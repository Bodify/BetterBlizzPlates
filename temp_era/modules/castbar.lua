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
local castIconHooked = false
local useCustomCastbarTextureBigHook

local interruptedText = SPELL_FAILED_INTERRUPTED or "Interrupted"

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
local function ResetCastbarAfterFadeout(frame, unitToken)
    -- local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
    -- if not enableCastbarCustomization then return end

    -- if not (frame and frame.CastBar) then return end
    -- if unitToken == "player" then return end

    -- local castBar = frame.CastBar
    -- if castBar:IsForbidden() then return end

    -- C_Timer.After(0.5, function()
    --     if not castBar then return end
    --     --local showCastBarIconWhenNoninterruptible = BetterBlizzPlatesDB.showCastBarIconWhenNoninterruptible
    --     local castBarIconScale = BetterBlizzPlatesDB.castBarIconScale
    --     local castBarHeight = BetterBlizzPlatesDB.castBarHeight
    --     local castBarTextScale = BetterBlizzPlatesDB.castBarTextScale
    --     local castBarEmphasisHealthbarColor = BetterBlizzPlatesDB.castBarEmphasisHealthbarColor

    --     --local borderShieldSize = showCastBarIconWhenNoninterruptible and (castBarIconScale + 0.3) or castBarIconScale

    --     castBar:SetHeight(BetterBlizzPlatesDB.enableCastbarCustomization and BetterBlizzPlatesDB.castBarHeight or (BetterBlizzPlatesDB.classicNameplates and 10 or 16))
    --     castBar.Icon:SetScale(castBarIconScale)
    --     castBar.Spark:SetSize(4, castBarHeight + 5)
    --     castBar.castText:SetScale(castBarTextScale)
    --     -- castBar.BorderShield:SetScale(borderShieldSize)
    --     -- if (not castBar.casting and not castBar.channeling and not castBar.reverseChanneling) then
    --     --     castBar.BorderShield:Hide()
    --     -- end

    --     -- local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
    --     -- local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
    --     -- if (castBarRecolor or useCustomCastbarTexture) and frame.CastBar then
    --     --     frame.CastBar:SetStatusBarColor(1,0,0)
    --     -- end
    --     -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
    --     --     frame.CastBar:SetStatusBarColor(1,1,1)
    --     -- end

    --     if castBarEmphasisHealthbarColor then
    --         if not frame or frame:IsForbidden() then return end
    --         BBP.CompactUnitFrame_UpdateHealthColor(frame)
    --     end
    -- end)
end

