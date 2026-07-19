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
            PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.Unitframe.castBar, "BOTTOM", xPos, yOffset + classOffset)
        else
            local castBar = nameplate.UnitFrame.CastBar or nameplate.UnitFrame.castBar
            if not castBar:IsShown() then
                PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset + classOffset)
            else
                PixelUtil.SetPoint(nameplate.driverFrame.classNamePlateMechanicFrame, "TOP", castBar, "BOTTOM", xPos, yOffset + classOffset)
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
    local db = BetterBlizzPlatesDB

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
                if not db.classicNameplates then
                    if frame.healthBar.SetBorderColor then
                        frame.healthBar:SetBorderColor(0,0,0,1)
                    end
                end
            end

            if db.castbarAlwaysOnTop and db.enableCastbarCustomization then
                frame.castBar:SetParent(BBP.OverlayFrame)
            end

            if db.changeNameplateBorderSize then
                if frame.healthBar.SetBorderSize then
                    frame.healthBar:SetBorderSize(db.nameplateBorderSize)
                end
                local castBar = frame.CastBar or frame.castBar
                if db.castBarPixelBorder then
                    if castBar.SetBorderSize then
                        castBar:SetBorderSize(db.nameplateBorderSize)
                    end
                end
                if db.castBarIconPixelBorder then
                    if castBar.Icon.SetBorderSize then
                        castBar.Icon:SetBorderSize(db.nameplateBorderSize)
                    end
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

            if config.petIndicatorHideSecondaryPets then
                BBP.PetIndicator(frame)
            end

            if db.executeIndicator then
                if frame.executeIndicatorTexture then
                    frame.executeIndicatorTexture:SetColorTexture(0, 0, 0, 1)
                end

                if db.executeIndicatorTargetOnly then
                    BBP.ExecuteIndicator(frame)
                end
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

            if db.executeIndicator then
                if frame.executeIndicatorTexture then
                    frame.executeIndicatorTexture:SetColorTexture(unpack(db.npBorderTargetColorRGB))
                end
                if db.executeIndicatorTargetOnly then
                    BBP.ExecuteIndicator(frame)
                end
            end

            if db.castbarAlwaysOnTop and db.enableCastbarCustomization then
                frame.castBar:SetParent(BBP.OverlayFrameTarget)
            end

            if config.changeNameplateBorderColor then
                BBP.ColorNameplateBorder(frame)
            else
                if not db.classicNameplates then
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
                -- local npcData = db.totemIndicatorNpcList[npcID]
                -- if config.totemIndicatorHideHealthBar
                BBP.ApplyTotemIconsAndColorNameplate(frame)
            end

            if (config.classIndicator and (config.classIndicatorHighlight or config.classIndicatorHighlightColor)) then BBP.ClassIndicatorTargetHighlight(frame) end

            if config.showCastbarIfTarget then BBP.HideCastbar(frame, frame.unit) end

            if config.petIndicatorHideSecondaryPets then
                BBP.PetIndicator(frame)
            end

            if db.changeNameplateBorderSize then
                if frame.healthBar.SetBorderSize then
                    frame.healthBar:SetBorderSize(db.nameplateTargetBorderSize)
                end
                local castBar = frame.CastBar or frame.castBar
                if db.castBarPixelBorder then
                    if castBar.SetBorderSize then
                        castBar:SetBorderSize(db.nameplateTargetBorderSize)
                    end
                end
                if db.castBarIconPixelBorder then
                    if castBar.Icon.SetBorderSize then
                        castBar.Icon:SetBorderSize(db.nameplateTargetBorderSize)
                    end
                end
            end
        end
        BBP.previousTargetNameplate = frame
    else
        BBP.activeTargetAuras = false
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


