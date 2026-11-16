local TOTEM_ICON_GENERIC        = "Interface\\Icons\\Spell_shaman_totemrecall"
local TOTEM_ICON_IMPORTANT      = "Interface\\Icons\\Spell_Nature_Groundingtotem"
local TOTEM_ICON_PSYFIEND       = C_Spell.GetSpellTexture(199824)
local TOTEM_ICON_CAPACITOR      = C_Spell.GetSpellTexture(192058)
local TOTEM_ICON_HEALING_STREAM = C_Spell.GetSpellTexture(5394)

local TOTEM_DURATION_CAPACITOR = 2
local TOTEM_DURATION_PSYFIEND  = 12

local TOTEM_COLOR_DB_KEYS = {
    grounding     = "totemIndicatorColorGrounding",
    capacitor     = "totemIndicatorColorCapacitor",
    psyfiend      = "totemIndicatorColorPsyfiend",
    healingStream = "totemIndicatorColorHealingStream",
    others        = "totemIndicatorTotemColor",
}

local TOTEM_COLOR_DEFAULTS = {
    grounding     = { 1,    0,    1    },
    capacitor     = { 1,    0.69, 0    },
    psyfiend      = { 0.49, 0,    1    },
    healingStream = { 0,    1,    0.78 },
    others        = { 0.4,  0.34, 0.21 },
}

local function GetTotemColor(colorKey)
    return BetterBlizzPlatesDB[TOTEM_COLOR_DB_KEYS[colorKey]] or TOTEM_COLOR_DEFAULTS[colorKey]
end

BBP.GetTotemColor = GetTotemColor

local FOREVER_TOTEMS = {
    { key = "healingStream",    spellID = 5394,  npcIDs = { 3527, 3906, 3907, 3908, 3909 },        color = { 0, 1, 0.78 },       important = true,  duration = 60 },
    { key = "grounding",        spellID = 8177,  npcIDs = { 5925 },                                color = { 1, 0, 1 },          important = true,  duration = 45 },
    { key = "tremor",           spellID = 8143,  npcIDs = { 5913 },                                color = { 0.49, 0.9, 0.08 },  important = true,  duration = 120 },
    { key = "manaTide",         spellID = 16190, npcIDs = { 10467, 11100, 11101 },                 color = { 0.08, 0.82, 0.78 }, important = true,  duration = 12 },
    { key = "stoneclaw",        spellID = 5730,  npcIDs = { 3579, 3911, 3912, 3913, 7398, 7399 },  color = { 0.78, 0.51, 0.39 }, important = true,  duration = 15 },
    { key = "earthbind",        spellID = 2484,  npcIDs = { 2630 },                                color = { 0.78, 0.51, 0.39 }, important = false, duration = 45 },
    { key = "searing",          spellID = 3599,  npcIDs = { 2523, 3902, 3903, 3904, 7400, 7402 },  color = { 1, 0.23, 0 },       important = false, durations = { 30, 35, 40, 45, 50, 55 } },
    { key = "magma",            spellID = 8190,  npcIDs = { 5929, 7464, 7465, 7466 },              color = { 1, 0.23, 0 },       important = false, duration = 20 },
    { key = "flametongue",      spellID = 8227,  npcIDs = { 5950, 6012, 7423, 10557 },             color = { 1, 0.23, 0 },       important = false, duration = 120 },
    { key = "windfury",         spellID = 8512,  npcIDs = { 6112, 7483, 7484 },                    color = { 0.70, 0.98, 1 },    important = false, duration = 120 },
    { key = "graceOfAir",       spellID = 8835,  npcIDs = { 7486, 7487, 15463 },                   color = { 0.70, 0.98, 1 },    important = false, duration = 120 },
    { key = "windwall",         spellID = 15107, npcIDs = { 9687, 9688, 9689 },                    color = { 0.70, 0.98, 1 },    important = false, duration = 120 },
    { key = "sentry",           spellID = 6495,  npcIDs = { 3968 },                                color = { 0.70, 0.98, 1 },    important = false, duration = 300 },
    { key = "manaSpring",       spellID = 5675,  npcIDs = { 3573, 7414, 7415, 7416 },              color = { 0.70, 0.98, 1 },    important = false, duration = 60 },
    { key = "poisonCleansing",  spellID = 8166,  npcIDs = { 5923 },                                color = { 0.08, 0.82, 0.78 }, important = false, duration = 120 },
    { key = "diseaseCleansing", spellID = 8170,  npcIDs = { 5924 },                                color = { 0.08, 0.82, 0.78 }, important = false, duration = 120 },
    { key = "strengthOfEarth",  spellID = 8075,  npcIDs = { 5874, 5921, 5922, 7403 },              color = { 0.78, 0.51, 0.39 }, important = false, duration = 120 },
    { key = "stoneskin",        spellID = 8071,  npcIDs = { 5873, 5919, 5920, 7366, 7367, 7368 },  color = { 0.78, 0.51, 0.39 }, important = false, duration = 120 },
    { key = "fireResistance",   spellID = 8184,  npcIDs = { 5927, 7424, 7425 },                    color = { 0.08, 0.82, 0.78 }, important = false, duration = 120 },
    { key = "frostResistance",  spellID = 8181,  npcIDs = { 5926, 7412, 7413 },                    color = { 0.08, 0.82, 0.78 }, important = false, duration = 120 },
    { key = "natureResistance", spellID = 10595, npcIDs = { 7467, 7468, 7469 },                    color = { 0.08, 0.82, 0.78 }, important = false, duration = 120 },
}

