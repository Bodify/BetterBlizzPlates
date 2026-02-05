if not BBP.isMidnight then return end
-- I did not know what a variable was when I started. I know a little bit more now and I am so sorry.

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("statusbar", "Blizzard DF", [[Interface\TargetingFrame\UI-TargetingFrame-BarFill]])
LSM:Register("statusbar", "Dragonflight (BBP)", [[Interface\Addons\BetterBlizzPlates\media\DragonflightTexture]])
LSM:Register("statusbar", "Dragonflight HD (BBP)", [[Interface\Addons\BetterBlizzPlates\media\DragonflightTextureHD]])
LSM:Register("statusbar", "Shattered DF (BBP)", [[Interface\Addons\BetterBlizzPlates\media\focusTexture]])
LSM:Register("statusbar", "Checkered (BBP)", [[Interface\Addons\BetterBlizzPlates\media\targetTexture]])
LSM:Register("statusbar", "Smooth", [[Interface\Addons\BetterBlizzPlates\media\smooth]])
LSM:Register("statusbar", "Blizzard Retail Bar", [[Interface\AddOns\BetterBlizzPlates\media\blizzTex\BlizzardRetailBar]])
LSM:Register("statusbar", "Blizzard Retail Bar Crop", [[Interface\AddOns\BetterBlizzPlates\media\blizzTex\BlizzardRetailBarCrop]])
LSM:Register("statusbar", "Blizzard Retail Bar Crop 2", [[Interface\AddOns\BetterBlizzPlates\media\blizzTex\BlizzardRetailBarCrop2]])
local allLocales = LSM.LOCALE_BIT_western+LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_zhCN+LSM.LOCALE_BIT_zhTW+LSM.LOCALE_BIT_koKR
LSM:Register("font", "Yanone (BBP)", [[Interface\Addons\BetterBlizzPlates\media\YanoneKaffeesatz-Medium.ttf]], allLocales)
LSM:Register("font", "Prototype", [[Interface\Addons\BetterBlizzPlates\media\Prototype.ttf]], allLocales)

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = C_AddOns.GetAddOnMetadata("BetterBlizzPlates", "Version")
local sendUpdate = false
BBP.VersionNumber = addonUpdates
local _, playerClass
local playerClassColor
BBP.hiddenFrame = CreateFrame("Frame")
BBP.hiddenFrame:Hide()

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
BBP.OverlayFrame = CreateFrame("Frame", nil, WorldFrame)
-- BBP.OverlayFrame:SetFrameStrata("DIALOG")
-- BBP.OverlayFrame:SetFrameLevel(50000)

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
    setCVarAcrossAllCharacters = true,
    -- General
    removeRealmNames = true,
    hideNameplateAuras = false,
    hideTargetHighlight = false,
    nameplateShowEnemyMinus = nil,
    enemyNameplateHealthbarHeight = nil,
    fadeOutNPC = false,
    hideNPC = false,
    hideNPCWhitelistOn = false,
    hideNPCArenaOnly = false,
    hideNPCHideSecondaryPets = true,
    hideNPCSecondaryShowMurloc = true,
    hideNPCHideOthersPets = true,
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
    --friendlyHideHealthBarNpc = true,
    nameplateResourceScale = 1,
    darkModeNameplateColor = 0.2,
    fakeNameXPos = 0,
    fakeNameYPos = 0,
    fakeNameFriendlyXPos = 0,
    fakeNameFriendlyYPos = 0,
    fakeNameAnchor = "BOTTOM",
    fakeNameAnchorRelative = "TOP",
    fakeNameScaleWithParent = false,
    fakeNameRaiseStrata = false,
    guildNameColorRGB = {0, 1, 0},
    npcTitleColorRGB = {1, 0.85, 0},
    npcTitleScale = 1,
    hideNpcMurlocScale = 1,
    hideNpcMurlocYPos = 0,
    partyPointerWidth = 36,
    changeHealthbarHeight = false,
    hpHeightEnemy = 4 * 2.7,--tonumber(GetCVar("NamePlateVerticalScale")),
    hpHeightFriendly = 4 * 2.7,--tonumber(GetCVar("NamePlateVerticalScale")),
    hpHeightSelf = 4 * 2.7,--tonumber(GetCVar("NamePlateVerticalScale")),
    hpHeightSelfMana = 4 * 2.7,--tonumber(GetCVar("NamePlateVerticalScale")),
    hideLevelFrame = true,
    druidOverstacks = true,
    personalBarPosition = 0.5,
    alwaysShowPurgeTexture = true,
    levelFrameFontSize = 12,
    nameplateExtraClickHeight = 0,
    nameplateVerticalPosition = 0,
    nameplateHorizontalPosition = 0,

    nameplateShadowRGB = {0,0,0,1},
    nameplateShadowHighlightRGB = {1,1,1,1},
    --health numbers
    healthNumbersPlayers = true,
    healthNumbersNpcs = true,
    healthNumbers = false,
    healthNumbersAnchor = "CENTER",
    healthNumbersXPos = 0,
    healthNumbersYPos = 0,
    healthNumbersScale = 1,
    healthNumbersFontOutline = "THICKOUTLINE",
    healthNumbersUseMillions = true,
    healthNumbersJustify = "CENTER",
    nameplateBorderSize = 1,
    nameplateTargetBorderSize = 3,
    nameplatePersonalBorderSize = 1,
    tankFullAggroColorRGB = {0, 1, 0, 1},
    tankOffTankAggroColorRGB = {0, 0.95, 1, 1},
    tankLosingAggroColorRGB = {1, 0.47, 0, 1},
    tankNoAggroColorRGB = {1, 0, 0, 1},
    dpsOrHealFullAggroColorRGB = {1, 0, 0, 1},
    dpsOrHealNoAggroColorRGB = {0, 1, 0, 1},
    npBgColorRGB = {1, 1, 1, 1},
    smallPetsWidth = 20,
    enlargeAllImportantBuffs = true,
    enlargeAllCC = true,
    normalCastbarForEmpoweredCasts = true,
    interruptedByIndicator = true,
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
    npBorderFocusColorRGB = {0, 0, 0, 1},
    -- Bg Indicator
    bgIndicatorAnchor = "BOTTOM",
    bgIndicatorScale = 1,
    bgIndicatorXPos = 0,
    bgIndicatorYPos = 0,
    bgIndicatorEnemyOnly = true,
    bgIndicatorShowOrbs = true,
    bgIndicatorShowFlags = true,
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
    arenaIndicatorBg = true,
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
    executeIndicatorInRangeColorRGB = {0,1,0.8,1},
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
    classIndicatorCCAuras = true,
    classIndicatorXPos = 0,
    classIndicatorFriendlyXPos = 0,
    classIndicatorYPos = 0,
    classIndicatorFriendlyYPos = 0,
    classIndicatorAnchor = "TOP",
    classIndicatorFriendlyAnchor = "TOP",
    classIndicatorScale = 1,
    classIndicatorAlpha = 1,
    classIndicatorFriendlyScale = 1.45,
    --classIndicatorEnemy = true,
    classIndicatorFriendly = true,
    classIconColorBorder = true,
    classIndicatorHideRaidMarker = true,
    classIndicatorHighlight = true,
    --classIndicatorHighlightColor = true,
    --classIconAlwaysShowHealer = true,
    classIconAlwaysShowBgObj = true,
    classIndicatorBackground = true,
    --classIndicatorHideFriendlyHealthbar = true,
    --classIndicatorPinMode = true,
    classIconEnemyHealIcon = true,
    --classIconAlwaysShowTank = true,
    classIndicatorTank = true,
    classIndicatorHealer = true,
    classIndicatorBackgroundSize = 1,
    classIndicatorBackgroundRGB = {0,0,0,1},
    classIconHealerIconType = 2,
    classIndicatorShowPet = true,
    -- Party Pointer
    partyPointerXPos = 0,
    partyPointerYPos = 0,
    partyPointerScale = 1,
    partyPointerHealerScale = 1.3,
    partyPointerAnchor = "TOP",
    partyPointerClassColor = true,
    partyPointerHideRaidmarker = true,
    partyPointerHealerReplace = true,
    partyPointerShowPet = true,
    partyPointerTexture = 1,
    partyPointerCCAuras = true,
    partyPointerHighlightRGB = {1,0.71,0},
    partyPointerHighlightScale = 1,
    --partyPointerArenaOnly = true,
    -- Pet Indicator
    petIndicator = false,
    petIndicatorScale = 1,
    petIndicatorXPos = 0,
    petIndicatorYPos = 0,
    petIndicatorAnchor = "CENTER",
    petIndicatorTestMode = false,
    petIndicatorShowMurloc = true,
    petIndicatorHideSecondaryPets = true,
    -- Target Indicator
    targetIndicator = false,
    targetIndicatorScale = 1,
    targetIndicatorXPos = 0,
    targetIndicatorYPos = 0,
    targetIndicatorAnchor = "TOP",
    targetIndicatorTestMode = false,
    targetIndicatorColorNameplateRGB = {1, 0, 0.44},
    petIndicatorColorHealthbarRGB = {0.03,0.35,0},
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
    totemIndicatorEnemyOnly = true,
    totemIndicatorDefaultCooldownTextSize = 0.85,
    showTotemIndicatorCooldownSwipe = true,
    totemIndicatorHideAuras = false,
    totemIndicatorNpcList = {
        [59764] =   { name = "Healing Tide Totem", icon = C_Spell.GetSpellTexture(108280),              hideIcon = false, size = 30, duration = 10, color = {0, 1, 0.39}, important = true },
        [59712] =   { name = "Stone Bulwark Totem", icon = C_Spell.GetSpellTexture(108270),             hideIcon = false, size = 30, duration = 30, color = {0.98, 0.75, 0.17}, important = true },
        [5925] =    { name = "Grounding Totem", icon = C_Spell.GetSpellTexture(204336),                 hideIcon = false, size = 30, duration = 3,  color = {1, 0, 1}, important = true },
        [53006] =   { name = "Spirit Link Totem", icon = C_Spell.GetSpellTexture(98008),                hideIcon = false, size = 30, duration = 6,  color = {0, 1, 0.78}, important = true },
        [5913] =    { name = "Tremor Totem", icon = C_Spell.GetSpellTexture(8143),                      hideIcon = false, size = 30, duration = 13, color = {0.49, 0.9, 0.08}, important = true },
        [104818] =  { name = "Ancestral Protection Totem", icon = C_Spell.GetSpellTexture(207399),      hideIcon = false, size = 30, duration = 33, color = {0, 1, 0.78}, important = true },
        --11.1 removed [119052] =  { name = "War Banner", icon = C_Spell.GetSpellTexture(236320),                      hideIcon = false, size = 30, duration = 15, color = {1, 0, 1}, important = true },
        [61245] =   { name = "Capacitor Totem", icon = C_Spell.GetSpellTexture(192058),                 hideIcon = false, size = 30, duration = 2,  color = {1, 0.69, 0}, important = true },
        [105451] =  { name = "Counterstrike Totem", icon = C_Spell.GetSpellTexture(204331),             hideIcon = false, size = 30, duration = 15, color = {1, 0.27, 0.59}, important = true },
        [101398] =  { name = "Psyfiend", icon = C_Spell.GetSpellTexture(199824),                        hideIcon = false, size = 35, duration = 12, color = {0.49, 0, 1}, important = true },
        [225672] =  { name = "Shadow", icon = C_Spell.GetSpellTexture(8122),                            hideIcon = false, size = 35, duration = 4,  color = {0.78, 0.48, 1}, important = true },
        [100943] =  { name = "Earthen Wall Totem", icon = C_Spell.GetSpellTexture(198838),              hideIcon = false, size = 30, duration = 18, color = {0.78, 0.49, 0.35}, important = true },
        --11.1 removed [107100] =  { name = "Observer", icon = C_Spell.GetSpellTexture(112869),                        hideIcon = false, size = 30, duration = 20, color = {1, 0.69, 0}, important = true },
        [135002] =  { name = "Tyrant", icon = C_Spell.GetSpellTexture(265187),                          hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
        [114565] =  { name = "Guardian of the Forgotten Queen", icon = C_Spell.GetSpellTexture(228049), hideIcon = false, size = 30, duration = 10, color = {1, 0, 1}, important = true },
        [107024] =  { name = "Fel Lord", icon = C_Spell.GetSpellTexture(212459),                        hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
        -- PvP Battleground Health Flags
        [14465] =   { name = "Alliance Battle Standard", icon = 132486,                                 hideIcon = false, size = 24, duration = nil, color = {0, 0.22, 1}, important = true },
        [14466] =   { name = "Horde Battle Standard", icon = 132485,                                    hideIcon = false, size = 24, duration = nil, color = {1, 0, 0}, important = true },
        -- Less important
        --[103673] =  { name = "Darkglare", icon = C_Spell.GetSpellTexture(205180),                       hideIcon = false, size = 24, duration = 20, color = {1, 0, 0}, important = false},
        [224466] =  { name = "Voidwraith", icon = C_Spell.GetSpellTexture(451234),                      hideIcon = false, size = 24, duration = 15, color = {1, 0.69, 0}, important = false },
        [89] =      { name = "Infernal", icon = C_Spell.GetSpellTexture(1122),                          hideIcon = false, size = 24, duration = 30, color = {1, 0.69, 0}, important = false },
        [196111] =  { name = "Pit Lord", icon = C_Spell.GetSpellTexture(138789),                        hideIcon = false, size = 24, duration = 10, color = {1, 0.69, 0}, important = false },
        [3527] =    { name = "Healing Stream Totem", icon = C_Spell.GetSpellTexture(5394),              hideIcon = false, size = 24, duration = 18, color = {0, 1, 0.78}, important = false },
        [78001] =   { name = "Cloudburst Totem", icon = C_Spell.GetSpellTexture(157153),                hideIcon = false, size = 24, duration = 15, color = {0, 1, 0.39}, important = false },
        --11.1 removed [10467] =   { name = "Mana Tide Totem", icon = C_Spell.GetSpellTexture(16191),                  hideIcon = false, size = 24, duration = 8,  color = {0.08, 0.82, 0.78}, important = false },
        [97285] =   { name = "Wind Rush Totem", icon = C_Spell.GetSpellTexture(192077),                 hideIcon = false, size = 24, duration = 18, color = {0.08, 0.82, 0.78}, important = false },
        [60561] =   { name = "Earthgrab Totem", icon = C_Spell.GetSpellTexture(51485),                  hideIcon = false, size = 24, duration = 30, color = {0.75, 0.31, 0.10}, important = false },
        [2630] =    { name = "Earthbind Totem", icon = C_Spell.GetSpellTexture(2484),                   hideIcon = false, size = 24, duration = 30, color = {0.78, 0.51, 0.39}, important = false },
        [105427] =  { name = "Totem of Wrath", icon = C_Spell.GetSpellTexture(204330),                  hideIcon = false, size = 24, duration = 15, color = {1, 0.27, 0.59}, important = false },
        [97369] =   { name = "Liquid Magma Totem", icon = C_Spell.GetSpellTexture(192222),              hideIcon = false, size = 24, duration = 6,  color = {1, 0.69, 0}, important = false },
        [62982] =   { name = "Mindbender", icon = C_Spell.GetSpellTexture(123040),                      hideIcon = false, size = 24, duration = 15, color = {1, 0.69, 0}, important = false },
        [19668] =   { name = "Shadowfiend", icon = C_Spell.GetSpellTexture(34433),                      hideIcon = false, size = 24, duration = 15, color = {1, 0.69, 0}, important = false },
        [179867] =  { name = "Static Field Totem", icon = C_Spell.GetSpellTexture(355580),              hideIcon = false, size = 24, duration = 6,  color = {0, 1, 0.78}, important = false },
        [194117] =  { name = "Stoneskin Totem", icon = C_Spell.GetSpellTexture(383017),                 hideIcon = false, size = 24, duration = 15, color = {0.78, 0.49, 0.35}, important = false },
        [5923] =    { name = "Poison Cleansing Totem", icon = C_Spell.GetSpellTexture(383013),          hideIcon = false, size = 24, duration = 9,  color = {0.49, 0.9, 0.08}, important = false },
        [194118] =  { name = "Tranquil Air Totem", icon = C_Spell.GetSpellTexture(383019),              hideIcon = false, size = 24, duration = 20, color = {0, 1, 0.78}, important = false },
        [225409] =  { name = "Surging Totem", icon = C_Spell.GetSpellTexture(444995),                   hideIcon = false, size = 24, duration = 24, color = {1, 0.36, 0}, important = false },
        [65282] =   { name = "Void Tendril", icon = C_Spell.GetSpellTexture(108920),                    hideIcon = false, size = 24, duration = 6,  color = {0.33, 0.35, 1}, important = false },
        [185800] =  { name = "Past Self", icon = C_Spell.GetSpellTexture(371869),                       hideIcon = false, size = 24, duration = 8,  color = {1, 0, 0}, important = false }
    },
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
    importantCCFullGlow = true,
    importantCCSilenceGlow = true,
    importantBuffsOffensivesGlow = true,
    importantBuffsDefensivesGlow = true,
    importantBuffsMobilityGlow = true,
    importantCCFullGlowRGB = {r = 1, g = 0.874, b = 0, a = 1},
    importantCCDisarmGlowRGB = {r = 1, g = 0.874, b = 0, a = 1},
    importantCCRootGlowRGB = {r = 1, g = 0.874, b = 0, a = 1},
    importantCCSilenceGlowRGB = {r = 1, g = 0.874, b = 0, a = 1},
    importantBuffsOffensivesGlowRGB = {r = 1, g = 0.5, b = 0, a = 1},
    importantBuffsDefensivesGlowRGB = {r = 1, g = 0.662, b = 0.945, a = 1},
    importantBuffsMobilityGlowRGB = {r = 0, g = 1, b = 1, a = 1},
    nameplateKeyAurasXPos = 0,
    nameplateKeyAurasYPos = 0,
    nameplateKeyAuraScale = 1,
    nameplateKeyAurasHorizontalGap = 5,
    nameplateKeyAurasAnchor = "RIGHT",
    keyAurasImportantGlowOn = true,
    keyAurasImportantBuffsEnabled = true,
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
    showInterruptsOnNameplateAuras = true,
    nameplateAurasCenteredAnchor = false,
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
    nameplateAuraTypeGap = 0,
    nameplateAurasYPos = 0,
    nameplateAurasXPos = 0,
    nameplateAurasPersonalXPos = 0,
    nameplateAurasPersonalYPos = 0,
    nameplateAuraAnchor = "BOTTOMLEFT",
    nameplateAuraRelativeAnchor = "TOPLEFT",
    nameplateAurasNoNameYPos = 0,
    nameplateAuraScale = 1,
    nameplateAuraSelfScale = 1,
    nameplateAuraBuffSelfScale = 1,
    nameplateAuraDebuffSelfScale = 1,
    hideDefaultPersonalNameplateAuras = false,
    separateAuraBuffRow = true,
    importantCCFull = true,
    importantCCDisarm = true,
    importantCCRoot = true,
    importantCCSilence = true,
    importantBuffsOffensives = true,
    importantBuffsDefensives = true,
    importantBuffsMobility = true,
    defaultNpAuraCdSize = 0.5,
    onlyPandemicAuraMine = true,
    nameplateAuraEnlargedScale = 1,
    nameplateAuraCompactedScale = 1,
    nameplateAuraEnlargedSquare = true,
    nameplateAuraCompactedSquare = true,
    nameplateAuraBuffScale = 1,
    nameplateAuraDebuffScale = 1,
    sortEnlargedAurasFirst = true,
    npAuraDiseaseRGB = {1,0.53,0.14},
    npAuraOtherRGB = {0,0,0},
    npAuraCurseRGB = {0.47,0,0.78},
    npAuraBuffsRGB = {0,0.67,1},
    npAuraPoisonRGB = {0,0.52,0.031},
    npAuraMagicRGB = {0.13,0.44,1},
    personalNpBuffEnable = true,
    personalNpBuffFilterAll = false,
    personalNpBuffFilterBlizzard = true,
    personalNpBuffFilterWatchList = true,
    personalNpBuffFilterLessMinite = false,
    personalNpBuffFilterOnlyMe = false,

    personalNpdeBuffEnable = false,
    personalNpdeBuffFilterAll = false,
    personalNpdeBuffFilterWatchList = true,
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
    friendlyNpdeBuffFilterCC = true,

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
    nameplateNonTargetAlpha = 0.5,
    enableNpNonTargetAlphaTargetOnly = true,

    -- Fade out NPCs
    fadeOutNPCsAlpha = 0.2,
    fadeOutNPCOnlyFadeSecondaryPets = true,

    defaultFadeOutNPCsList = {
        {name = "Hunter Pet (they all have same ID)", id = 165189, comment = ""},
        {name = "DK Pet", id = 26125, comment = ""},
        {name = "Magus(Army of the Dead)", id = 148797, comment = ""},
        {name = "Magus(Army of the Dead)", id = 163366, comment = ""},
        {name = "Army of the Dead", id = 24207, comment = ""},
        {name = "Felguard (Demo Pet)", id = 17252, comment = ""},
        {name = "Spirit Wolves (Enha Shaman)", id = 29264, comment = ""},
        {name = "Earth Elemental (Shaman)", id = 95072, comment = ""},
        {name = "Greater Fire Elemental (Shaman)", id = 95061, comment = ""},
        {name = "Greater Storm Elemental (Shaman)", id = 77936, comment = ""},
        {name = "Mirror Images (Mage)", id = 31216, comment = ""},
        {name = "Beast (Hunter)", id = 62005, comment = ""},

        {name = "Fenryr (Hunter)", id = 228224, comment = ""},
        {name = "Hati (Hunter)", id = 228226, comment = ""},
        {name = "Dark Hound (Hunter)", id = 228226, comment = ""},
        {name = "Monk SEF Image (Red)", id = 69791, comment = ""},
        {name = "Monk SEF Image (Green)", id = 69792, comment = ""},

        {name = "Vilefiend (Warlock)", id = 135816, comment = ""},
        {name = "Gloomhound (Warlock)", id = 226268, comment = ""},
        {name = "Charhound (Warlock)", id = 226269, comment = ""},
        {name = "Treant", id = 103822, comment = ""},
        {name = "Whitemane (DK)", id = 221633, comment = ""},
        {name = "Mograine (DK)", id = 221632, comment = ""},
        {name = "Nazgrim (DK)", id = 221634, comment = ""},
        {name = "Trollbane (DK)", id = 221635, comment = ""},
        {name = "Water Elemental (Mage)", id = 208441, comment = ""},

        {name = "Dire Basilisk (Hunter)", id = 105419, comment = ""},
        {name = "Void Tendril (Spriest)", id = 192337, comment = ""},
        {name = "Illidari Satyr", id = 136398, comment = ""},
        {name = "Darkhound", id = 136408, comment = ""},
        {name = "Void Terror", id = 136403, comment = ""},
        {name = "Treant", id = 54983, comment = ""},
    },
    hideNPCsList = {
        {name = "Mirror Images (Mage)", id = 31216, comment = ""},
        {name = "Wild Imp (Warlock)", id = 55659, comment = ""},
        {name = "Wild Imp (Warlock)", id = 143622, comment = ""},
        {name = "Spirit Wolves (Shaman)", id = 29264, comment = "", flags = {murloc = true}},
        {name = "Monk SEF Image (Red)", id = 69791, comment = "", flags = {murloc = true}},
        {name = "Monk SEF Image (Green)", id = 69792, comment = "", flags = {murloc = true}},
        {name = "Water Elemental (Mage)", id = 208441, comment = "", flags = {murloc = true}},
    },
    hideNPCsWhitelist = {
        {name = "Hunter Pet (they all have same ID)", id = 165189, comment = ""},
        {name = "Healing Tide Totem", id = 59764, comment = ""},
        {name = "Grounding Totem", id = 5925, comment = ""},
        {name = "Spirit Link Totem", id = 53006, comment = ""},
        {name = "Tremor Totem", id = 5913, comment = ""},
        {name = "Ancestral Protection Totem", id = 104818, comment = ""},
        {name = "War Banner", id = 119052, comment = ""},
        {name = "Capacitor Totem", id = 61245, comment = ""},
        {name = "Counterstrike Totem", id = 105451, comment = ""},
        {name = "Psyfiend (Spriest)", id = 101398, comment = ""},
        {name = "Earthen Wall Totem", id = 100943, comment = ""},
        {name = "Observer (Warlock)", id = 107100, comment = ""},
        {name = "Tyrant (Warlock)", id = 135002, comment = ""},
        {name = "Guardian Queen (prot pala)", id = 114565, comment = ""},
        {name = "Healing Stream Totem", id = 3527, comment = ""},
        {name = "Cloudburst Totem", id = 78001, comment = ""},
        {name = "Mana Tide Totem", id = 10467, comment = ""},
        {name = "Wind Rush Totem", id = 97285, comment = ""},
        {name = "Earthgrab Totem", id = 60561, comment = ""},
        {name = "Earthbind Totem", id = 2630, comment = ""},
        {name = "Totem of Wrath", id = 105427, comment = ""},
        {name = "Liquid Magma Totem", id = 97369, comment = ""},
        {name = "Mindbender", id = 62982, comment = ""},
        {name = "Static Field Totem", id = 179867, comment = ""},
        {name = "Stoneskin Totem", id = 194117, comment = ""},
        {name = "Poison Cleansing Totem", id = 5923, comment = ""},
        {name = "Tranquil Air Totem", id = 194118, comment = ""},
        {name = "Felguard (Demo Pet)", id = 17252, comment = ""},
        {name = "Felhunter (Warlock)", id = 417, comment = ""},
        {name = "Succubus (Warlock)", id = 1863, comment = ""},
        {name = "Infernal (Warlock)", id = 89, comment = ""},
        {name = "Stone Bulwark Totem", id = 59712, comment = ""},
        {name = "Shadow (Priest Re-Fear)", id = 225672, comment = ""},
        {name = "Voidwraith (Priest)", id = 224466, comment = ""},
        {name = "Shadowfiend", id = 19668, comment = ""},
        {name = "Surging Totem", id = 225409, comment = ""}
    },
    fadeOutNPCsWhitelist = {
        {name = "Hunter Pet (they all have same ID)", id = 165189, comment = ""},
        {name = "Healing Tide Totem", id = 59764, comment = ""},
        {name = "Grounding Totem", id = 5925, comment = ""},
        {name = "Spirit Link Totem", id = 53006, comment = ""},
        {name = "Tremor Totem", id = 5913, comment = ""},
        {name = "Ancestral Protection Totem", id = 104818, comment = ""},
        {name = "War Banner", id = 119052, comment = ""},
        {name = "Capacitor Totem", id = 61245, comment = ""},
        {name = "Counterstrike Totem", id = 105451, comment = ""},
        {name = "Psyfiend (Spriest)", id = 101398, comment = ""},
        {name = "Earthen Wall Totem", id = 100943, comment = ""},
        {name = "Observer (Warlock)", id = 107100, comment = ""},
        {name = "Tyrant (Warlock)", id = 135002, comment = ""},
        {name = "Guardian Queen (prot pala)", id = 114565, comment = ""},
        {name = "Healing Stream Totem", id = 3527, comment = ""},
        {name = "Cloudburst Totem", id = 78001, comment = ""},
        {name = "Mana Tide Totem", id = 10467, comment = ""},
        {name = "Wind Rush Totem", id = 97285, comment = ""},
        {name = "Earthgrab Totem", id = 60561, comment = ""},
        {name = "Earthbind Totem", id = 2630, comment = ""},
        {name = "Totem of Wrath", id = 105427, comment = ""},
        {name = "Liquid Magma Totem", id = 97369, comment = ""},
        {name = "Mindbender", id = 62982, comment = ""},
        {name = "Static Field Totem", id = 179867, comment = ""},
        {name = "Stoneskin Totem", id = 194117, comment = ""},
        {name = "Poison Cleansing Totem", id = 5923, comment = ""},
        {name = "Tranquil Air Totem", id = 194118, comment = ""},
        {name = "Felguard (Demo Pet)", id = 17252, comment = ""},
        {name = "Felhunter (Warlock)", id = 417, comment = ""},
        {name = "Succubus (Warlock)", id = 1863, comment = ""},
        {name = "Infernal (Warlock)", id = 89, comment = ""},
        {name = "Stone Bulwark Totem", id = 59712, comment = ""},
        {name = "Shadow (Priest Re-Fear)", id = 225672, comment = ""},
        {name = "Voidwraith (Priest)", id = 224466, comment = ""},
        {name = "Shadowfiend", id = 19668, comment = ""},
        {name = "Surging Totem", id = 225409, comment = ""}
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
        {name = "Sleep Walk"},
        {name = "Fear"},
        {name = "Repentance"},
        {name = "Hex"},
        {name = "Ring of Frost"},
        {name = "Mass Polymorph"},
        {name = "Shadowfury"},
        {name = "Haymaker"},
        {name = "Mind Control"},
        {name = "Hibernate"},
        {name = "Scare Beast"},
        {name = "Lightning Lasso"},
        {name = "Song of Chi-Ji"},
        {name = "Ring of Fire"},
    },
    castBarEmphasisSelfColorRGB = {1,0,0},

    castBarInterruptHighlighter = false,
    castBarInterruptHighlighterColorDontInterrupt = false,
    castBarInterruptHighlighterInterruptRGB = {0, 1, 0},
    castBarInterruptHighlighterDontInterruptRGB = {0, 0, 0},
    castBarInterruptHighlighterStartTime = 0.8,
    castBarInterruptHighlighterEndTime = 0.6,

    nameplateResourceXPos = 0,
    nameplateResourceYPos = 0,

    ghostAuras = {},

    -- Midnight new additions
    ccIconScale = 1.35,
    buffIconScale = 1.35,
    nameplateExtraClickWidth = 0,

    ccIconAnchor = "RIGHT",
    ccIconXPos = 0,
    ccIconYPos = 0,
    buffIconAnchor = "LEFT",
    buffIconXPos = 0,
    buffIconYPos = 0

}


local function TempClassicNpFix()
    BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = 172.5, 65
    BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = 172.5, 65
    BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = 172.5, 65

    BetterBlizzPlatesDB.nameplateOverlapH = 0.8
    BetterBlizzPlatesDB.nameplateOverlapV = 1.1
    BetterBlizzPlatesDB.nameplateMotionSpeed = 0.025
    BetterBlizzPlatesDB.nameplateHorizontalScale = 1.4
    BetterBlizzPlatesDB.NamePlateVerticalScale = 2.7
    BetterBlizzPlatesDB.nameplateMinScale = 0.9
    BetterBlizzPlatesDB.nameplateMaxScale = 0.9
    BetterBlizzPlatesDB.nameplateSelectedScale = 1.2
    BetterBlizzPlatesDB.NamePlateClassificationScale = 1
    BetterBlizzPlatesDB.nameplateGlobalScale = 1
    BetterBlizzPlatesDB.nameplateLargerScale = 1.2
    BetterBlizzPlatesDB.nameplatePlayerLargerScale = 1.8
    --BetterBlizzPlatesDB.nameplateResourceOnTarget = "0"

    BetterBlizzPlatesDB.nameplateMinAlphaDistance = 10
    BetterBlizzPlatesDB.nameplateMaxAlpha = 1.0
    BetterBlizzPlatesDB.nameplateMaxAlphaDistance = 40
    BetterBlizzPlatesDB.nameplateSelfAlpha = 0.75

    BetterBlizzPlatesDB.nameplateShowClassColor = "1"
    BetterBlizzPlatesDB.nameplateShowFriendlyClassColor = "1"

    BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
    BetterBlizzPlatesDB.castBarHeight = 18.8
    BetterBlizzPlatesDB.largeNameplates = true

    C_CVar.SetCVar("nameplateOverlapH", BetterBlizzPlatesDB.nameplateOverlapH)
    C_CVar.SetCVar("nameplateOverlapV", BetterBlizzPlatesDB.nameplateOverlapV)
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
    --C_CVar.SetCVar("nameplateResourceOnTarget", BetterBlizzPlatesDB.nameplateResourceOnTarget)
    C_CVar.SetCVar("nameplateMinAlphaDistance", BetterBlizzPlatesDB.nameplateMinAlphaDistance)
    C_CVar.SetCVar("nameplateMaxAlpha", BetterBlizzPlatesDB.nameplateMaxAlpha)
    C_CVar.SetCVar("nameplateMaxAlphaDistance", BetterBlizzPlatesDB.nameplateMaxAlphaDistance)
    C_CVar.SetCVar("nameplateShowClassColor", BetterBlizzPlatesDB.nameplateShowClassColor)
    C_CVar.SetCVar("nameplateShowFriendlyClassColor", BetterBlizzPlatesDB.nameplateShowFriendlyClassColor)
    C_CVar.SetCVar("nameplateSelfAlpha", BetterBlizzPlatesDB.nameplateSelfAlpha)
    C_CVar.SetCVar('nameplateShowOnlyNames', "0")
end

local function InitializeSavedVariables()
    if not BetterBlizzPlatesDB then
        BetterBlizzPlatesDB = {}
    end

    if BetterBlizzPlatesDB.classicExport then
        TempClassicNpFix()
        BBP.ResetTotemList()
        BetterBlizzPlatesDB.classicExport = nil
        StaticPopupDialogs["BBP_EXPORT_MISMATCH"] = {
            text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \n\nYou've imported a Classic profile into Retail.\n\nDue to Nameplate CVars being very different on Retail many of them have now been reset to their default value.\n\nClassic->Retail export is not fully supported but should be fine but consider this a warning and please report any bugs.\n\nPlease reload for changes to take effect.",
            button1 = "OK",
            OnAccept = function()
                BetterBlizzPlatesDB.reopenOptions = true
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
        }
        StaticPopup_Show("BBP_EXPORT_MISMATCH")
    end

    local db = BetterBlizzPlatesDB

    -- Check the stored version against the current addon version
    if not db.version or db.version ~= addonVersion then
        -- Perform database update here (if needed)
        if not db.fadeOutNPCsList then
            db.fadeOutNPCsList = defaultSettings.defaultFadeOutNPCsList
        else
            -- Check if any new NPC IDs need to be added to the user's list
            for _, defaultNPC in ipairs(defaultSettings.defaultFadeOutNPCsList) do
                local isFound = false
                for _, userNPC in ipairs(db.fadeOutNPCsList) do
                    if defaultNPC.id == userNPC.id then
                        isFound = true
                        break
                    end
                end
                if not isFound then
                    table.insert(db.fadeOutNPCsList, defaultNPC)
                end
            end
        end
        db.version = addonVersion  -- Update the version number in the database
    end

    if not db.classIndicatorFriendlyYPos then
        db.classIndicatorFriendlyXPos = db.classIndicatorXPos
        db.classIndicatorFriendlyYPos = db.classIndicatorYPos
        db.classIndicatorFriendlyAnchor = db.classIndicatorAnchor
        db.classIndicatorFriendlyScale = db.classIndicatorScale
    end

    if not db.healerIndicatorEnemyXPos then
        db.healerIndicatorEnemyXPos = db.healerIndicatorXPos
        db.healerIndicatorEnemyYPos = db.healerIndicatorYPos
        db.healerIndicatorEnemyAnchor = db.healerIndicatorAnchor
        db.healerIndicatorEnemyScale = db.healerIndicatorScale
    end

    if db.friendlyHealthBarColorPlayer == nil then
        db.friendlyHealthBarColorPlayer = db.friendlyHealthBarColor
        db.friendlyHealthBarColorNpc = db.friendlyHealthBarColor
    end

    if db.nameplateAuraRowFriendlyAmount == nil then
        db.nameplateAuraRowFriendlyAmount = db.nameplateAuraRowAmount or 5
    end

    if db.alwaysHideFriendlyCastbar == nil then
        db.alwaysHideFriendlyCastbar = db.hideFriendlyCastbar or false
    end

    if db.nameplateAuraSelfScale == nil then
        db.nameplateAuraSelfScale = db.nameplateAuraScale
        db.nameplateAuraBuffSelfScale = db.nameplateAuraBuffScale
        db.nameplateAuraDebuffSelfScale = db.nameplateAuraDebuffScale
    end

    if db.dpsOrHealTargetAggroColorRGB == nil then
        db.dpsOrHealTargetAggroColorRGB = db.dpsOrHealFullAggroColorRGB or {1, 0, 0, 1}
    end

    if db.nameplateAurasPersonalCenteredAnchor == nil then
        db.nameplateAurasPersonalCenteredAnchor = db.nameplateAurasFriendlyCenteredAnchor
    end

    for key, defaultValue in pairs(defaultSettings) do
        if db[key] == nil then
            db[key] = defaultValue
        end
    end
end

function BBP.ResetTotemList()
    BetterBlizzPlatesDB.totemIndicatorNpcList = {}
    BetterBlizzPlatesDB.totemIndicatorNpcList = defaultSettings.totemIndicatorNpcList
end


function BBPrint(msg)
    print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: "..msg)
end

local cvarList = {
    "nameplateShowAll",
    "nameplateOverlapH",
    "nameplateOverlapV",
    --"nameplateMotionSpeed",
    --"nameplateHorizontalScale",
    --"NamePlateVerticalScale",
    "nameplateSelectedScale",
    "nameplateMinScale",
    "nameplateMaxScale",
    --"NamePlateClassificationScale",
    --"nameplateGlobalScale",
    --"nameplateLargerScale",
    --"nameplatePlayerLargerScale",
    --"nameplateResourceOnTarget",
    "nameplateMinAlpha",
    "nameplateMinAlphaDistance",
    "nameplateMaxAlpha",
    "nameplateMaxAlphaDistance",
    "nameplateOccludedAlphaMult",
    --"nameplateMotion", -- MIDNIGHT: nameplateStackingTypes
    "nameplateShowClassColor",
    "nameplateShowFriendlyClassColor",
    "nameplateShowEnemyGuardians",
    "nameplateShowEnemyMinions",
    "nameplateShowEnemyMinus",
    "nameplateShowEnemyPets",
    "nameplateShowEnemyTotems",
    "nameplateShowFriendlyPlayerGuardians",
    "nameplateShowFriendlyPlayerMinions",
    "nameplateShowFriendlyPlayerPets",
    "nameplateShowFriendlyPlayerTotems",
    "nameplateShowFriendlyNPCs",
    --"nameplateSelfTopInset",
    --"nameplateSelfBottomInset",
    --"nameplateSelfAlpha",
    -- Midnights
    "nameplateDebuffPadding",
    "nameplateStyle",
    "nameplateAuraScale",
}

function BBP.ResetNameplateCVars()
    if BBPCVarBackupsDB then
        for cvar, value in pairs(BBPCVarBackupsDB) do
            if cvar == "nameplateMinScale" or cvar == "nameplateMaxScale" then
                value = 0.9
            end
            C_CVar.SetCVar(cvar, value)
            BetterBlizzPlatesDB[cvar] = value
        end
    else
        for _, cvar in ipairs(cvarList) do
            local defaultValue = C_CVar.GetCVarDefault(cvar)
            if cvar == "nameplateMinScale" or cvar == "nameplateMaxScale" then
                defaultValue = 0.9
            end
            C_CVar.SetCVar(cvar, defaultValue)
            BetterBlizzPlatesDB[cvar] = defaultValue
        end
    end
end

local function CVarDefaultOnLogout()
    if not BBPCVarBackupsDB then return end
    if InCombatLockdown() or BetterBlizzPlatesDB.disableCVarForceOnLogin then return end
    for cvar, value in pairs(BBPCVarBackupsDB) do
        if cvar ~= "nameplateStyle" then -- Midnight style, skip for now
            C_CVar.SetCVar(cvar, value)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function()
    BBP.CVarTrackingDisabled = true
    CVarDefaultOnLogout()
end)


