local defaultColors = {
    ["HUNTER"] = {0.67, 0.83, 0.45},
    ["WARLOCK"] = {0.58, 0.51, 0.79},
    ["PRIEST"] = {1.0, 1.0, 1.0},
    ["PALADIN"] = {0.96, 0.55, 0.73},
    ["MAGE"] = {0.41, 0.8, 0.94},
    ["ROGUE"] = {1.0, 0.96, 0.41},
    ["DRUID"] = {1.0, 0.49, 0.04},
    ["SHAMAN"] = {0.0, 0.44, 0.87},
    ["WARRIOR"] = {0.78, 0.61, 0.43},
    ["DEATHKNIGHT"] = {0.77, 0.12, 0.23},
    ["MONK"] = {0.0, 1.00, 0.59},
    ["DEMONHUNTER"] = {0.64, 0.19, 0.79},
    ["EVOKER"] = {0.20, 0.58, 0.50},

    ["dark1"] = {0.1215, 0.1176, 0.1294},
    ["dark2"] = {0.2215, 0.2176, 0.2294},
    ["dark3"] = {0.3215, 0.3176, 0.3294},

    ["aliceblue"] = {0.941176, 0.972549, 1, 1},
    ["antiquewhite"] = {0.980392, 0.921569, 0.843137, 1},
    ["aqua"] = {0, 1, 1, 1},
    ["aquamarine"] = {0.498039, 1, 0.831373, 1},
    ["azure"] = {0.941176, 1, 1, 1},
    ["beige"] = {0.960784, 0.960784, 0.862745, 1},
    ["bisque"] = {1, 0.894118, 0.768627, 1},
    ["black"] = {0, 0, 0, 1},
    ["blanchedalmond"] = {1, 0.921569, 0.803922, 1},
    ["blue"] = {0, 0, 1, 1},
    ["blueviolet"] = {0.541176, 0.168627, 0.886275, 1},
    ["brown"] = {0.647059, 0.164706, 0.164706, 1},
    ["burlywood"] = {0.870588, 0.721569, 0.529412, 1},
    ["cadetblue"] = {0.372549, 0.619608, 0.627451, 1},
    ["chartreuse"] = {0.498039, 1, 0, 1},
    ["chocolate"] = {0.823529, 0.411765, 0.117647, 1},
    ["coral"] = {1, 0.498039, 0.313725, 1},
    ["cornflowerblue"] = {0.392157, 0.584314, 0.929412, 1},
    ["cornsilk"] = {1, 0.972549, 0.862745, 1},
    ["crimson"] = {0.862745, 0.0784314, 0.235294, 1},
    ["cyan"] = {0, 1, 1, 1},
    ["darkblue"] = {0, 0, 0.545098, 1},
    ["darkcyan"] = {0, 0.545098, 0.545098, 1},
    ["darkgoldenrod"] = {0.721569, 0.52549, 0.0431373, 1},
    ["darkgray"] = {0.662745, 0.662745, 0.662745, 1},
    ["darkgreen"] = {0, 0.392157, 0, 1},
    ["darkkhaki"] = {0.741176, 0.717647, 0.419608, 1},
    ["darkmagenta"] = {0.545098, 0, 0.545098, 1},
    ["darkolivegreen"] = {0.333333, 0.419608, 0.184314, 1},
    ["darkorange"] = {1, 0.54902, 0, 1},
    ["darkorchid"] = {0.6, 0.196078, 0.8, 1},
    ["darkred"] = {0.545098, 0, 0, 1},
    ["darksalmon"] = {0.913725, 0.588235, 0.478431, 1},
    ["darkseagreen"] = {0.560784, 0.737255, 0.560784, 1},
    ["darkslateblue"] = {0.282353, 0.239216, 0.545098, 1},
    ["darkslategray"] = {0.184314, 0.309804, 0.309804, 1},
    ["darkturquoise"] = {0, 0.807843, 0.819608, 1},
    ["darkviolet"] = {0.580392, 0, 0.827451, 1},
    ["deeppink"] = {1, 0.0784314, 0.576471, 1},
    ["deepskyblue"] = {0, 0.74902, 1, 1},
    ["dimgray"] = {0.411765, 0.411765, 0.411765, 1},
    ["dimgrey"] = {0.411765, 0.411765, 0.411765, 1},
    ["dodgerblue"] = {0.117647, 0.564706, 1, 1},
    ["firebrick"] = {0.698039, 0.133333, 0.133333, 1},
    ["firebrickdark"] = {0.258039, 0.033333, 0.033333, 1},
    ["floralwhite"] = {1, 0.980392, 0.941176, 1},
    ["forestgreen"] = {0.133333, 0.545098, 0.133333, 1},
    ["fuchsia"] = {1, 0, 1, 1},
    ["gainsboro"] = {0.862745, 0.862745, 0.862745, 1},
    ["ghostwhite"] = {0.972549, 0.972549, 1, 1},
    ["gold"] = {1, 0.843137, 0, 1},
    ["goldenrod"] = {0.854902, 0.647059, 0.12549, 1},
    ["gray"] = {0.501961, 0.501961, 0.501961, 1},
    ["green"] = {0, 0.501961, 0, 1},
    ["greenyellow"] = {0.678431, 1, 0.184314, 1},
    ["honeydew"] = {0.941176, 1, 0.941176, 1},
    ["hotpink"] = {1, 0.411765, 0.705882, 1},
    ["indianred"] = {0.803922, 0.360784, 0.360784, 1},
    ["indigo"] = {0.294118, 0, 0.509804, 1},
    ["ivory"] = {1, 1, 0.941176, 1},
    ["khaki"] = {0.941176, 0.901961, 0.54902, 1},
    ["lavender"] = {0.901961, 0.901961, 0.980392, 1},
    ["lavenderblush"] = {1, 0.941176, 0.960784, 1},
    ["lawngreen"] = {0.486275, 0.988235, 0, 1},
    ["lemonchiffon"] = {1, 0.980392, 0.803922, 1},
    ["lightblue"] = {0.678431, 0.847059, 0.901961, 1},
    ["lightcoral"] = {0.941176, 0.501961, 0.501961, 1},
    ["lightcyan"] = {0.878431, 1, 1, 1},
    ["lightgoldenrodyellow"] = {0.980392, 0.980392, 0.823529, 1},
    ["lightgray"] = {0.827451, 0.827451, 0.827451, 1},
    ["lightgreen"] = {0.564706, 0.933333, 0.564706, 1},
    ["lightpink"] = {1, 0.713725, 0.756863, 1},
    ["lightsalmon"] = {1, 0.627451, 0.478431, 1},
    ["lightseagreen"] = {0.12549, 0.698039, 0.666667, 1},
    ["lightskyblue"] = {0.529412, 0.807843, 0.980392, 1},
    ["lightslategray"] = {0.466667, 0.533333, 0.6, 1},
    ["lightsteelblue"] = {0.690196, 0.768627, 0.870588, 1},
    ["lightyellow"] = {1, 1, 0.878431, 1},
    ["lime"] = {0, 1, 0, 1},
    ["limegreen"] = {0.196078, 0.803922, 0.196078, 1},
    ["linen"] = {0.980392, 0.941176, 0.901961, 1},
    ["magenta"] = {1, 0, 1, 1},
    ["maroon"] = {0.501961, 0, 0, 1},
    ["mediumaquamarine"] = {0.4, 0.803922, 0.666667, 1},
    ["mediumblue"] = {0, 0, 0.803922, 1},
    ["mediumorchid"] = {0.729412, 0.333333, 0.827451, 1},
    ["mediumpurple"] = {0.576471, 0.439216, 0.858824, 1},
    ["mediumseagreen"] = {0.235294, 0.701961, 0.443137, 1},
    ["mediumslateblue"] = {0.482353, 0.407843, 0.933333, 1},
    ["mediumspringgreen"] = {0, 0.980392, 0.603922, 1},
    ["mediumturquoise"] = {0.282353, 0.819608, 0.8, 1},
    ["mediumvioletred"] = {0.780392, 0.0823529, 0.521569, 1},
    ["midnightblue"] = {0.0980392, 0.0980392, 0.439216, 1},
    ["mintcream"] = {0.960784, 1, 0.980392, 1},
    ["mistyrose"] = {1, 0.894118, 0.882353, 1},
    ["moccasin"] = {1, 0.894118, 0.709804, 1},
    ["navajowhite"] = {1, 0.870588, 0.678431, 1},
    ["navy"] = {0, 0, 0.501961, 1},
    ["none"] ={0, 0, 0, 0},
    ["oldlace"] = {0.992157, 0.960784, 0.901961, 1},
    ["olive"] = {0.501961, 0.501961, 0, 1},
    ["olivedrab"] = {0.419608, 0.556863, 0.137255, 1},
    ["orange"] = {1, 0.647059, 0, 1},
    ["orangered"] = {1, 0.270588, 0, 1},
    ["orchid"] = {0.854902, 0.439216, 0.839216, 1},
    ["palegoldenrod"] = {0.933333, 0.909804, 0.666667, 1},
    ["palegreen"] = {0.596078, 0.984314, 0.596078, 1},
    ["paleturquoise"] = {0.686275, 0.933333, 0.933333, 1},
    ["palevioletred"] = {0.858824, 0.439216, 0.576471, 1},
    ["papayawhip"] = {1, 0.937255, 0.835294, 1},
    ["peachpuff"] = {1, 0.854902, 0.72549, 1},
    ["peru"] = {0.803922, 0.521569, 0.247059, 1},
    ["pink"] = {1, 0.752941, 0.796078, 1},
    ["plum"] = {0.866667, 0.627451, 0.866667, 1},
    ["powderblue"] = {0.690196, 0.878431, 0.901961, 1},
    ["purple"] = {0.501961, 0, 0.501961, 1},
    ["red"] = {1, 0, 0, 1},
    ["rosybrown"] = {0.737255, 0.560784, 0.560784, 1},
    ["royalblue"] = {0.254902, 0.411765, 0.882353, 1},
    ["saddlebrown"] = {0.545098, 0.270588, 0.0745098, 1},
    ["salmon"] = {0.980392, 0.501961, 0.447059, 1},
    ["sandybrown"] = {0.956863, 0.643137, 0.376471, 1},
    ["seagreen"] = {0.180392, 0.545098, 0.341176, 1},
    ["seashell"] = {1, 0.960784, 0.933333, 1},
    ["sienna"] = {0.627451, 0.321569, 0.176471, 1},
    ["silver"] = {0.752941, 0.752941, 0.752941, 1},
    ["skyblue"] = {0.529412, 0.807843, 0.921569, 1},
    ["slateblue"] = {0.415686, 0.352941, 0.803922, 1},
    ["slategray"] = {0.439216, 0.501961, 0.564706, 1},
    ["snow"] = {1, 0.980392, 0.980392, 1},
    ["springgreen"] = {0, 1, 0.498039, 1},
    ["steelblue"] = {0.27451, 0.509804, 0.705882, 1},
    ["tan"] = {0.823529, 0.705882, 0.54902, 1},
    ["teal"] = {0, 0.501961, 0.501961, 1},
    ["thistle"] = {0.847059, 0.74902, 0.847059, 1},
    ["tomato"] = {1, 0.388235, 0.278431, 1},
    ["transparent"] ={0, 0, 0, 0},
    ["turquoise"] = {0.25098, 0.878431, 0.815686, 1},
    ["violet"] = {0.933333, 0.509804, 0.933333, 1},
    ["wheat"] = {0.960784, 0.870588, 0.701961, 1},
    ["white"] = {1, 1, 1, 1},
    ["whitesmoke"] = {0.960784, 0.960784, 0.960784, 1},
    ["yellow"] = {1, 1, 0, 1},
    ["yellowgreen"] = {0.603922, 0.803922, 0.196078, 1}
}

