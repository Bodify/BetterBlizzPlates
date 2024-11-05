-- I did not know what a variable was when I started. I know a little bit more now and I am so sorry.

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("statusbar", "Dragonflight (BBP)", [[Interface\Addons\BetterBlizzPlates\media\DragonflightTexture]])
LSM:Register("statusbar", "Shattered DF (BBP)", [[Interface\Addons\BetterBlizzPlates\media\focusTexture]])
LSM:Register("statusbar", "Checkered (BBP)", [[Interface\Addons\BetterBlizzPlates\media\targetTexture]])
LSM:Register("statusbar", "Smooth", [[Interface\Addons\BetterBlizzPlates\media\smooth]])
LSM:Register("font", "Yanone (BBP)", [[Interface\Addons\BetterBlizzPlates\media\YanoneKaffeesatz-Medium.ttf]])
LSM:Register("font", "Prototype", [[Interface\Addons\BetterBlizzPlates\media\Prototype.ttf]])

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = "1.6.8"
local sendUpdate = false
BBP.VersionNumber = addonUpdates
local _, playerClass
local playerClassColor

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitName = UnitName
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local UnitClassBase = UnitClassBase
local UnitReaction = UnitReaction
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsActiveBattlefieldArena = IsActiveBattlefieldArena

BBP.variablesLoaded = false
BBP.OverlayFrame = CreateFrame("Frame")

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
    setCVarAcrossAllCharacters = true,
    -- General
    classicNameplates = false,
    removeRealmNames = true,
    hideNameplateAuras = false,
    hideTargetHighlight = false,
    nameplateShowEnemyMinus = nil,
    enemyNameplateHealthbarHeight = nil,
    fadeOutNPC = false,
    hideNPC = false,
    hideNPCWhitelistOn = false,
    hideNPCArenaOnly = false,
    colorNPC = false,
    colorNPCName = false,
    raidmarkIndicator = false,
    raidmarkIndicatorScale = 1,
    raidmarkIndicatorAnchor = "TOP",
    raidmarkIndicatorXPos = 0,
    raidmarkIndicatorYPos = 0,
    customTexture = "Dragonflight (BBP)",
    customTextureFriendly = "Dragonflight (BBP)",
    customTextureSelf = "Solid",
    customTextureSelfMana = "Solid",
    customFont = "Yanone (BBP)",
    friendlyHideHealthBarNpc = true,
    nameplateResourceScale = 0.7,
    darkModeNameplateColor = 0.2,
    fakeNameXPos = 0,
    fakeNameYPos = 0,
    fakeNameFriendlyXPos = 0,
    fakeNameFriendlyYPos = 0,
    guildNameColorRGB = {0, 1, 0},
    npcTitleColorRGB = {1, 0.85, 0},
    npcTitleScale = 1,
    hideNpcMurlocScale = 1,
    hideNpcMurlocYPos = 0,
    partyPointerWidth = 36,
    changeHealthbarHeight = false,
    hpHeightEnemy = 9,--4 * tonumber(GetCVar("NamePlateVerticalScale")),
    hpHeightFriendly = 9,--4 * tonumber(GetCVar("NamePlateVerticalScale")),
    healthNumbersPlayers = true,
    healthNumbersNpcs = true,
    healthNumbersAnchor = "CENTER",
    healthNumbersXPos = 0,
    healthNumbersYPos = 0,
    healthNumbersScale = 1,
    healthNumbersFontOutline = "THICKOUTLINE",
    fakeNameAnchor = "BOTTOM",
    fakeNameAnchorRelative = "CENTER",
    fakeNameScaleWithParent = false,
    nameplateBorderSize = 1,
    nameplateTargetBorderSize = 3,
    separateAuraBuffRow = true,
    npBorderDesaturate = true,
    nameplateGeneralHeight = 32,
    tankFullAggroColorRGB = {0, 1, 0, 1},
    tankNoAggroColorRGB = {1, 0, 0, 1},
    dpsOrHealFullAggroColorRGB = {1, 0, 0, 1},
    dpsOrHealNoAggroColorRGB = {0, 1, 0, 1},
    npBgColorRGB = {1, 1, 1, 1},
    -- Enemy
    enemyClassColorName = false,
    showNameplateCastbarTimer = false,
    showNameplateTargetText = false,
    enemyNameScale = 1,
    nameplateEnemyWidth = nil,
    nameplateEnemyHeight = nil,
    enemyHealthBarColorRGB = {1, 0, 0},
    enemyNeutralHealthBarColorRGB = {1, 1, 0},
    enemyColorNameRGB = {1, 0, 0},
    enemyNeutralColorNameRGB = {1, 1, 0},
    useCustomTextureForEnemy = true,
    -- Friendly
    friendlyNameplateClickthrough = false,
    friendlyClassColorName = false,
    friendlyNameScale = 1,
    friendlyNameplatesOnlyInArena = false,
    friendlyHealthBarColorRGB = {0, 1, 0},
    guildNameScale = 1,
    useCustomTextureForFriendly = true,
    -- Nameplate Border
    npBorderTargetColorRGB = {1, 1, 1, 1},
    npBorderEnemyColorRGB = {1, 0, 0, 1},
    npBorderFriendlyColorRGB = {0, 1, 0, 1},
    npBorderNeutralColorRGB = {1, 1, 0, 1},
    npBorderNpcColorRGB = {0, 0, 0, 1},
    npBorderNonTargetColorRGB = {0, 0, 0, 1},
    -- Arena Indicator
    arenaIndicatorTestMode = false,
    arenaIDScale = 1,
    arenaSpecScale = 1,
    arenaIndicatorModeOff = false,
    arenaIndicatorModeOne = false,
    arenaIndicatorModeTwo = false,
    arenaIndicatorModeThree = false,
    arenaIndicatorModeFour = false,
    arenaIndicatorModeFive = false,
    partyIDScale = 1,
    partySpecScale = 1,
    partyIndicatorModeOff = false,
    partyIndicatorModeOne = false,
    partyIndicatorModeTwo = false,
    partyIndicatorModeThree = false,
    partyIndicatorModeFour = false,
    partyIndicatorModeFive = false,
    arenaIdXPos = 0,
    arenaIdYPos = 0,
    arenaSpecXPos = 0,
    arenaSpecYPos = 0,
    arenaIdAnchor = "TOP",
    arenaSpecAnchor = "TOP",
    arenaIndicatorIDColor = false,
    arenaIndicatorIDColorRGB = {1, 0.819607, 0, 1},
    arenaIndicatorBg = true,
    -- Absorb Indicator
    absorbIndicatorTestMode = false,
    absorbIndicator = false,
    absorbIndicatorEnemyOnly = false,
    absorbIndicatorOnPlayersOnly = true,
    absorbIndicatorScale = 1,
    absorbIndicatorXPos = 0,
    absorbIndicatorYPos = 0,
    absorbIndicatorAnchor = "LEFT",
    -- Combat Indicator
    combatIndicator = false,
    combatIndicatorSap = false,
    combatIndicatorEnemyOnly = false,
    combatIndicatorPlayersOnly = true,
    combatIndicatorArenaOnly = false,
    combatIndicatorScale = 1,
    combatIndicatorXPos = 0,
    combatIndicatorYPos = 0,
    combatIndicatorAnchor = "CENTER",
    -- Execute Indicator
    executeIndicator = false,
    executeIndicatorTestMode = false,
    executeIndicatorAnchor = "LEFT",
    executeIndicatorScale = 1,
    executeIndicatorXPos = 0,
    executeIndicatorYPos = 0,
    executeIndicatorThreshold = 40,
    executeIndicatorAlwaysOn = false,
    executeIndicatorNotOnFullHp = false,
    executeIndicatorFriendly = false,
    executeIndicatorShowDecimal = true,
    -- Healer Indicator
    healerIndicator = false,
    healerIndicatorEnemyOnly = false,
    healerIndicatorScale = 1,
    healerIndicatorXPos = 0,
    healerIndicatorYPos = 0,
    healerIndicatorAnchor = "TOPRIGHT",
    healerIndicatorTestMode = false,
    healerIndicatorEnemyXPos = 0,
    healerIndicatorEnemyYPos = 0,
    healerIndicatorEnemyAnchor = "TOPRIGHT",
    healerIndicatorEnemyScale = 1,
    -- Class Icon
    classIndicator = false,
    classIndicatorXPos = 0,
    classIndicatorFriendlyXPos = 0,
    classIndicatorYPos = 0,
    classIndicatorFriendlyYPos = 0,
    classIndicatorAnchor = "TOP",
    classIndicatorFriendlyAnchor = "TOP",
    classIndicatorScale = 1,
    classIndicatorFriendlyScale = 1,
    classIndicatorEnemy = false,
    classIndicatorFriendly = true,
    classIconColorBorder = true,
    classIndicatorHideRaidMarker = true,
    classIndicatorHighlight = true,
    classIndicatorHighlightColor = true,
    classIconArenaOnly = false,
    -- Party Pointer
    partyPointerXPos = 0,
    partyPointerYPos = 0,
    partyPointerScale = 1,
    partyPointerHealerScale = 1,
    partyPointerAnchor = "TOP",
    partyPointerClassColor = true,
    partyPointerHideRaidmarker = true,
    partyPointerArenaOnly = true,
    -- Pet Indicator
    petIndicator = false,
    petIndicatorScale = 1,
    petIndicatorXPos = 0,
    petIndicatorYPos = 0,
    petIndicatorAnchor = "CENTER",
    petIndicatorTestMode = false,
    -- Target Indicator
    targetIndicator = false,
    targetIndicatorScale = 1,
    targetIndicatorXPos = 0,
    targetIndicatorYPos = 0,
    targetIndicatorAnchor = "TOP",
    targetIndicatorTestMode = false,
    targetIndicatorColorNameplateRGB = {1, 0, 0.44},
    targetIndicatorTexture = "Checkered (BBP)",
    -- Focus Target Indicator
    focusTargetIndicator = false,
    focusTargetIndicatorScale = 1,
    focusTargetIndicatorXPos = 0,
    focusTargetIndicatorYPos = 0,
    focusTargetIndicatorAnchor = "TOPRIGHT",
    focusTargetIndicatorTestMode = false,
    focusTargetIndicatorColorNameplate = false,
    focusTargetIndicatorColorNameplateRGB = {1, 1, 1},
    focusTargetIndicatorTexture = "Shattered DF (BBP)",
    -- Totem Indicator
    totemIndicator = false,
    totemIndicatorColorName = true,
    totemIndicatorColorHealthBar = true,
    totemIndicatorScale = 1,
    totemIndicatorXPos = 0,
    totemIndicatorYPos = 0,
    totemIndicatorAnchor = "TOP",
    totemIndicatorScaleUpImportant = false,
    totemIndicatorHideNameAndShiftIconDown = false,
    totemIndicatorTestMode = false,
    totemIndicatorEnemyOnly = false,
    totemIndicatorDefaultCooldownTextSize = 0.85,
    showTotemIndicatorCooldownSwipe = true,
    totemIndicatorShieldType = 1,
    totemIndicatorHideAuras = true,
    totemIndicatorNpcList = {
        -- Important
        [3527] =    { name = "Healing Stream Totem", icon = GetSpellTexture(5394),       hideIcon = false, size = 31, duration = nil, color = {0, 1, 0.78},       important = true, widthOn = true, hpWidth = -25 },
        [5925] =    { name = "Grounding Totem", icon = GetSpellTexture(8177),            hideIcon = false, size = 31, duration = 30,  color = {1, 0, 1},          important = true, widthOn = true, hpWidth = -25 },
        [53006] =   { name = "Spirit Link Totem", icon = GetSpellTexture(98008),         hideIcon = false, size = 31, duration = 6,   color = {0, 1, 0.78},       important = true },
        [5913] =    { name = "Tremor Totem", icon = GetSpellTexture(8143),               hideIcon = false, size = 31, duration = 8.4, color = {0.49, 0.9, 0.08},  important = true, widthOn = true, hpWidth = -25 },
        [27829] =   { name = "Ebon Gargoyle", icon = GetSpellTexture(49206),             hideIcon = false, size = 31, duration = 30,  color = {1, 0.69, 0},       important = true },
        [10467] =   { name = "Mana Tide Totem", icon = GetSpellTexture(16191),           hideIcon = false, size = 27, duration = 16.8,color = {0.08, 0.82, 0.78}, important = true, widthOn = true, hpWidth = -25 },
        [3579] =    { name = "Stoneclaw Totem", icon = GetSpellTexture(5730),            hideIcon = false, size = 29, duration = 21,  color = {0.78, 0.51, 0.39}, important = true, widthOn = true, hpWidth = -25 },
        -- Normal
        [19668] =   { name = "Shadowfiend", icon = GetSpellTexture(34433),               hideIcon = false, size = 27, duration = 15,  color = {0.43, 0.20, 1},    important = false, widthOn = true, hpWidth = -25 },
        [510] =     { name = "Water Elemental", icon = GetSpellTexture(31687),           hideIcon = true,  size = 27, duration = nil, color = {0.25, 1, 0.83},    important = false, widthOn = true, hpWidth = -25 },
        [15430] =   { name = "Earth Elemental Totem", icon = GetSpellTexture(2062),      hideIcon = false, size = 27, duration = nil, color = {0.78, 0.51, 0.39}, important = false, widthOn = true, hpWidth = -25 },
        [15439] =   { name = "Fire Elemental Totem", icon = GetSpellTexture(2894),       hideIcon = false, size = 27, duration = nil, color = {1, 0.23, 0},       important = false, widthOn = true, hpWidth = -25 },
        [15438] =   { name = "Greater Fire Elemental", icon = GetSpellTexture(2894),     hideIcon = false, size = 27, duration = nil, color = {1, 0.23, 0},       important = false, widthOn = true, hpWidth = -25 },
        [15352] =   { name = "Greater Earth Elemental", icon = GetSpellTexture(2062),    hideIcon = false, size = 27, duration = nil, color = {0.78, 0.51, 0.39}, important = false, widthOn = true, hpWidth = -25 },
        [2630] =    { name = "Earthbind Totem", icon = GetSpellTexture(2484),            hideIcon = false, size = 27, duration = nil, color = {0.78, 0.51, 0.39}, important = false, iconOnly = true },
        -- Un-important
        [3573] =    { name = "Mana Spring Totem", icon = GetSpellTexture(5675),          hideIcon = false, size = 25, duration = nil, color = {0.70, 0.98, 1},    important = false, iconOnly = true },
        [47069] =   { name = "Tranquil Mind", icon = GetSpellTexture(87718),             hideIcon = false, size = 25, duration = nil, color = {0.70, 0.98, 1},    important = false, iconOnly = true },
        [6112] =    { name = "Windfury Totem", icon = GetSpellTexture(8512),             hideIcon = false, size = 25, duration = nil, color = {0.70, 0.98, 1},    important = false, iconOnly = true },
        [15447] =   { name = "Wrath of Air", icon = GetSpellTexture(3738),               hideIcon = false, size = 25, duration = nil, color = {0.70, 0.98, 1},    important = false, iconOnly = true },
        [5874] =    { name = "Strength of Earth", icon = GetSpellTexture(8075),          hideIcon = false, size = 25, duration = nil, color = {0.78, 0.51, 0.39}, important = false, iconOnly = true },
        [5929] =    { name = "Magma Totem", icon = GetSpellTexture(8190),                hideIcon = false, size = 25, duration = nil, color = {1, 0.23, 0},       important = false, iconOnly = true },
        [2523] =    { name = "Searing Totem", icon = GetSpellTexture(3599),              hideIcon = false, size = 25, duration = nil, color = {1, 0.23, 0},       important = false, iconOnly = true },
        [5950] =    { name = "Flametongue Totem", icon = GetSpellTexture(8227),          hideIcon = false, size = 25, duration = nil, color = {1, 0.23, 0},       important = false, iconOnly = true },
        [5873] =    { name = "Stoneskin Totem", icon = GetSpellTexture(8071),            hideIcon = false, size = 25, duration = nil, color = {0.78, 0.51, 0.39}, important = false, iconOnly = true },
        [5927] =    { name = "Elemental Resistance Totem", icon = GetSpellTexture(8184), hideIcon = false, size = 25, duration = nil, color = {0.08, 0.82, 0.78}, important = false, iconOnly = true },
    },

    --hideHp

    -- Quest Indicator
    questIndicator = false,
    questIndicatorScale = 1,
    questIndicatorXPos = 0,
    questIndicatorYPos = 0,
    questIndicatorAnchor = "LEFT",
    questIndicatorTestMode = false,
    -- Font and texture
    customFontSizeEnabled = false,
    customFontSize = 12,
    useCustomFont = false,
    enableCustomFontOutline = true,
    customFontOutline = "THINOUTLINE",
    useCustomTextureForBars = false,
    -- Castbar
    enableCastbarCustomization = false,
    showCastBarIconWhenNoninterruptible = false,
    enableCastbarEmphasis = false,
    castBarEmphasisOnlyInterruptable = false,
    castBarEmphasisColor = false,
    castBarEmphasisIcon = false,
    castBarEmphasisText = false,
    castBarEmphasisHeight = false,
    castBarEmphasisIconScale = 2,
    castBarEmphasisTextScale = 2,
    castBarEmphasisHeightValue = 24,
    castBarEmphasisSparkHeight = 35,
    castBarEmphasisHealthbarColor = false,
    castBarDragonflightShield = true,
    castBarShieldAnchor = "LEFT",
    castBarShieldXPos = 0,
    castBarShieldYPos = 0,
    castBarShieldScale = 1,
    castBarIconScale = 1,
    castBarIconAnchor = "LEFT",
    castBarIconXPos = 0,
    castBarIconYPos = 0,
    castBarTextScale = 1,
    showCastbarIfTarget = false,
    castBarRecolor = false,
    castBarRecolorInterrupt = false,
    castBarCastColor = {
		1,
		0.8431373238563538,
		0.2000000178813934,
	},
    castBarChanneledColor = {
		0.4862745404243469,
		1,
		0.294117659330368,
	},
    castBarNoninterruptibleColor = {
        0.4,
        0.4,
        0.4,
    },
    castBarNoInterruptColor = {
		1,
		0,
		0.01568627543747425,
	},
    castBarDelayedInterruptColor = {
		1,
		0.4784314036369324,
		0.9568628072738647,
	},
    castBarBackgroundColor = {0.33,0.33,0.33,1},
    -- Nameplate aura settings
    enableNameplateAuraCustomisation = true,
    nameplateAurasCenteredAnchor = false,
    showDefaultCooldownNumbersOnNpAuras = true,
    maxAurasOnNameplate = 12,
    nameplateAuraRowAmount = 5,
    targetNameplateAuraScale = 1,
    nameplateAuraCountScale = 1,
    --nameplateAuraRowFriendlyAmount = 5,
    nameplateAuraSquare = false,
    nameplateAuraTaller = false,
    nameplateAuraRowAbove = true,
    nameplateAuraHeightGap = 4,
    nameplateAuraWidthGap = 4,
    nameplateAurasYPos = 0,
    nameplateAurasXPos = 0,
    nameplateAuraAnchor = "BOTTOMLEFT",
    nameplateAuraRelativeAnchor = "TOPLEFT",
    nameplateAurasNoNameYPos = 0,
    nameplateAuraScale = 1,
    hideDefaultPersonalNameplateAuras = false,
    defaultNpAuraCdSize = 0.5,
    onlyPandemicAuraMine = true,
    nameplateAuraEnlargedScale = 1,
    nameplateAuraCompactedScale = 1,
    nameplateAuraEnlargedSquare = true,
    nameplateAuraCompactedSquare = true,
    nameplateAuraBuffScale = 1,
    nameplateAuraDebuffScale = 1,
    sortEnlargedAurasFirst = true,

    personalNpBuffEnable = false,
    personalNpBuffFilterAll = false,
    personalNpBuffFilterBlizzard = false,
    personalNpBuffFilterWatchList = false,
    personalNpBuffFilterLessMinite = false,
    personalNpBuffFilterOnlyMe = false,

    personalNpdeBuffEnable = false,
    personalNpdeBuffFilterAll = false,
    personalNpdeBuffFilterWatchList = false,
    personalNpdeBuffFilterLessMinite = false,

    otherNpBuffEnable = false,
    otherNpBuffFilterAll = false,
    otherNpBuffFilterWatchList = true,
    otherNpBuffFilterLessMinite = false,
    otherNpBuffPurgeGlow = false,
    otherNpBuffBlueBorder = false,
    otherNpBuffEmphasisedBorder = false,

    otherNpdeBuffEnable = true,
    otherNpdeBuffFilterAll = false,
    otherNpdeBuffFilterBlizzard = true,
    otherNpdeBuffFilterWatchList = true,
    otherNpdeBuffFilterLessMinite = false,
    otherNpdeBuffFilterOnlyMe = false,
    otherNpdeBuffPandemicGlow = false,

    friendlyNpBuffEnable = false,
    friendlyNpBuffFilterAll = false,
    friendlyNpBuffFilterWatchList = false,
    friendlyNpBuffFilterLessMinite = false,
    friendlyNpBuffFilterOnlyMe = false,
    friendlyNpBuffPurgeGlow = false,
    friendlyNpBuffBlueBorder = false,
    friendlyNpBuffEmphasisedBorder = false,

    friendlyNpdeBuffEnable = false,
    friendlyNpdeBuffFilterAll = false,
    friendlyNpdeBuffFilterBlizzard = false,
    friendlyNpdeBuffFilterWatchList = false,
    friendlyNpdeBuffFilterLessMinite = false,
    friendlyNpdeBuffFilterOnlyMe = false,

    personalNpBuffFilterBlacklist = true,
    personalNpdeBuffFilterBlacklist = true,
    friendlyNpBuffFilterBlacklist = true,
    friendlyNpdeBuffFilterBlacklist = true,
    otherNpBuffFilterBlacklist = true,
    otherNpdeBuffFilterBlacklist = true,

    testAllEnabledFeatures = false,

    -- Default values for resets
    nameplateDefaultFriendlyWidth = 110,
    nameplateDefaultLargeFriendlyWidth = 154,
    nameplateDefaultFriendlyHeight = 45,
    nameplateDefaultLargeFriendlyHeight = 64.125,
    nameplateDefaultEnemyWidth = 110,
    nameplateDefaultLargeEnemyWidth = 154,
    nameplateDefaultEnemyHeight = 45,
    nameplateDefaultLargeEnemyHeight = 64.125,

    -- Fade out NPCs
    fadeOutNPCsAlpha = 0.2,

    defaultFadeOutNPCsList = {
        {name = "DK pet", id = 26125, comment = ""},
        {name = "Magus(Army of the Dead)", id = 163366, comment = ""},
        {name = "Army of the Dead", id = 24207, comment = ""},
        --{name = "Felguard (Demo Pet)", id = 17252, comment = ""},
        --{name = "Hunter pet (they all have same ID)", id = 165189, comment = ""},
        -- {name = "Spirit Wolves (Enha Shaman)", id = 29264, comment = ""},
        -- {name = "Earth Elemental (Shaman)", id = 95072, comment = ""},
        {name = "Mirror Images (Mage)", id = 31216, comment = ""},
        -- {name = "Beast (Hunter)", id = 62005, comment = ""},
        -- {name = "Dire Basilisk (Hunter)", id = 105419, comment = ""},
        -- {name = "Void Tendril (Spriest)", id = 192337, comment = ""},
        -- {name = "Illidari Satyr", id = 136398, comment = ""},
        -- {name = "Darkhound", id = 136408, comment = ""},
        -- {name = "Void Terror", id = 136403, comment = ""},
        -- {name = "Treant", id = 54983, comment = ""},
    },
    hideNPCsList = {
        {name = "Mirror Images (Mage)", id = 31216, comment = ""},
        {name = "Wild Imp (Warlock)", id = 55659, comment = ""},
        {name = "Wild Imp (Warlock)", id = 143622, comment = ""},
    },
    hideNPCsWhitelist = {
        {name = "Healing Stream Totem", id = 3527, comment = ""},
        {name = "Grounding Totem", id = 5925, comment = ""},
        {name = "Spirit Link Totem", id = 53006, comment = ""},
        {name = "Tremor Totem", id = 5913, comment = ""},
        {name = "Ebon Gargoyle", id = 27829, comment = ""},
        {name = "Mana Tide Totem", id = 10467, comment = ""},
        {name = "Shadowfiend", id = 19668, comment = ""},
        {name = "Earth Elemental Totem", id = 15430, comment = ""},
        {name = "Fire Elemental Totem", id = 15439, comment = ""},
        {name = "Greater Fire Elemental", id = 15438, comment = ""},
        {name = "Greater Earth Elemental", id = 15352, comment = ""},
        {name = "Earthbind Totem", id = 2630, comment = ""},
        {name = "Stoneclaw Totem", id = 3579, comment = ""},
        {name = "Mana Spring Totem", id = 3573, comment = ""},
        {name = "Tranquil Mind", id = 47069, comment = ""},
        {name = "Windfury Totem", id = 6112, comment = ""},
        {name = "Wrath of Air", id = 15447, comment = ""},
        {name = "Strength of Earth", id = 5874, comment = ""},
        {name = "Magma Totem", id = 5929, comment = ""},
        {name = "Searing Totem", id = 2523, comment = ""},
        {name = "Flametongue Totem", id = 5950, comment = ""},
        {name = "Stoneskin Totem", id = 5873, comment = ""},
        {name = "Elemental Resistance Totem", id = 5927, comment = ""},
        {name = "Water Elemental", id = 510, comment = ""},
        {name = "Death Knight Pet", id = 26125, comment = ""},
    },

    fadeOutNPCsWhitelist = {
        {name = "Healing Stream Totem", id = 3527, comment = ""},
        {name = "Grounding Totem", id = 5925, comment = ""},
        {name = "Spirit Link Totem", id = 53006, comment = ""},
        {name = "Tremor Totem", id = 5913, comment = ""},
        {name = "Ebon Gargoyle", id = 27829, comment = ""},
        {name = "Mana Tide Totem", id = 10467, comment = ""},
        {name = "Shadowfiend", id = 19668, comment = ""},
        {name = "Earth Elemental Totem", id = 15430, comment = ""},
        {name = "Fire Elemental Totem", id = 15439, comment = ""},
        {name = "Greater Fire Elemental", id = 15438, comment = ""},
        {name = "Greater Earth Elemental", id = 15352, comment = ""},
        {name = "Earthbind Totem", id = 2630, comment = ""},
        {name = "Stoneclaw Totem", id = 3579, comment = ""},
        {name = "Mana Spring Totem", id = 3573, comment = ""},
        {name = "Tranquil Mind", id = 47069, comment = ""},
        {name = "Windfury Totem", id = 6112, comment = ""},
        {name = "Wrath of Air", id = 15447, comment = ""},
        {name = "Strength of Earth", id = 5874, comment = ""},
        {name = "Magma Totem", id = 5929, comment = ""},
        {name = "Searing Totem", id = 2523, comment = ""},
        {name = "Flametongue Totem", id = 5950, comment = ""},
        {name = "Stoneskin Totem", id = 5873, comment = ""},
        {name = "Elemental Resistance Totem", id = 5927, comment = ""},
        {name = "Water Elemental", id = 510, comment = ""},
        {name = "Death Knight Pet", id = 26125, comment = ""},
    },

    hideCastbarList = {},
    hideCastbarWhitelist = {},
    colorNpcList = {},
    auraWhitelist = {
        {["name"] = "Example Aura :3 (delete me)",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },}
    },
    auraBlacklist = {},
    auraColorList = {},
    friendlyColorNameRGB = {1, 1, 1},

    castEmphasisList = {
        {name = "Cyclone"},
        {name = "Polymorph"},
        -- {name = "Sleep Walk"},
        {name = "Fear"},
        -- {name = "Repentance"},
        {name = "Hex"},
        -- {name = "Ring of Frost"},
        -- {name = "Mass Polymorph"},
        -- {name = "Shadowfury"},
        -- {name = "Haymaker"},
        -- {name = "Lightning Lasso"},
        -- {name = "Song of Chi-Ji"},
    },

    castBarInterruptHighlighter = false,
    castBarInterruptHighlighterColorDontInterrupt = false,
    castBarInterruptHighlighterInterruptRGB = {0, 1, 0},
    castBarInterruptHighlighterDontInterruptRGB = {0, 0, 0},
    castBarInterruptHighlighterStartTime = 0.8,
    castBarInterruptHighlighterEndTime = 0.6,

    nameplateResourceXPos = 0,
    nameplateResourceYPos = 0,


}

local smallNpcs = {
    [510] = true,
}

function BBP.greenScreen(frame)
    -- Ensure that the frame is valid
    if not frame then return end
    if frame.texture then return end

    -- Create a texture on the specified frame
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()  -- Make the texture fill the entire frame

    -- Generate random RGB values
    local r = math.random()
    local g = math.random()
    local b = math.random()

    -- Set the color and transparency (alpha) of the texture
    texture:SetColorTexture(r, g, b, 0.5)  -- 50% transparency

    frame.greenScreen = texture

    return texture  -- Return the texture for further manipulation if necessary
end