local function CVarFetcher()
    if BBP.variablesLoaded then
        local big = true
        BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = C_NamePlate.GetNamePlateSize()--C_NamePlate.GetNamePlateEnemySize()
        BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = C_NamePlate.GetNamePlateSize()--C_NamePlate.GetNamePlateFriendlySize()
        BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = C_NamePlate.GetNamePlateSize()--C_NamePlate.GetNamePlateSelfSize()

        BetterBlizzPlatesDB.nameplateEnemyWidth = big and 185 or 145
        BetterBlizzPlatesDB.nameplateFriendlyWidth = big and 185 or 145
        BetterBlizzPlatesDB.nameplateSelfWidth = big and 185 or 145

        if not BBPCVarBackupsDB then
            BBPCVarBackupsDB = {}
        end

        for _, cvar in ipairs(cvarList) do
            local value = GetCVar(cvar)
            BBPCVarBackupsDB[cvar] = value
            if cvar == "nameplateMinScale" or cvar == "nameplateMaxScale" then
                value = 0.9
            end
            BetterBlizzPlatesDB[cvar] = value
        end

        if true then
            BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
            BetterBlizzPlatesDB.castBarHeight = 18.8
            BetterBlizzPlatesDB.largeNameplates = true
        else
            BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 4
            BetterBlizzPlatesDB.castBarHeight = 8
            BetterBlizzPlatesDB.largeNameplates = false
        end

    else
        C_Timer.After(1, function()
            CVarFetcher()
        end)
    end
end

function BBP.CVarAdditionFetcher()
    if not BBP.variablesLoaded then
        C_Timer.After(1, BBP.CVarAdditionFetcher)
        return
    end

    if not BBPCVarBackupsDB then
        BBPCVarBackupsDB = {}
    end

    local anyAdded = false

    for _, cvar in ipairs(cvarList) do
        local needsBackup = BBPCVarBackupsDB[cvar] == nil
        local needsDB = BetterBlizzPlatesDB[cvar] == nil

        if needsBackup or needsDB then
            local value = GetCVar(cvar)
            if value == nil then
                value = C_CVar.GetCVarDefault(cvar)
            end

            if needsBackup then
                BBPCVarBackupsDB[cvar] = value
            end

            local storeValue = value
            if cvar == "nameplateMinScale" or cvar == "nameplateMaxScale" then
                storeValue = 0.9
            end
            if needsDB then
                BetterBlizzPlatesDB[cvar] = storeValue
            end

            anyAdded = true
        end
    end

    return anyAdded
end

local function FetchAndSaveValuesOnFirstLogin()
    if BBP.variablesLoaded then
        BetterBlizzPlatesDB.hasNotOpenedSettings = true
        -- collect some cvars added at a later time
        if not BetterBlizzPlatesDB.nameplateMinAlpha or not BetterBlizzPlatesDB.nameplateShowFriendlyPlayerMinions or not BetterBlizzPlatesDB.nameplateSelfWidth or not BetterBlizzPlatesDB.nameplateResourceOnTarget then
            CVarFetcher()
        end

        if BetterBlizzPlatesDB.hasSaved then
            if BetterBlizzPlatesDB.sendResetMessage then
                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates has been reset. If you are having any issues feel free to join the Discord. You'll find the link in the Support section /bbp")
                BetterBlizzPlatesDB.sendResetMessage = nil
            elseif BetterBlizzPlatesDB.hasNotOpenedSettings then
                C_Timer.After(3, function()
                    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates first run. Thank you for trying out my AddOn. Access settings with /bbp")
                end)
            end
            return
        end

        CVarFetcher()

        C_Timer.After(3, function()
            if not C_AddOns.IsAddOnLoaded("SkillCapped") then
                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates first run. Thank you for trying out my AddOn. Access settings with /bbp")
            end
            BetterBlizzPlatesDB.hasSaved = true
        end)
    else
        C_Timer.After(1, function()
            FetchAndSaveValuesOnFirstLogin()
        end)
    end
end

local printedCVarMissing

function BBP.CVarsAreSaved()
    local db = BetterBlizzPlatesDB
    local missing = {}

    for _, key in ipairs(cvarList) do
        if db[key] == nil then
            table.insert(missing, key)
        end
    end

    if #missing > 0 then
        if not printedCVarMissing then
            printedCVarMissing = true
            C_Timer.After(7, function()
                print("BBP: Missing CVars:", table.concat(missing, ", "))
                print("Contact @Bodify on Discord with bug report from BugSack and BugGrabber please.")
            end)
        end
        BBP.CVarAdditionFetcher()
        return false
    else
        return true
    end
end


local function ResetNameplates()
    BetterBlizzPlatesDB.nameplateGeneralWidth = 172.5
    BetterBlizzPlatesDB.nameplateGeneralHeight = 65
    BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = 172.5, 65
    BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = 172.5, 65
    BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = 172.5, 65

    BetterBlizzPlatesDB.nameplateOverlapH = 0.8
    BetterBlizzPlatesDB.nameplateOverlapV = 1.1
    BetterBlizzPlatesDB.nameplateMotion = 0
    BetterBlizzPlatesDB.nameplateMotionSpeed = 0.025
    BetterBlizzPlatesDB.nameplateHorizontalScale = 1.4
    BetterBlizzPlatesDB.NamePlateVerticalScale = 2.7
    BetterBlizzPlatesDB.nameplateMinScale = 0.9
    BetterBlizzPlatesDB.nameplateMaxScale = 0.9
    BetterBlizzPlatesDB.nameplateSelectedScale = 1.2
    BetterBlizzPlatesDB.NamePlateClassificationScale = 1
    BetterBlizzPlatesDB.nameplateGlobalScale = 1
    BetterBlizzPlatesDB.nameplateLargerScale = 1.2
    BetterBlizzPlatesDB.nameplatePlayerLargerScale = 1.8
    --BetterBlizzPlatesDB.nameplateResourceOnTarget = "0"

    BetterBlizzPlatesDB.nameplateMinAlpha = 0.6
    BetterBlizzPlatesDB.nameplateMinAlphaDistance = 10
    BetterBlizzPlatesDB.nameplateMaxAlpha = 1.0
    BetterBlizzPlatesDB.nameplateMaxAlphaDistance = 40
    BetterBlizzPlatesDB.nameplateOccludedAlphaMult = 0.4
    BetterBlizzPlatesDB.nameplateSelfAlpha = 0.75

    BetterBlizzPlatesDB.nameplateShowClassColor = "1"
    BetterBlizzPlatesDB.nameplateShowFriendlyClassColor = "1"

    BetterBlizzPlatesDB.nameplateShowEnemyGuardians = "1"
    BetterBlizzPlatesDB.nameplateShowEnemyMinions = "1"
    BetterBlizzPlatesDB.nameplateShowEnemyMinus = "0"
    BetterBlizzPlatesDB.nameplateShowEnemyPets = "1"
    BetterBlizzPlatesDB.nameplateShowEnemyTotems = "1"

    BetterBlizzPlatesDB.nameplateShowFriendlyPlayerGuardians = "0"
    BetterBlizzPlatesDB.nameplateShowFriendlyPlayerMinions = "0"
    BetterBlizzPlatesDB.nameplateShowFriendlyPlayerPets = "0"
    BetterBlizzPlatesDB.nameplateShowFriendlyPlayerTotems = "0"

    BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
    BetterBlizzPlatesDB.castBarHeight = 18.8
    BetterBlizzPlatesDB.largeNameplates = true

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
    --C_CVar.SetCVar("nameplateResourceOnTarget", BetterBlizzPlatesDB.nameplateResourceOnTarget)
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
    C_CVar.SetCVar("nameplateShowFriendlyPlayerMinions", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerMinions)
    C_CVar.SetCVar("nameplateShowFriendlyPlayerGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerGuardians)
    C_CVar.SetCVar("nameplateShowFriendlyPlayerPets", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerPets)
    C_CVar.SetCVar("nameplateShowFriendlyPlayerTotems", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerTotems)
    C_CVar.SetCVar("nameplateShowClassColor", BetterBlizzPlatesDB.nameplateShowClassColor)
    C_CVar.SetCVar("nameplateShowFriendlyClassColor", BetterBlizzPlatesDB.nameplateShowFriendlyClassColor)
    C_CVar.SetCVar("nameplateSelfAlpha", BetterBlizzPlatesDB.nameplateSelfAlpha)
    C_CVar.SetCVar('nameplateShowOnlyNames', "0")

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
                -- if db.petIndicator or db.hideNPC or db.enableNameplateAuraCustomisation then
                --     BBP.CreateUpdateMessageWindow()
                -- end
                -- if BetterBlizzPlatesDB.fadeAllButTarget then
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates " .. addonUpdates .. ":")
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Nameplate Auras now have a \"Key Auras Positioning\" setting that works similar to BigDebuffs. This will be expanded on in the future. Also \"PvP Buffs\" and \"PvP CC\" filters.")
                -- BetterBlizzPlatesDB.fadeAllButTarget = nil
                -- end
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Bugfixes/Tweaks:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Fix aura color module not working on buffs.")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Fix class icon module causing a lua error sometimes.")
                StaticPopupDialogs["BBP_NP_UPDATE"] = {
                text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \n\nNameplate Width/Height settings have got some temporary tweaks for Midnight and can now be adjusted again.\n\nThis has more than likely changed your nameplate sizes a bit and this might see one or more tweaks in the future before Midnight release so values might change again and look a little different.",
                button1 = "Ok",
                timeout = 0,
                whileDead = true,
                }
                StaticPopup_Show("BBP_NP_UPDATE")
                print("asd")
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

local function isFriend(unit)
    local reaction = UnitReaction(unit, "player")
    if reaction and reaction >= 5 then
        return true
    end
end

local function isEnemy(unit)
    local reaction = UnitReaction(unit, "player")
    if reaction and reaction <= 4 then
        return true
    end
end


local function GetNameplateUnitInfo(frame, unit)
    local unit = unit or frame.unit or frame.displayedUnit
    if not unit then return end

    if not frame.BetterBlizzPlates.unitInfo then
        frame.BetterBlizzPlates.unitInfo = {}
    end
    local info = frame.BetterBlizzPlates.unitInfo

    info.name = UnitName(unit)
    info.isSelf = false--UnitIsUnit("player", unit)
    info.isTarget = UnitIsUnit("target", unit)
    info.isFocus = UnitIsUnit("focus", unit)
    info.isPet = UnitIsUnit("pet", unit)
    info.isPlayer = UnitIsPlayer(unit)
    info.isNpc = not info.isPlayer
    info.unitGUID = 0--UnitGUID(unit)
    info.class = info.isPlayer and UnitClassBase(unit) or nil
    info.reaction = UnitReaction(unit, "player")
    info.isEnemy = (info.reaction and info.reaction < 4) and not info.isSelf
    info.isNeutral = (info.reaction and info.reaction == 4) and not info.isSelf
    info.isFriend = (info.reaction and info.reaction >= 5) and not info.isSelf
    info.playerClass = playerClass

    return info
end
BBP.GetNameplateUnitInfo = GetNameplateUnitInfo



local function GetRPNameColor(unit)
    if not UnitExists(unit) then return end
    local player = AddOn_TotalRP3 and AddOn_TotalRP3.Player and AddOn_TotalRP3.Player.CreateFromUnit(unit)
    if player then
        local color = player:GetCustomColorForDisplay()
        if color then
            local r, g, b = color:GetRGB()
            return r, g, b
        end
    end
end

local function SetRPName(name, unit, rpNamesFirst, rpNamesLast)
    local fullName = TRP3_API.r.name(unit) or ""
    local firstRpName, lastRpName = fullName:match("^(%S+)%s*(.*)$")

    if rpNamesFirst and rpNamesLast then
        name:SetText(fullName)
    elseif rpNamesFirst then
        name:SetText(firstRpName or fullName)
    elseif rpNamesLast then
        name:SetText(lastRpName ~= "" and lastRpName or fullName)
    else
        name:SetText(fullName)
    end
end


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
        return true
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
    db.bgIndicatorTestMode = false
end

-- Extracts NPC ID from GUID
function BBP.GetNPCIDFromGUID(guid)
    return 0 --BBP.isMidnight
    --return tonumber(guid:match("%-([0-9]+)%-%x+$"))
end

local C_NamePlate = C_NamePlate
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
function BBP.GetNameplate(unit)
    return C_NamePlate.GetNamePlateForUnit(unit)
end

function BBP.GetSafeNameplate(unit)
    if string.match(unit, "arena") then return end
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    -- If there's no nameplate or the nameplate doesn't have a UnitFrame, return nils.
    if not nameplate or not nameplate.UnitFrame then return nil, nil end

    local frame = nameplate.UnitFrame
    -- If none of the above conditions are met, return both the nameplate and the frame.
    return nameplate, frame
end


-- is large nameplates enabled
function BBP.isLargeNameplatesEnabled()
    return true
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
        local enemyWidth   = BetterBlizzPlatesDB.nameplateEnemyWidth or 172.5
        local friendlyWidth = BetterBlizzPlatesDB.nameplateFriendlyWidth or 172.5

        local widestBar = math.max(enemyWidth, friendlyWidth)
        local healthBarHeight = BetterBlizzPlatesDB.nameplateGeneralHeight or 65

        -- Set the nameplate size
        C_NamePlate.SetNamePlateSize(widestBar, healthBarHeight)

        if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
            -- Collapse friendly nameplates to un-clickable (positive = shrink)
            C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, 10000, 10000, 10000, 10000)
        else
            C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, 1, 1, -10, -10)
        end
        -- Expand to full nameplate size (negative = expand to bounds)
        C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Enemy, 1, 1, -10, -10)
    end
end

--/run C_NamePlate.SetNamePlateSize(172, 65)

function BBP.AdjustClickableNameplateSize()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        --if not UnitIsUnit(frame.unit, "player") then
            BBP.ClickableArea(nameplate)
        --end
    end
    BBP.ApplyNameplateWidth()
end

function BBP.HookNameplatePosition(frame, nameplate)
    if not BetterBlizzPlatesDB.enableNpVerticalPos then return end
    if frame.verticalPositionTweak then return end
    --if UnitIsUnit(frame.unit, "player") then return end
    frame.verticalPositionTweak = true
    hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(self)
        if SettingsPanel:IsShown() then return end
        if self:IsForbidden() then return end
        --if frame.unit and UnitIsUnit(frame.unit, "player") then return end
        frame:ClearPoint("BOTTOMLEFT")
        frame:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT", BetterBlizzPlatesDB.nameplateHorizontalPosition or 0, BetterBlizzPlatesDB.nameplateVerticalPosition or 0)
    end)
    -- if not SettingsPanel:IsShown() then
    -- end
    frame:ClearPoint("BOTTOMLEFT")
    frame:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT", BetterBlizzPlatesDB.nameplateHorizontalPosition or 0, BetterBlizzPlatesDB.nameplateVerticalPosition or 0)
end

function BBP.AdjustNameplatePosition()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        --if not UnitIsUnit(frame.unit, "player") then
            BBP.ClickableArea(nameplate)
            BBP.HookNameplatePosition(frame, nameplate)
            frame:ClearPoint("BOTTOMLEFT")
            frame:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT", BetterBlizzPlatesDB.nameplateHorizontalPosition or 0, BetterBlizzPlatesDB.nameplateVerticalPosition or 0)
        --end
    end
end

--#################################################################################################
--  Remove realm names
function BBP.RemoveRealmName(frame)
    -- BBP.isMidnight
    frame.name:SetText(UnitName(frame.unit))
    -- local name = GetUnitName(frame.unit)
    -- if name then
    --     name = string.gsub(name, " %(%*%)$", "")
    --     frame.name:SetText(name)
    -- end
end


--#################################################################################################
function BBP.isFriendlistFriend(unit)
    -- for i = 1, C_FriendList.GetNumFriends() do
    --     local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
    --     if friendInfo and friendInfo.name == UnitName(unit) then
    --         return true
    --     end
    -- end
    return false
end

function BBP.isUnitGuildmate(unit)
    local guildName = GetGuildInfo(unit)
    local playerGuildName = GetGuildInfo("player")
    return guildName and playerGuildName and (guildName == playerGuildName)
end

function BBP.isUnitBNetFriend(unit)
    -- local unitName = UnitName(unit)
    -- local numBNetFriends = BNGetNumFriends()
    -- for i = 1, numBNetFriends do
    --     local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
    --     if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
    --         local characterName = accountInfo.gameAccountInfo.characterName
    --         if characterName and characterName == unitName then
    --             return true
    --         end
    --     end
    -- end
    return false
end

local function anonMode(frame, info)
    if info.isPlayer and not info.isSelf then
        local anonName = UnitClass(frame.unit)
        frame.name:SetText(anonName)
    end
end

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
            friendlyHideHealthBarNpc = BetterBlizzPlatesDB.friendlyHideHealthBarNpc,
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
            nameplatePersonalBorderSize = BetterBlizzPlatesDB.nameplatePersonalBorderSize,
            showNpcTitle = BetterBlizzPlatesDB.showNpcTitle,
            enableNpNonTargetAlpha = BetterBlizzPlatesDB.enableNpNonTargetAlpha,
            enableNpNonFocusAlpha = BetterBlizzPlatesDB.enableNpNonFocusAlpha,
            targetHighlightFix = BetterBlizzPlatesDB.targetHighlightFix,
            bgIndicator = BetterBlizzPlatesDB.bgIndicator or BetterBlizzPlatesDB.bgIndicatorTestMode,
            arenaIndicatorBg = BetterBlizzPlatesDB.arenaIndicatorBg,
            classicNameplates = BetterBlizzPlatesDB.classicNameplates,
            hideLevelFrame = BetterBlizzPlatesDB.hideLevelFrame,
            smallPetsInPvP = BetterBlizzPlatesDB.smallPetsInPvP,
            hideEliteDragon = BetterBlizzPlatesDB.hideEliteDragon,
            personalBarTweaks = BetterBlizzPlatesDB.personalBarTweaks,
        }
        if frame.BetterBlizzPlates.config.changeHealthbarHeight then
            frame.BetterBlizzPlates.config.hpHeightEnemy = BetterBlizzPlatesDB.hpHeightEnemy
            frame.BetterBlizzPlates.config.hpHeightFriendly = BetterBlizzPlatesDB.hpHeightFriendly
            frame.BetterBlizzPlates.config.hpHeightSelf = BetterBlizzPlatesDB.hpHeightSelf
            frame.BetterBlizzPlates.config.hpHeightSelfMana = BetterBlizzPlatesDB.hpHeightSelfMana
        end
    end
    return frame.BetterBlizzPlates.config
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

        config.customTextureInitialized = true
    end

    local defaultTex = ((not BetterBlizzPlatesDB.useCustomTextureForBars and BetterBlizzPlatesDB.classicRetailNameplates) and "Interface/TargetingFrame/UI-TargetingFrame-BarFill") or "UI-HUD-CoolDownManager-Bar"

    if not config.useCustomTextureForBars then
        frame.healthBar:SetStatusBarTexture(defaultTex)
        textureExtraBars(frame, config.customTextureFriendly)
        return
    end

    if not info then return end

    --BBP.isMidnight
    --if UnitIsUnit(frame.unit, "player") then
    if false then
        if (config.useCustomTextureForSelf or config.useCustomTextureForSelfMana) then
            if config.useCustomTextureForSelf then
                frame.healthBar:SetStatusBarTexture(config.customTextureSelf)
                textureExtraBars(frame, config.customTextureSelf)
            else
                frame.healthBar:SetStatusBarTexture(defaultTex)
                --textureExtraBars(frame, defaultTex)
            end
            if config.useCustomTextureForSelfMana then
                ClassNameplateManaBarFrame:SetStatusBarTexture(config.customTextureSelfMana)
                if ClassNameplateBrewmasterBarFrame then
                    ClassNameplateBrewmasterBarFrame:SetStatusBarTexture(config.customTextureSelfMana)
                end
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

--#################################################
function BBP.ChangeStrataOfResourceFrame()
    local playerClass = select(2, UnitClass("player"))
    -- Table holding references to class-specific resource frames
    local resourceFrames = {
        ["WARLOCK"] = ClassNameplateBarWarlockFrame,
        ["DEATHKNIGHT"] = DeathKnightResourceOverlayFrame,
        ["PALADIN"] = ClassNameplateBarPaladinFrame,
        ["MONK"] = ClassNameplateBarWindwalkerMonkFrame,
        ["ROGUE"] = ClassNameplateBarRogueFrame,
        ["MAGE"] = ClassNameplateBarMageFrame,
        ["DRUID"] = ClassNameplateBarFeralDruidFrame,
    }
    local resourceFrame = resourceFrames[playerClass]
    if not resourceFrame or resourceFrame:IsForbidden() then return end

    resourceFrame:SetFrameStrata("HIGH")
end

--###############################################
local function ColorNameplateByReaction(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.friendlyHealthBarColorInitalized or BBP.needsUpdate then
        config.friendlyHealthBarColor = BetterBlizzPlatesDB.friendlyHealthBarColor
        config.friendlyHealthBarColorRGB = BetterBlizzPlatesDB.friendlyHealthBarColorRGB
        config.friendlyHealthBarColorPlayer = BetterBlizzPlatesDB.friendlyHealthBarColorPlayer
        config.friendlyHealthBarColorNpc = BetterBlizzPlatesDB.friendlyHealthBarColorNpc
        config.enemyHealthBarColor = BetterBlizzPlatesDB.enemyHealthBarColor
        config.enemyHealthBarColorNpcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly

        config.friendlyHealthBarColorInitalized = true
    end

    if info.isSelf then
        if frame.needsRecolor then
            BBP.CompactUnitFrame_UpdateHealthColor(frame, true)
        end
        return
    elseif info.isFriend and config.friendlyHealthBarColor then
        -- Friendly NPC
        if (info.isPlayer and config.friendlyHealthBarColorPlayer) or (info.isNpc and config.friendlyHealthBarColorNpc) then
            frame.healthBar:SetStatusBarColor(unpack(config.friendlyHealthBarColorRGB))
            frame.needsRecolor = true
        end
    elseif not info.isFriend and config.enemyHealthBarColor then
        -- Handling enemy health bars
        if (not config.enemyHealthBarColorNpcOnly) or (config.enemyHealthBarColorNpcOnly and not info.isPlayer) then
            if UnitIsTapDenied(frame.unit) then
                frame.healthBar:SetStatusBarColor(0.9,0.9,0.9)
                return
            end
            if info.isNeutral then
                -- Neutral NPC
                config.enemyNeutralHealthBarColorRGB = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 0, 0}
                frame.healthBar:SetStatusBarColor(unpack(config.enemyNeutralHealthBarColorRGB))
                frame.needsRecolor = true
            else
                -- Hostile NPC
                config.enemyHealthBarColorRGB = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
                frame.healthBar:SetStatusBarColor(unpack(config.enemyHealthBarColorRGB))
                frame.needsRecolor = true
            end
        end
    elseif frame.needsRecolor then
        BBP.CompactUnitFrame_UpdateHealthColor(frame, true)
    end
end

local function AdjustHealthBarHeight(frame)
    if frame:IsForbidden() then return end
    if not frame.unit then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
    if not config then return end
    if BetterBlizzPlatesDB.changeHealthbarHeight then
        if isEnemy(frame.unit) then
            frame.HealthBarsContainer:SetHeight(config.hpHeightEnemy or 11)
        elseif not isEnemy(frame.unit) then
            frame.HealthBarsContainer:SetHeight(config.hpHeightFriendly or 11)
        else
            frame.HealthBarsContainer:SetHeight(config.hpHeightSelf or 11)
            if ClassNameplateManaBarFrame then
                ClassNameplateManaBarFrame:SetHeight(config.hpHeightSelfMana or 11)
                ClassNameplateManaBarFrame.bbpHeight = config.hpHeightSelfMana

                if not ClassNameplateManaBarFrame.bbpHooked then
                    hooksecurefunc(ClassNameplateManaBarFrame, "SetHeight", function(self)
                        if self.changing then return end
                        self.changing = true
                        self:SetHeight(self.bbpHeight or 11)
                        self.changing = false
                    end)
                    ClassNameplateManaBarFrame.bbpHooked = true
                end
            end
        end
    else
        frame.HealthBarsContainer:SetHeight(BetterBlizzPlatesDB.nameplateGeneralHpHeight or 16)
    end
end

--#################################################################################################
function BBP.SetFontBasedOnOption(namePlateObj, specifiedSize, forcedOutline)
    local font, outline, currentSize
    local db = BetterBlizzPlatesDB
    local useCustomFont = db.useCustomFont

    if useCustomFont then
        local fontName = db.customFont
        local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
        local fontSize = db.defaultFontSize
        font = fontPath
        outline = forcedOutline or "THINOUTLINE"
        currentSize = (specifiedSize + 2) or (fontSize + 3)
    else
        local defaultNamePlateFontFlags =db.defaultNamePlateFontFlags
        local defaultFontSize = db.defaultFontSize
        font = db.defaultNamePlateFont
        outline = forcedOutline or "OUTLINE, SLUG"--defaultNamePlateFontFlags
        currentSize = specifiedSize or defaultFontSize
    end

    if forcedOutline == "" then
        outline = "OUTLINE, SLUG"
    end

    namePlateObj:SetFont(font, currentSize, outline)
    if db.customFontShadowOff then
        if not namePlateObj.oldShadow then
            local r, g, b, a = namePlateObj:GetShadowColor()
            namePlateObj.oldShadow = {r, g, b, a}
            namePlateObj:SetShadowColor(0, 0, 0, 0)
        end
    elseif namePlateObj.oldShadow then
        namePlateObj:SetShadowColor(unpack(namePlateObj.oldShadow))
        namePlateObj.oldShadow = nil
    end
end

--#################################################################################################
-- Friendly nameplates on only in arena toggle automatically
-- Event listening for Nameplates on in arena only
local toggleEventsRegistered = false
local inCombatEventRegistered = false

local friendlyNameplatesOnOffFrame = CreateFrame("Frame")

local function ShouldShowFriendlyNameplates()
    local instanceType = select(2, IsInInstance())
    local inWorld = instanceType == "none"

    if instanceType == "arena" and BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena then
        return true
    elseif (instanceType == "party" or instanceType == "scenario") and BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons then
        return true
    elseif instanceType == "raid" and BetterBlizzPlatesDB.friendlyNameplatesOnlyInRaids then
        return true
    elseif instanceType == "pvp" then
        if C_PvP.GetActiveMatchBracket() == 3 and BetterBlizzPlatesDB.friendlyNameplatesOnlyInEpicBgs then
            return true
        elseif BetterBlizzPlatesDB.friendlyNameplatesOnlyInBgs then
            return true
        else
            return false
        end
    elseif inWorld and BetterBlizzPlatesDB.friendlyNameplatesOnlyInWorld then
        return true
    end

    return false
end

local function ApplyCVarChange()
    local shouldShow = ShouldShowFriendlyNameplates() and "1" or "0"
    if GetCVar("nameplateShowFriendlyPlayers") ~= shouldShow then
        C_CVar.SetCVar("nameplateShowFriendlyPlayers", shouldShow)
    end
    if inCombatEventRegistered then
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        inCombatEventRegistered = false
    end
end

