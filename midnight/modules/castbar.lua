if not BBP.isMidnight then return end
local LSM = LibStub("LibSharedMedia-3.0")

local interruptSpells = {
    [1766]   = true, -- Kick (Rogue)
    [2139]   = true, -- Counterspell (Mage)
    [6552]   = true, -- Pummel (Warrior)
    [19647]  = true, -- Spell Lock (Warlock)
    [47528]  = true, -- Mind Freeze (Death Knight)
    [57994]  = true, -- Wind Shear (Shaman)
    --[91802]  = true, -- Shambling Rush (Death Knight)
    [96231]  = true, -- Rebuke (Paladin)
    [106839] = true, -- Skull Bash (Feral)
    [115781] = true, -- Optical Blast (Warlock)
    [116705] = true, -- Spear Hand Strike (Monk)
    [132409] = true, -- Spell Lock (Warlock)
    [119910] = true, -- Spell Lock (Warlock Pet)
    [89766]  = true, -- Axe Toss (Warlock Pet)
    [171138] = true, -- Shadow Lock (Warlock)
    [147362] = true, -- Countershot (Hunter)
    [183752] = true, -- Disrupt (Demon Hunter)
    [187707] = true, -- Muzzle (Hunter)
    [212619] = true, -- Call Felhunter (Warlock)
    --[231665] = true, -- Avengers Shield (Paladin)
    [351338] = true, -- Quell (Evoker)
    [97547]  = true, -- Solar Beam
    [78675]  = true, -- Solar Beam
    [15487]  = true, -- Silence
    --[47482]  = true, -- Leap (DK Transform)
}

-- Local variable to store the known interrupt spell ID
local playerKick = nil

-- Interrupt ready status
BBP.interruptReady = true
BBP.interruptStatusColorOn = false

-- Recheck interrupt spells when lock resummons/sacrifices pet
local petSummonSpells = {
    [30146]  = true, -- Summon Demonic Tyrant (Demonology)
    [691]    = true, -- Summon Felhunter (for Spell Lock)
    [108503] = true, -- Grimoire of Sacrifice
}

local function GetInterruptSpell()
    for spellID, _ in pairs(interruptSpells) do
        if IsSpellKnownOrOverridesKnown(spellID) or (UnitExists("pet") and IsSpellKnownOrOverridesKnown(spellID, true)) then
            return spellID
        end
    end
    return nil
end
BBP.GetInterruptSpell = GetInterruptSpell

BBP.interruptIcon = CreateFrame("Frame")
BBP.interruptIcon.cooldown = CreateFrame("Cooldown", nil, BBP.interruptIcon, "CooldownFrameTemplate")
BBP.interruptIcon.cooldown:HookScript("OnCooldownDone", function()
    BBP.interruptReady = true
    BBP.UpdateCastbarInterruptStatus()
end)

function BBP.UpdateCastbarInterruptStatus()
    if not BetterBlizzPlatesDB.castBarRecolorInterrupt then return end
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        if frame and frame.castBar and frame.castBar:IsShown() then
            BBP.CustomizeCastbar(frame, frame.unit)
        end
    end
end

local function UpdateInterruptIcon(frame)
    if not playerKick then
        playerKick = GetInterruptSpell()
    end
    if playerKick then
        local cooldownInfo = C_Spell.GetSpellCooldown(playerKick)
        if cooldownInfo then
            frame.cooldown:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration)
        end
    end
end

local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction

local useCustomCastbarTextureHooked = false
local classicFrames

local interruptedText = SPELL_FAILED_INTERRUPTED

local function OnEvent(self, event, unit, _, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- Check if player used an interrupt spell
        if interruptSpells[spellID] then
            local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
            if cooldownInfo then
                BBP.interruptIcon.cooldown:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration)
            end
            BBP.interruptReady = false
            if BetterBlizzPlatesDB.castBarRecolorInterrupt then
                BBP.UpdateCastbarInterruptStatus()
            end
            return
        end
        -- Check for pet summon spells
        if not petSummonSpells[spellID] then return end
    end
    if BetterBlizzPlatesDB.castBarRecolorInterrupt and BetterBlizzPlatesDB.enableCastbarCustomization then
        C_Timer.After(0.1, function()
            playerKick = GetInterruptSpell()
            UpdateInterruptIcon(BBP.interruptIcon)
            for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                local frame = namePlate.UnitFrame
                BBP.CustomizeCastbar(frame, frame.unit)
            end
        end)
    end
end

local interruptSpellUpdate = CreateFrame("Frame")
interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
interruptSpellUpdate:RegisterEvent("TRAIT_CONFIG_UPDATED")
interruptSpellUpdate:RegisterEvent("PLAYER_TALENT_UPDATE")
interruptSpellUpdate:SetScript("OnEvent", OnEvent)

local cooldownFrame = CreateFrame("Frame")
cooldownFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
cooldownFrame:SetScript("OnEvent", function(self, event, spellID)
    if spellID and spellID ~= playerKick then return end
    UpdateInterruptIcon(BBP.interruptIcon)
end)

