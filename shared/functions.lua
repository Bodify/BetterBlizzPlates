BBP.popups = {}
BBP.popupBuilders = {}

function BBP.GetPopup(name)
	local popup = BBP.popups[name]
	if not popup then
		popup = BBP.popupBuilders[name]()
		BBP.popups[name] = popup
		StaticPopupDialogs[name] = popup
	end
	return popup
end

function BBP.ShowPopup(name, ...)
	BBP.GetPopup(name)
	return StaticPopup_Show(name, ...)
end

BBP.popupBuilders["BB_PRD_AURAS_CLASH"] = function()
	return {
		text = BBP.L["Popup_PRD_Auras_Clash"],
		button1 = "BetterBlizzFrames",
		button2 = "BetterBlizzPlates",
		OnAccept = function() BBP.SetPrdAuraOwner("BBF") end,
		OnButton2 = function() BBP.SetPrdAuraOwner("BBP") end,
		timeout = 0,
		whileDead = true,
		preferredIndex = 3,
	}
end

function BBP.IsTotemUnit(unit)
	local creatureType, creatureTypeID = UnitCreatureType(unit)
	if issecretvalue(creatureType) then return false end
	if creatureTypeID then
		return creatureTypeID == 11
	end
	return creatureType == "Totem"
end

function BBP.IsRecentAlly(unit)
	return UnitSelectionType ~= nil and UnitSelectionType(unit, true) == 16
end

function BBP.IsFriendUnit(unit)
	local guid = UnitGUID(unit)
	if not guid or issecretvalue(guid) then return false end
	if C_FriendList.IsFriend(guid) then return true end
	local accountInfo = C_BattleNet and C_BattleNet.GetAccountInfoByGUID(guid)
	return accountInfo ~= nil and accountInfo.isFriend == true
end

local friendlyPlayerColorChecks = {}

function BBP.TargetShowsHidden(unit)
	return not BetterBlizzPlatesDB.keepNameplatesHidden and UnitIsUnit(unit, "target")
end

function BBP.GetFriendlyPlayerColor(unit, prefix)
	local checks = friendlyPlayerColorChecks[prefix]
	if not checks then
		checks = {
			{ prefix .. "Friend", prefix .. "FriendRGB", BBP.IsFriendUnit },
			{ prefix .. "Guild", prefix .. "GuildRGB", UnitIsInMyGuild },
			{ prefix .. "RecentAlly", prefix .. "RecentAllyRGB", BBP.IsRecentAlly },
		}
		friendlyPlayerColorChecks[prefix] = checks
	end
	local db = BetterBlizzPlatesDB
	for i = 1, #checks do
		local check = checks[i]
		if db[check[1]] and check[3](unit) then
			return db[check[2]]
		end
	end
end

function BBP.GetFriendlyPetColor(unit, prefix)
	local db = BetterBlizzPlatesDB
	local myPet, pets = db[prefix .. "MyPet"], db[prefix .. "Pet"]
	if not (myPet or pets) then return end
	local isMyPet = UnitIsUnit(unit, "pet")
	if isMyPet and myPet then
		return db[prefix .. "MyPetRGB"]
	end
	if pets and (isMyPet or UnitIsOtherPlayersPet(unit)) then
		return db[prefix .. "PetRGB"]
	end
end

function BBP.CopyHealthColorToName(frame)
	local config = frame.BetterBlizzPlates and frame.BetterBlizzPlates.config
	local uninterruptible = config and config.totemUninterruptible
	if uninterruptible ~= nil and frame.totemHealthbarOverlaid and frame.name.SetVertexColorFromBoolean then
		frame.name:SetVertexColorFromBoolean(uninterruptible, frame.totemHealthbarOverlayColor, frame.totemHealthbarBaseColor)
		return
	end
	local r, g, b = frame.healthBar:GetStatusBarColor()
	frame.name:SetVertexColor(r, g, b)
end

function BBP.FollowHealthName(frame)
	if not frame.bbpNameFollowsHealth or not frame.name then return end
	local bbp = frame.BetterBlizzPlates
	local config, info = bbp and bbp.config, bbp and bbp.unitInfo
	if not (config and info and config.updateNameInitialized) then return end
	BBP.CopyHealthColorToName(frame)
	BBP.ApplyNameColorLayers(frame, config, info)
end

local friendlyHealthBarRows = { "friendlyHealthBarColorOne", "friendlyHealthBarColorFriend", "friendlyHealthBarColorGuild", "friendlyHealthBarColorRecentAlly", "friendlyHealthBarColorPlayer", "friendlyHealthBarColorNpc", "friendlyHealthBarColorPet", "friendlyHealthBarColorMyPet" }
local friendlyNameRows = { "friendlyColorNameFollowHealthbar", "friendlyColorNameOne", "friendlyColorNameFriend", "friendlyColorNameGuild", "friendlyColorNameRecentAlly", "friendlyColorNamePlayer", "friendlyColorNameNpc", "friendlyColorNamePet", "friendlyColorNameMyPet" }

