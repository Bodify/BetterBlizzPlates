-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Healer spec id's
local HealerSpecs = {
    [105]  = true,  --> druid resto
    [270]  = true,  --> monk mw
    [65]   = true,  --> paladin holy
    [256]  = true,  --> priest disc
    [257]  = true,  --> priest holy
    [264]  = true,  --> shaman resto
    [1468] = true,  --> preservation evoker  
}

-- Healer Indicator
function BBP.HealerIndicator(frame)
    local anchorPoint = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
    local xPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
    local testMode = BetterBlizzPlatesDB.healerIndicatorTestMode
    local inInstance, instanceType = IsInInstance()
    local arenaOnly = BetterBlizzPlatesDB.healerIndicatorArenaOnly
    local bgOnly = BetterBlizzPlatesDB.healerIndicatorBgOnly
    local redCrossEnemy = BetterBlizzPlatesDB.healerIndicatorRedCrossEnemy
    local scale = BetterBlizzPlatesDB.healerIndicatorScale

    -- Initialize
    if not frame.healerIndicator then
        frame.healerIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.healerIndicator:SetAtlas("greencross")
        frame.healerIndicator:SetSize(12, 12)
        frame.healerIndicator:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875) -- Theres a few ugly white pixels around this texture, this gets rid of them
    end

    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.displayedUnit)
    if not isFriend then
        xPos = BetterBlizzPlatesDB.healerIndicatorEnemyXPos
        yPos = BetterBlizzPlatesDB.healerIndicatorEnemyYPos
        anchorPoint = BetterBlizzPlatesDB.healerIndicatorEnemyAnchor
        scale = BetterBlizzPlatesDB.healerIndicatorEnemyScale
    end

    -- Set position and scale dynamically
    frame.healerIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.healerIndicator:SetScale(scale)

    -- Test mode
    if testMode then
        frame.healerIndicator:Show()
        if redCrossEnemy and not isFriend then
            frame.healerIndicator:SetDesaturated(true)
            frame.healerIndicator:SetVertexColor(1,0,0)
        else
            frame.healerIndicator:SetDesaturated(false)
            frame.healerIndicator:SetVertexColor(1,1,1)
        end
        return
    end

    -- Check for Details
    local Details = Details
    if not Details or Details.realversion < 134 then
        frame.healerIndicator:Hide()
        return
    end

    if (arenaOnly and not (inInstance and instanceType == "arena")) or (bgOnly and not (inInstance and instanceType == "pvp")) then
        frame.healerIndicator:Hide()
        return
    end

    -- Get spec by guid from details
    local unitGUID = UnitGUID(frame.displayedUnit)
    local spec = Details:GetSpecByGUID(unitGUID)

    -- Condition check: healerIndicatorEnemyOnly
    if UnitIsPlayer(frame.displayedUnit) and HealerSpecs[spec] then
        if BetterBlizzPlatesDB.healerIndicatorEnemyOnly and not isEnemy then
            if frame.healerIndicator then frame.healerIndicator:Hide() end
            return
        end
        if redCrossEnemy and not isFriend then
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