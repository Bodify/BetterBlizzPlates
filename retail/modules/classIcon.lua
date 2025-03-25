-- Healer spec id's
local HealerSpecs = {
    [105] = true, --> druid resto
    [270] = true, --> monk mw
    [65] = true, --> paladin holy
    [256] = true, --> priest disc
    [257] = true, --> priest holy
    [264] = true, --> shaman resto
    [1468] = true --> preservation evoker
}

local TankSpecs = {
    [250] = true, --> Death Knight Blood
    [581] = true, --> Demon Hunter Vengeance
    [104] = true, --> Druid Guardian
    [268] = true, --> Monk Brewmaster
    [66] = true, --> Paladin Protection
    [73] = true --> Warrior Protection
}

local icons = {
    [121177] = 1119887, -- Red orb
    [121176] = 1119886, -- Green orb
    [121164] = 1119885, -- Blue orb
    [121175] = 1119888, -- Purple orb
    [156621] = 132486, -- Alliance Flag
    [156618] = 132485, -- Horde Flag
    [34976] = 132487, -- Netherstorm Flag
    [434339] = 463896, -- Deephaul Ravine Crystal
    [168506] = 134334, -- Ancient Artifact (Ashran)
    [231813] = 1567722, -- Green Dunkball (Brawl)
    [231814] = 1545374, -- Orange Dunkball (Brawl)
    [231529] = 1567723 -- Purple Dunkball (Brawl)
}
BBP.ClassIndicatorIcons = icons

local bgsWithObjectives = {
    [489] = true, -- Warsong Gulch
    [2106] = true, -- Warsong Gulch 2
    [566] = true, -- Eye of the Storm
    [968] = true, -- Eye of the Storm Rated
    [998] = true, -- Temple of Kotmogu
    [2656] = true, --Deephaul Ravine
    [1191] = true, -- Ashran
    [2245] = true, -- Deepwind Gorge
    [1105] = true, -- Deepwind Gorge Brawl
    [726] = true, -- Twin Peaks
}

local classIconNames = {}
BBP.classIconNames = classIconNames

local function GetAuraIcon(frame, foundID, auraType, bgId)
    -- If `foundID` exists in the table, return its color immediately
    if foundID and icons[foundID] then
        return icons[foundID]
    end

    if UnitPvpClassification(frame.unit) then
        if bgId == 2656 then
            return icons[434339]
        elseif bgId == 566 or bgId == 968 then
            return icons[34976]
        else
            -- Otherwise, scan buffs/debuffs based on `auraType`
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, spellID = BBP.TWWUnitAura(frame.unit, i, auraType or "HARMFUL")
                if not spellID then
                    break
                end
                if spellID and icons[spellID] then
                    return icons[spellID]
                end
            end
        end
    end

    return nil -- No matching aura found
end

local function BackgroundType(frame, bg)
    if frame.classIndicator.border.square then
        bg:SetAtlas("mountequipment-slot-background")
        bg:SetSize(28, 28)
    else
        bg:SetAtlas("talents-node-choiceflyout-circle-greenglow")
        local size = UnitIsUnit(frame.unit, "target") and 39 or 36
        bg:SetSize(size, size)
    end
end

