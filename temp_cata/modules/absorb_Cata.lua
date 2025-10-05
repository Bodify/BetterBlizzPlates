-- Used for Wrath with older API
local CataAbsorb = {}
CataAbsorb.spells = {
    [17] = true, -- Priest: Power Word: Shield
    [47753] = true, -- Priest: Divine Aegis
    [86273] = true, -- Paladin: Illuminated Healing
    [96263] = true, -- Paladin: Sacred Shield
    [62606] = true, -- Druid: Savage Defense
    [77535] = true, -- DK: Blood Shield
    [1463] = true, -- Mage: Mana Shield / Incanters Ward
    [11426] = true, -- Mage: Ice Barrier
    [98864] = true, -- Mage: Ice Barrier
    [55277] = true, -- Shaman: Totem Shield
    [116849] = true, -- Monk: Life Cocoon
    [115295] = true, -- Monk: Guard
    [114893] = true, -- Shaman: Stone Bulwark
    [123258] = true, -- Priest: Power Word: Shield
    [114214] = true, -- Angelic Bulwark
    [131623] = true, -- Twilight Ward (Magic)
    [48707] = true, -- Anti-Magic Shell
    [110570] = true, -- Anti-Magic Shell (Symbiosis)
    [114908] = true, -- Spirit Shell
}
-- most spells

local overshields
local absorbText

function ComputeAbsorb(unit)
    local value = 0
    local maxAbsorb = 0
    local maxAbsorbIcon = nil

    for index = 1, 40 do
        local name, icon, _, _, _, _, _, _, _, spellId, _, _, _, _, _, _, absorb = UnitAura(unit, index)
        if not name then break end
        if CataAbsorb.spells[spellId] and absorb then
            value = value + absorb
            if absorb > maxAbsorb then
                maxAbsorb = absorb
                maxAbsorbIcon = icon
            end
        end
    end

    return value, maxAbsorbIcon
end

-- Absorb Indicator
function BBP.AbsorbIndicator(frame, absorb)
    if frame:IsForbidden() then return end
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    if not config.absorbIndicatorInitialized or BBP.needsUpdate then
        config.absorbIndicatorAnchor = BetterBlizzPlatesDB.absorbIndicatorAnchor or "LEFT"
        config.absorbIndicatorXPos = BetterBlizzPlatesDB.absorbIndicatorXPos
        config.absorbIndicatorYPos = BetterBlizzPlatesDB.absorbIndicatorYPos
        config.absorbIndicatorEnemyOnly = BetterBlizzPlatesDB.absorbIndicatorEnemyOnly
        config.absorbIndicatorOnPlayersOnly = BetterBlizzPlatesDB.absorbIndicatorOnPlayersOnly
        config.absorbIndicatorScale = BetterBlizzPlatesDB.absorbIndicatorScale
        config.absorbIndicatorTestMode = BetterBlizzPlatesDB.absorbIndicatorTestMode

        config.absorbIndicatorInitialized = true
    end

    local unit = frame.unit
    local oppositeAnchor = BBP.GetOppositeAnchor(config.absorbIndicatorAnchor)
    local enemyOnly = config.absorbIndicatorEnemyOnly and (not info.isEnemy or not info.isNeutral)
    local playersOnly = config.absorbIndicatorOnPlayersOnly and (not info.isPlayer)

    -- Initialize
    if not frame.absorbIndicator then
        frame.absorbIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY")
        frame.absorbIndicator:SetTextColor(1, 1, 1)
    end

    frame.absorbIndicator:ClearAllPoints()
    frame.absorbIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.absorbIndicatorAnchor, config.absorbIndicatorXPos -2, config.absorbIndicatorYPos)
    frame.absorbIndicator:SetScale(config.absorbIndicatorScale or 1)
    BBP.SetFontBasedOnOption(frame.absorbIndicator, 10, "OUTLINE")

    -- Test mode
    if config.absorbIndicatorTestMode then
        frame.absorbIndicator:SetText("69k")
        frame.absorbIndicator:Show()
        return
    end

    -- Condition check: absorbIndicatorEnemyOnly
    if enemyOnly then
        if frame.absorbIndicator then frame.absorbIndicator:Hide() end
        return
    end

    -- Condition check: absorbIndicatorOnPlayersOnly
    if playersOnly then
        if frame.absorbIndicator then frame.absorbIndicator:Hide() end
        return
    end

    -- Check absorb amount and hide if less than 1k
    if absorb == nil then
        absorb = ComputeAbsorb(unit)
    end

    if absorb > 100 then
        local displayValue
        if absorb >= 1000 then
            displayValue = string.format("%.1fk", absorb / 1000)
        else
            displayValue = tostring(absorb)
        end
        frame.absorbIndicator:SetText(displayValue)
        frame.absorbIndicator:Show()
    elseif frame.absorbIndicator then
        frame.absorbIndicator:Hide()
    end
