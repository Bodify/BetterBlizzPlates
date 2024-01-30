-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- My first addon, a lot could be done better but its a start for now
-- Things are getting more messy need a lot of cleaning lol

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("statusbar", "Dragonflight (BBP)", [[Interface\Addons\BetterBlizzPlates\media\DragonflightTexture]])
LSM:Register("statusbar", "Shattered DF (BBP)", [[Interface\Addons\BetterBlizzPlates\media\focusTexture]])
LSM:Register("font", "Yanone (BBP)", [[Interface\Addons\BetterBlizzPlates\media\YanoneKaffeesatz-Medium.ttf]])

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = "1.3.9"
local sendUpdate = true
BBP.VersionNumber = addonUpdates
local _, playerClass
local playerClassColor

BBP.variablesLoaded = false

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
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
    colorNPC = false,
    colorNPCName = false,
    raidmarkIndicator = false,
    raidmarkIndicatorScale = 1,
    raidmarkIndicatorAnchor = "TOP",
    raidmarkIndicatorXPos = 0,
    raidmarkIndicatorYPos = 0,
    customTexture = "Dragonflight (BBP)",
    customTextureFriendly = "Dragonflight (BBP)",
    customFont = "Yanone (BBP)",
    friendlyHideHealthBarNpc = true,
    nameplateResourceScale = 0.7,
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
    classIndicatorEnemy = true,
    classIndicatorFriendly = true,
    classIconColorBorder = true,

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
    totemIndicatorNpcList = {
        [59764] =   { name = "Healing Tide Totem", icon = GetSpellTexture(108280),              hideIcon = false, size = 30, duration = 10, color = {0, 1, 0.39}, important = true },
        [5925] =    { name = "Grounding Totem", icon = GetSpellTexture(204336),                 hideIcon = false, size = 30, duration = 3,  color = {1, 0, 1}, important = true },
        [53006] =   { name = "Spirit Link Totem", icon = GetSpellTexture(98008),                hideIcon = false, size = 30, duration = 6,  color = {0, 1, 0.78}, important = true },
        [5913] =    { name = "Tremor Totem", icon = GetSpellTexture(8143),                      hideIcon = false, size = 30, duration = 13, color = {0.49, 0.9, 0.08}, important = true },
        [104818] =  { name = "Ancestral Protection Totem", icon = GetSpellTexture(207399),      hideIcon = false, size = 30, duration = 33, color = {0, 1, 0.78}, important = true },
        [119052] =  { name = "War Banner", icon = GetSpellTexture(236320),                      hideIcon = false, size = 30, duration = 15, color = {1, 0, 1}, important = true },
        [61245] =   { name = "Capacitor Totem", icon = GetSpellTexture(192058),                 hideIcon = false, size = 30, duration = 2,  color = {1, 0.69, 0}, important = true },
        [105451] =  { name = "Counterstrike Totem", icon = GetSpellTexture(204331),             hideIcon = false, size = 30, duration = 15, color = {1, 0.27, 0.59}, important = true },
        [179193] =  { name = "Fel Obelisk", icon = GetSpellTexture(353601),                     hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
        [101398] =  { name = "Psyfiend", icon = GetSpellTexture(199824),                        hideIcon = false, size = 35, duration = 12, color = {0.49, 0, 1}, important = true },
        [100943] =  { name = "Earthen Wall Totem", icon = GetSpellTexture(198838),              hideIcon = false, size = 30, duration = 18, color = {0.78, 0.49, 0.35}, important = true },
        [107100] =  { name = "Observer", icon = GetSpellTexture(112869),                        hideIcon = false, size = 30, duration = 20, color = {1, 0.69, 0}, important = true },
        [135002] =  { name = "Tyrant", icon = GetSpellTexture(265187),                          hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
        [114565] =  { name = "Guardian of the Forgotten Queen", icon = GetSpellTexture(228049), hideIcon = false, size = 30, duration = 10, color = {1, 0, 1}, important = true },
        [107024] =  { name = "Fel Lord", icon = GetSpellTexture(212459),                        hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
        -- Less important
        [89] =      { name = "Infernal", icon = GetSpellTexture(1122),                          hideIcon = false, size = 24, duration = 30, color = {1, 0.69, 0}, important = false },
        [196111] =  { name = "Pit Lord", icon = GetSpellTexture(138789),                        hideIcon = false, size = 24, duration = 10, color = {1, 0.69, 0}, important = false },
        [3527] =    { name = "Healing Stream Totem", icon = GetSpellTexture(5394),              hideIcon = false, size = 24, duration = 18, color = {0, 1, 0.78}, important = false },
        [78001] =   { name = "Cloudburst Totem", icon = GetSpellTexture(157153),                hideIcon = false, size = 24, duration = 15, color = {0, 1, 0.39}, important = false },
        [10467] =   { name = "Mana Tide Totem", icon = GetSpellTexture(16191),                  hideIcon = false, size = 24, duration = 8,  color = {0.08, 0.82, 0.78}, important = false },
        [97285] =   { name = "Wind Rush Totem", icon = GetSpellTexture(192077),                 hideIcon = false, size = 24, duration = 18, color = {0.08, 0.82, 0.78}, important = false },
        [60561] =   { name = "Earthgrab Totem", icon = GetSpellTexture(51485),                  hideIcon = false, size = 24, duration = 30, color = {0.75, 0.31, 0.10}, important = false },
        [2630] =    { name = "Earthbind Totem", icon = GetSpellTexture(2484),                   hideIcon = false, size = 24, duration = 30, color = {0.78, 0.51, 0.39}, important = false },
        [105427] =  { name = "Skyfury Totem", icon = GetSpellTexture(204330),                   hideIcon = false, size = 24, duration = 15, color = {1, 0.27, 0.59}, important = false },
        [97369] =   { name = "Liquid Magma Totem", icon = GetSpellTexture(192222),              hideIcon = false, size = 24, duration = 6,  color = {1, 0.69, 0}, important = false },
        [6112] =    { name = "Windfury Totem", icon = GetSpellTexture(8512),                    hideIcon = false, size = 24, duration = nil,color = {0.08, 0.82, 0.78}, important = false },
        [62982] =   { name = "Mindbender", icon = GetSpellTexture(123040),                      hideIcon = false, size = 24, duration = 15, color = {1, 0.69, 0}, important = false },
        [179867] =  { name = "Static Field Totem", icon = GetSpellTexture(355580),              hideIcon = false, size = 24, duration = 6,  color = {0, 1, 0.78}, important = false },
        [194117] =  { name = "Stoneskin Totem", icon = GetSpellTexture(383017),                 hideIcon = false, size = 24, duration = 15, color = {0.78, 0.49, 0.35}, important = false },
        [5923] =    { name = "Poison Cleansing Totem", icon = GetSpellTexture(383013),          hideIcon = false, size = 24, duration = 9,  color = {0.49, 0.9, 0.08}, important = false },
        [194118] =  { name = "Tranquil Air Totem", icon = GetSpellTexture(383019),              hideIcon = false, size = 24, duration = 20, color = {0, 1, 0.78}, important = false },
    },
    -- Quest Indicator
    questIndicator = false,
    questIndicatorScale = 1,
    questIndicatorXPos = 0,
    questIndicatorYPos = 0,
    questIndicatorAnchor = "LEFT",
    questIndicatorTestMode = false,
    -- Font and texture
    customFontSize = 12,
    useCustomFont = false,
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
    enableNameplateAuraCustomisation = false,
    nameplateAurasCenteredAnchor = false,
    maxAurasOnNameplate = 12,
    nameplateAuraRowAmount = 5,
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

    personalNpBuffEnable = true,
    personalNpBuffFilterAll = false,
    personalNpBuffFilterBlizzard = true,
    personalNpBuffFilterWatchList = true,
    personalNpBuffFilterLessMinite = false,

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
        {name = "Spirit Wolves (Enha Shaman)", id = 29264, comment = ""},
        {name = "Earth Elemental (Shaman)", id = 95072, comment = ""},
        {name = "Mirror Images (Mage)", id = 31216, comment = ""},
        {name = "Beast (Hunter)", id = 62005, comment = ""},
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
        {name = "Fel Obelisk (Warlock)", id = 179193, comment = ""},
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
        {name = "Skyfury Totem", id = 105427, comment = ""},
        {name = "Liquid Magma Totem", id = 97369, comment = ""},
        {name = "Windfury Totem", id = 6112, comment = ""},
        {name = "Mindbender", id = 62982, comment = ""},
        {name = "Static Field Totem", id = 179867, comment = ""},
        {name = "Stoneskin Totem", id = 194117, comment = ""},
        {name = "Poison Cleansing Totem", id = 5923, comment = ""},
        {name = "Tranquil Air Totem", id = 194118, comment = ""},
        {name = "Felguard (Demo Pet)", id = 17252, comment = ""},
        {name = "Felhunter (Warlock)", id = 417, comment = ""},
        {name = "Succubus (Warlock)", id = 1863, comment = ""},
        {name = "Infernal (Warlock)", id = 89, comment = ""},
    },

    hideCastbarList = {},
    hideCastbarWhitelist = {},
    colorNpcList = {},
    auraWhitelist = {},
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
        {name = "Lightning Lasso"},
    },
}

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

    for key, defaultValue in pairs(defaultSettings) do
        if BetterBlizzPlatesDB[key] == nil then
            BetterBlizzPlatesDB[key] = defaultValue
        end
    end
end

