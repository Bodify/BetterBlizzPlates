local TOTEM_ICON_GENERIC   = "Interface\\Icons\\Spell_shaman_totemrecall"
local TOTEM_ICON_IMPORTANT = "Interface\\Icons\\Spell_Nature_Groundingtotem"

local TOTEM_COLOR_GROUNDING = { 1,   0,   1   }
local TOTEM_COLOR_CAP       = { 1,   0.69, 0  }

function BBP.SetupUnifiedAnimation(frameWithAnimations)
    local animationGroup = frameWithAnimations:CreateAnimationGroup()

    local grow = animationGroup:CreateAnimation("Scale")
    grow:SetOrder(1)
    grow:SetScale(1.1, 1.1)
    grow:SetDuration(0.5)

    local shrink = animationGroup:CreateAnimation("Scale")
    shrink:SetOrder(2)
    shrink:SetScale(0.9091, 0.9091)
    shrink:SetDuration(0.5)

    animationGroup:SetLooping("REPEAT")

    return animationGroup
end

local function GetTotemAura(unit)
    local auras = C_UnitAuras.GetUnitAuras(unit, "HELPFUL|IMPORTANT")
    if auras and #auras > 0 then
        local isImportant = C_Spell.IsSpellImportant(auras[1].spellId)
        if issecretvalue(isImportant) or isImportant then
            return auras[1].icon, true
        end
    end
    local auras = C_UnitAuras.GetUnitAuras(unit, "HELPFUL")
    if auras and #auras > 0 then
        return auras[1].icon, false
    end
    return nil, false
end

function BBP.CreateTotemComponents(frame, size)
    local config = frame.BetterBlizzPlates.config
    if not frame.totemIndicator then
        frame.totemIndicator = CreateFrame("Frame", nil, frame)
        frame.totemIndicator:SetSize(size, size)
        frame.totemIndicator:SetScale(config.totemIndicatorScale or 1)
        frame.totemIndicator:SetFrameStrata("HIGH")

        frame.customIcon = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
        frame.customIcon:SetAllPoints(frame.totemIndicator)

        frame.animationGroup = BBP.SetupUnifiedAnimation(frame.totemIndicator)
    end
    frame.totemIndicator:SetSize(size, size)
    frame.totemIndicator:SetScale(config.totemIndicatorScale or 1)

    local anchorFrame
    if config.totemIndicatorHideNameAndShiftIconDown then
        anchorFrame = frame.healthBar
    elseif config.totemIndicatorAnchor == "TOP" then
        anchorFrame = frame.name
    else
        anchorFrame = frame.healthBar
    end
    local yOffset = config.totemIndicatorHideNameAndShiftIconDown
        and (config.totemIndicatorYPos + 4)
        or config.totemIndicatorYPos

    frame.totemIndicator:ClearAllPoints()
    frame.totemIndicator:SetPoint(
        BBP.GetOppositeAnchor(config.totemIndicatorAnchor),
        anchorFrame,
        config.totemIndicatorAnchor,
        config.totemIndicatorXPos,
        yOffset
    )
end

local function ApplyGlow(frame, size, color)
    if not frame.glowTexture then
        frame.glowTexture = frame.totemIndicator:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.glowTexture:SetBlendMode("ADD")
        frame.glowTexture:SetAtlas("clickcast-highlight-spellbook")
        frame.glowTexture:SetDesaturated(true)

        frame.totemIndicator.Mask = frame.totemIndicator:CreateMaskTexture()
        frame.totemIndicator.Mask:SetTexture(
            "Interface\\TalentFrame\\talentsmasknodechoiceflyout",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"
        )
        frame.totemIndicator.Mask:SetAllPoints(frame.customIcon)
        frame.customIcon:AddMaskTexture(frame.totemIndicator.Mask)
    end

    local offset = size * 0.41
    frame.glowTexture:ClearAllPoints()
    frame.glowTexture:SetPoint("TOPLEFT",     frame.totemIndicator, "TOPLEFT",     -offset,  offset)
    frame.glowTexture:SetPoint("BOTTOMRIGHT", frame.totemIndicator, "BOTTOMRIGHT",  offset, -offset)
    frame.glowTexture:SetVertexColor(unpack(color))
    frame.glowTexture:Show()

    if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
        frame.animationGroup:Play()
    end
