-- Table with spec IDs
local specIDToName = {
    -- Death Knight
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    -- Demon Hunter
    [577] = "Havoc", [581] = "Vengeance", [1480] = "Devourer",
    -- Druid
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Restoration",
    -- Evoker
    [1467] = "Devastation", [1468] = "Preservation", [1473] = "Augmentation",
    -- Hunter
    [253] = "Beast Mastery", [254] = "Marksmanship", [255] = "Survival",
    -- Mage
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    -- Monk
    [268] = "Brewmaster", [270] = "Mistweaver", [269] = "Windwalker",
    -- Paladin
    [65] = "Holy", [66] = "Protection", [70] = "Retribution",
    -- Priest
    [256] = "Discipline", [257] = "Holy", [258] = "Shadow",
    -- Rogue
    [259] = "Assassination", [260] = "Outlaw", [261] = "Subtlety",
    -- Shaman
    [262] = "Elemental", [263] = "Enhancement", [264] = "Restoration",
    -- Warlock
    [265] = "Affliction", [266] = "Demonology", [267] = "Destruction",
    -- Warrior
    [71] = "Arms", [72] = "Fury", [73] = "Protection",
}

local specIDToNameShort = {
    -- Death Knight
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    -- Demon Hunter
    [577] = "Havoc", [581] = "Vengeance", [1480] = "Devourer",
    -- Druid
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Resto",
    -- Evoker
    [1467] = "Dev", [1468] = "Pres", [1473] = "Aug",
    -- Hunter
    [253] = "BM", [254] = "Marksman", [255] = "Survival",
    -- Mage
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    -- Monk
    [268] = "Brewmaster", [270] = "Mistweaver", [269] = "Windwalker",
    -- Paladin
    [65] = "Holy", [66] = "Prot", [70] = "Ret",
    -- Priest
    [256] = "Disc", [257] = "Holy", [258] = "Shadow",
    -- Rogue
    [259] = "Assa", [260] = "Outlaw", [261] = "Sub",
    -- Shaman
    [262] = "Ele", [263] = "Enha", [264] = "Resto",
    -- Warlock
    [265] = "Aff", [266] = "Demo", [267] = "Destro",
    -- Warrior
    [71] = "Arms", [72] = "Fury", [73] = "Prot",
}

local idCircleColor = {
    [1] = {0.9, 0.2, 0.2, 1}, -- Red
    [2] = {0.2, 0.9, 0.2, 1}, -- Green
    [3] = {0.2, 0.2, 0.9, 1}, -- Blue
}

local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local UnitIsUnit        = UnitIsUnit
local GetArenaOpponentSpec = GetArenaOpponentSpec

local arenaCache   = {}  -- [1..3] = { class, race, sex, power, spec }
local plateToIndex = {}  -- [plate]      = arenaIndex
local indexToPlate = {}  -- [arenaIndex] = plate

local partyCache        = {}  -- [1..2] = { class, race, sex, power }
local partyPlateToIndex = {}  -- [plate]       = partyIndex
local partyIndexToPlate = {}  -- [partyIndex]  = plate

local function safeVal(v)
    if v == nil or issecretvalue(v) then return nil end
    return v
end

local function readUnitProps(unit)
    local _, class = UnitClass(unit)
    local _, race  = UnitRace(unit)
    return {
        class = safeVal(class),
        race  = safeVal(race),
        sex   = safeVal(UnitSex(unit)),
        power = safeVal(UnitPowerType(unit)),
    }
end

local function isValidEnemy(unit)
    return unit
        and UnitIsPlayer(unit)
        and UnitIsEnemy("player", unit)
        and not UnitIsPossessed(unit)
end

local function isValidFriendly(unit)
    return unit
        and UnitIsPlayer(unit)
        and not UnitIsEnemy("player", unit)
        and not UnitIsPossessed(unit)
end

local function cacheArenaIndex(idx)
    local arenaUnit = "arena" .. idx
    if not UnitExists(arenaUnit) then
        local specID = GetArenaOpponentSpec(idx)
        if specID and specID ~= 0 then
            local _, _, _, _, _, classFile = GetSpecializationInfoByID(specID)
            arenaCache[idx] = arenaCache[idx] or {}
            arenaCache[idx].spec = specID
            if classFile then arenaCache[idx].class = classFile end
        end
        return
    end
    local props = readUnitProps(arenaUnit)
    local specID = GetArenaOpponentSpec(idx)
    if specID and specID ~= 0 then
        props.spec = specID
        if not props.class then
            local _, _, _, _, _, classFile = GetSpecializationInfoByID(specID)
            if classFile then props.class = classFile end
        end
    end

    if arenaCache[idx] then
        for k, v in pairs(props) do
            if v then arenaCache[idx][k] = v end
        end
    else
        arenaCache[idx] = props
    end
end

local function buildArenaCache()
    local numSpecs = GetNumArenaOpponentSpecs and GetNumArenaOpponentSpecs() or 0
    for i = 1, 3 do
        if numSpecs >= i or UnitExists("arena" .. i) then
            cacheArenaIndex(i)
        end
    end
end

local function wipePlateMappings()
    for plate in pairs(plateToIndex) do
        if plate.UnitFrame then
            plate.UnitFrame.arenaID = nil
        end
    end
    wipe(plateToIndex)
    wipe(indexToPlate)
end

local function wipeArenaState()
    wipe(arenaCache)
    wipePlateMappings()
end

local function propsMatch(unitProps, idx)
    local cached = arenaCache[idx]
    if not cached then return nil end

    local checked = 0
    if unitProps.class and cached.class then
        if unitProps.class ~= cached.class then return false end
        checked = checked + 1
    end
    if unitProps.race and cached.race then
        if unitProps.race ~= cached.race then return false end
        checked = checked + 1
    end
    if unitProps.sex and cached.sex then
        if unitProps.sex ~= cached.sex then return false end
        checked = checked + 1
    end
    if unitProps.power and cached.power then
        if unitProps.power ~= cached.power then return false end
        checked = checked + 1
    end

    return checked > 0 and true or nil
