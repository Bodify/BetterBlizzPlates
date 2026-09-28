local playerFaction = UnitFactionGroup("player")

local factionIconSets = {
    [1] = {
        ["Alliance"] = { atlas = "questlog-questtypeicon-alliance", width = 24, height = 24 },
        ["Horde"]    = { atlas = "questlog-questtypeicon-horde", width = 22, height = 22 },
    },
    [2] = {
        ["Alliance"] = { atlas = "UI-HUD-UnitFrame-Player-PVP-AllianceIcon", width = 16, height = 24 },
        ["Horde"]    = { atlas = "UI-HUD-UnitFrame-Player-PVP-HordeIcon", width = 24, height = 24 },
    },
    [3] = {
        ["Horde"]    = { texture = "Interface\\Icons\\Inv_BannerPVP_01", width = 24, height = 24 },
        ["Alliance"] = { texture = "Interface\\Icons\\Inv_BannerPVP_02", width = 24, height = 24 },
    },
    [4] = {
        ["Alliance"] = { atlas = "bfa-landingbutton-alliance-up", width = 22, height = 24 },
        ["Horde"]    = { atlas = "bfa-landingbutton-horde-up", width = 21, height = 24 },
    },
    [5] = {
        ["Alliance"] = { atlas = "talenttree-alliance-cornerlogo", width = 21, height = 24 },
        ["Horde"]    = { atlas = "talenttree-horde-cornerlogo", width = 21, height = 24 },
    },
    [6] = {
        ["Alliance"] = { atlas = "ctf_flags-leftIcon1-state1", width = 24, height = 24 },
        ["Horde"]    = { atlas = "ctf_flags-rightIcon1-state1", width = 24, height = 24 },
    },
    [7] = {
        ["Alliance"] = { atlas = "QuestPortraitIcon-Alliance", width = 21, height = 24 },
        ["Horde"]    = { atlas = "QuestPortraitIcon-Horde", width = 21, height = 24 },
    },
    [8] = {
        ["Alliance"] = { atlas = "QuestPortraitIcon-Alliance-small", width = 22, height = 24 },
        ["Horde"]    = { atlas = "QuestPortraitIcon-Horde-small", width = 21, height = 24 },
    },
    [9] = {
        ["Alliance"] = { atlas = "charcreatetest-logo-alliance", width = 20, height = 24 },
        ["Horde"]    = { atlas = "charcreatetest-logo-horde", width = 20, height = 24 },
    },
    [10] = {
        ["Alliance"] = { atlas = "charactercreate-icon-alliance", width = 24, height = 26 },
        ["Horde"]    = { atlas = "charactercreate-icon-horde", width = 24, height = 26 },
    },
    [11] = {
        ["Alliance"] = { atlas = "Warfronts-BaseMapIcons-Alliance-Armory", width = 24, height = 23 },
        ["Horde"]    = { atlas = "Warfronts-BaseMapIcons-Horde-Armory", width = 24, height = 23 },
    },
    [12] = {
        ["Alliance"] = { atlas = "Quest-Alliance-WaxSeal", width = 24, height = 22 },
        ["Horde"]    = { atlas = "Quest-Horde-WaxSeal", width = 24, height = 22 },
    },
    [13] = {
        ["Alliance"] = { atlas = "communities-create-button-wow-alliance", width = 22, height = 28 },
        ["Horde"]    = { atlas = "communities-create-button-wow-horde", width = 22, height = 28 },
    },
    [14] = {
        ["Alliance"] = { atlas = "poi-alliance", width = 32, height = 32 },
        ["Horde"]    = { atlas = "poi-horde", width = 32, height = 32 },
    },
    [15] = {
        ["Alliance"] = { atlas = "horde_icon_alliance_flag-dynamicIcon", width = 32, height = 32 },
        ["Horde"]    = { atlas = "horde_icon_and_flag-dynamicIcon", width = 32, height = 32 },
    },
}

function BBP.IsFactionIconSetAvailable(index)
    local iconData = factionIconSets[index] and factionIconSets[index]["Alliance"]
    return iconData and (not iconData.atlas or C_Texture.GetAtlasInfo(iconData.atlas)) and true or false
end

local function ApplyFactionIcon(texture, iconData, faction)
    if not iconData then return false end
    if iconData.atlas and not C_Texture.GetAtlasInfo(iconData.atlas) then
        iconData = factionIconSets[3][faction]
    end
    if iconData.atlas then
        texture:SetAtlas(iconData.atlas)
    else
        texture:SetTexture(iconData.texture)
    end
    texture:SetSize(iconData.width, iconData.height)
    return true
