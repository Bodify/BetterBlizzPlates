-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

----------------------------------------------------
---- Aura Function Copied From RSPlates and edited by me
----------------------------------------------------

local function FetchSpellName(spellId)
    local spellName, _, _ = GetSpellInfo(spellId)
    return spellName
end

local fakeAuras = {
    -- 6 Fake Debuffs
    {
        auraInstanceID = "777",
        spellId = 201,
        icon = "interface/icons/spell_shadow_shadowwordpain",
        duration = 30,
        isHarmful = true,
        applications = 1,
    },
    {
        auraInstanceID = "778",
        spellId = 202,
        icon = "interface/icons/spell_shadow_curseofsargeras",
        duration = 18,
        isHarmful = true,
        applications = 18,
    },
    {
        auraInstanceID = "779",
        spellId = 203,
        icon = "interface/icons/spell_frost_frostnova",
        duration = 10,
        isHarmful = true,
        applications = 1,
    },
    {
        auraInstanceID = "780",
        spellId = 204,
        icon = 132092,
        duration = 22,
        applications = 1,
        isHarmful = true,
    },
    {
        auraInstanceID = "781",
        spellId = 205,
        icon = 135978,
        duration = 24,
        isHarmful = true,
        applications = 1,
    },
    {
        auraInstanceID = "782",
        spellId = 206,
        icon = "interface/icons/spell_shadow_plaguecloud",
        duration = 16,
        isHarmful = true,
        applications = 3,
    },
    -- 5 Fake Buffs
    {
        auraInstanceID = "666",
        spellId = 101,
        icon = "interface/icons/spell_nature_regeneration",
        duration = 20,
        isHelpful = true,
        applications = 1,
        isStealable = true,
    },
    {
        auraInstanceID = "667",
        spellId = 102,
        icon = 132341,
        duration = 0,
        expirationTime = 0,
        isHelpful = true,
        applications = 1,
    },
    {
        auraInstanceID = "668",
        spellId = 103,
        icon = "interface/icons/spell_holy_flashheal",
        duration = 25,
        isHelpful = true,
        applications = 2,
    },
    {
        auraInstanceID = "669",
        spellId = 104,
        icon = 132144,
        duration = 0,
        expirationTime = 0,
        isHelpful = true,
        applications = 1,
    },
    {
        auraInstanceID = "670",
        spellId = 105,
        icon = 135939,
        duration = 15,
        isHelpful = true,
        applications = 1,
        isStealable = true,
    },
}

local function isInWhitelist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            return true
        end
    end
    return false
end

local function isInBlacklist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraBlacklist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            return true
        end
    end
    return false
end

local function GetAuraDetails(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            local isImportant = entry.flags and entry.flags.important or false
            local isPandemic = entry.flags and entry.flags.pandemic or false
            local auraColor = entry.entryColors and entry.entryColors.text or nil
            local onlyMine = entry.flags and entry.flags.onlyMine or false
            return true, isImportant, isPandemic, auraColor, onlyMine
        end
    end
    return false, false, false, false, false
end

local trackedBuffs = {};
local checkBuffsTimer = nil;

local function StopCheckBuffsTimer()
    if checkBuffsTimer then
        checkBuffsTimer:Cancel();
        checkBuffsTimer = nil;
    end
end

local function CheckBuffs()
    local currentGameTime = GetTime();
    for auraInstanceID, buff in pairs(trackedBuffs) do
        if buff.isPandemic and buff.expirationTime then
            local remainingDuration = buff.expirationTime - currentGameTime;
            if remainingDuration <= 0 then
                trackedBuffs[auraInstanceID] = nil;
                if buff.PandemicGlow then
                    buff.PandemicGlow:Hide();
                end
                buff.isPandemicActive = false
            elseif remainingDuration <= 5.1 then
                if not buff.PandemicGlow then
                    buff.PandemicGlow = buff:CreateTexture(nil, "OVERLAY");
                    buff.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen");
                    buff.PandemicGlow:SetDesaturated(true)
                    buff.PandemicGlow:SetVertexColor(1, 0, 0)
                    if buff.Cooldown and buff.Cooldown:IsVisible() then
                        buff.PandemicGlow:SetParent(buff.Cooldown)
                    end
                    if BetterBlizzPlatesDB.nameplateAuraSquare then
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10);
                    elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10.5, 8);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10.5, -8);
                    else
                        buff.PandemicGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10.5, 7.5);
                        buff.PandemicGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10.5, -7.5);
                    end
                end
                buff.isPandemicActive = true
                buff.PandemicGlow:Show();
            else
                if buff.PandemicGlow then
                    buff.PandemicGlow:Hide();
                end
                buff.isPandemicActive = false
            end
        else
            buff.isPandemicActive = false
            for auraInstanceID, _ in pairs(trackedBuffs) do
                trackedBuffs[auraInstanceID] = nil
            end
        end
    end
    if next(trackedBuffs) == nil then
        StopCheckBuffsTimer();
    end
