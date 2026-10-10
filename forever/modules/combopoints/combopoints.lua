local DEFAULT_MAX_POINTS = 5
local PRD_RESOURCE_LEVEL = 1000

local CLASS_INFO = {
    ROGUE = {
        template = "BBP_RogueComboPointTemplate",
        topPadding = 10,
    },
    DRUID = {
        template = "BBP_DruidComboPointTemplate",
        topPadding = 7,
    },
}

local prdBar, updater

local function GetMaxPoints()
    local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    if maxPoints <= 0 then
        maxPoints = DEFAULT_MAX_POINTS
    end
    return maxPoints
end

local function SetRogueInstant(point, isFull)
    point:ResetVisuals()
    point.isFull = isFull
    point.isCharged = false

    point.BGActive:SetAlpha(isFull and 1 or 0)
    point.BGInactive:SetAlpha(isFull and 0 or 1)
    point.IconUncharged:SetAlpha(isFull and 1 or 0)
    point.FXUncharged:SetAlpha(isFull and 1 or 0)
    point.IconCharged:SetAlpha(0)
    point.FXCharged:SetAlpha(0)
    point.ChargedFrameActive:SetAlpha(0)
    point.ChargedFrameInactive:SetAlpha(0)
end

local function SetDruidInstant(point, isActive)
    point:ResetVisuals()
    point.isActive = isActive

    point.Point_Icon:SetAlpha(isActive and 1 or 0)
    point.BG_Active:SetAlpha(isActive and 1 or 0)
    point.BG_Inactive:SetAlpha(isActive and 0 or 1)
end

function BBP.ComboPointTargetBarActive()
    if not CLASS_INFO[UnitClassBase("player")] then return false end
    local db = BetterBlizzPlatesDB
    if db.disablePrdMovement then return false end
    if not (db.nameplateResourceOnTarget == "1" or db.nameplateResourceOnTarget == true) then return false end
    if BBF and BBF.ComboPointTargetBarWanted and BBF.ComboPointTargetBarWanted() then return false end
    return true
end

local function ShouldShow()
    local db = BetterBlizzPlatesDB
    if not BBP.ComboPointTargetBarActive() then return false end

    if UnitInVehicle and UnitInVehicle("player") then
        return PlayerVehicleHasComboPoints and PlayerVehicleHasComboPoints() or false
    end

    if UnitClassBase("player") == "DRUID" then
        if UnitPowerType("player") == Enum.PowerType.Energy then return true end
        return db.druidAlwaysShowCombos and GetComboPoints("player", "target") > 0 or false
    end

    return true
end

local function UpdateBar(bar)
    bar = bar or prdBar
    if not bar then return end

    local show = ShouldShow()
    bar:SetShown(show)
    if not show then return end

    local db = BetterBlizzPlatesDB
    local instant = db.instantComboPoints
    local comboPoints = GetComboPoints("player", "target")

    if bar.class == "ROGUE" then
        for i, point in ipairs(bar.classResourceButtonTable) do
            local isFull = i <= comboPoints
            if instant then
                SetRogueInstant(point, isFull)
            else
                point:Update(isFull, false)
            end
        end
    else
        for i, point in ipairs(bar.classResourceButtonTable) do
            local isActive = i <= comboPoints
            if instant then
                SetDruidInstant(point, isActive)
            else
                point:SetActive(isActive)
            end
        end
    end
    BBP.ApplyComboVisibility(bar, comboPoints)
end

local function UpdateMaxPower(bar)
    bar = bar or prdBar
    if not bar then return end

    local maxPoints = GetMaxPoints()
    if bar.maxUsablePoints == maxPoints and #bar.classResourceButtonTable == maxPoints then return end

    bar.maxUsablePoints = maxPoints
    wipe(bar.classResourceButtonTable)

    for i = 1, math.max(maxPoints, #bar.pointPool) do
        local point = bar.pointPool[i]
        if i <= maxPoints then
            if not point then
                point = CreateFrame("Frame", nil, bar, bar.template)
                bar.pointPool[i] = point
            end
            point.layoutIndex = i
            point:Setup()
            bar.classResourceButtonTable[i] = point
        elseif point then
            point:ResetVisuals()
            point:Hide()
        end
    end

    bar:Layout()
    UpdateBar(bar)
end

function BBP.UpdateComboPointBarParent(relativeTo)
    if not prdBar then return true end

    local prd = PersonalResourceDisplayFrame
    local onPrd = not relativeTo or relativeTo == prd
        or (relativeTo.GetParent and relativeTo:GetParent() == prd)
    local parent = onPrd and prd or UIParent
    if prdBar:GetParent() ~= parent then
        prdBar:SetParent(parent)
    end

    if onPrd then
        prdBar:SetFrameStrata("BACKGROUND")
        prdBar:SetFrameLevel(PRD_RESOURCE_LEVEL + 1)
    elseif not BetterBlizzPlatesDB.changeResourceStrata and relativeTo.GetFrameStrata then
        prdBar:SetFrameStrata("BACKGROUND")
        prdBar:SetFrameLevel(PRD_RESOURCE_LEVEL)
    end

    return onPrd
end

local function CreateUpdater(class)
    updater = CreateFrame("Frame")
    updater:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    updater:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    updater:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    updater:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    updater:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    updater:RegisterEvent("PLAYER_ENTERING_WORLD")
    updater:RegisterEvent("PLAYER_TARGET_CHANGED")
    if class == "DRUID" then
        updater:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end

    updater:SetScript("OnEvent", function(_, event, _, powerToken)
        if event == "UNIT_POWER_FREQUENT" then
            if powerToken ~= "COMBO_POINTS" then return end
        elseif event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" then
            UpdateMaxPower(prdBar)
        end

        UpdateBar(prdBar)

        if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED"
            or event == "UPDATE_SHAPESHIFT_FORM" then
            BBP.TargetResourceUpdater()
        end
    end)
end

function BBP.ForeverComboPoints()
    local class = UnitClassBase("player")
    if not CLASS_INFO[class] then return end
    if (class == "ROGUE" and _G.RogueComboPointBarFrame) or (class == "DRUID" and _G.DruidComboPointBarFrame) then return end
    if BBF and BBF.UpdateComboPointBars then
        BBF.UpdateComboPointBars()
    end
    if prdBar then
        UpdateBar(prdBar)
        BBP.TargetResourceUpdater()
        return
    end
    if not BBP.ComboPointTargetBarActive() then return end

    local info = CLASS_INFO[class]
    prdBar = CreateFrame("Frame", "BBPComboPointBar", UIParent, "HorizontalLayoutFrame")
    prdBar:SetFrameStrata("BACKGROUND")
    prdBar:Hide()
    prdBar.spacing = 4
    prdBar.topPadding = info.topPadding
    prdBar.leftPadding = 0
    prdBar.class = class
    prdBar.template = info.template
    prdBar.powerType = Enum.PowerType.ComboPoints
    prdBar.powerToken = "COMBO_POINTS"
    prdBar.ignoreFramePositionManager = true
    prdBar.bbpForeverComboBar = true
    prdBar.classResourceButtonTable = {}
    prdBar.pointPool = {}
    prdBar.UpdatePower = UpdateBar
    prdBar.UpdateMaxPower = UpdateMaxPower

    UpdateMaxPower(prdBar)

    BBP.ComboPointBar = prdBar

    CreateUpdater(class)

    if BBP.DarkModeNameplateResources then
        BBP.DarkModeNameplateResources()
    end

    UpdateBar(prdBar)
    BBP.TargetResourceUpdater()
end
