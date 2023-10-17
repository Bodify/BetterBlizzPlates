BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Table with spec IDs
local specIDToName = {
    -- Death Knight
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    -- Demon Hunter
    [577] = "Havoc", [581] = "Vengeance",
    -- Druid
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Restoration",
    -- Evoker
    [1467] = "Devastation", [1468] = "Preservation", [1473] = "Augmentation",
    -- Hunter
    [253] = "BeastMaster", [254] = "Marksman", [255] = "Survival",
    -- Mage
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    -- Monk
    [268] = "Brewmaster", [270] = "Mistweaver", [269] = "Windwalker",
    -- Paladin
    [65] = "Holy", [66] = "Protection", [70] = "Retribution",
    -- Priest
    [256] = "Discipline", [257] = "Holy", [258] = "Shadow",
    -- Rogue
    [259] = "Assasination", [260] = "Outlaw", [261] = "Subtlety",
    -- Shaman
    [262] = "Elemental", [263] = "Enhancement", [264] = "Restoration",
    -- Warlock
    [265] = "Affliction", [266] = "Demonology", [267] = "Destruction",
    -- Warrior
    [71] = "Arms", [72] = "Fury", [73] = "Protection",
}

-- Arena Indicator for Arena Units
-- Mode 1: Replace name with ID
function BBP.ArenaIndicator1(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"arena"..i) then
                local r, g, b, a = 1, 1, 0, 1
                if BetterBlizzPlatesDB.enemyClassColorName then
                    r, g, b, a = frame.name:GetTextColor()
                end

                if not frame.arenaNumberText then 
                    frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 0)
                frame.arenaNumberText:SetText(i)
                if BetterBlizzPlatesDB.enemyClassColorName then
                    frame.arenaNumberText:SetTextColor(r, g, b, a)
                else
                    frame.arenaNumberText:SetTextColor(1, 1, 0)
                end
                frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
                break
            end
        end
    end
end

-- Mode 2: Put ID on top of name
function BBP.ArenaIndicator2(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"arena"..i) then
                local r, g, b, a = frame.name:GetTextColor()

                if not frame.arenaNumberText then 
                    frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
                end

                frame.arenaNumberText:SetText(i)
                if BetterBlizzPlatesDB.enemyClassColorName then
                    frame.arenaNumberText:SetTextColor(r, g, b, a)
                else
                    frame.arenaNumberText:SetTextColor(1, 1, 0)
                end
                frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
                frame.arenaNumberText:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
                break
            end
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.ArenaIndicator3(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"arena"..i) then
                local specID = GetArenaOpponentSpec(i)
                local specName = specID and specIDToName[specID]
                local r, g, b, a = frame.name:GetTextColor()
                local _, className = UnitClass("arena"..i)

                if not specName then
                    specName = className
                end

                if not frame.specNameText then
                    frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.specNameText:SetText(specName)
                frame.specNameText:SetTextColor(r, g, b, a)
                frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
                frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
                break
            end
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.ArenaIndicator4(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"arena"..i) then
                local r, g, b, a = frame.name:GetTextColor()
                local specID = GetArenaOpponentSpec(i)
                local specName = specID and specIDToName[specID]
                local _, className = UnitClass("arena"..i)

                if not specName then
                    specName = className
                end

                if not frame.specNameText then
                    frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
                end

                if not frame.arenaNumberText then 
                    frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.specNameText:SetText(specName)
                frame.specNameText:SetTextColor(r, g, b, a)
                frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
                frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
                frame.arenaNumberText:SetText(i)
                if BetterBlizzPlatesDB.enemyClassColorName then
                    frame.arenaNumberText:SetTextColor(r, g, b, a)
                else
                    frame.arenaNumberText:SetTextColor(1, 1, 0)
                end
                frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
                frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, "TOP", 0, -1)
                break
            end
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.ArenaIndicator5(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"arena"..i) then
                local r, g, b, a = frame.name:GetTextColor()
                local specID = GetArenaOpponentSpec(i)
                local specName = specID and specIDToName[specID]
                local _, className = UnitClass("arena"..i)

                if not specName then
                    specName = className
                end

                if not frame.specNameText then
                    frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.specNameText:SetText(i .. " " .. specName)
                frame.specNameText:SetTextColor(r, g, b, a)
                frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
                frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
                break
            end
        end
    end
end




--#################################################################################
-- Party version
-- Mode 1: Replace name with ID
function BBP.PartyIndicator1(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"party"..i) then
                local r, g, b, a = frame.name:GetTextColor()

                if not frame.arenaNumberText then 
                    frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 0)
                frame.arenaNumberText:SetText(i)
                frame.arenaNumberText:SetTextColor(r, g, b, a)
                frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
                break
            end
        end
    end
end

