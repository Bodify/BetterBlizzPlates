-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- TODO: figure shit out
function UpdateCastbarAnchors(frame, setupOptions)
    if not BBP.IsLegalNameplateUnit(frame) then return end
    -- Healthbar height
    --if GetCVar("nameplateShowFriends") == "0" then
    --    if not InCombatLockdown() then
    --        setupOptions.healthBarHeight = BetterBlizzPlatesDB.enemyNameplateHealthbarHeight or 10.8
    --    end
    --end

    -- Castbar customization
    if BetterBlizzPlatesDB.enableCastbarCustomization then
        -- Shield icon
        frame.castBar.BorderShield:ClearAllPoints()
        local yOffset = BetterBlizzPlatesDB.castBarDragonflightShield and -1 or 0
        PixelUtil.SetPoint(frame.castBar.BorderShield, "CENTER", frame.castBar, BetterBlizzPlatesDB.castBarIconAnchor, BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos + yOffset)

        -- Spell icon position
        local customOptions = frame.customOptions;
        if not customOptions or not customOptions.ignoreIconPoint then
            frame.castBar.Icon:ClearAllPoints();
            PixelUtil.SetPoint(frame.castBar.Icon, "CENTER", frame.castBar, BetterBlizzPlatesDB.castBarIconAnchor, BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos);
        end
    else
        local verticalScale = tonumber(BetterBlizzPlatesDB.NamePlateVerticalScale)
        if not (verticalScale == 2.7 or verticalScale == 1) then
            if BBP.isLargeNameplatesEnabled() then
                frame.castBar:SetHeight(18.8)
            else
                frame.castBar:SetHeight(8)
            end
        end
    end
end

--function BBP.HookDefaultCompactNamePlateFrameAnchorInternal()
    hooksecurefunc("DefaultCompactNamePlateFrameAnchorInternal", UpdateCastbarAnchors)
--end

