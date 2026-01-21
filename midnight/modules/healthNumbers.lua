function BBP.HealthNumbers(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    -- Initialize or update the health numbers display
    if not frame.healthNumbers then
        frame.healthNumbers = frame.bbpOverlay:CreateFontString(nil, "OVERLAY")
        frame.healthNumbers:SetTextColor(1, 1, 1)
        frame.healthNumbers:SetJustifyH("CENTER")

        -- Copy outline and shadow from frame.name
        local shadowColorR, shadowColorG, shadowColorB, shadowColorA = frame.name:GetShadowColor()
        local shadowOffsetX, shadowOffsetY = frame.name:GetShadowOffset()
        frame.healthNumbers:SetShadowColor(shadowColorR, shadowColorG, shadowColorB, shadowColorA)
        frame.healthNumbers:SetShadowOffset(shadowOffsetX, shadowOffsetY)
    end

    if not config.healthNumbersInitialized or BBP.needsUpdate then
        config.healthNumbersFriendly = BetterBlizzPlatesDB.healthNumbersFriendly
        config.healthNumbersAnchor = BetterBlizzPlatesDB.healthNumbersAnchor
        config.healthNumbersXPos = BetterBlizzPlatesDB.healthNumbersXPos
        config.healthNumbersYPos = BetterBlizzPlatesDB.healthNumbersYPos
        config.healthNumbersScale = BetterBlizzPlatesDB.healthNumbersScale
        config.healthNumbersTestMode = BetterBlizzPlatesDB.healthNumbersTestMode
        config.healthNumbersShowDecimal = BetterBlizzPlatesDB.healthNumbersShowDecimal
        config.healthNumbersPercentage = BetterBlizzPlatesDB.healthNumbersPercentage
        config.healthNumbersPercentSymbol = BetterBlizzPlatesDB.healthNumbersPercentSymbol
        config.healthNumbersNotOnFullHp = BetterBlizzPlatesDB.healthNumbersNotOnFullHp
        config.healthNumbersOnlyInCombat = BetterBlizzPlatesDB.healthNumbersOnlyInCombat
        config.healthNumbersUseMillions = BetterBlizzPlatesDB.healthNumbersUseMillions
        config.healthNumbersCurrentFull = BetterBlizzPlatesDB.healthNumbersCurrentFull
        config.healthNumbersCombined = BetterBlizzPlatesDB.healthNumbersCombined
        config.healthNumbersSwapped = BetterBlizzPlatesDB.healthNumbersSwapped
        config.healthNumbersTargetOnly = BetterBlizzPlatesDB.healthNumbersTargetOnly
        config.healthNumbersPlayers = BetterBlizzPlatesDB.healthNumbersPlayers
        config.healthNumbersNpcs = BetterBlizzPlatesDB.healthNumbersNpcs
        config.healthNumbersHideSelf = BetterBlizzPlatesDB.healthNumbersHideSelf
        config.healthNumbersClassColor = BetterBlizzPlatesDB.healthNumbersClassColor

        BBP.SetFontBasedOnOption(frame.healthNumbers, 9, BetterBlizzPlatesDB.healthNumbersFontOutline)

        config.healthNumbersInitialized = true
    end

    local unit = frame.unit

    local isPlayer = UnitIsPlayer(unit)
    local hideHealthNumbers = (config.healthNumbersNpcs and not config.healthNumbersPlayers and isPlayer) or
                             (config.healthNumbersPlayers and not config.healthNumbersNpcs and not isPlayer)

    if hideHealthNumbers or (config.healthNumbersHideSelf and UnitIsUnit(unit, "player")) then
        frame.healthNumbers:Hide()
        return
    end

    -- Hide health numbers if not the current target and the setting is enabled
    if config.healthNumbersTargetOnly and not UnitIsUnit(unit, "target") then
        frame.healthNumbers:Hide()
        return
    end

    -- Hide health numbers based on combat setting
    if config.healthNumbersOnlyInCombat and not UnitAffectingCombat(unit) then
        frame.healthNumbers:Hide()
        return
    end

    -- Hide health numbers for friendly units if not configured to show
    if not config.healthNumbersFriendly and info.isFriend then
        frame.healthNumbers:Hide()
        return
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local percent = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100) or 0

    local healthText = ""
    if config.healthNumbersCombined then
        local numericHealth = AbbreviateNumbers(health)
        local percentHealth = string.format("%.0f%%", percent)
        if config.healthNumbersSwapped then
            healthText = string.format("%s - %s", percentHealth, numericHealth)
        else
            healthText = string.format("%s - %s", numericHealth, percentHealth)
        end
    elseif config.healthNumbersCurrentFull then
        if config.healthNumbersPercentage then
            local formatStr = config.healthNumbersShowDecimal and "%.1f" or "%.0f"
            local currentHealthPercentage = string.format(formatStr, percent)
            local maxHealthPercentage = "100"
            if config.healthNumbersPercentSymbol then
                currentHealthPercentage = currentHealthPercentage .. "%"
                maxHealthPercentage = maxHealthPercentage .. "%"
            end
            if config.healthNumbersSwapped then
                healthText = string.format("%s / %s", maxHealthPercentage, currentHealthPercentage)
            else
                healthText = string.format("%s / %s", currentHealthPercentage, maxHealthPercentage)
            end
        else
            local currentHealthFormatted = AbbreviateNumbers(health)
            local maxHealthFormatted = AbbreviateNumbers(maxHealth)
            if config.healthNumbersSwapped then
                healthText = string.format("%s / %s", maxHealthFormatted, currentHealthFormatted)
            else
                healthText = string.format("%s / %s", currentHealthFormatted, maxHealthFormatted)
            end
        end
    elseif config.healthNumbersPercentage then
        local formatStr = config.healthNumbersShowDecimal and "%.1f" or "%.0f"
        healthText = string.format(formatStr, percent)
        if config.healthNumbersPercentSymbol then
            healthText = healthText .. "%"
        end
    else
        healthText = AbbreviateNumbers(health)
    end

    local oppositeAnchor = BBP.GetOppositeAnchor(config.healthNumbersAnchor)

    local justify = BetterBlizzPlatesDB.healthNumbersJustify
    if justify ~= "CENTER" then
        oppositeAnchor = justify
    end

    if config.healthNumbersClassColor then
        frame.healthNumbers:SetTextColor(frame.healthBar:GetStatusBarColor())
    end

    frame.healthNumbers:ClearAllPoints()
    frame.healthNumbers:SetPoint(oppositeAnchor, frame.healthBar, config.healthNumbersAnchor, config.healthNumbersXPos, config.healthNumbersYPos + -0.5)
    frame.healthNumbers:SetScale(config.healthNumbersScale or 1)

    if config.healthNumbersTestMode then
        local testCurrentHealth = 69000
        local testMaxHealth = 420000
        local testPercent = (testCurrentHealth / testMaxHealth) * 100

        if config.healthNumbersCombined then
            local numericHealth = AbbreviateNumbers(testCurrentHealth)
            local percentHealth = string.format("%.0f%%", testPercent)
            if config.healthNumbersSwapped then
                healthText = string.format("%s - %s", percentHealth, numericHealth)
            else
                healthText = string.format("%s - %s", numericHealth, percentHealth)
            end
        elseif config.healthNumbersCurrentFull then
            local currentHealthFormatted, maxHealthFormatted
            if config.healthNumbersPercentage then
                local formatStr = config.healthNumbersShowDecimal and "%.1f" or "%.0f"
                currentHealthFormatted = string.format(formatStr, testPercent)
                maxHealthFormatted = "100"
                if config.healthNumbersPercentSymbol then
                    currentHealthFormatted = currentHealthFormatted .. "%"
                    maxHealthFormatted = maxHealthFormatted .. "%"
                end
            else
                currentHealthFormatted = AbbreviateNumbers(testCurrentHealth)
                maxHealthFormatted = AbbreviateNumbers(testMaxHealth)
            end
            if config.healthNumbersSwapped then
                healthText = string.format("%s / %s", maxHealthFormatted, currentHealthFormatted)
            else
                healthText = string.format("%s / %s", currentHealthFormatted, maxHealthFormatted)
            end
        elseif config.healthNumbersPercentage then
            local formatStr = config.healthNumbersShowDecimal and "%.1f" or "%.0f"
            healthText = string.format(formatStr, testPercent)
            if config.healthNumbersPercentSymbol then
                healthText = healthText .. "%"
            end
        else
            healthText = AbbreviateNumbers(testCurrentHealth)
        end
    end

    frame.healthNumbers:SetText(healthText)
    frame.healthNumbers:Show()
end

local healthEventFrame
-- Toggle event listening on/off for Health Numbers if not enabled
function BBP.ToggleHealthNumbers()
    if BetterBlizzPlatesDB.healthNumbers then
        if not healthEventFrame then
            healthEventFrame = CreateFrame("Frame")
            healthEventFrame:SetScript("OnEvent", function(self, event, unit)
                local nameplate, frame = BBP.GetSafeNameplate(unit)
                if not frame then return end
                BBP.HealthNumbers(frame)
            end)
        end
        healthEventFrame:RegisterEvent("UNIT_HEALTH")
    else
        if healthEventFrame then
            healthEventFrame:UnregisterEvent("UNIT_HEALTH")
        end
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        BBP.HealthNumbers(nameplate.UnitFrame)
    end
end