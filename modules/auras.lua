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
            return true, isImportant, isPandemic
        end
    end
    return false, false, false
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
        if buff.expirationTime then
            local remainingDuration = buff.expirationTime - currentGameTime;
            if remainingDuration <= 0 then
                trackedBuffs[auraInstanceID] = nil;
                if buff.PandemicGlow then
                    buff.PandemicGlow:Hide();
                end
            elseif remainingDuration <= 5.1 then
                if not buff.PandemicGlow then
                    buff.PandemicGlow = buff:CreateTexture(nil, "OVERLAY");
                    buff.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen");
                    buff.PandemicGlow:SetDesaturated(true)
                    buff.PandemicGlow:SetVertexColor(1, 0, 0)
                    if buff.Cooldown then
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
                buff.PandemicGlow:Show();
            else
                if buff.PandemicGlow then
                    buff.PandemicGlow:Hide();
                end
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

        for index, buff in ipairs(auras) do
            local buffWidth, buffHeight = buff:GetSize()

            -- Update the maximum row height
            maxRowHeight = math.max(maxRowHeight, buffHeight)

            -- Determine if it's the start of a new row
            if index % maxBuffsPerRow == 1 then
                local rowIndex = math.floor((index - 1) / maxBuffsPerRow) + 1

                if (BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor and not isEnemyUnit) or (BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor and isEnemyUnit) then
                    horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
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

            if (BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor and not isEnemyUnit) or (BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor and isEnemyUnit) then
                buff:SetPoint("BOTTOM", container, "TOP", horizontalOffset - healthBarWidth / 2 + 10 + BetterBlizzPlatesDB.nameplateAurasXPos, verticalOffset - 13)
            else
                buff:SetPoint("BOTTOMLEFT", container, "TOPLEFT", horizontalOffset + BetterBlizzPlatesDB.nameplateAurasXPos, verticalOffset - 13)
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

    return totalChildrenWidth, totalChildrenHeight, hasExpandableChild -- Adjust 'hasExpandableChild' as needed
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
                    if buff.Cooldown then
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
                    if buff.Cooldown then
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
    if aura.duration and buff and aura.expirationTime and not aura.isHelpful and isPandemic then
        buff.expirationTime = aura.expirationTime;
        trackedBuffs[aura.auraInstanceID] = buff;
        StartCheckBuffsTimer();
    else
        if buff.PandemicGlow then
            buff.PandemicGlow:Hide()
        end
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
                    if buff.Cooldown then
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

