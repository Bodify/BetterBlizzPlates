local RUNE_READY = 4
local HOLDER_KEYS = { "Background", "ActiveTexture", "Glow", "ThinGlow" }

local CUSTOM_BARS = {
    "ComboPointBar",
    "MaelstromBar",
    "TipOfSpearBar",
}

local prdSetupHooked

local function GetMode()
    local db = BetterBlizzPlatesDB
    if not db then return nil end
    if db.hideEmptyComboPoints then return "bar" end
    if db.onlyActiveComboPoints then return "points" end
end

local function GetPoints(bar)
    if bar.classResourceButtonTable then return bar.classResourceButtonTable end
    if bar.Runes then return bar.Runes end
    if not bar.rune1 then return nil end

    local runes = bar.bbRunePoints
    if not runes then
        runes = {}
        local i = 1
        while bar["rune" .. i] do
            runes[i] = bar["rune" .. i]
            i = i + 1
        end
        bar.bbRunePoints = runes
    end
    return runes
end

local function GetCount(bar)
    local powerType = bar.powerType or (bar.rune1 and Enum.PowerType.HolyPower)
    if not powerType then return 0 end
    return UnitPower(bar.unit or "player", powerType) or 0
end

local function IsActive(point, index, count)
    if point.runeIndex then
        return point.visualState == RUNE_READY
    end
    if point.fillAmount ~= nil then
        return point.fillAmount > 0
    end
    return index <= count
end

local function SetHolderArtShown(bar, shown)
    local art = bar.bbHolderArt
    if not art then
        if shown then return end
        art = CreateFrame("Frame", nil, bar)
        art:SetAllPoints(bar)
        art:SetFrameLevel(bar:GetFrameLevel())
        for _, key in ipairs(HOLDER_KEYS) do
            local texture = bar[key]
            if texture and texture:GetParent() == bar then
                texture:SetParent(art)
            end
        end
        bar.bbHolderArt = art
    end
    art:SetAlpha(shown and 1 or 0)
end

local function Restore(bar)
    local touched = bar.bbComboVisPoints
    if not touched then return end
    for point in pairs(touched) do
        point:SetAlpha(1)
    end
    bar.bbComboVisPoints = nil
    if bar.bbHolderArt then
        bar.bbHolderArt:SetAlpha(1)
    end
end

function BBP.ApplyComboVisibility(bar, count)
    if not bar or bar:IsForbidden() then return end

    local mode = GetMode()
    if not mode then
        Restore(bar)
        return
    end

    local points = GetPoints(bar)
    if not points then return end
    count = count or GetCount(bar)

    local anyActive = false
    for i, point in ipairs(points) do
        if IsActive(point, i, count) then
            anyActive = true
            break
        end
    end

    local touched = bar.bbComboVisPoints
    if not touched then
        touched = setmetatable({}, { __mode = "k" })
        bar.bbComboVisPoints = touched
    end

    for i, point in ipairs(points) do
        local shown = anyActive and (mode == "bar" or IsActive(point, i, count))
        point:SetAlpha(shown and 1 or 0)
        touched[point] = true
    end

    if bar.rune1 then
        SetHolderArtShown(bar, mode ~= "bar" or anyActive)
    end
end

local function FramesControlsPrd()
    local fdb = BBF and BetterBlizzFramesDB
    local pdb = BBP and BetterBlizzPlatesDB
    if not pdb then return true end
    if not fdb then return false end
    local framesMode = fdb.hideEmptyComboPoints or fdb.onlyActiveComboPoints
    local platesMode = pdb.hideEmptyComboPoints or pdb.onlyActiveComboPoints
    if fdb.prdResourceAdjust then
        return (framesMode or not platesMode) and true or false
    end
    return (framesMode and not platesMode) and true or false
end

local function ApplyPrdClassFrame(bar)
    if FramesControlsPrd() then return end
    BBP.ApplyComboVisibility(bar)
end

local function HookBar(bar)
    if not bar or bar.bbpComboVisHooked then return end
    local method = bar.Runes and "UpdateRunes" or "UpdatePower"
    if type(bar[method]) ~= "function" then return end
    bar.bbpComboVisHooked = true
    hooksecurefunc(bar, method, ApplyPrdClassFrame)
end

local function HookPrdClassFrame()
    local prd = PersonalResourceDisplayFrame
    if not prd then return end
    HookBar(prd.classFrame)
    if prdSetupHooked or not prd.SetupClassBar then return end
    prdSetupHooked = true
    hooksecurefunc(prd, "SetupClassBar", function(self)
        if not self.classFrame then return end
        HookBar(self.classFrame)
        ApplyPrdClassFrame(self.classFrame)
    end)
end

function BBP.UpdateComboVisibility(fromFrames)
    local prd = PersonalResourceDisplayFrame
    if GetMode() and not FramesControlsPrd() then
        HookPrdClassFrame()
    end
    if prd and prd.classFrame then
        ApplyPrdClassFrame(prd.classFrame)
    end

    for _, key in ipairs(CUSTOM_BARS) do
        local bar = BBP[key]
        if bar and bar.UpdatePower then
            bar:UpdatePower()
        end
    end

    if not fromFrames and BBF and BBF.UpdateComboVisibility then
        BBF.UpdateComboVisibility(true)
    end
end