function CVarFetcher()
    if BBP.variablesLoaded then
        BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = C_NamePlate.GetNamePlateEnemySize()
        BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = C_NamePlate.GetNamePlateFriendlySize()
        BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = C_NamePlate.GetNamePlateSelfSize()

        BetterBlizzPlatesDB.nameplateOverlapH = GetCVar("nameplateOverlapH")
        BetterBlizzPlatesDB.nameplateOverlapV = GetCVar("nameplateOverlapV")
        BetterBlizzPlatesDB.nameplateMotionSpeed = GetCVar("nameplateMotionSpeed")
        BetterBlizzPlatesDB.nameplateHorizontalScale = GetCVar("NamePlateHorizontalScale")
        BetterBlizzPlatesDB.NamePlateVerticalScale = GetCVar("NamePlateVerticalScale")
        BetterBlizzPlatesDB.nameplateMinScale = GetCVar("nameplateMinScale")
        BetterBlizzPlatesDB.nameplateMaxScale = GetCVar("nameplateMaxScale")
        BetterBlizzPlatesDB.nameplateSelectedScale = GetCVar("nameplateSelectedScale")
        BetterBlizzPlatesDB.NamePlateClassificationScale = GetCVar("NamePlateClassificationScale")
        BetterBlizzPlatesDB.nameplateGlobalScale = GetCVar("nameplateGlobalScale")
        BetterBlizzPlatesDB.nameplateLargerScale = GetCVar("nameplateLargerScale")
        BetterBlizzPlatesDB.nameplatePlayerLargerScale = GetCVar("nameplatePlayerLargerScale")
        BetterBlizzPlatesDB.nameplateResourceOnTarget = GetCVar("nameplateResourceOnTarget")

        BetterBlizzPlatesDB.nameplateMinAlpha = GetCVar("nameplateMinAlpha")
        BetterBlizzPlatesDB.nameplateMinAlphaDistance = GetCVar("nameplateMinAlphaDistance")
        BetterBlizzPlatesDB.nameplateMaxAlpha = GetCVar("nameplateMaxAlpha")
        BetterBlizzPlatesDB.nameplateMaxAlphaDistance = GetCVar("nameplateMaxAlphaDistance")
        BetterBlizzPlatesDB.nameplateOccludedAlphaMult = GetCVar("nameplateOccludedAlphaMult")
        BetterBlizzPlatesDB.nameplateMotion = GetCVar("nameplateMotion")

        BetterBlizzPlatesDB.nameplateShowEnemyGuardians = GetCVar("nameplateShowEnemyGuardians")
        BetterBlizzPlatesDB.nameplateShowEnemyMinions = GetCVar("nameplateShowEnemyMinions")
        BetterBlizzPlatesDB.nameplateShowEnemyMinus = GetCVar("nameplateShowEnemyMinus")
        BetterBlizzPlatesDB.nameplateShowEnemyPets = GetCVar("nameplateShowEnemyPets")
        BetterBlizzPlatesDB.nameplateShowEnemyTotems = GetCVar("nameplateShowEnemyTotems")

        BetterBlizzPlatesDB.nameplateShowFriendlyGuardians = GetCVar("nameplateShowFriendlyGuardians")
        BetterBlizzPlatesDB.nameplateShowFriendlyMinions = GetCVar("nameplateShowFriendlyMinions")
        BetterBlizzPlatesDB.nameplateShowFriendlyPets = GetCVar("nameplateShowFriendlyPets")
        BetterBlizzPlatesDB.nameplateShowFriendlyTotems = GetCVar("nameplateShowFriendlyTotems")

        if GetCVar("NamePlateHorizontalScale") == "1.4" then
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

