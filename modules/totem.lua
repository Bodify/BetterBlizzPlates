-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- List of NPCs and their associated icons and durations
BBP.npcList = {
    [59764] =   { name = "Healing Tide Totem", icon = GetSpellTexture(108280),              hideIcon = false, size = 30, duration = 10.5, color = {0, 1, 0.39}, important = true },
    [5925] =    { name = "Grounding Totem", icon = GetSpellTexture(204336),                 hideIcon = false, size = 30, duration = 3.5,  color = {1, 0, 1}, important = true },
    [53006] =   { name = "Spirit Link Totem", icon = GetSpellTexture(98008),                hideIcon = false, size = 30, duration = 6,  color = {0, 1, 0.78}, important = true },
    [5913] =    { name = "Tremor Totem", icon = GetSpellTexture(8143),                      hideIcon = false, size = 30, duration = 10, color = {0.49, 0.9, 0.08}, important = true },
    [104818] =  { name = "Ancestral Protection Totem", icon = GetSpellTexture(207399),      hideIcon = false, size = 30, duration = 30, color = {0, 1, 0.78}, important = true },
    [119052] =  { name = "War Banner", icon = GetSpellTexture(236320),                      hideIcon = false, size = 30, duration = 15, color = {1, 0, 1}, important = true },
    [61245] =   { name = "Capacitor Totem", icon = GetSpellTexture(192058),                 hideIcon = false, size = 30, duration = 2,  color = {1, 0.69, 0}, important = true },
    [105451] =  { name = "Counterstrike Totem", icon = GetSpellTexture(204331),             hideIcon = false, size = 30, duration = 15, color = {1, 0.27, 0.59}, important = true },
    [179193] =  { name = "Fel Obelisk", icon = GetSpellTexture(353601),                     hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
    [101398] =  { name = "Psyfiend", icon = GetSpellTexture(199824),                        hideIcon = false, size = 30, duration = 15, color = {0.49, 0, 1}, important = true },
    [100943] =  { name = "Earthen Wall Totem", icon = GetSpellTexture(198838),              hideIcon = false, size = 30, duration = 15, color = {0.78, 0.49, 0.35}, important = true },
    [107100] =  { name = "Observer", icon = GetSpellTexture(112869),                        hideIcon = false, size = 30, duration = 20, color = {1, 0.69, 0}, important = true },
    [135002] =  { name = "Tyrant", icon = GetSpellTexture(265187),                          hideIcon = false, size = 30, duration = 15, color = {1, 0.69, 0}, important = true },
    [114565] =  { name = "Guardian of the Forgotten Queen", icon = GetSpellTexture(228049), hideIcon = false, size = 30, duration = 10, color = {1, 0, 1}, important = true },
    -- Less important
    [3527] =    { name = "Healing Stream Totem", icon = GetSpellTexture(5394),              hideIcon = false, size = 24, duration = 15, color = {0, 0.7, 0.7}, important = false },
    [78001] =   { name = "Cloudburst Totem", icon = GetSpellTexture(157153),                hideIcon = false, size = 24, duration = 15, color = {0, 1, 0.39}, important = false },
    [10467] =   { name = "Mana Tide Totem", icon = GetSpellTexture(16191),                  hideIcon = false, size = 24, duration = 8,  color = {0.08, 0.82, 0.78}, important = false },
    [97285] =   { name = "Wind Rush Totem", icon = GetSpellTexture(192077),                 hideIcon = false, size = 24, duration = 15, color = {0.08, 0.82, 0.78}, important = false },
    [60561] =   { name = "Earthgrab Totem", icon = GetSpellTexture(51485),                  hideIcon = false, size = 24, duration = 20, color = {0.75, 0.31, 0.10}, important = false },
    [2630] =    { name = "Earthbind Totem", icon = GetSpellTexture(2484),                   hideIcon = false, size = 24, duration = 20, color = {0.78, 0.51, 0.39}, important = false },
    [105427] =  { name = "Skyfury Totem", icon = GetSpellTexture(204330),                   hideIcon = false, size = 24, duration = 15, color = {1, 0.27, 0.59}, important = false },
    [97369] =   { name = "Liquid Magma Totem", icon = GetSpellTexture(192222),              hideIcon = false, size = 24, duration = 6,  color = {1, 0.69, 0}, important = false },
    [6112] =    { name = "Windfury Totem", icon = GetSpellTexture(8512),                    hideIcon = false, size = 24, duration = nil,color = {0.08, 0.82, 0.78}, important = false },
    [62982] =   { name = "Mindbender", icon = GetSpellTexture(123040),                      hideIcon = false, size = 24, duration = 15, color = {1, 0.69, 0}, important = false },
    [179867] =  { name = "Static Field Totem", icon = GetSpellTexture(355580),              hideIcon = false, size = 24, duration = 6,  color = {0, 1, 0.78}, important = false },
    [194117] =  { name = "Stoneskin Totem", icon = GetSpellTexture(383017),                 hideIcon = false, size = 24, duration = 15,  color = {0.78, 0.49, 0.35}, important = false },
    [5923] =    { name = "Poison Cleansing Totem", icon = GetSpellTexture(383013),          hideIcon = false, size = 24, duration = 6,  color = {0.49, 0.9, 0.08}, important = false },
    [194118] =  { name = "Tranquil Air Totem", icon = GetSpellTexture(383019),              hideIcon = false, size = 24, duration = 20,  color = {0, 1, 0.78}, important = false },
}

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
function BBP.ApplyTotemAttributes(frame, iconTexture, duration, color, size, hideIcon)
    BBP.CreateTotemComponents(frame, size)

    -- Only apply the following if hideIcon is false
    if not hideIcon then
        -- Set icon texture and cooldown if provided
        if iconTexture then
            frame.customIcon:SetTexture(iconTexture)
            frame.customIcon:Show()

            if duration then
                if not frame.customCooldown then
                    frame.customCooldown = CreateFrame("Cooldown", nil, frame.totemIndicator,"CooldownFrameTemplate")
                    frame.customCooldown:SetAllPoints(frame.totemIndicator)
                end
                frame.customCooldown:SetCooldown(GetTime(), duration)
                frame.customCooldown:SetReverse(true)
                frame.customCooldown:SetDrawSwipe(false)
                frame.customCooldown:SetDrawEdge(false)
                frame.customCooldown:SetScript("OnUpdate", function(self, elapsed)
                    local start, dur = self:GetCooldownTimes()
                    if start and dur and start > 0 and dur > 0 then
                        local remaining = start / 1000 + dur / 1000 - GetTime()
                        if remaining <= 0 then
                            frame.customIcon:Hide()
                            if frame.glowTexture then
                                frame.glowTexture:Hide()
                            end
                            self:SetScript("OnUpdate", nil)
                            self:Hide()
                        end
                    else
                        frame.customIcon:Hide()
                        if frame.glowTexture then
                            frame.glowTexture:Hide()
                        end
                        self:SetScript("OnUpdate", nil)
                    end
                end)
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
                frame.glowTexture:SetParent(frame.customCooldown)
                frame.glowTexture:SetAtlas("clickcast-highlight-spellbook")
                frame.glowTexture:SetDesaturated(true)
            end

            frame.glowTexture:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', -widthOffset, heightOffset)
            frame.glowTexture:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', widthOffset, -heightOffset)

            frame.glowTexture:SetVertexColor(unpack(color))
            frame.glowTexture:Show()
            frame.animationGroup:Play()
        end
    else
        -- If hideIcon is true, ensure icon, cooldown, and glow are not displayed
        if frame.customIcon then
            frame.customIcon:Hide()
        end
        if frame.customCooldown then
            frame.customCooldown:Hide()
        end
        if frame.glowTexture then
            frame.glowTexture:Hide()
        end
    end

    local cdText = frame.customCooldown and frame.customCooldown:GetRegions()
    if cdText then
        cdText:SetScale(1) --cooldown text scale
    end
end

-- Gets random totem icon for totem feature tester
function BBP.GetRandomTotemAttributes()
    -- Convert NPC list keys into two tables: important and less important
    local importantKeys = {}
    local lessImportantKeys = {}
    for key, value in pairs(BBP.npcList) do
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

    -- Return the icon, color, importance flag, and name associated with the selected NPC
    return BBP.npcList[selectedKey].icon, BBP.npcList[selectedKey].color, BBP.npcList[selectedKey].important, BBP.npcList[selectedKey].name
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
    local npcData = BBP.npcList[npcID]
    local showEnemyOnly = BetterBlizzPlatesDB.totemIndicatorEnemyOnly
    local size = npcData and npcData.size or 30

    frame:SetScale(1)

    -- Early return if not in test mode and npcData is nil
    if not testMode and not npcData then
        return
    end

    local isEnemy = UnitIsEnemy("player", unit)

    -- Initialize totem components
    BBP.CreateTotemComponents(frame, size)

    -- Test mode
    if testMode then
        frame:SetScale(1)
        BBP.ResetNameplateTestAttributes()

        -- Fetch and store random attributes on the frame if they don't exist
        if not frame.randomIcon or not frame.randomColor or frame.isImportant == nil or not frame.randomName then
            frame.randomIcon, frame.randomColor, frame.isImportant, frame.randomName = BBP.GetRandomTotemAttributes()
        end

        BBP.ApplyTotemAttributes(frame, frame.randomIcon, nil, nil, npcData.size, npcData.hideIcon)
        frame.healthBar:SetStatusBarColor(unpack(frame.randomColor))
        frame.name:SetVertexColor(unpack(frame.randomColor))
        frame.name:SetText(frame.randomName)

        if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
            frame.name:SetText("")
        end

        if frame.isImportant then
            if BetterBlizzPlatesDB.totemIndicatorScaleUpImportant then
                --frame:SetScale(1.2) messes with targeting, kill for now
            end
            if not BetterBlizzPlatesDB.totemIndicatorGlowOff then
                BBP.ApplyTotemAttributes(frame, nil, nil, frame.randomColor, npcData.size, npcData.hideIcon)
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
        frame:SetScale(1)

        BBP.ApplyTotemAttributes(frame, npcData.icon, npcData.duration, nil, npcData.size, npcData.hideIcon)

        if npcData.color then
            frame.healthBar:SetStatusBarColor(unpack(npcData.color))
            frame.name:SetVertexColor(unpack(npcData.color))
        end

        if npcData.important then
            if BetterBlizzPlatesDB.totemIndicatorScaleUpImportant then
                --frame:SetScale(1.2) messes with targeting, kill for now
            end
            if not BetterBlizzPlatesDB.totemIndicatorGlowOff then
                BBP.ApplyTotemAttributes(frame, nil, nil, npcData.color, npcData.size, npcData.hideIcon)
            end
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
    else
        frame:SetScale(1)
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