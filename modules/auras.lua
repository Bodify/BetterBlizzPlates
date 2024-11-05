----------------------------------------------------
---- Aura Function Copied From RSPlates and edited by me
----------------------------------------------------

local function FetchSpellName(spellId)
    local spellName, _, _ = BBP.TWWGetSpellInfo(spellId)
    return spellName
end

local fakeAuras = {
    -- 6 Fake Debuffs
    {
        auraInstanceID = 777,
        spellId = 201,
        icon = "interface/icons/spell_shadow_shadowwordpain",
        duration = 30,
        isHarmful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 778,
        spellId = 202,
        icon = "interface/icons/spell_shadow_curseofsargeras",
        duration = 18,
        isHarmful = true,
        applications = 18,
        dispelName = "Curse",
    },
    {
        auraInstanceID = 779,
        spellId = 203,
        icon = "interface/icons/spell_frost_frostnova",
        duration = 10,
        isHarmful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 780,
        spellId = 204,
        icon = 132092,
        duration = 22,
        applications = 1,
        isHarmful = true,
        dispelName = "Physical",
    },
    {
        auraInstanceID = 781,
        spellId = 205,
        icon = 135978,
        duration = 24,
        isHarmful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 782,
        spellId = 206,
        icon = "interface/icons/spell_shadow_plaguecloud",
        duration = 16,
        isHarmful = true,
        applications = 3,
        dispelName = "Disease",
    },
    -- 5 Fake Buffs
    {
        auraInstanceID = 666,
        spellId = 101,
        icon = "interface/icons/spell_nature_regeneration",
        duration = 20,
        isHelpful = true,
        applications = 1,
        isStealable = true,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 667,
        spellId = 102,
        icon = 132341,
        duration = 0,
        expirationTime = 0,
        isHelpful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 668,
        spellId = 103,
        icon = "interface/icons/spell_holy_flashheal",
        duration = 25,
        isHelpful = true,
        applications = 2,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 669,
        spellId = 104,
        icon = 132144,
        duration = 0,
        expirationTime = 0,
        isHelpful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 670,
        spellId = 105,
        icon = 135939,
        duration = 15,
        isHelpful = true,
        applications = 1,
        isStealable = true,
        dispelName = "Magic",
    },
}

local smokeIDs = {
    [212182] = true,
    [359053] = true,
}

local uas = {
    [342938] = true,
    [316099] = true,
}


local smokeTracker
BBP.ActiveSmokeCheck = CreateFrame("Frame")