--#################################################################################################
--#################################################################################################
--#################################################################################################
local function InitializeNameplateSettings(frame)
    if not frame.BetterBlizzPlates then
        --frame.BetterBlizzPlates = CreateFrame("Frame")
        --frame.BetterBlizzPlates:SetAllPoints(frame)
        frame.BetterBlizzPlates = {}
    end
    if not frame.BetterBlizzPlates.config or BBP.needsUpdate then
        frame.BetterBlizzPlates.config = {
            enableNameplateAuraCustomisation = BetterBlizzPlatesDB.enableNameplateAuraCustomisation,
            enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization,
            questIndicator = BetterBlizzPlatesDB.questIndicatorTestMode or BetterBlizzPlatesDB.questIndicator,
            targetIndicator = BetterBlizzPlatesDB.targetIndicator,
            absorbIndicator = BetterBlizzPlatesDB.absorbIndicatorTestMode or BetterBlizzPlatesDB.absorbIndicator,
            totemIndicator = BetterBlizzPlatesDB.totemIndicator,
            arenaIndicators = not BetterBlizzPlatesDB.arenaIndicatorModeOff or not BetterBlizzPlatesDB.partyIndicatorModeOff or BetterBlizzPlatesDB.arenaIndicatorTestMode,
            executeIndicator = BetterBlizzPlatesDB.executeIndicator or BetterBlizzPlatesDB.executeIndicatorTestMode,
            fadeOutNPC = BetterBlizzPlatesDB.fadeOutNPC,
            hideNPC = BetterBlizzPlatesDB.hideNPC,
            colorNPC = BetterBlizzPlatesDB.colorNPC,
            friendlyHealthBarColor = BetterBlizzPlatesDB.friendlyHealthBarColor,
            enemyHealthBarColor = BetterBlizzPlatesDB.enemyHealthBarColor,
            petIndicator = BetterBlizzPlatesDB.petIndicator or BetterBlizzPlatesDB.petIndicatorTestMode,
            raidmarkIndicator = BetterBlizzPlatesDB.raidmarkIndicator,
            hideRaidmarkIndicator = BetterBlizzPlatesDB.hideRaidmarkIndicator,
            healerIndicator = BetterBlizzPlatesDB.healerIndicatorTestMode or BetterBlizzPlatesDB.healerIndicator,
            combatIndicator = BetterBlizzPlatesDB.combatIndicator,
            useCustomTextureForBars = BetterBlizzPlatesDB.useCustomTextureForBars,
            focusTargetIndicator = BetterBlizzPlatesDB.focusTargetIndicator or BetterBlizzPlatesDB.focusTargetIndicatorTestMode,
            friendlyHideHealthBar = BetterBlizzPlatesDB.friendlyHideHealthBar,
            friendlyHideHealthBarNpc = BetterBlizzPlatesDB.friendlyHideHealthBar and BetterBlizzPlatesDB.friendlyHideHealthBar,
            classIndicator = BetterBlizzPlatesDB.classIndicator,
            auraColor = BetterBlizzPlatesDB.auraColor,
            friendIndicator = BetterBlizzPlatesDB.friendIndicator,
            changeNameplateBorderColor = BetterBlizzPlatesDB.changeNameplateBorderColor,
            --hideResourceOnFriend = BetterBlizzPlatesDB.hideResourceOnFriend,
            nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar,
            nameplateResourceOnTarget = BetterBlizzPlatesDB.nameplateResourceOnTarget,
            nameplateResourceDoNotRaiseAuras = BetterBlizzPlatesDB.nameplateResourceDoNotRaiseAuras,
            showGuildNames = BetterBlizzPlatesDB.showGuildNames,
            hideNameplateAuras = BetterBlizzPlatesDB.hideNameplateAuras,
            nameplateAuraPlayersOnly = BetterBlizzPlatesDB.nameplateAuraPlayersOnly,
            nameplateAuraPlayersOnlyShowTarget = BetterBlizzPlatesDB.nameplateAuraPlayersOnlyShowTarget,
            hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight,
            partyPointer = BetterBlizzPlatesDB.partyPointer or BetterBlizzPlatesDB.partyPointerTestMode,
            useFakeName = BetterBlizzPlatesDB.useFakeName,
            hideEnemyNameText = BetterBlizzPlatesDB.hideEnemyNameText,
            hideFriendlyNameText = BetterBlizzPlatesDB.hideFriendlyNameText,
            anonModeOn = BetterBlizzPlatesDB.anonModeOn,
            changeHealthbarHeight = BetterBlizzPlatesDB.changeHealthbarHeight,
            healthNumbers = BetterBlizzPlatesDB.healthNumbers or BetterBlizzPlatesDB.healthNumbersTestMode,
            changeNameplateBorderSize = BetterBlizzPlatesDB.changeNameplateBorderSize,
            nameplateBorderSize = BetterBlizzPlatesDB.nameplateBorderSize,
            nameplateTargetBorderSize = BetterBlizzPlatesDB.nameplateTargetBorderSize,
            hideLevelFrame = BetterBlizzPlatesDB.hideLevelFrame,
            classicNameplates = BetterBlizzPlatesDB.classicNameplates,
            showNpcTitle = BetterBlizzPlatesDB.showNpcTitle,
            showLastNameNpc = BetterBlizzPlatesDB.showLastNameNpc,
        }
        if frame.BetterBlizzPlates.config.changeHealthbarHeight then
            frame.BetterBlizzPlates.config.hpHeightEnemy = BetterBlizzPlatesDB.hpHeightEnemy
            frame.BetterBlizzPlates.config.hpHeightFriendly = BetterBlizzPlatesDB.hpHeightFriendly
        end
    end
    return frame.BetterBlizzPlates.config
end

BBP.InitializeNameplateSettings = InitializeNameplateSettings

local function InitializeSavedVariables()
    if not BetterBlizzPlatesDB then
        BetterBlizzPlatesDB = {}
    end

    -- Check the stored version against the current addon version
    if not BetterBlizzPlatesDB.version or BetterBlizzPlatesDB.version ~= addonVersion then
        -- Perform database update here (if needed)
        if not BetterBlizzPlatesDB.fadeOutNPCsList then
            BetterBlizzPlatesDB.fadeOutNPCsList = defaultSettings.defaultFadeOutNPCsList
        else
            -- Check if any new NPC IDs need to be added to the user's list
            for _, defaultNPC in ipairs(defaultSettings.defaultFadeOutNPCsList) do
                local isFound = false
                for _, userNPC in ipairs(BetterBlizzPlatesDB.fadeOutNPCsList) do
                    if defaultNPC.id == userNPC.id then
                        isFound = true
                        break
                    end
                end
                if not isFound then
                    table.insert(BetterBlizzPlatesDB.fadeOutNPCsList, defaultNPC)
                end
            end
        end
        BetterBlizzPlatesDB.version = addonVersion  -- Update the version number in the database
    end

    if not BetterBlizzPlatesDB.classIndicatorFriendlyYPos then
        BetterBlizzPlatesDB.classIndicatorFriendlyXPos = BetterBlizzPlatesDB.classIndicatorXPos
        BetterBlizzPlatesDB.classIndicatorFriendlyYPos = BetterBlizzPlatesDB.classIndicatorYPos
        BetterBlizzPlatesDB.classIndicatorFriendlyAnchor = BetterBlizzPlatesDB.classIndicatorAnchor
        BetterBlizzPlatesDB.classIndicatorFriendlyScale = BetterBlizzPlatesDB.classIndicatorScale
    end

    if not BetterBlizzPlatesDB.healerIndicatorEnemyXPos then
        BetterBlizzPlatesDB.healerIndicatorEnemyXPos = BetterBlizzPlatesDB.healerIndicatorXPos
        BetterBlizzPlatesDB.healerIndicatorEnemyYPos = BetterBlizzPlatesDB.healerIndicatorYPos
        BetterBlizzPlatesDB.healerIndicatorEnemyAnchor = BetterBlizzPlatesDB.healerIndicatorAnchor
        BetterBlizzPlatesDB.healerIndicatorEnemyScale = BetterBlizzPlatesDB.healerIndicatorScale
    end

    if BetterBlizzPlatesDB.friendlyHealthBarColorPlayer == nil then
        BetterBlizzPlatesDB.friendlyHealthBarColorPlayer = BetterBlizzPlatesDB.friendlyHealthBarColor
        BetterBlizzPlatesDB.friendlyHealthBarColorNpc = BetterBlizzPlatesDB.friendlyHealthBarColor
    end

    if not BetterBlizzPlatesDB.nameplateAuraRowFriendlyAmount then
        BetterBlizzPlatesDB.nameplateAuraRowFriendlyAmount = BetterBlizzPlatesDB.nameplateAuraRowAmount or 5
    end

    if not BetterBlizzPlatesDB.alwaysHideFriendlyCastbar then
        BetterBlizzPlatesDB.alwaysHideFriendlyCastbar = BetterBlizzPlatesDB.hideFriendlyCastbar or false
    end

    for key, defaultValue in pairs(defaultSettings) do
        if BetterBlizzPlatesDB[key] == nil then
            BetterBlizzPlatesDB[key] = defaultValue
        end
    end
end

function BBP.ResetTotemList()
    BetterBlizzPlatesDB.totemIndicatorNpcList = {}
    BetterBlizzPlatesDB.totemIndicatorNpcList = defaultSettings.totemIndicatorNpcList
end

local function CVarFetcher()
    if BBP.variablesLoaded then
        local classic = BetterBlizzPlatesDB.classicNameplates
        BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = 128, 32 --C_NamePlate.GetNamePlateEnemySize()
        BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = 128, 32 -- C_NamePlate.GetNamePlateFriendlySize()
        BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = 128, 32 -- C_NamePlate.GetNamePlateSelfSize()

        BetterBlizzPlatesDB.nameplateEnemyWidth = classic and 128 or 110
        BetterBlizzPlatesDB.nameplateFriendlyWidth = classic and 128 or 110
        BetterBlizzPlatesDB.nameplateSelfWidth = classic and 128 or 110

        BetterBlizzPlatesDB.nameplateShowAll = GetCVar("nameplateShowAll")

        BetterBlizzPlatesDB.nameplateOverlapH = GetCVar("nameplateOverlapH")
        BetterBlizzPlatesDB.nameplateOverlapV = GetCVar("nameplateOverlapV")
        BetterBlizzPlatesDB.nameplateMotionSpeed = GetCVar("nameplateMotionSpeed")
        BetterBlizzPlatesDB.nameplateHorizontalScale = GetCVar("NamePlateHorizontalScale")
        BetterBlizzPlatesDB.NamePlateVerticalScale = GetCVar("NamePlateVerticalScale")
        BetterBlizzPlatesDB.nameplateMinScale = GetCVar("nameplateMinScale")
        BetterBlizzPlatesDB.nameplateMaxScale = BetterBlizzPlatesDB.nameplateMinScale--GetCVar("nameplateMaxScale")
        BetterBlizzPlatesDB.nameplateSelectedScale = GetCVar("nameplateSelectedScale")
        BetterBlizzPlatesDB.NamePlateClassificationScale = GetCVar("NamePlateClassificationScale")
        BetterBlizzPlatesDB.nameplateGlobalScale = GetCVar("nameplateGlobalScale")
        BetterBlizzPlatesDB.nameplateLargerScale = GetCVar("nameplateLargerScale")
        --BetterBlizzPlatesDB.nameplatePlayerLargerScale = GetCVar("nameplatePlayerLargerScale")
        BetterBlizzPlatesDB.nameplateResourceOnTarget = GetCVar("nameplateResourceOnTarget")

        BetterBlizzPlatesDB.nameplateMinAlpha = 1--GetCVar("nameplateMinAlpha")
        BetterBlizzPlatesDB.nameplateMinAlphaDistance = GetCVar("nameplateMinAlphaDistance")
        BetterBlizzPlatesDB.nameplateMaxAlpha = GetCVar("nameplateMaxAlpha")
        BetterBlizzPlatesDB.nameplateMaxAlphaDistance = GetCVar("nameplateMaxAlphaDistance")
        BetterBlizzPlatesDB.nameplateOccludedAlphaMult = GetCVar("nameplateOccludedAlphaMult")
        BetterBlizzPlatesDB.nameplateSelectedAlpha = GetCVar("nameplateSelectedAlpha")
        BetterBlizzPlatesDB.nameplateNotSelectedAlpha = GetCVar("nameplateNotSelectedAlpha")

        BetterBlizzPlatesDB.nameplateMotion = GetCVar("nameplateMotion")

        BetterBlizzPlatesDB.ShowClassColorInNameplate = GetCVar("ShowClassColorInNameplate")
        BetterBlizzPlatesDB.ShowClassColorInFriendlyNameplate = GetCVar("ShowClassColorInFriendlyNameplate")

        BetterBlizzPlatesDB.nameplateShowEnemyGuardians = GetCVar("nameplateShowEnemyGuardians")
        BetterBlizzPlatesDB.nameplateShowEnemyMinions = GetCVar("nameplateShowEnemyMinions")
        BetterBlizzPlatesDB.nameplateShowEnemyMinus = GetCVar("nameplateShowEnemyMinus")
        BetterBlizzPlatesDB.nameplateShowEnemyPets = GetCVar("nameplateShowEnemyPets")
        BetterBlizzPlatesDB.nameplateShowEnemyTotems = GetCVar("nameplateShowEnemyTotems")

        BetterBlizzPlatesDB.nameplateShowFriendlyGuardians = GetCVar("nameplateShowFriendlyGuardians")
        BetterBlizzPlatesDB.nameplateShowFriendlyMinions = GetCVar("nameplateShowFriendlyMinions")
        BetterBlizzPlatesDB.nameplateShowFriendlyPets = GetCVar("nameplateShowFriendlyPets")
        BetterBlizzPlatesDB.nameplateShowFriendlyTotems = GetCVar("nameplateShowFriendlyTotems")
        BetterBlizzPlatesDB.nameplateShowFriendlyNPCs = GetCVar("nameplateShowFriendlyNPCs")

        if GetCVar("NamePlateHorizontalScale") == "1.4" then
            BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
            BetterBlizzPlatesDB.castBarHeight = 16
            BetterBlizzPlatesDB.largeNameplates = true
        else
            BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 4
            BetterBlizzPlatesDB.castBarHeight = 16
            BetterBlizzPlatesDB.largeNameplates = false
        end

    else
        C_Timer.After(1, function()
            CVarFetcher()
        end)
    end
end

local function FetchAndSaveValuesOnFirstLogin()
    if BBP.variablesLoaded then
        -- collect some cvars added at a later time
        if not BetterBlizzPlatesDB.nameplateMinAlpha or not BetterBlizzPlatesDB.nameplateShowFriendlyMinions or not BetterBlizzPlatesDB.nameplateSelectedAlpha then
            CVarFetcher()
        end

        if BetterBlizzPlatesDB.hasSaved then
            if BetterBlizzPlatesDB.sendResetMessage then
                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates has been reset. If you are having any issues feel free to join the Discord. You'll find the link in the Support section /bbp")
                BetterBlizzPlatesDB.sendResetMessage = nil
            end
            return
        end

        CVarFetcher()

        C_Timer.After(5, function()
            if not C_AddOns.IsAddOnLoaded("SkillCapped") then
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates first run. Thank you for trying out my AddOn. Access settings with /bbp")
            end
            StaticPopup_Show("BBP_RETAILORCLASSIC")
            BetterBlizzPlatesDB.hasSaved = true
        end)
    else
        C_Timer.After(1, function()
            FetchAndSaveValuesOnFirstLogin()
        end)
    end
end

function BBP.CVarsAreSaved()
    local db = BetterBlizzPlatesDB
    if db.nameplateEnemyWidth and
       db.nameplateFriendlyWidth and
       db.nameplateSelfWidth and
       db.nameplateOverlapH and
       db.nameplateOverlapV and
       db.nameplateMotionSpeed and
       db.nameplateHorizontalScale and
       db.NamePlateVerticalScale and
       db.nameplateMinScale and
       db.nameplateMaxScale and
       db.nameplateSelectedScale and
       db.NamePlateClassificationScale and
       db.nameplateGlobalScale and
       db.nameplateLargerScale and
       --db.nameplatePlayerLargerScale and
       db.nameplateMinAlpha and
       db.nameplateMinAlphaDistance and
       db.nameplateMaxAlpha and
       db.nameplateMaxAlphaDistance and
       db.nameplateOccludedAlphaMult then
        return true
    else
        return false
    end
end

