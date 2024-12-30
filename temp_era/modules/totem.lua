local activeCooldowns = {}

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
    grow:SetScale(1.07, 1.07)
    grow:SetDuration(0.5)

    local shrink = animationGroup:CreateAnimation("Scale")
    shrink:SetOrder(2)
    shrink:SetScale(1 / 1.07, 1 / 1.07)
    shrink:SetDuration(0.5)

    animationGroup:SetLooping("REPEAT")

    return animationGroup
end

local function CreateTotemFrame(frame)
    local config = frame.BetterBlizzPlates.config or BBP.InitializeNameplateSettings(frame)
    if not frame.totemIndicator then
        frame.totemIndicator = CreateFrame("Frame", nil, frame)
        frame.totemIndicator:SetSize(30, 30)
        frame.totemIndicator:SetScale(config.totemIndicatorScale or 1)
        frame.totemIndicator:SetIgnoreParentAlpha(true)

        frame.customIcon = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
        frame.customIcon:SetAllPoints(frame.totemIndicator)

        frame.glowFrame = CreateFrame("Frame", nil, frame.totemIndicator)
        frame.glowFrame:SetAllPoints(frame.totemIndicator)
        frame.glowFrame:SetFrameStrata("MEDIUM")

        frame.friendlyIndicator = frame.glowFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.friendlyIndicator:SetAtlas("Garr_LevelUpgradeArrow", true)
        frame.friendlyIndicator:SetSize(22,27)
        frame.friendlyIndicator:SetPoint("CENTER", frame.totemIndicator, "BOTTOM", 0, 0)

        frame.animationGroup = BBP.SetupUnifiedAnimation(frame.totemIndicator)
    end
end

-- Function to create the necessary components for the totem indicator
function BBP.CreateTotemComponents(frame, size)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    CreateTotemFrame(frame)
    if info.isFriend then
        frame.totemIndicator:SetSize(22, 22)
    else
        frame.totemIndicator:SetSize(size, size)
    end
    frame.totemIndicator:SetScale(config.totemIndicatorScale or 1)
    local totemIndicatorSwappingAnchor
    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = frame.healthBar
    else
        if config.totemIndicatorAnchor == "TOP" then
            if frame.fakeName then
                totemIndicatorSwappingAnchor = frame.fakeName
            else
                totemIndicatorSwappingAnchor = frame.name
            end
        else
            totemIndicatorSwappingAnchor = frame.healthBar
        end
    end
    frame.totemIndicator:ClearAllPoints()
    if config.totemIndicatorHideNameAndShiftIconDown then
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), frame.healthBar, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos + 4)
    -- elseif config.nameplateResourceOnTarget == "1" and UnitIsUnit(frame.unit, "target") and not BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
    --     local resourceFrame = frame:GetParent().driverFrame.classNamePlateMechanicFrame
    --     frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), resourceFrame or (config.totemIndicatorHideNameAndShiftIconDown and frame.healthBar) or totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    else
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), (config.totemIndicatorHideNameAndShiftIconDown and frame.healthBar) or totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    end
end