local function ToggleFriendlyPlates()
    if BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInRaids
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInBgs
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInEpicBgs
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInWorld then

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
    local anyToggleEnabled = BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInDungeons
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInRaids
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInBgs
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInEpicBgs
        or BetterBlizzPlatesDB.friendlyNameplatesOnlyInWorld

    if anyToggleEnabled and not toggleEventsRegistered then
        friendlyNameplatesOnOffFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        toggleEventsRegistered = true
    elseif not anyToggleEnabled and toggleEventsRegistered then
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
    if BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater") then return end
    if C_AddOns.IsAddOnLoaded("Plater") and C_AddOns.IsAddOnLoaded("SkillCapped") then return end
    if BetterBlizzPlatesDB.hasSaved and not BetterBlizzPlatesDB.disableCVarForceOnLogin then
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
        --C_CVar.SetCVar("nameplateResourceOnTarget", (BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf and 0) or BetterBlizzPlatesDB.nameplateResourceOnTarget)
        C_CVar.SetCVar("nameplateShowClassColor", BetterBlizzPlatesDB.nameplateShowClassColor)
        C_CVar.SetCVar("nameplateShowFriendlyClassColor", BetterBlizzPlatesDB.nameplateShowFriendlyClassColor)

        if BetterBlizzPlatesDB.nameplateMotion then
            C_CVar.SetCVar("nameplateMotion", BetterBlizzPlatesDB.nameplateMotion)
        end

        if BetterBlizzPlatesDB.nameplateDebuffPadding then
            C_CVar.SetCVar("nameplateDebuffPadding", BetterBlizzPlatesDB.nameplateDebuffPadding)
        end

        if BetterBlizzPlatesDB.nameplateSelfAlpha then
            C_CVar.SetCVar("nameplateSelfAlpha", BetterBlizzPlatesDB.nameplateSelfAlpha)
        end

        if BetterBlizzPlatesDB.nameplateAuraScale then
            C_CVar.SetCVar("nameplateAuraScale", BetterBlizzPlatesDB.nameplateAuraScale)
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

            C_CVar.SetCVar("nameplateShowFriendlyPlayerMinions", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerMinions)
            C_CVar.SetCVar("nameplateShowFriendlyPlayerGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerGuardians)
            if BetterBlizzPlatesDB.nameplateShowFriendlyNPCs then
                C_CVar.SetCVar("nameplateShowFriendlyNPCs", BetterBlizzPlatesDB.nameplateShowFriendlyNPCs)
            end
            C_CVar.SetCVar("nameplateShowFriendlyPlayerPets", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerPets)
            C_CVar.SetCVar("nameplateShowFriendlyPlayerTotems", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerTotems)
        end

        ToggleFriendlyPlates()
    end
end

--#################################################################################################
function BBP.ToggleNameplateAuras(frame)
    local db = BetterBlizzPlatesDB
    if not db.nameplateAuraPlayersOnly then return end
    --if not frame then return end

    local isTarget = frame == BBP.currentTargetNameplate --UnitIsUnit(frame.unit, "target") --needs update
    local isPlayer = false--UnitIsPlayer(frame.unit)
    local shouldShowAuras = isPlayer or (db.nameplateAuraPlayersOnlyShowTarget and isTarget)

    frame.AurasFrame:SetAlpha(shouldShowAuras and 1 or 0)
end

function BBP.TargetNameplateAuraSize(frame)
    local db = BetterBlizzPlatesDB
    if not db.targetNameplateAuraScaleEnabled then return end
    --if not frame then return end
    local isTarget = frame == BBP.currentTargetNameplate --UnitIsUnit(frame.unit, "target") --needs update

    frame.AurasFrame:SetScale(isTarget and db.targetNameplateAuraScale or 1)
end

--#################################################################################################
local function ToggleNameplateBuffFrameVisibility(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    local buffFrameAlpha = 1
    if config.hideNameplateAuras then
        if not frame.bbpHookedBuffFrameAlpha then
            hooksecurefunc(frame.AurasFrame, "SetAlpha", function(self)
                if frame:IsForbidden() or self.changing then return end
                self.changing = true
                self:SetAlpha(0)
                self.changing = false
            end)
            frame.bbpHookedBuffFrameAlpha = true
            frame.AurasFrame:SetAlpha(0)
        end
        return
    elseif config.nameplateAuraPlayersOnly then
        if config.nameplateAuraPlayersOnlyShowTarget and info.isTarget then
            buffFrameAlpha = 1
        else
            buffFrameAlpha = info.isPlayer and 1 or 0
        end
    end
    frame.AurasFrame:SetAlpha(buffFrameAlpha)
end

local function ToggleTargetNameplateHighlight(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 0.22)
    if config.targetHighlightFix then
        frame.selectionHighlight:SetAllPoints(frame.healthBar.barTexture)
        frame.selectionHighlight:SetParent(frame.healthBar)
    end
end

--#################################################################################################
-- Clickthrough nameplates function
function BBP.ClickthroughNameplateAuras(pool, namePlateFrameBase)
    if not namePlateFrameBase.BuffFrame.buffPool.hooked then
        namePlateFrameBase.BuffFrame.buffPool.hooked=true
        hooksecurefunc(namePlateFrameBase.BuffFrame.buffPool,"resetterFunc",function(pool2,buff)
            buff:SetMouseClickEnabled(false)
        end)
    end
end
--hooksecurefunc(NamePlateDriverFrame.pools:GetPool("NamePlateUnitFrameTemplate"),"resetterFunc",BBP.ClickthroughNameplateAuras) --tww change
--hooksecurefunc(NamePlateDriverFrame.pools:GetPool("ForbiddenNamePlateUnitFrameTemplate"),"resetterFunc",BBP.ClickthroughNameplateAuras)

function BBP.PersonalBarSettings()
    local db = BetterBlizzPlatesDB
    local function SetFrameAlpha(frame, shouldHide, hiddenVar)
        if frame then
            if shouldHide then
                frame:SetAlpha(0)
                BBP[hiddenVar] = true
            elseif BBP[hiddenVar] then
                frame:SetAlpha(1)
                BBP[hiddenVar] = nil
            end
        end
    end
    -- Handle Mana Bar
    SetFrameAlpha(ClassNameplateManaBarFrame, db.hidePersonalBarManaFrame, "ClassNameplateManaBarFrameHidden")

    -- Handle Extra Frames (Ebon Might and Brewmaster)
    SetFrameAlpha(ClassNameplateEbonMightBarFrame, db.hidePersonalBarExtraFrame, "ClassNameplateEbonMightBarFrameHidden")
    SetFrameAlpha(ClassNameplateBrewmasterBarFrame, db.hidePersonalBarExtraFrame, "ClassNameplateBrewmasterBarFrameHidden")
end

--#################################################################################################
-- Class color and scale names 
function BBP.ClassColorAndScaleNames(frame)
    if not frame.unit then return end
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
        local color = ((isEnemy or (isNeutral and UnitAffectingCombat(frame.unit))) and BetterBlizzPlatesDB.enemyColorNameRGB) or (isNeutral and BetterBlizzPlatesDB.enemyNeutralColorNameRGB) or (isFriend and BetterBlizzPlatesDB.friendlyColorNameRGB)
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
end


--#################################################################################################
-- Dark Mode for Nameplate Resources
local function applySettings(frame, desaturate, colorValue, hook)
    if frame then
        if desaturate ~= nil and frame.SetDesaturated then -- Check if SetDesaturated is available
            frame:SetDesaturated(desaturate)
        end
        if frame.SetVertexColor then
            frame:SetVertexColor(colorValue, colorValue, colorValue) -- Alpha set to 1
            if hook then
                if not frame.bbpHooked then
                    frame.bbpHooked = true

                    hooksecurefunc(frame, "SetVertexColor", function(self)
                        if not self.changing then
                            self.changing = true
                            self:SetDesaturated(desaturate)
                            self:SetVertexColor(colorValue, colorValue, colorValue)
                            self.changing = false
                        end
                    end)
                end
            end
        end
    end
end

function BBP.HideResourceFrames()
    local db = BetterBlizzPlatesDB
    if not db.hideResourceFrame then return end
    if prdClassFrame then
        prdClassFrame:SetAlpha(0)
    end
end


function BBP.DarkModeNameplateResources()
    local useDarkMode = BetterBlizzPlatesDB.darkModeNameplateResource
    if not useDarkMode and not BBP.npCombosColored then
        return
    end
    local darkModeNpSatVal = useDarkMode and true or false
    local vertexColor = useDarkMode and BetterBlizzPlatesDB.darkModeNameplateColor or 1
    local druidComboPoint = useDarkMode and (vertexColor + 0.2) or 1
    local druidComboPointActive = useDarkMode and (vertexColor + 0.1) or 1
    local actionBarColor = useDarkMode and (vertexColor + 0.15) or 1
    local rogueCombo = useDarkMode and (vertexColor + 0.45) or 1
    local rogueComboActive = useDarkMode and (vertexColor + 0.30) or 1
    local monkChi = useDarkMode and (vertexColor + 0.10) or 1


    local nameplateRunes = prdClassFrame
    if nameplateRunes and not nameplateRunes:IsForbidden() and playerClass == "DEATHKNIGHT" then
        local dkNpRunes = vertexColor or 1
        for i = 1, 6 do
            applySettings(nameplateRunes["Rune" .. i].BG_Active, darkModeNpSatVal, dkNpRunes)
            applySettings(nameplateRunes["Rune" .. i].BG_Inactive, darkModeNpSatVal, dkNpRunes)
        end
    end

    local soulShardsNameplate = prdClassFrame
    if soulShardsNameplate and not soulShardsNameplate:IsForbidden() and playerClass == "WARLOCK" then
        local soulShardNp = vertexColor or 1
        for _, v in pairs({soulShardsNameplate:GetChildren()}) do
            applySettings(v.Background, darkModeNpSatVal, soulShardNp)
        end
    end

    local druidComboPointsNameplate = prdClassFrame
    if druidComboPointsNameplate and not druidComboPointsNameplate:IsForbidden() and playerClass == "DRUID" then
        local druidComboPointNp = druidComboPoint or 1
        local druidComboPointActiveNp = druidComboPointActive or 1
        for _, v in pairs({druidComboPointsNameplate:GetChildren()}) do
            applySettings(v.BG_Inactive, darkModeNpSatVal, druidComboPointNp)
            applySettings(v.BG_Active, darkModeNpSatVal, druidComboPointActiveNp)
            if BetterBlizzPlatesDB.druidOverstacks then
                applySettings(v.ChargedFrameActive, desaturationValue, druidComboPointActive, true)
            end
        end
    end

    local mageArcaneChargesNameplate = prdClassFrame
    if mageArcaneChargesNameplate and not mageArcaneChargesNameplate:IsForbidden() and playerClass == "MAGE" then
        local mageChargeNp = actionBarColor or 1
        for _, v in pairs({mageArcaneChargesNameplate:GetChildren()}) do
            applySettings(v.ArcaneBG, darkModeNpSatVal, mageChargeNp)
            --applySettings(v.BG_Active, desaturationValue, druidComboPointActive)
        end
    end

    local monkChiPointsNameplate = prdClassFrame
    if monkChiPointsNameplate and not monkChiPointsNameplate:IsForbidden() and playerClass == "MONK" then
        local monkChiNp = monkChi or 1
        for _, v in pairs({monkChiPointsNameplate:GetChildren()}) do
            applySettings(v.Chi_BG, darkModeNpSatVal, monkChiNp)
            applySettings(v.Chi_BG_Active, darkModeNpSatVal, monkChiNp)
        end
    end

    local rogueComboPointsNameplate = prdClassFrame
    if rogueComboPointsNameplate and not rogueComboPointsNameplate:IsForbidden() and playerClass == "ROGUE" then
        local rogueComboNp = rogueCombo or 1
        local rogueComboActiveNp = rogueComboActive or 1
        for _, v in pairs({rogueComboPointsNameplate:GetChildren()}) do
            applySettings(v.BGInactive, darkModeNpSatVal, rogueComboNp)
            applySettings(v.BGActive, darkModeNpSatVal, rogueComboActiveNp)
        end
    end

    local paladinHolyPowerNameplate = prdClassFrame
    if paladinHolyPowerNameplate and not paladinHolyPowerNameplate:IsForbidden() and playerClass == "PALADIN" then
        local palaPowerNp = vertexColor or 1
        applySettings(paladinHolyPowerNameplate.Background, darkModeNpSatVal, palaPowerNp)
        applySettings(paladinHolyPowerNameplate.ActiveTexture, darkModeNpSatVal, palaPowerNp)
    end

    local evokerEssencePointsNameplate = prdClassFrame
    if evokerEssencePointsNameplate and not evokerEssencePointsNameplate:IsForbidden() and playerClass == "EVOKER" then
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
    BBP.npCombosColored = useDarkMode or nil
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
        "bgIndicator",
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
    local heightValue = BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeFriendlyHeight or BetterBlizzPlatesDB.nameplateDefaultFriendlyHeight
     heightValue = heightValue + BetterBlizzPlatesDB.nameplateExtraClickHeight

    if isFriendly and BetterBlizzPlatesDB.friendlyNameplateClickthrough then
        heightValue = 1
    end

    if not BBP.checkCombatAndWarn() then
        C_NamePlate.SetNamePlateSize(172.5, heightValue)
        slider:SetValue(172.5)
    end
end

--#################################################################################################
-- Reset to default CVar values
function BBP.ResetToDefaultScales(slider, targetType)
    -- Define default values
    local defaultSettings = {
        nameplateScale = 0.9,  -- This will be used for nameplateMinScale
        nameplateSelected = 1.2,
    }

    -- Set the slider's value to the default
    slider:SetValue(defaultSettings[targetType] or 1)

    if not BBP.checkCombatAndWarn() then
        if targetType == "nameplateScale" then
            -- Reset both nameplateMinScale and nameplateMaxScale based on their ratio
            local defaultMinScale = 0.9
            local defaultMaxScale = 0.9
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
    if BBP.isLargeNameplatesEnabled() then
        slider:SetValue(18.8)
        BetterBlizzPlatesDB.castBarHeight = 18.8
    else
        slider:SetValue(8)
        BetterBlizzPlatesDB.castBarHeight = 8
    end
end

function BBP.ResetToDefaultHeight2(slider)
    slider:SetValue(16)
    BetterBlizzPlatesDB.nameplateGeneralHpHeight = 16
end

function BBP.ResetToDefaultValue(slider, element)
    if not BBP.checkCombatAndWarn() then
        if element == "nameplateOverlapH" then
            BetterBlizzPlatesDB.nameplateOverlapH = 0.8
            C_CVar.SetCVar("nameplateOverlapH", 0.8)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOverlapH set to 0.8")
        elseif element == "nameplateOverlapV" then
            BetterBlizzPlatesDB.nameplateOverlapV = 1.1
            C_CVar.SetCVar("nameplateOverlapV", 1.1)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOverlapV set to 1.1")
        elseif element == "nameplateMotionSpeed" then
            BetterBlizzPlatesDB.nameplateMotionSpeed = 0.025
            C_CVar.SetCVar("nameplateMotionSpeed", 0.025)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMotionSpeed set to 0.025")
        elseif element == "nameplateMinAlpha" then
            BetterBlizzPlatesDB.nameplateMinAlpha = 0.6
            C_CVar.SetCVar("nameplateMinAlpha", 0.6)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinAlpha set to 0.6")
        elseif element == "nameplateMinAlphaDistance" then
            BetterBlizzPlatesDB.nameplateMinAlphaDistance = 10
            C_CVar.SetCVar("nameplateMinAlphaDistance", 10)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinAlphaDistance set to 10")
        elseif element == "nameplateMaxAlpha" then
            BetterBlizzPlatesDB.nameplateMaxAlpha = 1
            C_CVar.SetCVar("nameplateMaxAlpha", 1)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMaxAlpha set to 1")
        elseif element == "nameplateMaxAlphaDistance" then
            BetterBlizzPlatesDB.nameplateMaxAlphaDistance = 40
            C_CVar.SetCVar("nameplateMaxAlphaDistance", 40)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMaxAlphaDistance set to 40")
        elseif element == "nameplateOccludedAlphaMult" then
            BetterBlizzPlatesDB.nameplateOccludedAlphaMult = 0.4
            C_CVar.SetCVar("nameplateOccludedAlphaMult", 0.4)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOccludedAlphaMult set to 0.4")
        elseif element == "nameplateResourceScale" then
            BetterBlizzPlatesDB.nameplateResourceScale = 0.7
        elseif element == "nameplateResourceXPos" then
            BetterBlizzPlatesDB.nameplateResourceXPos = 0
        elseif element == "nameplateResourceYPos" then
            BetterBlizzPlatesDB.nameplateResourceYPos = 0
        elseif element == "hpHeightFriendly" then
            BetterBlizzPlatesDB.hpHeightFriendly = 4 * 2.7--tonumber(GetCVar("NamePlateVerticalScale"))
        elseif element == "hpHeightSelf" then
            BetterBlizzPlatesDB.hpHeightSelf = 4 * 2.7--tonumber(GetCVar("NamePlateVerticalScale"))
        elseif element == "hpHeightSelfMana" then
            BetterBlizzPlatesDB.hpHeightSelfMana = 4 * 2.7--tonumber(GetCVar("NamePlateVerticalScale"))
        elseif element == "hpHeightEnemy" then
            BetterBlizzPlatesDB.hpHeightEnemy = 4 * 2.7--tonumber(GetCVar("NamePlateVerticalScale"))
        elseif element == "nameplateSelfAlpha" then
            C_CVar.SetCVar("nameplateSelfAlpha", C_CVar.GetCVarDefault("nameplateSelfAlpha"))
            BetterBlizzPlatesDB.nameplateSelfAlpha = C_CVar.GetCVarDefault("nameplateSelfAlpha")
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

local mainPets = {
    [165189] = true, -- Hunter
    [26125] = true, -- DK Pet
    [17252] = true, -- Felguard Lock
    [417] = true, -- Felhunter Lock
    [416] = true, -- Imp Lock
    [1860] = true, -- VoidWalker Lock
    [1863] = true, -- Sayaad/Succubus Lock
}

local secondaryPets = {
    -- Death Knight
    [221633] = true, -- High Inquisitor Whitemane
    [221632] = true, -- Highlord Darion Mograine
    [221634] = true, -- Nazgrim
    [221635] = true, -- King Thoras Trollbane
    [149555] = true, -- Raise Abomination
    [163366] = true, -- Magus (Army of the Dead)

    -- Warlock
    [135816] = true, -- Vilefiend
    [226268] = true, -- Gloomhound
    [226269] = true, -- Charhound
    [136408] = true, -- Darkhound
    [136398] = true, -- Illidari Satyr
    [136403] = true, -- Void Terror
    [198757] = true, -- Void Lasher
    [224466] = true, -- Voidwraith
    [98035] = true, -- Dreadstalker
    [143622] = true, -- Wild Imp
    [55659] = true, -- Wild Imp (alternate)
    [228574] = true, -- Pit Lord
    [228576] = true, -- Mother of Chaos
    [217429] = true, -- Overfiend
    [225493] = true, -- Doomguard
    [89] = true, -- Infernal

    -- Mage
    --[31216] = true, -- Mirror Images

    -- Shaman
    [29264] = true, -- Spirit Wolves (Enhancement)
    [77936] = true, -- Greater Storm Elemental
    [95061] = true, -- Greater Fire Elemental

    -- Druid
    [54983] = true, -- Treant
    [103822] = true, -- Treant (alternative)

    -- -- Priest
    [62982] = true, -- Mindbender

    -- Hunter
    [105419] = true, -- Dire Basilisk
    [62005] = true, -- Beast
    [228224] = true, -- Fenryr
    [228226] = true, -- Hati
    [225190] = true, -- Dark Hound
    [217228] = true, -- Blood Beast
    [234018] = true, -- Bear Pack Leader
}
BBP.secondaryPets = secondaryPets

--##################################################################################################
-- Fade out npcs from list
function BBP.FadeOutNPCs(frame)
    if BBP.isMidnight then return end
    local db = BetterBlizzPlatesDB
    local alpha = (db.enableNpNonTargetAlpha and (UnitIsUnit(frame.unit, "target") and 1 or db.nameplateNonTargetAlpha)) or (db.enableNpNonFocusAlpha and (UnitIsUnit(frame.unit, "focus") and 1 or db.nameplateNonTargetAlpha)) or 1
    frame:SetAlpha(alpha)
    frame.castBar:SetAlpha(alpha)
    frame.fadedNpc = nil

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    if info.isPlayer or not info.unitGUID then return end

    if UnitIsUnit(frame.unit, "pet") then
        return
    end

    if db.fadeNPCPvPOnly and not BBP.isInPvP then
        return
    end

    local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)
    local npcName = info.name

    if not config.fadeOutNPCsAlpha or BBP.needsUpdate then
        config.fadeOutNPCsAlpha = db.fadeOutNPCsAlpha
        --config.fadeAllButTarget = db.fadeAllButTarget
    end

    -- Handle fade out logic when target exists and fadeAllButTarget is enabled
    -- if config.fadeAllButTarget then
    --     if UnitExists("target") then
    --         if not info.isTarget and not info.isPlayer then
    --             frame:SetAlpha(config.fadeOutNPCsAlpha)
    --             frame.fadedNpc = true
    --         else
    --             frame:SetAlpha(1)
    --             frame.fadedNpc = nil
    --         end
    --     else
    --         frame:SetAlpha(1)
    --         frame.fadedNpc = nil
    --     end
    --     return
    -- end

    -- Convert npcName to lowercase for case-insensitive comparison
    local lowerCaseNpcName = strlower(npcName)

    -- Get the whitelist mode flag and appropriate NPC list
    local fadeOutNPCWhitelistOn = db.fadeOutNPCWhitelistOn
    local onlyFadeSecondaryPets = db.fadeOutNPCOnlyFadeSecondaryPets
    local npcListToCheck = fadeOutNPCWhitelistOn and db.fadeOutNPCsWhitelist or db.fadeOutNPCsList

    -- Check if the NPC is in the list by ID or name (case insensitive)
    local inList = false
    for _, npc in ipairs(npcListToCheck) do
        if npc.id == npcID or (npc.id and npc.id == npcID) then
            inList = true
            break
        elseif npc.name == npcName or strlower(npc.name) == lowerCaseNpcName then
            inList = true
            break
        end
    end

    -- Check if the unit is the current target
    if info.isTarget then
        frame:SetAlpha(alpha)
        frame.castBar:SetAlpha(alpha)
        frame.fadedNpc = nil
    elseif onlyFadeSecondaryPets and BBP.isInArena and mainPets[npcID] and info.isEnemy then
        local isFakePet = true
        for i = 1, 3 do
            if UnitIsUnit(frame.displayedUnit, "arenapet" .. i) then
                isFakePet = false
            end
        end
        if isFakePet then
            frame:SetAlpha(config.fadeOutNPCsAlpha)
            frame.castBar:SetAlpha(config.fadeOutNPCsAlpha)
            frame.fadedNpc = true
        end
    elseif onlyFadeSecondaryPets and secondaryPets[npcID] then
        frame:SetAlpha(config.fadeOutNPCsAlpha)
        frame.castBar:SetAlpha(config.fadeOutNPCsAlpha)
        frame.fadedNpc = true
    elseif fadeOutNPCWhitelistOn then
        -- If whitelist mode is on, fade out if not in the whitelist
        if inList then
            frame:SetAlpha(alpha)
            frame.castBar:SetAlpha(alpha)
            frame.fadedNpc = nil
        else
            frame:SetAlpha(config.fadeOutNPCsAlpha)
            frame.castBar:SetAlpha(config.fadeOutNPCsAlpha)
            frame.fadedNpc = true
        end
    else
        -- If not in whitelist mode, fade out if in the list
        if inList then
            frame:SetAlpha(config.fadeOutNPCsAlpha)
            frame.castBar:SetAlpha(config.fadeOutNPCsAlpha)
            frame.fadedNpc = true
        else
            frame:SetAlpha(alpha)
            frame.castBar:SetAlpha(alpha)
            frame.fadedNpc = nil
        end
    end
end

local function SetBarWidth(frame, width, useOffsets)
    frame.HealthBarsContainer:ClearPoint("RIGHT")
    frame.HealthBarsContainer:ClearPoint("LEFT")
    frame.castBar:ClearPoint("RIGHT")
    frame.castBar:ClearPoint("LEFT")

    if useOffsets then
        -- Use the +12 and -12 offset for npcData
        frame.HealthBarsContainer:SetPoint("LEFT", frame, "LEFT", -width + 12, 0)
        frame.HealthBarsContainer:SetPoint("RIGHT", frame, "RIGHT", width - 12, 0)

        frame.castBar:SetPoint("LEFT", frame, "LEFT", -width + 12, 0)
        frame.castBar:SetPoint("RIGHT", frame, "RIGHT", width - 12, 0)
    else
        -- Default behavior without offsets
        frame.HealthBarsContainer:SetPoint("LEFT", frame, "CENTER", -width, 0)
        frame.HealthBarsContainer:SetPoint("RIGHT", frame, "CENTER", width, 0)

        frame.castBar:SetPoint("LEFT", frame, "CENTER", -width, 0)
        frame.castBar:SetPoint("RIGHT", frame, "CENTER", width, 0)
    end
end

local function SetFriendlyBarWidthTemp(frame)
    if frame:IsForbidden() or not frame.unit or UnitCanAttack("player", frame.unit) then return end
    local width = (BetterBlizzPlatesDB.nameplateFriendlyWidth or 172.5)/2

    frame.HealthBarsContainer:ClearPoint("RIGHT")
    frame.HealthBarsContainer:ClearPoint("LEFT")
    frame.HealthBarsContainer:SetPoint("LEFT", frame, "CENTER", -width + 12, 0)
    frame.HealthBarsContainer:SetPoint("RIGHT", frame, "CENTER", width - 12, 0)
    frame.castBar:ClearPoint("RIGHT")
    frame.castBar:ClearPoint("LEFT")
    frame.castBar:SetPoint("LEFT", frame, "CENTER", -width + 12, 0)
    frame.castBar:SetPoint("RIGHT", frame, "CENTER", width - 12, 0)
    frame.bbpWidthAdjusted = true
end
BBP.SetFriendlyBarWidthTemp = SetFriendlyBarWidthTemp

local function SmallPetsInPvP(frame)
    local config = frame.BetterBlizzPlates.config
    if not config.smallPetsInPvP then return end
    if BBP.IsInCompStomp then return end

    if UnitIsOtherPlayersPet(frame.unit) or (BBP.isInPvP and not UnitIsPlayer(frame.unit)) or UnitIsUnit(frame.unit, "pet") then
        local db = BetterBlizzPlatesDB
        if not frame.bbpWidthHook then
            hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(self)
                if self:IsForbidden() or not frame.unit or UnitIsPlayer(frame.unit) then return end
                if BBP.IsInCompStomp then return end

                if UnitIsOtherPlayersPet(frame.unit) or (BBP.isInPvP and not UnitIsPlayer(frame.unit)) or UnitIsUnit(frame.unit, "pet") then
                    local db = BetterBlizzPlatesDB
                    frame.isSmallPet = true
                    SetBarWidth(frame, db.smallPetsWidth, false)
                else
                    frame.isSmallPet = false
                end
            end)
            frame.bbpWidthHook = true
        end

        frame.isSmallPet = true
        SetBarWidth(frame, db.smallPetsWidth, false)

    end
end
BBP.SmallPetsInPvP = SmallPetsInPvP


--##################################################################################################
-- Hide NPCs from list
function BBP.HideNPCs(frame, nameplate)
    if BBP.isMidnight then return end
    if not frame or not frame.displayedUnit then return end

    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not frame.bbpAlphaHook then
        hooksecurefunc(frame, "SetAlpha", function(self)
            if not self.bbpHiddenNPC or self.changingAlpha or self:IsForbidden() then return end
            self.changingAlpha = true
            if self.unit and not UnitIsUnit(self.unit, "target") then
                self:SetAlpha(0)
            end
            self.changingAlpha = nil
        end)
        frame.bbpAlphaHook = true
    end

    BBP.ShowFrame(frame)
    if frame.murlocModeActive then
        frame.murlocMode:Hide()
        frame.hideNameOverride = false
        frame.hideCastbarOverride = false
        if config.classIndicatorHideFriendlyHealthbar then
            frame.HealthBarsContainer:SetAlpha((info.isSelf and 1) or (frame.ciChange and 0) or 1)
            frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or (frame.ciChange and 0) or 0.22)
        else
            frame.HealthBarsContainer:SetAlpha((info.isSelf and 1) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 1)
            frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and (config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc) and 0) or 0.22)
        end
        ToggleNameplateBuffFrameVisibility(frame)
        frame.name:SetAlpha(1)
        frame.murlocModeActive = nil
    end

    local db = BetterBlizzPlatesDB
    local hideNPCArenaOnly = db.hideNPCArenaOnly
    local hideNPCWhitelistOn = db.hideNPCWhitelistOn
    --local hideNPCPetsOnly = db.hideNPCPetsOnly
    local inBg = BBP.isInPvP
    --local isPet = (UnitGUID(frame.displayedUnit) and select(6, strsplit("-", UnitGUID(frame.displayedUnit))) == "Pet")
    local hideAllNeutral = db.hideNPCAllNeutral and info.isNeutral and not UnitAffectingCombat(frame.unit)
    local hideSecondaryPets = db.hideNPCHideSecondaryPets
    local murlocSecondary = db.hideNPCSecondaryShowMurloc
    local hideOthersPets = db.hideNPCHideOthersPets
    local isTarget = UnitIsUnit(frame.displayedUnit, "target")

    if hideNPCArenaOnly and not inBg then
        return
    end

    if BBP.IsInCompStomp then return end

    -- Skip if the unit is a player
    if info.isPlayer then
        BBP.ResetFrame(frame, config, info)
        return
    end

    if hideAllNeutral and not isTarget then
        BBP.HideNameplate(frame)
        return
    end

    if hideOthersPets and ((info.isFriend and UnitIsOtherPlayersPet(frame.unit)) or (UnitIsOwnerOrControllerOfUnit("player", frame.unit) and not UnitIsUnit("pet", frame.unit))) then
        if UnitCreatureType(frame.unit) ~= "Totem" then
            if UnitIsOwnerOrControllerOfUnit("player", frame.unit) then
                if UnitPlayerControlled("target") then
                    if not isTarget then
                        BBP.HideNameplate(frame)
                    end
                    return
                end
            else
                if not isTarget then
                    BBP.HideNameplate(frame)
                end
                return
            end
        end
    end

    local unitGUID = UnitGUID(frame.displayedUnit)
    if not unitGUID then return end

    local npcID = BBP.GetNPCIDFromGUID(unitGUID)
    local npcName = UnitName(frame.displayedUnit)
    local lowerCaseNpcName = strlower(npcName)

    -- Initialize murlocMode if not present
    BBP.InitMurlocMode(frame, config, db)

    local listToCheck = hideNPCWhitelistOn and db.hideNPCsWhitelist or db.hideNPCsList
    local inList, showMurloc = BBP.CheckNPCList(listToCheck, npcID, lowerCaseNpcName)

    -- Determine if the frame should be shown based on the list check or if it's the current target
    if isTarget then
        BBP.ShowFrame(frame)
        local alpha = (info.isFriend and ((config.friendlyHideHealthBarNpc and not (BetterBlizzPlatesDB.friendlyHideHealthBarShowPet and info.isPet))) and 0) or 1
        frame.HealthBarsContainer:SetAlpha(alpha)
        frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 0.22)
    elseif BBP.isInArena and hideSecondaryPets and mainPets[npcID] and info.isEnemy then
        local isFakePet = true
        for i = 1, 3 do
            if UnitIsUnit(frame.displayedUnit, "arenapet" .. i) then
                isFakePet = false
                break
            end
        end
        if isFakePet then
            if murlocSecondary then
                BBP.ShowMurloc(frame)
            else
                BBP.HideNameplate(frame)
            end
        end
    elseif hideNPCWhitelistOn then
        if inList then
            if showMurloc then
                BBP.ShowMurloc(frame)
            else
                BBP.ShowFrame(frame)
            end
        else
            if murlocSecondary and secondaryPets[npcID] then
                BBP.ShowMurloc(frame)
            else
                BBP.HideNameplate(frame)
            end
        end
    elseif inList then
        if showMurloc then
            BBP.ShowMurloc(frame)
        else
            BBP.HideNameplate(frame)
        end
    elseif hideSecondaryPets and secondaryPets[npcID] then
        if murlocSecondary then
            BBP.ShowMurloc(frame)
        else
            BBP.HideNameplate(frame)
        end
    else
        BBP.ShowFrame(frame)
    end
end

-- Resets the frame to default display settings
function BBP.ResetFrame(frame, config, info)
    if frame.murlocModeActive then
        frame.murlocMode:Hide()
        frame.hideNameOverride = false
        frame.hideCastbarOverride = false
        if config.classIndicatorHideFriendlyHealthbar then
            frame.HealthBarsContainer:SetAlpha((info.isSelf and 1) or (frame.ciChange and 0) or 1)
            frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or (frame.ciChange and 0) or 0.22)
        else
            frame.HealthBarsContainer:SetAlpha((info.isSelf and 1) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 1)
            frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and (config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc) and 0) or 0.22)
        end
        ToggleNameplateBuffFrameVisibility(frame)
        frame.name:SetAlpha(1)
        frame.murlocModeActive = nil
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
function BBP.ShowFrame(frame)
    if frame.bbpHiddenNPC then
        frame.bbpHiddenNPC = nil
        frame:SetAlpha(1)
    end
    frame.hideCastInfo = false
    if frame.murlocMode then
        frame.murlocMode:Hide()
    end
    frame.murlocModeActive = nil
    frame.hideNameOverride = false
    frame.hideCastbarOverride = false
end

