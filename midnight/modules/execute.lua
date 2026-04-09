local executeCurve
local executeCurveThreshold

local function GetExecuteCurve(threshold)
    if executeCurveThreshold ~= threshold then
        executeCurve = C_CurveUtil.CreateCurve()
        executeCurve:SetType(Enum.LuaCurveType.Linear)
        local t = threshold / 100
        executeCurve:AddPoint(0.0, 1)
        executeCurve:AddPoint(t, 1)
        executeCurve:AddPoint(t + 0.001, 0)
        executeCurve:AddPoint(1.0, 0)
        executeCurveThreshold = threshold
    end
    return executeCurve
end

local notFullCurve
local function GetNotFullCurve()
    if not notFullCurve then
        notFullCurve = C_CurveUtil.CreateCurve()
        notFullCurve:SetType(Enum.LuaCurveType.Step)
        notFullCurve:AddPoint(0.0, 1)
        notFullCurve:AddPoint(1.0, 0)
    end
    return notFullCurve
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
        config.executeIndicatorInRangeColor = BetterBlizzPlatesDB.executeIndicatorInRangeColor
        config.executeIndicatorInRangeColorRGB = BetterBlizzPlatesDB.executeIndicatorInRangeColorRGB
        config.executeIndicatorHideText = BetterBlizzPlatesDB.executeIndicatorHideText

        config.executeIndicatorInitialized = true
    end

    local unit = frame.displayedUnit

    if config.executeIndicatorTargetOnly and not UnitIsUnit("target", unit) then
        if frame.executeIndicator then
            frame.executeIndicator:SetAlpha(0)
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:SetAlpha(0)
        end
        return
    end

    -- Check for friendly status if required
    if not config.executeIndicatorFriendly then
        if info.isFriend then
            if frame.executeIndicator then
                frame.executeIndicator:SetAlpha(0)
            end
            if frame.executeIndicatorTexture then
                frame.executeIndicatorTexture:SetAlpha(0)
            end
            return
        end
    end

    if UnitIsUnit(frame.unit, "player") then
        if frame.executeIndicator then
            frame.executeIndicator:SetAlpha(0)
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:SetAlpha(0)
        end
        return
    end

    local healthPercentage = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
    if not healthPercentage then return end

    local belowThreshold = UnitHealthPercent(unit, true, GetExecuteCurve(config.executeIndicatorThreshold))
    local notFullHp = UnitHealthPercent(unit, true, GetNotFullCurve())

    if config.executeIndicatorHideText and not config.executeIndicatorUseTexture then
        if frame.executeIndicator then
            frame.executeIndicator:SetAlpha(0)
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:SetAlpha(0)
        end
    else
        local oppositeAnchor = BBP.GetOppositeAnchor(config.executeIndicatorAnchor)

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
            frame.executeIndicator:SetAlpha(0)
        else
            if frame.executeIndicatorTexture then
                frame.executeIndicatorTexture:SetAlpha(0)
            end
        end

        if config.executeIndicatorTestMode then
            if config.executeIndicatorUseTexture then
                local barWidth = frame.HealthBarsContainer:GetWidth()
                local textureXPos = (config.executeIndicatorThreshold / 100) * barWidth

                frame.executeIndicatorTexture:ClearAllPoints()
                frame.executeIndicatorTexture:SetPoint("CENTER", frame.HealthBarsContainer, "LEFT", textureXPos, 0)
                frame.executeIndicatorTexture:SetAlpha(1)
            else
                local testText = config.executeIndicatorShowDecimal and "19.5" or "19"
                if config.executeIndicatorPercentSymbol then
                    testText = testText .. "%"
                end
                frame.executeIndicator:SetText(testText)
                frame.executeIndicator:SetAlpha(1)
                frame.executeIndicator:SetScale(config.executeIndicatorScale or 1)
            end
            return
        end

        if config.executeIndicatorUseTexture then
            frame.executeIndicator:SetAlpha(0)

            local barWidth = frame.healthBar:GetWidth()
            local textureXPos = (config.executeIndicatorThreshold / 100) * barWidth

            frame.executeIndicatorTexture:ClearAllPoints()
            frame.executeIndicatorTexture:SetPoint("CENTER", frame.healthBar, "LEFT", textureXPos, 0)

            if config.executeIndicatorAlwaysOn then
                if config.executeIndicatorNotOnFullHp then
                    frame.executeIndicatorTexture:SetAlpha(notFullHp)
                else
                    frame.executeIndicatorTexture:SetAlpha(1)
                end
            else
                frame.executeIndicatorTexture:SetAlpha(belowThreshold)
            end
        else
            if frame.executeIndicatorTexture then
                frame.executeIndicatorTexture:SetAlpha(0)
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
                if config.executeIndicatorNotOnFullHp then
                    frame.executeIndicator:SetAlpha(notFullHp)
                else
                    frame.executeIndicator:SetAlpha(1)
                end
            else
                frame.executeIndicator:SetAlpha(belowThreshold)
            end
        end
    end

    if config.executeIndicatorInRangeColor and config.executeIndicatorInRangeColorRGB then
        if not frame.executeColorOverlay then
            frame.executeColorOverlay = frame.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
            frame.executeColorOverlay:SetAllPoints(frame.healthBar:GetStatusBarTexture())
        end
        if BetterBlizzPlatesDB.useCustomTextureForBars then
            frame.executeColorOverlay:SetTexture(frame.healthBar:GetStatusBarTexture():GetTexture())
        else
            frame.executeColorOverlay:SetAtlas(frame.healthBar:GetStatusBarTexture():GetAtlas())
        end
        local r, g, b = unpack(config.executeIndicatorInRangeColorRGB)
        frame.executeColorOverlay:SetVertexColor(r, g, b, 1)
        frame.executeColorOverlay:SetAlpha(belowThreshold)

        if not BetterBlizzPlatesDB.classicNameplates and not BetterBlizzPlatesDB.classicRetailNameplates then
            BBP.ApplyMidnightMask(frame, frame.executeColorOverlay)
        end
    else
        if frame.executeColorOverlay then
            frame.executeColorOverlay:SetAlpha(0)
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
        BBP.ExecuteIndicator(nameplate.UnitFrame)
    end
end