local active
local prdHooked

local function SetAlpha(holder, alpha)
    if not holder or holder:IsForbidden() then return end
    if holder.myHealPrediction then holder.myHealPrediction:SetAlpha(alpha) end
    if holder.otherHealPrediction then holder.otherHealPrediction:SetAlpha(alpha) end
end

local function PrdHealthBar()
    local prd = PersonalResourceDisplayFrame
    return prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar
end

local function HidePrd()
    if active then
        SetAlpha(PrdHealthBar(), 0)
    end
end

function BBP.HideHealPrediction(frame)
    if frame.bbpHealPredHidden then return end
    frame.bbpHealPredHidden = true
    SetAlpha(frame, 0)
end

function BBP.ToggleHideHealPrediction()
    local on = BetterBlizzPlatesDB.hideHealPrediction
    if not on and not active then return end
    active = on
    local alpha = on and 0 or 1
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        if frame then
            frame.bbpHealPredHidden = on or nil
            SetAlpha(frame, alpha)
        end
    end
    SetAlpha(PrdHealthBar(), alpha)
    if on and not prdHooked and PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.Setup then
        prdHooked = true
        hooksecurefunc(PersonalResourceDisplayFrame, "Setup", HidePrd)
    end
end
