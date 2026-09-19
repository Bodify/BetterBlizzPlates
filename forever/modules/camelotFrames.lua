local specInfo = C_SpecializationInfo

function BBP.GetSpecialization()
    if GetSpecialization then return GetSpecialization() end
    if specInfo and specInfo.GetSpecialization then return specInfo.GetSpecialization() end
    return nil
end

function BBP.GetSpecializationInfo(specIndex)
    if not specIndex then return nil end
    if GetSpecializationInfo then return GetSpecializationInfo(specIndex) end
    if specInfo and specInfo.GetSpecializationInfo then return specInfo.GetSpecializationInfo(specIndex) end
    return nil
end

function BBP.GetNumSpecializationsForClassID(classID)
    if GetNumSpecializationsForClassID then return GetNumSpecializationsForClassID(classID) end
    if specInfo and specInfo.GetNumSpecializationsForClassID then return specInfo.GetNumSpecializationsForClassID(classID) end
    return 0
end

function BBP.GetNumClasses()
    return (GetNumClasses and GetNumClasses()) or 13
end

local LEVEL_BADGE_SCALE = 1.2
local LEVEL_BADGE_X_OFFSET = 5
local LEVEL_BADGE_BOTTOM_INSET = 0.5
local LEVEL_BADGE_WIDTH = 22
local CLASSIC_LEVEL_NAME_NUDGE = 14

local function GetLevelBadgeWidth()
    local blizzardWidth = NamePlateSetupOptions and NamePlateSetupOptions.playerLevelDiffWidth
    local blizzardBase = NamePlateConstants and NamePlateConstants.LEVEL_INDICATOR_WIDTH
    if not blizzardWidth or not blizzardBase or blizzardBase <= 0 then return LEVEL_BADGE_WIDTH end
    return blizzardWidth * LEVEL_BADGE_WIDTH / blizzardBase
end

local function SetUpLevelBadgeArt(levelFrame)
    if levelFrame.bbpBadgeArtSetUp then return end
    levelFrame.bbpBadgeArtSetUp = true

    local icon = levelFrame.playerLevelDiffIcon
    local text = levelFrame.playerLevelDiffText
    local border = levelFrame.selectedBorder

    if icon then
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", levelFrame, "CENTER", 0, 0)
        icon:SetScale(LEVEL_BADGE_SCALE)
        if border then
            border:ClearAllPoints()
            border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1.5)
            border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, -1)
        end
    end
    if text then
        text:SetScale(LEVEL_BADGE_SCALE)
    end
end

local function GetLevelBadgeSquish(healthBarHeight)
    if healthBarHeight >= 27 then return 2 end
    if healthBarHeight > 21 then return 1 end
    return -1
end

local function AnchorLevelBadge(frame, levelFrame, followHealthBar, squish, classicAnchor)
    squish = followHealthBar and squish or 0
    classicAnchor = not followHealthBar and classicAnchor or false
    if levelFrame.bbpFollowsHealthBar == followHealthBar and levelFrame.bbpBadgeSquish == squish and levelFrame.bbpClassicAnchor == classicAnchor then return end
    levelFrame.bbpFollowsHealthBar = followHealthBar
    levelFrame.bbpBadgeSquish = squish
    levelFrame.bbpClassicAnchor = classicAnchor
    levelFrame:ClearAllPoints()
    if followHealthBar then
        levelFrame:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPRIGHT", LEVEL_BADGE_X_OFFSET, -squish)
        levelFrame:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "BOTTOMRIGHT", LEVEL_BADGE_X_OFFSET, LEVEL_BADGE_BOTTOM_INSET + squish)
    elseif classicAnchor then
        levelFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", 0, 0)
    else
        levelFrame:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", 0, 0)
    end
end

local function SizeLevelBadgeArt(levelFrame, height)
    local width = levelFrame:GetWidth()
    height = height or levelFrame:GetHeight()
    if not width or not height then return end
    if issecretvalue and (issecretvalue(width) or issecretvalue(height)) then return end
    if height <= 0 then return end
    if levelFrame.playerLevelDiffIcon then
        levelFrame.playerLevelDiffIcon:SetSize(width, height)
    end
    if levelFrame.highLevelTexture then
        levelFrame.highLevelTexture:SetSize(height, height)
    end
end

