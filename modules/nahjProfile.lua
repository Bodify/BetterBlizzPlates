-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

local nahjAuraWhitelist = {
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["comment"] = "",
        ["name"] = "Cenarion Ward",
    }, -- [1]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["comment"] = "",
        ["name"] = "Shadow Dance",
    }, -- [2]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["comment"] = "",
        ["name"] = "Battle Stance",
    }, -- [3]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["comment"] = "",
        ["name"] = "Lifebloom",
    }, -- [4]
}

local nahjTotemList = {
    [60561] = {
        ["important"] = false,
        ["name"] = "Earthgrab Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.75, -- [1]
            0.31, -- [2]
            0.1, -- [3]
        },
        ["duration"] = 30,
        ["icon"] = 136100,
        ["size"] = 24,
    },
    [78001] = {
        ["important"] = false,
        ["name"] = "Cloudburst Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.39, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 971076,
        ["size"] = 24,
    },
    [104818] = {
        ["important"] = true,
        ["name"] = "Ancestral Protection Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 33,
        ["icon"] = 136080,
        ["size"] = 30,
    },
    [62982] = {
        ["important"] = false,
        ["name"] = "Mindbender",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 136214,
        ["size"] = 24,
    },
    [89] = {
        ["important"] = false,
        ["name"] = "Infernal",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 30,
        ["icon"] = 136219,
        ["size"] = 24,
    },
    [61245] = {
        ["important"] = true,
        ["name"] = "Capacitor Totem",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 2,
        ["icon"] = 136013,
        ["size"] = 30,
    },
    [194117] = {
        ["important"] = false,
        ["name"] = "Stoneskin Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.78, -- [1]
            0.49, -- [2]
            0.35, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 4667425,
        ["size"] = 24,
    },
    [59764] = {
        ["important"] = true,
        ["name"] = "Healing Tide Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.39, -- [3]
        },
        ["duration"] = 10,
        ["icon"] = 538569,
        ["size"] = 30,
    },
    [5913] = {
        ["important"] = true,
        ["name"] = "Tremor Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.49, -- [1]
            0.9, -- [2]
            0.08, -- [3]
        },
        ["duration"] = 13,
        ["icon"] = 136108,
        ["size"] = 30,
    },
    [53006] = {
        ["important"] = true,
        ["name"] = "Spirit Link Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 6,
        ["icon"] = 237586,
        ["size"] = 30,
    },
    [100943] = {
        ["important"] = true,
        ["name"] = "Earthen Wall Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.78, -- [1]
            0.49, -- [2]
            0.35, -- [3]
        },
        ["duration"] = 18,
        ["icon"] = 136098,
        ["size"] = 30,
    },
    [5925] = {
        ["important"] = true,
        ["name"] = "Grounding Totem",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0, -- [2]
            1, -- [3]
        },
        ["duration"] = 3,
        ["icon"] = 136039,
        ["size"] = 30,
    },
    [105427] = {
        ["important"] = false,
        ["name"] = "Skyfury Totem",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.27, -- [2]
            0.59, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 135829,
        ["size"] = 24,
    },
    [97369] = {
        ["important"] = false,
        ["name"] = "Liquid Magma Totem",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 6,
        ["icon"] = 971079,
        ["size"] = 24,
    },
    [194118] = {
        ["important"] = false,
        ["name"] = "Tranquil Air Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 20,
        ["icon"] = 538575,
        ["size"] = 24,
    },
    [5923] = {
        ["important"] = false,
        ["name"] = "Poison Cleansing Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.49, -- [1]
            0.9, -- [2]
            0.08, -- [3]
        },
        ["duration"] = 9,
        ["icon"] = 136070,
        ["size"] = 24,
    },
    [107024] = {
        ["important"] = true,
        ["name"] = "Fel Lord",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 1113433,
        ["size"] = 30,
    },
    [179867] = {
        ["important"] = false,
        ["name"] = "Static Field Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 6,
        ["icon"] = 1020304,
        ["size"] = 24,
    },
    [2630] = {
        ["important"] = false,
        ["name"] = "Earthbind Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.78, -- [1]
            0.51, -- [2]
            0.39, -- [3]
        },
        ["duration"] = 30,
        ["icon"] = 136102,
        ["size"] = 24,
    },
    [6112] = {
        ["name"] = "Windfury Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.08, -- [1]
            0.82, -- [2]
            0.78, -- [3]
        },
        ["important"] = false,
        ["icon"] = 136114,
        ["size"] = 24,
    },
    [119052] = {
        ["important"] = true,
        ["name"] = "War Banner",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0, -- [2]
            1, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 603532,
        ["size"] = 30,
    },
    [3527] = {
        ["important"] = false,
        ["name"] = "Healing Stream Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0, -- [1]
            1, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 18,
        ["icon"] = 135127,
        ["size"] = 24,
    },
    [135002] = {
        ["important"] = true,
        ["name"] = "Tyrant",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 2065628,
        ["size"] = 30,
    },
    [114565] = {
        ["important"] = true,
        ["name"] = "Guardian of the Forgotten Queen",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0, -- [2]
            1, -- [3]
        },
        ["duration"] = 10,
        ["icon"] = 135919,
        ["size"] = 30,
    },
    [105451] = {
        ["important"] = true,
        ["name"] = "Counterstrike Totem",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.27, -- [2]
            0.59, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 511726,
        ["size"] = 30,
    },
    [196111] = {
        ["important"] = false,
        ["name"] = "Pit Lord",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 10,
        ["icon"] = 236423,
        ["size"] = 24,
    },
    [179193] = {
        ["important"] = true,
        ["name"] = "Fel Obelisk",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 15,
        ["icon"] = 1718002,
        ["size"] = 30,
    },
    [107100] = {
        ["important"] = true,
        ["name"] = "Observer",
        ["hideIcon"] = false,
        ["color"] = {
            1, -- [1]
            0.69, -- [2]
            0, -- [3]
        },
        ["duration"] = 20,
        ["icon"] = 538445,
        ["size"] = 30,
    },
    [101398] = {
        ["important"] = true,
        ["name"] = "Psyfiend",
        ["hideIcon"] = false,
        ["color"] = {
            0.49, -- [1]
            0, -- [2]
            1, -- [3]
        },
        ["duration"] = 12,
        ["icon"] = 537021,
        ["size"] = 35,
    },
    [10467] = {
        ["important"] = false,
        ["name"] = "Mana Tide Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.08, -- [1]
            0.82, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 8,
        ["icon"] = 4667424,
        ["size"] = 24,
    },
    [97285] = {
        ["important"] = false,
        ["name"] = "Wind Rush Totem",
        ["hideIcon"] = false,
        ["color"] = {
            0.08, -- [1]
            0.82, -- [2]
            0.78, -- [3]
        },
        ["duration"] = 18,
        ["icon"] = 538576,
        ["size"] = 24,
    },
}

