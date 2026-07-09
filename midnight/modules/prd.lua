local LSM = LibStub("LibSharedMedia-3.0")

local fancyPRDTokenAtlasMap = {
    ["LUNAR_POWER"] = "Unit_Druid_AstralPower_Fill",
    ["FURY"]        = "Unit_DemonHunter_Fury_Fill",
    ["PAIN"]        = "Unit_DemonHunter_Fury_Fill",
    ["MAELSTROM"]   = "Unit_Shaman_Maelstrom_Fill",
    ["INSANITY"]    = "Unit_Priest_Insanity_Fill",
}

local fancyPRDAltBarClassAtlasMap = {
    ["EVOKER"] = "Unit_Evoker_EbonMight_Fill",
}

local monkStaggerAtlasMap = {
    ["green"]  = "Unit_Monk_Stagger_Fill_Green",
    ["yellow"] = "Unit_Monk_Stagger_Fill_Yellow",
    ["red"]    = "Unit_Monk_Stagger_Fill_Red",
}

function BBP.HidePersonalManabarFX()
    if BetterBlizzFramesDB and BetterBlizzFramesDB.hidePersonalManaFX then
        BBP.Print("BetterBlizzFrames is handling PRD: HidePersonalManabarFX. Skipping.")
        return
    end
    if BetterBlizzPlatesDB.hidePersonalManaFX then
        if PersonalResourceDisplayFrame then
            PersonalResourceDisplayFrame.PowerBar.FullPowerFrame:SetParent(BBP.hiddenFrame)
            PersonalResourceDisplayFrame.PowerBar.FeedbackFrame:SetParent(BBP.hiddenFrame)
        end
    end
end

local function ApplyPRDBarMask(bar, container)
    if not bar or bar:IsForbidden() then return end
    if not bar.bbpPRDMask then
        bar.bbpPRDMask = bar:CreateMaskTexture()
    end
    local mask = bar.bbpPRDMask
    mask:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\midnightNpMask.tga")
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", container, "TOPLEFT", -0.5, 1)
    mask:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0.5, -1)
    mask:Show()
    bar:GetStatusBarTexture():AddMaskTexture(mask)
    if bar.bbfPRDMask then
        bar:GetStatusBarTexture():AddMaskTexture(bar.bbfPRDMask)
    end
end
BBP.ApplyPRDBarMask = ApplyPRDBarMask

local function ApplyPRDMasks()
    if BetterBlizzPlatesDB.prdLegacyLook then return end
    local prd = PersonalResourceDisplayFrame
    local healthBar = prd.HealthBarsContainer.healthBar
    ApplyPRDBarMask(healthBar, prd.HealthBarsContainer)

    if healthBar.totalAbsorb and not healthBar.totalAbsorb:IsForbidden() then
        if not healthBar.totalAbsorb.bbpPRDMasked then
            ApplyPRDBarMask(healthBar, prd.HealthBarsContainer)
            healthBar.totalAbsorb:AddMaskTexture(healthBar.bbpPRDMask)
            healthBar.totalAbsorb.bbpPRDMasked = true
        end
    end
    ApplyPRDBarMask(prd.PowerBar, prd.PowerBar)
    if prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
        ApplyPRDBarMask(prd.AlternatePowerBar, prd.AlternatePowerBar)
    end
end

