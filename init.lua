-- :)

BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
BBA = BBA or {}

local gameVersion = select(1, GetBuildInfo())
BBP.isMidnight = gameVersion:match("^12")
BBP.isRetail = gameVersion:match("^11")
BBP.isMoP = gameVersion:match("^5%.")
BBP.isEra = gameVersion:match("^1%.")