-- Castbar has a fade out animation after UNIT_SPELLCAST_STOP has triggered, reset castbar settings after this fadeout
local function ResetCastbarAfterFadeout(unitToken)
    if not BetterBlizzPlatesDB.enableCastbarCustomization then return end
    local nameplate = BBP.GetNameplate(unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end
    if unitToken == "player" then return end
    local castBar = nameplate.UnitFrame.castBar
    local frame = nameplate.UnitFrame
    if castBar:IsForbidden() then return end
    C_Timer.After(0.5, function() 
        castBar:SetHeight(BetterBlizzPlatesDB.castBarHeight)
        castBar.Icon:SetScale(BetterBlizzPlatesDB.castBarIconScale)
        castBar.Spark:SetSize(4, BetterBlizzPlatesDB.castBarHeight + 5)
        castBar.Text:SetScale(BetterBlizzPlatesDB.castBarTextScale)
        castBar.BorderShield:SetScale(BetterBlizzPlatesDB.castBarIconScale)

        if BetterBlizzPlatesDB.castBarEmphasisHealthbarColor then
            if not frame or frame:IsForbidden() then return end
            BBP.CompactUnitFrame_UpdateHealthColor(frame)
        end
    end)
end

-- Cast emphasis
function BBP.CustomizeCastbar(unitToken)
    if not BetterBlizzPlatesDB.enableCastbarCustomization then return end
    local nameplate = BBP.GetNameplate(unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end
    if unitToken == "player" then return end

    local castBar = nameplate.UnitFrame.castBar
    if castBar:IsForbidden() then return end

    castBar:SetStatusBarColor(1,1,1)
    BBP.SetFontBasedOnOption(castBar.Text, 12, "OUTLINE")

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
    castBar.BorderShield:SetScale(BetterBlizzPlatesDB.castBarIconScale)
    castBar:SetHeight(BetterBlizzPlatesDB.castBarHeight)
    castBar.Spark:SetSize(4, BetterBlizzPlatesDB.castBarHeight) --4 width, 5 height original
    castBar.Text:SetScale(BetterBlizzPlatesDB.castBarTextScale)

--[[
    if not castBar.castBarGlow then
        castBar.castBarGlow = castBar:CreateTexture(nil, "OVERLAY")
        castBar.castBarGlow:SetAtlas("covenantsanctum-upgrade-border-available")
        castBar.castBarGlow:SetDesaturated(true)
        castBar.castBarGlow:SetVertexColor(1,0,0)
        --castBar.castBarGlow:SetBlendMode("ADD")
    end
    castBar.castBarGlow:SetPoint("TOPLEFT", castBar, "TOPLEFT", 4, 0)
    castBar.castBarGlow:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", -4, 0)

]]

    --castBar.castBarGlow:SetAllPoints()
    --castBar.castBarGlow:Hide()

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
            if not BetterBlizzPlatesDB.castBarEmphasisSpark then
                castBar.Spark:SetSize(4, BetterBlizzPlatesDB.castBarEmphasisHeightValue + 22)
            end
        end

        if BetterBlizzPlatesDB.castBarEmphasisSpark then
            castBar.Spark:SetSize(4, BetterBlizzPlatesDB.castBarEmphasisSparkHeight)
        end

        if BetterBlizzPlatesDB.castBarEmphasisHealthbarColor then
            nameplate.UnitFrame.healthBar:SetStatusBarColor(castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b)
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
                        nameplate.emphasizedCast = castEmphasis
                        break
                    end
                end
            end
        end
    end
end

-- Hide npcs from list
function BBP.HideCastbar(unitToken)
    local nameplate = BBP.GetNameplate(unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end

    local castBar = nameplate.UnitFrame.castBar
    if castBar:IsForbidden() then return end

    castBar:Show()

    local spellName, spellID, notInterruptible, npcID, npcName

    if UnitCastingInfo(unitToken) then
        spellName, _, _, _, _, _, _, notInterruptible, spellID = UnitCastingInfo(unitToken)
    elseif UnitChannelInfo(unitToken) then
        spellName, _, _, _, _, _, _, notInterruptible, spellID = UnitChannelInfo(unitToken)
    end

    local unitGUID = UnitGUID(unitToken)
    if unitGUID then
        npcID = select(6, strsplit("-", unitGUID))
        npcName = UnitName(unitToken)
    end

    if BetterBlizzPlatesDB.showCastbarIfTarget and UnitIsUnit(unitToken, "target") then
        -- Show the castBar if the unit is the player's current target
        castBar:Show()
        if nameplate.CastTimer then
            nameplate.CastTimer:Show()
        end
        if nameplate.TargetText then
            nameplate.TargetText:Show()
        end
    elseif BetterBlizzPlatesDB.hideCastbarWhitelistOn then
        -- Check if the NPC is in the whitelist by ID, Name, spell ID, or spell Name (case-insensitive)
        local inWhitelist = false
        for _, entry in ipairs(BetterBlizzPlatesDB.hideCastbarWhitelist) do
            if (entry.name and spellName and strlower(entry.name) == strlower(spellName)) or
                (entry.id and spellID and entry.id == spellID) or
                (entry.id and npcID and entry.id == tonumber(npcID)) or
                (entry.name and npcName and strlower(entry.name) == strlower(npcName)) then
                inWhitelist = true
                break
            end
        end

        -- Show the castBar only if the NPC is in the whitelist and is currently casting
        if inWhitelist and UnitCastingInfo(unitToken) then
            castBar:Show()
            if nameplate.CastTimer then
                nameplate.CastTimer:Show()
            end
            if nameplate.TargetText then
                nameplate.TargetText:Show()
            end
        else
            castBar:Hide()
            if nameplate.CastTimer then
                nameplate.CastTimer:Hide()
            end
            if nameplate.TargetText then
                nameplate.TargetText:Hide()
            end
        end
    else
        -- Check if the NPC is in the blacklist by ID, Name, spell ID, or spell Name (case-insensitive)
        local inList = false
        for _, entry in ipairs(BetterBlizzPlatesDB.hideCastbarList) do
            if (entry.name and spellName and strlower(entry.name) == strlower(spellName)) or
                (entry.id and spellID and entry.id == spellID) or
                (entry.id and npcID and entry.id == tonumber(npcID)) or
                (entry.name and npcName and strlower(entry.name) == strlower(npcName)) then
                inList = true
                break
            end
        end

        -- Check if the unit is currently casting and is not in the blacklist
        if UnitCastingInfo(unitToken) and not inList then
            castBar:Show()
            if nameplate.CastTimer then
                nameplate.CastTimer:Show()
            end
            if nameplate.TargetText then
                nameplate.TargetText:Show()
            end
        else
            castBar:Hide()
            if nameplate.CastTimer then
                nameplate.CastTimer:Hide()
            end
            if nameplate.TargetText then
                nameplate.TargetText:Hide()
            end
        end
        if BetterBlizzPlatesDB.hideNpcCastbar then
            if not UnitIsPlayer(unitToken) then
                castBar:Hide()
            end
        end
    end

    if BetterBlizzPlatesDB.onlyShowInterruptableCasts then
        if notInterruptible then
            castBar:Hide()
        end
    end
end




hooksecurefunc(CastingBarMixin, "UpdateShownState", function(self)
    if not BetterBlizzPlatesDB.hideCastbar then return end
    if not BBP.IsLegalNameplateUnit(self) then return end

    local unitToken = self.unit
    if unitToken then
        local nameplate = BBP.GetNameplate(unitToken)
        if nameplate then
            BBP.HideCastbar(unitToken)
        end
    end
end)


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
            C_Timer.After(0.01, function() 
                BBP.UpdateCastTimer(nameplate, unitID) 
                --BBP.HideCastbar(unitID) -- this worked well but could pop up short between casts
            end)
        end
    else
        nameplate.CastTimer:SetText("")
        if nameplate.TargetText then
            nameplate.TargetText:SetText("")
        end
    end
end

-- Spellcast events
local castbarEventFrame = CreateFrame("Frame")
castbarEventFrame:SetScript("OnEvent", function(self, event, unitID)
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
            ResetCastbarAfterFadeout(unitID)
        end
    end
end)

--#################################################################################################
-- Event handler
function BBP.ToggleSpellCastEventRegistration()
    if not BetterBlizzPlatesDB.castbarEventsOn then
        if BetterBlizzPlatesDB.showNameplateCastbarTimer or BetterBlizzPlatesDB.showNameplateTargetText or BetterBlizzPlatesDB.enableCastbarCustomization or BetterBlizzPlatesDB.hideCastbar then
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
            BetterBlizzPlatesDB.castbarEventsOn = true
        end
    else
        if not BetterBlizzPlatesDB.showNameplateCastbarTimer and not BetterBlizzPlatesDB.showNameplateTargetText and not BetterBlizzPlatesDB.enableCastbarCustomization and not BetterBlizzPlatesDB.hideCastbar then
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_START")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_STOP")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
            BetterBlizzPlatesDB.castbarEventsOn = false
        end
    end
end