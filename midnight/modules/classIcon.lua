if not BBP.isMidnight then return end
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

-- Map PvPUnitClassification enum values to icon textures
local classificationIcons = {
    [0] = 132485,  -- FlagCarrierHorde
    [1] = 132486,  -- FlagCarrierAlliance
    [2] = 132487,  -- FlagCarrierNeutral
    [7] = 1119885, -- OrbCarrierBlue
    [8] = 1119886, -- OrbCarrierGreen
    [9] = 1119887, -- OrbCarrierOrange (Red)
    [10] = 1119888, -- OrbCarrierPurple
}
BBP.ClassIndicatorIcons = classificationIcons

local petIcons = {
    [417] = 136217, -- felhunter
    [1863] = 136220, -- succubus
    [416] = 136218, -- imp
    [1860] = 136221, -- voidwalker
    [17252] = 136216, -- felguard
    [208441] = 135862, -- water ele
    [165189] = 132193, -- hunter pet
    [26125] = 1531513, -- dk pet
}

-- Huge thanks to Stroold @ Discord for putting together this list of hunter pet spell ids and icons
local petSpellIcons = {
    -- Hunter pet family abilities
    [160065] = 236195, -- Aqiri — Tendon Rip
    [263841] = 877476, -- Basilisk — Petrifying Gaze
    [344348] = 132182, -- Bat — Sonic Screech
    [263934] = 132183, -- Bear — Thick Fur
    [90339]  = 133570, -- Beetle — Harden Carapace
    [263852] = 132192, -- Bird of Prey — Talon Rend
    [288962] = 1687702,-- Blood Beast — Blood Bolt
    [263869] = 132184, -- Boar — Bristle
    [341115] = 454771, -- Camel — Hardy
    [279410] = 2011146, -- Carapid — Bulwark
    [24423]  = 132200, -- Carrion Bird — Bloody Screech
    [263892] = 132185, -- Cat — Catlike Reflexes
    [54644]  = 236190, -- Chimaera — Frost Breath
    [160057] = 1044794, -- Clefthoof — Thick Hide
    [263867] = 236191, -- Core Hound — Obsidian Skin
    [341117] = 2143073, -- Courser — Fleethoof
    [50245]  = 132186, -- Crab — Pin
    [50433]  = 132187, -- Crocolisk — Ankle Crack
    [54680]  = 236192, -- Devilsaur — Monstrous Bite
    [263861] = 877480, -- Direhorn — Gore
    [263887] = 132188, -- Dragonhawk — Dragon's Guile
    [263916] = 929300, -- Feathermane — Feather Flurry
    [160011] = 458223, -- Fox — Agile Reflexes
    [263939] = 132189, -- Gorilla — Silverback
    [263921] = 877477, -- Gruffhorn — Gruff
    [279336] = 804969, -- Hopper — Swarm of Flies
    [263423] = 877481, -- Hound — Lock Jaw
    [263863] = 463493, -- Hydra — Acid Bite
    [263853] = 132190, -- Hyena — Infected Bite
    [392622] = 797547, -- Lesser Dragonkin — Shimmering Scales
    [279362] = 2027936, -- Lizard — Grievous Bite
    [341118] = 132254, -- Mammoth — Trample
    [263868] = 132247, -- Mechanical — Defense Matrix
    [160044] = 877482, -- Monkey — Primal Agility
    [344353] = 236193, -- Moth — Serenity Dust
    [264023] = 616693, -- Oxen — Niuzao's Fortitude
    [279399] = 1624590, -- Pterrordax — Ancient Hide
    [263854] = 132193, -- Raptor — Savage Rend
    [263857] = 132194, -- Ravager — Ravage
    [344349] = 132191, -- Ray — Nether Energy
    [160018] = 1044490, -- Riverbeast — Gruesome Bite
    [263856] = 644001, -- Rodent — Gnaw
    [263865] = 646378, -- Scalehide — Scale Shield
    [160060] = 132195, -- Scorpid — Deadly Sting
    [263904] = 136040, -- Serpent — Serpent's Swiftness
    [160063] = 877478, -- Shale Beast — Solid Shell
    [160067] = 132196, -- Spider — Web Spray
    [344351] = 236165, -- Spirit Beast — Spirit Pulse
    [344347] = 132197, -- Sporebat — Spore Cloud
    [344352] = 1044501, -- Stag — Nature's Grace
    [160049] = 625905, -- Stone Hound — Stone Armor
    [50285]  = 132198, -- Tallstrider — Dust Cloud
    [26064]  = 132199, -- Turtle — Shell Shield
    [35346]  = 132201, -- Warp Stalker — Warp Time
    [263858] = 236196, -- Wasp — Toxic Sting
    [344346] = 643423, -- Water Strider — Soothing Waters
    [344350] = 877479, -- Waterfowl — Oiled Feathers
    [264360] = 132202, -- Wind Serpent — Winged Agility
    [263840] = 132203, -- Wolf — Furious Bite
    [263446] = 236197, -- Worm — Acid Spit
}

