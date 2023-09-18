-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Update text and color based on the target
function BBP.UpdateNameplateTargetText(nameplate, unitID)
    if not nameplate or not unitID then return end
    
    if not nameplate.TargetText then
        nameplate.TargetText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end

    local isCasting = UnitCastingInfo(unitID) or UnitChannelInfo(unitID)
    
    if isCasting and UnitExists(unitID.."target") then
        local targetOfTarget = unitID.."target"
        local name = UnitName(targetOfTarget)
        local _, class = UnitClass(targetOfTarget)
        local color = RAID_CLASS_COLORS[class]
        nameplate.TargetText:SetText(name)
        nameplate.TargetText:SetTextColor(color.r, color.g, color.b)
        if UnitIsEnemy("player", unitID) or (UnitReaction("player", unitID) or 0) < 5 then
            nameplate.TargetText:SetPoint("RIGHT", nameplate, "BOTTOMRIGHT", -11, 0)  -- Set anchor point for enemy
        else
            nameplate.TargetText:SetPoint("CENTER", nameplate, "BOTTOM", 0, 0)  -- Set anchor point for friendly
        end
        BBP.SetFontBasedOnOption(nameplate.TargetText, BetterBlizzPlatesDB.useCustomFont and 11 or 12)
    else
        nameplate.TargetText:SetText("")
    end
end

function BBP.UpdateCastTimer(nameplate, unitID)
    if not nameplate.CastTimerFrame then
        nameplate.CastTimerFrame = CreateFrame("Frame", nil, nameplate)
        nameplate.CastTimer = nameplate.CastTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameplate.CastTimer:SetPoint("LEFT", nameplate, "BOTTOMRIGHT", -10, 15)
        BBP.SetFontBasedOnOption(nameplate.CastTimer, 11)
        nameplate.CastTimer:SetTextColor(1, 1, 1)
    end

    local name, _, _, startTime, endTime = UnitCastingInfo(unitID)
    if not name then
        name, _, _, startTime, endTime = UnitChannelInfo(unitID)
    end

    if name and endTime and startTime then
        nameplate.CastTimer.endTime = endTime / 1000
        local currentTime = GetTime()
        local timeLeft = nameplate.CastTimer.endTime - currentTime
        if timeLeft <= 0 then
            nameplate.CastTimer:SetText("")
            nameplate.TargetText:SetText("")-- more bandaid?
        else
            nameplate.CastTimer:SetText(string.format("%.1f", timeLeft))
            C_Timer.After(0.1, function() BBP.UpdateCastTimer(nameplate, unitID) end)
        end
    else
        nameplate.CastTimer:SetText("")
        nameplate.TargetText:SetText("")-- more bandaid?
    end
end

-- Spellcast events
local spellCastEventFrame = CreateFrame("Frame")
spellCastEventFrame:SetScript("OnEvent", function(self, event, unitID)
    local nameplate = BBP.GetNameplate(unitID)
    if not nameplate then return end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        if BetterBlizzPlatesDB.showNameplateCastbarTimer then
            BBP.UpdateCastTimer(nameplate, unitID)
        end

        if BetterBlizzPlatesDB.showNameplateTargetText then
            BBP.UpdateNameplateTargetText(nameplate, unitID)
        end
    end
    
    if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" or 
       event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        BBP.UpdateNameplateTargetText(nameplate, unitID)
        BBP.UpdateCastTimer(nameplate, unitID) --bandaid?
    end
end)

--#################################################################################################
-- Event handler
function BBP.ToggleSpellCastEventRegistration()
    if BetterBlizzPlatesDB.showNameplateCastbarTimer or BetterBlizzPlatesDB.showNameplateTargetText then
        spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
        spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
        spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    else
        spellCastEventFrame:UnregisterEvent("UNIT_SPELLCAST_START")
        spellCastEventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        spellCastEventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        spellCastEventFrame:UnregisterEvent("UNIT_SPELLCAST_STOP")
        spellCastEventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        spellCastEventFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    end
end