BBP.ForeverTotemList = FOREVER_TOTEMS

local ROMAN_RANKS = { II = 2, III = 3, IV = 4, V = 5, VI = 6, VII = 7, VIII = 8, IX = 9, X = 10 }

local totemsByName, totemsByNpcID

local function BuildTotemLookups()
    totemsByName, totemsByNpcID = {}, {}
    for _, totem in ipairs(FOREVER_TOTEMS) do
        totem.icon = C_Spell.GetSpellTexture(totem.spellID)
        totemsByName[C_Spell.GetSpellName(totem.spellID)] = totem
        for rank, npcID in ipairs(totem.npcIDs) do
            totemsByNpcID[npcID] = { totem = totem, rank = rank }
        end
    end
end

local function LookupKnownTotem(unit)
    local guid = UnitGUID(unit)
    local name = UnitName(unit)
    if issecretvalue(guid) or issecretvalue(name) then return end
    if not totemsByName then BuildTotemLookups() end

    local totem = totemsByName[name]
    if totem then return totem, 1, guid end

    local baseName, numeral = name:match("^(.-) ([IVX]+)$")
    totem = baseName and totemsByName[baseName]
    if totem then return totem, ROMAN_RANKS[numeral] or 1, guid end

    local npcID = tonumber(guid:match("%-(%d+)%-%x+$"))
    local entry = npcID and totemsByNpcID[npcID]
    if entry then return entry.totem, entry.rank, guid end
end

local SPAWN_EPOCH = 2 ^ 23
local firstSeen = {}
local firstSeenCount = 0

local function GetTotemStartTime(guid, duration)
    local now = GetTime()
    local spawnUID = guid:match("%-(%x+)$")
    if spawnUID and #spawnUID >= 10 then
        local serverTime = GetServerTime()
        local spawnTime = serverTime - (serverTime % SPAWN_EPOCH) + bit.band(tonumber(spawnUID:sub(5), 16), 0x7fffff)
        if spawnTime > serverTime then
            spawnTime = spawnTime - SPAWN_EPOCH
        end
        local elapsed = serverTime - spawnTime
        if elapsed >= 0 and elapsed <= duration then
            return now - elapsed
        end
    end

    local seen = firstSeen[guid]
    if not seen then
        if firstSeenCount >= 200 then
            wipe(firstSeen)
            firstSeenCount = 0
        end
        seen = now
        firstSeen[guid] = seen
        firstSeenCount = firstSeenCount + 1
    end
    return seen
end

