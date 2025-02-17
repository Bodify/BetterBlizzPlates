-- Main pet buff spell id's
local petValidSpellIDs = {
    [264662] = true,
    [264656] = true,
    [264663] = true,
    [284301] = true,
}

local shadowRealm = CreateFrame("Frame")
shadowRealm:Hide()
local shadows = {}

local function ShowMurloc(frame, nameplate)
    frame.HealthBarsContainer:SetAlpha(0)
    frame.selectionHighlight:SetAlpha(0)
    frame.BuffFrame:SetAlpha(0)
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

    local nameplate = frame:GetParent()

    if shadows[nameplate] then
        nameplate:SetParent(WorldFrame)
        shadows[nameplate] = nil
        frame.hideCastInfo = false
        if frame.murlocMode then
            frame.murlocMode:Hide()
        end
        frame.hideNameOverride = false
        frame.hideCastbarOverride = false
    end

    if not config.petIndicatorInitialized or BBP.needsUpdate then
        config.petIndicatorAnchor = db.petIndicatorAnchor or "CENTER"
        config.petIndicatorXPos = db.petIndicatorXPos or 0
        config.petIndicatorYPos = db.petIndicatorYPos or 0
        config.petIndicatorTestMode = db.petIndicatorTestMode
        config.combatIndicator = db.combatIndicator
        config.combatIndicatorAnchor = db.combatIndicatorAnchor
        config.petIndicatorHideSecondaryPets = db.petIndicatorHideSecondaryPets
        config.petIndicatorScale = db.petIndicatorScale or 1
        config.petIndicatorShowMurloc = db.petIndicatorShowMurloc

        config.petIndicatorInitialized = true
    end

    -- Initialize
    if not frame.petIndicator then
        frame.petIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        frame.petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
        frame.petIndicator:SetSize(12, 12)
    end

    local combatIndicator = (frame.combatIndicatorSap or frame.combatIndicator) and not config.combatIndicatorPlayersOnly

    -- Move Pet Indicator to the left if both Pet Indicator and Combat Indicator are showing with the same anchor so they dont overlap
    local combatOffset = 0
    if combatIndicator and not UnitAffectingCombat(frame.unit) and (config.petIndicatorAnchor == config.combatIndicatorAnchor) then
        combatOffset = 5
    end

    -- Set position and scale dynamically
    frame.petIndicator:SetPoint("CENTER", frame.healthBar, config.petIndicatorAnchor, config.petIndicatorXPos-combatOffset, config.petIndicatorYPos)
    frame.petIndicator:SetScale(config.petIndicatorScale)

    -- Test mode
    if config.petIndicatorTestMode then
        frame.petIndicator:Show()
        return
    end

    local npcID = select(6, strsplit("-", info.unitGUID or ""))

    -- Demo lock pet
    if npcID == "17252" then
        if BBP.isInArena then
            local isRealPet = false
            for i = 1, 3 do
                if UnitIsUnit(frame.unit, "arenapet" .. i) then
                    isRealPet = true
                    break
                end
            end
            if isRealPet then
                frame.petIndicator:Show()
            elseif config.petIndicatorHideSecondaryPets then
                if not UnitIsUnit(frame.unit, "target") then
                    if config.petIndicatorShowMurloc then
                        BBP.InitMurlocMode(frame, config, db)
                        ShowMurloc(frame, nameplate)
                    elseif not shadows[nameplate] then
                        shadows[nameplate] = true
                        nameplate:SetParent(shadowRealm)
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
    if npcID == "165189" then
        if BBP.isInArena and info.isEnemy then
            local isRealPet = false
            for i = 1, 3 do
                if UnitIsUnit(frame.unit, "arenapet" .. i) then
                    isRealPet = true
                    break
                end
            end
            if isRealPet then
                frame.petIndicator:Show()
                return
            else
                frame.petIndicator:Hide()
            end
            if config.petIndicatorHideSecondaryPets and not isRealPet then
                if not UnitIsUnit(frame.unit, "target") then
                    if config.petIndicatorShowMurloc then
                        BBP.InitMurlocMode(frame, config, db)
                        ShowMurloc(frame, nameplate)
                    elseif not shadows[nameplate] then
                        shadows[nameplate] = true
                        nameplate:SetParent(shadowRealm)
                    end
                end
            end
        else
            local isValidPet = false
            for i = 1, 6 do -- Only loop through the first 5 buffs
                local _, _, _, _, _, _, _, _, _, spellID = BBP.TWWUnitAura(frame.displayedUnit, i, "HELPFUL")
                if petValidSpellIDs[spellID] then
                    isValidPet = true
                    break
                end
            end
            if isValidPet then
                frame.petIndicator:Show()
                return
            elseif config.petIndicatorHideSecondaryPets and info.isEnemy then
                if not UnitIsUnit(frame.unit, "target") then
                    if config.petIndicatorShowMurloc then
                        BBP.InitMurlocMode(frame, config, db)
                        ShowMurloc(frame, nameplate)
                    elseif not shadows[nameplate] then
                        shadows[nameplate] = true
                        nameplate:SetParent(shadowRealm)
                    end
                end
            end
        end
    end

    if config.petIndicatorHideSecondaryPets and BBP.secondaryPets[npcID] and info.isEnemy then
        if not UnitIsUnit(frame.unit, "target") then
            if config.petIndicatorShowMurloc then
                BBP.InitMurlocMode(frame, config, db)
                ShowMurloc(frame, nameplate)
            elseif not shadows[nameplate] then
                shadows[nameplate] = true
                nameplate:SetParent(shadowRealm)
            end
        end
    end

    -- If the conditions aren't met, hide the texture if it exists
    if frame.petIndicator then
        frame.petIndicator:Hide()
    end
end