local playerClass = select(2, UnitClass("player"))
local currentPetIcon = nil

if playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT" or playerClass == "MAGE" then
    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_PET")

    local function UpdateCurrentPetIcon()
        currentPetIcon = nil
        if UnitExists("pet") then
            for spellID, iconID in pairs(petSpellIcons) do
                if IsSpellKnownOrOverridesKnown(spellID, true) then
                    currentPetIcon = iconID
                    break
                end
            end
        end
    end

    f:SetScript("OnEvent", function(self, event, arg1)
        if arg1 == "player" then
            local pp = BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerShowPet
            local ci = BetterBlizzPlatesDB.classIndicator and BetterBlizzPlatesDB.classIndicatorShowPet
            if ci then
                if playerClass == "HUNTER" then
                    UpdateCurrentPetIcon()
                end
                C_Timer.After(0.5, function()
                    local _, frame = BBP.GetSafeNameplate("pet")
                    if frame then
                        BBP.ClassIndicator(frame)
                    end
                end)
            end
            if pp then
                C_Timer.After(0.5, function()
                    local _, frame = BBP.GetSafeNameplate("pet")
                    if frame then
                        BBP.PartyPointer(frame)
                    end
                end)
            end
        end
    end)
end

local function GetAuraIcon(frame)
    local classification = UnitPvpClassification(frame.unit)
    if classification and classificationIcons[classification] then
        return classificationIcons[classification]
    end
    return nil
end