local function FetchAndSaveValuesOnFirstLogin()
    if BBP.variablesLoaded then
        -- collect some cvars added at a later time
        if not BetterBlizzPlatesDB.nameplateMinAlpha or not BetterBlizzPlatesDB.nameplateShowFriendlyMinions or not BetterBlizzPlatesDB.nameplateSelfWidth or not BetterBlizzPlatesDB.nameplateResourceOnTarget then
            CVarFetcher()
        end

        if BetterBlizzPlatesDB.hasSaved then
            return
        end

        CVarFetcher()

        C_Timer.After(5, function()
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates first run. Thank you for trying out my AddOn. Access settings with /bbp")
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
       db.nameplatePlayerLargerScale and
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
    BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = 110, 45
    BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = 110, 45
    BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight = 110, 45

    BetterBlizzPlatesDB.nameplateOverlapH = 0.8
    BetterBlizzPlatesDB.nameplateOverlapV = 1.1
    BetterBlizzPlatesDB.nameplateMotionSpeed = 0.025
    BetterBlizzPlatesDB.nameplateHorizontalScale = 1
    BetterBlizzPlatesDB.NamePlateVerticalScale = 1
    BetterBlizzPlatesDB.nameplateMinScale = 0.8
    BetterBlizzPlatesDB.nameplateMaxScale = 1
    BetterBlizzPlatesDB.nameplateSelectedScale = 1.2
    BetterBlizzPlatesDB.NamePlateClassificationScale = 1
    BetterBlizzPlatesDB.nameplateGlobalScale = 1
    BetterBlizzPlatesDB.nameplateLargerScale = 1.2
    BetterBlizzPlatesDB.nameplatePlayerLargerScale = 1.8
    BetterBlizzPlatesDB.nameplateResourceOnTarget = 0

    BetterBlizzPlatesDB.nameplateMinAlpha = 0.6
    BetterBlizzPlatesDB.nameplateMinAlphaDistance = 10
    BetterBlizzPlatesDB.nameplateMaxAlpha = 1.0
    BetterBlizzPlatesDB.nameplateMaxAlphaDistance = 40
    BetterBlizzPlatesDB.nameplateOccludedAlphaMult = 0.4

    BetterBlizzPlatesDB.nameplateShowEnemyGuardians = 1
    BetterBlizzPlatesDB.nameplateShowEnemyMinions = 1
    BetterBlizzPlatesDB.nameplateShowEnemyMinus = 0
    BetterBlizzPlatesDB.nameplateShowEnemyPets = 1
    BetterBlizzPlatesDB.nameplateShowEnemyTotems = 1

    BetterBlizzPlatesDB.nameplateShowFriendlyGuardians = 0
    BetterBlizzPlatesDB.nameplateShowFriendlyMinions = 0
    BetterBlizzPlatesDB.nameplateShowFriendlyPets = 0
    BetterBlizzPlatesDB.nameplateShowFriendlyTotems = 0

    if GetCVar("NamePlateHorizontalScale") == "1.4" then
        BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
        BetterBlizzPlatesDB.castBarHeight = 18.8
        BetterBlizzPlatesDB.largeNameplates = true
    else
        BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 4
        BetterBlizzPlatesDB.castBarHeight = 8
        BetterBlizzPlatesDB.largeNameplates = false
    end

    SetCVar("nameplateOverlapH", BetterBlizzPlatesDB.nameplateOverlapH)
    SetCVar("nameplateOverlapV", BetterBlizzPlatesDB.nameplateOverlapV)
    SetCVar("nameplateMotionSpeed", BetterBlizzPlatesDB.nameplateMotionSpeed)
    SetCVar("nameplateHorizontalScale", BetterBlizzPlatesDB.nameplateHorizontalScale)
    SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
    SetCVar("nameplateMinScale", BetterBlizzPlatesDB.nameplateMinScale)
    SetCVar("nameplateMaxScale", BetterBlizzPlatesDB.nameplateMaxScale)
    SetCVar("nameplateSelectedScale", BetterBlizzPlatesDB.nameplateSelectedScale)
    SetCVar("NamePlateClassificationScale", BetterBlizzPlatesDB.NamePlateClassificationScale)
    SetCVar("nameplateGlobalScale", BetterBlizzPlatesDB.nameplateGlobalScale)
    SetCVar("nameplateLargerScale", BetterBlizzPlatesDB.nameplateLargerScale)
    SetCVar("nameplatePlayerLargerScale", BetterBlizzPlatesDB.nameplatePlayerLargerScale)
    SetCVar("nameplateResourceOnTarget", BetterBlizzPlatesDB.nameplateResourceOnTarget)
    SetCVar("nameplateMinAlpha", BetterBlizzPlatesDB.nameplateMinAlpha)
    SetCVar("nameplateMinAlphaDistance", BetterBlizzPlatesDB.nameplateMinAlphaDistance)
    SetCVar("nameplateMaxAlpha", BetterBlizzPlatesDB.nameplateMaxAlpha)
    SetCVar("nameplateMaxAlphaDistance", BetterBlizzPlatesDB.nameplateMaxAlphaDistance)
    SetCVar("nameplateOccludedAlphaMult", BetterBlizzPlatesDB.nameplateOccludedAlphaMult)
    SetCVar("nameplateShowEnemyGuardians", BetterBlizzPlatesDB.nameplateShowEnemyGuardians)
    SetCVar("nameplateShowEnemyMinions", BetterBlizzPlatesDB.nameplateShowEnemyMinions)
    SetCVar("nameplateShowEnemyMinus", BetterBlizzPlatesDB.nameplateShowEnemyMinus)
    SetCVar("nameplateShowEnemyPets", BetterBlizzPlatesDB.nameplateShowEnemyPets)
    SetCVar("nameplateShowEnemyTotems", BetterBlizzPlatesDB.nameplateShowEnemyTotems)
    SetCVar("nameplateShowFriendlyGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyGuardians)
    SetCVar("nameplateShowFriendlyMinions", BetterBlizzPlatesDB.nameplateShowFriendlyMinions)
    SetCVar("nameplateShowFriendlyPets", BetterBlizzPlatesDB.nameplateShowFriendlyPets)
    SetCVar("nameplateShowFriendlyTotems", BetterBlizzPlatesDB.nameplateShowFriendlyTotems)
    SetCVar('nameplateShowOnlyNames', 0)

    ReloadUI()
end

local function ResetBBP()
    BetterBlizzPlatesDB = {}

    ResetNameplates()

    BetterBlizzPlatesDB.hasSaved = true

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


local updatedDurations = {
    [5913] = 13,     -- New duration for Tremor Totem
    [104818] = 33,   -- New duration for Ancestral Protection Totem
    [100943] = 18,   -- New duration for Earthen Wall Totem
    [3527] = 18,     -- New duration for Healing Stream Totem
    [97285] = 18,    -- New duration for Wind Rush Totem
    [60561] = 30,    -- New duration for Earthgrab Totem
    [2630] = 30,     -- New duration for Earthbind Totem
    [5923] = 9,      -- New duration for Poison Cleansing Totem
}

-- Function to update the durations in the user's table
local function updateDurations(userTable)
    for id, newDuration in pairs(updatedDurations) do
        if userTable[id] then
            userTable[id].duration = newDuration
        end
    end
end

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
        updateDurations(BetterBlizzPlatesDB.totemIndicatorNpcList)
        C_Timer.After(7, function()
            --bbp news
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates " .. addonUpdates .. ":")
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a New Target Indicator settings: hide icon + color nameplate. Bugfixes.")
        end)
    end
end

local function NewsUpdateMessage()
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates news:")
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a #1: Misc: Anon Mode, replace names with class.")
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a #2: CVar: Don't force CVar option.")
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a #3: Bugfix: MC bug fixed?")
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a #4: Updated Nahj profile.")
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a #5: New Target Indicator settings: hide icon + color nameplate")
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Patreon link: www.patreon.com/bodydev")
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


    local reaction = UnitReaction("player", unit)

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
end

-- Extracts NPC ID from GUID
function BBP.GetNPCIDFromGUID(guid)
    return tonumber(string.match(guid, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function BBP.GetNameplate(unit)
    return C_NamePlate.GetNamePlateForUnit(unit)
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
            local friendlyHeight = BetterBlizzPlatesDB.friendlyNameplateClickthrough and 1 or (BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeFriendlyHeight or BetterBlizzPlatesDB.nameplateDefaultFriendlyHeight)

            if BetterBlizzPlatesDB.NamePlateVerticalScale then
                SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
            end

            if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
                C_NamePlate.SetNamePlateFriendlyClickThrough(true)
            else
                C_NamePlate.SetNamePlateFriendlyClickThrough(false)
            end

            if BetterBlizzPlatesDB.nameplateSelfHeight then
                C_NamePlate.SetNamePlateSelfSize(BetterBlizzPlatesDB.nameplateSelfWidth, BetterBlizzPlatesDB.nameplateSelfHeight)
            end

            C_NamePlate.SetNamePlateFriendlySize(BetterBlizzPlatesDB.nameplateFriendlyWidth or friendlyWidth, friendlyHeight)
            C_NamePlate.SetNamePlateEnemySize(BetterBlizzPlatesDB.nameplateEnemyWidth or enemyWidth, BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeEnemyHeight or BetterBlizzPlatesDB.nameplateDefaultEnemyHeight)
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

local function anonMode(frame)
    local isPlayer = UnitIsPlayer(frame.unit)
    local isUser = UnitIsUnit(frame.unit, "player")
    local name = frame.name
    if isPlayer then
        if not isUser then
            local class = UnitClass(frame.unit)
            name:SetText(class)
        else
            name:SetText("Anon")
        end
    end
end

--#################################################################################################
-- Set custom healthbar texture
function BBP.ApplyCustomTexture(namePlate)
    local unitFrame = namePlate.UnitFrame
    if unitFrame then
        local useCustomTextureForBars = BetterBlizzPlatesDB.useCustomTextureForBars
        if useCustomTextureForBars then
            if unitFrame.healthBar then
                local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitFrame.unit)
                local doFriend = BetterBlizzPlatesDB.useCustomTextureForFriendly and isFriend
                local doEnemy = BetterBlizzPlatesDB.useCustomTextureForEnemy and (isEnemy or isNeutral)
                local defaultTexture = "Interface/TargetingFrame/UI-TargetingFrame-BarFill"
                if doFriend then
                    local textureName = BetterBlizzPlatesDB.customTextureFriendly
                    local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                    unitFrame.healthBar:SetStatusBarTexture(texturePath)
                elseif doEnemy then
                    local textureName = BetterBlizzPlatesDB.customTexture
                    local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                    unitFrame.healthBar:SetStatusBarTexture(texturePath)
                else
                    unitFrame.healthBar:SetStatusBarTexture(defaultTexture)
                end
            end
        end
    end
end

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
local function ToggleFriendlyPlates()
    if BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena then
        if not InCombatLockdown() then
            if IsActiveBattlefieldArena() then
                SetCVar("nameplateShowFriends", 1)
            else
                SetCVar("nameplateShowFriends", 0)
            end
        else
            C_Timer.After(0.5, function()
                ToggleFriendlyPlates()
            end)
        end
    end
end

local friendlyNameplatesOnOffFrame = CreateFrame("Frame")
friendlyNameplatesOnOffFrame:SetScript("OnEvent", function(self, event, ...)
    ToggleFriendlyPlates()
end)

--#################################################################################################
-- Set CVars that keep changing
local function SetCVarsOnLogin()
    if BetterBlizzPlatesDB.hasSaved and not BetterBlizzPlatesDB.disableCVarForceOnLogin then
        SetCVar("nameplateOverlapH", BetterBlizzPlatesDB.nameplateOverlapH)
        SetCVar("nameplateOverlapV", BetterBlizzPlatesDB.nameplateOverlapV)
        SetCVar("nameplateMotionSpeed", BetterBlizzPlatesDB.nameplateMotionSpeed)
        SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
        SetCVar("nameplateSelectedScale", BetterBlizzPlatesDB.nameplateSelectedScale)
        SetCVar("nameplateMinScale", BetterBlizzPlatesDB.nameplateMinScale)
        SetCVar("nameplateMaxScale", BetterBlizzPlatesDB.nameplateMaxScale)
        SetCVar("nameplateMinAlpha", BetterBlizzPlatesDB.nameplateMinAlpha)
        SetCVar("nameplateMinAlphaDistance", BetterBlizzPlatesDB.nameplateMinAlphaDistance)
        SetCVar("nameplateMaxAlpha", BetterBlizzPlatesDB.nameplateMaxAlpha)
        SetCVar("nameplateMaxAlphaDistance", BetterBlizzPlatesDB.nameplateMaxAlphaDistance)
        SetCVar("nameplateOccludedAlphaMult", BetterBlizzPlatesDB.nameplateOccludedAlphaMult)
        SetCVar("nameplateGlobalScale", BetterBlizzPlatesDB.nameplateGlobalScale)
        if BetterBlizzPlatesDB.nameplateMotion then
            SetCVar("nameplateMotion", BetterBlizzPlatesDB.nameplateMotion)
        end

        if BetterBlizzPlatesDB.NamePlateVerticalScale then
            local verticalScale = tonumber(BetterBlizzPlatesDB.NamePlateVerticalScale)
            if verticalScale and verticalScale >= 2 then
                SetCVar("NamePlateHorizontalScale", 1.4)
            else
                SetCVar("NamePlateHorizontalScale", 1)
            end
        end

        if BetterBlizzPlatesDB.setCVarAcrossAllCharacters then
            SetCVar("nameplateShowEnemyGuardians", BetterBlizzPlatesDB.nameplateShowEnemyGuardians)
            SetCVar("nameplateShowEnemyMinions", BetterBlizzPlatesDB.nameplateShowEnemyMinions)
            SetCVar("nameplateShowEnemyMinus", BetterBlizzPlatesDB.nameplateShowEnemyMinus)
            SetCVar("nameplateShowEnemyPets", BetterBlizzPlatesDB.nameplateShowEnemyPets)
            SetCVar("nameplateShowEnemyTotems", BetterBlizzPlatesDB.nameplateShowEnemyTotems)

            SetCVar("nameplateShowFriendlyGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyGuardians)
            SetCVar("nameplateShowFriendlyMinions", BetterBlizzPlatesDB.nameplateShowFriendlyMinions)
            SetCVar("nameplateShowFriendlyMinus", BetterBlizzPlatesDB.nameplateShowFriendlyMinus)
            SetCVar("nameplateShowFriendlyPets", BetterBlizzPlatesDB.nameplateShowFriendlyPets)
            SetCVar("nameplateShowFriendlyTotems", BetterBlizzPlatesDB.nameplateShowFriendlyTotems)
        end

        ToggleFriendlyPlates()
    end
end

-- Toggle event listening on/off
function BBP.ToggleFriendlyNameplatesInArena()
    if BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena then
        friendlyNameplatesOnOffFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    else
        friendlyNameplatesOnOffFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    end
    if not InCombatLockdown() then
        if IsActiveBattlefieldArena() then
            SetCVar("nameplateShowFriends", 1)
        else
            SetCVar("nameplateShowFriends", 0)
        end
    end
end

--#################################################################################################
function BBP.HideOrShowNameplateAurasAndTargetHighlight(frame)
    local hideNameplateAuras = BetterBlizzPlatesDB.hideNameplateAuras
    local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
    -- Handle Buff Frame's alpha
    if hideNameplateAuras then
        frame.BuffFrame:SetAlpha(0)
    else
        frame.BuffFrame:SetAlpha(1)
    end

    if hideTargetHighlight then
        frame.selectionHighlight:SetAlpha(0)
    else
        frame.selectionHighlight:SetAlpha(0.22)
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
hooksecurefunc(NamePlateDriverFrame.pools:GetPool("NamePlateUnitFrameTemplate"),"resetterFunc",BBP.ClickthroughNameplateAuras)
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
    frame.name:SetScale(scale)
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

    if isFriendly and BetterBlizzPlatesDB.friendlyNameplateClickthrough then
        heightValue = 1
    end

    if not BBP.checkCombatAndWarn() then
        if isFriendly then
            if BBP.isLargeNameplatesEnabled() then
                C_NamePlate.SetNamePlateFriendlySize(154, heightValue)
                slider:SetValue(154)
            else
                C_NamePlate.SetNamePlateFriendlySize(110, heightValue)
                slider:SetValue(110)
            end
        else
            if slider ~= nameplateSelfWidth then
                if BBP.isLargeNameplatesEnabled() then
                    C_NamePlate.SetNamePlateEnemySize(154, heightValue)
                    slider:SetValue(154)
                else
                    C_NamePlate.SetNamePlateEnemySize(110, heightValue)
                    slider:SetValue(110)
                end
            else
                C_NamePlate.SetNamePlateFriendlySize(154, BetterBlizzPlatesDB.nameplateSelfHeight)
                slider:SetValue(154)
            end
        end
    end
end

--#################################################################################################
-- Reset to default CVar values
function BBP.ResetToDefaultScales(slider, targetType)
    -- Define default values
    local defaultSettings = {
        nameplateScale = 1.0,  -- This will be used for nameplateMaxScale
        nameplateSelected = 1.2,
    }

    -- Set the slider's value to the default
    slider:SetValue(defaultSettings[targetType] or 1)

    if not BBP.checkCombatAndWarn() then
        if targetType == "nameplateScale" then
            -- Reset both nameplateMinScale and nameplateMaxScale based on their ratio
            local defaultMinScale = 0.8
            local defaultMaxScale = 1.0
            local defaultGlobalScale = 1
            BetterBlizzPlatesDB.nameplateMinScale = defaultMinScale
            BetterBlizzPlatesDB.nameplateMaxScale = defaultMaxScale
            BetterBlizzPlatesDB.nameplateGlobalScale = defaultGlobalScale
            SetCVar("nameplateMinScale", defaultMinScale)
            SetCVar("nameplateMaxScale", defaultMaxScale)
            SetCVar("nameplateGlobalScale", defaultGlobalScale)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinScale set to " .. defaultMinScale)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMaxScale set to " .. defaultMaxScale)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateGlobalScale set to 1")
        elseif targetType == "nameplateSelected" then
            BetterBlizzPlatesDB.nameplateSelectedScale = defaultSettings[targetType]
            SetCVar("nameplateSelectedScale", defaultSettings[targetType])
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
    if BBP.isLargeNameplatesEnabled() then
        --slider:SetValue(10.8)
        --BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 10.8
        slider:SetValue(2.7)
        BetterBlizzPlatesDB.NamePlateVerticalScale = "2.7"
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar NamePlateVerticalScale set to 2.7")
    else
        --slider:SetValue(4)
        --BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = 4
        slider:SetValue(1)
        BetterBlizzPlatesDB.NamePlateVerticalScale = "1"
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar NamePlateVerticalScale set to 1")
    end
end

function BBP.ResetToDefaultValue(slider, element)
    if not BBP.checkCombatAndWarn() then
        if element == "nameplateOverlapH" then
            BetterBlizzPlatesDB.nameplateOverlapH = 0.8
            SetCVar("nameplateOverlapH", 0.8)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOverlapH set to 0.8")
        elseif element == "nameplateOverlapV" then
            BetterBlizzPlatesDB.nameplateOverlapV = 1.1
            SetCVar("nameplateOverlapV", 1.1)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOverlapV set to 1.1")
        elseif element == "nameplateMotionSpeed" then
            BetterBlizzPlatesDB.nameplateMotionSpeed = 0.025
            SetCVar("nameplateMotionSpeed", 0.025)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMotionSpeed set to 0.025")
        elseif element == "nameplateMinAlpha" then
            BetterBlizzPlatesDB.nameplateMinAlpha = 0.6
            SetCVar("nameplateMinAlpha", 0.6)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinAlpha set to 0.6")
        elseif element == "nameplateMinAlphaDistance" then
            BetterBlizzPlatesDB.nameplateMinAlphaDistance = 10
            SetCVar("nameplateMinAlphaDistance", 10)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMinAlphaDistance set to 10")
        elseif element == "nameplateMaxAlpha" then
            BetterBlizzPlatesDB.nameplateMaxAlpha = 1
            SetCVar("nameplateMaxAlpha", 1)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMotionSpeed set to 1")
        elseif element == "nameplateMaxAlphaDistance" then
            BetterBlizzPlatesDB.nameplateMaxAlphaDistance = 40
            SetCVar("nameplateMaxAlphaDistance", 40)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateMaxAlphaDistance set to 40")
        elseif element == "nameplateOccludedAlphaMult" then
            BetterBlizzPlatesDB.nameplateOccludedAlphaMult = 0.4
            SetCVar("nameplateOccludedAlphaMult", 0.4)
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aCVar nameplateOccludedAlphaMult set to 0.4")
        elseif element == "nameplateResourceScale" then
            BetterBlizzPlatesDB.nameplateResourceScale = 0.7
            BBP.ApplySettingsToAllNameplates()
        end
        slider:SetValue(BetterBlizzPlatesDB[element])
    end
end

function BBP.ToggleAndPrintCVAR(cvarName)
    local currentValue = GetCVar(cvarName)
    local newValue = (currentValue == "1") and "0" or "1"

    SetCVar(cvarName, newValue)
    print(string.format("%s set to %s", cvarName, newValue))
end

--##################################################################################################
-- Fade out npcs from list
function BBP.FadeOutNPCs(frame)
    if not frame or not frame.displayedUnit then return end
    frame:SetAlpha(1)
    -- Skip if the unit is a player
    if UnitIsPlayer(frame.displayedUnit) then return end

    local unitGUID = UnitGUID(frame.displayedUnit)
    if not unitGUID then return end

    local npcID = select(6, strsplit("-", unitGUID))
    local npcName = UnitName(frame.displayedUnit)
    local isTarget = UnitIsUnit(frame.displayedUnit, "target")
    local fadeOutNPCsAlpha = BetterBlizzPlatesDB.fadeOutNPCsAlpha
    local fadeAllButTarget = BetterBlizzPlatesDB.fadeAllButTarget

    if fadeAllButTarget then
        if UnitExists("target") then
            if not isTarget then
                frame:SetAlpha(fadeOutNPCsAlpha)
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
    if isTarget then
        frame:SetAlpha(1)
    elseif inList then
        frame:SetAlpha(fadeOutNPCsAlpha)
    else
        frame:SetAlpha(1)
    end
end


--##################################################################################################
-- Hide npcs from list
function BBP.HideNPCs(frame)
    if not frame or not frame.displayedUnit then return end
    frame:Show()

    local hideNPCArenaOnly = BetterBlizzPlatesDB.hideNPCArenaOnly
    local hideNPCWhitelistOn = BetterBlizzPlatesDB.hideNPCWhitelistOn
    local hideNPCPetsOnly = BetterBlizzPlatesDB.hideNPCPetsOnly
    local inBg = UnitInBattleground("player")
    local isPet = (UnitGUID(frame.displayedUnit) and select(6, strsplit("-", UnitGUID(frame.displayedUnit))) == "Pet")

    if hideNPCArenaOnly and not inBg then
        return
    end

    -- Skip if the unit is a player
    if UnitIsPlayer(frame.displayedUnit) then return end

    local unitGUID = UnitGUID(frame.displayedUnit)
    if not unitGUID then return end

    local npcID = select(6, strsplit("-", unitGUID))
    local npcName = UnitName(frame.displayedUnit)

    -- Convert npcName to lowercase for case-insensitive comparison
    local lowerCaseNpcName = strlower(npcName)

    if hideNPCWhitelistOn then
        -- Check if the NPC is in the whitelist by ID or name (case-insensitive)
        local inWhitelist = false
        local hideNPCsWhitelist = BetterBlizzPlatesDB.hideNPCsWhitelist
        for _, npc in ipairs(hideNPCsWhitelist) do
            if npc.id == tonumber(npcID) or (npc.id and npc.id == tonumber(npcID)) then
                inWhitelist = true
                break
            elseif npc.name == tostring(npcName) or strlower(npc.name) == lowerCaseNpcName then
                inWhitelist = true
                break
            end
        end

        -- Show the frame only if the NPC is in the whitelist or is the current target
        if UnitIsUnit(frame.displayedUnit, "target") or inWhitelist then
            frame:Show()
            frame.hideCastInfo = false
        else
            frame:Hide()
            frame.hideCastInfo = true
        end
    else
        -- Check if the NPC is in the blacklist by ID or name (case-insensitive)
        local inList = false
        local hideNPCsList = BetterBlizzPlatesDB.hideNPCsList
        for _, npc in ipairs(hideNPCsList) do
            if npc.id == tonumber(npcID) or (npc.id and npc.id == tonumber(npcID)) then
                inList = true
                break
            elseif npc.name == tostring(npcName) or strlower(npc.name) == lowerCaseNpcName then
                inList = true
                break
            end
        end

        -- Check if the unit is the current target and show accordingly
        if UnitIsUnit(frame.displayedUnit, "target") then
            frame:Show()
            frame.hideCastInfo = false
        elseif inList or (hideNPCPetsOnly and isPet) then
            frame:Hide()
            frame.hideCastInfo = true
        else
            frame:Show()
            frame.hideCastInfo = false
        end
    end
end





--################################################################################################
-- Color NPCs
function BBP.ColorNPCs(frame)
    if not BetterBlizzPlatesDB.colorNPC then return end
    if not frame or not frame.displayedUnit then return end
    -- Skip if the unit is a player
    if UnitIsPlayer(frame.displayedUnit) then return end

    local unitGUID = UnitGUID(frame.displayedUnit)
    if not unitGUID then return end

    local npcID = select(6, strsplit("-", unitGUID))
    local npcName = UnitName(frame.displayedUnit)

    -- Convert npcName to lowercase for case insensitive comparison
    local lowerCaseNpcName = strlower(npcName)

    -- Check if the NPC is in the list by ID or name (case insensitive)
    local inList = false
    local npcColor = nil
    local colorNpcList = BetterBlizzPlatesDB.colorNpcList
    for _, npc in ipairs(colorNpcList) do
        if npc.id == tonumber(npcID) or (npc.name and strlower(npc.name) == lowerCaseNpcName) then
            inList = true
            if npc.entryColors then
                npcColor = npc.entryColors.text
            else
                npc.entryColors = {} -- default for new entries that doesnt have a color yet
            end
            break
        end
    end


    -- Set the vertex color based on the NPC color values
    if inList and npcColor then
        frame.healthBar:SetStatusBarColor(npcColor.r, npcColor.g, npcColor.b)
        local colorNPCName = BetterBlizzPlatesDB.colorNPCName
        if colorNPCName then
            frame.name:SetVertexColor(npcColor.r, npcColor.g, npcColor.b)
        end
    end
end

function BBP.AuraColor(frame)
    if not BetterBlizzPlatesDB.colorNPC then return end
    if not frame or not frame.displayedUnit then return end

    local highestPriority = 0  -- Initialize the highest priority to 0
    local auraColor = nil  -- Initialize the aura color to nil

    local auraColorList = BetterBlizzPlatesDB.auraColorList
    local displayedUnit = frame.displayedUnit

    for _, npc in ipairs(auraColorList) do
        if npc.id or npc.name then
            local entryPriority = npc.priority or 0  -- Initialize the priority for this aura to 0
            for index = 1, 40 do
                local auraName, _, _, _, _, _, _, _, _, spellId = UnitAura(displayedUnit, index, "HELPFUL|HARMFUL")
                if auraName then
                    -- Convert auraName to lowercase for case-insensitive comparison
                    local lowerCaseAuraName = strlower(auraName)

                    if (npc.id == tonumber(spellId) or (npc.name and strlower(npc.name) == lowerCaseAuraName)) then
                        -- Update the aura color if priority is higher
                        if entryPriority > highestPriority then
                            highestPriority = entryPriority
                            auraColor = npc.entryColors.text
                        end
                    end
                end
            end
        end
    end

    -- Set the vertex color based on the highest priority aura color
    if auraColor then
        frame.healthBar:SetStatusBarColor(auraColor.r, auraColor.g, auraColor.b)
    end
end
local UnitAuraEventFrame = nil

local function UnitAuraColorEvent(self, event, ...)
    local unit = ...
    if string.match(unit, "nameplate") then
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit, false)
        if nameplate then
            local frame = nameplate.UnitFrame
            BBP.AuraColor(frame)
        end
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

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if not frame.unit or not frame.unit:find("nameplate") then return end
    if not BBP.IsLegalNameplateUnit(frame) then return end

    local colorNpc = BetterBlizzPlatesDB.colorNPC
    local focusIndicator = BetterBlizzPlatesDB.focusTargetIndicator
    local friendlyHealthBarColor = BetterBlizzPlatesDB.friendlyHealthBarColor
    local enemyHealthBarColor = BetterBlizzPlatesDB.enemyHealthBarColor
    local castEmphasisColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
    local totemIndicator = BetterBlizzPlatesDB.totemIndicator
    local totemIndicatorTest = BetterBlizzPlatesDB.totemIndicatorTestMode
    local colorPersonalNp = BetterBlizzPlatesDB.classColorPersonalNameplate
    local auraColor = BetterBlizzPlatesDB.auraColor
    local colorTarget = BetterBlizzPlatesDB.targetIndicatorColorNameplate

    if colorPersonalNp then
        local isPlayer = UnitIsUnit(frame.unit, "player")
        if isPlayer then
            frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
        end
    end

    if friendlyHealthBarColor or enemyHealthBarColor then
        local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
        local isOtherPlayer = UnitIsPlayer(frame.unit)
        local npcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly

        if isFriend and friendlyHealthBarColor then
            -- Coloring friendly health bars
            local color = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
            frame.healthBar:SetStatusBarColor(unpack(color))
        elseif not isFriend and enemyHealthBarColor then
            -- Handling enemy health bars
            if not (npcOnly and isOtherPlayer) then
                -- This block will execute only if npcOnly is false or the unit is not a player
                local color

                if isNeutral then
                    -- Neutral NPC
                    color = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 0, 0}
                else
                    -- Hostile NPC
                    color = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
                end

                frame.healthBar:SetStatusBarColor(unpack(color))
            end
        end
    end

    if colorNpc then
        BBP.ColorNPCs(frame)
    end

    if focusIndicator then
        BBP.FocusTargetIndicator(frame)
    end

    if castEmphasisColor then
        local nameplate = BBP.GetNameplate(frame.unit)
        local isCasting = UnitCastingInfo(frame.unit) or UnitChannelInfo(frame.unit)
        if nameplate and nameplate.emphasizedCast and isCasting then
            frame.healthBar:SetStatusBarColor(nameplate.emphasizedCast.entryColors.text.r, nameplate.emphasizedCast.entryColors.text.g, nameplate.emphasizedCast.entryColors.text.b)
        end
    end

    if totemIndicator or totemIndicatorTest then
        local npcID = BBP.GetNPCIDFromGUID(UnitGUID(frame.unit))
        local totemColor

        if totemIndicatorTest then
            -- Check if the frame already has test attributes stored
            if not frame.testTotemColor then
                -- If not, fetch random totem attributes and store them on the frame
                local _, testColor = BBP.GetRandomTotemAttributes()  -- Only interested in the color here
                frame.testTotemColor = testColor
            end
            -- Use the stored test color
            totemColor = frame.testTotemColor
        elseif BetterBlizzPlatesDB.totemIndicatorNpcList[npcID] then
            -- Not in test mode, use the actual npcID to get the totem's color
            totemColor = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color
        end

        if totemColor then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
            local showEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
            if not isFriend or not showEnemyOnly then
                frame.healthBar:SetStatusBarColor(unpack(totemColor))
                frame.name:SetVertexColor(unpack(totemColor))
            end
        end
    end

    if auraColor then
        BBP.AuraColor(frame)
    end

    if colorTarget then
        BBP.ColorTargetNameplate(frame)
    end
end)