local function SyncLevelBadge(frame, height)
    local levelFrame = frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() then return end
    local db = BetterBlizzPlatesDB

    local followHealthBar = not (db.classicNameplates or db.classicRetailNameplates)

    if followHealthBar then
        levelFrame:SetWidth(GetLevelBadgeWidth())
        levelFrame.bbpWidthOverridden = true
        height = height or frame.HealthBarsContainer:GetHeight()
        if height and not (issecretvalue and issecretvalue(height)) then
            local squish = GetLevelBadgeSquish(height)
            AnchorLevelBadge(frame, levelFrame, true, squish)
            SizeLevelBadgeArt(levelFrame, height - LEVEL_BADGE_BOTTOM_INSET - squish * 2)
        else
            AnchorLevelBadge(frame, levelFrame, true, levelFrame.bbpBadgeSquish or 0)
        end
    else
        AnchorLevelBadge(frame, levelFrame, false, 0, db.classicNameplates)
        if levelFrame.bbpWidthOverridden then
            local blizzardWidth = NamePlateSetupOptions and NamePlateSetupOptions.playerLevelDiffWidth
            if blizzardWidth then
                levelFrame:SetWidth(blizzardWidth)
            end
            levelFrame.bbpWidthOverridden = nil
        end
        SizeLevelBadgeArt(levelFrame)
    end
end

local function RestoreBlizzardLevelBadgeLayout(frame)
    local levelFrame = frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() or not frame.unit then return end
    local followsHealthBar = levelFrame.bbpFollowsHealthBar
    if not followsHealthBar and not BetterBlizzPlatesDB.classicNameplates then return end

    local badgeSpace = BBP.GetLevelBadgeSpace(frame)
    local auraOffset = 5 + badgeSpace

    local auras = followsHealthBar and frame.AurasFrame
    if auras then
        if auras.CrowdControlListFrame then
            auras.CrowdControlListFrame:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", auraOffset, 0)
        end
        if auras.LossOfControlFrame then
            auras.LossOfControlFrame:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", auraOffset, 0)
        end
    end

    local setupOptions = NamePlateSetupOptions
    local styles = NamePlateConstants and NamePlateConstants.NAME_ANCHOR_STYLES
    if not setupOptions or not styles or not frame.name then return end
    if frame.IsShowOnlyName and frame:IsShowOnlyName() then return end
    local style = setupOptions.unitNameAnchorStyle
    if style == styles.InsideHealthBar or style == styles.CenteredAboveHealthBar then return end

    local nameSpacing = setupOptions.healthBarToNameAboveSpacing or 0
    frame.name:ClearAllPoints()
    frame.name:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "TOPLEFT", 0, nameSpacing)
    if not followsHealthBar then
        local classicLevel = frame.ClassicLevelFrame
        local levelShown = not BetterBlizzPlatesDB.hideLevelFrameBackground and classicLevel and ((classicLevel.text and classicLevel.text:IsShown()) or (classicLevel.skull and classicLevel.skull:IsShown()))
        frame.name:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "TOPRIGHT", levelShown and CLASSIC_LEVEL_NAME_NUDGE or 0, nameSpacing)
    elseif badgeSpace > 0 then
        frame.name:SetPoint("RIGHT", levelFrame, "RIGHT", 0, 0)
    else
        frame.name:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "TOPRIGHT", 0, nameSpacing)
    end
end

function BBP.GetLevelBadgeSpace(frame)
    local db = BetterBlizzPlatesDB
    if db.classicNameplates or db.hideLevelFrame then return 0, 0 end
    local levelFrame = frame and frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() or not frame.unit then return 0, 0 end
    if not levelFrame:ShouldDisplay(frame.unit) then return 0, 0 end

    local width
    if levelFrame.bbpFollowsHealthBar then
        width = GetLevelBadgeWidth()
    else
        width = levelFrame:GetWidth()
        if not width or (issecretvalue and issecretvalue(width)) or width <= 0 then
            width = NamePlateSetupOptions and NamePlateSetupOptions.playerLevelDiffWidth or 0
        end
    end
    local offset = levelFrame.bbpFollowsHealthBar and LEVEL_BADGE_X_OFFSET or 0
    return width + offset, offset + width / 2
end

local function RefreshLevelBadgeSpace(frame)
    local space = BBP.GetLevelBadgeSpace(frame)
    local previous = frame.bbpLevelBadgeSpace
    frame.bbpLevelBadgeSpace = space
    if previous == nil or previous == space then return end
    local nameplate = frame:GetParent()
    if not nameplate then return end
    BBP.UpdateClickableArea(nameplate)
    BBP.UpdateStackingZone(nameplate)
