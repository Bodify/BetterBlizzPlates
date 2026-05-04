if BBP.isMidnight then return end
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
local GetArenaOpponentSpec = GetArenaOpponentSpec

local function GetFrameSortID(unit)
    if FrameSortApi then
        return FrameSortApi.v3.Frame:FrameNumberForUnit(unit)
    end
end

local function GetFallbackClassName(unit)
    local className = UnitClassBase(unit)
    className = className:sub(1, 1):upper() .. className:sub(2):lower()
    return className
end

local function GetSpecName(id, unit)
    if not id then return GetFallbackClassName(unit) end
    local short = BetterBlizzPlatesDB.shortArenaSpecName
    return (short and specIDToNameShort[id]) or specIDToName[id]
end

local function UnitIsProbablyUnit(unit1, unit2)
    if not UnitExists(unit1) or not UnitExists(unit2) then return end

    return UnitClassBase(unit1) == UnitClassBase(unit2)
       and UnitRace(unit1) == UnitRace(unit2)
       and UnitHonorLevel(unit1) == UnitHonorLevel(unit2)
end

local function createSpexText(frame)
    if not frame.specNameText then
        frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
        --local db = BetterBlizzPlatesDB
        --BBP.SetFontBasedOnOption(frame.specNameText, 12, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or nil)
        BBP.SetFontBasedOnOption(frame.specNameText, 12, "OUTLINE")
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
        BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "OUTLINE")
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
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos = BetterBlizzPlatesDB.arenaIdYPos
    local arenaIDScale = BetterBlizzPlatesDB.arenaIDScale
    local idCircle = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "arena" .. i) then
            local r, g, b, a = 1, 1, 0, 1
            if enemyClassColorName then
                r, g, b, a = frame.name:GetTextColor()
            end

            createIDText(frame)

            frame.name:SetText("")
            frame.name:SetAlpha(0)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, arenaIdAnchor, arenaIdXPos + idCircleOffset, arenaIdYPos)

            i = GetFrameSortID("arena" .. i) or i

            frame.arenaNumberText:SetText(i)
            if enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(arenaIDScale)

            if idCircle then
                addIdCircle(frame, i)
            end
            break
        end
    end
end

-- Mode 2: Put ID on top of name
function BBP.ArenaIndicator2(frame)
    local enemyClassColorName = BetterBlizzPlatesDB.enemyClassColorName or BetterBlizzPlatesDB.enemyColorName
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos = BetterBlizzPlatesDB.arenaIdYPos
    local arenaIDScale = BetterBlizzPlatesDB.arenaIDScale
    local idCircle = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "arena" .. i) then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            i = GetFrameSortID("arena" .. i) or i

            frame.arenaNumberText:SetText(i)
            if enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(arenaIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name, arenaIdAnchor, arenaIdXPos + idCircleOffset, arenaIdYPos)

            if idCircle then
                addIdCircle(frame, i)
            end
            break
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.ArenaIndicator3(frame)
    local arenaSpecScale = BetterBlizzPlatesDB.arenaSpecScale
    local arenaSpecAnchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos = BetterBlizzPlatesDB.arenaSpecYPos

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "arena" .. i) then
            local specID = GetArenaOpponentSpec(i)
            local specName = GetSpecName(specID, "arena" .. i)
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            frame.name:SetText("")
            frame.name:SetAlpha(0)
            frame.specNameText:SetText(specName)
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetScale(arenaSpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
            break
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.ArenaIndicator4(frame)
    local arenaSpecScale = BetterBlizzPlatesDB.arenaSpecScale
    local arenaSpecAnchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos = BetterBlizzPlatesDB.arenaSpecYPos
    local arenaIDScale = BetterBlizzPlatesDB.arenaIDScale
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos = BetterBlizzPlatesDB.arenaIdYPos
    local enemyClassColorName = BetterBlizzPlatesDB.enemyClassColorName or BetterBlizzPlatesDB.enemyColorName
    local idCircle = BetterBlizzPlatesDB.showCircleOnArenaID
    local idCircleOffset = idCircle and 1 or 0

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "arena" .. i) then
            local r, g, b, a = frame.name:GetTextColor()
            local specID = GetArenaOpponentSpec(i)
            local specName = GetSpecName(specID, "arena" .. i)

            local anchorPoint = createSpexText(frame)

            createIDText(frame)

            frame.name:SetText("")
            frame.name:SetAlpha(0)
            frame.specNameText:SetText(specName)
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetScale(arenaSpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)

            i = GetFrameSortID("arena" .. i) or i

            frame.arenaNumberText:SetText(i)
            if enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, 1)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(arenaIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, arenaIdAnchor, arenaIdXPos + idCircleOffset, arenaIdYPos - 1)

            if idCircle then
                addIdCircle(frame, i)
            end
            break
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.ArenaIndicator5(frame)
    local arenaSpecScale = BetterBlizzPlatesDB.arenaSpecScale
    local arenaSpecAnchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos = BetterBlizzPlatesDB.arenaSpecYPos

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "arena" .. i) then
            local r, g, b, a = frame.name:GetTextColor()
            local specID = GetArenaOpponentSpec(i)
            local specName = GetSpecName(specID, "arena" .. i)

            local anchorPoint = createSpexText(frame)

            i = GetFrameSortID("arena" .. i) or i

            frame.name:SetText("")
            frame.name:SetAlpha(0)
            frame.specNameText:SetText(specName .. " " .. i)
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetScale(arenaSpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
            break
        end
    end
end

--#################################################################################
-- Party version
-- Mode 1: Replace name with ID
function BBP.PartyIndicator1(frame)
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos = BetterBlizzPlatesDB.arenaIdYPos
    local partyIDScale = BetterBlizzPlatesDB.partyIDScale

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "party" .. i) then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            i = GetFrameSortID("party" .. i) or i

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, arenaIdAnchor, arenaIdXPos, arenaIdYPos)
            frame.arenaNumberText:SetText(i)
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetScale(partyIDScale)
            break
        end
    end
