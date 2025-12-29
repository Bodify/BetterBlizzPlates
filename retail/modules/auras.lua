if BBP.isMidnight then return end
----------------------------------------------------
---- Aura Function Copied From RSPlates and edited by me
----------------------------------------------------

local function FetchSpellName(spellId)
    local spellName, _, _ = BBP.TWWGetSpellInfo(spellId)
    return spellName
end

local LSM = LibStub("LibSharedMedia-3.0")

local fakeAuras = {
    -- 6 Fake Debuffs
    {
        auraInstanceID = 777,
        spellId = 201,
        icon = "interface/icons/spell_shadow_shadowwordpain",
        duration = 30,
        isHarmful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 778,
        spellId = 202,
        icon = "interface/icons/spell_shadow_curseofsargeras",
        duration = 18,
        isHarmful = true,
        applications = 18,
        dispelName = "Curse",
    },
    {
        auraInstanceID = 779,
        spellId = 203,
        icon = "interface/icons/spell_frost_frostnova",
        duration = 10,
        isHarmful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 780,
        spellId = 69420,
        icon = 132092,
        duration = 22,
        applications = 1,
        isHarmful = true,
        dispelName = "Physical",
    },
    {
        auraInstanceID = 781,
        spellId = 205,
        icon = 135978,
        duration = 24,
        isHarmful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 782,
        spellId = 206,
        icon = "interface/icons/spell_shadow_plaguecloud",
        duration = 16,
        isHarmful = true,
        applications = 3,
        dispelName = "Disease",
    },
    -- 5 Fake Buffs
    {
        auraInstanceID = 666,
        spellId = 101,
        icon = "interface/icons/spell_nature_regeneration",
        duration = 20,
        isHelpful = true,
        applications = 1,
        isStealable = true,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 667,
        spellId = 102,
        icon = 132341,
        duration = 0,
        expirationTime = 0,
        isHelpful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 668,
        spellId = 103,
        icon = "interface/icons/spell_holy_flashheal",
        duration = 25,
        isHelpful = true,
        applications = 2,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 669,
        spellId = 104,
        icon = 132144,
        duration = 0,
        expirationTime = 0,
        isHelpful = true,
        applications = 1,
        dispelName = "Magic",
    },
    {
        auraInstanceID = 670,
        spellId = 105,
        icon = 135939,
        duration = 15,
        isHelpful = true,
        applications = 1,
        isStealable = true,
        dispelName = "Magic",
    },
}

local activeInterrupts = {}

local interruptSpells = {
    [1766] = 3,  -- Kick (Rogue)
    [2139] = 5,  -- Counterspell (Mage)
    [6552] = 3,  -- Pummel (Warrior)
    [132409] = 5, -- Spell Lock (Warlock)
    [19647] = 5, -- Spell Lock (Warlock, pet)
    [47528] = 3,  -- Mind Freeze (Death Knight)
    [57994] = 2,  -- Wind Shear (Shaman)
    [91807] = 2,  -- Shambling Rush (Death Knight)
    [96231] = 3,  -- Rebuke (Paladin)
    [93985] = 3,  -- Skull Bash (Druid)
    [116705] = 3, -- Spear Hand Strike (Monk)
    [147362] = 3, -- Counter Shot (Hunter)
    [183752] = 3, -- Disrupt (Demon Hunter)
    [187707] = 3, -- Muzzle (Hunter)
    [212619] = 5, -- Call Felhunter (Warlock)
    [31935] = 3,  -- Avenger's Shield (Paladin)
    [217824] = 4, -- Shield of Virtue (Protection PvP Talent)
    [351338] = 4, -- Quell (Evoker)
}

-- Buffs that reduce interrupt duration
local spellLockReducer = {
    [317920] = 0.7, -- Concentration Aura
    [234084] = 0.5, -- Moon and Stars
    [383020] = 0.5, -- Tranquil Air
}

local interruptEvents = {
    ["SPELL_INTERRUPT"] = true,
    ["SPELL_CAST_SUCCESS"] = true,
}

function BBP.SetUpAuraInterrupts()
    if not BetterBlizzPlatesDB.showInterruptsOnNameplateAuras then return end
    if BBP.interruptTrackerFrame then return end
    local interruptTrackerFrame = CreateFrame("Frame")
    interruptTrackerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    interruptTrackerFrame:SetScript("OnEvent", function()
        local _, event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

        if not interruptEvents[event] then return end

        local duration = interruptSpells[spellId]
        if not duration then return end

        local interruptedNp, wasCasting, isInterruptible = nil, false, false
        local interruptedUnit

        if BBP.isInArena then
            for i = 1, 3 do
                local unit = "arena" .. i
                if UnitGUID(unit) == destGUID then
                    interruptedUnit = true

                    local np, frame = BBP.GetSafeNameplate(unit)
                    if frame then
                        interruptedNp = frame
                    end

                    if event == "SPELL_CAST_SUCCESS" then
                        -- Check if the unit was casting or channeling AND if it was interruptible
                        local _, _, _, _, _, _, notInterruptibleChannel = UnitChannelInfo(unit)
                        if notInterruptibleChannel ~= false then -- nil when not channeling
                            return
                        end
                    end

                    -- Apply interrupt duration reductions based on active buffs
                    AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(_, _, _, _, _, _, _, _, _, spellId)
                        local mult = spellLockReducer[spellId]
                        if mult then
                            duration = duration * mult
                        end
                    end)

                    break
                end
            end
        end

        if not interruptedUnit then
            for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                local frame = nameplate.UnitFrame
                if frame and UnitGUID(frame.unit) == destGUID then
                    interruptedNp = frame

                    if event == "SPELL_CAST_SUCCESS" then
                        -- Check if the unit was casting or channeling AND if it was interruptible
                        local _, _, _, _, _, _, notInterruptibleChannel = UnitChannelInfo(frame.unit)
                        if notInterruptibleChannel ~= false then -- nil when not channeling
                            return
                        end
                    end

                    -- Apply interrupt duration reductions based on active buffs
                    AuraUtil.ForEachAura(frame.unit, "HELPFUL", nil, function(_, _, _, _, _, _, _, _, _, spellId)
                        local mult = spellLockReducer[spellId]
                        if mult then
                            duration = duration * mult
                        end
                    end)

                    break
                end
            end
        end

        local expires = GetTime() + duration

        activeInterrupts[destGUID] = {
            spellId = spellId,
            name = spellName,
            duration = duration,
            expirationTime = expires,
            icon = C_Spell.GetSpellTexture(spellId),
        }

        -- Update the interrupted unit's nameplate buffs
        if interruptedNp then
            BBP.UpdateBuffs(interruptedNp.BuffFrame, interruptedNp.unit, nil, {harmful = true}, interruptedNp)
        end

        -- Clear the interrupt after its duration
        C_Timer.After(duration, function()
            if activeInterrupts[destGUID] and activeInterrupts[destGUID].expirationTime <= GetTime() then
                activeInterrupts[destGUID] = nil

                -- Refresh the nameplate to remove the expired interrupt aura
                for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                    local frame = nameplate.UnitFrame
                    if frame and UnitGUID(frame.unit) == destGUID then
                        BBP.UpdateBuffs(frame.BuffFrame, frame.unit, nil, {harmful = true}, frame)
                        break
                    end
                end
            end
        end)
    end)
    BBP.interruptTrackerFrame = interruptTrackerFrame
end

local opBarriers = {
    [235313] = true, -- Blazing Barrier
    [11426] = true, -- Ice Barrier
    [235450] = true, -- Prismatic Barrier
}

local importantColor = {r = 0, g = 1, b = 0, a = 1}

local importantBuffs = {}
local importantGeneralBuffs = {
    [156621] = {r = 0.207, g = 0.662, b = 1, a = 1}, --true, -- Alliance Flag
    [434339] = {r = 0.207, g = 0.662, b = 1, a = 1}, --true, -- Deephaul Crystal
    [156618] = {r = 1, g = 0, b = 0, a = 1}, --true, -- Horde Flag
    [34976] = importantColor, --true, -- Netherstorm Flag
    [188501] = importantColor,
}
local importantGeneralDebuffs = {
    [121164] = {r = 0, g = 1, b = 0.94, a = 1}, --true, -- Orb of Power
    [121175] = {r = 0.095, g = 0.121, b = 1, a = 1}, --true, -- Orb of Power
    [121176] = {r = 0.553, g = 1, b = 0.16, a = 1}, --true, -- Orb of Power
    [121177] = {r = 1, g = 0.36, b = 0.03, a = 1}, --true, -- Orb of Power
    [372048] = {r = 0, g = 1, b = 0, a = 1}, -- Oppressing Roar
    [212182] = {r = 1, g = 1, b = 1, a = 1}, -- Smoke Bomb
    [359053] = {r = 1, g = 1, b = 1, a = 1}, -- Smoke Bomb
    [383005] = {r = 0, g = 1, b = 0, a = 1}, -- Chrono Loop (Debuff)
}

local ogKeyAuraList = {
    [204018] = "defensiveColor",
    [212800] = "defensiveColor",
    [31224] = "defensiveColor",
    [1022] = "defensiveColor",
    [642] = "defensiveColor",
    [8178] = "defensiveColor",
    [5277] = "defensiveColor",
    [213664] = "defensiveColor",
    [409293] = "defensiveColor",
    [116849] = "defensiveColor",
    [186265] = "defensiveColor",
    [228050] = "defensiveColor",
    [446035] = "offensiveColor",
    [389794] = "offensiveColor",
    [227847] = "offensiveColor",
    [115192] = "offensiveColor",
    [45438] = "importantColor",
    [378078] = "importantColor",
    [473909] = "importantColor",
    [209584] = "importantColor",
    [1221107] = "importantColor",
    [48707] = "importantColor",
    [378441] = "importantColor",
    [213610] = "importantColor",
    [212295] = "importantColor",
    [456499] = "importantColor",
    [408558] = "importantColor",
    [196555] = "importantColor",
    [23920] = "importantColor",
    [378464] = "importantColor",
    [410358] = "importantColor",
    [377362] = "importantColor",
    [444741] = "importantColor",
    [248519] = "importantColor",
    [354610] = "importantColor",
    [353319] = "importantColor",
    [454863] = "importantColor",
    [359816] = "importantColor",
    [212704] = true,
    [69420] = true,

    [342246] = true, -- alter
    [1219209] = true,
    [18499] = true,
    [384100] = true,
    [1044] = true,
    [6940] = true,
    [210256] = "importantColor",
    [45182] = true,
    [383005] = true,
    [444347] = true,
    [209426] = true,
    [357210] = true,
    [433874] = true,
    [118038] = true,
    [1222783] = true,
    [47585] = true,
    [370960] = true,
    [86659] = true,
    [47788] = true,
    [198144] = true,
    [48792] = true,
    [147833] = true,
    [54216] = true,
    [62305] = true,
    [132158] = true, -- ns
    [378081] = true, -- ns
    [53480] = true,
    [289655] = true,
    [387633] = true,
    [199545] = true,
    [125174] = true,
    [199450] = true,
    [212552] = true,

    [32612] = true,
    [5215] = true,
    [58984] = true,
    [110960] = true,
    [199483] = true,
    [414664] = true,

    [212182] = true, -- smoke
    [359053] = true, -- smoke
}

local keyAuraList = {}