local function AddSmokeTimer(frame)
    local unit = frame.unit
    if frame.BigDebuffs then
        if not frame.BigDebuffs.CooldownSB then
            local cooldownFrame = CreateFrame("Cooldown", nil, frame.BigDebuffs, "CooldownFrameTemplate")
            cooldownFrame:SetAllPoints(frame.BigDebuffs.icon)
            cooldownFrame:SetDrawEdge(false)
            cooldownFrame:SetDrawSwipe(true)
            cooldownFrame:SetReverse(true)
            frame.BigDebuffs.CooldownSB = cooldownFrame
        end
        frame.BigDebuffs.CooldownSB:SetCooldown(BBP.smokeBombCast, 5)
        frame.BigDebuffs.CooldownSB:SetScript("OnUpdate", function(self, elapsed)
            local texture = frame.BigDebuffs.icon:GetTexture()
            if texture ~= 458733 then
                self:SetCooldown(0, 0)
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
    if C_AddOns.IsAddOnLoaded("OmniAuras") then
        if unit and string.find(unit, "nameplate") then
            local nameplateUnit = unit:sub(1, 1):upper() .. unit:sub(2, 4):lower() .. unit:sub(5, 5):upper() .. unit:sub(6):lower()
            local oaFrame = _G[nameplateUnit.."Icon"]
            if oaFrame then
                if not oaFrame.CooldownSB then
                    local cooldownFrame = CreateFrame("Cooldown", nil, oaFrame:GetParent(), "CooldownFrameTemplate")
                    cooldownFrame:SetAllPoints(oaFrame)
                    cooldownFrame:SetDrawEdge(false)
                    cooldownFrame:SetDrawSwipe(true)
                    cooldownFrame:SetReverse(true)
                    oaFrame.CooldownSB = cooldownFrame
                end
                oaFrame.CooldownSB:SetCooldown(BBP.smokeBombCast, 5)
                oaFrame.CooldownSB:SetScript("OnUpdate", function(self, elapsed)
                    local texture = oaFrame:GetTexture()
                    if texture ~= 458733 then
                        self:SetCooldown(0, 0)
                        self:SetScript("OnUpdate", nil)
                    end
                end)
            end
        end
    end
end

function BBP.CheckNameplateForSmoke(unit, frame)
    if not unit then return end
    if not string.find(unit, "nameplate") then
        local np
        np, frame = BBP.GetSafeNameplate(unit)
        if not frame then return end
    end

    if frame and frame.unit then
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellID = BBP.TWWUnitAura(frame.unit, i, "HARMFUL")

            if spellID then
                if spellID == 212183 then
                    AddSmokeTimer(frame)
                    break
                end
            else
                break
            end
        end
    end
end

function BBP.CheckAllNameplatesForSmoke()
    for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        if frame and frame.unit then
            BBP.CheckNameplateForSmoke(frame.unit, frame)
        end
    end
end

BBP.ActiveSmokeCheck:SetScript("OnEvent", function(self, event, unit)
    BBP.CheckNameplateForSmoke(unit)
end)

local function SmokeBombCheck()
    local _, subEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if subEvent == "SPELL_CAST_SUCCESS" and smokeIDs[spellID] then
        if smokeTracker then
            smokeTracker:Cancel()
        end
        BBP.smokeBombCast = GetTime()

        if BBF and BBF.ActiveSmokeCheck then
            BBF.smokeBombCast = BBP.smokeBombCast
            BBF.ActiveSmokeCheck:RegisterUnitEvent("UNIT_AURA", "player")
        end
        BBP.ActiveSmokeCheck:RegisterEvent("UNIT_AURA")

        C_Timer.After(0.1, function()
            BBP.CheckAllNameplatesForSmoke()
            if BBF and BBF.CheckDebuffsForSmoke then
                BBF.CheckDebuffsForSmoke()
            end
        end)
        smokeTracker = C_Timer.NewTimer(5, function()
            BBP.smokeBombCast = 0
            if BBF then
                BBF.smokeBombCast =0
            end
            BBP.ActiveSmokeCheck:UnregisterAllEvents()
        end)
    end
end

local function isInWhitelist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            return true
        end
    end
    return false
end

local function isInBlacklist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraBlacklist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            return true
        end
    end
    return false
end

local function GetAuraDetails(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            local isImportant = entry.flags and entry.flags.important or false
            local isPandemic = entry.flags and entry.flags.pandemic or false
            local auraColor = entry.entryColors and entry.entryColors.text or nil
            local onlyMine = entry.flags and entry.flags.onlyMine or false
            local isEnlarged = entry.flags and entry.flags.enlarged or false
            local isCompacted = entry.flags and entry.flags.compacted or false
            return true, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted
        end
    end
    return false, false, false, false, false
end
local importantGlowOffset = 10 * (BetterBlizzPlatesDB.nameplateAuraEnlargedScale or 1)
local trackedBuffs = {};
local checkBuffsTimer = nil;

local function StopCheckBuffsTimer()
    if checkBuffsTimer then
        checkBuffsTimer:Cancel();
        checkBuffsTimer = nil;
    end
end

local pandemicSpells = {
    -- Death Knight
        -- Blood
        [55078] = 24,  -- Blood Plague
        -- Frost
        [55095] = 24,  -- Frost Fever
        -- Unholy
        [191587] = 21, -- Virulent Plague

    -- Demon Hunter
        -- Havoc
        [390181] = 6,  -- Soulscar

    -- Druid
        -- Feral
        [1079] = 8,   -- Rip
        [155722] = 15, -- Rake
        [106830] = 15, -- Thrash
        [155625] = 14, -- Moonfire
        -- Balance
        [164815] = 12, -- Sunfire
        [202347] = 24, -- Stellar Flare
        -- Resto
        [774] = 12,    -- Rejuvenation
        [33763] = 15,  -- Lifebloom
        [8936] = 6,    -- Regrowth

    -- Evoker
        -- Preservation
        [355941] = 8, -- Dream Breath
        -- Augmentation
        [395152] = 10, -- Ebon Might

    -- Hunter
        -- Survival
        [259491] = 12, -- Serpent Sting
        -- Marksman
        [271788] = 18, -- Serpent Sting (Aimed Shot)

    -- Monk
        -- Brewmaster
        [116847] = 6,  -- Rushing Jade Wind
        -- Mistweaver
        [119611] = 20, -- Renewing Mist
        [124682] = 6,  -- Enveloping Mist

    -- Priest
        [139] = 15,    -- Renew
        [589] = 16,    -- Shadow Word: Pain
        -- Discipline
        [204213] = 20, -- Purge the Wicked
        -- Shadow
        [34914] = 21,  -- Vampiric Touch
        [335467] = 6,  -- Devouring Plague

    -- Rogue
        [1943] = 8,   -- Rupture
        [315496] = 12, -- Slice and Dice
        -- Assassination
        [703] = 18,    -- Garrote
        [121411] = 6, -- Crimson Tempest

    -- Shaman
        [188389] = 18, -- Flame Shock
        -- Restoration
        [382024] = 12, -- Earthliving Weapon
        [61295] = 18,  -- Riptide

    -- Warlock
        [445474] = 16, -- Wither
        -- Destruction
        [157736] = 18, -- Immolate
        -- Demonology
        [460553] = 20, -- Doom
        -- Affliction
        [146739] = 14, -- Corruption
        [980] = 18,    -- Agony
        [316099] = 21, -- Unstable Affliction

    -- Warrior
        [388539] = 15, -- Rend
        -- Arms
        [262115] = 12, -- Deep Wounds
}


local nonPandemic = 5
local defaultPandemic = 0.3
local uaPandemic = 8
local agonyPandemic = 10

local function GetPandemicThresholds(buff)
    local minBaseDuration = pandemicSpells[buff.spellID] or buff.duration
    local baseDuration = math.max(buff.duration, minBaseDuration)  -- Ensure the duration doesn't go below the min base duration

    -- Specific pandemic logic for Agony with talent
    if buff.spellID == 980 and IsPlayerSpell(453034) then
        -- For Agony with talent, return special threshold
        return agonyPandemic, baseDuration * defaultPandemic
    elseif buff.spellID == 316099 and IsPlayerSpell(459376) then
        -- Unstable Affliction with talent
        return uaPandemic, baseDuration * defaultPandemic
    elseif pandemicSpells[buff.spellID] then
        -- Use 30% of the greater value (dynamic or minimum) for Pandemic spells
        return nil, baseDuration * defaultPandemic
    else
        -- Default non-pandemic (5 seconds)
        return nil, nonPandemic
    end
end

local function CheckBuffs()
    local currentGameTime = GetTime()

    for auraInstanceID, buff in pairs(trackedBuffs) do
        if buff.isPandemic and buff.expirationTime then
            local remainingDuration = buff.expirationTime - currentGameTime
            local specialPandemicThreshold, defaultPandemicThreshold = GetPandemicThresholds(buff)

            if remainingDuration <= 0 then
                -- Buff expired, remove it and hide the glow
                trackedBuffs[auraInstanceID] = nil
                if buff.PandemicGlow then
                    buff.PandemicGlow:Hide()
                end
                buff.isPandemicActive = false
            else
                -- Check for the default pandemic threshold (red)
                if remainingDuration <= defaultPandemicThreshold then
                    -- In the default threshold (red)
                    if not buff.PandemicGlow then
                        buff.PandemicGlow = buff.GlowFrame:CreateTexture(nil, "ARTWORK")
                        buff.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                        buff.PandemicGlow:SetDesaturated(true)
                    end
                    -- Set the glow to red
                    buff.PandemicGlow:SetVertexColor(1, 0, 0) -- Red color
                    buff.PandemicGlow:Show()

                    if buff.isEnlarged then
                        if BetterBlizzPlatesDB.nameplateAuraEnlargedSquare then
                            local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
                        else
                            if BetterBlizzPlatesDB.nameplateAuraSquare then
                                local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                            elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local eight = 8 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                            else
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local sevenfive = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                            end
                        end
                    elseif buff.isCompacted then
                        if BetterBlizzPlatesDB.nameplateAuraCompactedSquare then
                            local scale = BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            local fourfive = 4.5 * scale
                            local fivefive = 5.5 * scale
                            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -fourfive, fivefive)
                            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", fourfive, -fivefive)
                        else
                            if BetterBlizzPlatesDB.nameplateAuraSquare then
                                local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                            elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local eight = 8 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                            else
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local sevenfive = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                            end
                        end
                    elseif BetterBlizzPlatesDB.nameplateAuraSquare then
                        local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                    elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                        local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        local eight = 8 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                    else
                        local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        local sevenfive = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                    end

                    buff.isPandemicActive = true
                elseif specialPandemicThreshold and remainingDuration <= specialPandemicThreshold and remainingDuration > defaultPandemicThreshold then
                    -- In the special threshold (reddish-orange), but above the default threshold
                    if not buff.PandemicGlow then
                        buff.PandemicGlow = buff.GlowFrame:CreateTexture(nil, "ARTWORK")
                        buff.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                        buff.PandemicGlow:SetDesaturated(true)
                    end
                    -- Set the glow to reddish-orange
                    buff.PandemicGlow:SetVertexColor(1, 0.25, 0) -- Reddish-orange color
                    buff.PandemicGlow:Show()

                    if buff.isEnlarged then
                        if BetterBlizzPlatesDB.nameplateAuraEnlargedSquare then
                            local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
                        else
                            if BetterBlizzPlatesDB.nameplateAuraSquare then
                                local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                            elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local eight = 8 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                            else
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local sevenfive = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                            end
                        end
                    elseif buff.isCompacted then
                        if BetterBlizzPlatesDB.nameplateAuraCompactedSquare then
                            local scale = BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            local fourfive = 4.5 * scale
                            local fivefive = 5.5 * scale
                            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -fourfive, fivefive)
                            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", fourfive, -fivefive)
                        else
                            if BetterBlizzPlatesDB.nameplateAuraSquare then
                                local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                            elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local eight = 8 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                            else
                                local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                local sevenfive = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                            end
                        end
                    elseif BetterBlizzPlatesDB.nameplateAuraSquare then
                        local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                    elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                        local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        local eight = 8 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                    else
                        local tenfive = 10.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        local sevenfive = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                    end

                    buff.isPandemicActive = true
                else
                    -- Outside the pandemic window, hide the glow
                    if buff.PandemicGlow then
                        buff.PandemicGlow:Hide()
                    end
                    buff.isPandemicActive = false
                end
            end
        else
            buff.isPandemicActive = false
            trackedBuffs[auraInstanceID] = nil
        end
    end

    -- Stop the timer if no tracked buffs remain
    if next(trackedBuffs) == nil then
        StopCheckBuffsTimer()
    end
