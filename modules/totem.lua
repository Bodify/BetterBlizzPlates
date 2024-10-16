local activeCooldowns = {}

local playerClass = select(2, UnitClass("player"))

local resourceFrames = {
    ["WARLOCK"] = ClassNameplateBarWarlockFrame,
    ["DEATHKNIGHT"] = DeathKnightResourceOverlayFrame,
    ["PALADIN"] = ClassNameplateBarPaladinFrame,
    ["MONK"] = ClassNameplateBarWindwalkerMonkFrame,
    ["ROGUE"] = ClassNameplateBarRogueFrame,
    ["MAGE"] = ClassNameplateBarMageFrame,
    ["DRUID"] = ClassNameplateBarFeralDruidFrame,
}

local function SetBarWidth(frame, width, useOffsets)
    frame.HealthBarsContainer:ClearPoint("RIGHT")
    frame.HealthBarsContainer:ClearPoint("LEFT")
    frame.castBar:ClearPoint("RIGHT")
    frame.castBar:ClearPoint("LEFT")

    if useOffsets then
        -- Use the +12 and -12 offset for npcData
        frame.HealthBarsContainer:SetPoint("LEFT", frame, "LEFT", -width + 12, 0)
        frame.HealthBarsContainer:SetPoint("RIGHT", frame, "RIGHT", width - 12, 0)

        frame.castBar:SetPoint("LEFT", frame, "LEFT", -width + 12, 0)
        frame.castBar:SetPoint("RIGHT", frame, "RIGHT", width - 12, 0)
    else
        -- Default behavior without offsets
        frame.HealthBarsContainer:SetPoint("LEFT", frame, "LEFT", 50, 0)
        frame.HealthBarsContainer:SetPoint("RIGHT", frame, "RIGHT", -50, 0)

        frame.castBar:SetPoint("LEFT", frame, "LEFT", 50, 0)
        frame.castBar:SetPoint("RIGHT", frame, "RIGHT", -50, 0)
    end
end

function BBP.ResetNameplateTestAttributes()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        local config = frame.BetterBlizzPlates.config
        config.randomTotemIcon = nil
        config.totemIsImportant = nil
        config.randomTotemIconOnly = nil
        config.randomTotemHideHp = nil
    end
end

-- Shared function to set up animations
function BBP.SetupUnifiedAnimation(frameWithAnimations)
    local animationGroup = frameWithAnimations:CreateAnimationGroup()

    local grow = animationGroup:CreateAnimation("Scale")
    grow:SetOrder(1)
    grow:SetScale(1.1, 1.1)
    grow:SetDuration(0.5)

    local shrink = animationGroup:CreateAnimation("Scale")
    shrink:SetOrder(2)
    shrink:SetScale(0.9091, 0.9091)
    shrink:SetDuration(0.5)

    animationGroup:SetLooping("REPEAT")

    return animationGroup
end

-- Function to create the necessary components for the totem indicator
function BBP.CreateTotemComponents(frame, size)
    local config = frame.BetterBlizzPlates.config
    if not frame.totemIndicator then
        frame.totemIndicator = CreateFrame("Frame", nil, frame)
        frame.totemIndicator:SetSize(30, 30)
        frame.totemIndicator:SetScale(config.totemIndicatorScale or 1)
        frame.totemIndicator:SetFrameStrata("HIGH")

        frame.customIcon = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
        frame.customIcon:SetAllPoints(frame.totemIndicator)
        --frame.totemIndicator:SetParent(frame)

        frame.animationGroup = BBP.SetupUnifiedAnimation(frame.totemIndicator)
    end
    frame.totemIndicator:SetSize(size, size)
    frame.totemIndicator:SetScale(config.totemIndicatorScale or 1)
    local totemIndicatorSwappingAnchor
    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = frame.healthBar
    else
        if config.totemIndicatorAnchor == "TOP" then
            totemIndicatorSwappingAnchor = frame.name
        else
            totemIndicatorSwappingAnchor = frame.healthBar
        end
    end
    frame.totemIndicator:ClearAllPoints()
    if config.totemIndicatorHideNameAndShiftIconDown then
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), frame.healthBar, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos + 4)
    elseif config.nameplateResourceOnTarget == "1" and UnitIsUnit(frame.unit, "target") and not BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
        local resourceFrame = frame:GetParent().driverFrame.classNamePlateMechanicFrame
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), resourceFrame or (config.totemIndicatorHideNameAndShiftIconDown and frame.healthBar) or totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    else
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), (config.totemIndicatorHideNameAndShiftIconDown and frame.healthBar) or totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    end
end

