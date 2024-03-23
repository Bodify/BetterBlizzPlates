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

    local hideIcon = BetterBlizzPlatesDB.targetIndicatorHideIcon
    local colorNp = BetterBlizzPlatesDB.targetIndicatorColorNameplate
    local colorName = BetterBlizzPlatesDB.targetIndicatorColorName

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

    local changeTexture = BetterBlizzPlatesDB.targetIndicatorChangeTexture
    local targetIndicatorTextureName = BetterBlizzPlatesDB.targetIndicatorTexture
    local targetTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, targetIndicatorTextureName)
    local textureName = BetterBlizzPlatesDB.customTexture
    local customTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)

    -- Show or hide Target Indicator
    if UnitIsUnit(frame.unit, "target") then
        if not hideIcon then
            frame.targetIndicator:Show()
        end
        if changeTexture then
            frame.healthBar:SetStatusBarTexture(targetTexture)
        else
            if BetterBlizzPlatesDB.useCustomTextureForBars then
                frame.healthBar:SetStatusBarTexture(customTexture)
            else
                frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
            end
        end
        local shouldColorize = colorNp or colorName
        local color
        if shouldColorize then
            color = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        end
        if colorNp then
            frame.healthBar:SetStatusBarColor(unpack(color))
        end
        if colorName then
            frame.name:SetVertexColor(unpack(color))
        end
    else
        frame.targetIndicator:Hide()
        if changeTexture then
            if BetterBlizzPlatesDB.useCustomTextureForBars then
                frame.healthBar:SetStatusBarTexture(customTexture)
            else
                frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
            end
        end
    end
end

-- Focus Target Indicator
function BBP.FocusTargetIndicator(frame)
    if not frame or not frame.unit then return end

    local anchorPoint = BetterBlizzPlatesDB.focusTargetIndicatorAnchor or "TOP"
    local xPos = BetterBlizzPlatesDB.focusTargetIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.focusTargetIndicatorYPos or 0
    local dbScale = BetterBlizzPlatesDB.focusTargetIndicatorScale or 1
    local useCustomTexture = BetterBlizzPlatesDB.useCustomTextureForBars

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

    local changeTexture = BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture
    local colorNp = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate
    local colorName = BetterBlizzPlatesDB.focusTargetIndicatorColorName

    -- Test mode
    if BetterBlizzPlatesDB.focusTargetIndicatorTestMode then
        frame.focusTargetIndicator:Show()
        if BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            if useCustomTexture then
                frame.healthBar:SetStatusBarTexture(customTexture)
            else
                frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
            end
        end
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            local color = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB or {1, 1, 1}
            frame.healthBar:SetStatusBarColor(unpack(color))
        else
            local exitLoop = true
            BBP.CompactUnitFrame_UpdateHealthColor(frame, exitLoop)
        end
        return
    end

    if UnitIsUnit(frame.unit, "focus") then
        frame.focusTargetIndicator:Show()
        if changeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            if useCustomTexture then
                frame.healthBar:SetStatusBarTexture(customTexture)
            else
                frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
            end
        end
        local shouldColorize = colorNp or colorName
        local color
        if shouldColorize then
            color = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB
        end
        if colorNp then
            frame.healthBar:SetStatusBarColor(unpack(color))
        end
        if colorName then
            frame.name:SetVertexColor(unpack(color))
        end
    else
        frame.focusTargetIndicator:Hide()
        if useCustomTexture then
            frame.healthBar:SetStatusBarTexture(customTexture)
        else
            frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
        end
        if colorName then
            BBP.ClassColorAndScaleNames(frame)
        end
    end
end

function BBP.ColorTargetNameplate(frame)
    local color = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB

    if UnitIsUnit(frame.unit, "target") then
        frame.healthBar:SetStatusBarColor(unpack(color))
    end
end