local function ResetNameplates()
    local big = GetCVar("NamePlateHorizontalScale") == "1.4"
    local classic = BetterBlizzPlatesDB.classicNameplates
    BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = classic and 128 or 110, 32
    BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = classic and 128 or 110, 32
    BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = classic and 128 or 110, 32

    BetterBlizzPlatesDB.nameplateOverlapH = 0.8
    BetterBlizzPlatesDB.nameplateOverlapV = 0.8
    BetterBlizzPlatesDB.nameplateMotion = 0
    BetterBlizzPlatesDB.nameplateMotionSpeed = 0.025
    BetterBlizzPlatesDB.nameplateHorizontalScale = big and 1.4 or 1
    BetterBlizzPlatesDB.NamePlateVerticalScale = 1
    BetterBlizzPlatesDB.nameplateMinScale = 1
    BetterBlizzPlatesDB.nameplateMaxScale = 1
    BetterBlizzPlatesDB.nameplateSelectedScale = 1.2
    BetterBlizzPlatesDB.NamePlateClassificationScale = 1
    BetterBlizzPlatesDB.nameplateGlobalScale = 1
    BetterBlizzPlatesDB.nameplateLargerScale = 1.2
    BetterBlizzPlatesDB.nameplatePlayerLargerScale = 1.8
    BetterBlizzPlatesDB.nameplateResourceOnTarget = "0"

    BetterBlizzPlatesDB.nameplateMinAlpha = 1--0.6
    BetterBlizzPlatesDB.nameplateMinAlphaDistance = 10
    BetterBlizzPlatesDB.nameplateMaxAlpha = 1.0
    BetterBlizzPlatesDB.nameplateMaxAlphaDistance = 40
    BetterBlizzPlatesDB.nameplateOccludedAlphaMult = 0.4
    BetterBlizzPlatesDB.nameplateShowAll = "1"
    BetterBlizzPlatesDB.nameplateSelectedAlpha = "1"
    BetterBlizzPlatesDB.nameplateNotSelectedAlpha = "0.5"

    BetterBlizzPlatesDB.nameplateShowEnemyGuardians = "1"
    BetterBlizzPlatesDB.nameplateShowEnemyMinions = "1"
    BetterBlizzPlatesDB.nameplateShowEnemyMinus = "0"
    BetterBlizzPlatesDB.nameplateShowEnemyPets = "1"
    BetterBlizzPlatesDB.nameplateShowEnemyTotems = "1"

    BetterBlizzPlatesDB.nameplateShowFriendlyGuardians = "0"
    BetterBlizzPlatesDB.nameplateShowFriendlyMinions = "0"
    BetterBlizzPlatesDB.nameplateShowFriendlyPets = "0"
    BetterBlizzPlatesDB.nameplateShowFriendlyTotems = "0"

    BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 11
    BetterBlizzPlatesDB.castBarHeight = classic and 10 or 16--big and 18.8 or 8
    BetterBlizzPlatesDB.largeNameplates = big and true or false

    C_CVar.SetCVar("nameplateOverlapH", BetterBlizzPlatesDB.nameplateOverlapH)
    C_CVar.SetCVar("nameplateOverlapV", BetterBlizzPlatesDB.nameplateOverlapV)
    C_CVar.SetCVar("nameplateMotion", BetterBlizzPlatesDB.nameplateMotion)
    C_CVar.SetCVar("nameplateMotionSpeed", BetterBlizzPlatesDB.nameplateMotionSpeed)
    C_CVar.SetCVar("nameplateHorizontalScale", BetterBlizzPlatesDB.nameplateHorizontalScale)
    C_CVar.SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
    C_CVar.SetCVar("nameplateMinScale", BetterBlizzPlatesDB.nameplateMinScale)
    C_CVar.SetCVar("nameplateMaxScale", BetterBlizzPlatesDB.nameplateMaxScale)
    C_CVar.SetCVar("nameplateSelectedScale", BetterBlizzPlatesDB.nameplateSelectedScale)
    C_CVar.SetCVar("NamePlateClassificationScale", BetterBlizzPlatesDB.NamePlateClassificationScale)
    C_CVar.SetCVar("nameplateGlobalScale", BetterBlizzPlatesDB.nameplateGlobalScale)
    C_CVar.SetCVar("nameplateLargerScale", BetterBlizzPlatesDB.nameplateLargerScale)
    C_CVar.SetCVar("nameplatePlayerLargerScale", BetterBlizzPlatesDB.nameplatePlayerLargerScale)
    C_CVar.SetCVar("nameplateResourceOnTarget", BetterBlizzPlatesDB.nameplateResourceOnTarget)
    C_CVar.SetCVar("nameplateMinAlpha", BetterBlizzPlatesDB.nameplateMinAlpha)
    C_CVar.SetCVar("nameplateMinAlphaDistance", BetterBlizzPlatesDB.nameplateMinAlphaDistance)
    C_CVar.SetCVar("nameplateMaxAlpha", BetterBlizzPlatesDB.nameplateMaxAlpha)
    C_CVar.SetCVar("nameplateMaxAlphaDistance", BetterBlizzPlatesDB.nameplateMaxAlphaDistance)
    C_CVar.SetCVar("nameplateOccludedAlphaMult", BetterBlizzPlatesDB.nameplateOccludedAlphaMult)
    C_CVar.SetCVar("nameplateShowEnemyMinions", BetterBlizzPlatesDB.nameplateShowEnemyMinions)
    C_CVar.SetCVar("nameplateShowEnemyGuardians", BetterBlizzPlatesDB.nameplateShowEnemyGuardians)
    C_CVar.SetCVar("nameplateShowEnemyMinus", BetterBlizzPlatesDB.nameplateShowEnemyMinus)
    C_CVar.SetCVar("nameplateShowEnemyPets", BetterBlizzPlatesDB.nameplateShowEnemyPets)
    C_CVar.SetCVar("nameplateShowEnemyTotems", BetterBlizzPlatesDB.nameplateShowEnemyTotems)
    C_CVar.SetCVar("nameplateShowFriendlyMinions", BetterBlizzPlatesDB.nameplateShowFriendlyMinions)
    C_CVar.SetCVar("nameplateShowFriendlyGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyGuardians)
    C_CVar.SetCVar("nameplateShowFriendlyPets", BetterBlizzPlatesDB.nameplateShowFriendlyPets)
    C_CVar.SetCVar("nameplateShowFriendlyTotems", BetterBlizzPlatesDB.nameplateShowFriendlyTotems)
    C_CVar.SetCVar('nameplateShowOnlyNames', "0")
    C_CVar.SetCVar("nameplateShowAll", "1")

    ReloadUI()
end

local function ResetBBP()
    BetterBlizzPlatesDB = {}

    ResetNameplates()

    BetterBlizzPlatesDB.hasSaved = true
    BetterBlizzPlatesDB.updates = addonUpdates
    BetterBlizzPlatesDB.sendResetMessage = true
    BetterBlizzPlatesDB.reopenOptions = true

    ReloadUI()
end

StaticPopupDialogs["CONFIRM_RESET_BETTERBLIZZPLATESDB"] = {
    text = "Are you sure you want to reset all BetterBlizzPlates settings?\nThis action cannot be undone.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        ResetBBP()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CONFIRM_FIX_NAMEPLATES_BBP"] = {
    text = "Are you sure you want to reset nameplate CVar's?\nThis action cannot be undone.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        ResetNameplates()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


StaticPopupDialogs["BETTERBLIZZPLATES_COMBAT_WARNING"] = {
    text = "Leave combat to adjust this setting.",
    button1 = "Okay",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function UpdateAuraColorsToGreen()
    if BetterBlizzPlatesDB and BetterBlizzPlatesDB["auraWhitelist"] then
        for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
            if entry.entryColors and entry.entryColors.text then
                -- Update to green color
                entry.entryColors.text.r = 0
                entry.entryColors.text.g = 1
                entry.entryColors.text.b = 0
            else
                entry.entryColors = { text = { r = 0, g = 1, b = 0 } }
            end
        end
    end
end

local function AddAlphaValuesToAuraColors()
    if BetterBlizzPlatesDB and BetterBlizzPlatesDB["auraWhitelist"] then
        for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
            if entry.entryColors and entry.entryColors.text then
                entry.entryColors.text.a = 1
            else
                entry.entryColors = { text = { r = 0, g = 1, b = 0, a = 1 } }
            end
        end
    end
end

-- Update message
local function SendUpdateMessage()
    if sendUpdate then
        if not BetterBlizzPlatesDB.scStart then
            C_Timer.After(7, function()
                --bbp news
                --PlaySoundFile(567439) --quest complete sfx
                --BBP.CreateUpdateMessageWindow()
                if not BetterBlizzPlatesDB.classicNameplates and (BetterBlizzPlatesDB.NamePlateVerticalScale ~= 1 and BetterBlizzPlatesDB.NamePlateVerticalScale ~= "1") then
                    StaticPopup_Show("BBP_UPDATE_NOTIF")
                end
                --DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates " .. addonUpdates .. ":")
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates Cata Beta 0.0.8:")
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a Tweaks:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Tweaked castbar stuff again. Might require tweaks on your settings if smth looks off.")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Hide Level Frame Setting: Now completely hides the level frame on classic nameplates and extends the health bar.")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Nameplate Auras: Added stack number like on retail.")

                -- DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Bugfixes/Tweaks:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Read curseforge changelog for bugfix list.")
            end)
        else
            BetterBlizzPlatesDB.scStart = nil
        end
    end
end

local function NewsUpdateMessage()
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates news:")
    DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New Settings:")
    DEFAULT_CHAT_FRAME:AddMessage("   - I changed up how nameplate aura filters work. I removed the \"All\" filter as a part of this.")
    DEFAULT_CHAT_FRAME:AddMessage("   - Anchor Nameplate Combopoints to bottom of healthbar/castbar (Blizzard CVar's).")
    DEFAULT_CHAT_FRAME:AddMessage("   - Hide nameplate auras on NPC's (Nameplate Auras).")

    DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Bugfixes:")
    DEFAULT_CHAT_FRAME:AddMessage("   - Fix \"Castbar Quick Hide\" setting.")
    DEFAULT_CHAT_FRAME:AddMessage("   - Fixed the \"Center auras\" fix... They should now work properly.")

    DEFAULT_CHAT_FRAME:AddMessage("|A:GarrisonTroops-Health:16:16|a Patreon link: www.patreon.com/bodydev")
end

local function CheckForUpdate()
    if not BetterBlizzPlatesDB.hasSaved then
        BetterBlizzPlatesDB.updates = addonUpdates
        return
    end
    if not BetterBlizzPlatesDB.updates or BetterBlizzPlatesDB.updates ~= addonUpdates then
        SendUpdateMessage()
        BetterBlizzPlatesDB.updates = addonUpdates
    end
end


--##############################################################################################################################################
--##############################################################################################################################################
--##############################################################################################################################################
------------------------------------------------------------------------------------------------------
--- Functions
------------------------------------------------------------------------------------------------------

-- Checks if the unit is nameplate and legal
function BBP.IsLegalNameplateUnit(frame)
    if not (frame and frame.unit) then return end
    if not string.match(frame.unit, "nameplate") then return end
    if frame:IsForbidden() then return end
    return true
end

function BBP.WaitThen(func, delay)
    local function waitFunc()
        if BBP.variablesLoaded then
            func()
        else
            C_Timer.After(delay or 0.1, waitFunc)
        end
    end
    waitFunc()
end

function BBP.GetUnitReaction(unit)
    -- Check if the unit is attackable first, useful for target dummies
--[[
    if UnitCanAttack("player", unit) then
        return true, false, false  -- Unit is an enemy because it's attackable
    end

]]


    local reaction = UnitReaction(unit, "player")

    local isEnemy = false
    local isFriend = false
    local isNeutral = false

    if reaction then
        if reaction < 4 then
            isEnemy = true  -- Units with a reaction less than 4 are enemies
        elseif reaction == 4 then
            isNeutral = true  -- A reaction of 4 is neutral
        else
            isFriend = true  -- Reactions of 5 and above are friendly
        end
    end

    return isEnemy, isFriend, isNeutral
end

local function GetNameplateUnitInfo(frame, unit)
    local unit = unit or frame.unit or frame.displayedUnit
    if not unit then return end

    if not frame.BetterBlizzPlates.unitInfo then
        frame.BetterBlizzPlates.unitInfo = {}
    end
    local info = frame.BetterBlizzPlates.unitInfo

    info.name = UnitName(unit)
    info.isSelf = UnitIsUnit("player", unit)
    info.isTarget = UnitIsUnit("target", unit)
    info.isFocus = UnitIsUnit("focus", unit)
    info.isPlayer = UnitIsPlayer(unit)
    info.isNpc = not info.isPlayer
    info.unitGUID = UnitGUID(unit)
    info.class = info.isPlayer and UnitClassBase(unit) or nil
    info.reaction = UnitReaction(unit, "player")
    info.isEnemy = (info.reaction and info.reaction < 4) and not info.isSelf
    info.isNeutral = (info.reaction and info.reaction == 4) and not info.isSelf
    info.isFriend = (info.reaction and info.reaction >= 5) and not info.isSelf
    info.playerClass = playerClass

    return info
end
BBP.GetNameplateUnitInfo = GetNameplateUnitInfo


-- If player was just on loading screen set wasOnLoadingScreen to true and skip running functions
local function LoadingScreenDetector(_, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "LOADING_SCREEN_ENABLED" then
        BetterBlizzPlatesDB.wasOnLoadingScreen = true
    elseif event == "LOADING_SCREEN_DISABLED" or event == "PLAYER_LEAVING_WORLD" then
        C_Timer.After(2, function()
            BetterBlizzPlatesDB.wasOnLoadingScreen = false
        end)
    end
end

local LoadingScreenFrame = CreateFrame("Frame")
LoadingScreenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
LoadingScreenFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
LoadingScreenFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
LoadingScreenFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
LoadingScreenFrame:SetScript("OnEvent", LoadingScreenDetector)

-- Function to check combat and show popup if in combat
function BBP.checkCombatAndWarn()
    if InCombatLockdown() then
        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            if IsActiveBattlefieldArena() then
                return true -- Player is in combat but don't show the popup during arena
            else
                StaticPopup_Show("BETTERBLIZZPLATES_COMBAT_WARNING")
                return true -- Player is in combat and outside of arena, so show the pop-up
            end
        end
    end
    return false -- Player is not in combat
end

local function TurnOffTestModes()
    local db = BetterBlizzPlatesDB
    db.absorbIndicatorTestMode = false
    db.petIndicatorTestMode = false
    db.healerIndicatorTestMode = false
    db.arenaIndicatorTestMode = false
    db.totemIndicatorTestMode = false
    db.targetIndicatorTestMode = false
    db.focusTargetIndicatorTestMode = false
    db.questIndicatorTestMode = false
    db.executeIndicatorTestMode = false
    db.testAllEnabledFeatures = false
    db.nameplateAuraTestMode = false
    db.partyPointerTestMode = false
    db.healthNumbersTestMode = false
end

-- Extracts NPC ID from GUID
function BBP.GetNPCIDFromGUID(guid)
    return tonumber(string.match(guid, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function BBP.GetNameplate(unit)
    return C_NamePlate.GetNamePlateForUnit(unit)
end
local C_NamePlate = C_NamePlate
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

function BBP.GetSafeNameplate(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    -- If there's no nameplate or the nameplate doesn't have a UnitFrame, return nils.
    if not nameplate or not nameplate.UnitFrame then return nil, nil end

    local frame = nameplate.UnitFrame
    -- If none of the above conditions are met, return both the nameplate and the frame.
    return nameplate, frame
end


-- is large nameplates enabled
function BBP.isLargeNameplatesEnabled()
    return GetCVar("NamePlateHorizontalScale") == "1.4"
end

function BBP.GetDefaultFadeOutNPCsList()
    return defaultSettings.defaultFadeOutNPCsList
end

function BBP.GetOppositeAnchor(anchor)
    local opposites = {
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        TOPLEFT = "BOTTOMRIGHT",
        TOPRIGHT = "BOTTOMLEFT",
        BOTTOMLEFT = "TOPRIGHT",
        BOTTOMRIGHT = "TOPLEFT",
    }
    return opposites[anchor] or "CENTER"
end

--#################################################################################################
-- Set nameplate width
function BBP.ApplyNameplateWidth()
    if not BBP.checkCombatAndWarn() then
        if BetterBlizzPlatesDB.nameplateEnemyHeight and BetterBlizzPlatesDB.nameplateFriendlyHeight then
            local friendlyWidth = BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeFriendlyWidth or BetterBlizzPlatesDB.nameplateDefaultFriendlyWidth
            local enemyWidth = BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeEnemyWidth or BetterBlizzPlatesDB.nameplateDefaultEnemyWidth
            local generalHeight = BetterBlizzPlatesDB.nameplateGeneralHeight
            local friendlyHeight = BetterBlizzPlatesDB.friendlyNameplateClickthrough and 1 or generalHeight--(BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeFriendlyHeight or BetterBlizzPlatesDB.nameplateDefaultFriendlyHeight)

            if BetterBlizzPlatesDB.NamePlateVerticalScale then
                C_CVar.SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
            end

            if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
                C_NamePlate.SetNamePlateFriendlyClickThrough(true)
            else
                C_NamePlate.SetNamePlateFriendlyClickThrough(false)
            end

            if BetterBlizzPlatesDB.nameplateSelfHeight then
                C_NamePlate.SetNamePlateSelfSize(BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight)
            end

            local friendlyWidthAdjustment = BBP.isInPvE and 128 or BetterBlizzPlatesDB.nameplateFriendlyWidth
            C_NamePlate.SetNamePlateFriendlySize(friendlyWidthAdjustment, friendlyHeight)--friendlyHeight)
            C_NamePlate.SetNamePlateEnemySize(BetterBlizzPlatesDB.nameplateEnemyWidth, generalHeight)--BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeEnemyHeight or BetterBlizzPlatesDB.nameplateDefaultEnemyHeight)
        end
    end
end

--#################################################################################################
--  Remove realm names
function BBP.RemoveRealmName(frame)
    local name = GetUnitName(frame.unit)
    if name then
        name = string.gsub(name, " %(%*%)$", "")
        frame.name:SetText(name)
    end
end


--#################################################################################################
local function isFriendlistFriend(unit)
    for i = 1, C_FriendList.GetNumFriends() do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.name == UnitName(unit) then
            return true
        end
    end
    return false
end

local function isUnitGuildmate(unit)
    local guildName = GetGuildInfo(unit)
    local playerGuildName = GetGuildInfo("player")
    return guildName and playerGuildName and (guildName == playerGuildName)
end

local function isUnitBNetFriend(unit)
    local unitName = UnitName(unit)
    local numBNetFriends = BNGetNumFriends()
    for i = 1, numBNetFriends do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
            local characterName = accountInfo.gameAccountInfo.characterName
            if characterName and characterName == unitName then
                return true
            end
        end
    end
    return false
end

local function anonMode(frame, info)
    if info.isPlayer and not info.isSelf then
        frame.name:SetText(UnitClass(frame.unit))
    end
end

--#################################################################################################
-- Set custom healthbar texture
local function textureExtraBars(frame, setting)
    local extraBars = BetterBlizzPlatesDB.useCustomTextureForExtraBars
    if extraBars then
        frame.otherHealPrediction:SetTexture(setting)
        frame.myHealPrediction:SetTexture(setting)
        frame.totalAbsorb:SetTexture(setting)
    end
end

function BBP.ApplyCustomTextureToNameplate(frame)
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)

    --if not info.useCustomTextureForBars then return end

    if not config.customTextureInitialized or BBP.needsUpdate then
        config.useCustomTextureForBars = BetterBlizzPlatesDB.useCustomTextureForBars
        config.useCustomTextureForEnemy = BetterBlizzPlatesDB.useCustomTextureForEnemy and config.useCustomTextureForBars
        config.useCustomTextureForFriendly = BetterBlizzPlatesDB.useCustomTextureForFriendly and config.useCustomTextureForBars
        config.useCustomTextureForSelf = BetterBlizzPlatesDB.useCustomTextureForSelf and config.useCustomTextureForBars
        config.useCustomTextureForSelfMana = BetterBlizzPlatesDB.useCustomTextureForSelfMana and config.useCustomTextureForBars
        config.useCustomTextureForExtraBars = BetterBlizzPlatesDB.useCustomTextureForExtraBars

        local customTexture = BetterBlizzPlatesDB.customTexture
        local customTextureFriendly = BetterBlizzPlatesDB.customTextureFriendly
        local customTextureSelf = BetterBlizzPlatesDB.customTextureSelf
        local customTextureSelfMana = BetterBlizzPlatesDB.customTextureSelfMana

        config.customTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, customTexture)
        config.customTextureFriendly = LSM:Fetch(LSM.MediaType.STATUSBAR, customTextureFriendly)
        config.customTextureSelf = LSM:Fetch(LSM.MediaType.STATUSBAR, customTextureSelf)
        config.customTextureSelfMana = LSM:Fetch(LSM.MediaType.STATUSBAR, customTextureSelfMana)
        frame.healthBar.border:SetFrameStrata("HIGH")
        frame.LevelFrame:SetFrameStrata("DIALOG")

        config.customTextureInitialized = true
    end

    local defaultTex = "Interface/TargetingFrame/UI-TargetingFrame-BarFill"

    if not config.useCustomTextureForBars then
        frame.healthBar:SetStatusBarTexture(defaultTex)
        textureExtraBars(frame, config.customTextureFriendly)
        return
    end

    if not info then return end

    if info.isSelf then
        if (config.useCustomTextureForSelf or config.useCustomTextureForSelfMana) then
            if config.useCustomTextureForSelf then
                frame.healthBar:SetStatusBarTexture(config.customTextureSelf)
                textureExtraBars(frame, config.customTextureSelf)
            elseif BBP.needsUpdate then
                frame.healthBar:SetStatusBarTexture(defaultTex)
                textureExtraBars(frame, defaultTex)
            end
            if config.useCustomTextureForSelfMana then
                ClassNameplateManaBarFrame:SetStatusBarTexture(config.customTextureSelfMana)
            elseif BBP.needsUpdate then
                ClassNameplateManaBarFrame:SetStatusBarTexture(defaultTex)
            end
        elseif BBP.needsUpdate then
            frame.healthBar:SetStatusBarTexture(defaultTex)
            textureExtraBars(frame, defaultTex)
            ClassNameplateManaBarFrame:SetStatusBarTexture(defaultTex)
        else
            frame.healthBar:SetStatusBarTexture(defaultTex)
            textureExtraBars(frame, defaultTex)
        end
    elseif (info.isEnemy or info.isNeutral) then
        if config.useCustomTextureForEnemy then
            frame.healthBar:SetStatusBarTexture(config.customTexture)
            textureExtraBars(frame, config.customTexture)
        elseif BBP.needsUpdate then
            frame.healthBar:SetStatusBarTexture(defaultTex)
            textureExtraBars(frame, defaultTex)
        end
    elseif info.isFriend then
        if config.useCustomTextureForFriendly then
            frame.healthBar:SetStatusBarTexture(config.customTextureFriendly)
            textureExtraBars(frame, config.customTextureFriendly)
        elseif BBP.needsUpdate then
            frame.healthBar:SetStatusBarTexture(defaultTex)
            textureExtraBars(frame, defaultTex)
        else
            frame.healthBar:SetStatusBarTexture(defaultTex)
            textureExtraBars(frame, defaultTex)
        end
    elseif BBP.needsUpdate then--or info.wasFocus or info.wasTarget then
        frame.healthBar:SetStatusBarTexture(defaultTex)
        textureExtraBars(frame, defaultTex)
        if not config.useCustomTextureForSelfMana then
            ClassNameplateManaBarFrame:SetStatusBarTexture(defaultTex)
        end
    else
        frame.healthBar:SetStatusBarTexture(defaultTex)
        textureExtraBars(frame, defaultTex)
    end
end

--###############################################
local function ColorNameplateByReaction(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    if info.isSelf then return end

    if not config.friendlyHealthBarColorInitalized or BBP.needsUpdate then
        config.friendlyHealthBarColor = BetterBlizzPlatesDB.friendlyHealthBarColor
        config.friendlyHealthBarColorRGB = BetterBlizzPlatesDB.friendlyHealthBarColorRGB
        config.friendlyHealthBarColorPlayer = BetterBlizzPlatesDB.friendlyHealthBarColorPlayer
        config.friendlyHealthBarColorNpc = BetterBlizzPlatesDB.friendlyHealthBarColorNpc
        config.enemyHealthBarColor = BetterBlizzPlatesDB.enemyHealthBarColor
        config.enemyHealthBarColorNpcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly

        config.friendlyHealthBarColorInitalized = true
    end

    if info.isFriend and config.friendlyHealthBarColor then
        -- Friendly NPC
        if (info.isPlayer and config.friendlyHealthBarColorPlayer) or (info.isNpc and config.friendlyHealthBarColorNpc) then
            frame.healthBar:SetStatusBarColor(unpack(config.friendlyHealthBarColorRGB))
        end
    elseif not info.isFriend and config.enemyHealthBarColor then
        -- Handling enemy health bars
        if (not config.enemyHealthBarColorNpcOnly) or (config.enemyHealthBarColorNpcOnly and not info.isPlayer) then
            if info.isNeutral then
                -- Neutral NPC
                config.enemyNeutralHealthBarColorRGB = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 0, 0}
                frame.healthBar:SetStatusBarColor(unpack(config.enemyNeutralHealthBarColorRGB))
            else
                -- Hostile NPC
                config.enemyHealthBarColorRGB = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
                frame.healthBar:SetStatusBarColor(unpack(config.enemyHealthBarColorRGB))
            end
        end
    end
end

-- local function ChangeHealthbarHeight(frame)
--     local config = frame.BetterBlizzPlates.config
--     local info = frame.BetterBlizzPlates.unitInfo

--     if not config.hpHeightEnemy or BBP.needsUpdate then
--         config.hpHeightEnemy = BetterBlizzPlatesDB.hpHeightEnemy
--         config.hpHeightFriendly = BetterBlizzPlatesDB.hpHeightFriendly
--     end

--     local healthBar = frame.healthBar

--     if info.isFriend then
--         if info.isSelf then
--             healthBar:SetScale(1)
--         else
--             healthBar:SetScale(config.hpHeightFriendly)
--         end
--     else
--         healthBar:SetScale(config.hpHeightEnemy)
--     end
-- end

--#################################################################################################
function BBP.SetFontBasedOnOption(namePlateObj, specifiedSize, forcedOutline)
    local font, outline, currentSize
    local useCustomFont = BetterBlizzPlatesDB.useCustomFont

    if useCustomFont then
        local fontName = BetterBlizzPlatesDB.customFont
        local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
        local fontSize = BetterBlizzPlatesDB.defaultFontSize
        font = fontPath
        outline = forcedOutline or "THINOUTLINE"
        currentSize = (specifiedSize + 2) or (fontSize + 3)
    else
        local defaultNamePlateFontFlags =BetterBlizzPlatesDB.defaultNamePlateFontFlags
        local defaultFontSize = BetterBlizzPlatesDB.defaultFontSize
        font = BetterBlizzPlatesDB.defaultNamePlateFont
        outline = forcedOutline or defaultNamePlateFontFlags
        currentSize = specifiedSize or defaultFontSize
    end

    namePlateObj:SetFont(font, currentSize, outline)
end

--#################################################################################################
-- Friendly nameplates on only in arena toggle automatically
-- Event listening for Nameplates on in arena only
local toggleEventsRegistered = false
local inCombatEventRegistered = false

local friendlyNameplatesOnOffFrame = CreateFrame("Frame")

local function ShouldShowFriendlyNameplates()
    local instanceType = select(2, IsInInstance())
    local showInArena = instanceType == "arena" and BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena
    local showInDungeon = (instanceType == "party" or instanceType == "raid" or instanceType == "scenario") and BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons
    local showInBg = instanceType == "pvp" and BetterBlizzPlatesDB.friendlyNameplatesOnlyInBgs

    if instanceType == "arena" then
        return showInArena
    elseif instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
        return showInDungeon
    elseif instanceType == "pvp" then
        return showInBg
    else
        -- Outside of dungeons and arenas
        return not BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons and not BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena
    end
end

local function ApplyCVarChange()
    local shouldShow = ShouldShowFriendlyNameplates() and "1" or "0"
    if GetCVar("nameplateShowFriends") ~= shouldShow then
        C_CVar.SetCVar("nameplateShowFriends", shouldShow)
    end
    if inCombatEventRegistered then
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        inCombatEventRegistered = false
    end
end

local function ToggleFriendlyPlates()
    if BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena or BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons then
        if InCombatLockdown() and not inCombatEventRegistered then
            friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            inCombatEventRegistered = true
        elseif not InCombatLockdown() then
            ApplyCVarChange()
        end
    end
end

friendlyNameplatesOnOffFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        ApplyCVarChange()
    else
        ToggleFriendlyPlates()
    end
end)

function BBP.ToggleFriendlyNameplatesAuto()
    if (BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena or BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons) and not toggleEventsRegistered then
        friendlyNameplatesOnOffFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        toggleEventsRegistered = true
    elseif toggleEventsRegistered then
        friendlyNameplatesOnOffFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        toggleEventsRegistered = false
    end
    ToggleFriendlyPlates()
end

--#################################################################################################
-- Set CVars that keep changing
local function SetCVarsOnLogin()
    if BetterBlizzPlatesDB.hasSaved and not BetterBlizzPlatesDB.disableCVarForceOnLogin then
        C_CVar.SetCVar("nameplateMaxDistance", 41)
        C_CVar.SetCVar("nameplateOverlapH", BetterBlizzPlatesDB.nameplateOverlapH)
        C_CVar.SetCVar("nameplateOverlapV", BetterBlizzPlatesDB.nameplateOverlapV)
        C_CVar.SetCVar("nameplateMotionSpeed", BetterBlizzPlatesDB.nameplateMotionSpeed)
        C_CVar.SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
        C_CVar.SetCVar("nameplateSelectedScale", BetterBlizzPlatesDB.nameplateSelectedScale)
        C_CVar.SetCVar("nameplateMinScale", BetterBlizzPlatesDB.nameplateMinScale)
        C_CVar.SetCVar("nameplateMaxScale", BetterBlizzPlatesDB.nameplateMaxScale)
        C_CVar.SetCVar("nameplateMinAlpha", BetterBlizzPlatesDB.nameplateMinAlpha)
        C_CVar.SetCVar("nameplateMinAlphaDistance", BetterBlizzPlatesDB.nameplateMinAlphaDistance)
        C_CVar.SetCVar("nameplateMaxAlpha", BetterBlizzPlatesDB.nameplateMaxAlpha)
        C_CVar.SetCVar("nameplateMaxAlphaDistance", BetterBlizzPlatesDB.nameplateMaxAlphaDistance)
        C_CVar.SetCVar("nameplateOccludedAlphaMult", BetterBlizzPlatesDB.nameplateOccludedAlphaMult)
        C_CVar.SetCVar("nameplateGlobalScale", BetterBlizzPlatesDB.nameplateGlobalScale)
        C_CVar.SetCVar("nameplateResourceOnTarget", BetterBlizzPlatesDB.nameplateResourceOnTarget)
        if BetterBlizzPlatesDB.nameplateSelectedAlpha then
            C_CVar.SetCVar("nameplateSelectedAlpha", BetterBlizzPlatesDB.nameplateSelectedAlpha)
            C_CVar.SetCVar("nameplateNotSelectedAlpha", BetterBlizzPlatesDB.nameplateNotSelectedAlpha)
        end

        if BetterBlizzPlatesDB.nameplateMotion then
            C_CVar.SetCVar("nameplateMotion", BetterBlizzPlatesDB.nameplateMotion)
        end

        if BetterBlizzPlatesDB.NamePlateVerticalScale then
            local verticalScale = tonumber(BetterBlizzPlatesDB.NamePlateVerticalScale)
            if verticalScale and verticalScale >= 2 then
                C_CVar.SetCVar("NamePlateHorizontalScale", 1.4)
            else
                C_CVar.SetCVar("NamePlateHorizontalScale", 1)
            end
        end

        if BetterBlizzPlatesDB.setCVarAcrossAllCharacters then
            if BetterBlizzPlatesDB.nameplateShowAll then
                C_CVar.SetCVar("nameplateShowAll", BetterBlizzPlatesDB.nameplateShowAll)
            end

            C_CVar.SetCVar("nameplateShowEnemyMinions", BetterBlizzPlatesDB.nameplateShowEnemyMinions)
            C_CVar.SetCVar("nameplateShowEnemyGuardians", BetterBlizzPlatesDB.nameplateShowEnemyGuardians)
            C_CVar.SetCVar("nameplateShowEnemyMinus", BetterBlizzPlatesDB.nameplateShowEnemyMinus)
            C_CVar.SetCVar("nameplateShowEnemyPets", BetterBlizzPlatesDB.nameplateShowEnemyPets)
            C_CVar.SetCVar("nameplateShowEnemyTotems", BetterBlizzPlatesDB.nameplateShowEnemyTotems)

            C_CVar.SetCVar("nameplateShowFriendlyMinions", BetterBlizzPlatesDB.nameplateShowFriendlyMinions)
            C_CVar.SetCVar("nameplateShowFriendlyGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyGuardians)
            if BetterBlizzPlatesDB.nameplateShowFriendlyNPCs then
                C_CVar.SetCVar("nameplateShowFriendlyNPCs", BetterBlizzPlatesDB.nameplateShowFriendlyNPCs)
            end
            C_CVar.SetCVar("nameplateShowFriendlyPets", BetterBlizzPlatesDB.nameplateShowFriendlyPets)
            C_CVar.SetCVar("nameplateShowFriendlyTotems", BetterBlizzPlatesDB.nameplateShowFriendlyTotems)
        end

        ToggleFriendlyPlates()
    end
end

--#################################################################################################
function BBP.ToggleNameplateAuras(frame)
    local db = BetterBlizzPlatesDB
    if not db.nameplateAuraPlayersOnly then return end
    if not frame.BuffFrame then return end
    --if not frame then return end

    local isTarget = UnitIsUnit(frame.unit, "target") --needs update
    local isPlayer = UnitIsPlayer(frame.unit)
    local shouldShowAuras = isPlayer or (db.nameplateAuraPlayersOnlyShowTarget and isTarget)

    frame.BuffFrame:SetAlpha(shouldShowAuras and 1 or 0)
end

function BBP.TargetNameplateAuraSize(frame)
    local db = BetterBlizzPlatesDB
    if not db.targetNameplateAuraScaleEnabled then return end
    --if not frame then return end
    local isTarget = UnitIsUnit(frame.unit, "target") --needs update

    frame.BuffFrame:SetScale(isTarget and db.targetNameplateAuraScale or 1)
    frame.BuffFrame:ClearAllPoints()
    if isTarget then
        local info = frame.BetterBlizzPlates.unitInfo
        local nameplateAurasFriendlyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor and not info.isEnemy
        local nameplateAurasEnemyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor and info.isEnemy
        if nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
            frame.BuffFrame:SetPoint("BOTTOM", frame, "TOP", 0, -10+BetterBlizzPlatesDB.nameplateAurasYPos)
        else
            frame.BuffFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -10+BetterBlizzPlatesDB.nameplateAurasYPos)
        end
    else
        frame.BuffFrame:SetPoint("BOTTOM", frame, "TOP", 0, -10+BetterBlizzPlatesDB.nameplateAurasYPos)
    end
end

--#################################################################################################
local function ToggleNameplateBuffFrameVisibility(frame)
    -- local config = frame.BetterBlizzPlates.config
    -- local info = frame.BetterBlizzPlates.unitInfo

    -- local buffFrameAlpha = 1
    -- if config.hideNameplateAuras then
    --     buffFrameAlpha = 0
    -- elseif config.nameplateAuraPlayersOnly then
    --     if config.nameplateAuraPlayersOnlyShowTarget and info.isTarget then
    --         buffFrameAlpha = 1
    --     else
    --         buffFrameAlpha = info.isPlayer and 1 or 0
    --     end
    -- end
    -- frame.BuffFrame:SetAlpha(buffFrameAlpha) --bodifycata
end

local function ToggleTargetNameplateHighlight(frame)
    local config = frame.BetterBlizzPlates.config
    frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or 0.22)
end

--#################################################################################################
-- Clickthrough nameplates function
-- function BBP.ClickthroughNameplateAuras(pool, namePlateFrameBase) bodifycata
--     if not namePlateFrameBase.BuffFrame.buffPool.hooked then
--         namePlateFrameBase.BuffFrame.buffPool.hooked=true
--         hooksecurefunc(namePlateFrameBase.BuffFrame.buffPool,"resetterFunc",function(pool2,buff)
--             buff:SetMouseClickEnabled(false)
--         end)
--     end
-- end
-- hooksecurefunc(NamePlateDriverFrame.pools:GetPool("NamePlateUnitFrameTemplate"),"resetterFunc",BBP.ClickthroughNameplateAuras)
--hooksecurefunc(NamePlateDriverFrame.pools:GetPool("ForbiddenNamePlateUnitFrameTemplate"),"resetterFunc",BBP.ClickthroughNameplateAuras)

--#################################################################################################
-- Class color and scale names 
function BBP.ClassColorAndScaleNames(frame)
    local isPlayer = UnitIsPlayer(frame.unit)
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
    local enemyScale = BetterBlizzPlatesDB.enemyNameScale
    local friendlyScale = BetterBlizzPlatesDB.friendlyNameScale
    local enemyColorName = BetterBlizzPlatesDB.enemyColorName
    local friendlyColorName = BetterBlizzPlatesDB.friendlyColorName
    local enemyClassColorName = BetterBlizzPlatesDB.enemyClassColorName
    local friendlyClassColorName = BetterBlizzPlatesDB.friendlyClassColorName

    -- Set the name's color based on unit relation and options
    if isPlayer then
        if ((isEnemy or isNeutral) and enemyClassColorName) or (isFriend and friendlyClassColorName) then
            local _, class = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[class]
            frame.name:SetVertexColor(classColor.r, classColor.g, classColor.b)
        elseif ((isEnemy or isNeutral) and enemyColorName) or (isFriend and friendlyColorName) then
            local color = isEnemy and BetterBlizzPlatesDB.enemyColorNameRGB or BetterBlizzPlatesDB.friendlyColorNameRGB
            frame.name:SetVertexColor(unpack(color))
        end
    elseif ((isEnemy or isNeutral) and enemyColorName) or (isFriend and friendlyColorName) then
        local color = (isEnemy and BetterBlizzPlatesDB.enemyColorNameRGB) or (isNeutral and BetterBlizzPlatesDB.enemyNeutralColorNameRGB) or (isFriend and BetterBlizzPlatesDB.friendlyColorNameRGB)
        frame.name:SetVertexColor(unpack(color))
    end

    -- Set the name's scale based on unit relation
    local scale = 1 -- Default scale
    if isFriend then
        scale = friendlyScale or 1
    else
        scale = enemyScale or 1
    end
    frame.name:SetIgnoreParentScale(true)
    frame.name:SetScale(scale)
    if frame.fakeName then
        frame.fakeName:SetScale(scale)
    end
end


--#################################################################################################
-- Dark Mode for Nameplate Resources
local function applySettings(frame, desaturate, colorValue)
    if frame then
        if desaturate ~= nil and frame.SetDesaturated then -- Check if SetDesaturated is available
            frame:SetDesaturated(desaturate)
        end
        if frame.SetVertexColor then
            frame:SetVertexColor(colorValue, colorValue, colorValue) -- Alpha set to 1
        end
    end
end

function BBP.DarkModeNameplateResources()
    local darkModeNpSatVal = BetterBlizzPlatesDB.darkModeNameplateResource and true or false
    local vertexColor = BetterBlizzPlatesDB.darkModeNameplateResource and BetterBlizzPlatesDB.darkModeNameplateColor or 1
    local druidComboPoint = BetterBlizzPlatesDB.darkModeNameplateResource and (vertexColor + 0.2) or 1
    local druidComboPointActive = BetterBlizzPlatesDB.darkModeNameplateResource and (vertexColor + 0.1) or 1
    local actionBarColor = BetterBlizzPlatesDB.darkModeActionBars and (vertexColor + 0.15) or 1
    local rogueCombo = BetterBlizzPlatesDB.darkModeNameplateResource and (vertexColor + 0.45) or 1
    local rogueComboActive = BetterBlizzPlatesDB.darkModeNameplateResource and (vertexColor + 0.30) or 1
    local monkChi = BetterBlizzPlatesDB.darkModeNameplateResource and (vertexColor + 0.10) or 1


    local nameplateRunes = _G.DeathKnightResourceOverlayFrame
    if nameplateRunes and not nameplateRunes:IsForbidden() then
        local dkNpRunes = vertexColor or 1
        for i = 1, 6 do
            applySettings(nameplateRunes["Rune" .. i].BG_Active, darkModeNpSatVal, dkNpRunes)
            applySettings(nameplateRunes["Rune" .. i].BG_Inactive, darkModeNpSatVal, dkNpRunes)
        end
    end

    local soulShardsNameplate = _G.ClassNameplateBarWarlockFrame
    if soulShardsNameplate and not soulShardsNameplate:IsForbidden() then
        local soulShardNp = vertexColor or 1
        for _, v in pairs({soulShardsNameplate:GetChildren()}) do
            applySettings(v.Background, darkModeNpSatVal, soulShardNp)
        end
    end

    local druidComboPointsNameplate = _G.ClassNameplateBarFeralDruidFrame
    if druidComboPointsNameplate and not druidComboPointsNameplate:IsForbidden() then
        local druidComboPointNp = druidComboPoint or 1
        local druidComboPointActiveNp = druidComboPointActive or 1
        for _, v in pairs({druidComboPointsNameplate:GetChildren()}) do
            applySettings(v.BG_Inactive, darkModeNpSatVal, druidComboPointNp)
            applySettings(v.BG_Active, darkModeNpSatVal, druidComboPointActiveNp)
        end
    end

    local mageArcaneChargesNameplate = _G.ClassNameplateBarMageFrame
    if mageArcaneChargesNameplate and not mageArcaneChargesNameplate:IsForbidden() then
        local mageChargeNp = actionBarColor or 1
        for _, v in pairs({mageArcaneChargesNameplate:GetChildren()}) do
            applySettings(v.ArcaneBG, darkModeNpSatVal, mageChargeNp)
            --applySettings(v.BG_Active, desaturationValue, druidComboPointActive)
        end
    end

    local monkChiPointsNameplate = _G.ClassNameplateBarWindwalkerMonkFrame
    if monkChiPointsNameplate and not monkChiPointsNameplate:IsForbidden() then
        local monkChiNp = monkChi or 1
        for _, v in pairs({monkChiPointsNameplate:GetChildren()}) do
            applySettings(v.Chi_BG, darkModeNpSatVal, monkChiNp)
            applySettings(v.Chi_BG_Active, darkModeNpSatVal, monkChiNp)
        end
    end

    local rogueComboPointsNameplate = _G.ClassNameplateBarRogueFrame
    if rogueComboPointsNameplate and not rogueComboPointsNameplate:IsForbidden() then
        local rogueComboNp = rogueCombo or 1
        local rogueComboActiveNp = rogueComboActive or 1
        for _, v in pairs({rogueComboPointsNameplate:GetChildren()}) do
            applySettings(v.BGInactive, darkModeNpSatVal, rogueComboNp)
            applySettings(v.BGActive, darkModeNpSatVal, rogueComboActiveNp)
        end
    end

    local paladinHolyPowerNameplate = _G.ClassNameplateBarPaladinFrame
    if paladinHolyPowerNameplate and not paladinHolyPowerNameplate:IsForbidden() then
        local palaPowerNp = vertexColor or 1
        applySettings(ClassNameplateBarPaladinFrame.Background, darkModeNpSatVal, palaPowerNp)
        applySettings(ClassNameplateBarPaladinFrame.ActiveTexture, darkModeNpSatVal, palaPowerNp)
    end

    local evokerEssencePointsNameplate = _G.ClassNameplateBarDracthyrFrame
    if evokerEssencePointsNameplate and not evokerEssencePointsNameplate:IsForbidden() then
        local evokerColorOne = monkChi or 1
        local evokerColorTwo = vertexColor or 1
        for _, v in pairs({evokerEssencePointsNameplate:GetChildren()}) do
            applySettings(v.EssenceFillDone.CircBG, darkModeNpSatVal, evokerColorOne)
            applySettings(v.EssenceFilling.EssenceBG, darkModeNpSatVal, evokerColorTwo)
            applySettings(v.EssenceEmpty.EssenceBG, darkModeNpSatVal, evokerColorTwo)
            applySettings(v.EssenceFillDone.CircBGActive, darkModeNpSatVal, evokerColorTwo)

            applySettings(v.EssenceDepleting.EssenceBG, darkModeNpSatVal, evokerColorTwo)
            applySettings(v.EssenceDepleting.CircBGActive, darkModeNpSatVal, evokerColorTwo)

            applySettings(v.EssenceFillDone.RimGlow, darkModeNpSatVal, evokerColorOne)
            applySettings(v.EssenceDepleting.RimGlow, darkModeNpSatVal, evokerColorOne)
        end
    end
end



--#################################################################################################
-- test all active functions
function BBP.ToggleTestAllEnabledFeatures()
    if BetterBlizzPlatesDB.wasOnLoadingScreen then return end
    if BetterBlizzPlatesDB.testAllEnabledFeatures then
        BetterBlizzPlatesDB.testAllEnabledFeatures = false
    else
        BetterBlizzPlatesDB.testAllEnabledFeatures = true
    end

end


function BBP.TestAllEnabledFeatures(option, value)
    if BetterBlizzPlatesDB.wasOnLoadingScreen then return end
    local featuresWithTestModes = {
        "absorbIndicator",
        "executeIndicator",
        "healerIndicator",
        "petIndicator",
        "targetIndicator",
        "focusTargetIndicator",
        "totemIndicator",
        "questIndicator",
        "partyPointer",
    }

    -- Iterate over all features and update their test modes
    for _, feature in ipairs(featuresWithTestModes) do
        if BetterBlizzPlatesDB[feature] then
            -- Construct the testMode key by appending "TestMode" to the feature name
            local testModeKey = feature .. "TestMode"
            BetterBlizzPlatesDB[testModeKey] = value
        end
    end
    -- Refresh all nameplates to apply the changes
    BBP.RefreshAllNameplates()
    BBP.ToggleTestAllEnabledFeatures()