-- Function to apply totem icons and other attributes
function BBP.ApplyTotemAttributes(frame, iconTexture, duration, color, size, hideIcon, guid)
    local config = frame.BetterBlizzPlates.config
    BBP.CreateTotemComponents(frame, size)

    -- Only apply the following if hideIcon is false
    if not hideIcon then
        -- Set icon texture
        if iconTexture then
            frame.customIcon:SetTexture(iconTexture)
            frame.customIcon:Show()
        end

        -- Set cooldown if provided
        if duration then
            if not frame.customCooldown then
                frame.customCooldown = CreateFrame("Cooldown", "totemIndicator", frame.totemIndicator, "CooldownFrameTemplate")
                frame.customCooldown:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', 1, -1)
                frame.customCooldown:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', -1, 1)
            end

            local existingCooldown = activeCooldowns[guid]
            if existingCooldown then
                -- Update the cooldown with the remaining time
                local currentTime = GetTime()
                local elapsed = currentTime - existingCooldown.startTime
                local remaining = existingCooldown.duration - elapsed
                if remaining > 0 then
                    frame.customCooldown:SetCooldown(currentTime - elapsed, existingCooldown.duration)
                else
                    -- Cooldown has expired
                    frame.customIcon:Hide()
                    if frame.glowTexture then frame.glowTexture:Hide() end
                    activeCooldowns[guid] = nil
                end
            else
                -- Set new cooldown
                local startTime = GetTime()
                frame.customCooldown:SetCooldown(startTime, duration)
                frame.customCooldown:SetReverse(true)
                activeCooldowns[guid] = { startTime = startTime, duration = duration }
            end

            -- Configure cooldown swipe and edge
            if not config.showTotemIndicatorCooldownSwipe then
                frame.customCooldown:SetDrawSwipe(false)
                frame.customCooldown:SetDrawEdge(false)
            end
        end

        -- Apply glow effect if color is provided
        if color then
            local offsetMultiplier = 0.41
            local widthOffset = size * offsetMultiplier
            local heightOffset = size * offsetMultiplier

            if not frame.glowTexture then
                frame.glowTexture = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
                frame.glowTexture:SetBlendMode("ADD")
                frame.glowTexture:SetAtlas("clickcast-highlight-spellbook")
                frame.glowTexture:SetDesaturated(true)
            end

            frame.glowTexture:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', -widthOffset, heightOffset)
            frame.glowTexture:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', widthOffset, -heightOffset)
            frame.glowTexture:SetVertexColor(unpack(color))
            frame.glowTexture:Show()

            if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
                frame.animationGroup:Play()
            end
        end

        -- Set cooldown text scale
        --local displayCdText = BetterBlizzPlatesDB.totemIndicatorDisplayCdText
        --if displayCdText then
            if frame.customCooldown then
                local cdText = frame.customCooldown:GetRegions()
                if cdText then
                    --frame.customCooldown:SetHideCountdownNumbers(false)
                    cdText:SetScale(config.totemIndicatorDefaultCooldownTextSize)
                end
            end
        --end
    else
        -- If hideIcon is true, ensure icon, cooldown, and glow are not displayed
        if frame.customIcon then frame.customIcon:Hide() end
        if frame.customCooldown then frame.customCooldown:Hide() end
        if frame.glowTexture then frame.glowTexture:Hide() end
    end
end

