-- Main pet buff spell id's
local petValidSpellIDs = {
    [264662] = true,
    [264656] = true,
    [264663] = true,
    [284301] = true,
}

local cataHunterPets = {
    ["43417"] = true, -- Monkey
    ["525"] = true, -- Wolf
    ["1713"] = true, -- Cat
    ["45582"] = true, -- Spider
}

-- Pet Indicator
function BBP.PetIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.petIndicatorInitialized or BBP.needsUpdate then
        config.petIndicatorAnchor = BetterBlizzPlatesDB.petIndicatorAnchor or "CENTER"
        config.petIndicatorXPos = BetterBlizzPlatesDB.petIndicatorXPos or 0
        config.petIndicatorYPos = BetterBlizzPlatesDB.petIndicatorYPos or 0
        config.petIndicatorTestMode = BetterBlizzPlatesDB.petIndicatorTestMode
        config.petIndicatorHideSecondaryPets = BetterBlizzPlatesDB.petIndicatorHideSecondaryPets
        config.petIndicatorScale = BetterBlizzPlatesDB.petIndicatorScale or 1

        config.petIndicatorInitialized = true
    end

    -- Initialize
    if not frame.petIndicator then
        frame.petIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
        frame.petIndicator:SetSize(12, 12)
    end

    -- Set position and scale dynamically
    frame.petIndicator:SetPoint("CENTER", frame.healthBar, config.petIndicatorAnchor, config.petIndicatorXPos, config.petIndicatorYPos)
    frame.petIndicator:SetScale(config.petIndicatorScale)

    -- Test mode
    if config.petIndicatorTestMode then
        frame.petIndicator:Show()
        return
    end

    local npcID = BBP.GetNPCIDFromGUID(info.unitGUID)

    -- Demo lock pet
    if npcID == 17252 then
        frame.petIndicator:Show()
        return
    end
    -- All hunter pets have same NPC id, check for it.
    if UnitIsOtherPlayersPet(frame.unit) or UnitIsUnit("pet", frame.unit) then
        frame.petIndicator:Show()
        return
    end

    -- If the conditions aren't met, hide the texture if it exists
    if frame.petIndicator then
        frame.petIndicator:Hide()
    end
end