-- Function to apply totem icons and other attributes
function BBP.ApplyTotemAttributes(frame, iconTexture, duration, color, size, hideIcon, guid)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
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
                    if frame.friendlyIndicator then frame.friendlyIndicator:Hide() end
                    if frame.glowTexture then frame.glowTexture:Hide() end
                    if frame.shieldTexture then frame.shieldTexture:Hide() end
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
        local offsetMultiplier = 1.15--0.41
        local widthOffset = size * offsetMultiplier

        if BetterBlizzPlatesDB.totemIndicatorShieldBorder then
            BBP.ApplyShieldBorder(frame, widthOffset)
        end

        if color then

            -- if not frame.glowTexture then
            --     frame.glowTexture = frame.totemIndicator:CreateTexture(nil, "OVERLAY")
            --     --frame.glowTexture:SetBlendMode("ADD")
            --     frame.glowTexture:SetTexture(BBP.squareGreenGlow)
            --     frame.glowTexture:SetDesaturated(true)
            -- end

            if not frame.glowFrame then
                frame.glowFrame = CreateFrame("Frame", nil, frame.totemIndicator)
                frame.glowFrame:SetAllPoints(frame.totemIndicator)
                frame.glowFrame:SetFrameStrata("MEDIUM")
            end

            -- Ensure the glowTexture is on top of other elements
            if not frame.glowTexture then
                frame.glowTexture = frame.glowFrame:CreateTexture(nil, "OVERLAY", nil, 1)  -- Specify sublevel to ensure correct layering
                frame.glowTexture:SetTexture(BBP.squareGreenGlow)
                frame.glowTexture:SetDesaturated(true)
            end

            frame.glowTexture:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', -widthOffset, widthOffset)
            frame.glowTexture:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', widthOffset, -widthOffset)
            frame.glowTexture:SetVertexColor(unpack(color))

            if not info.isFriend then
                frame.glowTexture:Show()
                if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
                    frame.animationGroup:Play()
                end
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

            if info.isFriend then
                if BetterBlizzPlatesDB.enemyTotemArrow == false then
                    frame.friendlyIndicator:SetDesaturated(false)
                    frame.friendlyIndicator:SetVertexColor(1,1,1)
                end
                frame.friendlyIndicator:Show()
            else
                if BetterBlizzPlatesDB.enemyTotemArrow then
                    frame.friendlyIndicator:SetDesaturated(true)
                    frame.friendlyIndicator:SetVertexColor(1,0,0)
                    frame.friendlyIndicator:Show()
                else
                    frame.friendlyIndicator:Hide()
                end
            end
        --end
    else
        -- If hideIcon is true, ensure icon, cooldown, and glow are not displayed
        if frame.customIcon then frame.customIcon:Hide() end
        if frame.customCooldown then frame.customCooldown:Hide() end
        if frame.glowTexture then frame.glowTexture:Hide() end
        if frame.shieldTexture then frame.shieldTexture:Hide() end
        if frame.friendlyIndicator then frame.friendlyIndicator:Hide() end
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

        config.totemIndicatorInitialized = true
    end


    local guid = UnitGUID(frame.unit)
    local npcID = tonumber(guid and guid:match("-(%d+)-%x+$"))
    local totemIndicatorSwappingAnchor

    if config.totemIndicatorHideNameAndShiftIconDown then
        totemIndicatorSwappingAnchor = frame.healthBar
    else
        if config.totemIndicatorAnchor == "TOP" then
            if frame.fakeName then
                totemIndicatorSwappingAnchor = frame.fakeName
            else
                totemIndicatorSwappingAnchor = frame.name
            end
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
            if frame.fakeName then
                frame.fakeName:SetText("")
            end
        end

        if frame.BuffFrame and config.totemIndicatorHideAuras then
            frame.BuffFrame:SetAlpha(0)
        end

        if config.totemIsImportant then
            if not info.isFriend then
                -- Apply glow effect
                if not frame.glowFrame then
                    frame.glowFrame = CreateFrame("Frame", nil, frame.totemIndicator)
                    frame.glowFrame:SetAllPoints(frame.totemIndicator)
                    frame.glowFrame:SetFrameStrata("MEDIUM")
                end

                -- Ensure the glowTexture is on top of other elements
                if not frame.glowTexture then
                    frame.glowTexture = frame.glowFrame:CreateTexture(nil, "OVERLAY")
                    frame.glowTexture:SetTexture(BBP.squareGreenGlow)
                    frame.glowTexture:SetDesaturated(true)
                end

                local offsetMultiplier = 1.15
                local widthOffset = config.randomTotemSize * offsetMultiplier
                local heightOffset = config.randomTotemSize * offsetMultiplier

                frame.glowTexture:SetPoint('TOPLEFT', frame.totemIndicator, 'TOPLEFT', -widthOffset, heightOffset)
                frame.glowTexture:SetPoint('BOTTOMRIGHT', frame.totemIndicator, 'BOTTOMRIGHT', widthOffset, -heightOffset)

                frame.glowTexture:SetVertexColor(unpack(config.randomTotemColor))
                frame.glowTexture:Show()
                if not BetterBlizzPlatesDB.totemIndicatorNoAnimation then
                    frame.animationGroup:Play()
                end
            end
        else
            if frame.glowTexture then
                frame.glowTexture:Hide()
            end
            if frame.animationGroup then
                frame.animationGroup:Stop()
            end
        end

        if config.totemIndicatorHideHealthBar or config.randomTotemHideHp or config.randomTotemIconOnly then
            if not info.isTarget then
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                frame.healthBar:SetAlpha(1)
                if not config.hideTargetHighlight then
                    frame.selectionHighlight:SetAlpha(0.22)
                end
            end
        end

        if BBP.totemIndicatorShieldTest then
            BBP.ShowShieldBorder(frame)
        else
            BBP.HideShieldBorder(frame)
        end
    -- Totem Indicator
    elseif npcData then
        config.randomTotemColor = nil
        if config.totemIndicatorEnemyOnly and info.isFriend then
            return
        end

        if frame.BuffFrame and config.totemIndicatorHideAuras then
            frame.BuffFrame:SetAlpha(0)
            frame.BuffFrameHidden = true
        end

        -- if true then
        --     frame.healthBar:ClearPoint("RIGHT")
        --     frame.healthBar:ClearPoint("LEFT")
        --     frame.healthBar:SetPoint("RIGHT", frame, "CENTER", 20,0)
        --     frame.healthBar:SetPoint("LEFT", frame, "CENTER", -20, 0)
        --     if BetterBlizzPlatesDB.classicNameplates then
        --         local width = info.isFriend and BetterBlizzPlatesDB.nameplateFriendlyWidth or BetterBlizzPlatesDB.nameplateEnemyWidth
        --         -- frame.BetterBlizzPlates.bbpBorder.left:ClearAllPoints()
        --         -- frame.BetterBlizzPlates.bbpBorder.left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -24, 1)
        --         frame.BetterBlizzPlates.bbpBorder.center:SetWidth(width-75)
        --     end
        -- end

        if npcData.color then
            config.totemColorRGB = npcData.color

            if config.totemIndicatorColorHealthBar then
                frame.healthBar:SetStatusBarColor(unpack(npcData.color))
            end
            if config.totemIndicatorColorName then
                frame.name:SetVertexColor(unpack(npcData.color))
                if frame.fakeName then
                    frame.name:SetVertexColor(unpack(npcData.color))
                end
            end
        else
            config.totemColorRGB = nil
        end

        if npcData.important and not info.isFriend then
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
                frame.healthBar:SetAlpha(0)
                frame.selectionHighlight:SetAlpha(0)
            else
                if not info.isTarget then
                    frame.healthBar:SetAlpha(0)
                    frame.selectionHighlight:SetAlpha(0)
                else
                    frame.healthBar:SetAlpha(1)
                    if not config.hideTargetHighlight then
                        frame.selectionHighlight:SetAlpha(0.22)
                    end
                end
            end
        else
            if npcData.widthOn and npcData.hpWidth then
                frame.healthBar.totemChanged = true
                frame.healthBar:ClearPoint("RIGHT")
                frame.healthBar:ClearPoint("LEFT")
                frame.healthBar:SetPoint("LEFT", frame, "LEFT", -npcData.hpWidth, 0)
                frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", npcData.hpWidth,0)
            else
                if frame.healthBar.totemChanged then
                    frame.healthBar:ClearPoint("RIGHT")
                    frame.healthBar:ClearPoint("LEFT")
                    if BetterBlizzPlatesDB.classicNameplates then
                        local xPos = BetterBlizzPlatesDB.hideLevelFrame and -4 or -21
                        frame.healthBar:SetPoint("LEFT", frame, "LEFT", 4, 0)
                        frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", xPos,0)
                    else
                        frame.healthBar:SetPoint("RIGHT", frame, "RIGHT", 0,0)
                        frame.healthBar:SetPoint("LEFT", frame, "LEFT", 0, 0)
                    end
                    frame.healthBar.totemChanged = nil
                end
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
            if frame.fakeName then
                frame.fakeName:SetText("")
            end
        else
            frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, yPosAdjustment)
            frame.name:SetText("")
            if frame.fakeName then
                frame.fakeName:SetText("")
            end
        end
    -- elseif config.nameplateResourceOnTarget == "1"  and UnitIsUnit(frame.unit, "target") and not BetterBlizzPlatesDB.nameplateResourceUnderCastbar then
    --     local resourceFrame = frame:GetParent().driverFrame.classNamePlateMechanicFrame
    --     frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), resourceFrame or totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    else
        frame.totemIndicator:SetPoint(BBP.GetOppositeAnchor(config.totemIndicatorAnchor), totemIndicatorSwappingAnchor, config.totemIndicatorAnchor, config.totemIndicatorXPos, config.totemIndicatorYPos)
    end
