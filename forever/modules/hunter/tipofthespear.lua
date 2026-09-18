local TIP_OF_THE_SPEAR = 260286
local MAX_POINTS = 3
local SURVIVAL_SPEC_INDEX = 3
local POINT_TEMPLATE = "RogueComboPointTemplate"
local POINT_SPACING = 4

local prdBar, specWatcher

local function RecolorUnchargedArt(point)
    point.IconUncharged:SetAtlas("uf-roguecp-icon-blue", true)
    point.FXUncharged:SetAtlas("uf-roguecp-fx-blue", true)
    point.SlashFBUncharged:SetAtlas("uf-roguecp-slash-blue")

    point.IconUncharged:SetDesaturated(true)
    point.FXUncharged:SetDesaturated(true)
    point.SlashFBUncharged:SetDesaturated(true)

    point.IconUncharged:SetVertexColor(0.49, 1, 0.361, 1)
    point.FXUncharged:SetVertexColor(0.49, 1, 0.361, 1)
    point.SlashFBUncharged:SetVertexColor(0.49, 1, 0.361, 1)
end

local function SetPointInstant(point, isFull)
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

local function CreatePoint(bar, index)
    local point = CreateFrame("Frame", nil, bar, POINT_TEMPLATE)
    point.layoutIndex = index
    RecolorUnchargedArt(point)
    point:Setup()
    return point
end

local function GetStacks()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(TIP_OF_THE_SPEAR)
    return (aura and aura.applications) or 0
end

local function IsSurvival()
    if UnitClassBase("player") ~= "HUNTER" then return false end
    return BBP.GetSpecialization() == SURVIVAL_SPEC_INDEX
end

local function FramesOwnsDisplay()
    return BBF and BBF.TipOfSpearPlatesShouldShow and not BBF.TipOfSpearPlatesShouldShow() or false
end

local function UpdateBar()
    if not prdBar then return end

    local show = BetterBlizzPlatesDB.hunterTipOfSpearCombos and IsSurvival() and not FramesOwnsDisplay()
    prdBar:SetShown(show)
    if not show then return end

    local stacks = GetStacks()
    local instant = BetterBlizzPlatesDB.instantComboPoints
    for i = 1, MAX_POINTS do
        local point = prdBar.classResourceButtonTable[i]
        if point then
            local isFull = i <= stacks
            if instant then
                SetPointInstant(point, isFull)
            else
                point:Update(isFull, false)
            end
        end
    end
end

function BBP.TipOfSpearCombos()
    if UnitClassBase("player") ~= "HUNTER" then return end
    if BBF and BBF.UpdateTipOfSpearBar then
        BBF.UpdateTipOfSpearBar()
    end
    if BBP.tipOfSpearCombos then
        UpdateBar()
        BBP.TargetResourceUpdater()
        return
    end
    if not BetterBlizzPlatesDB.hunterTipOfSpearCombos then return end

    if not specWatcher then
        specWatcher = CreateFrame("Frame")
        specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        specWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        specWatcher:SetScript("OnEvent", function()
            BBP.TipOfSpearCombos()
        end)
    end

    if not IsSurvival() or FramesOwnsDisplay() then return end

    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    prdBar = CreateFrame("Frame", "BBPTipOfTheSpearBar", prd, "HorizontalLayoutFrame")
    prdBar.spacing = POINT_SPACING
    prdBar.topPadding = 10
    prdBar.leftPadding = 0
    prdBar.maxUsablePoints = MAX_POINTS
    prdBar.powerType = Enum.PowerType.ComboPoints
    prdBar.ignoreFramePositionManager = true
    prdBar.classResourceButtonTable = {}

    for i = 1, MAX_POINTS do
        prdBar.classResourceButtonTable[i] = CreatePoint(prdBar, i)
    end
    prdBar.UpdatePower = UpdateBar

    prdBar:Layout()

    BBP.TipOfSpearBar = prdBar

    local auraWatch = CreateFrame("Frame")
    auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
    auraWatch:RegisterEvent("PLAYER_ENTERING_WORLD")
    auraWatch:SetScript("OnEvent", UpdateBar)

    BBP.tipOfSpearCombos = true
    UpdateBar()
    BBP.TargetResourceUpdater()
end
