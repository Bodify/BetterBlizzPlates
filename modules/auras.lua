-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

----------------------------------------------------
---- Aura Function Copied From RSPlates and edited by me
----------------------------------------------------

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

function CustomBuffLayoutChildren(container, children, ignored, expandToHeight)
    -- Obtain the health bar details
    local healthBar = container:GetParent().healthBar
    local healthBarWidth = healthBar:GetWidth()
    local healthBarCenter = healthBarWidth / 2

    -- Define the spacing and row parameters
    local horizontalSpacing = BetterBlizzPlatesDB.nameplateAuraWidthGap
    local verticalSpacing = -28 - BetterBlizzPlatesDB.nameplateAuraHeightGap - (BetterBlizzPlatesDB.nameplateAuraSquare and 12 or 0)
    local currentRow = 0
    local maxBuffsPerRow = BetterBlizzPlatesDB.nameplateAuraRowAmount
    local maxRowHeight = 0
    local rowWidths = {}
    local totalChildrenHeight = 0

    -- Calculate the width of each row
    for index, buff in ipairs(children) do
        buff:SetScale(BetterBlizzPlatesDB.nameplateAuraScale)
        local buffWidth, _ = buff:GetSize()

        if container.respectChildScale then
            local buffScale = buff:GetScale()
            buffWidth = buffWidth * buffScale
        end

        local rowIndex = math.floor((index - 1) / maxBuffsPerRow) + 1
        rowWidths[rowIndex] = (rowWidths[rowIndex] or 0) + buffWidth

        if index % maxBuffsPerRow ~= 1 then
            rowWidths[rowIndex] = rowWidths[rowIndex] + horizontalSpacing
        end
    end

    local horizontalOffset = 0
    local lastAuraInRow = nil

    for index, buff in ipairs(children) do
        local buffWidth, buffHeight = buff:GetSize()

        -- Update the maximum row height
        maxRowHeight = math.max(maxRowHeight, buffHeight)

        -- Determine if it's the start of a new row
        if index % maxBuffsPerRow == 1 then
            local rowIndex = math.floor((index - 1) / maxBuffsPerRow) + 1

            if BetterBlizzPlatesDB.nameplateAurasGrowLeft then
                -- Calculate the total width of this row
                local totalRowWidth = rowWidths[rowIndex] + (maxBuffsPerRow - 1) * horizontalSpacing - horizontalSpacing

                -- Adjust horizontal offset for the first aura in the row
                horizontalOffset = (healthBarWidth - totalRowWidth)  -- Start directly from the right edge
                lastAuraInRow = buff
            elseif BetterBlizzPlatesDB.nameplateAurasCenteredAnchor then
                if rowIndex == 1 then
                    horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2  -- Center the first row
                else
                    if not BetterBlizzPlatesDB.nameplateCenterAllRows then
                        -- Put the first aura of every new row on top of the first aura on the first row
                        horizontalOffset = (healthBarWidth - rowWidths[1]) / 2
                    else
                        horizontalOffset = (healthBarWidth - rowWidths[rowIndex]) / 2
                    end
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

        if BetterBlizzPlatesDB.nameplateAurasGrowLeft then
            if lastAuraInRow then
                -- Adjust horizontal offset based on the last aura in the row
                local lastAuraWidth, _ = lastAuraInRow:GetSize()
                horizontalOffset = horizontalOffset + lastAuraWidth + horizontalSpacing
            end
        end

        if BetterBlizzPlatesDB.nameplateAurasGrowLeft then
            buff:SetPoint(BetterBlizzPlatesDB.nameplateAuraAnchor, container, BetterBlizzPlatesDB.nameplateAuraRelativeAnchor, horizontalOffset + buffWidth - BetterBlizzPlatesDB.nameplateAurasXPos - healthBarWidth - 20, verticalOffset - 13)
        elseif BetterBlizzPlatesDB.nameplateAurasCenteredAnchor then
            buff:SetPoint(BetterBlizzPlatesDB.nameplateAuraAnchor, container, BetterBlizzPlatesDB.nameplateAuraRelativeAnchor, horizontalOffset - healthBarCenter + 10 + BetterBlizzPlatesDB.nameplateAurasXPos, verticalOffset - 13)
        else
            buff:SetPoint(BetterBlizzPlatesDB.nameplateAuraAnchor, container, BetterBlizzPlatesDB.nameplateAuraRelativeAnchor, horizontalOffset + BetterBlizzPlatesDB.nameplateAurasXPos, verticalOffset - 13)
        end
        lastAuraInRow = buff
        if not BetterBlizzPlatesDB.nameplateAurasGrowLeft then
        horizontalOffset = horizontalOffset + buffWidth + horizontalSpacing
        end
    end

    return totalChildrenWidth, totalChildrenHeight + currentRow * maxRowHeight, hasExpandableChild
