BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Combat Indicator
function BBP.CombatIndicator(frame)
    local unit = frame.displayedUnit
    local notInCombat = not UnitAffectingCombat(unit)
    local inInstance, instanceType = IsInInstance()
    local XPos = BetterBlizzPlatesDB.combatIndicatorXPos
    local YPos = BetterBlizzPlatesDB.combatIndicatorYPos

    -- Initialize
    -- Create food texture
    if not frame.combatIndicator then
        frame.combatIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.combatIndicator:SetSize(18, 18)
        frame.combatIndicator:SetAtlas("food")
    end
    -- Create sap texture (create this anyway to make sliders happier)
    if not frame.combatIndicatorSap then
        frame.combatIndicatorSap = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.combatIndicatorSap:SetSize(18, 16)
        frame.combatIndicatorSap:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
    end

    -- Conditions check: Only show during arena
    if BetterBlizzPlatesDB.combatIndicatorArenaOnly then
        if not (inInstance and instanceType == "arena") then
            if frame.combatIndicatorSap then
                frame.combatIndicatorSap:Hide()
            end
            if frame.combatIndicator then
                frame.combatIndicator:Hide()
            end
            return
        end
    end

    -- Conditon check: Only show on enemies
    if BetterBlizzPlatesDB.combatIndicatorEnemyOnly then
        notInCombat = notInCombat and UnitCanAttack("player", unit)
    end

    if BetterBlizzPlatesDB.combatIndicatorPlayersOnly then
        notInCombat = notInCombat and UnitIsPlayer(unit)
    end

    -- Condition check: Use food or sap texture
    if BetterBlizzPlatesDB.combatIndicatorSap then
        frame.combatIndicatorSap:SetScale(BetterBlizzPlatesDB.combatIndicatorScale)
        frame.combatIndicatorSap:Show()
        frame.combatIndicator:Hide()
    else
        if frame.combatIndicatorSap then
            frame.combatIndicatorSap:Hide()
        end
        frame.combatIndicator:SetScale(BetterBlizzPlatesDB.combatIndicatorScale)
        frame.combatIndicator:Show()
    end

    -- Add some offset if both Pet Indicator and Combat Indicator has the same anchor and shows at the same time
    if frame.petIndicator and frame.petIndicator:IsShown() and (BetterBlizzPlatesDB.combatIndicatorTestMode or BetterBlizzPlatesDB.petIndicatorTestMode or BetterBlizzPlatesDB.petIndicator) and (BetterBlizzPlatesDB.petIndicatorAnchor == BetterBlizzPlatesDB.combatIndicatorAnchor) then
        XPos = XPos + 10  -- Add some offset
    end

    -- Tiny adjustment to position depending on texture
    local yPosAdjustment = BetterBlizzPlatesDB.combatIndicatorSap and 0 or 1
    if frame.combatIndicatorSap then
        frame.combatIndicatorSap:SetPoint("CENTER", frame.healthBar, BetterBlizzPlatesDB.combatIndicatorAnchor, XPos, YPos + yPosAdjustment)
    end
    frame.combatIndicator:SetPoint("CENTER", frame.healthBar, BetterBlizzPlatesDB.combatIndicatorAnchor, XPos, YPos + yPosAdjustment)

    -- Target is not in combat so return
    if notInCombat then
        return
    end

    -- Target is in combat so hide texture
    if frame.combatIndicatorSap then
        frame.combatIndicatorSap:Hide()
    end
    if frame.combatIndicator then
        frame.combatIndicator:Hide()
    end
end

-- Event Listener for Combat Indicator
local combatIndicatorFrame = CreateFrame("Frame")
combatIndicatorFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_FLAGS" or event == "UNIT_COMBAT" then
        local frame = C_NamePlate.GetNamePlateForUnit(arg1)
        if frame then
            BBP.CombatIndicator(frame.UnitFrame)
        end
    end
end)

-- Toggle event listening on/off for Combat Indicator if not enabled
function BBP.ToggleCombatIndicator()
    if BetterBlizzPlatesDB.combatIndicator then
        combatIndicatorFrame:RegisterEvent("UNIT_FLAGS")
        combatIndicatorFrame:RegisterEvent("UNIT_COMBAT")
    else
        combatIndicatorFrame:UnregisterEvent("UNIT_FLAGS")
        combatIndicatorFrame:UnregisterEvent("UNIT_COMBAT")
    end
end