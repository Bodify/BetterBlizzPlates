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
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0.2156862914562225,
            },
        },
        ["name"] = "Subterfuge",
        ["comment"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Heart of the Wild",
        ["comment"] = "",
    }, -- [6]
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
        ["size"] = 30,
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
	db.useCustomTextureForEnemy = true
	db.totemIndicatorScale = 2
	db.NamePlateClassificationScale = "1.25"
	db.defaultLargeNamePlateFont = "Fonts\\FRIZQT__.TTF"
	db.executeIndicatorAnchor = "LEFT"
	db.arenaIdYPos = 0
	db.nameplateFriendlyWidthScale = 60
	db.nameplatePlayerLargerScale = "1.8"
	db.nameplateDefaultFriendlyHeight = 45
	db.friendlyNpBuffFilterLessMinite = false
	db.otherNpdeBuffFilterWatchList = true
	db.castBarInterruptHighlighterColorDontInterrupt = true
	db.castBarRecolorInterrupt = false
	db.customTextureFriendly = "Dragonflight (BBP)"
	db.classIndicatorXPos = 0
	db.colorNPCName = false
	db.absorbIndicatorYPos = 0
	db.castBarInterruptHighlighter = true
	db.targetIndicatorYPos = 0
	db.friendlyNpBuffFilterAll = false
	db.focusTargetIndicatorTexture = "Shattered DF (BBP)"
	db.classIndicatorFriendlyAnchor = "TOP"
	db.personalNpdeBuffEnable = false
	db.nameplateDefaultEnemyHeight = 45
	db.useCustomCastbarTexture = false
	db.otherNpBuffFilterWatchList = true
	db.castbarEventsOn = true
	db.targetIndicatorScale = 1
	db.showNameplateCastbarTimer = true
	db.partyIndicatorModeOff = false
	db.questIndicatorAnchor = "LEFT"
	db.otherNpdeBuffPandemicGlow = false
	db.otherNpdeBuffEnable = false
	db.castBarShieldAnchor = "LEFT"
	db.otherNpBuffBlueBorder = false
	db.combatIndicatorXPos = 0
	db.friendlyNpdeBuffFilterWatchList = false
	db.auraWhitelistColorsUpdated = true
	db.nameplateMinAlpha = "1"
	db.classIndicatorScale = 1
	db.focusTargetIndicatorColorNameplate = false
	db.reopenOptions = false
	db.hasSaved = true
	db.nameplateAuraWidthGap = 4
	db.otherNpdeBuffFilterBlizzard = true
	db.arenaIdAnchor = "TOP"
	db.NamePlateVerticalScale = "2.8"
	db.castBarDragonflightShield = true
	db.castBarNoninterruptibleColor = {
		0.4, -- [1]
		0.4, -- [2]
		0.4, -- [3]
	}
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
	db.nameplateMinAlphaScale = 1
	db.friendlyNpBuffPurgeGlow = false
	db.nameplateShowFriendlyMinions = "0"
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
	db.nameplateShowFriendlyGuardians = "0"
	db.totemIndicatorHideNameAndShiftIconDown = false
	db.petIndicator = true
	db.enemyNameplateHealthbarHeight = 10.8
	db.customFont = "Yanone (BBP)"
	db.nameplateSelfHeight = 45
	db.defaultLargeNamePlateFontFlags = ""
	db.personalNpBuffEnable = true
	db.nameplateAuraRelativeAnchor = "TOPLEFT"
	db.combatIndicatorEnemyOnly = true
	db.totemIndicatorAnchor = "TOP"
	db.healerIndicatorYPos = 0
	db.totemIndicatorYPos = 0
	db.nameplateLargerScale = "1.1"
	db.defaultNamePlateFontFlags = ""
	db.fadeOutNPCsAlpha = 0.3
	db.castBarRecolor = false
	db.castBarChanneledColor = {
		0.4862745404243469, -- [1]
		1, -- [2]
		0.294117659330368, -- [3]
		1, -- [4]
	}
	db.combatIndicator = true
	db.nameplateMaxAlpha = "1.0"
	db.useCustomFont = false
	db.classIndicatorFriendlyYPos = 0
	db.otherNpdeBuffFilterLessMinite = false
	db.classIndicatorYPos = 0
	db.castBarInterruptHighlighterInterruptRGB = {
		0, -- [1]
		1, -- [2]
		0.8784314393997192, -- [3]
		1, -- [4]
	}
	db.defaultFontSize = 9
	db.combatIndicatorAnchor = "CENTER"
	db.nameplateAuraHeightGap = 4
	db.hideNPC = true
	db.nameplateHorizontalScale = "1.4"
	db.healerIndicatorEnemyOnly = false
	db.normalCastbarForEmpoweredCasts = true
	db.executeIndicatorFriendly = false
	db.hideNameplateAuras = false
	db.combatIndicatorPlayersOnly = true
	db.friendlyNameColor = false
	db.totemIndicatorDefaultCooldownTextSize = 0.9
	db.arenaModeSettingKey = "4: Replace name with spec + ID on top"
	db.arenaSpecScale = 1
	db.combatIndicatorArenaOnly = true
	db.nameplateOverlapH = "0.8"
	db.focusTargetIndicatorYPos = 0
	db.healerIndicatorEnemyScale = 1
	db.castBarEmphasisText = false
	db.nameplateFriendlyWidth = 60
	db.nameplateShowEnemyTotems = "1"
	db.raidmarkIndicatorAnchor = "TOP"
	db.castBarInterruptHighlighterStartPercentage = 15
	db.petIndicatorScale = 1
	db.personalNpdeBuffFilterAll = false
	db.nameplateAurasNoNameYPos = 0
	db.totemIndicatorTestMode = false
	db.friendlyHideHealthBarNpc = true
	db.totemIndicatorGlowOff = false
	db.nameplateAuraScale = 1
	db.targetIndicatorXPos = 0
	db.arenaSpecYPos = 0
	db.nameplateShowEnemyPets = "1"
	db.focusTargetIndicatorXPos = 0
	db.interruptedByIndicator = true
	db.combatIndicatorScale = 1
	db.personalNpBuffFilterAll = false
	db.partyModeSettingKey = "2: Arena ID on top of name"
	db.castBarInterruptHighlighterDontInterruptRGB = {
		0, -- [1]
		1, -- [2]
		0.8784314393997192, -- [3]
		1, -- [4]
	}
	db.targetIndicatorTexture = "Checkered (BBP)"
	db.castBarEmphasisOnlyInterruptable = false
	db.partyIndicatorModeFour = false
	db.arenaSpecXPos = 0
	db.friendlyNpdeBuffEnable = false
	db.arenaIndicatorModeFive = false
	db.targetIndicatorAnchor = "TOP"
	db.enableCastbarEmphasis = false
	db.healerIndicator = false
	db.shortArenaSpecName = true
	db.classColorPersonalNameplate = true
	db.partyIndicatorModeFive = false
	db.friendlyNameplateClickthrough = true
	db.otherNpdeBuffFilterOnlyMe = false
	db.friendlyNpBuffEmphasisedBorder = false
	db.hideNPCArenaOnly = false
	db.hideTargetHighlight = true
	db.arenaIndicatorTestMode = false
	db.customTexture = "Dragonflight (BBP)"
	db.nameplateDefaultLargeFriendlyWidth = 154
	db.personalNpdeBuffFilterWatchList = true
	db.nameplateMinScale = "1"
	db.castBarHeight = 18.8
	db.nameplateAurasXPos = 0
	db.petIndicatorYPos = 0
	db.nameplateAuraRowAmount = 5
	db.castBarHeightHeight = 18.8
	db.castBarShieldXPos = 0
	db.castBarEmphasisIcon = false
	db.healerIndicatorAnchor = "TOPRIGHT"
	db.executeIndicatorShowDecimal = true
	db.nameplateShowEnemyMinus = "0"
	db.executeIndicator = false
	db.castBarEmphasisIconScale = 2
	db.fadeOutNPC = true
	db.nameplateShowEnemyMinions = "1"
	db.castBarInterruptHighlighterEndPercentage = 85
	db.nameplateSelfWidth = 154
	db.raidmarkIndicator = false
	db.petIndicatorAnchor = "CENTER"
	db.nameplateSelectedScale = "1.25"
	db.castBarEmphasisHealthbarColor = false
	db.partyIndicatorModeOne = false
	db.classIconSquareBorderFriendly = true
	db.totemIndicatorEnemyOnly = true
	db.nameplateShowFriendlyTotems = "1"
	db.castBarEmphasisHeightValue = 24
	db.questIndicatorXPos = 0
	db.questIndicatorScale = 1
	db.healerIndicatorXPos = 0
	db.enemyNameScale = 1
	db.focusTargetIndicatorColorNameplateRGB = {
		1, -- [1]
		1, -- [2]
		1, -- [3]
	}
	db.castBarIconXPos = 0
	db.nameplateOccludedAlphaMult = "0.4"
	db.enableCastbarCustomization = true
	db.petIndicatorTestMode = false
	db.nameplateResourceScale = 0.7
	db.classIconColorBorder = true
	db.combatIndicatorSap = true
	db.executeIndicatorNotOnFullHp = false
	db.focusTargetIndicatorAnchor = "TOPRIGHT"
	db.castBarIconScale = 1
	db.totemIndicatorScaleUpImportant = true
	db.enableNameplateAuraCustomisation = true
	db.testAllEnabledFeatures = false
	db.showCastBarIconWhenNoninterruptible = true
	db.enemyNeutralColorNameRGB = {
		1, -- [1]
		1, -- [2]
		0, -- [3]
	}
	db.nameplateAuraRowAbove = true
	db.nameplateMinAlphaDistanceScale = 60
	db.hideDefaultPersonalNameplateAuras = false
	db.healerIndicatorTestMode = false
	db.executeIndicatorScale = 1
	db.nameplateEnemyWidth = 135
	db.absorbIndicatorEnemyOnly = false
	db.setCVarAcrossAllCharacters = true
	db.totemIndicatorDefaultCooldownTextSizeScale = 0.9
	db.totemIndicator = true
	db.absorbIndicatorOnPlayersOnly = true
	db.castBarCastColor = {
		0.4862745404243469, -- [1]
		1, -- [2]
		0.294117659330368, -- [3]
		1, -- [4]
	}
	db.otherNpBuffEmphasisedBorder = false
	db.raidmarkIndicatorXPos = 0
	db.removeRealmNames = true
	db.largeNameplates = true
	db.nameplateResourceOnTarget = "0"
	db.castBarInterruptHighlighterEndPercentageHeight = 85
	db.castBarDelayedInterruptColor = {
		0, -- [1]
		1, -- [2]
		0.7843137979507446, -- [3]
		1, -- [4]
	}
	db.executeIndicatorYPos = 0
	db.otherNpBuffFilterLessMinite = false
	db.showTotemIndicatorCooldownSwipe = true
	db.nameplateMaxScale = "1.1"
	db.absorbIndicatorScale = 1
	db.nameplateResourceXPos = 0
	db.friendlyNpBuffFilterWatchList = true
	db.showCastbarIfTarget = false
	db.nameplateMotionSpeed = "0.05"
	db.nameplateMotion = "0"
	db.enemyClassColorName = true
	db.castBarIconPosReset = true
	db.otherNpBuffFilterAll = false
	db.totemIndicatorXPos = 0
	db.arenaIDScale = 1
	db.absorbIndicatorXPos = 0
	db.nameplateMinAlphaDistance = "60"
	db.nameplateDefaultLargeEnemyWidth = 154
	db.healerIndicatorEnemyXPos = 0
	db.targetIndicator = true
	db.absorbIndicatorTestMode = false
	db.healerIndicatorEnemyAnchor = "TOPRIGHT"
	db.otherNpBuffEnable = true
	db.nameplateDefaultLargeFriendlyHeight = 64.125
	db.defaultLargeFontSize = 12
	db.friendlyNpdeBuffFilterLessMinite = false
	db.nameplateDefaultFriendlyWidth = 110
	db.questIndicatorTestMode = false
	db.nameplateDefaultEnemyWidth = 110
	db.arenaIndicatorModeTwo = false
	db.nameplateOverlapV = "1.36"
	db.nameplateEnemyWidthScale = 135
	db.friendlyNameScale = 1
	db.castBarEmphasisHeight = false
	db.absorbIndicatorAnchor = "LEFT"
	db.raidmarkIndicatorYPos = 0
	db.personalNpBuffFilterWatchList = true
	db.nameplateFriendlyHeight = 1
	db.nameplateShowFriendlyPets = "0"
	db.focusTargetIndicator = false
	db.castBarIconYPos = 0
	db.useCustomTextureForFriendly = true
	db.executeIndicatorTestMode = false
	db.wasOnLoadingScreen = false
	db.friendlyNpdeBuffFilterOnlyMe = false
	db.auraWhitelistAlphaUpdated = true
	db.classIndicatorFriendly = true
	db.healerIndicatorEnemyYPos = 0
	db.castBarShieldScale = 1
	db.otherNpBuffPurgeGlow = false
	db.friendlyNpBuffEnable = true
	db.personalNpBuffFilterLessMinite = false
	db.petIndicatorXPos = 0
	db.combatIndicatorYPos = 0
	db.friendlyClassColorName = true
	db.classIndicator = false
	db.useCustomTextureForBars = false
	db.guildNameScale = 1
	db.personalNpBuffFilterBlizzard = true
	db.executeIndicatorAlwaysOn = false
	db.raidmarkIndicatorScale = 1
	db.friendlyNpBuffFilterOnlyMe = false
	db.defaultNpAuraCdSize = 0.5
	db.nameplateGlobalScale = "1.0"
	db.nameplateAuraAnchor = "BOTTOMLEFT"
	db.executeIndicatorThreshold = 40
	db.nameplateResourceYPos = 4
	db.castBarEmphasisTextScale = 2
	db.nameplateMaxAlphaDistance = "40"
	db.classIndicatorEnemy = true
	db.partyIndicatorModeThree = false
	db.castBarIconAnchor = "LEFT"
	db.healerIndicatorScale = 1
	db.arenaSpecAnchor = "TOP"
	db.castBarNoInterruptColor = {
		1, -- [1]
		0, -- [2]
		0.01568627543747425, -- [3]
	}
	db.friendlyNpdeBuffFilterBlizzard = false
	db.arenaIndicatorModeOne = false
	db.partyIndicatorModeTwo = true
	db.castBarInterruptHighlighterStartPercentageHeight = 15
	db.maxAurasOnNameplate = 12
	db.friendlyNameplatesOnlyInArena = true
	db.hideNPCWhitelistOn = false
end