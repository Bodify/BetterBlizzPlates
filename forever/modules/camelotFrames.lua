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
local SIDE_LEVEL_WIDTH = 17
local SIDE_LEVEL_X_OFFSET = 4
local SIDE_LEVEL_HEIGHT = 16
local LEVEL_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
local LEVEL_TEXT_SIZE = 10
local LEVEL_SKULL_PER_FONT_SIZE = 1.6

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

local function AnchorLevelBadge(frame, levelFrame, followHealthBar, squish)
    squish = followHealthBar and squish or 0
    levelFrame.bbpClassicAnchor = not followHealthBar
    if levelFrame.bbpFollowsHealthBar == followHealthBar and levelFrame.bbpBadgeSquish == squish then return end
    levelFrame.bbpFollowsHealthBar = followHealthBar
    levelFrame.bbpBadgeSquish = squish
    levelFrame:ClearAllPoints()
    if followHealthBar then
        levelFrame:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPRIGHT", LEVEL_BADGE_X_OFFSET, -squish)
        levelFrame:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "BOTTOMRIGHT", LEVEL_BADGE_X_OFFSET, LEVEL_BADGE_BOTTOM_INSET + squish)
    else
        levelFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", 0, 0)
    end
end

local function SizeLevelBadgeArt(levelFrame, height)
    local width = levelFrame:GetWidth()
    height = height or levelFrame:GetHeight()
    if not width or not height then return end
    if issecretvalue(width) or issecretvalue(height) then return end
    if height <= 0 then return end
    if levelFrame.playerLevelDiffIcon then
        levelFrame.playerLevelDiffIcon:SetSize(width, height)
    end
    if levelFrame.highLevelTexture then
        levelFrame.highLevelTexture:SetSize(height, height)
    end
end

local function LevelBadgeFollowsHealthBar()
    local db = BetterBlizzPlatesDB
    return not (db.classicNameplates or db.classicRetailNameplates)
end

function BBP.EliteRingActive()
    local db = BetterBlizzPlatesDB
    return db.eliteDragonTweaks and db.levelFrameEliteIcon and true or false
end

function BBP.IsLevelHidden(frame)
    local db = BetterBlizzPlatesDB
    if db.hideLevelFrame then return true end
    if not db.hideLevelOnFriendly then return false end
    local unit = frame and frame.unit
    return (unit and BBP.isFriend and BBP.isFriend(unit)) and true or false
end

local function SideLevel()
    local db = BetterBlizzPlatesDB
    return db.classicRetailNameplates and not db.classicNameplates or false
end

local function LevelOutsideHealthBar()
    local db = BetterBlizzPlatesDB
    if db.classicNameplates then return false end
    return (db.classicRetailNameplates or db.centerNameplateHealthBar) and true or false
end

local function SyncLevelBadge(frame, height)
    local levelFrame = frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() then return end

    local followHealthBar = LevelBadgeFollowsHealthBar()

    if followHealthBar then
        levelFrame:SetWidth(GetLevelBadgeWidth())
        levelFrame.bbpWidthOverridden = true
        height = height or frame.HealthBarsContainer:GetHeight()
        if height and not issecretvalue(height) then
            local squish = GetLevelBadgeSquish(height)
            AnchorLevelBadge(frame, levelFrame, true, squish)
            SizeLevelBadgeArt(levelFrame, height - LEVEL_BADGE_BOTTOM_INSET - squish * 2)
        else
            AnchorLevelBadge(frame, levelFrame, true, levelFrame.bbpBadgeSquish or 0)
        end
    else
        AnchorLevelBadge(frame, levelFrame, false, 0)
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

local function NameRowHealthText(frame)
    local healthBar = frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar
    local text = healthBar and healthBar.Text
    if not text or not text.IsShown then return nil end
    local shown = text:IsShown()
    if issecretvalue(shown) or not shown then return nil end
    return text
end

local RestoreBlizzardLevelBadgeLayout

local function RefreshNameRow(frame, healthBar)
    local text = healthBar and healthBar.Text
    local shown = (text and text.IsShown and text:IsShown()) or false
    if issecretvalue(shown) then return end
    if healthBar.bbpNameRowShown == shown then return end
    healthBar.bbpNameRowShown = shown
    RestoreBlizzardLevelBadgeLayout(frame)
end

