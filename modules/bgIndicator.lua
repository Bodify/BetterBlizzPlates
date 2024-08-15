local color = {
    [121177] = {1, 0.24, 0.26}, -- Red orb
    [121176] = {0.37, 1, 0.45}, -- Green orb
    [121164] = {0, 0.81, 1},    -- Blue orb
    [121175] = {0.78, 0.25, 1}, -- Purple orb
}

-- List of possible aura names to check
local auraNames = {
    "Netherstorm Flag",
    "Horde Flag",
    "Alliance Flag",
}

function BBP.BgIndicator(frame)
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
        config.bgIndicatorOrbs = BetterBlizzPlatesDB.bgIndicatorOrbs
        config.bgIndicatorFlags = BetterBlizzPlatesDB.bgIndicatorFlags

        config.bgIndicatorInitialized = true
    end

    if not frame.bgIndicator then
        frame.bgIndicator = frame:CreateTexture(nil, "BACKGROUND")
        frame.bgIndicator:SetDesaturated(true)
    end

    if config.bgIndicatorEnemyOnly and info.isFriend then
        frame.bgIndicator:Hide()
        return
    end

    local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    local isTemple = instanceMapID == 998
    local isWSGorEOTS = instanceMapID == 489 or instanceMapID == 566

    local auraColor = nil

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
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, frame, config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        return
    end

    -- Check for debuffs in Temple of Kotmogu
    if isTemple and config.bgIndicatorOrbs then
        local name, _, _, _, _, _, _, _, _, spellId = AuraUtil.FindAuraByName("Orb of Power", frame.unit, "HARMFUL")
        if name and color[spellId] then
            auraColor = color[spellId]
        end
    end

    -- Check for buffs in Warsong Gulch or Eye of the Storm
    if isWSGorEOTS and config.bgIndicatorFlags then
        for _, auraName in ipairs(auraNames) do
            local name, _, _, _, _, _, _, _, _, spellId = AuraUtil.FindAuraByName(auraName, frame.unit, "HELPFUL")
            if name and color[spellId] then
                auraColor = info.isFriend and {0.4, 0.6, 1} or {1, 0.24, 0.26}
                break
            end
        end
    end

    if auraColor then
        frame.bgIndicator:SetVertexColor(unpack(auraColor))

        -- Flag (Netherstorm Flag, Horde Flag, Alliance Flag)
        if isWSGorEOTS then
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)
        else -- Orb of Power
            frame.bgIndicator:SetAtlas("oribos-weeklyrewards-orb-dialog")
            frame.bgIndicator:SetSize(50, 50)
        end

        frame.bgIndicator:SetScale(config.bgIndicatorScale or 1)
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, frame.HealthBarsContainer, config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        frame.bgIndicator:Show()
    else
        frame.bgIndicator:Hide()
    end
end