-- Class Indicator
function BBP.ClassIndicator(frame, foundID)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.classIndicatorInitialized or BBP.needsUpdate then
        config.classIconArenaOnly = BetterBlizzPlatesDB.classIconArenaOnly
        config.classIconBgOnly = BetterBlizzPlatesDB.classIconBgOnly
        config.classIndicatorFriendly = BetterBlizzPlatesDB.classIndicatorFriendly
        config.classIndicatorEnemy = BetterBlizzPlatesDB.classIndicatorEnemy
        config.classIndicatorSpecIcon = BetterBlizzPlatesDB.classIndicatorSpecIcon
        config.classIndicatorHealer = BetterBlizzPlatesDB.classIndicatorHealer
        config.classIconSquareBorder = BetterBlizzPlatesDB.classIconSquareBorder
        config.classIconSquareBorderFriendly = BetterBlizzPlatesDB.classIconSquareBorderFriendly
        config.classIndicatorHighlight = BetterBlizzPlatesDB.classIndicatorHighlight
        config.classIndicatorHighlightColor = BetterBlizzPlatesDB.classIndicatorHighlightColor
        config.classIndicatorHideRaidMarker = BetterBlizzPlatesDB.classIndicatorHideRaidMarker
        config.classIndicatorAnchor = BetterBlizzPlatesDB.classIndicatorAnchor
        config.classIndicatorXPos = BetterBlizzPlatesDB.classIndicatorXPos
        config.classIndicatorYPos = BetterBlizzPlatesDB.classIndicatorYPos
        config.classIndicatorScale = BetterBlizzPlatesDB.classIndicatorScale
        config.classIndicatorFriendlyAnchor = BetterBlizzPlatesDB.classIndicatorFriendlyAnchor
        config.classIndicatorFriendlyXPos = BetterBlizzPlatesDB.classIndicatorFriendlyXPos
        config.classIndicatorFriendlyYPos = BetterBlizzPlatesDB.classIndicatorFriendlyYPos
        config.classIndicatorFriendlyScale = BetterBlizzPlatesDB.classIndicatorFriendlyScale
        config.classIconColorBorder = BetterBlizzPlatesDB.classIconColorBorder
        config.classIconReactionBorder = BetterBlizzPlatesDB.classIconReactionBorder
        config.nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar
        config.hideResourceOnFriend = BetterBlizzPlatesDB.hideResourceOnFriend
        config.classIndicatorAlpha = BetterBlizzPlatesDB.classIndicatorAlpha
        config.classIconHealthNumbers = BetterBlizzPlatesDB.classIconHealthNumbers
        config.classIndicatorFrameStrataHigh = BetterBlizzPlatesDB.classIndicatorFrameStrataHigh
        config.classIconEnemyHealIcon = BetterBlizzPlatesDB.classIconEnemyHealIcon
        config.classIconAlwaysShowBgObj = BetterBlizzPlatesDB.classIconAlwaysShowBgObj
        config.classIndicatorTank = BetterBlizzPlatesDB.classIndicatorTank
        config.classIconAlwaysShowHealer = BetterBlizzPlatesDB.classIconAlwaysShowHealer
        config.classIconAlwaysShowTank = BetterBlizzPlatesDB.classIconAlwaysShowTank
        config.classIndicatorHideName = BetterBlizzPlatesDB.classIndicatorHideName
        config.classIndicatorOnlyHealer = BetterBlizzPlatesDB.classIndicatorOnlyHealer
        config.classIndicatorBackground = BetterBlizzPlatesDB.classIndicatorBackground
        config.classIndicatorBackgroundClassColor = BetterBlizzPlatesDB.classIndicatorBackgroundClassColor
        config.classIndicatorBackgroundRGB = BetterBlizzPlatesDB.classIndicatorBackgroundRGB
        config.classIndicatorBackgroundSize = BetterBlizzPlatesDB.classIndicatorBackgroundSize
        config.classIndicatorPinMode = BetterBlizzPlatesDB.classIndicatorPinMode

        config.classIndicatorInitialized = true
    end

    frame.classIndicatorHideNumbers = nil

    if not info.class then
        if config.classIndicatorHideRaidMarker then
            frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
        end
        if frame.classIndicator then
            frame.classIndicator:Hide()
            frame.classIndicatorHideNumbers = true
        end
        return
    end

    if UnitIsUnit(frame.unit, "player") then
        if frame.classIndicator then
            frame.classIndicator:Hide()
        end
        return
    end

    local anchorPoint =
        (info.isFriend and config.classIndicatorFriendlyAnchor) or
        ((info.isEnemy or info.isNeutral) and config.classIndicatorAnchor)
    local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
    local xPos =
        (info.isFriend and config.classIndicatorFriendlyXPos) or
        ((info.isEnemy or info.isNeutral) and config.classIndicatorXPos) or
        0
    local yPos =
        (info.isFriend and config.classIndicatorFriendlyYPos + (anchorPoint == "TOP" and 2 or 0)) or
        ((info.isEnemy or info.isNeutral) and config.classIndicatorYPos + (anchorPoint == "TOP" and 2 or 0)) or
        0
    local scale =
        (info.isFriend and config.classIndicatorFriendlyScale + 0.3) or
        ((info.isEnemy or info.isNeutral) and config.classIndicatorScale + 0.3) or
        1
    local enabledOnThisUnit =
        (info.isFriend and config.classIndicatorFriendly) or (not info.isFriend and config.classIndicatorEnemy)

    -- Initialize Class Icon Frame
    if not frame.classIndicator then
        frame.classIndicator = CreateFrame("Frame", nil, frame)
        frame.classIndicator:HookScript("OnHide", function()
            frame.classIndicatorHideName = false
        end)
        frame.classIndicator:SetSize(24, 24)
        --frame.classIndicator:SetScale(scale)
        frame.classIndicator.icon = frame.classIndicator:CreateTexture(nil, "BORDER")
        frame.classIndicator.icon:SetPoint("CENTER", frame.classIndicator)
        frame.classIndicator.mask = frame.classIndicator:CreateMaskTexture()
        frame.classIndicator.icon:AddMaskTexture(frame.classIndicator.mask)
        frame.classIndicator.border = frame.classIndicator:CreateTexture(nil, "OVERLAY", nil, 6)
        frame.classIndicator:SetIgnoreParentAlpha(true)
    end
    frame.classIndicator:SetFrameStrata(config.classIndicatorFrameStrataHigh and "HIGH" or "LOW")
    frame.classIndicator:SetAlpha(config.classIndicatorAlpha)

    if (config.classIndicatorHighlight or config.classIndicatorHighlightColor) and not frame.classIndicator.highlightSelect then
        frame.classIndicator.highlightSelect = frame.classIndicator:CreateTexture(nil, "OVERLAY")
        frame.classIndicator.highlightSelect:SetAtlas("charactercreate-ring-select")
        frame.classIndicator.highlightSelect:Hide()
        frame.classIndicator.highlightSelect:SetPoint("CENTER", frame.classIndicator, "CENTER", 0, 0)
        frame.classIndicator.highlightSelect:SetSize(33, 33)
        frame.classIndicator.highlightSelect:SetDrawLayer("OVERLAY", 7)
    end

    local flagIcon
    if BBP.isInBg and (enabledOnThisUnit or config.classIconAlwaysShowBgObj) then
        local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
        if bgsWithObjectives[instanceMapID] then
            local auraType = (instanceMapID == 998 and "HARMFUL") or "HELPFUL"
            flagIcon = GetAuraIcon(frame, foundID, auraType, instanceMapID)
        end
    end

    local specIcon
    local specID = BBP.GetSpecID(frame)
    if config.classIndicatorSpecIcon or config.classIndicatorHealer then
        if specID then
            specIcon = select(4, GetSpecializationInfoByID(specID))
        end
    end

    local isTank = config.classIndicatorTank and TankSpecs[specID]
    local alwaysShowTank = config.classIconAlwaysShowTank and TankSpecs[specID]
    local alwaysShowHealer = config.classIconAlwaysShowHealer and HealerSpecs[specID]
    local isHealer = HealerSpecs[specID]
    local shouldHide = not enabledOnThisUnit and not flagIcon and not alwaysShowHealer and not alwaysShowTank

    if shouldHide or (config.classIndicatorOnlyHealer and not isHealer and not flagIcon and not alwaysShowHealer and not alwaysShowTank) then
        frame.classIndicator:Hide()
        return
    end

    frame.classIndicator.icon:SetPoint("CENTER", frame.classIndicator)
    frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)

    local function SetBorderType()
        local function Square()
            if frame.classIndicator.border.square then
                return
            end
            frame.classIndicator.icon:SetSize(20, 20)
            frame.classIndicator.mask:SetAtlas("UI-Frame-IconMask")
            frame.classIndicator.mask:SetSize(20, 20)
            frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicator.border:SetTexture(
                "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-ActionBar-IconFrame-AddRow-Light"
            )
            frame.classIndicator.border:SetSize(29, 29)
            frame.classIndicator.border:ClearAllPoints()
            frame.classIndicator.border:SetPoint("CENTER", frame.classIndicator.icon, 1.5, -1.5)
            frame.classIndicator.border.square = true
            frame.classIndicator.border.circle = false
            ------
            ------
            if frame.classIndicator.highlightSelect then
                frame.classIndicator.highlightSelect:SetSize(36, 36)
                frame.classIndicator.highlightSelect:SetAtlas("newplayertutorial-drag-slotblue")
                frame.classIndicator.highlightSelect:SetDesaturated(true)
                frame.classIndicator.highlightSelect:SetVertexColor(1, 0.88, 0)
            end
        end
        local function Circle()
            if frame.classIndicator.border.circle then
                return
            end
            frame.classIndicator.icon:SetSize(22, 22)
            frame.classIndicator.mask:SetTexture("Interface/Masks/CircleMaskScalable")
            frame.classIndicator.mask:SetSize(22, 22)
            frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicator.border:SetAtlas("AutoQuest-badgeborder")
            frame.classIndicator.border:SetAllPoints(frame.classIndicator)
            frame.classIndicator.border.square = false
            frame.classIndicator.border.circle = true
            ------
            ------
            if frame.classIndicator.highlightSelect then
                frame.classIndicator.highlightSelect:SetDesaturated(false)
                frame.classIndicator.highlightSelect:SetSize(33, 33)
                frame.classIndicator.highlightSelect:SetAtlas("charactercreate-ring-select")
                frame.classIndicator.highlightSelect:SetVertexColor(1, 0.88, 0)
            end
        end

        if info.isFriend then
            if config.classIconSquareBorderFriendly then
                Square()
            else
                Circle()
            end
        else
            if config.classIconSquareBorder then
                Square()
            else
                Circle()
            end
        end
    end

    SetBorderType()
    if frame.classIndicator.highlightSelect or config.classIndicatorHighlightColor then
        if info.isTarget then
            BBP.ClassIndicatorTargetHighlight(frame)
        else
            frame.classIndicator.highlightSelect:Hide()
            frame.classIndicator.border:Show()
        end
    end

    frame.classIndicator:ClearAllPoints()
    if anchorPoint == "TOP" then
        local resourceAnchor = nil
        if
            config.nameplateResourceOnTarget == "1" and not config.nameplateResourceUnderCastbar and info.isTarget and
                not (config.hideResourceOnFriend and info.isFriend)
         then
            resourceAnchor = frame:GetParent().driverFrame.classNamePlateMechanicFrame
        end
        frame.classIndicator:SetPoint(oppositeAnchor, resourceAnchor or frame.name, anchorPoint, xPos, yPos)
    else
        frame.classIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos, yPos)
    end
    frame.classIndicator:SetScale(flagIcon and scale + 0.15 or scale)

    -- Visibility checks
    if ((config.classIconArenaOnly and not BBP.isInArena) or (config.classIconBgOnly and not BBP.isInBg)) and not( config.classIconAlwaysShowBgObj and flagIcon) then
        if config.classIconArenaOnly and config.classIconBgOnly then
            if not BBP.isInPvP then
                frame.classIndicator:Hide()
                return
            end
        else
            frame.classIndicator:Hide()
            return
        end
    end

    frame.classIndicator.icon:SetDesaturated(false)
    frame.classIndicator.icon:SetVertexColor(1, 1, 1)

    -- -- Get class icon texture and coordinates
    -- local classIcon = "Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES"
    local classAtlas = "classicon-" .. string.lower(info.class)
    local classColor = RAID_CLASS_COLORS[info.class]
    if config.classIndicatorBackground then
        if not frame.classIndicator.bg then
            frame.classIndicator.bg = frame.classIndicator:CreateTexture(nil, "BACKGROUND", nil, 1)
            frame.classIndicator.bg:SetPoint("CENTER", frame.classIndicator)
            frame.classIndicator.bg:SetDesaturated(true)
        end
        frame.classIndicator.bg:Show()
        if config.classIndicatorBackgroundClassColor then
            frame.classIndicator.bg:SetVertexColor(classColor.r, classColor.g, classColor.b)
        else
            frame.classIndicator.bg:SetVertexColor(unpack(config.classIndicatorBackgroundRGB))
        end
        frame.classIndicator.bg:SetScale(config.classIndicatorBackgroundSize)
        BackgroundType(frame, frame.classIndicator.bg)
    elseif frame.classIndicator.bg then
        frame.classIndicator.bg:Hide()
    end

    if config.classIndicatorPinMode then
        if not frame.classIndicator.pin then
            frame.classIndicator.pin = frame.classIndicator:CreateTexture(nil, "BACKGROUND", nil, 0)
            frame.classIndicator.pin:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
            frame.classIndicator.pin:SetSize(29, 38)
            frame.classIndicator.pin:SetPoint("TOP", frame.classIndicator.icon, "BOTTOM", 0, 20)
            frame.classIndicator.pin:SetDesaturated(true)
        end
        frame.classIndicator.pin:SetVertexColor(classColor.r, classColor.g, classColor.b)
        frame.classIndicator.pin:Show()
    elseif frame.classIndicator.pin then
        frame.classIndicator.pin:Hide()
    end

    -- local coords = CLASS_ICON_TCOORDS[info.class]
    -- if not coords then
    --     frame.classIndicator:Hide()
    --     if config.classIndicatorHideRaidMarker then
    --         if not config.hideRaidmarkIndicator then
    --             frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
    --         end
    --     end
    --     return
    -- end

    -- Optional class coloring for the border
    if config.classIconColorBorder then
        frame.classIndicator.border:SetDesaturated(true)
        frame.classIndicator.border:SetVertexColor(classColor.r, classColor.g, classColor.b)
    elseif config.classIconReactionBorder then
        frame.classIndicator.border:SetDesaturated(true)
        if info.isFriend then
            frame.classIndicator.border:SetVertexColor(0, 1, 0)
        else
            frame.classIndicator.border:SetVertexColor(1, 0, 0)
        end
    else
        frame.classIndicator.border:SetDesaturated(false)
        if frame.classIndicator.border.square then
            frame.classIndicator.border:SetVertexColor(0.2, 0.2, 0.2)
        else
            frame.classIndicator.border:SetVertexColor(1, 1, 1)
        end
    end

    -- Show the class icon frame
    if config.classIndicatorHideRaidMarker then
        frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
    end

    if flagIcon then
        frame.classIndicator.icon:SetTexture(flagIcon)
        frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
    elseif specIcon and config.classIndicatorSpecIcon then
        if config.classIndicatorHealer and HealerSpecs[specID] then
            if info.isFriend then
                if frame.classIndicator.border.square then
                    frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                    frame.classIndicator.icon:SetTexCoord(0.0196, 0.103, 0.774, 0.856) -- square
                else
                    frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                    frame.classIndicator.icon:SetTexCoord(0.015, 0.1077, 0.7684, 0.8606) -- circle
                end
            else
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                if frame.classIndicator.border.square then
                    frame.classIndicator.icon:SetTexCoord(0.0196, 0.103, 0.774, 0.856) -- square
                else
                    frame.classIndicator.icon:SetTexCoord(0.015, 0.1077, 0.7684, 0.8606) -- circle
                end
                if BetterBlizzPlatesDB.classIconHealerIconType == 2 then
                    frame.classIndicator.icon:SetDesaturated(true)
                    frame.classIndicator.icon:SetVertexColor(1, 0, 0)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 3 then
                    frame.classIndicator.icon:SetTexture(648207)
                    frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
                end
            end
        elseif isTank then
            if frame.classIndicator.border.square then
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.6498, 0.7302, 0.2726, 0.356)
            else
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.637, 0.745, 0.259, 0.365)
            end
        else
            frame.classIndicator.icon:SetTexture(specIcon)
            frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
        end
    elseif config.classIndicatorHealer and HealerSpecs[specID] then
        if info.isFriend then
            if frame.classIndicator.border.square then
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.0196, 0.103, 0.774, 0.856) -- square
            else
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.015, 0.1077, 0.7684, 0.8606) -- circle
            end
        else
            frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
            if frame.classIndicator.border.square then
                frame.classIndicator.icon:SetTexCoord(0.0196, 0.103, 0.774, 0.856) -- square
            else
                frame.classIndicator.icon:SetTexCoord(0.015, 0.1077, 0.7684, 0.8606) -- circle
            end
            if BetterBlizzPlatesDB.classIconHealerIconType == 2 then
                frame.classIndicator.icon:SetDesaturated(true)
                frame.classIndicator.icon:SetVertexColor(1, 0, 0)
            elseif BetterBlizzPlatesDB.classIconHealerIconType == 3 then
                frame.classIndicator.icon:SetTexture(648207)
                frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
            end
        end
    elseif isTank then
        if frame.classIndicator.border.square then
            frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
            frame.classIndicator.icon:SetTexCoord(0.6498, 0.7302, 0.2726, 0.356)
        else
            frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
            frame.classIndicator.icon:SetTexCoord(0.637, 0.745, 0.259, 0.365)
        end
    else
        frame.classIndicator.icon:SetAtlas(classAtlas)
        frame.classIndicator.icon:SetTexCoord(-0.06, 1.05, -0.06, 1.05)
    end

    if info.isFriend then
        classIconNames[info.name] = frame
    end

    frame.classIndicator:Show()
    if config.classIndicatorHideName and info.isFriend then
        frame.classIndicatorHideName = true
        frame.name:SetText("")
    elseif config.classIconHealthNumbers then
        BBP.UpdateHealthText(frame)
    end
