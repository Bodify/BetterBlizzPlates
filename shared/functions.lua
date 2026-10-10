function BBP.IsTotemUnit(unit)
	local creatureType, creatureTypeID = UnitCreatureType(unit)
	if creatureTypeID then
		return creatureTypeID == 11
	end
	return creatureType == "Totem"
end

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
