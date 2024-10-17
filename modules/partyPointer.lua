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

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- Class Indicator
function BBP.PartyPointer(frame, fetchedSpecID)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)
    if not info then return end

    if not info.isFriend or info.isNpc or info.isSelf then
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

        config.partyPointerInitialized = true
    end

    -- Initialize Class Icon Frame
    if not frame.partyPointer then
        frame.partyPointer = CreateFrame("Frame", nil, frame)
        frame.partyPointer:SetFrameLevel(0)
        frame.partyPointer:SetSize(24, 24)
        frame.partyPointer.icon = frame.partyPointer:CreateTexture(nil, "BACKGROUND")
        frame.partyPointer.icon:SetPoint("CENTER", frame.partyPointer)
        frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
        frame.partyPointer.icon:SetSize(34, 48)
        frame.partyPointer.icon:SetPoint("BOTTOM", frame.partyPointer, "BOTTOM", 0, 5)
        frame.partyPointer.icon:SetDesaturated(true)

        frame.partyPointer.healerIcon = frame.partyPointer:CreateTexture(nil, "BORDER")
        frame.partyPointer.healerIcon:SetPoint("CENTER", frame.partyPointer)
        frame.partyPointer.healerIcon:SetAtlas("communities-chat-icon-plus")
        frame.partyPointer.healerIcon:SetSize(45, 45)
        frame.partyPointer.healerIcon:SetPoint("BOTTOM", frame.partyPointer.icon, "TOP", 0, -13)
        frame.partyPointer.healerIcon:SetDesaturated(true)
        frame.partyPointer.healerIcon:SetVertexColor(0,1,0)
        frame.partyPointer.healerIcon:Hide()

        frame.partyPointer:SetFrameStrata("MEDIUM")
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
            frame.partyPointer:SetPoint("BOTTOM", frame.name, config.partyPointerAnchor, config.partyPointerXPos, config.partyPointerYPos - 5)
        else
            frame.partyPointer:SetPoint("BOTTOM", frame.healthBar, config.partyPointerAnchor, config.partyPointerXPos, config.partyPointerYPos)
        end

        if config.partyPointerClassColor then
            local classColor = RAID_CLASS_COLORS[info.class]
            frame.partyPointer.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
        else
            frame.partyPointer.icon:SetVertexColor(0.04, 0.76, 1)
        end

        if config.partyPointerTargetIndicator then
            if testIsTarget then
                frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestBang")
            else
                frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
            end
        else
            frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
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

    if config.partyPointerAnchor == "TOP" and ShouldShowName(frame) then
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

        frame.partyPointer:SetPoint("BOTTOM", anchorPoint, config.partyPointerAnchor, config.partyPointerXPos, config.partyPointerYPos -5)
    else
        frame.partyPointer:SetPoint("BOTTOM", frame.healthBar, config.partyPointerAnchor, config.partyPointerXPos, config.partyPointerYPos)
    end

    if config.partyPointerClassColor then
        local classColor = RAID_CLASS_COLORS[info.class]
        frame.partyPointer.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
    else
        frame.partyPointer.icon:SetVertexColor(0.04, 0.76, 1)
    end

    if config.partyPointerTargetIndicator then
        if info.isTarget then
            frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestBang")
        else
            frame.partyPointer.icon:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
        end
    end

    -- Check for Healer Only Mode
    local specID = fetchedSpecID
    local Details = Details
    if not specID and Details then
        specID = Details:GetSpecByGUID(info.unitGUID)
    end

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