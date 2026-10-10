local function UpdateExecuteSkull(frame, config, show)
    if not config.executeSkull or not show then
        if frame.executeSkull then
            frame.executeSkull:Hide()
        end
        return
    end
    local skull = frame.executeSkull
    if not skull then
        skull = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        skull:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\Islands-AzeriteBoss.tga")
        frame.executeSkull = skull
    end
    local scale = config.executeSkullScale or 1
    local x = config.executeSkullXPos or 0
    local y = (config.executeSkullYPos or 0) + 0.5
    local anchorTo = config.executeSkullAttachToHealth and frame.healthBar:GetStatusBarTexture() or frame.healthBar
    if skull.scale ~= scale or skull.x ~= x or skull.y ~= y or skull.anchorTo ~= anchorTo then
        skull.scale, skull.x, skull.y, skull.anchorTo = scale, x, y, anchorTo
        skull:SetSize(23 * scale, 24 * scale)
        skull:ClearAllPoints()
        skull:SetPoint("LEFT", anchorTo, "RIGHT", x, y)
    end
    skull:Show()
end

local function HideExecuteIndicator(frame)
    if frame.executeIndicator then
        frame.executeIndicator:Hide()
    end
    if frame.executeIndicatorTexture then
        frame.executeIndicatorTexture:Hide()
    end
    if frame.executeSkull then
        frame.executeSkull:Hide()
    end
end

-- Update the Execute Indicator
function BBP.ExecuteIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    -- Initialize settings if needed
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
        config.executeIndicatorUseTexture = BetterBlizzPlatesDB.executeIndicatorUseTexture
        config.executeIndicatorTargetOnly = BetterBlizzPlatesDB.executeIndicatorTargetOnly
        config.executeSkull = BetterBlizzPlatesDB.executeSkull
        config.executeSkullScale = BetterBlizzPlatesDB.executeSkullScale
        config.executeSkullXPos = BetterBlizzPlatesDB.executeSkullXPos
        config.executeSkullYPos = BetterBlizzPlatesDB.executeSkullYPos
        config.executeSkullAttachToHealth = BetterBlizzPlatesDB.executeSkullAttachToHealth
        config.executeSkullKeepIndicator = BetterBlizzPlatesDB.executeSkullKeepIndicator

        config.executeIndicatorInitialized = true
    end

    local unit = frame.displayedUnit

    if config.executeIndicatorTargetOnly and not UnitIsUnit("target", unit) then
        HideExecuteIndicator(frame)
        return
    end

    -- Check for friendly status if required
    if not config.executeIndicatorFriendly then
        if info.isFriend then
            HideExecuteIndicator(frame)
            return
        end
    end

    if UnitIsUnit(frame.unit, "player") then
        HideExecuteIndicator(frame)
        return
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercentage = (health / maxHealth) * 100

    if not healthPercentage or maxHealth == 0 then
        HideExecuteIndicator(frame)
        return
    end

    UpdateExecuteSkull(frame, config, config.executeIndicatorTestMode or healthPercentage <= config.executeIndicatorThreshold)

    if config.executeSkull and not config.executeSkullKeepIndicator then
        if frame.executeIndicator then
            frame.executeIndicator:Hide()
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
        return
    end

    local oppositeAnchor = BBP.GetOppositeAnchor(config.executeIndicatorAnchor)

    -- Initialize the font string and texture for the Execute Indicator
    if not frame.executeIndicator then
        frame.executeIndicator = frame.bbpOverlay:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.executeIndicator, 10, "THICKOUTLINE")
        frame.executeIndicator:SetTextColor(1, 1, 1)
        frame.executeIndicator:SetJustifyH("CENTER")
    end

    if config.executeIndicatorUseTexture then
        if not frame.executeIndicatorTexture then
            frame.executeIndicatorTexture = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
            frame.executeIndicatorTexture:SetSize(1.5, frame.healthBar:GetHeight())
        end
        if info.isTarget then
            frame.executeIndicatorTexture:SetColorTexture(unpack(BetterBlizzPlatesDB.npBorderTargetColorRGB))
        else
            frame.executeIndicatorTexture:SetColorTexture(0,0,0,1)
        end
        frame.executeIndicator:Hide()
    else
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
    end

    -- Test mode logic
    if config.executeIndicatorTestMode then
        if config.executeIndicatorUseTexture then
            -- Position the texture based on the threshold for testing
            local barWidth = frame.healthBar:GetWidth()
            local textureXPos = (config.executeIndicatorThreshold / 100) * barWidth

            frame.executeIndicatorTexture:ClearAllPoints()
            frame.executeIndicatorTexture:SetPoint("CENTER", frame.healthBar, "LEFT", textureXPos, 0)
            frame.executeIndicatorTexture:Show()
        else
            -- Show test text
            local testText = config.executeIndicatorShowDecimal and "19.5" or "19"
            if config.executeIndicatorPercentSymbol then
                testText = testText .. "%"
            end
            frame.executeIndicator:SetText(testText)
            frame.executeIndicator:Show()
            frame.executeIndicator:SetScale(config.executeIndicatorScale or 1)
        end
        return
    end

    if config.executeIndicatorUseTexture then
        frame.executeIndicator:Hide()

        local barWidth = frame.healthBar:GetWidth()
        local textureXPos = (config.executeIndicatorThreshold / 100) * barWidth

        frame.executeIndicatorTexture:ClearAllPoints()
        frame.executeIndicatorTexture:SetPoint("CENTER", frame.healthBar, "LEFT", textureXPos, 0)

        if config.executeIndicatorAlwaysOn then
            if config.executeIndicatorNotOnFullHp then
                -- Show the texture if health is below 99%
                if healthPercentage < 99 then
                    frame.executeIndicatorTexture:Show()
                else
                    frame.executeIndicatorTexture:Hide()
                end
            else
                -- Always show the texture if Always On is true and not restricting full HP
                frame.executeIndicatorTexture:Show()
            end
        else
            -- Only show texture if health is below the threshold
            if healthPercentage <= config.executeIndicatorThreshold then
                frame.executeIndicatorTexture:Show()
            else
                frame.executeIndicatorTexture:Hide()
            end
        end
    else
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
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
        local text = config.executeIndicatorShowDecimal and string.format("%.1f", healthPercentage) or string.format("%d", healthPercentage)
        if config.executeIndicatorPercentSymbol then
            text = text .. "%"
        end
        frame.executeIndicator:SetText(text)

        if config.executeIndicatorAlwaysOn then
            if config.executeIndicatorNotOnFullHp and healthPercentage < 99 then
                frame.executeIndicator:Show()
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
function BBP.ToggleExecuteIndicator()
    if BetterBlizzPlatesDB.executeIndicator then
        executeEventFrame:RegisterEvent("UNIT_HEALTH")
    else
        executeEventFrame:UnregisterEvent("UNIT_HEALTH")
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        if BetterBlizzPlatesDB.executeIndicator then
            BBP.ExecuteIndicator(nameplate.UnitFrame)
        else
            HideExecuteIndicator(nameplate.UnitFrame)
        end
    end
end