end

function BBP.ApplyTotemAttributes(frame, iconTexture, color, size)
    BBP.CreateTotemComponents(frame, size)

    frame.customIcon:SetTexture(iconTexture)
    frame.customIcon:Show()

    if color then
        ApplyGlow(frame, size, color)
    else
        if frame.animationGroup then frame.animationGroup:Stop() end
        if frame.glowTexture then frame.glowTexture:Hide() end
    end
end

function BBP.ApplyTotemIconsAndColorNameplate(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.totemIndicatorInitialized or BBP.needsUpdate then
        config.totemIndicatorXPos = BetterBlizzPlatesDB.totemIndicatorXPos
        config.totemIndicatorYPos = BetterBlizzPlatesDB.totemIndicatorYPos

        config.totemIndicatorHideNameAndShiftIconDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
        config.totemIndicatorTestMode = BetterBlizzPlatesDB.totemIndicatorTestMode
        config.totemIndicatorHideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar
        config.totemIndicatorEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
        config.hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
        config.totemIndicatorAnchor = BetterBlizzPlatesDB.totemIndicatorAnchor
        config.totemIndicatorScale = BetterBlizzPlatesDB.totemIndicatorScale
        config.totemIndicatorColorHealthBar = BetterBlizzPlatesDB.totemIndicatorColorHealthBar
        config.totemIndicatorColorName = BetterBlizzPlatesDB.totemIndicatorColorName
        config.totemIndicatorColorNameOthers = BetterBlizzPlatesDB.totemIndicatorColorNameOthers
        config.totemIndicatorHideAuras = BetterBlizzPlatesDB.totemIndicatorHideAuras
        config.totemIndicatorShowOtherIcons = BetterBlizzPlatesDB.totemIndicatorShowOtherIcons
        config.totemIndicatorColorOtherHealthBars = BetterBlizzPlatesDB.totemIndicatorColorOtherHealthBars

        config.totemIndicatorInitialized = true
    end

    local unit = frame.unit
    local isProbablyTotem = UnitIsMinion(unit) and not UnitIsOtherPlayersPet(unit)

    local totemIndicatorSwappingAnchor
    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = frame.healthBar
    elseif config.totemIndicatorAnchor == "TOP" then
        totemIndicatorSwappingAnchor = frame.name
    else
        totemIndicatorSwappingAnchor = frame.healthBar
    end

    local yPosAdjustment = config.totemIndicatorHideNameAndShiftIconDown and config.totemIndicatorYPos + 4 or config.totemIndicatorYPos

    if not config.totemIndicatorTestMode and not isProbablyTotem then
        config.totemColorRGB = nil
        config.totemIsImportant = nil
        return
    end

    if config.totemIndicatorTestMode then

        local roll = math.random()
        local isImportant, totemColor, icon
        if roll < 0.25 then
            isImportant = true
            totemColor = TOTEM_COLOR_GROUNDING
            icon = TOTEM_ICON_IMPORTANT
        elseif roll < 0.35 then
            isImportant = true
            totemColor = TOTEM_COLOR_CAP
            icon = C_Spell.GetSpellTexture(192058) or TOTEM_ICON_GENERIC
        else
            isImportant = false
            totemColor = BetterBlizzPlatesDB.totemIndicatorTotemColor
            icon = TOTEM_ICON_GENERIC
        end
        local size = isImportant and 30 or 24
        BBP.ApplyTotemAttributes(frame, icon, isImportant and totemColor or nil, size)
        config.totemColorRGB = totemColor

        frame.healthBar:SetStatusBarColor(unpack(totemColor))
        frame.name:SetVertexColor(unpack(totemColor))

        if config.totemIndicatorHideNameAndShiftIconDown then
            frame.name:SetText("")
        end

        if config.totemIndicatorHideAuras then
            frame.AurasFrame:SetAlpha(0)
        end

        if config.totemIndicatorHideHealthBar then
            if not info.isTarget then
                frame.HealthBarsContainer:SetAlpha(0)
                frame.HealthBarsContainer.alphaZero = true
                frame.selectionHighlight:SetAlpha(0)
            else
                frame.HealthBarsContainer:SetAlpha(1)
                frame.HealthBarsContainer.alphaZero = false
                if not config.hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end

    elseif isProbablyTotem then
        if config.totemIndicatorEnemyOnly and info.isFriend then
            return
        end

        local auraIcon, isImportantAura = GetTotemAura(unit)
        local isCapTotem = UnitCastingInfo(unit)
        local totemColor
        if isImportantAura then
            totemColor = TOTEM_COLOR_GROUNDING
        elseif isCapTotem then
            totemColor = TOTEM_COLOR_CAP
        else
            totemColor = BetterBlizzPlatesDB.totemIndicatorTotemColor
        end
        local isImportant = isImportantAura or isCapTotem
        config.totemColorRGB = totemColor
        config.totemIsImportant = isImportant

        if config.totemIndicatorHideAuras then
            frame.AurasFrame:SetAlpha(0)
        end

        local showIcon = isImportant or config.totemIndicatorShowOtherIcons
        local colorHp = isImportant or config.totemIndicatorColorOtherHealthBars

        if colorHp and config.totemIndicatorColorHealthBar then
            frame.healthBar:SetStatusBarColor(unpack(totemColor))
        end
        local colorName = isImportant and config.totemIndicatorColorName or config.totemIndicatorColorNameOthers
        if colorName then
            frame.name:SetVertexColor(unpack(totemColor))
        end

        local size = isImportant and 30 or 24
        local icon = auraIcon or (isCapTotem and C_Spell.GetSpellTexture(192058)) or TOTEM_ICON_GENERIC
        if showIcon then
            BBP.ApplyTotemAttributes(frame, icon, isImportant and totemColor or nil, size)
        else
            if frame.totemIndicator then frame.totemIndicator:Hide() end
        end

        if config.totemIndicatorHideHealthBar then
            if not info.isTarget then
                frame.HealthBarsContainer:SetAlpha(0)
                frame.HealthBarsContainer.alphaZero = true
                frame.selectionHighlight:SetAlpha(0)
            else
                frame.HealthBarsContainer:SetAlpha(1)
                frame.HealthBarsContainer.alphaZero = false
                if not config.hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end

    else
        config.totemColorRGB = nil
        if frame.animationGroup then
            frame.animationGroup:Stop()
        end
    end

    if frame.glowTexture then
        if frame.glowTexture:IsShown() then
            frame.customIcon:AddMaskTexture(frame.totemIndicator.Mask)
        else
            frame.customIcon:RemoveMaskTexture(frame.totemIndicator.Mask)
        end
    end

    frame.totemIndicator:ClearAllPoints()
    if config.totemIndicatorHideNameAndShiftIconDown then
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, yPosAdjustment)
        frame.name:SetText("")
    else
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    end
end

function BBP.UpdateTotemPos(frame)
    local config = frame.BetterBlizzPlates.config

    config.totemIndicatorXPos = BetterBlizzPlatesDB.totemIndicatorXPos
    config.totemIndicatorYPos = BetterBlizzPlatesDB.totemIndicatorYPos
    config.totemIndicatorHideNameAndShiftIconDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
    config.totemIndicatorAnchor = BetterBlizzPlatesDB.totemIndicatorAnchor

    local totemIndicatorSwappingAnchor
    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = frame.healthBar
    elseif config.totemIndicatorAnchor == "TOP" then
        totemIndicatorSwappingAnchor = frame.name
    else
        totemIndicatorSwappingAnchor = frame.healthBar
    end

    local yPosAdjustment = config.totemIndicatorHideNameAndShiftIconDown and config.totemIndicatorYPos + 4 or config.totemIndicatorYPos

    frame.totemIndicator:ClearAllPoints()
    if config.totemIndicatorHideNameAndShiftIconDown then
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, yPosAdjustment)
        frame.name:SetText("")
    else
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    end
end

