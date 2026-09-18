-- Map PvPUnitClassification enum values to colors
local classificationColors = {
    [0] = {1, 0.24, 0.26},    -- FlagCarrierHorde (Red)
    [1] = {0.4, 0.6, 1},      -- FlagCarrierAlliance (Blue)
    [2] = {0, 1, 0},          -- FlagCarrierNeutral (Green)
    [7] = {0, 0.81, 1},       -- OrbCarrierBlue
    [8] = {0.37, 1, 0.45},    -- OrbCarrierGreen
    [9] = {1, 0.24, 0.26},    -- OrbCarrierOrange (Red)
    [10] = {0.78, 0.25, 1},   -- OrbCarrierPurple
}

-- Classification types
local CLASS_FLAG = {0, 1, 2}
local CLASS_ORB = {7, 8, 9, 10}

local function GetClassificationType(classification)
    if not classification then return nil end
    for _, v in ipairs(CLASS_FLAG) do
        if classification == v then return "FLAG" end
    end
    for _, v in ipairs(CLASS_ORB) do
        if classification == v then return "ORB" end
    end
    return nil
end

function BBP.BgIndicator(frame)
    local classification = UnitPvpClassification(frame.unit)
    if not BBP.isInBg or not classification then
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

    local classificationType = GetClassificationType(classification)
    local indicatorColor

    -- Test Mode logic
    if BetterBlizzPlatesDB.bgIndicatorTestMode then
        -- Randomly choose between flag (40%) and orb (60%)
        if math.random() <= 0.4 then
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)
            indicatorColor = classificationColors[math.random(0, 2)]
        else
            frame.bgIndicator:SetAtlas("oribos-weeklyrewards-orb-dialog")
            frame.bgIndicator:SetSize(50, 50)
            indicatorColor = classificationColors[math.random(7, 10)]
        end

        frame.bgIndicator:SetVertexColor(unpack(indicatorColor))
        frame.bgIndicator:Show()
        frame.bgIndicator:SetScale(config.bgIndicatorScale or 1)
        frame.bgIndicator:ClearAllPoints()
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, frame, config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        return
    end

    -- Check if we should show this type based on config
    if classificationType == "ORB" and not config.bgIndicatorOrbs then
        frame.bgIndicator:Hide()
        return
    end

    if classificationType == "FLAG" and not config.bgIndicatorFlags then
        frame.bgIndicator:Hide()
        return
    end

    -- Get color from classification
    indicatorColor = classificationColors[classification]
    frame.bgIndicator.flagActive = indicatorColor and true or nil

    if indicatorColor then
        frame.bgIndicator:SetVertexColor(unpack(indicatorColor))

        -- Set texture and size based on classification type
        if classificationType == "FLAG" then
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)
        else -- ORB
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