C_Timer.After(1, function()
    playerKick = GetInterruptSpell()
    if playerKick then
        UpdateInterruptIcon(BBP.interruptIcon)
    end
end)

-- Cast emphasis
function BBP.CustomizeCastbar(frame, unitToken, event)
    local db = BetterBlizzPlatesDB
    local enableCastbarCustomization = db.enableCastbarCustomization
    if not enableCastbarCustomization then return end
    if unitToken == "player" then return end

    local castBar = frame.castBar
    if not castBar then return end
    if castBar:IsForbidden() then return end

    -- if frame.ogParent then
    --     frame:SetParent(frame.ogParent)
    --     frame.ogParent = nil
    -- end

    local showCastBarIconWhenNoninterruptible = db.showCastBarIconWhenNoninterruptible
    local castBarIconScale = db.castBarIconScale
    local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale + 0.3) or castBarIconScale
    local castBarTexture = castBar:GetStatusBarTexture()
    local castBarRecolor = db.castBarRecolor
    local castBarDragonflightShield = db.castBarDragonflightShield
    local castBarHeight = db.castBarHeight
    local castBarTextScale = db.castBarTextScale
    local castBarCastColor = db.castBarCastColor
    local castBarNonInterruptibleColor = db.castBarNoninterruptibleColor
    local interruptNotReady = db.castBarNoInterruptColor
    local castBarChanneledColor = db.castBarChanneledColor
    local useCustomCastbarTexture = db.useCustomCastbarTexture
    local hideCastbarText = db.hideCastbarText
    local hideCastbarBorderShield = db.hideCastbarBorderShield
    local hideCastbarIcon = db.hideCastbarIcon
    local castBarIconPixelBorder = db.castBarIconPixelBorder
    local castBarPixelBorder = db.castBarPixelBorder

    if not castBarRecolor then
        if castBarTexture then
            castBarTexture:SetDesaturated(false)
        end
    end

    if event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_START" then
        if not classicFrames then
            castBar:SetStatusBarColor(1,1,1)
        end
    end

    local spellName, spellID, notInterruptible, empoweredCast
    local casting, channeling
    local _
    notInterruptible = false--castBar.barType == "uninterruptable"
    empoweredCast = false--castBar.barType == "empowered"

    if frame.castbarEmphasisActive then
        BBP.CompactUnitFrame_UpdateHealthColor(frame)
        castBar:SetHeight(castBarHeight)
        castBar.Icon:SetScale(castBarIconScale)
        castBar.Spark:SetSize(4, castBarHeight + 5)
        castBar.Text:SetScale(castBarTextScale)
        castBar.BorderShield:SetScale(borderShieldSize)
        --frame:GetParent():SetParent(WorldFrame)
        frame.castbarEmphasisActive = false
        frame.emphasizedCast = nil
    end

    if castBar.emphasisColored then
        castBar.emphasisColored = nil
        if castBarTexture then
            castBarTexture:SetDesaturated(false)
        end
        castBar:SetStatusBarColor(1,1,1)
    end

    if castBarPixelBorder then
        BBP.SetupBorderOnFrame(castBar)
    end
    if castBarIconPixelBorder then
        if not castBar.adjustedIcon then
            if not frame.castBarIconFrame then
                frame.castBarIconFrame = CreateFrame("Frame", nil, frame.castBar)
                frame.castBarIconFrame:SetFrameStrata("MEDIUM")
                frame.castBarIconFrame:SetFrameLevel(frame.castBar:GetFrameLevel()+1)
                frame.castBarIconFrame:SetSize(14, 14)
                frame.castBarIconFrame:SetScale(BetterBlizzPlatesDB.castBarIconScale or 1.0)
                local xPos = BetterBlizzPlatesDB.castBarIconXPos or 0
                local yPos = BetterBlizzPlatesDB.castBarIconYPos or 0
                frame.castBarIconFrame:SetPoint("CENTER", frame.castBar, "LEFT", -2 + xPos, yPos)

                frame.castBarIconFrame.Icon = frame.castBarIconFrame:CreateTexture(nil, "OVERLAY")
                frame.castBarIconFrame.Icon:SetAllPoints(frame.castBarIconFrame)

                local currentTexture = frame.castBar.Icon:GetTexture()
                if currentTexture then
                    frame.castBarIconFrame.Icon:SetTexture(currentTexture)
                end

                frame.castBar.Icon:SetAlpha(0)

                hooksecurefunc(frame.castBar.Icon, "SetTexture", function(self, texture)
                    if frame:IsForbidden() then return end
                    frame.castBarIconFrame.Icon:SetTexture(texture)
                end)

                hooksecurefunc(frame.castBar.Icon, "Show", function(self)
                    if frame:IsForbidden() then return end
                    frame.castBarIconFrame:Show()
                end)

                hooksecurefunc(frame.castBar.Icon, "SetShown", function(self)
                    if frame:IsForbidden() then return end
                    frame.castBarIconFrame:SetShown(self:IsShown())
                end)

                hooksecurefunc(frame.castBar.Icon, "Hide", function(self)
                    if frame:IsForbidden() then return end
                    frame.castBarIconFrame:Hide()
                end)

                hooksecurefunc(frame.castBar.BorderShield, "SetPoint", function(self)
                    if frame:IsForbidden() then return end
                    if self.changingIconPos then return end
                    self.changingIconPos = true
                    self:ClearAllPoints()
                    if frame.castBarIconFrame:IsShown() then
                        self:SetPoint("TOPLEFT", frame.castBarIconFrame, "TOPLEFT", -2, 2)
                        self:SetPoint("BOTTOMRIGHT", frame.castBarIconFrame, "BOTTOMRIGHT", 2, -4)
                    else
                        self:SetPoint("TOPLEFT", frame.castBarIconFrame, "TOPLEFT", 0, 0)
                        self:SetPoint("BOTTOMRIGHT", frame.castBarIconFrame, "BOTTOMRIGHT", 0, -2)
                    end
                    self.changingIconPos = nil
                end)
            end
            frame.castBarIconFrame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            BBP.SetupBorderOnFrame(frame.castBarIconFrame.Icon)
            frame.castBarIconFrame.Icon:HookScript("OnShow", function()
                for _, border in ipairs(frame.castBarIconFrame.Icon.borders) do
                    border:Show()
                end
            end)
            frame.castBarIconFrame.Icon:HookScript("OnHide", function()
                for _, border in ipairs(frame.castBarIconFrame.Icon.borders) do
                    border:Hide()
                end
            end)
            castBar.BorderShield:HookScript("OnShow", function()
                for _, border in ipairs(frame.castBarIconFrame.Icon.borders) do
                    border:Hide()
                end
                if not showCastBarIconWhenNoninterruptible then
                    frame.castBarIconFrame.Icon:Hide()
                end
            end)
            castBar.adjustedIcon = true
        end
    end

    castBar.Text:ClearAllPoints()
    if db.castBarFullTextWidth then
        castBar.Text:SetPoint("TOPLEFT", castBar, "TOPLEFT", -70, 0)
        castBar.Text:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 70, 0)
    else
        castBar.Text:SetPoint("TOPLEFT", castBar, "TOPLEFT", -2, 0)
        castBar.Text:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 2, 0)
    end

    if castBar.casting then
        casting = true
        if castBarRecolor then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            if not notInterruptible then
                castBar:SetStatusBarColor(unpack(castBarCastColor))
            else
                castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
            end
        end
    elseif castBar.channeling then
        if empoweredCast then
            casting = true
            channeling= false
        else
            casting = false
            channeling = true
        end
        if castBarRecolor then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            if not notInterruptible then
                castBar:SetStatusBarColor(unpack(castBarChanneledColor))
            else
                castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
            end
        end
    end

    if useCustomCastbarTexture then
        local textureName = BetterBlizzPlatesDB.customCastbarTexture
        local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
        local bgTextureName = BetterBlizzPlatesDB.customCastbarBGTexture
        local bgTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, bgTextureName)
        local changeBgTexture = BetterBlizzPlatesDB.useCustomCastbarBGTexture
        castBar:SetStatusBarTexture(texturePath)
        if castBarTexture then
            castBarTexture:SetDesaturated(true)
            if changeBgTexture then
                local bgColor = BetterBlizzPlatesDB.castBarBackgroundColor
                castBar.Background:SetDesaturated(true)
                castBar.Background:SetTexture(bgTexture)
                castBar.Background:SetAllPoints(castBar)
                if notInterruptible and BetterBlizzPlatesDB.redBgCastColor then
                    castBar.Background:SetVertexColor(1,0,0,1)
                else
                    castBar.Background:SetVertexColor(unpack(bgColor))
                end
            end
        end
    end

    if castBarRecolor or useCustomCastbarTexture then
        if castBarTexture then
            castBarTexture:SetDesaturated(true)
        end
        -- if castBar.barType == "uninterruptable" then
        --     castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
        if BBP.interruptStatusColorOn and not BBP.interruptReady then
            castBar:SetStatusBarColor(unpack(interruptNotReady or { 0.7, 0.7, 0.7, 1 }))
        elseif castBar.channeling then
            castBar:SetStatusBarColor(unpack(castBarChanneledColor))
        -- elseif castBar.barType == "interrupted" then
        --     castBar:SetStatusBarColor(1, 0, 0)
        else
            castBar:SetStatusBarColor(unpack(castBarCastColor))
        end
    else
        if BBP.interruptStatusColorOn and not BBP.interruptReady then
            castBar:SetStatusBarColor(unpack(interruptNotReady or { 0.7, 0.7, 0.7, 1 }))
        else
            castBar:SetStatusBarColor(1,1,1)
        end
    end

    local useCustomFont = BetterBlizzPlatesDB.useCustomFont
    if useCustomFont then
        BBP.SetFontBasedOnOption(castBar.Text, 12, "OUTLINE")
    else
        local f = castBar.Text:GetFont()
        castBar.Text:SetFont(f,12,"OUTLINE")
    end

    if hideCastbarText then
        castBar.Text:SetAlpha(0)
    end


    if db.hideNameDuringCast then
        if (casting or channeling) then
            frame.castHiddenName = true
            frame.name:SetText("")
            if frame.specNameText then
                frame.specNameText:SetText("")
            end
        end

        if not castBar.hideNameWhileCasting then
            hooksecurefunc(castBar, "Hide", function(self)
                if frame:IsForbidden() or not self.unit then return end
                if frame.castHiddenName then
                    frame.castHiddenName = nil
                    CompactUnitFrame_UpdateName(frame)
                end
            end)
            castBar.hideNameWhileCasting = true
        end

    end

    if hideCastbarBorderShield then
        castBar.BorderShield:SetTexture(nil)
    elseif castBarDragonflightShield then
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

    if not hideCastbarIcon then
        if showCastBarIconWhenNoninterruptible and notInterruptible then
            castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
            castBar.Icon:Show()
            castBar.Icon:SetDrawLayer("OVERLAY", 2)
        else
            if (casting or channeling) and not notInterruptible then
                castBar.Icon:Show() --attempt to fix icon randomly not showing (blizz bug)
            elseif not castBar:IsVisible() then
                castBar.Icon:Hide()
            end
        end
    else
        castBar.Icon:Hide()
        castBar.Icon:SetAlpha(0)
    end

    if castBar.oldParent then
        castBar:SetParent(castBar.oldParent)
        castBar:SetFrameStrata("MEDIUM")
        castBar.oldParent = nil
    end

    local castBarRecolorInterrupt = db.castBarRecolorInterrupt

    if castBarRecolorInterrupt then
        BBP.interruptStatusColorOn = true
        if (casting or channeling) then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitToken)
            if not isFriend then
                if not BBP.interruptReady then
                    if castBarTexture then
                        castBarTexture:SetDesaturated(true)
                    end
                    castBar:SetStatusBarColor(unpack(db.castBarNoInterruptColor or { 0.7, 0.7, 0.7, 1 }))
                end
            end
        end
    else
        BBP.interruptStatusColorOn = false
    end