-- Copy of blizzards update health color function
function BBP.CompactUnitFrame_UpdateHealthColor(frame)
    if not frame or not frame.unit then return end
	local r, g, b;
	local unitIsConnected = UnitIsConnected(frame.unit);
	local unitIsDead = unitIsConnected and UnitIsDead(frame.unit);
	local unitIsPlayer = UnitIsPlayer(frame.unit) or UnitIsPlayer(frame.displayedUnit);
    local colorPersonalNp = BetterBlizzPlatesDB.classColorPersonalNameplate

    if colorPersonalNp and UnitIsUnit(frame.unit, "player") then
        frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
        return -- Return early to skip the default logic for the player's nameplate
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
			elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
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

    local colorNpc = BetterBlizzPlatesDB.colorNPC
    local focusIndicator = BetterBlizzPlatesDB.focusTargetIndicator
    local friendlyHealthBarColor = BetterBlizzPlatesDB.friendlyHealthBarColor
    local enemyHealthBarColor = BetterBlizzPlatesDB.enemyHealthBarColor
    local castEmphasisColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
    local auraColor = BetterBlizzPlatesDB.auraColor
    local totemIndicator = BetterBlizzPlatesDB.totemIndicator

    if friendlyHealthBarColor or enemyHealthBarColor then
        local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
        local isOtherPlayer = UnitIsPlayer(frame.unit)
        local npcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly

        if isFriend and friendlyHealthBarColor then
            -- Coloring friendly health bars
            local color = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
            frame.healthBar:SetStatusBarColor(unpack(color))
        elseif not isFriend and enemyHealthBarColor then
            -- Handling enemy health bars
            if not (npcOnly and isOtherPlayer) then
                -- This block will execute only if npcOnly is false or the unit is not a player
                local color

                if isNeutral then
                    -- Neutral NPC
                    color = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 0, 0}
                else
                    -- Hostile NPC
                    color = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
                end

                frame.healthBar:SetStatusBarColor(unpack(color))
            end
        end
    end

    if colorNpc then
        BBP.ColorNPCs(frame)
    end

    if focusIndicator then
        BBP.FocusTargetIndicator(frame)
    end

    if auraColor then
        BBP.AuraColor(frame)
    end

    --BBP.ColorTargetNameplate(frame)

    if castEmphasisColor then
        local nameplate = BBP.GetNameplate(frame.unit)
        local isCasting = UnitCastingInfo(frame.unit) or UnitChannelInfo(frame.unit)
        if nameplate and nameplate.emphasizedCast and isCasting then
            frame.healthBar:SetStatusBarColor(nameplate.emphasizedCast.entryColors.text.r, nameplate.emphasizedCast.entryColors.text.g, nameplate.emphasizedCast.entryColors.text.b)
        end
    end

    if totemIndicator then
        local npcID = BBP.GetNPCIDFromGUID(UnitGUID(frame.unit))
        if BetterBlizzPlatesDB.totemIndicatorNpcList[npcID] and BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
            local showEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
            if not isFriend then
                frame.healthBar:SetStatusBarColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
            else
                if not showEnemyOnly then
                    frame.healthBar:SetStatusBarColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                    frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                end
            end
        end
    end

	-- Update whether healthbar is hidden due to being dead - only applies to non-player nameplates
	--local hideHealthBecauseDead = unitIsDead and not unitIsPlayer;
	--CompactUnitFrame_SetHideHealth(frame, hideHealthBecauseDead, HEALTH_BAR_HIDE_REASON_UNIT_DEAD);
