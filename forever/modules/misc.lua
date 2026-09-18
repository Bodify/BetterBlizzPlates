local prdClassFrame = prdClassFrame or (PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.classFrame)

function BBP.InstantComboPoints()
    if not BetterBlizzPlatesDB.instantComboPoints then return end
    if BBP.InstantComboPointsActive then return end

    local class = UnitClassBase("player")

    local function UpdateRogueComboPoints(self)
        if not self or self:IsForbidden() then return end
        local comboPoints = UnitPower("player", self.powerType)
        local chargedPowerPoints = GetUnitChargedPowerPoints("player") or {}

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints
            local isCharged = tContains(chargedPowerPoints, i)

            for _, transitionAnim in ipairs(point.transitionAnims) do
                transitionAnim:Stop()
            end

            point.IconUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
            point.IconCharged:SetAlpha(isFull and isCharged and 1 or 0)
            point.BGActive:SetAlpha(isFull and 1 or 0)
            point.BGInactive:SetAlpha(isFull and 0 or 1)
            point.FXUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
            point.FXCharged:SetAlpha(isFull and isCharged and 1 or 0)

            if isCharged then
                if isFull then
                    point.ChargedFrameActive:SetAlpha(1)
                    point.ChargedFrameInactive:SetAlpha(0)
                else
                    point.ChargedFrameActive:SetAlpha(0)
                    point.ChargedFrameInactive:SetAlpha(1)
                end
            else
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

            if point.activateAnim then point.activateAnim:Stop() end
            if point.deactivateAnim then point.deactivateAnim:Stop() end

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

            if point.activate then point.activate:Stop() end
            if point.deactivate then point.deactivate:Stop() end

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

            if point.activateAnim then point.activateAnim:Stop() end
            if point.deactivateAnim then point.deactivateAnim:Stop() end

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
                if rune.activateAnim then rune.activateAnim:Stop() end
                if rune.readyAnim then rune.readyAnim:Stop() end
                if rune.readyLoopAnim then rune.readyLoopAnim:Stop() end
                if rune.depleteAnim then rune.depleteAnim:Stop() end

                if rune.FX then rune.FX:SetAlpha(0) end
                if rune.Blur then rune.Blur:SetAlpha(0) end
                if rune.Glow then rune.Glow:SetAlpha(0) end
                if rune.DepleteFlipbook then rune.DepleteFlipbook:SetAlpha(0) end

                if i <= numHolyPower then
                    if rune.ActiveTexture then rune.ActiveTexture:SetAlpha(1) end
                else
                    if rune.ActiveTexture then rune.ActiveTexture:SetAlpha(0) end
                end
            end
        end

        self.activateAnim:Stop()
        self.readyAnim:Stop()
        self.readyLoopAnim:Stop()
        self.depleteAnim:Stop()

        self.ActiveTexture:SetAlpha(numHolyPower > 0 and 1 or 0)
        self.ThinGlow:SetAlpha(numHolyPower > 2 and 1 or 0)
        self.Glow:SetAlpha(numHolyPower == 5 and 1 or 0)
    end

    if BetterBlizzFramesDB then
        BetterBlizzFramesDB.instantComboPoints = true
    end
    local BBF = BetterBlizzFramesDB

    if class == "MONK" then
        if not BBF and MonkHarmonyBarFrame then hooksecurefunc(MonkHarmonyBarFrame, "UpdatePower", UpdateMonkChi) end
        if prdClassFrame then hooksecurefunc(prdClassFrame, "UpdatePower", UpdateMonkChi) end
    elseif class == "ROGUE" then
        if not BBF and RogueComboPointBarFrame then hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", UpdateRogueComboPoints) end
        if prdClassFrame then hooksecurefunc(prdClassFrame, "UpdatePower", UpdateRogueComboPoints) end
    elseif class == "DRUID" then
        if not BBF and DruidComboPointBarFrame then hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", UpdateDruidComboPoints) end
        if prdClassFrame then hooksecurefunc(prdClassFrame, "UpdatePower", UpdateDruidComboPoints) end
    elseif class == "MAGE" then
        if not BBF and MageArcaneChargesFrame then hooksecurefunc(MageArcaneChargesFrame, "UpdatePower", UpdateArcaneCharges) end
        if prdClassFrame then hooksecurefunc(prdClassFrame, "UpdatePower", UpdateArcaneCharges) end
    elseif class == "PALADIN" then
        if not BBF and PaladinPowerBarFrame then hooksecurefunc(PaladinPowerBarFrame, "UpdatePower", UpdatePaladinHolyPower) end
        if prdClassFrame then hooksecurefunc(prdClassFrame, "UpdatePower", UpdatePaladinHolyPower) end
    end
    BBP.InstantComboPointsActive = true
end