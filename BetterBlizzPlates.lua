-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- My first addon, a lot could be done better but its a start for now

local addonVersion = "1.00"
local db = BetterBlizzPlatesDB
local customFont = "Interface\\AddOns\\BetterBlizzPlates\\media\\YanoneKaffeesatz-Medium.ttf"
local customTexture = "Interface\\AddOns\\BetterBlizzPlates\\media\\UI-TargetingFrame-BarFill.tga"

local defaultSettings = {
    version = addonVersion,
    wasOnLoadingScreen = false,
    -- General
    removeRealmNames = true,
    hideNameplateAuras = false,
    hideTargetHighlight = false,
    nameplateShowEnemyMinus = nil,
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
    -- Enemy
    enemyClassColorName = false,
    showNameplateCastbarTimer = false,
    showNameplateTargetText = false,
    enemyNameScale = 1,
    nameplateEnemyWidth = nil,
    nameplateEnemyHeight = nil,
    -- Friendly
    friendlyNameplateClickthrough = false,
    friendlyClassColorName = false,
    friendlyNameScale = 1,
    friendlyNameplatesOnlyInArena = false,
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
    -- Healer Indicator
    healerIndicator = false,
    healerIndicatorEnemyOnly = false,
    healerIndicatorScale = 1,
    healerIndicatorXPos = 0,
    healerIndicatorYPos = 0,
    healerIndicatorAnchor = "TOPRIGHT",
    healerIndicatorTestMode = false,
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
    -- Totem Indicator
    totemIndicator = false,
    totemIndicatorScale = 1,
    totemIndicatorXPos = 0,
    totemIndicatorYPos = 0,
    totemIndicatorAnchor = "TOP",
    totemIndicatorGlowOff = false,
    totemIndicatorScaleUpImportant = false,
    totemIndicatorHideNameAndShiftIconDown = false,
    totemIndicatorTestMode = false,
    -- Font and texture
    customFontSize = 12,
    useCustomFont = false,
    useCustomTextureForBars = false,


    testAllEnabledExtraFeatures = false,


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
    },
    hideNPCsWhitelist = {
        {name = "Hunter pet (they all have same ID)", id = 165189, comment = ""},
        {name = "Felguard (Demo Pet)", id = 17252, comment = ""},
        {name = "Felhunter (Warlock)", id = 417, comment = ""},
        {name = "Succubus (Warlock)", id = 1863, comment = ""},
        {name = "Tyrant (Warlock)", id = 135002, comment = ""},
        {name = "Observer (Warlock)", id = 107100, comment = ""},
        {name = "War Banner", id = 119052, comment = ""},
        {name = "Healing Tide Totem", id = 59764, comment = ""},
        {name = "Grounding Totem", id = 5925, comment = ""},
        {name = "Spirit Link Totem", id = 53006, comment = ""},
        {name = "Capacitor Totem", id = 61245, comment = ""},
        {name = "Counterstrike Totem", id = 105451, comment = ""},
        {name = "Fel Obelisk (Warlock)", id = 179193, comment = ""},
        {name = "Psyfiend (Spriest)", id = 101398, comment = ""},
        {name = "Earthen Wall Totem", id = 100943, comment = ""},
        {name = "Tremor Totem", id = 5913, comment = ""},
        {name = "Guardian Queen (prot pala)", id = 114565, comment = ""},
        {name = "Earthgrab Totem", id = 60561, comment = ""},
    },

    colorNpcList = {
    },
    

    --Extra Blizzard settings
    nameplateOverlapH = 0.8,
    nameplateOverlapV = 1.1,
    nameplateMotionSpeed = 0.025,
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

    for key, defaultValue in pairs(defaultSettings) do
        if BetterBlizzPlatesDB[key] == nil then
            BetterBlizzPlatesDB[key] = defaultValue
        end
    end
end

