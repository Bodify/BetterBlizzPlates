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

local magnuszAuraWhitelist = {
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
        ["name"] = "Lifebloom",
        ["comment"] = "",
    }, -- [1]
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
        ["name"] = "Cenarion Ward",
        ["comment"] = "",
    }, -- [2]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8392157554626465,
                ["g"] = 0.388235330581665,
                ["b"] = 0.2823529541492462,
            },
        },
        ["name"] = "Blistering Scales",
        ["comment"] = "",
    }, -- [3]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.4274510145187378,
                ["b"] = 0,
            },
        },
        ["name"] = "Cyclone",
        ["comment"] = "",
    }, -- [4]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Shield of Vengeance",
        ["comment"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Divine Protection",
        ["comment"] = "",
    }, -- [6]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Dark Pact",
        ["comment"] = "",
    }, -- [7]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Unending Resolve",
        ["comment"] = "",
    }, -- [8]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5176470875740051,
                ["g"] = 0.3372549116611481,
                ["b"] = 0.1843137294054031,
            },
        },
        ["name"] = "Bladestorm",
        ["comment"] = "",
    }, -- [9]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5176470875740051,
                ["g"] = 0.3372549116611481,
                ["b"] = 0.1843137294054031,
            },
        },
        ["name"] = "Die by the Sword",
        ["comment"] = "",
    }, -- [10]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.8784314393997192,
                ["b"] = 0.062745101749897,
            },
        },
        ["name"] = "Evasion",
        ["comment"] = "",
    }, -- [11]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.8784314393997192,
                ["b"] = 0.062745101749897,
            },
        },
        ["name"] = "Cloak of Shadows",
        ["comment"] = "",
    }, -- [12]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1960784494876862,
                ["g"] = 0.8588235974311829,
                ["b"] = 0.3529411852359772,
            },
        },
        ["name"] = "Touch of Karma",
        ["comment"] = "",
    }, -- [13]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1960784494876862,
                ["g"] = 0.8588235974311829,
                ["b"] = 0.3529411852359772,
            },
        },
        ["name"] = "Dampen Harm",
        ["comment"] = "",
    }, -- [14]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1960784494876862,
                ["g"] = 0.8588235974311829,
                ["b"] = 0.3529411852359772,
            },
        },
        ["name"] = "Fortifying Brew",
        ["comment"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 0.7568628191947937,
                ["b"] = 0.847058892250061,
            },
        },
        ["name"] = "Alter Time",
        ["comment"] = "",
    }, -- [16]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 0.7568628191947937,
                ["b"] = 0.847058892250061,
            },
        },
        ["name"] = "Displacement Beacon",
        ["comment"] = "",
    }, -- [17]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8392157554626465,
                ["g"] = 0.388235330581665,
                ["b"] = 0.2823529541492462,
            },
        },
        ["name"] = "Nullifying Shroud",
        ["comment"] = "",
    }, -- [18]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8392157554626465,
                ["g"] = 0.388235330581665,
                ["b"] = 0.2823529541492462,
            },
        },
        ["name"] = "Obsidian Scales",
        ["comment"] = "",
    }, -- [19]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8392157554626465,
                ["g"] = 0.388235330581665,
                ["b"] = 0.2823529541492462,
            },
        },
        ["name"] = "Time Dilation",
        ["comment"] = "",
    }, -- [20]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.4274510145187378,
                ["b"] = 0,
            },
        },
        ["name"] = "Barkskin",
        ["comment"] = "",
    }, -- [21]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.4274510145187378,
                ["b"] = 0,
            },
        },
        ["name"] = "Ironbark",
        ["comment"] = "",
    }, -- [22]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.4274510145187378,
                ["b"] = 0,
            },
        },
        ["name"] = "Thorns",
        ["comment"] = "",
    }, -- [23]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.6745098233222961,
                ["g"] = 0.003921568859368563,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Icebound Fortitude",
        ["comment"] = "",
    }, -- [24]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.6745098233222961,
                ["g"] = 0.003921568859368563,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Lichborne",
        ["comment"] = "",
    }, -- [25]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.6745098233222961,
                ["g"] = 0.003921568859368563,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Strangulate",
        ["comment"] = "",
    }, -- [26]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Blur",
        ["comment"] = "",
    }, -- [27]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Netherwalk",
        ["comment"] = "",
    }, -- [28]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.7568628191947937,
                ["g"] = 0.4549019932746887,
                ["b"] = 0.0313725508749485,
            },
        },
        ["name"] = "Roar of Sacrifice",
        ["comment"] = "",
    }, -- [29]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Blessing of Freedom",
        ["comment"] = "",
    }, -- [30]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Blessing of Sanctuary",
        ["comment"] = "",
    }, -- [31]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Blessing of Protection",
        ["comment"] = "",
    }, -- [32]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Divine Shield",
        ["comment"] = "",
    }, -- [33]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.8784314393997192,
                ["b"] = 0.062745101749897,
            },
        },
        ["name"] = "Shadow Dance",
        ["comment"] = "",
    }, -- [34]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5176470875740051,
                ["g"] = 0.3372549116611481,
                ["b"] = 0.1843137294054031,
            },
        },
        ["name"] = "Berserker Rage",
        ["comment"] = "",
    }, -- [35]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5176470875740051,
                ["g"] = 0.3372549116611481,
                ["b"] = 0.1843137294054031,
            },
        },
        ["name"] = "Enraged Regeneration",
        ["comment"] = "",
    }, -- [36]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5176470875740051,
                ["g"] = 0.3372549116611481,
                ["b"] = 0.1843137294054031,
            },
        },
        ["name"] = "Intervene",
        ["comment"] = "",
    }, -- [37]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Ray of Hope",
        ["comment"] = "",
    }, -- [38]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Guardian Spirit",
        ["comment"] = "",
    }, -- [39]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Holy Ward",
        ["comment"] = "",
    }, -- [40]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Pain Suppression",
        ["comment"] = "",
    }, -- [41]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Dispersion",
        ["comment"] = "",
    }, -- [42]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Avenging Wrath",
        ["comment"] = "",
    }, -- [43]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.8784314393997192,
                ["g"] = 0.1647058874368668,
                ["b"] = 0.6470588445663452,
            },
        },
        ["name"] = "Crusade",
        ["comment"] = "",
    }, -- [44]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Glimpse",
        ["comment"] = "",
    }, -- [45]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7647059559822083,
                ["g"] = 0.1921568810939789,
                ["r"] = 0.1647058874368668,
            },
        },
        ["name"] = "Spiritwalker's Grace",
        ["comment"] = "",
    }, -- [46]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7960785031318665,
                ["g"] = 0,
                ["r"] = 0.5647059082984924,
            },
        },
        ["name"] = "Imprison",
        ["comment"] = "",
    }, -- [47]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7960785031318665,
                ["g"] = 0,
                ["r"] = 0.5647059082984924,
            },
        },
        ["name"] = "Metamorphosis",
        ["comment"] = "",
    }, -- [48]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.847058892250061,
                ["g"] = 0.7568628191947937,
                ["r"] = 0,
            },
        },
        ["name"] = "Combustion",
        ["comment"] = "",
    }, -- [49]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.847058892250061,
                ["g"] = 0.7568628191947937,
                ["r"] = 0,
            },
        },
        ["name"] = "Icy Veins",
        ["comment"] = "",
    }, -- [50]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.847058892250061,
                ["g"] = 0.7568628191947937,
                ["r"] = 0,
            },
        },
        ["name"] = "Arcane Surge",
        ["comment"] = "",
    }, -- [51]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Adrenaline Rush",
        ["comment"] = "",
    }, -- [52]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Subterfuge",
        ["comment"] = "",
    }, -- [53]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Berserk",
        ["comment"] = "",
    }, -- [54]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Wild Attunement",
        ["comment"] = "",
    }, -- [55]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Incarnation: Chosen of Elune",
        ["comment"] = "",
    }, -- [56]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 1,
                ["g"] = 0.9960784912109375,
                ["r"] = 0.9843137860298157,
            },
        },
        ["name"] = "Power Infusion",
        ["comment"] = "",
    }, -- [57]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.03529411926865578,
                ["g"] = 0.003921568859368563,
                ["r"] = 0.6745098233222961,
            },
        },
        ["name"] = "Pillar of Frost",
        ["comment"] = "",
    }, -- [58]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.6745098233222961,
                ["g"] = 0.003921568859368563,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Unholy Assault",
        ["comment"] = "",
    }, -- [59]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Phase Shift",
        ["comment"] = "",
    }, -- [60]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.8784314393997192,
                ["b"] = 0.062745101749897,
            },
        },
        ["name"] = "Shadow Blades",
        ["comment"] = "",
    }, -- [61]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.8784314393997192,
                ["b"] = 0.062745101749897,
            },
        },
        ["name"] = "Flagellation",
        ["comment"] = "",
    }, -- [62]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1647058874368668,
                ["g"] = 0.1921568810939789,
                ["b"] = 0.7647059559822083,
            },
        },
        ["name"] = "Doom Winds",
        ["comment"] = "",
    }, -- [63]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1960784494876862,
                ["g"] = 0.8588235974311829,
                ["b"] = 0.3529411852359772,
            },
        },
        ["name"] = "Serenity",
        ["comment"] = "",
    }, -- [64]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 424331,
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 0.7568628191947937,
                ["b"] = 0.847058892250061,
            },
        },
        ["name"] = "",
    }, -- [65]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 422881,
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 0.7568628191947937,
                ["b"] = 0.847058892250061,
            },
        },
        ["name"] = "",
    }, -- [66]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 359844,
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.7568628191947937,
                ["g"] = 0.4549019932746887,
                ["b"] = 0.0313725508749485,
            },
        },
        ["name"] = "",
    }, -- [67]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 391109,
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "",
    }, -- [68]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 102543,
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.4274510145187378,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [69]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.8784314393997192,
                ["b"] = 0.062745101749897,
            },
        },
        ["name"] = "Master Assassin",
        ["comment"] = "",
    }, -- [70]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.03529411926865578,
                ["g"] = 0.003921568859368563,
                ["r"] = 0.6745098233222961,
            },
        },
        ["name"] = "Anti-Magic Shell",
        ["comment"] = "",
    }, -- [71]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Entangling Roots",
        ["comment"] = "",
    }, -- [72]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Mass Entanglement",
        ["comment"] = "",
    }, -- [73]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Rake",
        ["comment"] = "",
    }, -- [74]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0,
                ["g"] = 0.4274510145187378,
                ["r"] = 1,
            },
        },
        ["name"] = "Maim",
        ["comment"] = "",
    }, -- [75]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.6470588445663452,
                ["g"] = 0.1647058874368668,
                ["r"] = 0.8784314393997192,
            },
        },
        ["name"] = "Blinding Light",
        ["comment"] = "",
    }, -- [76]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.6470588445663452,
                ["g"] = 0.1647058874368668,
                ["r"] = 0.8784314393997192,
            },
        },
        ["name"] = "Hammer of Justice",
        ["comment"] = "",
    }, -- [77]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.6470588445663452,
                ["g"] = 0.1647058874368668,
                ["r"] = 0.8784314393997192,
            },
        },
        ["name"] = "Repentance",
        ["comment"] = "",
    }, -- [78]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 1,
                ["g"] = 0.9960784912109375,
                ["r"] = 0.9843137860298157,
            },
        },
        ["name"] = "Holy Word: Chastise",
        ["comment"] = "",
    }, -- [79]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 1,
                ["g"] = 0.9960784912109375,
                ["r"] = 0.9843137860298157,
            },
        },
        ["name"] = "Psychic Scream",
        ["comment"] = "",
    }, -- [80]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 1,
                ["g"] = 0.9960784912109375,
                ["r"] = 0.9843137860298157,
            },
        },
        ["name"] = "Psychic Horror",
        ["comment"] = "",
    }, -- [81]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 1,
                ["g"] = 0.9960784912109375,
                ["r"] = 0.9843137860298157,
            },
        },
        ["name"] = "Silence",
        ["comment"] = "",
    }, -- [82]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.0313725508749485,
                ["g"] = 0.4549019932746887,
                ["r"] = 0.7568628191947937,
            },
        },
        ["name"] = "Beastial Wrath",
        ["comment"] = "",
    }, -- [83]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7647059559822083,
                ["g"] = 0.1921568810939789,
                ["r"] = 0.1647058874368668,
            },
        },
        ["name"] = "Astral Shift",
        ["comment"] = "",
    }, -- [84]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7647059559822083,
                ["g"] = 0.1921568810939789,
                ["r"] = 0.1647058874368668,
            },
        },
        ["name"] = "Burrow",
        ["comment"] = "",
    }, -- [85]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Blind",
        ["comment"] = "",
    }, -- [86]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Sap",
        ["comment"] = "",
    }, -- [87]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Kidney Shot",
        ["comment"] = "",
    }, -- [88]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Gouge",
        ["comment"] = "",
    }, -- [89]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.062745101749897,
                ["g"] = 0.8784314393997192,
                ["r"] = 1,
            },
        },
        ["name"] = "Cheap Shot",
        ["comment"] = "",
    }, -- [90]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7960785031318665,
                ["g"] = 0,
                ["r"] = 0.5647059082984924,
            },
        },
        ["name"] = "Mortal Coil",
        ["comment"] = "",
    }, -- [91]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7960785031318665,
                ["g"] = 0,
                ["r"] = 0.5647059082984924,
            },
        },
        ["name"] = "Unstable Affliction",
        ["comment"] = "",
    }, -- [92]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.0313725508749485,
                ["g"] = 0.4549019932746887,
                ["r"] = 0.7568628191947937,
            },
        },
        ["name"] = "Freezing Trap",
        ["comment"] = "",
    }, -- [93]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.7568628191947937,
                ["g"] = 0.4549019932746887,
                ["b"] = 0.0313725508749485,
            },
        },
        ["name"] = "Trueshot Aura",
        ["comment"] = "",
    }, -- [94]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.7568628191947937,
                ["g"] = 0.4549019932746887,
                ["b"] = 0.0313725508749485,
            },
        },
        ["name"] = "Master's Call",
        ["comment"] = "",
    }, -- [95]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 0.7568628191947937,
                ["b"] = 0.847058892250061,
            },
        },
        ["name"] = "Polymorph",
        ["comment"] = "",
    }, -- [96]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 0.7568628191947937,
                ["b"] = 0.847058892250061,
            },
        },
        ["name"] = "Ring of Frost",
        ["comment"] = "",
    }, -- [97]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Fear",
        ["comment"] = "",
    }, -- [98]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Chaos Nova",
        ["comment"] = "",
    }, -- [99]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5647059082984924,
                ["g"] = 0,
                ["b"] = 0.7960785031318665,
            },
        },
        ["name"] = "Fel Eruption",
        ["comment"] = "",
    }, -- [100]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.6745098233222961,
                ["g"] = 0.003921568859368563,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Blinding Sleet",
        ["comment"] = "",
    }, -- [101]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.6745098233222961,
                ["g"] = 0.003921568859368563,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Asphyxiate",
        ["comment"] = "",
    }, -- [102]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1960784494876862,
                ["g"] = 0.8588235974311829,
                ["b"] = 0.3529411852359772,
            },
        },
        ["name"] = "Paralysis",
        ["comment"] = "",
    }, -- [103]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1960784494876862,
                ["g"] = 0.8588235974311829,
                ["b"] = 0.3529411852359772,
            },
        },
        ["name"] = "Leg Sweep",
        ["comment"] = "",
    }, -- [104]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1647058874368668,
                ["g"] = 0.1921568810939789,
                ["b"] = 0.7647059559822083,
            },
        },
        ["name"] = "Lightning Lasso",
        ["comment"] = "",
    }, -- [105]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.1647058874368668,
                ["g"] = 0.1921568810939789,
                ["b"] = 0.7647059559822083,
            },
        },
        ["name"] = "Tremor Totem",
        ["comment"] = "",
    }, -- [106]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Rapture",
        ["comment"] = "",
    }, -- [107]
    {
        ["flags"] = {
            ["important"] = false,
            ["onlyMine"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Mortal Wounds",
        ["comment"] = "",
    }, -- [108]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 1,
                ["g"] = 0.4274510145187378,
                ["b"] = 0,
            },
        },
        ["name"] = "Survival Instincts",
        ["comment"] = "",
    }, -- [109]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 387633,
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7960785031318665,
                ["g"] = 0,
                ["r"] = 0.5647059082984924,
            },
        },
        ["name"] = "",
    }, -- [110]
    {
        ["flags"] = {
            ["important"] = false,
            ["onlyMine"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Slaughterhouse",
        ["comment"] = "",
    }, -- [111]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.5176470875740051,
                ["g"] = 0.3372549116611481,
                ["b"] = 0.1843137294054031,
            },
        },
        ["name"] = "Defensive Stance",
        ["comment"] = "",
    }, -- [112]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["r"] = 0.9843137860298157,
                ["g"] = 0.9960784912109375,
                ["b"] = 1,
            },
        },
        ["name"] = "Void Form",
        ["comment"] = "",
    }, -- [113]
    {
        ["flags"] = {
            ["important"] = true,
            ["onlyMine"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.7647059559822083,
                ["g"] = 0.1921568810939789,
                ["r"] = 0.1647058874368668,
            },
        },
        ["name"] = "Flame Shock",
        ["comment"] = "",
    }, -- [114]
    {
        ["flags"] = {
            ["important"] = true,
            ["onlyMine"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.03529411926865578,
                ["g"] = 0.003921568859368563,
                ["r"] = 0.6745098233222961,
            },
        },
        ["name"] = "Rupture",
        ["comment"] = "",
    }, -- [115]
    {
        ["flags"] = {
            ["important"] = true,
            ["onlyMine"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.03529411926865578,
                ["g"] = 0.003921568859368563,
                ["r"] = 0.6745098233222961,
            },
        },
        ["name"] = "Garrote",
        ["comment"] = "",
    }, -- [116]
    {
        ["flags"] = {
            ["important"] = true,
            ["onlyMine"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.03529411926865578,
                ["g"] = 0.003921568859368563,
                ["r"] = 0.6745098233222961,
            },
        },
        ["name"] = "Crimston Tempest",
        ["comment"] = "",
    }, -- [117]
}