end

local function StartCheckBuffsTimer()
    if not checkBuffsTimer then
        checkBuffsTimer = C_Timer.NewTicker(0.1, CheckBuffs);
    end
end

function CustomBuffLayoutChildren(container, children, isEnemyUnit)
    -- Obtain the health bar details
    local healthBar = container:GetParent().healthBar
    local healthBarWidth = healthBar:GetWidth()

    -- Define the spacing and row parameters
    local horizontalSpacing = BetterBlizzPlatesDB.nameplateAuraWidthGap
    local verticalSpacing = -28 - BetterBlizzPlatesDB.nameplateAuraHeightGap - (BetterBlizzPlatesDB.nameplateAuraSquare and 12 or 0) - (BetterBlizzPlatesDB.nameplateAuraTaller and 3 or 0)
    local maxBuffsPerRow = BetterBlizzPlatesDB.nameplateAuraRowAmount
    local maxRowHeight = 0
    local rowWidths = {}
    local totalChildrenHeight = 0

    -- Separate buffs and debuffs if needed
    local buffs = {}
    local debuffs = {}
    if BetterBlizzPlatesDB.separateAuraBuffRow then
        for _, buff in ipairs(children) do
            if buff.isBuff then
                table.insert(buffs, buff)
            else
                table.insert(debuffs, buff)
            end
        end
    else
        buffs = children  -- Treat all as buffs for the unified layout
        debuffs = {}  -- No debuffs in this mode
    end

    -- Calculate the width of each row
    local function CalculateRowWidths(auras)
        local widths = {}
        for index, buff in ipairs(auras) do
            buff:SetScale(BetterBlizzPlatesDB.nameplateAuraScale)
            local buffWidth, _ = buff:GetSize()

            if container.respectChildScale then
                local buffScale = buff:GetScale()
                buffWidth = buffWidth * buffScale
            end

            local rowIndex = math.floor((index - 1) / maxBuffsPerRow) + 1
            widths[rowIndex] = (widths[rowIndex] or 0) + buffWidth

            if index % maxBuffsPerRow ~= 1 then
                widths[rowIndex] = widths[rowIndex] + horizontalSpacing
            end
        end
        return widths
    end

    -- Function to layout auras
    local function LayoutAuras(auras, startRow)
        local currentRow = startRow
        local horizontalOffset = 0
        local firstRowFirstAuraOffset = nil  -- Variable to store the horizontal offset of the first aura in the first row
        local nameplateAurasFriendlyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor and not isEnemyUnit
        local nameplateAurasEnemyCenteredAnchor = BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor and isEnemyUnit
        local nameplateCenterAllRows = BetterBlizzPlatesDB.nameplateCenterAllRows and (nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor)
        local xPos = BetterBlizzPlatesDB.nameplateAurasXPos

        for index, buff in ipairs(auras) do
            local buffWidth, buffHeight = buff:GetSize()

            -- Update the maximum row height
            maxRowHeight = math.max(maxRowHeight, buffHeight)

            -- Determine if it's the start of a new row
            if index % maxBuffsPerRow == 1 then
                local rowIndex = math.floor((index - 1) / maxBuffsPerRow) + 1

                if nameplateCenterAllRows then
                    horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                elseif nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
                    if rowIndex == 1 then
                        horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                        firstRowFirstAuraOffset = horizontalOffset  -- Save this offset for the first aura
                    else
                        horizontalOffset = firstRowFirstAuraOffset or 0  -- Use the saved offset for the first aura of subsequent rows
                    end
                else
                    horizontalOffset = 0  -- or any other default starting offset
                end

                if index > 1 then
                    currentRow = currentRow + 1  -- Move to the next row
                end
            end

            -- Position the buff on the nameplate
            buff:ClearAllPoints()
            local verticalOffset = -currentRow * (maxRowHeight + (currentRow > 0 and verticalSpacing or 0))

            if nameplateAurasFriendlyCenteredAnchor or nameplateAurasEnemyCenteredAnchor then
                buff:SetPoint("BOTTOM", container, "TOP", horizontalOffset - healthBarWidth / 2 + 10 + xPos, verticalOffset - 13)
            else
                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", horizontalOffset + xPos, verticalOffset - 13)
            end
            horizontalOffset = horizontalOffset + buffWidth + horizontalSpacing
        end

        return currentRow
    end

    -- Layout logic
    local lastRow = 0
    if BetterBlizzPlatesDB.separateAuraBuffRow then
        if #debuffs > 0 then
            rowWidths = CalculateRowWidths(debuffs)
            lastRow = LayoutAuras(debuffs, 0)
        end

        rowWidths = CalculateRowWidths(buffs)
        LayoutAuras(buffs, lastRow + (#debuffs > 0 and 1 or 0))
    else
        rowWidths = CalculateRowWidths(buffs)
        lastRow = LayoutAuras(buffs, 0)
    end

    -- Calculate total children height
    totalChildrenHeight = (lastRow + 1) * (maxRowHeight + verticalSpacing)

    return totalChildrenWidth, totalChildrenHeight, hasExpandableChild
end

local auraSizeChanged = false
local function SetAuraDimensions(buff)
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if nameplateAuraSquare then
        auraSizeChanged = true
        buff:SetSize(20, 20)
        buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
        buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
        buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    elseif nameplateAuraTaller then
        auraSizeChanged = true
        buff:SetSize(20, 15.5)
        buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
        buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
        buff.Icon:SetTexCoord(0.05, 0.95, 0.15, 0.82)
    else
        if auraSizeChanged then
            buff:SetSize(20, 14)
            buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1)
            buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1)
            buff.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
        end
    end
