local playerFaction = UnitFactionGroup("player")

local factionIconSets = {
    [1] = { -- Quest Log Icons
        ["Alliance"] = { atlas = "questlog-questtypeicon-alliance", width = 24, height = 24 },
        ["Horde"]    = { atlas = "questlog-questtypeicon-horde", width = 22, height = 22 },
    },
    [2] = { -- UnitFrame Icons
        ["Alliance"] = { atlas = "UI-HUD-UnitFrame-Player-PVP-AllianceIcon", width = 16, height = 24 },
        ["Horde"]    = { atlas = "UI-HUD-UnitFrame-Player-PVP-HordeIcon", width = 24, height = 24 },
    },
    [3] = { -- PVP Banners
        ["Horde"]    = { texture = "Interface\\Icons\\Inv_BannerPVP_01", width = 24, height = 24 },
        ["Alliance"] = { texture = "Interface\\Icons\\Inv_BannerPVP_02", width = 24, height = 24 },
    },
    [4] = { -- BFA Landing Buttons
        ["Alliance"] = { atlas = "bfa-landingbutton-alliance-up", width = 22, height = 24 },
        ["Horde"]    = { atlas = "bfa-landingbutton-horde-up", width = 21, height = 24 },
    },
    [5] = { -- Talent Tree Logos
        ["Alliance"] = { atlas = "talenttree-alliance-cornerlogo", width = 21, height = 24 },
        ["Horde"]    = { atlas = "talenttree-horde-cornerlogo", width = 21, height = 24 },
    },
    [6] = { -- CTF Flags
        ["Alliance"] = { atlas = "ctf_flags-leftIcon1-state1", width = 24, height = 24 },
        ["Horde"]    = { atlas = "ctf_flags-rightIcon1-state1", width = 24, height = 24 },
    },
    [7] = { -- Quest Portrait Icons
        ["Alliance"] = { atlas = "QuestPortraitIcon-Alliance", width = 21, height = 24 },
        ["Horde"]    = { atlas = "QuestPortraitIcon-Horde", width = 21, height = 24 },
    },
    [8] = { -- Quest Portrait (Small)
        ["Alliance"] = { atlas = "QuestPortraitIcon-Alliance-small", width = 22, height = 24 },
        ["Horde"]    = { atlas = "QuestPortraitIcon-Horde-small", width = 21, height = 24 },
    },
    [9] = { -- Character Create Icons
        ["Alliance"] = { atlas = "charcreatetest-logo-alliance", width = 20, height = 24 },
        ["Horde"]    = { atlas = "charcreatetest-logo-horde", width = 20, height = 24 },
    },
    [10] = { -- Character Create (Small)
        ["Alliance"] = { atlas = "charactercreate-icon-alliance", width = 24, height = 26 },
        ["Horde"]    = { atlas = "charactercreate-icon-horde", width = 24, height = 26 },
    },
    [11] = { -- Warfront Armory Icons
        ["Alliance"] = { atlas = "Warfronts-BaseMapIcons-Alliance-Armory", width = 24, height = 23 },
        ["Horde"]    = { atlas = "Warfronts-BaseMapIcons-Horde-Armory", width = 24, height = 23 },
    },
    [12] = { -- Wax Seals
        ["Alliance"] = { atlas = "Quest-Alliance-WaxSeal", width = 24, height = 22 },
        ["Horde"]    = { atlas = "Quest-Horde-WaxSeal", width = 24, height = 22 },
    },
}

local function ApplyFactionIcon(texture, iconData)
    if not iconData then return false end
    if iconData.atlas then
        texture:SetAtlas(iconData.atlas)
    else
        texture:SetTexture(iconData.texture)
    end
    texture:SetSize(iconData.width, iconData.height)
    return true
end

-- Faction Indicator
function BBP.FactionIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    -- Initialize settings if needed
    if not config.factionIndicatorInitialized or BBP.needsUpdate then
        config.factionIndicatorEnemy = BetterBlizzPlatesDB.factionIndicatorEnemy
        config.factionIndicatorFriendly = BetterBlizzPlatesDB.factionIndicatorFriendly
        config.factionIndicatorAnchor = BetterBlizzPlatesDB.factionIndicatorAnchor or "LEFT"
        config.factionIndicatorXPos = BetterBlizzPlatesDB.factionIndicatorXPos or 0
        config.factionIndicatorYPos = BetterBlizzPlatesDB.factionIndicatorYPos or 0
        config.factionIndicatorScale = BetterBlizzPlatesDB.factionIndicatorScale or 1
        config.factionIndicatorTestMode = BetterBlizzPlatesDB.factionIndicatorTestMode
        config.factionIndicatorIconSet = BetterBlizzPlatesDB.factionIndicatorIconSet or 1
        config.factionIndicatorOnlyWorld = BetterBlizzPlatesDB.factionIndicatorOnlyWorld
        config.factionIndicatorOnlyPvPZone = BetterBlizzPlatesDB.factionIndicatorOnlyPvPZone

        config.factionIndicatorInitialized = true
    end

    local unit = frame.displayedUnit

    if not info.isPlayer and not config.factionIndicatorTestMode then
        if frame.factionIndicator then
            frame.factionIndicator:Hide()
        end
        return
    end

    if not config.factionIndicatorTestMode then
        if config.factionIndicatorOnlyPvPZone and not BBP.isInPvPZone then
            if frame.factionIndicator then
                frame.factionIndicator:Hide()
            end
            return
        elseif config.factionIndicatorOnlyWorld and not BBP.isInWorld then
            if frame.factionIndicator then
                frame.factionIndicator:Hide()
            end
            return
        end
    end

    local unitFaction = UnitFactionGroup(unit)

    local isSameFaction = (unitFaction == playerFaction)
    local shouldShow = false
    if isSameFaction and config.factionIndicatorFriendly then
        shouldShow = true
    elseif not isSameFaction and config.factionIndicatorEnemy then
        shouldShow = true
    end

    if not frame.factionIndicator then
        frame.factionIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
    end

    local iconSet = factionIconSets[config.factionIndicatorIconSet] or factionIconSets[1]
    local iconData = unitFaction and iconSet[unitFaction]
    local oppositeAnchor = BBP.GetOppositeAnchor(config.factionIndicatorAnchor)

    -- Test mode
    if config.factionIndicatorTestMode then
        local testFaction = (math.random(2) == 1) and "Horde" or "Alliance"
        local testData = iconSet[testFaction]
        ApplyFactionIcon(frame.factionIndicator, testData)
        frame.factionIndicator:ClearAllPoints()
        frame.factionIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.factionIndicatorAnchor, config.factionIndicatorXPos, config.factionIndicatorYPos)
        frame.factionIndicator:SetScale(config.factionIndicatorScale or 1)
        frame.factionIndicator:Show()
        return
    end

    if not shouldShow or not iconData then
        if frame.factionIndicator then
            frame.factionIndicator:Hide()
        end
        return
    end

    ApplyFactionIcon(frame.factionIndicator, iconData)
    frame.factionIndicator:ClearAllPoints()
    frame.factionIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.factionIndicatorAnchor, config.factionIndicatorXPos, config.factionIndicatorYPos)
    frame.factionIndicator:SetScale(config.factionIndicatorScale or 1)
    frame.factionIndicator:Show()
end