end

--#################################################################################################
-- Reset slider to default value function
function BBP.ResetToDefaultWidth(slider, isFriendly)
    local friendlyHeight = BetterBlizzPlatesDB.friendlyNameplateClickthrough and 1 or generalHeight

    if not BBP.checkCombatAndWarn() then
        local classic = BetterBlizzPlatesDB.classicNameplates
        local width = classic and 128 or 110
        local height = BetterBlizzPlatesDB.nameplateGeneralHeight
        if isFriendly then
            if BBP.isLargeNameplatesEnabled() then
                C_NamePlate.SetNamePlateFriendlySize(width, friendlyHeight)
                slider:SetValue(width)
            else
                C_NamePlate.SetNamePlateFriendlySize(width, friendlyHeight)
                slider:SetValue(width)
            end
        else
            if slider ~= nameplateSelfWidth then
                if BBP.isLargeNameplatesEnabled() then
                    C_NamePlate.SetNamePlateEnemySize(width, height)
                    slider:SetValue(width)
                else
                    C_NamePlate.SetNamePlateEnemySize(width, height)
                    slider:SetValue(width)
                end
            else
                C_NamePlate.SetNamePlateFriendlySize(width, friendlyHeight)
                slider:SetValue(width)
            end
        end
    end
end

--#################################################################################################
-- Reset to default CVar values
function BBP.ResetToDefaultScales(slider, targetType)
    -- Define default values
    local defaultSettings = {
        nameplateScale = 1,
        nameplateSelected = 1.2,
    }

    -- Set the slider's value to the default
    slider:SetValue(defaultSettings[targetType] or 1)

    if not BBP.checkCombatAndWarn() then
        if targetType == "nameplateScale" then
            -- Reset both nameplateMinScale and nameplateMaxScale based on their ratio
            local defaultMinScale = 1
            local defaultMaxScale = 1
            local defaultGlobalScale = 1
            BetterBlizzPlatesDB.nameplateMinScale = defaultMinScale
            BetterBlizzPlatesDB.nameplateMaxScale = defaultMaxScale
            BetterBlizzPlatesDB.nameplateGlobalScale = defaultGlobalScale
            C_CVar.SetCVar("nameplateMinScale", defaultMinScale)
            C_CVar.SetCVar("nameplateMaxScale", defaultMaxScale)
            C_CVar.SetCVar("nameplateGlobalScale", defaultGlobalScale)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinScale set to " .. defaultMinScale)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMaxScale set to " .. defaultMaxScale)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateGlobalScale set to 1")
        elseif targetType == "nameplateSelected" then
            BetterBlizzPlatesDB.nameplateSelectedScale = defaultSettings[targetType]
            C_CVar.SetCVar("nameplateSelectedScale", defaultSettings[targetType])
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateSelectedScale set to " .. defaultSettings[targetType])
        end
    end
end


function BBP.ResetToDefaultHeight(slider)
    if BetterBlizzPlatesDB.classicNameplates then
        slider:SetValue(10)
        BetterBlizzPlatesDB.castBarHeight = 10
    else
        slider:SetValue(16)
        BetterBlizzPlatesDB.castBarHeight = 16
    end
end

function BBP.ResetToDefaultHeight2(slider)
    -- if BBP.isLargeNameplatesEnabled() then
    --     --slider:SetValue(10.8)
    --     --BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
    --     slider:SetValue(2.7)
    --     BetterBlizzPlatesDB.NamePlateVerticalScale = "2.7"
    --     DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar NamePlateVerticalScale set to 2.7")
    -- else
        --slider:SetValue(4)
        --BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 4
        slider:SetValue(1)
        BetterBlizzPlatesDB.NamePlateVerticalScale = "1"
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar NamePlateVerticalScale set to 1")
    --end
end

