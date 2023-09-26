-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

local previousTargetNameplate = nil
local previousFocusTargetNameplate = nil
local originalColor = {}
local customFocusTexture = "Interface\\AddOns\\BetterBlizzPlates\\media\\focusTexture.tga"

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

-- Focus Target Indicator
function BBP.FocusTargetIndicator(frame)
    if not frame or not frame.unit then return end
    local anchorPoint = BetterBlizzPlatesDB.focusTargetIndicatorAnchor or "TOP"
    local xPos = BetterBlizzPlatesDB.focusTargetIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.focusTargetIndicatorYPos or 0
    local dbScale = BetterBlizzPlatesDB.focusTargetIndicatorScale or 1

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
    if not frame.focusTargetIndicator then
        frame.focusTargetIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.focusTargetIndicator:SetSize(20, 20)
        frame.focusTargetIndicator:SetAtlas("Waypoint-MapPin-Untracked")
        frame.focusTargetIndicator:Hide()
        frame.focusTargetIndicator:SetDrawLayer("OVERLAY", 7) 
        frame.focusTargetIndicator:SetVertexColor(1,1,1)
    end

    frame.focusTargetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.focusTargetIndicator:SetScale(dbScale)
    frame.focusTargetIndicator:SetRotation(rotation)

    -- Store original colors
    if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
        if not originalColor[frame] then
            originalColor[frame] = {frame.healthBar:GetStatusBarColor()}
        end
    end

    -- Test mode
    if BetterBlizzPlatesDB.focusTargetIndicatorTestMode then
        frame.focusTargetIndicator:Show()
        return
    end
    
    -- Show or hide focusTarget Indicator
    if UnitIsUnit(frame.unit, "focus") then
        frame.focusTargetIndicator:Show()
        frame.healthBar:SetStatusBarTexture(customFocusTexture)
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            frame.healthBar:SetStatusBarColor(0,1,0)
        end
    else
        frame.focusTargetIndicator:Hide()
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            -- Restore the original color values
            local original = originalColor[frame]
            if original then
                frame.healthBar:SetStatusBarColor(unpack(original))
            end
        end
    end
    if not BetterBlizzPlatesDB.focusTargetIndicator then
        frame.focusTargetIndicator:Hide()
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            -- Restore the original color values
            local original = originalColor[frame]
            if original then
                frame.healthBar:SetStatusBarColor(unpack(original))
            end
        end
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

-- Event listener for Focus Target Indicator
local frameFocusTargetChanged = CreateFrame("Frame")
frameFocusTargetChanged:RegisterEvent("PLAYER_FOCUS_CHANGED")
frameFocusTargetChanged:SetScript("OnEvent", function(self, event)
    local nameplateForFocusTarget = C_NamePlate.GetNamePlateForUnit("focus")

    if previousFocusTargetNameplate then
        BBP.FocusTargetIndicator(previousFocusTargetNameplate.UnitFrame)
        BBP.FadeOutNPCs(previousFocusTargetNameplate.UnitFrame)
        BBP.HideNPCs(previousFocusTargetNameplate.UnitFrame)  -- Update the alpha of the previous focus target
        previousFocusTargetNameplate = nil
    end

    if nameplateForFocusTarget then
        BBP.FocusTargetIndicator(nameplateForFocusTarget.UnitFrame)
        BBP.FadeOutNPCs(nameplateForFocusTarget.UnitFrame)
        BBP.HideNPCs(nameplateForFocusTarget.UnitFrame)
        previousFocusTargetNameplate = nameplateForFocusTarget
    end
end)

-- Toggle event listener for Target Indicator on/off
function BBP.ToggleFocusTargetIndicator(value)
    if BetterBlizzPlatesDB.focusTargetIndicator or BetterBlizzPlatesDB.fadeOutNPC or BetterBlizzPlatesDB.hideNPC then
        frameFocusTargetChanged:RegisterEvent("PLAYER_FOCUS_CHANGED")
        previousFocusTargetNameplate = C_NamePlate.GetNamePlateForUnit("focus")
    else
        if not BetterBlizzPlatesDB.fadeOutNPC or BetterBlizzPlatesDB.hideNPC then
            frameFocusTargetChanged:UnregisterEvent("PLAYER_FOCUS_CHANGED")
        end
        previousFocusTargetNameplate = nil
    end
end