end

local function SetBlueBuffBorder(buff, isPlayerUnit, isEnemyUnit, aura)
    local otherNpBuffBlueBorder = BetterBlizzPlatesDB.otherNpBuffBlueBorder
    if otherNpBuffBlueBorder then
        if not isPlayerUnit and isEnemyUnit then
            if aura.isHelpful then
                if not buff.buffBorder then
                    buff.buffBorder = buff:CreateTexture(nil, "ARTWORK");
                    if buff.Cooldown and buff.Cooldown:IsVisible() then
                        buff.buffBorder:SetParent(buff.Cooldown)
                    end
                    buff.buffBorder:SetAllPoints()
                    buff.buffBorder:SetAtlas("communities-create-avatar-border-hover");
                end
                buff.buffBorder:Show();
                buff.Border:Hide()
            else
                if buff.buffBorder then
                    buff.buffBorder:Hide();
                    buff.Border:Show()
                end
            end
            if not aura.isBuff then
                buff.Border:Show()
            end
        end
    else
        if buff.buffBorder then
            buff.buffBorder:Hide()
            buff.Border:Show()
        end
    end
end

local function SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)
    local otherNpBuffPurgeGlow = BetterBlizzPlatesDB.otherNpBuffPurgeGlow
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if otherNpBuffPurgeGlow then
        if not isPlayerUnit and isEnemyUnit then
            if aura.isHelpful and aura.isStealable then
                if not buff.buffBorderPurge then
                    buff.buffBorderPurge = buff:CreateTexture(nil, "OVERLAY")
                    buff.buffBorderPurge:SetAtlas("newplayertutorial-drag-slotblue")
                    if buff.Cooldown and buff.Cooldown:IsVisible() then
                        buff.buffBorderPurge:SetParent(buff.Cooldown)
                    end
                    if nameplateAuraSquare then
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10)
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10)
                    elseif nameplateAuraTaller then
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6.5)
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6.5)
                    else
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6)
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6)
                    end
                end
                buff.buffBorderPurge:Show()
                buff.Border:Hide()
            else
                if buff.buffBorderPurge then
                    buff.buffBorderPurge:Hide()
                    buff.Border:Show()
                end
            end
        end
    else
        if buff.buffBorderPurge then
            buff.buffBorderPurge:Hide()
            buff.Border:Show()
        end
    end
