local LSM = LibStub("LibSharedMedia-3.0")

local interruptSpells = {
    1766,  -- Kick (Rogue)
    2139,  -- Counterspell (Mage)
    6552,  -- Pummel (Warrior)
    19647, -- Spell Lock (Warlock)
    47528, -- Mind Freeze (Death Knight)
    57994, -- Wind Shear (Shaman)
    --91802, -- Shambling Rush (Death Knight)
    96231, -- Rebuke (Paladin)
    106839,-- Skull Bash (Feral)
    115781,-- Optical Blast (Warlock)
    116705,-- Spear Hand Strike (Monk)
    132409,-- Spell Lock (Warlock)
    119910,-- Spell Lock (Warlock Pet)
    89766, -- Axe Toss (Warlock Pet)
    171138,-- Shadow Lock (Warlock)
    147362,-- Countershot (Hunter)
    183752,-- Disrupt (Demon Hunter)
    187707,-- Muzzle (Hunter)
    212619,-- Call Felhunter (Warlock)
    --231665,-- Avengers Shield (Paladin)
    351338,-- Quell (Evoker)
    97547, -- Solar Beam
    78675, -- Solar Beam
    15487, -- Silence
    --47482, -- Leap (DK Transform)
}

-- Local variable to store the known interrupt spell ID
local knownInterruptSpellID = nil

-- Function to find and return the interrupt spell the player knows
local function GetInterruptSpell()
    for _, spellID in ipairs(interruptSpells) do
        if IsSpellKnownOrOverridesKnown(spellID) or (UnitExists("pet") and IsSpellKnownOrOverridesKnown(spellID, true)) then
            knownInterruptSpellID = spellID
            return spellID
        end
    end
    knownInterruptSpellID = nil
end
BBP.GetInterruptSpell = GetInterruptSpell

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

-- Recheck interrupt spells when lock resummons/sacrifices pet
local petSummonSpells = {
    [30146] = true,  -- Summon Demonic Tyrant (Demonology)
    [691]    = true,  -- Summon Felhunter (for Spell Lock)
    [108503] = true,  -- Grimoire of Sacrifice
}

