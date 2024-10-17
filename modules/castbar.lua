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

local useCustomCastbarTextureHooked = false
local classicFrames

local interruptSpellIDs = {}
function BBP.InitializeInterruptSpellID()
    interruptSpellIDs = {}
    for spellID in pairs(interruptList) do
        if IsSpellKnownOrOverridesKnown(spellID) or (UnitExists("pet") and IsSpellKnownOrOverridesKnown(spellID, true)) then
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
recheckInterruptListener:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
recheckInterruptListener:SetScript("OnEvent", OnEvent)

-- Castbar has a fade out animation after UNIT_SPELLCAST_STOP has triggered, reset castbar settings after this fadeout
local function ResetCastbarAfterFadeout(frame, unitToken)
    local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
    if not enableCastbarCustomization then return end

    if not (frame and frame.castBar) then return end
    if unitToken == "player" then return end

    local castBar = frame.castBar
    if castBar:IsForbidden() then return end

    C_Timer.After(0.5, function()
        if not castBar then return end
        local showCastBarIconWhenNoninterruptible = BetterBlizzPlatesDB.showCastBarIconWhenNoninterruptible
        local castBarIconScale = BetterBlizzPlatesDB.castBarIconScale
        local castBarHeight = BetterBlizzPlatesDB.castBarHeight
        local castBarTextScale = BetterBlizzPlatesDB.castBarTextScale
        local castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor

        local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale + 0.3) or castBarIconScale

        -- castBar:SetHeight(castBarHeight)
        -- castBar.Icon:SetScale(castBarIconScale)
        -- castBar.Spark:SetSize(4, castBarHeight + 5)
        -- castBar.Text:SetScale(castBarTextScale)
        -- castBar.BorderShield:SetScale(borderShieldSize)
        -- if (not castBar.casting and not castBar.channeling and not castBar.reverseChanneling) then
        --     castBar.BorderShield:Hide()
        -- end

        -- -- local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
        -- -- local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
        -- -- if (castBarRecolor or useCustomCastbarTexture) and frame.castBar then
        -- --     frame.castBar:SetStatusBarColor(1,0,0)
        -- -- end
        -- -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
        -- --     frame.castBar:SetStatusBarColor(1,1,1)
        -- -- end

        -- if castBarEmphasisHealthbarColor then
        --     if not frame or frame:IsForbidden() then return end
        --     BBP.CompactUnitFrame_UpdateHealthColor(frame)
        -- end
    end)
end

