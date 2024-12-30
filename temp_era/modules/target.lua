local LSM = LibStub("LibSharedMedia-3.0")

BBP.previousTargetNameplate = nil
BBP.previousFocusNameplate = nil

local function GetRotationForAnchor(anchorPoint)
    local rotation = 0 -- Default rotation

    if anchorPoint == "TOP" then
        rotation = math.rad(180)
    elseif anchorPoint == "BOTTOM" then
        rotation = math.rad(0)
    elseif anchorPoint == "LEFT" then
        rotation = math.rad(-90)
    elseif anchorPoint == "RIGHT" then
        rotation = math.rad(90)
    elseif anchorPoint == "TOPLEFT" then
        rotation = math.rad(225)
    elseif anchorPoint == "TOPRIGHT" then
        rotation = math.rad(-225)
    elseif anchorPoint == "BOTTOMLEFT" then
        rotation = math.rad(-45)
    elseif anchorPoint == "BOTTOMRIGHT" then
        rotation = math.rad(45)
    end

    return rotation
end

-- Target Indicator
function BBP.TargetIndicator(frame)
    --if not frame or not frame.unit then return end
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    -- Initialize
    if not frame.targetIndicator then
        frame.targetIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.targetIndicator:SetSize(18, 13)
        frame.targetIndicator:SetTexture(BBP.targetIndicatorIconReplacement)
        frame.targetIndicator:Hide()
        frame.targetIndicator:SetDrawLayer("OVERLAY", 7)
        frame.targetIndicator:SetVertexColor(1,1,1)
    end

    if not config.targetIndicatorInitialized or BBP.needsUpdate then
        config.targetIndicatorAnchor = BetterBlizzPlatesDB.targetIndicatorAnchor
        config.targetIndicatorXPos = BetterBlizzPlatesDB.targetIndicatorXPos
        config.targetIndicatorYPos = BetterBlizzPlatesDB.targetIndicatorYPos
        config.targetIndicatorScale = BetterBlizzPlatesDB.targetIndicatorScale

        config.targetIndicatorHideIcon = BetterBlizzPlatesDB.targetIndicatorHideIcon
        config.targetIndicatorColorNameplate = BetterBlizzPlatesDB.targetIndicatorColorNameplate
        config.targetIndicatorColorName = BetterBlizzPlatesDB.targetIndicatorColorName
        config.targetIndicatorRotation = GetRotationForAnchor(config.targetIndicatorAnchor)
        config.targetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        config.targetIndicatorChangeTexture = BetterBlizzPlatesDB.targetIndicatorChangeTexture
        if config.targetIndicatorChangeTexture then
            local targetIndicatorTexture = BetterBlizzPlatesDB.targetIndicatorTexture
            config.targetIndicatorTextureLSM = LSM:Fetch(LSM.MediaType.STATUSBAR, targetIndicatorTexture)
        end

        frame.targetIndicator:SetPoint("CENTER", frame.healthBar, config.targetIndicatorAnchor, config.targetIndicatorXPos, config.targetIndicatorYPos)
        --frame.targetIndicator:SetPoint("CENTER", frame, config.targetIndicatorAnchor, config.targetIndicatorXPos, config.targetIndicatorYPos-17)
        frame.targetIndicator:SetScale( config.targetIndicatorScale)
        frame.targetIndicator:SetRotation(config.targetIndicatorRotation)

        config.targetIndicatorInitialized = true
    end

    if info and info.isSelf then
        BBP.ApplyCustomTextureToNameplate(frame)
        if frame.targetIndicator then
            frame.targetIndicator:Hide()
        end
        --return
    end

    -- Show or hide Target Indicator
    if UnitIsUnit(frame.unit, "target") then
        if not config.targetIndicatorHideIcon then
            frame.targetIndicator:Show()
        end
        if config.targetIndicatorChangeTexture then
            frame.healthBar:SetStatusBarTexture(config.targetIndicatorTextureLSM)
        else
            if config.targetIndicatorChangeTexture then
                BBP.ApplyCustomTextureToNameplate(frame)
            end
        end
        local shouldColorize = config.targetIndicatorColorNameplate or config.targetIndicatorColorName
        local color
        if shouldColorize then
            color = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        end
        if config.targetIndicatorColorNameplate then
            frame.healthBar:SetStatusBarColor(unpack(color))
        end
        if config.targetIndicatorColorName then
            frame.name:SetVertexColor(unpack(color))
        end
    else
        frame.targetIndicator:Hide()
        if config.targetIndicatorChangeTexture then
            BBP.ApplyCustomTextureToNameplate(frame)
        end
    end
end