local function FetchAndSaveValuesOnFirstLogin()
    -- Check if already saved the first login values
    if BetterBlizzPlatesDB.hasSaved then
        return
    end
    -- Fetch Blizzard default values
    BetterBlizzPlatesDB.defaultLargeNamePlateFont, BetterBlizzPlatesDB.defaultLargeFontSize, BetterBlizzPlatesDB.defaultLargeNamePlateFontFlags = SystemFont_LargeNamePlate:GetFont()
    BetterBlizzPlatesDB.defaultNamePlateFont, BetterBlizzPlatesDB.defaultFontSize, BetterBlizzPlatesDB.defaultNamePlateFontFlags = SystemFont_NamePlate:GetFont()
    BetterBlizzPlatesDB.nameplateHorizontalScale = GetCVar("NamePlateHorizontalScale")
    BetterBlizzPlatesDB.NamePlateVerticalScale = GetCVar("NamePlateVerticalScale")
    BetterBlizzPlatesDB.nameplateMinScale = GetCVar("nameplateMinScale")
    BetterBlizzPlatesDB.nameplateMaxScale = GetCVar("nameplateMaxScale")
    BetterBlizzPlatesDB.nameplateSelectedScale = GetCVar("nameplateSelectedScale")
    BetterBlizzPlatesDB.NamePlateClassificationScale = GetCVar("NamePlateClassificationScale")
    BetterBlizzPlatesDB.nameplateGlobalScale = GetCVar("nameplateGlobalScale")
    BetterBlizzPlatesDB.nameplateLargerScale = GetCVar("nameplateLargerScale")
    BetterBlizzPlatesDB.nameplatePlayerLargerScale = GetCVar("nameplatePlayerLargerScale")
    BetterBlizzPlatesDB.nameplateShowEnemyMinus = GetCVar("nameplateShowEnemyMinus")

    BetterBlizzPlatesDB.hasSaved = true

    C_Timer.After(5, function()
        BetterBlizzPlatesDB.nameplateEnemyWidth, BetterBlizzPlatesDB.nameplateEnemyHeight = C_NamePlate.GetNamePlateEnemySize()
        BetterBlizzPlatesDB.nameplateFriendlyWidth, BetterBlizzPlatesDB.nameplateFriendlyHeight = C_NamePlate.GetNamePlateFriendlySize()
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates first run. Thank you for trying out my AddOn. Access settings with /bbp")
    end)
end

-- Define the popup window
StaticPopupDialogs["BETTERBLIZZPLATES_COMBAT_WARNING"] = {
    text = "Leave combat to adjust settings.",
    button1 = "Okay",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- to avoid tainting, use a high value if other popups are used
}

--##############################################################################################################################################
--##############################################################################################################################################
--##############################################################################################################################################
------------------------------------------------------------------------------------------------------
--- Functions
------------------------------------------------------------------------------------------------------
-- Return early functions if was just on loading screen
function BBP.SetLoadingScreenFalse()
    BetterBlizzPlatesDB.wasOnLoadingScreen = false
end

