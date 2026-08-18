local TOTEM_ICON_GENERIC   = "Interface\\Icons\\Spell_shaman_totemrecall"
local TOTEM_ICON_IMPORTANT = "Interface\\Icons\\Spell_Nature_Groundingtotem"

local TOTEM_COLOR_GROUNDING = { 1,   0,   1   }
local TOTEM_COLOR_CAP       = { 1,   0.69, 0  }
local TOTEM_COLOR_PSYFIEND  = { 0.49, 0, 1 }
local TOTEM_ICON_PSYFIEND   = C_Spell.GetSpellTexture(199824)
local TOTEM_ICON_CAPACITOR  = C_Spell.GetSpellTexture(192058)

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

local function CaptureBaseColor(object, cached, cachedFor)
    if cached and cachedFor == object then return cached end
    local r, g, b, a = object:GetVertexColor()
    if r == nil or issecretvalue(r) then r, g, b, a = 1, 1, 1, 1 end
    return CreateColor(r, g, b, a or 1)
end

local function PaintTotemHealthbarFromBoolean(frame, uninterruptible, r, g, b)
    local bar = frame.healthBar
    local texture = bar and bar.GetStatusBarTexture and bar:GetStatusBarTexture()
    if not texture or not texture.SetVertexColorFromBoolean then return false end

    local base = CaptureBaseColor(texture, frame.totemHealthbarBaseColor, frame.totemHealthbarOverlaid)
    frame.totemHealthbarBaseColor = base
    frame.totemHealthbarOverlaid = texture

    local overlay = frame.totemHealthbarOverlayColor
    if not overlay then
        overlay = CreateColor(1, 1, 1, 1)
        frame.totemHealthbarOverlayColor = overlay
    end
    overlay:SetRGBA(r, g, b, base.a)

    texture:SetVertexColorFromBoolean(uninterruptible, overlay, base)
    return true
end

local function PaintTotemNameFromBoolean(frame, uninterruptible, r, g, b)
    local name = frame.name
    if not name or not name.SetVertexColorFromBoolean then return false end

    local base = CaptureBaseColor(name, frame.totemNameBaseColor, frame.totemNameOverlaid)
    frame.totemNameBaseColor = base
    frame.totemNameOverlaid = name

    local overlay = frame.totemNameOverlayColor
    if not overlay then
        overlay = CreateColor(1, 1, 1, 1)
        frame.totemNameOverlayColor = overlay
    end
    overlay:SetRGBA(r, g, b, base.a)

    name:SetVertexColorFromBoolean(uninterruptible, overlay, base)
    return true
end

local function ClearTotemBooleanColors(frame)
    local texture = frame.totemHealthbarOverlaid
    local base    = frame.totemHealthbarBaseColor
    frame.totemHealthbarOverlaid   = nil
    frame.totemHealthbarBaseColor = nil
    if texture and base then
        texture:SetVertexColor(base.r, base.g, base.b, base.a)
    end

    local name     = frame.totemNameOverlaid
    local nameBase = frame.totemNameBaseColor
    frame.totemNameOverlaid    = nil
    frame.totemNameBaseColor = nil
    if name and nameBase then
        name:SetVertexColor(nameBase.r, nameBase.g, nameBase.b, nameBase.a)
    end
end

local function ClearPsyfiendIconAlpha(frame)
    if frame.customIcon then frame.customIcon:SetAlpha(1) end
    if frame.glowTexture then frame.glowTexture:SetAlpha(1) end
    if frame.customCooldown then frame.customCooldown:SetAlpha(1) end
end

BBP.PaintTotemHealthbarFromBoolean = PaintTotemHealthbarFromBoolean
BBP.PaintTotemNameFromBoolean = PaintTotemNameFromBoolean
BBP.ClearTotemBooleanColors = ClearTotemBooleanColors
BBP.ClearPsyfiendIconAlpha = ClearPsyfiendIconAlpha

local AF = AuraUtil.AuraFilters
local TOTEM_AURA_SIZE = 30

