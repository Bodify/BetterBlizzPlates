-- Absorb Indicator
function BBP.AbsorbIndicator(frame)
    if frame:IsForbidden() then return end
    --if not frame or frame.unit then return end
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    if not config.absorbIndicatorInitialized or BBP.needsUpdate then
        config.absorbIndicatorAnchor = BetterBlizzPlatesDB.absorbIndicatorAnchor or "LEFT"
        config.absorbIndicatorXPos = BetterBlizzPlatesDB.absorbIndicatorXPos
        config.absorbIndicatorYPos = BetterBlizzPlatesDB.absorbIndicatorYPos
        config.absorbIndicatorEnemyOnly = BetterBlizzPlatesDB.absorbIndicatorEnemyOnly
        config.absorbIndicatorOnPlayersOnly = BetterBlizzPlatesDB.absorbIndicatorOnPlayersOnly
        config.absorbIndicatorScale = BetterBlizzPlatesDB.absorbIndicatorScale
        config.absorbIndicatorTestMode = BetterBlizzPlatesDB.absorbIndicatorTestMode

        config.absorbIndicatorInitialized = true
    end

    local unit = frame.unit
    local oppositeAnchor = BBP.GetOppositeAnchor(config.absorbIndicatorAnchor)
    local enemyOnly = config.absorbIndicatorEnemyOnly and (not info.isEnemy or not info.isNeutral)
    local playersOnly = config.absorbIndicatorOnPlayersOnly and (not info.isPlayer)

    -- Initialize
    if not frame.absorbIndicator then
        frame.absorbIndicator = frame.bbpOverlay:CreateFontString(nil, "OVERLAY")
        frame.absorbIndicator:SetTextColor(1, 1, 1)
    end

    frame.absorbIndicator:ClearAllPoints()
    frame.absorbIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.absorbIndicatorAnchor, config.absorbIndicatorXPos -2, config.absorbIndicatorYPos)
    frame.absorbIndicator:SetScale(config.absorbIndicatorScale or 1)
    BBP.SetFontBasedOnOption(frame.absorbIndicator, 10, "OUTLINE")

    -- Test mode
    if config.absorbIndicatorTestMode then
        frame.absorbIndicator:SetText("69k")
        frame.absorbIndicator:Show()
        return
    end

    -- Condition check: absorbIndicatorEnemyOnly
    if enemyOnly then
        if frame.absorbIndicator then frame.absorbIndicator:Hide() end
        return
    end

    -- Condition check: absorbIndicatorOnPlayersOnly
    if playersOnly then
        if frame.absorbIndicator then frame.absorbIndicator:Hide() end
        return
    end

    -- Check absorb amount and hide if less than 1k
    local absorb = UnitGetTotalAbsorbs(unit) or 0
    if absorb >= 1000000 then
        local displayValue = string.format("%.1fm", absorb / 1000000)
        frame.absorbIndicator:SetText(displayValue)
        frame.absorbIndicator:Show()
    elseif absorb >= 1000 then
        local displayValue = math.floor(absorb / 1000) .. "k"
        frame.absorbIndicator:SetText(displayValue)
        frame.absorbIndicator:Show()
    else
        frame.absorbIndicator:Hide()
    end
end

-- Event listener for Absorb Indicator
local absorbEventFrame = CreateFrame("Frame")
absorbEventFrame:SetScript("OnEvent", function(self, event, ...)
    local unit = ...
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if frame then
        BBP.AbsorbIndicator(frame)
    end
end)

-- Toggle Event Registration
function BBP.ToggleAbsorbIndicator(value)
    if BetterBlizzPlatesDB.absorbIndicator then
        absorbEventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    else
        absorbEventFrame:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    end
end

local ABSORB_GLOW_ALPHA = 0.4;
local ABSORB_GLOW_OFFSET = -5;
local COMPACT_UNITFRAME_OVERSHIELD_HOOKED = false