-- Focus Target Indicator
function BBP.FocusTargetIndicator(frame)
    --if not frame or frame.unit then return end
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    if not config.focusTargetIndicatorInitialized or BBP.needsUpdate then
        config.focusTargetIndicatorTestMode = BetterBlizzPlatesDB.focusTargetIndicatorTestMode
        config.focusTargetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB

        config.focusTargetIndicatorInitialized = true
    end

    local focusTextureName = BetterBlizzPlatesDB.focusTargetIndicatorTexture
    local focusTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, focusTextureName)
    local textureName = BetterBlizzPlatesDB.customTexture
    local customTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)

    local changeTexture = BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture
    local colorNp = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate
    local colorName = BetterBlizzPlatesDB.focusTargetIndicatorColorName

    -- if info.isSelf then
    --     BBP.ApplyCustomTextureToNameplate(frame)
    --     if frame.focusTargetIndicator then
    --         frame.focusTargetIndicator:Hide()
    --     end
    --     return
    -- end

    local anchorPoint = BetterBlizzPlatesDB.focusTargetIndicatorAnchor or "TOP"
    local xPos = BetterBlizzPlatesDB.focusTargetIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.focusTargetIndicatorYPos or 0
    local dbScale = BetterBlizzPlatesDB.focusTargetIndicatorScale or 1
    local useCustomTexture = BetterBlizzPlatesDB.useCustomTextureForBars

    -- Initialize
    if not frame.focusTargetIndicator then
        frame.focusTargetIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.focusTargetIndicator:SetSize(22, 22)
        frame.focusTargetIndicator:SetTexture(BBP.focusIndicatorIconReplacement)
        frame.focusTargetIndicator:Hide()
        frame.focusTargetIndicator:SetDrawLayer("OVERLAY", 7)
        frame.focusTargetIndicator:SetVertexColor(1, 1, 1)
    end

    if BetterBlizzPlatesDB.classicNameplates then
        frame.focusTargetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos+9, yPos-4)
    else
        frame.focusTargetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    end
    frame.focusTargetIndicator:SetScale(dbScale)

    -- Test mode
    if config.focusTargetIndicatorTestMode then
        frame.focusTargetIndicator:Show()
        if BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            BBP.ApplyCustomTextureToNameplate(frame)
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

    if info and info.isFocus then
        frame.focusTargetIndicator:Show()
        frame.LevelFrame:Hide()
        if changeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            BBP.ApplyCustomTextureToNameplate(frame)
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
        frame.LevelFrame:Show()
        if BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture then
            BBP.ApplyCustomTextureToNameplate(frame)
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

local nameplateResourceHooked
local nameplateResourceOnTarget
local nameplateShowSelf
local notifiedUser
local nameplateResourceUnderCastbar
local nameplateResourceUnderCastbarEventFrame

local classResourceYOffsets = {
    PALADIN = 4,
    DEATHKNIGHT = -3,
    MAGE = -4,
    MONK = -4,
    DRUID = -4,
    ROGUE = -4,
    WARLOCK = 2,
    EVOKER = -1,
}
local playerClass = select(2, UnitClass("player"))

-- Function to update the position based on casting state and settings
function BBP.UpdateNameplateResourcePositionForCasting(nameplate, bypass)
    if not GetCVarBool("nameplateResourceOnTarget") then return end
    if nameplate and nameplate.UnitFrame and nameplate.driverFrame and nameplate.driverFrame.classNamePlateMechanicFrame then
        if nameplate.driverFrame.classNamePlateMechanicFrame:IsForbidden() then return end
        local yOffset = BetterBlizzPlatesDB.nameplateResourceYPos
        local xPos = BetterBlizzPlatesDB.nameplateResourceXPos or 0
        local isCasting = UnitCastingInfo("target") or UnitChannelInfo("target")

        local classOffset = classResourceYOffsets[playerClass] or 0

        -- Adjust position based on casting state and setting
        nameplate.driverFrame.classNamePlateMechanicFrame:ClearAllPoints()
        if bypass then
            PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset + classOffset)
        elseif isCasting then
            PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.Unitframe.CastBar, "BOTTOM", xPos, yOffset + classOffset)
        else
            if not nameplate.Unitframe.CastBar:IsShown() then
                PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset + classOffset)
            else
                PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.Unitframe.CastBar, "BOTTOM", xPos, yOffset + classOffset)
            end
        end
    end
end

local classPadding = {
    ["MONK"] = -8,
    ["EVOKER"] = -9,
    ["WARLOCK"] = -8
}