local function InitTotemAuraIcon(auraFrame, container)
    auraFrame:SetSize(TOTEM_AURA_SIZE, TOTEM_AURA_SIZE)
    auraFrame:SetPoint("CENTER", container, "CENTER", 0, 0)
    auraFrame:SetFrameLevel(container:GetFrameLevel() + 2)

    local icon = auraFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(auraFrame)
    auraFrame:SetIcon(icon)

    local mask = auraFrame:CreateMaskTexture()
    mask:SetTexture("Interface\\TalentFrame\\talentsmasknodechoiceflyout",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)

    if not BetterBlizzPlatesDB.totemIndicatorNoGlow then
        local offset = TOTEM_AURA_SIZE * 0.41
        local glow = auraFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        glow:SetAtlas("clickcast-highlight-spellbook")
        glow:SetBlendMode("ADD")
        glow:SetDesaturated(true)
        glow:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -offset, offset)
        glow:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", offset, -offset)
        glow:SetVertexColor(TOTEM_COLOR_GROUNDING[1], TOTEM_COLOR_GROUNDING[2], TOTEM_COLOR_GROUNDING[3])
    end

    auraFrame:SetCancelAuraButtons(nil)
    auraFrame:SetHideTooltipInCombat(true)
    if not InCombatLockdown() then
        auraFrame:SetMouseMotionEnabled(false)
    end
end

local function InitTotemOverlaySlot(auraFrame, frame)
    auraFrame:SetSize(1, 1)

    local bar = frame.HealthBarsContainer.healthBar
    local fill = bar and bar.GetStatusBarTexture and bar:GetStatusBarTexture()
    if fill then
        local overlay = auraFrame:CreateTexture(nil, "ARTWORK")
        overlay:SetAllPoints(fill)
        local atlas = fill:GetAtlas()
        if atlas then
            overlay:SetAtlas(atlas)
        else
            overlay:SetTexture(fill:GetTexture())
        end
        overlay:SetVertexColor(TOTEM_COLOR_GROUNDING[1], TOTEM_COLOR_GROUNDING[2], TOTEM_COLOR_GROUNDING[3], 1)

        if not BetterBlizzPlatesDB.classicNameplates and not BetterBlizzPlatesDB.classicRetailNameplates then
            BBP.ApplyMidnightMask(frame, overlay)
        end
    end

    auraFrame:SetCancelAuraButtons(nil)
    auraFrame:SetHideTooltipInCombat(true)
    if not InCombatLockdown() then
        auraFrame:SetMouseMotionEnabled(false)
    end
end

local HELPFUL_IMPORTANT = AuraUtil.CreateFilterString(AF.Helpful, AF.Important)

local function CreateTotemAuraContainers(frame)
    if not frame.healthBar or not frame.totemIndicator then return end

    if not frame.totemAuraContainer then
        local container = CreateFrame("AuraContainer", nil, frame.totemIndicator, "CustomAuraContainerTemplate")
        container:SetSize(1, 1)
        container:SetFrameLevel(frame.totemIndicator:GetFrameLevel() + 5)
        container:SetPoint("CENTER", frame.totemIndicator, "CENTER", 0, 0)
        container:SetEnabled(false)
        container:Hide()
        frame.totemAuraContainer = container

        container:AddAuraSlot("Important", HELPFUL_IMPORTANT, {
            initializeFrame = function(auraFrame)
                InitTotemAuraIcon(auraFrame, container)
            end,
        })
    end

    if not frame.totemOverlayContainer then
        local overlayContainer = CreateFrame("AuraContainer", nil, frame.healthBar, "CustomAuraContainerTemplate")
        overlayContainer:SetSize(1, 1)
        overlayContainer:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)
        overlayContainer:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
        overlayContainer:SetEnabled(false)
        overlayContainer:Hide()
        frame.totemOverlayContainer = overlayContainer

        overlayContainer:AddAuraSlot("Overlay", HELPFUL_IMPORTANT, {
            initializeFrame = function(auraFrame) InitTotemOverlaySlot(auraFrame, frame) end,
        })
    end
end

