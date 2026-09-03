BBP = BBP or {}
BBP.Locale = BBP.Locale or {}

local locale = GetLocale()
local translations = BBP.Locale.translations or {}

function BBP.L(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    local localeTranslations = translations[locale]
    if localeTranslations and localeTranslations[text] then
        return localeTranslations[text]
    end
    -- English source strings are the keys; fall back to the original text.
    return text
end

_G["BINDING_NAME_Toggle Hide Friendly Healthbars"] = BBP.L("Toggle Hide Friendly Healthbars")