-- Mode 2: Put ID on top of name
function BBP.PartyIndicator2(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"party"..i) then
                local r, g, b, a = frame.name:GetTextColor()

                if not frame.arenaNumberText then 
                    frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
                end

                frame.arenaNumberText:SetText(i)
                frame.arenaNumberText:SetTextColor(r, g, b, a)
                frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
                frame.arenaNumberText:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
                break
            end
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.PartyIndicator3(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"party"..i) then
                local specID
                local Details = Details
                if Details and Details.realversion >= 134 then
                    local unitGUID = UnitGUID(frame.unit)
                    specID = Details:GetSpecByGUID(unitGUID)
                end
                local specName = specID and specIDToName[specID]
                local r, g, b, a = frame.name:GetTextColor()
                local _, className = UnitClass("party"..i)

                if not specName then
                    specName = className
                end

                if not frame.specNameText then
                    frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.specNameText:SetText(specName)
                frame.specNameText:SetTextColor(r, g, b, a)
                frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
                frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
                break
            end
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.PartyIndicator4(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"party"..i) then
                local r, g, b, a = frame.name:GetTextColor()
                local specID
                local Details = Details
                if Details and Details.realversion >= 134 then
                    local unitGUID = UnitGUID(frame.unit)
                    specID = Details:GetSpecByGUID(unitGUID)
                end
                local specName = specID and specIDToName[specID]
                local _, className = UnitClass("party"..i)

                if not specName then
                    specName = className
                end

                if not frame.specNameText then
                    frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
                end

                if not frame.arenaNumberText then 
                    frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.specNameText:SetText(specName)
                frame.specNameText:SetTextColor(r, g, b, a)
                frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
                frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
                frame.arenaNumberText:SetText(i)
                frame.arenaNumberText:SetTextColor(r, g, b, a)
                frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
                frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, "TOP", 0, -1)
                break
            end
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.PartyIndicator5(frame)
    if IsActiveBattlefieldArena() then
        for i=1,3 do
            if UnitIsUnit(frame.unit,"party"..i) then
                local r, g, b, a = frame.name:GetTextColor()
                local specID
                local Details = Details
                if Details and Details.realversion >= 134 then
                    local unitGUID = UnitGUID(frame.unit)
                    specID = Details:GetSpecByGUID(unitGUID)
                end
                local specName = specID and specIDToName[specID]
                local _, className = UnitClass("party"..i)

                if not specName then
                    specName = className
                end

                if not frame.specNameText then
                    frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                    BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
                end

                frame.name:SetText("")
                frame.specNameText:SetText(i .. " " .. specName)
                frame.specNameText:SetTextColor(r, g, b, a)
                frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
                frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
                break
            end
        end
    end
end




--#########################################################################################################
-- Test modes
-- If no mode selected
function BBP.TestArenaIndicator0(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction("player", frame.unit) or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            frame.arenaNumberText:SetText("Select a mode to test (enemy)")
            frame.arenaNumberText:SetTextColor(r, g, b, a)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            break
        end
    end
end
-- Mode 1: Replace name with ID
function BBP.TestArenaIndicator1(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction("player", frame.unit) or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 0)
            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, a)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
            break
        end
    end
end

