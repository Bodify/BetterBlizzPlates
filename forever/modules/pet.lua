-- Main pet buff spell id's
local petValidSpellIDs = {
    [264662] = true,
    [264656] = true,
    [264663] = true,
    [284301] = true,
}

local function ShowMurloc(frame)
    if frame.bbpHiddenNPC then
        frame.bbpHiddenNPC = nil
    end
    frame:SetAlpha(1)
    frame.isMurloc = true
    frame.HealthBarsContainer:SetAlpha(0)
    frame.HealthBarsContainer.alphaZero = false
    frame.selectionHighlight:SetAlpha(0)
    BBP.SetNameplateAurasShown(frame, false)
    frame.name:SetAlpha(0)
    frame.murlocMode:Show()
    frame.castBar:Hide()
    frame.hideNameOverride = true
    frame.hideCastbarOverride = true
end

-- Pet Indicator
function BBP.PetIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo
    local db = BetterBlizzPlatesDB

    frame.mainPetColor = nil
    if frame.isMurloc then
        frame.hideCastInfo = false
        if frame.murlocMode then
            frame.murlocMode:Hide()
        end
        frame.hideNameOverride = false
        frame.hideCastbarOverride = false
        frame.isMurloc = false
    end

    if not frame.bbpAlphaHook then
        hooksecurefunc(frame, "SetAlpha", function(self)
            if not self.bbpHiddenNPC or self.changingAlpha or self:IsForbidden() then return end
            self.changingAlpha = true
            if self.unit and not BBP.TargetShowsHidden(self.unit) then
                self:SetAlpha(0)
            end
            self.changingAlpha = nil
        end)
        frame.bbpAlphaHook = true
    end

    if not config.petIndicatorInitialized or BBP.needsUpdate then
        config.petIndicatorAnchor = db.petIndicatorAnchor or "CENTER"
        config.petIndicatorXPos = db.petIndicatorXPos or 0
        config.petIndicatorYPos = db.petIndicatorYPos or 0
        config.petIndicatorTestMode = db.petIndicatorTestMode
        config.petIndicatorHideSecondaryPets = db.petIndicatorHideSecondaryPets
        config.petIndicatorScale = db.petIndicatorScale or 1
        config.petIndicatorShowMurloc = db.petIndicatorShowMurloc
        config.petIndicatorColorHealthbar = db.petIndicatorColorHealthbar
        config.petIndicatorColorHealthbarRGB = db.petIndicatorColorHealthbarRGB

        config.petIndicatorInitialized = true
    end

    -- Initialize
    if not frame.petIndicator then
        frame.petIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        frame.petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
        frame.petIndicator:SetSize(12, 12)
    end

    -- Set position and scale dynamically
    frame.petIndicator:SetPoint("CENTER", BBP.GetLevelSpanAnchor(frame, config.petIndicatorAnchor), config.petIndicatorAnchor, config.petIndicatorXPos, config.petIndicatorYPos)
    frame.petIndicator:SetScale(config.petIndicatorScale)

    -- Test mode
    if config.petIndicatorTestMode then
        frame.petIndicator:Show()
        return
    end

    local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)

    -- Demo lock pet
    if npcID == 17252 then
        if BBP.isInArena then
            local isRealPet = UnitIsUnit(frame.unit, "pet")
            for i = 1, 3 do
                if UnitIsUnit(frame.unit, "arenapet" .. i) or UnitIsUnit(frame.unit, "partypet" .. i) then
                    isRealPet = true
                    break
                end
            end
            if isRealPet then
                frame.petIndicator:Show()
            elseif config.petIndicatorHideSecondaryPets then
                if not BBP.TargetShowsHidden(frame.unit) then
                    if config.petIndicatorShowMurloc then
                        BBP.InitMurlocMode(frame, config, db)
                        ShowMurloc(frame)
                    else
                        frame.bbpHiddenNPC = true
                        frame:SetAlpha(0)
                    end
                end
            else
                frame.petIndicator:Hide()
            end
            return
        else
            frame.petIndicator:Show()
        end
        return
    end
    -- All hunter pets have same NPC id, check for it.
    if npcID == 165189 then
        if BBP.isInArena then
            local isRealPet = UnitIsUnit(frame.unit, "pet")
            for i = 1, 3 do
                if UnitIsUnit(frame.unit, "arenapet" .. i) or UnitIsUnit(frame.unit, "partypet" .. i) then
                    isRealPet = true
                    break
                end
            end
            if isRealPet then
                if config.petIndicatorColorHealthbar then
                    frame.mainPetColor = config.petIndicatorColorHealthbarRGB
                    frame.healthBar:SetStatusBarColor(unpack(frame.mainPetColor))
                    frame.needsRecolor = true
                end
                frame.petIndicator:Show()
                return
            else
                frame.petIndicator:Hide()
            end
            if config.petIndicatorHideSecondaryPets and not isRealPet then
                if not BBP.TargetShowsHidden(frame.unit) then
                    if config.petIndicatorShowMurloc then
                        BBP.InitMurlocMode(frame, config, db)
                        ShowMurloc(frame)
                    else
                        frame.bbpHiddenNPC = true
                        frame:SetAlpha(0)
                    end
                end
            end
        else
            local isValidPet = false
            for i = 1, 6 do -- Only loop through the first 5 buffs
                local aura = C_UnitAuras.GetAuraDataByIndex(frame.displayedUnit, i, "HELPFUL")
                local spellID = aura and aura.spellId
                if petValidSpellIDs[spellID] then
                    isValidPet = true
                    break
                end
            end
            if isValidPet then
                if config.petIndicatorColorHealthbar then
                    frame.mainPetColor = config.petIndicatorColorHealthbarRGB
                    frame.healthBar:SetStatusBarColor(unpack(frame.mainPetColor))
                    frame.needsRecolor = true
                end
                frame.petIndicator:Show()
                return
            elseif config.petIndicatorHideSecondaryPets and info.isEnemy then
                if not BBP.TargetShowsHidden(frame.unit) then
                    if config.petIndicatorShowMurloc then
                        BBP.InitMurlocMode(frame, config, db)
                        ShowMurloc(frame)
                    else
                        frame.bbpHiddenNPC = true
                        frame:SetAlpha(0)
                    end
                end
            end
        end
    end

    if config.petIndicatorHideSecondaryPets and BBP.secondaryPets[npcID] and info.isEnemy then
        if not BBP.TargetShowsHidden(frame.unit) then
            if config.petIndicatorShowMurloc then
                BBP.InitMurlocMode(frame, config, db)
                ShowMurloc(frame)
            else
                frame.bbpHiddenNPC = true
                frame:SetAlpha(0)
            end
        end
    end

    -- If the conditions aren't met, hide the texture if it exists
    if frame.petIndicator then
        frame.petIndicator:Hide()
    end
