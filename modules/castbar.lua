-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

local LSM = LibStub("LibSharedMedia-3.0")

local interruptList = {
    [1766] = true,  -- Kick (Rogue)
    [2139] = true,  -- Counterspell (Mage)
    [6552] = true,  -- Pummel (Warrior)
    [19647] = true, -- Spell Lock (Warlock)
    [47528] = true, -- Mind Freeze (Death Knight)
    [57994] = true, -- Wind Shear (Shaman)
    [91802] = true, -- Shambling Rush (Death Knight)
    [96231] = true, -- Rebuke (Paladin)
    [106839] = true,-- Skull Bash (Feral)
    [115781] = true,-- Optical Blast (Warlock)
    [116705] = true,-- Spear Hand Strike (Monk)
    [132409] = true,-- Spell Lock (Warlock)
    [119910] = true,-- Spell Lock (Warlock Pet)
    [147362] = true,-- Countershot (Hunter)
    [171138] = true,-- Shadow Lock (Warlock)
    [183752] = true,-- Consume Magic (Demon Hunter)
    [187707] = true,-- Muzzle (Hunter)
    [212619] = true,-- Call Felhunter (Warlock)
    [231665] = true,-- Avengers Shield (Paladin)
    [351338] = true,-- Quell (Evoker)
    [97547]  = true,-- Solar Beam
}

local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction

local useCustomCastbarTextureHooked

local interruptSpellIDs = {}
function BBP.InitializeInterruptSpellID()
    interruptSpellIDs = {}
    for spellID in pairs(interruptList) do
        if IsSpellKnownOrOverridesKnown(spellID) then
            table.insert(interruptSpellIDs, spellID)
        end
    end
end

-- Recheck interrupt spells when lock resummons/sacrifices pet
local recheckInterruptListener = CreateFrame("Frame")
local function OnEvent(self, event, unit, _, spellID)
    if spellID == 691 or spellID == 108503 then
        BBP.InitializeInterruptSpellID()
    end
end
recheckInterruptListener:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
recheckInterruptListener:SetScript("OnEvent", OnEvent)

-- Castbar has a fade out animation after UNIT_SPELLCAST_STOP has triggered, reset castbar settings after this fadeout
local function ResetCastbarAfterFadeout(unitToken)
    local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
    if not enableCastbarCustomization then return end

    local nameplate = BBP.GetNameplate(unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end
    if unitToken == "player" then return end

    local castBar = nameplate.UnitFrame.castBar
    local frame = nameplate.UnitFrame
    if castBar:IsForbidden() then return end

    local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
    if useCustomCastbarTexture and event and unitID then
        if not nameplate then return end
        local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
        local castBarTexture = castBar:GetStatusBarTexture()
        local textureName = BetterBlizzPlatesDB.customCastbarTexture
        local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
        if castBar.Flash then
            castBar.Flash:SetTexture(texturePath)
        end
        if castBarTexture then
            castBar:SetStatusBarTexture(texturePath)
            if not castBarRecolor then
                castBarTexture:SetDesaturated(true)
            end
        end
    end

    C_Timer.After(0.5, function()
        local showCastBarIconWhenNoninterruptible = BetterBlizzPlatesDB.showCastBarIconWhenNoninterruptible
        local castBarIconScale = BetterBlizzPlatesDB.castBarIconScale
        local castBarHeight = BetterBlizzPlatesDB.castBarHeight
        local castBarTextScale = BetterBlizzPlatesDB.castBarTextScale
        local castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor

        local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale + 0.3) or castBarIconScale

        castBar:SetHeight(castBarHeight)
        castBar.Icon:SetScale(castBarIconScale)
        castBar.Spark:SetSize(4, castBarHeight + 5)
        castBar.Text:SetScale(castBarTextScale)
        castBar.BorderShield:SetScale(borderShieldSize)
        if (not UnitCastingInfo(unitToken) and not UnitChannelInfo(unitToken)) then
            castBar.BorderShield:Hide()
        end

        if castBarEmphasisHealthbarColor then
            if not frame or frame:IsForbidden() then return end
            BBP.CompactUnitFrame_UpdateHealthColor(frame)
        end
    end)
end