end









function BBP.OnUnitUpdate(unitId, unitInfo, allUnitsInfo)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitId, false)
    if nameplate then
        local frame = nameplate.UnitFrame
        if BetterBlizzPlatesDB.classIndicator then
            BBP.ClassIndicator(frame, unitInfo.specId)
        end
        if BetterBlizzPlatesDB.showGuildNames then
            if not frame.guildName then
                frame.guildName = frame:CreateFontString(nil, "BACKGROUND")
                local font, size, outline = frame.name:GetFont()
                frame.guildName:SetFont(font, 14, outline)
            end

            local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
            if guildName then
                frame.guildName:SetText("<"..guildName..">")
                if BetterBlizzPlatesDB.guildNameColor then
                    local color = BetterBlizzPlatesDB.guildNameColorRGB or {0, 1, 0}
                    frame.guildName:SetTextColor(unpack(color))
                else
                    frame.guildName:SetTextColor(frame.name:GetTextColor())
                end
                frame.guildName:SetPoint("TOP", frame.name, "BOTTOM", 0, 0)
                frame.guildName:SetScale(BetterBlizzPlatesDB.guildNameScale or 1)
            else
                frame.guildName:SetText("")
            end
        end
    end
end
--registering the callback:
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")
openRaidLib.RegisterCallback(BBP, "UnitInfoUpdate", "OnUnitUpdate")