function BBP.ResetToDefaultValue(slider, element)
    if not BBP.checkCombatAndWarn() then
        local default = C_CVar.GetCVarDefault(element)
        if element == "nameplateOverlapH" then
            BetterBlizzPlatesDB.nameplateOverlapH = default
            C_CVar.SetCVar("nameplateOverlapH", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOverlapH set to "..default)
        elseif element == "nameplateOverlapV" then
            BetterBlizzPlatesDB.nameplateOverlapV = default
            C_CVar.SetCVar("nameplateOverlapV", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOverlapV set to "..default)
        elseif element == "nameplateMotionSpeed" then
            BetterBlizzPlatesDB.nameplateMotionSpeed = default
            C_CVar.SetCVar("nameplateMotionSpeed", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMotionSpeed set to "..default)
        elseif element == "nameplateMinAlpha" then
            BetterBlizzPlatesDB.nameplateMinAlpha = default
            C_CVar.SetCVar("nameplateMinAlpha", 1)--default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinAlpha set to "..default)
        elseif element == "nameplateMinAlphaDistance" then
            BetterBlizzPlatesDB.nameplateMinAlphaDistance = default
            C_CVar.SetCVar("nameplateMinAlphaDistance", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinAlphaDistance set to "..default)
        elseif element == "nameplateMaxAlpha" then
            BetterBlizzPlatesDB.nameplateMaxAlpha = default
            C_CVar.SetCVar("nameplateMaxAlpha", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMotionSpeed set to "..default)
        elseif element == "nameplateMaxAlphaDistance" then
            BetterBlizzPlatesDB.nameplateMaxAlphaDistance = default
            C_CVar.SetCVar("nameplateMaxAlphaDistance", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMaxAlphaDistance set to "..default)
        elseif element == "nameplateOccludedAlphaMult" then
            BetterBlizzPlatesDB.nameplateOccludedAlphaMult = default
            C_CVar.SetCVar("nameplateOccludedAlphaMult", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOccludedAlphaMult set to "..default)
        elseif element == "nameplateSelectedAlpha" then
            BetterBlizzPlatesDB.nameplateSelectedAlpha = default
            C_CVar.SetCVar("nameplateOccludedAlphaMult", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateSelectedAlpha set to "..default)
        elseif element == "nameplateNotSelectedAlpha" then
            BetterBlizzPlatesDB.nameplateNotSelectedAlpha = default
            C_CVar.SetCVar("nameplateNotSelectedAlpha", default)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateNotSelectedAlpha set to "..default)
        elseif element == "nameplateResourceScale" then
            BetterBlizzPlatesDB.nameplateResourceScale = 0.7
        elseif element == "nameplateResourceXPos" then
            BetterBlizzPlatesDB.nameplateResourceXPos = 0
        elseif element == "nameplateResourceYPos" then
            BetterBlizzPlatesDB.nameplateResourceYPos = 0
        elseif element == "hpHeightFriendly" then
            BetterBlizzPlatesDB.hpHeightFriendly = 9--4 * tonumber(GetCVar("NamePlateVerticalScale"))
        elseif element == "hpHeightEnemy" then
            BetterBlizzPlatesDB.hpHeightEnemy = 9--4 * tonumber(GetCVar("NamePlateVerticalScale"))
        elseif element == "nameplateGeneralHeight" then
            BetterBlizzPlatesDB.nameplateGeneralHeight = 32
        end
        slider:SetValue(BetterBlizzPlatesDB[element])
    end
end

function BBP.ToggleAndPrintCVAR(cvarName)
    local currentValue = GetCVar(cvarName)
    local newValue = (currentValue == "1") and "0" or "1"

    C_CVar.SetCVar(cvarName, newValue)
    print(string.format("%s set to %s", cvarName, newValue))
end

--##################################################################################################
-- Fade out npcs from list
function BBP.FadeOutNPCs(frame)
    frame:SetAlpha(1)
    -- Skip if the unit is a player
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    if info.isPlayer then return end
    if not info.unitGUID then return end

    local npcID = select(6, strsplit("-", info.unitGUID))
    local npcName = info.name

    if not config.fadeAllButTarget or BBP.needsUpdate then
        config.fadeOutNPCsAlpha = BetterBlizzPlatesDB.fadeOutNPCsAlpha
        config.fadeAllButTarget = BetterBlizzPlatesDB.fadeAllButTarget
    end

    if config.fadeAllButTarget then
        if UnitExists("target") then
            if not info.isTarget and not info.isPlayer then
                frame:SetAlpha(config.fadeOutNPCsAlpha)
            else
                frame:SetAlpha(1)
            end
        else
            frame:SetAlpha(1)
        end
        return
    end

    -- Convert npcName to lowercase for case insensitive comparison
    local lowerCaseNpcName = strlower(npcName)

    -- Check if the NPC is in the list by ID or name (case insensitive)
    local inList = false
    local fadeOutNPCsList = BetterBlizzPlatesDB.fadeOutNPCsList
    for _, npc in ipairs(fadeOutNPCsList) do
        if npc.id == tonumber(npcID) or (npc.id and npc.id == tonumber(npcID)) then
            inList = true
            break
        elseif npc.name == tostring(npcName) or strlower(npc.name) == lowerCaseNpcName then
            inList = true
            break
        end
    end

    -- Check if the unit is the current target
    if info.isTarget then
        frame:SetAlpha(1)
    elseif inList then
        frame:SetAlpha(config.fadeOutNPCsAlpha)
    else
        frame:SetAlpha(1)
    end
end


--##################################################################################################
-- Hide npcs from list
-- Initialize shadow realm frame and shadows table
local shadowRealm = CreateFrame("Frame")
shadowRealm:Hide()
local shadows = {}

-- Hide NPCs from list
function BBP.HideNPCs(frame, nameplate)
    if not frame or not frame.displayedUnit then return end

    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    BBP.ShowFrame(frame, nameplate, config)

    local db = BetterBlizzPlatesDB
    local hideNPCArenaOnly = db.hideNPCArenaOnly
    local hideNPCWhitelistOn = db.hideNPCWhitelistOn
    local hideNPCPetsOnly = db.hideNPCPetsOnly
    local inBg = BBP.isInPvP
    local isPet = (UnitGUID(frame.displayedUnit) and select(6, strsplit("-", UnitGUID(frame.displayedUnit))) == "Pet")
    local hideAllNeutral = db.hideNPCAllNeutral and info.isNeutral and UnitAffectingCombat(frame.unit)

    if hideNPCArenaOnly and not inBg then
        return
    end

    -- Skip if the unit is a player
    if info.isPlayer then
        BBP.ResetFrame(frame, config, info)
        return
    end

    if hideAllNeutral and not UnitIsUnit(frame.displayedUnit, "target") then
        BBP.HideNameplate(nameplate)
        return
    end

    if info.isFriend then
        local hideNpcHpBar = db.friendlyHideHealthBarNpc
        if config.friendlyHideHealthBar and hideNpcHpBar then
            frame.healthBar:SetAlpha(0)
            frame.selectionHighlight:SetAlpha(0)
            return
        end
    end

    local unitGUID = UnitGUID(frame.displayedUnit)
    if not unitGUID then return end

    local npcID = select(6, strsplit("-", unitGUID))
    local npcName = UnitName(frame.displayedUnit)
    local lowerCaseNpcName = strlower(npcName)

    -- Initialize murlocMode if not present
    BBP.InitMurlocMode(frame, config, db)

    local listToCheck = hideNPCWhitelistOn and db.hideNPCsWhitelist or db.hideNPCsList
    local inList, showMurloc = BBP.CheckNPCList(listToCheck, npcID, lowerCaseNpcName)

    -- Determine if the frame should be shown based on the list check or if it's the current target
    if UnitIsUnit(frame.displayedUnit, "target") then
        BBP.ShowFrame(frame, nameplate, config)
        frame.healthBar:SetAlpha(config.friendlyHideHealthBar and info.isFriend and 0 or 1)
        frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or 0.22)
    elseif hideNPCWhitelistOn then
        if inList then
            if showMurloc then
                BBP.ShowMurloc(frame, nameplate)
            else
                BBP.ShowFrame(frame, nameplate, config)
            end
        else
            BBP.HideNameplate(nameplate)
        end
    elseif inList or (hideNPCPetsOnly and isPet) then
        if showMurloc then
            BBP.ShowMurloc(frame, nameplate)
        else
            BBP.HideNameplate(nameplate)
        end
    else
        BBP.ShowFrame(frame, nameplate, config)
    end
end

-- Resets the frame to default display settings
function BBP.ResetFrame(frame, config, info)
    if frame.murlocMode then
        frame.murlocMode:Hide()
        frame.hideNameOverride = false
        frame.hideCastbarOverride = false
        frame.healthBar:SetAlpha((info.isSelf and 1) or (config.friendlyHideHealthBar and info.isFriend and 0) or 1)
        frame.selectionHighlight:SetAlpha(((info.isFriend and config.friendlyHideHealthBar) and 0) or (config.hideTargetHighlight and 0) or 0.22)
        ToggleNameplateBuffFrameVisibility(frame)
        if frame.fakeName then
            frame.fakeName:SetAlpha(1)
        else
            frame.name:SetAlpha(1)
        end
    end
end

-- Initializes the murlocMode texture on the frame
function BBP.InitMurlocMode(frame, config, db)
    if not frame.murlocMode then
        frame.murlocMode = frame:CreateTexture(nil, "OVERLAY")
        frame.murlocMode:SetAtlas("newplayerchat-chaticon-newcomer")
        frame.murlocMode:SetSize(14, 14)
        frame.murlocMode:Hide()
    end

    if not config.hideNpcMurlocYPos or BBP.needsUpdate then
        config.hideNpcMurlocYPos = db.hideNpcMurlocYPos or 0
        config.hideNpcMurlocScale = db.hideNpcMurlocScale

        frame.murlocMode:SetPoint("CENTER", frame, "CENTER", 0, config.hideNpcMurlocYPos)
        frame.murlocMode:SetScale(config.hideNpcMurlocScale)
    end
end

-- Checks if an NPC is in the provided list
function BBP.CheckNPCList(list, npcID, lowerCaseNpcName)
    local inList = false
    local showMurloc = false
    for _, npc in ipairs(list) do
        if npc.id == tonumber(npcID) or strlower(npc.name) == lowerCaseNpcName then
            inList = true
            if npc.flags and npc.flags.murloc then
                showMurloc = true
            end
            break
        end
    end
    return inList, showMurloc
end

-- Shows the frame with default settings
function BBP.ShowFrame(frame, nameplate, config)
    if shadows[nameplate] then
        nameplate:SetParent(shadows[nameplate])
        shadows[nameplate] = nil
    end
    frame.hideCastInfo = false
    if frame.murlocMode then
        frame.murlocMode:Hide()
    end
    frame.hideNameOverride = false
    frame.hideCastbarOverride = false
end

-- Shows the murlocMode on the frame
function BBP.ShowMurloc(frame, nameplate)
    if shadows[nameplate] then
        nameplate:SetParent(shadows[nameplate])
        shadows[nameplate] = nil
    end
    frame.healthBar:SetAlpha(0)
    frame.selectionHighlight:SetAlpha(0)
    frame.BuffFrame:SetAlpha(0)
    if frame.fakeName then
        frame.fakeName:SetAlpha(0)
    else
        frame.name:SetAlpha(0)
    end
    frame.murlocMode:Show()
    frame.hideNameOverride = true
    frame.hideCastbarOverride = true
end

-- Hides the nameplate by setting its parent to shadowRealm
function BBP.HideNameplate(nameplate)
    if not shadows[nameplate] then
        shadows[nameplate] = nameplate:GetParent()
        nameplate:SetParent(shadowRealm)
    end
end

local function ShowLastNameOnlyNpc(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if info.isNpc then
        local name = info.name
        local lastName = name:match("([^%s%-]+)$")  -- Matches the last word after a space or dash
        frame.name:SetText(lastName)
        if frame.fakeName then
            frame.fakeName:SetText(lastName)
        end
    end
end

function BBP.ColorThreat(frame)
    if not frame or not frame.unit then return end

    local combatOnly = BetterBlizzPlatesDB.enemyColorThreatCombatOnly and not UnitAffectingCombat(frame.unit)
    if combatOnly then return end
    if UnitIsPlayer(frame.unit) then return end

    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.unit)
    local r, g, b

    if BBP.isRoleTank then
        r, g, b = unpack(BetterBlizzPlatesDB.tankNoAggroColorRGB)

        if ( isTanking and threatStatus ) then
            if ( threatStatus >= 3 ) then
                r, g, b = unpack(BetterBlizzPlatesDB.tankFullAggroColorRGB)
            else
                -- targets me, but losing aggro
                r, g, b = GetThreatStatusColor(threatStatus)
            end
        end
    else
        r, g, b = unpack(BetterBlizzPlatesDB.dpsOrHealNoAggroColorRGB)

        if ( isTanking ) then
            r, g, b = unpack(BetterBlizzPlatesDB.dpsOrHealFullAggroColorRGB)
        elseif ( threatStatus and threatStatus > 0 ) then
            -- about to pull aggro
            r, g, b = GetThreatStatusColor(threatStatus)
        end
    end

    frame.healthBar:SetStatusBarColor(r, g, b)
end


--################################################################################################
-- Color NPCs
function BBP.ColorNpcHealthbar(frame)
    if not frame or not frame.unit then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    -- Skip if the unit is a player
    if info.isPlayer then return end
    if not info.unitGUID then return end

    local npcID = select(6, strsplit("-", info.unitGUID))
    local npcName = UnitName(frame.unit)

    -- Convert npcName to lowercase for case insensitive comparison
    local lowerCaseNpcName = strlower(npcName)

    -- Check if the NPC is in the list by ID or name (case insensitive)
    local inList = false
    local npcHealthbarColor = nil
    local colorNpcList = BetterBlizzPlatesDB.colorNpcList
    for _, npc in ipairs(colorNpcList) do
        if npc.id == tonumber(npcID) or (npc.name and strlower(npc.name) == lowerCaseNpcName) then
            inList = true
            if npc.entryColors then
                npcHealthbarColor = npc.entryColors.text
            else
                npc.entryColors = {} -- default for new entries that doesnt have a color yet
            end
            break
        end
    end

    -- Set the vertex color based on the NPC color values
    if inList and npcHealthbarColor then
        config.npcHealthbarColor = npcHealthbarColor
        frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
        local colorNPCName = BetterBlizzPlatesDB.colorNPCName
        if colorNPCName then
            frame.name:SetVertexColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
        end
    else
        config.npcHealthbarColor = nil
    end
end
-- frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
-- frame.name:SetVertexColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)

BBP.auraListNeedsUpdate = true
BBP.spellIdLookup = {}
BBP.auraNameLookup = {}

function BBP.UpdateAuraLookupTables()
    if not BBP.auraListNeedsUpdate then return end

    -- Clear existing lookup tables
    wipe(BBP.spellIdLookup)
    wipe(BBP.auraNameLookup)

    -- Populate new lookup tables
    for _, npc in ipairs(BetterBlizzPlatesDB.auraColorList) do
        if npc.id then
            BBP.spellIdLookup[npc.id] = {priority = npc.priority, color = npc.entryColors.text}
        end
        if npc.name then
            local lowerCaseName = strlower(npc.name)
            BBP.auraNameLookup[lowerCaseName] = {priority = npc.priority, color = npc.entryColors.text}
        end
    end

    BBP.auraListNeedsUpdate = false -- Reset the flag
end

function BBP.AuraColor(frame)
    if not frame or not frame.unit then return end
    if frame.unit == "player" then return end
    -- Ensure the aura lookup tables are up-to-date
    BBP.UpdateAuraLookupTables()

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    if BetterBlizzPlatesDB.auraColorPvEOnly and BBP.isInPvP then
        if config.auraColorRGB then
            config.auraColorRGB = nil
            BBP.CompactUnitFrame_UpdateHealthColor(frame)
        end
        return
    end
    local highestPriority = 0
    local auraColor = nil

    local function ProcessAura(filter)
        for index = 1, 40 do
            local name, icon, count, dispelType, duration, expirationTime, source, isStealable, 
                  nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura(frame.unit, index, filter)
            
            if not name then break end

            local spellInfo = BBP.spellIdLookup[spellId]
            if not spellInfo then
                spellInfo = BBP.auraNameLookup[strlower(name)]
            end
            if spellInfo and spellInfo.priority > highestPriority then
                highestPriority = spellInfo.priority
                auraColor = spellInfo.color
            end
            if highestPriority >= 10 then return true end
        end
    end

    -- Process both "HELPFUL" and "HARMFUL" auras
    ProcessAura("HELPFUL")
    ProcessAura("HARMFUL")

    -- Set the vertex color based on the highest priority aura color
    if auraColor then
        config.auraColorRGB = auraColor
        frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b)
    else
        config.auraColorRGB = nil
    end
end


local UnitAuraEventFrame = nil

local function UnitAuraColorEvent(self, event, ...)
    local unit = ...
    if unit:find("nameplate") then
        local nameplate, frame = BBP.GetSafeNameplate(unit)
        if not frame then return end
        BBP.AuraColor(frame)
    end
end

function BBP.CreateUnitAuraEventFrame()
    if not BetterBlizzPlatesDB.auraColor or UnitAuraEventFrame then
        return
    end
    UnitAuraEventFrame = CreateFrame("Frame")
    UnitAuraEventFrame:SetScript("OnEvent", UnitAuraColorEvent)
    UnitAuraEventFrame:RegisterEvent("UNIT_AURA")
end

-- if not frame.BetterBlizzPlates.bbpBorder then
--     frame.healthBar.border:Hide()
--     frame.BetterBlizzPlates.bbpBorder = CreateFrame("Frame", nil, frame)
--     local border = frame.BetterBlizzPlates.bbpBorder

--     local left = border:CreateTexture(nil, "OVERLAY")
--     left:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderLeft")
--     left:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", -28, -3.5)
--     border.left = left

--     local center = border:CreateTexture(nil, "OVERLAY")
--     center:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderCenter")
--     center:SetPoint("LEFT", left, "RIGHT", 0, 0)
--     border.center = center

--     local right = border:CreateTexture(nil, "OVERLAY")
--     right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRight")
--     right:SetPoint("LEFT", center, "RIGHT", 0, 0)
--     border.right = right

--     border:SetParent(frame.healthBar)

--     function border:SetBorderColor(r, g, b, a)
--         self.left:SetDesaturated(true)
--         self.center:SetDesaturated(true)
--         self.right:SetDesaturated(true)
--         self.left:SetVertexColor(r, g, b, a)
--         self.center:SetVertexColor(r, g, b, a)
--         self.right:SetVertexColor(r, g, b, a)
--     end
-- end

local function AdjustClassicBorderWidth(frame)
    local width = frame.healthBar:GetWidth() + 25
    local extraWidth = BetterBlizzPlatesDB.hideLevelFrame and 6.5 or 0
    frame.BetterBlizzPlates.bbpBorder.center:SetWidth((width - 40)+extraWidth)
end

local function CreateBetterClassicHealthbarBorder(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)

    if not frame.BetterBlizzPlates.bbpBorder then
        frame.healthBar.border:Hide()
        frame.BetterBlizzPlates.bbpBorder = CreateFrame("Frame", nil, frame)
        local border = frame.BetterBlizzPlates.bbpBorder

        local left = border:CreateTexture(nil, "OVERLAY", nil, -1)
        left:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderLeft")
        left:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", -28, -3)
        left:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", -28, 17)
        border.left = left

        local center = border:CreateTexture(nil, "OVERLAY", nil, -1)
        center:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderCenter")
        center:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", 0, 0)
        center:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        border.center = center

        local right = border:CreateTexture(nil, "OVERLAY", nil, -1)
        right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRight")
        right:SetPoint("BOTTOMLEFT", center, "BOTTOMRIGHT", 0, 0)
        right:SetPoint("TOPLEFT", center, "TOPRIGHT", 0, 0)
        border.right = right

        border:SetParent(frame.healthBar)

        function border:SetBorderColor(r, g, b, a)
            if BetterBlizzPlatesDB.npBorderDesaturate then
                self.left:SetDesaturated(true)
                self.center:SetDesaturated(true)
                self.right:SetDesaturated(true)
            end
            self.left:SetVertexColor(r, g, b, a)
            self.center:SetVertexColor(r, g, b, a)
            self.right:SetVertexColor(r, g, b, a)
        end
    end

    local height = frame.healthBar:GetHeight()
    local bottomOffset = -((5/11) * height - 1.09)
    local topOffset = (2 * height) - 1

    if config.hideLevelFrame and not frame.BetterBlizzPlates.bbpBorder.changed then
        frame.BetterBlizzPlates.bbpBorder.right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRightNoLevel")
        frame.BetterBlizzPlates.bbpBorder.changed = true
    end

    frame.BetterBlizzPlates.bbpBorder.left:ClearAllPoints()
    frame.BetterBlizzPlates.bbpBorder.left:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", -28, bottomOffset)
    frame.BetterBlizzPlates.bbpBorder.left:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", -28, topOffset)

    --local width = info.isFriend and BetterBlizzPlatesDB.nameplateFriendlyWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
    -- local width = frame.healthBar:GetWidth() + 25
    -- frame.BetterBlizzPlates.bbpBorder.center:SetWidth(width - 40)
end


local function ColorNameplateNameReaction(frame)
    local r, g, b
    if UnitIsTapDenied(frame.unit) then
        r, g, b = 0.5, 0.5, 0.5
    else
        r, g, b = UnitSelectionColor(frame.unit, true)
    end
    frame.name:SetTextColor(r, g, b)
end

function BBP.CustomizeNameOnNameplate(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    frame.name:ClearAllPoints()
    -- frame.name:SetPoint("CENTER", frame, "CENTER", 0, 10)

    if not config.fakeNameXPos or BBP.needsUpdate then
        config.fakeNameXPos = BetterBlizzPlatesDB.fakeNameXPos
        config.fakeNameYPos = BetterBlizzPlatesDB.fakeNameYPos
        config.fakeNameFriendlyXPos = BetterBlizzPlatesDB.fakeNameFriendlyXPos
        config.fakeNameFriendlyYPos = BetterBlizzPlatesDB.fakeNameFriendlyYPos
        config.useFakeNameAnchorBottom = BetterBlizzPlatesDB.useFakeNameAnchorBottom
        config.fakeNameAnchor = BetterBlizzPlatesDB.fakeNameAnchor
        config.fakeNameAnchorRelative = BetterBlizzPlatesDB.fakeNameAnchorRelative
        config.fakeNameScaleWithParent = BetterBlizzPlatesDB.fakeNameScaleWithParent
    end

    local clickthroughHeight = (frame:GetHeight() < 2) and 15.5 or 0
    local clickableAdjustment = BetterBlizzPlatesDB.nameplateGeneralHeight - 32

    if info.isFriend then
        -- if config.useFakeNameAnchorBottom then
        --     frame.fakeName:SetPoint("BOTTOM", frame, "BOTTOM", config.fakeNameFriendlyXPos, config.fakeNameFriendlyYPos + 27)
        -- else
            frame.name:SetPoint(config.fakeNameAnchor, frame, config.fakeNameAnchorRelative, config.fakeNameFriendlyXPos, (config.fakeNameFriendlyYPos - 7 + frame.healthBar:GetHeight() + clickthroughHeight)-(clickableAdjustment/2))
        --end
    else
        frame.name:SetPoint(config.fakeNameAnchor, frame, config.fakeNameAnchorRelative, config.fakeNameXPos, (config.fakeNameYPos - 7 + frame.healthBar:GetHeight() + clickthroughHeight)-(clickableAdjustment/2))
    end

    ColorNameplateNameReaction(frame)
end

local function CreateBetterClassicCastbarBorders(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    --local width = info.isFriend and BetterBlizzPlatesDB.nameplateFriendlyWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
    local width = frame.healthBar:GetWidth() + 25
    local levelFrameAdjustment = BetterBlizzPlatesDB.hideLevelFrame and -17 or 0

    -- Helper function to create borders
    local function CreateBorder(frame, textureLeft, textureCenter, textureRight, yPos)
        local border = CreateFrame("Frame", nil, frame.CastBar)
        border:SetFrameStrata("HIGH")
        local left = border:CreateTexture(nil, "OVERLAY")
        left:SetTexture(textureLeft)
        left:SetPoint("BOTTOMLEFT", frame.CastBar, "BOTTOMLEFT", -21, yPos)
        border.left = left

        local center = border:CreateTexture(nil, "OVERLAY")
        center:SetTexture(textureCenter)
        center:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        center:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", 0, 0)
        border.center = center

        local right = border:CreateTexture(nil, "OVERLAY")
        right:SetTexture(textureRight)
        right:SetPoint("TOPLEFT", center, "TOPRIGHT", 0, 0)
        right:SetPoint("BOTTOMLEFT", center, "BOTTOMRIGHT", 0, 0)
        border.right = right

        border:Hide()
        return border
    end

    if frame.BigDebuffs then
        frame.BigDebuffs:SetFrameStrata("HIGH")
    end

    -- Interruptible
    if not frame.CastBar.bbpCastBorder then
        frame.CastBar.Border:SetAlpha(0)
        frame.CastBar.bbpCastBorder = CreateBorder(
            frame,
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastBorderLeft",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastBorderCenter",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastBorderRight",
            -3
        )
        frame.CastBar.Icon:SetParent(frame.CastBar)
        frame.CastBar.Icon:SetDrawLayer("OVERLAY", 7)
    end
    frame.CastBar.bbpCastBorder.center:SetWidth(width - 40 + levelFrameAdjustment)

    -- Uninterruptible
    if not frame.CastBar.bbpCastUninterruptibleBorder then
        frame.CastBar.BorderShield:SetAlpha(0)
        frame.CastBar.bbpCastUninterruptibleBorder = CreateBorder(
            frame,
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastUninterruptibleLeft",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastUninterruptibleCenter",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastUninterruptibleRight",
            -11
        )
        if BetterBlizzPlatesDB.hideCastbarBorderShield then
            frame.CastBar.bbpCastUninterruptibleBorder.left:SetAlpha(0)
            frame.CastBar.bbpCastUninterruptibleBorder.right:SetAlpha(0)
            frame.CastBar.bbpCastUninterruptibleBorder.center:SetAlpha(0)
        end
    end
    frame.CastBar.bbpCastUninterruptibleBorder.center:SetWidth(width - 40 + levelFrameAdjustment)

    -- Update border visibility
    local function UpdateBorders()
        frame.CastBar.Border:SetAlpha(0)
        frame.CastBar.BorderShield:SetAlpha(0)
        if frame.CastBar.BorderShield:IsShown() then
            frame.CastBar.bbpCastUninterruptibleBorder:Show()
            frame.CastBar.bbpCastBorder:Hide()
            frame.CastBar.Icon:SetParent(frame.CastBar.bbpCastUninterruptibleBorder)
        else
            frame.CastBar.bbpCastUninterruptibleBorder:Hide()
            frame.CastBar.bbpCastBorder:Show()
            frame.CastBar.Icon:SetParent(frame.CastBar.bbpCastBorder)
        end
        frame.CastBar.Icon:SetDrawLayer("OVERLAY", 7) -- Ensure the icon is on top

        local height = frame.CastBar:GetHeight()
        local bottomOffset = -((5/11) * height - 1.09)
        local topOffset = (1.97 * height)-- - 1
        frame.CastBar.bbpCastBorder.left:ClearAllPoints()
        frame.CastBar.bbpCastBorder.left:SetPoint("TOPLEFT", frame.CastBar, "TOPLEFT", -21, topOffset)
        frame.CastBar.bbpCastBorder.left:SetPoint("BOTTOMLEFT", frame.CastBar, "BOTTOMLEFT", -21, bottomOffset)

        frame.CastBar.bbpCastUninterruptibleBorder.left:ClearAllPoints()
        frame.CastBar.bbpCastUninterruptibleBorder.left:SetPoint("TOPLEFT", frame.CastBar, "TOPLEFT", -21, topOffset-(height*0.85))
        frame.CastBar.bbpCastUninterruptibleBorder.left:SetPoint("BOTTOMLEFT", frame.CastBar, "BOTTOMLEFT", -21, bottomOffset-(height*0.85))
    end

    -- local function UpdateCastBarIconSize(self)
    --     local spellName, spellID, notInterruptible, endTime
    --     local _

    --     if UnitCastingInfo(self.unit) then
    --         spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
    --     elseif UnitChannelInfo(self.unit) then
    --         spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
    --     end
    --     if notInterruptible then
    --         self.Icon:ClearAllPoints()
    --         self.Icon:SetPoint("CENTER", frame.CastBar, "LEFT", -10.5, 1)
    --         --self.Icon:SetSize(11, 11)
    --         self.Icon:SetDrawLayer("OVERLAY", 7)
    --     end
    -- end
    -- if not frame.bbpClassicCastbarHook then
    --     frame.CastBar:HookScript("OnUpdate", function()
    --         UpdateCastBarIconSize(frame.CastBar)
    --     end)
    --     frame.bbpClassicCastbarHook = true
    -- end

    frame.CastBar:SetHeight(BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.castBarHeight or 10)

    if not frame.CastBar.eventsHooked then
        frame.CastBar.UpdateBorders = UpdateBorders
        frame.CastBar:HookScript("OnShow", UpdateBorders)
        frame.CastBar:HookScript("OnHide", UpdateBorders)
        frame.CastBar.BorderShield:HookScript("OnShow", UpdateBorders)
        frame.CastBar.BorderShield:HookScript("OnHide", UpdateBorders)
        frame.CastBar.eventsHooked = true

        hooksecurefunc(frame.CastBar.Icon, "SetPoint", function(self)
            if self.changing or self:IsForbidden() then return end
            self.changing = true
            self:ClearAllPoints()
            self:SetPoint("RIGHT", frame.CastBar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos-2, BetterBlizzPlatesDB.castBarIconYPos)
            --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
            self.changing = false
        end)
    end

    -- Set the initial visibility
    UpdateBorders()

    -- Adjust cast bar position
    if centerCastbar then
        frame.CastBar:ClearAllPoints()
        frame.CastBar:SetPoint("TOP", frame, "BOTTOM", 0, -5)
    else
        frame.CastBar:ClearAllPoints()
        frame.CastBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 17, -8)
        frame.CastBar:SetWidth(width - 25 + levelFrameAdjustment)
    end
end

local function FixLevelFramePosition(frame)
    if not frame.fixedLevelFrame then
        --local a,b,c,d,e = frame.LevelFrame:GetPoint()
        frame.LevelFrame:ClearAllPoints()
        frame.LevelFrame:SetPoint("LEFT", frame.healthBar, "RIGHT", 2, 0)
        frame.LevelFrame:SetParent(frame.healthBar)
        frame.LevelFrame.highLevelTexture:SetDrawLayer("OVERLAY")
        frame.LevelFrame.levelText:SetDrawLayer("OVERLAY")
        frame.fixedLevelFrame = true
    end
end

function BBP.UpdateCastBarText(self)
    local unit = self.unit
    local spellName
    if UnitChannelInfo(unit) then
        spellName = UnitChannelInfo(unit)
    elseif UnitCastingInfo(unit) then
        spellName = UnitCastingInfo(unit)
    else
        spellName = ""
    end
    self.castText:SetText(spellName)
    self.castText:SetWidth(self:GetWidth() - 10)
end

local function ClassicCastbarText(self)
    if not self.noInterruptColor and not self.delayedInterruptColor then
        local spellName, spellID, notInterruptible, endTime
        local _

        if UnitCastingInfo(self.unit) then
            spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
        elseif UnitChannelInfo(self.unit) then
            spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
        end

        if spellName then
            self.castText:SetText(spellName)
        end
    end
end

local function CreateBetterCastbarText(frame)
    if not frame.CastBar.castText then
        frame.CastBar.castText = frame.CastBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.CastBar.castText:SetText("")
        frame.CastBar.castText:SetDrawLayer("OVERLAY", 7)
        frame.CastBar.castText:SetPoint("CENTER", frame.CastBar, "CENTER", 0, BetterBlizzPlatesDB.classicNameplates and 0.5 or 0)
        BBP.SetFontBasedOnOption(frame.CastBar.castText, BetterBlizzPlatesDB.classicNameplates and 8 or 10, "THINOUTLINE")
        frame.CastBar.castText:SetTextColor(1, 1, 1)
        frame.CastBar.castText:SetJustifyH("CENTER") -- Horizontal alignment
        frame.CastBar.castText:SetJustifyV("MIDDLE") -- Vertical alignment
        frame.CastBar.castText:SetWordWrap(false) -- Disable word wrap
        frame.CastBar.castText:SetMaxLines(1) -- Only one line
        -- Set up scripts to update cast text

        frame.CastBar:HookScript("OnShow", function(self)
            BBP.UpdateCastBarText(self)
        end)

        if BetterBlizzPlatesDB.classicNameplates then
            frame.CastBar:HookScript("OnUpdate", function(self)
                ClassicCastbarText(self)
            end)
        end

        -- frame.CastBar:HookScript("OnHide", function(self)
        --     --self.castText:SetText("")
        -- end)
    end
    --frame.CastBar.castText:SetWidth(frame.CastBar:GetWidth() - 20)

    BBP.SetFontBasedOnOption(frame.CastBar.castText, BetterBlizzPlatesDB.classicNameplates and 8 or 10, "THINOUTLINE")
    BBP.UpdateCastBarText(frame.CastBar)
end

-- local function AdjustRetailCastbar(frame)
--     local width = frame.healthBar:GetWidth() + 25
--     local levelFrameAdjustment = BetterBlizzPlatesDB.hideLevelFrame and -17 or 0
--         frame.CastBar:ClearAllPoints()
--         frame.CastBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 17, -5)
--         frame.CastBar:SetWidth(width - 25 + levelFrameAdjustment)
-- end

local function CreateBetterRetailCastbar(frame)
    frame.CastBar:ClearAllPoints()
    frame.CastBar.Border:SetAlpha(0)
    frame.CastBar:SetFrameStrata("HIGH")

    frame.CastBar:SetHeight(BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.castBarHeight or 16)
    frame.CastBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2)
    frame.CastBar:SetPoint("TOPRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, -2)

    frame.CastBar.Icon:ClearAllPoints()
    --frame.CastBar.Icon:SetSize(10,10)
    frame.CastBar.Icon:SetPoint("CENTER", frame.CastBar, "LEFT", 5, 0)
    frame.CastBar.Icon:SetDrawLayer("OVERLAY", 7)
    --frame.CastBar:SetWidth(width - 26)

    -- Hook the OnUpdate script to ensure the size is set correctly
    local function UpdateCastBarIconSize(self)
        self.Icon:ClearAllPoints()
        self.Icon:SetPoint("CENTER", frame.CastBar, "LEFT", 0, 0)
        self.Icon:SetSize(13, 13)
        self.Icon:SetDrawLayer("OVERLAY", 7)
    end

    -- Create the background texture
    if not frame.CastBar.Background then
        frame.CastBar.Background = frame.CastBar:CreateTexture(nil, "BORDER")
        frame.CastBar.Background:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Background")
        -- frame.CastBar.Background:SetPoint("TOPLEFT", frame.CastBar, "TOPLEFT", -11, 1)
        -- frame.CastBar.Background:SetPoint("BOTTOMRIGHT", frame.CastBar, "BOTTOMRIGHT", 11, -1)
        frame.CastBar.Background:SetAllPoints()
        frame.CastBar.Background:SetDrawLayer("BORDER", -7)
    end

    if not frame.CastBar.bbpSpark then
        frame.CastBar.bbpSpark = frame.CastBar:CreateTexture(nil, "BORDER")
        frame.CastBar.bbpSpark:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Pip")
        frame.CastBar.bbpSpark:SetSize(16,16)
        --frame.CastBar.bbpSpark:SetParent(frame.CastBar.Spark)
        frame.CastBar.bbpSpark:SetPoint("CENTER", frame.CastBar.Spark, "CENTER", 0, 0)
        frame.CastBar.bbpSpark:SetDrawLayer("BORDER", 1)
        frame.CastBar.Spark:SetAlpha(0)
        -- frame.CastBar.bbpSpark:SetPoint("TOPLEFT", frame.CastBar, "TOPLEFT", -12, 2)
        -- frame.CastBar.bbpSpark:SetPoint("BOTTOMRIGHT", frame.CastBar, "BOTTOMRIGHT", 12, -2)
        -- frame.CastBar.Spark = frame.CastBar.bbpSpark

        --frame.CastBar.Spark
    end

    frame.CastBar.bbpSpark:ClearAllPoints()
    frame.CastBar.bbpSpark:SetPoint("CENTER", frame.CastBar.Spark, "CENTER", 0, 0)

    if not frame.CastBar.bbpBorderShield then
        frame.CastBar.BorderShield:SetAlpha(0)
        frame.CastBar.bbpBorderShield = frame.CastBar:CreateTexture(nil, "BORDER")
        if not BetterBlizzPlatesDB.hideCastbarBorderShield then
            frame.CastBar.bbpBorderShield:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Shield")
        end
        frame.CastBar.bbpBorderShield:SetSize(31,31)
        frame.CastBar.bbpBorderShield:SetPoint("CENTER", frame.CastBar.Icon, "CENTER", 0, -1)
        frame.CastBar.bbpBorderShield:SetDrawLayer("BORDER", 1)
    end

    -- -- Create the frame texture
    -- if not frame.CastBar.Frame then
    --     frame.CastBar.Frame = frame.CastBar:CreateTexture(nil, "ARTWORK")
    --     frame.CastBar.Frame:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Frame")
    --     frame.CastBar.Frame:SetPoint("TOPLEFT", frame.CastBar, "TOPLEFT", -12, 2)
    --     frame.CastBar.Frame:SetPoint("BOTTOMRIGHT", frame.CastBar, "BOTTOMRIGHT", 12, -2)
    -- end

    -- Update the filling texture based on cast type
    local function UpdateCastBarTextures(self)
        local texture
        if self.BorderShield:IsShown() then
            texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Uninterruptable"
            self.bbpBorderShield:Show()
        elseif self.channeling then
            texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
            self.bbpBorderShield:Hide()
        elseif self.interruptedColor then
            texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
            self.bbpBorderShield:Hide()
        else
            texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
            self.bbpBorderShield:Hide()
        end

        if not self.noInterruptColor and not self.delayedInterruptColor then
            --self:SetStatusBarColor(1,1,1)
            local spellName, spellID, notInterruptible, endTime
            local _
            local channel = false

            if UnitCastingInfo(self.unit) then
                spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
            elseif UnitChannelInfo(self.unit) then
                spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
                channel = true
            end

            if spellName then
                self.castText:SetText(spellName)
                if not self.notInterruptible then
                    if channel then
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                    else
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                    end
                end
            elseif not self.interruptedColor then
                --self.castText:SetText("")
                if not self.notInterruptible then
                    if channel then
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                    else
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                    end
                end
            end
        end

        if self.castText:GetText() == "Interrupted" then
            texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
        end

        self:SetStatusBarTexture(texture)
        --self:SetTexture(texture)
        self:GetStatusBarTexture():SetDrawLayer("BORDER", 0)  -- Ensure the filling is between frame and background
    end

    if not BetterBlizzPlatesDB.useCustomCastbarTexture and not BetterBlizzPlatesDB.castBarRecolor then
        frame.CastBar:SetStatusBarColor(1,1,1)
        UpdateCastBarTextures(frame.CastBar)
    end

    -- if not frame.CastBar.castText then
    --     frame.CastBar.castText = frame.CastBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    --     frame.CastBar.castText:SetText("")
    --     frame.CastBar.castText:SetDrawLayer("OVERLAY", 7)
    --     frame.CastBar.castText:SetPoint("CENTER", frame.CastBar, "CENTER", 0, 0)
    --     BBP.SetFontBasedOnOption(frame.CastBar.castText, 10, "THINOUTLINE")
    --     frame.CastBar.castText:SetTextColor(1, 1, 1)
    --     frame.CastBar.castText:SetJustifyH("CENTER") -- Horizontal alignment
    --     frame.CastBar.castText:SetJustifyV("MIDDLE") -- Vertical alignment
    --     frame.CastBar.castText:SetWordWrap(false) -- Disable word wrap
    --     frame.CastBar.castText:SetMaxLines(1) -- Only one line
    -- end
    -- --frame.CastBar.castText:SetWidth(frame.CastBar:GetWidth() - 20)

    -- -- Set up scripts to update cast text
    -- local function BBP.UpdateCastBarText(self)
    --     local unit = self.unit
    --     local spellName
    --     if UnitChannelInfo(unit) then
    --         spellName = UnitChannelInfo(unit)
    --     elseif UnitCastingInfo(unit) then
    --         spellName = UnitCastingInfo(unit)
    --     else
    --         spellName = ""
    --     end
    --     self.castText:SetText(spellName)
    --     self.castText:SetWidth(frame.CastBar:GetWidth() - 20)
    -- end

    -- frame.CastBar:HookScript("OnShow", function(self)
    --     BBP.UpdateCastBarText(self)
    -- end)

    -- frame.CastBar:HookScript("OnHide", function(self)
    --     self.castText:SetText("")
    -- end)

    -- BBP.UpdateCastBarText(frame.CastBar)

    local children = {frame.CastBar:GetRegions()}
    for _, region in ipairs(children) do
        if region:IsObjectType("Texture") and region:GetDrawLayer() == "BACKGROUND" then
            region:SetAlpha(0)
        end
    end

    local function UpdateSpark()
        local min, max = frame.CastBar:GetMinMaxValues()
        local value = frame.CastBar:GetValue()
        local width = frame.CastBar:GetWidth()
        local sparkPosition = (value - min) / (max - min) * width
        frame.CastBar.bbpSpark:SetPoint("CENTER", frame.CastBar, "LEFT", sparkPosition, 0)
    end

    if not frame.bbpRetailCastbarHook then
        if BetterBlizzPlatesDB.castBarRecolor or BetterBlizzPlatesDB.useCustomCastbarTexture then
            frame.CastBar:HookScript("OnUpdate", function(self)
                --UpdateCastBarIconSize(frame.CastBar)
                --UpdateCastBarTextures(self)
                UpdateSpark()
            end)
        else
            frame.CastBar:HookScript("OnUpdate", function(self)
                --UpdateCastBarIconSize(frame.CastBar)
                UpdateCastBarTextures(self)
                UpdateSpark()
            end)
        end

        -- frame.CastBar:HookScript("OnEvent", function(self, event, ...)
        --     -- --UpdateCastBarIconSize(frame.CastBar)
        --     -- UpdateCastBarTextures(self)
        --     -- UpdateSpark()
        --     if event == "UNIT_SPELLCAST_INTERRUPTED" then
        --         print("kicked")
        --     end
        -- end)

        hooksecurefunc(frame.CastBar.Icon, "SetPoint", function(self)
            if self.changing or self:IsForbidden() then return end
            self.changing = true
            self:ClearAllPoints()
            self:SetPoint("CENTER", frame.CastBar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
            --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
            self.changing = false
        end)
        frame.bbpRetailCastbarHook = true
    end
end

--#############################################################
--#############################################################
--#############################################################
--#############################################################
--#############################################################

local function CreateBorder(frame, r, g, b, a)
    local border = frame:CreateTexture(nil, "OVERLAY", nil, -1)
    border:SetColorTexture(r, g, b, a)
    border:SetIgnoreParentScale(true)
    return border
end

local function SetupBorderOnFrame(frame)
    if frame.border then
        frame.border:Hide()
    end
    if frame.newBorder then return end
    -- Create borders
    local borderTop = CreateBorder(frame, 0, 0, 0, 1)  -- Black color
    local borderBottom = CreateBorder(frame, 0, 0, 0, 1)
    local borderLeft = CreateBorder(frame, 0, 0, 0, 1)
    local borderRight = CreateBorder(frame, 0, 0, 0, 1)

    -- Store borders in a table
    frame.borders = {borderTop, borderBottom, borderLeft, borderRight}

    -- Initial border thickness
    local borderThickness = 1
    local minPixels = 1

    -- Define the SizeBorders function to use PixelUtil
    local function SizeBorders(borderThickness)
        PixelUtil.SetHeight(borderTop, borderThickness, minPixels)
        PixelUtil.SetHeight(borderBottom, borderThickness, minPixels)
        PixelUtil.SetWidth(borderLeft, borderThickness, minPixels)
        PixelUtil.SetWidth(borderRight, borderThickness, minPixels)

        -- Adjust border positions to grow outward
        borderTop:ClearAllPoints()
        PixelUtil.SetPoint(borderTop, "BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
        PixelUtil.SetPoint(borderTop, "BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)

        borderBottom:ClearAllPoints()
        PixelUtil.SetPoint(borderBottom, "TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
        PixelUtil.SetPoint(borderBottom, "TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        borderLeft:ClearAllPoints()
        PixelUtil.SetPoint(borderLeft, "TOPLEFT", frame, "TOPLEFT", -borderThickness, borderThickness)
        PixelUtil.SetPoint(borderLeft, "BOTTOMLEFT", frame, "BOTTOMLEFT", -borderThickness, -borderThickness)

        borderRight:ClearAllPoints()
        PixelUtil.SetPoint(borderRight, "TOPRIGHT", frame, "TOPRIGHT", borderThickness, borderThickness)
        PixelUtil.SetPoint(borderRight, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", borderThickness, -borderThickness)
    end

    SizeBorders(borderThickness)

    -- Define method to set border color
    function frame:SetBorderColor(r, g, b, a)
        for _, border in ipairs(self.borders) do
            border:SetColorTexture(r, g, b, a)
        end
    end

    -- Define method to set border size
    function frame:SetBorderSize(size)
        SizeBorders(size)
    end

    frame.newBorder = true
end



local function SetNameplateHeight(frame, height)
    frame:SetHeight(height)
end

local function CreateRetailNameplateLook(frame)
    frame.healthBar:ClearPoint("RIGHT")
    frame.healthBar:ClearPoint("LEFT")
    frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", 0,0)
    frame.healthBar:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.LevelFrame:Hide()
    frame.LevelFrame:SetAlpha(0)
    SetupBorderOnFrame(frame.healthBar)
end

local function HideLevelFrameOnClassicNameplate(frame)
    frame.healthBar:ClearPoint("RIGHT")
    frame.healthBar:ClearPoint("LEFT")
    frame.healthBar:SetPoint("LEFT", frame, "LEFT", 4, 0)
    local xPos = BetterBlizzPlatesDB.hideLevelFrame and -4 or -21
    frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", xPos,0)
    frame.LevelFrame:Hide()
    frame.LevelFrame:SetAlpha(0)
end



--#############################################################
--#############################################################
--#############################################################
--#############################################################
--#############################################################


-- can run before a nameplate is fetched so needs updated info
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if not frame.unit or not frame.unit:find("nameplate") then return end
    if not BBP.IsLegalNameplateUnit(frame) then return end

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    --local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    if not info then return end

    if not config.updateHealthColorInitialized or BBP.needsUpdate then
        config.castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
        config.classColorPersonalNameplate = BetterBlizzPlatesDB.classColorPersonalNameplate
        config.targetIndicatorColorNameplate = BetterBlizzPlatesDB.targetIndicatorColorNameplate
        config.enemyHealthBarColorNpcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly
        config.enemyNeutralHealthBarColorRGB = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 0, 0}
        config.enemyHealthBarColorRGB = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
        config.friendlyHealthBarColorRGB = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
        config.focusTargetIndicatorColorNameplate = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate
        config.focusTargetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB
        config.focusTargetIndicator = BetterBlizzPlatesDB.focusTargetIndicator
        config.targetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        config.totemIndicatorColorHealthBar = BetterBlizzPlatesDB.totemIndicatorColorHealthBar
        config.totemIndicatorColorName = BetterBlizzPlatesDB.totemIndicatorColorName
        config.colorNPC = BetterBlizzPlatesDB.colorNPC

        config.updateHealthColorInitialized = true
    end

    if info.isSelf then
        if config.classColorPersonalNameplate then
            frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
        end
    end

    if config.friendlyHealthBarColor or config.enemyHealthBarColor then
        ColorNameplateByReaction(frame)
    end

    if ( BetterBlizzPlatesDB.enemyColorThreat and (BBP.isInPvE or (BetterBlizzPlatesDB.threatColorAlwaysOn and not BBP.isInPvP)) ) then
        BBP.ColorThreat(frame)
    end

    if config.colorNPC then--and config.npcHealthbarColor then --bodify need npc check here since it can run before np added
        --frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
        BBP.ColorNpcHealthbar(frame)
    end

    if (config.focusTargetIndicator and config.focusTargetIndicatorColorNameplate and info.isFocus) or config.focusTargetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.focusTargetIndicatorColorNameplateRGB))--mby replace info.isFocus with unit call bodify
        --BBP.FocusTargetIndicator(frame)
    end

    if config.auraColor and config.auraColorRGB then
        BBP.AuraColor(frame)
        --frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b)
    end

    if (config.targetIndicator and config.targetIndicatorColorNameplate and info.isTarget) or config.targetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.targetIndicatorColorNameplateRGB))
    end

    if config.castBarEmphasisHealthbarColor then
        if frame.emphasizedCast then
            local isCasting = UnitCastingInfo(frame.unit) or UnitChannelInfo(frame.unit)
            if isCasting then
                frame.healthBar:SetStatusBarColor(frame.emphasizedCast.entryColors.text.r, frame.emphasizedCast.entryColors.text.g, frame.emphasizedCast.entryColors.text.b)
            end
        end
    end

    if config.totemIndicator then
        local totemColor = config.totemColorRGB or config.randomTotemColor
        if totemColor then
            local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)
            local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID]
            if npcData or config.randomTotemColor then
                if config.totemIndicatorEnemyOnly then
                    if not info.isFriend then
                        if config.totemIndicatorColorHealthBar then
                            frame.healthBar:SetStatusBarColor(unpack(totemColor))
                        end
                        -- if config.totemIndicatorColorName then
                        --     frame.name:SetVertexColor(unpack(totemColor))
                        --     if frame.fakeName then
                        --         frame.name:SetVertexColor(unpack(totemColor))
                        --     end
                        -- end
                    end
                else
                    if config.totemIndicatorColorHealthBar then
                        frame.healthBar:SetStatusBarColor(unpack(totemColor))
                    end
                    -- if config.totemIndicatorColorName then
                    --     frame.name:SetVertexColor(unpack(totemColor))
                    --     if frame.fakeName then
                    --         frame.name:SetVertexColor(unpack(totemColor))
                    --     end
                    -- end
                end
            else
                config.totemColorRGB = nil
            end
        end
    end
end)


function BBP.CompactUnitFrame_UpdateHealthColor(frame, exitLoop)
	if frame.UpdateHealthColorOverride and frame:UpdateHealthColorOverride() then
		return;
	end

    if not frame or not frame.unit then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    --local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    if not info then return end

    if not config.updateHealthColorInitialized or BBP.needsUpdate then
        config.castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
        config.classColorPersonalNameplate = BetterBlizzPlatesDB.classColorPersonalNameplate
        config.targetIndicatorColorNameplate = BetterBlizzPlatesDB.targetIndicatorColorNameplate
        config.enemyHealthBarColorNpcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly
        config.enemyNeutralHealthBarColorRGB = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 1, 0}
        config.enemyHealthBarColorRGB = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
        config.friendlyHealthBarColorRGB = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
        config.focusTargetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB
        config.focusTargetIndicator = BetterBlizzPlatesDB.focusTargetIndicator
        config.targetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        config.colorNPC = BetterBlizzPlatesDB.colorNPC

        config.updateHealthColorInitialized = true
    end

	local r, g, b;

	local unitIsConnected = UnitIsConnected(frame.unit);
	local unitIsDead = unitIsConnected and UnitIsDead(frame.unit);
	local unitIsPlayer = UnitIsPlayer(frame.unit) or UnitIsPlayer(frame.displayedUnit);

	if ( not unitIsConnected or (unitIsDead and not unitIsPlayer) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		if ( frame.optionTable.healthBarColorOverride ) then
			local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
		else
			--Try to color it by class.
			local localizedClass, englishClass = UnitClass(frame.unit);
			local classColor = RAID_CLASS_COLORS[englishClass];
			if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit)) and classColor and frame.optionTable.useClassColors ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = 0.9, 0.9, 0.9;
			elseif ( frame.optionTable.colorHealthBySelection ) then
				-- Use color based on the type of unit (neutral, etc.)
				--[[if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsPlayerAttacking(frame.displayedUnit)) then
					r, g, b = 1.0, 0.0, 0.0;
				else]]
					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors);
				--end
			elseif ( UnitIsFriend("player", frame.unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	end
	local oldR, oldG, oldB = frame.healthBar:GetStatusBarColor();
	if ( r ~= oldR or g ~= oldG or b ~= oldB ) then
		frame.healthBar:SetStatusBarColor(r, g, b);

		if (frame.optionTable.colorHealthWithExtendedColors) then
			frame.selectionHighlight:SetVertexColor(r, g, b);
		else
			frame.selectionHighlight:SetVertexColor(1, 1, 1);
		end
	end

	-- Update whether healthbar is hidden due to being dead - only applies to non-player nameplates
	-- local hideHealthBecauseDead = unitIsDead and not unitIsPlayer;
	-- CompactUnitFrame_SetHideHealth(frame, hideHealthBecauseDead, HEALTH_BAR_HIDE_REASON_UNIT_DEAD);

    if config.friendlyHealthBarColor or config.enemyHealthBarColor then
        ColorNameplateByReaction(frame)
    end

    if ( BetterBlizzPlatesDB.enemyColorThreat and (BBP.isInPvE or (BetterBlizzPlatesDB.threatColorAlwaysOn and not BBP.isInPvP)) ) then
        BBP.ColorThreat(frame)
    end

    if config.colorNPC and config.npcHealthbarColor then
        frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
    end

    if (config.focusTargetIndicator and config.focusTargetIndicatorColorNameplate and info.isFocus) or config.focusTargetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.focusTargetIndicatorColorNameplateRGB))
        --BBP.FocusTargetIndicator(frame)
    end

    if config.auraColor and config.auraColorRGB then
        frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b)
    end

    if (config.targetIndicator and config.targetIndicatorColorNameplate and info.isTarget) or config.targetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.targetIndicatorColorNameplateRGB))
    end

    if config.castBarEmphasisHealthbarColor then
        if frame.emphasizedCast then
            local isCasting = UnitCastingInfo(frame.unit) or UnitChannelInfo(frame.unit)
            if isCasting then
                frame.healthBar:SetStatusBarColor(frame.emphasizedCast.entryColors.text.r, frame.emphasizedCast.entryColors.text.g, frame.emphasizedCast.entryColors.text.b)
            end
        end
    end

    if config.totemIndicator then
        local totemColor = config.totemColorRGB or config.randomTotemColor
        if totemColor then
            if config.totemIndicatorEnemyOnly then
                if not info.isFriend then
                    if config.totemIndicatorColorHealthBar then
                        frame.healthBar:SetStatusBarColor(unpack(totemColor))
                    end
                    if config.totemIndicatorColorName then
                        frame.name:SetVertexColor(unpack(totemColor))
                        if frame.fakeName then
                            frame.fakeName:SetVertexColor(unpack(totemColor))
                        end
                    end
                end
            else
                if config.totemIndicatorColorHealthBar then
                    frame.healthBar:SetStatusBarColor(unpack(totemColor))
                end
                if config.totemIndicatorColorName then
                    frame.name:SetVertexColor(unpack(totemColor))
                    if frame.fakeName then
                        frame.fakeName:SetVertexColor(unpack(totemColor))
                    end
                end
            end
        end
    end
    -- if info.isSelf then --without this self nameplate reset to green after targeting self, figure out more
    --     if config.classColorPersonalNameplate then
    --         frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
    --     end
    -- end
end

-- -- Copy of blizzards update health color function
-- function BBP.CompactUnitFrame_UpdateHealthColor(frame, exitLoop)
--     if not frame or not frame.unit then return end
--     local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
--     --local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
--     frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
--     local info = frame.BetterBlizzPlates.unitInfo
--     if not info then return end

--     if not config.updateHealthColorInitialized or BBP.needsUpdate then
--         config.castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
--         config.classColorPersonalNameplate = BetterBlizzPlatesDB.classColorPersonalNameplate
--         config.targetIndicatorColorNameplate = BetterBlizzPlatesDB.targetIndicatorColorNameplate
--         config.enemyHealthBarColorNpcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly
--         config.enemyNeutralHealthBarColorRGB = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 1, 0}
--         config.enemyHealthBarColorRGB = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
--         config.friendlyHealthBarColorRGB = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
--         config.focusTargetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB
--         config.focusTargetIndicator = BetterBlizzPlatesDB.focusTargetIndicator
--         config.targetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
--         config.colorNPC = BetterBlizzPlatesDB.colorNPC

--         config.updateHealthColorInitialized = true
--     end

