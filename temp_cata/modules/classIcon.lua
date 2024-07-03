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

local specIcons = {
    -- Death Knight
    [250] = "Interface\\Icons\\Spell_Deathknight_BloodPresence",        -- Blood
    [251] = "Interface\\Icons\\Spell_Deathknight_FrostPresence",        -- Frost
    [252] = "Interface\\Icons\\Spell_Deathknight_UnholyPresence",       -- Unholy

    -- Druid
    [102] = "Interface\\Icons\\Spell_Nature_StarFall",                  -- Balance
    [103] = "Interface\\Icons\\Ability_Druid_CatForm",                  -- Feral Combat
    [104] = "Interface\\Icons\\Ability_Racial_BearForm",                -- Guardian
    [105] = "Interface\\Icons\\Spell_Nature_HealingTouch",              -- Restoration

    -- Hunter
    [253] = "Interface\\Icons\\Ability_Hunter_BeastMastery",             -- Beast Mastery
    [254] = "Interface\\Icons\\Ability_Hunter_FocusedAim",              -- Marksmanship
    [255] = "Interface\\Icons\\Ability_Hunter_Survival",                -- Survival

    -- Mage
    [62]  = "Interface\\Icons\\Spell_Holy_MagicalSentry",               -- Arcane
    [63]  = "Interface\\Icons\\Spell_Fire_FireBolt02",                  -- Fire
    [64]  = "Interface\\Icons\\Spell_Frost_FrostBolt02",                -- Frost

    -- Paladin
    [65]  = "Interface\\Icons\\Spell_Holy_HolyBolt",                    -- Holy
    [66]  = "Interface\\Icons\\Spell_Holy_DevotionAura",                -- Protection
    [70]  = "Interface\\Icons\\Spell_Holy_AuraOfLight",                 -- Retribution

    -- Priest
    [256] = "Interface\\Icons\\Spell_Holy_PowerWordShield",             -- Discipline
    [257] = "Interface\\Icons\\Spell_Holy_GuardianSpirit",              -- Holy
    [258] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",            -- Shadow

    -- Rogue
    [259] = "Interface\\Icons\\Ability_Rogue_DeadlyBrew",               -- Assassination
    [260] = "Interface\\Icons\\Ability_BackStab",                       -- Combat
    [261] = "Interface\\Icons\\Ability_Stealth",                        -- Subtlety

    -- Shaman
    [262] = "Interface\\Icons\\Spell_Nature_Lightning",                 -- Elemental
    [263] = "Interface\\Icons\\Spell_Shadow_DeathScream",               -- Enhancement
    [264] = "Interface\\Icons\\Spell_Nature_MagicImmunity",             -- Restoration

    -- Warlock
    [265] = "Interface\\Icons\\Spell_Shadow_DeathCoil",                 -- Affliction
    [266] = "Interface\\Icons\\Spell_Shadow_Metamorphosis",             -- Demonology
    [267] = "Interface\\Icons\\Spell_Shadow_RainOfFire",                -- Destruction

    -- Warrior
    [71]  = "Interface\\Icons\\Ability_Warrior_SavageBlow",             -- Arms
    [72]  = "Interface\\Icons\\Ability_Warrior_Incite",                 -- Fury
    [73]  = "Interface\\Icons\\Ability_Warrior_DefensiveStance",        -- Protection
}

local function GetSpecIconByID(specID)
    return specIcons[specID]
end