BBP.tempComboPointWA = "!WA:2!T33cWTXX59RtWkkcs2wIwMo6rSGLTviTLOia4dj5OiHNKqeea6aOOiTDboC3rCN4H7oD3bcs6eBhghh1KM0wokUojDsYWPt6mjojU0jTtsZ)Kw1M0oXPE2HtECnn9LM5V7JKM2OPPn9rQ7(T3HNeGVKKnRc5m449y39277733V9BV9B3J6CTONT7o84UJUAjFlCTWDPdO2cRISHMIKepxabrjonE5Pv31GkYJtZRRuqJL)eUWxq9EgMrtsHTQZMuGrJtxDVb5zmegqwmNGrLlsxqMxx9(PvYvG3NmxqTcICvvGk5ZQ4kHIOSHU6(sOjYRButbZPu0vCTSWfzKy4eLRC1(vKMcN1I8AQ7kfJwoEJesmg4BcRGI2vZQOXXR5NHDConfv1D6xsC6PX1txPuuKmevxGPGboDXvnevK1DQnv8XgtN3GAEgs(jvPSbcflvi65TkRakskANHIIYHgdljx9qRBWOz4m7yIYI6co9J)NHZzm0eZLJxtFVhsZE3NDoo(SfgBSutPYR1FOOjcpuu)g4dOzkOX4zgDvEjPiC6oVQEHS8tWlBKeNAXjNpDaFjtLozkF0P8xax4zvLyMIxJwMjpVUtAssZ2ppJKHq5SMqJhNv6Kjcfn6SfKTRcoVg(bIxtMr6C4QgU2)sZYilMNbEq6b1s4RWZOZN0aR1ZziSv0E8lRiZVahU6bPinuz105Xyeo9zGKcpkO29NNruomQnCgqTJEi0dJom()3v9NzoCDJMphrs7xsHHlCwdgjCDTv68fWAdN(Xsa2wrUDsZkXORd75xxCAEyNfYAReTuaoC4iHJo7OBADwCr4iRLYryoR)hIlhV6UsEXcmA8UcxqsY1WcIg8ZPrU7qLMoNMsbv7KNeFp2YvS23caST5muyNWse9M)69Fqro1h2V)ehjgwIRc4RsaWJeaQPIS6TfsJ5WP8h4WdQKO95htdNqSCKXGXX1SWsHHtb36SjdqhkuSSyP4yI5C6bBkm)ijUyHKYr7CICDPnPngCwDEPXiiq0DAd(IiJVGJ5a5VOfIDEr5Xu0SuGTEvDbLIXeLIOhMrsNpdnJKQaJJwy)KDEPhaT5hAMa9hXvyrjPSWo(7d5eT9SfzYPej4S9mMh3sHgONZGctHUDk0DGUt0oj4Cpf0Ku3VGHHQ(jo6rHK3HOYrlN(J6TB0UWyhNO7YjA3or39EpeQ1NfDpO3cw3Vx0(CI2p6TIUF0dGUx0bq3h6GixorpOt0HEj0BdGC1dBoYYdK0S1m9H6Wj6OHrDbaeKhYwVKTDs22DzycQhhOEfqhdDC0jqpc6TVf0j3wwD(84ckR7o6SdVDHEhw6zKduF4h9Ooq(q(rbCIcoFSPuABIcjKhledAhor97iRkgxHvlNcfXj6mTIgid60oaj8O0GG1nzRhYwVKTDr22niVrXrjwKigDwe9R3cruYRpXhkfAOYcTbRtO1VdqsnmwygC(21LuUW4fY3(XsvJ860zlOZRLEkkR)pjfKLBN6Ay8mpyDkZv2u3X86GXd)Kgf04fwK0cFVXuR6mgapfFMz0umigeu(hd3AM6odRjoTRZwGHdShDLkf6Otml(EMMWYiy90UaCIj4fezL4hsuy(QouOkztR(hmEmC9NiZUMHvnAyng1bv44v3DGO(gmrQ4(J6lWa(cgmsQiNlK6UQ8ez)iOEpeAJ4y4hMj)iK2)iw6Q7eFF9XDHc6g8C8CdkklGoHM9Tz2SyYso4gr7pAOybNvxIr2aooBKyjJemesrnCeGFFmgw(hZhhxCz9hByEMX9Hfm6p2G8CImpMDvq)XciQHF4s7d4i6td3QkgsNoEbJomYXmdRsEvCIWsNOoUc08eDjzQ6obMyRhhlMQTayAAwIYQ)t99)(F)x71ETVHJ(p1p8jEIpXR9AVQJ5zSFGWpoBwD3v0u(lxqcvF6WLfxcO7(dHneEvmU9EblGRQcn0Nwb3keJHI2Ep474Kefj50zq3hnXraSTbn5m7Tf3Zs2bA3ApyROzGedTGMHyhHTNwOC2H0KHyX9GoNNtu)cfKXTVpbVhg5PWUfHFauYNYQv0Ok5ezvpZyKuOi3MDJRT70f(pnE8tHSl7Z9OUFCxmYCUkLMh1ZJ7srR8v9(4T7eRtv3fd5Ezx(Gk9f20m4l4toNe)Z0k2o)QQAk5ansss7op0(30MV(m93BRO9SaUf5kAZSc8GxBhilX(HxOEWiZKcZaguqZL7jRv7FzfZRQOzKnVOMMIgolv1yhzJAlLbGNWQvhm)yrrodHda0GrawIbRGqyMCZaV4CexQip9uarZ1QulTifi0s1TbiIoV6UQK0swB7RjwBhbJFrNE7iFZNmu0qbsfM23GHYYIDYi9ujUTo7Ol3yUmnrzO5gmlqW5DxCSX9D(OPgO9UNxrdmyi2eQT0FC6iJgpwkFrthj25crN0UyM0UySi9a2YlDA0VefkTnzhkdHEdX0qsnu2miwkehIhZyHgZMPcLtajudNes0MqcDb04ijuEeqBGuqQOlI0q649mqfatz0euOIe7v0Kn0wfn1MrtlGEI6T8qVtWyd9UWgzONeA85P2BlEqpnyuHE3LTMqZuYcc9Eqpd69IEw077f2e6seem6x(gdOf9(rFGdG(veqFqb0hApOFv0Vg6xxanBdaAEqxUkqg6dtGwONJGOq)gnfdnc65rFecUa9rrFSYab0Vjab6xqoEOCJC2bcna6JJ(eOp5TYAyVR31WExBA4rxknmZ4rhM)4JmzUOJERVgUR17A4UwBA4hDP0WT1Zaje7lrxsm9Ddwd)Syn8CGlfwDSvOIUfu7TURmv06yeWBa67UxVRV7ETPVFSLsF3zFNpEpd7pBXaD3m99JmlJgBuYR9a)GV5rNPKVkL2XtPD8wANUMPCvU6(1nY10Xoe1)uz1e5sXGDz)COpJa6ZkG(CcOxqa95fYc(Axq)z2HDN)O1vXURVL1AFaNh74DH8YjHcXbOYWqsCh)fZjJUtnSBuGdLuZKdQnypCpiDW1U2eJYjDAe3bRI23VGZ39ytgFu)NpIAGZUuDMe3JWQ6p5oCQz9EN4fMfQAddoeUDC3mNJLh6adPQgLg605SQ7RcizrVHp0jUc3uYm5fzjVqhCxtPLeZlAS9zXUtQsCG8aK(TEAh(b9cQ9RYQiJflYgHX(CROLL2xWidL0po7fNRIBC13b3yemlPdUFus)AXyR7WtQ4jMBScsswDLkJLdZwV5qETHW9ZqOCpEHUEefQzcx6u2ClvEla2elngExhhtjWDtPn(iKknuxX1XByehD(ghXr72ehGfUnZXLB369lediiSzNlzvxTneOcliakWpdW7CARxqb2r(XMC6qXZ3ZihV4kTzzmtcMigOpIS3drZkWZoEyuRooOIAlVD6jyKkW3I7zMGrteS5rpLgRaJCoEDSr8lJ(iZG79Mk0htS(XI155O2ah8gbo4fQbhCrJ(MkxNzvI2BG1eoa9nlJbqVmUdrFl0tH(ZSu5OxzdD9BW66pBn66Whx88di674CS(VbOR9UHUEDLU(ZvJUwzGy9QpuCrHS9Fdqx31VqPR9WijTExB)5RrBh5I9oWeCt5(cCDA1fm0V9kQNxlHkV7MRYFe0Ng6IWzYMuPGKl3w)ZJ1)8A9VUQThbyCXxhn)wknyp)ER9X75LiE4)NkG(cyC0xKATRr(DHocuYFE03idGVwXEVpm6uOVKa6ldoSJ(9l5No6RGbV))Gbh6RUD0x7aG6bC8(paF3(drxb9hH(JR3P6BRANQ3bmuBQ5Uaxq9yjgpih6fdJ(ocOVRa6BlG(EcOFhChM(tQ4pnyjT2S(eAK1hUdM1B8PUl7yC4iWqMscVHgynom(Py1z6DNlnn7bD68MKL3rwSLxW5hTNZnc74ArJE8KGkyslRVL3o8Y3pOb)2vzhInLo6N6QKXulnJmxAYG5Nvxe6d2L3PnqQSr4yz8RH7bjynQ2s5bJRCgZG8Ei0pqByF0rJhyaidLnzliyzY(q1zY6UIjRAlLuDHYRAmLLUdBexjhGIPjzHMNHRswSrBy25BUOn0F(TGGR4Tnq3Sh3Rw7tEX1a467up4c9x0k6h0iOe6VKWQ)xzHAq)1Ri8s1ER)30i0r1j4VDdSW1jwiR8qs9W1BXU717Aal8DV5If8UCybVBGfUbIfOJMsphBC3JEX(xdyHV3nxSqxlhwORLalCi0M)MxXVKIchjMhD5(AvFGRabR(IEQ(IEGlgwtr3OuoR(G6UONQViKZfgswaIesRuRUZAoS(R7P2Rd5VghwFuIdRLcnPLk2V80JToA3e1uZDJfdebVyb4Nvylbgbj72ocK6CrUD2v9rGeGDSIcjlhnjrHegeaUuscHlpDx2VYTydDbmjgAwf0TUZCxl6mv7mQ2XpdFOZoUBpN3n4aCaNehFbhqpewDp)ykAS8HGyTupd4P7L6yorwfzR4Zy)BIinXLdgvJnvTigwGvrrItPOCYIIQ8cxP0Hq8kMXpK7mO7(oWYWVljsv0WANmLmSv3fCQC8Y8AISjfukghN47tDxK4T1Lva3s0NGzoiYXsFS42puiowOM8nheNG(KkYmLoOySjca7)Y2(2CuGg6eel5lTx17fIdP0KnwXCyA10gI55TpIsDplkb627GAF2Yx7GpOAdsPQ9o0qjYDvYLkhaK(9nuQ4Q3f5KmfmuG4DKLmMb(9Hp8AwfK4K8wdKW7w9bAwvvIphd7uPhdB3PjCfscGiprCSPq35CwX9ce1i(Jfpwi17RzLIQgpRiebIoq7rtVqwijlyf5lN3o6nNJKn2YrW2S2fJSbIxTfRhpsGnxkd1CYrkDYDw1jRe6XlqoBrfnoi0ZMzy7DwO89GeIXXhkv0iXczxXkvKwp0tGR(zLWqqRlMw1kotRucKG8rT9MjbSh0L0gcA8y0Ke3uQUAwAZRWLMeyEV6c5KukgwJ)If4LzjHyJNU9dNt4kW2G2XzSJzGJGNHfYwWWqr2o0DizpLGi74Y866oMhoS0J1SWbvcyW5GdTgpV72shbNGKOKKigMK5sY(RGnT6Ru(fiPkQi(ESlsX43k2IrFaVOJ(CK4ntMhxHeuVlyFXCYkA8qGbJ74GuEHAA)jxPx8e0(Z8bd5lv)delsF9NQchhUTrGBBnZyrCy4NntjQeWZJFY1gNNx1h0pkdAqIkuQj2ao9pTIsEksBNN2H6UlLna0huuhg7cUm42AVwzY0))yorsp0cyN0bv4ObTj6YEXKK5c1(igfpVVHI1f0O6WyY3QBrG8Iv6b36j6BnVOoHRIWr9YoSAafZt(kOFQfJk6Fndk870XL6d8N6NIVI94V3)x9BVj4VhXY3QmWti6NLXKYJqD(sD0NZKQdbtQJUeAbtQoRi8VanjInl5411kfKD2rCzj3WmP6kJTByaOT3URAm5HNylFX(3eq)7ziEKrOWr)hL5Ur)NG7y)x1YmJ(VDG(5Kq2oUCjzBD0XnWDS1acbiXl5o2dwze4nP8sznk8TwzawR2BLkALs(JHDzssT3vDiMMmVIIHakC)VJFmrrEz0ZR2tnLIsnLcjkoj7AvEwNf26Tz(udnAxXnsa)M5m9FQp9EH)o1I3XbGSFvtQUHirgD5hSkmBRACkPjCsLDnNeebAS9fLvO)a9Lyy0hFbFXsfja8QjgosYqyFcmPClGTUUuheGBdA63gD8ZYSIrhBb9Zr)pRI2NrVgLj1MqTBsrHBI1KAZMuomPUntQTys9MmP2Qj1B(DBsTnS5Ht0DAsTDtQDysD74wWmPUdtQ7eN5DseGMu7cXBs1c(e3f(3UjT4ysD3MuTAsDpMuVftQ9Gp)EXf0(GcA)4c4ToLj19MblqpGfPUjLl8LVpC2oOj19Bs9a49EqCMoK9D4TD3WTTntQ2Xh8q4l8W4KF4DzsDeBA2vPD8ngsuIsetUqywkZysStS4lj8avto(3HjhjOicxy3DE8EgKMVTZmO0YWfAs1BZPa3)Mxefi1nbQptQJvI3ZK643KP6WGztQtSEIEZtJP3mPE7qFGEEtQtEJKR5VVHCnoRLIj2iE9FXGJleXBk0h3K603C4v2(g8kR75v(hQHxzQIPCp(WNjWW(sE9WR8v20TE8kBF9bVs1VQMxx5v(hxj8kHzdWEM8rvMQ)i3e5vU9n4vw3ZR8dRHxz0E84l(z6FcFDg56Hx5EU1Jw52x3rR86R7k)OvcTc7W555VGQO)j5VjsRS1nOvw3tR8pvdTchDFx0RHY0XJg86HwjWTE0kB9nqAL7PcTsndo0RR8k)4vcVcxVdAWyqNOTUo)nrELTTbVY6EEL)5A4v6vSpJccTD(yHh(6Hxr5wpELTT(Jx51x)v(xwj8kYDn60Ezv7TRPJxpVIDmDoQNajCJ)5b)Zl(xx4FvMDxWO)E7JGEXZzsLcJfsI)La)7S4F0cquD(nYar5jaIwldk(l5GeJJRznfesOy4kaCXQ9ViL9WR3pmjT8WnmlD4r87R3XxQXBFh1mK7y90xImbeRlkp)AhWoipHW9ecXZV82xCuEwXi(nr4ooT1aRdbwqaNqeSAhEbvhsNqqPwoAAw8mVSwXADgONRsqEdprhIoi9qrcMHMoEFdfkJ9Z6YmHlZVOjC5W4AFLaT5ZTcc0MTbk4sbUl2mTCG2ufi4Er3N6otAWiZYF0WkA5pky(qgXFyGtjbPJFyVwr)GTswGkyfyGvBkyqiXfjPS(uMuJGzQgfsJj1JkqUFykjVMuddjY6USBysO5kqPSlQBiYQxoYFYATQwSub791jJr7lAoFgC(yNrVp9bhkxFtRdqSkM6ajCDrJdeOnqyAwvGyxB04uBcYtIgNMWRayYl3ogrInBTMTOLxUAQIMGqoV4jjAvH6)1jW0K6Cy92WR)GKMuNhWuqQQgxTQaCMupwz0Lj1J)6mYkF8Zn0GQtDUlsRScrwEAcY6KNSUeSsrwNDdK1TIilnJ4bhEIqtgi8KRqKL3Ldz5DvISO3azDRiYQ4Xg(8Th7IQJpD(viYQRLdz11QezLCdK1TIiRJ5wEKGDRfmsYvQFwDVCiRUxLiRuRfKLDFXobDCTSUCt26HS1Bdcs5nMvDlAw1T1fnR6sgWqOqrHXgJop6f7rJilD5rGSJNs74gVZBatYU7Xk2wv0YQFejy194i4kZr8NRHZ6HTw3SE4sTmlS2eswhC37CvwOGbJEqn)0h328MeXZbKuK51fi2MeUalccGDaWfKjiHgU7wqSCMzH8mgSc86wrmT1Bk0UJ63KNXeEB0mMy6(nIiYNOiBFCRUzmHxIHiBdNYepWYoLjYMGosOKPwU5nXINnD7UrQ1APvQFs7zsDHxpNynWTBLHXmPgFVMuslcuzsLFPbtMuY4FkVHdEy90)WbtCrdTZ31Ab8WTgbpMuxCLbC8uniqRbOepBGsU5JsIYxu7cmDfMJoYAbLWFZgL4D5qjExkuYjinvU5rVsLfmExUR(apvFG3QpORQpO76CcbEBWtjysnPWvRUKXnMw9XEQ7yO53ByoUu5TgVgGf2V1ySZpFXs(Ta(vfC(WdvS)jBxk44IJVAwxVi4jWbUQCIbCybEPXoiUTGTKapAW(5ao3aoXG96PoFyEZG3oNU0QT1PatpIVvWByNQw3tojy(BRp(W42tMcBLzZdGTpT6HYIw4(W974X38SCkPTEdOLhPfSDQ1SrNjRoUTlyn1hwmEZqw8HRCERZz3TIN(Uk1Jc75xzL5w5noRxBBWIuaJJn1v1w0WOPqsXhRcj3hmd65xagmMJ4UZJWXOnUlIYbZY9jTsewQIT8LZynevdJL6aVxW5DFmVgjsfZyuLeOJ(CGDS7E(T2zMVWoZC5DMPb2Z5eGrhZAg7NWxuFbJeRIjnqJIv5K(0vU2ibZwn0Lpz1kDtQcxvNmtbsyplmeqNEle(emNWe)eGCatX0CFpEzlB)wX6w1hg8lmnV8eDyTM)FIK8g2tlH2oyn1Id2o6vMZcgWIvR9Sy)tE5SsIYJdZlMkL)dTskFqMdfVj17ZcWQrwXU55eUoqTMupz1WvtQNIGonPE6)VbI8kePtNhNiDwHaYOQQtkprw3X7RNvlG0K69SuyrC9OXyXjmPEVcLApRazHIzPWFEw14Vs3zBaspl2JhCRyxA1H5SLQ1G5mPE)Ba36S3vdCRyUIz1toTmlxXB0WTEBcCR4QdU5D1d36DPGBEBaCR9LTm7D5qBGiDzGBpX6m0LnkQHiSgzAulCdu1lfgdB(zbXgITpv2GstpG6y3iGyLG5hZcMxcTDSMG2MC1H26A1J2o2sH26ATrUDSnGBRv42foZWx0t4beh1)e3aHBUDxdCdFyJHBtT6GBDV69LZ9sb36Enb3SF4wmC7H1ukyG9iK3K6TGIpRhooUJCC3XtzfFqeyNQlorD4J0vQMVyjSt7pPi4umKkhJbp6(UATRTbMuBTomWK32xPC9UQLcziipIW56KUKfLCkPWYi5kqA4TysU6HDrUUojuqozZUItNL(CM4Q0T4e(mmyyfsPu1TQnRpYjw3eJkNV2cUJ(4nkFqyfYsHCBh0k5hS6sOqPAE1ff89sPQJpbUWifGvgfhZvBwzRDxgc8YKtc)bRwevPnTwhMB7GwF92o4HRUipSRsN2Qm5L5Q(B3IvXdFywAKujruFJeIoDkF09fkv6a97lwFHcAx5i1HgPzGl0e5ztUnX8nyO047vQqPhkwKuP9fmi(2y)KxwsiRy0SBkigROFll(pS9Jx7nq8TeA8L8PZwGvsuUcFIOdny8Z1GNPMDBkDFAKEVzwdltvkCCA)rWc2yPxEXnraT0jBvFxAKiOH3N6tytUtwmj2qFY3bWd7QJo6OAtobmUqIxZgt(OKe94LL92xTorS9zjAMQkW6mBAII4jT0e4eJBbld6UJz18lMoBElkqYNvWS6gmgfSInTsbf5(CA9Tmux992qJUd3qTXHBIS7WlJY(WlRAcA4iu5V6t1lETLclVUaljapn(M4NtWpdSdiLeecIC4wvCu6naJD4qDFnSLeRDGKE98fGJ4YHJYUCC0ZrA0VZQEhFvpQ8FOBh81yHAw1ACGoHFyTYG4qYzv3x9RuuLBC8OUl3q)(3e6Bz)atwf1XntR(bjIzYhRYkFRlDTOtgpr9NdqcXcfTXzOYfXzSHiixnejGE5jPCuwpdatE9Y0t(5nm41iFirjOC9G(juTn48Dix)NlYHKHpHOm6gzz0ktqhAsrDd9kTpwRTNLvlusytwi5q2fLZfrEmLQYJIM1fXMQY8s1EXYLLne1QWQLGSQlpg8XJKGsj(lTJTGELRz)HrLMh)0iobFfnPj1N)xiexp5YlUWaztQx0sO9JEtGBJZBnkkuQ3FZ9hSYAj1c1S2pT)nP(WnpxlE9xcM4mrhz0Z6l4OfcqRzVQw5pAOWPk)A13g0tiB)WX9nia5dDxP7qltIsrdRKADoF9R3uZvzT16z2rPa7xyMslavMuT2Ye3276)9p"