-- 	local r, g, b;
-- 	local unitIsConnected = UnitIsConnected(frame.unit);
-- 	local unitIsDead = unitIsConnected and UnitIsDead(frame.unit);
-- 	local unitIsPlayer = UnitIsPlayer(frame.unit) or UnitIsPlayer(frame.displayedUnit);

--     if info.isSelf then
--         if config.classColorPersonalNameplate then
--             frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
--         --else return end
--         end
--     end

-- 	if ( not unitIsConnected or (unitIsDead and not unitIsPlayer) ) then
-- 		--Color it gray
-- 		r, g, b = 0.5, 0.5, 0.5;
-- 	else
-- 		if ( frame.optionTable.healthBarColorOverride ) then
-- 			local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
-- 			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
-- 		else
-- 			--Try to color it by class.
-- 			local localizedClass, englishClass = UnitClass(frame.unit);
-- 			local classColor = RAID_CLASS_COLORS[englishClass];
-- 			--debug
-- 			--classColor = RAID_CLASS_COLORS["PRIEST"];
-- 			--local useClassColors = CompactUnitFrame_GetOptionUseClassColors(frame, frame.optionTable);
-- 			--if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) or UnitTreatAsPlayerForDisplay(frame.unit)) and classColor and useClassColors ) then
--             if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit)) or classColor and frame.optionTable.useClassColors ) then
-- 				-- Use class colors for players if class color option is turned on
-- 				r, g, b = classColor.r, classColor.g, classColor.b;
-- 			elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
-- 				-- Use grey if not a player and can't get tap on unit
-- 				r, g, b = 0.9, 0.9, 0.9;
-- 			elseif ( frame.optionTable.colorHealthBySelection ) then
-- 				-- Use color based on the type of unit (neutral, etc.)
-- 				if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) and not UnitIsFriend("player", frame.unit) ) then
-- 					r, g, b = 1.0, 0.0, 0.0;
-- 				elseif ( UnitIsPlayer(frame.displayedUnit) and UnitIsFriend("player", frame.displayedUnit) ) then
-- 					-- We don't want to use the selection color for friendly player nameplates because
-- 					-- it doesn't show player health clearly enough.
-- 					r, g, b = 0.667, 0.667, 1.0;
-- 				else
-- 					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors);
-- 				end
-- 			elseif ( UnitIsFriend("player", frame.unit) ) then
-- 				r, g, b = 0.0, 1.0, 0.0;
-- 			else
-- 				r, g, b = 1.0, 0.0, 0.0;
-- 			end
-- 		end
-- 	end

-- 	local oldR, oldG, oldB = frame.healthBar:GetStatusBarColor();
-- 	if ( r ~= oldR or g ~= oldG or b ~= oldB ) then
-- 		frame.healthBar:SetStatusBarColor(r, g, b);

-- 		if (frame.optionTable.colorHealthWithExtendedColors) then
-- 			frame.selectionHighlight:SetVertexColor(r, g, b);
-- 		else
-- 			frame.selectionHighlight:SetVertexColor(1, 1, 1);
-- 		end
-- 	end

--     if config.friendlyHealthBarColor or config.enemyHealthBarColor then
--         ColorNameplateByReaction(frame)
--     end

--     if config.colorNPC and config.npcHealthbarColor then
--         frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
--     end

--     if (config.focusTargetIndicator and config.focusTargetIndicatorColorNameplate and info.isFocus) or config.focusTargetIndicatorTestMode then
--         frame.healthBar:SetStatusBarColor(unpack(config.focusTargetIndicatorColorNameplateRGB))
--         --BBP.FocusTargetIndicator(frame)
--     end

--     if config.auraColor and config.auraColorRGB then
--         frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b)
--     end

--     if (config.targetIndicator and config.targetIndicatorColorNameplate and info.isTarget) or config.targetIndicatorTestMode then
--         frame.healthBar:SetStatusBarColor(unpack(config.targetIndicatorColorNameplateRGB))
--     end

--     if config.castBarEmphasisHealthbarColor then
--         if frame.emphasizedCast then
--             local isCasting = UnitCastingInfo(frame.unit) or UnitChannelInfo(frame.unit)
--             if isCasting then
--                 frame.healthBar:SetStatusBarColor(frame.emphasizedCast.entryColors.text.r, frame.emphasizedCast.entryColors.text.g, frame.emphasizedCast.entryColors.text.b)
--             end
--         end
--     end

--     if config.totemIndicator then
--         local totemColor = config.totemColorRGB or config.randomTotemColor
--         if totemColor then
--             if config.totemIndicatorEnemyOnly then
--                 if not info.isFriend then
--                     if config.totemIndicatorColorHealthBar then
--                         frame.healthBar:SetStatusBarColor(unpack(totemColor))
--                     end
--                     if config.totemIndicatorColorName then
--                         frame.name:SetVertexColor(unpack(totemColor))
--                         if frame.fakeName then
--                             frame.fakeName:SetVertexColor(unpack(totemColor))
--                         end
--                     end
--                 end
--             else
--                 if config.totemIndicatorColorHealthBar then
--                     frame.healthBar:SetStatusBarColor(unpack(totemColor))
--                 end
--                 if config.totemIndicatorColorName then
--                     frame.name:SetVertexColor(unpack(totemColor))
--                     if frame.fakeName then
--                         frame.fakeName:SetVertexColor(unpack(totemColor))
--                     end
--                 end
--             end
--         end
--     end
--     if info.isSelf then --without this self nameplate reset to green after targeting self, figure out more
--         if config.classColorPersonalNameplate then
--             frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
--         end
--     end
-- end









function BBP.OnUnitUpdate(unitId, unitInfo, allUnitsInfo)
    local nameplate, frame = BBP.GetSafeNameplate(unitId)
    if frame then
        local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
        local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)
        if not info then return end

        if (config.classIndicator or config.partyPointer) and not info.isSelf then
            if config.classIndicator then
                BBP.ClassIndicator(frame, unitInfo.specId)
            end
            if config.partyPointer then
                BBP.PartyPointer(frame)
            end
        end
        if config.showGuildNames and config.friendlyHideHealthBar then
            if not config.guildNameColor then
                config.guildNameColor = BetterBlizzPlatesDB.guildNameColor
                config.guildNameColorRGB = BetterBlizzPlatesDB.guildNameColorRGB
                config.guildNameScale = BetterBlizzPlatesDB.guildNameScale
            end
            if not frame.guildName then
                frame.guildName = frame:CreateFontString(nil, "BACKGROUND")
                local font, size, outline = frame.name:GetFont()
                frame.guildName:SetFont(font, 14, outline)
            end

            local guildName, guildRankName, guildRankIndex = GetGuildInfo(unitId)
            if guildName then
                frame.guildName:SetText("<"..guildName..">")
                if config.guildNameColor then
                    frame.guildName:SetTextColor(unpack(config.guildNameColorRGB))
                else
                    frame.guildName:SetTextColor(frame.name:GetTextColor())
                end
                frame.guildName:SetPoint("TOP", frame.fakeName or frame.name, "BOTTOM", 0, 0)
                frame.guildName:SetScale(config.guildNameScale or 1)
            else
                frame.guildName:SetText("")
            end
        end
    end
end
--registering the callback:
-- local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")
-- openRaidLib.RegisterCallback(BBP, "UnitInfoUpdate", "OnUnitUpdate")



--################################################################################################
-- Apply raidmarker change
function BBP.ApplyRaidmarkerChanges(frame)
    local config = frame.BetterBlizzPlates.config

    if config.raidmarkIndicator then
        if not config.raidmarkInitialized or BBP.needsUpdate then
            config.raidmarkIndicatorAnchor = BetterBlizzPlatesDB.raidmarkIndicatorAnchor or "TOP"
            config.raidmarkIndicatorXPos = BetterBlizzPlatesDB.raidmarkIndicatorXPos
            config.raidmarkIndicatorYPos = BetterBlizzPlatesDB.raidmarkIndicatorYPos
            config.raidmarkIndicatorScale = BetterBlizzPlatesDB.raidmarkIndicatorScale
            config.raidmarkInitialized = true
        end

        local shouldMove = not BetterBlizzPlatesDB.raidmarkerPvPOnly or BBP.isInPvP

        if shouldMove then
            if config.raidmarkIndicatorAnchor == "TOP" then
                frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.fakeName or frame.name, config.raidmarkIndicatorAnchor, config.raidmarkIndicatorXPos, config.raidmarkIndicatorYPos)
            else
                local hiddenHealthbarOffset = (config.friendlyHideHealthBar and config.raidmarkIndicatorAnchor == "BOTTOM" and frame.healthBar:GetAlpha() == 0) and frame.healthBar:GetHeight() + 10 or 0
                frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.healthBar, config.raidmarkIndicatorAnchor, config.raidmarkIndicatorXPos, config.raidmarkIndicatorYPos + hiddenHealthbarOffset)
            end
            frame.RaidTargetFrame.RaidTargetIcon:SetScale(config.raidmarkIndicatorScale or 1)
            frame.RaidTargetFrame.RaidTargetIcon:SetSize(22, 22)
            frame.RaidTargetFrame:SetFrameLevel(frame:GetFrameLevel() - 1)
        else
            frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
            frame.RaidTargetFrame.RaidTargetIcon:SetScale(1)
            frame.RaidTargetFrame.RaidTargetIcon:SetSize(22, 22)
            frame.RaidTargetFrame.RaidTargetIcon:SetPoint("RIGHT", frame.healthBar, "LEFT", -15, 0)
        end
    elseif BBP.needsUpdate then
        frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
        frame.RaidTargetFrame.RaidTargetIcon:SetScale(1)
        frame.RaidTargetFrame.RaidTargetIcon:SetSize(22, 22)
        frame.RaidTargetFrame.RaidTargetIcon:SetPoint("RIGHT", frame.healthBar, "LEFT", -15, 0)
    end
end

function BBP.HideRaidmarker(frame)
    local config = frame.BetterBlizzPlates.config
    frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(config.hideRaidmarkIndicator and 0 or 1)
end

-- Change raidmarker
function BBP.ChangeRaidmarker()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        BBP.ApplyRaidmarkerChanges(frame)
    end
end

function BBP.RefUnitAuraTotally(frame)
    local unit = frame.unit
    BBP.ProcessAurasForNameplate(frame, unit)
end

local auraModuleIsOn = false
function BBP.RunAuraModule()
    if not auraModuleIsOn  then
        local nameplateFrame = CreateFrame("Frame")
        nameplateFrame:RegisterEvent("UNIT_AURA")
        nameplateFrame:SetScript("OnEvent", function(self, event, ...)
            local unit, unitAuraUpdateInfo = ...
            if unit:find("nameplate") then
                local nameplate, frame = BBP.GetSafeNameplate(unit)
                if frame then
                    BBP.ProcessAurasForNameplate(frame, unit)
                end
            end
        end)
        auraModuleIsOn = true
    end
end

local function ChangeHealthbarBorderSize(frame)
    -- frame.healthBar:SetBorderSize(size)
--     nameplateBorderSize
-- nameplateTargetBorderSize
end


function BBP.ColorNameplateBorder(frame)
    local border = BetterBlizzPlatesDB.classicNameplates and frame.BetterBlizzPlates.bbpBorder or frame.healthBar
    border:SetBorderColor(1,1,1)
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    if info.isSelf then return end

    if not config.nameplateBorderInitialized or BBP.needsUpdate then
        config.npBorderTargetColor = BetterBlizzPlatesDB.npBorderTargetColor
        config.npBorderFriendFoeColor = BetterBlizzPlatesDB.npBorderFriendFoeColor
        config.npBorderClassColor = BetterBlizzPlatesDB.npBorderClassColor

        config.npBorderTargetColorRGB = BetterBlizzPlatesDB.npBorderTargetColorRGB
        config.npBorderEnemyColorRGB = BetterBlizzPlatesDB.npBorderEnemyColorRGB
        config.npBorderFriendlyColorRGB = BetterBlizzPlatesDB.npBorderFriendlyColorRGB
        config.npBorderNeutralColorRGB = BetterBlizzPlatesDB.npBorderNeutralColorRGB
        config.npBorderNpcColorRGB = BetterBlizzPlatesDB.npBorderNpcColorRGB
        config.npBorderNonTargetColorRGB = BetterBlizzPlatesDB.npBorderNonTargetColorRGB

        config.nameplateBorderInitialized = true
    end

    if info.isTarget and config.npBorderTargetColor then
        border:SetBorderColor(unpack(config.npBorderTargetColorRGB))
    else
        --non target
        if config.npBorderFriendFoeColor then
            if info.isEnemy then
                border:SetBorderColor(unpack(config.npBorderEnemyColorRGB))
            elseif info.isNeutral then
                border:SetBorderColor(unpack(config.npBorderNeutralColorRGB))
            elseif info.isFriend then
                border:SetBorderColor(unpack(config.npBorderFriendlyColorRGB))
            end
        end

        if config.npBorderClassColor then
            if info.isPlayer then
                local classColor = RAID_CLASS_COLORS[info.class]
                border:SetBorderColor(classColor.r, classColor.g, classColor.b)
            else
                border:SetBorderColor(unpack(config.npBorderNpcColorRGB))
            end
        end

        if not config.npBorderFriendFoeColor and not config.npBorderClassColor and config.npBorderTargetColor then
            border:SetBorderColor(unpack(config.npBorderNonTargetColorRGB))
        end
    end
end

local function HookNameplateCastbarHide(frame)
    -- if not frame.CastBar.hideHooked then
    --     -- hooksecurefunc(frame.CastBar, "Hide", function(self)
    --     --     if UnitIsUnit(frame.unit, "target") then
    --     --         BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
    --     --     end
    --     -- end)--probably remove, stays for now bodify
    --     frame.CastBar:HookScript("OnHide", function()
    --         if not frame.unit then return end
    --         if UnitIsUnit(frame.unit, "target") then
    --             BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
    --         end
    --     end)
    --     frame.CastBar.hideHooked = true
    -- end
end

local guildName = CreateFrame("Frame")
local function HideFriendlyHealthbar(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if frame.healthBar and info.isFriend then
        if BetterBlizzPlatesDB.friendlyHideHealthBar then
            if not info.isPlayer then
                local hideNpcHpBar = BetterBlizzPlatesDB.friendlyHideHealthBarNpc
                if hideNpcHpBar then
                    frame.healthBar:SetAlpha(0)
                    frame.selectionHighlight:SetAlpha(0)
                else
                    frame.healthBar:SetAlpha(1)
                    frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or 0.22)
                end
            else
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
                if config.showGuildNames then
                    if not config.guildNameInitialized then
                        config.guildNameColor = BetterBlizzPlatesDB.guildNameColor
                        config.guildNameColorRGB = BetterBlizzPlatesDB.guildNameColorRGB
                        config.guildNameScale = BetterBlizzPlatesDB.guildNameScale

                        config.guildNameInitialized = true
                    end
                    if not frame.guildName then
                        frame.guildName = guildName:CreateFontString(nil, "BACKGROUND", "SystemFont_NamePlateFixed")
                        local font, size, outline = frame.name:GetFont()
                        frame.guildName:SetFont(font, 9, outline)
                    end

                    local guildName, guildRankName, guildRankIndex = GetGuildInfo(frame.unit)
                    if guildName then
                        local font, size, outline = frame.name:GetFont()
                        frame.guildName:SetFont(font, 9, outline)
                        frame.guildName:SetText("<"..guildName..">")
                        if config.guildNameColor then
                            frame.guildName:SetTextColor(unpack(config.guildNameColorRGB))
                        else
                            local name = frame.fakeName or frame.name
                            frame.guildName:SetTextColor(name:GetTextColor())
                        end
                        frame.guildName:SetPoint("TOP", frame.fakeName or frame.name, "BOTTOM", 0, 0)
                        frame.guildName:SetScale(config.guildNameScale or 1)
                    else
                        frame.guildName:SetText("")
                    end
                end
            end
        else
            frame.healthBar:SetAlpha(1)
            frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or 0.22)
            if frame.guildName then
                frame.guildName:SetText("")
            end
        end
    else
        frame.healthBar:SetAlpha(1)
        frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or 0.22)
        if frame.guildName then
            frame.guildName:SetText("")
        end
    end
end

local function FriendIndicator(frame)
    local isFriend = isFriendlistFriend(frame.unit)
    local isBnetFriend = isUnitBNetFriend(frame.unit)
    local isGuildmate = isUnitGuildmate(frame.unit)

    if not frame.friendIndicator then
        frame.friendIndicator = frame:CreateTexture(nil, "OVERLAY")
        frame.friendIndicator:SetAtlas("groupfinder-icon-friend")
        frame.friendIndicator:SetSize(20, 21)
        frame.friendIndicator:SetPoint("RIGHT", frame.fakeName or frame.name, "LEFT", 0, 0)
    end

    if isFriend or isBnetFriend then
        frame.friendIndicator:SetDesaturated(false)
        frame.friendIndicator:SetVertexColor(1, 1, 1)
        frame.friendIndicator:Show()
    elseif isGuildmate then
        frame.friendIndicator:SetDesaturated(true)
        frame.friendIndicator:SetVertexColor(0, 1, 0)
        frame.friendIndicator:Show()
    else
        frame.friendIndicator:Hide()
    end
end


--#################################################################################################
--#################################################################################################
--#################################################################################################
-- What to do on a nameplate remvoed
local function HandleNamePlateRemoved(unit)
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if not frame then return end

    frame:SetScale(1)
    frame.name:SetAlpha(1)
    if frame.healthBar then
        frame.healthBar:SetAlpha(1)
    end
    local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
    if not hideTargetHighlight then
        frame.selectionHighlight:SetAlpha(0.22)
    end

    if frame.partyPointer then
        frame.partyPointer:Hide()
    end

    -- remove colors
    if frame.BetterBlizzPlates and frame.BetterBlizzPlates.config then
        local config = frame.BetterBlizzPlates.config
        config.totemColorRGB = nil
        config.auraColorRGB = nil
        config.npcHealthbarColor = nil
        --bodify
    end

    if frame.murlocMode then
        frame.murlocMode:Hide()
    end

    if frame.hideCastInfo then
        frame.hideCastInfo = false
    end
    -- Hide totem icons
    if frame.customIcon then
        frame.customIcon:Hide()
    end
    if frame.friendlyIndicator then
        frame.friendlyIndicator:Hide()
    end
    if frame.glowTexture then
        frame.glowTexture:Hide()
    end
    if frame.shieldTexture then
        frame.shieldTexture:Hide()
    end
    if frame.animationGroup then
        frame.animationGroup:Stop()
    end
    if frame.customCooldown then
        frame.customCooldown:Hide()
    end
    -- Hide healer icon
    if frame.healerIndicator then
        frame.healerIndicator:Hide()
    end
    -- Hide out of combat icon
    if frame.combatIndicatorSap then
        frame.combatIndicatorSap:Hide()
    end
    -- Hide out of combat icon
    if frame.combatIndicator then
        frame.combatIndicator:Hide()
    end
    -- Hide pet icon
    if frame.petIndicator then
        frame.petIndicator:Hide()
    end
    -- Hide absorb indicator
    if frame.absorbIndicator then
        frame.absorbIndicator:Hide()
    end
    -- Castbar timer
    if frame.CastTimerFrame then
        frame.CastTimerFrame:Hide()
    end
    if frame.CastTimer then
        frame.CastTimer:SetText("")
    end
    -- Target text
    if frame.TargetText then
        frame.TargetText:SetText("")
    end
    -- Arena ID
    if frame.arenaNumberText then
        frame.arenaNumberText:SetText("")
    end
    -- Arena Spec
    if frame.specNameText then
        frame.specNameText:SetText("")
    end
    -- Target indicator
    if frame.targetIndicator then
        frame.targetIndicator:Hide()
    end
    -- Execute indicator
    if frame.executeIndicator then
        frame.executeIndicator:SetText("")
    end

    if frame.classIndicator then
        frame.classIndicator:Hide()
    end

    if frame.guildName then
        frame.guildName:SetText("")
    end

    if frame.friendIndicator then
        frame.friendIndicator:Hide()
    end

    if frame.arenaNumberCircle then
        frame.arenaNumberCircle:Hide()
    end

    if frame.fakeName then
        frame.fakeName:SetText("")
    end

end



function BBP.CustomizeClassificationFrame(frame)
    --TODO:
    --frame.ClassificationFrame:SetScale()
    --frame.ClassificationFrame:SetFrameStrata("LOW") bodifycata
end

function BBP.SetupFakeName(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if info.isSelf then
        if frame.fakeName then
            frame.fakeName:SetText("")
        end
        return
    end

    if not frame.fakeName then
        frame.fakeName = frame.healthBar:CreateFontString(nil, "OVERLAY", "SystemFont_NamePlateFixed")
        frame.fakeName:SetShadowColor(frame.name:GetShadowColor())
        frame.fakeName:GetShadowOffset(frame.name:GetShadowOffset())
    end

    if not config.fakeNameXPos or BBP.needsUpdate then
        config.fakeNameXPos = BetterBlizzPlatesDB.fakeNameXPos
        config.fakeNameYPos = BetterBlizzPlatesDB.fakeNameYPos
        config.fakeNameFriendlyXPos = BetterBlizzPlatesDB.fakeNameFriendlyXPos
        config.fakeNameFriendlyYPos = BetterBlizzPlatesDB.fakeNameFriendlyYPos
        config.useFakeNameAnchorBottom = BetterBlizzPlatesDB.useFakeNameAnchorBottom
        config.fakeNameAnchor = BetterBlizzPlatesDB.fakeNameAnchor
        config.fakeNameAnchorRelative = BetterBlizzPlatesDB.fakeNameAnchorRelative
        config.fakeNameScaleWithParent = BetterBlizzPlatesDB.fakeNameScaleWithParent
    end

    if config.fakeNameScaleWithParent then
        frame.fakeName:SetIgnoreParentScale(false)
    else
        frame.fakeName:SetIgnoreParentScale(true)
    end

    frame.fakeName:ClearAllPoints()
    if info.isFriend then
        if config.useFakeNameAnchorBottom then
            frame.fakeName:SetPoint("BOTTOM", frame, "BOTTOM", config.fakeNameFriendlyXPos, config.fakeNameFriendlyYPos + 27)
        else
            frame.fakeName:SetPoint(config.fakeNameAnchor, frame.healthBar, config.fakeNameAnchorRelative, config.fakeNameFriendlyXPos, config.fakeNameFriendlyYPos + 4)
        end
    else
        frame.fakeName:SetPoint(config.fakeNameAnchor, frame.healthBar, config.fakeNameAnchorRelative, config.fakeNameXPos, config.fakeNameYPos + 4)
    end
    frame.fakeName:SetFont(frame.name:GetFont())
    if BetterBlizzPlatesDB.arenaIndicatorTestMode and not BetterBlizzPlatesDB.partyIndicatorModeTwo then
        frame.fakeName:SetText("")
    else
        frame.fakeName:SetText(frame.name:GetText() or UnitName(frame.unit))
    end
    frame.fakeName:SetShown(frame.name:IsShown())
    frame.fakeName:SetScale(frame.name:GetScale())
    local r, g, b, a = frame.name:GetVertexColor()
    frame.fakeName:SetVertexColor(r, g, b, 1)
    --  Temp solution, figure out how to show on top of healthbar while keeping frame alpha and not healthbar alpha if possible
    if frame.healthBar:GetAlpha() == 0 then
        frame.fakeName:SetIgnoreParentAlpha(true)
    else
        frame.fakeName:SetIgnoreParentAlpha(false)
    end
    --
    frame.name:SetAlpha(0)
end

local function GetNameplateHookTable(frame)
    if not frame.BetterBlizzPlates.hooks then
        frame.BetterBlizzPlates.hooks = {}
    end

    return frame.BetterBlizzPlates.hooks
end

local hiddenTooltip = CreateFrame("GameTooltip", "HiddenTooltip", nil, "GameTooltipTemplate")
hiddenTooltip:SetOwner(UIParent, "ANCHOR_NONE")

local function GetNPCTitle(unit)
    hiddenTooltip:SetUnit(unit)
    local title = nil
    local levelFound = false
    local levelPattern = "^" .. TOOLTIP_UNIT_LEVEL:gsub("%%s", ".+")

    for i = 2, hiddenTooltip:NumLines() do
        local text = _G["HiddenTooltipTextLeft" .. i]:GetText()
        if text then
            if text:find(levelPattern) then
                levelFound = true
                break
            else
                title = text
            end
        end
    end
    return levelFound and title or nil
end

local function NameplateNPCTitle(frame)
    if not frame.npcTitle then
        -- Create a FontString on the nameplate
        frame.npcTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.npcTitle:SetIgnoreParentScale(true)
        BBP.SetFontBasedOnOption(frame.npcTitle, 10, (BetterBlizzPlatesDB.useCustomFont and BetterBlizzPlatesDB.enableCustomFontOutline) and BetterBlizzPlatesDB.customFontOutline or "")
    end

    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    -- Check if the unit is an NPC
    if info.isPlayer or not info.isFriend or UnitIsOtherPlayersPet(frame.unit) then
        frame.npcTitle:Hide()
    else
        local title = GetNPCTitle(frame.unit)
        frame.npcTitle:SetText(title)
        frame.npcTitle:ClearAllPoints()
        if config.friendlyHideHealthBar then
            frame.npcTitle:SetPoint("TOP", frame.name, "BOTTOM", 0, -2)
        else
            frame.npcTitle:SetPoint("TOP", frame.healthBar, "BOTTOM", 0, -2)
        end
        if BetterBlizzPlatesDB.npcTitleColor then
            frame.npcTitle:SetTextColor(unpack(BetterBlizzPlatesDB.npcTitleColorRGB))
        else
            frame.npcTitle:SetTextColor(1, 0.85, 0)
        end
        frame.npcTitle:SetScale(BetterBlizzPlatesDB.npcTitleScale)
        frame.npcTitle:Show()
    end
end

-- What to do on a new nameplate
local function HandleNamePlateAdded(unit)
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if not frame then return end

    -- CLean up previous nameplates
    HandleNamePlateRemoved(unit)
    -- if frame.needColorReset then
        BBP.CompactUnitFrame_UpdateHealthColor(frame, exitLoop)
    --     frame.needColorReset = nil
    -- end


    -- Get settings and unitInfo
    local config = InitializeNameplateSettings(frame)
    local info = GetNameplateUnitInfo(frame, unit)
    if not info then return end
    local hooks = GetNameplateHookTable(frame)

    BBP.RangeIndicator(frame)

    if BetterBlizzPlatesDB.changeNpHpBgColor then
        frame.healthBar.background:SetVertexColor(unpack(BetterBlizzPlatesDB.npBgColorRGB))
    end

    if info.isTarget then
        BBP.previousTargetNameplate = frame
    end

    if info.isFocus then
        BBP.previousFocusNameplate = frame
    end
    BBP.CustomizeClassificationFrame(frame)
    --print(frame.ClassificationFrame:GetFrameStrata(), frame.ClassificationFrame:GetFrameLevel())

    -- if not frame.hokedHp then
    --     hooksecurefunc(frame.healthBar, "SetHeight", function(self)
    --         if self.changing or self:IsForbidden() then return end
    --         self.changing = true
    --         self:SetHeight(30)
    --         self.changing = false
    --     end)
    --     frame.hokedHp = true
    -- end
    -- Check and set settings

    -- Hide default personal BuffFrame
    -- if config.enableNameplateAuraCustomisation then
    --     frame.BuffFrame.UpdateAnchor = BBP.UpdateAnchor;
    --     frame.BuffFrame.Layout = function(self)
    --         local children = self:GetLayoutChildren()
    --         local isEnemyUnit = self.isEnemyUnit
    --         BBP.CustomBuffLayoutChildren(self, children, isEnemyUnit, unitFrame)
    --     end
    --     --frame.BuffFrame.UpdateBuffs = BBP.UpdateBuffs
    --     frame.BuffFrame.UpdateBuffs = function() return end
    --     BBP.UpdateBuffs(frame.BuffFrame, unit, nil, {}, frame)
    --     if auraModuleIsOn then
    --         BBP.HidePersonalBuffFrame()
    --     end
    -- end--and auraModuleIsOn then BBP.HidePersonalBuffFrame() end

    CreateBetterCastbarText(frame)
    if config.classicNameplates then
        FixLevelFramePosition(frame)
        CreateBetterClassicHealthbarBorder(frame)
        CreateBetterClassicCastbarBorders(frame)

        if config.hideLevelFrame then
            --frame.LevelFrame:Hide()
            HideLevelFrameOnClassicNameplate(frame)
        end
    else
        -- enter retail nameplate
        -- SetNameplateHeight(frame.healthBar, 11)
        -- SetupBorderOnFrame(frame.healthBar)
        CreateRetailNameplateLook(frame)
        CreateBetterRetailCastbar(frame)

        if info.isTarget then
            frame.healthBar:SetBorderColor(1,1,1)
        else
            frame.healthBar:SetBorderColor(0,0,0)
        end

        if BetterBlizzPlatesDB.changeNameplateBorderSize then
            if info.isTarget then
                frame.healthBar:SetBorderSize(BetterBlizzPlatesDB.nameplateTargetBorderSize)
            else
                frame.healthBar:SetBorderSize(BetterBlizzPlatesDB.nameplateBorderSize)
            end
        end
    end
    BBP.CustomizeNameOnNameplate(frame)
    BBP.ClassColorAndScaleNames(frame)

    --small nameplate
    if BetterBlizzPlatesDB.smallPetsInPvP then
        if info.isNpc and (BBP.isInArena or BBP.isInBg) then
            frame.healthBar:ClearPoint("RIGHT")
            frame.healthBar:ClearPoint("LEFT")
            if BetterBlizzPlatesDB.classicNameplates then
                local hiddenLevel = BetterBlizzPlatesDB.hideLevelFrame
                if hiddenLevel then
                    frame.healthBar:SetPoint("LEFT", frame, "CENTER", -15, 0)
                    frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 15,0)
                else
                    frame.healthBar:SetPoint("LEFT", frame, "CENTER", -20, 0)
                    frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 7,0)
                end
            else
                frame.healthBar:SetPoint("LEFT", frame, "CENTER", -15, 0)
                frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 15,0)
            end
        else
            frame.healthBar:ClearPoint("RIGHT")
            frame.healthBar:ClearPoint("LEFT")
            if BetterBlizzPlatesDB.classicNameplates then
                local xPos = BetterBlizzPlatesDB.hideLevelFrame and -4 or -21
                frame.healthBar:SetPoint("LEFT", frame, "LEFT", 4, 0)
                frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", xPos,0)
            else
                frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", 0,0)
                frame.healthBar:SetPoint("LEFT", frame, "LEFT", 0, 0)
            end
        end
    end

    if config.enableNameplateAuraCustomisation then
        BBP.ProcessAurasForNameplate(frame, frame.unit)
        if frame.BuffFrame and frame.BuffFrameHidden then
            frame.BuffFrame:SetAlpha(1)
            frame.BuffFrameHidden = false
        end
    end

    BBP.ColorCastbar(frame)

    -- --HealthBar Height
    -- if config.changeHealthbarHeight then ChangeHealthbarHeight(frame) end

    if config.changeNameplateBorderSize then ChangeHealthbarBorderSize(frame) end

    -- Apply custom healthbar texture
    if config.useCustomTextureForBars or BBP.needsUpdate then BBP.ApplyCustomTextureToNameplate(frame) end

    -- Hook castbar hide function for resource
    if config.nameplateResourceUnderCastbar then HookNameplateCastbarHide(frame) end

    -- Hook nameplate border color
    if config.changeNameplateBorderColor then BBP.ColorNameplateBorder(frame) end

    -- Anon mode
    if config.anonModeOn then anonMode(frame, info) end

    if config.arenaIndicatorBg then
        BBP.BattlegroundSpecNames(frame)
    end

    -- Show Arena ID/Spec
    if config.arenaIndicators then BBP.ArenaIndicatorCaller(frame) end

    ToggleTargetNameplateHighlight(frame)

    if config.partyPointer then BBP.PartyPointer(frame) end

    -- Castbar customization
    if config.enableCastbarCustomization then BBP.CustomizeCastbar(frame, frame.unit) end

    -- Show Quest Indicator
    if config.questIndicator then BBP.QuestIndicator(frame) end

    -- Show Class Indicator
    if config.classIndicator and not info.isSelf then BBP.ClassIndicator(frame) end

    -- Show Target indicator
    if config.targetIndicator then BBP.TargetIndicator(frame) end

    -- Show absorb amount
    if config.absorbIndicator then BBP.AbsorbIndicator(frame) end

    -- Show Execute Indicator
    if config.executeIndicator then BBP.ExecuteIndicator(frame) end

    if config.healthNumbers then BBP.HealthNumbers(frame) end

    -- Handle nameplate aura and target highlight visibility
    ToggleNameplateBuffFrameVisibility(frame)
    BBP.ToggleNameplateAuras(frame)

    -- Hide friendly healthbar (non magic version)
    if config.friendlyHideHealthBar then HideFriendlyHealthbar(frame) end

    -- Fade out NPCs from list if enabled
    if config.fadeOutNPC then BBP.FadeOutNPCs(frame) end

    -- Hide NPCs from list if enabled
    if config.hideNPC then BBP.HideNPCs(frame, nameplate) end

    -- Color healthbar by reaction
    if config.friendlyHealthBarColor or config.enemyHealthBarColor then ColorNameplateByReaction(frame) end --isSelf skip

    -- Color NPC
    if config.colorNPC then BBP.ColorNpcHealthbar(frame) end

    -- Show main hunter/lock pet icon
    if config.petIndicator then BBP.PetIndicator(frame) end

    -- Handle raid marker changes
    if config.raidmarkIndicator then BBP.ApplyRaidmarkerChanges(frame) end

    -- Hide raidmarker
    if config.hideRaidmarkIndicator then BBP.HideRaidmarker(frame) end

    -- Healer icon
    if config.healerIndicator then BBP.HealerIndicator(frame) end

    -- Apply Out Of Combat Icon
    if config.combatIndicator then BBP.CombatIndicator(frame) end

    -- Show Focus Target Indicator
    if config.focusTargetIndicator then BBP.FocusTargetIndicator(frame) end

    -- Show totem icons
    if config.totemIndicator then BBP.ApplyTotemIconsAndColorNameplate(frame, unit) end

    -- Color nameplate depending on aura
    if config.auraColor then BBP.AuraColor(frame) end

    -- Friend Indicator
    if config.friendIndicator then FriendIndicator(frame) end

    -- Name repositioning
    if config.useFakeName then BBP.SetupFakeName(frame) end

    if config.showNpcTitle then NameplateNPCTitle(frame) end

    if config.showLastNameNpc then ShowLastNameOnlyNpc(frame) end

    local alwaysHideFriendlyCastbar = BetterBlizzPlatesDB.alwaysHideFriendlyCastbar
    local alwaysHideEnemyCastbar = BetterBlizzPlatesDB.alwaysHideEnemyCastbar
    if (info.isFriend and alwaysHideFriendlyCastbar) or (not info.isFriend and alwaysHideEnemyCastbar) then
        frame.CastBar:Hide()
    end

    -- Hide name
    if ((config.hideFriendlyNameText or (config.partyPointerHideAll and frame.partyPointer and frame.partyPointer:IsShown())) and info.isFriend) or (config.hideEnemyNameText and not info.isFriend) then
        frame.name:SetAlpha(0)
        if frame.fakeName then
            frame.fakeName:SetAlpha(0)
        end
    end

    if BetterBlizzPlatesDB.changeHealthbarHeight then
        if UnitCanAttack(frame.unit, "player") then
            frame.healthBar:SetHeight(config.hpHeightEnemy or 11)
        else
            frame.healthBar:SetHeight(config.hpHeightFriendly or 11)
        end
    end
    if config.classicNameplates then
        AdjustClassicBorderWidth(frame)
        CreateBetterClassicCastbarBorders(frame)
    end