end


local function SetPandemicGlow(buff, aura, isPandemic)
    if aura.duration and buff and aura.expirationTime and isPandemic then
        buff.isPandemic = true
        buff.expirationTime = aura.expirationTime;
        trackedBuffs[aura.auraInstanceID] = buff;
        StartCheckBuffsTimer();
    else
        if buff.PandemicGlow then
            buff.PandemicGlow:Hide()
        end
        buff.isPandemic = false
    end
end

local function SetBuffEmphasisBorder(buff, aura, isPlayerUnit, isEnemyUnit, shouldShowAura)
    local otherNpBuffEmphasisedBorder = BetterBlizzPlatesDB.otherNpBuffEmphasisedBorder
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if otherNpBuffEmphasisedBorder then
        if not isPlayerUnit and isEnemyUnit then
            if aura.isHelpful and shouldShowAura then
                -- If extra glow for purge
                if not buff.BorderEmphasis then
                    buff.BorderEmphasis = buff:CreateTexture(nil, "OVERLAY")
                    buff.BorderEmphasis:SetAtlas("newplayertutorial-drag-slotgreen")
                    buff.BorderEmphasis:SetVertexColor(1, 0, 0)
                    buff.BorderEmphasis:SetDesaturated(true)
                    if buff.Cooldown and buff.Cooldown:IsVisible() then
                        buff.BorderEmphasis:SetParent(buff.Cooldown)
                    end
                    if nameplateAuraSquare then
                        buff.BorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10)
                        buff.BorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10)
                    elseif nameplateAuraTaller then
                        buff.BorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7.5)
                        buff.BorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7.5)
                    else
                        buff.BorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7)
                        buff.BorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7)
                    end
                end
                if buff.buffBorderPurge then
                    buff.buffBorderPurge:Hide()
                end
                buff.BorderEmphasis:Show()
                buff.Border:Hide()
            else
                if buff.BorderEmphasis then
                    buff.BorderEmphasis:Hide()
                    buff.Border:Show()
                end
            end
        end
    else
        if buff.BorderEmphasis then
            buff.BorderEmphasis:Hide()
            buff.Border:Show()
        end
    end
end

local function SetImportantGlow(buff, isPlayerUnit, isImportant, auraColor)
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if isImportant then
        if not isPlayerUnit then
            -- If extra glow for purge
            if not buff.ImportantGlow then
                buff.ImportantGlow = buff:CreateTexture(nil, "OVERLAY")
                buff.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                buff.ImportantGlow:SetDesaturated(true)
                if buff.Cooldown and buff.Cooldown:IsVisible() then
                    buff.ImportantGlow:SetParent(buff.Cooldown)
                end
                if nameplateAuraSquare then
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10)
                elseif nameplateAuraTaller then
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7.5)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7.5)
                else
                    buff.ImportantGlow:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7)
                    buff.ImportantGlow:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7)
                end
            end
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
            if auraColor then
                buff.ImportantGlow:SetVertexColor(auraColor.r, auraColor.g, auraColor.b, auraColor.a)
            else
                buff.ImportantGlow:SetVertexColor(0, 1, 0)
            end
            buff.ImportantGlow:Show()
            buff.Border:Hide()
        else
            if buff.ImportantGlow then
                buff.ImportantGlow:Hide()
                buff.Border:Show()
            end
        end
    else
        if buff.ImportantGlow then
            buff.ImportantGlow:Hide()
            buff.Border:Show()
        end
    end
end