local function BackgroundType(frame, bg)
    if frame.classIndicator.border.square then
        bg:SetAtlas("mountequipment-slot-background")
        bg:SetSize(28, 28)
    else
        bg:SetAtlas("talents-node-choiceflyout-circle-greenglow")
        local size = UnitIsUnit("target", frame.unit) and 39 or 36
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
        config.classIndicatorShowPet = BetterBlizzPlatesDB.classIndicatorShowPet
        config.classIndicatorHideFriendlyHealthbar = BetterBlizzPlatesDB.classIndicatorHideFriendlyHealthbar
        config.classIndicatorOnlyParty = BetterBlizzPlatesDB.classIndicatorOnlyParty
        config.classIndicatorOnlyFriends = BetterBlizzPlatesDB.classIndicatorOnlyFriends
        config.classIndicatorAlwaysShowPet = BetterBlizzPlatesDB.classIndicatorAlwaysShowPet
        config.classIndicatorShowOthersPets = BetterBlizzPlatesDB.classIndicatorShowOthersPets

        config.classIndicatorInitialized = true
    end

    frame.classIndicatorHideNumbers = nil

    local isOthersPet = config.classIndicatorShowOthersPets and UnitIsOtherPlayersPet(frame.unit) and BBP.isInArena and info.isFriend
    local isPetGUID

    local class = info.class
    if not class then
        isPetGUID = UnitIsUnit(frame.unit, "pet")
        if (isPetGUID and config.classIndicatorShowPet) or isOthersPet then
            if isOthersPet then
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
            else
                class = playerClass
            end
        else
            if config.classIndicatorHideRaidMarker then
                frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
            end
            if frame.classIndicator then
                frame.classIndicator:Hide()
                frame.classIndicatorHideNumbers = true
            end
            return
        end
    end

    -- if UnitIsUnit(frame.unit, "player") then
    --     if frame.classIndicator then
    --         frame.classIndicator:Hide()
    --     end
    --     return
    -- end

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

        if not config.classIconSquareBorderFriendly then
            frame.classIndicatorCC = CreateFrame("Frame", nil, frame.classIndicator)
            frame.classIndicatorCC:SetSize(26, 26)
            frame.classIndicatorCC:SetFrameStrata("HIGH")
            frame.classIndicatorCC:Hide()

            frame.classIndicatorCC.Icon = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 6)
            frame.classIndicatorCC.Icon:SetPoint("CENTER", frame.classIndicator)
            frame.classIndicatorCC.mask = frame.classIndicatorCC:CreateMaskTexture()
            frame.classIndicatorCC.mask:SetTexture("Interface/Masks/CircleMaskScalable")
            frame.classIndicatorCC.mask:SetSize(27, 27)
            frame.classIndicatorCC.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicatorCC.Icon:AddMaskTexture(frame.classIndicatorCC.mask)
            frame.classIndicatorCC.Icon:SetSize(26, 26)

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
            frame.classIndicatorCC.Glow:SetPoint("CENTER", frame.classIndicator, "CENTER", 0, 0)
            frame.classIndicatorCC.Glow:SetDesaturated(true)
            frame.classIndicatorCC.Glow:SetSize(36, 36)
            frame.classIndicatorCC.Glow:SetDrawLayer("OVERLAY", 7)
        else
            frame.classIndicatorCC = CreateFrame("Frame", nil, frame.classIndicator)
            frame.classIndicatorCC:SetSize(27, 27)
            frame.classIndicatorCC:SetFrameStrata("HIGH")
            frame.classIndicatorCC:Hide()

            frame.classIndicatorCC.Icon = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 6)
            frame.classIndicatorCC.Icon:SetPoint("CENTER", frame.classIndicator)
            frame.classIndicatorCC.mask = frame.classIndicatorCC:CreateMaskTexture()
            frame.classIndicatorCC.mask:SetAtlas("UI-Frame-IconMask")
            frame.classIndicatorCC.mask:SetSize(21, 21)
            frame.classIndicatorCC.mask:SetPoint("CENTER", frame.classIndicator.icon)
            frame.classIndicatorCC.Icon:AddMaskTexture(frame.classIndicatorCC.mask)
            frame.classIndicatorCC.Icon:SetSize(20.5, 20.5)

            frame.classIndicatorCC.Cooldown = CreateFrame("Cooldown", nil, frame.classIndicatorCC, "CooldownFrameTemplate")
            frame.classIndicatorCC.Cooldown:SetAllPoints(frame.classIndicatorCC.Icon)
            frame.classIndicatorCC.Cooldown:SetDrawEdge(false)
            frame.classIndicatorCC.Cooldown:SetDrawSwipe(true)
            frame.classIndicatorCC.Cooldown:SetSwipeColor(0, 0, 0, 0.7)
            frame.classIndicatorCC.Cooldown:SetSwipeTexture("Interface\\Common\\common-iconmask")
            frame.classIndicatorCC.Cooldown:SetReverse(true)

            frame.classIndicatorCC.Glow = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 7)
            frame.classIndicatorCC.Glow:SetAtlas("newplayertutorial-drag-slotblue")
            frame.classIndicatorCC.Glow:SetPoint("CENTER", frame.classIndicator, "CENTER", 0, 0)
            frame.classIndicatorCC.Glow:SetDesaturated(true)
            frame.classIndicatorCC.Glow:SetSize(38, 38)
            frame.classIndicatorCC.Glow:SetDrawLayer("OVERLAY", 7)
        end
    end
    frame.classIndicator:SetFrameStrata(config.classIndicatorFrameStrataHigh and "HIGH" or "LOW")
    frame.classIndicator:SetAlpha(config.classIndicatorAlpha or 1)

    if (config.classIndicatorHighlight or config.classIndicatorHighlightColor) and not frame.classIndicator.highlightSelect then
        frame.classIndicator.highlightSelect = frame.classIndicator:CreateTexture(nil, "OVERLAY")
        frame.classIndicator.highlightSelect:SetAtlas("charactercreate-ring-select")
        frame.classIndicator.highlightSelect:Hide()
        frame.classIndicator.highlightSelect:SetPoint("CENTER", frame.classIndicator, "CENTER", 0, 0)
        frame.classIndicator.highlightSelect:SetSize(33, 33)
        frame.classIndicator.highlightSelect:SetDrawLayer("OVERLAY", 6)
    end

    local flagIcon
    if BBP.isInBg and (enabledOnThisUnit or config.classIconAlwaysShowBgObj) then
        flagIcon = GetAuraIcon(frame)
    end

    frame.classIndicator.flagActive = flagIcon and true or nil

    local specIcon
    local specID = BBP.GetSpecID(frame)
    if config.classIndicatorSpecIcon or config.classIndicatorHealer then
        if specID then
            specIcon = select(4, GetSpecializationInfoByID(specID))
        end
    end

    local isTank = config.classIndicatorTank and TankSpecs[specID]
    local isPet = isPetGUID and config.classIndicatorShowPet
    local isPetAndAlwaysShow = config.classIndicatorAlwaysShowPet and isPet
    local alwaysShowTank = config.classIconAlwaysShowTank and TankSpecs[specID]
    local alwaysShowHealer = config.classIconAlwaysShowHealer and HealerSpecs[specID]
    local isHealer = HealerSpecs[specID]
    local partyOnly = config.classIndicatorOnlyParty and not UnitInParty(frame.unit)

    local shouldHide = not enabledOnThisUnit and not flagIcon and not alwaysShowHealer and not alwaysShowTank and not isPet

    if shouldHide
        or (config.classIndicatorOnlyHealer and not isHealer and not flagIcon and not alwaysShowHealer and not alwaysShowTank)
        or partyOnly
        or (config.classIndicatorOnlyFriends and not (BBP.isFriendlistFriend(frame.unit) or BBP.isUnitBNetFriend(frame.unit)))
    then
        if not isPetAndAlwaysShow then
            frame.classIndicator:Hide()
            return
        end
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
        if config.nameplateResourceOnTarget == "1" and not config.nameplateResourceUnderCastbar and info.isTarget and not (config.hideResourceOnFriend and info.isFriend) then
            resourceAnchor = frame:GetParent().driverFrame.classNamePlateMechanicFrame
        end
        local attachPoint = (BetterBlizzPlatesDB.useFakeName and BetterBlizzPlatesDB.fakeNameAnchorRelative == "TOP" and frame.name) or resourceAnchor or frame.healthBar
        frame.classIndicator:SetPoint(oppositeAnchor, attachPoint, anchorPoint, xPos, yPos + 7)
    else
        frame.classIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos, yPos)
    end
    frame.classIndicator:SetScale((flagIcon and scale * 1.15) or (isOthersPet and scale * 0.7) or scale)

    -- Visibility checks
    if ((config.classIconArenaOnly and not BBP.isInArena) or (config.classIconBgOnly and not BBP.isInBg)) and not( config.classIconAlwaysShowBgObj and flagIcon) then
        if config.classIconArenaOnly and config.classIconBgOnly then
            if not BBP.isInPvP then
                if not isPetAndAlwaysShow then
                    frame.classIndicator:Hide()
                    return
                end
            end
        else
            if not isPetAndAlwaysShow and not ((alwaysShowHealer or alwaysShowTank) and BBP.isInPvP) then
                frame.classIndicator:Hide()
                return
            end
        end
    end

    frame.classIndicator.icon:SetDesaturated(false)
    frame.classIndicator.icon:SetVertexColor(1, 1, 1)

    -- -- Get class icon texture and coordinates
    -- local classIcon = "Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES"
    local classAtlas = "classicon-" .. string.lower(class)
    local classColor = RAID_CLASS_COLORS[class]
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

    if config.classIndicatorPinMode and info.isFriend then
        if not frame.classIndicator.pin then
            frame.classIndicator.pin = frame.classIndicator:CreateTexture(nil, "BACKGROUND", nil, 0)
            frame.classIndicator.pin:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
            frame.classIndicator.pin:SetSize(25, 23)
            frame.classIndicator.pin:SetPoint("TOP", frame.classIndicator.icon, "BOTTOM", 0, 6)
            frame.classIndicator.pin:SetDesaturated(true)
            frame.classIndicator.pin:SetTexCoord(0, 1, 0.27, 1)
        end
        frame.classIndicator.pin:SetVertexColor(classColor.r, classColor.g, classColor.b)
        frame.classIndicator.pin:Show()
    elseif frame.classIndicator.pin then
        frame.classIndicator.pin:Hide()
    end

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
                frame.classIndicator.icon:SetTexCoord(0.637, 0.742, 0.259, 0.365)
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
            frame.classIndicator.icon:SetTexCoord(0.637, 0.742, 0.259, 0.365)
        end
    else
        if isPet then
            local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)
            local petIcon = currentPetIcon or petIcons[npcID]
            if petIcon then
                frame.classIndicator.icon:SetTexture(petIcon)
                frame.classIndicator.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
            else
                local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)
                local petIcon = currentPetIcon or petIcons[npcID]
                if petIcon then
                    frame.classIndicator.icon:SetTexture(petIcon)
                    frame.classIndicator.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
                else
                    frame.classIndicator.icon:SetTexture(618972)
                    frame.classIndicator.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
                end
            end
        else
            frame.classIndicator.icon:SetAtlas(classAtlas)
            frame.classIndicator.icon:SetTexCoord(-0.06, 1.05, -0.06, 1.05)
        end
    end

    if info.isFriend then
        if config.classIndicatorHideFriendlyHealthbar then
            frame.HealthBarsContainer:SetAlpha(0)
            frame.HealthBarsContainer.alphaZero = true
            frame.selectionHighlight:SetAlpha(0)
            frame.ciChange = true
        elseif frame.ciChange then
            frame.HealthBarsContainer:SetAlpha(1)
            frame.HealthBarsContainer.alphaZero = false
            frame.selectionHighlight:SetAlpha(config.hideTargetHighlight and 0 or 0.22)
            frame.ciChange = nil
        end
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
        if frame.pinIconActive then return end
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
                local classColor = RAID_CLASS_COLORS[info.class] --BBP.isMidnight
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
    if BBP.isMidnight then return end
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

    if (info.isFriend and config.classIndicatorFriendly) or (info.isEnemy and config.classIndicatorEnemy) or (config.classIndicatorShowPet and info.isPet) then
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