local importantOffensives = {
    [190261] = true, -- death wish
    [80353] = true,
    [194249] = true,
    [389794] = true,
    [216468] = true,
    [264667] = true,
    [198144] = true,
    [204362] = true,
    [32182] = true,
    [466904] = true,
    [390386] = true,
    [47568] = true,
    [231895] = true,
    [114051] = true,
    [90355] = true,
    [1218128] = true,
    [115192] = true,
    [357210] = true,
    [395152] = true,
    [106951] = true,
    [10060] = true,
    [1719] = true,
    [375986] = true,
    [395296] = true,
    [390414] = true,
    [51271] = true,
    [359844] = true,
    [107574] = true,
    [2825] = true,
    [384352] = true,
    [391109] = true,
    [207289] = true,
    [191634] = true,
    [190319] = true,
    [19574] = true,
    [114052] = true,
    [442726] = true,
    [102543] = true,
    [433874] = true,
    [114050] = true,
    [360952] = true,
    [186289] = true,
    [12472] = true,
    [288613] = true,
    [121471] = true,
    [187827] = true,
    [446035] = true,
    [394758] = true,
    [162264] = true,
    [383269] = true,
    [205025] = true,
    [365362] = true,
    [384631] = true,
    [50334] = true,
    [13750] = true,
    [200851] = true,
    [31884] = true,
    [102560] = true,
    [204361] = true,
    [227847] = true,
    [137639] = true,
    [185422] = true,
    [454351] = true,
    --[252071] = true, incarn no dur
    [375087] = true,
}
local importantMobility = {
    [199545] = true,
    [205629] = true,
    [206572] = true,
    [221885] = true,
    [294133] = true,
    [254474] = true,
    [62305] = true,
    [54216] = true,
    [48265] = true,
    [221886] = true,
    [254471] = true,
    [221883] = true,
    [221887] = true,
    [254472] = true,
    [444347] = true,
    [276111] = true,
    [1044] = true,
    [212552] = true,
    [276112] = true,
    [453804] = true,
    [387633] = true,
    [254473] = true,
    [363608] = true,
}
local importantDefensives = {
    [117679] = true,
    [161495] = true,
    [132578] = true,
    [29166] = true,
    [102558] = true,
    [212641] = true,
    [443026] = importantColor,
    [462823] = importantColor,
    [359816] = importantColor,
    [390239] = true,
    [213871] = true,
    [384100] = true,
    [216331] = true,
    [317929] = importantColor,
    [456499] = importantColor, -- Absolute Serenity
    [473909] = importantColor, -- tree
    [213664] = importantColor,
    [269513] = importantColor,
    [1221107] = true,
    [31224] = true,
    [118038] = true,
    [45182] = true,
    [31230] = true,
    [125174] = true,
    [424655] = true,
    [408558] = importantColor, -- Phase Shift
    [145629] = true,
    [289655] = importantColor, -- Sanctified Ground
    [202748] = true,
    [378081] = true,
    [5277] = true,
    [122278] = true,
    [264735] = true,
    [48707] = true,
    [378464] = importantColor, -- Nullifying Shroud
    [353319] = importantColor, -- Peaceweaver
    [974] = true,
    [48743] = true,
    [871] = true,
    [232707] = true,
    [212800] = true,
    [61336] = true,
    [81782] = true,
    [213610] = importantColor, -- Holy Ward
    [6940] = true,
    [199450] = importantColor, -- Ultimate Sacrifice
    [120954] = true,
    [385391] = true,
    [18499] = true,
    [642] = true,
    [33206] = true,
    [210294] = true,
    [212704] = true,
    [31850] = true,
    [305497] = true,
    [454863] = true,
    [383648] = true,
    [132158] = true,
    [345231] = true,
    [45438] = true,
    [108271] = true,
    [498] = true,
    [357170] = true,
    [23920] = importantColor, -- Spell Reflection
    [212295] = importantColor, -- Nether Ward
    [102342] = true,
    [22842] = true,
    [374348] = true,
    [97463] = true,
    [403876] = true,
    [184364] = true,
    [374349] = true,
    [378078] = importantColor, -- Spiritwalker's Aegis
    [48792] = true,
    [319454] = true,
    [47585] = true,
    [47788] = true,
    [86659] = true,
    [443609] = true,
    [147833] = true,
    [444741] = true,
    [1219209] = true,
    [232708] = true,
    [370889] = true,
    [116849] = true,
    [378441] = importantColor, -- Time Stop
    [209584] = importantColor, -- Zen Focus Tea
    [53480] = true,
    [196555] = true,
    [410358] = true,
    [1022] = true,
    [210256] = importantColor,
    [209426] = true,
    [414658] = true,
    [79206] = true,
    [377362] = importantColor, -- precog
    [122783] = true,
    [186265] = true,
    [108416] = true,
    [104773] = true,
    [184662] = true,
    [204018] = true,
    [8178] = true,
    [49039] = true,
    [370960] = true,
    [201633] = true,
    [22812] = true,
    [342246] = true,
    [113862] = true,
    [354610] = importantColor, -- Glimpse
    [432180] = true, --dance wind
    [248519] = importantColor, -- Interlope
    [15286] = true,
    [228050] = true,
    [202162] = true,
    [199507] = true,
    [421453] = true,
    [232559] = true,
    [363534] = true,
    [363916] = true,
    [409293] = true,
}

local enlargeAllCCsFilter
local enlargeAllImportantBuffsFilter


local crowdControl = {}
local ccFull = {
    [427773] = true,
    [32752] = true,
    [277778] = true,
    [353084] = true,
    [853] = true,
    [115268] = true,
    [221527] = true,
    [91797] = true,
    [20066] = true,
    [115078] = true,
    [207685] = true,
    [24394] = true,
    [385954] = true,
    [5211] = true,
    [198909] = true,
    [211010] = true,
    [213688] = true,
    [10326] = true,
    [211004] = true,
    [89766] = true,
    [61780] = true,
    [22703] = true,
    [119381] = true,
    [203337] = true,
    [31661] = true,
    [389831] = true,
    [118905] = true,
    [9484] = true,
    [202274] = true,
    [1098] = true,
    [130616] = true,
    [126819] = true,
    [217832] = true,
    [118699] = true,
    [710] = true,
    [377048] = true,
    [360806] = true,
    [61721] = true,
    [3355] = true,
    [372245] = true,
    [107079] = true,
    [200196] = true,
    [202244] = true,
    [199085] = true,
    [28272] = true,
    [82691] = true,
    [108194] = true,
    [316595] = true,
    [87204] = true,
    [211881] = true,
    [5484] = true,
    [213691] = true,
    [277792] = true,
    [316593] = true,
    [287254] = true,
    [105421] = true,
    [20549] = true,
    [51514] = true,
    [77505] = true,
    [5246] = true,
    [61305] = true,
    [2094] = true,
    [1833] = true,
    [200166] = true,
    [385149] = true,
    [255723] = true,
    [161353] = true,
    [197214] = true,
    [163505] = true,
    [6358] = true,
    [33786] = true,
    [221562] = true,
    [334693] = true,
    [200200] = true,
    [2637] = true,
    [460392] = true,
    [261589] = true,
    [391622] = true,
    [64044] = true,
    [205630] = true,
    [305485] = true,
    [8122] = true,
    [6770] = true,
    [118345] = true,
    [255941] = true,
    [309328] = true,
    [132168] = true,
    [132169] = true,
    [179057] = true,
    [203123] = true,
    [161354] = true,
    [161372] = true,
    [388673] = true,
    [321395] = true,
    [605] = true,
    [196942] = true,
    [202346] = true,
    [358861] = true,
    [269352] = true,
    [210141] = true,
    [99] = true,
    [91800] = true,
    [213491] = true,
    [357021] = true,
    [408] = true,
    [277784] = true,
    [211015] = true,
    [208618] = true,
    [287712] = true,
    [383121] = true,
    [205364] = true,
    [207167] = true,
    [277787] = true,
    [210873] = true,
    [1776] = true,
    [28271] = true,
    [1513] = true,
    [61025] = true,
    [161355] = true,
    [118] = true,
    [6789] = true,
    [30283] = true,
    [117526] = true,
}
local ccDisarm = {
    [236077] = true,
    [407032] = true,
    [410201] = true,
    [209749] = true,
    [207777] = true,
    [445134] = true,
    [236236] = true,
    [407031] = true,
    [233759] = true,
}
local ccRoot = {
    [122] = true,
    [356738] = true,
    [157997] = true,
    [376080] = true,
    [199042] = true,
    [198121] = true,
    [323996] = true,
    [378760] = true,
    [393456] = true,
    [105771] = true,
    [307871] = true,
    [190925] = true,
    [233395] = true,
    [355689] = true,
    [116706] = true,
    [228600] = true,
    [212638] = true,
    [45334] = true,
    [247564] = true,
    [370970] = true,
    [201787] = true,
    [324382] = true,
    [451517] = true,
    [64695] = true,
    [356356] = true,
    [204085] = true,
    [102359] = true,
    [386770] = true,
    [460614] = true,
    [114404] = true,
    [235963] = true,
    [170855] = true,
    [339] = true,
    [127797] = true,
    [285515] = true,
    [33395] = true,
    [454787] = true,
}
local ccSilence = {
    [410065] = true,
    [31935] = true,
    [47476] = true,
    [214459] = true,
    [1330] = true,
    [356727] = true,
    [204490] = true,
    [15487] = true,
    [196364] = true,
    [217824] = true,
    [81261] = true,
    [392061] = true,
    [374776] = true,
}


local importantOffensivesColor = {r = 1, g = 0.5, b = 0, a = 1}
local importantMobilityColor = {r = 0, g = 1, b = 1, a = 1}
local importantDefensivesColor = {r = 1, g = 0.662, b = 0.945, a = 1}
local ccFullColor = {r = 1, g = 0.874, b = 0, a = 1}
local ccDisarmColor = {r = 1, g = 0.874, b = 0, a = 1}
local ccRootColor = {r = 1, g = 0.874, b = 0, a = 1}
local ccSilenceColor = {r = 1, g = 0.874, b = 0, a = 1}
local importantColor = {r = 0, g = 1, b = 0, a = 1}



function BBP.UpdateImportantBuffsAndCCTables()
    -- Clear the importantBuffs and crowdControl tables before updating
    wipe(importantBuffs)
    wipe(crowdControl)

    local db = BetterBlizzPlatesDB
    local importantBuffsEnabled = (db.otherNpBuffEnable and db.otherNpBuffFilterImportantBuffs) or (db.friendlyNpBuffEnable and db.friendlyNpBuffFilterImportantBuffs) or (db.personalNpBuffEnable and db.personalNpBuffFilterImportantBuffs)
    local importantCCEnabled = (db.otherNpdeBuffEnable and db.otherNpdeBuffFilterCC) or (db.friendlyNpdeBuffEnable and db.friendlyNpdeBuffFilterCC) or (db.personalNpdeBuffEnable and db.personalNpdeBuffFilterCC)
    local moveKeyAuras = db.nameplateAuraKeyAuraPositionEnabled

    enlargeAllImportantBuffsFilter = importantBuffsEnabled
    enlargeAllCCsFilter = importantCCEnabled

    if importantBuffsEnabled then
        local color = db.importantColor or importantColor
        for spellID, value in pairs (importantGeneralBuffs) do
            importantBuffs[spellID] = value
        end
        for spellID, value in pairs (importantGeneralDebuffs) do
            crowdControl[spellID] = value
        end

        -- Add offensives if enabled
        if db.importantBuffsOffensives then
            local color = not db.importantBuffsOffensivesGlow and true or db.importantBuffsOffensivesGlowRGB or importantOffensivesColor
            for spellID, value in pairs(importantOffensives) do
                importantBuffs[spellID] = value == true and color or value
            end
        end

        -- Add defensives if enabled
        if db.importantBuffsDefensives then
            local color = not db.importantBuffsDefensivesGlow and true or db.importantBuffsDefensivesGlowRGB or importantDefensivesColor
            for spellID, value in pairs(importantDefensives) do
                importantBuffs[spellID] = value == true and color or value
            end
        end

        -- Add mobility if enabled
        if db.importantBuffsMobility then
            local color = not db.importantBuffsMobilityGlow and true or db.importantBuffsMobilityGlowRGB or importantMobilityColor
            for spellID, value in pairs(importantMobility) do
                importantBuffs[spellID] = value == true and color or value
            end
        end
    end

    if moveKeyAuras then
        local checkColors = db.otherNpBuffFilterImportantBuffs or db.friendlyNpBuffFilterImportantBuffs or db.personalNpBuffFilterImportantBuffs
        if db.keyAurasImportantBuffsEnabled then
            for spellID, colorType in pairs(ogKeyAuraList) do
                local color
                if checkColors then
                    if colorType == "defensiveColor" then
                        color = db.importantBuffsDefensives and db.importantBuffsDefensivesGlow and db.importantBuffsDefensivesGlowRGB or true
                    elseif colorType == "offensiveColor" then
                        color = db.importantBuffsOffensives and db.importantBuffsOffensivesGlow and db.importantBuffsOffensivesGlowRGB or true
                    elseif colorType == "importantColor" then
                        color = db.keyAurasImportantGlowOn and importantColor or true
                    else
                        color = true
                    end
                else
                    if colorType == "importantColor" then
                        color = db.keyAurasImportantGlowOn and importantColor or true
                    else
                        color = true
                    end
                end

                keyAuraList[spellID] = color
            end
        else
            for spellID, colorType in pairs(keyAuraList) do
                keyAuraList[spellID] = nil
            end
        end

        for spellID, value in pairs(interruptSpells) do
            keyAuraList[spellID] = true
        end
        keyAuraList[96231] = nil -- Rebuke is an aura now? for no fucking reason? ok i guess

        if not importantCCEnabled then
            --local color = (not db.importantCCFullGlow and true) or (db.importantCCFull and db.importantCCFullGlowRGB) or true
            for spellID, value in pairs(ccFull) do
                keyAuraList[spellID] = true --value == true and color or value
            end
            --local color = (not db.importantCCDisarmGlow and true) or (db.importantCCDisarm and db.importantCCDisarmGlowRGB) or true
            for spellID, value in pairs(ccDisarm) do
                keyAuraList[spellID] = true--value == true and color or value
            end
            --local color = (not db.importantCCRootGlow and true) or (db.importantCCRoot and db.importantCCRootGlowRGB) or true
            for spellID, value in pairs(ccRoot) do
                keyAuraList[spellID] = true--value == true and color or value
            end
            --local color = (not db.importantCCSilenceGlow and true) or (db.importantCCSilence and db.importantCCSilenceGlowRGB) or true
            for spellID, value in pairs(ccSilence) do
                keyAuraList[spellID] = true--value == true and color or value
            end
        end

        -- temp custom
        if db.customKeyAuras and type(db.customKeyAuras) == "table" then
            for spellID, value in pairs(db.customKeyAuras) do
                keyAuraList[spellID] = value
            end
        end
    end

    if importantCCEnabled then

        -- Add CC categories based on settings
        if db.importantCCFull then
            local color = not db.importantCCFullGlow and true or db.importantCCFullGlowRGB or ccFullColor
            for spellID, value in pairs(ccFull) do
                crowdControl[spellID] = value == true and color or value
            end
        end

        if db.importantCCDisarm then
            local color = not db.importantCCDisarmGlow and true or db.importantCCDisarmGlowRGB or ccDisarmColor
            for spellID, value in pairs(ccDisarm) do
                crowdControl[spellID] = value == true and color or value
            end
        end

        if db.importantCCRoot then
            local color = not db.importantCCRootGlow and true or db.importantCCRootGlowRGB or ccRootColor
            for spellID, value in pairs(ccRoot) do
                crowdControl[spellID] = value == true and color or value
            end
        end

        if db.importantCCSilence then
            local color = not db.importantCCSilenceGlow and true or db.importantCCSilenceGlowRGB or ccSilenceColor
            for spellID, value in pairs(ccSilence) do
                crowdControl[spellID] = value == true and color or value
            end
            for spellID, value in pairs(interruptSpells) do
                crowdControl[spellID] = color
            end
        end
    end