local function OnEvent(_, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LEAVING_WORLD" then
        BetterBlizzPlatesDB.wasOnLoadingScreen = true
        C_Timer.After(3, function()  -- wait for 3 seconds
            BBP.SetLoadingScreenFalse()
        end)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:SetScript("OnEvent", OnEvent)

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

--#################################################################################################
-- Set nameplate width
function BBP.ApplyNameplateWidth()
    if not BBP.checkCombatAndWarn() then
        if BetterBlizzPlatesDB.nameplateEnemyHeight and BetterBlizzPlatesDB.nameplateFriendlyHeight then
            local friendlyWidth = BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeFriendlyWidth or BetterBlizzPlatesDB.nameplateDefaultFriendlyWidth
            local enemyWidth = BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeEnemyWidth or BetterBlizzPlatesDB.nameplateDefaultEnemyWidth
            local friendlyHeight = BetterBlizzPlatesDB.friendlyNameplateClickthrough and 1 or (BBP.isLargeNameplatesEnabled() and BetterBlizzPlatesDB.nameplateDefaultLargeFriendlyHeight or BetterBlizzPlatesDB.nameplateDefaultFriendlyHeight)
            
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
-- Set CVars that keep changing
local function SetCVarsOnLogin()
    SetCVar("nameplateOverlapH", BetterBlizzPlatesDB.nameplateOverlapH)
    SetCVar("nameplateOverlapV", BetterBlizzPlatesDB.nameplateOverlapV)
    SetCVar("nameplateMotionSpeed", BetterBlizzPlatesDB.nameplateMotionSpeed)
end

--#################################################################################################
-- Set custom healthbar texture
function BBP.ApplyCustomTexture(namePlate)
    local unitFrame = namePlate.UnitFrame
    if unitFrame then
        if BetterBlizzPlatesDB.useCustomTextureForBars then
            if unitFrame.healthBar then
                unitFrame.healthBar:SetStatusBarTexture(customTexture)
            end
        end
    end
end

--#################################################################################################
-- Set custom healthbar texture
function BBP.SetCustomBarTextureToggle(value)
    -- Loop through all visible nameplates
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local unitFrame = namePlate.UnitFrame
        if unitFrame then
            if value then
                if unitFrame.healthBar then
                    unitFrame.healthBar:SetStatusBarTexture(customTexture)
                end
            else
                if unitFrame.healthBar then
                    unitFrame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
                end
            end
        end
    end
end

--#################################################################################################
function BBP.SetFontBasedOnOption(namePlateObj, specifiedSize, forcedOutline)
    local currentSize = specifiedSize or select(2, namePlateObj:GetFont())
    local font, outline

    if BetterBlizzPlatesDB.useCustomFont then
        font = customFont
        outline = forcedOutline or "THINOUTLINE"
        if namePlateObj == SystemFont_LargeNamePlate then
            currentSize = BetterBlizzPlatesDB.defaultLargeFontSize
        elseif namePlateObj == SystemFont_NamePlate then
            currentSize = BetterBlizzPlatesDB.defaultFontSize
        end
        currentSize = currentSize + 3
    else
        if namePlateObj == SystemFont_LargeNamePlate then
            font = BetterBlizzPlatesDB.defaultLargeNamePlateFont
            currentSize = BetterBlizzPlatesDB.defaultLargeFontSize
            outline = BetterBlizzPlatesDB.defaultLargeNamePlateFontFlags
        elseif namePlateObj == SystemFont_NamePlate then
            font = BetterBlizzPlatesDB.defaultNamePlateFont
            currentSize = BetterBlizzPlatesDB.defaultFontSize
            outline = BetterBlizzPlatesDB.defaultNamePlateFontFlags
        else
            -- Default case to handle other namePlateObj objects
            font = BetterBlizzPlatesDB.defaultNamePlateFont
            outline = forcedOutline or "OUTLINE"
            currentSize = specifiedSize or 10
        end
    end
    
    namePlateObj:SetFont(font, currentSize, outline)
end

--#################################################################################################
-- Friendly nameplates on only in arena toggle automatically
-- Event listening for Nameplates on in arena only
local friendlyNameplatesOnOffFrame = CreateFrame("Frame")
friendlyNameplatesOnOffFrame:SetScript("OnEvent", function(self, event, ...)
    if BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena then
        if IsActiveBattlefieldArena() then
            SetCVar("nameplateShowFriends", 1)
        else
            SetCVar("nameplateShowFriends", 0)
        end
    end
end)

-- Toggle event listening on/off
function BBP.ToggleFriendlyNameplatesInArena(value)
    if BetterBlizzPlatesDB.friendlyNameplatesOnlyInArena then
        friendlyNameplatesOnOffFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    else
        friendlyNameplatesOnOffFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        friendlyNameplatesOnOffFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end


--#################################################################################################
function BBP.HideOrShowNameplateAurasAndTargetHighlight(frame)
    -- Handle Buff Frame's alpha
    if BetterBlizzPlatesDB.hideNameplateAuras then
        frame.BuffFrame:SetAlpha(0)
    else
        frame.BuffFrame:SetAlpha(1)
    end

    -- Handle target highlight's alpha
    if BetterBlizzPlatesDB.hideTargetHighlight then
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
hooksecurefunc(NamePlateDriverFrame.pools:GetPool("ForbiddenNamePlateUnitFrameTemplate"),"resetterFunc",BBP.ClickthroughNameplateAuras)



--#################################################################################################
-- Class color and scale names 
function BBP.ClassColorAndScaleNames(frame)
    local relation
    if UnitIsFriend("player", frame.unit) then
        relation = "friendly"
    elseif UnitIsEnemy("player", frame.unit) or (UnitReaction("player", frame.unit) == 4) then
        relation = "enemy"
    else
        relation = "neutral"
    end

    -- Set the name's color based on unit relation
    if frame.optionTable.colorNameBySelection and UnitIsPlayer(frame.unit) then
        local settingKey = relation .. "ClassColorName"
        if BetterBlizzPlatesDB[settingKey] then
            local _, class = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[class]
            frame.name:SetVertexColor(classColor.r, classColor.g, classColor.b)
        end
    end
    
    -- Set the name's scale based on unit relation
    local scale = 1 -- Default scale
    if relation == "friendly" then
        scale = BetterBlizzPlatesDB.friendlyNameScale or 1
    elseif relation == "enemy" then
        scale = BetterBlizzPlatesDB.enemyNameScale or 1
    end
    frame.name:SetScale(scale)
end

--#################################################################################################
-- test all active functions
function BBP.EnableAllActiveFeatureTestModes(option, value)
    if BetterBlizzPlatesDB.wasOnLoadingScreen then return end
    local featuresWithTestModes = {
        "absorbIndicator",
        "executeIndicator",
        "healerIndicator",
        "petIndicator",
        "targetIndicator",
        "totemIndicator",
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
            if BBP.isLargeNameplatesEnabled() then
                C_NamePlate.SetNamePlateEnemySize(154, heightValue)
                slider:SetValue(154)
            else
                C_NamePlate.SetNamePlateEnemySize(110, heightValue)
                slider:SetValue(110)
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
            BetterBlizzPlatesDB.nameplateMinScale = defaultMinScale
            BetterBlizzPlatesDB.nameplateMaxScale = defaultMaxScale
            SetCVar("nameplateMinScale", defaultMinScale)
            SetCVar("nameplateMaxScale", defaultMaxScale)
            SetCVar("nameplateGlobalScale", 1)
            print("CVar nameplateMinScale set to " .. defaultMinScale)
            print("CVar nameplateMaxScale set to " .. defaultMaxScale)
            print("CVar nameplateGlobalScale set to 1")         
        elseif targetType == "nameplateSelected" then
            BetterBlizzPlatesDB.nameplateSelectedScale = defaultSettings[targetType]
            SetCVar("nameplateSelectedScale", defaultSettings[targetType])
            print("CVar nameplateSelectedScale set to " .. defaultSettings[targetType])
        end
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

    -- Convert npcName to lowercase for case insensitive comparison
    local lowerCaseNpcName = strlower(npcName)

    -- Check if the NPC is in the list by ID or name (case insensitive)
    local inList = false
    for _, npc in ipairs(BetterBlizzPlatesDB.fadeOutNPCsList) do
        if npc.id == tonumber(npcID) or (npc.id and npc.id == tonumber(npcID)) then
            inList = true
            break
        elseif npc.name == tostring(npcName) or strlower(npc.name) == lowerCaseNpcName then
            inList = true
            break
        end
    end
    
    -- Check if the unit is the current target
    if UnitIsUnit(frame.displayedUnit, "target") then
        frame:SetAlpha(1)
    elseif inList then
        frame:SetAlpha(BetterBlizzPlatesDB.fadeOutNPCsAlpha)
    else
        frame:SetAlpha(1)
    end
end


--##################################################################################################
-- Hide npcs from list
function BBP.HideNPCs(frame)
    if not frame or not frame.displayedUnit then return end
    frame:Show()

    if BetterBlizzPlatesDB.hideNPCArenaOnly and not UnitInBattleground("player") then
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

    if BetterBlizzPlatesDB.hideNPCWhitelistOn then
        -- Check if the NPC is in the whitelist by ID or name (case-insensitive)
        local inWhitelist = false
        for _, npc in ipairs(BetterBlizzPlatesDB.hideNPCsWhitelist) do
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
        else
            frame:Hide()
        end
    else
        -- Check if the NPC is in the blacklist by ID or name (case-insensitive)
        local inList = false
        for _, npc in ipairs(BetterBlizzPlatesDB.hideNPCsList) do
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
        elseif inList then
            frame:Hide()
        else
            frame:Show()
        end
    end
end





--################################################################################################
-- Color NPCs
function BBP.ColorNPCs(frame)
    if not frame or not frame.displayedUnit then return end
    if not BetterBlizzPlatesDB.colorNPC then return end
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
    for _, npc in ipairs(BetterBlizzPlatesDB.colorNpcList) do
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
        if BetterBlizzPlatesDB.colorNPCName then
            frame.name:SetVertexColor(npcColor.r, npcColor.g, npcColor.b)
        end
    end
end

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if not BetterBlizzPlatesDB.colorNPC then return end
    BBP.ColorNPCs(frame)
end)


--################################################################################################
-- Apply raidmarker change
function BBP.ApplyRaidmarkerChanges(nameplate)
    if not nameplate then return end
    local frame = nameplate.UnitFrame
    if not frame or frame:IsForbidden() then return end

    frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()

    if BetterBlizzPlatesDB.raidmarkIndicator then
        local anchorPoint = BetterBlizzPlatesDB.raidmarkIndicatorAnchor or "TOP"
        local xPos = BetterBlizzPlatesDB.raidmarkIndicatorXPos
        local yPos = BetterBlizzPlatesDB.raidmarkIndicatorYPos
        if anchorPoint == "TOP" then
            frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
            frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.name, anchorPoint, xPos, yPos)
        else
            frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
            frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.healthBar, anchorPoint, xPos, yPos)
        end
        frame.RaidTargetFrame.RaidTargetIcon:SetScale(BetterBlizzPlatesDB.raidmarkIndicatorScale or 1)
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