local function ShouldShowBuff(unit, aura, BlizzardShouldShow)
    if not aura then return false end
    local spellName = aura.name
    local spellId = aura.spellId
    local duration = aura.duration
    local expirationTime = aura.expirationTime
    local caster = aura.sourceUnit
    local isPurgeable = aura.isStealable
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
    local castByPlayer = (caster == "player" or caster == "pet")
    local lessThanOneMin = (duration < 61 and duration ~= 0 and expirationTime ~= 0)

    local filterAllOverride = BetterBlizzPlatesDB.nameplateAuraTestMode or nil

    -- PLAYER
    if UnitIsUnit(unit, "player") then
        -- Buffs
        if BetterBlizzPlatesDB["personalNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = BetterBlizzPlatesDB["personalNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterBlizzard = BetterBlizzPlatesDB["personalNpBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["personalNpBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["personalNpBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterOnlyMe = BetterBlizzPlatesDB["personalNpBuffFilterOnlyMe"] and castByPlayer

            if BetterBlizzPlatesDB["onlyPandemicAuraMine"] and notCastByPlayer then
                isPandemic = false
            end

            -- Shorter than 60 override
            if filterOnlyMe and BetterBlizzPlatesDB["personalNpBuffFilterLessMinite"] and not isInWhitelist then
                if lessThanOneMin then
                    return true, isImportant, isPandemic
                else
                    return false
                end
            end

            if filterBlizzard or filterLessMinite or filterWatchlist or filterAllOverride or isImportant or isPandemic then
                if not castByPlayer and onlyMine then return false end
                return true, isImportant, isPandemic
            end
            if not BetterBlizzPlatesDB["personalNpBuffFilterBlizzard"] and not BetterBlizzPlatesDB["personalNpBuffFilterWatchList"] and not BetterBlizzPlatesDB["personalNpBuffFilterLessMinite"] then return true end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["personalNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = BetterBlizzPlatesDB["personalNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWatchlist = BetterBlizzPlatesDB["personalNpdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["personalNpdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)

            if BetterBlizzPlatesDB["onlyPandemicAuraMine"] and notCastByPlayer then
                isPandemic = false
            end

            if filterLessMinite or filterWatchlist or isImportant or isPandemic then
                if not castByPlayer and onlyMine then return false end
                return true, isImportant, isPandemic
            end
            if not BetterBlizzPlatesDB["personalNpdeBuffFilterWatchList"] and not BetterBlizzPlatesDB["personalNpdeBuffFilterWatchList"] then return true end
        end

    -- FRIENDLY
    elseif isFriend then
        -- Buffs
        if BetterBlizzPlatesDB["friendlyNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = BetterBlizzPlatesDB["friendlyNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWatchlist = BetterBlizzPlatesDB["friendlyNpBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpBuffFilterLessMinite"] and lessThanOneMin
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpBuffFilterOnlyMe"] and castByPlayer

            if BetterBlizzPlatesDB["onlyPandemicAuraMine"] and not castByPlayer then
                isPandemic = false
            end

            -- Shorter than 60 override
            if filterOnlyMe and BetterBlizzPlatesDB["friendlyNpBuffFilterLessMinite"] and not isInWhitelist then
                if lessThanOneMin then
                    return true, isImportant, isPandemic
                else
                    return false
                end
            end

            if filterLessMinite or filterOnlyMe or filterWatchlist or filterAllOverride or isImportant or isPandemic then
                if not castByPlayer and onlyMine then return false end
                return true, isImportant, isPandemic
            end
            if not BetterBlizzPlatesDB["friendlyNpBuffFilterWatchList"] and not BetterBlizzPlatesDB["friendlyNpBuffFilterLessMinite"] and not BetterBlizzPlatesDB["friendlyNpBuffFilterOnlyMe"] then return true end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["friendlyNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterBlizzard = BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["friendlyNpdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpdeBuffFilterOnlyMe"] and notCastByPlayer

            if BetterBlizzPlatesDB["onlyPandemicAuraMine"] and notCastByPlayer then
                isPandemic = false
            end

            -- Shorter than 60 override
            if filterOnlyMe and BetterBlizzPlatesDB["friendlyNpdeBuffFilterLessMinite"] and not isInWhitelist then
                if lessThanOneMin then
                    return true, isImportant, isPandemic
                else
                    return false
                end
            end

            if filterLessMinite or filterOnlyMe or filterBlizzard or filterWatchlist or filterAllOverride or isImportant or isPandemic then
                if not castByPlayer and onlyMine then return false end
                return true, isImportant, isPandemic
            end
            if not BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlizzard"] and not BetterBlizzPlatesDB["friendlyNpdeBuffFilterWatchList"] and not BetterBlizzPlatesDB["friendlyNpdeBuffFilterLessMinite"] and not BetterBlizzPlatesDB["friendlyNpdeBuffFilterOnlyMe"] then return true end
        end

    -- ENEMY
    else
        -- Buffs
        if BetterBlizzPlatesDB["otherNpBuffEnable"] and aura.isHelpful then
            local isInBlacklist = BetterBlizzPlatesDB["otherNpBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterWatchlist = BetterBlizzPlatesDB["otherNpBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["otherNpBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterPurgeable = BetterBlizzPlatesDB["otherNpBuffFilterPurgeable"] and isPurgeable

            if BetterBlizzPlatesDB["onlyPandemicAuraMine"] and notCastByPlayer then
                isPandemic = false
            end

            if filterPurgeable or filterLessMinite or filterWatchlist or filterAllOverride or isImportant or isPandemic then
                if not castByPlayer and onlyMine then return false end
                return true, isImportant, isPandemic
            end
            if not BetterBlizzPlatesDB["otherNpBuffFilterWatchList"] and not BetterBlizzPlatesDB["otherNpBuffFilterLessMinite"] and not BetterBlizzPlatesDB["otherNpBuffFilterPurgeable"] then return true end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["otherNpdeBuffEnable"] and aura.isHarmful then
            local isInBlacklist = BetterBlizzPlatesDB["otherNpdeBuffFilterBlacklist"] and isInBlacklist(spellName, spellId)
            if isInBlacklist then return end

            local isInWhitelist, isImportant, isPandemic, auraColor, onlyMine = GetAuraDetails(spellName, spellId)

            local filterBlizzard = BetterBlizzPlatesDB["otherNpdeBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["otherNpdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["otherNpdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterOnlyMe = BetterBlizzPlatesDB["otherNpdeBuffFilterOnlyMe"] and notCastByPlayer

            if BetterBlizzPlatesDB["onlyPandemicAuraMine"] and notCastByPlayer then
                isPandemic = false
            end

            -- Shorter than 60 override
            if filterOnlyMe and BetterBlizzPlatesDB["otherNpdeBuffFilterLessMinite"] and not isInWhitelist then
                if lessThanOneMin then
                    return true, isImportant, isPandemic
                else
                    return false
                end
            end

            if filterBlizzard or filterLessMinite or filterOnlyMe or filterWatchlist or isImportant or isPandemic then
                if not castByPlayer and onlyMine then return false end
                return true, isImportant, isPandemic
            end
            if not BetterBlizzPlatesDB["otherNpdeBuffFilterBlizzard"] and not BetterBlizzPlatesDB["otherNpdeBuffFilterWatchList"] and not BetterBlizzPlatesDB["otherNpdeBuffFilterLessMinite"] and not BetterBlizzPlatesDB["otherNpdeBuffFilterOnlyMe"] then return true end
        end
    end
end

function BBP.OnUnitAuraUpdate(self, unit, unitAuraUpdateInfo)
    local filter;
    local showAll = false;

    local isPlayer = UnitIsUnit("player", unit);
    local isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
    isEnemy = isEnemy or isNeutral
    local showDebuffsOnFriendly = self.showDebuffsOnFriendly;

    local auraSettings =
    {
        helpful = false;
        harmful = false;
        raid = false;
        includeNameplateOnly = false;
        showAll = false;
        hideAll = false;
    };

    if isPlayer then
        auraSettings.helpful = true;
        auraSettings.includeNameplateOnly = true;
        auraSettings.showPersonalCooldowns = self.showPersonalCooldowns;
    else
        if isEnemy then
            auraSettings.harmful = true;
            auraSettings.includeNameplateOnly = true;
        else
            if (showDebuffsOnFriendly) then
                -- dispellable debuffs
                auraSettings.harmful = true;
                auraSettings.raid = true;
                auraSettings.showAll = true;
            else
                auraSettings.hideAll = false; -- changed to false (would sometimes hide buffs on friendly targets if buff setting was on, TODO figure out more)
            end
        end
    end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
    if (nameplate) then
        BBP.UpdateBuffs(nameplate.UnitFrame.BuffFrame, nameplate.namePlateUnitToken, unitAuraUpdateInfo, auraSettings, nameplate.UnitFrame);
    end
end

function BBP.UpdateBuffs(self, unit, unitAuraUpdateInfo, auraSettings, UnitFrame)
    local filters = {};
    if auraSettings.helpful then
        table.insert(filters, AuraUtil.AuraFilters.Helpful);
    end
    if auraSettings.harmful then
        table.insert(filters, AuraUtil.AuraFilters.Harmful);
    end
    if auraSettings.raid then
        table.insert(filters, AuraUtil.AuraFilters.Raid);
    end
    if auraSettings.includeNameplateOnly then
        table.insert(filters, AuraUtil.AuraFilters.IncludeNameplateOnly);
    end
    local filterString = AuraUtil.CreateFilterString(unpack(filters));

    local previousFilter = self.filter;
    local previousUnit = self.unit;
    self.unit = unit;
    self.filter = filterString;
    self.showFriendlyBuffs = auraSettings.showFriendlyBuffs;

    local aurasChanged = false;
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filterString ~= previousFilter then
        BBP.ParseAllAuras(self, auraSettings.showAll, UnitFrame);
        aurasChanged = true;
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                local BlizzardShouldShow = self:ShouldShowBuff(aura, auraSettings.showAll) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, filterString)
                if ShouldShowBuff(unit, aura, BlizzardShouldShow) then
                    self.auras[aura.auraInstanceID] = aura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
                    self.auras[auraInstanceID] = newAura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    self.auras[auraInstanceID] = nil;
                    aurasChanged = true;
                end
            end
        end
    end

    self:UpdateAnchor();

    if not aurasChanged then
        return;
    end

    self.buffPool:ReleaseAll();

    --if auraSettings.hideAll or not self.isActive then
    if not self.isActive then
        return;
    end

    local buffIndex = 1;
    local BBPMaxAuraNum = BetterBlizzPlatesDB.maxAurasOnNameplate
    local rowOffset = 0;
    local isPlayerUnit = UnitIsUnit("player", self.unit)
    local isEnemyUnit, isFriend, isNeutral = BBP.GetUnitReaction(self.unit)
    isEnemyUnit = isEnemyUnit or isNeutral
    self.isEnemyUnit = isEnemyUnit
    local shouldShowAura, isImportant, isPandemic, auraColor


    self.auras:Iterate(function(auraInstanceID, aura)
        if buffIndex > BBPMaxAuraNum then return true end
        local buff = self.buffPool:Acquire();
        buff.auraInstanceID = auraInstanceID;
        buff.isBuff = aura.isHelpful;
        buff.layoutIndex = buffIndex;
        buff.spellID = aura.spellId;

        buff.Icon:SetTexture(aura.icon);

        local spellName = FetchSpellName(aura.spellId)
        local spellId = aura.spellId

        shouldShowAura, isImportant, isPandemic, auraColor = GetAuraDetails(spellName, spellId)

        -- Set aura dimensions
        SetAuraDimensions(buff);

        -- Blue buff border setting
        SetBlueBuffBorder(buff, isPlayerUnit, isEnemyUnit, aura);

        -- Pandemic Glow
        SetPandemicGlow(buff, aura, isPandemic)

        SetImportantGlow(buff, isPlayerUnit, isImportant, auraColor)

        -- Purge Glow
        SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)

        -- Emphasise Buff (Red Glow)
        SetBuffEmphasisBorder(buff, aura, isPlayerUnit, isEnemyUnit, shouldShowAura)

        if isPlayerUnit then
            if buff.Border then
                buff.Border:Show()
            end
            if buff.buffBorder then
                buff.buffBorder:Hide()
            end
            if buff.BorderEmphasis then
                buff.BorderEmphasis:Hide()
            end
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
        end

        if (aura.applications > 1) then
            buff.CountFrame.Count:SetText(aura.applications);
            buff.CountFrame.Count:Show();
        else
            buff.CountFrame.Count:Hide();
        end
        CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);

        if BetterBlizzPlatesDB.hideNpAuraSwipe then
            if buff.Cooldown then
                buff.Cooldown:SetDrawSwipe(false)
                buff.Cooldown:SetDrawEdge(false)
            end
        end

        if BetterBlizzPlatesDB.showDefaultCooldownNumbersOnNpAuras then
            if buff.Cooldown then
                buff.Cooldown:SetHideCountdownNumbers(false)
                local cdText = buff.Cooldown and buff.Cooldown:GetRegions()
                if cdText then
                    cdText:SetScale(BetterBlizzPlatesDB.defaultNpAuraCdSize)
                end
            end
        end

        buff:Show();
        buff:SetMouseClickEnabled(false)

        buffIndex = buffIndex + 1;
        return buffIndex >= BUFF_MAX_DISPLAY;
    end);
    self:Layout();
end

function BBP.ParseAllAuras(self, forceAll, UnitFrame)
    if self.auras == nil then
        self.auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
    else
        self.auras:Clear();
    end

    local function HandleAura(aura)
        local BlizzardShouldShow = self:ShouldShowBuff(aura, forceAll)
        local shouldShowAura, isImportant, isPandemic = ShouldShowBuff(self.unit, aura, BlizzardShouldShow)
        if shouldShowAura then
            self.auras[aura.auraInstanceID] = aura;
        end

        return false;
    end

    local batchCount = nil;
    local usePackedAura = true;
    AuraUtil.ForEachAura(self.unit, "HARMFUL", batchCount, HandleAura, usePackedAura);
    AuraUtil.ForEachAura(self.unit, "HELPFUL", batchCount, HandleAura, usePackedAura);

    -- Injecting fake auras for testing
    local isTestModeEnabled = BetterBlizzPlatesDB.nameplateAuraTestMode
    if isTestModeEnabled then
        local currentTime = GetTime()
        for _, fakeAura in ipairs(fakeAuras) do
            fakeAura.expirationTime = currentTime + fakeAura.duration
            HandleAura(fakeAura)
        end
    end
end

function BBP:UpdateAnchor()
    local unit = self:GetParent().unit
    local isTarget = unit and UnitIsUnit(unit, "target")
    local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0)
    local isEnemy, isFriend, isNeutral
    if unit then
        isEnemy, isFriend, isNeutral = BBP.GetUnitReaction(unit)
        isEnemy = isEnemy or isNeutral
    end

    local friendlyNameplateClickthrough = BetterBlizzPlatesDB.friendlyNameplateClickthrough
    local nameplateAurasYPos = BetterBlizzPlatesDB.nameplateAurasYPos
    local nameplateAurasNoNameYPos = BetterBlizzPlatesDB.nameplateAurasNoNameYPos
    local nameplateAuraScale = BetterBlizzPlatesDB.nameplateAuraScale

    if unit and ShouldShowName(self:GetParent()) then
        if friendlyNameplateClickthrough and isFriend then
            self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, -3 + targetYOffset + nameplateAurasYPos + 63)
        else
            self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, -3 + targetYOffset + nameplateAurasYPos)
        end
    else
        local additionalYOffset = 15 * (nameplateAuraScale - 1)
        self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 4 + targetYOffset + nameplateAurasNoNameYPos + 1 + additionalYOffset)
    end
end

function BBP.RefreshBuffFrame()
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
		local unitFrame = namePlate.UnitFrame
		unitFrame.BuffFrame:UpdateAnchor()
		if unitFrame.unit then
			local self = unitFrame.BuffFrame
            BBP.UpdateBuffs(self, unitFrame.unit, nil, {}, unitFrame)
        end
	end
end