-- Shows the murlocMode on the frame
function BBP.ShowMurloc(frame)
    if frame.bbpHiddenNPC then
        frame.bbpHiddenNPC = nil
        frame:SetAlpha(1)
    end
    frame.murlocModeActive = true
    frame.HealthBarsContainer:SetAlpha(0)
    frame.HealthBarsContainer.alphaZero = true
    frame.selectionHighlight:SetAlpha(0)
    frame.AurasFrame:SetAlpha(0)
    frame.name:SetAlpha(0)
    frame.murlocMode:Show()
    frame.castBar:Hide()
    frame.hideNameOverride = true
    frame.hideCastbarOverride = true
end

-- Hides the nameplate by setting its parent to shadowRealm -- addon blocked error in 11.1.7
function BBP.HideNameplate(frame)
    frame.bbpHiddenNPC = true
    frame:SetAlpha(0)
end

local function ShowLastNameOnlyNpc(frame)
    if BBP.isMidnight then return end
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if info.isNpc then
        local unit = frame.unit
        local creatureType = unit and UnitCreatureType(unit)
        local name = info.name
        if creatureType == "Totem" then
            -- Use first word (e.g., "Stoneclaw" from "Stoneclaw Totem")
            local firstWord = name:match("^[^%s%-]+")
            if firstWord then
                frame.name:SetText(firstWord)
            end
        else
            -- Use last word (e.g., "Guardian" from "Frostwolf Guardian")
            local lastWord = name:match("([^%s]+)$")
            frame.name:SetText(lastWord)
        end
    end
end

local offTanks = {}

local function GetGroupTanks()
	local tanks = {}
	local unitPrefix = IsInRaid() and "raid" or "party"
	local maxUnits = IsInRaid() and MAX_RAID_MEMBERS or GetNumGroupMembers()

	for i = 1, maxUnits do
		local unit = unitPrefix .. i
		local role = UnitGroupRolesAssigned(unit)

		-- Classic: fallback to Raid Info or Party Leader
		if role == "NONE" then
			if unitPrefix == "raid" then
				local _, _, _, _, _, _, _, _, _, raidRole = GetRaidRosterInfo(i)
				if raidRole == "MAINTANK" or raidRole == "MAINASSIST" then
					role = "TANK"
				end
			elseif UnitIsGroupLeader(unit) then
				role = "TANK"
			end
		end

		if role == "TANK" then--and not UnitIsUnit(unit, "player") then
			table.insert(tanks, unit)
		end

		-- Check pet if enabled
		local pet = unitPrefix .. "pet" .. i
		if UnitExists(pet) and (role == "TANK") then
			table.insert(tanks, pet)
		end
	end

	return tanks
end

function BBP.ColorThreat(frame)
    if not frame or not frame.unit then return end
    if UnitIsPlayer(frame.unit) then return end
    if UnitIsFriend(frame.unit, "player") then return end
    if UnitIsTapDenied(frame.unit) then return end

    local hideSolo = BetterBlizzPlatesDB.enemyColorThreatHideSolo and not IsInGroup()
    if hideSolo then return end
    local playerCombatOnly = BetterBlizzPlatesDB.enemyColorThreatCombatOnlyPlayer and not InCombatLockdown()
    if playerCombatOnly then return end
    local combatOnly = BetterBlizzPlatesDB.enemyColorThreatCombatOnly and not UnitAffectingCombat(frame.unit)
    if combatOnly then return end


    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.unit)
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local r, g, b

    if BBP.isRoleTank then
        -- Default color: no aggro
        r, g, b = unpack(BetterBlizzPlatesDB.tankNoAggroColorRGB)

        if isTanking and threatStatus then
            if threatStatus == 3 then
                if config.npcHealthbarColor then
                    return
                end
                -- Full threat
                r, g, b = unpack(BetterBlizzPlatesDB.tankFullAggroColorRGB)
            elseif threatStatus == 2 then
                -- Losing threat
                r, g, b = unpack(BetterBlizzPlatesDB.tankLosingAggroColorRGB)
            else
                r, g, b = GetThreatStatusColor(threatStatus)
            end
        elseif threatStatus then
            -- Not tanking — check if an offtank or a pet has full aggro
            local targetUnit = frame.unit.."target"
            if not UnitIsPlayer(targetUnit) then
                local offTanking, otherThreatStatus = UnitDetailedThreatSituation(targetUnit, frame.unit)
                if offTanking and otherThreatStatus and otherThreatStatus >= 2 then
                    r, g, b = unpack(BetterBlizzPlatesDB.tankOffTankAggroColorRGB)
                end
            else
                for _, unit in ipairs(offTanks) do
                    local offTanking, otherThreatStatus = UnitDetailedThreatSituation(unit, frame.unit)
                    if offTanking and otherThreatStatus and otherThreatStatus >= 2 then
                        r, g, b = unpack(BetterBlizzPlatesDB.tankOffTankAggroColorRGB)
                        break
                    end
                end
            end
        elseif config.npcHealthbarColor then
            return
        end
    else
        local isTargeted = false--UnitIsUnit(frame.unit.."target", "player") --bbp.ismidnight
        local hasAggro = isTanking-- or (threatStatus and threatStatus > 1)
        if config.npcHealthbarColor and not hasAggro then
            if isTargeted then
                r, g, b = unpack(BetterBlizzPlatesDB.dpsOrHealTargetAggroColorRGB)
                frame.healthBar:SetStatusBarColor(r, g, b)
                return
            else
                return
            end
        end

        if hasAggro then
            r, g, b = unpack(BetterBlizzPlatesDB.dpsOrHealFullAggroColorRGB)
        elseif isTargeted then
            r, g, b = unpack(BetterBlizzPlatesDB.dpsOrHealTargetAggroColorRGB)
        else
            r, g, b = unpack(BetterBlizzPlatesDB.dpsOrHealNoAggroColorRGB)
        end
    end

    frame.healthBar:SetStatusBarColor(r, g, b)
end

--################################################################################################
-- Color NPCs
function BBP.ColorNpcHealthbar(frame)
    if BBP.isMidnight then return end
    if not frame or not frame.unit then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    -- Skip if the unit is a player
    if info.isPlayer then
        if config.npcHealthbarColor then
            config.npcHealthbarColor = nil
            CompactUnitFrame_UpdateName(frame)
        end
        return
    end
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
    elseif config.npcHealthbarColor then
        config.npcHealthbarColor = nil
        CompactUnitFrame_UpdateName(frame)
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
            -- If the aura has an ID, add it to spellIdLookup and skip the name
            BBP.spellIdLookup[npc.id] = {priority = npc.priority, color = npc.entryColors.text, onlyMine = npc.onlyMine}
        elseif npc.name then
            -- Only add to auraNameLookup if no ID is present
            local lowerCaseName = strlower(npc.name)
            BBP.auraNameLookup[lowerCaseName] = {priority = npc.priority, color = npc.entryColors.text, onlyMine = npc.onlyMine}
        end
    end

    BBP.auraListNeedsUpdate = false -- Reset the flag
end

function BBP.AuraColor(frame)
    if true then return end
    if not frame or not frame.unit then return end
    if frame.unit == "player" then return end
    -- Ensure the aura lookup tables are up-to-date
    BBP.UpdateAuraLookupTables()

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    if BetterBlizzPlatesDB.auraColorPvEOnly and (BBP.isInPvP or UnitIsPlayer(frame.unit)) then
        if config.auraColorRGB then
            config.auraColorRGB = nil
            BBP.CompactUnitFrame_UpdateHealthColor(frame)
        end
        return
    end
    local highestPriority = 0
    local auraColor = nil

    local function ProcessAura(name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod)
        -- Check by spellId first
        local spellInfo = BBP.spellIdLookup[spellId]

        -- If no spellId is found, fall back to checking by name
        if not spellInfo and name then
            spellInfo = BBP.auraNameLookup[strlower(name)]
        end

        -- If we found a valid spellInfo and it has a higher priority, apply the color
        if spellInfo and spellInfo.priority > highestPriority then
            -- Check if onlyMine is set, and ensure the aura was cast by the player if required
            if spellInfo.onlyMine and source ~= "player" then
                config.auraColorRGB = nil
            else
                highestPriority = spellInfo.priority
                auraColor = spellInfo.color
            end
        end

        return highestPriority >= 10
    end

    AuraUtil.ForEachAura(frame.unit, "HELPFUL", nil, ProcessAura)
    AuraUtil.ForEachAura(frame.unit, "HARMFUL", nil, ProcessAura)

    -- Set the vertex color based on the highest priority aura color
    if auraColor then
        config.auraColorRGB = auraColor
        frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b, config.auraColorRGB.a)
        if (config.focusTargetIndicator and config.focusTargetIndicatorColorNameplate and frame == BBP.currentFocusNameplate)  then
            frame.healthBar:SetStatusBarColor(unpack(config.focusTargetIndicatorColorNameplateRGB))
        end
        if (config.targetIndicator and config.targetIndicatorColorNameplate and frame == BBP.currentTargetNameplate) then
            frame.healthBar:SetStatusBarColor(unpack(config.targetIndicatorColorNameplateRGB))
        end
    else
        config.auraColorRGB = nil
        BBP.CompactUnitFrame_UpdateHealthColor(frame)
    end
end

local UnitAuraEventFrame = nil
local function UnitAuraColorEvent(self, event, unit, unitAuraUpdateInfo)
    if unit:find("nameplate") then
        local nameplate, frame = BBP.GetSafeNameplate(unit)
        if not frame then return end
        local db = BetterBlizzPlatesDB
        if db.auraColor then
            BBP.AuraColor(frame)
        end
        if BBP.isInBg then
            if db.bgIndicator or db.classIndicator then
                if unitAuraUpdateInfo then
                    local foundID
                    if unitAuraUpdateInfo.addedAuras then
                        for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                            if BBP.BgIndicatorColors[aura.spellId] then
                                foundID = aura.spellId
                            end
                        end
                    end

                    if unitAuraUpdateInfo.updatedAuraInstanceIDs then
                        for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                            local auraInfo = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                            if auraInfo and auraInfo.spellId then
                                if BBP.BgIndicatorColors[auraInfo.spellId] then
                                    foundID = auraInfo.spellId
                                end
                            end
                        end
                    end

                    if unitAuraUpdateInfo.removedAuraInstanceIDs then
                        for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                            local auraInfo = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                            if auraInfo and auraInfo.spellId then
                                if BBP.BgIndicatorColors[auraInfo.spellId] then
                                    foundID = 0
                                end
                            end
                        end
                    end

                    if foundID then
                        if db.bgIndicator then
                            BBP.BgIndicator(frame, foundID)
                        end
                        if db.classIndicator then
                            BBP.ClassIndicator(frame, foundID)
                        end
                    end
                end
            end
        end
    end
end

function BBP.CreateUnitAuraEventFrame()
    -- if UnitAuraEventFrame then
    --     return
    -- end
    -- UnitAuraEventFrame = CreateFrame("Frame")
    -- UnitAuraEventFrame:SetScript("OnEvent", UnitAuraColorEvent)
    -- UnitAuraEventFrame:RegisterEvent("UNIT_AURA")
end

-- can run before a nameplate is fetched so needs updated info
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if not frame.unit or not frame.unit:find("nameplate") then return end
    if frame:IsForbidden() then return end

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
        config.personalNpTRP3Color = BetterBlizzPlatesDB.personalNpTRP3Color

        config.updateHealthColorInitialized = true
    end

    if info.isSelf then
        if config.personalNpTRP3Color then
            local r,g,b = GetRPNameColor("player")
            if r then
                frame.healthBar:SetStatusBarColor(r, g, b)
            end
        elseif config.classColorPersonalNameplate then
            frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
        end
    end

    if config.friendlyHealthBarColor or config.enemyHealthBarColor then
        ColorNameplateByReaction(frame)
    end

    if config.colorNPC then--and config.npcHealthbarColor then --bodify need npc check here since it can run before np added
        --frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
        BBP.ColorNpcHealthbar(frame)
    end

    if ( BetterBlizzPlatesDB.enemyColorThreat and (BBP.isInPvE or (BetterBlizzPlatesDB.threatColorAlwaysOn and not BBP.isInPvP)) ) and not info.isSelf then
        BBP.ColorThreat(frame)
    end

    if config.auraColor and config.auraColorRGB then
        BBP.AuraColor(frame)
        --frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b)
    end

    if (config.focusTargetIndicator and config.focusTargetIndicatorColorNameplate and info.isFocus) or config.focusTargetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.focusTargetIndicatorColorNameplateRGB))--mby replace info.isFocus with unit call bodify
        --BBP.FocusTargetIndicator(frame)
    end

    if (config.targetIndicator and config.targetIndicatorColorNameplate and info.isTarget) or config.targetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.targetIndicatorColorNameplateRGB))
    end

    if config.executeIndicatorInRangeColor and frame.executeIndicatorInRange then
        frame.healthBar:SetStatusBarColor(unpack(config.executeIndicatorInRangeColorRGB))
        frame.needsRecolor = true
    end

    if config.castBarEmphasisHealthbarColor then
        if frame.emphasizedCast then
            local isCasting = UnitCastingInfo(frame.unit) or UnitChannelInfo(frame.unit)
            if isCasting then
                frame.healthBar:SetStatusBarColor(frame.emphasizedCast.entryColors.text.r, frame.emphasizedCast.entryColors.text.g, frame.emphasizedCast.entryColors.text.b)
            end
        end
    end

    if config.totemIndicator and info.isNpc then
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
                        -- end
                    end
                else
                    if config.totemIndicatorColorHealthBar then
                        frame.healthBar:SetStatusBarColor(unpack(totemColor))
                    end
                    -- if config.totemIndicatorColorName then
                    --     frame.name:SetVertexColor(unpack(totemColor))
                    -- end
                end
            else
                config.totemColorRGB = nil
            end
        end
    end

    if frame.mainPetColor then
        frame.healthBar:SetStatusBarColor(unpack(frame.mainPetColor))
    end
end)


-- Copy of blizzards update health color function
function BBP.CompactUnitFrame_UpdateHealthColor(frame, exitLoop)
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
        config.personalNpTRP3Color = BetterBlizzPlatesDB.personalNpTRP3Color

        config.updateHealthColorInitialized = true
    end

	local r, g, b;
	local unitIsConnected = UnitIsConnected(frame.unit);
	local unitIsDead = unitIsConnected and UnitIsDead(frame.unit);
	local unitIsPlayer = UnitIsPlayer(frame.unit) or UnitIsPlayer(frame.displayedUnit);

    if info.isSelf then
        if config.classColorPersonalNameplate then
            frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
        --else return end
        end
    end

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
			--debug
			--classColor = RAID_CLASS_COLORS["PRIEST"];
			local useClassColors = CompactUnitFrame_GetOptionUseClassColors(frame, frame.optionTable);
			if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) or UnitTreatAsPlayerForDisplay(frame.unit)) and classColor and useClassColors ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( UnitIsTapDenied(frame.unit) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = 0.9, 0.9, 0.9;
			elseif ( frame.optionTable.colorHealthBySelection ) then
				-- Use color based on the type of unit (neutral, etc.)
				if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) and not UnitIsFriend("player", frame.unit) ) then
					r, g, b = 1.0, 0.0, 0.0;
				elseif ( UnitIsPlayer(frame.displayedUnit) and UnitIsFriend("player", frame.displayedUnit) ) then
					-- We don't want to use the selection color for friendly player nameplates because
					-- it doesn't show player health clearly enough.
					r, g, b = 0.667, 0.667, 1.0;
				else
					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors);
				end
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

    if config.friendlyHealthBarColor or config.enemyHealthBarColor then
        if not exitLoop then
            ColorNameplateByReaction(frame)
        end
    end

    if config.colorNPC and config.npcHealthbarColor then
        frame.healthBar:SetStatusBarColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
    end

    if ( BetterBlizzPlatesDB.enemyColorThreat and (BBP.isInPvE or (BetterBlizzPlatesDB.threatColorAlwaysOn and not BBP.isInPvP)) ) and not info.isSelf then
        BBP.ColorThreat(frame)
    end

    if (config.focusTargetIndicator and config.focusTargetIndicatorColorNameplate and info.isFocus) or config.focusTargetIndicatorTestMode then
        frame.healthBar:SetStatusBarColor(unpack(config.focusTargetIndicatorColorNameplateRGB))
        --BBP.FocusTargetIndicator(frame)
    end

    if config.auraColor and config.auraColorRGB then --bodify
        frame.healthBar:SetStatusBarColor(config.auraColorRGB.r, config.auraColorRGB.g, config.auraColorRGB.b, config.auraColorRGB.a)
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

    if config.totemIndicator and info.isNpc then
        local totemColor = config.totemColorRGB or config.randomTotemColor
        if totemColor then
            if config.totemIndicatorEnemyOnly then
                if not info.isFriend then
                    if config.totemIndicatorColorHealthBar then
                        frame.healthBar:SetStatusBarColor(unpack(totemColor))
                    end
                    if config.totemIndicatorColorName then
                        frame.name:SetVertexColor(unpack(totemColor))
                    end
                end
            else
                if config.totemIndicatorColorHealthBar then
                    frame.healthBar:SetStatusBarColor(unpack(totemColor))
                end
                if config.totemIndicatorColorName then
                    frame.name:SetVertexColor(unpack(totemColor))
                end
            end
        end
    end
    if info.isSelf then --without this self nameplate reset to green after targeting self, figure out more
        if config.personalNpTRP3Color then
            local r,g,b = GetRPNameColor("player")
            if r then
                frame.healthBar:SetStatusBarColor(r, g, b)
            end
        elseif config.classColorPersonalNameplate then
            frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
        end
    end
end

local function NameplateShadowAndMouseoverHighlight(frame)
    local showShadow = BetterBlizzPlatesDB.showNameplateShadow
    local highlightOnMouseover = BetterBlizzPlatesDB.highlightNpShadowOnMouseover

    if not showShadow and not highlightOnMouseover then
        return
    end

    local onlyShowHighlight = BetterBlizzPlatesDB.onlyShowHighlightedNpShadow
    local keepTargetHighlighted = BetterBlizzPlatesDB.keepNpShadowTargetHighlighted
    local healthVisible = frame.HealthBarsContainer.alphaZero ~= true-- and frame.healthBar:GetWidth() > 5
    local r,g,b,a = unpack(BetterBlizzPlatesDB.nameplateShadowRGB)
    local hlR,hlG,hlB,hlA = unpack(BetterBlizzPlatesDB.nameplateShadowHighlightRGB)
    local shadowAlpha = (not healthVisible and 0) or onlyShowHighlight and 0 or a
    local onlyOnTarget = BetterBlizzPlatesDB.showNameplateShadowOnlyTarget

    -- Create the highlight texture directly on the frame if it doesn't exist
    if not frame.BBPmouseoverTex then
        frame.BBPmouseoverTex = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        frame.BBPmouseoverTex:SetAtlas("AdventureMap-textlabelglow")
        frame.BBPmouseoverTex:SetPoint("CENTER", frame.HealthBarsContainer, "CENTER", 0, 0)
        frame.BBPmouseoverTex:SetDesaturated(true)

        -- frame.BBPmouseoverTex:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -6, 9)
        -- frame.BBPmouseoverTex:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", 6, -9)

        hooksecurefunc(frame.BBPmouseoverTex, "SetVertexColor", function(self)
            if frame.unit and UnitIsUnit(frame.unit, "player") then
                self:SetAlpha(0)
            end
        end)

        -- frame.healthBar:HookScript("OnHide", function(self)
        --     if self:IsForbidden() then return end
        --     if frame.BBPmouseoverTex then
        --         frame.BBPmouseoverTex:SetAlpha(0)
        --     end
        -- end)
    end

    frame.BBPmouseoverTex:ClearAllPoints()

    local isFriendly = frame.unit and not UnitCanAttack("player", frame.unit)
    local nameplateWidth = isFriendly and BetterBlizzPlatesDB.nameplateFriendlyWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
    nameplateWidth = nameplateWidth or 110
    local horizontalOffset = math.floor((nameplateWidth * 0.065) + 0.5)
    local verticalOffset = 10

    frame.BBPmouseoverTex:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -horizontalOffset, verticalOffset)
    frame.BBPmouseoverTex:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", horizontalOffset, -verticalOffset)

    if onlyOnTarget then
        if UnitIsUnit("target", frame.unit) then
            if keepTargetHighlighted and healthVisible then
                frame.BBPmouseoverTex:SetVertexColor(hlR, hlG, hlB, hlA)
            else
                frame.BBPmouseoverTex:SetVertexColor(r, g, b, shadowAlpha)
            end
        else
            frame.BBPmouseoverTex:SetVertexColor(0, 0, 0, 0)
        end
    else
        if keepTargetHighlighted and UnitIsUnit("target", frame.unit) and healthVisible then
            frame.BBPmouseoverTex:SetVertexColor(hlR, hlG, hlB, hlA)
        else
            frame.BBPmouseoverTex:SetVertexColor(r, g, b, shadowAlpha)
        end
    end
end
BBP.NameplateShadowAndMouseoverHighlight = NameplateShadowAndMouseoverHighlight


local periodicCheckTimer
local function StartPeriodicCheck()
    if periodicCheckTimer then return end

    periodicCheckTimer = C_Timer.NewTicker(0.1, function()
        if not UnitExists("mouseover") then
            local onlyShowHighlight = BetterBlizzPlatesDB.onlyShowHighlightedNpShadow

            for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                local frame = nameplate.UnitFrame
                if frame and frame.BBPmouseoverTex then
                    local healthVisible = frame.HealthBarsContainer.alphaZero ~= true-- and frame.healthBar:GetWidth() > 5
                    local r,g,b,a = unpack(BetterBlizzPlatesDB.nameplateShadowRGB)
                    local hlR,hlG,hlB,hlA = unpack(BetterBlizzPlatesDB.nameplateShadowHighlightRGB)
                    local shadowAlpha = (not healthVisible and 0) or onlyShowHighlight and 0 or a
                    local onlyOnTarget = BetterBlizzPlatesDB.showNameplateShadowOnlyTarget
                    if BetterBlizzPlatesDB.keepNpShadowTargetHighlighted and UnitIsUnit("target", frame.unit) and healthVisible then
                        frame.BBPmouseoverTex:SetVertexColor(hlR, hlG, hlB, hlA)
                    else
                        if onlyOnTarget and not UnitIsUnit(frame.unit, "target") then
                            frame.BBPmouseoverTex:SetVertexColor(r, g, b, 0)
                        else
                            frame.BBPmouseoverTex:SetVertexColor(r, g, b, shadowAlpha)
                        end
                    end
                end
            end
            periodicCheckTimer:Cancel()
            periodicCheckTimer = nil
        end
    end)
end

local function EnableMouseoverChecker()
    if BBP.mouseoverChecker then return end
    if BetterBlizzPlatesDB.showNameplateShadow or BetterBlizzPlatesDB.highlightNpShadowOnMouseover then
        BBP.mouseoverChecker = true
        local checkMouseoverFrame = CreateFrame("Frame")
        checkMouseoverFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        checkMouseoverFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        checkMouseoverFrame:SetScript("OnEvent", function(_, event)
            local nameplate, moFrame = BBP.GetSafeNameplate("mouseover")

            for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                local frame = nameplate.UnitFrame
                if frame and frame.BBPmouseoverTex then
                    local isMouseover = UnitIsUnit(frame.unit, "mouseover") and BetterBlizzPlatesDB.highlightNpShadowOnMouseover
                    local isTarget = UnitIsUnit(frame.unit, "target")
                    local healthVisible = frame.HealthBarsContainer.alphaZero ~= true-- and frame.healthBar:IsShown() and frame.healthBar:GetWidth() > 5
                    local onlyOnTarget = BetterBlizzPlatesDB.showNameplateShadowOnlyTarget
                    local r,g,b,a = unpack(BetterBlizzPlatesDB.nameplateShadowRGB)
                    local hlR,hlG,hlB,hlA = unpack(BetterBlizzPlatesDB.nameplateShadowHighlightRGB)

                    if (isMouseover or (isTarget and BetterBlizzPlatesDB.keepNpShadowTargetHighlighted)) and healthVisible then
                        frame.BBPmouseoverTex:SetVertexColor(hlR, hlG, hlB, hlA)
                    else
                        if onlyOnTarget and not UnitIsUnit(frame.unit, "target") then
                            frame.BBPmouseoverTex:SetVertexColor(0, 0, 0, 0)
                        else
                            local onlyShowHighlight = BetterBlizzPlatesDB.onlyShowHighlightedNpShadow
                            local shadowAlpha = (not healthVisible and 0) or onlyShowHighlight and 0 or a
                            frame.BBPmouseoverTex:SetVertexColor(r, g, b, shadowAlpha)
                        end
                    end
                end
            end

            -- Start periodic check to detect when the unit no longer exists (event does not trigger when it goes to nil)
            if moFrame then
                StartPeriodicCheck()
            end
        end)
    end
end


local function ShowFriendlyGuildName(frame, unit)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    if config.showGuildNames and (info.isFriend or (config.personalBarTweaks and info.isSelf)) then
        if not config.guildNameInitialized then
            config.guildNameColor = BetterBlizzPlatesDB.guildNameColor
            config.guildNameColorRGB = BetterBlizzPlatesDB.guildNameColorRGB
            config.guildNameScale = BetterBlizzPlatesDB.guildNameScale

            config.guildNameInitialized = true
        end
        if not frame.guildName then
            frame.guildName = frame:CreateFontString(nil, "BACKGROUND", "SystemFont_NamePlateFixed")
            local db = BetterBlizzPlatesDB
            if db.useCustomFont then
                BBP.SetFontBasedOnOption(frame.guildName, 9, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "")
            else
                local font, size, outline = frame.name:GetFont()
                frame.guildName:SetFont(font, 9, outline)
            end
            frame.guildName:SetIgnoreParentScale(true)
        end

        local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
        if guildName and (frame.name:GetAlpha() ~= 0) then
            local hasNameText = not issecretvalue(frame.name:GetText()) and frame.name:GetText() ~= ""
            if hasNameText then
                if BBP.needsUpdate then
                    local font, size, outline = frame.name:GetFont()
                    frame.guildName:SetFont(font, 9, outline)
                end
                frame.guildName:SetText("<"..guildName..">")
                if config.guildNameColor then
                    frame.guildName:SetTextColor(unpack(config.guildNameColorRGB))
                else
                    frame.guildName:SetTextColor(frame.name:GetTextColor())
                end
                frame.guildName:ClearAllPoints()
                if frame.HealthBarsContainer:GetAlpha() == 0 then
                    frame.guildName:SetPoint("TOP", frame.name, "BOTTOM", 0, 0)
                else
                    frame.guildName:SetPoint("TOP", frame.healthBar, "BOTTOM", 0, -3)
                end
                frame.guildName:SetScale(config.guildNameScale or 1)
            else
                frame.guildName:SetText("")
            end
        else
            frame.guildName:SetText("")
        end
    elseif frame.guildName then
        frame.guildName:SetText("")
    end
end


function BBP.NameplateTargetAlpha(frame)
    local config = frame.BetterBlizzPlates.config

    if frame.fadedNpc then
        return
    end

    if not config.npTargetAlphaInit or BBP.needsUpdate then
        config.enableNpNonTargetAlphaTargetOnly = BetterBlizzPlatesDB.enableNpNonTargetAlphaTargetOnly
        config.nameplateNonTargetAlpha = BetterBlizzPlatesDB.nameplateNonTargetAlpha
        config.enableNpNonFocusAlpha = BetterBlizzPlatesDB.enableNpNonFocusAlpha
        config.enableNpNonTargetAlphaFullAlphaCasting = BetterBlizzPlatesDB.enableNpNonTargetAlphaFullAlphaCasting

        config.npTargetAlphaInit = true
    end

    local unit = frame.unit
    local isPlayer = false--UnitIsUnit(unit, "player")
    local isTarget = UnitIsUnit(unit, "target")
    local isFocus = UnitIsUnit(unit, "focus")

    local isCasting = config.enableNpNonTargetAlphaFullAlphaCasting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))

    if isCasting then
        frame:SetAlpha(1)
        return
    end

    if isPlayer or isTarget or (isFocus and config.enableNpNonFocusAlpha) then
        frame:SetAlpha(1)
        return
    end

    if config.enableNpNonTargetAlphaTargetOnly and UnitExists("target") then
        frame:SetAlpha(config.nameplateNonTargetAlpha)
    elseif not config.enableNpNonTargetAlphaTargetOnly then
        frame:SetAlpha(config.nameplateNonTargetAlpha)
    else
        frame:SetAlpha(1)
    end
end

--################################################################################################
-- Apply raidmarker change
function BBP.ApplyRaidmarkerChanges(frame)
    local config = frame.BetterBlizzPlates.config

    if not config.raidmarkInitialized or BBP.needsUpdate then
        config.raidmarkIndicatorAnchor = BetterBlizzPlatesDB.raidmarkIndicatorAnchor or "TOP"
        config.raidmarkIndicatorXPos = BetterBlizzPlatesDB.raidmarkIndicatorXPos
        config.raidmarkIndicatorYPos = BetterBlizzPlatesDB.raidmarkIndicatorYPos
        config.raidmarkIndicatorScale = BetterBlizzPlatesDB.raidmarkIndicatorScale
        config.raidmarkIndicatorRaiseStrata = BetterBlizzPlatesDB.raidmarkIndicatorRaiseStrata
        config.raidmarkIndicatorFullAlpha = BetterBlizzPlatesDB.raidmarkIndicatorFullAlpha
        config.raidmarkInitialized = true
    end

    if config.raidmarkIndicator then

        local shouldMove = not BetterBlizzPlatesDB.raidmarkerPvPOnly or BBP.isInPvP

        if shouldMove then
            if config.raidmarkIndicatorAnchor == "TOP" then
                frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.name, config.raidmarkIndicatorAnchor, config.raidmarkIndicatorXPos, config.raidmarkIndicatorYPos)
            else
                local hiddenHealthbarOffset = (config.friendlyHideHealthBar and config.raidmarkIndicatorAnchor == "BOTTOM" and frame.HealthBarsContainer:GetAlpha() == 0) and frame.HealthBarsContainer:GetHeight() + 10 or 0
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
    if config.raidmarkIndicatorRaiseStrata then
        frame.RaidTargetFrame:SetFrameStrata("HIGH")
    end
    if config.raidmarkIndicatorFullAlpha then
        frame.RaidTargetFrame:SetIgnoreParentAlpha(true)
        frame.RaidTargetFrame:SetAlpha(1)
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

function BBP.RefUnitAuraTotally(unitFrame)
    local unit = unitFrame.unit
    BBP.UpdateBuffs(unitframe.AurasFrame, unit, nil, {}, unitFrame)
end

local auraModuleIsOn = false
function BBP.RunAuraModule()
    if BBP.isMidnight then return end
    auraModuleIsOn = true

    BBP.UpdateAuraTypeColors()

    function BBP.HidePersonalBuffFrame()
        if (PersonalFriendlyBuffFrame ~= nil) then
            local parentNameplate = PersonalFriendlyBuffFrame:GetParent();
            if (parentNameplate ~= nil and parentNameplate.UnitFrame ~= nil and not UnitIsUnit(parentNameplate.UnitFrame.unit, "player")) then
                PersonalFriendlyBuffFrame:Hide();
            else
                local hideDefaultPersonalNameplateAuras = BetterBlizzPlatesDB.hideDefaultPersonalNameplateAuras
                PersonalFriendlyBuffFrame:SetShown(not hideDefaultPersonalNameplateAuras);
            end
        end
    end

    function BBP.On_NpRefreshOnce(frame)
        --if unitFrame:IsForbidden() then return end
        BBP.RefUnitAuraTotally(frame)
    end


    local function UIObj_Event(self, event, ...)
        local unit, unitAuraUpdateInfo = ...
        -- if unitAuraUpdateInfo then
        --     for key, _ in pairs(unitAuraUpdateInfo) do
        --         print("Key:", key)
        --     end
        -- end
        if unit:find("nameplate") then
            local nameplate, frame = BBP.GetSafeNameplate(unit)
            if frame then
                BBP.OnUnitAuraUpdate(frame.AurasFrame, unit, unitAuraUpdateInfo)
            end
        end
    end

    local UIObjectDriveFrame = CreateFrame("Frame", "BBP_Aura", UIParent)
    UIObjectDriveFrame:SetScript("OnEvent", UIObj_Event)
    UIObjectDriveFrame:RegisterEvent("UNIT_AURA")

    --function BBP.HookBlizzedFunc()
        hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", function()
            for k, namePlate in pairs(C_NamePlate.GetNamePlates(false)) do
                BBP.On_NpRefreshOnce(namePlate.UnitFrame)
            end
        end)

        -- Unit Faction
    hooksecurefunc(NamePlateUnitFrameMixin, "OnUnitFactionChanged", function(self, unit)
        if not unit:find("nameplate") then return end
        local nameplate, frame = BBP.GetSafeNameplate(unit)
        if frame then
            BBP.On_NpRefreshOnce(frame)
            C_Timer.After(0.2, function()     --This needs more testing, silly attempt to make sure nameplates are updated after Mind Control
                local nameplate, frame = BBP.GetSafeNameplate(unit)
                if frame then
                    BBP.On_NpRefreshOnce(frame)
                end
            end)
        end
    end)
    --end
end

