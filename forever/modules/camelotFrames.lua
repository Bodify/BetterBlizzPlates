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
        local levelShown = classicLevel and ((classicLevel.text and classicLevel.text:IsShown()) or (classicLevel.skull and classicLevel.skull:IsShown()))
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

function BBP.UpdateBlizzardLevelFrame(frame)
    local levelFrame = frame and frame.PlayerLevelDiffFrame
    if not levelFrame or levelFrame:IsForbidden() then return end
    local db = BetterBlizzPlatesDB

    levelFrame:SetAlpha((db.hideLevelFrame or db.classicNameplates) and 0 or 1)
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
end