local magnuszAuraBlacklist = {
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Frost Fever",
        ["comment"] = "",
    }, -- [1]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Blood Plague",
        ["comment"] = "",
    }, -- [2]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Serrated Glaive",
        ["comment"] = "",
    }, -- [3]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Burning Wound",
        ["comment"] = "",
    }, -- [4]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Chaotic Imprint - Fire",
        ["comment"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Chaotic Imprint - Frost",
        ["comment"] = "",
    }, -- [6]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Chaotic Imprint - Nature",
        ["comment"] = "",
    }, -- [7]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Chaotic Imprint - Arcane",
        ["comment"] = "",
    }, -- [8]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Chaotic Imprint - Shadow",
        ["comment"] = "",
    }, -- [9]
}

local magnuszhideNPCsList = {
    {
        ["id"] = 31216,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Mirror Images (Mage)",
        ["comment"] = "",
    }, -- [1]
    {
        ["id"] = 55659,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Wild Imp (Warlock)",
        ["comment"] = "",
    }, -- [2]
    {
        ["id"] = 143622,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Wild Imp (Warlock)",
        ["comment"] = "",
    }, -- [3]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["comment"] = "Army",
        ["id"] = 24207,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "",
    }, -- [4]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 135816,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 98035,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "",
    }, -- [6]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 210910,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "",
    }, -- [7]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Beast",
        ["comment"] = "",
    }, -- [8]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 165189,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "",
    }, -- [9]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Void Lasher",
        ["comment"] = "",
    }, -- [10]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Denizen of the Dream",
        ["comment"] = "",
    }, -- [11]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Spirit Wolf",
        ["comment"] = "",
    }, -- [12]
}