-- Cast emphasis
function BBP.CustomizeCastbar(frame, unitToken, event)
    local db = BetterBlizzPlatesDB
    local enableCastbarCustomization = db.enableCastbarCustomization
    if not enableCastbarCustomization then return end
    if unitToken == "player" then return end

    local castBar = frame.CastBar
    if not castBar then return end
    if castBar:IsForbidden() then return end

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
    local castBarChanneledColor = db.castBarChanneledColor
    local useCustomCastbarTexture = db.useCustomCastbarTexture
    local hideCastbarText = db.hideCastbarText

    if not castBarRecolor then
        if castBarTexture then
            castBarTexture:SetDesaturated(false)
        end
    end

    castBar:SetHeight(castBarHeight)

    local spellName, spellID, notInterruptible, endTime
    local casting, channeling
    local castStart, castDuration
    local _

    if frame.castbarEmphasisActive then
        --frame:GetParent():SetParent(BBP.OverlayFrame)
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
        local textureName = db.customCastbarTexture
        local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
        local bgTextureName = db.customCastbarBGTexture
        local bgTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, bgTextureName)
        local changeBgTexture = db.useCustomCastbarBGTexture
        castBar:SetStatusBarTexture(texturePath)
        if castBarTexture then
            castBarTexture:SetDesaturated(true)
            if changeBgTexture and castBar.Background then
                local bgColor = db.castBarBackgroundColor
                castBar.Background:SetDesaturated(true)
                castBar.Background:SetTexture(bgTexture)
                castBar.Background:SetVertexColor(unpack(bgColor))
            end
        end
        if not castBarRecolor then
            castBarTexture:SetDesaturated(true)
            if notInterruptible then
                castBar:SetStatusBarColor(0.4,0.4,0.4)
            elseif casting then
                if not frame.emphasizedCast then
                    castBar:SetStatusBarColor(1, 0.84, 0.20)
                end
            elseif channeling then
                if not frame.emphasizedCast then
                    castBar:SetStatusBarColor(0.48, 1, 0.29)
                end
            end
        end
    end

    if not frame.CastBar.castText then
        frame.CastBar.castText = frame.CastBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.CastBar.castText:SetText("")
        frame.CastBar.castText:SetDrawLayer("OVERLAY", 7)
        frame.CastBar.castText:SetPoint("CENTER", frame.CastBar, "CENTER", 0, db.classicNameplates and 0.5 or 0)
        BBP.SetFontBasedOnOption(frame.CastBar.castText, db.classicNameplates and 8 or 10, "THINOUTLINE")
        frame.CastBar.castText:SetTextColor(1, 1, 1)
        frame.CastBar.castText:SetJustifyH("CENTER") -- Horizontal alignment
        frame.CastBar.castText:SetJustifyV("MIDDLE") -- Vertical alignment
        frame.CastBar.castText:SetWordWrap(false) -- Disable word wrap
        frame.CastBar.castText:SetMaxLines(1) -- Only one line
        -- Set up scripts to update cast text

        frame.CastBar:HookScript("OnShow", function(self)
            BBP.UpdateCastBarText(self)
        end)

        -- frame.CastBar:HookScript("OnHide", function(self)
        --     self.castText:SetText("")
        -- end)
        BBP.UpdateCastBarText(frame.CastBar)
    end
    --frame.CastBar.castText:SetWidth(frame.CastBar:GetWidth() - 20)

    BBP.SetFontBasedOnOption(frame.CastBar.castText, db.classicNameplates and 8 or 10, "THINOUTLINE")
    --BBP.UpdateCastBarText(frame.CastBar)

    --BBP.SetFontBasedOnOption(castBar.castText, 12, "OUTLINE")

    if hideCastbarText then
        local text = castBar.castText:GetText()
        -- First, check if 'text' is not nil and then check its content
        if db.hideCastbarTextInt then
            if not castBar.interruptedBy then
                castBar.castText:SetAlpha(0)
            end
        elseif text and (string.match(text, interruptedText) or string.match(text, "%b[]")) then
            -- If the text contains "Interrupted" or is within square brackets, ensure it's visible
            castBar.castText:SetAlpha(1)
        else
            -- For all other cases, including when 'text' is nil, hide the text
            castBar.castText:SetAlpha(0)
        end
    end

    --castBar.Icon:SetAlpha(castBar:GetEffectiveAlpha()) -- seems not accurate on cata/era

    if db.hideNameDuringCast and (casting or channeling) then
        if not frame.castHiddenName then
            frame.castHiddenName = frame.name:GetAlpha()
        end
        frame.name:SetAlpha(0)
        if frame.specNameText then
            frame.specNameText:SetAlpha(0)
        end
    elseif frame.castHiddenName and (not casting and not channeling) then
        frame.name:SetAlpha(frame.castHiddenName)
        if frame.specNameText then
            frame.specNameText:SetAlpha(frame.castHiddenName)
        end
    end

    if hideCastbarBorderShield then
        castBar.BorderShield:SetTexture(nil)
    end

    -- if castBarDragonflightShield then
    --     castBar.BorderShield:SetTexture(nil)
    --     castBar.BorderShield:SetAtlas("ui-castingbar-shield")
    -- else
    --     castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
    -- end

    castBar.Icon:SetScale(castBarIconScale)
    --castBar.BorderShield:SetScale(borderShieldSize)
    --castBar:SetHeight(castBarHeight)
    castBar.Spark:SetSize(4, castBarHeight) --4 width, 5 height original
    castBar.castText:SetScale(castBarTextScale)

    if notInterruptible then
        --castBar.BorderShield:SetDrawLayer("OVERLAY", 1)
        castBar.Icon:Show()
        castBar.Icon:SetDrawLayer("OVERLAY", 7)
    -- else
    --     if not notInterruptible then
    --         castBar.Icon:Show() --attempt to fix icon randomly not showing (blizz bug)
    --     else
    --         castBar.Icon:Hide()
    --     end
    end

    local function ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
        local castBarEmphasisColor = db.castBarEmphasisColor
        local castBarEmphasisText = db.castBarEmphasisText
        local castBarEmphasisIcon = db.castBarEmphasisIcon
        local castBarEmphasisHeight = db.castBarEmphasisHeight
        local castBarEmphasisSpark = db.castBarEmphasisSpark
        --local castBarEmphasisTexture = db.castBarEmphasisTexture
        local castBarEmphasisHealthbarColor = db.castBarEmphasisHealthbarColor
        local castBarEmphasisTextScale = db.castBarEmphasisTextScale
        local castBarEmphasisIconScale = db.castBarEmphasisIconScale
        local castBarEmphasisHeightValue = db.castBarEmphasisHeightValue
        local castBarEmphasisSparkHeight = db.castBarEmphasisSparkHeight

        frame.castbarEmphasisActive = true

        if castBarEmphasisColor and castEmphasis.entryColors then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            castBar:SetStatusBarColor(castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b)
        end

        if castBarEmphasisText then
            castBar.castText:SetScale(castBarEmphasisTextScale)
        end

        if castBarEmphasisIcon then
            castBar.Icon:SetScale(castBarEmphasisIconScale)
            --castBar.BorderShield:SetScale(castBarEmphasisIconScale - 0.4)
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
        --     local textureName = db.customCastbarTexture
        --     local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
        --     castBarTexture:SetTexture(texturePath)
        -- end
    end

    local enableCastbarEmphasis = db.enableCastbarEmphasis
    local castBarEmphasisOnlyInterruptable = db.castBarEmphasisOnlyInterruptable
    local castEmphasisList = db.castEmphasisList
    local castBarRecolorInterrupt = db.castBarRecolorInterrupt
    local castBarNoInterruptColor = db.castBarNoInterruptColor
    local castBarDelayedInterruptColor = db.castBarDelayedInterruptColor

    if castBarRecolorInterrupt then
        if spellName or spellID then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unitToken)
            if not isFriend then
                for _, interruptSpellIDx in ipairs(interruptSpellIDs) do
                    local start, duration = GetSpellCooldown(interruptSpellIDx)
                    local cooldownRemaining = start + duration - GetTime()
                    local castRemaining = (endTime / 1000) - GetTime()
                    local totalCastTime = (endTime / 1000) - (castStart / 1000)

                    if not notInterruptible then
                        if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
                            if castBarTexture then
                                castBarTexture:SetDesaturated(true)
                            end
                            castBar.noInterruptColor = true
                            castBar:SetStatusBarColor(unpack(castBarNoInterruptColor))
                            castBar.interruptRecolorActive = true
                        elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
                            if castBarTexture then
                                castBarTexture:SetDesaturated(true)
                            end
                            castBar.delayedInterruptColor = true
                            castBar:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
                            castBar.interruptRecolorActive = true

                            if cooldownRemaining < castRemaining then
                                if not castBar.spark then
                                    castBar.spark = castBar:CreateTexture(nil, "OVERLAY")
                                    castBar.spark:SetColorTexture(0, 1, 0, 1) -- Solid green color with full opacity
                                    castBar.spark:SetSize(2, castBar:GetHeight())
                                    --castBar.spark:SetBlendMode("ADD")
                                    --castBar.spark:SetVertexColor(0, 1, 0)
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

                                castBar.spark:SetPoint("CENTER", castBar, "LEFT", sparkPosition, 0)
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
                            castBar.interruptRecolorActive = nil
                            castBar.noInterruptColor = false
                            castBar.delayedInterruptColor = false
                            if not castBarRecolor and not useCustomCastbarTexture then
                                if castBarTexture then
                                    castBarTexture:SetDesaturated(false)
                                end
                                --castBar:SetStatusBarColor(1, 1, 1)
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
                    local isMatch
                    if castEmphasis.id then
                        isMatch = (spellID and castEmphasis.id == spellID)
                    elseif castEmphasis.name then
                        isMatch = (spellName and strlower(castEmphasis.name) == strlower(spellName))
                    end

                    if isMatch then
                        if castEmphasis.onMeOnly and not UnitIsPlayer(frame.unit) and not BBP.isInPvP then
                            if UnitIsUnit(unitToken.."target", "player") then
                                ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
                                frame.emphasizedCast = castEmphasis
                            end
                        else
                            ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
                            frame.emphasizedCast = castEmphasis
                        end
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
    if not frame.CastBar then return end
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

    local castBar = frame.CastBar
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
        --castBar:Show()
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
            frame.CastBar.hideThis = true
            if not frame.hookedHideCastbar then
                hooksecurefunc(frame.CastBar, "Show", function()
                    if frame.CastBar.hideThis and not frame.CastBar:IsProtected() then
                        frame.CastBar:Hide()
                    end
                end)
                frame.hookedHideCastbar = true
            end
            castBar:Hide()
            return
        else
            frame.CastBar.hideThis = false
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
            frame.CastBar.hideThis = false
            --castBar:Show()
        else
            frame.CastBar.hideThis = true
            if not frame.hookedHideCastbar then
                hooksecurefunc(frame.CastBar, "Show", function()
                    if frame.CastBar.hideThis and not frame.CastBar:IsProtected() then
                        frame.CastBar:Hide()
                    end
                end)
                frame.hookedHideCastbar = true
            end
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
            frame.CastBar.hideThis = false
            --castBar:Show()
        else
            frame.CastBar.hideThis = true
            if not frame.hookedHideCastbar then
                hooksecurefunc(frame.CastBar, "Show", function()
                    if frame.CastBar.hideThis and not frame.CastBar:IsProtected() then
                        frame.CastBar:Hide()
                    end
                end)
                frame.hookedHideCastbar = true
            end
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

    if isCasting and UnitExists(unit.."target") and frame.healthBar:IsShown() and not frame.hideCastInfo then
        local targetOfTarget = unit.."target"
        local name = UnitName(targetOfTarget)
        local _, class = UnitClass(targetOfTarget)
        local color = RAID_CLASS_COLORS[class]
        if class == "SHAMAN" then
            -- Specific color override for Shaman
            color = {r = 0.00, g = 0.44, b = 0.87}
        end
        local useCustomFont = BetterBlizzPlatesDB.useCustomFont

        frame.TargetText:SetText(name)
        frame.TargetText:SetTextColor(color.r, color.g, color.b)
        if UnitCanAttack("player", unit) then
            frame.TargetText:SetPoint("TOPRIGHT", frame.CastBar, "BOTTOMRIGHT", 2, -1)  -- Set anchor point for enemy
        else
            frame.TargetText:SetPoint("TOP", frame.CastBar, "BOTTOM", 0, 0)  -- Set anchor point for friendly
        end
        BBP.SetFontBasedOnOption(frame.TargetText, useCustomFont and 8 or 9)
    else
        frame.TargetText:SetText("")
    end
