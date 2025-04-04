-- Healer Indicator
function BBP.HealerIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

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

        config.healerIndicatorInitialized = true
    end

    local anchorPoint = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
    local xPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
    local scale = BetterBlizzPlatesDB.healerIndicatorScale

    -- Initialize
    if not frame.healerIndicator then
        frame.healerIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.healerIndicator:SetAtlas("greencross")
        frame.healerIndicator:SetSize(12, 12)
        frame.healerIndicator:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875) -- Theres a few ugly white pixels around this texture, this gets rid of them
    end

    if not info.isFriend then
        xPos = BetterBlizzPlatesDB.healerIndicatorEnemyXPos
        yPos = BetterBlizzPlatesDB.healerIndicatorEnemyYPos
        anchorPoint = BetterBlizzPlatesDB.healerIndicatorEnemyAnchor
        scale = BetterBlizzPlatesDB.healerIndicatorEnemyScale
    end

    -- Set position and scale dynamically
    frame.healerIndicator:ClearAllPoints()
    frame.healerIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.healerIndicator:SetScale(scale)

    -- Test mode
    if config.healerIndicatorTestMode then
        frame.healerIndicator:Show()
        if config.healerIndicatorRedCrossEnemy and not info.isFriend then
            frame.healerIndicator:SetDesaturated(true)
            frame.healerIndicator:SetVertexColor(1,0,0)
        else
            frame.healerIndicator:SetDesaturated(false)
            frame.healerIndicator:SetVertexColor(1,1,1)
        end
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
    if BBP.IsSpecHealer(frame) then
        if config.healerIndicatorEnemyOnly and not info.isEnemy then
            if frame.healerIndicator then frame.healerIndicator:Hide() end
            return
        end
        if config.healerIndicatorRedCrossEnemy and not info.isFriend then
            frame.healerIndicator:SetDesaturated(true)
            frame.healerIndicator:SetVertexColor(1,0,0)
        else
            frame.healerIndicator:SetDesaturated(false)
            frame.healerIndicator:SetVertexColor(1,1,1)
        end
        frame.healerIndicator:Show()
    else
        frame.healerIndicator:Hide()
    end
end