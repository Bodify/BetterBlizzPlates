local TOTEM_ICON_GENERIC   = "Interface\\Icons\\Spell_shaman_totemrecall"
local TOTEM_ICON_IMPORTANT = "Interface\\Icons\\Spell_Nature_Groundingtotem"

local TOTEM_COLOR_GROUNDING = { 1,   0,   1   }
local TOTEM_COLOR_CAP       = { 1,   0.69, 0  }
local TOTEM_COLOR_PSYFIEND  = { 0.49, 0, 1 }
local TOTEM_ICON_PSYFIEND   = C_Spell.GetSpellTexture(199824)

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
    local auras = C_UnitAuras.GetUnitAuras(unit, "HELPFUL")
    if auras and #auras > 0 then
        local isImportant = C_Spell.IsSpellImportant(auras[1].spellId)
        return auras[1].icon, isImportant
    end
    return nil, nil
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

local function ApplyGlow(frame, size, color, auraIcon, isImportant)
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
    if auraIcon then
        frame.glowTexture:Show()
        frame.glowTexture:SetVertexColorFromBoolean(
            isImportant,
            CreateColor(unpack(TOTEM_COLOR_GROUNDING)),
            CreateColor(unpack(BetterBlizzPlatesDB.totemIndicatorTotemColor))
        )
        frame.glowTexture:SetAlphaFromBoolean(isImportant, 1, 0)
    else
        frame.glowTexture:SetVertexColor(unpack(color))
        frame.glowTexture:Show()
    end

    if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
        frame.animationGroup:Play()
    end
end

function BBP.ApplyTotemAttributes(frame, iconTexture, color, size, duration, auraIcon, isImportantAura)
    BBP.CreateTotemComponents(frame, size)

    frame.customIcon:SetTexture(iconTexture)
    frame.customIcon:Show()

    if duration then
        if not frame.customCooldown then
            frame.customCooldown = CreateFrame("Cooldown", nil, frame.totemIndicator, "CooldownFrameTemplate")
            frame.customCooldown:SetPoint("TOPLEFT", frame.totemIndicator, "TOPLEFT", 1, -1)
            frame.customCooldown:SetPoint("BOTTOMRIGHT", frame.totemIndicator, "BOTTOMRIGHT", -1, 1)
            frame.customCooldown:SetReverse(true)
        end
        frame.customCooldown:Show()
        frame.customCooldown:SetCooldown(GetTime(), duration)
        if not BetterBlizzPlatesDB.showTotemIndicatorCooldownSwipe then
            frame.customCooldown:SetDrawSwipe(false)
            frame.customCooldown:SetDrawEdge(false)
        end
    elseif frame.customCooldown then
        frame.customCooldown:Hide()
    end

    if (color or auraIcon) and not BetterBlizzPlatesDB.totemIndicatorNoGlow then
        ApplyGlow(frame, size, color, auraIcon, isImportantAura)
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
    local isProbablyTotem = UnitIsMinion(unit) and (not UnitIsOtherPlayersPet(unit) and not UnitIsUnit(unit, "pet"))

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
        config.totemIsImportantAura = nil
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
        local size = 30--isImportant and 30 or 24
        BBP.ApplyTotemAttributes(frame, icon, isImportant and totemColor or nil, size)
        config.totemColorRGB = totemColor

        frame.healthBar:SetStatusBarColor(unpack(totemColor))
        frame.needsRecolor = true
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

        local auraIcon, isImportantAura
        local isCapTotem = UnitCastingInfo(unit)
        local isPsyfiend = UnitChannelInfo(unit)
        local totemColor
        if isPsyfiend then
            totemColor = TOTEM_COLOR_PSYFIEND
        elseif isCapTotem then
            totemColor = TOTEM_COLOR_CAP
        else
            auraIcon, isImportantAura = GetTotemAura(unit)
            totemColor = BetterBlizzPlatesDB.totemIndicatorTotemColor
            C_Timer.After(0.25, function()
                if frame and frame.unit and UnitChannelInfo(frame.unit) then
                    BBP.ApplyTotemIconsAndColorNameplate(frame)
                end
            end)
        end
        local isImportant = isCapTotem or isPsyfiend
        config.totemColorRGB = totemColor
        config.totemIsImportant = isImportant
        config.totemIsImportantAura = isImportantAura
        config.totemAuraColorImportant = TOTEM_COLOR_GROUNDING
        config.totemAuraColorNormal = BetterBlizzPlatesDB.totemIndicatorTotemColor

        if config.totemIndicatorHideAuras then
            frame.AurasFrame:SetAlpha(0)
        end

        local showIcon = auraIcon or isImportant or config.totemIndicatorShowOtherIcons
        local colorHp = isImportant or config.totemIndicatorColorOtherHealthBars

        if auraIcon then
            if config.totemIndicatorColorHealthBar then
                frame.healthBar:GetStatusBarTexture():SetVertexColorFromBoolean(
                    isImportantAura,
                    CreateColor(unpack(TOTEM_COLOR_GROUNDING)),
                    CreateColor(unpack(BetterBlizzPlatesDB.totemIndicatorTotemColor))
                )
                frame.needsRecolor = true
            end
            if config.totemIndicatorColorName or config.totemIndicatorColorNameOthers then
                frame.name:SetVertexColorFromBoolean(
                    isImportantAura,
                    CreateColor(unpack(TOTEM_COLOR_GROUNDING)),
                    CreateColor(unpack(BetterBlizzPlatesDB.totemIndicatorTotemColor))
                )
            end
        else
            if colorHp and config.totemIndicatorColorHealthBar then
                frame.healthBar:SetStatusBarColor(unpack(totemColor))
                frame.needsRecolor = true
            end
            local colorName = isImportant and config.totemIndicatorColorName or config.totemIndicatorColorNameOthers
            if colorName then
                frame.name:SetVertexColor(unpack(totemColor))
            end
        end

        local size = 30--isImportant and 30 or 24
        local duration = isPsyfiend and 12 or isCapTotem and 2 or nil
        local icon = auraIcon or (isPsyfiend and TOTEM_ICON_PSYFIEND) or (isCapTotem and C_Spell.GetSpellTexture(192058)) or TOTEM_ICON_GENERIC
        if showIcon then
            BBP.ApplyTotemAttributes(frame, icon, isImportant and totemColor or nil, size, duration, auraIcon, isImportantAura)
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
        config.totemIsImportantAura = nil
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

    if frame.totemIndicator then
        frame.totemIndicator:ClearAllPoints()
        if config.totemIndicatorHideNameAndShiftIconDown then
            frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, yPosAdjustment)
            frame.name:SetText("")
        else
            frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
        end
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

    if frame.totemIndicator then
        frame.totemIndicator:ClearAllPoints()
        if config.totemIndicatorHideNameAndShiftIconDown then
            frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, yPosAdjustment)
            frame.name:SetText("")
        else
            frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
        end
    end
end