end


-- Hide npcs from list
function BBP.HideCastbar(frame, unitToken)
    if not frame.castBar then return end
    local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config or BBP.InitializeNameplateSettings(frame)
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)

    if not config.showCastbarIfTarget or BBP.needsUpdate then
        config.showCastbarIfTarget = BetterBlizzPlatesDB.showCastbarIfTarget
        config.hideCastbarWhitelistOn = BetterBlizzPlatesDB.hideCastbarWhitelistOn
        config.onlyShowInterruptableCasts = BetterBlizzPlatesDB.onlyShowInterruptableCasts
        config.hideNpcCastbar = BetterBlizzPlatesDB.hideNpcCastbar
        config.hideCastbarFriendly = BetterBlizzPlatesDB.hideCastbarFriendly
        config.hideCastbarEnemy = BetterBlizzPlatesDB.hideCastbarEnemy
    end

    local castBar = frame.castBar
    local spellName, spellID, notInterruptible, npcID, npcName
    local _

    if UnitCastingInfo(unitToken) then
        spellName, _, _, _, _, _, _, notInterruptible, spellID = UnitCastingInfo(unitToken)
    elseif UnitChannelInfo(unitToken) then
        spellName, _, _, _, _, _, _, notInterruptible, spellID = UnitChannelInfo(unitToken)
    end

    local isCasting = spellName

    local unitGUID = UnitGUID(unitToken)
    if unitGUID then
        npcID = select(6, strsplit("-", unitGUID))
        npcName = info and info.name
    end

    if config.showCastbarIfTarget and info and info.isTarget then
        -- castBar:Show()
        return
    end

    if config.onlyShowInterruptableCasts then
        if notInterruptible then
            castBar:Hide()
            return
        end
    end

    if (config.hideCastbarFriendly and info and info.isFriend) or (config.hideCastbarEnemy and info and not info.isFriend) then
        local hideCastbar = true
        if config.hideCastbarWhitelistOn then
            -- Whitelist logic
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

            if inWhitelist and isCasting then
                hideCastbar = false
            end
        end
        if hideCastbar then
            castBar:Hide()
            return
        end
    end

    if config.hideCastbarWhitelistOn then
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
        if inWhitelist and isCasting then
            -- castBar:Show()
        else
            castBar:Hide()
        end
    else
        -- Check if the NPC is in the blacklist by ID, Name, spell ID, or spell Name (case-insensitive)
        local inList = false
        local hideCastbarList = BetterBlizzPlatesDB.hideCastbarList

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
        if isCasting and not inList then
            -- castBar:Show()
        else
            castBar:Hide()
        end
        if config.hideNpcCastbar then
            if info and not info.isPlayer then
                castBar:Hide()
            end
        end
    end
