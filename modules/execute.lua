-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Update the Execute Indicator
function BBP.ExecuteIndicator(frame)
    local unit = frame.displayedUnit

    if not BetterBlizzPlatesDB.executeIndicatorFriendly then
        if UnitIsFriend("player", unit) then
            return
        end
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercentage = (health / maxHealth) * 100
    local anchorPoint = BetterBlizzPlatesDB.executeIndicatorAnchor or "LEFT"
    local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
    local xPos = BetterBlizzPlatesDB.executeIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.executeIndicatorYPos or 0
    local scale = BetterBlizzPlatesDB.executeIndicatorScale
    local testMode = BetterBlizzPlatesDB.executeIndicatorTestMode
    local showDecimal = BetterBlizzPlatesDB.executeIndicatorShowDecimal
    local percentSymbol = BetterBlizzPlatesDB.executeIndicatorPercentSymbol

    -- Initialize
    if not frame.executeIndicator then
        frame.executeIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.executeIndicator, 10, "THICKOUTLINE")
        frame.executeIndicator:SetTextColor(1, 1, 1)
    end

    frame.executeIndicator:ClearAllPoints()
    if anchorPoint == "LEFT" then
        frame.executeIndicator:SetPoint(anchorPoint, frame.healthBar, anchorPoint, xPos + 24, yPos + -0.5)
    elseif anchorPoint == "RIGHT" then
        frame.executeIndicator:SetPoint(anchorPoint, frame.healthBar, anchorPoint, xPos, yPos + -0.5)
    else
        frame.executeIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos, yPos + -0.5)
    end
    frame.executeIndicator:SetScale(scale or 1)

    if testMode then
        if showDecimal then
            frame.executeIndicator:SetText("19.5")
        else
            frame.executeIndicator:SetText("19")
        end
        frame.executeIndicator:Show()
        if percentSymbol then
            frame.executeIndicator:SetText(frame.executeIndicator:GetText() .. "%")
        end
        return
    end

    -- Check if health is below 40% and if so show Execute Indicator
    if healthPercentage > 0.1 then
        local alwaysOn = BetterBlizzPlatesDB.executeIndicatorAlwaysOn
        local text
        if healthPercentage == 100 then
            text = "100"
        elseif showDecimal then
            text = string.format("%.1f", healthPercentage)
        else
            text = string.format("%d", healthPercentage)
        end
        if percentSymbol then
            text = text .. "%"
        end

        frame.executeIndicator:SetText(text)

        if alwaysOn then
            local hideOnFullHp = BetterBlizzPlatesDB.executeIndicatorNotOnFullHp
            if hideOnFullHp then
                if healthPercentage < 99 then
                    frame.executeIndicator:Show()
                else
                    frame.executeIndicator:Hide()
                end
            else
                frame.executeIndicator:Show()
            end
        else
            local threshold = BetterBlizzPlatesDB.executeIndicatorThreshold
            if healthPercentage < threshold then
                frame.executeIndicator:Show()
            else
                frame.executeIndicator:Hide()
            end
        end
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