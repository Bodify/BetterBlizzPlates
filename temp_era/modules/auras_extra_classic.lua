local frame = nil
local isRunning = false
local auraCallback = nil
local auraFilter = nil
local playerGUID = nil
local learnedDurations = {}
local activeAuras = {}
local ExtraAuraTracker = nil
local ExtraAuraCache = {}

function BBP.GetExtraAurasForGUID(guid)
    if not ExtraAuraCache[guid] then return {} end

    local currentTime = GetTime()
    for spellID, auraInfo in pairs(ExtraAuraCache[guid]) do
        if auraInfo.expirationTime and auraInfo.expirationTime > 0 and currentTime >= auraInfo.expirationTime then
            ExtraAuraCache[guid][spellID] = nil
        end
    end
    return ExtraAuraCache[guid]
end

local function ScheduleAuraExpiration(guid, spellID, duration)
    if duration <= 0 then return end

    C_Timer.After(duration, function()
        if ExtraAuraCache[guid] and ExtraAuraCache[guid][spellID] then
            ExtraAuraCache[guid][spellID] = nil
            BBP.RefreshNameplateByGUID(guid)
        end
    end)
end

function BBP.InitializeExtraAuraTracking()
    if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then return end
    if not BBP.CreateExtraAuraFullTracker or ExtraAuraTracker then return end

    ExtraAuraTracker = BBP.CreateExtraAuraFullTracker({
        filter = function(auraData)
            if auraData.auraType ~= "BUFF" then
                return false
            end

            local targetIsHostile = bit.band(auraData.targetFlags or 0, 0x00000040) ~= 0
            local targetIsNeutral = bit.band(auraData.targetFlags or 0, 0x00000020) ~= 0

            return targetIsHostile or targetIsNeutral
        end,
        onAuraAdded = function(auraData)
            if not ExtraAuraCache[auraData.targetGUID] then
                ExtraAuraCache[auraData.targetGUID] = {}
            end

            local duration = 0
            local expirationTime = 0

            if BBP.GetExtraAuraDuration then
                duration = BBP.GetExtraAuraDuration(auraData.spellID)
                expirationTime = GetTime() + duration
            end

            ExtraAuraCache[auraData.targetGUID][auraData.spellID] = {
                name = auraData.spellName,
                icon = GetSpellTexture(auraData.spellID),
                count = 1,
                debuffType = auraData.auraType,
                duration = duration,
                expirationTime = expirationTime,
                sourceUnit = nil,
                sourceGUID = auraData.sourceGUID,
                isStealable = auraData.auraType == "Magic",
                spellId = auraData.spellID,
                castByPlayer = auraData.sourceIsPlayer,
                isHelpful = true,
                isHarmful = false,
                isBuff = true,
                timestamp = auraData.timestamp,
                fromExtraAuras = true,
            }

            ScheduleAuraExpiration(auraData.targetGUID, auraData.spellID, duration)
            BBP.RefreshNameplateByGUID(auraData.targetGUID)
        end,
        onAuraRemoved = function(auraData)
            if ExtraAuraCache[auraData.targetGUID] then
                ExtraAuraCache[auraData.targetGUID][auraData.spellID] = nil
            end

            BBP.RefreshNameplateByGUID(auraData.targetGUID)
        end,
        autoStart = true,
    })
end

function BBP.RefreshNameplateByGUID(guid)
    if not guid then return end

    for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
        local unitFrame = namePlate.UnitFrame
        if unitFrame.unit and UnitGUID(unitFrame.unit) == guid then
            BBP.ProcessAurasForNameplate(unitFrame, unitFrame.unit)
            break
        end
    end
end

local KNOWN_DURATIONS = {}
local COMBATLOG_OBJECT_REACTION_HOSTILE = 0x00000040
local COMBATLOG_OBJECT_REACTION_NEUTRAL = 0x00000020
local COMBATLOG_OBJECT_REACTION_FRIENDLY = 0x00000010

local function GetNpcIdFromGuid(guid)
    if not guid then return 0 end
    local npcID = select(6, strsplit("-", guid))
    return tonumber(npcID) or 0
end

local function ParseAffiliation(flags)
    if not flags then return false, false, false end
    local isHostile = bit.band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0
    local isNeutral = bit.band(flags, COMBATLOG_OBJECT_REACTION_NEUTRAL) ~= 0
    local isFriendly = bit.band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
    return isHostile, isNeutral, isFriendly
end

