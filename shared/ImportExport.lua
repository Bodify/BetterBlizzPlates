local L = BBP.L
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize-BB")
local LibAceSerializer = LibStub("AceSerializer-3.0")

local exportKeepKeys = {
    version = true,
    updates = true,
    mopUpdated = true,
    hideLevelOnFriendly = true,
    classIndicatorFriendlyYPos = true,
    classIndicatorHealer = true,
    classIndicatorTank = true,
    healerIndicatorEnemyXPos = true,
    fakeNameAnchorFriendly = true,
    fakeNameAnchorRelativeFriendly = true,
    npTargetHighlightBorder = true,
    enableNameplateAuraCustomisation = true,
    smallPetsWidth = true,
    smallPetsHeight = true,
    friendlyHealthBarColorNpcRGB = true,
    friendlyColorNameNpcRGB = true,
}

local function SameValue(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    for k, v in pairs(a) do
        if not SameValue(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

local function WithoutDefaults(profileTable)
    local defaults = BBP.exportDefaults
    if not defaults then return profileTable end
    local stripped = {}
    for k, v in pairs(profileTable) do
        if exportKeepKeys[k] or not SameValue(v, defaults[k]) then
            stripped[k] = v
        end
    end
    return stripped
end

function BBP.UseDefaultsUntilReload(db)
    local defaults = BBP.exportDefaults
    if not defaults then return end
    setmetatable(db, { __index = function(t, k)
        local v = defaults[k]
        if type(v) == "table" then
            v = CopyTable(v)
            rawset(t, k, v)
        end
        return v
    end })
end

function BBP.DeepMergeTables(destination, source)
    for k, v in pairs(source) do
        if destination[k] == nil then
            if type(v) == "table" then
                destination[k] = {}
                BBP.DeepMergeTables(destination[k], v)
            else
                destination[k] = v
            end
        end
    end
end

function BBP.ExportProfile(profileTable, dataType)
    if dataType == "fullProfile" then
        local wowVersion = GetBuildInfo()
        BetterBlizzPlatesDB.exportVersion = "BBP: "..BBP.VersionNumber.." WoW: "..wowVersion
        BetterBlizzPlatesDB.retailExport = BBP.isMainline or BBP.isRetail
        BetterBlizzPlatesDB.classicExport = BBP.isMoP or BBP.isCata or BBP.isTBC or BBP.isEra
    end
    BetterBlizzPlatesDB.friendlyNameplatesEnabledOnExport = C_CVar.GetCVarBool("nameplateShowFriends")
    -- Include a dataType in the table being serialized
    local exportTable = {
        dataType = dataType,
        data = dataType == "fullProfile" and WithoutDefaults(profileTable) or profileTable
    }
    local serialized = LibSerialize:Serialize(exportTable)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    BetterBlizzPlatesDB.retailExport = nil
    BetterBlizzPlatesDB.classicExport = nil
    return "!BBP" .. encoded .. "!BBP"
end

local function ImportOtherProfile(encodedString, expectedDataType)
    -- Temporary native Blizzard encoding to support Platers new system
    local PlaterString = "!PLATER:2!"
	if (string.match(encodedString, "^" .. PlaterString)) and C_EncodingUtil then
		local dataCompressed = C_EncodingUtil.DecodeBase64(string.gsub(encodedString,PlaterString, ""))

        if not dataCompressed then
            return false, L["Import_Error_Decoding"]
        end

		local dataSerialized = C_EncodingUtil.DecompressString(dataCompressed)
		if not dataSerialized then
			return false, L["Import_Error_Decoding"]
		end

		local importTable = C_EncodingUtil.DeserializeCBOR(dataSerialized)
		if not importTable then
			return false, L["Import_Error_Decoding"]
		end

        if expectedDataType == "colorNpcList" then
            BBP.MergeNpcColorToBBP(importTable)
        elseif expectedDataType == "castEmphasisList" then
            BBP.MergeCastColorToBBP(importTable)
        else
            return false, L["Import_Error_Decoding"]
        end

		return true
	end

    -- Decode the data
    local compressed = LibDeflate:DecodeForPrint(encodedString)
    if not compressed then
        return nil, L["Import_Error_Decoding"]
    end

    -- Decompress the data
    local serialized, decompressMsg = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return nil, string.format(L["Import_Error_Decompressing"], tostring(decompressMsg))
    end

    -- Deserialize the data using LibAceSerializer
    local success, importTable = LibAceSerializer:Deserialize(serialized)
    if not success then
        return nil, L["Import_Error_Deserializing"]
    end

    -- Store the imported data in the DB
    if expectedDataType == "colorNpcList" then
        BBP.MergeNpcColorToBBP(importTable)
    elseif expectedDataType == "castEmphasisList" then
        BBP.MergeCastColorToBBP(importTable)
    end
    return true, nil
end

function BBP.OldImportProfile(encodedString, expectedDataType)
    -- Check if the string starts and ends with !BBP
    if encodedString:sub(1, 4) == "!BBP" and encodedString:sub(-4) == "!BBP" then
        encodedString = encodedString:sub(5, -5) -- Remove both prefix and suffix

        if encodedString:find("!") then
            return nil, L["Import_Error_Double_Paste"]
        end

        -- Proceed with the usual import process for your native format
        local compressed = LibDeflate:DecodeForPrint(encodedString)
        local serialized, decompressMsg = LibDeflate:DecompressDeflate(compressed)
        if not serialized then
            return nil, string.format(L["Import_Error_Decompressing"], tostring(decompressMsg))
        end

        local success, importTable = LibSerialize:Deserialize(serialized)
        if not success then
            return nil, L["Import_Error_Deserializing"]
        end

        -- If it's a full profile, extract the relevant portion based on expectedDataType
        if importTable.dataType == "fullProfile" then
            if importTable.data[expectedDataType] then
                -- Extract the relevant part and return it
                return importTable.data[expectedDataType], nil
            elseif expectedDataType ~= "fullProfile" and BBP.exportDefaults and type(BBP.exportDefaults[expectedDataType]) == "table" then
                return CopyTable(BBP.exportDefaults[expectedDataType]), nil
            else
                return importTable.data, nil
            end
        elseif importTable.dataType ~= expectedDataType then
            return nil, L["Import_Error_Type_Mismatch"]
        end

        return importTable.data, nil
    elseif encodedString:sub(1, 4) == "!BBF" and encodedString:sub(-4) == "!BBF" then
        return nil, L["Import_Error_BBF_String"]
    else
        -- If no !BBP, assume it's an other import and try to process it
        local success, importTable = ImportOtherProfile(encodedString, expectedDataType)

        -- Check if the import was successful and the expected data type is 'colorNpcList'
        if success and (expectedDataType == "colorNpcList" or expectedDataType == "castEmphasisList") then
            return nil, nil, true
        else
            return nil, L["Import_Error_Invalid_Format"]
        end
    end
end

function BBP.ImportProfile(encodedString)
    local expectedDataType = "fullProfile"

    local profileData, errorMessage = BBP.OldImportProfile(encodedString, expectedDataType)
    if errorMessage then
        return false, errorMessage
    end

    BBP.DeepMergeTables(BetterBlizzPlatesDB, profileData)

    return true
end