function BBP.ToggleClassIndicatorPinMode(enable)
    local db = BetterBlizzPlatesDB

    if enable then
        -- Save current values into session-local table
        BBP.classIndicatorValues = {
            classIndicatorHideName = db.classIndicatorHideName,
            alwaysHideFriendlyCastbar = db.alwaysHideFriendlyCastbar,
            classIndicatorBackground = db.classIndicatorBackground,
            classIndicatorBackgroundSize = db.classIndicatorBackgroundSize,
            classIndicatorHideFriendlyHealthbar = db.classIndicatorHideFriendlyHealthbar,
            classIndicatorYPos = db.classIndicatorYPos,
            classIconColorBorder = db.classIconColorBorder,
            classIndicatorHighlightColor = db.classIndicatorHighlightColor,
        }

        -- Apply new values for pin mode--classIndicatorHideName
        db.classIndicatorPinMode = true
        db.classIndicatorHideName = true
        db.alwaysHideFriendlyCastbar = true
        db.classIndicatorBackground = true
        db.classIndicatorBackgroundSize = 1
        db.classIconColorBorder = true
        db.classIndicatorHighlightColor = true
        db.classIndicatorYPos = -14
        db.classIndicatorHideFriendlyHealthbar = true


        BBP.alwaysHideFriendlyCastbar:SetChecked(true)
    else
        local saved = BBP.classIndicatorValues or {}

        db.classIndicatorPinMode = false
        db.classIndicatorHideName = saved.classIndicatorHideName or false
        db.alwaysHideFriendlyCastbar = saved.alwaysHideFriendlyCastbar or false
        db.classIndicatorBackground = saved.classIndicatorBackground or false
        db.classIndicatorBackgroundSize = saved.classIndicatorBackgroundSize or 1
        db.classIndicatorHideFriendlyHealthbar = saved.classIndicatorHideFriendlyHealthbar or false
        db.classIconColorBorder = saved.classIconColorBorder or true
        db.classIndicatorHighlightColor = saved.classIndicatorHighlightColor or false
        db.classIndicatorYPos = saved.classIndicatorYPos or 0

        BBP.alwaysHideFriendlyCastbar:SetChecked(db.alwaysHideFriendlyCastbar)
    end
    BBP.RefreshAllNameplates()
end