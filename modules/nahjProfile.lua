-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

local nahjAuraWhitelist = {
    {
        ["id"] = 102351,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
        ["comment"] = "",
    }, -- [1]
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

    local db = BetterBlizzPlatesDB
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
	db.colorNPCName = false
	db.absorbIndicatorYPos = 0
	db.targetIndicatorYPos = 0
	db.friendlyNpBuffFilterAll = false
	db.focusTargetIndicatorTexture = "Shattered DF (BBP)"
	db.personalNpdeBuffEnable = false
	db.nameplateDefaultEnemyHeight = 45
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
	db.focusTargetIndicatorColorNameplate = false
	db.reopenOptions = false
	db.hasSaved = true
	db.nameplateAuraWidthGap = 4
	db.otherNpdeBuffFilterBlizzard = true
	db.arenaIdAnchor = "TOP"
	db.NamePlateVerticalScale = 2.799999952316284
	db.castBarDragonflightShield = true
	db.focusTargetIndicatorTestMode = false
	db.targetIndicatorTestMode = false
	db.absorbIndicator = true
	db.arenaIndicatorModeOff = false
	db.friendlyNpBuffBlueBorder = false
	db.arenaIndicatorModeFour = true
	db.nameplateAuraSquare = false
	db.castBarEmphasisSparkHeight = 35
	db.nameplateEnemyHeight = 50
	db.nameplateAurasYPos = 0
	db.castBarEmphasisColor = false
	db.defaultNamePlateFont = "Fonts\\FRIZQT__.TTF"
	db.customFontSize = 12
	db.nameplateAurasCenteredAnchor = false
	db.questIndicatorYPos = 0
	db.friendlyNpBuffPurgeGlow = false
	db.arenaIdXPos = 0
	db.castBarShieldYPos = 0
	db.arenaIndicatorModeThree = false
	db.nameplateDefaultLargeEnemyHeight = 64.125
	db.castBarTextScale = 1
	db.otherNpdeBuffFilterAll = false
	db.colorNPC = false
	db.focusTargetIndicatorScale = 1
	db.questIndicator = false
	db.executeIndicatorXPos = 0
	db.showNameplateTargetText = false
	db.partySpecScale = 1
	db.personalNpdeBuffFilterLessMinite = false
	db.friendlyNpdeBuffFilterAll = false
	db.partyIDScale = 1
	db.totemIndicatorHideNameAndShiftIconDown = false
	db.petIndicator = false
	db.enemyNameplateHealthbarHeight = 10.8
	db.customFont = "Yanone (BBP)"
	db.defaultLargeNamePlateFontFlags = ""
	db.personalNpBuffEnable = true
	db.nameplateAuraRelativeAnchor = "TOPLEFT"
	db.combatIndicatorEnemyOnly = true
	db.totemIndicatorAnchor = "TOP"
	db.healerIndicatorYPos = 0
	db.totemIndicatorYPos = 0
	db.nameplateLargerScale = "1.1"
	db.defaultNamePlateFontFlags = ""
	db.fadeOutNPCsAlpha = 0.2
	db.castBarRecolor = false
	db.combatIndicator = true
	db.useCustomFont = false
	db.otherNpdeBuffFilterLessMinite = false
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
	db.totemIndicatorGlowOff = false
	db.nameplateAuraScale = 1
	db.executeIndicatorThreshold = 40
	db.totemIndicatorScaleUpImportant = true
	db.combatIndicatorScale = 1
	db.personalNpBuffFilterAll = false
	db.partyModeSettingKey = "2: Arena ID on top of name"
	db.hideTargetHighlight = true
	db.focusTargetIndicatorXPos = 0
	db.partyIndicatorModeFour = false
	db.arenaSpecXPos = 0
	db.friendlyNpdeBuffEnable = false
	db.arenaIndicatorModeFive = false
	db.combatIndicatorYPos = 0
	db.enableCastbarEmphasis = false
	db.healerIndicator = false
	db.shortArenaSpecName = true
	db.classColorPersonalNameplate = true
	db.fadeOutNPC = false
	db.otherNpdeBuffFilterOnlyMe = false
	db.arenaIndicatorTestMode = false
	db.nameplateDefaultLargeFriendlyWidth = 154
	db.personalNpdeBuffFilterWatchList = true
	db.castBarShieldXPos = 0
	db.castBarEmphasisIcon = false
	db.healerIndicatorAnchor = "TOPRIGHT"
	db.executeIndicatorShowDecimal = true
	db.castBarEmphasisIconScale = 2
	db.partyIndicatorModeOne = false
	db.testAllEnabledFeatures = false
	db.questIndicatorXPos = 0
	db.healerIndicatorXPos = 0
	db.enemyNameScale = 1
	db.castBarIconXPos = 0
	db.combatIndicatorSap = true
	db.executeIndicatorNotOnFullHp = false
	db.focusTargetIndicatorAnchor = "TOPRIGHT"
	db.executeIndicatorScale = 1
	db.nameplateDefaultFriendlyWidth = 110
	db.healerIndicatorTestMode = false
	db.nameplateEnemyWidth = 135
	db.castBarEmphasisTextScale = 2
	db.raidmarkIndicatorScale = 1
	db.totemIndicator = true
	db.absorbIndicatorOnPlayersOnly = true
	db.removeRealmNames = true
	db.useCustomTextureForBars = false
	db.raidmarkIndicatorXPos = 0
	db.castBarEmphasisOnlyInterruptable = false
	db.questIndicatorTestMode = false
	db.nameplateAuraRowAmount = 5
	db.raidmarkIndicatorYPos = 0
	db.executeIndicatorYPos = 0
	db.otherNpBuffFilterLessMinite = false
	db.defaultLargeFontSize = 12
	db.largeNameplates = true
	db.nameplateMaxScale = "1.1"
	db.arenaIndicatorModeOne = false
	db.nameplateFriendlyHeight = 60
	db.friendlyNpBuffFilterWatchList = false
	db.showCastbarIfTarget = false
	db.hideNPCArenaOnly = false
	db.absorbIndicatorAnchor = "LEFT"
	db.enemyClassColorName = true
	db.raidmarkIndicator = false
	db.castBarIconScale = 1
	db.totemIndicatorXPos = 0
	db.castBarIconAnchor = "LEFT"
	db.absorbIndicatorXPos = 0
	db.personalNpBuffFilterWatchList = true
	db.castBarEmphasisHeightValue = 24
	db.targetIndicatorXPos = 0
	db.showCastBarIconWhenNoninterruptible = false
	db.nameplateMinScale = "1"
	db.targetIndicator = true
	db.petIndicatorYPos = 0
	db.customTexture = "Dragonflight (BBP)"
	db.otherNpBuffEnable = true
	db.nameplateDefaultLargeFriendlyHeight = 64.125
	db.nameplateAuraAnchor = "BOTTOMLEFT"
	db.nameplateGlobalScale = "1.0"
	db.personalNpBuffFilterLessMinite = false
	db.nameplateMotionSpeed = "0.05"
	db.arenaIndicatorModeTwo = false
	db.nameplateOverlapV = "1.3600000143051"
	db.nameplateEnemyWidthScale = 135
	db.nameplateAurasNoNameYPos = 0
	db.castBarEmphasisHeight = false
	db.nameplateDefaultLargeEnemyWidth = 154
	db.partyIndicatorModeTwo = true
	db.absorbIndicatorTestMode = false
	db.arenaIDScale = 1
	db.otherNpBuffFilterAll = false
	db.castBarIconYPos = 0
	db.partyIndicatorModeThree = false
	db.executeIndicatorTestMode = false
	db.focusTargetIndicator = false
	db.friendlyNpdeBuffFilterOnlyMe = false
	db.wasOnLoadingScreen = true
	db.friendlyClassColorName = true
	db.nameplateDefaultEnemyWidth = 110
	db.castBarShieldScale = 1
	db.friendlyNpdeBuffFilterLessMinite = false
	db.otherNpBuffPurgeGlow = false
	db.friendlyNpBuffEnable = false
	db.hideDefaultPersonalNameplateAuras = false
	db.arenaSpecYPos = 0
	db.petIndicatorXPos = 0
	db.petIndicatorTestMode = false
	db.totemIndicatorScaleScale = 1.299999952316284
	db.friendlyNameScale = 1
	db.friendlyNameplateClickthrough = true
	db.raidmarkIndicatorAnchor = "TOP"
	db.personalNpBuffFilterBlizzard = true
	db.executeIndicatorAlwaysOn = false
	db.partyIndicatorModeFive = false
	db.friendlyNpBuffFilterOnlyMe = false
	db.enableCastbarCustomization = false
	db.questIndicatorScale = 1
	db.enableNameplateAuraCustomisation = true
	db.castBarHeight = 18.8
	db.nameplateSelectedScale = "1.25"
	db.arenaSpecAnchor = "TOP"
	db.NamePlateVerticalScaleScale = 2.799999952316284
	db.healerIndicatorScale = 1
	db.friendlyNpBuffEmphasisedBorder = false
	db.executeIndicator = false
	db.otherNpBuffEmphasisedBorder = false
	db.targetIndicatorAnchor = "TOP"
	db.nameplateAuraRowAbove = true
	db.friendlyNpdeBuffFilterBlizzard = false
	db.nameplateAurasXPos = 0
	db.castBarEmphasisHealthbarColor = false
	db.absorbIndicatorEnemyOnly = false
	db.absorbIndicatorScale = 1
	db.maxAurasOnNameplate = 12
	db.friendlyNameplatesOnlyInArena = true
	db.petIndicatorAnchor = "CENTER"
	db.hideNPCWhitelistOn = false
end