end

local function tagPlate(plate, idx)
    local oldIdx = plateToIndex[plate]
    if oldIdx and oldIdx ~= idx then
        indexToPlate[oldIdx] = nil
    end
    local oldPlate = indexToPlate[idx]
    if oldPlate and oldPlate ~= plate then
        plateToIndex[oldPlate] = nil
        if oldPlate.UnitFrame then oldPlate.UnitFrame.arenaID = nil end
    end

    plateToIndex[plate] = idx
    indexToPlate[idx]   = plate
    if plate.UnitFrame then plate.UnitFrame.arenaID = idx end
end

local function untagPlate(plate)
    local idx = plateToIndex[plate]
    if idx then indexToPlate[idx] = nil end
    plateToIndex[plate] = nil
    if plate.UnitFrame then plate.UnitFrame.arenaID = nil end
end

local function tryTagByFingerprint(plate)
    local frame = plate.UnitFrame
    if not frame or not frame.unit then return false end
    if not isValidEnemy(frame.unit) then return false end
    if plateToIndex[plate] then return true end

    local props = readUnitProps(frame.unit)
    local candidates = {}
    for i = 1, 3 do
        if arenaCache[i] and not indexToPlate[i] then
            if propsMatch(props, i) == true then
                candidates[#candidates + 1] = i
            end
        end
    end

    if #candidates == 1 then
        tagPlate(plate, candidates[1])
        return true
    end
    return false
end

local function learnViaIntermediary(plate, intermediary)
    local frame = plate.UnitFrame
    if not frame or not frame.unit then return false end
    if not isValidEnemy(frame.unit) then return false end
    if not UnitIsUnit(frame.unit, intermediary) then return false end

    for i = 1, 3 do
        if UnitIsUnit(intermediary, "arena" .. i) then
            local props = readUnitProps(frame.unit)
            local specID = GetArenaOpponentSpec(i)
            if specID and specID ~= 0 then props.spec = specID end
            if not arenaCache[i] then arenaCache[i] = {} end
            for k, v in pairs(props) do
                if v then arenaCache[i][k] = v end
            end
            tagPlate(plate, i)
            return true
        end
    end
    return false
end

local function tryElimination()
    local knownCount, missingIdx = 0, nil
    local totalKnown = 0
    for i = 1, 3 do
        if arenaCache[i] then
            totalKnown = totalKnown + 1
            if indexToPlate[i] then
                knownCount = knownCount + 1
            else
                missingIdx = i
            end
        end
    end
    if not missingIdx or knownCount ~= totalKnown - 1 then return end

    local untagged = {}
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = plate.UnitFrame
        if frame and frame.unit and isValidEnemy(frame.unit) and not plateToIndex[plate] then
            local props = readUnitProps(frame.unit)
            if propsMatch(props, missingIdx) ~= false then
                untagged[#untagged + 1] = plate
            end
        end
    end

    if #untagged == 1 then
        tagPlate(untagged[1], missingIdx)
    end
end

local function refreshAll()
    if not BBP.isInArena then return end

    for plate, idx in pairs(plateToIndex) do
        local frame = plate.UnitFrame
        if not frame or not frame.unit or not isValidEnemy(frame.unit) then
            untagPlate(plate)
        else
            if propsMatch(readUnitProps(frame.unit), idx) == false then
                untagPlate(plate)
            end
        end
    end

    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        if not plateToIndex[plate] then
            local frame = plate.UnitFrame
            if frame and frame.unit and isValidEnemy(frame.unit) then
                if not learnViaIntermediary(plate, "target")
                and not learnViaIntermediary(plate, "focus")
                and not learnViaIntermediary(plate, "mouseover") then
                    tryTagByFingerprint(plate)
                end
            end
        end
    end

    tryElimination()
end

local function onPlateAdded(unitToken)
    if not BBP.isInArena then return end
    local plate, frame = BBP.GetSafeNameplate(unitToken)
    if not frame then return end
    local unit = frame.unit
    if not unit or not isValidEnemy(unit) then return end

    if plateToIndex[plate] then
        local idx = plateToIndex[plate]
        if propsMatch(readUnitProps(unit), idx) == false then
            untagPlate(plate)
        else
            return
        end
    end

    if not learnViaIntermediary(plate, "target")
    and not learnViaIntermediary(plate, "focus")
    and not learnViaIntermediary(plate, "mouseover") then
        tryTagByFingerprint(plate)
    end

    tryElimination()
end

local function onIntermediaryChanged(intermediary)
    if not BBP.isInArena then return end
    if not UnitExists(intermediary) then return end

    local arenaIdx
    for i = 1, 3 do
        if UnitIsUnit(intermediary, "arena" .. i) then
            arenaIdx = i
            break
        end
    end
    if not arenaIdx then return end

    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = plate.UnitFrame
        if not frame or not frame.unit then
            -- skip
        elseif UnitIsUnit(frame.unit, intermediary) and isValidEnemy(frame.unit) then
            learnViaIntermediary(plate, intermediary)
        elseif plateToIndex[plate] == arenaIdx then
            untagPlate(plate)
        end
    end

    refreshAll()
end

-- Party cache and fingerprinting (mirrors arena system)
local function cachePartyIndex(idx)
    local partyUnit = "party" .. idx
    if not UnitExists(partyUnit) then return end
    local props = readUnitProps(partyUnit)
    if partyCache[idx] then
        for k, v in pairs(props) do
            if v then partyCache[idx][k] = v end
        end
    else
        partyCache[idx] = props
    end
end

local function buildPartyCache()
    for i = 1, 2 do
        if UnitExists("party" .. i) then
            cachePartyIndex(i)
        end
    end
end

local function wipePartyPlateMappings()
    for plate in pairs(partyPlateToIndex) do
        if plate.UnitFrame then
            plate.UnitFrame.partyID = nil
        end
    end
    wipe(partyPlateToIndex)
    wipe(partyIndexToPlate)
end

local function wipePartyState()
    wipe(partyCache)
    wipePartyPlateMappings()
end

local function partyPropsMatch(unitProps, idx)
    local cached = partyCache[idx]
    if not cached then return nil end

    local checked = 0
    if unitProps.class and cached.class then
        if unitProps.class ~= cached.class then return false end
        checked = checked + 1
    end
    if unitProps.race and cached.race then
        if unitProps.race ~= cached.race then return false end
        checked = checked + 1
    end
    if unitProps.sex and cached.sex then
        if unitProps.sex ~= cached.sex then return false end
        checked = checked + 1
    end
    if unitProps.power and cached.power then
        if unitProps.power ~= cached.power then return false end
        checked = checked + 1
    end

    return checked > 0 and true or nil
end

local function tagPartyPlate(plate, idx)
    local oldIdx = partyPlateToIndex[plate]
    if oldIdx and oldIdx ~= idx then
        partyIndexToPlate[oldIdx] = nil
    end
    local oldPlate = partyIndexToPlate[idx]
    if oldPlate and oldPlate ~= plate then
        partyPlateToIndex[oldPlate] = nil
        if oldPlate.UnitFrame then oldPlate.UnitFrame.partyID = nil end
    end

    partyPlateToIndex[plate] = idx
    partyIndexToPlate[idx]   = plate
    if plate.UnitFrame then plate.UnitFrame.partyID = idx end
end

local function untagPartyPlate(plate)
    local idx = partyPlateToIndex[plate]
    if idx then partyIndexToPlate[idx] = nil end
    partyPlateToIndex[plate] = nil
    if plate.UnitFrame then plate.UnitFrame.partyID = nil end
end

local function tryTagPartyByFingerprint(plate)
    local frame = plate.UnitFrame
    if not frame or not frame.unit then return false end
    if not isValidFriendly(frame.unit) then return false end
    if partyPlateToIndex[plate] then return true end

    local props = readUnitProps(frame.unit)
    local candidates = {}
    for i = 1, 2 do
        if partyCache[i] and not partyIndexToPlate[i] then
            if partyPropsMatch(props, i) == true then
                candidates[#candidates + 1] = i
            end
        end
    end

    if #candidates == 1 then
        tagPartyPlate(plate, candidates[1])
        return true
    end
    return false
end

local function learnPartyViaIntermediary(plate, intermediary)
    local frame = plate.UnitFrame
    if not frame or not frame.unit then return false end
    if not isValidFriendly(frame.unit) then return false end
    if not UnitIsUnit(frame.unit, intermediary) then return false end

    for i = 1, 2 do
        if UnitIsUnit(intermediary, "party" .. i) then
            local props = readUnitProps(frame.unit)
            if not partyCache[i] then partyCache[i] = {} end
            for k, v in pairs(props) do
                if v then partyCache[i][k] = v end
            end
            tagPartyPlate(plate, i)
            return true
        end
    end
    return false
end

local function tryPartyElimination()
    local knownCount, missingIdx = 0, nil
    local totalKnown = 0
    for i = 1, 2 do
        if partyCache[i] then
            totalKnown = totalKnown + 1
            if partyIndexToPlate[i] then
                knownCount = knownCount + 1
            else
                missingIdx = i
            end
        end
    end
    if not missingIdx or knownCount ~= totalKnown - 1 then return end

    local untagged = {}
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = plate.UnitFrame
        if frame and frame.unit and isValidFriendly(frame.unit) and not partyPlateToIndex[plate] then
            local props = readUnitProps(frame.unit)
            if partyPropsMatch(props, missingIdx) ~= false then
                untagged[#untagged + 1] = plate
            end
        end
    end

    if #untagged == 1 then
        tagPartyPlate(untagged[1], missingIdx)
    end
end

local function refreshAllParty()
    if not BBP.isInArena then return end

    for plate, idx in pairs(partyPlateToIndex) do
        local frame = plate.UnitFrame
        if not frame or not frame.unit or not isValidFriendly(frame.unit) then
            untagPartyPlate(plate)
        else
            if partyPropsMatch(readUnitProps(frame.unit), idx) == false then
                untagPartyPlate(plate)
            end
        end
    end

    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        if not partyPlateToIndex[plate] then
            local frame = plate.UnitFrame
            if frame and frame.unit and isValidFriendly(frame.unit) then
                if not learnPartyViaIntermediary(plate, "target")
                and not learnPartyViaIntermediary(plate, "focus")
                and not learnPartyViaIntermediary(plate, "mouseover") then
                    tryTagPartyByFingerprint(plate)
                end
            end
        end
    end

    tryPartyElimination()
end

local function onPartyPlateAdded(unitToken)
    if not BBP.isInArena then return end
    local plate, frame = BBP.GetSafeNameplate(unitToken)
    if not frame then return end
    local unit = frame.unit
    if not unit or not isValidFriendly(unit) then return end

    if partyPlateToIndex[plate] then
        local idx = partyPlateToIndex[plate]
        if partyPropsMatch(readUnitProps(unit), idx) == false then
            untagPartyPlate(plate)
        else
            return
        end
    end

    if not learnPartyViaIntermediary(plate, "target")
    and not learnPartyViaIntermediary(plate, "focus")
    and not learnPartyViaIntermediary(plate, "mouseover") then
        tryTagPartyByFingerprint(plate)
    end

    tryPartyElimination()
end

local function onPartyIntermediaryChanged(intermediary)
    if not BBP.isInArena then return end
    if not UnitExists(intermediary) then return end

    local partyIdx
    for i = 1, 2 do
        if UnitIsUnit(intermediary, "party" .. i) then
            partyIdx = i
            break
        end
    end
    if not partyIdx then return end

    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = plate.UnitFrame
        if not frame or not frame.unit then
            -- skip
        elseif UnitIsUnit(frame.unit, intermediary) and isValidFriendly(frame.unit) then
            learnPartyViaIntermediary(plate, intermediary)
        elseif partyPlateToIndex[plate] == partyIdx then
            untagPartyPlate(plate)
        end
    end

    refreshAllParty()
end

local function checkPendingUpdates()
    if (BBP.pendingSpecIconCount or 0) > 0 or (BBP.pendingHealerCount or 0) > 0 then
        for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
            local frame = plate and plate.UnitFrame
            if frame and BBP.GetSpecID(frame) then
                if frame.needsSpecIconUpdate then
                    frame.needsSpecIconUpdate = nil
                    BBP.pendingSpecIconCount = (BBP.pendingSpecIconCount or 0) - 1
                    BBP.ClassIndicator(frame)
                end
                if frame.needsHealerUpdate then
                    frame.needsHealerUpdate = nil
                    BBP.pendingHealerCount = (BBP.pendingHealerCount or 0) - 1
                    BBP.HealerIndicator(frame)
                end
            end
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PVP_MATCH_STATE_CHANGED")
f:RegisterEvent("PVP_MATCH_ACTIVE")
f:RegisterEvent("ARENA_OPPONENT_UPDATE")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("PLAYER_FOCUS_CHANGED")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:SetScript("OnEvent", function(_, event, unitToken)

    if event == "PVP_MATCH_STATE_CHANGED" then
        local state = C_PvP.GetActiveMatchState()
        if state == Enum.PvPMatchState.Inactive
        or state == Enum.PvPMatchState.Waiting
        or state == Enum.PvPMatchState.StartUp
        or state == Enum.PvPMatchState.PostRound then
            wipeArenaState()
            wipePartyState()
        elseif state == Enum.PvPMatchState.Engaged then
            wipePlateMappings()
            buildArenaCache()
            refreshAll()
            wipePartyPlateMappings()
            buildPartyCache()
            refreshAllParty()
            checkPendingUpdates()
        end
        return
    end

    if event == "PVP_MATCH_ACTIVE" then
        wipeArenaState()
        wipePartyState()
        buildArenaCache()
        buildPartyCache()
        refreshAll()
        refreshAllParty()
        checkPendingUpdates()
        return
    end

    if not BBP.isInArena then return end

    if event == "ARENA_OPPONENT_UPDATE" then
        buildArenaCache()
        local state = C_PvP.GetActiveMatchState()
        if state == Enum.PvPMatchState.Engaged then
            refreshAll()
            checkPendingUpdates()
        end
        return
    end

    if event == "NAME_PLATE_UNIT_ADDED" then
        onPlateAdded(unitToken)
        onPartyPlateAdded(unitToken)
        checkPendingUpdates()
        return
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        if unitToken then
            local plate, frame = BBP.GetSafeNameplate(unitToken)
            if plate then
                untagPlate(plate)
                untagPartyPlate(plate)
            end
        end
        return
    end

    if event == "PLAYER_TARGET_CHANGED" then
        onIntermediaryChanged("target")
        onPartyIntermediaryChanged("target")
        checkPendingUpdates()
        return
    end

    if event == "PLAYER_FOCUS_CHANGED" then
        onIntermediaryChanged("focus")
        onPartyIntermediaryChanged("focus")
        checkPendingUpdates()
        return
    end

    if event == "UPDATE_MOUSEOVER_UNIT" then
        onIntermediaryChanged("mouseover")
        onPartyIntermediaryChanged("mouseover")
        checkPendingUpdates()
        return
    end
end)

function BBP.GetArenaIndexByFrame(frame)
    if not frame.unit then return nil end
    if frame.arenaID then return frame.arenaID end
    local plate = BBP.GetSafeNameplate(frame.unit)
    if not plate then return nil end
    return plateToIndex[plate]
end

function BBP.GetPartyIndexByFrame(frame)
    if not frame.unit then return nil end
    if frame.partyID then return frame.partyID end
    local plate = BBP.GetSafeNameplate(frame.unit)
    if not plate then return nil end
    return partyPlateToIndex[plate]
end

function BBP.GetArenaSpec(idx)
    local cached = arenaCache[idx]
    return cached and cached.spec
end

local function createSpexText(frame)
    if not frame.specNameText then
        frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
        --local db = BetterBlizzPlatesDB
        --BBP.SetFontBasedOnOption(frame.specNameText, 12, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or nil)
        BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
        frame.specNameText:SetIgnoreParentScale(true)
        if BetterBlizzPlatesDB.arenaIdAnchorRaiseStrata then
            frame.specNameText:SetParent(frame.bbpOverlay)
        end
    end
    local anchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local justify = (anchor == "LEFT" or anchor == "RIGHT") and anchor or "CENTER"
    frame.specNameText:SetJustifyH(justify)

    local anchorPoint
    if anchor == "LEFT" then
        anchorPoint = "BOTTOMLEFT"
    elseif anchor == "RIGHT" then
        anchorPoint = "BOTTOMRIGHT"
    else
        anchorPoint = "BOTTOM"
    end
    
    return anchorPoint
end

local function createIDText(frame)
    if not frame.arenaNumberText then
        frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
        BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
        frame.arenaNumberText:SetIgnoreParentScale(true)
        if BetterBlizzPlatesDB.arenaIdAnchorRaiseStrata then
            frame.arenaNumberText:SetParent(frame.bbpOverlay)
        end
    end
end

--there is so much room for improvement here... oh well future me will surely have improved it.

local function addIdCircle(frame, index)
    local color = idCircleColor[index]
    if not frame.arenaNumberCircle then
        frame.arenaNumberCircle = frame:CreateTexture(nil, "BACKGROUND")
        frame.arenaNumberCircle:SetAtlas("UI-QuestPoi-QuestNumber-SuperTracked")
        frame.arenaNumberCircle:SetSize(32, 32)
        frame.arenaNumberCircle:SetDesaturated(true)
        frame.arenaNumberCircle:SetVertexColor(unpack(color))
        frame.arenaNumberCircle:SetPoint("CENTER", frame.arenaNumberText, "CENTER", -1, 0.5)
    end
    frame.arenaNumberCircle:Show()
    frame.arenaNumberText:SetTextColor(1,1,1)
    frame.arenaNumberCircle:SetVertexColor(unpack(color))
end

-- Arena Indicator for Arena Units
-- Mode 1: Replace name with ID
function BBP.ArenaIndicator1(frame)
    local enemyClassColorName = BetterBlizzPlatesDB.enemyClassColorName or BetterBlizzPlatesDB.enemyColorName
    local arenaIdAnchor  = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos    = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos    = BetterBlizzPlatesDB.arenaIdYPos
    local arenaIDScale   = BetterBlizzPlatesDB.arenaIDScale
    local idCircle       = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0

    -- resolve arena index without Unit* APIs
    local idx = BBP.GetArenaIndexByFrame(frame)
    if not idx then return end

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("arena"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    local r, g, b = 1, 1, 0
    if enemyClassColorName then
        r, g, b = frame.name:GetTextColor()
    end

    createIDText(frame)

    frame.name:SetText("")
    frame.name:SetAlpha(0)
    frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, arenaIdAnchor, arenaIdXPos + idCircleOffset, arenaIdYPos)
    frame.arenaNumberText:SetText(idx)
    if enemyClassColorName then
        frame.arenaNumberText:SetTextColor(r, g, b, 1)
    else
        frame.arenaNumberText:SetTextColor(1, 1, 0)
    end
    frame.arenaNumberText:SetIgnoreParentScale(false)
    frame.arenaNumberText:SetScale(arenaIDScale)
    frame.arenaNumberText:SetIgnoreParentScale(true)

    if idCircle then
        addIdCircle(frame, idx)
    end
end


-- Mode 2: Put ID on top of name
function BBP.ArenaIndicator2(frame)
    local enemyClassColorName = BetterBlizzPlatesDB.enemyClassColorName or BetterBlizzPlatesDB.enemyColorName
    local arenaIdAnchor  = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos    = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos    = BetterBlizzPlatesDB.arenaIdYPos
    local arenaIDScale   = BetterBlizzPlatesDB.arenaIDScale
    local idCircle       = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0

    local idx = BBP.GetArenaIndexByFrame(frame)
    if not idx then return end

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("arena"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    local r, g, b = 1, 1, 0
    if enemyClassColorName then
        r, g, b = frame.name:GetTextColor()
    end

    createIDText(frame)

    frame.arenaNumberText:SetText(idx)
    if enemyClassColorName then
        frame.arenaNumberText:SetTextColor(r, g, b, 1)
    else
        frame.arenaNumberText:SetTextColor(1, 1, 0)
    end
    frame.arenaNumberText:SetIgnoreParentScale(false)
    frame.arenaNumberText:SetScale(arenaIDScale)
    frame.arenaNumberText:SetIgnoreParentScale(true)
    frame.arenaNumberText:SetPoint("BOTTOM", frame.name, arenaIdAnchor, arenaIdXPos + idCircleOffset, arenaIdYPos)

    if idCircle then
        addIdCircle(frame, idx)
    end
end


-- Mode 3: Replace name with Spec
function BBP.ArenaIndicator3(frame)
    local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
    local arenaSpecScale   = BetterBlizzPlatesDB.arenaSpecScale
    local arenaSpecAnchor  = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos    = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos    = BetterBlizzPlatesDB.arenaSpecYPos

    local idx = BBP.GetArenaIndexByFrame(frame)
    if not idx then return end

    local specID = GetArenaOpponentSpec(idx)
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])

    local r, g, b = frame.name:GetTextColor()

    if not specName then
        local classLoc, class = UnitClass(frame.unit) or ""
        if class and not issecretvalue(class) then
            specName = classLoc ~= "" and classLoc or "Unknown"
        else
            specName = UnitName(frame.unit) or "Unknown"
        end
    end

    local anchorPoint = createSpexText(frame)

    frame.name:SetText("")
    frame.name:SetAlpha(0)
    frame.specNameText:SetText(specName)

    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetIgnoreParentScale(false)
    frame.specNameText:SetScale(arenaSpecScale)
    frame.specNameText:SetIgnoreParentScale(true)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
end


-- Mode 4: Replace name with spec and ID on top
function BBP.ArenaIndicator4(frame)
    local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
    local arenaSpecScale   = BetterBlizzPlatesDB.arenaSpecScale
    local arenaSpecAnchor  = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos    = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos    = BetterBlizzPlatesDB.arenaSpecYPos

    local arenaIDScale     = BetterBlizzPlatesDB.arenaIDScale
    local arenaIdAnchor    = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos      = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos      = BetterBlizzPlatesDB.arenaIdYPos

    local enemyClassColorName = BetterBlizzPlatesDB.enemyClassColorName or BetterBlizzPlatesDB.enemyColorName
    local idCircle       = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0

    local idx = BBP.GetArenaIndexByFrame(frame)
    if not idx then return end

    local specID   = GetArenaOpponentSpec(idx)
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])

    if not specName then
        local classLoc, class = UnitClass(frame.unit) or ""
        if class and not issecretvalue(class) then
            specName = classLoc ~= "" and classLoc or "Unknown"
        else
            specName = UnitName(frame.unit) or "Unknown"
        end
    end

    local r, g, b = frame.name:GetTextColor()

    local anchorPoint = createSpexText(frame)
    createIDText(frame)

    frame.name:SetText("")
    frame.name:SetAlpha(0)

    frame.specNameText:SetText(specName)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetIgnoreParentScale(false)
    frame.specNameText:SetScale(arenaSpecScale)
    frame.specNameText:SetIgnoreParentScale(true)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("arena"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    frame.arenaNumberText:SetText(idx)
    if enemyClassColorName then
        frame.arenaNumberText:SetTextColor(r, g, b, 1)
    else
        frame.arenaNumberText:SetTextColor(1, 1, 0)
    end
    frame.arenaNumberText:SetIgnoreParentScale(false)
    frame.arenaNumberText:SetScale(arenaIDScale)
    frame.arenaNumberText:SetIgnoreParentScale(true)
    frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, arenaIdAnchor, arenaIdXPos + idCircleOffset, arenaIdYPos - 1)

    if idCircle then
        addIdCircle(frame, idx)
    end
end


-- Mode 5: Put ID and Spec on same line instead of name
function BBP.ArenaIndicator5(frame)
    local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
    local arenaSpecScale   = BetterBlizzPlatesDB.arenaSpecScale
    local arenaSpecAnchor  = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos    = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos    = BetterBlizzPlatesDB.arenaSpecYPos

    local idx = BBP.GetArenaIndexByFrame(frame)
    if not idx then return end

    local specID   = GetArenaOpponentSpec(idx)
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])

    if not specName then
        local classLoc, class = UnitClass(frame.unit) or ""
        if class and not issecretvalue(class) then
            specName = classLoc ~= "" and classLoc or "Unknown"
        else
            specName = UnitName(frame.unit) or "Unknown"
        end
    end

    local r, g, b = frame.name:GetTextColor()

    local anchorPoint = createSpexText(frame)

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("arena"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    frame.name:SetText("")
    frame.name:SetAlpha(0)
    frame.specNameText:SetText(specName .. " " .. idx)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetIgnoreParentScale(false)
    frame.specNameText:SetScale(arenaSpecScale)
    frame.specNameText:SetIgnoreParentScale(true)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
end


--#################################################################################
-- Party version
-- Mode 1: Replace name with ID
function BBP.PartyIndicator1(frame)
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos   = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos   = BetterBlizzPlatesDB.arenaIdYPos
    local partyIDScale  = BetterBlizzPlatesDB.partyIDScale

    local idx = BBP.GetPartyIndexByFrame(frame)
    if not idx then return end

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("party"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    local r, g, b = frame.name:GetTextColor()

    createIDText(frame)

    frame.name:SetText("")
    frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, arenaIdAnchor, arenaIdXPos, arenaIdYPos)
    frame.arenaNumberText:SetText(idx)
    frame.arenaNumberText:SetTextColor(r, g, b, 1)
    frame.arenaNumberText:SetIgnoreParentScale(false)
    frame.arenaNumberText:SetScale(partyIDScale)
    frame.arenaNumberText:SetIgnoreParentScale(true)
end


-- Mode 2: Put ID on top of name
function BBP.PartyIndicator2(frame)
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos   = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos   = BetterBlizzPlatesDB.arenaIdYPos
    local partyIDScale  = BetterBlizzPlatesDB.partyIDScale

    local idx = BBP.GetPartyIndexByFrame(frame)
    if not idx then return end

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("party"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    local r, g, b = frame.name:GetTextColor()

    createIDText(frame)

    frame.arenaNumberText:SetText(idx)
    frame.arenaNumberText:SetTextColor(r, g, b, 1)
    frame.arenaNumberText:SetIgnoreParentScale(false)
    frame.arenaNumberText:SetScale(partyIDScale)
    frame.arenaNumberText:SetIgnoreParentScale(true)
    frame.arenaNumberText:SetPoint("BOTTOM", frame.name, arenaIdAnchor, arenaIdXPos, arenaIdYPos)
end


-- Mode 3: Replace name with Spec
function BBP.PartyIndicator3(frame)
    local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
    local partySpecScale   = BetterBlizzPlatesDB.partySpecScale
    local arenaSpecAnchor  = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos    = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos    = BetterBlizzPlatesDB.arenaSpecYPos

    local idx = BBP.GetPartyIndexByFrame(frame)
    if not idx then return end

    local specID   = BBP.GetSpecID(frame)
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])

    if not specName then
        local classLoc, class = UnitClass(frame.unit) or ""
        if class and not issecretvalue(class) then
            specName = classLoc ~= "" and classLoc or "Unknown"
        else
            specName = UnitName(frame.unit) or "Unknown"
        end
    end

    local r, g, b = frame.name:GetTextColor()

    local anchorPoint = createSpexText(frame)

    frame.name:SetText("")
    frame.specNameText:SetText(specName)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetIgnoreParentScale(false)
    frame.specNameText:SetScale(partySpecScale)
    frame.specNameText:SetIgnoreParentScale(true)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
