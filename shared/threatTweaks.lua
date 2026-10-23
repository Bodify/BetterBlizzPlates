local textPoints = {
    CENTER = "CENTER",
    TOP = "BOTTOM",
    BOTTOM = "TOP",
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    TOPLEFT = "BOTTOMLEFT",
    TOPRIGHT = "BOTTOMRIGHT",
    BOTTOMLEFT = "TOPLEFT",
    BOTTOMRIGHT = "TOPRIGHT",
}

local layoutVersion = 0
local eventFrame

local function IsNameplateFrame(frame)
    if not frame or issecretvalue(frame) or frame:IsForbidden() then return end
    local unit = frame.unit
    return unit and unit:find("nameplate")
end

function BBP.IsThreatColorActive()
    local db = BetterBlizzPlatesDB
    return db.enemyColorThreat and (BBP.isInPvE or (db.threatColorAlwaysOn and not BBP.isInPvP))
end

local function ColorsName(db)
    return db.threatColorName or db.threatColorNameOnly
end

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if not BetterBlizzPlatesDB or not ColorsName(BetterBlizzPlatesDB) then return end
    if not IsNameplateFrame(frame) or not frame.name then return end
    frame.bbpNameBaseR, frame.bbpNameBaseG, frame.bbpNameBaseB = frame.name:GetVertexColor()
    frame.bbpNameBaseSet = true
end)

local function ClearThreatName(frame)
    frame.bbpThreatNameR, frame.bbpThreatNameG, frame.bbpThreatNameB = nil, nil, nil
    if frame.bbpNameBaseSet then
        frame.name:SetVertexColor(frame.bbpNameBaseR, frame.bbpNameBaseG, frame.bbpNameBaseB)
    end
    BBP.ConsolidatedUpdateName(frame)
end

function BBP.SetThreatNameColor(frame, r, g, b)
    if r then
        if frame.bbpThreatNameR == r and frame.bbpThreatNameG == g and frame.bbpThreatNameB == b then return end
        frame.bbpThreatNameR, frame.bbpThreatNameG, frame.bbpThreatNameB = r, g, b
        BBP.ConsolidatedUpdateName(frame)
    elseif frame.bbpThreatNameR then
        ClearThreatName(frame)
    end
end

function BBP.ApplyThreatNameColor(frame)
    if ColorsName(BetterBlizzPlatesDB) and BBP.IsThreatColorActive() then
        frame.name:SetVertexColor(frame.bbpThreatNameR, frame.bbpThreatNameG, frame.bbpThreatNameB)
    else
        ClearThreatName(frame)
    end
end

function BBP.ColorThreat(frame)
    if not frame or not frame.unit then return end
    local db = BetterBlizzPlatesDB
    local r, g, b = BBP.GetThreatColor(frame)
    if ColorsName(db) then
        BBP.SetThreatNameColor(frame, r, g, b)
    end
    if r and not db.threatColorNameOnly then
        frame.healthBar:SetStatusBarColor(r, g, b)
    end
end

function BBP.ClearThreatTweaks(frame)
    frame.bbpThreatNameR, frame.bbpThreatNameG, frame.bbpThreatNameB = nil, nil, nil
    frame.bbpNameBaseSet = nil
    if frame.bbpThreatPercent then
        frame.bbpThreatPercent:Hide()
    end
end

local function LayoutThreatPercent(frame, text)
    local db = BetterBlizzPlatesDB
    local anchor = db.threatPercentAnchor or "RIGHT"
    BBP.SetFontBasedOnOption(text, 10 * (db.threatPercentScale or 1), "OUTLINE")
    text:ClearAllPoints()
    text:SetPoint(textPoints[anchor] or "LEFT", frame.healthBar, anchor, db.threatPercentXPos or 0, db.threatPercentYPos or 0)
    text.layout = layoutVersion
end

function BBP.UpdateThreatPercent(frame)
    local text = frame.bbpThreatPercent
    local unit = frame.unit
    local db = BetterBlizzPlatesDB
    if not db.threatPercent or not unit or UnitIsPlayer(unit) or UnitIsFriend("player", unit) then
        if text then text:Hide() end
        return
    end

    if not text then
        text = (frame.bbpOverlay or frame.healthBar):CreateFontString(nil, "OVERLAY")
        frame.bbpThreatPercent = text
    end
    if text.layout ~= layoutVersion then
        LayoutThreatPercent(frame, text)
    end

    if db.threatPercentTestMode then
        text:SetText("75%")
        text:Show()
        return
    end

    local _, _, percent = UnitDetailedThreatSituation("player", unit)
    if issecretvalue(percent) or (percent and percent > 0) then
        text:SetFormattedText("%.0f%%", percent)
        text:Show()
    else
        text:Hide()
    end
end

local function UpdateAllThreatPercents()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        BBP.UpdateThreatPercent(nameplate.UnitFrame)
    end
end

local function OnThreatEvent(_, event, unit)
    if event == "UNIT_THREAT_LIST_UPDATE" then
        if not unit or not unit:find("nameplate") then return end
        local _, frame = BBP.GetSafeNameplate(unit)
        if frame then
            BBP.UpdateThreatPercent(frame)
        end
    else
        UpdateAllThreatPercents()
    end
end

function BBP.ToggleThreatPercentEvents()
    local enabled = BetterBlizzPlatesDB.threatPercent
    if enabled and not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", OnThreatEvent)
    end
    if eventFrame then
        if enabled then
            eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
            eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            eventFrame:UnregisterAllEvents()
        end
    end
end

function BBP.RefreshThreatPercent()
    layoutVersion = layoutVersion + 1
    BBP.ToggleThreatPercentEvents()
    UpdateAllThreatPercents()
end
