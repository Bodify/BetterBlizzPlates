local L = BBP.L
local LSM = LibStub("LibSharedMedia-3.0")

-- Custom fonts (arialn.ttf, Expressway_Free.ttf) support Latin and Cyrillic only
-- For other languages, use WoW's default font from GameFontNormal (supports all locales)
local locale = GetLocale()

-- Check if custom fonts support the current locale
local useCustomFonts = (locale == "enUS" or locale == "enGB" or
                         locale == "deDE" or locale == "esES" or locale == "esMX" or
                         locale == "frFR" or locale == "itIT" or locale == "ptBR" or locale == "ruRU")

local fontSmall, fontMedium, fontLarge

if useCustomFonts then
    -- Use custom addon fonts for Latin and Cyrillic languages
    fontSmall = "Interface\\AddOns\\BetterBlizzPlates\\media\\arialn.ttf"
    fontMedium = "Interface\\AddOns\\BetterBlizzPlates\\media\\arialn.ttf"
    fontLarge = "Interface\\AddOns\\BetterBlizzPlates\\media\\Expressway_Free.ttf"
else
    -- Get game's default font path which already supports the current locale
    local gameFont = GameFontNormal:GetFont()
    fontSmall = gameFont
    fontMedium = gameFont
    fontLarge = gameFont
end

local GUI_FONT_BASE_SIZE = 12
local guiFontPanels = {}
local guiFontOriginals = setmetatable({}, { __mode = "k" })
local guiDerivedFontObjects = {}
local guiDerivedFontCount = 0
local guiFontApplied = false

local function GetGuiFontSettings()
    local db = BetterBlizzPlatesDB
    if not (db and db.guiFontEnabled) then
        return nil, 0
    end
    local fontPath = db.guiFont and LSM:Fetch(LSM.MediaType.FONT, db.guiFont, true) or nil
    return fontPath, (tonumber(db.guiFontSize) or GUI_FONT_BASE_SIZE) - GUI_FONT_BASE_SIZE
end

local function ApplyGuiFontToInstance(obj, fontPath, sizeDelta)
    local original = guiFontOriginals[obj]
    if not original then
        local path, size, flags = obj:GetFont()
        if not path then return end
        original = { path, size, flags }
        guiFontOriginals[obj] = original
    end
    obj:SetFont(fontPath or original[1], math.max(original[2] + sizeDelta, 6), original[3])
end

local function GetDerivedFontObject(source, fontPath, sizeDelta)
    local key = tostring(source) .. "|" .. (fontPath or "") .. "|" .. sizeDelta
    local fontObject = guiDerivedFontObjects[key]
    if not fontObject then
        guiDerivedFontCount = guiDerivedFontCount + 1
        fontObject = CreateFont("BBP_GuiFont" .. guiDerivedFontCount)
        fontObject:CopyFontObject(source)
        local path, size, flags = source:GetFont()
        fontObject:SetFont(fontPath or path, math.max(size + sizeDelta, 6), flags)
        guiDerivedFontObjects[key] = fontObject
    end
    return fontObject
end

local function ApplyGuiFontToButton(button, fontPath, sizeDelta)
    local original = guiFontOriginals[button]
    if not original then
        local normal = button:GetNormalFontObject()
        if not normal then return end
        original = { normal, button:GetHighlightFontObject(), button:GetDisabledFontObject() }
        guiFontOriginals[button] = original
    end
    local changed = fontPath or sizeDelta ~= 0
    local function Pick(source)
        return changed and GetDerivedFontObject(source, fontPath, sizeDelta) or source
    end
    button:SetNormalFontObject(Pick(original[1]))
    if original[2] then button:SetHighlightFontObject(Pick(original[2])) end
    if original[3] then button:SetDisabledFontObject(Pick(original[3])) end
end

local function WalkGuiFonts(frame, fontPath, sizeDelta)
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:IsObjectType("FontString") then
            ApplyGuiFontToInstance(region, fontPath, sizeDelta)
        end
    end
    if frame:IsObjectType("EditBox") then
        ApplyGuiFontToInstance(frame, fontPath, sizeDelta)
    elseif frame:IsObjectType("Button") then
        ApplyGuiFontToButton(frame, fontPath, sizeDelta)
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        WalkGuiFonts(child, fontPath, sizeDelta)
    end
end

function BBP.ApplyGuiFont()
    local fontPath, sizeDelta = GetGuiFontSettings()
    if not fontPath and sizeDelta == 0 and not guiFontApplied then return end
    guiFontApplied = true
    for _, panel in ipairs(guiFontPanels) do
        WalkGuiFonts(panel, fontPath, sizeDelta)
    end
end

local function RegisterGuiFontPanel(panel)
    table.insert(guiFontPanels, panel)
    panel:HookScript("OnShow", function()
        BBP.ApplyGuiFont()
    end)
end

local guiTooltipOriginals = {}
local guiTooltipHooked = false

local function RestoreGuiTooltipFonts()
    for fontString, original in pairs(guiTooltipOriginals) do
        fontString:SetFont(original[1], original[2], original[3])
    end
    wipe(guiTooltipOriginals)
end

local function ApplyGuiFontToTooltip()
    local fontPath, sizeDelta = GetGuiFontSettings()
    if not fontPath and sizeDelta == 0 then return end
    if not guiTooltipHooked then
        GameTooltip:HookScript("OnHide", RestoreGuiTooltipFonts)
        GameTooltip:HookScript("OnTooltipCleared", RestoreGuiTooltipFonts)
        guiTooltipHooked = true
    end
    for i = 1, GameTooltip:NumLines() do
        for _, side in ipairs({ "Left", "Right" }) do
            local fontString = _G["GameTooltipText" .. side .. i]
            if fontString then
                local original = guiTooltipOriginals[fontString]
                if not original then
                    local path, size, flags = fontString:GetFont()
                    if path then
                        original = { path, size, flags }
                        guiTooltipOriginals[fontString] = original
                    end
                end
                if original then
                    fontString:SetFont(fontPath or original[1], math.max(original[2] + sizeDelta, 6), original[3])
                end
            end
        end
    end
    GameTooltip:Show()
end

BetterBlizzPlates = nil
local anchorPoints = {"CENTER", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local targetIndicatorAnchorPoints = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local pixelsBetweenBoxes = 5

local AURA_SLIDER_ELEMENTS = {
    maxBuffsOnNameplate = true,
    nameplateAuraBuffScale = true,
    nameplateAuraDebuffScale = true,
    nameplateAuraEnlargedScale = true,
    nameplateAuraBuffLimit = true,
    ccIconLimit = true,
    nameplateAuraTimerLowThreshold = true,
    nameplateAuraTimerHighThreshold = true,
    bigNpAuraCdSize = true,
    nameplateDebuffXPadding = true,
    bbpDebuffPadding = true,
    npAuraStackTextXPos = true,
    npAuraStackTextYPos = true,
    bbpAuraScale = true,
    prdAuraScale = true,
    prdAuraYPos = true,
    prdAuraXPos = true,
    prdAuraRowAmount = true,
    prdAuraLimit = true,
}
local pixelsBetweenBoxedWSlider = -4
local pixelsOnFirstBox = -1
local npcEditFrame = nil
local titleText = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \n\n"

local checkBoxList = {}
local checkboxByOption = {}
local sliderList = {}
local dropdownList = {}
local MAX_SEARCH_CHECKBOXES = 25
local MAX_SEARCH_SLIDERS = 15
local MAX_SEARCH_DROPDOWNS = 3
local SEARCH_DROPDOWN_SCALE = 0.8

BBP.popupBuilders["BBP_CONFIRM_RELOAD"] = function() return {
    text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \n\n" .. L["Popup_Reload_Required"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
} end

BBP.popupBuilders["BBP_CLASSIC_NAMEPLATES_SETUP"] = function() return {
    text = titleText..L["Popup_Classic_Nameplates_Toggle_Only_Enables_The"],
    button1 = L["Yes_Fix_It_Up"],
    button2 = L["No_Ill_Sort_It"],
    OnAccept = function()
        local db = BetterBlizzPlatesDB
        db.nameplateGeneralHpHeight = 14.5
        if db.changeHealthbarHeight then
            db.hpHeightEnemy = 14.5
            db.hpHeightFriendly = 14.5
        end
        db.useCustomTextureForBars = true
        db.useCustomTextureForEnemy = true
        db.useCustomTextureForFriendly = true
        db.customTexture = "Blizzard DF"
        db.customTextureFriendly = "Blizzard DF"
        db.useFakeName = true
        db.reopenOptions = true
        ReloadUI()
    end,
    OnCancel = function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end,
    timeout = 0,
    whileDead = true,
} end

BBP.popupBuilders["BBP_CLASSIC_CASTBAR_SETUP"] = function() return {
    text = titleText..L["Popup_Do_You_Want_To_Use_Classic"],
    button1 = L["Use_Classic"],
    button2 = L["Use_New_Defaults"],
    OnAccept = function()
        local db = BetterBlizzPlatesDB
        db.classicCastbarTextures = true
        db.reopenOptions = true
        ReloadUI()
    end,
    OnCancel = function(_, _, reason)
        if reason == "clicked" then
            BetterBlizzPlatesDB.classicCastbarTextures = false
            BetterBlizzPlatesDB.reopenOptions = true
            ReloadUI()
        end
    end,
    timeout = 0,
    whileDead = true,
} end

BBP.popupBuilders["BBP_CONFIRM_WIPE_NPCCOLOR"] = function() return {
    text = titleText..L["Popup_This_Will_Delete_The_Entire_Npc"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BetterBlizzPlatesDB.colorNpcList = {}
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
} end

BBP.popupBuilders["BBP_CONFIRM_IMPORT_NPCCOLOR"] = function() return {
    text = titleText..L["Popup_This_Will_Add_Mythic_Plus_Season"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BBP.MythicSeason3NPCColors()
    end,
    timeout = 0,
    whileDead = true,
} end


BBP.popupBuilders["BBP_CONFIRM_WIPE_CASTEMPHASIS"] = function() return {
    text = titleText..L["Popup_This_Will_Delete_The_Entire_Cast"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BetterBlizzPlatesDB.castEmphasisList = {}
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
} end

BBP.popupBuilders["BBP_CONFIRM_PROFILE"] = function() return {
    text = "",
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function(self)
        if self.data and self.data.func then
            self.data.func()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
} end

BBP.popupBuilders["BBP_RESET_NP_AURAS"] = function() return {
    text = titleText..L["Popup_Are_You_Sure_You_Want_To"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BBP.ResetNameplateAuraSettings()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
} end

BBP.popupBuilders["BBP_TOTEMLIST_RESET"] = function() return {
    text = titleText..L["Popup_This_Will_Delete_The_Entire_Totem"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BBP.ResetTotemList()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
} end



------------------------------------------------------------
-- GUI Creation Functions
------------------------------------------------------------
local function CheckAndToggleCheckboxes(frame)
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        if child and (child:GetObjectType() == "CheckButton" or child:GetObjectType() == "Slider" or child:GetObjectType() == "Button") then
            if frame:GetChecked() then
                child:Enable()
                child:SetAlpha(1)
            else
                child:Disable()
                child:SetAlpha(0.5)
            end
        end

        -- Check if the child has children and if it's a CheckButton or Slider
        for j = 1, child:GetNumChildren() do
            local childOfChild = select(j, child:GetChildren())
            if childOfChild and (childOfChild:GetObjectType() == "CheckButton" or childOfChild:GetObjectType() == "Slider" or childOfChild:GetObjectType() == "Button") then
                if child.GetChecked and child:GetChecked() and frame.GetChecked and frame:GetChecked() then
                    childOfChild:Enable()
                    childOfChild:SetAlpha(1)
                else
                    childOfChild:Disable()
                    childOfChild:SetAlpha(0.5)
                end
            end
        end
    end
end

local function DisableElement(element)
    element:Disable()
    element:SetAlpha(0.5)
end

local function EnableElement(element)
    element:Enable()
    element:SetAlpha(1)
end

local function UpdateColorSquare(icon, r, g, b, a)
    if r and g and b then
        icon:SetColorTexture(r, g, b, a)
    end
end

local function TintFromColor(texture, colorVar, dr, dg, db)
    local c = BetterBlizzPlatesDB[colorVar]
    if type(c) == "table" and c[1] then
        texture:SetVertexColor(c[1], c[2] or 0, c[3] or 0)
    else
        texture:SetVertexColor(dr, dg, db)
    end
end

local function OpenColorPicker(colorType, icon, onChange)
    -- Initialize color with default RGBA if not present
    local stored = BetterBlizzPlatesDB[colorType]
    if type(stored) ~= "table" then
        stored = {1, 1, 1, 1}
    elseif stored[1] == nil then
        stored = {stored.r or 1, stored.g or 1, stored.b or 1, stored.a or 1}
    end
    BetterBlizzPlatesDB[colorType] = stored
    local r, g, b, a = unpack(stored)
    r, g, b, a = r or 1, g or 1, b or 1, a or 1
    BBP.needsUpdate = true

    local function updateColors()
        BetterBlizzPlatesDB[colorType] = {r, g, b, a}
        if icon then
            UpdateColorSquare(icon, r, g, b, a)
        end
        BBP.UpdateAuraTypeColors()
        BBP.RefreshAllNameplates()
        if onChange then onChange() end
        ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
    end

    local function swatchFunc()
        r, g, b = ColorPickerFrame:GetColorRGB()
        a = ColorPickerFrame:GetColorAlpha()
        updateColors()
    end

    local function opacityFunc()
        a = ColorPickerFrame:GetColorAlpha()
        updateColors()
    end

    local function cancelFunc(previousValues)
        if previousValues then
            r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
            updateColors()
        end
    end

    -- Setup and show the color picker
    ColorPickerFrame.previousValues = {r, g, b, a}
    ColorPickerFrame:SetupColorPickerAndShow({
        r = r, g = g, b = b, opacity = a,
        hasOpacity = true,
        swatchFunc = swatchFunc,
        opacityFunc = opacityFunc,
        cancelFunc = cancelFunc,
        previousValues = {r, g, b, a},
    })
end

local function OpenColorOptions(entryColors, func)
    local colorData = entryColors or {0, 1, 0, 1}
    local r, g, b = colorData[1] or 1, colorData[2] or 1, colorData[3] or 1
    local a = colorData[4] or 1

    local function updateColors(newR, newG, newB, newA)
        entryColors[1] = newR
        entryColors[2] = newG
        entryColors[3] = newB
        entryColors[4] = newA or 1

        if func then
            func()
        end
    end

    local function swatchFunc()
        r, g, b = ColorPickerFrame:GetColorRGB()
        updateColors(r, g, b, a)
    end

    local function opacityFunc()
        a = ColorPickerFrame:GetColorAlpha()
        updateColors(r, g, b, a)
    end

    local function cancelFunc(previousValues)
        if previousValues then
            r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
            updateColors(r, g, b, a)
        end
    end

    ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

    ColorPickerFrame:SetupColorPickerAndShow({
        r = r, g = g, b = b, opacity = a, hasOpacity = true,
        swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
    })
end

local function CreateColorBox(parent, colorVar, labelText, onChange)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(55, 20)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

    -- Border Frame (slightly larger to act as a border)
    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetSize(18, 18)
    borderFrame:SetPoint("LEFT", frame, "LEFT", 4, 0)

    local border = borderFrame:CreateTexture(nil, "OVERLAY", nil, 5)
    border:SetAtlas("talents-node-square-gray")
    border:SetAllPoints()

    -- Create the color texture within the border frame
    local colorTexture = borderFrame:CreateTexture(nil, "OVERLAY")
    colorTexture:SetSize(15, 15)
    colorTexture:SetPoint("CENTER", borderFrame, "CENTER", 0, 0)
    local c = BetterBlizzPlatesDB[colorVar]
    if type(c) ~= "table" then
        c = {1, 1, 1, 1}
    elseif c[1] == nil then
        c = {c.r or 1, c.g or 1, c.b or 1, c.a or 1}
    end
    colorTexture:SetColorTexture(c[1], c[2] or 1, c[3] or 1, c[4] or 1)

    -- Label text for the color box
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetText(labelText)
    text:SetPoint("LEFT", borderFrame, "RIGHT", 5, 0)
    frame.text = text
    frame.colorTexture = colorTexture

    -- Make the frame clickable and open a color picker on click
    frame:SetScript("OnMouseDown", function()
        if frame:GetAlpha() == 1 then
            BBP.needsUpdate = true
            OpenColorPicker(colorVar, colorTexture, onChange)
        end
    end)

    local grandparent = parent:GetParent()

    if parent:GetObjectType() == "CheckButton" and (parent:GetChecked() == false or (grandparent:GetObjectType() == "CheckButton" and grandparent:GetChecked() == false)) then
        frame:SetAlpha(0.5)
    else
        frame:SetAlpha(1)
    end

    return frame
end

local function CreateBorderBox(anchor)
    local contentFrame = anchor:GetParent()
    local texture = contentFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAtlas("UI-Frame-Neutral-PortraitWiderDisable")
    texture:SetDesaturated(true)
    texture:SetRotation(math.rad(90))
    texture:SetSize(315, 163)
    texture:SetPoint("CENTER", anchor, "CENTER", 0, -106)
    return texture
end

local function CreateResetButton(relativeTo, settingKey, parent)
    local resetButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    resetButton:SetText(L["Default"])
    resetButton:SetWidth(60)
    resetButton:SetScale(0.85)
    resetButton:SetPoint("LEFT", relativeTo, "RIGHT", 10, 1)
    resetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(relativeTo, settingKey)
        BBP.RefreshAllNameplates()
        BBP.needsUpdate = true
    end)
    return resetButton
end

local function CreateLegacySizedDropdown(parent, width)
    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    local top, bottom = 1, 31 - dropdown:GetHeight()
    dropdown:SetSize(width + 50, 32)
    dropdown:SetHitRectInsets(17, 16, top, bottom)
    for _, region in ipairs({ dropdown.Background, dropdown.Arrow, dropdown.Text }) do
        local points = {}
        for i = 1, region:GetNumPoints() do
            points[i] = { region:GetPoint(i) }
        end
        region:ClearAllPoints()
        for _, p in ipairs(points) do
            local point, relativeTo, relativePoint, x, y = unpack(p)
            if relativeTo == dropdown then
                x = x + (relativePoint:find("LEFT") and 17 or relativePoint:find("RIGHT") and -16 or 0.5)
                y = y + (relativePoint:find("TOP") and -top or relativePoint:find("BOTTOM") and bottom or (bottom - top) / 2)
            end
            region:SetPoint(point, relativeTo, relativePoint, x, y)
        end
    end
    dropdown:SetMenuAnchor(AnchorUtil.CreateAnchor("TOPLEFT", dropdown, "BOTTOMLEFT", 17, bottom + 2))
    dropdown.Background:SetVertexColor(0.9, 0.9, 0.9)
    dropdown.Arrow:SetVertexColor(0.9, 0.9, 0.9)
    return dropdown
end

local function GetIndicatorModes(prefix)
    return {
        { key = prefix .. "One", text = L["Arena_Mode_1"] },
        { key = prefix .. "Two", text = L["Arena_Mode_2"] },
        { key = prefix .. "Three", text = L["Arena_Mode_3"] },
        { key = prefix .. "Four", text = L["Arena_Mode_4"] },
        { key = prefix .. "Five", text = L["Arena_Mode_5"], tooltip = L["Tooltip_Arena_Mode_5_Desc"] },
        { key = prefix .. "Off", text = L["Off"], tooltip = L["Tooltip_Arena_Mode_Off_Desc"] },
    }
end

local function CreateModeDropdown(name, parent, defaultText, toggleFunc, point, modes, textLabel, textColor)
    local function SelectedText()
        for _, mode in ipairs(modes) do
            if BetterBlizzPlatesDB[mode.key] then
                return mode.text
            end
        end
        return defaultText
    end

    local dropdown = CreateLegacySizedDropdown(parent, 135)
    dropdown:SetSelectionText(function()
        return "|cFFFFFF00" .. SelectedText() .. "|r"
    end)

    dropdown:SetupMenu(function(_, rootDescription)
        for _, mode in ipairs(modes) do
            local radio = rootDescription:CreateRadio(mode.text, function()
                return BetterBlizzPlatesDB[mode.key] and true or false
            end, function()
                for _, other in ipairs(modes) do
                    BetterBlizzPlatesDB[other.key] = (other.key == mode.key)
                end
                BBP.needsUpdate = true
                toggleFunc(mode.key)
            end)
            if mode.tooltip then
                radio:SetTooltip(function(tooltip)
                    GameTooltip_SetTitle(tooltip, mode.text)
                    GameTooltip_AddNormalLine(tooltip, mode.tooltip)
                end)
            end
        end
    end)

    -- Position the dropdown
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    -- Create and set up the label
    local dropdownText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local name, _, style = dropdownText:GetFont()

    dropdownText:SetPoint("BOTTOM", dropdown, "TOP", 0, 3)
    dropdownText:SetText(textLabel)
    dropdownText:SetTextColor(unpack(textColor))
    dropdownText:SetFont(name, 10, style)

    return dropdown
end

local function CreateFontDropdown(name, parentFrame, defaultText, settingKey, toggleFunc, point, dropdownWidth, maxVisibleItems)
    maxVisibleItems = maxVisibleItems or 25  -- Default to 25 visible items if not provided

    -- Create container for label and dropdown
    local container = CreateFrame("Frame", nil, parentFrame)
    container:SetSize(dropdownWidth or 155, 50)

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth or 155)
    dropdown:SetDefaultText(BetterBlizzPlatesDB[settingKey])
    dropdown.Background:SetVertexColor(0.9,0.9,0.9)
    dropdown.Arrow:SetVertexColor(0.9,0.9,0.9)

    -- Custom font display for the selected font
    -- dropdown.customFontText = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- dropdown.customFontText:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
    -- dropdown.customFontText:SetText(BetterBlizzPlatesDB[settingKey] or defaultText)
    -- dropdown.customFontText:SetTextColor(1,1,1)
    -- local initialFont = LSM:Fetch(LSM.MediaType.FONT, BetterBlizzPlatesDB[settingKey] or "")
    -- if initialFont then
    --     dropdown.customFontText:SetFont(initialFont, 12)
    -- end

    -- Initialize a unique font pool for this dropdown
    dropdown.fontPool = {}

    -- Fetch and sort fonts
    C_Timer.After(1, function()
        local fonts = LSM:HashTable(LSM.MediaType.FONT)
        local sortedFonts = {}
        for fontName in pairs(fonts) do
            table.insert(sortedFonts, fontName)
        end
        table.sort(sortedFonts)

        -- Define the generator function for the dropdown menu
        local function GeneratorFunction(owner, rootDescription)
            local itemHeight = 20  -- Each item's height
            local maxScrollExtent = maxVisibleItems * itemHeight
            rootDescription:SetScrollMode(maxScrollExtent)

            for index, fontName in ipairs(sortedFonts) do
                local fontPath = fonts[fontName]

                -- Create each item as a button with the custom font
                local button = rootDescription:CreateButton("                                                  ", function()
                    BetterBlizzPlatesDB[settingKey] = fontName
                    -- dropdown.customFontText:SetText(fontName)
                    -- dropdown.customFontText:SetFont(fontPath, 12)
                    dropdown:SetDefaultText(BetterBlizzPlatesDB[settingKey])
                    BBP.needsUpdate = true
                    toggleFunc(fontPath)
                end)

                -- Use the pooled font string for each button
                button:AddInitializer(function(button)
                    local fontDisplay = dropdown.fontPool[index]
                    if not fontDisplay then
                        fontDisplay = dropdown:CreateFontString(nil, "BACKGROUND")
                        dropdown.fontPool[index] = fontDisplay
                    end

                    -- Attach the font display to the button and set the font
                    fontDisplay:SetParent(button)
                    fontDisplay:SetPoint("LEFT", button, "LEFT", 5, 0)
                    fontDisplay:SetFont(fontPath, 12)
                    fontDisplay:SetText(fontName)
                    fontDisplay:Show()
                end)
            end
        end

        -- Hide any unused font strings when the menu is closed
        hooksecurefunc(dropdown, "OnMenuClosed", function()
            for _, fontDisplay in pairs(dropdown.fontPool) do
                fontDisplay:Hide()
            end
        end)

        -- Set up the dropdown menu with the generator function
        dropdown:SetupMenu(GeneratorFunction)
    end)

    -- Position the container on the specified anchor point
    container:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    return dropdown, container
end

local function CreateTextureDropdown(name, parentFrame, labelText, settingKey, toggleFunc, point, dropdownWidth, maxVisibleItems)
    maxVisibleItems = maxVisibleItems or 25  -- Default to 25 visible items if not provided

    -- Create container for label and dropdown
    local container = CreateFrame("Frame", nil, parentFrame)
    container:SetSize(dropdownWidth or 155, 50)

    -- -- Create and position label
    -- local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- label:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 2)
    -- label:SetText(labelText)

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth or 155)
    dropdown:SetDefaultText(BetterBlizzPlatesDB[settingKey] or L["Select_Texture"])
    dropdown.Background:SetVertexColor(0.9,0.9,0.9)
    dropdown.Arrow:SetVertexColor(0.9,0.9,0.9)

    -- Initialize a unique texture pool for this dropdown
    dropdown.texturePool = {}

    -- Fetch and sort textures
    C_Timer.After(1, function()
        local textures = LSM:HashTable(LSM.MediaType.STATUSBAR)
        local sortedTextures = {}
        for textureName in pairs(textures) do
            table.insert(sortedTextures, textureName)
        end
        table.sort(sortedTextures)

        -- Get class colors table
        local classColors = RAID_CLASS_COLORS
        local classKeys = {}
        for class in pairs(classColors) do
            table.insert(classKeys, class)
        end

        -- Define the generator function for the dropdown menu
        local function GeneratorFunction(owner, rootDescription)
            local itemHeight = 20  -- Each item's height
            local maxScrollExtent = maxVisibleItems * itemHeight
            rootDescription:SetScrollMode(maxScrollExtent)

            for index, textureName in ipairs(sortedTextures) do
                local texturePath = textures[textureName]

                -- Create each item as a button with the background texture
                local button = rootDescription:CreateButton(textureName, function()
                    BetterBlizzPlatesDB[settingKey] = textureName
                    dropdown:SetDefaultText(textureName)
                    BBP.needsUpdate = true
                    toggleFunc(texturePath)
                end)

                -- Use the pooled texture for the background on each button
                button:AddInitializer(function(button)
                    local textureBackground = dropdown.texturePool[index]
                    if not textureBackground then
                        textureBackground = dropdown:CreateTexture(nil, "BACKGROUND")
                        dropdown.texturePool[index] = textureBackground
                    end

                    -- Attach the background to the button and set the texture
                    textureBackground:SetParent(button)
                    textureBackground:SetAllPoints(button)
                    textureBackground:SetTexture(texturePath)

                    -- Pick a random class color and apply it
                    local randomClass = classKeys[math.random(#classKeys)]
                    local color = classColors[randomClass]
                    textureBackground:SetVertexColor(color.r, color.g, color.b)

                    textureBackground:Show()
                end)
            end
        end

        hooksecurefunc(dropdown, "OnMenuClosed", function()
            for _, texture in pairs(dropdown.texturePool) do
                texture:Hide()
            end
        end)

        dropdown:SetupMenu(GeneratorFunction)
    end)

    container:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    return dropdown, container
end


local anchorTextCache
local function AnchorText(token)
    if not anchorTextCache then
        anchorTextCache = {
            CENTER = L["Anchor_CENTER"],
            TOPLEFT = L["Anchor_TOPLEFT"],
            TOP = L["Anchor_TOP"],
            TOPRIGHT = L["Anchor_TOPRIGHT"],
            LEFT = L["Anchor_LEFT"],
            RIGHT = L["Anchor_RIGHT"],
            BOTTOMLEFT = L["Anchor_BOTTOMLEFT"],
            BOTTOM = L["Anchor_BOTTOM"],
            BOTTOMRIGHT = L["Anchor_BOTTOMRIGHT"],
            THICKOUTLINE = L["Outline_Thick"],
            OUTLINE = L["Outline_Normal"],
        }
    end
    return token and anchorTextCache[token] or token
end

local function CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point, width, textColor, anchorTypes)
    local dropdown = CreateLegacySizedDropdown(parent, width or 125)
    dropdown:SetDefaultText(AnchorText(BetterBlizzPlatesDB[settingKey] or defaultText))

    local anchorPointsToUse = anchorTypes or anchorPoints
    if name == "targetIndicatorDropdown" then
        anchorPointsToUse = targetIndicatorAnchorPoints
    end

    dropdown:SetupMenu(function(_, rootDescription)
        for _, anchor in ipairs(anchorPointsToUse) do
            rootDescription:CreateRadio(AnchorText(anchor), function()
                return BetterBlizzPlatesDB[settingKey] == anchor
            end, function()
                if BetterBlizzPlatesDB[settingKey] ~= anchor then
                    BetterBlizzPlatesDB[settingKey] = anchor
                    BBP.needsUpdate = true
                    toggleFunc(anchor)
                    BBP.RefreshAllNameplates()
                end
            end)
        end
    end)

    -- Position the dropdown
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    -- Create and set up the label
    local dropdownText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownText:SetPoint("BOTTOM", dropdown, "TOP", 0, 3)
    dropdownText:SetText(point.label)
    if textColor then
        dropdownText:SetTextColor(unpack(textColor))
    end
    dropdown.label = dropdownText

    -- Enable or disable the dropdown based on the parent's check state
    dropdown:SetEnabled(not (parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false))

    return dropdown
end

local function CreateSlider(parent, label, minValue, maxValue, stepValue, element, axis, width)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)
    slider.Text:SetFont(fontSmall, 11)

    slider.Low:SetText(" ")
    slider.High:SetText(" ")

    table.insert(sliderList, {
        slider = slider,
        label = label,
        element = element
    })

    local category
    if parent.name then
        category = parent.name
    elseif parent:GetParent() and parent:GetParent().name then
        category = parent:GetParent().name
    elseif parent:GetParent() and parent:GetParent():GetParent() and parent:GetParent():GetParent().name then
        category = parent:GetParent():GetParent().name
    end

    if category == "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a" then
        category = L["Search_Name_General"]
    end

    slider.searchCategory = category

    if width then
        slider:SetWidth(width)
    end

    local allowsZero = minValue <= 0
    local allowsNegative = minValue < 0

    local function UpdateSliderRange(newValue, minValue, maxValue)
        newValue = tonumber(newValue) -- Convert newValue to a number

        if (axis == "X" or axis == "Y" or allowsNegative) and (newValue < minValue or newValue > maxValue) then
            -- For X or Y axis: extend the range by ±30
            local newMinValue = math.min(newValue - 30, minValue)
            local newMaxValue = math.max(newValue + 30, maxValue)
            slider:SetMinMaxValues(newMinValue, newMaxValue)
        elseif newValue < minValue or newValue > maxValue then
            -- For other sliders: adjust the range, ensuring it never goes below a specified minimum (e.g., 0)
            local nonAxisRangeExtension = 2
            local newMinValue = math.max(newValue - nonAxisRangeExtension, allowsZero and 0 or 0.1)
            local newMaxValue = math.max(newValue + nonAxisRangeExtension, maxValue)
            if element == "classIndicatorAlpha" then
                slider:SetMinMaxValues(newMinValue, 1)
            elseif element == "nameplateFriendlyWidth" or element == "nameplateEnemyWidth" then
                slider:SetMinMaxValues(24, newMaxValue)
            else
                slider:SetMinMaxValues(newMinValue, newMaxValue)
            end
        end
    end

    local function SetSliderValue()
        if BBP.variablesLoaded and BBP.CVarsAreSaved() then
            local initialValue = tonumber(BetterBlizzPlatesDB[element]) -- Convert to number

            if initialValue then
                local currentMin, currentMax = slider:GetMinMaxValues() -- Fetch the latest min and max values

                -- Check if the initial value is outside the current range and update range if necessary
                UpdateSliderRange(initialValue, currentMin, currentMax)

                slider:SetValue(initialValue) -- Set the initial value
                local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
                slider.Text:SetText(label .. ": " .. textValue)
            end
        else
            C_Timer.After(0.1, SetSliderValue)
        end
    end

    SetSliderValue()

    local function SetSliderState()
        if not BBP.variablesLoaded then
            C_Timer.After(0.5, function()
                SetSliderState()
            end)
        else
            if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
                slider:Disable()
                slider:SetAlpha(0.5)
            else
                if parent:GetObjectType() == "CheckButton" and parent:IsEnabled() then
                    slider:Enable()
                    slider:SetAlpha(1)
                elseif parent:GetObjectType() ~= "CheckButton" then
                    slider:Enable()
                    slider:SetAlpha(1)
                end
            end
        end
    end
    SetSliderState()


    -- Create Input Box on Right Click
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetWidth(50)
    editBox:SetHeight(20)
    editBox:SetMultiLine(false)
    editBox:SetPoint("CENTER", slider, "CENTER", 0, 0)
    editBox:SetFrameStrata("TOOLTIP")
    editBox:Hide()

    editBox:SetFontObject(GameFontHighlightSmall)

    local function SliderOnValueChanged(self, value)
        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            BBP.needsUpdate = true
            local textValue = value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
            self.Text:SetText(label .. ": " .. textValue)
            value = tonumber(textValue)
            --if not BBP.checkCombatAndWarn() then
                -- Update the X or Y position based on the axis
                if axis == "X" then
                    BetterBlizzPlatesDB[element .. "XPos"] = value
                elseif axis == "Y" then
                    BetterBlizzPlatesDB[element .. "YPos"] = value
                elseif axis == "Alpha" then
                    BetterBlizzPlatesDB[element .. "Alpha"] = value
                elseif axis == "Height" then
                    BetterBlizzPlatesDB[element .. "Height"] = value
                end

                if not axis then
                    if string.match(element, "Scale$") or string.match(element, "[XY]Pos$") then
                        BetterBlizzPlatesDB[element] = value
                    else
                        BetterBlizzPlatesDB[element .. "Scale"] = value
                    end
                end

                local xPos = BetterBlizzPlatesDB[element .. "XPos"] or 0
                local yPos = BetterBlizzPlatesDB[element .. "YPos"] or 0
                local anchorPoint = BetterBlizzPlatesDB[element .. "Anchor"] or "CENTER"

                --If no nameplates are present still adjust values
                if AURA_SLIDER_ELEMENTS[element] then
                    BetterBlizzPlatesDB[element] = value
                    BBP.RefreshAllNameplateAuras()
                elseif element == "levelEliteIconWidth" or element == "levelEliteIconHeight" or element == "levelEliteIconXPos" or element == "levelEliteIconYPos" or element == "levelTextSize" or element == "levelTextXPos" or element == "levelTextYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.UpdateAllLevelOverlays()
                elseif element == "normalEliteIconWidth" or element == "normalEliteIconHeight" or element == "normalEliteIconXPos" or element == "normalEliteIconYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.UpdateAllEliteIndicators()
                elseif element == "nameplateGeneralHpHeight" then
                    BetterBlizzPlatesDB.nameplateGeneralHpHeight = value
                    if not BBP.checkCombatAndWarn() then
                        BBP.ApplyNameplateWidth()
                        BBP.RefreshAllNameplates()
                    end
                elseif element == "nameplateExtraClickHeight" then
                    BetterBlizzPlatesDB.nameplateExtraClickHeight = value
                    BBP.AdjustAllCickAndStackAreas()
                elseif element == "nameplateExtraClickWidth" then
                    BetterBlizzPlatesDB.nameplateExtraClickWidth = value
                    BBP.AdjustAllCickAndStackAreas()
                elseif element == "nameplateClickVerticalAdjustment" then
                    BetterBlizzPlatesDB.nameplateClickVerticalAdjustment = value
                    BBP.AdjustAllCickAndStackAreas()
                elseif element == "enemyCastbarExtraWidth" or element == "friendlyCastbarExtraWidth" or element == "spacingBetweenCastAndHealthbar" or element == "castBarXPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.nameplateCastBarTestMode()
                    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                        local frame = nameplate.UnitFrame
                        if not frame:IsForbidden() then
                            BBP.SetNameplateBarSizes(frame)
                            if frame.castBar.UpdateBorders then
                                BBP.CreateBetterClassicCastbarBorders(frame)
                            end
                        end
                    end
                -- elseif element == "friendlyCastbarExtraWidth" then
                --     BetterBlizzPlatesDB.friendlyCastbarExtraWidth = value
                --     for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                --         local frame = nameplate.UnitFrame
                --         if not frame:IsForbidden() then
                --             BBP.SetNameplateBarSizes(frame)
                --         end
                --     end

                -- elseif element == "spacingBetweenCastAndHealthbar" then
                --     BetterBlizzPlatesDB.spacingBetweenCastAndHealthbar = value
                --     for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                --         local frame = nameplate.UnitFrame
                --         if not frame:IsForbidden() then
                --             BBP.SetNameplateBarSizes(frame)
                --         end
                --     end
                elseif element == "ccIconScale" then
                    BetterBlizzPlatesDB.ccIconScale = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "ccIconXPos" then
                    BetterBlizzPlatesDB.ccIconXPos = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "ccIconYPos" then
                    BetterBlizzPlatesDB.ccIconYPos = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "buffIconScale" then
                    BetterBlizzPlatesDB.buffIconScale = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "buffIconXPos" then
                    BetterBlizzPlatesDB.buffIconXPos = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "buffIconYPos" then
                    BetterBlizzPlatesDB.buffIconYPos = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "nameplateVerticalPosition" then
                    BetterBlizzPlatesDB.nameplateVerticalPosition = value
                    BBP.AdjustAllCickAndStackAreas()
                elseif element == "nameplateHorizontalPosition" then
                    BetterBlizzPlatesDB.nameplateHorizontalPosition = value
                    BBP.AdjustAllCickAndStackAreas()
                elseif element == "partyPointerScale" then
                    BetterBlizzPlatesDB.partyPointerScale = value
                elseif element == "partyPointerHealerScale" then
                    BetterBlizzPlatesDB.partyPointerHealerScale = value
                elseif element == "partyPointerXPos" then
                    BetterBlizzPlatesDB.partyPointerXPos = value
                elseif element == "partyPointerYPos" then
                    BetterBlizzPlatesDB.partyPointerYPos = value
                elseif element == "partyPointerWidth" then
                    BetterBlizzPlatesDB.partyPointerWidth = value
                elseif element == "partyPointerTexture" then
                    BetterBlizzPlatesDB.partyPointerTexture = value
                    BBP.RefreshAllNameplates()
                elseif element == "partyPointerHighlightScale" then
                    BetterBlizzPlatesDB.partyPointerHighlightScale = value
                    BBP.RefreshAllNameplates()
                elseif element == "hpHeightEnemy" then
                    BetterBlizzPlatesDB.hpHeightEnemy = value
                    BBP.RefreshAllNameplates()
                elseif element == "hpHeightFriendly" then
                    BetterBlizzPlatesDB.hpHeightFriendly = value
                    BBP.RefreshAllNameplates()
                -- elseif element == "hpHeightSelf" then
                --     BetterBlizzPlatesDB.hpHeightSelf = value
                --     BBP.ResizePRD()
                -- elseif element == "hpHeightSelfMana" then
                --     BetterBlizzPlatesDB.hpHeightSelfMana = value
                --     BBP.ResizePRD()
                elseif element == "healthNumbersScale" then
                    BetterBlizzPlatesDB.healthNumbersScale = value
                elseif element == "healthNumbersXPos" then
                    BetterBlizzPlatesDB.healthNumbersXPos = value
                elseif element == "healthNumbersYPos" then
                    BetterBlizzPlatesDB.healthNumbersYPos = value
                elseif element == "fakeNameXPos" then
                    BetterBlizzPlatesDB.fakeNameXPos = value
                elseif element == "fakeNameYPos" then
                    BetterBlizzPlatesDB.fakeNameYPos = value
                elseif element == "fakeNameFriendlyXPos" then
                    BetterBlizzPlatesDB.fakeNameFriendlyXPos = value
                elseif element == "fakeNameFriendlyYPos" then
                    BetterBlizzPlatesDB.fakeNameFriendlyYPos = value
                elseif element == "fakeNameMaxWidth" then
                    BetterBlizzPlatesDB.fakeNameMaxWidth = value
                elseif element == "hideNpcMurlocScale" then
                    BetterBlizzPlatesDB.hideNpcMurlocScale = value
                elseif element == "hideNpcMurlocYPos" then
                    BetterBlizzPlatesDB.hideNpcMurlocYPos = value
                elseif element == "nameplateAuraBuffScale" then
                    BetterBlizzPlatesDB.nameplateAuraBuffScale = value
                elseif element == "nameplateAuraBuffSelfScale" then
                    BetterBlizzPlatesDB.nameplateAuraBuffSelfScale = value
                elseif element == "nameplateAuraDebuffScale" then
                    BetterBlizzPlatesDB.nameplateAuraDebuffScale = value
                elseif element == "nameplateAuraDebuffSelfScale" then
                    BetterBlizzPlatesDB.nameplateAuraDebuffSelfScale = value
                -- Absorb Indicator Pos and Scale
                elseif element == "absorbIndicatorXPos" then
                    BetterBlizzPlatesDB.absorbIndicatorXPos = value
                elseif element == "absorbIndicatorYPos" then
                    BetterBlizzPlatesDB.absorbIndicatorYPos = value
                elseif element == "absorbIndicatorScale" then
                    BetterBlizzPlatesDB.absorbIndicatorScale = value
                -- Combat Indicator Pos and Scale
                elseif element == "combatIndicatorXPos" then
                    BetterBlizzPlatesDB.combatIndicatorXPos = value
                elseif element == "combatIndicatorYPos" then
                    BetterBlizzPlatesDB.combatIndicatorYPos = value
                elseif element == "combatIndicatorScale" then
                    BetterBlizzPlatesDB.combatIndicatorScale = value
                -- Healer Indicator Pos and Scale
                elseif element == "healerIndicatorXPos" then
                    BetterBlizzPlatesDB.healerIndicatorXPos = value
                elseif element == "healerIndicatorYPos" then
                    BetterBlizzPlatesDB.healerIndicatorYPos = value
                elseif element == "healerIndicatorScale" then
                    BetterBlizzPlatesDB.healerIndicatorScale = value
                elseif element == "healerIndicatorEnemyXPos" then
                    BetterBlizzPlatesDB.healerIndicatorEnemyXPos = value
                elseif element == "healerIndicatorEnemyYPos" then
                    BetterBlizzPlatesDB.healerIndicatorEnemyYPos = value
                elseif element == "healerIndicatorEnemyScale" then
                    BetterBlizzPlatesDB.healerIndicatorEnemyScale = value
                -- Pet Indicator Pos and Scale
                elseif element == "petIndicatorXPos" then
                    BetterBlizzPlatesDB.petIndicatorXPos = value
                elseif element == "petIndicatorYPos" then
                    BetterBlizzPlatesDB.petIndicatorYPos = value
                elseif element == "petIndicatorScale" then
                    BetterBlizzPlatesDB.petIndicatorScale = value
                -- Quest Indicator Pos and Scale
                elseif element == "questIndicatorXPos" then
                    BetterBlizzPlatesDB.questIndicatorXPos = value
                elseif element == "questIndicatorYPos" then
                    BetterBlizzPlatesDB.questIndicatorYPos = value
                elseif element == "questIndicatorScale" then
                    BetterBlizzPlatesDB.questIndicatorScale = value
                -- Execute Indicator Pos and Scale
                elseif element == "executeIndicatorXPos" then
                    BetterBlizzPlatesDB.executeIndicatorXPos = value
                elseif element == "executeIndicatorYPos" then
                    BetterBlizzPlatesDB.executeIndicatorYPos = value
                elseif element == "executeIndicatorScale" then
                    BetterBlizzPlatesDB.executeIndicatorScale = value
                -- Faction Indicator Pos and Scale
                elseif element == "factionIndicatorXPos" then
                    BetterBlizzPlatesDB.factionIndicatorXPos = value
                elseif element == "factionIndicatorYPos" then
                    BetterBlizzPlatesDB.factionIndicatorYPos = value
                elseif element == "factionIndicatorScale" then
                    BetterBlizzPlatesDB.factionIndicatorScale = value
                -- Target Indicator Pos and Scale
                elseif element == "targetIndicatorXPos" then
                    BetterBlizzPlatesDB.targetIndicatorXPos = value
                elseif element == "targetIndicatorYPos" then
                    BetterBlizzPlatesDB.targetIndicatorYPos = value
                elseif element == "targetIndicatorScale" then
                    BetterBlizzPlatesDB.targetIndicatorScale = value
                -- Focus Target Indicator Pos and Scale
                elseif element == "focusTargetIndicatorXPos" then
                    BetterBlizzPlatesDB.focusTargetIndicatorXPos = value
                elseif element == "focusTargetIndicatorYPos" then
                    BetterBlizzPlatesDB.focusTargetIndicatorYPos = value
                elseif element == "focusTargetIndicatorScale" then
                    BetterBlizzPlatesDB.focusTargetIndicatorScale = value
                -- Raidmarker Indicator Pos and Scale
                elseif element == "raidmarkIndicatorXPos" then
                    BetterBlizzPlatesDB.raidmarkIndicatorXPos = value
                elseif element == "raidmarkIndicatorYPos" then
                    BetterBlizzPlatesDB.raidmarkIndicatorYPos = value
                elseif element == "raidmarkIndicatorScale" then
                    BetterBlizzPlatesDB.raidmarkIndicatorScale = value
                -- Bg Blitz
                elseif element == "bgIndicatorXPos" then
                    BetterBlizzPlatesDB.bgIndicatorXPos = value
                elseif element == "bgIndicatorYPos" then
                    BetterBlizzPlatesDB.bgIndicatorYPos = value
                elseif element == "bgIndicatorScale" then
                    BetterBlizzPlatesDB.bgIndicatorScale = value
                -- Target Text
                elseif element == "npTargetTextXPos" then
                    BetterBlizzPlatesDB.npTargetTextXPos = value
                    BBP.RefreshAllNameplates()
                elseif element == "npTargetTextYPos" then
                    BetterBlizzPlatesDB.npTargetTextYPos = value
                    BBP.RefreshAllNameplates()
                elseif element == "npTargetTextSize" then
                    BetterBlizzPlatesDB.npTargetTextSize = value
                    BBP.RefreshAllNameplates()
                elseif element == "npTargetTextFriendlyXPos" then
                    BetterBlizzPlatesDB.npTargetTextFriendlyXPos = value
                    BBP.RefreshAllNameplates()
                elseif element == "npTargetTextFriendlyYPos" then
                    BetterBlizzPlatesDB.npTargetTextFriendlyYPos = value
                    BBP.RefreshAllNameplates()
                elseif element == "npTargetTextFriendlySize" then
                    BetterBlizzPlatesDB.npTargetTextFriendlySize = value
                    BBP.RefreshAllNameplates()
                -- Totem Indicator Pos and Scale
                elseif element == "totemIndicatorXPos" then
                    BetterBlizzPlatesDB.totemIndicatorXPos = value
                elseif element == "totemIndicatorYPos" then
                    BetterBlizzPlatesDB.totemIndicatorYPos = value
                elseif element == "totemIndicatorScale" then
                    BetterBlizzPlatesDB.totemIndicatorScale = value
                elseif element == "executeIndicatorThreshold" then
                    BetterBlizzPlatesDB.executeIndicatorThreshold = value
                elseif element == "castBarHeight" then
                    BetterBlizzPlatesDB.castBarHeight = value
                elseif element == "castBarTextScale" then
                    BetterBlizzPlatesDB.castBarTextScale = value
                elseif element == "castBarTextXPos" or element == "castBarTextYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.UpdateAllCastbarTextPositions()
                elseif element == "castTimerXPos" or element == "castTimerYPos" or element == "npCastTimerSize" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.UpdateAllCastTimers()
                elseif element == "castBarIconScale" then
                    BetterBlizzPlatesDB.castBarIconScale = value
                elseif element == "castBarIconXPos" then
                    BetterBlizzPlatesDB.castBarIconXPos = value
                elseif element == "castBarIconYPos" then
                    BetterBlizzPlatesDB.castBarIconYPos = value
                elseif element == "castBarEmphasisSparkHeight" then
                    BetterBlizzPlatesDB.castBarEmphasisSparkHeight = value
                elseif element == "castBarEmphasisIconScale" then
                    BetterBlizzPlatesDB.castBarEmphasisIconScale = value
                elseif element == "classIndicatorXPos" then
                    BetterBlizzPlatesDB.classIndicatorXPos = value
                elseif element == "classIndicatorYPos" then
                    BetterBlizzPlatesDB.classIndicatorYPos = value
                elseif element == "classIndicatorScale" then
                    BetterBlizzPlatesDB.classIndicatorScale = value
                elseif element == "classIndicatorAlpha" then
                    BetterBlizzPlatesDB.classIndicatorAlpha = value
                elseif element == "classIndicatorFriendlyXPos" then
                    BetterBlizzPlatesDB.classIndicatorFriendlyXPos = value
                elseif element == "classIndicatorFriendlyYPos" then
                    BetterBlizzPlatesDB.classIndicatorFriendlyYPos = value
                elseif element == "classIndicatorFriendlyScale" then
                    BetterBlizzPlatesDB.classIndicatorFriendlyScale = value
                elseif element == "classIndicatorBackgroundSize" then
                    BetterBlizzPlatesDB.classIndicatorBackgroundSize = value
                    -- Nameplate Widths
                elseif element == "nameplateFriendlyWidth" then
                    BetterBlizzPlatesDB.nameplateFriendlyWidth = value
                    BBP.ApplyNameplateWidth()
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local frame = np.UnitFrame
                        if frame then
                            BBP.SetNameplateBarSizes(frame)
                        end
                    end
                elseif element == "nameplateEnemyWidth" then
                    BetterBlizzPlatesDB.nameplateEnemyWidth = value
                    BBP.ApplyNameplateWidth()
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local frame = np.UnitFrame
                        if frame then
                            BBP.SetNameplateBarSizes(frame)
                        end
                    end
                -- elseif element == "nameplateSelfWidth" then
                --     BetterBlizzPlatesDB.nameplateSelfWidth = value
                --     BBP.ResizePRD()
                elseif element == "smallPetsWidth" then
                    BetterBlizzPlatesDB.smallPetsWidth = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local petFrame = np.UnitFrame
                        if petFrame then
                            BBP.SmallPetsInPvP(petFrame)
                            BBP.NameplateShadowAndMouseoverHighlight(petFrame)
                        end
                    end
                elseif element == "smallPetsSmallerWidth" then
                    BetterBlizzPlatesDB.smallPetsSmallerWidth = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local petFrame = np.UnitFrame
                        if petFrame then
                            BBP.SmallPetsInPvP(petFrame)
                            BBP.NameplateShadowAndMouseoverHighlight(petFrame)
                        end
                    end
                elseif element == "smallPetsHeight" then
                    BetterBlizzPlatesDB.smallPetsHeight = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local petFrame = np.UnitFrame
                        if petFrame then
                            BBP.SmallPetsInPvP(petFrame)
                            BBP.NameplateShadowAndMouseoverHighlight(petFrame)
                        end
                    end
                elseif element == "smallPetsSmallerHeight" then
                    BetterBlizzPlatesDB.smallPetsSmallerHeight = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local petFrame = np.UnitFrame
                        if petFrame then
                            BBP.SmallPetsInPvP(petFrame)
                            BBP.NameplateShadowAndMouseoverHighlight(petFrame)
                        end
                    end
                -- Cast bar emphasis height
                elseif element == "castBarEmphasisHeightValue" then
                    BetterBlizzPlatesDB.castBarEmphasisHeightValue = value
                -- Cast bar emphasis text scale
                elseif element == "castBarEmphasisTextScale" then
                    BetterBlizzPlatesDB.castBarEmphasisTextScale = value
                -- Enemy Nameplate height
                elseif element == "enemyNameplateHealthbarHeight" then
                    BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = value
                    --BBP.DefaultCompactNamePlateFrameAnchorInternal(frame, setupOptions)
                elseif element == "maxAurasOnNameplate" then
                    BetterBlizzPlatesDB.maxAurasOnNameplate = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraRowAmount" then
                    BetterBlizzPlatesDB.nameplateAuraRowAmount = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraRowFriendlyAmount" then
                    BetterBlizzPlatesDB.nameplateAuraRowFriendlyAmount = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraWidthGap" then
                    BetterBlizzPlatesDB.nameplateAuraWidthGap = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraHeightGap" then
                    BetterBlizzPlatesDB.nameplateAuraHeightGap = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraHeightGap" then
                    BetterBlizzPlatesDB.nameplateAuraHeightGap = value
                    BBP.RefreshBuffFrame()
                elseif element == "defaultNpAuraCdSize" then
                    BetterBlizzPlatesDB.defaultNpAuraCdSize = value
                    BBP.UpdateAllNameplatesAuras()
                elseif element == "targetNameplateAuraScale" then
                    BetterBlizzPlatesDB.targetNameplateAuraScale = value
                    BBP.RefreshBuffFrame()
                    local nameplate, frame = BBP.GetSafeNameplate("target")
                    if frame then
                        BBP.TargetNameplateAuraSize(frame)
                    end
                elseif element == "nameplateAuraCountScale" then
                    BetterBlizzPlatesDB.nameplateAuraCountScale = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateBorderSize" then
                    BetterBlizzPlatesDB.nameplateBorderSize = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local frame = np.UnitFrame
                        if frame then
                            frame.BetterBlizzPlates.config.nameplateBorderSize = value
                            BBP.ChangeHealthbarBorderSize(frame)
                        end
                    end
                elseif element == "nameplateTargetBorderSize" then
                    BetterBlizzPlatesDB.nameplateTargetBorderSize = value
                    local np, frame = BBP.GetSafeNameplate("target")
                    if frame then
                        frame.BetterBlizzPlates.config.nameplateTargetBorderSize = value
                        BBP.ChangeHealthbarBorderSize(frame)
                    end
                elseif element == "nameplatePersonalBorderSize" then
                    BetterBlizzPlatesDB.nameplatePersonalBorderSize = value
                    local frame = PersonalResourceDisplayFrame
                    if frame then
                        BBP.ChangeHealthbarBorderSize(frame)
                    end
                    if BBP.LegacyPRDLookEnabled then
                        BBP.LegacyPRDLook()
                    end
                elseif element == "totemIndicatorDefaultCooldownTextSize" then
                    BetterBlizzPlatesDB.totemIndicatorDefaultCooldownTextSize = value
                elseif element == "left" then
                    BetterBlizzPlatesDB.left = value
                elseif element == "right" then
                    BetterBlizzPlatesDB.right = value
                elseif element == "top" then
                    BetterBlizzPlatesDB.top = value
                elseif element == "bottom" then
                    BetterBlizzPlatesDB.bottom = value
                    -- Nameplate scales
                elseif element == "nameplateMinScale" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMinScale", value)
                        C_CVar.SetCVar("nameplateMaxScale", value)
                        BetterBlizzPlatesDB.nameplateMinScale = value
                        BetterBlizzPlatesDB.nameplateMaxScale = value
                    end
                -- Nameplate selected scale
                elseif element == "nameplateSelectedScale" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateSelectedScale", value)
                        BetterBlizzPlatesDB.nameplateSelectedScale = value
                    end
                elseif element == "stackingVerticalAdjustmentOffset" or element == "stackingHorizontalOffset" or element == "stackingVerticalOffset" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.AdjustAllCickAndStackAreas("zone")
                elseif element == "nameplateBoxHeight" then
                    BetterBlizzPlatesDB.nameplateBoxHeight = value
                    BBP.AdjustAllCickAndStackAreas("space")
                elseif element == "nameplateOverlapH" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateOverlapH", value)
                    end
                    BetterBlizzPlatesDB.nameplateOverlapH = value
                elseif element == "nameplateOverlapV" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateOverlapV", value)
                    end
                    BetterBlizzPlatesDB.nameplateOverlapV = value
                elseif element == "nameplateMotionSpeed" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMotionSpeed", value)
                    end
                    BetterBlizzPlatesDB.nameplateMotionSpeed = value
                elseif element == "nameplateMinAlpha" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMinAlpha", value)
                        BetterBlizzPlatesDB.nameplateMinAlpha = value
                    end
                elseif element == "nameplateMinAlphaDistance" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMinAlphaDistance", value)
                        BetterBlizzPlatesDB.nameplateMinAlphaDistance = value
                    end
                elseif element == "nameplateMaxAlpha" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMaxAlpha", value)
                        BetterBlizzPlatesDB.nameplateMaxAlpha = value
                    end
                elseif element == "nameplateSimplifiedScale" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateSimplifiedScale", value)
                        BetterBlizzPlatesDB.nameplateSimplifiedScale = value
                    end
                elseif element == "nameplateMaxAlphaDistance" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMaxAlphaDistance", value)
                        BetterBlizzPlatesDB.nameplateMaxAlphaDistance = value
                    end
                elseif element == "nameplateOccludedAlphaMult" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateOccludedAlphaMult", value)
                        BetterBlizzPlatesDB.nameplateOccludedAlphaMult = value
                    end
                elseif element == "nameplateDebuffXPadding" then
                    BetterBlizzPlatesDB.nameplateDebuffXPadding = value
                    BBP.UpdateAllNameplatesAuras()
                    -- Friendly name scale
                elseif element == "friendlyNameScale" then
                    if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                        BBP.hasPrintedTestModeWarning = false
                        BetterBlizzPlatesDB.friendlyNameScale = value
                    else
                        if not BBP.hasPrintedTestModeWarning then
                            print(L["Print_ArenaID_Test_Mode_Active_Disable_To"])
                            BBP.hasPrintedTestModeWarning = true
                        end
                    end
                -- Enemy name scale
                elseif element == "enemyNameScale" then
                    if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                        BBP.hasPrintedTestModeWarning = false
                        BetterBlizzPlatesDB.enemyNameScale = value
                    else
                        if not BBP.hasPrintedTestModeWarning then
                            print(L["Print_ArenaID_Test_Mode_Active_Disable_To"])
                            BBP.hasPrintedTestModeWarning = true
                        end
                    end
                -- Arena ID scale
                elseif element == "arenaIDScale" then
                    BetterBlizzPlatesDB.arenaIDScale = value
                    BBP.RefreshAllNameplatesLightVer()
                -- Arena spec scale
                elseif element == "arenaSpecScale" then
                    BetterBlizzPlatesDB.arenaSpecScale = value
                    BBP.RefreshAllNameplatesLightVer()
                -- Party ID scale
                elseif element == "partyIDScale" then
                    BetterBlizzPlatesDB.partyIDScale = value
                    BBP.RefreshAllNameplatesLightVer()
                -- Party spec scale
                elseif element == "partySpecScale" then
                    BetterBlizzPlatesDB.partySpecScale = value
                    BBP.RefreshAllNameplatesLightVer()
                elseif element == "arenaIdXPos" then
                    BetterBlizzPlatesDB.arenaIdXPos = value
                    BBP.RefreshAllNameplatesLightVer()
                elseif element == "arenaIdYPos" then
                    BetterBlizzPlatesDB.arenaIdYPos = value
                    BBP.RefreshAllNameplatesLightVer()
                elseif element == "arenaSpecXPos" then
                    BetterBlizzPlatesDB.arenaSpecXPos = value
                    BBP.RefreshAllNameplatesLightVer()
                elseif element == "arenaSpecYPos" then
                    BetterBlizzPlatesDB.arenaSpecYPos = value
                    BBP.RefreshAllNameplatesLightVer()
                elseif element == "guildNameScale" or element == "guildNameEnemyScale" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.RefreshAllNameplates()
                elseif element == "npcTitleScale" then
                    BetterBlizzPlatesDB.npcTitleScale = value
                    BBP.RefreshAllNameplates()
                elseif element == "friendIndicatorScale" then
                    BetterBlizzPlatesDB.friendIndicatorScale = value
                    BBP.RefreshAllNameplates()
                elseif element == "nameplateResourceScale" then
                    BetterBlizzPlatesDB.nameplateResourceScale = value
                    BBP.TargetResourceUpdater()
                elseif element == "nameplateResourceXPos" then
                    BetterBlizzPlatesDB.nameplateResourceXPos = value
                    BBP.TargetResourceUpdater()
                elseif element == "nameplateResourceYPos" then
                    BetterBlizzPlatesDB.nameplateResourceYPos = value
                    BBP.TargetResourceUpdater()
                elseif element == "darkModeNameplateColor" then
                    BetterBlizzPlatesDB.darkModeNameplateColor = value
                    BBP.DarkModeNameplateResources()
                elseif element == "castBarInterruptHighlighterStartTime" then
                    BetterBlizzPlatesDB.castBarInterruptHighlighterStartTime = value
                elseif element == "castBarInterruptHighlighterEndTime" then
                    BetterBlizzPlatesDB.castBarInterruptHighlighterEndTime = value
                elseif element == "customFontSize" then
                    BetterBlizzPlatesDB.customFontSize = value
                    BBP.RefreshAllNameplates()
                elseif element == "nameplateNonTargetAlpha" then
                    BetterBlizzPlatesDB.nameplateNonTargetAlpha = value
                    BBP.RefreshAllNameplates()
                -- Nameplate Widths
                elseif element == "nameplateFriendlyWidth" then
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateFriendlyWidth = value
                        local heightValue
                        if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
                            heightValue = 1
                        else
                            heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        end
                    C_NamePlate.SetNamePlateSize(value, heightValue)
                    end
                elseif element == "nameplateEnemyWidth" then
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateEnemyWidth = value
                        local heightValue
                        heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        C_NamePlate.SetNamePlateSize(value, heightValue)
                    end
                elseif element == "fadeOutNPCsAlpha" then
                    if axis then
                        BetterBlizzPlatesDB.fadeOutNPCsAlpha = value
                    end
                end

                for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                    if namePlate.UnitFrame then
                        local frame = namePlate.UnitFrame
                        local nameplate = namePlate
                        if frame:IsForbidden() or frame:IsProtected() then return end
                        -- Absorb Indicator Pos and Scale
                        if element == "absorbIndicatorXPos" or element == "absorbIndicatorYPos" or element == "absorbIndicatorScale" then
                            BBP.AbsorbIndicator(frame)
                        -- Combat Indicator Pos and Scale
                        elseif element == "combatIndicatorXPos" or element == "combatIndicatorYPos" or element == "combatIndicatorScale" then
                            BBP.CombatIndicator(frame)
                        -- Healer Indicator Pos and Scale
                        elseif element == "healerIndicatorXPos" or element == "healerIndicatorYPos" or element == "healerIndicatorScale" or element == "healerIndicatorEnemyXPos" or element == "healerIndicatorEnemyYPos" or element == "healerIndicatorEnemyScale" then
                            BBP.HealerIndicator(frame)
                        -- Healer Indicator Pos and Scale
                        elseif element == "classIndicatorXPos" or element == "classIndicatorYPos" or element == "classIndicatorScale" or element == "classIndicatorFriendlyXPos" or element == "classIndicatorFriendlyYPos" or element == "classIndicatorFriendlyScale" or element == "classIndicatorAlpha" or element == "classIndicatorBackgroundSize" then
                            BBP.ClassIndicator(frame)
                        -- Pet Indicator Pos and Scale
                        elseif element == "petIndicatorXPos" or element == "petIndicatorYPos" or element == "petIndicatorScale" then
                            BBP.PetIndicator(frame)
                        -- Quest Indicator Pos and Scale
                        elseif element == "questIndicatorXPos" or element == "questIndicatorYPos" or element == "questIndicatorScale" then
                            BBP.QuestIndicator(frame)
                        -- Execute Indicator Pos and Scale
                        elseif element == "executeIndicatorXPos" or element == "executeIndicatorYPos" or element == "executeIndicatorScale" or element == "executeSkullScale" or element == "executeSkullXPos" or element == "executeSkullYPos" then
                            BBP.ExecuteIndicator(frame)
                        -- Faction Indicator Pos and Scale
                        elseif element == "factionIndicatorXPos" or element == "factionIndicatorYPos" or element == "factionIndicatorScale" then
                            BBP.FactionIndicator(frame)
                        -- Party Pointer Pos and Scale
                        elseif element == "partyPointerXPos" or element == "partyPointerYPos" or element == "partyPointerScale"  or element == "partyPointerHealerScale" or element == "partyPointerWidth" then
                            BBP.PartyPointer(frame)
                        elseif element == "hideNpcMurlocScale" or element == "hideNpcMurlocYPos" then
                            BBP.HideNPCs(frame, nameplate)
                        elseif element == "fakeNameXPos" or element == "fakeNameYPos" or element == "fakeNameFriendlyXPos" or element == "fakeNameFriendlyYPos" or element == "fakeNameMaxWidth" then
                            BBP.RepositionName(frame)
                        -- Target Indicator Pos and Scale
                        elseif element == "targetIndicatorXPos" or element == "targetIndicatorYPos" or element == "targetIndicatorScale" then
                            BBP.TargetIndicator(frame)
                        -- Focus Target Indicator Pos and Scale
                        elseif element == "focusTargetIndicatorXPos" or element == "focusTargetIndicatorYPos" or element == "focusTargetIndicatorScale" then
                            BBP.FocusTargetIndicator(frame)
                        -- Totem Indicator cooldown text size
                        elseif element == "totemIndicatorDefaultCooldownTextSize" then
                            if BetterBlizzPlatesDB.totemIndicator and frame.BetterBlizzPlates and frame.BetterBlizzPlates.config then
                                BBP.ApplyTotemIconsAndColorNameplate(frame)
                            end
                        elseif element == "healthNumbersScale" or element == "healthNumbersXPos" or element == "healthNumbersYPos" then
                            BBP.HealthNumbers(frame)
                        -- Cast Timer Pos and Scale
                        elseif element == "castTimer" then
                            --not rdy
                        -- Cast bar icon pos and scale
                        elseif element == "castBarIconXPos" or element == "castBarIconYPos" or element == "castBarIconScale" then
                            if axis then
                                BBP.SetNameplateBarSizes(frame)
                                if not BBP.UsesClassicCastbar() then
                                    frame.castBar.BorderShield:ClearAllPoints()
                                    frame.castBar.BorderShield:SetPoint("CENTER", frame.castBarIconFrame, "CENTER", 0, 0)
                                end
                            else
                                BetterBlizzPlatesDB.castBarIconScale = value
                                frame.castBarIconFrame:SetScale(BBP.GetCastIconScale())
                                --frame.castBar.BorderShield:SetScale(value)
                            end
                        -- Cast bar height
                        elseif element == "castBarHeight" then
                            frame.castBar:SetHeight(value)
                            frame.CastBarsContainer:SetHeight(value)
                            if BetterBlizzPlatesDB.classicNameplates and frame.castBar.UpdateBorders then
                                frame.castBar.UpdateBorders()
                            end
                            BBP.SetNameplateBarSizes(frame)
                        elseif element == "castBarTextScale" then
                            frame.castBar.Text:SetScale(value)
                        -- Cast bar emphasis icon pos and scale
                        elseif element == "castBarEmphasisIconXPos" or element == "castBarEmphasisIconYPos" then
                            if axis then
                                frame.castBar.Icon:SetPoint("CENTER", frame.castBar, "LEFT", xPos, yPos)
                            end
                        -- Target Text for Cast Timer Pos and Scale
                        elseif element == "targetText" then
                        -- Raidmarker Pos and Scale
                        elseif element == "raidmarkIndicatorXPos" or element == "raidmarkIndicatorYPos" or element == "raidmarkIndicatorScale" then
                            if BetterBlizzPlatesDB.raidmarkIndicator then
                                -- if frame.RaidTargetFrame.RaidTargetIcon then
                                --     if axis then
                                --         if anchorPoint == "TOP" then
                                --             frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                                --             frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.name, anchorPoint, xPos, yPos)
                                --         else
                                --             frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                                --             frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.healthBar, anchorPoint, xPos, yPos)
                                --         end
                                --     else
                                --         frame.RaidTargetFrame.RaidTargetIcon:SetScale(value)
                                --     end
                                -- end
                                BBP.ApplyRaidmarkerChanges(frame)
                            end
                        -- Friendly name scale
                        elseif element == "friendlyNameScale" then
                            if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                                BBP.ClassColorAndScaleNames(frame)
                            end
                        -- Enemy name scale
                        elseif element == "enemyNameScale" then
                            if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                                BBP.ClassColorAndScaleNames(frame)
                            end
                        elseif element == "fadeOutNPCsAlpha" then
                            if axis then
                                BBP.FadeOutNPCs(frame)
                            end
                        end
                    end
                end
            end
        --end
    end

    -- Function to handle the entered value and update the slider
    local function HandleEditBoxInput()
        local inputValue = tonumber(editBox:GetText())
        if inputValue then
            if (axis ~= "X" and axis ~= "Y") and not allowsZero
                and (inputValue <= 0 or (element == "classIndicatorAlpha" and inputValue >= 1)) then
                inputValue = 0.1  -- Set to minimum allowed value for non-axis sliders
                if element == "classIndicatorAlpha" then
                    inputValue = 1
                end
            end

            -- Force minimum value of 24 for nameplate widths
            if (element == "nameplateFriendlyWidth" or element == "nameplateEnemyWidth") and inputValue < 24 then
                inputValue = 24
            end

            local currentMin, currentMax = slider:GetMinMaxValues()
            if inputValue < currentMin or inputValue > currentMax then
                UpdateSliderRange(inputValue, currentMin, currentMax)
            end

            slider:SetValue(inputValue)
            SliderOnValueChanged(slider, inputValue) -- Call the OnValueChanged functionality explicitly
            BetterBlizzPlatesDB[element] = inputValue
        end
        editBox:Hide()
        BBP.RefreshAllNameplates()
    end

    slider:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            editBox:Show()
            editBox:SetFocus()
        end
    end)

    editBox:SetScript("OnEnterPressed", HandleEditBoxInput)
    slider:SetScript("OnValueChanged", SliderOnValueChanged)
    slider:SetScript("OnMouseWheel", function(slider, delta)
        if IsShiftKeyDown() then
            local currentVal = slider:GetValue()
            if delta > 0 then
                slider:SetValue(currentVal + stepValue)
            else
                slider:SetValue(currentVal - stepValue)
            end
        end
    end)

    return slider
end

local function CreateTooltip(widget, tooltipText, anchor, cvarName)
    widget.tooltipTitle = tooltipText
    widget:SetScript("OnEnter", function(self)
        local finalTooltipText = tooltipText -- Start with the original tooltip text
        if cvarName then
            -- Append the additional text if cvarName is provided
            finalTooltipText = finalTooltipText .. "\n\n" .. string.format(L["Tooltip_Controls_CVar"], cvarName)
        end

        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:SetText(finalTooltipText)

        GameTooltip:Show()

        ApplyGuiFontToTooltip()
    end)

    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function CreateTooltipTwo(widget, title, mainText, subText, anchor, cvarName, cvarName2, category)
    widget.tooltipTitle = title
    widget.tooltipMainText = mainText
    widget.tooltipSubText = subText
    widget.tooltipCVarName = cvarName
    widget:SetScript("OnEnter", function(self)
        -- Clear the tooltip before showing new information
        GameTooltip:ClearLines()
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end
        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        -- Set the bold title
        GameTooltip:AddLine(title)
        --GameTooltip:AddLine(" ") -- Adding an empty line as a separator
        -- Set the main text
        GameTooltip:AddLine(mainText, 1, 1, 1, true) -- true for wrap text
        -- Add the "Right-click to show on Target" text with checkmark depending on BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget
        if widget == BBP.friendlyHideHealthBar then
            local showOnTarget = BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget
            local tooltipText = "|cff32f795" .. L["Tooltip_Right_Click_To_Keep_Them_Enabled"] .. "|r"

            -- Add or remove the checkmark based on the value of showOnTarget
            if showOnTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            tooltipText = tooltipText .. "\n\n|cffc084f7" .. L["Tooltip_Shift_Plus_Right_Click_To_Keep"] .. "|r"

            if BetterBlizzPlatesDB.friendlyHideHealthBarShowTanksAndHeals then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            if BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerHideAll then
                tooltipText = tooltipText .. "\n\n" .. L["Tooltip_Party_Pointer_Hide_All_Setting_Is"]
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Hide_NPC_Healthbar"] then
            local hideFriendlyHpNpcPve = BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Keep_NPC_Healthbars"] .. "|r"

            if hideFriendlyHpNpcPve then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            tooltipText = tooltipText .. "\n\n|cffc084f7" .. L["Tooltip_Shift_Plus_Right_Click_To_Keep_2"] .. "|r"
            if BetterBlizzPlatesDB.friendlyHideHealthBarShowPet then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Hide_Enemy_Castbar"] then
            local showOnTarget = BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget
            local tooltipText = "|cff32f795" .. L["Tooltip_Right_Click_To_Keep_Them_Enabled"] .. "|r"

            -- Add or remove the checkmark based on the value of showOnTarget
            if showOnTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            if BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerHideAll then
                tooltipText = tooltipText .. "\n\n" .. L["Tooltip_Party_Pointer_Hide_All_Setting_Is"]
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Hide_Castbar_Text"] then
            local alsoHideInt = BetterBlizzPlatesDB.hideCastbarTextInt
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Also_Hide_The"] .. "|r"

            if alsoHideInt then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Hide_Friendly_Castbar"] then
            local showOnTarget = BetterBlizzPlatesDB.alwaysHideFriendlyCastbarShowTarget
            local tooltipText = "|cff32f795" .. L["Tooltip_Right_Click_To_Keep_Them_Enabled"] .. "|r"

            -- Add or remove the checkmark based on the value of showOnTarget
            if showOnTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            if BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerHideAll then
                tooltipText = tooltipText .. "\n\n" .. L["Tooltip_Party_Pointer_Hide_All_Setting_Is"]
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Color_Focus_Nameplate_Healthbar"] then
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Disable_While_In"] .. "|r"
            if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP then
                tooltipText = tooltipText .. "\n" .. L["Tooltip_Disabled_In_PvP"] .. " |A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Purgeable"] then
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Only_Show_Purgeable"] .. "|r"
            if BetterBlizzPlatesDB.otherNpBuffFilterPurgeablePvEOnly then
                tooltipText = tooltipText .. "\n" .. L["Tooltip_Only_In_PvE_Enabled"] .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            local onlyShowIfPurge = BetterBlizzPlatesDB.otherNpBuffFilterPurgeableHasPurge
            tooltipText = tooltipText.."\n\n|cff32f795" .. L["Tooltip_Shift_Right_Click_To_Only_Show"] .. "|r"

            if onlyShowIfPurge then
                tooltipText = tooltipText .. "\n" .. L["Tooltip_Only_In_Show_If_Have_A"] .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Hide_Enemy_Name"] then
            local forceShowTotems = BetterBlizzPlatesDB.forceShowTotemNames
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Keep_Totem_Names"] .. "|r"

            if forceShowTotems then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            tooltipText = tooltipText .. "\n\n|cffc084f7" .. L["Tooltip_Shift_Plus_Right_Click_To_Keep_3"] .. "|r"

            if BetterBlizzPlatesDB.hideNameShowTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Sort_Auras_By_Duration"] then
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Reverse_Duration_Sort"] .. "|r"
            if BetterBlizzPlatesDB.sortDurationAurasReverse then
                tooltipText = tooltipText .. "\n" .. L["Tooltip_Reverse_Sorting"] .. "|A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Castbar_Background_Color"] then
            local redBg = BetterBlizzPlatesDB.redBgCastColor
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Color_The_Background"] .. "|r"

            if redBg then
                tooltipText = tooltipText .. "\n|cff32f795" .. L["Enabled"] .. " |A:ParagonReputation_Checkmark:15:15|a"
            else
                tooltipText = tooltipText .. "\n|cFFFFD100" .. L["Disabled"] .. " |A:lootroll-toast-icon-pass-up:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Center_Auras_On_Enemy"] then
            local centerBuffsOnly = BetterBlizzPlatesDB.nameplateCenterOnlyBuffs
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Only_Center_Buffs"] .. "|r"

            if centerBuffsOnly then
                tooltipText = tooltipText .. "\n|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Nameplate_Resource"] then
            local showOnPlayerWithoutTarget = BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Show_Resource_On"] .. "|r"

            if showOnPlayerWithoutTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Friend_Guildie_Indicator"] then
            local currentAnchor = BetterBlizzPlatesDB.friendIndicatorAnchor or "LEFT"
            local tooltipText = "\n|cff32f795" .. string.format(L["Tooltip_Right_Click_Change_Anchor"], AnchorText(currentAnchor)) .. "|r"
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Show_Crowd_Control"] then
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Hide_The_Cooldown"] .. "|r"

            if BetterBlizzPlatesDB.classIndicatorCCHideCdText then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Castbar_Quick_Hide"] then
            local tooltipText = "\n|cff32f795" .. L["Right_Click_Quick_Hide_Castbars_Always"] .. "|r"

            if BetterBlizzPlatesDB.castbarQuickHideAlways then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        -- Set the subtext
        if subText then
            GameTooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(subText, 0.8, 0.80, 0.80, true)
        end
        -- Add CVar information if provided
        if cvarName then
            --GameTooltip:AddLine(" ")
            --GameTooltip:AddLine("Default Value: " .. cvarName, 0.5, 0.5, 0.5) -- grey color for subtext
            GameTooltip:AddDoubleLine(L["Tooltip_Changes_CVar"], cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
            if cvarName2 then
                GameTooltip:AddDoubleLine(" ", cvarName2, 0.2, 1, 0.6, 0.2, 1, 0.6)
            end
        end

        if category then
            GameTooltip:AddLine("")
            GameTooltip:AddLine("|A:shop-games-magnifyingglass:17:17|a " .. string.format(L["Tooltip_Setting_Located_In_Section"], category), 0.4, 0.8, 1, true)
        end

        GameTooltip:Show()

        ApplyGuiFontToTooltip()
    end)
    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function RefreshTooltip(widget, title, mainText, subText, anchor, cvarName, cvarName2)
    GameTooltip:ClearLines()
    if anchor then
        GameTooltip:SetOwner(widget, anchor)
    else
        GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")
    end
    -- Set the bold title
    GameTooltip:AddLine(title)
    --GameTooltip:AddLine(" ") -- Adding an empty line as a separator
    -- Set the main text
    GameTooltip:AddLine(mainText, 1, 1, 1, true) -- true for wrap text
    -- Set the subtext
    if subText then
        GameTooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(subText, 0.8, 0.80, 0.80, true)
    end
    -- Add CVar information if provided
    if cvarName then
        --GameTooltip:AddLine(" ")
        --GameTooltip:AddLine("Default Value: " .. cvarName, 0.5, 0.5, 0.5) -- grey color for subtext
        GameTooltip:AddDoubleLine(L["Tooltip_Changes_CVar"], cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
        if cvarName2 then
            GameTooltip:AddDoubleLine(" ", cvarName2, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end
    end
    GameTooltip:Show()
    ApplyGuiFontToTooltip()
end

local CLASS_COLORS = {
    ROGUE = "|cfffff569",
    WARRIOR = "|cffc79c6e",
    MAGE = "|cff40c7eb",
    DRUID = "|cffff7d0a",
    HUNTER = "|cffabd473",
    PRIEST = "|cffffffff",
    WARLOCK = "|cff8787ed",
    SHAMAN = "|cff0070de",
    PALADIN = "|cfff58cba",
    DEATHKNIGHT = "|cffc41f3b",
    MONK = "|cff00ff96",
    DEMONHUNTER = "|cffa330c9",
    EVOKER = "|cff33937f",
    STARTER = "|cff32cd32",
    BLITZ = "|cffff8000",
    MYTHIC = "|cff7dd1c2",
    PREMIDNIGHT = "|cffbbc3ff",
    FOREVER = "|cffffd100",
}

local CLASS_ICONS = {
    ROGUE = "groupfinder-icon-class-rogue",
    WARRIOR = "groupfinder-icon-class-warrior",
    MAGE = "groupfinder-icon-class-mage",
    DRUID = "groupfinder-icon-class-druid",
    HUNTER = "groupfinder-icon-class-hunter",
    PRIEST = "groupfinder-icon-class-priest",
    WARLOCK = "groupfinder-icon-class-warlock",
    SHAMAN = "groupfinder-icon-class-shaman",
    PALADIN = "groupfinder-icon-class-paladin",
    DEATHKNIGHT = "groupfinder-icon-class-deathknight",
    MONK = "groupfinder-icon-class-monk",
    DEMONHUNTER = "groupfinder-icon-class-demonhunter",
    EVOKER = "groupfinder-icon-class-evoker",
    STARTER = "newplayerchat-chaticon-newcomer",
    BLITZ = "questlog-questtypeicon-pvp",
    MYTHIC = "worldquest-icon-dungeon",
    PREMIDNIGHT = "nameplates-icon-elite-gold",
    FOREVER = "logo-wow-forever",
}

-- Function to show the confirmation popup with dynamic profile information
local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
    local noteText = additionalNote or ""
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
    local iconSize = class == "FOREVER" and 28 or 16
    local profileText = string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], profileName == "Starter" and L["Starter"] or profileName))
    local confirmationText = titleText .. string.format(L["Popup_Apply_Profile_Confirm"], profileText, noteText)

    BBP.GetPopup("BBP_CONFIRM_PROFILE").text = confirmationText
    BBP.ShowPopup("BBP_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
end

function BBP.ShowProfileLink(link)
    local box = BBP.profileLinkBox
    if not box then
        box = CreateFrame("EditBox", nil, UIParent, "InputBoxTemplate")
        box:SetSize(170, 20)
        box:SetAutoFocus(false)
        box:SetFrameStrata("FULLSCREEN_DIALOG")
        box:SetScript("OnEscapePressed", box.Hide)
        box:SetScript("OnEnterPressed", box.Hide)
        box:SetScript("OnEditFocusLost", box.Hide)
        box:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                self:SetText(self.link)
                self:HighlightText()
            end
        end)
        box:SetScript("OnKeyDown", function(self, key)
            if key == "C" and IsControlKeyDown() then
                C_Timer.After(0, function() self:Hide() end)
            end
        end)
        BBP.profileLinkBox = box
    end
    if not link then
        box:Hide()
        return
    end
    box.link = link
    box:ClearAllPoints()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    box:SetPoint("TOP", UIParent, "BOTTOMLEFT", x / scale, y / scale - 12)
    box:SetText(link)
    box:Show()
    box:SetFocus()
    box:HighlightText()
end

local function CreateClassButton(parent, class, name, twitchName, onClickFunc, youtubeName)
    local bbpParent = parent == BetterBlizzPlates
    local coreProfile = class == "STARTER" or class == "BLITZ" or class == "MYTHIC" or class == "PREMIDNIGHT" or class == "FOREVER" or name == "Bodify"
    local btnWidth, btnHeight = bbpParent and 110 or (coreProfile and 150 or 114), bbpParent and 22 or 30
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetSize(btnWidth, btnHeight)
    button:SetScale(bbpParent and 0.88 or 0.95)

    local displayName = name == "Starter" and L["Starter"] or name
    local buttonName = (bbpParent or not coreProfile) and displayName or string.format(L["Profile_Name_Title"], displayName)
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
    local iconSize = class == "FOREVER" and 28 or 16

    if name == "Bodify" then
        icon = "gmchat-icon-blizz"
    end

    if name == "Pre-Midnight" then
        button:SetText(string.format("|A:%s:%d:%d|a%s%s|r", icon, iconSize, iconSize, color, buttonName))
    else
        button:SetText(string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, buttonName))
    end
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    local a,b,c = button.Text:GetFont()
    button.Text:SetFont(a,b,"OUTLINE")
    local a,b,c,d,e = button.Text:GetPoint()
    if not bbpParent then
        button.Text:SetPoint("LEFT",b,"LEFT",10,e-0.6)
    end

    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            BBP.ShowProfileLink(twitchName and ("www.twitch.tv/"..twitchName) or youtubeName and ("www.youtube.com/@"..youtubeName))
        elseif onClickFunc then
            onClickFunc()
        end
    end)

    if class == "STARTER" then
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Profile_Starter_Desc"], nil, "ANCHOR_TOP")
    elseif class == "FOREVER" then
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Tooltip_A_Very_Basic_Profile_With_A_Desc"], nil, "ANCHOR_TOP")
    elseif class == "BLITZ" then
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Profile_Blitz_Desc"], nil, "ANCHOR_TOP")
    elseif class == "MYTHIC" then
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Tooltip_A_Tweaked_Version_Of_The_Midnight_Desc"], nil, "ANCHOR_TOP")
    elseif name == "Bodify" then
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Profile_Bodify_Desc"], nil, "ANCHOR_TOP")
    elseif name == "Pre-Midnight" then
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Tooltip_A_Very_Basic_Profile_That_Aims_Desc"], nil, "ANCHOR_TOP")
    else
        local socialText = ""
        if twitchName then
            socialText = string.format("www.twitch.tv/%s", twitchName)
        end
        if youtubeName then
            if socialText ~= "" then socialText = socialText .. "\n" end
            socialText = socialText .. string.format("www.youtube.com/@%s", youtubeName)
        end
        CreateTooltipTwo(button, string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), string.format(L["Tooltip_Enable_Profile_Desc"], name), socialText ~= "" and socialText or nil, "ANCHOR_TOP")
    end

    return button
end

local function CreateImportExportUI(parent, title, dataTable, posX, posY, tableName)
    local function GetDataTable()
        if tableName and tableName ~= "fullProfile" and type(BetterBlizzPlatesDB) == "table" then
            local live = BetterBlizzPlatesDB[tableName]
            if type(live) == "table" then
                dataTable = live
            end
        end
        return dataTable
    end

    -- Frame to hold all import/export elements
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(210, 65)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", posX, posY)

    -- Setting the backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", -- More subtle background
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Sleeker border
        tile = false, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.7) -- Semi-transparent black

    -- Title
    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    titleText:SetPoint("BOTTOM", frame, "TOP", 0, 0)
    titleText:SetText(title)

    if tableName == "castEmphasisList" then
        CreateTooltipTwo(titleText, L["Supports_Plater_Cast_Color_Import_As_Well"])
    end

    -- Export EditBox
    local exportBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    exportBox:SetSize(100, 20)
    exportBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -10)
    exportBox:SetAutoFocus(false)
    CreateTooltipTwo(exportBox, L["Tooltip_Ctrl_C_Copy"])

    -- Import EditBox
    local importBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importBox:SetSize(100, 20)
    importBox:SetPoint("TOP", exportBox, "BOTTOM", 0, -5)
    importBox:SetAutoFocus(false)

    -- Export Button
    local exportBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    exportBtn:SetPoint("RIGHT", exportBox, "LEFT", -10, 0)
    exportBtn:SetSize(73, 20)
    exportBtn:SetText(L["Export"])
    exportBtn:SetNormalFontObject("GameFontNormal")
    exportBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(exportBtn, L["Tooltip_Export_Data"], L["Tooltip_Export_Data_Desc"])

    -- Import Button
    local importBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    importBtn:SetPoint("RIGHT", importBox, "LEFT", -10, 0)
    --importBtn:SetSize(title ~= "Full Profile" and 52 or 73, 20)
    importBtn:SetSize(73, 20)
    importBtn:SetText(L["Import"])
    importBtn:SetNormalFontObject("GameFontNormal")
    importBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(importBtn, L["Tooltip_Import_Data"], L["Tooltip_Import_Data_Desc"])

    -- Keep Old Checkbox
    -- if title ~= "Full Profile" then
    --     local keepOldCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    --     keepOldCheckbox:SetPoint("RIGHT", importBtn, "LEFT", 3, -1)
    --     keepOldCheckbox:SetChecked(true)
    --     CreateTooltipTwo(keepOldCheckbox, "Keep Old Data (BETA)", "(BETA) Not expected to work currently. Import new data while keeping your old one. Uncheck to remove current data.")
    -- end

    -- Button scripts
    exportBtn:SetScript("OnClick", function()
        local exportString = BBP.ExportProfile(GetDataTable(), tableName)
        exportBox:SetText(exportString)
        exportBox:SetFocus()
        exportBox:HighlightText()
    end)

    local wipeButton = exportBox:CreateTexture(nil, "OVERLAY")
    wipeButton:SetSize(14,14)
    wipeButton:SetPoint("CENTER", exportBox, "TOPRIGHT", 8,6)
    wipeButton:SetAtlas("transmog-icon-remove")
    wipeButton:Hide()

    wipeButton:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and IsShiftKeyDown() and IsAltKeyDown() then
            if tableName == "fullProfile" then
                BetterBlizzPlatesDB = nil
            else
                BetterBlizzPlatesDB[tableName] = nil
            end
            ReloadUI()
        end
    end)

    local function HideWipeButton()
        if not wipeButton:IsMouseOver() then
            wipeButton:Hide()
        end
    end

    frame:HookScript("OnEnter", function()
        wipeButton:Show()
        C_Timer.After(4, HideWipeButton)
    end)
    CreateTooltipTwo(wipeButton, string.format(L["Tooltip_Delete_List_Title"], title), string.format(L["Tooltip_Delete_List_Desc"], title))

    wipeButton:HookScript("OnEnter", function()
        wipeButton:Show()
    end)

    wipeButton:HookScript("OnLeave", function()
        C_Timer.After(0.5, HideWipeButton)
    end)


    importBtn:SetScript("OnClick", function()
        if InCombatLockdown() then
            BBP.Print(L["Print_Leave_Combat_To_Import"])
            return
        end
        local importString = importBox:GetText()
        local profileData, errorMessage, bypass = BBP.OldImportProfile(importString, tableName)
        if errorMessage then
            BBP.Print(string.format(L["Print_Error_Importing"], title) .. " " .. tostring(errorMessage))
        else
            if bypass then
                -- bypass
            else
                if tableName == "auraWhitelist" or tableName == "auraBlacklist" then
                    local keyed = BBP.NormalizeAuraList(profileData)
                    if next(keyed) == nil and next(profileData) ~= nil then
                        BBP.Print(string.format(L["Print_Error_Importing_No_Spell_ID"], title))
                        return
                    end
                    profileData = keyed
                end

                local target = GetDataTable()
                if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                    -- Perform a deep merge if "Keep Old" is checked
                    BBP.DeepMergeTables(target, profileData)
                else
                    -- Replace existing data with imported data
                    for k in pairs(target) do target[k] = nil end
                    for k, v in pairs(profileData) do
                        target[k] = v
                    end
                end
                --print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: " .. title .. " imported successfully. While still BETA this requires a reload to load in new lists.")

                if tableName == "fullProfile" then
                    BetterBlizzPlatesDB.optimizedAuraLists = nil
                    BBP.SanitizeImportedNameplateStyle()
                end
            end
            BetterBlizzPlatesDB.scStart = true
            BetterBlizzPlatesDB.skipUpdateMsg = true
            if BetterBlizzPlatesDB.friendlyNameplatesEnabledOnExport then
                C_CVar.SetCVar("nameplateShowFriendlyPlayers", "1")
                BBP.SaveNameplateToggleCVar("nameplateShowFriendlyPlayers", "1")
                BetterBlizzPlatesDB.friendlyNameplatesEnabledOnExport = nil
            end
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)
    return frame
end


-- local function CVarCB(checkbox, dbKey)
--     -- Set the checkbox state based on the database value
--     checkbox:SetChecked(BetterBlizzPlatesDB[dbKey] == "1")

--     -- Assign the OnClick handler
--     checkbox:SetScript("OnClick", function(self)
--         BetterBlizzPlatesDB[dbKey] = self:GetChecked() and "1" or "0"
--     end)
-- end

-- Ensures a single combatCheck frame is created and reused
local combatCheck = combatCheck or CreateFrame("Frame")

function BBP.RunAfterCombat(func)
    if UnitAffectingCombat("player") or InCombatLockdown() then
        BBP.Print(L["Print_CVars_Waiting_For_Combat"])
        combatCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
        combatCheck:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                func()
                self:UnregisterEvent(event)
                self:SetScript("OnEvent", nil)
            end
        end)
    else
        func()
    end
end

local function LateUpdateCheckboxState(checkBox, option)
    local value = BetterBlizzPlatesDB[option]
    local isChecked = value == "1" or value == 1 or value == true
    checkBox:SetChecked(isChecked)
end

local function CreateCheckbox(option, label, parent, cvar, extraFunc, bitCVar)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)
    checkBox.Text:SetFont(fontSmall, 12)
    checkBox:SetSize(24,24)
    checkBox.option = option
    if option and not checkboxByOption[option] then
        checkboxByOption[option] = checkBox
    end
    table.insert(checkBoxList, {checkbox = checkBox, label = label})

    checkBox.bbpMouseDownHandlers = {}
    local hookScript, setScript = checkBox.HookScript, checkBox.SetScript
    function checkBox:HookScript(scriptType, handler, ...)
        if scriptType == "OnMouseDown" then
            table.insert(self.bbpMouseDownHandlers, handler)
        end
        return hookScript(self, scriptType, handler, ...)
    end
    function checkBox:SetScript(scriptType, handler, ...)
        if scriptType == "OnMouseDown" then
            self.bbpMouseDownHandlers = { handler }
        end
        return setScript(self, scriptType, handler, ...)
    end
    if cvar then
        checkBox.cvar = true
    end
    if bitCVar then
        checkBox.bitCVar = bitCVar
    end

    local category
    if parent.name then
        category = parent.name
    elseif parent:GetParent() and parent:GetParent().name then
        category = parent:GetParent().name
    elseif parent:GetParent() and parent:GetParent():GetParent() and parent:GetParent():GetParent().name then
        category = parent:GetParent():GetParent().name
    end

    if category == "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a" then
        category = L["Search_Name_General"]
    end

    checkBox.searchCategory = category

    local function UpdateCheckboxState()
        if (cvar or bitCVar) and not BBP.variablesLoaded then
            C_Timer.After(0.1, function() UpdateCheckboxState() end)
        else
            if bitCVar then
                local val = BetterBlizzPlatesDB.bitfields
                    and BetterBlizzPlatesDB.bitfields[bitCVar.cvarName]
                    and BetterBlizzPlatesDB.bitfields[bitCVar.cvarName][tostring(bitCVar.index)]
                checkBox:SetChecked(val and true or false)
            elseif BetterBlizzPlatesDB[option] == "1" or BetterBlizzPlatesDB[option] == 1 or BetterBlizzPlatesDB[option] == true then
                BetterBlizzPlatesDB[option] = "1"
                checkBox:SetChecked(true)
            else
                BetterBlizzPlatesDB[option] = "0"
                checkBox:SetChecked(false)
            end
            if not bitCVar then
                local isChecked = checkBox:GetChecked()
                local newValue = isChecked and "1" or "0"
                if cvar then
                    BetterBlizzPlatesDB[option] = newValue
                else
                    BetterBlizzPlatesDB[option] = isChecked
                end
            end
        end
    end

    UpdateCheckboxState()

    local function UpdateCheckboxStateDependingOnParent()
        if (cvar or bitCVar or parent.cvar or parent.bitCVar) and not BBP.variablesLoaded then
            C_Timer.After(0.5, function() UpdateCheckboxStateDependingOnParent() end)
        else
            local grandparent = parent:GetParent()
            if parent:GetObjectType() == "CheckButton" and (parent:GetChecked() == false or (grandparent:GetObjectType() == "CheckButton" and grandparent:GetChecked() == false)) then
                checkBox:Disable()
                checkBox:SetAlpha(0.5)
            else
                checkBox:Enable()
                checkBox:SetAlpha(1)
            end
        end
    end
    UpdateCheckboxStateDependingOnParent()


    checkBox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        local newValue = isChecked
        if bitCVar then
            BBP.RunAfterCombat(function()
                BetterBlizzPlatesDB.bitfields[bitCVar.cvarName][tostring(bitCVar.index)] = isChecked
                BBP.CVarTrackingDisabled = true
                C_CVar.SetCVarBitfield(bitCVar.cvarName, bitCVar.index, isChecked)
                BBP.CVarTrackingDisabled = nil
            end)
        elseif cvar then
            newValue = isChecked and "1" or "0"
            BBP.RunAfterCombat(function()
                BBP.CVarTrackingDisabled = true
                C_CVar.SetCVar(option, newValue)
                BBP.CVarTrackingDisabled = nil
                BetterBlizzPlatesDB[option] = newValue
            end)
        else
            BetterBlizzPlatesDB[option] = isChecked
        end

        if extraFunc then
            extraFunc(option, newValue)
        end

        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            BBP.needsUpdate = true
            BBP.RefreshAllNameplates()
        end
    end)

    return checkBox
end

local function CreateMultiSelectDropdown(label, parent, options, width, onChange)
    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(width or 120)
    dropdown.options = options

    local category = parent.name
    if category == "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a" then
        category = L["Search_Name_General"]
    end
    dropdown.searchCategory = category

    function dropdown:ToggleOption(option)
        BetterBlizzPlatesDB[option.key] = not BetterBlizzPlatesDB[option.key]
        if onChange then
            onChange(option.key, BetterBlizzPlatesDB[option.key])
        end
        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            BBP.needsUpdate = true
            BBP.RefreshAllNameplates()
        end
    end

    local function GenerateMenu(owner, rootDescription)
        for _, option in ipairs(options) do
            if option.onClick then
                local button = rootDescription:CreateButton(option.label, function()
                    option.onClick()
                    return MenuResponse.CloseAll
                end)
                if option.tooltip then
                    button:SetTooltip(function(tooltip)
                        GameTooltip_SetTitle(tooltip, option.tooltipTitle or option.label, NORMAL_FONT_COLOR)
                        tooltip:AddLine(option.tooltip, 1, 1, 1, true)
                    end)
                end
            else
                local checkbox = rootDescription:CreateCheckbox(option.label,
                    function() return (BetterBlizzPlatesDB[option.key] or (option.isForced and option.isForced())) and true or false end,
                    function(_, inputData)
                        if option.onRightClick and inputData and inputData.buttonName == "RightButton" then
                            option.onRightClick()
                            return MenuResponse.CloseAll
                        end
                        dropdown:ToggleOption(option)
                    end)
                if option.onRightClick then
                    checkbox:AddInitializer(function(button)
                        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                    end)
                    checkbox:AddResetter(function(button)
                        button:RegisterForClicks("LeftButtonUp")
                    end)
                end
                if option.isEnabled or option.isForced then
                    checkbox:SetEnabled(function()
                        if option.isForced and option.isForced() then return false end
                        return not option.isEnabled or option.isEnabled() and true or false
                    end)
                end
                if option.tooltip then
                    checkbox:SetTooltip(function(tooltip)
                        GameTooltip_SetTitle(tooltip, option.tooltipTitle or option.label, NORMAL_FONT_COLOR)
                        tooltip:AddLine(option.tooltip, 1, 1, 1, true)
                        if option.onRightClick then
                            tooltip:AddLine(" ")
                            tooltip:AddLine("|cff32f795" .. (option.rightClickText or L["Right_Click_For_Options"]) .. "|r", 1, 1, 1, true)
                        end
                        local note = option.tooltipNote
                        if type(note) == "function" then note = note() end
                        if note then
                            tooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
                            tooltip:AddLine(note, 0.8, 0.8, 0.8, true)
                        end
                    end)
                end
            end
        end
    end

    dropdown.menuGenerator = GenerateMenu
    dropdown:SetDefaultText(label)
    dropdown:SetSelectionText(function() return label end)
    dropdown:SetupMenu(GenerateMenu)
    dropdown:OverrideText(label)

    table.insert(dropdownList, {dropdown = dropdown, label = label})

    return dropdown
end

local KEYED_LISTS = {
    auraBlacklist = true,
    auraWhitelist = true,
}

local SPELL_ICON_LISTS = {
    auraBlacklist = true,
    auraWhitelist = true,
    auraColorList = true,
    castEmphasisList = true,
    hideCastbarWhitelist = true,
}

local SPELL_NAME_LISTS = {
    auraBlacklist = true,
    auraWhitelist = true,
    auraColorList = true,
    castEmphasisList = true,
    hideCastbarList = true,
    hideCastbarWhitelist = true,
}

local function CreateList(subPanel, listName, listData, refreshFunc, enableColorPicker, extraBoxes, prioSlider, width, height, colorText, pos)
    local isKeyed = KEYED_LISTS[listName]
    local showIcon = SPELL_ICON_LISTS[listName]
    local resolveSpellName = SPELL_NAME_LISTS[listName]

    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, height or 390)
    if not pos then
        scrollFrame:SetPoint("TOPLEFT", 10, -10)
    else
        scrollFrame:SetPoint("TOPLEFT", -48, -10)
    end

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}
    local framePool = {}
    local currentSearchFilter = ""
    local entryToDelete = nil
    local duplicateEntry = nil

    local function setSearchFilter(text)
        text = text or ""
        if currentSearchFilter == text then return end
        currentSearchFilter = text
        scrollFrame:SetVerticalScroll(0)
    end

    local function GetList()
        if isKeyed and BetterBlizzPlatesDB then
            BBP.EnsureAuraListsKeyed()
        end
        local live = listName and BetterBlizzPlatesDB and BetterBlizzPlatesDB[listName]
        if type(live) == "table" and live ~= listData then
            listData = live
        end
        return listData or {}
    end

    local function GetFlag(entry, flag)
        if not entry then return nil end
        if isKeyed then
            if entry[flag] ~= nil then return entry[flag] end
            return entry.flags and entry.flags[flag]
        end
        local flags = entry.flags
        if flags and flags[flag] ~= nil then return flags[flag] end
        return entry[flag]
    end

    local function SetFlag(entry, flag, value)
        if not entry then return end
        value = value and true or nil
        if isKeyed then
            entry[flag] = value
            if type(entry.flags) == "table" then
                entry.flags[flag] = nil
            end
        else
            local flags = entry.flags
            if type(flags) ~= "table" then
                flags = {}
                entry.flags = flags
            end
            flags[flag] = value
            entry[flag] = nil
        end
    end

    local function GetEntryColors(entry)
        local entryColors = entry.entryColors
        if type(entryColors) ~= "table" then
            entryColors = {}
            entry.entryColors = entryColors
        end
        if type(entryColors.text) ~= "table" then
            entryColors.text = { r = 0, g = 1, b = 0, a = 1 }
        end
        return entryColors.text
    end

    local function OpenGlowColor(colorVar)
        OpenColorPicker(colorVar, nil, function()
            for _, line in ipairs(textLines) do
                if line.bbpImportantSwatch then
                    TintFromColor(line.bbpImportantSwatch, "nameplateAuraImportantGlowRGB", 0, 1, 0)
                end
                if line.bbpPandemicSwatch then
                    TintFromColor(line.bbpPandemicSwatch, "nameplateAuraPandemicGlowRGB", 1, 0, 0)
                end
                if line.bbpEnlargedSwatch then
                    TintFromColor(line.bbpEnlargedSwatch, "nameplateAuraEnlargedGlowRGB", 1, 0.5, 0)
                end
            end
            BBP.RefreshAllNameplateAuras()
        end)
    end

    local function updateBackgroundColors()
        for i, button in ipairs(textLines) do
            local bg = button.bgImg
            if i % 2 == 0 then
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)
            else
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            end
        end
    end

    local function deleteEntry(dataEntry)
        if not dataEntry then return end

        local list = GetList()
        if isKeyed then
            local key = dataEntry.id
            if key and list[key] == dataEntry then
                list[key] = nil
            else
                for k, entry in pairs(list) do
                    if entry == dataEntry then
                        list[k] = nil
                        break
                    end
                end
            end
            BBP.auraListNeedsUpdate = true
        else
            for i, entry in ipairs(list) do
                if entry == dataEntry then
                    table.remove(list, i)
                    break
                end
            end
        end

        contentFrame.refreshList()
        if refreshFunc then refreshFunc() end
    end

    local function SetTextColor(button)
        local npc = button.npcData
        if colorText and GetFlag(npc, "important") then
            local color = GetEntryColors(npc)
            button.text:SetTextColor(color.r or 1, color.g or 0.8196, color.b or 0)
        else
            button.text:SetTextColor(1, 1, 0)
        end
    end

    local function GetEntryName(npc)
        local name = npc.name
        if type(name) == "string" and name ~= "" then return name end
        if resolveSpellName and npc.id then
            local resolved = C_Spell.GetSpellName(npc.id)
            if resolved and resolved ~= "" then
                npc.name = resolved
                return resolved
            end
        end
        return nil
    end

    local function GetDisplayText(npc)
        if isKeyed then
            if npc.id then
                return string.format("%s (%d)", GetEntryName(npc) or L["Name_Missing"], npc.id)
            end
            return npc.name or ""
        end

        local displayText = npc.id and tostring(npc.id) or ""
        if npc.name and npc.name ~= "" then
            displayText = npc.name .. (displayText ~= "" and " - " or "") .. displayText
        end
        if npc.comment and npc.comment ~= "" then
            displayText = npc.comment .. (displayText ~= "" and " - " or "") .. displayText
        end
        if (npc.name and npc.name ~= "") and (npc.comment and npc.comment ~= "") then
            if npc.id and npc.id ~= "" then
                displayText = npc.name .. " (" .. npc.id .. ")"
            else
                displayText = npc.name
            end
        end
        return displayText
    end

    local function ApplyExtraBoxState(button)
        local npc = button.npcData
        if not npc or not button.checkBoxOnlyMine then return end

        local globalPandemic = BetterBlizzPlatesDB.otherNpdeBuffPandemicGlow and true or false
        TintFromColor(button.bbpPandemicSwatch, "nameplateAuraPandemicGlowRGB", 1, 0, 0)
        TintFromColor(button.bbpImportantSwatch, "nameplateAuraImportantGlowRGB", 0, 1, 0)
        TintFromColor(button.bbpEnlargedSwatch, "nameplateAuraEnlargedGlowRGB", 1, 0.5, 0)

        if button.bbpPandemicTooltipState ~= globalPandemic then
            button.bbpPandemicTooltipState = globalPandemic
            CreateTooltipTwo(button.checkBoxPandemic, L["Pandemic_Glow"] .. " |A:elementalstorm-boss-air:22:22|a",
                L["Tooltip_Pandemic_Glow_Desc"],
                globalPandemic
                    and L["Tooltip_Pandemic_Glow_Inactive"]
                    or nil,
                "ANCHOR_TOPRIGHT")
        end

        local important = GetFlag(npc, "important")
        local enlarged = GetFlag(npc, "enlarged")
        button.bbpEnlargedSwatch:SetShown((important and enlarged) and true or false)
        button.checkBoxOnlyMine:SetChecked(GetFlag(npc, "onlyMine") and true or false)
        button.checkBoxPandemic:SetChecked(GetFlag(npc, "pandemic") and true or false)
        button.checkBoxImportant:SetChecked(important and true or false)
        button.checkBoxEnlarged:SetChecked(enlarged and true or false)

        if globalPandemic or important or enlarged then
            DisableElement(button.checkBoxPandemic)
        else
            EnableElement(button.checkBoxPandemic)
        end
    end

    local function RefreshRow(button)
        if not button or not button.npcData then return end
        SetTextColor(button)
        ApplyExtraBoxState(button)
    end

    local function createOrUpdateTextLineButton(npc, index)
        local button = framePool[index]

        if not button then
            button = CreateFrame("Frame", nil, contentFrame)
            button:SetSize((width and width - 12) or 310, 20)
            button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

            local bg = button:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            button.bgImg = bg

            if showIcon then
                local iconTexture = button:CreateTexture(nil, "OVERLAY")
                iconTexture:SetSize(20, 20)
                iconTexture:SetPoint("LEFT", button, "LEFT", 0, 0)
                button.iconTexture = iconTexture

                button:SetScript("OnEnter", function(self)
                    local id = button.npcData and button.npcData.id
                    if not id then return end
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:SetSpellByID(id)
                    GameTooltip:AddLine(string.format(L["Spell_ID_Label"], id), 1, 1, 1)
                    GameTooltip:Show()
                end)
                button:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end

            local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", button, "LEFT", showIcon and 25 or 5, 0)
            button.text = text

            if listName == "auraWhitelist" then
                text:SetWidth(213)
                text:SetWordWrap(false)
                text:SetJustifyH("LEFT")
            end

            local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
            deleteButton:SetSize(20, 20)
            deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
            deleteButton:SetText("X")
            deleteButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    deleteEntry(button.npcData)
                else
                    entryToDelete = button.npcData
                    StaticPopup_Show("BBP_DELETE_NPC_CONFIRM_" .. listName)
                end
            end)
            button.deleteButton = deleteButton

            framePool[index] = button
        end

        button.npcData = npc
        button:Show()

        button.text:SetText(GetDisplayText(npc))
        SetTextColor(button)

        if button.iconTexture then
            button.iconTexture:SetTexture(npc.id and C_Spell.GetSpellTexture(npc.id)
                or (npc.name and npc.name ~= "" and C_Spell.GetSpellTexture(npc.name)) or nil)
        end

        if enableColorPicker then
            if not button.colorPickerButton then
                local colorPickerButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
                colorPickerButton:SetSize(50, 19)
                colorPickerButton:SetPoint("RIGHT", button.deleteButton, "LEFT", -5, 0)
                colorPickerButton:SetText(L["Color"])

                local colorPickerIcon = button:CreateTexture(nil, "ARTWORK")
                colorPickerIcon:SetAtlas("newplayertutorial-icon-key")
                colorPickerIcon:SetSize(17, 16)
                colorPickerIcon:SetPoint("RIGHT", colorPickerButton, "LEFT", 0, 0)

                colorPickerButton:SetScript("OnClick", function()
                    if not button.npcData then return end
                    BBP.needsUpdate = true
                    local colorData = GetEntryColors(button.npcData)
                    local r, g, b = colorData.r or 1, colorData.g or 1, colorData.b or 1
                    local a = colorData.a or 1

                    local function updateColors()
                        colorData.r, colorData.g, colorData.b, colorData.a = r, g, b, a
                        SetTextColor(button)
                        colorPickerIcon:SetVertexColor(r, g, b)
                        BBP.RefreshAllNameplates()
                        ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
                        BBP.auraListNeedsUpdate = true
                    end

                    local function swatchFunc()
                        r, g, b = ColorPickerFrame:GetColorRGB()
                        updateColors()
                    end

                    local function opacityFunc()
                        a = ColorPickerFrame:GetColorAlpha()
                        updateColors()
                    end

                    local function cancelFunc(previousValues)
                        if previousValues then
                            r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                            updateColors()
                        end
                    end

                    ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

                    ColorPickerFrame:SetupColorPickerAndShow({
                        r = r, g = g, b = b, opacity = a, hasOpacity = true,
                        swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
                    })
                end)

                button.colorPickerButton = colorPickerButton
                button.colorPickerIcon = colorPickerIcon
            end

            local color = GetEntryColors(npc)
            button.colorPickerIcon:SetVertexColor(color.r or 1, color.g or 1, color.b or 1)
        end

        if listName == "hideNPCsList" or listName == "hideNPCsWhitelist" then
            if not button.checkBoxMurloc then
                local checkBoxMurloc = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxMurloc:SetSize(24, 24)
                checkBoxMurloc:SetPoint("RIGHT", button.deleteButton, "LEFT", -11, 0)
                CreateTooltipTwo(checkBoxMurloc, L["Murloc_Icon"] .. " |A:newplayerchat-chaticon-newcomer:22:22|a", L["Tooltip_Murloc_Icon_Desc"], nil, "ANCHOR_TOPRIGHT")

                checkBoxMurloc:SetScript("OnClick", function(self)
                    SetFlag(button.npcData, "murloc", self:GetChecked())
                    BBP.RefreshAllNameplates()
                end)

                button.checkBoxMurloc = checkBoxMurloc
            end
            button.checkBoxMurloc:SetChecked(GetFlag(npc, "murloc") and true or false)
        end

        if listName == "castEmphasisList" then
            if not button.checkBoxOnMe then
                local checkBoxOnMe = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxOnMe:SetSize(24, 24)
                checkBoxOnMe:SetPoint("RIGHT", button.colorPickerIcon or button.deleteButton, "LEFT", -5, 0)
                CreateTooltipTwo(checkBoxOnMe, L["Only_On_Me"] .. " |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", L["Tooltip_Only_On_Me_Desc"], L["Tooltip_Only_On_Me_SubText"], "ANCHOR_TOPRIGHT")

                checkBoxOnMe:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    button.npcData.onMeOnly = self:GetChecked() or nil
                    BBP.RefreshAllNameplates()
                end)

                button.checkBoxOnMe = checkBoxOnMe
            end
            button.checkBoxOnMe:SetChecked(npc.onMeOnly and true or false)
        end

        if extraBoxes then
            if not button.checkBoxOnlyMine then
                local checkBoxPandemic = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxPandemic:SetSize(24, 24)
                checkBoxPandemic:SetPoint("RIGHT", button.deleteButton, "LEFT", 0, 0)
                local pandemicSwatch = checkBoxPandemic:CreateTexture(nil, "ARTWORK", nil, 1)
                pandemicSwatch:SetAtlas("newplayertutorial-drag-slotgreen")
                pandemicSwatch:SetDesaturated(true)
                pandemicSwatch:SetSize(27, 27)
                pandemicSwatch:SetPoint("CENTER", checkBoxPandemic, "CENTER", -0.5, 0.5)
                button.bbpPandemicSwatch = pandemicSwatch

                checkBoxPandemic:SetScript("OnClick", function(self)
                    SetFlag(button.npcData, "pandemic", self:GetChecked())
                    BBP.RefreshAllNameplateAuras()
                end)

                checkBoxPandemic:HookScript("OnMouseDown", function(_, mouseButton)
                    if mouseButton == "RightButton" then OpenGlowColor("nameplateAuraPandemicGlowRGB") end
                end)

                button.checkBoxPandemic = checkBoxPandemic

                local checkBoxImportant = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxImportant:SetSize(24, 24)
                checkBoxImportant:SetPoint("RIGHT", checkBoxPandemic, "LEFT", 0, 0)
                local importantSwatch = checkBoxImportant:CreateTexture(nil, "ARTWORK", nil, 1)
                importantSwatch:SetAtlas("newplayertutorial-drag-slotgreen")
                importantSwatch:SetDesaturated(true)
                importantSwatch:SetSize(27, 27)
                importantSwatch:SetPoint("CENTER", checkBoxImportant, "CENTER", -0.5, 0.5)
                button.bbpImportantSwatch = importantSwatch
                CreateTooltipTwo(checkBoxImportant, L["Important_Glow"] .. " |A:importantavailablequesticon:22:22|a",
                    L["Tooltip_Important_Glow_Desc"],
                    nil, "ANCHOR_TOPRIGHT")

                checkBoxImportant:HookScript("OnMouseDown", function(_, mouseButton)
                    if mouseButton == "RightButton" then OpenGlowColor("nameplateAuraImportantGlowRGB") end
                end)

                checkBoxImportant:SetScript("OnClick", function(self)
                    local checked = self:GetChecked()
                    SetFlag(button.npcData, "important", checked)
                    if checked then SetFlag(button.npcData, "pandemic", false) end
                    RefreshRow(button)
                    BBP.RefreshAllNameplateAuras()
                end)

                button.checkBoxImportant = checkBoxImportant

                local checkBoxEnlarged = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxEnlarged:SetSize(24, 24)
                checkBoxEnlarged:SetPoint("RIGHT", checkBoxImportant, "LEFT", 0, 0)
                local enlargedSwatch = checkBoxEnlarged:CreateTexture(nil, "ARTWORK", nil, 1)
                enlargedSwatch:SetAtlas("newplayertutorial-drag-slotgreen")
                enlargedSwatch:SetDesaturated(true)
                enlargedSwatch:SetSize(27, 27)
                enlargedSwatch:SetPoint("CENTER", checkBoxEnlarged, "CENTER", -0.5, 0.5)
                button.bbpEnlargedSwatch = enlargedSwatch
                CreateTooltipTwo(checkBoxEnlarged, L["Enlarged_Aura_Icon"] .. " |A:ui-hud-minimap-zoom-in:22:22|a",
                    L["Tooltip_Enlarged_Aura_Icon_Desc"],
                    L["Tooltip_Enlarged_Aura_Icon_SubText"],
                    "ANCHOR_TOPRIGHT")

                checkBoxEnlarged:HookScript("OnMouseDown", function(_, mouseButton)
                    if mouseButton == "RightButton" then OpenGlowColor("nameplateAuraEnlargedGlowRGB") end
                end)

                checkBoxEnlarged:SetScript("OnClick", function(self)
                    local checked = self:GetChecked()
                    SetFlag(button.npcData, "enlarged", checked)
                    if checked then SetFlag(button.npcData, "pandemic", false) end
                    RefreshRow(button)
                    BBP.RefreshAllNameplateAuras()
                end)

                button.checkBoxEnlarged = checkBoxEnlarged

                local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxOnlyMine:SetSize(24, 24)
                checkBoxOnlyMine:SetPoint("RIGHT", checkBoxEnlarged, "LEFT", 0, 0)
                CreateTooltipTwo(checkBoxOnlyMine, L["Only_My_Aura_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a",
                    L["Tooltip_Only_My_Aura"], nil, "ANCHOR_TOPRIGHT")

                checkBoxOnlyMine:SetScript("OnClick", function(self)
                    SetFlag(button.npcData, "onlyMine", self:GetChecked())
                    BBP.RefreshAllNameplateAuras()
                end)

                button.checkBoxOnlyMine = checkBoxOnlyMine
            end

            ApplyExtraBoxState(button)
        end

        if prioSlider then
            if not button.prioritySlider then
                local prioritySlider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
                prioritySlider:SetSize(100, 16)
                prioritySlider:SetPoint("RIGHT", button.colorPickerButton or button.deleteButton, "LEFT", -75, 0)
                prioritySlider:SetOrientation("HORIZONTAL")
                prioritySlider:SetMinMaxValues(1, 10)
                prioritySlider:SetValueStep(1)
                prioritySlider:SetObeyStepOnDrag(true)
                prioritySlider.Low:SetText("")
                prioritySlider.High:SetText("")
                CreateTooltipTwo(prioritySlider, L["Priority_Value"], L["Tooltip_Priority_Value_Desc"])

                local priorityText = prioritySlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                priorityText:SetPoint("RIGHT", prioritySlider, "LEFT", -5, 0)
                priorityText:SetTextColor(1, 0.8196, 0, 1)
                prioritySlider.priorityText = priorityText

                prioritySlider:SetScript("OnValueChanged", function(self, value)
                    local newValue = math.floor(value + 0.5)
                    self:SetValue(newValue)
                    priorityText:SetText(newValue)
                    if not button.npcData then return end
                    button.npcData.priority = newValue
                    BBP.auraListNeedsUpdate = true
                end)

                local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxOnlyMine:SetSize(24, 24)
                checkBoxOnlyMine:SetPoint("RIGHT", prioritySlider, "LEFT", -16, 0)
                CreateTooltipTwo(checkBoxOnlyMine, L["Only_My_Aura_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", L["Tooltip_Only_My_Aura_Icon_Desc"], nil, "ANCHOR_TOPRIGHT")

                checkBoxOnlyMine:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    button.npcData.onlyMine = self:GetChecked()
                    BBP.auraListNeedsUpdate = true
                    BBP.RefreshAllNameplates()
                end)

                button.prioritySlider = prioritySlider
                button.prioCheckBoxOnlyMine = checkBoxOnlyMine
            end

            button.prioritySlider:SetValue(npc.priority or 1)
            button.prioritySlider.priorityText:SetText(npc.priority or 1)
            button.prioCheckBoxOnlyMine:SetChecked(npc.onlyMine and true or false)
        end

        return button
    end

    local function updateNamesInListData()
        if not resolveSpellName then return end
        for key, entry in pairs(GetList()) do
            if type(entry) == "table" then
                if isKeyed and not entry.id then
                    entry.id = tonumber(key)
                end
                GetEntryName(entry)
            end
        end
    end

    local function getSortedNpcList()
        updateNamesInListData()

        local sortableList = {}
        local safeFilter = (currentSearchFilter and currentSearchFilter ~= "")
            and currentSearchFilter:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
            or nil

        for _, entry in pairs(GetList()) do
            if type(entry) == "table" then
                if not safeFilter then
                    table.insert(sortableList, entry)
                else
                    local name = (GetEntryName(entry) or ""):lower()
                    local id = entry.id and tostring(entry.id):lower() or ""
                    local comment = entry.comment and entry.comment:lower() or ""
                    if name:match(safeFilter) or id:match(safeFilter) or comment:match(safeFilter) then
                        table.insert(sortableList, entry)
                    end
                end
            end
        end

        table.sort(sortableList, function(a, b)
            local nameA = GetEntryName(a)
            local nameB = GetEntryName(b)
            if (nameA ~= nil) ~= (nameB ~= nil) then
                return nameA ~= nil
            end
            if nameA and nameB then
                nameA, nameB = nameA:lower(), nameB:lower()
                if nameA ~= nameB then
                    return nameA < nameB
                end
            end

            local idA = tonumber(a.id) or math.huge
            local idB = tonumber(b.id) or math.huge
            return idA < idB
        end)

        return sortableList
    end

    local function releaseRowsFrom(firstIndex)
        for i = firstIndex, #framePool do
            local button = framePool[i]
            if button then
                button.npcData = nil
                button:Hide()
            end
        end
    end

    local function clampScroll()
        local maxScroll = math.max(0, contentFrame:GetHeight() - scrollFrame:GetHeight())
        if scrollFrame:GetVerticalScroll() > maxScroll then
            scrollFrame:SetVerticalScroll(maxScroll)
        end
    end

    local refreshGeneration = 0
    local function refreshList()
        local sortedListData = getSortedNpcList()
        local totalEntries = #sortedListData
        local batchSize = 35
        local currentIndex = 1

        refreshGeneration = refreshGeneration + 1
        local generation = refreshGeneration
        wipe(textLines)

        local function processNextBatch()
            if generation ~= refreshGeneration then return end

            local lastIndex = math.min(currentIndex + batchSize - 1, totalEntries)
            for i = currentIndex, lastIndex do
                textLines[i] = createOrUpdateTextLineButton(sortedListData[i], i)
            end

            releaseRowsFrom(lastIndex + 1)

            contentFrame:SetHeight(totalEntries * 20)
            updateBackgroundColors()
            clampScroll()

            currentIndex = lastIndex + 1
            if currentIndex <= totalEntries then
                C_Timer.After(0.04, processNextBatch)
            end
        end

        processNextBatch()
    end

    contentFrame.refreshList = refreshList
    BBP[listName.."Refresh"] = refreshList

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize((width and width - 62) or (322 - 62), 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)

    StaticPopupDialogs["BBP_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = L["Popup_This_Name_Or_NpcID_Is_Already"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            setSearchFilter("")
            editBox:SetText("")
            deleteEntry(duplicateEntry)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopupDialogs["BBP_DELETE_NPC_CONFIRM_" .. listName] = {
        text = L["Dialog_Confirm_Delete"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            deleteEntry(entryToDelete)
            entryToDelete = nil
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    if listName == "auraWhitelist" then
        CreateTooltipTwo(editBox, L["Add_Whitelist_Aura"],
            L["Tooltip_Add_Whitelist_Aura"],
            nil, "ANCHOR_TOP")
    elseif listName == "auraBlacklist" then
        CreateTooltipTwo(editBox, L["Add_Blacklist_Aura"],
            L["Tooltip_Add_Blacklist_Aura"],
            nil, "ANCHOR_TOP")
    elseif isKeyed then
        CreateTooltipTwo(editBox, L["Add_New_Aura_Or_Search"], L["Tooltip_Add_New_Aura_Or_Search_Desc"], nil, "ANCHOR_TOP")
    elseif listName == "auraColorList" or
    listName == "hideCastbarWhitelist" then
        CreateTooltipTwo(editBox, L["Add_New_Aura_Or_Search"], L["Tooltip_Add_New_Aura_Or_Search_Desc_2"], nil, "ANCHOR_TOP")
    elseif listName == "hideCastbarList" then
        CreateTooltipTwo(editBox, L["Add_New_Spell_Or_NPC"], L["Tooltip_Add_New_Spell_Or_NPC_Desc"], nil, "ANCHOR_TOP")
    elseif listName == "castEmphasisList" then
        CreateTooltipTwo(editBox, L["Add_New_Spell_Or_NPC"], L["Tooltip_Add_New_Spell_Or_NPC_Desc_2"], nil, "ANCHOR_TOP")
    else
        CreateTooltipTwo(editBox, L["Add_New_NPC"], L["Tooltip_Add_New_NPC_Desc"], nil, "ANCHOR_TOP")
    end

    local function addOrUpdateEntry(inputText)
        duplicateEntry = nil

        local name, comment = strsplit("/", inputText, 2)
        name = strtrim(name or "")
        comment = strtrim(comment or "")
        local id = tonumber(name)

        if isKeyed and not id then
            if name ~= "" then
                BBP.Print(L["Print_Spell_ID_Only_Auras_Can_No"])
            end
            setSearchFilter("")
            editBox:SetText("")
            refreshList()
            return
        end

        local icon
        if id then
            local spellInfo = C_Spell.GetSpellInfo(id)
            local spellName = spellInfo and spellInfo.name
            local spellIcon = spellInfo and (spellInfo.iconID or spellInfo.originalIconID)
            if isKeyed and not spellName then
                BBP.Print(string.format(L["Print_No_Spell_Found_With_ID"], id))
                setSearchFilter("")
                editBox:SetText("")
                refreshList()
                return
            end
            name = (spellName and resolveSpellName) and spellName or ""
            icon = spellIcon
        end

        if name == "" and not id then return end

        local list = GetList()
        local isDuplicate = false

        if isKeyed then
            if list[id] then
                isDuplicate = true
                duplicateEntry = list[id]
            end
        else
            for _, npc in ipairs(list) do
                if type(npc) == "table"
                    and ((id and npc.id == id)
                        or (not id and strlower(npc.name or "") == strlower(name))) then
                    isDuplicate = true
                    duplicateEntry = npc
                    break
                end
            end
        end

        if isDuplicate then
            StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_" .. listName)
        else
            if isKeyed then
                list[id] = {
                    id = id,
                    name = name ~= "" and name or nil,
                    comment = comment ~= "" and comment or nil,
                }
                local iconString = icon and ("|T" .. icon .. ":16:16:0:0|t ") or ""
                BBP.Print(string.format(listName == "auraBlacklist" and L["Print_Added_To_Blacklist"] or L["Print_Added_To_Whitelist"],
                    iconString, name, id))
            else
                local newEntry = { name = name, id = id, comment = comment, flags = { important = false, pandemic = false } }
                if prioSlider then
                    newEntry.priority = 1
                end
                table.insert(list, newEntry)
            end

            setSearchFilter("")
            editBox:SetText("")
            refreshList()
            if refreshFunc then refreshFunc() end
        end

        BBP.auraListNeedsUpdate = true
    end

    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
    end)

    local function searchList(searchText)
        setSearchFilter(searchText:lower())
        refreshList()
    end

    editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            searchList(self:GetText())
        end
    end, true)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText(L["Add"])
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)

    if listName == "auraWhitelist" then
        BBP.RefreshAuraWhitelistDisplay = refreshList
    end

    refreshList()
    scrollFrame:HookScript("OnShow", refreshList)

    return scrollFrame
end

local function CreateNpcList(subPanel, npcList, refreshFunc, width, height)
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}
    local selectedNpcId = nil
    local selectedLineIndex = nil

    local function updateBackgroundColors()
        for i, button in ipairs(textLines) do
            local bg = button.bgImg
            if i % 2 == 0 then
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)
            else
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            end
        end
    end

    local function deleteEntry(index)
        if not index or not textLines[index] then return end

        local npcId = textLines[index].npcId
        if not npcId or not npcList[npcId] then return end

        npcList[npcId] = nil
        textLines[index]:Hide()
        table.remove(textLines, index)

        for i = index, #textLines do
            textLines[i]:SetPoint("TOPLEFT", 10, -(i - 1) * 20)
            textLines[i].deleteButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    deleteEntry(i)
                else
                    selectedLineIndex = i
                    StaticPopup_Show("BBP_DELETE_NPC_CONFIRM")
                end
            end)
        end

        updateBackgroundColors()
        refreshFunc()
    end

    StaticPopupDialogs["BBP_DELETE_NPC_CONFIRM"] = {
        text = L["Dialog_Confirm_Delete"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            deleteEntry(selectedLineIndex)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local function updateImportantFlag(npcId, importantFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.important = importantFlag
        end

        refreshFunc()
    end

    local function updateHideIconFlag(npcId, hideIconFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.hideIcon = hideIconFlag
        end

        refreshFunc()
    end

    local function updateHideHpFlag(npcId, hideHpFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.hideHp = hideHpFlag
        end

        refreshFunc()
    end

    local function updateIconOnlyFlag(npcId, iconOnlyFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.iconOnly = iconOnlyFlag
        end

        refreshFunc()
    end

    local function updateEntryColor(npcId, color)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.color = color
        end

        refreshFunc()
    end

    local function createNpcLineButton(npcId, npcData, index)
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or 310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg

        -- New icon texture
        local iconTexture = button:CreateTexture(nil, "OVERLAY")
        iconTexture:SetSize(20, 20)  -- Same height as the button
        iconTexture:SetPoint("LEFT", button, "LEFT", -10, 0)

        -- Set the icon image
        if npcData.icon then
            iconTexture:SetTexture(npcData.icon)
        end

        button.icon = iconTexture

        if npcData.hideIcon then
            iconTexture:Hide()
        else
            iconTexture:Show()
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", 15, 0)
        text:SetText((npcData.name .. " ("..npcId .. ")") or "")

        -- Delete button
        local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
        deleteButton:SetText("X")

        deleteButton:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                deleteEntry(index)
            else
                selectedLineIndex = index
                StaticPopup_Show("BBP_DELETE_NPC_CONFIRM")
            end
        end)
        button.deleteButton = deleteButton

        -- Set text color based on NPC color attribute
        local color = npcData.color or {1, 1, 1}
        text:SetTextColor(color[1], color[2], color[3])

        -- Function to create a label and an edit box for a given property
        local function CreatePropertyField(frame, labelText, anchorFrame, offsetX, offsetY, editBoxWidth, editBoxHeight)
            local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", offsetX, offsetY)
            label:SetText(labelText)

            local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
            editBox:SetSize(editBoxWidth, editBoxHeight)
            editBox:SetPoint("LEFT", label, "RIGHT", 5, 0)
            editBox:SetAutoFocus(false)

            return label, editBox
        end


        local function CreateEditFrame()
            npcEditFrame = CreateFrame("Frame", "NPC_EditFrame", UIParent, "DefaultPanelFlatTemplate")
            npcEditFrame:SetSize(350, 250)
            npcEditFrame:SetPoint("CENTER")
            npcEditFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            npcEditFrame:SetFrameLevel(550)
            npcEditFrame:SetIgnoreParentAlpha(true)
            npcEditFrame:SetTitle(L["Edit_NPC_Details"])
            npcEditFrame:EnableMouse(true)
            npcEditFrame:SetMovable(true)
            npcEditFrame:SetClampedToScreen(true)
            npcEditFrame:RegisterForDrag("LeftButton")
            npcEditFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            npcEditFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            npcEditFrame.closeButton = CreateFrame("Button", nil, npcEditFrame, "UIPanelCloseButton")
            npcEditFrame.closeButton:SetFrameLevel((npcEditFrame.TitleContainer or npcEditFrame):GetFrameLevel() + 10)
            npcEditFrame.closeButton:SetPoint("TOPRIGHT", npcEditFrame, "TOPRIGHT", 0, 0)
            npcEditFrame.closeButton:SetScript("OnClick", function()
                npcEditFrame:Hide()
            end)

            npcEditFrame.bg = npcEditFrame:CreateTexture(nil, "BACKGROUND")
            npcEditFrame.bg:SetPoint("TOPLEFT", npcEditFrame, "TOPLEFT", 7, -3)
            npcEditFrame.bg:SetPoint("BOTTOMRIGHT", npcEditFrame, "BOTTOMRIGHT", -3, 3)
            npcEditFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            -- Icon
            local iconTexture = npcEditFrame:CreateTexture(nil, "ARTWORK")
            iconTexture:SetSize(70, 70)
            iconTexture:SetPoint("TOPLEFT", npcEditFrame, "TOPLEFT", 70, -100)
            npcEditFrame.iconTexture = iconTexture

            -- IconGlow
            local iconGlowTexture = npcEditFrame:CreateTexture(nil, "OVERLAY")
            iconGlowTexture:SetSize(70, 70)
            iconGlowTexture:SetBlendMode("ADD")
            iconGlowTexture:SetAtlas("clickcast-highlight-spellbook")
            iconGlowTexture:SetDesaturated(true)
            iconGlowTexture:SetPoint('TOPLEFT', iconTexture, 'TOPLEFT', -26, 26)
            iconGlowTexture:SetPoint('BOTTOMRIGHT', iconTexture, 'BOTTOMRIGHT', 26, -26)
            iconGlowTexture:SetVertexColor(unpack(color))
            npcEditFrame.iconGlowTexture = iconGlowTexture

            -- Edit Boxes and Labels for NPC properties
            local nameLabel, nameEditBox = CreatePropertyField(npcEditFrame, L["Name_Colon"], npcEditFrame.iconTexture, -35, 125, 220, 25)
            npcEditFrame.nameEditBox = nameEditBox

            local durationLabel, durationEditBox = CreatePropertyField(npcEditFrame, L["Duration_Colon"], npcEditFrame.iconTexture, 95, 91, 50, 20)
            npcEditFrame.durationEditBox = durationEditBox
            CreateTooltipTwo(durationEditBox, L["Duration"], L["Tooltip_Duration_Desc"])

            local sizeLabel, sizeEditBox = CreatePropertyField(npcEditFrame, L["Size_Colon"], durationLabel, 0, -10, 50, 20)
            npcEditFrame.sizeEditBox = sizeEditBox
            CreateTooltipTwo(sizeEditBox, L["Size"], L["Tooltip_Size_Desc"])

            local iconLabel, iconEditBox = CreatePropertyField(npcEditFrame, L["Icon_Colon"], sizeLabel, 0, -10, 50, 20)
            npcEditFrame.iconEditBox = iconEditBox
            CreateTooltipTwo(iconEditBox, L["Icon"], L["Tooltip_Icon_Desc"], L["Tooltip_Icon_SubText"])


            local GlowText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            GlowText:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 0, -10)
            GlowText:SetText(L["Glow"])

            local importantCheckBox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            importantCheckBox:SetSize(28, 28)
            importantCheckBox:SetPoint("LEFT", GlowText, "RIGHT", 5, 0)
            CreateTooltipTwo(importantCheckBox, L["Important_Glow"])
            npcEditFrame.importantCheckBox = importantCheckBox
            if npcData.important then
                iconGlowTexture:Show()
                importantCheckBox:SetChecked(true)
            else
                iconGlowTexture:Hide()
            end

            local colorPickerButton = CreateFrame("Button", nil, npcEditFrame, "UIPanelButtonTemplate")
            colorPickerButton:SetSize(50, 20)
            colorPickerButton:SetPoint("LEFT", npcEditFrame.importantCheckBox, "RIGHT", 0, 0)
            colorPickerButton:SetText(L["Color"])
            colorPickerButton:SetScript("OnClick", function()
                local currentColor = npcEditFrame.currentColor or {1, 1, 1}
                local currentNpcId = npcEditFrame.currentNpcId

                ColorPickerFrame:SetupColorPickerAndShow({
                    r = currentColor[1], g = currentColor[2], b = currentColor[3],
                    hasOpacity = false, -- Assuming opacity is not needed; set to true if needed
                    swatchFunc = function()
                        local r, g, b = ColorPickerFrame:GetColorRGB()
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentNpcId, {r, g, b})
                        npcEditFrame.currentColor = {r, g, b} -- Update the current color
                        BBP.refreshNpcList()
                    end,
                    cancelFunc = function(previousValues)
                        local r, g, b = previousValues.r, previousValues.g, previousValues.b
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentNpcId, {r, g, b})
                        npcEditFrame.currentColor = {r, g, b} -- Revert to the original color
                        BBP.refreshNpcList()
                    end,
                })
            end)

            local HideText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            HideText:SetPoint("TOPLEFT", GlowText, "BOTTOMLEFT", 0, -10)
            HideText:SetText(L["Hide_Icon"])

            -- Creation of the hideIconCheckbox
            local hideIconCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideIconCheckbox:SetSize(28, 28)
            hideIconCheckbox:SetPoint("LEFT", HideText, "RIGHT", 5, 0)

            local HideHpText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            HideHpText:SetPoint("TOPLEFT", HideText, "BOTTOMLEFT", 0, -10)
            HideHpText:SetText(L["Hide_HP"])

            -- Creation of the hideIconCheckbox
            local hideHpCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideHpCheckbox:SetSize(28, 28)
            hideHpCheckbox:SetPoint("LEFT", HideHpText, "RIGHT", 5, 0)

            CreateTooltipTwo(hideIconCheckbox, L["Hide_Icon"])

            npcEditFrame.hideHpCheckbox = hideHpCheckbox
            npcEditFrame.hideIconCheckbox = hideIconCheckbox

            if npcData.hideIcon then
                npcEditFrame.hideIconCheckbox:SetChecked(true)
                npcEditFrame.iconTexture:Hide()
                npcEditFrame.iconGlowTexture:Hide()
            end

            -- Update Button
            local updateButton = CreateFrame("Button", nil, npcEditFrame, "UIPanelButtonTemplate")
            updateButton:SetSize(80, 22)
            updateButton:SetPoint("BOTTOM", npcEditFrame, "BOTTOM", 0, 10)
            updateButton:SetText(L["Close"])
            npcEditFrame.updateButton = updateButton
        end

        local function PopulateEditFrame(npcId)
            local npcData = npcList[npcId]
            if not npcData then return end
            if not npcEditFrame then return end
            npcEditFrame.currentNpcId = npcId

            npcEditFrame.iconTexture:SetTexture(npcData.icon)
            npcEditFrame.sizeEditBox:SetText(npcData.size or "")
            npcEditFrame.durationEditBox:SetText(npcData.duration or "")
            npcEditFrame.nameEditBox:SetText(npcData.name or "")
            local color = npcData.color
            npcEditFrame.nameEditBox:SetTextColor(color[1], color[2], color[3])
            npcEditFrame.iconGlowTexture:SetVertexColor(unpack(color))
            npcEditFrame.iconEditBox:SetText(npcData.icon or "")
            if npcData.important then
                npcEditFrame.iconGlowTexture:Show()
                npcEditFrame.importantCheckBox:SetChecked(true)
            else
                npcEditFrame.iconGlowTexture:Hide()
                npcEditFrame.importantCheckBox:SetChecked(false)
            end
            if npcData.hideIcon then
                npcEditFrame.iconTexture:Hide()
                npcEditFrame.iconGlowTexture:Hide()
                npcEditFrame.hideIconCheckbox:SetChecked(true)
            else
                npcEditFrame.iconTexture:Show()
                if npcData.important then
                    npcEditFrame.iconGlowTexture:Show()
                end
                npcEditFrame.hideIconCheckbox:SetChecked(false)
            end
            if npcData.hideHp then
                npcEditFrame.hideHpCheckbox:SetChecked(true)
            end
            npcEditFrame.currentColor = npcData.color

            local function updateNpcData()
                local newSize = tonumber(npcEditFrame.sizeEditBox:GetText())
                if newSize then
                    npcList[npcId].size = newSize
                end

                local newDuration = tonumber(npcEditFrame.durationEditBox:GetText())
                if newDuration then
                    npcList[npcId].duration = (newDuration == 0) and nil or newDuration
                end

                local newIcon = tonumber(npcEditFrame.iconEditBox:GetText())
                if newIcon then
                    npcList[npcId].icon = newIcon
                end

                local newName = npcEditFrame.nameEditBox:GetText()
                if newName then
                    npcList[npcId].name = newName
                end

                npcEditFrame.iconTexture:SetTexture(npcData.icon)
                npcEditFrame.currentColor = npcData.color
                npcEditFrame.iconGlowTexture:SetVertexColor(unpack(npcEditFrame.currentColor))
                if npcData.important then
                    npcEditFrame.iconGlowTexture:Show()
                else
                    npcEditFrame.iconGlowTexture:Hide()
                end

                if npcData.hideIcon then
                    npcEditFrame.iconTexture:Hide()
                    npcEditFrame.iconGlowTexture:Hide()
                else
                    npcEditFrame.iconTexture:Show()
                    if npcData.important then
                        npcEditFrame.iconGlowTexture:Show()
                    end
                end
                BBP.refreshNpcList()
            end

            npcEditFrame.sizeEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.sizeEditBox:ClearFocus()
            end)

            npcEditFrame.durationEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.durationEditBox:ClearFocus()
            end)

            npcEditFrame.nameEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.nameEditBox:ClearFocus()
            end)

            npcEditFrame.iconEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.iconEditBox:ClearFocus()
            end)

            npcEditFrame.hideIconCheckbox:SetScript("OnClick", function(self)
                updateHideIconFlag(npcId, self:GetChecked())
                local npcData = npcList[npcId]
                if self:GetChecked() then
                    npcData.hideIcon = true
                    BBP.refreshNpcList()
                    npcEditFrame.iconTexture:Hide()
                    npcEditFrame.iconGlowTexture:Hide()
                else
                    npcData.hideIcon = false
                    BBP.refreshNpcList()
                    npcEditFrame.iconTexture:Show()
                    if npcData.important then
                        npcEditFrame.iconGlowTexture:Show()
                    end
                end
            end)

            npcEditFrame.hideHpCheckbox:SetScript("OnClick", function(self)
                updateHideHpFlag(npcId, self:GetChecked())
                local npcData = npcList[npcId]
                if self:GetChecked() then
                    npcData.hideHp = true
                    BBP.refreshNpcList()
                else
                    npcData.hideIcon = false
                    BBP.refreshNpcList()
                end
            end)


            npcEditFrame.importantCheckBox:SetScript("OnClick", function(self)
                updateImportantFlag(npcId, self:GetChecked())
                local npcData = npcList[npcId]
                if self:GetChecked() then
                    if not npcData.hideIcon then
                        npcEditFrame.iconGlowTexture:Show()
                    end
                else
                    npcEditFrame.iconGlowTexture:Hide()
                end
                BBP.refreshNpcList()
            end)

            -- Update Button Script
            npcEditFrame.updateButton:SetScript("OnClick", function()
                local currentNpcId = npcEditFrame.currentNpcId
                local currentColor = npcEditFrame.currentColor
                local r, g, b = currentColor[1], currentColor[2], currentColor[3]
                updateEntryColor(currentNpcId, {r, g, b})
                updateNpcData()
                npcEditFrame:Hide()
            end)

        end

        local function ShowEditFrame(npcId)
            if not npcEditFrame then
                CreateEditFrame()
            end

            PopulateEditFrame(npcId)
            if npcEditFrame then
                npcEditFrame:Show()
            end
        end

        -- Edit button
        local editButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        editButton:SetSize(50, 20)
        editButton:SetPoint("RIGHT", button, "RIGHT", -105, 0)
        editButton:SetText(L["Edit"])
        editButton:SetScript("OnClick", function()
            ShowEditFrame(npcId)
        end)
        button.editButton = editButton
        CreateTooltipTwo(editButton, L["Edit_NPC_Details"], L["Tooltip_Edit_NPC_Details_Desc"])

        -- Size button
        local sizeButton = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sizeButton:SetPoint("RIGHT", button, "RIGHT", -165, 0)
        local sizeText = npcData.size and string.format(L["Size_Value"], npcData.size) or L["Set_Size"]
        sizeButton:SetText(sizeText)

        -- Creation of the hideIconCheckbox
        local hideIconCheckboxButton = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        hideIconCheckboxButton:SetSize(24, 24)
        hideIconCheckboxButton:SetPoint("RIGHT", button, "RIGHT", -15, 0)
        hideIconCheckboxButton:SetScript("OnClick", function(self)
            updateHideIconFlag(npcId, self:GetChecked())
            if self:GetChecked() then
                iconTexture:Hide()
            else
                iconTexture:Show()
            end
        end)
        CreateTooltipTwo(hideIconCheckboxButton, L["Hide_Icon"])

        if npcData.hideIcon then
            hideIconCheckboxButton:SetChecked(true)
        end

        button.hideIconCheckboxButton = hideIconCheckboxButton

        local importantCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        importantCheckBox:SetSize(24, 24)
        importantCheckBox:SetPoint("RIGHT", button, "RIGHT", -55, 0)
        importantCheckBox:SetScript("OnClick", function(self)
            updateImportantFlag(npcId, self:GetChecked())
        end)
        CreateTooltip(importantCheckBox, L["Important_Glow"])

        if npcData.important then
            importantCheckBox:SetChecked(true)
        end

        button.importantCheckBox = importantCheckBox

        -- Creation of the hideIconCheckbox
        local hideHealthBarCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        hideHealthBarCheckBox:SetSize(24, 24)
        hideHealthBarCheckBox:SetPoint("RIGHT", button, "RIGHT", -35, 0)
        hideHealthBarCheckBox:SetScript("OnClick", function(self)
            updateHideHpFlag(npcId, self:GetChecked())
            BBP.RefreshAllNameplates()
        end)
        CreateTooltipTwo(hideHealthBarCheckBox, L["Hide_Healthbar"])

        if npcData.hideHp then
            hideHealthBarCheckBox:SetChecked(true)
        end

        button.hideHealthBarCheckBox = hideHealthBarCheckBox

        -- Creation of the hideIconCheckbox
        local iconOnlyCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        iconOnlyCheckBox:SetSize(24, 24)
        iconOnlyCheckBox:SetPoint("RIGHT", button, "RIGHT", -75, 0)
        iconOnlyCheckBox:SetScript("OnClick", function(self)
            updateIconOnlyFlag(npcId, self:GetChecked())
            BBP.RefreshAllNameplates()
        end)
        CreateTooltipTwo(iconOnlyCheckBox, L["Icon_Only_Mode"])

        if npcData.iconOnly then
            iconOnlyCheckBox:SetChecked(true)
        end

        button.iconOnlyCheckBox = iconOnlyCheckBox

        return button
    end

    StaticPopupDialogs["BBP_SET_SIZE"] = {
        text = L["Popup_Enter_New_Size_Minimum_10"],
        button1 = L["Set"],
        button2 = L["Cancel"],
        hasEditBox = true,
        maxLetters = 3,
        OnAccept = function(self)
            local newSize = self.editBox:GetText()
            self.data(newSize)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- Static popup for setting duration
    StaticPopupDialogs["BBP_SET_DURATION"] = {
        text = L["Popup_Enter_New_Duration_0_For_No"],
        button1 = L["Set"],
        button2 = L["Cancel"],
        hasEditBox = true,
        maxLetters = 6,
        OnAccept = function(self)
            local input = self.editBox:GetText()
            self.data(input)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs["BBP_DUPLICATE_NPC_CONFIRM_TOTEM"] = {
        text = L["Popup_This_Name_Or_NpcID_Is_Already"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            deleteEntry(selectedLineIndex)
            BBP.refreshNpcList()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local function getSortedNpcList()
        local sortableNpcList = {}
        for npcId, npcData in pairs(npcList) do
            if npcData.duration == 0 then
                npcData.duration = nil
            end
            table.insert(sortableNpcList, {npcId = npcId, npcData = npcData})
        end

        table.sort(sortableNpcList, function(a, b)
            return a.npcData.name:lower() < b.npcData.name:lower()
        end)

        return sortableNpcList
    end

    local sortedNpcList = getSortedNpcList()
    for _, entry in ipairs(sortedNpcList) do
        local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1)
        button.npcId = entry.npcId
        table.insert(textLines, button)
    end

    updateBackgroundColors()
    contentFrame:SetHeight(#textLines * 20)

    -- Edit Box for input
    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize(260, 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    CreateTooltipTwo(editBox, L["Add_New_NPC"], L["Tooltip_Add_New_NPC_Desc_2"], L["Tooltip_Add_New_NPC_SubText"], "ANCHOR_TOP")

    function BBP.refreshNpcList()
        -- Clear existing buttons
        for _, button in ipairs(textLines) do
            button:Hide()
        end
        wipe(textLines)

        local sortedNpcList = getSortedNpcList()

        -- Repopulate list with sorted entries
        for _, entry in ipairs(sortedNpcList) do
            local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1)
            button.npcId = entry.npcId
            table.insert(textLines, button)
        end

        updateBackgroundColors()
        contentFrame:SetHeight(#textLines * 20)
    end

    local function addOrUpdateEntry(inputText)
        editBox:SetText("")
        if not inputText or inputText == "" then return end

        -- Splitting the input text into arguments
        local args = {}
        for word in string.gmatch(inputText, "[^,]+") do
            table.insert(args, word:match("^%s*(.-)%s*$")) -- Trim leading and trailing spaces
        end

        local npcId = tonumber(args[1])
        local name = args[2] and args[2]:gsub("^%s*(.-)%s*$", "%1") or "A no name entry"
        local spellId = tonumber(args[3])

        if not npcId then
            print(L["Print_Invalid_NPC_ID"])
            return
        end

        -- Check for duplicates
        for index, line in ipairs(textLines) do
            if line.npcId == npcId then
                selectedLineIndex = index  -- Set the index of the duplicate entry
                StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_TOTEM")
                return
            end
        end

        -- Create or update the npc entry
        local npcData = {
            name = name,  -- Name from input, or default if not provided
            icon = spellId and C_Spell.GetSpellTexture(spellId) or 533422,  -- Get icon if spellId is provided
            hideIcon = false,
            size = 30,  -- Default size
            duration = nil,  -- Ensure duration is set to nil
            color = {1, 1, 1},
            important = true
        }
        npcList[npcId] = npcData

        -- Create a new line button for the npc
        local newButton = createNpcLineButton(npcId, npcData, #textLines + 1)
        newButton.npcId = npcId  -- Assign npcId to the button
        table.insert(textLines, newButton)  -- Insert the button, not the index

        updateBackgroundColors()
        contentFrame:SetHeight(#textLines * 20)
        BBP.refreshNpcList()
        BBP.RefreshAllNameplates()
    end


    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
        editBox:ClearFocus()
    end)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText(L["Add"])
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)

    return scrollFrame
end

local function CreateNpcListWidth(subPanel, npcList, refreshFunc, width, height)
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}
    local selectedNpcId = nil
    local selectedLineIndex = nil

    local function updateBackgroundColors()
        for i, button in ipairs(textLines) do
            local bg = button.bgImg
            if i % 2 == 0 then
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)
            else
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            end
        end
    end

    local function deleteEntry(index)
        if not index or not textLines[index] then return end

        local npcId = textLines[index].npcId
        if not npcId or not npcList[npcId] then return end

        npcList[npcId] = nil
        textLines[index]:Hide()
        table.remove(textLines, index)

        for i = index, #textLines do
            textLines[i]:SetPoint("TOPLEFT", 10, -(i - 1) * 20)
            textLines[i].deleteButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    deleteEntry(i)
                else
                    selectedLineIndex = i
                    StaticPopup_Show("BBP_DELETE_NPC_CONFIRM")
                end
            end)
        end

        updateBackgroundColors()
        refreshFunc()
    end

    StaticPopupDialogs["BBP_DELETE_NPC_CONFIRM"] = {
        text = L["Dialog_Confirm_Delete"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            deleteEntry(selectedLineIndex)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local function updateImportantFlag(npcId, importantFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.important = importantFlag
        end

        refreshFunc()
    end

    local function updateHideIconFlag(npcId, hideIconFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.hideIcon = hideIconFlag
        end

        refreshFunc()
    end

    local function updateHideHpFlag(npcId, hideHpFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.hideHp = hideHpFlag
        end

        refreshFunc()
    end

    local function updateIconOnlyFlag(npcId, iconOnlyFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.iconOnly = iconOnlyFlag
        end

        refreshFunc()
    end

    local function updatehpWidthFlag(npcId, widthOnFlag)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.widthOn = widthOnFlag
        end

        refreshFunc()
    end

    local function updateEntryColor(npcId, color)
        if not npcId then return end

        local npcData = npcList[npcId]
        if npcData then
            npcData.color = color
        end

        refreshFunc()
    end

    local function createNpcLineButton(npcId, npcData, index)
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or 310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg

        -- New icon texture
        local iconTexture = button:CreateTexture(nil, "OVERLAY")
        iconTexture:SetSize(20, 20)  -- Same height as the button
        iconTexture:SetPoint("LEFT", button, "LEFT", -10, 0)

        -- Set the icon image
        if npcData.icon then
            iconTexture:SetTexture(npcData.icon)
        end

        button.icon = iconTexture

        if npcData.hideIcon then
            iconTexture:Hide()
        else
            iconTexture:Show()
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", 15, 0)
        text:SetText((npcData.name .. " ("..npcId .. ")") or "")

        -- Delete button
        local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
        deleteButton:SetText("X")

        deleteButton:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                deleteEntry(index)
            else
                selectedLineIndex = index
                StaticPopup_Show("BBP_DELETE_NPC_CONFIRM")
            end
        end)
        button.deleteButton = deleteButton

        -- Set text color based on NPC color attribute
        local color = npcData.color or {1, 1, 1}
        text:SetTextColor(color[1], color[2], color[3])

        -- Function to create a label and an edit box for a given property
        local function CreatePropertyField(frame, labelText, anchorFrame, offsetX, offsetY, editBoxWidth, editBoxHeight)
            local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", offsetX, offsetY)
            label:SetText(labelText)

            local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
            editBox:SetSize(editBoxWidth, editBoxHeight)
            editBox:SetPoint("LEFT", label, "RIGHT", 5, 0)
            editBox:SetAutoFocus(false)

            return label, editBox
        end


        local function CreateEditFrame()
            npcEditFrame = CreateFrame("Frame", "NPC_EditFrame", UIParent, "DefaultPanelFlatTemplate")
            npcEditFrame:SetSize(350, 250)
            npcEditFrame:SetPoint("CENTER")
            npcEditFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            npcEditFrame:SetFrameLevel(550)
            npcEditFrame:SetIgnoreParentAlpha(true)
            npcEditFrame:SetTitle(L["Edit_NPC_Details"])
            npcEditFrame:EnableMouse(true)
            npcEditFrame:SetMovable(true)
            npcEditFrame:SetClampedToScreen(true)
            npcEditFrame:RegisterForDrag("LeftButton")
            npcEditFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            npcEditFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            npcEditFrame.closeButton = CreateFrame("Button", nil, npcEditFrame, "UIPanelCloseButton")
            npcEditFrame.closeButton:SetFrameLevel((npcEditFrame.TitleContainer or npcEditFrame):GetFrameLevel() + 10)
            npcEditFrame.closeButton:SetPoint("TOPRIGHT", npcEditFrame, "TOPRIGHT", 0, 0)
            npcEditFrame.closeButton:SetScript("OnClick", function()
                npcEditFrame:Hide()
            end)

            npcEditFrame.bg = npcEditFrame:CreateTexture(nil, "BACKGROUND")
            npcEditFrame.bg:SetPoint("TOPLEFT", npcEditFrame, "TOPLEFT", 7, -3)
            npcEditFrame.bg:SetPoint("BOTTOMRIGHT", npcEditFrame, "BOTTOMRIGHT", -3, 3)
            npcEditFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            -- Icon
            local iconTexture = npcEditFrame:CreateTexture(nil, "ARTWORK")
            iconTexture:SetSize(70, 70)
            iconTexture:SetPoint("TOPLEFT", npcEditFrame, "TOPLEFT", 70, -100)
            npcEditFrame.iconTexture = iconTexture

            -- IconGlow
            local iconGlowTexture = npcEditFrame:CreateTexture(nil, "OVERLAY")
            iconGlowTexture:SetSize(70, 70)
            iconGlowTexture:SetBlendMode("ADD")
            iconGlowTexture:SetAtlas("clickcast-highlight-spellbook")
            iconGlowTexture:SetDesaturated(true)
            iconGlowTexture:SetPoint('TOPLEFT', iconTexture, 'TOPLEFT', -26, 26)
            iconGlowTexture:SetPoint('BOTTOMRIGHT', iconTexture, 'BOTTOMRIGHT', 26, -26)
            iconGlowTexture:SetVertexColor(unpack(color))
            npcEditFrame.iconGlowTexture = iconGlowTexture

            -- Edit Boxes and Labels for NPC properties
            local nameLabel, nameEditBox = CreatePropertyField(npcEditFrame, L["Name_Colon"], npcEditFrame.iconTexture, -35, 125, 220, 25)
            npcEditFrame.nameEditBox = nameEditBox

            local durationLabel, durationEditBox = CreatePropertyField(npcEditFrame, L["Duration_Colon"], npcEditFrame.iconTexture, 95, 91, 50, 20)
            npcEditFrame.durationEditBox = durationEditBox
            CreateTooltipTwo(durationEditBox, L["Duration"], L["Tooltip_Duration_Desc"])

            local sizeLabel, sizeEditBox = CreatePropertyField(npcEditFrame, L["Size_Colon"], durationLabel, 0, -10, 50, 20)
            npcEditFrame.sizeEditBox = sizeEditBox
            CreateTooltipTwo(sizeEditBox, L["Size"], L["Tooltip_Size_Desc"])

            local iconLabel, iconEditBox = CreatePropertyField(npcEditFrame, L["Icon_Colon"], sizeLabel, 0, -10, 50, 20)
            npcEditFrame.iconEditBox = iconEditBox
            CreateTooltipTwo(iconEditBox, L["Icon"], L["Tooltip_Icon_Desc"], L["Tooltip_Icon_SubText"])


            local GlowText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            GlowText:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 0, -10)
            GlowText:SetText(L["Glow"])

            local importantCheckBox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            importantCheckBox:SetSize(28, 28)
            importantCheckBox:SetPoint("LEFT", GlowText, "RIGHT", 5, 0)
            CreateTooltipTwo(importantCheckBox, L["Important_Glow"])
            npcEditFrame.importantCheckBox = importantCheckBox
            if npcData.important then
                iconGlowTexture:Show()
                importantCheckBox:SetChecked(true)
            else
                iconGlowTexture:Hide()
            end

            local colorPickerButton = CreateFrame("Button", nil, npcEditFrame, "UIPanelButtonTemplate")
            colorPickerButton:SetSize(50, 20)
            colorPickerButton:SetPoint("LEFT", npcEditFrame.importantCheckBox, "RIGHT", 0, 0)
            colorPickerButton:SetText(L["Color"])
            colorPickerButton:SetScript("OnClick", function()
                local currentColor = npcEditFrame.currentColor or {1, 1, 1}
                local currentNpcId = npcEditFrame.currentNpcId

                ColorPickerFrame:SetupColorPickerAndShow({
                    r = currentColor[1], g = currentColor[2], b = currentColor[3],
                    hasOpacity = false, -- Assuming opacity is not needed; set to true if needed
                    swatchFunc = function()
                        local r, g, b = ColorPickerFrame:GetColorRGB()
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentNpcId, {r, g, b})
                        npcEditFrame.currentColor = {r, g, b} -- Update the current color
                        BBP.refreshNpcList()
                    end,
                    cancelFunc = function(previousValues)
                        local r, g, b = previousValues.r, previousValues.g, previousValues.b
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentNpcId, {r, g, b})
                        npcEditFrame.currentColor = {r, g, b} -- Revert to the original color
                        BBP.refreshNpcList()
                    end,
                })
            end)

            local HideText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            HideText:SetPoint("TOPLEFT", GlowText, "BOTTOMLEFT", 0, -10)
            HideText:SetText(L["Hide_Icon"])

            -- Creation of the hideIconCheckbox
            local hideIconCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideIconCheckbox:SetSize(28, 28)
            hideIconCheckbox:SetPoint("LEFT", HideText, "RIGHT", 5, 0)

            local HideHpText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            HideHpText:SetPoint("TOPLEFT", HideText, "BOTTOMLEFT", 0, -10)
            HideHpText:SetText(L["Hide_HP"])

            -- Creation of the hideIconCheckbox
            local hideHpCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideHpCheckbox:SetSize(28, 28)
            hideHpCheckbox:SetPoint("LEFT", HideHpText, "RIGHT", 5, 0)

            CreateTooltipTwo(hideIconCheckbox, L["Hide_Icon"])

            npcEditFrame.hideHpCheckbox = hideHpCheckbox
            npcEditFrame.hideIconCheckbox = hideIconCheckbox

            if npcData.hideIcon then
                npcEditFrame.hideIconCheckbox:SetChecked(true)
                npcEditFrame.iconTexture:Hide()
                npcEditFrame.iconGlowTexture:Hide()
            end

            -- Update Button
            local updateButton = CreateFrame("Button", nil, npcEditFrame, "UIPanelButtonTemplate")
            updateButton:SetSize(80, 22)
            updateButton:SetPoint("BOTTOM", npcEditFrame, "BOTTOM", 0, 10)
            updateButton:SetText(L["Close"])
            npcEditFrame.updateButton = updateButton
        end

        local function PopulateEditFrame(npcId)
            local npcData = npcList[npcId]
            if not npcData then return end
            if not npcEditFrame then return end
            npcEditFrame.currentNpcId = npcId

            npcEditFrame.iconTexture:SetTexture(npcData.icon)
            npcEditFrame.sizeEditBox:SetText(npcData.size or "")
            npcEditFrame.durationEditBox:SetText(npcData.duration or "")
            npcEditFrame.nameEditBox:SetText(npcData.name or "")
            local color = npcData.color
            npcEditFrame.nameEditBox:SetTextColor(color[1], color[2], color[3])
            npcEditFrame.iconGlowTexture:SetVertexColor(unpack(color))
            npcEditFrame.iconEditBox:SetText(npcData.icon or "")
            if npcData.important then
                npcEditFrame.iconGlowTexture:Show()
                npcEditFrame.importantCheckBox:SetChecked(true)
            else
                npcEditFrame.iconGlowTexture:Hide()
                npcEditFrame.importantCheckBox:SetChecked(false)
            end
            if npcData.hideIcon then
                npcEditFrame.iconTexture:Hide()
                npcEditFrame.iconGlowTexture:Hide()
                npcEditFrame.hideIconCheckbox:SetChecked(true)
            else
                npcEditFrame.iconTexture:Show()
                if npcData.important then
                    npcEditFrame.iconGlowTexture:Show()
                end
                npcEditFrame.hideIconCheckbox:SetChecked(false)
            end
            if npcData.hideHp then
                npcEditFrame.hideHpCheckbox:SetChecked(true)
            end
            npcEditFrame.currentColor = npcData.color

            local function updateNpcData()
                local newSize = tonumber(npcEditFrame.sizeEditBox:GetText())
                if newSize then
                    npcList[npcId].size = newSize
                end

                local newDuration = tonumber(npcEditFrame.durationEditBox:GetText())
                if newDuration then
                    npcList[npcId].duration = (newDuration == 0) and nil or newDuration
                end

                local newIcon = tonumber(npcEditFrame.iconEditBox:GetText())
                if newIcon then
                    npcList[npcId].icon = newIcon
                end

                local newName = npcEditFrame.nameEditBox:GetText()
                if newName then
                    npcList[npcId].name = newName
                end

                npcEditFrame.iconTexture:SetTexture(npcData.icon)
                npcEditFrame.currentColor = npcData.color
                npcEditFrame.iconGlowTexture:SetVertexColor(unpack(npcEditFrame.currentColor))
                if npcData.important then
                    npcEditFrame.iconGlowTexture:Show()
                else
                    npcEditFrame.iconGlowTexture:Hide()
                end

                if npcData.hideIcon then
                    npcEditFrame.iconTexture:Hide()
                    npcEditFrame.iconGlowTexture:Hide()
                else
                    npcEditFrame.iconTexture:Show()
                    if npcData.important then
                        npcEditFrame.iconGlowTexture:Show()
                    end
                end
                BBP.refreshNpcList()
            end

            npcEditFrame.sizeEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.sizeEditBox:ClearFocus()
            end)

            npcEditFrame.durationEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.durationEditBox:ClearFocus()
            end)

            npcEditFrame.nameEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.nameEditBox:ClearFocus()
            end)

            npcEditFrame.iconEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.iconEditBox:ClearFocus()
            end)

            npcEditFrame.hideIconCheckbox:SetScript("OnClick", function(self)
                updateHideIconFlag(npcId, self:GetChecked())
                local npcData = npcList[npcId]
                if self:GetChecked() then
                    npcData.hideIcon = true
                    BBP.refreshNpcList()
                    npcEditFrame.iconTexture:Hide()
                    npcEditFrame.iconGlowTexture:Hide()
                else
                    npcData.hideIcon = false
                    BBP.refreshNpcList()
                    npcEditFrame.iconTexture:Show()
                    if npcData.important then
                        npcEditFrame.iconGlowTexture:Show()
                    end
                end
            end)

            npcEditFrame.hideHpCheckbox:SetScript("OnClick", function(self)
                updateHideHpFlag(npcId, self:GetChecked())
                local npcData = npcList[npcId]
                if self:GetChecked() then
                    npcData.hideHp = true
                    BBP.refreshNpcList()
                else
                    npcData.hideIcon = false
                    BBP.refreshNpcList()
                end
            end)


            npcEditFrame.importantCheckBox:SetScript("OnClick", function(self)
                updateImportantFlag(npcId, self:GetChecked())
                local npcData = npcList[npcId]
                if self:GetChecked() then
                    if not npcData.hideIcon then
                        npcEditFrame.iconGlowTexture:Show()
                    end
                else
                    npcEditFrame.iconGlowTexture:Hide()
                end
                BBP.refreshNpcList()
            end)

            -- Update Button Script
            npcEditFrame.updateButton:SetScript("OnClick", function()
                local currentNpcId = npcEditFrame.currentNpcId
                local currentColor = npcEditFrame.currentColor
                local r, g, b = currentColor[1], currentColor[2], currentColor[3]
                updateEntryColor(currentNpcId, {r, g, b})
                updateNpcData()
                npcEditFrame:Hide()
            end)

        end

        local function ShowEditFrame(npcId)
            if not npcEditFrame then
                CreateEditFrame()
            end

            PopulateEditFrame(npcId)
            if npcEditFrame then
                npcEditFrame:Show()
            end
        end

        -- Edit button
        local editButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        editButton:SetSize(50, 20)
        editButton:SetPoint("RIGHT", button, "RIGHT", -250, 0)
        editButton:SetText(L["Edit"])
        editButton:SetScript("OnClick", function()
            ShowEditFrame(npcId)
        end)
        button.editButton = editButton
        CreateTooltipTwo(editButton, L["Edit_NPC_Details"], L["Tooltip_Edit_NPC_Details_Desc"])

        -- Size button
        local sizeButton = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sizeButton:SetPoint("LEFT", button, "RIGHT", -355, 0)
        local sizeText = npcData.size and string.format(L["Size_Value"], npcData.size) or L["Set_Size"]
        sizeButton:SetText(sizeText)

        -- Creation of the hideIconCheckbox
        local hideIconCheckboxButton = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        hideIconCheckboxButton:SetSize(24, 24)
        hideIconCheckboxButton:SetPoint("RIGHT", button, "RIGHT", -15, 0)
        hideIconCheckboxButton:SetScript("OnClick", function(self)
            updateHideIconFlag(npcId, self:GetChecked())
            if self:GetChecked() then
                iconTexture:Hide()
            else
                iconTexture:Show()
            end
        end)
        CreateTooltipTwo(hideIconCheckboxButton, L["Hide_Icon"])

        if npcData.hideIcon then
            hideIconCheckboxButton:SetChecked(true)
        end

        button.hideIconCheckboxButton = hideIconCheckboxButton

        local importantCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        importantCheckBox:SetSize(24, 24)
        importantCheckBox:SetPoint("RIGHT", button, "RIGHT", -55, 0)
        importantCheckBox:SetScript("OnClick", function(self)
            updateImportantFlag(npcId, self:GetChecked())
        end)
        CreateTooltip(importantCheckBox, L["Important_Glow"])

        if npcData.important then
            importantCheckBox:SetChecked(true)
        end

        button.importantCheckBox = importantCheckBox

        -- Creation of the hideIconCheckbox
        local hideHealthBarCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        hideHealthBarCheckBox:SetSize(24, 24)
        hideHealthBarCheckBox:SetPoint("RIGHT", button, "RIGHT", -35, 0)
        hideHealthBarCheckBox:SetScript("OnClick", function(self)
            updateHideHpFlag(npcId, self:GetChecked())
            BBP.RefreshAllNameplates()
        end)
        CreateTooltipTwo(hideHealthBarCheckBox, L["Hide_Healthbar"])

        if npcData.hideHp then
            hideHealthBarCheckBox:SetChecked(true)
        end

        button.hideHealthBarCheckBox = hideHealthBarCheckBox


        -- Creation of the hideIconCheckbox
        local iconOnlyCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        iconOnlyCheckBox:SetSize(24, 24)
        iconOnlyCheckBox:SetPoint("RIGHT", button, "RIGHT", -75, 0)
        iconOnlyCheckBox:SetScript("OnClick", function(self)
            updateIconOnlyFlag(npcId, self:GetChecked())
            BBP.RefreshAllNameplates()
        end)
        CreateTooltipTwo(iconOnlyCheckBox, L["Icon_Only_Mode"])

        if npcData.iconOnly then
            iconOnlyCheckBox:SetChecked(true)
        end

        button.iconOnlyCheckBox = iconOnlyCheckBox


        --if prioSlider then
                -- Create Input Box on Right Click


                local barWidthSlider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
                local editBox = CreateFrame("EditBox", nil, barWidthSlider, "InputBoxTemplate")
                editBox:SetAutoFocus(false)
                editBox:SetWidth(50)
                editBox:SetHeight(20)
                editBox:SetMultiLine(false)
                editBox:SetFrameStrata("TOOLTIP")
                editBox:Hide()

                editBox:SetFontObject(GameFontHighlightSmall)

                barWidthSlider:SetSize(100, 16)
                barWidthSlider:SetPoint("LEFT", button, "RIGHT", -203, 0)
                barWidthSlider:SetOrientation("HORIZONTAL")
                -- if BetterBlizzPlatesDB.classicNameplates then
                --     barWidthSlider:SetMinMaxValues(-48, 48)
                -- else
                    barWidthSlider:SetMinMaxValues(-65, 53)
                --end
                barWidthSlider:SetValueStep(1)
                barWidthSlider:SetValue(npcData.hpWidth or 0) -- Set the default priority to 1 if not specified
                barWidthSlider:SetObeyStepOnDrag(true)
                barWidthSlider.Low:SetText("")
                barWidthSlider.High:SetText("")
                CreateTooltipTwo(barWidthSlider, L["Healthbar_Width"], L["Tooltip_Healthbar_Width_Desc"])

                editBox:SetPoint("CENTER", barWidthSlider, "CENTER", 0, 0)

                barWidthSlider:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        editBox:Show()
                        editBox:SetFocus()
                    end
                end)

                local function HandleEditBoxInput()
                    local inputValue = tonumber(editBox:GetText())
                    if inputValue then
                        barWidthSlider:SetValue(inputValue)
                        npcData.hpWidth = inputValue
                    end
                    editBox:Hide()
                    BBP.RefreshAllNameplates()
                end

                editBox:SetScript("OnEnterPressed", HandleEditBoxInput)
                editBox:SetScript("OnEscapePressed", function() editBox:Hide() end) -- Hide the edit box on escape

                local priorityText = barWidthSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                priorityText:SetPoint("RIGHT", barWidthSlider, "LEFT", -5, 0)
                priorityText:SetText(barWidthSlider:GetValue())
                priorityText:SetTextColor(1, 0.8196, 0, 1)

                barWidthSlider:SetScript("OnValueChanged", function(self, value)
                    local newValue = math.floor(value + 0.5)  -- Round to the nearest integer
                    self:SetValue(newValue)
                    priorityText:SetText(newValue)
                    npcData.hpWidth = newValue
                    BBP.RefreshAllNameplates()
                end)

                button.barWidthSlider = barWidthSlider

        --end

        -- Creation of the hideIconCheckbox
        local hpWidthCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        hpWidthCheckBox:SetSize(24, 24)
        hpWidthCheckBox:SetPoint("RIGHT", button, "RIGHT", -222, 0)
        hpWidthCheckBox:SetScript("OnClick", function(self)
            updatehpWidthFlag(npcId, self:GetChecked())
            BBP.RefreshAllNameplates()
            if self:GetChecked() then
                EnableElement(button.barWidthSlider)
            else
                DisableElement(button.barWidthSlider)
            end
        end)
        CreateTooltipTwo(hpWidthCheckBox, L["Change_HP_Bar_Width"])

        if npcData.widthOn then
            hpWidthCheckBox:SetChecked(true)
        else
            DisableElement(barWidthSlider)
        end

        button.hpWidthCheckBox = hpWidthCheckBox

        return button
    end

    StaticPopupDialogs["BBP_SET_SIZE"] = {
        text = L["Popup_Enter_New_Size_Minimum_10"],
        button1 = L["Set"],
        button2 = L["Cancel"],
        hasEditBox = true,
        maxLetters = 3,
        OnAccept = function(self)
            local newSize = self.editBox:GetText()
            self.data(newSize)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- Static popup for setting duration
    StaticPopupDialogs["BBP_SET_DURATION"] = {
        text = L["Popup_Enter_New_Duration_0_For_No"],
        button1 = L["Set"],
        button2 = L["Cancel"],
        hasEditBox = true,
        maxLetters = 6,
        OnAccept = function(self)
            local input = self.editBox:GetText()
            self.data(input)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs["BBP_DUPLICATE_NPC_CONFIRM_TOTEM"] = {
        text = L["Popup_This_Name_Or_NpcID_Is_Already"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            deleteEntry(selectedLineIndex)
            BBP.refreshNpcList()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local function getSortedNpcList()
        local sortableNpcList = {}
        for npcId, npcData in pairs(npcList) do
            if npcData.duration == 0 then
                npcData.duration = nil
            end
            table.insert(sortableNpcList, {npcId = npcId, npcData = npcData})
        end

        table.sort(sortableNpcList, function(a, b)
            return a.npcData.name:lower() < b.npcData.name:lower()
        end)

        return sortableNpcList
    end

    local sortedNpcList = getSortedNpcList()
    for _, entry in ipairs(sortedNpcList) do
        local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1)
        button.npcId = entry.npcId
        table.insert(textLines, button)
    end

    updateBackgroundColors()
    contentFrame:SetHeight(#textLines * 20)

    -- Edit Box for input
    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize(260, 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    CreateTooltipTwo(editBox, L["Add_New_NPC"], L["Tooltip_Add_New_NPC_Desc_2"], L["Tooltip_Add_New_NPC_SubText"], "ANCHOR_TOP")

    function BBP.refreshNpcList()
        -- Clear existing buttons
        for _, button in ipairs(textLines) do
            button:Hide()
        end
        wipe(textLines)

        local sortedNpcList = getSortedNpcList()

        -- Repopulate list with sorted entries
        for _, entry in ipairs(sortedNpcList) do
            local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1)
            button.npcId = entry.npcId
            table.insert(textLines, button)
        end

        updateBackgroundColors()
        contentFrame:SetHeight(#textLines * 20)
    end

    local function addOrUpdateEntry(inputText)
        editBox:SetText("")
        if not inputText or inputText == "" then return end

        -- Splitting the input text into arguments
        local args = {}
        for word in string.gmatch(inputText, "[^,]+") do
            table.insert(args, word:match("^%s*(.-)%s*$")) -- Trim leading and trailing spaces
        end

        local npcId = tonumber(args[1])
        local name = args[2] and args[2]:gsub("^%s*(.-)%s*$", "%1") or "A no name entry"
        local spellId = tonumber(args[3])

        if not npcId then
            print(L["Print_Invalid_NPC_ID"])
            return
        end

        -- Check for duplicates
        for index, line in ipairs(textLines) do
            if line.npcId == npcId then
                selectedLineIndex = index  -- Set the index of the duplicate entry
                StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_TOTEM")
                return
            end
        end

        -- Create or update the npc entry
        local npcData = {
            name = name,  -- Name from input, or default if not provided
            icon = spellId and C_Spell.GetSpellTexture(spellId) or 533422,  -- Get icon if spellId is provided
            hideIcon = false,
            size = 30,  -- Default size
            duration = nil,  -- Ensure duration is set to nil
            color = {1, 1, 1},
            important = true
        }
        npcList[npcId] = npcData

        -- Create a new line button for the npc
        local newButton = createNpcLineButton(npcId, npcData, #textLines + 1)
        newButton.npcId = npcId  -- Assign npcId to the button
        table.insert(textLines, newButton)  -- Insert the button, not the index

        updateBackgroundColors()
        contentFrame:SetHeight(#textLines * 20)
        BBP.refreshNpcList()
        BBP.RefreshAllNameplates()
    end


    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
        editBox:ClearFocus()
    end)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText(L["Add"])
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)

    return scrollFrame
end

local function CreateTitle(parent)
    RegisterGuiFontPanel(parent)
    local mainGuiAnchor = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")

    local addonNameText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 47)
    addonNameText:SetText("BetterBlizzPlates")
    local addonNameIcon = parent:CreateTexture(nil, "ARTWORK")
    addonNameIcon:SetAtlas("gmchat-icon-blizz")
    addonNameIcon:SetSize(22, 22)
    addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    local verNumber = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    verNumber:SetText(BBP.VersionNumber)
end

local function CreateSearchFrame()
    local searchFrame = CreateFrame("Frame", "BBPSearchFrame", UIParent)
    searchFrame:SetSize(680, 610)
    searchFrame:SetPoint("CENTER", UIParent, "CENTER")
    searchFrame:SetFrameStrata("HIGH")
    searchFrame:Hide()

    local wipText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wipText:SetPoint("BOTTOM", searchFrame, "BOTTOM", -10, 10)
    wipText:SetText(L["Search_WIP"])

    CreateTitle(searchFrame)

    local bgImg = searchFrame:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", searchFrame, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0, 0, 0)

    -- Title text for "Misc settings"
    local settingsText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    settingsText:SetPoint("TOPLEFT", searchFrame, "TOPLEFT", 20, 0)
    settingsText:SetText(L["Search_Results"])

    local cappedText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    cappedText:SetPoint("LEFT", settingsText, "RIGHT", 6, -1)
    cappedText:Hide()

    local searchIcon = searchFrame:CreateTexture(nil, "ARTWORK")
    searchIcon:SetAtlas("communities-icon-searchmagnifyingglass")
    searchIcon:SetSize(28, 28)
    searchIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    -- Reference the existing SettingsPanel.SearchBox to copy properties
    local referenceBox = SettingsPanel.SearchBox

    -- Create the search input field on top of SettingsPanel.SearchBox
    local searchBox = CreateFrame("EditBox", nil, SettingsPanel, "InputBoxTemplate")
    searchBox:SetSize(referenceBox:GetWidth() + 1, referenceBox:GetHeight() + 1)
    searchBox:SetPoint("CENTER", referenceBox, "CENTER")
    searchBox:SetFrameStrata("HIGH")
    searchBox:SetAutoFocus(false)
    searchBox.Left:Hide()
    searchBox.Right:Hide()
    searchBox.Middle:Hide()
    searchBox:SetFontObject(referenceBox:GetFontObject())
    searchBox:SetTextInsets(16, 8, 0, 0)
    searchBox:Hide()
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    CreateTooltipTwo(searchBox, L["Search"] .. " |A:shop-games-magnifyingglass:17:17|a", L["Tooltip_Search_Desc"], nil, "TOP")

    -- Create the list to display search results, positioned under the title and icon
    local resultsList = CreateFrame("Frame", nil, searchFrame)
    resultsList:SetSize(640, 500)
    resultsList:SetPoint("TOP", settingsText, "BOTTOM", 0, -10)

    -- Search function that clears results or searches for query
    local checkboxPool = {}
    local sliderPool = {}
    local dropdownPool = {}

    local function UpdateSearchDropdownStates()
        for _, resultDropdown in ipairs(dropdownPool) do
            if resultDropdown:IsShown() then
                local parentKey = resultDropdown.parentKey
                local enabled = not parentKey or BetterBlizzPlatesDB[parentKey] and true or false
                resultDropdown:SetEnabled(enabled)
                resultDropdown:SetAlpha(enabled and 1 or 0.5)
            end
        end
    end

    local function SearchElements(query)
        -- Clear existing results
        for _, child in ipairs({resultsList:GetChildren()}) do
            child:Hide()
        end
        cappedText:Hide()

        if query == "" then
            return
        end

        -- Convert the query into lowercase and split it into individual words
        query = string.lower(query)
        local queryWords = { strsplit(" ", query) }

        local checkboxCount = 0
        local sliderCount = 0
        local checkboxMatches = 0
        local sliderMatches = 0
        local dropdownCount = 0
        local dropdownMatches = 0
        local yOffsetCheckbox = -20  -- Starting position for the first checkbox
        local yOffsetSlider = -20    -- Starting position for the first slider

        -- Helper function to check if all query words are in the label
        local function matchesQuery(label)
            label = string.lower(label)
            for _, queryWord in ipairs(queryWords) do
                if not string.find(label, queryWord) then
                    return false
                end
            end
            return true
        end

        local function applyRightClickScript(searchCheckbox, originalCheckbox)
            local handlers = originalCheckbox.bbpMouseDownHandlers
            if not handlers and originalCheckbox.GetScript then
                local originalScript = originalCheckbox:GetScript("OnMouseDown")
                handlers = originalScript and { originalScript }
            end
            if handlers and #handlers > 0 then
                searchCheckbox:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        for _, handler in ipairs(handlers) do
                            handler(originalCheckbox, button)
                        end
                    end
                end)
            else
                searchCheckbox:SetScript("OnMouseDown", nil)
            end
        end

        for _, data in ipairs(dropdownList) do
            local dropdown = data.dropdown
            local base = data.label .. " " .. (dropdown.tooltipTitle or "")
            local texts = { base .. " " .. (dropdown.tooltipMainText or "") }
            for _, option in ipairs(dropdown.options) do
                texts[#texts + 1] = base .. " " .. (option.label or "") .. " " .. (option.tooltipTitle or "") .. " " .. (option.tooltip or "")
            end
            for _, term in ipairs(dropdown.searchExtraTerms or {}) do
                texts[#texts + 1] = base .. " " .. term
            end
            local isMatch = false
            for _, text in ipairs(texts) do
                if matchesQuery(text) then
                    isMatch = true
                    break
                end
            end
            if isMatch then
                dropdownMatches = dropdownMatches + 1
            end
            if isMatch and dropdownCount < MAX_SEARCH_DROPDOWNS then
                dropdownCount = dropdownCount + 1
                local resultDropdown = dropdownPool[dropdownCount]
                if not resultDropdown then
                    resultDropdown = CreateFrame("DropdownButton", nil, resultsList, "WowStyle1DropdownTemplate")
                    resultDropdown:SetWidth(180)
                    resultDropdown:SetScale(SEARCH_DROPDOWN_SCALE)
                    dropdownPool[dropdownCount] = resultDropdown
                end
                resultDropdown:ClearAllPoints()
                resultDropdown:SetPoint("TOPLEFT", searchIcon, "TOPLEFT", 31 / SEARCH_DROPDOWN_SCALE, (yOffsetCheckbox - 1) / SEARCH_DROPDOWN_SCALE)
                resultDropdown.parentKey = dropdown.searchParentKey
                resultDropdown:SetDefaultText(data.label)
                resultDropdown:SetSelectionText(function() return data.label end)
                resultDropdown:SetupMenu(dropdown.menuGenerator)
                resultDropdown:OverrideText(data.label)
                CreateTooltipTwo(resultDropdown, dropdown.tooltipTitle or data.label, dropdown.tooltipMainText, nil, nil, nil, nil, dropdown.searchCategory)
                resultDropdown:Show()
                yOffsetCheckbox = yOffsetCheckbox - 26
            end
        end
        local checkboxCap = MAX_SEARCH_CHECKBOXES - math.ceil(dropdownCount * 26 / 21)

        -- Search through checkboxes
        for _, data in ipairs(checkBoxList) do
            -- Prepare the label and tooltip text
            local label = string.lower(data.label or "")
            local tooltipTitle = string.lower(data.checkbox.tooltipTitle or "")
            local tooltipMainText = string.lower(data.checkbox.tooltipMainText or "")
            local tooltipSubText = string.lower(data.checkbox.tooltipSubText or "")
            local tooltipCVarName = string.lower(data.checkbox.tooltipCVarName and data.checkbox.tooltipCVarName.." CVar" or "")

            -- Check if all query words are found in any of the searchable fields
            local isMatch = matchesQuery(label) or matchesQuery(tooltipTitle) or matchesQuery(tooltipMainText) or matchesQuery(tooltipSubText) or matchesQuery(tooltipCVarName)
            if not isMatch then
                for _, term in ipairs(data.checkbox.searchExtraTerms or {}) do
                    if matchesQuery(label .. " " .. term) then
                        isMatch = true
                        break
                    end
                end
            end
            if isMatch then
                checkboxMatches = checkboxMatches + 1
            end
            if isMatch and checkboxCount < checkboxCap then
                checkboxCount = checkboxCount + 1

                -- Re-use or create a new checkbox from the pool
                local resultCheckBox = checkboxPool[checkboxCount]
                if not resultCheckBox then
                    resultCheckBox = CreateFrame("CheckButton", nil, resultsList, "InterfaceOptionsCheckButtonTemplate")
                    resultCheckBox:SetSize(24, 24)
                    resultCheckBox.Text:SetFont(fontSmall, 12)
                    checkboxPool[checkboxCount] = resultCheckBox
                end

                -- Update checkbox properties and position
                resultCheckBox:ClearAllPoints()
                resultCheckBox:SetPoint("TOPLEFT", searchIcon, "TOPLEFT", 27, yOffsetCheckbox)
                resultCheckBox.Text:SetText(data.label)
                if not data.label or data.label == "" then
                    resultCheckBox.Text:SetText(data.checkbox.tooltipTitle)
                end
                resultCheckBox:SetChecked(data.checkbox:GetChecked())
                resultCheckBox:SetEnabled(true)
                resultCheckBox:SetAlpha(1)

                -- Link the result checkbox to the main checkbox
                resultCheckBox:SetScript("OnClick", function()
                    data.checkbox:Click()
                    UpdateSearchDropdownStates()
                end)

                applyRightClickScript(resultCheckBox, data.checkbox)

                -- Reapply tooltip
                if data.checkbox.tooltipMainText then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, data.checkbox.tooltipMainText, data.checkbox.tooltipSubText, nil, data.checkbox.tooltipCVarName, nil, data.checkbox.searchCategory)
                elseif data.checkbox.tooltipTitle then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, nil, nil, nil, nil, nil, data.checkbox.searchCategory)
                else
                    CreateTooltipTwo(resultCheckBox, data.label, nil, nil, nil, nil, nil, data.checkbox.searchCategory)
                end

                resultCheckBox:Show()

                -- Move down for the next checkbox
                yOffsetCheckbox = yOffsetCheckbox - 21
            end
        end

        -- Search through sliders
        for _, data in ipairs(sliderList) do
            -- Prepare the label and tooltip text
            local label = string.lower(data.label or "")
            local tooltipTitle = string.lower(data.slider.tooltipTitle or "")
            local tooltipMainText = string.lower(data.slider.tooltipMainText or "")
            local tooltipSubText = string.lower(data.slider.tooltipSubText or "")
            local tooltipCVarName = string.lower(data.slider.tooltipCVarName and data.slider.tooltipCVarName.." CVar" or "")

            -- Check if all query words are found in any of the searchable fields
            local isMatch = matchesQuery(label) or matchesQuery(tooltipTitle) or matchesQuery(tooltipMainText) or matchesQuery(tooltipSubText) or matchesQuery(tooltipCVarName)
            if isMatch then
                sliderMatches = sliderMatches + 1
            end
            if isMatch and sliderCount < MAX_SEARCH_SLIDERS then
                sliderCount = sliderCount + 1

                -- Re-use or create a new slider from the slider pool
                local resultSlider = sliderPool[sliderCount]
                if not resultSlider then
                    resultSlider = CreateFrame("Slider", nil, resultsList, "OptionsSliderTemplate")
                    resultSlider:SetOrientation('HORIZONTAL')
                    resultSlider:SetObeyStepOnDrag(true)
                    resultSlider.Text = resultSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    resultSlider.Text:SetTextColor(1, 0.81, 0, 1)
                    resultSlider.Text:SetFont(fontSmall, 11)
                    resultSlider.Text:SetPoint("TOP", resultSlider, "BOTTOM", 0, -1)
                    resultSlider.Low:SetText(" ")
                    resultSlider.High:SetText(" ")
                    sliderPool[sliderCount] = resultSlider
                end

                -- Format the slider text value
                local function formatSliderValue(value)
                    return value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
                end

                -- Update slider properties and position
                resultSlider:ClearAllPoints()
                resultSlider:SetPoint("TOPLEFT", searchIcon, "TOPLEFT", 277, yOffsetSlider)
                resultSlider:SetScript("OnValueChanged", nil)
                resultSlider:SetMinMaxValues(data.slider:GetMinMaxValues())
                resultSlider:SetValueStep(data.slider:GetValueStep())
                resultSlider:SetValue(data.slider:GetValue())
                resultSlider.Text:SetText(data.label .. ": " .. formatSliderValue(data.slider:GetValue()))

                resultSlider:SetScript("OnValueChanged", function(self, value)
                    data.slider:SetValue(value) -- Trigger the original slider's script
                    resultSlider.Text:SetText(data.label .. ": " .. formatSliderValue(value))
                end)

                -- Tooltip setup for sliders
                if data.slider.tooltipMainText then
                    CreateTooltipTwo(resultSlider, data.slider.tooltipTitle, data.slider.tooltipMainText, data.slider.tooltipSubText, nil, data.slider.tooltipCVarName, nil, data.slider.searchCategory)
                elseif data.slider.tooltipTitle then
                    CreateTooltipTwo(resultSlider, data.slider.tooltipTitle, nil, nil, nil, nil, nil, data.slider.searchCategory)
                else
                    CreateTooltipTwo(resultSlider, data.label, nil, nil, nil, nil, nil, data.slider.searchCategory)
                end

                -- Show the slider and prepare for the next slider
                resultSlider:Show()
                yOffsetSlider = yOffsetSlider - 35
            end
        end

        UpdateSearchDropdownStates()

        local totalMatches = checkboxMatches + sliderMatches + dropdownMatches
        local shown = checkboxCount + sliderCount + dropdownCount
        if shown < totalMatches then
            cappedText:SetFormattedText(L["Search_Results_Capped"], shown, totalMatches)
            cappedText:Show()
        end
    end

    searchBox:SetScript("OnTextChanged", function(self)
        local query = self:GetText()
        if #query > 0 then
            SettingsPanelSearchIcon:SetVertexColor(1, 1, 1)
            SettingsPanel.SearchBox.Instructions:SetAlpha(0)
            searchFrame:Show()
            if SettingsPanel.currentLayout and SettingsPanel.currentLayout.frame then
                SettingsPanel.currentLayout.frame:Hide()
            end
        else
            SettingsPanelSearchIcon:SetVertexColor(0.6, 0.6, 0.6)
            SettingsPanel.SearchBox.Instructions:SetAlpha(1)
            searchFrame:Hide()
            if SettingsPanel.currentLayout and SettingsPanel.currentLayout.frame then
                SettingsPanel.currentLayout.frame:Show()
            end
        end
        if #query >= 1 then
            SearchElements(query)
        else
            SearchElements("")
        end

        if not searchBox.hookedSettings then
            SettingsPanel:HookScript("OnHide", function()
                SettingsPanelSearchIcon:SetVertexColor(0.6, 0.6, 0.6)
                SettingsPanel.SearchBox.Instructions:SetAlpha(1)
                searchFrame:Hide()
                searchBox:Hide()
                if SettingsPanel.currentLayout and SettingsPanel.currentLayout.frame then
                    searchBox:SetText("")
                    SettingsPanel.currentLayout.frame:Hide()
                end
            end)
            searchBox.hookedSettings = true
        end
    end)

    hooksecurefunc(SettingsPanel, "DisplayLayout", function()
        if SettingsPanel.currentLayout.frame and SettingsPanel.currentLayout.frame.name == "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a" or
        (SettingsPanel.currentLayout.frame and SettingsPanel.currentLayout.frame.parent == "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a") then
            SettingsPanel.SearchBox.Instructions:SetText(L["Search_In_BBP"])
            searchBox:Show()
            searchBox:SetText("")
            searchFrame:Hide()
            searchFrame:ClearAllPoints()
            searchFrame:SetPoint("TOPLEFT", SettingsPanel.currentLayout.frame, "TOPLEFT")
            searchFrame:SetPoint("BOTTOMRIGHT", SettingsPanel.currentLayout.frame, "BOTTOMRIGHT")
            if not SettingsPanel.currentLayout.frame:IsShown() then
                SettingsPanel.currentLayout.frame:Show()
            end
        else
            if SettingsPanel.SearchBox.Instructions:GetText() == L["Search_In_BBP"] then
                SettingsPanel.SearchBox.Instructions:SetText(SEARCH)
            end
            searchBox:Hide()
            searchFrame:Hide()
        end
    end)
end
------------------------------------------------------------
-- GUI Panels
------------------------------------------------------------
local function guiProfiles()
    local parent = SettingsPanel
    local frame = CreateFrame("Frame", nil, BetterBlizzPlates, "SettingsFrameTemplate")
    frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.titleText:SetPoint("TOP", frame, "TOP", 1, -4)
    frame.titleText:SetText("|A:gmchat-icon-blizz:16:16|a BBP")

    frame.descriptionText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.descriptionText:SetPoint("TOP", frame, "TOP", 2, -25)
    frame.descriptionText:SetText(L["Profiles_For_BetterBlizzPlates_Colon"])
    frame.descriptionText:SetWidth(100)

    frame.coreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.coreText:SetPoint("TOP", frame.descriptionText, "BOTTOM", 0, -3)
    frame.coreText:SetText(L["Profile_Core"])

    frame.streamerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.streamerText:SetPoint("TOP", frame.coreText, "BOTTOM", 0, -128)
    frame.streamerText:SetText(L["Profile_Streamers"])

    frame.infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.infoText:SetPoint("BOTTOM", frame, "BOTTOM", 2, 45)
    frame.infoText:SetText(L["Profile_Info_Message"])
    frame.infoText:SetWidth(135)

    frame:SetSize(130, parent:GetHeight())

    local streamerCount = 0
    for _, profile in ipairs(BBP.ProfileData) do
        if not profile.core then
            streamerCount = streamerCount + 1
        end
    end
    if streamerCount >= 20 then
        frame.twoColumn = true
        frame.titleText:SetText("|A:gmchat-icon-blizz:16:16|a BetterBlizzPlates")
        frame.descriptionText:SetFontObject("GameFontNormal")
        frame.descriptionText:SetText(L["Profiles_For_BetterBlizzPlates_Colon_2"])
        frame.descriptionText:SetWidth(145)
        frame.coreText:SetFontObject("GameFontNormalLarge")
        frame.coreText:SetPoint("TOP", frame.descriptionText, "BOTTOM", 0, -10)
        frame.streamerText:SetFontObject("GameFontNormalLarge")
        frame.infoText:SetWidth(135)
        frame:SetWidth(165)
    end
    frame:SetPoint("TOPRIGHT", parent, "TOPLEFT", 7, 0)
    frame:SetFrameStrata("BACKGROUND")
    frame.ClosePanelButton:SetAlpha(0)
    frame.ClosePanelButton:HookScript("OnEnter", function(self)
        self:SetAlpha(1)
    end)
    frame.ClosePanelButton:HookScript("OnLeave", function(self)
        self:SetAlpha(0)
    end)

    local function CopyNineSliceColors(fromFrame, toFrame)
        if not (fromFrame and toFrame and fromFrame.NineSlice and toFrame.NineSlice) then
            return
        end

        local parts = {
            "TopLeftCorner", "TopRightCorner",
            "BottomLeftCorner", "BottomRightCorner",
            "TopEdge", "BottomEdge",
            "LeftEdge", "RightEdge",
            "Center",
        }

        for _, name in ipairs(parts) do
            local src = fromFrame.NineSlice[name]
            local dst = toFrame.NineSlice[name]
            if src and dst and src.GetVertexColor and dst.SetVertexColor then
                local r, g, b, a = src:GetVertexColor()
                dst:SetVertexColor(r, g, b, a)

                if src.IsDesaturated and dst.SetDesaturated then
                    dst:SetDesaturated(src:IsDesaturated())
                end
            end
        end
    end

    CopyNineSliceColors(SettingsPanel, frame)

    local plusButton = CreateFrame("Button", nil, BetterBlizzPlates)
    plusButton:SetSize(frame.ClosePanelButton:GetSize())
    plusButton:SetPoint("TOPRIGHT", parent, "TOPLEFT", 7, 0)
    plusButton:SetNormalAtlas("128-RedButton-Plus")
    plusButton:SetHighlightAtlas("128-RedButton-Plus", "ADD")
    plusButton:SetAlpha(0)
    plusButton:HookScript("OnEnter", function(self)
        self:SetAlpha(1)
    end)
    plusButton:HookScript("OnLeave", function(self)
        self:SetAlpha(0)
    end)
    plusButton:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.profilesPanelClosed = false
        frame:Show()
        self:Hide()
    end)
    frame.PlusButton = plusButton

    frame.ClosePanelButton:HookScript("OnClick", function()
        BetterBlizzPlatesDB.profilesPanelClosed = true
        plusButton:Show()
    end)

    if BetterBlizzPlatesDB.profilesPanelClosed then
        frame:Hide()
    else
        plusButton:Hide()
    end

    BetterBlizzPlates.profilesFrame = frame
    return frame
end

local function guiGeneralTab()
    ----------------------
    -- Main panel:
    ----------------------
    local mainGuiAnchor = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")
    CreateTitle(BetterBlizzPlates)

    local profilesFrame = guiProfiles()

    CreateSearchFrame()

    if BetterBlizzPlates.titleText then
        BetterBlizzPlates.titleText:Hide()
        BetterBlizzPlates.loadGUI:Hide()
    end

    local midnightBeta = BetterBlizzPlates:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    midnightBeta:SetPoint("BOTTOM", SettingsPanel, "TOP", 0, 0)
    midnightBeta:SetText("|T136221:12:12|t |cffcc66ff" .. L["BetterBlizzPlates_EARLY_BETA_Beware_Of_Bugs_WIP_2"])
    midnightBeta:SetFont(STANDARD_TEXT_FONT, 24, "THINOUTLINE")
    midnightBeta:Hide()
    BetterBlizzPlates:HookScript("OnShow", function()
        midnightBeta:Show()
    end)
    BetterBlizzPlates:HookScript("OnHide", function()
        midnightBeta:Hide()
    end)


    local bgImg = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local newSearch = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    newSearch:SetAtlas("NewCharacter-Horde", true)
    newSearch:SetPoint("BOTTOM", BetterBlizzPlates, "TOP", -70, 2)
    CreateTooltipTwo(newSearch, L["Search"] .. " |A:shop-games-magnifyingglass:17:17|a", L["Tooltip_Search_Desc"])

    local newSearchPoint = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    newSearchPoint:SetAtlas("auctionhouse-icon-buyallarrow", true)
    newSearchPoint:SetPoint("LEFT", newSearch, "RIGHT", -25, 0)
    newSearchPoint:SetRotation(math.pi / 2)

    ----------------------
    -- General:
    ----------------------
    -- "General:" text
    local settingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 30)
    settingsText:SetText(L["General_Settings"])
    settingsText:SetFont(fontLarge, 16)
    settingsText:SetTextColor(1,1,1)
    local generalSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)


    local healthNumbers = CreateCheckbox("healthNumbers", L["Health_Numbers"], BetterBlizzPlates, nil, BBP.ToggleHealthNumbers)
    CreateTooltipTwo(healthNumbers, L["Show_Health_Numbers"], L["Tooltip_Show_Health_Numbers_Desc"])

    local smallPetsInPvP = CreateCheckbox("smallPetsInPvP", L["Small_Pets"], BetterBlizzPlates)
    smallPetsInPvP:SetPoint("LEFT", healthNumbers.text, "RIGHT", 0, 0)
    CreateTooltipTwo(smallPetsInPvP, L["Small_Pets_In_PvP"], L["Tooltip_Small_Pets_In_PvP_Desc"])

    local smallPetsOptionsFrame
    local function OpenSmallPetsOptionsWindow()
        if not smallPetsOptionsFrame then
            smallPetsOptionsFrame = CreateFrame("Frame", "BBPSmallPetsOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            smallPetsOptionsFrame:SetSize(180, 240)
            smallPetsOptionsFrame:SetPoint("CENTER")
            smallPetsOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            smallPetsOptionsFrame:SetFrameLevel(550)
            smallPetsOptionsFrame:SetIgnoreParentAlpha(true)
            smallPetsOptionsFrame:SetTitle(L["Small_Pets_Options"])
            smallPetsOptionsFrame:EnableMouse(true)
            smallPetsOptionsFrame:SetMovable(true)
            smallPetsOptionsFrame:SetClampedToScreen(true)
            smallPetsOptionsFrame:RegisterForDrag("LeftButton")
            smallPetsOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            smallPetsOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            smallPetsOptionsFrame.closeButton = CreateFrame("Button", nil, smallPetsOptionsFrame, "UIPanelCloseButton")
            smallPetsOptionsFrame.closeButton:SetFrameLevel((smallPetsOptionsFrame.TitleContainer or smallPetsOptionsFrame):GetFrameLevel() + 10)
            smallPetsOptionsFrame.closeButton:SetPoint("TOPRIGHT", smallPetsOptionsFrame, "TOPRIGHT", 0, 0)
            smallPetsOptionsFrame.closeButton:SetScript("OnClick", function()
                smallPetsOptionsFrame:Hide()
            end)

            smallPetsOptionsFrame.bg = smallPetsOptionsFrame:CreateTexture(nil, "BACKGROUND")
            smallPetsOptionsFrame.bg:SetPoint("TOPLEFT", smallPetsOptionsFrame, "TOPLEFT", 7, -3)
            smallPetsOptionsFrame.bg:SetPoint("BOTTOMRIGHT", smallPetsOptionsFrame, "BOTTOMRIGHT", -3, 3)
            smallPetsOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local smallPetsAllNPCs = CreateCheckbox("smallPetsInPvPAllNPCs", L["Shrink_All_NPCs_In_PvP"], smallPetsOptionsFrame)
            smallPetsAllNPCs:SetPoint("TOPLEFT", smallPetsOptionsFrame, "TOPLEFT", 10, -26)
            CreateTooltipTwo(smallPetsAllNPCs, L["Shrink_All_NPCs_In_PvP"], L["Tooltip_Shrink_All_NPCs_In_PvP_Desc"])

            local smallPetsIgnoreTotems = CreateCheckbox("smallPetsInPvPIgnoreTotems", L["Ignore_Totems"], smallPetsOptionsFrame)
            smallPetsIgnoreTotems:SetPoint("TOPLEFT", smallPetsAllNPCs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
            CreateTooltipTwo(smallPetsIgnoreTotems, L["Ignore_Totems"], L["Tooltip_Ignore_Totems_Desc"], "|cFFFFD100" .. L["Tooltip_Ignore_Totems_SubText_2"] .. "|r")

            smallPetsAllNPCs:HookScript("OnClick", function(self)
                if self:GetChecked() then
                    BetterBlizzPlatesDB.smallPetsInPvPIgnoreTotems = false
                    smallPetsIgnoreTotems:SetChecked(false)
                end
            end)
            smallPetsIgnoreTotems:HookScript("OnClick", function(self)
                if self:GetChecked() then
                    BetterBlizzPlatesDB.smallPetsInPvPAllNPCs = false
                    smallPetsAllNPCs:SetChecked(false)
                end
            end)

            local smallPetsWidthSlider = CreateSlider(smallPetsOptionsFrame, L["Pets_Width"], 2, 40, 1, "smallPetsWidth", nil, 150)
            smallPetsWidthSlider:SetPoint("TOPLEFT", smallPetsIgnoreTotems, "BOTTOMLEFT", 2, -10)
            CreateTooltipTwo(smallPetsWidthSlider, L["Pets_Width"], L["Tooltip_Pets_Width_Desc"], L["Tooltip_Pets_Width_SubText"])

            local smallPetsSmallerWidthSlider = CreateSlider(smallPetsOptionsFrame, L["Smaller_Pets_Width"], 2, 40, 1, "smallPetsSmallerWidth", nil, 150)
            smallPetsSmallerWidthSlider:SetPoint("TOPLEFT", smallPetsWidthSlider, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(smallPetsSmallerWidthSlider, L["Smaller_Pets_Width"], L["Tooltip_Smaller_Pets_Width_Desc"], L["Tooltip_Pets_Width_SubText"])

            local smallPetsInPvPHeight = CreateCheckbox("smallPetsInPvPHeight", L["Also_Adjust_Height"], smallPetsOptionsFrame)
            smallPetsInPvPHeight:SetPoint("TOPLEFT", smallPetsSmallerWidthSlider, "BOTTOMLEFT", -2, -10)
            CreateTooltipTwo(smallPetsInPvPHeight, L["Also_Adjust_Height"], L["Tooltip_Also_Adjust_Height_Desc"])

            local smallPetsHeightSlider = CreateSlider(smallPetsOptionsFrame, L["Pets_Height"], 1, 35, 0.1, "smallPetsHeight", nil, 150)
            smallPetsHeightSlider:SetPoint("TOPLEFT", smallPetsInPvPHeight, "BOTTOMLEFT", 2, -10)
            CreateTooltipTwo(smallPetsHeightSlider, L["Pets_Height"], L["Tooltip_Pets_Height_Desc"], L["Tooltip_Pets_Width_SubText"])

            local smallPetsSmallerHeightSlider = CreateSlider(smallPetsOptionsFrame, L["Smaller_Pets_Height"], 1, 35, 0.1, "smallPetsSmallerHeight", nil, 150)
            smallPetsSmallerHeightSlider:SetPoint("TOPLEFT", smallPetsHeightSlider, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(smallPetsSmallerHeightSlider, L["Smaller_Pets_Height"], L["Tooltip_Smaller_Pets_Height_Desc"], L["Tooltip_Pets_Width_SubText"])

            if not BetterBlizzPlatesDB.smallPetsInPvPHeight then
                DisableElement(smallPetsHeightSlider)
                DisableElement(smallPetsSmallerHeightSlider)
            end

            smallPetsInPvPHeight:HookScript("OnClick", function(self)
                if self:GetChecked() then
                    EnableElement(smallPetsHeightSlider)
                    EnableElement(smallPetsSmallerHeightSlider)
                else
                    DisableElement(smallPetsHeightSlider)
                    DisableElement(smallPetsSmallerHeightSlider)
                end
            end)

            smallPetsOptionsFrame:Show()
        else
            smallPetsOptionsFrame:SetShown(not smallPetsOptionsFrame:IsShown())
        end
    end

    smallPetsInPvP:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            OpenSmallPetsOptionsWindow()
        end
    end)

    local hideOptionsRow = CreateFrame("Frame", nil, BetterBlizzPlates)
    hideOptionsRow:SetSize(24, 24)

    local hideOptions = CreateMultiSelectDropdown(L["Hide_Options"], BetterBlizzPlates, {
        { key = "removeRealmNames", label = L["Hide_2nd_Name"], tooltip = L["Tooltip_Hide_The_2nd_Name_Surname_From"] },
        { key = "hideTargetHighlight", label = L["Hide_Target_Glow"], tooltip = L["Tooltip_Hide_Target_Highlight_Desc"] },
        { key = "hideTargetBorder", label = L["Hide_Target_Border"], tooltip = L["Tooltip_Hide_The_White_Border_Around_Your"] },
        { key = "hideNameplateAuraTooltip", label = L["Hide_Pet_Aura_Tooltip"], tooltip = L["Tooltip_Hide_Nameplate_Aura_Tooltips"] },
    }, 150, function(key)
        if key == "hideNameplateAuraTooltip" then
            BBP.HideNameplateAuraTooltip()
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)
    hideOptions:SetPoint("LEFT", hideOptionsRow, "LEFT", 4, 0)
    hideOptions:SetScale(0.7)
    CreateTooltipTwo(hideOptions, L["Hide_Options"], L["Tooltip_Hide_Options_Desc"])

    local classicNameplates = CreateCheckbox("classicNameplates", L["Classic_Nameplates"], BetterBlizzPlates)
    classicNameplates:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(classicNameplates, L["Classic_Nameplates"], L["Tooltip_Classic_Nameplates_Desc"])
    classicNameplates:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.ShowPopup("BBP_CLASSIC_NAMEPLATES_SETUP")
        else
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local levelTextOptionsFrame
    local function OpenLevelTextOptionsWindow()
        if not levelTextOptionsFrame then
            levelTextOptionsFrame = CreateFrame("Frame", "BBPLevelTextOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            levelTextOptionsFrame:SetSize(200, 270)
            levelTextOptionsFrame:SetPoint("CENTER")
            levelTextOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            levelTextOptionsFrame:SetFrameLevel(550)
            levelTextOptionsFrame:SetIgnoreParentAlpha(true)
            levelTextOptionsFrame:SetTitle(L["Level_Text_Options"])
            levelTextOptionsFrame:EnableMouse(true)
            levelTextOptionsFrame:SetMovable(true)
            levelTextOptionsFrame:SetClampedToScreen(true)
            levelTextOptionsFrame:RegisterForDrag("LeftButton")
            levelTextOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            levelTextOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            levelTextOptionsFrame.closeButton = CreateFrame("Button", nil, levelTextOptionsFrame, "UIPanelCloseButton")
            levelTextOptionsFrame.closeButton:SetFrameLevel((levelTextOptionsFrame.TitleContainer or levelTextOptionsFrame):GetFrameLevel() + 10)
            levelTextOptionsFrame.closeButton:SetPoint("TOPRIGHT", levelTextOptionsFrame, "TOPRIGHT", 0, 0)
            levelTextOptionsFrame.closeButton:SetScript("OnClick", function()
                levelTextOptionsFrame:Hide()
            end)

            levelTextOptionsFrame.bg = levelTextOptionsFrame:CreateTexture(nil, "BACKGROUND")
            levelTextOptionsFrame.bg:SetPoint("TOPLEFT", levelTextOptionsFrame, "TOPLEFT", 7, -3)
            levelTextOptionsFrame.bg:SetPoint("BOTTOMRIGHT", levelTextOptionsFrame, "BOTTOMRIGHT", -3, 3)
            levelTextOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local levelTextAnchor = CreateAnchorDropdown(
                "BBPLevelTextAnchorDropdown",
                levelTextOptionsFrame,
                "LEFT",
                "levelTextAnchor",
                BBP.UpdateAllLevelOverlays,
                { anchorFrame = levelTextOptionsFrame, x = -2, y = -50, label = L["Anchor"] },
                65
            )
            CreateTooltipTwo(levelTextAnchor, L["Level_Text_Anchor"], L["Tooltip_Level_Text_Anchor_Desc"])

            local levelTextRelativeAnchor = CreateAnchorDropdown(
                "BBPLevelTextRelativeAnchorDropdown",
                levelTextOptionsFrame,
                "RIGHT",
                "levelTextRelativeAnchor",
                BBP.UpdateAllLevelOverlays,
                { anchorFrame = levelTextOptionsFrame, x = 88, y = -50, label = L["Healthbar"] },
                65
            )
            CreateTooltipTwo(levelTextRelativeAnchor, L["Healthbar_Anchor"], L["Tooltip_Healthbar_Anchor_Desc"])

            local levelTextSize = CreateSlider(levelTextOptionsFrame, L["Size"], 4, 24, 0.5, "levelTextSize", nil, 150)
            levelTextSize:SetPoint("TOPLEFT", levelTextOptionsFrame, "TOPLEFT", 24, -105)
            CreateTooltipTwo(levelTextSize, L["Level_Text_Size"], L["Tooltip_Level_Text_Size_Desc"], L["Tooltip_Pets_Width_SubText"])

            local levelTextXPos = CreateSlider(levelTextOptionsFrame, L["X_Offset"], -50, 50, 0.5, "levelTextXPos", nil, 150)
            levelTextXPos:SetPoint("TOPLEFT", levelTextSize, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(levelTextXPos, L["Level_Text_X_Offset"], L["Tooltip_Level_Text_X_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

            local levelTextYPos = CreateSlider(levelTextOptionsFrame, L["Y_Offset"], -50, 50, 0.5, "levelTextYPos", nil, 150)
            levelTextYPos:SetPoint("TOPLEFT", levelTextXPos, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(levelTextYPos, L["Level_Text_Y_Offset"], L["Tooltip_Level_Text_Y_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

            local levelTextReset = CreateFrame("Button", nil, levelTextOptionsFrame, "UIPanelButtonTemplate")
            levelTextReset:SetText(L["Reset"])
            levelTextReset:SetSize(80, 22)
            levelTextReset:SetPoint("BOTTOM", levelTextOptionsFrame, "BOTTOM", 2, 12)
            levelTextReset:SetScript("OnClick", function()
                BetterBlizzPlatesDB.levelTextAnchor = "LEFT"
                BetterBlizzPlatesDB.levelTextRelativeAnchor = "RIGHT"
                levelTextAnchor:GenerateMenu()
                levelTextRelativeAnchor:GenerateMenu()
                levelTextSize:SetValue(10)
                levelTextXPos:SetValue(0)
                levelTextYPos:SetValue(0)
                BBP.UpdateAllLevelOverlays()
            end)
            CreateTooltipTwo(levelTextReset, L["Reset"], L["Tooltip_Reset_Desc"])

            levelTextOptionsFrame:Show()
        else
            levelTextOptionsFrame:SetShown(not levelTextOptionsFrame:IsShown())
        end
    end

    local levelEliteIconOptionsFrame
    local function OpenLevelEliteIconOptionsWindow()
        if not levelEliteIconOptionsFrame then
            levelEliteIconOptionsFrame = CreateFrame("Frame", "BBPLevelEliteIconOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            levelEliteIconOptionsFrame:SetSize(210, 320)
            levelEliteIconOptionsFrame:SetPoint("CENTER")
            levelEliteIconOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            levelEliteIconOptionsFrame:SetFrameLevel(550)
            levelEliteIconOptionsFrame:SetIgnoreParentAlpha(true)
            levelEliteIconOptionsFrame:SetTitle(L["Elite_Icon_Options"])
            levelEliteIconOptionsFrame:EnableMouse(true)
            levelEliteIconOptionsFrame:SetMovable(true)
            levelEliteIconOptionsFrame:SetClampedToScreen(true)
            levelEliteIconOptionsFrame:RegisterForDrag("LeftButton")
            levelEliteIconOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            levelEliteIconOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            levelEliteIconOptionsFrame.closeButton = CreateFrame("Button", nil, levelEliteIconOptionsFrame, "UIPanelCloseButton")
            levelEliteIconOptionsFrame.closeButton:SetFrameLevel((levelEliteIconOptionsFrame.TitleContainer or levelEliteIconOptionsFrame):GetFrameLevel() + 10)
            levelEliteIconOptionsFrame.closeButton:SetPoint("TOPRIGHT", levelEliteIconOptionsFrame, "TOPRIGHT", 0, 0)
            levelEliteIconOptionsFrame.closeButton:SetScript("OnClick", function()
                levelEliteIconOptionsFrame:Hide()
            end)

            levelEliteIconOptionsFrame.bg = levelEliteIconOptionsFrame:CreateTexture(nil, "BACKGROUND")
            levelEliteIconOptionsFrame.bg:SetPoint("TOPLEFT", levelEliteIconOptionsFrame, "TOPLEFT", 7, -3)
            levelEliteIconOptionsFrame.bg:SetPoint("BOTTOMRIGHT", levelEliteIconOptionsFrame, "BOTTOMRIGHT", -3, 3)
            levelEliteIconOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local levelFrameEliteIcon = CreateCheckbox("levelFrameEliteIcon", L["Show_Elite_Icon_Around_Level"], levelEliteIconOptionsFrame)
            levelFrameEliteIcon:SetPoint("TOPLEFT", levelEliteIconOptionsFrame, "TOPLEFT", 10, -26)
            CreateTooltipTwo(levelFrameEliteIcon, L["Show_Elite_Icon_Around_Level"], L["Tooltip_Show_Elite_Icon_Around_Level_Desc"], L["Tooltip_Show_Elite_Icon_Around_Level_SubText"])

            local rangeNote = L["Tooltip_Pets_Width_SubText"]
            local function CreateEliteIconSliders(prefix, widthText, heightText)
                local sliders = {}
                sliders.width = CreateSlider(levelEliteIconOptionsFrame, L["Width"], -30, 40, 1, prefix .. "Width", nil, 150)
                sliders.width:SetPoint("TOPLEFT", levelEliteIconOptionsFrame, "TOPLEFT", 14, -72)
                CreateTooltipTwo(sliders.width, L["Elite_Icon_Width"], widthText, rangeNote)

                sliders.height = CreateSlider(levelEliteIconOptionsFrame, L["Height"], -30, 40, 1, prefix .. "Height", nil, 150)
                sliders.height:SetPoint("TOPLEFT", sliders.width, "BOTTOMLEFT", 0, -17)
                CreateTooltipTwo(sliders.height, L["Elite_Icon_Height"], heightText, rangeNote)

                sliders.x = CreateSlider(levelEliteIconOptionsFrame, L["X_Offset"], -30, 30, 0.5, prefix .. "XPos", nil, 150)
                sliders.x:SetPoint("TOPLEFT", sliders.height, "BOTTOMLEFT", 0, -17)
                CreateTooltipTwo(sliders.x, L["Elite_Icon_X_Offset"], L["Tooltip_Elite_Icon_X_Offset_Desc"], rangeNote)

                sliders.y = CreateSlider(levelEliteIconOptionsFrame, L["Y_Offset"], -30, 30, 0.5, prefix .. "YPos", nil, 150)
                sliders.y:SetPoint("TOPLEFT", sliders.x, "BOTTOMLEFT", 0, -17)
                CreateTooltipTwo(sliders.y, L["Elite_Icon_Y_Offset"], L["Tooltip_Elite_Icon_Y_Offset_Desc"], rangeNote)
                return sliders
            end

            local ringSliders = CreateEliteIconSliders("levelEliteIcon", L["Tooltip_Ring_Elite_Icon_Width"], L["Tooltip_Ring_Elite_Icon_Height"])
            local normalSliders = CreateEliteIconSliders("normalEliteIcon", L["Tooltip_Normal_Elite_Icon_Width"], L["Tooltip_Normal_Elite_Icon_Height"])

            local ringOnlyNote = L["Tooltip_Only_For_When_Elite_Dragon_Is"]

            local levelEliteIconLeftSide = CreateCheckbox("levelEliteIconLeftSide", L["Attach_Elite_Icon_Left_Side"], levelEliteIconOptionsFrame, nil, BBP.UpdateAllLevelOverlays)
            levelEliteIconLeftSide:SetPoint("TOPLEFT", ringSliders.y, "BOTTOMLEFT", -4, -12)
            levelEliteIconLeftSide:SetMotionScriptsWhileDisabled(true)
            CreateTooltipTwo(levelEliteIconLeftSide, L["Attach_Elite_Icon_Left_Side"], L["Tooltip_Attach_Elite_Icon_Left_Side_Desc"], ringOnlyNote)

            local levelEliteIconRingTexture = CreateCheckbox("levelEliteIconRingTexture", L["Ring_Texture"], levelEliteIconOptionsFrame, nil, BBP.UpdateAllLevelOverlays)
            levelEliteIconRingTexture:SetPoint("TOPLEFT", levelEliteIconLeftSide, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
            levelEliteIconRingTexture:SetMotionScriptsWhileDisabled(true)
            CreateTooltipTwo(levelEliteIconRingTexture, L["Ring_Texture"], L["Tooltip_Ring_Texture_Desc"], ringOnlyNote)

            local function UpdateEliteIconMode()
                local aroundLevel = BetterBlizzPlatesDB.levelFrameEliteIcon and true or false
                for _, slider in pairs(ringSliders) do slider:SetShown(aroundLevel) end
                for _, slider in pairs(normalSliders) do slider:SetShown(not aroundLevel) end
                for _, box in ipairs({ levelEliteIconLeftSide, levelEliteIconRingTexture }) do
                    box:SetEnabled(aroundLevel)
                    box:SetAlpha(aroundLevel and 1 or 0.5)
                end
                levelEliteIconOptionsFrame:SetTitle(aroundLevel and L["Elite_Icon_Around_Level"] or L["Elite_Icon_Options"])
            end
            levelEliteIconOptionsFrame.UpdateEliteIconMode = UpdateEliteIconMode
            levelEliteIconOptionsFrame:HookScript("OnShow", UpdateEliteIconMode)
            levelFrameEliteIcon:HookScript("OnClick", function()
                UpdateEliteIconMode()
                BBP.RefreshAllNameplates()
                BBP.UpdateAllLevelOverlays()
                BBP.UpdateAllEliteIndicators()
            end)
            UpdateEliteIconMode()

            local levelEliteIconReset = CreateFrame("Button", nil, levelEliteIconOptionsFrame, "UIPanelButtonTemplate")
            levelEliteIconReset:SetText(L["Reset"])
            levelEliteIconReset:SetSize(80, 22)
            levelEliteIconReset:SetPoint("BOTTOM", levelEliteIconOptionsFrame, "BOTTOM", 2, 12)
            levelEliteIconReset:SetScript("OnClick", function()
                local aroundLevel = BetterBlizzPlatesDB.levelFrameEliteIcon
                local sliders = aroundLevel and ringSliders or normalSliders
                sliders.width:SetValue(0)
                sliders.height:SetValue(0)
                sliders.x:SetValue(0)
                sliders.y:SetValue(0)
                if aroundLevel then
                    if levelEliteIconLeftSide:GetChecked() then
                        levelEliteIconLeftSide:Click()
                    end
                    if levelEliteIconRingTexture:GetChecked() then
                        levelEliteIconRingTexture:Click()
                    end
                end
            end)
            CreateTooltipTwo(levelEliteIconReset, L["Reset"], L["Tooltip_Reset_Desc"])

            levelEliteIconOptionsFrame:Show()
        else
            levelEliteIconOptionsFrame:SetShown(not levelEliteIconOptionsFrame:IsShown())
        end
    end

    local levelOptions = CreateMultiSelectDropdown(L["Level_Options"], BetterBlizzPlates, {
        { key = "hideLevelFrame", label = L["Hide_Level"], tooltip = L["Tooltip_Hide_Level_Desc"] },
        { key = "hideLevelOnFriendly", label = L["Hide_Level_On_Friendly"], tooltip = L["Tooltip_Hide_The_Level_Display_On_Friendly"] },
        { key = "hideLevelFrameBackground", label = L["Hide_Level_Background"], tooltip = L["Tooltip_Hide_The_Level_Background_Texture_And"], tooltipNote = function() return BetterBlizzPlatesDB.classicRetailNameplates and L["Tooltip_Always_On_With_Pre_Midnight_Look"] or nil end, isForced = function() return BetterBlizzPlatesDB.classicRetailNameplates end },
        { key = "moveLevelText", label = L["Move_Level"], tooltipTitle = L["Move_And_Size_Level_Text"], tooltip = L["Tooltip_Move_And_Size_The_Level_Text"], tooltipNote = L["Tooltip_Needs_Hide_Level_Background_With_Classic"], onRightClick = OpenLevelTextOptionsWindow, isEnabled = BBP.CanMoveLevelText },
        { key = "eliteDragonTweaks", label = L["Elite_Dragon_Tweaks"], tooltip = L["Tooltip_Size_Position_And_Look_Of_The"], onRightClick = OpenLevelEliteIconOptionsWindow },
    }, 150, function(key)
        if key ~= "eliteDragonTweaks" then return end
        BBP.UpdateAllLevelOverlays()
        BBP.UpdateAllEliteIndicators()
    end)
    levelOptions:SetPoint("LEFT", hideOptions, "RIGHT", 8, 0)
    levelOptions:SetScale(0.7)
    CreateTooltipTwo(levelOptions, L["Level_Options"], L["Tooltip_Level_Options_Desc"])


    classicNameplates:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.hideLevelFrame = false
            BetterBlizzPlatesDB.classicRetailNameplates = nil
        else
            BetterBlizzPlatesDB.hideLevelFrame = true
        end
        BBP.RefreshAllNameplates()
    end)

    local classicRetailNameplates = CreateCheckbox("classicRetailNameplates", L["Use_The_Pre_Midnight_Nameplate_Look"], BetterBlizzPlates)
    classicRetailNameplates:SetPoint("TOPLEFT", classicNameplates, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicRetailNameplates, L["Pre_Midnight_Nameplates"], L["Tooltip_Pre_Midnight_Nameplates_Desc"])
    classicRetailNameplates:HookScript("OnClick", function(self)
        if self:GetChecked() then
            --
            BetterBlizzPlatesDB.useFakeName = true
            BetterBlizzPlatesDB.changeHealthbarHeight = true
            BetterBlizzPlatesDB.classicNameplates = false
            BetterBlizzPlatesDB.hpHeightEnemy = 4 * 2.7
            BetterBlizzPlatesDB.hpHeightFriendly = 4 * 2.7
            BetterBlizzPlatesDB.hpHeightSelf = 4 * 2.7
            BetterBlizzPlatesDB.hpHeightSelfMana = 4 * 2.7
            BetterBlizzPlatesDB.disableDefaultBlizzardOutline = true
            if not InCombatLockdown() then
                C_CVar.SetCVar("nameplateStyle", "2")
            end
            -- BetterBlizzPlatesDB.fakeNameXPos = 0
            -- BetterBlizzPlatesDB.fakeNameYPos = 0
            -- BetterBlizzPlatesDB.fakeNameFriendlyXPos = 0
            -- BetterBlizzPlatesDB.fakeNameFriendlyYPos = 0
        else
            BetterBlizzPlatesDB.useFakeName = false
            BetterBlizzPlatesDB.changeHealthbarHeight = false
            BetterBlizzPlatesDB.disableDefaultBlizzardOutline = nil
        end
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local nameplateMinScale = CreateSlider(BetterBlizzPlates, L["Nameplate_Size"], 0.5, 2, 0.01, "nameplateMinScale")
    healthNumbers:SetPoint("TOPLEFT", classicRetailNameplates, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local centerNameplateHealthBar = CreateCheckbox("centerNameplateHealthBar", L["Center_Nameplate_Healthbar"], BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    centerNameplateHealthBar:SetPoint("TOPLEFT", healthNumbers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(centerNameplateHealthBar, L["Center_Nameplate_Healthbar"], L["Tooltip_Center_Nameplate_Healthbar_Desc"], L["Tooltip_Center_Nameplate_Healthbar_SubText"])

    hideOptionsRow:SetPoint("TOPLEFT", centerNameplateHealthBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    nameplateMinScale:SetPoint("TOPLEFT", hideOptionsRow, "BOTTOMLEFT", 12, -15)
    CreateTooltipTwo(nameplateMinScale, L["Nameplate_Size"], L["Tooltip_Nameplate_Size_Desc"], nil, nil, "nameplateMinScale", "nameplateMaxScale")

    local nameplateMinScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateMinScaleResetButton:SetText(L["Default"])
    nameplateMinScaleResetButton:SetWidth(60)
    nameplateMinScaleResetButton:SetPoint("LEFT", nameplateMinScale, "RIGHT", 10, 0)
    nameplateMinScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateMinScale, "nameplateScale")
    end)

    local nameplateSelectedScale = CreateSlider(BetterBlizzPlates, L["Target_Nameplate_Size"], 0.5, 3, 0.01, "nameplateSelectedScale")
    nameplateSelectedScale:SetPoint("TOPLEFT", nameplateMinScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateSelectedScale, L["Target_Nameplate_Size"], L["Tooltip_Target_Nameplate_Size_Desc"], nil, nil, "nameplateSelectedScale")

    local nameplateSelectedScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateSelectedScaleResetButton:SetText(L["Default"])
    nameplateSelectedScaleResetButton:SetWidth(60)
    nameplateSelectedScaleResetButton:SetPoint("LEFT", nameplateSelectedScale, "RIGHT", 10, 0)
    nameplateSelectedScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateSelectedScale, "nameplateSelected")
    end)

    local nameplateGeneralHpHeight = CreateSlider(BetterBlizzPlates, L["Nameplate_Height"], 4, 50, 0.5, "nameplateGeneralHpHeight")
    nameplateGeneralHpHeight:SetPoint("TOPLEFT", nameplateSelectedScale, "BOTTOMLEFT", 0, -17)
    if BetterBlizzPlatesDB.changeHealthbarHeight then
        CreateTooltipTwo(nameplateGeneralHpHeight, L["Nameplate_Height"], L["Tooltip_Nameplate_Height_Desc"])
        nameplateGeneralHpHeight:Disable()
        nameplateGeneralHpHeight:SetAlpha(0.5)
    else
        CreateTooltipTwo(nameplateGeneralHpHeight, L["Nameplate_Height"], L["Tooltip_Nameplate_Height_Desc_2"])
    end

    local nameplateGeneralHpHeightResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateGeneralHpHeightResetButton:SetText(L["Default"])
    nameplateGeneralHpHeightResetButton:SetWidth(60)
    nameplateGeneralHpHeightResetButton:SetPoint("LEFT", nameplateGeneralHpHeight, "RIGHT", 10, 0)
    nameplateGeneralHpHeightResetButton:SetScript("OnClick", function()
        local value = (BetterBlizzPlatesDB.classicNameplates or BetterBlizzPlatesDB.classicRetailNameplates) and 12 or 16
        nameplateGeneralHpHeight:SetValue(value)
        BetterBlizzPlatesDB.nameplateGeneralHpHeight = value
    end)
    CreateTooltipTwo(nameplateGeneralHpHeightResetButton, L["Reset_Nameplate_Height"], L["Tooltip_Reset_Nameplate_Height_Desc"], nil, "ANCHOR_TOP")
    ----------------------
    -- Enemy nameplates:
    ----------------------
    local enemyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -191)
    enemyNameplatesText:SetText(L["Enemy_Nameplates"])
    enemyNameplatesText:SetFont(fontLarge, 16)
    enemyNameplatesText:SetTextColor(1,1,1)
    local enemyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon:SetSize(28, 28)
    enemyNameplateIcon:SetPoint("RIGHT", enemyNameplatesText, "LEFT", -3, 0)
    enemyNameplateIcon:SetDesaturated(1)
    enemyNameplateIcon:SetVertexColor(1, 0, 0)

    local enemyClassColorName = CreateCheckbox("enemyClassColorName", L["Class_Color_Name"], BetterBlizzPlates)
    enemyClassColorName:SetPoint("TOPLEFT", enemyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(enemyClassColorName, L["Class_Color_Name"], L["Tooltip_Class_Color_Name_2_Desc"])

    local enemyColorName = CreateCheckbox("enemyColorName", L["Color_Name"], BetterBlizzPlates)
    enemyColorName:SetPoint("LEFT", enemyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyColorName, L["Color_Name"], L["Tooltip_Color_Name_2_Desc"], L["Tooltip_Color_Name_2_SubText"])

    local function UpdateColorSquare(icon, r, g, b)
        if r and g and b then
            icon:SetVertexColor(r, g, b)
        end
    end

    local enemyColorNameIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyColorNameIcon:SetAtlas("newplayertutorial-icon-key")
    enemyColorNameIcon:SetSize(18, 17)
    UpdateColorSquare(enemyColorNameIcon, unpack(BetterBlizzPlatesDB.enemyColorNameRGB or {1, 1, 1}))

    local function OpenColorPicker(colorType, icon)
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB[colorType] or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB[colorType] = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(icon, r, g, b)
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB[colorType] = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(icon, r, g, b)
            end,
        })
    end

    local enemyColorNameButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyColorNameButtonIcon:SetAtlas("newplayertutorial-icon-key")
    enemyColorNameButtonIcon:SetSize(18, 17)
    UpdateColorSquare(enemyColorNameButtonIcon, unpack(BetterBlizzPlatesDB.enemyColorNameRGB or {1, 1, 1}))
    local enemyColorNameButton = CreateFrame("Button", nil, enemyColorName, "UIPanelButtonTemplate")
    enemyColorNameButton:SetText(L["Hostile"])
    enemyColorNameButton:SetPoint("LEFT", enemyColorName.Text, "RIGHT", -1, 0)
    enemyColorNameButton:SetSize(55, 20)
    enemyColorNameButton:SetScript("OnClick", function()
        OpenColorPicker("enemyColorNameRGB", enemyColorNameButtonIcon)
    end)
    CreateTooltipTwo(enemyColorNameButton, L["Hostile_Color"])
    enemyColorNameButtonIcon:SetPoint("LEFT", enemyColorNameButton, "RIGHT", 0, -0.5)

    local enemyNeutralColorNameButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNeutralColorNameButtonIcon:SetAtlas("newplayertutorial-icon-key")
    enemyNeutralColorNameButtonIcon:SetSize(18, 17)
    UpdateColorSquare(enemyNeutralColorNameButtonIcon, unpack(BetterBlizzPlatesDB.enemyNeutralColorNameRGB or {1, 1, 1}))
    local enemyNeutralColorNameButton = CreateFrame("Button", nil, enemyColorName, "UIPanelButtonTemplate")
    enemyNeutralColorNameButton:SetText(L["Neutral"])
    enemyNeutralColorNameButton:SetPoint("LEFT", enemyColorNameButtonIcon, "RIGHT", 0, 0.5)
    enemyNeutralColorNameButton:SetSize(55, 20)
    enemyNeutralColorNameButton:SetScript("OnClick", function()
        OpenColorPicker("enemyNeutralColorNameRGB", enemyNeutralColorNameButtonIcon)
    end)
    CreateTooltipTwo(enemyNeutralColorNameButton, L["Neutral_Color"])
    enemyNeutralColorNameButtonIcon:SetPoint("LEFT", enemyNeutralColorNameButton, "RIGHT", 0, -0.5)

    enemyColorName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            enemyNeutralColorNameButton:Enable()
            enemyNeutralColorNameButton:Show()
            enemyColorNameButton:Enable()
            enemyColorNameButton:Show()
            enemyColorNameButtonIcon:Show()
            enemyNeutralColorNameButtonIcon:Show()
        else
            enemyNeutralColorNameButton:Disable()
            enemyNeutralColorNameButton:Hide()
            enemyColorNameButton:Disable()
            enemyColorNameButton:Hide()
            enemyColorNameButtonIcon:Hide()
            enemyNeutralColorNameButtonIcon:Hide()
        end
    end)
    if not BetterBlizzPlatesDB.enemyColorName then
        enemyNeutralColorNameButton:Disable()
        enemyNeutralColorNameButton:Hide()
        enemyColorNameButton:Hide()
        enemyColorNameButton:Disable()
        enemyColorNameButtonIcon:Hide()
        enemyNeutralColorNameButtonIcon:Hide()
    end

    local nameplateShowClassColor = CreateCheckbox("nameplateShowClassColor", L["Class_Color_Healthbar"], BetterBlizzPlates, true, BBP.ApplyNameplateWidth)
    nameplateShowClassColor:SetPoint("TOPLEFT", enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowClassColor, L["Class_Color_Healthbar"], L["Tooltip_Class_Color_Healthbar_2_Desc"], nil, nil, "nameplateShowClassColor")
    if GetCVar("nameplateShowClassColor") == "1" and BetterBlizzPlatesDB.nameplateShowClassColor == nil then
        BetterBlizzPlatesDB.nameplateShowClassColor = true
        nameplateShowClassColor:SetChecked(true)
    end

    local enemyColorThreat = CreateCheckbox("enemyColorThreat", L["Color_Threat"], BetterBlizzPlates)
    enemyColorThreat:SetPoint("LEFT", nameplateShowClassColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyColorThreat, L["Color_By_Threat_In_Instanced_PvE"], L["Tooltip_Color_By_Threat_In_Instanced_PvE_Desc"])

    local enemyHealthBarColor = CreateCheckbox("enemyHealthBarColor", L["Custom_Healthbar_Color"], BetterBlizzPlates)
    enemyHealthBarColor:SetPoint("TOPLEFT", nameplateShowClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enemyHealthBarColor, L["Custom_Nameplate_Color"], L["Tooltip_Custom_Nameplate_Color_Desc"], L["Tooltip_Custom_Nameplate_Color_SubText"])

    local alwaysHideEnemyCastbar = CreateCheckbox("alwaysHideEnemyCastbar", L["Hide_Castbar"], BetterBlizzPlates)
    alwaysHideEnemyCastbar:SetPoint("TOPLEFT", enemyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideEnemyCastbar, L["Hide_Enemy_Castbar"], L["Tooltip_Hide_Enemy_Castbar_Desc"])
    alwaysHideEnemyCastbar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget = not BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget
            --self:SetChecked(BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget)
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local enemyHealthBarColorNpcOnly = CreateCheckbox("enemyHealthBarColorNpcOnly", L["Npc_Only"], BetterBlizzPlates)
    enemyHealthBarColorNpcOnly:SetPoint("LEFT", enemyHealthBarColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyHealthBarColorNpcOnly, L["Only_Color_NPCs"])

    local function OpenColorPicker(colorType, icon)
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB[colorType] or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB[colorType] = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(icon, r, g, b)
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB[colorType] = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(icon, r, g, b)
            end,
        })
    end

    local enemyHealthBarColorButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyHealthBarColorButtonIcon:SetAtlas("newplayertutorial-icon-key")
    enemyHealthBarColorButtonIcon:SetSize(18, 17)
    UpdateColorSquare(enemyHealthBarColorButtonIcon, unpack(BetterBlizzPlatesDB.enemyHealthBarColorRGB or {1, 1, 1}))
    local enemyHealthBarColorButton = CreateFrame("Button", nil, enemyHealthBarColor, "UIPanelButtonTemplate")
    enemyHealthBarColorButton:SetText(L["Hostile"])
    enemyHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorNpcOnly.Text, "RIGHT", -1, 0)
    enemyHealthBarColorButton:SetSize(55, 20)
    enemyHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyHealthBarColorRGB", enemyHealthBarColorButtonIcon)
    end)
    CreateTooltipTwo(enemyHealthBarColorButton, L["Hostile_Color"])
    enemyHealthBarColorButtonIcon:SetPoint("LEFT", enemyHealthBarColorButton, "RIGHT", 0, -0.5)

    local enemyNeutralHealthBarColorButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNeutralHealthBarColorButtonIcon:SetAtlas("newplayertutorial-icon-key")
    enemyNeutralHealthBarColorButtonIcon:SetSize(18, 17)
    UpdateColorSquare(enemyNeutralHealthBarColorButtonIcon, unpack(BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 1, 1}))
    local enemyNeutralHealthBarColorButton = CreateFrame("Button", nil, enemyHealthBarColor, "UIPanelButtonTemplate")
    enemyNeutralHealthBarColorButton:SetText(L["Neutral"])
    enemyNeutralHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorButtonIcon, "RIGHT", 0, 0.5)
    enemyNeutralHealthBarColorButton:SetSize(55, 20)
    enemyNeutralHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyNeutralHealthBarColorRGB", enemyNeutralHealthBarColorButtonIcon)
    end)
    CreateTooltipTwo(enemyNeutralHealthBarColorButton, L["Neutral_Color"])
    enemyNeutralHealthBarColorButtonIcon:SetPoint("LEFT", enemyNeutralHealthBarColorButton, "RIGHT", 0, -0.5)

    enemyHealthBarColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            enemyHealthBarColorNpcOnly:Enable()
            enemyHealthBarColorNpcOnly:Show()
            enemyNeutralHealthBarColorButton:Enable()
            enemyNeutralHealthBarColorButton:Show()
            enemyHealthBarColorButton:Enable()
            enemyHealthBarColorButton:Show()
            enemyHealthBarColorButtonIcon:Show()
            enemyNeutralHealthBarColorButtonIcon:Show()
        else
            enemyHealthBarColorNpcOnly:Hide()
            enemyHealthBarColorNpcOnly:Disable()
            enemyNeutralHealthBarColorButton:Disable()
            enemyNeutralHealthBarColorButton:Hide()
            enemyHealthBarColorButton:Disable()
            enemyHealthBarColorButton:Hide()
            enemyHealthBarColorButtonIcon:Hide()
            enemyNeutralHealthBarColorButtonIcon:Hide()
        end
    end)
    if not BetterBlizzPlatesDB.enemyHealthBarColor then
        enemyHealthBarColorNpcOnly:Hide()
        enemyHealthBarColorNpcOnly:Disable()
        enemyNeutralHealthBarColorButton:Disable()
        enemyNeutralHealthBarColorButton:Hide()
        enemyHealthBarColorButton:Hide()
        enemyHealthBarColorButton:Disable()
        enemyHealthBarColorButtonIcon:Hide()
        enemyNeutralHealthBarColorButtonIcon:Hide()
    end

    local showNameplateCastbarTimer = CreateCheckbox("showNameplateCastbarTimer", L["Cast_Timer_Next_To_Castbar"], BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateCastbarTimer:SetPoint("LEFT", alwaysHideEnemyCastbar.text, "RIGHT", 0, 0)

    local showNameplateTargetText = CreateCheckbox("showNameplateTargetText", L["Show_Target_Text"], BetterBlizzPlates, nil, function()
        BBP.ToggleSpellCastEventRegistration()
        BBP.ToggleTargetTextAlwaysShow()
        BBP.RefreshAllNameplates()
    end)
    showNameplateTargetText:SetPoint("TOPLEFT", alwaysHideEnemyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateTargetText, L["Nameplate_Target_Text"], L["Tooltip_Nameplate_Target_Text_Desc"], L["Tooltip_Nameplate_Target_Text_SubText"])

    local hideEliteDragon = CreateCheckbox("hideEliteDragon", L["Hide_Elite_Icon"], BetterBlizzPlates)
    hideEliteDragon:SetPoint("LEFT", showNameplateTargetText.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideEliteDragon, L["Hide_Elite_Icon"], L["Tooltip_Hide_Elite_Icon_2_Desc"])

    local enemyNameScale = CreateSlider(BetterBlizzPlates, L["Tooltip_Name_Size"], 0.5, 1.5, 0.01, "enemyNameScale")
    enemyNameScale:SetPoint("TOPLEFT", showNameplateTargetText, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(enemyNameScale, L["Tooltip_Name_Size"], L["Tooltip_Name_Size_Desc"])

    local hideEnemyNameText = CreateCheckbox("hideEnemyNameText", L["Hide_Name"], BetterBlizzPlates)
    hideEnemyNameText:SetPoint("LEFT", enemyNameScale, "RIGHT", 2, 0)
    CreateTooltipTwo(hideEnemyNameText, L["Hide_Enemy_Name"], L["Tooltip_Hide_Enemy_Name_Desc"])
    hideEnemyNameText:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not IsShiftKeyDown() then
                BetterBlizzPlatesDB.forceShowTotemNames = not BetterBlizzPlatesDB.forceShowTotemNames
                if BetterBlizzPlatesDB.forceShowTotemNames then
                    if not C_CVar.GetCVarBool("UnitNameEnemyTotemName") then
                        BBP.RunAfterCombat(function()
                            C_CVar.SetCVar("UnitNameEnemyTotemName", "1")
                            BBP.Print(L["Print_CVar_UnitNameEnemyTotemName_Set_To_1_So"])
                        end)
                    end
                    if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
                        BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown = false
                        if BBP.totemIndicatorHideName then
                            BBP.totemIndicatorHideName:SetChecked(false)
                        end
                    end
                end
            else
                BetterBlizzPlatesDB.hideNameShowTarget = not BetterBlizzPlatesDB.hideNameShowTarget
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.needsUpdate = true
            BBP.RefreshAllNameplates()
        end
    end)

--[[
    -- Nameplate height slider
    local enemyNameplateHealthbarHeightSlider = CreateSlider("enemyNameplateHealthbarHeightScaleSlider", BetterBlizzPlates, "Nameplate Height (*)", 2, 20, 0.1, "enemyNameplateHealthbarHeight")
    enemyNameplateHealthbarHeightSlider:SetPoint("TOPLEFT", enemyNameScale, "BOTTOMLEFT", 0, -17)
    enemyNameplateHealthbarHeightSlider:Disable()
    enemyNameplateHealthbarHeightSlider:SetAlpha(0.5)
    CreateTooltip(enemyNameplateHealthbarHeightSlider, "*Testing\nDisabled until I figure out stuff")

    -- Button for resetting Enemy Nameplate Height
    local nameplateEnemyWidthResetButtonHeight = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateEnemyWidthResetButtonHeight:SetText("Default")
    nameplateEnemyWidthResetButtonHeight:SetWidth(60)
    nameplateEnemyWidthResetButtonHeight:SetPoint("LEFT", enemyNameplateHealthbarHeightSlider, "RIGHT", 10, 0)
    nameplateEnemyWidthResetButtonHeight:Disable()
    nameplateEnemyWidthResetButtonHeight:SetAlpha(0.5)
    nameplateEnemyWidthResetButtonHeight:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight2(enemyNameplateHealthbarHeightSlider)
    end)

]]

    local nameplateEnemyWidth = CreateSlider(BetterBlizzPlates, L["Nameplate_Width"], 24, 300, 1, "nameplateEnemyWidth")
    nameplateEnemyWidth:SetPoint("TOPLEFT", enemyNameScale, "BOTTOMLEFT", 0, -17)

    local nameplateEnemyWidthResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateEnemyWidthResetButton:SetText(L["Default"])
    nameplateEnemyWidthResetButton:SetWidth(60)
    nameplateEnemyWidthResetButton:SetPoint("LEFT", nameplateEnemyWidth, "RIGHT", 10, 0)
    nameplateEnemyWidthResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultWidth(nameplateEnemyWidth, false)
    end)

    ----------------------
    -- Friendly nameplates:
    ----------------------
    local friendlyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -375)
    friendlyNameplatesText:SetText(L["Friendly_Nameplates"])
    friendlyNameplatesText:SetFont(fontLarge, 16)
    friendlyNameplatesText:SetTextColor(1,1,1)
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", L["Clickthrough"], BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(friendlyNameplateClickthrough, L["Clickthrough_Nameplate"], L["Tooltip_Clickthrough_Nameplate_Desc"])

    local friendlyHideOtherPets = CreateCheckbox("friendlyHideOtherPets", L["Hide_Other_Pets"], BetterBlizzPlates)
    friendlyHideOtherPets:SetPoint("LEFT", friendlyNameplateClickthrough.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyHideOtherPets, L["Hide_Other_Pets"], L["Tooltip_Hide_Other_Pets_Desc"])

    -- local friendlyNameplateNonstackable = CreateCheckbox("friendlyNameplateNonstackable", "Non-Stackable", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    -- friendlyNameplateNonstackable:SetPoint("LEFT", friendlyNameplateClickthrough.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(friendlyNameplateNonstackable, "Non-Stackable", "Makes the friendly nameplates non-stackable even with \"Stacking Nameplates\" on.")

    local friendlyClassColorName = CreateCheckbox("friendlyClassColorName", L["Class_Color_Name"], BetterBlizzPlates)
    friendlyClassColorName:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyClassColorName, L["Class_Color_Name"], L["Tooltip_Class_Color_Name_2_Desc_2"], nil, nil, "nameplateUseClassColorForFriendlyPlayerUnitNames")
    friendlyClassColorName:HookScript("OnClick", function(self)
        local value = self:GetChecked() and "1" or "0"
        BBP.RunAfterCombat(function()
            C_CVar.SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", value)
        end)
    end)

    local friendlyColorName = CreateCheckbox("friendlyColorName", L["Color_Name"], BetterBlizzPlates)
    friendlyColorName:SetPoint("LEFT", friendlyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyColorName, L["Color_Name"], L["Tooltip_Color_Name_2_Desc_2"], L["Tooltip_Color_Name_2_SubText"])

    local friendlyColorNameIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyColorNameIcon:SetAtlas("newplayertutorial-icon-key")
    friendlyColorNameIcon:SetSize(18, 17)
    UpdateColorSquare(friendlyColorNameIcon, unpack(BetterBlizzPlatesDB.friendlyColorNameRGB or {1, 1, 1}))

    local function OpenColorPicker2()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.friendlyColorNameRGB or {1, 1, 1})
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.friendlyColorNameRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(friendlyColorNameIcon, r, g, b)
            end,
            cancelFunc = function(previousValues)
                BetterBlizzPlatesDB.friendlyColorNameRGB = { previousValues.r, previousValues.g, previousValues.b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(friendlyColorNameIcon, r, g, b)
            end
        })
    end

    local friendlyColorNameButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    friendlyColorNameButton:SetText(L["Color"])
    friendlyColorNameButton:SetPoint("LEFT", friendlyColorName.text, "RIGHT", -1, 0)
    friendlyColorNameButton:SetSize(45, 20)
    friendlyColorNameButton:SetScript("OnClick", OpenColorPicker2)
    friendlyColorNameIcon:SetPoint("LEFT", friendlyColorNameButton, "RIGHT", 0, -0.5)
    friendlyColorName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            friendlyColorNameButton:Show()
            friendlyColorNameIcon:Show()
            friendlyColorNameButton:Enable()
        else
            friendlyColorNameButton:Hide()
            friendlyColorNameIcon:Hide()
            friendlyColorNameButton:Disable()
        end
    end)
    if friendlyColorName:GetChecked() then
        friendlyColorNameButton:Show()
        friendlyColorNameIcon:Show()
    else
        friendlyColorNameButton:Hide()
        friendlyColorNameIcon:Hide()
    end

    local nameplateShowFriendlyClassColor = CreateCheckbox("nameplateShowFriendlyClassColor", L["Class_Color_Healthbar"], BetterBlizzPlates, true)
    BBP.classColorCVarCheckboxes = { nameplateShowClassColor = nameplateShowClassColor, nameplateShowFriendlyClassColor = nameplateShowFriendlyClassColor }
    nameplateShowFriendlyClassColor:SetPoint("TOPLEFT", friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyClassColor, L["Class_Color_Healthbar"], L["Tooltip_Class_Color_Healthbar_Desc"], nil, nil, "nameplateShowFriendlyClassColor")
    if GetCVar("nameplateShowFriendlyClassColor") == "1" and BetterBlizzPlatesDB.nameplateShowFriendlyClassColor == nil then
        BetterBlizzPlatesDB.nameplateShowFriendlyClassColor = true
        nameplateShowFriendlyClassColor:SetChecked(true)
    end

    local friendlyHealthBarColor = CreateCheckbox("friendlyHealthBarColor", L["Custom_Healthbar_Color"], BetterBlizzPlates)
    friendlyHealthBarColor:SetPoint("TOPLEFT", nameplateShowFriendlyClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyHealthBarColor, L["Custom_Healthbar_Color"], L["Tooltip_Custom_Healthbar_Color_2_Desc"])

    local friendlyHealthBarColorPlayer = CreateCheckbox("friendlyHealthBarColorPlayer", L["Player"], BetterBlizzPlates)
    friendlyHealthBarColorPlayer:SetPoint("LEFT", friendlyHealthBarColor.text, "RIGHT", -3, 0)
    CreateTooltipTwo(friendlyHealthBarColorPlayer, L["Color_Players"], L["Tooltip_Color_Players_Desc"])

    local friendlyHealthBarColorNpc = CreateCheckbox("friendlyHealthBarColorNpc", L["Npc"], BetterBlizzPlates)
    friendlyHealthBarColorNpc:SetPoint("LEFT", friendlyHealthBarColorPlayer.text, "RIGHT", -3, 0)
    CreateTooltipTwo(friendlyHealthBarColorNpc, L["Color_Npcs"], L["Tooltip_Color_Npcs_Desc"])

    local alwaysHideFriendlyCastbar = CreateCheckbox("alwaysHideFriendlyCastbar", L["Hide_Castbar"], BetterBlizzPlates)
    alwaysHideFriendlyCastbar:SetPoint("TOPLEFT", friendlyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideFriendlyCastbar, L["Hide_Friendly_Castbar"], L["Tooltip_Hide_Friendly_Castbar_Desc"])
    alwaysHideFriendlyCastbar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BetterBlizzPlatesDB.alwaysHideFriendlyCastbarShowTarget = not BetterBlizzPlatesDB.alwaysHideFriendlyCastbarShowTarget
            --self:SetChecked(BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget)
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)
    BBP.alwaysHideFriendlyCastbar = alwaysHideFriendlyCastbar

    -- local classColorPersonalNameplate = CreateCheckbox("classColorPersonalNameplate", "Class color personal nameplate", BetterBlizzPlates)
    -- classColorPersonalNameplate:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- classColorPersonalNameplate:HookScript("OnClick", function(self)
    --     BBP.ColorPRD()
    -- end)

    -- local friendlyNameColor = CreateCheckbox("friendlyNameColor", "Name", BetterBlizzPlates)
    -- friendlyNameColor:SetPoint("LEFT", friendlyHealthBarColorNpc.Text, "RIGHT", -3, 0)
    -- friendlyNameColor:HookScript("OnClick", function(self)
    --     if self:GetChecked(true) then
    --         BetterBlizzPlatesDB.friendlyClassColorName = false
    --         friendlyClassColorName:SetChecked(false)
    --     end
    -- end)
    -- CreateTooltipTwo(friendlyNameColor, "Color Name", "Color Friendly name text as well.")

    -- friendlyClassColorName:HookScript("OnClick", function(self)
    --     if self:GetChecked(true) then
    --         BetterBlizzPlatesDB.friendlyNameColor = false
    --         friendlyNameColor:SetChecked(false)
    --     end
    -- end)

    local function UpdateColorSquare(icon, r, g, b)
        if r and g and b then
            icon:SetVertexColor(r, g, b)
        end
    end

    local function OpenColorPicker(colorType, icon)
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB[colorType] or {1, 1, 1})
        UpdateColorSquare(icon, r, g, b)

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB[colorType] = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(icon, r, g, b)
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB[colorType] = { r, g, b }
                BBP.RefreshAllNameplates()
                UpdateColorSquare(icon, r, g, b)
            end,
        })
    end

    local friendlyHealthBarColorButton = CreateFrame("Button", nil, friendlyHealthBarColor, "UIPanelButtonTemplate")
    friendlyHealthBarColorButton:SetText(L["Color"])
    friendlyHealthBarColorButton:SetPoint("LEFT", friendlyHealthBarColorNpc.Text, "RIGHT", -3, 0)
    friendlyHealthBarColorButton:SetSize(50, 20)
    local friendlyHealthBarColorButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyHealthBarColorButtonIcon:SetAtlas("newplayertutorial-icon-key")
    friendlyHealthBarColorButtonIcon:SetSize(18, 17)
    friendlyHealthBarColorButtonIcon:SetPoint("LEFT", friendlyHealthBarColorButton, "RIGHT", 0, 0)
    UpdateColorSquare(friendlyHealthBarColorButtonIcon, unpack(BetterBlizzPlatesDB["friendlyHealthBarColorRGB"] or {1, 1, 1}))
    friendlyHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("friendlyHealthBarColorRGB", friendlyHealthBarColorButtonIcon)
    end)

    friendlyHealthBarColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            friendlyHealthBarColorPlayer:Enable()
            friendlyHealthBarColorPlayer:Show()
            friendlyHealthBarColorNpc:Enable()
            friendlyHealthBarColorNpc:Show()
            -- friendlyNameColor:Enable()
            -- friendlyNameColor:Show()
            friendlyHealthBarColorButton:Enable()
            friendlyHealthBarColorButton:Show()
            friendlyHealthBarColorButtonIcon:Show()
        else
            friendlyHealthBarColorPlayer:Disable()
            friendlyHealthBarColorPlayer:Hide()
            friendlyHealthBarColorNpc:Disable()
            friendlyHealthBarColorNpc:Hide()
            -- friendlyNameColor:Hide()
            -- friendlyNameColor:Disable()
            friendlyHealthBarColorButton:Disable()
            friendlyHealthBarColorButton:Hide()
            friendlyHealthBarColorButtonIcon:Hide()
        end
    end)
    if not BetterBlizzPlatesDB.friendlyHealthBarColor then
        friendlyHealthBarColorPlayer:Disable()
        friendlyHealthBarColorPlayer:Hide()
        friendlyHealthBarColorNpc:Disable()
        friendlyHealthBarColorNpc:Hide()
        -- friendlyNameColor:Disable()
        -- friendlyNameColor:Hide()
        friendlyHealthBarColorButtonIcon:Hide()
        friendlyHealthBarColorButton:Hide() --default slider creation only does 0.5 alpha
        friendlyHealthBarColorButton:Disable()
    end

    BBP.friendlyHideHealthBar = CreateCheckbox("friendlyHideHealthBar", L["Hide_Healthbar"], BetterBlizzPlates)
    BBP.friendlyHideHealthBar:SetPoint("LEFT", alwaysHideFriendlyCastbar.text, "RIGHT", 0, 0)
    BBP.friendlyHideHealthBar:HookScript("OnClick", function()
        BBP.HideHealthbarInPvEMagicCaller()
    end)
    BBP.friendlyHideHealthBar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not IsShiftKeyDown() then
                BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget = not BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget
                --self:SetChecked(BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget)
            else
                if not BetterBlizzPlatesDB.friendlyHideHealthBarShowTanksAndHeals then
                    BetterBlizzPlatesDB.friendlyHideHealthBarShowTanksAndHeals = true
                else
                    BetterBlizzPlatesDB.friendlyHideHealthBarShowTanksAndHeals = nil
                end
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.RefreshAllNameplates()
        end
    end)

    CreateTooltipTwo(BBP.friendlyHideHealthBar, L["Hide_Healthbar"], L["Tooltip_Hide_Healthbar_2_Desc"], L["Tooltip_Hide_Healthbar_2_SubText"])

    BBP.friendlyHideHealthBarNpc = CreateCheckbox("friendlyHideHealthBarNpc", L["NPCs"], BetterBlizzPlates)
    BBP.friendlyHideHealthBarNpc:SetPoint("LEFT", BBP.friendlyHideHealthBar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(BBP.friendlyHideHealthBarNpc, L["Hide_NPC_Healthbar"], L["Tooltip_Hide_NPC_Healthbar_Desc"], L["Tooltip_Hide_NPC_Healthbar_SubText"])

    BBP.friendlyHideHealthBarNpc:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not IsShiftKeyDown() then
                if not BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve then
                    BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve = true
                else
                    BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve = nil
                end
                BBP.ShowPopup("BBP_CONFIRM_RELOAD")
            else
                if not BetterBlizzPlatesDB.friendlyHideHealthBarShowPet then
                    BetterBlizzPlatesDB.friendlyHideHealthBarShowPet = true
                else
                    BetterBlizzPlatesDB.friendlyHideHealthBarShowPet = nil
                end
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.RefreshAllNameplates()
        end
    end)

    -- BBP.friendlyHideHealthBar:HookScript("OnClick", function(self)
    --     if self:GetChecked() then
    --         BBP.friendlyHideHealthBarNpc:Enable()
    --         BBP.friendlyHideHealthBarNpc:Show()
    --         BBP.friendlyHideHealthBarNpc:SetAlpha(1)
    --     else
    --         BBP.friendlyHideHealthBarNpc:Disable()
    --         BBP.friendlyHideHealthBarNpc:Hide()
    --     end
    -- end)
    -- if not BetterBlizzPlatesDB.friendlyHideHealthBar then
    --     BBP.friendlyHideHealthBarNpc:Hide()
    --     BBP.friendlyHideHealthBarNpc:Disable()
    -- end

    local friendlyNpToggles = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    friendlyNpToggles:SetText(L["Toggles_Colon"])
    friendlyNpToggles:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", -20, -70)
    CreateTooltipTwo(friendlyNpToggles, L["Toggle_Friendly_Nameplates"], L["Tooltip_Toggle_Friendly_Nameplates_Desc"])

    do
        BBP.friendlyToggleButtons = {}
        local anchor = friendlyNpToggles
        for _, toggle in ipairs({
            { "arena", L["Toggle_Short_Arena"], L["Arena_Toggle"], L["Tooltip_Friendly_Toggle_Arenas"] },
            { "bg", L["Toggle_BGs"], L["Battleground_Toggle"], L["Tooltip_Friendly_Toggle_BGs"] },
            { "epicbg", L["Toggle_Short_EBGs"], L["Epic_Battleground_Toggle"], L["Tooltip_Friendly_Toggle_EBGs"] },
            { "dungeon", L["Toggle_Dungeons"], L["Dungeon_Toggle"], L["Tooltip_Friendly_Toggle_Dungeons"] },
            { "raid", L["Toggle_Raids"], L["Raid_Toggle"], L["Tooltip_Friendly_Toggle_Raids"] },
            { "world", L["Toggle_World"], L["World_Toggle"], L["Tooltip_Friendly_Toggle_World"] },
            { "city", L["Toggle_Short_City"], L["City_Toggle"], L["Tooltip_Friendly_Toggle_Cities"] },
        }) do
            local key = toggle[1]
            if BBP.nameplateToggleCategoryByKey[key].available then
                local button = CreateFrame("CheckButton", nil, BetterBlizzPlates, "InterfaceOptionsCheckButtonTemplate")
                button:SetSize(22, 22)
                button.Text:SetText(toggle[2])
                button.searchCategory = L["Search_Name_General"]
                table.insert(checkBoxList, {checkbox = button, label = toggle[2]})
                CreateTooltipTwo(button, toggle[3], toggle[4])
                if anchor == friendlyNpToggles then
                    button:SetPoint("LEFT", anchor, "RIGHT", 0, 0)
                else
                    button:SetPoint("LEFT", anchor.Text, "RIGHT", -2, 0)
                end
                button:SetChecked(BBP.GetFriendlyToggle(key))
                button:SetScript("OnClick", function(self)
                    BBP.SetFriendlyToggle(key, self:GetChecked())
                end)
                BBP.friendlyToggleButtons[key] = button
                anchor = button
            end
        end
    end

    local friendlyNameScale = CreateSlider(BetterBlizzPlates, L["Tooltip_Name_Size"], 0.5, 3, 0.01, "friendlyNameScale")
    friendlyNameScale:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", 0, -6)
    CreateTooltipTwo(friendlyNameScale, L["Tooltip_Name_Size"], L["Tooltip_Name_Size_Desc_2"], L["Tooltip_Name_Size_SubText"])

    local hideNameTooltip = L["Tooltip_Hide_Name_2_Desc"]
    if BetterBlizzPlatesDB.partyPointerHideAll then
        hideNameTooltip = L["Tooltip_Hide_Name_On_Friendly_Nameplates_Party"]
    end
    local hideFriendlyNameText = CreateCheckbox("hideFriendlyNameText", L["Hide_Name"], BetterBlizzPlates)
    hideFriendlyNameText:SetPoint("LEFT", friendlyNameScale, "RIGHT", 2, 0)
    CreateTooltipTwo(hideFriendlyNameText, L["Hide_Name"], hideNameTooltip)
    BBP.hideFriendlyNameText = hideFriendlyNameText

    local nameplateFriendlyWidth = CreateSlider(BetterBlizzPlates, L["Nameplate_Width"], 24, 300, 1, "nameplateFriendlyWidth")
    nameplateFriendlyWidth:SetPoint("TOPLEFT", friendlyNameScale, "BOTTOMLEFT", 0, -20)
    CreateTooltipTwo(nameplateFriendlyWidth, L["Friendly_Nameplate_Width"], L["Tooltip_Friendly_Nameplate_Width_Desc"])

    local nameplateFriendlyWidthResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateFriendlyWidthResetButton:SetText(L["Default"])
    nameplateFriendlyWidthResetButton:SetWidth(60)
    nameplateFriendlyWidthResetButton:SetPoint("LEFT", nameplateFriendlyWidth, "RIGHT", 5, 0)
    nameplateFriendlyWidthResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultWidth(nameplateFriendlyWidth, true)
    end)

    ----------------------
    -- Extra features on nameplates:
    ----------------------
    local extraFeaturesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 390, -102)
    extraFeaturesText:SetText(L["Extra_Features"])
    extraFeaturesText:SetFont(fontLarge, 16)
    extraFeaturesText:SetTextColor(1,1,1)
    local extraFeaturesIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)
    CreateTooltipTwo(extraFeaturesText, L["Extra_Features"] .. " |A:Campaign-QuestLog-LoreBook:18:18|a", L["Tooltip_Extra_Features_Desc"])
    CreateTooltipTwo(extraFeaturesIcon, L["Extra_Features"] .. " |A:Campaign-QuestLog-LoreBook:18:18|a", L["Tooltip_Extra_Features_Desc"])

    local testAllEnabledFeatures = CreateCheckbox("testAllEnabledFeatures", L["Test"], BetterBlizzPlates, nil, BBP.TestAllEnabledFeatures)
    testAllEnabledFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
    CreateTooltipTwo(testAllEnabledFeatures, L["Test_All_Features"], L["Tooltip_Test_All_Features_Desc"], L["Tooltip_Test_All_Features_SubText"])

    local absorbIndicator = CreateCheckbox("absorbIndicator", L["Absorb_Indicator"], BetterBlizzPlates, nil, BBP.ToggleAbsorbIndicator)
    absorbIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(absorbIndicator, L["Absorb_Indicator"] .. " |A:ParagonReputation_Glow:18:18|a", L["Tooltip_Absorb_Indicator_2_Desc"])
    local absorbsIcon = absorbIndicator:CreateTexture(nil, "ARTWORK")
    absorbsIcon:SetAtlas("ParagonReputation_Glow")
    absorbsIcon:SetSize(22, 22)
    absorbsIcon:SetPoint("RIGHT", absorbIndicator, "LEFT", 2, 0)

    local overShields = CreateCheckbox("overShields", L["Overshields"], BetterBlizzPlates, nil, BBP.HookOverShields)
    overShields:SetPoint("LEFT", absorbIndicator.text, "RIGHT", 0, 0)
    CreateTooltipTwo(overShields, L["Show_Overshields"] .. " |A:ParagonReputation_Glow:18:18|a", L["Tooltip_Show_Overshields_Desc"], L["Tooltip_Show_Overshields_SubText"])
    overShields:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local bgIndicator = CreateCheckbox("bgIndicator", L["Blitz_Indicator"], BetterBlizzPlates, nil, BBP.ToggleNpFlagUpdates)
    bgIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(bgIndicator, L["Blitz_Indicator"] .. " |A:Ping_Chat_Assist:18:18|a", L["Tooltip_Blitz_Indicator_2_Desc"])
    local bgIcon = bgIndicator:CreateTexture(nil, "ARTWORK")
    bgIcon:SetAtlas("Ping_Chat_Assist")
    bgIcon:SetSize(17, 17)
    bgIcon:SetPoint("RIGHT", bgIndicator, "LEFT", 1, 0)

    local classIndicator = CreateCheckbox("classIndicator", L["Class_Indicator"], BetterBlizzPlates, nil, BBP.ToggleNpFlagUpdates)
    classIndicator:SetPoint("TOPLEFT", bgIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classIndicator, L["Class_Indicator"] .. " |A:groupfinder-icon-class-mage:16:16|a", L["Tooltip_Class_Indicator_2_Desc"], L["Tooltip_Class_Indicator_2_SubText"])
    local classIndicatorIcon = classIndicator:CreateTexture(nil, "ARTWORK")
    classIndicatorIcon:SetAtlas("groupfinder-icon-class-mage")
    classIndicatorIcon:SetSize(18, 18)
    classIndicatorIcon:SetPoint("RIGHT", classIndicator, "LEFT", 0, 0)

    local classIndicatorPinMode = CreateCheckbox("classIndicatorPinMode", L["Pin_Mode"], classIndicator)
    classIndicatorPinMode:SetPoint("LEFT", classIndicator.text, "RIGHT", 0, 0)
    classIndicatorPinMode:HookScript("OnClick", function(self)
        BBP.ToggleClassIndicatorPinMode(self:GetChecked())
    end)
    CreateTooltipTwo(classIndicatorPinMode, L["Class_Indicator_Pin_Mode"] .. " |A:groupfinder-icon-class-mage:16:16|a", L["Tooltip_Class_Indicator_Pin_Mode_Desc"], L["Tooltip_Class_Indicator_Pin_Mode_SubText"])

    classIndicator:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        BBP.RefreshAllNameplateAuras()
        if InCombatLockdown() then return end
        if self:GetChecked() then
            C_CVar.SetCVar("nameplateShowFriendlyPlayers", "1")
            BBP.SaveNameplateToggleCVar("nameplateShowFriendlyPlayers", "1")
        end
    end)


    local combatIndicator = CreateCheckbox("combatIndicator", L["Combat_Indicator"], BetterBlizzPlates, nil, BBP.ToggleCombatIndicator)
    combatIndicator:SetPoint("TOPLEFT", classIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(combatIndicator, L["Combat_Indicator"] .. " |A:food:16:16|a", L["Tooltip_Combat_Indicator_2_Desc"])
    local combatIcon = combatIndicator:CreateTexture(nil, "ARTWORK")
    combatIcon:SetAtlas("food")
    combatIcon:SetSize(19, 19)
    combatIcon:SetPoint("RIGHT", combatIndicator, "LEFT", -1, 0)

    local executeIndicator = CreateCheckbox("executeIndicator", L["Execute_Indicator"], BetterBlizzPlates, nil, BBP.ToggleExecuteIndicator)
    executeIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(executeIndicator, L["Execute_Indicator"] .. " |A:islands-azeriteboss:24:24|a", L["Tooltip_Execute_Indicator_2_Desc"])
    local executeIndicatorIcon = executeIndicator:CreateTexture(nil, "ARTWORK")
    executeIndicatorIcon:SetAtlas("islands-azeriteboss")
    executeIndicatorIcon:SetSize(28, 30)
    executeIndicatorIcon:SetPoint("RIGHT", executeIndicator, "LEFT", 4, 1)

    local factionIndicator = CreateCheckbox("factionIndicator", L["Faction_Indicator"], BetterBlizzPlates, nil, BBP.ToggleFactionIndicator)
    factionIndicator:SetPoint("TOPLEFT", executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(factionIndicator, L["Faction_Indicator"] .. " |A:questlog-questtypeicon-alliance:21:21|a", L["Tooltip_Faction_Indicator_2_Desc"], L["Tooltip_Faction_Indicator_2_SubText"])
    local factionIndicatorIcon = factionIndicator:CreateTexture(nil, "ARTWORK")
    factionIndicatorIcon:SetAtlas("questlog-questtypeicon-alliance")
    factionIndicatorIcon:SetSize(21, 21)
    factionIndicatorIcon:SetPoint("RIGHT", factionIndicator, "LEFT", 0, 0)

    local healerIndicator = CreateCheckbox("healerIndicator", L["Healer_Indicator"], BetterBlizzPlates)
    healerIndicator:SetPoint("TOPLEFT", factionIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healerIndicator, L["Healer_Indicator"] .. " |A:greencross:21:21|a", L["Tooltip_Healer_Indicator_2_Desc"], L["Tooltip_Healer_Indicator_2_SubText"])
    local healerCrossIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    healerCrossIcon:SetAtlas("greencross")
    healerCrossIcon:SetSize(21, 21)
    healerCrossIcon:SetPoint("RIGHT", healerIndicator, "LEFT", 0, 0)

    local partyPointer = CreateCheckbox("partyPointer", L["Party_Pointer"], BetterBlizzPlates)
    partyPointer:SetPoint("TOPLEFT", healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    partyPointer:HookScript("OnClick", function(self)
        BBP.RefreshAllNameplateAuras()
        if self:GetChecked() then
            if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
                BBP.Print(L["Print_Enable_Nameplate_Aura_Customization_In_Order"])
            else
                BBP.Print(L["Print_Enabled_Friendly_Debuffs_And_PvP_CC"])
            end
            if BBP.friendlyNpdeBuffEnable then
                if not BBP.friendlyNpdeBuffEnable:GetChecked() then
                    BBP.friendlyNpdeBuffEnable:Click()
                end
                if not BBP.friendlyNpdeBuffFilterCC:GetChecked() then
                    BBP.friendlyNpdeBuffFilterCC:Click()
                end
                BetterBlizzPlatesDB.friendlyNpdeBuffEnable = true
                BetterBlizzPlatesDB.friendlyNpdeBuffFilterCC = true
            else
                BetterBlizzPlatesDB.friendlyNpdeBuffEnable = true
                BetterBlizzPlatesDB.friendlyNpdeBuffFilterCC = true
            end
            if InCombatLockdown() then return end
            C_CVar.SetCVar("nameplateShowFriendlyPlayers", "1")
            BBP.SaveNameplateToggleCVar("nameplateShowFriendlyPlayers", "1")
        end
    end)
    CreateTooltipTwo(partyPointer, L["Party_Pointer"] .. " |A:UI-QuestPoiImportant-QuestNumber-SuperTracked:21:16|a", L["Tooltip_Party_Pointer_2_Desc"], L["Tooltip_Party_Pointer_2_SubText"])
    local partyPointerIcon = partyPointer:CreateTexture(nil, "ARTWORK")
    partyPointerIcon:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
    partyPointerIcon:SetSize(16, 20)
    partyPointerIcon:SetPoint("RIGHT", partyPointer, "LEFT", -2.5, 1.5)
    partyPointerIcon:SetDesaturated(true)
    partyPointerIcon:SetVertexColor(0.04, 0.76, 1)

    local petIndicator = CreateCheckbox("petIndicator", L["Pet_Indicator"], BetterBlizzPlates)
    petIndicator:SetPoint("TOPLEFT", partyPointer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(petIndicator, L["Tooltip_Show_A_Murloc_On_The_Main"])
    CreateTooltipTwo(petIndicator, L["Pet_Indicator"] .. " |A:newplayerchat-chaticon-newcomer:18:18|a", L["Tooltip_Pet_Indicator_2_Desc"])
    local petIndicatorIcon = petIndicator:CreateTexture(nil, "ARTWORK")
    petIndicatorIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicatorIcon:SetSize(18, 18)
    petIndicatorIcon:SetPoint("RIGHT", petIndicator, "LEFT", -1, 0)

    local targetIndicator = CreateCheckbox("targetIndicator", L["Target_Indicator"], BetterBlizzPlates)
    targetIndicator:SetPoint("TOPLEFT", petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetIndicator, L["Target_Indicator"] .. " |A:Navigation-Tracked-Arrow:14:19|a", L["Tooltip_Target_Indicator_2_Desc"])
    local targetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    targetIndicatorIcon:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicatorIcon:SetRotation(math.rad(180))
    targetIndicatorIcon:SetSize(19, 14)
    targetIndicatorIcon:SetPoint("RIGHT", targetIndicator, "LEFT", -1, 0)

    local focusTargetIndicator = CreateCheckbox("focusTargetIndicator", L["Focus_Target_Indicator"], BetterBlizzPlates)
    focusTargetIndicator:SetPoint("TOPLEFT", targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicator, L["Tooltip_Show_A_Marker_On_The_Focus"])
    CreateTooltipTwo(focusTargetIndicator, L["Focus_Target_Indicator"] .. " |A:Waypoint-MapPin-Untracked:19:19|a", L["Tooltip_Focus_Target_Indicator_2_Desc"])
    local focusTargetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    focusTargetIndicatorIcon:SetAtlas("Waypoint-MapPin-Untracked")
    focusTargetIndicatorIcon:SetSize(19, 19)
    focusTargetIndicatorIcon:SetPoint("RIGHT", focusTargetIndicator, "LEFT", 0, 0)

    local totemIndicator = CreateCheckbox("totemIndicator", L["Totem_Indicator"], BetterBlizzPlates)
    totemIndicator:SetPoint("TOPLEFT", focusTargetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    totemIndicator:HookScript("OnClick", function(self)
        local function setTotemCVar()
            if InCombatLockdown() then
                C_Timer.After(1.5, setTotemCVar)
            elseif self:GetChecked() then
                BBP.EnableTotemIndicatorCVars()
            else
                BBP.UpdateNameplateToggles(true, true)
            end
        end
        setTotemCVar()
    end)

    CreateTooltipTwo(totemIndicator, L["Totem_Indicator"] .. " |A:teleportationnetwork-ardenweald-32x32:17:17|a", L["Tooltip_Totem_Indicator_2_Desc"])
    local totemsIcon = totemIndicator:CreateTexture(nil, "ARTWORK")
    totemsIcon:SetAtlas("teleportationnetwork-ardenweald-32x32")
    totemsIcon:SetSize(17, 17)
    totemsIcon:SetPoint("RIGHT", totemIndicator, "LEFT", -1, 0)

    local questIndicator = CreateCheckbox("questIndicator", L["Quest_Indicator"], BetterBlizzPlates, nil, BBP.ToggleQuestIndicator)
    questIndicator:SetPoint("TOPLEFT", totemIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(questIndicator, L["Quest_Indicator"] .. "|A:smallquestbang:20:20|a", L["Tooltip_Quest_Indicator_2_Desc"])
    local questsIcon = questIndicator:CreateTexture(nil, "ARTWORK")
    questsIcon:SetAtlas("smallquestbang")
    questsIcon:SetSize(20, 20)
    questsIcon:SetPoint("RIGHT", questIndicator, "LEFT", 1, 0)

    ----------------------
    -- Font and texture
    ----------------------
    local customFontandTextureText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -373)
    customFontandTextureText:SetText(L["Font_And_Texture"])
    customFontandTextureText:SetFont(fontLarge, 16)
    customFontandTextureText:SetTextColor(1,1,1)
    local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    customFontandTextureIcon:SetAtlas("barbershop-32x32")
    customFontandTextureIcon:SetSize(24, 24)
    customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

    local useCustomFont = CreateCheckbox("useCustomFont", L["Change_The_Nameplate_Font"], BetterBlizzPlates)
    useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(useCustomFont, L["Custom_Font"], L["Change_The_Nameplate_Font"], L["Tooltip_Custom_Font_SubText"])

    local useDefaultBlizzardOutline = CreateCheckbox("disableDefaultBlizzardOutline", L["Disable_Outline"], BetterBlizzPlates)
    useDefaultBlizzardOutline:SetPoint("LEFT", useCustomFont.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(useDefaultBlizzardOutline, L["Disable_Default_Blizzard_Outline"], L["Tooltip_Disable_Default_Blizzard_Outline_Desc"])

    local useCustomTexture = CreateCheckbox("useCustomTextureForBars", L["Change_The_Nameplate_Texture"], BetterBlizzPlates)
    useCustomTexture:SetPoint("TOPLEFT", useCustomFont, "BOTTOMLEFT", 0, -23)
    CreateTooltipTwo(useCustomTexture, L["Custom_Texture"], L["Change_The_Nameplate_Texture"])

    local fontDropdown = CreateFontDropdown(
        "fontDropdown",
        useCustomFont,
        L["Select_Font"],
        "customFont",
        function(arg1)
            BBP.RefreshAllNameplates()
            BBP.TexturePRD()
        end,
        { anchorFrame = useCustomFont, x = 20, y = 1, label = L["Font"] }
    )

    if not useCustomFont:GetChecked() then
        fontDropdown:Disable()
    else
        DisableElement(useDefaultBlizzardOutline)
    end

    local enableCustomFontOutline = CreateCheckbox("enableCustomFontOutline", L["Outline_Label"], useCustomFont)
    enableCustomFontOutline:SetPoint("LEFT", fontDropdown, "RIGHT", 0, 0)
    CreateTooltipTwo(enableCustomFontOutline, L["Font_Outline"], L["Tooltip_Font_Outline_Desc"])

    enableCustomFontOutline:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then
                -- Toggle Font Shadow
                BetterBlizzPlatesDB["customFontShadowOff"] = not BetterBlizzPlatesDB["customFontShadowOff"]
                local shadowState = BetterBlizzPlatesDB["customFontShadowOff"] and L["Disabled"] or L["Enabled"]
                RefreshTooltip(enableCustomFontOutline, L["Font_Outline"],
                    string.format(L["Tooltip_Font_Outline_Toggle_Desc"],
                    BetterBlizzPlatesDB["customFontOutline"] == "THICKOUTLINE" and L["Thick_Outline"] or L["Thin_Outline"],
                    shadowState))
            else
                -- Swap Between Thick and Thin Outline
                local currentOutline = BetterBlizzPlatesDB["customFontOutline"]
                if currentOutline == "THINOUTLINE" then
                    BetterBlizzPlatesDB["customFontOutline"] = "THICKOUTLINE"
                    RefreshTooltip(enableCustomFontOutline, L["Font_Outline"],
                        string.format(L["Tooltip_Font_Outline_Toggle_Desc"], L["Thick_Outline"],
                        BetterBlizzPlatesDB["customFontShadowOff"] and L["Disabled"] or L["Enabled"]))
                else
                    BetterBlizzPlatesDB["customFontOutline"] = "THINOUTLINE"
                    RefreshTooltip(enableCustomFontOutline, L["Font_Outline"],
                        string.format(L["Tooltip_Font_Outline_Toggle_Desc"], L["Thin_Outline"],
                        BetterBlizzPlatesDB["customFontShadowOff"] and L["Disabled"] or L["Enabled"]))
                end
            end
            BBP.RefreshAllNameplates()
        end
    end)


    local textureDropdown = CreateTextureDropdown(
        "textureDropdown",
        useCustomTexture,
        L["Select_Texture"],
        "customTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = 1, label = L["Texture"] }
    )

    local textureDropdownFriendly = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        L["Select_Texture"],
        "customTextureFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = -27, label = L["Friendly"] }
    )

    local textureDropdownSelf = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        L["Select_Texture"],
        "customTextureSelf",
        function(arg1)
            BBP.TexturePRD()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = -55, label = L["Personal"] }
    )

    local textureDropdownSelfMana = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        L["Select_Texture"],
        "customTextureSelfMana",
        function(arg1)
            BBP.TexturePRD()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = -83, label = L["Personal_Mana"] }
    )

    local useCustomTextureForEnemy = CreateCheckbox("useCustomTextureForEnemy", L["Enemy"], useCustomTexture)
    useCustomTextureForEnemy:SetPoint("LEFT", textureDropdown, "RIGHT", 0, 0)
    useCustomTextureForEnemy.text:SetTextColor(1,0,0)
    useCustomTextureForEnemy:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdown:Enable()
        else
            textureDropdown:Disable()
        end
    end)
    CreateTooltipTwo(useCustomTextureForEnemy, L["Enemy_Texture"], L["Tooltip_Enemy_Texture_Desc"], nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForEnemy:GetChecked() then
        textureDropdown:Disable()
    end

    local useCustomTextureForExtraBars = CreateCheckbox("useCustomTextureForExtraBars", L["Overbars"], useCustomTexture)
    useCustomTextureForExtraBars:SetPoint("BOTTOMLEFT", useCustomTextureForEnemy, "TOPLEFT", 0, -3)
    CreateTooltipTwo(useCustomTextureForExtraBars, L["Change_Overbars_Texture"], L["Tooltip_Change_Overbars_Texture_Desc"])

    local useCustomTextureForFriendly = CreateCheckbox("useCustomTextureForFriendly", L["Friendly"], useCustomTexture)
    useCustomTextureForFriendly:SetPoint("LEFT", textureDropdownFriendly, "RIGHT", 0, 0)
    useCustomTextureForFriendly.text:SetTextColor(0.04, 0.76, 1)
    useCustomTextureForFriendly:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownFriendly:Enable()
        else
            textureDropdownFriendly:Disable()
        end
    end)
    CreateTooltipTwo(useCustomTextureForFriendly, L["Friendly_Texture"], L["Tooltip_Friendly_Texture_Desc"], nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForFriendly:GetChecked() then
        textureDropdownFriendly:Disable()
    end

    local useCustomTextureForSelf = CreateCheckbox("useCustomTextureForSelf", L["Self"], useCustomTexture)
    useCustomTextureForSelf:SetPoint("LEFT", textureDropdownSelf, "RIGHT", 0, 0)
    useCustomTextureForSelf:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownSelf:Enable()
        else
            textureDropdownSelf:Disable()
        end
        BBP.TexturePRD()
    end)
    CreateTooltipTwo(useCustomTextureForSelf, L["Personal_Texture"], L["Tooltip_Personal_Texture_Desc"], nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForSelf:GetChecked() then
        textureDropdownSelf:Disable()
    end

    local useCustomTextureForSelfMana = CreateCheckbox("useCustomTextureForSelfMana", L["Self_Mana"], useCustomTexture)
    useCustomTextureForSelfMana:SetPoint("LEFT", textureDropdownSelfMana, "RIGHT", 0, 0)
    useCustomTextureForSelfMana:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownSelfMana:Enable()
        else
            textureDropdownSelfMana:Disable()
        end
        BBP.TexturePRD()
    end)
    CreateTooltipTwo(useCustomTextureForSelfMana, L["Personal_Mana_Resource_Texture"], L["Tooltip_Personal_Mana_Resource_Texture_Desc"], nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForSelfMana:GetChecked() then
        textureDropdownSelfMana:Disable()
    end

    local function SetClassAndPowerColor()
        -- Retrieve the player's class information
        local class = UnitClassBase("player")
        local classColor = RAID_CLASS_COLORS[class]
        -- Retrieve the player's primary power type
        local powerType, powerToken = UnitPowerType("player")
        local powerColor
        if PowerBarColor[powerType] then
            powerColor = PowerBarColor[powerType]
        elseif PowerBarColor[powerToken] then
            powerColor = PowerBarColor[powerToken]
        end
        -- Check if both classColor and powerColor are not nil
        if classColor and powerColor then
            -- Set text color using the class color
            useCustomTextureForSelf.text:SetTextColor(classColor.r, classColor.g, classColor.b)
            -- Set text color using the power color
            useCustomTextureForSelfMana.text:SetTextColor(powerColor.r, powerColor.g, powerColor.b)
        else
            -- Retry after 1 second if either color is nil
            C_Timer.After(1, SetClassAndPowerColor)
        end
    end

    SetClassAndPowerColor()

    useCustomFont:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(enableCustomFontOutline)
            DisableElement(useDefaultBlizzardOutline)
            fontDropdown:Enable()
        else
            fontDropdown:Disable()
            DisableElement(enableCustomFontOutline)
            EnableElement(useDefaultBlizzardOutline)
        end
    end)

    useCustomTexture:HookScript("OnClick", function(self)
        --CheckAndToggleCheckboxes(useCustomTexture)
        if self:GetChecked() then
            EnableElement(useCustomTextureForEnemy)
            EnableElement(useCustomTextureForExtraBars)
            EnableElement(useCustomTextureForFriendly)
            EnableElement(useCustomTextureForSelf)
            EnableElement(useCustomTextureForSelfMana)
            if useCustomTextureForEnemy:GetChecked() then
                textureDropdown:Enable()
            end
            if useCustomTextureForFriendly:GetChecked() then
                textureDropdownFriendly:Enable()
            end
            if useCustomTextureForSelf:GetChecked() then
                textureDropdownSelf:Enable()
            end
            if useCustomTextureForSelfMana:GetChecked() then
                textureDropdownSelfMana:Enable()
            end
        else
            DisableElement(useCustomTextureForEnemy)
            DisableElement(useCustomTextureForExtraBars)
            DisableElement(useCustomTextureForFriendly)
            DisableElement(useCustomTextureForSelf)
            DisableElement(useCustomTextureForSelfMana)
            textureDropdown:Disable()
            textureDropdownFriendly:Disable()
            textureDropdownSelf:Disable()
            textureDropdownSelfMana:Disable()
        end
        BBP.TexturePRD()
    end)


    ----------------------
    -- Arena
    ----------------------
    local arenaSettingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaSettingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, 30)
    arenaSettingsText:SetText(L["Arena_Names"])
    arenaSettingsText:SetFont(fontLarge, 16)
    arenaSettingsText:SetTextColor(1,1,1)
    local arenaSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    arenaSettingsIcon:SetAtlas("pvptalents-warmode-swords")
    arenaSettingsIcon:SetSize(20, 20)
    arenaSettingsIcon:SetPoint("RIGHT", arenaSettingsText, "LEFT", -3, 0)
    CreateTooltipTwo(arenaSettingsText, L["Arena_ID_Spec_Name"], L["Tooltip_Arena_ID_Spec_Name_Desc"], L["Tooltip_Arena_ID_Spec_Name_SubText"], "ANCHOR_LEFT")

    local arenaModeDropdown = CreateModeDropdown(
        "arenaModeDropdown",
        BetterBlizzPlates,
        L["Select_A_Mode_To_Use"],
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSettingsText, x = -90, y = -33, label = L["Mode"] },
        GetIndicatorModes("arenaIndicatorMode"),
        L["Enemy"],
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(arenaModeDropdown, L["Arena_ID_Spec_Name"], L["Tooltip_Arena_ID_Spec_Name_Desc"], L["Tooltip_Arena_ID_Spec_Name_SubText"], "ANCHOR_LEFT")

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", L["Short"], BetterBlizzPlates)
    shortArenaSpecName:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)
    CreateTooltipTwo(shortArenaSpecName, L["Short_Spec_Names"], L["Tooltip_Short_Spec_Names_Desc"], nil, "ANCHOR_LEFT")

    local healerSpecNameOnly = CreateCheckbox("healerSpecNameOnly", L["Heal"], BetterBlizzPlates)
    healerSpecNameOnly:SetPoint("LEFT", shortArenaSpecName.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(healerSpecNameOnly, L["Healer_Spec_Only"], L["Tooltip_Healer_Spec_Only_Desc"], nil, "ANCHOR_LEFT")

    local arenaIndicatorBg = CreateCheckbox("arenaIndicatorBg", "BG", BetterBlizzPlates)
    arenaIndicatorBg:SetPoint("LEFT", healerSpecNameOnly.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(arenaIndicatorBg, L["Battleground_Spec_Names"], L["Tooltip_Battleground_Spec_Names_Desc"], nil, "ANCHOR_LEFT")

    local arenaIndicatorTestMode = CreateCheckbox("arenaIndicatorTestMode", L["Test"], BetterBlizzPlates)
    arenaIndicatorTestMode:SetPoint("LEFT", arenaIndicatorBg.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(arenaIndicatorTestMode, L["Test_Arena_ID_Spec"], L["Tooltip_Test_Arena_ID_Spec_Desc"], nil, "ANCHOR_LEFT")

    local arenaIDScale = CreateSlider(BetterBlizzPlates, L["Arena_ID_Size"], 0.5, 4, 0.01, "arenaIDScale")
    arenaIDScale:SetPoint("TOPLEFT", arenaModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltipTwo(arenaIDScale, L["Arena_ID_Size"], L["Tooltip_Arena_ID_Size_Desc"])

    local arenaSpecScale = CreateSlider(BetterBlizzPlates, L["Spec_Size"], 0.5, 3, 0.01, "arenaSpecScale")
    arenaSpecScale:SetPoint("TOPLEFT", arenaIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltipTwo(arenaSpecScale, L["Arena_Spec_Size"], L["Tooltip_Arena_Spec_Size_Desc"])

    local partyModeDropdown = CreateModeDropdown(
        "partyModeDropdown",
        BetterBlizzPlates,
        L["Select_A_Mode_To_Use"],
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSettingsText, x = 70, y = -33, label = L["Mode"] },
        GetIndicatorModes("partyIndicatorMode"),
        L["Friendly"],
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(partyModeDropdown, L["Arena_ID_Spec_Name"], L["Tooltip_Arena_ID_Spec_Name_Desc"], L["Tooltip_Arena_ID_Spec_Name_SubText"], "ANCHOR_LEFT")
    BBP.arenaModeDropdowns = { arenaModeDropdown, partyModeDropdown }

    local partyIDScale = CreateSlider(BetterBlizzPlates, L["Party_ID_Size"], 0.5, 4, 0.01, "partyIDScale")
    partyIDScale:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltipTwo(partyIDScale, L["Arena_ID_Size"], L["Tooltip_Arena_ID_Size_Desc_2"])

    local partySpecScale = CreateSlider(BetterBlizzPlates, L["Spec_Size"], 0.5, 3, 0.01, "partySpecScale")
    partySpecScale:SetPoint("TOPLEFT", partyIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltipTwo(partySpecScale, L["Arena_Spec_Size"], L["Tooltip_Arena_Spec_Size_Desc_2"])

    local btnGap = -1
    local lastCoreButton = profilesFrame.coreText
    local lastStreamerButton = profilesFrame.streamerText
    local profileButtons = {}

    for _, profile in ipairs(BBP.ProfileData) do
        local additionalNote = profile.name == "Starter" and "|cff808080" .. L["Popup_Starter_Reset_Note"] .. "|r\n\n" or nil
        local button = CreateClassButton(BetterBlizzPlates, profile.class, profile.name, profile.twitchName, function()
            ShowProfileConfirmation(profile.name, profile.class, function() BBP.ApplyProfile(profile.name) end, additionalNote)
        end, profile.youtubeName)
        table.insert(profileButtons, button)
        if profilesFrame.twoColumn then
            button:SetScale(profile.core and 1.05 or 0.9)
        end
        if profile.core then
            button:SetPoint("TOP", lastCoreButton, "BOTTOM", 0, lastCoreButton == profilesFrame.coreText and -3 or btnGap)
            lastCoreButton = button
        elseif profilesFrame.twoColumn then
            button:SetSize(82, 24)
            button:SetText((CLASS_COLORS[profile.class] or "|cffffffff")..profile.name.."|r")
            if lastStreamerButton ~= profilesFrame.streamerText and not lastStreamerButton.rowPartner then
                button:SetPoint("LEFT", lastStreamerButton, "RIGHT", 1, 0)
                lastStreamerButton.rowPartner = button
            else
                button:SetPoint("TOPRIGHT", lastStreamerButton, lastStreamerButton == profilesFrame.streamerText and "BOTTOM" or "BOTTOMRIGHT", 0, lastStreamerButton == profilesFrame.streamerText and -3 or -1)
                lastStreamerButton = button
            end
        else
            button:SetPoint("TOP", lastStreamerButton, "BOTTOM", 0, lastStreamerButton == profilesFrame.streamerText and -3 or btnGap)
            lastStreamerButton = button
        end
    end

    if profilesFrame.twoColumn then
        profilesFrame.streamerText:ClearAllPoints()
        profilesFrame.streamerText:SetPoint("TOP", lastCoreButton, "BOTTOM", 0, -12)
    end

    local resetBBPButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    resetBBPButton:SetText(L["Full_Reset"])
    resetBBPButton:SetWidth(104)
    resetBBPButton:SetPoint("BOTTOM", profilesFrame, "BOTTOM", 2, 15)
    resetBBPButton:SetScript("OnClick", function()
        BBP.ShowPopup("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    end)
    CreateTooltip(resetBBPButton, L["Tooltip_Reset_ALL_BetterBlizzPlates_Settings"], "ANCHOR_TOP")
    table.insert(profileButtons, resetBBPButton)
    profilesFrame.infoText:ClearAllPoints()
    profilesFrame.infoText:SetPoint("BOTTOM", resetBBPButton, "TOP", 0, 6)

    profilesFrame:HookScript("OnShow", function()
        for _, button in ipairs(profileButtons) do
            button:Show()
        end
    end)
    profilesFrame:HookScript("OnHide", function()
        for _, button in ipairs(profileButtons) do
            button:Hide()
        end
    end)

    if BetterBlizzPlatesDB.profilesPanelClosed then
        profilesFrame:Hide()
        for _, button in ipairs(profileButtons) do
            button:Hide()
        end
    end




    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    reloadUiButton:SetText(L["Reload_UI"])
    reloadUiButton:SetWidth(96)
    reloadUiButton:SetPoint("RIGHT", SettingsPanel.CloseButton, "LEFT", -btnGap, 0)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    -- if not SettingsPanel.CloseButton.origPoint then
    --     SettingsPanel.CloseButton.origPoint, SettingsPanel.CloseButton.origRel, SettingsPanel.CloseButton.origAnchor, SettingsPanel.CloseButton.origX, SettingsPanel.CloseButton.origY = SettingsPanel.CloseButton:GetPoint()
    -- end
    -- SettingsPanel.CloseButton:ClearAllPoints()
    -- SettingsPanel.CloseButton:SetPoint("TOPRIGHT", BetterBlizzPlates, "BOTTOMRIGHT", 6, -41)
    -- BetterBlizzPlates:HookScript("OnShow", function()
    --     SettingsPanel.CloseButton:ClearAllPoints()
    --     SettingsPanel.CloseButton:SetPoint("TOPRIGHT", BetterBlizzPlates, "BOTTOMRIGHT", 6, -41)
    -- end)
    -- BetterBlizzPlates:HookScript("OnHide", function()
    --     if BetterBlizzFrames and BetterBlizzFrames:IsShown() then return end
    --     SettingsPanel.CloseButton:ClearAllPoints()
    --     SettingsPanel.CloseButton:SetPoint(SettingsPanel.CloseButton.origPoint, SettingsPanel.CloseButton.origRel, SettingsPanel.CloseButton.origAnchor, SettingsPanel.CloseButton.origX, SettingsPanel.CloseButton.origY)
    -- end)
end

local function guiForever()
    local guiForever = CreateFrame("Frame")
    guiForever.name = "FOREVER"
    guiForever.parent = BetterBlizzPlates.name
    local guiForeverCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiForever, guiForever.name)
    BBP.guiForever = guiForever.name
    BBP.category.guiForeverCategory = guiForeverCategory.ID
    CreateTitle(guiForever)

    local bgImg = guiForever:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiForever, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local headerText = guiForever:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    headerText:SetPoint("TOP", guiForever, "TOP", -8, -100)
    headerText:SetText("|cffffd100" .. L["Forever_In_Development"] .. "|r")

    local bodyText = guiForever:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    bodyText:SetPoint("TOP", headerText, "BOTTOM", 0, -20)
    bodyText:SetWidth(500)
    bodyText:SetJustifyH("CENTER")
    bodyText:SetSpacing(6)
    bodyText:SetText(L["The_WoW_Forever_Version_Of_BetterBlizzPlates_Is_Under"])

    local discordLinkEditBox = CreateFrame("EditBox", nil, guiForever, "InputBoxTemplate")
    discordLinkEditBox:SetPoint("TOP", bodyText, "BOTTOM", 0, -30)
    discordLinkEditBox:SetSize(180, 20)
    discordLinkEditBox:SetAutoFocus(false)
    discordLinkEditBox:SetFontObject("ChatFontNormal")
    discordLinkEditBox:SetText("https://discord.gg/cjqVaEMm25")
    discordLinkEditBox:SetCursorPosition(0)
    discordLinkEditBox:ClearFocus()
    discordLinkEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    discordLinkEditBox:SetScript("OnTextChanged", function(self)
        self:SetText("https://discord.gg/cjqVaEMm25")
    end)
    discordLinkEditBox:SetScript("OnCursorChanged", function() end)
    discordLinkEditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    discordLinkEditBox:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)
end

local function CreateMoreOptionsPopup(owner, contentFrame, subPanel, title, tooltip, width)
    owner.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    owner.extendedSettingsButton:SetSize(120, 25)
    owner.extendedSettingsButton:SetText(L["More_Options"])
    if tooltip then
        CreateTooltip(owner.extendedSettingsButton, tooltip)
    end

    local popup = CreateFrame("Frame", nil, subPanel, "DefaultPanelFlatTemplate")
    owner.extendedSettings = popup
    popup:SetSize(width, 200)
    popup:SetPoint("TOP", owner, "TOP", 0, 40)
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(550)
    popup:SetIgnoreParentAlpha(true)
    popup:EnableMouse(true)
    popup:Hide()
    popup.name = L["Module_Name_Advanced"]
    popup:SetTitle(title)
    popup:SetMovable(true)
    popup:SetClampedToScreen(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    popup.closeButton = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    popup.closeButton:SetFrameLevel((popup.TitleContainer or popup):GetFrameLevel() + 10)
    popup.closeButton:SetPoint("TOPRIGHT", popup, "TOPRIGHT", 0, 0)
    popup.closeButton:SetScript("OnClick", function()
        popup:Hide()
        contentFrame:SetAlpha(1)
    end)

    popup.bg = popup:CreateTexture(nil, "BACKGROUND")
    popup.bg:SetPoint("TOPLEFT", popup, "TOPLEFT", 7, -3)
    popup.bg:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -3, 3)
    popup.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    owner.extendedSettingsButton:HookScript("OnClick", function()
        popup:SetShown(not popup:IsShown())
        contentFrame:SetAlpha(popup:IsShown() and 0.5 or 1)
    end)

    popup.columns = {}
    function popup.Column(x)
        local col = { y = -32 }
        table.insert(popup.columns, col)
        function col.Header(text)
            if col.started then
                col.y = col.y - 10
            end
            col.started = true
            local header = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            header:SetPoint("TOPLEFT", popup, "TOPLEFT", x + 2, col.y)
            header:SetText(text)
            col.y = col.y - 14
            return header
        end
        function col.Add(widget, offsetX)
            widget:ClearAllPoints()
            widget:SetPoint("TOPLEFT", popup, "TOPLEFT", x + (offsetX or 0), col.y)
            col.y = col.y - 19
        end
        function col.Slider(slider, scale)
            scale = scale or 1
            col.y = col.y - 16 * scale
            slider:SetScale(scale)
            slider:ClearAllPoints()
            slider:SetPoint("TOPLEFT", popup, "TOPLEFT", (x + 6) / scale, col.y / scale)
            col.y = col.y - 22 * scale
        end
        function col.Gap(height)
            col.y = col.y - height
        end
        return col
    end
    function popup.Fit()
        local bottom = 0
        for _, col in ipairs(popup.columns) do
            bottom = math.min(bottom, col.y)
        end
        popup:SetHeight(-bottom + 17)
    end

    return popup
end

local function CreateFeatureToggle(owner, isEnabled, toggle)
    local button = CreateFrame("Button", nil, owner:GetParent())
    button:SetSize(35, 35)
    button:SetPoint("CENTER", owner, "CENTER", -64, 32)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()

    function button:Refresh()
        local enabled = isEnabled() and true or false
        self.icon:SetAtlas(enabled and "PlayerFriend" or "PlayerEnemy")
        self.icon:SetDesaturated(not enabled)
        if GameTooltip:IsOwned(self) then
            self:GetScript("OnEnter")(self)
        end
    end

    button:SetScript("OnClick", function(self)
        toggle()
        self:Refresh()
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, isEnabled() and L["Feature_Enabled_Click_To_Disable"] or L["Feature_Disabled_Click_To_Enable"], HIGHLIGHT_FONT_COLOR, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:Refresh()
    return button
end

local function guiPositionAndScale()
    ----------------------
    -- Advanced settings
    ----------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -380
    local thirdLineX = 391
    local thirdLineY = -695
    local fourthLineX = 560
    local fourthLineY = -1010
    local fifthLineY = -1325

    local BetterBlizzPlatesSubPanel = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel.name = L["Module_Name_Advanced"]
    BetterBlizzPlatesSubPanel.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel)
    local guiPositionAndScaleCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, BetterBlizzPlatesSubPanel, BetterBlizzPlatesSubPanel.name)
    CreateTitle(BetterBlizzPlatesSubPanel)

    local bgImg = BetterBlizzPlatesSubPanel:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzPlatesSubPanel, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzPlatesSubPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzPlatesSubPanel, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame.name = BetterBlizzPlatesSubPanel.name
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

    ---------------------------
    -- Healer indicator
    ---------------------------
    local anchorSubHeal = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHeal:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, thirdLineY)
    anchorSubHeal:SetText(L["Healer_Indicator"])

    CreateBorderBox(anchorSubHeal)

    local healerCrossIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    healerCrossIcon2:SetAtlas("greencross")
    healerCrossIcon2:SetSize(29, 29)
    healerCrossIcon2:SetPoint("BOTTOM", anchorSubHeal, "TOP", 0, 3)
    healerCrossIcon2:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local healerIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.6, 2.5, 0.01, "healerIndicatorScale", false, 72)
    healerIndicatorScale:SetPoint("TOP", anchorSubHeal, "BOTTOM", 36, -15)
    healerIndicatorScale.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltipTwo(healerIndicatorScale, L["Friendly_Scale"])

    local healerIndicatorEnemyScale = CreateSlider(contentFrame, L["Size"], 0.6, 2.5, 0.01, "healerIndicatorEnemyScale", false, 72)
    healerIndicatorEnemyScale:SetPoint("TOP", anchorSubHeal, "BOTTOM", -36, -15)
    healerIndicatorEnemyScale.Text:SetTextColor(1,0,0)
    CreateTooltipTwo(healerIndicatorEnemyScale, L["Enemy_Scale"])

    local healerIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "healerIndicatorXPos", "X", 72)
    healerIndicatorXPos:SetPoint("TOP", healerIndicatorScale, "BOTTOM", 0, -15)
    healerIndicatorXPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltipTwo(healerIndicatorXPos, L["Friendly_X_Offset"])

    local healerIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "healerIndicatorYPos", "Y", 72)
    healerIndicatorYPos:SetPoint("TOP", healerIndicatorXPos, "BOTTOM", 0, -15)
    healerIndicatorYPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltipTwo(healerIndicatorYPos, L["Friendly_Y_Offset"])

    local healerIndicatorEnemyXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "healerIndicatorEnemyXPos", "X", 72)
    healerIndicatorEnemyXPos:SetPoint("TOP", healerIndicatorEnemyScale, "BOTTOM", 0, -15)
    healerIndicatorEnemyXPos.Text:SetTextColor(1,0,0)
    CreateTooltipTwo(healerIndicatorEnemyXPos, L["Enemy_X_Offset"])

    local healerIndicatorEnemyYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "healerIndicatorEnemyYPos", "Y", 72)
    healerIndicatorEnemyYPos:SetPoint("TOP", healerIndicatorEnemyXPos, "BOTTOM", 0, -15)
    healerIndicatorEnemyYPos.Text:SetTextColor(1,0,0)
    CreateTooltipTwo(healerIndicatorEnemyYPos, L["Enemy_Y_Offset"])

    local healerIndicatorDropdown = CreateAnchorDropdown(
        "healerIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "healerIndicatorEnemyAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = healerIndicatorYPos, x = -90, y = -35, label = L["Enemy"] },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltip(healerIndicatorDropdown, L["Tooltip_Enemy_Anchor"])

    local healerIndicatorDropdown2 = CreateAnchorDropdown(
        "healerIndicatorDropdown2",
        contentFrame,
        L["Select_Anchor_Point"],
        "healerIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = healerIndicatorYPos, x = -16, y = -35, label = L["Friendly"] },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltip(healerIndicatorDropdown2, L["Tooltip_Friendly_Anchor"])

    local healerIndicatorTestMode2 = CreateCheckbox("healerIndicatorTestMode", L["Test"], contentFrame)
    healerIndicatorTestMode2:SetPoint("TOPLEFT", healerIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local moreCol
    CreateMoreOptionsPopup(anchorSubHeal, contentFrame, BetterBlizzPlatesSubPanel, L["Healer_Indicator"], nil, 240)
    anchorSubHeal.extendedSettingsButton:SetPoint("TOPLEFT", healerIndicatorTestMode2, "BOTTOMLEFT", 12, -8)

    local healerIndicatorEnemyOnly2 = CreateCheckbox("healerIndicatorEnemyOnly", L["Enemies_Only"], anchorSubHeal.extendedSettings)

    local healerIndicatorArenaOnly = CreateCheckbox("healerIndicatorArenaOnly", L["Arena_Only"], anchorSubHeal.extendedSettings)

    local healerIndicatorBgOnly = CreateCheckbox("healerIndicatorBgOnly", L["Battleground_Only"], anchorSubHeal.extendedSettings)

    local healerIndicatorRedCrossEnemy = CreateCheckbox("healerIndicatorRedCrossEnemy", L["Red_Cross_For_Enemy"], anchorSubHeal.extendedSettings)

    anchorSubHeal.healerIndicatorColorEnemyHealthbar = CreateCheckbox("healerIndicatorColorEnemyHealthbar", L["Color_Enemy_Healer_HP"], anchorSubHeal.extendedSettings)
    CreateTooltipTwo(anchorSubHeal.healerIndicatorColorEnemyHealthbar, L["Color_Enemy_Healer_Healthbar"], L["Tooltip_Color_Enemy_Healer_Healthbar_Desc"])

    anchorSubHeal.healerIndicatorColorFriendlyHealthbar = CreateCheckbox("healerIndicatorColorFriendlyHealthbar", L["Color_Friendly_Healer_HP"], anchorSubHeal.extendedSettings)
    CreateTooltipTwo(anchorSubHeal.healerIndicatorColorFriendlyHealthbar, L["Color_Friendly_Healer_Healthbar"], L["Tooltip_Color_Friendly_Healer_Healthbar_Desc"])

    local function OpenHealerEnemyColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB or {0, 1, 0})
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                anchorSubHeal.healerIndicatorColorEnemyHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB))
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                anchorSubHeal.healerIndicatorColorEnemyHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB))
            end,
        })
    end

    local function OpenHealerFriendlyColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB or {0, 1, 0})
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                anchorSubHeal.healerIndicatorColorFriendlyHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB))
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                anchorSubHeal.healerIndicatorColorFriendlyHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB))
            end,
        })
    end

    anchorSubHeal.healerIndicatorColorEnemyHealthbar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenHealerEnemyColorPicker()
        end
    end)
    anchorSubHeal.healerIndicatorColorFriendlyHealthbar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenHealerFriendlyColorPicker()
        end
    end)

    if BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbar then
        anchorSubHeal.healerIndicatorColorEnemyHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB or {0, 1, 0}))
    end
    if BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbar then
        anchorSubHeal.healerIndicatorColorFriendlyHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB or {0, 1, 0}))
    end

    moreCol = anchorSubHeal.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(healerIndicatorEnemyOnly2)
    moreCol.Add(healerIndicatorArenaOnly)
    moreCol.Add(healerIndicatorBgOnly)
    moreCol.Header(L["Icon"])
    moreCol.Add(healerIndicatorRedCrossEnemy)
    moreCol.Header(L["Healthbar"])
    moreCol.Add(anchorSubHeal.healerIndicatorColorEnemyHealthbar)
    moreCol.Add(anchorSubHeal.healerIndicatorColorFriendlyHealthbar)
    anchorSubHeal.extendedSettings.Fit()

    ----------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY)
    anchorSubOutOfCombat:SetText(L["Combat_Indicator"])

    CreateBorderBox(anchorSubOutOfCombat)

    local combatIconSub = contentFrame:CreateTexture(nil, "ARTWORK")
    if BetterBlizzPlatesDB.combatIndicatorSap then
        combatIconSub:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
        combatIconSub:SetSize(38, 38)
        combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 0)
    else
        combatIconSub:SetAtlas("food")
        combatIconSub:SetSize(40, 40)
        combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", -1, 0)
    end

    local combatIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "combatIndicatorScale")
    combatIndicatorScale:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)

    local combatIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "combatIndicatorXPos", "X")
    combatIndicatorXPos:SetPoint("TOP", combatIndicatorScale, "BOTTOM", 0, -15)

    local combatIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "combatIndicatorYPos", "Y")
    combatIndicatorYPos:SetPoint("TOP", combatIndicatorXPos, "BOTTOM", 0, -15)

    local combatIndicatorDropdown = CreateAnchorDropdown(
        "combatIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "combatIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = combatIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local combatIndicatorEnemyOnly = CreateCheckbox("combatIndicatorEnemyOnly", L["Enemies_Only"], contentFrame)
    combatIndicatorEnemyOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local combatIndicatorArenaOnly = CreateCheckbox("combatIndicatorArenaOnly", L["In_Arena_Only"], contentFrame)
    combatIndicatorArenaOnly:SetPoint("TOPLEFT", combatIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local combatIndicatorSap = CreateCheckbox("combatIndicatorSap", L["Use_Sap_Icon_Instead"], contentFrame)
    combatIndicatorSap:SetPoint("TOPLEFT", combatIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    combatIndicatorSap:HookScript("OnClick", function(self)
        if self:GetChecked() then
            combatIconSub:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
            combatIconSub:SetSize(38, 38)
            combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 0)
        else
            combatIconSub:SetAtlas("food")
            combatIconSub:SetSize(42, 42)
            combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", -1, 0)
        end
    end)

    local combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", L["On_Players_Only"], contentFrame)
    combatIndicatorPlayersOnly:SetPoint("TOPLEFT", combatIndicatorSap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    ----------------------
    -- Hunter pet icon
    ----------------------
    local anchorSubPet = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPet:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, fourthLineY)
    anchorSubPet:SetText(L["Pet_Indicator"])

    CreateBorderBox(anchorSubPet)

    local petIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    petIndicator2:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicator2:SetSize(36, 36)
    petIndicator2:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

    local petIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "petIndicatorScale")
    petIndicatorScale:SetPoint("TOP", anchorSubPet, "BOTTOM", 0, -15)

    local petIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "petIndicatorXPos", "X")
    petIndicatorXPos:SetPoint("TOP", petIndicatorScale, "BOTTOM", 0, -15)

    local petIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "petIndicatorYPos", "Y")
    petIndicatorYPos:SetPoint("TOP", petIndicatorXPos, "BOTTOM", 0, -15)

    local petIndicatorDropdown = CreateAnchorDropdown(
        "petIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "petIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = petIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    anchorSubPet.petIndicatorTestMode2 = CreateCheckbox("petIndicatorTestMode", L["Test"], contentFrame)
    anchorSubPet.petIndicatorTestMode2:SetPoint("TOPLEFT", petIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    anchorSubPet.petIndicatorHideSecondaryPets = CreateCheckbox("petIndicatorHideSecondaryPets", L["Hide_Secondary_Pets"], contentFrame)
    anchorSubPet.petIndicatorHideSecondaryPets:SetPoint("TOPLEFT", anchorSubPet.petIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPet.petIndicatorHideSecondaryPets, L["Hide_Secondary_Pets"], L["Tooltip_Hide_Secondary_Pets_Desc"])

    anchorSubPet.petIndicatorShowMurloc = CreateCheckbox("petIndicatorShowMurloc", L["Murloc_Secondary_Pets"], anchorSubPet.petIndicatorHideSecondaryPets)
    anchorSubPet.petIndicatorShowMurloc:SetPoint("TOPLEFT", anchorSubPet.petIndicatorHideSecondaryPets, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPet.petIndicatorShowMurloc, L["Murloc_Secondary_Pets"], L["Tooltip_Murloc_Secondary_Pets_Desc"])
    anchorSubPet.petIndicatorShowMurloc:HookScript("OnClick", function(self)
        if self:GetChecked() then
            if not anchorSubPet.petIndicatorHideSecondaryPets:GetChecked() then
                anchorSubPet.petIndicatorHideSecondaryPets:Click()
            end
        end
    end)

    anchorSubPet.petIndicatorHideSecondaryPets:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)


    anchorSubPet.petIndicatorColorHealthbar = CreateCheckbox("petIndicatorColorHealthbar", L["Color_Main_Pet_HP"], contentFrame)
    anchorSubPet.petIndicatorColorHealthbar:SetPoint("TOPLEFT", anchorSubPet.petIndicatorShowMurloc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPet.petIndicatorColorHealthbar, L["Color_Main_Pet_Healthbar"], L["Tooltip_Color_Main_Pet_Healthbar_Desc"])
    local function OpenColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                anchorSubPet.petIndicatorColorHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB))
                if BetterBlizzPlatesDB.targetIndicatorColorName then
                    anchorSubPet.petIndicatorColorHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB))
                end
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                anchorSubPet.petIndicatorColorHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB))
                if BetterBlizzPlatesDB.targetIndicatorColorName then
                    anchorSubPet.petIndicatorColorHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB))
                end
            end,
        })
    end

    anchorSubPet.petIndicatorColorHealthbar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorPicker()
        end
    end)

    if BetterBlizzPlatesDB.petIndicatorColorHealthbar then
        anchorSubPet.petIndicatorColorHealthbar.Text:SetTextColor(unpack(BetterBlizzPlatesDB.petIndicatorColorHealthbarRGB))
    end

    -- anchorSubPet.petHealthColor = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    -- anchorSubPet.petHealthColor:SetText("Color")
    -- anchorSubPet.petHealthColor:SetPoint("LEFT", anchorSubPet.petIndicatorColorHealthbar.text, "RIGHT", -1, 0)
    -- anchorSubPet.petHealthColor:SetSize(43, 18)
    -- anchorSubPet.petHealthColor:SetScript("OnClick", OpenColorPicker)

    ----------------------
    -- Absorb Indicator
    ----------------------
    local anchorSubAbsorb = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubAbsorb:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY)
    anchorSubAbsorb:SetText(L["Absorb_Indicator"])

    CreateBorderBox(anchorSubAbsorb)

    local absorbIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator2:SetAtlas("ParagonReputation_Glow")
    absorbIndicator2:SetSize(51, 51)
    absorbIndicator2:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

    local absorbIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "absorbIndicatorScale")
    absorbIndicatorScale:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)

    local absorbIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "absorbIndicatorXPos", "X")
    absorbIndicatorXPos:SetPoint("TOP", absorbIndicatorScale, "BOTTOM", 0, -15)

    local absorbIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "absorbIndicatorYPos", "Y")
    absorbIndicatorYPos:SetPoint("TOP", absorbIndicatorXPos, "BOTTOM", 0, -15)

    local absorbIndicatorDropdown = CreateAnchorDropdown(
        "absorbIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "absorbIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = absorbIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local absorbIndicatorTestMode2 = CreateCheckbox("absorbIndicatorTestMode", L["Test"], contentFrame)
    absorbIndicatorTestMode2:SetPoint("TOPLEFT", absorbIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local absorbIndicatorEnemyOnly = CreateCheckbox("absorbIndicatorEnemyOnly", L["Enemies_Only"], contentFrame)
    absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", absorbIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local absorbIndicatorOnPlayersOnly = CreateCheckbox("absorbIndicatorOnPlayersOnly", L["Players_Only"], contentFrame)
    absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    ----------------------
    -- Faction Indicator
    ----------------------
    local anchorSubFaction = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFaction:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, secondLineY)
    anchorSubFaction:SetText(L["Faction_Indicator"])

    CreateBorderBox(anchorSubFaction)

    anchorSubFaction.factionIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFaction.factionIcon2:SetAtlas("questlog-questtypeicon-alliance")
    anchorSubFaction.factionIcon2:SetSize(34, 34)
    anchorSubFaction.factionIcon2:SetPoint("BOTTOM", anchorSubFaction, "TOP", 0, 0)

    anchorSubFaction.factionIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 3, 0.01, "factionIndicatorScale")
    anchorSubFaction.factionIndicatorScale:SetPoint("TOP", anchorSubFaction, "BOTTOM", 0, -15)

    anchorSubFaction.factionIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "factionIndicatorXPos", "X")
    anchorSubFaction.factionIndicatorXPos:SetPoint("TOP", anchorSubFaction.factionIndicatorScale, "BOTTOM", 0, -15)

    anchorSubFaction.factionIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "factionIndicatorYPos", "Y")
    anchorSubFaction.factionIndicatorYPos:SetPoint("TOP", anchorSubFaction.factionIndicatorXPos, "BOTTOM", 0, -15)

    anchorSubFaction.factionIndicatorDropdown = CreateAnchorDropdown(
        "factionIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "factionIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubFaction.factionIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    -- Icon Set dropdown
    anchorSubFaction.factionIconSetNames = {
        [1]  = L["Faction_Icons_Quest_Log"],
        [2]  = L["Faction_Icons_UnitFrame"],
        [3]  = L["Faction_Icons_PVP_Banners"],
        [4]  = L["Faction_Icons_BFA_Landing"],
        [5]  = L["Faction_Icons_Talent_Tree"],
        [6]  = L["Faction_Icons_CTF_Flags"],
        [7]  = L["Faction_Icons_Quest_Portrait"],
        [8]  = L["Faction_Icons_Quest_Portrait_Small"],
        [9]  = L["Faction_Icons_Character_Create"],
        [10] = L["Faction_Icons_Character_Create_Small"],
        [11] = L["Faction_Icons_Warfront_Armory"],
        [12] = L["Faction_Icons_Wax_Seals"],
    }

    anchorSubFaction.factionIconSetDropdown = CreateLegacySizedDropdown(contentFrame, 125)
    anchorSubFaction.factionIconSetDropdown:SetDefaultText(L["Faction_Icons_Quest_Log"])
    anchorSubFaction.factionIconSetDropdown:SetupMenu(function(_, rootDescription)
        for i = 1, 12 do
            rootDescription:CreateRadio(anchorSubFaction.factionIconSetNames[i], function()
                return (BetterBlizzPlatesDB.factionIndicatorIconSet or 1) == i
            end, function()
                BetterBlizzPlatesDB.factionIndicatorIconSet = i
                BBP.needsUpdate = true
                BBP.RefreshAllNameplates()
            end)
        end
    end)

    anchorSubFaction.factionIconSetDropdown:SetPoint("TOPLEFT", anchorSubFaction.factionIndicatorDropdown, "TOPLEFT", 0, -43)

    anchorSubFaction.factionIconSetLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFaction.factionIconSetLabel:SetPoint("BOTTOM", anchorSubFaction.factionIconSetDropdown, "TOP", 0, 3)
    anchorSubFaction.factionIconSetLabel:SetText(L["Icon_Set"])

    anchorSubFaction.factionIndicatorTestMode2 = CreateCheckbox("factionIndicatorTestMode", L["Test"], contentFrame)
    anchorSubFaction.factionIndicatorTestMode2:SetPoint("TOPLEFT", anchorSubFaction.factionIconSetDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    CreateMoreOptionsPopup(anchorSubFaction, contentFrame, BetterBlizzPlatesSubPanel, L["Faction_Indicator"], nil, 220)
    anchorSubFaction.extendedSettingsButton:SetPoint("TOPLEFT", anchorSubFaction.factionIndicatorTestMode2, "BOTTOMLEFT", 12, -8)

    anchorSubFaction.factionIndicatorEnemy = CreateCheckbox("factionIndicatorEnemy", L["Enemy"], anchorSubFaction.extendedSettings)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorEnemy, L["Show_On_Enemies"], L["Tooltip_Show_On_Enemies_Desc"])

    anchorSubFaction.factionIndicatorFriendly = CreateCheckbox("factionIndicatorFriendly", L["Friendly"], anchorSubFaction.extendedSettings)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorFriendly, L["Show_On_Friendly"], L["Tooltip_Show_On_Friendly_Desc"])

    anchorSubFaction.factionIndicatorOnlyWorld = CreateCheckbox("factionIndicatorOnlyWorld", L["World_Only"], anchorSubFaction.extendedSettings)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorOnlyWorld, L["World_Only"], L["Tooltip_World_Only_2_Desc"])
    anchorSubFaction.factionIndicatorOnlyWorld:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.factionIndicatorOnlyPvPZone = false
            anchorSubFaction.factionIndicatorOnlyPvPZone:SetChecked(false)
        end
    end)

    anchorSubFaction.factionIndicatorHostileOnly = CreateCheckbox("factionIndicatorHostileOnly", L["Hostile_Only"], anchorSubFaction.extendedSettings)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorHostileOnly, L["Hostile_Only"], L["Tooltip_Hostile_Only_2_Desc"])

    anchorSubFaction.factionIndicatorPvPTaggedOnly = CreateCheckbox("factionIndicatorPvPTaggedOnly", L["PvP_Tagged_Only"], anchorSubFaction.extendedSettings)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorPvPTaggedOnly, L["PvP_Tagged_Only"], L["Tooltip_PvP_Tagged_Only_2_Desc"])

    anchorSubFaction.factionIndicatorOnlyPvPZone = CreateCheckbox("factionIndicatorOnlyPvPZone", L["PvP_FFA_Only"], anchorSubFaction.extendedSettings)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorOnlyPvPZone, L["PvP_Zone_Only"], L["Tooltip_PvP_Zone_Only_Desc"])
    anchorSubFaction.factionIndicatorOnlyPvPZone:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.factionIndicatorOnlyWorld = false
            anchorSubFaction.factionIndicatorOnlyWorld:SetChecked(false)
        end
    end)

    moreCol = anchorSubFaction.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(anchorSubFaction.factionIndicatorEnemy)
    moreCol.Add(anchorSubFaction.factionIndicatorFriendly)
    moreCol.Add(anchorSubFaction.factionIndicatorHostileOnly)
    moreCol.Add(anchorSubFaction.factionIndicatorOnlyWorld)
    moreCol.Add(anchorSubFaction.factionIndicatorOnlyPvPZone)
    moreCol.Add(anchorSubFaction.factionIndicatorPvPTaggedOnly)
    anchorSubFaction.extendedSettings.Fit()

    ----------------------
    -- Target indicator
    ----------------------
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, fourthLineY)
    anchorSubTarget:SetText(L["Target_Indicator"])

    anchorSubTarget.border = CreateBorderBox(anchorSubTarget)

    anchorSubTarget.icon = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubTarget.icon:SetAtlas("Navigation-Tracked-Arrow")
    anchorSubTarget.icon:SetRotation(math.rad(180))
    anchorSubTarget.icon:SetSize(48, 32)
    anchorSubTarget.icon:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

    local targetIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "targetIndicatorScale")
    targetIndicatorScale:SetPoint("TOP", anchorSubTarget, "BOTTOM", 0, -15)

    local targetIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "targetIndicatorXPos", "X")
    targetIndicatorXPos:SetPoint("TOP", targetIndicatorScale, "BOTTOM", 0, -15)

    local targetIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "targetIndicatorYPos", "Y")
    targetIndicatorYPos:SetPoint("TOP", targetIndicatorXPos, "BOTTOM", 0, -15)

    local targetIndicatorDropdown = CreateAnchorDropdown(
        "targetIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "targetIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = targetIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local targetIndicatorHideIcon = CreateCheckbox("targetIndicatorHideIcon", L["Hide_Target_Marker"], contentFrame)
    targetIndicatorHideIcon:SetPoint("TOPLEFT", targetIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    anchorSubTarget.double = CreateCheckbox("targetIndicatorDouble", L["Double_Markers"], contentFrame)
    anchorSubTarget.double:SetPoint("TOPLEFT", targetIndicatorHideIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubTarget.double, L["Double_Markers"], L["Tooltip_Double_Markers_Desc"])

    anchorSubTarget.anchorToName = CreateCheckbox("targetIndicatorAnchorToName", L["Anchor_To_Name"], contentFrame)
    anchorSubTarget.anchorToName:SetPoint("TOPLEFT", anchorSubTarget.double, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubTarget.anchorToName, L["Anchor_To_Name"], L["Tooltip_Anchor_To_Name_2_Desc"])

    anchorSubTarget.UpdateDoubleState = function()
        if targetIndicatorHideIcon:GetChecked() then
            anchorSubTarget.double:Disable()
            anchorSubTarget.double:SetAlpha(0.5)
        else
            anchorSubTarget.double:Enable()
            anchorSubTarget.double:SetAlpha(1)
        end
    end
    anchorSubTarget.UpdateDoubleState()
    targetIndicatorHideIcon:HookScript("OnClick", anchorSubTarget.UpdateDoubleState)

    -- Extended Settings Button
    anchorSubTarget.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    anchorSubTarget.extendedSettingsButton:SetSize(120, 25)
    anchorSubTarget.extendedSettingsButton:SetPoint("TOPLEFT", anchorSubTarget.anchorToName, "BOTTOMLEFT", 12, -8)
    anchorSubTarget.extendedSettingsButton:SetText(L["More_Options"])
    CreateTooltip(anchorSubTarget.extendedSettingsButton, L["Tooltip_Open_More_Settings_For_Target_Indicator"])

    -- Extended Settings Frame
    anchorSubTarget.extendedSettings = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel, "DefaultPanelFlatTemplate")
    anchorSubTarget.extendedSettings:SetSize(anchorSubTarget.border:GetHeight()+60, 250)
    anchorSubTarget.extendedSettings:SetPoint("BOTTOMRIGHT", anchorSubTarget.border, "BOTTOMLEFT", 87, -65)
    anchorSubTarget.extendedSettings:SetFrameStrata("FULLSCREEN_DIALOG")
    anchorSubTarget.extendedSettings:SetFrameLevel(550)
    anchorSubTarget.extendedSettings:SetIgnoreParentAlpha(true)
    anchorSubTarget.extendedSettings:EnableMouse(true)
    anchorSubTarget.extendedSettings:Hide()
    anchorSubTarget.extendedSettings.name = L["Module_Name_Advanced"]
    anchorSubTarget.extendedSettings:SetTitle(L["Target_Indicator"])
    anchorSubTarget.extendedSettings:SetMovable(true)
    anchorSubTarget.extendedSettings:SetClampedToScreen(true)
    anchorSubTarget.extendedSettings:RegisterForDrag("LeftButton")
    anchorSubTarget.extendedSettings:SetScript("OnDragStart", function(self) self:StartMoving() end)
    anchorSubTarget.extendedSettings:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    anchorSubTarget.closeButton = CreateFrame("Button", nil, anchorSubTarget.extendedSettings, "UIPanelCloseButton")
    anchorSubTarget.closeButton:SetFrameLevel((anchorSubTarget.extendedSettings.TitleContainer or anchorSubTarget.extendedSettings):GetFrameLevel() + 10)
    anchorSubTarget.closeButton:SetPoint("TOPRIGHT", anchorSubTarget.extendedSettings, "TOPRIGHT", 0, 0)
    anchorSubTarget.closeButton:SetScript("OnClick", function()
        anchorSubTarget.extendedSettings:Hide()
        contentFrame:SetAlpha(1)
    end)

    anchorSubTarget.bg = anchorSubTarget.extendedSettings:CreateTexture(nil, "BACKGROUND")
    anchorSubTarget.bg:SetPoint("TOPLEFT", anchorSubTarget.extendedSettings, "TOPLEFT", 7, -3)
    anchorSubTarget.bg:SetPoint("BOTTOMRIGHT", anchorSubTarget.extendedSettings, "BOTTOMRIGHT", -3, 3)
    anchorSubTarget.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    anchorSubTarget.extendedSettingsButton:HookScript("OnClick", function(self)
        anchorSubTarget.extendedSettings:SetShown(not anchorSubTarget.extendedSettings:IsShown())
        contentFrame:SetAlpha(anchorSubTarget.extendedSettings:IsShown() and 0.5 or 1)
    end)

    local targetIndicatorColorNameplate = CreateCheckbox("targetIndicatorColorNameplate", L["Color_Healthbar"], anchorSubTarget.extendedSettings)
    targetIndicatorColorNameplate:SetPoint("TOPLEFT", anchorSubTarget.extendedSettings, "TOPLEFT", 10, -23)

    local targetIndicatorColorName = CreateCheckbox("targetIndicatorColorName", L["Color_Name"], anchorSubTarget.extendedSettings)
    targetIndicatorColorName:SetPoint("TOPLEFT", targetIndicatorColorNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    if BetterBlizzPlatesDB.targetIndicatorColorNameplate then
        targetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
    end

    if BetterBlizzPlatesDB.targetIndicatorColorName then
        targetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
    end

    local function OpenColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                targetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
                if BetterBlizzPlatesDB.targetIndicatorColorName then
                    targetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
                end
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                targetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
                if BetterBlizzPlatesDB.targetIndicatorColorName then
                    targetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
                end
            end,
        })
    end

    local targetColorButton = CreateFrame("Button", nil, anchorSubTarget.extendedSettings, "UIPanelButtonTemplate")
    targetColorButton:SetText(L["Color"])
    targetColorButton:SetPoint("LEFT", targetIndicatorColorNameplate.text, "RIGHT", -1, 0)
    targetColorButton:SetSize(43, 18)
    targetColorButton:SetScript("OnClick", OpenColorPicker)

    targetIndicatorColorName:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.targetIndicatorColorName = self:GetChecked()
        local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
        local frame = nameplateForTarget and nameplateForTarget.UnitFrame
        if BetterBlizzPlatesDB.targetIndicatorColorName then
            targetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
            targetColorButton:Enable()
            targetColorButton:SetAlpha(1)
        else
            targetIndicatorColorName.Text:SetTextColor(1, 0.819607, 0)
            if (not BetterBlizzPlatesDB.targetIndicatorColorName and not BetterBlizzPlatesDB.targetIndicatorColorNameplate) then
                targetColorButton:Disable()
                targetColorButton:SetAlpha(0.5)
            end
        end
        if frame then BBP.TargetIndicator(frame) end
        BBP.RefreshAllNameplates()
    end)

    targetIndicatorColorNameplate:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.targetIndicatorColorNameplate = self:GetChecked()
        local nameplateForTarget = C_NamePlate.GetNamePlateForUnit("target")
        local frame = nameplateForTarget and nameplateForTarget.UnitFrame
        if BetterBlizzPlatesDB.targetIndicatorColorNameplate then
            targetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
            targetColorButton:Enable()
            targetColorButton:SetAlpha(1)
        else
            targetIndicatorColorNameplate.Text:SetTextColor(1, 0.819607, 0)
            if (not BetterBlizzPlatesDB.targetIndicatorColorName and not BetterBlizzPlatesDB.targetIndicatorColorNameplate) then
                targetColorButton:Disable()
                targetColorButton:SetAlpha(0.5)
            end
        end
        if frame then BBP.TargetIndicator(frame) end
        BBP.RefreshAllNameplates()
    end)

    if BetterBlizzPlatesDB.targetIndicatorColorNameplate or BetterBlizzPlatesDB.targetIndicatorColorName then
        targetColorButton:Enable()
        targetColorButton:SetAlpha(1)
    else
        targetColorButton:Disable()
        targetColorButton:SetAlpha(0.5)
    end

    anchorSubTarget.recolorMarker = CreateCheckbox("targetIndicatorRecolor", L["Change_Marker_Color"], anchorSubTarget.extendedSettings)
    anchorSubTarget.recolorMarker:SetPoint("TOPLEFT", targetIndicatorColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubTarget.recolorMarker, L["Change_Marker_Color"], L["Tooltip_Change_Marker_Color_Desc"])

    if BetterBlizzPlatesDB.targetIndicatorRecolor then
        anchorSubTarget.recolorMarker.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorRGB))
    end

    anchorSubTarget.OpenMarkerColorPicker = function()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.targetIndicatorRGB or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.targetIndicatorRGB = { r, g, b }
                BBP.needsUpdate = true
                BBP.RefreshAllNameplates()
                if BetterBlizzPlatesDB.targetIndicatorRecolor then
                    anchorSubTarget.recolorMarker.Text:SetTextColor(r, g, b)
                end
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.targetIndicatorRGB = { r, g, b }
                BBP.needsUpdate = true
                BBP.RefreshAllNameplates()
                if BetterBlizzPlatesDB.targetIndicatorRecolor then
                    anchorSubTarget.recolorMarker.Text:SetTextColor(r, g, b)
                end
            end,
        })
    end

    anchorSubTarget.markerColorButton = CreateFrame("Button", nil, anchorSubTarget.extendedSettings, "UIPanelButtonTemplate")
    anchorSubTarget.markerColorButton:SetText(L["Color"])
    anchorSubTarget.markerColorButton:SetPoint("LEFT", anchorSubTarget.recolorMarker.text, "RIGHT", -1, 0)
    anchorSubTarget.markerColorButton:SetSize(43, 18)
    anchorSubTarget.markerColorButton:SetScript("OnClick", anchorSubTarget.OpenMarkerColorPicker)

    anchorSubTarget.recolorMarker:HookScript("OnClick", function(self)
        if self:GetChecked() then
            anchorSubTarget.recolorMarker.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorRGB))
            anchorSubTarget.markerColorButton:Enable()
            anchorSubTarget.markerColorButton:SetAlpha(1)
        else
            anchorSubTarget.recolorMarker.Text:SetTextColor(1, 0.819607, 0)
            anchorSubTarget.markerColorButton:Disable()
            anchorSubTarget.markerColorButton:SetAlpha(0.5)
        end
    end)

    if BetterBlizzPlatesDB.targetIndicatorRecolor then
        anchorSubTarget.markerColorButton:Enable()
        anchorSubTarget.markerColorButton:SetAlpha(1)
    else
        anchorSubTarget.markerColorButton:Disable()
        anchorSubTarget.markerColorButton:SetAlpha(0.5)
    end

    local targetIndicatorChangeTexture = CreateCheckbox("targetIndicatorChangeTexture", L["Re_Texture_Healthbar"], anchorSubTarget.extendedSettings)
    targetIndicatorChangeTexture:SetPoint("TOPLEFT", anchorSubTarget.recolorMarker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetIndicatorChangeTexture, L["Tooltip_Re_Texture_The_Healthbar_Of_Your"])

    local targetIndicatorTexture = CreateTextureDropdown(
        "targetIndicatorTexture",
        anchorSubTarget.extendedSettings,
        L["Select_Texture"],
        "targetIndicatorTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = targetIndicatorChangeTexture, x = 3, y = 3, label = L["Texture"] },
        138
    )

    targetIndicatorChangeTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetIndicatorTexture:Enable()
        else
            targetIndicatorTexture:Disable()
        end
    end)

    anchorSubTarget.iconDropdown = CreateFrame("DropdownButton", nil, anchorSubTarget.extendedSettings, "WowStyle1DropdownTemplate")
    anchorSubTarget.iconDropdown:SetPoint("TOPLEFT", targetIndicatorTexture, "TOPLEFT", 0, -43)
    anchorSubTarget.iconDropdown:SetWidth(138)
    anchorSubTarget.iconDropdown.Background:SetVertexColor(0.9,0.9,0.9)
    anchorSubTarget.iconDropdown.Arrow:SetVertexColor(0.9,0.9,0.9)
    anchorSubTarget.iconDropdown:SetDefaultText(BBP.GetTargetIndicatorIconText(BBP.GetTargetIndicatorTexture()))
    anchorSubTarget.iconDropdown:SetupMenu(function(dropdown, rootDescription)
        for _, entry in ipairs(BBP.targetIndicatorTextures) do
            rootDescription:CreateButton(BBP.GetTargetIndicatorIconText(entry), function()
                BetterBlizzPlatesDB.targetIndicatorIcon = entry.key
                anchorSubTarget.iconDropdown:SetDefaultText(BBP.GetTargetIndicatorIconText(entry))
                BBP.needsUpdate = true
                BBP.RefreshAllNameplates()
            end)
        end
    end)

    anchorSubTarget.iconLabel = anchorSubTarget.extendedSettings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget.iconLabel:SetPoint("BOTTOM", anchorSubTarget.iconDropdown, "TOP", 0, 3)
    anchorSubTarget.iconLabel:SetText(L["Icon_Select"])


    ----------------------
    -- Raid Indicator
    ----------------------
    local anchorSubRaidmark = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubRaidmark:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, fourthLineY)
    anchorSubRaidmark:SetText(L["Raidmarker"])

    CreateBorderBox(anchorSubRaidmark)

    anchorSubRaidmark.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubRaidmark.t:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_3")
    anchorSubRaidmark.t:SetSize(32, 32)
    anchorSubRaidmark.t:SetPoint("BOTTOM", anchorSubRaidmark, "TOP", 0, 3)

    BBP.raidmarkIndicator2 = CreateCheckbox("raidmarkIndicator", L["Move_Raidmarker"], contentFrame, nil, BBP.ChangeRaidmarker)
    CreateTooltip(BBP.raidmarkIndicator2, L["Tooltip_Enable_This_To_Move_Raidmarker_On"])

    local hideRaidmarkIndicator = CreateCheckbox("hideRaidmarkIndicator", L["Hide_Raidmarker"], contentFrame)
    hideRaidmarkIndicator:SetPoint("TOPLEFT", BBP.raidmarkIndicator2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    anchorSubRaidmark.box3 = CreateCheckbox("raidmarkerPvPOnly", L["Only_Move_In_PvP"], contentFrame)
    anchorSubRaidmark.box3:SetPoint("TOPLEFT", hideRaidmarkIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubRaidmark.box3, L["Only_Move_In_PvP"], L["Tooltip_Only_Move_In_PvP_Desc"])

    anchorSubRaidmark.box4 = CreateCheckbox("raidmarkIndicatorRaiseStrata", L["Raise_Strata"], contentFrame)
    anchorSubRaidmark.box4:SetPoint("TOPLEFT", anchorSubRaidmark.box3, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubRaidmark.box4, L["Raise_Strata"], L["Tooltip_Raise_Strata_Desc"])

    anchorSubRaidmark.box5 = CreateCheckbox("raidmarkIndicatorFullAlpha", L["Always_Full_Alpha"], contentFrame)
    anchorSubRaidmark.box5:SetPoint("TOPLEFT", anchorSubRaidmark.box4, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubRaidmark.box5, L["Always_Full_Alpha"], L["Tooltip_Always_Full_Alpha_Desc"])


    --CreateTooltip(hideRaidmarkIndicator, "Hide all raidmarkers on nameplates\n\n(Class Indicator and Party Pointer has their own setting\nto only hide on those specific nameplates where those icons show)")
    CreateTooltipTwo(hideRaidmarkIndicator, L["Hide_Raidmarker"], L["Tooltip_Hide_Raidmarker_2_Desc"], L["Tooltip_Hide_Raidmarker_2_SubText"], anchor, cvarName)
    --(widget, title, mainText, subText, anchor, cvarName)
    local raidmarkIndicatorScale = CreateSlider(BBP.raidmarkIndicator2, L["Size"], 0.6, 2.5, 0.01, "raidmarkIndicatorScale")
    raidmarkIndicatorScale:SetPoint("TOP", anchorSubRaidmark, "BOTTOM", 0, -15)

    local raidmarkIndicatorXPos = CreateSlider(BBP.raidmarkIndicator2, L["X_Offset"], -50, 50, 1, "raidmarkIndicatorXPos", "X")
    raidmarkIndicatorXPos:SetPoint("TOP", raidmarkIndicatorScale, "BOTTOM", 0, -15)

    local raidmarkIndicatorYPos = CreateSlider(BBP.raidmarkIndicator2, L["Y_Offset"], -50, 50, 1, "raidmarkIndicatorYPos", "Y")
    raidmarkIndicatorYPos:SetPoint("TOP", raidmarkIndicatorXPos, "BOTTOM", 0, -15)

    local raidmarkIndicatorDropdown = CreateAnchorDropdown(
        "raidmarkIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "raidmarkIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = raidmarkIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    --BBP.raidmarkIndicator2 = CreateCheckbox("raidmarkIndicator", "Change raidmarker pos", contentFrame, nil, BBP.ChangeRaidmarker)
    BBP.raidmarkIndicator2:SetPoint("TOPLEFT", raidmarkIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    function BBP.TempScuffedRadio()
        if BetterBlizzPlatesDB.raidmarkIndicator then
            CheckAndToggleCheckboxes(BBP.raidmarkIndicator2)
            raidmarkIndicatorDropdown:Enable()
        else
            CheckAndToggleCheckboxes(BBP.raidmarkIndicator2)
            raidmarkIndicatorDropdown:Disable()
        end
    end
    BBP.raidmarkIndicator2:HookScript("OnClick", function(self)
        BBP.TempScuffedRadio()
    end)



    BBP.TempScuffedRadio()

    ----------------------
    -- Quest Indicator
    ----------------------
    local anchorSubquest = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubquest:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, fourthLineY)
    anchorSubquest:SetText(L["Quest_Indicator"])

    CreateBorderBox(anchorSubquest)

    anchorSubquest.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubquest.t:SetAtlas("smallquestbang")
    anchorSubquest.t:SetSize(44, 44)
    anchorSubquest.t:SetPoint("BOTTOM", anchorSubquest, "TOP", 0, -3)

    local questIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "questIndicatorScale")
    questIndicatorScale:SetPoint("TOP", anchorSubquest, "BOTTOM", 0, -15)

    local questIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "questIndicatorXPos", "X")
    questIndicatorXPos:SetPoint("TOP", questIndicatorScale, "BOTTOM", 0, -15)

    local questIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "questIndicatorYPos", "Y")
    questIndicatorYPos:SetPoint("TOP", questIndicatorXPos, "BOTTOM", 0, -15)

    local questIndicatorDropdown = CreateAnchorDropdown(
        "questIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "questIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = questIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local questTestIcons2 = CreateCheckbox("questIndicatorTestMode", L["Test"], contentFrame)
    questTestIcons2:SetPoint("TOPLEFT", questIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    anchorSubquest.questIndicatorColorNpc = CreateCheckbox("questIndicatorColorNpc", L["Color_NPC"], contentFrame)
    anchorSubquest.questIndicatorColorNpc:SetPoint("TOPLEFT", questTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubquest.questIndicatorColorNpc, L["Color_Quest_NPC"], L["Tooltip_Color_Quest_NPC_Desc"])

    anchorSubquest.questIndicatorColorNpc:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BBP.needsUpdate = true
            local r, g, b = unpack(BetterBlizzPlatesDB.questIndicatorColorNpcRGB or {1, 0.502, 0})
            ColorPickerFrame:SetupColorPickerAndShow({
                r = r, g = g, b = b,
                swatchFunc = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    BetterBlizzPlatesDB.questIndicatorColorNpcRGB = { r, g, b }
                    BBP.RefreshAllNameplates()
                    anchorSubquest.questIndicatorColorNpc.Text:SetTextColor(unpack(BetterBlizzPlatesDB.questIndicatorColorNpcRGB))
                end,
                cancelFunc = function(previousValues)
                    local r, g, b = previousValues.r, previousValues.g, previousValues.b
                    BetterBlizzPlatesDB.questIndicatorColorNpcRGB = { r, g, b }
                    BBP.RefreshAllNameplates()
                    anchorSubquest.questIndicatorColorNpc.Text:SetTextColor(unpack(BetterBlizzPlatesDB.questIndicatorColorNpcRGB))
                end,
            })
        end
    end)

    if BetterBlizzPlatesDB.questIndicatorColorNpc then
        anchorSubquest.questIndicatorColorNpc.Text:SetTextColor(unpack(BetterBlizzPlatesDB.questIndicatorColorNpcRGB or {1, 0.502, 0}))
    end

    ----------------------
    -- Focus Target Indicator
    ----------------------
    local anchorSubFocus = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFocus:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, secondLineY)
    anchorSubFocus:SetText(L["Focus_Target_Indicator"])

    CreateBorderBox(anchorSubFocus)

    anchorSubFocus.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFocus.t:SetAtlas("Waypoint-MapPin-Untracked")
    anchorSubFocus.t:SetSize(40, 40)
    anchorSubFocus.t:SetPoint("BOTTOM", anchorSubFocus, "TOP", 0, -2)

    local focusTargetIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.5, 3, 0.01, "focusTargetIndicatorScale")
    focusTargetIndicatorScale:SetPoint("TOP", anchorSubFocus, "BOTTOM", 0, -15)

    local focusTargetIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "focusTargetIndicatorXPos", "X")
    focusTargetIndicatorXPos:SetPoint("TOP", focusTargetIndicatorScale, "BOTTOM", 0, -15)

    local focustargetIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "focusTargetIndicatorYPos", "Y")
    focustargetIndicatorYPos:SetPoint("TOP", focusTargetIndicatorXPos, "BOTTOM", 0, -15)

    local focusTargetIndicatorDropdown = CreateAnchorDropdown(
        "focusTargetIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "focusTargetIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = focustargetIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local focusTargetTestIcons2 = CreateCheckbox("focusTargetIndicatorTestMode", L["Test"], contentFrame)
    focusTargetTestIcons2:SetPoint("TOPLEFT", focusTargetIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local focusTargetIndicatorColorName = CreateCheckbox("focusTargetIndicatorColorName", L["Color_Name"], contentFrame)
    focusTargetIndicatorColorName:SetPoint("LEFT", focusTargetTestIcons2.Text, "RIGHT", 0, 0)

    if BetterBlizzPlatesDB.focusTargetIndicatorColorName then
        focusTargetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
    end

    local focusTargetIndicatorColorNameplate = CreateCheckbox("focusTargetIndicatorColorNameplate", L["Color_Healthbar"], contentFrame)
    focusTargetIndicatorColorNameplate:SetPoint("TOPLEFT", focusTargetTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
        focusTargetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
    end
    CreateTooltipTwo(focusTargetIndicatorColorNameplate, L["Color_Focus_Nameplate_Healthbar"], L["Tooltip_Color_Focus_Nameplate_Healthbar_Desc"])
    focusTargetIndicatorColorNameplate:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP == nil then
                BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP = true
            else
                BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local function OpenColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                focusTargetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB = { r, g, b }
                BBP.RefreshAllNameplates()
                focusTargetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
            end,
        })
    end

    local focusColorButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    focusColorButton:SetText(L["Color"])
    focusColorButton:SetPoint("LEFT", focusTargetIndicatorColorNameplate.text, "RIGHT", -1, 0)
    focusColorButton:SetSize(43, 18)
    focusColorButton:SetScript("OnClick", OpenColorPicker)

    focusTargetIndicatorColorName:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.focusTargetIndicatorColorName = self:GetChecked()
        local nameplateForFocus = C_NamePlate.GetNamePlateForUnit("focus")
        if BetterBlizzPlatesDB.focusTargetIndicatorColorName then
            focusTargetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
            focusColorButton:Enable()
            focusColorButton:SetAlpha(1)
        else
            focusTargetIndicatorColorName.Text:SetTextColor(1, 0.819607, 0)
            if (not BetterBlizzPlatesDB.focusTargetIndicatorColorName and not BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate) then
                focusColorButton:Disable()
                focusColorButton:SetAlpha(0.5)
            end
        end
    end)

    focusTargetIndicatorColorNameplate:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate = self:GetChecked()
        local nameplateForFocusTarget = C_NamePlate.GetNamePlateForUnit("focus")
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            focusTargetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
            focusColorButton:Enable()
            focusColorButton:SetAlpha(1)
        else
            focusTargetIndicatorColorNameplate.Text:SetTextColor(1, 0.819607, 0)
            if (not BetterBlizzPlatesDB.focusTargetIndicatorColorName and not BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate) then
                focusColorButton:Disable()
                focusColorButton:SetAlpha(0.5)
            end
        end
    end)

    if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate or BetterBlizzPlatesDB.focusTargetIndicatorColorName then
        focusColorButton:Enable()
        focusColorButton:SetAlpha(1)
    else
        focusColorButton:Disable()
        focusColorButton:SetAlpha(0.5)
    end

    local focusTargetIndicatorChangeTexture = CreateCheckbox("focusTargetIndicatorChangeTexture", L["Re_Texture_Healthbar"], contentFrame)
    focusTargetIndicatorChangeTexture:SetPoint("TOPLEFT", focusTargetIndicatorColorNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicatorChangeTexture, L["Tooltip_Re_Texture_The_Healthbar_Of_The"])

    local focusTargetIndicatorTexture = CreateTextureDropdown(
        "focusTargetIndicatorTexture",
        focusTargetIndicatorChangeTexture,
        L["Select_Texture"],
        "focusTargetIndicatorTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = focusTargetIndicatorChangeTexture, x = 3, y = 3, label = L["Texture"] },
        138
    )

    focusTargetIndicatorChangeTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusTargetIndicatorTexture:Enable()
        else
            focusTargetIndicatorTexture:Disable()
        end
    end)

    ----------------------
    -- Execute Indicator
    ----------------------
    local anchorSubExecute = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubExecute:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, secondLineY)
    anchorSubExecute:SetText(L["Execute_Indicator"])

    anchorSubExecute.border = CreateBorderBox(anchorSubExecute)

    anchorSubExecute.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubExecute.t:SetAtlas("islands-azeriteboss")
    anchorSubExecute.t:SetSize(56, 60)
    anchorSubExecute.t:SetPoint("BOTTOM", anchorSubExecute, "TOP", 0, -10)

    local executeIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.5, 2.5, 0.01, "executeIndicatorScale")
    executeIndicatorScale:SetPoint("TOP", anchorSubExecute, "BOTTOM", 0, -15)

    local executeIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "executeIndicatorXPos", "X")
    executeIndicatorXPos:SetPoint("TOP", executeIndicatorScale, "BOTTOM", 0, -15)

    local executeIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "executeIndicatorYPos", "Y")
    executeIndicatorYPos:SetPoint("TOP", executeIndicatorXPos, "BOTTOM", 0, -15)

    local executeIndicatorDropdown = CreateAnchorDropdown(
        "executeIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "executeIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = executeIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local executeTestIcons2 = CreateCheckbox("executeIndicatorTestMode", L["Test"], contentFrame)
    executeTestIcons2:SetPoint("TOPLEFT", executeIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    anchorSubExecute.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    anchorSubExecute.extendedSettingsButton:SetSize(120, 25)
    anchorSubExecute.extendedSettingsButton:SetPoint("TOPLEFT", executeTestIcons2, "BOTTOMLEFT", 12, -8)
    anchorSubExecute.extendedSettingsButton:SetText(L["More_Options"])
    CreateTooltip(anchorSubExecute.extendedSettingsButton, L["Tooltip_Open_More_Settings_For_Execute_Indicator"])

    anchorSubExecute.extendedSettings = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel, "DefaultPanelFlatTemplate")
    anchorSubExecute.extendedSettings:SetSize(270, 420)
    anchorSubExecute.extendedSettings:SetPoint("TOPLEFT", anchorSubExecute.border, "TOPRIGHT", -60, 40)
    anchorSubExecute.extendedSettings:SetFrameStrata("FULLSCREEN_DIALOG")
    anchorSubExecute.extendedSettings:SetFrameLevel(550)
    anchorSubExecute.extendedSettings:SetIgnoreParentAlpha(true)
    anchorSubExecute.extendedSettings:EnableMouse(true)
    anchorSubExecute.extendedSettings:Hide()
    anchorSubExecute.extendedSettings.name = L["Module_Name_Advanced"]
    anchorSubExecute.extendedSettings:SetTitle(L["Execute_Indicator"])
    anchorSubExecute.extendedSettings:SetMovable(true)
    anchorSubExecute.extendedSettings:SetClampedToScreen(true)
    anchorSubExecute.extendedSettings:RegisterForDrag("LeftButton")
    anchorSubExecute.extendedSettings:SetScript("OnDragStart", function(self) self:StartMoving() end)
    anchorSubExecute.extendedSettings:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    anchorSubExecute.closeButton = CreateFrame("Button", nil, anchorSubExecute.extendedSettings, "UIPanelCloseButton")
    anchorSubExecute.closeButton:SetFrameLevel((anchorSubExecute.extendedSettings.TitleContainer or anchorSubExecute.extendedSettings):GetFrameLevel() + 10)
    anchorSubExecute.closeButton:SetPoint("TOPRIGHT", anchorSubExecute.extendedSettings, "TOPRIGHT", 0, 0)
    anchorSubExecute.closeButton:SetScript("OnClick", function()
        anchorSubExecute.extendedSettings:Hide()
        contentFrame:SetAlpha(1)
    end)

    anchorSubExecute.bg = anchorSubExecute.extendedSettings:CreateTexture(nil, "BACKGROUND")
    anchorSubExecute.bg:SetPoint("TOPLEFT", anchorSubExecute.extendedSettings, "TOPLEFT", 7, -3)
    anchorSubExecute.bg:SetPoint("BOTTOMRIGHT", anchorSubExecute.extendedSettings, "BOTTOMRIGHT", -3, 3)
    anchorSubExecute.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    anchorSubExecute.extendedSettingsButton:HookScript("OnClick", function(self)
        anchorSubExecute.extendedSettings:SetShown(not anchorSubExecute.extendedSettings:IsShown())
        contentFrame:SetAlpha(anchorSubExecute.extendedSettings:IsShown() and 0.5 or 1)
    end)

    local executeSettings = anchorSubExecute.extendedSettings

    anchorSubExecute.AddHeader = function(text, y)
        local header = executeSettings:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        header:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 18, y)
        header:SetText(text)
        return header
    end

    anchorSubExecute.AddHeader(L["Visibility"], -32)

    local executeIndicatorAlwaysOn = CreateCheckbox("executeIndicatorAlwaysOn", L["Always_On"], executeSettings)
    executeIndicatorAlwaysOn:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 16, -46)
    CreateTooltip(executeIndicatorAlwaysOn, L["Tooltip_Always_Display_Health_Percentage"])

    local executeIndicatorNotOnFullHp = CreateCheckbox("executeIndicatorNotOnFullHp", "< 100%", executeSettings)
    executeIndicatorNotOnFullHp:SetPoint("TOPLEFT", executeIndicatorAlwaysOn, "TOPLEFT", 125, 0)
    CreateTooltip(executeIndicatorNotOnFullHp, L["Tooltip_Hide_On_100_Pct"])

    local executeIndicatorFriendly = CreateCheckbox("executeIndicatorFriendly", L["Friendly"], executeSettings)
    executeIndicatorFriendly:SetPoint("TOPLEFT", executeIndicatorAlwaysOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorFriendly, L["Show_On_Friendly_Nameplates"])

    anchorSubExecute.executeIndicatorTargetOnly = CreateCheckbox("executeIndicatorTargetOnly", L["Target"], executeSettings)
    anchorSubExecute.executeIndicatorTargetOnly:SetPoint("TOPLEFT", executeIndicatorNotOnFullHp, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorTargetOnly, L["Target_Only"], L["Tooltip_Target_Only_Desc"])

    local executeIndicatorThreshold = CreateSlider(executeSettings, L["Threshold"], 5, 100, 1, "executeIndicatorThreshold")
    executeIndicatorThreshold:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 26, -102)
    CreateTooltip(executeIndicatorThreshold, L["Tooltip_Percentage_Of_When_The_Execute_Indicator"])

    anchorSubExecute.AddHeader(L["Execute_Text_Line"], -134)

    local executeIndicatorShowDecimal = CreateCheckbox("executeIndicatorShowDecimal", L["Decimal"], executeSettings)
    executeIndicatorShowDecimal:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 16, -148)
    CreateTooltip(executeIndicatorShowDecimal, L["Tooltip_Show_Decimal"])

    local executeIndicatorPercentSymbol = CreateCheckbox("executeIndicatorPercentSymbol", L["Pct_Symbol"], executeSettings)
    executeIndicatorPercentSymbol:SetPoint("TOPLEFT", executeIndicatorShowDecimal, "TOPLEFT", 125, 0)
    CreateTooltip(executeIndicatorPercentSymbol, L["Tooltip_Show_Pct_Symbol"])

    anchorSubExecute.executeIndicatorUseTexture = CreateCheckbox("executeIndicatorUseTexture", L["Use_Texture"], executeSettings)
    anchorSubExecute.executeIndicatorUseTexture:SetPoint("TOPLEFT", executeIndicatorShowDecimal, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorUseTexture, L["Use_Texture"], L["Tooltip_Use_Texture_Desc"])

    local executeIndicatorHideText = CreateCheckbox("executeIndicatorHideText", L["Hide_Text"], executeSettings)
    executeIndicatorHideText:SetPoint("TOPLEFT", executeIndicatorPercentSymbol, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(executeIndicatorHideText, L["Hide_Text"], L["Tooltip_Hide_Text_2_Desc"])

    anchorSubExecute.executeIndicatorUseTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            DisableElement(executeIndicatorScale)
            DisableElement(executeIndicatorXPos)
            DisableElement(executeIndicatorYPos)
            executeIndicatorDropdown:Disable()
        else
            EnableElement(executeIndicatorScale)
            EnableElement(executeIndicatorXPos)
            EnableElement(executeIndicatorYPos)
            executeIndicatorDropdown:Enable()
        end
    end)
    if BetterBlizzPlatesDB.executeIndicatorUseTexture then
        DisableElement(executeIndicatorScale)
        DisableElement(executeIndicatorXPos)
        DisableElement(executeIndicatorYPos)
        executeIndicatorDropdown:Disable()
    end

    anchorSubExecute.AddHeader(L["Healthbar"], -196)

    anchorSubExecute.executeIndicatorInRangeColor = CreateCheckbox("executeIndicatorInRangeColor", L["Color_Healthbar"], executeSettings)
    anchorSubExecute.executeIndicatorInRangeColor:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 16, -210)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorInRangeColor, L["Color_Healthbar"], L["Tooltip_Color_Healthbar_Desc"])

    anchorSubExecute.executeIndicatorInRangeColor:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.executeIndicatorInRangeColorRGB, BBP.RefreshAllNameplates)
        end
    end)

    anchorSubExecute.AddHeader(L["Execute_Skull"] .. " |A:islands-azeriteboss:24:24|a", -239)

    anchorSubExecute.executeSkull = CreateCheckbox("executeSkull", L["Show_Execute_Skull"], executeSettings)
    anchorSubExecute.executeSkull:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 16, -253)
    CreateTooltipTwo(anchorSubExecute.executeSkull, L["Show_Execute_Skull"] .. " |A:islands-azeriteboss:18:18|a", L["Tooltip_Show_Execute_Skull_Desc"])

    anchorSubExecute.skullAttach = CreateCheckbox("executeSkullAttachToHealth", L["Attach_To_Current_Health"], executeSettings)
    anchorSubExecute.skullAttach:SetPoint("TOPLEFT", anchorSubExecute.executeSkull, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.skullAttach, L["Attach_To_Current_Health"], L["Tooltip_Attach_To_Current_Health_Desc"])

    anchorSubExecute.skullKeep = CreateCheckbox("executeSkullKeepIndicator", L["Keep_Execute_Text_Line"], executeSettings)
    anchorSubExecute.skullKeep:SetPoint("TOPLEFT", anchorSubExecute.skullAttach, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.skullKeep, L["Keep_Execute_Text_Line"], L["Tooltip_Keep_Execute_Text_Line_Desc"])

    anchorSubExecute.skullScale = CreateSlider(executeSettings, L["Size"], 0.5, 3, 0.01, "executeSkullScale")
    anchorSubExecute.skullScale:SetScale(0.85)
    anchorSubExecute.skullScale:SetPoint("TOPLEFT", executeSettings, "TOPLEFT", 26 / 0.85, -330 / 0.85)

    anchorSubExecute.skullXPos = CreateSlider(executeSettings, L["X_Offset"], -50, 50, 1, "executeSkullXPos")
    anchorSubExecute.skullXPos:SetScale(0.85)
    anchorSubExecute.skullXPos:SetPoint("TOP", anchorSubExecute.skullScale, "BOTTOM", 0, -15)

    anchorSubExecute.skullYPos = CreateSlider(executeSettings, L["Y_Offset"], -50, 50, 1, "executeSkullYPos")
    anchorSubExecute.skullYPos:SetScale(0.85)
    anchorSubExecute.skullYPos:SetPoint("TOP", anchorSubExecute.skullXPos, "BOTTOM", 0, -15)

    local function executeIndicatorToggle()
        if BetterBlizzPlatesDB.executeIndicatorAlwaysOn then
            executeIndicatorNotOnFullHp:SetAlpha(1)
            executeIndicatorNotOnFullHp:Enable()
            executeIndicatorThreshold:SetAlpha(0.5)
            executeIndicatorThreshold:Disable()
        else
            executeIndicatorNotOnFullHp:SetAlpha(0.5)
            executeIndicatorNotOnFullHp:Disable()
            executeIndicatorThreshold:SetAlpha(1)
            executeIndicatorThreshold:Enable()
        end
        local skullOn = BetterBlizzPlatesDB.executeSkull
        for _, widget in ipairs({ anchorSubExecute.skullAttach, anchorSubExecute.skullKeep, anchorSubExecute.skullScale, anchorSubExecute.skullXPos, anchorSubExecute.skullYPos }) do
            if skullOn then widget:Enable() else widget:Disable() end
            widget:SetAlpha(skullOn and 1 or 0.5)
        end
    end
    executeIndicatorToggle()

    executeIndicatorAlwaysOn:HookScript("OnClick", executeIndicatorToggle)
    anchorSubExecute.executeSkull:HookScript("OnClick", executeIndicatorToggle)

    ----------------------
    -- Arena Indicator
    ----------------------
    local anchorSubArena = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubArena:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorSubArena:SetText(L["Arena_Names"])

    CreateBorderBox(anchorSubArena)

    anchorSubArena.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubArena.t:SetAtlas("pvptalents-warmode-swords")
    anchorSubArena.t:SetSize(30, 30)
    anchorSubArena.t:SetPoint("BOTTOM", anchorSubArena, "TOP", 0, 3)

    local arenaIndicatorXPos = CreateSlider(contentFrame, L["ID_X_Offset"], -50, 50, 1, "arenaIdXPos", "X")
    arenaIndicatorXPos:SetPoint("TOP", anchorSubArena, "BOTTOM", 0, -15)

    local arenaIndicatorYPos = CreateSlider(contentFrame, L["ID_Y_Offset"], -50, 50, 1, "arenaIdYPos", "Y")
    arenaIndicatorYPos:SetPoint("TOP", arenaIndicatorXPos, "BOTTOM", 0, -15)

    local arenaSpecXPos = CreateSlider(contentFrame, L["Spec_X_Offset"], -50, 50, 1, "arenaSpecXPos", "X")
    arenaSpecXPos:SetPoint("TOP", arenaIndicatorYPos, "BOTTOM", 0, -15)

    local arenaSpecYPos = CreateSlider(contentFrame, L["Spec_Y_Offset"], -50, 50, 1, "arenaSpecYPos", "Y")
    arenaSpecYPos:SetPoint("TOP", arenaSpecXPos, "BOTTOM", 0, -15)

    local arenaIdAnchorDropdown = CreateAnchorDropdown(
        "arenaIdAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "arenaIdAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = arenaSpecYPos, x = -16, y = -31, label = L["ID_Anchor"] }
    )

    local arenaSpecAnchorDropdown = CreateAnchorDropdown(
        "arenaSpecAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "arenaSpecAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = arenaIdAnchorDropdown, x = 0, y = -41, label = L["Spec_Anchor"] }
    )
    BBP.arenaSpecAnchorDropdown = arenaSpecAnchorDropdown

    local arenaIndicatorTestMode2 = CreateCheckbox("arenaIndicatorTestMode", L["Test"], contentFrame)
    arenaIndicatorTestMode2:SetPoint("TOPLEFT", arenaSpecAnchorDropdown, "BOTTOMLEFT", 16, 8)

    anchorSubArena.arenaIdAnchorRaiseStrata = CreateCheckbox("arenaIdAnchorRaiseStrata", L["Raise_Strata"], contentFrame)
    anchorSubArena.arenaIdAnchorRaiseStrata:SetPoint("LEFT", arenaIndicatorTestMode2.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubArena.arenaIdAnchorRaiseStrata, L["Raise_Strata_For_Arena_ID"], L["Tooltip_Raise_Strata_For_Arena_ID_Desc"])
    anchorSubArena.arenaIdAnchorRaiseStrata:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)


    local showCircleOnArenaID = CreateCheckbox("showCircleOnArenaID", L["Show_Circle_On_ID"], contentFrame)
    showCircleOnArenaID:SetPoint("TOPLEFT", arenaIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCircleOnArenaID, L["Tooltip_Show_A_Colored_Circle_On_Each"])

    ----------------------
    -- Class Icon
    ----------------------
    local anchorSubClassIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubClassIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubClassIcon:SetText(L["Class_Indicator"])

    anchorSubClassIcon.border = CreateBorderBox(anchorSubClassIcon)

    anchorSubClassIcon.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubClassIcon.t:SetAtlas("groupfinder-icon-class-mage")
    anchorSubClassIcon.t:SetSize(33, 33)
    anchorSubClassIcon.t:SetPoint("BOTTOM", anchorSubClassIcon, "TOP", 0, 1.5)

    local classIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.6, 2.5, 0.01, "classIndicatorFriendlyScale", false, 72)
    classIndicatorScale:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", 36, -15)
    classIndicatorScale.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorScale, L["Friendly_Scale"])

    local classIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "classIndicatorFriendlyXPos", "X", 72)
    classIndicatorXPos:SetPoint("TOP", classIndicatorScale, "BOTTOM", 0, -15)
    classIndicatorXPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorXPos, L["Friendly_X_Offset"])

    local classIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "classIndicatorFriendlyYPos", "Y", 72)
    classIndicatorYPos:SetPoint("TOP", classIndicatorXPos, "BOTTOM", 0, -15)
    classIndicatorYPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorYPos, L["Friendly_Y_Offset"])

    local classIndicatorScale2 = CreateSlider(contentFrame, L["Size"], 0.6, 2.5, 0.01, "classIndicatorScale", false, 72)
    classIndicatorScale2:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", -36, -15)
    classIndicatorScale2.Text:SetTextColor(1,0,0)
    CreateTooltip(classIndicatorScale2, L["Enemy_Scale"])

    local classIndicatorXPos2 = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "classIndicatorXPos", "X", 72)
    classIndicatorXPos2:SetPoint("TOP", classIndicatorScale2, "BOTTOM", 0, -15)
    classIndicatorXPos2.Text:SetTextColor(1,0,0)
    CreateTooltip(classIndicatorXPos2, L["Enemy_X_Offset"])

    local classIndicatorYPos2 = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "classIndicatorYPos", "Y", 72)
    classIndicatorYPos2:SetPoint("TOP", classIndicatorXPos2, "BOTTOM", 0, -15)
    classIndicatorYPos2.Text:SetTextColor(1,0,0)
    CreateTooltip(classIndicatorYPos2, L["Enemy_Y_Offset"])

    local classIconDropdown = CreateAnchorDropdown(
        "classIconDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "classIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = classIndicatorYPos, x = -90, y = -35, label = L["Enemy"] },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltip(classIconDropdown, L["Tooltip_Enemy_Anchor"])

    local classIconDropdown2 = CreateAnchorDropdown(
        "classIconDropdown2",
        contentFrame,
        L["Select_Anchor_Point"],
        "classIndicatorFriendlyAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = classIndicatorYPos, x = -16, y = -35, label = L["Friendly"] },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltip(classIconDropdown2, L["Tooltip_Friendly_Anchor"])

    local classIndicatorEnemy = CreateCheckbox("classIndicatorEnemy", L["Enemies"], contentFrame)
    classIndicatorEnemy:SetPoint("TOPLEFT", classIconDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    CreateTooltipTwo(classIndicatorEnemy, L["Show_On_Enemy_Nameplates"], L["Tooltip_Show_On_Enemy_Nameplates_Desc"], L["Tooltip_Show_On_Enemy_Nameplates_SubText"])

    local classIndicatorFriendly = CreateCheckbox("classIndicatorFriendly", L["Friendly"], contentFrame)
    classIndicatorFriendly:SetPoint("LEFT", classIndicatorEnemy.text, "RIGHT", -2, 0)
    CreateTooltipTwo(classIndicatorFriendly, L["Show_On_Friendly_Nameplates"], L["Tooltip_Show_On_Friendly_Nameplates_Desc"], L["Tooltip_Show_On_Friendly_Nameplates_SubText"])

    CreateMoreOptionsPopup(anchorSubClassIcon, contentFrame, BetterBlizzPlatesSubPanel, L["Class_Indicator"], L["Tooltip_Open_More_Settings_For_Class_Indicator"], 470)

    local classIconSquareBorder = CreateCheckbox("classIconSquareBorder", L["Square"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconSquareBorder, L["Tooltip_Square_Instead_Of_Circle_Icon_For"])

    local classIconSquareBorderFriendly = CreateCheckbox("classIconSquareBorderFriendly", L["Square_Friend"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconSquareBorderFriendly, L["Tooltip_Square_Instead_Of_Circle_Icon_For_2"])

    local classIconArenaOnly = CreateCheckbox("classIconArenaOnly", L["Arena_Only"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconArenaOnly, L["Tooltip_Show_In_Arena_Only"])

    local classIconBgOnly = CreateCheckbox("classIconBgOnly", L["BG_Only"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconBgOnly, L["Tooltip_Show_In_Battlegrounds_Only"])

    anchorSubClassIcon.classIndicatorCCAuras = CreateCheckbox("classIndicatorCCAuras", L["Show_CC"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorCCAuras, L["Show_Crowd_Control"], L["Tooltip_Show_Crowd_Control_Desc"], L["Tooltip_Show_Crowd_Control_SubText"])
    anchorSubClassIcon.classIndicatorCCAuras:HookScript("OnClick", function(self)
        BBP.SetupClassIndicatorCCAuraListener()
        BBP.RefreshAllNameplateAuras()
    end)
    anchorSubClassIcon.classIndicatorCCAuras:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzPlatesDB.classIndicatorCCHideCdText then
                BetterBlizzPlatesDB.classIndicatorCCHideCdText = true
            else
                BetterBlizzPlatesDB.classIndicatorCCHideCdText = nil
            end
            BBP.SetupClassIndicatorCCAuraListener()
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    anchorSubClassIcon.classIndicatorShowPet = CreateCheckbox("classIndicatorShowPet", L["Show_On_Pet"], contentFrame)
    anchorSubClassIcon.classIndicatorShowPet:SetPoint("TOPLEFT", classIndicatorEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorShowPet, L["Show_Pet"], L["Tooltip_Show_Pet_Desc"], L["Tooltip_Show_Pet_SubText"])
    anchorSubClassIcon.classIndicatorShowPet:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.RunAfterCombat(function()
                C_CVar.SetCVar("nameplateShowFriendlyPlayerPets", "1")
                BBP.SaveNameplateToggleCVar("nameplateShowFriendlyPlayerPets", "1")
                BBP.Print(L["Print_Show_Friendly_Pets_CVar_Toggled_On"])
            end)
        end
    end)

    anchorSubClassIcon.petOptions = CreateMultiSelectDropdown(L["Pet_Options"], contentFrame, {
        { key = "classIndicatorAlwaysShowPet", label = L["Show_Pet_Always"], tooltip = L["Tooltip_Show_Pet_Always_Desc"], tooltipNote = L["Tooltip_Show_Pet_SubText"] },
        { key = "partyPointerShowOthersPets", label = L["Show_On_Pet_Others"], tooltip = L["Tooltip_Show_On_Pet_Others_Desc"], tooltipNote = L["Tooltip_Show_Pet_SubText"] },
    }, 150)
    anchorSubClassIcon.petOptions.searchParentKey = "classIndicatorShowPet"
    anchorSubClassIcon.petOptions:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorShowPet, "BOTTOMLEFT", 6, -2)
    anchorSubClassIcon.petOptions:SetScale(0.7)
    anchorSubClassIcon.UpdatePetOptionsState = function()
        local enabled = anchorSubClassIcon.classIndicatorShowPet:GetChecked() and true or false
        anchorSubClassIcon.petOptions:SetEnabled(enabled)
        anchorSubClassIcon.petOptions:SetAlpha(enabled and 1 or 0.5)
    end
    anchorSubClassIcon.classIndicatorShowPet:HookScript("OnClick", anchorSubClassIcon.UpdatePetOptionsState)
    anchorSubClassIcon.UpdatePetOptionsState()
    anchorSubClassIcon.extendedSettingsButton:SetPoint("TOPLEFT", anchorSubClassIcon.petOptions, "BOTTOMLEFT", 6, -8)


    local classIndicatorSpecIcon = CreateCheckbox("classIndicatorSpecIcon", L["Show_Spec_Icon"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorSpecIcon, L["Tooltip_Show_Spec_Instead_Of_Class_Icon"])

    anchorSubClassIcon.classIndicatorHideFriendlyHealthbar = CreateCheckbox("classIndicatorHideFriendlyHealthbar", L["Hide_Friendly_Healthbar"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorHideFriendlyHealthbar, L["Hide_Friendly_Healthbar"],L["Tooltip_Hide_Friendly_Healthbar_Desc"])

    anchorSubClassIcon.classIndicatorOnlyParty = CreateCheckbox("classIndicatorOnlyParty", L["Only_Show_On_Party"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorOnlyParty, L["Only_Show_On_Party"], L["Tooltip_Only_Show_On_Party_Desc"])

    anchorSubClassIcon.classIndicatorOnlyFriends = CreateCheckbox("classIndicatorOnlyFriends", L["Only_Show_On_Friends_Friendlist"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorOnlyFriends, L["Only_Show_On_Friends_Friendlist"], L["Tooltip_Only_Show_On_Friends_Friendlist_Desc"])

    anchorSubClassIcon.classIndicatorOnlyHealer = CreateCheckbox("classIndicatorOnlyHealer", L["Only_Show_Healer"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(anchorSubClassIcon.classIndicatorOnlyHealer, L["Tooltip_Only_Show_On_Healers"])

    local classIndicatorHealer = CreateCheckbox("classIndicatorHealer", L["Show_Cross_On_Healer"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHealer, L["Tooltip_Show_Cross_Instead_Of_Class_Spec"])

    anchorSubClassIcon.classIndicatorTank = CreateCheckbox("classIndicatorTank", L["Show_Shield_On_Tank"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(anchorSubClassIcon.classIndicatorTank, L["Tooltip_Show_Shield_Instead_Of_Class_Spec"])

    local classIconColorBorder = CreateCheckbox("classIconColorBorder", L["Class_Color_Border"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconColorBorder, L["Class_Color_Border"])

    anchorSubClassIcon.classIconReactionBorder = CreateCheckbox("classIconReactionBorder", L["Reaction_Color_Border"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(anchorSubClassIcon.classIconReactionBorder, L["Tooltip_Reaction_Color_Border_Red_For_Enemy"])

    classIconColorBorder:HookScript("OnClick", function(self)
        if self:GetChecked() then
            if anchorSubClassIcon.classIconReactionBorder:GetChecked() then
                anchorSubClassIcon.classIconReactionBorder:Click()
            end
        end
    end)

    anchorSubClassIcon.classIconReactionBorder:HookScript("OnClick", function(self)
        if self:GetChecked() then
            if classIconColorBorder:GetChecked() then
                classIconColorBorder:Click()
            end
        end
    end)

    anchorSubClassIcon.classIconAlwaysShowHealer = CreateCheckbox("classIconAlwaysShowHealer", L["Always_Show_Healers"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIconAlwaysShowHealer, L["Always_Show_Healers"], L["Tooltip_Always_Show_Healers_Desc"])

    anchorSubClassIcon.classIconAlwaysShowTank = CreateCheckbox("classIconAlwaysShowTank", L["Always_Show_Tanks"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIconAlwaysShowTank, L["Always_Show_Tanks"], L["Tooltip_Always_Show_Tanks_Desc"])

    anchorSubClassIcon.classIconAlwaysShowBgObj = CreateCheckbox("classIconAlwaysShowBgObj", L["Always_Show_BG_Objective"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIconAlwaysShowBgObj, L["Always_Show_BG_Objective"], L["Tooltip_Always_Show_BG_Objective_Desc"])

    anchorSubClassIcon.classIconHealthNumbers = CreateCheckbox("classIconHealthNumbers", L["Show_Health_Instead_Of_Name"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIconHealthNumbers, L["Show_Health_Instead_Of_Name"], L["Tooltip_Show_Health_Instead_Of_Name_Desc"])
    anchorSubClassIcon.classIconHealthNumbers:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.SetupClassIndicatorHealthText()
        end
    end)

    anchorSubClassIcon.classIconEnemyHealIcon = CreateCheckbox("classIconEnemyHealIcon", L["Change_Enemy_Healer_Icon"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIconEnemyHealIcon, L["Change_Enemy_Healer_Icon"], L["Tooltip_Change_Enemy_Healer_Icon_Desc"])

    anchorSubClassIcon.classIconEnemyHealIcon:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then

            BetterBlizzPlatesDB.classIconHealerIconType = (BetterBlizzPlatesDB.classIconHealerIconType % 4) + 1

            if not anchorSubClassIcon.extendedSettings.healIcon then
                anchorSubClassIcon.extendedSettings.healIcon = anchorSubClassIcon.extendedSettings:CreateTexture(nil, "BACKGROUND")
                anchorSubClassIcon.extendedSettings.healIcon:SetPoint("CENTER", anchorSubClassIcon.classIconEnemyHealIcon, "LEFT", -55, 0)

                -- Apply correct icon texture
                anchorSubClassIcon.extendedSettings.healIcon.border = anchorSubClassIcon.extendedSettings:CreateTexture(nil, "OVERLAY")
                anchorSubClassIcon.extendedSettings.healMask = anchorSubClassIcon.extendedSettings:CreateMaskTexture()
                anchorSubClassIcon.extendedSettings.healMask:SetPoint("CENTER", anchorSubClassIcon.extendedSettings.healIcon)
            end

            -- Apply size and border based on settings
            anchorSubClassIcon.extendedSettings.healIcon:SetDesaturated(false)
            anchorSubClassIcon.extendedSettings.healIcon:SetVertexColor(1,1,1)
            if BetterBlizzPlatesDB.classIconSquareBorder then

                anchorSubClassIcon.extendedSettings.healIcon:AddMaskTexture(anchorSubClassIcon.extendedSettings.healMask)
                anchorSubClassIcon.extendedSettings.healMask:SetAtlas("UI-Frame-IconMask")
                anchorSubClassIcon.extendedSettings.healIcon.border:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-ActionBar-IconFrame-AddRow-Light")
                anchorSubClassIcon.extendedSettings.healIcon.border:SetVertexColor(0.2, 0.2, 0.2)

                anchorSubClassIcon.extendedSettings.healIcon:SetSize(119,119)
                if BetterBlizzPlatesDB.classIconHealerIconType == 1 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexture("interface/lfgframe/uilfgprompts")
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0.005, 0.116, 0.76, 0.87)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 2 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexture("interface/lfgframe/uilfgprompts")
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0.005, 0.116, 0.76, 0.87)
                    anchorSubClassIcon.extendedSettings.healIcon:SetDesaturated(true)
                    anchorSubClassIcon.extendedSettings.healIcon:SetVertexColor(1,0,0)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 3 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetSize(90,90)
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexture(648207)
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0, 1, 0, 1)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 4 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetSize(90,90)
                    if BetterBlizzPlatesDB.classIndicatorSpecIcon then
                        local specIcon = select(4, GetSpecializationInfoByID(105))
                        if specIcon then
                            anchorSubClassIcon.extendedSettings.healIcon:SetTexture(specIcon)
                            anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0, 1, 0, 1)
                        else
                            anchorSubClassIcon.extendedSettings.healIcon:SetAtlas("classicon-druid")
                            anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(-0.06, 1.05, -0.06, 1.05)
                        end
                    else
                        anchorSubClassIcon.extendedSettings.healIcon:SetAtlas("classicon-druid")
                        anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(-0.06, 1.05, -0.06, 1.05)
                    end
                end


                anchorSubClassIcon.extendedSettings.healMask:SetSize(90,90)



                anchorSubClassIcon.extendedSettings.healIcon.border:SetSize(129,129)
                anchorSubClassIcon.extendedSettings.healIcon.border:ClearAllPoints()
                anchorSubClassIcon.extendedSettings.healIcon.border:SetPoint("CENTER", anchorSubClassIcon.extendedSettings.healIcon, 8, -7)
            else
                anchorSubClassIcon.extendedSettings.healIcon:SetSize(90,90)
                anchorSubClassIcon.extendedSettings.healMask:SetSize(90,90)
                anchorSubClassIcon.extendedSettings.healIcon:AddMaskTexture(anchorSubClassIcon.extendedSettings.healMask)
                anchorSubClassIcon.extendedSettings.healIcon.border:SetAtlas("AutoQuest-badgeborder")
                anchorSubClassIcon.extendedSettings.healMask:SetTexture("Interface/Masks/CircleMaskScalable")
                anchorSubClassIcon.extendedSettings.healIcon.border:ClearAllPoints()
                anchorSubClassIcon.extendedSettings.healIcon.border:SetPoint("CENTER", anchorSubClassIcon.extendedSettings.healIcon, "CENTER", 0.5, 0)
                anchorSubClassIcon.extendedSettings.healIcon.border:SetSize(103,103)

                if BetterBlizzPlatesDB.classIconHealerIconType == 1 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexture("interface/lfgframe/uilfgprompts")
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0.0185, 0.103, 0.772, 0.856)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 2 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexture("interface/lfgframe/uilfgprompts")
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0.0185, 0.103, 0.772, 0.856)
                    anchorSubClassIcon.extendedSettings.healIcon:SetDesaturated(true)
                    anchorSubClassIcon.extendedSettings.healIcon:SetVertexColor(1,0,0)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 3 then
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexture(648207)
                    anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0, 1, 0, 1)
                elseif BetterBlizzPlatesDB.classIconHealerIconType == 4 then
                    if BetterBlizzPlatesDB.classIndicatorSpecIcon then
                        local specIcon = select(4, GetSpecializationInfoByID(105))
                        if specIcon then
                            anchorSubClassIcon.extendedSettings.healIcon:SetTexture(specIcon)
                            anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(0, 1, 0, 1)
                        else
                            anchorSubClassIcon.extendedSettings.healIcon:SetAtlas("classicon-druid")
                            anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(-0.06, 1.05, -0.06, 1.05)
                        end
                    else
                        anchorSubClassIcon.extendedSettings.healIcon:SetAtlas("classicon-druid")
                        anchorSubClassIcon.extendedSettings.healIcon:SetTexCoord(-0.06, 1.05, -0.06, 1.05)
                    end
                end


            end

            if BetterBlizzPlatesDB.classIconColorBorder then
                anchorSubClassIcon.classColor = RAID_CLASS_COLORS["DRUID"]
                anchorSubClassIcon.extendedSettings.healIcon.border:SetDesaturated(true)
                anchorSubClassIcon.extendedSettings.healIcon.border:SetVertexColor(anchorSubClassIcon.classColor.r, anchorSubClassIcon.classColor.g, anchorSubClassIcon.classColor.b)
            elseif BetterBlizzPlatesDB.classIconReactionBorder then
                anchorSubClassIcon.extendedSettings.healIcon.border:SetDesaturated(true)
                anchorSubClassIcon.extendedSettings.healIcon.border:SetVertexColor(1,0,0)
            else
                anchorSubClassIcon.extendedSettings.healIcon.border:SetDesaturated(false)
                if BetterBlizzPlatesDB.classIconSquareBorder then
                    anchorSubClassIcon.extendedSettings.healIcon.border:SetVertexColor(0.2, 0.2, 0.2)
                else
                    anchorSubClassIcon.extendedSettings.healIcon.border:SetVertexColor(1, 1, 1)
                end
            end
        end
    end)

    local classIndicatorHighlight = CreateCheckbox("classIndicatorHighlight", L["Highlight_Target"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHighlight, L["Tooltip_Show_Highlight_On_Current_Target_Icon"])

    local classIndicatorHighlightColor = CreateCheckbox("classIndicatorHighlightColor", L["Class_Color_Highlight"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHighlightColor, L["Tooltip_Class_Color_Target_Highlight"])

    local classIndicatorHideRaidMarker = CreateCheckbox("classIndicatorHideRaidMarker", L["Hide_Raidmarker"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHideRaidMarker, L["Tooltip_Hide_Raidmarker_On_Nameplates_With_Class"])

    anchorSubClassIcon.classIndicatorFrameStrataHigh = CreateCheckbox("classIndicatorFrameStrataHigh", L["Raise_Strata"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorFrameStrataHigh, L["Class_Indicator_Frame_Strata"], L["Tooltip_Class_Indicator_Frame_Strata_Desc"])

    anchorSubClassIcon.classIndicatorHideName = CreateCheckbox("classIndicatorHideName", L["Hide_Name"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorHideName, L["Hide_Name_Friend"], L["Tooltip_Hide_Name_Friend_Desc"])

    anchorSubClassIcon.classIndicatorIgnoreScale = CreateCheckbox("classIndicatorIgnoreScale", L["Ignore_Nameplate_Scale"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorIgnoreScale, L["Ignore_Nameplate_Scale"], L["Tooltip_Ignore_Nameplate_Scale_Desc"])

    anchorSubClassIcon.classIndicatorBackground = CreateCheckbox("classIndicatorBackground", L["Show_Background_Color"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorBackground, L["Show_Background_Color"],L["Tooltip_Show_Background_Color_Desc"])

    anchorSubClassIcon.classIndicatorBackground:HookScript("OnMouseDown", function(self, button)
        if IsControlKeyDown() and button == "RightButton" then
            if not BetterBlizzPlatesDB.classIndicatorBackgroundClassColor then
                BetterBlizzPlatesDB.classIndicatorBackgroundClassColor = true
            else
                BetterBlizzPlatesDB.classIndicatorBackgroundClassColor = nil
            end
            BBP.RefreshAllNameplates()
        elseif button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.classIndicatorBackgroundRGB, BBP.RefreshAllNameplates)
        end
    end)

    anchorSubClassIcon.classIndicatorBackgroundSize = CreateSlider(anchorSubClassIcon.extendedSettings, L["Background_Size"], 0.8, 1.4, 0.01, "classIndicatorBackgroundSize", false, 110)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorBackgroundSize, L["Class_Indicator_Background_Size"])

    anchorSubClassIcon.classIndicatorAlpha = CreateSlider(anchorSubClassIcon.extendedSettings, L["Alpha"], 0.1, 1, 0.01, "classIndicatorAlpha", false, 110)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorAlpha, L["Class_Indicator_Alpha"])

    moreCol = anchorSubClassIcon.extendedSettings.Column(16)
    moreCol.Header(L["Icon"])
    moreCol.Add(classIconSquareBorder)
    moreCol.Add(classIconSquareBorderFriendly)
    moreCol.Add(classIndicatorSpecIcon)
    moreCol.Add(classIndicatorHealer)
    moreCol.Add(anchorSubClassIcon.classIndicatorTank)
    moreCol.Add(anchorSubClassIcon.classIconEnemyHealIcon)
    moreCol.Add(classIconColorBorder)
    moreCol.Add(anchorSubClassIcon.classIconReactionBorder)
    moreCol.Add(anchorSubClassIcon.classIndicatorBackground)
    moreCol.Slider(anchorSubClassIcon.classIndicatorBackgroundSize)
    moreCol.Header(L["Highlight"])
    moreCol.Add(classIndicatorHighlight)
    moreCol.Add(classIndicatorHighlightColor)
    moreCol = anchorSubClassIcon.extendedSettings.Column(246)
    moreCol.Header(L["Visibility"])
    moreCol.Add(classIconArenaOnly)
    moreCol.Add(classIconBgOnly)
    moreCol.Add(anchorSubClassIcon.classIndicatorOnlyParty)
    moreCol.Add(anchorSubClassIcon.classIndicatorOnlyFriends)
    moreCol.Add(anchorSubClassIcon.classIndicatorOnlyHealer)
    moreCol.Add(anchorSubClassIcon.classIconAlwaysShowHealer)
    moreCol.Add(anchorSubClassIcon.classIconAlwaysShowTank)
    moreCol.Slider(anchorSubClassIcon.classIndicatorAlpha)
    moreCol.Header(L["Other"])
    moreCol.Add(anchorSubClassIcon.classIndicatorCCAuras)
    moreCol.Add(anchorSubClassIcon.classIconAlwaysShowBgObj)
    moreCol.Add(classIndicatorHideRaidMarker)
    moreCol.Add(anchorSubClassIcon.classIndicatorHideName)
    moreCol.Add(anchorSubClassIcon.classIndicatorHideFriendlyHealthbar)
    moreCol.Add(anchorSubClassIcon.classIconHealthNumbers)
    moreCol.Add(anchorSubClassIcon.classIndicatorFrameStrataHigh)
    moreCol.Add(anchorSubClassIcon.classIndicatorIgnoreScale)
    anchorSubClassIcon.extendedSettings.Fit()

    ----------------------
    -- Party Pointer
    ----------------------
    local anchorSubPointerIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPointerIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, thirdLineY)
    anchorSubPointerIndicator:SetText(L["Party_Pointer"])

    CreateBorderBox(anchorSubPointerIndicator)

    anchorSubPointerIndicator.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubPointerIndicator.t:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
    anchorSubPointerIndicator.t:SetSize(25, 30)
    anchorSubPointerIndicator.t:SetPoint("BOTTOM", anchorSubPointerIndicator, "TOP", -1, 5)
    anchorSubPointerIndicator.t:SetDesaturated(true)
    anchorSubPointerIndicator.t:SetVertexColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubPointerIndicator.t, L["Tooltip_Show_A_Class_Colored_Pointer_Above"])

    local partyPointerScale = CreateSlider(contentFrame, L["Size"], 0.5, 2.2, 0.01, "partyPointerScale", false, 72)
    partyPointerScale:SetPoint("TOP", anchorSubPointerIndicator, "BOTTOM", -36, -15)

    local partyPointerWidth = CreateSlider(contentFrame, L["Width"], 20, 55, 1, "partyPointerWidth", false, 72)
    partyPointerWidth:SetPoint("TOP", anchorSubPointerIndicator, "BOTTOM", 36, -15)

    local partyPointerHealerScale = CreateSlider(contentFrame, L["Healer_Icon_Size"], 0.5, 2.2, 0.01, "partyPointerHealerScale")
    partyPointerHealerScale:SetPoint("TOP", partyPointerScale, "BOTTOM", 36, -15)

    local partyPointerXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "partyPointerXPos", "X")
    partyPointerXPos:SetPoint("TOP", partyPointerHealerScale, "BOTTOM", 0, -15)

    local partyPointerYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "partyPointerYPos", "Y")
    partyPointerYPos:SetPoint("TOP", partyPointerXPos, "BOTTOM", 0, -15)

    local partyPointerDropdown = CreateAnchorDropdown(
        "partyPointerDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "partyPointerAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = partyPointerYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local partyPointerTestMode = CreateCheckbox("partyPointerTestMode", L["Test"], contentFrame)
    partyPointerTestMode:SetPoint("TOPLEFT", partyPointerDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    CreateMoreOptionsPopup(anchorSubPointerIndicator, contentFrame, BetterBlizzPlatesSubPanel, L["Party_Pointer"], nil, 430)
    anchorSubPointerIndicator.extendedSettingsButton:SetPoint("TOPLEFT", partyPointerTestMode, "BOTTOMLEFT", 12, -8)

    local partyPointerHideRaidmarker = CreateCheckbox("partyPointerHideRaidmarker", L["No_Raidmarker"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltip(partyPointerHideRaidmarker, L["Tooltip_Hide_Raidmarker_On_Nameplates_With_Party"])

    local partyPointerArenaOnly = CreateCheckbox("partyPointerArenaOnly", L["Arena_Only"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltip(partyPointerArenaOnly, L["Tooltip_Show_In_Arena_Only"])

    local partyPointerBgOnly = CreateCheckbox("partyPointerBgOnly", L["BG_Only"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltip(partyPointerBgOnly, L["Tooltip_Show_In_Battlegrounds_Only"])

    local partyPointerClassColor = CreateCheckbox("partyPointerClassColor", L["Class_Color"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltip(partyPointerClassColor, L["Tooltip_Class_Color_Pointer"])

    local partyPointerTargetIndicator = CreateCheckbox("partyPointerTargetIndicator", L["Target"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(partyPointerTargetIndicator, L["Target_Indicator"], L["Tooltip_Target_Indicator_2_Desc_2"])

    local partyPointerHealer = CreateCheckbox("partyPointerHealer", L["Healer"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltip(partyPointerHealer, L["Tooltip_Show_A_Cross_On_Top_Of"])

    anchorSubPointerIndicator.partyPointerHighlight = CreateCheckbox("partyPointerHighlight", L["Highlight"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlight, L["Highlight"], L["Tooltip_Highlight_Desc"], L["Tooltip_Highlight_SubText"])
    anchorSubPointerIndicator.partyPointerHighlight:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.partyPointerHighlightRGB, BBP.RefreshAllNameplates)
        end
    end)

    local partyPointerHealerReplace = CreateCheckbox("partyPointerHealerReplace", L["Replace"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(partyPointerHealerReplace, L["Replace_Party_Pointer_With_Healer_Icon"], L["Tooltip_Replace_Party_Pointer_With_Healer_Icon_Desc"])

    anchorSubPointerIndicator.partyPointerHealerOnly = CreateCheckbox("partyPointerHealerOnly", L["Heal_Only"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHealerOnly, L["Healer_Only"], L["Tooltip_Healer_Only_Desc"])

    local partyPointerHideAll = CreateCheckbox("partyPointerHideAll", L["Hide_All"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(partyPointerHideAll, L["Hide_All"], L["Tooltip_Hide_All_2_Desc"])

    anchorSubPointerIndicator.partyPointerShowPet = CreateCheckbox("partyPointerShowPet", L["Show_On_Pet"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerShowPet, L["Show_On_Pet"], L["Tooltip_Show_On_Pet_Desc"], L["Tooltip_Show_Pet_SubText"])

    anchorSubPointerIndicator.petOptions = CreateMultiSelectDropdown(L["Pet_Options"], anchorSubPointerIndicator.extendedSettings, {
        { key = "partyPointerAlwaysShowPet", label = L["Show_On_Pet_Always"], tooltip = L["Tooltip_Show_On_Pet_Always_Desc"], tooltipNote = L["Tooltip_Show_Pet_SubText"] },
        { key = "partyPointerShowOthersPets", label = L["Show_On_Pet_Others"], tooltip = L["Tooltip_Show_On_Pet_Others_Desc_2"], tooltipNote = L["Tooltip_Show_Pet_SubText"] },
    }, 150)
    anchorSubPointerIndicator.petOptions.searchParentKey = "partyPointerShowPet"
    anchorSubPointerIndicator.petOptions:SetPoint("LEFT", anchorSubPointerIndicator.partyPointerShowPet.text, "RIGHT", 5, 0)
    anchorSubPointerIndicator.petOptions:SetScale(0.7)
    anchorSubPointerIndicator.UpdatePetOptionsState = function()
        local enabled = anchorSubPointerIndicator.partyPointerShowPet:GetChecked() and true or false
        anchorSubPointerIndicator.petOptions:SetEnabled(enabled)
        anchorSubPointerIndicator.petOptions:SetAlpha(enabled and 1 or 0.5)
    end
    anchorSubPointerIndicator.partyPointerShowPet:HookScript("OnClick", anchorSubPointerIndicator.UpdatePetOptionsState)
    anchorSubPointerIndicator.UpdatePetOptionsState()

    anchorSubPointerIndicator.partyPointerCCAuras = CreateCheckbox("partyPointerCCAuras", L["Show_CC"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerCCAuras, L["Show_CC"], L["Tooltip_Show_CC_Desc"], L["Tooltip_Show_CC_SubText"])
    anchorSubPointerIndicator.partyPointerCCAuras:HookScript("OnClick", function(self)
        BBP.RefreshAllNameplateAuras()
    end)

    anchorSubPointerIndicator.partyPointerOnlyParty = CreateCheckbox("partyPointerOnlyParty", L["Party_Only"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerOnlyParty, L["Party_Only"], L["Tooltip_Party_Only_Desc"])

    anchorSubPointerIndicator.partyPointerHighlightScale = CreateSlider(anchorSubPointerIndicator.extendedSettings, L["PP_Highlight_Size"], 0.8, 1.7, 0.01, "partyPointerHighlightScale")
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlightScale, L["Change_The_Size_Of_The_Highlight_Requires_Highlight"])

    anchorSubPointerIndicator.partyPointerTexture = CreateSlider(anchorSubPointerIndicator.extendedSettings, L["Party_Pointer_Texture"], 1, 14, 1, "partyPointerTexture")
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerTexture, L["Change_Party_Pointer_Texture"])
    anchorSubPointerIndicator.partyPointerCustomTextureBox = CreateFrame("EditBox", nil, anchorSubPointerIndicator.extendedSettings, "InputBoxTemplate")
    anchorSubPointerIndicator.partyPointerCustomTextureBox:SetSize(140, 20)
    anchorSubPointerIndicator.partyPointerCustomTextureBox:SetAutoFocus(false)
    anchorSubPointerIndicator.partyPointerCustomTextureBox:Hide()
    anchorSubPointerIndicator.partyPointerCustomTextureBox:SetPoint("TOP", anchorSubPointerIndicator.partyPointerTexture, "BOTTOM", 0, -5)
    anchorSubPointerIndicator.partyPointerCustomTextureBox:SetScript("OnEnterPressed", function(self)
        BetterBlizzPlatesDB.partyPointerCustomTexture = self:GetText()
        BBP.RefreshAllNameplates()
        self:ClearFocus()
    end)
    anchorSubPointerIndicator.partyPointerCustomTextureBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerCustomTextureBox, L["Enter_Custom_Atlas_Name"], L["Tooltip_Enter_Custom_Atlas_Name_Desc"], nil, "ANCHOR_TOP")

    -- Hook the slider to show/hide the edit box
    anchorSubPointerIndicator.partyPointerTexture:HookScript("OnValueChanged", function(self, value)
        if value == 14 then
            anchorSubPointerIndicator.partyPointerCustomTextureBox:SetText(BetterBlizzPlatesDB.partyPointerCustomTexture or "")
            anchorSubPointerIndicator.partyPointerCustomTextureBox:Show()
        else
            anchorSubPointerIndicator.partyPointerCustomTextureBox:Hide()
        end
    end)
    if anchorSubPointerIndicator.partyPointerTexture:GetValue() == 14 then
        anchorSubPointerIndicator.partyPointerCustomTextureBox:Show()
        anchorSubPointerIndicator.partyPointerCustomTextureBox:SetText(BetterBlizzPlatesDB.partyPointerCustomTexture or "Custom")
        anchorSubPointerIndicator.partyPointerCustomTextureBox:SetCursorPosition(0)
    end
    moreCol = anchorSubPointerIndicator.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(partyPointerArenaOnly)
    moreCol.Add(partyPointerBgOnly)
    moreCol.Add(anchorSubPointerIndicator.partyPointerOnlyParty)
    moreCol.Add(anchorSubPointerIndicator.partyPointerHealerOnly)
    moreCol.Add(anchorSubPointerIndicator.partyPointerShowPet)
    moreCol.Header(L["Other"])
    moreCol.Add(partyPointerTargetIndicator)
    moreCol.Add(partyPointerHideAll)
    moreCol.Add(partyPointerHideRaidmarker)
    moreCol.Add(anchorSubPointerIndicator.partyPointerCCAuras)
    moreCol = anchorSubPointerIndicator.extendedSettings.Column(226)
    moreCol.Header(L["Icon"])
    moreCol.Add(partyPointerClassColor)
    moreCol.Add(partyPointerHealer)
    moreCol.Add(partyPointerHealerReplace)
    moreCol.Add(anchorSubPointerIndicator.partyPointerHighlight)
    moreCol.Slider(anchorSubPointerIndicator.partyPointerHighlightScale)
    moreCol.Slider(anchorSubPointerIndicator.partyPointerTexture)
    moreCol.Gap(26)
    anchorSubPointerIndicator.extendedSettings.Fit()

    ----------------------
    -- Fake Name Reposition
    ----------------------
    local anchorSubFakeName = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFakeName:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, thirdLineY)
    anchorSubFakeName:SetText(L["Name_Reposition"])

    CreateBorderBox(anchorSubFakeName)

    anchorSubFakeName.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFakeName.t:SetAtlas("MiniMap-PositionArrows")
    anchorSubFakeName.t:SetSize(32, 44)
    anchorSubFakeName.t:SetPoint("BOTTOM", anchorSubFakeName, "TOP", 0, -3)
    anchorSubFakeName.t:SetRotation(math.pi / 2)
    anchorSubFakeName.t:SetDesaturated(true)
    anchorSubFakeName.t:SetVertexColor(1,1,0.1)

    local useFakeName = CreateCheckbox("useFakeName", L["Enable_Name_Reposition"], contentFrame)

    local fakeNameXPos = CreateSlider(useFakeName, "|cffFF0000" .. L["Enemy_X_Offset"] .. "|r", -50, 50, 1, "fakeNameXPos", "X")
    fakeNameXPos:SetPoint("TOP", anchorSubFakeName, "BOTTOM", 0, -15)

    local fakeNameYPos = CreateSlider(useFakeName, "|cffFF0000" .. L["Enemy_Y_Offset"] .. "|r", -50, 50, 1, "fakeNameYPos", "Y")
    fakeNameYPos:SetPoint("TOP", fakeNameXPos, "BOTTOM", 0, -15)

    local fakeNameFriendlyXPos = CreateSlider(useFakeName, "|cff0CC2FF" .. L["Friendly_X_Offset"] .. "|r", -50, 50, 1, "fakeNameFriendlyXPos", "X")
    fakeNameFriendlyXPos:SetPoint("TOP", fakeNameYPos, "BOTTOM", 0, -15)

    local fakeNameFriendlyYPos = CreateSlider(useFakeName, "|cff0CC2FF" .. L["Friendly_Y_Offset"] .. "|r", -50, 50, 1, "fakeNameFriendlyYPos", "Y")
    fakeNameFriendlyYPos:SetPoint("TOP", fakeNameFriendlyXPos, "BOTTOM", 0, -15)

    local fakeNameAnchorDropdown = CreateAnchorDropdown(
        "partyPointerDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "fakeNameAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameFriendlyYPos, x = -16, y = -33, label = L["Enemy_Name"] },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(fakeNameAnchorDropdown, L["Enemy_Name_Anchor_Point"], L["Tooltip_Enemy_Name_Anchor_Point_Desc"])

    local fakeNameAnchorFriendlyDropdown = CreateAnchorDropdown(
        "fakeNameAnchorFriendlyDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "fakeNameAnchorFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameFriendlyYPos, x = 58, y = -33, label = L["Friend_Name"] },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(fakeNameAnchorFriendlyDropdown, L["Friendly_Name_Anchor_Point"], L["Tooltip_Friendly_Name_Anchor_Point_Desc"])

    local fakeNameAnchorRelativeDropdown = CreateAnchorDropdown(
        "arenaSpecAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "fakeNameAnchorRelative",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameAnchorDropdown, x = 0, y = -41, label = L["Enemy_HP"] },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(fakeNameAnchorRelativeDropdown, L["Enemy_Healthbar_Anchor_Point"], L["Tooltip_Enemy_Healthbar_Anchor_Point_Desc"])

    local fakeNameAnchorRelativeFriendlyDropdown = CreateAnchorDropdown(
        "fakeNameAnchorRelativeFriendlyDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "fakeNameAnchorRelativeFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameAnchorFriendlyDropdown, x = 0, y = -41, label = L["Friend_HP"] },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(fakeNameAnchorRelativeFriendlyDropdown, L["Friendly_Healthbar_Anchor_Point"], L["Tooltip_Friendly_Healthbar_Anchor_Point_Desc"])

    local fakeNameDropdowns = {
        fakeNameAnchorDropdown,
        fakeNameAnchorFriendlyDropdown,
        fakeNameAnchorRelativeDropdown,
        fakeNameAnchorRelativeFriendlyDropdown,
    }

    useFakeName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            for _, dropdown in ipairs(fakeNameDropdowns) do
                dropdown:Enable()
            end
            if BetterBlizzPlates.arenaSpecAnchor == "TOP" then
                BetterBlizzPlates.arenaSpecAnchor = "CENTER"
            end
        else
            for _, dropdown in ipairs(fakeNameDropdowns) do
                dropdown:Disable()
            end
            if BetterBlizzPlates.arenaSpecAnchor == "CENTER" then
                BetterBlizzPlates.arenaSpecAnchor = "TOP"
            end
        end
        BBP.arenaSpecAnchorDropdown:GenerateMenu()
    end)

    if not BetterBlizzPlatesDB.useFakeName then
        for _, dropdown in ipairs(fakeNameDropdowns) do
            dropdown:Disable()
        end
    end

    --local useFakeName = CreateCheckbox("useFakeName", "Enable Name Reposition", contentFrame) --moved up
    useFakeName:SetPoint("TOPLEFT", fakeNameAnchorRelativeDropdown, "BOTTOMLEFT", 16, 8)
    useFakeName:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(useFakeName)
    end)
    CreateTooltip(useFakeName, L["Tooltip_Enables_Name_Repositioning_By_Using_A"])
    CreateTooltip(anchorSubFakeName.t, L["Tooltip_Enables_Name_Repositioning_By_Using_A"])

    CreateMoreOptionsPopup(anchorSubFakeName, contentFrame, BetterBlizzPlatesSubPanel, L["Name_Reposition"], nil, 220)
    anchorSubFakeName.extendedSettingsButton:SetPoint("TOPLEFT", useFakeName, "BOTTOMLEFT", 12, 5)

    local useFakeNameAnchorBottom = CreateCheckbox("useFakeNameAnchorBottom", L["Anchor_Friend"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(useFakeNameAnchorBottom, L["Anchor_Friendly_Name_To_Bottom"], L["Tooltip_Anchor_Friendly_Name_To_Bottom_Desc"])

    local fakeNameScaleWithParent = CreateCheckbox("fakeNameScaleWithParent", L["Scale"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(fakeNameScaleWithParent, L["Scale_With_Nameplate"], L["Tooltip_Scale_With_Nameplate_Desc"])

    local fakeNameRaiseStrata = CreateCheckbox("fakeNameRaiseStrata", L["Raise_Strata"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(fakeNameRaiseStrata, L["Raise_Strata"], L["Tooltip_Raise_Strata_Desc_2"])
    fakeNameRaiseStrata:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    anchorSubFakeName.fakeNameMaxWidthOn = CreateCheckbox("fakeNameMaxWidthOn", L["Max_Width"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(anchorSubFakeName.fakeNameMaxWidthOn, L["Max_Width"], L["Tooltip_Max_Width_Desc"])
    anchorSubFakeName.fakeNameMaxWidthOn:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        BBP.RefreshAllNameplates()
    end)

    anchorSubFakeName.fakeNameMaxWidthSlider = CreateSlider(anchorSubFakeName.fakeNameMaxWidthOn, L["Max_Width"], 25, 400, 1, "fakeNameMaxWidth", false, 120)

    moreCol = anchorSubFakeName.extendedSettings.Column(16)
    moreCol.Header(L["Friendly"])
    moreCol.Add(useFakeNameAnchorBottom)
    moreCol.Header(L["Other"])
    moreCol.Add(fakeNameScaleWithParent)
    moreCol.Add(fakeNameRaiseStrata)
    moreCol.Header(L["Max_Width"])
    moreCol.Add(anchorSubFakeName.fakeNameMaxWidthOn)
    moreCol.Slider(anchorSubFakeName.fakeNameMaxWidthSlider)
    anchorSubFakeName.extendedSettings.Fit()

    anchorSubFakeName.UpdatePopupState = function()
        local enabled = useFakeName:GetChecked()
        for _, checkbox in ipairs({ useFakeNameAnchorBottom, fakeNameScaleWithParent, fakeNameRaiseStrata, anchorSubFakeName.fakeNameMaxWidthOn }) do
            if enabled then EnableElement(checkbox) else DisableElement(checkbox) end
        end
        if enabled and anchorSubFakeName.fakeNameMaxWidthOn:GetChecked() then
            EnableElement(anchorSubFakeName.fakeNameMaxWidthSlider)
        else
            DisableElement(anchorSubFakeName.fakeNameMaxWidthSlider)
        end
    end
    anchorSubFakeName.UpdatePopupState()
    useFakeName:HookScript("OnClick", anchorSubFakeName.UpdatePopupState)

    ----------------------
    -- Health Numbers
    ----------------------
    local anchorSubHealthNumbers = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHealthNumbers:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubHealthNumbers:SetText(L["Health_Numbers"])

    anchorSubHealthNumbers.border = CreateBorderBox(anchorSubHealthNumbers)

    anchorSubHealthNumbers.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubHealthNumbers.t:SetAtlas("ui_adv_health")
    anchorSubHealthNumbers.t:SetSize(44, 44)
    anchorSubHealthNumbers.t:SetPoint("BOTTOM", anchorSubHealthNumbers, "TOP", 0, -5)

    local healthNumbersScale = CreateSlider(contentFrame, L["Size"], 0.5, 2.5, 0.01, "healthNumbersScale")
    healthNumbersScale:SetPoint("TOP", anchorSubHealthNumbers, "BOTTOM", 0, -15)

    local healthNumbersXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "healthNumbersXPos", "X")
    healthNumbersXPos:SetPoint("TOP", healthNumbersScale, "BOTTOM", 0, -15)

    local healthNumbersYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "healthNumbersYPos", "Y")
    healthNumbersYPos:SetPoint("TOP", healthNumbersXPos, "BOTTOM", 0, -15)

    local healthNumbersDropdown = CreateAnchorDropdown(
        "healthNumbersDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "healthNumbersAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = healthNumbersYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local healthNumbersTestMode = CreateCheckbox("healthNumbersTestMode", L["Test"], contentFrame)
    healthNumbersTestMode:SetPoint("TOPLEFT", healthNumbersDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local healthNumbersFriendly = CreateCheckbox("healthNumbersFriendly", L["Friendly"], contentFrame)
    healthNumbersFriendly:SetPoint("LEFT", healthNumbersTestMode.text, "RIGHT", 20, 0)
    CreateTooltip(healthNumbersFriendly, L["Show_On_Friendly_Nameplates"])

    local healthNumbersPercentage = CreateCheckbox("healthNumbersPercentage", L["Percent"], contentFrame)
    healthNumbersPercentage:SetPoint("TOPLEFT", healthNumbersTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersPercentage, L["Show_Percent"], L["Tooltip_Show_Percent_Desc"])

    local healthNumbersPercentSymbol = CreateCheckbox("healthNumbersPercentSymbol", L["Pct_Symbol"], contentFrame)
    healthNumbersPercentSymbol:SetPoint("TOPLEFT", healthNumbersFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersPercentSymbol, L["Show_Percent_Symbol"], L["Tooltip_Show_Percent_Symbol_Desc"])

    local healthNumbersShowDecimal = CreateCheckbox("healthNumbersShowDecimal", L["Decimal"], contentFrame)
    healthNumbersShowDecimal:SetPoint("TOPLEFT", healthNumbersPercentage, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(healthNumbersShowDecimal, L["Tooltip_Show_Decimal"])

    local healthNumbersNotOnFullHp = CreateCheckbox("healthNumbersNotOnFullHp", "< 100%", contentFrame)
    healthNumbersNotOnFullHp:SetPoint("TOPLEFT", healthNumbersPercentSymbol, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersNotOnFullHp, L["Hide_On_Full_HP"], L["Tooltip_Hide_On_Full_HP_Desc"])

    -- Extended Settings Button
    anchorSubHealthNumbers.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    anchorSubHealthNumbers.extendedSettingsButton:SetSize(120, 25)
    anchorSubHealthNumbers.extendedSettingsButton:SetPoint("TOP", anchorSubHealthNumbers, "BOTTOM", 0, -212)
    anchorSubHealthNumbers.extendedSettingsButton:SetText(L["More_Options"])
    CreateTooltip(anchorSubHealthNumbers.extendedSettingsButton, L["Tooltip_Open_More_Settings_For_Health_Numbers"])

    -- Extended Settings Frame
    anchorSubHealthNumbers.extendedSettings = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel, "DefaultPanelFlatTemplate")
    -- anchorSubHealthNumbers.extendedSettings:SetAllPoints(anchorSubHealthNumbers.border)
    anchorSubHealthNumbers.extendedSettings:SetSize(anchorSubHealthNumbers.border:GetHeight()+40, 360)
    anchorSubHealthNumbers.extendedSettings:SetPoint("BOTTOMRIGHT", anchorSubHealthNumbers.border, "BOTTOMLEFT", 87, -125)
    anchorSubHealthNumbers.extendedSettings:SetFrameStrata("FULLSCREEN_DIALOG")
    anchorSubHealthNumbers.extendedSettings:SetFrameLevel(550)
    anchorSubHealthNumbers.extendedSettings:SetIgnoreParentAlpha(true)
    anchorSubHealthNumbers.extendedSettings:EnableMouse(true)
    anchorSubHealthNumbers.extendedSettings:Hide()
    anchorSubHealthNumbers.extendedSettings.name = L["Module_Name_Advanced"]
    anchorSubHealthNumbers.extendedSettings:SetTitle(L["Health_Numbers"])
    anchorSubHealthNumbers.extendedSettings:SetMovable(true)
    anchorSubHealthNumbers.extendedSettings:SetClampedToScreen(true)
    anchorSubHealthNumbers.extendedSettings:RegisterForDrag("LeftButton")
    anchorSubHealthNumbers.extendedSettings:SetScript("OnDragStart", function(self) self:StartMoving() end)
    anchorSubHealthNumbers.extendedSettings:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    anchorSubHealthNumbers.closeButton = CreateFrame("Button", nil, anchorSubHealthNumbers.extendedSettings, "UIPanelCloseButton")
    anchorSubHealthNumbers.closeButton:SetFrameLevel((anchorSubHealthNumbers.extendedSettings.TitleContainer or anchorSubHealthNumbers.extendedSettings):GetFrameLevel() + 10)
    anchorSubHealthNumbers.closeButton:SetPoint("TOPRIGHT", anchorSubHealthNumbers.extendedSettings, "TOPRIGHT", 0, 0)
    anchorSubHealthNumbers.closeButton:SetScript("OnClick", function()
        anchorSubHealthNumbers.extendedSettings:Hide()
        contentFrame:SetAlpha(1)
    end)

    anchorSubHealthNumbers.bg = anchorSubHealthNumbers.extendedSettings:CreateTexture(nil, "BACKGROUND")
    anchorSubHealthNumbers.bg:SetPoint("TOPLEFT", anchorSubHealthNumbers.extendedSettings, "TOPLEFT", 7, -3)
    anchorSubHealthNumbers.bg:SetPoint("BOTTOMRIGHT", anchorSubHealthNumbers.extendedSettings, "BOTTOMRIGHT", -3, 3)
    anchorSubHealthNumbers.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    anchorSubHealthNumbers.extendedSettingsButton:HookScript("OnClick", function(self)
        anchorSubHealthNumbers.extendedSettings:SetShown(not anchorSubHealthNumbers.extendedSettings:IsShown())
        contentFrame:SetAlpha(anchorSubHealthNumbers.extendedSettings:IsShown() and 0.5 or 1)
    end)

    anchorSubHealthNumbers.healthNumbersRawNumbers = CreateCheckbox("healthNumbersRawNumbers", L["Raw_Numbers"], anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersRawNumbers:SetPoint("TOPLEFT", anchorSubHealthNumbers.extendedSettings, "TOPLEFT", 10, -23)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersRawNumbers, L["Raw_Numbers"], L["Tooltip_Raw_Numbers_Desc"])

    anchorSubHealthNumbers.healthNumbersUseMillions = CreateCheckbox("healthNumbersUseMillions", L["Format_Million"], anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersUseMillions:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersRawNumbers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersUseMillions, L["Format_Million"], L["Tooltip_Format_Million_Desc"])

    anchorSubHealthNumbers.healthNumbersRawNumbers:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.healthNumbersUseMillions = false
            anchorSubHealthNumbers.healthNumbersUseMillions:SetChecked(false)
        end
    end)

    anchorSubHealthNumbers.healthNumbersUseMillions:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.healthNumbersRawNumbers = false
            anchorSubHealthNumbers.healthNumbersRawNumbers:SetChecked(false)
        end
    end)

    local healthNumbersCurrentFull = CreateCheckbox("healthNumbersCurrentFull", L["Current_Max"], anchorSubHealthNumbers.extendedSettings)
    healthNumbersCurrentFull:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersUseMillions, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersCurrentFull, L["Current_Max"], L["Tooltip_Current_Max_Desc"])

    local healthNumbersCombined = CreateCheckbox("healthNumbersCombined", L["Health_Percent"], anchorSubHealthNumbers.extendedSettings)
    healthNumbersCombined:SetPoint("TOPLEFT", healthNumbersCurrentFull, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersCombined, L["Health_Percent"], L["Tooltip_Health_Percent_Desc"])

    local healthNumbersOnlyInCombat = CreateCheckbox("healthNumbersOnlyInCombat", L["Only_In_Combat"], anchorSubHealthNumbers.extendedSettings)
    healthNumbersOnlyInCombat:SetPoint("TOPLEFT", healthNumbersCombined, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersOnlyInCombat, L["Only_In_Combat"], L["Tooltip_Only_In_Combat_Desc"])

    local healthNumbersSwapped = CreateCheckbox("healthNumbersSwapped", L["Swap_Numbers"], anchorSubHealthNumbers.extendedSettings)
    healthNumbersSwapped:SetPoint("TOPLEFT", healthNumbersOnlyInCombat, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersSwapped, L["Swap_Numbers"], L["Tooltip_Swap_Numbers_Desc"])

    local healthNumbersTargetOnly = CreateCheckbox("healthNumbersTargetOnly", L["Show_On_Target_Only"], anchorSubHealthNumbers.extendedSettings)
    healthNumbersTargetOnly:SetPoint("TOPLEFT", healthNumbersSwapped, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersTargetOnly, L["Show_On_Target_Only"], L["Tooltip_Show_On_Target_Only_Desc"])

    anchorSubHealthNumbers.healthNumbersPlayers = CreateCheckbox("healthNumbersPlayers", L["Enable_On_Players"], anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersPlayers:SetPoint("TOPLEFT", healthNumbersTargetOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersPlayers, L["Players"], L["Tooltip_Players_Desc"])

    anchorSubHealthNumbers.healthNumbersHideSelf = CreateCheckbox("healthNumbersHideSelf", L["Hide_On_Personal"], anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersHideSelf:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersPlayers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersHideSelf, L["Hide_On_Personal_Resource_Display"], L["Tooltip_Hide_On_Personal_Resource_Display_Desc"])

    anchorSubHealthNumbers.healthNumbersNpcs = CreateCheckbox("healthNumbersNpcs", L["Enable_On_NPCs"], anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersNpcs:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersHideSelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersNpcs, L["Enable_On_NPCs"], L["Tooltip_Enable_On_NPCs_Desc"])

    anchorSubHealthNumbers.healthNumbersClassColor = CreateCheckbox("healthNumbersClassColor", L["Class_Color_Text"], anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersClassColor:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersNpcs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersClassColor, L["Class_Color_Text"], L["Tooltip_Class_Color_Text_Desc"])

    anchorSubHealthNumbers.healthNumbersTextJustify = CreateAnchorDropdown(
        "healthNumbersTextJustifyDropdown",
        anchorSubHealthNumbers.extendedSettings,
        L["Select_Text_Alignment"],
        "healthNumbersJustify",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = anchorSubHealthNumbers.healthNumbersClassColor, x = 0, y = -45, label = L["Text_Alignment"] },nil,nil,{"CENTER", "LEFT", "RIGHT"}
    )


    anchorSubHealthNumbers.healthNumbersFontOutline = CreateAnchorDropdown(
        "healthNumbersFontOutlineDropdown",
        anchorSubHealthNumbers.extendedSettings,
        L["Select_Font_Outline"],
        "healthNumbersFontOutline",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = anchorSubHealthNumbers.healthNumbersTextJustify, x = 0, y = -45, label = L["Font_Outline"] },nil,nil,{"THICKOUTLINE", "OUTLINE"}
    )

    ----------------------
    -- Threat Colors
    ----------------------
    local anchorThreatColor = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorThreatColor:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, fifthLineY)
    anchorThreatColor:SetText(L["Threat_Colors"])

    CreateBorderBox(anchorThreatColor)

    anchorThreatColor.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorThreatColor.t:SetAtlas("Raid")
    anchorThreatColor.t:SetSize(30, 30)
    anchorThreatColor.t:SetPoint("BOTTOM", anchorThreatColor, "TOP", 0, 2)

    local tankFullAggroColorRGB = CreateColorBox(contentFrame, "tankFullAggroColorRGB", L["Tank_Full_Aggro"])
    tankFullAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor, "BOTTOMLEFT", -28, -5)

    anchorThreatColor.tankLosingAggroColorRGB = CreateColorBox(contentFrame, "tankLosingAggroColorRGB", L["Tank_Losing_Aggro"])
    anchorThreatColor.tankLosingAggroColorRGB:SetPoint("TOPLEFT", tankFullAggroColorRGB, "BOTTOMLEFT", 0, -2)

    anchorThreatColor.tankOffTankAggroColorRGB = CreateColorBox(contentFrame, "tankOffTankAggroColorRGB", L["Tank_Off_Tank_Aggro"])
    anchorThreatColor.tankOffTankAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor.tankLosingAggroColorRGB, "BOTTOMLEFT", 0, -2)

    local tankNoAggroColorRGB = CreateColorBox(contentFrame, "tankNoAggroColorRGB", L["Tank_No_Aggro"])
    tankNoAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor.tankOffTankAggroColorRGB, "BOTTOMLEFT", 0, -2)

    local dpsOrHealFullAggroColorRGB = CreateColorBox(contentFrame, "dpsOrHealFullAggroColorRGB", L["DPS_Heal_Full_Aggro"])
    dpsOrHealFullAggroColorRGB:SetPoint("TOPLEFT", tankNoAggroColorRGB, "BOTTOMLEFT", 0, -8)

    anchorThreatColor.dpsOrHealTargetAggroColorRGB = CreateColorBox(contentFrame, "dpsOrHealTargetAggroColorRGB", L["DPS_Heal_Targeted"])
    anchorThreatColor.dpsOrHealTargetAggroColorRGB:SetPoint("TOPLEFT", dpsOrHealFullAggroColorRGB, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(anchorThreatColor.dpsOrHealTargetAggroColorRGB, L["Color_When_Being_Targeted_But_Without_Aggro"])

    local dpsOrHealNoAggroColorRGB = CreateColorBox(contentFrame, "dpsOrHealNoAggroColorRGB", L["DPS_Heal_No_Aggro"])
    dpsOrHealNoAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor.dpsOrHealTargetAggroColorRGB, "BOTTOMLEFT", 0, -2)

    anchorThreatColor.threatColorAlwaysOn = CreateCheckbox("threatColorAlwaysOn", L["Always_On"], contentFrame)
    anchorThreatColor.threatColorAlwaysOn:SetPoint("TOPLEFT", dpsOrHealNoAggroColorRGB, "BOTTOMLEFT", 0, 0)
    CreateTooltipTwo(anchorThreatColor.threatColorAlwaysOn, L["Always_On"], L["Tooltip_Always_On_Desc"])

    anchorThreatColor.enemyColorThreatCombatOnly = CreateCheckbox("enemyColorThreatCombatOnly", L["Combat_Only"], contentFrame)
    anchorThreatColor.enemyColorThreatCombatOnly:SetPoint("TOPLEFT", anchorThreatColor.threatColorAlwaysOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatCombatOnly, L["Combat_Only"], L["Tooltip_Combat_Only_Desc"])

    anchorThreatColor.enemyColorThreatCombatOnlyPlayer = CreateCheckbox("enemyColorThreatCombatOnlyPlayer", L["Player_Combat_Only"], contentFrame)
    anchorThreatColor.enemyColorThreatCombatOnlyPlayer:SetPoint("TOPLEFT", anchorThreatColor.enemyColorThreatCombatOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatCombatOnlyPlayer, L["Player_Combat_Only"], L["Tooltip_Player_Combat_Only_2_Desc"])

    anchorThreatColor.enemyColorThreatHideSolo = CreateCheckbox("enemyColorThreatHideSolo", L["Turn_Off_While_Solo"], contentFrame)
    anchorThreatColor.enemyColorThreatHideSolo:SetPoint("TOPLEFT", anchorThreatColor.enemyColorThreatCombatOnlyPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatHideSolo, L["Turn_Off_While_Solo"], L["Tooltip_Turn_Off_While_Solo_Desc"])

    anchorThreatColor.threatColorRoleOnly = CreateCheckbox("threatColorRoleOnly", L["Specific_Role_Only"], contentFrame)
    anchorThreatColor.threatColorRoleOnly:SetPoint("TOPLEFT", anchorThreatColor.enemyColorThreatHideSolo, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.threatColorRoleOnly, L["Specific_Role_Only"], L["Tooltip_Specific_Role_Only_Desc"])
    anchorThreatColor.threatColorRoleOnly:SetScript("OnMouseDown", function(self, button)
        if button ~= "RightButton" then return end
        GameTooltip:Hide()
        local window = anchorThreatColor.roleWindow
        if window then
            window:SetShown(not window:IsShown())
            return
        end
        window = CreateFrame("Frame", "BBPThreatColorRoleFrame", UIParent, "DefaultPanelFlatTemplate")
        anchorThreatColor.roleWindow = window
        window:SetSize(190, 120)
        window:SetPoint("CENTER")
        window:SetFrameStrata("FULLSCREEN_DIALOG")
        window:SetFrameLevel(550)
        window:SetIgnoreParentAlpha(true)
        window:SetTitle(L["Specific_Role_Only"])
        window:EnableMouse(true)
        window:SetMovable(true)
        window:SetClampedToScreen(true)
        window:RegisterForDrag("LeftButton")
        window:SetScript("OnDragStart", window.StartMoving)
        window:SetScript("OnDragStop", window.StopMovingOrSizing)

        window.closeButton = CreateFrame("Button", nil, window, "UIPanelCloseButton")
        window.closeButton:SetFrameLevel((window.TitleContainer or window):GetFrameLevel() + 10)
        window.closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
        window.closeButton:SetScript("OnClick", function() window:Hide() end)

        window.bg = window:CreateTexture(nil, "BACKGROUND")
        window.bg:SetPoint("TOPLEFT", window, "TOPLEFT", 7, -3)
        window.bg:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -3, 3)
        window.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

        window.tank = CreateCheckbox("threatColorRoleTank", L["Tank"], window)
        window.tank:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -30)
        window.dps = CreateCheckbox("threatColorRoleDps", L["DPS"], window)
        window.dps:SetPoint("TOPLEFT", window.tank, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        window.heal = CreateCheckbox("threatColorRoleHeal", L["Heal"], window)
        window.heal:SetPoint("TOPLEFT", window.dps, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        window:Show()
    end)


    ----------------------
    -- Target Text
    ----------------------
    local anchorSubTargetText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTargetText:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, fifthLineY)
    anchorSubTargetText:SetText(L["Target_Text"])

    anchorSubTargetText.border = CreateBorderBox(anchorSubTargetText)

    anchorSubTargetText.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubTargetText.t:SetAtlas("TargetCrosshairs")
    anchorSubTargetText.t:SetSize(60, 60)
    anchorSubTargetText.t:SetPoint("BOTTOM", anchorSubTargetText, "TOP", 11, -23)

    anchorSubTargetText.s1 = CreateSlider(contentFrame, L["Font_Size"], 4, 20, 1, "npTargetTextSize", false, 72)
    anchorSubTargetText.s1:SetPoint("TOP", anchorSubTargetText, "BOTTOM", -36, -15)
    anchorSubTargetText.s1.Text:SetTextColor(1,0,0)
    CreateTooltip(anchorSubTargetText.s1, L["Tooltip_Enemy_Font_Size"])

    anchorSubTargetText.s2 = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "npTargetTextXPos", "X", 72)
    anchorSubTargetText.s2:SetPoint("TOP", anchorSubTargetText.s1, "BOTTOM", 0, -15)
    anchorSubTargetText.s2.Text:SetTextColor(1,0,0)
    CreateTooltip(anchorSubTargetText.s2, L["Enemy_X_Offset"])

    anchorSubTargetText.s3 = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "npTargetTextYPos", "Y", 72)
    anchorSubTargetText.s3:SetPoint("TOP", anchorSubTargetText.s2, "BOTTOM", 0, -15)
    anchorSubTargetText.s3.Text:SetTextColor(1,0,0)
    CreateTooltip(anchorSubTargetText.s3, L["Enemy_Y_Offset"])

    anchorSubTargetText.fs1 = CreateSlider(contentFrame, L["Font_Size"], 4, 20, 1, "npTargetTextFriendlySize", false, 72)
    anchorSubTargetText.fs1:SetPoint("TOP", anchorSubTargetText, "BOTTOM", 36, -15)
    anchorSubTargetText.fs1.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubTargetText.fs1, L["Tooltip_Friendly_Font_Size"])

    anchorSubTargetText.fs2 = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "npTargetTextFriendlyXPos", "X", 72)
    anchorSubTargetText.fs2:SetPoint("TOP", anchorSubTargetText.fs1, "BOTTOM", 0, -15)
    anchorSubTargetText.fs2.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubTargetText.fs2, L["Friendly_X_Offset"])

    anchorSubTargetText.fs3 = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "npTargetTextFriendlyYPos", "Y", 72)
    anchorSubTargetText.fs3:SetPoint("TOP", anchorSubTargetText.fs2, "BOTTOM", 0, -15)
    anchorSubTargetText.fs3.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubTargetText.fs3, L["Friendly_Y_Offset"])

    anchorSubTargetText.dropdown = CreateAnchorDropdown(
        "targetTextAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "targetTextAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.fs3, x = -90, y = -35, label = L["Enemy"] },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdown, L["Enemy_Anchor_Point"], L["Tooltip_Enemy_Anchor_Point_Desc"])
    CreateTooltipTwo(anchorSubTargetText.dropdown.label, L["Enemy_Anchor_Point"], L["Tooltip_Enemy_Anchor_Point_Desc"])

    anchorSubTargetText.dropdownFriendly = CreateAnchorDropdown(
        "targetTextFriendlyAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "targetTextFriendlyAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.fs3, x = -16, y = -35, label = L["Friendly"] },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendly, L["Friendly_Anchor_Point"], L["Tooltip_Enemy_Anchor_Point_Desc"])
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendly.label, L["Friendly_Anchor_Point"], L["Tooltip_Enemy_Anchor_Point_Desc"])

    anchorSubTargetText.dropdownRelative = CreateAnchorDropdown(
        "targetTextRelativeAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "targetTextRelativeAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.dropdown, x = 0, y = -45, label = L["Relative"] },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdownRelative, L["Enemy_Relative_Point"], L["Tooltip_Enemy_Relative_Point_Desc"])
    CreateTooltipTwo(anchorSubTargetText.dropdownRelative.label, L["Enemy_Relative_Point"], L["Tooltip_Enemy_Relative_Point_Desc"])

    anchorSubTargetText.dropdownFriendlyRelative = CreateAnchorDropdown(
        "targetTextFriendlyRelativeAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "targetTextFriendlyRelativeAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.dropdownFriendly, x = 0, y = -45, label = L["Relative"] },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendlyRelative, L["Friendly_Relative_Point"], L["Tooltip_Enemy_Relative_Point_Desc"])
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendlyRelative.label, L["Friendly_Relative_Point"], L["Tooltip_Enemy_Relative_Point_Desc"])

    CreateMoreOptionsPopup(anchorSubTargetText, contentFrame, BetterBlizzPlatesSubPanel, L["Target_Text"], nil, 240)

    anchorSubTargetText.c1 = CreateCheckbox("targetTextAlwaysShow", L["Always_On"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.ToggleTargetTextAlwaysShow()
        BBP.RefreshAllNameplates()
    end)
    CreateTooltipTwo(anchorSubTargetText.c1, L["Always_Show_Target_Text"], L["Tooltip_Always_Show_Target_Text_Desc"])

    anchorSubTargetText.static = CreateCheckbox("targetTextStatic", L["Static"], anchorSubTargetText.extendedSettings)
    CreateTooltipTwo(anchorSubTargetText.static, L["Static_Position"], L["Tooltip_Static_Position_Desc"])

    anchorSubTargetText.c1pvp = CreateCheckbox("targetTextAlwaysShowPvP", L["Toggle_PvP"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)
    CreateTooltip(anchorSubTargetText.c1pvp, L["Tooltip_Always_On_Mode_Active_In_PvP"])

    anchorSubTargetText.c1pve = CreateCheckbox("targetTextAlwaysShowPvE", L["Toggle_PvE"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c1pve:SetPoint("LEFT", anchorSubTargetText.c1pvp.text, "RIGHT", 0, 0)
    CreateTooltip(anchorSubTargetText.c1pve, L["Tooltip_Always_On_Mode_Active_In_PvE"])

    anchorSubTargetText.c1world = CreateCheckbox("targetTextAlwaysShowWorld", L["Toggle_World"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c1world:SetPoint("LEFT", anchorSubTargetText.c1pve.text, "RIGHT", 0, 0)
    CreateTooltip(anchorSubTargetText.c1world, L["Tooltip_Always_On_Mode_Active_In_The"])

    local function ToggleTargetTextAlwaysShowSubSettings()
        local enabled = BetterBlizzPlatesDB.targetTextAlwaysShow
        if enabled then
            EnableElement(anchorSubTargetText.c1pvp)
            EnableElement(anchorSubTargetText.c1pve)
            EnableElement(anchorSubTargetText.c1world)
        else
            DisableElement(anchorSubTargetText.c1pvp)
            DisableElement(anchorSubTargetText.c1pve)
            DisableElement(anchorSubTargetText.c1world)
        end
    end
    ToggleTargetTextAlwaysShowSubSettings()

    anchorSubTargetText.c1:HookScript("OnClick", function()
        ToggleTargetTextAlwaysShowSubSettings()
    end)

    anchorSubTargetText.c3 = CreateCheckbox("targetTextEnemy", L["Enemy"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)
    CreateTooltip(anchorSubTargetText.c3, L["Tooltip_Show_Target_Text_On_Enemy_Nameplates"])

    anchorSubTargetText.c4 = CreateCheckbox("targetTextFriendly", L["Friendly"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c4:SetPoint("LEFT", anchorSubTargetText.c3.text, "RIGHT", 0, 0)
    CreateTooltip(anchorSubTargetText.c4, L["Tooltip_Show_Target_Text_On_Friendly_Nameplates"])

    anchorSubTargetText.testMode = CreateCheckbox("targetTextTestMode", L["Test"], contentFrame)
    anchorSubTargetText.testMode:SetPoint("TOPLEFT", anchorSubTargetText.dropdownRelative, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    anchorSubTargetText.extendedSettingsButton:SetPoint("TOPLEFT", anchorSubTargetText.testMode, "BOTTOMLEFT", 12, -8)
    anchorSubTargetText.testMode:SetScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.targetTextTestMode = true
            BBP.RefreshAllNameplates()
        else
            BetterBlizzPlatesDB.targetTextTestMode = false
            BBP.RefreshAllNameplates()
        end
    end)
    anchorSubTargetText.testMode:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzPlatesDB.nameplateCastbarTestMode then
                BetterBlizzPlatesDB.nameplateCastbarTestMode = true
                BBP.nameplateCastBarTestMode()
                BBP.nameplateCastBarTestMode()
            else
                BetterBlizzPlatesDB.nameplateCastbarTestMode = false
                BBP.cancelTimers()
            end
            C_Timer.After(0.05, function()
                BBP.RefreshAllNameplates()
            end)
        end
    end)
    CreateTooltipTwo(anchorSubTargetText.testMode, L["Test_Target_Text"], L["Tooltip_Test_Target_Text_Desc"])

    anchorSubTargetText.insideBar = CreateCheckbox("castbarTargetTextInsideBar", L["Inside_Bar"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)

    anchorSubTargetText.hideOnNpcs = CreateCheckbox("npTargetTextHideOnNpcs", L["Hide_On_NPCs"], anchorSubTargetText.extendedSettings, nil, function()
        BBP.RefreshAllNameplates()
    end)
    CreateTooltipTwo(anchorSubTargetText.hideOnNpcs, L["Hide_On_NPCs"], L["Tooltip_Hide_On_NPCs_Desc"])
    do
        local playerName = UnitName("player") or "Player"
        local playerClass = UnitClassBase("player")
        local classColor = playerClass and C_ClassColor.GetClassColor(playerClass)
        local coloredName = classColor and classColor:WrapTextInColorCode(playerName) or playerName
        CreateTooltipTwo(anchorSubTargetText.insideBar, L["Target_Text_Inside_Castbar"], string.format(L["Tooltip_Target_Text_Inside_Castbar_Desc"], coloredName))
    end


    moreCol = anchorSubTargetText.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(anchorSubTargetText.c3)
    moreCol.Add(anchorSubTargetText.hideOnNpcs)
    moreCol.Header(L["Always_On"])
    moreCol.Add(anchorSubTargetText.c1)
    moreCol.Add(anchorSubTargetText.c1pvp, 12)
    moreCol.Header(L["Other"])
    moreCol.Add(anchorSubTargetText.static)
    moreCol.Add(anchorSubTargetText.insideBar)
    anchorSubTargetText.extendedSettings.Fit()

    ----------------------
    -- Bg Blitz
    ----------------------
    local anchorSubBlitzIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubBlitzIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubBlitzIndicator:SetText(L["Blitz_Indicator"])

    CreateBorderBox(anchorSubBlitzIndicator)

    anchorSubBlitzIndicator.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubBlitzIndicator.t:SetAtlas("Ping_Chat_Assist")
    anchorSubBlitzIndicator.t:SetSize(29, 29)
    anchorSubBlitzIndicator.t:SetPoint("BOTTOM", anchorSubBlitzIndicator, "TOP", 0, 3)

    anchorSubBlitzIndicator.s1 = CreateSlider(contentFrame, L["Size"], 0.5, 2, 0.01, "bgIndicatorScale")
    anchorSubBlitzIndicator.s1:SetPoint("TOP", anchorSubBlitzIndicator, "BOTTOM", 0, -15)

    anchorSubBlitzIndicator.s2 = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "bgIndicatorXPos", "X")
    anchorSubBlitzIndicator.s2:SetPoint("TOP", anchorSubBlitzIndicator.s1, "BOTTOM", 0, -15)

    anchorSubBlitzIndicator.s3 = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "bgIndicatorYPos", "Y")
    anchorSubBlitzIndicator.s3:SetPoint("TOP", anchorSubBlitzIndicator.s2, "BOTTOM", 0, -15)

    anchorSubBlitzIndicator.dropdown = CreateAnchorDropdown(
        "anchorSubBlitzIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "bgIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = anchorSubBlitzIndicator.s3, x = -16, y = -35, label = L["Anchor"] }
    )

    anchorSubBlitzIndicator.c1 = CreateCheckbox("bgIndicatorEnemyOnly", L["Enemies_Only"], contentFrame)
    anchorSubBlitzIndicator.c1:SetPoint("TOPLEFT", anchorSubBlitzIndicator.dropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubBlitzIndicator.c1, L["Enemies_Only"], L["Tooltip_Enemies_Only_Desc"])

    anchorSubBlitzIndicator.c2 = CreateCheckbox("bgIndicatorShowFlags", L["Show_Flags"], contentFrame)
    anchorSubBlitzIndicator.c2:SetPoint("TOPLEFT", anchorSubBlitzIndicator.c1, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubBlitzIndicator.c2, L["Show_Flags"], L["Tooltip_Show_Flags_Desc"])

    anchorSubBlitzIndicator.c3 = CreateCheckbox("bgIndicatorShowOrbs", L["Show_Orbs"], contentFrame)
    anchorSubBlitzIndicator.c3:SetPoint("TOPLEFT", anchorSubBlitzIndicator.c2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubBlitzIndicator.c3, L["Show_Orbs"], L["Tooltip_Show_Orbs_Desc"])

    -- anchorSubBlitzIndicator.c4 = CreateCheckbox("bgIndicatorShowFlags", "", contentFrame)
    -- anchorSubBlitzIndicator.c4:SetPoint("TOPLEFT", anchorSubBlitzIndicator.c2, "BOTTOMLEFT", 0, -50)
    -- anchorSubBlitzIndicator.c4:SetAlpha(0)
    -- anchorSubBlitzIndicator.c4:SetScript("OnClick", nil)



    ----------------------
    -- Totem Indicator
    ----------------------
    contentFrame.anchorSubTotem = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentFrame.anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, fifthLineY)
    contentFrame.anchorSubTotem:SetText(L["Totem_Indicator"])

    contentFrame.anchorSubTotem.border = CreateBorderBox(contentFrame.anchorSubTotem)

    contentFrame.totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    contentFrame.totemIcon2:SetAtlas("teleportationnetwork-ardenweald-32x32")
    contentFrame.totemIcon2:SetSize(34, 34)
    contentFrame.totemIcon2:SetPoint("BOTTOM", contentFrame.anchorSubTotem, "TOP", 0, 0)

    BBP.totemIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.5, 3, 0.01, "totemIndicatorScale")
    BBP.totemIndicatorScale:SetPoint("TOP", contentFrame.anchorSubTotem, "BOTTOM", 0, -15)
    CreateTooltip( BBP.totemIndicatorScale, L["Tooltip_This_Changes_The_Scale_Of_ALL"], "ANCHOR_LEFT")

    contentFrame.totemIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "totemIndicatorXPos", "X")
    contentFrame.totemIndicatorXPos:SetPoint("TOP",  BBP.totemIndicatorScale, "BOTTOM", 0, -15)

    contentFrame.totemIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "totemIndicatorYPos", "Y")
    contentFrame.totemIndicatorYPos:SetPoint("TOP", contentFrame.totemIndicatorXPos, "BOTTOM", 0, -15)

    contentFrame.totemIndicatorDropdown = CreateAnchorDropdown(
        "totemIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "totemIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = contentFrame.totemIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    contentFrame.totemTestIcons2 = CreateCheckbox("totemIndicatorTestMode", L["Test"], contentFrame)
    contentFrame.totemTestIcons2:SetPoint("TOPLEFT", contentFrame.totemIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    contentFrame.totemIndicatorEnemyOnly = CreateCheckbox("totemIndicatorEnemyOnly", L["Enemies_Only"], contentFrame)
    contentFrame.totemIndicatorEnemyOnly:SetPoint("LEFT", contentFrame.totemTestIcons2.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorEnemyOnly, L["Tooltip_Show_On_Enemy_Totems_Only"])

    contentFrame.totemIndicatorShowOtherIcons = CreateCheckbox("totemIndicatorShowOtherIcons", L["Other_Icons"], contentFrame)
    contentFrame.totemIndicatorShowOtherIcons:SetPoint("TOPLEFT", contentFrame.totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(contentFrame.totemIndicatorShowOtherIcons, L["Show_Icon_On_Non_Important_Totems"], L["Tooltip_Show_Icon_On_Non_Important_Totems_Desc"])

    contentFrame.totemIndicatorColorOtherHealthBars = CreateCheckbox("totemIndicatorColorOtherHealthBars", L["Color_Others"], contentFrame)
    contentFrame.totemIndicatorColorOtherHealthBars:SetPoint("LEFT", contentFrame.totemIndicatorShowOtherIcons.text, "RIGHT", 0, 0)
    CreateTooltipTwo(contentFrame.totemIndicatorColorOtherHealthBars, L["Color_Healthbar_Of_Non_Important_Totems"], L["Tooltip_Color_Healthbar_Of_Non_Important_Totems_Desc"])
    local function OpenTotemNormalColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.totemIndicatorTotemColor or { 0.4, 0.34, 0.21 })
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.totemIndicatorTotemColor = { r, g, b }
                BBP.RefreshAllNameplates()
                BBP.RefreshTotemOthersSwatch()
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.totemIndicatorTotemColor = { r, g, b }
                BBP.RefreshAllNameplates()
                BBP.RefreshTotemOthersSwatch()
            end,
        })
    end
    contentFrame.totemIndicatorColorOtherHealthBars:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenTotemNormalColorPicker()
        end
    end)
    if BetterBlizzPlatesDB.totemIndicatorTotemColor then
        contentFrame.totemIndicatorColorOtherHealthBars.Text:SetTextColor(unpack(BetterBlizzPlatesDB.totemIndicatorTotemColor))
    end

    -- Extended Settings Button
    contentFrame.anchorSubTotem.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    contentFrame.anchorSubTotem.extendedSettingsButton:SetSize(120, 25)
    contentFrame.anchorSubTotem.extendedSettingsButton:SetPoint("TOPLEFT", contentFrame.totemIndicatorShowOtherIcons, "BOTTOMLEFT", 12, -8)
    contentFrame.anchorSubTotem.extendedSettingsButton:SetText(L["More_Options"])
    CreateTooltip(contentFrame.anchorSubTotem.extendedSettingsButton, L["Tooltip_Open_More_Settings_For_Totem_Indicator"])

    -- Extended Settings Frame
    contentFrame.anchorSubTotem.extendedSettings = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel, "DefaultPanelFlatTemplate")
    contentFrame.anchorSubTotem.extendedSettings:SetSize(contentFrame.anchorSubTotem.border:GetHeight()+130, 285)
    contentFrame.anchorSubTotem.extendedSettings:SetPoint("BOTTOMRIGHT", contentFrame.anchorSubTotem.border, "BOTTOMLEFT", 87, -20)
    contentFrame.anchorSubTotem.extendedSettings:SetFrameStrata("FULLSCREEN_DIALOG")
    contentFrame.anchorSubTotem.extendedSettings:SetFrameLevel(550)
    contentFrame.anchorSubTotem.extendedSettings:SetIgnoreParentAlpha(true)
    contentFrame.anchorSubTotem.extendedSettings:EnableMouse(true)
    contentFrame.anchorSubTotem.extendedSettings:Hide()
    contentFrame.anchorSubTotem.extendedSettings.name = L["Module_Name_Advanced"]
    contentFrame.anchorSubTotem.extendedSettings:SetTitle(L["Totem_Indicator"])
    contentFrame.anchorSubTotem.extendedSettings:SetMovable(true)
    contentFrame.anchorSubTotem.extendedSettings:SetClampedToScreen(true)
    contentFrame.anchorSubTotem.extendedSettings:RegisterForDrag("LeftButton")
    contentFrame.anchorSubTotem.extendedSettings:SetScript("OnDragStart", function(self) self:StartMoving() end)
    contentFrame.anchorSubTotem.extendedSettings:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    contentFrame.anchorSubTotem.closeButton = CreateFrame("Button", nil, contentFrame.anchorSubTotem.extendedSettings, "UIPanelCloseButton")
    contentFrame.anchorSubTotem.closeButton:SetFrameLevel((contentFrame.anchorSubTotem.extendedSettings.TitleContainer or contentFrame.anchorSubTotem.extendedSettings):GetFrameLevel() + 10)
    contentFrame.anchorSubTotem.closeButton:SetPoint("TOPRIGHT", contentFrame.anchorSubTotem.extendedSettings, "TOPRIGHT", 0, 0)
    contentFrame.anchorSubTotem.closeButton:SetScript("OnClick", function()
        contentFrame.anchorSubTotem.extendedSettings:Hide()
        contentFrame:SetAlpha(1)
    end)

    contentFrame.anchorSubTotem.bg = contentFrame.anchorSubTotem.extendedSettings:CreateTexture(nil, "BACKGROUND")
    contentFrame.anchorSubTotem.bg:SetPoint("TOPLEFT", contentFrame.anchorSubTotem.extendedSettings, "TOPLEFT", 7, -3)
    contentFrame.anchorSubTotem.bg:SetPoint("BOTTOMRIGHT", contentFrame.anchorSubTotem.extendedSettings, "BOTTOMRIGHT", -3, 3)
    contentFrame.anchorSubTotem.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    contentFrame.anchorSubTotem.extendedSettingsButton:HookScript("OnClick", function(self)
        contentFrame.anchorSubTotem.extendedSettings:SetShown(not contentFrame.anchorSubTotem.extendedSettings:IsShown())
        contentFrame:SetAlpha(contentFrame.anchorSubTotem.extendedSettings:IsShown() and 0.5 or 1)
    end)

    contentFrame.totemIndicatorHideNameAndShiftIconDown = CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", L["Hide_Name"], contentFrame.anchorSubTotem.extendedSettings)
    BBP.totemIndicatorHideName = contentFrame.totemIndicatorHideNameAndShiftIconDown
    contentFrame.totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", contentFrame.anchorSubTotem.extendedSettings, "TOPLEFT", 10, -23)

    contentFrame.totemIndicatorHideHealthBar = CreateCheckbox("totemIndicatorHideHealthBar", L["Hide_HP"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorHideHealthBar:SetPoint("LEFT", contentFrame.totemIndicatorHideNameAndShiftIconDown.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorHideHealthBar, L["Tooltip_Hide_The_Healthbar_On_Totems_Will"])

    contentFrame.totemIndicatorHideCastbar = CreateCheckbox("totemIndicatorHideCastbar", L["Hide_Castbar"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorHideCastbar:SetPoint("LEFT", contentFrame.totemIndicatorHideHealthBar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(contentFrame.totemIndicatorHideCastbar, L["Hide_Castbar_For_Totems"], L["Tooltip_Hide_Castbar_For_Totems_Desc"], "|cFFFFD100" .. L["Tooltip_Hide_Castbar_For_Totems_SubText_2"] .. "|r")

--[=[
    local totemIndicatorDisplayCdText = CreateCheckbox("totemIndicatorDisplayCdText", "CD Text", contentFrame)
    totemIndicatorDisplayCdText:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorDisplayCdText, "Display default Blizz CD Text\n\nWill not work with OmniCC.")
]=]-- cant force use blizzards own countdown it seems, must make own soonTM

    contentFrame.showTotemIndicatorCooldownSwipe = CreateCheckbox("showTotemIndicatorCooldownSwipe", L["CD_Swipe"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.showTotemIndicatorCooldownSwipe:SetPoint("TOPLEFT", contentFrame.totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(contentFrame.showTotemIndicatorCooldownSwipe, L["Tooltip_Show_Cooldown_Swipe_Animation"])

    contentFrame.totemIndicatorColorHealthBar = CreateCheckbox("totemIndicatorColorHealthBar", L["Color_HP"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorColorHealthBar:SetPoint("LEFT", contentFrame.showTotemIndicatorCooldownSwipe.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorColorHealthBar, L["Color_Healthbar"])

    contentFrame.totemIndicatorHideCountdownNumbers = CreateCheckbox("totemIndicatorHideCountdownNumbers", L["No_CD_Text"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorHideCountdownNumbers:SetPoint("LEFT", contentFrame.totemIndicatorColorHealthBar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(contentFrame.totemIndicatorHideCountdownNumbers, L["Hide_Countdown_Numbers"], L["Tooltip_Hide_Countdown_Numbers_Desc"])

    contentFrame.totemIndicatorColorName = CreateCheckbox("totemIndicatorColorName", L["Color_Name"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorColorName:SetPoint("TOPLEFT", contentFrame.showTotemIndicatorCooldownSwipe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(contentFrame.totemIndicatorColorName, L["Tooltip_Color_Name_Text"])

    contentFrame.totemIndicatorHideAuras = CreateCheckbox("totemIndicatorHideAuras", L["Hide_Auras"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorHideAuras:SetPoint("LEFT", contentFrame.totemIndicatorColorName.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorHideAuras, L["Tooltip_Hide_Auras_On_Totem_Nameplates"])

    contentFrame.totemIndicatorColorNameOthers = CreateCheckbox("totemIndicatorColorNameOthers", L["Color_Name_Others"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorColorNameOthers:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(contentFrame.totemIndicatorColorNameOthers, L["Color_Name_Others"], L["Tooltip_Color_Name_Others_Desc"], "|cFFFFD100" .. L["Tooltip_Color_Name_Others_SubText_2"] .. "|r")

    contentFrame.totemIndicatorNoAnimation = CreateCheckbox("totemIndicatorNoAnimation", L["Anim"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorNoAnimation:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorNameOthers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(contentFrame.totemIndicatorNoAnimation, L["No_Animation"], L["Tooltip_No_Animation_Desc"])

    contentFrame.totemIndicatorNoGlow = CreateCheckbox("totemIndicatorNoGlow", L["No_Glow"], contentFrame.anchorSubTotem.extendedSettings)
    contentFrame.totemIndicatorNoGlow:SetPoint("LEFT", contentFrame.totemIndicatorNoAnimation.text, "RIGHT", 0, 0)
    CreateTooltipTwo(contentFrame.totemIndicatorNoGlow, L["No_Glow"], L["Tooltip_No_Glow_Desc"])

    contentFrame.totemIndicatorDefaultCooldownTextSize = CreateSlider(contentFrame.anchorSubTotem.extendedSettings, L["Default_CD_Size"], 0.3, 2, 0.01, "totemIndicatorDefaultCooldownTextSize", nil, 95)
    contentFrame.totemIndicatorDefaultCooldownTextSize:SetPoint("TOPLEFT", contentFrame.totemIndicatorNoAnimation, "BOTTOMLEFT", 12, -22)
    CreateTooltip(contentFrame.totemIndicatorDefaultCooldownTextSize, L["Tooltip_Size_Of_The_Default_Blizz_CD"])

    contentFrame.anchorSubTotem.colorLabel = contentFrame.anchorSubTotem.extendedSettings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentFrame.anchorSubTotem.colorLabel:SetPoint("TOPLEFT", contentFrame.totemIndicatorDefaultCooldownTextSize, "BOTTOMLEFT", -12, -12)
    contentFrame.anchorSubTotem.colorLabel:SetText(L["Totem_Colors"])

    local function RefreshTotemOthersSwatch()
        local color = BetterBlizzPlatesDB.totemIndicatorTotemColor or { 0.4, 0.34, 0.21 }
        contentFrame.totemIndicatorColorOtherHealthBars.Text:SetTextColor(color[1], color[2], color[3])
        if contentFrame.totemIndicatorColorOthers then
            contentFrame.totemIndicatorColorOthers.colorTexture:SetColorTexture(color[1], color[2], color[3], 1)
        end
    end
    BBP.RefreshTotemOthersSwatch = RefreshTotemOthersSwatch

    contentFrame.totemIndicatorColorGrounding = CreateColorBox(contentFrame.anchorSubTotem.extendedSettings, "totemIndicatorColorGrounding", L["Grounding"])
    contentFrame.totemIndicatorColorGrounding:SetPoint("TOPLEFT", contentFrame.anchorSubTotem.colorLabel, "BOTTOMLEFT", 0, -4)
    CreateTooltipTwo(contentFrame.totemIndicatorColorGrounding, L["Grounding_Totem"], L["Tooltip_Grounding_Totem_Desc"])

    contentFrame.totemIndicatorColorCapacitor = CreateColorBox(contentFrame.anchorSubTotem.extendedSettings, "totemIndicatorColorCapacitor", L["Capacitor"])
    contentFrame.totemIndicatorColorCapacitor:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorGrounding, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(contentFrame.totemIndicatorColorCapacitor, L["Capacitor_Totem"], L["Tooltip_Capacitor_Totem_Desc"])

    contentFrame.totemIndicatorColorPsyfiend = CreateColorBox(contentFrame.anchorSubTotem.extendedSettings, "totemIndicatorColorPsyfiend", L["Psyfiend"])
    contentFrame.totemIndicatorColorPsyfiend:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorCapacitor, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(contentFrame.totemIndicatorColorPsyfiend, L["Psyfiend"], L["Tooltip_Psyfiend_Desc"])

    contentFrame.totemIndicatorColorHealingStream = CreateColorBox(contentFrame.anchorSubTotem.extendedSettings, "totemIndicatorColorHealingStream", L["Healing_Stream"])
    contentFrame.totemIndicatorColorHealingStream:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorGrounding, "TOPLEFT", 140, 0)
    CreateTooltipTwo(contentFrame.totemIndicatorColorHealingStream, L["Healing_Stream_Totem"], L["Tooltip_Healing_Stream_Totem_Desc"])

    contentFrame.totemIndicatorColorOthers = CreateColorBox(contentFrame.anchorSubTotem.extendedSettings, "totemIndicatorTotemColor", L["Others"], RefreshTotemOthersSwatch)
    contentFrame.totemIndicatorColorOthers:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorHealingStream, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(contentFrame.totemIndicatorColorOthers, L["Other_Totems"], L["Tooltip_Other_Totems_Desc"])




    ----

    BetterBlizzPlatesSubPanel.reloadButton = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
    BetterBlizzPlatesSubPanel.reloadButton:SetText(L["Reload_UI"])
    BetterBlizzPlatesSubPanel.reloadButton:SetWidth(85)
    BetterBlizzPlatesSubPanel.reloadButton:SetPoint("TOP", BetterBlizzPlatesSubPanel, "BOTTOMRIGHT", -140, -9)
    BetterBlizzPlatesSubPanel.reloadButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    BetterBlizzPlatesSubPanel.resetBBPButton = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
    BetterBlizzPlatesSubPanel.resetBBPButton:SetText(L["Reset_BetterBlizzPlates"])
    BetterBlizzPlatesSubPanel.resetBBPButton:SetWidth(165)
    BetterBlizzPlatesSubPanel.resetBBPButton:SetPoint("RIGHT", BetterBlizzPlatesSubPanel.reloadButton, "LEFT", -528, 0)
    BetterBlizzPlatesSubPanel.resetBBPButton:SetScript("OnClick", function()
        BBP.ShowPopup("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    end)
    CreateTooltipTwo(BetterBlizzPlatesSubPanel.resetBBPButton, L["Reset"], L["Tooltip_Reset_ALL_BetterBlizzPlates_Settings"])

    BetterBlizzPlatesSubPanel.rightClickTip = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    BetterBlizzPlatesSubPanel.rightClickTip:SetPoint("RIGHT", BetterBlizzPlatesSubPanel.reloadButton, "LEFT", -80, -2)
    BetterBlizzPlatesSubPanel.rightClickTip:SetText("|A:smallquestbang:20:20|a" .. L["Tip_Right_Click_Sliders_To_Enter_A_Specific"])
    do
        local ft = { toggles = {}, arenaModes = { "One", "Two", "Three", "Four", "Five" } }
        function ft.CheckboxToggle(option)
            return function() return BetterBlizzPlatesDB[option] end, function()
                local checkbox = checkboxByOption[option]
                if checkbox then
                    checkbox:Click()
                end
            end
        end

        function ft.ArenaNamesEnabled()
            return not BetterBlizzPlatesDB.arenaIndicatorModeOff or not BetterBlizzPlatesDB.partyIndicatorModeOff
        end
        function ft.SetArenaMode(prefix, mode)
            for _, m in ipairs(ft.arenaModes) do
                BetterBlizzPlatesDB[prefix .. m] = (m == mode)
            end
            BetterBlizzPlatesDB[prefix .. "Off"] = (mode == "Off")
        end
        function ft.CurrentArenaMode(prefix)
            for _, m in ipairs(ft.arenaModes) do
                if BetterBlizzPlatesDB[prefix .. m] then return m end
            end
            return "Off"
        end
        function ft.ToggleArenaNames()
            local db = BetterBlizzPlatesDB
            if ft.ArenaNamesEnabled() then
                db.arenaNamesLastModes = { arena = ft.CurrentArenaMode("arenaIndicatorMode"), party = ft.CurrentArenaMode("partyIndicatorMode") }
                ft.SetArenaMode("arenaIndicatorMode", "Off")
                ft.SetArenaMode("partyIndicatorMode", "Off")
            else
                local last = db.arenaNamesLastModes
                if last and (last.arena ~= "Off" or last.party ~= "Off") then
                    ft.SetArenaMode("arenaIndicatorMode", last.arena)
                    ft.SetArenaMode("partyIndicatorMode", last.party)
                else
                    ft.SetArenaMode("arenaIndicatorMode", "One")
                end
            end
            for _, dropdown in ipairs(BBP.arenaModeDropdowns or {}) do
                dropdown:GenerateMenu()
            end
            BBP.needsUpdate = true
            BBP.RefreshAllNameplates()
        end

        function ft.Add(owner, isEnabled, toggle)
            table.insert(ft.toggles, CreateFeatureToggle(owner, isEnabled, toggle))
        end
        ft.Add(anchorSubAbsorb, ft.CheckboxToggle("absorbIndicator"))
        ft.Add(anchorSubArena, ft.ArenaNamesEnabled, ft.ToggleArenaNames)
        ft.Add(anchorSubBlitzIndicator, ft.CheckboxToggle("bgIndicator"))
        ft.Add(anchorSubClassIcon, ft.CheckboxToggle("classIndicator"))
        ft.Add(anchorSubOutOfCombat, ft.CheckboxToggle("combatIndicator"))
        ft.Add(anchorSubExecute, ft.CheckboxToggle("executeIndicator"))
        ft.Add(anchorSubFaction, ft.CheckboxToggle("factionIndicator"))
        ft.Add(anchorSubFocus, ft.CheckboxToggle("focusTargetIndicator"))
        ft.Add(anchorSubHeal, ft.CheckboxToggle("healerIndicator"))
        ft.Add(anchorSubHealthNumbers, ft.CheckboxToggle("healthNumbers"))
        ft.Add(anchorSubFakeName, ft.CheckboxToggle("useFakeName"))
        ft.Add(anchorSubPointerIndicator, ft.CheckboxToggle("partyPointer"))
        ft.Add(anchorSubPet, ft.CheckboxToggle("petIndicator"))
        ft.Add(anchorSubquest, ft.CheckboxToggle("questIndicator"))
        ft.Add(anchorSubRaidmark, ft.CheckboxToggle("raidmarkIndicator"))
        ft.Add(anchorSubTarget, ft.CheckboxToggle("targetIndicator"))
        ft.Add(anchorSubTargetText, ft.CheckboxToggle("showNameplateTargetText"))
        ft.Add(anchorThreatColor, ft.CheckboxToggle("enemyColorThreat"))
        ft.Add(contentFrame.anchorSubTotem, ft.CheckboxToggle("totemIndicator"))

        BetterBlizzPlatesSubPanel:HookScript("OnShow", function()
            for _, toggle in ipairs(ft.toggles) do
                toggle:Refresh()
            end
        end)
    end
end

local function guiCastbar()
    --------------------------------
    -- Castbar Customization
    --------------------------------
    local guiCastbar = CreateFrame("Frame")
    guiCastbar.name = L["Castbar"]
    guiCastbar.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiCastbar)
    local guiCastbarCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiCastbar, guiCastbar.name)
    CreateTitle(guiCastbar)

    local bgImg = guiCastbar:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiCastbar, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    -- local listFrame = CreateFrame("Frame", nil, guiCastbar)
    -- listFrame:SetAllPoints(guiCastbar)
    -- local scrollFrame = CreateList(listFrame, "castEmphasisList", BetterBlizzPlatesDB.castEmphasisList, BBP.RefreshAllNameplates, true, nil, nil, 360)
    -- scrollFrame:SetPoint("TOPLEFT", -17, -10)

    -- local castEmphasisText = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- castEmphasisText:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 25, 3)
    -- castEmphasisText:SetText("Cast Emphasis List")

    -- local onMeOnlyTexture = listFrame:CreateTexture(nil, "OVERLAY")
    -- onMeOnlyTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    -- onMeOnlyTexture:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", -99, -1)
    -- onMeOnlyTexture:SetSize(18,20)
    -- CreateTooltipTwo(onMeOnlyTexture, "Only On Me Checkboxes", "Check to only emphasis casts if theyre on me.", "This is only for NPCs, due to API limitations.")

    -- local how2usecastemphasis = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- how2usecastemphasis:SetPoint("TOP", guiCastbar, "BOTTOMLEFT", 180, 165)
    -- how2usecastemphasis:SetText("Add name or spell ID. Case-insensitive.\nType a name or spell ID already in list to delete it")

    local castbarSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarSettingsText:SetPoint("LEFT", guiCastbar, "TOPLEFT", 5, -5)
    castbarSettingsText:SetText(L["Castbar_Settings"])
    castbarSettingsText:SetFont(fontLarge, 16)
    castbarSettingsText:SetTextColor(1,1,1)
    local castbarSettingsIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsIcon:SetSize(24, 24)
    castbarSettingsIcon:SetPoint("RIGHT", castbarSettingsText, "LEFT", -3, 0)

    local nameplateCastbarTestMode = CreateCheckbox("nameplateCastbarTestMode", L["Test_Castbars"], guiCastbar)
    nameplateCastbarTestMode:SetPoint("LEFT", castbarSettingsText, "RIGHT", 0, 0)
    nameplateCastbarTestMode:SetScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.nameplateCastBarTestMode()
        else
            BBP.cancelTimers()
        end
    end)
    CreateTooltipTwo(nameplateCastbarTestMode, L["Test_Nameplate_Castbars"], L["Tooltip_Test_Nameplate_Castbars_Desc"])

    local classicCastbar = CreateCheckbox("classicCastbar", L["Classic_Castbar"], guiCastbar)
    classicCastbar:SetPoint("TOPLEFT", castbarSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)
    CreateTooltipTwo(classicCastbar, L["Classic_Castbar"], L["Tooltip_Classic_Castbar_Desc"])
    classicCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.castBarHeight = 11.5
        end
        BBP.ShowPopup(self:GetChecked() and "BBP_CLASSIC_CASTBAR_SETUP" or "BBP_CONFIRM_RELOAD")
    end)

    local classicCastbarOptions = CreateMultiSelectDropdown(L["Classic_Options"], guiCastbar, {
        { key = "classicCastbarNoIconBorder", label = L["Hide_Icon_Background"], tooltip = L["Tooltip_Remove_The_Background_Behind_The_Cast"], isEnabled = function() return BetterBlizzPlatesDB.classicCastbar end, isForced = BBP.IsCastIconHidden, tooltipNote = function() return BBP.IsCastIconHidden() and L["Tooltip_Always_On_While_Cast_Icon_Hidden"] or nil end },
        { key = "classicCastbarTextures", label = L["Classic_Textures"], tooltip = L["Tooltip_Classic_Textures_Desc"], tooltipNote = function() return BetterBlizzPlatesDB.enableCastbarCustomization and L["Tooltip_Off_With_Castbar_Customization"] or nil end, isEnabled = function() return BetterBlizzPlatesDB.classicCastbar and not BetterBlizzPlatesDB.enableCastbarCustomization end },
        { key = "classicCastbarFullWidth", label = L["Full_Width_Bar"], tooltip = L["Tooltip_Have_The_Classic_Castbar_Width_Be"], isEnabled = function() return BetterBlizzPlatesDB.classicCastbar and BetterBlizzPlatesDB.classicCastbarNoIconBorder end, isForced = BBP.IsCastIconHidden, tooltipNote = function() return BBP.IsCastIconHidden() and L["Tooltip_Always_On_While_Cast_Icon_Hidden"] or nil end },
    }, 150, function()
        if guiCastbar.UpdateCastIconControls then
            guiCastbar.UpdateCastIconControls()
        end
    end)
    classicCastbarOptions:SetPoint("LEFT", classicCastbar.text, "RIGHT", 4, 0)
    classicCastbarOptions:SetScale(0.7)
    CreateTooltipTwo(classicCastbarOptions, L["Classic_Options"], L["Tooltip_Classic_Options_Desc"])
    classicCastbarOptions.searchParentKey = "classicCastbar"
    function classicCastbarOptions:UpdateEnabled()
        local enabled = BetterBlizzPlatesDB.classicCastbar and true or false
        self:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.5)
    end
    classicCastbarOptions:HookScript("OnShow", classicCastbarOptions.UpdateEnabled)
    classicCastbarOptions:UpdateEnabled()
    classicCastbar:HookScript("OnClick", function()
        classicCastbarOptions:UpdateEnabled()
    end)

    local enableCastbarCustomization = CreateCheckbox("enableCastbarCustomization", L["Enable_Castbar_Customization"], guiCastbar, nil, BBP.ToggleSpellCastEventRegistration)
    enableCastbarCustomization:SetPoint("TOPLEFT", classicCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castbarAlwaysOnTop = CreateCheckbox("castbarAlwaysOnTop", L["Always_On_Top"], enableCastbarCustomization)
    castbarAlwaysOnTop:SetPoint("LEFT", enableCastbarCustomization.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castbarAlwaysOnTop, L["Always_On_Top"], L["Tooltip_Always_On_Top_Desc"], L["Tooltip_Always_On_Top_SubText"])

    local castbarQuickHide = CreateCheckbox("castbarQuickHide", L["Castbar_Quick_Hide"], enableCastbarCustomization)
    CreateTooltipTwo(castbarQuickHide, L["Castbar_Quick_Hide"], L["Tooltip_Castbar_Quick_Hide_Desc"])
    castbarQuickHide:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzPlatesDB.castbarQuickHideAlways then
                BetterBlizzPlatesDB.castbarQuickHideAlways = true
            else
                BetterBlizzPlatesDB.castbarQuickHideAlways = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local hideCastbarBorderShield = CreateCheckbox("hideCastbarBorderShield", L["Hide_Shield"], enableCastbarCustomization)
    hideCastbarBorderShield:SetPoint("LEFT", castbarQuickHide.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideCastbarBorderShield, L["Hide_Castbar_Shield"], L["Tooltip_Hide_Castbar_Shield_Desc"])

    local hideCastbarIcon = CreateCheckbox("hideCastbarIcon", L["Hide_Icon"], enableCastbarCustomization)
    hideCastbarIcon:SetPoint("LEFT", hideCastbarBorderShield.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideCastbarIcon, L["Hide_Castbar_Icon"], L["Tooltip_Hide_Castbar_Icon_Desc"])
    hideCastbarIcon:HookScript("OnClick", function()
        if guiCastbar.UpdateCastIconControls then
            guiCastbar.UpdateCastIconControls()
        end
    end)

    local showCastBarIconWhenNoninterruptible = CreateCheckbox("showCastBarIconWhenNoninterruptible", L["Show_Cast_Icon_On_Non_Interruptable"], enableCastbarCustomization)
    showCastBarIconWhenNoninterruptible:SetPoint("TOPLEFT", castbarQuickHide, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCastBarIconWhenNoninterruptible, L["Tooltip_Show_The_Cast_Icon_On_Non"])

    local hideNameDuringCast = CreateCheckbox("hideNameDuringCast", L["Hide_Name"], enableCastbarCustomization)
    hideNameDuringCast:SetPoint("LEFT", showCastBarIconWhenNoninterruptible.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideNameDuringCast, L["Hide_Unit_Name"], L["Tooltip_Hide_Unit_Name_Desc"])

    local castBarDragonflightShield = CreateCheckbox("castBarDragonflightShield", L["New_Shield_On_Non_Interruptable"], enableCastbarCustomization)
    castBarDragonflightShield:SetPoint("TOPLEFT", showCastBarIconWhenNoninterruptible, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarDragonflightShield, L["Tooltip_Replace_The_Old_Pixelated_Non_Interruptible"])

    local castBarFullTextWidth = CreateCheckbox("castBarFullTextWidth", L["Full_Text_Width"], enableCastbarCustomization, nil, BBP.UpdateAllCastbarTextPositions)
    castBarFullTextWidth:SetPoint("LEFT", castBarDragonflightShield.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarFullTextWidth, L["Full_Text_Width"], L["Tooltip_Full_Text_Width_Desc"])

    local castBarTextOptionsFrame
    local function OpenCastBarTextOptionsWindow()
        if not castBarTextOptionsFrame then
            castBarTextOptionsFrame = CreateFrame("Frame", "BBPCastBarTextOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            castBarTextOptionsFrame:SetSize(460, 320)
            castBarTextOptionsFrame:SetPoint("CENTER")
            castBarTextOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            castBarTextOptionsFrame:SetFrameLevel(550)
            castBarTextOptionsFrame:SetIgnoreParentAlpha(true)
            castBarTextOptionsFrame:SetTitle(L["Castbar_Text_Options"])
            castBarTextOptionsFrame:EnableMouse(true)
            castBarTextOptionsFrame:SetMovable(true)
            castBarTextOptionsFrame:SetClampedToScreen(true)
            castBarTextOptionsFrame:RegisterForDrag("LeftButton")
            castBarTextOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            castBarTextOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            castBarTextOptionsFrame.closeButton = CreateFrame("Button", nil, castBarTextOptionsFrame, "UIPanelCloseButton")
            castBarTextOptionsFrame.closeButton:SetFrameLevel((castBarTextOptionsFrame.TitleContainer or castBarTextOptionsFrame):GetFrameLevel() + 10)
            castBarTextOptionsFrame.closeButton:SetPoint("TOPRIGHT", castBarTextOptionsFrame, "TOPRIGHT", 0, 0)
            castBarTextOptionsFrame.closeButton:SetScript("OnClick", function()
                castBarTextOptionsFrame:Hide()
            end)

            castBarTextOptionsFrame.bg = castBarTextOptionsFrame:CreateTexture(nil, "BACKGROUND")
            castBarTextOptionsFrame.bg:SetPoint("TOPLEFT", castBarTextOptionsFrame, "TOPLEFT", 7, -3)
            castBarTextOptionsFrame.bg:SetPoint("BOTTOMRIGHT", castBarTextOptionsFrame, "BOTTOMRIGHT", -3, 3)
            castBarTextOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local columnWidth = 230
            local function CreateColumnHeader(text, column)
                local header = castBarTextOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                header:SetPoint("TOP", castBarTextOptionsFrame, "TOPLEFT", column * columnWidth + columnWidth / 2 + 2, -32)
                header:SetText(text)
                local line = castBarTextOptionsFrame:CreateTexture(nil, "ARTWORK")
                line:SetColorTexture(1, 1, 1, 0.12)
                line:SetSize(columnWidth - 40, 1)
                line:SetPoint("TOP", header, "BOTTOM", 0, -4)
                return header
            end
            CreateColumnHeader(L["Spell_Name"], 0)
            CreateColumnHeader(L["Cast_Timer"], 1)

            local divider = castBarTextOptionsFrame:CreateTexture(nil, "ARTWORK")
            divider:SetColorTexture(1, 1, 1, 0.12)
            divider:SetWidth(1)
            divider:SetPoint("TOP", castBarTextOptionsFrame, "TOPLEFT", columnWidth + 2, -32)
            divider:SetPoint("BOTTOM", castBarTextOptionsFrame, "BOTTOMLEFT", columnWidth + 2, 6)

            local function CreateRowDropdown(name, default, key, func, column, row, label, anchorTypes)
                local dropdown = CreateAnchorDropdown(name, castBarTextOptionsFrame, default, key, func,
                    { anchorFrame = castBarTextOptionsFrame, x = column * columnWidth + 88, y = -58 - row * 30, label = label },
                    70, nil, anchorTypes)
                dropdown.label:ClearAllPoints()
                dropdown.label:SetPoint("LEFT", dropdown.Background, "LEFT", -63, 0)
                dropdown.label:SetWidth(57)
                dropdown.label:SetJustifyH("LEFT")
                return dropdown
            end

            local function CreateColumnReset(column, onClick)
                local button = CreateFrame("Button", nil, castBarTextOptionsFrame, "UIPanelButtonTemplate")
                button:SetText(L["Reset"])
                button:SetSize(80, 22)
                button:SetPoint("BOTTOM", castBarTextOptionsFrame, "BOTTOMLEFT", column * columnWidth + columnWidth / 2 + 2, 12)
                button:SetScript("OnClick", onClick)
                CreateTooltipTwo(button, L["Reset"], L["Tooltip_Reset_Desc"])
                return button
            end

            local castBarTextAnchorDropdown = CreateRowDropdown("castBarTextAnchorDropdown", "CENTER", "castBarTextAnchor", BBP.UpdateAllCastbarTextPositions, 0, 0, L["Anchor"])
            CreateTooltipTwo(castBarTextAnchorDropdown, L["Castbar_Text_Anchor"], L["Tooltip_Castbar_Text_Anchor_Desc"])

            local castBarTextRelativeAnchorDropdown = CreateRowDropdown("castBarTextRelativeAnchorDropdown", "CENTER", "castBarTextRelativeAnchor", BBP.UpdateAllCastbarTextPositions, 0, 1, L["Castbar"])
            CreateTooltipTwo(castBarTextRelativeAnchorDropdown, L["Castbar_Anchor"], L["Tooltip_Castbar_Anchor_Desc"])

            local castBarTextJustifyDropdown = CreateRowDropdown("castBarTextJustifyDropdown", "CENTER", "castBarTextJustify", BBP.UpdateAllCastbarTextPositions, 0, 2, L["Justify"], { "LEFT", "CENTER", "RIGHT" })
            CreateTooltipTwo(castBarTextJustifyDropdown, L["Castbar_Text_Position"], L["Tooltip_Castbar_Text_Position_Desc"])

            local castBarTextScale = CreateSlider(castBarTextOptionsFrame, L["Size"], 0.5, 2.5, 0.01, "castBarTextScale", nil, 150)
            castBarTextScale:SetPoint("TOPLEFT", castBarTextOptionsFrame, "TOPLEFT", 42, -172)

            local castBarTextXPos = CreateSlider(castBarTextOptionsFrame, L["X_Offset"], -50, 50, 0.5, "castBarTextXPos", nil, 150)
            castBarTextXPos:SetPoint("TOPLEFT", castBarTextScale, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(castBarTextXPos, L["X_Offset"], L["Tooltip_Castbar_Text_X_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

            local castBarTextYPos = CreateSlider(castBarTextOptionsFrame, L["Y_Offset"], -50, 50, 0.5, "castBarTextYPos", nil, 150)
            castBarTextYPos:SetPoint("TOPLEFT", castBarTextXPos, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(castBarTextYPos, L["Y_Offset"], L["Tooltip_Castbar_Text_Y_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

            CreateColumnReset(0, function()
                BetterBlizzPlatesDB.castBarTextAnchor = "CENTER"
                BetterBlizzPlatesDB.castBarTextRelativeAnchor = "CENTER"
                BetterBlizzPlatesDB.castBarTextJustify = "CENTER"
                castBarTextAnchorDropdown:GenerateMenu()
                castBarTextRelativeAnchorDropdown:GenerateMenu()
                castBarTextJustifyDropdown:GenerateMenu()
                castBarTextScale:SetValue(1)
                castBarTextXPos:SetValue(0)
                castBarTextYPos:SetValue(0)
                BBP.UpdateAllCastbarTextPositions()
            end)

            local castTimerAnchorDropdown = CreateRowDropdown("castTimerAnchorDropdown", "LEFT", "castTimerAnchor", BBP.UpdateAllCastTimers, 1, 0, L["Anchor"])
            CreateTooltipTwo(castTimerAnchorDropdown, L["Cast_Timer_Anchor"], L["Tooltip_Cast_Timer_Anchor_Desc"])

            local castTimerRelativeAnchorDropdown = CreateRowDropdown("castTimerRelativeAnchorDropdown", "RIGHT", "castTimerRelativeAnchor", BBP.UpdateAllCastTimers, 1, 1, L["Castbar"])
            CreateTooltipTwo(castTimerRelativeAnchorDropdown, L["Castbar_Anchor"], L["Tooltip_Castbar_Anchor_Desc"])

            if not BetterBlizzPlatesDB.npCastTimerSize then
                BetterBlizzPlatesDB.npCastTimerSize = BetterBlizzPlatesDB.npTargetTextSize or 12
            end
            local castTimerSize = CreateSlider(castBarTextOptionsFrame, L["Size"], 6, 24, 1, "npCastTimerSize", nil, 150)
            castTimerSize:SetPoint("TOPLEFT", castBarTextOptionsFrame, "TOPLEFT", columnWidth + 42, -172)

            local castTimerXPos = CreateSlider(castBarTextOptionsFrame, L["X_Offset"], -50, 50, 0.5, "castTimerXPos", nil, 150)
            castTimerXPos:SetPoint("TOPLEFT", castTimerSize, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(castTimerXPos, L["X_Offset"], L["Tooltip_Cast_Timer_X_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

            local castTimerYPos = CreateSlider(castBarTextOptionsFrame, L["Y_Offset"], -50, 50, 0.5, "castTimerYPos", nil, 150)
            castTimerYPos:SetPoint("TOPLEFT", castTimerXPos, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(castTimerYPos, L["Y_Offset"], L["Tooltip_Cast_Timer_Y_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

            CreateColumnReset(1, function()
                BetterBlizzPlatesDB.castTimerAnchor = "LEFT"
                BetterBlizzPlatesDB.castTimerRelativeAnchor = "RIGHT"
                castTimerAnchorDropdown:GenerateMenu()
                castTimerRelativeAnchorDropdown:GenerateMenu()
                castTimerSize:SetValue(12)
                castTimerXPos:SetValue(5)
                castTimerYPos:SetValue(0)
                BBP.UpdateAllCastTimers()
            end)

            castBarTextOptionsFrame:Show()
        else
            castBarTextOptionsFrame:SetShown(not castBarTextOptionsFrame:IsShown())
        end
    end

    local moveCastBarText = CreateCheckbox("moveCastBarText", L["Move_Castbar_Text"], enableCastbarCustomization, nil, BBP.UpdateAllCastbarTextPositions)
    moveCastBarText:SetPoint("TOPLEFT", enableCastbarCustomization, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    castbarQuickHide:SetPoint("TOPLEFT", moveCastBarText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveCastBarText, L["Move_Castbar_Text"], L["Tooltip_Move_Castbar_Text_Desc"] .. "\n\n" .. L["Right_Click_For_Options"])
    moveCastBarText:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            OpenCastBarTextOptionsWindow()
        end
    end)

    local castBarIconScale = CreateSlider(enableCastbarCustomization, L["Castbar_Icon_Size"], 0.1, 2.5, 0.01, "castBarIconScale")
    castBarIconScale:SetPoint("TOPLEFT", castBarDragonflightShield, "BOTTOMLEFT", 12, -10)

    local castBarIconXPos = CreateSlider(enableCastbarCustomization, L["Icon_X_Offset"], -50, 50, 1, "castBarIconXPos", "X", 100)
    castBarIconXPos:SetPoint("LEFT", castBarIconScale, "RIGHT", 82, 0)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, L["Icon_Y_Offset"], -50, 50, 1, "castBarIconYPos", "Y", 100)
    castBarIconYPos:SetPoint("TOP", castBarIconXPos, "BOTTOM", 0, -15)

    local anchorCastIconOnRight = CreateCheckbox("anchorCastIconOnRight", L["Anchor_Icon_Right"], enableCastbarCustomization)
    anchorCastIconOnRight:SetPoint("LEFT", castBarIconYPos, "RIGHT", 5, 16)
    CreateTooltipTwo(anchorCastIconOnRight, L["Anchor_Cast_Icon_On_Right"], L["Tooltip_Anchor_Cast_Icon_On_Right_Desc"], L["Tooltip_Not_Used_While_Cast_Icon_Hidden"])
    CreateTooltipTwo(castBarIconScale, L["Castbar_Icon_Size"], L["Tooltip_Cast_Icon_Locked_Note"])
    CreateTooltipTwo(castBarIconXPos, L["Icon_X_Offset"], L["Tooltip_Cast_Icon_Locked_Note"])
    CreateTooltipTwo(castBarIconYPos, L["Icon_Y_Offset"], L["Tooltip_Cast_Icon_Locked_Note"])

    function guiCastbar.UpdateCastIconControls()
        local custom = BetterBlizzPlatesDB.enableCastbarCustomization
        local locked = not custom or BBP.CastIconSizeLocked() or BBP.IsCastIconHidden()
        for _, slider in ipairs({ castBarIconScale, castBarIconXPos, castBarIconYPos }) do
            if locked then
                DisableElement(slider)
            else
                EnableElement(slider)
            end
        end
        if custom and not BBP.IsCastIconHidden() then
            EnableElement(anchorCastIconOnRight)
        else
            DisableElement(anchorCastIconOnRight)
        end
    end
    for _, widget in ipairs({ castBarIconScale, castBarIconXPos, castBarIconYPos, anchorCastIconOnRight }) do
        if widget.SetMotionScriptsWhileDisabled then
            widget:SetMotionScriptsWhileDisabled(true)
        end
    end
    enableCastbarCustomization:HookScript("OnClick", guiCastbar.UpdateCastIconControls)
    castBarIconScale:HookScript("OnShow", guiCastbar.UpdateCastIconControls)
    guiCastbar.UpdateCastIconControls()

--[=[
    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconXPos", "X")
    castBarIconXPos:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y")
    castBarIconYPos:SetPoint("TOPLEFT", castBarIconXPos, "BOTTOMLEFT", 0, -15)

]=]

    local castBarHeight = CreateSlider(enableCastbarCustomization, L["Castbar_Height"], 4, 36, 0.1, "castBarHeight", "Height")
    castBarHeight:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castbarHeightResetButton = CreateFrame("Button", nil, enableCastbarCustomization, "UIPanelButtonTemplate")
    castbarHeightResetButton:SetText(L["Default"])
    castbarHeightResetButton:SetWidth(60)
    castbarHeightResetButton:SetPoint("LEFT", castBarHeight, "RIGHT", 10, 0)
    castbarHeightResetButton:SetScale(0.8)
    CreateTooltipTwo(castbarHeightResetButton, L["Reset_Castbar_Height"])
    castbarHeightResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight(castBarHeight)
    end)

    local castBarRecolor = CreateCheckbox("castBarRecolor", L["Re_Color_Castbar"], enableCastbarCustomization)
    castBarRecolor:SetPoint("TOPLEFT", castBarHeight, "BOTTOMLEFT", -12, -3)

    local function UpdateColorSquare(icon, r, g, b, a)
        if r and g and b and a then
            icon:SetVertexColor(r, g, b, a)
        else
            icon:SetVertexColor(r, g, b)
        end
    end

    local function OpenColorPicker(colorType, icon)
        BBP.needsUpdate = true
        -- Ensure originalColorData has four elements, defaulting alpha (a) to 1 if not present
        local originalColorData = BetterBlizzPlatesDB[colorType] or {1, 1, 1, 1}
        if #originalColorData == 3 then
            table.insert(originalColorData, 1) -- Add default alpha value if not present
        end
        local r, g, b, a = unpack(originalColorData)

        local function updateColors()
            UpdateColorSquare(icon, r, g, b, a)
            BBP.RefreshAllNameplates()
            ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
        end

        local function swatchFunc()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        local function opacityFunc()
            a = ColorPickerFrame:GetColorAlpha()
            BetterBlizzPlatesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        local function cancelFunc()
            r, g, b, a = unpack(originalColorData)
            BetterBlizzPlatesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
        })
    end


    local castBarCastColor = CreateFrame("Button", nil, castBarRecolor, "UIPanelButtonTemplate")
    castBarCastColor:SetText(L["Cast"])
    castBarCastColor:SetPoint("TOPLEFT", castBarRecolor, "BOTTOMRIGHT", 0, 3)
    castBarCastColor:SetSize(45, 20)
    local castBarCastColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarCastColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarCastColorIcon:SetSize(18, 17)
    castBarCastColorIcon:SetPoint("LEFT", castBarCastColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarCastColorIcon, unpack(BetterBlizzPlatesDB["castBarCastColor"] or {1, 1, 1}))
    castBarCastColor:SetScript("OnClick", function()
        OpenColorPicker("castBarCastColor", castBarCastColorIcon)
    end)

    local castBarChanneledColor = CreateFrame("Button", nil, castBarRecolor, "UIPanelButtonTemplate")
    castBarChanneledColor:SetText(L["Channel"])
    castBarChanneledColor:SetPoint("LEFT", castBarCastColor, "RIGHT", 24, 0)
    castBarChanneledColor:SetSize(70, 20)
    local castBarChanneledColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarChanneledColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarChanneledColorIcon:SetSize(18, 17)
    castBarChanneledColorIcon:SetPoint("LEFT", castBarChanneledColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarChanneledColorIcon, unpack(BetterBlizzPlatesDB["castBarChanneledColor"] or {1, 1, 1}))
    castBarChanneledColor:SetScript("OnClick", function()
        OpenColorPicker("castBarChanneledColor", castBarChanneledColorIcon)
    end)

    local castBarNoninterruptibleColor = CreateFrame("Button", nil, castBarRecolor, "UIPanelButtonTemplate")
    castBarNoninterruptibleColor:SetText(L["Non_Int"])
    castBarNoninterruptibleColor:SetPoint("LEFT", castBarChanneledColor, "RIGHT", 24, 0)
    castBarNoninterruptibleColor:SetSize(70, 20)
    local castBarNoninterruptibleColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarNoninterruptibleColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarNoninterruptibleColorIcon:SetSize(18, 17)
    castBarNoninterruptibleColorIcon:SetPoint("LEFT", castBarNoninterruptibleColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarNoninterruptibleColorIcon, unpack(BetterBlizzPlatesDB["castBarNoninterruptibleColor"] or {1, 1, 1}))
    castBarNoninterruptibleColor:SetScript("OnClick", function()
        OpenColorPicker("castBarNoninterruptibleColor", castBarNoninterruptibleColorIcon)
    end)
    CreateTooltip(castBarNoninterruptibleColor, L["Tooltip_Color_For_Non_Interruptible_Casts"])

    local useCustomCastbarTexture = CreateCheckbox("useCustomCastbarTexture", L["Re_Texture_Castbar"], enableCastbarCustomization, nil, BBP.ToggleSpellCastEventRegistration)
    useCustomCastbarTexture:SetPoint("TOPLEFT", castBarRecolor, "BOTTOMLEFT", 0, -16)

    local castBarPixelBorder = CreateCheckbox("castBarPixelBorder", L["Pixel_Border"], enableCastbarCustomization)
    castBarPixelBorder:SetPoint("LEFT", useCustomCastbarTexture.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarPixelBorder, L["Castbar_Pixel_Border"], L["Tooltip_Castbar_Pixel_Border_Desc"])

    local castBarIconPixelBorder = CreateCheckbox("castBarIconPixelBorder", L["Icon_Pixel"], enableCastbarCustomization)
    castBarIconPixelBorder:SetPoint("LEFT", castBarPixelBorder.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarIconPixelBorder, L["Icon_Pixel_Border"], L["Tooltip_Icon_Pixel_Border_Desc"])

    local customCastbarTextureDropdown = CreateTextureDropdown(
        "customCastbarTextureDropdown",
        useCustomCastbarTexture,
        L["Select_Texture"],
        "customCastbarTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomCastbarTexture, x = 5, y = 0, label = "CustomCastbar" }
    )
    CreateTooltip(customCastbarTextureDropdown, L["Tooltip_Castbar_Texture"])

    local interruptibleLabel = useCustomCastbarTexture:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    interruptibleLabel:SetPoint("LEFT", customCastbarTextureDropdown, "RIGHT", 6, 0)
    interruptibleLabel:SetText(L["Interruptible"])

    local customCastbarNonInterruptibleTextureDropdown = CreateTextureDropdown(
        "customCastbarNonInterruptibleTextureDropdown",
        useCustomCastbarTexture,
        L["Select_Texture"],
        "customCastbarNonInterruptibleTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomCastbarTexture, x = 5, y = -31, label = "CustomBGCastbar" }
    )
    CreateTooltip(customCastbarNonInterruptibleTextureDropdown, L["Tooltip_Non_Interruptible_Texture"])

    local nonInterruptibleLabel = useCustomCastbarTexture:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nonInterruptibleLabel:SetPoint("LEFT", customCastbarNonInterruptibleTextureDropdown, "RIGHT", 6, 0)
    nonInterruptibleLabel:SetText(L["Non_Interruptible"])

    local customCastbarBGTextureDropdown = CreateTextureDropdown(
        "customCastbarBGTextureDropdown",
        useCustomCastbarTexture,
        L["Select_Texture"],
        "customCastbarBGTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomCastbarTexture, x = 5, y = -62, label = "CustomBGCastbar" }
    )
    CreateTooltip(customCastbarBGTextureDropdown, L["Tooltip_Background_Texture"])

    if not useCustomCastbarTexture:GetChecked() then
        customCastbarTextureDropdown:Disable()
        customCastbarTextureDropdown:SetAlpha(0.5)
        customCastbarNonInterruptibleTextureDropdown:Disable()
        customCastbarNonInterruptibleTextureDropdown:SetAlpha(0.5)
        customCastbarBGTextureDropdown:Disable()
        customCastbarBGTextureDropdown:SetAlpha(0.5)
    end

    local useCustomCastbarBGTexture = CreateCheckbox("useCustomCastbarBGTexture", "BG", useCustomCastbarTexture)
    useCustomCastbarBGTexture:SetPoint("LEFT", customCastbarBGTextureDropdown, "RIGHT", 2, -2)
    CreateTooltipTwo(useCustomCastbarBGTexture, L["Change_Background_Texture"])
    useCustomCastbarBGTexture:SetFrameStrata("HIGH")

    local castBarBackgroundColor = CreateFrame("Button", nil, useCustomCastbarBGTexture, "UIPanelButtonTemplate")
    castBarBackgroundColor:SetText(L["Color"])
    castBarBackgroundColor:SetPoint("LEFT", useCustomCastbarBGTexture, "RIGHT", 16, 0)
    castBarBackgroundColor:SetSize(45, 20)
    local castBarBackgroundColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarBackgroundColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarBackgroundColorIcon:SetSize(18, 17)
    castBarBackgroundColorIcon:SetPoint("LEFT", castBarBackgroundColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarBackgroundColorIcon, unpack(BetterBlizzPlatesDB["castBarBackgroundColor"] or {1, 1, 1, 1}))
    castBarBackgroundColor:SetScript("OnClick", function()
        OpenColorPicker("castBarBackgroundColor", castBarBackgroundColorIcon)
    end)
    CreateTooltipTwo(castBarBackgroundColor, L["Castbar_Background_Color"], L["Tooltip_Castbar_Background_Color_Desc"])
    castBarBackgroundColor:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzPlatesDB.redBgCastColor == nil then
                BetterBlizzPlatesDB.redBgCastColor = true
            else
                BetterBlizzPlatesDB.redBgCastColor = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    useCustomCastbarTexture:HookScript("OnClick", function(self)
        --CheckAndToggleCheckboxes(useCustomCastbarTexture)
        if self:GetChecked() then
            customCastbarTextureDropdown:Enable()
            customCastbarTextureDropdown:SetAlpha(1)
            customCastbarNonInterruptibleTextureDropdown:Enable()
            customCastbarNonInterruptibleTextureDropdown:SetAlpha(1)
            useCustomCastbarBGTexture:Enable()
            useCustomCastbarBGTexture:SetAlpha(1)
            if BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                castBarBackgroundColor:Enable()
                castBarBackgroundColor:SetAlpha(1)
                castBarBackgroundColorIcon:SetAlpha(1)
                customCastbarBGTextureDropdown:Enable()
                customCastbarBGTextureDropdown:SetAlpha(1)
            end
        else
            customCastbarTextureDropdown:Disable()
            customCastbarTextureDropdown:SetAlpha(0.5)
            customCastbarNonInterruptibleTextureDropdown:Disable()
            customCastbarNonInterruptibleTextureDropdown:SetAlpha(0.5)
            customCastbarBGTextureDropdown:Disable()
            customCastbarBGTextureDropdown:SetAlpha(0.5)
            useCustomCastbarBGTexture:Disable()
            useCustomCastbarBGTexture:SetAlpha(0.5)
            if not BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                castBarBackgroundColor:Disable()
                castBarBackgroundColor:SetAlpha(0)
                castBarBackgroundColorIcon:SetAlpha(0)
            end
        end
    end)

    local interruptedByIndicator = CreateCheckbox("interruptedByIndicator", L["Show_Who_Interrupted"], enableCastbarCustomization, nil, BBP.ToggleSpellCastEventRegistration)
    interruptedByIndicator:SetPoint("TOPLEFT", useCustomCastbarTexture, "BOTTOMLEFT", 0, -84)
    CreateTooltip(interruptedByIndicator, L["Tooltip_Show_The_Name_Of_Who_Interrupted"])

    local hideCastbarText = CreateCheckbox("hideCastbarText", L["Hide_Castbar_Text"], enableCastbarCustomization)
    hideCastbarText:SetPoint("TOPLEFT", interruptedByIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarText, L["Hide_Castbar_Text"], L["Tooltip_Hide_Castbar_Text_Desc"], nil, "ANCHOR_LEFT")
    hideCastbarText:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzPlatesDB.hideCastbarTextInt then
                BetterBlizzPlatesDB.hideCastbarTextInt = true
            else
                BetterBlizzPlatesDB.hideCastbarTextInt = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local castBarRecolorInterrupt = CreateCheckbox("castBarRecolorInterrupt", L["Interrupt_CD_Color"], enableCastbarCustomization)
    castBarRecolorInterrupt:SetPoint("TOPLEFT", hideCastbarText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarRecolorInterrupt, L["Tooltip_Checks_If_You_Have_Interrupt_Ready"])

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText(L["Kick_On_Cd"])
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", -15, 3)
    castBarNoInterruptColor:SetSize(95, 20)
    CreateTooltip(castBarNoInterruptColor, L["Tooltip_Interrupt_On_CD"])
    local castBarNoInterruptColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarNoInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarNoInterruptColorIcon:SetSize(18, 17)
    castBarNoInterruptColorIcon:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarNoInterruptColorIcon, unpack(BetterBlizzPlatesDB["castBarNoInterruptColor"] or {1, 1, 1}))
    castBarNoInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarNoInterruptColor", castBarNoInterruptColorIcon)
    end)

    local castBarDelayedInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarDelayedInterruptColor:SetText(L["Kick_Soon"])
    castBarDelayedInterruptColor:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 30, 0)
    castBarDelayedInterruptColor:SetSize(95, 20)
    CreateTooltip(castBarDelayedInterruptColor, L["Tooltip_Interrupt_CD_Soon"])
    local castBarDelayedInterruptColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarDelayedInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarDelayedInterruptColorIcon:SetSize(18, 17)
    castBarDelayedInterruptColorIcon:SetPoint("LEFT", castBarDelayedInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarDelayedInterruptColorIcon, unpack(BetterBlizzPlatesDB["castBarDelayedInterruptColor"] or {1, 1, 1}))
    castBarDelayedInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarDelayedInterruptColor", castBarDelayedInterruptColorIcon)
    end)

    -- local castbarEmphasisSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- castbarEmphasisSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -280, -430)
    -- castbarEmphasisSettingsText:SetText("Castbar emphasis settings")
    -- local castbarSettingsEmphasisIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    -- castbarSettingsEmphasisIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    -- castbarSettingsEmphasisIcon:SetSize(36, 36)
    -- castbarSettingsEmphasisIcon:SetVertexColor(1,0,0)
    -- castbarSettingsEmphasisIcon:SetPoint("RIGHT", castbarEmphasisSettingsText, "LEFT", 5, 0)

    -- local enableCastbarEmphasis = CreateCheckbox("enableCastbarEmphasis", "Cast Emphasis", enableCastbarCustomization)
    -- enableCastbarEmphasis:SetPoint("TOPLEFT", castbarEmphasisSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)
    -- enableCastbarEmphasis:HookScript("OnClick", function (self)
    --     CheckAndToggleCheckboxes(enableCastbarEmphasis)
    --     if self:GetChecked() then
    --         listFrame:SetAlpha(1)
    --     else
    --         listFrame:SetAlpha(0.5)
    --     end
    -- end)
    -- CreateTooltipTwo(enableCastbarEmphasis, "Castbar Emphasis", "Enable to adjust how the castbar looks for specific spells from the list. Will also ensure the castbar is not being covered by other nameplates during cast.")

    -- local castBarEmphasisOnlyInterruptable = CreateCheckbox("castBarEmphasisOnlyInterruptable", "Interruptable cast only", enableCastbarEmphasis)
    -- castBarEmphasisOnlyInterruptable:SetPoint("LEFT", enableCastbarEmphasis.text, "RIGHT", 0, 0)
    -- CreateTooltip(castBarEmphasisOnlyInterruptable, "Only apply emphasis settings if the cast is interruptable")

    -- local castBarEmphasisHealthbarColor = CreateCheckbox("castBarEmphasisHealthbarColor", "Color healthbar", enableCastbarEmphasis)
    -- castBarEmphasisHealthbarColor:SetPoint("TOPLEFT", enableCastbarEmphasis, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    -- CreateTooltip(castBarEmphasisHealthbarColor, "Color the healthbar the color you've set\nin the list if that spell is being cast.")

    -- local castBarEmphasisColor = CreateCheckbox("castBarEmphasisColor", "Color castbar", enableCastbarEmphasis)
    -- castBarEmphasisColor:SetPoint("LEFT", castBarEmphasisHealthbarColor.text, "RIGHT", 0, 0)
    -- CreateTooltip(castBarEmphasisColor, "Color the castbar the color you've set\nin the list if that spell is being cast.")

    -- local castBarEmphasisSelfColor = CreateCheckbox("castBarEmphasisSelfColor", "Self Color", enableCastbarEmphasis)
    -- castBarEmphasisSelfColor:SetPoint("LEFT", castBarEmphasisColor.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(castBarEmphasisSelfColor, "Self Color", "Color a specific color if the cast is on me.\n\n|cff32f795Right-click to change Self Color.|r", "This is only for NPCs, due to API limitations.")
    -- castBarEmphasisSelfColor:HookScript("OnMouseDown", function(self, button)
    --     if button == "RightButton" then
    --         OpenColorOptions(BetterBlizzPlatesDB.castBarEmphasisSelfColorRGB, BBP.RefreshAllNameplates)
    --     end
    -- end)

    -- local castBarEmphasisHeight = CreateCheckbox("castBarEmphasisHeight", "Height", enableCastbarEmphasis)
    -- castBarEmphasisHeight:SetPoint("TOPLEFT", castBarEmphasisHealthbarColor, "BOTTOMLEFT", 0, -2)

    -- local castBarEmphasisIcon = CreateCheckbox("castBarEmphasisIcon", "Icon size", enableCastbarEmphasis)
    -- castBarEmphasisIcon:SetPoint("TOPLEFT", castBarEmphasisHeight, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)

    -- local castBarEmphasisText = CreateCheckbox("castBarEmphasisText", "Text size", enableCastbarEmphasis)
    -- castBarEmphasisText:SetPoint("TOPLEFT", castBarEmphasisIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)

    -- local castBarEmphasisSpark = CreateCheckbox("castBarEmphasisSpark", "Spark", enableCastbarEmphasis)
    -- castBarEmphasisSpark:SetPoint("TOPLEFT", castBarEmphasisText, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)
    -- CreateTooltip(castBarEmphasisSpark, "Spark is the little texture at the end of the current cast progress")

    -- local castBarEmphasisHeightValue = CreateSlider(enableCastbarEmphasis, "Emphasis height", 4, 40, 0.1, "castBarEmphasisHeightValue", "Height")
    -- castBarEmphasisHeightValue:SetPoint("LEFT", castBarEmphasisHeight, "RIGHT", 50, -1)

    -- local castBarEmphasisIconScale = CreateSlider(enableCastbarEmphasis, "Emphasis Icon Size", 1, 3, 0.1, "castBarEmphasisIconScale")
    -- castBarEmphasisIconScale:SetPoint("LEFT", castBarEmphasisIcon, "RIGHT", 50, -1)

    -- local castBarEmphasisTextScale = CreateSlider(enableCastbarEmphasis, "Emphasis text size", 0.5, 2.5, 0.1, "castBarEmphasisTextScale")
    -- castBarEmphasisTextScale:SetPoint("LEFT", castBarEmphasisText, "RIGHT", 50, -1)

    -- local castBarEmphasisSparkHeight = CreateSlider(enableCastbarEmphasis, "Emphasis Spark Size", 25, 60, 1, "castBarEmphasisSparkHeight", "Height")
    -- castBarEmphasisSparkHeight:SetPoint("LEFT", castBarEmphasisSpark, "RIGHT", 50, -1)

    -- local castBarInterruptHighlighterText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- castBarInterruptHighlighterText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -610, -485)
    -- castBarInterruptHighlighterText:SetText("Castbar Edge Highlight settings")

    -- local castBarInterruptHighlighter = CreateCheckbox("castBarInterruptHighlighter", "Castbar Edge Highlight", enableCastbarCustomization)
    -- castBarInterruptHighlighter:SetPoint("TOPLEFT", castBarInterruptHighlighterText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    -- CreateTooltipTwo(castBarInterruptHighlighter, "Castbar Highlight", "Color the start and end of the castbar differently.\nSet the time in seconds when to color the castbar below.")
    -- castBarInterruptHighlighter:HookScript("OnClick", function(self)
    --     BBP.ToggleSpellCastEventRegistration()
    --     if not self:GetChecked() then
    --         BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    --     end
    -- end)

    -- local castBarInterruptHighlighterColorDontInterrupt = CreateCheckbox("castBarInterruptHighlighterColorDontInterrupt", "Re-color between portion", castBarInterruptHighlighter)
    -- castBarInterruptHighlighterColorDontInterrupt:SetPoint("TOPLEFT", castBarInterruptHighlighter, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    -- CreateTooltipTwo(castBarInterruptHighlighterColorDontInterrupt, "Color Inbetween", "Color the middle section between start and finish as well. Pick a color.")

    -- local castBarInterruptHighlighterDontInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighterColorDontInterrupt, "UIPanelButtonTemplate")
    -- castBarInterruptHighlighterDontInterruptRGB:SetText("Color")
    -- castBarInterruptHighlighterDontInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterColorDontInterrupt.text, "RIGHT", 0, 0)
    -- castBarInterruptHighlighterDontInterruptRGB:SetSize(50, 20)
    -- CreateTooltip(castBarInterruptHighlighterDontInterruptRGB, "Castbar color inbetween the start and finish")
    -- local castBarInterruptHighlighterDontInterruptRGBIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    -- castBarInterruptHighlighterDontInterruptRGBIcon:SetAtlas("newplayertutorial-icon-key")
    -- castBarInterruptHighlighterDontInterruptRGBIcon:SetSize(18, 17)
    -- castBarInterruptHighlighterDontInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterDontInterruptRGB, "RIGHT", 0, -1)
    -- UpdateColorSquare(castBarInterruptHighlighterDontInterruptRGBIcon, unpack(BetterBlizzPlatesDB["castBarInterruptHighlighterDontInterruptRGB"] or {1, 1, 1}))
    -- castBarInterruptHighlighterDontInterruptRGB:SetScript("OnClick", function()
    --     OpenColorPicker("castBarInterruptHighlighterDontInterruptRGB", castBarInterruptHighlighterDontInterruptRGBIcon)
    -- end)

    -- local castBarInterruptHighlighterStartTime = CreateSlider(castBarInterruptHighlighter, "Start Seconds", 0, 2, 0.01, "castBarInterruptHighlighterStartTime", "Height")
    -- castBarInterruptHighlighterStartTime:SetPoint("TOPLEFT", castBarInterruptHighlighterColorDontInterrupt, "BOTTOMLEFT", 10, -6)
    -- CreateTooltip(castBarInterruptHighlighterStartTime, "How many seconds of the start of the cast you want to color the castbar.")

    -- local castBarInterruptHighlighterEndTime = CreateSlider(castBarInterruptHighlighter, "End Seconds", 0, 2, 0.01, "castBarInterruptHighlighterEndTime", "Height")
    -- castBarInterruptHighlighterEndTime:SetPoint("TOPLEFT", castBarInterruptHighlighterStartTime, "BOTTOMLEFT", 0, -10)
    -- CreateTooltip(castBarInterruptHighlighterEndTime, "How many seconds of the end of the cast you want to color the castbar.")

    -- local castBarInterruptHighlighterInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighter, "UIPanelButtonTemplate")
    -- castBarInterruptHighlighterInterruptRGB:SetText("Color")
    -- castBarInterruptHighlighterInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterEndTime, "RIGHT", 0, 15)
    -- castBarInterruptHighlighterInterruptRGB:SetSize(50, 20)
    -- CreateTooltip(castBarInterruptHighlighterInterruptRGB, "Castbar edge color")
    -- local castBarInterruptHighlighterInterruptRGBIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    -- castBarInterruptHighlighterInterruptRGBIcon:SetAtlas("newplayertutorial-icon-key")
    -- castBarInterruptHighlighterInterruptRGBIcon:SetSize(18, 17)
    -- castBarInterruptHighlighterInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterInterruptRGB, "RIGHT", 0, -1)
    -- UpdateColorSquare(castBarInterruptHighlighterInterruptRGBIcon, unpack(BetterBlizzPlatesDB["castBarInterruptHighlighterInterruptRGB"] or {1, 1, 1}))
    -- castBarInterruptHighlighterInterruptRGB:SetScript("OnClick", function()
    --     OpenColorPicker("castBarInterruptHighlighterInterruptRGB", castBarInterruptHighlighterInterruptRGBIcon)
    -- end)

    -- CheckAndToggleCheckboxes(castBarInterruptHighlighter)
    -- if not BetterBlizzPlatesDB.castBarInterruptHighlighter then
    --     castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(0)
    -- end

    enableCastbarCustomization:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarCustomization)
        if self:GetChecked() then
            -- if BetterBlizzPlatesDB.enableCastbarEmphasis then
            --     listFrame:SetAlpha(1)
            -- end
            if BetterBlizzPlatesDB.castBarRecolor then
                castBarCastColorIcon:SetAlpha(1)
                castBarChanneledColorIcon:SetAlpha(1)
                castBarNoninterruptibleColorIcon:SetAlpha(1)
            else
                castBarCastColorIcon:SetAlpha(0)
                castBarChanneledColorIcon:SetAlpha(0)
                castBarNoninterruptibleColorIcon:SetAlpha(0)
            end
            if BetterBlizzPlatesDB.castBarRecolorInterrupt then
                castBarNoInterruptColorIcon:SetAlpha(1)
                castBarDelayedInterruptColorIcon:SetAlpha(1)
            else
                castBarNoInterruptColorIcon:SetAlpha(0)
                castBarDelayedInterruptColorIcon:SetAlpha(0)
            end
            if BetterBlizzPlatesDB.useCustomCastbarTexture then
                if BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                    castBarBackgroundColor:Enable()
                    castBarBackgroundColor:SetAlpha(1)
                    castBarBackgroundColorIcon:SetAlpha(1)
                else
                    castBarBackgroundColor:Disable()
                    castBarBackgroundColor:SetAlpha(0)
                    castBarBackgroundColorIcon:SetAlpha(0)
                end
            else
                castBarBackgroundColor:SetAlpha(0)
                castBarBackgroundColor:Disable()
                castBarBackgroundColorIcon:SetAlpha(0)
            end
        else
            --listFrame:SetAlpha(0.5)
            castBarCastColorIcon:SetAlpha(0)
            castBarChanneledColorIcon:SetAlpha(0)
            castBarNoInterruptColorIcon:SetAlpha(0)
            castBarDelayedInterruptColorIcon:SetAlpha(0)
            castBarBackgroundColor:SetAlpha(0)
            castBarBackgroundColorIcon:SetAlpha(0)
        end
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    -- castBarInterruptHighlighter:HookScript("OnClick", function(self)
    --     CheckAndToggleCheckboxes(castBarInterruptHighlighter)
    --     if self:GetChecked() then
    --         if BetterBlizzPlatesDB.castBarInterruptHighlighterColorDontInterrupt then
    --             castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
    --         end
    --         castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(1)
    --     else
    --         castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
    --         castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(0)
    --     end
    -- end)

    -- castBarInterruptHighlighterColorDontInterrupt:HookScript("OnClick", function(self)
    --     CheckAndToggleCheckboxes(castBarInterruptHighlighter)
    --     if self:GetChecked() then
    --         castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
    --     else
    --         castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
    --     end
    -- end)

    castBarRecolor:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(castBarRecolor)
        if self:GetChecked() then
            castBarCastColorIcon:SetAlpha(1)
            castBarChanneledColorIcon:SetAlpha(1)
            castBarNoninterruptibleColorIcon:SetAlpha(1)
        else
            castBarCastColorIcon:SetAlpha(0)
            castBarChanneledColorIcon:SetAlpha(0)
            castBarNoninterruptibleColorIcon:SetAlpha(0)
        end
    end)

    castBarRecolorInterrupt:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(castBarRecolorInterrupt)
        if self:GetChecked() then
            castBarNoInterruptColorIcon:SetAlpha(1)
            castBarDelayedInterruptColorIcon:SetAlpha(1)
        else
            castBarNoInterruptColorIcon:SetAlpha(0)
            castBarDelayedInterruptColorIcon:SetAlpha(0)
        end
    end)

    useCustomCastbarBGTexture:HookScript("OnClick", function (self)
        --CheckAndToggleCheckboxes(useCustomCastbarBGTexture)
        if self:GetChecked() then
            customCastbarBGTextureDropdown:Enable()
            customCastbarBGTextureDropdown:SetAlpha(1)
            castBarBackgroundColor:Enable()
            castBarBackgroundColor:SetAlpha(1)
            castBarBackgroundColorIcon:SetAlpha(1)
        else
            customCastbarBGTextureDropdown:Disable()
            customCastbarBGTextureDropdown:SetAlpha(0.5)
            castBarBackgroundColor:Disable()
            castBarBackgroundColor:SetAlpha(0)
            castBarBackgroundColorIcon:SetAlpha(0)
        end
    end)

    local function TogglePanel()
        if BBP.variablesLoaded then
            -- if BetterBlizzPlatesDB.enableCastbarEmphasis then
            --     listFrame:SetAlpha(1)
            -- else
            --     listFrame:SetAlpha(0.5)
            -- end
            if BetterBlizzPlatesDB.castBarRecolor then
                castBarCastColor:Enable()
                castBarChanneledColor:Enable()
                castBarCastColorIcon:SetAlpha(1)
                castBarChanneledColorIcon:SetAlpha(1)
                castBarNoninterruptibleColor:Enable()
                castBarNoninterruptibleColorIcon:SetAlpha(1)
            else
                castBarCastColor:Disable()
                castBarChanneledColor:Disable()
                castBarCastColorIcon:SetAlpha(0)
                castBarChanneledColorIcon:SetAlpha(0)
                castBarNoninterruptibleColor:Disable()
                castBarNoninterruptibleColorIcon:SetAlpha(0)
            end
            if BetterBlizzPlatesDB.castBarRecolorInterrupt then
                castBarNoInterruptColor:Enable()
                castBarDelayedInterruptColor:Enable()
                castBarNoInterruptColorIcon:SetAlpha(1)
                castBarDelayedInterruptColorIcon:SetAlpha(1)
            else
                castBarNoInterruptColor:Disable()
                castBarDelayedInterruptColor:Disable()
                castBarNoInterruptColorIcon:SetAlpha(0)
                castBarDelayedInterruptColorIcon:SetAlpha(0)
            end
            if BetterBlizzPlatesDB.useCustomCastbarTexture then
                if BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                    customCastbarBGTextureDropdown:Enable()
                    castBarBackgroundColor:Enable()
                    castBarBackgroundColor:SetAlpha(1)
                    castBarBackgroundColorIcon:SetAlpha(1)
                else
                    customCastbarBGTextureDropdown:Disable()
                    castBarBackgroundColor:Disable()
                    castBarBackgroundColor:SetAlpha(0)
                    castBarBackgroundColorIcon:SetAlpha(0)
                end
            else
                castBarBackgroundColor:Disable()
                castBarBackgroundColor:SetAlpha(0)
                castBarBackgroundColorIcon:SetAlpha(0)
            end
            if not BetterBlizzPlatesDB.castBarInterruptHighlighterColorDontInterrupt then
                -- castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
                -- castBarInterruptHighlighterDontInterruptRGB:Disable()
            end
        else
            C_Timer.After(1, function()
                TogglePanel()
            end)
        end
    end
    TogglePanel()
end

local function guiClickingAndStacking()
    local sliderStartNumber = #sliderList + 1
    local guiClickNStack = CreateFrame("Frame")
    guiClickNStack.name = "|A:plunderstorm-pickup-mouseclick-left:16:16|a" .. L["Look_And_Behaviour"]
    guiClickNStack.parent = BetterBlizzPlates.name
    local guiClickNStackCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiClickNStack, guiClickNStack.name)
    CreateTitle(guiClickNStack)

    local bgImg = guiClickNStack:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiClickNStack, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local settingsText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, 0)
    settingsText:SetText(L["Search_Name_General"])
    settingsText:SetFont(fontLarge, 16)
    settingsText:SetTextColor(1,1,1)
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("optionsicon-brown")
    icon:SetSize(22, 22)
    icon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local info = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 300, 0)
    info:SetWidth(270)
    info:SetText(L["Blue_Nameplate_Box_Height_The_Invisible_Nameplate_Size"])

    local nameplateBoxHeight = CreateSlider(guiClickNStack, L["Nameplate_Box_Height"], 12, 70, 1, "nameplateBoxHeight")
    nameplateBoxHeight:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 8, -12)
    CreateTooltipTwo(nameplateBoxHeight, L["Nameplate_Box_Height"], L["Tooltip_Nameplate_Box_Height_Desc"])
    local nameplateBoxHeightReset = CreateResetButton(nameplateBoxHeight, "nameplateBoxHeight", nameplateBoxHeight)

    local nameplateVerticalPosition = CreateSlider(guiClickNStack, L["Nameplate_Vertical_Position"], -190, 70, 1, "nameplateVerticalPosition", "Y")
    nameplateVerticalPosition:SetPoint("TOPLEFT", nameplateBoxHeight, "BOTTOMLEFT", 0, -17)
    CreateResetButton(nameplateVerticalPosition, "nameplateVerticalPosition", guiClickNStack)

    local stackingText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackingText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -80)
    stackingText:SetText(L["Stacking"])
    stackingText:SetFont(fontLarge, 16)
    stackingText:SetTextColor(1,1,1)
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("MiniMap-PositionArrows")
    icon:SetSize(17, 25)
    icon:SetPoint("RIGHT", stackingText, "LEFT", -3, -1)

    local nameplateStackingEnemy = CreateCheckbox("nameplateStackingTypes_Enemy", L["Stacking_Enemy_Nameplates"], guiClickNStack, nil, nil, {cvarName = "nameplateStackingTypes", index = Enum.NamePlateStackType.Enemy})
    nameplateStackingEnemy:SetPoint("TOPLEFT", stackingText, "BOTTOMLEFT", -4, -pixelsOnFirstBox)
    CreateTooltipTwo(nameplateStackingEnemy, L["Stacking_Enemy_Nameplates"], L["Tooltip_Toggle_Stacking_Enemy_Nameplates_Desc"], nil, nil, "nameplateStackingTypes")

    local nameplateStackingFriendly = CreateCheckbox("nameplateStackingTypes_Friendly", L["Stacking_Friendly_Nameplates"], guiClickNStack, nil, nil, {cvarName = "nameplateStackingTypes", index = Enum.NamePlateStackType.Friendly})
    nameplateStackingFriendly:SetPoint("TOPLEFT", nameplateStackingEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateStackingFriendly, L["Stacking_Friendly_Nameplates"], L["Tooltip_Toggle_Stacking_Friendly_Nameplates_Desc"], nil, nil, "nameplateStackingTypes")

    local stackingHorizontalOffset = CreateSlider(guiClickNStack, L["Stacking_Zone_Width"], -60, 60, 1, "stackingHorizontalOffset", "X")
    stackingHorizontalOffset:SetPoint("TOPLEFT", nameplateStackingFriendly, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(stackingHorizontalOffset, L["Stacking_Zone_Width"], L["Tooltip_Stacking_Zone_Width_Desc"])
    local stackingHorizontalOffsetReset = CreateResetButton(stackingHorizontalOffset, "stackingHorizontalOffset", stackingHorizontalOffset)

    local stackingVerticalOffset = CreateSlider(guiClickNStack, L["Stacking_Zone_Height"], -60, 60, 1, "stackingVerticalOffset", "Y")
    stackingVerticalOffset:SetPoint("TOPLEFT", stackingHorizontalOffset, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(stackingVerticalOffset, L["Stacking_Zone_Height"], L["Tooltip_Stacking_Zone_Height_Desc"])
    local stackingVerticalOffsetReset = CreateResetButton(stackingVerticalOffset, "stackingVerticalOffset", stackingVerticalOffset)

    local stackingVerticalAdjustmentOffset = CreateSlider(guiClickNStack, L["Stacking_Zone_Y_Offset"], -60, 60, 1, "stackingVerticalAdjustmentOffset", "Y")
    stackingVerticalAdjustmentOffset:SetPoint("TOPLEFT", stackingVerticalOffset, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(stackingVerticalAdjustmentOffset, L["Stacking_Zone_Y_Offset"], L["Tooltip_Stacking_Zone_Y_Offset_Desc"])
    local stackingVerticalAdjustmentOffsetReset = CreateResetButton(stackingVerticalAdjustmentOffset, "stackingVerticalAdjustmentOffset", stackingVerticalAdjustmentOffset)

    local nameplateOverlapH = CreateSlider(guiClickNStack, L["Horizontal_Stacking_Overlap"], 0.3, 1.2, 0.01, "nameplateOverlapH")
    nameplateOverlapH:SetPoint("TOPLEFT", stackingVerticalAdjustmentOffset, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOverlapH, L["Horizontal_Stacking_Overlap"], L["Tooltip_Horizontal_Stacking_Overlap_Desc"])
    local nameplateOverlapHReset = CreateResetButton(nameplateOverlapH, "nameplateOverlapH", nameplateOverlapH)

    local nameplateOverlapV = CreateSlider(guiClickNStack, L["Vertical_Stacking_Overlap"], 0.3, 1.2, 0.01, "nameplateOverlapV")
    nameplateOverlapV:SetPoint("TOPLEFT", nameplateOverlapH, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOverlapV, L["Vertical_Stacking_Overlap"], L["Tooltip_Horizontal_Stacking_Overlap_Desc"])
    local nameplateOverlapVReset = CreateResetButton(nameplateOverlapV, "nameplateOverlapV", nameplateOverlapV)

    local nameplateMotionSpeed = CreateSlider(guiClickNStack, L["Nameplate_Motion_Speed"], 0.01, 1, 0.01, "nameplateMotionSpeed")
    nameplateMotionSpeed:SetPoint("TOPLEFT", nameplateOverlapV, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateMotionSpeed, L["Nameplate_Motion_Speed"], L["Tooltip_Nameplate_Motion_Speed_Desc"], nil, nil, "nameplateMotionSpeed")
    local nameplateMotionSpeedReset = CreateResetButton(nameplateMotionSpeed, "nameplateMotionSpeed", nameplateMotionSpeed)

    local stackingSliders = {stackingHorizontalOffset, stackingVerticalOffset, stackingHorizontalOffsetReset, stackingVerticalOffsetReset,stackingVerticalAdjustmentOffset,stackingVerticalAdjustmentOffsetReset, nameplateOverlapH, nameplateOverlapHReset, nameplateOverlapV, nameplateOverlapVReset, nameplateMotionSpeed, nameplateMotionSpeedReset}
    local function ToggleStackingSliders()
        local eitherChecked = nameplateStackingEnemy:GetChecked() or nameplateStackingFriendly:GetChecked()
        for _, element in ipairs(stackingSliders) do
            if eitherChecked then
                element:Enable()
                element:SetAlpha(1)
            else
                element:Disable()
                element:SetAlpha(0.5)
            end
        end
    end

    local function InitStackingSliders()
        if not BBP.variablesLoaded then
            C_Timer.After(0.1, InitStackingSliders)
            return
        end
        local bf = BetterBlizzPlatesDB.bitfields and BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"]
        if bf then
            nameplateStackingEnemy:SetChecked(bf[tostring(Enum.NamePlateStackType.Enemy)] and true or false)
            nameplateStackingFriendly:SetChecked(bf[tostring(Enum.NamePlateStackType.Friendly)] and true or false)
        else
            nameplateStackingEnemy:SetChecked(C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy) and true or false)
            nameplateStackingFriendly:SetChecked(C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly) and true or false)
        end
        ToggleStackingSliders()
    end
    InitStackingSliders()
    BBP.SyncStackingCheckboxes = function()
        if BBP.variablesLoaded then InitStackingSliders() end
    end

    nameplateStackingEnemy:HookScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        BBP.RunAfterCombat(function()
            if not BetterBlizzPlatesDB.bitfields then BetterBlizzPlatesDB.bitfields = {} end
            if not BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"] then BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"] = {} end
            BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"][tostring(Enum.NamePlateStackType.Enemy)] = isChecked
            C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, isChecked)
            BBP.SaveNameplateToggleStacking("Enemy", isChecked)
        end)
        ToggleStackingSliders()
    end)
    nameplateStackingFriendly:HookScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        BBP.RunAfterCombat(function()
            if not BetterBlizzPlatesDB.bitfields then BetterBlizzPlatesDB.bitfields = {} end
            if not BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"] then BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"] = {} end
            BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"][tostring(Enum.NamePlateStackType.Friendly)] = isChecked
            C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, isChecked)
            BBP.SaveNameplateToggleStacking("Friendly", isChecked)
        end)
        ToggleStackingSliders()
    end)

    local clickingText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clickingText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -326)
    clickingText:SetText(L["Clicking"])
    clickingText:SetFont(fontLarge, 16)
    clickingText:SetTextColor(1,1,1)
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("plunderstorm-pickup-mouseclick-left")
    icon:SetSize(24, 26)
    icon:SetPoint("RIGHT", clickingText, "LEFT", -3, -1)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", L["Friendly_Clickthrough"], guiClickNStack, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", clickingText, "BOTTOMLEFT", -4, -pixelsOnFirstBox)
    CreateTooltipTwo(friendlyNameplateClickthrough, L["Clickthrough_Friendly_Nameplate"], L["Tooltip_Clickthrough_Nameplate_Desc"])

    local nameplateExtraClickWidth = CreateSlider(guiClickNStack, L["Nameplate_Extra_Click_Width"], -60, 6, 1, "nameplateExtraClickWidth", "X")
    nameplateExtraClickWidth:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 12, -10)
    CreateResetButton(nameplateExtraClickWidth, "nameplateExtraClickWidth", guiClickNStack)

    local nameplateExtraClickHeight = CreateSlider(guiClickNStack, L["Nameplate_Extra_Click_Height"], -38, 30, 1, "nameplateExtraClickHeight", "Y")
    nameplateExtraClickHeight:SetPoint("TOPLEFT", nameplateExtraClickWidth, "BOTTOMLEFT", 0, -16)
    CreateResetButton(nameplateExtraClickHeight, "nameplateExtraClickHeight", guiClickNStack)

    local nameplateClickVerticalAdjustment = CreateSlider(guiClickNStack, L["Nameplate_Click_Area_Y_Offset"], -20, 20, 1, "nameplateClickVerticalAdjustment", "Y")
    nameplateClickVerticalAdjustment:SetPoint("TOPLEFT", nameplateExtraClickHeight, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(nameplateClickVerticalAdjustment, L["Clickable_Vertical_Position"], L["Tooltip_Clickable_Vertical_Position_Desc"])
    CreateResetButton(nameplateClickVerticalAdjustment, "nameplateClickVerticalAdjustment", guiClickNStack)

    local castbarText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -461)
    castbarText:SetText(L["Castbar_Adjustments"])
    castbarText:SetFont(fontLarge, 16)
    castbarText:SetTextColor(1,1,1)
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("UI-CastingBar-Pip")
    icon:SetSize(22, 22)
    icon:SetPoint("RIGHT", castbarText, "LEFT", -3, -1)


    local fitCastIconLeftOfCast
    local classic = BetterBlizzPlatesDB.classicNameplates
    if not classic then
        fitCastIconLeftOfCast = CreateCheckbox("fitCastIconLeftOfCast", L["Fit_Cast_Icon_On_The_Left"], guiClickNStack)
        fitCastIconLeftOfCast:SetPoint("TOPLEFT", castbarText, "BOTTOMLEFT", -4, -pixelsOnFirstBox)
        CreateTooltipTwo(fitCastIconLeftOfCast, L["Fit_Cast_Icon_On_The_Left"], L["Tooltip_Fit_Cast_Icon_On_The_Left_Desc"], L["Tooltip_Fit_Cast_Icon_Right_Note"] .. "\n" .. L["Tooltip_Not_Used_With_Classic_Castbar"])
        local function UpdateFitCastIconEnabled()
            if BBP.UsesClassicCastbar() then
                DisableElement(fitCastIconLeftOfCast)
            else
                EnableElement(fitCastIconLeftOfCast)
            end
        end
        fitCastIconLeftOfCast:SetMotionScriptsWhileDisabled(true)
        fitCastIconLeftOfCast:HookScript("OnShow", UpdateFitCastIconEnabled)
        UpdateFitCastIconEnabled()
    end

    -- local fitCastIconLeftOfCastAndHp = CreateCheckbox("fitCastIconLeftOfCastAndHp", "Fit Cast Icon Left of Bars", guiClickNStack)
    -- fitCastIconLeftOfCastAndHp:SetPoint("TOPLEFT", fitCastIconLeftOfCast, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(fitCastIconLeftOfCastAndHp, "Fit Cast Icon Left of Bars", "Position the castbar icon on the left side of the healthbar and cast bar, stretching from the bottom of the cast bar to the top of the healthbar.")

    local xPos, yPos
    if classic then
        xPos, yPos = 8, -12
    else
        xPos, yPos = 12, -10
    end

    local enemyCastbarExtraWidth = CreateSlider(guiClickNStack, L["Castbar_Width_Enemy"], -60, 60, 1, "enemyCastbarExtraWidth", "X")
    enemyCastbarExtraWidth:SetPoint("TOPLEFT", fitCastIconLeftOfCast or castbarText, "BOTTOMLEFT", xPos, yPos)
    CreateTooltipTwo(enemyCastbarExtraWidth, L["Enemy_Castbar_Extra_Width"], L["Tooltip_Enemy_Castbar_Extra_Width_Desc"])
    CreateResetButton(enemyCastbarExtraWidth, "enemyCastbarExtraWidth", guiClickNStack)

    local friendlyCastbarExtraWidth = CreateSlider(guiClickNStack, L["Castbar_Width_Friendly"], -60, 60, 1, "friendlyCastbarExtraWidth", "X")
    friendlyCastbarExtraWidth:SetPoint("TOPLEFT", enemyCastbarExtraWidth, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(friendlyCastbarExtraWidth, L["Friendly_Castbar_Extra_Width"], L["Tooltip_Friendly_Castbar_Extra_Width_Desc"])
    CreateResetButton(friendlyCastbarExtraWidth, "friendlyCastbarExtraWidth", guiClickNStack)

    local castBarXPos = CreateSlider(guiClickNStack, L["Castbar_Horizontal_Position"], -50, 50, 1, "castBarXPos", "X")
    castBarXPos:SetPoint("TOPLEFT", friendlyCastbarExtraWidth, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(castBarXPos, L["Castbar_Horizontal_Position"], L["Tooltip_Castbar_Horizontal_Position_Desc"])
    CreateResetButton(castBarXPos, "castBarXPos", guiClickNStack)

    local spacingBetweenCastAndHealthbar = CreateSlider(guiClickNStack, L["Castbar_Vertical_Position"], -50, 50, 1, "spacingBetweenCastAndHealthbar", "Y")
    spacingBetweenCastAndHealthbar:SetPoint("TOPLEFT", castBarXPos, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(spacingBetweenCastAndHealthbar, L["Castbar_Vertical_Position"], L["Tooltip_Castbar_Vertical_Position_Desc"])
    CreateResetButton(spacingBetweenCastAndHealthbar, "spacingBetweenCastAndHealthbar", guiClickNStack)

    local clickAndStackTestButton = CreateFrame("Button", nil, guiClickNStack, "GameMenuButtonTemplate")
    clickAndStackTestButton:SetSize(110, 25)
    clickAndStackTestButton:SetText(L["Test"])
    clickAndStackTestButton:SetNormalFontObject("GameFontNormal")
    clickAndStackTestButton:SetHighlightFontObject("GameFontHighlight")
    clickAndStackTestButton:SetPoint("TOP", info, "BOTTOM", 0, -10)
    CreateTooltipTwo(clickAndStackTestButton, L["Test_Click_And_Stacking"], L["Tooltip_Test_Click_And_Stacking_Desc"], nil, "ANCHOR_LEFT")

    local testModeActive = false
    clickAndStackTestButton:SetScript("OnClick", function(self)
        testModeActive = not testModeActive
        if testModeActive then
            self:SetText(L["Label_Stop_Testing"])
            BBP.ClickAndStackTestMode(true)
        else
            self:SetText(L["Test"])
            BBP.ClickAndStackTestMode(false)
        end
    end)

    for i = sliderStartNumber, #sliderList do
        sliderList[i].slider:SetScale(0.9)
    end

end

local function guiHideCastbar()
    ------------------
    -- Hide Cast
    ------------------
    local guiHideCastbar = CreateFrame("Frame")
    guiHideCastbar.name = L["Hide_Castbar"]
    guiHideCastbar.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiHideCastbar)
    local guiHideCastbarCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiHideCastbar, guiHideCastbar.name)
    CreateTitle(guiHideCastbar)

    local bgImg = guiHideCastbar:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiHideCastbar, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiHideCastbar)
    listFrame:SetAllPoints(guiHideCastbar)

    local hideCastbarListExplanationText = guiHideCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideCastbarListExplanationText:SetPoint("TOP", guiHideCastbar, "BOTTOMLEFT", 180, 155)
    hideCastbarListExplanationText:SetText(L["Add_Spell_Name_Spell_ID_Npc_Name_Or"])

    local hideCastbarExplanationText = guiHideCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideCastbarExplanationText:SetPoint("TOP", guiHideCastbar, "TOP", 172, -127)
    hideCastbarExplanationText:SetText(L["Hide_Castbar_For_Chosen_Spells_NPCs_Or_Only"])

    local hideCastbar = CreateCheckbox("hideCastbar", L["Enable_Hide_Castbar"], guiHideCastbar)
    hideCastbar:SetPoint("TOPLEFT", hideCastbarExplanationText, "BOTTOMLEFT", 25, -15)
    hideCastbar:HookScript("OnClick", function(_, btn, down)
        BBP.ToggleSpellCastEventRegistration()
    end)
    CreateTooltip(hideCastbar, L["Tooltip_Hide_The_Castbar_For_Chosen_Spells"])

    local hideCastbarFrame = CreateFrame("Frame", nil, listFrame)
    hideCastbarFrame:SetSize(322, 390)
    hideCastbarFrame:SetPoint("TOPLEFT", 0, 0)

    local hideCastbarWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    hideCastbarWhitelistFrame:SetSize(322, 390)
    hideCastbarWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = hideCastbarWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", hideCastbarWhitelistFrame, "TOP", 0, -5)
    whitelistOnText:SetText(L["Whitelist_ON"])

    CreateList(hideCastbarFrame, "hideCastbarList", BetterBlizzPlatesDB.hideCastbarList, BBP.RefreshAllNameplates, false)
    CreateList(hideCastbarWhitelistFrame, "hideCastbarWhitelist", BetterBlizzPlatesDB.hideCastbarWhitelist, BBP.RefreshAllNameplates, false)

    local hideCastbarWhitelist = CreateCheckbox("hideCastbarWhitelistOn", L["Whitelist_Mode"], hideCastbar)
    hideCastbarWhitelist:SetPoint("TOPLEFT", hideCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCastbarWhitelist, L["Tooltip_Hide_Castbar_For_ALL_Spells_Except"])

    local showCastbarIfTarget = CreateCheckbox("showCastbarIfTarget", L["Always_Show_Castbar_On_Target"], hideCastbar)
    showCastbarIfTarget:SetPoint("TOPLEFT", hideCastbarWhitelist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local onlyShowInterruptableCasts = CreateCheckbox("onlyShowInterruptableCasts", L["Only_Show_Interruptable_Casts"], hideCastbar)
    onlyShowInterruptableCasts:SetPoint("TOPLEFT", showCastbarIfTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideNpcCastbar = CreateCheckbox("hideNpcCastbar", L["Hide_All_NPC_Castbars"], hideCastbar)
    hideNpcCastbar:SetPoint("TOPLEFT", onlyShowInterruptableCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNpcCastbar, L["Hide_NPC_Castbars"], L["Tooltip_Hide_NPC_Castbars_Desc"])

    local hideCastbarFriendly = CreateCheckbox("hideCastbarFriendly", L["Hide_Friendly_Castbars"], hideCastbar)
    hideCastbarFriendly:SetPoint("TOPLEFT", hideNpcCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarFriendly, L["Hide_Friendly_Castbars"], L["Tooltip_Hide_Friendly_Castbars_2_Desc"])

    local hideCastbarEnemy = CreateCheckbox("hideCastbarEnemy", L["Hide_Enemy_Castbars"], hideCastbar)
    hideCastbarEnemy:SetPoint("TOPLEFT", hideCastbarFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarEnemy, L["Hide_Enemy_Castbars"], L["Tooltip_Hide_Enemy_Castbars_2_Desc"])

    local function handleVisibility()
        if BetterBlizzPlatesDB.hideCastbarWhitelistOn then
            hideCastbarFrame:Hide()
            hideCastbarWhitelistFrame:Show()
        else
            hideCastbarFrame:Show()
            hideCastbarWhitelistFrame:Hide()
        end
    end
    hideCastbarWhitelist:HookScript("OnClick", function(_, btn, down)
        handleVisibility()
    end)
    handleVisibility()

    hideCastbar:HookScript("OnClick", function(_, btn, down)
        CheckAndToggleCheckboxes(hideCastbar)
    end)

    hideCastbar:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(hideCastbar)
        if self:GetChecked() then
            listFrame:SetAlpha(1)
        else
            listFrame:SetAlpha(0.5)
        end
    end)
    if not BetterBlizzPlatesDB.hideCastbar then
        listFrame:SetAlpha(0.5)
    end
end

local function guiFadeNPC()
    ---------------------
    -- Fade out NPC
    ---------------------
    local guiFadeNpc = CreateFrame("Frame")
    guiFadeNpc.name = L["Fade_NPC"]
    guiFadeNpc.parent = BetterBlizzPlates.name
    local guiFadeNpcCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiFadeNpc, guiFadeNpc.name)
    CreateTitle(guiFadeNpc)

    local bgImg = guiFadeNpc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiFadeNpc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiFadeNpc)
    listFrame:SetAllPoints(guiFadeNpc)

    local fadeOutNPCListFrame = CreateFrame("Frame", nil, listFrame)
    fadeOutNPCListFrame:SetSize(322, 390)
    fadeOutNPCListFrame:SetPoint("TOPLEFT", 0, 0)

    local fadeOutNPCWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    fadeOutNPCWhitelistFrame:SetSize(322, 390)
    fadeOutNPCWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = fadeOutNPCWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", fadeOutNPCWhitelistFrame, "TOP", 0, -5)
    whitelistOnText:SetText(L["Whitelist_ON"])

    CreateList(fadeOutNPCListFrame, "fadeOutNPCsList", BetterBlizzPlatesDB.fadeOutNPCsList, BBP.RefreshAllNameplates, false)
    CreateList(fadeOutNPCWhitelistFrame, "fadeOutNPCsWhitelist", BetterBlizzPlatesDB.fadeOutNPCsWhitelist, BBP.RefreshAllNameplates, false)

    local how2usefade = guiFadeNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usefade:SetPoint("TOP", guiFadeNpc, "BOTTOMLEFT", 180, 155)
    how2usefade:SetText(L["Add_Name_Or_NpcID_Case_Insensitive_Add_A"])

    local fadeOutNPCsAlpha = CreateSlider(guiFadeNpc, L["Alpha_Value"], 0, 1, 0.01, "fadeOutNPCsAlpha", "Alpha")
    fadeOutNPCsAlpha:SetPoint("TOPRIGHT", guiFadeNpc, "TOPRIGHT", -90, -90)

    local noteFade = guiFadeNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteFade:SetPoint("TOP", fadeOutNPCsAlpha, "BOTTOM", 0, -20)
    noteFade:SetText(L["This_Makes_Nameplates_Transparent_You_Will_Still_Be"])

    local fadeOutNPC = CreateCheckbox("fadeOutNPC", L["Enable_Fade_NPC"], guiFadeNpc)
    fadeOutNPC:SetPoint("TOPLEFT", noteFade, "BOTTOMLEFT", 20, -15)
    fadeOutNPC:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    -- local fadeAllButTarget = CreateCheckbox("fadeAllButTarget", "Fade All Except Target", fadeOutNPC)
    -- fadeAllButTarget:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(fadeAllButTarget, "Fade out all other nameplates when you have a target.\nDisregards the fade list")

    local fadeNPCPvPOnly = CreateCheckbox("fadeNPCPvPOnly", L["Only_Fade_NPCs_In_PvP"], fadeOutNPC)
    fadeNPCPvPOnly:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fadeNPCPvPOnly, L["Only_Fade_Nameplates_In_Arena_And_BGs"])

    local fadeOutNPCWhitelistOn = CreateCheckbox("fadeOutNPCWhitelistOn", L["Whitelist_Mode"], fadeOutNPC)
    fadeOutNPCWhitelistOn:SetPoint("TOPLEFT", fadeNPCPvPOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    fadeOutNPCWhitelistOn:HookScript("OnClick", function (self)
        if self:GetChecked() then
            fadeOutNPCListFrame:Hide()
            fadeOutNPCWhitelistFrame:Show()
        else
            fadeOutNPCListFrame:Show()
            fadeOutNPCWhitelistFrame:Hide()
        end
    end)
    CreateTooltipTwo(fadeOutNPCWhitelistOn, L["Whitelist_Mode"], L["Tooltip_Whitelist_Mode_2_Desc"])

    local fadeOutNPCOnlyFadeSecondaryPets = CreateCheckbox("fadeOutNPCOnlyFadeSecondaryPets", L["Dont_Fade_Main_Pet"], fadeOutNPC)
    fadeOutNPCOnlyFadeSecondaryPets:SetPoint("TOPLEFT", fadeOutNPCWhitelistOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fadeOutNPCOnlyFadeSecondaryPets, L["Dont_Fade_Main_Pets"], L["Tooltip_Dont_Fade_Main_Pets_Desc"], L["Tooltip_Dont_Fade_Main_Pets_SubText"])

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.fadeOutNPC then
                listFrame:SetAlpha(1)
                if BetterBlizzPlatesDB.fadeOutNPCWhitelistOn then
                    fadeOutNPCListFrame:Hide()
                    fadeOutNPCWhitelistFrame:Show()
                else
                    fadeOutNPCListFrame:Show()
                    fadeOutNPCWhitelistFrame:Hide()
                end
            else
                listFrame:SetAlpha(0.5)
                if BetterBlizzPlatesDB.fadeOutNPCWhitelistOn then
                    fadeOutNPCListFrame:Hide()
                    fadeOutNPCWhitelistFrame:Show()
                else
                    fadeOutNPCListFrame:Show()
                    fadeOutNPCWhitelistFrame:Hide()
                end
            end
        else
            C_Timer.After(1, function()
                TogglePanel()
            end)
        end
    end
    fadeOutNPC:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(fadeOutNPC)
        TogglePanel()
    end)
    TogglePanel()
end

local function guiHideNPC()
    -----------------------
    -- Hide NPC
    -----------------------
    local guiHideNpc = CreateFrame("Frame")
    guiHideNpc.name = L["Hide_NPC"]
    guiHideNpc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiHideNpc)
    local guiHideNpcCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiHideNpc, guiHideNpc.name)
    CreateTitle(guiHideNpc)

    local bgImg = guiHideNpc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiHideNpc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local hideNpcListExplanationText = guiHideNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideNpcListExplanationText:SetPoint("TOP", guiHideNpc, "BOTTOMLEFT", 180, 155)
    hideNpcListExplanationText:SetText(L["Add_Name_Or_NpcID_Case_Insensitive_Add_A"])

    local hideNpcExplanationText = guiHideNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideNpcExplanationText:SetPoint("TOP", guiHideNpc, "TOP", 172, -127)
    hideNpcExplanationText:SetText(L["This_Hides_Nameplates_The_Nameplates_Also_Become_Unclickable"])

    local hideNPC = CreateCheckbox("hideNPC", L["Enable_Hide_NPC"], guiHideNpc, nil, BBP.hideNPC)
    hideNPC:SetPoint("TOPLEFT", hideNpcExplanationText, "BOTTOMLEFT", 25, -15)
    CreateTooltip(hideNPC, L["Tooltip_Hide_NPCs_From_The_Blacklist_Or"])
    hideNPC:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local listFrame = CreateFrame("Frame", nil, guiHideNpc)
    listFrame:SetAllPoints(guiHideNpc)

    local hideNPCListFrame = CreateFrame("Frame", nil, listFrame)
    hideNPCListFrame:SetSize(322, 390)
    hideNPCListFrame:SetPoint("TOPLEFT", 0, 0)

    local hideNPCWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    hideNPCWhitelistFrame:SetSize(322, 390)
    hideNPCWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = hideNPCWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", hideNPCWhitelistFrame, "TOP", 0, -5)
    whitelistOnText:SetText(L["Whitelist_ON"])

    CreateList(hideNPCListFrame, "hideNPCsList", BetterBlizzPlatesDB.hideNPCsList, BBP.RefreshAllNameplates, false)
    CreateList(hideNPCWhitelistFrame, "hideNPCsWhitelist", BetterBlizzPlatesDB.hideNPCsWhitelist, BBP.RefreshAllNameplates, false)

    local murlocTexture = guiHideNpc:CreateTexture(nil, "OVERLAY")
    murlocTexture:SetAtlas("newplayerchat-chaticon-newcomer")
    murlocTexture:SetPoint("BOTTOM", hideNPCListFrame, "TOPRIGHT", -30, -9)
    murlocTexture:SetSize(17,17)
    CreateTooltip(murlocTexture, L["Tooltip_Murloc_Icon_Checkboxes"])

    local hideNpcMurlocScale = CreateSlider(hideNPC, L["Murloc_Size"], 0.7, 2.2, 0.01, "hideNpcMurlocScale")
    hideNpcMurlocScale:SetPoint("TOPRIGHT", guiHideNpc, "TOPRIGHT", -90, -365)

    local hideNpcMurlocYPos = CreateSlider(hideNPC, L["Murloc_Y_Position"], -50, 50, 1, "hideNpcMurlocYPos", "Y")
    hideNpcMurlocYPos:SetPoint("TOPRIGHT", guiHideNpc, "TOPRIGHT", -90, -410)

    local hideNPCWhitelistOn = CreateCheckbox("hideNPCWhitelistOn", L["Whitelist_Mode"], hideNPC)
    hideNPCWhitelistOn:SetPoint("TOPLEFT", hideNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hideNPCWhitelistOn:HookScript("OnClick", function (self)
        if self:GetChecked() then
            hideNPCListFrame:Hide()
            hideNPCWhitelistFrame:Show()
        else
            hideNPCListFrame:Show()
            hideNPCWhitelistFrame:Hide()
        end
    end)
    CreateTooltip(hideNPCWhitelistOn, L["Tooltip_Hides_ALL_NPCs_Except_The_Ones"])

    local hideNPCArenaOnly = CreateCheckbox("hideNPCArenaOnly", L["Only_Hide_NPCs_In_PvP"], hideNPC)
    hideNPCArenaOnly:SetPoint("TOPLEFT", hideNPCWhitelistOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- local hideNPCPetsOnly = CreateCheckbox("hideNPCPetsOnly", "Hide Player Pets", hideNPC)
    -- hideNPCPetsOnly:SetPoint("TOPLEFT", hideNPCArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(hideNPCPetsOnly, "Hide all player pets.")

    local hideNPCAllNeutral = CreateCheckbox("hideNPCAllNeutral", L["Hide_Neutral_NPCs"], hideNPC)
    hideNPCAllNeutral:SetPoint("TOPLEFT", hideNPCArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCAllNeutral, L["Hide_Neutral_NPCs"], L["Tooltip_Hide_Neutral_NPCs_Desc"])

    local hideNPCHideOthersPets = CreateCheckbox("hideNPCHideOthersPets", L["Hide_Others_Pets"], hideNPC)
    hideNPCHideOthersPets:SetPoint("TOPLEFT", hideNPCAllNeutral, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCHideOthersPets, L["Hide_Others_Pets"], L["Tooltip_Hide_Others_Pets_Desc"], L["Tooltip_Hide_Others_Pets_SubText"])

    local hideNPCHideSecondaryPets = CreateCheckbox("hideNPCHideSecondaryPets", L["Hide_Secondary_Pets"], hideNPC)
    hideNPCHideSecondaryPets:SetPoint("TOPLEFT", hideNPCHideOthersPets, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCHideSecondaryPets, L["Hide_Secondary_Pets"], L["Tooltip_Hide_Secondary_Pets_Desc_2"], L["Tooltip_Hide_Secondary_Pets_SubText"])

    local hideNPCSecondaryShowMurloc = CreateCheckbox("hideNPCSecondaryShowMurloc", L["Murloc_Secondary_Pets"], hideNPCHideSecondaryPets)
    hideNPCSecondaryShowMurloc:SetPoint("TOPLEFT", hideNPCHideSecondaryPets, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCSecondaryShowMurloc, L["Murloc_Secondary_Pets"], L["Tooltip_Murloc_Secondary_Pets_Desc"])
    hideNPCSecondaryShowMurloc:HookScript("OnClick", function(self)
        if self:GetChecked() then
            if not hideNPCHideSecondaryPets:GetChecked() then
                hideNPCHideSecondaryPets:Click()
            end
        end
    end)

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.hideNPC then
                listFrame:SetAlpha(1)
                if BetterBlizzPlatesDB.hideNPCWhitelistOn then
                    hideNPCListFrame:Hide()
                    hideNPCWhitelistFrame:Show()
                else
                    hideNPCListFrame:Show()
                    hideNPCWhitelistFrame:Hide()
                end
            else
                listFrame:SetAlpha(0.5)
                if BetterBlizzPlatesDB.hideNPCWhitelistOn then
                    hideNPCListFrame:Hide()
                    hideNPCWhitelistFrame:Show()
                else
                    hideNPCListFrame:Show()
                    hideNPCWhitelistFrame:Hide()
                end
            end
        else
            C_Timer.After(1, function()
                TogglePanel()
            end)
        end
    end
    hideNPC:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(hideNPC)
        TogglePanel()
    end)
    TogglePanel()
end

local function guiColorNPC()
    -------------------
    -- Color NPC
    -------------------
    local guiColorNpc = CreateFrame("Frame")
    guiColorNpc.name = L["Color_NPC"]
    guiColorNpc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiColorNpc)
    local guiColorNpcCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiColorNpc, guiColorNpc.name)
    CreateTitle(guiColorNpc)

    local bgImg = guiColorNpc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiColorNpc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local npcColorSettingsText = guiColorNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    npcColorSettingsText:SetPoint("LEFT", guiColorNpc, "TOPLEFT", 5, -5)
    npcColorSettingsText:SetText(L["NPC_Color_Settings"])
    npcColorSettingsText:SetFont(fontLarge, 16)
    npcColorSettingsText:SetTextColor(1,1,1)
    local npcColorSettingsIcon = guiColorNpc:CreateTexture(nil, "ARTWORK")
    npcColorSettingsIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    npcColorSettingsIcon:SetSize(24, 24)
    npcColorSettingsIcon:SetPoint("RIGHT", npcColorSettingsText, "LEFT", -3, 0)

    local colorNPC = CreateCheckbox("colorNPC", L["Enable_Color_NPC"], guiColorNpc, nil, BBP.colorNPC)
    colorNPC:SetPoint("TOPLEFT", npcColorSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)
    CreateTooltip(colorNPC, L["Tooltip_Color_NPCs_A_Color_Of_Your"])

    local colorNPCEverywhere = CreateCheckbox("colorNPCEverywhere", L["Color_NPCs_Everywhere"], colorNPC, nil, BBP.colorNPC)
    colorNPCEverywhere:SetPoint("TOPLEFT", colorNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(colorNPCEverywhere, L["Color_NPCs_Everywhere"], L["Tooltip_Color_NPCs_Everywhere_Desc"])

    local colorNPCName = CreateCheckbox("colorNPCName", L["Also_Color_Name_Text"], colorNPC, nil, BBP.colorNPC)
    colorNPCName:SetPoint("TOPLEFT", colorNPCEverywhere, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local colorNPCNeutralHpCombatOnly = CreateCheckbox("colorNPCNeutralHpCombatOnly", L["Color_Neutral_Healthbars_Only_In_Combat"], colorNPC, nil, BBP.colorNPC)
    colorNPCNeutralHpCombatOnly:SetPoint("TOPLEFT", colorNPCName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(colorNPCNeutralHpCombatOnly, L["Color_Neutral_Healthbars_Only_In_Combat"], L["Tooltip_Color_Neutral_Healthbars_Only_In_Combat_Desc"])

    local colorNPCNeutralNameCombatOnly = CreateCheckbox("colorNPCNeutralNameCombatOnly", L["Color_Neutral_Names_Only_In_Combat"], colorNPC, nil, BBP.colorNPC)
    colorNPCNeutralNameCombatOnly:SetPoint("TOPLEFT", colorNPCNeutralHpCombatOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(colorNPCNeutralNameCombatOnly, L["Color_Neutral_Names_Only_In_Combat"], L["Tooltip_Color_Neutral_Names_Only_In_Combat_Desc"])

    local npcColorBoss = CreateColorBox(colorNPC, "npcColorBoss", L["Boss"])
    npcColorBoss:SetPoint("TOPLEFT", colorNPCNeutralNameCombatOnly, "BOTTOMLEFT", 0, -8)

    local npcColorMiniboss = CreateColorBox(colorNPC, "npcColorMiniboss", L["Miniboss"])
    npcColorMiniboss:SetPoint("TOPLEFT", npcColorBoss, "BOTTOMLEFT", 0, -2)

    local npcColorMinionCaster = CreateColorBox(colorNPC, "npcColorCaster", L["Casters"])
    npcColorMinionCaster:SetPoint("TOPLEFT", npcColorMiniboss, "BOTTOMLEFT", 0, -2)

    local npcColorMelee = CreateColorBox(colorNPC, "npcColorMelee", L["Melee"])
    npcColorMelee:SetPoint("TOPLEFT", npcColorMinionCaster, "BOTTOMLEFT", 0, -2)

    local npcColorTrivial = CreateColorBox(colorNPC, "npcColorTrivial", L["Trivial"])
    npcColorTrivial:SetPoint("TOPLEFT", npcColorMelee, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(npcColorTrivial, L["Trivial"], L["Tooltip_Trivial_Desc"])

    local npcColorRareElite = CreateColorBox(colorNPC, "npcColorRareElite", L["Rare_Rare_Elite"])
    npcColorRareElite:SetPoint("TOPLEFT", npcColorTrivial, "BOTTOMLEFT", 0, -2)

    local npcColorMinus = CreateColorBox(colorNPC, "npcColorMinus", L["Minus"])
    npcColorMinus:SetPoint("TOPLEFT", npcColorRareElite, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(npcColorMinus, L["Minus"], L["Tooltip_Minus_Desc"])

    colorNPC:HookScript("OnClick", function()
        local enabled = colorNPC:GetChecked()
        local a = enabled and 1 or 0.5
        npcColorBoss:SetAlpha(a)
        npcColorMiniboss:SetAlpha(a)
        npcColorMinionCaster:SetAlpha(a)
        npcColorMelee:SetAlpha(a)
        npcColorTrivial:SetAlpha(a)
        npcColorRareElite:SetAlpha(a)
        npcColorMinus:SetAlpha(a)
        CheckAndToggleCheckboxes(colorNPC)
    end)

    local reloadUiButton = CreateFrame("Button", nil, guiColorNpc, "UIPanelButtonTemplate")
    reloadUiButton:SetText(L["Reload_UI"])
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiColorNpc, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    CheckAndToggleCheckboxes(colorNPC)
end

local function guiAuraColor()
    -------------------
    -- Color NPC
    -------------------
    local guiAuraColor = CreateFrame("Frame")
    guiAuraColor.name = L["Color_By_Aura"]
    guiAuraColor.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiAuraColor)
    local guiAuraColorCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiAuraColor, guiAuraColor.name)
    CreateTitle(guiAuraColor)

    local bgImg = guiAuraColor:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiAuraColor, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiAuraColor)
    listFrame:SetAllPoints(guiAuraColor)

    local auraColorList = CreateList(listFrame, "auraColorList", BetterBlizzPlatesDB.auraColorList, BBP.RefreshAllNameplates, true, false, true, 440)
    auraColorList:SetPoint("TOPLEFT", -5, -10)

    local listExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listExplanationText:SetPoint("TOP", guiAuraColor, "BOTTOMLEFT", 180, 155)
    listExplanationText:SetText(L["Add_Name_Or_Spell_ID_Case_Insensitive_Type"])

    local prioText = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prioText:SetPoint("BOTTOM", auraColorList, "TOP", 76, 3)
    prioText:SetText(L["Priority_Value"])

    local auraColorExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    auraColorExplanationText:SetPoint("TOP", guiAuraColor, "TOP", 220, -127)
    auraColorExplanationText:SetText(L["Color_Nameplates_Depending_On_Their_Auras_Add_A"])

    local auraColor = CreateCheckbox("auraColor", L["Enable_Color_By_Aura"], guiAuraColor, nil, BBP.CreateUnitAuraEventFrame)
    auraColor:SetPoint("TOPLEFT", auraColorExplanationText, "BOTTOMLEFT", 10, -15)
    CreateTooltip(auraColor, L["Tooltip_Chose_Nameplate_Color_Depending_On_The"])

    local auraColorPvEOnly = CreateCheckbox("auraColorPvEOnly", L["Enable_In_PvE_Only"], auraColor)
    auraColorPvEOnly:SetPoint("TOPLEFT", auraColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(auraColorPvEOnly, L["Aura_Color_For_PvE_Only"], L["Tooltip_Aura_Color_For_PvE_Only_Desc"])

    local reloadUiButton = CreateFrame("Button", nil, guiAuraColor, "UIPanelButtonTemplate")
    reloadUiButton:SetText(L["Reload_UI"])
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiAuraColor, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.auraColor then
                listFrame:SetAlpha(1)
            else
                listFrame:SetAlpha(0.5)
            end
        else
            C_Timer.After(1, function()
                TogglePanel()
            end)
        end
    end
    auraColor:HookScript("OnClick", function ()
        TogglePanel()
        CheckAndToggleCheckboxes(auraColor)
    end)
    TogglePanel()
end

local function guiNameplateAuras()
    ----------------------
    -- Nameplate Auras
    ----------------------
    local guiNameplateAuras = CreateFrame("Frame")
    guiNameplateAuras.name = L["Nameplate_Auras"]
    guiNameplateAuras.parent = BetterBlizzPlates.name
    local guiNameplateAurasCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiNameplateAuras, guiNameplateAuras.name)
    CreateTitle(guiNameplateAuras)

    local bgImg = guiNameplateAuras:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiNameplateAuras, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local scrollFrame = CreateFrame("ScrollFrame", nil, guiNameplateAuras, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", guiNameplateAuras, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame.name = guiNameplateAuras.name
    scrollFrame:SetScrollChild(contentFrame)

    local function Refresh()
        BBP.RefreshAllNameplateAuras()
    end

    local enableAuras = CreateCheckbox("enableNameplateAuraCustomisation", L["Enable_Aura_Settings"], contentFrame)
    CreateTooltipTwo(enableAuras, L["Enable_Nameplate_Aura_Customization"], L["Tooltip_Enable_Nameplate_Aura_Customization_Desc"])

    local resetAuras = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetAuras:SetSize(70, 22)
    resetAuras:SetText(L["Default"])
    resetAuras:SetPoint("LEFT", enableAuras.Text, "RIGHT", 10, 0)
    CreateTooltipTwo(resetAuras, L["Default"], L["Tooltip_Default_Desc"],
        L["Tooltip_Default_SubText"])
    resetAuras:SetScript("OnClick", function()
        BBP.ShowPopup("BBP_RESET_NP_AURAS")
    end)

    local swatches, dropdowns, plainDropdowns = {}, {}, {}

    local function Swatch(colorVar, onChange)
        local swatch = CreateColorBox(contentFrame, colorVar, "", onChange)
        swatch:ClearAllPoints()
        table.insert(swatches, swatch)
        return swatch
    end

    local function UpdatePanelState()
        CheckAndToggleCheckboxes(enableAuras)
        local on = enableAuras:GetChecked()
        for _, swatch in ipairs(swatches) do
            local enabled = on
            if enabled and swatch.bbpRequires then
                for _, key in ipairs(swatch.bbpRequires) do
                    if not BetterBlizzPlatesDB[key] then
                        enabled = false
                        break
                    end
                end
            end
            swatch:SetAlpha(enabled and 1 or 0.5)
        end
        for _, dropdown in ipairs(dropdowns) do
            if dropdown.bbpShowWhen then
                local shown = BetterBlizzPlatesDB[dropdown.bbpShowWhen] and true or false
                dropdown:SetShown(shown)
                if dropdown.label then dropdown.label:SetShown(shown) end
            end
            if on and not (dropdown.bbpDisableWhen and BetterBlizzPlatesDB[dropdown.bbpDisableWhen]) then
                dropdown:Enable()
            else
                dropdown:Disable()
            end
        end
        for _, dropdown in ipairs(plainDropdowns) do
            if on and (not dropdown.bbpRequires or BetterBlizzPlatesDB[dropdown.bbpRequires]) then
                dropdown:Enable()
            else
                dropdown:Disable()
            end
        end
    end

    enableAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.SetupNameplateAuras()
        else
            BBP.DisableNameplateAuras()
        end
        UpdatePanelState()
        BBP.RefreshAllNameplates()
    end)

    local CHECK_STEP, SLIDER_STEP, HEADER_STEP, SECTION_GAP = 21, 32, 22, 16
    local COL_L, COL_M, COL_R = 50, 256, 462

    local function NewColumn(x, y, step)
        return { x = x, y = y, top = y, step = step }
    end

    local function Place(col, widget, indent, step, dy)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", col.x + (indent or 0), col.y + (dy or 0))
        col.y = col.y - step
        return widget
    end

    local function Header(col, text)
        local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
        fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", col.x, col.y)
        fs:SetText(text)
        col.y = col.y - HEADER_STEP
        return fs
    end

    local function GroupHeader(col, text, r, g, b, blend)
        local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", col.x + 12, col.y)
        fs:SetText(text)
        fs:SetFont(fontLarge, 16)
        fs:SetTextColor(1,1,1)

        local icon = contentFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAtlas("groupfinder-icon-friend")
        icon:SetSize(28, 28)
        icon:SetPoint("RIGHT", fs, "LEFT", -3, 0)
        if r then
            icon:SetDesaturated(1)
            icon:SetVertexColor(r, g, b)
            if blend then icon:SetBlendMode("ADD") end
        end

        col.y = col.y - HEADER_STEP
        return fs
    end

    local boxes = {}

    local function Check(col, key, label, parent, indent, title, desc, sub, anchor)
        local cb = CreateCheckbox(key, label, parent or enableAuras)
        Place(col, cb, (indent or 0) - 4, col.step or CHECK_STEP)
        if title then CreateTooltipTwo(cb, title, desc, sub, anchor) end
        cb:HookScript("OnClick", function()
            Refresh()
            CheckAndToggleCheckboxes(cb)
        end)
        boxes[key] = cb
        return cb
    end

    local function Beside(after, key, label, parent, title, desc, sub, anchor)
        local cb = CreateCheckbox(key, label, parent or enableAuras)
        cb:ClearAllPoints()
        cb:SetPoint("LEFT", after.Text, "RIGHT", 2, 0)
        if title then CreateTooltipTwo(cb, title, desc, sub, anchor) end
        cb:HookScript("OnClick", function()
            Refresh()
            CheckAndToggleCheckboxes(cb)
        end)
        boxes[key] = cb
        return cb
    end

    local testButtons = {}

    local function UpdateTestButtons()
        local on = BetterBlizzPlatesDB.nameplateAuraTestMode
        for _, btn in ipairs(testButtons) do
            btn:SetText(on and L["Stop_Test"] or L["Test_Auras"])
        end
    end

    local function TestButton(col, dy)
        local btn = CreateFrame("Button", nil, enableAuras, "UIPanelButtonTemplate")
        btn:SetSize(110, 28)
        Place(col, btn, -4, 34, dy)
        CreateTooltipTwo(btn, L["Test_Auras"],
            L["Tooltip_Test_Auras_Desc"])
        btn:SetScript("OnClick", function()
            BetterBlizzPlatesDB.nameplateAuraTestMode = not BetterBlizzPlatesDB.nameplateAuraTestMode
            UpdateTestButtons()
            Refresh()
        end)
        table.insert(testButtons, btn)
        return btn
    end

    local function Slider(col, label, minV, maxV, step, key, indent, title, desc, parent, dy)
        local s = CreateSlider(parent or enableAuras, label, minV, maxV, step, key, nil, 144)
        Place(col, s, (indent or 0) + 3, SLIDER_STEP, -6 + (dy or 0))
        if title then CreateTooltipTwo(s, title, desc) end
        return s
    end

    local LIST_TOP, LIST_H = -15, 270

    local auraBlacklistFrame = CreateFrame("Frame", nil, contentFrame)
    auraBlacklistFrame:SetSize(322, LIST_H + 20)
    auraBlacklistFrame:SetPoint("TOPLEFT", 6, LIST_TOP)
    CreateList(auraBlacklistFrame, "auraBlacklist", BetterBlizzPlatesDB.auraBlacklist, Refresh, nil, nil, nil, 265, LIST_H)

    local blacklistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistText:SetPoint("BOTTOM", auraBlacklistFrame, "TOP", 10, -4)
    blacklistText:SetText(L["Blacklist"])
    blacklistText:SetFont(fontLarge, 16)
    blacklistText:SetTextColor(1,1,1)

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, LIST_H + 20)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, LIST_TOP)
    local whitelist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzPlatesDB.auraWhitelist, Refresh, nil, true, nil, 379, LIST_H, nil, true)
    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -60, -4)
    whitelistText:SetText(L["Whitelist"])
    whitelistText:SetFont(fontLarge, 16)
    whitelistText:SetTextColor(1,1,1)


    local pandemicIcon = CreateFrame("Frame", nil, contentFrame)
    pandemicIcon:SetSize(26, 26)
    pandemicIcon:SetPoint("CENTER", whitelist, "TOPRIGHT", -30, 11)
    pandemicIcon:EnableMouse(true)
    pandemicIcon.texture = pandemicIcon:CreateTexture(nil, "OVERLAY")
    pandemicIcon.texture:SetAllPoints()
    pandemicIcon.texture:SetAtlas("elementalstorm-boss-air")
    pandemicIcon.texture:SetDesaturated(true)
    TintFromColor(pandemicIcon.texture, "nameplateAuraPandemicGlowRGB", 1, 0, 0)
    CreateTooltipTwo(pandemicIcon, L["Pandemic_Glow"],
        L["Tooltip_Pandemic_Glow_Desc_2"],
        L["Tooltip_Pandemic_Glow_SubText"])

    local importantIcon = CreateFrame("Frame", nil, contentFrame)
    importantIcon:SetSize(16, 16)
    importantIcon:SetPoint("CENTER", pandemicIcon, "CENTER", -25, -2)
    importantIcon:EnableMouse(true)
    importantIcon.texture = importantIcon:CreateTexture(nil, "OVERLAY")
    importantIcon.texture:SetAllPoints()
    importantIcon.texture:SetAtlas("importantavailablequesticon")
    importantIcon.texture:SetDesaturated(true)
    TintFromColor(importantIcon.texture, "nameplateAuraImportantGlowRGB", 0, 1, 0)
    CreateTooltipTwo(importantIcon, L["Important_Glow"],
        L["Tooltip_Important_Glow_Desc_2"],
        L["Tooltip_Important_Glow_SubText"])

    local enlargedIcon = CreateFrame("Frame", nil, contentFrame)
    enlargedIcon:SetSize(18, 18)
    enlargedIcon:SetPoint("CENTER", importantIcon, "CENTER", -23, -1)
    enlargedIcon:EnableMouse(true)
    enlargedIcon.texture = enlargedIcon:CreateTexture(nil, "OVERLAY")
    enlargedIcon.texture:SetAllPoints()
    enlargedIcon.texture:SetAtlas("ui-hud-minimap-zoom-in")
    CreateTooltipTwo(enlargedIcon, L["Enlarged_Aura_Icon"],
        L["Tooltip_Enlarged_Aura_Icon_Desc_2"],
        L["Tooltip_Enlarged_Aura_Icon_SubText_2"])

    local onlyMeIcon = CreateFrame("Frame", nil, contentFrame)
    onlyMeIcon:SetSize(18, 20)
    onlyMeIcon:SetPoint("CENTER", enlargedIcon, "CENTER", -24, 1)
    onlyMeIcon:EnableMouse(true)
    onlyMeIcon.texture = onlyMeIcon:CreateTexture(nil, "OVERLAY")
    onlyMeIcon.texture:SetAllPoints()
    onlyMeIcon.texture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    CreateTooltipTwo(onlyMeIcon, L["Only_My_Aura_Icon"], L["Tooltip_Only_My_Aura_Icon_Desc_2"])

    local COL_ENEMY, COL_FRIENDLY, COL_PERSONAL = 50, 300, 525
    local listBottom = LIST_TOP - LIST_H - 38

    local filterCaveat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    filterCaveat:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", COL_ENEMY - 4, listBottom)
    filterCaveat:SetWidth(620)
    filterCaveat:SetJustifyH("LEFT")
    filterCaveat:SetText(L["Aura_SpellID_Filter_Caveat"])

    local masterY = listBottom - 34
    enableAuras:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", COL_ENEMY - 4, masterY)

    local FILTER_STEP = 19
    local enemy    = NewColumn(COL_ENEMY, masterY - 26, FILTER_STEP)
    local friendly = NewColumn(COL_FRIENDLY, masterY - 6, FILTER_STEP)
    local personal = NewColumn(COL_PERSONAL, masterY - 6, FILTER_STEP)

    GroupHeader(enemy, L["Enemy_Nameplates"], 1, 0, 0)
    GroupHeader(friendly, L["Friendly_Nameplates"])

    local FILTER_GROUPS = {
        { col = enemy,    prefix = "otherNpBuff",      title = L["Enemy_Buffs"],      helpful = true,  byName = false },
        { col = enemy,    prefix = "otherNpdeBuff",    title = L["Enemy_Debuffs"],    helpful = false, byName = true, mine = true },
        { col = friendly, prefix = "friendlyNpBuff",   title = L["Friendly_Buffs"],   helpful = true,  byName = true, mine = true },
        { col = friendly, prefix = "friendlyNpdeBuff", title = L["Friendly_Debuffs"], helpful = false, byName = false, dispel = true },
    }

    for _, spec in ipairs(FILTER_GROUPS) do
        local col = spec.col
        local helpful = spec.helpful

        local enable = Check(col, spec.prefix .. "Enable",
            helpful and L["Show_Buffs"] or L["Show_DEBUFFS"], nil, 0,
            spec.title, helpful and L["Tooltip_Show_All_Buffs"] or L["Tooltip_Show_All_Debuffs"],
            helpful and L["Tooltip_Aura_Filter_Stack_Buffs"] or L["Tooltip_Aura_Filter_Stack_Debuffs"])

        local function Sub(key, label, title, desc, sub)
            return Check(col, spec.prefix .. key, label, enable, 15, title, desc, sub)
        end

        local blackList = spec.byName and Sub("FilterBlacklist", L["Blacklist"], L["Blacklist"],
            helpful and L["Tooltip_Hide_Blacklisted_Buffs"] or L["Tooltip_Hide_Blacklisted_Debuffs"])
        local watchList = spec.byName and Sub("FilterWatchList", L["Whitelist"], L["Whitelist"],
            helpful and L["Tooltip_Only_Whitelisted_Buffs"] or L["Tooltip_Only_Whitelisted_Debuffs"])

        if spec.helpful then
            Sub("FilterDefensives", L["Defensive_Auras"], L["Defensive_Auras"],
                L["Tooltip_Defensive_Auras_Desc"],
                L["Tooltip_Defensive_Auras_SubText"])
            Sub("FilterImportantBuffs", L["Important"], L["Important_Buffs"],
                L["Tooltip_Important_Buffs_Desc"],
                L["Tooltip_Defensive_Auras_SubText"])
            local purgeable = Sub("FilterPurgeable", L["Purgeable"], L["Purgeable_Buffs"],
                L["Tooltip_Purgeable_Buffs_Desc"])
            Beside(purgeable, spec.prefix .. "FilterPurgeableAny", L["Always_Show"], purgeable,
                L["Always_Show"],
                L["Tooltip_Always_Show_Desc"])
        else
            local ccTitle, ccDesc, ccSub = L["Crowd_Control"],
                L["Tooltip_Only_CC_Desc"],
                L["Tooltip_Only_CC_SubText"]
            local ccAnchor = watchList or blackList
            if ccAnchor then
                Beside(ccAnchor, spec.prefix .. "FilterCC", L["Crowd_Control"], enable,
                    ccTitle, ccDesc, ccSub)
            else
                Sub("FilterCC", L["Crowd_Control"], ccTitle, ccDesc, ccSub)
            end
            if spec.dispel then
                local dispellable = Sub("FilterPurgeable", L["Dispellable"], L["Dispellable_Debuffs"],
                    L["Tooltip_Aura_Dispellable"])
                Beside(dispellable, spec.prefix .. "FilterPurgeableAny", L["Always_Show"], dispellable,
                    L["Always_Show"],
                    L["Tooltip_Always_Show_Desc_2"])
            end
            Sub("FilterBlizzard", L["Blizzard_Default_Filter"], L["Blizzard_Default_Filter"],
                L["Tooltip_Blizzard_Default_Filter_Desc"])
        end

        Sub("FilterLessMinite", L["Under_One_Min"], L["Under_One_Min"],
            helpful and L["Tooltip_Under_One_Min_Buffs"] or L["Tooltip_Under_One_Min_Debuffs"])

        if spec.mine then
            Sub("FilterOnlyMe", L["Only_Mine"],
                helpful and L["Only_My_Buffs"] or L["Only_My_Debuffs"],
                helpful and L["Tooltip_Only_My_Buffs"] or L["Tooltip_Only_My_Debuffs"])
        end

        col.y = col.y - 2
    end

    local playerClass = UnitClassBase("player")
    local classColor = RAID_CLASS_COLORS[playerClass]
    GroupHeader(personal, L["Personal_Bar"],
        classColor and classColor.r or 1, classColor and classColor.g or 0.5,
        classColor and classColor.b or 0, true)

    local prdAuras = Check(personal, "prdAurasEnabled", L["Show_Buffs"], nil, 0,
        L["Auras_On_Personal_Resource_Display"],
        L["Tooltip_Auras_On_Personal_Resource_Display_Desc"],
        L["Tooltip_Aura_Filter_Stack_Buffs"], "ANCHOR_LEFT")
    prdAuras:HookScript("OnClick", function()
        BBP.SetupPRDAuras()
        UpdatePanelState()
    end)

    for _, filter in ipairs({
        { "Blacklist", L["Blacklist"], L["Blacklist"], L["Tooltip_Hide_Blacklisted_Buffs"] },
        { "WatchList", L["Whitelist"], L["Whitelist"], L["Tooltip_Only_Whitelisted_Buffs"] },
        { "Defensives", L["Defensive_Auras"], L["Defensive_Auras"], L["Tooltip_Defensive_Auras_Desc"] },
        { "ImportantBuffs", L["Important"], L["Important_Buffs"], L["Tooltip_Important_Buffs_Desc"] },
        { "LessMinite", L["Under_One_Min"], L["Under_One_Min"], L["Tooltip_Under_One_Min_Buffs"] },
        { "OnlyMe", L["Only_Mine"], L["Only_My_Buffs"], L["Tooltip_Only_My_Buffs"] },
    }) do
        Check(personal, "prdBuffFilter" .. filter[1], filter[2], prdAuras, 15,
            filter[3], filter[4], nil, "ANCHOR_LEFT")
    end

    TestButton(personal, -8)

    local left, mid, right

    local function StartRow(top)
        left, mid, right = NewColumn(COL_L, top), NewColumn(COL_M, top), NewColumn(COL_R, top)
    end

    local function RowBottom()
        return math.min(left.y, mid.y, right.y)
    end

    StartRow(math.min(enemy.y, friendly.y, personal.y) - SECTION_GAP)
    mid.x = mid.x + 10
    right.x = right.x + 12

    Header(left, L["Big_CC_Icon"])
    Check(left, "nameplateAuraCCOnEnemyPlayers", L["Show_On_Enemy_Players"], nil, 0,
        L["Crowd_Control_On_Enemy_Players"],
        L["Tooltip_Crowd_Control_On_Enemy_Players_Desc"],
        L["Tooltip_Crowd_Control_On_Enemy_Players_SubText"])
    Check(left, "nameplateAuraCCOnFriendlyPlayers", L["Show_On_Friendly_Players"], nil, 0,
        L["Crowd_Control_On_Friendly_Players"],
        L["Tooltip_Crowd_Control_On_Friendly_Players_Desc"],
        L["Tooltip_Crowd_Control_On_Friendly_Players_SubText"])
    Check(left, "nameplateAuraCCOnNpcs", L["Show_On_NPCs"], nil, 0,
        L["Crowd_Control_On_NPCs"],
        L["Tooltip_Crowd_Control_On_NPCs_Desc"],
        L["Tooltip_Crowd_Control_On_NPCs_SubText"])
    local ccBlizzardPvE = Check(left, "nameplateAuraCCBlizzardInPvE", L["Blizzards_In_PvE_Friendly"], nil, 0,
        L["Show_Blizzards_In_PvE_Friendly_Only"],
        L["Tooltip_Show_Blizzards_In_PvE_Friendly_Only_Desc"])
    ccBlizzardPvE:HookScript("OnClick", function()
        BBP.RefreshBlizzardAuraCVarOverrides()
    end)
    local ccIconScale = Slider(left, L["CC_Icon_Scale"], 0.4, 3, 0.01, "ccIconScale", -2, nil, nil, nil, -5)
    local ccIconXPos = Slider(left, L["CC_Icon_X"], -100, 100, 1, "ccIconXPos", -2, nil, nil, nil, -5)
    local ccIconYPos = Slider(left, L["CC_Icon_Y"], -100, 100, 1, "ccIconYPos", -2, nil, nil, nil, -5)
    local ccIconAnchor = CreateAnchorDropdown("ccIconAnchor", contentFrame, "RIGHT", "ccIconAnchor",
        Refresh, { label = L["CC_Icon_Anchor"], anchorFrame = ccIconYPos, x = -22, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(ccIconAnchor, L["CC_Icon_Anchor"], L["Tooltip_CC_Icon_Anchor_Desc"])
    ccIconAnchor.bbpDisableWhen = "combineBigAuraIcons"
    table.insert(dropdowns, ccIconAnchor)
    left.y = left.y - 60

    local combineBigIcons = Check(left, "combineBigAuraIcons", L["Combine_Big_CC_And_Buffs"], nil, 0,
        L["Combine_Big_CC_And_Big_Buffs_Icons"],
        L["Tooltip_Combine_Big_CC_And_Big_Buffs_Icons_Desc"],
        L["Tooltip_Combine_Big_CC_And_Big_Buffs_Icons_SubText"])
    combineBigIcons:HookScript("OnClick", function()
        UpdatePanelState()
    end)
    local combinedAnchor = CreateAnchorDropdown("combinedBigIconAnchor", contentFrame, "RIGHT",
        "combinedBigIconAnchor", Refresh,
        { label = L["Combined_Anchor"], anchorFrame = combineBigIcons, x = -17, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(combinedAnchor, L["Combined_Anchor"],
        L["Tooltip_Combined_Anchor_Desc"])
    combinedAnchor.bbpShowWhen = "combineBigAuraIcons"
    table.insert(dropdowns, combinedAnchor)
    left.y = left.y - 60

    Header(mid, L["Big_Buff_Icon"])
    Check(mid, "nameplateAuraBuffsOnEnemyPlayers", L["Show_On_Enemy_Players"], nil, 0,
        L["Buffs_On_Enemy_Players"],
        L["Tooltip_Buffs_On_Enemy_Players_Desc"],
        L["Tooltip_Buffs_On_Enemy_Players_SubText"])
    Check(mid, "nameplateAuraBuffsOnFriendlyPlayers", L["Show_On_Friendly_Players"], nil, 0,
        L["Buffs_On_Friendly_Players"],
        L["Tooltip_Buffs_On_Friendly_Players_Desc"],
        L["Tooltip_Buffs_On_Friendly_Players_SubText"])
    Check(mid, "nameplateAuraBuffsOnNpcs", L["Show_On_NPCs"], nil, 0,
        L["Buffs_On_NPCs"],
        L["Tooltip_Buffs_On_NPCs_Desc"],
        L["Tooltip_Buffs_On_NPCs_SubText"])
    local buffsBlizzardPvE = Check(mid, "nameplateAuraBuffsBlizzardInPvE", L["Blizzards_In_PvE_Friendly"], nil, 0,
        L["Show_Blizzards_In_PvE_Friendly_Only"],
        L["Tooltip_Show_Blizzards_In_PvE_Friendly_Only_Desc_2"])
    buffsBlizzardPvE:HookScript("OnClick", function()
        BBP.RefreshBlizzardAuraCVarOverrides()
    end)
    local buffIconScale = Slider(mid, L["Buff_Icon_Scale"], 0.4, 3, 0.01, "buffIconScale", -2, nil, nil, nil, -5)
    local buffIconXPos = Slider(mid, L["Buff_Icon_X"], -100, 100, 1, "buffIconXPos", -2, nil, nil, nil, -5)
    local buffIconYPos = Slider(mid, L["Buff_Icon_Y"], -100, 100, 1, "buffIconYPos", -2, nil, nil, nil, -5)
    local buffIconAnchor = CreateAnchorDropdown("buffIconAnchor", contentFrame, "LEFT", "buffIconAnchor",
        Refresh, { label = L["Buff_Icon_Anchor"], anchorFrame = buffIconYPos, x = -22, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(buffIconAnchor, L["Buff_Icon_Anchor"], L["Tooltip_Buff_Icon_Anchor_Desc"])
    buffIconAnchor.bbpDisableWhen = "combineBigAuraIcons"
    table.insert(dropdowns, buffIconAnchor)
    mid.y = mid.y - 60

    local moveNormalBuffs = Check(mid, "moveNormalBuffs", L["Move_Normal_Buffs"], nil, 0,
        L["Move_Normal_Buffs"],
        L["Tooltip_Move_Normal_Buffs_Desc"],
        L["Tooltip_Move_Normal_Buffs_SubText"])
    moveNormalBuffs:HookScript("OnClick", function()
        UpdatePanelState()
    end)
    local buffRowAnchor = CreateAnchorDropdown("moveNormalBuffsAnchor", contentFrame, "LEFT",
        "moveNormalBuffsAnchor", Refresh,
        { label = L["Normal_Buffs_Anchor"], anchorFrame = moveNormalBuffs, x = -17, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(buffRowAnchor, L["Normal_Buffs_Anchor"],
        L["Tooltip_Normal_Buffs_Anchor_Desc"])
    buffRowAnchor.bbpShowWhen = "moveNormalBuffs"
    table.insert(dropdowns, buffRowAnchor)
    mid.y = mid.y - 60

    Header(right, L["Aura_Glows"])

    local TIERS = {
        { key = "nameplateAuraDefensiveGlow", label = L["Defensive_Auras"], color = "nameplateAuraDefensiveGlowRGB",
          title = L["Defensive_Auras"], desc = L["Tooltip_Glow_On_Defensive_Buffs_Desc"] },
        { key = "nameplateAuraImportantGlow", label = L["Important"], color = "nameplateAuraImportantGlowRGB",
          title = L["Important"], desc = L["Tooltip_Glow_On_Important_Auras_Desc"] },
        { key = "nameplateAuraCCGlow", label = L["Crowd_Control"], color = "nameplateAuraCCGlowRGB",
          title = L["Crowd_Control"], desc = L["Tooltip_Glow_On_Crowd_Control_Desc"] },
    }
    local ccGlow, ccGlowSwatch
    for _, tier in ipairs(TIERS) do
        local cb = Check(right, tier.key, tier.label, nil, 0, tier.title, tier.desc, tier.sub)
        local swatch = Swatch(tier.color, Refresh)
        swatch:SetPoint("LEFT", cb.Text, "RIGHT", 4, 0)
        if tier.key == "nameplateAuraCCGlow" then
            ccGlow, ccGlowSwatch = cb, swatch
        end
    end

    local ccDispelColor = Beside(ccGlow, "nameplateAuraCCGlowDispelColor", L["Dispel_Color"], ccGlow,
        L["Dispel_Color"], L["Tooltip_Dispel_Color_Desc"],
        L["Tooltip_Dispel_Color_SubText"])
    ccDispelColor:ClearAllPoints()
    ccDispelColor:SetPoint("LEFT", ccGlowSwatch, "RIGHT", -25, 0)

    local purgeGlow = Check(right, "otherNpBuffPurgeGlow", L["Purgeable"], nil, 0,
        L["Glow_On_Purgeable"],
        L["Tooltip_Glow_On_Purgeable_Desc"])
    local purgeAlways = Beside(purgeGlow, "alwaysShowPurgeTexture", L["Always"], purgeGlow,
        L["Always"], L["Tooltip_Always_Desc"])

    local purgeColorToggle = Beside(purgeAlways, "npAuraPurgeGlowColorEnabled", "", purgeGlow,
        L["Change_Purge_Glow_Color"],
        L["Tooltip_Change_Purge_Glow_Color_Desc"])
    local purgeColorSwatch = Swatch("npAuraPurgeGlowRGB", Refresh)
    purgeColorSwatch:SetPoint("LEFT", purgeColorToggle, "RIGHT", -2, 0)
    purgeColorSwatch.bbpRequires = { "otherNpBuffPurgeGlow", "npAuraPurgeGlowColorEnabled" }
    purgeColorSwatch:EnableMouse(true)
    CreateTooltipTwo(purgeColorSwatch, L["Change_Purge_Glow_Color"],
        L["Tooltip_Change_Purge_Glow_Color_Desc"])
    purgeColorToggle:HookScript("OnClick", function()
        UpdatePanelState()
    end)
    purgeGlow:HookScript("OnClick", function()
        UpdatePanelState()
    end)

    local pandemic = Check(right, "otherNpdeBuffPandemicGlow", L["Pandemic"], nil, 0,
        L["Pandemic_Glow"],
        L["Tooltip_Pandemic_Glow_Desc_3"],
        L["Tooltip_Pandemic_Glow_SubText_2"])
    local pandemicSwatch = Swatch("nameplateAuraPandemicGlowRGB", Refresh)
    pandemicSwatch:SetPoint("LEFT", pandemic.Text, "RIGHT", 4, 0)
    pandemic:HookScript("OnClick", function()
        if BBP.RefreshAuraWhitelistDisplay then BBP.RefreshAuraWhitelistDisplay() end
    end)

    StartRow(RowBottom() - SECTION_GAP)
    mid.x = mid.x + 10
    right.x = right.x + 12

    Header(left, L["Size_And_Position"])
    Slider(left, L["Aura_Scale"], 0.3, 3, 0.01, "bbpAuraScale", 0, L["Aura_Scale"],
        L["Tooltip_Aura_Scale_Desc"])
    Slider(left, L["Debuff_Scale"], 0.3, 3, 0.01, "nameplateAuraDebuffScale", 0, L["Debuff_Scale"],
        L["Tooltip_Debuff_Scale_Desc"])
    Slider(left, L["Buff_Scale"], 0.3, 3, 0.01, "nameplateAuraBuffScale", 0, L["Buff_Scale"],
        L["Tooltip_Buff_Scale_Desc"])
    Slider(left, L["Enlarged_Aura_Scale"], 1, 2, 0.01, "nameplateAuraEnlargedScale", 0, L["Enlarged_Aura_Scale"],
        L["Tooltip_Enlarged_Aura_Scale_Desc"])
    local AURA_POS_NOTE = L["Tooltip_This_Only_Affects_The_Normal_Debuffs"]
    local auraPosX = Slider(left, L["Auras_Horizontal_Position"], -300, 300, 0.5, "nameplateDebuffXPadding", 0)
    CreateTooltipTwo(auraPosX, L["Auras_Horizontal_Position"],
        L["Tooltip_Auras_Horizontal_Position_Desc"], AURA_POS_NOTE)
    local bbpDebuffPadding = Slider(left, L["Auras_Vertical_Position"], -100, 100, 1, "bbpDebuffPadding", 0)
    CreateTooltipTwo(bbpDebuffPadding, L["Auras_Vertical_Position"],
        L["Tooltip_Auras_Vertical_Position_Desc"], AURA_POS_NOTE)
    Slider(left, L["Horizontal_Gap"], 0, 20, 0.5, "nameplateAuraWidthGap")
    Slider(left, L["Vertical_Gap"], 0, 20, 0.5, "nameplateAuraHeightGap")
    Slider(left, L["Auras_Per_Row_Enemy"], 1, 16, 1, "nameplateAuraRowAmount")
    Slider(left, L["Auras_Per_Row_Friendly"], 1, 16, 1, "nameplateAuraRowFriendlyAmount")
    local sortDuration, sortDurationReverse
    sortDuration = Check(left, "sortDurationAuras", L["Sort_By_Duration"], nil, 0,
        L["Sort_By_Duration"], L["Tooltip_Sort_By_Duration_Desc"])
    sortDurationReverse = Check(left, "sortDurationAurasReverse", L["Reverse_Duration_Sort"], nil, 0,
        L["Reverse_Duration_Sort"], L["Tooltip_Reverse_Duration_Sort_Desc"])

    local function ExclusiveSort(checked, other, otherKey)
        if not checked:GetChecked() then return end
        other:SetChecked(false)
        BetterBlizzPlatesDB[otherKey] = false
        Refresh()
    end
    sortDuration:HookScript("OnClick", function(self)
        ExclusiveSort(self, sortDurationReverse, "sortDurationAurasReverse")
    end)
    sortDurationReverse:HookScript("OnClick", function(self)
        ExclusiveSort(self, sortDuration, "sortDurationAuras")
    end)
    Check(left, "sortEnlargedAurasFirst", L["Sort_Enlarged_First"], nil, 0,
        L["Sort_Enlarged_First"],
        L["Tooltip_Sort_Enlarged_First_Desc"])

    Header(mid, L["Style"])
    local squareAuras, tallerAuras
    squareAuras = Check(mid, "nameplateAuraSquare", L["Square_Auras"])
    tallerAuras = Check(mid, "nameplateAuraTaller", L["Taller_Auras"], nil, 0, L["Taller_Auras"],
        L["Tooltip_Taller_Auras_Desc"])
    squareAuras:HookScript("OnClick", function(self)
        ExclusiveSort(self, tallerAuras, "nameplateAuraTaller")
    end)
    tallerAuras:HookScript("OnClick", function(self)
        ExclusiveSort(self, squareAuras, "nameplateAuraSquare")
    end)
    Check(mid, "nameplateAuraPixelBorder", L["Pixel_Border"], nil, 0, L["Pixel_Border_Auras"],
        L["Tooltip_Pixel_Border_Auras_Desc"])
    Check(mid, "npColorAuraBorder", L["Color_Border_By_Type"], nil, 0, L["Color_Border_By_Dispel_Type"],
        L["Tooltip_Color_Border_By_Dispel_Type_Desc"])
    Check(mid, "nameplateAuraRightToLeft", L["Grow_Auras_Right_To_Left"], nil, 0, L["Grow_Auras_Right_To_Left"],
        L["Tooltip_Grow_Auras_Right_To_Left_Desc"])
    Check(mid, "nameplateAuraGrowDownwards", L["Grow_Auras_Top_To_Bottom"], nil, 0,
        L["Grow_Auras_Top_To_Bottom"],
        L["Tooltip_Grow_Auras_Top_To_Bottom_Desc"])
    Check(mid, "nameplateAuraCenterAlign", L["Center_Align_Auras"], nil, 0,
        L["Center_Align_Auras"],
        L["Tooltip_Center_Align_Auras_Desc"])
    Check(mid, "otherNpBuffBlueBorder", L["Blue_Border_For_Buffs"], nil, 0, L["Blue_Border_For_Buffs"],
        L["Tooltip_Blue_Border_For_Buffs_Desc"])
    Check(mid, "nameplateAurasEnemyCenteredDebuffs", L["Center_Debuffs_On_Enemies"], nil, 0,
        L["Center_Debuffs_On_Enemies"],
        L["Tooltip_Center_Debuffs_On_Enemies_Desc"])
    Check(mid, "nameplateAurasEnemyCenteredBuffs", L["Center_Buffs_On_Enemies"], nil, 0,
        L["Center_Buffs_On_Enemies"], L["Tooltip_Center_Buffs_On_Enemies_Desc"])
    Check(mid, "nameplateAurasFriendlyCenteredDebuffs", L["Center_Debuffs_On_Friendlies"], nil, 0,
        L["Center_Debuffs_On_Friendlies"], L["Tooltip_Center_Debuffs_On_Friendlies_Desc"])
    Check(mid, "nameplateAurasFriendlyCenteredBuffs", L["Center_Buffs_On_Friendlies"], nil, 0,
        L["Center_Buffs_On_Friendlies"], L["Tooltip_Center_Buffs_On_Friendlies_Desc"])
    Check(mid, "nameplateAuraEnlargedSquare", L["Square_Enlarged"], nil, 0, L["Square_Enlarged_Auras"],
        L["Tooltip_Square_Enlarged_Auras_Desc"])
    Check(mid, "enlargeAllCC", L["Enlarge_All_CC"], nil, 0, L["Enlarge_All_Crowd_Control"],
        L["Tooltip_Enlarge_All_Crowd_Control_Desc"],
        L["Tooltip_Enlarge_All_Crowd_Control_SubText"])
    Check(mid, "enlargeAllImportantBuffs", L["Enlarge_All_Important"], nil, 0,
        L["Enlarge_All_Important_Buffs"],
        L["Tooltip_Enlarge_All_Important_Buffs_Desc"],
        L["Tooltip_Enlarge_All_Important_Buffs_SubText"])

    mid.y = mid.y - SECTION_GAP

    Header(mid, L["Visibility"])
    local playersOnly = Check(mid, "nameplateAuraPlayersOnly", L["Players_Only"], nil, 0,
        L["Players_Only"], L["Tooltip_Players_Only_2_Desc"])
    Beside(playersOnly, "nameplateAuraPlayersOnlyShowTarget", L["Show_Target"], playersOnly,
        L["Show_Target"], L["Tooltip_Show_Target_Desc"])
    Check(mid, "hideNameplateAuraTooltip", L["Hide_Tooltips"], nil, 0,
        L["Hide_Tooltips"], L["Tooltip_Hide_Tooltips_Desc"])
    local auraTooltipSpellID = Check(mid, "auraTooltipSpellID", L["Aura_Tooltip_Spell_ID"], nil, 0,
        L["Aura_Tooltip_Spell_ID"], L["Tooltip_Aura_Tooltip_Spell_ID_Desc"])
    auraTooltipSpellID:HookScript("OnClick", function(self)
        BBP.ApplyAuraTooltipSpellID(not self:GetChecked())
    end)

    local limitsHeader = Header(right, L["Limits"])

    local limitsNote = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    limitsNote:SetPoint("BOTTOMLEFT", limitsHeader, "TOPLEFT", 0, 3)
    limitsNote:SetJustifyH("LEFT")
    limitsNote:SetText(L["Proper_Limits_Wont_Come_Until_12_1_5"])

    local ROUGH_LIMIT_NOTE = L["Tooltip_A_Rough_Cap_Not_An_Exact"]
    local maxDebuffs = Slider(right, L["Max_Debuffs"], 1, 24, 1, "maxAurasOnNameplate", 0)
    CreateTooltipTwo(maxDebuffs, L["Max_Debuffs"],
        L["Tooltip_Max_Debuffs_Desc"], ROUGH_LIMIT_NOTE)
    local maxBuffs = Slider(right, L["Max_Buffs"], 1, 24, 1, "maxBuffsOnNameplate", 0)
    CreateTooltipTwo(maxBuffs, L["Max_Buffs"],
        L["Tooltip_Max_Buffs_Desc"], ROUGH_LIMIT_NOTE)
    Slider(right, L["Max_Buffs_On_Side"], 1, 12, 1, "nameplateAuraBuffLimit", 0,
        L["Max_Buffs_On_Side"],
        L["Tooltip_Max_Buffs_On_Side_Desc"])
    local maxCC = Slider(right, L["Max_Crowd_Control"], 1, 6, 1, "ccIconLimit")
    CreateTooltipTwo(maxCC, L["Max_Crowd_Control"],
        L["Tooltip_Max_Crowd_Control_Desc"], ROUGH_LIMIT_NOTE)

    StartRow(RowBottom() - SECTION_GAP)
    mid.x = mid.x + 10

    Header(left, L["Cooldown_Text"])
    local showCd = Check(left, "showDefaultCooldownNumbersOnNpAuras", L["Show_Cooldown_Text"], nil, 0,
        L["Show_Cooldown_Text"], L["Tooltip_Show_Cooldown_Text_Desc"])
    Check(left, "hideNpAuraSwipe", L["Hide_Swipe"], showCd, 14, L["Hide_Swipe"],
        L["Tooltip_Hide_Swipe_Desc"])
    Check(left, "nameplateAuraHideLongDurationText", L["Hide_Over_A_Minute"], showCd, 14,
        L["Hide_Text_Over_A_Minute"],
        L["Tooltip_Hide_Text_Over_A_Minute_Desc"])
    Check(left, "nameplateAuraUseBlizzardCdText", L["Use_Blizzard_Numbers"], showCd, 14,
        L["Use_Blizzard_Cooldown_Numbers"],
        L["Tooltip_Use_Blizzard_Cooldown_Numbers_Desc"])
    Check(left, "nameplateAuraMillisecondsBuffs", L["Milliseconds_On_Buffs"], showCd, 14,
        L["Milliseconds_On_Buffs"],
        L["Tooltip_Milliseconds_On_Buffs_Desc"])
    Check(left, "nameplateAuraMillisecondsCC", L["Milliseconds_On_CC"], showCd, 14,
        L["Milliseconds_On_Crowd_Control"],
        L["Tooltip_Milliseconds_On_Crowd_Control_Desc"])
    Check(left, "npAuraCdTextBigOnly", L["Only_On_Big_Icons"], showCd, 14,
        L["Only_On_Big_Icons"],
        L["Tooltip_Only_On_Big_Icons_Desc"])
    local timerColor = Check(left, "nameplateAuraTimerColor", L["Color_Timer_Text"], showCd, 14, L["Color_Timer_Text"],
        L["Tooltip_Color_Timer_Text_Desc"])
    timerColor:HookScript("OnClick", Refresh)

    local timerColorOptionsFrame
    local function OpenTimerColorOptionsWindow()
        if not timerColorOptionsFrame then
            timerColorOptionsFrame = CreateFrame("Frame", "BBPAuraTimerColorOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            timerColorOptionsFrame:SetSize(200, 240)
            timerColorOptionsFrame:SetPoint("CENTER")
            timerColorOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            timerColorOptionsFrame:SetFrameLevel(550)
            timerColorOptionsFrame:SetIgnoreParentAlpha(true)
            timerColorOptionsFrame:SetTitle(L["Timer_Text_Colors"])
            timerColorOptionsFrame:EnableMouse(true)
            timerColorOptionsFrame:SetMovable(true)
            timerColorOptionsFrame:SetClampedToScreen(true)
            timerColorOptionsFrame:RegisterForDrag("LeftButton")
            timerColorOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            timerColorOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            timerColorOptionsFrame.closeButton = CreateFrame("Button", nil, timerColorOptionsFrame, "UIPanelCloseButton")
            timerColorOptionsFrame.closeButton:SetFrameLevel((timerColorOptionsFrame.TitleContainer or timerColorOptionsFrame):GetFrameLevel() + 10)
            timerColorOptionsFrame.closeButton:SetPoint("TOPRIGHT", timerColorOptionsFrame, "TOPRIGHT", 0, 0)
            timerColorOptionsFrame.closeButton:SetScript("OnClick", function()
                timerColorOptionsFrame:Hide()
            end)

            timerColorOptionsFrame.bg = timerColorOptionsFrame:CreateTexture(nil, "BACKGROUND")
            timerColorOptionsFrame.bg:SetPoint("TOPLEFT", timerColorOptionsFrame, "TOPLEFT", 7, -3)
            timerColorOptionsFrame.bg:SetPoint("BOTTOMRIGHT", timerColorOptionsFrame, "BOTTOMRIGHT", -3, 3)
            timerColorOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local lowThreshold = CreateSlider(timerColorOptionsFrame, L["Low_Threshold_Sec"], 1, 30, 1,
                "nameplateAuraTimerLowThreshold", nil, 150)
            lowThreshold:SetPoint("TOP", timerColorOptionsFrame, "TOP", 0, -45)
            lowThreshold.integerOnly = true
            CreateTooltipTwo(lowThreshold, L["Low_Threshold"],
                L["Tooltip_Timer_Low_Threshold"])

            local highThreshold = CreateSlider(timerColorOptionsFrame, L["Normal_Threshold_Sec"], 10, 120, 1,
                "nameplateAuraTimerHighThreshold", nil, 150)
            highThreshold:SetPoint("TOP", lowThreshold, "BOTTOM", 0, -26)
            highThreshold.integerOnly = true
            CreateTooltipTwo(highThreshold, L["Normal_Threshold"],
                L["Tooltip_Timer_Normal_Threshold"])

            local lowColorBox = CreateColorBox(timerColorOptionsFrame, "nameplateAuraTimerLowColor",
                L["Low_Color"], Refresh)
            lowColorBox:SetPoint("TOPLEFT", timerColorOptionsFrame, "TOPLEFT", 18, -125)

            local baseColorBox = CreateColorBox(timerColorOptionsFrame, "nameplateAuraTimerBaseColor",
                L["Normal_Color"], Refresh)
            baseColorBox:SetPoint("TOPLEFT", lowColorBox, "BOTTOMLEFT", 0, -10)

            local highColorBox = CreateColorBox(timerColorOptionsFrame, "nameplateAuraTimerHighColor",
                L["High_Color"], Refresh)
            highColorBox:SetPoint("TOPLEFT", baseColorBox, "BOTTOMLEFT", 0, -10)

            timerColorOptionsFrame:Show()
        else
            timerColorOptionsFrame:SetShown(not timerColorOptionsFrame:IsShown())
        end
    end

    timerColor:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            OpenTimerColorOptionsWindow()
        end
    end)

    Slider(left, L["Aura_CD_Text_Size"], 0.1, 2, 0.01, "defaultNpAuraCdSize", 12, L["Aura_CD_Text_Size"],
        L["Tooltip_Aura_CD_Text_Size_Desc"], showCd, -4)
    Slider(left, L["Big_Icon_CD_Text_Size"], 0.1, 2, 0.01, "bigNpAuraCdSize", 12, L["Big_Icon_CD_Text_Size"],
        L["Tooltip_Big_Icon_CD_Text_Size_Desc"], showCd, -4)

    local cdFontEnabled = Check(left, "npAuraCdFontEnabled", L["Change_Cooldown_Font"], showCd, 14,
        L["Custom_Timer_Font"], L["Tooltip_Custom_Timer_Font_Desc"],
        L["Tooltip_Custom_Timer_Font_SubText"])
    local cdFontDropdown = CreateFontDropdown("npAuraCdFontDropdown", contentFrame, L["Select_Font"],
        "npAuraCdFont", Refresh,
        { label = L["Timer_Font"], anchorFrame = cdFontEnabled, x = 4, y = 4 }, 140)
    CreateTooltipTwo(cdFontDropdown, L["Timer_Font"], L["Tooltip_Timer_Font_Desc"])
    cdFontDropdown.bbpRequires = "npAuraCdFontEnabled"
    table.insert(plainDropdowns, cdFontDropdown)
    cdFontEnabled:HookScript("OnClick", function()
        Refresh()
        UpdatePanelState()
    end)
    left.y = left.y - 36

    Header(mid, L["Stack_Text"])
    local showStackText = Check(mid, "npAuraShowStackText", L["Show_Stack_Text"])
    Slider(mid, L["Stack_Text_Scale"], 0.3, 3, 0.01, "nameplateAuraCountScale", -4, nil, nil, showStackText, -6)
    mid.y = mid.y - 6
    Slider(mid, L["Stack_Text_X"], -30, 30, 1, "npAuraStackTextXPos", -4, nil, nil, showStackText)
    local stackTextY = Slider(mid, L["Stack_Text_Y"], -30, 30, 1, "npAuraStackTextYPos", -4, nil, nil,
        showStackText)
    local stackTextAlign = CreateAnchorDropdown("npAuraStackTextAlignDropdown", contentFrame, "RIGHT",
        "npAuraStackTextAlign", Refresh,
        { label = L["Stack_Text_Align"], anchorFrame = stackTextY, x = -22, y = -34 }, 140, nil,
        { "LEFT", "CENTER", "RIGHT" })
    table.insert(dropdowns, stackTextAlign)
    mid.y = mid.y - 50

    local stackFontEnabled = Check(mid, "npAuraStackFontEnabled", L["Change_Stack_Font"], showStackText, -4)
    local stackFontDropdown = CreateFontDropdown("npAuraStackFontDropdown", contentFrame, L["Select_Font"],
        "npAuraStackFont", Refresh,
        { label = L["Stack_Font"], anchorFrame = stackFontEnabled, x = 4, y = 4 }, 140)
    stackFontDropdown.bbpRequires = "npAuraStackFontEnabled"
    table.insert(plainDropdowns, stackFontDropdown)
    stackFontEnabled:HookScript("OnClick", function()
        Refresh()
        UpdatePanelState()
    end)
    mid.y = mid.y - 50

    local stackTextColor = Swatch("npAuraStackTextColor", Refresh)
    stackTextColor.text:SetText(L["Stack_Text_Color"])
    Place(mid, stackTextColor, -8, CHECK_STEP, 10)

    StartRow(RowBottom() - SECTION_GAP)

    Header(left, L["Personal_Resource_Display"])
    Slider(left, L["PRD_Aura_Scale"], 0.3, 3, 0.01, "prdAuraScale", 0, L["PRD_Aura_Scale"],
        L["Tooltip_PRD_Aura_Scale_Desc"], prdAuras)
    Slider(left, L["PRD_Aura_X"], -100, 100, 0.5, "prdAuraXPos", 0, nil, nil, prdAuras)
    Slider(left, L["PRD_Aura_Y"], -100, 100, 0.5, "prdAuraYPos", 0, nil, nil, prdAuras)

    mid.y = mid.y - HEADER_STEP
    Slider(mid, L["PRD_Auras_Per_Row"], 1, 16, 1, "prdAuraRowAmount", 0, nil, nil, prdAuras)
    local prdMaxAuras = Slider(mid, L["PRD_Max_Auras"], 1, 12, 1, "prdAuraLimit", 0, L["PRD_Max_Auras"],
        L["Tooltip_PRD_Max_Auras_Desc"], prdAuras)
    local prdAuraAlign = CreateAnchorDropdown("prdAuraAlign", contentFrame, "CENTER", "prdAuraAlign", Refresh,
        { label = L["PRD_Aura_Align"], anchorFrame = prdMaxAuras, x = -22, y = -34 }, 140, nil,
        { "LEFT", "CENTER", "RIGHT" })
    prdAuraAlign.bbpRequires = "prdAurasEnabled"
    table.insert(plainDropdowns, prdAuraAlign)
    mid.y = mid.y - 60

    right.y = right.y - HEADER_STEP
    TestButton(right, 0)

    UpdatePanelState()
    UpdateTestButtons()

    BBP.RefreshNameplateAuraPanel = function()
        for key, cb in pairs(boxes) do
            cb:SetChecked(BetterBlizzPlatesDB[key] and true or false)
        end
        UpdatePanelState()
        UpdateTestButtons()
        Refresh()
    end

    contentFrame:SetSize(680, math.max(600, math.abs(RowBottom()) + 30))
end

local function guiCVarControl()
    --------------------------
    -- More Blizz Settings
    --------------------------
    local guiCVarControl = CreateFrame("Frame")
    guiCVarControl.name = L["CVar_Control"]
    guiCVarControl.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiCVarControl)
    local guiCVarControlCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiCVarControl, guiCVarControl.name)
    CreateTitle(guiCVarControl)

    local bgImg = guiCVarControl:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiCVarControl, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local moreBlizzSettings = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettings:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 0, 0)
    moreBlizzSettings:SetText(L["Blizzard_CVar_Settings_Not_Available_In_Base_UI"])


    local comboPointsText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    comboPointsText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 20, -25)
    comboPointsText:SetText(L["Resource_Settings_Combo_Points_Etc"])
    comboPointsText:SetFont(fontLarge, 16)
    comboPointsText:SetTextColor(1,1,1)
    local comboPointIcon = guiCVarControl:CreateTexture(nil, "ARTWORK")
    comboPointIcon:SetAtlas("ClassOverlay-ComboPoint")
    comboPointIcon:SetSize(16, 16)
    comboPointIcon:SetPoint("RIGHT", comboPointsText, "LEFT", -3, 0)

    local nameplateResourceOnTarget = CreateCheckbox("nameplateResourceOnTarget", L["Prd_Resource_On_Target"], guiCVarControl, true, BBP.TargetResourceUpdater)
    nameplateResourceOnTarget:SetPoint("TOPLEFT", comboPointsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(nameplateResourceOnTarget, L["Nameplate_Resource"], L["Tooltip_Nameplate_Resource_Desc"], nil, nil, "nameplateResourceOnTarget")
    nameplateResourceOnTarget:HookScript("OnClick", function()
        BBP.RegisterTargetCastingEvents()
        BBP.ApplyNameplateWidth()
        BBP.ForeverComboPoints()
    end)

    nameplateResourceOnTarget:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BBP.checkCombatAndWarn() then
                if BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf == nil then
                    BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf = true
                else
                    BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf = nil
                end
                if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                    self:GetScript("OnEnter")(self)
                end
                if nameplateResourceOnTarget:GetChecked() and not BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf then
                    C_CVar.SetCVar("nameplateResourceOnTarget", "1")
                    BetterBlizzPlatesDB.nameplateResourceOnTarget = "1"
                end
                BBP.TargetResourceUpdater()
                BBP.ForeverComboPoints()
            end
        end
    end)

    local instantComboPoints = CreateCheckbox("instantComboPoints", L["Instant_Combo_Points"], guiCVarControl, nil, BBP.InstantComboPoints)
    instantComboPoints:SetPoint("TOPLEFT", nameplateResourceOnTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(instantComboPoints, L["Instant_Combo_Points"], L["Tooltip_Instant_Combo_Points_Desc_2"])
    instantComboPoints:HookScript("OnClick", function(self)
        BBP.ForeverComboPoints()
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
            if BetterBlizzFramesDB then
                BetterBlizzFramesDB.instantComboPoints = false
            end
        end
    end)

    local hideResourceFrame = CreateCheckbox("hideResourceFrame", L["Hide_Resource_On_Personal_Bar"], guiCVarControl, nil, BBP.HideResourceFrames)
    hideResourceFrame:SetPoint("TOPLEFT", instantComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hideResourceFrame:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            local resourceFrame = PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.classFrame
            if resourceFrame then
                resourceFrame:SetAlpha(1)
            end
        end
    end)
    CreateTooltipTwo(hideResourceFrame, L["Hide_Resource_On_Personal_Bar"], L["Tooltip_Hide_Resource_On_Personal_Bar_Desc"])

    local classOptionsFrame
    local function OpenClassSpecificWindow()
        if not classOptionsFrame then
            classOptionsFrame = CreateFrame("Frame", "ClassOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            classOptionsFrame:SetSize(185, 252)
            classOptionsFrame:SetPoint("CENTER")
            classOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            classOptionsFrame:SetFrameLevel(550)
            classOptionsFrame:SetIgnoreParentAlpha(true)
            classOptionsFrame:SetTitle(L["Class_Specific_Options"])
            classOptionsFrame:EnableMouse(true)
            classOptionsFrame:SetMovable(true)
            classOptionsFrame:SetClampedToScreen(true)
            classOptionsFrame:RegisterForDrag("LeftButton")
            classOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            classOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            classOptionsFrame.closeButton = CreateFrame("Button", nil, classOptionsFrame, "UIPanelCloseButton")
            classOptionsFrame.closeButton:SetFrameLevel((classOptionsFrame.TitleContainer or classOptionsFrame):GetFrameLevel() + 10)
            classOptionsFrame.closeButton:SetPoint("TOPRIGHT", classOptionsFrame, "TOPRIGHT", 0, 0)
            classOptionsFrame.closeButton:SetScript("OnClick", function()
                classOptionsFrame:Hide()
            end)

            classOptionsFrame.bg = classOptionsFrame:CreateTexture(nil, "BACKGROUND")
            classOptionsFrame.bg:SetPoint("TOPLEFT", classOptionsFrame, "TOPLEFT", 7, -3)
            classOptionsFrame.bg:SetPoint("BOTTOMRIGHT", classOptionsFrame, "BOTTOMRIGHT", -3, 3)
            classOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local classes = {
                { class = L["Class_Druid"], var = "hideResourceFrameNoDruid", color = RAID_CLASS_COLORS["DRUID"] },
                { class = L["Class_Rogue"], var = "hideResourceFrameNoRogue", color = RAID_CLASS_COLORS["ROGUE"] },
                { class = L["Class_Warlock"], var = "hideResourceFrameNoWarlock", color = RAID_CLASS_COLORS["WARLOCK"] },
                { class = L["Class_Paladin"], var = "hideResourceFrameNoPaladin", color = RAID_CLASS_COLORS["PALADIN"] },
                { class = L["Class_Death_Knight"], var = "hideResourceFrameNoDeathKnight", color = RAID_CLASS_COLORS["DEATHKNIGHT"] },
                { class = L["Class_Evoker"], var = "hideResourceFrameNoEvoker", color = RAID_CLASS_COLORS["EVOKER"] },
                { class = L["Class_Monk"], var = "hideResourceFrameNoMonk", color = RAID_CLASS_COLORS["MONK"] },
                { class = L["Class_Mage"], var = "hideResourceFrameNoMage", color = RAID_CLASS_COLORS["MAGE"] },
                { class = L["Class_Shaman"], var = "hideResourceFrameNoShaman", color = RAID_CLASS_COLORS["SHAMAN"] },
                { class = L["Class_Hunter"], var = "hideResourceFrameNoHunter", color = RAID_CLASS_COLORS["HUNTER"] },
            }

            local previousCheckbox
            for i, classData in ipairs(classes) do
                local classCheckbox = CreateFrame("CheckButton", nil, classOptionsFrame, "UICheckButtonTemplate")
                classCheckbox:SetSize(24, 24)
                classCheckbox.Text:SetText(string.format(L["Ignore_Class"], classData.class))

                local r, g, b = classData.color.r, classData.color.g, classData.color.b
                classCheckbox.Text:SetTextColor(r, g, b)

                if i == 1 then
                    classCheckbox:SetPoint("TOPLEFT", classOptionsFrame, "TOPLEFT", 10, -30)
                else
                    classCheckbox:SetPoint("TOPLEFT", previousCheckbox, "BOTTOMLEFT", 0, 3)
                end

                classCheckbox:SetChecked(BetterBlizzPlatesDB[classData.var])

                classCheckbox:SetScript("OnClick", function(self)
                    BetterBlizzPlatesDB[classData.var] = self:GetChecked() or nil
                    BBP.HideResourceFrames()
                end)

                previousCheckbox = classCheckbox
            end
            classOptionsFrame:Show()
        else
            if classOptionsFrame:IsShown() then
                classOptionsFrame:Hide()
            else
                classOptionsFrame:Show()
            end
        end
    end

    hideResourceFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenClassSpecificWindow()
        end
    end)

    local druidAlwaysShowCombos = CreateCheckbox("druidAlwaysShowCombos", L["Druid_Always_Show_Combo_Points"], guiCVarControl)
    druidAlwaysShowCombos:SetPoint("TOPLEFT", hideResourceFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(druidAlwaysShowCombos, L["Druid_Always_Show_Combo_Points"], L["Tooltip_Druid_Always_Show_Combo_Points_Desc"])
    druidAlwaysShowCombos:HookScript("OnClick", function()
        BBP.ForeverComboPoints()
    end)

    local hideEmptyComboPoints = CreateCheckbox("hideEmptyComboPoints", L["Hide_Combo_Points_When_Empty"], guiCVarControl)
    hideEmptyComboPoints:SetPoint("TOPLEFT", druidAlwaysShowCombos, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideEmptyComboPoints, L["Hide_Combo_Points_When_Empty"], L["Tooltip_Hide_Combo_Points_When_Empty_Desc"])

    local onlyActiveComboPoints = CreateCheckbox("onlyActiveComboPoints", L["Only_Show_Filled_Combo_Points"], guiCVarControl)
    onlyActiveComboPoints:SetPoint("TOPLEFT", hideEmptyComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(onlyActiveComboPoints, L["Only_Show_Filled_Combo_Points"], L["Tooltip_Only_Show_Filled_Combo_Points_Desc"])

    hideEmptyComboPoints:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.onlyActiveComboPoints = false
            onlyActiveComboPoints:SetChecked(false)
        end
        BBP.UpdateComboVisibility()
    end)
    onlyActiveComboPoints:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.hideEmptyComboPoints = false
            hideEmptyComboPoints:SetChecked(false)
        end
        BBP.UpdateComboVisibility()
    end)

    local changeResourceStrata = CreateCheckbox("changeResourceStrata", L["Increase_Resource_Layer_Level"], guiCVarControl, nil, BBP.ChangeStrataOfResourceFrame)
    changeResourceStrata:SetPoint("TOP", onlyActiveComboPoints, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(changeResourceStrata, L["Increase_Resource_Layer_Level"], L["Tooltip_Increase_Resource_Layer_Level_Desc"])

    local nameplateResourceUnderCastbar = CreateCheckbox("nameplateResourceUnderCastbar", L["Anchor_Resource_Underneath_Healthbar_Castbar"], nameplateResourceOnTarget, nil, BBP.RegisterTargetCastingEvents)
    nameplateResourceUnderCastbar:SetPoint("TOP", changeResourceStrata, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateResourceUnderCastbar, L["Anchor_Resource_Under"], L["Tooltip_Anchor_Resource_Under_Desc"])
    nameplateResourceOnTarget:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(nameplateResourceOnTarget)
    end)

    local hideResourceOnFriend = CreateCheckbox("hideResourceOnFriend", L["Hide_Resource_On_Friendly_Nameplates"], guiCVarControl)
    hideResourceOnFriend:SetPoint("TOP", nameplateResourceUnderCastbar, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideResourceOnFriend, L["Hide_Resource_On_Friendly"], L["Tooltip_Hide_Resource_On_Friendly_Desc"])

    local nameplateResourceScale = CreateSlider(guiCVarControl, L["Resource_Scale"], 0.2, 1.7, 0.01, "nameplateResourceScale")
    nameplateResourceScale:SetPoint("TOPLEFT", hideResourceOnFriend, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(nameplateResourceScale, L["Resource_Scale"], L["Tooltip_Resource_Scale_Desc"])
    CreateResetButton(nameplateResourceScale, "nameplateResourceScale", guiCVarControl)

    local nameplateResourceXPos = CreateSlider(guiCVarControl, L["X_Offset"], -100, 100, 1, "nameplateResourceXPos", "X")
    nameplateResourceXPos:SetPoint("TOPLEFT", nameplateResourceScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceXPos, L["Nameplate_Resource_X_Position"], L["Tooltip_Nameplate_Resource_X_Position_Desc"])
    CreateResetButton(nameplateResourceXPos, "nameplateResourceXPos", guiCVarControl)

    local nameplateResourceYPos = CreateSlider(guiCVarControl, L["Y_Offset"], -100, 100, 1, "nameplateResourceYPos", "Y")
    nameplateResourceYPos:SetPoint("TOPLEFT", nameplateResourceXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceYPos, L["Nameplate_Resource_Y_Position"], L["Tooltip_Nameplate_Resource_Y_Position_Desc"])
    CreateResetButton(nameplateResourceYPos, "nameplateResourceYPos", guiCVarControl)

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", L["Dark_Mode"], guiCVarControl, nil, BBP.DarkModeNameplateResources)
    darkModeNameplateResource:SetPoint("TOPLEFT", nameplateResourceYPos, "BOTTOMLEFT", -12, -4)
    CreateTooltipTwo(darkModeNameplateResource, L["Resource_Dark_Mode"], L["Tooltip_Resource_Dark_Mode_Desc"])

    local darkModeNameplateColor = CreateSlider(darkModeNameplateResource, L["Darkness_Amount"], 0, 1, 0.01, "darkModeNameplateColor")
    darkModeNameplateColor:SetPoint("TOPLEFT", darkModeNameplateResource, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(darkModeNameplateColor, L["How_Dark_You_Want_Nameplate_Resource"])

    darkModeNameplateResource:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeNameplateResource)
    end)

    local disableCVarForceOnLogin = CreateCheckbox("disableCVarForceOnLogin", L["Disable_All_CVar_Forcing"], guiCVarControl)
    disableCVarForceOnLogin:SetPoint("BOTTOM", guiCVarControl, "BOTTOM", -disableCVarForceOnLogin.Text:GetStringWidth() / 2 - 25, -2.5)
    CreateTooltipTwo(disableCVarForceOnLogin, L["Disable_All_CVar_Forcing"], L["Tooltip_Disable_All_CVar_Forcing_2_Desc"], L["Tooltip_Disable_All_CVar_Forcing_2_SubText"])
    disableCVarForceOnLogin:SetScale(1.2)

    local avoidCVarPickup = CreateCheckbox("avoidCVarPickup", L["Avoid_CVar_Pickup"], guiCVarControl)
    avoidCVarPickup:SetPoint("BOTTOMLEFT", disableCVarForceOnLogin, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(avoidCVarPickup, L["Avoid_CVar_Pickup"], L["Tooltip_Avoid_CVar_Pickup_Desc"])
    avoidCVarPickup:SetScale(1.2)

    local nameplateSimplifiedScale = CreateSlider(guiCVarControl, L["Simplified_Scale"], 0.3, 1, 0.01, "nameplateSimplifiedScale")
    nameplateSimplifiedScale:SetPoint("TOPLEFT", darkModeNameplateColor, "BOTTOMLEFT", 0, -20)
    CreateTooltipTwo(nameplateSimplifiedScale, L["Simplified_Scale"], L["Tooltip_Simplified_Scale_Desc"], L["Tooltip_Simplified_Scale_SubText"], nil, "nameplateSimplifiedScale")
    CreateResetButton(nameplateSimplifiedScale, "nameplateSimplifiedScale", guiCVarControl)

    local nameplateAlphaText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateAlphaText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 400, -35)
    nameplateAlphaText:SetText(L["Nameplate_Alpha_Settings"])
    nameplateAlphaText:SetFont(fontLarge, 16)
    nameplateAlphaText:SetTextColor(1,1,1)

    local nameplateMinAlpha = CreateSlider(guiCVarControl, L["Min_Alpha"], 0, 1, 0.01, "nameplateMinAlpha")
    nameplateMinAlpha:SetPoint("TOP", nameplateAlphaText, "BOTTOM", 0, -17)
    CreateTooltipTwo(nameplateMinAlpha, L["Min_Alpha"], L["Tooltip_Min_Alpha_Desc"], L["Tooltip_Min_Alpha_SubText"], nil, "nameplateMinAlpha")
    CreateResetButton(nameplateMinAlpha, "nameplateMinAlpha", guiCVarControl)

    local nameplateMinAlphaDistance = CreateSlider(guiCVarControl, L["Min_Alpha_Distance"], 0, 60, 1, "nameplateMinAlphaDistance")
    nameplateMinAlphaDistance:SetPoint("TOPLEFT", nameplateMinAlpha, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateMinAlphaDistance, L["Min_Alpha_Distance"], L["Tooltip_Min_Alpha_Distance_Desc"], nil, nil, "nameplateMinAlphaDistance")
    CreateResetButton(nameplateMinAlphaDistance, "nameplateMinAlphaDistance", guiCVarControl)

    local nameplateMaxAlpha = CreateSlider(guiCVarControl, L["Max_Alpha"], 0, 1, 0.01, "nameplateMaxAlpha")
    nameplateMaxAlpha:SetPoint("TOP", nameplateMinAlphaDistance, "BOTTOM", 0, -17)
    CreateTooltipTwo(nameplateMaxAlpha, L["Max_Alpha"], L["Tooltip_Max_Alpha_Desc"], nil, nil, "nameplateMaxAlpha")
    CreateResetButton(nameplateMaxAlpha, "nameplateMaxAlpha", guiCVarControl)

    local nameplateMaxAlphaDistance = CreateSlider(guiCVarControl, L["Max_Alpha_Distance"], 0, 60, 1, "nameplateMaxAlphaDistance")
    nameplateMaxAlphaDistance:SetPoint("TOPLEFT", nameplateMaxAlpha, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateMaxAlphaDistance, L["Max_Alpha_Distance"], L["Tooltip_Max_Alpha_Distance_Desc"], L["Tooltip_Max_Alpha_Distance_SubText"], nil, "nameplateMaxAlphaDistance")
    CreateResetButton(nameplateMaxAlphaDistance, "nameplateMaxAlphaDistance", guiCVarControl)

    local nameplateOccludedAlphaMult = CreateSlider(guiCVarControl, L["Occluded_Alpha"], 0, 1, 0.01, "nameplateOccludedAlphaMult")
    nameplateOccludedAlphaMult:SetPoint("TOPLEFT", nameplateMaxAlphaDistance, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOccludedAlphaMult, L["Occluded_Alpha"], L["Tooltip_Occluded_Alpha_Desc"], nil, nil, "nameplateOccludedAlphaMult")
    CreateResetButton(nameplateOccludedAlphaMult, "nameplateOccludedAlphaMult", guiCVarControl)

    local enableNpNonTargetAlpha = CreateCheckbox("enableNpNonTargetAlpha", L["Enable"], guiCVarControl, nil, BBP.ToggleNpNonTargetAlphaHook)
    CreateTooltipTwo(enableNpNonTargetAlpha, L["Enable_Non_Target_Alpha"])

    local enableNpNonFocusAlpha = CreateCheckbox("enableNpNonFocusAlpha", L["Focus"], enableNpNonTargetAlpha)
    enableNpNonFocusAlpha:SetPoint("LEFT", enableNpNonTargetAlpha.text, "RIGHT", 0, 0)
    CreateTooltipTwo(enableNpNonFocusAlpha, L["Also_Keep_Focus_Nameplate_Full_Alpha"])

    local enableNpNonTargetAlphaTargetOnly = CreateCheckbox("enableNpNonTargetAlphaTargetOnly", L["Require_Target"], enableNpNonTargetAlpha)
    CreateTooltipTwo(enableNpNonTargetAlphaTargetOnly, L["Only_Fade_Out_Other_Nameplates_When_You_Have"])
    enableNpNonTargetAlphaTargetOnly:SetPoint("TOPLEFT", enableNpNonTargetAlpha, "BOTTOMLEFT", 0, 6)

    local enableNpNonTargetAlphaFullAlphaCasting = CreateCheckbox("enableNpNonTargetAlphaFullAlphaCasting", L["Casting_Full_Alpha"], enableNpNonTargetAlpha)
    CreateTooltipTwo(enableNpNonTargetAlphaFullAlphaCasting, L["Keep_Casting_Nameplates_At_Full_Alpha"])
    enableNpNonTargetAlphaFullAlphaCasting:SetPoint("TOPLEFT", enableNpNonTargetAlphaTargetOnly, "BOTTOMLEFT", 0, 6)

    local nameplateNonTargetAlpha = CreateSlider(enableNpNonTargetAlpha, L["Non_Target_Alpha"], 0, 1, 0.01, "nameplateNonTargetAlpha")
    nameplateNonTargetAlpha:SetPoint("TOPLEFT", nameplateOccludedAlphaMult, "BOTTOMLEFT", 0, -17)

    enableNpNonTargetAlpha:SetPoint("LEFT", nameplateNonTargetAlpha, "RIGHT", 5, 8)
    enableNpNonTargetAlpha:HookScript("OnClick", function(self)
        if self:GetChecked() then
            CheckAndToggleCheckboxes(enableNpNonTargetAlpha)
        else
            CheckAndToggleCheckboxes(enableNpNonTargetAlpha)
        end
    end)

    local nameplateCVarText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateCVarText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 400, -320)
    nameplateCVarText:SetText(L["Nameplate_Visibility_CVars"])
    nameplateCVarText:SetFont(fontLarge, 16)
    nameplateCVarText:SetTextColor(1,1,1)

    local setCVarAcrossAllCharacters = CreateCheckbox("setCVarAcrossAllCharacters", L["Force_These_CVars_Across_All_Characters"], guiCVarControl)
    setCVarAcrossAllCharacters:SetPoint("TOP", nameplateCVarText, "BOTTOM", -100, 0)
    CreateTooltipTwo(setCVarAcrossAllCharacters, L["Force_CVars"], L["Tooltip_Force_CVars_Desc"])

    local nameplateShowAll = CreateCheckbox("nameplateShowAll", L["Always_Show_Nameplates_If_Not_Targeted"], guiCVarControl, true)
    nameplateShowAll:SetPoint("TOP", setCVarAcrossAllCharacters, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowAll, L["Always_Show_Nameplates"], L["Always_Show_Nameplates_If_Not_Targeted"], nil, nil, "nameplateShowAll")

    guiCVarControl.modeLabel = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guiCVarControl.modeLabel:SetPoint("TOPLEFT", nameplateShowAll, "BOTTOMLEFT", 4, -9)
    guiCVarControl.modeLabel:SetText(L["Nameplate_Toggle_Mode_Colon"])

    guiCVarControl.modeDropdown = CreateFrame("DropdownButton", nil, guiCVarControl, "WowStyle1DropdownTemplate")
    guiCVarControl.modeDropdown:SetPoint("RIGHT", guiCVarControl.modeLabel, "LEFT", 268, 0)
    guiCVarControl.modeDropdown:SetWidth(110)
    CreateTooltipTwo(guiCVarControl.modeDropdown, L["Nameplate_Toggle_Mode"], L["Tooltip_Nameplate_Toggle_Mode_Desc"])

    guiCVarControl.toggleRowFrames = {}

    function guiCVarControl.ToggleSelectionText(categoryKey)
        local db = BetterBlizzPlatesDB
        local set = db[BBP.NameplateToggleSetKey(categoryKey)] or {}
        local parts = {}
        if set.nameplateShowEnemies then parts[#parts + 1] = L["Enemy"] end
        local friendlyOn, friendlyTotal = BBP.GetFriendlyToggleCount(categoryKey)
        if friendlyOn > 0 then
            local friendlyText = set.nameplateShowOnlyNameForFriendlyPlayerUnits and L["CVar_Summary_Friendly_Names"] or L["Friendly"]
            parts[#parts + 1] = friendlyOn < friendlyTotal and string.format(L["CVar_Summary_Some"], friendlyText) or friendlyText
        end
        local extras = 0
        for _, entry in ipairs(BBP.nameplateToggleEntries) do
            if entry and not entry.root and not entry.stack and not entry.short and BBP.NameplateToggleEntryAvailable(entry) and set[entry.key] then
                local rootOn = true
                if entry.side == "enemy" then
                    rootOn = set.nameplateShowEnemies
                elseif entry.side == "friendly" then
                    rootOn = friendlyOn > 0
                end
                if rootOn then extras = extras + 1 end
            end
        end
        local text = #parts > 0 and table.concat(parts, ", ") or L["None"]
        if extras > 0 then text = text .. " +" .. extras end
        return text
    end

    function guiCVarControl.BuildToggleDropdown(categoryKey, dropdown)
        local setKey = BBP.NameplateToggleSetKey(categoryKey)
        local function GetSet()
            local set = BetterBlizzPlatesDB[setKey]
            if type(set) ~= "table" then
                set = {}
                BetterBlizzPlatesDB[setKey] = set
            end
            return set
        end
        dropdown:SetupMenu(function(owner, rootDescription)
            rootDescription:SetGridMode(MenuConstants.HorizontalGridDirection, 2, 0)
            for _, entry in ipairs(BBP.nameplateToggleEntries) do
                if entry and BBP.NameplateToggleEntryAvailable(entry) then
                    local checkbox = rootDescription:CreateCheckbox(entry.label,
                        function()
                            if entry.key == "nameplateShowFriendlyPlayers" then
                                return BBP.GetFriendlyToggle(categoryKey)
                            end
                            return GetSet()[entry.key] == true
                        end,
                        function()
                            if entry.key == "nameplateShowFriendlyPlayers" then
                                BBP.SetFriendlyToggle(categoryKey, not BBP.GetFriendlyToggle(categoryKey), true)
                                return
                            end
                            local set = GetSet()
                            set[entry.key] = not set[entry.key]
                            BBP.lastAppliedNameplateToggles = nil
                            BBP.UpdateNameplateToggles(true, true)
                        end)
                    local isEnemyEntry = entry.side == "enemy"
                    checkbox:AddInitializer(function(button)
                        if isEnemyEntry then
                            button.fontString:SetTextColor(1, 0.38, 0.38)
                        else
                            button.fontString:SetTextColor(0.35, 0.7, 1)
                        end
                    end)
                    if entry.side and not entry.root then
                        local isEnemySide = entry.side == "enemy"
                        checkbox:SetEnabled(function()
                            if isEnemySide then
                                return GetSet().nameplateShowEnemies == true
                            end
                            return (BBP.GetFriendlyToggleCount(categoryKey)) > 0
                        end)
                    end
                else
                    rootDescription:CreateSpacer()
                end
            end
        end)
        dropdown:SetDefaultText(L["None"])
        dropdown:SetSelectionText(function()
            return guiCVarControl.ToggleSelectionText(categoryKey)
        end)
    end

    BBP.RefreshNameplateToggleRows = function()
        guiCVarControl.RefreshNameplateToggleRows()
    end

    function guiCVarControl.RefreshNameplateToggleRows()
        local mode = BBP.GetNameplateToggleMode()
        local previous
        for _, row in ipairs(guiCVarControl.toggleRowFrames) do
            if row.category.mode == mode then
                row:ClearAllPoints()
                if previous then
                    row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
                else
                    row:SetPoint("TOPLEFT", guiCVarControl.modeLabel, "BOTTOMLEFT", -4, -17)
                end
                previous = row
                row.dropdown:GenerateMenu()
                row:Show()
            else
                row:Hide()
            end
        end
        guiCVarControl.modeDropdown:GenerateMenu()
    end

    guiCVarControl.modeDropdown:SetupMenu(function(owner, rootDescription)
        for _, option in ipairs({ { "simple", L["CVar_Mode_Simple"] }, { "advanced", L["CVar_Mode_Advanced"] } }) do
            rootDescription:CreateRadio(option[2],
                function()
                    return BBP.GetNameplateToggleMode() == option[1]
                end,
                function()
                    BetterBlizzPlatesDB.nameplateToggleMode = option[1]
                    BBP.lastAppliedNameplateToggles = nil
                    guiCVarControl.RefreshNameplateToggleRows()
                    BBP.UpdateNameplateToggles(true, true)
                end)
        end
    end)

    for _, category in ipairs(BBP.nameplateToggleCategories) do
        if category.available then
            local row = CreateFrame("Frame", nil, guiCVarControl)
            row:SetSize(272, 24)
            row.category = category

            row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.label:SetPoint("RIGHT", row, "LEFT", 136, 0)
            row.label:SetJustifyH("RIGHT")
            row.label:SetText(string.format(L["CVar_Row_In_Category_Show"], category.label))

            row.dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
            row.dropdown:SetPoint("LEFT", row, "LEFT", 142, 0)
            row.dropdown:SetWidth(130)
            guiCVarControl.BuildToggleDropdown(category.key, row.dropdown)
            CreateTooltipTwo(row.dropdown, string.format(L["Tooltip_CVar_Row_Title"], category.label), string.format(L["Tooltip_CVar_Row_Desc"], category.label), (category.pvp or category.key == "pvp") and ("|cFFFFD100" .. L["Tooltip_CVar_Row_Totem_Note"] .. "|r") or nil)

            guiCVarControl.toggleRowFrames[#guiCVarControl.toggleRowFrames + 1] = row
        end
    end
    guiCVarControl.RefreshNameplateToggleRows()

    local cbCVars = {}
    --cbCVars["nameplateResourceOnTarget"] = nameplateResourceOnTarget
    cbCVars["nameplateShowAll"] = nameplateShowAll

    local sliderCVars = {}
    sliderCVars["nameplateOverlapH"] = nameplateOverlapH
    sliderCVars["nameplateOverlapV"] = nameplateOverlapV
    --sliderCVars["nameplateMotionSpeed"] = nameplateMotionSpeed
    sliderCVars["nameplateMinAlpha"] = nameplateMinAlpha
    sliderCVars["nameplateMinAlphaDistance"] = nameplateMinAlphaDistance
    sliderCVars["nameplateMaxAlpha"] = nameplateMaxAlpha
    sliderCVars["nameplateMaxAlphaDistance"] = nameplateMaxAlphaDistance
    sliderCVars["nameplateOccludedAlphaMult"] = nameplateOccludedAlphaMult

    C_Timer.After(0.5, function()
        local cvarListener = CreateFrame("Frame")
        cvarListener:RegisterEvent("CVAR_UPDATE")
        cvarListener:SetScript("OnEvent", function(self, event, cvarName, cvarValue)
            if BBP.CVarTrackingDisabled then return end
            if (BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater")) then return end
            if BetterBlizzPlatesDB.avoidCVarPickup then return end
            local checkedState = cvarValue == "1" or false
            if cvarValue then
                if cbCVars[cvarName] then
                    --BetterBlizzPlatesDB[cvarName] = cvarValue
                    cbCVars[cvarName]:SetChecked(checkedState)
                elseif sliderCVars[cvarName] then
                    --BetterBlizzPlatesDB[cvarName] = tonumber(cvarValue)
                    sliderCVars[cvarName]:SetValue(tonumber(cvarValue))
                elseif cvarName == "nameplateStackingTypes" then
                    -- Sync bitfield checkbox UI
                    local enemyVal = C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy)
                    local friendlyVal = C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly)
                    nameplateStackingEnemy:SetChecked(enemyVal and true or false)
                    nameplateStackingFriendly:SetChecked(friendlyVal and true or false)
                    CheckAndToggleCheckboxes(nameplateStackingEnemy)
                end
            end
        end)
    end)


    --local moreBlizzSettingsText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    --moreBlizzSettingsText:SetPoint("BOTTOM", guiCVarControl, "BOTTOM", 0, 10)
    --moreBlizzSettingsText:SetText("Work in progress, more stuff inc soon™\n \nSome settings don't make much sense anymore because\nthe addon grew a bit more than I thought it would.\nWill clean up eventually\n \nIf you have any suggestions feel free to\nleave a comment on CurseForge")
end

local function guiTotemList()
    -----------------------
    -- Hide NPC
    -----------------------
    local guiTotemList = CreateFrame("Frame")
    guiTotemList.name = L["Totem_Indicator_List"]
    guiTotemList.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiTotemList)
    local guiTotemListCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiTotemList, guiTotemList.name)
    CreateTitle(guiTotemList)

    local bgImg = guiTotemList:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiTotemList, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiTotemList)
    listFrame:SetAllPoints(guiTotemList)
    BBP.totemIndicatorListFrame = listFrame

    local totemListFrame = CreateFrame("Frame", nil, listFrame)
    totemListFrame:SetSize(322, 390)
    totemListFrame:SetPoint("TOPLEFT", -5, 3)

    local overlayFrame = CreateFrame("Frame", nil, guiTotemList)
    overlayFrame:EnableMouse(true)
    overlayFrame:SetAllPoints(bgImg)
    overlayFrame:SetFrameLevel(guiTotemList:GetFrameLevel() + 100)
    overlayFrame.bg = overlayFrame:CreateTexture(nil, "BACKGROUND")
    overlayFrame.bg:SetAllPoints(overlayFrame)
    overlayFrame.bg:SetColorTexture(0, 0, 0, 0.8)
    overlayFrame:Show()

    local ggText = overlayFrame:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Huge1")
    ggText:SetPoint("CENTER", overlayFrame, "CENTER", 0, 80)
    ggText:SetText(L["GGs"])
    ggText:SetTextColor(1, 0.2, 0.2, 1)
    ggText:SetTextScale(4.5)
    ggText:SetJustifyH("CENTER")

    local warningText = overlayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    warningText:SetPoint("TOP", ggText, "BOTTOM", 0, -3)
    warningText:SetText(L["All_Of_These_Settings_Are_Currently_Disabled_Unsure"])
    warningText:SetTextColor(1, 0.8, 0, 1)
    warningText:SetWidth(520)
    warningText:SetWordWrap(true)
    warningText:SetJustifyH("CENTER")

    -- local totemListTip = guiTotemList:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- totemListTip:SetPoint("TOP", guiTotemList, "TOP", 0, 8)
    -- totemListTip:SetText("(Adjust general size of ALL icons in the Advanced Settings tab)")

    local totemList-- = CreateNpcList(totemListFrame, BetterBlizzPlatesDB.totemIndicatorNpcList, BBP.RefreshAllNameplates, 630, 490)
    if BetterBlizzPlatesDB.totemIndicatorWidthEnabled then
        totemList = CreateNpcListWidth(totemListFrame, BetterBlizzPlatesDB.totemIndicatorNpcList, BBP.RefreshAllNameplates, 630, 490)
    else
        totemList = CreateNpcList(totemListFrame, BetterBlizzPlatesDB.totemIndicatorNpcList, BBP.RefreshAllNameplates, 630, 490)
    end

    local function CreateTotemListElements()
        local totemIndicatorScale = CreateSlider(listFrame, L["General_Scale_Of_All_Totem_Icons"], 0.5, 3, 0.01, "totemIndicatorScale")
        totemIndicatorScale:SetPoint("TOP", totemList, "BOTTOM", -25, -45)
        totemIndicatorScale:HookScript("OnValueChanged", function(self)
            local val = self:GetValue()
            BBP.totemIndicatorScale:SetValue(val)
        end)
        totemIndicatorScale:SetScale(1.2)

        local totemIndicatorWidthEnabled = CreateCheckbox("totemIndicatorWidthEnabled", L["Enable_Healthbar_Width_Settings"], listFrame)
        totemIndicatorWidthEnabled:SetPoint("LEFT", totemIndicatorScale, "RIGHT", 25, 2)
        totemIndicatorWidthEnabled:HookScript("OnClick", function()
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end)
        CreateTooltipTwo(totemIndicatorWidthEnabled,L["Enable_Healthbar_Width_Settings"], L["Tooltip_Enable_Healthbar_Width_Settings_Desc"])
        totemIndicatorWidthEnabled:SetScale(1.1)

        local totemIndicatorUseNicknames = CreateCheckbox("totemIndicatorUseNicknames", L["Use_Nicknames"], listFrame)
        totemIndicatorUseNicknames:SetPoint("TOPLEFT", totemIndicatorWidthEnabled, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        CreateTooltipTwo(totemIndicatorUseNicknames,L["Use_Nicknames"], L["Tooltip_Use_Nicknames_Desc"])
        totemIndicatorUseNicknames:SetScale(1.1)

        local resetTotemListButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        resetTotemListButton:SetText(L["Reset_Totem_List"])
        resetTotemListButton:SetWidth(120)
        resetTotemListButton:SetPoint("BOTTOMLEFT", listFrame, "BOTTOMLEFT", 10, 20)
        resetTotemListButton:SetScript("OnClick", function()
            BBP.ShowPopup("BBP_TOTEMLIST_RESET")
        end)
        CreateTooltipTwo(resetTotemListButton, L["Reset_Totem_List"], L["Tooltip_Reset_Totem_List_Desc"], nil, "ANCHOR_TOP")
    end

    if not BetterBlizzPlatesDB.totemIndicator then
        listFrame:SetAlpha(0.5)
        guiTotemList.totemIndicator = CreateCheckbox("totemIndicator", L["Enable_Totem_Indicator"], guiTotemList)
        guiTotemList.totemIndicator:SetPoint("TOP", totemList, "BOTTOM", -45, -45)
        guiTotemList.totemIndicator:HookScript("OnClick", function(self)
            local function setTotemCVar()
                if InCombatLockdown() then
                    C_Timer.After(1.5, setTotemCVar)
                elseif self:GetChecked() then
                    BBP.EnableTotemIndicatorCVars()
                else
                    BBP.UpdateNameplateToggles(true, true)
                end
            end
            setTotemCVar()
            guiTotemList.totemIndicator:Hide()
            listFrame:SetAlpha(1)
            CreateTotemListElements()
        end)
        CreateTooltipTwo(guiTotemList.totemIndicator, L["Totem_Indicator"] .. " |A:teleportationnetwork-ardenweald-32x32:17:17|a", L["Tooltip_Totem_Indicator_2_Desc_2"])
    else
        CreateTotemListElements()
    end
end

local function CreateGuiFontSection(parent, anchor)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 12, -4)
    header:SetText("BBP")
    header:SetFont(fontLarge, 16)
    header:SetTextColor(1,1,1)
    local headerIcon = parent:CreateTexture(nil, "ARTWORK")
    headerIcon:SetAtlas("gmchat-icon-blizz")
    headerIcon:SetSize(18, 18)
    headerIcon:SetPoint("RIGHT", header, "LEFT", -3, 0)

    local forceEnglishGUI = CreateCheckbox("forceEnglishGUI", L["Force_English_GUI"], parent)
    forceEnglishGUI:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(forceEnglishGUI, L["Force_English_GUI"], L["Tooltip_Force_English_GUI_Desc"])
    forceEnglishGUI.searchExtraTerms = { "Force English GUI" }
    forceEnglishGUI:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local guiFontEnabled = CreateCheckbox("guiFontEnabled", L["Adjust_GUI_Font"], parent, nil, BBP.ApplyGuiFont)
    guiFontEnabled:SetPoint("TOPLEFT", forceEnglishGUI, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(guiFontEnabled, L["Adjust_GUI_Font"], L["Tooltip_Adjust_GUI_Font_Desc"])

    local function GuiDropdown(labelText, anchorFrame, yOffset, width)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 24, yOffset)
        label:SetText(labelText)
        local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("LEFT", label, "LEFT", 40, 0)
        dropdown:SetWidth(width)
        dropdown.label = label
        return dropdown
    end

    local guiFontDropdown = GuiDropdown(L["Font"], guiFontEnabled, -6, 150)
    guiFontDropdown:SetupMenu(function(owner, rootDescription)
        rootDescription:SetScrollMode(20 * 20)
        local function IsSelected(name) return BetterBlizzPlatesDB.guiFont == name end
        local function SetSelected(name)
            BetterBlizzPlatesDB.guiFont = name ~= "" and name or nil
            BBP.ApplyGuiFont()
        end
        rootDescription:CreateRadio(L["Dont_Change_Font"], function() return BetterBlizzPlatesDB.guiFont == nil end, SetSelected, "")
        local fonts = {}
        for fontName in pairs(LSM:HashTable(LSM.MediaType.FONT)) do
            fonts[#fonts + 1] = fontName
        end
        table.sort(fonts)
        for _, fontName in ipairs(fonts) do
            rootDescription:CreateRadio(fontName, IsSelected, SetSelected, fontName)
        end
    end)

    local guiFontSizeDropdown = GuiDropdown(L["Size"], guiFontDropdown.label, -18, 70)
    guiFontSizeDropdown:SetupMenu(function(owner, rootDescription)
        local function IsSelected(size) return (tonumber(BetterBlizzPlatesDB.guiFontSize) or 12) == size end
        local function SetSelected(size)
            BetterBlizzPlatesDB.guiFontSize = size
            BBP.ApplyGuiFont()
        end
        for size = 6, 16 do
            rootDescription:CreateRadio(tostring(size), IsSelected, SetSelected, size)
        end
    end)
    guiFontSizeDropdown.label:ClearAllPoints()
    guiFontSizeDropdown.label:SetPoint("TOPLEFT", guiFontDropdown.label, "BOTTOMLEFT", 0, -18)

    guiFontEnabled:HookScript("OnClick", function(self)
        guiFontDropdown:SetEnabled(self:GetChecked())
        guiFontSizeDropdown:SetEnabled(self:GetChecked())
    end)
    guiFontDropdown:SetEnabled(guiFontEnabled:GetChecked())
    guiFontSizeDropdown:SetEnabled(guiFontEnabled:GetChecked())

    return header
end

local function guiMisc()
    local guiMisc = CreateFrame("Frame")
    guiMisc.name = L["Module_Name_Misc"]--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiMisc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiMisc)
    local guiMiscCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiMisc, guiMisc.name)
    CreateTitle(guiMisc)

    local bgImg = guiMisc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiMisc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local settingsText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 20, -10)
    settingsText:SetText(L["Misc_Settings"])
    settingsText:SetFont(fontLarge, 16)
    settingsText:SetTextColor(1,1,1)
    local miscSettingsIcon = guiMisc:CreateTexture(nil, "ARTWORK")
    miscSettingsIcon:SetAtlas("optionsicon-brown")
    miscSettingsIcon:SetSize(22, 22)
    miscSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local showGuildNames = CreateCheckbox("showGuildNames", L["Show_Guild_Names_On_Nameplates"], guiMisc)
    showGuildNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(showGuildNames, L["Show_Guild_Names_On_Nameplates"], L["Tooltip_Show_Guild_Names_Desc"])

    local guildNameOptionsFrame
    local function OpenGuildNameOptionsWindow()
        if not guildNameOptionsFrame then
            guildNameOptionsFrame = CreateFrame("Frame", "BBPGuildNameOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
            guildNameOptionsFrame:SetSize(250, 296)
            guildNameOptionsFrame:SetPoint("CENTER")
            guildNameOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            guildNameOptionsFrame:SetFrameLevel(550)
            guildNameOptionsFrame:SetIgnoreParentAlpha(true)
            guildNameOptionsFrame:SetTitle(L["Guild_Name_Options"])
            guildNameOptionsFrame:EnableMouse(true)
            guildNameOptionsFrame:SetMovable(true)
            guildNameOptionsFrame:SetClampedToScreen(true)
            guildNameOptionsFrame:RegisterForDrag("LeftButton")
            guildNameOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            guildNameOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

            guildNameOptionsFrame.closeButton = CreateFrame("Button", nil, guildNameOptionsFrame, "UIPanelCloseButton")
            guildNameOptionsFrame.closeButton:SetFrameLevel((guildNameOptionsFrame.TitleContainer or guildNameOptionsFrame):GetFrameLevel() + 10)
            guildNameOptionsFrame.closeButton:SetPoint("TOPRIGHT", guildNameOptionsFrame, "TOPRIGHT", 0, 0)
            guildNameOptionsFrame.closeButton:SetScript("OnClick", function()
                guildNameOptionsFrame:Hide()
            end)

            guildNameOptionsFrame.bg = guildNameOptionsFrame:CreateTexture(nil, "BACKGROUND")
            guildNameOptionsFrame.bg:SetPoint("TOPLEFT", guildNameOptionsFrame, "TOPLEFT", 7, -3)
            guildNameOptionsFrame.bg:SetPoint("BOTTOMRIGHT", guildNameOptionsFrame, "BOTTOMRIGHT", -3, 3)
            guildNameOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

            local function CreateGuildNameSection(title, showKey, showLabel, scaleKey, colorKey, colorRGBKey, yOffset, isEnemy)
                local header = guildNameOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                header:SetPoint("TOPLEFT", guildNameOptionsFrame, "TOPLEFT", 42, yOffset)
                header:SetText(title)
                header:SetFont(fontLarge, 16)
                header:SetTextColor(1,1,1)
                local headerIcon = guildNameOptionsFrame:CreateTexture(nil, "ARTWORK")
                headerIcon:SetAtlas("groupfinder-icon-friend")
                headerIcon:SetSize(28, 28)
                headerIcon:SetPoint("RIGHT", header, "LEFT", -3, 0)
                if isEnemy then
                    headerIcon:SetDesaturated(1)
                    headerIcon:SetVertexColor(1, 0, 0)
                end

                local showGuild = CreateCheckbox(showKey, showLabel, guildNameOptionsFrame)
                showGuild:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -30, -2)

                local scale = CreateSlider(showGuild, L["Guild_Name_Size"], 0.2, 2, 0.01, scaleKey, nil, 150)
                scale:SetPoint("TOPLEFT", showGuild, "BOTTOMLEFT", 6, -10)

                local color = CreateCheckbox(colorKey, L["Custom_Guild_Name_Color"], showGuild)
                color:SetPoint("TOPLEFT", scale, "BOTTOMLEFT", -6, -8)
                CreateTooltip(color, L["Tooltip_Change_Guild_Name_Color_To_A"])

                local colorButton = CreateFrame("Button", nil, color, "UIPanelButtonTemplate")
                colorButton:SetText(L["Color"])
                colorButton:SetPoint("LEFT", color.text, "RIGHT", -1, 0)
                colorButton:SetSize(45, 20)
                colorButton:SetScript("OnClick", function()
                    BBP.needsUpdate = true
                    local r, g, b = unpack(BetterBlizzPlatesDB[colorRGBKey] or {1, 1, 1})
                    ColorPickerFrame:SetupColorPickerAndShow({
                        r = r, g = g, b = b,
                        hasOpacity = false,
                        swatchFunc = function()
                            local r, g, b = ColorPickerFrame:GetColorRGB()
                            BetterBlizzPlatesDB[colorRGBKey] = { r, g, b }
                            BBP.needsUpdate = true
                            BBP.RefreshAllNameplates()
                        end,
                        cancelFunc = function(previousValues)
                            BetterBlizzPlatesDB[colorRGBKey] = { previousValues.r, previousValues.g, previousValues.b }
                            BBP.needsUpdate = true
                            BBP.RefreshAllNameplates()
                        end,
                    })
                end)

                local function UpdateGuildSectionState()
                    if showGuild:GetChecked() then
                        EnableElement(scale)
                        EnableElement(color)
                        colorButton:Enable()
                    else
                        DisableElement(scale)
                        DisableElement(color)
                        colorButton:Disable()
                    end
                end
                showGuild:HookScript("OnClick", UpdateGuildSectionState)
                UpdateGuildSectionState()
            end

            CreateGuildNameSection(L["Friendly_Guild_Names"], "guildNamesFriendly", L["Show_Friendly_Guild_Names"], "guildNameScale", "guildNameColor", "guildNameColorRGB", -32)
            CreateGuildNameSection(L["Enemy_Guild_Names"], "guildNamesEnemy", L["Show_Enemy_Guild_Names"], "guildNameEnemyScale", "guildNameEnemyColor", "guildNameEnemyColorRGB", -148, true)

            local outlineLabel = guildNameOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            outlineLabel:SetPoint("TOPLEFT", guildNameOptionsFrame, "TOPLEFT", 16, -264)
            outlineLabel:SetText(L["Outline_Colon"])
            local outlineDropdown = CreateFrame("DropdownButton", nil, guildNameOptionsFrame, "WowStyle1DropdownTemplate")
            outlineDropdown:SetPoint("LEFT", outlineLabel, "RIGHT", 6, 0)
            outlineDropdown:SetWidth(140)
            outlineDropdown:SetupMenu(function(owner, rootDescription)
                local function IsSelected(value) return BetterBlizzPlatesDB.guildNameOutline == value end
                local function SetSelected(value)
                    BetterBlizzPlatesDB.guildNameOutline = value
                    BBP.needsUpdate = true
                    BBP.RefreshAllNameplates()
                end
                rootDescription:CreateRadio(L["None"], IsSelected, SetSelected, "NONE")
                rootDescription:CreateRadio(L["Outline_Label"], IsSelected, SetSelected, "OUTLINE")
                rootDescription:CreateRadio(L["Thick_Outline"], IsSelected, SetSelected, "THICKOUTLINE")
            end)

            guildNameOptionsFrame:Show()
        else
            guildNameOptionsFrame:SetShown(not guildNameOptionsFrame:IsShown())
        end
    end

    showGuildNames:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            OpenGuildNameOptionsWindow()
        end
    end)

    local showNpcTitle = CreateCheckbox("showNpcTitle", L["Show_NPC_Titles_On_Friendly_NPCs"], guiMisc)
    showNpcTitle:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showNpcTitle, L["Tooltip_Show_NPC_Titles_Under_Name_Healthbar"])

    local npcTitleScale = CreateSlider(guiMisc, L["NPC_Title_Size"], 0.2, 2, 0.01, "npcTitleScale", nil, 90)
    npcTitleScale:SetPoint("LEFT", showNpcTitle.Text, "RIGHT", 25, 0)

    local npcTitleColor = CreateCheckbox("npcTitleColor", L["Custom_NPC_Title_Color"], guiMisc)
    npcTitleColor:SetPoint("TOPLEFT", showNpcTitle, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(npcTitleColor, L["Tooltip_Change_The_NPC_Title_Color"])

    local function OpenColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.npcTitleColorRGB or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.npcTitleColorRGB = { r, g, b }
                BBP.RefreshAllNameplates()
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.npcTitleColorRGB = { r, g, b }
                BBP.RefreshAllNameplates()
            end,
        })
    end

    local npcTitleColorButton = CreateFrame("Button", nil, guiMisc, "UIPanelButtonTemplate")
    npcTitleColorButton:SetText(L["Color"])
    npcTitleColorButton:SetPoint("LEFT", npcTitleColor.text, "RIGHT", -1, 0)
    npcTitleColorButton:SetSize(45, 20)
    npcTitleColorButton:SetScript("OnClick", OpenColorPicker)

    local hideDeselectNonTargetOverlay = CreateCheckbox("hideDeselectNonTargetOverlay", L["Hide_Deselect_Overlay"], guiMisc)
    hideDeselectNonTargetOverlay:SetPoint("TOPLEFT", npcTitleColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDeselectNonTargetOverlay, L["Hide_Deselect_Overlay"], L["Tooltip_Hide_Deselect_Overlay_Desc"])
    hideDeselectNonTargetOverlay:HookScript("OnClick", function(self)
        if not self:GetChecked() then
             BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local friendIndicator = CreateCheckbox("friendIndicator", L["Friend_Guildie_Indicator"], guiMisc)
    friendIndicator:SetPoint("TOPLEFT", hideDeselectNonTargetOverlay, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendIndicator, L["Friend_Guildie_Indicator"], L["Tooltip_Friend_Guildie_Indicator_Desc"])
    friendIndicator:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            local anchorOrder = { "LEFT", "RIGHT", "TOP", "BOTTOM" }
            local current = BetterBlizzPlatesDB.friendIndicatorAnchor or "LEFT"
            local idx = 1
            for i, v in ipairs(anchorOrder) do
                if v == current then idx = i break end
            end
            idx = (idx % #anchorOrder) + 1
            BetterBlizzPlatesDB.friendIndicatorAnchor = anchorOrder[idx]
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.RefreshAllNameplates()
        end
    end)

    local friendIndicatorScale = CreateSlider(guiMisc, L["Friend_Indicator_Size"], 0.2, 2.5, 0.01, "friendIndicatorScale", nil, 90)
    friendIndicatorScale:SetPoint("LEFT", friendIndicator.Text, "RIGHT", 25, 0)

    local targetHighlightFix = CreateCheckbox("targetHighlightFix", L["TWW_Target_Highlight_Fix"], guiMisc)
    targetHighlightFix:SetPoint("TOPLEFT", friendIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetHighlightFix, L["TWW_Target_Highlight_Fix"], L["Tooltip_TWW_Target_Highlight_Fix_Desc"])

    local forceClassColors = CreateCheckbox("forceClassColors", L["Force_Class_Colors"], guiMisc)
    forceClassColors:SetPoint("TOPLEFT", targetHighlightFix, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(forceClassColors, L["Force_Class_Colors"], L["Tooltip_Force_Class_Colors_Desc"])

    local recolorTempHpLoss = CreateCheckbox("recolorTempHpLoss", L["Recolor_Temp_HP_Loss"], guiMisc)
    recolorTempHpLoss:SetPoint("TOPLEFT", forceClassColors, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(recolorTempHpLoss, L["Recolor_Temp_HP_Loss"], L["Tooltip_Recolor_Temp_HP_Loss_Desc"])

    local hideTempHpLoss = CreateCheckbox("hideTempHpLoss", L["Hide_Temp_Hp_Loss"], guiMisc)
    hideTempHpLoss:SetPoint("TOPLEFT", recolorTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTempHpLoss, L["Hide_Temp_Hp_Loss"], L["Tooltip_Hide_Temp_HP_Loss_Desc"])

    local showNameplateShadow = CreateCheckbox("showNameplateShadow", L["Nameplate_Shadow"], guiMisc)
    showNameplateShadow:SetPoint("TOPLEFT", hideTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateShadow, L["Nameplate_Shadow"], L["Tooltip_Nameplate_Shadow_Desc"])
    showNameplateShadow:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local shadowOptionsFrame = CreateFrame("Frame", "BBPNameplateShadowOptionsFrame", UIParent, "DefaultPanelFlatTemplate")
    shadowOptionsFrame.name = guiMisc.name
    shadowOptionsFrame:SetSize(250, 215)
    shadowOptionsFrame:SetPoint("CENTER")
    shadowOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    shadowOptionsFrame:SetFrameLevel(550)
    shadowOptionsFrame:SetIgnoreParentAlpha(true)
    shadowOptionsFrame:SetTitle(L["Nameplate_Shadow"])
    shadowOptionsFrame:EnableMouse(true)
    shadowOptionsFrame:SetMovable(true)
    shadowOptionsFrame:SetClampedToScreen(true)
    shadowOptionsFrame:RegisterForDrag("LeftButton")
    shadowOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    shadowOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    shadowOptionsFrame:Hide()

    shadowOptionsFrame.closeButton = CreateFrame("Button", nil, shadowOptionsFrame, "UIPanelCloseButton")
    shadowOptionsFrame.closeButton:SetFrameLevel((shadowOptionsFrame.TitleContainer or shadowOptionsFrame):GetFrameLevel() + 10)
    shadowOptionsFrame.closeButton:SetPoint("TOPRIGHT", shadowOptionsFrame, "TOPRIGHT", 0, 0)
    shadowOptionsFrame.closeButton:SetScript("OnClick", function()
        shadowOptionsFrame:Hide()
    end)

    shadowOptionsFrame.bg = shadowOptionsFrame:CreateTexture(nil, "BACKGROUND")
    shadowOptionsFrame.bg:SetPoint("TOPLEFT", shadowOptionsFrame, "TOPLEFT", 7, -3)
    shadowOptionsFrame.bg:SetPoint("BOTTOMRIGHT", shadowOptionsFrame, "BOTTOMRIGHT", -3, 3)
    shadowOptionsFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    guiMisc:HookScript("OnHide", function()
        shadowOptionsFrame:Hide()
    end)

    showNameplateShadow:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            shadowOptionsFrame:SetShown(not shadowOptionsFrame:IsShown())
        end
    end)

    local nameplateShadowColor = CreateColorBox(shadowOptionsFrame, "nameplateShadowRGB", L["Shadow_Color"], BBP.RefreshAllNameplates)
    nameplateShadowColor:SetPoint("TOPLEFT", shadowOptionsFrame, "TOPLEFT", 14, -30)

    local highlightNpShadowOnMouseover = CreateCheckbox("highlightNpShadowOnMouseover", L["Highlight_Mouseover"], shadowOptionsFrame)
    highlightNpShadowOnMouseover:SetPoint("TOPLEFT", nameplateShadowColor, "BOTTOMLEFT", -4, -4)
    CreateTooltipTwo(highlightNpShadowOnMouseover, L["Highlight_Shadow_On_Mouseover"], L["Tooltip_Highlight_Shadow_On_Mouseover_Desc"])
    highlightNpShadowOnMouseover:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)
    highlightNpShadowOnMouseover:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.nameplateShadowHighlightRGB, BBP.RefreshAllNameplates)
        end
    end)

    local nameplateShadowHighlightColor = CreateColorBox(shadowOptionsFrame, "nameplateShadowHighlightRGB", L["Highlight_Color"], BBP.RefreshAllNameplates)
    nameplateShadowHighlightColor:SetPoint("TOPLEFT", highlightNpShadowOnMouseover, "BOTTOMLEFT", 22, 2)

    local onlyShowHighlightedNpShadow = CreateCheckbox("onlyShowHighlightedNpShadow", L["Highlighted_Only"], shadowOptionsFrame)
    onlyShowHighlightedNpShadow:SetPoint("TOPLEFT", nameplateShadowHighlightColor, "BOTTOMLEFT", -22, -2)
    CreateTooltipTwo(onlyShowHighlightedNpShadow, L["Highlighted_Only"], L["Tooltip_Highlighted_Only_Desc"])
    onlyShowHighlightedNpShadow:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local keepNpShadowTargetHighlighted = CreateCheckbox("keepNpShadowTargetHighlighted", L["Keep_Target_Highlighted"], shadowOptionsFrame)
    keepNpShadowTargetHighlighted:SetPoint("TOPLEFT", onlyShowHighlightedNpShadow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(keepNpShadowTargetHighlighted, L["Keep_Target_Highlighted"], L["Tooltip_Keep_Target_Highlighted_Desc"])
    keepNpShadowTargetHighlighted:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local showNameplateShadowClassColor = CreateCheckbox("showNameplateShadowClassColor", L["Class_Color"], shadowOptionsFrame)
    showNameplateShadowClassColor:SetPoint("TOPLEFT", keepNpShadowTargetHighlighted, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateShadowClassColor, L["Class_Color"], L["Tooltip_Class_Color_Combo_Desc"])

    local showNameplateShadowOnlyTarget = CreateCheckbox("showNameplateShadowOnlyTarget", L["Target_Only"], shadowOptionsFrame)
    showNameplateShadowOnlyTarget:SetPoint("TOPLEFT", showNameplateShadowClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateShadowOnlyTarget, L["Target_Only"], L["Tooltip_Target_Only_Desc_2"])

    local anonMode = CreateCheckbox("anonMode", L["Anon_Mode"], guiMisc)
    anonMode:SetPoint("TOPLEFT", showNameplateShadow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anonMode, L["Tooltip_Changes_The_Names_Of_Players_To"])

    local pvpTitleMode = CreateCheckbox("pvpTitleMode", L["PVP_Title"], guiMisc)
    pvpTitleMode:SetPoint("LEFT", anonMode.text, "RIGHT", 5, 0)
    CreateTooltipTwo(pvpTitleMode, L["Changes_The_Names_Of_Players_To_Include_Their"])

    local skipAdjustingFixedFonts = CreateCheckbox("skipAdjustingFixedFonts", L["Skip_Adjusting_Nameplate_Fonts"], guiMisc)
    skipAdjustingFixedFonts:SetPoint("TOPLEFT", anonMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(skipAdjustingFixedFonts, L["Skip_Adjusting_Nameplate_Fonts"], L["Tooltip_Skip_Adjusting_Nameplate_Fonts_Desc"], L["Tooltip_Skip_Adjusting_Nameplate_Fonts_SubText"])
    skipAdjustingFixedFonts:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local toggleNamesOffDuringPVE = CreateCheckbox("toggleNamesOffDuringPVE", L["Toggle_Friendly_Player_Name"], guiMisc)
    toggleNamesOffDuringPVE:SetPoint("TOPLEFT", skipAdjustingFixedFonts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(toggleNamesOffDuringPVE, L["Tooltip_Toggle_Friendly_Player_Names_On_Nameplate"])

    local doNotHideFriendlyHealthbarInPve = CreateCheckbox("doNotHideFriendlyHealthbarInPve", L["Dont_Hide_Friendly_Healthbars_In_PvE"], guiMisc)
    doNotHideFriendlyHealthbarInPve:SetPoint("TOPLEFT", toggleNamesOffDuringPVE, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(doNotHideFriendlyHealthbarInPve, L["Dont_Hide_Friendly_Healthbar"], L["Tooltip_Dont_Hide_Friendly_Healthbar_Desc"])

    local showLastNameNpc = CreateCheckbox("showLastNameNpc", L["Tooltip_Only_Last_Name_NPCs_Desc"], guiMisc)
    showLastNameNpc:SetPoint("TOPLEFT", doNotHideFriendlyHealthbarInPve, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showLastNameNpc, L["Tooltip_Only_Last_Name_NPCs_Desc"], L["Tooltip_Only_Last_Name_NPCs_Simple_Desc"])

    local scaleNpNameWithParent = CreateCheckbox("scaleNpNameWithParent", L["Scale_Names_With_The_Nameplate"], guiMisc)
    scaleNpNameWithParent:SetPoint("TOPLEFT", showLastNameNpc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(scaleNpNameWithParent, L["Scale_Names_With_The_Nameplate"], L["Tooltip_Scale_Names_With_The_Nameplate_Desc"])

    local prdLegacyLook = CreateCheckbox("prdLegacyLook", L["PRD_Legacy_Look"], guiMisc)
    prdLegacyLook:SetPoint("TOPLEFT", scaleNpNameWithParent, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(prdLegacyLook, L["Tooltip_PRD_Legacy_Look"], L["Tooltip_PRD_Legacy_Look_Desc"])

    local prdSplitLines = CreateCheckbox("prdSplitLines", L["PRD_Split_Lines"], prdLegacyLook, nil, BBP.LegacyPRDLook)
    prdSplitLines:SetPoint("LEFT", prdLegacyLook.text, "RIGHT", 0, 0)
    CreateTooltipTwo(prdSplitLines, L["Tooltip_PRD_Split_Lines"], L["Tooltip_PRD_Split_Lines_Desc"])

    prdLegacyLook:HookScript("OnClick", function(self)
        BBP.LegacyPRDLook()
        BBP.TexturePRD()
        if self:GetChecked() then
            EnableElement(prdSplitLines)
        else
            DisableElement(prdSplitLines)
        end
    end)

    local fancyPrdAltTexture = CreateCheckbox("fancyPrdAltTexture", L["PRD_Fancy_Alt_Power_Texture"], guiMisc)
    fancyPrdAltTexture:SetPoint("TOPLEFT", prdLegacyLook, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fancyPrdAltTexture, L["PRD_Fancy_Alt_Power_Texture"], L["Tooltip_PRD_Fancy_Alt_Power_Texture_Desc"])


    -- local nameplateResourceText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- nameplateResourceText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 45, -250)
    -- nameplateResourceText:SetText("Nameplate Resource")

    -- local nameplateSelfWidth = CreateSlider(guiMisc, "Personal Nameplate Width", 50, 200, 1, "nameplateSelfWidth")
    -- nameplateSelfWidth:SetPoint("TOPLEFT", scaleNpNameWithParent, "BOTTOMLEFT", 10, -20)

    -- local hidePersonalBarManaFrame = CreateCheckbox("hidePersonalBarManaFrame", "Hide Personal Manabar", guiMisc, nil, BBP.PersonalBarSettings)
    -- hidePersonalBarManaFrame:SetPoint("TOPLEFT", scaleNpNameWithParent, "BOTTOMLEFT", 0, -60)
    -- CreateTooltipTwo(hidePersonalBarManaFrame, "Hide Personal Manabar", "Hide the manabar on personal resource.")

    -- local hidePersonalBarExtraFrame = CreateCheckbox("hidePersonalBarExtraFrame", "Hide Extra Personal Bar", guiMisc, nil, BBP.PersonalBarSettings)
    -- hidePersonalBarExtraFrame:SetPoint("LEFT", hidePersonalBarManaFrame.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePersonalBarExtraFrame, "Hide Extra Personal Bar", "Hide the extra bar on personal resource for Ebon/Stagger.")

    local changeHealthbarHeight = CreateCheckbox("changeHealthbarHeight", L["Separate_Friendly_Enemy_Nameplate_Height"], guiMisc)
    changeHealthbarHeight:SetPoint("TOPLEFT", fancyPrdAltTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(changeHealthbarHeight, L["Separate_Nameplate_Heights"], L["Tooltip_Separate_Nameplate_Heights_Desc"])

    local hpHeightEnemy = CreateSlider(changeHealthbarHeight, L["Enemy_Height"], 1, 35, 0.1, "hpHeightEnemy")
    hpHeightEnemy:SetPoint("TOPLEFT", changeHealthbarHeight, "BOTTOMLEFT", 10, -10)
    CreateTooltipTwo(hpHeightEnemy, L["Enemy_Height"], L["Tooltip_Enemy_Height_Desc"])
    local hpHeightEnemyReset = CreateResetButton(hpHeightEnemy, "hpHeightEnemy", guiMisc)
    CreateTooltipTwo(hpHeightEnemyReset, L["Reset_To_Default"], L["Tooltip_Reset_To_Default_Desc"])

    local hpHeightFriendly = CreateSlider(changeHealthbarHeight, L["Friendly_Height"], 1, 35, 0.1, "hpHeightFriendly")
    hpHeightFriendly:SetPoint("TOPLEFT", hpHeightEnemy, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(hpHeightFriendly, L["Friendly_Height"], L["Tooltip_Friendly_Height_Desc"])
    local hpHeightFriendlyReset = CreateResetButton(hpHeightFriendly, "hpHeightFriendly", guiMisc)
    CreateTooltipTwo(hpHeightFriendlyReset, L["Reset_To_Default"], L["Tooltip_Reset_To_Default_Desc"])

    CreateGuiFontSection(guiMisc, hpHeightFriendly)

    -- local hpHeightSelf = CreateSlider(changeHealthbarHeight, "Personal Height", 1, 35, 0.1, "hpHeightSelf")
    -- hpHeightSelf:SetPoint("TOPLEFT", hpHeightFriendly, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(hpHeightSelf, "Personal Height", "The height for Personal Resource Healthbar.")
    -- local hpHeightSelfReset = CreateResetButton(hpHeightSelf, "hpHeightSelf", guiMisc)
    -- CreateTooltipTwo(hpHeightSelfReset, "Reset to default", "Default is 4 * NamePlateVerticalScale")

    -- local hpHeightSelfMana = CreateSlider(changeHealthbarHeight, "Personal Mana Height", 1, 35, 0.1, "hpHeightSelfMana")
    -- hpHeightSelfMana:SetPoint("TOPLEFT", hpHeightSelf, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(hpHeightSelfMana, "Friendly Height", "The height Personal Resource Manabar.")
    -- local hpHeightSelfManaReset = CreateResetButton(hpHeightSelfMana, "hpHeightSelfMana", guiMisc)
    -- CreateTooltipTwo(hpHeightSelfManaReset, "Reset to default", "Default is 4 * NamePlateVerticalScale")

    changeHealthbarHeight:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.HookHealthbarHeight()
            EnableElement(hpHeightEnemy)
            EnableElement(hpHeightFriendly)
            -- EnableElement(hpHeightSelf)
            -- EnableElement(hpHeightSelfMana)
        else
            DisableElement(hpHeightEnemy)
            DisableElement(hpHeightFriendly)
            -- DisableElement(hpHeightSelf)
            -- DisableElement(hpHeightSelfMana)
        end
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local changeNameplateBorderSize = CreateCheckbox("changeNameplateBorderSize", L["Change_Nameplate_Border_Size"], guiMisc)
    changeNameplateBorderSize:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 400, 39)
    local nameplateBorderSize = CreateSlider(changeNameplateBorderSize, L["Nameplate_Border_Size"], 0.5, 10, 0.5, "nameplateBorderSize")
    nameplateBorderSize:SetPoint("TOPLEFT", changeNameplateBorderSize, "BOTTOMLEFT", 10, -10)
    local nameplateTargetBorderSize = CreateSlider(changeNameplateBorderSize, L["Target_Border_Size"], 0.5, 10, 0.5, "nameplateTargetBorderSize")
    nameplateTargetBorderSize:SetPoint("TOPLEFT", nameplateBorderSize, "BOTTOMLEFT", 0, -17)
    local nameplatePersonalBorderSize = CreateSlider(changeNameplateBorderSize, L["Personal_Border_Size"], 0.5, 10, 0.5, "nameplatePersonalBorderSize")
    nameplatePersonalBorderSize:SetPoint("TOPLEFT", nameplateTargetBorderSize, "BOTTOMLEFT", 0, -17)



    CreateTooltipTwo(nameplateBorderSize, L["Nameplate_Border_Size"], L["Tooltip_Nameplate_Border_Size_Desc"])
    changeNameplateBorderSize:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(nameplateBorderSize)
            EnableElement(nameplateTargetBorderSize)
            EnableElement(nameplatePersonalBorderSize)
        else
            DisableElement(nameplateBorderSize)
            DisableElement(nameplateTargetBorderSize)
            DisableElement(nameplatePersonalBorderSize)
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)


    local hidePersonalManaFX = CreateCheckbox("hidePersonalManaFX", L["Hide_Personal_Resource_Manabar_FX"], guiMisc, nil, BBP.HidePersonalManabarFX)
    hidePersonalManaFX:SetPoint("BOTTOMLEFT", changeNameplateBorderSize, "BOTTOMLEFT", 0, 20)
    CreateTooltipTwo(hidePersonalManaFX, L["Hide_Personal_Manabar_FX"], L["Tooltip_Hide_Personal_Manabar_FX_Desc"])
    hidePersonalManaFX:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local changeNameplateBorderColor = CreateCheckbox("changeNameplateBorderColor", L["Change_Nameplate_Border_Color"], guiMisc)
    changeNameplateBorderColor:SetPoint("TOPLEFT", nameplatePersonalBorderSize, "BOTTOMLEFT", -10, -2)

    local npTargetHighlightBorder = CreateCheckbox("npTargetHighlightBorder", L["Target_Highlight_Border"], changeNameplateBorderColor)
    npTargetHighlightBorder:SetPoint("TOPLEFT", changeNameplateBorderColor, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltipTwo(npTargetHighlightBorder, L["Target_Highlight_Border"], L["Tooltip_Target_Highlight_Border_Desc"])

    local npTargetHighlightTargetRGB = CreateColorBox(npTargetHighlightBorder, "npTargetHighlightTargetRGB", L["Target"], BBP.RefreshAllNameplates)
    npTargetHighlightTargetRGB:SetPoint("TOPLEFT", npTargetHighlightBorder, "BOTTOMLEFT", 15, 0)

    local npTargetHighlightFocusRGB = CreateColorBox(npTargetHighlightBorder, "npTargetHighlightFocusRGB", L["Focus"], BBP.RefreshAllNameplates)
    npTargetHighlightFocusRGB:SetPoint("TOPLEFT", npTargetHighlightTargetRGB, "BOTTOMLEFT", 0, -2)

    npTargetHighlightBorder:HookScript("OnClick", function(self)
        npTargetHighlightTargetRGB:SetAlpha(self:GetChecked() and 1 or 0.5)
        npTargetHighlightFocusRGB:SetAlpha(self:GetChecked() and 1 or 0.5)
        if self:GetChecked() then
            BBP.TurnOnFocusBorderColor()
        end
    end)

    local npBorderTargetColor = CreateCheckbox("npBorderTargetColor", L["Target_Border"], changeNameplateBorderColor)
    npBorderTargetColor:SetPoint("TOPLEFT", npTargetHighlightFocusRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltip(npBorderTargetColor, L["Tooltip_Enable_To_Change_The_Color_Of"])

    local npBorderTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderTargetColorRGB", L["Target_Border"])
    npBorderTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColor, "BOTTOMLEFT", 15, 0)

    local npBorderNonTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderNonTargetColorRGB", L["Non_Target_Border"])
    npBorderNonTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColorRGB, "BOTTOMLEFT", 0, -2)

    local npBorderFocusColorRGB = CreateColorBox(npBorderTargetColor, "npBorderFocusColorRGB", L["Focus_Border"])
    npBorderFocusColorRGB:SetPoint("TOPLEFT", npBorderNonTargetColorRGB, "BOTTOMLEFT", 0, -2)

    npBorderTargetColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBorderTargetColorRGB:SetAlpha(1)
            npBorderNonTargetColorRGB:SetAlpha(1)
            npBorderFocusColorRGB:SetAlpha(1)
        else
            npBorderTargetColorRGB:SetAlpha(0.5)
            npBorderNonTargetColorRGB:SetAlpha(0.5)
            npBorderFocusColorRGB:SetAlpha(0.5)
        end
        BBP.TurnOnFocusBorderColor()
    end)

    local npBorderFriendFoeColor = CreateCheckbox("npBorderFriendFoeColor", L["Reaction_Color_Border"], changeNameplateBorderColor)
    npBorderFriendFoeColor:SetPoint("TOPLEFT", npBorderFocusColorRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltip(npBorderFriendFoeColor, L["Tooltip_Enable_To_Change_The_Color_Of_2"])

    local npBorderEnemyColorRGB = CreateColorBox(npBorderFriendFoeColor, "npBorderEnemyColorRGB", L["Enemy_Border"])
    npBorderEnemyColorRGB:SetPoint("TOPLEFT", npBorderFriendFoeColor, "BOTTOMLEFT", 15, 0)

    local npBorderFriendlyColorRGB = CreateColorBox(npBorderFriendFoeColor, "npBorderFriendlyColorRGB", L["Friendly_Border"])
    npBorderFriendlyColorRGB:SetPoint("TOPLEFT", npBorderEnemyColorRGB, "BOTTOMLEFT", 0, -2)

    local npBorderNeutralColorRGB = CreateColorBox(npBorderFriendFoeColor, "npBorderNeutralColorRGB", L["Neutral_Border"])
    npBorderNeutralColorRGB:SetPoint("TOPLEFT", npBorderFriendlyColorRGB, "BOTTOMLEFT", 0, -2)

    npBorderFriendFoeColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBorderEnemyColorRGB:SetAlpha(1)
            npBorderFriendlyColorRGB:SetAlpha(1)
            npBorderNeutralColorRGB:SetAlpha(1)
        else
            npBorderEnemyColorRGB:SetAlpha(0.5)
            npBorderFriendlyColorRGB:SetAlpha(0.5)
            npBorderNeutralColorRGB:SetAlpha(0.5)
        end
    end)

    local npBorderClassColor = CreateCheckbox("npBorderClassColor", L["Class_Color_Border"], changeNameplateBorderColor)
    npBorderClassColor:SetPoint("TOPLEFT", npBorderNeutralColorRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltip(npBorderClassColor, L["Tooltip_Enable_To_Change_The_Color_Of_3"])

    local npBorderNpcColorRGB = CreateColorBox(npBorderClassColor, "npBorderNpcColorRGB", L["NPC_Border"])
    npBorderNpcColorRGB:SetPoint("TOPLEFT", npBorderClassColor, "BOTTOMLEFT", 15, 0)

    npBorderClassColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBorderNpcColorRGB:SetAlpha(1)
        else
            npBorderNpcColorRGB:SetAlpha(0.5)
        end
    end)

    changeNameplateBorderColor:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(changeNameplateBorderColor)
        CheckAndToggleCheckboxes(npTargetHighlightBorder)
        CheckAndToggleCheckboxes(npBorderTargetColor)
        CheckAndToggleCheckboxes(npBorderFriendFoeColor)
        CheckAndToggleCheckboxes(npBorderClassColor)
    end)

    local changeNpHpBgColor = CreateCheckbox("changeNpHpBgColor", L["Change_Nameplate_Background_Color"], guiMisc)
    changeNpHpBgColor:SetPoint("TOPLEFT", npBorderNpcColorRGB, "BOTTOMLEFT", -30, 0)
    CreateTooltipTwo(changeNpHpBgColor, L["Nameplate_Background_Color"], L["Tooltip_Nameplate_Background_Color_Desc"])

    local npBgColorRGB = CreateColorBox(changeNpHpBgColor, "npBgColorRGB", L["Background_Color"])
    npBgColorRGB:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 15, 0)

    changeNpHpBgColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBgColorRGB:SetAlpha(1)
        else
            npBgColorRGB:SetAlpha(0.5)
        end
    end)

    local customFontSizeEnabled = CreateCheckbox("customFontSizeEnabled", L["Enable_Custom_Nameplate_Font_Size"], guiMisc)
    customFontSizeEnabled:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 0, -22)
    CreateTooltipTwo(customFontSizeEnabled, L["Custom_Nameplate_Font_Size"], L["Tooltip_Custom_Nameplate_Font_Size_Desc"], L["Tooltip_Custom_Nameplate_Font_Size_SubText"])

    local customFontSize = CreateSlider(customFontSizeEnabled, L["Font_Size"], 2, 32, 1, "customFontSize")
    customFontSize:SetPoint("TOPLEFT", customFontSizeEnabled, "BOTTOMLEFT", 10, -10)

    customFontSizeEnabled:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(customFontSize)
        else
            DisableElement(customFontSize)
        end
    end)


    local personalNpTRP3Color = CreateCheckbox("personalNpTRP3Color", L["TRP3_Personal_Bar_Color"], guiMisc)
    personalNpTRP3Color:SetPoint("TOPLEFT", customFontSizeEnabled, "BOTTOMLEFT", -160, -59)
    CreateTooltipTwo(personalNpTRP3Color, L["TRP3_Personal_Bar_Color"], L["Tooltip_TRP3_Personal_Bar_Color_Desc"])

    local personalBarTweaks = CreateCheckbox("personalBarTweaks", L["Personal_Bar_Tweaks"], guiMisc)
    personalBarTweaks:SetPoint("TOPLEFT", personalNpTRP3Color, "BOTTOMLEFT", 0, 6)
    CreateTooltipTwo(personalBarTweaks, L["Personal_Bar_Tweaks"], L["Tooltip_Personal_Bar_Tweaks_Desc"])





    -- local nameplateSelfWidthResetButton = CreateFrame("Button", nil, guiMisc, "UIPanelButtonTemplate")
    -- nameplateSelfWidthResetButton:SetText("Default")
    -- nameplateSelfWidthResetButton:SetWidth(60)
    -- nameplateSelfWidthResetButton:SetPoint("LEFT", nameplateSelfWidth, "RIGHT", 10, 0)
    -- nameplateSelfWidthResetButton:SetScript("OnClick", function()
    --     BBP.ResetToDefaultWidth(nameplateSelfWidth, false, true)
    -- end)
end

local function guiImportAndExport()
    local guiImportAndExport = CreateFrame("Frame")
    guiImportAndExport.name = L["Module_Name_Import_Export"]--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiImportAndExport.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiImportAndExport)
    local guiImportAndExportCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiImportAndExport, guiImportAndExport.name)
    CreateTitle(guiImportAndExport)

    local bgImg = guiImportAndExport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiImportAndExport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local text = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text:SetText("")
    text:SetPoint("TOP", guiImportAndExport, "TOPRIGHT", -220, 0)

    local profilesBtn = CreateFrame("Button", nil, guiImportAndExport, "GameMenuButtonTemplate")
    profilesBtn:SetSize(150, 25)
    profilesBtn:SetText(L["Label_Profiles_Selection"])
    profilesBtn:SetPoint("TOP", text, "BOTTOM", 0, -25)
    profilesBtn:SetScale(1.3)
    profilesBtn:SetNormalFontObject("GameFontNormal")
    profilesBtn:SetHighlightFontObject("GameFontHighlight")
    profilesBtn:SetScript("OnClick", function()
        BBP.CreateIntroMessageWindow()
    end)
    CreateTooltipTwo(profilesBtn, L["Tooltip_Profiles_Title"], L["Tooltip_Profiles_Desc"], nil, "ANCHOR_TOP")


    local fullProfile = CreateImportExportUI(guiImportAndExport, L["Full_Profile"], BetterBlizzPlatesDB, 20, -20, "fullProfile")

    local auraWhitelist = CreateImportExportUI(fullProfile, L["Aura_Whitelist"], BetterBlizzPlatesDB.auraWhitelist, 0, -100, "auraWhitelist")
    local auraBlacklist = CreateImportExportUI(auraWhitelist, L["Aura_Blacklist"], BetterBlizzPlatesDB.auraBlacklist, 210, 0, "auraBlacklist")

    -- local totemIndicatorList = CreateImportExportUI(auraWhitelist, "Totem Indicator List", BetterBlizzPlatesDB.totemIndicatorNpcList, 0, -100, "totemIndicatorNpcList")

    -- local fadeOutNPCsList = CreateImportExportUI(totemIndicatorList, "Fade NPC List", BetterBlizzPlatesDB.fadeOutNPCsList, 0, -100, "fadeOutNPCsList")
    -- local hideNpcList = CreateImportExportUI(fadeOutNPCsList, "Hide NPC Blacklist", BetterBlizzPlatesDB.hideNPCsList, 210, 0, "hideNPCsList")
    -- local hideNPCsWhitelist = CreateImportExportUI(hideNpcList, "Hide NPC Whitelist", BetterBlizzPlatesDB.hideNPCsWhitelist, 210, 0, "hideNPCsWhitelist")

    -- local castEmphasisList = CreateImportExportUI(fadeOutNPCsList, "Cast Emphasis List", BetterBlizzPlatesDB.castEmphasisList, 0, -100, "castEmphasisList")
    -- local hideCastbarList = CreateImportExportUI(castEmphasisList, "Hide Castbar Blacklist", BetterBlizzPlatesDB.hideCastbarList, 210, 0, "hideCastbarList")
    -- local hideCastbarWhitelist = CreateImportExportUI(hideCastbarList, "Hide Castbar Whitelist", BetterBlizzPlatesDB.hideCastbarWhitelist, 210, 0, "hideCastbarWhitelist")

    -- local auraColorList = CreateImportExportUI(castEmphasisList, "Color by Aura List", BetterBlizzPlatesDB.auraColorList, 210, 0, "auraColorList")

    -- local text2 = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- text2:SetText("Color NPC & Cast Emphasis now supports\nPlater NPC Color & Plater Cast Color import.")
    -- text2:SetPoint("LEFT", totemIndicatorList, "RIGHT", 60, 0)
end

local function guiSupport()
    local guiSupport = CreateFrame("Frame")
    guiSupport.name = "|A:GarrisonTroops-Health:10:10|a " .. L["Module_Name_Support"]
    guiSupport.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiSupport)
    local guiSupportCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiSupport, guiSupport.name)
    BBP.guiSupport = guiSupport.name
    BBP.category.guiSupportCategory = guiSupportCategory.ID
    CreateTitle(guiSupport)

    local bgImg = guiSupport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiSupport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local discordLinkEditBox = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    discordLinkEditBox:SetPoint("TOP", guiSupport, "TOP", 0, -170)
    discordLinkEditBox:SetSize(180, 20)
    discordLinkEditBox:SetAutoFocus(false)
    discordLinkEditBox:SetFontObject("ChatFontNormal")
    discordLinkEditBox:SetText("https://discord.gg/cjqVaEMm25")
    discordLinkEditBox:SetCursorPosition(0) -- Places cursor at start of the text
    discordLinkEditBox:ClearFocus() -- Removes focus from the EditBox
    discordLinkEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    discordLinkEditBox:SetScript("OnTextChanged", function(self)
        self:SetText("https://discord.gg/cjqVaEMm25")
    end)
    --discordLinkEditBox:HighlightText() -- Highlights the text for easy copying
    discordLinkEditBox:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    discordLinkEditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    discordLinkEditBox:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local discordText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    discordText:SetPoint("BOTTOM", discordLinkEditBox, "TOP", 18, 8)
    discordText:SetText(L["Discord_Text"])

    local joinDiscord = guiSupport:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local supportText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportText:SetPoint("TOP", guiSupport, "TOP", 0, -230)
    supportText:SetText(L["Support_Text"] .. " |A:GarrisonTroops-Health:10:10|a")

    local boxOne = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxOne:SetPoint("TOP", guiSupport, "TOP", -110, -360)
    boxOne:SetSize(180, 20)
    boxOne:SetAutoFocus(false)
    boxOne:SetFontObject("ChatFontNormal")
    boxOne:SetText("https://patreon.com/bodifydev")
    boxOne:SetCursorPosition(0) -- Places cursor at start of the text
    boxOne:ClearFocus() -- Removes focus from the EditBox
    boxOne:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    boxOne:SetScript("OnTextChanged", function(self)
        self:SetText("https://patreon.com/bodifydev")
    end)
    --boxOne:HighlightText() -- Highlights the text for easy copying
    boxOne:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    boxOne:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    boxOne:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxOneTex = guiSupport:CreateTexture(nil, "ARTWORK")
    boxOneTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\patreon.tga")
    boxOneTex:SetSize(58, 58)
    boxOneTex:SetPoint("BOTTOM", boxOne, "TOP", 0, 1)

    local boxTwo = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxTwo:SetPoint("TOP", guiSupport, "TOP", 110, -360)
    boxTwo:SetSize(180, 20)
    boxTwo:SetAutoFocus(false)
    boxTwo:SetFontObject("ChatFontNormal")
    boxTwo:SetText("https://paypal.me/bodifydev")
    boxTwo:SetCursorPosition(0) -- Places cursor at start of the text
    boxTwo:ClearFocus() -- Removes focus from the EditBox
    boxTwo:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    boxTwo:SetScript("OnTextChanged", function(self)
        self:SetText("https://paypal.me/bodifydev")
    end)
    --boxTwo:HighlightText() -- Highlights the text for easy copying
    boxTwo:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    boxTwo:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    boxTwo:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxTwoTex = guiSupport:CreateTexture(nil, "ARTWORK")
    boxTwoTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\paypal.tga")
    boxTwoTex:SetSize(58, 58)
    boxTwoTex:SetPoint("BOTTOM", boxTwo, "TOP", 0, 1)
end

------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
local function CombatOnGUICreation()
    if InCombatLockdown() then
        BBP.Print(L["Print_Waiting_For_Combat"])
        if not BBP.waitingCombat then
            local f = CreateFrame("Frame")
            f:RegisterEvent("PLAYER_REGEN_ENABLED")
            f:SetScript("OnEvent", function(self)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                BBP.LoadGUI()
            end)
            BBP.waitingCombat = true
        end
        return true
    end
end

function BBP.InitializeOptions()
    if not BetterBlizzPlates then
        BetterBlizzPlates = CreateFrame("Frame")
        BetterBlizzPlates.name = "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a"
        --InterfaceOptions_AddCategory(BetterBlizzPlates)
        BBP.category = Settings.RegisterCanvasLayoutCategory(BetterBlizzPlates, BetterBlizzPlates.name)
        Settings.RegisterAddOnCategory(BBP.category)

        local titleText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFont_Gigantic")
        titleText:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -15, 33)
        titleText:SetText("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates")
        BetterBlizzPlates.titleText = titleText

        local loadGUI = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
        loadGUI:SetText(L["Load_Settings"])
        loadGUI:SetWidth(100)
        loadGUI:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -18, 6)
        BetterBlizzPlates.loadGUI = loadGUI
        loadGUI:SetScript("OnClick", function(self)
            if CombatOnGUICreation() then return end
            BBP.LoadGUI()
            titleText:Hide()
            self:Hide()
        end)
    end
end

function BBP.LoadGUI()
    -- First time opening settings
    if BetterBlizzPlatesDB.hasNotOpenedSettings then
        BBP.CreateIntroMessageWindow()
        BetterBlizzPlatesDB.hasNotOpenedSettings = nil
        return
    end

    if CombatOnGUICreation() then return end

    if BetterBlizzPlates.guiLoaded then
        Settings.OpenToCategory(BBP.category:GetID())
        return
    end

    guiGeneralTab()
    guiForever()
    guiPositionAndScale()
    guiCastbar()
    guiClickingAndStacking()
    --guiHideCastbar()
    --guiFadeNPC()
    --guiHideNPC()
    guiColorNPC()
    --guiAuraColor()
    guiNameplateAuras()
    guiCVarControl()
    guiMisc()
    guiImportAndExport()
    --guiTotemList()
    guiSupport()
    BetterBlizzPlates.guiLoaded = true

    if SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end
    Settings.OpenToCategory(BBP.category:GetID())
    Settings.OpenToCategory(BBP.category:GetID())
end



-- function CustomSetInset(nameplateType, left, right, top, bottom)
--     if not InCombatLockdown() then
--         if nameplateType == "friendly" then
--             C_NamePlate.SetNamePlateFriendlyPreferredClickInsets (left or 0, right or 0, top or 0, bottom or 0)
--         elseif nameplateType == "enemy" then
--             C_NamePlate.SetNamePlateEnemyPreferredClickInsets (left or 0, right or 0, top or 0, bottom or 0)
--         elseif nameplateType == "player" then
--             C_NamePlate.SetNamePlateSelfPreferredClickInsets (left or 0, right or 0, top or 0, bottom or 0)
--         end
--     else
--         C_Timer.After(1, function() CustomSetInset(nameplateType, left, right, top, bottom) end)
--     end
-- end
-- hooksecurefunc(NamePlateDriverFrame.namePlateSetInsetFunctions, "friendly", function()
--     --C_NamePlate.SetNamePlateFriendlyPreferredClickInsets (0, 0, 0, 0)
--     CustomSetInset("friendly", 0, 0, 0, 0)
-- end)
-- hooksecurefunc(NamePlateDriverFrame.namePlateSetInsetFunctions, "enemy", function()
--     --C_NamePlate.SetNamePlateEnemyPreferredClickInsets (0, 0, 0, 0)
--     CustomSetInset("enemy", 0, 0, 0, 0)
-- end)




-- local slider = CreateFrame("Frame", "BBPslidus", UIParent, "MinimalSliderWithSteppersTemplate")
-- slider:RegisterCallback("OnValueChanged", function()
--     slider.TopText:SetText("Nameplate Size: " .. slider.Slider:GetValue())
-- end)
-- slider.TopText:Show()
-- slider:Init(2, 1, 5, 4/1)
-- slider.MinText:SetText("asd")
-- slider.MinText:Show()
-- slider.TopText:SetText("Nameplate Size: " .. slider.Slider:GetValue())
-- slider:SetPoint("CENTER", UIParent)

-- slider.LeftText:SetText("left")
-- slider.LeftText:Show()

-- slider.RightText:SetText("right")
-- slider.RightText:Show()

-- slider.MaxText:SetText("Max")
-- slider.MaxText:Show()

function BBP.CVarTracker()
    if BBP.cvarTrackerRegistered then return end
    BBP.cvarTrackerRegistered = true

    local cvarsToTrack = {
        checkboxes = {
            nameplateResourceOnTarget = true,
            nameplateShowAll = true,
            nameplateShowClassColor = true,
            nameplateShowFriendlyClassColor = true,
        },
        sliders = {
            nameplateOverlapH = true,
            nameplateOverlapV = true,
            nameplateMotionSpeed = true,
            nameplateMinAlpha = true,
            nameplateMinAlphaDistance = true,
            nameplateMaxAlpha = true,
            nameplateMaxAlphaDistance = true,
            nameplateOccludedAlphaMult = true,
            -- Midnight
            nameplateAuraScale = true,
            nameplateDebuffPadding = true,
            nameplateSimplifiedScale = true,
        },
        other = {
            nameplateStyle = true,
        }
    }

    local bitCVarNames = {}
    if BBP.bitCVarList then
        for cvarName, _ in pairs(BBP.bitCVarList) do
            bitCVarNames[cvarName] = true
        end
    end

    local pickupProtected = {
        nameplateResourceOnTarget = true,
        nameplateShowAll = true,
        nameplateOverlapH = true,
        nameplateOverlapV = true,
        nameplateMinAlpha = true,
        nameplateMinAlphaDistance = true,
        nameplateMaxAlpha = true,
        nameplateMaxAlphaDistance = true,
        nameplateOccludedAlphaMult = true,
        nameplateSimplifiedScale = true,
        nameplateStackingTypes = true,
        nameplateShowClassColor = true,
        nameplateShowFriendlyClassColor = true,
        nameplateMotionSpeed = true,
    }
    for cvarName in pairs(BBP.nameplateToggleCVarLookup) do
        pickupProtected[cvarName] = true
    end

    local cvarListener = CreateFrame("Frame")
    cvarListener:RegisterEvent("CVAR_UPDATE")
    cvarListener:SetScript("OnEvent", function(self, event, cvarName, cvarValue)
        if BBP.CVarTrackingDisabled then return end
        if BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater") then return end
        if BetterBlizzPlatesDB.avoidCVarPickup and pickupProtected[cvarName] then return end

        if BBP.SaveNameplateToggleCVar(cvarName, cvarValue) then
            -- handled: stored against the active PvP/PvE set
        elseif cvarsToTrack.checkboxes[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
            if cvarName == "nameplateShowClassColor" or cvarName == "nameplateShowFriendlyClassColor" then
                local checkbox = BBP.classColorCVarCheckboxes and BBP.classColorCVarCheckboxes[cvarName]
                if checkbox then
                    checkbox:SetChecked(cvarValue == "1")
                end
                BBP.RefreshAllNameplates()
            end
        elseif cvarsToTrack.sliders[cvarName] then
            BetterBlizzPlatesDB[cvarName] = tonumber(cvarValue)
        elseif cvarsToTrack.other[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
        elseif bitCVarNames[cvarName] then
            local bitfields = BetterBlizzPlatesDB.bitfields
            if bitfields and bitfields[cvarName] then
                for _, index in ipairs(BBP.bitCVarList[cvarName]) do
                    bitfields[cvarName][tostring(index)] = BBP.GetPlayerNameplateBit(cvarName, index)
                end
            end
        end
    end)
end




function BBP.CreateIntroMessageWindow()
    if BBP.IntroMessageWindow then
        BBP.IntroMessageWindow:ClearAllPoints()
        if BBF and BBF.IntroMessageWindow and BBF.IntroMessageWindow:IsShown() then
            BBP.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 240, 45)
            BBF.IntroMessageWindow:ClearAllPoints()
            BBF.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", -240, 45)
        else
            BBP.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 45)
        end
        BBP.IntroMessageWindow:Show()
        return
    end

    BBP.IntroMessageWindow = CreateFrame("Frame", "BBPIntro", UIParent, "PortraitFrameTemplate")
    BBP.IntroMessageWindow:SetSize(470, 550)
    BBP.IntroMessageWindow.Bg:SetDesaturated(true)
    BBP.IntroMessageWindow.Bg:SetVertexColor(0.5,0.5,0.5, 0.98)
    if BBF and BBF.IntroMessageWindow and BBF.IntroMessageWindow:IsShown() then
        BBP.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 240, 45)
        BBF.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", -240, 45)
    else
        BBP.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 45)
    end
    BBP.IntroMessageWindow:SetMovable(true)
    BBP.IntroMessageWindow:EnableMouse(true)
    BBP.IntroMessageWindow:RegisterForDrag("LeftButton")
    BBP.IntroMessageWindow:SetScript("OnDragStart", BBP.IntroMessageWindow.StartMoving)
    BBP.IntroMessageWindow:SetScript("OnDragStop", BBP.IntroMessageWindow.StopMovingOrSizing)
    BBP.IntroMessageWindow:SetTitle("Better|cff00c0ffBlizz|rPlates "..BBP.VersionNumber)
    BBP.IntroMessageWindow:SetFrameStrata("HIGH")
    BBP.IntroMessageWindow:SetFrameLevel(550)

    -- Add background texture
    BBP.IntroMessageWindow.textureTest = BBP.IntroMessageWindow:CreateTexture(nil, "BACKGROUND",nil, 3)
    BBP.IntroMessageWindow.textureTest:SetAtlas("communities-widebackground")
    BBP.IntroMessageWindow.textureTest:SetSize(465, 150)
    BBP.IntroMessageWindow.textureTest:SetPoint("TOP", BBP.IntroMessageWindow, "TOP", 0, -15)

    -- Create a mask texture
    local maskTexture = BBP.IntroMessageWindow:CreateMaskTexture()
    maskTexture:SetAtlas("Azerite-CenterBG-ChannelGlowBar-FillingMask")
    maskTexture:SetSize(665, 300)
    maskTexture:SetPoint("CENTER", BBP.IntroMessageWindow.textureTest, "CENTER", 0, 50)
    BBP.IntroMessageWindow.textureTest:AddMaskTexture(maskTexture)

    BBP.IntroMessageWindow:SetPortraitToAsset(135724)

    local welcomeText = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge2")
    welcomeText:SetPoint("TOP", BBP.IntroMessageWindow, "TOP", 0, -45)
    welcomeText:SetText(L["Welcome_To_Better_Blizz_Plates"])
    welcomeText:SetJustifyH("CENTER")

    local description1 = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description1:SetPoint("TOP", welcomeText, "BOTTOM", 0, -10)
    description1:SetText(L["Thank_You_For_Trying_Out_My_Addon_Below"])
    description1:SetJustifyH("CENTER")
    description1:SetWidth(410)

    local btnWidth, btnHeight, btnGap = 150, 30, -3

    local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
        local noteText = additionalNote or ""
        local color = CLASS_COLORS[class] or "|cffffffff"
        local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
        local iconSize = class == "FOREVER" and 28 or 16
        local profileText = string.format("|A:%s:%d:%d|a %s%s|r", icon, iconSize, iconSize, color, string.format(L["Profile_Name_Title"], profileName == "Starter" and L["Starter"] or profileName))
        local confirmationText = titleText .. string.format(L["Popup_Intro_Profile_Confirm"], profileText, noteText)
        BBP.GetPopup("BBP_CONFIRM_PROFILE").text = confirmationText
        BBP.ShowPopup("BBP_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
    end

    local starterButton = CreateClassButton(BBP.IntroMessageWindow, "STARTER", "Starter", nil, function()
        ShowProfileConfirmation("Starter", "STARTER", function() BBP.ApplyProfile("Starter") end)
    end)
    starterButton:SetPoint("TOP", description1, "BOTTOM", -75, -20)

    local blitzButton = CreateClassButton(BBP.IntroMessageWindow, "BLITZ", "Blitz", nil, function()
        ShowProfileConfirmation("Blitz", "BLITZ", function() BBP.ApplyProfile("Blitz") end)
    end)
    blitzButton:SetPoint("TOP", starterButton, "BOTTOM", 0, btnGap)

    local mythicButton = CreateClassButton(BBP.IntroMessageWindow, "MYTHIC", "Mythic", nil, function()
        ShowProfileConfirmation("Mythic", "MYTHIC", function() BBP.ApplyProfile("Mythic") end)
    end)
    mythicButton:SetPoint("TOP", description1, "BOTTOM", 75, -20)

    local bodifyButton = CreateClassButton(BBP.IntroMessageWindow, "MAGE", "Bodify", "bodify", function()
        ShowProfileConfirmation("Bodify", "MAGE", function() BBP.ApplyProfile("Bodify") end)
    end)
    bodifyButton:SetPoint("TOP", mythicButton, "BOTTOM", 0, btnGap)

    local preMidnightButton = CreateClassButton(BBP.IntroMessageWindow, "PREMIDNIGHT", "Pre-Midnight", nil, function()
        ShowProfileConfirmation("Pre-Midnight", "PREMIDNIGHT", function() BBP.ApplyProfile("Pre-Midnight") end)
    end)
    preMidnightButton:SetPoint("TOP", blitzButton, "BOTTOM", 0, btnGap)

    local foreverButton = CreateClassButton(BBP.IntroMessageWindow, "FOREVER", "Forever", nil, function()
        ShowProfileConfirmation("Forever", "FOREVER", function() BBP.ApplyProfile("Forever") end)
    end)
    foreverButton:SetPoint("TOP", bodifyButton, "BOTTOM", 0, btnGap)

    local orText = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText:SetPoint("CENTER", preMidnightButton, "BOTTOM", 75, -20)
    orText:SetText("OR")
    orText:SetJustifyH("CENTER")

    local columnOffsets = { -114, 0, 114 }
    local columnAnchors = { orText, orText, orText }
    local columnFirstRow = { true, true, true }
    local colIndex = 1
    local lastCol1Button

    for _, profile in ipairs(BBP.ProfileData) do
        if not profile.core then
            local button = CreateClassButton(BBP.IntroMessageWindow, profile.class, profile.name, profile.twitchName, function()
                ShowProfileConfirmation(profile.name, profile.class, function() BBP.ApplyProfile(profile.name) end)
            end, profile.youtubeName)

            if columnFirstRow[colIndex] then
                button:SetPoint("TOP", columnAnchors[colIndex], "BOTTOM", columnOffsets[colIndex], -10)
                columnFirstRow[colIndex] = false
            else
                button:SetPoint("TOP", columnAnchors[colIndex], "BOTTOM", 0, btnGap)
            end

            columnAnchors[colIndex] = button
            if colIndex == 1 then
                lastCol1Button = button
            end
            colIndex = colIndex + 1
            if colIndex > 3 then colIndex = 1 end
        end
    end

    local orText2 = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText2:SetPoint("CENTER", lastCol1Button, "BOTTOM", 114, -20)
    orText2:SetText("OR")
    orText2:SetJustifyH("CENTER")

    local buttonLast = CreateFrame("Button", nil, BBP.IntroMessageWindow, "GameMenuButtonTemplate")
    buttonLast:SetSize(btnWidth, btnHeight)
    buttonLast:SetText(L["Exit_No_Profile"])
    buttonLast:SetPoint("TOP", lastCol1Button, "BOTTOM", 114, -40)
    buttonLast:SetNormalFontObject("GameFontNormal")
    buttonLast:SetHighlightFontObject("GameFontHighlight")
    buttonLast:SetScript("OnClick", function()
        BBP.IntroMessageWindow:Hide()
        if not BetterBlizzPlates.guiLoaded then
            BBP.LoadGUI()
        else
            Settings.OpenToCategory(BBP.category:GetID())
        end
    end)
    CreateTooltipTwo(buttonLast, L["Exit_No_Profile"], L["Tooltip_Exit_No_Profile_2_Desc"], nil, "ANCHOR_TOP")
    local f,s,o = buttonLast.Text:GetFont()
    buttonLast.Text:SetFont(f,s,"OUTLINE")

    BBP.IntroMessageWindow.CloseButton:HookScript("OnClick", function()
        if not BetterBlizzPlates.guiLoaded then
            BBP.LoadGUI()
        else
            Settings.OpenToCategory(BBP.category:GetID())
        end
    end)

    local function AdjustWindowHeight()
        local baseHeight = 374
        local perRowHeight = 29
        local buttonCount = 0
        for _, child in ipairs({BBP.IntroMessageWindow:GetChildren()}) do
            if child and child:IsObjectType("Button") then
                buttonCount = buttonCount + 1
            end
        end

        local rowCount = math.ceil(buttonCount / 3)
        local newHeight = baseHeight + (rowCount * perRowHeight)

        BBP.IntroMessageWindow:SetSize(470, newHeight)
    end
    AdjustWindowHeight()
end