--#################################################################################################
--#################################################################################################
--#################################################################################################
-- What to do on a nameplate remvoed
local function HandleNamePlateRemoved(unit)
    local nameplate = BBP.GetNameplate(unit)
    if not nameplate or not nameplate.UnitFrame then return end
    local frame = nameplate.UnitFrame
    if frame:IsForbidden() then return end

    if frame then
        frame:SetScale(1)
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
end

--#################################################################################################
--#################################################################################################
--#################################################################################################
-- What to do on a new nameplate
local function HandleNamePlateAdded(unit)
    local nameplate = BBP.GetNameplate(unit)
    if not nameplate or not nameplate.UnitFrame then return end
    local frame = nameplate.UnitFrame
    if frame:IsForbidden() then return end

    -- CLean up previous nameplates
    HandleNamePlateRemoved(unit)

    -- Show Target indicator
    if BetterBlizzPlatesDB.targetIndicator then
        BBP.TargetIndicator(frame)
    end
    
    -- Show absorb amount
    if BetterBlizzPlatesDB.absorbIndicator or BetterBlizzPlatesDB.absorbIndicatorTestMode then
        BBP.AbsorbIndicator(frame)
    end

    -- Show totem icons
    if BetterBlizzPlatesDB.totemIndicatorTestMode or BetterBlizzPlatesDB.totemIndicator then
        BBP.ApplyTotemIconsAndColorNameplate(frame, unit)
    end

    if not BetterBlizzPlatesDB.arenaIndicatorModeOff or not BetterBlizzPlatesDB.partyIndicatorModeOff or BetterBlizzPlatesDB.arenaIndicatorTestMode then
        BBP.ArenaIndicatorCaller(frame, BetterBlizzPlatesDB)
    end
    
    if BetterBlizzPlatesDB.executeIndicator or BetterBlizzPlatesDB.executeIndicatorTestMode then
        BBP.ExecuteIndicator(frame)
    end

    -- Handle nameplate aura and target highlight visibility
    BBP.HideOrShowNameplateAurasAndTargetHighlight(frame)

    -- Fade out NPCs from list if enabled
    if BetterBlizzPlatesDB.fadeOutNPC then
        BBP.FadeOutNPCs(frame)
    end

    -- Hide NPCs from list if enabled
    if BetterBlizzPlatesDB.hideNPC then
        BBP.HideNPCs(frame)
    end

    -- Color NPC
    if BetterBlizzPlatesDB.colorNPC then
        BBP.ColorNPCs(frame)
    end

    -- Show hunter pet icon
    if BetterBlizzPlatesDB.petIndicator or BetterBlizzPlatesDB.petIndicatorTestMode then
        BBP.PetIndicator(frame)
    end

    -- Handle raid marker changes
    if BetterBlizzPlatesDB.raidmarkIndicator then
        BBP.ApplyRaidmarkerChanges(nameplate)
    end

    -- Healer icon
    if BetterBlizzPlatesDB.healerIndicatorTestMode or BetterBlizzPlatesDB.healerIndicator then
        BBP.HealerIndicator(frame)
    end

    -- Apply Out Of Combat Icon
    if BetterBlizzPlatesDB.combatIndicator then
        BBP.CombatIndicator(frame)
    end

    -- Apply custom healthbar texture
    if BetterBlizzPlatesDB.useCustomTextureForBars then
        BBP.ApplyCustomTexture(nameplate)
    else
        frame.healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill") --added this only to deal with scenario where user toggles off custom textures and gets new nameplates (with custom textures) displaying, OPTIMIZE
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
    if not BBP.checkCombatAndWarn() then
        for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
            local frame = nameplate.UnitFrame
            BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, BetterBlizzPlatesDB.defaultLargeFontSize)
            BBP.SetFontBasedOnOption(SystemFont_NamePlate, BetterBlizzPlatesDB.defaultFontSize) 
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
                BBP.SetFontBasedOnOption(frame.executeIndicator, 8, "THICKOUTLINE")
            end
            if frame.arenaNumberText then
                BBP.SetFontBasedOnOption(frame.arenaNumberText, BetterBlizzPlatesDB.defaultFontSize)
            end
            if frame.specNameText then
                BBP.SetFontBasedOnOption(frame.specNameText, BetterBlizzPlatesDB.defaultFontSize)
            end

            -- Reset nameplate scale after testing totems
            if not BetterBlizzPlatesDB.totemIndicatorTestMode then
                if frame then
                    frame:SetScale(1)
                end
            end
            -- Always update the name
            BBP.RestoreOriginalNameplateColors(frame)
            CompactUnitFrame_UpdateName(frame)
            HandleNamePlateAdded(frame.unit)
            if not BetterBlizzPlatesDB.fadeOutNPC then
                frame:SetAlpha(1)
            end
            if not BetterBlizzPlatesDB.hideNPC then
                if frame then
                    frame:Show()
                end
            end
        end
    end