end

local function CreateAbsorbBar(frame)
    if frame.absorbBar then return end -- Prevent duplicate elements

    -- Absorb Fill (Total Absorb)
    frame.absorbBar = frame:CreateTexture(nil, "ARTWORK", nil, 1)
    frame.absorbBar:SetTexture("Interface\\RaidFrame\\Shield-Fill")
    --frame.absorbBar:SetHorizTile(false)
    --frame.absorbBar:SetVertTile(false)
    frame.absorbBar:Hide()

    -- Absorb Overlay
    frame.absorbOverlay = frame:CreateTexture(nil, "OVERLAY", nil, 2)
    frame.absorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
    frame.absorbOverlay:SetHorizTile(true)
    frame.absorbOverlay.tileSize = 32
    frame.absorbOverlay:SetAllPoints(frame.absorbBar)
    frame.absorbOverlay:Hide()

    -- Over Absorb Glow
    frame.absorbGlow = frame:CreateTexture(nil, "OVERLAY", nil, 3)
    frame.absorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    frame.absorbGlow:SetBlendMode("ADD")
    frame.absorbGlow:SetWidth(8)
    frame.absorbGlow:SetAlpha(0.6)
    frame.absorbGlow:Hide()
    frame.absorbGlow:SetParent(frame.healthbar or frame.healthBar or frame.HealthBar)
end

local function UpdateCompactUnitFrameAbsorbTexture(unit, frame, absorbValue)
    if not frame or not frame.unit or not UnitIsUnit(unit, frame.unit) then return end
    if frame:IsForbidden() then return end
    local healthBar = frame.healthBar or frame.HealthBar or frame.healthbar
    if not healthBar then return end

    local state = CataAbsorb.allstates[unit]
    CreateAbsorbBar(frame) -- Ensure elements exist

    if not (state and state.show) then
        -- Hide absorb visuals if no absorb is present
        frame.absorbGlow:Hide()
        frame.absorbOverlay:Hide()
        frame.absorbBar:Hide()
        return
    end

    local currentHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
    if maxHealth <= 0 then return end

    -- **Use precomputed absorb value**
    local totalAbsorb = absorbValue or 0
    local missingHealth = maxHealth - currentHealth
    local totalWidth = healthBar:GetWidth()

    -- **Absorb Bar - stays within missing health space**
    local absorbWidth = math.min(totalAbsorb, missingHealth) / maxHealth * totalWidth
    local offset = currentHealth / maxHealth * totalWidth -- Where absorb starts

    if absorbWidth > 0 then
        frame.absorbBar:ClearAllPoints()
        frame.absorbBar:SetParent(healthBar)
        frame.absorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", offset, 0)
        frame.absorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", offset, 0)
        frame.absorbBar:SetWidth(absorbWidth)
        frame.absorbBar:Show()
    else
        frame.absorbBar:Hide()
    end

    -- **Absorb Overlay - always shows full absorb & moves backward if needed**
    frame.absorbOverlay:ClearAllPoints()
    frame.absorbOverlay:SetParent(healthBar)

    local overlayOffset = offset
    local overlayWidth = totalAbsorb / maxHealth * totalWidth

    if (currentHealth + totalAbsorb) > maxHealth then
        -- **Absorb exceeds max health → overlay moves backward onto health**
        local overAbsorb = (currentHealth + totalAbsorb) - maxHealth
        local overAbsorbWidth = overAbsorb / maxHealth * totalWidth

        overlayWidth = overlayWidth + overAbsorbWidth
        overlayOffset = offset - overAbsorbWidth
    end

    frame.absorbOverlay:SetPoint("TOPLEFT", healthBar, "TOPLEFT", math.max(overlayOffset, 0), 0)
    frame.absorbOverlay:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", math.max(overlayOffset, 0), 0)
    frame.absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0)
    frame.absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
    frame.absorbOverlay:SetWidth(math.min(overlayWidth, totalWidth)) -- Ensure it doesn't exceed total width
    frame.absorbOverlay:SetTexCoord(0, frame.absorbOverlay:GetWidth() / frame.absorbOverlay.tileSize, 0, 1)
    frame.absorbOverlay:Show()

    -- **Absorb Glow - attaches left when absorb exceeds max HP**
    frame.absorbGlow:ClearAllPoints()
    if (currentHealth + totalAbsorb) > maxHealth then
        -- Over-absorbing → Glow appears on the left side
        frame.absorbGlow:SetPoint("TOPLEFT", frame.absorbOverlay, "TOPLEFT", -4, 1)
        frame.absorbGlow:SetPoint("BOTTOMLEFT", frame.absorbOverlay, "BOTTOMLEFT", -4, -1)
    else
        -- Normal absorb → Glow on the right
        frame.absorbGlow:SetPoint("TOPRIGHT", frame.absorbOverlay, "TOPRIGHT", 6, 1)
        frame.absorbGlow:SetPoint("BOTTOMRIGHT", frame.absorbOverlay, "BOTTOMRIGHT", 6, -1)
        frame.absorbOverlay:SetPoint("TOPRIGHT", frame.absorbBar, "TOPRIGHT", 0, 0)
        frame.absorbOverlay:SetPoint("BOTTOMRIGHT", frame.absorbBar, "BOTTOMRIGHT", 0, 0)
    end
    frame.absorbBar:SetTexCoord(0, 1, 0, 1)
    frame.absorbGlow:Show()