-- Event listener for Target Indicator
local frameTargetChanged = CreateFrame("Frame")
--frameTargetChanged:RegisterEvent("PLAYER_TARGET_CHANGED")
frameTargetChanged:SetScript("OnEvent", function(self, event)
    local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")

    local hideTotemHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar

    if previousTargetNameplate then
        BBP.CompactUnitFrame_UpdateHealthColor(previousTargetNameplate.UnitFrame)
        BBP.TargetIndicator(previousTargetNameplate.UnitFrame)
        BBP.ToggleNameplateAuras(previousTargetNameplate.UnitFrame)
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
            if previousTargetNameplate.UnitFrame then
                BBP.ApplyTotemIconsAndColorNameplate(previousTargetNameplate.UnitFrame, previousTargetNameplate.UnitFrame.unit)
            end
        end
        if previousTargetNameplate.UnitFrame and
        previousTargetNameplate.UnitFrame.classIndicator and
        previousTargetNameplate.UnitFrame.classIndicator.highlightSelect then
         previousTargetNameplate.UnitFrame.classIndicator.highlightSelect:Hide()
        end
--[[
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
]]
        

        previousTargetNameplate = nil
    end

    if nameplateForTarget then
        BBP.TargetIndicator(nameplateForTarget.UnitFrame)
        BBP.ToggleNameplateAuras(nameplateForTarget.UnitFrame)
        -- if nameplateForTarget.driverFrame then
        --     if nameplateForTarget.driverFrame.classNamePlateMechanicFrame then
        --         if BetterBlizzPlatesDB.hideResourceOnFriend then
        --             if not UnitCanAttack(nameplateForTarget.UnitFrame.unit, "player") then
        --                 nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(0)
        --             else
        --                 nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(1)
        --             end
        --         end
        --         local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
        --         nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)

        --         nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
        --         PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos);
        --     end
        -- end
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
        if nameplateForTarget.UnitFrame and nameplateForTarget.UnitFrame.classIndicator and nameplateForTarget.UnitFrame.classIndicator.highlightSelect then
            BBP.ClassIndicatorTargetHighlight(nameplateForTarget.UnitFrame)
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
        --BBP.ColorTargetNameplate(nameplateForTarget.UnitFrame)
        previousTargetNameplate = nameplateForTarget
    end
end)


-- Toggle event listener for Target Indicator on/off
function BBP.ToggleTargetIndicator(value)
    if BetterBlizzPlatesDB.targetIndicator or BetterBlizzPlatesDB.fadeOutNPC or BetterBlizzPlatesDB.hideNPC or BetterBlizzPlatesDB.hideResourceOnFriend then
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
--frameFocusTargetChanged:RegisterEvent("PLAYER_FOCUS_CHANGED")
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

local nameplateResourceHooked
local nameplateResourceOnTarget
local nameplateShowSelf
local notifiedUser
local nameplateResourceUnderCastbar
local nameplateResourceUnderCastbarEventFrame



-- Function to update the position based on casting state and settings
function BBP.UpdateNamplateResourcePositionForCasting(nameplate, bypass)
    if nameplate and nameplate.UnitFrame and nameplate.driverFrame and nameplate.driverFrame.classNamePlateMechanicFrame then
        local yOffset = BetterBlizzPlatesDB.nameplateResourceYPos
        local xPos = BetterBlizzPlatesDB.nameplateResourceXPos or 0
        local isCasting = UnitCastingInfo("target") or UnitChannelInfo("target")

        -- Adjust position based on casting state and setting
        if bypass then
            PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset - 10)
        elseif isCasting then
            PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.castBar, "BOTTOM", xPos, yOffset - 10)
        elseif not isCasting then
            if not nameplate.UnitFrame.castBar:IsShown() then
                PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset - 10)
            else
                PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.castBar, "BOTTOM", xPos, yOffset - 10)
            end
        end
    end
end

