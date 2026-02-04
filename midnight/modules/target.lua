if not BBP.isMidnight then return end
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
        frame.targetIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, -1)
        if false then
            frame.targetIndicator:SetAtlas("glues-gameMode-selectArrow")
            frame.targetIndicator:SetSize(22,14)
            -- this needs rotations swapped
        else
            frame.targetIndicator:SetSize(14, 9)
            frame.targetIndicator:SetAtlas("Navigation-Tracked-Arrow")
        end
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
    -- local textureName = BetterBlizzPlatesDB.customTexture
    -- local customTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)

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
    --local useCustomTexture = BetterBlizzPlatesDB.useCustomTextureForBars

    -- Initialize
    if not frame.focusTargetIndicator then
        frame.focusTargetIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        frame.focusTargetIndicator:SetSize(20, 20)
        frame.focusTargetIndicator:SetAtlas("Waypoint-MapPin-Untracked")
        frame.focusTargetIndicator:Hide()
        frame.focusTargetIndicator:SetDrawLayer("OVERLAY", 7)
        frame.focusTargetIndicator:SetVertexColor(1, 1, 1)
    end

    frame.focusTargetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.focusTargetIndicator:SetScale(dbScale)

    -- Test mode
    if config.focusTargetIndicatorTestMode then
        frame.focusTargetIndicator:Show()
        if BetterBlizzPlatesDB.focusTargetIndicatorChangeTexture then
            frame.healthBar:SetStatusBarTexture(focusTexture)
        else
            BBP.ApplyCustomTextureToNameplate(frame)
        end
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate and not (BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP and BBP.isInPvP) then
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
            BBP.ApplyCustomTextureToNameplate(frame)
        end
        local shouldColorize = colorNp or colorName
        local color
        if shouldColorize then
            color = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB
        end
        if colorNp and not (BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP and BBP.isInPvP) then
            frame.healthBar:SetStatusBarColor(unpack(color))
        end
        if colorName then
            frame.name:SetVertexColor(unpack(color))
        end
    else
        frame.focusTargetIndicator:Hide()
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

    if frame == BBP.currentTargetNameplate then
        frame.healthBar:SetStatusBarColor(unpack(color))
    end
end

local nameplateResourceHooked
local nameplateResourceOnTarget
local nameplateShowSelf
local nameplateResourceUnderCastbar
local nameplateResourceUnderCastbarEventFrame

local classPadding = {
    ["MONK"] = -8,
    ["EVOKER"] = -9,
    ["WARLOCK"] = -8,
    --["DRUID"] = -11,
}

local classResourceYOffsets = {
    PALADIN = 4,
    DEATHKNIGHT = -3,
    MAGE = -4,
    MONK = -4,
    DRUID = -4,
    ROGUE = -4,
    WARLOCK = 0,
    EVOKER = -1,
}
local playerClass = select(2, UnitClass("player"))

local adjusted

local function RepositionClassFrame(point, relativeTo, relativePoint, xOfs, yOfs)
    local prdClassFrame = prdClassFrame
    if not prdClassFrame then return end
    if prdClassFrame.bbpChanging  then return end

    if playerClass == "ROGUE" then
        local maxComboPoints = RogueComboPointBarFrame.maxUsablePoints
        if maxComboPoints == 7 then
            xOfs = xOfs + 20
        elseif maxComboPoints == 6 then
            xOfs = xOfs + 10
        end
    end

    prdClassFrame.bbpChanging = true
    prdClassFrame:ClearAllPoints()
    PixelUtil.SetPoint(prdClassFrame, point, relativeTo, relativePoint, xOfs, yOfs)
    prdClassFrame.bbpChanging = false
end

