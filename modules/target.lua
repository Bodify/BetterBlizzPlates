-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
local LSM = LibStub("LibSharedMedia-3.0")

local previousTargetNameplate = nil
local previousFocusTargetNameplate = nil

-- Target Indicator
function BBP.TargetIndicator(frame)
    if not frame or not frame.unit then return end
    local targetIndicator = BetterBlizzPlatesDB.targetIndicator
    if not targetIndicator then
        if frame.targetIndicator then
            frame.targetIndicator:Hide()
        end
        return
    end
    local anchorPoint = BetterBlizzPlatesDB.targetIndicatorAnchor or "TOP"
    local xPos = BetterBlizzPlatesDB.targetIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.targetIndicatorYPos or 0
    local dbScale = BetterBlizzPlatesDB.targetIndicatorScale or 1

    local testMode = BetterBlizzPlatesDB.targetIndicatorTestMode

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
    if testMode then
        frame.targetIndicator:Show()
        return
    end

    -- Show or hide Target Indicator
    if UnitIsUnit(frame.unit, "target") then
        frame.targetIndicator:Show()
    else
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

    -- Initialize
    if not frame.focusTargetIndicator then
        frame.focusTargetIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.focusTargetIndicator:SetSize(20, 20)
        frame.focusTargetIndicator:SetAtlas("Waypoint-MapPin-Untracked")
        frame.focusTargetIndicator:Hide()
        frame.focusTargetIndicator:SetDrawLayer("OVERLAY", 7)
        frame.focusTargetIndicator:SetVertexColor(1, 1, 1)
    end

    frame.focusTargetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.focusTargetIndicator:SetScale(dbScale)

    local focusTextureName = BetterBlizzPlatesDB.focusTargetIndicatorTexture
    local focusTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, focusTextureName)
    local textureName = BetterBlizzPlatesDB.customTexture
    local customTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)

    -- Test mode
    if BetterBlizzPlatesDB.focusTargetIndicatorTestMode then
        frame.focusTargetIndicator:Show()
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            local color = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB or {1, 1, 1}
            frame.healthBar:SetStatusBarColor(unpack(color))
        else
            BBP.CompactUnitFrame_UpdateHealthColor(frame)
        end
        if BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            if BetterBlizzPlatesDB.useCustomTextureForBars then
                frame.healthBar:SetStatusBarTexture(customTexture)
            else
                frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
            end
        end
        return
    end

    if UnitIsUnit(frame.unit, "focus") then
        frame.focusTargetIndicator:Show()
        if BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            if BetterBlizzPlatesDB.useCustomTextureForBars then
                frame.healthBar:SetStatusBarTexture(customTexture)
            else
                frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
            end
        end
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            local color = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB or {1, 1, 1}
            frame.healthBar:SetStatusBarColor(unpack(color))
        end
    else
        frame.focusTargetIndicator:Hide()
    end
end

-- Event listener for Target Indicator
local frameTargetChanged = CreateFrame("Frame")
frameTargetChanged:RegisterEvent("PLAYER_TARGET_CHANGED")
frameTargetChanged:SetScript("OnEvent", function(self, event)
    local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")

    local hideTotemHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar

    if previousTargetNameplate then
        BBP.TargetIndicator(previousTargetNameplate.UnitFrame)
        if BetterBlizzPlatesDB.fadeOutNPC then
            BBP.FadeOutNPCs(previousTargetNameplate.UnitFrame)
            local fadeAllButTarget = BetterBlizzPlatesDB.fadeAllButTarget
            if fadeAllButTarget then
                for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                    local frame = namePlate.UnitFrame
                    frame:SetAlpha(1)
                end
            end
        end
        if BetterBlizzPlatesDB.hideNPC then
            BBP.HideNPCs(previousTargetNameplate.UnitFrame)
        end
        if hideTotemHealthBar then
            BBP.ApplyTotemIconsAndColorNameplate(previousTargetNameplate.UnitFrame, previousTargetNameplate.UnitFrame.unit)
        end
        if BetterBlizzPlatesDB.hideCastbar then
            if previousTargetNameplate.UnitFrame then
                local castBar = previousTargetNameplate.UnitFrame.castBar --149
                if castBar:IsForbidden() then return end
                if castBar then
                    castBar:SetAlpha(0)
                    castBar.Icon:SetAlpha(0)
                    if previousTargetNameplate.UnitFrame.CastTimer then
                        previousTargetNameplate.UnitFrame.CastTimer:Hide()
                    end
                    if previousTargetNameplate.UnitFrame.TargetText then
                        previousTargetNameplate.UnitFrame.TargetText:Hide()
                    end
                end
            end
        end
        previousTargetNameplate = nil
    end

    if nameplateForTarget then
        BBP.TargetIndicator(nameplateForTarget.UnitFrame)
        if BetterBlizzPlatesDB.fadeOutNPC then
            BBP.FadeOutNPCs(nameplateForTarget.UnitFrame)
            local fadeAllButTarget = BetterBlizzPlatesDB.fadeAllButTarget
            if fadeAllButTarget then
                local fadeOutNPCsAlpha = BetterBlizzPlatesDB.fadeOutNPCsAlpha
                for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                    local frame = namePlate.UnitFrame
                    if UnitExists("target") and not UnitIsPlayer(frame.unit) then
                        -- Check if this unit frame's unit is the current target
                        local isTarget = UnitIsUnit(frame.unit, "target")
                        if not isTarget then
                            frame:SetAlpha(fadeOutNPCsAlpha)
                        else
                            frame:SetAlpha(1)
                        end
                    else
                        frame:SetAlpha(1)
                    end
                end
            end
        end
        if BetterBlizzPlatesDB.hideNPC then
            BBP.HideNPCs(nameplateForTarget.UnitFrame)
        end
        if hideTotemHealthBar then
            BBP.ApplyTotemIconsAndColorNameplate(nameplateForTarget.UnitFrame, nameplateForTarget.UnitFrame.unit)
        end
        if BetterBlizzPlatesDB.showCastbarIfTarget then
            local castBar = nameplateForTarget.UnitFrame.castBar
            if castBar:IsForbidden() then return end
            if castBar then
                castBar:SetAlpha(1)
                castBar.Icon:SetAlpha(1)
                if nameplateForTarget.UnitFrame.CastTimer then
                    nameplateForTarget.UnitFrame.CastTimer:Show()
                end
                if nameplateForTarget.UnitFrame.TargetText then
                    nameplateForTarget.UnitFrame.TargetText:Show()
                end
            end
        end
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
        BBP.CompactUnitFrame_UpdateHealthColor(previousFocusTargetNameplate.UnitFrame)
        previousFocusTargetNameplate = nil
    end

    if nameplateForFocusTarget then
        BBP.FocusTargetIndicator(nameplateForFocusTarget.UnitFrame)
        previousFocusTargetNameplate = nameplateForFocusTarget
    end
end)

-- Toggle event listener for Target Indicator on/off
function BBP.ToggleFocusTargetIndicator(value)
    if BetterBlizzPlatesDB.focusTargetIndicator then
        frameFocusTargetChanged:RegisterEvent("PLAYER_FOCUS_CHANGED")
        previousFocusTargetNameplate = C_NamePlate.GetNamePlateForUnit("focus")
    else
        frameFocusTargetChanged:UnregisterEvent("PLAYER_FOCUS_CHANGED")
        previousFocusTargetNameplate = nil
    end
end