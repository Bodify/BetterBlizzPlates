----------------------------------------------------
---- Aura Function Copied From RSPlates and edited by me
----------------------------------------------------

local function FetchSpellName(spellId)
    local spellName, _, _ = GetSpellInfo(spellId)
    return spellName
end

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
        spellId = 1833,
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

local spellsCata = {
    [20549] = true, -- War Stomp
    [28730] = true, -- Arcane Torrent (Mana)
    [25046] = true, -- Arcane Torrent (Energy)
    [50613] = true, -- Arcane Torrent (Runic Power)
    -- Warlock
    [172] = true, -- Corruption
    [87389] = true, -- Corruption (Seed of Corruption version)
    [18223] = true, -- Curse of Exhaustion
    [1490] = true, -- Curse of the Elements
    [702] = true, -- Curse of Exhaustion
    [1714] = true, -- Curse of Tongues
    [980] = true, -- Agony
    [5782] = true, --Fear
    [48181] = true, -- Haunt
    [27243] = true, -- Seed of Corruption
    [47960] = true, -- Shadowflame
    [348] = true, -- Immolate
    [5484] = true, -- Howl of Terror
    [30108] = true, -- Unstable Affliction
    [603] = true, -- Bane of Doom
    [80240] = true, -- Bane of Havoc
    [85421] = true, -- Burning Embers
    [30283] = true, -- Shadowfury
    [24259] = true, -- Spell Lock Silence
    [6358] = true, -- Seduction
    [710] = true, -- Banish
    [6789] = true, -- Death Coil
    [32752] = true, -- Summoning Disorientation
    [19482] = true, -- Doom Guard Stun
    [30153] = true, -- Felguard Stun
    [60995] = true, -- Demon Charge (Metamorphosis)
    [22703] = true, -- Inferno Effect
    [43523] = true, -- Unstable Affliction

    -- Priest
    [87178] = true, -- Mind Spike
    [2944] = true, -- Devouring Plague
    [34914] = true, -- Vampiric Touch
    [15487] = true, -- Silence
    [589] = true, -- Shadow Word: Pain
    [64044] = true, -- Psychic Horror (Horrify)
    [64058] = true, -- Psychic Horror (Disarm)
    [8122] = true, -- Psychic Scream
    [9484] = true, -- Shackle Undead
    [605] = true, -- Mind Control

    --Druid
    [339] = true, -- Entangling Roots
    [33786] = true, -- Cyclone
    [5570] = true, -- Insect Swarm
    [8921] = true, -- Moonfire
    [93402] = true, -- Sunfire
    [91565] = true, -- Faerie Fire
    [50259] = true, -- Dazed (Feral Charge)
    [9007] = true, -- Pounce Bleed
    [1822] = true, -- Rake
    [1079] = true, -- Rip
    [22570] = true, -- Maim
    [5211] = true, -- Bash
    [45334] = true, -- Feral Charge (Bear)
    [33745] = true, -- Lacerate
    [33878] = true, -- Mangle (Bear)
    [33876] = true, -- Mangle (Cat)
    [58180] = true, -- Infected Wounds
    [77758] = true, -- Thrash
    [2637] = true, -- Hibernate
    [9005] = true, -- Pounce Stun

    -- Mage
    [44614] = true, -- Frostfire Bolt
    [120] = true, -- Cone of Cold slow
    [83302] = true, -- Cone of Cold root
    [122] = true, -- Frost Nova
    [116] = true, -- Frostbolt
    [44572] = true, -- Deep Freeze
    [33395] = true, -- Freeze (Pet Nova)
    [11113] = true, -- Blast Wave
    [11366] = true, -- Pyroblast
    [92315] = true, -- Pyroblast!
    [44457] = true, -- Living Bomb
    [22959] = true, -- Critical Mass
    [83853] = true, -- Combustion
    [413841] = true,-- Ignite
    [31661] = true, -- Dragon's Breath
    [55021] = true, -- Counterspell
    [12355] = true, -- Impact
    [118] = true, -- Polymorph
    [28271] = true, -- Polymorph
    [28272] = true, -- Polymorph
    [71319] = true, -- Polymorph
    [61305] = true, -- Polymorph
    [61721] = true, -- Polymorph
    [64346] = true, -- Fiery Payback (Fire Mage Disarm)
    [82691] = true, -- Ring of Frost
    [18469] = true, -- Improved Counterspell

    -- Rogue
    [1776] = true, -- Gouge
    [1943] = true, -- Rupture
    [89775] = true, -- Hemorrhage Glyph Bleed
    [88611] = true, -- Smoke Bomb
    [408] = true, -- Kidney Shot
    [91021] = true, -- Find Weakness
    [1833] = true, -- Cheap Shot
    [703] = true, -- Garrote (Bleed)
    [1330] = true, -- Garrote (Silence)
    [26679] = true, -- Deadly Throw
    [8647] = true, -- Expose Armor
    [6770] = true, -- Sap
    [51722] = true, -- Dismantle
    [18425] = true, -- Improved Kick
    [2094] = true, -- Blind

    -- Hunter
    [82654] = true, -- Widow Venom
    [94528] = true, -- Flare
    [5116] = true, -- Concussive Shot
    [1130] = true, -- Hunter's Mark
    [13797] = true, -- Immolation Trap
    [1978] = true, -- Serpent Sting
    [2974] = true, -- Wing Clip
    [19503] = true, -- Scatter Shot
    [3355] = true, -- Freezing Trap
    [13812] = true, -- Explosive Trap
    [13810] = true, -- Ice Trap
    [1513] = true, -- Scare Beast
    [19386] = true, --Wyvern Sting
    [34490] = true, -- Silencing Shot
    [24394] = true, -- Intimidation

    -- Shaman
    [8050] = true, -- Flame Shock
    [8056] = true, -- Frost Shock
    [8042] = true, -- Earth Shock
    [3600] = true, -- Earth Bind
    [58861] = true, -- Bash (Spirit Wolf)
    [39796] = true, -- Stoneclaw Totem
    [51514] = true,  -- Hex

    -- Warrior
    [94009] = true, -- Rend
    [86346] = true, -- Colossus Smash
    [12721] = true, -- Deep Wounds
    [7922] = true, -- Charge
    [85388] = true, -- Throwdown
    [6343] = true, -- Thunderclap
    [46968] = true,  -- Shockwave
    [18498] = true, -- Improved Shield Bash
    [20253] = true, -- Intercept Stun
    [20615] = true, -- Intercept Stun
    [12809] = true, -- Concussion Blow
    [5246] = true, -- Intimidating Shout
    [20511] = true, -- Intimidation Shout
    [12294] = true, -- Mortal Strike
    [413763] = true, -- Deep Wounds

    -- Paladin
    [853] = true, -- Hammer of Justice
    [31803] = true, -- Censure
    [63529] = true, -- Silenced - Shield of the Templar
    [10326] = true, -- Turn Evil
    [20066] = true, -- Repentance

    -- Death Knight
    [55078] = true, -- Blood Plague
    [50435] = true, -- Chillblains
    [55095] = true, -- Frost Fever
    [73975] = true, -- Necrotic Strike
    [47476] = true, -- Strangulate
    [45524] = true, -- Chains of Ice
    [47481] = true,  -- Gnaw
    [49203] = true, -- Hungering Cold
    -- [7922] = true, -- Charge
    -- [7922] = true, -- Charge+
}

local spellsForAllCata = {
    [20549] = true, -- War Stomp
    [28730] = true, -- Arcane Torrent (Mana)
    [25046] = true, -- Arcane Torrent (Energy)
    [50613] = true, -- Arcane Torrent (Runic Power)
    [47476] = true,  -- Strangulate
    [47481] = true,  -- Gnaw
    [49203] = true, -- Hungering Cold
    [64044] = true, -- Psychic Horror (Horrify)
    [64058] = true, -- Psychic Horror (Disarm)
    [605] = true, -- Mind Control
    [8122] = true, -- Psychic Scream
    [15487] = true, -- Silence
    [9484] = true, -- Shackle Undead
    [60995] = true, -- Demon Charge (Metamorphosis)
    [24259] = true, -- Spell Lock Silence
    [6358] = true, -- Seduction
    [5782] = true, -- Fear
    [5484] = true, -- Howl of Terror
    [710] = true, -- Banish
    [6789] = true, -- Death Coil
    [22703] = true, -- Inferno Effect
    [30283] = true, -- Shadowfury
    [43523] = true, -- Unstable Affliction
    [32752] = true, -- Summoning Disorientation
    [19482] = true, -- Doom Guard Stun
    [30153] = true, -- Felguard Stun
    [51514] = true,  -- Hex
    [58861] = true, -- Bash (Spirit Wolf)
    [39796] = true, -- Stoneclaw Totem
    [63529] = true,
    [853] = true,
    [20066] = true, -- Repentance
    [10326] = true, -- Turn Evil
    [1513] = true, -- Scare Beast
    [3355] = true, -- Freezing Trap
    [19386] = true, --Wyvern Sting
    [19503] = true, -- Scatter Shot
    [34490] = true, -- Silencing Shot
    [24394] = true, -- Intimidation
    [22570] = true, -- Maim
    [2637] = true, -- Hibernate
    [9005] = true, -- Pounce Stun
    [5211] = true, -- Bash
    [33786] = true, -- Cyclone
    [44572] = true, -- Deep Freeze
    [55021] = true, -- Improved Counterspell
    [64346] = true, -- Fiery Payback (Fire Mage Disarm)
    [82691] = true, -- Ring of Frost
    [18469] = true, -- Improved Counterspell
    [118] = true, -- Polymorph
    [28271] = true, -- Polymorph
    [28272] = true, -- Polymorph
    [71319] = true, -- Polymorph
    [61305] = true, -- Polymorph
    [61721] = true, -- Polymorph
    [12355] = true, -- Impact Stun
    [31661] = true, -- Dragon's Breath
    [51722] = true, -- Dismantle
    [18425] = true, -- Improved Kick
    [1833] = true, -- Cheap Shot
    [408] = true, -- Kidney Shot
    [6770] = true, -- Sap
    [2094] = true, -- Blind
    [1776] = true, -- Gouge
    [1330] = true, -- Garrote Silence
    [46968] = true,  -- Shockwave
    [85388] = true, -- Throwdown
    [18498] = true, -- Improved Shield Bash
    [20253] = true, -- Intercept Stun
    [20615] = true, -- Intercept Stun
    [12809] = true, -- Concussion Blow
    [7922] = true, -- Charge Stun
    [5246] = true, -- Intimidating Shout
    [20511] = true, -- Intimidating Shout
}

