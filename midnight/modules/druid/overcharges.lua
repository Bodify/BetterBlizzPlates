if not BBP.isMidnight then return end
function BBP.DruidAlwaysShowCombos()
    if not BetterBlizzPlatesDB.druidAlwaysShowCombos then return end
    if select(2, UnitClass("player")) ~= "DRUID" then return end
    if BBP.DruidAlwaysShowCombosActive then return end
    local frame = ClassNameplateBarFeralDruidFrame

    local function CreateChargedPoints(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.taggedCombos then return end

        local comboPoints = {}
        local visibleComboPoints = 0

        for i = 1, comboPointFrame:GetNumChildren() do
            local child = select(i, comboPointFrame:GetChildren())

            if child:IsShown() then
                visibleComboPoints = visibleComboPoints + 1
                table.insert(comboPoints, child)
            end
        end

        table.sort(comboPoints, function(a, b)
            return (a.layoutIndex or 0) < (b.layoutIndex or 0)
        end)

        for i = 1, 5 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint" .. i] = comboPoint
            end
        end

        if visibleComboPoints == 5 then
            comboPointFrame.taggedCombos = true
        end
    end

    CreateChargedPoints(frame)

    local function UpdateDruidComboPoints(self)
        if not self then return end
        if self:IsForbidden() then return end
        local form = GetShapeshiftFormID()
        if form == 1 then return end

        local comboPoints = UnitPower("player", self.powerType)

        if comboPoints > 0 then
            if GetCVarBool("nameplateResourceOnTarget") and not UnitExists("target") then
                self:Hide()
            else
                self:Show()
            end
        else
            self:Hide()
        end

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints

            point.Point_Icon:SetAlpha(isFull and 1 or 0)
            point.BG_Active:SetAlpha(isFull and 1 or 0)
            point.BG_Inactive:SetAlpha(isFull and 0 or 1)
            point.Point_Deplete:SetAlpha(0)
        end
    end

    frame:HookScript("OnHide", function(self)
        if not self then return end
        if self:IsForbidden() then return end
        -- if UnitPower("player", self.powerType) > 0 then --isMidnight
        --     if (BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true) and not UnitExists("target") then
        --         self:Hide()
        --     else
        --         self:Show()
        --     end
        -- end
    end)

    local listener = CreateFrame("Frame")
    listener:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    listener:RegisterEvent("PLAYER_TARGET_CHANGED")
    listener:SetScript("OnEvent", function(_, event, unit, powerType)
        if event == "UNIT_POWER_UPDATE" and powerType == "COMBO_POINTS" then
            UpdateDruidComboPoints(frame)
        elseif event == "PLAYER_TARGET_CHANGED" then
            UpdateDruidComboPoints(frame)
        end
    end)
    BBP.DruidAlwaysShowCombosActive = true
end