local adjusted
function BBP.TargetResourceUpdater()
    -- local _, className = UnitClass("player")
    -- nameplateResourceOnTarget = BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true
    -- nameplateShowSelf = GetCVarBool("nameplateShowSelf")
    -- nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar

    -- if nameplateResourceOnTarget and not nameplateShowSelf then
    --     local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
    --     local inInstance, instanceType = IsInInstance()
    --     if not (inInstance and (instanceType == "raid" or instanceType == "party" or instanceType == "scenario")) then
    --         if nameplateForTarget and nameplateForTarget.driverFrame then
    --             local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
    --             nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)

    --             if BetterBlizzPlatesDB.hideResourceOnFriend then
    --                 if not UnitCanAttack(nameplateForTarget.UnitFrame.unit, "player") then
    --                     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(0)
    --                 else
    --                     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(1)
    --                 end
    --             end

    --             nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetParent(nameplateForTarget)
    --             nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
    --             if nameplateResourceUnderCastbar then
    --                 BBP.UpdateNameplateResourcePositionForCasting(nameplateForTarget)
    --             else
    --                 PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos);
    --             end
    --         end
    --     end
    -- elseif nameplateShowSelf then
    --     local nameplatePlayer = C_NamePlate.GetNamePlateForUnit("player")
    --     if nameplatePlayer and nameplatePlayer.driverFrame then
    --         local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
    --         nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)

    --         nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetParent(nameplatePlayer)
    --         nameplatePlayer.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
    --         local padding = nameplatePlayer.driverFrame.classNamePlateMechanicFrame.paddingOverride or 0
    --         PixelUtil.SetPoint(nameplatePlayer.driverFrame.classNamePlateMechanicFrame, "TOP", nameplatePlayer.driverFrame.classNamePlatePowerBar, "BOTTOM", BetterBlizzPlatesDB.nameplateResourceXPos, padding + BetterBlizzPlatesDB.nameplateResourceYPos or -4 + BetterBlizzPlatesDB.nameplateResourceYPos)
    --     end
    -- end


    -- -- hook

    -- if not nameplateResourceHooked and (nameplateShowSelf or nameplateResourceOnTarget) then
    --     hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", function(self)
    --         if self.classNamePlateMechanicFrame then --after entering an instance classNamePlateMechanicFrame becomes, and stays forbidden even when you leave the instance. not sure if there is a workaround.
    --             if self.classNamePlateMechanicFrame:IsForbidden() then
    --                 if not notifiedUser and nameplateResourceOnTarget then
    --                     DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Nameplate resource frame (combo points etc) is not allowed to be repositioned in PvE content. In order to restore functionality /reload ui outside of instance.")
    --                     notifiedUser = true
    --                 end
    --                 return
    --             end
    --             if nameplateResourceOnTarget then
    --                 local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
    --                 if nameplateForTarget then--and nameplateForTarget.driverFrame then
    --                     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetParent(nameplateForTarget)
    --                     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();
    --                     if nameplateResourceUnderCastbar then
    --                         BBP.UpdateNameplateResourcePositionForCasting(nameplateForTarget)
    --                     else
    --                         PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos);
    --                     end
    --                     --nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetPoint()
    --                     local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
    --                     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)

    --                     if BetterBlizzPlatesDB.hideResourceOnFriend then
    --                         local info = nameplateForTarget.UnitFrame.BetterBlizzPlates.unitInfo
    --                         if info.isFriend then
    --                             nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(0)
    --                             adjusted = true
    --                         else
    --                             nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(1)
    --                         end
    --                     elseif adjusted then
    --                         nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetAlpha(1)
    --                         adjusted = nil
    --                     end
    --                 end
    --             else
    --                 local nameplatePlayer = C_NamePlate.GetNamePlateForUnit("player")
    --                 if nameplatePlayer and nameplatePlayer.driverFrame then
    --                     nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetParent(nameplatePlayer)
    --                     nameplatePlayer.driverFrame.classNamePlateMechanicFrame:ClearAllPoints();

    --                     local padding = nameplatePlayer.driverFrame.classNamePlateMechanicFrame.paddingOverride or classPadding[className] or 0
    --                     PixelUtil.SetPoint(nameplatePlayer.driverFrame.classNamePlateMechanicFrame, "TOP", nameplatePlayer.driverFrame.classNamePlatePowerBar, "BOTTOM", BetterBlizzPlatesDB.nameplateResourceXPos, padding + BetterBlizzPlatesDB.nameplateResourceYPos or -4 + BetterBlizzPlatesDB.nameplateResourceYPos)

    --                     local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
    --                     nameplatePlayer.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)
    --                 end
    --             end
    --         end
    --     end)
    --     nameplateResourceHooked = true
    -- end
end





-- Function to handle event registration and updates
function BBP.RegisterTargetCastingEvents()
    -- nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar
    -- nameplateResourceOnTarget = BetterBlizzPlatesDB.nameplateResourceOnTarget == "1"

    -- if not nameplateResourceUnderCastbarEventFrame then
    --     nameplateResourceUnderCastbarEventFrame = CreateFrame("Frame")
    -- end

    -- -- Always unregister all events first to ensure a clean state
    -- nameplateResourceUnderCastbarEventFrame:UnregisterAllEvents()

    -- if nameplateResourceUnderCastbar and nameplateResourceOnTarget then
    --     -- Register events if both conditions are met
    --     nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
    --     nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
    --     nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "target")
    --     nameplateResourceUnderCastbarEventFrame:SetScript("OnEvent", function(_, event, unit)
    --         local nameplate = C_NamePlate.GetNamePlateForUnit("target")
    --         if nameplate then
    --             BBP.UpdateNameplateResourcePositionForCasting(nameplate)
    --         end
    --     end)
    -- end

    -- local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
    -- if nameplateForTarget then
    --     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:SetParent(nameplateForTarget)
    --     nameplateForTarget.driverFrame.classNamePlateMechanicFrame:ClearAllPoints()
    --     if nameplateResourceUnderCastbar then
    --         BBP.UpdateNameplateResourcePositionForCasting(nameplateForTarget)
    --     else
    --         PixelUtil.SetPoint(nameplateForTarget.driverFrame.classNamePlateMechanicFrame, "BOTTOM", nameplateForTarget.UnitFrame.name, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos)
    --     end
    -- end
