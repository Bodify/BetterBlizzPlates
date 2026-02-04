-- Healer spec id's
local HealerSpecs = {
    [105]  = true,  --> druid resto
    [270]  = true,  --> monk mw
    [65]   = true,  --> paladin holy
    [256]  = true,  --> priest disc
    [257]  = true,  --> priest holy
    [264]  = true,  --> shaman resto
    [1468] = true,  --> preservation evoker  
}

local ppTextures = {
    [1] = "UI-QuestPoiImportant-QuestNumber-SuperTracked",
    [2] = "CreditsScreen-Assets-Buttons-Rewind", --rotate
    [3] = "CovenantSanctum-Renown-DoubleArrow-Disabled", -- rotate
    [4] = "Crosshair_Quest_128",
    [5] = "Crosshair_Wrapper_128",
    [6] = "honorsystem-icon-prestige-2",
    [7] = "plunderstorm-glues-queueselector-solo-selected",
    [8] = "plunderstorm-glues-queueselector-solo",
    [9] = "AutoQuest-Badge-Campaign",
    [10] = "Ping_Marker_Icon_OnMyWay",
    [11] = "Ping_Marker_Icon_NonThreat",
    [12] = "charactercreate-icon-customize-body-selected",
    [13] = "128-RedButton-Delete",
}

local pointerOffsets = {
    [2] = 2,
    [5] = -2,
}

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local playerClass = select(2, UnitClass("player"))