local function ColorNameplateBorder(self, frame)
    if self.changing or self:IsForbidden() then return end

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    if (info.isSelf and not config.personalBarTweaks) then return end

    if not config.nameplateBorderInitialized or BBP.needsUpdate then
        config.npBorderTargetColor = BetterBlizzPlatesDB.npBorderTargetColor
        config.npBorderFriendFoeColor = BetterBlizzPlatesDB.npBorderFriendFoeColor
        config.npBorderClassColor = BetterBlizzPlatesDB.npBorderClassColor

        config.npBorderTargetColorRGB = BetterBlizzPlatesDB.npBorderTargetColorRGB
        config.npBorderFocusColorRGB = BetterBlizzPlatesDB.npBorderFocusColorRGB
        config.npBorderEnemyColorRGB = BetterBlizzPlatesDB.npBorderEnemyColorRGB
        config.npBorderFriendlyColorRGB = BetterBlizzPlatesDB.npBorderFriendlyColorRGB
        config.npBorderNeutralColorRGB = BetterBlizzPlatesDB.npBorderNeutralColorRGB
        config.npBorderNpcColorRGB = BetterBlizzPlatesDB.npBorderNpcColorRGB
        config.npBorderNonTargetColorRGB = BetterBlizzPlatesDB.npBorderNonTargetColorRGB

        config.nameplateBorderInitialized = true
    end

    self.changing = true

    if info.isTarget and config.npBorderTargetColor then
        self:SetVertexColor(unpack(config.npBorderTargetColorRGB))
    elseif info.isFocus and config.npBorderTargetColor then
        self:SetVertexColor(unpack(config.npBorderFocusColorRGB))
    else
        --non target
        if config.npBorderFriendFoeColor then
            if info.isEnemy then
                self:SetVertexColor(unpack(config.npBorderEnemyColorRGB))
            elseif info.isNeutral then
                self:SetVertexColor(unpack(config.npBorderNeutralColorRGB))
            elseif info.isFriend then
                self:SetVertexColor(unpack(config.npBorderFriendlyColorRGB))
            end
        end

        if config.npBorderClassColor then
            if info.isPlayer then
                local classColor = RAID_CLASS_COLORS[info.class]
                self:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
            else
                self:SetVertexColor(unpack(config.npBorderNpcColorRGB))
            end
        end

        if not config.npBorderFriendFoeColor and not config.npBorderClassColor then
            self:SetVertexColor(unpack(config.npBorderNonTargetColorRGB))
        end
    end
    self.changing = false
end

function BBP.ColorNameplateBorder(frame) --classic border
    -- Support classic borders, classicRetailNameplates borders, and default midnight borders
    local border = frame.BetterBlizzPlates.bbpBorder
    local newBorder = frame.HealthBarsContainer and frame.HealthBarsContainer.newBorder
    local selectedBorder = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar and frame.HealthBarsContainer.healthBar.selectedBorder
    local db = BetterBlizzPlatesDB
    local midnightBgBorder = frame.HealthBarsContainer.healthBar.bgTexture

    if border then
        border:SetBorderColor(1,1,1)
        border:SetDesaturated(false)
    end

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or GetNameplateUnitInfo(frame)
    if not info then return end

    if (info.isSelf and not config.personalBarTweaks) then return end

    local nonMidnightBorder = db.classicRetailNameplates or config.classicNameplates
    if not config.nameplateBorderInitialized or BBP.needsUpdate then
        config.npBorderTargetColor = BetterBlizzPlatesDB.npBorderTargetColor
        config.npBorderFocusColorRGB = BetterBlizzPlatesDB.npBorderFocusColorRGB
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
        if border then
            border:SetDesaturated(true)
            border:SetBorderColor(unpack(config.npBorderTargetColorRGB))
        elseif not nonMidnightBorder then
            midnightBgBorder:SetVertexColor(unpack(config.npBorderTargetColorRGB))
        end
        if newBorder and db.classicRetailNameplates then
            frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderTargetColorRGB))
        end
        if selectedBorder and not nonMidnightBorder then
            selectedBorder:SetVertexColor(unpack(config.npBorderTargetColorRGB))
        end
    elseif info.isFocus and config.npBorderTargetColor then
        if border then
            border:SetDesaturated(true)
            border:SetBorderColor(unpack(config.npBorderFocusColorRGB))
        elseif not nonMidnightBorder then
            midnightBgBorder:SetVertexColor(unpack(config.npBorderFocusColorRGB))
        end
        if newBorder and db.classicRetailNameplates then
            frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderFocusColorRGB))
        end
        if selectedBorder and not nonMidnightBorder then
            selectedBorder:SetVertexColor(unpack(config.npBorderFocusColorRGB))
        end
    else
        --non target
        if config.npBorderFriendFoeColor then
            if info.isEnemy then
                if border then
                    border:SetDesaturated(true)
                    border:SetBorderColor(unpack(config.npBorderEnemyColorRGB))
                elseif not nonMidnightBorder then
                    midnightBgBorder:SetVertexColor(unpack(config.npBorderEnemyColorRGB))
                end
                if newBorder and db.classicRetailNameplates then
                    frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderEnemyColorRGB))
                end
                if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                    selectedBorder:SetVertexColor(unpack(config.npBorderEnemyColorRGB))
                end
            elseif info.isNeutral then
                if border then
                    border:SetDesaturated(true)
                    border:SetBorderColor(unpack(config.npBorderNeutralColorRGB))
                elseif not nonMidnightBorder then
                    midnightBgBorder:SetVertexColor(unpack(config.npBorderNeutralColorRGB))
                end
                if newBorder and db.classicRetailNameplates then
                    frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderNeutralColorRGB))
                end
                if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                    selectedBorder:SetVertexColor(unpack(config.npBorderNeutralColorRGB))
                end
            elseif info.isFriend then
                if border then
                    border:SetDesaturated(true)
                    border:SetBorderColor(unpack(config.npBorderFriendlyColorRGB))
                elseif not nonMidnightBorder then
                    midnightBgBorder:SetVertexColor(unpack(config.npBorderFriendlyColorRGB))
                end
                if newBorder and db.classicRetailNameplates then
                    frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderFriendlyColorRGB))
                end
                if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                    selectedBorder:SetVertexColor(unpack(config.npBorderFriendlyColorRGB))
                end
            end
        end

        if config.npBorderClassColor then
            if info.isPlayer then
                local classColor = RAID_CLASS_COLORS[info.class]
                if border then
                    border:SetDesaturated(true)
                    border:SetBorderColor(classColor.r, classColor.g, classColor.b, 1)
                elseif not nonMidnightBorder then
                    midnightBgBorder:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
                end
                if newBorder and db.classicRetailNameplates then
                    frame.HealthBarsContainer:SetBorderColor(classColor.r, classColor.g, classColor.b, 1)
                end
                if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                    selectedBorder:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
                end
            elseif not config.npBorderFriendFoeColor then
                if border then
                    border:SetDesaturated(true)
                    border:SetBorderColor(unpack(config.npBorderNpcColorRGB))
                elseif not nonMidnightBorder then
                    midnightBgBorder:SetVertexColor(unpack(config.npBorderNpcColorRGB))
                end
                if newBorder and db.classicRetailNameplates then
                    frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderNpcColorRGB))
                end
                if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                    selectedBorder:SetVertexColor(unpack(config.npBorderNpcColorRGB))
                end
            end
        end

        if not config.npBorderFriendFoeColor and not config.npBorderClassColor and config.npBorderTargetColor then
            if border then
                border:SetDesaturated(true)
                border:SetBorderColor(unpack(config.npBorderNonTargetColorRGB))
            elseif not nonMidnightBorder then
                midnightBgBorder:SetVertexColor(unpack(config.npBorderNonTargetColorRGB))
            end
            if newBorder and db.classicRetailNameplates then
                frame.HealthBarsContainer:SetBorderColor(unpack(config.npBorderNonTargetColorRGB))
            end
            if selectedBorder and not db.classicRetailNameplates and not config.classicNameplates then
                selectedBorder:SetVertexColor(unpack(config.npBorderNonTargetColorRGB))
            end
        end
    end
end

local function ApplyBorderSize(border, size, min)
    PixelUtil.SetWidth(border.Left, size, min)
    PixelUtil.SetPoint(border.Left, "TOPRIGHT", border, "TOPLEFT", 0, size, 0, min)
    PixelUtil.SetPoint(border.Left, "BOTTOMRIGHT", border, "BOTTOMLEFT", 0, -size, 0, min)

    PixelUtil.SetWidth(border.Right, size, min)
    PixelUtil.SetPoint(border.Right, "TOPLEFT", border, "TOPRIGHT", 0, size, 0, min)
    PixelUtil.SetPoint(border.Right, "BOTTOMLEFT", border, "BOTTOMRIGHT", 0, -size, 0, min)

    PixelUtil.SetHeight(border.Bottom, size, min)
    PixelUtil.SetPoint(border.Bottom, "TOPLEFT", border, "BOTTOMLEFT", 0, 0)
    PixelUtil.SetPoint(border.Bottom, "TOPRIGHT", border, "BOTTOMRIGHT", 0, 0)

    if border.Top then
        PixelUtil.SetHeight(border.Top, size, min)
        PixelUtil.SetPoint(border.Top, "BOTTOMLEFT", border, "TOPLEFT", 0, 0)
        PixelUtil.SetPoint(border.Top, "BOTTOMRIGHT", border, "TOPRIGHT", 0, 0)
    end
end

local function ChangeHealthbarBorderSize(frame)
    if frame.HealthBarsContainer.healthBar.borders then
        local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
        if not config then return end

        local borderSize = config.nameplateBorderSize
        local minPixels = 0.5
        local unit = frame.unit

        if frame == BBP.currentTargetNameplate then
            borderSize = config.nameplateTargetBorderSize
        -- elseif UnitIsUnit("player", unit) then
        --     borderSize = config.nameplatePersonalBorderSize

        --     local mana = ClassNameplateManaBarFrame and ClassNameplateManaBarFrame.Border
        --     if mana then
        --         ApplyBorderSize(mana, borderSize, minPixels)
        --     end
        end

        if BetterBlizzPlatesDB.castBarPixelBorder then
            if frame.castBar.SetBorderSize then
                frame.castBar:SetBorderSize(borderSize)
            end
        end
        if BetterBlizzPlatesDB.castBarIconPixelBorder then
            if frame.castBarIconFrame.Icon.SetBorderSize then
                frame.castBarIconFrame.Icon:SetBorderSize(borderSize)
            end
        end

        frame.HealthBarsContainer.healthBar:SetBorderSize(borderSize)

    elseif frame.HealthBarsContainer.borders and frame.HealthBarsContainer.SetBorderSize then
        -- (classicRetailNameplates)
        local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
        if not config then return end

        local borderSize = config.nameplateBorderSize
        local unit = frame.unit

        if frame == BBP.currentTargetNameplate then
            borderSize = config.nameplateTargetBorderSize
        end

        if BetterBlizzPlatesDB.castBarPixelBorder then
            if frame.castBar.SetBorderSize then
                frame.castBar:SetBorderSize(borderSize)
            end
        end
        if BetterBlizzPlatesDB.castBarIconPixelBorder then
            if frame.castBarIconFrame.Icon.SetBorderSize then
                frame.castBarIconFrame.Icon:SetBorderSize(borderSize)
            end
        end

        frame.HealthBarsContainer:SetBorderSize(borderSize)

    else
        if not frame.HealthBarsContainer.border then return end
        if frame.borderHooked then
            if BetterBlizzPlatesDB.nameplateMinScale == 1 then
                frame.HealthBarsContainer.border:SetBorderSize()
            end
            return
        end

        hooksecurefunc(frame.HealthBarsContainer.border, "UpdateSizes", function(self)
            if frame:IsForbidden() or not frame.unit then return end

            local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
            if not config then return end

            local borderSize = config.nameplateBorderSize
            local minPixels = 0.5
            local unit = frame.unit

            if UnitIsUnit("target", unit) then
                borderSize = config.nameplateTargetBorderSize
            elseif UnitIsUnit("player", unit) then
                borderSize = config.nameplatePersonalBorderSize

                local mana = ClassNameplateManaBarFrame and ClassNameplateManaBarFrame.Border
                if mana then
                    ApplyBorderSize(mana, borderSize, minPixels)
                end
            end

            if BetterBlizzPlatesDB.castBarPixelBorder then
                if frame.castBar.SetBorderSize then
                    frame.castBar:SetBorderSize(borderSize)
                end
            end
            if BetterBlizzPlatesDB.castBarIconPixelBorder then
                if frame.castBarIconFrame.Icon.SetBorderSize then
                    frame.castBarIconFrame.Icon:SetBorderSize(borderSize)
                end
            end

            ApplyBorderSize(self, borderSize, minPixels)
        end)

        frame.borderHooked = true
        frame.HealthBarsContainer.border:UpdateSizes()
    end
end
BBP.ChangeHealthbarBorderSize = ChangeHealthbarBorderSize


local function HookNameplateBorder(frame)
    if not frame.HealthBarsContainer.border then return end
    -- BBP.isMidnight
    --HealthBarsContainer.healthBar.bgTexture = background Border
    --HealthBarsContainer.healthBar.selectedBorder = white border on target
    if not frame.BetterBlizzPlates.hooks.nameplateBorderColor then
        hooksecurefunc(frame.HealthBarsContainer.border, "SetVertexColor", function(self)
            if not self then return end
            ColorNameplateBorder(self, frame)
        end)
        hooksecurefunc(frame.HealthBarsContainer.border, "SetUnderlineColor", function(self) -- softtarget
            if not self then return end
            ColorNameplateBorder(self, frame)
        end)
        frame.BetterBlizzPlates.hooks.nameplateBorderColor = true
        ColorNameplateBorder(frame.HealthBarsContainer.border, frame)
    end
end

local function HookSelectedBorder(frame)
    local selectedBorder = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar and frame.HealthBarsContainer.healthBar.selectedBorder
    if not selectedBorder then return end

    if not frame.BetterBlizzPlates.hooks.selectedBorderColor then
        hooksecurefunc(selectedBorder, "SetVertexColor", function(self, r, g, b, a)
            if self.changing or frame:IsForbidden() then return end
            self.changing = true
            BBP.ColorNameplateBorder(frame)
            self.changing = false
        end)
        frame.BetterBlizzPlates.hooks.selectedBorderColor = true
        BBP.ColorNameplateBorder(frame)
    end
end

local function HookNameplateCastbarHide(frame)
    if not frame.castBar.hideHooked then
        -- hooksecurefunc(frame.castBar, "Hide", function(self)
        --     if UnitIsUnit(frame.unit, "target") then
        --         BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
        --     end
        -- end)--probably remove, stays for now bodify
        frame.castBar:HookScript("OnHide", function()
            if frame:IsForbidden() then return end
            if not frame.unit then return end
            if frame == BBP.currentTargetNameplate then --BBP.isMidnight
                BBP.UpdateNameplateResourcePositionForCasting(frame:GetParent(), true)
            end
        end)
        frame.castBar.hideHooked = true
    end
end

local function HideFriendlyHealthbar(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    config.friendlyHideHealthBar = BetterBlizzPlatesDB.friendlyHideHealthBar
    config.friendlyHideHealthBarNpc = BetterBlizzPlatesDB.friendlyHideHealthBarNpc
    if frame.healthBar and info.isFriend then
        if BetterBlizzPlatesDB.friendlyHideHealthBar and info.isPlayer then
            local showOnTarget = BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget
            if showOnTarget and frame == BBP.currentTargetNameplate then
                frame.HealthBarsContainer:SetAlpha(1)
                frame.HealthBarsContainer.alphaZero = false
                frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 0.22)
            else
                frame.HealthBarsContainer:SetAlpha(0)
                frame.HealthBarsContainer.alphaZero = true
                frame.selectionHighlight:SetAlpha(0)
            end
        elseif BetterBlizzPlatesDB.friendlyHideHealthBarNpc and not info.isPlayer then
            local hideNpcHpBar = BetterBlizzPlatesDB.friendlyHideHealthBarNpc and not (BetterBlizzPlatesDB.friendlyHideHealthBarShowPet and UnitIsUnit("pet", frame.unit))
            if hideNpcHpBar then
                frame.HealthBarsContainer:SetAlpha(0)
                frame.HealthBarsContainer.alphaZero = true
                frame.selectionHighlight:SetAlpha(0)
            else
                frame.HealthBarsContainer:SetAlpha(1)
                frame.HealthBarsContainer.alphaZero = false
                frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 0.22)
            end
        else
            frame.HealthBarsContainer:SetAlpha(1)
            frame.HealthBarsContainer.alphaZero = false
            frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 0.22)
            if frame.guildName then
                frame.guildName:SetText("")
            end
        end
    else
        frame.HealthBarsContainer:SetAlpha(1)
        frame.selectionHighlight:SetAlpha((config.hideTargetHighlight and 0) or (info.isFriend and ((config.friendlyHideHealthBar and not info.isNpc) or (config.friendlyHideHealthBarNpc and info.isNpc)) and 0) or 0.22)
        if frame.guildName then
            frame.guildName:SetText("")
        end
    end
end

BBP.HideFriendlyHealthbar = HideFriendlyHealthbar

local function FriendIndicator(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    local isFriend = BBP.isFriendlistFriend(frame.unit)
    local isBnetFriend = BBP.isUnitBNetFriend(frame.unit)
    local isGuildmate = BBP.isUnitGuildmate(frame.unit)

    if not frame.friendIndicator then
        frame.friendIndicator = frame:CreateTexture(nil, "OVERLAY")
        frame.friendIndicator:SetAtlas("groupfinder-icon-friend")
        frame.friendIndicator:SetSize(20, 21)
    end

    if info.isSelf then
        frame.friendIndicator:Hide()
    elseif isFriend or isBnetFriend then
        frame.friendIndicator:SetDesaturated(false)
        frame.friendIndicator:SetVertexColor(1, 1, 1)
        frame.friendIndicator:Show()
        if BBP.isInArena and frame.specNameText and frame.specNameText ~= "" then
            frame.friendIndicator:SetPoint("RIGHT", frame.specNameText, "LEFT", 0, 0)
        else
            frame.friendIndicator:SetPoint("RIGHT", frame.name, "LEFT", 0, 0)
        end
    elseif isGuildmate then
        frame.friendIndicator:SetDesaturated(true)
        frame.friendIndicator:SetVertexColor(0, 1, 0)
        frame.friendIndicator:Show()
        if BBP.isInArena and frame.specNameText and frame.specNameText ~= "" then
            frame.friendIndicator:SetPoint("RIGHT", frame.specNameText, "LEFT", 0, 0)
        else
            frame.friendIndicator:SetPoint("RIGHT", frame.name, "LEFT", 0, 0)
        end
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

    frame.bbpHiddenNPC = nil
    frame.ciChange = nil
    frame:SetScale(1)
    frame:SetAlpha(1)
    frame.name:SetAlpha(1)
    if frame.HealthBarsContainer then
        frame.HealthBarsContainer:SetAlpha(1)
        frame.HealthBarsContainer.alphaZero = false
    end
    local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
    if not hideTargetHighlight then
        frame.selectionHighlight:SetAlpha(0.22)
    end

    frame.arenaID = nil

    if frame.bbpWidthAdjusted then
        local width = (BetterBlizzPlatesDB.nameplateEnemyWidth or 172.5)/2
        frame.bbpWidthAdjusted = nil
        frame.HealthBarsContainer:ClearPoint("RIGHT")
        frame.HealthBarsContainer:ClearPoint("LEFT")
        frame.HealthBarsContainer:SetPoint("LEFT", frame, "CENTER", -width + 12, 0)
        frame.HealthBarsContainer:SetPoint("RIGHT", frame, "CENTER", width - 12, 0)
        frame.castBar:ClearPoint("RIGHT")
        frame.castBar:ClearPoint("LEFT")
        frame.castBar:SetPoint("LEFT", frame, "CENTER", -width + 12, 0)
        frame.castBar:SetPoint("RIGHT", frame, "CENTER", width - 12, 0)
    end

    if frame.castHiddenName then
        frame.castHiddenName = nil
        CompactUnitFrame_UpdateName(frame)
    end

    if frame.needsRecolor then
        BBP.CompactUnitFrame_UpdateHealthColor(frame, true)
        frame.needsRecolor = nil
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

    if frame.mainPetColor then
        frame.mainPetColor = nil
    end
    if frame.hideCastInfo then
        frame.hideCastInfo = false
    end
    if frame.hideCastInfo then
        frame.hideCastInfo = false
    end
    if frame.hideCastbarOverride then
        frame.hideCastbarOverride = false
    end
    if frame.hideNameOverride then
        frame.hideNameOverride = false
    end
    -- Hide totem icons
    if frame.customIcon then
        frame.customIcon:Hide()
    end
    if frame.glowTexture then
        frame.glowTexture:Hide()
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

    if frame.bgIndicator then
        frame.bgIndicator:Hide()
    end

    frame.executeIndicatorInRange = nil

end

--#################################################################################################
--#################################################################################################
--#################################################################################################

BBP.InitializeNameplateSettings = InitializeNameplateSettings

local eliteIcons = {
    ["UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star"] = true,
    ["UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare"] = true,
    ["nameplates-icon-elite-gold"] = true,
    ["nameplates-icon-elite-silver"] = true,
}

function BBP.CustomizeClassificationFrame(frame)
    local config = frame.BetterBlizzPlates.config
    frame.ClassificationFrame:SetFrameStrata("LOW")

    if config.hideEliteDragon and not frame.ClassificationFrame.bbpHook then
        local atlas = frame.ClassificationFrame.classificationIndicator:GetAtlas()
        if eliteIcons[atlas] then
            frame.ClassificationFrame.classificationIndicator:SetAtlas(nil)
        end

        hooksecurefunc(frame.ClassificationFrame.classificationIndicator, "SetAtlas", function(self, newAtlas)
            if frame:IsForbidden() then return end
            if eliteIcons[newAtlas] then
                self:SetAtlas(nil)
            end
        end)

        frame.ClassificationFrame.bbpHook = true
    end
end

function BBP.RepositionName(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.fakeNameXPos or BBP.needsUpdate then
        config.fakeNameXPos = BetterBlizzPlatesDB.fakeNameXPos
        config.fakeNameYPos = BetterBlizzPlatesDB.fakeNameYPos
        config.fakeNameFriendlyXPos = BetterBlizzPlatesDB.fakeNameFriendlyXPos
        config.fakeNameFriendlyYPos = BetterBlizzPlatesDB.fakeNameFriendlyYPos
        config.useFakeNameAnchorBottom = BetterBlizzPlatesDB.useFakeNameAnchorBottom
        config.fakeNameAnchor = BetterBlizzPlatesDB.fakeNameAnchor
        config.fakeNameAnchorRelative = BetterBlizzPlatesDB.fakeNameAnchorRelative
        config.fakeNameScaleWithParent = BetterBlizzPlatesDB.fakeNameScaleWithParent
        config.fakeNameRaiseStrata = BetterBlizzPlatesDB.fakeNameRaiseStrata
    end
    local function RepositionName(frame)
        if frame:IsForbidden() or not frame.unit or frame.name.changing then return end
        frame.name.changing = true
        local db = BetterBlizzPlatesDB
        --frame.name:ClearPoint("BOTTOM")
        frame.name:ClearAllPoints()
        if isFriend(frame.unit) then
            if db.useFakeNameAnchorBottom then
                frame.name:SetPoint("BOTTOM", frame, "BOTTOM", db.fakeNameFriendlyXPos, db.fakeNameFriendlyYPos + 27)
            else
                frame.name:SetPoint(db.fakeNameAnchor, frame.healthBar, db.fakeNameAnchorRelative, db.fakeNameFriendlyXPos, db.fakeNameFriendlyYPos + (info.isSelf and 3.5 or 4))
            end
        else
            frame.name:SetPoint(db.fakeNameAnchor, frame.healthBar, db.fakeNameAnchorRelative, db.fakeNameXPos, db.fakeNameYPos + 4)
        end
        frame.name.changing = false
    end
    if not frame.nameHooked then
        hooksecurefunc(frame.name, "SetPoint", function()
            RepositionName(frame)
        end)

        frame.nameHooked = true
    end
    RepositionName(frame)

    if config.fakeNameRaiseStrata then
        if not frame.newNameParent then
            frame.newNameParent = CreateFrame("Frame", nil, frame)
            frame.newNameParent:SetAllPoints(frame)
            frame.newNameParent:SetFrameStrata("HIGH")
        end
        frame.name:SetParent(frame.newNameParent)
        frame.name:SetDrawLayer("OVERLAY", 7)
    end
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

    --local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    -- Check if the unit is an NPC
    if info.isPlayer or not info.isFriend or UnitIsOtherPlayersPet(frame.unit) then
        frame.npcTitle:Hide()
    else
        local title = GetNPCTitle(frame.unit)
        frame.npcTitle:SetText(title)
        frame.npcTitle:ClearAllPoints()
        if frame.HealthBarsContainer:GetAlpha() == 0 then
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

local function CreateBetterClassicCastbarBorders(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    --local width = info.isFriend and BetterBlizzPlatesDB.nameplateFriendlyWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
    local width = frame.healthBar:GetWidth() + 25
    local levelFrameAdjustment = BetterBlizzPlatesDB.hideLevelFrame and -17 or 0

    -- Helper function to create borders
    local function CreateBorder(frame, textureLeft, textureCenter, textureRight, yPos, topYPos)
        local border = CreateFrame("Frame", nil, frame.castBar)
        border:SetFrameStrata("HIGH")
        local left = border:CreateTexture(nil, "OVERLAY")
        left:SetTexture(textureLeft)
        left:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMLEFT", -21, yPos)
        left:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", -21, topYPos)
        border.left = left

        local right = border:CreateTexture(nil, "OVERLAY")
        right:SetTexture(textureRight)
        right:SetPoint("BOTTOMRIGHT", frame.castBar, "BOTTOMRIGHT", 21, yPos)
        right:SetPoint("TOPRIGHT", frame.castBar, "TOPRIGHT", 21, topYPos)
        border.right = right

        local center = border:CreateTexture(nil, "OVERLAY")
        center:SetTexture(textureCenter)
        center:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", 0, 0)
        center:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        center:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)
        center:SetPoint("TOPRIGHT", right, "TOPLEFT", 0, 0)
        border.center = center


        border:Hide()
        return border
    end

    if frame.BigDebuffs then
        frame.BigDebuffs:SetFrameStrata("HIGH")
    end

    -- Interruptible
    if not frame.castBar.bbpCastBorder then
        --frame.castBar.Border:SetAlpha(0)
        frame.castBar.bbpCastBorder = CreateBorder(
            frame,
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastBorderLeft",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastBorderCenter",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastBorderRight",
            -3,
            5
        )
        frame.castBar.Icon:SetParent(frame.castBar)
        frame.castBar.Icon:SetDrawLayer("OVERLAY", 7)
    end
    --frame.castBar.bbpCastBorder.center:SetWidth(width - 24 + levelFrameAdjustment)

    -- Uninterruptible
    if not frame.castBar.bbpCastUninterruptibleBorder then
        --frame.castBar.BorderShield:SetAlpha(0)
        frame.castBar.bbpCastUninterruptibleBorder = CreateBorder(
            frame,
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastUninterruptibleLeft",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastUninterruptibleCenter",
            "Interface\\AddOns\\BetterBlizzPlates\\media\\npCastUninterruptibleRight",
            -11,
            5
        )
        if BetterBlizzPlatesDB.hideCastbarBorderShield then
            frame.castBar.bbpCastUninterruptibleBorder.left:SetAlpha(0)
            frame.castBar.bbpCastUninterruptibleBorder.right:SetAlpha(0)
            frame.castBar.bbpCastUninterruptibleBorder.center:SetAlpha(0)
        end
    end
    frame.castBar.bbpCastUninterruptibleBorder.center:SetWidth(width + 40 + levelFrameAdjustment)

    -- Update border visibility
    local function UpdateBorders()
        if frame:IsForbidden() then return end
        --frame.castBar.Border:SetAlpha(0)
        --frame.castBar.BorderShield:SetAlpha(0)
        if frame.castBar.BorderShield:IsShown() then
            frame.castBar.bbpCastUninterruptibleBorder:Show()
            frame.castBar.bbpCastBorder:Hide()
            frame.castBar.Icon:SetParent(frame.castBar.bbpCastUninterruptibleBorder)
        else
            frame.castBar.bbpCastUninterruptibleBorder:Hide()
            frame.castBar.bbpCastBorder:Show()
            frame.castBar.Icon:SetParent(frame.castBar.bbpCastBorder)
        end
        frame.castBar.Icon:SetDrawLayer("OVERLAY", 7) -- Ensure the icon is on top

        -- local height = frame.castBar:GetHeight()
        -- local bottomOffset = -((5/11) * height - 1.09)
        -- local topOffset = (1.97 * height)-- - 1
        -- frame.castBar.bbpCastBorder.left:ClearAllPoints()
        -- frame.castBar.bbpCastBorder.left:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", -21, topOffset)
        -- frame.castBar.bbpCastBorder.left:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMLEFT", -21, bottomOffset)

        -- frame.castBar.bbpCastUninterruptibleBorder.left:ClearAllPoints()
        -- frame.castBar.bbpCastUninterruptibleBorder.left:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", -21, topOffset-(height*0.85))
        -- frame.castBar.bbpCastUninterruptibleBorder.left:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMLEFT", -21, bottomOffset-(height*0.85))


        local height = frame.castBar:GetHeight()
        local bottomOffset = -((0.455) * height - 1.09)
        --local topOffset = (2 * height) - 1
        local topOffset = (1.97 * height)-- - 1
        local rightXOffset = config.hideLevelFrame and 27.9 or 20.9

        frame.castBar.bbpCastBorder.left:ClearAllPoints()
        frame.castBar.bbpCastBorder.left:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMLEFT", -21, bottomOffset)
        frame.castBar.bbpCastBorder.left:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", -21, topOffset)

        frame.castBar.bbpCastBorder.right:ClearAllPoints()
        frame.castBar.bbpCastBorder.right:SetPoint("BOTTOMRIGHT", frame.castBar, "BOTTOMRIGHT", rightXOffset, bottomOffset)
        frame.castBar.bbpCastBorder.right:SetPoint("TOPRIGHT", frame.castBar, "TOPRIGHT", rightXOffset, topOffset)

        frame.castBar.bbpCastUninterruptibleBorder.left:ClearAllPoints()
        frame.castBar.bbpCastUninterruptibleBorder.left:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMLEFT", -21, bottomOffset)
        frame.castBar.bbpCastUninterruptibleBorder.left:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", -21, topOffset)
    
        frame.castBar.bbpCastUninterruptibleBorder.right:ClearAllPoints()
        frame.castBar.bbpCastUninterruptibleBorder.right:SetPoint("BOTTOMRIGHT", frame.castBar, "BOTTOMRIGHT", rightXOffset, bottomOffset)
        frame.castBar.bbpCastUninterruptibleBorder.right:SetPoint("TOPRIGHT", frame.castBar, "TOPRIGHT", rightXOffset, topOffset)

        if not frame.castBar.isClassicStyle then
            frame.castBar:HookScript("OnEvent", function(self)
                if frame:IsForbidden() then return end
                self.Background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
                self.Background:SetVertexColor(0, 0, 0, 0.6)
                self:SetStatusBarTexture(137012)
                self:SetStatusBarColor(1, 0.7, 0, 1)
            end)
            frame.castBar.isClassicStyle = true
        end
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
    --         self.Icon:SetPoint("CENTER", frame.castBar, "LEFT", -10.5, 1)
    --         --self.Icon:SetSize(11, 11)
    --         self.Icon:SetDrawLayer("OVERLAY", 7)
    --     end
    -- end
    -- if not frame.bbpClassicCastbarHook then
    --     frame.castBar:HookScript("OnUpdate", function()
    --         UpdateCastBarIconSize(frame.castBar)
    --     end)
    --     frame.bbpClassicCastbarHook = true
    -- end

    --frame.castBar:SetHeight(BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.castBarHeight or 10)

    if not frame.castBar.eventsHooked then
        frame.castBar.UpdateBorders = UpdateBorders
        frame.castBar:HookScript("OnShow", UpdateBorders)
        frame.castBar:HookScript("OnHide", UpdateBorders)
        frame.castBar.BorderShield:HookScript("OnShow", UpdateBorders)
        frame.castBar.BorderShield:HookScript("OnHide", UpdateBorders)
        frame.castBar.eventsHooked = true

        hooksecurefunc(frame.castBar.Icon, "SetPoint", function(self)
            if self.changing or self:IsForbidden() then return end
            self.changing = true
            self:ClearAllPoints()
            self:SetPoint("RIGHT", frame.castBar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos-2, BetterBlizzPlatesDB.castBarIconYPos)
            --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
            self.changing = false
        end)
    end

    -- Set the initial visibility
    UpdateBorders()

    -- Adjust cast bar position
    -- if centerCastbar then
    --     frame.castBar:ClearAllPoints()
    --     frame.castBar:SetPoint("TOP", frame, "BOTTOM", 0, -5)
    -- else
    --     frame.castBar:ClearAllPoints()
    --     frame.castBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 17, -8)
    --     frame.castBar:SetWidth(width - 25 + levelFrameAdjustment)
    -- end
end

local function CreateLevelFrame(frame)
    if not frame.bbfLevelFrame then
        frame.bbfLevelFrame = CreateFrame("Frame", nil, frame.bbpOverlay)
        frame.bbfLevelFrame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.bbfLevelFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
        frame.bbfLevelFrame.text:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 5, 0)
        BBP.SetFontBasedOnOption(frame.bbfLevelFrame.text, BetterBlizzPlatesDB.levelFrameFontSize)
        frame.bbfLevelFrame.skull = frame.bbfLevelFrame:CreateTexture(nil, "OVERLAY")
        frame.bbfLevelFrame.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
        frame.bbfLevelFrame.skull:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 5, 0)
        frame.bbfLevelFrame.skull:SetSize(16,16)
    end
    if BBP.needsUpdate then
        BBP.SetFontBasedOnOption(frame.bbfLevelFrame.text, 12)
    end
end