end

function BBP.ClassIndicatorTargetHighlight(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    if config.classIndicatorHighlight or config.classIndicatorHighlightColor then
        if frame.classIndicator and frame.classIndicator.highlightSelect then
            frame.classIndicator.highlightSelect:Show()
            if frame.classIndicator.bg and frame.classIndicator.border.circle then
                frame.classIndicator.bg:SetSize(39, 39)
            end
            C_Timer.After(
                0.05,
                function()
                    frame.classIndicator.border:Hide()
                end
            )
            if info.class and config.classIndicatorHighlightColor then
                local classColor = RAID_CLASS_COLORS[info.class]
                frame.classIndicator.highlightSelect:SetDesaturated(true)
                frame.classIndicator.highlightSelect:SetVertexColor(classColor.r, classColor.g, classColor.b)
                frame.classIndicator.highlightSelect.classColored = true
            elseif frame.classIndicator.highlightSelect.classColored then
                frame.classIndicator.highlightSelect:SetDesaturated(
                    frame.classIndicator.border.square and true or false
                )
                frame.classIndicator.highlightSelect:SetVertexColor(1, 0.88, 0)
                frame.classIndicator.highlightSelect.classColored = true
            end
        end
    end
end

function BBP.UpdateHealthText(frame)
    if not frame.classIndicator then
        return
    end
    if not frame.classIndicator:IsShown() then
        return
    end
    if frame.classIndicatorHideNumbers then
        return
    end
    if not BBP.isInPvP then
        return
    end

    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if (info.isFriend and config.classIndicatorFriendly) or (info.isEnemy and config.classIndicatorEnemy) then
        local health = UnitHealth(frame.unit)
        local maxHealth = UnitHealthMax(frame.unit)

        if maxHealth and maxHealth > 0 then
            local healthPercent = math.floor((health / maxHealth) * 100)
            if frame.name:GetAlpha() ~= 0 then
                frame.name:SetText(healthPercent)
            end
        end
    end
end

function BBP.SetupClassIndicatorHealthText()
    if BBP.healthTextFrame then
        return
    end -- Prevent multiple registrations

    BBP.healthTextFrame = CreateFrame("Frame")
    BBP.healthTextFrame:RegisterEvent("UNIT_HEALTH")
    BBP.healthTextFrame:RegisterEvent("UNIT_MAXHEALTH")
    BBP.healthTextFrame:SetScript(
        "OnEvent",
        function(_, event, unit)
            local _, frame = BBP.GetSafeNameplate(unit)
            if frame then
                BBP.UpdateHealthText(frame)
            end
        end
    )
end

local function FadeClassIcon(name, fade)
    local frame = classIconNames[name]
    if frame and frame.classIndicator then
        if fade then
            frame.classIndicator:SetAlpha(0.15)
            -- if frame.classIndicator.bg then
            --     frame.classIndicator.bg:SetDesaturated(true)
            --     frame.classIndicator.bg:SetVertexColor(0,0,0)
            -- end
        else
            local config = frame.BetterBlizzPlates.config
            frame.classIndicator:SetAlpha(config.classIndicatorAlpha)
        end
    end
end

local function CalculateFadeTime(msg)
    local base = 2.5
    local perChar = 0.05
    local length = string.len(msg or "")
    return base + (length * perChar)
end

function BBP.SetupClassIndicatorChat()
    if BBP.ClassIndicatorChat then return end
    local chatBubbles = C_CVar.GetCVarBool("chatBubblesParty")
    local chatBubblesParty = C_CVar.GetCVarBool("chatBubblesParty")

    if chatBubbles or chatBubblesParty then

        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:SetScript("OnEvent", function(self, event)
            wipe(classIconNames)
        end)



        local chatFrame = CreateFrame("Frame")
        if C_CVar.GetCVarBool("chatBubblesParty") then
            chatFrame:RegisterEvent("CHAT_MSG_PARTY")
            chatFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
        end
        if C_CVar.GetCVarBool("chatBubbles") then
            chatFrame:RegisterEvent("CHAT_MSG_SAY")
        end


        local partyPointer = BetterBlizzPlatesDB.partyPointer
        local classIndicator = BetterBlizzPlatesDB.classIndicator


        chatFrame:SetScript("OnEvent", function(self, event, msg, sender)
            local nameOnly = Ambiguate(sender, "short")
            if classIconNames[nameOnly] then
                local delay = CalculateFadeTime(msg)
                if classIndicator then
                    FadeClassIcon(nameOnly, true)
                    C_Timer.After(delay, function()
                        FadeClassIcon(nameOnly)
                    end)
                end
                if partyPointer then
                    BBP.FadePartyPointer(nameOnly, true)
                    C_Timer.After(delay, function()
                        BBP.FadePartyPointer(nameOnly)
                    end)
                end
            end
        end)
    end

    BBP.ClassIndicatorChat = true
end


function BBP.ToggleClassIndicatorPinMode(enable)
    local db = BetterBlizzPlatesDB

    if enable then
        -- Save current values into session-local table
        BBP.classIndicatorValues = {
            hideFriendlyNameText = db.hideFriendlyNameText,
            alwaysHideFriendlyCastbar = db.alwaysHideFriendlyCastbar,
            classIndicatorBackground = db.classIndicatorBackground,
            friendlyHideHealthBar = db.friendlyHideHealthBar,
            friendlyHideHealthBarNpc = db.friendlyHideHealthBarNpc,
            classIndicatorYPos = db.classIndicatorYPos,
            classIconColorBorder = db.classIconColorBorder,
            classIndicatorHighlightColor = dbclassIndicatorHighlightColor,
        }

        -- Apply new values for pin mode
        db.classIndicatorPinMode = true
        db.hideFriendlyNameText = true
        db.alwaysHideFriendlyCastbar = true
        db.classIndicatorBackground = true
        db.classIconColorBorder = true
        db.classIndicatorHighlightColor = true
        db.classIndicatorYPos = -14
        if not db.friendlyHideHealthBar then
            db.friendlyHideHealthBarNpc = false
            BBP.friendlyHideHealthBarNpc:SetChecked(false)
        end
        db.friendlyHideHealthBar = true


        BBP.alwaysHideFriendlyCastbar:SetChecked(true)
        BBP.hideFriendlyNameText:SetChecked(true)
        BBP.friendlyHideHealthBar:SetChecked(true)
        BBP.friendlyHideHealthBarNpc:Enable()
        BBP.friendlyHideHealthBarNpc:Show()
    else
        local saved = BBP.classIndicatorValues or {}

        db.classIndicatorPinMode = false
        db.hideFriendlyNameText = saved.hideFriendlyNameText or false
        db.alwaysHideFriendlyCastbar = saved.alwaysHideFriendlyCastbar or false
        db.classIndicatorBackground = saved.classIndicatorBackground or false
        db.friendlyHideHealthBar = saved.friendlyHideHealthBar or false
        db.friendlyHideHealthBarNpc = saved.friendlyHideHealthBarNpc or false
        db.classIconColorBorder = saved.classIconColorBorder or true
        db.classIndicatorHighlightColor = saved.classIndicatorHighlightColor or false
        db.classIndicatorYPos = saved.classIndicatorYPos or 0

        BBP.alwaysHideFriendlyCastbar:SetChecked(db.alwaysHideFriendlyCastbar)
        BBP.hideFriendlyNameText:SetChecked(db.hideFriendlyNameText)
        BBP.friendlyHideHealthBar:SetChecked(db.friendlyHideHealthBar)
        if BBP.friendlyHideHealthBar:GetChecked() then
            BBP.friendlyHideHealthBar:SetChecked(db.friendlyHideHealthBarNpc)
            BBP.friendlyHideHealthBarNpc:Enable()
            BBP.friendlyHideHealthBarNpc:Show()
        else
            BBP.friendlyHideHealthBar:SetChecked(false)
            BBP.friendlyHideHealthBarNpc:Disable()
            BBP.friendlyHideHealthBarNpc:Hide()
        end
    end
    BBP.RefreshAllNameplates()
end