local function ConfigureTotemCooldown(cooldown)
    cooldown:SetMinimumCountdownDuration(0)
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawSwipe(BetterBlizzPlatesDB.showTotemIndicatorCooldownSwipe and true or false)
    cooldown:SetHideCountdownNumbers(BetterBlizzPlatesDB.totemIndicatorHideCountdownNumbers and true or false)

    local countdownText = cooldown.GetCountdownFontString and cooldown:GetCountdownFontString()
    if countdownText then
        countdownText:SetScale(BetterBlizzPlatesDB.totemIndicatorDefaultCooldownTextSize or 0.85)
    end
end

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

local HELPFUL_IMPORTANT = AuraUtil.CreateFilterString(AF.Helpful, AF.Important)
local HELPFUL_NOT_IMPORTANT = AuraUtil.CreateFilterString(AF.Helpful, "!" .. AF.Important)

local function GetHealthbarFill(frame)
    local bar = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar
    if not bar or not bar.GetStatusBarTexture then return nil end
    return bar:GetStatusBarTexture()
end

local function CreateTotemOverlayAnchor(frame)
    if frame.totemOverlayAnchor then return end

    local anchor = CreateFrame("Frame", nil, frame)
    anchor:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    anchor:SetSize(0, 0)
    frame.totemOverlayAnchor = anchor

    local fill = GetHealthbarFill(frame)
    if not fill then return end

    local atlas = fill.GetAtlas and fill:GetAtlas()
    if atlas then
        frame.totemOverlayAtlas = atlas
    else
        frame.totemOverlayTexture = fill:GetTexture()
    end
end

local function RefreshTotemOverlayAnchor(frame)
    local anchor = frame.totemOverlayAnchor
    if not anchor then return end

    local fill = BetterBlizzPlatesDB.totemIndicatorColorHealthBar and GetHealthbarFill(frame) or nil

    anchor:ClearAllPoints()

    if not fill then
        anchor:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        anchor:SetSize(0, 0)
        return
    end

    anchor:SetAllPoints(fill)
end

local function RaiseTotemNameplateName(frame)
    if BetterBlizzPlatesDB.useFakeName or not frame.name then return end

    if not frame.newNameParent then
        frame.newNameParent = CreateFrame("Frame", nil, frame)
        frame.newNameParent:SetAllPoints(frame)
        frame.newNameParent:SetFrameStrata("DIALOG")
    end

    frame.name:SetParent(frame.newNameParent)
    frame.name:SetDrawLayer("OVERLAY", 7)
end

local function InitTotemAuraOverlay(auraFrame, frame, color)
    local anchor = frame.totemOverlayAnchor
    local bar = frame.healthBar
    if not anchor or not bar then return end

    local host = CreateFrame("Frame", nil, auraFrame)
    host:SetFrameStrata(bar:GetFrameStrata())
    host:SetFrameLevel(bar:GetFrameLevel() + 1)
    host:SetAllPoints(anchor)

    local overlay = host:CreateTexture(nil, "ARTWORK")
    overlay:SetAllPoints(anchor)
    if frame.totemOverlayAtlas then
        overlay:SetAtlas(frame.totemOverlayAtlas)
    elseif frame.totemOverlayTexture then
        overlay:SetTexture(frame.totemOverlayTexture)
    end
    overlay:SetVertexColor(color[1], color[2], color[3], 1)

    if not BetterBlizzPlatesDB.classicNameplates and not BetterBlizzPlatesDB.classicRetailNameplates then
        BBP.ApplyMidnightMask(frame, overlay)
    end
end

local function InitTotemAuraIcon(auraFrame, frame, container, colorKey, useGlow)
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

    local cooldown = CreateFrame("Cooldown", nil, auraFrame, "CooldownFrameTemplate")
    cooldown:ClearAllPoints()
    cooldown:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", 1, -1)
    cooldown:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", -1, 1)
    ConfigureTotemCooldown(cooldown)
    auraFrame:SetDurationCooldown(cooldown)

    local color = GetTotemColor(colorKey)

    InitTotemAuraOverlay(auraFrame, frame, color)

    if useGlow and not BetterBlizzPlatesDB.totemIndicatorNoGlow then
        local offset = TOTEM_AURA_SIZE * 0.41
        local glowFrame = CreateFrame("Frame", nil, auraFrame, "DisableUntrustedLayoutScriptsTemplate")
        glowFrame:SetAllPoints(auraFrame)
        glowFrame:SetFrameLevel(auraFrame:GetFrameLevel() + 1)

        local glow = glowFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        glow:SetAtlas("clickcast-highlight-spellbook")
        glow:SetBlendMode("ADD")
        glow:SetDesaturated(true)
        glow:SetPoint("TOPLEFT", glowFrame, "TOPLEFT", -offset, offset)
        glow:SetPoint("BOTTOMRIGHT", glowFrame, "BOTTOMRIGHT", offset, -offset)
        glow:SetVertexColor(color[1], color[2], color[3])
    end

    auraFrame:SetCancelAuraButtons(nil)
    auraFrame:SetHideTooltipInCombat(true)
    if not InCombatLockdown() then
        auraFrame:SetMouseMotionEnabled(false)
    end
