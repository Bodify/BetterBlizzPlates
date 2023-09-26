-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
local customFont = "Interface\\AddOns\\BetterBlizzPlates\\media\\YanoneKaffeesatz-Medium.ttf"


-- TODO: figure shit out
function UpdateCastbarAnchors(frame, setupOptions)
    -- Healthbar height
    --if GetCVar("nameplateShowFriends") == "0" then
    --    if not InCombatLockdown() then
    --        setupOptions.healthBarHeight = BetterBlizzPlatesDB.enemyNameplateHealthbarHeight or 10.8
    --    end
    --end

    -- Shield position
    if BetterBlizzPlatesDB.enableCastbarCustomization then
        frame.castBar.BorderShield:ClearAllPoints()
        local yOffset = BetterBlizzPlatesDB.castBarDragonflightShield and -1 or 0
        PixelUtil.SetPoint(frame.castBar.BorderShield, "CENTER", frame.castBar, BetterBlizzPlatesDB.castBarIconAnchor, BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos + yOffset)

        -- Spell icon position
        local customOptions = frame.customOptions;
        if not customOptions or not customOptions.ignoreIconPoint then
            frame.castBar.Icon:ClearAllPoints();
            PixelUtil.SetPoint(frame.castBar.Icon, "CENTER", frame.castBar, BetterBlizzPlatesDB.castBarIconAnchor, BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos);
        end
    end
end

--function BBP.HookDefaultCompactNamePlateFrameAnchorInternal()
    hooksecurefunc("DefaultCompactNamePlateFrameAnchorInternal", UpdateCastbarAnchors)
--end