end

local function StartCheckBuffsTimer()
    if not checkBuffsTimer then
        checkBuffsTimer = C_Timer.NewTicker(0.1, CheckBuffs);
    end
end

function BBP.CustomBuffLayoutChildren(container, children, isEnemyUnit)
    -- Obtain the health bar details
    local healthBar = container:GetParent().healthBar
    local healthBarWidth = healthBar:GetWidth()
    -- if not container.GreenOverlay then
    --     local greenOverlay = container:CreateTexture("GreenOverlay", "OVERLAY")
    --     greenOverlay:SetColorTexture(0, 1, 0, 0.5)  -- RGBA: Solid green with 50% opacity
    --     greenOverlay:SetAllPoints(container)  -- Make the texture cover the entire container
    --     container.GreenOverlay = greenOverlay  -- Assign the texture to the container for future reference
    -- end
    -- Define the spacing and row parameters
    local horizontalSpacing = BetterBlizzPlatesDB.nameplateAuraWidthGap
    local verticalSpacing = -BetterBlizzPlatesDB.nameplateAuraHeightGap-- + (BetterBlizzPlatesDB.nameplateAuraSquare and 12 or 0) + (BetterBlizzPlatesDB.nameplateAuraTaller and 3 or 0)
    local maxBuffsPerRow = (isEnemyUnit and BetterBlizzPlatesDB.nameplateAuraRowAmount) or (not isEnemyUnit and BetterBlizzPlatesDB.nameplateAuraRowFriendlyAmount)
    local maxRowHeight = 0
    local rowWidths = {}
    local totalChildrenHeight = 0
    local maxBuffsPerRowAdjusted = maxBuffsPerRow
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller
    local auraHeightSetting = (nameplateAuraSquare and 20) or (nameplateAuraTaller and 15.5) or 14
    local square = BetterBlizzPlatesDB.nameplateAuraEnlargedSquare
    local compactSquare = BetterBlizzPlatesDB.nameplateAuraCompactedSquare
    local auraSize = square and 20 or auraHeightSetting
    local compactSize = compactSquare and 10 or 20
    local nameplateAuraEnlargedScale = BetterBlizzPlatesDB.nameplateAuraEnlargedScale
    local nameplateAuraCompactedScale = BetterBlizzPlatesDB.nameplateAuraCompactedScale
    local auraSizeScaled = auraSize * nameplateAuraEnlargedScale
    local sizeMultiplier = 20 * nameplateAuraEnlargedScale
    local texCoord = nameplateAuraSquare and {0.1, 0.9, 0.1, 0.9} or nameplateAuraTaller and {0.05, 0.95, 0.15, 0.82} or {0.05, 0.95, 0.1, 0.6}
    local compactTexCoord = not compactSquare and texCoord or nameplateAuraSquare and {0.25, 0.75, 0.05, 0.95} or nameplateAuraTaller and {0.3, 0.7, 0.15, 0.82} or {0.3, 0.7, 0.15, 0.80}
    local nameplateAuraScale = BetterBlizzPlatesDB.nameplateAuraScale
    local nameplateAuraCountScale = BetterBlizzPlatesDB.nameplateAuraCountScale
    local sortEnlargedAurasFirst = BetterBlizzPlatesDB.sortEnlargedAurasFirst
    local sortCompactedAurasFirst = BetterBlizzPlatesDB.sortCompactedAurasFirst

    local scaledCompactWidth = compactSize * nameplateAuraCompactedScale
    local scaledCompactHeight = auraHeightSetting * nameplateAuraCompactedScale

    local nameplateAuraBuffScale = BetterBlizzPlatesDB.nameplateAuraBuffScale
    local nameplateAuraDebuffScale = BetterBlizzPlatesDB.nameplateAuraDebuffScale
    local scaledBuffWidth = 20 * nameplateAuraBuffScale
    local scaledBuffHeight = auraHeightSetting * nameplateAuraBuffScale
    local scaledDebuffWidth = 20 * nameplateAuraDebuffScale
    local scaledDebuffHeight = auraHeightSetting * nameplateAuraDebuffScale

    local function defaultComparator(a, b)
        return a.auraInstanceID < b.auraInstanceID
    end

    local function largeSmallAuraComparator(a, b)
        if a.isEnlarged or b.isEnlarged then
            if a.isEnlarged and not b.isEnlarged then
                return true
            elseif not a.isEnlarged and b.isEnlarged then
                return false
            else
                return defaultComparator(a, b)
            end
        end

        if a.isCompacted or b.isCompacted then
            if a.isCompacted and not b.isCompacted then
                return false
            elseif not a.isCompacted and b.isCompacted then
                return true
            else
                return defaultComparator(a, b)
            end
        end

        return defaultComparator(a, b)
    end

    local function smallLargeAuraComparator(a, b)
        if a.isCompacted or b.isCompacted then
            if a.isCompacted and not b.isCompacted then
                return true
            elseif not a.isCompacted and b.isCompacted then
                return false
            else
                return defaultComparator(a, b)
            end
        end

        if a.isEnlarged or b.isEnlarged then
            if a.isEnlarged and not b.isEnlarged then
                return false
            elseif not a.isEnlarged and b.isEnlarged then
                return true
            else
                return defaultComparator(a, b)
            end
        end

        return defaultComparator(a, b)
    end


    -- Separate buffs and debuffs if needed
    local buffs = {}
    local debuffs = {}
    if BetterBlizzPlatesDB.separateAuraBuffRow then
        for _, buff in ipairs(children) do
            if buff.isBuff then
                table.insert(buffs, buff)
            else
                table.insert(debuffs, buff)
            end
        end
    else
        buffs = children  -- Treat all as buffs for the unified layout
        debuffs = {}  -- No debuffs in this mode
    end

    -- Calculate the width of each row
    local function CalculateRowWidths(auras)
        local widths = {}
        local compactTracker = 0
        for index, buff in ipairs(auras) do
            buff:SetScale(nameplateAuraScale)
            buff.CountFrame:SetScale(nameplateAuraCountScale)
            local buffWidth
            if buff.isEnlarged then
                buff:SetSize(sizeMultiplier, auraSizeScaled)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                if not square then
                    buff.Icon:SetTexCoord(unpack(texCoord))
                else
                    buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
                buffWidth = sizeMultiplier
                --buffHeight = sizeMultiplier
                compactTracker = 0
            elseif buff.isCompacted then
                buff:SetSize(scaledCompactWidth, scaledCompactHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(compactTexCoord))
                buffWidth = scaledCompactWidth
                --buffHeight = 14
                compactTracker = compactTracker + 1
            elseif buff.isBuff then
                buff:SetSize(scaledBuffWidth, scaledBuffHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(texCoord))
                buffWidth = scaledBuffWidth
                --buffHeight = 14
                compactTracker = 0
            else--debuff
                buff:SetSize(scaledDebuffWidth, scaledDebuffHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(texCoord))
                buffWidth = scaledDebuffWidth
                --buffHeight = 14
                compactTracker = 0
            end

            local extraOffset = 0
            if compactSquare and compactTracker == 2 and buff.isCompacted then
                extraOffset = horizontalSpacing
                maxBuffsPerRowAdjusted = maxBuffsPerRowAdjusted + 1
                compactTracker = 0
            end

            --if container.respectChildScale then
                local buffScale = buff:GetScale()
                buffWidth = buffWidth * buffScale
            --end

            local rowIndex = math.floor((index - 1) / maxBuffsPerRowAdjusted) + 1
            widths[rowIndex] = (widths[rowIndex] or 0) + buffWidth -extraOffset

            if index % maxBuffsPerRowAdjusted ~= 1 then
                widths[rowIndex] = widths[rowIndex] + horizontalSpacing
            end
        end
        return widths
    end

    -- Function to layout auras
    local function LayoutAuras(auras, startRow)
        local currentRow = startRow
        local horizontalOffset = 0
        local firstRowFirstAuraOffset = nil  -- Variable to store the horizontal offset of the first aura in the first row
        local nameplateAurasFriendlyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor and not isEnemyUnit
        local nameplateAurasEnemyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor and isEnemyUnit
        local nameplateCenterAllRows = BetterBlizzPlatesDB.nameplateCenterAllRows and (nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor)
        local xPos = BetterBlizzPlatesDB.nameplateAurasXPos
        local compactTracker = 0

        for index, buff in ipairs(auras) do
            local buffWidth, buffHeight = buff:GetSize()
            if buff.isEnlarged then
                compactTracker = 0
            elseif buff.isCompacted then
                compactTracker = compactTracker + 1
            else
                compactTracker = 0
            end

            local buffScale = buff:GetScale()

            -- Update the maximum row height
            maxRowHeight = math.max(maxRowHeight, buffHeight)

            -- Determine if it's the start of a new row
            if index % maxBuffsPerRowAdjusted == 1 then
                local rowIndex = math.floor((index - 1) / maxBuffsPerRowAdjusted) + 1
                if buff.isCompacted then
                    compactTracker = 1
                else
                    compactTracker = 0
                end

                if nameplateCenterAllRows then
                    horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                elseif nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
                    if rowIndex == 1 then
                        horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                        firstRowFirstAuraOffset = horizontalOffset  -- Save this offset for the first aura
                    else
                        horizontalOffset = firstRowFirstAuraOffset or 0  -- Use the saved offset for the first aura of subsequent rows
                    end
                else
                    horizontalOffset = 0  -- or any other default starting offset
                end

                if index > 1 then
                    currentRow = currentRow + 1  -- Move to the next row
                end
            end

            -- Position the buff on the nameplate
            buff:ClearAllPoints()
            local verticalOffset = -currentRow * (-maxRowHeight + (currentRow > 0 and verticalSpacing or 0))

            local extraOffset = 0
            if compactSquare and compactTracker == 2 and buff.isCompacted then
                extraOffset = BetterBlizzPlatesDB.nameplateAuraWidthGap
                compactTracker = 0
            end

            if nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) +(xPos+1-extraOffset/buffScale), verticalOffset - 13)
            else
                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + xPos-extraOffset/buffScale, verticalOffset - 13)
            end
            horizontalOffset = horizontalOffset + ((buffWidth)*buffScale) + horizontalSpacing-extraOffset
        end

        return currentRow
    end

    -- Layout logic
    local lastRow = 0
    if BetterBlizzPlatesDB.separateAuraBuffRow then
        if #debuffs > 0 then
            if sortEnlargedAurasFirst then
                table.sort(debuffs, largeSmallAuraComparator)
            end
            if sortCompactedAurasFirst then
                table.sort(debuffs, smallLargeAuraComparator)
            end
            rowWidths = CalculateRowWidths(debuffs)
            lastRow = LayoutAuras(debuffs, 0)
        end

        if sortEnlargedAurasFirst then
            table.sort(buffs, largeSmallAuraComparator)
        end
        if sortCompactedAurasFirst then
            table.sort(buffs, smallLargeAuraComparator)
        end
        rowWidths = CalculateRowWidths(buffs)
        LayoutAuras(buffs, lastRow + (#debuffs > 0 and 1 or 0))
    else
        if sortEnlargedAurasFirst then
            table.sort(buffs, largeSmallAuraComparator)
        end
        if sortCompactedAurasFirst then
            table.sort(buffs, smallLargeAuraComparator)
        end
        rowWidths = CalculateRowWidths(buffs)
        lastRow = LayoutAuras(buffs, 0)
    end

    -- Calculate total children height
    totalChildrenHeight = (lastRow + 1) * (maxRowHeight + verticalSpacing)

    return totalChildrenWidth, totalChildrenHeight, hasExpandableChild
end

local cachedDebuffColors
function BBP.UpdateAuraTypeColors()
    local db = BetterBlizzPlatesDB
    cachedDebuffColors = {
        Magic = db.npAuraMagicRGB,
        Poison = db.npAuraPoisonRGB,
        Curse = db.npAuraCurseRGB,
        Disease = db.npAuraDiseaseRGB,
    }
end

local function SetAuraBorderColorByType(buff, aura, db)
    if not db.npColorAuraBorder then return end

    local debuffColors = cachedDebuffColors

    if aura.isHelpful then
        buff.Border:SetColorTexture(unpack(db.npAuraBuffsRGB))
    else
        local color = debuffColors[aura.dispelName] or db.npAuraOtherRGB
        buff.Border:SetColorTexture(unpack(color))
    end
end

local function SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)
    local otherNpBuffPurgeGlow = BetterBlizzPlatesDB.otherNpBuffPurgeGlow
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if otherNpBuffPurgeGlow then
        if not isPlayerUnit and isEnemyUnit then
            local alwaysShowPurgeTexture = BetterBlizzPlatesDB.alwaysShowPurgeTexture
            if aura.isHelpful and aura.isStealable or (alwaysShowPurgeTexture and aura.dispelName == "Magic" and aura.isHelpful) then
                buff.Icon:SetScale(0.5)
                if not buff.buffBorderPurge then
                    buff.buffBorderPurge = buff.GlowFrame:CreateTexture(nil, "ARTWORK")
                    buff.buffBorderPurge:SetAtlas("newplayertutorial-drag-slotblue")
                end
                if buff.isEnlarged then
                    importantGlowOffset = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -importantGlowOffset, importantGlowOffset)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", importantGlowOffset, -importantGlowOffset)
                elseif buff.isCompacted then
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -4.5, 6)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 4.5, -6)
                elseif nameplateAuraSquare then
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10)
                elseif nameplateAuraTaller then
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6.5)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6.5)
                else
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6)
                end
                buff.buffBorderPurge:Show()
                buff.Border:Hide()
            else
                if buff.buffBorderPurge then
                    buff.buffBorderPurge:Hide()
                    buff.Border:Show()
                end
            end
        else
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
                buff.Border:Show()
            end
        end
    else
        buff.Icon:SetScale(1)
        if buff.buffBorderPurge then
            buff.buffBorderPurge:Hide()
            buff.Border:Show()
        end
    end