-- Cast emphasis
function BBP.CustomizeCastbar(frame, unitToken, event)
    local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
    if not enableCastbarCustomization then return end
    if unitToken == "player" then return end

    local castBar = frame.castBar
    if not castBar then return end
    if castBar:IsForbidden() then return end

    -- if frame.ogParent then
    --     frame:SetParent(frame.ogParent)
    --     frame.ogParent = nil
    -- end

    local showCastBarIconWhenNoninterruptible = BetterBlizzPlatesDB.showCastBarIconWhenNoninterruptible
    local castBarIconScale = BetterBlizzPlatesDB.castBarIconScale
    local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale + 0.3) or castBarIconScale
    local castBarTexture = castBar:GetStatusBarTexture()
    local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
    local castBarDragonflightShield = BetterBlizzPlatesDB.castBarDragonflightShield
    local castBarHeight = BetterBlizzPlatesDB.castBarHeight
    local castBarTextScale = BetterBlizzPlatesDB.castBarTextScale
    local castBarCastColor = BetterBlizzPlatesDB.castBarCastColor
    local castBarNonInterruptibleColor = BetterBlizzPlatesDB.castBarNoninterruptibleColor
    local castBarChanneledColor = BetterBlizzPlatesDB.castBarChanneledColor
    local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
    local hideCastbarText = BetterBlizzPlatesDB.hideCastbarText
    local hideCastbarBorderShield = BetterBlizzPlatesDB.hideCastbarBorderShield

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

    local spellName, spellID, notInterruptible, endTime
    local casting, channeling
    local castStart, castDuration
    local _

    if frame.castbarEmphasisActive then
        BBP.CompactUnitFrame_UpdateHealthColor(frame)
        castBar:SetHeight(castBarHeight)
        castBar.Icon:SetScale(castBarIconScale)
        castBar.Spark:SetSize(4, castBarHeight + 5)
        castBar.Text:SetScale(castBarTextScale)
        castBar.BorderShield:SetScale(borderShieldSize)
        frame:GetParent():SetParent(WorldFrame)
        frame.castbarEmphasisActive = false
    end

    if UnitCastingInfo(unitToken) then
        casting = true
        spellName, _, _, castStart, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(unitToken)
        castDuration = endTime - castStart
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
    elseif UnitChannelInfo(unitToken) then
        channeling = true
        spellName, _, _, castStart, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(unitToken)
        castDuration = endTime - castStart
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
                if notInterruptible then
                    castBar.Background:SetVertexColor(1,0,0,1)
                else
                    castBar.Background:SetVertexColor(unpack(bgColor))
                end
            end
        end
        if not castBarRecolor then
            castBarTexture:SetDesaturated(true)
            if notInterruptible then
                castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
            elseif casting then
                if not frame.emphasizedCast then
                    castBar:SetStatusBarColor(unpack(castBarCastColor))
                end
            elseif channeling then
                if not frame.emphasizedCast then
                    castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                end
            end
        end
    end

    BBP.SetFontBasedOnOption(castBar.Text, 12, "OUTLINE")

    if hideCastbarText then
        local text = castBar.Text:GetText()
        -- First, check if 'text' is not nil and then check its content
        if text and (string.match(text, "Interrupted") or string.match(text, "%b[]")) then
            -- If the text contains "Interrupted" or is within square brackets, ensure it's visible
            castBar.Text:SetAlpha(1)
        else
            -- For all other cases, including when 'text' is nil, hide the text
            castBar.Text:SetAlpha(0)
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

    if showCastBarIconWhenNoninterruptible and notInterruptible then
        castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
        castBar.Icon:Show()
        castBar.Icon:SetDrawLayer("OVERLAY", 2)
    else
        if (casting or channeling) and not notInterruptible then
            castBar.Icon:Show() --attempt to fix icon randomly not showing (blizz bug)
        else
            castBar.Icon:Hide()
        end
    end

    if castBar.oldParent then
        castBar:SetParent(castBar.oldParent)
        castBar:SetFrameStrata("MEDIUM")
        castBar.oldParent = nil
    end

    local function ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
        local castBarEmphasisColor = BetterBlizzPlatesDB.castBarEmphasisColor
        local castBarEmphasisText = BetterBlizzPlatesDB.castBarEmphasisText
        local castBarEmphasisIcon = BetterBlizzPlatesDB.castBarEmphasisIcon
        local castBarEmphasisHeight = BetterBlizzPlatesDB.castBarEmphasisHeight
        local castBarEmphasisSpark = BetterBlizzPlatesDB.castBarEmphasisSpark
        --local castBarEmphasisTexture = BetterBlizzPlatesDB.castBarEmphasisTexture
        local castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor
        local castBarEmphasisTextScale = BetterBlizzPlatesDB.castBarEmphasisTextScale
        local castBarEmphasisIconScale = BetterBlizzPlatesDB.castBarEmphasisIconScale
        local castBarEmphasisHeightValue = BetterBlizzPlatesDB.castBarEmphasisHeightValue
        local castBarEmphasisSparkHeight = BetterBlizzPlatesDB.castBarEmphasisSparkHeight

        frame.castbarEmphasisActive = true

        if not castBar.oldParent then
            castBar.oldParent = castBar:GetParent()
            castBar:SetParent(BBP.OverlayFrame)
            castBar:SetFrameStrata("HIGH")
        end

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
            if frame then
                frame.healthBar:SetStatusBarColor(castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b)
            end
        end

        -- if castBarEmphasisTexture then
        --     local textureName = BetterBlizzPlatesDB.customCastbarTexture
        --     local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
        --     castBarTexture:SetTexture(texturePath)
        -- end
    end

    local enableCastbarEmphasis = BetterBlizzPlatesDB.enableCastbarEmphasis
    local castBarEmphasisOnlyInterruptable = BetterBlizzPlatesDB.castBarEmphasisOnlyInterruptable
    local castEmphasisList = BetterBlizzPlatesDB.castEmphasisList
    local castBarRecolorInterrupt = BetterBlizzPlatesDB.castBarRecolorInterrupt
    local castBarNoInterruptColor = BetterBlizzPlatesDB.castBarNoInterruptColor
    local castBarDelayedInterruptColor = BetterBlizzPlatesDB.castBarDelayedInterruptColor

    if castBarRecolorInterrupt then
        if spellName or spellID then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitToken)
            if not isFriend then
                for _, interruptSpellIDx in ipairs(interruptSpellIDs) do
                    local start, duration = BBP.TWWGetSpellCooldown(interruptSpellIDx)
                    local cooldownRemaining = start + duration - GetTime()
                    local castRemaining = (endTime / 1000) - GetTime()
                    local totalCastTime = (endTime / 1000) - (castStart / 1000)

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

                            if cooldownRemaining < castRemaining then
                                if not castBar.spark then
                                    castBar.spark = castBar:CreateTexture(nil, "OVERLAY")
                                    castBar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
                                    castBar.spark:SetSize(16, 52)
                                    castBar.spark:SetBlendMode("ADD")
                                    castBar.spark:SetVertexColor(0, 1, 0)
                                end

                                -- Calculate the interrupt percentage
                                local interruptPercent = (totalCastTime - castRemaining + cooldownRemaining) / totalCastTime

                                -- Adjust the spark position based on the percentage, reverse if channeling
                                local sparkPosition
                                if channeling then
                                    -- Channeling: reverse the direction, starting from the right
                                    sparkPosition = (1 - interruptPercent) * castBar:GetWidth()
                                else
                                    -- Casting: normal direction, from left to right
                                    sparkPosition = interruptPercent * castBar:GetWidth()
                                end

                                castBar.spark:SetPoint("CENTER", castBar, "LEFT", sparkPosition, -2)
                                castBar.spark:Show()

                                -- Schedule the color update for when the interrupt will be ready
                                C_Timer.After(cooldownRemaining, function()
                                    if castBar then
                                        if not castBarRecolor and not useCustomCastbarTexture then
                                            if castBarTexture then
                                                castBarTexture:SetDesaturated(false)
                                            end
                                            if not classicFrames then
                                                castBar:SetStatusBarColor(1, 1, 1)
                                            end
                                        else
                                            if casting then
                                                castBar:SetStatusBarColor(unpack(castBarCastColor))
                                            elseif channeling then
                                                castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                                            end
                                        end
                                        -- Hide the spark once the interrupt is ready
                                        if castBar.spark then
                                            castBar.spark:Hide()
                                        end
                                    end
                                end)
                            else
                                if castBar.spark then
                                    castBar.spark:Hide()
                                end
                            end
                        else
                            if not castBarRecolor and not useCustomCastbarTexture then
                                if castBarTexture then
                                    castBarTexture:SetDesaturated(false)
                                end
                                if not classicFrames then
                                    castBar:SetStatusBarColor(1, 1, 1)
                                end
                            else
                                if casting then
                                    castBar:SetStatusBarColor(unpack(castBarCastColor))
                                elseif channeling then
                                    castBar:SetStatusBarColor(unpack(castBarChanneledColor))
                                end
                            end
                            if castBar.spark then
                                castBar.spark:Hide()
                            end
                        end
                    end
                end
            end
        end
    end

    if enableCastbarEmphasis then
        if spellName or spellID then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitToken)
            if not isFriend then
                if castBarEmphasisOnlyInterruptable and notInterruptible then
                    -- Skip emphasizing non-kickable casts when configured to do so
                    return
                end

                for _, castEmphasis in ipairs(castEmphasisList) do
                    if (castEmphasis.name and spellName and strlower(castEmphasis.name) == strlower(spellName)) or
                       (castEmphasis.id and spellID and castEmphasis.id == spellID) then
                        ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
                        frame.emphasizedCast = castEmphasis
                        -- frame:GetParent():SetParent(BBP.OverlayFrame)
                        -- frame.ogParent = frame:GetParent():GetParent()
                        return
                    end
                    frame.emphasizedCast = nil
                end
            end
        end
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
        castBar:Show()
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
            castBar:Show()
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
            castBar:Show()
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
    if not frame.TargetText then
        frame.TargetText = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.TargetText:SetJustifyH("CENTER")
    end

    local isCasting = UnitCastingInfo(unit) or UnitChannelInfo(unit)

    frame.TargetText:SetText("")

    if isCasting and UnitExists(unit.."target") and frame.healthBar:IsShown() and not frame.hideCastInfo then
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
        BBP.SetFontBasedOnOption(frame.TargetText, (useCustomFont and (npTextSize or 11)) or (npTextSize or 12))
    else
        frame.TargetText:SetText("")
    end