function BBP.CompactUnitFrame_UpdateAll(frame)
    if frame.unit and frame.unit:find("nameplate") then
        if frame:IsForbidden() then return end
        local absorbBar = frame.totalAbsorb;
        if not absorbBar or absorbBar:IsForbidden() then
            return
        end

        local absorbOverlay = frame.totalAbsorbOverlay;
        if not absorbOverlay or absorbOverlay:IsForbidden() then
            return
        end

        local healthBar = frame.healthBar;
        if not healthBar or healthBar:IsForbidden() then
            return
        end

        absorbOverlay:SetParent(healthBar);
        absorbOverlay:ClearAllPoints(); -- we'll be attaching the overlay on heal prediction update.
        absorbOverlay:SetDrawLayer("OVERLAY")

        local absorbGlow = frame.overAbsorbGlow;
        if absorbGlow and not absorbGlow:IsForbidden() then
            -- absorbGlow:ClearAllPoints();
            -- absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
            -- absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
            -- absorbGlow:SetDrawLayer("OVERLAY")

            if not absorbGlow.replaced then
                local newAbsorbGlow = frame:CreateTexture(nil, "OVERLAY")
                newAbsorbGlow:SetTexture(absorbGlow:GetTexture())
                newAbsorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 2);
                newAbsorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, -2);
                --newAbsorbGlow:SetIgnoreParentAlpha(true)
                --newAbsorbGlow:SetAlpha(ABSORB_GLOW_ALPHA)
                newAbsorbGlow:SetBlendMode(absorbGlow:GetBlendMode())
                newAbsorbGlow:SetParent(absorbGlow:GetParent())
                newAbsorbGlow:SetWidth(absorbGlow:GetWidth())
                newAbsorbGlow:SetHeight(healthBar:GetHeight()+4)

                absorbGlow.replaced = newAbsorbGlow
            end
            absorbGlow:SetAlpha(0);
            absorbGlow.replaced:SetAlpha((frame.HealthBarsContainer:GetAlpha() == 0 and 0) or (frame:GetAlpha() == 0 and 0) or (absorbGlow:IsShown() and ABSORB_GLOW_ALPHA or 0))
        end
    end
end

local function CreateAbsorbBar(frame)
    if frame.absorbBar then return end -- Prevent duplicate elements
    -- Absorb Fill (Total Absorb)
    frame.absorbBar = frame:CreateTexture()
    frame.absorbBar:SetDrawLayer("ARTWORK", 1)
    frame.absorbBar:SetTexture("Interface\\RaidFrame\\Shield-Fill")
    --frame.absorbBar:SetHorizTile(false)
    --frame.absorbBar:SetVertTile(false)
    frame.absorbBar:Hide()

    -- Absorb Overlay
    frame.absorbOverlay = frame:CreateTexture()
    frame.absorbOverlay:SetDrawLayer("OVERLAY", 2)
    frame.absorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
    frame.absorbOverlay:SetHorizTile(true)
    frame.absorbOverlay.tileSize = 32
    frame.absorbOverlay:SetAllPoints(frame.absorbBar)
    frame.absorbOverlay:Hide()

    -- Over Absorb Glow
    frame.absorbGlow = frame:CreateTexture()
    frame.absorbGlow:SetDrawLayer("OVERLAY", 3)
    frame.absorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    frame.absorbGlow:SetBlendMode("ADD")
    frame.absorbGlow:SetWidth(8)
    frame.absorbGlow:SetAlpha(0.6)
    frame.absorbGlow:Hide()
    frame.absorbGlow:SetParent(frame.healthbar or frame.healthBar or frame.HealthBar)
end

