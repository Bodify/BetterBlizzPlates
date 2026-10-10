-- Locale system for BetterBlizzPlates

BBP.L = BBP.L or {}
BBP.L_native = {}
BBP.locale = GetLocale()
BBP.localeCallbacks = {}

setmetatable(BBP.L, {
	__index = function(t, key)
		return key
	end
})

function BBP.ApplyLocale()
	if not BBP.L_native then return end
	if BetterBlizzPlatesDB and BetterBlizzPlatesDB.forceEnglishGUI then
		BBP.locale = "enUS"
	else
		for key, value in pairs(BBP.L_native) do
			BBP.L[key] = value
		end
	end
	for _, callback in ipairs(BBP.localeCallbacks) do
		callback()
	end
	BBP.L_native = nil
end