local function GetAuraDuration(spellId)
    if learnedDurations[spellId] and #learnedDurations[spellId] > 0 then
        local avg = 0
        local count = math.min(#learnedDurations[spellId], 5)
        for i = #learnedDurations[spellId] - count + 1, #learnedDurations[spellId] do
            avg = avg + learnedDurations[spellId][i]
        end
        return avg / count
    end

    if KNOWN_DURATIONS[spellId] then
        return KNOWN_DURATIONS[spellId]
    end

    local name, _, icon, castTime = GetSpellInfo(spellId)
    if castTime and castTime > 0 then
        return castTime / 1000
    end

    return 30
end

local function OnCombatLogEvent(self, event)
    local timestamp, subevent, _,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          spellID, spellName, spellSchool, auraType = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_AURA_APPLIED" then
        activeAuras[destGUID] = activeAuras[destGUID] or {}
        activeAuras[destGUID][spellID] = {
            applyTime = GetTime(),
            timestamp = timestamp
        }
    elseif subevent == "SPELL_AURA_REMOVED" then
        if activeAuras[destGUID] and activeAuras[destGUID][spellID] then
            local duration = GetTime() - activeAuras[destGUID][spellID].applyTime

            if duration >= 1 and duration <= 3600 then
                learnedDurations[spellID] = learnedDurations[spellID] or {}
                table.insert(learnedDurations[spellID], duration)

                if #learnedDurations[spellID] > 10 then
                    table.remove(learnedDurations[spellID], 1)
                end
            end

            activeAuras[destGUID][spellID] = nil
        end
    end

    if subevent ~= "SPELL_AURA_APPLIED" and subevent ~= "SPELL_AURA_REMOVED" then
        return
    end

    local isHostile, isNeutral, isFriendly = ParseAffiliation(sourceFlags)
    local npcID = GetNpcIdFromGuid(sourceGUID)

    local auraData = {
        timestamp = timestamp,
        event = subevent,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        sourceFlags = sourceFlags,
        sourceIsPlayer = sourceGUID == playerGUID,
        sourceIsHostile = isHostile,
        sourceIsNeutral = isNeutral,
        sourceIsFriendly = isFriendly,
        targetGUID = destGUID,
        targetName = destName,
        targetFlags = destFlags,
        spellID = spellID,
        spellName = spellName,
        auraType = auraType,
        npcID = npcID,
    }

    if auraFilter and not auraFilter(auraData) then
        return
    end

    if auraCallback then
        auraCallback(auraData)
    end
end

local function UpdatePlayerGUID()
    playerGUID = UnitGUID("player")
end

function BBP.InitializeExtraAuraDetection(callback)
    if type(callback) ~= "function" then return end

    auraCallback = callback

    if not frame then
        frame = CreateFrame("Frame", "CLEU_AuraDetectorFrame")
        frame:SetScript("OnEvent", OnCombatLogEvent)

        local guidFrame = CreateFrame("Frame")
        guidFrame:RegisterEvent("PLAYER_LOGIN")
        guidFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        guidFrame:SetScript("OnEvent", UpdatePlayerGUID)
        UpdatePlayerGUID()
    end
end

function BBP.SetExtraAuraFilter(filterFunc)
    if filterFunc and type(filterFunc) ~= "function" then return end
    auraFilter = filterFunc
end

function BBP.StartExtraAuraDetection()
    if not frame then return end

    if not isRunning then
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        isRunning = true
    end
end

function BBP.StopExtraAuraDetection()
    if frame and isRunning then
        frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        isRunning = false
    end
end

function BBP.IsExtraAuraDetectionRunning()
    return isRunning
end

function BBP.CreateExtraAuraTracker()
    local aurasByTarget = {}

    local tracker = {
        AddAura = function(self, auraData)
            if not aurasByTarget[auraData.targetGUID] then
                aurasByTarget[auraData.targetGUID] = {}
            end
            aurasByTarget[auraData.targetGUID][auraData.spellID] = auraData
        end,

        RemoveAura = function(self, auraData)
            if aurasByTarget[auraData.targetGUID] then
                aurasByTarget[auraData.targetGUID][auraData.spellID] = nil
            end
        end,

        GetAuras = function(self, targetGUID)
            return aurasByTarget[targetGUID] or {}
        end,

        GetAura = function(self, targetGUID, spellID)
            if aurasByTarget[targetGUID] then
                return aurasByTarget[targetGUID][spellID]
            end
            return nil
        end,

        Clear = function(self, targetGUID)
            if targetGUID then
                aurasByTarget[targetGUID] = nil
            else
                aurasByTarget = {}
            end
        end,

        GetAllTargets = function(self)
            local targets = {}
            for guid, _ in pairs(aurasByTarget) do
                table.insert(targets, guid)
            end
            return targets
        end,
    }

    return tracker
end

function BBP.CreateExtraAuraFullTracker(options)
    options = options or {}

    local tracker = BBP.CreateExtraAuraTracker()

    BBP.InitializeExtraAuraDetection(function(auraData)
        if auraData.event == "SPELL_AURA_APPLIED" then
            tracker:AddAura(auraData)

            if options.onAuraAdded then
                options.onAuraAdded(auraData)
            end
        elseif auraData.event == "SPELL_AURA_REMOVED" then
            tracker:RemoveAura(auraData)

            if options.onAuraRemoved then
                options.onAuraRemoved(auraData)
            end
        end
    end)

    if options.filter then
        BBP.SetExtraAuraFilter(options.filter)
    end

    if options.autoStart ~= false then
        BBP.StartExtraAuraDetection()
    end

    return tracker
end

BBP.GetExtraAuraDuration = GetAuraDuration
BBP.AddKnownAuraDuration = function(spellID, duration)
    KNOWN_DURATIONS[spellID] = duration
end