end


local function SetPandemicGlow(buff, aura, isPandemic)
    if aura.duration and buff and aura.expirationTime and isPandemic then
        buff.isPandemic = true
        buff.expirationTime = aura.expirationTime;
        trackedBuffs[aura.auraInstanceID] = buff;
        StartCheckBuffsTimer();
    else
        if buff.PandemicGlow then
            buff.PandemicGlow:Hide()
        end
        buff.isPandemic = false
    end
end

local function SetImportantGlow(buff, isPlayerUnit, isImportant, auraColor)
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if isImportant then
        buff.Icon:SetScale(0.5)
        if not isPlayerUnit then
            if not buff.ImportantGlow then
                buff.ImportantGlow = buff.GlowFrame:CreateTexture(nil, "ARTWORK")
                buff.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                buff.ImportantGlow:SetDesaturated(true)
            end
            if buff.isEnlarged then
                importantGlowOffset = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -importantGlowOffset, importantGlowOffset)
                buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", importantGlowOffset, -importantGlowOffset)
            elseif buff.isCompacted then
                buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -4.5, 6)
                buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 4.5, -6)
            elseif nameplateAuraSquare then
                buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10)
                buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10)
            elseif nameplateAuraTaller then
                buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7.5)
                buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7.5)
            else
                buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -9, 6)
                buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 9, -6)
            end
            -- If extra glow for purge
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
            if auraColor then
                buff.ImportantGlow:SetVertexColor(auraColor.r, auraColor.g, auraColor.b, auraColor.a)
            else
                buff.ImportantGlow:SetVertexColor(0, 1, 0)
            end
            buff.ImportantGlow:Show()
            buff.Border:Hide()
        else
            if buff.ImportantGlow then
                buff.ImportantGlow:Hide()
                buff.Border:Show()
            end
        end
    else
        buff.Icon:SetScale(1)
        if buff.ImportantGlow then
            buff.ImportantGlow:Hide()
            buff.Border:Show()
        end
    end