end

function BBP.GetNameplateLevel(unit, effective)
    local getLevel = effective and UnitEffectiveLevel or UnitLevel
    local level = getLevel(unit)
    if not level then return level end
    if level > 0 and UnitCanAttack("player", unit) then
        local playerLevel = getLevel("player")
        if playerLevel and level >= playerLevel + 10 then
            return -1
        end
    end
    return level
end

function BBP.HideMaxLevelInPvP(unit)
    if not BBP.isInPvP or not unit then return false end
    local level = UnitLevel(unit)
    if not level then return false end
    return level >= GetMaxLevelForPlayerExpansion()
end

local ELITE_CLASSIFICATIONS = { elite = true, rareelite = true, worldboss = true }
local ELITE_RING_LEVEL_X = 1
local ELITE_RING_HEALTHBAR_X = -8
local ELITE_RING_ATLAS = "Adventures-Ring-Gold-Dragon"
local ELITE_RING_CLASSIC_X = 8.5
local ELITE_RING_Y = -1
local ELITE_RING_WIDTH = 38
local ELITE_RING_PADDING = 13

local function GetLevelOverlay(frame, levelFrame)
    local overlay = frame.bbpLevelOverlay
    if overlay then return overlay end
    overlay = CreateFrame("Frame", nil, levelFrame)
    overlay:SetAllPoints(levelFrame)
    overlay:SetFrameLevel(levelFrame:GetFrameLevel() + 1)
    overlay.onHealthBar = false

    overlay.eliteRing = overlay:CreateTexture(nil, "ARTWORK")
    local ringInfo = C_Texture.GetAtlasInfo(ELITE_RING_ATLAS)
    if ringInfo then
        overlay.eliteRing:SetTexture(ringInfo.file or ringInfo.filename)
        overlay.eliteRing.atlasInfo = ringInfo
    else
        overlay.eliteRing:SetAtlas(ELITE_RING_ATLAS)
    end

    overlay.text = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    overlay.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    overlay.text:SetJustifyH("CENTER")
    overlay.text:SetPoint("CENTER", overlay, "CENTER", 0, 0)
    overlay.text:SetShadowColor(0, 0, 0, 1)
    overlay.text:SetShadowOffset(1, -1)

    overlay.skull = overlay:CreateTexture(nil, "OVERLAY")
    overlay.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    overlay.skull:SetPoint("CENTER", overlay, "CENTER", 0, 0)
    overlay.skull:SetSize(16, 16)

    frame.bbpLevelOverlay = overlay
    return overlay
end

local function UpdateLevelOverlayText(frame)
    local overlay = frame.bbpLevelOverlay
    local unit = frame.unit
    if not overlay or not unit then return end
    if not overlay.showText then
        overlay.text:Hide()
        overlay.skull:Hide()
        return
    end

    local level = BBP.GetNameplateLevel(unit, true)
    if level <= 0 then
        overlay.text:Hide()
        overlay.skull:Show()
        return
    end

    local color = UNIT_LEVEL_NON_ATTACKABLE
    if UnitCanAttack("player", unit) then
        color = frame.PlayerLevelDiffFrame:GetDifficultyColor(level - UnitEffectiveLevel("player"))
    end
    if color then
        overlay.text:SetTextColor(color:GetRGB())
    end
    overlay.text:SetText(level)
    overlay.text:Show()
    overlay.skull:Hide()
end

local levelDiffHooked
local function HookLevelDiffUpdates()
    if levelDiffHooked or not CompactUnitFrame_UpdatePlayerLevelDiff then return end
    levelDiffHooked = true
    hooksecurefunc("CompactUnitFrame_UpdatePlayerLevelDiff", function(frame)
        if not frame or frame:IsForbidden() or not frame.bbpLevelOverlay then return end
        UpdateLevelOverlayText(frame)
    end)
end

