function BBP.DruidBlueComboPoints()
    if not BetterBlizzPlatesDB.druidOverstacks then return end
    if select(2, UnitClass("player")) ~= "DRUID" then return end
    local druidNp = _G.ClassNameplateBarFeralDruidFrame
    local msgPrinted

    local function CreateChargedPoints(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.blueOverchargePoints then return end
        local comboPoints = {}

        local comboPointsChecked = 0
        for i = 1, comboPointFrame:GetNumChildren() do
            local child = select(i, comboPointFrame:GetChildren())
            if child:IsShown() then
                comboPointsChecked = comboPointsChecked + 1
                table.insert(comboPoints, child)
            end
        end

        for i = 1, 3 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint"..i] = comboPoint

                -- Create the overlayActive texture and reference it as ChargedFrameActive
                local overlayActive = comboPoint:CreateTexture(nil, "OVERLAY")
                overlayActive:SetAtlas("UF-RogueCP-BG-Anima")
                overlayActive:SetSize(20, 20)
                overlayActive:SetPoint("CENTER", comboPoint, "CENTER")
                comboPoint.ChargedFrameActive = overlayActive

                -- Initially hide the active overlay
                overlayActive:Hide()
            end
        end

        if comboPointsChecked == 5 then
            comboPointFrame.blueOverchargePoints = true
        end
    end

    CreateChargedPoints(druidNp)

    -- Function to handle updating combo points based on aura
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
                        -- Revert to default combo point and hide the overlay
                        comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")  -- Default Druid combo point
                        comboPoint.Point_Deplete:SetDesaturated(false)
                        comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                        comboPoint.Smoke:SetDesaturated(false)
                        comboPoint.Smoke:SetVertexColor(1, 1, 1)
                        comboPoint.FB_Slash:SetDesaturated(false)
                        comboPoint.FB_Slash:SetVertexColor(1, 1, 1)

                        if comboPoint.ChargedFrameActive then
                            comboPoint.ChargedFrameActive:Hide()  -- Hide active overlay
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
                    comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")  -- Default Druid combo point
                    comboPoint.Point_Deplete:SetDesaturated(false)
                    comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                    comboPoint.Smoke:SetDesaturated(false)
                    comboPoint.Smoke:SetVertexColor(1, 1, 1)
                    comboPoint.FB_Slash:SetDesaturated(false)
                    comboPoint.FB_Slash:SetVertexColor(1, 1, 1)
                    comboPoint.ChargedFrameActive:Hide()  -- Hide active overlay
                end
            end
        end
    end

    -- Create a frame to listen to form changes
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