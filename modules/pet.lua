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

-- Pet Indicator
function BBP.PetIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    local nameplate = frame:GetParent()

    if not config.petIndicatorInitialized or BBP.needsUpdate then
        config.petIndicatorAnchor = BetterBlizzPlatesDB.petIndicatorAnchor or "CENTER"
        config.petIndicatorXPos = BetterBlizzPlatesDB.petIndicatorXPos or 0
        config.petIndicatorYPos = BetterBlizzPlatesDB.petIndicatorYPos or 0
        config.petIndicatorTestMode = BetterBlizzPlatesDB.petIndicatorTestMode
        config.combatIndicator = BetterBlizzPlatesDB.combatIndicator
        config.combatIndicatorAnchor = BetterBlizzPlatesDB.combatIndicatorAnchor
        config.petIndicatorOnlyShowMainPet = BetterBlizzPlatesDB.petIndicatorOnlyShowMainPet
        config.petIndicatorScale = BetterBlizzPlatesDB.petIndicatorScale or 1

        config.petIndicatorInitialized = true
    end

    -- Initialize
    if not frame.petIndicator then
        frame.petIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        frame.petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
        frame.petIndicator:SetSize(12, 12)
    end

    if shadows[nameplate] then
        nameplate:SetParent(shadows[nameplate])
        shadows[nameplate] = nil
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
        frame.petIndicator:Show()
        return
    end
    -- All hunter pets have same NPC id, check for it.
    if npcID == "165189" then
        for i = 1, 6 do -- Only loop through the first 5 buffs
            local _, _, _, _, _, _, _, _, _, spellID = BBP.TWWUnitAura(frame.displayedUnit, i, "HELPFUL")
            if petValidSpellIDs[spellID] then
                frame.petIndicator:Show()
                return
            elseif config.petIndicatorOnlyShowMainPet then
                if not UnitIsUnit(frame.unit, "target") then
                    shadows[nameplate] = nameplate
                    nameplate:SetParent(shadowRealm)
                end
            end
        end
    end

    -- If the conditions aren't met, hide the texture if it exists
    if frame.petIndicator then
        frame.petIndicator:Hide()
    end
end