end

-- Update text and color based on the target
function BBP.UpdateNameplateTargetText(frame, unit)
    if not unit then return end

    if not frame.TargetText then
        frame.TargetText = BBP.OverlayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.TargetText:SetJustifyH("CENTER")
        frame.TargetText:SetParent(frame.castBar)
        frame.TargetText:SetIgnoreParentScale(true)
        -- fix me (make it appear above resource when higher strata resource) bodify
    end

    local isCasting = frame.castBar.casting or frame.castBar.channeling

    frame.TargetText:SetText("")

    if isCasting and UnitExists(unit.."target") and frame.castBar:IsShown() and not frame.hideCastInfo then
        local targetOfTarget = unit.."target"
        local name = UnitName(targetOfTarget)
        local _, class = UnitClass(targetOfTarget)
        local color = RAID_CLASS_COLORS[class]
        local useCustomFont = BetterBlizzPlatesDB.useCustomFont

        frame.TargetText:SetText(name)
        frame.TargetText:SetTextColor(color.r, color.g, color.b)
        frame.TargetText:ClearAllPoints()
        if UnitCanAttack("player", unit) then
            frame.TargetText:SetPoint("TOPRIGHT", frame.castBar, "BOTTOMRIGHT", -4, 0)  -- Set anchor point for enemy
        else
            frame.TargetText:SetPoint("TOP", frame.castBar, "BOTTOM", 0, 0)  -- Set anchor point for friendly
        end
        local npTextSize = BetterBlizzPlatesDB.npTargetTextSize
        if useCustomFont then
            BBP.SetFontBasedOnOption(frame.TargetText, (useCustomFont and (npTextSize or 6)) or (npTextSize or 6))
        else
            local f,s,o = frame.TargetText:GetFont()
            frame.TargetText:SetFont(f, npTextSize or 6,"OUTLINE")
        end
    else
        frame.TargetText:SetText("")
    end