function BBP.CompactUnitFrame_UpdateHealPrediction(frame)
    if frame:IsForbidden() then return end
    if frame.unit and frame.unit:find("nameplate") then
        local healthBar = frame.healthBar or frame.HealthBar or frame.healthbar
        if not healthBar then return end
        local unit = frame.unit

        CreateAbsorbBar(frame) -- Ensure elements exist
        local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0

        if totalAbsorb <= 0 then
            -- Hide absorb visuals if no absorb is present
            frame.absorbGlow:Hide()
            frame.absorbOverlay:Hide()
            frame.absorbBar:Hide()
            return
        end

        local currentHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
        if maxHealth <= 0 then return end

        local missingHealth = maxHealth - currentHealth
        local totalWidth = healthBar:GetWidth()

        -- **Absorb Bar - stays within missing health space**
        local absorbWidth = math.min(totalAbsorb, missingHealth) / maxHealth * totalWidth
        local offset = currentHealth / maxHealth * totalWidth -- Where absorb starts

        if absorbWidth > 0 then
            frame.absorbBar:ClearAllPoints()
            frame.absorbBar:SetParent(healthBar)
            frame.absorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", offset, 0)
            frame.absorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", offset, 0)
            frame.absorbBar:SetWidth(absorbWidth)
            frame.absorbBar:Show()
        else
            frame.absorbBar:Hide()
        end

        -- **Absorb Overlay - always shows full absorb & moves backward if needed**
        frame.absorbOverlay:ClearAllPoints()
        frame.absorbOverlay:SetParent(healthBar)

        local overlayOffset = offset
        local overlayWidth = totalAbsorb / maxHealth * totalWidth

        if (currentHealth + totalAbsorb) > maxHealth then
            -- **Absorb exceeds max health → overlay moves backward onto health**
            local overAbsorb = (currentHealth + totalAbsorb) - maxHealth
            local overAbsorbWidth = overAbsorb / maxHealth * totalWidth

            overlayWidth = overlayWidth + overAbsorbWidth
            overlayOffset = offset - overAbsorbWidth
        end

        frame.absorbOverlay:SetPoint("TOPLEFT", healthBar, "TOPLEFT", math.max(overlayOffset, 0), 0)
        frame.absorbOverlay:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", math.max(overlayOffset, 0), 0)
        frame.absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0)
        frame.absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
        frame.absorbOverlay:SetWidth(math.min(overlayWidth, totalWidth)) -- Ensure it doesn't exceed total width
        frame.absorbOverlay:SetTexCoord(0, frame.absorbOverlay:GetWidth() / frame.absorbOverlay.tileSize, 0, 1)
        frame.absorbOverlay:Show()

        -- **Absorb Glow - attaches left when absorb exceeds max HP**
        frame.absorbGlow:ClearAllPoints()
        if (currentHealth + totalAbsorb) > maxHealth then
            -- Over-absorbing → Glow appears on the left side
            frame.absorbGlow:SetPoint("TOPLEFT", frame.absorbOverlay, "TOPLEFT", -4, 1)
            frame.absorbGlow:SetPoint("BOTTOMLEFT", frame.absorbOverlay, "BOTTOMLEFT", -4, -1)
        else
            -- Normal absorb → Glow on the right
            frame.absorbGlow:SetPoint("TOPRIGHT", frame.absorbOverlay, "TOPRIGHT", 6, 1)
            frame.absorbGlow:SetPoint("BOTTOMRIGHT", frame.absorbOverlay, "BOTTOMRIGHT", 6, -1)
            frame.absorbOverlay:SetPoint("TOPRIGHT", frame.absorbBar, "TOPRIGHT", 0, 0)
            frame.absorbOverlay:SetPoint("BOTTOMRIGHT", frame.absorbBar, "BOTTOMRIGHT", 0, 0)
        end
        frame.absorbBar:SetTexCoord(0, 1, 0, 1)
        frame.absorbGlow:Show()
    end
end

function BBP.HookOverShields()
    if not BetterBlizzPlatesDB.overShields or COMPACT_UNITFRAME_OVERSHIELD_HOOKED then
        return
    end

    --hooksecurefunc("CompactUnitFrame_UpdateAll", BBP.CompactUnitFrame_UpdateAll)
    hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", BBP.CompactUnitFrame_UpdateHealPrediction)

    for _, np in pairs(C_NamePlate.GetNamePlates()) do
        local frame = np.UnitFrame
        if frame then
            --BBP.CompactUnitFrame_UpdateAll(frame)
            BBP.CompactUnitFrame_UpdateHealPrediction(frame)
        end
    end

    COMPACT_UNITFRAME_OVERSHIELD_HOOKED = true
end