end

local function SetupState(allstates, unit, absorb)
    if absorb > 0 then
        local maxHealth = UnitHealthMax(unit)
        local health = UnitHealth(unit)
        local healthPercent = health / maxHealth
        local healthDeficitPercent = 1.0 - healthPercent
        local absorbPercent = absorb / maxHealth

        if healthPercent < 1.0 and absorbPercent > healthDeficitPercent then
            if absorbPercent < 2 * healthDeficitPercent then
                absorbPercent = healthDeficitPercent
            else
                absorbPercent = absorbPercent - healthDeficitPercent
            end
        end

        allstates[unit] = {
            unit = unit,
            name = unit,
            value = absorbPercent * 100,
            total = 100,
            show = true,
            changed = true,
            healthPercent = healthPercent,
        }
    else
        allstates[unit] = {
            show = false,
            changed = true,
        }
    end
end

local function ResetAll(allstates)
    for _, state in pairs(allstates) do
        state.show = false
        state.changed = true
    end
end

local function RefreshUnit(allstates, unit, absorbValue)
    local np, frame = BBP.GetSafeNameplate(unit)
    local absorb = absorbValue or ComputeAbsorb(unit)
    SetupState(allstates, unit, absorb)
    if frame then
        if overshields then
            UpdateCompactUnitFrameAbsorbTexture(unit, frame, absorb)
        end
        if absorbText then
            BBP.AbsorbIndicator(frame, absorb)
        end
    end
end

local relevantUnits = {}

local function TrackUnitForAbsorbs(unit)
    local name = UnitName(unit)
    if name then
        relevantUnits[name] = relevantUnits[name] or {}
        table.insert(relevantUnits[name], unit)
        RefreshUnit(CataAbsorb.allstates, unit)
    end
end

local auraEvents = {
    ["SPELL_AURA_APPLIED"] = true,
    ["SPELL_AURA_REFRESH"] = true,
    ["SPELL_AURA_REMOVED"] = true,
    ["SPELL_ABSORBED"] = true,
}

local function OnEvent(self, event, unit)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName,_,_,spellID = CombatLogGetCurrentEventInfo()
        if not auraEvents[subEvent] then return end
        if destName then
            destName = Ambiguate(destName, "short")
            local units = relevantUnits[destName]
            if units then
                local computedAbsorbs = {}
                for _, unit in ipairs(units) do
                    if UnitName(unit) == destName then
                        if not computedAbsorbs[unit] then
                            computedAbsorbs[unit] = ComputeAbsorb(unit)
                        end
                        if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_REMOVED" then
                            if not CataAbsorb.spells[spellID] then return end
                            RefreshUnit(CataAbsorb.allstates, unit, computedAbsorbs[unit])
                        elseif subEvent == "SPELL_ABSORBED" then
                            RefreshUnit(CataAbsorb.allstates, unit, computedAbsorbs[unit])
                        end
                    end
                end
            end
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        RefreshUnit(CataAbsorb.allstates, unit)
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        TrackUnitForAbsorbs(unit)
    elseif event == "PLAYER_ENTERING_WORLD" then
        wipe(relevantUnits)
        ResetAll(CataAbsorb.allstates)
        for _, nameplate in pairs(C_NamePlate.GetNamePlates(issecure())) do
            local frame = nameplate.UnitFrame
            local unit = frame.unit
            RefreshUnit(CataAbsorb.allstates, unit)
        end
    end
end

local overshieldSetup = false
function BBP.HookOverShields()
    if (BetterBlizzPlatesDB.overShields or BetterBlizzPlatesDB.absorbIndicator) and not overshieldSetup then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("UNIT_HEALTH")
        frame:RegisterEvent("UNIT_MAXHEALTH")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", OnEvent)

        overshieldSetup = true
    end
end

-- Initialize allstates
CataAbsorb.allstates = {}

function BBP.ToggleAbsorbIndicator(value)
    if (BetterBlizzPlatesDB.absorbIndicator or BetterBlizzPlatesDB.overShields) and not overshieldSetup then
        if BetterBlizzPlatesDB.absorbIndicator then
            absorbText = true
        end
        if BetterBlizzPlatesDB.overShields then
            overshields = true
        end

        BBP.HookOverShields()
    end
end