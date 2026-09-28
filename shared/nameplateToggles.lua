local CITY_MAPS = {
    [1453] = true,
    [1454] = true,
    [1455] = true,
    [1456] = true,
    [1457] = true,
    [1458] = true,

    [84]   = true,
    [1012] = true,
    [1264] = true,
    [87]   = true,
    [1265] = true,
    [89]   = true,
    [1324] = true,
    [103]  = true,
    [775]  = true,
    [1326] = true,
    [1331] = true,

    [85]   = true,
    [86]   = true,
    [1534] = true,
    [88]   = true,
    [1323] = true,
    [90]   = true,
    [998]  = true,
    [1266] = true,
    [110]  = true,
    [1269] = true,
    [2393] = true,
    [2443] = true,

    [111]  = true,
    [594]  = true,
    [125]  = true,
    [126]  = true,
    [501]  = true,
    [502]  = true,
    [626]  = true,
    [627]  = true,
    [628]  = true,
    [629]  = true,
    [2305] = true,
    [2306] = true,
    [2307] = true,
    [391]  = true,
    [392]  = true,
    [393]  = true,
    [394]  = true,
    [622]  = true,
    [624]  = true,
    [1161] = true,
    [1163] = true,
    [1164] = true,
    [1165] = true,
    [1670] = true,
    [1671] = true,
    [1672] = true,
    [1673] = true,
    [2112] = true,
    [2134] = true,
    [2135] = true,
    [2239] = true,
    [2268] = true,
    [2339] = true,
}

local EPIC_BG_BRACKET = 3
local ONLY_NAME_CVAR = "nameplateShowOnlyNameForFriendlyPlayerUnits"
local STACKING_CVAR = "nameplateStackingTypes"

local hasArenas = not (BBP.isForever or BBP.isEra)

BBP.nameplateToggleCategories = {
    { key = "pvp",     label = "PvP",           mode = "simple" },
    { key = "pve",     label = "PvE",           mode = "simple" },
    { key = "arena",   label = "Arenas",        mode = "advanced", pvp = true, available = hasArenas },
    { key = "bg",      label = "BGs",           mode = "advanced", pvp = true },
    { key = "epicbg",  label = "Epic BGs",      mode = "advanced", pvp = true },
    { key = "dungeon", label = "Dungeons",      mode = "advanced" },
    { key = "raid",    label = "Raids",         mode = "advanced" },
    { key = "world",   label = "World",         mode = "advanced" },
    { key = "city",    label = "Cities",        mode = "advanced" },
}

local categoryByKey = {}
for _, category in ipairs(BBP.nameplateToggleCategories) do
    if category.available == nil then category.available = true end
    categoryByKey[category.key] = category
end
BBP.nameplateToggleCategoryByKey = categoryByKey

BBP.nameplateToggleCVarList = {
    "nameplateShowEnemies",
    "nameplateShowFriendlyPlayers",
    "nameplateShowEnemyMinions",
    "nameplateShowEnemyGuardians",
    "nameplateShowEnemyMinus",
    "nameplateShowEnemyPets",
    "nameplateShowEnemyTotems",
    "nameplateShowFriendlyPlayerMinions",
    "nameplateShowFriendlyPlayerGuardians",
    "nameplateShowFriendlyNpcs",
    "nameplateShowFriendlyPlayerPets",
    "nameplateShowFriendlyPlayerTotems",
    ONLY_NAME_CVAR,
}

local toggleMinionChildren = {
    "nameplateShowEnemyGuardians",
    "nameplateShowEnemyMinus",
    "nameplateShowEnemyPets",
    "nameplateShowEnemyTotems",
    "nameplateShowFriendlyPlayerGuardians",
    "nameplateShowFriendlyPlayerPets",
    "nameplateShowFriendlyPlayerTotems",
}

