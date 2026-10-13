local SECRET_HEALER_MAP = { HEALER = "bags-icon-addslots", TANK = "", DAMAGER = "" }

local function SetRedCross(texture, red)
    if red then
        texture:SetDesaturated(true)
        texture:SetVertexColor(1,0,0)
    else
        texture:SetDesaturated(false)
        texture:SetVertexColor(1,1,1)
    end
end

local function ShowSecretHealer(frame, arenaIndex, red)
    if not frame.healerIndicatorSecret then
        frame.healerIndicatorSecret = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.healerIndicatorSecret:SetAllPoints(frame.healerIndicator)
    end
    BBP.SetSecretArenaRoleTexture(frame.healerIndicatorSecret, arenaIndex, SECRET_HEALER_MAP)
    SetRedCross(frame.healerIndicatorSecret, red)
    frame.healerIndicatorSecret:Show()
end

-- Healer Indicator
function BBP.HealerIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    frame.mainHealerColor = nil

    if frame.healerIndicatorSecret then
        frame.healerIndicatorSecret:Hide()
    end

    if info.isSelf then
        if frame.healerIndicator then
            frame.healerIndicator:Hide()
            return
        end
    end

    if not config.healerIndicatorInitialized or BBP.needsUpdate then
        config.healerIndicatorAnchor = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
        config.healerIndicatorXPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
        config.healerIndicatorYPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
        config.healerIndicatorTestMode = BetterBlizzPlatesDB.healerIndicatorTestMode
        config.healerIndicatorArenaOnly = BetterBlizzPlatesDB.healerIndicatorArenaOnly
        config.healerIndicatorBgOnly = BetterBlizzPlatesDB.healerIndicatorBgOnly
        config.healerIndicatorRedCrossEnemy = BetterBlizzPlatesDB.healerIndicatorRedCrossEnemy
        config.healerIndicatorScale = BetterBlizzPlatesDB.healerIndicatorScale
        config.healerIndicatorEnemyOnly = BetterBlizzPlatesDB.healerIndicatorEnemyOnly
        config.healerIndicatorColorEnemyHealthbar = BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbar
        config.healerIndicatorColorFriendlyHealthbar = BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbar
        config.healerIndicatorColorEnemyHealthbarRGB = BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB
        config.healerIndicatorColorFriendlyHealthbarRGB = BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB

        config.healerIndicatorInitialized = true
    end

    local anchorPoint = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
    local xPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
    local scale = BetterBlizzPlatesDB.healerIndicatorScale

    -- Initialize
    if not frame.healerIndicator then
        frame.healerIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.healerIndicator:SetAtlas("bags-icon-addslots")
        frame.healerIndicator:SetSize(13, 13)
    end

    if not info.isFriend then
        xPos = BetterBlizzPlatesDB.healerIndicatorEnemyXPos
        yPos = BetterBlizzPlatesDB.healerIndicatorEnemyYPos
        anchorPoint = BetterBlizzPlatesDB.healerIndicatorEnemyAnchor
        scale = BetterBlizzPlatesDB.healerIndicatorEnemyScale
    end

    -- Set position and scale dynamically
    frame.healerIndicator:ClearAllPoints()
    frame.healerIndicator:SetPoint("CENTER", BBP.GetLevelSpanAnchor(frame, anchorPoint), anchorPoint, xPos, yPos)
    frame.healerIndicator:SetScale(scale)

    -- Test mode
    if config.healerIndicatorTestMode then
        frame.healerIndicator:Show()
        SetRedCross(frame.healerIndicator, config.healerIndicatorRedCrossEnemy and not info.isFriend)
        return
    end

    if (config.healerIndicatorArenaOnly and not BBP.isInArena) or (config.healerIndicatorBgOnly and not BBP.isInBg) then
        if config.healerIndicatorArenaOnly and config.healerIndicatorBgOnly then
            if not BBP.isInPvP then
                frame.healerIndicator:Hide()
                return
            end
        else
            frame.healerIndicator:Hide()
            return
        end
    end

    -- Condition check: healerIndicatorEnemyOnly
    local specID, secretIndex = BBP.GetSpecID(frame)
    if specID or secretIndex then
        if frame.needsHealerUpdate then
            frame.needsHealerUpdate = nil
            BBP.pendingHealerCount = (BBP.pendingHealerCount or 0) - 1
        end
    else
        if not frame.needsHealerUpdate then
            frame.needsHealerUpdate = true
            BBP.pendingHealerCount = (BBP.pendingHealerCount or 0) + 1
        end
    end

    if secretIndex then
        frame.healerIndicator:Hide()
        if config.healerIndicatorEnemyOnly and not info.isEnemy then return end
        ShowSecretHealer(frame, secretIndex, config.healerIndicatorRedCrossEnemy and not info.isFriend)
        return
    end

    if BBP.IsSpecHealer(frame) then
        if config.healerIndicatorEnemyOnly and not info.isEnemy then
            if frame.healerIndicator then frame.healerIndicator:Hide() end
            return
        end
        SetRedCross(frame.healerIndicator, config.healerIndicatorRedCrossEnemy and not info.isFriend)
        if config.healerIndicatorColorEnemyHealthbar and not info.isFriend then
            frame.mainHealerColor = config.healerIndicatorColorEnemyHealthbarRGB
            frame.healthBar:SetStatusBarColor(unpack(frame.mainHealerColor))
            frame.needsRecolor = true
        elseif config.healerIndicatorColorFriendlyHealthbar and info.isFriend then
            frame.mainHealerColor = config.healerIndicatorColorFriendlyHealthbarRGB
            frame.healthBar:SetStatusBarColor(unpack(frame.mainHealerColor))
            frame.needsRecolor = true
        end
        frame.healerIndicator:Show()
    else
        frame.healerIndicator:Hide()
    end
end