local function UpdateLevelOverlay(frame, levelFrame, db, levelHidden)
    local hideBackground = (db.hideLevelFrameBackground or db.classicRetailNameplates) and not levelHidden
    local ringOnHealthBar = levelHidden and frame.HealthBarsContainer and true or false
    local showRing = false
    local classification
    if db.levelFrameEliteIcon and (not levelHidden or ringOnHealthBar) and frame.unit then
        classification = UnitClassification(frame.unit)
        showRing = ELITE_CLASSIFICATIONS[classification] or false
    end

    local blizzardAlpha = hideBackground and 0 or 1
    if levelFrame.playerLevelDiffIcon then levelFrame.playerLevelDiffIcon:SetAlpha(blizzardAlpha) end
    if levelFrame.playerLevelDiffText then levelFrame.playerLevelDiffText:SetAlpha(blizzardAlpha) end
    if levelFrame.highLevelTexture then levelFrame.highLevelTexture:SetAlpha(blizzardAlpha) end
    if levelFrame.selectedBorder then levelFrame.selectedBorder:SetAlpha(blizzardAlpha) end

    if not hideBackground and not showRing and not frame.bbpLevelOverlay then return end

    HookLevelDiffUpdates()
    local overlay = GetLevelOverlay(frame, levelFrame)
    overlay.showText = hideBackground
    if overlay.onHealthBar ~= ringOnHealthBar then
        overlay.onHealthBar = ringOnHealthBar
        overlay:ClearAllPoints()
        if ringOnHealthBar then
            overlay:SetParent(frame.HealthBarsContainer)
            overlay:SetSize(20, 20)
            overlay:SetPoint("CENTER", frame.HealthBarsContainer, "RIGHT", 0, 0)
        else
            overlay:SetParent(levelFrame)
            overlay:SetAllPoints(levelFrame)
        end
        overlay:SetFrameLevel(math.max(overlay:GetParent():GetFrameLevel(), levelFrame:GetFrameLevel()) + 1)
    end
    overlay.eliteRing:SetShown(showRing)
    overlay.eliteRing:SetDesaturated(classification == "rareelite")
    local healthBar = frame.HealthBarsContainer
    if healthBar then
        local x
        local side = "RIGHT"
        if db.hideLevelFrame then
            if db.levelEliteIconLeftSide then
                side = "LEFT"
                x = -ELITE_RING_HEALTHBAR_X
            else
                x = ELITE_RING_HEALTHBAR_X
            end
        elseif db.classicNameplates then
            x = ELITE_RING_CLASSIC_X
        else
            x = select(2, BBP.GetLevelBadgeSpace(frame)) + ELITE_RING_LEVEL_X
        end
        x = x + (db.levelEliteIconXPos or 0)
        local y = ELITE_RING_Y + (db.levelEliteIconYPos or 0)
        local padding = ELITE_RING_PADDING + (db.levelEliteIconHeight or 0) / 2
        local info = overlay.eliteRing.atlasInfo
        if info then
            if side == "LEFT" then
                overlay.eliteRing:SetTexCoord(info.rightTexCoord, info.leftTexCoord, info.topTexCoord, info.bottomTexCoord)
            else
                overlay.eliteRing:SetTexCoord(info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord)
            end
        end
        overlay.eliteRing:ClearAllPoints()
        overlay.eliteRing:SetPoint("TOP", healthBar, "TOP" .. side, x, y + padding)
        overlay.eliteRing:SetPoint("BOTTOM", healthBar, "BOTTOM" .. side, x, y - padding)
        overlay.eliteRing:SetWidth(ELITE_RING_WIDTH + (db.levelEliteIconWidth or 0))
    end
    UpdateLevelOverlayText(frame)
end

function BBP.UpdateAllLevelOverlays()
    local db = BetterBlizzPlatesDB
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        local levelFrame = frame and frame.PlayerLevelDiffFrame
        if levelFrame and not frame:IsForbidden() and not levelFrame:IsForbidden() then
            UpdateLevelOverlay(frame, levelFrame, db, db.hideLevelFrame or db.classicNameplates)
        end
    end
end

function BBP.UpdateBlizzardLevelFrame(frame)
    local levelFrame = frame and frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() then return end
    local db = BetterBlizzPlatesDB

    local levelHidden = db.hideLevelFrame or db.classicNameplates
    levelFrame:SetAlpha(levelHidden and 0 or 1)
    SetUpLevelBadgeArt(levelFrame)

    if frame.HealthBarsContainer and not frame.bbpLevelFrameHooked then
        frame.bbpLevelFrameHooked = true
        hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(_, height)
            SyncLevelBadge(frame, height)
        end)
        if frame.UpdateAnchors then
            hooksecurefunc(frame, "UpdateAnchors", function()
                RestoreBlizzardLevelBadgeLayout(frame)
            end)
        end
    end
    SyncLevelBadge(frame)
    RestoreBlizzardLevelBadgeLayout(frame)
    RefreshLevelBadgeSpace(frame)
    UpdateLevelOverlay(frame, levelFrame, db, levelHidden)
end
