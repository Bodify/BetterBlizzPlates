-- :)

BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
BBA = BBA or {}

BBP.ICON_NAME = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates"

local gameVersion, _, _, interfaceVersion = GetBuildInfo()
BBP.isForever = interfaceVersion >= 16000 and interfaceVersion < 17000
BBP.isMidnight = not BBP.isForever and gameVersion:match("^12")
BBP.isRetail = gameVersion:match("^11")
BBP.isMainline = BBP.isMidnight or BBP.isForever
BBP.isMoP = gameVersion:match("^5%.")
BBP.isCata = gameVersion:match("^4%.")
BBP.isTBC = gameVersion:match("^2%.")
BBP.isEra = not BBP.isForever and gameVersion:match("^1%.")

function BBP.Print(msg, noColon)
	if msg then
		local suffix = noColon and " " or ": "
		print(BBP.ICON_NAME .. suffix .. msg)
	end
end