function RestoreBlizzardLevelBadgeLayout(frame)
    local levelFrame = frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() or not frame.unit then return end
    local followsHealthBar = levelFrame.bbpFollowsHealthBar
    local sideLevel = SideLevel()
    if not followsHealthBar and not sideLevel and not BetterBlizzPlatesDB.classicNameplates then return end

    local badgeSpace = BBP.GetLevelBadgeSpace(frame)
    local auraOffset = 5 + badgeSpace

    local auras = (followsHealthBar or sideLevel) and frame.AurasFrame
    if auras then
        if auras.CrowdControlListFrame then
            auras.CrowdControlListFrame:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", auraOffset, 0)
        end
        if auras.LossOfControlFrame then
            auras.LossOfControlFrame:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", auraOffset, 0)
        end
    end
    if sideLevel then return end

    local setupOptions = NamePlateSetupOptions
    local styles = NamePlateConstants and NamePlateConstants.NAME_ANCHOR_STYLES
    if not setupOptions or not styles or not frame.name then return end
    if frame.IsShowOnlyName and frame:IsShowOnlyName() then return end
    local style = setupOptions.unitNameAnchorStyle
    if style == styles.InsideHealthBar or style == styles.CenteredAboveHealthBar then return end

    local nameSpacing = setupOptions.healthBarToNameAboveSpacing or 0
    local healthText = NameRowHealthText(frame)
    frame.name:ClearAllPoints()
    frame.name:SetPoint("BOTTOMLEFT", frame.HealthBarsContainer, "TOPLEFT", 0, nameSpacing)
    if not followsHealthBar then
        local classicLevel = frame.ClassicLevelFrame
        local levelShown = not BetterBlizzPlatesDB.hideLevelFrameBackground and classicLevel and ((classicLevel.text and classicLevel.text:IsShown()) or (classicLevel.skull and classicLevel.skull:IsShown()))
        frame.name:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "TOPRIGHT", levelShown and CLASSIC_LEVEL_NAME_NUDGE or 0, nameSpacing)
    elseif healthText then
        frame.name:SetPoint("RIGHT", healthText, "LEFT", -2, 0)
    elseif badgeSpace > 0 and not LevelOutsideHealthBar() then
        frame.name:SetPoint("RIGHT", levelFrame, "RIGHT", 0, 0)
    else
        frame.name:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "TOPRIGHT", 0, nameSpacing)
    end
end

local function DisplayedLevelFrame(frame)
    if BBP.IsLevelHidden(frame) then return nil end
    local levelFrame = frame and frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() or not frame.unit then return nil end
    if not levelFrame:ShouldDisplay(frame.unit) then return nil end
    return levelFrame
end

local function LevelBadgeFrame(frame)
    if not LevelBadgeFollowsHealthBar() then return nil end
    return DisplayedLevelFrame(frame)
end

function BBP.GetLevelBadgeSpace(frame)
    if SideLevel() then
        if not DisplayedLevelFrame(frame) then return 0, 0 end
        return SIDE_LEVEL_X_OFFSET + SIDE_LEVEL_WIDTH, SIDE_LEVEL_X_OFFSET + SIDE_LEVEL_WIDTH / 2
    end
    if not LevelBadgeFrame(frame) then return 0, 0 end
    local width = GetLevelBadgeWidth()
    return width + LEVEL_BADGE_X_OFFSET, LEVEL_BADGE_X_OFFSET + width / 2
end

function BBP.GetLevelBarReserve(frame)
    if LevelOutsideHealthBar() then return 0 end
    return (BBP.GetLevelBadgeSpace(frame))
end

local CLASSIC_LEVEL_SPACE = 17

local function ClassicLevelSpace(frame)
    local db = BetterBlizzPlatesDB
    return (db.classicNameplates and not (db.hideLevelFrameBackground or BBP.IsLevelHidden(frame))) and CLASSIC_LEVEL_SPACE or 0
end

function BBP.GetLevelSpace(frame)
    return BBP.GetLevelBadgeSpace(frame) + ClassicLevelSpace(frame)
end

function BBP.UpdateLevelSpan(frame, space)
    local span = frame.bbpLevelSpan
    local healthBar = frame.HealthBarsContainer
    if not span or not healthBar then return end

    local levelFrame = LevelBadgeFrame(frame)
    space = space or BBP.GetLevelSpace(frame)
    if LevelOutsideHealthBar() then
        levelFrame, space = nil, 0
    end
    local relTo = levelFrame or healthBar
    if span.bbpRelTo == relTo and span.bbpSpace == space then return end
    span.bbpRelTo, span.bbpSpace = relTo, space

    span:ClearAllPoints()
    span:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
    if levelFrame then
        span:SetPoint("BOTTOMRIGHT", levelFrame, "BOTTOMRIGHT", 0, 0)
    else
        span:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", space, 0)
    end
end

