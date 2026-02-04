if not BBP.isMidnight then return end
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

-- cache arena -> nameplate frame
BBP.ArenaPlates = {} -- [1..3] = plate frame or nil
-- cache nameplate -> arena index (for non-120000 patches)
BBP.NameplateToArenaIndex = {} -- [nameplate] = 1/2/3 or nil
BBP.ArenaIndexToClass = {} -- [1..3] = "WARRIOR", "MAGE", etc.
BBP.ArenaIndexToSpec = {} -- [1..3] = specID
local patchVersion = select(4, GetBuildInfo())
local isPrepatch = patchVersion == 120000

-- Horrendous temporary llm abomination to work around blizzard removing getting nameplate of arena units.
function BBP.RefreshArenaPlates(shouldWipe)
    if isPrepatch then
        wipe(BBP.ArenaPlates)
        for i = 1, 3 do
            local plate = C_NamePlate.GetNamePlateForUnit("arena"..i)
            BBP.ArenaPlates[i] = plate
            -- Tag the frame with its arena ID for optimization
            if plate and plate.UnitFrame then
                plate.UnitFrame.arenaID = i
            end
        end
    else
        if shouldWipe then
            wipe(BBP.NameplateToArenaIndex)
            wipe(BBP.ArenaIndexToClass)
            wipe(BBP.ArenaIndexToSpec)
        end

        local nameplates = C_NamePlate.GetNamePlates()
        local foundArenas = {}
        local allPlayerPlates = {}
        local plateToClass = {}
        local plateToSpec = {}

        local alreadyTaggedCount = 0
        for _, plate in ipairs(nameplates) do
            if plate.UnitFrame and plate.UnitFrame.arenaID then
                local unit = plate.UnitFrame.unit
                if UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
                    -- Validate the tag still matches the cache
                    local cachedIndex = BBP.NameplateToArenaIndex[plate]
                    if cachedIndex == plate.UnitFrame.arenaID then
                        alreadyTaggedCount = alreadyTaggedCount + 1
                        foundArenas[plate.UnitFrame.arenaID] = plate
                    else
                        -- Stale tag, clear it
                        plate.UnitFrame.arenaID = nil
                    end
                else
                    -- Not an enemy player anymore, clear the tag
                    plate.UnitFrame.arenaID = nil
                end
            end
        end

        if alreadyTaggedCount == 3 and foundArenas[1] and foundArenas[2] and foundArenas[3] then
            return
        end

        for _, plate in ipairs(nameplates) do
            if plate.UnitFrame then
                local unit = plate.UnitFrame.unit
                if UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
                    table.insert(allPlayerPlates, plate)
                    local _, class = UnitClass(unit)
                    plateToClass[plate] = class

                    local cachedIndex = BBP.NameplateToArenaIndex[plate]
                    if cachedIndex then
                        local cachedClass = BBP.ArenaIndexToClass[cachedIndex]
                        local cachedSpec = BBP.ArenaIndexToSpec[cachedIndex]

                        if cachedClass and cachedClass ~= class then
                            BBP.NameplateToArenaIndex[plate] = nil
                            if plate.UnitFrame then
                                plate.UnitFrame.arenaID = nil
                            end
                            cachedIndex = nil
                        elseif cachedSpec then
                            local currentSpec = GetArenaOpponentSpec(cachedIndex)
                            if currentSpec and currentSpec ~= cachedSpec then
                                BBP.NameplateToArenaIndex[plate] = nil
                                if plate.UnitFrame then
                                    plate.UnitFrame.arenaID = nil
                                end
                                cachedIndex = nil
                            end
                        end
                    end

                    for i = 1, 3 do
                        local arenaUnit = "arena" .. i
                        if (UnitIsUnit(unit, "target") and UnitIsUnit("target", arenaUnit)) or
                           (UnitIsUnit(unit, "focus") and UnitIsUnit("focus", arenaUnit)) or
                           (UnitIsUnit(unit, "mouseover") and UnitIsUnit("mouseover", arenaUnit)) then
                            BBP.NameplateToArenaIndex[plate] = i
                            BBP.ArenaIndexToClass[i] = class

                            local specID = GetArenaOpponentSpec(i)
                            if specID then
                                BBP.ArenaIndexToSpec[i] = specID
                                plateToSpec[plate] = specID
                            end

                            if plate.UnitFrame then
                                plate.UnitFrame.arenaID = i
                            end

                            foundArenas[i] = plate
                        end
                    end
                else
                    if BBP.NameplateToArenaIndex[plate] then
                        BBP.NameplateToArenaIndex[plate] = nil
                    end
                    if plate.UnitFrame and plate.UnitFrame.arenaID then
                        plate.UnitFrame.arenaID = nil
                    end
                end
            end
        end

        for _, plate in ipairs(allPlayerPlates) do
            if not plateToSpec[plate] then
                local cachedIndex = BBP.NameplateToArenaIndex[plate]
                if cachedIndex and BBP.ArenaIndexToSpec[cachedIndex] then
                    plateToSpec[plate] = BBP.ArenaIndexToSpec[cachedIndex]
                end
            end
        end

        if #allPlayerPlates == 3 then
            for _, plate in ipairs(allPlayerPlates) do
                if not BBP.NameplateToArenaIndex[plate] then
                    local class = plateToClass[plate]
                    if class then
                        for i = 1, 3 do
                            if BBP.ArenaIndexToClass[i] == class and not foundArenas[i] then
                                local cachedSpec = BBP.ArenaIndexToSpec[i]
                                local plateSpec = plateToSpec[plate]

                                if cachedSpec and plateSpec then
                                    if cachedSpec == plateSpec then
                                        BBP.NameplateToArenaIndex[plate] = i
                                        if plate.UnitFrame then
                                            plate.UnitFrame.arenaID = i
                                        end
                                        foundArenas[i] = plate
                                        break
                                    end
                                else
                                    local classCount = 0
                                    for _, p in ipairs(allPlayerPlates) do
                                        if plateToClass[p] == class and not BBP.NameplateToArenaIndex[p] then
                                            classCount = classCount + 1
                                        end
                                    end
                                    if classCount == 1 then
                                        BBP.NameplateToArenaIndex[plate] = i
                                        if plate.UnitFrame then
                                            plate.UnitFrame.arenaID = i
                                        end
                                        foundArenas[i] = plate
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local foundCount = 0
        local missingIndex = nil
        for i = 1, 3 do
            if foundArenas[i] then
                foundCount = foundCount + 1
            else
                missingIndex = i
            end
        end

        if foundCount == 2 and missingIndex and #allPlayerPlates == 3 then
            for _, plate in ipairs(allPlayerPlates) do
                local isAlreadyFound = false
                for _, foundPlate in pairs(foundArenas) do
                    if foundPlate == plate then
                        isAlreadyFound = true
                        break
                    end
                end
                if not isAlreadyFound then
                    BBP.NameplateToArenaIndex[plate] = missingIndex
                    BBP.ArenaIndexToClass[missingIndex] = plateToClass[plate]
                    local specID = GetArenaOpponentSpec(missingIndex)
                    if specID then
                        BBP.ArenaIndexToSpec[missingIndex] = specID
                    end
                    if plate.UnitFrame then
                        plate.UnitFrame.arenaID = missingIndex
                    end
                    break
                end
            end
        end
    end