local function OnEvent(self, event, unit, _, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if not petSummonSpells[spellID] then return end
    end
    C_Timer.After(0.1, GetInterruptSpell)
end

local interruptSpellUpdate = CreateFrame("Frame")
if select(2, UnitClass("player")) == "WARLOCK" then
    interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end
interruptSpellUpdate:RegisterEvent("TRAIT_CONFIG_UPDATED")
interruptSpellUpdate:RegisterEvent("PLAYER_TALENT_UPDATE")
interruptSpellUpdate:SetScript("OnEvent", OnEvent)

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

    local spellName, spellID, notInterruptible, endTime, empoweredCast
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
            castBar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            BBP.SetupBorderOnFrame(castBar.Icon)
            castBar.Icon:HookScript("OnShow", function()
                for _, border in ipairs(castBar.Icon.borders) do
                    border:Show()
                end
            end)
            castBar.Icon:HookScript("OnHide", function()
                for _, border in ipairs(castBar.Icon.borders) do
                    border:Hide()
                end
            end)
            castBar.BorderShield:HookScript("OnShow", function()
                for _, border in ipairs(castBar.Icon.borders) do
                    border:Hide()
                end
                if not showCastBarIconWhenNoninterruptible then
                    castBar.Icon:Hide()
                end
            end)
            castBar.adjustedIcon = true
        end
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
        spellName, _, _, castStart, endTime, _, notInterruptible, spellID, empoweredCast = UnitChannelInfo(unitToken)
        if empoweredCast then
            casting = true
            channeling= false
        else
            casting = false
            channeling = true
        end
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
                castBar.Background:SetAllPoints(castBar)
                if notInterruptible and BetterBlizzPlatesDB.redBgCastColor then
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

    local useCustomFont = BetterBlizzPlatesDB.useCustomFont
    if useCustomFont then
        BBP.SetFontBasedOnOption(castBar.Text, 12, "OUTLINE")
    else
        local f = castBar.Text:GetFont()
        castBar.Text:SetFont(f,12,"OUTLINE")
    end

    if hideCastbarText then
        local text = castBar.Text:GetText()
        -- First, check if 'text' is not nil and then check its content
        if text and (string.match(text, interruptedText) or string.match(text, "%b[]")) then
            -- If the text contains "Interrupted" or is within square brackets, ensure it's visible
            castBar.Text:SetAlpha(1)
        else
            -- For all other cases, including when 'text' is nil, hide the text
            castBar.Text:SetAlpha(0)
        end
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
            hooksecurefunc(castBar, "Hide", function()
                if frame:IsForbidden() then return end
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

        local r,g,b

        if db.castBarEmphasisSelfColor and UnitIsUnit(unitToken.."target", "player") and not UnitIsPlayer(frame.unit) and not BBP.isInPvP then
            r,g,b = unpack(db.castBarEmphasisSelfColorRGB)
        else
            r,g,b = castEmphasis.entryColors.text.r, castEmphasis.entryColors.text.g, castEmphasis.entryColors.text.b
        end

        if not castBar.oldParent then
            castBar.oldParent = castBar:GetParent()
            castBar:SetParent(BBP.OverlayFrame)
            castBar:SetFrameStrata("HIGH")
        end

        if castBarEmphasisColor and castEmphasis.entryColors then
            if castBarTexture then
                castBarTexture:SetDesaturated(true)
            end
            castBar:SetStatusBarColor(r, g, b)
            castBar.emphasisColored = true
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
                frame.healthBar:SetStatusBarColor(r, g, b)
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
                --for _, interruptSpellIDx in ipairs(interruptSpellIDs) do
                if not knownInterruptSpellID then
                    GetInterruptSpell()
                end
                if knownInterruptSpellID then
                    local start, duration = BBP.TWWGetSpellCooldown(knownInterruptSpellID)
                    local cooldownRemaining = start + duration - GetTime()
                    local castRemaining = (endTime / 1000) - GetTime()
                    local totalCastTime = (endTime / 1000) - (castStart / 1000)

                    if not notInterruptible then
                        if castBar.spark and castBar.spark:IsShown() then
                            castBar.spark:Hide()
                        end
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
                                    if empoweredCast then
                                        sparkPosition = sparkPosition * 0.7 -- ? idk why but on empowered casts it needs to be roughly 30% to the left compared to cast/channel
                                    end
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
                        if castEmphasis.onMeOnly and not UnitIsPlayer(frame.unit) and not BBP.isInPvP then
                            if UnitIsUnit(unitToken.."target", "player") then
                                ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
                                frame.emphasizedCast = castEmphasis
                            end
                        else
                            ApplyCastBarEmphasisSettings(castBar, castEmphasis, castBarTexture)
                            frame.emphasizedCast = castEmphasis
                        end
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
    if not frame.TargetText then
        frame.TargetText = BBP.OverlayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.TargetText:SetJustifyH("CENTER")
        -- fix me (make it appear above resource when higher strata resource) bodify
    end

    local isCasting = UnitCastingInfo(unit) or UnitChannelInfo(unit)

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
            BBP.SetFontBasedOnOption(frame.TargetText, (useCustomFont and (npTextSize or 11)) or (npTextSize or 12))
        else
            local f,s,o = frame.TargetText:GetFont()
            frame.TargetText:SetFont(f,12,"OUTLINE")
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

            if not BBP.UnitTargetCastbarUpdate then
                BBP.UnitTargetCastbarUpdate = CreateFrame("Frame")
                BBP.UnitTargetCastbarUpdate:RegisterEvent("UNIT_TARGET")
                BBP.UnitTargetCastbarUpdate:SetScript("OnEvent", function(_, _, unit)
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