--################################################################################################
-- Apply raidmarker change
function BBP.ApplyRaidmarkerChanges(nameplate)
    if not nameplate then return end
    local frame = nameplate.UnitFrame
    if not frame or frame:IsForbidden() then return end

    local raidmarkIndicator = BetterBlizzPlatesDB.raidmarkIndicator

    frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()

    if raidmarkIndicator then
        local anchorPoint = BetterBlizzPlatesDB.raidmarkIndicatorAnchor or "TOP"
        local xPos = BetterBlizzPlatesDB.raidmarkIndicatorXPos
        local yPos = BetterBlizzPlatesDB.raidmarkIndicatorYPos
        local scale = BetterBlizzPlatesDB.raidmarkIndicatorScale
        if anchorPoint == "TOP" then
            frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
            frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.name, anchorPoint, xPos, yPos)
        else
            frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
            frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.healthBar, anchorPoint, xPos, yPos)
        end
        frame.RaidTargetFrame.RaidTargetIcon:SetScale(scale or 1)
        frame.RaidTargetFrame.RaidTargetIcon:SetSize(22, 22)
        frame.RaidTargetFrame:SetFrameLevel(frame:GetFrameLevel() - 1)
    else
        frame.RaidTargetFrame.RaidTargetIcon:SetScale(1)
        frame.RaidTargetFrame.RaidTargetIcon:SetSize(22, 22)
        frame.RaidTargetFrame.RaidTargetIcon:SetPoint("RIGHT", frame.healthBar, "LEFT", -15, 0)
    end
end

-- Change raidmarker
function BBP.ChangeRaidmarker()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        BBP.ApplyRaidmarkerChanges(namePlate)
    end
end

function BBP.RefUnitAuraTotally(unitFrame)
    local unit = unitFrame.unit
    BBP.UpdateBuffs(unitFrame.BuffFrame, unit, nil, {}, unitFrame)
end

local auraModuleIsOn = false
function BBP.RunAuraModule()
    auraModuleIsOn = true

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

    function BBP.On_Np_Add(unitToken)
        local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(unitToken, false)
        if namePlateFrameBase then
            local unitFrame = namePlateFrameBase.UnitFrame
            unitFrame.BuffFrame.UpdateAnchor = BBP.UpdateAnchor;
            unitFrame.BuffFrame.Layout = function(self)
                local children = self:GetLayoutChildren()
                local isEnemyUnit = self.isEnemyUnit
                CustomBuffLayoutChildren(self, children, isEnemyUnit)
            end
            --unitFrame.BuffFrame.UpdateBuffs = BBP.UpdateBuffs
            unitFrame.BuffFrame.UpdateBuffs = function() return end
            unitFrame.healthBar.AuraR, unitFrame.healthBar.AuraG, unitFrame.healthBar.AuraB = nil, nil, nil
            BBP.On_NpRefreshOnce(unitFrame, namePlateFrameBase)
        end
    end

    function BBP.On_NpRefreshOnce(unitFrame, namePlateFrameBase)
        if unitFrame:IsForbidden() then return end
        BBP.RefUnitAuraTotally(unitFrame)
    end


    local function UIObj_Event(self, event, ...)
        if event == "NAME_PLATE_UNIT_ADDED" then
            local unit = ...
            BBP.On_Np_Add(unit)
        elseif event == "UNIT_AURA" then
            local unit, unitAuraUpdateInfo = ...
            if string.match(unit, "nameplate") then 
                local npbase = C_NamePlate.GetNamePlateForUnit(unit, false)
                if npbase then
                    BBP.OnUnitAuraUpdate(npbase.UnitFrame.BuffFrame, unit, unitAuraUpdateInfo)
                end
            end
        end
    end

    local UIObjectDriveFrame = CreateFrame("Frame", "RS_Plates", UIParent)
    UIObjectDriveFrame:SetScript("OnEvent", UIObj_Event)
    UIObjectDriveFrame:RegisterEvent("UNIT_AURA")
    UIObjectDriveFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")

    --function BBP.HookBlizzedFunc()
        hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", function()
            for k, namePlate in pairs(C_NamePlate.GetNamePlates(false)) do
                BBP.On_NpRefreshOnce(namePlate.UnitFrame)
            end
        end)

        -- Unit Faction
        hooksecurefunc(NamePlateDriverFrame, "OnUnitFactionChanged", function(self,unit)
            if not string.match(unit, "nameplate") then return end
            local npbase = C_NamePlate.GetNamePlateForUnit(unit, false)
            if npbase then
                BBP.On_NpRefreshOnce(npbase.UnitFrame)
            end
            C_Timer.After(0.1, function()
                --HandleNamePlateAdded(unit)
            end)
        end)
    --end
end


--#################################################################################################
--#################################################################################################
--#################################################################################################
-- What to do on a nameplate remvoed
local function HandleNamePlateRemoved(unit)
    local nameplate = BBP.GetNameplate(unit)
    if not nameplate or not nameplate.UnitFrame then return end
    local frame = nameplate.UnitFrame
    if frame:IsForbidden() or frame:IsProtected() then return end

    if frame then
        frame:SetScale(1)
        if frame.healthBar then
            frame.healthBar:SetAlpha(1)
        end
        local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
        if not hideTargetHighlight then
            frame.selectionHighlight:SetAlpha(0.22)
        end
    end

    if frame.hideCastInfo then
        frame.hideCastInfo = false
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
end

--#################################################################################################
--#################################################################################################
--#################################################################################################
-- What to do on a new nameplate
local function HandleNamePlateAdded(unit)
    local nameplate = BBP.GetNameplate(unit)
    if not nameplate or not nameplate.UnitFrame then return end
    local frame = nameplate.UnitFrame
    if frame:IsForbidden() or frame:IsProtected() then return end
    local isPlayer = UnitIsUnit("player", unit)
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)

    local customAuraOn = BetterBlizzPlatesDB.enableNameplateAuraCustomisation
    local customCastbar = BetterBlizzPlatesDB.enableCastbarCustomization
    local questIndicator = BetterBlizzPlatesDB.questIndicator or BetterBlizzPlatesDB.questIndicatorTestMode
    local targetIndicator = BetterBlizzPlatesDB.targetIndicator
    local absorbIndicator = BetterBlizzPlatesDB.absorbIndicator or BetterBlizzPlatesDB.absorbIndicatorTestMode
    local totemIndicator = BetterBlizzPlatesDB.totemIndicatorTestMode or BetterBlizzPlatesDB.totemIndicator
    local arenaIndicators = not BetterBlizzPlatesDB.arenaIndicatorModeOff or not BetterBlizzPlatesDB.partyIndicatorModeOff or BetterBlizzPlatesDB.arenaIndicatorTestMode
    local executeIndicator = BetterBlizzPlatesDB.executeIndicator or BetterBlizzPlatesDB.executeIndicatorTestMode
    local fadeOutNpc = BetterBlizzPlatesDB.fadeOutNPC
    local hideNpc = BetterBlizzPlatesDB.hideNPC
    local colorNpc = BetterBlizzPlatesDB.colorNPC
    local friendlyHealthBarColor = BetterBlizzPlatesDB.friendlyHealthBarColor
    local enemyHealthBarColor = BetterBlizzPlatesDB.enemyHealthBarColor
    local petIndicator = BetterBlizzPlatesDB.petIndicator or BetterBlizzPlatesDB.petIndicatorTestMode
    local raidIndicator = BetterBlizzPlatesDB.raidmarkIndicator
    local healerIndicator = BetterBlizzPlatesDB.healerIndicatorTestMode or BetterBlizzPlatesDB.healerIndicator
    local combatIndicator = BetterBlizzPlatesDB.combatIndicator
    local customTextureForBar = BetterBlizzPlatesDB.useCustomTextureForBars
    local focusIndicator = BetterBlizzPlatesDB.focusTargetIndicator or BetterBlizzPlatesDB.focusTargetIndicatorTestMode
    local friendlyHideHealthBar = BetterBlizzPlatesDB.friendlyHideHealthBar
    local classIndicator = BetterBlizzPlatesDB.classIndicator
    local auraColor = BetterBlizzPlatesDB.auraColor
    local friendIndicator = BetterBlizzPlatesDB.friendIndicator

    -- CLean up previous nameplates
    HandleNamePlateRemoved(unit)