function BBP.TargetResourceUpdater()
    nameplateResourceOnTarget = BetterBlizzPlatesDB.nameplateResourceOnTarget == 1 or BetterBlizzPlatesDB.nameplateResourceOnTarget == true
    nameplateShowSelf = GetCVarBool("nameplateShowSelf")
    nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar

    if nameplateResourceOnTarget and not nameplateShowSelf then
        local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
        local inInstance, instanceType = IsInInstance()
        if not (inInstance and (instanceType == "raid" or instanceType == "party" or instanceType == "scenario")) then
            if nameplateForTarget and nameplateForTarget.driverFrame then
                local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
                nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)

                if BetterBlizzPlatesDB.hideResourceOnFriend then
                    if not UnitCanAttack(nameplateForTarget.UnitFrame.unit, "player") then
                        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(0)
                    else
                        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(1)
                    end
                end

                nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetParent(nameplateForTarget)
                nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
                if nameplateResourceUnderCastbar then
                    BBP.UpdateNamplateResourcePositionForCasting(nameplateForTarget)
                else
                    PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos);
                end
            end
        end
    elseif nameplateShowSelf then
        local nameplatePlayer = C_NamePlate.GetNamePlateForUnit("player")
        if nameplatePlayer and nameplatePlayer.driverFrame then
            local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
            nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)

            nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetParent(nameplatePlayer)
            nameplatePlayer.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
            local padding = nameplatePlayer.driverFrame.classNamePlateMechanicFrame.paddingOverride or 0
            PixelUtil.SetPoint(nameplatePlayer.driverFrame.classNamePlateMechanicFrame, "TOP", nameplatePlayer.driverFrame.classNamePlatePowerBar, "BOTTOM", BetterBlizzPlatesDB.nameplateResourceXPos, padding + BetterBlizzPlatesDB.nameplateResourceYPos or -4 + BetterBlizzPlatesDB.nameplateResourceYPos)
        end
    end


    -- hook

    if not nameplateResourceHooked and (nameplateShowSelf or nameplateResourceOnTarget) then
        hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", function(self)
            if self.classNamePlateMechanicFrame then --after entering an instance classNamePlateMechanicFrame becomes, and stays forbidden even when you leave the instance. not sure if there is a workaround.
                if self.classNamePlateMechanicFrame:IsForbidden() then
                    if not notifiedUser and nameplateResourceOnTarget then
                        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Nameplate resource frame (combo points etc) is not allowed to be repositioned in PvE content. In order to restore functionality /reload ui outside of instance.")
                        notifiedUser = true
                    end
                    return
                end
                if nameplateResourceOnTarget then
                    local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
                    if nameplateForTarget then--and nameplateForTarget.driverFrame then
                        --if UnitIsFriend(nameplateForTarget.UnitFrame.unit, "player") then print("kek") return end
                        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetParent(nameplateForTarget)
                        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
                        if nameplateResourceUnderCastbar then
                            BBP.UpdateNamplateResourcePositionForCasting(nameplateForTarget)
                        else
                            PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos);
                        end
                        --nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetPoint()
                        local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
                        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)
                    end
                else
                    local nameplatePlayer = C_NamePlate.GetNamePlateForUnit("player")
                    if nameplatePlayer and nameplatePlayer.driverFrame then
                        nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetParent(nameplatePlayer)
                        nameplatePlayer.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();

                        local padding = nameplatePlayer.driverFrame.classNamePlateMechanicFrame.paddingOverride or 0
                        PixelUtil.SetPoint(nameplatePlayer.driverFrame.classNamePlateMechanicFrame, "TOP", nameplatePlayer.driverFrame.classNamePlatePowerBar, "BOTTOM", BetterBlizzPlatesDB.nameplateResourceXPos, padding + BetterBlizzPlatesDB.nameplateResourceYPos or -4 + BetterBlizzPlatesDB.nameplateResourceYPos)

                        local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
                        nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)
                    end
                end
            end
        end)
        nameplateResourceHooked = true
    end
end





-- Function to handle event registration and updates
function BBP.RegisterTargetCastingEvents()
    nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar
    nameplateResourceOnTarget = BetterBlizzPlatesDB.nameplateResourceOnTarget == 1 or BetterBlizzPlatesDB.nameplateResourceOnTarget == true

    if not nameplateResourceUnderCastbarEventFrame then
        nameplateResourceUnderCastbarEventFrame = CreateFrame("Frame")
    end

    -- Always unregister all events first to ensure a clean state
    nameplateResourceUnderCastbarEventFrame:UnregisterAllEvents()

    if nameplateResourceUnderCastbar and nameplateResourceOnTarget then
        -- Register events if both conditions are met
        nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
        nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
        nameplateResourceUnderCastbarEventFrame:SetScript("OnEvent", function(_, event, unit)
            local nameplate = C_NamePlate.GetNamePlateForUnit("target")
            if nameplate then
                BBP.UpdateNamplateResourcePositionForCasting(nameplate)
            end
        end)
    end

    local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
    if nameplateForTarget then
        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetParent(nameplateForTarget)
        nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints()
        if nameplateResourceUnderCastbar then
            BBP.UpdateNamplateResourcePositionForCasting(nameplateForTarget)
        else
            PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos)
        end
    end
end