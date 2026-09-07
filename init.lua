-- :)

BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
BBA = BBA or {}

BBP.ICON_NAME = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates"

local gameVersion = select(1, GetBuildInfo())
BBP.isMidnight = gameVersion:match("^12")
BBP.isRetail = gameVersion:match("^11")
BBP.isMoP = gameVersion:match("^5%.")
BBP.isCata = gameVersion:match("^4%.")
BBP.isTBC = gameVersion:match("^2%.")
BBP.isEra = gameVersion:match("^1%.")

local eraShamanColor
if BBP.isEra then
    eraShamanColor = CreateColor(0, 0.44, 0.87)
    eraShamanColor.colorStr = eraShamanColor:GenerateHexColor()
end

function BBP.GetClassColor(class)
    if eraShamanColor and class == "SHAMAN" then
        return eraShamanColor
    end
    return RAID_CLASS_COLORS[class]
end

function BBP.Print(msg, noColon)
	if msg then
		local suffix = noColon and " " or ": "
		print(BBP.ICON_NAME .. suffix .. msg)
	end
end