--[[
    if not frame.BetterBlizzPlates then
        frame.BetterBlizzPlates = CreateFrame("Cooldown", BetterBlizzPlates, parent, "CooldownFrameTemplate")
        frame.BetterBlizzPlates:SetAllPoints(frame)
    end
]]


    if customAuraOn and auraModuleIsOn then
        BBP.HidePersonalBuffFrame()
    end

--[[
    if frame.castBar and not frame.castBar.bbpHook then
        print("hooked")
        frame.castBar:HookScript("OnShow", function()
            print("KEKBOOM")
        end)
        frame.castBar.bbpHook = true
    end
]]

    if nameplate.driverFrame.classNamePlateMechanicFrame then
        local nameplateResourceScale = BetterBlizzPlatesDB.nameplateResourceScale or 0.7
        nameplate.driverFrame.classNamePlateMechanicFrame:SetScale(nameplateResourceScale)
    end

    -- Castbar customization
    if customCastbar then
        BBP.CustomizeCastbar(unit)
    end

    -- Show Quest Indicator
    if questIndicator then
        BBP.QuestIndicator(frame)
    end

    -- Show Class Indicator
    if classIndicator  then
        BBP.ClassIndicator(frame)
    end

    -- Show Target indicator
    if targetIndicator then
        BBP.TargetIndicator(frame)
    end

    -- Show absorb amount
    if absorbIndicator then
        BBP.AbsorbIndicator(frame)
    end

    if arenaIndicators then
        BBP.ArenaIndicatorCaller(frame, BetterBlizzPlatesDB)
    end

    if executeIndicator then
        BBP.ExecuteIndicator(frame)
    end

    -- Handle nameplate aura and target highlight visibility
    BBP.HideOrShowNameplateAurasAndTargetHighlight(frame)

    if friendlyHideHealthBar and not isPlayer then
        if frame.healthBar and isFriend then
            if not UnitIsPlayer(unit) then
                local hideNpcHpBar = BetterBlizzPlatesDB.friendlyHideHealthBarNpc
                if hideNpcHpBar then
                    frame.healthBar:SetAlpha(0)
                    frame.selectionHighlight:SetAlpha(0)
                end
            else
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
                if BetterBlizzPlatesDB.showGuildNames then
                    if not frame.guildName then
                        frame.guildName = frame:CreateFontString(nil, "BACKGROUND")
                        local font, size, outline = frame.name:GetFont()
                        frame.guildName:SetFont(font, 14, outline)
                    end

                    local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
                    if guildName then
                        frame.guildName:SetText("<"..guildName..">")
                        if BetterBlizzPlatesDB.guildNameColor then
                            local color = BetterBlizzPlatesDB.guildNameColorRGB or {0, 1, 0}
                            frame.guildName:SetTextColor(unpack(color))
                        else
                            frame.guildName:SetTextColor(frame.name:GetTextColor())
                        end
                        frame.guildName:SetPoint("TOP", frame.name, "BOTTOM", 0, 0)
                        frame.guildName:SetScale(BetterBlizzPlatesDB.guildNameScale or 1)
                    else
                        frame.guildName:SetText("")
                    end
                end
            end
        else
            frame.healthBar:SetAlpha(1)
            if frame.guildName then
                frame.guildName:SetText("")
            end
        end
    end

    -- Fade out NPCs from list if enabled
    if fadeOutNpc then
        BBP.FadeOutNPCs(frame)
    end

    -- Hide NPCs from list if enabled
    if hideNpc then
        BBP.HideNPCs(frame)
    end

    -- Color NPC
    if colorNpc then
        BBP.ColorNPCs(frame)
    end

    if friendlyHealthBarColor or enemyHealthBarColor then
        local isOtherPlayer = UnitIsPlayer(unit)
        local npcOnly = BetterBlizzPlatesDB.enemyHealthBarColorNpcOnly

        if isFriend and friendlyHealthBarColor then
            -- Coloring friendly health bars
            local color = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
            frame.healthBar:SetStatusBarColor(unpack(color))
        elseif not isFriend and enemyHealthBarColor then
            -- Handling enemy health bars
            if not (npcOnly and isOtherPlayer) then
                -- This block will execute only if npcOnly is false or the unit is not a player
                local unitReaction = UnitReaction("player", unit)
                local color

                if unitReaction == 4 then
                    -- Neutral NPC
                    color = BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 0, 0}
                else
                    -- Hostile NPC
                    color = BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 0, 0}
                end

                frame.healthBar:SetStatusBarColor(unpack(color))
            end
        end
    end

    -- Show hunter pet icon
    if petIndicator then
        BBP.PetIndicator(frame)
    end

    -- Handle raid marker changes
    if raidIndicator then
        BBP.ApplyRaidmarkerChanges(nameplate)
    end

    -- Healer icon
    if healerIndicator then
        BBP.HealerIndicator(frame)
    end

    -- Apply Out Of Combat Icon
    if combatIndicator then
        BBP.CombatIndicator(frame)
    end

    -- Apply custom healthbar texture
    if customTextureForBar and not isPlayer then
        BBP.ApplyCustomTexture(nameplate)
    else
        frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill") --added this only to deal with scenario where user toggles off custom textures and gets new nameplates (with custom textures) displaying, OPTIMIZE
    end

    -- Show Focus Target Indicator
    if focusIndicator then
        BBP.FocusTargetIndicator(frame)
    end

    -- Show totem icons
    if totemIndicator then
        BBP.ApplyTotemIconsAndColorNameplate(frame, unit)
    end

    if auraColor then
        BBP.AuraColor(frame)
    end

    if friendIndicator then
        local isFriend = isFriendlistFriend(unit)
        local isBnetFriend = isUnitBNetFriend(unit)
        local isGuildmate = isUnitGuildmate(unit)

        if not frame.friendIndicator then
            frame.friendIndicator = frame:CreateTexture(nil, "OVERLAY")
            frame.friendIndicator:SetAtlas("groupfinder-icon-friend")
            frame.friendIndicator:SetSize(20, 21)
            frame.friendIndicator:SetPoint("RIGHT", frame.name, "LEFT", 0, 0)
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
    if BetterBlizzPlatesDB.wasOnLoadingScreen then return end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        local unitFrame = nameplate.UnitFrame
        if not frame or frame:IsForbidden() or frame:IsProtected() then return end
        local unitToken = frame.unit

        local hideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar

        BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, BetterBlizzPlatesDB.defaultLargeFontSize)
        BBP.SetFontBasedOnOption(SystemFont_NamePlate, BetterBlizzPlatesDB.defaultFontSize)
        BBP.SetFontBasedOnOption(SystemFont_LargeNamePlateFixed, BetterBlizzPlatesDB.defaultLargeFontSize)
        BBP.SetFontBasedOnOption(SystemFont_NamePlateFixed, BetterBlizzPlatesDB.defaultFontSize)

        if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
            BBP.RefUnitAuraTotally(unitFrame)
        end

        if BetterBlizzPlatesDB.enableCastbarCustomization then
            BBP.CustomizeCastbar(unitToken)
        end

        if frame.TargetText then
            BBP.SetFontBasedOnOption(nameplate.TargetText, 12)
        end
        if frame.absorbIndicator then
            BBP.SetFontBasedOnOption(nameplate.UnitFrame.absorbIndicator, 10)
        end
        if frame.CastTimer then
            BBP.SetFontBasedOnOption(nameplate.UnitFrame.CastTimer, 11)
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
            if BetterBlizzPlatesDB.showGuildNames then
                local guildName, guildRankName, guildRankIndex = GetGuildInfo(nameplate.UnitFrame.unit)
                if guildName then
                    frame.guildName:SetText("<"..guildName..">")
                    if BetterBlizzPlatesDB.guildNameColor then
                        local color = BetterBlizzPlatesDB.guildNameColorRGB or {0, 1, 0}
                        frame.guildName:SetTextColor(unpack(color))
                    else
                        frame.guildName:SetTextColor(frame.name:GetTextColor())
                    end
                    frame.guildName:SetPoint("TOP", frame.name, "BOTTOM", 0, 0)
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
                BBP.QuestIndicator()
            end
        end

        -- Hide focus marker after testing
        if BetterBlizzPlatesDB.focusTargetIndicator or not BetterBlizzPlatesDB.focusTargetIndicatorTestMode then
            if frame.focusTargetIndicator then
                frame.focusTargetIndicator:Hide()
            end
            if BetterBlizzPlatesDB.focusTargetIndicator then
                BBP.FocusTargetIndicator()
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
    end
end