-- Mode 2: Put ID on top of name
function BBP.TestArenaIndicator2(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction("player", frame.unit) or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, a)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
            break
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.TestArenaIndicator3(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction("player", frame.unit) or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.specNameText then
                frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.specNameText:SetText("Spectest")
            frame.specNameText:SetTextColor(r, g, b, a)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            break
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.TestArenaIndicator4(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction("player", frame.unit) or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.specNameText then
                frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
            end

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.specNameText:SetText("Spectest")
            frame.specNameText:SetTextColor(r, g, b, a)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            frame.arenaNumberText:SetText("1")
            if BetterBlizzPlatesDB.enemyClassColorName then
                frame.arenaNumberText:SetTextColor(r, g, b, a)
            else
                frame.arenaNumberText:SetTextColor(1, 1, 0)
            end
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.arenaIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, "TOP", 0, -1)
            break
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.TestArenaIndicator5(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if not UnitIsFriend("player", frame.unit) and (UnitReaction("player", frame.unit) or 0) < 5 then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.specNameText then
                frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.specNameText:SetText("1" .. " " .. "Spectest")
            frame.specNameText:SetTextColor(r, g, b, a)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.arenaSpecScale)
            frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            break
        end
    end
end


-- Mode 0: Replace name with ID
function BBP.TestPartyIndicator0(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            frame.arenaNumberText:SetText("Select a mode to test (friendly)")
            frame.arenaNumberText:SetTextColor(r, g, b, a)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            break
        end
    end
end

-- Mode 1: Replace name with ID 
function BBP.TestPartyIndicator1(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.arenaNumberText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 0)
            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, a)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
            break
        end
    end
end


-- Mode 2: Put ID on top of name
function BBP.TestPartyIndicator2(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, a)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
            break
        end
    end
end

-- Mode 3: Replace name with Spec
function BBP.TestPartyIndicator3(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.specNameText then
                frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.specNameText:SetText("Spectest")
            frame.specNameText:SetTextColor(r, g, b, a)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            break
        end
    end
end

-- Mode 4: Replace name with spec and ID on top
function BBP.TestPartyIndicator4(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.specNameText then
                frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
            end

            if not frame.arenaNumberText then 
                frame.arenaNumberText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.arenaNumberText, 15, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.specNameText:SetText("Spectest")
            frame.specNameText:SetTextColor(r, g, b, a)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            frame.arenaNumberText:SetText("2")
            frame.arenaNumberText:SetTextColor(r, g, b, a)
            frame.arenaNumberText:SetScale(BetterBlizzPlatesDB.partyIDScale)
            frame.arenaNumberText:SetPoint("BOTTOM", frame.specNameText, "TOP", 0, -1)
            break
        end
    end
end

-- Mode 5: Put ID and Spec on same line instead of name
function BBP.TestPartyIndicator5(frame)
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if UnitIsFriend("player", frame.unit) then
            local r, g, b, a = frame.name:GetTextColor()

            if not frame.specNameText then
                frame.specNameText = frame:CreateFontString(nil, "BACKGROUND")
                BBP.SetFontBasedOnOption(frame.specNameText, 12, "THINOUTLINE")
            end

            frame.name:SetText("")
            frame.specNameText:SetText("2" .. " " .. "Spectest")
            frame.specNameText:SetTextColor(r, g, b, a)
            frame.specNameText:SetScale(BetterBlizzPlatesDB.partySpecScale)
            frame.specNameText:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
            break
        end
    end
end



--#########################################################################################################
-- The big consolidated caller
function BBP.ArenaIndicatorCaller(frame, config)
    if BetterBlizzPlatesDB.arenaIndicatorTestMode then
        local unitType
        if UnitIsEnemy("player", frame.unit) or (UnitReaction("player", frame.unit) or 0) < 5 then
            unitType = "arena"
        else
            unitType = "party"
        end

        -- Test modes
        if unitType == "arena" then
            if config.arenaIndicatorModeOff or 
               (not config.arenaIndicatorModeOne and 
                not config.arenaIndicatorModeTwo and 
                not config.arenaIndicatorModeThree and 
                not config.arenaIndicatorModeFour and 
                not config.arenaIndicatorModeFive) then
                BBP.TestArenaIndicator0(frame)
            elseif config.arenaIndicatorModeOne then
                BBP.TestArenaIndicator1(frame)
            elseif config.arenaIndicatorModeTwo then
                BBP.TestArenaIndicator2(frame)
            elseif config.arenaIndicatorModeThree then
                BBP.TestArenaIndicator3(frame)
            elseif config.arenaIndicatorModeFour then
                BBP.TestArenaIndicator4(frame)
            elseif config.arenaIndicatorModeFive then
                BBP.TestArenaIndicator5(frame)
            end
        elseif unitType == "party" then
            if config.partyIndicatorModeOff or 
               (not config.partyIndicatorModeOne and 
                not config.partyIndicatorModeTwo and 
                not config.partyIndicatorModeThree and 
                not config.partyIndicatorModeFour and 
                not config.partyIndicatorModeFive) then
                BBP.TestPartyIndicator0(frame)
            elseif config.partyIndicatorModeOne then
                BBP.TestPartyIndicator1(frame)
            elseif config.partyIndicatorModeTwo then
                BBP.TestPartyIndicator2(frame)
            elseif config.partyIndicatorModeThree then
                BBP.TestPartyIndicator3(frame)
            elseif config.partyIndicatorModeFour then
                BBP.TestPartyIndicator4(frame)
            elseif config.partyIndicatorModeFive then
                BBP.TestPartyIndicator5(frame)
            end
        end
    end

    -- Arena and party logic
    if IsActiveBattlefieldArena() then
        local unitType
        if UnitIsEnemy("player", frame.unit) then
            unitType = "arena"
        else
            unitType = "party"
        end        

        if unitType == "arena" then
            if not config.arenaIndicatorModeOff then
                if config.arenaIndicatorModeOne then
                    BBP.ArenaIndicator1(frame)
                elseif config.arenaIndicatorModeTwo then
                    BBP.ArenaIndicator2(frame)
                elseif config.arenaIndicatorModeThree then
                    BBP.ArenaIndicator3(frame)
                elseif config.arenaIndicatorModeFour then
                    BBP.ArenaIndicator4(frame)
                elseif config.arenaIndicatorModeFive then
                    BBP.ArenaIndicator5(frame)
                end
            end
        elseif unitType == "party" then
            if not config.partyIndicatorModeOff then
                if config.partyIndicatorModeOne then
                    BBP.PartyIndicator1(frame)
                elseif config.partyIndicatorModeTwo then
                    BBP.PartyIndicator2(frame)
                elseif config.partyIndicatorModeThree then
                    BBP.PartyIndicator3(frame)
                elseif config.partyIndicatorModeFour then
                    BBP.PartyIndicator4(frame)
                elseif config.partyIndicatorModeFive then
                    BBP.PartyIndicator5(frame)
                end
            end
        end
    end
end

-- Refresh nameplates between solo shuffle rounds (sometimes id and spec text stick)
local refresh = CreateFrame("Frame")
refresh:RegisterEvent("GROUP_ROSTER_UPDATE")
refresh:SetScript("OnEvent", function(self, event, ...)
    if not InCombatLockdown() then
        BBP.RefreshAllNameplates()
    end
end)