local visibilityDefaults = {
    nameplateShowEnemyMinions = true,
    nameplateShowEnemyGuardians = true,
    nameplateShowEnemyMinus = false,
    nameplateShowEnemyPets = true,
    nameplateShowEnemyTotems = true,
    nameplateShowFriendlyPlayerMinions = false,
    nameplateShowFriendlyPlayerGuardians = false,
    nameplateShowFriendlyNpcs = false,
    nameplateShowFriendlyPlayerPets = false,
    nameplateShowFriendlyPlayerTotems = false,
}

local toggleDefaults = {
    nameplateShowEnemies = true,
    nameplateShowFriendlyPlayers = true,
    [ONLY_NAME_CVAR] = false,
    stackingEnemy = true,
    stackingFriendly = false,
}
for cvar, value in pairs(visibilityDefaults) do
    toggleDefaults[cvar] = value
end
BBP.nameplateToggleDefaults = toggleDefaults

BBP.nameplateToggleEntries = {
    { key = "nameplateShowEnemies", label = "Show Enemy Nameplates", side = "enemy", root = true },
    { key = "nameplateShowFriendlyPlayers", label = "Show Friendly Nameplates", side = "friendly", root = true },
    false,
    { key = "nameplateShowFriendlyNpcs", label = "Show Friendly NPC Nameplates" },
    false, false,
    { key = "stackingEnemy", label = "Stacking Enemy Nameplates", side = "enemy", stack = "Enemy" },
    { key = "stackingFriendly", label = "Stacking Friendly Nameplates", side = "friendly", stack = "Friendly" },
    false,
    { key = ONLY_NAME_CVAR, label = "Only show Friendly name", side = "friendly", short = "Names only" },
    false, false,
    { key = "nameplateShowEnemyMinions", label = "Enemy Minions", side = "enemy" },
    { key = "nameplateShowFriendlyPlayerMinions", label = "Friendly Minions", side = "friendly" },
    { key = "nameplateShowEnemyGuardians", label = "Enemy Guardians", side = "enemy" },
    { key = "nameplateShowFriendlyPlayerGuardians", label = "Friendly Guardians", side = "friendly" },
    { key = "nameplateShowEnemyPets", label = "Enemy Pets", side = "enemy" },
    { key = "nameplateShowFriendlyPlayerPets", label = "Friendly Pets", side = "friendly" },
    { key = "nameplateShowEnemyTotems", label = "Enemy Totems", side = "enemy" },
    { key = "nameplateShowFriendlyPlayerTotems", label = "Friendly Totems", side = "friendly" },
    { key = "nameplateShowEnemyMinus", label = "Enemy Minus", side = "enemy" },
    false,
}

local cvarExists = {}
local function CVarExists(cvar)
    local known = cvarExists[cvar]
    if known == nil then
        known = C_CVar.GetCVar(cvar) ~= nil
        cvarExists[cvar] = known
    end
    return known
end

function BBP.NameplateToggleEntryAvailable(entry)
    if not entry then return false end
    if entry.stack then return true end
    return CVarExists(entry.key)
end

local function StackIndex(which)
    return Enum.NamePlateStackType[which]
end

local function LiveStackBit(which)
    return C_CVar.GetCVarBitfield(STACKING_CVAR, StackIndex(which)) and true or false
end

local function IsOn(value)
    return value == "1" or value == 1 or value == true
end

local function SetKey(key)
    return "nameplateToggles_" .. key
end
BBP.NameplateToggleSetKey = SetKey

function BBP.GetNameplateToggleMode()
    local db = BetterBlizzPlatesDB
    return db and db.nameplateToggleMode == "advanced" and "advanced" or "simple"
end

local EPIC_BG_INSTANCES = {
    [30] = true,
    [2582] = true,
    [628] = true,
    [1191] = true,
}

local function IsEpicBG()
    local _, _, _, _, maxPlayers, _, _, instanceMapID = GetInstanceInfo()
    if instanceMapID and EPIC_BG_INSTANCES[instanceMapID] then return true end
    if C_PvP.GetActiveMatchBracket then
        local bracket = C_PvP.GetActiveMatchBracket()
        if bracket == EPIC_BG_BRACKET then return true end
        if bracket ~= nil and bracket ~= 0 then return false end
    end
    return (tonumber(maxPlayers) or 0) >= 40