end

function BBP.UpdateCastTimer(frame, unit)
    if not frame.CastTimerFrame then
        frame.CastTimerFrame = CreateFrame("Frame", nil, frame.castBar)
        frame.CastTimer = frame.CastTimerFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
        --nameplate.CastTimer:SetPoint("LEFT", nameplate, "BOTTOMRIGHT", -10, 15)
        frame.CastTimer:SetPoint("LEFT", frame.castBar, "RIGHT", 5, 0)
        local npTextSize = BetterBlizzPlatesDB.npTargetTextSize
        BBP.SetFontBasedOnOption(frame.CastTimer, npTextSize or 12, "OUTLINE")
        frame.CastTimer:SetTextColor(1, 1, 1)
    end
    if BBP.isMidnight then return end

    local name, temp_, temp__, startTime, endTime = UnitCastingInfo(unit)
    if not name then
        name, temp_, temp__, startTime, endTime = UnitChannelInfo(unit)
    end

    if name and endTime and startTime and frame and frame.healthBar and frame.healthBar:IsShown() and not frame.hideCastInfo then
        -- local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization

        -- if enableCastbarCustomization then
        --     BBP.CustomizeCastbar(unit)
        -- end
        frame.CastTimer.endTime = endTime / 1000
        local currentTime = GetTime()
        local timeLeft = frame.CastTimer.endTime - currentTime
        if timeLeft <= 0 then
            frame.CastTimer:SetText("")
            if frame.TargetText then
                frame.TargetText:SetText("")
            end
        else
            frame.CastTimerFrame:Show()
            frame.CastTimer:SetText(string.format("%.1f", timeLeft))
            C_Timer.After(0.05, function()
                BBP.UpdateCastTimer(frame, unit)
                --BBP.HideCastbar(unit) -- this worked well but could pop up short between casts
            end)
        end
    else
        frame.CastTimer:SetText("")
        if frame.TargetText then
            frame.TargetText:SetText("")
        end
    end
end