local classColorGroups = {
	{
		master = "friendlyHealthBarColor", row = "friendlyHealthBarColorClass", derived = "nameplateShowFriendlyClassColor",
		cvar = "nameplateShowFriendlyClassColor", cvarString = true, others = friendlyHealthBarRows,
		keepClass = function(db) return not db.friendlyHealthBarColorPlayer end,
	},
	{
		master = "friendlyColorName", row = "friendlyColorNameClass", derived = "friendlyClassColorName",
		cvar = "nameplateUseClassColorForFriendlyPlayerUnitNames", others = friendlyNameRows,
		keepClass = function() return true end,
	},
	{
		master = "enemyHealthBarColor", row = "enemyHealthBarColorClass", derived = "nameplateShowClassColor",
		cvar = "nameplateShowClassColor", cvarString = true, others = { "enemyHealthBarColorHostile", "enemyHealthBarColorNeutral", "enemyHealthBarColorNpcOnly", "enemyHealthBarColorPet" },
		keepClass = function(db) return db.enemyHealthBarColorNpcOnly or db.enemyHealthBarColorHostile == false end,
	},
	{
		master = "enemyColorName", row = "enemyColorNameClass", derived = "enemyClassColorName",
		others = { "enemyColorNameFollowHealthbar", "enemyColorNameHostile", "enemyColorNameNeutral", "enemyColorNamePet" },
		keepClass = function() return true end,
	},
}
local classColorGroupByCVar = {}
for _, group in ipairs(classColorGroups) do
	if group.cvar then classColorGroupByCVar[group.cvar] = group end
end

local function ClassColorCVarExists(group)
	return group.cvar and C_CVar.GetCVar(group.cvar) ~= nil
end

local function ClassColorOn(db, group)
	return db[group.master] and db[group.row] and true or false
end

local function WriteClassColorDerived(db, group)
	local on = ClassColorOn(db, group)
	if group.cvarString then
		db[group.derived] = on and "1" or "0"
	else
		db[group.derived] = on
	end
end

local function OldClassColorOn(db, group)
	local value = db[group.derived]
	if value == nil then
		return ClassColorCVarExists(group) and C_CVar.GetCVar(group.cvar) == "1"
	end
	return value == true or value == "1" or value == 1
end

local function EnableClassColorOnly(db, group)
	if not db[group.master] then
		db[group.master] = true
		for _, key in ipairs(group.others) do
			db[key] = false
		end
	end
	db[group.row] = true
end

function BBP.MigrateClassColorRows()
	local db = BetterBlizzPlatesDB
	if db.classColorRowsMigrated then return end
	for _, group in ipairs(classColorGroups) do
		if OldClassColorOn(db, group) then
			if not db[group.master] then
				EnableClassColorOnly(db, group)
			else
				db[group.row] = group.keepClass(db) and true or false
			end
		end
		WriteClassColorDerived(db, group)
	end
	db.classColorRowsMigrated = true
end

function BBP.SyncClassColorCVars(skipCVars)
	local db = BetterBlizzPlatesDB
	local changed = false
	for _, group in ipairs(classColorGroups) do
		local before = db[group.derived]
		WriteClassColorDerived(db, group)
		if group.cvarString and before ~= db[group.derived] then
			changed = true
		end
		if not skipCVars and ClassColorCVarExists(group) then
			local value = ClassColorOn(db, group) and "1" or "0"
			if C_CVar.GetCVar(group.cvar) ~= value then
				local cvar = group.cvar
				BBP.RunAfterCombat(function()
					C_CVar.SetCVar(cvar, value)
				end)
			end
		end
	end
	return changed
end

function BBP.RefreshClassColorWidgets()
	local widgets = BBP.classColorWidgets
	if not widgets then return end
	for key, widget in pairs(widgets) do
		widget[1]:SetChecked(BetterBlizzPlatesDB[key] and true or false)
		widget[2]:UpdateEnabled()
	end
end

function BBP.EnableHealthBarClassColors()
	local db = BetterBlizzPlatesDB
	EnableClassColorOnly(db, classColorGroups[1])
	EnableClassColorOnly(db, classColorGroups[3])
	BBP.SyncClassColorCVars(true)
end

function BBP.PickupClassColorCVar(cvarName, value)
	local group = classColorGroupByCVar[cvarName]
	if not group then return end
	local db = BetterBlizzPlatesDB
	if not db.classColorRowsMigrated then return true end
	local on = value == "1"
	if on ~= ClassColorOn(db, group) then
		if on then
			EnableClassColorOnly(db, group)
		else
			db[group.row] = false
		end
		WriteClassColorDerived(db, group)
		if BBP.RefreshClassColorWidgets then BBP.RefreshClassColorWidgets() end
		BBP.needsUpdate = true
		if BBP.RefreshAllNameplates then BBP.RefreshAllNameplates() end
	end
	return true
