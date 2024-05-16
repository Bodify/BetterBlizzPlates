-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

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
    local absorb = UnitGetTotalAbsorbs(unit) or 0
    if absorb > 1000 then
        local displayValue = math.floor(absorb / 1000) .. "k"
        frame.absorbIndicator:SetText(displayValue)
        frame.absorbIndicator:Show()
    elseif frame.absorbIndicator then
        frame.absorbIndicator:Hide()
    end
end

-- Event listener for Absorb Indicator
local absorbEventFrame = CreateFrame("Frame")
absorbEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        local unit = ...
        local nameplate, frame = BBP.GetSafeNameplate(unit)
        if frame then
            BBP.AbsorbIndicator(frame)
        end
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