local magnuszFadeOutNPCsList = {
    {
        ["id"] = 26125,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "DK pet",
        ["comment"] = "",
    }, -- [1]
    {
        ["id"] = 163366,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Magus(Army of the Dead)",
        ["comment"] = "",
    }, -- [2]
    {
        ["id"] = 24207,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Army of the Dead",
        ["comment"] = "",
    }, -- [3]
    {
        ["id"] = 29264,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Spirit Wolves (Enha Shaman)",
        ["comment"] = "",
    }, -- [4]
    {
        ["id"] = 95072,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Earth Elemental (Shaman)",
        ["comment"] = "",
    }, -- [5]
    {
        ["id"] = 31216,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Mirror Images (Mage)",
        ["comment"] = "",
    }, -- [6]
    {
        ["id"] = 105419,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Dire Basilisk (Hunter)",
        ["comment"] = "",
    }, -- [7]
    {
        ["id"] = 192337,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Void Tendril (Spriest)",
        ["comment"] = "",
    }, -- [8]
    {
        ["id"] = 136398,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Illidari Satyr",
        ["comment"] = "",
    }, -- [9]
    {
        ["id"] = 136408,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Darkhound",
        ["comment"] = "",
    }, -- [10]
    {
        ["id"] = 136403,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Void Terror",
        ["comment"] = "",
    }, -- [11]
    {
        ["id"] = 54983,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Treant",
        ["comment"] = "",
    }, -- [12]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Infernal",
        ["comment"] = "",
    }, -- [13]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Shadowfiend",
        ["comment"] = "",
    }, -- [14]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Mindbender",
        ["comment"] = "",
    }, -- [15]
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
	db.castBarInterruptHighlighterStartTime = 15
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
	db.castBarInterruptHighlighterEndTime = 85
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
	db.castBarInterruptHighlighterEndTimeHeight = 85
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
	db.castBarInterruptHighlighterStartTimeHeight = 15
	db.maxAurasOnNameplate = 12
	db.friendlyNameplatesOnlyInArena = true
	db.hideNPCWhitelistOn = false