end

BBP.PartyPlates = {}
function BBP.RefreshPartyPlates()
    wipe(BBP.PartyPlates)
    for i = 1, 2 do
        BBP.PartyPlates[i] = C_NamePlate.GetNamePlateForUnit("party"..i)
    end
end


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ARENA_OPPONENT_UPDATE")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
if not isPrepatch then
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("PLAYER_FOCUS_CHANGED")
    f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
end
f:SetScript("OnEvent", function(_, e)
    if not BBP.isInArena then return end
    local shouldWipe = (e == "PLAYER_ENTERING_WORLD" or e == "ARENA_OPPONENT_UPDATE")
    BBP.RefreshArenaPlates(shouldWipe)
    BBP.RefreshPartyPlates()
end)

function BBP.GetArenaIndexByFrame(frame)
    if not frame.unit then return nil end

    if frame.arenaID then
        return frame.arenaID
    end

    if isPrepatch then
        local plate = BBP.GetSafeNameplate(frame.unit)
        if not plate then return nil end
        for i = 1, 3 do
            local ap = BBP.ArenaPlates[i]
            if ap and ap == plate then
                return i
            end
        end
        return nil
    else
        local plate = BBP.GetSafeNameplate(frame.unit)
        if not plate then return nil end
        return BBP.NameplateToArenaIndex[plate]
    end