-- Cast emphasis
function BBP.CustomizeCastbar(unitToken)
    local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
    if not enableCastbarCustomization then return end

    local nameplate = BBP.GetNameplate(unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end
    if unitToken == "player" then return end

    local castBar = nameplate.UnitFrame.castBar
    if castBar:IsForbidden() then return end

    local showCastBarIconWhenNoninterruptible = BetterBlizzPlatesDB.showCastBarIconWhenNoninterruptible
    local castBarIconScale = BetterBlizzPlatesDB.castBarIconScale
    local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale + 0.3) or castBarIconScale
    local castBarTexture = castBar:GetStatusBarTexture()
    local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
    local castBarDragonflightShield = BetterBlizzPlatesDB.castBarDragonflightShield
    local castBarHeight = BetterBlizzPlatesDB.castBarHeight
    local castBarTextScale = BetterBlizzPlatesDB.castBarTextScale
    local castBarCastColor = BetterBlizzPlatesDB.castBarCastColor
    local castBarChanneledColor = BetterBlizzPlatesDB.castBarChanneledColor
    local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture

    if not castBarRecolor then
        if castBarTexture then
            castBarTexture:SetDesaturated(false)
        end
    end

    castBar:SetStatusBarColor(1, 1, 1)

    local spellName, spellID, notInterruptible, endTime
    local casting, channeling
    if UnitCastingInfo(unitToken) then
        casting = true
        spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(unitToken)
        if castBarRecolor and not notInterruptible then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            castBar:SetStatusBarColor(unpack(castBarCastColor))
        end
    elseif UnitChannelInfo(unitToken) then
        channeling = true
        spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(unitToken)
        if castBarRecolor and not notInterruptible then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            castBar:SetStatusBarColor(unpack(castBarChanneledColor))
        end
    end

    if useCustomCastbarTexture then
        local textureName = BetterBlizzPlatesDB.customCastbarTexture
        local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
        local bgTextureName = BetterBlizzPlatesDB.customCastbarBGTexture
        local bgTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, bgTextureName)
        local changeBgTexture = BetterBlizzPlatesDB.useCustomCastbarBGTexture
        castBar:SetStatusBarTexture(texturePath)
        castBarTexture:SetDesaturated(true)
        if castBarTexture then
            if changeBgTexture then
                local bgColor = BetterBlizzPlatesDB.castBarBackgroundColor
                castBar.Background:SetDesaturated(true)
                castBar.Background:SetTexture(bgTexture)
                castBar.Background:SetVertexColor(unpack(bgColor))
                end
                if not castBarRecolor then
                    castBarTexture:SetDesaturated(true)
                    if casting then
                        if not nameplate.emphasizedCast then
                            castBar:SetStatusBarColor(unpack(castBarCastColor))
                    elseif channeling then
                        if not nameplate.emphasizedCast then
                            castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                        end
                    end
                end
            end
        end
    end

    BBP.SetFontBasedOnOption(castBar.Text, 12, "OUTLINE")

    if castBarDragonflightShield then
        castBar.BorderShield:SetTexture(nil)
        castBar.BorderShield:SetAtlas("ui-castingbar-shield")
    else
        castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
    end

    castBar.Icon:SetScale(castBarIconScale)
    castBar.BorderShield:SetScale(borderShieldSize)
    castBar:SetHeight(castBarHeight)
    castBar.Spark:SetSize(4, castBarHeight) --4 width, 5 height original
    castBar.Text:SetScale(castBarTextScale)

    if showCastBarIconWhenNoninterruptible then
        castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
        castBar.Icon:Show()
        castBar.Icon:SetDrawLayer("OVERLAY", 2)
    end

    local function ApplyCastBarEmphasisSettings(castBar, castEmphasis)
        local castBarEmphasisColor = BetterBlizzPlatesDB.castBarEmphasisColor
        local castBarEmphasisText = BetterBlizzPlatesDB.castBarEmphasisText
        local castBarEmphasisIcon = BetterBlizzPlatesDB.castBarEmphasisIcon
        local castBarEmphasisHeight = BetterBlizzPlatesDB.castBarEmphasisHeight
        local castBarEmphasisSpark = BetterBlizzPlatesDB.castBarEmphasisSpark
        local castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
        local castBarEmphasisTextScale = BetterBlizzPlatesDB.castBarEmphasisTextScale
        local castBarEmphasisIconScale = BetterBlizzPlatesDB.castBarEmphasisIconScale
        local castBarEmphasisHeightValue = BetterBlizzPlatesDB.castBarEmphasisHeightValue
        local castBarEmphasisSparkHeight = BetterBlizzPlatesDB.castBarEmphasisSparkHeight

        if castBarEmphasisColor and castEmphasis.entryColors then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            castBar:SetStatusBarColor(castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b)
        end

        if castBarEmphasisText then
            castBar.Text:SetScale(castBarEmphasisTextScale)
        end

        if castBarEmphasisIcon then
            castBar.Icon:SetScale(castBarEmphasisIconScale)
            castBar.BorderShield:SetScale(castBarEmphasisIconScale - 0.4)
        end

        if castBarEmphasisHeight then
            castBar:SetHeight(castBarEmphasisHeightValue)
            if not castBarEmphasisSpark then
                castBar.Spark:SetSize(4, castBarEmphasisHeightValue + 22)
            end
        end

        if castBarEmphasisSpark then
            castBar.Spark:SetSize(4, castBarEmphasisSparkHeight)
        end

        if castBarEmphasisHealthbarColor then
            if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.healthBar then
                nameplate.UnitFrame.healthBar:SetStatusBarColor(castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b)
            end
        end
    end

    local enableCastbarEmphasis = BetterBlizzPlatesDB.enableCastbarEmphasis
    local castBarEmphasisOnlyInterruptable = BetterBlizzPlatesDB.castBarEmphasisOnlyInterruptable
    local castEmphasisList = BetterBlizzPlatesDB.castEmphasisList
    local castBarRecolorInterrupt = BetterBlizzPlatesDB.castBarRecolorInterrupt
    local castBarNoInterruptColor = BetterBlizzPlatesDB.castBarNoInterruptColor
    local castBarDelayedInterruptColor = BetterBlizzPlatesDB.castBarDelayedInterruptColor

    if enableCastbarEmphasis then
        if spellName or spellID then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitToken)
            if isEnemy or isNeutral then
                if castBarEmphasisOnlyInterruptable and notInterruptible then
                    -- Skip emphasizing non-kickable casts when configured to do so
                    return
                end

                for _, castEmphasis in ipairs(castEmphasisList) do
                    if (castEmphasis.name and spellName and strlower(castEmphasis.name) == strlower(spellName)) or
                       (castEmphasis.id and spellID and castEmphasis.id == spellID) then
                        ApplyCastBarEmphasisSettings(castBar, castEmphasis)
                        nameplate.emphasizedCast = castEmphasis
                    else
                        nameplate.emphasizedCast = nil
                    end
                end
            end
        end
    end

    if castBarRecolorInterrupt then
        --if not UnitIsFriend(unitToken, "player") then
            if spellName or spellID then
                for _, interruptSpellIDx in ipairs(interruptSpellIDs) do
                    local start, duration = GetSpellCooldown(interruptSpellIDx)
                    local cooldownRemaining = start + duration - GetTime()
                    local castRemaining = (endTime/1000) - GetTime()

                    if not notInterruptible then
                        if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
                            if castBarTexture then
                                castBarTexture:SetDesaturated(true)
                            end
                            castBar:SetStatusBarColor(unpack(castBarNoInterruptColor))
                        elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
                            if castBarTexture then
                                castBarTexture:SetDesaturated(true)
                            end
                            castBar:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
                        else
                            if not castBarRecolor and not useCustomCastbarTexture then
                                if castBarTexture then
                                    castBarTexture:SetDesaturated(false)
                                end
                                castBar:SetStatusBarColor(1, 1, 1)
                            else
                                if UnitCastingInfo(unitToken) then
                                    castBar:SetStatusBarColor(unpack(castBarCastColor))
                                elseif UnitChannelInfo(unitToken) then
                                    castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                                end
                            end
                        end
                    end
                end
            end
        --end
    end