-- Class Indicator
function BBP.PartyPointer(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)
    if not info then return end

    if not config.partyPointerInitialized or BBP.needsUpdate then
        config.partyPointerTestMode = BetterBlizzPlatesDB.partyPointerTestMode
        config.partyPointerArenaOnly = BetterBlizzPlatesDB.partyPointerArenaOnly
        config.partyPointerBgOnly = BetterBlizzPlatesDB.partyPointerBgOnly
        config.partyPointerHealer = BetterBlizzPlatesDB.partyPointerHealer
        config.partyPointerClassColor = BetterBlizzPlatesDB.partyPointerClassColor

        config.partyPointerAnchor = BetterBlizzPlatesDB.partyPointerAnchor
        config.partyPointerXPos = BetterBlizzPlatesDB.partyPointerXPos
        config.partyPointerYPos = BetterBlizzPlatesDB.partyPointerYPos
        config.partyPointerScale = BetterBlizzPlatesDB.partyPointerScale
        config.partyPointerHealerScale = BetterBlizzPlatesDB.partyPointerHealerScale
        config.partyPointerHideRaidmarker = BetterBlizzPlatesDB.partyPointerHideRaidmarker
        config.partyPointerWidth = BetterBlizzPlatesDB.partyPointerWidth
        config.partyPointerHealerReplace = BetterBlizzPlatesDB.partyPointerHealerReplace
        config.partyPointerTargetIndicator = BetterBlizzPlatesDB.partyPointerTargetIndicator
        config.partyPointerHideAll = BetterBlizzPlatesDB.partyPointerHideAll
        config.partyPointerHealerOnly = BetterBlizzPlatesDB.partyPointerHealerOnly
        config.partyPointerShowPet = BetterBlizzPlatesDB.partyPointerShowPet
        config.partyPointerAlwaysShowPet = BetterBlizzPlatesDB.partyPointerAlwaysShowPet
        config.partyPointerShowOthersPets = BetterBlizzPlatesDB.partyPointerShowOthersPets
        config.partyPointerOnlyParty = BetterBlizzPlatesDB.partyPointerOnlyParty
        config.partyPointerHighlight = BetterBlizzPlatesDB.partyPointerHighlight
        config.partyPointerHighlightRGB = BetterBlizzPlatesDB.partyPointerHighlightRGB
        config.partyPointerHighlightScale = BetterBlizzPlatesDB.partyPointerHighlightScale

        config.partyPointerInitialized = true
    end

    local partyOnly = config.partyPointerOnlyParty and not UnitInParty(frame.unit)

    local pointerMode = BetterBlizzPlatesDB.partyPointerTexture
    local xOffset = pointerOffsets[pointerMode] or 0
    local normalTexture = ppTextures[pointerMode]
    if pointerMode == 14 then
        normalTexture = BetterBlizzPlatesDB.partyPointerCustomTexture
    end

    local isPet = config.partyPointerShowPet and UnitIsUnit(frame.unit, "pet")
    local isPetAndAlwaysShow = config.partyPointerAlwaysShowPet and isPet
    local isOthersPet = config.partyPointerShowOthersPets and UnitIsOtherPlayersPet(frame.unit) and BBP.isInArena and info.isFriend


    if not info.isFriend or info.isNpc or info.isSelf or partyOnly then
        if isPet or isOthersPet or isPetAndAlwaysShow then
            --
        else
            if config.partyPointerHideRaidmarker then
                frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
            end
            if frame.partyPointer then
                frame.partyPointer:Hide()
            end
            if frame.ppChange then
                frame.hideNameOverride = nil
                frame.ppChange = nil
            end
            return
        end
    end

    -- Initialize Class Icon Frame
    if not frame.partyPointer then
        frame.partyPointer = CreateFrame("Frame", nil, frame)
        frame.partyPointer:SetFrameLevel(0)
        frame.partyPointer:SetSize(24, 24)
        frame.partyPointer.icon = frame.partyPointer:CreateTexture(nil, "BACKGROUND", nil, 1)
        frame.partyPointer.icon:SetAtlas(normalTexture)
        frame.partyPointer.icon:SetSize(34, 48)
        frame.partyPointer.icon:SetPoint("BOTTOM", frame.partyPointer, "BOTTOM", 0, 5)
        frame.partyPointer.icon:SetDesaturated(true)

        frame.partyPointer.highlight = frame.partyPointer:CreateTexture(nil, "BACKGROUND")
        frame.partyPointer.highlight:SetAtlas(normalTexture)
        frame.partyPointer.highlight:SetSize(55, 69)
        frame.partyPointer.highlight:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, -1)
        frame.partyPointer.highlight:SetDesaturated(true)
        frame.partyPointer.highlight:SetBlendMode("ADD")
        frame.partyPointer.highlight:SetVertexColor(1, 1, 0)
        frame.partyPointer.highlight:Hide()

        frame.partyPointer.healerIcon = frame.partyPointer:CreateTexture(nil, "BORDER")
        frame.partyPointer.healerIcon:SetAtlas("communities-chat-icon-plus")
        frame.partyPointer.healerIcon:SetSize(45, 45)
        frame.partyPointer.healerIcon:SetPoint("BOTTOM", frame.partyPointer.icon, "TOP", 0, -13)
        frame.partyPointer.healerIcon:SetDesaturated(true)
        frame.partyPointer.healerIcon:SetVertexColor(0,1,0)
        frame.partyPointer.healerIcon:Hide()

        frame.partyPointer:SetIgnoreParentAlpha(true)
        frame.partyPointer:SetFrameStrata("LOW")

        if not frame.classIndicatorCC then
            frame.classIndicatorCC = CreateFrame("Frame", nil, frame.partyPointer)
            frame.classIndicatorCC:SetSize(39, 39)
            frame.classIndicatorCC:SetFrameStrata("HIGH")
            frame.classIndicatorCC:Hide()

            frame.classIndicatorCC.Icon = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 6)
            frame.classIndicatorCC.Icon:SetPoint("CENTER", frame.partyPointer.icon)
            frame.classIndicatorCC.mask = frame.classIndicatorCC:CreateMaskTexture()
            frame.classIndicatorCC.mask:SetTexture("Interface/Masks/CircleMaskScalable")
            frame.classIndicatorCC.mask:SetSize(40, 40)
            frame.classIndicatorCC.mask:SetPoint("CENTER", frame.partyPointer.icon)
            frame.classIndicatorCC.Icon:AddMaskTexture(frame.classIndicatorCC.mask)
            frame.classIndicatorCC.Icon:SetSize(39, 39)

            frame.classIndicatorCC.Cooldown = CreateFrame("Cooldown", nil, frame.classIndicatorCC, "CooldownFrameTemplate")
            frame.classIndicatorCC.Cooldown:SetAllPoints(frame.classIndicatorCC.Icon)
            frame.classIndicatorCC.Cooldown:SetDrawEdge(false)
            frame.classIndicatorCC.Cooldown:SetDrawSwipe(true)
            frame.classIndicatorCC.Cooldown:SetSwipeColor(0, 0, 0, 0.7)
            frame.classIndicatorCC.Cooldown:SetSwipeTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
            frame.classIndicatorCC.Cooldown:SetUseCircularEdge(true)
            frame.classIndicatorCC.Cooldown:SetReverse(true)

            frame.classIndicatorCC.Glow = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 7)
            frame.classIndicatorCC.Glow:SetAtlas("charactercreate-ring-select")
            frame.classIndicatorCC.Glow:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, 0)
            frame.classIndicatorCC.Glow:SetDesaturated(true)
            frame.classIndicatorCC.Glow:SetSize(54,54)
            frame.classIndicatorCC.Glow:SetDrawLayer("OVERLAY", 7)
        end
    end
    frame.partyPointer.icon:SetAtlas(normalTexture)
    frame.partyPointer:SetAlpha(1)


    if pointerMode == 2 or pointerMode == 3 then
        frame.partyPointer.icon:SetRotation(math.rad(90))
    else
        frame.partyPointer.icon:SetRotation(0)
    end

    local class = info.class or playerClass
    if isOthersPet and not BBP.isMidnight then
        for i = 1, 2 do
            local partyPet = "partypet"..i
            if UnitExists(partyPet) and UnitIsUnit(partyPet, frame.unit) then
                local _, partyClass = UnitClass("party"..i)
                if partyClass then
                    class = partyClass
                end
                break
            end
        end
    end

    -- Enhanced Test Mode: Use local test variables
    if config.partyPointerTestMode then
        local testIsTarget = math.random(0, 1) == 1
        local testSpecID = math.random(0, 1) == 1 and 105 or 71
        frame.partyPointer:Show()

        if HealerSpecs[testSpecID] then
            frame.partyPointer.healerIcon:Show()
            if config.partyPointerHealerReplace then
                frame.partyPointer.healerIcon:ClearAllPoints()
                frame.partyPointer.healerIcon:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, 0)
                frame.partyPointer.icon:Hide()
            else
               frame.partyPointer.healerIcon:ClearAllPoints()
               frame.partyPointer.healerIcon:SetPoint("BOTTOM", frame.partyPointer.icon, "TOP", 0, -13)
               frame.partyPointer.healerIcon:SetSize(45, 45)
               frame.partyPointer.icon:Show()
            end
        else
            frame.partyPointer.healerIcon:Hide()
            if config.partyPointerHealerReplace then
                frame.partyPointer.icon:Show()
            end
        end

        frame.partyPointer:SetScale(config.partyPointerScale or 1)
        frame.partyPointer.icon:SetWidth(config.partyPointerWidth)
        frame.partyPointer.healerIcon:SetScale(config.partyPointerHealerScale or 1)

        if config.partyPointerAnchor == "TOP" then
            frame.partyPointer:SetPoint("BOTTOM", frame.name, config.partyPointerAnchor, config.partyPointerXPos+xOffset, config.partyPointerYPos - 5)
        else
            frame.partyPointer:SetPoint("BOTTOM", frame.healthBar, config.partyPointerAnchor, config.partyPointerXPos+xOffset, config.partyPointerYPos)
        end

        if config.partyPointerClassColor then
            local classColor = RAID_CLASS_COLORS[class]
            local r, g, b = classColor.r, classColor.g, classColor.b

            if isOthersPet then
                r, g, b = r * 0.5, g * 0.5, b * 0.5
            end

            frame.partyPointer.icon:SetVertexColor(r, g, b)
        else
            frame.partyPointer.icon:SetVertexColor(0.04, 0.76, 1)
        end

        if config.partyPointerTargetIndicator and pointerMode == 1 then
            if testIsTarget then
                frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestBang")
            else
                frame.partyPointer.icon:SetAtlas(normalTexture)
            end
        else
            frame.partyPointer.icon:SetAtlas(normalTexture)
        end

        if config.partyPointerHideRaidmarker then
            frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
        end

        if config.partyPointerHealerOnly then
            if not HealerSpecs[testSpecID] then
                frame.partyPointer.icon:Hide()
            end
        end

        return
    end

    frame.partyPointer:SetScale(config.partyPointerScale or 1)
    frame.partyPointer.icon:SetWidth(config.partyPointerWidth)
    frame.partyPointer.highlight:SetWidth(config.partyPointerWidth + 26)
    frame.partyPointer.healerIcon:SetScale(config.partyPointerHealerScale or 1)

    -- Visibility checks
    if ((config.partyPointerArenaOnly and not BBP.isInArena) or (config.partyPointerBgOnly and not BBP.isInBg)) and not config.partyPointerTestMode then
        if not ((config.partyPointerArenaOnly and config.partyPointerBgOnly) and (BBP.isInArena or BBP.isInBg)) then
            frame.partyPointer:Hide()
            if config.partyPointerHideRaidmarker then
                if not config.hideRaidmarkIndicator then
                    frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
                end
            end
            return
        end
    end

    if config.partyPointerAnchor == "TOP" and ShouldShowName(frame) then --isMidnight ShouldShowName == secret?
        local resourceAnchor = nil
        if config.nameplateResourceOnTarget == "1" and not config.nameplateResourceUnderCastbar and info.isTarget and not (BetterBlizzPlatesDB.hideResourceOnFriend and info.isFriend) then
            resourceAnchor = frame:GetParent().driverFrame.classNamePlateMechanicFrame
        end

        local arenaPoint = nil
        if BBP.isInArena or BetterBlizzPlatesDB.arenaIndicatorTestMode then
            local db = BetterBlizzPlatesDB
            if db.partyIndicatorModeOne then
                arenaPoint = frame.arenaNumberText
            elseif db.partyIndicatorModeTwo then
                arenaPoint = frame.arenaNumberText
            elseif db.partyIndicatorModeThree then
                arenaPoint = frame.specNameText
            elseif db.partyIndicatorModeFour then
                arenaPoint = frame.arenaNumberText
            elseif db.partyIndicatorModeFive then
                arenaPoint = frame.specNameText
            end
        end

        local anchorPoint = resourceAnchor or arenaPoint or frame.name

        frame.partyPointer:SetPoint("BOTTOM", anchorPoint, config.partyPointerAnchor, config.partyPointerXPos+xOffset, config.partyPointerYPos -5)
    else
        frame.partyPointer:SetPoint("BOTTOM", frame.healthBar, config.partyPointerAnchor, config.partyPointerXPos+xOffset, config.partyPointerYPos)
    end

    if config.partyPointerClassColor then
        local classColor = RAID_CLASS_COLORS[class]
        local r, g, b = classColor.r, classColor.g, classColor.b

        if isOthersPet then
            r, g, b = r * 0.5, g * 0.5, b * 0.5
            frame.partyPointer:SetScale(config.partyPointerScale * 0.6)
        end

        frame.partyPointer.icon:SetVertexColor(r, g, b)
    else
        frame.partyPointer.icon:SetVertexColor(0.04, 0.76, 1)
    end

    if config.partyPointerTargetIndicator and pointerMode == 1 then
        if info.isTarget then
            frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestBang")
        else
            frame.partyPointer.icon:SetAtlas(normalTexture)
        end
    end

    if config.partyPointerHighlight then
        frame.partyPointer.highlight:SetScale((isOthersPet and config.partyPointerHighlightScale * 0.6) or config.partyPointerHighlightScale)
        frame.partyPointer.highlight:SetVertexColor(unpack(config.partyPointerHighlightRGB))
        if info.isTarget then
            frame.partyPointer.highlight:Show()
        else
            frame.partyPointer.highlight:Hide()
        end
    end

    -- Check for Healer Only Mode
    local specID = BBP.GetSpecID(frame)

    if config.partyPointerHealerOnly then
        if not HealerSpecs[specID] then
            frame.partyPointer:Hide()
            return
        end
    end

    if config.partyPointerHealer then
        if HealerSpecs[specID] then
            frame.partyPointer.healerIcon:Show()
            if config.partyPointerHealerReplace then
                frame.partyPointer.healerIcon:ClearAllPoints()
                frame.partyPointer.healerIcon:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, 0)
                frame.partyPointer.icon:Hide()
            end
        else
            frame.partyPointer.healerIcon:Hide()
            if config.partyPointerHealerReplace then
                frame.partyPointer.icon:Show()
            end
        end
    else
        frame.partyPointer.healerIcon:Hide()
    end
    frame.partyPointer:Show()
    if config.partyPointerHideRaidmarker then
        frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
    end

    if config.partyPointerHideAll then
        frame.HealthBarsContainer:SetAlpha(0)
        frame.selectionHighlight:SetAlpha(0)
        frame.hideNameOverride = true
        frame.name:SetAlpha(0)
        BBP.hideFriendlyCastbar = true
        frame.ppChange = true
    elseif frame.ppChange then
        frame.HealthBarsContainer:SetAlpha(1)
        frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or 0.22)
        frame.hideNameOverride = nil
        if not config.hideFriendlyNameText then
            frame.name:SetAlpha(1)
        end
        BBP.hideFriendlyCastbar = nil
        frame.ppChange = nil
    end
end