local centeredAnchors = { TOP = true, BOTTOM = true, CENTER = true }

function BBP.GetLevelSpanAnchor(frame, anchorPoint)
    if not centeredAnchors[anchorPoint] or not frame.HealthBarsContainer then return frame.healthBar end
    if not frame.bbpLevelSpan then
        frame.bbpLevelSpan = CreateFrame("Frame", nil, frame)
        BBP.UpdateLevelSpan(frame)
    end
    return frame.bbpLevelSpan
end

local function ClassicLevelRowSpace(frame)
    if BBP.HideMaxLevelInPvP(frame and frame.unit) then return 0 end
    return ClassicLevelSpace(frame)
end

function BBP.UpdateLevelRow(frame, space)
    local row = frame.bbpLevelRow
    local healthBar = frame.HealthBarsContainer
    if not row or not healthBar then return end

    space = (space or BBP.GetLevelBadgeSpace(frame)) + ClassicLevelRowSpace(frame)
    if row.bbpSpace == space then return end
    row.bbpSpace = space

    row:ClearAllPoints()
    row:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
    row:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", space, 0)
end

function BBP.GetLevelRowAnchor(frame)
    if not frame.HealthBarsContainer then return frame.healthBar end
    if not frame.bbpLevelRow then
        frame.bbpLevelRow = CreateFrame("Frame", nil, frame)
    end
    BBP.UpdateLevelRow(frame)
    return frame.bbpLevelRow
end

local function RefreshLevelBadgeSpace(frame)
    local space = BBP.GetLevelBadgeSpace(frame)
    local previous = frame.bbpLevelBadgeSpace
    frame.bbpLevelBadgeSpace = space
    BBP.UpdateLevelSpan(frame, space + ClassicLevelSpace(frame))
    BBP.UpdateLevelRow(frame, space)
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

local ELITE_CLASSIFICATIONS = { elite = true, rareelite = true, worldboss = true, rare = true }
local SILVER_CLASSIFICATIONS = { rareelite = true, rare = true }
local ELITE_RING_LEVEL_X = 2
local ELITE_RING_HEALTHBAR_X = -8
local ELITE_RING_ATLAS = "Adventures-Ring-Gold-Dragon"
local ELITE_RING_ALT_ATLAS = "Adventure-Mission-Gold-Dragon"
local ELITE_RING_CLASSIC_X = 10.5
local ELITE_RING_Y = -1
local ELITE_RING_WIDTH = 38
local ELITE_RING_PADDING = 13

local function GetLevelOverlay(frame, levelFrame)
    local overlay = frame.bbpLevelOverlay
    if overlay then return overlay end
    overlay = CreateFrame("Frame", nil, levelFrame)
    overlay:SetAllPoints(levelFrame)
    overlay:SetFrameLevel(levelFrame:GetFrameLevel() + 1)
    overlay.placement = "badge"

    overlay.eliteRing = overlay:CreateTexture(nil, "ARTWORK")

    overlay.text = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    overlay.text:SetFont(LEVEL_TEXT_FONT, LEVEL_TEXT_SIZE)
    overlay.text:SetJustifyH("CENTER")
    overlay.text:SetPoint("CENTER", overlay, "CENTER", 0, 0)
    overlay.text:SetShadowColor(0, 0, 0, 1)
    overlay.text:SetShadowOffset(1, -1)

    overlay.skull = overlay:CreateTexture(nil, "OVERLAY")
    overlay.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    overlay.skull:SetPoint("CENTER", overlay, "CENTER", 0, 0)
    overlay.skull:SetSize(LEVEL_TEXT_SIZE * LEVEL_SKULL_PER_FONT_SIZE, LEVEL_TEXT_SIZE * LEVEL_SKULL_PER_FONT_SIZE)

    frame.bbpLevelOverlay = overlay
    return overlay
end

local function SetEliteRingAtlas(ring, atlas)
    if ring.bbpAtlas == atlas then return end
    ring.bbpAtlas = atlas
    local info = C_Texture.GetAtlasInfo(atlas)
    ring.atlasInfo = info
    if info then
        ring:SetTexture(info.file or info.filename)
    else
        ring:SetAtlas(atlas)
    end
end

local function UpdateLevelOverlayText(frame)
    local overlay = frame.bbpLevelOverlay
    local unit = frame.unit
    if not overlay or not unit then return end
    if not overlay.showText or (overlay.placement == "side" and not DisplayedLevelFrame(frame)) then
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

    local color = BBP.GetNameplateLevelColor(frame, level)
    if color then
        overlay.text:SetTextColor(color:GetRGB())
    end
    overlay.text:SetText(level)
    overlay.text:Show()
    overlay.skull:Hide()