local function updateAuraList(nahjList, userList)
    for _, newEntry in ipairs(nahjList) do
        local isEntryExists = false
        local entryId = newEntry.id or ""
        local entryName = newEntry.name or ""

        for _, existingEntry in ipairs(userList) do
            local existingId = existingEntry.id or ""
            local existingName = existingEntry.name or ""

            if (entryId ~= "" and entryId == existingId) or (entryName ~= "" and entryName == existingName) then
                isEntryExists = true
                break
            end
        end

        if not isEntryExists then
            local entryToAdd = {}
            if entryName ~= "" then
                entryToAdd.name = entryName
            else
                entryToAdd.id = entryId
                entryToAdd.name = ""
            end
            entryToAdd.entryColors = newEntry.entryColors
            entryToAdd.flags = newEntry.flags
            entryToAdd.comment = newEntry.comment or ""
            table.insert(userList, entryToAdd)
        end
    end
end

function BBP.NahjProfile()
    updateAuraList(nahjAuraWhitelist, BetterBlizzPlatesDB.auraWhitelist)
    updateAuraList(nahjTotemList, BetterBlizzPlatesDB.totemIndicatorNpcList)

    local db = BetterBlizzPlatesDB
	db.classIndicatorFriendlyScale = 1
	db.nameplateAuraTaller = false
	db.totemIndicatorScale = 1.299999952316284
	db.NamePlateClassificationScale = "1.25"
	db.defaultLargeNamePlateFont = "Fonts\\FRIZQT__.TTF"
	db.executeIndicatorAnchor = "LEFT"
	db.arenaIdYPos = 0
	db.nameplateFriendlyWidthScale = 60
	db.nameplatePlayerLargerScale = "1.8"
	db.nameplateDefaultFriendlyHeight = 45
	db.friendlyNpBuffFilterLessMinite = false
	db.otherNpdeBuffFilterWatchList = true
	db.castBarRecolorInterrupt = false
	db.customTextureFriendly = "Dragonflight (BBP)"
	db.classIndicatorXPos = 0
	db.colorNPCName = false
	db.absorbIndicatorYPos = 0
	db.targetIndicatorYPos = 0
	db.friendlyNpBuffFilterAll = false
	db.focusTargetIndicatorTexture = "Shattered DF (BBP)"
	db.classIndicatorFriendlyAnchor = "TOP"
	db.personalNpdeBuffEnable = false
	db.nameplateDefaultEnemyHeight = 45
	db.otherNpBuffFilterWatchList = true
	db.castbarEventsOn = true
	db.targetIndicatorScale = 1
	db.showNameplateCastbarTimer = true
	db.partyIndicatorModeOff = false
    db.interruptedByIndicator = true
	db.questIndicatorAnchor = "LEFT"
	db.otherNpdeBuffPandemicGlow = false
	db.otherNpdeBuffEnable = false
	db.castBarShieldAnchor = "LEFT"
	db.otherNpBuffBlueBorder = false
	db.combatIndicatorXPos = 0
	db.friendlyNpdeBuffFilterWatchList = false
	db.auraWhitelistColorsUpdated = true
	db.nameplateMinAlpha = "0.6"
	db.classIndicatorScale = 1
	db.focusTargetIndicatorColorNameplate = false
	db.reopenOptions = false
	db.hasSaved = true
	db.nameplateAuraWidthGap = 4
	db.otherNpdeBuffFilterBlizzard = true
	db.arenaIdAnchor = "TOP"
	db.NamePlateVerticalScale = "2.8"
	db.castBarDragonflightShield = true
	db.focusTargetIndicatorTestMode = false
	db.targetIndicatorTestMode = false
	db.absorbIndicator = true
	db.classIndicatorFriendlyXPos = 0
	db.arenaIndicatorModeOff = false
	db.friendlyNpBuffBlueBorder = false
	db.arenaIndicatorModeFour = true
	db.nameplateAuraSquare = false
	db.nameplateShowEnemyGuardians = "1"
	db.castBarEmphasisSparkHeight = 35
	db.nameplateEnemyHeight = 64.125
	db.nameplateAurasYPos = 0
	db.castBarEmphasisColor = false
	db.defaultNamePlateFont = "Fonts\\FRIZQT__.TTF"
	db.customFontSize = 12
	db.nameplateAurasCenteredAnchor = false
	db.questIndicatorYPos = 0
	db.friendlyNpBuffPurgeGlow = false
	db.nameplateShowFriendlyMinions = "1"
	db.arenaIdXPos = 0
	db.castBarShieldYPos = 0
	db.arenaIndicatorModeThree = false
	db.nameplateDefaultLargeEnemyHeight = 64.125
	db.castBarTextScale = 1
	db.otherNpdeBuffFilterAll = false
	db.colorNPC = false
	db.classIndicatorAnchor = "TOP"
	db.focusTargetIndicatorScale = 1
	db.questIndicator = false
	db.executeIndicatorXPos = 0
	db.showNameplateTargetText = false
	db.partySpecScale = 1
	db.personalNpdeBuffFilterLessMinite = false
	db.friendlyNpdeBuffFilterAll = false
	db.partyIDScale = 1
	db.nameplateShowFriendlyGuardians = "1"
	db.totemIndicatorHideNameAndShiftIconDown = false
	db.petIndicator = true
	db.enemyNameplateHealthbarHeight = 10.8
	db.customFont = "Yanone (BBP)"
	db.nameplateSelfHeight = 45.00000762939453
	db.defaultLargeNamePlateFontFlags = ""
	db.personalNpBuffEnable = true
	db.nameplateAuraRelativeAnchor = "TOPLEFT"
	db.combatIndicatorEnemyOnly = true
	db.totemIndicatorAnchor = "TOP"
	db.healerIndicatorYPos = 0
	db.totemIndicatorYPos = 0
	db.nameplateLargerScale = "1.2"
	db.defaultNamePlateFontFlags = ""
	db.fadeOutNPCsAlpha = 0.2
	db.castBarRecolor = false
	db.combatIndicator = true
	db.nameplateMaxAlpha = "1.0"
	db.useCustomFont = false
	db.classIndicatorFriendlyYPos = 0
	db.otherNpdeBuffFilterLessMinite = false
	db.classIndicatorYPos = 0
	db.defaultFontSize = 9
	db.combatIndicatorAnchor = "CENTER"
	db.nameplateAuraHeightGap = 4
	db.hideNPC = false
	db.nameplateHorizontalScale = "1.4"
	db.healerIndicatorEnemyOnly = false
	db.executeIndicatorFriendly = false
	db.hideNameplateAuras = false
	db.combatIndicatorPlayersOnly = true
	db.friendlyNameColor = false
	db.totemIndicatorDefaultCooldownTextSize = 0.85
	db.arenaModeSettingKey = "4: Replace name with spec + ID on top"
	db.arenaSpecScale = 1
	db.combatIndicatorArenaOnly = true
	db.nameplateOverlapH = "0.8"
	db.focusTargetIndicatorYPos = 0
	db.castBarEmphasisText = false
	db.nameplateFriendlyWidth = 60
	db.petIndicatorScale = 1
	db.personalNpdeBuffFilterAll = false
	db.totemIndicatorTestMode = false
	db.friendlyHideHealthBarNpc = true
	db.totemIndicatorGlowOff = false
	db.nameplateAuraScale = 1
	db.executeIndicatorThreshold = 40
	db.totemIndicatorScaleUpImportant = true
	db.nameplateShowEnemyPets = "1"
	db.combatIndicatorScale = 1
	db.personalNpBuffFilterAll = false
	db.partyModeSettingKey = "2: Arena ID on top of name"
	db.hideTargetHighlight = true
	db.focusTargetIndicatorXPos = 0
	db.partyIndicatorModeFour = false
	db.arenaSpecXPos = 0
	db.friendlyNpdeBuffEnable = false
	db.arenaIndicatorModeFive = false
	db.setCVarAcrossAllCharacters = true
	db.combatIndicatorYPos = 0
	db.enableCastbarEmphasis = false
	db.healerIndicator = false
	db.hideDefaultPersonalNameplateAuras = false
	db.shortArenaSpecName = true
	db.classColorPersonalNameplate = true
	db.friendlyNameplateClickthrough = true
	db.otherNpdeBuffFilterOnlyMe = false
	db.arenaIndicatorTestMode = false
	db.absorbIndicatorEnemyOnly = false
	db.nameplateDefaultLargeFriendlyWidth = 154
	db.personalNpdeBuffFilterWatchList = true
	db.nameplateShowFriendlyTotems = "1"
	db.castBarEmphasisOnlyInterruptable = false
	db.castBarShieldXPos = 0
	db.largeNameplates = true
	db.healerIndicatorAnchor = "TOPRIGHT"
	db.executeIndicatorShowDecimal = true
	db.castBarEmphasisIconScale = 2
	db.nameplateShowEnemyMinions = "1"
	db.partyIndicatorModeFive = false
	db.petIndicatorAnchor = "CENTER"
	db.classIndicatorEnemy = true
	db.absorbIndicatorScale = 1
	db.partyIndicatorModeOne = false
	db.classIndicator = false
	db.nameplateAurasNoNameYPos = 0
	db.castBarEmphasisHeightValue = 24
	db.questIndicatorXPos = 0
	db.nameplateResourceScale = 0.7
	db.healerIndicatorXPos = 0
	db.enemyNameScale = 1
	db.testAllEnabledFeatures = false
	db.castBarIconXPos = 0
	db.nameplateOccludedAlphaMult = "0.4"
	db.nameplateFriendlyHeight = 1
	db.nameplateShowEnemyTotems = "1"
	db.guildNameScale = 1
	db.classIconColorBorder = true
	db.wasOnLoadingScreen = false
	db.executeIndicatorNotOnFullHp = false
	db.focusTargetIndicatorAnchor = "TOPRIGHT"
	db.raidmarkIndicatorScale = 1
	db.nameplateShowEnemyMinus = "0"
	db.friendlyClassColorName = true
	db.executeIndicatorScale = 1
	db.customTexture = "Dragonflight (BBP)"
	db.executeIndicator = false
	db.fadeOutNPC = false
	db.healerIndicatorScale = 1
	db.nameplateDefaultFriendlyWidth = 110
	db.NamePlateVerticalScaleScale = 2.8
	db.nameplateAuraRowAmount = 5
	db.healerIndicatorTestMode = false
	db.nameplateSelectedScale = "1.25"
	db.nameplateEnemyWidth = 135
	db.arenaIndicatorModeOne = false
	db.nameplateMinScale = "1"
	db.questIndicatorScale = 1
	db.totemIndicator = true
	db.absorbIndicatorOnPlayersOnly = true
	db.enableCastbarCustomization = false
	db.raidmarkIndicatorXPos = 0
	db.petIndicatorTestMode = false
	db.totemIndicatorEnemyOnly = true
	db.castBarEmphasisHealthbarColor = false
	db.raidmarkIndicatorYPos = 0
	db.executeIndicatorYPos = 0
	db.otherNpBuffFilterLessMinite = false
	db.partyIndicatorModeTwo = true
	db.showTotemIndicatorCooldownSwipe = true
	db.nameplateMaxScale = "1.1"
	db.hideNPCArenaOnly = false
	db.friendlyNpBuffFilterWatchList = false
	db.showCastbarIfTarget = false
	db.enableNameplateAuraCustomisation = true
	db.nameplateMotionSpeed = "0.05"
	db.enemyClassColorName = true
	db.nameplateMotion = "0"
	db.arenaSpecAnchor = "TOP"
	db.totemIndicatorXPos = 0
	db.questIndicatorTestMode = false
	db.absorbIndicatorXPos = 0
	db.nameplateMinAlphaDistance = "10"
	db.nameplateSelfWidth = 154.0000305175781
	db.targetIndicator = true
	db.arenaSpecYPos = 0
	db.removeRealmNames = true
	db.friendlyNameScale = 1
	db.nameplateDefaultLargeFriendlyHeight = 64.125
	db.absorbIndicatorAnchor = "LEFT"
	db.otherNpBuffEmphasisedBorder = false
	db.nameplateResourceOnTarget = "0"
	db.friendlyNpdeBuffFilterLessMinite = false
	db.otherNpBuffEnable = true
	db.arenaIndicatorModeTwo = false
	db.nameplateOverlapV = "1.3600000143051"
	db.nameplateEnemyWidthScale = 135
	db.defaultLargeFontSize = 12
	db.castBarEmphasisHeight = false
	db.combatIndicatorSap = true
	db.personalNpBuffFilterWatchList = true
	db.otherNpBuffFilterAll = false
	db.arenaIDScale = 1
	db.nameplateShowFriendlyPets = "1"
	db.focusTargetIndicator = false
	db.castBarIconYPos = 0
	db.executeIndicatorTestMode = false
	db.nameplateDefaultEnemyWidth = 110
	db.friendlyNpdeBuffFilterOnlyMe = false
	db.auraWhitelistAlphaUpdated = true
	db.partyIndicatorModeThree = false
	db.raidmarkIndicator = false
	db.absorbIndicatorTestMode = false
	db.castBarShieldScale = 1
	db.otherNpBuffPurgeGlow = false
	db.friendlyNpBuffEnable = false
	db.nameplateAuraRowAbove = true
	db.petIndicatorXPos = 0
	db.nameplateDefaultLargeEnemyWidth = 154
	db.defaultNpAuraCdSize = 0.5
	db.friendlyNpBuffEmphasisedBorder = false
	db.castBarHeight = 18.8
	db.personalNpBuffFilterBlizzard = true
	db.targetIndicatorXPos = 0
	db.totemIndicatorScaleScale = 1.299999952316284
	db.friendlyNpBuffFilterOnlyMe = false
	db.personalNpBuffFilterLessMinite = false
	db.nameplateGlobalScale = "1.0"
	db.nameplateAuraAnchor = "BOTTOMLEFT"
	db.useCustomTextureForBars = false
	db.executeIndicatorAlwaysOn = false
	db.castBarEmphasisTextScale = 2
	db.nameplateMaxAlphaDistance = "40"
	db.showCastBarIconWhenNoninterruptible = false
	db.raidmarkIndicatorAnchor = "TOP"
	db.castBarIconAnchor = "LEFT"
	db.petIndicatorYPos = 0
	db.castBarIconScale = 1
	db.classIndicatorFriendly = true
	db.friendlyNpdeBuffFilterBlizzard = false
	db.nameplateAurasXPos = 0
	db.targetIndicatorAnchor = "TOP"
	db.maxAurasOnNameplate = 12
	db.friendlyNameplatesOnlyInArena = true
	db.castBarEmphasisIcon = false
	db.hideNPCWhitelistOn = false
end