end

local function IsInCity()
    if C_PvP.GetZonePVPInfo() == "sanctuary" then
        return true
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    return mapID ~= nil and CITY_MAPS[mapID] == true
end

function BBP.DetectNameplateToggleCategory()
    local inInstance, instanceType = IsInInstance()
    if instanceType == "arena" then return "arena" end
    if instanceType == "pvp" then return IsEpicBG() and "epicbg" or "bg" end
    if instanceType == "party" or instanceType == "scenario" then return "dungeon" end
    if instanceType == "raid" then return "raid" end
    if not inInstance and IsInCity() then return "city" end
    return "world"
end

function BBP.ResolveNameplateToggleSet(category, mode)
    local cat = categoryByKey[category]
    if not cat then return nil end
    if mode == "simple" then
        return cat.pvp and "pvp" or "pve"
    end
    if not cat.available then return "bg" end
    return category
end

function BBP.RefreshNameplateToggleSet()
    local category = BBP.DetectNameplateToggleCategory()
    BBP.nameplateToggleCategory = category
    BBP.nameplateToggleActiveSet = BBP.ResolveNameplateToggleSet(category, BBP.GetNameplateToggleMode())
    return BBP.nameplateToggleActiveSet
end

function BBP.GetActiveNameplateToggleSetKey()
    local active = BBP.RefreshNameplateToggleSet()
    return active and SetKey(active) or nil
end

local function NewDefaultSet()
    local set = {}
    for key, value in pairs(toggleDefaults) do
        set[key] = value
    end
    return set
end

local function LegacyVisibilityValue(db, cvar, fallback)
    if BBP.isMainline and db.totemIndicator and not db.totemIndicatorUpdatedForMidnight then
        local legacyTotem = cvar == "nameplateShowEnemyMinions" or cvar == "nameplateShowEnemyGuardians"
            or cvar == "nameplateShowEnemyMinus" or cvar == "nameplateShowEnemyPets" or cvar == "nameplateShowEnemyTotems"
        if legacyTotem then return fallback end
    end
    local previous = db[cvar]
    if previous ~= nil then return IsOn(previous) end
    local live = C_CVar.GetCVar(cvar)
    if live ~= nil then return live == "1" end
    return fallback
end

local function BuildLegacySet(db, oldSet)
    local set = NewDefaultSet()
    for cvar, fallback in pairs(visibilityDefaults) do
        if type(oldSet) == "table" and oldSet[cvar] ~= nil then
            set[cvar] = oldSet[cvar] and true or false
        else
            set[cvar] = LegacyVisibilityValue(db, cvar, fallback)
        end
    end
    return set
end

