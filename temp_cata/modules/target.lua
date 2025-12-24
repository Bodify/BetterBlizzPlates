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


BBP.tempComboPointWA = "!WA:2!T33c0TT159ByghNqNeBR4O04KgZ4K4kLyllsQh2o11MpLOffjniLKTIZibjajGfeaeaOE1K2fT0u3T1T)vNK0T1UKD0zNE2As7)oT0UZ26628AApnz5CUh1hhSCw32XNTS3DREDp6EL9DVaGeKIuVStTtJ05qkGlU4EV47733VVVlUFaKA4w0u7UdVhTdV(Az8wyBH9c7tPLcYs6QYIICSH4fezv5KMvz3dklngnNMCz1cChZdCaL7Cegvr5coknnpJkRMYEdZXOZpGKqjE9QhKUSeNMY9tlxQmxaj2WQLfyD0GYJNx2tkzbjDnL7oLQaNMEnnmR8uEsQMhFqgrgwbPQhTFzXzGtDkovLDNHrTeNEkrgDOtkWlREP8YQSCQbzkmgRQSIYUckkm7SW40tgzzrDbf1PtwSOgNoL6mwBSid5mjdM8HIKite6fnBLqYIYQNIIIYLktbDbzjTEO10zu1Dhuqsq3D(IW)04DpNUQqPsCQA79aQwB(0lWYLVCXIzMrHtT)iXtfDO4b1HDOzkRY4BonforXySAUVKw58CtYjPNgQTW0lMnuG0zYMota6mbldDsEfrMz4uPLygNtZnnPQ57NJruNVYPMsLdov60PIep(8LLSgcUVmCbXPkXiomm0Gr)lopJKW4m4lKEqTefDxbLKL4UihJgxADqTxsNF7lXcdpCnYIhSQACa6GvBoCDWxkO2cooJGeCUO2qTVD0dHEy0bHn3t9LSam2O5kHLzUdkkZWgnOMWSCTspEzql4oiC9xOvKx30fez00WBLxNreUwWBUuEl1NPcWLlxPC1zhDtRvaQIR8Mkh(fm)Fe2sCk7o9eLzu58eTSOONr4f05wqL074bnDjv5Ykwvpnmk22fn32eaCZlOlxystr0n9kH3VaRY7jyWuhkbiXvWilBO3GYPwSOkukiTy0zCDztGtuCr4(jF6q0rIKipiYkkuYTpaXV4ztnr50sX7CYsDzbQIjb9PlAgrfEgxZRXjwKG8q7CbSOwGaZCVOGurzvtDL7LykRd9tsfZJ1sHFLoVWdG26dnxO(J5jQGOyE8gb7d5gTJ8tXusow457POpVIrgONtHgWn6wPq3gANODrGY(kRkQCp866kAh7Whgx9oeKpCL6Fy)DJ2napCJUD3O94gDh79aOwFA0DIEpGgEVO72n6EqVx09JEa09I2h6(q7h5Xn6bDJoWlI6hTtvl5yFOoCJoCuuxy1jYh5B)KV7K8D3vuQOECH6LhDe0rrhd9iO3)2qh)MZRXno0q592rND4Vl0hWuRGCHoPluFUqbqbrHxmXmYTnz5usfJWGc5gDlu5vaeaiipbkQlum3Ot5g9(mX51Ivp0QJEXI3rPXsvVKV9r(2p57UiF3nwyJsGsUm5lkf60xbsqe9vMSdLgLPIelUdjgiuiIjq01UMO85hR84TFKmOHrxXcRtMVSgNA2zOm))0u4EXuMSOg22GBA9YQC8yjZLXM2y7rjwtJBYfsDFHLda)PgJoMmIl3CQY6etbQGfbNvk7kQQWSEoDzgwSDONmzYxailYotQBOZo6Y7L1n7VruzuguMLtzpHIhyWuzsgmEGqdeiC4yzInCKfie5bKkjYrPSlyGhG98L105y5yhuqIhDmvRMz(8aTelUHOdgpsIWZRjYiPJ3pFSePJfoc68krJHzAlYuG7CbyztkPDUr4yglam61o3GCScmNZsgODUqcQfe5YgaB(3Nk4zdGSztwwVd9smZvqECfOsA8Gs7Iyhf02x4k7QQGZK2ABe03WO4lYynYHX9wv2tv5wWkNbVZIJkduJMfJUJFoaB(MGc9EPvWEu3BlEVezJSYa7pJUS6E3)h44ZdINSKIZHUpAIRxc2fWWZtkg7R4USr2ECphU(yNx5wQYzIRsoIrWd6ErwbTZxwcCPojNpgPzGyqGla5XZy64kUCjHckNQiPgYsTz5pRD3EG)u5GRcjpwL9OEFmpmsSESRZJ67X8iRw5O(FS2DdkpLDZq6lR2hR7EPTmhCaI6)PAfm9UKIQCjSOpnHQ)HUNTS1nSbbXeEVTIURLaNGvvB555WHiTV8e0mhF9OoMP5v2D1QBHyuU7qypKjb(qiqGdrcCI4W4qamiVPJP8cJRiRQNFCbvvzvOHD4yI8LslvWJhZ0xHhVescG9Y02zAtBh6ceJY(pXB8gVXB9wV1xZv)N4V)d(bFH36TEtxvHzmtV1lxSciQIpAxaZI3PkowGZepZaT3nHiYbpiMpAK5W2VyxW3f6K7GEkbwD(9HPLo8KemgjyaEcOzsoEbWqzibEtIWfDuiVdwXwdoyYedKZKBuvqc7acQqGfthjEKqzIshyWilkRInZiwskT0Fs6yJMmrMaXZglXWrOthXKauz3vVOSf(3zte(x4KOhJc9t4GPdLLWVHY1ugnetouEkubelIZuAJkIkH4PqW14XqNhngsenosc2sgPGPaqtqHuRyNJ02ksNhv2PvlAY92Ip0uyJu00GXjAgBdt0SomirFWCOh326d9eOpe6dJ(jrp5lTf0Ce0p6N6QdGh9uOpY(qpnp6JYJUa6JH(Pr)mOFwE0hVb4pF24p0pVLW4)xdHDOpXwrZBdV6NxkzKsN90dezGgbVod6zW4k0ZAHPqphp6tAHFq)c1GAq)Iwqg0VeawqFk0Ng9lB5h85rVW1tQx)VJu96FJOEzgl(iCh9Stxk(Ons9E2FCu9217ivVDTruVT1ZaPe6lvxIm91i17O)4O6T73rQE7EJOE7SVZKSNrcMFQqn03)JwR69PXQxtDOLsU1DNdRMROGj67fWU9nVZa8nwz)iZZOwio5UxaIRTo6C2b4yVHp7n8BVrxZv560EwCyOYzr3MVmjtzgxM59eItDiimwERP2bZdzQ0kqu(B4j5TieFv5XLmBK84W)lR9u3Ygw3sZikuscTZ5kPkWIVfe7Nomo474cJJh1yCnaQjZOCHILffnN8roIcO5tWm8IDxC6KJg8mXucDANt3eWdyqdG97X1cf4WZ5H0PXPXtd9JRC3vbsl7gZnpe6OcjE79btunOgeVkCPGN66jDrlIhV7aDSlYoJeZ4cfi3WMlvqwcMKMKEui6Dz180bchBO0bHJn1cvJHR(P8oOQ5n5IJFESqzeCiM7GaBWZ0nQRlJ75(NjpwGXatTBy0NLh9s8Ophp6f5rFEEWGJwdRE2Mjgtfgc4jnqDHtudRIfS3IyXjuy9XM8XAaBYGnJnPZRVytA3InbmSTitGzauC6zJKC8Eo7rNcJxAoVbMwo2EpaDbEUcJff1QR9lR0Y7FUjzufW6f0K0tYiwMRfVQf4zKkXPbwyVg6Jnhmrnf80jbzxtOZXWHaOGy0WNLW0DsxONTDtkT1UBfWgbt0ytaAX2SjiyTacMqVVzk1zE549gAnbcqFJkaa0RIMe9AWKA(Jn13OxFnPOFXnv0xlu0rpQWzgqiWrzleCdQO9Vov0V0Mk6RfkA5bs0R2qjf4Z3)gur316ur)52urdkAFmII)iwvhBIEhys2z8EE2o3GQ6UxNQ6p)Yu1RXzhG(14BU((rq)64jeCQ8PLll6XR5)8z(p)M)RR6I))lcXpBVmo)w5qFTTTHxmNfDH1uByD0ldI2FdxeO4xIVsm8GYrP05zdRLi1yHzxLO4FLOOVfp6BZJ(M8OVdVZW4hgDcI2(K444r)22HVJ(Dq)U4yZrFzya8hzVSsFf0V3oq)(O)a0Fi6I1hR9nGb(FvZORbKsuxaK4)p6lWJ(nH50yodTV(6mUz(gz3bAZLz4PSBR8r4q4vaLKkcnWs8gwVwI7CfPC3VB3VnziEOLziIxZoI5hrEzBU9qnWCZRP5gmpEljsKXv0NXuKagGvpd8fCtofAog2QNYkzZAR8)MvmAVFaxoApdF2cJPgp(rtJo8N5sKBKFwgj2SKf6pVMaEMFpZUQWDR0sL73FLQLd9C5cQct9Iy0BHOpa67Qosa64jdnqvSDdT55F7cQHmE3kYYok8)KMHJSRWBSwrnFRAqnjBBGUlCu)QTp9eaQb9N2k676aJG(ZWic0FEDWb0FXMaHFude8VAab)RxGW3UgGqEPHe7HT3P6Ux)BceUEgi01Qbe6A9ce(o1aeOJNrRuHKEhDI(V6ceoaARV6fdkklZssnrpEVSZD8ekSZd6Z5b9HpyuvznD7Z05o1DqFopi(mxAijECclAwBLDvZU1FCF1EC85xjcvCuB36JsIWYorJwP04Yxpw479qG4npUva8HdBfJkntcjtmgGDWqihyS6kzplRe6UTYCPoxwiPDvFMlHbEMzVeoUtRSxcab4imj59LVURGq2gX6KKgtFkZeys9ONIlYPhZRVZ4fJBd52oLVADXIYQf4IGZksTC4qyVqhliuqwYmToUNTqeLvX5GfR5keTubzzrw5PKspLGcjvL(NRv(DBG877qsSfvq1KJyBdIqLDJlQeNeNQqH08YtLuk3s1S7cAW)ciofZmAeHmiVbPpi5dIBixO7tz3KeO1Jzg0s08y6alUamfqDM)BavdqTH1ohJWaCH9QCF4KBkl5lZ8mmRswDHX5YQOYvqaNbFUuURLvhnRnqTnFLJT)huPb1uXAdACJYEjYHQKQJbdmuMKk3oPqMY6Y40CSa5g1hmaS7LnBiHP5mV79pPYd0SrRixjMcZKTiySQYFrsfW5OIqXzq7CbZ0SbNjhbtKmrefpnRvgxMnljpZq3LQw584AO0EZQS1kuKvNxLd0SISZSaPwfQKgmZBDws6iwL7TzTJ5EukTykBiz88zTYizLD5OWQjH8sKsNswLfNABZnI1glvP)ijBCYHYepwIiMsJjbDzEro(LmZii7o4IM7MvXmZtR2cKuZXQYNXE04CiAx4BUujr5PIQYnrzoPcKmVZx3bXLXFr83HTsJyxZH3dpWwkFzDDzjRCPzbCXMRA3DSiEB7H284DQMtrKUjdVqHXK400CzQHWLDrWURp7QYtAIZ4SjstYvyYMXfGZD3KEmOzQdJ(iqygphjLJK4MexqD3tjWjZNKx52XvqOKKSkhozGH5ijoopXJZIHJeit)dKiwF9NPQVhWNkMxdyKWbmeeZ7ausO)LCguDKdDlpUlGeFBa9vPiTFw9PotGHs0vWzLLhNc9S(b(nL9ytcHbTHf0WRdcBoWB53Vcx4FjzItHSQ3GYS0eG7jnZXZqy)FxEmooLa4juPtJ1b8x0UzXPkDoZBztpGFB0RUOGgH7HW58AUmDDdKKVo6hmN9jrwgXl0hooQFaCiiwkCgV2)x5BTf8Fpcetv)N4ZUx8FNy5BaXALJWL24abmO8Z3SqVOjzTj65v6DDNCLPhxwgcedReUSDE9zLnN2XWzq5nN59AQpCh2B3ocLZY9Gz0C)R8guDLJeuhXfa6FRc3p6Fph6)4sAewEBnsTu8O)tGFh9FvhDEdIOBd6T1oIUh0r4CagGSQ(TwDXyDgPJbvp8GRsdQojosl0x8c89hQVuJagegupCJTemOoOjU3G6qvH7xqPNAunY1OAiPjkzttLKzP4V9tmhE2hKynaoHX4BWfmgE)xzq5Zcn)PS9)2QkRCwcZc2rmpfoepi67p9sbsKjwi8ngyKyPJunCpSbh6w6)d89ia0N5cDqWTnXVpOFBIV(6v0OFy962T1aD7vDx1O)BxO)hO4)xWrl6TmO2IbfLb1wnOCzqDdguB7jnOUrq)SD0onOUjdQB2GYnmUnO2Hb1TmJb1TsUKnOUneRb1oHZCxWNDtCNyq1Ib1TBqThdQ7WGQvOrUt4yVhCdDxqdSxyN7M6nnOUhtYDdQ3luL7foT9zq5XG6(GtA)qDUFRE4bCH72h0G6aq1EFWbAdkS9DBq9qw0TRt0vTKPaKXjv69SvlQ0U78O9minxBNAqrcKMqKsmUDYA(MvHvwKKyMhIHTd2qdQURJeKyS0i6pQ32O9mO6f98guhX6Q(Ox1jSmOo2AbiFTKKYxTKujoR)GteEm(y(ZSbiPmOoEZ5B(RBaFJ7APzmOor9CluV9XPSJn5uUwXP8L3IfNYmtLX7yJCQqJei9kWP83SjNYkXPSJRh4uCEJAQLtjAHqfo14XLNP)yxT5u(BVEJt5w3Kt5AfNYDArPmAp(cK8u9pzGoJTcuk)DBsPSsuk361zuk1fMsHrgNJ78kcbNM7QnLYF)1BukBFtkLRvukHSOuyP7Bc)6YZMmE4vGs5FytkLvIsz7xZOuUZQuk1SKq1YPW27G6m60PARRZC1Mt5F86noLBEtoLRvCkYwCk9k0NEz(2otIOJScCkFVn5uwjoLB(6noL6ItrQRrN1FbLE7A2KxT5u(N2GCkwPQ5O(cLYl8Xh8Xp8Pl4t3nkfn)c840Z83W1Y5AwJlZTZ0ZCdOiEzZhSQVepofr)6uwR8T1YYhAfxd8Wl6JDKc0rpBWa9oMZvehVW(noRmXjHPvAzIZjZV6oWPK5V7(QnRmRAEEJ4K30A1YnZkZxzydQ0GcLg(Ke(Kc(CAEsgfuntnXgM2zlt13Pjz5xblV6S6o8W4S2T(8r9a00j7BOi5OdtpuSW2zPDZsN6xWYQKigRKAn3OJuR5ZVkPwdy4n7n7iZAWk)kPwJn6GSq(4LGfopLDLwNrQa3HJc7FyS5dP1H2kiUgTI(UBN8gjOapd(1afE1cH(G0wFgsn9BqnKb1O8KU)5ak1ZIphOH3d(Hh0ti7ZtqtxOGMb1i5CWo8e5nF3xSsj59vivr7l)H(eZCd2tv9GBLzu2wMoTPWylfEazbGhYZWjjpTdVyItP1N2GdvQVz1Qq4cg5ark5b0S2ShcNYP4eeYrIHxB2dvBfEbs2dvxI7Fvfvc6mqtn81j4rcO4(mOoJn0ZcerGvRn0Mb1Jwp0YG6CVJawLYjSA8Kdp0GkZm8e0YRfyLVvawD8Jxxf2ew9Ujy1PDcRu1tgEKjJmDOOtVwGv(xnyL)nHvVlfwr7ewn1rg5mTNycLXMD81cSQRvdw11MWQ3LcRs7ewDeVsNnC3QHJLEnfBv3RgSQ7MbRSM51XutQM3Jxp(i)3N1)97XxnZ(6rFhWdix6q68LNIVyr6XxThqUEmOyHzcva(K)TNhqUTFT8bK7onZytz18Ahse)644qGo9qbl1GhDHTx3JUWfAzE8BFqY7C29Uq1xhVytASAC2JAz9ssU5qIYsCA8QWKKWPjzoNCaycaWy06EJaMUlnoJEbEonZKJg9dXWbmc5T)h7b)R)h7HL)aZTNgjuR1IR(NlpdQIRXNfcahw5HHWpGLNTF9ycCPMQqFS2pmepWQ(WqKpfDSiPZCT6rJbF1UwayguL2Rbf)YqugucG945xzqKb1yVJb54Zgfi2eyIV1pmPqnWKc(6FKWPMqx9mDT2HjgusBcrUobI4F1Gi(x)qe2AGiX5Ms98mDfLLo2vziYXi(926OxQ6RLDCCeo31xT7crvCrh72LZD6UU4nW35YYGYwh(mb8rf(Oz)64Y8gaFLe(be6WvueiyCp2J(x3o(diMisisRqyhHQ55GccjWAzzCePHDGfVFx4ylG4hWbCGd)amzWrAaXEuxGg3eoYeR77ooGUWlgDOP6F62fdpMWyvUrVFnkRGoYtDHJJnTnT8Uj0Na8vPb2swZSaScnNPHLPE1v)amSmFYTzYRb(aXVh6XVnDZHLYxQA5MLzzto7TBBwATqjpEZxAeSa1KMrL8AwMJLhq7elilYfNgDh3w1dtK5CBDEw5SM3lvEmsGZuaVH1VF0CecmS2bMt0YnCFTQE4Bf6ELhghXuwoPj7W8np)XsZPB9Gj02(XRdZH825HeXpIx7VD0RVG5iTaiO6Pw7Ds7MxuqAm8Z(r12)HwlTplJ6y4M3G6Xrt89VKg5bHiL1JabpsiN5QGbgxy24Wl69i(1tLjH(OYPwP1ccty4TNF1DL7L3vUNzx5mFQ8tfiEGWXsufzJj3be6fwY5OXd65xQMREcXig7AnVNjWKLNCBON94MZYKSGIyEutUgIseGSQxbqwdQPiiudQPVcrLguZS2bKguZ(JmKOV1fsSZJwfjcqLgGa9zq9eRp0h0M1G(OmO(WnaXfxrzAPjZ7nzF9SErCgup5YbBx0zNBJ1SV(QhRPsWAU2eRDfH18V(WA9UAyn)1H1AFvBZExtqTPknvET0ZkvGDQRMqTERfQ1BJHAARFOgGOAisdUGQnM7A04VTb9kZ3yyNfK8QasZwIEetj6kc66A9b6oYQb66A9tWDKvc1H5jmHDdvOpLcHfNDaLIxnGDaKXgQDKgd10BiudBgVjwRESMxVRbSw3RVW68UAyTUx3ynRH5QI1o)PgzcFrhqy0GtE1fRzFrvpwR8AhR9WQYL1H4y5mOUduI59XYYEOJ6nzgZPetTunpZ73ZwWGqfpScA4FWRY08hy(Dz9BfcuJHuyz05a4xkL7U(3egv6Ud71juE6B4vQi8D8okgNOgXy9CCpscIUfLlWi6juw8nZKC0d6HCCns6CC8MDe3UT)flXJDxCSa66mf4Zi7ORAZ83XeZorVA512WD0hNELDIktEnu32(nR((D2cLTh5oBk8pjko2Vdj7wc3mzKhJtI0ccf90M553UhDERcX)HFvn4aBA(gCUT9B(JJ2(pOZ2(GESl2CuXjX683PfZMh)JWsJepPIh4SrOZMjaDFrYKnu)bs0xKWwciYyOrQi8bAIGTjDtIadgjl0xzIKDOeXYKnq4Wq3yDLxrsijR3SoflpRQOROhoO1Lx7nq8TcQ(v8QZsGzlkxJxr0rgm5Wn4AQzDJD)0i9EZmlwLHu0K0bJbc2ezxDXnraTYvBD3lnse0W(P(k2KEYKCXc6t(z27GE6OJoCA7Xd4crovlm5JsQ0Jvr2BD06eXwLs0moAW6mBAII4dzQjGkdEKZr8iNW0JmqTTOjXi5hUV8A6m6L1SlIxGfyH3sLmG06EIz(RhOMYhPH2HhSHkOd2eX5bxf9)bxvnhoIHVbEjCpNsKk)2pvVG3s(S6AjqgHJgXXBuligeL7UH(xm3alGUswsss0lUQe9YHh2H7y)oUzGMECFMBfhdYs18wvXf6ybXVNkWrhDPAFZ4yqDdlu9vIZtDlQwVNBcgps0mk3FZDBw9f6do2o8DceCzNMg)kwQZk3(WBw5HBElS834n25(9a4fCLn(zh90bcpA5q0l6OrAzAiWYfR)vytLaUa)9VQf6K8cGh9Att5QIwhJE50QqJfKtxNtL8l5jXAqlCqcLCdkN4QRMF1ghsc)l5jJMEEg1ke5rMwqtxRQd1ATrnTUXTeyAJRo(0fKkftQOSJZrw18GGjTeNyThSsBzbynBSAjsDC4ImIACymle2OYhNyvq(18S6pgOEwwHjtvFzyd3erI34tO6bHtSHg8EAOHRzCR3Y2qV(LT(ftLMdKVctYvvtAqTimWnOE53vOg)qRUA0uO9pCJ4W3)IK8CNFo7xCtgu3EltEdpX)3"