end

function BBP.GetNameplateLevelColor(frame, level)
    local unit = frame.unit
    if not unit or not UnitCanAttack("player", unit) then return UNIT_LEVEL_NON_ATTACKABLE end
    local levelFrame = frame.PlayerLevelDiffFrame
    if not levelFrame or not levelFrame.GetDifficultyColor then return nil end
    return levelFrame:GetDifficultyColor((level or UnitEffectiveLevel(unit)) - UnitEffectiveLevel("player"))
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

function BBP.CanMoveLevelText()
    local db = BetterBlizzPlatesDB
    if db.classicNameplates then return db.hideLevelFrameBackground and true or false end
    return (db.classicRetailNameplates or db.hideLevelFrameBackground) and true or false
end

local function LevelTextSideGap(relPoint)
    if relPoint:find("RIGHT") then return SIDE_LEVEL_X_OFFSET end
    if relPoint:find("LEFT") then return -SIDE_LEVEL_X_OFFSET end
    return 0
end

local function PlaceLevelText(frame, overlay, db)
    local moved = db.moveLevelText and overlay.showText and frame.HealthBarsContainer and true or false
    local size = moved and db.levelTextSize or LEVEL_TEXT_SIZE
    if size <= 0 then size = LEVEL_TEXT_SIZE end
    local point = moved and (db.levelTextAnchor or "LEFT") or "CENTER"
    local relPoint = moved and (db.levelTextRelativeAnchor or "RIGHT") or "CENTER"
    local x = moved and ((db.levelTextXPos or 0) + LevelTextSideGap(relPoint)) or 0
    local y = moved and (db.levelTextYPos or 0) or 0
    local relTo = moved and frame.HealthBarsContainer or overlay
    if overlay.bbpTextSize ~= size then
        overlay.bbpTextSize = size
        overlay.text:SetFont(LEVEL_TEXT_FONT, size)
        overlay.skull:SetSize(size * LEVEL_SKULL_PER_FONT_SIZE, size * LEVEL_SKULL_PER_FONT_SIZE)
    end
    local layout = overlay.bbpTextLayout
    if layout and layout[1] == relTo and layout[2] == point and layout[3] == relPoint and layout[4] == x and layout[5] == y then return end
    overlay.bbpTextLayout = { relTo, point, relPoint, x, y }
    overlay.text:ClearAllPoints()
    overlay.text:SetPoint(point, relTo, relPoint, x, y)
    overlay.skull:ClearAllPoints()
    overlay.skull:SetPoint(point, relTo, relPoint, x, y)
end

local CLASSIC_LEVEL_TEXT_SIZE = 11

function BBP.PlaceClassicLevelText(frame)
    local classicLevel = frame and frame.ClassicLevelFrame
    if not classicLevel then return end
    local db = BetterBlizzPlatesDB
    local noBackground = db.hideLevelFrameBackground and true or false
    local moved = noBackground and db.moveLevelText and true or false
    local size = moved and db.levelTextSize or CLASSIC_LEVEL_TEXT_SIZE
    if size <= 0 then size = CLASSIC_LEVEL_TEXT_SIZE end
    local skullSize = moved and size * LEVEL_SKULL_PER_FONT_SIZE or 16
    local relTo = frame.HealthBarsContainer
    local textPoint, skullPoint, relPoint, textX, skullX, y
    if moved then
        textPoint = db.levelTextAnchor or "LEFT"
        skullPoint = textPoint
        relPoint = db.levelTextRelativeAnchor or "RIGHT"
        textX = (db.levelTextXPos or 0) + LevelTextSideGap(relPoint)
        skullX = textX
        y = db.levelTextYPos or 0
    else
        textPoint, skullPoint, relPoint, y = "CENTER", "LEFT", "RIGHT", 0
        textX = noBackground and 13 or 10
        skullX = noBackground and 4 or 2
    end
    local layout = classicLevel.bbpLayout
    if layout and layout[1] == textPoint and layout[2] == relPoint and layout[3] == textX and layout[4] == skullX and layout[5] == y and layout[6] == size then return end
    classicLevel.bbpLayout = { textPoint, relPoint, textX, skullX, y, size }
    classicLevel.text:SetFont(LEVEL_TEXT_FONT, size, "OUTLINE")
    classicLevel.text:ClearAllPoints()
    classicLevel.text:SetPoint(textPoint, relTo, relPoint, textX, y)
    classicLevel.skull:SetSize(skullSize, skullSize)
    classicLevel.skull:ClearAllPoints()
    classicLevel.skull:SetPoint(skullPoint, relTo, relPoint, skullX, y)
