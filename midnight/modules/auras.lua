local LSM = LibStub("LibSharedMedia-3.0")

local AF = AuraUtil.AuraFilters
local CreateFilterString = AuraUtil.CreateFilterString
local FlowDirection = AnchorUtil.FlowDirection
local FlowLayoutAxis = AnchorUtil.FlowLayoutAxis
local DispelStyle = Enum.CustomAuraButtonDispelTypeTextureStyle

local strsub = string.sub

local CDM = {
    mask      = "UI-HUD-CoolDownManager-Mask",
    bezel     = "UI-HUD-CoolDownManager-IconOverlay",
    swipe     = "Interface\\HUD\\UI-HUD-CoolDownManager-Icon-Swipe",
    edge      = "Interface\\Cooldown\\UI-HUD-ActionBar-SecondaryCooldown",
    flatSwipe = "Interface\\Buttons\\WHITE8X8",
}

local BEZEL = { base = 25, insetX = 6, insetY = 5, trimLeft = 0.5, trimRight = 0.5, trim = 0.5 }

local BORDER_THICKNESS  = 1
local MILLISECOND_THRESHOLD = 6
local EDGE_SCALE        = 1.4142
local COUNTDOWN_FONT    = "GameFontHighlightOutline"
local COUNTDOWN_FONT_SIZE = 12
local DISPEL_BORDER_ATLAS = "orderhalltalents-spellborder-yellow"
local DISPEL_BORDER_INSET = 0.05

local GLOW_ATLAS        = "newplayertutorial-drag-slotgreen"
local PURGE_ATLAS       = "newplayertutorial-drag-slotblue"
local PANDEMIC_ATLAS    = GLOW_ATLAS

local AURA_ITEM_SIZE    = 25

local DEBUFFS, BUFFS, BUFFROW, CC = "debuffs", "buffs", "buffrow", "cc"
local CONTAINER_KINDS = { DEBUFFS, BUFFS, BUFFROW, CC }
local function IsBuffKind(kind)
    return kind == BUFFS or kind == BUFFROW
end

local ENLARGED_GROUPS = {
    EnlargedImportant = true, EnlargedImportantMine = true,
    Enlarged = true, EnlargedMine = true,
}

local DEBUFF_GROUPS = { "CC", "OtherCC", "Important",
                        "WatchPandemic", "WatchImportantMine", "WatchImportant",
                        "Watch", "WatchMine", "Purgeable", "Mine", "Others",
                        "EnlargedImportant", "EnlargedImportantMine", "Enlarged", "EnlargedMine" }
local BUFF_GROUPS   = { "DefBig", "DefExt", "Important" }
local BUFFROW_GROUPS = { "DefBig", "DefExt", "Important",
                         "WatchPandemic", "WatchImportantMine", "WatchImportant",
                         "Watch", "WatchMine", "Purgeable", "Mine", "Others",
                         "EnlargedImportant", "EnlargedImportantMine", "Enlarged", "EnlargedMine" }
local CC_GROUPS     = { "CC", "OtherCC" }

local function IsCCGroup(kind, groupKey)
    if kind == CC then return true end
    return kind == DEBUFFS and (groupKey == "CC" or groupKey == "OtherCC")
end

local GROUPS_BY_KIND = {
    [DEBUFFS] = DEBUFF_GROUPS,
    [BUFFS]   = BUFF_GROUPS,
    [BUFFROW] = BUFFROW_GROUPS,
    [CC]      = CC_GROUPS,
}

local DRAW_ORDER = {
    [DEBUFFS] = {
        enlarged = { "EnlargedImportant", "EnlargedImportantMine", "Enlarged", "EnlargedMine" },
        rest     = { "CC", "OtherCC", "Important",
                     "WatchImportant", "WatchImportantMine", "WatchPandemic", "Watch", "WatchMine",
                     "Purgeable", "Mine", "Others" },
    },
    [BUFFROW] = {
        enlarged = { "EnlargedImportant", "EnlargedImportantMine", "Enlarged", "EnlargedMine" },
        rest     = { "Important", "DefBig", "DefExt",
                     "WatchImportant", "WatchImportantMine", "WatchPandemic", "Watch", "WatchMine",
                     "Purgeable", "Mine", "Others" },
    },
    [BUFFS] = { rest = BUFF_GROUPS },
    [CC]    = { rest = CC_GROUPS },
}

local function BuildLayoutIndex(enlargedFirst)
    local out = {}
    for kind, spec in pairs(DRAW_ORDER) do
        local map, index = {}, 1

        local function Append(list)
            if not list then return end
            for _, groupKey in ipairs(list) do
                map[groupKey] = index
                index = index + 1
            end
        end

        if enlargedFirst then Append(spec.enlarged) end
        Append(spec.rest)
        if not enlargedFirst then Append(spec.enlarged) end

        out[kind] = map
    end
    return out
end

local LAYOUT_INDEX = {
    [true]  = BuildLayoutIndex(true),
    [false] = BuildLayoutIndex(false),
}

local GLOW_TIERS = {
    [DEBUFFS] = { CC = "cc", OtherCC = "cc", Important = "important",
                  WatchImportant = "important", WatchImportantMine = "important",
                  EnlargedImportant = "enlarged", EnlargedImportantMine = "enlarged" },
    [BUFFS]   = { DefBig = "defensive", DefExt = "defensive", Important = "important" },
    [BUFFROW] = { DefBig = "defensive", DefExt = "defensive", Important = "important",
                  WatchImportant = "important", WatchImportantMine = "important",
                  EnlargedImportant = "enlarged", EnlargedImportantMine = "enlarged" },
    [CC]      = { CC = "cc", OtherCC = "cc" },
}

local WHITELIST_GLOW_GROUPS = {
    WatchImportant = true, WatchImportantMine = true,
    EnlargedImportant = true, EnlargedImportantMine = true,
}

local BUFF_STACK_LEVELS = { Important = 3, DefBig = 2, DefExt = 1 }
local CC_STACK_LEVELS = { CC = 2, OtherCC = 1 }
local PANDEMIC_GROUPS = {
    [DEBUFFS] = { Mine = true, WatchMine = true, WatchPandemic = true,
                  WatchImportantMine = true, EnlargedMine = true, EnlargedImportantMine = true },
    [BUFFROW] = { Mine = true, WatchMine = true, WatchPandemic = true,
                  WatchImportantMine = true, EnlargedMine = true, EnlargedImportantMine = true },
}

local SORT_METHODS = {
    default   = { AuraContainerSortMethod.Default,        AuraContainerSortDirection.Normal },
    expires   = { AuraContainerSortMethod.ExpirationOnly, AuraContainerSortDirection.Normal },
    lastest   = { AuraContainerSortMethod.ExpirationOnly, AuraContainerSortDirection.Reverse },
}

local DISPEL_KEYS = { "None", "Magic", "Curse", "Disease", "Poison", "Bleed" }
local PURGE = {
    dispels = {
        { spell = 370,    types = { "Magic" } },                -- Purge (Shaman)
        { spell = 528,    types = { "Magic" } },                -- Dispel Magic (Priest)
        { spell = 30449,  types = { "Magic" } },                -- Spellsteal (Mage)
        { spell = 278326, types = { "Magic" } },                -- Consume Magic (Demon Hunter)
        { spell = 19505,  types = { "Magic" }, pet = true },    -- Devour Magic (Felhunter)
        { spell = 19801,  types = { "Magic", "Enrage" } },      -- Tranquilizing Shot (Hunter)
        { spell = 2908,   types = { "Enrage" } },               -- Soothe (Druid)
        { spell = 5938,   types = { "Enrage" } },               -- Shiv (Rogue)
    },
    types = { "Magic", "Enrage" },
    asset = { asset = PURGE_ATLAS },
    own = {},
    signature = "",
}
PURGE.all = { Magic = PURGE.asset, Enrage = PURGE.asset }