end

local function ShouldShowBuff(unit, aura, BlizzardShouldShow, filterAllOverride)
    if not aura then return false end
    local spellName = aura.name
    local spellId = aura.spellId
    local duration = aura.duration
    local expirationTime = aura.expirationTime
    local caster = aura.sourceUnit
    local isPurgeable = aura.isStealable or (aura.dispelName == "Magic" and aura.isHelpful)
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
    local castByPlayer = (caster == "player" or caster == "pet")
    local moreThanOneMin = (duration > 60 or duration == 0 or expirationTime == 0)
    local lessThanOneMin = duration < 61 or duration == 0 or expirationTime == 0

    -- PLAYER
    if UnitIsUnit(unit, "player") then
        -- Buffs
        if BetterBlizzPlatesDB["personalNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = BetterBlizzPlatesDB["personalNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return false end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = BetterBlizzPlatesDB["personalNpBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["personalNpBuffFilterLessMinite"]
            local filterOnlyMe = BetterBlizzPlatesDB["personalNpBuffFilterOnlyMe"]
            local filterBlizzard = BetterBlizzPlatesDB["personalNpBuffFilterBlizzard"]
            local anyFilter = filterBlizzard or filterLessMinite or filterOnlyMe

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- Filter to show only Blizzard recommended auras
                if not BlizzardShouldShow and filterBlizzard then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterOnlyMe then return true end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["personalNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = BetterBlizzPlatesDB["personalNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = BetterBlizzPlatesDB["personalNpdeBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["personalNpdeBuffFilterLessMinite"]
            local anyFilter = filterLessMinite

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end
            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then if not auraWhitelisted then return false end end
                return true
            end
        end

    -- FRIENDLY
    elseif isFriend then
        -- Buffs
        if BetterBlizzPlatesDB["friendlyNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = BetterBlizzPlatesDB["friendlyNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = BetterBlizzPlatesDB["friendlyNpBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpBuffFilterLessMinite"]
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpBuffFilterOnlyMe"]
            local anyFilter = filterLessMinite or filterOnlyMe

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["friendlyNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = BetterBlizzPlatesDB["friendlyNpdeBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterBlizzard = BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlizzard"]
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpdeBuffFilterLessMinite"]
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpdeBuffFilterOnlyMe"]
            local anyFilter = filterBlizzard or filterLessMinite or filterOnlyMe

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- Filter to show only Blizzard recommended auras
                if not BlizzardShouldShow and filterBlizzard then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterOnlyMe then return true end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
    -- ENEMY
    else
        -- Buffs
        if BetterBlizzPlatesDB["otherNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = BetterBlizzPlatesDB["otherNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = BetterBlizzPlatesDB["otherNpBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["otherNpBuffFilterLessMinite"]
            local filterPurgeable = BetterBlizzPlatesDB["otherNpBuffFilterPurgeable"]
            local anyFilter = filterLessMinite or filterPurgeable

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if filterPurgeable and not isPurgeable then return false end
                if moreThanOneMin and filterLessMinite then return false end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["otherNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = BetterBlizzPlatesDB["otherNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = BetterBlizzPlatesDB["otherNpdeBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterBlizzard = BetterBlizzPlatesDB["otherNpdeBuffFilterBlizzard"]
            local filterLessMinite = BetterBlizzPlatesDB["otherNpdeBuffFilterLessMinite"]
            local filterOnlyMe = BetterBlizzPlatesDB["otherNpdeBuffFilterOnlyMe"]
            local anyFilter = filterBlizzard or filterLessMinite or filterOnlyMe

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- Filter to show only Blizzard recommended auras
                if not BlizzardShouldShow and filterBlizzard then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterOnlyMe then return true end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
    end
end

function BBP.OnUnitAuraUpdate(self, unit, unitAuraUpdateInfo)
    local filter;
    local showAll = false;

    local isPlayer = UnitIsUnit("player", unit);
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
    isEnemy = isEnemy or isNeutral
    local showDebuffsOnFriendly = self.showDebuffsOnFriendly;

    local auraSettings =
    {
        helpful = false;
        harmful = false;
        raid = false;
        includeNameplateOnly = false;
        showAll = false;
        hideAll = false;
    };

    if isPlayer then
        auraSettings.helpful = true;
        auraSettings.includeNameplateOnly = true;
        auraSettings.showPersonalCooldowns = self.showPersonalCooldowns;
    else
        if isEnemy then
            auraSettings.harmful = true;
            auraSettings.includeNameplateOnly = true;
        else
            if (showDebuffsOnFriendly) then
                -- dispellable debuffs
                auraSettings.harmful = true;
                auraSettings.raid = true;
                auraSettings.showAll = true;
            else
                auraSettings.hideAll = false; -- changed to false (would sometimes hide buffs on friendly targets if buff setting was on, TODO figure out more)
            end
        end
    end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
    if (nameplate) then
        BBP.UpdateBuffs(nameplate.UnitFrame.BuffFrame, nameplate.namePlateUnitToken, unitAuraUpdateInfo, auraSettings, nameplate.UnitFrame);
    end
end

function BBP.UpdateBuffs(self, unit, unitAuraUpdateInfo, auraSettings, UnitFrame)
    local filters = {};
    if auraSettings.helpful then
        table.insert(filters, AuraUtil.AuraFilters.Helpful);
    end
    if auraSettings.harmful then
        table.insert(filters, AuraUtil.AuraFilters.Harmful);
    end
    if auraSettings.raid then
        table.insert(filters, AuraUtil.AuraFilters.Raid);
    end
    if auraSettings.includeNameplateOnly then
        table.insert(filters, AuraUtil.AuraFilters.IncludeNameplateOnly);
    end
    local filterString = AuraUtil.CreateFilterString(unpack(filters));

    local previousFilter = self.filter;
    local previousUnit = self.unit;
    self.unit = unit;
    self.filter = filterString;
    self.showFriendlyBuffs = auraSettings.showFriendlyBuffs;

    local aurasChanged = false;
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filterString ~= previousFilter then
        BBP.ParseAllAuras(self, auraSettings.showAll, UnitFrame);
        aurasChanged = true;
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                local BlizzardShouldShow = self:ShouldShowBuff(aura, auraSettings.showAll) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, filterString)
                if ShouldShowBuff(unit, aura, BlizzardShouldShow) then
                    self.auras[aura.auraInstanceID] = aura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
                    self.auras[auraInstanceID] = newAura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    self.auras[auraInstanceID] = nil;
                    aurasChanged = true;
                end
            end
        end
    end

    self:UpdateAnchor();

    if not aurasChanged then
        return;
    end

    self.buffPool:ReleaseAll();

    --if auraSettings.hideAll or not self.isActive then
    if not self.isActive then
        return;
    end

    local db = BetterBlizzPlatesDB
    local buffIndex = 1;
    local BBPMaxAuraNum = db.maxAurasOnNameplate
    local isPlayerUnit = UnitIsUnit("player", self.unit)
    local isEnemyUnit, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
    isEnemyUnit = isEnemyUnit or isNeutral
    self.isEnemyUnit = isEnemyUnit
    local shouldShowAura, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted
    local onlyPandemicMine = db.onlyPandemicAuraMine
    local showDefaultCooldownNumbersOnNpAuras = db.showDefaultCooldownNumbersOnNpAuras
    local hideNpAuraSwipe = db.hideNpAuraSwipe

    self.auras:Iterate(function(auraInstanceID, aura)
        if buffIndex > BBPMaxAuraNum then return true end
        local buff = self.buffPool:Acquire();
        buff.auraInstanceID = auraInstanceID;
        buff.isBuff = aura.isHelpful;
        buff.layoutIndex = buffIndex;
        buff.spellID = aura.spellId;
        buff.duration = aura.duration;

        buff.Icon:SetTexture(aura.icon);

        local spellName = FetchSpellName(aura.spellId)
        local spellId = aura.spellId
        local caster = aura.sourceUnit
        local castByPlayer = (caster == "player" or caster == "pet")

        shouldShowAura, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted = GetAuraDetails(spellName, spellId)
        if onlyPandemicMine and not castByPlayer then
            isPandemic = false
        end

        if buff.Cooldown._occ_display then
            buff.Cooldown._occ_display:SetFrameStrata("HIGH")
        end

        if isEnlarged then
            buff.isEnlarged = true
        else
            buff.isEnlarged = false
        end

        if isCompacted then
            buff.isCompacted = true
        else
            buff.isCompacted = false
        end

        if not buff.GlowFrame then
            buff.CountFrame:SetFrameStrata("DIALOG")
            buff.GlowFrame = CreateFrame("Frame", nil, buff)
            buff.GlowFrame:SetFrameStrata("MEDIUM")
            buff.GlowFrame:SetFrameLevel(1000)
        end

        if aura.spellId == 212183 then
            if not buff.CooldownSB then
                local cooldownFrame = CreateFrame("Cooldown", nil, buff, "CooldownFrameTemplate")
                cooldownFrame:SetAllPoints(buff.Icon)
                cooldownFrame:SetDrawEdge(false)
                cooldownFrame:SetDrawSwipe(true)
                cooldownFrame:SetReverse(true)
                buff.CooldownSB = cooldownFrame
            end
            buff.CooldownSB:Show()
            buff.CooldownSB:SetCooldown(BBP.smokeBombCast or 0, 5)
        elseif buff.CooldownSB then
            buff.CooldownSB:Hide()
        end

        SetAuraBorderColorByType(buff, aura, db)

        -- Pandemic Glow
        SetPandemicGlow(buff, aura, isPandemic)

        SetImportantGlow(buff, isPlayerUnit, isImportant, auraColor)

        -- Purge Glow
        SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)

        if isPlayerUnit then
            if buff.Border then
                buff.Border:Show()
            end
            if buff.buffBorder then
                buff.buffBorder:Hide()
            end
            if buff.BorderEmphasis then
                buff.BorderEmphasis:Hide()
            end
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
        end

        if (aura.applications > 1) then
            buff.CountFrame.Count:SetText(aura.applications);
            buff.CountFrame.Count:Show();
        else
            buff.CountFrame.Count:Hide();
        end
        CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);

        if hideNpAuraSwipe then
            if buff.Cooldown then
                buff.Cooldown:SetDrawSwipe(false)
                buff.Cooldown:SetDrawEdge(false)
            end
        end

        if showDefaultCooldownNumbersOnNpAuras then
            if buff.Cooldown then
                buff.Cooldown:SetHideCountdownNumbers(false)
                local cdText = buff.Cooldown and buff.Cooldown:GetRegions()
                if cdText then
                    cdText:SetScale(BetterBlizzPlatesDB.defaultNpAuraCdSize)
                end
            end
        end

        buff:Show();
        buff:SetMouseClickEnabled(false)

        buffIndex = buffIndex + 1;
        return buffIndex >= BUFF_MAX_DISPLAY;
    end);
    self:Layout();
end

function BBP.ParseAllAuras(self, forceAll, UnitFrame)
    if self.auras == nil then
        self.auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
    else
        self.auras:Clear();
    end

    local function HandleAura(aura, isTestModeEnabled)
        local BlizzardShouldShow = self:ShouldShowBuff(aura, forceAll)
        local shouldShowAura, isImportant, isPandemic = ShouldShowBuff(self.unit, aura, BlizzardShouldShow, isTestModeEnabled)
        if shouldShowAura then
            self.auras[aura.auraInstanceID] = aura;
        end

        return false;
    end

    local batchCount = nil;
    local usePackedAura = true;
    AuraUtil.ForEachAura(self.unit, "HARMFUL", batchCount, HandleAura, usePackedAura);
    if UnitIsUnit(self.unit, "player") then
        AuraUtil.ForEachAura(self.unit, "HELPFUL|INCLUDE_NAME_PLATE_ONLY", batchCount, HandleAura, usePackedAura);
    else
        AuraUtil.ForEachAura(self.unit, "HELPFUL", batchCount, HandleAura, usePackedAura);
    end

    -- Injecting fake auras for testing
    local isTestModeEnabled = BetterBlizzPlatesDB.nameplateAuraTestMode
    if isTestModeEnabled then
        local currentTime = GetTime()
        for _, fakeAura in ipairs(fakeAuras) do
            fakeAura.expirationTime = currentTime + fakeAura.duration
            HandleAura(fakeAura, isTestModeEnabled)
        end
    end
end

-- Table of classes and their specs that have a nameplate resource
local specsForResource = {
    [62] = true,  -- Arcane Mage
    [259] = true, -- Assassination Rogue
    [260] = true, -- Outlaw Rogue
    [261] = true, -- Subtlety Rogue
    [250] = true, -- Blood DK
    [251] = true, -- Frost DK
    [252] = true, -- Unholy DK
    --[102] = true, -- Balance Druid (has combopoints but not used)
    [105] = true, -- Resto Druid (doubtful but potentially)
    [104] = true, -- Guardian Druid
    [103] = true, -- Feral Druid
    [1467] = true, -- Devoker
    [1468] = true, -- Prevoker
    [269] = true, -- Windwalker Monk
    [65] = true, -- Holy Pala
    [66] = true, -- Prot Pala
    [70] = true, -- Ret Pala
    [265] = true, -- Aff Lock
    [266] = true, -- Demo Lock
    [267] = true, -- Destro Lock
}
-- Function to check if the current player's class spec has a nameplate resource
function BBP.PlayerSpecHasResource()
    local specID, _, _, _, _, _, _ = GetSpecializationInfo(GetSpecialization())
    return specsForResource[specID] or false
end

function BBP:UpdateAnchor()
    local frame = self:GetParent()

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    local isTarget = frame.unit and UnitIsUnit(frame.unit, "target")
    local reaction = frame.unit and UnitReaction(frame.unit, "player")
    local isFriend = reaction and reaction >= 5

    local shouldNotOffset = config.nameplateResourceDoNotRaiseAuras or config.nameplateResourceUnderCastbar or not BBP.PlayerSpecHasResource()
    local targetYOffset = self:GetBaseYOffset() + (isTarget and not shouldNotOffset and self:GetTargetYOffset() or 0.0)

    if not config.buffAnchorInitalized or BBP.needsUpdate then
        config.friendlyNameplateNonstackable = BetterBlizzPlatesDB.friendlyNameplateNonstackable
        config.nameplateAurasYPos = BetterBlizzPlatesDB.nameplateAurasYPos
        config.nameplateAurasNoNameYPos = BetterBlizzPlatesDB.nameplateAurasNoNameYPos
        config.nameplateAuraScale = BetterBlizzPlatesDB.nameplateAuraScale

        config.buffAnchorInitalized = true
    end

    if frame.unit and ShouldShowName(frame) then
        if config.friendlyNameplateNonstackable and isFriend then
            self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 24.5 + targetYOffset + config.nameplateAurasYPos + 63)
        else
            self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 24.5 + targetYOffset + config.nameplateAurasYPos)
        end
    else
        local additionalYOffset = 15 * (config.nameplateAuraScale - 1)
        self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4 + targetYOffset + config.nameplateAurasNoNameYPos + 1 + additionalYOffset)
    end
end

function BBP.RefreshBuffFrame()
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
		local unitFrame = namePlate.UnitFrame
		unitFrame.BuffFrame:UpdateAnchor()
		if unitFrame.unit then
			local self = unitFrame.BuffFrame
            BBP.UpdateBuffs(self, unitFrame.unit, nil, {}, unitFrame)
        end
	end
end

function BBP.HideNameplateAuraTooltip()
    if BetterBlizzPlatesDB.hideNameplateAuraTooltip and not BBP.hookedNameplateAuraTooltip then
        hooksecurefunc(NameplateBuffButtonTemplateMixin, "OnEnter", function(self)
            if self:IsForbidden() then return end
            self:EnableMouse(false)
        end)
        BBP.hookedNameplateAuraTooltip = true
    end
end

function BBP.SmokeCheckBootup()
    if not BBP.smokeBombDetector and not (BBF and BBF.smokeBombDetector) then
        BBP.smokeBombDetector = CreateFrame("Frame")
        BBP.smokeBombDetector:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        BBP.smokeBombDetector:SetScript("OnEvent", SmokeBombCheck)
    end
end