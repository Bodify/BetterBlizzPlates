-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Absorb Indicator
function BBP.AbsorbIndicator(frame)
    local unit = frame.displayedUnit
    local anchorPoint = BetterBlizzPlatesDB["absorbIndicatorAnchor"] or "LEFT"
    local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
    local xPos = BetterBlizzPlatesDB["absorbIndicatorXPos"] or 0
    local yPos = BetterBlizzPlatesDB["absorbIndicatorYPos"] or 0
    local enemyOnly = BetterBlizzPlatesDB.absorbIndicatorEnemyOnly and (not UnitIsEnemy("player", unit))
    local playersOnly = BetterBlizzPlatesDB.absorbIndicatorOnPlayersOnly and (not UnitIsPlayer(unit))

    -- Initialize
    if not frame.absorbIndicator then
        frame.absorbIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
        frame.absorbIndicator:SetTextColor(1, 1, 1)
    end

    frame.absorbIndicator:ClearAllPoints()
    frame.absorbIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos -2, yPos)
    frame.absorbIndicator:SetScale(BetterBlizzPlatesDB.absorbIndicatorScale or 1)
    BBP.SetFontBasedOnOption(frame.absorbIndicator, 10, "OUTLINE")

    -- Test mode
    if BetterBlizzPlatesDB.absorbIndicatorTestMode then
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
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplate then
            BBP.AbsorbIndicator(nameplate.UnitFrame)
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