hooksecurefunc(NamePlateDriverFrame, "OnUnitFactionChanged", function(self,unit)
    if not string.match(unit, "nameplate") then return end
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
            BBP.ArenaIndicatorCaller(frame, BetterBlizzPlatesDB)
        end
    --end
end

function BBP.ApplySettingsToAllNameplates()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        --local frame = nameplate.UnitFrame

        if nameplate.driverFrame.classNamePlateMechanicFrame then
            nameplate.driverFrame.classNamePlateMechanicFrame:SetScale(BetterBlizzPlatesDB.nameplateResourceScale or 0.7)
        end
    end
end

--#################################################################################################
-- Nameplate updater etc
function BBP.ConsolidatedUpdateName(frame)
    if not frame or frame:IsForbidden() or frame:IsProtected() then return end
    local removeRealmName = BetterBlizzPlatesDB.removeRealmNames
    local anonModeOn = BetterBlizzPlatesDB.anonMode
    if removeRealmName then
        BBP.RemoveRealmName(frame)
    end

    -- Further processing only for nameplate units
    if not frame.unit or not frame.unit:find("nameplate") then return end

    -- Class color and scale names depending on their reaction
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
    BBP.ClassColorAndScaleNames(frame)

    local arenaIndicator = not BetterBlizzPlatesDB.arenaIndicatorModeOff or not BetterBlizzPlatesDB.partyIndicatorModeOff or BetterBlizzPlatesDB.arenaIndicatorTestMode
    local absorbIndicator = BetterBlizzPlatesDB.absorbIndicator
    local combatIndicator = BetterBlizzPlatesDB.combatIndicator
    local petIndicator = BetterBlizzPlatesDB.petIndicator
    local healerIndicator = BetterBlizzPlatesDB.healerIndicatorTestMode or BetterBlizzPlatesDB.healerIndicator
    local colorNpc = BetterBlizzPlatesDB.colorNPCName
    local friendlyNameColor = BetterBlizzPlatesDB.friendlyNameColor and BetterBlizzPlatesDB.friendlyHealthBarColor
    local totemIndicatorTest = BetterBlizzPlatesDB.totemIndicatorTestMode and frame.randomColor
    local totemIndicator = BetterBlizzPlatesDB.totemIndicator
    local hideFriendlyNameText = BetterBlizzPlatesDB.hideFriendlyNameText
    local hideEnemyNameText = BetterBlizzPlatesDB.hideEnemyNameText
    --local showGuildNames = BetterBlizzPlatesDB.showGuildNames
    local colorName = BetterBlizzPlatesDB.targetIndicatorColorName and BetterBlizzPlatesDB.targetIndicator

    if anonModeOn then
        anonMode(frame)
    end
    -- Use arena numbers
    if arenaIndicator then
        BBP.ArenaIndicatorCaller(frame, BetterBlizzPlatesDB)
    end

    -- Handle absorb indicator and reset absorb text if it exists
    if absorbIndicator then
        BBP.AbsorbIndicator(frame)
    end

    -- Show out of combat icon
    if combatIndicator then
        BBP.CombatIndicator(frame)
    end

    -- Show hunter pet icon
    if petIndicator then
        BBP.PetIndicator(frame)
    end
    -- Raidmarker change
    --if BetterBlizzPlatesDB.raidmarkIndicator then
        --BBP.ApplyRaidmarkerChanges(nameplate)
    --end
    -- Show healer icon
    if healerIndicator then
        BBP.HealerIndicator(frame)
    end

    -- Show Class Indicator
    if classIndicator then
        BBP.ClassIndicator(frame)
    end

    -- Color NPC
    if colorNpc then
        BBP.ColorNPCs(frame)
    end

    if friendlyNameColor then
        local isFriend = isFriend and not UnitIsUnit("player", frame.unit)
        local color = BetterBlizzPlatesDB.friendlyHealthBarColorRGB or {0, 1, 0}
        if isFriend then
            frame.name:SetTextColor(unpack(color))
        end
    end

    -- Color nameplate and pick random name or hide name during totem tester
    if totemIndicatorTest then
        frame.name:SetVertexColor(unpack(frame.randomColor))
        local shiftNameDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
        if shiftNameDown then
            frame.name:SetText("")
        else
            frame.name:SetText(frame.randomName)
        end
    end

    -- Ensure totem nameplate color is correct
    if totemIndicator then
        local npcID = BBP.GetNPCIDFromGUID(UnitGUID(frame.unit))
        if BetterBlizzPlatesDB.totemIndicatorNpcList[npcID] and BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color then
            local showEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
            if not isFriend then
                frame.healthBar:SetStatusBarColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
            else
                if not showEnemyOnly then
                    frame.healthBar:SetStatusBarColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                    frame.name:SetVertexColor(unpack(BetterBlizzPlatesDB.totemIndicatorNpcList[npcID].color))
                end
            end
        end
    end

    if colorName then
        local color = BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB
        local isTarget = UnitIsUnit(frame.unit, "target")
        if isTarget then
            frame.name:SetVertexColor(unpack(color))
        end
    end

    if hideFriendlyNameText or hideEnemyNameText then
        frame.name:SetAlpha(((hideFriendlyNameText and isFriend) or (hideEnemyNameText and not isFriend)) and 0 or 1)
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

local isInPvEContent = false
local hideFriendlyCastbar
-- Function to update the instance status
local function UpdateInstanceStatus()
    local inInstance, instanceType = IsInInstance()
    isInPvEContent = inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario")
end

-- Function to set the nameplate behavior
local function SetNameplateBehavior()
    if InCombatLockdown() then
        C_Timer.After(1, SetNameplateBehavior)
    else
        if isInPvEContent then
            SetCVar('nameplateShowOnlyNames', 1)
            BBP.ApplyNameplateWidth()
        else
            SetCVar('nameplateShowOnlyNames', hideFriendlyCastbar and 1 or 0)
            BBP.ApplyNameplateWidth()
        end
    end
end

-- Event handler function
local function CheckIfInInstance(self, event, ...)
    hideFriendlyCastbar = BetterBlizzPlatesDB.hideFriendlyCastbar
    UpdateInstanceStatus()
    SetNameplateBehavior()
end

function BBP.CheckIfInInstanceCaller()
    CheckIfInInstance()
end

local hookedGetNamePlateTypeFromUnit = false

local function HideHealthbarInPvEMagic()
    if BetterBlizzPlatesDB.friendlyHideHealthBar and not hookedGetNamePlateTypeFromUnit then
        -- Set the hook flag
        hookedGetNamePlateTypeFromUnit = true

        -- Register events
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        eventFrame:SetScript("OnEvent", CheckIfInInstance)

        hooksecurefunc(
            NamePlateDriverFrame,
            'GetNamePlateTypeFromUnit',
            function(_, unit)
                local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
                if not isFriend then
                    setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                    setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                else
                    setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
                    if hideFriendlyCastbar then
                        setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                    else
                        setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideCastbar')
                    end
                end
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

    CheckForUpdate()

    _, playerClass = UnitClass("player")
    playerClassColor = RAID_CLASS_COLORS[playerClass]

    if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
        BBP.RunAuraModule()
    end

    --if BetterBlizzPlatesDB.enableCastbarCustomization then
        --BBP.HookDefaultCompactNamePlateFrameAnchorInternal()
    --end


    BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, BetterBlizzPlatesDB.defaultLargeFontSize)
    BBP.SetFontBasedOnOption(SystemFont_NamePlate, BetterBlizzPlatesDB.defaultFontSize)
    BBP.SetFontBasedOnOption(SystemFont_LargeNamePlateFixed, BetterBlizzPlatesDB.defaultLargeFontSize)
    BBP.SetFontBasedOnOption(SystemFont_NamePlateFixed, BetterBlizzPlatesDB.defaultFontSize)

    BBP.ApplyNameplateWidth()

    C_Timer.After(1, function()
        BBP.ApplySettingsToAllNameplates()

        if BetterBlizzPlatesDB.executeIndicatorScale <= 0 then --had a slider with borked values
            BetterBlizzPlatesDB.executeIndicatorScale = 1     --this will fix it for every user who made the error while bug was live
        end
    end)

    SetCVarsOnLogin()
    BBP.InitializeInterruptSpellID() --possibly not needed, talent events seem to always run on login?

    -- Re-open options when clicking reload button
    if BetterBlizzPlatesDB.reopenOptions then
        InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
        BetterBlizzPlatesDB.reopenOptions = false
    end
    BBP.CreateUnitAuraEventFrame()

    -- Modify the hooksecurefunc based on instance status
    HideHealthbarInPvEMagic()
end)

local nameplateWidthOnEnterWorld = CreateFrame("Frame")
nameplateWidthOnEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
nameplateWidthOnEnterWorld:SetScript("OnEvent", BBP.ApplyNameplateWidth)

-- Slash command
SLASH_BBP1 = "/bbp"
SlashCmdList["BBP"] = function(msg)
    local command = string.lower(msg)
    if command == "news" then
        NewsUpdateMessage()
    elseif command == "nahj" then
        StaticPopup_Show("BBP_CONFIRM_NAHJ_PROFILE")
    elseif command == "reset" then
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    elseif command == "fixnameplates" then
        StaticPopup_Show("CONFIRM_FIX_NAMEPLATES_BBP")
    else
        InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
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
    BBP.ToggleFriendlyNameplatesInArena()
    BBP.ToggleAbsorbIndicator()
    BBP.ToggleCombatIndicator()
    BBP.ToggleExecuteIndicator()
    BBP.ToggleTargetIndicator()
    BBP.ToggleFocusTargetIndicator()
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
            BetterBlizzPlatesDB.defaultLargeNamePlateFont, BetterBlizzPlatesDB.defaultLargeFontSize, BetterBlizzPlatesDB.defaultLargeNamePlateFontFlags = SystemFont_LargeNamePlate:GetFont()
            BetterBlizzPlatesDB.defaultNamePlateFont, BetterBlizzPlatesDB.defaultFontSize, BetterBlizzPlatesDB.defaultNamePlateFontFlags = SystemFont_NamePlate:GetFont()
            FetchAndSaveValuesOnFirstLogin()

            if not BetterBlizzPlatesDB.auraWhitelistColorsUpdated then
                UpdateAuraColorsToGreen() --update default yellow text to green for new color featur
                BetterBlizzPlatesDB.auraWhitelistColorsUpdated = true
            end

            if not BetterBlizzPlatesDB.auraWhitelistAlphaUpdated then
                AddAlphaValuesToAuraColors()
                BetterBlizzPlatesDB.auraWhitelistAlphaUpdated = true
            end

            TurnOnEnabledFeaturesOnLogin()
            BBP.InitializeOptions()
        end
    end
end)

local function OnVariablesLoaded(self, event)
    if event == "VARIABLES_LOADED" then
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