end

function BBP.UpdateCastTimer(frame, unit)
    if not frame.CastTimerFrame then
        frame.CastTimerFrame = CreateFrame("Frame", nil, frame.healthBar)
        frame.CastTimer = frame.CastTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        --nameplate.CastTimer:SetPoint("LEFT", nameplate, "BOTTOMRIGHT", -10, 15)
        local classic = BetterBlizzPlatesDB.classicNameplates
        local yPos = classic and 0.5 or 0
        local xPos = classic and 2 or 1
        frame.CastTimer:SetPoint("LEFT", frame.CastBar, "RIGHT", xPos, yPos)
        BBP.SetFontBasedOnOption(frame.CastTimer, 9, "OUTLINE")
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
-- Spellcast events
local castbarEventFrame = CreateFrame("Frame")
castbarEventFrame:SetScript("OnEvent", function(self, event, unitID)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_INTERRUPT" then
        -- Iterate over all nameplates
        for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
            local frame = nameplate.UnitFrame
            --if frame and UnitName(frame.unit) == destName then
                if frame and UnitGUID(frame.unit) == destGUID then
                if sourceName then
                    local name, server = strsplit("-", sourceName)
                    local colorStr = "ffFFFFFF"

                    if C_PlayerInfo.GUIDIsPlayer(sourceGUID) then
                        local localizedClass, englishClass, localizedRace, englishRace, sex, _name, realm = GetPlayerInfoByGUID(sourceGUID)
                        colorStr = RAID_CLASS_COLORS[englishClass].colorStr
                        if englishClass == "SHAMAN" then
                            -- Specific color override for Shaman
                            colorStr = "ff0070dd"
                        end
                    end
                    local interruptedByName = string.format("|c%s[%s]|r", colorStr, name)
                    frame.CastBar.interruptedBy = interruptedByName
                    frame.CastBar.castText:SetText(interruptedByName)
                    -- local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
                    -- local castBarTexture = frame.CastBar:GetStatusBarTexture()
                    -- local castHighlighter = BetterBlizzPlatesDB.castBarInterruptHighlighter
                    -- if castBarTexture and not useCustomCastbarTexture and castHighlighter and not BetterBlizzPlatesDB.classicNameplates then
                    --     castBarTexture:SetDesaturated(false)
                    --     frame.CastBar:SetStatusBarColor(1,1,1)
                    -- end

                    local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
                    if castbarQuickHide then
                        local nameplateResourceUnderCastbar = BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" and BetterBlizzPlatesDB.nameplateResourceUnderCastbar
                        frame.CastBar:Show()
                        frame.CastBar.castText:Show()

                        if nameplateResourceUnderCastbar then
                            BBP.UpdateNameplateResourcePositionForCasting(nameplate)
                        end

                        -- C_Timer.After(0.5, function()
                        --     if not UnitCastingInfo(destName) and not UnitChannelInfo(destName) then
                        --         if frame and frame.CastBar then
                        --             frame.CastBar:PlayFadeAnim()
                        --         end
                        --     end
                        -- end)
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
        -- hooksecurefunc("CastingBarFrame_OnUpdate", function(self, event, ...)
        --     if self.unit and self.unit:find("nameplate") then
        --         local spellName, spellID, notInterruptible, endTime
        --         local castStart, castDuration
        --         local _
        --         local cast

        --         if UnitCastingInfo(self.unit) then
        --             spellName, _, _, castStart, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
        --             castDuration = endTime - castStart
        --             cast = true
        --         elseif UnitChannelInfo(self.unit) then
        --             spellName, _, _, castStart, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
        --             castDuration = endTime - castStart
        --         end

        --         local castBar = self
        --         local interruptedCastbar = castBar.barType == "interrupted"
        --         if spellName and not interruptedCastbar and castDuration and not notInterruptible then
        --             local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
        --             if not isFriend then
        --                 local currentTime = GetTime() -- currentTime is in seconds
        --                 -- Convert startTime from milliseconds to seconds for these calculations
        --                 local castStartSeconds = castStart / 1000
        --                 local castEndSeconds = endTime / 1000
        --                 local currentCastTime = currentTime - castStartSeconds
        --                 local timeRemaining = castEndSeconds - currentTime
        --                 local db = BetterBlizzPlatesDB

        --                 -- Convert the start and end times from configuration to seconds for comparison
        --                 local highlightStartTime = db.castBarInterruptHighlighterStartTime
        --                 local highlightEndTime = db.castBarInterruptHighlighterEndTime

        --                 -- Check if the current cast time is within the specified start and end times
        --                 if currentCastTime <= highlightStartTime or timeRemaining <= highlightEndTime then
        --                     -- Highlight the cast bar
        --                     local color = db.castBarInterruptHighlighterInterruptRGB
        --                     if castBarTexture then
        --                         castBarTexture:SetDesaturated()
        --                     end
        --                     castBar:SetStatusBarColor(unpack(color)) -- Color for highlight (e.g., green)
        --                 else
        --                     local colorDontInterrupt = db.castBarInterruptHighlighterColorDontInterrupt
        --                     if colorDontInterrupt then
        --                         local color = db.castBarInterruptHighlighterDontInterruptRGB
        --                         if castBarTexture then
        --                             castBarTexture:SetDesaturated()
        --                         end
        --                         castBar:SetStatusBarColor(unpack(color)) -- Color for no interrupt (e.g., red)
        --                     else
        --                         if castBarTexture then
        --                             castBarTexture:SetDesaturated(false)
        --                         end
        --                         local castBarRecolor = db.castBarRecolor
        --                         local useCustomCastbarTexture = db.useCustomCastbarTexture
        --                         if castBarRecolor then
        --                             if cast then
        --                                 castBar:SetStatusBarColor(unpack(db.castBarCastColor))
        --                             else
        --                                 castBar:SetStatusBarColor(unpack(db.castBarChanneledColor))
        --                             end
        --                         elseif useCustomCastbarTexture then
        --                             if cast then
        --                                 castBar:SetStatusBarColor(1,0.843,0.2)
        --                             else
        --                                 castBar:SetStatusBarColor(0,1,0)
        --                             end
        --                         else
        --                             --castBar:SetStatusBarColor(1,1,1)
        --                         end
        --                         --castBar:SetStatusBarColor(1, 1, 1) -- Default color
        --                     end
        --                 end
        --             end
        --         else
        --             if interruptedCastbar then
        --                 if castBarTexture then
        --                     castBarTexture:SetDesaturated(false)
        --                 end
        --                 local db = BetterBlizzPlatesDB
        --                 local castBarRecolor = db.castBarRecolor
        --                 local useCustomCastbarTexture = db.useCustomCastbarTexture
        --                 if castBarRecolor or useCustomCastbarTexture then
        --                     castBar:SetStatusBarColor(1,0,0)
        --                 else
        --                     --castBar:SetStatusBarColor(1,1,1)
        --                 end
        --                 --castBar:SetStatusBarColor(1, 1, 1) -- Reset to default color if interrupted
        --             end
        --         end
        --     end
        -- end)
        castbarOnUpdateHooked = true
    end
end


-- quickfix for now
-- hooksecurefunc("CastingBarFrame_OnEvent", function(self, event, ...)
--     if self.unit and self.unit:find("nameplate") then
--         local nameplate, frame = BBP.GetSafeNameplate(self.unit)
--         if not frame then return end
--         if self.unit == "player" then return end
--         local alwaysHideFriendlyCastbar = BetterBlizzPlatesDB.alwaysHideFriendlyCastbar
--         local alwaysHideEnemyCastbar = BetterBlizzPlatesDB.alwaysHideEnemyCastbar
--         local hideCastbar = BetterBlizzPlatesDB.hideCastbar
--         local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
--         local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
--         local showNameplateTargetText = BetterBlizzPlatesDB.showNameplateTargetText
--         local showNameplateCastbarTimer = BetterBlizzPlatesDB.showNameplateCastbarTimer

--         if frame.hideCastbarOverride then
--             frame.CastBar:Hide()
--             return
--         end

--         if alwaysHideFriendlyCastbar or alwaysHideEnemyCastbar or BBP.hideFriendlyCastbar then
--             local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
--             if ((alwaysHideFriendlyCastbar or BBP.hideFriendlyCastbar) and isFriend) or (alwaysHideEnemyCastbar and not isFriend) then
--                 frame.CastBar:Hide()
--                 return
--             end
--         end

--         local spellName, spellID, notInterruptible, endTime
--         local _

--         if UnitCastingInfo(self.unit) then
--             spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
--         elseif UnitChannelInfo(self.unit) then
--             spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
--         end

--         if frame.CastBar.castText and spellName then
--             frame.CastBar.castText:SetText(spellName)
--         end

--         if showNameplateCastbarTimer then
--             BBP.UpdateCastTimer(frame, self.unit)
--         end

--         if showNameplateTargetText then
--             BBP.UpdateNameplateTargetText(frame, self.unit)
--         end

--         if enableCastbarCustomization then

--             BBP.CustomizeCastbar(frame, self.unit, event)

--             if useCustomCastbarTexture and not useCustomCastbarTextureHooked then
--                 if not self.hooked then
--                     hooksecurefunc(self, "SetStatusBarTexture", function(self, texture)
--                         if self.changing or not self.unit or self:IsForbidden() then return end

--                         local textureName = BetterBlizzPlatesDB.customCastbarTexture
--                         local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
--                         local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
--                         local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)
--                         self.changing = true

--                         --if self.barType then
--                             if self.notInterruptible then
--                                 self:SetStatusBarTexture(nonInterruptibleTexturePath)
--                                 self.OldTextureWas = nonInterruptibleTexturePath
--                             else
--                                 --if self.barType == "standard" then
--                                     self:SetStatusBarTexture(texturePath)
--                                     self.OldTextureWas = texturePath
--                                 --end
--                             end
--                         -- else
--                         --     if self.OldTextureWas then --the castbar sometimes does a flash of the casting texture that was so this has to be re-set here to not flash an old/changed texture
--                         --         self:SetStatusBarTexture(self.OldTextureWas)
--                         --     else
--                         --         self:SetStatusBarTexture(texturePath)
--                         --     end
--                         -- end

--                         self.changing = false
--                     end)

--                     -- if self.Flash then
--                         -- hooksecurefunc(self.Flash, "OnShow", function(self)
--                         --     if self:IsForbidden() then return end
--                         --     self:Hide()
--                         --     self:SetAlpha(0)
--                         -- end)
--                     -- end
--                     -- local castbar = self
--                     -- local borderShield = self.BorderShield

--                     -- if self.Icon then
--                     --     hooksecurefunc(self.Icon, "SetPoint", function(self)
--                     --         if self.changing or self:IsForbidden() then return end
--                     --         self.changing = true
--                     --         self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
--                     --         --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
--                     --         self.changing = false
--                     --     end)
--                     -- end
--                     self.hooked = true
--                 end
--                 useCustomCastbarTextureHooked = true
--             elseif not useCustomCastbarTexture then
--                 if not BetterBlizzPlatesDB.classicNameplates and self.bbpBorderShield then
--                     if not BetterBlizzPlatesDB.castBarRecolor then
--                         frame.CastBar:SetStatusBarColor(1,1,1)
--                     end
--                     local texture
--                     if self.notInterruptible then
--                         texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Uninterruptable"
--                         self.bbpBorderShield:Show()
--                     elseif self.channeling then
--                         texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
--                         self.bbpBorderShield:Hide()
--                     elseif self.interruptedColor then
--                         texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
--                         self.bbpBorderShield:Hide()
--                     else
--                         texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
--                         self.bbpBorderShield:Hide()
--                     end
            
--                     if not self.noInterruptColor and not self.delayedInterruptColor then
--                         --self:SetStatusBarColor(1,1,1)
--                         local spellName, spellID, notInterruptible, endTime
--                         local _
--                         local channel = false
            
--                         if UnitCastingInfo(self.unit) then
--                             spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
--                         elseif UnitChannelInfo(self.unit) then
--                             spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
--                             channel = true
--                         end
            
--                         if spellName then
--                             self.castText:SetText(spellName)
--                             if not self.notInterruptible then
--                                 if channel then
--                                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
--                                 else
--                                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
--                                 end
--                             end
--                         elseif not self.interruptedColor then
--                             --self.castText:SetText("")
--                             if not self.notInterruptible then
--                                 if channel then
--                                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
--                                 else
--                                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
--                                 end
--                             end
--                         end
--                     end
            
--                     if self.castText:GetText() == "Interrupted" then
--                         texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
--                     end
            
--                     self:SetStatusBarTexture(texture)
--                     --self:SetTexture(texture)
--                     self:GetStatusBarTexture():SetDrawLayer("BORDER", 0)  -- Ensure the filling is between frame and background
--                 end
--             end

--             -- if BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts then
--             --     if ( event == "UNIT_SPELLCAST_EMPOWER_START" ) then
--             --         if not self:IsForbidden() then
--             --             if self.barType == "empowered" or self.barType == "standard" then
--             --                 self:SetStatusBarTexture("ui-castingbar-filling-standard")
--             --             end
--             --             self.ChargeTier1:Hide()
--             --             self.ChargeTier2:Hide()
--             --             self.ChargeTier3:Hide()
--             --             if self.ChargeTier4 then
--             --                 self.ChargeTier4:Hide()
--             --             end

--             --             -- self.StagePip1:Hide()
--             --             -- self.StagePip2:Hide()
--             --             -- self.StagePip3:Hide()
--             --         end
--             --     end
--             -- end

--             -- if not self.hooked then
--             --     local castbar = self
--             --     local borderShield = self.BorderShield

--             --     if self.Icon then
--             --         if BetterBlizzPlatesDB.classicNameplates then
--             --             hooksecurefunc(self.Icon, "SetPoint", function(self)
--             --                 if self.changing or self:IsForbidden() then return end
--             --                 self.changing = true
--             --                 self:ClearAllPoints()
--             --                 self:SetPoint("RIGHT", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos-3, BetterBlizzPlatesDB.castBarIconYPos+1)
--             --                 --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
--             --                 self.changing = false
--             --             end)
--             --         else
--             --             hooksecurefunc(self.Icon, "SetPoint", function(self)
--             --                 if self.changing or self:IsForbidden() then return end
--             --                 self.changing = true
--             --                 self:ClearAllPoints()
--             --                 self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
--             --                 --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
--             --                 self.changing = false
--             --             end)
--             --         end
--             --     end
--             --     self.hooked = true
--             -- end
--         else
--             if not BetterBlizzPlatesDB.classicNameplates and self.bbpBorderShield then
--                 frame.CastBar:SetStatusBarColor(1,1,1)
--                 local texture
--                 if self.notInterruptible then
--                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Uninterruptable"
--                     self.bbpBorderShield:Show()
--                 elseif self.channeling then
--                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
--                     self.bbpBorderShield:Hide()
--                 elseif self.interruptedColor then
--                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
--                     self.bbpBorderShield:Hide()
--                 else
--                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
--                     self.bbpBorderShield:Hide()
--                 end

--                 if not self.noInterruptColor and not self.delayedInterruptColor then
--                     --self:SetStatusBarColor(1,1,1)
--                     local spellName, spellID, notInterruptible, endTime
--                     local _
--                     local channel = false

--                     if UnitCastingInfo(self.unit) then
--                         spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
--                     elseif UnitChannelInfo(self.unit) then
--                         spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(self.unit)
--                         channel = true
--                     end

--                     if spellName then
--                         self.castText:SetText(spellName)
--                         if not self.notInterruptible then
--                             if channel then
--                                 texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
--                             else
--                                 texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
--                             end
--                         end
--                     elseif not self.interruptedColor then
--                         --self.castText:SetText("")
--                         if not self.notInterruptible then
--                             if channel then
--                                 texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
--                             else
--                                 texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
--                             end
--                         end
--                     end
--                 end

--                 if self.castText:GetText() == "Interrupted" then
--                     texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
--                 end

--                 self:SetStatusBarTexture(texture)
--                 --self:SetTexture(texture)
--                 self:GetStatusBarTexture():SetDrawLayer("BORDER", 0)  -- Ensure the filling is between frame and background
--             end
--         end

--         --local interruptedCastbar = false

--         if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
--             local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
--             ResetCastbarAfterFadeout(frame, unitID)
--             if event =="UNIT_SPELLCAST_INTERRUPTED" then
--                 frame.CastBar.interruptedColor = true
--                 local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
--                 local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
--                 if (castBarRecolor or useCustomCastbarTexture) and frame.CastBar then
--                     frame.CastBar:SetStatusBarColor(1,0,0)
--                 end
--                 -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
--                 --     frame.CastBar:SetStatusBarColor(1,1,1)
--                 -- end
--                 if frame.CastBar.castText then
--                     --interruptedCastbar = true
--                     frame.CastBar.castText:SetText("Interrupted")
--                 end
--             end
--             --frame.CastBar:SetStatusBarColor(0,0,1)
--             --frame.CastBar.interruptedColor = true
--             -- local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
--             -- local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
--             -- if (castBarRecolor or useCustomCastbarTexture) and frame.CastBar then
--             --     frame.CastBar:SetStatusBarColor(1,0,0)
--             -- end
--             -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
--             --     frame.CastBar:SetStatusBarColor(1,1,1)
--             -- end
--             -- if frame.CastBar.castText then
--             --     frame.CastBar.castText:SetText("Interrupted")
--             -- end
--             if castbarQuickHide then
--                 if frame.CastBar then
--                     frame.CastBar:Hide()
--                     -- if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
--                     --     if UnitIsUnit(self.unit, "target") then
--                     --         BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
--                     --     end
--                     -- end
--                 end
--             end
--         else
--             --frame.CastBar.interruptedColor = false
--         end

--         if event == "UNIT_SPELLCAST_SUCCEEDED" then
--             frame.CastBar.interruptedColor = false
--         end

--         if event == "UNIT_SPELLCAST_START" then
--             frame.CastBar.interruptedBy = false
--         end
--         -- if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
--         --     C_Timer.After(0.6, function()
--         --         if frame and frame.unit then
--         --             if UnitIsUnit(frame.unit, "target") then
--         --                 BBP.UpdateNameplateResourcePositionForCasting(nameplate)
--         --             end
--         --         end
--         --     end)
--         -- end

--         if hideCastbar then
--             BBP.HideCastbar(frame, self.unit)
--         end
--     end
-- end)





