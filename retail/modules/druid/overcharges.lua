if BBP.isMidnight then return end
function BBP.DruidBlueComboPoints()
    if not BetterBlizzPlatesDB.druidOverstacks then return end
    if select(2, UnitClass("player")) ~= "DRUID" then return end
    local druidNp = _G.ClassNameplateBarFeralDruidFrame
    local msgPrinted

    local function CreateChargedPoints(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.blueOverchargePoints then return end

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

        for i = 1, 3 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint"..i] = comboPoint

                local overlayActive = comboPoint:CreateTexture(nil, "OVERLAY")
                overlayActive:SetAtlas("UF-RogueCP-BG-Anima")
                overlayActive:SetSize(20, 20)
                overlayActive:SetPoint("CENTER", comboPoint, "CENTER")
                comboPoint.ChargedFrameActive = overlayActive
                overlayActive:Hide()
            end
        end

        if visibleComboPoints == 5 then
            comboPointFrame.blueOverchargePoints = true
        end
    end

    CreateChargedPoints(druidNp)

    local function UpdateComboPoints(self)
        if self:IsForbidden() then
            if not msgPrinted then
                C_Timer.After(1, function()
                    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Due to Nameplate Resource being forbidden Overcharge blue combopoints cannot be updated until a reload.")
                end)
                msgPrinted = true
            end
            return
        end
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(405189)

        if not aura then
            if self.overcharged then
                for i = 1, 3 do
                    local comboPoint = self["ComboPoint"..i]
                    if comboPoint then
                        comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")
                        comboPoint.Point_Deplete:SetDesaturated(false)
                        comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                        comboPoint.Smoke:SetDesaturated(false)
                        comboPoint.Smoke:SetVertexColor(1, 1, 1)
                        comboPoint.FB_Slash:SetDesaturated(false)
                        comboPoint.FB_Slash:SetVertexColor(1, 1, 1)

                        if comboPoint.ChargedFrameActive then
                            comboPoint.ChargedFrameActive:Hide()
                        end
                    end
                end
                self.overcharged = nil
            end
            return
        end

        for i = 1, 3 do
            local comboPoint = self["ComboPoint"..i]

            if comboPoint then
                if i <= aura.applications then  -- Show blue combo point and active overlay for stacks <= i
                    self.overcharged = true
                    comboPoint.Point_Icon:SetAtlas("UF-RogueCP-Icon-Blue") -- Blue combo point
                    comboPoint.Point_Deplete:SetDesaturated(true)
                    comboPoint.Point_Deplete:SetVertexColor(0, 0, 1)
                    comboPoint.Smoke:SetDesaturated(true)
                    comboPoint.Smoke:SetVertexColor(0, 0, 1)
                    comboPoint.FB_Slash:SetDesaturated(true)
                    comboPoint.FB_Slash:SetVertexColor(0, 0, 1)
                    comboPoint.ChargedFrameActive:Show()  -- Show active overlay
                else  -- Revert to default combo point and hide the overlay for stacks > i
                    comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")
                    comboPoint.Point_Deplete:SetDesaturated(false)
                    comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                    comboPoint.Smoke:SetDesaturated(false)
                    comboPoint.Smoke:SetVertexColor(1, 1, 1)
                    comboPoint.FB_Slash:SetDesaturated(false)
                    comboPoint.FB_Slash:SetVertexColor(1, 1, 1)
                    comboPoint.ChargedFrameActive:Hide()
                end
            end
        end
    end

    local currentForm = GetShapeshiftFormID()
    if currentForm ~= 1 then
        local formWatch = CreateFrame("Frame")
        local function OnFormChanged()
            CreateChargedPoints(druidNp)
            if druidNp.blueOverchargePoints then
                formWatch:UnregisterAllEvents()
            end
        end
        formWatch:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        formWatch:SetScript("OnEvent", OnFormChanged)
    end

    druidNp.auraWatch = CreateFrame("Frame", nil, UIParent)
    druidNp.auraWatch:SetScript("OnEvent", function()
        UpdateComboPoints(druidNp)
    end)
    druidNp.auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
end



function BBP.DruidAlwaysShowCombos()
    if not BetterBlizzPlatesDB.druidAlwaysShowCombos then return end
    if select(2, UnitClass("player")) ~= "DRUID" then return end
    if BBP.DruidAlwaysShowCombosActive then return end
    local frame = ClassNameplateBarFeralDruidFrame

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
        if UnitPower("player", self.powerType) > 0 then
            if GetCVarBool("nameplateResourceOnTarget") and not UnitExists("target") then
                self:Hide()
            else
                self:Show()
            end
        end
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