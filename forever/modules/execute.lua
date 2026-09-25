local LSM = LibStub("LibSharedMedia-3.0")

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

local executeAlphaCurves = {}
local executeAlphaCurvesThreshold

local function GetExecuteAlphaCurve(threshold, alpha)
    if executeAlphaCurvesThreshold ~= threshold then
        executeAlphaCurves = {}
        executeAlphaCurvesThreshold = threshold
    end
    local curve = executeAlphaCurves[alpha]
    if not curve then
        curve = C_CurveUtil.CreateCurve()
        curve:SetType(Enum.LuaCurveType.Linear)
        local t = threshold / 100
        curve:AddPoint(0.0, 0)
        curve:AddPoint(t, 0)
        curve:AddPoint(t + 0.001, alpha)
        curve:AddPoint(1.0, alpha)
        executeAlphaCurves[alpha] = curve
    end
    return curve
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

local function RestoreHealthBarTexture(frame)
    if not frame.executeHidHealthBar then return end
    frame.executeHidHealthBar = nil
    local hpTexture = frame.healthBar and frame.healthBar:GetStatusBarTexture()
    if hpTexture then
        hpTexture:SetAlpha(frame.executeBaseAlpha or 1)
    end
end

local function ApplyExecuteHealthBarAlpha(frame)
    local hpTexture = frame.healthBar and frame.healthBar:GetStatusBarTexture()
    if not hpTexture then return end
    local unit = frame.displayedUnit or frame.unit
    if not unit then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
    local threshold = config and config.executeIndicatorThreshold
    if not threshold then return end
    hpTexture:SetAlpha(UnitHealthPercent(unit, true, GetExecuteAlphaCurve(threshold, frame.executeBaseAlpha or 1)))
    frame.executeHidHealthBar = true
end

local function HookHealthBarColor(frame)
    local healthBar = frame.healthBar
    if not healthBar or healthBar.bbpExecuteAlphaHook then return end
    healthBar.bbpExecuteAlphaHook = true
    hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b, a)
        if frame:IsForbidden() then return end
        if issecretvalue(a) or a == nil then
            frame.executeBaseAlpha = 1
        else
            frame.executeBaseAlpha = a
        end
        if frame.executeHidHealthBar then
            ApplyExecuteHealthBarAlpha(frame)
        end
    end)
end

local function HideExecuteIndicator(frame)
    if frame.executeIndicator then
        frame.executeIndicator:SetAlpha(0)
    end
    if frame.executeIndicatorTexture then
        frame.executeIndicatorTexture:SetAlpha(0)
    end
    if frame.executeColorOverlay then
        frame.executeColorOverlay:SetAlpha(0)
    end
    RestoreHealthBarTexture(frame)
end

BBP.HideExecuteIndicator = HideExecuteIndicator
BBP.RestoreExecuteHealthBarTexture = RestoreHealthBarTexture

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

    local unit = frame.displayedUnit or frame.unit
    if not unit then return end

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
                local hpHeight = frame.healthBar:GetHeight()
                local height = not issecretvalue(hpHeight) and hpHeight or frame.lastKnownHpHeight or 16
                if issecretvalue(height) and not frame.lastKnownHpHeight then
                    frame.executeIndicator.needsTextureResize = true
                end
                frame.executeIndicatorTexture:SetSize(1.5, height)
            end
            if frame.executeIndicator.needsTextureResize then
                local hpHeight = frame.healthBar:GetHeight()
                if not issecretvalue(hpHeight) then
                    frame.executeIndicatorTexture:SetHeight(hpHeight)
                    frame.executeIndicator.needsTextureResize = nil
                elseif frame.lastKnownHpHeight then
                    frame.executeIndicatorTexture:SetHeight(frame.lastKnownHpHeight)
                    frame.executeIndicator.needsTextureResize = nil
                end
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
                local hpWidth = frame.HealthBarsContainer:GetWidth()
                local barWidth = not issecretvalue(hpWidth) and hpWidth or frame.lastKnownHpWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
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
            if frame.executeColorOverlay then
                frame.executeColorOverlay:SetAlpha(0)
            end
            RestoreHealthBarTexture(frame)
            return
        end

        if config.executeIndicatorUseTexture then
            frame.executeIndicator:SetAlpha(0)

            local hpWidth = frame.healthBar:GetWidth()
            local barWidth = not issecretvalue(hpWidth) and hpWidth or frame.lastKnownHpWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
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
            frame.executeColorOverlay = CreateFrame("StatusBar", nil, frame.healthBar)
            frame.executeColorOverlay:SetAllPoints(frame.healthBar)
            frame.executeColorOverlay:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)
            frame.executeColorOverlay:SetMinMaxValues(frame.healthBar:GetMinMaxValues())
            frame.executeColorOverlay:SetValue(frame.healthBar:GetValue())
            frame.healthBar:HookScript("OnValueChanged", function(_, value)
                if frame:IsForbidden() then return end
                frame.executeColorOverlay:SetValue(value)
            end)
            frame.healthBar:HookScript("OnMinMaxChanged", function(_, min, max)
                if frame:IsForbidden() then return end
                frame.executeColorOverlay:SetMinMaxValues(min, max)
            end)
        end
        local db = BetterBlizzPlatesDB
        local overrideTex
        if db.targetIndicatorChangeTexture and frame.unit and UnitIsUnit(frame.unit, "target") then
            overrideTex = LSM:Fetch(LSM.MediaType.STATUSBAR, db.targetIndicatorTexture)
        elseif db.focusTargetIndicatorChangeTexture and frame.unit and UnitIsUnit(frame.unit, "focus") then
            overrideTex = LSM:Fetch(LSM.MediaType.STATUSBAR, db.focusTargetIndicatorTexture)
        end
        if overrideTex then
            frame.executeColorOverlay:SetStatusBarTexture(overrideTex)
        elseif db.useCustomTextureForBars then
            frame.executeColorOverlay:SetStatusBarTexture(frame.healthBar:GetStatusBarTexture():GetTexture())
        else
            local atlas = frame.healthBar:GetStatusBarTexture():GetAtlas()
            frame.executeColorOverlay:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
            frame.executeColorOverlay:GetStatusBarTexture():SetAtlas(atlas)
        end
        local r, g, b, a = unpack(config.executeIndicatorInRangeColorRGB)
        frame.executeColorOverlay:SetStatusBarColor(r, g, b, a or 1)
        frame.executeColorOverlay:SetAlpha(belowThreshold)

        HookHealthBarColor(frame)
        ApplyExecuteHealthBarAlpha(frame)

        if not BetterBlizzPlatesDB.classicNameplates and not BetterBlizzPlatesDB.classicRetailNameplates then
            BBP.ApplyMidnightMask(frame, frame.executeColorOverlay:GetStatusBarTexture())
        end
    else
        if frame.executeColorOverlay then
            frame.executeColorOverlay:SetAlpha(0)
        end
        RestoreHealthBarTexture(frame)
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
    local enabled = BetterBlizzPlatesDB.executeIndicator
    if enabled then
        executeEventFrame:RegisterEvent("UNIT_HEALTH")
    else
        executeEventFrame:UnregisterEvent("UNIT_HEALTH")
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        if not nameplate.UnitFrame:IsForbidden() then
            if enabled then
                BBP.ExecuteIndicator(nameplate.UnitFrame)
            else
                HideExecuteIndicator(nameplate.UnitFrame)
            end
        end
    end
end