end

function BBP.UpdateCastTimer(frame, unit)
    if not frame.CastTimerFrame then
        frame.CastTimerFrame = CreateFrame("Frame", nil, frame.healthBar)
        frame.CastTimer = frame.CastTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        --nameplate.CastTimer:SetPoint("LEFT", nameplate, "BOTTOMRIGHT", -10, 15)
        frame.CastTimer:SetPoint("LEFT", frame.castBar, "RIGHT", 5, 0)
        local npTextSize = BetterBlizzPlatesDB.npTargetTextSize
        BBP.SetFontBasedOnOption(frame.CastTimer, npTextSize or 12, "OUTLINE")
        frame.CastTimer:SetTextColor(1, 1, 1)
    end

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
                    if castbarQuickHide then
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
                castbarEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                interruptCombatLog = true
            end

            BetterBlizzPlatesDB.castbarEventsOn = true
        end
    else
        if BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.interruptedByIndicator and not interruptCombatLog then
            castbarEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            interruptCombatLog = true
        else
            castbarEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            interruptCombatLog = false
        end
        if not BetterBlizzPlatesDB.showNameplateCastbarTimer and not BetterBlizzPlatesDB.showNameplateTargetText and not BetterBlizzPlatesDB.enableCastbarCustomization and not BetterBlizzPlatesDB.hideCastbar then
            castbarEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

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

                if UnitCastingInfo(self.unit) then
                    spellName, _, _, castStart, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
                    castDuration = endTime - castStart
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

                        -- Convert the start and end times from configuration to seconds for comparison
                        local highlightStartTime = BetterBlizzPlatesDB.castBarInterruptHighlighterStartTime
                        local highlightEndTime = BetterBlizzPlatesDB.castBarInterruptHighlighterEndTime

                        -- Check if the current cast time is within the specified start and end times
                        if currentCastTime <= highlightStartTime or timeRemaining <= highlightEndTime then
                            -- Highlight the cast bar
                            local color = BetterBlizzPlatesDB.castBarInterruptHighlighterInterruptRGB
                            if castBarTexture then
                                castBarTexture:SetDesaturated()
                            end
                            castBar:SetStatusBarColor(unpack(color)) -- Color for highlight (e.g., green)
                        else
                            local colorDontInterrupt = BetterBlizzPlatesDB.castBarInterruptHighlighterColorDontInterrupt
                            if colorDontInterrupt then
                                local color = BetterBlizzPlatesDB.castBarInterruptHighlighterDontInterruptRGB
                                if castBarTexture then
                                    castBarTexture:SetDesaturated()
                                end
                                castBar:SetStatusBarColor(unpack(color)) -- Color for no interrupt (e.g., red)
                            else
                                if castBarTexture then
                                    castBarTexture:SetDesaturated(false)
                                end
                                if not classicFrames then
                                    castBar:SetStatusBarColor(1,1,1)
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
                            castBar:SetStatusBarColor(1,1,1)
                        end
                    end
                end
            end
        end)
        castbarOnUpdateHooked = true
    end