end

function BBP.MagnuszProfile()
    updateAuraList(magnuszAuraWhitelist, BetterBlizzPlatesDB.auraWhitelist)
    updateAuraList(magnuszAuraBlacklist, BetterBlizzPlatesDB.auraBlacklist)
    updateAuraList(magnuszhideNPCsList, BetterBlizzPlatesDB.hideNPCsList)
    updateAuraList(magnuszFadeOutNPCsList, BetterBlizzPlatesDB.fadeOutNPCsList)

    local db = BetterBlizzPlatesDB
	db.classIndicatorFriendlyScale = 1
	db.nameplateAuraTaller = false
	db.useCustomTextureForEnemy = true
	db.totemIndicatorScale = 1
	db.petIndicatorScaleScale = 1
	db.raidmarkIndicator = false
	db.defaultLargeNamePlateFont = "Fonts\\FRIZQT__.TTF"
	db.targetIndicatorYPosYPos = 0
	db.executeIndicatorAnchor = "LEFT"
	db.arenaIdYPos = 0
	db.auraColor = false
	db.nameplateFriendlyWidthScale = 154
	db.friendlyNpdeBuffFilterLessMinite = false
	db.nameplateDefaultFriendlyHeight = 45
	db.friendlyNpBuffFilterLessMinite = false
	db.otherNpdeBuffFilterWatchList = true
	db.castBarInterruptHighlighterColorDontInterrupt = false
	db.focusTargetIndicatorXPosXPos = 0
	db.enableNameplateAuraCustomisation = true
	db.customTextureFriendly = "Minimalist"
	db.executeIndicatorScaleScale = 1
	db.classIndicatorXPos = 0
	db.colorNPCName = false
	db.questIndicatorTestMode = false
	db.castBarInterruptHighlighter = false
	db.targetIndicatorYPos = 0
	db.castBarEmphasisTextScaleScale = 2.099999904632568
	db.fadeOutNPCsAlphaAlpha = 0.1000000014901161
	db.friendlyNpBuffFilterAll = false
	db.updates = "1.4.7b"
	db.focusTargetIndicatorTexture = "Shattered DF (BBP)"
	db.classIndicatorFriendlyAnchor = "TOP"
	db.personalNpdeBuffEnable = false
	db.nameplateDefaultEnemyHeight = 45
	db.otherNpBuffFilterWatchList = true
	db.targetIndicatorScale = 1
	db.showNameplateCastbarTimer = false
	db.petIndicatorYPosYPos = 0
	db.arenaSpecYPosYPos = 0
	db.partyIndicatorModeOff = false
	db.questIndicatorAnchor = "LEFT"
	db.otherNpdeBuffPandemicGlow = false
	db.otherNpdeBuffEnable = true
	db.castBarShieldAnchor = "LEFT"
	db.otherNpBuffBlueBorder = false
	db.combatIndicatorXPos = 0
	db.friendlyNpdeBuffFilterWatchList = false
	db.auraWhitelistColorsUpdated = true
	db.nameplateAuraTestMode = false
	db.nameplateMinAlpha = "0.89999997615814"
	db.nameplateAurasEnemyCenteredAnchor = false
	db.classIndicatorScale = 1
	db.focusTargetIndicatorColorNameplate = false
	db.reopenOptions = false
	db.hasSaved = true
	db.nameplateAuraWidthGap = 2
	db.otherNpdeBuffFilterBlizzard = true
	db.castBarEmphasisOnlyInterruptable = false
	db.questIndicatorYPosYPos = 0
	db.defaultLargeFontSize = 12
	db.NamePlateVerticalScale = 2.7
	db.castBarDragonflightShield = true
	db.castBarHeight = 18.8
	db.arenaIdXPosXPos = 0
	db.healerIndicatorXPosXPos = 0
	db.focusTargetIndicatorTestMode = false
	db.focusTargetIndicatorYPosYPos = 0
	db.partyIndicatorModeThree = false
	db.classIndicatorFriendlyYPosYPos = 0
	db.nameplateResourceUnderCastbar = true
	db.nameplateMotion = "0"
	db.classIndicatorFriendlyXPos = 0
	db.arenaIndicatorModeOff = false
	db.nameplateOverlapHScale = 0.800000011920929
	db.friendlyNameplatesOnlyInArena = false
	db.arenaIndicatorModeFour = false
	db.nameplateAuraSquare = false
	db.nameplateShowEnemyGuardians = "1"
	db.castBarEmphasisSparkHeight = 35
	db.nameplateAurasXPosXPos = 0
	db.combatIndicatorSap = false
	db.nameplateEnemyHeight = 64.125
	db.friendlyNameScaleScale = 1
	db.nameplateAurasYPos = 6
	db.castBarEmphasisColor = false
	db.castBarTextScaleScale = 1
	db.castBarInterruptHighlighterEndTime = 80
	db.nameplateShowFriendlyTotems = "0"
	db.customFontSize = 12
	db.nameplateAurasCenteredAnchor = false
	db.questIndicatorYPos = 0
	db.nameplateMinAlphaScale = 0.8999999761581421
	db.customTexture = "Minimalist"
	db.friendlyNpBuffPurgeGlow = false
	db.enemyNameScaleScale = 1
	db.focusTargetIndicatorScaleScale = 1
	db.arenaIdXPos = 0
	db.castBarShieldYPos = 0
	db.showCastBarIconWhenNoninterruptible = false
	db.nameplateDefaultLargeEnemyHeight = 64.125
	db.castBarTextScale = 1
	db.castBarEmphasisHeightValueHeight = 24
	db.colorNPC = false
	db.classIndicatorAnchor = "TOP"
	db.nameplateResourceScaleScale = 0.699999988079071
	db.nameplateCenterAllRows = false
	db.absorbIndicatorEnemyOnly = true
	db.executeIndicatorThreshold = 35
	db.questIndicator = false
	db.nameplateFriendlyHeight = 64.125
	db.showNameplateTargetText = false
	db.hideNPCArenaOnly = false
	db.partySpecScale = 1
	db.personalNpdeBuffFilterLessMinite = false
	db.otherNpBuffEmphasisedBorder = false
	db.nameplateOccludedAlphaMultScale = 0.3999999761581421
	db.partyIDScale = 1
	db.useCustomTextureForBars = false
	db.nameplateShowFriendlyGuardians = "0"
	db.classIndicatorEnemy = true
	db.petIndicator = true
	db.enemyNameplateHealthbarHeight = 10.8
	db.absorbIndicator = true
	db.nameplateAuraRowAmount = 6
	db.nameplateSelfHeight = 45.0000114440918
	db.nameplateSelectedScaleScale = 1.149999976158142
	db.totemIndicatorYPosYPos = 6
	db.defaultLargeNamePlateFontFlags = ""
	db.arenaIdAnchor = "TOP"
	db.personalNpBuffEnable = true
	db.nameplateAuraRelativeAnchor = "TOPLEFT"
	db.friendlyNpBuffFilterBlacklist = true
	db.castBarEmphasisHealthbarColor = false
	db.totemIndicatorScaleScale = 1
	db.classIndicatorXPosXPos = 0
	db.arenaIndicatorModeThree = false
	db.totemIndicatorAnchor = "TOP"
	db.healerIndicatorYPos = 0
	db.totemIndicatorYPos = 6
	db.useCustomTextureForFriendly = true
	db.nameplateLargerScale = "1.2"
	db.nameplateAurasXPos = 0
	db.defaultNamePlateFontFlags = ""
	db.darkModeNameplateColor = 0.2
	db.castBarRecolorInterrupt = false
	db.castBarRecolor = false
	db.otherNpBuffFilterBlacklist = true
	db.combatIndicator = false
	db.absorbIndicatorYPos = 0
	db.nameplateMaxAlpha = "1"
	db.NamePlateClassificationScale = "1.0"
	db.useCustomFont = false
	db.absorbIndicatorScale = 1
	db.nameplateShowEnemyTotems = "1"
	db.castBarIconAnchor = "LEFT"
	db.classIndicatorFriendlyYPos = 0
	db.nameplateMinScale = "0.87999992370605"
	db.otherNpdeBuffFilterLessMinite = false
	db.executeIndicatorPercentSymbol = false
	db.classIndicatorYPos = 0
	db.absorbIndicatorAnchor = "LEFT"
	db.castBarEmphasisTextScale = 2.099999904632568
	db.classIndicatorYPosYPos = 0
	db.defaultFontSize = 9
	db.combatIndicatorAnchor = "CENTER"
	db.nameplateAuraHeightGap = 4
	db.focusTargetIndicatorScale = 1
	db.nameplateResourceScale = 0.699999988079071
	db.defaultNpAuraCdSize = 0.4999999701976776
	db.nameplateHorizontalScale = "1.4"
	db.healerIndicatorEnemyOnly = false
	db.petIndicatorTestMode = false
	db.executeIndicatorYPosYPos = 0
	db.classIndicatorScaleScale = 1
	db.executeIndicatorFriendly = false
	db.targetIndicatorTestMode = false
	db.personalNpBuffFilterBlizzard = true
	db.hideNameplateAuras = false
	db.executeIndicatorXPosXPos = 0
	db.combatIndicatorPlayersOnly = true
	db.friendlyNpdeBuffFilterBlacklist = true
	db.combatIndicatorEnemyOnly = true
	db.totemIndicatorDefaultCooldownTextSize = 1
	db.arenaSpecAnchor = "TOP"
	db.nameplateMotionSpeed = "0.049999997019768"
	db.otherNpdeBuffFilterAll = false
	db.partySpecScaleScale = 1
	db.raidmarkIndicatorYPosYPos = 0
	db.arenaSpecScale = 1
	db.combatIndicatorArenaOnly = false
	db.nameplateOverlapH = "0.80000001192093"
	db.hideDefaultPersonalNameplateAuras = false
	db.personalNpdeBuffFilterBlacklist = true
	db.targetIndicatorScaleScale = 1
	db.healerIndicatorEnemyScale = 1
	db.castBarEmphasisText = false
	db.nameplateFriendlyWidth = 154.0000305175781
	db.otherNpBuffPurgeGlow = false
	db.nameplateDefaultEnemyWidth = 110
	db.castBarHeightHeight = 18.79999923706055
	db.castBarInterruptHighlighterStartTime = 15
	db.personalNpdeBuffFilterAll = false
	db.targetIndicatorAnchor = "TOP"
	db.absorbIndicatorYPosYPos = 0
	db.totemIndicatorTestMode = false
	db.partyIDScaleScale = 1
	db.nameplateMinAlphaDistanceScale = 0.1000000014901161
	db.auraWhitelistAlphaUpdated = true
	db.executeIndicatorScale = 1
	db.nameplateAuraScale = 1.349999904632568
	db.nameplateAurasNoNameYPos = 0
	db.targetIndicatorXPos = 0
	db.nameplateResourcePositionFix = true
	db.totemIndicatorScaleUpImportant = false
	db.executeIndicatorTestMode = false
	db.combatIndicatorScaleScale = 1
	db.friendlyHideHealthBarNpc = true
	db.focusTargetIndicator = false
	db.combatIndicatorScale = 1
	db.personalNpBuffFilterAll = false
	db.nameplateMaxAlphaDistanceScale = 40
	db.arenaIDScale = 1
	db.raidmarkIndicatorAnchor = "TOP"
	db.hideTargetHighlight = false
	db.nameplateSelfWidthScale = 154
	db.classIndicatorFriendlyScaleScale = 1
	db.NamePlateVerticalScaleScale = 2.700000047683716
	db.petIndicatorYPos = 0
	db.focusTargetIndicatorXPos = 0
	db.nameplateAurasNoNameYPosYPos = 0
	db.arenaSpecXPosXPos = 0
	db.partyIndicatorModeFour = false
	db.nameplateAuraWidthGapScale = 2
	db.arenaSpecXPos = 0
	db.friendlyNpdeBuffEnable = false
	db.arenaIndicatorModeFive = false
	db.nameplateEnemyWidthScale = 154
	db.combatIndicatorYPos = 0
	db.nameplateOverlapV = "0.46999999880791"
	db.enableCastbarEmphasis = false
	db.healerIndicator = true
	db.totemIndicatorXPosXPos = 0
	db.guildNameScaleScale = 0.9999999403953552
	db.nameplateDefaultLargeFriendlyHeight = 64.125
	db.otherNpBuffEnable = true
	db.fadeOutNPC = true
	db.petIndicatorXPosXPos = 0
	db.otherNpdeBuffFilterOnlyMe = false
	db.nameplateShowEnemyMinus = "0"
	db.arenaIndicatorTestMode = false
	db.setCVarAcrossAllCharacters = true
	db.auraColorList = {
	}
	db.healerIndicatorScale = 1
	db.nameplateDefaultLargeFriendlyWidth = 154
	db.separateAuraBuffRow = true
	db.personalNpdeBuffFilterWatchList = true
	db.arenaIDScaleScale = 1
	db.healerIndicatorScaleScale = 1
	db.personalNpBuffFilterWatchList = true
	db.nameplateAurasFriendlyCenteredAnchor = false
	db.petIndicatorScale = 1
	db.castBarShieldXPos = 0
	db.largeNameplates = true
	db.healerIndicatorAnchor = "TOPRIGHT"
	db.nameplatePlayerLargerScale = "1.8"
	db.executeIndicatorShowDecimal = false
	db.friendlyNameplateClickthrough = false
	db.partyIndicatorModeFive = false
	db.castBarEmphasisIconScale = 2
	db.onlyPandemicAuraMine = true
	db.nameplateShowEnemyMinions = "1"
	db.arenaSpecScaleScale = 1
	db.castBarEmphasisIcon = false
	db.classIndicatorFriendlyXPosXPos = 0
	db.nameplateDefaultLargeEnemyWidth = 154
	db.healerIndicatorEnemyYPos = 0
	db.partyIndicatorModeOne = false
	db.classIndicator = false
	db.castBarIconScaleScale = 1
	db.removeRealmNames = true
	db.questIndicatorXPos = 0
	db.hideResourceOnFriend = false
	db.healerIndicatorXPos = 0
	db.executeIndicatorAlwaysOn = false
	db.otherNpdeBuffFilterBlacklist = true
	db.castBarIconXPos = 0
	db.nameplateOccludedAlphaMult = "0.39999997615814"
	db.petIndicatorAnchor = "CENTER"
	db.healerIndicatorYPosYPos = 0
	db.nameplateShowEnemyPets = "1"
	db.classIconColorBorder = true
	db.wasOnLoadingScreen = false
	db.executeIndicatorNotOnFullHp = false
	db.focusTargetIndicatorAnchor = "TOPRIGHT"
	db.classIndicatorFriendly = true
	db.totemIndicatorEnemyOnly = true
	db.absorbIndicatorTestMode = false
	db.enemyNameScale = 1
	db.fadeOutNPCsAlpha = 0.1000000014901161
	db.raidmarkIndicatorScale = 1
	db.testAllEnabledFeatures = false
	db.nameplateDefaultFriendlyWidth = 110
	db.focusTargetIndicatorYPos = 0
	db.raidmarkIndicatorScaleScale = 1
	db.healerIndicatorTestMode = false
	db.nameplateAuraRowAbove = true
	db.nameplateEnemyWidth = 154.0000305175781
	db.executeIndicatorThresholdScale = 35
	db.nameplateMaxScaleScale = 1.099999904632568
	db.totemIndicatorDefaultCooldownTextSizeScale = 1
	db.totemIndicator = false
	db.absorbIndicatorOnPlayersOnly = true
	db.personalNpBuffFilterBlacklist = true
	db.raidmarkIndicatorXPos = 0
	db.nameplateOverlapVScale = 0.4699999988079071
	db.castBarEmphasisHeightValue = 24
	db.questIndicatorScaleScale = 1
	db.raidmarkIndicatorYPos = 0
	db.executeIndicatorYPos = 0
	db.otherNpBuffFilterLessMinite = false
	db.nameplateAurasYPosYPos = 6
	db.showTotemIndicatorCooldownSwipe = true
	db.nameplateResourceXPos = 0
	db.nameplateAuraHeightGapScale = 4
	db.friendlyNpBuffFilterWatchList = false
	db.showCastbarIfTarget = false
	db.combatIndicatorXPosXPos = 0
	db.personalNpBuffFilterOnlyMe = false
	db.enemyClassColorName = false
	db.castBarIconPosReset = true
	db.nameplateSelfWidth = 154.0000305175781
	db.totemIndicatorXPos = 0
	db.nameplateAuraRowAmountScale = 6
	db.absorbIndicatorXPos = 0
	db.nameplateMinAlphaDistance = "0.10000000149012"
	db.nameplateAuraAnchor = "BOTTOMLEFT"
	db.healerIndicatorEnemyXPos = 0
	db.targetIndicator = true
	db.darkModeNameplateResource = false
	db.friendlyNameScale = 1
	db.healerIndicatorEnemyAnchor = "TOPRIGHT"
	db.castBarIconScale = 1
	db.defaultNamePlateFont = "Fonts\\FRIZQT__.TTF"
	db.arenaIndicatorModeTwo = false
	db.nameplateMotionSpeedScale = 0.04999999701976776
	db.raidmarkIndicatorXPosXPos = 0
	db.castbarEventsOn = false
	db.castBarEmphasisHeight = false
	db.defaultNpAuraCdSizeScale = 0.4999999701976776
	db.castBarShieldScale = 1
	db.combatIndicatorYPosYPos = 0
	db.executeIndicatorXPos = 0
	db.nameplateShowFriendlyPets = "0"
	db.otherNpBuffFilterAll = false
	db.castBarIconYPos = 0
	db.arenaIdYPosYPos = 0
	db.targetIndicatorXPosXPos = 0
	db.anonMode = false
	db.friendlyNpdeBuffFilterOnlyMe = false
	db.castBarEmphasisIconScaleScale = 2
	db.friendlyNpBuffEmphasisedBorder = false
	db.nameplateShowFriendlyMinions = "0"
	db.arenaSpecYPos = 0
	db.castBarEmphasisTextScaleHeight = 2.099999904632568
	db.friendlyNpBuffEnable = false
	db.version = "1.00"
	db.targetIndicatorTexture = "Checkered (BBP)"
	db.hideCastbar = false
	db.petIndicatorXPos = 0
	db.personalNpBuffFilterLessMinite = false
	db.absorbIndicatorXPosXPos = 0
	db.nameplateMaxScale = "1.0999999046326"
	db.hideNPC = true
	db.nameplateResourceYPosYPos = 0
	db.maxAurasOnNameplateScale = 12
	db.friendlyClassColorName = false
	db.absorbIndicatorScaleScale = 1
	db.friendlyNpBuffFilterOnlyMe = false
	db.enableCastbarCustomization = false
	db.nameplateGlobalScale = "1"
	db.questIndicatorScale = 1
	db.nameplateResourceXPosXPos = 0
	db.nameplateResourceYPos = 0
	db.nameplateSelectedScale = "1.1499999761581"
	db.nameplateMaxAlphaDistance = "40"
	db.partyIndicatorModeTwo = false
	db.arenaIndicatorModeOne = false
	db.executeIndicator = true
	db.customFont = "Numen"
	db.friendlyNpdeBuffFilterAll = false
	db.nameplateMaxAlphaScale = 1
	db.friendlyNpdeBuffFilterBlizzard = false
	db.totemIndicatorHideNameAndShiftIconDown = false
	db.questIndicatorXPosXPos = 0
	db.maxAurasOnNameplate = 12
	db.nameplateAuraScaleScale = 1.349999904632568
	db.friendlyNpBuffBlueBorder = false
end