end


--#################################################################################################
-- Event Listener
local frameAdded = CreateFrame("Frame")
frameAdded:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frameAdded:SetScript("OnEvent", function(self, event, unit)
    HandleNamePlateAdded(unit)
end)

local frameRemoved = CreateFrame("Frame")
frameRemoved:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frameRemoved:SetScript("OnEvent", function(self, event, unit)
    HandleNamePlateRemoved(unit)
end)

--#################################################################################################
--Update all nameplates
function BBP.RefreshAllNameplates()
    local db = BetterBlizzPlatesDB
    if db.wasOnLoadingScreen then return end
    -- local useCustomFont = BetterBlizzPlatesDB.useCustomFont
    -- if useCustomFont then
    --     local fontName = BetterBlizzPlatesDB.customFont
    --     local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
    --     -- Table of font objects to update
    --     local fontsToUpdate = {
    --         SystemFont_LargeNamePlate,
    --         SystemFont_NamePlate,
    --         SystemFont_LargeNamePlateFixed,
    --         SystemFont_NamePlateFixed
    --     }
    --     for _, fontObject in ipairs(fontsToUpdate) do
    --         local fontSize = select(2, fontObject:GetFont())
    --         fontObject:SetFont(fontPath, fontSize, "THINOUTLINE")
    --     end
    -- end
    if not db.skipAdjustingFixedFonts then
        BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultLargeNamePlateFontFlags)
        BBP.SetFontBasedOnOption(SystemFont_NamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultNamePlateFontFlags)
        BBP.SetFontBasedOnOption(SystemFont_LargeNamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultLargeNamePlateFontFlags)
        BBP.SetFontBasedOnOption(SystemFont_NamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultNamePlateFontFlags)
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        local unitFrame = nameplate.UnitFrame
        if not frame or frame:IsForbidden() or frame:IsProtected() then return end
        local unitToken = frame.unit
        if not frame.unit then return end

        --local config = InitializeNameplateSettings(frame)
        local info = GetNameplateUnitInfo(frame)
        if not info then return end

        if BetterBlizzPlatesDB.hideLevelFrame and BetterBlizzPlatesDB.classicNameplates then
            HideLevelFrameOnClassicNameplate(frame)
        else
            if BetterBlizzPlatesDB.classicNameplates then
                if frame.BetterBlizzPlates.bbpBorder and frame.BetterBlizzPlates.bbpBorder.changed then
                    frame.BetterBlizzPlates.bbpBorder.right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRight")
                    frame.healthBar:ClearPoint("RIGHT")
                    frame.healthBar:ClearPoint("LEFT")
                    frame.healthBar:SetPoint("LEFT", frame, "LEFT", 4, 0)
                    local xPos = BetterBlizzPlatesDB.hideLevelFrame and -4 or -21
                    frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", xPos,0)
                    AdjustClassicBorderWidth(frame)
                end
                frame.LevelFrame:Show()
            end
        end

        CreateBetterCastbarText(frame)

        local hideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar

        if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
            BBP.RefUnitAuraTotally(unitFrame)
        end

        if BetterBlizzPlatesDB.focusTargetIndicator then
            BBP.FocusTargetIndicator(frame)
        end

        if BetterBlizzPlatesDB.healthNumbers then
            BBP.HealthNumbers(frame)
        else
            if frame.healthNumbers then
                frame.healthNumbers:SetText("")
            end
        end

        if BetterBlizzPlatesDB.auraColor then
            BBP.AuraColor(frame)
        end

        if not BetterBlizzPlatesDB.useFakeName then
            if frame.fakeName then
                frame.fakeName:SetAlpha(0)
                frame.fakeName = nil
                frame.name:SetAlpha(1)
            end
        end

        if BetterBlizzPlatesDB.enableCastbarCustomization then
            BBP.CustomizeCastbar(unitToken)
        end

        if BetterBlizzPlatesDB.classicNameplates then
            CreateBetterClassicHealthbarBorder(frame)
        else
            CreateRetailNameplateLook(frame)
        end

        BBP.ClassColorAndScaleNames(frame)

        if frame.TargetText then
            BBP.SetFontBasedOnOption(frame.TargetText, 12)
        end
        if frame.absorbIndicator then
            BBP.SetFontBasedOnOption(frame.absorbIndicator, 10)
        end
        if frame.CastTimer then
            BBP.SetFontBasedOnOption(frame.CastTimer, 11)
        end
        if frame.executeIndicator then
            BBP.SetFontBasedOnOption(frame.executeIndicator, 10, "THICKOUTLINE")
        end
        if frame.arenaNumberText then
            BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
        end
        if frame.specNameText then
            BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
        end
        if frame.guildName then
            if BetterBlizzPlatesDB.showGuildNames and BetterBlizzPlatesDB.friendlyHideHealthBar then
                local guildName, guildRankName, guildRankIndex = GetGuildInfo(nameplate.UnitFrame.unit)
                if guildName then
                    frame.guildName:SetText("<"..guildName..">")
                    if BetterBlizzPlatesDB.guildNameColor then
                        frame.guildName:SetTextColor(unpack(BetterBlizzPlatesDB.guildNameColorRGB))
                    else
                        frame.guildName:SetTextColor(frame.name:GetTextColor())
                    end
                    frame.guildName:SetPoint("TOP", frame.fakeName or frame.name, "BOTTOM", 0, 0)
                    frame.guildName:SetScale(BetterBlizzPlatesDB.guildNameScale or 1)
                else
                    frame.guildName:SetText("")
                end
            else
                frame.guildName:SetText("")
            end
        end

        -- Hide quest indicator after testing
        if BetterBlizzPlatesDB.questIndicator or not BetterBlizzPlatesDB.questIndicatorTestMode then
            if frame.questIndicator then
                frame.questIndicator:Hide()
            end
            if BetterBlizzPlatesDB.questIndicator then
                BBP.QuestIndicator(frame)
            end
        end

        -- Hide focus marker after testing
        if BetterBlizzPlatesDB.focusTargetIndicator or not BetterBlizzPlatesDB.focusTargetIndicatorTestMode then
            if frame.focusTargetIndicator then
                frame.focusTargetIndicator:Hide()
            end
            if BetterBlizzPlatesDB.focusTargetIndicator then
                BBP.FocusTargetIndicator(frame)
            end
        end

        -- Reset nameplate scale after testing totems
        if not BetterBlizzPlatesDB.totemIndicatorTestMode then
            if frame then
                frame:SetScale(1)
            end
        end
        -- Always update the name
        --BBP.RestoreOriginalNameplateColors(frame)
        BBP.CompactUnitFrame_UpdateHealthColor(frame)
        BBP.ConsolidatedUpdateName(frame)
        HandleNamePlateAdded(frame.unit)
        if not BetterBlizzPlatesDB.fadeOutNPC then
            frame:SetAlpha(1)
        end
        if not BetterBlizzPlatesDB.friendlyHideHealthBar then
            if frame.healthBar then
                if not hideHealthBar and not BetterBlizzPlatesDB.totemIndicatorTestMode then
                    frame.healthBar:SetAlpha(1)
                end
            end
        end
        if not BetterBlizzPlatesDB.hideNPC then
            if frame then
                frame:Show()
            end
        end
        if BetterBlizzPlatesDB.totemIndicatorTestMode then
            if hideHealthBar then
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
                frame.healthBar:SetAlpha(1)
                if not hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end

        -- if frame.CastBar then
        --     if not BetterBlizzPlatesDB.useCustomCastbarBGTexture or not BetterBlizzPlatesDB.useCustomCastbarTexture then
        --         frame.CastBar.Background:SetDesaturated(false)
        --         frame.CastBar.Background:SetVertexColor(1,1,1,1)
        --         frame.CastBar.Background:SetAtlas("UI-CastingBar-Background")
        --     end
        -- end

        if BetterBlizzPlatesDB.targetIndicator then
            BBP.TargetIndicator(frame)
        end

        if not BetterBlizzPlatesDB.hideRaidmarkIndicator then
            frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
        end

        -- -- Hide name
        -- if BetterBlizzPlatesDB.hideFriendlyNameText or BetterBlizzPlatesDB.hideEnemyNameText then
        --     if (BetterBlizzPlatesDB.hideFriendlyNameText and info.isFriend) or (BetterBlizzPlatesDB.hideEnemyNameText and not info.isFriend) then
        --         frame.name:SetAlpha(0)
        --         if frame.fakeName then
        --             frame.fakeName:SetAlpha(0)
        --         end
        --     else
        --         if frame.fakeName then
        --             frame.name:SetAlpha(0)
        --             frame.fakeName:SetAlpha(1)
        --         else
        --             frame.name:SetAlpha(1)
        --         end
        --     end
        -- end

        if BetterBlizzPlatesDB.hideNPC then
            BBP.HideNPCs(frame, nameplate)
        end

        if BetterBlizzPlatesDB.totemIndicator then
            BBP.ApplyTotemIconsAndColorNameplate(frame)
        end

        if BetterBlizzPlatesDB.partyPointer then
            BBP.PartyPointer(frame)
        else
            if frame.partyPointer then
                frame.partyPointer:Hide()
            end
        end

        if BetterBlizzPlatesDB.changeNameplateBorderSize then
            if info.isTarget then
                frame.healthBar:SetBorderSize(BetterBlizzPlatesDB.nameplateTargetBorderSize)
            else
                frame.healthBar:SetBorderSize(BetterBlizzPlatesDB.nameplateBorderSize)
            end
        end

        if BetterBlizzPlatesDB.classicNameplates then
            if BetterBlizzPlatesDB.smallPetsInPvP then
                if info.isNpc and (BBP.isInArena or BBP.isInBg) then
                    frame.healthBar:ClearPoint("RIGHT")
                    frame.healthBar:ClearPoint("LEFT")
                    if BetterBlizzPlatesDB.classicNameplates then
                        local hiddenLevel = BetterBlizzPlatesDB.hideLevelFrame
                        if hiddenLevel then
                            frame.healthBar:SetPoint("LEFT", frame, "CENTER", -15, 0)
                            frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 15,0)
                        else
                            frame.healthBar:SetPoint("LEFT", frame, "CENTER", -20, 0)
                            frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 7,0)
                        end
                    else
                        frame.healthBar:SetPoint("LEFT", frame, "CENTER", -15, 0)
                        frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 15,0)
                    end
                else
                    frame.healthBar:ClearPoint("RIGHT")
                    frame.healthBar:ClearPoint("LEFT")
                    if BetterBlizzPlatesDB.classicNameplates then
                        local xPos = BetterBlizzPlatesDB.hideLevelFrame and -4 or -21
                        frame.healthBar:SetPoint("LEFT", frame, "LEFT", 4, 0)
                        frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", xPos,0)
                    else
                        frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", 0,0)
                        frame.healthBar:SetPoint("LEFT", frame, "LEFT", 0, 0)
                    end
                end
            end
            AdjustClassicBorderWidth(frame)
            CreateBetterClassicCastbarBorders(frame)

            if frame.BetterBlizzPlates.bbpBorder.changed and not BetterBlizzPlatesDB.hideLevelFrame then
                frame.BetterBlizzPlates.bbpBorder.right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRight")
                frame.BetterBlizzPlates.bbpBorder.changed = nil
                frame.LevelFrame:Show()
                frame.LevelFrame:SetAlpha(1)
            end
        end
    end
end

hooksecurefunc(NamePlateDriverFrame, "OnUnitFactionChanged", function(self,unit)
    if not unit or not unit:find("nameplate") then return end
    C_Timer.After(0.2, function()
        HandleNamePlateAdded(unit)
    end)
end)

function BBP.RefreshAllNameplatesLightVer()
    --if not BBP.checkCombatAndWarn() then
        for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
            local frame = nameplate.UnitFrame
            --BBP.RestoreOriginalNameplateColors(frame)
            --CompactUnitFrame_UpdateName(frame)
            --HandleNamePlateAdded(frame.unit)
            BBP.ArenaIndicatorCaller(frame)
        end
    --end
end

--#################################################################################################
-- Nameplate updater etc
function BBP.ConsolidatedUpdateName(frame)
    if not frame or frame:IsForbidden() or frame:IsProtected() then return end
    local removeRealmName = BetterBlizzPlatesDB.removeRealmNames
    if removeRealmName then
        BBP.RemoveRealmName(frame)
    end

    -- Further processing only for nameplate units
    if not frame.unit or not frame.unit:find("nameplate") then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    --local info = GetNameplateUnitInfo(frame) --frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    frame.BetterBlizzPlates.unitInfo = BBP.GetNameplateUnitInfo(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    if not info then return end

    if not config.updateNameInitialized or BBP.needsUpdate then
        config.colorNPCName = BetterBlizzPlatesDB.colorNPCName
        config.hideFriendlyNameText = BetterBlizzPlatesDB.hideFriendlyNameText
        config.hideEnemyNameText = BetterBlizzPlatesDB.hideEnemyNameText
        config.colorTargetName = BetterBlizzPlatesDB.targetIndicatorColorName and BetterBlizzPlatesDB.targetIndicator
        config.targetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        config.colorFocusName = BetterBlizzPlatesDB.focusTargetIndicatorColorName and BetterBlizzPlatesDB.focusTargetIndicator
        config.focusTargetIndicatorColorNameplateRGB = BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB
        config.totemIndicatorTest = config.totemIndicatorTestMode and frame.randomColor
        config.anonModeOn = BetterBlizzPlatesDB.anonMode
        config.friendlyHealthBarColorRGB = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
        config.totemIndicatorHideNameAndShiftIconDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
        config.useFakeName = BetterBlizzPlatesDB.useFakeName
        config.totemIndicator = BetterBlizzPlatesDB.totemIndicator
        config.totemIndicatorColorHealthBar = BetterBlizzPlatesDB.totemIndicatorColorHealthBar
        config.totemIndicatorColorName = BetterBlizzPlatesDB.totemIndicatorColorName
        config.showLastNameNpc = BetterBlizzPlatesDB.showLastNameNpc
        config.arenaIndicatorBg = BetterBlizzPlatesDB.arenaIndicatorBg

        config.updateNameInitialized = true
    end

    --if info.isSelf then return end
    -- frame.name:ClearAllPoints()
    -- frame.name:SetPoint("CENTER", frame, "CENTER", 0, 7)

    -- Class color and scale names depending on their reaction
    ColorNameplateNameReaction(frame)
    BBP.ClassColorAndScaleNames(frame)

    -- Anon mode replace name with class
    if config.anonModeOn then anonMode(frame, info) end

    -- Use arena numbers
    if config.arenaIndicators then BBP.ArenaIndicatorCaller(frame) end

    if config.arenaIndicatorBg then
        BBP.BattlegroundSpecNames(frame)
    end

    -- Handle absorb indicator and reset absorb text if it exists
    if config.absorbIndicator then BBP.AbsorbIndicator(frame) end

    -- Show out of combat icon
    if config.combatIndicator then BBP.CombatIndicator(frame) end

    -- Show hunter pet icon
    if config.petIndicator then BBP.PetIndicator(frame) end

    -- Show healer icon
    if config.healerIndicator then BBP.HealerIndicator(frame) end

    -- Show Class Indicator
    if config.classIndicator then BBP.ClassIndicator(frame) end --and not info.isSelf then BBP.ClassIndicator(frame) end bodify not sure if this needs to run here

    -- Color NPC
    if config.colorNPC and config.colorNPCName and config.npcHealthbarColor then
        frame.name:SetVertexColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
    end

    -- Color nameplate and pick random name or hide name during totem tester
    if config.totemIndicatorTest then
        if config.totemIndicatorColorName then
            frame.name:SetVertexColor(unpack(frame.randomColor))
            if config.totemIndicatorHideNameAndShiftIconDown or config.randomTotemIconOnly then
                frame.name:SetText("")
            else
                frame.name:SetText(frame.randomName)
            end
        end
    end

    -- Ensure totem nameplate color is correct
    if config.totemIndicator and config.totemIndicatorColorName then
        local guid = UnitGUID(frame.unit);
        local npcID = tonumber(guid and guid:match("-(%d+)-%x+$"))
        if BetterBlizzPlatesDB.totemIndicatorNpcList[npcID] and BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color then
            if not info.isFriend then
                if config.totemIndicatorColorHealthBar then
                    frame.healthBar:SetStatusBarColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                end
                if config.totemIndicatorHideNameAndShiftIconDown or BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].iconOnly then
                    frame.name:SetText("")
                else
                    frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                end
            else
                if not config.totemIndicatorEnemyOnly then
                    if config.totemIndicatorColorHealthBar then
                        frame.healthBar:SetStatusBarColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                    end
                    if config.totemIndicatorHideNameAndShiftIconDown or BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].iconOnly then
                        frame.name:SetText("")
                    else
                        frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                    end
                end
            end
        end
    end

    if config.colorFocusName and info.isFocus then
        frame.name:SetVertexColor(unpack(config.focusTargetIndicatorColorNameplateRGB))
    end

    if config.colorTargetName and info.isTarget then
        frame.name:SetVertexColor(unpack(config.targetIndicatorColorNameplateRGB))
    end

    if config.useFakeName then BBP.SetupFakeName(frame) end

    if config.showLastNameNpc then ShowLastNameOnlyNpc(frame) end

    if (config.hideFriendlyNameText and info.isFriend) or (config.hideEnemyNameText and not info.isFriend) then
        frame.name:SetAlpha(0)
        if frame.fakeName then
            frame.fakeName:SetAlpha(0)
        end
    end

    if frame.hideNameOverride then
        frame.name:SetAlpha(0)
        if frame.fakeName then
            frame.fakeName:SetAlpha(0)
        end
    else
        if frame.partyPointer and config.partyPointerHideAll and frame.partyPointer:IsShown() then
            frame.name:SetAlpha(0)
            if frame.fakeName then
                frame.fakeName:SetAlpha(0)
            end
        end
    end
end
-- Use the consolidated function to hook into CompactUnitFrame_UpdateName
hooksecurefunc("CompactUnitFrame_UpdateName", BBP.ConsolidatedUpdateName)

local function setNil(table, member)
    TextureLoadingGroupMixin.RemoveTexture(
        { textures = table }, member
    )
end

local function setTrue(table, member)
    TextureLoadingGroupMixin.AddTexture(
        { textures = table }, member
    )
end

-- Function to update the instance status
local function UpdateInstanceStatus()
    local inInstance, instanceType = IsInInstance()
    BBP.isInPvE = inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario")
    BBP.isInArena = inInstance and (instanceType == "arena")
    BBP.isInBg = inInstance and (instanceType == "pvp")
    BBP.isInPvP = BBP.isInBg or BBP.isInArena
end

-- Function to update the current class role
local function UpdateClassRoleStatus(self, event)
    local _, class = UnitClass("player")
    local isTank = false

    -- Check the player's talent tree to infer if they are a tank
    local spec1, _, _, _, pointsSpent1 = GetTalentTabInfo(1)
    local spec2, _, _, _, pointsSpent2 = GetTalentTabInfo(2)
    local spec3, _, _, _, pointsSpent3 = GetTalentTabInfo(3)

    if class == "WARRIOR" then
        if pointsSpent3 > pointsSpent1 and pointsSpent3 > pointsSpent2 then
            isTank = true
        end
    elseif class == "PALADIN" then
        if pointsSpent2 > pointsSpent1 and pointsSpent2 > pointsSpent3 then
            isTank = true
        end
    elseif class == "DRUID" then
        if pointsSpent2 > pointsSpent1 and pointsSpent2 > pointsSpent3 then
            isTank = true
        end
    elseif class == "DEATHKNIGHT" then
        if pointsSpent1 > pointsSpent2 and pointsSpent1 > pointsSpent3 then
            isTank = true
        end
    end

    BBP.isRoleTank = isTank
end

local ClassRoleChecker = CreateFrame("Frame")
ClassRoleChecker:RegisterEvent("PLAYER_ENTERING_WORLD")
ClassRoleChecker:RegisterEvent("PLAYER_TALENT_UPDATE")
ClassRoleChecker:SetScript("OnEvent", UpdateClassRoleStatus)

local function ThreatSituationUpdate(self, event)
    if ( BetterBlizzPlatesDB.enemyColorThreat and (BBP.isInPvE or (BetterBlizzPlatesDB.threatColorAlwaysOn and not BBP.isInPvP)) ) then
        for _, nameplate in pairs(C_NamePlate.GetNamePlates(issecure())) do
            local frame = nameplate.UnitFrame
            BBP.ColorThreat(frame)
        end
    end
end

local ThreatSitUpdate = CreateFrame("Frame")
ThreatSitUpdate:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
ThreatSitUpdate:SetScript("OnEvent", ThreatSituationUpdate)

-- Function to set the nameplate behavior
local InstanceChecker = CreateFrame("Frame")

local function SetNameplateBehavior()
    if InCombatLockdown() then
        --C_Timer.After(1, SetNameplateBehavior)
        if not InstanceChecker:IsEventRegistered("PLAYER_REGEN_ENABLED") then
            InstanceChecker:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
    else
        if BBP.isInPvE then
            if BetterBlizzPlatesDB.friendlyHideHealthBar and not BetterBlizzPlatesDB.doNotHideFriendlyHealthbarInPve then
                C_CVar.SetCVar('nameplateShowOnlyNames', 1)
            else
                C_CVar.SetCVar('nameplateShowOnlyNames', 0)
            end
            if BetterBlizzPlatesDB.toggleNamesOffDuringPVE then C_CVar.SetCVar("UnitNameFriendlyPlayerName", 0) end
            BBP.ApplyNameplateWidth()
        else
            --if BetterBlizzPlatesDB.friendlyHideHealthBar then C_CVar.SetCVar('nameplateShowOnlyNames', 0) end
            C_CVar.SetCVar('nameplateShowOnlyNames', 0)
            if BetterBlizzPlatesDB.toggleNamesOffDuringPVE then C_CVar.SetCVar("UnitNameFriendlyPlayerName", 1) end
            BBP.ApplyNameplateWidth()
        end
    end
end

-- Event handler function
local hideFriendlyCastbar
local friendlyHideHealthBarNpc
local function CheckIfInInstance(self, event, ...)
    hideFriendlyCastbar = BetterBlizzPlatesDB.alwaysHideFriendlyCastbar
    friendlyHideHealthBarNpc = BetterBlizzPlatesDB.friendlyHideHealthBarNpc
    -- UpdateInstanceStatus()
    -- SetNameplateBehavior()
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        UpdateInstanceStatus()
        SetNameplateBehavior()
        BBP.fistweaverFound = nil
    elseif event == "PLAYER_REGEN_ENABLED" then
        SetNameplateBehavior()
        InstanceChecker:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

InstanceChecker:RegisterEvent("PLAYER_ENTERING_WORLD")
InstanceChecker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
InstanceChecker:SetScript("OnEvent", CheckIfInInstance)

function BBP.CheckIfInInstanceCaller()
    CheckIfInInstance()
end

local hookedGetNamePlateTypeFromUnit = false

function BBP.ToggleHideHealthbar()
    BetterBlizzPlatesDB.friendlyHideHealthBar = not BetterBlizzPlatesDB.friendlyHideHealthBar
    BBP.friendlyHideHealthBar:SetChecked(BetterBlizzPlatesDB.friendlyHideHealthBar)
    if BBP.friendlyHideHealthBar:GetChecked() then
        BBP.friendlyHideHealthBarNpc:Enable()
        BBP.friendlyHideHealthBarNpc:SetAlpha(1)
    else
        BBP.friendlyHideHealthBarNpc:Disable()
        BBP.friendlyHideHealthBarNpc:SetAlpha(0)
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        HideFriendlyHealthbar(frame)
    end
    if BBP.isInPvE then
        if BetterBlizzPlatesDB.friendlyHideHealthBar then--for toggle keybind
            setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        else
            setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
        end
    end
end




local forbiddenFrame = CreateFrame("Frame")
forbiddenFrame:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
forbiddenFrame:SetScript("OnEvent", function(self, event, unit)
    if BBP.isInPvE and hideFriendlyCastbar then
        local plateFrame = C_NamePlate.GetNamePlateForUnit (unit, true)
        if (plateFrame) then -- and plateFrame.template == "ForbiddenNamePlateUnitFrameTemplate"
            TextureLoadingGroupMixin.RemoveTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
        end
    end
end)


hooksecurefunc (NamePlateDriverFrame, "UpdateNamePlateOptions", function()
    if BBP.isInPvE and hideFriendlyCastbar then
        for _, plateFrame in pairs(C_NamePlate.GetNamePlates(true)) do
            if (plateFrame) then
                if GetCVarBool ("nameplateShowOnlyNames") then
                    TextureLoadingGroupMixin.RemoveTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
                else
                    TextureLoadingGroupMixin.AddTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
                end
            end
        end
    end
end)