end


local castToAuraMap = {
    [212182] = 212183, -- Smoke Bomb
    [359053] = 212183, -- Smoke Bomb
    [198838] = 201633, -- Earthen Wall Totem
    [62618]  = 81782,  -- Power Word: Barrier
    [204336] = 8178,   -- Grounding Totem
    [443028] = 456499, -- Celestial Conduit (Absolute Serenity)
    [289655] = 289655, -- Sanctified Ground
    [34861] = 289655, -- Sanctified Ground
}

local trackedAuras = {
    [212183] = {duration = 5, helpful = false, texture = 458733},  -- Smoke Bomb
    [201633] = {duration = 18, helpful = true, texture = 136098},  -- Earthen Wall
    [81782]  = {duration = 10, helpful = true, texture = 253400},  -- Barrier
    [8178]   = {duration = 3,  helpful = true, texture = 136039},  -- Grounding
    [456499] = {duration = 4, helpful = true, texture = 988197}, -- Absolute Serenity
    [289655] = {duration = 5, helpful = true, texture = 237544}, -- Sanctified Ground
}


local activeNonDurationAuras = {}
BBP.ActiveAuraCheck = CreateFrame("Frame")


local function AddAuraCooldownTimer(frame, auraID)
    local unit = frame.unit
    local aura = trackedAuras[auraID]
    if not aura then return end

    local castTime = activeNonDurationAuras[auraID] or GetTime()
    local duration = aura.duration
    local textureID = aura.texture

    if frame.BigDebuffs then
        if not frame.BigDebuffs.CooldownSB then
            local cooldownFrame = CreateFrame("Cooldown", nil, frame.BigDebuffs, "CooldownFrameTemplate")
            cooldownFrame:SetAllPoints(frame.BigDebuffs.icon)
            cooldownFrame:SetDrawEdge(false)
            cooldownFrame:SetDrawSwipe(true)
            cooldownFrame:SetReverse(true)
            frame.BigDebuffs.CooldownSB = cooldownFrame
        end

        frame.BigDebuffs.CooldownSB:SetCooldown(castTime, duration)
        frame.BigDebuffs.CooldownSB:SetScript("OnUpdate", function(self, elapsed)
            local currentTexture = frame.BigDebuffs.icon:GetTexture()
            if currentTexture ~= textureID then
                self:SetCooldown(0, 0)
                self:SetScript("OnUpdate", nil)
            end
        end)
    end

    if C_AddOns.IsAddOnLoaded("OmniAuras") and unit and string.find(unit, "nameplate") then
        local nameplateUnit = unit:sub(1, 1):upper() .. unit:sub(2, 4):lower() .. unit:sub(5, 5):upper() .. unit:sub(6):lower()
        local oaFrame = _G[nameplateUnit.."Icon"]
        if oaFrame then
            if not oaFrame.CooldownSB then
                local cooldownFrame = CreateFrame("Cooldown", nil, oaFrame:GetParent(), "CooldownFrameTemplate")
                cooldownFrame:SetAllPoints(oaFrame)
                cooldownFrame:SetDrawEdge(false)
                cooldownFrame:SetDrawSwipe(true)
                cooldownFrame:SetReverse(true)
                oaFrame.CooldownSB = cooldownFrame
            end

            oaFrame.CooldownSB:SetCooldown(castTime, duration)
            oaFrame.CooldownSB:SetScript("OnUpdate", function(self, elapsed)
                local currentTexture = oaFrame:GetTexture()
                if currentTexture ~= textureID then
                    self:SetCooldown(0, 0)
                    self:SetScript("OnUpdate", nil)
                end
            end)
        end
    end
end

function BBP.CheckNameplateForTrackedAuras(unit, frame)
    if not unit then return end
    if not string.find(unit, "nameplate") then
        local _, f = BBP.GetSafeNameplate(unit)
        if not f then return end
        frame = f
    end
    if not frame or not frame.unit then return end

    -- Step 1: Determine which aura types are currently active
    local neededAuraTypes = {}
    for auraID in pairs(activeNonDurationAuras) do
        local auraInfo = trackedAuras[auraID]
        if auraInfo then
            local auraType = auraInfo.helpful and "HELPFUL" or "HARMFUL"
            neededAuraTypes[auraType] = true
        end
    end

    -- Step 2: Check only the required aura types
    for auraType in pairs(neededAuraTypes) do
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellID = BBP.TWWUnitAura(frame.unit, i, auraType)
            if not spellID then break end

            local tracked = trackedAuras[spellID]
            if tracked then
                AddAuraCooldownTimer(frame, spellID)
            end
        end
    end
end


function BBP.CheckAllNameplatesForTrackedAuras()
    for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        if frame and frame.unit then
            BBP.CheckNameplateForTrackedAuras(frame.unit, frame)
        end
    end
end

BBP.ActiveAuraCheck:SetScript("OnEvent", function(_, event, unit)
    BBP.CheckNameplateForTrackedAuras(unit)
end)


local function TrackAuraAfterCast()
    local _, subEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if subEvent ~= "SPELL_CAST_SUCCESS" then return end
    if not castToAuraMap[spellID] then return end
    local auraID = castToAuraMap[spellID]

    activeNonDurationAuras[auraID] = GetTime()

    -- Register UNIT_AURA if not already registered
    if not BBP.ActiveAuraCheck.isRegistered then
        BBP.ActiveAuraCheck:RegisterEvent("UNIT_AURA")
        BBP.ActiveAuraCheck.isRegistered = true
    end

    C_Timer.After(0.1, function()
        BBP.CheckAllNameplatesForTrackedAuras()
        BBP.RefreshBuffFrame()
    end)

    local duration = trackedAuras[auraID].duration or 0
    C_Timer.NewTimer(duration, function()
        activeNonDurationAuras[auraID] = nil

        -- Check if any other auras are still active
        local anyActive = false
        for _, activeTime in pairs(activeNonDurationAuras) do
            if activeTime then
                anyActive = true
                break
            end
        end

        -- If none are active, unregister UNIT_AURA
        if not anyActive and BBP.ActiveAuraCheck.isRegistered then
            BBP.ActiveAuraCheck:UnregisterAllEvents()
            BBP.ActiveAuraCheck.isRegistered = false
        end
    end)
end

local function isInWhitelist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            return true
        end
    end
    return false
end

local function isInBlacklist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraBlacklist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            return true
        end
    end
    return false
end

local function GetAuraDetails(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            local isImportant = entry.flags and entry.flags.important or false
            local isPandemic = entry.flags and entry.flags.pandemic or false
            local auraColor = entry.entryColors and entry.entryColors.text or nil
            local onlyMine = entry.flags and entry.flags.onlyMine or false
            local isEnlarged = entry.flags and entry.flags.enlarged or false
            local isCompacted = entry.flags and entry.flags.compacted or false
            return true, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted
        end
    end
    return
end
local importantGlowOffset = 10 * (BetterBlizzPlatesDB.nameplateAuraEnlargedScale or 1)
local trackedBuffs = {};
local checkBuffsTimer = nil;

local function StopCheckBuffsTimer()
    if checkBuffsTimer then
        checkBuffsTimer:Cancel();
        checkBuffsTimer = nil;
    end
end

local pandemicSpells = {
    -- Death Knight
        -- Blood
        [55078] = 24,  -- Blood Plague
        -- Frost
        [55095] = 24,  -- Frost Fever
        -- Unholy
        [191587] = 21, -- Virulent Plague

    -- Demon Hunter
        -- Havoc
        [390181] = 6,  -- Soulscar

    -- Druid
        -- Feral
        [1079] = 24,   -- Rip
        [155722] = 15, -- Rake
        [106830] = 15, -- Thrash
        [155625] = 18, -- Moonfire
        -- Balance
        [164815] = 18, -- Sunfire
        [202347] = 24, -- Stellar Flare
        -- Resto
        [774] = 12,    -- Rejuvenation
        [33763] = 15,  -- Lifebloom
        [8936] = 6,    -- Regrowth

    -- Evoker
        -- Preservation
        [355941] = 8, -- Dream Breath
        -- Augmentation
        [395152] = 10, -- Ebon Might

    -- Hunter
        -- Survival
        [259491] = 12, -- Serpent Sting
        -- Marksman
        [271788] = 18, -- Serpent Sting (Aimed Shot)

    -- Monk
        -- Brewmaster
        [116847] = 6,  -- Rushing Jade Wind
        -- Mistweaver
        [119611] = 20, -- Renewing Mist
        [124682] = 6,  -- Enveloping Mist

    -- Priest
        [139] = 15,    -- Renew
        [589] = 16,    -- Shadow Word: Pain
        -- Discipline
        [204213] = 20, -- Purge the Wicked
        -- Shadow
        [34914] = 21,  -- Vampiric Touch
        [335467] = 6,  -- Devouring Plague

    -- Rogue
        [1943] = 32,   -- Rupture
        [315496] = 12, -- Slice and Dice
        -- Assassination
        [703] = 18,    -- Garrote
        [121411] = 18, -- Crimson Tempest

    -- Shaman
        [188389] = 18, -- Flame Shock
        -- Restoration
        [382024] = 12, -- Earthliving Weapon
        [61295] = 18,  -- Riptide

    -- Warlock
        [445474] = 15.3, -- Wither
        -- Destruction
        [157736] = 21, -- Immolate
        -- Demonology
        [460553] = 20, -- Doom
        -- Affliction
        [146739] = 14, -- Corruption
        [980] = 18,    -- Agony
        [316099] = 21, -- Unstable Affliction

    -- Warrior
        [388539] = 15, -- Rend
        -- Arms
        [262115] = 12, -- Deep Wounds
}


local nonPandemic = 5
local defaultPandemic = 0.3
local uaPandemic = 8
local agonyPandemic = 10

local function GetPandemicThresholds(buff)
    local minBaseDuration = pandemicSpells[buff.spellID] or buff.duration

    -- Specific pandemic logic for Agony with talent
    if buff.spellID == 980 and IsPlayerSpell(453034) then
        -- For Agony with talent, return special threshold
        return agonyPandemic, minBaseDuration * defaultPandemic
    elseif buff.spellID == 316099 and IsPlayerSpell(459376) then
        -- Unstable Affliction with talent
        return uaPandemic, minBaseDuration * defaultPandemic
    elseif pandemicSpells[buff.spellID] then
        -- Use 30% of the greater value (dynamic or minimum) for Pandemic spells
        return nil, minBaseDuration * defaultPandemic
    else
        -- Default non-pandemic (5 seconds)
        return nil, nonPandemic
    end
end

local function CreatePandemicGlow(buff, orange)
    local db = BetterBlizzPlatesDB
    local nameplateAuraSquare = db.nameplateAuraSquare
    local nameplateAuraTaller = db.nameplateAuraTaller
    local buffScale = db.nameplateAuraBuffScale
    local debuffScale = db.nameplateAuraDebuffScale
    --local nameplateAuraScale = db.nameplateAuraScale

    if not buff.PandemicGlow then
        buff.PandemicGlow = buff.GlowFrame:CreateTexture(nil, "OVERLAY")
        buff.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen")
        buff.PandemicGlow:SetDesaturated(true)
    end

    if buff.isKeyAura then
        local scale = db.nameplateKeyAuraScale
        local ten = 16 * scale
        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
    elseif buff.isEnlarged then
        local scale = db.nameplateAuraEnlargedScale
        if db.nameplateAuraEnlargedSquare then
            local ten = 10 * scale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
        else
            if nameplateAuraSquare then
                local ten = 10 * scale
                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
            elseif nameplateAuraTaller then
                local tenfive = 10 * scale
                local eight = 7.5 * scale
                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
            else
                local tenfive = 9.4 * scale
                local sevenfive = 6.4 * scale
                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
            end
        end
    elseif buff.isCompacted then
        local scale = db.nameplateAuraCompactedScale
        if db.nameplateAuraCompactedSquare then
            local fourfive = 4.5 * scale
            local fivefive = 6.4 * scale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -fourfive, fivefive)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", fourfive, -fivefive)
        else
            if nameplateAuraSquare then
                local ten = 10 * scale
                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
            elseif nameplateAuraTaller then
                local tenfive = 10.5 * scale
                local eight = 8 * scale
                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
            else
                local tenfive = 10.5 * scale
                local sevenfive = 7.5 * scale
                buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
            end
        end
    elseif nameplateAuraSquare then
        if buff.isBuff then
            local ten = 10 * buffScale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
        else
            local ten = 10 * debuffScale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
        end
    elseif nameplateAuraTaller then
        if buff.isBuff then
            local ten = 10 * buffScale
            local eight = 7.5 * buffScale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, eight)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -eight)
        else
            local ten = 10 * debuffScale
            local eight = 7.5 * debuffScale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, eight)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -eight)
        end
    else
        if buff.isBuff then
            local tenfive = 9.4 * buffScale
            local eight = 6.4 * buffScale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
        else
            local tenfive = 9.4 * debuffScale
            local eight = 6.4 * debuffScale
            buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
            buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
        end
    end

    if not orange then
        buff.PandemicGlow:SetVertexColor(1, 0, 0)
    else
        buff.PandemicGlow:SetVertexColor(1, 0.25, 0)
    end

    buff.Border:Hide()
    buff.PandemicGlow:Show()

    buff.isPandemicActive = true
