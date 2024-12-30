local absorbSpells = {
    [17] = true, -- Priest: Power Word: Shield
    [47753] = true, -- Priest: Divine Aegis
    [86273] = true, -- Paladin: Illuminated Healing
    [96263] = true, -- Paladin: Sacred Shield
    [62606] = true, -- Druid: Savage Defense
    [77535] = true, -- DK: Blood Shield
    [1463] = true, -- Mage: Mana Shield
    [11426] = true, -- Mage: Ice Barrier
    [98864] = true, -- Mage: Ice Barrier
    [55277] = true, -- Shaman: Totem Shield
}

local function ComputeAbsorb(unit)
    local value = 0
    for index = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId, _, _, _, _, _, _, absorb = UnitAura(unit, index)
        if not name then break end
        if absorbSpells[spellId] and absorb then
            value = value + absorb
        end
    end
    return value
end

-- Absorb Indicator
function BBP.AbsorbIndicator(frame)
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
        frame.absorbIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
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
    local absorb = ComputeAbsorb(frame.unit) or 0
    if absorb > 100 then
        local displayValue
        if absorb >= 1000 then
            displayValue = string.format("%.1fk", absorb / 1000)
        else
            displayValue = tostring(absorb)
        end
        frame.absorbIndicator:SetText(displayValue)
        frame.absorbIndicator:Show()
    elseif frame.absorbIndicator then
        frame.absorbIndicator:Hide()
    end
end

local playerName = UnitName("player")

-- Event listener for Absorb Indicator
local absorbEventFrame = CreateFrame("Frame")
absorbEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = select(1, ...)
        local nameplate, frame = BBP.GetSafeNameplate(unit)
        if frame then
            BBP.AbsorbIndicator(frame)
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName = CombatLogGetCurrentEventInfo()
        if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_REMOVED" then
            local spellId = select(12, CombatLogGetCurrentEventInfo())
            if not absorbSpells[spellId] then return end
        end
        --RefreshUnit(MyAbsorbAddon.allstates, destName)
        if destName == playerName then
            --RefreshUnit(MyAbsorbAddon.allstates, "player")
        end
    end
end)

-- Toggle Event Registration
function BBP.ToggleAbsorbIndicator(value)
    if BetterBlizzPlatesDB.absorbIndicator then
        --absorbEventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED") --bodifycata
        absorbEventFrame:RegisterEvent("UNIT_HEALTH")
        absorbEventFrame:RegisterEvent("UNIT_MAXHEALTH")
        absorbEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        absorbEventFrame:UnregisterAllEvents()
    end
end

local ABSORB_GLOW_ALPHA = 0.4;
local ABSORB_GLOW_OFFSET = -5;
local COMPACT_UNITFRAME_OVERSHIELD_HOOKED = false

function BBP.CompactUnitFrame_UpdateAll(frame)
    if frame.unit and frame.unit:find("nameplate") then
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
                newAbsorbGlow:SetIgnoreParentAlpha(true)
                newAbsorbGlow:SetAlpha(ABSORB_GLOW_ALPHA)
                newAbsorbGlow:SetBlendMode(absorbGlow:GetBlendMode())
                newAbsorbGlow:SetParent(absorbGlow:GetParent())
                newAbsorbGlow:SetWidth(absorbGlow:GetWidth())
                newAbsorbGlow:SetHeight(healthBar:GetHeight()+4)

                absorbGlow.replaced = newAbsorbGlow
            end
            absorbGlow:SetAlpha(0);
            absorbGlow.replaced:SetAlpha((healthBar:GetAlpha() == 0 and 0) or (absorbGlow:IsShown() and ABSORB_GLOW_ALPHA or 0))
        end
    end
end

function BBP.CompactUnitFrame_UpdateHealPrediction(frame)
    if frame.unit and frame.unit:find("nameplate") then
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

        local _, maxHealth = healthBar:GetMinMaxValues();
        if maxHealth <= 0 then
            return
        end

        local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
        if totalAbsorb > maxHealth then
            totalAbsorb = maxHealth;
        end

        if totalAbsorb > 0 then -- show overlay when there's a positive absorb amount
            if absorbBar:IsShown() then -- If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
                absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
                absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
            else
                absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
                absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);
            end

            local totalWidth, totalHeight = healthBar:GetSize();
            local barSize = totalAbsorb / maxHealth * totalWidth;

            absorbOverlay:SetWidth(barSize);
            absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
            absorbOverlay:Show();
            -- frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
        end

        local absorbGlow = frame.overAbsorbGlow
        if absorbGlow.replaced then
            absorbGlow:SetAlpha(0);
            absorbGlow.replaced:SetAlpha((healthBar:GetAlpha() == 0 and 0) or (absorbGlow:IsShown() and ABSORB_GLOW_ALPHA or 0))
            absorbOverlay:SetDrawLayer("OVERLAY")
        end
    end
end

function BBP.HookOverShields()
    -- if not BetterBlizzPlatesDB.overShields or COMPACT_UNITFRAME_OVERSHIELD_HOOKED then
    --     return
    -- end

    -- hooksecurefunc("CompactUnitFrame_UpdateAll", BBP.CompactUnitFrame_UpdateAll)
    -- hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", BBP.CompactUnitFrame_UpdateHealPrediction)

    -- for _, np in pairs(C_NamePlate.GetNamePlates()) do
    --     local frame = np.UnitFrame
    --     if frame then
    --         BBP.CompactUnitFrame_UpdateAll(frame)
    --         BBP.CompactUnitFrame_UpdateHealPrediction(frame)
    --     end
    -- end

    -- COMPACT_UNITFRAME_OVERSHIELD_HOOKED = true
end