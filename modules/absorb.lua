-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Get opposite anchor of main anchor to always have it outside of nameplate
function BBP.GetOppositeAnchor(anchor)
    local opposites = {
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        TOPLEFT = "BOTTOMRIGHT",
        TOPRIGHT = "BOTTOMLEFT",
        BOTTOMLEFT = "TOPRIGHT",
        BOTTOMRIGHT = "TOPLEFT",
    }
    return opposites[anchor] or "CENTER"
end

-- Absorb Indicator
function BBP.AbsorbIndicator(frame)
    local unit = frame.displayedUnit
    local anchorPoint = BetterBlizzPlatesDB["absorbIndicatorAnchor"] or "LEFT"
    local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
    local xPos = BetterBlizzPlatesDB["absorbIndicatorXPos"] or 0
    local yPos = BetterBlizzPlatesDB["absorbIndicatorYPos"] or 0

    -- Initialize
    if not frame.absorbIndicator then
        frame.absorbIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.absorbIndicator, 10)
        frame.absorbIndicator:SetTextColor(1, 1, 1)
    end

    frame.absorbIndicator:ClearAllPoints()
    frame.absorbIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos -2, yPos)
    frame.absorbIndicator:SetScale(absorbIndicatorScale or 1)

    -- Test mode
    if BetterBlizzPlatesDB.absorbIndicatorTestMode then
        frame.absorbIndicator:SetText("69k")
        frame.absorbIndicator:Show()
        return
    end

    -- Condition check: absorbIndicatorEnemyOnly
    if BetterBlizzPlatesDB.absorbIndicatorEnemyOnly and (not UnitIsEnemy("player", unit)) then
        if frame.absorbIndicator then frame.absorbIndicator:Hide() end
        return
    end

    -- Condition check: absorbIndicatorOnPlayersOnly
    if BetterBlizzPlatesDB.absorbIndicatorOnPlayersOnly and (not UnitIsPlayer(unit)) then
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