end


-- Mode 4: Replace name with spec and ID on top
function BBP.PartyIndicator4(frame)
    local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
    local partySpecScale   = BetterBlizzPlatesDB.partySpecScale
    local arenaSpecAnchor  = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos    = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos    = BetterBlizzPlatesDB.arenaSpecYPos

    local partyIDScale     = BetterBlizzPlatesDB.partyIDScale
    local arenaIdAnchor    = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos      = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos      = BetterBlizzPlatesDB.arenaIdYPos

    local idx = BBP.GetPartyIndexByFrame(frame)
    if not idx then return end

    local specID   = BBP.GetSpecID(frame)
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])
    if not specName then
        local classLoc, class = UnitClass(frame.unit) or ""
        if class and not issecretvalue(class) then
            specName = classLoc ~= "" and classLoc or "Unknown"
        else
            specName = UnitName(frame.unit) or "Unknown"
        end
    end

    local r, g, b = frame.name:GetTextColor()

    local anchorPoint = createSpexText(frame)
    createIDText(frame)

    frame.name:SetText("")

    frame.specNameText:SetText(specName)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetIgnoreParentScale(false)
    frame.specNameText:SetScale(partySpecScale)
    frame.specNameText:SetIgnoreParentScale(true)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("party"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    frame.arenaNumberText:SetText(idx)
    frame.arenaNumberText:SetTextColor(r, g, b, 1)
    frame.arenaNumberText:SetIgnoreParentScale(false)
    frame.arenaNumberText:SetScale(partyIDScale)
    frame.arenaNumberText:SetIgnoreParentScale(true)
    frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, arenaIdAnchor, arenaIdXPos, arenaIdYPos - 1)
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.PartyIndicator5(frame)
    local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
    local partySpecScale   = BetterBlizzPlatesDB.partySpecScale
    local arenaSpecAnchor  = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos    = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos    = BetterBlizzPlatesDB.arenaSpecYPos

    local idx = BBP.GetPartyIndexByFrame(frame)
    if not idx then return end

    local specID   = BBP.GetSpecID(frame)
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])
    if not specName then
        local classLoc, class = UnitClass(frame.unit) or ""
        if class and not issecretvalue(class) then
            specName = classLoc ~= "" and classLoc or "Unknown"
        else
            specName = UnitName(frame.unit) or "Unknown"
        end
    end

    local r, g, b = frame.name:GetTextColor()

    local anchorPoint = createSpexText(frame)

    if FrameSortApi then
        local FrameSortID = FrameSortApi.v3.Frame:FrameNumberForUnit("party"..idx)
        if FrameSortID then
            idx = FrameSortID
        end
    end

    frame.name:SetText("")
    frame.specNameText:SetText(specName .. " " .. idx)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetIgnoreParentScale(false)
    frame.specNameText:SetScale(partySpecScale)
    frame.specNameText:SetIgnoreParentScale(true)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
