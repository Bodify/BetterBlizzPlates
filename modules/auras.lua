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

function BBP.OnUnitAuraUpdateRSV(self, unit, unitAuraUpdateInfo)
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
				auraSettings.hideAll = true;
			end
		end
	end

	local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
	if (nameplate) then
		BBP.UpdateBuffsRSV(nameplate.UnitFrame.BuffFrame, nameplate.namePlateUnitToken, unitAuraUpdateInfo, auraSettings, nameplate.UnitFrame);
	end
end

function BBP.UpdateBuffsRSV(self, unit, unitAuraUpdateInfo, auraSettings, UnitFrame)
    --local BetterBlizzPlatesDB = BBP.tabDB[BBP.iDBmark]
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
		BBP.ParseAllAurasRSV(self, auraSettings.showAll, UnitFrame);
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

	if auraSettings.hideAll or not self.isActive then
		return;
	end

	local buffIndex = 1;
    local BBPMaxAuraNum = BetterBlizzPlatesDB.maxAurasOnNameplate
	self.auras:Iterate(function(auraInstanceID, aura)
        if buffIndex > BBPMaxAuraNum then return true end
		local buff = self.buffPool:Acquire();
		buff.auraInstanceID = auraInstanceID;
		buff.isBuff = aura.isHelpful;
		buff.layoutIndex = buffIndex;
		buff.spellID = aura.spellId;

        
        
		buff.Icon:SetTexture(aura.icon);


        -- If blue border
        local isPlayerUnit = UnitIsUnit("player", self.unit)
        local isEnemyUnit = UnitIsEnemy("player", self.unit)
        local spellName = FetchSpellName(aura.spellId)
        local spellId = aura.spellId

        -- Blue buff border setting
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




        -- Purge buff glow setting
        if BetterBlizzPlatesDB.otherNpBuffPurgeGlow then
            if not isPlayerUnit and isEnemyUnit then
                if aura.isHelpful and aura.isStealable then
                    -- If extra glow for purge
                    if not buff.buffBorderPurge then
                        buff.buffBorderPurge = buff:CreateTexture(nil, "OVERLAY");
                        if buff.Cooldown then
                            buff.buffBorderPurge:SetParent(buff.Cooldown)
                        end
                        buff.buffBorderPurge:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 6);
                        buff.buffBorderPurge:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -6);
                        buff.buffBorderPurge:SetAtlas("newplayertutorial-drag-slotblue");
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

        -- Red glow on whitelisted buffs
        if BetterBlizzPlatesDB.otherNpBuffEmphasisedBorder then
            if not isPlayerUnit and isEnemyUnit then
                if aura.isHelpful and BBP.isInWhitelist(spellName, spellId) then
                    -- If extra glow for purge
                    if not buff.buffBorderEmphasis then
                        buff.buffBorderEmphasis = buff:CreateTexture(nil, "OVERLAY");
                        if buff.Cooldown then
                            buff.buffBorderEmphasis:SetParent(buff.Cooldown)
                        end
                        buff.buffBorderEmphasis:SetPoint("TOPLEFT", buff, "TOPLEFT", -10, 7);
                        buff.buffBorderEmphasis:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 10, -7);
                        buff.buffBorderEmphasis:SetAtlas("newplayertutorial-drag-slotgreen");
                        buff.buffBorderEmphasis:SetDesaturated(true)
                        buff.buffBorderEmphasis:SetVertexColor(1, 0, 0)
                    end
                    if buff.buffBorderPurge then
                        buff.buffBorderPurge:Hide()
                    end
                    buff.buffBorderEmphasis:Show();
                    buff.Border:Hide()
                else
                    if buff.buffBorderEmphasis then
                        buff.buffBorderEmphasis:Hide()
                        buff.Border:Show()
                    end
                end
            end
        else
            if buff.buffBorderEmphasis then
                buff.buffBorderEmphasis:Hide()
                buff.Border:Show()
            end
        end

        if isPlayerUnit then
            if buff.Border then
                buff.Border:Show()
            end
            if buff.buffBorder then
                buff.buffBorder:Hide()
            end
            if buff.buffBorderEmphasis then
                buff.buffBorderEmphasis:Hide()
            end
            if buff.buffBorderPurge then
                buff.buffBorderPurge:Hide()
            end
        end

        buff.Icon:SetScale(1)

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

function BBP.ParseAllAurasRSV(self, forceAll, UnitFrame)
    --local BetterBlizzPlatesDB = BBP.tabDB[BBP.iDBmark] 

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



-- Source
function BBP:UpdateAnchor()
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target");
	local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0);
	if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0 + BetterBlizzPlatesDB.nameplateAurasXPos, targetYOffset + BetterBlizzPlatesDB.nameplateAurasYPos);
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0 + BetterBlizzPlatesDB.nameplateAurasXPos, 5 + targetYOffset);
	end
end

function BBP.RefBuffFrameDisplay()
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
		local unitFrame = namePlate.UnitFrame
		unitFrame.BuffFrame:UpdateAnchor()
		if unitFrame.unit then 
			local self = unitFrame.BuffFrame
            -- 重新init全更新一遍所有buff
            BBP.UpdateBuffsRSV(self, unitFrame.unit, nil, {}, unitFrame)
        end
	end	
end

--[[
function BBP:UpdateAnchor()
    local isPlayer = self:GetParent().unit and UnitIsUnit("player", self:GetParent().unit)
    local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target");
	local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0);
    if isPlayer then 
        self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 + targetYOffset);
	elseif (self:GetParent().unit and ShouldShowName(self:GetParent())) then
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", 0 + BetterBlizzPlatesDB.nameplateAurasXPos, targetYOffset + BetterBlizzPlatesDB.nameplateAurasYPos);
	else
        self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", self:GetParent().healthBar, "TOPLEFT", 0 + BetterBlizzPlatesDB.nameplateAurasXPos, 5 + targetYOffset + BetterBlizzPlatesDB.nameplateAurasYPos);
	end
end

]]


--[[
function BBP:UpdateAnchor()
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target");
	local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0);
	if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset);
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 + targetYOffset);
	end
end


]]
