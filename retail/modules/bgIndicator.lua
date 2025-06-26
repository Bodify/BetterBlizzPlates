local color = {
    [121177] = {1, 0.24, 0.26}, -- Red orb
    [121176] = {0.37, 1, 0.45}, -- Green orb
    [121164] = {0, 0.81, 1},    -- Blue orb
    [121175] = {0.78, 0.25, 1}, -- Purple orb
    [156621] = {0.4, 0.6, 1}, -- Ally Flag
    [156618] = {1, 0.24, 0.26}, -- Horde Flag
    [34976] = {0, 1, 0}, -- Netherstorm Flag
    [434339] = {0.81, 1, 0.66} -- Deephaul Ravine Crystal
}
BBP.BgIndicatorColors = color

local function GetAuraColor(frame, foundID, auraType)
    -- If `foundID` exists in the table, return its color immediately
    if foundID and color[foundID] then
        return color[foundID]
    end

    -- Otherwise, scan buffs/debuffs based on `auraType`
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellID = BBP.TWWUnitAura(frame.unit, i, auraType or "HARMFUL")
        if spellID and color[spellID] then
            return color[spellID]
        end
    end

    return nil  -- No matching aura found
end

local tempVal = 0
function BBP.BgIndicator(frame, foundID)
    if BBP.tempDebug then
        tempVal = tempVal + 1
        print(tempVal, "BG: ", UnitName(frame.unit), foundID)
    end

    if not BBP.isInBg or not UnitPvpClassification(frame.unit) then
        if frame.bgIndicator then
            frame.bgIndicator:Hide()
        end
        if not BetterBlizzPlatesDB.bgIndicatorTestMode then
            return
        end
    end

    if not BBP.tempDebug and UnitIsUnit(frame.unit, "player") then
        if frame.bgIndicator then
            frame.bgIndicator:Hide()
        end
        return
    end

    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)
    if not info then return end

    if not config.bgIndicatorInitialized or BBP.needsUpdate then
        config.bgIndicatorAnchor = BetterBlizzPlatesDB.bgIndicatorAnchor
        config.bgIndicatorOppositeAnchor = BBP.GetOppositeAnchor(config.bgIndicatorAnchor)
        config.bgIndicatorScale = BetterBlizzPlatesDB.bgIndicatorScale
        config.bgIndicatorXPos = BetterBlizzPlatesDB.bgIndicatorXPos
        config.bgIndicatorYPos = BetterBlizzPlatesDB.bgIndicatorYPos
        config.bgIndicatorEnemyOnly = BetterBlizzPlatesDB.bgIndicatorEnemyOnly
        config.bgIndicatorOrbs = BetterBlizzPlatesDB.bgIndicatorShowOrbs
        config.bgIndicatorFlags = BetterBlizzPlatesDB.bgIndicatorShowFlags

        config.bgIndicatorInitialized = true
    end

    if not frame.bgIndicator then
        frame.bgIndicator = frame:CreateTexture(nil, "BACKGROUND")
        frame.bgIndicator:SetDesaturated(true)
    end

    -- if config.bgIndicatorEnemyOnly and info.isFriend then
    --     frame.bgIndicator:Hide()
    --     return
    -- end

    local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    local isTemple = instanceMapID == 998
    local isWSGorEOTS = instanceMapID == 489 or instanceMapID == 566 or instanceMapID == 2106
    local isDeephaulRavine = instanceMapID == 2656
    local auraColor

    -- Test Mode logic
    if BetterBlizzPlatesDB.bgIndicatorTestMode then
        -- Randomly choose between flag (30%) and orb (70%)
        if math.random() <= 0.3 then
            -- Flag texture
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)

            -- Randomly pick red or soft green for the flag in test mode (50-50 chance)
            if math.random() <= 0.5 then
                auraColor = {1, 0.24, 0.26}  -- Red for enemy
            else
                auraColor = {0.4, 0.6, 1}  -- Softer green for friendly
            end
        else
            -- Orb texture
            frame.bgIndicator:SetAtlas("oribos-weeklyrewards-orb-dialog")
            frame.bgIndicator:SetSize(50, 50)

            -- Randomly pick one of the orb colors
            local orbColors = {
                color[121177], -- Red orb
                color[121176], -- Green orb
                color[121164], -- Blue orb
                color[121175]  -- Purple orb
            }
            auraColor = orbColors[math.random(#orbColors)]
        end

        frame.bgIndicator:SetVertexColor(unpack(auraColor))
        frame.bgIndicator:Show()
        frame.bgIndicator:SetScale(config.bgIndicatorScale or 1)
        frame.bgIndicator:ClearAllPoints()
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, frame, config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        return
    end

    -- Check for debuffs in Temple of Kotmogu
    if isTemple and config.bgIndicatorOrbs then
        auraColor = GetAuraColor(frame, foundID, "HARMFUL")
    end

    -- Check for buffs in Warsong Gulch or Eye of the Storm
    if isWSGorEOTS and config.bgIndicatorFlags then
        auraColor = GetAuraColor(frame, foundID, "HELPFUL")
    end

    if isDeephaulRavine then
        auraColor = GetAuraColor(frame, foundID, "HARMFUL")
    end

    frame.bgIndicator.flagActive = auraColor and true or nil

    if auraColor then
        frame.bgIndicator:SetVertexColor(unpack(auraColor))

        -- Flag (Netherstorm Flag, Horde Flag, Alliance Flag)
        if isWSGorEOTS then
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)
        elseif isDeephaulRavine then
            frame.bgIndicator:SetAtlas("SpecDial_Pip_Empty")
            frame.bgIndicator:SetSize(28, 45)
        else -- Orb of Power
            frame.bgIndicator:SetAtlas("oribos-weeklyrewards-orb-dialog")
            frame.bgIndicator:SetSize(50, 50)
        end

        frame.bgIndicator:SetScale(config.bgIndicatorScale or 1)
        frame.bgIndicator:ClearAllPoints()
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, frame.HealthBarsContainer, config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        frame.bgIndicator:Show()
    else
        frame.bgIndicator:Hide()
    end
end