end


























function BBP.FadeAllButTargetNameplates()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        local config = frame.BetterBlizzPlates.config or BBP.InitializeNameplateSettings
        if UnitExists("target") and not UnitIsPlayer(frame.unit) then
            if not UnitIsUnit(frame.unit, "target") and not UnitIsUnit(frame.unit, "player") then
                frame:SetAlpha(config.fadeOutNPCsAlpha)
            else
                frame:SetAlpha(1)
            end
        else
            frame:SetAlpha(1)
        end
    end
end

function BBP.UnfadeAllNameplates()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        frame:SetAlpha(1)
    end
end






local PlayerTargetChanged = CreateFrame("Frame")
PlayerTargetChanged:RegisterEvent("PLAYER_TARGET_CHANGED")
PlayerTargetChanged:SetScript("OnEvent", function(self, event)
    local targetNameplate, frame = BBP.GetSafeNameplate("target")

    -- LAST TARGET NAMEPLATE
    if BBP.previousTargetNameplate then
        local frame = BBP.previousTargetNameplate

        if frame.unit then
            local config = frame.BetterBlizzPlates.config
            local info = frame.BetterBlizzPlates.unitInfo
            frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)


            if config.changeNameplateBorderColor then
                BBP.ColorNameplateBorder(frame)
            else
                if not BetterBlizzPlatesDB.classicNameplates then
                    if frame.healthBar.SetBorderColor then
                        frame.healthBar:SetBorderColor(0,0,0,1)
                    end
                end
            end

            if BetterBlizzPlatesDB.changeNameplateBorderSize then
                if frame.healthBar.SetBorderSize then
                    frame.healthBar:SetBorderSize(BetterBlizzPlatesDB.nameplateBorderSize)
                end
            end

            if config.healthNumbersTargetOnly then
                BBP.HealthNumbers(frame)
            end

            -- info.isTarget = false
            -- info.wasTarget = true

            -- Reset nameplate color
            if config.totemIndicator or
            config.targetIndicatorColorNameplate or
            config.focusTargetIndicatorColorNameplate or
            config.auraColor or config.colorNPC then
                BBP.CompactUnitFrame_UpdateHealthColor(frame)
            end

            if config.targetIndicator then
                BBP.TargetIndicator(frame)
            end
            if config.focusTargetIndicator then BBP.FocusTargetIndicator(frame) end
            if config.partyPointer then BBP.PartyPointer(frame) end
            if config.fadeOutNPC then
                BBP.FadeOutNPCs(frame)
                if config.fadeAllButTarget then
                    BBP.UnfadeAllNameplates()
                end
            end
            if config.hideNPC then BBP.HideNPCs(frame, BBP.previousTargetNameplate:GetParent()) end
            if config.totemIndicator then
                --if config.totemIndicatorHideHealthBar then BBP.ApplyTotemIconsAndColorNameplate(frame) end
                BBP.ApplyTotemIconsAndColorNameplate(frame)
            end
            if (config.classIndicator and (config.classIndicatorHighlight or config.classIndicatorHighlightColor)) then
                if frame.classIndicator and frame.classIndicator.highlightSelect then
                    frame.classIndicator.highlightSelect:Hide()
                end
            end

            if config.petIndicatorOnlyShowMainPet then
                BBP.PetIndicator(frame)
            end

            BBP.ToggleNameplateAuras(frame)
            BBP.TargetNameplateAuraSize(frame)
        end

        BBP.previousTargetNameplate = nil
    end

    -- CURRENT TARGET NAMEPLATE
    if frame then
        local config = frame.BetterBlizzPlates.config
        --local info = frame.BetterBlizzPlates.unitInfo
        frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
        --local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)
        --if not info then return end

        -- info.isTarget = true
        -- info.wasTarget = nil
        if not UnitIsUnit(frame.unit, "player") then
        --if not info.isSelf then

            if config.changeNameplateBorderColor then
                BBP.ColorNameplateBorder(frame)
            else
                if not BetterBlizzPlatesDB.classicNameplates then
                    if frame.healthBar.SetBorderColor then
                        frame.healthBar:SetBorderColor(1,1,1,1)
                    end
                end
            end
            BBP.ToggleNameplateAuras(frame)
            BBP.TargetNameplateAuraSize(frame)
            if config.targetIndicator then BBP.TargetIndicator(frame) end
            if config.partyPointer then BBP.PartyPointer(frame) end

            if config.fadeOutNPC then
                BBP.FadeOutNPCs(frame)
                if config.fadeAllButTarget then
                    BBP.FadeAllButTargetNameplates()
                end
            end

            if config.healthNumbersTargetOnly then
                BBP.HealthNumbers(frame)
            end

            if config.hideNPC then BBP.HideNPCs(frame, targetNameplate) end

            if config.totemIndicator then
                --if config.totemIndicatorHideHealthBar then BBP.ApplyTotemIconsAndColorNameplate(frame) end
                -- local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)
                -- local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID]
                -- if config.totemIndicatorHideHealthBar
                BBP.ApplyTotemIconsAndColorNameplate(frame)
            end

            if (config.classIndicator and (config.classIndicatorHighlight or config.classIndicatorHighlightColor)) then BBP.ClassIndicatorTargetHighlight(frame) end

            if config.showCastbarIfTarget then BBP.HideCastbar(frame, frame.unit) end

            if config.petIndicatorOnlyShowMainPet then
                BBP.PetIndicator(frame)
            end

            if BetterBlizzPlatesDB.changeNameplateBorderSize then
                if frame.healthBar.SetBorderSize then
                    frame.healthBar:SetBorderSize(BetterBlizzPlatesDB.nameplateTargetBorderSize)
                end
            end
        end
        BBP.previousTargetNameplate = frame
    end