end

local auraSizeChanged = false
local function SetAuraDimensions(buff)
    if BetterBlizzPlatesDB.nameplateAuraSquare then
        auraSizeChanged = true
        buff:SetSize(20, 20);
        buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1);
        buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1);
        buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    elseif BetterBlizzPlatesDB.nameplateAuraTaller then
        auraSizeChanged = true
        buff:SetSize(20, 15.5);
        buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1);
        buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1);
        buff.Icon:SetTexCoord(0.05, 0.95, 0.15, 0.82);
    else
        if auraSizeChanged then
            buff:SetSize(20, 14);
            buff.Icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, -1);
            buff.Icon:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -1, 1);
            buff.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);
        end
    end
end

local function SetBlueBuffBorder(buff, isPlayerUnit, isEnemyUnit, aura)
    if BetterBlizzPlatesDB.otherNpBuffBlueBorder then
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
    if BetterBlizzPlatesDB.otherNpBuffPurgeGlow then
        if not isPlayerUnit and isEnemyUnit then
            if aura.isHelpful and aura.isStealable then
                if not buff.buffBorderPurge then
                    buff.buffBorderPurge = buff:CreateTexture(nil, "OVERLAY");
                    buff.buffBorderPurge:SetAtlas("newplayertutorial-drag-slotblue");
                    if buff.Cooldown then
                        buff.buffBorderPurge:SetParent(buff.Cooldown)
                    end
                    if BetterBlizzPlatesDB.nameplateAuraSquare then
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10);
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10);
                    elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6.5);
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6.5);
                    else
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6);
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6);
                    end
                end
                buff.buffBorderPurge:Show();
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

local function SetPandemicGlow(buff, aura, spellName, spellId)
    if BetterBlizzPlatesDB.otherNpdeBuffPandemicGlow then
        if aura.duration and buff and aura.expirationTime and not aura.isHelpful and BBP.isInWhitelist(spellName, spellId) then
            buff.expirationTime = aura.expirationTime;
            trackedBuffs[aura.auraInstanceID] = buff;
            StartCheckBuffsTimer();
        else
            if buff.PandemicGlow then
                buff.PandemicGlow:Hide()
            end
        end
    end
end

local function SetBuffEmphasisBorder(buff, aura, isPlayerUnit, isEnemyUnit, spellName, spellId)
    if BetterBlizzPlatesDB.otherNpBuffEmphasisedBorder then
        if not isPlayerUnit and isEnemyUnit then
            if aura.isHelpful and BBP.isInWhitelist(spellName, spellId) then
                -- If extra glow for purge
                if not buff.BorderEmphasis then
                    buff.BorderEmphasis = buff:CreateTexture(nil, "OVERLAY");
                    buff.BorderEmphasis:SetAtlas("newplayertutorial-drag-slotgreen");
                    buff.BorderEmphasis:SetVertexColor(1, 0, 0);
                    buff.BorderEmphasis:SetDesaturated(true);
                    if buff.Cooldown then
                        buff.BorderEmphasis:SetParent(buff.Cooldown);
                    end
                    if BetterBlizzPlatesDB.nameplateAuraSquare then
                        buff.BorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 10);
                        buff.BorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -10);
                    elseif BetterBlizzPlatesDB.nameplateAuraTaller then
                        buff.BorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7.5);
                        buff.BorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7.5);
                    else
                        buff.BorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7);
                        buff.BorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7);
                    end
                end
                if buff.buffBorderPurge then
                    buff.buffBorderPurge:Hide();
                end
                buff.BorderEmphasis:Show();
                buff.Border:Hide();
            else
                if buff.BorderEmphasis then
                    buff.BorderEmphasis:Hide();
                    buff.Border:Show();
                end
            end
        end
    else
        if buff.BorderEmphasis then
            buff.BorderEmphasis:Hide();
            buff.Border:Show();
        end
    end