end


function BBP.ApplyShieldBorder(frame, widthOffset)
    if not frame.shieldFrame then
        frame.shieldFrame = CreateFrame("Frame", nil, frame.glowFrame)
        frame.shieldFrame:SetAllPoints(frame.glowFrame)
        frame.shieldFrame:SetFrameStrata("HIGH")
        frame.shieldTexture = frame.shieldFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    end

    local shieldType = BetterBlizzPlatesDB.totemIndicatorShieldType

    frame.shieldTexture:ClearAllPoints()
    if shieldType == 1 then
        frame.shieldTexture:SetAtlas("nameplates-InterruptShield")
        frame.shieldTexture:SetSize(14, 16)
        frame.shieldTexture:SetPoint("CENTER", frame.totemIndicator, "TOP", 0, -2)
    elseif shieldType == 2 then
        frame.shieldTexture:SetAtlas("transmog-frame-selected")
        frame.shieldTexture:SetDesaturated(true)
        frame.shieldTexture:SetSize(widthOffset + 2, widthOffset + 2)
        frame.shieldTexture:SetPoint("CENTER", frame.totemIndicator, "CENTER", 0, 0)
    elseif shieldType == 3 then
        frame.shieldTexture:SetAtlas("ShipMission_ShipFollower-EquipmentFrame")
        frame.shieldTexture:SetDesaturated(true)
        frame.shieldTexture:SetSize(widthOffset - 1, widthOffset - 1)
        frame.shieldTexture:SetPoint("CENTER", frame.totemIndicator, "CENTER", 0, 0)
    elseif shieldType == 4 then
        frame.shieldTexture:SetAtlas("GarrMission_EncounterAbilityBorder-Lg")
        frame.shieldTexture:SetDesaturated(true)
        frame.shieldTexture:SetSize(widthOffset + 13, widthOffset + 13)
        frame.shieldTexture:SetPoint("CENTER", frame.totemIndicator, "CENTER", 0, 0)
    elseif shieldType == 5 then
        frame.shieldTexture:SetAtlas("Garr_Specialization_IconBorder")
        frame.shieldTexture:SetDesaturated(true)
        frame.shieldTexture:SetSize(widthOffset + 1, widthOffset + 1)
        frame.shieldTexture:SetPoint("CENTER", frame.totemIndicator, "CENTER", 0, 0)
    end

    BBP.OnUnitAura(frame.unit)
