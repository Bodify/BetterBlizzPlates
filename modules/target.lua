-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

local previousTargetNameplate = nil

-- Target Indicator
function BBP.TargetIndicator(frame)
    if not frame or not frame.unit then return end
    local anchorPoint = BetterBlizzPlatesDB.targetIndicatorAnchor or "TOP"
    local xPos = BetterBlizzPlatesDB.targetIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.targetIndicatorYPos or 0
    local dbScale = BetterBlizzPlatesDB.targetIndicatorScale or 1

    local rotation

    if anchorPoint == "TOP" then
        rotation = math.rad(180)
    elseif anchorPoint == "BOTTOM" then
        rotation = math.rad(0)
    elseif anchorPoint == "LEFT" then
        rotation = math.rad(-90)
    elseif anchorPoint == "RIGHT" then
        rotation = math.rad(90)
    --
    elseif anchorPoint == "TOPLEFT" then
        rotation = math.rad(225)
    elseif anchorPoint == "TOPRIGHT" then
        rotation = math.rad(-225)
    elseif anchorPoint == "BOTTOMLEFT" then
        rotation = math.rad(-45)
    elseif anchorPoint == "BOTTOMRIGHT" then
        rotation = math.rad(45)
    end

    -- Initialize
    if not frame.targetIndicator then
        frame.targetIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.targetIndicator:SetSize(14, 9)
        frame.targetIndicator:SetAtlas("Navigation-Tracked-Arrow")
        frame.targetIndicator:Hide()
        frame.targetIndicator:SetDrawLayer("OVERLAY", 7) 
        frame.targetIndicator:SetVertexColor(1,1,1)
    end

    frame.targetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.targetIndicator:SetScale(dbScale)
    frame.targetIndicator:SetRotation(rotation)

    -- Test mode
    if BetterBlizzPlatesDB.targetIndicatorTestMode then
        frame.targetIndicator:Show()
        return
    end

    -- Show or hide Target Indicator
    if UnitIsUnit(frame.unit, "target") then
        frame.targetIndicator:Show()
    else
        frame.targetIndicator:Hide()
    end
    if not BetterBlizzPlatesDB.targetIndicator then
        frame.targetIndicator:Hide()
    end
end

-- Event listener for Target Indicator
local frameTargetChanged = CreateFrame("Frame")
frameTargetChanged:RegisterEvent("PLAYER_TARGET_CHANGED")
frameTargetChanged:SetScript("OnEvent", function(self, event)
    local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")

    if previousTargetNameplate then
        BBP.TargetIndicator(previousTargetNameplate.UnitFrame)
        BBP.FadeOutNPCs(previousTargetNameplate.UnitFrame)
        BBP.HideNPCs(previousTargetNameplate.UnitFrame)  -- Update the alpha of the previous target
        previousTargetNameplate = nil
    end

    if nameplateForTarget then
        BBP.TargetIndicator(nameplateForTarget.UnitFrame)
        BBP.FadeOutNPCs(nameplateForTarget.UnitFrame)
        BBP.HideNPCs(nameplateForTarget.UnitFrame)  -- Update the alpha of the new target
        previousTargetNameplate = nameplateForTarget
    end
end)


-- Toggle event listener for Target Indicator on/off
function BBP.ToggleTargetIndicator(value)
    if BetterBlizzPlatesDB.targetIndicator or BetterBlizzPlatesDB.fadeOutNPC or BetterBlizzPlatesDB.hideNPC then
        frameTargetChanged:RegisterEvent("PLAYER_TARGET_CHANGED")
        previousTargetNameplate = C_NamePlate.GetNamePlateForUnit("target")
    else
        if not BetterBlizzPlatesDB.fadeOutNPC or BetterBlizzPlatesDB.hideNPC then
            frameTargetChanged:UnregisterEvent("PLAYER_TARGET_CHANGED")
        end
        previousTargetNameplate = nil
    end
end