-- Gets random totem icon for totem feature tester
function BBP.GetRandomTotemAttributes()
    -- Convert NPC list keys into two tables: important and less important
    local importantKeys = {}
    local lessImportantKeys = {}
    for key, value in pairs(BetterBlizzPlatesDB.totemIndicatorNpcList) do
        if value.important then
            table.insert(importantKeys, key)
        else
            table.insert(lessImportantKeys, key)
        end
    end

    local selectedKey
    if #importantKeys > 0 or #lessImportantKeys > 0 then
        local shouldPickImportant = math.random() < 0.5
        if shouldPickImportant and #importantKeys > 0 then
            selectedKey = importantKeys[math.random(1, #importantKeys)]
        elseif #lessImportantKeys > 0 then
            selectedKey = lessImportantKeys[math.random(1, #lessImportantKeys)]
        end
    end

    if selectedKey then
        local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[selectedKey]
        return npcData.icon, npcData.color, npcData.important, npcData.name, npcData.size, npcData.hideIcon, npcData.iconOnly, npcData.hideHp
    else
        -- Return a dummy set of attributes
        return "Interface\\Icons\\inv_misc_questionmark", -- Dummy icon
               {1, 0, 0}, -- Dummy color (red)
               false, -- Not important
               "Dummy NPC", -- Dummy name
               30, -- Dummy size
               true -- Show icon
    end
end

local cc = 0
-- Apply totem icons and color nameplate
function BBP.ApplyTotemIconsAndColorNameplate(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if frame.bbfBigDebuffsAlpha and frame.BigDebuffs then
        frame.bbfBigDebuffsAlpha = false
        frame.BigDebuffs:SetAlpha(1)
    end

    if info.isSelf then return end

    if not config.totemIndicatorInitialized or BBP.needsUpdate then
        config.totemIndicatorXPos = BetterBlizzPlatesDB.totemIndicatorXPos
        config.totemIndicatorYPos = BetterBlizzPlatesDB.totemIndicatorYPos

        config.totemIndicatorHideNameAndShiftIconDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
        config.totemIndicatorTestMode = BetterBlizzPlatesDB.totemIndicatorTestMode
        config.totemIndicatorHideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar
        config.totemIndicatorEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
        config.hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
        config.totemIndicatorAnchor = BetterBlizzPlatesDB.totemIndicatorAnchor
        config.showTotemIndicatorCooldownSwipe = BetterBlizzPlatesDB.showTotemIndicatorCooldownSwipe
        config.totemIndicatorScale = BetterBlizzPlatesDB.totemIndicatorScale
        config.totemIndicatorTestMode = BetterBlizzPlatesDB.totemIndicatorTestMode
        config.totemIndicatorDefaultCooldownTextSize = BetterBlizzPlatesDB.totemIndicatorDefaultCooldownTextSize
        config.totemIndicatorColorHealthBar = BetterBlizzPlatesDB.totemIndicatorColorHealthBar
        config.totemIndicatorColorName = BetterBlizzPlatesDB.totemIndicatorColorName
        config.totemIndicatorHideAuras = BetterBlizzPlatesDB.totemIndicatorHideAuras
        config.totemIndicatorWidthEnabled = BetterBlizzPlatesDB.totemIndicatorWidthEnabled

        config.totemIndicatorInitialized = true
    end


    local guid = info.unitGUID
    local npcID = BBP.GetNPCIDFromGUID(guid) --mby need fresh guid
    local totemIndicatorSwappingAnchor

    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = frame.healthBar
    else
        if config.totemIndicatorAnchor == "TOP" then
            totemIndicatorSwappingAnchor = frame.name
        else
            totemIndicatorSwappingAnchor = frame.healthBar
        end
    end

    local yPosAdjustment = config.totemIndicatorHideNameAndShiftIconDown and config.totemIndicatorYPos + 4 or config.totemIndicatorYPos
    local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID]
    local size = npcData and npcData.size or 30

    -- Early return if not in test mode and npcData is nil
    if not config.totemIndicatorTestMode and not npcData then
        config.totemColorRGB = nil
        return
    end

    -- Initialize totem components
    BBP.CreateTotemComponents(frame, size)

    -- Test mode
    if config.totemIndicatorTestMode then
        BBP.ResetNameplateTestAttributes()

        -- Fetch and store random attributes on the frame if they don't exist
        if not config.randomTotemIcon or not config.randomTotemColor or config.totemIsImportant == nil or not config.randomTotemName or not config.randomTotemSize or config.randomHideTotemIcon == nil then
            config.randomTotemIcon, config.randomTotemColor, config.totemIsImportant, config.randomTotemName, config.randomTotemSize, config.randomHideTotemIcon, config.randomTotemIconOnly, config.randomTotemHideHp = BBP.GetRandomTotemAttributes()
        end

        BBP.ApplyTotemAttributes(frame, config.randomTotemIcon, nil, nil, config.randomTotemSize, config.randomHideTotemIcon, guid)
        frame.healthBar:SetStatusBarColor(unpack(config.randomTotemColor))
        frame.name:SetVertexColor(unpack(config.randomTotemColor))
        frame.name:SetText(config.randomTotemName)

        if config.totemIndicatorHideNameAndShiftIconDown then
            frame.name:SetText("")
        end

        if config.totemIndicatorHideAuras then
            frame.BuffFrame:SetAlpha(0)
        end

        if config.totemIsImportant then
            -- Apply glow effect
            if not frame.glowTexture then
                frame.glowTexture = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
                frame.glowTexture:SetBlendMode("ADD")
                frame.glowTexture:SetAtlas("clickcast-highlight-spellbook")
                frame.glowTexture:SetDesaturated(true)
            end

            local offsetMultiplier = 0.41
            local widthOffset = config.randomTotemSize * offsetMultiplier
            local heightOffset = config.randomTotemSize * offsetMultiplier

            frame.glowTexture:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', -widthOffset, heightOffset)
            frame.glowTexture:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', widthOffset, -heightOffset)

            frame.glowTexture:SetVertexColor(unpack(config.randomTotemColor))
            frame.glowTexture:Show()
            if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
                frame.animationGroup:Play()
            end
        else
            if frame.animationGroup then
                frame.animationGroup:Stop()
            end
            if frame.glowTexture then
                frame.glowTexture:Hide()
            end
        end
        if config.totemIndicatorHideHealthBar or config.randomTotemHideHp or config.randomTotemIconOnly then
            if not info.isTarget then
                frame.HealthBarsContainer:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                frame.HealthBarsContainer:SetAlpha(1)
                if not config.hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end
    -- Totem Indicator
    elseif npcData then
        config.randomTotemColor = nil
        if config.totemIndicatorEnemyOnly and info.isFriend then
            return
        end

        if config.totemIndicatorHideAuras then
            frame.BuffFrame:SetAlpha(0)
        end

        if npcData.color then
            config.totemColorRGB = npcData.color

            if config.totemIndicatorColorHealthBar then
                frame.healthBar:SetStatusBarColor(unpack(npcData.color))
            end
            if config.totemIndicatorColorName then
                frame.name:SetVertexColor(unpack(npcData.color))
            end
        else
            config.totemColorRGB = nil
        end

        if npcData.important then
            BBP.ApplyTotemAttributes(frame, npcData.icon, npcData.duration, npcData.color, npcData.size, npcData.hideIcon, guid)
        else
            BBP.ApplyTotemAttributes(frame, npcData.icon, npcData.duration, nil, npcData.size, npcData.hideIcon, guid)
            if frame.animationGroup then
                frame.animationGroup:Stop()
            end
        end
        if config.totemIndicatorHideHealthBar or npcData.hideHp or npcData.iconOnly then
            if frame.BigDebuffs then
                frame.BigDebuffs:SetAlpha(0)
                frame.bbfBigDebuffsAlpha = true
            end
            if npcData.iconOnly then
                frame.HealthBarsContainer:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                if not info.isTarget then
                    frame.HealthBarsContainer:SetAlpha(0)
                    frame.selectionHighlight:SetAlpha(0)
                else
                    frame.HealthBarsContainer:SetAlpha(1)
                    if not config.hideTargetHighlight then
                        frame.selectionHighlight:SetAlpha(0.22)
                    end
                end
            end
        elseif config.totemIndicatorWidthEnabled then
            if npcData.widthOn and npcData.hpWidth then
                if not frame.bbpWidthHook then
                    hooksecurefunc(frame.HealthBarsContainer, "SetHeight", function(self)
                        if self:IsProtected() or not frame.unit then return end
                        if UnitIsPlayer(frame.unit) then return end
                        local db = BetterBlizzPlatesDB

                        if db.totemIndicator then
                            local npcID = BBP.GetNPCIDFromGUID(UnitGUID(frame.unit))
                            local npcData = db.totemIndicatorNpcList[npcID]

                            if npcData then
                                if db.totemIndicatorWidthEnabled then
                                    if npcData.widthOn and npcData.hpWidth then
                                        SetBarWidth(frame, npcData.hpWidth, true)
                                    end
                                end
                            elseif db.smallPetsInPvP and (UnitIsOtherPlayersPet(frame.unit) or BBP.isInPvP) then
                                SetBarWidth(frame, 50, false)
                            end
                        elseif UnitIsOtherPlayersPet(frame.unit) or BBP.isInPvP then
                            SetBarWidth(frame, 50, false)
                        end
                    end)
                    frame.bbpWidthHook = true
                end
                SetBarWidth(frame, npcData.hpWidth, true)
            end
        end
    else
        config.totemColorRGB = nil
        if frame.animationGroup then
            frame.animationGroup:Stop()
        end
    end

    frame.totemIndicator:ClearAllPoints()
    local iconOnlyMode = (npcData and npcData.iconOnly or config.randomTotemIconOnly)
    if config.totemIndicatorHideNameAndShiftIconDown or iconOnlyMode then
        if iconOnlyMode then
            frame.totemIndicator:SetPoint("CENTER", frame, "CENTER", config.totemIndicatorXPos, config.totemIndicatorYPos)
            frame.name:SetText("")
        else
            frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, yPosAdjustment)
            frame.name:SetText("")
        end
    elseif config.nameplateResourceOnTarget == "1"  and UnitIsUnit(frame.unit, "target") and not BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
        local resourceFrame = resourceFrames[playerClass]
        if not resourceFrame or resourceFrame:IsForbidden() then return end
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), resourceFrame or totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    else
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    end
end