end

function BBP.PickupLiveClassColorCVars()
	for _, group in ipairs(classColorGroups) do
		if ClassColorCVarExists(group) then
			BBP.PickupClassColorCVar(group.cvar, C_CVar.GetCVar(group.cvar))
		end
	end
end

local function SetShiftedNamePoint(name, point, relativeTo, relativePoint, x, y)
	local wasChanging = name.changing
	name.bbpShifting = true
	name.changing = true
	name:SetPoint(point, relativeTo, relativePoint, x, y + (name.bbpNameShift or 0))
	name.changing = wasChanging
	name.bbpShifting = nil
end

local function HookNamePoints(frame)
	local name = frame and frame.name
	if not name or name.bbpNamePoints or frame:IsForbidden() then return end
	name.bbpNamePoints = {}

	hooksecurefunc(name, "ClearAllPoints", function(self)
		if not self.bbpShifting then
			wipe(self.bbpNamePoints)
		end
	end)

	hooksecurefunc(name, "SetPoint", function(self, point, relativeTo, relativePoint, x, y)
		if self.bbpShifting then return end

		if type(relativeTo) == "number" then
			relativeTo, relativePoint, x, y = nil, nil, relativeTo, relativePoint
		elseif type(relativeTo) == "string" then
			relativeTo = _G[relativeTo]
		end
		relativeTo = relativeTo or self:GetParent()
		relativePoint = relativePoint or point
		x = x or 0
		y = y or 0

		local points = self.bbpNamePoints
		if issecretvalue(y) then
			points[point] = nil
			return
		end

		local saved = points[point]
		if not saved then
			saved = {}
			points[point] = saved
		end
		saved[1], saved[2], saved[3], saved[4] = relativeTo, relativePoint, x, y

		if self.bbpNameShift and self.bbpNameShift ~= 0 then
			SetShiftedNamePoint(self, point, relativeTo, relativePoint, x, y)
		end
	end)
end

local function HookNamePlate(namePlate)
	if not namePlate then return end
	if namePlate.AcquireUnitFrame and not namePlate.bbpNameShiftHooked then
		namePlate.bbpNameShiftHooked = true
		hooksecurefunc(namePlate, "AcquireUnitFrame", function(self)
			HookNamePoints(self.UnitFrame)
		end)
	end
	HookNamePoints(namePlate.UnitFrame)
end

local underNameHookFrame
function BBP.ToggleUnderNameHooks()
	local db = BetterBlizzPlatesDB
	local guildMoves = db.guildNameUnderName and not db.guildNameUnderNameNoMove
	local titleMoves = db.npcTitleUnderName and not db.npcTitleUnderNameNoMove

	if guildMoves or titleMoves then
		if not underNameHookFrame then
			underNameHookFrame = CreateFrame("Frame")
			underNameHookFrame:SetScript("OnEvent", function(_, _, namePlate)
				HookNamePlate(namePlate)
			end)
		end
		underNameHookFrame:RegisterEvent("NAME_PLATE_CREATED")
		for _, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			HookNamePlate(namePlate)
		end
	elseif underNameHookFrame then
		underNameHookFrame:UnregisterAllEvents()
	end
end

local function HookShiftReset(frame, source)
	if source == "guild" then
		local guildName = frame.guildName
		if guildName and not guildName.bbpShiftHooked then
			guildName.bbpShiftHooked = true
			hooksecurefunc(guildName, "SetText", function(_, text)
				if not text or text == "" then
					BBP.SetNameShift(frame, "guild", 0)
				end
			end)
		end
	elseif source == "npcTitle" then
		local npcTitle = frame.npcTitle
		if npcTitle and not npcTitle.bbpShiftHooked then
			npcTitle.bbpShiftHooked = true
			hooksecurefunc(npcTitle, "Hide", function()
				BBP.SetNameShift(frame, "npcTitle", 0)
			end)
		end
	end
end

function BBP.SetNameShift(frame, source, shift)
	local name = frame.name
	if not name then return end
	HookShiftReset(frame, source)

	local shifts = name.bbpShiftSources
	if not shifts then
		if shift == 0 then return end
		shifts = {}
		name.bbpShiftSources = shifts
	end
	shifts[source] = shift

	local total = math.max(shifts.guild or 0, shifts.npcTitle or 0)
	if total == (name.bbpNameShift or 0) then return end
	name.bbpNameShift = total

	if not name.bbpNamePoints then return end
	for point, saved in pairs(name.bbpNamePoints) do
		SetShiftedNamePoint(name, point, saved[1], saved[2], saved[3], saved[4])
	end
end