local spellsMoP = {
    [114404] = true, -- Void Tendril's Grasp
    [15407]  = true, -- Mind Flay
    [149149] = true, -- Holy Fire
    [113792] = true, -- Psyfiend Fear
    [73975]  = true, -- Necrotic Strike
    [5760]   = true, -- Mind-numbing Poison
    [115194] = true, -- Mind Paralysis
    [112947] = true, -- Nerve Strike
    [84617]  = true, -- Revealing Strike
    [91021]  = true, -- Find Weakness
    [113952] = true, -- Paralytic Poison
    [77606]  = true, -- Dark Simulacrum
    [10]     = true, -- Blizzard
    [41425]  = true, -- Hypothermia
    [132210] = true, -- Pyromaniac
    [8056]   = true, -- Frost Shock
    [770]    = true, -- Faerie Fire
    [2812]   = true, -- Denounce
    [25771]  = true, -- Forbearance
    [80240]  = true, -- Havoc
    [114923] = true, -- Nether Tempest
    [603]    = true, -- Doom
    [48181]  = true, -- Haunt
    [116202] = true, -- Aura of the Elements
    [146739] = true, -- Corruption
    [348]    = true, -- Immolate
    [1490]   = true, -- Curse of the Elements
    [689]    = true, -- Drain Life
    [1130]   = true, -- Hunter's Mark
    [115356] = true, -- Stormblast
    [118470] = true, -- Unleashed Fury
    [73683]  = true, -- Unleash Flame
    [17364]  = true, -- Stormstrike
    [117405] = true, -- Binding Shot
    [124280] = true, -- Touch of Karma
    [130320] = true, -- Rising Sun Kick
    [140023] = true, -- Ring of Peace
    [88611]  = true, -- Smoke Bomb
    [118297] = true, -- Immolate
    [134477] = true, -- Threatening Presence
    [17735]  = true, -- Suffering
    [34709]  = true, -- Shadow Sight
    [115625] = true, -- Mortal Cleave
    [54680]  = true, -- Monstrous Bite
    [82654]  = true, -- Widow Venom
    [55078]  = true, -- Blood Plague
    [113344] = true, -- Bloodbath
    [115767] = true, -- Deep Wounds
    [89775]  = true, -- Hemorrhage
    [1943]   = true, -- Rupture
    [703]    = true, -- Garrote
    [2818]   = true, -- Deadly Poison
    [44457]  = true, -- Living Bomb
    [413841] = true, -- Ignite
    [11366]  = true, -- Pyroblast
    [83853]  = true, -- Combustion
    [589]    = true, -- Shadow Word: Pain
    [1822]   = true, -- Rake
    [8050]   = true, -- Flame Shock
    [31803]  = true, -- Censure
    [2944]   = true, -- Devouring Plague
    [14914]  = true, -- Holy Fire
    [129250] = true, -- Power Word: Solace
    [55095]  = true, -- Frost Fever
    [114916] = true, -- Execution Sentence
    [30108]  = true, -- Unstable Affliction
    [104232] = true, -- Rain of Fire
    [980]    = true, -- Agony
    [116858] = true, -- Chaos Bolt
    [118253] = true, -- Serpent Sting
    [3674]   = true, -- Black Arrow
    [53301]  = true, -- Explosive Shot
    [61882]  = true, -- Earthquake
    [9007]   = true, -- Pounce Bleed
    [106830] = true, -- Thrash
    [8921]   = true, -- Moonfire
    [93402]  = true, -- Sunfire
    [1079]   = true, -- Rip
    [33745]  = true, -- Lacerate
    [117952] = true, -- Crackling Jade Lightning
    [128531] = true, -- Blackout Kick
    [112948] = true, -- Frost Bomb
    [113092] = true, -- Frost Bomb
}