end

-- Hide npcs from list
function BBP.HideCastbar(nameplate, unitToken)
    if not (nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar) then return end

    local castBar = nameplate.UnitFrame.castBar
    if castBar:IsForbidden() then return end

    --local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitToken)

    local showCastbarIfTarget = BetterBlizzPlatesDB.showCastbarIfTarget
    local hideCastbarWhitelistOn = BetterBlizzPlatesDB.hideCastbarWhitelistOn
    local onlyShowInterruptableCasts = BetterBlizzPlatesDB.onlyShowInterruptableCasts

--[[
    local hideFriendlyCastbars = true--BetterBlizzPlatesDB.hideFriendlyCastbars

    if hideFriendlyCastbars then
        if isFriend then
            castBar:Hide()
            return
        end
    end

]]


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

    if showCastbarIfTarget and UnitIsUnit(unitToken, "target") then
        -- Show the castBar if the unit is the player's current target
        castBar:Show()
        if nameplate.CastTimer then
            nameplate.CastTimer:Show()
        end
        if nameplate.TargetText then
            nameplate.TargetText:Show()
        end
    elseif hideCastbarWhitelistOn then
        -- Check if the NPC is in the whitelist by ID, Name, spell ID, or spell Name (case-insensitive)
        local inWhitelist = false
        local hideCastbarWhitelist = BetterBlizzPlatesDB.hideCastbarWhitelist
        for _, entry in ipairs(hideCastbarWhitelist) do
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
        local hideCastbarList = BetterBlizzPlatesDB.hideCastbarList
        local hideNpcCastbar = BetterBlizzPlatesDB.hideNpcCastbar

        for _, entry in ipairs(hideCastbarList) do
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
        if hideNpcCastbar then
            if not UnitIsPlayer(unitToken) then
                castBar:Hide()
            end
        end
    end

    if onlyShowInterruptableCasts then
        if notInterruptible then
            castBar:Hide()
        end
    end