function BBP.UpdateNameplateResourcePositionForCasting(nameplate, bypass)
    local prdClassFrame = prdClassFrame
    if not prdClassFrame then return end

    local enabled = BetterBlizzPlatesDB.nameplateResourceOnTarget and (BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true)

    if not enabled then
        return
    end

    if nameplate and nameplate.UnitFrame and nameplate.driverFrame then
        local yOffset = BetterBlizzPlatesDB.nameplateResourceYPos
        local xPos = BetterBlizzPlatesDB.nameplateResourceXPos or 0
        local isCasting = UnitCastingInfo("target") or UnitChannelInfo("target")
        local classOffset = classResourceYOffsets[playerClass] or 0

        if playerClass == "ROGUE" then
            local maxComboPoints = RogueComboPointBarFrame.maxUsablePoints
            if maxComboPoints == 7 then
                xPos = xPos + 20
            elseif maxComboPoints == 6 then
                xPos = xPos + 10
            end
        end

        -- Adjust position based on casting state and setting
        if bypass then
            RepositionClassFrame("TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset + classOffset)
        elseif isCasting then
            RepositionClassFrame("TOP", nameplate.UnitFrame.castBar, "BOTTOM", xPos, yOffset + classOffset)
        else
            if not nameplate.UnitFrame.castBar:IsShown() then
                RepositionClassFrame("TOP", nameplate.UnitFrame.healthBar, "BOTTOM", xPos, yOffset + classOffset)
            else
                RepositionClassFrame("TOP", nameplate.UnitFrame.castBar, "BOTTOM", xPos, yOffset + classOffset)
            end
        end
    end
end

function BBP.TargetResourceUpdater()
    if BetterBlizzPlatesDB.disablePrdMovement then return end
    local _, className = UnitClass("player")
    nameplateResourceOnTarget = (BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true)
    nameplateShowSelf = GetCVarBool("nameplateShowSelf") and not nameplateResourceOnTarget
    nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar and nameplateResourceOnTarget

    local prdClassFrame = prdClassFrame
    if not prdClassFrame then return end
    -- Safe check this
    prdClassFrame:SetScript("OnShow", function()end)

    if not nameplateResourceHooked then
        -- hooksecurefunc(prdClassFrame, "SetPoint", function(self)
        --     BBP.TargetResourceUpdater()
        -- end)
        nameplateResourceHooked = true
    end

    if nameplateResourceOnTarget then
        local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
        if nameplateForTarget then
            prdClassFrame:SetAlpha(1)
            local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 1
            prdClassFrame:SetScale(nameplateResourceScale)

            if BetterBlizzPlatesDB.hideResourceOnFriend then
                if not UnitCanAttack(nameplateForTarget.UnitFrame.unit, "player") then
                    prdClassFrame:SetAlpha(0)
                    return
                else
                    prdClassFrame:SetAlpha(1)
                end
            end

            if BetterBlizzPlatesDB.changeResourceStrata then
                prdClassFrame:SetFrameStrata("DIALOG")
            end

            if nameplateResourceUnderCastbar then
                BBP.UpdateNameplateResourcePositionForCasting(nameplateForTarget)
            else
                RepositionClassFrame("BOTTOM", nameplateForTarget.UnitFrame.healthBar, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos + 30)
            end
        else
            if BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf then
                if PersonalResourceDisplayFrame then
                    local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
                    prdClassFrame:SetScale(nameplateResourceScale)
                    prdClassFrame:SetAlpha(1)

                    if BetterBlizzPlatesDB.changeResourceStrata then
                        prdClassFrame:SetFrameStrata("DIALOG")
                    end

                    local padding = PersonalResourceDisplayFrame.ClassFrameContainer.yOffset or classPadding[className] or 0
                    RepositionClassFrame("TOP", PersonalResourceDisplayFrame, "BOTTOM", BetterBlizzPlatesDB.nameplateResourceXPos, padding + BetterBlizzPlatesDB.nameplateResourceYPos or -4 + BetterBlizzPlatesDB.nameplateResourceYPos)
                else
                    prdClassFrame:SetAlpha(0)
                end
            else
                prdClassFrame:SetAlpha(0)
            end
        end
    elseif nameplateShowSelf then
        if PersonalResourceDisplayFrame then
            local hideResource = BetterBlizzPlatesDB.hideResourceFrame
            local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
            prdClassFrame:SetScale(nameplateResourceScale)

            if BetterBlizzPlatesDB.changeResourceStrata then
                prdClassFrame:SetFrameStrata("DIALOG")
            end

            local padding = PersonalResourceDisplayFrame.ClassFrameContainer.yOffset or classPadding[className] or 0
            padding = padding + 52
            prdClassFrame:SetAlpha(hideResource and 0 or 1)
            RepositionClassFrame("TOP", PersonalResourceDisplayFrame, "BOTTOM", BetterBlizzPlatesDB.nameplateResourceXPos, padding + BetterBlizzPlatesDB.nameplateResourceYPos or -4 + BetterBlizzPlatesDB.nameplateResourceYPos)
        else
            prdClassFrame:SetAlpha(0)
        end
    else
        prdClassFrame:SetAlpha(0)
    end
end





-- Function to handle event registration and updates
function BBP.RegisterTargetCastingEvents()
    if BetterBlizzPlatesDB.disablePrdMovement then return end
    nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar
    nameplateResourceOnTarget = BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true

    if not nameplateResourceUnderCastbarEventFrame then
        nameplateResourceUnderCastbarEventFrame = CreateFrame("Frame")
    end

    -- Always unregister all events first to ensure a clean state
    nameplateResourceUnderCastbarEventFrame:UnregisterAllEvents()

    if nameplateResourceUnderCastbar and nameplateResourceOnTarget then
        -- Register events if both conditions are met
        nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
        nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
        nameplateResourceUnderCastbarEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "target")
        nameplateResourceUnderCastbarEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        nameplateResourceUnderCastbarEventFrame:SetScript("OnEvent", function(_, event, unit)
            local nameplate = C_NamePlate.GetNamePlateForUnit("target")
            if nameplate then
                BBP.UpdateNameplateResourcePositionForCasting(nameplate)
            end
        end)
    else
        return
    end

    local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
    local prdClassFrame = prdClassFrame
    if not prdClassFrame then return end

    if nameplateForTarget then
        if nameplateResourceUnderCastbar then
            BBP.UpdateNameplateResourcePositionForCasting(nameplateForTarget)
        elseif nameplateResourceOnTarget then
            RepositionClassFrame("BOTTOM", nameplateForTarget.UnitFrame.healthBar, "TOP", BetterBlizzPlatesDB.nameplateResourceXPos, BetterBlizzPlatesDB.nameplateResourceYPos)
        end
    end