end

local function CreateTotemAuraContainer(frame)
    if not frame.healthBar or not frame.totemIndicator then return end
    if frame.totemAuraContainer then return end

    RaiseTotemNameplateName(frame)
    CreateTotemOverlayAnchor(frame)

    local container = CreateFrame("AuraContainer", nil, frame.totemIndicator, "CustomAuraContainerTemplate")
    container:SetSize(1, 1)
    container:SetFrameLevel(frame.totemIndicator:GetFrameLevel() + 5)
    container:SetPoint("CENTER", frame.totemIndicator, "CENTER", 0, 0)
    container:SetEnabled(false)
    container:SetEditModePreviewEnabled(false)
    container:Hide()
    frame.totemAuraContainer = container

    container:AddAuraSlot("Important", HELPFUL_IMPORTANT, {
        initializeFrame = function(auraFrame)
            InitTotemAuraIcon(auraFrame, frame, container, "grounding", true)
        end,
    })

    container:AddAuraSlot("Others", HELPFUL_NOT_IMPORTANT, {
        initializeFrame = function(auraFrame)
            InitTotemAuraIcon(auraFrame, frame, container, "healingStream", false)
        end,
    })
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
            BBP.FollowHealthName(frame)
        end
    end)
end

local function DisableTotemAuraContainer(frame)
    frame.totemRecheckArmed = nil
    if not frame.totemAuraContainer then return end
    SetTotemAuraContainerEnabled(frame.totemAuraContainer, nil)
end

local function UpdateTotemAuraContainer(frame)
    ScheduleTotemCastRecheck(frame)
    RefreshTotemOverlayAnchor(frame)
    SetTotemAuraContainerEnabled(frame.totemAuraContainer, frame.unit)
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
    if not frame.totemGlowFrame then
        frame.totemGlowFrame = CreateFrame("Frame", nil, frame.totemIndicator)
        frame.totemGlowFrame:SetAllPoints(frame.totemIndicator)
    end
    frame.totemGlowFrame:SetFrameLevel((frame.customCooldown or frame.totemIndicator):GetFrameLevel() + 1)

    if not frame.glowTexture then
        frame.glowTexture = frame.totemGlowFrame:CreateTexture(nil, "OVERLAY", nil, 7)
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
    frame.glowTexture:SetPoint("TOPLEFT",     frame.totemGlowFrame, "TOPLEFT",     -offset,  offset)
    frame.glowTexture:SetPoint("BOTTOMRIGHT", frame.totemGlowFrame, "BOTTOMRIGHT",  offset, -offset)
    frame.glowTexture:SetAlpha(1)
    frame.glowTexture:SetVertexColor(unpack(color))
    frame.glowTexture:Show()

    if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
        frame.animationGroup:Play()
    end
end