end

-- Mode 2: Put ID on top of name
function BBP.PartyIndicator2(frame)
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos = BetterBlizzPlatesDB.arenaIdYPos
    local partyIDScale = BetterBlizzPlatesDB.partyIDScale

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "party" .. i) then
            local r, g, b, a = frame.name:GetTextColor()

            createIDText(frame)

            i = GetFrameSortID("party" .. i) or i

            frame.arenaNumberText:SetText(i)
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetScale(partyIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name, arenaIdAnchor, arenaIdXPos, arenaIdYPos)
            break
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.PartyIndicator3(frame)
    local partySpecScale = BetterBlizzPlatesDB.partySpecScale
    local arenaSpecAnchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos = BetterBlizzPlatesDB.arenaSpecYPos

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "party" .. i) then
            local specID = BBP.GetSpecID(frame)
            local specName = GetSpecName(specID, "party" .. i)
            local r, g, b, a = frame.name:GetTextColor()

            local anchorPoint = createSpexText(frame)

            frame.name:SetText("")
            frame.specNameText:SetText(specName)
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetScale(partySpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
            break
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.PartyIndicator4(frame)
    local partySpecScale = BetterBlizzPlatesDB.partySpecScale
    local arenaSpecAnchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos = BetterBlizzPlatesDB.arenaSpecYPos
    local partyIDScale = BetterBlizzPlatesDB.partyIDScale
    local arenaIdAnchor = BetterBlizzPlatesDB.arenaIdAnchor
    local arenaIdXPos = BetterBlizzPlatesDB.arenaIdXPos
    local arenaIdYPos = BetterBlizzPlatesDB.arenaIdYPos

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "party" .. i) then
            local r, g, b, a = frame.name:GetTextColor()
            local specID = BBP.GetSpecID(frame)
            local specName = GetSpecName(specID, "party" .. i)

            local anchorPoint = createSpexText(frame)

            createIDText(frame)

            i = GetFrameSortID("party" .. i) or i

            frame.name:SetText("")
            frame.specNameText:SetText(specName)
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetScale(partySpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)

            frame.arenaNumberText:SetText(i)
            frame.arenaNumberText:SetTextColor(r, g, b, 1)
            frame.arenaNumberText:SetScale(partyIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, arenaIdAnchor, arenaIdXPos, arenaIdYPos - 1)
            break
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.PartyIndicator5(frame)
    local partySpecScale = BetterBlizzPlatesDB.partySpecScale
    local arenaSpecAnchor = BetterBlizzPlatesDB.arenaSpecAnchor
    local arenaSpecXPos = BetterBlizzPlatesDB.arenaSpecXPos
    local arenaSpecYPos = BetterBlizzPlatesDB.arenaSpecYPos

    for i = 1, 3 do
        if UnitIsProbablyUnit(frame.unit, "party" .. i) then
            local r, g, b, a = frame.name:GetTextColor()
            local specID = BBP.GetSpecID(frame)
            local specName = GetSpecName(specID, "party" .. i)

            local anchorPoint = createSpexText(frame)

            i = GetFrameSortID("party" .. i) or i

            frame.name:SetText("")
            frame.specNameText:SetText(specName .. " " .. i)
            frame.specNameText:SetTextColor(r, g, b, 1)
            frame.specNameText:SetScale(partySpecScale)
            frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
            break
        end
    end
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
        if UnitIsFriend("player", frame.unit) then
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
        if UnitIsFriend("player", frame.unit) then
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
        if UnitIsFriend("player", frame.unit) then
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
        if UnitIsFriend("player", frame.unit) then
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
        if UnitIsFriend("player", frame.unit) then
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
    if IsActiveBattlefieldArena() and UnitIsPlayer(frame.unit) then
        local unitType
        if UnitIsEnemy("player", frame.unit) then
            unitType = "arena"
        else
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
        else
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
    if not BBP.isInBg then return end
    if not UnitIsEnemy(frame.unit, "player") or not UnitIsPlayer(frame.unit) then
        if frame.specNameText then
            frame.specNameText:SetText("")
        end
        return
    else

        local db = BetterBlizzPlatesDB
        local arenaSpecScale = db.arenaSpecScale
        local arenaSpecAnchor = db.arenaSpecAnchor
        local arenaSpecXPos = db.arenaSpecXPos
        local arenaSpecYPos = db.arenaSpecYPos

        local specID = BBP.GetSpecID(frame)
        local specName = GetSpecName(specID, frame.unit)
        local r, g, b, a = frame.name:GetTextColor()

        local anchorPoint = createSpexText(frame)

        frame.name:SetText("")
        frame.name:SetAlpha(0)
        frame.specNameText:SetText(specName)
        frame.specNameText:SetTextColor(r, g, b, 1)
        frame.specNameText:SetScale(arenaSpecScale)
        frame.specNameText:SetPoint(anchorPoint, frame.healthBar, arenaSpecAnchor, arenaSpecXPos, arenaSpecYPos + 3)
    end
end