local function UpdateLevelFrame(frame)
    if BBP.isInPvP then
        frame.bbfLevelFrame:Hide()
        frame.bbfLevelFrame.text:Hide()
        frame.bbfLevelFrame.skull:Hide()
        return
    end

    if UnitIsFriend(frame.unit, "player") and not BetterBlizzPlatesDB.showLevelFrameOnFriendly then
        frame.bbfLevelFrame:Hide()
        frame.bbfLevelFrame.text:Hide()
        frame.bbfLevelFrame.skull:Hide()
    else
        local unitLevel = UnitLevel(frame.unit)
        local color = GetCreatureDifficultyColor(unitLevel)

        frame.bbfLevelFrame.text:SetText(unitLevel ~= -1 and unitLevel or "")
        frame.bbfLevelFrame.text:SetTextColor(color.r, color.g, color.b)

        frame.bbfLevelFrame:Show()
        frame.bbfLevelFrame.text:Show()

        if unitLevel == -1 then
            frame.bbfLevelFrame.skull:Show()
            frame.bbfLevelFrame.text:Hide()
        elseif unitLevel == 0 then
            frame.bbfLevelFrame:Hide()
            frame.bbfLevelFrame.skull:Hide()
            frame.bbfLevelFrame.text:Hide()
        else
            frame.bbfLevelFrame.skull:Hide()
        end
    end
end

local function CreateBetterClassicHealthbarBorder(frame)
    local info = frame.BetterBlizzPlates.unitInfo
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)

    if not frame.BetterBlizzPlates.bbpBorder then
        if frame.HealthBarsContainer.border then
            frame.HealthBarsContainer.border:Hide()
        end
        frame.HealthBarsContainer.healthBar.bgTexture:SetAlpha(0)
        if not frame.HealthBarsContainer.background then
            frame.HealthBarsContainer.background = frame.HealthBarsContainer:CreateTexture(nil, "BACKGROUND")
            frame.HealthBarsContainer.background:SetAllPoints(frame.HealthBarsContainer)
            frame.HealthBarsContainer.background:SetColorTexture(0, 0, 0, 0.4)
        end
        --frame.HealthBarsContainer.healthBar.selectedTexture:SetAlpha(0)
        frame.BetterBlizzPlates.bbpBorder = CreateFrame("Frame", nil, frame)
        local border = frame.BetterBlizzPlates.bbpBorder

        local left = border:CreateTexture(nil, "OVERLAY", nil, -1)
        left:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderLeft")
        left:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "BOTTOMLEFT", -28, -3)
        left:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -28, 17)
        border.left = left

        local right = border:CreateTexture(nil, "OVERLAY", nil, -1)
        right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRight")
        right:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", 27.5, -3)
        right:SetPoint("TOPRIGHT", frame.HealthBarsContainer, "TOPRIGHT", 27.5, 17)
        border.right = right

        local center = border:CreateTexture(nil, "OVERLAY", nil, -1)
        center:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderCenter")
        center:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", 0, 0)
        center:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        center:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)
        center:SetPoint("TOPRIGHT", right, "TOPLEFT", 0, 0)
        border.center = center

        border:SetParent(frame.healthBar)

        function border:SetDesaturated()
            self.left:SetDesaturated(true)
            self.center:SetDesaturated(true)
            self.right:SetDesaturated(true)
        end

        function border:SetBorderColor(r, g, b, a)
            if BetterBlizzPlatesDB.npBorderDesaturate then
                self:SetDesaturated()
            end
            self.left:SetVertexColor(r, g, b, a)
            self.center:SetVertexColor(r, g, b, a)
            self.right:SetVertexColor(r, g, b, a)
        end

        --if not config.hideLevelFrame then
            frame.ClassicLevelFrame = CreateFrame("Frame", nil, border)
            frame.ClassicLevelFrame.text = border:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.ClassicLevelFrame.text:SetDrawLayer("OVERLAY", 7)
            frame.ClassicLevelFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
            frame.ClassicLevelFrame.text:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 1.5, 0)
            frame.ClassicLevelFrame.skull = border:CreateTexture(nil, "OVERLAY")
            frame.ClassicLevelFrame.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
            frame.ClassicLevelFrame.skull:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 1.5, 0)
            frame.ClassicLevelFrame.skull:SetSize(16,16)
        --end
    end

    if (info.isSelf and not config.personalBarTweaks) then
        frame.BetterBlizzPlates.bbpBorder:Hide()
        if frame.HealthBarsContainer.border then
            frame.HealthBarsContainer.border:Show()
        end
        frame.selfBorderHidden = true
        return
    elseif frame.selfBorderHidden then
        frame.selfBorderHidden = nil
        frame.BetterBlizzPlates.bbpBorder:Show()
        if frame.HealthBarsContainer.border then
            frame.HealthBarsContainer.border:Hide()
        end
    end

    if BBP.needsUpdate then
        frame.BetterBlizzPlates.bbpBorder:Show()
        if frame.HealthBarsContainer.border then
            frame.HealthBarsContainer.border:Hide()
        end
    end

    if frame.ClassicLevelFrame and not config.hideLevelFrame then
        local unitLevel = UnitLevel(frame.unit)
        frame.ClassicLevelFrame.text:SetText(unitLevel ~= -1 and unitLevel or "")
        if unitLevel == -1 then
            frame.ClassicLevelFrame.skull:Show()
            frame.ClassicLevelFrame.text:Hide()
        elseif unitLevel == 0 then
            frame.ClassicLevelFrame:Hide()
            frame.ClassicLevelFrame.skull:Hide()
            frame.ClassicLevelFrame.text:Hide()
        else
            frame.ClassicLevelFrame.skull:Hide()
        end
    end

    local height = frame.healthBar:GetHeight()
    local bottomOffset = -((0.455) * height - 1.09)
    local topOffset = (2 * height) - 1
    local hideLevel = config.hideLevelFrame or (BBP.isInPvP and not BetterBlizzPlatesDB.hideLevelFrameForceOnInPvP) or (info.isSelf and config.personalBarTweaks)
    local rightXOffset = hideLevel and 27.9 or 20.9

    if hideLevel then
        frame.BetterBlizzPlates.bbpBorder.right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRightNoLevel")
        frame.ClassicLevelFrame.text:Hide()
        frame.ClassicLevelFrame.skull:Hide()
    else
        frame.BetterBlizzPlates.bbpBorder.right:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\npBorderRight")
        frame.ClassicLevelFrame.text:Show()
    end

    frame.BetterBlizzPlates.bbpBorder.left:ClearAllPoints()
    frame.BetterBlizzPlates.bbpBorder.left:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "BOTTOMLEFT", -28, bottomOffset)
    frame.BetterBlizzPlates.bbpBorder.left:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -28, topOffset)

    frame.BetterBlizzPlates.bbpBorder.right:ClearAllPoints()
    frame.BetterBlizzPlates.bbpBorder.right:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", rightXOffset, bottomOffset)
    frame.BetterBlizzPlates.bbpBorder.right:SetPoint("TOPRIGHT", frame.HealthBarsContainer, "TOPRIGHT", rightXOffset, topOffset)


    --local width = info.isFriend and BetterBlizzPlatesDB.nameplateFriendlyWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
    -- local width = frame.healthBar:GetWidth() + 25
    -- frame.BetterBlizzPlates.bbpBorder.center:SetWidth(width - 40)

    --CreateBetterClassicCastbarBorders(frame)
end

function BBP.ClickableArea(nameplate)
    if not nameplate then return end
    local frame = nameplate.UnitFrame
    local isClickthroughFriend = UnitIsFriend("player", frame.unit) and BetterBlizzPlatesDB.friendlyNameplateClickthrough
    
    if not nameplate.clickableAreaOverlay then
        local texture = nameplate:CreateTexture(nil, "BACKGROUND")
        local text = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("BOTTOM", texture, "TOP", 0, 2)

        local r = math.random()
        local g = math.random()
        local b = math.random()

        texture:SetColorTexture(r, g, b, 0.5)

        nameplate.clickableAreaOverlay = texture
        nameplate.clickableAreaText = text
    end

    local texture = nameplate.clickableAreaOverlay
    texture:ClearAllPoints()
    
    if isClickthroughFriend then
        -- Collapse to a point (un-clickable)
        texture:SetPoint("TOPLEFT", frame.HealthBarsContainer, "CENTER", 0, -50)
        texture:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "CENTER", 0, -50)
        nameplate.clickableAreaText:SetText("Un-clickable")
    else
        -- Expand clickable area
        local extraClickHeight = (BetterBlizzPlatesDB.nameplateExtraClickHeight or 0)
        local extraClickWidth = (BetterBlizzPlatesDB.nameplateExtraClickWidth or 0)
        texture:SetPoint("TOPLEFT", frame.HealthBarsContainer.healthBar, "TOPLEFT", -extraClickWidth, extraClickHeight)
        texture:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer.healthBar, "BOTTOMRIGHT", extraClickWidth, -20)
        nameplate.clickableAreaText:SetText("Clickable Area")
    end

    return texture
end









-- List of healer specialization IDs
local HEALER_SPEC_IDS = {
    [105] = true,  -- Restoration Druid
    [264] = true,  -- Restoration Shaman
    [270] = true,  -- Mistweaver Monk
    [257] = true,  -- Holy Priest
    [65] = true,   -- Holy Paladin
    [256] = true,  -- Discipline Priest
    [1468] = true, -- Preservation Evoker
}

-- Table to store localized specialization names -> spec ID
local function GetLocalizedSpecs()
    local specs = {}

    for classID = 1, GetNumClasses() do
        local _, class = GetClassInfo(classID)
        local classMale = LOCALIZED_CLASS_NAMES_MALE[class]
        local classFemale = LOCALIZED_CLASS_NAMES_FEMALE[class]

        for specIndex = 1, GetNumSpecializationsForClassID(classID) do
            local specID, specName = GetSpecializationInfoForClassID(classID, specIndex)

            if classMale then
                specs[string.format("%s %s", specName, classMale)] = specID
            end
            if classFemale and classFemale ~= classMale then
                specs[string.format("%s %s", specName, classFemale)] = specID
            end
        end
    end

    -- Blizzard API poopoo. Not possible to get gendered specNames AFAIK.
    -- And some classes were even missing from LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_FEMALE
    -- Thanks to Dardo7 @ Discord for helping get all the correct Spanish data.
    if GetLocale() == "esES" then
        local esES_overrides = {
            ["Armas Guerrero"] = 71,
            ["Armas Guerrera"] = 71,
            ["Furia Guerrero"] = 72,
            ["Furia Guerrera"] = 72,
            ["Protección Guerrero"] = 73,
            ["Protección Guerrera"] = 73,

            ["Sagrado Paladín"] = 65,
            ["Sagrada Paladín"] = 65,
            ["Protección Paladín"] = 66,
            ["Reprensión Paladín"] = 70,

            ["Bestias Cazador"] = 253,
            ["Bestias Cazadora"] = 253,
            ["Puntería Cazador"] = 254,
            ["Puntería Cazadora"] = 254,
            ["Supervivencia Cazador"] = 255,
            ["Supervivencia Cazadora"] = 255,

            ["Asesinato Pícaro"] = 259,
            ["Asesinato Pícara"] = 259,
            ["Forajido Pícaro"] = 260,
            ["Forajida Pícara"] = 260,
            ["Sutileza Pícaro"] = 261,
            ["Sutileza Pícara"] = 261,

            ["Disciplina Sacerdote"] = 256,
            ["Disciplina Sacerdotisa"] = 256,
            ["Sagrado Sacerdote"] = 257,
            ["Sagrada Sacerdotisa"] = 257,
            ["Sombra Sacerdote"] = 258,
            ["Sombra Sacerdotisa"] = 258,

            ["Sangre Caballero de la Muerte"] = 250,
            ["Sangre Caballera de la Muerte"] = 250,
            ["Escarcha Caballero de la Muerte"] = 251,
            ["Escarcha Caballera de la Muerte"] = 251,
            ["Profano Caballero de la Muerte"] = 252,
            ["Profana Caballera de la Muerte"] = 252,

            ["Elemental Chamán"] = 262,
            ["Mejora Chamán"] = 263,
            ["Restauración Chamán"] = 264,

            ["Arcano Mago"] = 62,
            ["Arcana Maga"] = 62,
            ["Fuego Mago"] = 63,
            ["Fuego Maga"] = 63,
            ["Escarcha Mago"] = 64,
            ["Escarcha Maga"] = 64,

            ["Aflicción Brujo"] = 265,
            ["Aflicción Bruja"] = 265,
            ["Demonología Brujo"] = 266,
            ["Demonología Bruja"] = 266,
            ["Destrucción Brujo"] = 267,
            ["Destrucción Bruja"] = 267,

            ["Maestro cervecero Monje"] = 268,
            ["Maestra cervecera Monje"] = 268,
            ["Tejedor de niebla Monje"] = 270,
            ["Tejedora de niebla Monje"] = 270,
            ["Viajero del viento Monje"] = 269,
            ["Viajera del viento Monje"] = 269,

            ["Equilibrio Druida"] = 102,
            ["Feral Druida"] = 103,
            ["Guardián Druida"] = 104,
            ["Guardiana Druida"] = 104,
            ["Restauración Druida"] = 105,

            ["Devastación Cazador de demonios"] = 577,
            ["Devastación Cazadora de demonios"] = 577,
            ["Venganza Cazador de demonios"] = 581,
            ["Venganza Cazadora de demonios"] = 581,

            ["Devastación Evocador"] = 1467,
            ["Devastación Evocadora"] = 1467,
            ["Preservación Evocador"] = 1468,
            ["Preservación Evocadora"] = 1468,
            ["Aumento Evocador"] = 1473,
            ["Aumento Evocadora"] = 1473,
        }
        for k, v in pairs(esES_overrides) do
            specs[k] = v
        end
    end

    return specs
end

-- Store all specs in a lookup table
local ALL_SPECS = GetLocalizedSpecs()

-- Caching Tables
BBA.SpecCache = {}
local SpecCache = BBA.SpecCache  -- Stores GUID -> specID
local GetUnitTooltip = C_TooltipInfo and C_TooltipInfo.GetUnit or function() return nil end

-- Function to retrieve the specialization ID of a unit
local function GetSpecID(frame)
    local unit = frame.unit
    -- Check if the unit is a player
    if not UnitIsPlayer(unit) then
        return nil
    end

    local guid = UnitGUID(frame.unit)
    if issecretvalue(guid) then
        if BBP.isInArena then
            local i = BBP.GetArenaIndexByFrame(frame)
            if i then
                local specID = GetArenaOpponentSpec(i)
                if specID then
                    return specID
                end
            end
        end
        return
    end

    -- Return cached specID if already found
    if SpecCache[guid] and BBP.isInPvP then
        return SpecCache[guid]
    end

    -- Fetch tooltip data
    local tooltipData = GetUnitTooltip(unit)
    if not tooltipData or not tooltipData.guid or not tooltipData.lines then
        return nil
    end

    local tooltipGUID = tooltipData.guid

    -- Iterate through tooltip lines to find the spec name
    for _, line in ipairs(tooltipData.lines) do
        if line and line.type == Enum.TooltipDataLineType.None and line.leftText and line.leftText ~= "" then
            local specID = ALL_SPECS[line.leftText]
            if specID then
                SpecCache[guid] = specID
                return specID
            end
        end
    end
    --BBP.isMidnight

    return nil -- Return nil if no spec ID was found
end
BBP.GetSpecID = GetSpecID

-- Function to check if a unit is a healer
local function IsSpecHealer(frame)
    local unit = frame.unit

    -- Check if the unit is a player first (avoid processing NPCs)
    if not UnitIsPlayer(unit) then
        return false
    end

    local guid = UnitGUID(unit)
    if issecretvalue(guid) then
        if BBP.isInArena then
            local i = BBP.GetArenaIndexByFrame(frame)
            if i then
                local specID = GetArenaOpponentSpec(i)
                if specID then
                    return HEALER_SPEC_IDS[specID] or false
                end
            end
        end
        return false
    end

    -- Use cached spec ID if available
    local specID = (BBP.isInPvP and SpecCache[guid]) or GetSpecID(frame)

    -- If no valid spec ID found, return false
    if not specID then
        return false
    end

    -- Check if spec is a healer (direct lookup)
    return HEALER_SPEC_IDS[specID] or false
end
BBP.IsSpecHealer = IsSpecHealer


local function CreateBorder(frame, r, g, b, a)
    local border
    if frame.CreateTexture then
        border = frame:CreateTexture(nil, "OVERLAY", nil, -1)
    else
        border = frame:GetParent():CreateTexture(nil, "OVERLAY", nil, -1)
    end
    border:SetColorTexture(r, g, b, a)
    border:SetIgnoreParentScale(true)
    return border
end

function BBP.SetupBorderOnFrame(frame, hpBar)
    if frame.border then
        frame.border:Hide()
    end
    if hpBar then
        frame.healthBar.bgTexture:SetAlpha(0)
        frame.healthBar.selectedBorder:SetAlpha(0)
        -- frame = frame.HealthBarsContainer
        if not frame.background then
            frame.background = frame:CreateTexture(nil, "BACKGROUND")
            frame.background:SetAllPoints(frame)
            frame.background:SetColorTexture(0, 0, 0, 0.4)
        end
        --frame.selectedBorder:SetParent(frame.hiddenFrame)
    end
    if frame.newBorder then return end
    -- Create borders
    local borderTop = CreateBorder(frame, 0, 0, 0, 1)  -- Black color
    local borderBottom = CreateBorder(frame, 0, 0, 0, 1)
    local borderLeft = CreateBorder(frame, 0, 0, 0, 1)
    local borderRight = CreateBorder(frame, 0, 0, 0, 1)

    -- Store borders in a table
    frame["borders"] = {borderTop, borderBottom, borderLeft, borderRight}

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

-- What to do on a new nameplate
local function HandleNamePlateAdded(unit)
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if not frame then return end
    --frame:SetAlpha(1)

    -- CLean up previous nameplates
    HandleNamePlateRemoved(unit)

    --print("1: ", frame:GetFrameLevel(), nameplate:GetFrameLevel())
    -- Get settings and unitInfo
    frame.HealthBarsContainer.healthBar.selectedBorder:SetVertexColor(0.98, 0.98, 0.98, 1)
    local config = InitializeNameplateSettings(frame)
    local info = GetNameplateUnitInfo(frame, unit)
    if not info then return end
    local hooks = GetNameplateHookTable(frame)

    if info.isTarget then
        BBP.previousTargetNameplate = frame
        if BetterBlizzPlatesDB.nameplateResourceOnTarget then
            BBP.TargetResourceUpdater()
        end
    end
    BBP.HookCastbarOnEvent(frame)
    if not frame.bbpOverlay then
        frame.bbpOverlay = CreateFrame("Frame", nil, frame.HealthBarsContainer.healthBar)
        frame.bbpOverlay:SetFrameStrata("DIALOG")
        frame.bbpOverlay:SetFrameLevel(9000)

    end
    if BBP.isMidnight then

        local newBar = frame.HealthBarsContainer.healthBar
        -- frame.HealthBarsContainer.healthBar.selectedBorder:ClearAllPoints()
        -- frame.HealthBarsContainer.healthBar.selectedBorder:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -3, 4)
        -- frame.HealthBarsContainer.healthBar.selectedBorder:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", 3, -3)

        -- frame.HealthBarsContainer.healthBar.bgTexture:ClearAllPoints()
        -- frame.HealthBarsContainer.healthBar.bgTexture:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -3, 4)
        -- frame.HealthBarsContainer.healthBar.bgTexture:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", 3, -3)

        local castTexture = newBar:GetStatusBarTexture()
        if not newBar.MaskTexture then
        newBar.MaskTexture = newBar:CreateMaskTexture()
        end
        newBar.MaskTexture:SetTexture("interface\\castingbar\\uicastingbarfullmask")
        newBar.MaskTexture:ClearAllPoints()
        newBar.MaskTexture:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -13, 1.5)
        newBar.MaskTexture:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", 12, -0.5)
        newBar.MaskTexture:Show()
        castTexture:AddMaskTexture(newBar.MaskTexture)

        if not frame.bbpTargetHook then
            frame.bbpTargetHook = true
            hooksecurefunc(frame.HealthBarsContainer.healthBar.selectedBorder, "SetVertexColor", function(self, r, g, b, a)
                if frame:IsForbidden() then return end
                if frame.targetIndicator and r ~= 1 and g ~=1 and b ~= 1 then
                    frame.targetIndicator:Hide()
                end
            end)
        end

        -- BPP.isMidnight temp nameplate tweaks
        if not frame.bbpTempMidnightWidthHook then
            frame.bbpTempMidnightWidthHook = true
            hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(self)
                SetFriendlyBarWidthTemp(frame)
            end)

            -- hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(self)
            --     if frame:IsForbidden() or BetterBlizzPlatesDB.changeHealthbarHeight then return end
            --     self:SetSize(2, BetterBlizzPlatesDB.nameplateGeneralHpHeight or 16)
            -- end)
            -- frame.HealthBarsContainer:SetHeight(BetterBlizzPlatesDB.nameplateGeneralHpHeight or 16)
        end
        SetFriendlyBarWidthTemp(frame)
        AdjustHealthBarHeight(frame)

        if not frame.castBarIconFrame then
            frame.castBarIconFrame = CreateFrame("Frame", nil, frame.castBar)
            frame.castBarIconFrame:SetFrameStrata("MEDIUM")
            frame.castBarIconFrame:SetFrameLevel(frame.castBar:GetFrameLevel()+1)
            frame.castBarIconFrame:SetSize(14, 14)
            frame.castBarIconFrame:SetScale(BetterBlizzPlatesDB.castBarIconScale or 1.0)
            local xPos = BetterBlizzPlatesDB.castBarIconXPos or 0
            local yPos = BetterBlizzPlatesDB.castBarIconYPos or 0
            frame.castBarIconFrame:SetPoint("CENTER", frame.castBar, "LEFT", -2 + xPos, yPos)

            frame.castBarIconFrame.Icon = frame.castBarIconFrame:CreateTexture(nil, "OVERLAY")
            frame.castBarIconFrame.Icon:SetAllPoints(frame.castBarIconFrame)

            local currentTexture = frame.castBar.Icon:GetTexture()
            if currentTexture then
                frame.castBarIconFrame.Icon:SetTexture(currentTexture)
            end

            frame.castBar.Icon:SetAlpha(0)

            hooksecurefunc(frame.castBar.Icon, "SetTexture", function(self, texture)
                if frame:IsForbidden() then return end
                frame.castBarIconFrame.Icon:SetTexture(texture)
            end)

            hooksecurefunc(frame.castBar.Icon, "Show", function(self)
                if frame:IsForbidden() then return end
                frame.castBarIconFrame:Show()
            end)

            hooksecurefunc(frame.castBar.Icon, "SetShown", function(self)
                if frame:IsForbidden() then return end
                frame.castBarIconFrame:SetShown(self:IsShown())
            end)

            hooksecurefunc(frame.castBar.Icon, "Hide", function(self)
                if frame:IsForbidden() then return end
                frame.castBarIconFrame:Hide()
            end)

            hooksecurefunc(frame.castBar.BorderShield, "SetPoint", function(self)
                if frame:IsForbidden() then return end
                if self.changingIconPos then return end
                self.changingIconPos = true
                self:ClearAllPoints()
                if frame.castBarIconFrame:IsShown() then
                    self:SetPoint("TOPLEFT", frame.castBarIconFrame, "TOPLEFT", -2, 2)
                    self:SetPoint("BOTTOMRIGHT", frame.castBarIconFrame, "BOTTOMRIGHT", 2, -4)
                else
                    self:SetPoint("TOPLEFT", frame.castBarIconFrame, "TOPLEFT", 0, 0)
                    self:SetPoint("BOTTOMRIGHT", frame.castBarIconFrame, "BOTTOMRIGHT", 0, -2)
                end
                self.changingIconPos = nil
            end)
        end

        BBP.CastbarOnEvent(frame)
    end

    -- Make settings
    if BetterBlizzPlatesDB.enableMidnightNameplateTweaks then
        if not frame.bbpCCIconSizeHook then
            frame.bbpCCIconSizeHook = true
            hooksecurefunc(frame.AurasFrame.LossOfControlFrame, "SetScale", function(self)
                if self.changing or self:IsForbidden() then return end
                self.changing = true
                self:SetScale(BetterBlizzPlatesDB.ccIconScale or 1.35)
                self:ClearAllPoints()
                --if BetterBlizzPlatesDB.ccIconAnchor == "RIGHT" then --  TODO: fix later
                    self:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 5, 0)
                -- elseif BetterBlizzPlatesDB.ccIconAnchor == "LEFT" then
                --     self:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -5, 0)
                -- elseif BetterBlizzPlatesDB.ccIconAnchor == "TOP" then
                --     self:SetPoint("BOTTOM", frame.HealthBarsContainer, "TOP", 0, 30)
                -- end
                self.changing = false
            end)
            hooksecurefunc(frame.AurasFrame.CrowdControlListFrame, "SetScale", function(self)
                if self.changing or self:IsForbidden() then return end
                self.changing = true
                self:SetScale(BetterBlizzPlatesDB.ccIconScale or 1.35)
                self:ClearAllPoints()
                --if BetterBlizzPlatesDB.ccIconAnchor == "RIGHT" then
                    self:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 5, 1)
                -- elseif BetterBlizzPlatesDB.ccIconAnchor == "LEFT" then
                --     self:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -5, 21)
                -- elseif BetterBlizzPlatesDB.ccIconAnchor == "TOP" then
                --     self:SetPoint("BOTTOM", frame.HealthBarsContainer, "TOP", 0, 30)
                -- end
                self.changing = false
            end)
            hooksecurefunc(frame.AurasFrame.BuffListFrame, "SetScale", function(self)
                if self.changing or self:IsForbidden() then return end
                self.changing = true
                self:SetScale(BetterBlizzPlatesDB.buffIconScale or 1.35)
                self:ClearAllPoints()
                --if BetterBlizzPlatesDB.buffIconAnchor == "LEFT" then
                    self:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -5, 1)
                -- elseif BetterBlizzPlatesDB.buffIconAnchor == "RIGHT" then
                --     self:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 5, 1)
                -- elseif BetterBlizzPlatesDB.buffIconAnchor == "TOP" then
                --     self:SetPoint("BOTTOM", frame.HealthBarsContainer, "TOP", 0, 30)
                -- end
                self.changing = false
            end)
            frame.AurasFrame.LossOfControlFrame:SetScale(BetterBlizzPlatesDB.ccIconScale or 1.35)
            frame.AurasFrame.CrowdControlListFrame:SetScale(BetterBlizzPlatesDB.ccIconScale or 1.35)
            frame.AurasFrame.BuffListFrame:SetScale(BetterBlizzPlatesDB.buffIconScale or 1.35)
        end
    end

    -- if not frame.bbpMidnightHooks then
    --     frame.bbpMidnightHooks = true
    -- end


    if BetterBlizzPlatesDB.classicRetailNameplates then
        BBP.SetupBorderOnFrame(frame.HealthBarsContainer, true)
        if config.changeNameplateBorderColor then
            BBP.ColorNameplateBorder(frame)
        else
            if UnitIsUnit(unit, "target") then
                frame.HealthBarsContainer:SetBorderColor(1, 1, 1, 1)
            else
                frame.HealthBarsContainer:SetBorderColor(0, 0, 0, 1)
            end
        end
    end
    if BetterBlizzPlatesDB.classicRetailNameplates or not config.useCustomTextureForBars then
        if frame.HealthBarsContainer.healthBar.MaskTexture then
            frame.HealthBarsContainer.healthBar.MaskTexture:Hide()
            frame.HealthBarsContainer.healthBar.deselectedOverlay:SetAlpha(0)
        end
    end
    -- if info.isFriend and BetterBlizzPlatesDB.friendlyNameplateClickthrough then
    --     frame.HitTestFrame:ClearAllPoints()
    --     frame.HitTestFrame:SetPoint("TOPLEFT", frame.HealthBarsContainer, "CENTER", 0, -50)
    --     frame.HitTestFrame:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "CENTER", 0, -50)
    -- else
    --     frame.HitTestFrame:ClearAllPoints()
    --     local extraClickHeight = 40 + (BetterBlizzPlatesDB.nameplateExtraClickHeight or 0)
    --     local extraClickWidth = 12 + (BetterBlizzPlatesDB.nameplateExtraClickWidth or 0)
    --     frame.HitTestFrame:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -extraClickWidth, extraClickHeight)
    --     frame.HitTestFrame:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT", extraClickWidth, -20)
    -- end

    BBP.HookNameplatePosition(frame, nameplate)

    if not frame.nameplateTweaksBBP then
        frame.ClassificationFrame:SetParent(frame.HealthBarsContainer)
        frame.castBar.Icon:SetIgnoreParentAlpha(false)
        frame.castBar.BorderShield:SetIgnoreParentAlpha(false)
        frame.nameplateTweaksBBP = true
    end

    --print("2: ", frame:GetFrameLevel(), nameplate:GetFrameLevel())

    --BBP.greenScreen(nameplate)

    local alwaysHideFriendlyCastbar = BetterBlizzPlatesDB.alwaysHideFriendlyCastbar
    local alwaysHideEnemyCastbar = BetterBlizzPlatesDB.alwaysHideEnemyCastbar
    if alwaysHideFriendlyCastbar or alwaysHideEnemyCastbar or BBP.hideFriendlyCastbar then
        if ((alwaysHideFriendlyCastbar or BBP.hideFriendlyCastbar) and frame.isFriend) or (alwaysHideEnemyCastbar and not frame.isFriend) then
            if (BetterBlizzPlatesDB.alwaysHideFriendlyCastbarShowTarget and frame.isFriend) or (BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget and not frame.isFriend) then
                -- go thruugh
            else
                frame.castBar:Hide()
            end
        end
    end

    if info.isFocus then
        BBP.previousFocusNameplate = frame
    end
    BBP.CustomizeClassificationFrame(frame)
    --print(frame.ClassificationFrame:GetFrameStrata(), frame.ClassificationFrame:GetFrameLevel())

    -- if not frame.hookedHp then
    --     hooksecurefunc(frame.healthBar, "SetHeight", function(self)
    --         if self.changing or self:IsForbidden() then return end
    --         self.changing = true
    --         self:SetHeight(30)
    --         self.changing = false
    --     end)
    --     frame.hookedHp = true
    -- end
    -- Check and set settings

    -- frame.healthBar:ClearPoint("RIGHT")
    -- frame.healthBar:ClearPoint("LEFT")
    -- frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 20,0)
    -- frame.healthBar:SetPoint("LEFT", frame, "CENTER", -20, 0)

    -- if not frame.hoks then
    --     hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(self)
    --         if self.changing then return end
    --         cc = cc + 1
    --         print("aaa", cc)
    --         self.changing = true
    --         frame.HealthBarsContainer:ClearPoint("RIGHT")
    --         frame.HealthBarsContainer:ClearPoint("LEFT")
    --         frame.HealthBarsContainer:SetPoint("RIGHT", frame, "CENTER", 40,0)
    --         frame.HealthBarsContainer:SetPoint("LEFT", frame, "CENTER", -40, 0)

    --         self.changing = false
    --     end)
    --     frame.HealthBarsContainer:ClearPoint("RIGHT")
    --     frame.HealthBarsContainer:ClearPoint("LEFT")
    --     frame.HealthBarsContainer:SetPoint("RIGHT", frame, "CENTER", 40,0)
    --     frame.HealthBarsContainer:SetPoint("LEFT", frame, "CENTER", -40, 0)

    --     frame.hoks = true
    -- end

    if config.bgIndicator then BBP.BgIndicator(frame) end

    -- BBP.isMidnight
    -- if BetterBlizzPlatesDB.hideTempHpLoss then
    --     local tempHp = frame.HealthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture
    --     tempHp:SetAlpha(0)
    -- elseif BetterBlizzPlatesDB.recolorTempHpLoss then
    --     local tempHp = frame.HealthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture
    --     tempHp:SetVertexColor(1,0,0)
    --     tempHp:SetBlendMode("ADD")
    -- end

    -- Hide default personal BuffFrame
    -- if config.enableNameplateAuraCustomisation then
    --     frame.AurasFrame.UpdateAnchor = BBP.UpdateAnchor;
    --     frame.AurasFrame.Layout = function(self)
    --         local children = self:GetLayoutChildren()
    --         local isEnemyUnit = self.isEnemyUnit
    --         BBP.CustomBuffLayoutChildren(self, children, isEnemyUnit, frame)
    --     end
    --     --frame.AurasFrame.UpdateBuffs = BBP.UpdateBuffs
    --     frame.AurasFrame.UpdateBuffs = function() return end
    --     BBP.UpdateBuffs(frame.AurasFrame, unit, nil, {}, frame)
    --     if auraModuleIsOn then
    --         BBP.HidePersonalBuffFrame()
    --     end
    -- end--and auraModuleIsOn then BBP.HidePersonalBuffFrame() end

    if BetterBlizzPlatesDB.changeNpHpBgColor then
        if not frame.HealthBarsContainer.background then
            frame.HealthBarsContainer.background = frame.HealthBarsContainer:CreateTexture(nil, "BACKGROUND")
            frame.HealthBarsContainer.background:SetAllPoints(frame.HealthBarsContainer)
        end
        frame.HealthBarsContainer.background:SetTexture("Interface\\Buttons\\WHITE8x8")
        frame.HealthBarsContainer.background:SetVertexColor(unpack(BetterBlizzPlatesDB.npBgColorRGB))
    end

    if config.changeNameplateBorderSize then
        ChangeHealthbarBorderSize(frame)
    -- elseif BetterBlizzPlatesDB.classicRetailNameplates and frame.HealthBarsContainer.newBorder then
    --     -- Ensure classicRetailNameplates borders are initialized even if changeNameplateBorderSize is off
    --     ChangeHealthbarBorderSize(frame)
    end

    -- Apply custom healthbar texture
    if config.useCustomTextureForBars or BBP.needsUpdate or BetterBlizzPlatesDB.classicRetailNameplates then BBP.ApplyCustomTextureToNameplate(frame) end

    -- Hook castbar hide function for resource
    if config.nameplateResourceUnderCastbar then HookNameplateCastbarHide(frame) end

    -- Anon mode
    if config.anonModeOn then anonMode(frame, info) end

    if config.arenaIndicatorBg then
        BBP.BattlegroundSpecNames(frame, nameplate, info.unitGUID)
    end

    -- Show Arena ID/Spec
    if config.arenaIndicators then BBP.ArenaIndicatorCaller(frame) end

    ToggleTargetNameplateHighlight(frame)

    -- Castbar customization
    if config.enableCastbarCustomization then BBP.CustomizeCastbar(unit) end

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

    -- Hide friendly healthbar (non magic version)
    if config.friendlyHideHealthBar or config.friendlyHideHealthBarNpc then HideFriendlyHealthbar(frame) end

    -- Fade out NPCs from list if enabled
    if config.fadeOutNPC then BBP.FadeOutNPCs(frame) end

    if config.enableNpNonTargetAlpha then BBP.NameplateTargetAlpha(frame) end

    -- Hide NPCs from list if enabled
    if config.hideNPC then BBP.HideNPCs(frame, nameplate) end

    if config.partyPointer or config.partyPointerTestMode then BBP.PartyPointer(frame) end

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

    SmallPetsInPvP(frame)

    -- Name repositioning
    if config.useFakeName then BBP.RepositionName(frame) end

    if config.showNpcTitle then NameplateNPCTitle(frame) end

    if config.showLastNameNpc then ShowLastNameOnlyNpc(frame) end

    -- Color nameplate depending on aura
    if config.auraColor then BBP.AuraColor(frame) end

    -- Friend Indicator
    if config.friendIndicator then FriendIndicator(frame) end

    if config.classicNameplates then
        CreateBetterClassicHealthbarBorder(frame)
        if info.isSelf then
            frame.ClassicLevelFrame:Hide()
            frame.ClassicLevelFrame.text:Hide()
            frame.ClassicLevelFrame.skull:Hide()
        end
        frame.HealthBarsContainer.healthBar.selectedBorder:SetAlpha(0)
        frame.classicNameplatesOn = true
    elseif frame.classicNameplatesOn then
        frame.BetterBlizzPlates.bbpBorder:Hide()
        if frame.HealthBarsContainer.border then
            frame.HealthBarsContainer.border:Show()
        end
        frame.classicNameplatesOn = nil
    end

    if not config.classicNameplates then
        if not BetterBlizzPlatesDB.hideLevelFrame then
            CreateLevelFrame(frame)
            UpdateLevelFrame(frame)
        else
            if frame.bbfLevelFrame then
                frame.bbfLevelFrame:Hide()
                frame.bbfLevelFrame.text:Hide()
                frame.bbfLevelFrame.skull:Hide()
            end
        end
    end

    -- Hook nameplate border color
    if config.changeNameplateBorderColor then
        if not config.classicNameplates then
            HookNameplateBorder(frame)
            HookSelectedBorder(frame)
        else
            BBP.ColorNameplateBorder(frame)
        end
    end

    local showNameplateTargetText = BetterBlizzPlatesDB.showNameplateTargetText
    if showNameplateTargetText then
        BBP.UpdateNameplateTargetText(frame, frame.unit)
    end

    -- Hide name
    if ((config.hideFriendlyNameText or (config.partyPointerHideAll and frame.partyPointer and frame.partyPointer:IsShown())) and info.isFriend) or (config.hideEnemyNameText and not info.isFriend) then
        frame.name:SetAlpha(0)
    end

    if config.showGuildNames then ShowFriendlyGuildName(frame, frame.unit) end

    NameplateShadowAndMouseoverHighlight(frame)

    -- print("3: ", frame:GetFrameLevel(), nameplate:GetFrameLevel())
    -- print("______________________")
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
        BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultLargeNamePlateFontFlags)
        BBP.SetFontBasedOnOption(SystemFont_NamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultNamePlateFontFlags)
        BBP.SetFontBasedOnOption(SystemFont_LargeNamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultLargeNamePlateFontFlags)
        BBP.SetFontBasedOnOption(SystemFont_NamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultNamePlateFontFlags)
    end
    BBP.UpdateAuraTypeColors()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        local unitFrame = nameplate.UnitFrame
        if not frame or frame:IsForbidden() then return end
        local unitToken = frame.unit
        if not frame.unit then return end

        --local config = InitializeNameplateSettings(frame)
        local info = GetNameplateUnitInfo(frame)
        if not info then return end
        --nameplate:OnSizeChanged()

        if nameplate.clickableAreaText then
            local isClickthroughFriend = UnitIsFriend("player", frame.unit) and BetterBlizzPlatesDB.friendlyNameplateClickthrough
            nameplate.clickableAreaText:SetText(isClickthroughFriend and "Un-clickable" or "Clickable Area")
        end

        local hideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar

        if not BetterBlizzPlatesDB.hideRaidmarkIndicator then
            frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
        end

        -- if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
        --     BBP.RefUnitAuraTotally(unitFrame)
        -- end

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

        if BetterBlizzPlatesDB.enableCastbarCustomization then
            BBP.CustomizeCastbar(unitToken)
        end

        BBP.ClassColorAndScaleNames(frame)

        if frame.TargetText then
            BBP.SetFontBasedOnOption(frame.TargetText, BetterBlizzPlatesDB.npTargetTextSize or 12)
        end
        if frame.absorbIndicator then
            BBP.SetFontBasedOnOption(frame.absorbIndicator, 10)
        end
        if frame.CastTimer then
            BBP.SetFontBasedOnOption(frame.CastTimer, BetterBlizzPlatesDB.npTargetTextSize or 11)
        end
        if frame.executeIndicator then
            BBP.SetFontBasedOnOption(frame.executeIndicator, 10, "THICKOUTLINE")
        end
        if frame.arenaNumberText then
            BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
        end
        if frame.specNameText then
            --BBP.SetFontBasedOnOption(frame.specNameText, 12, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or nil)
            BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
        end
        if frame.guildName then
            if BetterBlizzPlatesDB.showGuildNames then
                ShowFriendlyGuildName(frame, frame.unit)
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
        if BetterBlizzPlatesDB.enableNpNonTargetAlpha then
            BBP.NameplateTargetAlpha(frame)
        end
        if not BetterBlizzPlatesDB.fadeOutNPC then
            if not BetterBlizzPlatesDB.enableNpNonTargetAlpha then
                frame:SetAlpha(1)
            end
        end
        if not BetterBlizzPlatesDB.friendlyHideHealthBar then
            if frame.healthBar then
                if not hideHealthBar and not BetterBlizzPlatesDB.totemIndicatorTestMode then
                    frame.HealthBarsContainer:SetAlpha(1)
                    frame.HealthBarsContainer.alphaZero = false
                end
            end
        end
        HideFriendlyHealthbar(frame)
        if not BetterBlizzPlatesDB.hideNPC then
            if frame then
                frame:Show()
            end
        end
        if BetterBlizzPlatesDB.totemIndicatorTestMode then
            if hideHealthBar then
                frame.HealthBarsContainer:SetAlpha(0)
                frame.HealthBarsContainer.alphaZero = true
                frame.selectionHighlight:SetAlpha(0)
            else
                local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
                frame.HealthBarsContainer:SetAlpha(1)
                frame.HealthBarsContainer.alphaZero = false
                if not hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end

        if frame.castBar then
            if not BetterBlizzPlatesDB.useCustomCastbarBGTexture or not BetterBlizzPlatesDB.useCustomCastbarTexture then
                frame.castBar.Background:SetDesaturated(false)
                frame.castBar.Background:SetVertexColor(1,1,1,1)
                frame.castBar.Background:SetAtlas("UI-CastingBar-Background")
            else
                local bgTextureName = BetterBlizzPlatesDB.customCastbarBGTexture
                local bgTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, bgTextureName)
                local changeBgTexture = BetterBlizzPlatesDB.useCustomCastbarBGTexture
                if changeBgTexture then
                    local bgColor = BetterBlizzPlatesDB.castBarBackgroundColor
                    frame.castBar.Background:SetDesaturated(true)
                    frame.castBar.Background:SetTexture(bgTexture)
                    frame.castBar.Background:SetAllPoints(frame.castBar)
                    frame.castBar.Background:SetVertexColor(unpack(bgColor))
                end
            end
        end

        if BetterBlizzPlatesDB.targetIndicator then
            BBP.TargetIndicator(frame)
        end

        if BetterBlizzPlatesDB.hideNPC then
            BBP.HideNPCs(frame, nameplate)
        end

        if BetterBlizzPlatesDB.classicNameplates then
            CreateBetterClassicHealthbarBorder(frame)
        end

        if BetterBlizzPlatesDB.classIndicator then
            BBP.ClassIndicator(frame)
        end

        if BetterBlizzPlatesDB.partyPointer or BetterBlizzPlatesDB.partyPointerTestMode then
            BBP.PartyPointer(frame)
        else
            if frame.partyPointer then
                frame.partyPointer:Hide()
            end
        end
        if BetterBlizzPlatesDB.focusTargetIndicator then
            BBP.FocusTargetIndicator(frame)
        end
        BBP.ConsolidatedUpdateName(frame)
        SetFriendlyBarWidthTemp(frame)
        AdjustHealthBarHeight(frame)
        --HideFriendlyHealthbar(frame)
    end