end

local shieldAuraEvent
function BBP.ToggleTotemIndicatorShieldBorder()
    if BetterBlizzPlatesDB.totemIndicatorShieldBorder then
        if not shieldAuraEvent then
            shieldAuraEvent = CreateFrame("Frame")
            shieldAuraEvent:RegisterEvent("UNIT_AURA")
            shieldAuraEvent:SetScript("OnEvent", function(self, event, unit)
                if event == "UNIT_AURA" then
                    BBP.OnUnitAura(unit)
                end
            end)
        end
        if not shieldAuraEvent:IsEventRegistered("UNIT_AURA") then
            shieldAuraEvent:RegisterEvent("UNIT_AURA")
        end
    elseif shieldAuraEvent then
        shieldAuraEvent:UnregisterAllEvents()
    end
end

function BBP.OnUnitAura(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.UnitFrame then
        local frame = nameplate.UnitFrame
        local guid = UnitGUID(frame.unit)
        local npcID = tonumber(guid and guid:match("-(%d+)-%x+$"))
        local entry = BetterBlizzPlatesDB.totemIndicatorNpcList[npcID]
        if entry then
            local hasAura = false
            for i = 1, 40 do
                local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
                if not name then break end
                if spellId == 55277 then
                    hasAura = true
                    break
                end
            end

            if hasAura then
                if not entry.hideIcon then
                    BBP.ShowShieldBorder(frame)
                end
            else
                BBP.HideShieldBorder(frame)
            end
        else
            BBP.HideShieldBorder(frame)
        end
    end
end

function BBP.ShowShieldBorder(frame)
    if not frame.shieldFrame then
        CreateTotemFrame(frame)
        frame.shieldFrame = CreateFrame("Frame", nil, frame.glowFrame)
        frame.shieldFrame:SetAllPoints(frame.glowFrame)
        frame.shieldFrame:SetFrameStrata("HIGH")
        frame.shieldTexture = frame.shieldFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    end
    frame.shieldTexture:Show()
end

function BBP.HideShieldBorder(frame)
    if frame.shieldTexture then
        frame.shieldTexture:Hide()
    end
end