function BBP.ApplyTotemAttributes(frame, iconTexture, color, size, duration, startTime)
    BBP.CreateTotemComponents(frame, size)

    frame.totemIndicator:Show()
    frame.customIcon:SetTexture(iconTexture)
    frame.customIcon:Show()

    if duration then
        if not frame.customCooldown then
            frame.customCooldown = CreateFrame("Cooldown", nil, frame.totemIndicator, "CooldownFrameTemplate")
            frame.customCooldown:SetMinimumCountdownDuration(0)
            frame.customCooldown:SetPoint("TOPLEFT", frame.totemIndicator, "TOPLEFT", 1, -1)
            frame.customCooldown:SetPoint("BOTTOMRIGHT", frame.totemIndicator, "BOTTOMRIGHT", -1, 1)
        end
        ConfigureTotemCooldown(frame.customCooldown)
        frame.customCooldown:Show()
        if startTime then
            frame.customCooldown:SetCooldown(startTime, duration)
        else
            frame.customCooldown:SetCooldownDuration(duration)
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
    grounding     = { icon = TOTEM_ICON_IMPORTANT,      colorKey = "grounding",     isImportant = true  },
    capacitor     = { icon = TOTEM_ICON_CAPACITOR,      colorKey = "capacitor",     isImportant = true  },
    psyfiend      = { icon = TOTEM_ICON_PSYFIEND,       colorKey = "psyfiend",      isImportant = true  },
    healingStream = { icon = TOTEM_ICON_HEALING_STREAM, colorKey = "healingStream", isImportant = false },
    others        = { icon = TOTEM_ICON_GENERIC,        colorKey = "others",        isImportant = false },
}

local function RollTestTotemType(config)
    local roll = math.random()
    if config.totemIndicatorShowOtherIcons then
        if roll < 0.20 then return "grounding"
        elseif roll < 0.40 then return "capacitor"
        elseif roll < 0.60 then return "psyfiend"
        elseif roll < 0.80 then return "healingStream"
        else return "others" end
    else
        if roll < 0.25 then return "grounding"
        elseif roll < 0.50 then return "capacitor"
        elseif roll < 0.75 then return "psyfiend"
        else return "healingStream" end
    end
end

local function SetTotemCastbarHidden(frame, hidden)
    if hidden then
        frame.hideCastbarOverride = true
        frame.castBar:Hide()
    elseif frame.hideCastbarOverride then
        frame.hideCastbarOverride = false
    end
end

local function HideTotemIcon(frame)
    frame.customIcon:Hide()
    if frame.glowTexture then frame.glowTexture:Hide() end
    if frame.customCooldown then frame.customCooldown:Hide() end
    if frame.animationGroup then frame.animationGroup:Stop() end
end

local function ClearTotemState(frame, config)
    config.totemColorRGB = nil
    config.totemIsImportant = nil
    config.totemUninterruptible = nil
    ClearTotemBooleanColors(frame)
    ClearPsyfiendIconAlpha(frame)
    DisableTotemAuraContainer(frame)
    SetTotemCastbarHidden(frame, false)
    if frame.totemIndicator then
        HideTotemIcon(frame)
    end
end

local function ApplyTotemHideOptions(frame, config, info)
    if config.totemIndicatorHideAuras then
        BBP.SetNameplateAurasShown(frame, false)
    end

    if config.totemIndicatorHideHealthBar then
        if not info.isTarget then
            BBP.SetHealthBarHidden(frame, true)
            frame.selectionHighlight:SetAlpha(0)
        else
            BBP.SetHealthBarHidden(frame, false)
            if not config.hideTargetHighlight then
                frame.selectionHighlight:SetAlpha(0.22)
            end
        end
    end
end