end

hooksecurefunc(NamePlateUnitFrameMixin, "OnUnitFactionChanged", function(self)
    if not self.unit then return end

    if self.unit:find("nameplate") then
        HandleNamePlateAdded(self.unit)
        C_Timer.After(0.2, function()
            if not self or not self.unit then return end
            HandleNamePlateAdded(self.unit)
        end)
    end
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
    if not frame or frame:IsForbidden() or not frame.unit then return end
    -- Further processing only for nameplate units
    if not frame.unit:find("nameplate") then return end

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
        config.removeRealmNames = BetterBlizzPlatesDB.removeRealmNames
        config.classIndicator = BetterBlizzPlatesDB.classIndicator
        config.classIconHealthNumbers = BetterBlizzPlatesDB.classIconHealthNumbers
        config.personalBarTweaks = BetterBlizzPlatesDB.personalBarTweaks

        config.updateNameInitialized = true
    end

    if config.removeRealmNames then
        BBP.RemoveRealmName(frame)
    end

    if not frame.bbpOverlay then
        frame.bbpOverlay = CreateFrame("Frame", nil, frame.healthBar)
        frame.bbpOverlay:SetFrameStrata("DIALOG")
        frame.bbpOverlay:SetFrameLevel(9000)
    end

    if frame.castHiddenName then
        frame.name:SetText("")
        return
    end

    if info.isSelf then
        if config.personalBarTweaks then
            frame.name:Show()
            frame.name:SetIgnoreParentScale(true)
            frame.name:SetScale(BetterBlizzPlatesDB.friendlyNameScale+0.34)
            local rpDB = TRP3_Configuration
            if rpDB then
                if rpDB.NamePlates_CustomizeNames then
                    local rpNamesFull = rpDB.NamePlates_CustomizeNames == 1
                    local rpNamesFirst = rpDB.NamePlates_CustomizeNames == 2
                    local rpNamesLast = rpDB.NamePlates_CustomizeNames == 3
                    if rpNamesFull then
                        rpNamesFirst = true
                        rpNamesLast = true
                    end
                    SetRPName(frame.name, "player", rpNamesFirst, rpNamesLast)
                    -- first name == 2
                    -- both == 1
                    -- last == 3?
                end
                if rpDB.NamePlates_CustomizeNameColors then
                    local r,g,b = GetRPNameColor("player")
                    if r then
                        frame.name:SetVertexColor(r,g,b)
                    else
                        local friendlyColorName = BetterBlizzPlatesDB.friendlyColorName
                        local friendlyClassColorName = BetterBlizzPlatesDB.friendlyClassColorName
                        if friendlyClassColorName then
                            local _, class = UnitClass(frame.unit)
                            local classColor = RAID_CLASS_COLORS[class]
                            frame.name:SetVertexColor(classColor.r, classColor.g, classColor.b)
                        elseif friendlyColorName then
                            frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.friendlyColorNameRGB))
                        else
                            frame.name:SetVertexColor(1, 1, 0)
                        end
                    end
                end
                return
            else
                frame.name:SetText(UnitName("player"))
            end

            -- local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
            -- if ((isEnemy or isNeutral) and enemyClassColorName) or (isFriend and friendlyClassColorName) then
            --     local _, class = UnitClass(frame.unit)
            --     local classColor = RAID_CLASS_COLORS[class]
            --     frame.name:SetVertexColor(classColor.r, classColor.g, classColor.b)
            -- elseif ((isEnemy or isNeutral) and enemyColorName) or (isFriend and friendlyColorName) then
            --     local color = isEnemy and BetterBlizzPlatesDB.enemyColorNameRGB or BetterBlizzPlatesDB.friendlyColorNameRGB
            --     frame.name:SetVertexColor(unpack(color))
            -- end

        else
            return
        end
    end

    -- Class color and scale names depending on their reaction
    BBP.ClassColorAndScaleNames(frame)
    -- BBP.isMidnight
    local db = BetterBlizzPlatesDB
    BBP.SetFontBasedOnOption(frame.name, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")
    -- Default new np name pos, this removes truncate:
    --frame.name:ClearAllPoints()
    --frame.name:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "TOPLEFT", 4.2, 2)

    -- Color NPC
    if config.colorNPC and config.colorNPCName and config.npcHealthbarColor then
        frame.name:SetVertexColor(config.npcHealthbarColor.r, config.npcHealthbarColor.g, config.npcHealthbarColor.b)
    end

    --BBP.RepositionName(frame)

    if config.colorFocusName and info.isFocus then
        frame.name:SetVertexColor(unpack(config.focusTargetIndicatorColorNameplateRGB))
    end

    if config.colorTargetName and info.isTarget then
        frame.name:SetVertexColor(unpack(config.targetIndicatorColorNameplateRGB))
    end

    --if config.useFakeName then BBP.RepositionName(frame) end

    if config.showLastNameNpc then ShowLastNameOnlyNpc(frame) end

    -- Anon mode replace name with class
    if config.anonModeOn then anonMode(frame, info) end

    -- Use arena numbers
    if config.arenaIndicators then BBP.ArenaIndicatorCaller(frame) end

    if config.arenaIndicatorBg then
        BBP.BattlegroundSpecNames(frame)
    end

    -- -- Handle absorb indicator and reset absorb text if it exists
    -- if config.absorbIndicator then BBP.AbsorbIndicator(frame) end

    -- Show out of combat icon
    if config.combatIndicator then BBP.CombatIndicator(frame) end

    -- -- Show hunter pet icon
    -- if config.petIndicator then BBP.PetIndicator(frame) end

    -- -- Show healer icon
    -- if config.healerIndicator then BBP.HealerIndicator(frame) end

    -- Show Class Indicator
    --if config.classIndicator then BBP.ClassIndicator(frame) end --and not info.isSelf then BBP.ClassIndicator(frame) end bodify not sure if this needs to run here

    -- Color nameplate and pick random name or hide name during totem tester
    if config.totemIndicatorTest then
        if config.totemIndicatorColorName then
            frame.name:SetVertexColor(unpack(frame.randomColor))
            if config.totemIndicatorHideNameAndShiftIconDown then
                frame.name:SetText("")
            else
                frame.name:SetText(frame.randomName)
            end
        end
    end

    -- Ensure totem nameplate color is correct
    if config.totemIndicator and info.isNpc then
        local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)
        local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID]

        if npcData then
            if not config.totemIndicatorInitialized or BBP.needsUpdate then
                config.totemIndicatorXPos = BetterBlizzPlatesDB.totemIndicatorXPos
                config.totemIndicatorYPos = BetterBlizzPlatesDB.totemIndicatorYPos

                config.totemIndicatorHideNameAndShiftIconDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
                config.totemIndicatorTestMode = BetterBlizzPlatesDB.totemIndicatorTestMode
                config.totemIndicatorHideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar
                config.totemIndicatorEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
                config.hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
                config.totemIndicatorAnchor = BetterBlizzPlatesDB.totemIndicatorAnchor
                config.showTotemIndicatorCooldownSwipe = BetterBlizzPlatesDB.showTotemIndicatorCooldownSwipe
                config.totemIndicatorScale = BetterBlizzPlatesDB.totemIndicatorScale
                config.totemIndicatorTestMode = BetterBlizzPlatesDB.totemIndicatorTestMode
                config.totemIndicatorDefaultCooldownTextSize = BetterBlizzPlatesDB.totemIndicatorDefaultCooldownTextSize
                config.totemIndicatorColorHealthBar = BetterBlizzPlatesDB.totemIndicatorColorHealthBar
                config.totemIndicatorColorName = BetterBlizzPlatesDB.totemIndicatorColorName
                config.totemIndicatorHideAuras = BetterBlizzPlatesDB.totemIndicatorHideAuras
                config.totemIndicatorWidthEnabled = BetterBlizzPlatesDB.totemIndicatorWidthEnabled
                config.totemIndicatorUseNicknames = BetterBlizzPlatesDB.totemIndicatorUseNicknames

                config.totemIndicatorInitialized = true
            end
            local color = npcData.color

            if not info.isFriend or (info.isFriend and not config.totemIndicatorEnemyOnly) then
                if config.totemIndicatorColorHealthBar and color then
                    frame.healthBar:SetStatusBarColor(unpack(color))
                end

                if config.totemIndicatorHideNameAndShiftIconDown then
                    frame.name:SetText("")
                elseif config.totemIndicatorColorName and color then
                    frame.name:SetVertexColor(unpack(color))
                end

                if config.totemIndicatorUseNicknames then
                    frame.name:SetText(npcData.name)
                end
            end

            if npcData.iconOnly then
                frame.name:SetText("")
                frame.name:SetAlpha(0)
            end
        end
    end


    -- if frame.isBBPTotem then
    --     if config.totemIndicatorColorName or config.totemIndicatorHideNameAndShiftIconDown then
    --         frame.name:SetText("")
    --     elseif frame.BBPTotemColor then
    --         frame.name:SetVertexColor(unpack(frame.BBPTotemColor))
    --     end
    -- end

    if (config.hideFriendlyNameText and info.isFriend) or (config.hideEnemyNameText and not info.isFriend) then
        frame.name:SetAlpha(0)
    end

    if frame.hideNameOverride then
        frame.name:SetAlpha(0)
    else
        if frame.partyPointer and config.partyPointerHideAll and frame.partyPointer:IsShown() then
            frame.name:SetAlpha(0)
        end
    end

    if frame.classIndicatorHideName then
        frame.name:SetText("")
    elseif config.classIndicator and config.classIconHealthNumbers then
        BBP.UpdateHealthText(frame)
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

function IsInBrawlCompStomp()
    if C_PvP.IsInBrawl() then
        local brawlInfo = C_PvP.GetActiveBrawlInfo()
        if brawlInfo and (brawlInfo.name and brawlInfo.name == "Brawl: Comp Stomp") then
            return true
        end
    end
    return false
end

-- Function to update the instance status
local function UpdateInstanceStatus()
    local inInstance, instanceType = IsInInstance()
    BBP.isInPvE = inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario")
    BBP.isInArena = inInstance and (instanceType == "arena")
    BBP.isInBg = inInstance and (instanceType == "pvp")
    BBP.isInPvP = BBP.isInBg or BBP.isInArena
    BBP.IsInCompStomp = IsInBrawlCompStomp()

    local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    BBP.isInAV = instanceMapID == 30 -- Alterac Valley
end

-- Function to update the current class role
local function UpdateClassRoleStatus(self, event)
    if not BetterBlizzPlatesDB.enemyColorThreat then return end
    local specIndex = GetSpecialization()
    local role = specIndex and GetSpecializationRole(specIndex)
    BBP.isRoleTank = role == "TANK"

    offTanks = GetGroupTanks()
end

local ClassRoleChecker = CreateFrame("Frame")
ClassRoleChecker:RegisterEvent("PLAYER_ENTERING_WORLD")
ClassRoleChecker:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
ClassRoleChecker:RegisterEvent("PLAYER_ROLES_ASSIGNED")
ClassRoleChecker:RegisterEvent("GROUP_ROSTER_UPDATE")
ClassRoleChecker:SetScript("OnEvent", UpdateClassRoleStatus)

local function ThreatSituationUpdate(self, event, unit)
    if BetterBlizzPlatesDB.enemyColorThreat and (BBP.isInPvE or (BetterBlizzPlatesDB.threatColorAlwaysOn and (not BBP.isInPvP or BBP.isInAV))) then
        if event == "UNIT_THREAT_SITUATION_UPDATE" then
            if UnitIsPlayer(unit) then return end
            for _, nameplate in pairs(C_NamePlate.GetNamePlates(issecure())) do
                local frame = nameplate.UnitFrame
                local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
                if config.totemColorRGB then return end
                BBP.ColorThreat(frame)
            end
        elseif event == "UNIT_TARGET" then
            -- update frame specific
            if UnitIsPlayer(unit) then return end
            local np, frame = BBP.GetSafeNameplate(unit)
            if frame then
                local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
                if config.totemColorRGB then return end
                BBP.ColorThreat(frame)
            end
        end
    end
end

local ThreatSitUpdate = CreateFrame("Frame")
ThreatSitUpdate:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
ThreatSitUpdate:RegisterEvent("UNIT_TARGET")
ThreatSitUpdate:SetScript("OnEvent", ThreatSituationUpdate)

-- Function to set the nameplate behavior
local InstanceChecker = CreateFrame("Frame")

local function SetStackingNameplateBehaviour(enabled)
    BBP.CVarTrackingDisabled = true
    C_CVar.SetCVar("nameplateMotion", enabled and 1 or 0)
    BBP.CVarTrackingDisabled = nil
end

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
            if BetterBlizzPlatesDB.nameplateMotion == "1" and BetterBlizzPlatesDB.keepOverlappingNameplatesInPvP then
                SetStackingNameplateBehaviour(true)
            end
            BBP.ApplyNameplateWidth()
        else
            --if BetterBlizzPlatesDB.friendlyHideHealthBar then C_CVar.SetCVar('nameplateShowOnlyNames', 0) end
            C_CVar.SetCVar('nameplateShowOnlyNames', 0)
            if BetterBlizzPlatesDB.toggleNamesOffDuringPVE then C_CVar.SetCVar("UnitNameFriendlyPlayerName", 1) end
            if BetterBlizzPlatesDB.nameplateMotion == "1" and BetterBlizzPlatesDB.keepOverlappingNameplatesInPvP then
                if BBP.isInPvP then
                    SetStackingNameplateBehaviour(false)
                else
                    SetStackingNameplateBehaviour(true)
                end
            end
            BBP.ApplyNameplateWidth()
        end
    end
end
BBP.SetNameplateBehavior = SetNameplateBehavior

-- Event handler function
local hideFriendlyCastbar
local function CheckIfInInstance(self, event, ...)
    hideFriendlyCastbar = BetterBlizzPlatesDB.alwaysHideFriendlyCastbar or BetterBlizzPlatesDB.hideCastbarFriendly
    -- UpdateInstanceStatus()
    -- SetNameplateBehavior()
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        SpecCache = {}
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
    if BBP.friendlyHideHealthBar then
        BBP.friendlyHideHealthBar:SetChecked(BetterBlizzPlatesDB.friendlyHideHealthBar)
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

local function HideHealthbarInPvEMagic()
    if (BetterBlizzPlatesDB.friendlyHideHealthBar or BetterBlizzPlatesDB.friendlyHideHealthBarNpc) and not hookedGetNamePlateTypeFromUnit then
        -- Set the hook flag
        hookedGetNamePlateTypeFromUnit = true

        local hideDungeonNPCs = BetterBlizzPlatesDB.friendlyHideHealthBarNpc and not BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve

        -- nameplateShowOnlyNameForFriendlyPlayerUnits TODO: sort out this stuff

        --BBP.isMidnight
        -- hooksecurefunc(
        --     NamePlateDriverFrame,
        --     'GetNamePlateTypeFromUnit',
        --     function(_, unit)
        --         if BBP.isInPvE then
        --             local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
        --             local isPlayer = UnitIsPlayer(unit) and BetterBlizzPlatesDB.friendlyHideHealthBar
        --             if not isFriend then
        --                 setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        --                 setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
        --             else
        --                 if isPlayer or hideDungeonNPCs then
        --                     local isTankOrHeal
        --                     if BetterBlizzPlatesDB.friendlyHideHealthBarShowTanksAndHeals then
        --                         local role = UnitGroupRolesAssigned(unit)
        --                         isTankOrHeal = role == "TANK" or role == "HEALER"
        --                     end
        --                     local skipHide = BetterBlizzPlatesDB.doNotHideFriendlyHealthbarInPve or (BetterBlizzPlatesDB.friendlyHideHealthBarShowPet and UnitIsUnit("pet", unit)) or isTankOrHeal or (UnitIsPlayer(unit) and not BetterBlizzPlatesDB.friendlyHideHealthBar)
        --                     if not skipHide then
        --                         setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        --                     else
        --                         setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        --                     end
        --                     -- This method doesnt seem to work for castbar, works fine for healthbar.
        --                     if hideFriendlyCastbar then
        --                         setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
        --                     else
        --                         setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
        --                     end
        --                 else
        --                     setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        --                     setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
        --                 end
        --             end
        --         end
        --         -- if not UnitIsPlayer(unit) then
        --         --     setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        --         -- else
        --         --     setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        --         -- end
        --     end
        -- )
    end
end

function BBP.HideHealthbarInPvEMagicCaller()
    HideHealthbarInPvEMagic()
end

local function HookNpFlagUpdates()
    -- BBP.isMidnight -- Fix this to get texture from the old arena frames, they might have orb texture? or at least do unitisunit then add flag/orb texture
    -- if BetterBlizzPlatesDB.classIndicator or BetterBlizzPlatesDB.bgIndicator then
    --     hooksecurefunc("CompactUnitFrame_UpdatePvPClassificationIndicator", function(frame)
    --         if frame:IsForbidden() or not BBP.isInPvP or not UnitIsPlayer(frame.unit) or UnitPvpClassification(frame.unit) then return end
    --         if frame.classIndicator and frame.classIndicator.flagActive then
    --             BBP.ClassIndicator(frame)
    --         end
    --         if frame.bgIndicator and frame.bgIndicator.flagActive then
    --             BBP.BgIndicator(frame)
    --         end
    --     end)
    -- end
end

-- Event registration for PLAYER_LOGIN
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
--Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(...)
    local db = BetterBlizzPlatesDB

    if db.updates and db.updates ~= addonUpdates then
        -- if db.enableNameplateAuraCustomisation and db.classIndicator and db.classIndicatorFriendly and not db.classIndicatorUpdated then
        --     db.classIndicatorCCAuras = true
        --     if not db.friendlyNpdeBuffEnable then
        --         db.friendlyNpdeBuffEnable = true
        --         db.friendlyNpdeBuffFilterBlacklist = true
        --         db.friendlyNpdeBuffFilterWatchList = false
        --         db.friendlyNpdeBuffFilterCC = true
        --         db.friendlyNpdeBuffFilterBlizzard = false
        --         db.friendlyNpdeBuffFilterLessMinite = false
        --     else
        --         db.friendlyNpdeBuffFilterCC = true
        --     end

        --     db.classIndicatorUpdated = true
        -- end
    end

    --if db.updates and db.updates ~= addonUpdates then
        -- if db.enableNameplateAuraCustomisation and db.partyPointer and not db.partyPointerUpdated then
        --     if not db.friendlyNpdeBuffEnable then
        --         db.friendlyNpdeBuffEnable = true
        --         db.friendlyNpdeBuffFilterBlacklist = true
        --         db.friendlyNpdeBuffFilterWatchList = false
        --         db.friendlyNpdeBuffFilterCC = true
        --         db.friendlyNpdeBuffFilterBlizzard = false
        --         db.friendlyNpdeBuffFilterLessMinite = false
        --     else
        --         db.friendlyNpdeBuffFilterCC = true
        --     end
        --     db.partyPointerCCAuras = true
        --     db.partyPointerUpdated = true
        -- end
        if db.partyPointerUpdated and not db.partyPointerUpdated2 then
            db.partyPointerCCAuras = true
            db.partyPointerUpdated2 = true
        end
    --end

    CheckForUpdate()

    if not db.skipBugWarning then
        C_Timer.After(4, function()
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Bugs are expected in this very early release. Use at own risk for now. Please report bugs.")
        end)
    end

    _, playerClass = UnitClass("player")
    playerClassColor = RAID_CLASS_COLORS[playerClass]

    --BBP.ToggleSpellCastEventRegistration()
    BBP.PersonalBarSettings()

    if db.enableNameplateAuraCustomisation then
        --BBP.RunAuraModule()
        --BBP.SmokeCheckBootup()
        --BBP.SetUpAuraInterrupts()
        --BBP.UpdateImportantBuffsAndCCTables()
    end

    --if BetterBlizzPlatesDB.enableCastbarCustomization then
        --BBP.HookDefaultCompactNamePlateFrameAnchorInternal()
    --end

    --if BetterBlizzPlatesDB.nameplateResourceOnTarget then
        BBP.TargetResourceUpdater()
    --end

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
        BBP.InstantComboPoints()
        if not db.skipAdjustingFixedFonts then
            BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultLargeNamePlateFontFlags)
            BBP.SetFontBasedOnOption(SystemFont_NamePlate, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultNamePlateFontFlags)
            BBP.SetFontBasedOnOption(SystemFont_LargeNamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultLargeFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultLargeNamePlateFontFlags)
            BBP.SetFontBasedOnOption(SystemFont_NamePlateFixed, (db.customFontSizeEnabled and db.customFontSize) or db.defaultFontSize, (db.useCustomFont and db.enableCustomFontOutline) and db.customFontOutline or "OUTLINE, SLUG")--db.defaultNamePlateFontFlags)
        end
    end)

    BBP.HookHealthbarHeight()

    BBP.HookOverShields()
    HookNpFlagUpdates()

    BBP.ApplyNameplateWidth()

    C_Timer.After(1, function()
        if db.executeIndicatorScale <= 0 then --had a slider with borked values
            db.executeIndicatorScale = 1     --this will fix it for every user who made the error while bug was live
        end

        if db.changeResourceStrata then
            BBP.ChangeStrataOfResourceFrame()
        end
    end)

    SetCVarsOnLogin()

    if BetterBlizzPlatesDB.classIndicator and BetterBlizzPlatesDB.classIconHealthNumbers then
        BBP.SetupClassIndicatorHealthText()
    end

    -- Re-open options when clicking reload button
    if db.reopenOptions then
        --InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
        C_Timer.After(1, function()
            Settings.OpenToCategory(BBP.category:GetID())
        end)
        db.reopenOptions = false
    end
    --BBP.CreateUnitAuraEventFrame()

    -- Modify the hooksecurefunc based on instance status
    HideHealthbarInPvEMagic()
    BBP.HideNameplateAuraTooltip()
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
        C_Timer.After(1, function()
            if not InCombatLockdown() then
                BBP.DarkModeNameplateResources()
            end
        end)
        if not BBP.DarkModeSpec then
            local specChangeListener = CreateFrame("Frame")
            specChangeListener:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            specChangeListener:SetScript("OnEvent", function(self, event, ...)
                if event == "PLAYER_SPECIALIZATION_CHANGED" then
                    if BetterBlizzPlatesDB.darkModeNameplateResource then
                        local unitID = ...
                        if unitID == "player" then
                            local playerClass = select(2, UnitClass("player"))

                            if playerClass == "ROGUE" or playerClass == "MONK" then
                                BBP.DarkModeNameplateResources()
                            end
                        end
                    end
                end
            end)
            BBP.DarkModeSpec = true
        end
    end
end)

local function MoveableSettingsPanel()
    local frame = SettingsPanel
    if frame and not frame:GetScript("OnDragStart") and not C_AddOns.IsAddOnLoaded("BlizzMove") then
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    end
end

