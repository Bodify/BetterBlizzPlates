local LSM = LibStub("LibSharedMedia-3.0")

local SECRET_HEALER_MAP = { HEALER = "bags-icon-addslots", TANK = "", DAMAGER = "" }
local SECRET_BAR_TEXTURE_MAP = { HEALER = "", TANK = "", DAMAGER = "" }

local function SetRedCross(texture, red)
    if red then
        texture:SetDesaturated(true)
        texture:SetVertexColor(1,0,0)
    else
        texture:SetDesaturated(false)
        texture:SetVertexColor(1,1,1)
    end
end

local function ShowSecretHealer(frame, arenaIndex, red)
    if not frame.healerIndicatorSecret then
        frame.healerIndicatorSecret = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.healerIndicatorSecret:SetAllPoints(frame.healerIndicator)
    end
    BBP.SetSecretArenaRoleTexture(frame.healerIndicatorSecret, arenaIndex, SECRET_HEALER_MAP)
    SetRedCross(frame.healerIndicatorSecret, red)
    frame.healerIndicatorSecret:Show()
end

local function GetHealerBarOverlay(frame)
    if frame.healerBarOverlay then return frame.healerBarOverlay end
    local healthBar = frame.healthBar
    frame.healerBarClip = CreateFrame("Frame", nil, healthBar)
    frame.healerBarClip:SetFrameLevel(healthBar:GetFrameLevel() + 1)
    frame.healerBarClip:SetClipsChildren(true)
    frame.healerBarOverlay = frame.healerBarClip:CreateTexture(nil, "ARTWORK")
    frame.healerBarOverlay:SetAllPoints(healthBar)
    hooksecurefunc(healthBar, "SetStatusBarColor", function(_, r, g, b)
        if frame:IsForbidden() then return end
        frame.healerBarOverlay:SetVertexColor(r, g, b)
    end)
    return frame.healerBarOverlay
end