end





--#########################################################################################################
-- Test modes
-- If no mode selected
function BBP.TestArenaIndicator0(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction(frame.unit, "player") or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name or frame.healthBar, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos, BetterBlizzPlatesDB.arenaIdYPos + 3)
            frame.arenaNumberText:SetText("Select a mode to test (enemy)")
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            break
        end
    end
end
-- Mode 1: Replace name with ID
function BBP.TestArenaIndicator1(frame)
    local idCircle = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction(frame.unit, "player") or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos + idCircleOffset, BetterBlizzPlatesDB.arenaIdYPos)
            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)

            if idCircle then
                local i = math.random(1, 3)
                frame.arenaNumberText:SetText(tostring(i))
                addIdCircle(frame, i)
            end
            break
        end
    end
end

-- Mode 2: Put ID on top of name
function BBP.TestArenaIndicator2(frame)
    local idCircle = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction(frame.unit, "player") or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos + idCircleOffset, BetterBlizzPlatesDB.arenaIdYPos)

            if idCircle then
                local i = math.random(1, 3)
                frame.arenaNumberText:SetText(tostring(i))
                addIdCircle(frame, i)
            end
            break
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.TestArenaIndicator3(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction(frame.unit, "player") or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            frame.name:SetText("")
            local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
            if shortArenaSpecName then
                frame.specNameText:SetText("Aff")
            else
                frame.specNameText:SetText("Affliction")
            end
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetIgnoreParentScale(false)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetIgnoreParentScale(true)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            break
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.TestArenaIndicator4(frame)
    local idCircle = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction(frame.unit, "player") or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            createIDText(frame)

            frame.name:SetText("")
            local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
            if shortArenaSpecName then
                frame.specNameText:SetText("Aff")
            else
                frame.specNameText:SetText("Affliction")
            end
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetIgnoreParentScale(false)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetIgnoreParentScale(true)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos + idCircleOffset, BetterBlizzPlatesDB.arenaIdYPos - 1)

            if idCircle then
                local i = math.random(1, 3)
                frame.arenaNumberText:SetText(tostring(i))
                addIdCircle(frame, i)
            end
            break
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.TestArenaIndicator5(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction(frame.unit, "player") or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            frame.name:SetText("")
            local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
            if shortArenaSpecName then
                frame.specNameText:SetText("Aff" .. " " .. "3")
            else
                frame.specNameText:SetText("Affliction" .. " " .. "3")
            end
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetIgnoreParentScale(false)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetIgnoreParentScale(true)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            break
        end
    end
end


-- Mode 0: Replace name with ID
function BBP.TestPartyIndicator0(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos, BetterBlizzPlatesDB.arenaIdYPos + 3)
            frame.arenaNumberText:SetText("Select a mode to test (friendly)")
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            break
        end
    end
end

-- Mode 1: Replace name with ID 
function BBP.TestPartyIndicator1(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos, BetterBlizzPlatesDB.arenaIdYPos)
            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            break
        end
    end
end


-- Mode 2: Put ID on top of name
function BBP.TestPartyIndicator2(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos, BetterBlizzPlatesDB.arenaIdYPos)
            break
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.TestPartyIndicator3(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            frame.name:SetText("")
            local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
            if shortArenaSpecName then
                frame.specNameText:SetText("Aff")
            else
                frame.specNameText:SetText("Affliction")
            end
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetIgnoreParentScale(false)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetIgnoreParentScale(true)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            break
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.TestPartyIndicator4(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            createIDText(frame)

            frame.name:SetText("")
            local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
            if shortArenaSpecName then
                frame.specNameText:SetText("Aff")
            else
                frame.specNameText:SetText("Affliction")
            end
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetIgnoreParentScale(false)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetIgnoreParentScale(true)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetIgnoreParentScale(false)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
            frame.arenaNumberText:SetIgnoreParentScale(true)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, BetterBlizzPlatesDB.arenaIdAnchor, BetterBlizzPlatesDB.arenaIdXPos, BetterBlizzPlatesDB.arenaIdYPos - 1)
            break
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.TestPartyIndicator5(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            frame.name:SetText("")
            local shortArenaSpecName = BetterBlizzPlatesDB.shortArenaSpecName
            if shortArenaSpecName then
                frame.specNameText:SetText("Aff" .. " " .. "3")
            else
                frame.specNameText:SetText("Affliction" .. " " .. "3")
            end
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetIgnoreParentScale(false)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetIgnoreParentScale(true)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            break
        end
    end
end

function BBP.CleanArenaIndicators(frame)
    if frame.name then
        local removeRealmName = BetterBlizzPlatesDB.removeRealmNames
        if removeRealmName then
            BBP.RemoveRealmName(frame)
        else
            frame.name:SetText(GetUnitName(frame.unit, true))
        end
    end
    if frame.arenaNumberText then
        frame.arenaNumberText:SetText("")
    end
    if frame.specNameText then
        frame.specNameText:SetText("")
    end
end

--#########################################################################################################
-- The big consolidated caller
function BBP.ArenaIndicatorCaller(frame)
    local db = BetterBlizzPlatesDB
    -- Arena and party logic
    if not frame.unit then return end
    if IsActiveBattlefieldArena() then
        local unitType
        if UnitIsEnemy("player", frame.unit) then
            unitType = "arena"
        elseif not UnitIsUnit("player", frame.unit) then
            unitType = "party"
        end

        if unitType == "arena" then
            if not db.arenaIndicatorModeOff then
                if db.arenaIndicatorModeOne then
                    BBP.ArenaIndicator1(frame)
                elseif db.arenaIndicatorModeTwo then
                    BBP.ArenaIndicator2(frame)
                elseif db.arenaIndicatorModeThree then
                    BBP.ArenaIndicator3(frame)
                elseif db.arenaIndicatorModeFour then
                    BBP.ArenaIndicator4(frame)
                elseif db.arenaIndicatorModeFive then
                    BBP.ArenaIndicator5(frame)
                else
                    BBP.CleanArenaIndicators(frame)
                end
                return
            end
        elseif unitType == "party" then
            if not db.partyIndicatorModeOff then
                if db.partyIndicatorModeOne then
                    BBP.PartyIndicator1(frame)
                elseif db.partyIndicatorModeTwo then
                    BBP.PartyIndicator2(frame)
                elseif db.partyIndicatorModeThree then
                    BBP.PartyIndicator3(frame)
                elseif db.partyIndicatorModeFour then
                    BBP.PartyIndicator4(frame)
                elseif db.partyIndicatorModeFive then
                    BBP.PartyIndicator5(frame)
                else
                    BBP.CleanArenaIndicators(frame)
                end
                return
            end
        end
    end
    if BetterBlizzPlatesDB.arenaIndicatorTestMode then
        local unitType
        if UnitIsEnemy("player", frame.unit) or (UnitReaction(frame.unit, "player") or 0) < 5 then
            unitType = "arena"
        elseif not UnitIsUnit("player", frame.unit) then
            unitType = "party"
        end

        -- Test modes
        if unitType == "arena" then
            if db.arenaIndicatorModeOff or
               (not db.arenaIndicatorModeOne and
                not db.arenaIndicatorModeTwo and
                not db.arenaIndicatorModeThree and
                not db.arenaIndicatorModeFour and
                not db.arenaIndicatorModeFive) then
                BBP.TestArenaIndicator0(frame)
            elseif db.arenaIndicatorModeOne then
                BBP.TestArenaIndicator1(frame)
            elseif db.arenaIndicatorModeTwo then
                BBP.TestArenaIndicator2(frame)
            elseif db.arenaIndicatorModeThree then
                BBP.TestArenaIndicator3(frame)
            elseif db.arenaIndicatorModeFour then
                BBP.TestArenaIndicator4(frame)
            elseif db.arenaIndicatorModeFive then
                BBP.TestArenaIndicator5(frame)
            end
        elseif unitType == "party" then
            if db.partyIndicatorModeOff or
               (not db.partyIndicatorModeOne and
                not db.partyIndicatorModeTwo and
                not db.partyIndicatorModeThree and
                not db.partyIndicatorModeFour and
                not db.partyIndicatorModeFive) then
                BBP.TestPartyIndicator0(frame)
            elseif db.partyIndicatorModeOne then
                BBP.TestPartyIndicator1(frame)
            elseif db.partyIndicatorModeTwo then
                BBP.TestPartyIndicator2(frame)
            elseif db.partyIndicatorModeThree then
                BBP.TestPartyIndicator3(frame)
            elseif db.partyIndicatorModeFour then
                BBP.TestPartyIndicator4(frame)
            elseif db.partyIndicatorModeFive then
                BBP.TestPartyIndicator5(frame)
            end
        end
    end
end

-- Refresh nameplates between solo shuffle rounds (sometimes id and spec text stick)
local refresh = CreateFrame("Frame")
refresh:RegisterEvent("GROUP_ROSTER_UPDATE")
refresh:SetScript("OnEvent", function(self, event, ...)
    if not InCombatLockdown() and BBP.isInArena then
        buildPartyCache()
        refreshAllParty()
        BBP.RefreshAllNameplates()
    end
end)


function BBP.BattlegroundSpecNames(frame)
    -- if not BBP.isInBg then return end
    -- if not UnitIsEnemy(frame.unit, "player") or not UnitIsPlayer(frame.unit) then
    --     if frame.specNameText then
    --         frame.specNameText:SetText("")
    --     end
    --     return
    -- else

    --     local db = BetterBlizzPlatesDB
    --     local shortArenaSpecName = db.shortArenaSpecName
    --     local arenaSpecScale = db.arenaSpecScale
    --     local arenaSpecAnchor = db.arenaSpecAnchor
    --     local arenaSpecXPos = db.arenaSpecXPos
    --     local arenaSpecYPos = db.arenaSpecYPos

    --     local specID = BBP.GetSpecID(frame)
    --     local specName = specID and specIDToName[specID]

    --     if shortArenaSpecName and specID then
    --         specName = specIDToNameShort[specID]
    --     end
    --     local r, g, b, a = frame.name:GetTextColor()

    --     if not specName then
    --         specName = UnitName(frame.unit)
    --     end

    --     local anchorPoint = createSpexText(frame)

    --     frame.name:SetText("")
    --     frame.name:SetAlpha(0)
    --     frame.specNameText:SetText(specName)
    --     frame.specNameText:SetTextColor(r, g, b, 1)
    --     frame.specNameText:SetScale(arenaSpecScale)
    --     frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
    -- end
end