-- function BBP.ConvertNpcColorToBBP(platerData)
--     local convertedData = {}

--     for key, npcData in pairs(platerData) do
--         -- Check if npcData is a table
--         if type(npcData) == "table" then
--             local npcID = npcData[1]
--             --local enabled = npcData[2]
--             local colorName = npcData[3]
--             local npcName = npcData[4]
--             --local zoneName = npcData[5]

--             local colorRGB = defaultColors[colorName]
--             if not colorRGB then
--                 colorRGB = {1, 1, 1}
--             end

--             local entry = {
--                 ["comment"] = "",
--                 ["id"] = npcID,
--                 ["entryColors"] = {
--                     ["text"] = {
--                         ["r"] = colorRGB[1],
--                         ["g"] = colorRGB[2],
--                         ["b"] = colorRGB[3],
--                     },
--                 },
--                 ["name"] = npcName,
--             }

--             table.insert(convertedData, entry)
--         end
--     end

--     return convertedData
-- end

-- function BBP.ConvertCastColorToBBP(platerData)
--     local convertedData = {}

--     for key, castData in pairs(platerData) do
--         -- Check if npcData is a table
--         if type(castData) == "table" then
--             local spellID = castData[1]
--             local colorName = castData[2]

--             local colorRGB = defaultColors[colorName]
--             if not colorRGB then
--                 colorRGB = {1, 1, 1}
--             end