function BBP.MigrateNameplateToggles(db)
    local pvpSet = BuildLegacySet(db, db.cvarContextPvP)
    local pveSet = BuildLegacySet(db, db.cvarContextPvE)

    local sets = {}
    for _, category in ipairs(BBP.nameplateToggleCategories) do
        local source = (category.key == "pvp" or category.pvp) and pvpSet or pveSet
        local set = {}
        for key, value in pairs(source) do
            set[key] = value
        end
        sets[category.key] = set
    end

    for _, set in pairs(sets) do
        set.nameplateShowEnemies = true
    end

    local oldArena = db.friendlyNameplatesOnlyInArena and true or false
    local oldBgs = db.friendlyNameplatesOnlyInBgs and true or false
    local oldEpic = db.friendlyNameplatesOnlyInEpicBgs
    if oldEpic == nil then oldEpic = oldBgs end
    oldEpic = oldEpic and true or false
    local oldDungeons = db.friendlyNameplatesOnlyInDungeons and true or false
    local oldRaids = db.friendlyNameplatesOnlyInRaids
    if oldRaids == nil then oldRaids = oldDungeons end
    oldRaids = oldRaids and true or false
    local oldWorld = db.friendlyNameplatesOnlyInWorld and true or false

    local usedOldToggles = oldArena or oldBgs or oldEpic or oldDungeons or oldRaids or oldWorld
    if usedOldToggles then
        sets.arena.nameplateShowFriendlyPlayers = oldArena
        sets.bg.nameplateShowFriendlyPlayers = oldBgs
        sets.epicbg.nameplateShowFriendlyPlayers = oldEpic
        sets.dungeon.nameplateShowFriendlyPlayers = oldDungeons
        sets.raid.nameplateShowFriendlyPlayers = oldRaids
        sets.world.nameplateShowFriendlyPlayers = oldWorld
        sets.city.nameplateShowFriendlyPlayers = oldWorld
    else
        local liveFriendly = C_CVar.GetCVar("nameplateShowFriendlyPlayers")
        local showFriendly = liveFriendly == nil or liveFriendly == "1"
        for _, set in pairs(sets) do
            set.nameplateShowFriendlyPlayers = showFriendly
        end
    end

    local bits = db.bitfields and db.bitfields[STACKING_CVAR]
    local enemyIndex, friendlyIndex = StackIndex("Enemy"), StackIndex("Friendly")
    local stackEnemy = bits and enemyIndex and bits[tostring(enemyIndex)]
    if stackEnemy == nil then stackEnemy = LiveStackBit("Enemy") end
    local stackFriendly = bits and friendlyIndex and bits[tostring(friendlyIndex)]
    if stackFriendly == nil then stackFriendly = LiveStackBit("Friendly") end
    local overlapInPvP = stackEnemy and db.keepOverlappingNameplatesInPvP
    for key, set in pairs(sets) do
        local category = categoryByKey[key]
        local pvp = key == "pvp" or category.pvp
        set.stackingEnemy = (stackEnemy and not (overlapInPvP and pvp)) and true or false
        set.stackingFriendly = stackFriendly and true or false
    end

    local onlyName = LegacyVisibilityValue(db, ONLY_NAME_CVAR, false)
    for _, set in pairs(sets) do
        set[ONLY_NAME_CVAR] = onlyName
    end

    for key, set in pairs(sets) do
        db[SetKey(key)] = set
    end
    db.nameplateToggleMode = "simple"

    db.friendlyNameplatesOnlyInArena = nil
    db.friendlyNameplatesOnlyInBgs = nil
    db.friendlyNameplatesOnlyInEpicBgs = nil
    db.friendlyNameplatesOnlyInDungeons = nil
    db.friendlyNameplatesOnlyInRaids = nil
    db.friendlyNameplatesOnlyInWorld = nil
    db.friendlyNameplateTogglesUpdated = nil
    db.keepOverlappingNameplatesInPvP = nil
    db.cvarContextPvP = nil
    db.cvarContextPvE = nil
    db.nameplateTogglesMigrated = true
end

function BBP.InitNameplateToggles(resetToDefaults)
    local db = BetterBlizzPlatesDB
    if not db then return end

    if resetToDefaults then
        for _, category in ipairs(BBP.nameplateToggleCategories) do
            db[SetKey(category.key)] = NewDefaultSet()
        end
        db.nameplateToggleMode = "simple"
        db.nameplateTogglesMigrated = true
    elseif not db.nameplateTogglesMigrated then
        if BBP.variablesLoaded then
            BBP.MigrateNameplateToggles(db)
        else
            BBP.nameplateToggleMigrationPending = true
        end
    end

    for _, category in ipairs(BBP.nameplateToggleCategories) do
        local key = SetKey(category.key)
        if type(db[key]) ~= "table" then db[key] = NewDefaultSet() end
        for field, value in pairs(toggleDefaults) do
            if db[key][field] == nil then
                db[key][field] = value
            end
        end
    end
    if db.nameplateToggleMode ~= "advanced" then
        db.nameplateToggleMode = "simple"
    end

    BBP.lastAppliedNameplateToggles = nil
    BBP.RefreshFriendlyToggleUI(true)
