local ALPHABETS = { "korean", "roman", "russian", "simplifiedchinese", "traditionalchinese" }

local LOCALE_ALPHABET = {
    koKR = "korean",
    ruRU = "russian",
    zhCN = "simplifiedchinese",
    zhTW = "traditionalchinese",
}
local ownAlphabet = LOCALE_ALPHABET[GetLocale()] or "roman"

local stock = SystemFont_NamePlate
local supported = type(CreateFontFamily) == "function" and stock and stock.GetFontObjectForAlphabet ~= nil

local stockFiles = {}
if supported then
    for _, alphabet in ipairs(ALPHABETS) do
        local member = stock:GetFontObjectForAlphabet(alphabet)
        stockFiles[alphabet] = member and member:GetFont()
    end
end

local applied = {}

local function SetFontIfChanged(fontObject, file, size, flags)
    local last = applied[fontObject]
    if last and last[1] == file and last[2] == size and last[3] == flags then
        local f, s, fl = fontObject:GetFont()
        if f == last[4] and s == last[5] and fl == last[6] then return end
    end
    fontObject:SetFont(file, size, flags)
    if not last then
        last = {}
        applied[fontObject] = last
    end
    last[1], last[2], last[3] = file, size, flags
    last[4], last[5], last[6] = fontObject:GetFont()
end

local memberLists = {}

local function GetMembers(fontObject)
    local list = memberLists[fontObject]
    if list then return list end
    list = {}
    for _, alphabet in ipairs(ALPHABETS) do
        local member = fontObject:GetFontObjectForAlphabet(alphabet)
        if member and member ~= fontObject then
            list[#list + 1] = member
            list[#list + 1] = alphabet ~= ownAlphabet and stockFiles[alphabet] or false
        end
    end
    memberLists[fontObject] = list
    return list
end

function BBP.SetFontOnFontObject(fontObject, file, size, flags)
    fontObject:SetFont(file, size, flags)
    if not supported or not fontObject.GetFontObjectForAlphabet then return end
    local list = GetMembers(fontObject)
    for i = 1, #list, 2 do
        SetFontIfChanged(list[i], list[i + 1] or file, size, flags)
    end
end

local textFamilies = {}
local textFamilyCount = 0

local function GetTextFamily(file, flags)
    local byFlags = textFamilies[file]
    if not byFlags then
        byFlags = {}
        textFamilies[file] = byFlags
    end
    local family = byFlags[flags]
    if family then return family end
    local members = {}
    for i, alphabet in ipairs(ALPHABETS) do
        members[i] = {
            alphabet = alphabet,
            file = alphabet ~= ownAlphabet and stockFiles[alphabet] or file,
            height = 12,
            flags = flags,
        }
    end
    textFamilyCount = textFamilyCount + 1
    family = CreateFontFamily("BBPTextFont" .. textFamilyCount, members)
    byFlags[flags] = family
    return family
end

function BBP.SetTextFont(fontString, file, size, flags)
    flags = flags or ""
    if not supported or not file or not size then
        fontString:SetFont(file, size, flags)
        return
    end
    local family = GetTextFamily(file, flags)
    if fontString:GetFontObject() ~= family then
        local r, g, b, a = fontString:GetTextColor()
        local sr, sg, sb, sa = fontString:GetShadowColor()
        local sx, sy = fontString:GetShadowOffset()
        local justifyH, justifyV = fontString:GetJustifyH(), fontString:GetJustifyV()
        fontString:SetFontObject(family)
        fontString:SetTextColor(r, g, b, a)
        fontString:SetShadowColor(sr, sg, sb, sa)
        fontString:SetShadowOffset(sx, sy)
        fontString:SetJustifyH(justifyH)
        fontString:SetJustifyV(justifyV)
    end
    local _, height = fontString:GetFont()
    if not height or height - size > 0.01 or size - height > 0.01 then
        fontString:SetFontHeight(size)
    end
end

function BBP.SetHealthTextFont(frame, file, size, flags)
    local healthBar = frame.HealthBarsContainer.healthBar
    for _, text in ipairs({ healthBar.Text, healthBar.LeftText, healthBar.RightText }) do
        BBP.SetTextFont(text, file, size, flags)
        text:SetFontHeight(size)
    end
end