local function SetImportantGlow(buff, isPlayerUnit, isImportant)
    local nameplateAuraSquare = BetterBlizzPlatesDB.nameplateAuraSquare
    local nameplateAuraTaller = BetterBlizzPlatesDB.nameplateAuraTaller

    if isImportant then
        if not isPlayerUnit then
            -- If extra glow for purge
            if not buff.ImportantGlow then
                buff.ImportantGlow = buff:CreateTexture(nil, "OVERLAY")
                buff.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
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
    local spellName = aura.name
    local spellId = aura.spellId
    local duration = aura.duration
    local expirationTime = aura.expirationTime
    local caster = aura.sourceUnit
    local isPurgeable = aura.isStealable

    -- PLAYER
    if UnitIsUnit(unit, "player") then
        -- Buffs
        if BetterBlizzPlatesDB["personalNpBuffEnable"] and aura.isHelpful then
            local isInWhitelist, isImportant, isPandemic = GetAuraDetails(spellName, spellId)
            local filterAll = BetterBlizzPlatesDB["personalNpBuffFilterAll"]
            local filterBlizzard = BetterBlizzPlatesDB["personalNpBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["personalNpBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["personalNpBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            if filterAll or filterBlizzard or filterWatchlist or isImportant or isPandemic then
                if filterLessMinite then return end
                if isInBlacklist(spellName, spellId) then return end
                return true, isImportant, isPandemic
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["personalNpdeBuffEnable"] and aura.isHarmful then
            local isInWhitelist, isImportant, isPandemic = GetAuraDetails(spellName, spellId)
            local filterAll = BetterBlizzPlatesDB["personalNpdeBuffFilterAll"]
            local filterWatchlist = BetterBlizzPlatesDB["personalNpdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["personalNpdeBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            if filterAll or filterWatchlist or isImportant or isPandemic then
                if filterLessMinite then return end
                if isInBlacklist(spellName, spellId) then return end
                return true, isImportant, isPandemic
            end
        end

    -- FRIENDLY
    elseif UnitIsFriend(unit, "player") then
        -- Buffs
        if BetterBlizzPlatesDB["friendlyNpBuffEnable"] and aura.isHelpful then
            local isInWhitelist, isImportant, isPandemic = GetAuraDetails(spellName, spellId)
            local filterAll = BetterBlizzPlatesDB["friendlyNpBuffFilterAll"]
            local filterWatchlist = BetterBlizzPlatesDB["friendlyNpBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpBuffFilterOnlyMe"] and (caster ~= "player" and caster ~= "pet")
            if filterAll or filterWatchlist or isImportant or isPandemic then
                if filterLessMinite or filterOnlyMe then return end
                if isInBlacklist(spellName, spellId) then return end
                return true, isImportant, isPandemic
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["friendlyNpdeBuffEnable"] and aura.isHarmful then
            local isInWhitelist, isImportant, isPandemic = GetAuraDetails(spellName, spellId)
            local filterAll = BetterBlizzPlatesDB["friendlyNpdeBuffFilterAll"]
            local filterBlizzard = BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["friendlyNpdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpdeBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpdeBuffFilterOnlyMe"] and (caster ~= "player" and caster ~= "pet")
            if filterAll or filterWatchlist or filterBlizzard or isImportant or isPandemic then
                if filterLessMinite or filterOnlyMe then return end
                if isInBlacklist(spellName, spellId) then return end
                return true, isImportant, isPandemic
            end
        end

    -- ENEMY
    else
        -- Buffs
        if BetterBlizzPlatesDB["otherNpBuffEnable"] and aura.isHelpful then
            local isInWhitelist, isImportant, isPandemic = GetAuraDetails(spellName, spellId)
            local filterAll = BetterBlizzPlatesDB["otherNpBuffFilterAll"]
            local filterWatchlist = BetterBlizzPlatesDB["otherNpBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["otherNpBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterPurgeable = BetterBlizzPlatesDB["otherNpBuffFilterPurgeable"] and isPurgeable
            if filterAll or filterWatchlist or filterPurgeable or isImportant or isPandemic then
                if filterLessMinite then return end
                if isInBlacklist(spellName, spellId) then return end
                return true, isImportant, isPandemic
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["otherNpdeBuffEnable"] and aura.isHarmful then
            local isInWhitelist, isImportant, isPandemic = GetAuraDetails(spellName, spellId)
            local filterAll = BetterBlizzPlatesDB["otherNpdeBuffFilterAll"]
            local filterBlizzard = BetterBlizzPlatesDB["otherNpdeBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["otherNpdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzPlatesDB["otherNpdeBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterOnlyMe = BetterBlizzPlatesDB["otherNpdeBuffFilterOnlyMe"] and (caster ~= "player" and caster ~= "pet")
            if filterAll or filterWatchlist or filterBlizzard or isImportant or isPandemic then
                if filterLessMinite or filterOnlyMe then return end
                if isInBlacklist(spellName, spellId) then return end
                return true, isImportant, isPandemic
            end
        end
    end
end

function BBP.OnUnitAuraUpdate(self, unit, unitAuraUpdateInfo)
    local filter;
    local showAll = false;

    local isPlayer = UnitIsUnit("player", unit);
    local isEnemy = not UnitIsFriend("player", unit)
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
    local isEnemyUnit = not UnitIsFriend("player", self.unit)
    self.isEnemyUnit = isEnemyUnit
    local shouldShowAura, isImportant, isPandemic


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

        shouldShowAura, isImportant, isPandemic = GetAuraDetails(spellName, spellId)

        -- Set aura dimensions
        SetAuraDimensions(buff);

        -- Blue buff border setting
        SetBlueBuffBorder(buff, isPlayerUnit, isEnemyUnit, aura);

        -- Pandemic Glow
        SetPandemicGlow(buff, aura, isPandemic)
        SetImportantGlow(buff, isPlayerUnit, isImportant)

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
end

function BBP:UpdateAnchor()
    local unit = self:GetParent().unit
    local isTarget = unit and UnitIsUnit(unit, "target")
    local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0)
    local isFriend = unit and UnitIsFriend(unit, "player")

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