local function ApplyKnownTotem(frame, config, info, totem, rank, guid)
    if (config.totemIndicatorEnemyOnly and info.isFriend) or BetterBlizzPlatesDB.totemIndicatorForeverHidden[totem.key] then
        ClearTotemState(frame, config)
        return
    end

    DisableTotemAuraContainer(frame)
    ClearTotemBooleanColors(frame)
    ClearPsyfiendIconAlpha(frame)
    SetTotemCastbarHidden(frame, config.totemIndicatorHideCastbar)

    local important = totem.important
    local color = totem.color
    config.totemColorRGB = color
    config.totemIsImportant = important
    config.totemUninterruptible = nil

    if config.totemIndicatorColorHealthBar and (important or config.totemIndicatorColorOtherHealthBars) then
        frame.healthBar:SetStatusBarColor(unpack(color))
        frame.needsRecolor = true
    end
    if important and config.totemIndicatorColorName or config.totemIndicatorColorNameOthers then
        frame.name:SetVertexColor(unpack(color))
    end

    if important or config.totemIndicatorShowOtherIcons then
        local duration = totem.durations and totem.durations[rank] or totem.duration
        BBP.ApplyTotemAttributes(frame, totem.icon, important and color or nil, 30, duration, GetTotemStartTime(guid, duration))
    else
        BBP.CreateTotemComponents(frame, 30)
        HideTotemIcon(frame)
        frame.totemIndicator:Show()
    end

    ApplyTotemHideOptions(frame, config, info)
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
        config.totemIndicatorHideCastbar = BetterBlizzPlatesDB.totemIndicatorHideCastbar
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
    local known, rank, guid
    if BBP.IsTotemUnit(unit) then
        known, rank, guid = LookupKnownTotem(unit)
    end

    local totemIndicatorSwappingAnchor
    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = BBP.GetLevelSpanAnchor(frame, config.totemIndicatorAnchor)
    elseif config.totemIndicatorAnchor == "TOP" then
        totemIndicatorSwappingAnchor = frame.name
    else
        totemIndicatorSwappingAnchor = BBP.GetLevelSpanAnchor(frame, config.totemIndicatorAnchor)
    end

    local yPosAdjustment = config.totemIndicatorHideNameAndShiftIconDown and config.totemIndicatorYPos + 4 or config.totemIndicatorYPos

    if not config.totemIndicatorTestMode and not isProbablyTotem and not known then
        ClearTotemState(frame, config)
        return
    end

    if config.totemIndicatorTestMode then
        DisableTotemAuraContainer(frame)
        config.totemUninterruptible = nil
        ClearTotemBooleanColors(frame)
        ClearPsyfiendIconAlpha(frame)
        SetTotemCastbarHidden(frame, config.totemIndicatorHideCastbar)

        if not config.totemTestType
            or (config.totemTestType == "others" and not config.totemIndicatorShowOtherIcons) then
            config.totemTestType = RollTestTotemType(config)
        end

        local preview = TOTEM_TEST_TYPES[config.totemTestType]
        local icon = preview.icon or TOTEM_ICON_GENERIC
        local totemColor = GetTotemColor(preview.colorKey)
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

        ApplyTotemHideOptions(frame, config, info)

    elseif known then
        ApplyKnownTotem(frame, config, info, known, rank, guid)
        if not config.totemColorRGB then return end

    elseif isProbablyTotem then
        if config.totemIndicatorEnemyOnly and info.isFriend then
            ClearTotemState(frame, config)
            return
        end

        SetTotemCastbarHidden(frame, config.totemIndicatorHideCastbar)

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
            totemColor = GetTotemColor("psyfiend")
            DisableTotemAuraContainer(frame)
        elseif isCapTotem then
            totemColor = GetTotemColor("capacitor")
            DisableTotemAuraContainer(frame)
        else
            BBP.CreateTotemComponents(frame, 30)
            CreateTotemAuraContainer(frame)
            UpdateTotemAuraContainer(frame)
            totemColor = GetTotemColor("others")
        end
        local isImportant = isCapTotem or isPsyfiend
        config.totemColorRGB = totemColor
        config.totemIsImportant = isImportant
        config.totemUninterruptible = uninterruptible

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
        local duration = (isPsyfiend and TOTEM_DURATION_PSYFIEND) or (isCapTotem and TOTEM_DURATION_CAPACITOR) or nil
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
            HideTotemIcon(frame)
            frame.totemIndicator:Show()
        end

        ApplyTotemHideOptions(frame, config, info)

    else
        config.totemColorRGB = nil
        config.totemUninterruptible = nil
        ClearTotemBooleanColors(frame)
        ClearPsyfiendIconAlpha(frame)
        DisableTotemAuraContainer(frame)
        SetTotemCastbarHidden(frame, false)
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
        totemIndicatorSwappingAnchor = BBP.GetLevelSpanAnchor(frame, config.totemIndicatorAnchor)
    elseif config.totemIndicatorAnchor == "TOP" then
        totemIndicatorSwappingAnchor = frame.name
    else
        totemIndicatorSwappingAnchor = BBP.GetLevelSpanAnchor(frame, config.totemIndicatorAnchor)
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