local function SetTotemAuraContainerEnabled(container, unit)
    if not container then return end

    if not unit then
        container:SetEnabled(false)
        container:Hide()
        return
    end

    container:SetUnit(unit)
    container:SetEnabled(true)
    container:Show()
end

local function ScheduleTotemCastRecheck(frame)
    if frame.totemRecheckArmed then return end
    frame.totemRecheckArmed = true

    C_Timer.After(0.25, function()
        if not frame.unit or not frame.BetterBlizzPlates then return end
        if UnitChannelInfo(frame.unit) then
            BBP.ApplyTotemIconsAndColorNameplate(frame)
        end
    end)
end

local function DisableTotemAuraContainer(frame)
    frame.totemRecheckArmed = nil
    if not frame.totemAuraContainer and not frame.totemOverlayContainer then return end
    SetTotemAuraContainerEnabled(frame.totemAuraContainer, nil)
    SetTotemAuraContainerEnabled(frame.totemOverlayContainer, nil)
end

local function UpdateTotemAuraContainer(frame)
    ScheduleTotemCastRecheck(frame)
    SetTotemAuraContainerEnabled(frame.totemAuraContainer, frame.unit)
    SetTotemAuraContainerEnabled(frame.totemOverlayContainer,
        BetterBlizzPlatesDB.totemIndicatorColorHealthBar and frame.unit or nil)
end

BBP.DisableTotemAuraContainer = DisableTotemAuraContainer

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
    frame.glowTexture:SetAlpha(1)
    frame.glowTexture:SetVertexColor(unpack(color))
    frame.glowTexture:Show()

    if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
        frame.animationGroup:Play()
    end
end

function BBP.ApplyTotemAttributes(frame, iconTexture, color, size, duration)
    BBP.CreateTotemComponents(frame, size)

    frame.totemIndicator:Show()
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

    if color and not BetterBlizzPlatesDB.totemIndicatorNoGlow then
        ApplyGlow(frame, size, color)
    else
        if frame.animationGroup then frame.animationGroup:Stop() end
        if frame.glowTexture then frame.glowTexture:Hide() end
    end
end

local TOTEM_TEST_TYPES = {
    grounding = { icon = TOTEM_ICON_IMPORTANT, color = TOTEM_COLOR_GROUNDING, isImportant = true  },
    capacitor = { icon = TOTEM_ICON_CAPACITOR, color = TOTEM_COLOR_CAP,       isImportant = true  },
    psyfiend  = { icon = TOTEM_ICON_PSYFIEND,  color = TOTEM_COLOR_PSYFIEND,  isImportant = true  },
    others    = { icon = TOTEM_ICON_GENERIC,   color = nil,                   isImportant = false },
}

local function RollTestTotemType(config)
    local roll = math.random()
    if config.totemIndicatorShowOtherIcons then
        if roll < 0.25 then return "grounding"
        elseif roll < 0.50 then return "capacitor"
        elseif roll < 0.70 then return "psyfiend"
        else return "others" end
    else
        if roll < 0.34 then return "grounding"
        elseif roll < 0.67 then return "capacitor"
        else return "psyfiend" end
    end
end