end

local function CheckBuffs()
    local currentGameTime = GetTime()
    for auraInstanceID, buff in pairs(trackedBuffs) do
        if buff.isPandemic and buff.expirationTime then
            local remainingDuration = buff.expirationTime - currentGameTime
            local specialPandemicThreshold, defaultPandemicThreshold = GetPandemicThresholds(buff)

            if remainingDuration <= 0 then
                -- Buff expired, remove it and hide the glow
                trackedBuffs[auraInstanceID] = nil
                if buff.PandemicGlow then
                    buff.Border:Show()
                    buff.PandemicGlow:Hide()
                end
                buff.isPandemicActive = false
            else
                -- Check for the default pandemic threshold (red)
                if remainingDuration <= defaultPandemicThreshold then
                    CreatePandemicGlow(buff)
                elseif specialPandemicThreshold and remainingDuration <= specialPandemicThreshold and remainingDuration > defaultPandemicThreshold then
                    CreatePandemicGlow(buff, true)
                else
                    -- Outside the pandemic window, hide the glow
                    if buff.PandemicGlow then
                        buff.PandemicGlow:Hide()
                    end
                    buff.Border:Show()
                    buff.isPandemicActive = false
                end
            end
        else
            buff.Border:Show()
            buff.isPandemicActive = false
            trackedBuffs[auraInstanceID] = nil
        end
    end

    -- Stop the timer if no tracked buffs remain
    if next(trackedBuffs) == nil then
        StopCheckBuffsTimer()
    end
end

local function StartCheckBuffsTimer()
    if not checkBuffsTimer then
        checkBuffsTimer = C_Timer.NewTicker(0.05, CheckBuffs);
    end
end

local function defaultComparator(a, b)
    return a.auraInstanceID < b.auraInstanceID
end

local function durationComparator(a, b)
    if a.isCC ~= b.isCC then
        return a.isCC
    end

    if a.isEnlarged ~= b.isEnlarged then
        return a.isEnlarged
    end

    if a.duration == 0 and b.duration == 0 then
        return a.auraInstanceID < b.auraInstanceID
    elseif a.duration == 0 then
        return false
    elseif b.duration == 0 then
        return true
    end

    local now = GetTime()
    local timeLeftA = (a.expirationTime or 0) - now
    local timeLeftB = (b.expirationTime or 0) - now

    if timeLeftA < 0 then timeLeftA = 0 end
    if timeLeftB < 0 then timeLeftB = 0 end

    if timeLeftA ~= timeLeftB then
        return timeLeftA < timeLeftB
    end

    return a.auraInstanceID < b.auraInstanceID
end

local function reverseDurationComparator(a, b)
    if a.isCC ~= b.isCC then
        return b.isCC
    end

    if a.isEnlarged ~= b.isEnlarged then
        return b.isEnlarged
    end

    if a.duration == 0 and b.duration == 0 then
        return a.auraInstanceID > b.auraInstanceID
    elseif a.duration == 0 then
        return true
    elseif b.duration == 0 then
        return false
    end

    local now = GetTime()
    local timeLeftA = (a.expirationTime or 0) - now
    local timeLeftB = (b.expirationTime or 0) - now

    if timeLeftA < 0 then timeLeftA = 0 end
    if timeLeftB < 0 then timeLeftB = 0 end

    if timeLeftA ~= timeLeftB then
        return timeLeftA > timeLeftB
    end

    return a.auraInstanceID > b.auraInstanceID
end

local function largeSmallAuraComparator(a, b)
    if a.isCC ~= b.isCC then
        return a.isCC
    end

    if a.isEnlarged or b.isEnlarged then
        if a.isEnlarged and not b.isEnlarged then
            return true
        elseif not a.isEnlarged and b.isEnlarged then
            return false
        else
            return defaultComparator(a, b)
        end
    end

    if a.isImportant or b.isImportant then
        if a.isImportant and not b.isImportant then
            return true
        elseif not a.isImportant and b.isImportant then
            return false
        else
            return defaultComparator(a, b)
        end
    end

    if a.isCompacted or b.isCompacted then
        if a.isCompacted and not b.isCompacted then
            return false
        elseif not a.isCompacted and b.isCompacted then
            return true
        else
            return defaultComparator(a, b)
        end
    end

    return defaultComparator(a, b)
end

local function smallLargeAuraComparator(a, b)
    if a.isCompacted or b.isCompacted then
        if a.isCompacted and not b.isCompacted then
            return true
        elseif not a.isCompacted and b.isCompacted then
            return false
        else
            return defaultComparator(a, b)
        end
    end

    if a.isImportant or b.isImportant then
        if a.isImportant and not b.isImportant then
            return true
        elseif not a.isImportant and b.isImportant then
            return false
        else
            return defaultComparator(a, b)
        end
    end

    if a.isEnlarged or b.isEnlarged then
        if a.isEnlarged and not b.isEnlarged then
            return false
        elseif not a.isEnlarged and b.isEnlarged then
            return true
        else
            return defaultComparator(a, b)
        end
    end

    return defaultComparator(a, b)
end

local function CapForLayout(frames, maxCount)
    local visible = {}
    local consumed = 0
    for _, f in ipairs(frames) do
        local consumes = not (f.isKeyAura or f.pinIcon)  -- key/pinned don't count
        if consumes then
            if consumed < maxCount then
                table.insert(visible, f)
                consumed = consumed + 1
            else
                f:Hide()
            end
        else
            table.insert(visible, f) -- always show key/pinned
        end
    end
    return visible
end