end

local function FetchSpellName(spellId)
    local spellName, _, _ = GetSpellInfo(spellId)
    return spellName
end

function BBP.isInWhitelist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraWhitelist"]) do
        if entry.name and spellName and type(entry.name) == "string" and type(spellName) == "string" then
            if string.lower(entry.name) == string.lower(spellName) or entry.id == spellId then
                return true
            end
        end
    end
    return false
end

function BBP.isInBlacklist(spellName, spellId)
    for _, entry in pairs(BetterBlizzPlatesDB["auraBlacklist"]) do
        if entry.name and spellName and type(entry.name) == "string" and type(spellName) == "string" then
            if string.lower(entry.name) == string.lower(spellName) or entry.id == spellId then
                return true
            end
        end
    end
    return false
end

function BBP.BBPShouldShowBuff(unit, aura, BlizzardShouldShow)
    local spellName = FetchSpellName(aura.spellId)
    local spellId = aura.spellId
    local duration = aura.duration
    local expirationTime = aura.expirationTime
    local caster = aura.sourceUnit
    local isPurgeable = aura.isStealable

    -- PLAYER
    if UnitIsUnit(unit, "player") then
        -- Buffs
        if BetterBlizzPlatesDB["personalNpBuffEnable"] and aura.isHelpful then
            local filterAll = BetterBlizzPlatesDB["personalNpBuffFilterAll"]
            local filterBlizzard = BetterBlizzPlatesDB["personalNpBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["personalNpBuffFilterWatchList"] and BBP.isInWhitelist(spellName, spellId)
            local filterLessMinite = BetterBlizzPlatesDB["personalNpBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            if filterAll or filterBlizzard or filterWatchlist then 
                if filterLessMinite then return end
                if BBP.isInBlacklist(spellName, spellId) then return end
                return true
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["personalNpdeBuffEnable"] and aura.isHarmful then
            local filterAll = BetterBlizzPlatesDB["personalNpdeBuffFilterAll"]
            local filterWatchlist = BetterBlizzPlatesDB["personalNpdeBuffFilterWatchList"] and BBP.isInWhitelist(spellName, spellId)
            local filterLessMinite = BetterBlizzPlatesDB["personalNpdeBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            if filterAll or filterWatchlist then 
                if filterLessMinite then return end
                if BBP.isInBlacklist(spellName, spellId) then return end
                return true
            end
        end

    -- FRIENDLY
    elseif UnitIsFriend(unit, "player") then
        -- Buffs
        if BetterBlizzPlatesDB["friendlyNpBuffEnable"] and aura.isHelpful then
            local filterAll = BetterBlizzPlatesDB["friendlyNpBuffFilterAll"]
            local filterWatchlist = BetterBlizzPlatesDB["friendlyNpBuffFilterWatchList"] and BBP.isInWhitelist(spellName, spellId)
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            if filterAll or filterWatchlist then
                if filterLessMinite then return end
                if BBP.isInBlacklist(spellName, spellId) then return end
                return true
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["friendlyNpdeBuffEnable"] and aura.isHarmful then
            local filterAll = BetterBlizzPlatesDB["friendlyNpdeBuffFilterAll"]
            local filterBlizzard = BetterBlizzPlatesDB["friendlyNpdeBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["friendlyNpdeBuffFilterWatchList"] and BBP.isInWhitelist(spellName, spellId)
            local filterLessMinite = BetterBlizzPlatesDB["friendlyNpdeBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterOnlyMe = BetterBlizzPlatesDB["friendlyNpdeBuffFilterOnlyMe"] and (caster ~= "player" and caster ~= "pet")
            if filterAll or filterWatchlist or filterBlizzard then 
                if filterLessMinite or filterOnlyMe then return end
                if BBP.isInBlacklist(spellName, spellId) then return end
                return true
            end
        end

    -- ENEMY
    else
        -- Buffs
        if BetterBlizzPlatesDB["otherNpBuffEnable"] and aura.isHelpful then
            local filterAll = BetterBlizzPlatesDB["otherNpBuffFilterAll"]
            local filterWatchlist = BetterBlizzPlatesDB["otherNpBuffFilterWatchList"] and BBP.isInWhitelist(spellName, spellId)
            local filterLessMinite = BetterBlizzPlatesDB["otherNpBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterPurgeable = BetterBlizzPlatesDB["otherNpBuffFilterPurgeable"] and isPurgeable
            if filterAll or filterWatchlist or filterPurgeable then
                if filterLessMinite then return end
                if BBP.isInBlacklist(spellName, spellId) then return end
                return true
            end
        end
        -- Debuffs
        if BetterBlizzPlatesDB["otherNpdeBuffEnable"] and aura.isHarmful then
            local filterAll = BetterBlizzPlatesDB["otherNpdeBuffFilterAll"]
            local filterBlizzard = BetterBlizzPlatesDB["otherNpdeBuffFilterBlizzard"] and BlizzardShouldShow
            local filterWatchlist = BetterBlizzPlatesDB["otherNpdeBuffFilterWatchList"] and BBP.isInWhitelist(spellName, spellId)
            local filterLessMinite = BetterBlizzPlatesDB["otherNpdeBuffFilterLessMinite"] and (duration > 60 or duration == 0 or expirationTime == 0)
            local filterOnlyMe = BetterBlizzPlatesDB["otherNpdeBuffFilterOnlyMe"] and (caster ~= "player" and caster ~= "pet")
            if filterAll or filterWatchlist or filterBlizzard then 
                if filterLessMinite or filterOnlyMe then return end
                if BBP.isInBlacklist(spellName, spellId) then return end
                return true
            end
        end
    end
end

function BBP.OnUnitAuraUpdate(self, unit, unitAuraUpdateInfo)
    local filter;
	local showAll = false;

	local isPlayer = UnitIsUnit("player", unit);
	local reaction = UnitReaction("player", unit);
	-- Reaction 4 is neutral and less than 4 becomes increasingly more hostile
	local hostileUnit = reaction and reaction <= 4;
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
		if hostileUnit then
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
				if BBP.BBPShouldShowBuff(unit, aura, BlizzardShouldShow) then
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


	self.auras:Iterate(function(auraInstanceID, aura)
        if buffIndex > BBPMaxAuraNum then return true end
		local buff = self.buffPool:Acquire();
		buff.auraInstanceID = auraInstanceID;
		buff.isBuff = aura.isHelpful;
		buff.layoutIndex = buffIndex;
		buff.spellID = aura.spellId;

		buff.Icon:SetTexture(aura.icon);

        local isPlayerUnit = UnitIsUnit("player", self.unit)
        local isEnemyUnit = UnitIsEnemy("player", self.unit)
        local spellName = FetchSpellName(aura.spellId)
        local spellId = aura.spellId

        -- Set aura dimensions
        SetAuraDimensions(buff);

        -- Blue buff border setting
        SetBlueBuffBorder(buff, isPlayerUnit, isEnemyUnit, aura);

        -- Pandemic Glow
        SetPandemicGlow(buff, aura, spellName, spellId)

        -- Purge Glow
        SetPurgeGlow(buff, isPlayerUnit, isEnemyUnit, aura)

        -- Emphasise Buff (Red Glow)
        SetBuffEmphasisBorder(buff, aura, isPlayerUnit, isEnemyUnit, spellName, spellId)


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
		if BBP.BBPShouldShowBuff(self.unit, aura, BlizzardShouldShow) then
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
    local unit = self:GetParent().unit;
    local isTarget = unit and UnitIsUnit(unit, "target");
    local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0);
    local isFriend = unit and UnitIsFriend(unit, "player");

    if unit and ShouldShowName(self:GetParent()) then
        if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
            if isFriend then
                self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, -3 + targetYOffset + BetterBlizzPlatesDB.nameplateAurasYPos + 63);
            else
                self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, -3 + targetYOffset + BetterBlizzPlatesDB.nameplateAurasYPos);
            end
        else
            self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, -3 + targetYOffset + BetterBlizzPlatesDB.nameplateAurasYPos);
        end
    else
        local additionalYOffset = 15 * (BetterBlizzPlatesDB.nameplateAuraScale - 1)
        self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 4 + targetYOffset + BetterBlizzPlatesDB.nameplateAurasNoNameYPos + additionalYOffset);
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