function BBP.TexturePRD()
    if BetterBlizzFramesDB and (BetterBlizzFramesDB.useCustomTextureForBars or BetterBlizzFramesDB.changePrdTextures) then
        BBP.Print("BetterBlizzFrames is handling PRD: TexturePRD. Skipping.")
        return
    end
    local customTextureSelf = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzPlatesDB.customTextureSelf)
    local customTextureSelfMana = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzPlatesDB.customTextureSelfMana)

    local frame = PersonalResourceDisplayFrame
    if not frame then return end
    if BetterBlizzPlatesDB.useCustomTextureForBars and BetterBlizzPlatesDB.useCustomTextureForSelf then
        frame.changedPrdHealthTexture = true
        frame.HealthBarsContainer.healthBar:SetStatusBarTexture(customTextureSelf)
        BBP.textureExtraBars(frame.HealthBarsContainer.healthBar, customTextureSelf)
    elseif frame.changedPrdHealthTexture then
        frame.HealthBarsContainer.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        BBP.textureExtraBars(frame.HealthBarsContainer.healthBar, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.changedPrdHealthTexture = nil
    end
    if BetterBlizzPlatesDB.useCustomTextureForBars and BetterBlizzPlatesDB.useCustomTextureForSelfMana then
        frame.changedPrdManaTexture = true
        frame.PowerBar:SetStatusBarTexture(customTextureSelfMana)
        frame.AlternatePowerBar:SetStatusBarTexture(customTextureSelfMana)
        BBP.textureExtraBars(frame.PowerBar, customTextureSelfMana)
        BBP.textureExtraBars(frame.AlternatePowerBar, customTextureSelfMana)
    elseif frame.changedPrdManaTexture then
        frame.PowerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        BBP.textureExtraBars(frame.PowerBar, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.AlternatePowerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        BBP.textureExtraBars(frame.AlternatePowerBar, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.changedPrdManaTexture = nil
    end

    ApplyPRDMasks()

    -- fix borders
    local borderContainers = {
        PersonalResourceDisplayFrame.HealthBarsContainer.border,
        PersonalResourceDisplayFrame.PowerBar.Border,
        PersonalResourceDisplayFrame.AlternatePowerBar.Border,
    }

    for _, borderContainer in ipairs(borderContainers) do
        if borderContainer then
            for _, child in ipairs({borderContainer:GetChildren()}) do
                child:SetIgnoreParentAlpha(true)
            end
            for _, region in ipairs({borderContainer:GetRegions()}) do
                region:SetIgnoreParentAlpha(true)
            end
        end
    end
    BBP.FancyPRDAltTexture()
end

function BBP.FancyPRDAltTexture()
    if BBP.fancyPRDAltTextureRunning then return end
    if BetterBlizzFramesDB and BetterBlizzFramesDB.fancyPrdAltTexture then
        BBP.Print("BetterBlizzFrames is handling PRD: FancyPRDAltTexture. Skipping.")
        return
    end
    local prd = PersonalResourceDisplayFrame

    BBP.fancyPRDAltTextureRunning = true

    local db = BetterBlizzPlatesDB
    local powerBar = prd.PowerBar
    local altPowerBar = prd.AlternatePowerBar
    local _, playerClass = UnitClass("player")

    if not BBP.fancyPRDColorHooked then
        hooksecurefunc(powerBar, "SetStatusBarColor", function(self, r, g, b, a)
            if self.coloredBarTexture and not self.bbpSettingBarColor then
                self.bbpSettingBarColor = true
                self:SetStatusBarColor(1, 1, 1)
                self.bbpSettingBarColor = nil
            end
        end)
        hooksecurefunc(altPowerBar, "SetStatusBarColor", function(self, r, g, b, a)
            if self.coloredBarTexture and not self.bbpSettingBarColor then
                self.bbpSettingBarColor = true
                self:SetStatusBarColor(1, 1, 1)
                self.bbpSettingBarColor = nil
            end
        end)
        BBP.fancyPRDColorHooked = true
    end

    if not BBP.fancyPRDPowerBarHooked then
        hooksecurefunc(PersonalResourceDisplayFrame, "UpdatePowerBar", function()
            BBP.FancyPRDAltTexture()
        end)
        hooksecurefunc(PersonalResourceDisplayFrame, "UpdateAlternatePowerBar", function()
            BBP.FancyPRDAltTexture()
        end)
        if playerClass == "MONK" then
            hooksecurefunc(MonkStaggerBar, "SetStatusBarTexture", function()
                BBP.FancyPRDAltTexture()
            end)
        end
        BBP.fancyPRDPowerBarHooked = true
    end

    local _, powerToken = UnitPowerType("player")
    local atlas    = db.fancyPrdAltTexture and powerToken and fancyPRDTokenAtlasMap[powerToken]
    local altAtlas
    if db.fancyPrdAltTexture then
        if playerClass == "MONK" then
            local staggerKey = altPowerBar.staggerStateKey
            if staggerKey then
                altAtlas = monkStaggerAtlasMap[staggerKey]
            end
        else
            altAtlas = fancyPRDAltBarClassAtlasMap[playerClass]
        end
    end
    local customTextureActive = db.useCustomTextureForBars and db.useCustomTextureForSelfMana

    -- PowerBar
    if not atlas then
        if powerBar.coloredBarTexture then
            powerBar.coloredBarTexture = nil
            if customTextureActive then
                BBP.TexturePRD()
            elseif db.prdLegacyLook then
                powerBar:SetStatusBarTexture(137014)
            else
                powerBar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
            end
            local pt, ptok, altR, altG, altB = UnitPowerType("player")
            local info = PowerBarColor[ptok] or PowerBarColor[pt]
            if info then
                powerBar:SetStatusBarColor(info.r, info.g, info.b)
            elseif altR then
                powerBar:SetStatusBarColor(altR, altG, altB)
            end
        end
    else
        powerBar:SetStatusBarTexture(atlas)
        powerBar.coloredBarTexture = true
        powerBar:SetStatusBarColor(1, 1, 1)
        if powerBar.FeedbackFrame and powerBar.FeedbackFrame.BarTexture then
            powerBar.FeedbackFrame.BarTexture:SetAtlas(atlas)
        end
        if not db.prdLegacyLook then
            BBP.ApplyPRDBarMask(powerBar, powerBar)
        end
    end

    -- AltPowerBar, Ebon Might and Stagger shows here, but Mealstrom and Insanity for example shows on PowerBar
    if not altAtlas then
        if altPowerBar.coloredBarTexture then
            altPowerBar.coloredBarTexture = nil
            if altPowerBar.bbpOrigBarTextureAtlas then
                altPowerBar.barTextureAtlas = altPowerBar.bbpOrigBarTextureAtlas
                altPowerBar:SetStatusBarTexture(altPowerBar.bbpOrigBarTextureAtlas)
                altPowerBar.bbpOrigBarTextureAtlas = nil
            end
        end
    else
        if not altPowerBar.bbpOrigBarTextureAtlas and altPowerBar.barTextureAtlas then
            altPowerBar.bbpOrigBarTextureAtlas = altPowerBar.barTextureAtlas
        end
        altPowerBar:SetStatusBarTexture(altAtlas)
        altPowerBar.barTextureAtlas = altAtlas
        altPowerBar.coloredBarTexture = true
        altPowerBar:SetStatusBarColor(1, 1, 1)
        if not db.prdLegacyLook and altPowerBar:IsShown() then
            BBP.ApplyPRDBarMask(altPowerBar, altPowerBar)
        end
    end

    BBP.fancyPRDAltTextureRunning = nil
end

function BBP.LegacyPRDLook()
    if BetterBlizzFramesDB and BetterBlizzFramesDB.prdLegacyLook then
        BBP.Print("BetterBlizzFrames is handling PRD: LegacyPRDLook. Skipping.")
        return
    end
    local prd = PersonalResourceDisplayFrame
    local hpBar = prd.HealthBarsContainer.healthBar
    local powerBar = prd.PowerBar
    local altPowerBar = prd.AlternatePowerBar

    if not BetterBlizzPlatesDB.prdLegacyLook then
        if BBP.LegacyPRDLookEnabled then
            BBP.LegacyPRDLookEnabled = false
            if prd.bbpBorderContainer then
                prd.bbpBorderContainer:Hide()
            end
            for _, frame in ipairs({ hpBar, powerBar, altPowerBar }) do
                for _, region in ipairs({ frame:GetRegions() }) do
                    if region.blizzBgBorderTexture then
                        region:SetAtlas("UI-HUD-CoolDownManager-Bar-BG")
                    end
                end
                if frame.bbpPRDMask then
                    frame.bbpPRDMask:Show()
                end
                local customTextureActive
                local db = BetterBlizzPlatesDB
                if frame == hpBar then
                    customTextureActive = db.useCustomTextureForBars and db.useCustomTextureForSelf
                else
                    customTextureActive = db.useCustomTextureForBars and db.useCustomTextureForSelfMana
                end
                if not customTextureActive then
                    frame:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
                end
                if frame.bbpPRDBarBg then
                    frame.bbpPRDBarBg:Hide()
                end
            end
            prd:UpdatePowerBarAnchor()
            prd:UpdateAdditionalBarAnchors()
        end
        BBP.FancyPRDAltTexture()
        return
    end

    local db = BetterBlizzPlatesDB
    local prdBars = { hpBar, powerBar, altPowerBar }

    for _, frame in ipairs(prdBars) do
        for _, region in ipairs({ frame:GetRegions() }) do
            if region:GetObjectType() == "Texture" and region:GetAtlas() == "UI-HUD-CoolDownManager-Bar-BG" then
                region.blizzBgBorderTexture = true
                region:SetTexture(nil)
            end
        end
        if frame.bbpPRDMask then
            frame.bbpPRDMask:Hide()
        end
        local customTextureActive
        if frame == hpBar then
            customTextureActive = db.useCustomTextureForBars and db.useCustomTextureForSelf
        else
            customTextureActive = db.useCustomTextureForBars and db.useCustomTextureForSelfMana
        end
        if not customTextureActive then
            frame:SetStatusBarTexture(137014)
        end
        if not frame.bbpPRDBarBg then
            local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
            bg:SetAllPoints(frame)
            frame.bbpPRDBarBg = bg
        end
        if db.changeNpHpBgColor and db.npBgColorRGB then
            local r, g, b = unpack(db.npBgColorRGB)
            frame.bbpPRDBarBg:SetColorTexture(r, g, b, 0.4)
        else
            frame.bbpPRDBarBg:SetColorTexture(0, 0, 0, 0.4)
        end
        frame.bbpPRDBarBg:Show()
    end

    if not prd.bbpBorderContainer then
        local c = CreateFrame("Frame", nil, prd)
        c:SetAllPoints(prd)
        c:SetFrameStrata("MEDIUM")
        c:SetFrameLevel(500)
        prd.bbpBorderContainer = c
    end
    prd.bbpBorderContainer:Show()

    local bc = prd.bbpBorderContainer

    local function MakePRDTex()
        local t = bc:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetColorTexture(0, 0, 0, 1)
        t:SetIgnoreParentScale(true)
        t:SetIgnoreParentAlpha(true)
        return t
    end

    if not prd.bbpBorderTop then
        prd.bbpBorderTop    = MakePRDTex()
        prd.bbpBorderBottom = MakePRDTex()
        prd.bbpBorderLeft   = MakePRDTex()
        prd.bbpBorderRight  = MakePRDTex()
        prd.bbpSplitLine1   = MakePRDTex()
        prd.bbpSplitLine2   = MakePRDTex()
    end

    local function UpdatePRDBorderLayout()
        local db = BetterBlizzPlatesDB
        local th = (db.changeNameplateBorderSize and db.nameplatePersonalBorderSize) or 1
        local hpShown    = prd.HealthBarsContainer:IsShown()
        local powerShown = powerBar:IsShown()
        local altShown   = altPowerBar:IsShown()

        if not hpShown and not powerShown and not altShown then
            prd.bbpBorderContainer:Hide()
            prd.bbpBorderTop:Hide()
            prd.bbpBorderBottom:Hide()
            prd.bbpBorderLeft:Hide()
            prd.bbpBorderRight:Hide()
            prd.bbpSplitLine1:Hide()
            prd.bbpSplitLine2:Hide()
            return
        end

        prd.bbpBorderContainer:Show()

        local topBar  = hpShown    and hpBar    or (powerShown and powerBar or altPowerBar)
        local lastBar = altShown   and altPowerBar or (powerShown and powerBar or hpBar)

        local bTop = prd.bbpBorderTop
        bTop:ClearAllPoints()
        bTop:SetPoint("TOPLEFT",  topBar, "TOPLEFT",  -th, th)
        bTop:SetPoint("TOPRIGHT", topBar, "TOPRIGHT",  th, th)
        bTop:SetHeight(th)
        bTop:Show()

        local bBot = prd.bbpBorderBottom
        bBot:ClearAllPoints()
        bBot:SetPoint("BOTTOMLEFT",  lastBar, "BOTTOMLEFT",  -th, -th)
        bBot:SetPoint("BOTTOMRIGHT", lastBar, "BOTTOMRIGHT",  th, -th)
        bBot:SetHeight(th)
        bBot:Show()

        local bLeft = prd.bbpBorderLeft
        bLeft:ClearAllPoints()
        bLeft:SetPoint("TOPLEFT",    topBar,  "TOPLEFT",    -th,  th)
        bLeft:SetPoint("BOTTOMLEFT", lastBar, "BOTTOMLEFT", -th, -th)
        bLeft:SetWidth(th)
        bLeft:Show()

        local bRight = prd.bbpBorderRight
        bRight:ClearAllPoints()
        bRight:SetPoint("TOPRIGHT",    topBar,  "TOPRIGHT",    th,  th)
        bRight:SetPoint("BOTTOMRIGHT", lastBar, "BOTTOMRIGHT", th, -th)
        bRight:SetWidth(th)
        bRight:Show()

        if db.prdSplitLines then
            local sl1 = prd.bbpSplitLine1
            if hpShown and powerShown then
                sl1:ClearAllPoints()
                sl1:SetPoint("BOTTOMLEFT",  hpBar, "BOTTOMLEFT",  -th, 0)
                sl1:SetPoint("BOTTOMRIGHT", hpBar, "BOTTOMRIGHT",  th, 0)
                sl1:SetHeight(th)
                sl1:Show()
            else
                sl1:Hide()
            end

            local sl2 = prd.bbpSplitLine2
            if altShown and powerShown then
                sl2:ClearAllPoints()
                sl2:SetPoint("BOTTOMLEFT",  powerBar, "BOTTOMLEFT",  -th, 0)
                sl2:SetPoint("BOTTOMRIGHT", powerBar, "BOTTOMRIGHT",  th, 0)
                sl2:SetHeight(th)
                sl2:Show()
            else
                sl2:Hide()
            end
        else
            prd.bbpSplitLine1:Hide()
            prd.bbpSplitLine2:Hide()
        end
    end

    prd.bbpUpdateBorderLayout = UpdatePRDBorderLayout

    if BBP.LegacyPRDLookEnabled then
        UpdatePRDBorderLayout()
        BBP.FancyPRDAltTexture()
        return
    end

    BBP.LegacyPRDLookEnabled = true

    local function TweakPowerBarAnchor(self)
        if not BBP.LegacyPRDLookEnabled then return end
        self.PowerBar:ClearAllPoints()
        if self.hideHealth then
            self.PowerBar:SetPoint("TOP", self, "TOP", 0, 0)
        else
            self.PowerBar:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, 0)
        end
    end

    local function TweakAdditionalBarAnchors(self)
        if not BBP.LegacyPRDLookEnabled then return end
        local alternatePowerBarShown = self.AlternatePowerBar:IsShown()
        local classFrameContainerShown = self.ClassFrameContainer:IsShown()

        if alternatePowerBarShown then
            self.AlternatePowerBar:ClearAllPoints()
            if not self.hidePower then
                self.AlternatePowerBar:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, 0)
            elseif not self.hideHealth then
                self.AlternatePowerBar:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, 0)
            else
                self.AlternatePowerBar:SetPoint("TOP", self, "TOP", 0, 0)
            end
        end

        if classFrameContainerShown then
            self.ClassFrameContainer:ClearAllPoints()
            if alternatePowerBarShown then
                self.ClassFrameContainer:SetPoint("TOP", self.AlternatePowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset)
            elseif not self.hidePower then
                self.ClassFrameContainer:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset)
            elseif not self.hideHealth then
                self.ClassFrameContainer:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, self.ClassFrameContainer.yOffset)
            else
                self.ClassFrameContainer:SetPoint("TOP", self, "TOP", 0, self.ClassFrameContainer.yOffset)
            end
        end
        if self == PersonalResourceDisplayFrame and prd.bbpUpdateBorderLayout then
            prd.bbpUpdateBorderLayout()
        end
    end

    altPowerBar:HookScript("OnShow", function()
        C_Timer.After(0, function() -- Next frame, toggling ui is too fast
            UpdatePRDBorderLayout()
            TweakPowerBarAnchor(PersonalResourceDisplayFrame)
            TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)
        end)
    end)
    altPowerBar:HookScript("OnHide", function()
        UpdatePRDBorderLayout()
        TweakPowerBarAnchor(PersonalResourceDisplayFrame)
        TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)
    end)

    TweakPowerBarAnchor(PersonalResourceDisplayFrame)
    TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)

    hooksecurefunc(PersonalResourceDisplayMixin, "UpdatePowerBarAnchor", TweakPowerBarAnchor)
    hooksecurefunc(PersonalResourceDisplayMixin, "UpdateAdditionalBarAnchors", TweakAdditionalBarAnchors)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        C_Timer.After(0, function()
            UpdatePRDBorderLayout()
            TweakPowerBarAnchor(PersonalResourceDisplayFrame)
            TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)
        end)
    end)
    BBP.FancyPRDAltTexture()
end