function BBP.IsProbablyTotem(unit)
    return UnitIsMinion(unit) and (not UnitIsOtherPlayersPet(unit) and not UnitIsUnit(unit, "pet"))
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
    local isProbablyTotem = BBP.IsProbablyTotem(unit)

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
        config.totemUninterruptible = nil
        ClearTotemBooleanColors(frame)
        ClearPsyfiendIconAlpha(frame)
        DisableTotemAuraContainer(frame)
        return
    end

    if config.totemIndicatorTestMode then
        DisableTotemAuraContainer(frame)
        config.totemUninterruptible = nil
        ClearTotemBooleanColors(frame)
        ClearPsyfiendIconAlpha(frame)

        if not config.totemTestType
            or (config.totemTestType == "others" and not config.totemIndicatorShowOtherIcons) then
            config.totemTestType = RollTestTotemType(config)
        end

        local preview = TOTEM_TEST_TYPES[config.totemTestType]
        local icon = preview.icon or TOTEM_ICON_GENERIC
        local totemColor = preview.color or BetterBlizzPlatesDB.totemIndicatorTotemColor
        local isImportant = preview.isImportant
        local size = 30--isImportant and 30 or 24
        BBP.ApplyTotemAttributes(frame, icon, isImportant and totemColor or nil, size)
        config.totemColorRGB = totemColor
        config.totemIsImportant = isImportant

        frame.healthBar:SetStatusBarColor(unpack(totemColor))
        frame.needsRecolor = true
        frame.name:SetVertexColor(unpack(totemColor))

        if config.totemIndicatorHideNameAndShiftIconDown then
            frame.name:SetText("")
        end

        if config.totemIndicatorHideAuras then
            BBP.SetNameplateAurasShown(frame, false)
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
            DisableTotemAuraContainer(frame)
            return
        end

        local isCapTotem = UnitCastingInfo(unit) ~= nil
        local channelName, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
        local isPsyfiend = channelName ~= nil

        local uninterruptible
        if isPsyfiend then
            uninterruptible = notInterruptible
        else
            ClearTotemBooleanColors(frame)
            ClearPsyfiendIconAlpha(frame)
        end

        local totemColor
        if isPsyfiend then
            totemColor = TOTEM_COLOR_PSYFIEND
            DisableTotemAuraContainer(frame)
        elseif isCapTotem then
            totemColor = TOTEM_COLOR_CAP
            DisableTotemAuraContainer(frame)
        else
            BBP.CreateTotemComponents(frame, 30)
            CreateTotemAuraContainers(frame)
            UpdateTotemAuraContainer(frame)
            totemColor = BetterBlizzPlatesDB.totemIndicatorTotemColor
        end
        local isImportant = isCapTotem or isPsyfiend
        config.totemColorRGB = totemColor
        config.totemIsImportant = isImportant
        config.totemUninterruptible = uninterruptible

        if config.totemIndicatorHideAuras then
            BBP.SetNameplateAurasShown(frame, false)
        end

        local showIcon = isImportant or config.totemIndicatorShowOtherIcons
        local colorHp = isImportant or config.totemIndicatorColorOtherHealthBars

        if colorHp and config.totemIndicatorColorHealthBar then
            if uninterruptible == nil or not PaintTotemHealthbarFromBoolean(frame, uninterruptible, unpack(totemColor)) then
                frame.healthBar:SetStatusBarColor(unpack(totemColor))
            end
            frame.needsRecolor = true
        end
        local colorName = isImportant and config.totemIndicatorColorName or config.totemIndicatorColorNameOthers
        if colorName then
            if uninterruptible == nil or not PaintTotemNameFromBoolean(frame, uninterruptible, unpack(totemColor)) then
                frame.name:SetVertexColor(unpack(totemColor))
            end
        end

        local size = 30--isImportant and 30 or 24
        local duration = isPsyfiend and 12 or isCapTotem and 2 or nil
        local icon = (isPsyfiend and TOTEM_ICON_PSYFIEND) or (isCapTotem and TOTEM_ICON_CAPACITOR) or TOTEM_ICON_GENERIC
        if showIcon then
            BBP.ApplyTotemAttributes(frame, icon, isImportant and totemColor or nil, size, duration)
            if isPsyfiend then
                frame.customIcon:SetAlphaFromBoolean(uninterruptible, 1, 0)
                if frame.glowTexture then
                    frame.glowTexture:SetAlphaFromBoolean(uninterruptible, 1, 0)
                end
                if frame.customCooldown then
                    frame.customCooldown:SetAlphaFromBoolean(uninterruptible, 1, 0)
                end
            end
        elseif frame.totemIndicator then
            frame.customIcon:Hide()
            if frame.glowTexture then frame.glowTexture:Hide() end
            if frame.customCooldown then frame.customCooldown:Hide() end
            if frame.animationGroup then frame.animationGroup:Stop() end
            frame.totemIndicator:Show()
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
        config.totemUninterruptible = nil
        ClearTotemBooleanColors(frame)
        ClearPsyfiendIconAlpha(frame)
        DisableTotemAuraContainer(frame)
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
