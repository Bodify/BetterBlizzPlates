local function ShouldForceShow()
    return BetterBlizzPlatesDB.druidAlwaysShowCombos and GetComboPoints("player", "target") > 0
end

local function UpdateDruidComboPoints()
    local frame = PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.classFrame
    if not frame or frame:IsForbidden() then return end
    if UnitPowerType("player") == Enum.PowerType.Energy then return end

    if ShouldForceShow() then
        frame:Show()
    else
        frame:Hide()
    end
end

local hookedFrame
local function HookClassFrame(frame)
    if not frame or hookedFrame == frame then return end
    hookedFrame = frame
    frame:HookScript("OnHide", function(self)
        if self:IsForbidden() then return end
        if ShouldForceShow() then
            self:Show()
        end
    end)
end

function BBP.DruidAlwaysShowCombos()
    if not BetterBlizzPlatesDB.druidAlwaysShowCombos then return end
    if UnitClassBase("player") ~= "DRUID" then return end
    if BBP.DruidAlwaysShowCombosActive then return end
    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    HookClassFrame(prd.classFrame)
    if prd.SetupClassBar then
        hooksecurefunc(prd, "SetupClassBar", function(self)
            HookClassFrame(self.classFrame)
        end)
    end

    local listener = CreateFrame("Frame")
    listener:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    listener:RegisterEvent("PLAYER_TARGET_CHANGED")
    listener:RegisterEvent("COMBO_TARGET_CHANGED")
    listener:SetScript("OnEvent", function(_, event, _, powerType)
        if event == "UNIT_POWER_UPDATE" and powerType ~= "COMBO_POINTS" then return end
        UpdateDruidComboPoints()
    end)
    BBP.DruidAlwaysShowCombosActive = true
    UpdateDruidComboPoints()
end
