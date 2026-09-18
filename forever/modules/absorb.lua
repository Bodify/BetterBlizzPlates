-- Absorb Indicator
function BBP.AbsorbIndicator(frame)
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
    local absorb = UnitGetTotalAbsorbs(unit)
    frame.absorbIndicator:SetText(AbbreviateNumbers(absorb))
    frame.absorbIndicator:SetAlpha(absorb)
    frame.absorbIndicator:Show()
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
local PRD_OVERSHIELD_HOOKED = false

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

local function AdjustAbsorbGlow(absorbGlow, anchorBar, clamped)
    local barTex = anchorBar:GetStatusBarTexture()
    absorbGlow:ClearAllPoints()
    absorbGlow:SetPoint("TOPLEFT", barTex, "TOPLEFT", ABSORB_GLOW_OFFSET, 1)
    absorbGlow:SetPoint("BOTTOMLEFT", barTex, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, -1)
    absorbGlow:SetAlphaFromBoolean(clamped, ABSORB_GLOW_ALPHA, 0)
    absorbGlow:SetWidth(13)
end

local function CreateOvershieldBar(frame, healthBar, higherLayer)
    local overshieldBar = CreateFrame("StatusBar", nil, healthBar)
    overshieldBar:SetAllPoints(healthBar)
    overshieldBar:SetReverseFill(true)
    overshieldBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Overlay")
    overshieldBar:SetFrameLevel(healthBar:GetFrameLevel()+1)
    overshieldBar:SetStatusBarColor(1, 1, 1, 0.7)

    local barTex = overshieldBar:GetStatusBarTexture()
    barTex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", "REPEAT", "REPEAT")
    barTex:SetHorizTile(true)
    barTex:SetVertTile(true)
    if higherLayer then
        barTex:SetDrawLayer("ARTWORK", 1)
    else
        barTex:SetDrawLayer("ARTWORK", -3)
        hooksecurefunc(frame, "UpdateAnchors", function()
            AdjustAbsorbGlow(healthBar.overAbsorbGlow, overshieldBar, frame.healPredictionCalcClamped)
        end)
    end

    return overshieldBar
end

local function BBP_UpdatePersonalResourceFrame()
    local frame = PersonalResourceDisplayFrame
    local healthBar = frame.HealthBarsContainer.healthBar
    local absorbGlow = healthBar.overAbsorbGlow
    if not absorbGlow or absorbGlow:IsForbidden() then return end
    if not healthBar or healthBar:IsForbidden() then return end

    local overshieldBar = frame.bbfOvershieldBar
    UnitGetDetailedHealPrediction("player", nil, frame.healPredictionCalc)
    local _, clamped = frame.healPredictionCalc:GetDamageAbsorbs()
    local totalAbsorbs = UnitGetTotalAbsorbs("player") or 0
    local _, maxVal = healthBar:GetMinMaxValues()
    local totalAbsorbOverlay = healthBar.totalAbsorbOverlay

    overshieldBar:SetMinMaxValues(0, maxVal)
    overshieldBar:SetValue(totalAbsorbs)
    overshieldBar:SetAlphaFromBoolean(clamped, 1, 0)
    totalAbsorbOverlay:SetAlphaFromBoolean(clamped, 0, 1)
    AdjustAbsorbGlow(absorbGlow, overshieldBar, clamped)
end

function BBP.HookOverShieldPersonalResourceDisplay()
    if PRD_OVERSHIELD_HOOKED or not C_CVar.GetCVarBool("nameplateShowSelf") then return end
    if not BetterBlizzPlatesDB.overShields then return end

    local frame = PersonalResourceDisplayFrame
    local healthBar = frame.HealthBarsContainer.healthBar
    local totalAbsorbOverlay = healthBar.totalAbsorbOverlay
    local absorbGlow = healthBar.overAbsorbGlow

    if frame.bbOvershields then return end

    local prdEvents = CreateFrame("Frame")
    prdEvents:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    prdEvents:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
    prdEvents:RegisterUnitEvent("UNIT_HEALTH", "player")
    prdEvents:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    prdEvents:RegisterEvent("PLAYER_REGEN_DISABLED")

    totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", "REPEAT", "REPEAT")
    totalAbsorbOverlay:SetHorizTile(true)
    totalAbsorbOverlay:SetVertTile(true)
    totalAbsorbOverlay:SetVertexColor(1, 1, 1, 0.7)
    absorbGlow:SetDrawLayer("ARTWORK", 2)

    frame.bbfOvershieldBar = CreateOvershieldBar(frame, healthBar, true)
    frame.healPredictionCalc = CreateUnitHealPredictionCalculator()
    frame.healPredictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)

    prdEvents:SetScript("OnEvent", BBP_UpdatePersonalResourceFrame)
    BBP_UpdatePersonalResourceFrame()

    frame.bbOvershields = true
    PRD_OVERSHIELD_HOOKED = true
end

function BBP.CompactUnitFrame_UpdateHealPrediction(frame)
    if not frame.unit then return end
    local unit = frame.displayedUnit or frame.unit
    if not unit:find("nameplate") then return end
    if frame:IsForbidden() then return end

    local absorbGlow = frame.overAbsorbGlow
    if not absorbGlow or absorbGlow:IsForbidden() then return end

    local healthBar = frame.healthBar
    if not healthBar or healthBar:IsForbidden() then return end

    if not frame.bbfOvershieldBar then
        frame.bbfOvershieldBar = CreateOvershieldBar(frame, healthBar)
        frame.healPredictionCalc = CreateUnitHealPredictionCalculator()
        frame.healPredictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        absorbGlow:SetDrawLayer("ARTWORK", 1)
    end

    local overshieldBar = frame.bbfOvershieldBar

    UnitGetDetailedHealPrediction(unit, nil, frame.healPredictionCalc)
    local _, clamped = frame.healPredictionCalc:GetDamageAbsorbs()
    local totalAbsorbs = UnitGetTotalAbsorbs(unit) or 0
    local _, maxVal = healthBar:GetMinMaxValues()

    frame.healPredictionCalcClamped = clamped
    overshieldBar:SetMinMaxValues(0, maxVal)
    overshieldBar:SetValue(totalAbsorbs)
    overshieldBar:SetAlphaFromBoolean(clamped, 1, 0)
    AdjustAbsorbGlow(absorbGlow, overshieldBar, clamped)
end

function BBP.HookOverShields()
    if not BetterBlizzPlatesDB.overShields or COMPACT_UNITFRAME_OVERSHIELD_HOOKED then
        return
    end

    --hooksecurefunc("CompactUnitFrame_UpdateAll", BBP.CompactUnitFrame_UpdateAll)
    hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", BBP.CompactUnitFrame_UpdateHealPrediction)
    BBP.HookOverShieldPersonalResourceDisplay()

    for _, np in pairs(C_NamePlate.GetNamePlates()) do
        local frame = np.UnitFrame
        if frame then
            --BBP.CompactUnitFrame_UpdateAll(frame)
            BBP.CompactUnitFrame_UpdateHealPrediction(frame)
        end
    end

    COMPACT_UNITFRAME_OVERSHIELD_HOOKED = true
end