-- hooksecurefunc("CastingBarFrame_FinishSpell", function(self, event, ...)
--     if self.unit and self.unit:find("nameplate") then
--         local nameplate, frame = BBP.GetSafeNameplate(self.unit)
--         if not frame then return end
--         frame.CastBar.interruptedColor = false
--         -- if not BetterBlizzPlatesDB.classicNameplates and not BetterBlizzPlatesDB.useCustomCastbarTexture then
--         --     frame.CastBar:SetStatusBarTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard")
--         -- end
--     end
-- end)

function BBP.ColorCastbar(frame)
    local castBarCastColor = BetterBlizzPlatesDB.castBarCastColor
    local castBarNonInterruptibleColor = BetterBlizzPlatesDB.castBarNoninterruptibleColor
    local castBarChanneledColor = BetterBlizzPlatesDB.castBarChanneledColor
    local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
    local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
    local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
    local classic = BetterBlizzPlatesDB.classicNameplates
    local castBar = frame.CastBar
    local castBarTexture = castBar:GetStatusBarTexture()
    if frame.CastBar.emphasizedCast then
        castBar:SetStatusBarColor(frame.CastBar.emphasizedCast.entryColors.text.r, frame.CastBar.emphasizedCast.entryColors.text.g, frame.CastBar.emphasizedCast.entryColors.text.b)
        return
    end
    if not classic then
        castBar:SetStatusBarColor(1,1,1)
    end
    if castBar.notInterruptible then
        if enableCastbarCustomization then
            if castBarRecolor then
                castBar:SetStatusBarColor(unpack(castBarNonInterruptibleColor))
            elseif useCustomCastbarTexture then
                castBar:SetStatusBarColor(0.4,0.4,0.4)
            end
        end
    elseif castBar.channeling then
        if enableCastbarCustomization then
            if castBarRecolor then
                castBar:SetStatusBarColor(unpack(castBarChanneledColor))
            elseif useCustomCastbarTexture then
                if not frame.emphasizedCast then
                    castBar:SetStatusBarColor(0.48, 1, 0.29)
                end
            end
        end
    elseif castBar.interruptedColor then
        if enableCastbarCustomization then
            if useCustomCastbarTexture then
                castBar:SetStatusBarColor(1,0,0)
            else
                if castBarRecolor then
                    if castBarTexture then
                        castBarTexture:SetDesaturated(false)
                    end
                    castBar:SetStatusBarColor(1,1,1)
                end
            end
        end
    else
        if enableCastbarCustomization then
            if castBarRecolor then
                castBar:SetStatusBarColor(unpack(castBarCastColor))
            elseif useCustomCastbarTexture then
                if not frame.emphasizedCast then
                    castBar:SetStatusBarColor(1, 0.84, 0.20)
                end
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit, ...)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    local frame = nameplate and nameplate.UnitFrame
    if frame then
        local alwaysHideFriendlyCastbar = BetterBlizzPlatesDB.alwaysHideFriendlyCastbar
        local alwaysHideEnemyCastbar = BetterBlizzPlatesDB.alwaysHideEnemyCastbar
        local hideCastbar = BetterBlizzPlatesDB.hideCastbar
        local enableCastbarCustomization = BetterBlizzPlatesDB.enableCastbarCustomization
        local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
        local showNameplateTargetText = BetterBlizzPlatesDB.showNameplateTargetText
        local showNameplateCastbarTimer = BetterBlizzPlatesDB.showNameplateCastbarTimer
        local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
        local classic = BetterBlizzPlatesDB.classicNameplates

        if frame.hideCastbarOverride then
            frame.CastBar.hideThis = true
            if not frame.hookedHideCastbar then
                hooksecurefunc(frame.CastBar, "Show", function()
                    if frame.CastBar.hideThis then
                        frame.CastBar:Hide()
                    end
                end)
                frame.hookedHideCastbar = true
            end
            frame.CastBar:Hide()
            return
        end

        if alwaysHideFriendlyCastbar or alwaysHideEnemyCastbar or BBP.hideFriendlyCastbar then
            local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(frame.unit)
            if ((alwaysHideFriendlyCastbar or BBP.hideFriendlyCastbar) and isFriend) or (alwaysHideEnemyCastbar and not isFriend) then
                frame.CastBar.hideThis = true
                if not frame.hookedHideCastbar then
                    hooksecurefunc(frame.CastBar, "Show", function()
                        if frame.CastBar.hideThis and not frame.CastBar:IsProtected() then
                            frame.CastBar:Hide()
                        end
                    end)
                    frame.hookedHideCastbar = true
                end
                frame.CastBar:Hide()
                return
            end
        end

        frame.CastBar.hideThis = false

        local spellName, spellID, notInterruptible, endTime
        local _
        local channel = false

        if UnitCastingInfo(frame.unit) then
            spellName, _, _, _, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(frame.unit)
            frame.CastBar.interruptedColor = false
            frame.CastBar.interruptedBy = nil
        elseif UnitChannelInfo(frame.unit) then
            spellName, _, _, _, endTime, _, notInterruptible, _, spellID = UnitChannelInfo(frame.unit)
            channel = true
            frame.CastBar.interruptedColor = false
            frame.CastBar.interruptedBy = nil
        end

        if frame.CastBar.castText and spellName then
            frame.CastBar.castText:SetText(spellName)
        end

        if showNameplateCastbarTimer then
            BBP.UpdateCastTimer(frame, frame.unit)
        end

        if showNameplateTargetText then
            BBP.UpdateNameplateTargetText(frame, frame.unit)
        end

        if enableCastbarCustomization then

            BBP.CustomizeCastbar(frame, frame.unit, event)

            if useCustomCastbarTexture then
                if not useCustomCastbarTextureHooked then
                    if not frame.hooked then
                        hooksecurefunc(frame.CastBar, "SetStatusBarTexture", function(self, texture)
                            if self.changing or not self.unit or self:IsForbidden() then return end

                            local textureName = BetterBlizzPlatesDB.customCastbarTexture
                            local texturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, textureName)
                            local nonInterruptibleTextureName = BetterBlizzPlatesDB.customCastbarNonInterruptibleTexture
                            local nonInterruptibleTexturePath = LSM:Fetch(LSM.MediaType.STATUSBAR, nonInterruptibleTextureName)
                            self.changing = true

                            --if self.barType then
                                if self.notInterruptible then
                                    self:SetStatusBarTexture(nonInterruptibleTexturePath)
                                    self.OldTextureWas = nonInterruptibleTexturePath
                                else
                                    --if self.barType == "standard" then
                                        self:SetStatusBarTexture(texturePath)
                                        self.OldTextureWas = texturePath
                                    --end
                                end
                            -- else
                            --     if self.OldTextureWas then --the castbar sometimes does a flash of the casting texture that was so this has to be re-set here to not flash an old/changed texture
                            --         self:SetStatusBarTexture(self.OldTextureWas)
                            --     else
                            --         self:SetStatusBarTexture(texturePath)
                            --     end
                            -- end

                            self.changing = false
                        end)

                        -- if self.Flash then
                            -- hooksecurefunc(self.Flash, "OnShow", function(self)
                            --     if self:IsForbidden() then return end
                            --     self:Hide()
                            --     self:SetAlpha(0)
                            -- end)
                        -- end
                        -- local castbar = self
                        -- local borderShield = self.BorderShield

                        -- if self.Icon then
                        --     hooksecurefunc(self.Icon, "SetPoint", function(self)
                        --         if self.changing or self:IsForbidden() then return end
                        --         self.changing = true
                        --         self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
                        --         --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
                        --         self.changing = false
                        --     end)
                        -- end
                        self.hooked = true
                    end
                    useCustomCastbarTextureHooked = true
                end
                if not BetterBlizzPlatesDB.classicNameplates and frame.CastBar.bbpBorderShield then
                    if frame.CastBar.notInterruptible then
                        frame.CastBar.bbpBorderShield:Show()
                    elseif frame.CastBar.channeling then
                        frame.CastBar.bbpBorderShield:Hide()
                    elseif frame.CastBar.interruptedColor then
                        frame.CastBar.bbpBorderShield:Hide()
                    else
                        frame.CastBar.bbpBorderShield:Hide()
                    end
            
                    if not frame.CastBar.noInterruptColor and not frame.CastBar.delayedInterruptColor then
                        --self:SetStatusBarColor(1,1,1)
                        if spellName then
                            frame.CastBar.castText:SetText(spellName)
                        end
                    end
                    --self:SetTexture(texture)
                    frame.CastBar:GetStatusBarTexture():SetDrawLayer("BORDER", 0)  -- Ensure the filling is between frame and background
                end
            elseif not useCustomCastbarTexture then
                if not BetterBlizzPlatesDB.classicNameplates and frame.CastBar.bbpBorderShield then
                    if not BetterBlizzPlatesDB.castBarRecolor then
                        frame.CastBar:SetStatusBarColor(1,1,1)
                    end
                    local texture
                    if frame.CastBar.notInterruptible then
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Uninterruptable"
                        frame.CastBar.bbpBorderShield:Show()
                    elseif frame.CastBar.channeling then
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                        frame.CastBar.bbpBorderShield:Hide()
                    elseif frame.CastBar.interruptedColor then
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
                        frame.CastBar.bbpBorderShield:Hide()
                    else
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                        frame.CastBar.bbpBorderShield:Hide()
                    end
            
                    if not frame.CastBar.noInterruptColor and not frame.CastBar.delayedInterruptColor then
                        --self:SetStatusBarColor(1,1,1)
                        if spellName then
                            frame.CastBar.castText:SetText(spellName)
                            if not frame.CastBar.notInterruptible then
                                if channel then
                                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                                else
                                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                                end
                            end
                        elseif not frame.CastBar.interruptedColor then
                            --self.castText:SetText("")
                            if not frame.CastBar.notInterruptible then
                                if channel then
                                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                                else
                                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                                end
                            end
                        end
                    end
            
                    if frame.CastBar.castText:GetText() == "Interrupted" then
                        texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
                    end
            
                    frame.CastBar:SetStatusBarTexture(texture)
                    --self:SetTexture(texture)
                    frame.CastBar:GetStatusBarTexture():SetDrawLayer("BORDER", 0)  -- Ensure the filling is between frame and background
                end
            end

            -- if BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts then
            --     if ( event == "UNIT_SPELLCAST_EMPOWER_START" ) then
            --         if not self:IsForbidden() then
            --             if self.barType == "empowered" or self.barType == "standard" then
            --                 self:SetStatusBarTexture("ui-castingbar-filling-standard")
            --             end
            --             self.ChargeTier1:Hide()
            --             self.ChargeTier2:Hide()
            --             self.ChargeTier3:Hide()
            --             if self.ChargeTier4 then
            --                 self.ChargeTier4:Hide()
            --             end

            --             -- self.StagePip1:Hide()
            --             -- self.StagePip2:Hide()
            --             -- self.StagePip3:Hide()
            --         end
            --     end
            -- end

            -- if not self.hooked then
            --     local castbar = self
            --     local borderShield = self.BorderShield

            --     if self.Icon then
            --         if BetterBlizzPlatesDB.classicNameplates then
            --             hooksecurefunc(self.Icon, "SetPoint", function(self)
            --                 if self.changing or self:IsForbidden() then return end
            --                 self.changing = true
            --                 self:ClearAllPoints()
            --                 self:SetPoint("RIGHT", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos-3, BetterBlizzPlatesDB.castBarIconYPos+1)
            --                 --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
            --                 self.changing = false
            --             end)
            --         else
            --             hooksecurefunc(self.Icon, "SetPoint", function(self)
            --                 if self.changing or self:IsForbidden() then return end
            --                 self.changing = true
            --                 self:ClearAllPoints()
            --                 self:SetPoint("CENTER", castbar, "LEFT", BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
            --                 --borderShield:SetPoint("CENTER", self, "CENTER", 0, 0)
            --                 self.changing = false
            --             end)
            --         end
            --     end
            --     self.hooked = true
            -- end
        else
            if not BetterBlizzPlatesDB.classicNameplates and frame.CastBar.bbpBorderShield then
                local texture
                if frame.CastBar.notInterruptible then
                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Uninterruptable"
                    frame.CastBar.bbpBorderShield:Show()
                elseif frame.CastBar.channeling then
                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                    frame.CastBar.bbpBorderShield:Hide()
                elseif frame.CastBar.interruptedColor then
                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
                    frame.CastBar.bbpBorderShield:Hide()
                else
                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                    frame.CastBar.bbpBorderShield:Hide()
                end

                if not frame.CastBar.noInterruptColor and not frame.CastBar.delayedInterruptColor then
                    --self:SetStatusBarColor(1,1,1)

                    if spellName then
                        frame.CastBar.castText:SetText(spellName)
                        if not frame.CastBar.notInterruptible then
                            if channel then
                                texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                            else
                                texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                            end
                        end
                    elseif not frame.CastBar.interruptedColor then
                        --self.castText:SetText("")
                        if not frame.CastBar.notInterruptible then
                            if channel then
                                texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Channel"
                            else
                                texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Filling-Standard"
                            end
                        end
                    end
                end

                if frame.CastBar.castText:GetText() == "Interrupted" then
                    texture = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-CastingBar-Interrupted"
                end

                frame.CastBar:SetStatusBarTexture(texture)
                --self:SetTexture(texture)
                frame.CastBar:GetStatusBarTexture():SetDrawLayer("BORDER", 0)  -- Ensure the filling is between frame and background
            end
        end

        --local interruptedCastbar = false

        -- if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        --     local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
        --     ResetCastbarAfterFadeout(frame, unitID)
        --     if event =="UNIT_SPELLCAST_INTERRUPTED" then
        --         -- frame.CastBar.interruptedColor = true
        --         -- local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
        --         -- local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
        --         -- if (castBarRecolor or useCustomCastbarTexture) and frame.CastBar then
        --         --     frame.CastBar:SetStatusBarColor(1,0,0)
        --         -- end
        --         -- -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
        --         -- --     frame.CastBar:SetStatusBarColor(1,1,1)
        --         -- -- end
        --         -- if frame.CastBar.castText then
        --         --     --interruptedCastbar = true
        --         --     frame.CastBar.castText:SetText("Interrupted")
        --         -- end
        --     end
        --     --frame.CastBar:SetStatusBarColor(0,0,1)
        --     --frame.CastBar.interruptedColor = true
        --     -- local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
        --     -- local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
        --     -- if (castBarRecolor or useCustomCastbarTexture) and frame.CastBar then
        --     --     frame.CastBar:SetStatusBarColor(1,0,0)
        --     -- end
        --     -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
        --     --     frame.CastBar:SetStatusBarColor(1,1,1)
        --     -- end
        --     -- if frame.CastBar.castText then
        --     --     frame.CastBar.castText:SetText("Interrupted")
        --     -- end
        --     if castbarQuickHide then
        --         if frame.CastBar then
        --             frame.CastBar:Hide()
        --             -- if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
        --             --     if UnitIsUnit(self.unit, "target") then
        --             --         BBP.UpdateNameplateResourcePositionForCasting(nameplate, true)
        --             --     end
        --             -- end
        --         end
        --     end
        -- else
        --     --frame.CastBar.interruptedColor = false
        -- end

        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            frame.CastBar.interruptedColor = false
        end

        if event == "UNIT_SPELLCAST_START" then
            frame.CastBar.interruptedBy = false
        end
        -- if BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
        --     C_Timer.After(0.6, function()
        --         if frame and frame.unit then
        --             if UnitIsUnit(frame.unit, "target") then
        --                 BBP.UpdateNameplateResourcePositionForCasting(nameplate)
        --             end
        --         end
        --     end)
        -- end
        if not frame.CastBar.hookedCastColor then
            hooksecurefunc(frame.CastBar, "SetStatusBarColor", function(self, texture)
                if self.changing or not self.unit or self:IsForbidden() then return end
                self.changing = true

                BBP.ColorCastbar(frame)

                self.changing = false
            end)
            BBP.ColorCastbar(frame)
            frame.CastBar.hookedCastColor = true
        end

        if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or frame.CastBar.interruptedBy then
            --frame.CastBar.interruptedColor = true
            local castBarRecolor = BetterBlizzPlatesDB.castBarRecolor
            local useCustomCastbarTexture = BetterBlizzPlatesDB.useCustomCastbarTexture
            -- if BetterBlizzPlatesDB.castBarInterruptHighlighter then
            --     frame.CastBar:SetStatusBarColor(1,1,1)
            -- end
            if frame.CastBar.castText then
                --interruptedCastbar = true
                -- if frame.CastBar.interruptedBy then
                --     frame.CastBar.castText:SetText(frame.CastBar.interruptedBy)
                -- else
                    if event == "UNIT_SPELLCAST_INTERRUPTED" then
                        frame.CastBar.emphasizedCast = nil
                        frame.CastBar.interruptedColor = true
                        if (castBarRecolor or useCustomCastbarTexture) and frame.CastBar then
                            frame.CastBar:SetStatusBarColor(1,0,0)
                        end
                        frame.CastBar.castText:SetText(interruptedText or "Interrupted")
                        if not frame.CastBar.interruptedBy then
                            frame.CastBar.interruptedBy = true
                        end
                    -- else
                    --     frame.CastBar.castText:SetText("Just Stopped")
                    end
                --end
            end
            local castbarQuickHide = BetterBlizzPlatesDB.castbarQuickHide
            ResetCastbarAfterFadeout(frame, unitID)
            if castbarQuickHide then
                if frame.CastBar then
                    if frame.CastBar.interruptedBy then
                        frame.CastBar:Show()
                    else
                        frame.CastBar:Hide()
                    end
                end
            end
        end

        if hideCastbar then
            BBP.HideCastbar(frame, frame.unit)
        end
    end
end)
