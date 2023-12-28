-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

BBP.activeCooldowns = BBP.activeCooldowns or {}

function BBP.ResetNameplateTestAttributes()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = nameplate.UnitFrame
        frame.randomIcon = nil
        frame.isImportant = nil
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
    local xPos = BetterBlizzPlatesDB.totemIndicatorXPos
    local yPos = BetterBlizzPlatesDB.totemIndicatorYPos
    local shiftIconDown = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown
    local anchor = BetterBlizzPlatesDB.totemIndicatorAnchor

    if not frame.totemIndicator then
        local scale = BetterBlizzPlatesDB.totemIndicatorScale
        frame.totemIndicator = CreateFrame("Frame", nil, frame)
        frame.totemIndicator:SetSize(30, 30)
        frame.totemIndicator:SetScale(scale or 1)

        frame.customIcon = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
        frame.customIcon:SetAllPoints(frame.totemIndicator)

        frame.animationGroup = BBP.SetupUnifiedAnimation(frame.totemIndicator)
    end
    frame.totemIndicator:SetSize(size, size)
    frame.totemIndicator:SetScale(scale or 1)
    if shiftIconDown then
        frame.totemIndicator:SetPoint("BOTTOM", frame.healthBar, anchor, xPos, yPos + 4)
    else
        frame.totemIndicator:SetPoint("BOTTOM", frame.name, anchor, xPos, yPos + 0)
    end
end

-- Function to apply totem icons and other attributes
function BBP.ApplyTotemAttributes(frame, iconTexture, duration, color, size, hideIcon, guid)
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
                frame.customCooldown = CreateFrame("Cooldown", nil, frame.totemIndicator, "CooldownFrameTemplate")
                frame.customCooldown:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', 1, -1)
                frame.customCooldown:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', -1, 1)
            end

            local existingCooldown = BBP.activeCooldowns[guid]
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
                    BBP.activeCooldowns[guid] = nil
                end
            else
                -- Set new cooldown
                local startTime = GetTime()
                frame.customCooldown:SetCooldown(startTime, duration)
                frame.customCooldown:SetReverse(true)
                BBP.activeCooldowns[guid] = { startTime = startTime, duration = duration }
            end

            -- Configure cooldown swipe and edge
            if not BetterBlizzPlatesDB.showTotemIndicatorCooldownSwipe then
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

            frame.animationGroup:Play()
        end

        -- Set cooldown text scale
        local cdText = frame.customCooldown and frame.customCooldown:GetRegions()
        if cdText then
            cdText:SetScale(BetterBlizzPlatesDB.totemIndicatorDefaultCooldownTextSize)
        end
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

    -- Decide whether to pick an important or less important totem
    local shouldPickImportant = math.random() < 0.5

    local selectedKey
    if shouldPickImportant then
        selectedKey = importantKeys[math.random(1, #importantKeys)]
    else
        selectedKey = lessImportantKeys[math.random(1, #lessImportantKeys)]
    end

    -- Retrieve the selected NPC data
    local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[selectedKey]

    -- Return the icon, color, importance flag, name, size, and hideIcon status associated with the selected NPC
    return npcData.icon, npcData.color, npcData.important, npcData.name, npcData.size, npcData.hideIcon
end

-- Apply totem icons and color nameplate
function BBP.ApplyTotemIconsAndColorNameplate(frame, unit)
    local guid = UnitGUID(unit)
    local npcID = BBP.GetNPCIDFromGUID(guid)
    local xPos = BetterBlizzPlatesDB.totemIndicatorXPos
    local yPos = BetterBlizzPlatesDB.totemIndicatorYPos
    local totemIndicatorSwappingAnchor = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown and frame.healthBar or frame.name
    local yPosAdjustment = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown and yPos + 4 or yPos
    local testMode = BetterBlizzPlatesDB.totemIndicatorTestMode
    local hideHealthBar = BetterBlizzPlatesDB.totemIndicatorHideHealthBar
    local npcData = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID]
    local showEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
    local size = npcData and npcData.size or 30

    -- Early return if not in test mode and npcData is nil
    if not testMode and not npcData then
        return
    end

    local isEnemy = UnitIsEnemy("player", unit)

    -- Initialize totem components
    BBP.CreateTotemComponents(frame, size)

    -- Test mode
    if testMode then
        BBP.ResetNameplateTestAttributes()

        -- Fetch and store random attributes on the frame if they don't exist
        if not frame.randomIcon or not frame.randomColor or frame.isImportant == nil or not frame.randomName or not frame.randomSize or frame.randomHideIcon == nil then
            frame.randomIcon, frame.randomColor, frame.isImportant, frame.randomName, frame.randomSize, frame.randomHideIcon = BBP.GetRandomTotemAttributes()
        end

        BBP.ApplyTotemAttributes(frame, frame.randomIcon, nil, nil, frame.randomSize, frame.randomHideIcon, guid)
        frame.healthBar:SetStatusBarColor(unpack(frame.randomColor))
        frame.name:SetVertexColor(unpack(frame.randomColor))
        frame.name:SetText(frame.randomName)

        if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
            frame.name:SetText("")
        end

        if frame.isImportant then
            -- Apply glow effect
            if not frame.glowTexture then
                frame.glowTexture = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
                frame.glowTexture:SetBlendMode("ADD")
                frame.glowTexture:SetAtlas("clickcast-highlight-spellbook")
                frame.glowTexture:SetDesaturated(true)
            end

            local offsetMultiplier = 0.41
            local widthOffset = frame.randomSize * offsetMultiplier
            local heightOffset = frame.randomSize * offsetMultiplier

            frame.glowTexture:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', -widthOffset, heightOffset)
            frame.glowTexture:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', widthOffset, -heightOffset)

            frame.glowTexture:SetVertexColor(unpack(frame.randomColor))
            frame.glowTexture:Show()
            frame.animationGroup:Play()
        else
            if frame.animationGroup then
                frame.animationGroup:Stop()
            end
        end
        if hideHealthBar then
            if not UnitIsUnit(unit, "target") then
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
                frame.healthBar:SetAlpha(1)
                if not hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end
    -- Totem Indicator
    elseif npcData then
        if showEnemyOnly and not isEnemy then
            return
        end

        if npcData.color then
            frame.healthBar:SetStatusBarColor(unpack(npcData.color))
            frame.name:SetVertexColor(unpack(npcData.color))
        end

        if npcData.important then
            BBP.ApplyTotemAttributes(frame, npcData.icon, npcData.duration, npcData.color, npcData.size, npcData.hideIcon, guid)
        else
            BBP.ApplyTotemAttributes(frame, npcData.icon, npcData.duration, nil, npcData.size, npcData.hideIcon, guid)
            if frame.animationGroup then
                frame.animationGroup:Stop()
            end
        end
        if hideHealthBar then
            if not UnitIsUnit(unit, "target") then
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                local hideTargetHighlight = BetterBlizzPlatesDB.hideTargetHighlight
                frame.healthBar:SetAlpha(1)
                if not hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end
    else
        if frame.animationGroup then
            frame.animationGroup:Stop()
        end
    end

    if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
        frame.totemIndicator:SetPoint("BOTTOM", totemIndicatorSwappingAnchor, BetterBlizzPlatesDB.totemIndicatorAnchor, xPos, yPosAdjustment)
        frame.name:SetText("")
    else
        frame.totemIndicator:SetPoint("BOTTOM", totemIndicatorSwappingAnchor, BetterBlizzPlatesDB.totemIndicatorAnchor, xPos, yPos)
    end
end