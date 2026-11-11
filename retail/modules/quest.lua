local UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest
local GetUnitTooltip = C_TooltipInfo.GetUnit
local LINE_OBJECTIVE = Enum.TooltipDataLineType.QuestObjective
local LINE_TITLE = Enum.TooltipDataLineType.QuestTitle
local LINE_PLAYER = Enum.TooltipDataLineType.QuestPlayer
local PlayerName = UnitName("player")
local PlayerGUID = UnitGUID("player")

local function IsObjectiveDone(line)
    if line.completed then
        return true
    end
    local text = line.leftText
    if type(text) ~= "string" then
        return false
    end
    local current, goal = text:match("(%d+)%s*/%s*(%d+)")
    if current then
        return tonumber(current) >= tonumber(goal)
    end
    local percent = text:match("(%d+)%s*%%")
    return percent ~= nil and tonumber(percent) >= 100
end

function BBP.IsQuestUnit(unit)
    if not unit or UnitIsPlayer(unit) then
        return false
    end

    if C_Secrets.ShouldUnitIdentityBeSecret(unit) then
        return false
    end

    local related = UnitIsRelatedToActiveQuest(unit) == true
    if not related and not UnitCanAttack("player", unit) then
        return false
    end

    local data = GetUnitTooltip(unit)
    local lines = data and data.lines
    if lines then
        local hasQuestLines = false
        local isMine = true
        for _, line in ipairs(lines) do
            local lineType = line.type
            if lineType == LINE_TITLE then
                hasQuestLines = true
                isMine = true
            elseif lineType == LINE_PLAYER then
                isMine = line.guid == PlayerGUID or line.leftText == PlayerName
            elseif lineType == LINE_OBJECTIVE then
                hasQuestLines = true
                if isMine and not IsObjectiveDone(line) then
                    return true
                end
            end
        end
        if hasQuestLines then
            return false
        end
    end

    return related
end

local hiddenInstanceTypes = {
    party = true,
    raid = true,
    pvp = true,
    arena = true,
}

local function InHiddenInstance()
    local _, instanceType = IsInInstance()
    return hiddenInstanceTypes[instanceType] or false
end

local function SetQuestColor(frame, isQuest)
    if isQuest and BetterBlizzPlatesDB.questIndicatorColorNpc then
        local color = BetterBlizzPlatesDB.questIndicatorColorNpcRGB
        if not UnitIsTapDenied(frame.unit) then
            frame.healthBar:SetStatusBarColor(unpack(color))
        end
        frame.needsRecolor = true
        frame.isQuestNpc = color
        BBP.FollowHealthName(frame)
    elseif frame.needsRecolor then
        frame.needsRecolor = nil
        frame.isQuestNpc = nil
        BBP.CompactUnitFrame_UpdateHealthColor(frame)
    end
end

local hasTurnInAtlas = C_Texture.GetAtlasInfo("QuestTurnin") ~= nil

function BBP.PositionQuestIndicator(frame)
    local indicator = frame.questIndicator
    if not indicator then return end
    local db = BetterBlizzPlatesDB
    indicator:ClearAllPoints()
    indicator:SetScale(db.questIndicatorScale or 1)
    if frame.HealthBarsContainer and frame.HealthBarsContainer.alphaZero == true then
        indicator:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
        return
    end
    local anchorPoint = db.questIndicatorAnchor or "CENTER"
    local xPos = (db.questIndicatorXPos or 0) + (anchorPoint == "LEFT" and -8 or 0)
    local yPos = db.questIndicatorYPos or 0
    indicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
end

function BBP.QuestIndicator(frame)
    if not frame.questIndicator then
        if not frame.bbpPlateOverlay then
            frame.bbpPlateOverlay = CreateFrame("Frame", nil, frame)
            frame.bbpPlateOverlay:SetFrameStrata("DIALOG")
            frame.bbpPlateOverlay:SetFrameLevel(9000)
        end
        frame.questIndicator = frame.bbpPlateOverlay:CreateTexture(nil, "OVERLAY")
        frame.questIndicator:SetSize(22, 22)
    end
    local info = frame.BetterBlizzPlates and frame.BetterBlizzPlates.unitInfo
    local atlas = (info and info.isFriendlyNpc and hasTurnInAtlas) and "QuestTurnin" or "smallquestbang"
    if frame.questIndicator.bbpAtlas ~= atlas then
        frame.questIndicator:SetAtlas(atlas)
        frame.questIndicator.bbpAtlas = atlas
    end

    local db = BetterBlizzPlatesDB
    BBP.PositionQuestIndicator(frame)

    local isQuest = db.questIndicatorTestMode or (db.questIndicator and not InHiddenInstance() and BBP.IsQuestUnit(frame.unit))
    frame.questIndicator:SetShown(isQuest)
    SetQuestColor(frame, isQuest)
end

local updatePending

local function UpdateAllUnitQuestState()
    updatePending = nil
    if not BetterBlizzPlatesDB.questIndicator or InHiddenInstance() then return end
    for _, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        if frame and not frame:IsForbidden() and not frame:IsProtected() and frame.unit then
            BBP.QuestIndicator(frame)
        end
    end
end

local QuestEventFrame

local function OnQuestEvent()
    if not updatePending then
        updatePending = true
        C_Timer.After(0.1, UpdateAllUnitQuestState)
    end
end

function BBP.ToggleQuestIndicator()
    if BetterBlizzPlatesDB.questIndicator then
        if not QuestEventFrame then
            QuestEventFrame = CreateFrame("Frame")
            QuestEventFrame:SetScript("OnEvent", OnQuestEvent)
        end
        QuestEventFrame:RegisterEvent("QUEST_LOG_UPDATE")
        QuestEventFrame:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
    elseif QuestEventFrame then
        QuestEventFrame:UnregisterAllEvents()
    end
end