end)


-- Event listener for Focus Target Indicator
local PlayerFocusChanged = CreateFrame("Frame")
PlayerFocusChanged:RegisterEvent("PLAYER_FOCUS_CHANGED")
PlayerFocusChanged:SetScript("OnEvent", function(self, event)
    local focusNameplate, frame = BBP.GetSafeNameplate("focus")

    -- PREVIOUS FOCUS NAMEPLATE
    if BBP.previousFocusNameplate then
        local frame = BBP.previousFocusNameplate
        local config = frame.BetterBlizzPlates.config
        --local info = frame.BetterBlizzPlates.unitInfo
        frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
        local info = frame.BetterBlizzPlates.unitInfo
        -- info.isFocus = false
        -- info.wasFocus = true
        if config.focusTargetIndicator then
            BBP.FocusTargetIndicator(frame)
            --BBP.ApplyCustomTextureToNameplate(frame)
        end
        BBP.CompactUnitFrame_UpdateHealthColor(frame)

        BBP.previousFocusNameplate = nil
    end

    -- CURRENT FOCUS NAMEPLATE
    if frame then
        local config = frame.BetterBlizzPlates.config
        frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
        -- local info = frame.BetterBlizzPlates.unitInfo
        -- info.isFocus = true
        -- info.wasFocus = nil
        local info = frame.BetterBlizzPlates.unitInfo
        if config.focusTargetIndicator then BBP.FocusTargetIndicator(frame) end
        BBP.previousFocusNameplate = frame
    end
end)