function BBP.CustomBuffLayoutChildren(container, children, isEnemyUnit, frame)
    -- Obtain the health bar details
    local healthBar = frame.healthBar
    local healthBarWidth = healthBar:GetWidth()
    -- if not container.GreenOverlay then
    --     local greenOverlay = container:CreateTexture("GreenOverlay", "OVERLAY")
    --     greenOverlay:SetColorTexture(0, 1, 0, 0.5)  -- RGBA: Solid green with 50% opacity
    --     greenOverlay:SetAllPoints(container)  -- Make the texture cover the entire container
    --     container.GreenOverlay = greenOverlay  -- Assign the texture to the container for future reference
    -- end
    -- Define the spacing and row parameters
    local db = BetterBlizzPlatesDB
    local horizontalSpacing = db.nameplateAuraWidthGap
    local nameplateKeyAurasHorizontalGap = db.nameplateKeyAurasHorizontalGap
    local verticalSpacing = -db.nameplateAuraHeightGap or 0-- + (db.nameplateAuraSquare and 12 or 0) + (db.nameplateAuraTaller and 3 or 0)
    local maxBuffsPerRow = (isEnemyUnit and db.nameplateAuraRowAmount) or (not isEnemyUnit and db.nameplateAuraRowFriendlyAmount)
    --local maxRowHeight = 0
    local rowWidths = {}
    local totalChildrenHeight = 0
    local maxBuffsPerRowAdjusted = maxBuffsPerRow
    local nameplateAuraSquare = db.nameplateAuraSquare
    local nameplateAuraTaller = db.nameplateAuraTaller
    local auraHeightSetting = (nameplateAuraSquare and 20) or (nameplateAuraTaller and 15.5) or 14
    local square = db.nameplateAuraEnlargedSquare
    local compactSquare = db.nameplateAuraCompactedSquare
    local auraSize = square and 20 or auraHeightSetting
    local compactSize = compactSquare and 10 or 20
    local nameplateAuraEnlargedScale = db.nameplateAuraEnlargedScale
    local nameplateAuraCompactedScale = db.nameplateAuraCompactedScale
    local auraSizeScaled = auraSize * nameplateAuraEnlargedScale
    local sizeMultiplier = 20 * nameplateAuraEnlargedScale
    local keyAuraSize = 30 * db.nameplateKeyAuraScale
    local texCoord = nameplateAuraSquare and {0.1, 0.9, 0.1, 0.9} or nameplateAuraTaller and {0.05, 0.95, 0.15, 0.82} or {0.05, 0.95, 0.1, 0.6}
    local compactTexCoord = not compactSquare and texCoord or nameplateAuraSquare and {0.25, 0.75, 0.05, 0.95} or nameplateAuraTaller and {0.3, 0.7, 0.15, 0.82} or {0.3, 0.7, 0.15, 0.80}
    local nameplateAuraScale = db.nameplateAuraScale
    local nameplateAuraCountScale = db.nameplateAuraCountScale
    local sortEnlargedAurasFirst = db.sortEnlargedAurasFirst
    local sortCompactedAurasFirst = db.sortCompactedAurasFirst
    local sortDurationAuras = db.sortDurationAuras
    local sortDurationAurasReverse = db.sortDurationAurasReverse
    local keyAuraXPos = db.nameplateKeyAurasXPos
    local keyAuraYPos = db.nameplateKeyAurasYPos
    local keyAuraAnchor = db.nameplateAuraKeyAuraPositionEnabled and db.nameplateKeyAurasAnchor
    local totalChildrenWidth, hasExpandableChild

    local scaledCompactWidth = compactSize * nameplateAuraCompactedScale
    local scaledCompactHeight = auraHeightSetting * nameplateAuraCompactedScale

    local nameplateAuraBuffScale = db.nameplateAuraBuffScale
    local nameplateAuraDebuffScale = db.nameplateAuraDebuffScale
    local scaledBuffWidth = 20 * nameplateAuraBuffScale
    local scaledBuffHeight = auraHeightSetting * nameplateAuraBuffScale
    local scaledDebuffWidth = 20 * nameplateAuraDebuffScale
    local scaledDebuffHeight = auraHeightSetting * nameplateAuraDebuffScale

    local unit = frame.unit
    local isSelf
    if unit then
        isSelf = UnitIsUnit(unit, "player")
    end

    -- Separate buffs and debuffs if needed
    local buffs = {}
    local debuffs = {}
    if db.separateAuraBuffRow then
        for _, buff in ipairs(children) do
            if buff.isBuff then
                table.insert(buffs, buff)
            else
                table.insert(debuffs, buff)
            end
        end
    else
        buffs = children  -- Treat all as buffs for the unified layout
        debuffs = {}  -- No debuffs in this mode
    end

    -- Calculate the width of each row
    local function CalculateRowWidths(auras)
        local widths = {}
        widths[1] = 0
        local compactTracker = 0
        local keyAuras = 0
        local isPinAura = 0
        local hasRealAuras
        for index, buff in ipairs(auras) do
            buff:SetScale(nameplateAuraScale)
            buff.CountFrame:SetScale(nameplateAuraCountScale)
            local buffWidth
            if buff.pinIcon then
                isPinAura = isPinAura + 1
                buffWidth = 0
            elseif buff.isKeyAura then
                keyAuras = keyAuras + 1
                buff:SetSize(keyAuraSize, keyAuraSize)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                buffWidth = sizeMultiplier
                compactTracker = 0
            elseif buff.isEnlarged then
                buff:SetSize(sizeMultiplier, auraSizeScaled)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                if not square then
                    buff.Icon:SetTexCoord(unpack(texCoord))
                else
                    buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
                buffWidth = sizeMultiplier
                --buffHeight = sizeMultiplier
                compactTracker = 0
            elseif buff.isCompacted then
                buff:SetSize(scaledCompactWidth, scaledCompactHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(compactTexCoord))
                buffWidth = scaledCompactWidth
                --buffHeight = 14
                compactTracker = compactTracker + 1
            elseif buff.isBuff then
                buff:SetSize(scaledBuffWidth, scaledBuffHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(texCoord))
                buffWidth = scaledBuffWidth
                --buffHeight = 14
                compactTracker = 0
            else--debuff
                buff:SetSize(scaledDebuffWidth, scaledDebuffHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(texCoord))
                buffWidth = scaledDebuffWidth
                --buffHeight = 14
                compactTracker = 0
            end

            local extraOffset = 0
            if compactSquare and compactTracker == 2 and buff.isCompacted then
                extraOffset = horizontalSpacing
                maxBuffsPerRowAdjusted = maxBuffsPerRowAdjusted + 1
                compactTracker = 0
            end

            --if container.respectChildScale then
                local buffScale = buff:GetScale()
                buffWidth = buffWidth * buffScale
            --end

            local noKeyAuraIndex = index - keyAuras - isPinAura

            local rowIndex = math.floor((noKeyAuraIndex - 1) / maxBuffsPerRowAdjusted) + 1
            if not buff.isKeyAura and not buff.pinIcon then
                hasRealAuras = true
                widths[rowIndex] = (widths[rowIndex] or 0) + buffWidth -extraOffset
            end

            if noKeyAuraIndex % maxBuffsPerRowAdjusted ~= 1 then
                widths[rowIndex] = (widths[rowIndex] or 0) + horizontalSpacing
            end
        end
        return widths, hasRealAuras
    end

    local function CalculateRowWidths2(auras)
        local widths = {}
        local compactTracker = 0

        local nameplateAuraSelfScale = db.nameplateAuraSelfScale

        local npAurasSelfEnlargedEnabled = not db.disableEnlargedAurasOnSelf
        local npAurasSelfCompactedEnabled = not db.disableCompactedAurasOnSelf

        local nameplateAuraBuffScale = db.nameplateAuraBuffSelfScale
        local nameplateAuraDebuffScale = db.nameplateAuraDebuffSelfScale
        local scaledBuffWidth = 20 * nameplateAuraBuffScale
        local scaledBuffHeight = auraHeightSetting * nameplateAuraBuffScale
        local scaledDebuffWidth = 20 * nameplateAuraDebuffScale
        local scaledDebuffHeight = auraHeightSetting * nameplateAuraDebuffScale

        for index, buff in ipairs(auras) do
            buff:SetScale(nameplateAuraSelfScale)
            buff.CountFrame:SetScale(nameplateAuraCountScale)
            local buffWidth
            if buff.isEnlarged and npAurasSelfEnlargedEnabled then
                buff:SetSize(sizeMultiplier, auraSizeScaled)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                if not square then
                    buff.Icon:SetTexCoord(unpack(texCoord))
                else
                    buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
                buffWidth = sizeMultiplier
                --buffHeight = sizeMultiplier
                compactTracker = 0
            elseif buff.isCompacted and npAurasSelfCompactedEnabled then
                buff:SetSize(scaledCompactWidth, scaledCompactHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(compactTexCoord))
                buffWidth = scaledCompactWidth
                --buffHeight = 14
                compactTracker = compactTracker + 1
            elseif buff.isBuff then
                buff:SetSize(scaledBuffWidth, scaledBuffHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(texCoord))
                buffWidth = scaledBuffWidth
                --buffHeight = 14
                compactTracker = 0
            else--debuff
                buff:SetSize(scaledDebuffWidth, scaledDebuffHeight)
                buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
                buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
                buff.Icon:SetTexCoord(unpack(texCoord))
                buffWidth = scaledDebuffWidth
                --buffHeight = 14
                compactTracker = 0
            end

            local extraOffset = 0
            if compactSquare and compactTracker == 2 and buff.isCompacted then
                extraOffset = horizontalSpacing
                maxBuffsPerRowAdjusted = maxBuffsPerRowAdjusted + 1
                compactTracker = 0
            end

            --if container.respectChildScale then
                local buffScale = buff:GetScale()
                buffWidth = buffWidth * buffScale
            --end

            local rowIndex = math.floor((index - 1) / maxBuffsPerRowAdjusted) + 1
            widths[rowIndex] = (widths[rowIndex] or 0) + buffWidth -extraOffset

            if index % maxBuffsPerRowAdjusted ~= 1 then
                widths[rowIndex] = widths[rowIndex] + horizontalSpacing
            end
        end
        return widths
    end

    -- Function to layout auras. ALl of this is scuffed and needs a rework. If one enlarged aura every row gets higher instead of only the row immediately after like intentional.
    local maxRowHeight = 0
    local maxDebuffHeight = 0
    local maxBuffHeight = 0
    local keyAuraOffset = 5
    local function LayoutAuras(auras, startRow, isBuffs)
        local currentRow = startRow
        local horizontalOffset = 0
        local firstRowFirstAuraOffset = nil  -- Variable to store the horizontal offset of the first aura in the first row
        local nameplateAurasFriendlyCenteredAnchor = db.nameplateAurasFriendlyCenteredAnchor and not isEnemyUnit and not isSelf
        local nameplateAurasEnemyCenteredAnchor = db.nameplateAurasEnemyCenteredAnchor and isEnemyUnit and (not db.nameplateCenterOnlyBuffs or isBuffs)
        local nameplateAurasPersonalCenteredAnchor = db.nameplateAurasPersonalCenteredAnchor and isSelf
        local nameplateCenterAllRows = db.nameplateCenterAllRows and (nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor)
        local xPos = db.nameplateAurasXPos
        local nameplateAuraTypeGap = db.nameplateAuraTypeGap
        local rightToLeft = db.nameplateAuraRightToLeft

        local compactTracker = 0
        local indexTracker = 0

        local totalKeyAuraWidth = 0
        local keyAuraCount = 0

        if keyAuraAnchor and keyAuraAnchor == "CENTER" then
            for _, buff in ipairs(auras) do
                if buff.isKeyAura then
                    local w, _ = buff:GetSize()
                    local s = buff:GetScale()
                    totalKeyAuraWidth = totalKeyAuraWidth + (w * s)
                    keyAuraCount = keyAuraCount + 1
                end
            end
            if keyAuraCount > 1 then
                totalKeyAuraWidth = totalKeyAuraWidth + ((keyAuraCount - 1) * nameplateKeyAurasHorizontalGap)
            end
        end

        local keyAuraHorizontalOffset = 0
        local keyAuraFirstRowOffset = 0

        -- local keyAuraXPos = db.nameplateKeyAurasXPos
        -- local keyAuraYPos = db.nameplateKeyAurasYPos

        for index, buff in ipairs(auras) do
            local buffWidth, buffHeight = buff:GetSize()
            local buffScale = buff:GetScale()

            if buff.pinIcon then
                buff:Hide()
            elseif buff.isKeyAura then
                -- buff:ClearAllPoints()
                -- buff:SetPoint("LEFT", healthBar, "RIGHT", keyAuraOffset + keyAuraXPos, keyAuraYPos)
                -- keyAuraOffset = keyAuraOffset + (buffWidth * buffScale) + nameplateKeyAurasHorizontalGap
                buff:ClearAllPoints()

                local anchor = keyAuraAnchor or "RIGHT" -- Default to RIGHT if not set

                if anchor == "RIGHT" then
                    buff:SetPoint("LEFT", healthBar, "RIGHT", keyAuraOffset + keyAuraXPos, keyAuraYPos)
                    keyAuraOffset = keyAuraOffset + buffWidth + nameplateKeyAurasHorizontalGap
                elseif anchor == "LEFT" then
                    buff:SetPoint("RIGHT", healthBar, "LEFT", -(keyAuraOffset + keyAuraXPos), keyAuraYPos)
                    keyAuraOffset = keyAuraOffset + buffWidth + nameplateKeyAurasHorizontalGap
                elseif anchor == "CENTER" then
                    if keyAuraHorizontalOffset == 0 then
                        keyAuraFirstRowOffset = (healthBarWidth - totalKeyAuraWidth) / 2
                    end
                    buff:SetPoint("BOTTOMLEFT", healthBar, "LEFT", (keyAuraFirstRowOffset + keyAuraHorizontalOffset + keyAuraXPos)/buffScale, keyAuraYPos + 45)
                    keyAuraHorizontalOffset = keyAuraHorizontalOffset + buffWidth + nameplateKeyAurasHorizontalGap
                end
            else
                indexTracker = indexTracker + 1
                if buff.isEnlarged then
                    compactTracker = 0
                elseif buff.isCompacted then
                    compactTracker = compactTracker + 1
                else
                    compactTracker = 0
                end


                -- Update the maximum row height
                maxRowHeight = math.max(maxRowHeight, buffHeight)

                -- Determine if it's the start of a new row
                if indexTracker % maxBuffsPerRowAdjusted == 1 then
                    local rowIndex = math.floor((indexTracker - 1) / maxBuffsPerRowAdjusted) + 1
                    if buff.isCompacted then
                        compactTracker = 1
                    else
                        compactTracker = 0
                    end

                    if nameplateCenterAllRows then
                        horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                    elseif nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor or nameplateAurasPersonalCenteredAnchor then
                        if rowIndex == 1 then
                            horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                            firstRowFirstAuraOffset = horizontalOffset  -- Save this offset for the first aura
                        else
                            horizontalOffset = firstRowFirstAuraOffset or 0  -- Use the saved offset for the first aura of subsequent rows
                        end
                    else
                        horizontalOffset = 0  -- or any other default starting offset
                    end

                    if indexTracker > 1 then
                        currentRow = currentRow + 1  -- Move to the next row
                    end
                end

                -- Position the buff on the nameplate
                buff:ClearAllPoints()
                local verticalOffset
                if not isBuffs then
                    maxDebuffHeight = maxRowHeight
                    verticalOffset = -currentRow * (-maxRowHeight + (currentRow > 0 and verticalSpacing or 0))
                else
                    maxBuffHeight = maxRowHeight
                    verticalOffset = (-currentRow * (-maxDebuffHeight + (currentRow > 0 and verticalSpacing or 0))) + nameplateAuraTypeGap
                end

                local extraOffset = 0
                if compactSquare and compactTracker == 2 and buff.isCompacted then
                    extraOffset = BetterBlizzPlatesDB.nameplateAuraWidthGap
                    compactTracker = 0
                end

                if isSelf then
                    if nameplateAurasPersonalCenteredAnchor then
                        if rightToLeft then
                            buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (db.nameplateAurasPersonalXPos + 1 - (extraOffset/buffScale))), verticalOffset - 13)
                        else
                            buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + (db.nameplateAurasPersonalXPos + 1 - extraOffset/buffScale), verticalOffset - 13)
                        end
                    else
                        if rightToLeft then
                            buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (xPos + 1 - (extraOffset/buffScale))), verticalOffset - 13)
                        else
                            buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + db.nameplateAurasPersonalXPos - extraOffset/buffScale, verticalOffset - 13)
                        end
                    end
                else
                    if nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
                        if rightToLeft then
                            buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (xPos + 1 - (extraOffset/buffScale))), verticalOffset - 13)
                        else
                            buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + (xPos + 1 - extraOffset/buffScale), verticalOffset - 13)
                        end
                    else
                        if rightToLeft then
                            buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (xPos - (extraOffset/buffScale))), verticalOffset - 13)
                        else
                            buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + xPos - extraOffset/buffScale, verticalOffset - 13)
                        end
                    end
                end
                horizontalOffset = horizontalOffset + ((buffWidth)*buffScale) + horizontalSpacing-extraOffset
            end
        end

        return currentRow
    end

    -- Layout logic
    local lastRow = 0
    if db.separateAuraBuffRow then
        local hasNormalDebuff
        if #debuffs > 0 then
            if sortDurationAurasReverse then
                table.sort(debuffs, reverseDurationComparator)
            elseif sortDurationAuras then
                table.sort(debuffs, durationComparator)
            elseif sortEnlargedAurasFirst then
                table.sort(debuffs, largeSmallAuraComparator)
            elseif sortCompactedAurasFirst then
                table.sort(debuffs, smallLargeAuraComparator)
            end
            debuffs = CapForLayout(debuffs, BetterBlizzPlatesDB.maxAurasOnNameplate)
            if isSelf then
                rowWidths, hasNormalDebuff = CalculateRowWidths2(debuffs)
            else
                rowWidths, hasNormalDebuff = CalculateRowWidths(debuffs)
            end
            lastRow = LayoutAuras(debuffs, 0)
        end

        if sortDurationAurasReverse then
            table.sort(buffs, reverseDurationComparator)
        elseif sortDurationAuras then
            table.sort(buffs, durationComparator)
        elseif sortEnlargedAurasFirst then
            table.sort(buffs, largeSmallAuraComparator)
        elseif sortCompactedAurasFirst then
            table.sort(buffs, smallLargeAuraComparator)
        end
        buffs = CapForLayout(buffs, BetterBlizzPlatesDB.maxAurasOnNameplate)
        rowWidths = isSelf and CalculateRowWidths2(buffs) or CalculateRowWidths(buffs)
        LayoutAuras(buffs, lastRow + ((#debuffs > 0 and hasNormalDebuff) and 1 or 0), true)
    else
        if sortDurationAurasReverse then
            table.sort(buffs, reverseDurationComparator)
        elseif sortDurationAuras then
            table.sort(buffs, durationComparator)
        elseif sortEnlargedAurasFirst then
            table.sort(buffs, largeSmallAuraComparator)
        elseif sortCompactedAurasFirst then
            table.sort(buffs, smallLargeAuraComparator)
        end
        buffs = CapForLayout(buffs, BetterBlizzPlatesDB.maxAurasOnNameplate)
        rowWidths = isSelf and CalculateRowWidths2(buffs) or CalculateRowWidths(buffs)
        lastRow = LayoutAuras(buffs, 0)
    end

    -- Calculate total children height
    totalChildrenHeight = (lastRow + 1) * (maxRowHeight + verticalSpacing)

    return totalChildrenWidth, totalChildrenHeight, hasExpandableChild
end

local cachedDebuffColors
function BBP.UpdateAuraTypeColors()
    local db = BetterBlizzPlatesDB
    cachedDebuffColors = {
        Magic = db.npAuraMagicRGB,
        Poison = db.npAuraPoisonRGB,
        Curse = db.npAuraCurseRGB,
        Disease = db.npAuraDiseaseRGB,
    }
end

local function SetAuraBorderColorByType(buff, aura, db)
    if not db.npColorAuraBorder then return end

    local debuffColors = cachedDebuffColors

    if aura.isHelpful then
        buff.Border:SetColorTexture(unpack(db.npAuraBuffsRGB))
    else
        local color = debuffColors[aura.dispelName] or db.npAuraOtherRGB
        buff.Border:SetColorTexture(unpack(color))
    end
end

local function SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)
    local otherNpBuffPurgeGlow = BetterBlizzPlatesDB.otherNpBuffPurgeGlow
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if otherNpBuffPurgeGlow then
        if not isPlayerUnit and isEnemyUnit then
            local alwaysShowPurgeTexture = BetterBlizzPlatesDB.alwaysShowPurgeTexture
            if aura.isHelpful and (aura.isStealable or (alwaysShowPurgeTexture and aura.dispelName == "Magic" and aura.isHelpful)) then
                buff.Icon:SetScale(0.5)

                if not buff.buffBorderPurge then
                    buff.buffBorderPurge = buff.GlowFrame:CreateTexture(nil, "ARTWORK")
                    buff.buffBorderPurge:SetAtlas("newplayertutorial-drag-slotblue")
                end

                if buff.isKeyAura then
                    local ten = 16 * BetterBlizzPlatesDB.nameplateKeyAuraScale
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)

                elseif buff.isEnlarged then
                    if BetterBlizzPlatesDB.nameplateAuraEnlargedSquare then
                        local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
                    else
                        if nameplateAuraSquare then
                            local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                            buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
                        elseif nameplateAuraTaller then
                            local tenfive = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            local eight = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                            buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                        else
                            local tenfive = 9.4 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            local sevenfive = 6.4 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                            buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive)
                            buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive)
                        end
                    end

                elseif buff.isCompacted then
                    if BetterBlizzPlatesDB.nameplateAuraCompactedSquare then
                        local scale = BetterBlizzPlatesDB.nameplateAuraCompactedScale
                        local fourfive = 4.5 * scale
                        local fivefive = 6.4 * scale
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -fourfive, fivefive)
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", fourfive, -fivefive)
                    else
                        if nameplateAuraSquare then
                            local ten = 10 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                            buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                            buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
                        elseif nameplateAuraTaller then
                            local tenfive = 10 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                            local eight = 7.5 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                            buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                            buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                        else
                            local tenfive = 9.4 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                            local sevenfive = 6.4 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                            buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive)
                            buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive)
                        end
                    end

                elseif nameplateAuraSquare then
                    local buffScale = BetterBlizzPlatesDB.nameplateAuraBuffScale
                    local tenfive = 10 * buffScale
                    local eight = 10 * buffScale
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)

                elseif nameplateAuraTaller then
                    local buffScale = BetterBlizzPlatesDB.nameplateAuraBuffScale
                    local tenfive = 10 * buffScale
                    local eight = 7.5 * buffScale
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)

                else
                    local buffScale = BetterBlizzPlatesDB.nameplateAuraBuffScale
                    local tenfive = 9.4 * buffScale
                    local eight = 6.4 * buffScale
                    buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                end

                buff.buffBorderPurge:Show()
                buff.Border:Hide()
            else
                if buff.buffBorderPurge then
                    buff.buffBorderPurge:Hide()
                    buff.Border:Show()
                end
            end
        else
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
                buff.Border:Show()
            end
        end
    else
        buff.Icon:SetScale(1)
        if buff.buffBorderPurge then
            buff.buffBorderPurge:Hide()
            buff.Border:Show()
        end
    end