-- Healer Indicator
local function UpdateHealerIcon(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    frame.mainHealerColor = nil

    if frame.healerIndicatorSecret then
        frame.healerIndicatorSecret:Hide()
    end

    if info.isSelf then
        if frame.healerIndicator then
            frame.healerIndicator:Hide()
            return
        end
    end

    if not config.healerIndicatorInitialized or BBP.needsUpdate then
        config.healerIndicatorAnchor = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
        config.healerIndicatorXPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
        config.healerIndicatorYPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
        config.healerIndicatorTestMode = BetterBlizzPlatesDB.healerIndicatorTestMode
        config.healerIndicatorArenaOnly = BetterBlizzPlatesDB.healerIndicatorArenaOnly
        config.healerIndicatorBgOnly = BetterBlizzPlatesDB.healerIndicatorBgOnly
        config.healerIndicatorRedCrossEnemy = BetterBlizzPlatesDB.healerIndicatorRedCrossEnemy
        config.healerIndicatorScale = BetterBlizzPlatesDB.healerIndicatorScale
        config.healerIndicatorEnemyOnly = BetterBlizzPlatesDB.healerIndicatorEnemyOnly
        config.healerIndicatorColorEnemyHealthbar = BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbar
        config.healerIndicatorColorFriendlyHealthbar = BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbar
        config.healerIndicatorColorEnemyHealthbarRGB = BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB
        config.healerIndicatorColorFriendlyHealthbarRGB = BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB

        config.healerIndicatorInitialized = true
    end

    local anchorPoint = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
    local xPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
    local scale = BetterBlizzPlatesDB.healerIndicatorScale

    -- Initialize
    if not frame.healerIndicator then
        frame.healerIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.healerIndicator:SetAtlas("bags-icon-addslots")
        frame.healerIndicator:SetSize(13, 13)
    end

    if not info.isFriend then
        xPos = BetterBlizzPlatesDB.healerIndicatorEnemyXPos
        yPos = BetterBlizzPlatesDB.healerIndicatorEnemyYPos
        anchorPoint = BetterBlizzPlatesDB.healerIndicatorEnemyAnchor
        scale = BetterBlizzPlatesDB.healerIndicatorEnemyScale
    end

    -- Set position and scale dynamically
    frame.healerIndicator:ClearAllPoints()
    frame.healerIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.healerIndicator:SetScale(scale)

    -- Test mode
    if config.healerIndicatorTestMode then
        frame.healerIndicator:Show()
        SetRedCross(frame.healerIndicator, config.healerIndicatorRedCrossEnemy and not info.isFriend)
        return true
    end

    if (config.healerIndicatorArenaOnly and not BBP.isInArena) or (config.healerIndicatorBgOnly and not BBP.isInBg) then
        if config.healerIndicatorArenaOnly and config.healerIndicatorBgOnly then
            if not BBP.isInPvP then
                frame.healerIndicator:Hide()
                return
            end
        else
            frame.healerIndicator:Hide()
            return
        end
    end

    -- Condition check: healerIndicatorEnemyOnly
    local specID, secretIndex = BBP.GetSpecID(frame)
    if specID or secretIndex then
        if frame.needsHealerUpdate then
            frame.needsHealerUpdate = nil
            BBP.pendingHealerCount = (BBP.pendingHealerCount or 0) - 1
        end
    else
        if not frame.needsHealerUpdate then
            frame.needsHealerUpdate = true
            BBP.pendingHealerCount = (BBP.pendingHealerCount or 0) + 1
        end
    end

    if secretIndex then
        frame.healerIndicator:Hide()
        if config.healerIndicatorEnemyOnly and not info.isEnemy then return end
        ShowSecretHealer(frame, secretIndex, config.healerIndicatorRedCrossEnemy and not info.isFriend)
        return nil, secretIndex
    end

    if BBP.IsSpecHealer(frame) then
        if config.healerIndicatorEnemyOnly and not info.isEnemy then
            if frame.healerIndicator then frame.healerIndicator:Hide() end
            return
        end
        SetRedCross(frame.healerIndicator, config.healerIndicatorRedCrossEnemy and not info.isFriend)
        if config.healerIndicatorColorEnemyHealthbar and not info.isFriend then
            frame.mainHealerColor = config.healerIndicatorColorEnemyHealthbarRGB
            frame.healthBar:SetStatusBarColor(unpack(frame.mainHealerColor))
            frame.needsRecolor = true
        elseif config.healerIndicatorColorFriendlyHealthbar and info.isFriend then
            frame.mainHealerColor = config.healerIndicatorColorFriendlyHealthbarRGB
            frame.healthBar:SetStatusBarColor(unpack(frame.mainHealerColor))
            frame.needsRecolor = true
        end
        frame.healerIndicator:Show()
        return true
    else
        frame.healerIndicator:Hide()
    end
end

function BBP.HealerIndicator(frame)
    local wasTextured = frame.bbpHealerTextured or frame.bbpHealerSecretIndex
    local isHealer, secretIndex = UpdateHealerIcon(frame)
    local changeTexture = BetterBlizzPlatesDB.healerIndicatorChangeTexture and not frame.BetterBlizzPlates.unitInfo.isSelf
    frame.bbpHealerTextured = changeTexture and isHealer or nil
    frame.bbpHealerSecretIndex = changeTexture and secretIndex or nil
    if wasTextured or frame.bbpHealerTextured or frame.bbpHealerSecretIndex then
        BBP.ApplyIndicatorBarTexture(frame)
    end
end

function BBP.UpdateHealerBarOverlay(frame, source)
    local db = BetterBlizzPlatesDB
    if not frame.bbpHealerSecretIndex or source == "target" or (source == "focus" and not db.healerIndicatorTextureOverFocus) then
        if frame.healerBarClip then
            frame.healerBarClip:Hide()
        end
        return
    end

    local healthBar = frame.healthBar
    local overlay = GetHealerBarOverlay(frame)
    local clip = frame.healerBarClip
    clip:ClearAllPoints()
    clip:SetPoint("TOPLEFT", healthBar, "TOPLEFT")
    clip:SetPoint("BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    if not db.classicNameplates and not db.classicRetailNameplates then
        BBP.ApplyMidnightMask(frame, overlay)
    end
    SECRET_BAR_TEXTURE_MAP.HEALER = LSM:Fetch(LSM.MediaType.STATUSBAR, db.healerIndicatorTexture)
    BBP.SetSecretArenaRoleTexture(overlay, frame.bbpHealerSecretIndex, SECRET_BAR_TEXTURE_MAP)
    overlay:SetVertexColor(healthBar:GetStatusBarColor())
    clip:Show()
end