end


























function BBP.FadeAllButTargetNameplates()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        local config = frame.BetterBlizzPlates.config or BBP.InitializeNameplateSettings(frame)

        local unit = frame.unit
        local isPlayer = false--UnitIsUnit(unit, "player")
        local isTarget = frame == BBP.currentTargetNameplate--UnitIsUnit(unit, "target")
        local isFocus = frame == BBP.currentFocusNameplate --UnitIsUnit(unit, "focus")

        local shouldFade = true

        if isPlayer or (isTarget and not config.enableNpNonTargetAlpha) or (isFocus and config.enableNpNonFocusAlpha) then
            shouldFade = false
        end

        if shouldFade then
            frame:SetAlpha(config.fadeOutNPCsAlpha)
        else
            frame:SetAlpha(1)
        end
    end
end

function BBP.UnfadeAllNameplates()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        local config = frame.BetterBlizzPlates.config or BBP.InitializeNameplateSettings(frame)
        if not config.enableNpNonTargetAlpha then
            frame:SetAlpha(1)
        end
    end
end

local function NameplateTargetAlphaAllNps()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        BBP.NameplateTargetAlpha(frame)
    end
end

local PlayerTargetChanged = CreateFrame("Frame")
PlayerTargetChanged:RegisterEvent("PLAYER_TARGET_CHANGED")
PlayerTargetChanged:SetScript("OnEvent", function(self, event)
    local targetNameplate, frame = BBP.GetSafeNameplate("target")
    local db = BetterBlizzPlatesDB
    BBP.currentTargetNameplate = nil

    BBP.TargetResourceUpdater()

    -- LAST TARGET NAMEPLATE
    if BBP.previousTargetNameplate then
        local frame = BBP.previousTargetNameplate
        if frame.unit then
            local config = frame.BetterBlizzPlates.config
            local info = frame.BetterBlizzPlates.unitInfo
            frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)

            if config.healthNumbers and config.healthNumbersTargetOnly then
                BBP.HealthNumbers(frame)
            end

            if db.changeNameplateBorderSize then
                BBP.ChangeHealthbarBorderSize(frame)
            end

            if frame.BBPmouseoverTex and db.keepNpShadowTargetHighlighted then
                frame.BBPmouseoverTex:SetVertexColor(0, 0, 0, 1)
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

            if config.classicNameplates then
                if config.changeNameplateBorderColor then
                    BBP.ColorNameplateBorder(frame)
                end
            end

            if db.classicRetailNameplates and frame.HealthBarsContainer.newBorder then
                if config.changeNameplateBorderColor then
                    BBP.ColorNameplateBorder(frame)
                else
                    frame.HealthBarsContainer:SetBorderColor(0, 0, 0, 1)
                end
            end

            local selectedBorder = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar and frame.HealthBarsContainer.healthBar.selectedBorder
            if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                if config.changeNameplateBorderColor then
                    BBP.ColorNameplateBorder(frame)
                else
                    selectedBorder:SetVertexColor(0, 0, 0, 1)
                end
            end

            if db.friendlyHideHealthBar then
                local showOnTarget = db.friendlyHideHealthBarShowTarget
                if showOnTarget and (info.isPlayer and info.isFriend) then
                    frame.HealthBarsContainer:SetAlpha(0)
                    frame.HealthBarsContainer.alphaZero = true
                    frame.selectionHighlight:SetAlpha(0)
                end
            end

            if config.targetIndicator then
                BBP.TargetIndicator(frame)
            end
            --if config.focusTargetIndicator then BBP.FocusTargetIndicator(frame, true) end
            if config.fadeOutNPC then
                BBP.FadeOutNPCs(frame)
                if config.fadeAllButTarget then
                    BBP.UnfadeAllNameplates()
                end
            end
            if config.enableNpNonTargetAlpha then NameplateTargetAlphaAllNps() end
            if config.hideNPC then BBP.HideNPCs(frame, BBP.previousTargetNameplate:GetParent()) end
            if config.partyPointer then BBP.PartyPointer(frame) end

            if config.classIndicator then
                if frame.classIndicator then
                    if (config.classIndicatorHighlight or config.classIndicatorHighlightColor) then
                        if frame.classIndicator and frame.classIndicator.highlightSelect then
                            frame.classIndicator.highlightSelect:Hide()
                            frame.classIndicator.border:Show()
                        end
                    end
                    if frame.classIndicator.border and frame.classIndicator.border.circle then
                        if frame.classIndicator.bg then
                            frame.classIndicator.bg:SetSize(36, 36)
                        end
                    end
                end
            end

            if db.friendlyHideHealthBar then
                if showOnTarget and (info.isPlayer and info.isFriend) then
                    frame.HealthBarsContainer:SetAlpha(0)
                    frame.HealthBarsContainer.alphaZero = true
                    frame.selectionHighlight:SetAlpha(0)
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
        BBP.currentTargetNameplate = frame
        local config = frame.BetterBlizzPlates.config
        --local info = frame.BetterBlizzPlates.unitInfo
        frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
        local info = frame.BetterBlizzPlates.unitInfo
        --if not info then return end

        -- info.isTarget = true
        -- info.wasTarget = nil
        --if not UnitIsUnit(frame.unit, "player") then
        if true then--BBP.isMidnight
        --if not info.isSelf then

            if db.executeIndicator then
                if frame.executeIndicatorTexture then
                    frame.executeIndicatorTexture:SetColorTexture(unpack(db.npBorderTargetColorRGB))
                end
                if db.executeIndicatorTargetOnly then
                    BBP.ExecuteIndicator(frame)
                end
            end

            if db.changeNameplateBorderSize then
                BBP.ChangeHealthbarBorderSize(frame)
            end

            if frame.BBPmouseoverTex and db.keepNpShadowTargetHighlighted then
                frame.BBPmouseoverTex:SetVertexColor(1, 1, 1, 1)
            end

            BBP.ToggleNameplateAuras(frame)
            BBP.TargetNameplateAuraSize(frame)
            if config.targetIndicator then BBP.TargetIndicator(frame) end

            if config.classicNameplates then
                if config.changeNameplateBorderColor then
                    BBP.ColorNameplateBorder(frame)
                end
            end

            if db.classicRetailNameplates and frame.HealthBarsContainer.newBorder then
                if config.changeNameplateBorderColor then
                    BBP.ColorNameplateBorder(frame)
                else
                    frame.HealthBarsContainer:SetBorderColor(1, 1, 1, 1)
                end
            end

            local selectedBorder = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar and frame.HealthBarsContainer.healthBar.selectedBorder
            if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                if config.changeNameplateBorderColor then
                    BBP.ColorNameplateBorder(frame)
                else
                    selectedBorder:SetVertexColor(1, 1, 1, 1)
                end
            end

            if config.fadeOutNPC then
                BBP.FadeOutNPCs(frame)
                if config.fadeAllButTarget then
                    BBP.FadeAllButTargetNameplates()
                end
            end
            --if config.enableNpNonTargetAlpha then NameplateTargetAlphaAllNps() end

            if config.healthNumbers and config.healthNumbersTargetOnly then
                BBP.HealthNumbers(frame)
            end


            local alwaysHideFriendlyCastbar = db.alwaysHideFriendlyCastbar
            local alwaysHideEnemyCastbar = db.alwaysHideEnemyCastbar
            if alwaysHideFriendlyCastbar or alwaysHideEnemyCastbar or BBP.hideFriendlyCastbar then
                local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction("target")
                if ((alwaysHideFriendlyCastbar or BBP.hideFriendlyCastbar) and isFriend) or (alwaysHideEnemyCastbar and not isFriend) then
                    local alwaysHideFriendlyCastbarShowTarget = db.alwaysHideFriendlyCastbarShowTarget
                    local alwaysHideEnemyCastbarShowTarget = db.alwaysHideEnemyCastbarShowTarget
                    if (alwaysHideFriendlyCastbarShowTarget and isFriend) or (alwaysHideEnemyCastbarShowTarget and not isFriend) then
                        if UnitCastingInfo("target") or UnitChannelInfo("target") then
                            frame.castBar:Show()
                        end
                    end
                end
            end



            if config.hideNPC then BBP.HideNPCs(frame, targetNameplate) end
            if config.partyPointer then BBP.PartyPointer(frame) end

            if db.friendlyHideHealthBar then
                local showOnTarget = db.friendlyHideHealthBarShowTarget
                if showOnTarget and (info.isPlayer and info.isFriend) then
                    frame.HealthBarsContainer:SetAlpha(1)
                    frame.HealthBarsContainer.alphaZero = false
                    frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or 0.22)
                end
            end

            if (config.classIndicator and (config.classIndicatorHighlight or config.classIndicatorHighlightColor)) then BBP.ClassIndicatorTargetHighlight(frame) end

            if config.showCastbarIfTarget then BBP.HideCastbar(frame, frame.unit) end

            if config.petIndicatorHideSecondaryPets then
                BBP.PetIndicator(frame)
            end

        end
        BBP.previousTargetNameplate = frame
    end

    if db.enableNpNonTargetAlpha then NameplateTargetAlphaAllNps() end