-- Class Indicator
function BBP.ClassIndicator(frame, fetchedSpecID)
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
        config.nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceUnderCastbar
        config.hideResourceOnFriend = BetterBlizzPlatesDB.hideResourceOnFriend

        config.classIndicatorInitialized = true
    end

    if not info.class then
        if config.classIndicatorHideRaidMarker then
            frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
        end
        if frame.classIndicator then
            frame.classIndicator:Hide()
        end
        return
    end

    local anchorPoint = (info.isFriend and config.classIndicatorFriendlyAnchor) or ((info.isEnemy or info.isNeutral) and config.classIndicatorAnchor)
    local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
    local xPos = (info.isFriend and config.classIndicatorFriendlyXPos) or ((info.isEnemy or info.isNeutral) and config.classIndicatorXPos) or 0
    local yPos = (info.isFriend and config.classIndicatorFriendlyYPos + (anchorPoint == "TOP" and 2 or 0)) or ((info.isEnemy or info.isNeutral) and config.classIndicatorYPos + (anchorPoint == "TOP" and 2 or 0)) or 0
    local scale = (info.isFriend and config.classIndicatorFriendlyScale + 0.3) or ((info.isEnemy or info.isNeutral) and config.classIndicatorScale + 0.3) or 1
    local inInstance, instanceType = IsInInstance()

    -- Initialize Class Icon Frame
    if not frame.classIndicator then
        frame.classIndicator = CreateFrame("Frame", nil, frame)
        frame.classIndicator:SetSize(24, 24)
        --frame.classIndicator:SetScale(scale)
        frame.classIndicator.icon = frame.classIndicator:CreateTexture(nil, "BORDER")
        frame.classIndicator.icon:SetPoint("CENTER", frame.classIndicator)
        frame.classIndicator.mask = frame.classIndicator:CreateMaskTexture()
        frame.classIndicator.border = frame.classIndicator:CreateTexture(nil, "OVERLAY")
        frame.classIndicator:SetFrameStrata("HIGH")
    end

    if (config.classIndicatorHighlight or config.classIndicatorHighlightColor) and not frame.classIndicator.highlightSelect then
        frame.classIndicator.highlightSelect = frame.classIndicator:CreateTexture(nil, "OVERLAY")
        frame.classIndicator.highlightSelect:SetAtlas("charactercreate-ring-select")
        frame.classIndicator.highlightSelect:Hide()
        frame.classIndicator.highlightSelect:SetPoint("CENTER", frame.classIndicator, "CENTER", 0,0)
        frame.classIndicator.highlightSelect:SetSize(33, 33)
        frame.classIndicator.highlightSelect:SetDrawLayer("OVERLAY", 1)
    end

    if (info.isFriend and not config.classIndicatorFriendly) or ((info.isEnemy or info.isNeutral) and not config.classIndicatorEnemy) then
        frame.classIndicator:Hide()
        return
    end

    frame.classIndicator.icon:AddMaskTexture(frame.classIndicator.mask)

    frame.classIndicator.icon:SetPoint("CENTER", frame.classIndicator)
    frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)

    -- Set position and scale dynamically
    if info.isFriend then
            -- Configure for square or circle border and apply mask
        if config.classIconSquareBorderFriendly then
            frame.classIndicator.icon:SetSize(20, 20)
            frame.classIndicator.mask:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UIFrameIconMask")
            frame.classIndicator.mask:SetSize(20, 20)
            frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicator.border:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-ActionBar-IconFrame-AddRow-Light")
            frame.classIndicator.border:SetSize(29, 29)
            frame.classIndicator.border:ClearAllPoints()
            frame.classIndicator.border:SetPoint("CENTER", frame.classIndicator.icon, 1.5, -1.5)
            ------
            ------
            if frame.classIndicator.highlightSelect then
                frame.classIndicator.highlightSelect:SetSize(64,64)
                frame.classIndicator.highlightSelect:SetTexture(BBP.squareBlueGlow)
                frame.classIndicator.highlightSelect:SetDesaturated(true)
                frame.classIndicator.highlightSelect:SetVertexColor(1,0.88,0)
            end
        else
            frame.classIndicator.icon:SetSize(24, 24)
            frame.classIndicator.mask:SetTexture("Interface/Masks/CircleMaskScalable")
            frame.classIndicator.mask:SetSize(24, 24)
            frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicator.border:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\ui-frame-genericplayerchoice-portrait-border")
            frame.classIndicator.border:SetAllPoints(frame.classIndicator)
            ------
            ------
            if frame.classIndicator.highlightSelect then
                frame.classIndicator.highlightSelect:SetDesaturated(false)
                frame.classIndicator.highlightSelect:SetSize(33, 33)
                frame.classIndicator.highlightSelect:SetAtlas("charactercreate-ring-select")
                frame.classIndicator.highlightSelect:SetVertexColor(1,0.88,0)
            end
        end
    elseif (info.isEnemy or info.isNeutral) then
        if config.classIconSquareBorder then
            frame.classIndicator.icon:SetSize(20, 20)
            frame.classIndicator.mask:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UIFrameIconMask")
            frame.classIndicator.mask:SetSize(20, 20)
            frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicator.border:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-ActionBar-IconFrame-AddRow-Light")
            frame.classIndicator.border:SetSize(29, 29)
            frame.classIndicator.border:ClearAllPoints()
            frame.classIndicator.border:SetPoint("CENTER", frame.classIndicator.icon, 1.5, -1.5)
            ------
            ------
            if frame.classIndicator.highlightSelect then
                frame.classIndicator.highlightSelect:SetSize(64,64)
                frame.classIndicator.highlightSelect:SetTexture(BBP.squareBlueGlow)
                frame.classIndicator.highlightSelect:SetDesaturated(true)
                frame.classIndicator.highlightSelect:SetVertexColor(1,0.88,0)
            end
        else
            frame.classIndicator.icon:SetSize(24, 24)
            frame.classIndicator.mask:SetTexture("Interface/Masks/CircleMaskScalable")
            frame.classIndicator.mask:SetSize(24, 24)
            frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicator.border:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\ui-frame-genericplayerchoice-portrait-border")
            frame.classIndicator.border:SetAllPoints(frame.classIndicator)
            ------
            ------
            if frame.classIndicator.highlightSelect then
                frame.classIndicator.highlightSelect:SetDesaturated(false)
                frame.classIndicator.highlightSelect:SetSize(33, 33)
                frame.classIndicator.highlightSelect:SetAtlas("charactercreate-ring-select")
                frame.classIndicator.highlightSelect:SetVertexColor(1,0.88,0)
            end
        end
    end

    if frame.classIndicator.highlightSelect or config.classIndicatorHighlightColor then
        if info.isTarget then
            BBP.ClassIndicatorTargetHighlight(frame)
        else
            frame.classIndicator.highlightSelect:Hide()
        end
    end

    frame.classIndicator:ClearAllPoints()
    if anchorPoint == "TOP" then
        local resourceAnchor = nil
        if config.nameplateResourceOnTarget == "1" and not config.nameplateResourceUnderCastbar and info.isTarget and not (config.hideResourceOnFriend and info.isFriend) then
            resourceAnchor = frame:GetParent().driverFrame.classNamePlateMechanicFrame
        end
        frame.classIndicator:SetPoint(oppositeAnchor, resourceAnchor or frame.fakeName or frame.name, anchorPoint, xPos, yPos)
    else
        frame.classIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos, yPos)
    end
    frame.classIndicator:SetScale(scale)

    -- Visibility checks
    if (config.classIconArenaOnly and not (inInstance and instanceType == "arena")) or (config.classIconBgOnly and not (inInstance and instanceType == "pvp")) then
        frame.classIndicator:Hide()
        return
    end

    -- Get class icon texture and coordinates
    local classIcon = "Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES"
    local classColor = RAID_CLASS_COLORS[info.class]
    local coords = CLASS_ICON_TCOORDS[info.class]
    if not coords then
        frame.classIndicator:Hide()
        if config.classIndicatorHideRaidMarker then
            if not config.hideRaidmarkIndicator then
                frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
            end
        end
        return
    end

    local specIcon
    local specID = fetchedSpecID
    local Details = Details
    if config.classIndicatorSpecIcon or config.classIndicatorHealer then
        if not specID then
            if info.isFriend and Details then
                if Details then
                    specID = Details:GetSpecByGUID(info.unitGUID)
                end
                if specID then
                    specIcon = GetSpecIconByID(specID)
                end
            elseif (info.isEnemy or info.isNeutral) and IsActiveBattlefieldArena() then
                for i = 1, 3 do
                    local arenaUnit = "arena" .. i
                    if UnitIsUnit(frame.displayedUnit, arenaUnit) then
                        specID = Details and Details:GetSpecByGUID(info.unitGUID)
                        if specID then
                            specIcon = GetSpecIconByID(specID)
                            break
                        end
                    end
                end
            elseif (info.isEnemy or info.isNeutral) then
                if Details then
                    specID = Details:GetSpecByGUID(info.unitGUID)
                end
                if specID then
                    specIcon = GetSpecIconByID(specID)
                end
            end
        else
            specIcon = GetSpecIconByID(specID)
        end
    end

    -- Set class icon texture and coordinates
    if specIcon and config.classIndicatorSpecIcon then
        if config.classIndicatorHealer then
            if HealerSpecs[specID] then
                if not ((info.isEnemy or info.isNeutral) and config.classIconSquareBorder) or (info.isFriend or config.classIconSquareBorderFriendly) then
                    frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                    frame.classIndicator.icon:SetTexCoord(0.005, 0.116, 0.76, 0.87)
                else
                    frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                    frame.classIndicator.icon:SetTexCoord(0.0185, 0.103, 0.772, 0.856)
                end
            else
                frame.classIndicator.icon:SetTexture(specIcon)
                frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
            end
        else
            frame.classIndicator.icon:SetTexture(specIcon)
            frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
        end
    elseif config.classIndicatorHealer then
        if HealerSpecs[specID] then
            if not ((info.isEnemy or info.isNeutral) and config.classIconSquareBorder) or (info.isFriend or config.classIconSquareBorderFriendly) then
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.005, 0.116, 0.76, 0.87)
            else
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.0185, 0.103, 0.772, 0.856)
            end
        else
            frame.classIndicator.icon:SetTexture(classIcon)
            frame.classIndicator.icon:SetTexCoord(unpack(coords))
        end
    else
        frame.classIndicator.icon:SetTexture(classIcon)
        frame.classIndicator.icon:SetTexCoord(unpack(coords))
    end

    -- Optional class coloring for the border
    if config.classIconColorBorder then
        frame.classIndicator.border:SetDesaturated(true)
        frame.classIndicator.border:SetVertexColor(classColor.r, classColor.g, classColor.b)
    else
        frame.classIndicator.border:SetDesaturated(false)
        frame.classIndicator.border:SetVertexColor(1, 1, 1)
    end

    -- Show the class icon frame
    if config.classIndicatorHideRaidMarker then
        frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
    end
    frame.classIndicator:Show()
end

function BBP.ClassIndicatorTargetHighlight(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    if config.classIndicatorHighlight or config.classIndicatorHighlightColor then
        if frame.classIndicator and frame.classIndicator.highlightSelect then
            frame.classIndicator.highlightSelect:Show()
            if info.class and config.classIndicatorHighlightColor then
                local classColor = RAID_CLASS_COLORS[info.class]
                frame.classIndicator.highlightSelect:SetDesaturated(true)
                frame.classIndicator.highlightSelect:SetVertexColor(classColor.r, classColor.g, classColor.b)
            end
        end
    end
end