-- Cast emphasis
function BBP.CustomizeCastbar(unitToken)
    if not BetterBlizzPlatesDB.enableCastbarCustomization then return end
    local nameplate = BBP.GetNameplate(unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end
    if unitToken == "player" then return end

    local castBar = nameplate.UnitFrame.castBar
    if castBar:IsForbidden() then return end

    castBar:SetStatusBarColor(1,1,1)

    -- if new dragonflight shield
    castBar.BorderShield:SetScale(BetterBlizzPlatesDB.castBarShieldScale)

    local fontName, fontSize, fontFlags = castBar.Text:GetFont()
    
    if BetterBlizzPlatesDB.useCustomFont then
        castBar.Text:SetFont(customFont, 12, "OUTLINE")
    else
        castBar.Text:SetFont(fontName, 12, "OUTLINE")
    end
    
    if BetterBlizzPlatesDB.castBarDragonflightShield then
        castBar.BorderShield:SetTexture(nil);
        castBar.BorderShield:SetAtlas("ui-castingbar-shield")
    else
        castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
    end

    castBar.Icon:ClearAllPoints()
    castBar.Icon:SetPoint("CENTER", castBar, BetterBlizzPlatesDB.castBarIconAnchor, BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos);

    local yOffset = BetterBlizzPlatesDB.castBarDragonflightShield and -1 or 0
    castBar.BorderShield:ClearAllPoints()
    castBar.BorderShield:SetPoint("CENTER", castBar, BetterBlizzPlatesDB.castBarIconAnchor, BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos + yOffset)


    castBar.Icon:SetScale(BetterBlizzPlatesDB.castBarIconScale)
    castBar:SetHeight(BetterBlizzPlatesDB.castBarHeight)
    castBar.Spark:SetSize(4, BetterBlizzPlatesDB.castBarHeight + 5)
    castBar.Text:SetScale(BetterBlizzPlatesDB.castBarTextScale)


    -- Check if the cast name or spellID is in the user-defined list
    local spellName, spellID, notInterruptible
    if UnitCastingInfo(unitToken) then
        spellName, _, _, _, _, _, _, notInterruptible, spellID = UnitCastingInfo(unitToken)
    elseif UnitChannelInfo(unitToken) then
        spellName, _, _, _, _, _, _, notInterruptible, spellID = UnitChannelInfo(unitToken)
    end

    local function ApplyCastBarEmphasisSettings(castBar, castEmphasis, defaultR, defaultG, defaultB)
        if BetterBlizzPlatesDB.castBarEmphasisColor and castEmphasis.entryColors then
            castBar:SetStatusBarColor(castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b)
        end

        if BetterBlizzPlatesDB.castBarEmphasisText then
            castBar.Text:SetScale(BetterBlizzPlatesDB.castBarEmphasisTextScale)
        end
    
        if BetterBlizzPlatesDB.castBarEmphasisIcon then
            castBar.Icon:SetScale(BetterBlizzPlatesDB.castBarEmphasisIconScale)
            castBar.BorderShield:SetScale(BetterBlizzPlatesDB.castBarEmphasisIconScale - 0.4)
        end
    
        if BetterBlizzPlatesDB.castBarEmphasisHeight then
            castBar:SetHeight(BetterBlizzPlatesDB.castBarEmphasisHeightValue)
            castBar.Spark:SetSize(4, BetterBlizzPlatesDB.castBarEmphasisHeightValue + 22)
        end
    end
    

    
    if BetterBlizzPlatesDB.enableCastbarEmphasis then
        if spellName or spellID then
            if not UnitIsFriend(unitToken, "player") then
                if BetterBlizzPlatesDB.castBarEmphasisOnlyInterruptable and notInterruptible then
                    -- Skip emphasizing non-kickable casts when configured to do so
                    return
                end
                
                for _, castEmphasis in ipairs(BetterBlizzPlatesDB.castEmphasisList) do
                    if (castEmphasis.name and spellName and strlower(castEmphasis.name) == strlower(spellName)) or (castEmphasis.id and spellID and castEmphasis.id == spellID) then
                        ApplyCastBarEmphasisSettings(castBar, castEmphasis, defaultR, defaultG, defaultB)
                        break
                    end
                end
            end
        end
    end
end
    






















-- Update text and color based on the target
function BBP.UpdateNameplateTargetText(nameplate, unitID)
    if not nameplate or not unitID then return end
    if unitID == "player" then return end
    
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
    if UnitIsUnit(unitID, "player") then return end

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
        if BetterBlizzPlatesDB.enableCastbarCustomization then
            BBP.CustomizeCastbar(unitID)
        end
        nameplate.CastTimer.endTime = endTime / 1000
        local currentTime = GetTime()
        local timeLeft = nameplate.CastTimer.endTime - currentTime
        if timeLeft <= 0 then
            nameplate.CastTimer:SetText("")
            if nameplate.TargetText then
                nameplate.TargetText:SetText("")
            end
        else
            nameplate.CastTimer:SetText(string.format("%.1f", timeLeft))
            C_Timer.After(0.1, function() BBP.UpdateCastTimer(nameplate, unitID) end)
        end
    else
        nameplate.CastTimer:SetText("")
        if nameplate.TargetText then
            nameplate.TargetText:SetText("")
        end
    end
end

-- Spellcast events
local spellCastEventFrame = CreateFrame("Frame")
spellCastEventFrame:SetScript("OnEvent", function(self, event, unitID)
    local nameplate = BBP.GetNameplate(unitID)
    if not nameplate then return end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        if BetterBlizzPlatesDB.enableCastbarCustomization then
            BBP.CustomizeCastbar(unitID)
        end
        if BetterBlizzPlatesDB.showNameplateCastbarTimer then
            BBP.UpdateCastTimer(nameplate, unitID)
        end

        if BetterBlizzPlatesDB.showNameplateTargetText then
            BBP.UpdateNameplateTargetText(nameplate, unitID)
        end
    end
    
    if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" or 
       event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        if BetterBlizzPlatesDB.showNameplateTargetText then
            BBP.UpdateNameplateTargetText(nameplate, unitID)
        end
        if BetterBlizzPlatesDB.showNameplateCastbarTimer then
            BBP.UpdateCastTimer(nameplate, unitID)
        end
        if BetterBlizzPlatesDB.enableCastbarCustomization then
            BBP.CustomizeCastbar(unitID)
        end
    end
end)

spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
spellCastEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

--#################################################################################################
-- Event handler
function BBP.ToggleSpellCastEventRegistration()
-- not used needs to be optimized cba for now
--[[
    if BetterBlizzPlatesDB.showNameplateCastbarTimer or
    BetterBlizzPlatesDB.showNameplateTargetText or
    BetterBlizzPlatesDB.eenableCastbarCustomization then
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
print("spellcast event toggle ran")

]]


end