local spellsForAllMoP = {
    [113792] = true, -- Psyfiend Fear
    [58861] = true,  -- Bash (Spirit Wolves)
    [1833]  = true,  -- Cheap Shot
    [12809] = true,  -- Concussion Blow
    [60995] = true,  -- Demon Charge
    [47481] = true,  -- Gnaw
    [85388] = true,  -- Throwdown
    [20253] = true,  -- Intercept
    [30153] = true,  -- Pursuit
    [6572]  = true,  -- Ravage
    [46968] = true,  -- Shockwave
    [39796] = true,  -- Stoneclaw Stun
    [20549] = true,  -- War Stomp
    [61025]  = true, -- Polymorph: Serpent
    [76780]  = true, -- Bind Elemental
    [107079] = true, -- Quaking Palm (Racial)
    [123393] = true, -- Glyph of Breath of Fire
    [113801] = true, -- Bash (Treants)
    [56626]  = true, -- Sting (Wasp)
    [50519]  = true, -- Sonic Blast
    [119392] = true, -- Charging Ox Wave
    [122242] = true, -- Clash
    [115752] = true, -- Blinding Light (Glyphed)
    [119072] = true, -- Holy Wrath
    [22703]  = true, -- Inferno Effect
    [107570] = true, -- Storm Bolt
    [113056] = true, -- Intimidating Roar (Symbiosis 2)
    [115268] = true, -- Mesmerize (Shivarra)
    [104045] = true, -- Sleep (Metamorphosis)
    [20511]  = true, -- Intimidating Shout (secondary)
    [96201] = true, -- Web Wrap
    [118895] = true, -- Dragon Roar
    [115001] = true, -- Remorseless Winter
    [122057] = true, -- Clash
    [102795] = true, -- Bear Hug
    [77505] = true, -- Earthquake
    [15618] = true, -- Snap Kick
    [137143] = true, -- Blood Horror

    -- Stun Procs
    [34510] = true,  -- Stun (various procs)
    [12355] = true,  -- Impact
    [23454] = true,  -- Stun

    -- Disorient / Incapacitate / Fear / Charm
    [2094]  = true,  -- Blind
    [5782]  = true,  -- Fear
    [130616] = true, -- Fear (Glyphed)
    [118699] = true, -- Fear (alt ID)
    [49203] = true,  -- Hungering Cold
    [5246]  = true,  -- Intimidating Shout
    [605]   = true,  -- Mind Control
    [28271] = true,  -- Polymorph: Turtle
    [28272] = true,  -- Polymorph: Pig
    [61721] = true,  -- Polymorph: Rabbit
    [61780] = true,  -- Polymorph: Turkey
    [61305] = true,  -- Polymorph: Black Cat
    [6770]  = true,  -- Sap
    [6358]  = true,  -- Seduction
    [9484]  = true,  -- Shackle Undead
    [1090]  = true,  -- Sleep
    [1450679] = true, -- Turn Evil
    [126355] = true, -- Paralyzing Quill
    [126246] = true, -- Lullaby
    [126423] = true, -- Petrifying Gaze (Basilisk pet) -- TODO: verify category
    [25046] = true, -- Arcane Torrent
    [15487] = true, -- Silence (Priest)
    [18498] = true, -- Silenced - Gag Order (Warrior)
    [18469] = true, -- Silenced - Improved Counterspell (Mage)
    [18425] = true, -- Silenced - Improved Kick (Rogue
    [43523] = true, -- Unstable Affliction (Silence effect)
    [50613]  = true, -- Arcane Torrent (Runic Power)
    [28730]  = true, -- Arcane Torrent (Mana)
    [69179]  = true, -- Arcane Torrent (Rage)
    [80483]  = true, -- Arcane Torrent (Focus)
    [31935] = true, -- Avenger's Shield

    [1766]   = true, -- Kick (Rogue)
    [2139]   = true, -- Counterspell (Mage)
    [6552]   = true, -- Pummel (Warrior)
    [19647]  = true, -- Spell Lock (Warlock)
    [47528]  = true, -- Mind Freeze (Death Knight)
    [57994]  = true, -- Wind Shear (Shaman)
    [91802]  = true, -- Shambling Rush (Death Knight)
    -- [96231] = true, -- Rebuke (Paladin) -- intentionally commented out
    [106839] = true, -- Skull Bash (Feral)
    [115781] = true, -- Optical Blast (Warlock)
    [116705] = true, -- Spear Hand Strike (Monk)
    [132409] = true, -- Spell Lock (Warlock)
    [147362] = true, -- Countershot (Hunter)
    [171138] = true, -- Shadow Lock (Warlock)
    [183752] = true, -- Consume Magic (Demon Hunter)
    [187707] = true, -- Muzzle (Hunter)
    [212619] = true, -- Call Felhunter (Warlock)
    [231665] = true, -- Avenger's Shield (Paladin)
    [351338] = true, -- Quell (Evoker)
    [97547]  = true, -- Solar Beam
    [78675] = true, -- Solar Beam
    [81261] = true, -- Solar Beam
    [15752]  = true, -- Disarm
    [14251]  = true, -- Riposte
    [50541]  = true, -- Clench (Scorpid)
    [91644]  = true, -- Snatch (Bird of Prey)
    [118093] = true, -- Disarm (Voidwalker/Voidlord)
    [116844] = true, -- Ring of Peace (Silence / Disarm)
    [19975]  = true, -- Entangling Roots (Nature's Grasp talent)
    [25999]  = true, -- Boar Charge
    [96294]  = true, -- Chains of Ice (Chilblains)
    [113275] = true, -- Entangling Roots (Symbiosis)
    [128405] = true, -- Narrow Escape
    [90327]  = true, -- Lock Jaw (Dog)
    [54706]  = true, -- Venom Web Spray (Silithid)
    [50245]  = true, -- Pin (Crab)
    [116706] = true, -- Disable
    [87194]  = true, -- Glyph of Mind Blast
    [114404] = true, -- Void Tendrils
    [53148] = true, -- Charge
    --[127797] = true, -- Ursol's Vortex
    [81210] = true, -- Net
    [35963]  = true, -- Improved Wing Clip
    [19185]  = true, -- Entrapment
    [23694]  = true, -- Improved Hamstring
    [64695]  = true, -- Earthgrab Totem
}

local activeInterrupts = {}

local interruptSpells = {
    [1766] = 5,  -- Kick (Rogue)
    [2139] = 6,  -- Counterspell (Mage)
    [6552] = 4,  -- Pummel (Warrior)
    [132409] = 6, -- Spell Lock (Warlock)
    [19647] = 6, -- Spell Lock (Warlock, pet)
    [47528] = 4,  -- Mind Freeze (Death Knight)
    [57994] = 3,  -- Wind Shear (Shaman)
    [91807] = 2,  -- Shambling Rush (Death Knight)
    [96231] = 4,  -- Rebuke (Paladin)
    [93985] = 4,  -- Skull Bash (Druid)
    [116705] = 4, -- Spear Hand Strike (Monk)
    [147362] = 3, -- Counter Shot (Hunter)
    [31935] = 3,  -- Avenger's Shield (Paladin)
    [78675] = 5, -- Solar Beam
    [113286] = 5, -- Solar Beam (Symbiosis)
    [26679] = 6, 	-- Deadly Throw (Rogue)

	[33871] = 8, 	-- Shield Bash (Warrior)
	[24259] = 6, 	-- Spell Lock (Warlock)
	[43523] = 5,	-- Unstable Affliction (Warlock)
	--[16979] = 4, 	-- Feral Charge (Druid)
    [119911] = 6, -- Optical Blast (Warlock Observer)
    [115781] = 6, -- Optical Blast (Warlock Observer)
    [102060] = 4, -- Disrupting Shout
    [26090] = 2, -- Pummel (Gorilla)
    [50479] = 2, -- Nethershock
    [97547] = 5, -- Solar Beam
}


-- Buffs that reduce interrupt duration
local spellLockReducer = {
    -- [317920] = 0.7, -- Concentration Aura
    -- [234084] = 0.5, -- Moon and Stars
    -- [383020] = 0.5, -- Tranquil Air
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
                    for i = 1, 40 do
                        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
                        if not name then break end

                        local mult = spellLockReducer[spellId]
                        if mult then
                            duration = duration * mult
                        end
                    end

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
                    for i = 1, 40 do
                        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(frame.unit, i)
                        if not name then break end

                        local mult = spellLockReducer[spellId]
                        if mult then
                            duration = duration * mult
                        end
                    end

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
    [76577] = {r = 1, g = 1, b = 1, a = 1}, -- Smoke Bomb
    [383005] = {r = 0, g = 1, b = 0, a = 1}, -- Chrono Loop (Debuff)
    [34709] = {r = 0.73, g = 0.37, b = 1, a = 1}, -- Shadow Sight (Arena Eye)
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
    
    
    
    --mop
    [137562] = "importantColor", -- Nimble Brew (60% cc reduction, 6sec)
    [19263] = true, --deterrence
    [110788] = true, -- cloak of shadows (symbiosis)
    [124280] = true, -- touch of karma
    --[122470] = "defensiveColor", -- touch of karma
    [31821] = "importantColor", -- devotion aura
    [122465] = "importantColor", -- dematerialize
    [46924] = true, -- Bladestorm
    [76577] = true, -- smoke
    [78675] = true, -- Solar Beam
    [16188]  = true, -- Nature's Swiftness

    [34692]  = true, -- The Beast Within
    [26064]  = true, -- Shell Shield
    [19574]  = true, -- Bestial Wrath
    [3169]   = true, -- Invulnerability
    [20230]  = true, -- Retaliation
    [16621]  = true, -- Self Invulnerability
    [92681]  = true, -- Phase Shift
    [27827]  = true, -- Spirit of Redemption

    -- Anti-CCs
    [5384]   = true, -- Feign Death
    [34471]  = true, -- The Beast Within
    [110575] = true, -- Icebound Fortitude (Druid)
    [110715] = true, -- Dispersion (Symbiosis)

    [122783] = true, -- Diffuse Magic
    [122470] = true, -- Touch of Karma
    [114028] = "importantColor", -- Mass Spell Reflection
    [113002] = "importantColor", -- Spell Reflection (Symbiosis)
    [148467] = true, -- Deterrence
    [115018] = true, -- Desecrated Ground (All CC Immunity)
    [115610] = true, -- Temporal Shield
    [111264] = true, -- Ice Ward (Buff)
    [89485]  = true, -- Inner Focus (instant cast immunity)
    [104773] = true, -- Unending Resolve
    [108271] = true, -- Astral Shift
    [115611] = true, --temporal ripples 15%dmg reduc + 100% heal back 6s.
    [115760] = "importantColor", -- Glyph of Ice Block, spell immunity
    [110909] = true, -- Alter Time



    [3411]   = true, -- Intervene
    [53476]  = true, -- Intervene (Hunter Pet)
    [50461]  = true, -- Anti-Magic Zone
    [114029] = true, -- Safeguard
    [115176] = true, -- Zen Meditation
    [110696] = true, -- Ice Block (Symbiosis)
    [110791] = true, -- Evasion (Symbiosis)
    [110700] = true, -- Divine Shield (Symbiosis)
    [122291] = true, -- Unending Resolve (Symbiosis)
    [122292] = true, -- Intervene (Symbiosis)
    [113862] = true, -- Greater Invisibility (90% dmg reduction)
    [6346]   = true, -- Fear Ward
    [110717] = true, -- Fear Ward (Symbiosis)

    [110617] = true, -- Deterrence (Symbiosis)
    [110570] = "importantColor", -- Anti-Magic Shell (Symbiosis)
    [12043]  = true, -- Presence of Mind
    [111397] = "importantColor", -- Blood Horror (flee on attack)
    [117679] = true, -- Incarnation: Tree of Life
    [51713]  = true, -- Shadow Dance

    [88611] = true, -- Smoke Bomb
    [96268] = true, -- Deaths Advance



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

    -- mop
    [51690] = true, -- killing spree
    [34692]  = true, -- The Beast Within
    [34471]  = true, -- The Beast Within
    [46924] = true, -- Bladestorm
        -- Offensive Buffs
    [12042]  = true, -- Arcane Power
    [34936]  = true, -- Backlash
    [14177]  = true, -- Cold Blood
    [12292]  = true, -- Death Wish
    [16166]  = true, -- Elemental Mastery
    [12051]  = true, -- Evocation
    [18708]  = true, -- Fel Domination
    [29166]  = true, -- Innervate
    [47241]  = true, -- Metamorphasis
    [17941]  = true, -- Shadow Trance
    [12043]  = true, -- Presence of Mind
    [3045]   = true, -- Rapid Fire
    [51713]  = true, -- Shadow Dance
    [83853] = true, -- Combustion
    [105809] = true, -- Holy Avenger
    [86698] = true, -- Guardian of Ancient Kings (alt)
    [113858] = true, -- Dark Soul: Instability
    [113860] = true, -- Dark Soul: Misery
    [113861] = true, -- Dark Soul: Knowledge
    [124974] = true, -- Nature’s Vigil
    [49206] = true, -- Summon Gargoyle
    [114868] = true, -- Soul Reaper (Buff)
    --[12328]  = 2, -- Sweeping Strikes
    --[113656] = 0.5, -- Fists of Fury
    [77616] = true, -- Dark Simulacrum (Buff, has spell)
    [84747] = true, -- Deep insight (red buff)
    [481089] = true, -- Instant Pyro
    [131078] = true, -- Icy Veins (split)
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
    --[48265] = true, (Unholy Presence in MoP)
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

    --mop
    [96268] = true, -- Deaths Advance
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
    [113862] = true, -- 90% dmg reduciton mop invis
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
    [114028] = true,


    --mop
    [137562] = true, -- Nimble Brew (60% cc reduction, 6sec)
    [19263] = true, --deterrence
    [110788] = true, -- cloak of shadows (symbiosis)
    --[46947] = true, -- Safeguard, 20%, ignore due to other more important Safeguard buff with same icon

    -- mop
    [115611] = true, --temporal ripples 15%dmg reduc + 100% heal back 6s.
    [112833] = true, --spectral guise stealth
    [86669] = true, --guardian of ancient kings 
    [122465] = importantColor, -- Dematerialize


    [26064]  = true, -- Shell Shield
    [3169]   = true, -- Invulnerability
    [20230]  = true, -- Retaliation
    [16621]  = true, -- Self Invulnerability
    [92681]  = true, -- Phase Shift
    [20594]  = true, -- Stoneform
    [27827]  = true, -- Spirit of Redemption
    [5384]   = true, -- Feign Death
    [110575] = true, -- Icebound Fortitude (Duid)
    [110715] = true, -- Dispersion (Symbiosis)
    [126456] = true, -- Fortifying Brew (Symbiosis)
    [124280] = true, -- Touch of Karma
    [3411]   = true, -- Intervene
    [53476]  = true, -- Intervene (Hunter Pet)
    [47000]  = true, -- Improved Blink
    [30823]  = true, -- Shamanistic Rage
    [55694]  = true, -- Enraged Regeneration
    [31842]  = true, -- Divine Favor
    [31821]  = true, -- Aura Mastery
    [1044]   = true, -- Hand of Freedom
    [16188]  = true, -- Nature's Swiftness
    [50461]  = true, -- Anti-Magic Zone
    [47484]  = true, -- Huddle

    [89485]  = true, -- Inner Focus (instant cast immunity)
    [114029] = true, -- Safeguard
    [1966]  = true, -- Feint
    [108359] = true, -- Dark Regeneration
    [111397] = true, -- Blood Horror (flee on attack)
    [110913] = true, -- Dark Bargain
    [108281] = true, -- Ancestral Guidance (healing)
    [31616] = true, -- Nature’s Guardian
    [114052] = true, -- Ascendance (Restoration)
    [106922] = true, -- Might of Ursoc
    [115176] = true, -- Zen Meditation
    [109964] = true, -- Spirit Shell (Buff)
    [115610] = true, -- Temporal Shield
    [148467] = true, -- Deterrence
    [115018] = importantColor, -- Desecrated Ground (All CC Immunity)
    [111264] = true, -- Ice Ward (Buff)
    [110960] = true,
    [110909] = true, -- Alter
    [110700] = true, -- Divine Shield (Symbiosis)
    [122291] = true, -- Unending Resolve (Symbiosis)
    [122292] = true, -- Intervene (Symbiosis)
    [113002] = true, -- Spell Reflection (Symbiosis)
    [6346]   = true, -- Fear Ward
    [110717] = true, -- Fear Ward (Symbiosis)
    [115760] = importantColor, -- Ice Block Glyph
    [110617] = true, -- Deterrence (Symbiosis)
    [110696] = true, -- Ice Block (Symbiosis)
    [110570] = true, -- Anti-Magic Shell (Symbiosis)
    [122470] = true, -- Touch of Karma
    [110791] = true, -- Evasion (Symbiosis)


}

local enlargeAllCCsFilter
local enlargeAllImportantBuffsFilter


local crowdControl = {}
local ccFull = {
    [2637]   = true,
    [3355]   = true,
    [19386]  = true,
    [118]    = true,
    [28271]  = true,
    [28272]  = true,
    [61025]  = true,
    [61721]  = true,
    [61780]  = true,
    [61305]  = true,
    [82691]  = true,
    [115078] = true,
    [20066]  = true,
    [9484]   = true,
    [1776]   = true,
    [6770]   = true,
    [76780]  = true,
    [51514]  = true,
    [710]    = true,
    [107079] = true,
    --[99]     = true,
    [19503]  = true,
    [31661]  = true,
    [123393] = true,
    [88625]  = true,
    [108194] = true,
    [91800]  = true,
    [91797]  = true,
    [115001] = true,
    [102795] = true,
    [5211]   = true,
    [9005]   = true,
    [22570]  = true,
    [113801] = true,
    [117526] = true,
    [24394]  = true,
    [126246] = true,
    [126423] = true,
    [126355] = true,
    [90337]  = true,
    [56626]  = true,
    [50519]  = true,
    [118271] = true,
    [44572]  = true,
    [119392] = true,
    [122242] = true,
    [120086] = true,
    [119381] = true,
    [115752] = true,
    [853]    = true,
    [110698] = true,
    [119072] = true,
    [105593] = true,
    [408]    = true,
    [1833]   = true,
    [118345] = true,
    [118905] = true,
    [89766]  = true,
    [22703]  = true,
    [30283]  = true,
    [132168] = true,
    [107570] = true,
    [20549]  = true,
    [113953] = true,
    [118895] = true,
    [77505]  = true,
    [100]    = true,
    [118000] = true,
    [113004] = true,
    [113056] = true,
    [1513]   = true,
    [10326]  = true,
    [145067] = true,
    [8122]   = true,
    [113792] = true,
    [2094]   = true,
    [5782]   = true,
    [118699] = true,
    [5484]   = true,
    [115268] = true,
    [6358]   = true,
    [104045] = true,
    [5246]   = true,
    [20511]  = true,
    [64044]  = true,
    [137143] = true,
    [6789]   = true,
    [605]    = true,
    [13181]  = true,
    [67799]  = true,
    [33786]  = true,
    [113506] = true,
    [105421] = true,


    [58861] = true,  -- Bash (Spirit Wolves)
    [7922]  = true,  -- Charge Stun
    [12809] = true,  -- Concussion Blow
    [60995] = true,  -- Demon Charge
    [47481] = true,  -- Gnaw
    [85388] = true,  -- Throwdown
    [20253] = true,  -- Intercept
    [30153] = true,  -- Pursuit
    [64058] = true,  -- Psychic Horror
    [6572]  = true,  -- Ravage
    [46968] = true,  -- Shockwave
    [39796] = true,  -- Stoneclaw Stun
    [34510] = true,  -- Stun (various procs)
    [12355] = true,  -- Impact
    [23454] = true,  -- Stun
    [49203] = true,  -- Hungering Cold
    [1090]  = true,  -- Sleep
    [132169] = true, -- Storm Bolt
    [1450679] = true, -- Turn Evil
    [93433] = true, -- Burrow Attack (Worm)
    [83046] = true, -- Improved Polymorph (Rank 1)
    [83047] = true, -- Improved Polymorph (Rank 2)
    --[2812]  = true, -- Holy Wrath
    --[88625] = "Stunned", -- Holy Word: Chastise
    [93986] = true, -- Aura of Foreboding
    [54786] = true, -- Demon Leap
    [85387] = true, -- Aftermath
    [15283] = true, -- Stunning Blow (Weapon Proc)
    [56]    = true, -- Stun (Weapon Proc)
    [5134]  = true, -- Flash Bomb Fear (Item)
    [130616] = true, -- Fear (Glyphed)

    -- Stuns
    [96201] = true, -- Web Wrap
    [122057] = true, -- Clash
    [15618] = true, -- Snap Kick
    [127361] = true, -- Bear Hug
    [32752] = true, -- Summoning Disorientation (Pet)
    [102546]  = true, -- Pounce
}
local ccDisarm = {
    [50541]  = true,
    [91644]  = true,
    [117368] = true,
    [126458] = true,
    [137461] = true,
    [64058]  = true,
    [51722]  = true,
    [118093] = true,
    [676]    = true,
    [15752]  = true, -- Disarm
    [14251]  = true, -- Riposte
    [142896] = true, -- Disarmed
    [116844] = true, -- Ring of Peace (Silence / Disarm)
}
local ccRoot = {
    [96294]  = true,
    [339]    = true,
    [113275] = true,
    [102359] = true,
    [19975]  = true,
    [128405] = true,
    [90327]  = true,
    [54706]  = true,
    [50245]  = true,
    [4167]   = true,
    [33395]  = true,
    [122]    = true,
    [110693] = true,
    [116706] = true,
    [87194]  = true,
    [114404] = true,
    [115197] = true,
    [63685]  = true,
    [107566] = true,
    [64803]  = true,
    [111340] = true,
    [123407] = true,
    [64695]  = true,
    -- mop
    [115757] = true,
    [25999]  = true, -- Boar Charge
    [19306]  = true, -- Counterattack
    [35963]  = true, -- Improved Wing Clip
    [19185]  = true, -- Entrapment
    [23694]  = true, -- Improved Hamstring
    [91807] = true,   -- Shambling Rush

    [113770] = true, -- Entangling Roots (?)
    [105771] = true, -- Warbringer
    [96293] = true, -- Chains of Ice (Chilblains Rank 1)
    [87193] = true, -- Paralysis
    [47168] = true, -- Improved Wing Clip
    [83301] = true, -- Improved Cone of Cold (Rank 1)
    [83302] = true, -- Improved Cone of Cold (Rank 2)
    [55080] = true, -- Shattered Barrier (Rank 1)
    [83073] = true, -- Shattered Barrier (Rank 2)
    [50479] = true, -- Nether Shock (Nether Ray)
    [86759] = true, -- Silenced - Improved Kick (Rank 2)
    [53148] = true, -- Charge
    [136634] = true, -- Narrow Escape
    --[127797] = true, -- Ursol's Vortex
    [81210] = true, -- Net
    [135373] = true, -- Entrapment
    [45334]  = true, -- Immobilized
}
local ccSilence = {
    [47476]  = true,
    [114238] = true,
    [34490]  = true,
    [102051] = true,
    [55021]  = true,
    [137460] = true,
    [116709] = true,
    [31935]  = true,
    [15487]  = true,
    [1330]   = true,
    [24259]  = true,
    [115782] = true,
    [18498]  = true,
    [50613]  = true,
    [28730]  = true,
    [25046]  = true,
    [69179]  = true,
    [80483]  = true,
    [18469] = true, -- Silenced - Improved Counterspell (Mage)
    [18425] = true, -- Silenced - Improved Kick (Rogue)
    [43523] = true, -- Unstable Affliction (Silence effect)
    [97547]  = true,
    [113286] = true,
    [78675] = true,
    [81261] = true,
    [142895] = true,

    [1766]   = true, -- Kick (Rogue)
    [2139]   = true, -- Counterspell (Mage)
    [6552]   = true, -- Pummel (Warrior)
    [19647]  = true, -- Spell Lock (Warlock)
    [47528]  = true, -- Mind Freeze (Death Knight)
    [57994]  = true, -- Wind Shear (Shaman)
    [91802]  = true, -- Shambling Rush (Death Knight)
    -- [96231] = 6, -- Rebuke (Paladin) -- intentionally commented out
    [106839] = true, -- Skull Bash (Feral)
    [115781] = true, -- Optical Blast (Warlock)
    [116705] = true, -- Spear Hand Strike (Monk)
    [132409] = true, -- Spell Lock (Warlock)
    [147362] = true, -- Countershot (Hunter)
    [171138] = true, -- Shadow Lock (Warlock)
    [183752] = true, -- Consume Magic (Demon Hunter)
    [187707] = true, -- Muzzle (Hunter)
    [212619] = true, -- Call Felhunter (Warlock)
    [231665] = true, -- Avenger's Shield (Paladin)
    [351338] = true, -- Quell (Evoker)
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

    if BBP.isTBC then
        ccFull[6798]    = true    -- Bash
        ccFull[8983]    = true    -- Bash
        ccFull[17925]   = true    -- Death Coil
        ccFull[17926]   = true    -- Death Coil
        ccFull[27223]   = true    -- Death Coil
        ccFull[5588]    = true    -- Hammer of Justice
        ccFull[5589]    = true    -- Hammer of Justice
        ccFull[10308]   = true    -- Hammer of Justice
        ccFull[19577]   = true    -- Intimidation
        ccFull[8643]    = true    -- Kidney Shot
        ccFull[9823]    = true    -- Pounce
        ccFull[9827]    = true    -- Pounce
        ccFull[27006]   = true    -- Pounce
        ccFull[30413]   = true    -- Shadowfury
        ccFull[30414]   = true    -- Shadowfury
        ccFull[99]      = true    -- Disorienting Roar
        ccFull[87204]   = true    -- Sin and Punishment
        ccFull[20614]   = true    -- Intercept Stun (Rank 2)
        ccFull[20615]   = true    -- Intercept Stun (Rank 3)
        ccFull[25273]   = true    -- Intercept Stun (Rank 4)
        ccFull[13237]   = true    -- Goblin Mortar (Item)
        ccFull[835]     = true    -- Tidal Charm (Item)
        ccFull[5530]    = true    -- Mace Stun Effect
        ccFull[15269]   = true    -- Blackout Stun
        ccFull[16922]   = true    -- Imp Starfire Stun
        ccFull[11103]   = true    -- Impact
        ccFull[12357]   = true    -- Impact
        ccFull[12358]   = true    -- Impact
        ccFull[12359]   = true    -- Impact
        ccFull[12360]   = true    -- Impact
        ccFull[19410]   = true    -- Improved Concussive Shot
        ccFull[20170]   = true    -- Seal of Justice Stun
        ccFull[18093]   = true    -- Pyroclasm
        ccFull[12798]   = true    -- Revenge Stun
        ccFull[33041]   = true    -- Dragon's Breath
        ccFull[33042]   = true    -- Dragon's Breath
        ccFull[33043]   = true    -- Dragon's Breath
        ccFull[6213]    = true    -- Fear
        ccFull[6215]    = true    -- Fear
        ccFull[14309]   = true    -- Freezing Trap Effect
        ccFull[1777]    = true    -- Gouge
        ccFull[8629]    = true    -- Gouge
        ccFull[11285]   = true    -- Gouge
        ccFull[11286]   = true    -- Gouge
        ccFull[38764]   = true    -- Gouge
        ccFull[18657]   = true    -- Hibernate
        ccFull[18658]   = true    -- Hibernate
        ccFull[17928]   = true    -- Howl of Terror
        ccFull[25274]   = true    -- Intercept Stun
        ccFull[10911]   = true    -- Mind Control
        ccFull[10912]   = true    -- Mind Control
        ccFull[12824]   = true    -- Polymorph
        ccFull[12825]   = true    -- Polymorph
        ccFull[12826]   = true    -- Polymorph
        ccFull[8124]    = true    -- Psychic Scream
        ccFull[10888]   = true    -- Psychic Scream
        ccFull[10890]   = true    -- Psychic Scream
        ccFull[2070]    = true    -- Sap
        ccFull[11297]   = true    -- Sap
        ccFull[14326]   = true    -- Scare Beast
        ccFull[14327]   = true    -- Scare Beast
        ccFull[20407]   = true    -- Seduction
        ccFull[30850]   = true    -- Seduction
        ccFull[24132]   = true    -- Wyvern Sting
        ccFull[24133]   = true    -- Wyvern Sting
        ccFull[27068]   = true    -- Wyvern Sting
        ccFull[18647]   = true    -- Banish

        ccDisarm[676]     = true    -- Disarm
        ccDisarm[15752]   = true    -- Disarm
        ccDisarm[14251]   = true    -- Riposte
        ccDisarm[34097]   = true    -- Riposte 2 (TODO: not sure which ID is correct)
        ccDisarm[51722]   = true    -- Dismantle
        ccDisarm[50541]   = true    -- Clench (Scorpid)
        ccDisarm[91644]   = true    -- Snatch (Bird of Prey)
        ccDisarm[117368]  = true    -- Grapple Weapon
        ccDisarm[126458]  = true    -- Grapple Weapon (Symbiosis)
        ccDisarm[137461]  = true    -- Ring of Peace (Disarm)
        ccDisarm[118093]  = true    -- Disarm (Voidwalker/Voidlord)
        ccDisarm[142896]  = true    -- Disarmed
        ccDisarm[116844]  = true    -- Ring of Peace (Silence / Disarm)

        ccSilence[25046]   = true    -- Arcane Torrent
        ccSilence[1330]    = true    -- Garrote
        ccSilence[15487]   = true    -- Silence (Priest)
        ccSilence[18498]   = true    -- Silenced - Gag Order (Warrior)
        ccSilence[18469]   = true    -- Silenced - Improved Counterspell (Mage)
        ccSilence[55021]   = true    -- Silenced - Improved Counterspell (Mage alt)
        ccSilence[18425]   = true    -- Silenced - Improved Kick (Rogue)
        ccSilence[34490]   = true    -- Silencing Shot (Hunter)
        ccSilence[19244]   = true    -- Spell Lock (Felhunter)
        ccSilence[31117]   = true    -- UA silence (on dispel)
        ccSilence[24259]   = true    -- Spell Lock (Felhunter)
        ccSilence[47476]   = true    -- Strangulate (Death Knight)
        ccSilence[43523]   = true    -- Unstable Affliction (Silence effect)
        ccSilence[114238]  = true    -- Glyph of Fae Silence
        ccSilence[102051]  = true    -- Frostjaw
        ccSilence[137460]  = true    -- Ring of Peace (Silence)
        ccSilence[115782]  = true    -- Optical Blast (Observer)
        ccSilence[50613]   = true    -- Arcane Torrent (Runic Power)
        ccSilence[28730]   = true    -- Arcane Torrent (Mana)
        ccSilence[69179]   = true    -- Arcane Torrent (Rage)
        ccSilence[80483]   = true    -- Arcane Torrent (Focus)
        ccSilence[31935]   = true    -- Avenger's Shield
        ccSilence[116709]  = true    -- Spear Hand Strike
        ccSilence[142895]  = true    -- Silence (Ring of Peace?)
        ccSilence[1766]    = true    -- Kick (Rogue)
        ccSilence[2139]    = true    -- Counterspell (Mage)
        ccSilence[6552]    = true    -- Pummel (Warrior)
        ccSilence[19647]   = true    -- Spell Lock (Warlock)
        ccSilence[47528]   = true    -- Mind Freeze (Death Knight)
        ccSilence[57994]   = true    -- Wind Shear (Shaman)
        ccSilence[91802]   = true    -- Shambling Rush (Death Knight)
        ccSilence[106839]  = true    -- Skull Bash (Feral)
        ccSilence[115781]  = true    -- Optical Blast (Warlock)
        ccSilence[116705]  = true    -- Spear Hand Strike (Monk)
        ccSilence[132409]  = true    -- Spell Lock (Warlock)
        ccSilence[147362]  = true    -- Countershot (Hunter)
        ccSilence[97547]   = true    -- Solar Beam
        ccSilence[113286]  = true    -- Solar Beam
        ccSilence[78675]   = true    -- Solar Beam
        ccSilence[81261]   = true    -- Solar Beam

        ccRoot[44041]   = true      -- Chastise (Root)
        ccRoot[44043]   = true      -- Chastise (Root)
        ccRoot[44044]   = true      -- Chastise (Root)
        ccRoot[44045]   = true      -- Chastise (Root)
        ccRoot[44046]   = true      -- Chastise (Root)
        ccRoot[44047]   = true      -- Chastise (Root)
        ccRoot[339]     = true      -- Entangling Roots
        ccRoot[1062]    = true      -- Entangling Roots
        ccRoot[5195]    = true      -- Entangling Roots
        ccRoot[5196]    = true      -- Entangling Roots
        ccRoot[9852]    = true      -- Entangling Roots
        ccRoot[9853]    = true      -- Entangling Roots
        ccRoot[26989]   = true      -- Entangling Roots
        ccRoot[19970]   = true      -- Entangling Roots (Nature's Grasp)
        ccRoot[19971]   = true      -- Entangling Roots (Nature's Grasp)
        ccRoot[19972]   = true      -- Entangling Roots (Nature's Grasp)
        ccRoot[19973]   = true      -- Entangling Roots (Nature's Grasp)
        ccRoot[19974]   = true      -- Entangling Roots (Nature's Grasp)
        ccRoot[19975]   = true      -- Entangling Roots (Nature's Grasp talent)
        ccRoot[27010]   = true      -- Nature's Grasp
        ccRoot[25999]   = true      -- Boar Charge
        ccRoot[4167]    = true      -- Web
        ccRoot[122]     = true      -- Frost Nova
        ccRoot[865]     = true      -- Frost Nova
        ccRoot[6131]    = true      -- Frost Nova
        ccRoot[10230]   = true      -- Frost Nova
        ccRoot[27088]   = true      -- Frost Nova
        ccRoot[33395]   = true      -- Freeze (Water Elemental)
        ccRoot[96294]   = true      -- Chains of Ice (Chilblains)
        ccRoot[113275]  = true      -- Entangling Roots (Symbiosis)
        ccRoot[113770]  = true      -- Entangling Roots (Treant)
        ccRoot[102359]  = true      -- Mass Entanglement
        ccRoot[128405]  = true      -- Narrow Escape
        ccRoot[90327]   = true      -- Lock Jaw (Dog)
        ccRoot[54706]   = true      -- Venom Web Spray (Silithid)
        ccRoot[50245]   = true      -- Pin (Crab)
        ccRoot[110693]  = true      -- Frost Nova (Symbiosis)
        ccRoot[116706]  = true      -- Disable
        ccRoot[87194]   = true      -- Glyph of Mind Blast
        ccRoot[114404]  = true      -- Void Tendrils
        ccRoot[115197]  = true      -- Partial Paralysis
        ccRoot[63685]   = true      -- Freeze (Frost Shock)
        ccRoot[107566]  = true      -- Staggering Shout
        ccRoot[115757]  = true      -- Frost nova
        ccRoot[105771]  = true      -- Warbringer
        ccRoot[53148]   = true      -- Charge
        ccRoot[136634]  = true      -- Narrow Escape
        ccRoot[81210]   = true      -- Net
        ccRoot[35963]   = true      -- Improved Wing Clip
        ccRoot[19185]   = true      -- Entrapment
        ccRoot[16979]   = true      -- Feral Charge
        ccRoot[23694]   = true      -- Improved Hamstring
        ccRoot[13120]   = true      -- Net-o-Matic
        ccRoot[64803]   = true      -- Entrapment
        ccRoot[111340]  = true      -- Ice Ward
        ccRoot[123407]  = true      -- Spinning Fire Blossom
        ccRoot[64695]   = true      -- Earthgrab Totem
        ccRoot[91807]   = true      -- Shambling Rush
        ccRoot[135373]  = true      -- Entrapment
        ccRoot[45334]   = true      -- Immobilized
        ccRoot[19306]   = true      -- Counterattack (Rank 1)
        ccRoot[20909]   = true      -- Counterattack (Rank 2)
        ccRoot[20910]   = true      -- Counterattack (Rank 3)
        ccRoot[27067]   = true      -- Counterattack (Rank 4)
        ccRoot[19229]   = true      -- Improved Wing Clip
        ccRoot[12494]   = true      -- Frostbite

        ogKeyAuraList[23920]   = "importantColor"     -- Spell Reflection
        ogKeyAuraList[19263]   = "defensiveColor"       -- Deterrence
        ogKeyAuraList[642]     = "defensiveColor"       -- Divine Shield
        ogKeyAuraList[1020]    = "defensiveColor"       -- Divine Shield
        ogKeyAuraList[498]     = "defensiveColor"       -- Divine Protection
        ogKeyAuraList[45438]   = "defensiveColor"       -- Ice Block
        ogKeyAuraList[5599]    = "defensiveColor"       -- Blessing of Protection
        ogKeyAuraList[10278]   = "defensiveColor"       -- Blessing of Protection
        ogKeyAuraList[3169]    = true       -- Invulnerability
        ogKeyAuraList[16621]   = true       -- Self Invulnerability
        ogKeyAuraList[31224]   = "defensiveColor"       -- Cloak of Shadows
        ogKeyAuraList[27827]   = true       -- Spirit of Redemption
        ogKeyAuraList[148467]  = "defensiveColor"       -- Deterrence
        ogKeyAuraList[5384]    = true     -- Feign Death
        ogKeyAuraList[45182]   = "defensiveColor"     -- Cheating Death (85% reduced inc dmg)
        ogKeyAuraList[31821]   = nil     -- Aura Mastery --40yards on tbc
        ogKeyAuraList[3411]    = "importantColor"     -- Intervene
        ogKeyAuraList[5277]    = "defensiveColor"       -- Evasion
        ogKeyAuraList[26669]   = "defensiveColor"       -- Evasion
        ogKeyAuraList[1044]    = true       -- Hand of Freedom
        ogKeyAuraList[6346]    = "importantColor"      -- Fear Ward
        ogKeyAuraList[7744]    = true      -- Will of the Forsaken

        importantOffensives[12043]   = true    -- Presence of Mind
        importantOffensives[13750]   = true       -- Adrenaline Rush
        importantOffensives[12042]   = true       -- Arcane Power
        importantOffensives[31884]   = true       -- Avenging Wrath
        importantOffensives[34936]   = true       -- Backlash
        importantOffensives[2825]    = true       -- Bloodlust
        importantOffensives[12292]   = true       -- Death Wish
        importantOffensives[16166]   = true       -- Elemental Mastery
        importantOffensives[12051]   = true       -- Evocation
        importantOffensives[12472]   = true       -- Icy Veins
        importantOffensives[32182]   = true       -- Heroism
        importantOffensives[10060]   = true       -- Power Infusion
        importantOffensives[3045]    = true       -- Rapid Fire
        importantOffensives[1719]    = true       -- Recklessness
        importantOffensives[12328]   = true       -- Sweeping Strikes
        importantOffensives[31641]   = true       -- Blazing Speed
        importantOffensives[31642]   = true       -- Blazing Speed
        importantOffensives[31643]   = true       -- Blazing Speed
        importantOffensives[14177] = true       -- Cold Blood

        importantMobility[2983]    = true      -- Sprint
        importantMobility[8696]    = true      -- Sprint
        importantMobility[11305]   = true      -- Sprint
        importantMobility[1044]    = true       -- Hand of Freedom

        importantDefensives[20230]   = true    -- Retaliation
        importantDefensives[16188]   = true    -- Nature's Swiftness
        importantDefensives[20600]   = true    -- Perception
        importantDefensives[17116]   = true    -- Nature's Swiftness (Shaman)
        importantDefensives[31842]   = true    -- Divine Favor
        importantDefensives[1022]    = true    -- Hand of Protection
        importantDefensives[34692]   = true    -- The Beast Within
        importantDefensives[19574]   = true    -- Bestial Wrath
        importantDefensives[26064]   = true    -- Shell Shield
        importantDefensives[6940]    = true    -- Hand of Sacrifice
        importantDefensives[20729]   = true    -- Blessing of Sacrifice
        importantDefensives[27147]   = true    -- Blessing of Sacrifice
        importantDefensives[27148]   = true    -- Blessing of Sacrifice
        importantDefensives[34471]   = true    -- The Beast Within
        importantDefensives[871]     = true    -- Shield Wall
        importantDefensives[33206]   = true    -- Pain Suppresion
        importantDefensives[30823]   = true    -- Shamanistic Rage
        importantDefensives[30824]   = true    -- Shamanistic Rage
        importantDefensives[18499]   = true    -- Berserker Rage
        importantDefensives[22812]   = true    -- Barkskin
        importantDefensives[31616]   = true    -- Nature’s Guardian
        importantDefensives[12976]   = true    -- Last Stand
        importantDefensives[29166]   = true    -- Innervate
        importantDefensives[30458]   = true    -- Nigh Invulnerability Shield
        importantDefensives[19263]   = true       -- Deterrence
        importantDefensives[642]     = true       -- Divine Shield
        importantDefensives[1020]    = true       -- Divine Shield
        importantDefensives[498]     = true       -- Divine Protection
        importantDefensives[45438]   = true       -- Ice Block
        importantDefensives[5599]    = true       -- Blessing of Protection
        importantDefensives[10278]   = true       -- Blessing of Protection
        importantDefensives[3169]    = true       -- Invulnerability
        importantDefensives[16621]   = true       -- Self Invulnerability
        importantDefensives[31224]   = true       -- Cloak of Shadows
        importantDefensives[27827]   = true       -- Spirit of Redemption
        importantDefensives[31821]   = nil     -- Aura Mastery
        importantDefensives[3411]    = true     -- Intervene
        importantDefensives[23920]   = true     -- Spell Reflection
        importantDefensives[5384]    = true     -- Feign Death
        importantDefensives[45182]   = true     -- Cheating Death (85% reduced inc dmg)
        importantDefensives[5277]    = true       -- Evasion
        importantDefensives[26669]   = true       -- Evasion
        importantDefensives[6346]    = true      -- Fear Ward
        importantDefensives[7744]    = true      -- Will of the Forsaken
        importantDefensives[20216] = true -- Divine Favor
        importantDefensives[18708] = true      -- Fel Domination
        importantDefensives[34709]  = true     -- Shadow Sight (Arena Eye)(Debuff)
        importantDefensives[46989] = true     -- Improved Blink (25% chance to miss attacks and spells, 4sec buff)
        importantDefensives[15286] = nil -- Vamp Embrace is debuff in tbc

    elseif not BBP.isMoP then
        ccFull[2812] = true
    else
        ccFull[99] = true -- Disorienting Roar (MoP only, 30sec debuff in cata)
    end

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

    [76577] = 88611, -- Smoke Bomb
    [115018] = 115018, -- Desecrated Ground
    [51052] = 145629, -- Anti-Magic Zone
    [78675] = 81261, -- Solar Beam
    [113286] = 113286, -- Solar Beam (Symbiosis)
}

local trackedAuras = {
    [212183] = {duration = 5, helpful = false, texture = 458733},  -- Smoke Bomb
    [201633] = {duration = 18, helpful = true, texture = 136098},  -- Earthen Wall
    [81782]  = {duration = 10, helpful = true, texture = 253400},  -- Barrier
    [8178]   = {duration = 3,  helpful = true, texture = 136039},  -- Grounding
    [456499] = {duration = 4, helpful = true, texture = 988197}, -- Absolute Serenity
    [289655] = {duration = 5, helpful = true, texture = 237544}, -- Sanctified Ground

    [76577] = {duration = 5, helpful = false, texture = 458733},  -- Smoke Bomb
    [88611] = {duration = 5, helpful = false, texture = 458733},  -- Smoke Bomb
    [115018] = {duration = 10, helpful = true, texture = 538768},  -- Desecrated Ground
    [145629] = {duration = 3, helpful = true, texture = 237510},  -- Anti-Magic Zone
    [81261] = {duration = 8, helpful = false, texture = 252188},  -- Solar Beam
    [113286] = {duration = 8, helpful = false, texture = 252188},  -- Solar Beam
}


local activeNonDurationAuras = {}
BBP.ActiveAuraCheck = CreateFrame("Frame")

-- Stance auras for TBC (stances don't have real auras, only cast/aura events)
local stanceAuras = {
    [71]   = true, -- Defensive Stance
    [2458] = true, -- Berserker Stance
    [2457] = true, -- Battle Stance
}

-- Active stance auras per GUID: [GUID] = spellID (e.g. ["Player-xxx"] = 71)
local activeStanceAuras = {}


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
            local _, _, _, _, _, _, _, _, _, spellID = UnitAura(frame.unit, i, auraType)
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
    local _, subEvent, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if subEvent ~= "SPELL_CAST_SUCCESS" then return end
    if stanceAuras[spellID] and sourceGUID then
        activeStanceAuras[sourceGUID] = spellID

        C_Timer.After(0.1, function()
            for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
                local frame = nameplate.UnitFrame
                if frame and frame.unit and UnitGUID(frame.unit) == sourceGUID then
                    BBP.UpdateBuffs(frame.BuffFrame, frame.unit, nil, {helpful = true}, frame)
                    break
                end
            end
        end)
        return
    end
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

function BBP.SmokeCheckBootup()
    if not BBP.NoDurationAuraCheck then
        BBP.NoDurationAuraCheck = CreateFrame("Frame")
        BBP.NoDurationAuraCheck:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        BBP.NoDurationAuraCheck:SetScript("OnEvent", TrackAuraAfterCast)
    end

    if BBP.isTBC and not BBP.StanceAuraWiper then
        BBP.StanceAuraWiper = CreateFrame("Frame")
        BBP.StanceAuraWiper:RegisterEvent("PLAYER_ENTERING_WORLD")
        BBP.StanceAuraWiper:SetScript("OnEvent", function()
            wipe(activeStanceAuras)
        end)
    end
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
    return false, false, false, false, false
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
        [1079] = 16,   -- Rip
        [155722] = 15, -- Rake
        [106830] = 15, -- Thrash
        [155625] = 14, -- Moonfire
        -- Balance
        [164815] = 12, -- Sunfire
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
        [1943] = 24,   -- Rupture
        [315496] = 12, -- Slice and Dice
        -- Assassination
        [703] = 18,    -- Garrote
        [121411] = 6, -- Crimson Tempest

    -- Shaman
        [188389] = 18, -- Flame Shock
        -- Restoration
        [382024] = 12, -- Earthliving Weapon
        [61295] = 18,  -- Riptide

    -- Warlock
        [445474] = 16, -- Wither
        -- Destruction
        [157736] = 18, -- Immolate
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
    elseif buff.spellID == 44457 then
        return nil, 3
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
        buff.PandemicGlow:SetTexture(BBP.squareGreenGlow)
        buff.PandemicGlow:SetDesaturated(true)
        buff.PandemicGlow:SetScale(2.25)
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
        checkBuffsTimer = C_Timer.NewTicker(0.1, CheckBuffs);
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
    if not frame then return end
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
    local keyAuraAnchor = (db.nameplateAuraKeyAuraPositionEnabled and (isEnemyUnit and db.nameplateKeyAurasAnchor) or (not isEnemyUnit and db.nameplateKeyAurasFriendlyAnchor))

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
    local isTarget
    if unit then
        isTarget = UnitIsUnit(unit, "target")
        isSelf = UnitIsUnit(unit, "player")
    end

    -- Separate buffs and debuffs if needed
    local buffs = {}
    local debuffs = {}
    if db.separateAuraBuffRow then
        for _, buff in ipairs(children) do
            if buff.isActive then
                if buff.isBuff then
                    table.insert(buffs, buff)
                else
                    table.insert(debuffs, buff)
                end
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
        local hasRealAuras = false
        for index, buff in ipairs(auras) do
            if buff:IsShown() then
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
            if buff:IsShown() then
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
        end
        return widths
    end

    -- Function to layout auras. ALl of this is scuffed and needs a rework. If one enlarged aura every row gets higher instead of only the row immediately after like intentional.
    local maxRowHeight = 0
    local maxDebuffHeight = 0
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
                if buff.isActive and buff.isKeyAura then
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
            if buff.isActive then
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
                        maxDebuffHeight = maxRowHeight
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
                                buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (db.nameplateAurasPersonalXPos + 1 - (extraOffset/buffScale))), verticalOffset - 13)
                            else
                                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + db.nameplateAurasPersonalXPos - extraOffset/buffScale, verticalOffset - 13)
                            end
                        end
                    else
                        if nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
                            if rightToLeft then
                                buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (xPos - extraOffset/buffScale)), verticalOffset - 13)
                            else
                                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + (xPos - extraOffset/buffScale), verticalOffset - 13)
                            end
                        else
                            if rightToLeft then
                                buff:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -((horizontalOffset/buffScale) + (xPos - 1 - (extraOffset/buffScale))), verticalOffset - 13)
                            else
                                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", (horizontalOffset/buffScale) + xPos - 1 - extraOffset/buffScale, verticalOffset - 13)
                            end
                        end
                    end
                    horizontalOffset = horizontalOffset + ((buffWidth)*buffScale) + horizontalSpacing-extraOffset
                end
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

            if hasNormalDebuff then
                BBP.activeTargetAuras = (isTarget and #buffs > 0)
            end
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
        BBP.activeTargetAuras = (isTarget and #buffs > 0)
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
        buff.Border:SetVertexColor(unpack(db.npAuraBuffsRGB))
    else
        local color = debuffColors[aura.dispelName] or db.npAuraOtherRGB
        buff.Border:SetVertexColor(unpack(color))
    end
end

local function SetBlueBuffBorder(buff, isPlayerUnit, isEnemyUnit)
    local otherNpBuffBlueBorder = BetterBlizzPlatesDB.otherNpBuffBlueBorder
    if otherNpBuffBlueBorder then
        if isEnemyUnit then
            if buff.isHelpful then
                buff.Border:SetVertexColor(0.2,0.2,1)
            else
                buff.Border:SetVertexColor(0,0,0)
            end
        end
    else
        buff.Border:SetVertexColor(0,0,0)
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
                    buff.buffBorderPurge:SetTexture(BBP.squareBlueGlow)
                    buff.buffBorderPurge:SetScale(2.25)
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
                buff.ImportantGlow:SetTexture(BBP.squareGreenGlow)
                buff.ImportantGlow:SetDesaturated(true)
                buff.ImportantGlow:SetScale(2.25)
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


    local BlizzardShouldShowCC = spellsForAllCata[spellId] or spellsForAllMoP[spellId]

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
                if not BlizzardShouldShow and filterBlizzard and not BlizzardShouldShowCC then
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

BBP.isRetail = false

local function CreateBorder(parent, r, g, b, a)
    local border = parent:CreateTexture(nil, "OVERLAY")
    border:SetColorTexture(r, g, b, a)
    return border
end

local borderThickness = 1

local function SetupBorderOnFrame(frame)
    if frame.Border then return end

    -- Create a Border frame
    local Border = CreateFrame("Frame", nil, frame)
    Border:SetAllPoints(frame)

    -- Create borders
    local borderTop = CreateBorder(Border, 0, 0, 0, 1)  -- Black color
    local borderBottom = CreateBorder(Border, 0, 0, 0, 1)
    local borderLeft = CreateBorder(Border, 0, 0, 0, 1)
    local borderRight = CreateBorder(Border, 0, 0, 0, 1)

    -- Position borders
    borderTop:SetPoint("TOPLEFT", Border, "TOPLEFT")
    borderTop:SetPoint("TOPRIGHT", Border, "TOPRIGHT")
    borderTop:SetHeight(borderThickness)

    borderBottom:SetPoint("BOTTOMLEFT", Border, "BOTTOMLEFT")
    borderBottom:SetPoint("BOTTOMRIGHT", Border, "BOTTOMRIGHT")
    borderBottom:SetHeight(borderThickness)

    borderLeft:SetPoint("TOPLEFT", Border, "TOPLEFT")
    borderLeft:SetPoint("BOTTOMLEFT", Border, "BOTTOMLEFT")
    borderLeft:SetWidth(borderThickness)

    borderRight:SetPoint("TOPRIGHT", Border, "TOPRIGHT")
    borderRight:SetPoint("BOTTOMRIGHT", Border, "BOTTOMRIGHT")
    borderRight:SetWidth(borderThickness)

    -- Assign the Border frame to the frame
    frame.Border = Border

    -- Define the SetVertexColor method for the Border frame
    -- Assign the Border frame to the frame
    frame.Border = Border
    frame.Border.borders = { borderTop, borderBottom, borderLeft, borderRight }

    -- Define the SetVertexColor method for the Border frame
    function Border:SetVertexColor(r, g, b, a)
        for _, border in ipairs(self.borders) do
            border:SetColorTexture(r, g, b, a)
        end
    end

    -- Hide the old border if it exists
    if frame.border then
        frame.border:Hide()
    end
end


function BBP.UpdateBuffs(self, unit, unitAuraUpdateInfo, auraSettings, UnitFrame)
    local frame = UnitFrame
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    if not frame.BuffFrame then
        if not config.nameplateAurasYPos then
            config.nameplateAurasYPos = BetterBlizzPlatesDB.nameplateAurasYPos
        end
        frame.BuffFrame = CreateFrame("Frame", nil, frame)
        frame.BuffFrame:SetSize(frame:GetWidth(), 26)
        frame.BuffFrame.auraFrames = {}
    end
    local nameplateAurasFriendlyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor and not info.isEnemy
    local nameplateAurasEnemyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor and info.isEnemy

    frame.BuffFrame:SetSize(frame:GetWidth(), 26)
    frame.BuffFrame:ClearAllPoints()
    if nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
        frame.BuffFrame:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 10+BetterBlizzPlatesDB.nameplateAurasYPos)
    else
        local yPos = 10 + BetterBlizzPlatesDB.nameplateAurasYPos
        frame.BuffFrame:SetPoint("BOTTOMLEFT", frame.healthBar, "TOPLEFT", -1, yPos)
        frame.BuffFrame:SetPoint("BOTTOMRIGHT", frame.healthBar, "TOPRIGHT", -1, yPos)
    end


    --local filters = {};
    local filterString
    -- if BBP.isRetail then
    --     if auraSettings.helpful then
    --         table.insert(filters, AuraUtil.AuraFilters.Helpful);
    --     end
    --     if auraSettings.harmful then
    --         table.insert(filters, AuraUtil.AuraFilters.Harmful);
    --     end
    --     if auraSettings.raid then
    --         table.insert(filters, AuraUtil.AuraFilters.Raid);
    --     end
    --     if auraSettings.includeNameplateOnly then
    --         table.insert(filters, AuraUtil.AuraFilters.IncludeNameplateOnly);
    --     end
    --     filterString = AuraUtil.CreateFilterString(unpack(filters));
    -- end

    local previousFilter = self.filter;
    local previousUnit = self.unit;
    self.unit = unit;
    self.filter = filterString;
    self.showFriendlyBuffs = auraSettings.showFriendlyBuffs;

    local aurasChanged = false;
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filterString ~= previousFilter  or not BBP.isRetail then
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

    if self.UpdateAnchor then
        self:UpdateAnchor();
    end

    if not aurasChanged then
        return;
    end

    --self.buffPool:ReleaseAll();

    --if auraSettings.hideAll or not self.isActive then
    -- if not self.isActive then
    --     return;
    -- end

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


    for _, buff in ipairs(self.auraFrames) do
        buff:Hide();
        buff.isActive = false;
    end


    self.auras:Iterate(function(auraInstanceID, aura)
        --if buffIndex > BBPMaxAuraNum then return true end
        local buff = frame.BuffFrame.auraFrames[buffIndex]
        if not buff then
            buff = CreateFrame("Frame", nil, frame.BuffFrame)
            buff.unit = unit
            buff.isBuff = aura.isHelpful;
            buff.spellID = aura.spellId;
            buff:SetSize(20, 14)
            buff.Icon = buff:CreateTexture(nil, "BORDER")
            buff.Icon:SetAllPoints(true)
            SetupBorderOnFrame(buff)

            -- Create cooldown frame
            buff.Cooldown = CreateFrame("Cooldown", nil, buff, "CooldownFrameTemplate")
            buff.Cooldown:SetAllPoints(true)
            buff.Cooldown:SetHideCountdownNumbers(showDefaultCooldownNumbersOnNpAuras and false or true)

            -- Create FontString for aura stacks
            buff.CountFrame = CreateFrame("Frame", nil, buff)
            buff.CountFrame.Count = buff.CountFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
            buff.CountFrame.Count:SetPoint("CENTER", buff, "BOTTOMRIGHT", -1, 4)
            if BetterBlizzPlatesDB.npAuraStackFontEnabled then
                local npAuraStackFontPath = LSM:Fetch(LSM.MediaType.FONT, BetterBlizzPlatesDB.npAuraStackFont)
                buff.CountFrame.Count:SetFont(npAuraStackFontPath, 11, "OUTLINE")
            else
                buff.CountFrame.Count:SetFont("fonts/arialn.ttf", 11, "THINOUTLINE")
            end
            buff.CountFrame:SetFrameStrata("DIALOG")

            frame.BuffFrame.auraFrames[buffIndex] = buff

            if BetterBlizzPlatesDB.nameplateAuraTooltip then
                buff:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    local foundIndex = nil
                    for i = 1, 255 do
                        local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, i, self.isBuff and "HELPFUL" or "HARMFUL")
                        if not aura then break end
                        if aura.auraInstanceID == self.auraInstanceID then
                            foundIndex = i
                            break
                        end
                    end
                    
                    if foundIndex then
                        GameTooltip:SetUnitAura(self.unit, foundIndex, self.isBuff and "HELPFUL" or "HARMFUL")
                        GameTooltip:AddLine("Spell ID: " .. self.spellID, 1, 1, 1)
                        GameTooltip:Show()
                    end
                end)

                buff:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)
            end
        end
        buff.unit = unit
        buff.Border:SetVertexColor(0,0,0,1)
        buff.auraInstanceID = auraInstanceID;
        buff.isBuff = aura.isHelpful;
        buff.layoutIndex = buffIndex;
        buff.spellID = aura.spellId;
        buff.duration = aura.duration;
        buff.expirationTime = aura.expirationTime

        buff:SetSize(20, 14)
        buff.Icon:SetTexture(aura.icon)
        buff.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
        --buff:SetPoint("BOTTOMLEFT", frame.BuffFrame, "BOTTOMLEFT", 4 + (iconWidth + auraPadding) * (auraIndex - 1), yPos)
        buff:Show()
        buff.isActive = true
        -- Set cooldown duration if applicable
        if buff.duration and buff.expirationTime then
            buff.Cooldown:SetCooldown(buff.expirationTime - buff.duration, buff.duration)
            buff.Cooldown:SetReverse(true)
        else
            buff.Cooldown:Hide()
        end
        -- Update aura stacks
        if aura.count and aura.count > 1 then
            buff.CountFrame.Count:SetText(aura.count)
            buff.CountFrame.Count:Show()
            buff.CountFrame:SetScale(BetterBlizzPlatesDB.nameplateAuraCountScale)
        else
            buff.CountFrame.Count:Hide()
        end

        buff.Icon:SetTexture(aura.icon);

        local spellName = aura.name--FetchSpellName(aura.spellId)
        local spellId = aura.spellId
        local caster = aura.sourceUnit
        local castByPlayer = (caster == "player" or caster == "pet")

        shouldShowAura, isImportant, isPandemic, auraColor, onlyMine, isEnlarged, isCompacted = GetAuraDetails(spellName, spellId)
        if onlyPandemicMine and not castByPlayer then
            isPandemic = false
        end

        -- if buff.Cooldown._occ_display then
        --     buff.Cooldown._occ_display:SetFrameStrata("FULLSCREEN")
        -- end
        buff.isKeyAura = nil
        buff.isCC = nil
        buff.pinIcon = nil

        --buff:SetFrameStrata("HIGH")

        if moveKeyAuras then
            local isKeyAura = keyAuraList[spellId]
            if isKeyAura then
                if isEnemyUnit then
                    --buff:SetFrameStrata("DIALOG")
                    buff.isKeyAura = true
                    isEnlarged = true
                    if isKeyAura ~= true and not isImportant then
                        isImportant = true
                        auraColor = isKeyAura
                    end
                else
                    if moveKeyAurasFriendly then
                        --buff:SetFrameStrata("DIALOG")
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

        if opBarriersOn and opBarriers[spellId] and auraData.duration ~= 5 then
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
                    cdText:SetScale((buff.isKeyAura and BetterBlizzPlatesDB.defaultNpAuraCdSize * 1.5) or BetterBlizzPlatesDB.defaultNpAuraCdSize)
                end
            end
        end

        buff:Show();
        buff:SetMouseClickEnabled(false)

        -- if not buff.isKeyAura then
        --     buffIndex = buffIndex + 1;
        -- end
        -- return buffIndex >= BUFF_MAX_DISPLAY;
        buffIndex = buffIndex + 1
        if not buff.isKeyAura and buffIndex > BBPMaxAuraNum then
            return true
        end
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

local function DefaultAuraCompare(a, b)
    local aFromPlayer = (a.sourceUnit ~= nil) and UnitIsUnit("player", a.sourceUnit) or false;
	local bFromPlayer = (b.sourceUnit ~= nil) and UnitIsUnit("player", b.sourceUnit) or false;
	if aFromPlayer ~= bFromPlayer then
		return aFromPlayer;
	end

	if a.canApplyAura ~= b.canApplyAura then
		return a.canApplyAura;
	end

	return a.auraInstanceID < b.auraInstanceID;
end

local DefaultAuraCompareBlizzard = AuraUtil.DefaultAuraCompare or DefaultAuraCompare

function BBP.ParseAllAuras(self, forceAll, UnitFrame)
    if self.auras == nil then
        self.auras = TableUtil.CreatePriorityTable(DefaultAuraCompareBlizzard, TableUtil.Constants.AssociativePriorityTable);
    else
        self.auras:Clear();
    end

    local mirrorImgFrostbolt = false
    local isTestModeEnabled = BetterBlizzPlatesDB.nameplateAuraTestMode

    local function HandleAura(aura, isTestModeEnabled, interrupt)
        if aura.spellId == 59638 then
            if mirrorImgFrostbolt then
                return false -- Already added one, skip
            end
            mirrorImgFrostbolt = true -- Allow this one, skip others later
        end
        local castByPlayer = aura.sourceUnit == "player" or aura.sourceUnit == "pet"
        local BlizzardShouldShow = (spellsCata[aura.spellId] or spellsMoP[aura.spellId]) and castByPlayer and not (BetterBlizzPlatesDB.blizzardDefaultFilterOnlyMine and (aura.sourceUnit ~= "player" and aura.sourceUnit~= "pet"))
        local shouldShowAura, isImportant, isPandemic = ShouldShowBuff(self.unit, aura, BlizzardShouldShow, isTestModeEnabled, interrupt)
        if shouldShowAura then
            self.auras[aura.auraInstanceID] = aura;
        end

        return false;
    end

    local function IterateAuras(self, filter, isTestModeEnabled)
        for i = 1, 255 do
            local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, i, filter);
            if ( not aura ) or ( not aura.name ) then
                break;
            end
            HandleAura(aura, isTestModeEnabled)
        end
    end

    -- local batchCount = nil;
    -- local usePackedAura = true;
    -- if BBP.isRetail then
    --     AuraUtil.ForEachAura(self.unit, "HARMFUL", batchCount, HandleAura, usePackedAura);
    --     if UnitIsUnit(self.unit, "player") then
    --         AuraUtil.ForEachAura(self.unit, "HELPFUL|INCLUDE_NAME_PLATE_ONLY", batchCount, HandleAura, usePackedAura);
    --     else
    --         AuraUtil.ForEachAura(self.unit, "HELPFUL", batchCount, HandleAura, usePackedAura);
    --     end
    -- else
        IterateAuras(self, "HARMFUL", isTestModeEnabled)
        IterateAuras(self, "HELPFUL", isTestModeEnabled)
    --end

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

    -- Inject stance auras (TBC warrior stances tracked via CLEU)
    if BBP.isTBC and destGUID and activeStanceAuras[destGUID] then
        local stanceSpellID = activeStanceAuras[destGUID]
        local spellName = GetSpellInfo(stanceSpellID)
        local stanceAura = {
            auraInstanceID = 2,
            spellId = stanceSpellID,
            icon = GetSpellTexture(stanceSpellID),
            name = spellName,
            duration = 0,
            expirationTime = 0,
            isHelpful = true,
            applications = 0,
            dispelName = nil,
        }
        HandleAura(stanceAura, false, false)
    end

    -- Injecting fake auras for testing
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
    -- local specID, _, _, _, _, _, _ = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
    -- return specsForResource[specID] or false