end

local function UpdateLevelOverlay(frame, levelFrame, db, levelHidden)
    local sideLevel = SideLevel() and frame.HealthBarsContainer and true or false
    local hideBackground = (db.hideLevelFrameBackground or sideLevel) and not levelHidden
    local ringOnHealthBar = levelHidden and frame.HealthBarsContainer and true or false
    local placement = (ringOnHealthBar and "ring") or (sideLevel and "side") or "badge"
    local showRing = false
    local classification
    if BBP.EliteRingActive() and (not levelHidden or ringOnHealthBar) and frame.unit then
        classification = UnitClassification(frame.unit)
        showRing = ELITE_CLASSIFICATIONS[classification] or false
    end

    local blizzardAlpha = hideBackground and 0 or 1
    if levelFrame.playerLevelDiffIcon then levelFrame.playerLevelDiffIcon:SetAlpha(blizzardAlpha) end
    if levelFrame.playerLevelDiffText then levelFrame.playerLevelDiffText:SetAlpha(blizzardAlpha) end
    if levelFrame.highLevelTexture then levelFrame.highLevelTexture:SetAlpha(blizzardAlpha) end
    if levelFrame.selectedBorder then levelFrame.selectedBorder:SetAlpha(db.hideTargetBorder and 0 or blizzardAlpha) end

    if not hideBackground and not showRing and not frame.bbpLevelOverlay then return end

    HookLevelDiffUpdates()
    local overlay = GetLevelOverlay(frame, levelFrame)
    overlay.showText = hideBackground
    PlaceLevelText(frame, overlay, db)
    if overlay.placement ~= placement then
        overlay.placement = placement
        overlay:ClearAllPoints()
        if placement == "ring" then
            overlay:SetParent(frame.HealthBarsContainer)
            overlay:SetSize(20, 20)
            overlay:SetPoint("CENTER", frame.HealthBarsContainer, "RIGHT", 0, 0)
        elseif placement == "side" then
            overlay:SetParent(frame.HealthBarsContainer)
            overlay:SetSize(SIDE_LEVEL_WIDTH, SIDE_LEVEL_HEIGHT)
            overlay:SetPoint("LEFT", frame.HealthBarsContainer, "RIGHT", SIDE_LEVEL_X_OFFSET, 0)
        else
            overlay:SetParent(levelFrame)
            overlay:SetAllPoints(levelFrame)
        end
        overlay:SetFrameLevel(math.max(overlay:GetParent():GetFrameLevel(), levelFrame:GetFrameLevel()) + 1)
    end
    SetEliteRingAtlas(overlay.eliteRing, db.levelEliteIconRingTexture and ELITE_RING_ALT_ATLAS or ELITE_RING_ATLAS)
    overlay.eliteRing:SetShown(showRing)
    overlay.eliteRing:SetDesaturated(SILVER_CLASSIFICATIONS[classification] or false)
    local healthBar = frame.HealthBarsContainer
    if healthBar then
        local x
        local side = "RIGHT"
        if db.levelEliteIconLeftSide then
            side = "LEFT"
            x = -ELITE_RING_HEALTHBAR_X
        elseif BBP.IsLevelHidden(frame) then
            x = ELITE_RING_HEALTHBAR_X
        elseif db.classicNameplates then
            x = ELITE_RING_CLASSIC_X + (db.hideLevelFrameBackground and 2 or 0)
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
            UpdateLevelOverlay(frame, levelFrame, db, BBP.IsLevelHidden(frame) or db.classicNameplates)
        end
        if frame and not frame:IsForbidden() then
            BBP.PlaceClassicLevelText(frame)
        end
    end
end

function BBP.UpdateBlizzardLevelFrame(frame)
    local levelFrame = frame and frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() then return end
    local db = BetterBlizzPlatesDB

    local levelHidden = BBP.IsLevelHidden(frame) or db.classicNameplates
    levelFrame:SetAlpha((levelHidden or SideLevel()) and 0 or 1)
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
        local healthBar = frame.HealthBarsContainer.healthBar
        if healthBar and healthBar.UpdateTextString then
            hooksecurefunc(healthBar, "UpdateTextString", function(self)
                RefreshNameRow(frame, self)
            end)
        end
    end
    SyncLevelBadge(frame)
    RestoreBlizzardLevelBadgeLayout(frame)
    RefreshLevelBadgeSpace(frame)
    UpdateLevelOverlay(frame, levelFrame, db, levelHidden)
end