end

function BBP.RefreshAllNameplatesLightVer()
    if not BBP.checkCombatAndWarn() then
        for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
            local frame = nameplate.UnitFrame
            --BBP.RestoreOriginalNameplateColors(frame)
            --CompactUnitFrame_UpdateName(frame)
            HandleNamePlateAdded(frame.unit)
        end
    end
end

--#################################################################################################
-- Nameplate updater etc
local function ConsolidatedUpdateName(frame)
    -- Remove realm names if applicable
    if BetterBlizzPlatesDB.removeRealmNames then
        BBP.RemoveRealmName(frame)
    end

    -- Further processing only for nameplate units
    if not frame.unit or not frame.unit:find("nameplate") then return end

    -- Class color and scale names depending on their reaction
    BBP.ClassColorAndScaleNames(frame)
    
    -- Use arena numbers
    if not BetterBlizzPlatesDB.arenaIndicatorModeOff or not BetterBlizzPlatesDB.partyIndicatorModeOff or BetterBlizzPlatesDB.arenaIndicatorTestMode then
        BBP.ArenaIndicatorCaller(frame, BetterBlizzPlatesDB)
    end
    
    -- Handle absorb indicator and reset absorb text if it exists
    if BetterBlizzPlatesDB.absorbIndicator then
        BBP.AbsorbIndicator(frame)
    end
    -- Show out of combat icon
    if BetterBlizzPlatesDB.combatIndicator then
        BBP.CombatIndicator(frame)
    end

    -- Show hunter pet icon
    if BetterBlizzPlatesDB.petIndicator then
        BBP.PetIndicator(frame)
    end
    -- Raidmarker change
    if BetterBlizzPlatesDB.raidmarkIndicator then
        BBP.ApplyRaidmarkerChanges(nameplate)
    end
    -- Show healer icon
    if BetterBlizzPlatesDB.healerIndicatorTestMode or BetterBlizzPlatesDB.healerIndicator then
        BBP.HealerIndicator(frame)
    end

    if BetterBlizzPlatesDB.colorNPCName then
        BBP.ColorNPCs(frame)
    end

    -- Color nameplate and pick random name or hide name during totem tester
    if BetterBlizzPlatesDB.totemIndicatorTestMode and frame.randomColor then
        frame.name:SetVertexColor(unpack(frame.randomColor))
        if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
            frame.name:SetText("")
        else
            frame.name:SetText(frame.randomName)
        end
    end

    -- Ensure totem nameplate color is correct
    local npcID = BBP.GetNPCIDFromGUID(UnitGUID(frame.unit))
    if BBP.npcList[npcID] and BBP.npcList[npcID].color then
        frame.healthBar:SetStatusBarColor(unpack(BBP.npcList[npcID].color))
        frame.name:SetVertexColor(unpack(BBP.npcList[npcID].color))
    end