-- Slash command
SLASH_BBP1 = "/bbp"
SlashCmdList["BBP"] = function(msg)
    local command = string.lower(msg)
    if command == "news" then
        BBP.ToggleUpdateMessageWindow()
    elseif command == "reset" then
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    elseif command == "fixnameplates" then
        StaticPopup_Show("CONFIRM_FIX_NAMEPLATES_BBP")
    elseif command == "ver" or command == "version" then
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates "..BBP.VersionNumber)
    elseif command == "dump" then
        local exportVersion = BetterBlizzPlatesDB.exportVersion or "No export version registered"
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: "..exportVersion)
    elseif command == "profiles" then
        BBP.CreateIntroMessageWindow()
    elseif command == "resetcvars" then
        BBP.ResetNameplateCVars()
    elseif command == "uninstall" then
        BBP.ResetNameplateCVars()
        C_AddOns.DisableAddOn("BetterBlizzPlates")
        ReloadUI()
    elseif command == "swap" then

    elseif command == "snupylol" then
        local db = BetterBlizzPlatesDB
        db["classIndicatorFriendlyScale"] = 1.23
        db["classIndicatorAnchor"] = "TOP"
        db["classIndicatorEnemy"] = false
        db["classIndicatorYPos"] = 0
        db["classIndicatorHideRaidMarker"] = false
        db["classIndicatorFriendlyXPosXPos"] = 0
        db["classIndicatorFriendly"] = true
        db["classIndicatorScale"] = 1
        db["classIndicatorFrameStrataHigh"] = false
        db["classIndicatorHealer"] = true
        db["classIndicatorHighlight"] = true
        db["classIndicatorHideName"] = false
        db["classIndicatorSpecIcon"] = false
        db["classIndicatorFriendlyAnchor"] = "TOP"
        db["classIndicatorOnlyHealer"] = true
        db["classIndicatorXPos"] = 0
        db["classIndicatorFriendlyXPos"] = 0
        db["classIndicatorTank"] = false
        db["classIndicatorHighlightColor"] = true
        db["classIndicatorXPosXPos"] = 0
        db["classIndicatorFriendlyYPos"] = 0
        db["classIndicator"] = true
        db["classIndicatorFriendlyYPosYPos"] = 0
        db["classIndicatorAlpha"] = 1
        db["classIndicatorYPosYPos"] = 0
        db["classIconAlwaysShowBgObj"] = true
        db["classIconReactionBorder"] = false
        db["classIconArenaOnly"] = true
        db["classIconAlwaysShowTank"] = false
        db["classIconColorBorder"] = true
        db["classIconHealthNumbers"] = false
        db["classIconBgOnly"] = true
        db["classIconAlwaysShowHealer"] = false
        db["classIconSquareBorder"] = false
        db["classIconSquareBorderFriendly"] = false
        db["classIconHealerIconType"] = 2
        db["classIconEnemyHealIcon"] = true
        ReloadUI()
    elseif command == "oldfonts" then
        BBP.UseOldFonts()
    else
        BBP.LoadGUI()
        MoveableSettingsPanel()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CVAR_UPDATE")
frame:SetScript("OnEvent", function(self, event, cvarName)
    if BBP.CVarTrackingDisabled then return end
    if cvarName == "NamePlateHorizontalScale" then
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
    if cvarName == "uiScale" or cvarName == "useUiScale" then
        RunNextFrame(function()
            BBP.ApplyNameplateWidth()
        end)
    end
end)

local ShuffleNpWidthUpdate = CreateFrame("Frame")
ShuffleNpWidthUpdate.eventRegistered = false

local function UpdateNpWidthShuffle(self, event, ...)
    if event == "ARENA_OPPONENT_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
        if not BBP.isInArena then return end
        -- BBP.isMidnight
        local aura = nil--C_UnitAuras.GetPlayerAuraBySpellID(32727) -- Arena Preparation
        if not aura then return end

        if InCombatLockdown() then
            if not ShuffleNpWidthUpdate.eventRegistered then
                ShuffleNpWidthUpdate:RegisterEvent("PLAYER_REGEN_ENABLED")
                ShuffleNpWidthUpdate.eventRegistered = true
            end
        else
            BBP.ApplyNameplateWidth()
            BBP.RefreshAllNameplates()
            C_Timer.After(1, function()
                if not InCombatLockdown() then
                    BBP.ApplyNameplateWidth()
                    BBP.RefreshAllNameplates()
                end
            end)
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        ShuffleNpWidthUpdate:UnregisterEvent("PLAYER_REGEN_ENABLED")
        ShuffleNpWidthUpdate.eventRegistered = false
        BBP.ApplyNameplateWidth()
        BBP.RefreshAllNameplates()
    end
end
ShuffleNpWidthUpdate:SetScript("OnEvent", UpdateNpWidthShuffle)
ShuffleNpWidthUpdate:RegisterEvent("ARENA_OPPONENT_UPDATE")
ShuffleNpWidthUpdate:RegisterEvent("GROUP_ROSTER_UPDATE")

function BBP.TurnOnFocusBorderColor()
    if BBP.focusBorderColor then return end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_FOCUS_CHANGED")
    f:SetScript("OnEvent", function()
        local focusNp, frame = BBP.GetSafeNameplate("focus")
        if BBP.previousFocusNameplate2 then
            ColorNameplateBorder(BBP.previousFocusNameplate2.HealthBarsContainer.border, BBP.previousFocusNameplate2)
            BBP.previousFocusNameplate2 = nil
        end
        if frame and frame.HealthBarsContainer.border then
            ColorNameplateBorder(frame.HealthBarsContainer.border, frame)
            BBP.previousFocusNameplate2 = frame
        end
    end)
    BBP.focusBorderColor = true
end

local function TurnOnEnabledFeaturesOnLogin()
    local db = BetterBlizzPlatesDB
    if db.raidmarkIndicator then
        BBP.ChangeRaidmarker()
    end

    if db.changeNameplateBorderColor and db.npBorderTargetColor then
        BBP.TurnOnFocusBorderColor()
    end

    --BBP.ToggleSpellCastEventRegistration()
    BBP.ApplyNameplateWidth()
    BBP.ToggleFriendlyNameplatesAuto()
    BBP.ToggleAbsorbIndicator()
    BBP.ToggleCombatIndicator()
    BBP.ToggleExecuteIndicator()
    BBP:RegisterTargetCastingEvents()
    BBP.ToggleHealthNumbers()
    --BBP.DruidBlueComboPoints() isMidnight
    BBP.DruidAlwaysShowCombos()
    EnableMouseoverChecker()
end


local function UpdateLateAdditionSettings(db)
    if (db.friendlyNameplatesOnlyInDungeons or db.friendlyNameplatesOnlyInBgs) and not db.friendlyNameplateTogglesUpdated then
        if db.friendlyNameplatesOnlyInDungeons and db.friendlyNameplatesOnlyInRaids == nil then
            db.friendlyNameplatesOnlyInRaids = true
        end
        if db.friendlyNameplatesOnlyInBgs and db.friendlyNameplatesOnlyInEpicBgs == nil then
            db.friendlyNameplatesOnlyInEpicBgs = true
        end
        db.friendlyNameplateTogglesUpdated = true
    end

    if db.classIndicator and db.classIconAlwaysShowHealer == nil then
        db.classIconAlwaysShowHealer = false
        db.classIconAlwaysShowTank = false

        if db.classIndicatorTank == nil then
            db.classIndicatorTank = false
        end
        if db.classIndicatorHealer == nil then
            db.classIndicatorHealer = false
        end
    end

    --bodifycheck
    if db.updates and db.updates ~= addonUpdates then
        -- if db.enableNameplateAuraCustomisation and db.classIndicator and db.classIndicatorFriendly and not db.classIndicatorUpdated then
        --     db.classIndicatorCCAuras = true
        --     if not db.friendlyNpdeBuffEnable then
        --         db.friendlyNpdeBuffEnable = true
        --         db.friendlyNpdeBuffFilterBlacklist = true
        --         db.friendlyNpdeBuffFilterWatchList = false
        --         db.friendlyNpdeBuffFilterCC = true
        --         db.friendlyNpdeBuffFilterBlizzard = false
        --         db.friendlyNpdeBuffFilterLessMinite = false
        --     else
        --         db.friendlyNpdeBuffFilterCC = true
        --     end

        --     db.classIndicatorUpdated = true
        -- end
    end

    --if db.updates and db.updates ~= addonUpdates then
        -- if db.enableNameplateAuraCustomisation and db.partyPointer and not db.partyPointerUpdated then
        --     if not db.friendlyNpdeBuffEnable then
        --         db.friendlyNpdeBuffEnable = true
        --         db.friendlyNpdeBuffFilterBlacklist = true
        --         db.friendlyNpdeBuffFilterWatchList = false
        --         db.friendlyNpdeBuffFilterCC = true
        --         db.friendlyNpdeBuffFilterBlizzard = false
        --         db.friendlyNpdeBuffFilterLessMinite = false
        --     else
        --         db.friendlyNpdeBuffFilterCC = true
        --     end
        --     db.partyPointerCCAuras = true
        --     db.partyPointerUpdated = true
        -- end
        if db.partyPointerUpdated and not db.partyPointerUpdated2 then
            db.partyPointerCCAuras = true
            db.partyPointerUpdated2 = true
        end
    --end

    if db.firstSaveComplete and not db.classIndicatorUpdated2 then
        db.classIndicatorBackground = false
        db.classIndicatorHideFriendlyHealthbar = false

        if db.classIndicatorPinMode then
            db.classIndicatorBackground = true
            db.classIndicatorBackgroundSize = 1
        end

        db.classIndicatorUpdated2 = true
    end
end

function BBP.HidePersonalManabarFX()
    if BetterBlizzPlatesDB.hidePersonalManaFX then
        if ClassNameplateManaBarFrame then
            ClassNameplateManaBarFrame.FullPowerFrame:SetParent(BBP.hiddenFrame)
            ClassNameplateManaBarFrame.FeedbackFrame:SetParent(BBP.hiddenFrame)
        end
    end
end

function BBP.UseOldFonts()
    local db = BetterBlizzPlatesDB
    if not db.old_defaultLargeNamePlateFont then return end
    db.defaultLargeNamePlateFont = db.old_defaultLargeNamePlateFont
    db.defaultLargeFontSize = db.old_defaultLargeFontSize
    db.defaultLargeNamePlateFontFlags = db.old_defaultLargeNamePlateFontFlags
    db.defaultNamePlateFont = db.old_defaultNamePlateFont
    db.defaultFontSize = db.old_defaultFontSize
    db.defaultNamePlateFontFlags = db.old_defaultNamePlateFontFlags
    db.skipFontCollect = true
    ReloadUI()
end

-- Event registration for PLAYER_LOGIN
local First = CreateFrame("Frame")
First:RegisterEvent("ADDON_LOADED")
First:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName then
        if addonName == "BetterBlizzPlates" then
            local db = BetterBlizzPlatesDB
            TurnOffTestModes()
            db.castbarEventsOn = false
            db.wasOnLoadingScreen = true

            if db.nameplateShowFriendlyGuardians and db.nameplateShowFriendlyPlayerGuardians == nil then
                db.nameplateShowFriendlyPlayerGuardians = db.nameplateShowFriendlyGuardians
            end
            if db.nameplateShowFriendlyMinions and db.nameplateShowFriendlyPlayerMinions == nil then
                db.nameplateShowFriendlyPlayerMinions = db.nameplateShowFriendlyMinions
            end
            if db.nameplateShowFriendlyPets and db.nameplateShowFriendlyPlayerPets == nil then
                db.nameplateShowFriendlyPlayerPets = db.nameplateShowFriendlyPets
            end
            if db.nameplateShowFriendlyTotems and db.nameplateShowFriendlyPlayerTotems == nil then
                db.nameplateShowFriendlyPlayerTotems = db.nameplateShowFriendlyTotems
            end

            C_Timer.After(3, function()
                BBP.CVarTracker()
                db.hasSaved = true -- Ended up with a config without this tag, idk how. Put this here just in case.
            end)

            -- Midnight update
            if db.ShowClassColorInFriendlyNameplate then
                db.nameplateShowFriendlyClassColor = db.ShowClassColorInFriendlyNameplate
                db.ShowClassColorInFriendlyNameplate = nil
            end
            if db.ShowClassColorInNameplate then
                db.nameplateShowClassColor = db.ShowClassColorInNameplate
                db.ShowClassColorInNameplate = nil
            end
            if db.nameplateResourceOnTarget then
                if db.nameplateResourceOnTarget == 1 or db.nameplateResourceOnTarget == "1" or db.nameplateResourceOnTarget == true then
                    db.nameplateResourceOnTarget = true
                else
                    db.nameplateResourceOnTarget = nil
                end
            end

            UpdateLateAdditionSettings(db)

            InitializeSavedVariables()
            -- Fetch Blizzard default values
            if not db.firstSaveComplete then
                db.defaultLargeNamePlateFont, db.defaultLargeFontSize, db.defaultLargeNamePlateFontFlags = SystemFont_LargeNamePlate:GetFont()
                db.defaultNamePlateFont, db.defaultFontSize, db.defaultNamePlateFontFlags = SystemFont_NamePlate:GetFont()
                FetchAndSaveValuesOnFirstLogin()

                db.firstSaveComplete = true
            else
                BBP.CVarAdditionFetcher()
            end
            if not BetterBlizzPlatesDB.nameplateGeneralHpHeight then
                BetterBlizzPlatesDB.nameplateGeneralHpHeight = ((BetterBlizzPlatesDB.NamePlateVerticalScale or 2.7) * 4) + 5.5
            end

            if not db.old_defaultLargeNamePlateFont then
                db.old_defaultLargeNamePlateFont = db.defaultLargeNamePlateFont
                db.old_defaultLargeFontSize = db.defaultLargeFontSize
                db.old_defaultLargeNamePlateFontFlags = db.defaultLargeNamePlateFontFlags
                db.old_defaultNamePlateFont = db.defaultNamePlateFont
                db.old_defaultFontSize = db.defaultFontSize
                db.old_defaultNamePlateFontFlags = db.defaultNamePlateFontFlags
            end
            if not db.skipFontCollect then
                db.defaultLargeNamePlateFont, db.defaultLargeFontSize, db.defaultLargeNamePlateFontFlags = SystemFont_LargeNamePlate:GetFont()
                db.defaultNamePlateFont, db.defaultFontSize, db.defaultNamePlateFontFlags = SystemFont_NamePlate:GetFont()
            end

            BBP.HidePersonalManabarFX()

            if not db.cleanedScaleScale then
                for key, _ in pairs(BetterBlizzPlatesDB) do
                    if string.match(key, "ScaleScale$") then
                        BetterBlizzPlatesDB[key] = nil
                    end
                end
                db.cleanedScaleScale = true
            end

            if not db.fixedFriendlyHealthbarHide then
                if not db.friendlyHideHealthBar then
                    db.friendlyHideHealthBarNpc = nil
                end
                db.fixedFriendlyHealthbarHide = true
            end

            if db.castBarIconXPos and not db.castBarIconPosReset then
                db.castBarIconXPos = 0
                db.castBarIconYPos = 0
                db.castBarIconPosReset = true
            end

            if not db.nameplateResourcePositionFix then
                if db.nameplateResourceYPos == 4 then
                    db.nameplateResourceYPos = 0
                end
                db.nameplateResourcePositionFix = true
            end

            if db.nameplateMinScale and db.nameplateMaxScale then
                -- Check if the two values are not the same
                if db.nameplateMinScale ~= db.nameplateMaxScale and not BetterBlizzPlatesDB.disableCVarForceOnLogin then
                    -- Calculate the average of the two values to balance them
                    local average = (db.nameplateMinScale + db.nameplateMaxScale) / 2

                    -- Set both values to the average to make them equal
                    db.nameplateMinScale = average
                    db.nameplateMaxScale = average

                    -- Update the CVar settings to reflect the change
                    C_CVar.SetCVar("nameplateMinScale", average)
                    C_CVar.SetCVar("nameplateMaxScale", average)
                end
            end

            TurnOnEnabledFeaturesOnLogin()
            if db.enableMidnightNameplateTweaks then
                BBP.NameplateAuraTweaksTemp()
            end
            BBP.HideResourceFrames()
            BBP.InitializeOptions()
        end
    end
end)

local function OnVariablesLoaded(self, event)
    if event == "VARIABLES_LOADED" then
        if not BetterBlizzPlatesDB.nameplateShowFriendlyNPCs then
            BetterBlizzPlatesDB.nameplateShowFriendlyNPCs = GetCVar("nameplateShowFriendlyNPCs")
            BetterBlizzPlatesDB.nameplateShowAll = GetCVar("nameplateShowAll")
        end
        if not BetterBlizzPlatesDB.nameplateSelfAlpha then
            BetterBlizzPlatesDB.nameplateSelfAlpha = GetCVar("nameplateSelfAlpha")
        end
        BBP.variablesLoaded = true
    end
end

-- Register the frame to listen for the "VARIABLES_LOADED" event
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:SetScript("OnEvent", OnVariablesLoaded)




--#########################################
-- Nameplate castbar test mode, a fiesta mess... another one for the refactor
local nameplates = {}
local timers = {}
local temporaryNpCastTest = CreateFrame("Frame")

local function NamePlateCastBarTestMode(frame)
    local castBar = frame.castBar
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
                if frame.castBarIconFrame then
                    frame.castBarIconFrame:SetScale(BetterBlizzPlatesDB.castBarIconScale or 1.0)
                end
                castBar.BorderShield:SetScale(borderShieldSize)

                if not BetterBlizzPlatesDB.useCustomCastbarBGTexture or not BetterBlizzPlatesDB.useCustomCastbarTexture then
                    frame.castBar.Background:SetDesaturated(false)
                    frame.castBar.Background:SetVertexColor(1,1,1,1)
                    frame.castBar.Background:SetAtlas("UI-CastingBar-Background")
                else
                    local bgTextureName = BetterBlizzPlatesDB.customCastbarBGTexture
                    local bgTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, bgTextureName)
                    local changeBgTexture = BetterBlizzPlatesDB.useCustomCastbarBGTexture
                    if changeBgTexture then
                        local bgColor = BetterBlizzPlatesDB.castBarBackgroundColor
                        frame.castBar.Background:SetDesaturated(true)
                        frame.castBar.Background:SetTexture(bgTexture)
                        frame.castBar.Background:SetAllPoints(frame.castBar)
                        frame.castBar.Background:SetVertexColor(unpack(bgColor))
                    end
                end

                if castBarTimer then
                    if not frame.dummyTimer then
                        frame.dummyTimer = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        frame.dummyTimer:SetPoint("LEFT", frame.castBar, "RIGHT", 5, 0)
                        frame.dummyTimer:SetTextColor(1, 1, 1)
                        frame.dummyTimer:SetText("1.5")
                    end
                    BBP.SetFontBasedOnOption(frame.dummyTimer, BetterBlizzPlatesDB.npTargetTextSize or 12, "OUTLINE")
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
                            frame.dummyNameText:ClearAllPoints()
                            if UnitCanAttack("player", frame.unit) then
                                frame.dummyNameText:SetPoint("TOPRIGHT", frame.castBar, "BOTTOMRIGHT", -4, 0)  -- Set anchor point for enemy
                            else
                                frame.dummyNameText:SetPoint("TOP", frame.castBar, "BOTTOM", 0, 0)  -- Set anchor point for friendly
                            end
                        else -- Fallback color in case something goes wrong
                            frame.dummyNameText:SetTextColor(1, 1, 1) -- Set to white or any default color
                        end
                    end

                    local useCustomFont = BetterBlizzPlatesDB.useCustomFont
                    BBP.SetFontBasedOnOption(frame.dummyNameText, (useCustomFont and BetterBlizzPlatesDB.npTargetTextSize or 11) or (BetterBlizzPlatesDB.npTargetTextSize or 12))
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
                        castBar.BorderShield:Hide()
                        if useCustomCastbarTexture then
                            castBar:SetStatusBarTexture(texturePath)
                        else
                            castBar:SetStatusBarTexture("ui-castingbar-filling-standard")
                            local castBarTexture = castBar:GetStatusBarTexture()
                            castBarTexture:SetDesaturated(false)
                            castBar:SetStatusBarColor(1,1,1,1)
                        end
                        castBar.Text:SetText("Frostbolt")
                        castBar.Icon:Show()
                        castBar.Icon:SetTexture(C_Spell.GetSpellTexture(116))
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
                            castBar.BorderShield:Show()
                            if useCustomCastbarTexture then
                                castBar:SetStatusBarTexture(nonInterruptibleTexturePath)
                            else
                                castBar:SetStatusBarTexture("ui-castingbar-uninterruptable")
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(false)
                                castBar:SetStatusBarColor(1,1,1,1)
                            end
                            castBar.Text:SetText("Shattering Throw")
                            if showCastBarIconWhenNoninterruptible then
                                castBar.Icon:SetTexture(C_Spell.GetSpellTexture(64382))
                                castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
                                castBar.Icon:SetDrawLayer("OVERLAY", 2)
                            else
                                castBar.Icon:Hide()
                            end
                            if useCustomCastbarTexture or castBarRecolor then
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(true)
                                castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
                            end
                        elseif castType == "channeled" then
                            castBar.BorderShield:Hide()
                            if useCustomCastbarTexture then
                                castBar:SetStatusBarTexture(texturePath)
                            else
                                castBar:SetStatusBarTexture("ui-castingbar-filling-channel")
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(false)
                                castBar:SetStatusBarColor(1,1,1,1)
                            end
                            castBar.Text:SetText("Soothing Mist")
                            castBar.Icon:Show()
                            castBar.Icon:SetTexture(C_Spell.GetSpellTexture(115175))
                            if useCustomCastbarTexture or castBarRecolor then
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(true)
                                castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                            end
                        else
                            castBar.BorderShield:Hide()
                            if useCustomCastbarTexture then
                                castBar:SetStatusBarTexture(texturePath)
                            else
                                castBar:SetStatusBarTexture("ui-castingbar-filling-standard")
                                local castBarTexture = castBar:GetStatusBarTexture()
                                castBarTexture:SetDesaturated(false)
                                castBar:SetStatusBarColor(1,1,1,1)
                            end
                            castBar.Text:SetText("Frostbolt")
                            castBar.Icon:Show()
                            castBar.Icon:SetTexture(C_Spell.GetSpellTexture(116))
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
            local castBar = frame.castBar
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
    BBP.UpdateMessageWindow:SetSize(450,425)
    BBP.UpdateMessageWindow.Bg:SetDesaturated(true)
    BBP.UpdateMessageWindow.Bg:SetVertexColor(0.5,0.5,0.5, 0.98)
    local screenHeight = UIParent:GetHeight() -- Get the screen height
    local yOffset = screenHeight * -0.2-- Calculate 20% from the top. Negative because we're moving up.
    BBP.UpdateMessageWindow:ClearAllPoints() -- Clear any existing points
    BBP.UpdateMessageWindow:SetPoint("TOP", UIParent, "TOP", 0, yOffset)
    BBP.UpdateMessageWindow:SetMovable(true)
    BBP.UpdateMessageWindow:EnableMouse(true)
    BBP.UpdateMessageWindow:RegisterForDrag("LeftButton")
    BBP.UpdateMessageWindow:Show()
    BBP.UpdateMessageWindow:SetScript("OnDragStart", BBP.UpdateMessageWindow.StartMoving)
    BBP.UpdateMessageWindow:SetScript("OnDragStop", BBP.UpdateMessageWindow.StopMovingOrSizing)
    BBP.UpdateMessageWindow:SetPortraitToAsset(135724)
    BBP.UpdateMessageWindow:SetTitle("Better|cff00c0ffBlizz|rPlates " .. BBP.VersionNumber)
    BBP.UpdateMessageWindow:SetFrameLevel(0)
    BBP.UpdateMessageWindow:SetFrameStrata("HIGH")
    local testTitle = BBP.UpdateMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
    testTitle:SetText("Better|cff00c0ffBlizz|rPlates " ..BBP.VersionNumber.. " Update!")
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
    scrollingMessageFrame:AddMessage("QuestLegendary", "Important changes:", nil, 5, -3, 3, "GameFontNormalMed2", 16)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Pet Indicator & Hide NPC can now accurately identify main hunter & warlock pets in Arena.\n\nThere's two new settings:\n1) Hide Secondary Pets\n2) Murloc Secondary Pets.\n\nThe murloc setting will replace the nameplates of secondary pets with a tiny murloc icon. By default this murloc setting will be enabled for both Pet Indicator and Hide NPC.", "", 11)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "You can now adjust Personal Resource Display Aura size separately and chose to disable enlarge/compact/glow on it. You may need to re-adjust the personal settings to your liking.", "(Nameplate Auras)", 11)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Bugfix: Friendly nameplate auras were showing too high in combination with the friendly NP setting \"Non-Stackable\". ", "(Nameplate Auras)", 11)
    scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Please check out the full list of updates in the CurseForge changelog.", "", 14)

    -- -- Adding messages
    -- scrollingMessageFrame:AddMessage("QuestNormal", "New Stuff:", nil, 5, -3, 3, "GameFontNormalMed2", 16)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Sort Enlarged & Compacted Auras (reversed ver)", "(Nameplate Auras)", 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Castbar Edge Highlighter now uses seconds instead of percentages", "(Castbar)", 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Party pointer healer icon replace setting", "(Advanced Settings)", 14)

    -- scrollingMessageFrame:AddMessage("Professions-Crafting-Orders-Icon", "Bugfixes and Tweaks:", nil, 5, -4, 2, "GameFontNormalMed2", 16)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fixed some npc casts not triggering castbar customization", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Totem indicator icon now moves on top of np resource (if enabled) when targeting a totem", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fixed Friendly NP color player/npc toggle resetting on reload", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fix personal Nameplate Aura filtering issues", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Fixed a Blizzard bug:\nIf Nameplate Resource CVar is on then nameplate auras get pushed up 18 pixels by default but this used to happen even on specs that don't have a nameplate resource. This is fixed now.", nil, 14)

    -- scrollingMessageFrame:AddMessage("GarrisonTroops-Health", "Note from Developer:", nil, 5, 3, 0, "GameFontNormalMed2", 12)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "Thank you for all the love. Thanks to all users and especially beta testers and Patreon supporters.\nVery motivating thank you!<3", nil, 2)
    -- scrollingMessageFrame:AddMessage("Professions-Icon-Quality-Tier5-Inv", "If you run into any bugs please report them!", nil, 2)


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
    if not hookedHpHeight then
        hooksecurefunc(NamePlateUnitFrameMixin, "UpdateAnchors", function(frame)
            AdjustHealthBarHeight(frame)
        end)

        hookedHpHeight = true
    end
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

-- config

function BBP.NameplateAuraTweaksTemp()
    local function OnAuraFrameRefreshed(auraFrame, isDebuffList)
        local db = BetterBlizzPlatesDB
        local pixelBorder = db.nameplateAuraPixelBorder
        local rectangleAuras = db.nameplateAuraRectangleSize
        local hideCooldownTimer = db.nameplateAuraHideCooldownNumbers
        local WIDTH = 20
        local HEIGHT = (not rectangleAuras) and 20 or 14

        if auraFrame and auraFrame:IsShown() then
            auraFrame:SetMouseClickEnabled(false)
            if isDebuffList then
                if hideCooldownTimer then
                    auraFrame.Cooldown:SetHideCountdownNumbers(true)
                    auraFrame.cdHidden = true
                elseif auraFrame.cdHidden then
                    auraFrame.Cooldown:SetHideCountdownNumbers(false)
                end
                auraFrame:SetSize(WIDTH, HEIGHT)
                auraFrame.bbpResized = true
            else
                if auraFrame.cdHidden then
                    auraFrame.Cooldown:SetHideCountdownNumbers(false)
                    auraFrame.cdHidden = nil
                end
                -- Reset to default size for non-debuff frames
                --if auraFrame.bbpResized then
                auraFrame:SetSize(22, 22)
                auraFrame.bbpResized = nil
                --end
            end

            if pixelBorder then
                BBP.SetupBorderOnFrame(auraFrame)
                auraFrame.Cooldown:SetSwipeTexture(1)
            end

            if auraFrame.Cooldown then
                local r1 = auraFrame.Cooldown:GetRegions()
                if r1 and r1.GetObjectType and r1:GetObjectType() == "FontString" then
                    r1:SetScale(0.65)
                end
            end

            if isDebuffList and rectangleAuras then
                auraFrame.Icon:SetTexCoord(0.05, 0.95, 0.10, 0.60)
            else
                if pixelBorder then
                    auraFrame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                else
                    auraFrame.Icon:SetTexCoord(0.02, 0.98, 0.02, 0.98)
                end
            end

            for i = 1, auraFrame:GetNumRegions() do
                local region = select(i, auraFrame:GetRegions())
                if region then
                    if region:GetObjectType() == "Texture" and region:GetAtlas() == "UI-HUD-CoolDownManager-IconOverlay" then
                        if pixelBorder then
                            region:Hide()
                        else
                            if rectangleAuras then
                                region:Show()
                                region:ClearAllPoints()
                                region:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -4, 2.5)
                                region:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 3.5, -2.5)
                            else
                                region:Show()
                                region:ClearAllPoints()
                                region:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -3.5, 3.5)
                                region:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 3.5, -3.5)
                            end
                        end
                    elseif region:GetObjectType() == "MaskTexture" then
                        if pixelBorder then
                            region:Hide()
                        else
                            region:Show()
                        end
                    end
                end
            end
        end
    end

    local function LayoutAurasSequential(self, listFrame)
        local parent = listFrame:GetParent() and listFrame:GetParent():GetParent()
        if not parent then return end

        local db = BetterBlizzPlatesDB
        local rightToLeft = db.nameplateAuraRightToLeft
        local centerAuras = db.nameplateAurasEnemyCenteredAnchor
        local debuffPad = C_CVar.GetCVar("nameplateDebuffPadding")
        local WIDTH = 20
        local GAP = db.nameplateAuraWidthGap or 4
        local widthAndGap = WIDTH + GAP

        -- Count total visible auras
        local totalAuras = 0
        if centerAuras then
            for af in self.auraItemFramePool:EnumerateActive() do
                if af:IsShown() then
                    totalAuras = totalAuras + 1
                end
            end
        end

        -- Calculate total width including gaps and center offset
        local centerOffset = 0
        if centerAuras and totalAuras > 0 then
            local totalWidth = (totalAuras * WIDTH) + ((totalAuras - 1) * GAP)
            centerOffset = totalWidth / 2
        end

        local idx = 0
        for auraFrame in self.auraItemFramePool:EnumerateActive() do
            if auraFrame:IsShown() then
                auraFrame:ClearAllPoints()
                if centerAuras then
                    local xOffset = -centerOffset + (WIDTH / 2) + (idx * widthAndGap)
                    auraFrame:SetPoint("BOTTOM", parent.healthBar, "TOP", xOffset, debuffPad)
                elseif rightToLeft then
                    if idx == 0 then
                        auraFrame:SetPoint("BOTTOMRIGHT", parent.healthBar, "TOPRIGHT", 0, debuffPad)
                    else
                        auraFrame:SetPoint("BOTTOMRIGHT", parent.healthBar, "TOPRIGHT", -(idx * widthAndGap), debuffPad)
                    end
                else
                    if idx == 0 then
                        auraFrame:SetPoint("BOTTOMLEFT", parent.healthBar, "TOPLEFT", 0, debuffPad)
                    else
                        auraFrame:SetPoint("BOTTOMLEFT", parent.healthBar, "TOPLEFT", idx * widthAndGap, debuffPad)
                    end
                end
                idx = idx + 1
            end
        end
    end

    hooksecurefunc(NamePlateAurasMixin, "RefreshList", function(self, listFrame, auraList)
        if self:IsForbidden() then return end

        local isDebuffList = (listFrame == self.DebuffListFrame)

        -- Only process frames that belong to the current list being refreshed
        for auraItemFrame in self.auraItemFramePool:EnumerateActive() do
            if auraItemFrame:GetParent() == listFrame then
                OnAuraFrameRefreshed(auraItemFrame, isDebuffList)
            end
        end

        -- Only apply custom layout to debuff frames
        if isDebuffList then
            LayoutAurasSequential(self, listFrame)
        end
    end)


    -- CVAR listener + global relayout for nameplate auras
    local TRACKED = {
        nameplateDebuffPadding = true,
        nameplateStyle = true,
        nameplateAuraScale = true,
    }

    local function UpdateOneNameplate(plate)
        if not plate or not plate.UnitFrame then return end
        local uf = plate.UnitFrame
        if plate.UnitFrame:IsForbidden() then return end
        local auras = uf.AurasFrame
        local listFrame = auras.DebuffListFrame

        -- Re-run your refresh on active aura item frames, then re-layout
        if auras.auraItemFramePool then
            for auraFrame in auras.auraItemFramePool:EnumerateActive() do
                OnAuraFrameRefreshed(auraFrame, auraFrame:GetParent() == listFrame)
            end
            LayoutAurasSequential(auras, listFrame)
        end
    end

    local function UpdateAllNameplatesAuras()
        -- false = only shown plates
        for _, plate in ipairs(C_NamePlate.GetNamePlates(false)) do
            UpdateOneNameplate(plate)
        end
    end

    local evt = CreateFrame("Frame")
    evt:RegisterEvent("CVAR_UPDATE")

    evt:SetScript("OnEvent", function(_, event, cvarName)
        if TRACKED[cvarName] then
            UpdateAllNameplatesAuras()
        end
    end)

    -- hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    --     if unit ~= "preview" then return end
    --     local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    --     UpdateOneNameplate(nameplate)
    -- end)
end





local NameplatePostCombatUpdater = CreateFrame("Frame")
local needsNameplateUpdate = false
local function ApplyNameplateUpdates()
    needsNameplateUpdate = false
    if NameplatePostCombatUpdater:IsEventRegistered("PLAYER_REGEN_ENABLED") then
        NameplatePostCombatUpdater:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
    BBP.ApplyNameplateWidth()
    BBP.RefreshAllNameplates()
end

NameplatePostCombatUpdater:SetScript("OnEvent", ApplyNameplateUpdates)

hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", function()
    if InCombatLockdown() then
        if not needsNameplateUpdate then
            needsNameplateUpdate = true
            if not NameplatePostCombatUpdater:IsEventRegistered("PLAYER_REGEN_ENABLED") then
                NameplatePostCombatUpdater:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
        end
        return
    end
    C_Timer.After(0, function()
        ApplyNameplateUpdates()
    end)
end)

hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateSize", function(self, namePlateStyle, namePlateScale)
    if InCombatLockdown() then
        if not needsNameplateUpdate then
            needsNameplateUpdate = true
            if not NameplatePostCombatUpdater:IsEventRegistered("PLAYER_REGEN_ENABLED") then
                NameplatePostCombatUpdater:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
        end
        return
    end
    C_Timer.After(0, function()
        ApplyNameplateUpdates()
    end)
end)