end

local friendlyGroups = {
    pvp = { "arena", "bg", "epicbg" },
    pve = { "dungeon", "raid", "world", "city" },
}

local function FriendlyMembers(key)
    local members = {}
    for _, member in ipairs(friendlyGroups[key] or { key }) do
        local category = categoryByKey[member]
        if category and category.available then
            members[#members + 1] = member
        end
    end
    return members
end

function BBP.GetFriendlyToggleCount(key)
    local db = BetterBlizzPlatesDB
    local on, total = 0, 0
    for _, member in ipairs(FriendlyMembers(key)) do
        total = total + 1
        local set = db and db[SetKey(member)]
        if set and set.nameplateShowFriendlyPlayers then on = on + 1 end
    end
    return on, total
end

function BBP.GetFriendlyToggle(key)
    local on, total = BBP.GetFriendlyToggleCount(key)
    return total > 0 and on == total
end

function BBP.RefreshFriendlyToggleUI(skipRows)
    if BBP.friendlyToggleButtons then
        for key, button in pairs(BBP.friendlyToggleButtons) do
            button:SetChecked(BBP.GetFriendlyToggle(key))
        end
    end
    if not skipRows and BBP.RefreshNameplateToggleRows then BBP.RefreshNameplateToggleRows() end
end

function BBP.SetFriendlyToggle(key, value, fromDropdown)
    local db = BetterBlizzPlatesDB
    if not db then return end
    for _, member in ipairs(FriendlyMembers(key)) do
        local setKey = SetKey(member)
        if type(db[setKey]) ~= "table" then db[setKey] = NewDefaultSet() end
        db[setKey].nameplateShowFriendlyPlayers = value and true or false
    end
    BBP.lastAppliedNameplateToggles = nil
    BBP.UpdateNameplateToggles(true, true)
    BBP.RefreshFriendlyToggleUI(fromDropdown)
end

function BBP.SyncNameplateTogglesFromLiveCVars()
    local db = BetterBlizzPlatesDB
    if not db then return end
    local stackEnemy, stackFriendly = LiveStackBit("Enemy"), LiveStackBit("Friendly")
    for _, category in ipairs(BBP.nameplateToggleCategories) do
        local key = SetKey(category.key)
        if type(db[key]) ~= "table" then db[key] = NewDefaultSet() end
        for _, cvar in ipairs(BBP.nameplateToggleCVarList) do
            local live = C_CVar.GetCVar(cvar)
            if live ~= nil then
                db[key][cvar] = live == "1"
            end
        end
        db[key].stackingEnemy = stackEnemy
        db[key].stackingFriendly = stackFriendly
    end
    BBP.lastAppliedNameplateToggles = nil
end

function BBP.ForEachNameplateToggleSet(func)
    local db = BetterBlizzPlatesDB
    if not db then return end
    for _, category in ipairs(BBP.nameplateToggleCategories) do
        local key = SetKey(category.key)
        if type(db[key]) ~= "table" then db[key] = NewDefaultSet() end
        func(db[key], category)
    end
end

BBP.nameplateToggleCVarLookup = {}
for _, cvar in ipairs(BBP.nameplateToggleCVarList) do
    BBP.nameplateToggleCVarLookup[cvar] = true
end

function BBP.NameplateTogglesDisabled()
    local db = BetterBlizzPlatesDB
    if not db then return true end
    if db.disableCVarForceOnLogin then return true end
    if db.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater") then return true end
    return false
end

local function WriteStackingToDB(enemy, friendly)
    local db = BetterBlizzPlatesDB
    db.bitfields = db.bitfields or {}
    db.bitfields[STACKING_CVAR] = db.bitfields[STACKING_CVAR] or {}
    local bits = db.bitfields[STACKING_CVAR]
    bits[tostring(StackIndex("Enemy"))] = enemy
    bits[tostring(StackIndex("Friendly"))] = friendly
end

function BBP.SaveNameplateToggleCVar(cvarName, value)
    local db = BetterBlizzPlatesDB
    if not db then return false end
    if cvarName == STACKING_CVAR then
        local enemy, friendly = LiveStackBit("Enemy"), LiveStackBit("Friendly")
        WriteStackingToDB(enemy, friendly)
        local setKey = BBP.GetActiveNameplateToggleSetKey()
        if setKey and type(db[setKey]) == "table" then
            db[setKey].stackingEnemy = enemy
            db[setKey].stackingFriendly = friendly
            BBP.lastAppliedNameplateToggles = nil
        end
        if BBP.SyncStackingCheckboxes then BBP.SyncStackingCheckboxes() end
        return true
    end
    if not BBP.nameplateToggleCVarLookup[cvarName] then return false end
    if cvarName == "nameplateShowFriendlyPlayers" then
        local category = BBP.DetectNameplateToggleCategory()
        if not categoryByKey[category].available then category = "bg" end
        local setKey = SetKey(category)
        if type(db[setKey]) ~= "table" then db[setKey] = NewDefaultSet() end
        db[setKey].nameplateShowFriendlyPlayers = IsOn(value)
        BBP.lastAppliedNameplateToggles = nil
        BBP.RefreshFriendlyToggleUI()
        return true
    end
    local setKey = BBP.GetActiveNameplateToggleSetKey()
    if not setKey then return false end
    if type(db[setKey]) ~= "table" then db[setKey] = NewDefaultSet() end
    db[setKey][cvarName] = IsOn(value)
    BBP.lastAppliedNameplateToggles = nil
    return true
end

function BBP.SaveNameplateToggleStacking(which, value)
    local db = BetterBlizzPlatesDB
    if not db then return end
    local setKey = BBP.GetActiveNameplateToggleSetKey()
    if not setKey or type(db[setKey]) ~= "table" then return end
    db[setKey][which == "Enemy" and "stackingEnemy" or "stackingFriendly"] = value and true or false
    BBP.lastAppliedNameplateToggles = nil
end

local function SetIfChanged(cvar, value)
    if not CVarExists(cvar) then return end
    if C_CVar.GetCVar(cvar) ~= value then
        C_CVar.SetCVar(cvar, value)
    end
end

local function ApplyNameplateToggles(target)
    local wasTracking = BBP.CVarTrackingDisabled
    BBP.CVarTrackingDisabled = true
    for _, cvar in ipairs(BBP.nameplateToggleCVarList) do
        SetIfChanged(cvar, target[cvar] and "1" or "0")
    end
    for _, cvar in ipairs(toggleMinionChildren) do
        SetIfChanged(cvar, target[cvar] and "1" or "0")
    end
    if LiveStackBit("Enemy") ~= target.stackingEnemy then
        C_CVar.SetCVarBitfield(STACKING_CVAR, StackIndex("Enemy"), target.stackingEnemy)
    end
    if LiveStackBit("Friendly") ~= target.stackingFriendly then
        C_CVar.SetCVarBitfield(STACKING_CVAR, StackIndex("Friendly"), target.stackingFriendly)
    end
    WriteStackingToDB(target.stackingEnemy, target.stackingFriendly)
    BBP.CVarTrackingDisabled = wasTracking
    if BBP.SyncStackingCheckboxes then BBP.SyncStackingCheckboxes() end
end

local totemPvPCVarNoticeShown
local function AnnounceTotemPvPCVars()
    if totemPvPCVarNoticeShown then return end
    totemPvPCVarNoticeShown = true
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Totem Indicator needs Enemy Totems shown and Enemy Minions, Guardians and Minus hidden, so your enemy nameplate visibility CVars were changed for PvP. They are put back when you leave.")
end

local toggleEventFrame = CreateFrame("Frame")

function BBP.BuildNameplateToggleTarget(active, category)
    local db = BetterBlizzPlatesDB
    local source = db[SetKey(active)] or {}
    local target = {}
    for _, cvar in ipairs(BBP.nameplateToggleCVarList) do
        target[cvar] = source[cvar] and true or false
    end
    target.stackingEnemy = source.stackingEnemy and true or false
    target.stackingFriendly = source.stackingFriendly and true or false

    local friendlyCategory = (categoryByKey[category] and categoryByKey[category].available) and category or "bg"
    local friendlySource = db[SetKey(friendlyCategory)]
    target.nameplateShowFriendlyPlayers = (friendlySource and friendlySource.nameplateShowFriendlyPlayers) and true or false

    local inPvE = category == "dungeon" or category == "raid"
    if inPvE and db.friendlyHideHealthBar and not db.doNotHideFriendlyHealthbarInPve then
        target[ONLY_NAME_CVAR] = true
    end

    local catInfo = categoryByKey[category]
    local totemOverride = BBP.totemIndicatorPvPCVars and catInfo and catInfo.pvp and db.totemIndicator
    local totemDiffers = false
    if totemOverride then
        for cvar, wanted in pairs(BBP.totemIndicatorPvPCVars) do
            if target[cvar] ~= wanted then totemDiffers = true end
            target[cvar] = wanted
        end
    end
    return target, totemOverride, totemDiffers
end

function BBP.UpdateNameplateToggles(force, explicit)
    local db = BetterBlizzPlatesDB
    if not db or not BBP.variablesLoaded then return end
    if not explicit and BBP.NameplateTogglesDisabled() then return end
    if explicit then force = true end

    if InCombatLockdown() then
        toggleEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local active = BBP.RefreshNameplateToggleSet()
    if not active then
        BBP.lastAppliedNameplateToggles = nil
        return
    end

    local target, totemOverride, totemDiffers = BBP.BuildNameplateToggleTarget(active, BBP.nameplateToggleCategory)
    if totemDiffers then AnnounceTotemPvPCVars() end

    local signature = active .. (totemOverride and "+totem" or "")
        .. (target.stackingEnemy and "1" or "0") .. (target.stackingFriendly and "1" or "0")
    for _, cvar in ipairs(BBP.nameplateToggleCVarList) do
        signature = signature .. (target[cvar] and "1" or "0")
    end
    if not force and BBP.lastAppliedNameplateToggles == signature then return end
    BBP.lastAppliedNameplateToggles = signature

    ApplyNameplateToggles(target)
end

function BBP.EnableTotemIndicatorCVars()
    local db = BetterBlizzPlatesDB
    if not db then return end

    local changed = false
    BBP.ForEachNameplateToggleSet(function(set)
        if not set.nameplateShowEnemyTotems then
            set.nameplateShowEnemyTotems = true
            changed = true
        end
    end)

    if changed then
        BBP.lastAppliedNameplateToggles = nil
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \"Enemy Totems\" nameplates turned on in every content type. You can change that in the \"CVar Control\" section of the addon.")
    end

    BBP.UpdateNameplateToggles(true, true)
end

local function DelayedToggleCheck()
    BBP.UpdateNameplateToggles()
end

toggleEventFrame:RegisterEvent("VARIABLES_LOADED")
toggleEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
toggleEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
toggleEventFrame:RegisterEvent("ZONE_CHANGED")
toggleEventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
toggleEventFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
toggleEventFrame:SetScript("OnEvent", function(self, event)
    if event == "VARIABLES_LOADED" then
        local db = BetterBlizzPlatesDB
        if BBP.nameplateToggleMigrationPending and db and not db.nameplateTogglesMigrated then
            BBP.nameplateToggleMigrationPending = nil
            BBP.MigrateNameplateToggles(db)
            BBP.InitNameplateToggles()
        end
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        BBP.UpdateNameplateToggles(true)
        return
    end
    BBP.UpdateNameplateToggles(event == "PLAYER_ENTERING_WORLD")
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_BATTLEGROUND" then
        C_Timer.After(1.5, DelayedToggleCheck)
    end
end)
