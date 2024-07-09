local UnitAffectingCombat = UnitAffectingCombat
-- Combat Indicator
function BBP.CombatIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.combatIndicatorInitialized or BBP.needsUpdate then
        config.combatIndicatorXPos = BetterBlizzPlatesDB.combatIndicatorXPos
        config.combatIndicatorYPos = BetterBlizzPlatesDB.combatIndicatorYPos

        config.combatIndicatorAnchor = BetterBlizzPlatesDB.combatIndicatorAnchor
        config.combatIndicatorArenaOnly = BetterBlizzPlatesDB.combatIndicatorArenaOnly
        config.combatIndicatorEnemyOnly = BetterBlizzPlatesDB.combatIndicatorEnemyOnly
        config.combatIndicatorPlayersOnly = BetterBlizzPlatesDB.combatIndicatorPlayersOnly
        config.combatIndicatorSap = BetterBlizzPlatesDB.combatIndicatorSap
        config.combatIndicatorScale = BetterBlizzPlatesDB.combatIndicatorScale
        config.combatIndicatorTestMode = BetterBlizzPlatesDB.combatIndicatorTestMode
        config.petIndicatorTestMode = BetterBlizzPlatesDB.petIndicatorTestMode
        config.petIndicator = BetterBlizzPlatesDB.petIndicator
        config.petIndicatorAnchor = BetterBlizzPlatesDB.petIndicatorAnchor
        config.combatIndicatorAssumePalaCombat = BetterBlizzPlatesDB.combatIndicatorAssumePalaCombat

        config.combatIndicatorInitialized = true
    end

    local unit = frame.displayedUnit
    local notInCombat = not UnitAffectingCombat(unit)
    local petAndCombatTest = config.combatIndicatorTestMode or config.petIndicatorTestMode or config.petIndicator

    if config.combatIndicatorAssumePalaCombat then
        for i = 1, 40 do
            local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
            if not name then break end
            if spellId == 86698 then -- Guardian of the Ancient Kings (UnitAffectingCombat returns false even tho unit is on combat if guardian is in combat)
                notInCombat = false
                break
            end
        end
    end

    -- Initialize
    -- Create food texture
    if not frame.combatIndicator then
        frame.combatIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.combatIndicator:SetSize(16, 16)
        frame.combatIndicator:SetAtlas("food")
    end
    -- Create sap texture (create this anyway to make sliders happier)
    if not frame.combatIndicatorSap then
        frame.combatIndicatorSap = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.combatIndicatorSap:SetSize(16, 15)
        frame.combatIndicatorSap:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
    end

    -- Conditions check: Only show during arena
    if config.combatIndicatorArenaOnly then
        if not BBP.isInArena then
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
    if config.combatIndicatorEnemyOnly then
        notInCombat = notInCombat and (info.isEnemy or info.isNeutral)
    end

    if config.combatIndicatorPlayersOnly then
        notInCombat = notInCombat and info.isPlayer
    end

    -- Condition check: Use food or sap texture
    if config.combatIndicatorSap then
        frame.combatIndicatorSap:SetScale(config.combatIndicatorScale)
        frame.combatIndicatorSap:Show()
        frame.combatIndicator:Hide()
    else
        if frame.combatIndicatorSap then
            frame.combatIndicatorSap:Hide()
        end
        frame.combatIndicator:SetScale(config.combatIndicatorScale)
        frame.combatIndicator:Show()
    end

    -- Add some offset if both Pet Indicator and Combat Indicator has the same anchor and shows at the same time
    local petOffset = 0
    if frame.petIndicator and frame.petIndicator:IsShown() and petAndCombatTest and (config.petIndicatorAnchor == config.combatIndicatorAnchor) then
        petOffset = 5
    end

    -- Tiny adjustment to position depending on texture
    local yPosAdjustment = config.combatIndicatorSap and 0 or 1
    if frame.combatIndicatorSap then
        frame.combatIndicatorSap:SetPoint("CENTER", frame.healthBar, config.combatIndicatorAnchor, config.combatIndicatorXPos+petOffset, config.combatIndicatorYPos + yPosAdjustment)
    end
    frame.combatIndicator:SetPoint("CENTER", frame.healthBar, config.combatIndicatorAnchor, config.combatIndicatorXPos+petOffset, config.combatIndicatorYPos + yPosAdjustment)

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
combatIndicatorFrame:SetScript("OnEvent", function(self, event, unit)
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if frame then
        BBP.CombatIndicator(frame)
    end
end)

-- Toggle event listening on/off for Combat Indicator if not enabled
function BBP.ToggleCombatIndicator()
    if BetterBlizzPlatesDB.combatIndicator then
        combatIndicatorFrame:RegisterEvent("UNIT_FLAGS")
    else
        combatIndicatorFrame:UnregisterEvent("UNIT_FLAGS")
    end
end