end    
-- Use the consolidated function to hook into CompactUnitFrame_UpdateName
hooksecurefunc("CompactUnitFrame_UpdateName", ConsolidatedUpdateName)

-- Event registration for PLAYER_LOGIN
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
--Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(...)

    BBP.SetFontBasedOnOption(SystemFont_LargeNamePlate, BetterBlizzPlatesDB.defaultLargeFontSize)
    BBP.SetFontBasedOnOption(SystemFont_NamePlate, BetterBlizzPlatesDB.defaultFontSize)    
    BBP.ApplyNameplateWidth()
    SetCVarsOnLogin()
    -- This needs to be delayed to work
    C_Timer.After(3, function()  -- wait for 3 seconds
        BBP.SetCustomBarTextureToggle(BetterBlizzPlatesDB.useCustomTextureForBars)
    end)
    -- Re-open options when clicking reload button
    if BetterBlizzPlatesDB.reopenOptions then
        InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
        BetterBlizzPlatesDB.reopenOptions = false
    end
end)

-- Slash command
SLASH_BBP1 = "/bbp"
SlashCmdList["BBP"] = function(msg)
    InterfaceOptionsFrame_OpenToCategory(BetterBlizzPlates)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CVAR_UPDATE")
frame:SetScript("OnEvent", function(self, event, cvarName)
    if cvarName == "NamePlateHorizontalScale" then
        -- Reapply nameplate width if user toggles Large Nameplates on/off
        RunNextFrame(function()
            BBP.ApplyNameplateWidth()
        end)
    end
end)

-- Event registration for PLAYER_LOGIN
local First = CreateFrame("Frame")
First:RegisterEvent("ADDON_LOADED")
First:SetScript("OnEvent", function(...)
    BetterBlizzPlatesDB.absorbIndicatorTestMode = false
    BetterBlizzPlatesDB.petIndicatorTestMode = false
    BetterBlizzPlatesDB.healerIndicatorTestMode = false
    BetterBlizzPlatesDB.arenaIndicatorTestMode = false
    BetterBlizzPlatesDB.totemIndicatorTestMode = false
    BetterBlizzPlatesDB.testAllEnabledExtraFeatures = false
    
    InitializeSavedVariables()
    FetchAndSaveValuesOnFirstLogin()
    BBP.InitializeOptions()
end)