--             local entry = {
--                 ["id"] = spellID,
--                 ["entryColors"] = {
--                     ["text"] = {
--                         ["r"] = colorRGB[1],
--                         ["g"] = colorRGB[2],
--                         ["b"] = colorRGB[3],
--                     },
--                 },
--             }

--             table.insert(convertedData, entry)
--         end
--     end

--     return convertedData
-- end


function BBP.MergeNpcColorToBBP(platerData)
    for key, npcData in pairs(platerData) do
        -- Check if npcData is a table
        if type(npcData) == "table" and type(npcData[1]) == "number" and type(npcData[4]) == "string" then
            local npcID = npcData[1]
            --local enabled = npcData[2]
            local colorName = npcData[3]
            local npcName = npcData[4]
            --local zoneName = npcData[5]

            local colorRGB = defaultColors[colorName]
            if not colorRGB then
                colorRGB = {1, 1, 1}
            end

            local entry = {
                ["comment"] = "",
                ["id"] = npcID,
                ["entryColors"] = {
                    ["text"] = {
                        ["r"] = colorRGB[1],
                        ["g"] = colorRGB[2],
                        ["b"] = colorRGB[3],
                    },
                },
                ["name"] = npcName,
            }

            -- Check if the NPC ID already exists in the database
            local exists = false
            for _, existingEntry in pairs(BetterBlizzPlatesDB.colorNpcList) do
                if existingEntry.id == npcID then
                    exists = true
                    break
                end
            end

            -- If it doesn't exist, add it
            if not exists then
                table.insert(BetterBlizzPlatesDB.colorNpcList, entry)
            end
        end
    end
end

function BBP.MergeCastColorToBBP(platerData)
    for key, castData in pairs(platerData) do
        -- Check if castData is a table
        if type(castData) == "table" and type(castData[1]) == "number" and type(castData[2]) == "string" then
            local spellID = castData[1]
            local colorName = castData[2]

            local colorRGB = defaultColors[colorName]
            if not colorRGB then
                colorRGB = {1, 1, 1}
            end

            local entry = {
                ["id"] = spellID,
                ["entryColors"] = {
                    ["text"] = {
                        ["r"] = colorRGB[1],
                        ["g"] = colorRGB[2],
                        ["b"] = colorRGB[3],
                    },
                },
            }

            -- Check if the spell ID already exists in the database
            local exists = false
            for _, existingEntry in pairs(BetterBlizzPlatesDB.castEmphasisList) do
                if existingEntry.id == spellID then
                    exists = true
                    break
                end
            end

            -- If it doesn't exist, add it
            if not exists then
                table.insert(BetterBlizzPlatesDB.castEmphasisList, entry)
            end
        end
    end
end