local function HideHealthbarInPvEMagic()
    if BetterBlizzPlatesDB.friendlyHideHealthBar and not hookedGetNamePlateTypeFromUnit then
        -- Set the hook flag
        hookedGetNamePlateTypeFromUnit = true

        hooksecurefunc(
            NamePlateDriverFrame,
            'GetNamePlateTypeFromUnit',
            function(_, unit)
                if BBP.isInPvE then
                    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
                    local isPlayer = UnitIsPlayer(unit)
                    if not isFriend then
                        setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                        setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                    else
                        if isPlayer then
                            local skipHide = BetterBlizzPlatesDB.doNotHideFriendlyHealthbarInPve
                            if not skipHide then
                                setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                            end
                            if hideFriendlyCastbar then
                                setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                            else
                                setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                            end
                            setNil(DefaultCompactNamePlateFrameSetUpOptions, 'showLevel')
                            setNil(DefaultCompactNamePlateFriendlyFrameOptions, 'showLevel')
                        else
                            setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                            setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                        end
                    end
                end
                -- if not UnitIsPlayer(unit) then
                --     setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                -- else
                --     setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                -- end
            end
        )
    end
end

function BBP.HideHealthbarInPvEMagicCaller()
    HideHealthbarInPvEMagic()
end

-- Event registration for PLAYER_LOGIN
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
--Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(...)
    local db = BetterBlizzPlatesDB

    CheckForUpdate()

    _, playerClass = UnitClass("player")
    playerClassColor = RAID_CLASS_COLORS[playerClass]

    if db.enableNameplateAuraCustomisation then
        BBP.RunAuraModule()
    end

    --if BetterBlizzPlatesDB.enableCastbarCustomization then
        --BBP.HookDefaultCompactNamePlateFrameAnchorInternal()
    --end

    if BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true or GetCVarBool("nameplateShowSelf") then
        BBP.TargetResourceUpdater()
    end

    -- local useCustomFont = BetterBlizzPlatesDB.useCustomFont
    -- if useCustomFont then
    --     local fontName = BetterBlizzPlatesDB.customFont
    --     local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
    --     -- Table of font objects to update
    --     local fontsToUpdate = {
    --         SystemFont_LargeNamePlate,
    --         SystemFont_NamePlate,
    --         SystemFont_LargeNamePlateFixed,
    --         SystemFont_NamePlateFixed
    --     }
    --     for _, fontObject in ipairs(fontsToUpdate) do
    --         local fontSize = select(2, fontObject:GetFont())
    --         fontObject:SetFont(fontPath, fontSize, "THINOUTLINE")
    --     end
    -- end

    C_Timer.After(1, function()
        if not db.skipAdjustingFixedFonts then
            BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultLargeNamePlateFontFlags)
            BBP.SetFontBasedOnOption(SystemFont_NamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultNamePlateFontFlags)
            BBP.SetFontBasedOnOption(SystemFont_LargeNamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultLargeNamePlateFontFlags)
            BBP.SetFontBasedOnOption(SystemFont_NamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")--db.defaultNamePlateFontFlags)
        end
    end)

    if db.changeHealthbarHeight then
        BBP.HookHealthbarHeight()
    end

    BBP.HookOverShields()
    BBP.ToggleTotemIndicatorShieldBorder()

    BBP.ApplyNameplateWidth()

    C_Timer.After(1, function()
        if db.executeIndicatorScale <= 0 then --had a slider with borked values
            db.executeIndicatorScale = 1     --this will fix it for every user who made the error while bug was live
        end
    end)

    SetCVarsOnLogin()
    BBP.InitializeInterruptSpellID() --possibly not needed, talent events seem to always run on login?

    -- Re-open options when clicking reload button
    if db.reopenOptions then
        --InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
        Settings.OpenToCategory(BBP.category.ID)
        db.reopenOptions = false
    end
    BBP.CreateUnitAuraEventFrame()

    -- Modify the hooksecurefunc based on instance status
    HideHealthbarInPvEMagic()
    --BBP.HideNameplateAuraTooltip()
end)

local nameplateWidthOnEnterWorld = CreateFrame("Frame")
nameplateWidthOnEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
nameplateWidthOnEnterWorld:SetScript("OnEvent", function()
    BBP.ApplyNameplateWidth()
    C_Timer.After(1, function()
        if not InCombatLockdown() then
            BBP.ApplyNameplateWidth()
        end
    end)
    if BetterBlizzPlatesDB.darkModeNameplateResource then
        BBP.DarkModeNameplateResources()
    end
end)

-- Slash command
SLASH_BBP1 = "/bbp"
SlashCmdList["BBP"] = function(msg)
    local command = string.lower(msg)
    if command == "news" then
        BBP.ToggleUpdateMessageWindow()
    elseif command == "nahj" then
        StaticPopup_Show("BBP_CONFIRM_NAHJ_PROFILE")
    elseif command == "magnusz" then
        StaticPopup_Show("BBP_CONFIRM_MAGNUSZ_PROFILE")
    elseif command == "reset" then
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    elseif command == "fixnameplates" then
        StaticPopup_Show("CONFIRM_FIX_NAMEPLATES_BBP")
    elseif command == "ver" or command == "version" then
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates Version "..addonUpdates)
    else
        --InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
        Settings.OpenToCategory(BBP.category.ID)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CVAR_UPDATE")
frame:SetScript("OnEvent", function(self, event, cvarName)
    if cvarName == "NamePlateHorizontalScale" or cvarName == "nameplateResourceOnTarget" then
        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            if BBP.isLargeNameplatesEnabled() then
                BetterBlizzPlatesDB.NamePlateVerticalScale = 2.7
            else
                BetterBlizzPlatesDB.NamePlateVerticalScale = 1
            end
            RunNextFrame(function()
                BBP.ApplyNameplateWidth()
            end)
        end
    end
end)

local function TurnOnEnabledFeaturesOnLogin()
    if BetterBlizzPlatesDB.raidmarkIndicator then
        BBP.ChangeRaidmarker()
    end

    BBP.ToggleSpellCastEventRegistration()
    BBP.ApplyNameplateWidth()
    BBP.ToggleFriendlyNameplatesAuto()
    BBP.ToggleAbsorbIndicator()
    BBP.ToggleCombatIndicator()
    BBP.ToggleExecuteIndicator()
    BBP:RegisterTargetCastingEvents()
    BBP.ToggleHealthNumbers()
end

-- Event registration for PLAYER_LOGIN
local First = CreateFrame("Frame")
First:RegisterEvent("ADDON_LOADED")
First:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName then
        if addonName == "BetterBlizzPlates" then
            TurnOffTestModes()
            BetterBlizzPlatesDB.castbarEventsOn = false
            BetterBlizzPlatesDB.wasOnLoadingScreen = true

            InitializeSavedVariables()
            -- Fetch Blizzard default values
            if not BetterBlizzPlatesDB.firstSaveComplete then
                BetterBlizzPlatesDB.defaultLargeNamePlateFont, BetterBlizzPlatesDB.defaultLargeFontSize, BetterBlizzPlatesDB.defaultLargeNamePlateFontFlags = SystemFont_LargeNamePlate:GetFont()
                BetterBlizzPlatesDB.defaultNamePlateFont, BetterBlizzPlatesDB.defaultFontSize, BetterBlizzPlatesDB.defaultNamePlateFontFlags = SystemFont_NamePlate:GetFont()
                FetchAndSaveValuesOnFirstLogin()

                BetterBlizzPlatesDB.firstSaveComplete = true
            end

            if not BetterBlizzPlatesDB.auraWhitelistColorsUpdated then
                UpdateAuraColorsToGreen() --update default yellow text to green for new color featur
                BetterBlizzPlatesDB.auraWhitelistColorsUpdated = true
            end

            if not BetterBlizzPlatesDB.auraWhitelistAlphaUpdated then
                AddAlphaValuesToAuraColors()
                BetterBlizzPlatesDB.auraWhitelistAlphaUpdated = true
            end

            if BetterBlizzPlatesDB.castBarIconXPos and not BetterBlizzPlatesDB.castBarIconPosReset then
                BetterBlizzPlatesDB.castBarIconXPos = 0
                BetterBlizzPlatesDB.castBarIconYPos = 0
                BetterBlizzPlatesDB.castBarIconPosReset = true
            end

            if not BetterBlizzPlatesDB.nameplateResourcePositionFix then
                if BetterBlizzPlatesDB.nameplateResourceYPos == 4 then
                    BetterBlizzPlatesDB.nameplateResourceYPos = 0
                end
                BetterBlizzPlatesDB.nameplateResourcePositionFix = true
            end

            TurnOnEnabledFeaturesOnLogin()
            BBP.InitializeOptions()
        end
    end
end)

local function OnVariablesLoaded(self, event)
    if event == "VARIABLES_LOADED" then
        if not BetterBlizzPlatesDB.nameplateSelectedAlpha then
            BetterBlizzPlatesDB.nameplateSelectedAlpha = GetCVar("nameplateSelectedAlpha")
            BetterBlizzPlatesDB.nameplateNotSelectedAlpha = GetCVar("nameplateNotSelectedAlpha")
        end
        BBP.variablesLoaded = true
    elseif event == "TRAIT_CONFIG_UPDATED" or event == "PLAYER_TALENT_UPDATE" then
        BBP.InitializeInterruptSpellID()
    end
end

-- Register the frame to listen for the "VARIABLES_LOADED" event
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:SetScript("OnEvent", OnVariablesLoaded)




--#########################################
-- Nameplate castbar test mode, a fiesta mess... another one for the refactor
local nameplates = {}
local timers = {}
local temporaryNpCastTest = CreateFrame("Frame")

local function NamePlateCastBarTestMode(frame)
    local castBar = frame.CastBar
    if castBar then
        castBar:Show()
        castBar:SetAlpha(1)

        local minValue, maxValue = 0, 100
        local duration = 2 -- in seconds
        local stepsPerSecond = 50 -- adjust for smoothness
        local totalSteps = duration * stepsPerSecond
        local stepValue = (maxValue - minValue) / totalSteps
        local currentValue = maxValue -- Start at 100% for channeled cast
        local uninterruptibleChance = 0.25 -- 25% chance of being uninterruptible
        local channeledChance = 0.25 -- 25% chance of being channeled
        local isChanneled = false -- Flag to indicate channeled cast
        local classic = BetterBlizzPlatesDB.classicNameplates

        castBar:SetMinMaxValues(minValue, maxValue)
        castBar:SetValue(currentValue)

        local castType = "normal" -- Initialize as normal cast

        if not castBar.tickTimer then
            castBar.tickTimer = C_Timer.NewTicker(1 / stepsPerSecond, function()

                local castBarCastColor = BetterBlizzPlatesDB.castBarCastColor
                local castBarNonInterruptibleColor = BetterBlizzPlatesDB.castBarNoninterruptibleColor
                local castBarChanneledColor = BetterBlizzPlatesDB.castBarChanneledColor
                local showCastBarIconWhenNoninterruptible = BetterBlizzPlatesDB.showCastBarIconWhenNoninterruptible
                local castBarIconScale = BetterBlizzPlatesDB.castBarIconScale
                local additionalShieldSizeRatio = 1.3
                local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale * additionalShieldSizeRatio) or castBarIconScale

                local textureName = BetterBlizzPlatesDB.customCastbarTexture
                local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
                local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)

                local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
                local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
                local castBarTimer = BetterBlizzPlatesDB.showNameplateCastbarTimer
                local targetText = BetterBlizzPlatesDB.showNameplateTargetText


                castBar.Icon:SetScale(castBarIconScale)
                castBar.BorderShield:SetScale(borderShieldSize)

                -- if not BetterBlizzPlatesDB.useCustomCastbarBGTexture or not BetterBlizzPlatesDB.useCustomCastbarTexture then
                --     frame.CastBar.Background:SetDesaturated(false)
                --     frame.CastBar.Background:SetVertexColor(1,1,1,1)
                --     frame.CastBar.Background:SetAtlas("UI-CastingBar-Background")
                -- end

                if castBarTimer then
                    if not frame.dummyTimer then
                        frame.dummyTimer = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        frame.dummyTimer:SetPoint("LEFT", frame.CastBar, "RIGHT", 5, 0)
                        frame.dummyTimer:SetTextColor(1, 1, 1)
                        frame.dummyTimer:SetText("1.5")
                    end
                    BBP.SetFontBasedOnOption(frame.dummyTimer, 12, "OUTLINE")
                    frame.dummyTimer:Show()
                else
                    if frame.dummyTimer then
                        frame.dummyTimer:Hide()
                    end
                end

                if targetText then
                    if not frame.dummyNameText then
                        frame.dummyNameText = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        frame.dummyNameText:SetJustifyH("CENTER")

                        local _, classIdentifier = UnitClass("player") -- Capture both localized name and class identifier
                        local color = RAID_CLASS_COLORS[classIdentifier] -- Use the class identifier to get the color

                        if color then -- Check if color is not nil
                            frame.dummyNameText:SetText(GetUnitName("player"))
                            frame.dummyNameText:SetTextColor(color.r, color.g, color.b)
                            frame.dummyNameText:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -11, 0)
                        else -- Fallback color in case something goes wrong
                            frame.dummyNameText:SetTextColor(1, 1, 1) -- Set to white or any default color
                        end
                    end

                    local useCustomFont = BetterBlizzPlatesDB.useCustomFont
                    BBP.SetFontBasedOnOption(frame.dummyNameText, useCustomFont and 11 or 12)
                    frame.dummyNameText:Show()
                else
                    if frame.dummyNameText then
                        frame.dummyNameText:Hide()
                    end
                end

                if isChanneled then
                    currentValue = currentValue - stepValue
                    -- Check if the cast has reached the end
                    if currentValue <= minValue then
                        isChanneled = false
                        castBar.BorderShield:SetAlpha(0)
                        if useCustomCastbarTexture then
                            castBar:SetStatusBarTexture(texturePath)
                        else
                            castBar:SetStatusBarTexture("ui-castingbar-filling-standard")
                            local castBarTexture = castBar:GetStatusBarTexture()
                            castBarTexture:SetDesaturated(false)
                            castBar:SetStatusBarColor(1,1,1,1)
                        end
                        castBar.castText:SetText("Frostbolt")
                        castBar.Icon:Show()
                        castBar.Icon:SetTexture(GetSpellTexture(116))
                        if useCustomCastbarTexture or castBarRecolor then
                            local castBarTexture = castBar:GetStatusBarTexture()
                            castBarTexture:SetDesaturated(true)
                            castBar:SetStatusBarColor(unpack(castBarCastColor))
                        end
                    end
                else
                    currentValue = currentValue + stepValue
                    -- Check if the cast is completed
                    if currentValue >= maxValue then
                        -- Reset current value
                        currentValue = minValue
                        -- Determine if the cast type should change
                        if math.random() <= uninterruptibleChance then
                            castType = "uninterruptible"
                        elseif math.random() <= channeledChance then
                            castType = "channeled"
                            isChanneled = true
                            currentValue = maxValue
                        else
                            castType = "normal"
                        end

                        if castType == "uninterruptible" then
                            castBar.BorderShield:SetAlpha(1)
                            if useCustomCastbarTexture then
                                castBar:SetStatusBarTexture(nonInterruptibleTexturePath)
                            else
                                castBar:SetStatusBarTexture("ui-castingbar-uninterruptable")
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(false)
                                castBar:SetStatusBarColor(0.6,0.6,0.6,1)
                            end
                            castBar.castText:SetText("Shattering Throw")
                            if showCastBarIconWhenNoninterruptible then
                                castBar.Icon:SetTexture(GetSpellTexture(64382))
                                castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
                                castBar.Icon:SetDrawLayer("OVERLAY", 7)
                            else
                                --castBar.Icon:Hide()
                                castBar.Icon:SetTexture(GetSpellTexture(64382))
                                castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
                                castBar.Icon:SetDrawLayer("OVERLAY", 7)
                            end
                            if useCustomCastbarTexture or castBarRecolor then
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(true)
                                castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
                            end
                        elseif castType == "channeled" then
                            castBar.BorderShield:SetAlpha(0)
                            if useCustomCastbarTexture then
                                castBar:SetStatusBarTexture(texturePath)
                            else
                                castBar:SetStatusBarTexture("ui-castingbar-filling-channel")
                                local castBarTexture = castBar:GetStatusBarTexture()
                                if classic then
                                    castBar:SetStatusBarColor(0,1,0,1)
                                else
                                    castBarTexture:SetDesaturated(false)
                                    castBar:SetStatusBarColor(1,1,1,1)
                                end
                            end
                            castBar.castText:SetText("Penance")
                            castBar.Icon:Show()
                            castBar.Icon:SetTexture(GetSpellTexture(47540))
                            if useCustomCastbarTexture or castBarRecolor then
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(true)
                                castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                            end
                        else
                            castBar.BorderShield:SetAlpha(0)
                            if useCustomCastbarTexture then
                                castBar:SetStatusBarTexture(texturePath)
                            else
                                castBar:SetStatusBarTexture("ui-castingbar-filling-standard")
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(false)
                                castBar:SetStatusBarColor(1,1,1,1)
                            end
                            castBar.castText:SetText("Frostbolt")
                            castBar.Icon:Show()
                            castBar.Icon:SetTexture(GetSpellTexture(116))
                            castBar:SetStatusBarColor(1,0.7,0)
                            if useCustomCastbarTexture or castBarRecolor then
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(true)
                                castBar:SetStatusBarColor(unpack(castBarCastColor))
                            end
                        end
                    end
                end
                castBar:SetValue(currentValue)
            end)
            -- Store the timer object
            table.insert(timers, castBar.tickTimer)
        end
    end
end

local function OnEvent(self, event, unit)
    local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlateFrame then
        local frame = namePlateFrame.UnitFrame
        if frame then
            NamePlateCastBarTestMode(frame)
            -- Add this nameplate to the tracking table
            table.insert(nameplates, namePlateFrame)
        end
    end
end

function BBP.nameplateCastBarTestMode()
    -- Clear existing nameplates
    wipe(nameplates)

    temporaryNpCastTest:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    temporaryNpCastTest:SetScript("OnEvent", OnEvent)

    -- Populate nameplates table
    nameplates = C_NamePlate.GetNamePlates()

    for _, nameplate in ipairs(nameplates) do
        local frame = nameplate.UnitFrame
        NamePlateCastBarTestMode(frame)
    end
end

function BBP.cancelTimers()
    for _, timer in ipairs(timers) do
        timer:Cancel()
        timer = nil
    end
    -- Clear the timers table
    wipe(timers)
    -- Hide cast bars when canceling timers
    for _, nameplate in ipairs(nameplates) do
        local frame = nameplate.UnitFrame
        if frame then
            local castBar = frame.CastBar
            if castBar then
                castBar:Hide()
                if castBar.tickTimer then
                    castBar.tickTimer:Cancel()
                    castBar.tickTimer = nil
                end
            end
            if frame.dummyTimer then
                frame.dummyTimer:SetText("")
                frame.dummyTimer = nil
            end
            if frame.dummyNameText then
                frame.dummyNameText:SetText("")
                frame.dummyNameText = nil
            end
        end
    end
    temporaryNpCastTest:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
end


-- ill clean this a bit for nonbeta
BBP.UpdateMessageWindow = BBP.UpdateMessageWindow or nil
function BBP.CreateUpdateMessageWindow()
    if BBP.UpdateMessageWindow then
        BBP.UpdateMessageWindow:Show()
        return
    end
    local function CreateScrollingMessageFrame(parentFrame)
        local scrollingFrame = CreateFrame("ScrollFrame", nil, parentFrame, "UIPanelScrollFrameTemplate")
        scrollingFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, -60)
        scrollingFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -30, 37)

        local content = CreateFrame("Frame", nil, scrollingFrame)
        scrollingFrame:SetScrollChild(content)
        content.fontStrings = {}
        content.icons = {}
        content.yOffset = 0 -- Starting Y offset for the first line

        function content:AddMessage(iconPath, message, note, lineSpacing, xOffset, yOffset, font, size)
            local iconXOffset = xOffset or 12
            local iconYOffset = yOffset or 0
            local textSpacing = lineSpacing or 0

            -- Create an icon texture
            local icon = content:CreateTexture(nil, "OVERLAY")
            icon:SetAtlas(iconPath)
            icon:SetSize(size or 16, size or 16) -- You can adjust the size if needed
            icon:SetPoint("TOPLEFT", content, "TOPLEFT", iconXOffset+4, self.yOffset + iconYOffset-1)
            table.insert(self.icons, icon)

            -- Create a font string for text
            local text = content:CreateFontString(nil, "OVERLAY", font or "GameFontNormalMed1")
            text:SetJustifyH("LEFT")
            text:SetWidth(scrollingFrame:GetWidth() - 40) -- Adjust width to leave space for the icon
            text:SetPoint("TOPLEFT", content, "TOPLEFT", iconXOffset + 20, self.yOffset)
            table.insert(self.fontStrings, text)

            -- Apply color and concatenate message with note if needed
            local fullMessage = message
            if note then
                fullMessage = message .. " |cff7E7E7E" .. note .. "|r"  -- 'ffffff00' is the color yellow. Change as needed.
            end
            text:SetText(fullMessage)

            -- Update yOffset for the next line
            self.yOffset = self.yOffset - text:GetStringHeight() - textSpacing

            -- Update content frame size to fit all messages
            local totalHeight = -self.yOffset
            content:SetSize(scrollingFrame:GetWidth(), totalHeight)
            scrollingFrame:UpdateScrollChildRect()
        end

        return content
    end



    -- Example of how to use the scrolling message frame
    BBP.UpdateMessageWindow = CreateFrame("Frame", "BBPUpdate", UIParent, "PortraitFrameTemplate")
    BBP.UpdateMessageWindow:SetSize(450,300)
    BBP.UpdateMessageWindow.Bg:SetDesaturated(true)
    BBP.UpdateMessageWindow.Bg:SetVertexColor(0.5,0.5,0.5, 0.98)
    local screenHeight = UIParent:GetHeight() -- Get the screen height
    local yOffset = screenHeight * -0.10 -- Calculate 20% from the top. Negative because we're moving up.
    BBP.UpdateMessageWindow:ClearAllPoints() -- Clear any existing points
    BBP.UpdateMessageWindow:SetPoint("TOP", UIParent, "TOP", 0, yOffset)
    BBP.UpdateMessageWindow:SetMovable(true)
    BBP.UpdateMessageWindow:EnableMouse(true)
    BBP.UpdateMessageWindow:RegisterForDrag("LeftButton")
    BBP.UpdateMessageWindow:Show()
    BBP.UpdateMessageWindow:SetScript("OnDragStart", BBP.UpdateMessageWindow.StartMoving)
    BBP.UpdateMessageWindow:SetScript("OnDragStop", BBP.UpdateMessageWindow.StopMovingOrSizing)
    BBP.UpdateMessageWindow:SetPortraitToAsset(135724)
    BBP.UpdateMessageWindow:SetTitle("Better|cff00c0ffBlizz|rPlates " .. addonUpdates)
    BBP.UpdateMessageWindow:SetFrameLevel(0)
    local testTitle = BBP.UpdateMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
    testTitle:SetText("Better|cff00c0ffBlizz|rPlates " ..addonUpdates.. " Update!")
    testTitle:SetPoint("TOP", BBP.UpdateMessageWindow, "TOP", 0, -32)

    local okButton = CreateFrame("Button", nil, BBP.UpdateMessageWindow, "GameMenuButtonTemplate")
    okButton:SetPoint("BOTTOM", BBP.UpdateMessageWindow, "BOTTOM", 0, 10) -- Adjust the position as needed
    okButton:SetSize(100, 25) -- Width and height of the button
    okButton:SetText("OK")
    okButton:SetNormalFontObject("GameFontNormal")
    okButton:SetHighlightFontObject("GameFontHighlight")

    -- Script to close/hide the window when 'OK' is clicked
    okButton:SetScript("OnClick", function(self)
        BBP.UpdateMessageWindow:Hide()
    end)

    BBP.UpdateMessageWindow.textureTest = BBP.UpdateMessageWindow:CreateTexture(nil, "BACKGROUND") -- Ensure this is below the "ARTWORK" layer
    BBP.UpdateMessageWindow.textureTest:SetAtlas("communities-widebackground")
    BBP.UpdateMessageWindow.textureTest:SetSize(445, 150) -- Example size, set this to what you need
    BBP.UpdateMessageWindow.textureTest:SetPoint("TOP", BBP.UpdateMessageWindow, "TOP", 0, -15)

    -- Create a mask texture object
    local maskTexture = BBP.UpdateMessageWindow:CreateMaskTexture()
    maskTexture:SetAtlas("Azerite-CenterBG-ChannelGlowBar-FillingMask")
    maskTexture:SetSize(645, 300) -- Match the size of the textureTest or your needs
    --maskTexture:SetAllPoints(test.textureTest) -- Ensure mask is centered on the texture
    maskTexture:SetPoint("CENTER", BBP.UpdateMessageWindow.textureTest, "CENTER", 0, 50)

    BBP.UpdateMessageWindow.textureTest:AddMaskTexture(maskTexture)
    local scrollingMessageFrame = CreateScrollingMessageFrame(BBP.UpdateMessageWindow)

    -- Adding messages
    scrollingMessageFrame:AddMessage("QuestNormal", "New Stuff:", nil, 5, -3, 3, "GameFontNormalMed2", 16)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Sort Enlarged & Compacted Auras (reversed ver)", "(Nameplate Auras)", 2)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Castbar Edge Highlighter now uses seconds instead of percentages", "(Castbar)", 2)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Party pointer healer icon replace setting", "(Advanced Settings)", 14)

    scrollingMessageFrame:AddMessage("Professions-Crafting-Orders-Icon", "Bugfixes and Tweaks:", nil, 5, -4, 2, "GameFontNormalMed2", 16)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fixed some npc casts not triggering castbar customization", nil, 2)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Totem indicator icon now moves on top of np resource (if enabled) when targeting a totem", nil, 2)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fixed Friendly NP color player/npc toggle resetting on reload", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fix personal Nameplate Aura filtering issues", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fixed a Blizzard bug:\nIf Nameplate Resource CVar is on then nameplate auras get pushed up 18 pixels by default but this used to happen even on specs that don't have a nameplate resource. This is fixed now.", nil, 14)

    -- scrollingMessageFrame:AddMessage("GarrisonTroops-Health", "Note from Developer:", nil, 5, 3, 0, "GameFontNormalMed2", 12)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Thank you for all the love. Thanks to all users and especially beta testers and Patreon supporters.\nVery motivating thank you!<3", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "If you run into any bugs please report them!", nil, 2)
end

function BBP.ToggleUpdateMessageWindow()
    if not BBP.UpdateMessageWindow then
        BBP.CreateUpdateMessageWindow()
    elseif BBP.UpdateMessageWindow:IsShown() then
        BBP.UpdateMessageWindow:Hide()
    else
        BBP.UpdateMessageWindow:Show()
    end
end

local hookedHpHeight
function BBP.HookHealthbarHeight()
    -- if not hookedHpHeight then
    --     hooksecurefunc("DefaultCompactNamePlateFrameAnchorInternal", function(frame)
    --         if frame:IsForbidden() or frame:IsProtected() then return end
    --         local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
    --         if not config then return end
    --         if not frame.unit then return end
    --         if UnitCanAttack(frame.unit, "player") then
    --             frame.healthBar:SetHeight(config.hpHeightEnemy or 11)
    --         else
    --             frame.healthBar:SetHeight(config.hpHeightFriendly or 11)
    --         end
    --     end)

    --     hookedHpHeight = true
    -- end
end

-- local spellbar = CreateFrame("StatusBar", "PlayerBBPSpellbar", UIParent, "SmallCastingBarFrameTemplate")
-- spellbar:SetScale(1)

-- spellbar:SetUnit("player", true, true)
-- spellbar.Text:ClearAllPoints()
-- spellbar.Text:SetPoint("CENTER", spellbar, "BOTTOM", 0, -5.5)
-- spellbar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
-- spellbar.Icon:ClearAllPoints()
-- spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4, -5)
-- spellbar.Icon:SetSize(22,22)
-- spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
-- spellbar.BorderShield:ClearAllPoints()
-- spellbar.BorderShield:SetPoint("RIGHT", spellbar, "LEFT", -1, -7)
-- spellbar.BorderShield:SetSize(29,33)
-- spellbar.BorderShield:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
-- spellbar:SetScale(1)
-- spellbar:SetWidth(130)
-- spellbar:SetHeight(8)

-- spellbar.Timer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
-- spellbar.Timer:SetPoint("LEFT", spellbar, "RIGHT", 3, 0)
-- spellbar.Timer:SetTextColor(1, 1, 1, 1)

-- spellbar.FakeTimer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
-- spellbar.FakeTimer:SetPoint("LEFT", spellbar, "RIGHT", 3, 0)
-- spellbar.FakeTimer:SetTextColor(1, 1, 1, 1)
-- spellbar.FakeTimer:SetText("1.8")
-- spellbar.FakeTimer:Hide()

-- Mixin(spellbar, SmoothStatusBarMixin)
-- spellbar:SetMinMaxSmoothedValue(0, 100)

-- function temp()
--     --local nameplate, frame = BBP.GetSafeNameplate("player")
--     local frame = ClassNameplateManaBarFrame
--     if frame then
--         spellbar:SetParent(frame)
--         spellbar:ClearAllPoints()
--         spellbar:SetPoint("TOP", frame, "BOTTOM",0, -2)
--     end
-- end







-- -- Create the frame for the slider
-- local sliderFrame = CreateFrame("Frame", "CastBarAdjuster", UIParent)
-- sliderFrame:SetSize(200, 100)
-- sliderFrame:SetPoint("CENTER")


-- -- Create the slider
-- local slider = CreateFrame("Slider", "CastBarSlider", sliderFrame, "OptionsSliderTemplate")
-- slider:SetOrientation('HORIZONTAL')
-- slider:SetSize(150, 15)
-- slider:SetPoint("CENTER", sliderFrame, "CENTER", 0, 0)
-- slider:SetMinMaxValues(60, 200) -- Min and Max values for scaling
-- slider:SetValueStep(0.1)
-- slider:SetValue(1) -- Default value

-- -- Slider label
-- CastBarSliderLow:SetText('0.5')
-- CastBarSliderHigh:SetText('2')
-- CastBarSliderText:SetText('Cast Bar Scale')

-- -- Function to update the cast bar size
-- local function UpdateCastBarScale()
--     local scale = slider:GetValue()
--     local namePlate = C_NamePlate.GetNamePlateForUnit("target")
--     if namePlate then
--         local castBar = namePlate.UnitFrame.CastBar
--         if castBar then
--             castBar:SetWidth(scale)
--         end
--     end
-- end

-- -- Hook the slider value change event
-- slider:SetScript("OnValueChanged", UpdateCastBarScale)

-- -- Create a frame to monitor the target change
-- local targetFrame = CreateFrame("Frame")
-- targetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
-- targetFrame:SetScript("OnEvent", function(self, event, ...)
--     UpdateCastBarScale()
-- end)