end


local function SetPandemicGlow(buff, aura, isPandemic)
    if aura.duration and buff and aura.expirationTime and isPandemic then
        buff.isPandemic = true
        buff.expirationTime = aura.expirationTime;
        trackedBuffs[aura.auraInstanceID] = buff;
        StartCheckBuffsTimer();
    else
        if buff.PandemicGlow then
            buff.PandemicGlow:Hide()
        end
        buff.isPandemic = false
    end
end

local function SetImportantGlow(buff, isPlayerUnit, isImportant, auraColor)
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if isImportant then
        local buffScale = BetterBlizzPlatesDB.nameplateAuraBuffScale
        local debuffScale = BetterBlizzPlatesDB.nameplateAuraDebuffScale
        if isPlayerUnit then
            buffScale = BetterBlizzPlatesDB.nameplateAuraBuffSelfScale
            debuffScale = BetterBlizzPlatesDB.nameplateAuraDebuffSelfScale
        end
        buff.Icon:SetScale(0.5)
        --if not isPlayerUnit then
            if not buff.ImportantGlow then
                buff.ImportantGlow = buff.GlowFrame:CreateTexture(nil, "ARTWORK")
                buff.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                buff.ImportantGlow:SetDesaturated(true)
            end
            if buff.isKeyAura then
                local ten = 16 * BetterBlizzPlatesDB.nameplateKeyAuraScale
                buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
            elseif buff.isEnlarged then
                if BetterBlizzPlatesDB.nameplateAuraEnlargedSquare then
                    local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten)
                else
                    if nameplateAuraSquare then
                        local ten = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                        buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                    elseif nameplateAuraTaller then
                        local tenfive = 10 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        local eight = 7.5 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                        buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                    else
                        local tenfive = 9.4 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        local sevenfive = 6.4 * BetterBlizzPlatesDB.nameplateAuraEnlargedScale
                        buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                        buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                    end
                end
            elseif buff.isCompacted then
                if BetterBlizzPlatesDB.nameplateAuraCompactedSquare then
                    local scale = BetterBlizzPlatesDB.nameplateAuraCompactedScale
                    local fourfive = 4.5 * scale
                    local fivefive = 6.4 * scale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -fourfive, fivefive)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", fourfive, -fivefive)
                else
                    if nameplateAuraSquare then
                        local ten = 10 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                        buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -ten, ten);
                        buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", ten, -ten);
                    elseif nameplateAuraTaller then
                        local tenfive = 10 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                        local eight = 7.5 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                        buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight);
                        buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight);
                    else
                        local tenfive = 9.4 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                        local sevenfive = 6.4 * BetterBlizzPlatesDB.nameplateAuraCompactedScale
                        buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, sevenfive);
                        buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -sevenfive);
                    end
                end
            elseif nameplateAuraSquare then
                if buff.isBuff then
                    local tenfive = 10 * buffScale
                    local eight = 10 * buffScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                else
                    local tenfive = 10 * debuffScale
                    local eight = 10 * debuffScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                end
            elseif nameplateAuraTaller then
                if buff.isBuff then
                    local tenfive = 10 * buffScale
                    local eight = 7.5 * buffScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                else
                    local tenfive = 10 * debuffScale
                    local eight = 7.5 * debuffScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                end
            else
                if buff.isBuff then
                    local tenfive = 9.4 * buffScale
                    local eight = 6.4 * buffScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                else
                    local tenfive = 9.4 * debuffScale
                    local eight = 6.4 * debuffScale
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -tenfive, eight)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", tenfive, -eight)
                end
            end
            -- If extra glow for purge
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
            if auraColor then
                buff.ImportantGlow:SetVertexColor(auraColor.r, auraColor.g, auraColor.b, auraColor.a)
            else
                buff.ImportantGlow:SetVertexColor(0, 1, 0)
            end
            buff.ImportantGlow:Show()
            buff.Border:Hide()
        --else
            -- if buff.ImportantGlow then
            --     buff.ImportantGlow:Hide()
            --     buff.Border:Show()
            -- end
        --end
    else
        buff.Icon:SetScale(1)
        if buff.ImportantGlow then
            buff.ImportantGlow:Hide()
            buff.Border:Show()
        end
    end
end