end

function BBP.GetPartyIndexByFrame(frame)
    local plate = BBP.GetSafeNameplate(frame.unit)
    if not plate then return nil end
    for i = 1, 2 do
        local ap = BBP.PartyPlates[i]
        if ap and ap == plate then
            return i
        end
    end
    return nil
end

local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local UnitIsUnit = UnitIsUnit
local GetArenaOpponentSpec = GetArenaOpponentSpec

local function isFistweaver(unit)
    if true then return end
    if BBP.fistweaverFound then return true end
    local isFistweaver = AuraUtil.FindAuraByName("Ancient Teachings", unit, "HELPFUL")
    if isFistweaver then
        BBP.fistweaverFound = true
        return true
    end
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
    frame.arenaNumberText:SetScale(arenaIDScale)

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
    frame.arenaNumberText:SetScale(arenaIDScale)
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

    if specID == 270 then
        if isFistweaver("arena"..idx) then
            frame.specNameText:SetText("Fistweaver")
        end
    end

    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetScale(arenaSpecScale)
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
    if specID == 270 and isFistweaver("arena"..idx) then
        frame.specNameText:SetText("Fistweaver")
    end
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetScale(arenaSpecScale)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)

    frame.arenaNumberText:SetText(idx)
    if enemyClassColorName then
        frame.arenaNumberText:SetTextColor(r, g, b, 1)
    else
        frame.arenaNumberText:SetTextColor(1, 1, 0)
    end
    frame.arenaNumberText:SetScale(arenaIDScale)
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

    frame.name:SetText("")
    frame.name:SetAlpha(0)
    frame.specNameText:SetText(specName .. " " .. idx)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetScale(arenaSpecScale)
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

    local r, g, b = frame.name:GetTextColor()

    createIDText(frame)

    frame.name:SetText("")
    frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, arenaIdAnchor, arenaIdXPos, arenaIdYPos)
    frame.arenaNumberText:SetText(idx)
    frame.arenaNumberText:SetTextColor(r, g, b, 1)
    frame.arenaNumberText:SetScale(partyIDScale)
end


-- Mode 2: Put ID on top of name
function BBP.PartyIndicator2(frame)
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos   = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos   = BetterBlizzPlatesDB.arenaIdYPos
    local partyIDScale  = BetterBlizzPlatesDB.partyIDScale

    local idx = BBP.GetPartyIndexByFrame(frame)
    if not idx then return end

    local r, g, b = frame.name:GetTextColor()

    createIDText(frame)

    frame.arenaNumberText:SetText(idx)
    frame.arenaNumberText:SetTextColor(r, g, b, 1)
    frame.arenaNumberText:SetScale(partyIDScale)
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
    frame.specNameText:SetScale(partySpecScale)
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
    frame.specNameText:SetScale(partySpecScale)
    frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)

    frame.arenaNumberText:SetText(idx)
    frame.arenaNumberText:SetTextColor(r, g, b, 1)
    frame.arenaNumberText:SetScale(partyIDScale)
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

    frame.name:SetText("")
    frame.specNameText:SetText(specName .. " " .. idx)
    frame.specNameText:SetTextColor(r, g, b, 1)
    frame.specNameText:SetScale(partySpecScale)
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
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
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
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)

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
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
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
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
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
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
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
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
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
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partySpecScale)
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
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
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
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
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
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
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
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, BetterBlizzPlatesDB.arenaSpecAnchor, BetterBlizzPlatesDB.arenaSpecXPos, BetterBlizzPlatesDB.arenaSpecYPos + 3)
            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
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
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
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
        BBP.RefreshAllNameplates()
        BBP.fistweaverFound = nil
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