end

-- Update text and color based on the target
function BBP.UpdateNameplateTargetText(nameplate, unitID)
    if not nameplate or not unitID then return end
    if UnitIsUnit(unitID, "player") then return end

    if not nameplate.TargetText then
        nameplate.TargetText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameplate.TargetText:SetJustifyH("CENTER")
    end

    local isCasting = UnitCastingInfo(unitID) or UnitChannelInfo(unitID)

    if isCasting and UnitExists(unitID.."target") and nameplate.UnitFrame.healthBar:IsShown() and not nameplate.UnitFrame.hideCastInfo then
        local targetOfTarget = unitID.."target"
        local name = UnitName(targetOfTarget)
        local _, class = UnitClass(targetOfTarget)
        local color = RAID_CLASS_COLORS[class]
        local useCustomFont = BetterBlizzPlatesDB.useCustomFont

        nameplate.TargetText:SetText(name)
        nameplate.TargetText:SetTextColor(color.r, color.g, color.b)
        if not UnitIsFriend("player", unitID) then
            nameplate.TargetText:SetPoint("RIGHT", nameplate, "BOTTOMRIGHT", -11, 0)  -- Set anchor point for enemy
        else
            nameplate.TargetText:SetPoint("CENTER", nameplate, "BOTTOM", 0, 0)  -- Set anchor point for friendly
        end
        BBP.SetFontBasedOnOption(nameplate.TargetText, useCustomFont and 11 or 12)
    else
        nameplate.TargetText:SetText("")
    end
end