end


-- quickfix for now
hooksecurefunc(CastingBarMixin, "OnEvent", function(self, event, ...)
    if self.unit and self.unit:find("nameplate") then
        local nameplate, frame = BBP.GetSafeNameplate(self.unit)
        if not frame then return end
        if self.unit == "player" then return end
        local db = BetterBlizzPlatesDB
        local alwaysHideFriendlyCastbar = db.alwaysHideFriendlyCastbar
        local alwaysHideEnemyCastbar = db.alwaysHideEnemyCastbar
        local hideCastbar = db.hideCastbar
        local enableCastbarCustomization = db.enableCastbarCustomization
        local useCustomCastbarTexture = db.useCustomCastbarTexture
        local showNameplateTargetText = db.showNameplateTargetText
        local showNameplateCastbarTimer = db.showNameplateCastbarTimer

        if frame.hideCastbarOverride then
            frame.castBar:Hide()
            return
        end

        if alwaysHideFriendlyCastbar or alwaysHideEnemyCastbar or BBP.hideFriendlyCastbar then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
            if ((alwaysHideFriendlyCastbar or BBP.hideFriendlyCastbar) and isFriend) or (alwaysHideEnemyCastbar and not isFriend) then
                local alwaysHideFriendlyCastbarShowTarget = db.alwaysHideFriendlyCastbarShowTarget
                local alwaysHideEnemyCastbarShowTarget = db.alwaysHideEnemyCastbarShowTarget
                if (alwaysHideFriendlyCastbarShowTarget and isFriend and UnitIsUnit("target", self.unit)) or (alwaysHideEnemyCastbarShowTarget and not isFriend and UnitIsUnit("target", self.unit)) then
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

            if useCustomCastbarTexture and not useCustomCastbarTextureHooked then
                if not self.hooked then
                    hooksecurefunc(self, "SetStatusBarTexture", function(self, texture)
                        if self.changing or self:IsForbidden() then return end
                        self.changing = true
                        local textureName = BetterBlizzPlatesDB.customCastbarTexture
                        local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                        local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
                        local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)

                        if self.barType then
                            if self.barType == "uninterruptable" then
                                self:SetStatusBarTexture(nonInterruptibleTexturePath)
                            else
                                self:SetStatusBarTexture(texturePath)
                            end
                        else
                            self:SetStatusBarTexture(texturePath)
                        end

                        self.changing = false
                    end)

                    self:HookScript("OnEvent", function()
                        if self:IsForbidden() then return end
                        --self.changing = true
                        local textureName = BetterBlizzPlatesDB.customCastbarTexture
                        local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                        local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
                        local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)

                        if self.barType then
                            if self.barType == "uninterruptable" then
                                self:SetStatusBarTexture(nonInterruptibleTexturePath)
                            else
                                self:SetStatusBarTexture(texturePath)
                            end
                        else
                            self:SetStatusBarTexture(texturePath)
                        end

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
                        hooksecurefunc(self.Icon, "SetPoint", function(self)
                            if self.changing or self:IsForbidden() then return end
                            self.changing = true
                            self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
                            borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
                            self.changing = false
                        end)
                    end
                    self.hooked = true
                end
                useCustomCastbarTextureHooked = true
            end

            if BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts then
                if ( event == "UNIT_SPELLCAST_EMPOWER_START" ) then
                    if self:IsForbidden() then return end
                    if self.barType == "empowered" or self.barType == "standard" then
                        self:SetStatusBarTexture("ui-castingbar-filling-standard")
                    end
                    self.ChargeTier1:Hide()
                    self.ChargeTier2:Hide()
                    self.ChargeTier3:Hide()
                    if self.ChargeTier4 then
                        self.ChargeTier4:Hide()
                    end

                    local function UpdateSparkPosition(castBar)
                        local progressPercent = castBar.value / castBar.maxValue
                        local newX = castBar:GetWidth() * progressPercent
                        castBar.Spark:SetPoint("CENTER", castBar, "LEFT", newX, 0)
                    end

                    if not self.empoweredFix then
                        self:HookScript("OnUpdate", function(self)
                            if self:IsForbidden() then return end
                            if self.barType == "uninterruptable" then
                                if self.ChargeTier1 then
                                    self.Spark:SetAtlas("UI-CastingBar-Pip")
                                    self.Spark:SetSize(6,16)
                                    UpdateSparkPosition(self)
                                end
                            elseif self.barType == "empowered" then
                                self.Spark:SetAtlas("UI-CastingBar-Pip")
                                self.Spark:SetSize(6,16)
                                UpdateSparkPosition(self)
                            end
                        end)
                        self.empoweredFix = true
                    end

                    -- self.StagePip1:Hide()
                    -- self.StagePip2:Hide()
                    -- self.StagePip3:Hide()
                end
            end

            if not self.hooked then
                local castbar = self
                local borderShield = self.BorderShield

                if self.Icon then
                    hooksecurefunc(self.Icon, "SetPoint", function(self)
                        if self.changing or self:IsForbidden() then return end
                        self.changing = true
                        self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
                        borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
                        self.changing = false
                    end)
                end
                self.hooked = true
            end

            if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
                local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
                --ResetCastbarAfterFadeout(frame, unitID)
                if event =="UNIT_SPELLCAST_INTERRUPTED" then
                    local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
                    local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
                    if (castBarRecolor or useCustomCastbarTexture) and frame.castBar then
                        frame.castBar:SetStatusBarColor(1,0,0)
                    end
                    if BetterBlizzPlatesDB.castBarInterruptHighlighter then
                        if not classicFrames then
                            frame.castBar:SetStatusBarColor(1,1,1)
                        end
                    end
                end
                if castbarQuickHide then
                    if frame.castBar then
                        frame.castBar:Hide()
                        if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
                            if UnitIsUnit(self.unit, "target") then
                                BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
                            end
                        end
                    end
                end
            end
        end

        if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
            C_Timer.After(0.6, function()
                if frame and frame.unit then
                    if UnitIsUnit(frame.unit, "target") then
                        BBP.UpdateNameplateResourcePositionForCasting(nameplate)
                    end
                end
            end)
        end

        if hideCastbar then
            BBP.HideCastbar(frame, self.unit)
        end
    end
end)