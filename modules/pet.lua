-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Main pet buff spell id's
local petValidSpellIDs = {
    [264662] = true,
    [264656] = true,
    [264663] = true,
    [284301] = true,
}

-- Pet Indicator
function BBP.PetIndicator(frame)
    local anchorPoint = BetterBlizzPlatesDB.petIndicatorAnchor or "CENTER"
    local xPos = BetterBlizzPlatesDB.petIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.petIndicatorYPos or 0

    -- Initialize
    if not frame.petIndicator then
        frame.petIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
        frame.petIndicator:SetSize(12, 12)
    end

    -- Set position and scale dynamically
    frame.petIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.petIndicator:SetScale(BetterBlizzPlatesDB.petIndicatorScale or 1)

    -- Test mode
    if BetterBlizzPlatesDB.petIndicatorTestMode then
        frame.petIndicator:Show()
        return
    end

    local unitGUID = UnitGUID(frame.displayedUnit)
    local npcID = select(6, strsplit("-", unitGUID or ""))
    
    -- Move Pet Indicator to the left if both Pet Indicator and Combat Indicator are showing with the same anchor so they dont overlap
    if frame.combatIndicator and frame.combatIndicator:IsShown() and BetterBlizzPlatesDB.combatIndicator and (BetterBlizzPlatesDB.petIndicatorAnchor == BetterBlizzPlatesDB.combatIndicatorAnchor) then
        xPos = xPos - 10
    end

    -- All hunter pets have same NPC id, check for it.
    if npcID == "165189" then
        for i = 1, 6 do -- Only loop through the first 5 buffs
            local _, _, _, _, _, _, _, _, _, spellID = UnitAura(frame.displayedUnit, i, "HELPFUL")
            if petValidSpellIDs[spellID] then
                frame.petIndicator:Show()
                return
            end
        end
    end

    -- If the conditions aren't met, hide the texture if it exists
    if frame.petIndicator then
        frame.petIndicator:Hide()
    end
end