end

local function IsHostile(unit)
    local reaction = UnitReaction(unit, "player")
    return reaction and reaction <= 4
end

local function IsPvPTagged(unit)
    return UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit)
end

function BBP.FactionIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.factionIndicatorInitialized or BBP.needsUpdate then
        config.factionIndicatorEnemy = BetterBlizzPlatesDB.factionIndicatorEnemy
        config.factionIndicatorFriendly = BetterBlizzPlatesDB.factionIndicatorFriendly
        config.factionIndicatorAnchor = BetterBlizzPlatesDB.factionIndicatorAnchor or "LEFT"
        config.factionIndicatorXPos = BetterBlizzPlatesDB.factionIndicatorXPos or -5
        config.factionIndicatorYPos = BetterBlizzPlatesDB.factionIndicatorYPos or 0
        config.factionIndicatorScale = BetterBlizzPlatesDB.factionIndicatorScale or 0.7
        config.factionIndicatorTestMode = BetterBlizzPlatesDB.factionIndicatorTestMode
        config.factionIndicatorIconSet = BetterBlizzPlatesDB.factionIndicatorIconSet or 13
        config.factionIndicatorOnlyWorld = BetterBlizzPlatesDB.factionIndicatorOnlyWorld
        config.factionIndicatorOnlyPvPZone = BetterBlizzPlatesDB.factionIndicatorOnlyPvPZone
        config.factionIndicatorHostileOnly = BetterBlizzPlatesDB.factionIndicatorHostileOnly
        config.factionIndicatorPvPTaggedOnly = BetterBlizzPlatesDB.factionIndicatorPvPTaggedOnly

        config.factionIndicatorInitialized = true
    end

    local unit = frame.displayedUnit or frame.unit
    if not unit or not info then return end

    if not info.isPlayer and not config.factionIndicatorTestMode then
        if frame.factionIndicator then
            frame.factionIndicator:Hide()
        end
        return
    end

    if not config.factionIndicatorTestMode then
        if (config.factionIndicatorHostileOnly and not IsHostile(unit))
            or (config.factionIndicatorPvPTaggedOnly and not IsPvPTagged(unit))
            or (config.factionIndicatorOnlyPvPZone and not BBP.isInPvPZone)
            or (not config.factionIndicatorOnlyPvPZone and config.factionIndicatorOnlyWorld and not BBP.isInWorld) then
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

    local iconSet = factionIconSets[config.factionIndicatorIconSet] or factionIconSets[13]
    local oppositeAnchor = BBP.GetOppositeAnchor(config.factionIndicatorAnchor)

    if config.factionIndicatorTestMode then
        local testFaction = (math.random(2) == 1) and "Horde" or "Alliance"
        ApplyFactionIcon(frame.factionIndicator, iconSet[testFaction], testFaction)
        frame.factionIndicator:ClearAllPoints()
        frame.factionIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.factionIndicatorAnchor, config.factionIndicatorXPos, config.factionIndicatorYPos)
        frame.factionIndicator:SetScale(config.factionIndicatorScale or 1)
        frame.factionIndicator:Show()
        return
    end

    local iconData = unitFaction and iconSet[unitFaction]
    if not shouldShow or not iconData then
        frame.factionIndicator:Hide()
        return
    end

    ApplyFactionIcon(frame.factionIndicator, iconData, unitFaction)
    frame.factionIndicator:ClearAllPoints()
    frame.factionIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.factionIndicatorAnchor, config.factionIndicatorXPos, config.factionIndicatorYPos)
    frame.factionIndicator:SetScale(config.factionIndicatorScale or 1)
    frame.factionIndicator:Show()
end

function BBP.ToggleFactionIndicator()
    if BetterBlizzPlatesDB.factionIndicator then
        if not BBP.FactionIndicatorEvent then
            BBP.FactionIndicatorEvent = CreateFrame("Frame")
            BBP.FactionIndicatorEvent:SetScript("OnEvent", function(self, event, unit)
                local nameplate, frame = BBP.GetSafeNameplate(unit)
                if frame and frame.BetterBlizzPlates and frame.bbpOverlay then
                    BBP.FactionIndicator(frame)
                end
            end)
        end
        BBP.FactionIndicatorEvent:RegisterEvent("UNIT_FACTION")
    elseif BBP.FactionIndicatorEvent then
        BBP.FactionIndicatorEvent:UnregisterEvent("UNIT_FACTION")
    end
end
