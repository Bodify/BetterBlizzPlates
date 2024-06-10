-- Update the Execute Indicator
function BBP.ExecuteIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.executeIndicatorInitialized or BBP.needsUpdate then
        config.executeIndicatorFriendly = BetterBlizzPlatesDB.executeIndicatorFriendly
        config.executeIndicatorAnchor = BetterBlizzPlatesDB.executeIndicatorAnchor
        config.executeIndicatorXPos = BetterBlizzPlatesDB.executeIndicatorXPos
        config.executeIndicatorYPos = BetterBlizzPlatesDB.executeIndicatorYPos
        config.executeIndicatorScale = BetterBlizzPlatesDB.executeIndicatorScale
        config.executeIndicatorTestMode = BetterBlizzPlatesDB.executeIndicatorTestMode
        config.executeIndicatorShowDecimal = BetterBlizzPlatesDB.executeIndicatorShowDecimal
        config.executeIndicatorPercentSymbol = BetterBlizzPlatesDB.executeIndicatorPercentSymbol
        config.executeIndicatorNotOnFullHp = BetterBlizzPlatesDB.executeIndicatorNotOnFullHp
        config.executeIndicatorThreshold = BetterBlizzPlatesDB.executeIndicatorThreshold
        config.executeIndicatorAlwaysOn = BetterBlizzPlatesDB.executeIndicatorAlwaysOn

        config.executeIndicatorInitialized = true
    end


    local unit = frame.displayedUnit

    if not config.executeIndicatorFriendly then
        if info.isFriend then
            return
        end
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercentage = (health / maxHealth) * 100
    local oppositeAnchor = BBP.GetOppositeAnchor(config.executeIndicatorAnchor)

    -- Initialize
    if not frame.executeIndicator then
        frame.executeIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.executeIndicator, 10, "THICKOUTLINE")
        frame.executeIndicator:SetTextColor(1, 1, 1)
        frame.executeIndicator:SetJustifyH("CENTER")
    end

    frame.executeIndicator:ClearAllPoints()
    if config.executeIndicatorAnchor == "LEFT" then
        frame.executeIndicator:SetPoint(config.executeIndicatorAnchor, frame.healthBar, config.executeIndicatorAnchor, config.executeIndicatorXPos + 24, config.executeIndicatorYPos + -0.5)
    elseif config.executeIndicatorAnchor == "RIGHT" then
        frame.executeIndicator:SetPoint(config.executeIndicatorAnchor, frame.healthBar, config.executeIndicatorAnchor, config.executeIndicatorXPos, config.executeIndicatorYPos + -0.5)
    else
        frame.executeIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.executeIndicatorAnchor, config.executeIndicatorXPos, config.executeIndicatorYPos + -0.5)
    end
    frame.executeIndicator:SetScale(config.executeIndicatorScale or 1)

    if config.executeIndicatorTestMode then
        if config.executeIndicatorShowDecimal then
            frame.executeIndicator:SetText("19.5")
        else
            frame.executeIndicator:SetText("19")
        end
        frame.executeIndicator:Show()
        if config.executeIndicatorPercentSymbol then
            frame.executeIndicator:SetText(frame.executeIndicator:GetText() .. "%")
        end
        return
    end

    -- Check if health is below 40% and if so show Execute Indicator
    if healthPercentage > 0.1 then
        local text
        if healthPercentage == 100 then
            text = "100"
        elseif config.executeIndicatorShowDecimal then
            text = string.format("%.1f", healthPercentage)
        else
            text = string.format("%d", healthPercentage)
        end
        if config.executeIndicatorPercentSymbol then
            text = text .. "%"
        end

        frame.executeIndicator:SetText(text)

        if config.executeIndicatorAlwaysOn then
            if config.executeIndicatorNotOnFullHp then
                if healthPercentage < 99 then
                    frame.executeIndicator:Show()
                else
                    frame.executeIndicator:Hide()
                end
            else
                frame.executeIndicator:Show()
            end
        else
            if healthPercentage < config.executeIndicatorThreshold then
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
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if frame then
        BBP.ExecuteIndicator(frame)
    end
end)

-- Toggle event listening on/off for Execute Indicator if not enabled
function BBP.ToggleExecuteIndicator(value)
    if BetterBlizzPlatesDB.executeIndicator then
        executeEventFrame:RegisterEvent("UNIT_HEALTH")
    else
        executeEventFrame:UnregisterEvent("UNIT_HEALTH")
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        BBP.ExecuteIndicator(nameplate.UnitFrame)
    end
end