-- Spellcast events
local castbarEventFrame = CreateFrame("Frame")
castbarEventFrame:SetScript("OnEvent", function(self, event, unitID)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_INTERRUPT" then

        local destUnit = UnitTokenFromGUID(destGUID)
        if string.match(destUnit or "", "nameplate") then
            local nameplate, frame = BBP.GetSafeNameplate(destUnit)
            if frame then
                if sourceName then
                    local name, server = strsplit("-", sourceName)
                    local colorStr = "ffFFFFFF"

                    if C_PlayerInfo.GUIDIsPlayer(sourceGUID) then
                        local localizedClass, englishClass, localizedRace, englishRace, sex, _name, realm = GetPlayerInfoByGUID(sourceGUID)
                        colorStr = RAID_CLASS_COLORS[englishClass].colorStr
                    end
                    frame.castBar.Text:SetText(string.format("|c%s[%s]|r", colorStr, name))
                    local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
                    local castBarTexture = frame.castBar:GetStatusBarTexture()
                    local castHighlighter = BetterBlizzPlatesDB.castBarInterruptHighlighter
                    if castBarTexture and not useCustomCastbarTexture and castHighlighter then
                        castBarTexture:SetDesaturated(false)
                        if not classicFrames then
                            frame.castBar:SetStatusBarColor(1,1,1)
                        end
                    end

                    local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
                    if castbarQuickHide or BetterBlizzPlatesDB.hideCastbar then
                        local nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" and BetterBlizzPlatesDB.nameplateResourceUnderCastbar
                        frame.castBar:Show()

                        if nameplateResourceUnderCastbar and UnitIsUnit(destUnit, "target") then
                            BBP.UpdateNameplateResourcePositionForCasting(nameplate)
                        end

                        C_Timer.After(0.5, function()
                            if not UnitCastingInfo(destUnit) and not UnitChannelInfo(destUnit) then
                                if frame and frame.castBar then
                                    frame.castBar:PlayFadeAnim()
                                    if nameplateResourceUnderCastbar and UnitIsUnit(destUnit, "target") then
                                        BBP.UpdateNameplateResourcePositionForCasting(nameplate)
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- Event handler
local interruptCombatLog
local castbarOnUpdateHooked
function BBP.ToggleSpellCastEventRegistration()
    classicFrames = C_AddOns.IsAddOnLoaded("ClassicFrames")
    if not BetterBlizzPlatesDB.castbarEventsOn then
        if BetterBlizzPlatesDB.showNameplateCastbarTimer or BetterBlizzPlatesDB.showNameplateTargetText or BetterBlizzPlatesDB.enableCastbarCustomization or BetterBlizzPlatesDB.hideCastbar then
            if BetterBlizzPlatesDB.interruptedByIndicator and not interruptCombatLog then
                --castbarEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                interruptCombatLog = true
            end

            BetterBlizzPlatesDB.castbarEventsOn = true
        end
    else
        if BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.interruptedByIndicator and not interruptCombatLog then
            --castbarEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            interruptCombatLog = true
        else
            --castbarEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            interruptCombatLog = false
        end
        if not BetterBlizzPlatesDB.showNameplateCastbarTimer and not BetterBlizzPlatesDB.showNameplateTargetText and not BetterBlizzPlatesDB.enableCastbarCustomization and not BetterBlizzPlatesDB.hideCastbar then
            --castbarEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

            BetterBlizzPlatesDB.castbarEventsOn = false
            interruptCombatLog = false
        end
    end
    if BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.castBarInterruptHighlighter and not castbarOnUpdateHooked then
        hooksecurefunc(CastingBarMixin, "OnUpdate", function(self, event, ...)
            if self.unit and self.unit:find("nameplate") then
                if self:IsForbidden() then return end
                local spellName, spellID, notInterruptible, endTime
                local castStart, castDuration
                local _
                local cast

                if UnitCastingInfo(self.unit) then
                    spellName, _, _, castStart, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
                    castDuration = endTime - castStart
                    cast = true
                elseif UnitChannelInfo(self.unit) then
                    spellName, _, _, castStart, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
                    castDuration = endTime - castStart
                end

                local castBar = self
                local interruptedCastbar = castBar.barType == "interrupted"
                if spellName and not interruptedCastbar and castDuration and not notInterruptible then
                    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
                    if not isFriend then
                        local currentTime = GetTime() -- currentTime is in seconds
                        -- Convert startTime from milliseconds to seconds for these calculations
                        local castStartSeconds = castStart / 1000
                        local castEndSeconds = endTime / 1000
                        local currentCastTime = currentTime - castStartSeconds
                        local timeRemaining = castEndSeconds - currentTime

                        local db = BetterBlizzPlatesDB

                        -- Convert the start and end times from configuration to seconds for comparison
                        local highlightStartTime = db.castBarInterruptHighlighterStartTime
                        local highlightEndTime = db.castBarInterruptHighlighterEndTime

                        -- Check if the current cast time is within the specified start and end times
                        if currentCastTime <= highlightStartTime or timeRemaining <= highlightEndTime then
                            -- Highlight the cast bar
                            local color = db.castBarInterruptHighlighterInterruptRGB
                            if castBarTexture then
                                castBarTexture:SetDesaturated()
                            end
                            castBar:SetStatusBarColor(unpack(color)) -- Color for highlight (e.g., green)
                        else
                            local colorDontInterrupt = db.castBarInterruptHighlighterColorDontInterrupt
                            if colorDontInterrupt then
                                local color = db.castBarInterruptHighlighterDontInterruptRGB
                                if castBarTexture then
                                    castBarTexture:SetDesaturated()
                                end
                                castBar:SetStatusBarColor(unpack(color)) -- Color for no interrupt (e.g., red)
                            else
                                if castBarTexture then
                                    castBarTexture:SetDesaturated(false)
                                end
                                if not classicFrames then
                                    local castBarRecolor = db.castBarRecolor
                                    local useCustomCastbarTexture = db.useCustomCastbarTexture
                                    if castBarRecolor then
                                        if cast then
                                            castBar:SetStatusBarColor(unpack(db.castBarCastColor))
                                        else
                                            castBar:SetStatusBarColor(unpack(db.castBarChanneledColor))
                                        end
                                    elseif useCustomCastbarTexture then
                                        if cast then
                                            castBar:SetStatusBarColor(1,0.843,0.2)
                                        else
                                            castBar:SetStatusBarColor(0,1,0)
                                        end
                                    else
                                        castBar:SetStatusBarColor(1,1,1)
                                    end
                                end
                            end
                        end
                    end
                else
                    if interruptedCastbar then
                        if castBarTexture then
                            castBarTexture:SetDesaturated(false)
                        end
                        if not classicFrames then
                            local db = BetterBlizzPlatesDB
                            local castBarRecolor = db.castBarRecolor
                            local useCustomCastbarTexture = db.useCustomCastbarTexture
                            if castBarRecolor or useCustomCastbarTexture then
                                castBar:SetStatusBarColor(1,0,0)
                            else
                                castBar:SetStatusBarColor(1,1,1)
                            end
                        end
                    end
                end
            end
        end)
        castbarOnUpdateHooked = true
    end
end


-- quickfix for now
function BBP.CastbarOnEvent(frame, event)
    local self = frame.castBar
    local nameplate = frame:GetParent()
    --if self.unit == "player" then return end
    local db = BetterBlizzPlatesDB
    local alwaysHideFriendlyCastbar = db.alwaysHideFriendlyCastbar
    local alwaysHideEnemyCastbar = db.alwaysHideEnemyCastbar
    local hideCastbar = db.hideCastbar
    local enableCastbarCustomization = db.enableCastbarCustomization
    local useCustomCastbarTexture = db.useCustomCastbarTexture
    local showNameplateTargetText = db.showNameplateTargetText
    local showNameplateCastbarTimer = db.showNameplateCastbarTimer

    if db.enableNpNonTargetAlpha and db.enableNpNonTargetAlphaFullAlphaCasting then
        if frame.BetterBlizzPlates then
            BBP.NameplateTargetAlpha(frame)
        end
    end

    

    if frame.hideCastbarOverride then
        frame.castBar:Hide()
        return
    end

    if alwaysHideFriendlyCastbar or alwaysHideEnemyCastbar or BBP.hideFriendlyCastbar then
        local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
        if ((alwaysHideFriendlyCastbar or BBP.hideFriendlyCastbar) and isFriend) or (alwaysHideEnemyCastbar and not isFriend) then
            local alwaysHideFriendlyCastbarShowTarget = db.alwaysHideFriendlyCastbarShowTarget
            local alwaysHideEnemyCastbarShowTarget = db.alwaysHideEnemyCastbarShowTarget
            if (alwaysHideFriendlyCastbarShowTarget and isFriend and UnitIsUnit("target", frame.unit)) or (alwaysHideEnemyCastbarShowTarget and not isFriend and UnitIsUnit("target", frame.unit)) then
                -- go thruugh
            else
                frame.castBar:Hide()
                return
            end
        end
    end

    if showNameplateCastbarTimer then
        BBP.UpdateCastTimer(frame, self.unit)
    end

    if showNameplateTargetText then
        BBP.UpdateNameplateTargetText(frame, self.unit)
    end

    if enableCastbarCustomization then
        if db.castbarAlwaysOnTop then
            frame.castBar:SetParent(BBP.OverlayFrame)
            frame.castBar:SetFrameStrata("HIGH")
        end

        BBP.CustomizeCastbar(frame, self.unit, event)

        if not BBP.UnitTargetCastbarUpdate then
            BBP.UnitTargetCastbarUpdate = CreateFrame("Frame")
            BBP.UnitTargetCastbarUpdate:RegisterEvent("UNIT_TARGET")
            BBP.UnitTargetCastbarUpdate:SetScript("OnEvent", function(_, _, unit)
                if string.match(unit, "arena") then return end
                local np, frame = BBP.GetSafeNameplate(unit)
                if frame and not UnitIsPlayer(unit) then
                    BBP.CustomizeCastbar(frame, unit)
                end
            end)
        end

        if useCustomCastbarTexture and not useCustomCastbarTextureHooked then
            if not self.hooked then
                hooksecurefunc(self, "SetStatusBarTexture", function(self, texture)
                    if self.changing or self:IsForbidden() then return end
                    self.changing = true
                    local textureName = BetterBlizzPlatesDB.customCastbarTexture
                    local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                    --local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
                    --local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)

                    -- if self.barType then
                    --     if self.barType == "uninterruptable" then
                    --         self:SetStatusBarTexture(nonInterruptibleTexturePath)
                    --     else
                    --         self:SetStatusBarTexture(texturePath)
                    --     end
                    -- else
                        self:SetStatusBarTexture(texturePath)
                    --end

                    self.changing = false
                end)

                self:HookScript("OnEvent", function()
                    if self:IsForbidden() then return end
                    --self.changing = true
                    local textureName = BetterBlizzPlatesDB.customCastbarTexture
                    local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                    --local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
                    --local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)

                    -- if self.barType then
                    --     if self.barType == "uninterruptable" then
                    --         self:SetStatusBarTexture(nonInterruptibleTexturePath)
                    --     else
                    --         self:SetStatusBarTexture(texturePath)
                    --     end
                    -- else
                        self:SetStatusBarTexture(texturePath)
                    --end

                    --self.changing = false
                    --end)
                end)

                if self.Flash then
                    self.Flash:HookScript("OnShow", function(self)
                        if self:IsForbidden() then return end
                        self:SetAlpha(0)
                    end)
                end
                local castbar = self
                local borderShield = self.BorderShield

                if self.Icon then
                    -- hooksecurefunc(self.Icon, "SetPoint", function(self)
                    --     if self.changing or self:IsForbidden() then return end
                    --     self.changing = true
                    --     self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos,
                    --         BetterBlizzPlatesDB.castBarIconYPos)
                    --     borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
                    --     self.changing = false
                    -- end)
                end
                self.hooked = true
            end
            useCustomCastbarTextureHooked = true
        end

        if BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts then
            -- if (event == "UNIT_SPELLCAST_EMPOWER_START") then
            --     if self:IsForbidden() then return end
            --     if self.barType == "empowered" or self.barType == "standard" then
            --         self:SetStatusBarTexture("ui-castingbar-filling-standard")
            --     end
            --     self.ChargeTier1:Hide()
            --     self.ChargeTier2:Hide()
            --     self.ChargeTier3:Hide()
            --     if self.ChargeTier4 then
            --         self.ChargeTier4:Hide()
            --     end

            --     local function UpdateSparkPosition(castBar)
            --         local progressPercent = castBar.value / castBar.maxValue
            --         local newX = castBar:GetWidth() * progressPercent
            --         castBar.Spark:SetPoint("CENTER", castBar, "LEFT", newX, 0)
            --     end

            --     if not self.empoweredFix then
            --         self:HookScript("OnUpdate", function(self)
            --             if self:IsForbidden() then return end
            --             if self.barType == "uninterruptable" then
            --                 if self.ChargeTier1 then
            --                     self.Spark:SetAtlas("UI-CastingBar-Pip")
            --                     self.Spark:SetSize(6, 16)
            --                     UpdateSparkPosition(self)
            --                 end
            --             elseif self.barType == "empowered" then
            --                 self.Spark:SetAtlas("UI-CastingBar-Pip")
            --                 self.Spark:SetSize(6, 16)
            --                 UpdateSparkPosition(self)
            --             end
            --         end)
            --         self.empoweredFix = true
            --     end

            --     -- self.StagePip1:Hide()
            --     -- self.StagePip2:Hide()
            --     -- self.StagePip3:Hide()
            -- end
        end

        if not self.hooked then
            local castbar = self
            local borderShield = self.BorderShield

            if self.Icon then
                -- hooksecurefunc(self.Icon, "SetPoint", function(self)
                --     if self.changing or self:IsForbidden() then return end
                --     self.changing = true
                --     self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos,
                --         BetterBlizzPlatesDB.castBarIconYPos)
                --     borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
                --     self.changing = false
                -- end)
            end
            self.hooked = true
        end

        if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
            local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
            --ResetCastbarAfterFadeout(frame, unitID)
            if event == "UNIT_SPELLCAST_INTERRUPTED" then
                local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
                local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
                if (castBarRecolor or useCustomCastbarTexture) and frame.castBar then
                    frame.castBar:SetStatusBarColor(1, 0, 0)
                end
                if BetterBlizzPlatesDB.castBarInterruptHighlighter then
                    if not classicFrames then
                        frame.castBar:SetStatusBarColor(1, 1, 1)
                    end
                end
            end
            if castbarQuickHide then
                if frame.castBar then
                    frame.castBar:Hide()
                    if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
                        --if UnitIsUnit(self.unit, "target") then
                        if UnitIsUnit("target", frame.unit) then
                            BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
                        end
                    end
                end
            end
            if frame.castHiddenName then
                frame.castHiddenName = nil
                CompactUnitFrame_UpdateName(frame)
            end
        end
    end

    if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
        C_Timer.After(0.6, function()
            if frame and frame.unit then
                --if UnitIsUnit(frame.unit, "target") then
                if UnitIsUnit("target", frame.unit) then
                    BBP.UpdateNameplateResourcePositionForCasting(nameplate)
                end
            end
        end)
    end

    -- if hideCastbar then
    --     BBP.HideCastbar(frame, self.unit)
    -- end
end

function BBP.HookCastbarOnEvent(frame)
    if frame.hookedCastbarOnEvent then return end
    frame.castBar:HookScript("OnEvent", function(self, event, ...)
        if frame and not frame:IsForbidden() then
            BBP.CastbarOnEvent(frame, event)
        end
    end)
    BBP.CastbarOnEvent(frame)
    frame.hookedCastbarOnEvent = true
end