local function ShouldShowBuff(unit, aura, BlizzardShouldShow, filterAllOverride, interrupt)
    if not aura then return false end
    local spellName = aura.name
    local spellId = aura.spellId
    local duration = aura.duration
    local expirationTime = aura.expirationTime
    local caster = aura.sourceUnit
    local db = BetterBlizzPlatesDB
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
    local isPurgeable = aura.isStealable or (aura.dispelName == "Magic" and aura.isHelpful and (not db.otherNpBuffFilterPurgeableHasPurge and not isFriend))
    local castByPlayer = (caster == "player" or caster == "pet")
    local moreThanOneMin = (duration > 60 or duration == 0 or expirationTime == 0)
    local lessThanOneMin = duration < 61 or duration == 0 or expirationTime == 0


    -- PLAYER
    if UnitIsUnit(unit, "player") then
        -- Buffs
        if db["personalNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = db["personalNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return false end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = db["personalNpBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = db["personalNpBuffFilterLessMinite"]
            local filterOnlyMe = db["personalNpBuffFilterOnlyMe"]
            local filterBlizzard = db["personalNpBuffFilterBlizzard"]
            local filterImportantBuffs = db["personalNpBuffFilterImportantBuffs"]

            local anyFilter = filterBlizzard or filterLessMinite or filterOnlyMe or filterImportantBuffs

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterImportantBuffs and importantBuffs[spellId] then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- Filter to show only Blizzard recommended auras
                if not BlizzardShouldShow and filterBlizzard then
                    if filterImportantBuffs and importantBuffs[spellId] then return true end
                    if filterLessMinite and lessThanOneMin then return true end
                    return false
                end

                if filterImportantBuffs and not importantBuffs[spellId] then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
        -- Debuffs
        if db["personalNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = db["personalNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end
            if interrupt then return true end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = db["personalNpdeBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = db["personalNpdeBuffFilterLessMinite"]
            local filterCC = db["personalNpdeBuffFilterCC"]

            local anyFilter = filterLessMinite or filterCC

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end
            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if filterCC and not crowdControl[spellId] then
                    if filterLessMinite and lessThanOneMin then return true end
                    return false
                end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then if not auraWhitelisted then return false end end
                return true
            end
        end

    -- FRIENDLY
    elseif isFriend then
        -- Buffs
        if db["friendlyNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = db["friendlyNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local showKeyAuras = db["nameplateAuraKeyAuraPositionEnabled"] and db["nameplateAuraKeyAuraPositionFriendly"]
            if showKeyAuras and keyAuraList[spellId] then
                return true
            end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = db["friendlyNpBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = db["friendlyNpBuffFilterLessMinite"]
            local filterOnlyMe = db["friendlyNpBuffFilterOnlyMe"]
            local filterImportantBuffs = db["friendlyNpBuffFilterImportantBuffs"]

            local anyFilter = filterLessMinite or filterOnlyMe or filterImportantBuffs

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterImportantBuffs and importantBuffs[spellId] then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end

                if filterImportantBuffs and not importantBuffs[spellId] then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
        -- Debuffs
        if db["friendlyNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = db["friendlyNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end
            if interrupt then return true end

            local showKeyAuras = db["nameplateAuraKeyAuraPositionEnabled"] and db["nameplateAuraKeyAuraPositionFriendly"]
            if showKeyAuras and keyAuraList[spellId] then
                return true
            end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = db["friendlyNpdeBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterBlizzard = db["friendlyNpdeBuffFilterBlizzard"]
            local filterLessMinite = db["friendlyNpdeBuffFilterLessMinite"]
            local filterOnlyMe = db["friendlyNpdeBuffFilterOnlyMe"]
            local filterCC = db["friendlyNpdeBuffFilterCC"] or (db["classIndicator"] and db["classIndicatorCCAuras"])

            local anyFilter = filterBlizzard or filterLessMinite or filterOnlyMe or filterCC

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterCC and crowdControl[spellId] then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- Filter to show only Blizzard recommended auras
                if not BlizzardShouldShow and filterBlizzard then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterCC and crowdControl[spellId] then return true end
                    if filterOnlyMe then return true end
                    return false
                end

                if filterCC and not crowdControl[spellId] then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
    -- ENEMY
    else
        -- Buffs
        if db["otherNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = db["otherNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local showKeyAuras = db["nameplateAuraKeyAuraPositionEnabled"]
            if showKeyAuras and keyAuraList[spellId] then
                return true
            end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = db["otherNpBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterLessMinite = db["otherNpBuffFilterLessMinite"]
            local filterPurgeable = db["otherNpBuffFilterPurgeable"] and not (db.otherNpBuffFilterPurgeablePvEOnly and BBP.isInPvE)
            local filterImportantBuffs = db["otherNpBuffFilterImportantBuffs"]

            local anyFilter = filterLessMinite or filterPurgeable or filterImportantBuffs

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end

                if filterImportantBuffs then
                    if importantBuffs[spellId] then
                        return true
                    else
                        if filterPurgeable then
                            if isPurgeable then return true else return false end
                        end
                        if moreThanOneMin and filterLessMinite then return false end
                        return false
                    end
                end

                -- Filter to hide long duration auras
                if filterPurgeable and not isPurgeable then return false end
                if moreThanOneMin and filterLessMinite then return false end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
        -- Debuffs
        if db["otherNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = db["otherNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end
            if interrupt then return true end

            local showKeyAuras = db["nameplateAuraKeyAuraPositionEnabled"]
            if showKeyAuras and keyAuraList[spellId] then
                return true
            end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWhitelist = db["otherNpdeBuffFilterWatchList"]
            local auraWhitelisted = filterWhitelist and isInWhitelist
            local filterBlizzard = db["otherNpdeBuffFilterBlizzard"]
            local filterLessMinite = db["otherNpdeBuffFilterLessMinite"]
            local filterOnlyMe = db["otherNpdeBuffFilterOnlyMe"]
            local filterCC = db["otherNpdeBuffFilterCC"]

            local anyFilter = filterBlizzard or filterLessMinite or filterOnlyMe or filterCC

            if filterAllOverride then return true end
            if onlyMine and not castByPlayer then return false end

            if not anyFilter then
                if filterWhitelist and not isInWhitelist then return false end
                return true
            else
                if auraWhitelisted then return true end
                -- Filter to hide long duration auras
                if moreThanOneMin and filterLessMinite then return false end
                -- Handle filter for only showing the player's auras and Blizzard's recommendations
                if filterOnlyMe then
                    if castByPlayer then return true end
                    if filterCC and crowdControl[spellId] then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- Filter to show only Blizzard recommended auras
                if not BlizzardShouldShow and filterBlizzard then
                    if filterCC and crowdControl[spellId] then return true end
                    if filterLessMinite and lessThanOneMin then return true end
                    return false
                end

                if filterCC and not crowdControl[spellId] then
                    if filterLessMinite and lessThanOneMin then return true end
                    if filterBlizzard then return BlizzardShouldShow end
                    return false
                end
                -- If none of the specific sub-filter conditions are met, show the aura
                return true
            end
        end
    end
end

function BBP.OnUnitAuraUpdate(self, unit, unitAuraUpdateInfo)
    local filter;
    local showAll = false;

    local isPlayer = UnitIsUnit("player", unit);
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
    isEnemy = isEnemy or isNeutral
    local showDebuffsOnFriendly = self.showDebuffsOnFriendly;

    local auraSettings =
    {
        helpful = false;
        harmful = false;
        raid = false;
        includeNameplateOnly = false;
        showAll = false;
        hideAll = false;
    };

    if isPlayer then
        auraSettings.helpful = true;
        auraSettings.includeNameplateOnly = true;
        auraSettings.showPersonalCooldowns = self.showPersonalCooldowns;
    else
        if isEnemy then
            auraSettings.harmful = true;
            auraSettings.includeNameplateOnly = true;
        else
            if (showDebuffsOnFriendly) then
                -- dispellable debuffs
                auraSettings.harmful = true;
                auraSettings.raid = true;
                auraSettings.showAll = true;
            else
                auraSettings.hideAll = false; -- changed to false (would sometimes hide buffs on friendly targets if buff setting was on, TODO figure out more)
            end
        end
    end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
    if (nameplate) then
        BBP.UpdateBuffs(nameplate.UnitFrame.BuffFrame, nameplate.namePlateUnitToken, unitAuraUpdateInfo, auraSettings, nameplate.UnitFrame);
    end
end

function BBP.UpdateBuffs(self, unit, unitAuraUpdateInfo, auraSettings, UnitFrame)
    local filters = {};
    if auraSettings.helpful then
        table.insert(filters, AuraUtil.AuraFilters.Helpful);
    end
    if auraSettings.harmful then
        table.insert(filters, AuraUtil.AuraFilters.Harmful);
    end
    if auraSettings.raid then
        table.insert(filters, AuraUtil.AuraFilters.Raid);
    end
    if auraSettings.includeNameplateOnly then
        table.insert(filters, AuraUtil.AuraFilters.IncludeNameplateOnly);
    end
    local filterString = AuraUtil.CreateFilterString(unpack(filters));

    local previousFilter = self.filter;
    local previousUnit = self.unit;
    self.unit = unit;
    self.filter = filterString;
    self.showFriendlyBuffs = auraSettings.showFriendlyBuffs;

    local aurasChanged = false;
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filterString ~= previousFilter then
        BBP.ParseAllAuras(self, auraSettings.showAll, UnitFrame);
        aurasChanged = true;
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                local BlizzardShouldShow = self:ShouldShowBuff(aura, auraSettings.showAll) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, filterString) and not (BetterBlizzPlatesDB.blizzardDefaultFilterOnlyMine and (aura.sourceUnit ~= "player" and aura.sourceUnit~= "pet"))
                if ShouldShowBuff(unit, aura, BlizzardShouldShow) then
                    self.auras[aura.auraInstanceID] = aura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
                    self.auras[auraInstanceID] = newAura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    self.auras[auraInstanceID] = nil;
                    aurasChanged = true;
                end
            end
        end
    end

    self:UpdateAnchor();

    if not aurasChanged then
        return;
    end

    self.buffPool:ReleaseAll();

    --if auraSettings.hideAll or not self.isActive then
    if not self.isActive then
        return;
    end

    local db = BetterBlizzPlatesDB
    local buffIndex = 1;
    local BBPMaxAuraNum = db.maxAurasOnNameplate
    local isPlayerUnit = UnitIsUnit("player", self.unit)
    local isEnemyUnit, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
    isEnemyUnit = isEnemyUnit or isNeutral
    self.isEnemyUnit = isEnemyUnit
    local shouldShowAura, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted
    local onlyPandemicMine = db.onlyPandemicAuraMine
    local showDefaultCooldownNumbersOnNpAuras = db.showDefaultCooldownNumbersOnNpAuras
    local hideNpAuraSwipe = db.hideNpAuraSwipe
    local enlargeAllImportantBuffs = db.enlargeAllImportantBuffs
    local enlargeAllCC = db.enlargeAllCC
    local opBarriersOn = db.opBarriersEnabled
    local npAuraStackFontEnabled = db.npAuraStackFontEnabled
    local moveKeyAuras = db.nameplateAuraKeyAuraPositionEnabled
    local moveKeyAurasFriendly = db.nameplateAuraKeyAuraPositionFriendly
    --local ccGLow = db.

    local longestCCAura = nil
    local longestCCDuration = 0
    local pinnedAuras = isFriend and ((db["classIndicator"] and db["classIndicatorCCAuras"]) or (db["partyPointer"] and db["partyPointerCCAuras"])) and not (moveKeyAuras and moveKeyAurasFriendly)

    self.auras:Iterate(function(auraInstanceID, aura)
        --if buffIndex > BBPMaxAuraNum then return true end
        local buff = self.buffPool:Acquire();
        buff.auraInstanceID = auraInstanceID;
        buff.isBuff = aura.isHelpful;
        buff.layoutIndex = buffIndex;
        buff.spellID = aura.spellId;
        buff.duration = aura.duration;
        buff.expirationTime = aura.expirationTime

        buff.Icon:SetTexture(aura.icon);

        local spellName = aura.name--FetchSpellName(aura.spellId)
        local spellId = aura.spellId
        local caster = aura.sourceUnit
        local castByPlayer = (caster == "player" or caster == "pet")

        shouldShowAura, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted = GetAuraDetails(spellName, spellId)
        if onlyPandemicMine and not castByPlayer then
            isPandemic = false
        end

        if buff.Cooldown._occ_display then
            buff.Cooldown._occ_display:SetFrameStrata("FULLSCREEN")
        end
        buff.isKeyAura = nil
        buff.isCC = nil
        buff.pinIcon = nil

        buff:SetFrameStrata("HIGH")

        if moveKeyAuras then
            local isKeyAura = keyAuraList[spellId]
            if isKeyAura then
                if isEnemyUnit then
                    buff:SetFrameStrata("DIALOG")
                    buff.isKeyAura = true
                    isEnlarged = true
                    if isKeyAura ~= true and not isImportant then
                        isImportant = true
                        auraColor = isKeyAura
                    end
                else
                    if moveKeyAurasFriendly then
                        buff:SetFrameStrata("DIALOG")
                        buff.isKeyAura = true
                        isEnlarged = true
                        if isKeyAura ~= true and not isImportant then
                            isImportant = true
                            auraColor = isKeyAura
                        end
                    end
                end
            end
        end

        local isImportantBuff = importantBuffs[spellId]
        if isImportantBuff then
            if enlargeAllImportantBuffs and enlargeAllImportantBuffsFilter then
                if not isCompacted then
                    isEnlarged = true
                end
            end
            if isImportantBuff ~= true and not isImportant then
                isImportant = true
                auraColor = isImportantBuff
            end
            if buff.spellID == 432180 and not shouldShowAura and aura.applications < 5 then
                buff.pinIcon = true
            end
        end

        local isCC = crowdControl[spellId]
        if isCC then
            buff.isCC = true
            if isEnemyUnit then
                if db.otherNpdeBuffFilterCC then
                    if moveKeyAuras and ((moveKeyAurasFriendly and not isEnemyUnit) or isEnemyUnit) then
                        buff.isKeyAura = true
                    end
                    if enlargeAllCC and enlargeAllCCsFilter then
                        isEnlarged = true
                    end
                    if isCC ~= true and not isImportant then
                        isImportant = true
                        auraColor = isCC
                    end
                end
            else
                if moveKeyAuras and ((moveKeyAurasFriendly and not isEnemyUnit) or isEnemyUnit) then
                    buff.isKeyAura = true
                end
                if enlargeAllCC and enlargeAllCCsFilter then
                    isEnlarged = true
                end
                if isCC ~= true and not isImportant then
                    isImportant = true
                    auraColor = isCC
                end
            end

            if pinnedAuras and UnitFrame.classIndicatorCC then
                if buff.duration and buff.expirationTime and buff.expirationTime > longestCCDuration then
                    longestCCDuration = buff.expirationTime
                    local ciColor
                    if isCC ~= true then
                        -- if not isImportant then
                        --     if aura.dispelName == "Curse" then
                        --         ciColor = {r = 0.6, g = 0, b = 1.0, a = 1}
                        --     elseif aura.dispelName == "Magic" then
                        --         ciColor = {r = 0.2, g = 0.6, b = 1.0, a = 1}
                        --     else
                        --         ciColor = auraColor
                        --     end
                        -- else
                            ciColor = auraColor or ccFullColor
                        --end
                    else
                        -- if aura.dispelName == "Curse" then
                        --     ciColor = {r = 0.6, g = 0, b = 1.0, a = 1}
                        -- elseif aura.dispelName == "Magic" then
                        --     ciColor = {r = 0.2, g = 0.6, b = 1.0, a = 1}
                        -- else
                            ciColor = ccFullColor
                        --end
                    end
                    if type(ciColor) ~= "table" then
                        ciColor = ccFullColor
                    end
                    longestCCAura = {
                        icon = aura.icon,
                        expirationTime = buff.expirationTime,
                        duration = buff.duration,
                        color = ciColor,
                        spellId = spellId,
                        dispelName = aura.dispelName,
                    }
                end
                buff.pinIcon = true
            end
        end

        if opBarriersOn and opBarriers[spellId] and buff.duration ~= 5 then
            isImportant = nil
            isEnlarged = nil
        end

        if isPlayerUnit then
            buff.isKeyAura = nil
            if isEnlarged then
                if not db.disableEnlargedAurasOnSelf then
                    buff.isEnlarged = true
                else
                    buff.isEnlarged = false
                end
            else
                buff.isEnlarged = false
            end

            if isCompacted then
                if not db.disableEnlargedAurasOnSelf then
                    buff.isCompacted = true
                else
                    buff.isCompacted = false
                end
            else
                buff.isCompacted = false
            end

            if isImportant then
                if db.disableImportantAurasOnSelf then
                    isImportant = false
                end
            end
        else
            if isEnlarged then
                buff.isEnlarged = true
            else
                buff.isEnlarged = false
            end
            if isCompacted then
                buff.isCompacted = true
            else
                buff.isCompacted = false
            end
        end

        if not buff.GlowFrame then
            buff.CountFrame:SetFrameStrata("DIALOG")
            buff.GlowFrame = CreateFrame("Frame", nil, buff)
            buff.GlowFrame:SetFrameStrata("HIGH")
            buff.GlowFrame:SetFrameLevel(9000)
            buff.CountFrame:SetFrameLevel(9999)

            if npAuraStackFontEnabled then
                local npAuraStackFontPath = LSM:Fetch(LSM.MediaType.FONT, BetterBlizzPlatesDB.npAuraStackFont)
                buff.CountFrame.Count:SetFont(npAuraStackFontPath, 12, "OUTLINE")
            end
        end

        local data = trackedAuras[aura.spellId]
        if data then
            if not buff.CooldownSB then
                local cooldownFrame = CreateFrame("Cooldown", nil, buff, "CooldownFrameTemplate")
                cooldownFrame:SetAllPoints(buff.Icon)
                cooldownFrame:SetDrawEdge(false)
                cooldownFrame:SetDrawSwipe(true)
                cooldownFrame:SetReverse(true)
                buff.CooldownSB = cooldownFrame
            end
            buff.CooldownSB:Show()
            buff.CooldownSB:SetCooldown(activeNonDurationAuras[aura.spellId] or 0, data.duration)
        elseif buff.CooldownSB then
            buff.CooldownSB:Hide()
        end


        SetAuraBorderColorByType(buff, aura, db)

        -- Pandemic Glow
        SetPandemicGlow(buff, aura, isPandemic)

        -- temp
        if BBP.sotfWA then
            if BBP.sotfAurasAreActive then
                local unitGUID = UnitGUID(self.unit)
                local germAuraID = BBP.sotfGerm[unitGUID]
                local rejuvAuraID = BBP.sotfRejuv[unitGUID]
                if buff.spellID == germAuraID or buff.spellID == rejuvAuraID then
                    isImportant = true
                else
                    if not germAuraID or not rejuvAuraID then
                        if buff.spellID == 155777 or buff.spellID == 774 then
                            buff.pinIcon = true
                        end
                    end
                end
            else
                if buff.spellID == 155777 or buff.spellID == 774 then
                    buff.pinIcon = true
                end
            end
        end

        SetImportantGlow(buff, isPlayerUnit, isImportant, auraColor)

        -- Purge Glow
        SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)

        if isPlayerUnit then
            if buff.Border then
                buff.Border:Show()
            end
            if buff.buffBorder then
                buff.buffBorder:Hide()
            end
            if buff.BorderEmphasis then
                buff.BorderEmphasis:Hide()
            end
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
        end

        if (aura.applications > 1) then
            buff.CountFrame.Count:SetText(aura.applications);
            buff.CountFrame.Count:Show();
        else
            buff.CountFrame.Count:Hide();
        end
        CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);

        if hideNpAuraSwipe then
            if buff.Cooldown then
                buff.Cooldown:SetDrawSwipe(false)
                buff.Cooldown:SetDrawEdge(false)
            end
        end

        if showDefaultCooldownNumbersOnNpAuras then
            if buff.Cooldown then
                buff.Cooldown:SetHideCountdownNumbers(false)
                local cdText = buff.Cooldown and buff.Cooldown:GetRegions()
                if cdText then
                    cdText:SetScale(BetterBlizzPlatesDB.defaultNpAuraCdSize)
                end
            end
        end

        buff:Show();
        buff:SetMouseClickEnabled(false)

        if not buff.isKeyAura then
            buffIndex = buffIndex + 1;
        end
        return buffIndex >= BUFF_MAX_DISPLAY;
    end);

    if UnitFrame.classIndicatorCC then
        if longestCCAura then
            UnitFrame.pinIconActive = true
            UnitFrame.ccIconTexture = longestCCAura.icon
            UnitFrame.pinBuffColor = longestCCAura.color
            UnitFrame.ccDispelName = longestCCAura.dispelName

            UnitFrame.classIndicatorCC.Glow:SetVertexColor(
                longestCCAura.color.r,
                longestCCAura.color.g,
                longestCCAura.color.b
            )

            local start = longestCCAura.expirationTime - longestCCAura.duration
            UnitFrame.classIndicatorCC.Cooldown:SetCooldown(start, longestCCAura.duration)
            UnitFrame.classIndicatorCC.Icon:SetTexture(longestCCAura.icon)
            UnitFrame.classIndicatorCC:Show()
        else
            UnitFrame.classIndicatorCC:Hide()
            UnitFrame.pinIconActive = nil
            UnitFrame.ccIconTexture = nil
            UnitFrame.pinBuffColor = nil
            UnitFrame.ccDispelName = nil
        end
    end

    self:Layout();
end

function BBP.ParseAllAuras(self, forceAll, UnitFrame)
    if self.auras == nil then
        self.auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
    else
        self.auras:Clear();
    end

    local mirrorImgFrostbolt = false

    local function HandleAura(aura, isTestModeEnabled, interrupt)
        if aura.spellId == 59638 then
            if mirrorImgFrostbolt then
                return false -- Already added one, skip
            end
            mirrorImgFrostbolt = true -- Allow this one, skip others later
        end
        local BlizzardShouldShow = self:ShouldShowBuff(aura, forceAll) and not (BetterBlizzPlatesDB.blizzardDefaultFilterOnlyMine and (aura.sourceUnit ~= "player" and aura.sourceUnit~= "pet"))
        local shouldShowAura, isImportant, isPandemic = ShouldShowBuff(self.unit, aura, BlizzardShouldShow, isTestModeEnabled, interrupt)
        if shouldShowAura then
            self.auras[aura.auraInstanceID] = aura;
        end

        return false;
    end

    local batchCount = nil;
    local usePackedAura = true;
    AuraUtil.ForEachAura(self.unit, "HARMFUL", batchCount, HandleAura, usePackedAura);
    if UnitIsUnit(self.unit, "player") then
        AuraUtil.ForEachAura(self.unit, "HELPFUL|INCLUDE_NAME_PLATE_ONLY", batchCount, HandleAura, usePackedAura);
    else
        AuraUtil.ForEachAura(self.unit, "HELPFUL", batchCount, HandleAura, usePackedAura);
    end

    local destGUID = UnitGUID(self.unit)
    if destGUID and activeInterrupts[destGUID] then
        local interruptData = activeInterrupts[destGUID]
        local currentTime = GetTime()
        if interruptData.expirationTime > currentTime then
            local interruptAura = {
                auraInstanceID = 1,
                spellId = interruptData.spellId,
                icon = interruptData.icon,
                name = interruptData.name,
                duration = interruptData.duration,
                expirationTime = interruptData.expirationTime,
                isHarmful = true,
                applications = 1,
                dispelName = "Physical",
            }
            HandleAura(interruptAura, false, true)
        end
    end

    -- Injecting fake auras for testing
    local isTestModeEnabled = BetterBlizzPlatesDB.nameplateAuraTestMode
    if isTestModeEnabled then
        local currentTime = GetTime()
        for _, fakeAura in ipairs(fakeAuras) do
            fakeAura.expirationTime = currentTime + fakeAura.duration
            HandleAura(fakeAura, isTestModeEnabled)
        end
    end
end

-- Table of classes and their specs that have a nameplate resource
local specsForResource = {
    [62] = true,  -- Arcane Mage
    [259] = true, -- Assassination Rogue
    [260] = true, -- Outlaw Rogue
    [261] = true, -- Subtlety Rogue
    [250] = true, -- Blood DK
    [251] = true, -- Frost DK
    [252] = true, -- Unholy DK
    --[102] = true, -- Balance Druid (has combopoints but not used)
    [105] = true, -- Resto Druid (doubtful but potentially)
    [104] = true, -- Guardian Druid
    [103] = true, -- Feral Druid
    [1467] = true, -- Devoker
    [1468] = true, -- Prevoker
    [269] = true, -- Windwalker Monk
    [65] = true, -- Holy Pala
    [66] = true, -- Prot Pala
    [70] = true, -- Ret Pala
    [265] = true, -- Aff Lock
    [266] = true, -- Demo Lock
    [267] = true, -- Destro Lock
}
-- Function to check if the current player's class spec has a nameplate resource
function BBP.PlayerSpecHasResource()
    local specID, _, _, _, _, _, _ = GetSpecializationInfo(GetSpecialization())
    return specsForResource[specID] or false
end

function BBP:UpdateAnchor()
    local frame = self:GetParent()

    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    local isTarget = frame.unit and UnitIsUnit(frame.unit, "target")
    local isSelf = frame.unit and UnitIsUnit(frame.unit, "player")
    --local reaction = frame.unit and UnitReaction(frame.unit, "player")
    --local isFriend = reaction and reaction >= 5

    local shouldNotOffset = config.nameplateResourceDoNotRaiseAuras or config.nameplateResourceUnderCastbar or not BBP.PlayerSpecHasResource()
    local targetYOffset = self:GetBaseYOffset() + (isTarget and not shouldNotOffset and self:GetTargetYOffset() or 0.0)

    if not config.buffAnchorInitalized or BBP.needsUpdate then
        config.friendlyNameplateNonstackable = BetterBlizzPlatesDB.friendlyNameplateNonstackable
        config.nameplateAurasYPos = BetterBlizzPlatesDB.nameplateAurasYPos
        config.nameplateAurasNoNameYPos = BetterBlizzPlatesDB.nameplateAurasNoNameYPos
        config.nameplateAuraScale = BetterBlizzPlatesDB.nameplateAuraScale
        config.nameplateAuraSelfScale = BetterBlizzPlatesDB.nameplateAuraSelfScale

        config.buffAnchorInitalized = true
    end

    if frame.unit and ShouldShowName(frame) then
        -- if config.friendlyNameplateNonstackable and isFriend then
        --     self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 24.5 + targetYOffset + config.nameplateAurasYPos + 63)
        -- else
            self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 24.5 + targetYOffset + config.nameplateAurasYPos)
        --end
    else
        local additionalYOffset
        if isSelf then
            additionalYOffset = (15 * (isSelf and config.nameplateAuraSelfScale - 1)) + BetterBlizzPlatesDB.nameplateAurasPersonalYPos
        else
            additionalYOffset = 15 * (config.nameplateAuraScale - 1) + config.nameplateAurasNoNameYPos
        end
        self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4 + targetYOffset + 1 + additionalYOffset)
    end
end

function BBP.RefreshBuffFrame()
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
		local unitFrame = namePlate.UnitFrame
		unitFrame.BuffFrame:UpdateAnchor()
		if unitFrame.unit then
			local self = unitFrame.BuffFrame
            BBP.UpdateBuffs(self, unitFrame.unit, nil, {}, unitFrame)
        end
	end
end

function BBP.HideNameplateAuraTooltip()
    if BetterBlizzPlatesDB.hideNameplateAuraTooltip and not BBP.hookedNameplateAuraTooltip then
        hooksecurefunc(NameplateBuffButtonTemplateMixin, "OnEnter", function(self)
            if self:IsForbidden() then return end
            self:EnableMouse(false)
        end)
        BBP.hookedNameplateAuraTooltip = true
    end
end

function BBP.SmokeCheckBootup()
    if not BBP.NoDurationAuraCheck then
        BBP.NoDurationAuraCheck = CreateFrame("Frame")
        BBP.NoDurationAuraCheck:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        BBP.NoDurationAuraCheck:SetScript("OnEvent", TrackAuraAfterCast)
    end
end