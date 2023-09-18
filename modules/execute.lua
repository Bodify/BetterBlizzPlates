-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Update the Execute Indicator
function BBP.ExecuteIndicator(frame)
    local unit = frame.displayedUnit
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercentage = (health / maxHealth) * 100

    -- Initialize
    if not frame.executeIndicator then
        frame.executeIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.executeIndicator, 8, "THICKOUTLINE")
        frame.executeIndicator:SetTextColor(1, 1, 1)
        frame.executeIndicator:SetPoint("LEFT", frame.healthBar, "LEFT", 24, -0.5)
    end

    if BetterBlizzPlatesDB.executeIndicatorTestMode then
        frame.executeIndicator:SetText("19.5")
        frame.executeIndicator:Show()
        return
    end

    -- Check if health is below 40% and if so show Execute Indicator
    if healthPercentage < 40 and healthPercentage > 0.1 and not UnitIsFriend("player", unit) then
        frame.executeIndicator:SetText(string.format("%.1f", healthPercentage))
        frame.executeIndicator:Show()
    else
        frame.executeIndicator:Hide()
    end
end

-- Event listening for Execute Indicator
local executeEventFrame = CreateFrame("Frame")
executeEventFrame:SetScript("OnEvent", function(self, event, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate then
        BBP.ExecuteIndicator(nameplate.UnitFrame)
    end
end)

-- Toggle event listening on/off for Execute Indicator if not enabled
function BBP.ToggleExecuteIndicator(value)
    if BetterBlizzPlatesDB.executeIndicator then
        executeEventFrame:RegisterEvent("UNIT_HEALTH")
        executeEventFrame:RegisterEvent("UNIT_MAXHEALTH")
    else
        executeEventFrame:UnregisterEvent("UNIT_HEALTH")
        executeEventFrame:UnregisterEvent("UNIT_MAXHEALTH")
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        BBP.ExecuteIndicator(nameplate.UnitFrame)
    end
end