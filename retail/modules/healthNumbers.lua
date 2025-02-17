-- Helper function to format health numbers
local function FormatHealthValue(health, useMillions, showDecimal)
    local formatString
    if health >= 1000000 then
        if useMillions then
            formatString = showDecimal and "%.1fm" or "%.0fm"
            return string.format(formatString, health / 1000000)
        else
            formatString = showDecimal and "%.0fk" or "%.0fk"
            return string.format(formatString, health / 1000)  -- Format as thousands, not millions
        end
    elseif health >= 1000 then
        formatString = showDecimal and "%.1fk" or "%.0fk"
        return string.format(formatString, health / 1000)
    else
        return tostring(health)
    end
end

-- Update the Execute Indicator
function BBP.HealthNumbers(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

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

        config.healthNumbersInitialized = true
    end

    local unit = frame.unit

    local isPlayer = UnitIsPlayer(unit)
    local hideHealthNumbers = (config.healthNumbersNpcs and not config.healthNumbersPlayers and isPlayer) or
                             (config.healthNumbersPlayers and not config.healthNumbersNpcs and not isPlayer)

    if hideHealthNumbers or (config.healthNumbersHideSelf and UnitIsUnit(unit, "player")) then
        if frame.healthNumbers then
            frame.healthNumbers:Hide()
        end
        return
    end

    -- Hide health numbers if not the current target and the setting is enabled
    if config.healthNumbersTargetOnly and not UnitIsUnit(unit, "target") then
        if frame.healthNumbers then
            frame.healthNumbers:Hide()
        end
        return
    end

    -- Hide health numbers based on combat setting
    if config.healthNumbersOnlyInCombat and not UnitAffectingCombat(unit) then
        if frame.healthNumbers then
            frame.healthNumbers:Hide()
        end
        return
    end

    -- Hide health numbers for friendly units if not configured to show
    if not config.healthNumbersFriendly and info.isFriend then
        if frame.healthNumbers then
            frame.healthNumbers:Hide()
        end
        return
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)

    -- Check if health is full and config.healthNumbersNotOnFullHp is set
    if config.healthNumbersNotOnFullHp and health == maxHealth then
        if frame.healthNumbers then
            frame.healthNumbers:Hide()
        end
        return
    end

    -- Determine the appropriate health text based on configuration
    local healthText = ""
    if config.healthNumbersCombined then
        -- New setting: show both the numeric value and percentage
        local numericHealth = FormatHealthValue(health, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
        local percentHealth = string.format("%.0f%%", (health / maxHealth) * 100)
        if config.healthNumbersSwapped then
            healthText = percentHealth .. " - " .. numericHealth
        else
            healthText = numericHealth .. " - " .. percentHealth
        end
    elseif config.healthNumbersCurrentFull then
        if config.healthNumbersPercentage then
            -- Format both current and max health as percentages
            local currentHealthPercentage = string.format(config.healthNumbersShowDecimal and "%.1f%%" or "%.0f%%", (health / maxHealth) * 100)
            local maxHealthPercentage = "100%"
            if config.healthNumbersSwapped then
                healthText = maxHealthPercentage .. " / " .. currentHealthPercentage
            else
                healthText = currentHealthPercentage .. " / " .. maxHealthPercentage
            end
            if not config.healthNumbersPercentSymbol then
                -- Remove percentage symbol if not needed
                currentHealthPercentage = string.format(config.healthNumbersShowDecimal and "%.1f" or "%.0f", (health / maxHealth) * 100)
                healthText = currentHealthPercentage .. " / 100"
            end
        else
            -- Default to showing raw numbers
            local currentHealthFormatted = FormatHealthValue(health, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
            local maxHealthFormatted = FormatHealthValue(maxHealth, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
            if config.healthNumbersSwapped then
                healthText = maxHealthFormatted .. " / " .. currentHealthFormatted
            else
                healthText = currentHealthFormatted .. " / " .. maxHealthFormatted
            end
        end
    elseif config.healthNumbersPercentage then
        -- Format the percentage based on whether decimals are shown or not
        healthText = string.format(config.healthNumbersShowDecimal and "%.1f" or "%.0f", (health / maxHealth) * 100)
        if config.healthNumbersPercentSymbol then
            healthText = healthText .. "%"
        end
    else
        healthText = FormatHealthValue(health, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
    end

    local oppositeAnchor = BBP.GetOppositeAnchor(config.healthNumbersAnchor)

    -- Initialize or update the health numbers display
    if not frame.healthNumbers then
        frame.healthNumbers = frame.bbpOverlay:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.healthNumbers, 9, BetterBlizzPlatesDB.healthNumbersFontOutline)
        frame.healthNumbers:SetTextColor(1, 1, 1)
        frame.healthNumbers:SetJustifyH("CENTER")
    end

    if config.healthNumbersClassColor then
        -- if isPlayer then
        --     local _, class = UnitClass(unit)
        --     local classColor = RAID_CLASS_COLORS[class]
        --     frame.healthNumbers:SetTextColor(classColor.r, classColor.g, classColor.b)
        -- else
        --     frame.healthNumbers:SetTextColor(1, 1, 1)
        -- end
        frame.healthNumbers:SetTextColor(frame.healthBar:GetStatusBarColor())
    end

    frame.healthNumbers:ClearAllPoints()
    frame.healthNumbers:SetPoint(oppositeAnchor, frame.healthBar, config.healthNumbersAnchor, config.healthNumbersXPos, config.healthNumbersYPos + -0.5)
    frame.healthNumbers:SetScale(config.healthNumbersScale or 1)

    if config.healthNumbersTestMode then
        -- Set base test values for health.
        local testCurrentHealth = 69000  -- Represents current health.
        local testMaxHealth = 420000     -- Represents maximum health.

        -- Determine the format based on configuration
        if config.healthNumbersCurrentFull then
            -- Format both current and max health.
            local currentHealthFormatted, maxHealthFormatted
            if config.healthNumbersPercentage then
                currentHealthFormatted = string.format(config.healthNumbersShowDecimal and "%.1f" or "%.0f", (testCurrentHealth / testMaxHealth) * 100)
                maxHealthFormatted = "100"
                -- Check and append the percentage symbol if required
                if config.healthNumbersPercentSymbol then
                    currentHealthFormatted = currentHealthFormatted .. "%"
                    maxHealthFormatted = maxHealthFormatted .. "%"
                end
            else
                currentHealthFormatted = FormatHealthValue(testCurrentHealth, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
                maxHealthFormatted = FormatHealthValue(testMaxHealth, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
            end
            if config.healthNumbersSwapped then
                healthText = maxHealthFormatted .. " / " .. currentHealthFormatted
            else
                healthText = currentHealthFormatted .. " / " .. maxHealthFormatted
            end
        elseif config.healthNumbersPercentage then
            -- Only current health as a percentage of max
            healthText = string.format(config.healthNumbersShowDecimal and "%.1f" or "%.0f", (testCurrentHealth / testMaxHealth) * 100)
            if config.healthNumbersPercentSymbol then
                healthText = healthText .. "%"
            end
        else
            -- Default to showing current health in raw format
            healthText = FormatHealthValue(testCurrentHealth, config.healthNumbersUseMillions, config.healthNumbersShowDecimal)
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