local function RefreshOffensiveDispels()
    local own, parts = {}, {}

    for _, entry in ipairs(PURGE.dispels) do
        if IsSpellKnownOrOverridesKnown(entry.spell, entry.pet) then
            for _, dispelType in ipairs(entry.types) do own[dispelType] = true end
        end
    end

    for _, dispelType in ipairs(PURGE.types) do
        if own[dispelType] then parts[#parts + 1] = dispelType end
    end

    local signature = table.concat(parts, ",")
    if signature == PURGE.signature then return false end
    PURGE.signature = signature

    wipe(PURGE.own)
    for _, dispelType in ipairs(parts) do PURGE.own[dispelType] = PURGE.asset end
    return true
end

local S = {}
BBP.auraSettings = S

local inPvEInstance = false

local function RefreshPvEState()
    local inInstance, instanceType = IsInInstance()
    local now = (inInstance and (instanceType == "party" or instanceType == "raid"
        or instanceType == "scenario")) and true or false
    if now == inPvEInstance then return false end
    inPvEInstance = now
    return true
end

local GetDurationCurve

local function GetColor(key, r, g, b, a)
    local c = BetterBlizzPlatesDB[key]
    if type(c) == "table" then
        return c[1] or c.r or r, c[2] or c.g or g, c[3] or c.b or b, c[4] or c.a or a
    end
    return r, g, b, a
end

local importantGeneralBuffs = {
    [156621] = true, -- Alliance Flag
    [434339] = true, -- Deephaul Crystal
    [156618] = true, -- Horde Flag
    [34976]  = true, -- Netherstorm Flag
    [188501] = true, -- Spectral Sight
}
local importantGeneralDebuffs = {
    [121164] = true, -- Orb of Power
    [121175] = true, -- Orb of Power
    [121176] = true, -- Orb of Power
    [121177] = true, -- Orb of Power
    [372048] = true, -- Oppressing Roar
    [212182] = true, -- Smoke Bomb
    [359053] = true, -- Smoke Bomb
    [383005] = true, -- Chrono Loop
}

local defaultOwnDebuffs = {
    [257284] = true, -- Hunter's Mark
}

local defaultOtherCC = {
    -- CC
    [383005] = true, -- Chrono Loop (Mage)
    -- Disarms
    [207777] = true, -- Dismantle (Rogue)
    [236077] = true, -- Disarm (Warrior)
    [233759] = true, -- Grapple Weapon (Monk)
    [407028] = true, -- Sticky Tar Bomb (Hunter)
    [209749] = true, -- Faerie Swarm (Druid)
}

local categorySets = {
    watchBuff = {},
    watchDebuff = {},
    ownDebuff = {},
    otherCC = {},
}
local categorySafe = {
    watchBuff = {},
    watchDebuff = {},
    ownDebuff = {},
    otherCC = {},
}
BBP.auraCategorySets = categorySets

local function FillSet(dst, src)
    for spellID in pairs(src) do dst[spellID] = true end
end

local AURA_LIST_FLAGS = { "onlyMine", "pandemic", "important", "enlarged" }

function BBP.NormalizeAuraList(list)
    local normalized = {}
    if type(list) ~= "table" then return normalized end

    local keysAreSpellIDs = #list == 0

    for key, entry in pairs(list) do
        if type(entry) == "table" then
            local spellID = tonumber(entry.id) or (keysAreSpellIDs and tonumber(key)) or nil
            if spellID then
                local flags = type(entry.flags) == "table" and entry.flags or entry
                local newEntry = { id = spellID }

                if type(entry.name) == "string" and entry.name ~= "" then
                    newEntry.name = entry.name
                end
                if type(entry.comment) == "string" and entry.comment ~= "" then
                    newEntry.comment = entry.comment
                end
                for _, flag in ipairs(AURA_LIST_FLAGS) do
                    if flags[flag] then newEntry[flag] = true end
                end

                normalized[spellID] = newEntry
            end
        end
    end

    return normalized
end

function BBP.EnsureAuraListsKeyed()
    local converted = false
    for _, listName in ipairs({ "auraBlacklist", "auraWhitelist" }) do
        local list = BetterBlizzPlatesDB[listName]
        if type(list) ~= "table" then
            BetterBlizzPlatesDB[listName] = {}
        elseif #list > 0 then
            BetterBlizzPlatesDB[listName] = BBP.NormalizeAuraList(list)
            converted = true
        end
    end
    if converted then
        BBP.auraListNeedsUpdate = true
    end
    return converted
end

local function CollectList(listName, into, dst)
    local list = BetterBlizzPlatesDB[listName]
    if type(list) ~= "table" then return end
    for key, entry in pairs(list) do
        local spellID = type(entry) == "table" and (tonumber(entry.id) or tonumber(key))
        if spellID then
            if not dst then
                into[spellID] = true
            else
                local onlyMine = entry.onlyMine
                local important = entry.important
                local enlarged = entry.enlarged

                local bucket
                if enlarged then
                    if important then
                        bucket = onlyMine and dst.enlargedImportantMine or dst.enlargedImportant
                    else
                        bucket = onlyMine and dst.enlargedMine or dst.enlarged
                    end
                elseif important then
                    bucket = onlyMine and dst.importantMine or dst.important
                elseif onlyMine then
                    bucket = dst.mine
                else
                    bucket = into
                end
                bucket[spellID] = true

                if not important and not enlarged and entry.pandemic then
                    dst.pandemic[spellID] = true
                end
            end
        end
    end
end

function BBP.UpdateImportantBuffsAndCCTables()
    for _, set in pairs(categorySets) do wipe(set) end

    FillSet(categorySets.watchBuff, importantGeneralBuffs)
    FillSet(categorySets.watchDebuff, importantGeneralDebuffs)
    FillSet(categorySets.ownDebuff, defaultOwnDebuffs)
    FillSet(categorySets.otherCC, defaultOtherCC)
end

local function IsNeverSecret(spellID)
    local ok, level = pcall(C_Secrets.GetSpellAuraSecrecy, spellID)
    return ok and level == Enum.SecrecyLevel.NeverSecret
end

local mergeCache = {}

local function MergeSets(...)
    local n = select("#", ...)
    if n == 1 then return (select(1, ...)) end

    local node = mergeCache
    for i = 1, n do
        local src = select(i, ...) or false
        local nxt = node[src]
        if not nxt then nxt = {}; node[src] = nxt end
        node = nxt
    end
    if not node.result then
        local merged = {}
        for i = 1, n do
            local src = select(i, ...)
            if src then for k in pairs(src) do merged[k] = true end end
        end
        node.result = merged
    end
    return node.result
end

local subtractCache = {}

local function SubtractSets(from, taken)
    if not taken or next(taken) == nil then return from end

    local byTaken = subtractCache[from]
    if not byTaken then byTaken = {}; subtractCache[from] = byTaken end

    local out = byTaken[taken]
    if not out then
        out = {}
        for id in pairs(from) do
            if not taken[id] then out[id] = true end
        end
        byTaken[taken] = out
    end
    return out
end

local function SetIsEmpty(set)
    return next(set) == nil
end

local function RefillSafeSubset(dst, src)
    wipe(dst)
    local any = false
    for spellID in pairs(src) do
        if IsNeverSecret(spellID) then dst[spellID] = true; any = true end
    end
    return any
end

local function ReadFilterBlock(prefix)
    local db = BetterBlizzPlatesDB
    return {
        enable        = db[prefix .. "Enable"],
        blacklist     = db[prefix .. "FilterBlacklist"],
        watchlist     = db[prefix .. "FilterWatchList"],
        important     = db[prefix .. "FilterImportantBuffs"],
        cc            = db[prefix .. "FilterCC"],
        defensives    = db[prefix .. "FilterDefensives"],
        purgeable     = db[prefix .. "FilterPurgeable"],
        anyDispel     = db[prefix .. "FilterPurgeableAny"],
        blizzard      = db[prefix .. "FilterBlizzard"],
        lessThanMin   = db[prefix .. "FilterLessMinite"],
        onlyMine      = db[prefix .. "FilterOnlyMe"],
    }
end

function BBP.ApplyAuraTooltipSpellID(allowOff)
    local want = BetterBlizzPlatesDB.auraTooltipSpellID and "1" or "0"
    if want == "0" and not allowOff then return end
    if C_CVar.GetCVar("tooltipShowAuraSpellIDs") ~= want then
        C_CVar.SetCVar("tooltipShowAuraSpellIDs", want)
    end
end

function BBP.UpdateUserAuraSettings()
    local db = BetterBlizzPlatesDB

    BBP.ApplyAuraTooltipSpellID()

    S.enabled = db.enableNameplateAuraCustomisation and true or false

    if db.nameplateAuraSquare == nil then db.nameplateAuraSquare = true end
    if db.nameplateAuraSquare then
        S.debuffWidth, S.debuffHeight = AURA_ITEM_SIZE, AURA_ITEM_SIZE
        S.debuffTexCoord = { 0.10, 0.90, 0.10, 0.90 }
    elseif db.nameplateAuraTaller then
        S.debuffWidth, S.debuffHeight = 20, 15.5
        S.debuffTexCoord = { 0.05, 0.95, 0.15, 0.82 }
    else
        S.debuffWidth, S.debuffHeight = 20, 14
        S.debuffTexCoord = { 0.05, 0.95, 0.10, 0.60 }
    end

    S.pixelBorder = db.nameplateAuraPixelBorder
    S.buffWidth, S.buffHeight = AURA_ITEM_SIZE, AURA_ITEM_SIZE
    S.buffTexCoord = { 0.10, 0.90, 0.10, 0.90 }
    S.gapX = db.nameplateAuraWidthGap or 4
    S.gapY = db.nameplateAuraHeightGap or 4
    S.perRowEnemy = db.nameplateAuraRowAmount or 5
    S.perRowFriendly = db.nameplateAuraRowFriendlyAmount or S.perRowEnemy
    S.debuffLimit = db.maxAurasOnNameplate or 12
    S.buffRowLimit = db.maxBuffsOnNameplate or S.debuffLimit
    S.buffLimit = db.nameplateAuraBuffLimit or 3
    S.ccLimit = db.ccIconLimit or 2
    S.debuffPadX = db.nameplateDebuffXPadding or 0
    S.centerEnemyBuffs = db.nameplateAurasEnemyCenteredBuffs
    S.centerEnemyDebuffs = db.nameplateAurasEnemyCenteredDebuffs
    S.centerFriendlyBuffs = db.nameplateAurasFriendlyCenteredBuffs
    S.centerFriendlyDebuffs = db.nameplateAurasFriendlyCenteredDebuffs
    S.blueBuffBorder = db.otherNpBuffBlueBorder and true or false
    S.rightToLeft = db.nameplateAuraRightToLeft
    S.growDown = db.nameplateAuraGrowDownwards and true or false
    S.enlargedScale = db.nameplateAuraEnlargedScale or 1
    S.enlargedSquare = db.nameplateAuraEnlargedSquare ~= false
    S.sortEnlargedFirst = db.sortEnlargedAurasFirst ~= false
    S.enlargeAllCC = db.enlargeAllCC and true or false
    S.enlargeAllImportantBuffs = db.enlargeAllImportantBuffs and true or false
    S.scale = db.bbpAuraScale or 1
    S.buffScale = db.nameplateAuraBuffScale or 1
    S.debuffScale = db.nameplateAuraDebuffScale or 1
    S.countScale = db.nameplateAuraCountScale or 1
    S.showStack = db.npAuraShowStackText ~= false
    S.stackX = db.npAuraStackTextXPos or 0
    S.stackY = db.npAuraStackTextYPos or 0
    S.stackAlign = db.npAuraStackTextAlign or "RIGHT"
    S.stackColor = { GetColor("npAuraStackTextColor", 1, 1, 1, 1) }
    S.targetScaleOn = db.targetNameplateAuraScaleEnabled
    S.targetScale = db.targetNameplateAuraScale or 1
    S.ccIconScale = db.ccIconScale or 1.35
    S.ccIconAnchor = db.ccIconAnchor or "RIGHT"
    S.ccIconX = db.ccIconXPos or 0
    S.ccIconY = db.ccIconYPos or 0
    S.buffIconScale = db.buffIconScale or 1.35
    S.buffIconAnchor = db.buffIconAnchor or "LEFT"
    S.buffIconX = db.buffIconXPos or 0
    S.buffIconY = db.buffIconYPos or 0
    S.combineBigIcons = db.combineBigAuraIcons and true or false
    S.combinedAnchor = db.combinedBigIconAnchor or "RIGHT"
    S.moveBuffRow = db.moveNormalBuffs and true or false
    S.buffRowAnchor = db.moveNormalBuffsAnchor or "LEFT"
    S.showCdText = db.showDefaultCooldownNumbersOnNpAuras ~= false
    S.cdTextScale = db.defaultNpAuraCdSize or 0.6
    S.cdTextScaleBig = db.bigNpAuraCdSize or 0.6
    S.cdTextBigOnly = db.npAuraCdTextBigOnly and true or false
    S.hideSwipe = db.hideNpAuraSwipe
    S.blizzardCdText = db.nameplateAuraUseBlizzardCdText
    S.timerColor = db.nameplateAuraTimerColor ~= false
    S.timerBase = { GetColor("nameplateAuraTimerBaseColor", 1, 0.82, 0, 1) }
    S.timerLow = { GetColor("nameplateAuraTimerLowColor", 1, 0.1, 0.1, 1) }
    S.timerThreshold = db.nameplateAuraTimerLowThreshold or 6
    S.hideLongTimers = db.nameplateAuraHideLongDurationText ~= false
    S.buffsOnNpcs = db.nameplateAuraBuffsOnNpcs ~= false
    S.buffsOnEnemyPlayers = db.nameplateAuraBuffsOnEnemyPlayers ~= false
    S.buffsOnFriendlyPlayers = db.nameplateAuraBuffsOnFriendlyPlayers ~= false
    S.ccOnNpcs = db.nameplateAuraCCOnNpcs ~= false
    S.ccOnEnemyPlayers = db.nameplateAuraCCOnEnemyPlayers ~= false
    S.ccOnFriendlyPlayers = db.nameplateAuraCCOnFriendlyPlayers ~= false
    S.inPvE = inPvEInstance
    S.blizzardCCInPvE = db.nameplateAuraCCBlizzardInPvE and true or false
    S.blizzardBuffsInPvE = db.nameplateAuraBuffsBlizzardInPvE and true or false
    S.msBuffs = db.nameplateAuraMillisecondsBuffs ~= false
    S.msCC = db.nameplateAuraMillisecondsCC ~= false
    S.debuffPadding = tonumber(db.bbpDebuffPadding) or 0
    S.ccOverlay = (db.partyPointer and db.partyPointerCCAuras) and true or false
    S.ccOverlayReplacesIcon = S.ccOverlay and not inPvEInstance
    S.hideTooltips = db.hideNameplateAuraTooltip
    S.colorBorderByType = db.npColorAuraBorder
    S.purgeGlow = db.otherNpBuffPurgeGlow
    S.purgeGlowAlways = db.alwaysShowPurgeTexture
    S.purgeColor = db.npAuraPurgeGlowColorEnabled and { GetColor("npAuraPurgeGlowRGB", 0.2, 0.6, 1, 1) } or false

    PURGE.asset.asset = S.purgeColor and GLOW_ATLAS or PURGE_ATLAS

    if S.purgeColor then
        local c = S.purgeColor
        local color = CreateColor(c[1], c[2], c[3], c[4] or 1)
        PURGE.colorMap = {}
        for _, dispelType in ipairs(PURGE.types) do PURGE.colorMap[dispelType] = color end
    else
        PURGE.colorMap = nil
    end

    RefreshOffensiveDispels()
    S.purgeTypes = PURGE.signature
    S.pandemicGlow = db.otherNpdeBuffPandemicGlow and true or false
    S.pandemicColor = { GetColor("nameplateAuraPandemicGlowRGB", 1, 0, 0, 1) }
    S.splitPandemic = false

    S.sort = SORT_METHODS.default
    if db.sortDurationAurasReverse then S.sort = SORT_METHODS.lastest
    elseif db.sortDurationAuras then S.sort = SORT_METHODS.expires end

    S.playersOnly = db.nameplateAuraPlayersOnly
    S.playersOnlyShowTarget = db.nameplateAuraPlayersOnlyShowTarget

    S.glow = {
        defensive = { db.nameplateAuraDefensiveGlow and true or false, { GetColor("nameplateAuraDefensiveGlowRGB", 1, 0.662, 0.945, 1) } },
        important = { db.nameplateAuraImportantGlow and true or false, { GetColor("nameplateAuraImportantGlowRGB", 0, 1, 0, 1) } },
        cc        = { db.nameplateAuraCCGlow and true or false,        { GetColor("nameplateAuraCCGlowRGB", 1, 0.874, 0, 1) } },
        enlarged  = { true,                                            { GetColor("nameplateAuraEnlargedGlowRGB", 1, 0.5, 0, 1) } },
    }
    S.ccGlowDispelColor = db.nameplateAuraCCGlowDispelColor and true or false

    S.enemy = { buff = ReadFilterBlock("otherNpBuff"), debuff = ReadFilterBlock("otherNpdeBuff") }
    S.friendly = { buff = ReadFilterBlock("friendlyNpBuff"), debuff = ReadFilterBlock("friendlyNpdeBuff") }
    S.blizzardOnlyMine = db.blizzardDefaultFilterOnlyMine

    S.prdEnabled = S.enabled and db.prdAurasEnabled and true or false
    S.prdScale = db.prdAuraScale or 1
    S.prdX = db.prdAuraXPos or 0
    S.prdY = db.prdAuraYPos or 0
    S.prdPerRow = db.prdAuraRowAmount or 6
    S.prdLimit = db.prdAuraLimit or 6

    S.stackFont = db.npAuraStackFontEnabled and LSM:Fetch(LSM.MediaType.FONT, db.npAuraStackFont) or nil
    S.cdFont = db.npAuraCdFontEnabled and LSM:Fetch(LSM.MediaType.FONT, db.npAuraCdFont) or nil

    BBP.UpdateImportantBuffsAndCCTables()
    BBP.RefreshSpellLists()
    S.splitPandemic = (not S.pandemicGlow) and BBP.auraLists.anyPandemic and true or false
    BBP.UpdateAuraTypeColors()
    GetDurationCurve()
end

local listGeneration = 0

local lists = {
    blacklist = {},
    blacklistSafe = {},
    watch = {},
    watchSafe = {},
    watchMine = {},
    watchMineSafe = {},
    watchPandemic = {},
    watchPandemicSafe = {},
    watchImportant = {},
    watchImportantSafe = {},
    watchImportantMine = {},
    watchImportantMineSafe = {},
    watchEnlarged = {},
    watchEnlargedSafe = {},
    watchEnlargedMine = {},
    watchEnlargedMineSafe = {},
    watchEnlargedImportant = {},
    watchEnlargedImportantSafe = {},
    watchEnlargedImportantMine = {},
    watchEnlargedImportantMineSafe = {},
}
BBP.auraLists = lists

local WHITELIST_BUCKETS = {
    mine                   = "watchMine",
    pandemic               = "watchPandemic",
    important              = "watchImportant",
    importantMine          = "watchImportantMine",
    enlarged               = "watchEnlarged",
    enlargedMine           = "watchEnlargedMine",
    enlargedImportant      = "watchEnlargedImportant",
    enlargedImportantMine  = "watchEnlargedImportantMine",
}

local whitelistDst = {}
for field, listKey in pairs(WHITELIST_BUCKETS) do
    whitelistDst[field] = lists[listKey]
end

local function ListSignature(listName, parts)
    local list = BetterBlizzPlatesDB[listName]
    if type(list) ~= "table" then return end
    for key, entry in pairs(list) do
        if type(entry) == "table" then
            parts[#parts + 1] = tostring(entry.id or key)
            parts[#parts + 1] = (entry.onlyMine and "m" or "")
                .. (entry.pandemic and "p" or "")
                .. (entry.important and "i" or "")
                .. (entry.enlarged and "e" or "")
        end
    end
end

local listSignature

function BBP.RefreshSpellLists()
    BBP.EnsureAuraListsKeyed()

    local parts = { "bl" }
    ListSignature("auraBlacklist", parts)
    parts[#parts + 1] = "wl"
    ListSignature("auraWhitelist", parts)
    local signature = table.concat(parts, ":")

    if listSignature == signature then return end
    listSignature = signature
    listGeneration = listGeneration + 1
    wipe(mergeCache)
    wipe(subtractCache)

    wipe(lists.blacklist)
    wipe(lists.watch)
    for _, listKey in pairs(WHITELIST_BUCKETS) do wipe(lists[listKey]) end
    CollectList("auraBlacklist", lists.blacklist)
    CollectList("auraWhitelist", lists.watch, whitelistDst)
    lists.anyPandemic = next(lists.watchPandemic) ~= nil

    RefillSafeSubset(lists.blacklistSafe, lists.blacklist)
    RefillSafeSubset(lists.watchSafe, lists.watch)
    for _, listKey in pairs(WHITELIST_BUCKETS) do
        RefillSafeSubset(lists[listKey .. "Safe"], lists[listKey])
    end
    for key, set in pairs(categorySets) do
        RefillSafeSubset(categorySafe[key], set)
    end
end

local dispelColorMapHarmful, dispelColorMapHelpful, ccGlowDispelColorMap

function BBP.UpdateAuraTypeColors()
    local db = BetterBlizzPlatesDB
    local wantBorder = db.npColorAuraBorder and true or false
    local wantCCGlow = (db.nameplateAuraCCGlow and db.nameplateAuraCCGlowDispelColor) and true or false
    if not wantBorder and not wantCCGlow then
        dispelColorMapHarmful, dispelColorMapHelpful, ccGlowDispelColorMap = nil, nil, nil
        return
    end

    local function C(key, r, g, b)
        local cr, cg, cb, ca = GetColor(key, r, g, b, 1)
        return CreateColor(cr, cg, cb, ca or 1)
    end

    local harmful = {
        Magic   = C("npAuraMagicRGB",   0.13, 0.44, 1),
        Poison  = C("npAuraPoisonRGB",  0,    0.52, 0.031),
        Curse   = C("npAuraCurseRGB",   0.47, 0,    0.78),
        Disease = C("npAuraDiseaseRGB", 1,    0.53, 0.14),
        Bleed   = C("npAuraBleedRGB",   0.8,  0.1,  0.1),
        None    = C("npAuraOtherRGB",   0,    0,    0),
    }

    if wantCCGlow then
        local gr, gg, gb, ga = GetColor("nameplateAuraCCGlowRGB", 1, 0.874, 0, 1)
        ga = ga or 1
        ccGlowDispelColorMap = {}
        for _, key in ipairs(DISPEL_KEYS) do
            local c = harmful[key]
            ccGlowDispelColorMap[key] = CreateColor(c.r, c.g, c.b, ga)
        end
        ccGlowDispelColorMap.None = CreateColor(gr, gg, gb, ga)
    else
        ccGlowDispelColorMap = nil
    end

    if not wantBorder then
        dispelColorMapHarmful, dispelColorMapHelpful = nil, nil
        return
    end

    dispelColorMapHarmful = harmful

    local buff = C("npAuraBuffsRGB", 0, 0.67, 1)
    dispelColorMapHelpful = {}
    for _, key in ipairs(DISPEL_KEYS) do dispelColorMapHelpful[key] = buff end
end

local HIDE_LONG_TIMER_FROM = 61

local durationCurve, durationCurveSignature

function GetDurationCurve()
    local base, low = S.timerBase, S.timerLow
    local hideFrom = HIDE_LONG_TIMER_FROM
    local threshold = math.min(S.timerThreshold, hideFrom - 1)

    local signature = string.format("%s|%.2f|%s|%s|%s",
        tostring(S.timerColor), threshold, tostring(S.hideLongTimers),
        table.concat(base, ","), table.concat(low, ","))

    if not durationCurve then
        durationCurve = C_CurveUtil.CreateColorCurve()
        durationCurve:SetType(Enum.LuaCurveType.Step)
    elseif durationCurveSignature == signature then
        return durationCurve
    else
        durationCurve:ClearPoints()
    end
    durationCurveSignature = signature

    local baseColor = CreateColor(base[1], base[2], base[3], base[4] or 1)
    if S.timerColor then
        durationCurve:AddPoint(0, CreateColor(low[1], low[2], low[3], low[4] or 1))
        durationCurve:AddPoint(threshold, baseColor)
    else
        durationCurve:AddPoint(0, baseColor)
    end

    if S.hideLongTimers then
        durationCurve:AddPoint(hideFrom, CreateColor(base[1], base[2], base[3], 0))
    end

    return durationCurve
end

local durationFormatters = {}

local function GetDurationFormatter(showMilliseconds, hideLong)
    local key = (showMilliseconds and "ms" or "plain") .. (hideLong and "+hide" or "")
    if durationFormatters[key] then return durationFormatters[key] end

    local f = C_StringUtil.CreateNumericRuleFormatter()
    local breakpoints = {}
    if showMilliseconds then
        breakpoints[#breakpoints + 1] = { threshold = 0, format = "%.1f" }
    end
    breakpoints[#breakpoints + 1] = {
        threshold = showMilliseconds and MILLISECOND_THRESHOLD or 0,
        format = "%d",
        step = 1,
        rounding = Enum.NumericRuleFormatRounding.Up,
    }
    if hideLong then
        breakpoints[#breakpoints + 1] = { threshold = HIDE_LONG_TIMER_FROM, format = " " }
    end
    f:SetBreakpoints(breakpoints)

    durationFormatters[key] = f
    return f
end

local function CreateBorderEdges(host)
    local edges = {}
    for i = 1, 4 do
        local t = host:CreateTexture(nil, "OVERLAY", nil, 4)
        t:SetColorTexture(1, 1, 1, 1)
        edges[i] = t
    end
    return edges
end

local function ApplyBorderEdgeGeometry(edges, anchor, thickness)
    local top, bottom, left, right = edges[1], edges[2], edges[3], edges[4]
    top:ClearAllPoints()
    top:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", -thickness, 0)
    top:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", thickness, 0)
    top:SetHeight(thickness)

    bottom:ClearAllPoints()
    bottom:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -thickness, 0)
    bottom:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", thickness, 0)
    bottom:SetHeight(thickness)

    left:ClearAllPoints()
    left:SetPoint("TOPRIGHT", anchor, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", 0, 0)
    left:SetWidth(thickness)

    right:ClearAllPoints()
    right:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", 0, 0)
    right:SetWidth(thickness)
end

local function SetBorderEdges(edges, shown, r, g, b)
    for i = 1, 4 do
        if r then edges[i]:SetColorTexture(r, g, b, 1) end
        edges[i]:SetShown(shown)
    end
end

local BLACK_BORDER = { 0, 0, 0 }
local BLUE_BUFF_BORDER = { 0.2, 0.2, 1 }

local function BlueBorderOn(style)
    return (style.blueBorder and not style.glow and not style.colorBorderByType) and true or false
end

local function ColorsEdgesByType(style)
    return (style.colorBorderByType and style.pixelBorder and not style.glow) and true or false
end

local function ColorsDispelBorderByType(style)
    return (style.colorBorderByType and not style.pixelBorder and not style.glow) and true or false
end

local function CreateDispelBorder(host)
    local border = host:CreateTexture(nil, "OVERLAY", nil, 4)
    border:SetAtlas(DISPEL_BORDER_ATLAS, TextureKitConstants.IgnoreAtlasSize)
    border:SetDesaturated(true)
    border:Hide()
    return border
end

local function ApplyDispelBorderGeometry(border, button, width, height)
    local inset = math.max(width, height) * DISPEL_BORDER_INSET
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", button, "TOPLEFT", -inset, inset)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", inset, -inset)
end

local function SetIconMasked(icon, mask, masked)
    if mask.bbpAttached == masked then return end
    mask.bbpAttached = masked
    if masked then
        icon:AddMaskTexture(mask)
    else
        icon:RemoveMaskTexture(mask)
    end
    mask:SetShown(masked)
end

local function ApplyBezelGeometry(bezel, button, width, height)
    local scale = math.max(width, height) / BEZEL.base
    bezel:ClearAllPoints()
    local insetY = (BEZEL.insetY - BEZEL.trim) * scale
    bezel:SetPoint("TOPLEFT", button, "TOPLEFT",
        -(BEZEL.insetX - BEZEL.trimLeft - BEZEL.trim) * scale, insetY)
    bezel:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT",
        (BEZEL.insetX - BEZEL.trimRight - BEZEL.trim) * scale, -insetY)
end

local GLOW_PAD = { row = 2, big = 0, round = 0 }

local function GlowPad(style)
    if not style.pixelBorder then
        return GLOW_PAD.round
    end
    if style.kind == BUFFS or style.kind == CC then
        return GLOW_PAD.big
    end
    return GLOW_PAD.row
end

local function ApplyGlowGeometry(glow, button, width, height, pad)
    pad = pad or 0
    glow:ClearAllPoints()
    glow:SetPoint("TOPLEFT", button, "TOPLEFT", -(width * 0.47 + pad), height * 0.46 + pad)
    glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", width * 0.47 + pad, -(height * 0.46 + pad))
end

local borderDispelOptions = {
    style = DispelStyle.PreserveAsset,
    showWithoutDispelType = true,
}

local glowDispelOptions = {
    style = DispelStyle.PreserveAsset,
    showWithoutDispelType = true,
}

local purgeDispelOptions = {
    style = DispelStyle.CustomAsset,
    showWhenHarmful = false,
    showWhenHelpful = true,
    showWithoutDispelType = false,
}

local function ApplyDispelRegistrations(button, style)
    local signature = 0
    if style.harmful            then signature = signature + 1 end
    if style.colorBorderByType  then signature = signature + 2 end
    if style.purgeGlow          then signature = signature + 4 end
    if style.purgeGlowAlways    then signature = signature + 8 end
    if style.glow               then signature = signature + 16 end
    if style.glowDispelColor    then signature = signature + 32 end
    if style.pixelBorder        then signature = signature + 64 end

    local colorMap = style.harmful and dispelColorMapHarmful or dispelColorMapHelpful
    local glowMap = style.glowDispelColor and ccGlowDispelColorMap or nil
    local purgeKey = style.purgeGlow
        and (style.purgeGlowAlways and "all" or (style.purgeTypes or "")) or ""
    local purgeColorMap = style.purgeGlow and PURGE.colorMap or nil

    if button.bbpDispelSignature == signature and button.bbpDispelColorMap == colorMap
        and button.bbpDispelGlowMap == glowMap and button.bbpPurgeKey == purgeKey
        and button.bbpPurgeColorMap == purgeColorMap then
        return
    end
    button.bbpPurgeKey = purgeKey
    button.bbpDispelSignature = signature
    button.bbpDispelColorMap = colorMap
    button.bbpDispelGlowMap = glowMap
    button.bbpPurgeColorMap = purgeColorMap

    button:ClearDispelTypeTextures()

    if button.bbpGlow and glowMap then
        glowDispelOptions.showWhenHarmful = style.harmful and true or false
        glowDispelOptions.showWhenHelpful = style.harmful and false or true
        glowDispelOptions.customDispelColorMap = glowMap
        button:AddDispelTypeTexture(button.bbpGlow, glowDispelOptions)
    end

    local tintEdges = ColorsEdgesByType(style) and button.bbpBorderEdges
    local tintBorder = ColorsDispelBorderByType(style) and button.bbpDispelBorder

    if tintEdges or tintBorder then
        borderDispelOptions.showWhenHarmful = style.harmful and true or false
        borderDispelOptions.showWhenHelpful = style.harmful and false or true
        borderDispelOptions.customDispelColorMap = colorMap
        if tintEdges then
            for i = 1, 4 do
                button:AddDispelTypeTexture(button.bbpBorderEdges[i], borderDispelOptions)
            end
        else
            button:AddDispelTypeTexture(button.bbpDispelBorder, borderDispelOptions)
        end
    end

    if button.bbpDispelBorder and not tintBorder then
        button.bbpDispelBorder:Hide()
    end

    if button.bbpPurgeGlow then
        local purgeMap = style.purgeGlow
            and (style.purgeGlowAlways and PURGE.all or PURGE.own) or nil
        if purgeMap and next(purgeMap) then
            purgeDispelOptions.customDispelAssetMap = purgeMap
            purgeDispelOptions.customDispelColorMap = purgeColorMap
            button:AddDispelTypeTexture(button.bbpPurgeGlow, purgeDispelOptions)
        else
            button.bbpPurgeGlow:Hide()
        end
    end
end

local function ApplyPandemicRegistration(button, style)
    local pandemic = button.bbpPandemicGlow
    if not pandemic then return end

    if style.pandemicGlow then
        local c = style.pandemicColor
        if c then pandemic:SetVertexColor(c[1], c[2], c[3], c[4] or 1) end
        pandemic:SetAlpha(1)
        if not button.bbpPandemicRegistered then
            button.bbpPandemicRegistered = true
            button:AddPandemicRegion(pandemic)
        end
    elseif button.bbpPandemicRegistered then
        pandemic:SetAlpha(0)
    end
end

local function ApplyCountdownFont(fontString, font)
    local wanted = font or false
    if fontString.bbpFont == wanted then return end
    fontString.bbpFont = wanted
    if font then
        fontString:SetFont(font, COUNTDOWN_FONT_SIZE, "OUTLINE")
    else
        fontString:SetFontObject(COUNTDOWN_FONT)
    end
end

local STACK_ANCHORS = {
    LEFT   = { "BOTTOMLEFT",  -3, -2 },
    CENTER = { "BOTTOM",       0, -2 },
    RIGHT  = { "BOTTOMRIGHT",  3, -2 },
}

local STACK_FONT_SIZE = 12

local function ApplyStackText(count, button, style)
    local anchor = STACK_ANCHORS[style.stackAlign] or STACK_ANCHORS.RIGHT

    count:SetScale(style.countScale or 1)
    count:ClearAllPoints()
    count:SetPoint(anchor[1], button, anchor[1],
        anchor[2] + (style.stackX or 0), anchor[3] + (style.stackY or 0))
    count:SetJustifyH(style.stackAlign or "RIGHT")

    if style.stackFont then
        count:SetFont(style.stackFont, STACK_FONT_SIZE, "OUTLINE")
    else
        count:SetFontObject("NumberFontNormalSmall")
    end

    local c = style.stackColor
    if c then count:SetTextColor(c[1], c[2], c[3], c[4] or 1) end

    count:SetShown(style.showStack)
    count:SetAlpha(style.showStack and 1 or 0)
end

local function ApplyMutableStyle(button, style)
    local w, h = style.width, style.height
    button:SetSize(w, h)

    if button.bbpIcon then
        local tc = style.texCoord
        button.bbpIcon:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
        button.bbpIcon:SetShown(true)
    end

    if button.bbpMask then
        SetIconMasked(button.bbpIcon, button.bbpMask, not style.pixelBorder)
    end

    local glowing = style.glow and true or false

    if button.bbpBezel then
        button.bbpBezel:SetShown(not style.pixelBorder and not glowing)
        ApplyBezelGeometry(button.bbpBezel, button, w, h)
    end

    if button.bbpDispelBorder then
        ApplyDispelBorderGeometry(button.bbpDispelBorder, button, w, h)
    end

    if button.bbpBorderEdges then
        ApplyBorderEdgeGeometry(button.bbpBorderEdges, button, BORDER_THICKNESS)
        if not ColorsEdgesByType(style) then
            local edge = BlueBorderOn(style) and BLUE_BUFF_BORDER or BLACK_BORDER
            SetBorderEdges(button.bbpBorderEdges, style.pixelBorder and not glowing,
                edge[1], edge[2], edge[3])
        end
    end

    if button.bbpCooldown then
        button.bbpCooldown:SetDrawSwipe(not style.hideSwipe)
        button.bbpCooldown:SetDrawEdge(not style.hideSwipe)
        button.bbpCooldown:SetSwipeTexture(style.pixelBorder and CDM.flatSwipe or CDM.swipe)
        button.bbpCooldown:SetSwipeColor(0, 0, 0, 0.5)
        button.bbpCooldown:SetEdgeScale(EDGE_SCALE)

        if style.blizzardCdText then
            local countdown = button.bbpCooldown.GetCountdownFontString
                and button.bbpCooldown:GetCountdownFontString()
            if countdown then countdown:SetScale(style.cdTextScale or 0.6) end
            if button.bbpCooldown.SetCountdownFormatter then
                button.bbpCooldown:SetCountdownFormatter(
                    GetDurationFormatter(style.showMilliseconds, style.hideLongTimers))
            end
        end
        button.bbpCooldown:SetHideCountdownNumbers(not (style.showCdText and style.blizzardCdText))
    end

    if style.stackLevel then
        local parent = button:GetParent()
        if parent then
            button:SetFrameLevel(parent:GetFrameLevel() + style.stackLevel)
        end
    end

    if button.bbpCount then
        ApplyStackText(button.bbpCount, button, style)
    end

    if button.bbpTimer then
        button.bbpTimer:SetScale(style.cdTextScale or 0.6)
        button.bbpTimer:SetShown(style.showCdText and not style.blizzardCdText)
        ApplyCountdownFont(button.bbpTimer, style.cdFont)

        local wantMs = style.showMilliseconds and true or false
        if button.bbpMilliseconds ~= wantMs then
            button.bbpMilliseconds = wantMs
            button:SetDurationText(button.bbpTimer, {
                textFormatter = GetDurationFormatter(wantMs),
                textColor = {
                    curve = GetDurationCurve(),
                    property = Enum.DurationTextBindingProperty.RemainingDuration,
                },
            })
        end
    end

    local glowPad = GlowPad(style)

    if button.bbpGlow then
        ApplyGlowGeometry(button.bbpGlow, button, w, h, glowPad)
        local c = style.glowColor
        if c then button.bbpGlow:SetVertexColor(c[1], c[2], c[3], c[4] or 1) end
        button.bbpGlow:SetShown(style.glow and true or false)
    end

    if button.bbpPurgeGlow then
        ApplyGlowGeometry(button.bbpPurgeGlow, button, w, h, glowPad)
        local c = style.purgeColor
        button.bbpPurgeGlow:SetAtlas(c and GLOW_ATLAS or PURGE_ATLAS)
        button.bbpPurgeGlow:SetDesaturated(c and true or false)
        if c then
            button.bbpPurgeGlow:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
        else
            button.bbpPurgeGlow:SetVertexColor(1, 1, 1, 1)
        end
    end

    if button.bbpPandemicGlow then
        ApplyGlowGeometry(button.bbpPandemicGlow, button, w, h, glowPad)
        ApplyPandemicRegistration(button, style)
    end

    ApplyDispelRegistrations(button, style)

    if button.bbpDispelBorder and not ColorsDispelBorderByType(style) then
        local blue = BlueBorderOn(style) and not style.pixelBorder
        if blue then
            button.bbpDispelBorder:SetVertexColor(
                BLUE_BUFF_BORDER[1], BLUE_BUFF_BORDER[2], BLUE_BUFF_BORDER[3])
        end
        button.bbpDispelBorder:SetShown(blue)
    end

    button:SetHideTooltipInCombat(style.hideTooltips and true or false)
    if not InCombatLockdown() then
        button:SetMouseMotionEnabled(not style.hideTooltips)
    end
end

local function InitAuraButton(button, style)
    button:SetSize(style.width, style.height)
    button:SetFlattensRenderLayers(true)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(button)
    button.bbpIcon = icon
    button:SetIcon(icon)

    local mask = button:CreateMaskTexture()
    mask:SetAllPoints(button)
    mask:SetAtlas(CDM.mask)
    icon:AddMaskTexture(mask)
    mask.bbpAttached = true
    button.bbpMask = mask

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetReverse(true)
    cooldown:SetDrawBling(false)
    cooldown:SetEdgeTexture(CDM.edge)
    button.bbpCooldown = cooldown
    button:SetDurationCooldown(cooldown)

    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    button.bbpOverlay = overlay

    local bezel = overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    bezel:SetAtlas(CDM.bezel)
    button.bbpBezel = bezel

    button.bbpBorderEdges = CreateBorderEdges(overlay)
    button.bbpDispelBorder = CreateDispelBorder(overlay)

    if style.purgeTier then
        local purge = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
        purge:SetAtlas(PURGE_ATLAS)
        purge:Hide()
        button.bbpPurgeGlow = purge
    end

    if style.pandemicTier then
        local pandemic = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
        pandemic:SetAtlas(PANDEMIC_ATLAS)
        pandemic:SetDesaturated(true)
        pandemic:Hide()
        button.bbpPandemicGlow = pandemic
    end

    local count = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    button.bbpCount = count
    button:SetApplicationCount(count)

    if style.glowTier then
        local glow = overlay:CreateTexture(nil, "OVERLAY", nil, 5)
        glow:SetAtlas(GLOW_ATLAS)
        glow:SetDesaturated(true)
        button.bbpGlow = glow
    end

    local timer = overlay:CreateFontString(nil, "OVERLAY", COUNTDOWN_FONT)
    timer:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.bbpTimer = timer
    button.bbpMilliseconds = style.showMilliseconds and true or false
    button:SetDurationText(timer, {
        textFormatter = GetDurationFormatter(button.bbpMilliseconds),
        textColor = {
            curve = GetDurationCurve(),
            property = Enum.DurationTextBindingProperty.RemainingDuration,
        },
    })

    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, 0)
    button:SetCancelAuraButtons(nil)

    ApplyMutableStyle(button, style)
end

local unzoomedTexCoords = setmetatable({}, { __mode = "k" })

local function UnzoomTexCoord(tc)
    local cached = unzoomedTexCoords[tc]
    if cached then return cached end

    local w, h = tc[2] - tc[1], tc[4] - tc[3]
    if w <= 0 or h <= 0 then return tc end

    local grow = math.min(1 / w, 1 / h)
    local halfW, halfH = w * grow / 2, h * grow / 2
    local left, right = (tc[1] + tc[2]) / 2 - halfW, (tc[1] + tc[2]) / 2 + halfW
    local top, bottom = (tc[3] + tc[4]) / 2 - halfH, (tc[3] + tc[4]) / 2 + halfH

    if left < 0 then right, left = right - left, 0
    elseif right > 1 then left, right = left - (right - 1), 1 end
    if top < 0 then bottom, top = bottom - top, 0
    elseif bottom > 1 then top, bottom = top - (bottom - 1), 1 end

    cached = { left, right, top, bottom }
    unzoomedTexCoords[tc] = cached
    return cached
end

local function IsEnlargedGroup(kind, groupKey)
    if ENLARGED_GROUPS[groupKey] then return true end
    if S.enlargeAllCC and kind == DEBUFFS and IsCCGroup(kind, groupKey) then return true end
    if S.enlargeAllImportantBuffs and kind == BUFFROW and groupKey == "Important" then return true end
    return false
end

local function BuildStyle(kind, groupKey, standalone)
    local harmful = not IsBuffKind(kind)
    local tier = GLOW_TIERS[kind] and GLOW_TIERS[kind][groupKey]
    local glowCfg = tier and S.glow[tier]

    local pandemicTier = (PANDEMIC_GROUPS[kind] and PANDEMIC_GROUPS[kind][groupKey]) and true or false
    local pandemicOn = (groupKey == "WatchPandemic") or (pandemicTier and S.pandemicGlow)

    local inRow = (kind == DEBUFFS) or (kind == BUFFROW and not standalone)

    local width, height, texCoord
    if inRow then
        width, height, texCoord = S.debuffWidth, S.debuffHeight, S.debuffTexCoord
    else
        width, height, texCoord = S.buffWidth, S.buffHeight, S.buffTexCoord
    end

    if inRow and IsEnlargedGroup(kind, groupKey) then
        local scale = S.enlargedScale
        height = (S.enlargedSquare and S.debuffWidth or S.debuffHeight) * scale
        width = S.debuffWidth * scale
        if S.enlargedSquare then texCoord = S.buffTexCoord end
    end

    local glowing = (glowCfg and glowCfg[1] or WHITELIST_GLOW_GROUPS[groupKey]) and true or false
    if glowing and not inRow then texCoord = UnzoomTexCoord(texCoord) end

    local isCC = IsCCGroup(kind, groupKey)

    return {
        kind = kind,
        groupKey = groupKey,
        harmful = harmful,
        width = width,
        height = height,
        texCoord = texCoord,
        pixelBorder = S.pixelBorder,
        blueBorder = (kind == BUFFROW) and S.blueBuffBorder or false,
        hideSwipe = S.hideSwipe,
        showCdText = S.showCdText and not (S.cdTextBigOnly and inRow),
        blizzardCdText = S.blizzardCdText,
        hideLongTimers = S.hideLongTimers,
        cdTextScale = inRow and S.cdTextScale or S.cdTextScaleBig,
        cdFont = S.cdFont,
        showMilliseconds = (IsBuffKind(kind) and S.msBuffs) or (isCC and S.msCC) or false,
        showStack = S.showStack,
        countScale = S.countScale,
        stackFont = S.stackFont,
        stackX = S.stackX,
        stackY = S.stackY,
        stackAlign = S.stackAlign,
        stackColor = S.stackColor,
        hideTooltips = S.hideTooltips,
        colorBorderByType = S.colorBorderByType,
        purgeTier = (kind == BUFFROW) and true or false,
        purgeGlow = (kind == BUFFROW) and S.purgeGlow or false,
        purgeGlowAlways = S.purgeGlowAlways,
        purgeColor = S.purgeColor,
        purgeTypes = S.purgeTypes,
        pandemicTier = pandemicTier,
        pandemicGlow = pandemicOn and true or false,
        pandemicColor = S.pandemicColor,
        stackLevel = ((kind == BUFFS) and BUFF_STACK_LEVELS[groupKey])
            or ((kind == CC) and CC_STACK_LEVELS[groupKey]) or nil,
        glowTier = tier,
        glow = glowing,
        glowColor = glowCfg and glowCfg[2] or nil,
        glowDispelColor = (glowing and tier == "cc" and S.ccGlowDispelColor) and true or false,
    }
end

local function ReplaceStyleInPlace(style, fresh)
    local changed = false
    for k, v in pairs(fresh) do
        local old = style[k]
        if type(v) == "table" and type(old) == "table" then
            for i = 1, math.max(#v, #old) do
                if old[i] ~= v[i] then changed = true; break end
            end
            if changed then style[k] = v end
        elseif old ~= v then
            style[k] = v
            changed = true
        end
    end
    return changed
end

local profiles = {}
BBP.auraProfiles = profiles

local function ProfileKey(isFriend, isPlayer, classIconCC)
    if isFriend then
        if isPlayer then
            return classIconCC and "friendlyPlayerClassIconCC" or "friendlyPlayer"
        end
        return "friendlyNpc"
    end
    return isPlayer and "enemyPlayer" or "enemyNpc"
end

local function ClassIconTakesCC(frame, isFriend, isPlayer)
    if not (frame and isFriend and isPlayer) then return false end
    local db = BetterBlizzPlatesDB
    if not db.classIndicator or not db.classIndicatorCCAuras then return false end
    return (BBP.ClassIconShowsCC and BBP.ClassIconShowsCC(frame)) and true or false
end

local function BigIconOn(kind, isFriend, isPlayer)
    if kind == CC then
        if not isPlayer then return S.ccOnNpcs end
        if isFriend then return S.ccOnFriendlyPlayers end
        return S.ccOnEnemyPlayers
    end
    if not isPlayer then return S.buffsOnNpcs end
    if isFriend then return S.buffsOnFriendlyPlayers end
    return S.buffsOnEnemyPlayers
end

local function IncludeOrZero(set, safeSet, canFilter, limit)
    if canFilter then
        return set, SetIsEmpty(set) and 0 or limit
    end
    return safeSet, SetIsEmpty(safeSet) and 0 or limit
end

local function ExcludeSet(set, safeSet, canFilter)
    return canFilter and set or safeSet
end

local function AppendTokens(parts, ...)
    for i = 1, select("#", ...) do
        local token = select(i, ...)
        if token then parts[#parts + 1] = token end
    end
end

local function BuildProfile(isFriend, isPlayer, classIconCC)
    local cfg = isFriend and S.friendly or S.enemy
    local buffCfg, debuffCfg = cfg.buff, cfg.debuff

    local canFilterHelpful = isFriend and true or false
    local canFilterHarmful = not canFilterHelpful
    local blacklistOnD = (debuffCfg.blacklist or not canFilterHarmful) and true or false
    local blacklistOnB = (buffCfg.blacklist or not canFilterHelpful) and true or false

    local blD     = blacklistOnD and lists.blacklist or nil
    local blDSafe = blacklistOnD and lists.blacklistSafe or nil
    local blB     = blacklistOnB and lists.blacklist or nil
    local blBSafe = blacklistOnB and lists.blacklistSafe or nil

    local blacklistD = ExcludeSet(blD, blDSafe, canFilterHarmful)
    local blacklistB = ExcludeSet(blB, blBSafe, canFilterHelpful)

    local watchD = MergeSets(lists.watch, categorySets.watchDebuff)
    local watchDSafe = MergeSets(lists.watchSafe, categorySafe.watchDebuff)
    local watchB = MergeSets(lists.watch, categorySets.watchBuff)
    local watchBSafe = MergeSets(lists.watchSafe, categorySafe.watchBuff)

    local out = { debuffs = {}, buffs = {}, buffrow = {}, cc = {} }

    local dEnabled = debuffCfg.enable
    local dLimit = dEnabled and S.debuffLimit or 0

    local ccBigWanted = BigIconOn(CC, isFriend, isPlayer)
        and not (isFriend and isPlayer and S.ccOverlayReplacesIcon)
        and not (S.inPvE and isFriend and isPlayer and S.blizzardCCInPvE)
        and true or false
    local ccInRowWanted = (not ccBigWanted) and dEnabled and debuffCfg.cc and true or false
    local ccBig = (ccBigWanted and not classIconCC) and true or false
    local ccInRow = (ccInRowWanted and not classIconCC) and true or false
    local ccClaimed = (ccBig or ccInRow or classIconCC) and true or false
    local otherCCClaimed = (ccBigWanted or ccInRowWanted) and true or false
    local noCC = (not ccInRow) and ("!" .. AF.CrowdControl) or nil

    local watchOnD = (debuffCfg.watchlist and canFilterHarmful) and true or false
    local watchLiveD = (dEnabled and watchOnD) and true or false
    local debuffsMineOnly = (debuffCfg.onlyMine and not isFriend) and true or false
    local dispelOnD = (debuffCfg.purgeable and isFriend) and true or false
    local dispelTokenD = debuffCfg.anyDispel and AF.Dispellable or AF.RaidPlayerDispellable

    local plainLiveD = dEnabled
        and (debuffCfg.blizzard or debuffCfg.lessThanMin
            or not (debuffCfg.cc or watchOnD or dispelOnD))
        and true or false

    local function DebuffFilter(...)
        local parts = { AF.Harmful, AF.IncludeNameplateOnly }
        AppendTokens(parts, ...)
        if noCC then parts[#parts + 1] = noCC end
        return CreateFilterString(unpack(parts))
    end

    local function DebuffFilterKeepCC(...)
        local parts = { AF.Harmful, AF.IncludeNameplateOnly }
        AppendTokens(parts, ...)
        return CreateFilterString(unpack(parts))
    end

    local flagClaimed = MergeSets(lists.watchImportant, lists.watchImportantMine,
        lists.watchEnlarged, lists.watchEnlargedMine,
        lists.watchEnlargedImportant, lists.watchEnlargedImportantMine)
    local flagClaimedSafe = MergeSets(lists.watchImportantSafe, lists.watchImportantMineSafe,
        lists.watchEnlargedSafe, lists.watchEnlargedMineSafe,
        lists.watchEnlargedImportantSafe, lists.watchEnlargedImportantMineSafe)

    local importantMineD = MergeSets(lists.watchImportant, lists.watchImportantMine,
        lists.watchEnlargedImportant, lists.watchEnlargedImportantMine)
    local importantMineDSafe = MergeSets(lists.watchImportantSafe, lists.watchImportantMineSafe,
        lists.watchEnlargedImportantSafe, lists.watchEnlargedImportantMineSafe)

    local watchSet, watchMax = IncludeOrZero(
        SubtractSets(watchD, flagClaimed), SubtractSets(watchDSafe, flagClaimedSafe),
        canFilterHarmful, dLimit)
    out.debuffs.Watch = {
        filter = DebuffFilter("!" .. AF.Player),
        filters = { includeSpellIDs = watchSet, excludeSpellIDs = blacklistD },
        max = (watchLiveD and not debuffsMineOnly) and watchMax or 0,
    }

    local mineClause = debuffsMineOnly and AF.Player or nil

    local impSet, impMax = IncludeOrZero(lists.watchImportant, lists.watchImportantSafe,
        canFilterHarmful, dLimit)
    out.debuffs.WatchImportant = {
        filter = DebuffFilterKeepCC(mineClause),
        filters = { includeSpellIDs = impSet, excludeSpellIDs = blacklistD },
        max = dEnabled and impMax or 0,
    }

    local impMineSet, impMineMax = IncludeOrZero(
        lists.watchImportantMine, lists.watchImportantMineSafe, canFilterHarmful, dLimit)
    out.debuffs.WatchImportantMine = {
        filter = DebuffFilterKeepCC(AF.Player),
        filters = { includeSpellIDs = impMineSet, excludeSpellIDs = blacklistD },
        max = dEnabled and impMineMax or 0,
    }

    local bigImpSet, bigImpMax = IncludeOrZero(lists.watchEnlargedImportant,
        lists.watchEnlargedImportantSafe, canFilterHarmful, dLimit)
    out.debuffs.EnlargedImportant = {
        filter = DebuffFilterKeepCC(mineClause),
        filters = { includeSpellIDs = bigImpSet, excludeSpellIDs = blacklistD },
        max = dEnabled and bigImpMax or 0,
    }

    local bigImpMineSet, bigImpMineMax = IncludeOrZero(lists.watchEnlargedImportantMine,
        lists.watchEnlargedImportantMineSafe, canFilterHarmful, dLimit)
    out.debuffs.EnlargedImportantMine = {
        filter = DebuffFilterKeepCC(AF.Player),
        filters = { includeSpellIDs = bigImpMineSet, excludeSpellIDs = blacklistD },
        max = dEnabled and bigImpMineMax or 0,
    }

    local bigSet, bigMax = IncludeOrZero(lists.watchEnlarged, lists.watchEnlargedSafe,
        canFilterHarmful, dLimit)
    out.debuffs.Enlarged = {
        filter = DebuffFilter(mineClause),
        filters = { includeSpellIDs = bigSet, excludeSpellIDs = blacklistD },
        max = (dEnabled and watchLiveD) and bigMax or 0,
    }

    local bigMineSet, bigMineMax = IncludeOrZero(lists.watchEnlargedMine,
        lists.watchEnlargedMineSafe, canFilterHarmful, dLimit)
    out.debuffs.EnlargedMine = {
        filter = DebuffFilter(AF.Player),
        filters = { includeSpellIDs = bigMineSet, excludeSpellIDs = blacklistD },
        max = (dEnabled and watchLiveD) and bigMineMax or 0,
    }

    local mineTracked = MergeSets(lists.watch, lists.watchMine,
        categorySets.watchDebuff, categorySets.ownDebuff)
    local mineTrackedSafe = MergeSets(lists.watchSafe, lists.watchMineSafe,
        categorySafe.watchDebuff, categorySafe.ownDebuff)
    mineTracked = SubtractSets(mineTracked, flagClaimed)
    mineTrackedSafe = SubtractSets(mineTrackedSafe, flagClaimedSafe)

    local pandemicTracked = ExcludeSet(lists.watchPandemic, lists.watchPandemicSafe, canFilterHarmful)
    local splitPandemicD = S.splitPandemic and not SetIsEmpty(pandemicTracked)
    if splitPandemicD then
        mineTracked = SubtractSets(mineTracked, lists.watchPandemic)
        mineTrackedSafe = SubtractSets(mineTrackedSafe, lists.watchPandemic)
    end

    local mineSet, mineMax = IncludeOrZero(mineTracked, mineTrackedSafe, canFilterHarmful, dLimit)
    out.debuffs.WatchMine = {
        filter = DebuffFilter(AF.Player),
        filters = {
            includeSpellIDs = mineSet,
            excludeSpellIDs = blacklistD,
        },
        max = watchLiveD and mineMax or 0,
    }

    out.debuffs.WatchPandemic = {
        filter = DebuffFilter(AF.Player),
        filters = { includeSpellIDs = pandemicTracked, excludeSpellIDs = blacklistD },
        max = (dEnabled and splitPandemicD) and dLimit or 0,
    }

    local watchAllD = MergeSets(watchD, lists.watchMine, flagClaimed)
    local watchAllDSafe = MergeSets(watchDSafe, lists.watchMineSafe, flagClaimedSafe)

    local flaggedD = flagClaimed
    local flaggedDSafe = flagClaimedSafe
    if splitPandemicD then
        flaggedD = MergeSets(flaggedD, lists.watchPandemic)
        flaggedDSafe = MergeSets(flaggedDSafe, lists.watchPandemicSafe)
    end

    local claimedD, claimedDSafe = flaggedD, flaggedDSafe
    if watchLiveD then
        claimedD = MergeSets(watchAllD, categorySets.ownDebuff)
        claimedDSafe = MergeSets(watchAllDSafe, categorySafe.ownDebuff)
    end

    local otherCCExclude = ExcludeSet(MergeSets(blD, claimedD),
        MergeSets(blDSafe, claimedDSafe), canFilterHarmful)
    local excludeWithOtherCC = ExcludeSet(
        MergeSets(blD, claimedD, categorySets.otherCC),
        MergeSets(blDSafe, claimedDSafe, categorySafe.otherCC), canFilterHarmful)

    local normalExclude = (not ccInRowWanted) and excludeWithOtherCC or otherCCExclude

    out.debuffs.CC = {
        filter = CreateFilterString(AF.Harmful, AF.IncludeNameplateOnly, AF.CrowdControl),
        filters = { excludeSpellIDs = normalExclude },
        max = ccInRow and dLimit or 0,
    }

    local otherCCRowSet, otherCCRowMax = IncludeOrZero(categorySets.otherCC, categorySafe.otherCC,
        canFilterHarmful, dLimit)
    out.debuffs.OtherCC = {
        filter = DebuffFilterKeepCC(),
        filters = { includeSpellIDs = otherCCRowSet, excludeSpellIDs = otherCCExclude },
        max = ccInRowWanted and otherCCRowMax or 0,
    }

    local normalFilters = {
        excludeSpellIDs = normalExclude,
        maxDuration = debuffCfg.lessThanMin and 60 or nil,
        nameplateShowPersonal = debuffCfg.blizzard and true or nil,
    }

    out.debuffs.Important = {
        filter = DebuffFilter(AF.Important),
        filters = { excludeSpellIDs = normalExclude },
        max = plainLiveD and dLimit or 0,
    }

    local NOT_IMPORTANT = "!" .. AF.Important

    local function DispelFilter()
        local parts = { AF.Harmful, AF.IncludeNameplateOnly, dispelTokenD }
        if ccClaimed then parts[#parts + 1] = "!" .. AF.CrowdControl end
        return CreateFilterString(unpack(parts))
    end

    out.debuffs.Purgeable = {
        filter = DispelFilter(),
        filters = {
            excludeSpellIDs = otherCCClaimed and excludeWithOtherCC or normalExclude,
        },
        max = (dEnabled and dispelOnD) and dLimit or 0,
    }

    local function PlainDebuffFilter(caster)
        local parts = { AF.Harmful, AF.IncludeNameplateOnly, caster, NOT_IMPORTANT }
        if noCC then parts[#parts + 1] = noCC end
        if dispelOnD then parts[#parts + 1] = "!" .. dispelTokenD end
        return CreateFilterString(unpack(parts))
    end

    out.debuffs.Mine = {
        filter = PlainDebuffFilter(AF.Player),
        filters = normalFilters,
        max = plainLiveD and dLimit or 0,
    }
    out.debuffs.Others = {
        filter = PlainDebuffFilter("!" .. AF.Player),
        filters = normalFilters,
        max = (plainLiveD and isFriend and not debuffsMineOnly
            and not (debuffCfg.blizzard and S.blizzardOnlyMine)) and dLimit or 0,
    }

    local bEnabled = buffCfg.enable
    local bLimit = S.buffLimit
    local rowLimit = bEnabled and S.buffRowLimit or 0
    local NOT_BIG, NOT_EXT = "!" .. AF.BigDefensive, "!" .. AF.ExternalDefensive

    local watchAllB = MergeSets(watchB, lists.watchMine, flagClaimed)
    local watchAllBSafe = MergeSets(watchBSafe, lists.watchMineSafe, flagClaimedSafe)
    local watchLive = (bEnabled and buffCfg.watchlist and canFilterHelpful) and true or false
    local purgeOn = (bEnabled and buffCfg.purgeable) and true or false
    local underMin = (bEnabled and buffCfg.lessThanMin) and true or false
    local defOn = (bEnabled and buffCfg.defensives) and true or false
    local impOn = (bEnabled and buffCfg.important) and true or false
    local purgeToken = buffCfg.anyDispel and AF.Dispellable or AF.RaidPlayerDispellable
    local plainLive = bEnabled and (underMin or not (watchLive or purgeOn or defOn or impOn))
    local buffsMineOnly = (buffCfg.onlyMine and isFriend) and true or false
    local buffBig = BigIconOn(BUFFS, isFriend, isPlayer)
        and not (S.inPvE and isFriend and isPlayer and S.blizzardBuffsInPvE)
        and true or false
    local defRow = (not buffBig) and defOn
    local impRow = (not buffBig) and impOn
    local bigClaimed = buffBig or defRow
    local impClaimed = buffBig or impRow

    local function CategoryFilter(...)
        local parts = { AF.Helpful, AF.IncludeNameplateOnly }
        AppendTokens(parts, ...)
        return CreateFilterString(unpack(parts))
    end

    local function BuffFilter(...)
        local parts = { AF.Helpful, AF.IncludeNameplateOnly }
        AppendTokens(parts, ...)
        if bigClaimed then
            parts[#parts + 1] = NOT_BIG
            parts[#parts + 1] = NOT_EXT
        end
        if impClaimed then parts[#parts + 1] = NOT_IMPORTANT end
        return CreateFilterString(unpack(parts))
    end

    local watchBSet, watchBMax = IncludeOrZero(
        SubtractSets(watchB, flagClaimed), SubtractSets(watchBSafe, flagClaimedSafe),
        canFilterHelpful, rowLimit)
    out.buffrow.Watch = {
        filter = BuffFilter("!" .. AF.Player),
        filters = { includeSpellIDs = watchBSet, excludeSpellIDs = blacklistB },
        max = (watchLive and not buffsMineOnly) and watchBMax or 0,
    }

    local mineTrackedB = MergeSets(lists.watch, lists.watchMine, categorySets.watchBuff)
    local mineTrackedBSafe = MergeSets(lists.watchSafe, lists.watchMineSafe, categorySafe.watchBuff)
    mineTrackedB = SubtractSets(mineTrackedB, flagClaimed)
    mineTrackedBSafe = SubtractSets(mineTrackedBSafe, flagClaimedSafe)
    local pandemicTrackedB = ExcludeSet(lists.watchPandemic, lists.watchPandemicSafe, canFilterHelpful)
    local splitPandemicB = S.splitPandemic and not SetIsEmpty(pandemicTrackedB)
    if splitPandemicB then
        mineTrackedB = SubtractSets(mineTrackedB, lists.watchPandemic)
        mineTrackedBSafe = SubtractSets(mineTrackedBSafe, lists.watchPandemic)
    end

    local mineClauseB = buffsMineOnly and AF.Player or nil

    local impBSet, impBMax = IncludeOrZero(lists.watchImportant, lists.watchImportantSafe,
        canFilterHelpful, rowLimit)
    out.buffrow.WatchImportant = {
        filter = CategoryFilter(mineClauseB),
        filters = { includeSpellIDs = impBSet, excludeSpellIDs = blacklistB },
        max = bEnabled and impBMax or 0,
    }

    local impBMineSet, impBMineMax = IncludeOrZero(
        lists.watchImportantMine, lists.watchImportantMineSafe, canFilterHelpful, rowLimit)
    out.buffrow.WatchImportantMine = {
        filter = CategoryFilter(AF.Player),
        filters = { includeSpellIDs = impBMineSet, excludeSpellIDs = blacklistB },
        max = bEnabled and impBMineMax or 0,
    }

    local bigImpBSet, bigImpBMax = IncludeOrZero(lists.watchEnlargedImportant,
        lists.watchEnlargedImportantSafe, canFilterHelpful, rowLimit)
    out.buffrow.EnlargedImportant = {
        filter = CategoryFilter(mineClauseB),
        filters = { includeSpellIDs = bigImpBSet, excludeSpellIDs = blacklistB },
        max = bEnabled and bigImpBMax or 0,
    }

    local bigImpBMineSet, bigImpBMineMax = IncludeOrZero(lists.watchEnlargedImportantMine,
        lists.watchEnlargedImportantMineSafe, canFilterHelpful, rowLimit)
    out.buffrow.EnlargedImportantMine = {
        filter = CategoryFilter(AF.Player),
        filters = { includeSpellIDs = bigImpBMineSet, excludeSpellIDs = blacklistB },
        max = bEnabled and bigImpBMineMax or 0,
    }

    local bigBSet, bigBMax = IncludeOrZero(lists.watchEnlarged, lists.watchEnlargedSafe,
        canFilterHelpful, rowLimit)
    out.buffrow.Enlarged = {
        filter = BuffFilter(mineClauseB),
        filters = { includeSpellIDs = bigBSet, excludeSpellIDs = blacklistB },
        max = watchLive and bigBMax or 0,
    }

    local bigBMineSet, bigBMineMax = IncludeOrZero(lists.watchEnlargedMine,
        lists.watchEnlargedMineSafe, canFilterHelpful, rowLimit)
    out.buffrow.EnlargedMine = {
        filter = BuffFilter(AF.Player),
        filters = { includeSpellIDs = bigBMineSet, excludeSpellIDs = blacklistB },
        max = watchLive and bigBMineMax or 0,
    }

    local watchBMineSet, watchBMineMax = IncludeOrZero(mineTrackedB, mineTrackedBSafe, canFilterHelpful, rowLimit)
    out.buffrow.WatchMine = {
        filter = BuffFilter(AF.Player),
        filters = { includeSpellIDs = watchBMineSet, excludeSpellIDs = blacklistB },
        max = watchLive and watchBMineMax or 0,
    }

    out.buffrow.WatchPandemic = {
        filter = BuffFilter(AF.Player),
        filters = { includeSpellIDs = pandemicTrackedB, excludeSpellIDs = blacklistB },
        max = (bEnabled and splitPandemicB) and rowLimit or 0,
    }

    local flaggedB = flagClaimed
    local flaggedBSafe = flagClaimedSafe
    if splitPandemicB then
        flaggedB = MergeSets(flaggedB, lists.watchPandemic)
        flaggedBSafe = MergeSets(flaggedBSafe, lists.watchPandemicSafe)
    end

    local claimedB, claimedBSafe = flaggedB, flaggedBSafe
    if watchLive then
        claimedB = MergeSets(claimedB, watchAllB)
        claimedBSafe = MergeSets(claimedBSafe, watchAllBSafe)
    end

    local rowExclude = ExcludeSet(MergeSets(blB, claimedB),
        MergeSets(blBSafe, claimedBSafe), canFilterHelpful)

    local impLiveB = (bEnabled and (impBMax > 0 or impBMineMax > 0
        or bigImpBMax > 0 or bigImpBMineMax > 0)) and true or false
    local catExclude = impLiveB
        and ExcludeSet(MergeSets(blB, importantMineD),
            MergeSets(blBSafe, importantMineDSafe), canFilterHelpful)
        or blacklistB

    local DEF_BIG_FILTER = CategoryFilter(AF.BigDefensive)
    local DEF_EXT_FILTER = CategoryFilter(NOT_BIG, AF.ExternalDefensive)
    local IMPORTANT_FILTER = CategoryFilter(NOT_BIG, NOT_EXT, AF.Important)

    out.buffs.DefBig = {
        filter = DEF_BIG_FILTER,
        filters = { excludeSpellIDs = catExclude },
        max = buffBig and bLimit or 0,
    }
    out.buffs.DefExt = {
        filter = DEF_EXT_FILTER,
        filters = { excludeSpellIDs = catExclude },
        max = buffBig and bLimit or 0,
    }
    out.buffs.Important = {
        filter = IMPORTANT_FILTER,
        filters = { excludeSpellIDs = catExclude },
        max = buffBig and bLimit or 0,
    }

    out.buffrow.DefBig = {
        filter = DEF_BIG_FILTER,
        filters = { excludeSpellIDs = catExclude },
        max = defRow and rowLimit or 0,
    }
    out.buffrow.DefExt = {
        filter = DEF_EXT_FILTER,
        filters = { excludeSpellIDs = catExclude },
        max = defRow and rowLimit or 0,
    }
    out.buffrow.Important = {
        filter = IMPORTANT_FILTER,
        filters = { excludeSpellIDs = catExclude },
        max = impRow and rowLimit or 0,
    }

    out.buffrow.Purgeable = {
        filter = BuffFilter(purgeToken),
        filters = { excludeSpellIDs = rowExclude },
        max = purgeOn and rowLimit or 0,
    }

    local function PlainBuffFilter(caster)
        local parts = { AF.Helpful, AF.IncludeNameplateOnly, caster }
        if bigClaimed then
            parts[#parts + 1] = NOT_BIG
            parts[#parts + 1] = NOT_EXT
        end
        if impClaimed then parts[#parts + 1] = NOT_IMPORTANT end
        if purgeOn then parts[#parts + 1] = "!" .. purgeToken end
        return CreateFilterString(unpack(parts))
    end

    local plainFilters = {
        excludeSpellIDs = rowExclude,
        maxDuration = underMin and 60 or nil,
    }

    out.buffrow.Mine = {
        filter = PlainBuffFilter(AF.Player),
        filters = plainFilters,
        max = plainLive and rowLimit or 0,
    }

    out.buffrow.Others = {
        filter = PlainBuffFilter("!" .. AF.Player),
        filters = plainFilters,
        max = (plainLive and not buffsMineOnly) and rowLimit or 0,
    }

    local impLiveD = (dEnabled and (impMax > 0 or impMineMax > 0
        or bigImpMax > 0 or bigImpMineMax > 0)) and true or false
    local ccExclude = impLiveD
        and ExcludeSet(MergeSets(blD, importantMineD),
            MergeSets(blDSafe, importantMineDSafe), canFilterHarmful)
        or blacklistD
    out.cc.CC = {
        filter = CreateFilterString(AF.Harmful, AF.IncludeNameplateOnly, AF.CrowdControl),
        filters = { excludeSpellIDs = ccExclude },
        max = ccBig and S.ccLimit or 0,
    }

    local otherCCSet, otherCCMax = IncludeOrZero(categorySets.otherCC, categorySafe.otherCC,
        canFilterHarmful, S.ccLimit)
    out.cc.OtherCC = {
        filter = CreateFilterString(AF.Harmful, AF.IncludeNameplateOnly),
        filters = { includeSpellIDs = otherCCSet, excludeSpellIDs = ccExclude },
        max = ccBigWanted and otherCCMax or 0,
    }

    out.debuffsLive = false
    for _, groupCfg in pairs(out.debuffs) do
        if groupCfg.max > 0 then
            out.debuffsLive = true
            break
        end
    end

    out.buffsLive = false
    for _, groupCfg in pairs(out.buffs) do
        if groupCfg.max > 0 then
            out.buffsLive = true
            break
        end
    end

    out.ccLive = (out.cc.CC.max > 0 or out.cc.OtherCC.max > 0) and true or false

    return out
end

local profileGeneration = 0

local liveGroups = {}
for _, kind in ipairs(CONTAINER_KINDS) do liveGroups[kind] = {} end

local function RebuildLiveGroups()
    for _, kind in ipairs(CONTAINER_KINDS) do
        local live = liveGroups[kind]
        wipe(live)
        for _, groupKey in ipairs(GROUPS_BY_KIND[kind]) do
            for _, profile in pairs(profiles) do
                local cfg = profile[kind] and profile[kind][groupKey]
                if cfg and cfg.max > 0 then
                    live[groupKey] = true
                    break
                end
            end
        end
    end
end

local function RebuildProfiles()
    wipe(profiles)
    profiles.enemyPlayer    = BuildProfile(false, true)
    profiles.enemyNpc       = BuildProfile(false, false)
    profiles.friendlyPlayer = BuildProfile(true, true)
    profiles.friendlyNpc    = BuildProfile(true, false)
    profiles.friendlyPlayerClassIconCC = BuildProfile(true, true, true)
    RebuildLiveGroups()
    profileGeneration = profileGeneration + 1
end

local function GetCell(kind, groupKey)
    if kind == DEBUFFS or kind == BUFFROW then
        if groupKey and IsEnlargedGroup(kind, groupKey) then
            local scale = S.enlargedScale
            return S.debuffWidth * scale,
                (S.enlargedSquare and S.debuffWidth or S.debuffHeight) * scale
        end
        return S.debuffWidth, S.debuffHeight
    end
    return S.buffWidth, S.buffHeight
end

local function LayoutIndex(kind, groupKey)
    local map = LAYOUT_INDEX[S.sortEnlargedFirst and true or false][kind]
    return (map and map[groupKey]) or 99
end

local function CreateContainer(kind)
    local container = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
    container:SetEnabled(false)
    container:Hide()
    container.bbpKind = kind
    container.bbpStyles = {}
    container.bbpApplied = {}
    container.bbpHasGroup = {}
    container:SetFlattensRenderLayers(true)
    local growsUp = ((kind == DEBUFFS) or (kind == BUFFROW)) and not S.growDown
    container:SetFlowLayoutAnchorPoint(growsUp and "BOTTOMLEFT" or "TOPLEFT")
    container:SetFlowLayoutGrowthDirection(FlowDirection.Right,
        growsUp and FlowDirection.Up or FlowDirection.Down)
    return container
end

local function AddContainerGroup(container, groupKey)
    local kind = container.bbpKind
    local style = BuildStyle(kind, groupKey)
    container.bbpStyles[groupKey] = style

    local cellW, cellH = GetCell(kind, groupKey)
    container:AddAuraGroup(groupKey, CreateFilterString(IsBuffKind(kind) and AF.Helpful or AF.Harmful), {
        maxFrameCount = 0,
        sortMethod = S.sort[1],
        sortDirection = S.sort[2],
        initializeFrame = function(button)
            InitAuraButton(button, container.bbpStyles[groupKey])
        end,
        layout = {
            elementSpacing = S.gapX,
            lineSpacing = S.gapY,
            elementWidth = cellW,
            elementHeight = cellH,
            layoutIndex = LayoutIndex(kind, groupKey),
        },
    })
    container.bbpApplied[groupKey] = {}
    container.bbpHasGroup[groupKey] = true
end

local function AddContainerGroups(container)
    local kind = container.bbpKind
    local live = liveGroups[kind]
    for _, groupKey in ipairs(GROUPS_BY_KIND[kind]) do
        if live[groupKey] then
            AddContainerGroup(container, groupKey)
        end
    end
end

local function EnsureContainerGroups(container)
    local kind = container.bbpKind
    local live = liveGroups[kind]
    local has = container.bbpHasGroup
    for _, groupKey in ipairs(GROUPS_BY_KIND[kind]) do
        if live[groupKey] and not has[groupKey] then
            AddContainerGroup(container, groupKey)
        end
    end
end

local function ApplyGroupCandidateFilters(container, groupKey, filters)
    local applied = container.bbpApplied[groupKey]
    local include = filters and filters.includeSpellIDs or false
    local exclude = filters and filters.excludeSpellIDs or false
    local maxDur = filters and filters.maxDuration or false
    local personal = filters and filters.nameplateShowPersonal or false
    if applied.generation == listGeneration
        and applied.include == include and applied.exclude == exclude
        and applied.maxDuration == maxDur and applied.personal == personal then
        return
    end
    applied.generation = listGeneration
    applied.include, applied.exclude = include, exclude
    applied.maxDuration, applied.personal = maxDur, personal
    container:SetAuraGroupCandidateFilters(groupKey, filters)
end

local function ApplyGroupLayout(container, groupKey, spacingX, spacingY, cellW, cellH, index)
    local applied = container.bbpApplied[groupKey]
    if applied.spacingX == spacingX and applied.spacingY == spacingY
        and applied.cellW == cellW and applied.cellH == cellH
        and applied.layoutIndex == index then
        return
    end
    applied.spacingX, applied.spacingY = spacingX, spacingY
    applied.cellW, applied.cellH = cellW, cellH
    applied.layoutIndex = index
    container:SetAuraGroupLayout(groupKey, {
        elementSpacing = spacingX,
        lineSpacing = spacingY,
        elementWidth = cellW,
        elementHeight = cellH,
        layoutIndex = index,
    })
end

local function ApplyGroupSort(container, groupKey, method, direction)
    local applied = container.bbpApplied[groupKey]
    if applied.sortMethod == method and applied.sortDirection == direction then return end
    applied.sortMethod, applied.sortDirection = method, direction
    container:SetAuraGroupSortMethod(groupKey, method, direction)
end

local function ApplyProfile(container, profileKey, perRow)
    if container.bbpProfileKey == profileKey
        and container.bbpPerRow == perRow
        and container.bbpProfileGen == profileGeneration then
        return
    end
    container.bbpProfileKey, container.bbpPerRow = profileKey, perRow
    container.bbpProfileGen = profileGeneration

    EnsureContainerGroups(container)

    local kind = container.bbpKind
    local profile = profiles[profileKey]
    if not profile then return end
    local groupCfgs = profile[kind]
    local groups = GROUPS_BY_KIND[kind]
    local has = container.bbpHasGroup

    local baseW = GetCell(kind)
    local overlap = (kind == BUFFS and S.buffLimit == 1) or (kind == CC and S.ccLimit == 1)
    local wrap = (kind == DEBUFFS or kind == BUFFROW)
        and (perRow * baseW + (perRow - 1) * S.gapX)
        or math.huge
    container:SetFlowLayoutMaximumLineSize(wrap)

    local parkFilter
    for _, groupKey in ipairs(groups) do
        local cfg = groupCfgs[groupKey]
        if cfg and cfg.max > 0 then
            parkFilter = cfg.filter
            break
        end
    end
    if not parkFilter then
        local first = groupCfgs[groups[1]]
        parkFilter = first and first.filter
    end

    for _, groupKey in ipairs(groups) do
        local cfg = groupCfgs[groupKey]
        if cfg and has[groupKey] then
            container:SetAuraGroupMaxFrameCount(groupKey, cfg.max)
            if cfg.max > 0 then
                container:SetAuraGroupFilterString(groupKey, cfg.filter)
                ApplyGroupCandidateFilters(container, groupKey, cfg.filters)
                local index = LayoutIndex(kind, groupKey)
                if overlap then
                    ApplyGroupLayout(container, groupKey, 0, 0, 0, 0, index)
                else
                    local cellW, cellH = GetCell(kind, groupKey)
                    ApplyGroupLayout(container, groupKey, S.gapX, S.gapY, cellW, cellH, index)
                end
                ApplyGroupSort(container, groupKey, S.sort[1], S.sort[2])
            elseif parkFilter then
                container:SetAuraGroupFilterString(groupKey, parkFilter)
            end
        end
    end
end

local function SetContainerPoint(container, point, relTo, relPoint, x, y)
    if container.bbpPoint == point and container.bbpRelTo == relTo
        and container.bbpRelPoint == relPoint and container.bbpX == x and container.bbpY == y then
        return
    end
    container.bbpPoint, container.bbpRelTo = point, relTo
    container.bbpRelPoint, container.bbpX, container.bbpY = relPoint, x, y
    container:ClearAllPoints()
    container:SetPoint(point, relTo, relPoint, x, y)
end

local DEBUFF_ROW_LIFT = 4

local function GetDebuffVerticalOffset()
    local pad = (S.debuffPadding or 0) + DEBUFF_ROW_LIFT
    local opts = NamePlateSetupOptions
    if not opts then return pad end

    local styles = NamePlateConstants.NAME_ANCHOR_STYLES
    if not styles or opts.unitNameAnchorStyle == styles.InsideHealthBar then
        return pad
    end
    return pad + (opts.healthBarFontHeight or 16) + (opts.healthBarToNameAboveSpacing or 2)
end

local function GetDebuffAnchor(frame, centered)
    local healthBar = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar
    if not healthBar then return end

    local y = GetDebuffVerticalOffset()
    local x = S.debuffPadX

    if centered then
        return "BOTTOM", healthBar, "TOP", x, y
    elseif S.rightToLeft then
        return "BOTTOMRIGHT", healthBar, "TOPRIGHT", x, y
    end
    return "BOTTOMLEFT", healthBar, "TOPLEFT", x, y
end

local function GetSideAnchor(frame, kind, anchor, xPos, yPos)
    local healthBar = frame.HealthBarsContainer
    if not healthBar then return end
    local _, cellH = GetCell(kind)
    local lift = cellH / 2

    if anchor == "LEFT" then
        return "TOPRIGHT", healthBar, "LEFT", -5 + xPos, yPos + lift
    elseif anchor == "TOP" then
        return "BOTTOM", healthBar, "TOP", xPos, (S.debuffPadding or 0) + 15 + yPos
    end
    return "TOPLEFT", healthBar, "RIGHT", 5 + xPos, yPos + lift
end

local function CenteredDebuffs(isFriend)
    if isFriend then return S.centerFriendlyDebuffs and true or false end
    return S.centerEnemyDebuffs and true or false
end

local function CenteredBuffs(isFriend)
    if isFriend then return S.centerFriendlyBuffs and true or false end
    return S.centerEnemyBuffs and true or false
end

local function SetRowFlow(container, centered)
    local right = S.rightToLeft and not centered
    if S.growDown then
        container:SetFlowLayoutAnchorPoint(right and "TOPRIGHT" or "TOPLEFT")
        container:SetFlowLayoutGrowthDirection(right and FlowDirection.Left or FlowDirection.Right,
            FlowDirection.Down)
    else
        container:SetFlowLayoutAnchorPoint(right and "BOTTOMRIGHT" or "BOTTOMLEFT")
        container:SetFlowLayoutGrowthDirection(right and FlowDirection.Left or FlowDirection.Right,
            FlowDirection.Up)
    end
end

local function SetSideFlow(container, anchor)
    if anchor == "LEFT" then
        container:SetFlowLayoutAnchorPoint("TOPRIGHT")
        container:SetFlowLayoutGrowthDirection(FlowDirection.Left, FlowDirection.Down)
        return "TOPRIGHT", "TOPLEFT", -1
    elseif anchor == "TOP" then
        container:SetFlowLayoutAnchorPoint("BOTTOMLEFT")
        container:SetFlowLayoutGrowthDirection(FlowDirection.Right, FlowDirection.Up)
        return "BOTTOMLEFT", "BOTTOMRIGHT", 1
    end
    container:SetFlowLayoutAnchorPoint("TOPLEFT")
    container:SetFlowLayoutGrowthDirection(FlowDirection.Right, FlowDirection.Down)
    return "TOPLEFT", "TOPRIGHT", 1
end

local function AnchorDebuffContainer(container, frame, centered)
    SetRowFlow(container, centered)

    local point, relTo, relPoint, x, y = GetDebuffAnchor(frame, centered)
    if not relTo then return end
    SetContainerPoint(container, point, relTo, relPoint, x, y)
end

local function AnchorSideContainer(container, frame, anchor, xPos, yPos)
    SetSideFlow(container, anchor)

    local point, relTo, relPoint, x, y = GetSideAnchor(frame, container.bbpKind, anchor, xPos, yPos)
    if not relTo then return end
    SetContainerPoint(container, point, relTo, relPoint, x, y)
end

local function AnchorChainedContainer(container, frame, relContainer, anchor, xPos, yPos, ratio)
    local point, relPoint, direction = SetSideFlow(container, anchor)

    local leadKind = relContainer.bbpKind
    local leadYPos = (leadKind == CC) and S.ccIconY or S.buffIconY
    local _, relTo, _, _, ownY = GetSideAnchor(frame, container.bbpKind, anchor, 0, yPos)
    if not relTo then return end
    local leadY = select(5, GetSideAnchor(frame, leadKind, anchor, 0, leadYPos))

    SetContainerPoint(container, point, relContainer, relPoint,
        direction * S.gapX + xPos, ownY - leadY * (ratio or 1))
end

local function AlignFraction(centered)
    if centered then return 0.5 end
    if S.rightToLeft then return 1 end
    return 0
end

local function HealthBarWidth(frame)
    local healthBar = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar
    local width = healthBar and healthBar:GetWidth()
    if issecretvalue(width) then width = frame.lastKnownHpWidth end
    return (width and not issecretvalue(width) and width > 0) and width or 0
end

local function AnchorBuffRowContainer(container, frame, debuffContainer, centered, debuffsCentered,
                                      debuffsLive, scaleRatio, buffScale)
    SetRowFlow(container, centered)

    if not (debuffsLive and debuffContainer) then
        local point, relTo, relPoint, x, y = GetDebuffAnchor(frame, centered)
        if not relTo then return end
        local ratio = scaleRatio or 1
        SetContainerPoint(container, point, relTo, relPoint, x * ratio, y * ratio)
        return
    end

    local point, relPoint
    if centered then
        point = "BOTTOM"
    elseif S.rightToLeft then
        point = "BOTTOMRIGHT"
    else
        point = "BOTTOMLEFT"
    end

    if debuffsCentered then
        relPoint = "TOP"
    elseif S.rightToLeft then
        relPoint = "TOPRIGHT"
    else
        relPoint = "TOPLEFT"
    end

    local x = 0
    local shift = AlignFraction(centered) - AlignFraction(debuffsCentered)
    if shift ~= 0 then
        local width = HealthBarWidth(frame)
        if width > 0 then x = width * shift / (buffScale or 1) end
    end

    SetContainerPoint(container, point, debuffContainer, relPoint, x, S.gapY)
end

local function ContainerScale(kind, isTarget)
    local scale = S.scale
    if kind == DEBUFFS then scale = scale * S.debuffScale
    elseif kind == BUFFS then scale = scale * S.buffIconScale
    elseif kind == BUFFROW then scale = scale * S.buffScale
    else scale = scale * S.ccIconScale end
    if isTarget and S.targetScaleOn then scale = scale * S.targetScale end
    return scale
end

local AurasAreSecret, RestyleSet

local MAX_NAMEPLATES = 40
local BUDGET_NORMAL = 1
local BUDGET_LOADING = 8

local pool = { sets = {}, queue = {}, queued = {}, target = 0 }
BBP.auraPool = pool

local builder = CreateFrame("Frame")
builder:Hide()

local function BuildSet(token)
    local set = pool.sets[token]
    if not set then
        set = { token = token }
        pool.sets[token] = set
    end
    for _, kind in ipairs(CONTAINER_KINDS) do
        local container = set[kind]
        if container then
            EnsureContainerGroups(container)
        elseif next(liveGroups[kind]) then
            container = CreateContainer(kind)
            AddContainerGroups(container)
            set[kind] = container
        end
    end
    set.groupGen = profileGeneration
    set.ready = true
    return set
end

local function EnqueueSets(count)
    pool.target = math.max(pool.target, math.min(count, MAX_NAMEPLATES))
    for i = 1, pool.target do
        local token = "nameplate" .. i
        local set = pool.sets[token]
        if (not set or set.groupGen ~= profileGeneration) and not pool.queued[token] then
            pool.queued[token] = true
            pool.queue[#pool.queue + 1] = token
        end
    end
    if #pool.queue > 0 then builder:Show() end
end

builder:SetScript("OnUpdate", function(self)
    if InCombatLockdown() then return end

    local budget = BetterBlizzPlatesDB.wasOnLoadingScreen and BUDGET_LOADING or BUDGET_NORMAL
    local start = debugprofilestop()

    while #pool.queue > 0 and (debugprofilestop() - start) < budget do
        local token = table.remove(pool.queue, 1)
        pool.queued[token] = nil
        local set = pool.sets[token]
        if not set or set.groupGen ~= profileGeneration then BuildSet(token) end
    end

    if #pool.queue == 0 then self:Hide() end
end)

local function AcquireSet(token)
    local set = pool.sets[token]
    if set and set.ready and set.groupGen == profileGeneration then return set end
    pool.queued[token] = nil
    return BuildSet(token)
end

local BLIZZARD_AURA_BITS = {
    [NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR] = {
        Enum.NamePlateEnemyNpcAuraDisplay.Buffs,
        Enum.NamePlateEnemyNpcAuraDisplay.Debuffs,
        Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl,
    },
    [NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR] = {
        Enum.NamePlateEnemyPlayerAuraDisplay.Buffs,
        Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs,
        Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl,
    },
    [NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR] = {
        Enum.NamePlateFriendlyPlayerAuraDisplay.Buffs,
        Enum.NamePlateFriendlyPlayerAuraDisplay.Debuffs,
        Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl,
    },
}

local BLIZZARD_PVE_CVAR = NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR
local BLIZZARD_PVE_BUFF_BIT = Enum.NamePlateFriendlyPlayerAuraDisplay.Buffs
local BLIZZARD_PVE_CC_BIT = Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl

local function BlizzardBitForcedOn(cvarName, index)
    if not inPvEInstance then return false end
    if cvarName ~= BLIZZARD_PVE_CVAR then return false end
    local db = BetterBlizzPlatesDB
    if db.nameplateAuraCCBlizzardInPvE and index == BLIZZARD_PVE_CC_BIT then return true end
    if db.nameplateAuraBuffsBlizzardInPvE and index == BLIZZARD_PVE_BUFF_BIT then return true end
    return false
end

local cvarsPending = nil

function BBP.IsSuppressedAuraBit(cvarName, index)
    if not BetterBlizzPlatesDB.bbpAuraCVarsSuppressed then return false end
    local indices = BLIZZARD_AURA_BITS[cvarName]
    if not indices then return false end
    for _, i in ipairs(indices) do
        if i == index then return true end
    end
    return false
end

local function StoreBlizzardAuraBit(cvarName, index, value)
    local db = BetterBlizzPlatesDB
    db.bitfields = db.bitfields or {}
    db.bitfields[cvarName] = db.bitfields[cvarName] or {}
    db.bitfields[cvarName][tostring(index)] = value
end

local function SeedBlizzardAuraStore()
    local db = BetterBlizzPlatesDB
    if db.bbpAuraCVarsSuppressed then return end

    for cvarName, indices in pairs(BLIZZARD_AURA_BITS) do
        local saved = db.bitfields and db.bitfields[cvarName]
        for _, index in ipairs(indices) do
            if not saved or saved[tostring(index)] == nil then
                StoreBlizzardAuraBit(cvarName, index, C_CVar.GetCVarBitfield(cvarName, index))
            end
        end
    end
end

function BBP.GetStoredAuraBit(cvarName, index)
    local db = BetterBlizzPlatesDB
    local key = tostring(index)

    local saved = db.bitfields and db.bitfields[cvarName] and db.bitfields[cvarName][key]
    if saved ~= nil then return saved end

    local backup = BBPCVarBackupsDB and BBPCVarBackupsDB.bitfields
    saved = backup and backup[cvarName] and backup[cvarName][key]
    if saved ~= nil then return saved end

    return true
end

function BBP.GetPlayerNameplateBit(cvarName, index)
    if BBP.IsSuppressedAuraBit(cvarName, index) then
        return BBP.GetStoredAuraBit(cvarName, index)
    end
    return C_CVar.GetCVarBitfield(cvarName, index)
end

local function ApplyBlizzardAuraCVars(enabled)
    if InCombatLockdown() then
        cvarsPending = enabled and true or false
        return
    end
    cvarsPending = nil

    local db = BetterBlizzPlatesDB

    if not enabled then
        SeedBlizzardAuraStore()
    end

    local wasTracking = BBP.CVarTrackingDisabled
    BBP.CVarTrackingDisabled = true

    db.bbpAuraCVarsSuppressed = (not enabled) or nil

    for cvarName, indices in pairs(BLIZZARD_AURA_BITS) do
        for _, index in ipairs(indices) do
            local value = false
            if enabled then
                value = BBP.GetStoredAuraBit(cvarName, index)
            elseif BlizzardBitForcedOn(cvarName, index) then
                value = true
            end
            C_CVar.SetCVarBitfield(cvarName, index, value)
        end
    end

    C_CVar.SetCVar(NamePlateConstants.SHOW_DEBUFFS_ON_FRIENDLY_CVAR, "0")

    BBP.CVarTrackingDisabled = wasTracking
end

local function RememberBlizzardAuraCVarChange(cvarName)
    local db = BetterBlizzPlatesDB

    if cvarName == NamePlateConstants.SHOW_DEBUFFS_ON_FRIENDLY_CVAR then
        if C_CVar.GetCVarBool(cvarName) then
            local wasTracking = BBP.CVarTrackingDisabled
            BBP.CVarTrackingDisabled = true
            C_CVar.SetCVar(cvarName, "0")
            BBP.CVarTrackingDisabled = wasTracking
        end
        return
    end

    local indices = BLIZZARD_AURA_BITS[cvarName]
    if not indices then return end

    if not db.bbpAuraCVarsSuppressed then
        for _, index in ipairs(indices) do
            StoreBlizzardAuraBit(cvarName, index, C_CVar.GetCVarBitfield(cvarName, index))
        end
        return
    end

    local changed = false
    for _, index in ipairs(indices) do
        if not BlizzardBitForcedOn(cvarName, index) and C_CVar.GetCVarBitfield(cvarName, index) then
            StoreBlizzardAuraBit(cvarName, index, true)
            changed = true
        end
    end

    if changed then ApplyBlizzardAuraCVars(false) end
end

function BBP.RestoreBlizzardNameplateAuras()
    if not BetterBlizzPlatesDB.bbpAuraCVarsSuppressed then
        SeedBlizzardAuraStore()
        if cvarsPending == false then cvarsPending = nil end
        return
    end
    ApplyBlizzardAuraCVars(true)
end

function BBP.ReassertBlizzardAuraCVars()
    if not BetterBlizzPlatesDB.bbpAuraCVarsSuppressed then return end
    ApplyBlizzardAuraCVars(false)
end

function BBP.RefreshBlizzardAuraCVarOverrides()
    if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then return end
    RefreshPvEState()
    ApplyBlizzardAuraCVars(false)
end

local boundTokens = {}

local function ShouldShowAuras(info, unit)
    if BetterBlizzPlatesDB.hideNameplateAuras then return false end
    if not S.playersOnly then return true end
    if info.isPlayer then return true end
    return S.playersOnlyShowTarget and UnitIsUnit(unit, "target") and true or false
end

local function ShouldShowKind(kind, profile)
    if not profile then return kind ~= BUFFS and kind ~= CC end
    if kind == BUFFS then return profile.buffsLive end
    if kind == CC then return profile.ccLive end
    return true
end

local function BigIconSide(kind, set, profile)
    if not (profile and set[kind]) then return nil end
    if kind == CC then
        if not profile.ccLive then return nil end
        return S.combineBigIcons and S.combinedAnchor or S.ccIconAnchor
    end
    if not profile.buffsLive then return nil end
    return S.combineBigIcons and S.combinedAnchor or S.buffIconAnchor
end

local function SideChainTail(set, profile, side)
    if BigIconSide(BUFFS, set, profile) == side then return set[BUFFS] end
    if BigIconSide(CC, set, profile) == side then return set[CC] end
    return nil
end

function BBP.SetNameplateAurasShown(frame, shown)
    local set = frame and frame.bbpAuraSet
    if not set then return end
    set.bbpFrame = nil
    for _, kind in ipairs(CONTAINER_KINDS) do
        local container = set[kind]
        if container then
            container:SetShown(shown and container.bbpWanted or false)
        end
    end
end

function BBP.BindNameplateAuras(unit, frame, info)
    if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then return end
    if not unit or not frame then return end
    if strsub(unit, 1, 9) ~= "nameplate" then return end

    local set = AcquireSet(unit)
    if set.styleDirty and not AurasAreSecret() then RestyleSet(set) end
    local show = ShouldShowAuras(info, unit)
    local isFriend, isPlayer = info.isFriend and true or false, info.isPlayer and true or false
    local profileKey = ProfileKey(isFriend, isPlayer, ClassIconTakesCC(frame, isFriend, isPlayer))
    local profile = profiles[profileKey]
    local perRow = info.isFriend and S.perRowFriendly or S.perRowEnemy
    local isTarget = info.isTarget
    local level = frame:GetFrameLevel() + 10

    if set.bbpFrame == frame and set.bbpUnit == unit
        and set.bbpProfileKey == profileKey and set.bbpPerRow == perRow
        and set.bbpIsTarget == isTarget and set.bbpShow == show
        and set.bbpGen == profileGeneration and set.bbpLevel == level then
        return
    end
    set.bbpFrame, set.bbpUnit = frame, unit
    set.bbpProfileKey, set.bbpPerRow = profileKey, perRow
    set.bbpIsTarget, set.bbpShow = isTarget, show
    set.bbpGen, set.bbpLevel = profileGeneration, level

    for _, kind in ipairs(CONTAINER_KINDS) do
        local container = set[kind]
        if container then
            if container.bbpParent ~= frame then
                container:SetParent(frame)
                container.bbpParent = frame
                container.bbpRelTo = nil
            end
            if container.bbpLevel ~= level then
                container:SetFrameLevel(level)
                container.bbpLevel = level
            end

            if kind == DEBUFFS then
                AnchorDebuffContainer(container, frame, CenteredDebuffs(info.isFriend))
            elseif kind == BUFFS then
                local anchor = S.combineBigIcons and S.combinedAnchor or S.buffIconAnchor
                if S.combineBigIcons and BigIconSide(CC, set, profile) == anchor then
                    AnchorChainedContainer(container, frame, set[CC], anchor,
                        S.buffIconX, S.buffIconY,
                        ContainerScale(CC, isTarget) / ContainerScale(BUFFS, isTarget))
                else
                    AnchorSideContainer(container, frame, anchor, S.buffIconX, S.buffIconY)
                end
            elseif kind == BUFFROW then
                if S.moveBuffRow then
                    local tail = SideChainTail(set, profile, S.buffRowAnchor)
                    if tail then
                        AnchorChainedContainer(container, frame, tail, S.buffRowAnchor, 0, 0,
                            ContainerScale(tail.bbpKind, isTarget)
                                / ContainerScale(BUFFROW, isTarget))
                    else
                        AnchorSideContainer(container, frame, S.buffRowAnchor, 0, 0)
                    end
                else
                    local buffScale = ContainerScale(BUFFROW, isTarget)
                    AnchorBuffRowContainer(container, frame, set[DEBUFFS],
                        CenteredBuffs(info.isFriend), CenteredDebuffs(info.isFriend),
                        profile and profile.debuffsLive,
                        ContainerScale(DEBUFFS, isTarget) / buffScale, buffScale)
                end
            else
                AnchorSideContainer(container, frame,
                    S.combineBigIcons and S.combinedAnchor or S.ccIconAnchor,
                    S.ccIconX, S.ccIconY)
            end

            local scale = ContainerScale(kind, isTarget)
            if container.bbpScale ~= scale then
                container:SetScale(scale)
                container.bbpScale = scale
            end

            local kindShown = show and ShouldShowKind(kind, profile)
            container.bbpWanted = kindShown
            if kindShown then
                ApplyProfile(container, profileKey, perRow)
                container:SetUnit(unit)
                container:SetEnabled(true)
                container:Show()
                if container.bbpEnabled then container:UpdateAllAuras() end
                container.bbpEnabled = true
            else
                container:SetEnabled(false)
                container:Hide()
                container.bbpEnabled = false
            end
        end
    end

    set.profileKey = profileKey
    frame.bbpAuraSet = set
    boundTokens[unit] = frame

    if BBP.UpdateAuraPreview then BBP.UpdateAuraPreview(frame, info) end
end

function BBP.UnbindNameplateAuras(unit)
    local set = unit and pool.sets[unit]
    local frame = boundTokens[unit]
    if frame then frame.bbpAuraSet = nil end
    boundTokens[unit] = nil
    if not set or not set.ready then return end
    set.bbpFrame = nil

    for _, kind in ipairs(CONTAINER_KINDS) do
        local container = set[kind]
        if container then
            container:SetEnabled(false)
            container:Hide()
            container:ClearAllPoints()
            container:SetParent(UIParent)
            container.bbpEnabled = false
            container.bbpParent, container.bbpRelTo, container.bbpLevel = nil, nil, nil
        end
    end
end

function AurasAreSecret()
    return C_Secrets.ShouldAurasBeSecret()
end

local restyleQueued = false

function RestyleSet(set, force)
    for _, kind in ipairs(CONTAINER_KINDS) do
        local container = set[kind]
        if container then
            local has = container.bbpHasGroup
            local dirty = force
            for _, groupKey in ipairs(GROUPS_BY_KIND[kind]) do
                if has[groupKey] then
                    local style = container.bbpStyles[groupKey]
                    if ReplaceStyleInPlace(style, BuildStyle(kind, groupKey)) then dirty = true end
                end
            end
            if dirty then
                for _, groupKey in ipairs(GROUPS_BY_KIND[kind]) do
                    if has[groupKey] then
                        local style = container.bbpStyles[groupKey]
                        for i = 1, container:GetAuraGroupFrameCount(groupKey) do
                            local button = container:GetAuraGroupFrame(groupKey, i)
                            if button then ApplyMutableStyle(button, style) end
                        end
                    end
                end
            end
        end
    end
    set.styleDirty = nil
end

function BBP.RestyleAuraButtons(force)
    if AurasAreSecret() then
        restyleQueued = true
        return
    end
    restyleQueued = false

    local seen = {}
    for token, frame in pairs(boundTokens) do
        local set = frame and frame.bbpAuraSet
        if set and set.ready and not seen[set] then
            seen[set] = true
            RestyleSet(set, force)
        end
    end

    for _, set in pairs(pool.sets) do
        if set.ready and not seen[set] then set.styleDirty = true end
    end

    if BBP.prdAuraContainer then BBP.RestylePRDAuraButtons(force) end
end

local refreshPending = false

local function DoRefresh()
    refreshPending = false
    BBP.UpdateUserAuraSettings()
    RebuildProfiles()

    EnqueueSets(pool.target)

    for token, frame in pairs(boundTokens) do
        if frame and frame.unit then
            local info = BBP.GetNameplateUnitInfo(frame, frame.unit)
            if info then BBP.BindNameplateAuras(token, frame, info) end
        end
    end

    BBP.RestyleAuraButtons()
    BBP.RefreshPRDAuras()
    if BBP.RefreshClassIndicatorCCStyle then BBP.RefreshClassIndicatorCCStyle() end
end

function BBP.RefreshAllNameplateAuras()
    if refreshPending then return end
    refreshPending = true
    C_Timer.After(0, DoRefresh)
end

BBP.UpdateAllNameplatesAuras = BBP.RefreshAllNameplateAuras
BBP.RefreshBuffFrame = BBP.RefreshAllNameplateAuras

local PRD_GROUPS = { "DefBig", "DefExt", "Important" }

function BBP.SetupPRDAuras()
    if not S.prdEnabled then
        if BBP.prdAuraContainer then
            BBP.prdAuraContainer:SetEnabled(false)
            BBP.prdAuraContainer:Hide()
        end
        return
    end
    if not PersonalResourceDisplayFrame then return end

    local container = BBP.prdAuraContainer
    if not container then
        container = CreateFrame("AuraContainer", nil, PersonalResourceDisplayFrame, "CustomAuraContainerTemplate")
        container:SetEnabled(false)
        container.bbpKind = BUFFS
        container.bbpStyles = {}
        container.bbpApplied = {}
        container:SetFlattensRenderLayers(true)
        container:SetFlowLayoutAxis(FlowLayoutAxis.Horizontal)

        for index, groupKey in ipairs(PRD_GROUPS) do
            local style = BuildStyle(BUFFS, groupKey, true)
            container.bbpStyles[groupKey] = style
            container:AddAuraGroup(groupKey, AF.Helpful, {
                maxFrameCount = 0,
                initializeFrame = function(button)
                    InitAuraButton(button, container.bbpStyles[groupKey])
                end,
                layout = {
                    elementSpacing = S.gapX,
                    lineSpacing = S.gapY,
                    elementWidth = S.buffWidth,
                    elementHeight = S.buffHeight,
                    layoutIndex = index,
                },
            })
            container.bbpApplied[groupKey] = {}
        end
        BBP.prdAuraContainer = container
    end

    BBP.RefreshPRDAuras()
end

function BBP.RefreshPRDAuras()
    local container = BBP.prdAuraContainer
    if not container then
        if S.prdEnabled then BBP.SetupPRDAuras() end
        return
    end

    if not S.prdEnabled then
        container:SetEnabled(false)
        container:Hide()
        return
    end

    local NOT_BIG, NOT_EXT = "!" .. AF.BigDefensive, "!" .. AF.ExternalDefensive
    local filters = {
        DefBig    = CreateFilterString(AF.Helpful, AF.BigDefensive),
        DefExt    = CreateFilterString(AF.Helpful, NOT_BIG, AF.ExternalDefensive),
        Important = CreateFilterString(AF.Helpful, AF.Important, NOT_BIG, NOT_EXT),
    }

    local exclude = lists.blacklist

    local anchor = PersonalResourceDisplayFrame.HealthBarsContainer or PersonalResourceDisplayFrame
    container:ClearAllPoints()
    container:SetFlowLayoutAnchorPoint("BOTTOMLEFT")
    container:SetFlowLayoutGrowthDirection(FlowDirection.Right, FlowDirection.Up)
    container:SetPoint("BOTTOM", anchor, "TOP", S.prdX, 6 + S.prdY)
    container:SetScale(S.prdScale)
    container:SetFlowLayoutMaximumLineSize(S.prdPerRow * S.buffWidth + (S.prdPerRow - 1) * S.gapX)

    for index, groupKey in ipairs(PRD_GROUPS) do
        container:SetAuraGroupFilterString(groupKey, filters[groupKey])
        container:SetAuraGroupMaxFrameCount(groupKey, S.prdLimit)
        ApplyGroupCandidateFilters(container, groupKey, { excludeSpellIDs = exclude })
        ApplyGroupLayout(container, groupKey, S.gapX, S.gapY, S.buffWidth, S.buffHeight, index)
    end

    container:SetUnit("player")
    container:SetEnabled(true)
    container:Show()
end

function BBP.RestylePRDAuraButtons(force)
    local container = BBP.prdAuraContainer
    if not container then return end
    for _, groupKey in ipairs(PRD_GROUPS) do
        local style = container.bbpStyles[groupKey]
        local changed = ReplaceStyleInPlace(style, BuildStyle(BUFFS, groupKey, true))
        if changed or force then
            for i = 1, container:GetAuraGroupFrameCount(groupKey) do
                local button = container:GetAuraGroupFrame(groupKey, i)
                if button then ApplyMutableStyle(button, style) end
            end
        end
    end
end

local SAMPLE_ICONS = {
    [DEBUFFS] = {
        "interface/icons/spell_shadow_shadowwordpain",
        "interface/icons/spell_shadow_curseofsargeras",
        "interface/icons/spell_shadow_unstableaffliction_3",
        "interface/icons/spell_fire_immolation",
        "interface/icons/ability_rogue_rupture",
        "interface/icons/spell_nature_faeriefire",
        "interface/icons/spell_shadow_plaguecloud",
        "interface/icons/ability_druid_disembowel",
    },
    [BUFFS] = {
        "interface/icons/ability_shaman_astralshift",
        "interface/icons/spell_holy_painsupression",
        "interface/icons/spell_fire_sealoffire",
    },
    [BUFFROW] = {
        "interface/icons/spell_nature_rejuvenation",
        "interface/icons/spell_holy_renew",
        "interface/icons/spell_nature_healingtouch",
    },
    [CC] = {
        "interface/icons/spell_nature_polymorph",
        "interface/icons/spell_shadow_psychicscream",
        "interface/icons/ability_rogue_kidneyshot",
        "interface/icons/spell_holy_prayerofhealing",
    },
}

local PREVIEW_DISPEL_KEYS = { "Magic", "None", "Curse", "Poison" }

local PREVIEW_TIERS = {
    [DEBUFFS] = { "Mine", "Others" },
    [BUFFS]   = { "DefBig", "DefExt", "Important" },
    [BUFFROW] = { "Mine", "Others" },
    [CC]      = { "CC" },
}

local previews = {}

local function DrawMockButton(button, style, index)
    button:SetSize(style.width, style.height)

    if not button.bbpIcon then
        button.bbpIcon = button:CreateTexture(nil, "ARTWORK")
        button.bbpIcon:SetAllPoints(button)

        button.bbpMask = button:CreateMaskTexture()
        button.bbpMask:SetAllPoints(button)
        button.bbpMask:SetAtlas(CDM.mask)
        button.bbpIcon:AddMaskTexture(button.bbpMask)
        button.bbpMask.bbpAttached = true

        button.bbpOverlay = CreateFrame("Frame", nil, button)
        button.bbpOverlay:SetAllPoints(button)
        button.bbpOverlay:SetFrameLevel(button:GetFrameLevel() + 2)
        button.bbpBorderEdges = CreateBorderEdges(button.bbpOverlay)
        button.bbpDispelBorder = CreateDispelBorder(button.bbpOverlay)
        button.bbpGlow = button.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 5)
        button.bbpGlow:SetAtlas(GLOW_ATLAS)
        button.bbpGlow:SetDesaturated(true)
        button.bbpPandemicGlow = button.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        button.bbpPandemicGlow:SetAtlas(PANDEMIC_ATLAS)
        button.bbpPandemicGlow:SetDesaturated(true)
        button.bbpPandemicGlow:Hide()
        button.bbpBezel = button.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 3)
        button.bbpBezel:SetAtlas(CDM.bezel)

        button.bbpCooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.bbpCooldown:SetAllPoints(button)
        button.bbpCooldown:SetReverse(true)
        button.bbpCooldown:SetDrawBling(false)
        button.bbpCooldown:SetEdgeTexture(CDM.edge)
        button.bbpCooldown:SetEdgeScale(EDGE_SCALE)
        button.bbpTimer = button.bbpOverlay:CreateFontString(nil, "OVERLAY", COUNTDOWN_FONT)
        button.bbpTimer:SetPoint("CENTER")
        button.bbpCount = button.bbpOverlay:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    end

    local icons = SAMPLE_ICONS[style.kind] or SAMPLE_ICONS[DEBUFFS]
    button.bbpIcon:SetTexture(icons[((index - 1) % #icons) + 1])
    local tc = style.texCoord
    button.bbpIcon:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
    SetIconMasked(button.bbpIcon, button.bbpMask, not style.pixelBorder)

    local glowing = style.glow and true or false

    local dispelColor = style.colorBorderByType and dispelColorMapHarmful
        and dispelColorMapHarmful.Magic

    button.bbpBezel:SetShown(not style.pixelBorder and not glowing)
    ApplyBezelGeometry(button.bbpBezel, button, style.width, style.height)

    local blueBorder = BlueBorderOn(style)

    local dispelBorderColor = ColorsDispelBorderByType(style) and dispelColor
    ApplyDispelBorderGeometry(button.bbpDispelBorder, button, style.width, style.height)
    if dispelBorderColor then
        button.bbpDispelBorder:SetVertexColor(
            dispelBorderColor.r, dispelBorderColor.g, dispelBorderColor.b, 1)
    elseif blueBorder and not style.pixelBorder then
        button.bbpDispelBorder:SetVertexColor(
            BLUE_BUFF_BORDER[1], BLUE_BUFF_BORDER[2], BLUE_BUFF_BORDER[3], 1)
    end
    button.bbpDispelBorder:SetShown((dispelBorderColor or (blueBorder and not style.pixelBorder))
        and true or false)

    ApplyBorderEdgeGeometry(button.bbpBorderEdges, button, BORDER_THICKNESS)
    local borderColor = ColorsEdgesByType(style) and dispelColor
    local edge = blueBorder and BLUE_BUFF_BORDER or BLACK_BORDER
    SetBorderEdges(button.bbpBorderEdges,
        style.pixelBorder and not glowing,
        borderColor and borderColor.r or edge[1],
        borderColor and borderColor.g or edge[2],
        borderColor and borderColor.b or edge[3])

    local glowPad = GlowPad(style)

    ApplyGlowGeometry(button.bbpGlow, button, style.width, style.height, glowPad)
    if style.glow and style.glowColor then
        local dispel = style.glowDispelColor and ccGlowDispelColorMap
            and ccGlowDispelColorMap[PREVIEW_DISPEL_KEYS[((index - 1) % #PREVIEW_DISPEL_KEYS) + 1]]
        if dispel then
            button.bbpGlow:SetVertexColor(dispel.r, dispel.g, dispel.b, dispel.a or 1)
        else
            local c = style.glowColor
            button.bbpGlow:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
        end
        button.bbpGlow:Show()
    else
        button.bbpGlow:Hide()
    end

    ApplyGlowGeometry(button.bbpPandemicGlow, button, style.width, style.height, glowPad)
    button.bbpPandemicPreview = style.pandemicGlow and true or false
    if button.bbpPandemicPreview and style.pandemicColor then
        local c = style.pandemicColor
        button.bbpPandemicGlow:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
    end
    button.bbpPandemicGlow:Hide()

    ApplyStackText(button.bbpCount, button, style)
    button.bbpCount:SetText(index % 3 == 0 and index or "")

    button.bbpCooldown:SetDrawSwipe(not style.hideSwipe)
    button.bbpCooldown:SetDrawEdge(not style.hideSwipe)
    button.bbpCooldown:SetSwipeTexture(style.pixelBorder and CDM.flatSwipe or CDM.swipe)
    button.bbpCooldown:SetSwipeColor(0, 0, 0, 0.5)
    button.bbpCooldown:SetHideCountdownNumbers(not (style.showCdText and style.blizzardCdText))

    button.bbpTimer:SetScale(style.cdTextScale or 0.6)
    button.bbpTimer:SetShown(style.showCdText and not style.blizzardCdText)
    ApplyCountdownFont(button.bbpTimer, style.cdFont)

    local duration = (index == 1) and 5 or (6 + index * 4)
    button.bbpDuration = duration
    button.bbpExpires = GetTime() + duration
    button.bbpFormatter = GetDurationFormatter(style.showMilliseconds)
    button.bbpTimerColor = style.timerColor
    CooldownFrame_Set(button.bbpCooldown, GetTime(), duration, true, true)

    if not button.bbpTicking then
        button.bbpTicking = true
        button:SetScript("OnUpdate", function(self)
            local remaining = (self.bbpExpires or 0) - GetTime()
            if remaining <= 0 then
                self.bbpExpires = GetTime() + (self.bbpDuration or 10)
                CooldownFrame_Set(self.bbpCooldown, GetTime(), self.bbpDuration or 10, true, true)
                self.bbpPandemicGlow:Hide()
                return
            end
            self.bbpPandemicGlow:SetShown(self.bbpPandemicPreview
                and remaining <= (self.bbpDuration or 10) * 0.3)
            if self.bbpTimer:IsShown() and self.bbpFormatter then
                self.bbpTimer:SetText(self.bbpFormatter:FormatNumber(remaining))
                local c = (self.bbpTimerColor and remaining < S.timerThreshold)
                    and S.timerLow or S.timerBase
                self.bbpTimer:SetTextColor(c[1], c[2], c[3], c[4] or 1)
            end
        end)
    end

    button:Show()
end

local function LayoutMockRow(host, buttons, kind, perRow, centered, sideAnchor, rightAlign,
                             fromTop, invert)
    local cellW, cellH = GetCell(kind)
    local gapX, gapY = S.gapX, S.gapY
    local count = #buttons
    if count == 0 then return end

    local rowMode = (kind == DEBUFFS) or (kind == BUFFROW)

    if not rowMode then
        for i, button in ipairs(buttons) do
            local step = (i - 1) * (cellW + gapX)
            button:ClearAllPoints()
            if sideAnchor == "LEFT" then
                button:SetPoint("TOPRIGHT", host, "TOPRIGHT", -step, 0)
            elseif sideAnchor == "TOP" then
                local rowWidth = count * cellW + (count - 1) * gapX
                button:SetPoint("BOTTOMLEFT", host, "BOTTOM", -rowWidth / 2 + step, 0)
            else
                button:SetPoint("TOPLEFT", host, "TOPLEFT", step, 0)
            end
        end
        return
    end

    local rows = math.ceil(count / perRow)
    local edge = fromTop and "TOP" or "BOTTOM"

    for i, button in ipairs(buttons) do
        local row = math.floor((i - 1) / perRow)
        local col = (i - 1) % perRow
        local inRow = math.min(perRow, count - row * perRow)
        local rowWidth = inRow * cellW + (inRow - 1) * gapX
        button:ClearAllPoints()
        local y = (invert and (rows - 1 - row) or row) * (cellH + gapY)
        if fromTop then y = -y end
        if centered then
            button:SetPoint(edge .. "LEFT", host, edge, -rowWidth / 2 + col * (cellW + gapX), y)
        elseif rightAlign then
            button:SetPoint(edge .. "RIGHT", host, edge .. "RIGHT", -col * (cellW + gapX), y)
        else
            button:SetPoint(edge .. "LEFT", host, edge .. "LEFT", col * (cellW + gapX), y)
        end
    end
end

local previewStyles = {}
local previewStyleGen = nil

local function PreviewStyle(kind, groupKey)
    if previewStyleGen ~= profileGeneration then
        previewStyleGen = profileGeneration
        wipe(previewStyles)
    end
    local key = kind .. groupKey
    local style = previewStyles[key]
    if not style then
        style = BuildStyle(kind, groupKey)
        previewStyles[key] = style
    end
    return style
end

local previewTiers = {}

local function PreviewTiers(profile, kind)
    local groups = profile and profile[kind]
    if not groups then return nil end

    wipe(previewTiers)
    for _, tier in ipairs(PREVIEW_TIERS[kind]) do
        local cfg = groups[tier]
        if cfg and cfg.max > 0 then previewTiers[#previewTiers + 1] = tier end
    end
    if #previewTiers > 0 then return previewTiers end

    local wanted = #PREVIEW_TIERS[kind]
    for pass = 1, 2 do
        for _, groupKey in ipairs(GROUPS_BY_KIND[kind]) do
            local cfg = groups[groupKey]
            if cfg and cfg.max > 0 and (pass == 2 or not PreviewStyle(kind, groupKey).glow) then
                previewTiers[#previewTiers + 1] = groupKey
                if #previewTiers >= wanted then break end
            end
        end
        if #previewTiers > 0 then break end
    end
    return #previewTiers > 0 and previewTiers or nil
end

local function GetPreview(frame, kind)
    previews[frame] = previews[frame] or {}
    local p = previews[frame][kind]
    if not p then
        p = { host = CreateFrame("Frame", nil, frame), buttons = {} }
        p.host:SetSize(1, 1)
        p.host:SetFrameLevel(frame:GetFrameLevel() + 12)
        previews[frame][kind] = p
    end
    return p
end

local function MockSideWidth(kind)
    local count = (kind == BUFFS) and math.min(S.buffLimit, 3) or math.min(S.ccLimit, 2)
    local cellW = GetCell(kind)
    return count * cellW + (count - 1) * S.gapX
end

local function MockChainOffset(kind, anchor, set, profile, isTarget)
    local scale = ContainerScale(kind, isTarget)
    local run = 0

    local function Add(leader)
        run = run + (MockSideWidth(leader) + S.gapX)
            * (ContainerScale(leader, isTarget) / scale)
    end

    if kind == BUFFS then
        if S.combineBigIcons and BigIconSide(CC, set, profile) == anchor then Add(CC) end
    else
        local tail = SideChainTail(set, profile, anchor)
        if tail == set[BUFFS] then
            Add(BUFFS)
            if S.combineBigIcons and BigIconSide(CC, set, profile) == anchor then Add(CC) end
        elseif tail == set[CC] then
            Add(CC)
        end
    end

    return (anchor == "LEFT") and -run or run
end

local function UpdatePreviewFor(frame, info)
    local on = BetterBlizzPlatesDB.nameplateAuraTestMode
    if not on and not previews[frame] then return end
    local set = frame.bbpAuraSet
    local profile = profiles[(set and set.bbpProfileKey)
        or ProfileKey(info.isFriend and true or false, info.isPlayer and true or false)]
    for _, kind in ipairs(CONTAINER_KINDS) do
        local p = previews[frame] and previews[frame][kind]
        if on then
            p = GetPreview(frame, kind)
            local container = set and set[kind]
            local wanted = container and container.bbpWanted
            local tiers = wanted and PreviewTiers(profile, kind)
            if tiers then
                local centered
                if kind == BUFFROW then
                    centered = CenteredBuffs(info.isFriend)
                else
                    centered = CenteredDebuffs(info.isFriend)
                end
                local point, relTo, relPoint, x, y
                local sideAnchor, fromTop
                if kind == DEBUFFS then
                    point, relTo, relPoint, x, y = GetDebuffAnchor(frame, centered)
                elseif kind == BUFFROW and S.moveBuffRow then
                    sideAnchor = S.buffRowAnchor
                    point, relTo, relPoint, x, y = GetSideAnchor(frame, BUFFROW, sideAnchor, 0, 0)
                    if relTo then
                        x = x + MockChainOffset(BUFFROW, sideAnchor, set, profile, info.isTarget)
                    end
                    fromTop = sideAnchor ~= "TOP"
                    centered = sideAnchor == "TOP"
                elseif kind == BUFFROW then
                    point, relTo, relPoint, x, y = GetDebuffAnchor(frame, centered)
                    if relTo then
                        local ratio = ContainerScale(DEBUFFS, info.isTarget) / ContainerScale(BUFFROW, info.isTarget)
                        if profile and profile.debuffsLive then
                            local perRow = info.isFriend and S.perRowFriendly or S.perRowEnemy
                            local rows = math.ceil(math.min(S.debuffLimit, 8) / perRow)
                            local _, debuffCellH = GetCell(DEBUFFS)
                            local block = rows * debuffCellH + (rows - 1) * S.gapY
                            y = y + block + S.gapY / ratio
                        end
                        x, y = x * ratio, y * ratio
                    end
                elseif kind == BUFFS then
                    sideAnchor = S.combineBigIcons and S.combinedAnchor or S.buffIconAnchor
                    point, relTo, relPoint, x, y =
                        GetSideAnchor(frame, BUFFS, sideAnchor, S.buffIconX, S.buffIconY)
                    if relTo then
                        x = x + MockChainOffset(BUFFS, sideAnchor, set, profile, info.isTarget)
                    end
                else
                    sideAnchor = S.combineBigIcons and S.combinedAnchor or S.ccIconAnchor
                    point, relTo, relPoint, x, y =
                        GetSideAnchor(frame, CC, sideAnchor, S.ccIconX, S.ccIconY)
                end
                if not relTo then
                    p.host:Hide()
                else
                    p.host:ClearAllPoints()
                    p.host:SetPoint(point, relTo, relPoint, x, y)
                    p.host:SetScale(ContainerScale(kind, info.isTarget))

                    local limit = (kind == DEBUFFS and math.min(S.debuffLimit, 8))
                        or (kind == BUFFROW and math.min(S.buffRowLimit, 8))
                        or (kind == BUFFS and math.min(S.buffLimit, 3))
                        or math.min(S.ccLimit, 2)
                    for i = 1, limit do
                        p.buttons[i] = p.buttons[i] or CreateFrame("Frame", nil, p.host)
                        local tier = tiers[((i - 1) % #tiers) + 1]
                        DrawMockButton(p.buttons[i], PreviewStyle(kind, tier), i)
                    end
                    for i = limit + 1, #p.buttons do p.buttons[i]:Hide() end

                    local live = {}
                    for i = 1, limit do live[i] = p.buttons[i] end
                    local rowMode = (kind == DEBUFFS or kind == BUFFROW)
                    LayoutMockRow(p.host, live, kind,
                        info.isFriend and S.perRowFriendly or S.perRowEnemy,
                        rowMode and centered,
                        not rowMode and sideAnchor or nil,
                        rowMode and (sideAnchor == "LEFT"
                            or (not sideAnchor and S.rightToLeft and not centered)),
                        fromTop,
                        rowMode and not sideAnchor and S.growDown)
                    p.host:Show()
                end
            elseif p then
                p.host:Hide()
            end
        elseif p then
            p.host:Hide()
            for _, button in ipairs(p.buttons) do
                button:SetScript("OnUpdate", nil)
                button.bbpTicking = nil
            end
        end
    end
end

BBP.UpdateAuraPreview = UpdatePreviewFor

function BBP.HideNameplateAuraTooltip()
    BBP.RefreshAllNameplateAuras()
end

local hooked = false

function BBP.DisableNameplateAuras()
    for token in pairs(boundTokens) do
        BBP.UnbindNameplateAuras(token)
    end

    if BBP.prdAuraContainer then
        BBP.prdAuraContainer:SetEnabled(false)
        BBP.prdAuraContainer:Hide()
    end

    BBP.UpdateUserAuraSettings()
    BBP.RestoreBlizzardNameplateAuras()
end

function BBP.SetupNameplateAuras()
    if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
        BBP.DisableNameplateAuras()
        return
    end

    RefreshPvEState()
    ApplyBlizzardAuraCVars(false)

    if hooked then
        BBP.RefreshAllNameplateAuras()
        return
    end
    hooked = true

    BBP.UpdateUserAuraSettings()
    RebuildProfiles()

    hooksecurefunc(NamePlateUnitFrameMixin, "OnUnitFactionChanged", function(self)
        if self:IsForbidden() or not self.unit then return end
        local frame = self
        local info = BBP.GetNameplateUnitInfo(frame, frame.unit)
        if info then BBP.BindNameplateAuras(frame.unit, frame, info) end
    end)

    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("CVAR_UPDATE")
    events:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
    events:RegisterEvent("SPELLS_CHANGED")
    events:RegisterUnitEvent("UNIT_PET", "player")

    local TRACKED_CVARS = {
        nameplateStyle = true,
        nameplateShowSelf = true,
    }

    events:SetScript("OnEvent", function(_, event, arg1)
        if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then return end
            local pveChanged = RefreshPvEState()
            if event == "PLAYER_ENTERING_WORLD" then
                EnqueueSets(MAX_NAMEPLATES)
                BBP.SetupPRDAuras()
            end
            if pveChanged then
                ApplyBlizzardAuraCVars(false)
                BBP.RefreshAllNameplateAuras()
            end
        elseif event == "CVAR_UPDATE" then
            if BBP.CVarTrackingDisabled then return end
            if TRACKED_CVARS[arg1] then BBP.RefreshAllNameplateAuras() end
            RememberBlizzardAuraCVarChange(arg1)
        elseif event == "SPELLS_CHANGED" or event == "UNIT_PET" then
            if RefreshOffensiveDispels() then
                S.purgeTypes = PURGE.signature
                BBP.RefreshAllNameplateAuras()
            end
        else
            if restyleQueued then BBP.RestyleAuraButtons() end
            if cvarsPending ~= nil then ApplyBlizzardAuraCVars(cvarsPending) end
        end
    end)

    EnqueueSets(MAX_NAMEPLATES)
end