end)


-- Event listener for Focus Target Indicator
local PlayerFocusChanged = CreateFrame("Frame")
PlayerFocusChanged:RegisterEvent("PLAYER_FOCUS_CHANGED")
PlayerFocusChanged:SetScript("OnEvent", function(self, event)
    local focusNameplate, frame = BBP.GetSafeNameplate("focus")
    BBP.currentFocusNameplate = nil

    -- PREVIOUS FOCUS NAMEPLATE
    if BBP.previousFocusNameplate then
        local frame = BBP.previousFocusNameplate
        local config = frame.BetterBlizzPlates.config
        --local info = frame.BetterBlizzPlates.unitInfo
        frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
        --local info = frame.BetterBlizzPlates.unitInfo
        -- info.isFocus = false
        -- info.wasFocus = true
        if config.enableNpNonTargetAlpha and BetterBlizzPlatesDB.enableNpNonFocusAlpha then NameplateTargetAlphaAllNps() end
        if config.focusTargetIndicator then
            BBP.FocusTargetIndicator(frame)
            --BBP.ApplyCustomTextureToNameplate(frame)
        end
        BBP.CompactUnitFrame_UpdateHealthColor(frame)

        BBP.previousFocusNameplate = nil
    end

    -- CURRENT FOCUS NAMEPLATE
    if frame then
        BBP.currentFocusNameplate = frame
        local config = frame.BetterBlizzPlates.config
        frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)

        if config.fadeOutNPC and config.fadeAllButTarget and BetterBlizzPlatesDB.enableNpNonFocusAlpha then
            BBP.FadeAllButTargetNameplates()
        end
        -- local info = frame.BetterBlizzPlates.unitInfo
        -- info.isFocus = true
        -- info.wasFocus = nil
        --local info = frame.BetterBlizzPlates.unitInfo
        if config.focusTargetIndicator then BBP.FocusTargetIndicator(frame) end
        BBP.previousFocusNameplate = frame
    end
    if BetterBlizzPlatesDB.enableNpNonTargetAlpha and BetterBlizzPlatesDB.enableNpNonFocusAlpha then NameplateTargetAlphaAllNps() end
end)