function BBP.UpdateCastTimer(nameplate, unitID)
    if not nameplate or not unitID then return end
    if UnitIsUnit(unitID, "player") then return end

    if not nameplate.CastTimerFrame then
        nameplate.CastTimerFrame = CreateFrame("Frame", nil, nameplate)
        nameplate.CastTimer = nameplate.CastTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        --nameplate.CastTimer:SetPoint("LEFT", nameplate, "BOTTOMRIGHT", -10, 15)
        nameplate.CastTimer:SetPoint("LEFT", nameplate.UnitFrame.castBar, "RIGHT", 5, 0)
        BBP.SetFontBasedOnOption(nameplate.CastTimer, 12, "OUTLINE")
        nameplate.CastTimer:SetTextColor(1, 1, 1)
    end

    local name, _, _, startTime, endTime = UnitCastingInfo(unitID)
    if not name then
        name, _, _, startTime, endTime = UnitChannelInfo(unitID)
    end

    if name and endTime and startTime and nameplate.UnitFrame and nameplate.UnitFrame.healthBar:IsShown() and not nameplate.UnitFrame.hideCastInfo then
        local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization

        if enableCastbarCustomization then
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
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
        local nameplate = BBP.GetNameplate(unitID)
        if not nameplate then return end

        local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
        local showNameplateCastbarTimer = BetterBlizzPlatesDB.showNameplateCastbarTimer
        local showNameplateTargetText = BetterBlizzPlatesDB.showNameplateTargetText
        local hideCastbar = BetterBlizzPlatesDB.hideCastbar
        if enableCastbarCustomization then
            BBP.CustomizeCastbar(unitID)
        end
        if showNameplateCastbarTimer then
            BBP.UpdateCastTimer(nameplate, unitID)
        end

        if hideCastbar then
            BBP.HideCastbar(nameplate, unitID)
        end

        if showNameplateTargetText then
            BBP.UpdateNameplateTargetText(nameplate, unitID)
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" or
       event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or
       event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        local nameplate = BBP.GetNameplate(unitID)
        if not nameplate then return end

        local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
        local showNameplateCastbarTimer = BetterBlizzPlatesDB.showNameplateCastbarTimer
        local showNameplateTargetText = BetterBlizzPlatesDB.showNameplateTargetText
        if enableCastbarCustomization then
            ResetCastbarAfterFadeout(unitID)
            if event =="UNIT_SPELLCAST_INTERRUPTED" then
                if nameplate.UnitFrame.castBar then
                    nameplate.UnitFrame.castBar:SetStatusBarColor(1,0,0)
                end
            end
        end
        if showNameplateTargetText then
            BBP.UpdateNameplateTargetText(nameplate, unitID)
        end
        if showNameplateCastbarTimer then
            BBP.UpdateCastTimer(nameplate, unitID)
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local showWhoInterrupted = BetterBlizzPlatesDB.interruptedByIndicator
        if showWhoInterrupted then
            local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
            if subevent == "SPELL_INTERRUPT" then

                local destUnit = UnitTokenFromGUID(destGUID)
                if string.match(destUnit or "", "nameplate") then
                    local npbase = C_NamePlate.GetNamePlateForUnit(destUnit, false)
                    if npbase then
                        if sourceName then
                            local name, server = strsplit("-", sourceName)
                            local colorStr = "ffFFFFFF"

                            if C_PlayerInfo.GUIDIsPlayer(sourceGUID) then
                                local localizedClass, englishClass, localizedRace, englishRace, sex, _name, realm = GetPlayerInfoByGUID(sourceGUID)
                                colorStr = RAID_CLASS_COLORS[englishClass].colorStr
                            end
                            if showWhoInterrupted then
                                npbase.UnitFrame.castBar.Text:SetText(string.format("|c%s[%s]|r", colorStr, name))
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Event handler
function BBP.ToggleSpellCastEventRegistration()
    if not BetterBlizzPlatesDB.castbarEventsOn then
        if BetterBlizzPlatesDB.showNameplateCastbarTimer or BetterBlizzPlatesDB.showNameplateTargetText or BetterBlizzPlatesDB.enableCastbarCustomization or BetterBlizzPlatesDB.hideCastbar then
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
            castbarEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            if BetterBlizzPlatesDB.interruptedByIndicator then
                castbarEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            end
            if not useCustomCastbarTextureHooked and BetterBlizzPlatesDB.useCustomCastbarTexture then
                hooksecurefunc(CastingBarMixin, "OnEvent", function(self)
                    if self and not self.unit:find("nameplate") then return end
                    local textureName = BetterBlizzPlatesDB.customCastbarTexture
                    local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                    if not self.hooked then
                        hooksecurefunc(self, "SetStatusBarTexture", function(self)
                            if self.changing then return end
                            self.changing = true
                            self:SetStatusBarTexture(texturePath)
                            self.changing = false
                        end)
                        if self.Flash then
                            hooksecurefunc(self.Flash, "SetAtlas", function(self)
                                if self.changing then return end
                                self.changing = true
                                self:SetTexture(texturePath)
                                self.changing = false
                            end)
                        end
                        self.hooked = true
                    end
                end)
                useCustomCastbarTextureHooked = true
            end

            BetterBlizzPlatesDB.castbarEventsOn = true
        end
    else
        if not BetterBlizzPlatesDB.showNameplateCastbarTimer and not BetterBlizzPlatesDB.showNameplateTargetText and not BetterBlizzPlatesDB.enableCastbarCustomization and not BetterBlizzPlatesDB.hideCastbar then
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_START")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_STOP")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_FAILED")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
            castbarEventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            if BetterBlizzPlatesDB.interruptedByIndicator then
                castbarEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            end
            BetterBlizzPlatesDB.castbarEventsOn = false
        end
    end
end


--[[
hooksecurefunc(CastingBarMixin, "OnEvent", function(self)
    if self and not self.unit:find("nameplate") then return end
    local textureName = BetterBlizzPlatesDB.customCastbarTexture
    local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
    if not self.hooked then
        hooksecurefunc(self, "SetStatusBarTexture", function(self)
            if self.changing then return end
            self.changing = true 
            self:SetStatusBarTexture(texturePath) 
            self.changing = false
        end)
        if self.Flash then
            hooksecurefunc(self.Flash, "SetAtlas", function(self)
                if self.changing then return end
                self.changing = true
                self:SetTexture(texturePath)
                self.changing = false
            end)
        end
        self.hooked = true
    end
end)

]]