end

function BBP:UpdateAnchor()
    local frame = self:GetParent()

    if not self.GetBaseYOffset then
        self.GetBaseYOffset = function(self)
            return -3
        end
    end

    if not self.GetTargetYOffset then
        self.GetTargetYOffset = function(self)
            if GetCVarBool("nameplateResourceOnTarget") then
                return 18
            else
                return 0
            end
        end
    end



    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    local isTarget = frame.unit and UnitIsUnit(frame.unit, "target")
    local isFriend = info and info.isFriend --frame.unit and UnitReaction(frame.unit, "player") > 4

    local shouldNotOffset = config.nameplateResourceDoNotRaiseAuras or config.nameplateResourceUnderCastbar or not BBP.PlayerSpecHasResource()
    local targetYOffset = self:GetBaseYOffset() + (isTarget and not shouldNotOffset and self:GetTargetYOffset() or 0.0)

    if not config.buffAnchorInitalized or BBP.needsUpdate then
        config.friendlyNameplateClickthrough = BetterBlizzPlatesDB.friendlyNameplateClickthrough
        config.nameplateAurasYPos = BetterBlizzPlatesDB.nameplateAurasYPos
        config.nameplateAurasNoNameYPos = BetterBlizzPlatesDB.nameplateAurasNoNameYPos
        config.nameplateAuraScale = BetterBlizzPlatesDB.nameplateAuraScale

        config.buffAnchorInitalized = true
    end

    if frame.unit and ShouldShowName(frame) then
        -- if config.friendlyNameplateClickthrough and isFriend then
        --     --self:SetPoint("BOTTOM", frame, "TOP", 0, -3 + targetYOffset + config.nameplateAurasYPos + 63)
        --     self:SetPoint("BOTTOMLEFT", frame.healthBar, "TOPLEFT", 0, 13.5 + targetYOffset + config.nameplateAurasYPos)
        -- else
            self:SetPoint("BOTTOMLEFT", frame.healthBar, "TOPLEFT", 0, 13.5 + targetYOffset + config.nameplateAurasYPos)
        --end
    else
        local additionalYOffset = 15 * (config.nameplateAuraScale - 1)
        self:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4 + targetYOffset + config.nameplateAurasNoNameYPos + 1 + additionalYOffset)
    end
end

function BBP.RefreshBuffFrame()
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
		local unitFrame = namePlate.UnitFrame
        if unitFrame.BuffFrame.UpdateAnchor then
		    unitFrame.BuffFrame:UpdateAnchor()
        end
		if unitFrame.unit then
			local self = unitFrame.BuffFrame
            BBP.UpdateBuffs(self, unitFrame.unit, nil, {}, unitFrame)
        end
	end
end