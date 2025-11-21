if not BBP.isMidnight then return end
function BBP.InstantComboPoints()
    if not BetterBlizzPlatesDB.instantComboPoints then return end
    if BBP.InstantComboPointsActive then return end
    if BBP.isMidnight then return end
    -- Call the function for each frame
    local _, class = UnitClass("player")

    local function UpdateRogueComboPoints(self)
        if not self or self:IsForbidden() then return end
        local comboPoints = UnitPower("player", self.powerType)
        local chargedPowerPoints = GetUnitChargedPowerPoints("player") or {}

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints
            local isCharged = tContains(chargedPowerPoints, i)

            -- Stop all animations to enforce instant update
            for _, transitionAnim in ipairs(point.transitionAnims) do
                transitionAnim:Stop()
            end

            -- Directly set textures and visibility
            point.IconUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
            point.IconCharged:SetAlpha(isFull and isCharged and 1 or 0)
            point.BGActive:SetAlpha(isFull and 1 or 0)
            point.BGInactive:SetAlpha(isFull and 0 or 1)
            point.FXUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
            point.FXCharged:SetAlpha(isFull and isCharged and 1 or 0)

            -- ChargedFrame logic:
            if isCharged then
                if isFull then
                    point.ChargedFrameActive:SetAlpha(1)  -- Show Active only if both charged and filled
                    point.ChargedFrameInactive:SetAlpha(0) -- Hide Inactive since it's full
                else
                    point.ChargedFrameActive:SetAlpha(0)  -- Hide Active since no combo point is in it
                    point.ChargedFrameInactive:SetAlpha(1) -- Show Inactive since it's charged but empty
                end
            else
                -- If not charged, hide both charged frames
                point.ChargedFrameActive:SetAlpha(0)
                point.ChargedFrameInactive:SetAlpha(0)
            end
        end
    end

    local function UpdateDruidComboPoints(self)
        if not self or self:IsForbidden() then return end
        local comboPoints = UnitPower("player", self.powerType)

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints

            -- Stop animations for instant update
            if point.activateAnim then point.activateAnim:Stop() end
            if point.deactivateAnim then point.deactivateAnim:Stop() end

            -- Directly set textures and visibility
            point.Point_Icon:SetAlpha(isFull and 1 or 0)
            point.BG_Active:SetAlpha(isFull and 1 or 0)
            point.BG_Inactive:SetAlpha(isFull and 0 or 1)

            point.Point_Deplete:SetAlpha(0)
        end
    end

    local function UpdateMonkChi(self)
        if not self or self:IsForbidden() then return end
        local numChi = UnitPower("player", self.powerType)

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= numChi

            -- Stop animations for instant updates
            if point.activate then point.activate:Stop() end
            if point.deactivate then point.deactivate:Stop() end

            -- Directly update textures and visibility
            point.Chi_Icon:SetAlpha(isFull and 1 or 0)
            point.Chi_BG_Active:SetAlpha(isFull and 1 or 0)
            point.Chi_BG:SetAlpha(isFull and 0 or 1)

            point.Chi_Deplete:SetAlpha(0)
            point.FX_OuterGlow:SetAlpha(0)
            point.FB_Wind_FX:SetAlpha(0)
        end
    end

    local function UpdateArcaneCharges(self)
        if not self or self:IsForbidden() then return end
        local numCharges = UnitPower("player", self.powerType, true)

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= numCharges

            -- Stop animations for instant updates
            if point.activateAnim then point.activateAnim:Stop() end
            if point.deactivateAnim then point.deactivateAnim:Stop() end

            -- Directly update textures and visibility
            point.ArcaneIcon:SetAlpha(isFull and 1 or 0)
            point.ArcaneBG:SetAlpha(isFull and 1 or 0)
            point.Orb:SetAlpha(isFull and 0 or 1)

            point.ArcaneFlare:SetAlpha(0)
            point.ArcaneOuterFX:SetAlpha(0)
            point.ArcaneCircle:SetAlpha(0)
            point.ArcaneTriangle:SetAlpha(0)
            point.ArcaneSquare:SetAlpha(0)
            point.ArcaneDiamond:SetAlpha(0)
            point.FrameGlow:SetAlpha(0)
            point.FBArcaneFX:SetAlpha(0)
        end
    end

    local function UpdatePaladinHolyPower(self)
        if not self or self:IsForbidden() then return end
        local numHolyPower = UnitPower("player", Enum.PowerType.HolyPower)
        local maxHolyPower = UnitPowerMax("player", Enum.PowerType.HolyPower)

        for i = 1, maxHolyPower do
            local rune = self["rune"..i]
            if rune then
                -- Stop all animations
                if rune.activateAnim then rune.activateAnim:Stop() end
                if rune.readyAnim then rune.readyAnim:Stop() end
                if rune.readyLoopAnim then rune.readyLoopAnim:Stop() end
                if rune.depleteAnim then rune.depleteAnim:Stop() end

                -- Hide all FX
                if rune.FX then rune.FX:SetAlpha(0) end
                if rune.Blur then rune.Blur:SetAlpha(0) end
                if rune.Glow then rune.Glow:SetAlpha(0) end
                if rune.DepleteFlipbook then rune.DepleteFlipbook:SetAlpha(0) end

                -- Set active state
                if i <= numHolyPower then
                    if rune.ActiveTexture then rune.ActiveTexture:SetAlpha(1) end
                else
                    if rune.ActiveTexture then rune.ActiveTexture:SetAlpha(0) end
                end
            end
        end

        -- Stop main bar animations
        self.activateAnim:Stop()
        self.readyAnim:Stop()
        self.readyLoopAnim:Stop()
        self.depleteAnim:Stop()

        -- Update bar visuals
        self.ActiveTexture:SetAlpha(numHolyPower > 0 and 1 or 0)
        self.ThinGlow:SetAlpha(numHolyPower > 2 and 1 or 0)
        self.Glow:SetAlpha(numHolyPower == 5 and 1 or 0)
    end

    if BetterBlizzFramesDB then
        BetterBlizzFramesDB.instantComboPoints = true
    end
    local BBF = BetterBlizzFramesDB

    if class == "MONK" then
        if not BBF then hooksecurefunc(MonkHarmonyBarFrame, "UpdatePower", UpdateMonkChi) end
        hooksecurefunc(ClassNameplateBarWindwalkerMonkFrame, "UpdatePower", UpdateMonkChi)
    elseif class == "ROGUE" then
        if not BBF then hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", UpdateRogueComboPoints) end
        hooksecurefunc(ClassNameplateBarRogueFrame, "UpdatePower", UpdateRogueComboPoints)
    elseif class == "DRUID" then
        if not BBF then hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", UpdateDruidComboPoints) end
        hooksecurefunc(ClassNameplateBarFeralDruidFrame, "UpdatePower", UpdateDruidComboPoints)
    elseif class == "MAGE" then
        if not BBF then hooksecurefunc(MageArcaneChargesFrame, "UpdatePower", UpdateArcaneCharges) end
        hooksecurefunc(ClassNameplateBarMageFrame, "UpdatePower", UpdateArcaneCharges)
    elseif class == "PALADIN" then
        if not BBF then hooksecurefunc(PaladinPowerBarFrame, "UpdatePower", UpdatePaladinHolyPower) end
        hooksecurefunc(ClassNameplateBarPaladinFrame, "UpdatePower", UpdatePaladinHolyPower)
    end
    BBP.InstantComboPointsActive = true
end