end

function BBP.HideOtherPet(frame)
    if not frame.bbpOtherPetAlphaHook then
        hooksecurefunc(frame, "SetAlpha", function(self)
            if not self.bbpHiddenOtherPet or self.changingAlpha or self:IsForbidden() then return end
            self.changingAlpha = true
            self:SetAlpha(0)
            self.changingAlpha = nil
        end)
        frame.bbpOtherPetAlphaHook = true
    end

    local unit = frame.unit
    local info = frame.BetterBlizzPlates and frame.BetterBlizzPlates.unitInfo
    local hide = BetterBlizzPlatesDB.friendlyHideOtherPets and unit and info
        and (info.isFriend or info.isFriendlyNpc)
        and (UnitIsOtherPlayersPet(unit)
            or (BetterBlizzPlatesDB.friendlyHideOwnSecondaryPets and UnitIsOwnerOrControllerOfUnit("player", unit) and not UnitIsUnit(unit, "pet")))
        and not BBP.TargetShowsHidden(unit)

    if hide then
        frame.bbpHiddenOtherPet = true
        frame.hideCastbarOverride = true
        frame.castBar:Hide()
        frame:SetAlpha(0)
    elseif frame.bbpHiddenOtherPet then
        frame.bbpHiddenOtherPet = nil
        frame.hideCastbarOverride = false
        frame:SetAlpha(1)
    end
end