BBP.tempComboPointWA = "!WA:2!TZ3c4TT119BygxhZK0iPKyVO42WQu7iLyjBsAlhjxxx(uI2uK0GuwwoXJeKaIarGaWaG6HxB)VOLM5(VBDlAzj7rFQ0LTMM2UY02T(911T5TU9TSUTt16646E7TLTUU1TQ9(9o3la4djslBhfn3Vy99riGlU4I79C(D(Do3h4YCQUmYFOb8EWb82vPU47I)c37Y55kmnVUQwivzv9J7YLRuUoWahsRRcQkM6QYYc8HeLK51fuEuTDnbNUSAHPzfmulRxqyypPf505n06oSaNP4juKkkAw)MSLvem0Upw1ILfcOWhwVSeF97gsTuEvpPuLumn0UNu6scgMnvW8QZ6jPEEYn5K54LuQF3rvLNhF0zf016mdNErbZuYCM4lPGOQ(LYRQZlOh0UHP1rqzPZFESE6jJQQSPKgRrbozbxlzQwygbDdjvLB(9d5TEkXLS(Fe(IcADM(CL50f8eTSSSNjeLmfwsxOiM)mZRjWwuxTSMD2tlDEHTXYjRjY5QIvswcugggx6ZLCQPmemz0N35eUcMyXymiRHjNUP78tjPizi6oi(pt3lyQlvSiwZ6EV62N(elXlKV8utrEX6JgjEQOJhpOjPwWvwNZ3cgAcYYX4nCFjJY5fMrqXmnMBP5QKnuG0zYMota2mblJfEEnzU5f0zv4kjy4MLM18JkWjBkw7rtPlGpkB6urIhFXYk2vb3v4OIxQglFOijYeH9IwnvRw1owMRSjMHKA02M7f5uKkXroFq4UJErbodH0MioQOP42bpbvuvewMhR9KCKL0w0nequhVXcKSsAPG)GL4KuIc(Wha8dheoemi()UxDk9iXRDxjWMKgbg4GtcXzYfuwLJpAEtuHRyUt2sLraG7GO4QWoHJ4MTGmNHb5SGgOgKCsLP0XYbRO4d7AfRMCussKku(0HyJejXkOeqqxHt(uwWNNXwLhtbfdUw0qqEkQucgyjuMYsHmgUZJnUPKk6EjsJuYsgvrszkvDlPKBFO9rLjtDUYPvIFGzkEWUk8H8CHJSiNEH4uP2JVtW1WSPvll7LE0h9OFWnCl5NLROASWlo4u(8kh5edEC4aUHDnj0VVmjtTIHQU5OZNxxIpdxEzHbHeIWyIqCr4UOa0f0vNnTgxbbx(kRlRTBrttnJH3)(jf6asQ7VwPUFFdcFhO20nCpUHUDd7U79cVHNaEJW9IAJ3e0JB4(G3m8aWdc3VBOxOpypWEH95Usbv5YLuSEf51rB5Ygp(TcHHbqtgPIk4)ni3BBGxcuHQzrfSJ6(WRjLUxtk7KrhnLi4ugDBJ6dbrCdHCbrDddffgMOCH3c94rPhFRKJADu2WM3iLG(4OfIiS1A0G51qZFup(q5Tqu5LkPHYYflIIYjK4nfVf4wDTubbcCGGp6jol86f16Obyd9G29mHa30bqWUXWRHVc68I8ZJ2JsfOmkWDSnwzPssM3YIgMcAbukklCVbjQqSzENUGBh64siccBTkMrrEev98SbchB80bXhF2LgnjBSZKmrMaXH9VJ8gcLqPrEVdCGb8Di42qEo0ubUjDlttbr4yUG3wL0rIhjuMOSbglYcKMgTPWggIvXRw05mnoX5gBcVlGcQ4K6L4stH8HHK0lilKdc(mWiUHrDJyitkmM5chlpMv9SZZy9)5yqTtfo(hTm2E4hJBUTc7Izfe2lqAVk81884QIbXotyoZY6yvldmEtGneUGSGgCMeod8(MmbNcDsP1ruDPZ75KL54j2SEYKjFbK2p78PUPdmWb9UIPv5nHoN2yQ8cA3zO4bglvMKbJhi0jceoCSmXovKLO8WuznJfKWU6IvyjfrOtD7Izr0(rHNuqSbJhjr4fnKr9a568XsKow4iWcADA7MS)OsYYupKujpr5fRsVZE4H6DMKEpDWX16G481siyrHUnijKITqDbsnPMKYw1UZ6T(G1EqXgtoAnHQiS73lAB(YODYEigLxsJ4TmRkYYYHqMU75TE0fXMzwAY5GEzPEtjMUS0K6URdSi9ecX8TJw2e1FwIhKCuJ6739Y1ECswYrjbqtDEjJhTSc6EBgbFCkZJbsGna1szSCIexTOuHEC7wRtoAwStMi)EHTSakzPQaKOl4ZCjnD1I6cggPPMEpWU3YwV2PhEyKmO7DcEwg5JRl0ZlkqIyP)8uSRG4Q18CZjUabIr8UF3W3jKnFjjDDvDr4SWnryy7hgag5b2lBbrHcthfEdU6rvRR3YcZWPlriAHNKDgo5YcD5vVGiNsrb0Jo8SAD5GpIusZCEkazbSXQrKKWc7f(W2LeQJGLGNeE2U8cFKMFswboERNeEoyHvQ3KSmMOKxR6GwN1n5STX02viI)VKifbgvq)0iYSCCjdL06SEP6K)7Pn5VFe(siwItiBjukqayONGcWOEyZfeJ4rWcYmJGOeYCmUKOfNCLgsu0HGEV5nKiib9jcWgpzOtuJVMDwcT79PlPqy5feVij(hwhQNkQyyKkwxO1vDQWSXsCQiSPJyXmmNfZaH0QGAjncgt8chdkZaZqOQGzjeuWCulqy(wsebNNW)aFxWBhEh2L27e()bF3mWJHKfWcW3d84W7cEc8SV3gm(pVOV5gCQIHND(yW7MASd))TEnVNTcFFIW3)QnBH3lXsf(bqlu4hK6y9jrltyrIfj8d5ykcpLJ5h8ddpn8mObg8J8cBb(rPgsWp2gJTd8JdVV(H3Vi8beHpi1Ca(qR2sOg2TR3In01Nf0f(jia1wHTDYWpjjdWpvlXUWhfEEcMe(yWlqWzJ1eod(45GpHB4tAdOGF66Wi4tbvQHDGx8(GpTi8zyGpl8Za)S1qbWNBts9hT3jvkxA8zInX0Vwr97F9u)(Vgu)j2Wv)7fC9sxe7RGkpTxRE8UsJx4ju4gVPVgVPpYnJQRAy68KnEXQUPVgVj5jxECfrsFzTYTwhnD5QVVVMVp55jX(tXrNfEiyxpmQhoPDm9Rb2EfgRobXqq4pmn852h4CdrjtXc3QlmYxipuaX)DHXWsqf7FhuTMtyNBJyDrvBQx7WXyv0h64cro50E9DAVKGHTdXNee6oRGU4kieH0jwJCOn3fgyjjmwzRii29wwLfhALJ42LlOQkZRoRs6zL0Sc7mi5HYb7(1JsSVknWhDuGNZXQuRtssffue0LkKwuD2KyM7vRt6GG4XAuqOQiIjkraJYAu4gKuiUwUPNBjd8FbKNLBEdIAW2kMy8wZW1MUHOpgMAgEHU1EJKOrZspy19XSAznLkjyFfJ2DVMmyyFc4FXA3RN9OP5PDfvjv(SKykZDj6nR1P2GbgptsT7GMi2HFvsNxlq7muWa4LRyvusZjy1dPht7n3U3GSqrUcZNDk0ysx8I0mqc9sAQ5Xi9TcjJe4rWejter7n1Usb9FxqI0FpxGhDm8osww2QdyN2E4wwI(y1dREr7Ibd05TR1LvZJoEtopqtjoPDIw1WzW3fgAN4Y0RMf73pPNflmH9jlxROPdvtYXZepgw77WsCvFauqCN1voLUDwSEL1h7O6LhniuT(ANyWUlKznfX4zqsc(5BbiqZ(ewYJW)YlxuwD2O6cNRSGsbA)LWojsfIKBCreLpISDLrCbssK20Y5lBAQQyheiTiYGbVnTcggLRkKlDAslw05PPs9lsUmS9a(yLZAkiYfwdYXDfKCUi9ztthNo6PXLWYVtA(cAnqDW7Zpm0ttJXurygscRI(hDl8jf1UdsgKkQGX(sgGimWz5sIuxdvchjqMrprIyJmAM60AO3nKo7IoKcKXbmNLx9V0cojsC7TTvMwa7DozKKmzjnjrcJhse1iNlXb1XCf88QQLyAIk8ZR1fwVczxEy3FyjwAKOeEr)A3PZ7HG(dlzq6kbFoK5RyK(M0C2thy8ehK4jB2xbE1hb9g8HheDgdlvrYGYCrzSEwxw(JrYYNdEjKsf(1Yb78T76cJqcq6LWKXGKiJT0OFHVYwi)DemsPrp2Z3n5VJT2tWiOYrDf9LYvLz7IRk4PHE6QmBT1kUQmUSutvzUP6AN3jlT37orATItFeT7DUtCxvzCNZoUlcQ(WhI41VvrC9RJVNTLJg4fLSh(nQXYd)MKOU(TAMdhaxWx(sguUBhT3QiU34J6Apeq5htBWyKHzAkSJupsaEEvfJhP2Gk9i0EVtpDmbEjUhXkvYr)uVZiUedwlV2oRpoungGJTE2jMOpNiSZrFRFtQ(9PQfHl65TWiXlioAOrsnbjeqIFC0qGGdjyB0xkbA)ZHi(Qm7ih8I7PTHZPD4MAljBQTy1cS7YPXJynqtztxsv1uKa7RBGTtDE1Su6c4ZUCGezIfI0xXjILocgoqvMxhQCVzMlmaf22kx)O63gBEfR(3g8LHLVkCvd)2mWxb1N)oOVw4RMd(DHQWVh81GF)hd(deH)q8b(JG)y4pb9Db)PWLyG)mRQ4FoAC8xWaVmd8xkc)vWxh(RHVb83G5(VLb(MwX393D3WF)8W3cw5LH)bhQB4Fe(NeH)z4Fb(xDb)BmW)UvP9F4c(pzG)R7c(VfH)hu5SLoRYWytGEvAaArpsnASifjIzckGAD3ogqIEOj(VVafHqP7O2QXQCOdm0GJXk07XhtEdKBRkZT2gkTDV11qPXS5sLvL52C4XQY863eOUqSBvMBFtIUQkthxbmp(AbZdtdmojM0FWZfEAXy(Z0EgNF(RagNQm3rZChUHpBvM76vnEIB5g8eBe8e)cRHNy(zZ4D6joEOjcKEtHN4ZVLxZXtClxNWt04aPSo8erleQWXlfxD(rJ1EEIFXRd5jUTBWtSrWtCX1WtCMb9fi5XhDMahi2McpXUEnhnXTD9hnX6forHjkji8OAsbNtO90e)sxhstS9BqtSrqt8lVgAcE2roNFt1ZNmE4nfAIqVMJMy7)FjnXUQtt00uRSo8e8hEmtot2u9EWt3EEIV41H8e74g8eBe8e)kRHN4WsJywwS3tNi6eBk8eQVMJNyhxhYtSEXtOCWZCE)f0o8bpFY2Zt8RUXWtCe4eKfa6z8fkLx8Np8NF83bXFhQ20aBVQpHtcSNQkZ9Jp5EXF7b)1h(RxNf8jK(AF(HpLlycRfVjCA83KVIw0MWzySNP51BHAcpsJlmt68DtuG5iRatGZAHxAp9Z8KPFw4wGPUxOyT1mjicsWJctV6jL(1bkIotkTM1IE0h)efyJozWahEAqxemQVihrZPx9wPipFdRuKeh3yeJXgV4iN3OTRuKpXvYkfzhTzLI0GUEpqVADK2KtPGW(JQQxA)e7a6SEtMSq6JgKC2oHp12PRGRcICKfWozk3WsMwwphPCQYmajpvz2Vi99H0lhLLn5iJhbZxvM(jts(DswITEc5ucsgMsfmQT6vYBTybHNr74trxeHQk9AV8Z7ZTh8pDbZY6kESt7H9EwpCk8ECYZd77SEu1RDx)NTp3ck8VkrK0xlwlmVUl7AHXEv8bVq7wlmoz45VYxlmOXDJlgMzGpUyRwjm4X9YgMD8yHrfXbY5SGy6BZF9q1ikVuYtn(yAZFQZXQUzGYRYSpkkeZvJq11fdJsSAa4QmERHwRY4dEMQm(VUbG5RnaSJU61A3vfaBVxPaSQmh86j0LUzYWtmtK5cfDUBGU2aqx(xp0L)Rf019)TPORzFOjoDFjoN20NV0nqxBaORdUEORdETGU69BtrxpKxLjdFi9WXsBCd01ga66qRh66qxlOR(24rx29YBy2K6594LE0h9O)M6JN1k9LDWQmdH9R7i4VHVrF7wtF72(A7BxFNmIzQZLMnX5MDtSVDA7YADDQQN3OFzYhay)OoT)GfBWKN9KNOV4hx9KN4rh5Y(XbCHUwK8nVq)aE7EP6FN0eBFuBU4TBBKtxAXHKvveme1XUTrw9J5SyfS4kCikSiiqCXYL4mlikyyT0KHLPOccq5v)pSa)TWIE7TZIop5lHwGhEwglJ2QmhTUz9(2ItxQ8fir480VmlJhWz42cdpRRg72vEdto8(n8jwDNTstD1qkmuJKcp3LOF)tzXEPM16Jo(t9P9wJIGUiqZ2CoYv)ZzO(xXq(uSXIKUHvP6l6Ft3)erkxhToOwE1tvO88bvgDDqRvzow3vzEBRgEwLjaYAf8YJiRYe66xyifnD5HGvzIuLjABrFvzgPENYQYm6vdmB4MGzvzI1m0QkZXBjsQkZjUocfXvCUetMw0ycTtEdu0RmuK)Rju0rE1ffnm1RSRHxU(g2HhVEA8kFnDLFp1IYbbEyuouV2Ot6x5X0GQ4RzLljwisqjeKUPtqny0ny8rxMGAI203ifQ(jGbmuOgIPHe7cgjZD4IgmdgVdjih0YadWHesdg9YQIO5MPHazhsdjsXyvkkPF6Yc5NI)0dwlOWKOMlb(lvTGcTcXrx8ch12WgRpVh0KXEMgrBnBHUTbE9jUbd93YpfxEd0RizVcH85ANJ(vLxpDR0i2EOr3I3brFq0fR5luCnMCeH6SO7xlcgD63tVapXM5MD4uA046Oi0MYq8oSKRxZk1pqohduKMQrRsRXJ9zRhtWoXUZO9GKGUYkOmZawBbmdNwW0EnQ3BpKjlQFVhOFzYN(vp9bp3swdKDbuOmyZ9gHwU5LLuMM8nDuV8FGRKYNNtFAsXxL5uec2lzqxu8PS)iieHhlN1S19z(wug3l7S(HM6hzWpsh5(0DK7P6ih1SwpvG4bchlrDmmLQMqC)XwUX6Gh4JUCtTzkbccCjy1pNiLAjbH47yBdEXJ6y2IDdY3wxKxnRLWrKyfJgji5rSkjsDs((cpw6qNCwBEeQ2fXSVBxxty2QmSuiAvM0BaWYQmzUUar67QcrEGHQJiritlqI(QYmXvhkelZvHcRYmzdipMRjKxvMZ0kq3fB8v6G5CAvTaZLKI5CTAmxvMZ2eyRCMdx44NZNYGPh6gGT2d28F1r)5D9aB(VQbByzUzd2SFL1i482wWwQRmWw8scbY37SdLuBU1c2EqD1YMOZab4Bajx0hppF)d5nzgA0puGNMhEjdYE2vM2)X(2H9wScMJX145mfGEVuZFzUWxZUk2TDTCUB6lwt43WgsezYzJX75OEuKKDlRwGt2tOSKboGE395HEFd6u4E02Dh3UDM6wpoVIHdyIDZwmJAdVQETMqxRxIz90BUGhyebZAxevLUbn1BpwzVNglHYo18glkYCd3W1dO4usKIjJ60ck0sqAkp9A9895Xu0orYFKV55gWMwBxt92J1EFwp7RXYEFECs2QwjOW34ewBv8KzJUvINuXdmze2SzcWosKmzdnAGeJejSTaIwhALkICJ2iyBZRjrGXIKfFxzIKD8eXYKnq4W4RXULxtsOOA2UxkrEwxrxtpSp7MxFTq8Dzu9x2wNTaZruEf2IyJmwYt1I2u7EnoVNwP3BNzX6uLIMKnymuWMi76lUPcOlF2UQFlTse0Y3ZQZyBEtwmk2qF62d4(8mWad0OTNiIlKXEVzHjFyAMoBnzV9DxLi2ovQMPHcCvMnTrr8oT0eyMrY2AlospKzDG0hqIxwNoa2JBR90qdT3vlTY2xlf)7RncR9ToA39TU6fIFVi1wBlRwEA3SxFHpzzTGHu8HX2jgHrflha0nrrYiAAw2WjjrjEbyf7Go0UNw6mXEJHyfNT(dAmhUQfZXqNQb3RhTHo7A5a9dEBKOiwUPnqbxqNbjFs2qgT7z1BMG1CYTFVvAO601CyFu1T3)hcgps0mA3x7D91WM(aDaJywWzNya(6epVYSKT8UduRFZ7y5M2lh29wCg0dR4Nw1(l5Hx)DCsYIeo(KN5KbcFMYHyXGf1EW2xBx7EZqLvVppSu9DmJh)wPR6qsiGpuxZCtVJ)3)"