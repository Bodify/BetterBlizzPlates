BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
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
local pixelsBetweenBoxedWSlider = -4
local pixelsOnFirstBox = -1
local npcEditFrame = nil
local titleText = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \n\n"

BBP.executeIndicatorIconReplacement = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\Islands-AzeriteBoss.tga"
BBP.targetIndicatorIconReplacement = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\Navigation-Tracked-Arrow.tga"
BBP.focusIndicatorIconReplacement = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\Waypoint-MapPin-Untracked.tga"
BBP.healthNumbersIconReplacement = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\ui_adv_health.tga"
BBP.partyPointerIconReplacement = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-QuestPoiImportant-QuestNumber-SuperTracked.tga"
BBP.partyPointerHealerIconReplacement = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\communities-chat-icon-plus.tga"
BBP.squareGreenGlow = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\newplayertutorial-drag-slotgreen.tga"
BBP.squareBlueGlow = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\newplayertutorial-drag-slotblue.tga"
BBP.PandemicIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\ElementalStorm-Boss-Air.tga"
BBP.ImportantIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-QuestPoiImportant-QuestBang.tga"
BBP.OwnAuraIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon.tga"
BBP.EnlargedIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-Minimap-Zoom-In.tga"
BBP.CompactIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UI-HUD-Minimap-Zoom-Out.tga"
BBP.TotemIndicatorIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\TeleportationNetwork-Ardenweald-32x32.tga"
BBP.BarberIcon = "Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\Barbershop-32x32.tga"

local checkBoxList = {}
local checkboxByOption = {}
local sliderList = {}
local dropdownList = {}
local MAX_SEARCH_CHECKBOXES = 25
local MAX_SEARCH_SLIDERS = 15
local MAX_SEARCH_DROPDOWNS = 3
local SEARCH_DROPDOWN_SCALE = 0.8

local settingsPopups = {}
local settingsPopupsHooked

local function KeepPopupInSettings(popup, panel)
    popup:SetParent(UIParent)
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(550)
    popup:SetToplevel(true)
    popup:HookScript("OnShow", function(self)
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end)
    popup:HookScript("OnHide", function()
        panel:SetAlpha(1)
    end)
    panel:HookScript("OnHide", function()
        popup:Hide()
    end)
    if not settingsPopupsHooked then
        settingsPopupsHooked = true
        SettingsPanel:HookScript("OnHide", function()
            for other in pairs(settingsPopups) do
                other:Hide()
            end
        end)
    end
    settingsPopups[popup] = panel
end

local function RecolorEntireAuraWhitelist(r, g, b, a)
    if type(BetterBlizzPlatesDB) ~= "table" then return false end
    local wl = BetterBlizzPlatesDB.auraWhitelist
    if type(wl) ~= "table" then return false end

    for i = 1, #wl do
        local entry = wl[i]
        if type(entry) == "table" then
            local ec = entry.entryColors
            if type(ec) ~= "table" then
                ec = {}
                entry.entryColors = ec
            end

            local touched = false
            for _, sub in pairs(ec) do
                if type(sub) == "table" and (sub.r or sub.g or sub.b or sub.a) then
                    sub.r, sub.g, sub.b, sub.a = r, g, b, a
                    touched = true
                end
            end

            if not touched then
                ec.text = { r = r, g = g, b = b, a = a }
            end
        end
    end

    if BBP["auraWhitelistRefresh"] then
        BBP["auraWhitelistRefresh"]()
    end

    return true
end

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

BBP.popupBuilders["BBP_NP_AURA_ENABLE"] = function() return {
    text = titleText..L["Popup_Youve_Enabled_Nameplate_Aura_Filters_This"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        local db = BetterBlizzPlatesDB
        db.otherNpBuffFilterImportantBuffs = true
        db.otherNpdeBuffFilterCC = true
        db.friendlyNpBuffFilterImportantBuffs = true
        db.friendlyNpdeBuffFilterCC = true
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end,
    OnCancel = function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end,
    timeout = 0,
    whileDead = true,
} end

BBP.popupBuilders["BBP_TOTEMLIST_RESET"] = function() return {
    text = L["Popup_This_Will_Delete_The_Entire_Totem"],
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

BBP.popupBuilders["BBP_RETAILORCLASSIC"] = function() return {
    text = L["Popup_Welcome_To_Better_Blizz_Plates_Would"],
    button1 = L["Keep_Retail"],
    button2 = L["Switch_To_Classic"],
    OnCancel = function()
        BetterBlizzPlatesDB.classicNameplates = true
        BetterBlizzPlatesDB.nameplateEnemyWidth = 150
        BetterBlizzPlatesDB.nameplateFriendlyWidth = 150
        BetterBlizzPlatesDB.castBarHeight = 11
        BetterBlizzPlatesDB.hideLevelFrame = false
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
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
        icon:SetVertexColor(r, g, b, a)
    end
end

local function OpenColorPicker(colorType, icon)
    -- Initialize color with default RGBA if not present
    BetterBlizzPlatesDB[colorType] = BetterBlizzPlatesDB[colorType] or {1, 1, 1, 1}
    local r, g, b, a = unpack(BetterBlizzPlatesDB[colorType])

    local function updateColors()
        BetterBlizzPlatesDB[colorType] = {r, g, b, a}
        if icon then
            UpdateColorSquare(icon, r, g, b, a)
        end
        BBP.RefreshAllNameplates()
        if ColorPickerFrame.Content then
            ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
        end
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

local function CreateColorBox(parent, colorVar, labelText)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(55, 20)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

    -- Border Frame (slightly larger to act as a border)
    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetSize(18, 18)
    borderFrame:SetPoint("LEFT", frame, "LEFT", 4, 0)

    local border = borderFrame:CreateTexture(nil, "OVERLAY", nil, 5)
    border:SetAtlas("CommentatorSpellBorder")
    border:SetAllPoints()

    -- Create the color texture within the border frame
    local colorTexture = borderFrame:CreateTexture(nil, "OVERLAY")
    colorTexture:SetSize(15, 15)
    colorTexture:SetPoint("CENTER", borderFrame, "CENTER", 0, 0)
    colorTexture:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\blizzTex\\UIFrameIconMask")
    colorTexture:SetVertexColor(unpack(BetterBlizzPlatesDB[colorVar] or {1, 1, 1}))

    -- Label text for the color box
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetText(labelText)
    text:SetPoint("LEFT", borderFrame, "RIGHT", 5, 0)
    frame.text = text

    -- Make the frame clickable and open a color picker on click
    frame:SetScript("OnMouseDown", function()
        if frame:GetAlpha() == 1 then
            BBP.needsUpdate = true
            OpenColorPicker(colorVar, colorTexture)
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

local function CreateFontDropdown(name, parent, defaultText, settingKey, toggleFunc, point)
    local dropdown = CreateLegacySizedDropdown(parent, 135)
    dropdown:SetSelectionText(function()
        return BetterBlizzPlatesDB[settingKey] or defaultText
    end)

    dropdown:SetupMenu(function(_, rootDescription)
        local fonts = LSM:HashTable(LSM.MediaType.FONT)
        local sortedFonts = {}
        for fontName in pairs(fonts) do
            table.insert(sortedFonts, fontName)
        end
        table.sort(sortedFonts)

        local categorySize = 12
        for page = 1, math.ceil(#sortedFonts / categorySize) do
            local submenu = rootDescription:CreateButton(string.format(L["Fonts_Page"], page))
            local startIndex = (page - 1) * categorySize + 1
            for i = startIndex, math.min(startIndex + categorySize - 1, #sortedFonts) do
                local fontName = sortedFonts[i]
                local fontPath = fonts[fontName]
                submenu:CreateRadio(fontName, function()
                    return BetterBlizzPlatesDB[settingKey] == fontName
                end, function()
                    BetterBlizzPlatesDB[settingKey] = fontName
                    BBP.needsUpdate = true
                    toggleFunc(fontPath)
                    dropdown.Text:SetFont(fontPath, 12)
                    return MenuResponse.CloseAll
                end)
            end
        end
    end)

    local fontName = BetterBlizzPlatesDB.customFont
    local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
    dropdown.Text:SetFont(fontPath, 12)
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    dropdown:SetEnabled(not (parent:GetObjectType() == "CheckButton" and not parent:GetChecked()))

    return dropdown
end

local function CreateTextureDropdown(name, parent, defaultText, settingKey, toggleFunc, point, dropdownWidth)
    local dropdown = CreateLegacySizedDropdown(parent, dropdownWidth or 135)
    dropdown:SetSelectionText(function()
        return BetterBlizzPlatesDB[settingKey] or defaultText
    end)

    dropdown:SetupMenu(function(_, rootDescription)
        local textures = LSM:HashTable(LSM.MediaType.STATUSBAR)
        local sortedTextures = {}
        for textureName in pairs(textures) do
            table.insert(sortedTextures, textureName)
        end
        table.sort(sortedTextures)

        local categorySize = 12
        for page = 1, math.ceil(#sortedTextures / categorySize) do
            local submenu = rootDescription:CreateButton(string.format(L["Textures_Page"], page))
            local startIndex = (page - 1) * categorySize + 1
            for i = startIndex, math.min(startIndex + categorySize - 1, #sortedTextures) do
                local textureName = sortedTextures[i]
                local texturePath = textures[textureName]
                local radio = submenu:CreateRadio(textureName, function()
                    return BetterBlizzPlatesDB[settingKey] == textureName
                end, function()
                    BetterBlizzPlatesDB[settingKey] = textureName
                    BBP.needsUpdate = true
                    toggleFunc(texturePath)
                    return MenuResponse.CloseAll
                end)
                radio:AddInitializer(function(button)
                    local icon = button:AttachTexture()
                    icon:SetSize(16, 16)
                    icon:SetPoint("RIGHT")
                    icon:SetTexture(texturePath)
                    button.fontString:SetPoint("RIGHT", icon, "LEFT", -4, 0)
                    return button.fontString:GetUnboundedStringWidth() + 60, 20
                end)
            end
        end
    end)

    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    dropdown:SetEnabled(not (parent:GetObjectType() == "CheckButton" and not parent:GetChecked()))

    return dropdown
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

local function GetSearchCategory(parent)
    local category
    local frame = parent
    while frame and frame ~= UIParent do
        if frame.name then
            category = frame.name
            break
        end
        frame = settingsPopups[frame] or frame:GetParent()
    end
    if category == "Better|cff00c0ffBlizz|rPlates |A:gmchat-icon-blizz:16:16|a" then
        category = L["Search_Name_General"]
    end
    return category
end

local function SearchCategoryOf(widget)
    if not widget.searchCategory then
        widget.searchCategory = GetSearchCategory(widget:GetParent())
    end
    return widget.searchCategory
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

    local category = GetSearchCategory(parent)

    slider.searchCategory = category

    if width then
        slider:SetWidth(width)
    end

    local function UpdateSliderRange(newValue, minValue, maxValue)
        newValue = tonumber(newValue) -- Convert newValue to a number

        if (axis == "X" or axis == "Y") and (newValue < minValue or newValue > maxValue) then
            -- For X or Y axis: extend the range by ±30
            local newMinValue = math.min(newValue - 30, minValue)
            local newMaxValue = math.max(newValue + 30, maxValue)
            slider:SetMinMaxValues(newMinValue, newMaxValue)
        elseif newValue < minValue or newValue > maxValue then
            -- For other sliders: adjust the range, ensuring it never goes below a specified minimum (e.g., 0)
            local nonAxisRangeExtension = 2
            local newMinValue = math.max(newValue - nonAxisRangeExtension, 0.1)  -- Prevent going below 0.1
            local newMaxValue = math.max(newValue + nonAxisRangeExtension, maxValue)
            if element == "classIndicatorAlpha" then
                slider:SetMinMaxValues(newMinValue, 1)
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
                    if not string.match(element, "Scale$") then
                        BetterBlizzPlatesDB[element .. "Scale"] = value
                    else
                        BetterBlizzPlatesDB[element] = value
                    end
                end

                local xPos = BetterBlizzPlatesDB[element .. "XPos"] or 0
                local yPos = BetterBlizzPlatesDB[element .. "YPos"] or 0
                local anchorPoint = BetterBlizzPlatesDB[element .. "Anchor"] or "CENTER"

                if element == "levelEliteIconWidth" or element == "levelEliteIconHeight" or element == "levelEliteIconXPos" or element == "levelEliteIconYPos" or element == "levelTextSize" or element == "levelTextXPos" or element == "levelTextYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.UpdateAllLevelFrames()
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
                        elseif element == "executeIndicatorXPos" or element == "executeIndicatorYPos" or element == "executeIndicatorScale" then
                            BBP.ExecuteIndicator(frame)
                        -- Faction Indicator Pos and Scale
                        elseif element == "factionIndicatorXPos" or element == "factionIndicatorYPos" or element == "factionIndicatorScale" then
                            BBP.FactionIndicator(frame)
                        -- Party Pointer Pos and Scale
                        elseif element == "partyPointerXPos" or element == "partyPointerYPos" or element == "partyPointerScale"  or element == "partyPointerHealerScale" or element == "partyPointerWidth" then
                            BBP.PartyPointer(frame)
                        elseif element == "hideNpcMurlocScale" or element == "hideNpcMurlocYPos" then
                            BBP.HideNPCs(frame, nameplate)
                        elseif element == "nameplateAuraEnlargedScale" or element == "nameplateKeyAuraScale" or element == "nameplateAuraCompactedScale" or element == "nameplateAuraBuffScale" or element == "nameplateAuraDebuffScale" or element == "nameplateAuraBuffSelfScale" or element == "nameplateAuraDebuffSelfScale" or element == "nameplateKeyAurasHorizontalGap" then
                            BBP.RefUnitAuraTotally(frame)
                        elseif element == "nameplateAuraEnlargedScale" or element == "nameplateAuraCompactedScale" or element == "nameplateAuraBuffScale" or element == "nameplateAuraDebuffScale" then
                            BBP.RefUnitAuraTotally(frame)
                        -- Fake name
                        elseif element == "fakeNameXPos" or element == "fakeNameYPos" or element == "fakeNameFriendlyXPos" or element == "fakeNameFriendlyYPos" then
                            BBP.RepositionName(frame)
                        -- Target Indicator Pos and Scale
                        elseif element == "targetIndicatorXPos" or element == "targetIndicatorYPos" or element == "targetIndicatorScale" then
                            BBP.TargetIndicator(frame)
                        -- Focus Target Indicator Pos and Scale
                        elseif element == "focusTargetIndicatorXPos" or element == "focusTargetIndicatorYPos" or element == "focusTargetIndicatorScale" then
                            BBP.FocusTargetIndicator(frame)
                        elseif element == "healthNumbersScale" or element == "healthNumbersXPos" or element == "healthNumbersYPos" then
                            BBP.HealthNumbers(frame)
                        -- Totem Indicator Pos and Scale
                        elseif element == "totemIndicatorXPos" or element == "totemIndicatorYPos" or element == "totemIndicatorScale" then
                            if not frame.totemIndicator then
                                --BBP.CreateTotemComponents(frame, 30)
                                BBP.ApplyTotemIconsAndColorNameplate(frame, frame.unit)
                            else
                                if axis then
                                    local yPosAdjustment = BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown and yPos + 4 or yPos
                                    if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
                                        frame.totemIndicator:SetPoint("BOTTOM", frame.healthBar, BetterBlizzPlatesDB.totemIndicatorAnchor, xPos, yPos + 4)
                                    else
                                        frame.totemIndicator:SetPoint("BOTTOM", frame.name, BetterBlizzPlatesDB.totemIndicatorAnchor, xPos, yPos + 0)
                                    end
                                else
                                    frame.totemIndicator:SetScale(value)
                                end
                            end
                        -- Cast Timer Pos and Scale
                        elseif element == "castTimer" then
                            --not rdy
                        -- Cast bar icon pos and scale
                        elseif element == "castBarIconXPos" or element == "castBarIconYPos" then
                            local castBar = frame.CastBar or frame.castBar
                            if axis then
                                local yOffset = BetterBlizzPlatesDB.castBarDragonflightShield and -2 or 0
                                castBar.Icon:ClearAllPoints()
                                castBar.Icon:SetPoint("CENTER", castBar, "LEFT", xPos, yPos)
                                if castBar.bbpRetailIcon then
                                    castBar.bbpRetailIcon:ClearAllPoints()
                                    castBar.bbpRetailIcon:SetPoint("CENTER", castBar, "LEFT", xPos, yPos)
                                end
                                if castBar.bbpClassicIcon then
                                    castBar.bbpClassicIcon:ClearAllPoints()
                                    castBar.bbpClassicIcon:SetPoint("RIGHT", frame.CastBarsContainer.castBar, "LEFT", xPos-2, yPos)
                                end
                                castBar.BorderShield:ClearAllPoints()
                                castBar.BorderShield:SetPoint("CENTER", castBar.bbpRetailIcon or castBar.bbpClassicIcon or castBar.Icon, "CENTER", 0, 0)
                            else
                                BetterBlizzPlatesDB.castBarIconScale = value
                                castBar.Icon:SetScale(value)
                                if castBar.bbpRetailIcon then
                                    castBar.bbpRetailIcon:SetScale(value)
                                end
                                if castBar.bbpClassicIcon then
                                    castBar.bbpClassicIcon:SetScale(value)
                                end
                                castBar.BorderShield:SetScale(value)
                            end
                        -- Cast bar height
                        elseif element == "castBarHeight" then
                            local castBar = frame.CastBar or frame.castBar
                            castBar:SetHeight(value)
                            frame.CastBarsContainer:SetHeight(value)
                            if BetterBlizzPlatesDB.classicNameplates then
                                castBar.UpdateBorders()
                            end
                            BBP.SetNameplateBarSizes(frame)
                        elseif element == "castBarTextScale" then
                            local castBar = frame.CastBar or frame.castBar
                            if castBar.castText then
                                castBar.castText:SetScale(value)
                            end
                            if castBar.Text then
                                castBar.Text:SetScale(value)
                            end
                        -- Cast bar emphasis icon pos and scale
                        elseif element == "castBarEmphasisIconXPos" or element == "castBarEmphasisIconYPos" then
                            if axis then
                                local castBar = frame.CastBar or frame.castBar
                                castBar.Icon:SetPoint("CENTER", castBar, "LEFT", xPos, yPos)
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

                --If no nameplates are present still adjust values
                if element == "threatPercentScale" or element == "threatPercentXPos" or element == "threatPercentYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.RefreshThreatPercent()
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
                elseif element == "nameplateVerticalPosition" then
                    BetterBlizzPlatesDB.nameplateVerticalPosition = value
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
                elseif element == "partyPointerHighlightScale" then
                    BetterBlizzPlatesDB.partyPointerHighlightScale = value
                    BBP.RefreshAllNameplates()
                elseif element == "hpHeightEnemy" then
                    BetterBlizzPlatesDB.hpHeightEnemy = value
                    BBP.RefreshAllNameplates()
                elseif element == "hpHeightFriendly" then
                    BetterBlizzPlatesDB.hpHeightFriendly = value
                    BBP.RefreshAllNameplates()
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
                elseif element == "hideNpcMurlocScale" then
                    BetterBlizzPlatesDB.hideNpcMurlocScale = value
                elseif element == "hideNpcMurlocYPos" then
                    BetterBlizzPlatesDB.hideNpcMurlocYPos = value
                elseif element == "nameplateAuraEnlargedScale" then
                    BetterBlizzPlatesDB.nameplateAuraEnlargedScale = value
                elseif element == "nameplateAuraCompactedScale" then
                    BetterBlizzPlatesDB.nameplateAuraCompactedScale = value
                elseif element == "nameplateAuraBuffScale" then
                    BetterBlizzPlatesDB.nameplateAuraBuffScale = value
                elseif element == "nameplateAuraDebuffScale" then
                    BetterBlizzPlatesDB.nameplateAuraDebuffScale = value
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
                elseif element == "executeSkullScale" or element == "executeSkullXPos" or element == "executeSkullYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.needsUpdate = true
                    if BetterBlizzPlatesDB.executeIndicator then
                        for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                            if namePlate.UnitFrame and not namePlate.UnitFrame:IsForbidden() then
                                BBP.ExecuteIndicator(namePlate.UnitFrame)
                            end
                        end
                    end
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
                elseif element == "classIndicatorFriendlyXPos" then
                    BetterBlizzPlatesDB.classIndicatorFriendlyXPos = value
                elseif element == "classIndicatorFriendlyYPos" then
                    BetterBlizzPlatesDB.classIndicatorFriendlyYPos = value
                elseif element == "classIndicatorFriendlyScale" then
                    BetterBlizzPlatesDB.classIndicatorFriendlyScale = value
                elseif element == "classIndicatorAlpha" then
                    BetterBlizzPlatesDB.classIndicatorAlpha = value
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
                elseif element == "nameplateSelfWidth" then
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateSelfWidth = value
                        local heightValue
                        heightValue = 45 --BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        C_NamePlate.SetNamePlateSelfSize(value, heightValue)
                    end
                elseif element == "smallPetsWidth" then
                    BetterBlizzPlatesDB.smallPetsWidth = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local petFrame = np.UnitFrame
                        if petFrame then
                            BBP.SmallPetsInPvP(petFrame)
                            if BetterBlizzPlatesDB.classicNameplates then
                                BBP.CreateBetterClassicCastbarBorders(petFrame)
                            end
                        end
                    end
                elseif element == "smallPetsHeight" then
                    BetterBlizzPlatesDB.smallPetsHeight = value
                    for _, np in pairs(C_NamePlate.GetNamePlates()) do
                        local petFrame = np.UnitFrame
                        if petFrame then
                            BBP.SmallPetsInPvP(petFrame)
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
                elseif element == "nameplateAurasNoNameYPos" then
                    BetterBlizzPlatesDB.nameplateAurasNoNameYPos = value
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
                elseif element == "nameplateAuraWidthGap" then
                    BetterBlizzPlatesDB.nameplateAuraWidthGap = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraHeightGap" then
                    BetterBlizzPlatesDB.nameplateAuraHeightGap = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAurasXPos" then
                    BetterBlizzPlatesDB.nameplateAurasXPos = xPos
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAurasYPos" then
                    BetterBlizzPlatesDB.nameplateAurasYPos = yPos
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateAuraScale" then
                    BetterBlizzPlatesDB.nameplateAuraScale = value
                    BBP.RefreshBuffFrame()
                elseif element == "nameplateKeyAurasXPos" or element == "nameplateKeyAurasYPos" or element == "nameplateKeyAuraScale" or element == "nameplateKeyAurasHorizontalGap" or element == "nameplateAurasPersonalXPos" or element == "nameplateAurasPersonalYPos" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.RefreshBuffFrame()
                elseif element == "defaultNpAuraCdSize" then
                    BetterBlizzPlatesDB.defaultNpAuraCdSize = value
                    BBP.RefreshBuffFrame()
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
                    BBP.RefreshAllNameplates()
                elseif element == "nameplateTargetBorderSize" then
                    BetterBlizzPlatesDB.nameplateTargetBorderSize = value
                    BBP.RefreshAllNameplates()
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
                -- Nameplate Height cvar
                elseif element == "NamePlateVerticalScale" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("NamePlateVerticalScale", value)
                        BetterBlizzPlatesDB.NamePlateVerticalScale = value
                        local verticalScale = tonumber(BetterBlizzPlatesDB.NamePlateVerticalScale)
                        if verticalScale and verticalScale >= 2 then
                            C_CVar.SetCVar("NamePlateHorizontalScale", 1.4)
                        else
                            C_CVar.SetCVar("NamePlateHorizontalScale", 1)
                        end
                        local castBar = frame.CastBar or frame.castBar
                        if castBar then
                            if not BetterBlizzPlatesDB.enableCastbarCustomization then
                                if BBP.isLargeNameplatesEnabled() then
                                    castBar:SetHeight(18.8)
                                else
                                    castBar:SetHeight(8)
                                end
                            else
                                castBar:SetHeight(BetterBlizzPlatesDB.castBarHeight)
                            end
                        end
                    end
                -- Nameplate Horizontal Overlap
                elseif element == "stackingVerticalAdjustmentOffset" or element == "stackingHorizontalOffset" or element == "stackingVerticalOffset" then
                    BetterBlizzPlatesDB[element] = value
                    BBP.AdjustAllCickAndStackAreas("zone")
                -- Nameplate Motion Speed
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
                elseif element == "nameplateSimplifiedScale" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateSimplifiedScale", value)
                        BetterBlizzPlatesDB.nameplateSimplifiedScale = value
                    end
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
                elseif element == "nameplateSelectedAlpha" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateSelectedAlpha", value)
                        BetterBlizzPlatesDB.nameplateSelectedAlpha = value
                    end
                elseif element == "nameplateNotSelectedAlpha" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateNotSelectedAlpha", value)
                        BetterBlizzPlatesDB.nameplateNotSelectedAlpha = value
                    end
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
                    BBP.UpdateNpcTitleScale()
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
                    C_NamePlate.SetNamePlateFriendlySize(value, heightValue)
                    end
                elseif element == "nameplateEnemyWidth" then
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateEnemyWidth = value
                        local heightValue
                        heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        C_NamePlate.SetNamePlateEnemySize(value, heightValue)
                    end
                elseif element == "fadeOutNPCsAlpha" then
                    if axis then
                        BetterBlizzPlatesDB.fadeOutNPCsAlpha = value
                    end
                end
            end
        --end
    end

    -- Function to handle the entered value and update the slider
    local function HandleEditBoxInput()
        local inputValue = tonumber(editBox:GetText())
        if inputValue then
            if (axis ~= "X" and axis ~= "Y") and (inputValue <= 0 or (element == "classIndicatorAlpha" and inputValue >= 1)) then
                inputValue = 0.1  -- Set to minimum allowed value for non-axis sliders
                if element == "classIndicatorAlpha" then
                    inputValue = 1
                end
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
        -- Add the current border type
        if title == L["Shield"] then
            local currentBorder = BetterBlizzPlatesDB["totemIndicatorShieldType"]
            local borderTypes = {
                "1:|A:nameplates-InterruptShield:24:20|a",
                "2:|A:transmog-frame-selected:24:24|a",
                "3:|A:ShipMission_ShipFollower-EquipmentFrame:22:22|a",
                "4:|A:GarrMission_EncounterAbilityBorder-Lg:29:29|a",
                "5:|A:Garr_Specialization_IconBorder:24:24|a"
            }
            local tooltipText = L["Tooltip_Right_Click_To_Change_Border_Type"] .. "\n"
            for i, border in ipairs(borderTypes) do
                if i == currentBorder then
                    tooltipText = tooltipText .. border .. " |A:ParagonReputation_Checkmark:15:15|a\n"
                else
                    tooltipText = tooltipText .. border .. "\n"
                end
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Hide_Castbar_Text"] then
            local alsoHideInt = BetterBlizzPlatesDB.hideCastbarTextInt
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Also_Hide_The"] .. "|r"

            if alsoHideInt then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Center_Auras_On_Enemy"] then
            local centerBuffsOnly = BetterBlizzPlatesDB.nameplateCenterOnlyBuffs
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Only_Center_Buffs"] .. "|r"

            if centerBuffsOnly then
                tooltipText = tooltipText .. "\n|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == L["Sort_Auras_By_Duration"] then
            local tooltipText = "\n|cff32f795" .. L["Tooltip_Right_Click_To_Reverse_Duration_Sort"] .. "|r"
            if BetterBlizzPlatesDB.sortDurationAurasReverse then
                tooltipText = tooltipText .. "\n" .. L["Tooltip_Reverse_Sorting"] .. "|A:ParagonReputation_Checkmark:15:15|a"
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

local function greenScreen(anchorFrame, parent)
    -- Create a texture on the target frame, in the BACKGROUND layer
    local greenScreen = parent and parent:CreateTexture(nil, "BACKGROUND") or anchorFrame:CreateTexture(nil, "BACKGROUND")

    -- If an anchor frame is provided, set the texture to cover that frame; otherwise, cover the target frame
    greenScreen:SetAllPoints(anchorFrame)

    -- Generate random RGB values
    local r = math.random()
    local g = math.random()
    local b = math.random()

    -- Set the color texture with random RGB values and 0.4 opacity
    greenScreen:SetColorTexture(r, g, b, 0.4)
end

local function notWorking(element, re)
    --element:Disable()
    local hasOnClick = pcall(function() return element:GetScript("OnClick") end)
    if hasOnClick then
        element:SetScript("OnClick", function() end)
    end
    element:SetScript("OnMouseDown", function() end)
    element:SetScript("OnMouseUp", function() end)
    element:SetAlpha(0.4)
    if element.Text then
        element.Text:SetTextColor(1,0,0)
    end
    CreateTooltipTwo(element, L["Tooltip_Not_Working_Title"], string.format(L["Tooltip_Not_Working_Desc"], BBP.isMoP and "MoP" or BBP.isTBC and "TBC" or "Cata"), L["Tooltip_Not_Working_SubText"])

    if re then
        C_Timer.After(4, function()
            notWorking(element)
        end)
    end
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
    DEATHKNIGHT = "|ffc41f3b",
    MONK = "|cff00ff96",
    DEMONHUNTER = "|cffa330c9",
    EVOKER = "|cff33937f",
    STARTER = "|cff32cd32",
    BLITZ = "|cffff8000",
    MYTHIC = "|cff7dd1c2",
    MINIMAL = "|cfff5e6cc",
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
    BLITZ = "QuestBonusObjective",
    MYTHIC = "worldquest-icon-dungeon",
    MINIMAL = "plunderstorm-icon-offensive",
}

-- Function to show the confirmation popup with dynamic profile information
local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
    local noteText = additionalNote or ""
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
    local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], profileName == "Starter" and L["Starter"] or profileName))
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

local function CreateClassButton(parent, class, name, twitchName, onClickFunc)
    local bbpParent = parent == BetterBlizzPlates
    local btnWidth, btnHeight = bbpParent and 96 or 150, bbpParent and 22 or  30
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetSize(btnWidth, btnHeight)

    local displayName = name == "Starter" and L["Starter"] or name
    local buttonName = bbpParent and displayName or string.format(L["Profile_Name_Title"], displayName)
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"

    button:SetText(string.format("|A:%s:16:16|a %s%s|r", icon, color, buttonName))
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    local a,b,c = button.Text:GetFont()
    button.Text:SetFont(a,b,"OUTLINE")
    local a,b,c,d,e = button.Text:GetPoint()
    button.Text:SetPoint(a,b,c,d,e-0.6)

    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            BBP.ShowProfileLink(twitchName and ("www.twitch.tv/"..twitchName))
        elseif onClickFunc then
            onClickFunc()
        end
    end)

    if class == "STARTER" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Profile_Starter_Desc"], nil, "ANCHOR_TOP")
    elseif class == "BLITZ" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Profile_Blitz_Desc"], nil, "ANCHOR_TOP")
    elseif class == "MINIMAL" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Tooltip_A_Minimalistic_And_Clean_Profile_With_Desc"], nil, "ANCHOR_TOP")
    elseif class == "MYTHIC" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), L["Tooltip_A_Great_Well_Rounded_Profile_Made_Desc"], nil, "ANCHOR_TOP")
    else
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], name == "Starter" and L["Starter"] or name)), string.format(L["Tooltip_Enable_Profile_Desc"], name), string.format("www.twitch.tv/%s", twitchName), "ANCHOR_TOP")
    end

    return button
end

local function CreateImportExportUI(parent, title, dataTable, posX, posY, tableName)
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
    elseif tableName == "colorNpcList" then
        CreateTooltipTwo(titleText, L["Supports_Plater_NPC_Color_Import_As_Well"])
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
        local exportString = BBP.ExportProfile(dataTable, tableName)
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
        local importString = importBox:GetText()
        local profileData, errorMessage = BBP.OldImportProfile(importString, tableName)
        if errorMessage then
            BBP.Print(string.format(L["Print_Error_Importing"], title) .. " " .. tostring(errorMessage))
        else
            if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                -- Perform a deep merge if "Keep Old" is checked
                BBP.DeepMergeTables(dataTable, profileData)
            else
                -- Replace existing data with imported data
                --for k in pairs(dataTable) do dataTable[k] = nil end -- Clear current table
                if tableName == "fullProfile" then
                    for k in pairs(BBP.exportDefaults) do dataTable[k] = nil end
                end
                for k, v in pairs(profileData) do
                    dataTable[k] = v -- Populate with new data
                end
                if tableName == "fullProfile" then
                    BBP.UseDefaultsUntilReload(dataTable)
                end
            end
            BBP.Print(string.format(L["Print_Imported_Successfully_Reload"], title))
            C_CVar.SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
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

local function CreateCheckbox(option, label, parent, cvar, extraFunc)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)
    checkBox.Text:SetFont(fontSmall, 12)
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
    checkBox.text = checkBox.Text
    -- checkBox:SetHitRectInsets(0, 0, 0, 0)
    -- local a,b,c,d,e = checkBox.Text:GetPoint()
    -- checkBox.Text:SetPoint(a,b,c,d-4,e-1)
    checkBox.option = option
    if option and not checkboxByOption[option] then
        checkboxByOption[option] = checkBox
    end
    if cvar then
        checkBox.cvar = true
    end

    local category = GetSearchCategory(parent)

    checkBox.searchCategory = category

    local function UpdateCheckboxState()
        if cvar and not BBP.variablesLoaded then
            C_Timer.After(0.1, function() UpdateCheckboxState() end)
        else
            if BetterBlizzPlatesDB[option] == "1" or BetterBlizzPlatesDB[option] == 1 or BetterBlizzPlatesDB[option] == true then
                BetterBlizzPlatesDB[option] = "1"
                checkBox:SetChecked(true)
            else
                BetterBlizzPlatesDB[option] = "0"
                checkBox:SetChecked(false)
            end
            local isChecked = checkBox:GetChecked()
            local newValue = isChecked and "1" or "0"
            if cvar then
                -- if not BetterBlizzPlatesDB.wasOnLoadingScreen then
                --     BBP.RunAfterCombat(function()
                --         C_CVar.SetCVar(option, newValue)
                --     end)
                -- end
                BetterBlizzPlatesDB[option] = newValue
            else
                BetterBlizzPlatesDB[option] = isChecked
            end
        end
    end

    UpdateCheckboxState()

    local function UpdateCheckboxStateDependingOnParent()
        if (cvar or parent.cvar) and not BBP.variablesLoaded then
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
        if cvar then
            newValue = isChecked and "1" or "0"
            BBP.RunAfterCombat(function()
                C_CVar.SetCVar(option, newValue)
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

    local category = GetSearchCategory(parent)
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
            if not option.isAvailable or option.isAvailable() then
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

local selectedLineIndex = nil
local selectedNpcData = nil
local function CreateList(subPanel, listName, listData, refreshFunc, enableColorPicker, extraBoxes, prioSlider, width, height, colorText, pos)
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, height or 390)
    if not pos then
        scrollFrame:SetPoint("TOPLEFT", 10, -10)
    else
        scrollFrame:SetPoint("TOPLEFT", -48, -10)
    end

    -- Create the content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}

    -- Function to update the background colors of the entries
    local function updateBackgroundColors()
        for i, button in ipairs(textLines) do
            local bg = button.bgImg
            if i % 2 == 0 then
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)  -- Dark color for even lines
            else
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)  -- Light color for odd lines
            end
        end
    end

    local function deleteEntry(dataEntry)
        if not dataEntry then return end
        -- Find and remove the entry from listData based on the reference
        for i, entry in ipairs(listData) do
            if entry == dataEntry then
                table.remove(listData, i)
                break
            end
        end
        contentFrame.refreshList()
    end

    local function createTextLineButton(npc, index, enableColorPicker)
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or 310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)
        button.npcData = npc

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg  -- Store the background texture for later color updates

        local addIcon
        local displayText = npc.id and npc.id or ""
        if listName == "auraBlacklist" or
        listName == "auraWhitelist" or
        listName == "auraColorList" or
        listName == "auraColorList" or
        listName == "castEmphasisList" or
        listName == "hideCastbarWhitelist" then
            addIcon = true
            if npc.id then
                button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:SetSpellByID(npc.id)
                    GameTooltip:AddLine(string.format(L["Spell_ID_Label"], npc.id), 1, 1, 1)
                    GameTooltip:Show()
                end)
                button:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)
            end
        end

        if addIcon then
            local iconTexture = button:CreateTexture(nil, "OVERLAY")
            iconTexture:SetSize(20, 20)  -- Same height as the button
            iconTexture:SetPoint("LEFT", button, "LEFT", 0, 0)

            -- Set the icon image
            if npc.id then
                iconTexture:SetTexture(GetSpellTexture(npc.id))
            elseif npc.name then
                iconTexture:SetTexture(GetSpellTexture(npc.name))
            end
        end

        if npc.name and npc.name ~= "" then
            displayText = npc.name .. (displayText ~= "" and " - " or "") .. displayText
        end
        if npc.comment and npc.comment ~= "" then
            displayText = npc.comment .. (displayText ~= "" and " - " or "") .. displayText
        end
        if (npc.name and npc.name ~= "") and (npc.comment and npc.comment ~= "") then
            if (npc.id and npc.id ~= "") then
                displayText = npc.name .. " (" .. npc.id .. ")"
            else
                displayText = npc.name
            end
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", addIcon and 25 or 5, 0)
        text:SetText(displayText)

        if listName == "auraWhitelist" then
            text:SetWidth(225)
            text:SetWordWrap(false)
            text:SetJustifyH("LEFT")
        end

        -- Initialize the text color and background color for this entry from npc table or with default values
        local entryColors = npc.entryColors or {}
        npc.entryColors = entryColors  -- Save the colors back to the npc data

        if not entryColors.text then
            entryColors.text = { r = 0, g = 1, b = 0 } -- Default to green color
        end

        -- Function to set the text color
        local function SetTextColor(r, g, b)
            r = r or 1
            b = b or 0
            g = g or 0.8196
            if colorText then
                if npc.flags and npc.flags.important then
                    text:SetTextColor(r, g, b)
                else
                    text:SetTextColor(1, 1, 0)  -- Keeping alpha consistent
                end
            else
                text:SetTextColor(1, 1, 0)  -- Keeping alpha consistent
            end
        end

        -- Set initial text and background colors from entryColors
        SetTextColor(entryColors.text.r, entryColors.text.g, entryColors.text.b)

        local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
        deleteButton:SetText("X")

        deleteButton:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                deleteEntry(button.npcData)
            else
                selectedLineIndex = button.npcData
                StaticPopup_Show("BBP_DELETE_NPC_CONFIRM_" .. listName)
            end
        end)

        if enableColorPicker then
            local colorPickerButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
            colorPickerButton:SetSize(50, 20)
            colorPickerButton:SetPoint("RIGHT", deleteButton, "LEFT", -5, 0)
            colorPickerButton:SetText(L["Color"])

            local colorPickerIcon = button:CreateTexture(nil, "ARTWORK")
            colorPickerIcon:SetAtlas("CircleMaskScalable")
            colorPickerIcon:SetSize(18, 17)
            colorPickerIcon:SetPoint("RIGHT", colorPickerButton, "LEFT", 0, -1)

                -- Function to update the icon's color
            local function UpdateIconColor(r, g, b)
                colorPickerIcon:SetVertexColor(r, g, b)
            end

            -- Initial color update for the icon
            local initialColor = entryColors.text
            UpdateIconColor(initialColor.r, initialColor.g, initialColor.b)

            -- Function to open the color picker
            local function OpenColorPicker()
                local colorData = entryColors.text or {}
                local r, g, b = colorData.r or 1, colorData.g or 1, colorData.b or 1
                local a = colorData.a or 1 -- Default alpha to 1 if not present

                local function updateColors()
                    entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a = r, g, b, a
                    SetTextColor(r, g, b)  -- Update text color
                    UpdateIconColor(r, g, b)
                    BBP.RefreshAllNameplates()  -- Refresh frames or elements that depend on these colors
                    if ColorPickerFrame.Content then
                        ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
                    end
                    BBP.auraListNeedsUpdate = true
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    updateColors()  -- Update colors based on the new selection
                end

                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha()
                    updateColors()  -- Update colors including the alpha value
                end

                local function cancelFunc(previousValues)
                    -- Revert to previous values if the selection is cancelled
                    if previousValues then
                        r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                        updateColors()  -- Reapply the previous colors
                    end
                end

                -- Store the initial values before showing the color picker
                ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

                -- Setup and show the color picker with the necessary callbacks and initial values
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r, g = g, b = b, opacity = a, hasOpacity = true,
                    swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
                })
            end
            colorPickerButton:SetScript("OnClick", OpenColorPicker)
        end

        if listName == "hideNPCsList" or listName == "hideNPCsWhitelist" then
            if not npc.flags then
                npc.flags = { murloc = false }
            end
            -- Create Checkbox P (Pandemic)
            local checkBoxMurloc = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxMurloc:SetSize(24, 24)
            checkBoxMurloc:SetPoint("RIGHT", deleteButton, "LEFT", -11, 0)

            -- Center the texture within the checkbox
            CreateTooltipTwo(checkBoxMurloc, L["Murloc_Icon"] .. " |A:newplayerchat-chaticon-newcomer:22:22|a", L["Tooltip_Murloc_Icon_Desc"], nil, "ANCHOR_TOPRIGHT")

            -- Handler for the P checkbox
            checkBoxMurloc:SetScript("OnClick", function(self)
                npc.flags.murloc = self:GetChecked() -- Save the state in the npc flags
            end)
            checkBoxMurloc:HookScript("OnClick", BBP.RefreshAllNameplates)

            -- Initialize state from npc flags
            if npc.flags.murloc then
                checkBoxMurloc:SetChecked(true)
            end
        end

        if extraBoxes then
            -- Ensure the npc.flags table exists
            if not npc.flags then
                npc.flags = { important = false, pandemic = false, enlarged = false }
            end

            -- Create Checkbox P (Pandemic)
            local checkBoxP = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxP:SetSize(24, 24)
            checkBoxP:SetPoint("RIGHT", deleteButton, "LEFT", 4, 0) -- Positioned first, to the left of deleteButton

            -- Create a texture for the checkbox
            checkBoxP.texture = checkBoxP:CreateTexture(nil, "ARTWORK", nil, 1)
            checkBoxP.texture:SetTexture(BBP.squareGreenGlow)
            checkBoxP.texture:SetDesaturated(true)
            checkBoxP.texture:SetVertexColor(1, 0, 0)
            checkBoxP.texture:SetSize(46, 46)
            checkBoxP.texture:SetPoint("CENTER", checkBoxP, "CENTER", -0.5, 0.5)
            CreateTooltipTwo(checkBoxP, L["Pandemic_Glow"] .. " |T"..BBP.PandemicIcon..":22:22:0:0|t", L["Tooltip_Check_For_A_Red_Glow_When_Desc"], nil, "ANCHOR_TOPRIGHT")

            -- Handler for the P checkbox
            checkBoxP:SetScript("OnClick", function(self)
                npc.flags.pandemic = self:GetChecked() -- Save the state in the npc flags
                BBP.RefreshAllNameplates()
            end)

            -- Initialize state from npc flags
            if npc.flags.pandemic then
                checkBoxP:SetChecked(true)
            end

            -- Create Checkbox I (Important)
            local checkBoxI = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxI:SetSize(24, 24)
            checkBoxI:SetPoint("RIGHT", checkBoxP, "LEFT", 3, 0) -- Positioned next to checkBoxP

            -- Create a texture for the checkbox
            checkBoxI.texture = checkBoxI:CreateTexture(nil, "ARTWORK", nil, 1)
            checkBoxI.texture:SetTexture(BBP.squareGreenGlow)
            checkBoxI.texture:SetSize(46, 46)
            checkBoxI.texture:SetDesaturated(true)
            checkBoxI.texture:SetPoint("CENTER", checkBoxI, "CENTER", -0.5, 0.5)
            CreateTooltipTwo(checkBoxI, L["Important_Glow"] .. " |T"..BBP.ImportantIcon..":22:22:0:0|t", L["Tooltip_Important_Glow_Desc"], L["Tooltip_Ctrl_Plus_Alt_Plus_Right_Click_SubText"], "ANCHOR_TOPRIGHT")

            -- Handler for the I checkbox
            checkBoxI:SetScript("OnClick", function(self)
                npc.flags.important = self:GetChecked() -- Save the state in the npc flags
            end)
            local function SetImportantBoxColor(r, g, b, a)
                if npc.flags and npc.flags.important then
                    checkBoxI.texture:SetVertexColor(r, g, b, a)
                else
                    checkBoxI.texture:SetVertexColor(0,1,0,1)
                end
            end
            checkBoxI:HookScript("OnClick", function()
                BBP.RefreshAllNameplates()
                SetTextColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, 1)
                SetImportantBoxColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a)
            end)

            -- Initialize state from npc flags
            if npc.flags.important then
                checkBoxI:SetChecked(true)
            end

            SetImportantBoxColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a)

            -- Function to open the color picker
            local function OpenColorPicker(isAll)
                BBP.needsUpdate = true

                if isAll and not BBP.allColorHook then
                    BBP.allColorHook = true
                    local okBtn      = ColorPickerOkayButton or ColorPickerFrame.Footer and ColorPickerFrame.Footer.OkayButton
                    local cancelBtn  = ColorPickerCancelButton or ColorPickerFrame.Footer and ColorPickerFrame.Footer.CancelButton
                    if okBtn then
                        okBtn:HookScript("OnClick", function()
                            if BBP._allColorActive and BBP._allColorPending then
                                local p = BBP._allColorPending
                                RecolorEntireAuraWhitelist(p.r, p.g, p.b, p.a)
                            end
                            BBP._allColorActive = false
                            BBP._allColorPending = nil
                        end)
                    end
                    if cancelBtn then
                        cancelBtn:HookScript("OnClick", function()
                            BBP._allColorActive = false
                            BBP._allColorPending = nil
                        end)
                    end
                end

                BBP._allColorActive  = isAll or false
                BBP._allColorPending = nil

                local okBtn = ColorPickerOkayButton or ColorPickerFrame.Footer and ColorPickerFrame.Footer.OkayButton
                if okBtn then
                    if not BBP._colorPickerOkText then
                        BBP._colorPickerOkText = okBtn:GetText()
                    end
                    if isAll then
                        okBtn:SetText(L["Color_All_Auras"])
                    else
                        okBtn:SetText(BBP._colorPickerOkText)
                    end
                end

                local colorData      = entryColors.text or {}
                local r, g, b        = colorData.r or 1, colorData.g or 1, colorData.b or 1
                local a              = colorData.a or 1
                local backup         = { r = r, g = g, b = b, a = a }

                local function updateRowPreview()
                    entryColors.text = entryColors.text or {}
                    entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a = r, g, b, a
                    SetTextColor(r, g, b)
                    SetImportantBoxColor(r, g, b, a)
                    BBP.RefreshAllNameplates()
                    if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorSwatchCurrent then
                        ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
                    end
                    BBP.auraListNeedsUpdate = true
                    if isAll then BBP._allColorPending = { r = r, g = g, b = b, a = a } end
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB(); updateRowPreview()
                end
                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha(); updateRowPreview()
                end
                local function cancelFunc()
                    r, g, b, a = backup.r, backup.g, backup.b, backup.a
                    updateRowPreview()
                    BBP._allColorActive = false
                    BBP._allColorPending = nil
                end

                ColorPickerFrame.previousValues = { r, g, b, a }
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r,
                    g = g,
                    b = b,
                    opacity = a,
                    hasOpacity = true,
                    swatchFunc = swatchFunc,
                    opacityFunc = opacityFunc,
                    cancelFunc = cancelFunc
                })

                updateRowPreview()
            end

            checkBoxI:HookScript("OnMouseDown", function(self, button)
                if button ~= "RightButton" then return end
                local isAll = IsControlKeyDown() and IsAltKeyDown()
                OpenColorPicker(isAll)
            end)

            -- Create Checkbox C (Compacted)
            local checkBoxC = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxC:SetSize(24, 24)
            checkBoxC:SetPoint("RIGHT", checkBoxI, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxC, L["Tooltip_Compact_Aura_Title"] .. " |T"..BBP.CompactIcon..":22:22:0:0|t", L["Tooltip_Check_To_Make_The_Aura_Half_Desc"], L["Tooltip_You_Can_Turn_Off_Half_Size_SubText"], "ANCHOR_TOPRIGHT")

            -- Initialize state from npc flags
            if npc.flags.compacted then
                checkBoxC:SetChecked(true)
            end

            -- Create Checkbox E (Enlarged)
            local checkBoxE = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxE:SetSize(24, 24)
            checkBoxE:SetPoint("RIGHT", checkBoxC, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxE, L["Enlarged_Aura_Icon"] .. " |T"..BBP.EnlargedIcon..":22:22:0:0|t", L["Tooltip_Enlarged_Aura_Icon_Desc"], L["Tooltip_You_Can_Turn_Off_Square_And_SubText"], "ANCHOR_TOPRIGHT")

            -- Handler for the C checkbox
            checkBoxC:SetScript("OnClick", function(self)
                npc.flags.compacted = self:GetChecked()
                checkBoxE:SetChecked(false)
                npc.flags.enlarged = false
                BBP.RefreshAllNameplates()
            end)

            -- Handler for the E checkbox
            checkBoxE:SetScript("OnClick", function(self)
                npc.flags.enlarged = self:GetChecked()
                checkBoxC:SetChecked(false)
                npc.flags.compacted = false
                BBP.RefreshAllNameplates()
            end)

            -- Initialize state from npc flags
            if npc.flags.enlarged then
                checkBoxE:SetChecked(true)
            end

            -- Create Checkbox Only Mine
            local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxOnlyMine:SetSize(24, 24)
            checkBoxOnlyMine:SetPoint("RIGHT", checkBoxE, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxOnlyMine, L["Only_My_Aura_Icon"] .. " |T"..BBP.OwnAuraIcon..":22:22:0:0|t", L["Tooltip_Only_My_Aura"], nil, "ANCHOR_TOPRIGHT")

            -- Handler for the E checkbox
            checkBoxOnlyMine:SetScript("OnClick", function(self)
                npc.flags.onlyMine = self:GetChecked()
                BBP.RefreshAllNameplates()
            end)

            -- Initialize state from npc flags
            if npc.flags.onlyMine then
                checkBoxOnlyMine:SetChecked(true)
            end
        end

        if prioSlider then
            local prioritySlider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
            prioritySlider:SetSize(100, 16)
            prioritySlider:SetPoint("RIGHT", colorPickerButton or deleteButton, "LEFT", -75, 0)
            prioritySlider:SetOrientation("HORIZONTAL")
            prioritySlider:SetMinMaxValues(1, 10)
            prioritySlider:SetValueStep(1)
            prioritySlider:SetValue(npc.priority or 1) -- Set the default priority to 1 if not specified
            prioritySlider:SetObeyStepOnDrag(true)
            prioritySlider.Low:SetText("")
            prioritySlider.High:SetText("")
            CreateTooltipTwo(prioritySlider, L["Priority_Value"], L["Tooltip_Priority_Value_Desc"])

            local priorityText = prioritySlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            priorityText:SetPoint("RIGHT", prioritySlider, "LEFT", -5, 0)
            priorityText:SetText(prioritySlider:GetValue())
            priorityText:SetTextColor(1, 0.8196, 0, 1)

            prioritySlider:SetScript("OnValueChanged", function(self, value)
                local newValue = math.floor(value + 0.5)  -- Round to the nearest integer
                self:SetValue(newValue)
                priorityText:SetText(newValue)
                npc.priority = newValue
                BBP.auraListNeedsUpdate = true
            end)

            button.prioritySlider = prioritySlider

            -- Create Checkbox Only Mine
            local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxOnlyMine:SetSize(24, 24)
            checkBoxOnlyMine:SetPoint("RIGHT", prioritySlider, "LEFT", -16, 0)
            CreateTooltipTwo(checkBoxOnlyMine, L["Only_My_Aura_Icon"] .. " |T"..BBP.OwnAuraIcon..":22:22:0:0|t", L["Tooltip_Only_My_Aura_Icon_Desc"], nil, "ANCHOR_TOPRIGHT")

            -- Handler for the E checkbox
            checkBoxOnlyMine:SetScript("OnClick", function(self)
                npc.onlyMine = self:GetChecked()
                BBP.auraListNeedsUpdate = true
                BBP.RefreshAllNameplates()
            end)

            -- Initialize state from npc flags
            if npc.onlyMine then
                checkBoxOnlyMine:SetChecked(true)
            end
        end

        button.deleteButton = deleteButton
        table.insert(textLines, button)
        updateBackgroundColors()  -- Update background colors after adding a new entry
    end

    local function updateNamesInListData()
        if (listName == "auraWhitelist" or listName == "auraBlacklist" or listName == "auraColorList" or listName == "castEmphasisList" or listName == "hideCastbarList" or listName == "hideCastbarWhitelist") then
            for _, entry in ipairs(listData) do
                if entry.id and (not entry.name or entry.name == "") then
                    local spellName = GetSpellInfo(entry.id)
                    if spellName then
                        entry.name = spellName  -- Update the name field with the fetched spell name
                    end
                end
            end
        end
    end

    local function getSortedNpcList()
        updateNamesInListData()

        table.sort(listData, function(a, b)
            local nameA = a.name:lower()
            local nameB = b.name:lower()
            return nameA < nameB
        end)

        return listData
    end

    local sortedListData = getSortedNpcList()
    for i, npc in ipairs(sortedListData) do
        createTextLineButton(npc, i, enableColorPicker)
    end
    local currentSearchFilter = ""
    local function refreshList()
        -- Clear all existing buttons to reuse or recreate them as needed
        for _, button in ipairs(textLines) do
            button:Hide()
        end
        wipe(textLines)

        -- Filter listData based on the current search filter
        local filteredListData = {}
        if currentSearchFilter and currentSearchFilter ~= "" then
            local safeFilter = currentSearchFilter:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
            for _, entry in ipairs(listData) do
                local name = entry.name and entry.name:lower() or ""
                local id = entry.id and tostring(entry.id):lower() or ""
                local comment = entry.comment and entry.comment:lower() or ""
                if name:match(safeFilter) or id:match(safeFilter) or comment:match(safeFilter) then
                    table.insert(filteredListData, entry)
                end
            end
        else
            filteredListData = listData
        end

            table.sort(filteredListData, function(a, b)
                local nameA = a.name:lower()
                local nameB = b.name:lower()
                return nameA < nameB
            end)

        -- Recreate the UI elements
        for i, npc in ipairs(filteredListData) do
            createTextLineButton(npc, i, enableColorPicker)
        end

        local newHeight = #filteredListData * 20
        contentFrame:SetHeight(newHeight)
    end
    contentFrame.refreshList = refreshList
    BBP[listName.."Refresh"] = refreshList

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize((width and width - 62) or (322 - 62), 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)

    -- Create static popup dialogs for duplicate and delete confirmations
    StaticPopupDialogs["BBP_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = L["Popup_This_Name_Or_NpcID_Is_Already"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            currentSearchFilter = ""
            editBox:SetText("")
            deleteEntry(selectedNpcData)
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
            deleteEntry(selectedLineIndex)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    if listName == "auraBlacklist" or
    listName == "auraWhitelist" or
    listName == "auraColorList" or
    listName == "auraColorList" or
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
        selectedLineIndex = nil
        local name, comment = strsplit("/", inputText, 2)
        name = strtrim(name or "")
        comment = strtrim(comment or "")
        local id = tonumber(name)

        -- Check if there's a numeric ID within the name and clear the name if found
        if id then
            local spellName = GetSpellInfo(id)
            if spellName and (listName == "auraWhitelist" or listName == "auraBlacklist" or listName == "auraColorList" or listName == "castEmphasisList" or listName == "hideCastbarList" or listName == "hideCastbarWhitelist") then
                name = spellName
            else
                name = ""
            end
        end

        local isDuplicate = false
        if (name ~= "" or id) then

            for i, npc in ipairs(listData) do
                if (id and npc.id == id) or (not id and strlower(npc.name) == strlower(name)) then
                    isDuplicate = true
                    selectedNpcData = npc
                    break
                end
            end

            if isDuplicate then
                StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_" .. listName)
            else
                local newEntry = { name = name, id = id, comment = comment, flags = { important = false, pandemic = false } }
                if prioSlider then
                    newEntry = { name = name, id = id, comment = comment, flags = { important = false, pandemic = false }, priority = 1 }
                end
                table.insert(listData, newEntry)
                createTextLineButton(newEntry, #textLines + 1, enableColorPicker)
                refreshFunc()
            end
            BBP.auraListNeedsUpdate = true
        end


        if not isDuplicate then
            currentSearchFilter = ""
            editBox:SetText("")
            refreshList()
        end
    end

    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
        refreshList()
    end)

    local function searchList(searchText)
        currentSearchFilter = searchText:lower()
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

        local groupIds = textLines[index].groupIds or {textLines[index].npcId}
        for _, id in ipairs(groupIds) do
            npcList[id] = nil
        end
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

    local function updateImportantFlag(npcIdOrIds, importantFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.important = importantFlag
            end
        end
        refreshFunc()
    end

    local function updateHideIconFlag(npcIdOrIds, hideIconFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.hideIcon = hideIconFlag
            end
        end
        refreshFunc()
    end

    local function updateHideHpFlag(npcIdOrIds, hideHpFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.hideHp = hideHpFlag
            end
        end
        refreshFunc()
    end

    local function updateIconOnlyFlag(npcIdOrIds, iconOnlyFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.iconOnly = iconOnlyFlag
            end
        end
        refreshFunc()
    end

    local function updateEntryColor(npcIdOrIds, color)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.color = color
            end
        end
        refreshFunc()
    end

    local function createNpcLineButton(npcId, npcData, index, groupIds)
        groupIds = groupIds or {npcId}
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or 310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg
        button.groupIds = groupIds

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
        local idText = tostring(npcId)
        if #groupIds > 1 then
            local idParts = {}
            for _, id in ipairs(groupIds) do
                table.insert(idParts, tostring(id))
            end
            idText = table.concat(idParts, ", ")
        end
        text:SetText((npcData.name .. " (" .. idText .. ")") or "")

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
            npcEditFrame = CreateFrame("Frame", "NPC_EditFrame", UIParent, "BasicFrameTemplateWithInset")
            npcEditFrame:SetSize(350, 275)
            npcEditFrame:SetPoint("CENTER")
            npcEditFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            npcEditFrame:SetFrameLevel(550)

            -- Make the frame movable
            npcEditFrame:SetMovable(true)
            npcEditFrame:EnableMouse(true)
            npcEditFrame:RegisterForDrag("LeftButton")
            npcEditFrame:SetScript("OnDragStart", npcEditFrame.StartMoving)
            npcEditFrame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
            end)

            -- Creating a custom title for the frame
            local title = npcEditFrame:CreateFontString(nil, "OVERLAY")
            title:SetFontObject("GameFontHighlight")
            title:SetPoint("TOPLEFT", npcEditFrame, "TOPLEFT", 7, -7)
            title:SetText(L["Edit_NPC_Details"])
            npcEditFrame.title = title

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

            local pulseLabel, pulseEditBox = CreatePropertyField(npcEditFrame, L["Pulse_Colon"], iconLabel, 0, -10, 50, 20)
            npcEditFrame.pulseEditBox = pulseEditBox
            CreateTooltipTwo(pulseEditBox, L["Pulse"], L["Tooltip_Pulse_Desc"])

            local GlowText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            GlowText:SetPoint("TOPLEFT", pulseLabel, "BOTTOMLEFT", 0, -10)
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
                local currentGroupIds = npcEditFrame.currentGroupIds or {npcEditFrame.currentNpcId}

                ColorPickerFrame:SetupColorPickerAndShow({
                    r = currentColor[1], g = currentColor[2], b = currentColor[3],
                    hasOpacity = false, -- Assuming opacity is not needed; set to true if needed
                    swatchFunc = function()
                        local r, g, b = ColorPickerFrame:GetColorRGB()
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentGroupIds, {r, g, b})
                        npcEditFrame.currentColor = {r, g, b} -- Update the current color
                        BBP.refreshNpcList()
                    end,
                    cancelFunc = function(previousValues)
                        local r, g, b = previousValues.r, previousValues.g, previousValues.b
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentGroupIds, {r, g, b})
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

        local function PopulateEditFrame(npcId, editGroupIds)
            local npcData = npcList[npcId]
            if not npcData then return end
            if not npcEditFrame then return end
            npcEditFrame.currentNpcId = npcId
            npcEditFrame.currentGroupIds = editGroupIds or {npcId}

            npcEditFrame.iconTexture:SetTexture(npcData.icon)
            npcEditFrame.sizeEditBox:SetText(npcData.size or "")
            npcEditFrame.durationEditBox:SetText(npcData.duration or "")
            npcEditFrame.nameEditBox:SetText(npcData.name or "")
            npcEditFrame.pulseEditBox:SetText(npcData.pulse or "")
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
                local newDuration = tonumber(npcEditFrame.durationEditBox:GetText())
                local newIcon = tonumber(npcEditFrame.iconEditBox:GetText())
                local newName = npcEditFrame.nameEditBox:GetText()
                local newPulse = tonumber(npcEditFrame.pulseEditBox:GetText())

                for _, gid in ipairs(npcEditFrame.currentGroupIds) do
                    if npcList[gid] then
                        if newSize then npcList[gid].size = newSize end
                        if newDuration then npcList[gid].duration = (newDuration == 0) and nil or newDuration end
                        if newIcon then npcList[gid].icon = newIcon end
                        if newName then npcList[gid].name = newName end
                        npcList[gid].pulse = (newPulse and newPulse > 0) and newPulse or nil
                    end
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

            npcEditFrame.pulseEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.pulseEditBox:ClearFocus()
            end)

            npcEditFrame.hideIconCheckbox:SetScript("OnClick", function(self)
                updateHideIconFlag(npcEditFrame.currentGroupIds, self:GetChecked())
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
                updateHideHpFlag(npcEditFrame.currentGroupIds, self:GetChecked())
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
                updateImportantFlag(npcEditFrame.currentGroupIds, self:GetChecked())
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
                local currentGroupIds = npcEditFrame.currentGroupIds
                local currentColor = npcEditFrame.currentColor
                local r, g, b = currentColor[1], currentColor[2], currentColor[3]
                updateEntryColor(currentGroupIds, {r, g, b})
                updateNpcData()
                npcEditFrame:Hide()
            end)

        end

        local function ShowEditFrame(npcId, editGroupIds)
            if not npcEditFrame then
                CreateEditFrame()
            end

            PopulateEditFrame(npcId, editGroupIds)
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
            ShowEditFrame(npcId, groupIds)
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
            updateHideIconFlag(groupIds, self:GetChecked())
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
            updateImportantFlag(groupIds, self:GetChecked())
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
            updateHideHpFlag(groupIds, self:GetChecked())
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
            updateIconOnlyFlag(groupIds, self:GetChecked())
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
        local defaultList = BBP.defaultTotemIndicatorNpcList or {}
        local grouped = {}
        local groupOrder = {}
        local ungrouped = {}

        for npcId, npcData in pairs(npcList) do
            if npcData.duration == 0 then
                npcData.duration = nil
            end
            if defaultList[npcId] then
                local name = npcData.name:lower()
                if not grouped[name] then
                    grouped[name] = {ids = {}, npcData = npcData, primaryId = npcId}
                    table.insert(groupOrder, name)
                end
                table.insert(grouped[name].ids, npcId)
            else
                table.insert(ungrouped, {npcId = npcId, npcData = npcData, groupIds = {npcId}})
            end
        end

        local sortableNpcList = {}
        for _, name in ipairs(groupOrder) do
            local group = grouped[name]
            table.sort(group.ids)
            table.insert(sortableNpcList, {npcId = group.ids[1], npcData = group.npcData, groupIds = group.ids})
        end
        for _, entry in ipairs(ungrouped) do
            table.insert(sortableNpcList, entry)
        end

        table.sort(sortableNpcList, function(a, b)
            return a.npcData.name:lower() < b.npcData.name:lower()
        end)

        return sortableNpcList
    end

    local sortedNpcList = getSortedNpcList()
    for _, entry in ipairs(sortedNpcList) do
        local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1, entry.groupIds)
        button.npcId = entry.npcId
        button.groupIds = entry.groupIds
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
            local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1, entry.groupIds)
            button.npcId = entry.npcId
            button.groupIds = entry.groupIds
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
            if line.groupIds then
                for _, gid in ipairs(line.groupIds) do
                    if gid == npcId then
                        selectedLineIndex = index
                        StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_TOTEM")
                        return
                    end
                end
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

        local groupIds = textLines[index].groupIds or {textLines[index].npcId}
        for _, id in ipairs(groupIds) do
            npcList[id] = nil
        end
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

    local function updateImportantFlag(npcIdOrIds, importantFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.important = importantFlag
            end
        end
        refreshFunc()
    end

    local function updateHideIconFlag(npcIdOrIds, hideIconFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.hideIcon = hideIconFlag
            end
        end
        refreshFunc()
    end

    local function updateHideHpFlag(npcIdOrIds, hideHpFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.hideHp = hideHpFlag
            end
        end
        refreshFunc()
    end

    local function updateIconOnlyFlag(npcIdOrIds, iconOnlyFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.iconOnly = iconOnlyFlag
            end
        end
        refreshFunc()
    end

    local function updatehpWidthFlag(npcIdOrIds, widthOnFlag)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.widthOn = widthOnFlag
            end
        end
        refreshFunc()
    end

    local function updateEntryColor(npcIdOrIds, color)
        local ids = type(npcIdOrIds) == "table" and npcIdOrIds or {npcIdOrIds}
        for _, npcId in ipairs(ids) do
            local npcData = npcList[npcId]
            if npcData then
                npcData.color = color
            end
        end
        refreshFunc()
    end

    local function createNpcLineButton(npcId, npcData, index, groupIds)
        groupIds = groupIds or {npcId}
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or 310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg
        button.groupIds = groupIds

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
        text:SetText(npcData.name or "")

        -- Tooltip showing NPC ID(s) on mouseover
        local idText = tostring(npcId)
        if #groupIds > 1 then
            local idParts = {}
            for _, id in ipairs(groupIds) do
                table.insert(idParts, tostring(id))
            end
            idText = table.concat(idParts, ", ")
        end
        button:EnableMouse(true)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            GameTooltip:AddLine(string.format(L["NPC_IDs_Label"], idText), 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

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
            npcEditFrame = CreateFrame("Frame", "NPC_EditFrame", UIParent, "BasicFrameTemplateWithInset")
            npcEditFrame:SetSize(350, 275)
            npcEditFrame:SetPoint("CENTER")
            npcEditFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            npcEditFrame:SetFrameLevel(550)

            -- Make the frame movable
            npcEditFrame:SetMovable(true)
            npcEditFrame:EnableMouse(true)
            npcEditFrame:RegisterForDrag("LeftButton")
            npcEditFrame:SetScript("OnDragStart", npcEditFrame.StartMoving)
            npcEditFrame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
            end)

            -- Creating a custom title for the frame
            local title = npcEditFrame:CreateFontString(nil, "OVERLAY")
            title:SetFontObject("GameFontHighlight")
            title:SetPoint("TOPLEFT", npcEditFrame, "TOPLEFT", 7, -7)
            title:SetText(L["Edit_NPC_Details"])
            npcEditFrame.title = title

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

            local pulseLabel, pulseEditBox = CreatePropertyField(npcEditFrame, L["Pulse_Colon"], iconLabel, 0, -10, 50, 20)
            npcEditFrame.pulseEditBox = pulseEditBox
            CreateTooltipTwo(pulseEditBox, L["Pulse"], L["Tooltip_Pulse_Desc"])

            local GlowText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            GlowText:SetPoint("TOPLEFT", pulseLabel, "BOTTOMLEFT", 0, -10)
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
                local currentGroupIds = npcEditFrame.currentGroupIds or {npcEditFrame.currentNpcId}

                ColorPickerFrame:SetupColorPickerAndShow({
                    r = currentColor[1], g = currentColor[2], b = currentColor[3],
                    hasOpacity = false, -- Assuming opacity is not needed; set to true if needed
                    swatchFunc = function()
                        local r, g, b = ColorPickerFrame:GetColorRGB()
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentGroupIds, {r, g, b})
                        npcEditFrame.currentColor = {r, g, b} -- Update the current color
                        BBP.refreshNpcList()
                    end,
                    cancelFunc = function(previousValues)
                        local r, g, b = previousValues.r, previousValues.g, previousValues.b
                        text:SetTextColor(r, g, b)
                        npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                        npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                        updateEntryColor(currentGroupIds, {r, g, b})
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

        local function PopulateEditFrame(npcId, editGroupIds)
            local npcData = npcList[npcId]
            if not npcData then return end
            if not npcEditFrame then return end
            npcEditFrame.currentNpcId = npcId
            npcEditFrame.currentGroupIds = editGroupIds or {npcId}

            npcEditFrame.iconTexture:SetTexture(npcData.icon)
            npcEditFrame.sizeEditBox:SetText(npcData.size or "")
            npcEditFrame.durationEditBox:SetText(npcData.duration or "")
            npcEditFrame.nameEditBox:SetText(npcData.name or "")
            npcEditFrame.pulseEditBox:SetText(npcData.pulse or "")
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
                local newDuration = tonumber(npcEditFrame.durationEditBox:GetText())
                local newIcon = tonumber(npcEditFrame.iconEditBox:GetText())
                local newName = npcEditFrame.nameEditBox:GetText()
                local newPulse = tonumber(npcEditFrame.pulseEditBox:GetText())

                for _, gid in ipairs(npcEditFrame.currentGroupIds) do
                    if npcList[gid] then
                        if newSize then npcList[gid].size = newSize end
                        if newDuration then npcList[gid].duration = (newDuration == 0) and nil or newDuration end
                        if newIcon then npcList[gid].icon = newIcon end
                        if newName then npcList[gid].name = newName end
                        npcList[gid].pulse = (newPulse and newPulse > 0) and newPulse or nil
                    end
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

            npcEditFrame.pulseEditBox:SetScript("OnEnterPressed", function()
                updateNpcData()
                npcEditFrame.pulseEditBox:ClearFocus()
            end)

            npcEditFrame.hideIconCheckbox:SetScript("OnClick", function(self)
                updateHideIconFlag(npcEditFrame.currentGroupIds, self:GetChecked())
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
                updateHideHpFlag(npcEditFrame.currentGroupIds, self:GetChecked())
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
                updateImportantFlag(npcEditFrame.currentGroupIds, self:GetChecked())
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
                local currentGroupIds = npcEditFrame.currentGroupIds
                local currentColor = npcEditFrame.currentColor
                local r, g, b = currentColor[1], currentColor[2], currentColor[3]
                updateEntryColor(currentGroupIds, {r, g, b})
                updateNpcData()
                npcEditFrame:Hide()
            end)

        end

        local function ShowEditFrame(npcId, editGroupIds)
            if not npcEditFrame then
                CreateEditFrame()
            end

            PopulateEditFrame(npcId, editGroupIds)
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
            ShowEditFrame(npcId, groupIds)
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
            updateHideIconFlag(groupIds, self:GetChecked())
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
            updateImportantFlag(groupIds, self:GetChecked())
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
            updateHideHpFlag(groupIds, self:GetChecked())
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
            updateIconOnlyFlag(groupIds, self:GetChecked())
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
            updatehpWidthFlag(groupIds, self:GetChecked())
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
        local defaultList = BBP.defaultTotemIndicatorNpcList or {}
        local groupedByName = {}
        local groupOrder = {}

        for npcId, npcData in pairs(npcList) do
            if npcData.duration == 0 then
                npcData.duration = nil
            end
            if defaultList[npcId] then
                local key = npcData.name:lower()
                if not groupedByName[key] then
                    groupedByName[key] = { npcId = npcId, npcData = npcData, groupIds = {npcId} }
                    table.insert(groupOrder, key)
                else
                    table.insert(groupedByName[key].groupIds, npcId)
                end
            else
                table.insert(sortableNpcList, {npcId = npcId, npcData = npcData, groupIds = {npcId}})
            end
        end

        for _, key in ipairs(groupOrder) do
            table.insert(sortableNpcList, groupedByName[key])
        end

        table.sort(sortableNpcList, function(a, b)
            return a.npcData.name:lower() < b.npcData.name:lower()
        end)

        return sortableNpcList
    end

    local sortedNpcList = getSortedNpcList()
    for _, entry in ipairs(sortedNpcList) do
        local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1, entry.groupIds)
        button.npcId = entry.npcId
        button.groupIds = entry.groupIds
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
            local button = createNpcLineButton(entry.npcId, entry.npcData, #textLines + 1, entry.groupIds)
            button.npcId = entry.npcId
            button.groupIds = entry.groupIds
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
                selectedLineIndex = index
                StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_TOTEM")
                return
            end
            if line.groupIds then
                for _, gid in ipairs(line.groupIds) do
                    if gid == npcId then
                        selectedLineIndex = index
                        StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_TOTEM")
                        return
                    end
                end
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

    searchFrame:HookScript("OnHide", function()
        for popup, panel in pairs(settingsPopups) do
            if not panel:IsShown() then
                popup:Hide()
            end
        end
    end)

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
                CreateTooltipTwo(resultDropdown, dropdown.tooltipTitle or data.label, dropdown.tooltipMainText, nil, nil, nil, nil, SearchCategoryOf(dropdown))
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
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, data.checkbox.tooltipMainText, data.checkbox.tooltipSubText, nil, data.checkbox.tooltipCVarName, nil, SearchCategoryOf(data.checkbox))
                elseif data.checkbox.tooltipTitle then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, nil, nil, nil, nil, nil, SearchCategoryOf(data.checkbox))
                else
                    CreateTooltipTwo(resultCheckBox, data.label, nil, nil, nil, nil, nil, SearchCategoryOf(data.checkbox))
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
                    CreateTooltipTwo(resultSlider, data.slider.tooltipTitle, data.slider.tooltipMainText, data.slider.tooltipSubText, nil, data.slider.tooltipCVarName, nil, SearchCategoryOf(data.slider))
                elseif data.slider.tooltipTitle then
                    CreateTooltipTwo(resultSlider, data.slider.tooltipTitle, nil, nil, nil, nil, nil, SearchCategoryOf(data.slider))
                else
                    CreateTooltipTwo(resultSlider, data.label, nil, nil, nil, nil, nil, SearchCategoryOf(data.slider))
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
    frame.streamerText:SetPoint("TOP", frame.coreText, "BOTTOM", 0, -80)
    frame.streamerText:SetText(L["Profile_Streamers"])

    frame.infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.infoText:SetPoint("BOTTOM", frame, "BOTTOM", 2, 39)
    frame.infoText:SetText(L["Profile_Info_Message"])
    frame.infoText:SetWidth(100)

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
        frame.infoText:SetWidth(145)
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

    -- Replace corner
    local atlasName = frame.NineSlice.TopLeftCorner:GetAtlas()
    if atlasName then
        local info = C_Texture.GetAtlasInfo(atlasName)
        if info then
            frame.NineSlice.TopRightCorner:Hide()
            local cornerReplacement = frame.NineSlice:CreateTexture(nil, "BORDER")
            cornerReplacement:SetSize(frame.NineSlice.TopRightCorner:GetSize())
            cornerReplacement:SetPoint("TOPRIGHT", frame.NineSlice.TopRightCorner, "TOPRIGHT", 4, 0)
            cornerReplacement:SetPoint("TOPLEFT", frame.NineSlice.TopEdge, "TOPRIGHT", 0, 0)
            cornerReplacement:SetTexture(info.file)
            cornerReplacement:SetTexCoord(info.rightTexCoord, info.leftTexCoord, info.topTexCoord, info.bottomTexCoord)
        end
    end

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

    local alpha = BetterBlizzPlates:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    alpha:SetPoint("CENTER", 0, 0)
    alpha:SetText("BETA")
    alpha:SetFont(STANDARD_TEXT_FONT, 156)
    alpha:SetScale(1.4)
    alpha:SetAlpha(0.1)

    local alpha2 = BetterBlizzPlates:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    alpha2:SetPoint("BOTTOM", SettingsPanel, "TOP", 0, 0)
    alpha2:SetText(string.format(L["Classic_Beta_Notice"], BBP.isMoP and "MoP" or BBP.isTBC and "TBC" or "Cata"))
    alpha2:SetFont(STANDARD_TEXT_FONT, 20, "THINOUTLINE")
    alpha2:Hide()
    BetterBlizzPlates:HookScript("OnShow",function()
        alpha2:Show()
    end)
    BetterBlizzPlates:HookScript("OnHide",function()
        alpha2:Hide()
    end)

    CreateSearchFrame()

    if BetterBlizzPlates.titleText then
        BetterBlizzPlates.titleText:Hide()
        BetterBlizzPlates.loadGUI:Hide()
    end

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

    local removeRealmNames = CreateCheckbox("removeRealmNames", L["Hide_Realm"], BetterBlizzPlates)
    removeRealmNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local healthNumbers = CreateCheckbox("healthNumbers", L["Health_Numbers"], BetterBlizzPlates, nil, BBP.ToggleHealthNumbers)
    healthNumbers:SetPoint("LEFT", removeRealmNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(healthNumbers, L["Show_Health_Numbers"], L["Tooltip_Show_Health_Numbers_Desc_2"])

    local classicNameplates = CreateCheckbox("classicNameplates", L["Use_Classic_Nameplates"], BetterBlizzPlates)
    classicNameplates:SetPoint("TOPLEFT", removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicNameplates, L["Classic_Nameplates"], L["Tooltip_Classic_Nameplates_Desc_2"])

    local function CreateLevelOptionsWindow(name, title, width, height)
        local window = CreateFrame("Frame", name, UIParent, "DefaultPanelFlatTemplate")
        window.name = L["Search_Name_General"]
        window:SetSize(width, height)
        window:SetPoint("CENTER")
        window:SetFrameStrata("FULLSCREEN_DIALOG")
        window:SetFrameLevel(550)
        window:SetIgnoreParentAlpha(true)
        window:SetTitle(title)
        window:EnableMouse(true)
        window:SetMovable(true)
        window:SetClampedToScreen(true)
        window:RegisterForDrag("LeftButton")
        window:SetScript("OnDragStart", function(self) self:StartMoving() end)
        window:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

        window.closeButton = CreateFrame("Button", nil, window, "UIPanelCloseButton")
        window.closeButton:SetFrameLevel((window.TitleContainer or window):GetFrameLevel() + 10)
        window.closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
        window.closeButton:SetScript("OnClick", function()
            window:Hide()
        end)

        window.bg = window:CreateTexture(nil, "BACKGROUND")
        window.bg:SetPoint("TOPLEFT", window, "TOPLEFT", 7, -3)
        window.bg:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -3, 3)
        window.bg:SetColorTexture(0.08, 0.08, 0.08, 1)
        return window
    end

    local levelTextOptionsFrame
    local function OpenLevelTextOptionsWindow()
        if levelTextOptionsFrame then
            levelTextOptionsFrame:SetShown(not levelTextOptionsFrame:IsShown())
            return
        end
        levelTextOptionsFrame = CreateLevelOptionsWindow("BBPLevelTextOptionsFrame", L["Level_Text_Options"], 200, 270)

        local levelTextAnchor = CreateAnchorDropdown(
            "BBPLevelTextAnchorDropdown",
            levelTextOptionsFrame,
            "LEFT",
            "levelTextAnchor",
            BBP.UpdateAllLevelFrames,
            { anchorFrame = levelTextOptionsFrame, x = -2, y = -50, label = L["Anchor"] },
            65
        )
        CreateTooltipTwo(levelTextAnchor, L["Level_Text_Anchor"], L["Tooltip_Level_Text_Anchor_Desc"])

        local levelTextRelativeAnchor = CreateAnchorDropdown(
            "BBPLevelTextRelativeAnchorDropdown",
            levelTextOptionsFrame,
            "RIGHT",
            "levelTextRelativeAnchor",
            BBP.UpdateAllLevelFrames,
            { anchorFrame = levelTextOptionsFrame, x = 88, y = -50, label = L["Healthbar"] },
            65
        )
        CreateTooltipTwo(levelTextRelativeAnchor, L["Healthbar_Anchor"], L["Tooltip_Healthbar_Anchor_Desc"])

        local levelTextSize = CreateSlider(levelTextOptionsFrame, L["Size"], 4, 24, 0.5, "levelTextSize", nil, 150)
        levelTextSize:SetPoint("TOPLEFT", levelTextOptionsFrame, "TOPLEFT", 24, -105)
        CreateTooltipTwo(levelTextSize, L["Level_Text_Size"], L["Tooltip_Level_Text_Size_Desc_2"], L["Tooltip_Pets_Width_SubText"])

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
            BBP.UpdateAllLevelFrames()
        end)
        CreateTooltipTwo(levelTextReset, L["Reset"], L["Tooltip_Reset_Desc"])

        levelTextOptionsFrame:Show()
    end

    local levelEliteIconOptionsFrame
    local function OpenLevelEliteIconOptionsWindow()
        if levelEliteIconOptionsFrame then
            levelEliteIconOptionsFrame:SetShown(not levelEliteIconOptionsFrame:IsShown())
            return
        end
        levelEliteIconOptionsFrame = CreateLevelOptionsWindow("BBPLevelEliteIconOptionsFrame", L["Elite_Icon_Options"], 180, 290)

        local levelEliteIconWidth = CreateSlider(levelEliteIconOptionsFrame, L["Width"], -30, 40, 1, "levelEliteIconWidth", nil, 150)
        levelEliteIconWidth:SetPoint("TOPLEFT", levelEliteIconOptionsFrame, "TOPLEFT", 14, -45)
        CreateTooltipTwo(levelEliteIconWidth, L["Elite_Icon_Width"], L["Tooltip_Normal_Elite_Icon_Width"], L["Tooltip_Pets_Width_SubText"])

        local levelEliteIconHeight = CreateSlider(levelEliteIconOptionsFrame, L["Height"], -30, 40, 1, "levelEliteIconHeight", nil, 150)
        levelEliteIconHeight:SetPoint("TOPLEFT", levelEliteIconWidth, "BOTTOMLEFT", 0, -17)
        CreateTooltipTwo(levelEliteIconHeight, L["Elite_Icon_Height"], L["Tooltip_Normal_Elite_Icon_Height"], L["Tooltip_Pets_Width_SubText"])

        local levelEliteIconXPos = CreateSlider(levelEliteIconOptionsFrame, L["X_Offset"], -30, 30, 0.5, "levelEliteIconXPos", nil, 150)
        levelEliteIconXPos:SetPoint("TOPLEFT", levelEliteIconHeight, "BOTTOMLEFT", 0, -17)
        CreateTooltipTwo(levelEliteIconXPos, L["Elite_Icon_X_Offset"], L["Tooltip_Elite_Icon_X_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

        local levelEliteIconYPos = CreateSlider(levelEliteIconOptionsFrame, L["Y_Offset"], -30, 30, 0.5, "levelEliteIconYPos", nil, 150)
        levelEliteIconYPos:SetPoint("TOPLEFT", levelEliteIconXPos, "BOTTOMLEFT", 0, -17)
        CreateTooltipTwo(levelEliteIconYPos, L["Elite_Icon_Y_Offset"], L["Tooltip_Elite_Icon_Y_Offset_Desc"], L["Tooltip_Pets_Width_SubText"])

        local levelEliteIconLeftSide = CreateCheckbox("levelEliteIconLeftSide", L["Attach_Elite_Icon_Left_Side"], levelEliteIconOptionsFrame, nil, BBP.UpdateAllLevelFrames)
        levelEliteIconLeftSide:SetPoint("TOPLEFT", levelEliteIconYPos, "BOTTOMLEFT", -4, -12)
        CreateTooltipTwo(levelEliteIconLeftSide, L["Attach_Elite_Icon_Left_Side"], L["Tooltip_Attach_Elite_Icon_Left_Side_Desc"])

        local levelEliteIconRingTexture = CreateCheckbox("levelEliteIconRingTexture", L["Ring_Texture"], levelEliteIconOptionsFrame, nil, BBP.UpdateAllLevelFrames)
        levelEliteIconRingTexture:SetPoint("TOPLEFT", levelEliteIconLeftSide, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        CreateTooltipTwo(levelEliteIconRingTexture, L["Ring_Texture"], L["Tooltip_Ring_Texture_Desc_2"])

        local levelEliteIconReset = CreateFrame("Button", nil, levelEliteIconOptionsFrame, "UIPanelButtonTemplate")
        levelEliteIconReset:SetText(L["Reset"])
        levelEliteIconReset:SetSize(80, 22)
        levelEliteIconReset:SetPoint("BOTTOM", levelEliteIconOptionsFrame, "BOTTOM", 2, 12)
        levelEliteIconReset:SetScript("OnClick", function()
            levelEliteIconWidth:SetValue(0)
            levelEliteIconHeight:SetValue(0)
            levelEliteIconXPos:SetValue(0)
            levelEliteIconYPos:SetValue(0)
            if levelEliteIconLeftSide:GetChecked() then
                levelEliteIconLeftSide:Click()
            end
            if levelEliteIconRingTexture:GetChecked() then
                levelEliteIconRingTexture:Click()
            end
        end)
        CreateTooltipTwo(levelEliteIconReset, L["Reset"], L["Tooltip_Reset_Desc"])

        levelEliteIconOptionsFrame:Show()
    end

    local levelAreaKeys = { hideLevelFrame = true, hideLevelOnFriendly = true, hideLevelFrameBackground = true }
    local levelOptions = CreateMultiSelectDropdown(L["Level_Options"], BetterBlizzPlates, {
        { key = "hideLevelFrame", label = L["Hide_Level"], tooltip = L["Tooltip_Hide_The_Level"] },
        { key = "hideLevelOnFriendly", label = L["Hide_Level_On_Friendly"], tooltip = L["Tooltip_Hide_The_Level_On_Friendly_Nameplates"] },
        { key = "hideLevelFrameBackground", label = L["Hide_Level_Background"], tooltip = L["Tooltip_Show_Only_The_Level_Text"], tooltipNote = function() return not BetterBlizzPlatesDB.classicNameplates and L["Tooltip_Always_On_Without_Classic_Nameplates"] or nil end, isForced = function() return not BetterBlizzPlatesDB.classicNameplates end },
        { key = "moveLevelText", label = L["Move_Level"], tooltipTitle = L["Move_And_Size_Level_Text"], tooltip = L["Tooltip_Move_And_Size_The_Level_Text"], tooltipNote = L["Tooltip_Needs_Hide_Level_Background_With_Classic"], onRightClick = OpenLevelTextOptionsWindow, isEnabled = BBP.CanMoveLevelText },
        { key = "levelFrameEliteIcon", label = L["Show_Elite_Icon_Around_Level"], tooltip = L["Tooltip_Show_A_Dragon_Around_The_Level"], tooltipNote = L["Tooltip_With_Hide_Level_On_It_Sits"], onRightClick = OpenLevelEliteIconOptionsWindow, isAvailable = BBP.LevelEliteRingAvailable },
    }, 150, function(key)
        if levelAreaKeys[key] and not InCombatLockdown() then
            for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                local frame = nameplate.UnitFrame
                if frame and not frame:IsForbidden() and frame.unit then
                    BBP.UpdateClickableArea(nameplate)
                    BBP.SetNameplateBarSizes(frame)
                    BBP.UpdateStackingZone(nameplate)
                end
            end
        end
    end)
    levelOptions:SetPoint("LEFT", classicNameplates.text, "RIGHT", 5, 0)
    levelOptions:SetScale(0.7)
    CreateTooltipTwo(levelOptions, L["Level_Options"], L["Tooltip_Level_Options_Desc_2"])

    classicNameplates:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.nameplateEnemyWidth = 150
            BetterBlizzPlatesDB.nameplateFriendlyWidth = 150
            BetterBlizzPlatesDB.castBarHeight = 11
            BetterBlizzPlatesDB.hideLevelFrame = false
        else
            BetterBlizzPlatesDB.nameplateEnemyWidth = 145
            BetterBlizzPlatesDB.nameplateFriendlyWidth = 145
            BetterBlizzPlatesDB.castBarHeight = 16
            BetterBlizzPlatesDB.hideLevelFrame = true
        end
        if not InCombatLockdown() then
            BBP.ApplyNameplateWidth()
        end
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)
    -- hideLevelFrame:HookScript("OnClick", function(self)
    --     if not self:GetChecked() then
    --         BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    --     end
    -- end)

    -- local hideNameplateAuraTooltip = CreateCheckbox("hideNameplateAuraTooltip", "Hide aura tooltip", BetterBlizzPlates)
    -- hideNameplateAuraTooltip:SetPoint("LEFT", classicNameplates.text, "RIGHT", 0, 0)
    -- hideNameplateAuraTooltip:HookScript("OnClick", function()
    --     BBP.HideNameplateAuraTooltip()
    --     BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    -- end)
    -- CreateTooltipTwo(hideNameplateAuraTooltip, "Hide Aura Tooltip", "Hide Nameplate Aura Tooltips.")

    local hideTargetHighlight = CreateCheckbox("hideTargetHighlight", L["Hide_Target_Highlight_Glow"], BetterBlizzPlates)
    hideTargetHighlight:SetPoint("TOPLEFT", classicNameplates, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTargetHighlight, L["Hide_Target_Highlight"], L["Tooltip_Hide_Target_Highlight_Desc"])

    local smallPetsInPvP = CreateCheckbox("smallPetsInPvP", L["Small_Pets"], BetterBlizzPlates)
    smallPetsInPvP:SetPoint("LEFT", healthNumbers.text, "RIGHT", 0, 0)
    CreateTooltipTwo(smallPetsInPvP, L["Small_Pets_In_PvP"], L["Tooltip_Small_Pets_In_PvP_Desc"])

    local smallPetsOptionsFrame
    local function OpenSmallPetsOptionsWindow()
        if not smallPetsOptionsFrame then
            smallPetsOptionsFrame = CreateFrame("Frame", "BBPSmallPetsOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            smallPetsOptionsFrame.name = L["Search_Name_General"]
            smallPetsOptionsFrame:SetSize(192, 220)
            smallPetsOptionsFrame:SetPoint("CENTER")
            smallPetsOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            smallPetsOptionsFrame:SetFrameLevel(550)
            smallPetsOptionsFrame:SetMovable(true)
            smallPetsOptionsFrame:EnableMouse(true)
            smallPetsOptionsFrame:RegisterForDrag("LeftButton")
            smallPetsOptionsFrame:SetScript("OnDragStart", smallPetsOptionsFrame.StartMoving)
            smallPetsOptionsFrame:SetScript("OnDragStop", smallPetsOptionsFrame.StopMovingOrSizing)
            smallPetsOptionsFrame.title = smallPetsOptionsFrame:CreateFontString(nil, "OVERLAY")
            smallPetsOptionsFrame.title:SetFontObject("GameFontHighlight")
            smallPetsOptionsFrame.title:SetPoint("LEFT", smallPetsOptionsFrame.TitleBg, "LEFT", 5, 0)
            smallPetsOptionsFrame.title:SetText(L["Small_Pets_Options"])

            local smallPetsAllNPCs = CreateCheckbox("smallPetsInPvPAllNPCs", L["Shrink_All_NPCs_In_PvP"], smallPetsOptionsFrame)
            smallPetsAllNPCs:SetPoint("TOPLEFT", smallPetsOptionsFrame, "TOPLEFT", 10, -26)
            CreateTooltipTwo(smallPetsAllNPCs, L["Shrink_All_NPCs_In_PvP"], L["Tooltip_Shrink_All_NPCs_In_PvP_Desc"])

            local smallPetsIgnoreTotems = CreateCheckbox("smallPetsInPvPIgnoreTotems", L["Ignore_Totems"], smallPetsOptionsFrame)
            smallPetsIgnoreTotems:SetPoint("TOPLEFT", smallPetsAllNPCs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
            CreateTooltipTwo(smallPetsIgnoreTotems, L["Ignore_Totems"], L["Tooltip_Ignore_Totems_Desc"])

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

            local smallPetsWidthSlider = CreateSlider(smallPetsOptionsFrame, L["Small_Pets_Width"], 2, 70, 1, "smallPetsWidth", nil, 150)
            smallPetsWidthSlider:SetPoint("TOPLEFT", smallPetsIgnoreTotems, "BOTTOMLEFT", 2, -10)
            CreateTooltipTwo(smallPetsWidthSlider, L["Small_Pets_Width"], L["Tooltip_Small_Pets_Width_Desc"], L["Tooltip_Pets_Width_SubText"])

            local smallPetsInPvPHeight = CreateCheckbox("smallPetsInPvPHeight", L["Also_Adjust_Height"], smallPetsOptionsFrame)
            smallPetsInPvPHeight:SetPoint("TOPLEFT", smallPetsWidthSlider, "BOTTOMLEFT", -2, -10)
            CreateTooltipTwo(smallPetsInPvPHeight, L["Also_Adjust_Height"], L["Tooltip_Also_Adjust_Height_Desc_2"])

            local smallPetsHeightSlider = CreateSlider(smallPetsOptionsFrame, L["Small_Pets_Height"], 1, 35, 0.1, "smallPetsHeight", nil, 150)
            smallPetsHeightSlider:SetPoint("TOPLEFT", smallPetsInPvPHeight, "BOTTOMLEFT", 2, -10)
            CreateTooltipTwo(smallPetsHeightSlider, L["Small_Pets_Height"], L["Tooltip_Small_Pets_Height_Desc"], L["Tooltip_Pets_Width_SubText"])

            if not BetterBlizzPlatesDB.smallPetsInPvPHeight then
                DisableElement(smallPetsHeightSlider)
            end

            smallPetsInPvPHeight:HookScript("OnClick", function(self)
                if self:GetChecked() then
                    EnableElement(smallPetsHeightSlider)
                else
                    DisableElement(smallPetsHeightSlider)
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

    local nameplateMinScale = CreateSlider(BetterBlizzPlates, L["Nameplate_Size"], 0.5, 2, 0.01, "nameplateMinScale")
    nameplateMinScale:SetPoint("TOPLEFT", hideTargetHighlight, "BOTTOMLEFT", 12, -10)
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
        BBP.ResetToDefaultHeight2(nameplateGeneralHpHeight)
    end)
    CreateTooltipTwo(nameplateGeneralHpHeightResetButton, L["Reset_Nameplate_Height"], L["Tooltip_Reset_Nameplate_Height_Desc"], nil, "ANCHOR_TOP")

    ----------------------
    -- Enemy nameplates:
    ----------------------
    local enemyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -151)
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

    local enemyColorThreat = CreateCheckbox("enemyColorThreat", L["Color_Threat"], BetterBlizzPlates)
    enemyColorThreat:SetPoint("TOPLEFT", enemyColorName.text, "BOTTOMLEFT", 0, 0)
    CreateTooltipTwo(enemyColorThreat, L["Color_By_Threat_In_Instanced_PvE"], L["Tooltip_Color_By_Threat_In_Instanced_PvE_Desc_2"])

    local function UpdateColorSquare(icon, r, g, b)
        if r and g and b then
            icon:SetVertexColor(r, g, b)
        end
    end

    local enemyColorNameIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyColorNameIcon:SetAtlas("CircleMaskScalable")
    enemyColorNameIcon:SetSize(18, 17)
    UpdateColorSquare(enemyColorNameIcon, unpack(BetterBlizzPlatesDB.enemyColorNameRGB or {1, 1, 1}))

    local function OpenColorPicker(colorType, icon)
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
    enemyColorNameButtonIcon:SetAtlas("CircleMaskScalable")
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
    enemyNeutralColorNameButtonIcon:SetAtlas("CircleMaskScalable")
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
            enemyNeutralColorNameButton:SetAlpha(1)
            enemyColorNameButton:Enable()
            enemyColorNameButton:SetAlpha(1)
            enemyColorNameButtonIcon:Show()
            enemyNeutralColorNameButtonIcon:Show()
        else
            enemyNeutralColorNameButton:Disable()
            enemyNeutralColorNameButton:SetAlpha(0)
            enemyColorNameButton:Disable()
            enemyColorNameButton:SetAlpha(0)
            enemyColorNameButtonIcon:Hide()
            enemyNeutralColorNameButtonIcon:Hide()
        end
    end)
    if not BetterBlizzPlatesDB.enemyColorName then
        enemyNeutralColorNameButton:Disable()
        enemyNeutralColorNameButton:SetAlpha(0)
        enemyColorNameButton:SetAlpha(0)
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
    nameplateShowClassColor:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

    local enemyHealthBarColor = CreateCheckbox("enemyHealthBarColor", L["Custom_Healthbar_Color"], BetterBlizzPlates)
    enemyHealthBarColor:SetPoint("TOPLEFT", nameplateShowClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enemyHealthBarColor, L["Custom_Nameplate_Color"], L["Tooltip_Custom_Nameplate_Color_Desc"], L["Tooltip_Custom_Nameplate_Color_SubText"])

    local alwaysHideEnemyCastbar = CreateCheckbox("alwaysHideEnemyCastbar", L["Hide_Castbar"], BetterBlizzPlates)
    alwaysHideEnemyCastbar:SetPoint("TOPLEFT", enemyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideEnemyCastbar, L["Hide_Castbar"], L["Tooltip_Hide_Enemy_Castbar_Desc"])

    local enemyHealthBarColorNpcOnly = CreateCheckbox("enemyHealthBarColorNpcOnly", L["Npc_Only"], BetterBlizzPlates)
    enemyHealthBarColorNpcOnly:SetPoint("LEFT", enemyHealthBarColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyHealthBarColorNpcOnly, L["Only_Color_NPCs"])

    local function OpenColorPicker(colorType, icon)
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
    enemyHealthBarColorButtonIcon:SetAtlas("CircleMaskScalable")
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
    enemyNeutralHealthBarColorButtonIcon:SetAtlas("CircleMaskScalable")
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
            enemyHealthBarColorNpcOnly:SetAlpha(1)
            enemyNeutralHealthBarColorButton:Enable()
            enemyNeutralHealthBarColorButton:SetAlpha(1)
            enemyHealthBarColorButton:Enable()
            enemyHealthBarColorButton:SetAlpha(1)
            enemyHealthBarColorButtonIcon:Show()
            enemyNeutralHealthBarColorButtonIcon:Show()
        else
            enemyHealthBarColorNpcOnly:SetAlpha(0)
            enemyHealthBarColorNpcOnly:Disable()
            enemyNeutralHealthBarColorButton:Disable()
            enemyNeutralHealthBarColorButton:SetAlpha(0)
            enemyHealthBarColorButton:Disable()
            enemyHealthBarColorButton:SetAlpha(0)
            enemyHealthBarColorButtonIcon:Hide()
            enemyNeutralHealthBarColorButtonIcon:Hide()
        end
    end)
    if not BetterBlizzPlatesDB.enemyHealthBarColor then
        enemyHealthBarColorNpcOnly:SetAlpha(0)
        enemyHealthBarColorNpcOnly:Disable()
        enemyNeutralHealthBarColorButton:Disable()
        enemyNeutralHealthBarColorButton:SetAlpha(0)
        enemyHealthBarColorButton:SetAlpha(0)
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

    local enemyNameScale = CreateSlider(BetterBlizzPlates, L["Tooltip_Name_Size"], 0.5, 3, 0.01, "enemyNameScale")
    enemyNameScale:SetPoint("TOPLEFT", showNameplateTargetText, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(enemyNameScale, L["Tooltip_Name_Size"], L["Tooltip_Name_Size_Desc"])

    local hideEnemyNameText = CreateCheckbox("hideEnemyNameText", L["Hide_Name"], BetterBlizzPlates)
    hideEnemyNameText:SetPoint("LEFT", enemyNameScale, "RIGHT", 2, 0)
    CreateTooltip(hideEnemyNameText, L["Hide_Name"], "Hide Name on Enemy nameplates")

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

    local nameplateEnemyWidth = CreateSlider(BetterBlizzPlates, L["Nameplate_Width"], 26, 200, 1, "nameplateEnemyWidth")
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
    friendlyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -342)
    friendlyNameplatesText:SetText(L["Friendly_Nameplates"])
    friendlyNameplatesText:SetFont(fontLarge, 16)
    friendlyNameplatesText:SetTextColor(1,1,1)
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", L["Clickthrough"], BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(friendlyNameplateClickthrough, L["Clickthrough_Nameplate"], L["Tooltip_Clickthrough_Nameplate_Desc_2"],  L["Tooltip_Clickthrough_Nameplate_SubText"])

    local friendlyClassColorName = CreateCheckbox("friendlyClassColorName", L["Class_Color_Name"], BetterBlizzPlates)
    BBP.friendlyClassColorNameCheckbox = friendlyClassColorName
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
    friendlyColorNameIcon:SetAtlas("CircleMaskScalable")
    friendlyColorNameIcon:SetSize(18, 17)
    UpdateColorSquare(friendlyColorNameIcon, unpack(BetterBlizzPlatesDB.friendlyColorNameRGB or {1, 1, 1}))

    local function OpenColorPicker2()
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

    local nameplateShowFriendlyClassColor = CreateCheckbox("nameplateShowFriendlyClassColor", L["Class_Color_Healthbar"], BetterBlizzPlates, true, BBP.ApplyNameplateWidth)
    nameplateShowFriendlyClassColor:SetPoint("TOPLEFT", friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyClassColor, L["Class_Color_Healthbar"], L["Tooltip_Class_Color_Healthbar_Desc"], nil, nil, "nameplateShowFriendlyClassColor")
    if GetCVar("nameplateShowFriendlyClassColor") == "1" and BetterBlizzPlatesDB.nameplateShowFriendlyClassColor == nil then
        BetterBlizzPlatesDB.nameplateShowFriendlyClassColor = true
        nameplateShowFriendlyClassColor:SetChecked(true)
    end
    nameplateShowFriendlyClassColor:HookScript("OnClick", function()
        BBP.ShowPopup("BBP_CONFIRM_RELOAD")
    end)

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
    CreateTooltipTwo(alwaysHideFriendlyCastbar, L["Hide_Castbar"], L["Tooltip_Hide_Friendly_Castbar_Desc"])

    local classColorPersonalNameplate = CreateCheckbox("classColorPersonalNameplate", L["Class_Color_Personal_Nameplate"], BetterBlizzPlates)
    classColorPersonalNameplate:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    classColorPersonalNameplate:HookScript("OnClick", function(self)
        local nameplate, frame = BBP.GetSafeNameplate("player")
        if frame then
            if self:GetChecked() then
                local class = UnitClassBase(frame.unit);
                local playerClassColor = BBP.GetClassColor(class);
                frame.healthBar:SetStatusBarColor(playerClassColor.r, playerClassColor.g, playerClassColor.b)
            else
                frame.healthBar:SetStatusBarColor(0,1,0)
            end
        end
    end)

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
    friendlyHealthBarColorButtonIcon:SetAtlas("CircleMaskScalable")
    friendlyHealthBarColorButtonIcon:SetSize(18, 17)
    friendlyHealthBarColorButtonIcon:SetPoint("LEFT", friendlyHealthBarColorButton, "RIGHT", 0, 0)
    UpdateColorSquare(friendlyHealthBarColorButtonIcon, unpack(BetterBlizzPlatesDB["friendlyHealthBarColorRGB"] or {1, 1, 1}))
    friendlyHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("friendlyHealthBarColorRGB", friendlyHealthBarColorButtonIcon)
    end)

    friendlyHealthBarColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            friendlyHealthBarColorPlayer:Enable()
            friendlyHealthBarColorPlayer:SetAlpha(1)
            friendlyHealthBarColorNpc:Enable()
            friendlyHealthBarColorNpc:SetAlpha(1)
            -- friendlyNameColor:Enable()
            -- friendlyNameColor:SetAlpha(1)
            friendlyHealthBarColorButton:Enable()
            friendlyHealthBarColorButton:SetAlpha(1)
            friendlyHealthBarColorButtonIcon:SetAlpha(1)
        else
            friendlyHealthBarColorPlayer:Disable()
            friendlyHealthBarColorPlayer:SetAlpha(0)
            friendlyHealthBarColorNpc:Disable()
            friendlyHealthBarColorNpc:SetAlpha(0)
            -- friendlyNameColor:SetAlpha(0)
            -- friendlyNameColor:Disable()
            friendlyHealthBarColorButton:Disable()
            friendlyHealthBarColorButton:SetAlpha(0)
            friendlyHealthBarColorButtonIcon:SetAlpha(0)
        end
    end)
    if not BetterBlizzPlatesDB.friendlyHealthBarColor then
        friendlyHealthBarColorPlayer:Disable()
        friendlyHealthBarColorPlayer:SetAlpha(0)
        friendlyHealthBarColorNpc:Disable()
        friendlyHealthBarColorNpc:SetAlpha(0)
        -- friendlyNameColor:Disable()
        -- friendlyNameColor:SetAlpha(0)
        friendlyHealthBarColorButtonIcon:SetAlpha(0)
        friendlyHealthBarColorButton:SetAlpha(0) --default slider creation only does 0.5 alpha
        friendlyHealthBarColorButton:Disable()
    end

    BBP.friendlyHideHealthBar = CreateCheckbox("friendlyHideHealthBar", L["Hide_Healthbar"], BetterBlizzPlates, nil, nil, true)
    BBP.friendlyHideHealthBar:SetPoint("LEFT", alwaysHideFriendlyCastbar.text, "RIGHT", 0, 0)
    BBP.friendlyHideHealthBar:HookScript("OnClick", function()
        BBP.HideHealthbarInPvEMagicCaller()
    end)
    CreateTooltipTwo(BBP.friendlyHideHealthBar, L["Hide_Healthbar"], L["Tooltip_Hide_Healthbar_2_Desc"], L["Tooltip_Hide_Healthbar_2_SubText"])

    BBP.friendlyHideHealthBarNpc = CreateCheckbox("friendlyHideHealthBarNpc", L["NPCs"], BetterBlizzPlates, nil, nil, true)
    BBP.friendlyHideHealthBarNpc:SetPoint("LEFT", BBP.friendlyHideHealthBar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(BBP.friendlyHideHealthBarNpc, L["Hide_NPC_Healthbar"], L["Tooltip_Hide_NPC_Healthbar_Desc"], L["Tooltip_Hide_NPC_Healthbar_SubText"])

    BBP.friendlyHideHealthBar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.friendlyHideHealthBarNpc:Enable()
            BBP.friendlyHideHealthBarNpc:SetAlpha(1)
        else
            BBP.friendlyHideHealthBarNpc:Disable()
            BBP.friendlyHideHealthBarNpc:SetAlpha(0)
        end
    end)
    if not BetterBlizzPlatesDB.friendlyHideHealthBar then
        BBP.friendlyHideHealthBarNpc:SetAlpha(0)
        BBP.friendlyHideHealthBarNpc:Disable()
    end

    local friendlyNpToggles = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    friendlyNpToggles:SetText(L["Toggles_Colon"])
    friendlyNpToggles:SetPoint("TOPLEFT", classColorPersonalNameplate, "BOTTOMLEFT", -20, -70)
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
    friendlyNameScale:SetPoint("TOPLEFT", classColorPersonalNameplate, "BOTTOMLEFT", 0, -6)
    CreateTooltipTwo(friendlyNameScale, L["Tooltip_Name_Size"], L["Tooltip_Name_Size_Desc_2"])

    local hideFriendlyNameText = CreateCheckbox("hideFriendlyNameText", L["Hide_Name"], BetterBlizzPlates)
    hideFriendlyNameText:SetPoint("LEFT", friendlyNameScale, "RIGHT", 2, 0)
    CreateTooltipTwo(hideFriendlyNameText, L["Hide_Name"], L["Tooltip_Hide_Name_2_Desc"])

    local nameplateFriendlyWidth = CreateSlider(BetterBlizzPlates, L["Nameplate_Width"], 26, 200, 1, "nameplateFriendlyWidth")
    nameplateFriendlyWidth:SetPoint("TOPLEFT", friendlyNameScale, "BOTTOMLEFT", 0, -20)

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
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 390, -105)
    extraFeaturesText:SetText(L["Extra_Features"])
    extraFeaturesText:SetFont(fontLarge, 16)
    extraFeaturesText:SetTextColor(1,1,1)
    local extraFeaturesIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)

    local testAllEnabledFeatures = CreateCheckbox("testAllEnabledFeatures", L["Test"], BetterBlizzPlates, nil, BBP.TestAllEnabledFeatures)
    testAllEnabledFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
    CreateTooltipTwo(testAllEnabledFeatures, L["Test_All_Features"], L["Tooltip_Test_All_Features_Desc"], L["Tooltip_Test_All_Features_SubText_2"])

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

    local classIndicator = CreateCheckbox("classIndicator", L["Class_Indicator"], BetterBlizzPlates)
    classIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classIndicator, L["Class_Indicator"] .. " |A:groupfinder-icon-class-mage:16:16|a", L["Tooltip_Class_Indicator_2_Desc_2"])
    local classIndicatorIcon = classIndicator:CreateTexture(nil, "ARTWORK")
    classIndicatorIcon:SetAtlas("groupfinder-icon-class-mage")
    classIndicatorIcon:SetSize(18, 18)
    classIndicatorIcon:SetPoint("RIGHT", classIndicator, "LEFT", 0, 0)
    classIndicator:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        if self:GetChecked() then
            if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
                BBP.Print(L["Print_Enable_Nameplate_Aura_Customization_In_Order_2"])
            else
                BBP.Print(L["Print_Enabled_Friendly_Debuffs_And_PvP_CC_2"])
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
        end
        if InCombatLockdown() then return end
        if self:GetChecked() then
            C_CVar.SetCVar("nameplateShowFriends", "1")
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
    CreateTooltipTwo(executeIndicator, L["Execute_Indicator"] .. " |T"..BBP.executeIndicatorIconReplacement..":22:22:0:0|t", L["Tooltip_Execute_Indicator_2_Desc"])
    local executeIndicatorIcon = executeIndicator:CreateTexture(nil, "ARTWORK")
    executeIndicatorIcon:SetTexture(BBP.executeIndicatorIconReplacement)
    executeIndicatorIcon:SetSize(28, 30)
    executeIndicatorIcon:SetPoint("RIGHT", executeIndicator, "LEFT", 4, 1)

    local factionIndicator = CreateCheckbox("factionIndicator", L["Faction_Indicator"], BetterBlizzPlates, nil, BBP.ToggleFactionIndicator)
    factionIndicator:SetPoint("TOPLEFT", executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    local factionAtlas = C_Texture.GetAtlasInfo("questlog-questtypeicon-alliance") and "questlog-questtypeicon-alliance"
    local factionIconMarkup = factionAtlas and "|A:"..factionAtlas..":21:21|a" or "|TInterface\\Icons\\Inv_BannerPVP_02:18:18|t"
    CreateTooltipTwo(factionIndicator, L["Faction_Indicator"] .. " " .. factionIconMarkup, L["Tooltip_Faction_Indicator_2_Desc"], L["Tooltip_Faction_Indicator_2_SubText"])
    local factionIndicatorIcon = factionIndicator:CreateTexture(nil, "ARTWORK")
    if factionAtlas then
        factionIndicatorIcon:SetAtlas(factionAtlas)
        factionIndicatorIcon:SetSize(21, 21)
    else
        factionIndicatorIcon:SetTexture("Interface\\Icons\\Inv_BannerPVP_02")
        factionIndicatorIcon:SetSize(18, 18)
    end
    factionIndicatorIcon:SetPoint("RIGHT", factionIndicator, "LEFT", 0, 0)

    local healerIndicator = CreateCheckbox("healerIndicator", L["Healer_Indicator"], BetterBlizzPlates)
    healerIndicator:SetPoint("TOPLEFT", factionIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healerIndicator, L["Healer_Indicator"] .. " |A:greencross:21:21|a", L["Tooltip_Healer_Indicator_2_Desc_2"], L["Tooltip_Healer_Indicator_2_SubText"])
    local healerCrossIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    healerCrossIcon:SetAtlas("greencross")
    healerCrossIcon:SetSize(21, 21)
    healerCrossIcon:SetPoint("RIGHT", healerIndicator, "LEFT", 0, 0)

    local partyPointer = CreateCheckbox("partyPointer", L["Party_Pointer"], BetterBlizzPlates)
    partyPointer:SetPoint("TOPLEFT", healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyPointer, L["Party_Pointer"] .. " |T"..BBP.partyPointerIconReplacement..":22:22:0:0|t", L["Tooltip_Party_Pointer_2_Desc"], L["Tooltip_Party_Pointer_2_SubText"])
    local partyPointerIcon = partyPointer:CreateTexture(nil, "ARTWORK")
    partyPointerIcon:SetTexture(BBP.partyPointerIconReplacement)
    partyPointerIcon:SetSize(17, 18)
    partyPointerIcon:SetPoint("RIGHT", partyPointer, "LEFT", -2.5, 1.5)
    partyPointerIcon:SetDesaturated(true)
    partyPointerIcon:SetVertexColor(0.04, 0.76, 1)
    partyPointer:HookScript("OnClick", function(self)
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
            C_CVar.SetCVar("nameplateShowFriends", "1")
        end
    end)

    local petIndicator = CreateCheckbox("petIndicator", L["Pet_Indicator"], BetterBlizzPlates)
    petIndicator:SetPoint("TOPLEFT", partyPointer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(petIndicator, L["Tooltip_Show_A_Murloc_On_The_Main"])
    CreateTooltipTwo(petIndicator, L["Pet_Indicator"] .. " |A:newplayerchat-chaticon-newcomer:18:18|a", L["Tooltip_Pet_Indicator_2_Desc_2"])
    local petIndicatorIcon = petIndicator:CreateTexture(nil, "ARTWORK")
    petIndicatorIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicatorIcon:SetSize(18, 18)
    petIndicatorIcon:SetPoint("RIGHT", petIndicator, "LEFT", -1, 0)

    local targetIndicator = CreateCheckbox("targetIndicator", L["Target_Indicator"], BetterBlizzPlates)
    targetIndicator:SetPoint("TOPLEFT", petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetIndicator, L["Target_Indicator"] .. " |T"..BBP.targetIndicatorIconReplacement..":22:22:0:0|t", L["Tooltip_Target_Indicator_2_Desc"])
    local targetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    targetIndicatorIcon:SetTexture(BBP.targetIndicatorIconReplacement)
    targetIndicatorIcon:SetRotation(math.rad(180))
    targetIndicatorIcon:SetSize(24, 20)
    targetIndicatorIcon:SetPoint("RIGHT", targetIndicator, "LEFT", 2, 0)

    local focusTargetIndicator = CreateCheckbox("focusTargetIndicator", L["Focus_Target_Indicator"], BetterBlizzPlates)
    focusTargetIndicator:SetPoint("TOPLEFT", targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicator, L["Tooltip_Show_A_Marker_On_The_Focus"])
    CreateTooltipTwo(focusTargetIndicator, L["Focus_Target_Indicator"] .. " |T"..BBP.focusIndicatorIconReplacement..":22:22:0:0|t", L["Tooltip_Show_A_Marker_On_Your_Focus_Desc"])
    local focusTargetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    focusTargetIndicatorIcon:SetTexture(BBP.focusIndicatorIconReplacement)
    focusTargetIndicatorIcon:SetSize(19, 20)
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

    CreateTooltipTwo(totemIndicator, L["Totem_Indicator"] .. " |T"..BBP.TotemIndicatorIcon..":22:22:0:0|t", L["Tooltip_Totem_Indicator_2_Desc_2"], L["Tooltip_Full_List_Available_In_Totem_Indicator_SubText"])
    local totemsIcon = totemIndicator:CreateTexture(nil, "ARTWORK")
    totemsIcon:SetTexture(BBP.TotemIndicatorIcon)
    totemsIcon:SetSize(17, 17)
    totemsIcon:SetPoint("RIGHT", totemIndicator, "LEFT", -1, 0)

    local questIndicator = CreateCheckbox("questIndicator", L["Quest_Indicator"], BetterBlizzPlates)
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
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -385)
    customFontandTextureText:SetText(L["Font_And_Texture"])
    customFontandTextureText:SetFont(fontLarge, 16)
    customFontandTextureText:SetTextColor(1,1,1)
    local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    customFontandTextureIcon:SetTexture(BBP.BarberIcon)
    customFontandTextureIcon:SetSize(24, 24)
    customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

    local useCustomFont = CreateCheckbox("useCustomFont", L["Change_The_Nameplate_Font"], BetterBlizzPlates)
    useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(useCustomFont, L["Custom_Font"], L["Change_The_Nameplate_Font"], L["Tooltip_Custom_Font_SubText"])

    local useCustomTexture = CreateCheckbox("useCustomTextureForBars", L["Change_The_Nameplate_Texture"], BetterBlizzPlates)
    useCustomTexture:SetPoint("TOPLEFT", useCustomFont, "BOTTOMLEFT", 0, -26)
    CreateTooltipTwo(useCustomTexture, L["Custom_Texture"], L["Change_The_Nameplate_Texture"])

    local fontDropdown = CreateFontDropdown(
        "fontDropdown",
        useCustomFont,
        L["Select_Font"],
        "customFont",
        function(arg1)
            BBP.RefreshAllNameplates() 
        end,
        { anchorFrame = useCustomFont, x = 5, y = -21, label = L["Font"] }
    )

    local enableCustomFontOutline = CreateCheckbox("enableCustomFontOutline", L["Outline_Label"], useCustomFont)
    enableCustomFontOutline:SetPoint("LEFT", fontDropdown, "RIGHT", -15, 1)
    CreateTooltipTwo(enableCustomFontOutline, L["Font_Outline"], L["Tooltip_Font_Outline_Desc_2"])
    enableCustomFontOutline:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            local currentOutline = BetterBlizzPlatesDB["customFontOutline"]
            if currentOutline == "THINOUTLINE" then
                BetterBlizzPlatesDB["customFontOutline"] = "THICKOUTLINE"
                RefreshTooltip(enableCustomFontOutline, L["Font_Outline"], L["Tooltip_Font_Outline_Desc_3"])
            else
                BetterBlizzPlatesDB["customFontOutline"] = "THINOUTLINE"
                RefreshTooltip(enableCustomFontOutline, L["Font_Outline"], L["Tooltip_Font_Outline_Desc_4"])
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
        { anchorFrame = useCustomTexture, x = 5, y = -21, label = L["Texture"] }
    )

    local textureDropdownFriendly = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        L["Select_Texture"],
        "customTextureFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomTexture, x = 5, y = -51, label = L["Friendly"] }
    )

    -- local textureDropdownSelf = CreateTextureDropdown(
    --     "textureDropdownFriendly",
    --     useCustomTexture,
    --     "Select Texture",
    --     "customTextureSelf",
    --     function(arg1)
    --         BBP.RefreshAllNameplates()
    --     end,
    --     { anchorFrame = useCustomTexture, x = 5, y = -81, label = "Personal" }
    -- )

    -- local textureDropdownSelfMana = CreateTextureDropdown(
    --     "textureDropdownFriendly",
    --     useCustomTexture,
    --     "Select Texture",
    --     "customTextureSelfMana",
    --     function(arg1)
    --         BBP.RefreshAllNameplates()
    --     end,
    --     { anchorFrame = useCustomTexture, x = 5, y = -111, label = "Personal Mana" }
    -- )

    local useCustomTextureForEnemy = CreateCheckbox("useCustomTextureForEnemy", L["Enemy"], useCustomTexture)
    useCustomTextureForEnemy:SetPoint("LEFT", textureDropdown, "RIGHT", -15, 1)
    --useCustomTextureForEnemy.text:SetTextColor(1,0,0) bodifycata
    useCustomTextureForEnemy:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdown:Enable()
        else
            textureDropdown:Disable()
        end
    end)
    CreateTooltipTwo(useCustomTextureForEnemy, L["Enemy_Texture"], L["Tooltip_Enemy_Texture_Desc"], nil, "ANCHOR_LEFT")
    if not useCustomTextureForEnemy:GetChecked() then
        textureDropdown:Disable()
    end

    -- local useCustomTextureForExtraBars = CreateCheckbox("useCustomTextureForExtraBars", "Overbars", BetterBlizzPlates)
    -- useCustomTextureForExtraBars:SetPoint("BOTTOMLEFT", useCustomTextureForEnemy, "TOPLEFT", 0, -3)
    -- CreateTooltipTwo(useCustomTextureForExtraBars, "Change Overbars Texture", "Also change the texture for nameplate absorbs & overhealing etc.")
    -- notWorking(useCustomTextureForExtraBars, true)

    local useCustomTextureForFriendly = CreateCheckbox("useCustomTextureForFriendly", L["Friendly"], useCustomTexture)
    useCustomTextureForFriendly:SetPoint("LEFT", textureDropdownFriendly, "RIGHT", -15, 1)
    --useCustomTextureForFriendly.text:SetTextColor(0.04, 0.76, 1) bodifycata
    useCustomTextureForFriendly:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownFriendly:Enable()
        else
            textureDropdownFriendly:Disable()
        end
    end)
    CreateTooltipTwo(useCustomTextureForFriendly, L["Friendly_Texture"], L["Tooltip_Friendly_Texture_Desc"], nil, "ANCHOR_LEFT")
    if not useCustomTextureForFriendly:GetChecked() then
        textureDropdownFriendly:Disable()
    end

    -- local useCustomTextureForSelf = CreateCheckbox("useCustomTextureForSelf", "Self", useCustomTexture)
    -- useCustomTextureForSelf:SetPoint("LEFT", textureDropdownSelf, "RIGHT", -15, 1)
    -- useCustomTextureForSelf:HookScript("OnClick", function(self)
    --     if self:GetChecked() then
    --         textureDropdownSelf:Enable()
    --     else
    --         textureDropdownSelf:Disable()
    --     end
    -- end)
    -- CreateTooltipTwo(useCustomTextureForSelf, "Personal Texture", "Change Personal resource healthbar texture.", nil, "ANCHOR_LEFT")
    -- if not useCustomTextureForSelf:GetChecked() then
    --     textureDropdownSelf:Disable()
    -- end

    -- local useCustomTextureForSelfMana = CreateCheckbox("useCustomTextureForSelfMana", "Self Mana", useCustomTexture)
    -- useCustomTextureForSelfMana:SetPoint("LEFT", textureDropdownSelfMana, "RIGHT", -15, 1)
    -- useCustomTextureForSelfMana:HookScript("OnClick", function(self)
    --     if self:GetChecked() then
    --         textureDropdownSelfMana:Enable()
    --     else
    --         textureDropdownSelfMana:Disable()
    --     end
    -- end)
    -- CreateTooltipTwo(useCustomTextureForSelfMana, "Personal Mana/Resource Texture", "Change Personal Resource mana/resource-bar texture", nil, "ANCHOR_LEFT")
    -- if not useCustomTextureForSelfMana:GetChecked() then
    --     textureDropdownSelfMana:Disable()
    -- end

    -- local function SetClassAndPowerColor()
    --     -- Retrieve the player's class information
    --     local _, class = UnitClass("player")
    --     local classColor = RAID_CLASS_COLORS[class]
    --     -- Retrieve the player's primary power type
    --     local powerType, powerToken = UnitPowerType("player")
    --     local powerColor
    --     if PowerBarColor[powerType] then
    --         powerColor = PowerBarColor[powerType]
    --     elseif PowerBarColor[powerToken] then
    --         powerColor = PowerBarColor[powerToken]
    --     end
    --     -- Check if both classColor and powerColor are not nil
    --     if classColor and powerColor then
    --         -- Set text color using the class color
    --         --useCustomTextureForSelf.text:SetTextColor(classColor.r, classColor.g, classColor.b) bodifycata
    --         -- Set text color using the power color
    --         --useCustomTextureForSelfMana.text:SetTextColor(powerColor.r, powerColor.g, powerColor.b) bodifycata
    --     else
    --         -- Retry after 1 second if either color is nil
    --         C_Timer.After(1, SetClassAndPowerColor)
    --     end
    -- end

    -- SetClassAndPowerColor()

    useCustomFont:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(enableCustomFontOutline)
            fontDropdown:Enable()
        else
            fontDropdown:Disable()
            DisableElement(enableCustomFontOutline)
        end
    end)

    useCustomTexture:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(useCustomTexture)
        if self:GetChecked() then
            if useCustomTextureForEnemy:GetChecked() then
                textureDropdown:Enable()
            end
            if useCustomTextureForFriendly:GetChecked() then
                textureDropdownFriendly:Enable()
            end
            -- if useCustomTextureForSelf:GetChecked() then
            --     textureDropdownSelf:Enable()
            -- end
            -- if useCustomTextureForSelfMana:GetChecked() then
            --     textureDropdownSelfMana:Enable()
            -- end
        else
            textureDropdown:Disable()
            textureDropdownFriendly:Disable()
            -- textureDropdownSelf:Disable()
            -- textureDropdownSelfMana:Disable()
        end
    end)


    ----------------------
    -- Arena
    ----------------------
    local arenaSettingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaSettingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, 30)
    arenaSettingsText:SetText(L["Arena_Nameplates"])
    arenaSettingsText:SetFont(fontLarge, 16)
    arenaSettingsText:SetTextColor(1,1,1)
    local arenaSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    arenaSettingsIcon:SetAtlas("questbonusobjective")
    arenaSettingsIcon:SetSize(24, 24)
    arenaSettingsIcon:SetPoint("RIGHT", arenaSettingsText, "LEFT", -3, 0)
    CreateTooltipTwo(arenaSettingsText, L["Arena_ID_Spec_Name"], L["Tooltip_Arena_ID_Spec_Name_Desc"], nil, "ANCHOR_LEFT")

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
    CreateTooltipTwo(arenaModeDropdown, L["Arena_ID_Spec_Name"], L["Tooltip_Arena_ID_Spec_Name_Desc"], nil, "ANCHOR_LEFT")

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", L["Short"], BetterBlizzPlates)
    shortArenaSpecName:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)
    CreateTooltipTwo(shortArenaSpecName, L["Short_Spec_Names"], L["Tooltip_Short_Spec_Names_Desc"], nil, "ANCHOR_LEFT")

    local arenaIndicatorBg = CreateCheckbox("arenaIndicatorBg", "BG", BetterBlizzPlates)
    arenaIndicatorBg:SetPoint("LEFT", shortArenaSpecName.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(arenaIndicatorBg, L["Battleground_Spec_Names"], L["Tooltip_Battleground_Spec_Names_Desc"], L["Tooltip_Battleground_Spec_Names_SubText"], "ANCHOR_LEFT")

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
    CreateTooltipTwo(partyModeDropdown, L["Arena_ID_Spec_Name"], L["Tooltip_Arena_ID_Spec_Name_Desc"], nil, "ANCHOR_LEFT")
    BBP.arenaModeDropdowns = { arenaModeDropdown, partyModeDropdown }

    local partyIDScale = CreateSlider(BetterBlizzPlates, L["Party_ID_Size"], 0.5, 4, 0.01, "partyIDScale")
    partyIDScale:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltipTwo(partyIDScale, L["Arena_ID_Size"], L["Tooltip_Arena_ID_Size_Desc_2"])

    local partySpecScale = CreateSlider(BetterBlizzPlates, L["Spec_Size"], 0.5, 3, 0.01, "partySpecScale")
    partySpecScale:SetPoint("TOPLEFT", partyIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltipTwo(partySpecScale, L["Arena_Spec_Size"], L["Tooltip_Arena_Spec_Size_Desc_2"])






    local btnGap = -2
    local lastCoreButton = profilesFrame.coreText
    local lastStreamerButton = profilesFrame.streamerText
    local profileButtons = {}

    for _, profile in ipairs(BBP.ProfileData) do
        local additionalNote = profile.name == "Starter" and "|cff808080" .. L["Popup_Starter_Reset_Note"] .. "|r\n\n" or nil
        local button = CreateClassButton(BetterBlizzPlates, profile.class, profile.name, profile.twitchName, function()
            ShowProfileConfirmation(profile.name, profile.class, function() BBP.ApplyProfile(profile.name) end, additionalNote)
        end)
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
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", BetterBlizzPlates, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
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
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

    ---------------------------
    -- Healer indicator
    ---------------------------
    local anchorSubHeal = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHeal:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, secondLineY)
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
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubOutOfCombat:SetText(L["Combat_Indicator"])

    CreateBorderBox(anchorSubOutOfCombat)

    anchorSubOutOfCombat.icon = contentFrame:CreateTexture(nil, "ARTWORK")
    if BetterBlizzPlatesDB.combatIndicatorSap then
        anchorSubOutOfCombat.icon:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
        anchorSubOutOfCombat.icon:SetSize(38, 38)
        anchorSubOutOfCombat.icon:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 0)
    else
        anchorSubOutOfCombat.icon:SetAtlas("food")
        anchorSubOutOfCombat.icon:SetSize(40, 40)
        anchorSubOutOfCombat.icon:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", -1, 0)
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
            anchorSubOutOfCombat.icon:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
            anchorSubOutOfCombat.icon:SetSize(38, 38)
            anchorSubOutOfCombat.icon:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 0)
        else
            anchorSubOutOfCombat.icon:SetAtlas("food")
            anchorSubOutOfCombat.icon:SetSize(40, 40)
            anchorSubOutOfCombat.icon:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", -1, 0)
        end
    end)

    local combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", L["On_Players_Only"], contentFrame)
    combatIndicatorPlayersOnly:SetPoint("TOPLEFT", combatIndicatorSap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local combatIndicatorAssumePalaCombat = CreateCheckbox("combatIndicatorAssumePalaCombat", L["Assume_Pala_Combat"], contentFrame)
    combatIndicatorAssumePalaCombat:SetPoint("TOPLEFT", combatIndicatorPlayersOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(combatIndicatorAssumePalaCombat, L["Tooltip_Assume_Paladin_Combat_Title"], L["Tooltip_Assume_Paladin_Combat_Desc"], L["Tooltip_Assume_Paladin_Combat_SubText"])

    ----------------------
    -- Hunter pet icon
    ----------------------
    local anchorSubPet = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPet:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, thirdLineY)
    anchorSubPet:SetText(L["Pet_Indicator"])

    CreateBorderBox(anchorSubPet)

    anchorSubPet.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubPet.t:SetAtlas("newplayerchat-chaticon-newcomer")
    anchorSubPet.t:SetSize(36, 36)
    anchorSubPet.t:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

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

    anchorSubAbsorb.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubAbsorb.t:SetAtlas("ParagonReputation_Glow")
    anchorSubAbsorb.t:SetSize(51, 51)
    anchorSubAbsorb.t:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

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
    -- Totem Indicator
    ----------------------
    local anchorSubTotem = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, fifthLineY)
    anchorSubTotem:SetText(L["Totem_Indicator"])

    CreateBorderBox(anchorSubTotem)

    local totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    totemIcon2:SetTexture(BBP.TotemIndicatorIcon)
    totemIcon2:SetSize(34, 34)
    totemIcon2:SetPoint("BOTTOM", anchorSubTotem, "TOP", 0, 0)

    BBP.totemIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.5, 3, 0.01, "totemIndicatorScale")
    BBP.totemIndicatorScale:SetPoint("TOP", anchorSubTotem, "BOTTOM", 0, -15)
    CreateTooltip( BBP.totemIndicatorScale, L["Tooltip_This_Changes_The_Scale_Of_ALL"], "ANCHOR_LEFT")

    local totemIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "totemIndicatorXPos", "X")
    totemIndicatorXPos:SetPoint("TOP",  BBP.totemIndicatorScale, "BOTTOM", 0, -15)

    local totemIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "totemIndicatorYPos", "Y")
    totemIndicatorYPos:SetPoint("TOP", totemIndicatorXPos, "BOTTOM", 0, -15)

    local totemIndicatorDropdown = CreateAnchorDropdown(
        "totemIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "totemIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = totemIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local totemTestIcons2 = CreateCheckbox("totemIndicatorTestMode", L["Test"], contentFrame)
    totemTestIcons2:SetPoint("TOPLEFT", totemIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local totemIndicatorEnemyOnly = CreateCheckbox("totemIndicatorEnemyOnly", L["Enemies_Only"], contentFrame)
    totemIndicatorEnemyOnly:SetPoint("LEFT", totemTestIcons2.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorEnemyOnly, L["Tooltip_Show_On_Enemy_Totems_Only"])

    local totemIndicatorHideNameAndShiftIconDown = CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", L["Hide_Name"], contentFrame)
    totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local totemIndicatorHideHealthBar = CreateCheckbox("totemIndicatorHideHealthBar", L["Hide_HP"], contentFrame)
    totemIndicatorHideHealthBar:SetPoint("LEFT", totemIndicatorHideNameAndShiftIconDown.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorHideHealthBar, L["Tooltip_Hide_The_Healthbar_On_Totems_Will"])

--[=[
    local totemIndicatorDisplayCdText = CreateCheckbox("totemIndicatorDisplayCdText", "CD Text", contentFrame)
    totemIndicatorDisplayCdText:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorDisplayCdText, "Display default Blizz CD Text\n\nWill not work with OmniCC.")
]=]-- cant force use blizzards own countdown it seems, must make own soonTM

    local showTotemIndicatorCooldownSwipe = CreateCheckbox("showTotemIndicatorCooldownSwipe", L["CD_Swipe"], contentFrame)
    showTotemIndicatorCooldownSwipe:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showTotemIndicatorCooldownSwipe, L["Tooltip_Show_Cooldown_Swipe_Animation"])

    local totemIndicatorColorName = CreateCheckbox("totemIndicatorColorName", L["Color_Name"], contentFrame)
    totemIndicatorColorName:SetPoint("TOPLEFT", showTotemIndicatorCooldownSwipe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorColorName, L["Tooltip_Color_Name_Text"])

    local totemIndicatorHideAuras = CreateCheckbox("totemIndicatorHideAuras", L["Hide_Auras"], contentFrame)
    totemIndicatorHideAuras:SetPoint("LEFT", totemIndicatorColorName.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorHideAuras, L["Tooltip_Hide_Auras_On_Totem_Nameplates"])

    local totemIndicatorColorHealthBar = CreateCheckbox("totemIndicatorColorHealthBar", L["Color_HP"], contentFrame)
    totemIndicatorColorHealthBar:SetPoint("LEFT", showTotemIndicatorCooldownSwipe.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorColorHealthBar, L["Color_Healthbar"])

    local totemIndicatorDefaultCooldownTextSize = CreateSlider(contentFrame, L["Default_CD_Size"], 0.3, 2, 0.01, "totemIndicatorDefaultCooldownTextSize", nil, 95)
    totemIndicatorDefaultCooldownTextSize:SetPoint("TOP", totemIndicatorHideNameAndShiftIconDown, "BOTTOM", 40, -48)
    CreateTooltip(totemIndicatorDefaultCooldownTextSize, L["Tooltip_Size_Of_The_Default_Blizz_CD"])

    local totemIndicatorNoAnimation = CreateCheckbox("totemIndicatorNoAnimation", L["Anim"], contentFrame)
    totemIndicatorNoAnimation:SetPoint("LEFT", totemIndicatorDefaultCooldownTextSize, "RIGHT", 0, 3)
    CreateTooltipTwo(totemIndicatorNoAnimation, L["No_Animation"], L["Tooltip_No_Animation_Desc"])

    ----------------------
    -- Target indicator
    ----------------------
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, fourthLineY)
    anchorSubTarget:SetText(L["Target_Indicator"])

    anchorSubTarget.border = CreateBorderBox(anchorSubTarget)

    anchorSubTarget.icon = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubTarget.icon:SetTexture(BBP.targetIndicatorIconReplacement)
    anchorSubTarget.icon:SetRotation(math.rad(180))
    anchorSubTarget.icon:SetSize(48, 32)
    anchorSubTarget.icon:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

    local targetIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 3, 0.01, "targetIndicatorScale")
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
        { anchorFrame = targetIndicatorChangeTexture, x = -16, y = -20, label = L["Texture"] },
        125
    )

    targetIndicatorChangeTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetIndicatorTexture:Enable()
        else
            targetIndicatorTexture:Disable()
        end
    end)

    anchorSubTarget.iconDropdown = CreateLegacySizedDropdown(anchorSubTarget.extendedSettings, 125)
    anchorSubTarget.iconDropdown:SetupMenu(function(_, rootDescription)
        for _, entry in ipairs(BBP.targetIndicatorTextures) do
            rootDescription:CreateRadio(BBP.GetTargetIndicatorIconText(entry), function()
                return BBP.GetTargetIndicatorTexture().key == entry.key
            end, function()
                BetterBlizzPlatesDB.targetIndicatorIcon = entry.key
                BBP.needsUpdate = true
                BBP.RefreshAllNameplates()
            end)
        end
    end)

    anchorSubTarget.iconDropdown:SetPoint("TOPLEFT", targetIndicatorTexture, "TOPLEFT", 0, -43)

    anchorSubTarget.iconLabel = anchorSubTarget.extendedSettings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget.iconLabel:SetPoint("BOTTOM", anchorSubTarget.iconDropdown, "TOP", 0, 3)
    anchorSubTarget.iconLabel:SetText(L["Icon_Select"])


    ----------------------
    -- Raid Indicator
    ----------------------
    local anchorSubRaidmark = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubRaidmark:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, fourthLineY)
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
    anchorSubquest:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, fourthLineY)
    anchorSubquest:SetText(L["Quest_Indicator"])

    CreateBorderBox(anchorSubquest)

    local questIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    questIcon2:SetAtlas("smallquestbang")
    questIcon2:SetSize(44, 44)
    questIcon2:SetPoint("BOTTOM", anchorSubquest, "TOP", 0, -3)

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
    anchorSubFocus:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, secondLineY)
    anchorSubFocus:SetText(L["Focus_Target_Indicator"])

    CreateBorderBox(anchorSubFocus)

    local focusIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusIcon:SetTexture(BBP.focusIndicatorIconReplacement)
    focusIcon:SetSize(40, 40)
    focusIcon:SetPoint("BOTTOM", anchorSubFocus, "TOP", 0, -2)

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

    local function OpenColorPicker()
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
        { anchorFrame = focusTargetIndicatorChangeTexture, x = -16, y = -20, label = L["Texture"] },
        125
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
    anchorSubExecute:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY)
    anchorSubExecute:SetText(L["Execute_Indicator"])

    CreateBorderBox(anchorSubExecute)

    anchorSubExecute.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubExecute.t:SetTexture(BBP.executeIndicatorIconReplacement)
    anchorSubExecute.t:SetSize(50, 54)
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

    CreateMoreOptionsPopup(anchorSubExecute, contentFrame, BetterBlizzPlatesSubPanel, L["Execute_Indicator"], L["Tooltip_Open_More_Settings_For_Execute_Indicator"], 240)
    anchorSubExecute.extendedSettingsButton:SetPoint("TOPLEFT", executeTestIcons2, "BOTTOMLEFT", 12, -8)

    local executeIndicatorAlwaysOn = CreateCheckbox("executeIndicatorAlwaysOn", L["Always_On"], anchorSubExecute.extendedSettings)
    CreateTooltip(executeIndicatorAlwaysOn, L["Tooltip_Always_Display_Health_Percentage"])

    local executeIndicatorFriendly = CreateCheckbox("executeIndicatorFriendly", L["Friendly"], anchorSubExecute.extendedSettings)
    CreateTooltip(executeIndicatorFriendly, L["Show_On_Friendly_Nameplates"])

    anchorSubExecute.executeIndicatorUseTexture = CreateCheckbox("executeIndicatorUseTexture", L["Use_Texture"], anchorSubExecute.extendedSettings)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorUseTexture, L["Use_Texture"], L["Tooltip_Use_Texture_Desc"])
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

    local executeIndicatorNotOnFullHp = CreateCheckbox("executeIndicatorNotOnFullHp", "< 100%", anchorSubExecute.extendedSettings)
    CreateTooltip(executeIndicatorNotOnFullHp, L["Tooltip_Hide_On_100_Pct"])

    local executeIndicatorPercentSymbol = CreateCheckbox("executeIndicatorPercentSymbol", L["Pct_Symbol"], anchorSubExecute.extendedSettings)
    CreateTooltip(executeIndicatorPercentSymbol, L["Tooltip_Show_Pct_Symbol"])

    anchorSubExecute.executeIndicatorTargetOnly = CreateCheckbox("executeIndicatorTargetOnly", L["Target"], anchorSubExecute.extendedSettings)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorTargetOnly, L["Target_Only"], L["Tooltip_Target_Only_Desc"])

    local executeIndicatorShowDecimal = CreateCheckbox("executeIndicatorShowDecimal", L["Decimal"], anchorSubExecute.extendedSettings)
    CreateTooltip(executeIndicatorShowDecimal, L["Tooltip_Show_Decimal"])

    local executeIndicatorThreshold = CreateSlider(anchorSubExecute.extendedSettings, L["Threshold"], 5, 100, 1, "executeIndicatorThreshold")
    CreateTooltip(executeIndicatorThreshold, L["Tooltip_Percentage_Of_When_The_Execute_Indicator"])

    anchorSubExecute.executeSkull = CreateCheckbox("executeSkull", L["Show_Execute_Skull"], anchorSubExecute.extendedSettings)
    CreateTooltipTwo(anchorSubExecute.executeSkull, L["Show_Execute_Skull"] .. " |T" .. BBP.executeIndicatorIconReplacement .. ":18:18|t", L["Tooltip_Show_Execute_Skull_Desc"])

    anchorSubExecute.skullAttach = CreateCheckbox("executeSkullAttachToHealth", L["Attach_To_Current_Health"], anchorSubExecute.extendedSettings, nil, function(_, value)
        if value then
            BetterBlizzPlatesDB.executeSkullAttachToThreshold = false
            anchorSubExecute.skullThreshold:SetChecked(false)
        end
    end)
    CreateTooltipTwo(anchorSubExecute.skullAttach, L["Attach_To_Current_Health"], L["Tooltip_Attach_To_Current_Health_Desc"])

    anchorSubExecute.skullThreshold = CreateCheckbox("executeSkullAttachToThreshold", L["Attach_To_Threshold_Spot"], anchorSubExecute.extendedSettings, nil, function(_, value)
        if value then
            BetterBlizzPlatesDB.executeSkullAttachToHealth = false
            anchorSubExecute.skullAttach:SetChecked(false)
        end
    end)
    CreateTooltipTwo(anchorSubExecute.skullThreshold, L["Attach_To_Threshold_Spot"], L["Tooltip_Attach_To_Threshold_Spot_Desc"])

    anchorSubExecute.skullKeep = CreateCheckbox("executeSkullKeepIndicator", L["Keep_Execute_Text_Line"], anchorSubExecute.extendedSettings)
    CreateTooltipTwo(anchorSubExecute.skullKeep, L["Keep_Execute_Text_Line"], L["Tooltip_Keep_Execute_Text_Line_Desc"])

    anchorSubExecute.skullScale = CreateSlider(anchorSubExecute.extendedSettings, L["Size"], 0.5, 3, 0.01, "executeSkullScale")
    anchorSubExecute.skullXPos = CreateSlider(anchorSubExecute.extendedSettings, L["X_Offset"], -50, 50, 1, "executeSkullXPos", "X")
    anchorSubExecute.skullYPos = CreateSlider(anchorSubExecute.extendedSettings, L["Y_Offset"], -50, 50, 1, "executeSkullYPos", "Y")

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
    end
    executeIndicatorToggle()

    executeIndicatorAlwaysOn:HookScript("OnClick", function(_, btn, down)
        executeIndicatorToggle()
    end)

    moreCol = anchorSubExecute.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(executeIndicatorAlwaysOn)
    moreCol.Add(executeIndicatorNotOnFullHp, 12)
    moreCol.Add(executeIndicatorFriendly)
    moreCol.Add(anchorSubExecute.executeIndicatorTargetOnly)
    moreCol.Slider(executeIndicatorThreshold)
    moreCol.Header(L["Execute_Text_Line"])
    moreCol.Add(executeIndicatorShowDecimal)
    moreCol.Add(executeIndicatorPercentSymbol)
    moreCol.Add(anchorSubExecute.executeIndicatorUseTexture)
    moreCol.Header(L["Execute_Skull"] .. " |T" .. BBP.executeIndicatorIconReplacement .. ":24:24|t")
    moreCol.Add(anchorSubExecute.executeSkull)
    moreCol.Add(anchorSubExecute.skullAttach)
    moreCol.Add(anchorSubExecute.skullThreshold)
    moreCol.Add(anchorSubExecute.skullKeep)
    moreCol.Slider(anchorSubExecute.skullScale, 0.85)
    moreCol.Slider(anchorSubExecute.skullXPos, 0.85)
    moreCol.Slider(anchorSubExecute.skullYPos, 0.85)
    anchorSubExecute.extendedSettings.Fit()

    anchorSubExecute.UpdateSkullState = function()
        local skullOn = BetterBlizzPlatesDB.executeSkull
        for _, widget in ipairs({ anchorSubExecute.skullAttach, anchorSubExecute.skullThreshold, anchorSubExecute.skullKeep, anchorSubExecute.skullScale, anchorSubExecute.skullXPos, anchorSubExecute.skullYPos }) do
            if skullOn then widget:Enable() else widget:Disable() end
            widget:SetAlpha(skullOn and 1 or 0.5)
        end
    end
    anchorSubExecute.UpdateSkullState()
    anchorSubExecute.executeSkull:HookScript("OnClick", anchorSubExecute.UpdateSkullState)

    ----------------------
    -- Arena Indicator
    ----------------------
    local anchorSubArena = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubArena:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorSubArena:SetText(L["Arena_Indicator"])

    CreateBorderBox(anchorSubArena)

    anchorSubArena.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubArena.t:SetAtlas("questbonusobjective")
    anchorSubArena.t:SetSize(32, 32)
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

    -- BBP.arenaIndicatorIDColor = CreateCheckbox("arenaIndicatorIDColor", "ID", contentFrame)
    -- BBP.arenaIndicatorIDColor:SetPoint("LEFT", arenaIndicatorTestMode2.Text, "RIGHT", 0, 0)

    -- local function OpenColorPicker()
    --     local r, g, b = unpack(BetterBlizzPlatesDB.arenaIndicatorIDColorRGB or {1, 1, 1})

    --     ColorPickerFrame:SetupColorPickerAndShow({
    --         r = r, g = g, b = b,
    --         swatchFunc = function()
    --             local r, g, b = ColorPickerFrame:GetColorRGB()
    --             BetterBlizzPlatesDB.arenaIndicatorIDColorRGB = { r, g, b }
    --             BBP.RefreshAllNameplates()
    --             BBP.arenaIndicatorIDColor.Text:SetTextColor(unpack(BetterBlizzPlatesDB.arenaIndicatorIDColorRGB))
    --         end,
    --         cancelFunc = function(previousValues)
    --             local r, g, b = previousValues.r, previousValues.g, previousValues.b
    --             BetterBlizzPlatesDB.arenaIndicatorIDColorRGB = { r, g, b }
    --             BBP.RefreshAllNameplates()
    --             BBP.arenaIndicatorIDColor.Text:SetTextColor(unpack(BetterBlizzPlatesDB.arenaIndicatorIDColorRGB))
    --         end,
    --     })
    -- end

    -- BBP.idColorButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    -- BBP.idColorButton:SetText("Color")
    -- BBP.idColorButton:SetPoint("LEFT", BBP.arenaIndicatorIDColor.text, "RIGHT", -1, 0)
    -- BBP.idColorButton:SetSize(43, 18)
    -- BBP.idColorButton:SetScript("OnClick", OpenColorPicker)

    local showCircleOnArenaID = CreateCheckbox("showCircleOnArenaID", L["Show_Circle_On_ID"], contentFrame)
    showCircleOnArenaID:SetPoint("TOPLEFT", arenaIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCircleOnArenaID, L["Tooltip_Show_A_Colored_Circle_On_Each"])

    ----------------------
    -- Class Icon
    ----------------------
    local anchorSubClassIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubClassIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubClassIcon:SetText(L["Class_Indicator"])

    CreateBorderBox(anchorSubClassIcon)

    anchorSubClassIcon.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubClassIcon.t:SetAtlas("groupfinder-icon-class-mage")
    anchorSubClassIcon.t:SetSize(33, 33)
    anchorSubClassIcon.t:SetPoint("BOTTOM", anchorSubClassIcon, "TOP", 0, 1.5)
    --anchorSubClassIcon.t:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

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
    CreateTooltip(classIndicatorEnemy, L["Tooltip_Show_On_Enemy_Nameplates_Desc"])

    local classIndicatorFriendly = CreateCheckbox("classIndicatorFriendly", L["Friendly"], contentFrame)
    classIndicatorFriendly:SetPoint("LEFT", classIndicatorEnemy.text, "RIGHT", -2, 0)
    CreateTooltip(classIndicatorFriendly, L["Tooltip_Show_On_Friendly_Nameplates_Desc"])

    CreateMoreOptionsPopup(anchorSubClassIcon, contentFrame, BetterBlizzPlatesSubPanel, L["Class_Indicator"], L["Tooltip_Open_More_Settings_For_Class_Indicator"], 420)
    anchorSubClassIcon.extendedSettingsButton:SetPoint("TOPLEFT", classIndicatorEnemy, "BOTTOMLEFT", 12, -8)

    anchorSubHeal.classIndicatorAlpha = CreateSlider(anchorSubClassIcon.extendedSettings, L["Alpha"], 0.1, 1, 0.01, "classIndicatorAlpha", false, 110)
    CreateTooltipTwo(anchorSubHeal.classIndicatorAlpha, L["Class_Indicator_Alpha"])

    local classIconSquareBorder = CreateCheckbox("classIconSquareBorder", L["Square"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconSquareBorder, L["Tooltip_Square_Instead_Of_Circle_Icon_For"])

    local classIconSquareBorderFriendly = CreateCheckbox("classIconSquareBorderFriendly", L["Square_Friend"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconSquareBorderFriendly, L["Tooltip_Square_Instead_Of_Circle_Icon_For_2"])

    local classIconArenaOnly = CreateCheckbox("classIconArenaOnly", L["Arena_Only"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconArenaOnly, L["Tooltip_Show_In_Arena_Only"])

    local classIconBgOnly = CreateCheckbox("classIconBgOnly", L["BG_Only"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconBgOnly, L["Tooltip_Show_In_Battlegrounds_Only"])

    local classIndicatorSpecIcon = CreateCheckbox("classIndicatorSpecIcon", L["Show_Spec_Icon"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorSpecIcon, L["Tooltip_Show_Spec_Instead_Of_Class_Icon_2"])

    local classIndicatorHealer = CreateCheckbox("classIndicatorHealer", L["Show_Cross_On_Healer"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHealer, L["Tooltip_Show_Cross_Instead_Of_Class_Spec"])

    local classIconColorBorder = CreateCheckbox("classIconColorBorder", L["Class_Color_Border"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIconColorBorder, L["Class_Color_Border"])

    local classIndicatorHighlight = CreateCheckbox("classIndicatorHighlight", L["Highlight_Target"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHighlight, L["Tooltip_Show_Highlight_On_Current_Target_Icon"])

    anchorSubClassIcon.classIndicatorCCAuras = CreateCheckbox("classIndicatorCCAuras", L["Show_CC"], anchorSubClassIcon.extendedSettings)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorCCAuras, L["Show_Crowd_Control"], L["Tooltip_Show_Crowd_Control_Desc"], L["Tooltip_Show_Crowd_Control_SubText_2"])
    anchorSubClassIcon.classIndicatorCCAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.Print(L["Print_Enabled_Friendly_Debuffs_And_PvP_CC_3"])
            if BBP.friendlyNpdeBuffEnable then
                if not BBP.friendlyNpdeBuffEnable:GetChecked() then
                    BBP.friendlyNpdeBuffEnable:Click()
                end
                if not BBP.friendlyNpdeBuffFilterCC:GetChecked() then
                    BBP.friendlyNpdeBuffFilterCC:Click()
                end
            else
                BetterBlizzPlatesDB.friendlyNpdeBuffEnable = true
                BetterBlizzPlatesDB.friendlyNpdeBuffFilterCC = true
            end
        end
    end)
    anchorSubClassIcon.classIndicatorCCAuras:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzPlatesDB.classIndicatorCCHideCdText then
                BetterBlizzPlatesDB.classIndicatorCCHideCdText = true
            else
                BetterBlizzPlatesDB.classIndicatorCCHideCdText = nil
            end
            BBP.RefreshAllNameplates()
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local classIndicatorHighlightColor = CreateCheckbox("classIndicatorHighlightColor", L["Class_Color_Highlight"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHighlightColor, L["Tooltip_Class_Color_Target_Highlight"])

    local classIndicatorHideRaidMarker = CreateCheckbox("classIndicatorHideRaidMarker", L["Hide_Raidmarker"], anchorSubClassIcon.extendedSettings)
    CreateTooltip(classIndicatorHideRaidMarker, L["Tooltip_Hide_Raidmarker_On_Nameplates_With_Class"])

    moreCol = anchorSubClassIcon.extendedSettings.Column(16)
    moreCol.Header(L["Icon"])
    moreCol.Add(classIconSquareBorder)
    moreCol.Add(classIconSquareBorderFriendly)
    moreCol.Add(classIndicatorSpecIcon)
    moreCol.Add(classIndicatorHealer)
    moreCol.Add(classIconColorBorder)
    moreCol.Header(L["Highlight"])
    moreCol.Add(classIndicatorHighlight)
    moreCol.Add(classIndicatorHighlightColor)
    moreCol = anchorSubClassIcon.extendedSettings.Column(216)
    moreCol.Header(L["Visibility"])
    moreCol.Add(classIconArenaOnly)
    moreCol.Add(classIconBgOnly)
    moreCol.Slider(anchorSubHeal.classIndicatorAlpha)
    moreCol.Header(L["Other"])
    moreCol.Add(anchorSubClassIcon.classIndicatorCCAuras)
    moreCol.Add(classIndicatorHideRaidMarker)
    anchorSubClassIcon.extendedSettings.Fit()

    ----------------------
    -- Party Pointer
    ----------------------
    local anchorSubPointerIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPointerIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, thirdLineY)
    anchorSubPointerIndicator:SetText(L["Party_Pointer"])

    CreateBorderBox(anchorSubPointerIndicator)

    anchorSubPointerIndicator.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubPointerIndicator.t:SetTexture(BBP.partyPointerIconReplacement)
    anchorSubPointerIndicator.t:SetSize(28, 29)
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
    CreateTooltip(partyPointerHealer, L["Tooltip_Show_A_Cross_On_Top_Of_2"])

    anchorSubPointerIndicator.partyPointerHighlight = CreateCheckbox("partyPointerHighlight", L["Highlight"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlight, L["Highlight"], L["Tooltip_Highlight_Desc"], L["Tooltip_Highlight_SubText"])
    anchorSubPointerIndicator.partyPointerHighlight:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.partyPointerHighlightRGB, BBP.RefreshAllNameplates)
        end
    end)

    local partyPointerHealerReplace = CreateCheckbox("partyPointerHealerReplace", L["Replace"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(partyPointerHealerReplace, L["Replace_Party_Pointer_With_Healer_Icon"], L["Tooltip_Replace_Party_Pointer_With_Healer_Icon_Desc_2"])

    local partyPointerHideAll = CreateCheckbox("partyPointerHideAll", L["Hide_All"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(partyPointerHideAll, L["Hide_All"], L["Tooltip_Hide_All_2_Desc"])

    anchorSubPointerIndicator.partyPointerCCAuras = CreateCheckbox("partyPointerCCAuras", L["Show_CC"], anchorSubPointerIndicator.extendedSettings)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerCCAuras, L["Show_CC"], L["Tooltip_Show_CC_Desc"], L["Tooltip_Show_Crowd_Control_SubText_2"])

    anchorSubPointerIndicator.partyPointerHighlightScale = CreateSlider(anchorSubPointerIndicator.extendedSettings, L["PP_Highlight_Size"], 0.8, 1.7, 0.01, "partyPointerHighlightScale")
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlightScale, L["Change_The_Size_Of_The_Highlight_Requires_Highlight"])

    moreCol = anchorSubPointerIndicator.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(partyPointerArenaOnly)
    moreCol.Add(partyPointerBgOnly)
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
    anchorSubPointerIndicator.extendedSettings.Fit()

   ----------------------
    -- Fake Name Reposition
    ----------------------
    local anchorSubFakeName = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFakeName:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubFakeName:SetText(L["Name_Reposition"])

    CreateBorderBox(anchorSubFakeName)

    anchorSubFakeName.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFakeName.t:SetAtlas("MiniMap-PositionArrows")
    anchorSubFakeName.t:SetSize(32, 44)
    anchorSubFakeName.t:SetPoint("BOTTOM", anchorSubFakeName, "TOP", 0, -3)
    anchorSubFakeName.t:SetRotation(math.pi / 2)
    anchorSubFakeName.t:SetDesaturated(true)
    anchorSubFakeName.t:SetVertexColor(1,1,0.1)

    anchorSubFakeName.useFakeName = CreateCheckbox("useFakeName", L["Enable_Name_Reposition"], contentFrame)
    anchorSubFakeName.useFakeName:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    anchorSubFakeName.fakeNameXPos = CreateSlider(anchorSubFakeName.useFakeName, "|cffFF0000" .. L["Enemy_X_Offset"] .. "|r", -50, 50, 1, "fakeNameXPos", "X")
    anchorSubFakeName.fakeNameXPos:SetPoint("TOP", anchorSubFakeName, "BOTTOM", 0, -15)

    anchorSubFakeName.fakeNameYPos = CreateSlider(anchorSubFakeName.useFakeName, "|cffFF0000" .. L["Enemy_Y_Offset"] .. "|r", -50, 50, 1, "fakeNameYPos", "Y")
    anchorSubFakeName.fakeNameYPos:SetPoint("TOP", anchorSubFakeName.fakeNameXPos, "BOTTOM", 0, -15)

    anchorSubFakeName.fakeNameFriendlyXPos = CreateSlider(anchorSubFakeName.useFakeName, "|cff0CC2FF" .. L["Friendly_X_Offset"] .. "|r", -50, 50, 1, "fakeNameFriendlyXPos", "X")
    anchorSubFakeName.fakeNameFriendlyXPos:SetPoint("TOP", anchorSubFakeName.fakeNameYPos, "BOTTOM", 0, -15)

    anchorSubFakeName.fakeNameFriendlyYPos = CreateSlider(anchorSubFakeName.useFakeName, "|cff0CC2FF" .. L["Friendly_Y_Offset"] .. "|r", -50, 50, 1, "fakeNameFriendlyYPos", "Y")
    anchorSubFakeName.fakeNameFriendlyYPos:SetPoint("TOP", anchorSubFakeName.fakeNameFriendlyXPos, "BOTTOM", 0, -15)

    local fakeNameAnchorDropdown = CreateAnchorDropdown(
        "partyPointerDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "fakeNameAnchor",
        function(arg1) 
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubFakeName.fakeNameFriendlyYPos, x = -16, y = -33, label = L["Name_Anchor_Point"] }
    )
    CreateTooltipTwo(fakeNameAnchorDropdown, L["Name_Anchor_Point"], L["Tooltip_Name_Anchor_Point_Desc"])

    local fakeNameAnchorRelativeDropdown = CreateAnchorDropdown(
        "arenaSpecAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "fakeNameAnchorRelative",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameAnchorDropdown, x = 0, y = -41, label = L["Healthbar_Anchor_Point"] }
    )
    CreateTooltipTwo(fakeNameAnchorRelativeDropdown, L["Healthbar_Anchor_Point"], L["Tooltip_Healthbar_Anchor_Point_Desc"])

    anchorSubFakeName.useFakeName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            fakeNameAnchorDropdown:Enable()
            fakeNameAnchorRelativeDropdown:Enable()
            if BetterBlizzPlates.arenaSpecAnchor == "TOP" then
                BetterBlizzPlates.arenaSpecAnchor = "CENTER"
            end
        else
            fakeNameAnchorDropdown:Disable()
            fakeNameAnchorRelativeDropdown:Disable()
            if BetterBlizzPlates.arenaSpecAnchor == "CENTER" then
                BetterBlizzPlates.arenaSpecAnchor = "TOP"
            end
        end
        BBP.arenaSpecAnchorDropdown:GenerateMenu()
    end)

    if not BetterBlizzPlatesDB.useFakeName then
        fakeNameAnchorDropdown:Disable()
        fakeNameAnchorRelativeDropdown:Disable()
    end

    --local useFakeName = CreateCheckbox("useFakeName", "Enable Name Reposition", contentFrame) --moved up
    anchorSubFakeName.useFakeName:SetPoint("TOPLEFT", fakeNameAnchorRelativeDropdown, "BOTTOMLEFT", 16, 8)
    anchorSubFakeName.useFakeName:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(anchorSubFakeName.useFakeName)
    end)
    CreateTooltip(anchorSubFakeName.useFakeName, L["Tooltip_Enables_Name_Repositioning_By_Using_A"])
    CreateTooltip(anchorSubFakeName.t, L["Tooltip_Enables_Name_Repositioning_By_Using_A"])

    CreateMoreOptionsPopup(anchorSubFakeName, contentFrame, BetterBlizzPlatesSubPanel, L["Name_Reposition"], nil, 220)
    anchorSubFakeName.extendedSettingsButton:SetPoint("TOPLEFT", anchorSubFakeName.useFakeName, "BOTTOMLEFT", 12, 5)

    anchorSubFakeName.useFakeNameAnchorBottom = CreateCheckbox("useFakeNameAnchorBottom", L["Anchor_Friend"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(anchorSubFakeName.useFakeNameAnchorBottom, L["Anchor_Friendly_Name_To_Bottom"], L["Tooltip_Anchor_Friendly_Name_To_Bottom_Desc"])

    local fakeNameScaleWithParent = CreateCheckbox("fakeNameScaleWithParent", L["Scale"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(fakeNameScaleWithParent, L["Scale_With_Nameplate"], L["Tooltip_Scale_With_Nameplate_Desc"])

    anchorSubFakeName.fakeNameRaiseStrata = CreateCheckbox("fakeNameRaiseStrata", L["Raise_Strata"], anchorSubFakeName.extendedSettings)
    CreateTooltipTwo(anchorSubFakeName.fakeNameRaiseStrata, L["Raise_Strata"], L["Tooltip_Raise_Strata_Desc_2"])
    anchorSubFakeName.fakeNameRaiseStrata:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    moreCol = anchorSubFakeName.extendedSettings.Column(16)
    moreCol.Header(L["Friendly"])
    moreCol.Add(anchorSubFakeName.useFakeNameAnchorBottom)
    moreCol.Header(L["Other"])
    moreCol.Add(fakeNameScaleWithParent)
    moreCol.Add(anchorSubFakeName.fakeNameRaiseStrata)
    anchorSubFakeName.extendedSettings.Fit()

    anchorSubFakeName.UpdatePopupState = function()
        local enabled = anchorSubFakeName.useFakeName:GetChecked()
        for _, checkbox in ipairs({ anchorSubFakeName.useFakeNameAnchorBottom, fakeNameScaleWithParent, anchorSubFakeName.fakeNameRaiseStrata }) do
            if enabled then EnableElement(checkbox) else DisableElement(checkbox) end
        end
    end
    anchorSubFakeName.UpdatePopupState()
    anchorSubFakeName.useFakeName:HookScript("OnClick", anchorSubFakeName.UpdatePopupState)

    ----------------------
    -- Health Numbers
    ----------------------
    local anchorSubHealthNumbers = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHealthNumbers:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, thirdLineY)
    anchorSubHealthNumbers:SetText(L["Health_Numbers"])

    anchorSubHealthNumbers.border = CreateBorderBox(anchorSubHealthNumbers)

    anchorSubHealthNumbers.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubHealthNumbers.t:SetTexture(BBP.healthNumbersIconReplacement)
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

    anchorSubHealthNumbers.closeButton = CreateFrame("Button", nil, anchorSubHealthNumbers.extendedSettings, "UIPanelCloseButton")
    anchorSubHealthNumbers.closeButton:SetFrameLevel((anchorSubHealthNumbers.extendedSettings.TitleContainer or anchorSubHealthNumbers.extendedSettings):GetFrameLevel() + 10)
    anchorSubHealthNumbers.closeButton:SetPoint("TOPRIGHT", anchorSubHealthNumbers.extendedSettings, "TOPRIGHT", 4, 4)
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
    anchorThreatColor:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, fifthLineY)
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

    anchorThreatColor.threatColorName = CreateCheckbox("threatColorName", L["Color_Name"], contentFrame)
    anchorThreatColor.threatColorName:SetPoint("TOPLEFT", anchorThreatColor.enemyColorThreatCombatOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.threatColorName, L["Threat_Color_Name"], L["Tooltip_Threat_Color_Name_Desc"])

    anchorThreatColor.threatColorNameOnly = CreateCheckbox("threatColorNameOnly", L["Name_Only"], contentFrame)
    anchorThreatColor.threatColorNameOnly:SetPoint("LEFT", anchorThreatColor.threatColorName.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorThreatColor.threatColorNameOnly, L["Threat_Color_Name_Only"], L["Tooltip_Threat_Color_Name_Only_Desc"])

    CreateMoreOptionsPopup(anchorThreatColor, contentFrame, BetterBlizzPlatesSubPanel, L["Threat_Colors"], nil, 220)
    anchorThreatColor.extendedSettingsButton:SetPoint("TOPLEFT", anchorThreatColor.threatColorName, "BOTTOMLEFT", 12, -6)

    anchorThreatColor.enemyColorThreatCombatOnlyPlayer = CreateCheckbox("enemyColorThreatCombatOnlyPlayer", L["Player_Combat_Only"], anchorThreatColor.extendedSettings)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatCombatOnlyPlayer, L["Player_Combat_Only"], L["Tooltip_Player_Combat_Only_2_Desc"])

    anchorThreatColor.enemyColorThreatHideSolo = CreateCheckbox("enemyColorThreatHideSolo", L["Turn_Off_While_Solo"], anchorThreatColor.extendedSettings)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatHideSolo, L["Turn_Off_While_Solo"], L["Tooltip_Turn_Off_While_Solo_Desc"])

    anchorThreatColor.threatColorRoleOnly = CreateCheckbox("threatColorRoleOnly", L["Specific_Role_Only"], anchorThreatColor.extendedSettings)
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
        window.name = L["Module_Name_Advanced"]
        anchorThreatColor.roleWindow = window
        window:SetSize(190, 120)
        window:SetPoint("CENTER")
        window:SetFrameStrata("FULLSCREEN_DIALOG")
        window:SetFrameLevel(600)
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

    anchorThreatColor.threatPercent = CreateCheckbox("threatPercent", L["Show_Threat_Percent"], anchorThreatColor.extendedSettings, nil, function()
        anchorThreatColor.UpdatePercentState()
        BBP.RefreshThreatPercent()
    end)

    anchorThreatColor.threatPercentTestMode = CreateCheckbox("threatPercentTestMode", L["Test"], anchorThreatColor.extendedSettings, nil, function()
        BBP.RefreshThreatPercent()
    end)

    anchorThreatColor.threatPercentScale = CreateSlider(anchorThreatColor.extendedSettings, L["Size"], 0.5, 2.5, 0.01, "threatPercentScale", false, 150)
    anchorThreatColor.threatPercentXPos = CreateSlider(anchorThreatColor.extendedSettings, L["X_Offset"], -50, 50, 1, "threatPercentXPos", false, 150)
    anchorThreatColor.threatPercentYPos = CreateSlider(anchorThreatColor.extendedSettings, L["Y_Offset"], -50, 50, 1, "threatPercentYPos", false, 150)

    moreCol = anchorThreatColor.extendedSettings.Column(16)
    moreCol.Header(L["Visibility"])
    moreCol.Add(anchorThreatColor.enemyColorThreatCombatOnlyPlayer)
    moreCol.Add(anchorThreatColor.enemyColorThreatHideSolo)
    moreCol.Add(anchorThreatColor.threatColorRoleOnly)
    moreCol.Header(L["Threat_Percent"])
    moreCol.Add(anchorThreatColor.threatPercent)
    moreCol.Add(anchorThreatColor.threatPercentTestMode)
    moreCol.Slider(anchorThreatColor.threatPercentScale)
    moreCol.Slider(anchorThreatColor.threatPercentXPos)
    moreCol.Slider(anchorThreatColor.threatPercentYPos)
    moreCol.Gap(20)
    anchorThreatColor.threatPercentAnchor = CreateAnchorDropdown(
        "threatPercentAnchorDropdown",
        anchorThreatColor.extendedSettings,
        L["Select_Anchor_Point"],
        "threatPercentAnchor",
        function()
            BBP.RefreshThreatPercent()
        end,
        { anchorFrame = anchorThreatColor.extendedSettings, x = 16, y = moreCol.y, label = L["Anchor"] },
        150
    )
    moreCol.Gap(32)
    anchorThreatColor.extendedSettings.Fit()

    function anchorThreatColor.UpdatePercentState()
        local enabled = BetterBlizzPlatesDB.threatPercent
        local toggle = enabled and EnableElement or DisableElement
        toggle(anchorThreatColor.threatPercentTestMode)
        toggle(anchorThreatColor.threatPercentScale)
        toggle(anchorThreatColor.threatPercentXPos)
        toggle(anchorThreatColor.threatPercentYPos)
        anchorThreatColor.threatPercentAnchor:SetEnabled(enabled and true or false)
    end
    anchorThreatColor.UpdatePercentState()
    anchorThreatColor.extendedSettings:HookScript("OnShow", anchorThreatColor.UpdatePercentState)


    ----------------------
    -- Target Text
    ----------------------
    local anchorSubTargetText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTargetText:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, fourthLineY)
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
        local playerName = UnitName("player")
        local playerClass = UnitClassBase("player")
        local classColor = BBP.GetClassColor(playerClass)
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
    -- Faction Indicator
    ----------------------
    local anchorSubFaction = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFaction:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, secondLineY)
    anchorSubFaction:SetText(L["Faction_Indicator"])

    CreateBorderBox(anchorSubFaction)

    anchorSubFaction.factionIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    if C_Texture.GetAtlasInfo("questlog-questtypeicon-alliance") then
        anchorSubFaction.factionIcon2:SetAtlas("questlog-questtypeicon-alliance")
        anchorSubFaction.factionIcon2:SetSize(34, 34)
    else
        anchorSubFaction.factionIcon2:SetTexture("Interface\\Icons\\Inv_BannerPVP_02")
        anchorSubFaction.factionIcon2:SetSize(28, 28)
    end
    anchorSubFaction.factionIcon2:SetPoint("BOTTOM", anchorSubFaction, "TOP", 0, 3)

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
        [13] = L["Faction_Icons_Communities_Buttons"],
        [14] = L["Faction_Icons_POI_Icons"],
        [15] = L["Faction_Icons_Faction_Flags"],
    }

    anchorSubFaction.factionIconSetDropdown = CreateLegacySizedDropdown(contentFrame, 125)
    local function CurrentFactionIconSet()
        local currentSet = BetterBlizzPlatesDB.factionIndicatorIconSet or 13
        if not BBP.IsFactionIconSetAvailable(currentSet) then
            currentSet = 3
        end
        return currentSet
    end
    anchorSubFaction.factionIconSetDropdown:SetupMenu(function(_, rootDescription)
        for i = 1, #anchorSubFaction.factionIconSetNames do
            if BBP.IsFactionIconSetAvailable(i) then
                rootDescription:CreateRadio(anchorSubFaction.factionIconSetNames[i], function()
                    return CurrentFactionIconSet() == i
                end, function()
                    BetterBlizzPlatesDB.factionIndicatorIconSet = i
                    BBP.needsUpdate = true
                    BBP.RefreshAllNameplates()
                end)
            end
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
        ft.Add(anchorSubTotem, ft.CheckboxToggle("totemIndicator"))

        function ft.Refresh()
            for _, toggle in ipairs(ft.toggles) do
                toggle:Refresh()
            end
        end
        BetterBlizzPlatesSubPanel:HookScript("OnShow", ft.Refresh)
        hooksecurefunc(SettingsPanel, "DisplayLayout", function()
            if BetterBlizzPlatesSubPanel:IsVisible() then
                ft.Refresh()
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

    local listFrame = CreateFrame("Frame", nil, guiCastbar)
    listFrame:SetAllPoints(guiCastbar)
    local scrollFrame = CreateList(listFrame, "castEmphasisList", BetterBlizzPlatesDB.castEmphasisList, BBP.RefreshAllNameplates, true, nil, nil, 360)
    scrollFrame:SetPoint("TOPLEFT", -17, -10)

    local castEmphasisText = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castEmphasisText:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 25, 3)
    castEmphasisText:SetText(L["Cast_Emphasis_List"])

    local onMeOnlyTexture = listFrame:CreateTexture(nil, "OVERLAY")
    onMeOnlyTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    onMeOnlyTexture:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", -99, -1)
    onMeOnlyTexture:SetSize(18,20)
    CreateTooltipTwo(onMeOnlyTexture, L["Only_On_Me_Checkboxes"], L["Tooltip_Only_On_Me_Checkboxes_Desc"], L["Tooltip_Only_On_Me_SubText"])

    local how2usecastemphasis = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usecastemphasis:SetPoint("TOP", guiCastbar, "BOTTOMLEFT", 180, 165)
    how2usecastemphasis:SetText(L["Add_Name_Or_Spell_ID_Case_Insensitive_Type_2"])

    local castbarSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -280, -5)
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

    local enableCastbarCustomization = CreateCheckbox("enableCastbarCustomization", L["Enable_Castbar_Customization"], guiCastbar, nil, BBP.ToggleSpellCastEventRegistration)
    enableCastbarCustomization:SetPoint("TOPLEFT", castbarSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)

    local castbarAlwaysOnTop = CreateCheckbox("castbarAlwaysOnTop", L["Always_On_Top"], enableCastbarCustomization)
    castbarAlwaysOnTop:SetPoint("LEFT", enableCastbarCustomization.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castbarAlwaysOnTop, L["Always_On_Top"], L["Tooltip_Always_On_Top_Desc"])

    local castbarQuickHide = CreateCheckbox("castbarQuickHide", L["Castbar_Quick_Hide"], enableCastbarCustomization)
    castbarQuickHide:SetPoint("TOPLEFT", enableCastbarCustomization, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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

    local showCastBarIconWhenNoninterruptible = CreateCheckbox("showCastBarIconWhenNoninterruptible", L["Show_Cast_Icon_On_Non_Interruptable"], enableCastbarCustomization)
    showCastBarIconWhenNoninterruptible:SetPoint("TOPLEFT", castbarQuickHide, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCastBarIconWhenNoninterruptible, L["Tooltip_Show_The_Cast_Icon_On_Non"])

    local hideNameDuringCast = CreateCheckbox("hideNameDuringCast", L["Hide_Name"], enableCastbarCustomization)
    hideNameDuringCast:SetPoint("LEFT", showCastBarIconWhenNoninterruptible.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideNameDuringCast, L["Hide_Unit_Name"], L["Tooltip_Hide_Unit_Name_Desc"])

    local castBarDragonflightShield = CreateCheckbox("castBarDragonflightShield", L["New_Shield_On_Non_Interruptable"], enableCastbarCustomization)
    castBarDragonflightShield:SetPoint("TOPLEFT", showCastBarIconWhenNoninterruptible, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarDragonflightShield, L["Tooltip_Replace_The_Old_Pixelated_Non_Interruptible"])

    local castBarFullTextWidth = CreateCheckbox("castBarFullTextWidth", L["Full_Text_Width"], enableCastbarCustomization)
    castBarFullTextWidth:SetPoint("LEFT", castBarDragonflightShield.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarFullTextWidth, L["Full_Text_Width"], L["Tooltip_Full_Text_Width_Desc"])

    local castBarIconScale = CreateSlider(enableCastbarCustomization, L["Castbar_Icon_Size"], 0.1, 2.5, 0.01, "castBarIconScale")
    castBarIconScale:SetPoint("TOPLEFT", castBarDragonflightShield, "BOTTOMLEFT", 12, -10)

    local castBarIconXPos = CreateSlider(enableCastbarCustomization, L["Icon_X_Offset"], -50, 50, 1, "castBarIconXPos", "X", 100)
    castBarIconXPos:SetPoint("LEFT", castBarIconScale, "RIGHT", 12, 0)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, L["Icon_Y_Offset"], -50, 50, 1, "castBarIconYPos", "Y", 100)
    castBarIconYPos:SetPoint("TOP", castBarIconXPos, "BOTTOM", 0, -15)

    local anchorCastIconOnRight = CreateCheckbox("anchorCastIconOnRight", L["Anchor_Icon_Right"], enableCastbarCustomization)
    anchorCastIconOnRight:SetPoint("LEFT", castBarIconYPos, "RIGHT", 5, 16)
    CreateTooltipTwo(anchorCastIconOnRight, L["Anchor_Cast_Icon_On_Right"], L["Tooltip_Anchor_Cast_Icon_On_Right_Desc"])

--[=[
    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconXPos", "X")
    castBarIconXPos:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y")
    castBarIconYPos:SetPoint("TOPLEFT", castBarIconXPos, "BOTTOMLEFT", 0, -15)

]=]

    local castBarTextScale = CreateSlider(enableCastbarCustomization, L["Castbar_Text_Size"], 0.5, 2.5, 0.01, "castBarTextScale")
    castBarTextScale:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarHeight = CreateSlider(enableCastbarCustomization, L["Castbar_Height"], 4, 36, 0.1, "castBarHeight", "Height")
    castBarHeight:SetPoint("TOPLEFT", castBarTextScale, "BOTTOMLEFT", 0, -15)

    local castbarHeightResetButton = CreateFrame("Button", nil, enableCastbarCustomization, "UIPanelButtonTemplate")
    castbarHeightResetButton:SetText(L["Default"])
    castbarHeightResetButton:SetWidth(60)
    castbarHeightResetButton:SetPoint("LEFT", castBarHeight, "RIGHT", 10, 0)
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
            if ColorPickerFrame.Content then
                ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
            end
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
    castBarCastColorIcon:SetAtlas("CircleMaskScalable")
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
    castBarChanneledColorIcon:SetAtlas("CircleMaskScalable")
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
    castBarNoninterruptibleColorIcon:SetAtlas("CircleMaskScalable")
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
        { anchorFrame = useCustomCastbarTexture, x = -8, y = -23, label = "CustomCastbar" }
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
        { anchorFrame = useCustomCastbarTexture, x = -8, y = -54, label = "CustomBGCastbar" }
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
        { anchorFrame = useCustomCastbarTexture, x = -8, y = -85, label = "CustomBGCastbar" }
    )
    CreateTooltip(customCastbarBGTextureDropdown, L["Tooltip_Background_Texture"])

    if not useCustomCastbarTexture:GetChecked() then
        customCastbarTextureDropdown:Disable()
        customCastbarNonInterruptibleTextureDropdown:Disable()
        customCastbarBGTextureDropdown:Disable()
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
    castBarBackgroundColorIcon:SetAtlas("CircleMaskScalable")
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
            customCastbarNonInterruptibleTextureDropdown:Enable()
            useCustomCastbarBGTexture:Enable()
            useCustomCastbarBGTexture:SetAlpha(1)
            if BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                castBarBackgroundColor:Enable()
                castBarBackgroundColor:SetAlpha(1)
                castBarBackgroundColorIcon:SetAlpha(1)
                customCastbarBGTextureDropdown:Enable()
            end
        else
            customCastbarTextureDropdown:Disable()
            customCastbarNonInterruptibleTextureDropdown:Disable()
            customCastbarBGTextureDropdown:Disable()
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

    local normalCastbarForEmpoweredCasts = CreateCheckbox("normalCastbarForEmpoweredCasts", L["Normal_Empowered_Cast"], enableCastbarCustomization)
    normalCastbarForEmpoweredCasts:SetPoint("LEFT", interruptedByIndicator.text, "RIGHT", -1, 0)
    CreateTooltip(normalCastbarForEmpoweredCasts, L["Tooltip_Instead_Of_The_Jank_Tiered_Castbar"], "ANCHOR_LEFT")
    normalCastbarForEmpoweredCasts:HookScript("OnClick", function(self)
        if BetterBlizzFramesDB then
            if self:GetChecked() then
                BetterBlizzFramesDB.normalCastbarForEmpoweredCasts = true
            else
                BetterBlizzFramesDB.normalCastbarForEmpoweredCasts = false
            end
        end
    end)

    local hideCastbarText = CreateCheckbox("hideCastbarText", L["Hide_Castbar_Text"], enableCastbarCustomization)
    hideCastbarText:SetPoint("TOPLEFT", normalCastbarForEmpoweredCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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
    castBarRecolorInterrupt:SetPoint("TOPLEFT", interruptedByIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarRecolorInterrupt, L["Tooltip_Checks_If_You_Have_Interrupt_Ready"])

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText(L["Kick_On_Cd"])
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", -15, 3)
    castBarNoInterruptColor:SetSize(95, 20)
    CreateTooltip(castBarNoInterruptColor, L["Tooltip_Interrupt_On_CD"])
    local castBarNoInterruptColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarNoInterruptColorIcon:SetAtlas("CircleMaskScalable")
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
    castBarDelayedInterruptColorIcon:SetAtlas("CircleMaskScalable")
    castBarDelayedInterruptColorIcon:SetSize(18, 17)
    castBarDelayedInterruptColorIcon:SetPoint("LEFT", castBarDelayedInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarDelayedInterruptColorIcon, unpack(BetterBlizzPlatesDB["castBarDelayedInterruptColor"] or {1, 1, 1}))
    castBarDelayedInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarDelayedInterruptColor", castBarDelayedInterruptColorIcon)
    end)

    local castbarEmphasisSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarEmphasisSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -280, -430)
    castbarEmphasisSettingsText:SetText(L["Castbar_Emphasis_Settings"])
    castbarEmphasisSettingsText:SetFont(fontLarge, 16)
    castbarEmphasisSettingsText:SetTextColor(1,1,1)
    local castbarSettingsEmphasisIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsEmphasisIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsEmphasisIcon:SetSize(36, 36)
    castbarSettingsEmphasisIcon:SetVertexColor(1,0,0)
    castbarSettingsEmphasisIcon:SetPoint("RIGHT", castbarEmphasisSettingsText, "LEFT", 5, 0)

    local enableCastbarEmphasis = CreateCheckbox("enableCastbarEmphasis", L["Cast_Emphasis"], enableCastbarCustomization)
    enableCastbarEmphasis:SetPoint("TOPLEFT", castbarEmphasisSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)
    enableCastbarEmphasis:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarEmphasis)
        if self:GetChecked() then
            listFrame:SetAlpha(1)
        else
            listFrame:SetAlpha(0.5)
        end
    end)
    CreateTooltipTwo(enableCastbarEmphasis, L["Castbar_Emphasis"], L["Tooltip_Castbar_Emphasis_Desc"])

    local castBarEmphasisOnlyInterruptable = CreateCheckbox("castBarEmphasisOnlyInterruptable", L["Interruptable_Cast_Only"], enableCastbarEmphasis)
    castBarEmphasisOnlyInterruptable:SetPoint("LEFT", enableCastbarEmphasis.text, "RIGHT", 0, 0)
    CreateTooltip(castBarEmphasisOnlyInterruptable, L["Tooltip_Only_Apply_Emphasis_Settings_If_The"])

    local castBarEmphasisHealthbarColor = CreateCheckbox("castBarEmphasisHealthbarColor", L["Color_Healthbar"], enableCastbarEmphasis)
    castBarEmphasisHealthbarColor:SetPoint("TOPLEFT", enableCastbarEmphasis, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(castBarEmphasisHealthbarColor, L["Tooltip_Color_The_Healthbar_The_Color_Youve"])

    local castBarEmphasisColor = CreateCheckbox("castBarEmphasisColor", L["Color_Castbar"], enableCastbarEmphasis)
    castBarEmphasisColor:SetPoint("LEFT", castBarEmphasisHealthbarColor.text, "RIGHT", 0, 0)
    CreateTooltip(castBarEmphasisColor, L["Tooltip_Color_The_Castbar_The_Color_Youve"])

    local castBarEmphasisSelfColor = CreateCheckbox("castBarEmphasisSelfColor", L["Self_Color"], enableCastbarEmphasis)
    castBarEmphasisSelfColor:SetPoint("LEFT", castBarEmphasisColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(castBarEmphasisSelfColor, L["Self_Color"], L["Tooltip_Self_Color_Desc"], L["Tooltip_Only_On_Me_SubText"])
    castBarEmphasisSelfColor:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.castBarEmphasisSelfColorRGB, BBP.RefreshAllNameplates)
        end
    end)

    local castBarEmphasisHeight = CreateCheckbox("castBarEmphasisHeight", L["Height"], enableCastbarEmphasis)
    castBarEmphasisHeight:SetPoint("TOPLEFT", castBarEmphasisHealthbarColor, "BOTTOMLEFT", 0, -2)

    local castBarEmphasisIcon = CreateCheckbox("castBarEmphasisIcon", L["Icon_Size"], enableCastbarEmphasis)
    castBarEmphasisIcon:SetPoint("TOPLEFT", castBarEmphasisHeight, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)

    local castBarEmphasisText = CreateCheckbox("castBarEmphasisText", L["Text_Size"], enableCastbarEmphasis)
    castBarEmphasisText:SetPoint("TOPLEFT", castBarEmphasisIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)

    local castBarEmphasisSpark = CreateCheckbox("castBarEmphasisSpark", L["Spark"], enableCastbarEmphasis)
    castBarEmphasisSpark:SetPoint("TOPLEFT", castBarEmphasisText, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)
    CreateTooltip(castBarEmphasisSpark, L["Tooltip_Spark_Is_The_Little_Texture_At"])

    local castBarEmphasisHeightValue = CreateSlider(enableCastbarEmphasis, L["Emphasis_Height"], 4, 40, 0.1, "castBarEmphasisHeightValue", "Height")
    castBarEmphasisHeightValue:SetPoint("LEFT", castBarEmphasisHeight, "RIGHT", 50, -1)

    local castBarEmphasisIconScale = CreateSlider(enableCastbarEmphasis, L["Emphasis_Icon_Size"], 1, 3, 0.1, "castBarEmphasisIconScale")
    castBarEmphasisIconScale:SetPoint("LEFT", castBarEmphasisIcon, "RIGHT", 50, -1)

    local castBarEmphasisTextScale = CreateSlider(enableCastbarEmphasis, L["Emphasis_Text_Size"], 0.5, 2.5, 0.1, "castBarEmphasisTextScale")
    castBarEmphasisTextScale:SetPoint("LEFT", castBarEmphasisText, "RIGHT", 50, -1)

    local castBarEmphasisSparkHeight = CreateSlider(enableCastbarEmphasis, L["Emphasis_Spark_Size"], 25, 60, 1, "castBarEmphasisSparkHeight", "Height")
    castBarEmphasisSparkHeight:SetPoint("LEFT", castBarEmphasisSpark, "RIGHT", 50, -1)

    local castBarInterruptHighlighterText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castBarInterruptHighlighterText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -610, -485)
    castBarInterruptHighlighterText:SetText(L["Label_Castbar_Edge_Highlight_Settings"])

    local castBarInterruptHighlighter = CreateCheckbox("castBarInterruptHighlighter", L["Castbar_Edge_Highlight"], enableCastbarCustomization)
    castBarInterruptHighlighter:SetPoint("TOPLEFT", castBarInterruptHighlighterText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(castBarInterruptHighlighter, L["Castbar_Highlight"], L["Tooltip_Castbar_Highlight_Desc"])
    castBarInterruptHighlighter:HookScript("OnClick", function(self)
        BBP.ToggleSpellCastEventRegistration()
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local castBarInterruptHighlighterColorDontInterrupt = CreateCheckbox("castBarInterruptHighlighterColorDontInterrupt", L["Recolor_Between_Portion"], castBarInterruptHighlighter)
    castBarInterruptHighlighterColorDontInterrupt:SetPoint("TOPLEFT", castBarInterruptHighlighter, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptHighlighterColorDontInterrupt, L["Color_Inbetween"], L["Tooltip_Color_Inbetween_Desc"])

    local castBarInterruptHighlighterDontInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighterColorDontInterrupt, "UIPanelButtonTemplate")
    castBarInterruptHighlighterDontInterruptRGB:SetText(L["Color"])
    castBarInterruptHighlighterDontInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterColorDontInterrupt.text, "RIGHT", 0, 0)
    castBarInterruptHighlighterDontInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterDontInterruptRGB, L["Tooltip_Castbar_Color_Inbetween_The_Start_And"])
    local castBarInterruptHighlighterDontInterruptRGBIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetAtlas("CircleMaskScalable")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterDontInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterDontInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterDontInterruptRGBIcon, unpack(BetterBlizzPlatesDB["castBarInterruptHighlighterDontInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterDontInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterDontInterruptRGB", castBarInterruptHighlighterDontInterruptRGBIcon)
    end)

    local castBarInterruptHighlighterStartTime = CreateSlider(castBarInterruptHighlighter, L["Start_Seconds"], 0, 2, 0.01, "castBarInterruptHighlighterStartTime", "Height")
    castBarInterruptHighlighterStartTime:SetPoint("TOPLEFT", castBarInterruptHighlighterColorDontInterrupt, "BOTTOMLEFT", 10, -6)
    CreateTooltip(castBarInterruptHighlighterStartTime, L["Tooltip_Interrupt_Highlighter_Start"])

    local castBarInterruptHighlighterEndTime = CreateSlider(castBarInterruptHighlighter, L["End_Seconds"], 0, 2, 0.01, "castBarInterruptHighlighterEndTime", "Height")
    castBarInterruptHighlighterEndTime:SetPoint("TOPLEFT", castBarInterruptHighlighterStartTime, "BOTTOMLEFT", 0, -10)
    CreateTooltip(castBarInterruptHighlighterEndTime, L["Tooltip_Interrupt_Highlighter_End"])

    local castBarInterruptHighlighterInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighter, "UIPanelButtonTemplate")
    castBarInterruptHighlighterInterruptRGB:SetText(L["Color"])
    castBarInterruptHighlighterInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterEndTime, "RIGHT", 0, 15)
    castBarInterruptHighlighterInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterInterruptRGB, L["Tooltip_Castbar_Edge_Color"])
    local castBarInterruptHighlighterInterruptRGBIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterInterruptRGBIcon:SetAtlas("CircleMaskScalable")
    castBarInterruptHighlighterInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterInterruptRGBIcon, unpack(BetterBlizzPlatesDB["castBarInterruptHighlighterInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterInterruptRGB", castBarInterruptHighlighterInterruptRGBIcon)
    end)

    CheckAndToggleCheckboxes(castBarInterruptHighlighter)
    if not BetterBlizzPlatesDB.castBarInterruptHighlighter then
        castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(0)
    end

    enableCastbarCustomization:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarCustomization)
        if self:GetChecked() then
            if BetterBlizzPlatesDB.enableCastbarEmphasis then
                listFrame:SetAlpha(1)
            end
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
            listFrame:SetAlpha(0.5)
            castBarCastColorIcon:SetAlpha(0)
            castBarChanneledColorIcon:SetAlpha(0)
            castBarNoInterruptColorIcon:SetAlpha(0)
            castBarDelayedInterruptColorIcon:SetAlpha(0)
            castBarBackgroundColor:SetAlpha(0)
            castBarBackgroundColorIcon:SetAlpha(0)
        end
    end)

    castBarInterruptHighlighter:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(castBarInterruptHighlighter)
        if self:GetChecked() then
            if BetterBlizzPlatesDB.castBarInterruptHighlighterColorDontInterrupt then
                castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
            end
            castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(1)
        else
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
            castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(0)
        end
    end)

    castBarInterruptHighlighterColorDontInterrupt:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(castBarInterruptHighlighter)
        if self:GetChecked() then
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
        else
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
        end
    end)

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
            castBarBackgroundColor:Enable()
            castBarBackgroundColor:SetAlpha(1)
            castBarBackgroundColorIcon:SetAlpha(1)
        else
            customCastbarBGTextureDropdown:Disable()
            castBarBackgroundColor:Disable()
            castBarBackgroundColor:SetAlpha(0)
            castBarBackgroundColorIcon:SetAlpha(0)
        end
    end)

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.enableCastbarEmphasis then
                listFrame:SetAlpha(1)
            else
                listFrame:SetAlpha(0.5)
            end
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
                castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
                castBarInterruptHighlighterDontInterruptRGB:Disable()
            end
        else
            C_Timer.After(1, function()
                TogglePanel()
            end)
        end
    end
    TogglePanel()
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
    hideCastbarExplanationText:SetText(L["Hide_The_Castbar_For_Chosen_Spells_Or_Only"])

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

    local hidePetCastbars = CreateCheckbox("hidePetCastbars", L["Hide_All_Pet_Castbars"], hideCastbar)
    hidePetCastbars:SetPoint("TOPLEFT", hideNpcCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePetCastbars, L["Hide_Pet_Castbars"], L["Hide_All_Pet_Castbars"])

    local hideCastbarFriendly = CreateCheckbox("hideCastbarFriendly", L["Hide_Friendly_Castbars"], hideCastbar)
    hideCastbarFriendly:SetPoint("TOPLEFT", hidePetCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarFriendly, L["Hide_Friendly_Castbars"], L["Tooltip_Hide_Friendly_Castbars_2_Desc_2"])

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
    --InterfaceOptions_AddCategory(guiFadeNpc)
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

    local fadeAllButTarget = CreateCheckbox("fadeAllButTarget", L["Fade_All_Except_Target"], fadeOutNPC)
    fadeAllButTarget:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(fadeAllButTarget, L["Tooltip_Fade_Out_All_Other_Nameplates_When"])

    local fadeNPCPvPOnly = CreateCheckbox("fadeNPCPvPOnly", L["Only_Fade_NPCs_In_PvP"], fadeOutNPC)
    fadeNPCPvPOnly:SetPoint("TOPLEFT", fadeAllButTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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

    local listFrame = CreateFrame("Frame", nil, guiColorNpc)
    listFrame:SetAllPoints(guiColorNpc)

    CreateList(listFrame, "colorNpcList", BetterBlizzPlatesDB.colorNpcList, BBP.RefreshAllNameplates, true)

    local listExplanationText = guiColorNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listExplanationText:SetPoint("TOP", guiColorNpc, "BOTTOMLEFT", 180, 155)
    listExplanationText:SetText(L["Add_Name_Or_NpcID_Case_Insensitive_Add_A"])

    local colorNpcExplanationText = guiColorNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorNpcExplanationText:SetPoint("TOP", guiColorNpc, "TOP", 172, -127)
    colorNpcExplanationText:SetText(L["This_Colors_Specific_Nameplates_Add_A_Name_Npc"])

    local colorNPC = CreateCheckbox("colorNPC", L["Enable_NPC_Color"], guiColorNpc, nil, BBP.colorNPC)
    colorNPC:SetPoint("TOPLEFT", colorNpcExplanationText, "BOTTOMLEFT", 25, -15)
    CreateTooltip(colorNPC, L["Tooltip_Color_NPCs_From_The_List_A"])

    local colorNPCName = CreateCheckbox("colorNPCName", L["Also_Color_Name_Text"], colorNPC, nil, BBP.colorNPC)
    colorNPCName:SetPoint("TOPLEFT", colorNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local reloadUiButton = CreateFrame("Button", nil, guiColorNpc, "UIPanelButtonTemplate")
    reloadUiButton:SetText(L["Reload_UI"])
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiColorNpc, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.colorNPC then
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
    colorNPC:HookScript("OnClick", function ()
        TogglePanel()
        CheckAndToggleCheckboxes(colorNPC)
    end)
    TogglePanel()
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

    CreateList(listFrame, "auraColorList", BetterBlizzPlatesDB.auraColorList, BBP.RefreshAllNameplates, true, false, true, 410)

    local listExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listExplanationText:SetPoint("TOP", guiAuraColor, "BOTTOMLEFT", 180, 155)
    listExplanationText:SetText(L["Add_Name_Or_Spell_ID_Case_Insensitive_Type"])

    local auraColorExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    auraColorExplanationText:SetPoint("TOP", guiAuraColor, "TOP", 210, -127)
    auraColorExplanationText:SetText(L["Color_Nameplates_Depending_On_Their_Auras_Add_A_2"])

    local auraColor = CreateCheckbox("auraColor", L["Enable_Color_By_Aura"], guiAuraColor, nil, BBP.CreateUnitAuraEventFrame)
    auraColor:SetPoint("TOPLEFT", auraColorExplanationText, "BOTTOMLEFT", 30, -15)
    CreateTooltip(auraColor, L["Tooltip_Chose_Nameplate_Color_Depending_On_The"])

    local auraColorPvEOnly = CreateCheckbox("auraColorPvEOnly", L["Enable_In_PvE_Only"], auraColor)
    auraColorPvEOnly:SetPoint("TOPLEFT", auraColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

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
    --InterfaceOptions_AddCategory(guiNameplateAuras)
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
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, 390)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, -15)

    local auraBlacklistFrame = CreateFrame("Frame", nil, contentFrame)
    auraBlacklistFrame:SetSize(322, 390)
    auraBlacklistFrame:SetPoint("TOPLEFT", 6, -15)

    local blacklist = CreateList(auraBlacklistFrame, "auraBlacklist", BetterBlizzPlatesDB.auraBlacklist, BBP.RefreshAllNameplates, nil, nil, nil, 265, 270)

    local blacklistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistText:SetPoint("BOTTOM", auraBlacklistFrame, "TOP", 10, -5)
    blacklistText:SetText(L["Blacklist"])
    blacklistText:SetFont(fontLarge, 16)
    blacklistText:SetTextColor(1,1,1)

    local whitelist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzPlatesDB.auraWhitelist, BBP.RefreshAllNameplates, nil, true, nil, 379, 270, true, true)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -60, -5)
    whitelistText:SetText(L["Whitelist"])
    whitelistText:SetFont(fontLarge, 16)
    whitelistText:SetTextColor(1,1,1)

    local onlyMeTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    onlyMeTexture:SetTexture(BBP.OwnAuraIcon)
    onlyMeTexture:SetPoint("RIGHT", whitelist, "TOPRIGHT", -101, 9)
    onlyMeTexture:SetSize(18,20)
    CreateTooltip(onlyMeTexture, L["Only_My_Aura_Checkboxes"])

    local enlargeAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    enlargeAuraTexture:SetTexture(BBP.EnlargedIcon)
    enlargeAuraTexture:SetPoint("LEFT", onlyMeTexture, "RIGHT", 4, 0)
    enlargeAuraTexture:SetSize(18,18)
    CreateTooltip(enlargeAuraTexture, L["Tooltip_Enlarged_Aura_Checkboxes"])

    local compactAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    compactAuraTexture:SetTexture(BBP.CompactIcon)
    compactAuraTexture:SetPoint("LEFT", enlargeAuraTexture, "RIGHT", 3, 0)
    compactAuraTexture:SetSize(18,18)
    CreateTooltip(compactAuraTexture, L["Tooltip_Compact_Aura_Checkboxes"])

    local importantAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    importantAuraTexture:SetTexture(BBP.ImportantIcon)
    importantAuraTexture:SetPoint("LEFT", compactAuraTexture, "RIGHT", 2, 0)
    importantAuraTexture:SetSize(17,16)
    importantAuraTexture:SetDesaturated(true)
    importantAuraTexture:SetVertexColor(0,1,0)
    CreateTooltip(importantAuraTexture, L["Important_Aura_Checkboxes"])

    local pandemicAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    pandemicAuraTexture:SetTexture(BBP.PandemicIcon)
    pandemicAuraTexture:SetPoint("LEFT", importantAuraTexture, "RIGHT", 0, 1)
    pandemicAuraTexture:SetSize(26,26)
    pandemicAuraTexture:SetDesaturated(true)
    pandemicAuraTexture:SetVertexColor(1,0,0)
    CreateTooltip(pandemicAuraTexture, L["Pandemic_Aura_Checkboxes"])

    local enableNameplateAuraCustomisation = CreateCheckbox("enableNameplateAuraCustomisation", L["Enable_Aura_Settings"], contentFrame)
    enableNameplateAuraCustomisation:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 195)
    CreateTooltip(enableNameplateAuraCustomisation, L["Tooltip_Enable_All_Aura_Settings_Like_Filters"])

    --------------------------
    -- Enemy Nameplates
    --------------------------
    -- Enemy Buffs
    local otherNpBuffEnable = CreateCheckbox("otherNpBuffEnable", L["Show_Buffs"], enableNameplateAuraCustomisation)
    otherNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 145)
    otherNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(otherNpBuffEnable)
    end)
    CreateTooltip(otherNpBuffEnable, L["Tooltip_Enable_All_Buffs_Select_Filters_Under"])

    local bigEnemyBorderText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText:SetPoint("LEFT", otherNpBuffEnable, "CENTER", 0, 25)
    bigEnemyBorderText:SetText(L["Enemy_Nameplates"])
    bigEnemyBorderText:SetFont(fontLarge, 16)
    bigEnemyBorderText:SetTextColor(1,1,1)
    local friendlyNameplatesIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    friendlyNameplatesIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplatesIcon:SetSize(28, 28)
    friendlyNameplatesIcon:SetPoint("RIGHT", bigEnemyBorderText, "LEFT", -3, 0)
    friendlyNameplatesIcon:SetDesaturated(1)
    friendlyNameplatesIcon:SetVertexColor(1, 0, 0)

    local otherNpBuffFilterBlacklist = CreateCheckbox("otherNpBuffFilterBlacklist", L["Blacklist"], otherNpBuffEnable)
    otherNpBuffFilterBlacklist:SetPoint("TOPLEFT", otherNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffFilterBlacklist, L["Tooltip_Hide_Blacklisted_Buffs"])

    local otherNpBuffFilterWatchList = CreateCheckbox("otherNpBuffFilterWatchList", L["Whitelist"], otherNpBuffEnable)
    otherNpBuffFilterWatchList:SetPoint("TOPLEFT", otherNpBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(otherNpBuffFilterWatchList, L["Whitelist"], L["Tooltip_Only_Whitelisted_Buffs"], L["Tooltip_Whitelist_Desc"])

    local otherNpBuffFilterImportantBuffs = CreateCheckbox("otherNpBuffFilterImportantBuffs", L["PvP_Buffs"], otherNpBuffEnable)
    otherNpBuffFilterImportantBuffs:SetPoint("LEFT", otherNpBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(otherNpBuffFilterImportantBuffs, L["Show_Important_Buffs"], L["Tooltip_Show_Important_Buffs_Desc"])
    otherNpBuffFilterImportantBuffs:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local otherNpBuffFilterLessMinite = CreateCheckbox("otherNpBuffFilterLessMinite", L["Under_One_Min"], otherNpBuffEnable)
    otherNpBuffFilterLessMinite:SetPoint("TOPLEFT", otherNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffFilterLessMinite, L["Tooltip_Only_Show_Buffs_Under_One_Minute"])

    local otherNpBuffFilterPurgeable = CreateCheckbox("otherNpBuffFilterPurgeable", L["Purgeable"], otherNpBuffEnable)
    otherNpBuffFilterPurgeable:SetPoint("TOPLEFT", otherNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(otherNpBuffFilterPurgeable, L["Purgeable"], L["Tooltip_Purgeable_Desc"])
    otherNpBuffFilterPurgeable:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then 
                if BetterBlizzPlatesDB.otherNpBuffFilterPurgeableHasPurge == nil then
                    if not otherNpBuffFilterPurgeable:GetChecked() then
                        otherNpBuffFilterPurgeable:Click()
                        otherNpBuffFilterPurgeable:SetChecked(true)
                    end
                    BetterBlizzPlatesDB.otherNpBuffFilterPurgeableHasPurge = true
                else
                    BetterBlizzPlatesDB.otherNpBuffFilterPurgeableHasPurge = nil
                end
            else
                if BetterBlizzPlatesDB.otherNpBuffFilterPurgeablePvEOnly == nil then
                    if not otherNpBuffFilterPurgeable:GetChecked() then
                        otherNpBuffFilterPurgeable:Click()
                        otherNpBuffFilterPurgeable:SetChecked(true)
                    end
                    BetterBlizzPlatesDB.otherNpBuffFilterPurgeablePvEOnly = true
                else
                    BetterBlizzPlatesDB.otherNpBuffFilterPurgeablePvEOnly = nil
                end
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.RefreshBuffFrame()
        end
    end)

    local otherNpBuffPurgeGlow = CreateCheckbox("otherNpBuffPurgeGlow", L["Glow_On_Purgeable"], otherNpBuffEnable)
    otherNpBuffPurgeGlow:SetPoint("TOPLEFT", otherNpBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffPurgeGlow, L["Tooltip_Bright_Blue_Glow_On_Purgeable_Stealable"])

    local alwaysShowPurgeTexture = CreateCheckbox("alwaysShowPurgeTexture", L["Always"], otherNpBuffPurgeGlow)
    alwaysShowPurgeTexture:SetPoint("LEFT", otherNpBuffPurgeGlow.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(alwaysShowPurgeTexture, L["Always_Show"], L["Tooltip_Always_Show_2_Desc"])

    otherNpBuffPurgeGlow:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    -- local otherNpBuffBlueBorder = CreateCheckbox("otherNpBuffBlueBorder", "Blue border on buffs", otherNpBuffEnable)
    -- otherNpBuffBlueBorder:SetPoint("TOPLEFT", otherNpBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(otherNpBuffBlueBorder, "Replace the black border around buffs with a blue one (for buffs only)")

    -- Enemy Debuffs
    local otherNpdeBuffEnable = CreateCheckbox("otherNpdeBuffEnable", L["Show_DEBUFFS"], enableNameplateAuraCustomisation)
    otherNpdeBuffEnable:SetPoint("TOPLEFT", otherNpBuffPurgeGlow, "BOTTOMLEFT", -15, -2)
    otherNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(otherNpdeBuffEnable)
    end)
    CreateTooltip(otherNpdeBuffEnable, L["Tooltip_Enable_All_Debuffs_Select_Filters_Under"])

    local otherNpdeBuffFilterBlacklist = CreateCheckbox("otherNpdeBuffFilterBlacklist", L["Blacklist"], otherNpdeBuffEnable)
    otherNpdeBuffFilterBlacklist:SetPoint("TOPLEFT", otherNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterBlacklist, L["Tooltip_Hide_Blacklisted_Debuffs"])

    local otherNpdeBuffFilterWatchList = CreateCheckbox("otherNpdeBuffFilterWatchList", L["Whitelist"], otherNpdeBuffEnable)
    otherNpdeBuffFilterWatchList:SetPoint("TOPLEFT", otherNpdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(otherNpdeBuffFilterWatchList, L["Whitelist"], L["Tooltip_Only_Whitelisted_Buffs"], L["Tooltip_Whitelist_Desc"])

    local otherNpdeBuffFilterCC = CreateCheckbox("otherNpdeBuffFilterCC", L["PvP_CC"], otherNpdeBuffEnable)
    otherNpdeBuffFilterCC:SetPoint("LEFT", otherNpdeBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(otherNpdeBuffFilterCC, L["Show_Crowd_Control"], L["Tooltip_Show_Crowd_Control_Desc_2"])
    otherNpdeBuffFilterCC:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local otherNpdeBuffFilterBlizzard = CreateCheckbox("otherNpdeBuffFilterBlizzard", L["Blizzard_Default_Filter"], otherNpdeBuffEnable)
    otherNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", otherNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterBlizzard, L["Tooltip_Blizzard_Default_Filter_Desc"])

    local blizzardDefaultFilterOnlyMine = CreateCheckbox("blizzardDefaultFilterOnlyMine", L["BDF_Mine"], otherNpdeBuffFilterBlizzard)
    blizzardDefaultFilterOnlyMine:SetPoint("LEFT", otherNpdeBuffFilterBlizzard.text, "RIGHT", 0, 0)
    CreateTooltipTwo(blizzardDefaultFilterOnlyMine, L["Blizzard_Default_Filter_Mine_Only"], L["Tooltip_Blizzard_Default_Filter_Mine_Only_Desc"])

    if BBP.isTBC then
        DisableElement(otherNpdeBuffFilterBlizzard)
        DisableElement(otherNpdeBuffFilterBlizzard)
    end

    otherNpdeBuffFilterBlizzard:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    local otherNpdeBuffFilterLessMinite = CreateCheckbox("otherNpdeBuffFilterLessMinite", L["Under_One_Min"], otherNpdeBuffEnable)
    otherNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", otherNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterLessMinite, L["Tooltip_Only_Show_Debuffs_Under_One_Minute"])

    local otherNpdeBuffFilterOnlyMe = CreateCheckbox("otherNpdeBuffFilterOnlyMe", L["Only_Mine"], otherNpdeBuffEnable)
    otherNpdeBuffFilterOnlyMe:SetPoint("TOPLEFT", otherNpdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterOnlyMe, L["Tooltip_Only_Show_My_Debuffs_Can_Select"])

    if BBP.isTBC then
        local otherNpdeBuffFilterBreakCCDots = CreateCheckbox("otherNpdeBuffFilterBreakCCDots", L["Break_CC_DoTs"], otherNpdeBuffEnable)
        otherNpdeBuffFilterBreakCCDots:SetPoint("TOPLEFT", otherNpdeBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        CreateTooltipTwo(otherNpdeBuffFilterBreakCCDots, L["Break_CC_DoTs"], L["Tooltip_Break_CC_DoTs_Desc"])
    end

--[=[
    local otherNpdeBuffPandemicGlow = CreateCheckbox("otherNpdeBuffPandemicGlow", "Pandemic Glow", otherNpdeBuffEnable)
    otherNpdeBuffPandemicGlow:SetPoint("TOPLEFT", otherNpdeBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffPandemicGlow, "Red glow on whitelisted debuffs with less than 5 seconds left.")

]=]


    --------------------------
    -- Friendly Nameplates
    --------------------------
    -- Friendly Buffs
    local friendlyNpBuffEnable = CreateCheckbox("friendlyNpBuffEnable", L["Show_Buffs"], enableNameplateAuraCustomisation)
    friendlyNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 300, 170)
    friendlyNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(friendlyNpBuffEnable)
    end)
    CreateTooltip(friendlyNpBuffEnable, L["Tooltip_Enable_All_Buffs_Select_Filters_Under"])

    local friendlyNameplatesText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyNameplatesText:SetPoint("LEFT", friendlyNpBuffEnable, "CENTER", 0, 25)
    friendlyNameplatesText:SetText(L["Friendly_Nameplates"])
    friendlyNameplatesText:SetFont(fontLarge, 16)
    friendlyNameplatesText:SetTextColor(1,1,1)
    local friendlyNameplatesIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    friendlyNameplatesIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplatesIcon:SetSize(28, 28)
    friendlyNameplatesIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNpBuffFilterBlacklist = CreateCheckbox("friendlyNpBuffFilterBlacklist", L["Blacklist"], friendlyNpBuffEnable)
    friendlyNpBuffFilterBlacklist:SetPoint("TOPLEFT", friendlyNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpBuffFilterBlacklist, L["Tooltip_Hide_Blacklisted_Buffs"])

    local friendlyNpBuffFilterWatchList = CreateCheckbox("friendlyNpBuffFilterWatchList", L["Whitelist"], friendlyNpBuffEnable)
    CreateTooltipTwo(friendlyNpBuffFilterWatchList, L["Whitelist"], L["Tooltip_Only_Whitelisted_Buffs"], L["Tooltip_Whitelist_Desc"])
    friendlyNpBuffFilterWatchList:SetPoint("TOPLEFT", friendlyNpBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyNpBuffFilterImportantBuffs = CreateCheckbox("friendlyNpBuffFilterImportantBuffs", L["PvP_Buffs"], friendlyNpBuffEnable)
    friendlyNpBuffFilterImportantBuffs:SetPoint("LEFT", friendlyNpBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyNpBuffFilterImportantBuffs, L["Show_Important_Buffs"], L["Tooltip_Show_Important_Buffs_Desc"])
    friendlyNpBuffFilterImportantBuffs:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local friendlyNpBuffFilterLessMinite = CreateCheckbox("friendlyNpBuffFilterLessMinite", L["Under_One_Min"], friendlyNpBuffEnable)
    friendlyNpBuffFilterLessMinite:SetPoint("TOPLEFT", friendlyNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpBuffFilterLessMinite, L["Tooltip_Only_Show_Buffs_Under_One_Minute"])

    local friendlyNpBuffFilterOnlyMe = CreateCheckbox("friendlyNpBuffFilterOnlyMe", L["Only_Mine"], friendlyNpBuffEnable)
    friendlyNpBuffFilterOnlyMe:SetPoint("TOPLEFT", friendlyNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpBuffFilterOnlyMe, L["Tooltip_Only_Show_My_Buffs_Plus_Other"])

    -- Friendly Debuffs
    local friendlyNpdeBuffEnable = CreateCheckbox("friendlyNpdeBuffEnable", L["Show_DEBUFFS"], enableNameplateAuraCustomisation)
    friendlyNpdeBuffEnable:SetPoint("TOPLEFT", friendlyNpBuffFilterOnlyMe, "BOTTOMLEFT", -15, -2)
    friendlyNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(friendlyNpdeBuffEnable)
    end)
    CreateTooltip(friendlyNpdeBuffEnable, L["Tooltip_Enable_All_Debuffs_Select_Filters_Under"])
    BBP.friendlyNpdeBuffEnable = friendlyNpdeBuffEnable

    local friendlyNpdeBuffFilterBlacklist = CreateCheckbox("friendlyNpdeBuffFilterBlacklist", L["Blacklist"], friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterBlacklist:SetPoint("TOPLEFT", friendlyNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpdeBuffFilterBlacklist, L["Tooltip_Hide_Blacklisted_Debuffs"])

    local friendlyNpdeBuffFilterWatchList = CreateCheckbox("friendlyNpdeBuffFilterWatchList", L["Whitelist"], friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterWatchList:SetPoint("TOPLEFT", friendlyNpdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyNpdeBuffFilterWatchList, L["Whitelist"], L["Tooltip_Only_Whitelisted_Debuffs"], L["Tooltip_Whitelist_Desc"])

    local friendlyNpdeBuffFilterCC = CreateCheckbox("friendlyNpdeBuffFilterCC", L["PvP_CC"], friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterCC:SetPoint("LEFT", friendlyNpdeBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyNpdeBuffFilterCC, L["Show_Crowd_Control"], L["Tooltip_Show_Crowd_Control_Desc_2"])
    friendlyNpdeBuffFilterCC:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)
    BBP.friendlyNpdeBuffFilterCC = friendlyNpdeBuffFilterCC

    local friendlyNpdeBuffFilterBlizzard = CreateCheckbox("friendlyNpdeBuffFilterBlizzard", L["Blizzard_Default_Filter"], friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", friendlyNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpdeBuffFilterBlizzard, L["Tooltip_Blizzard_Default_Filter_Desc"])

    local friendlyNpdeBuffFilterLessMinite = CreateCheckbox("friendlyNpdeBuffFilterLessMinite", L["Under_One_Min"], friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", friendlyNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpdeBuffFilterLessMinite, L["Tooltip_Only_Show_Debuffs_Under_One_Minute_2"])

    --------------------------
    -- Personal Bar
    --------------------------
    -- Personal Bar Buffs
    local personalNpBuffEnable = CreateCheckbox("personalNpBuffEnable", L["Show_Buffs"], enableNameplateAuraCustomisation)
    personalNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 525, 170)
    personalNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(personalNpBuffEnable)
    end)
    CreateTooltip(personalNpBuffEnable, L["Tooltip_Enable_All_Buffs_Select_Filters_Under"], "ANCHOR_LEFT")

    local personalBarText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalBarText:SetPoint("LEFT", personalNpBuffEnable, "CENTER", 0, 25)
    personalBarText:SetText(L["Personal_Bar"])
    personalBarText:SetFont(fontLarge, 16)
    personalBarText:SetTextColor(1,1,1)
    local personalBarIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    personalBarIcon:SetAtlas("groupfinder-icon-friend")
    personalBarIcon:SetSize(28, 28)
    personalBarIcon:SetPoint("RIGHT", personalBarText, "LEFT", -3, 0)
    personalBarIcon:SetDesaturated(1)
    local playerClass = UnitClassBase("player")
    local classColor = BBP.GetClassColor(playerClass)
    if classColor then
        personalBarIcon:SetVertexColor(classColor.r, classColor.g, classColor.b)
    else
        personalBarIcon:SetVertexColor(1, 0.5, 0)
    end
    personalBarIcon:SetBlendMode("ADD")


    local hideDefaultPersonalNameplateAuras = CreateCheckbox("hideDefaultPersonalNameplateAuras", L["Hide_Default"], personalNpBuffEnable)
    hideDefaultPersonalNameplateAuras:SetPoint("LEFT", personalBarText, "RIGHT", 0, 0)
    CreateTooltip(hideDefaultPersonalNameplateAuras, L["Tooltip_Hide_Default_Personal_BuffFrame_I_Dont"], "ANCHOR_LEFT")

    local personalNpBuffFilterBlacklist = CreateCheckbox("personalNpBuffFilterBlacklist", L["Blacklist"], personalNpBuffEnable)
    personalNpBuffFilterBlacklist:SetPoint("TOPLEFT", personalNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterBlacklist, L["Tooltip_Hide_Blacklisted_Buffs"], "ANCHOR_LEFT")

    local personalNpBuffFilterWatchList = CreateCheckbox("personalNpBuffFilterWatchList", L["Whitelist"], personalNpBuffEnable)
    personalNpBuffFilterWatchList:SetPoint("TOPLEFT", personalNpBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(personalNpBuffFilterWatchList, L["Whitelist"], L["Tooltip_Only_Whitelisted_Buffs"], L["Tooltip_Whitelist_Desc"], "ANCHOR_LEFT")

    local personalNpBuffFilterImportantBuffs = CreateCheckbox("personalNpBuffFilterImportantBuffs", L["PvP_Buffs"], personalNpBuffEnable)
    personalNpBuffFilterImportantBuffs:SetPoint("LEFT", personalNpBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(personalNpBuffFilterImportantBuffs, L["Show_Important_Buffs"], L["Tooltip_Show_Important_Buffs_Desc"])
    personalNpBuffFilterImportantBuffs:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local personalNpBuffFilterBlizzard = CreateCheckbox("personalNpBuffFilterBlizzard", L["Blizzard_Default_Filter"], personalNpBuffEnable)
    personalNpBuffFilterBlizzard:SetPoint("TOPLEFT", personalNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterBlizzard, L["Tooltip_Only_Show_Buffs_That_Are_In"], "ANCHOR_LEFT")

    local personalNpBuffFilterLessMinite = CreateCheckbox("personalNpBuffFilterLessMinite", L["Under_One_Min"], personalNpBuffEnable)
    personalNpBuffFilterLessMinite:SetPoint("TOPLEFT", personalNpBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterLessMinite, L["Tooltip_Only_Show_Buffs_Under_One_Minute"], "ANCHOR_LEFT")

    local personalNpBuffFilterOnlyMe = CreateCheckbox("personalNpBuffFilterOnlyMe", L["Only_Mine"], personalNpBuffEnable)
    personalNpBuffFilterOnlyMe:SetPoint("TOPLEFT", personalNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterOnlyMe, L["Tooltip_Only_Show_My_Buffs_Can_Select"], "ANCHOR_LEFT")

    -- Personal Bar Debuffs
    local personalNpdeBuffEnable = CreateCheckbox("personalNpdeBuffEnable", L["Show_DEBUFFS"], enableNameplateAuraCustomisation)
    personalNpdeBuffEnable:SetPoint("TOPLEFT", personalNpBuffFilterOnlyMe, "BOTTOMLEFT", -15, -2)
    personalNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(personalNpdeBuffEnable)
    end)
    CreateTooltip(personalNpdeBuffEnable, L["Tooltip_Enable_All_Debuffs_Select_Filters_Under"], "ANCHOR_LEFT")

    local personalNpdeBuffFilterBlacklist = CreateCheckbox("personalNpdeBuffFilterBlacklist", L["Blacklist"], personalNpdeBuffEnable)
    personalNpdeBuffFilterBlacklist:SetPoint("TOPLEFT", personalNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(personalNpdeBuffFilterBlacklist, L["Tooltip_Hide_Blacklisted_Debuffs"], "ANCHOR_LEFT")

    local personalNpdeBuffFilterWatchList = CreateCheckbox("personalNpdeBuffFilterWatchList", L["Whitelist"], personalNpdeBuffEnable)
    personalNpdeBuffFilterWatchList:SetPoint("TOPLEFT", personalNpdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(personalNpdeBuffFilterWatchList, L["Whitelist"], L["Tooltip_Only_Whitelisted_Debuffs"], L["Tooltip_Whitelist_Desc"],  "ANCHOR_LEFT")

    local personalNpdeBuffFilterCC = CreateCheckbox("personalNpdeBuffFilterCC", L["PvP_CC"], personalNpdeBuffEnable)
    personalNpdeBuffFilterCC:SetPoint("LEFT", personalNpdeBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(personalNpdeBuffFilterCC, L["Show_Crowd_Control"], L["Tooltip_Show_Crowd_Control_Desc_2"])
    personalNpdeBuffFilterCC:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local ccOptionsFrame

    local function OpenCCSettingsWindow(cb)
        if not ccOptionsFrame then
            -- Create a new frame if it doesn't exist
            ccOptionsFrame = CreateFrame("Frame", nil, guiNameplateAuras, "BasicFrameTemplateWithInset")
            ccOptionsFrame:SetSize(210, 130)
            ccOptionsFrame:SetPoint("CENTER")
            ccOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            ccOptionsFrame:SetFrameLevel(550)
            KeepPopupInSettings(ccOptionsFrame, guiNameplateAuras)
            ccOptionsFrame:SetMovable(true)
            ccOptionsFrame:EnableMouse(true)
            ccOptionsFrame:RegisterForDrag("LeftButton")
            ccOptionsFrame:SetScript("OnDragStart", ccOptionsFrame.StartMoving)
            ccOptionsFrame:SetScript("OnDragStop", ccOptionsFrame.StopMovingOrSizing)

            -- Title
            ccOptionsFrame.title = ccOptionsFrame:CreateFontString(nil, "OVERLAY")
            ccOptionsFrame.title:SetFontObject("GameFontHighlight")
            ccOptionsFrame.title:SetPoint("LEFT", ccOptionsFrame.TitleBg, "LEFT", 5, 0)
            ccOptionsFrame.title:SetText(L["PvP_CC_All_Units"])


            local function OpenColorPicker(colorTbl, cb)
                local colorData = BetterBlizzPlatesDB[colorTbl] or {}
                local r, g, b = colorData.r or 1, colorData.g or 1, colorData.b or 1
                local a = colorData.a or 1 -- Default alpha to 1 if not present

                local backupColorData = {r = r, g = g, b = b, a = a}

                local function updateColors()
                    BetterBlizzPlatesDB[colorTbl].r, BetterBlizzPlatesDB[colorTbl].g, BetterBlizzPlatesDB[colorTbl].b, BetterBlizzPlatesDB[colorTbl].a = r, g, b, a
                    cb.texture:SetVertexColor(r, g, b, 1)
                    cb.Text:SetTextColor(r, g, b, 1)
                    BBP.RefreshAllNameplates()
                    if ColorPickerFrame.Content then
                        ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
                    end
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    updateColors()
                end

                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha()
                    updateColors()
                end

                local function cancelFunc()
                    r, g, b, a = backupColorData.r, backupColorData.g, backupColorData.b, backupColorData.a
                    updateColors()
                end

                ColorPickerFrame.previousValues = {r, g, b, a}
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r, g = g, b = b, opacity = a, hasOpacity = true,
                    swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
                })
            end

            local glowCCCheckboxes = {}

            -- First Loop: Glow Checkboxes
            local glowCCFilters = {
                { label = L["Glow_Full"], var = "importantCCFullGlow", tt = L["Full_CC_Auras"], colorTbl = "importantCCFullGlowRGB", linkedVar = "importantCCFull" },
                { label = L["Glow_Disarm"], var = "importantCCDisarmGlow", tt = L["Disarm_CC_Auras"], colorTbl = "importantCCDisarmGlowRGB", linkedVar = "importantCCDisarm" },
                { label = L["Glow_Root"], var = "importantCCRootGlow", tt = L["Root_CC_Auras"], colorTbl = "importantCCRootGlowRGB", linkedVar = "importantCCRoot" },
                { label = L["Glow_Silence"], var = "importantCCSilenceGlow", tt = L["Silence_CC_Auras"], colorTbl = "importantCCSilenceGlowRGB", linkedVar = "importantCCSilence" },
            }

            local previousGlowCheckbox
            for i, ccFilter in ipairs(glowCCFilters) do
                local glowCheckbox = CreateFrame("CheckButton", nil, ccOptionsFrame, "UICheckButtonTemplate")
                glowCheckbox:SetSize(24, 24)
                glowCheckbox.Text:SetText(ccFilter.label)

                -- Positioning
                if i == 1 then
                    glowCheckbox:SetPoint("TOPLEFT", ccOptionsFrame, "TOPLEFT", 95, -30)
                else
                    glowCheckbox:SetPoint("TOPLEFT", previousGlowCheckbox, "BOTTOMLEFT", 0, 3)
                end

                -- Set initial state from DB
                glowCheckbox:SetChecked(BetterBlizzPlatesDB[ccFilter.var])

                -- Save state when toggled
                glowCheckbox:SetScript("OnClick", function(self)
                    BetterBlizzPlatesDB[ccFilter.var] = self:GetChecked()
                    local color = BetterBlizzPlatesDB[ccFilter.colorTbl]
                    glowCheckbox.texture:SetVertexColor(color.r, color.g, color.b, BetterBlizzPlatesDB[ccFilter.var] and 1 or 0)
                    if BetterBlizzPlatesDB[ccFilter.var] then
                        glowCheckbox.Text:SetTextColor(color.r, color.g, color.b, 1)
                    else
                        glowCheckbox.Text:SetTextColor(1, 0.819607, 0, 1)
                    end
                    BBP.UpdateImportantBuffsAndCCTables()
                    BBP.RefreshAllNameplates()
                end)

                -- Create texture for color indication
                glowCheckbox.texture = glowCheckbox:CreateTexture(nil, "ARTWORK", nil, 1)
                glowCheckbox.texture:SetAtlas("newplayertutorial-drag-slotgreen")
                glowCheckbox.texture:SetSize(27, 27)
                glowCheckbox.texture:SetDesaturated(true)
                glowCheckbox.texture:SetPoint("CENTER", glowCheckbox, "CENTER", -0.5, 0.5)

                -- Tooltip
                CreateTooltipTwo(glowCheckbox, L["Important_Glow"] .. " |T"..BBP.ImportantIcon..":22:22:0:0|t", string.format(L["Tooltip_Glow_On_All"], ccFilter.tt) .. "\n\n|cff32f795" .. L["Right_Click_To_Change_Color"] .. "|r", L["Tooltip_Auras_That_Are_In_The_Whitelist_SubText"], "ANCHOR_TOPRIGHT")

                -- Set initial color
                local color = BetterBlizzPlatesDB[ccFilter.colorTbl]
                glowCheckbox.texture:SetVertexColor(color.r, color.g, color.b, BetterBlizzPlatesDB[ccFilter.var] and 1 or 0)
                if BetterBlizzPlatesDB[ccFilter.var] then
                    glowCheckbox.Text:SetTextColor(color.r, color.g, color.b, 1)
                else
                    glowCheckbox.Text:SetTextColor(1, 0.819607, 0, 1)
                end

                -- Right-click opens color picker
                glowCheckbox:HookScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        OpenColorPicker(ccFilter.colorTbl, self)
                    end
                end)

                -- Store reference to the checkbox for later enabling/disabling
                glowCCCheckboxes[ccFilter.linkedVar] = glowCheckbox

                previousGlowCheckbox = glowCheckbox
            end

            -- Second Loop: Important CC Checkboxes (Enable/Disable Glow Checkboxes)
            local importantCCFilters = {
                { label = L["CC_Full"], var = "importantCCFull", tt = L["Show_Full_CC_Auras"] },
                { label = L["CC_Disarm"], var = "importantCCDisarm", tt = L["Show_Disarm_CC_Auras"] },
                { label = L["CC_Root"], var = "importantCCRoot", tt = L["Show_Root_CC_Auras"] },
                { label = L["CC_Silence"], var = "importantCCSilence", tt = L["Show_Silence_CC_Auras"] },
            }

            local previousImportantCheckbox
            for i, ccFilter in ipairs(importantCCFilters) do
                local importantCheckbox = CreateFrame("CheckButton", nil, ccOptionsFrame, "UICheckButtonTemplate")
                importantCheckbox:SetSize(24, 24)
                importantCheckbox.Text:SetText(ccFilter.label)

                -- Positioning
                if i == 1 then
                    importantCheckbox:SetPoint("TOPLEFT", ccOptionsFrame, "TOPLEFT", 10, -30)
                else
                    importantCheckbox:SetPoint("TOPLEFT", previousImportantCheckbox, "BOTTOMLEFT", 0, 3)
                end

                -- Set initial state from DB
                importantCheckbox:SetChecked(BetterBlizzPlatesDB[ccFilter.var])

                -- Enable/Disable Glow Checkboxes based on initial state
                local linkedGlowCheckbox = glowCCCheckboxes[ccFilter.var]
                if linkedGlowCheckbox then
                    local isChecked = BetterBlizzPlatesDB[ccFilter.var] or false
                    linkedGlowCheckbox:SetEnabled(isChecked)
                    linkedGlowCheckbox:SetAlpha(isChecked and 1 or 0.5) -- Dim if disabled
                end

                -- Save state when toggled + Enable/Disable Glow Checkboxes
                importantCheckbox:SetScript("OnClick", function(self)
                    local isChecked = self:GetChecked()
                    BetterBlizzPlatesDB[ccFilter.var] = isChecked
                    BBP.UpdateImportantBuffsAndCCTables()

                    -- Enable or disable the corresponding glow checkbox
                    local linkedGlowCheckbox = glowCCCheckboxes[ccFilter.var]
                    if linkedGlowCheckbox then
                        linkedGlowCheckbox:SetEnabled(isChecked)
                        linkedGlowCheckbox:SetAlpha(isChecked and 1 or 0.5) -- Dim it if disabled
                    end
                end)

                -- Tooltip
                CreateTooltipTwo(importantCheckbox, ccFilter.tt)

                -- Store reference
                previousImportantCheckbox = importantCheckbox
            end

            ccOptionsFrame:Show()
        else
            -- Toggle visibility
            if ccOptionsFrame:IsShown() then
                ccOptionsFrame:Hide()
            else
                ccOptionsFrame:Show()
            end
        end
        ccOptionsFrame:ClearAllPoints()
        ccOptionsFrame:SetPoint("RIGHT", cb, "LEFT", 0, 50)
    end

    local buffOptionsFrame
    local function OpenBuffSettingsWindow(cb)
        if not buffOptionsFrame then
            -- Create a new frame if it doesn't exist
            buffOptionsFrame = CreateFrame("Frame", nil, guiNameplateAuras, "BasicFrameTemplateWithInset")
            buffOptionsFrame:SetSize(280, 110)
            buffOptionsFrame:SetPoint("CENTER")
            buffOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            buffOptionsFrame:SetFrameLevel(550)
            KeepPopupInSettings(buffOptionsFrame, guiNameplateAuras)
            buffOptionsFrame:SetMovable(true)
            buffOptionsFrame:EnableMouse(true)
            buffOptionsFrame:RegisterForDrag("LeftButton")
            buffOptionsFrame:SetScript("OnDragStart", buffOptionsFrame.StartMoving)
            buffOptionsFrame:SetScript("OnDragStop", buffOptionsFrame.StopMovingOrSizing)

            -- Title
            buffOptionsFrame.title = buffOptionsFrame:CreateFontString(nil, "OVERLAY")
            buffOptionsFrame.title:SetFontObject("GameFontHighlight")
            buffOptionsFrame.title:SetPoint("LEFT", buffOptionsFrame.TitleBg, "LEFT", 5, 0)
            buffOptionsFrame.title:SetText(L["PvP_Buffs_All_Units"])

            local function OpenColorPicker(colorTbl, cb)
                local colorData = BetterBlizzPlatesDB[colorTbl] or {}
                local r, g, b = colorData.r or 1, colorData.g or 1, colorData.b or 1
                local a = colorData.a or 1 -- Default alpha to 1 if not present

                local backupColorData = {r = r, g = g, b = b, a = a}

                local function updateColors()
                    BetterBlizzPlatesDB[colorTbl].r, BetterBlizzPlatesDB[colorTbl].g, BetterBlizzPlatesDB[colorTbl].b, BetterBlizzPlatesDB[colorTbl].a = r, g, b, a
                    cb.texture:SetVertexColor(r, g, b, 1)
                    cb.Text:SetTextColor(r, g, b, 1)
                    BBP.RefreshAllNameplates()
                    if ColorPickerFrame.Content then
                        ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
                    end
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    updateColors()
                end

                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha()
                    updateColors()
                end

                local function cancelFunc()
                    r, g, b, a = backupColorData.r, backupColorData.g, backupColorData.b, backupColorData.a
                    updateColors()
                end

                ColorPickerFrame.previousValues = {r, g, b, a}
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r, g = g, b = b, opacity = a, hasOpacity = true,
                    swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
                })
            end

            -- Store references to glow checkboxes
            local glowCheckboxes = {}

            -- First Loop: Glow Checkboxes
            local glowFilters = {
                { label = L["Glow_Offensives"], var = "importantBuffsOffensivesGlow", tt = L["Important_Offensive_Auras"], colorTbl = "importantBuffsOffensivesGlowRGB", linkedVar = "importantBuffsOffensives" },
                { label = L["Glow_Defensives"], var = "importantBuffsDefensivesGlow", tt = L["Important_Defensive_Auras"], colorTbl = "importantBuffsDefensivesGlowRGB", linkedVar = "importantBuffsDefensives" },
                { label = L["Glow_Mobility"], var = "importantBuffsMobilityGlow", tt = L["Important_Mobility_Freedom_Auras"], colorTbl = "importantBuffsMobilityGlowRGB", linkedVar = "importantBuffsMobility" },
            }

            local previousGlowCheckbox
            for i, buffFilter in ipairs(glowFilters) do
                local glowCheckbox = CreateFrame("CheckButton", nil, buffOptionsFrame, "UICheckButtonTemplate")
                glowCheckbox:SetSize(24, 24)
                glowCheckbox.Text:SetText(buffFilter.label)

                -- Positioning
                if i == 1 then
                    glowCheckbox:SetPoint("TOPLEFT", buffOptionsFrame, "TOPLEFT", 145, -30)
                else
                    glowCheckbox:SetPoint("TOPLEFT", previousGlowCheckbox, "BOTTOMLEFT", 0, 3)
                end

                -- Set initial state from DB
                glowCheckbox:SetChecked(BetterBlizzPlatesDB[buffFilter.var])

                -- Save state when toggled
                glowCheckbox:SetScript("OnClick", function(self)
                    BetterBlizzPlatesDB[buffFilter.var] = self:GetChecked()
                    local color = BetterBlizzPlatesDB[buffFilter.colorTbl]
                    glowCheckbox.texture:SetVertexColor(color.r, color.g, color.b, BetterBlizzPlatesDB[buffFilter.var] and 1 or 0)
                    if BetterBlizzPlatesDB[buffFilter.var] then
                        glowCheckbox.Text:SetTextColor(color.r, color.g, color.b, 1)
                    else
                        glowCheckbox.Text:SetTextColor(1, 0.819607, 0, 1)
                    end
                    BBP.UpdateImportantBuffsAndCCTables()
                    BBP.RefreshAllNameplates()
                end)

                -- Create texture for color indication
                glowCheckbox.texture = glowCheckbox:CreateTexture(nil, "ARTWORK", nil, 1)
                glowCheckbox.texture:SetAtlas("newplayertutorial-drag-slotgreen")
                glowCheckbox.texture:SetSize(27, 27)
                glowCheckbox.texture:SetDesaturated(true)
                glowCheckbox.texture:SetPoint("CENTER", glowCheckbox, "CENTER", -0.5, 0.5)

                -- Tooltip
                CreateTooltipTwo(glowCheckbox, L["Important_Glow"] .. " |T"..BBP.ImportantIcon..":22:22:0:0|t", string.format(L["Tooltip_Glow_On_All"], buffFilter.tt) .. "\n\n|cff32f795" .. L["Right_Click_To_Change_Color"] .. "|r", L["Tooltip_Auras_That_Are_In_The_Whitelist_SubText"], "ANCHOR_TOPRIGHT")

                -- Set initial color
                local color = BetterBlizzPlatesDB[buffFilter.colorTbl]
                glowCheckbox.texture:SetVertexColor(color.r, color.g, color.b, BetterBlizzPlatesDB[buffFilter.var] and 1 or 0)
                if BetterBlizzPlatesDB[buffFilter.var] then
                    glowCheckbox.Text:SetTextColor(color.r, color.g, color.b, 1)
                else
                    glowCheckbox.Text:SetTextColor(1, 0.819607, 0, 1)
                end

                -- Right-click opens color picker
                glowCheckbox:HookScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        OpenColorPicker(buffFilter.colorTbl, self)
                    end
                end)

                -- Store reference to the checkbox for later enabling/disabling
                glowCheckboxes[buffFilter.linkedVar] = glowCheckbox

                previousGlowCheckbox = glowCheckbox
            end

            -- Second Loop: Important Buff Checkboxes (Enable/Disable Glow Checkboxes)
            local importantFilters = {
                { label = L["Important_Offensives"], var = "importantBuffsOffensives", tt = L["Show_Important_Offensives"] },
                { label = L["Important_Defensives"], var = "importantBuffsDefensives", tt = L["Show_Important_Defensives"] },
                { label = L["Important_Mobility"], var = "importantBuffsMobility", tt = L["Show_Important_Mobility_Freedoms"] },
            }

            local previousImportantCheckbox
            for i, buffFilter in ipairs(importantFilters) do
                local importantCheckbox = CreateFrame("CheckButton", nil, buffOptionsFrame, "UICheckButtonTemplate")
                importantCheckbox:SetSize(24, 24)
                importantCheckbox.Text:SetText(buffFilter.label)

                -- Positioning
                if i == 1 then
                    importantCheckbox:SetPoint("TOPLEFT", buffOptionsFrame, "TOPLEFT", 10, -30)
                else
                    importantCheckbox:SetPoint("TOPLEFT", previousImportantCheckbox, "BOTTOMLEFT", 0, 3)
                end

                -- Set initial state from DB
                importantCheckbox:SetChecked(BetterBlizzPlatesDB[buffFilter.var])

                -- Save state when toggled + Enable/Disable Glow Checkboxes
                importantCheckbox:SetScript("OnClick", function(self)
                    local isChecked = self:GetChecked()
                    BetterBlizzPlatesDB[buffFilter.var] = isChecked
                    BBP.UpdateImportantBuffsAndCCTables()

                    -- Enable or disable the corresponding glow checkbox
                    local linkedGlowCheckbox = glowCheckboxes[buffFilter.var]
                    if linkedGlowCheckbox then
                        linkedGlowCheckbox:SetEnabled(isChecked)
                        linkedGlowCheckbox:SetAlpha(isChecked and 1 or 0.5) -- Dim it if disabled
                    end
                end)

                -- Disable Glow Checkbox if Important Checkbox is not checked
                if not BetterBlizzPlatesDB[buffFilter.var] then
                    local linkedGlowCheckbox = glowCheckboxes[buffFilter.var]
                    if linkedGlowCheckbox then
                        linkedGlowCheckbox:SetEnabled(false)
                        linkedGlowCheckbox:SetAlpha(0.5) -- Make it look disabled
                    end
                end

                -- Tooltip
                CreateTooltipTwo(importantCheckbox, buffFilter.tt)

                -- Store reference
                previousImportantCheckbox = importantCheckbox
            end

            buffOptionsFrame:Show()
        else
            -- Toggle visibility
            if buffOptionsFrame:IsShown() then
                buffOptionsFrame:Hide()
            else
                buffOptionsFrame:Show()
            end
        end
        buffOptionsFrame:ClearAllPoints()
        buffOptionsFrame:SetPoint("RIGHT", cb, "LEFT", 0, 50)
    end

    local hookCC = {
        friendlyNpdeBuffFilterCC,
        otherNpdeBuffFilterCC,
        personalNpdeBuffFilterCC,
    }

    for _, cb in pairs(hookCC) do
        cb:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                OpenCCSettingsWindow(cb)
            end
        end)
    end

    local hookBuffs = {
        otherNpBuffFilterImportantBuffs,
        friendlyNpBuffFilterImportantBuffs,
        personalNpBuffFilterImportantBuffs,
    }

    for _, cb in pairs(hookBuffs) do
        cb:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                OpenBuffSettingsWindow(cb)
            end
        end)
    end


    local personalNpdeBuffFilterLessMinite = CreateCheckbox("personalNpdeBuffFilterLessMinite", L["Under_One_Min"], personalNpdeBuffEnable)
    personalNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", personalNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpdeBuffFilterLessMinite, L["Tooltip_Only_Show_Debuffs_Under_One_Minute_2"], "ANCHOR_LEFT")

    --------------------------
    -- Nameplate settings
    --------------------------
    local nameplateAurasXPos = CreateSlider(enableNameplateAuraCustomisation, L["X_Offset"], -50, 50, 1, "nameplateAurasXPos", "X")
    nameplateAurasXPos:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -230, -240)
    CreateTooltip(nameplateAurasXPos, L["Tooltip_Aura_X_Offset"])

    local nameplateAurasYPos = CreateSlider(enableNameplateAuraCustomisation, L["Y_Offset"], -50, 50, 1, "nameplateAurasYPos", "Y")
    nameplateAurasYPos:SetPoint("TOPLEFT", nameplateAurasXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasYPos, L["Tooltip_Aura_Y_Offset_When_Name_Is"])

    local nameplateAurasNoNameYPos = CreateSlider(enableNameplateAuraCustomisation, L["No_Name_Y_Offset"], -50, 50, 1, "nameplateAurasNoNameYPos", "Y")
    nameplateAurasNoNameYPos:SetPoint("TOPLEFT", nameplateAurasYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasNoNameYPos, L["Tooltip_Aura_Y_Offset_When_Name_Is_2"])

    local nameplateAuraScale = CreateSlider(enableNameplateAuraCustomisation, L["Global_Aura_Size"], 0.7, 2, 0.01, "nameplateAuraScale")
    nameplateAuraScale:SetPoint("TOPLEFT", nameplateAurasNoNameYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraScale, L["Global_Aura_Size"], L["Tooltip_Global_Aura_Size_Desc"])

    local nameplateAuraBuffScale = CreateSlider(enableNameplateAuraCustomisation, L["Buff_Size"], 0.7, 2, 0.01, "nameplateAuraBuffScale")
    nameplateAuraBuffScale:SetPoint("TOPLEFT", nameplateAuraScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraBuffScale, L["Buff_Size"], L["Tooltip_Buff_Size_Desc"], L["Tooltip_Buff_Size_SubText"])

    local nameplateAuraDebuffScale = CreateSlider(enableNameplateAuraCustomisation, L["Debuff_Size"], 0.7, 2, 0.01, "nameplateAuraDebuffScale")
    nameplateAuraDebuffScale:SetPoint("TOPLEFT", nameplateAuraBuffScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraDebuffScale, L["Debuff_Size"], L["Tooltip_Debuff_Size_Desc"], L["Tooltip_Buff_Size_SubText"])

    local nameplateAuraCountScale = CreateSlider(enableNameplateAuraCustomisation, L["Aura_Stack_Size"], 0.7, 2, 0.01, "nameplateAuraCountScale")
    nameplateAuraCountScale:SetPoint("TOPLEFT", nameplateAuraDebuffScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraCountScale, L["Aura_Stack_Size"], L["Tooltip_Aura_Stack_Size_Desc"])

    local nameplateAuraEnlargedScale = CreateSlider(enableNameplateAuraCustomisation, L["Enlarged_Aura_Size"], 1, 2, 0.01, "nameplateAuraEnlargedScale")
    nameplateAuraEnlargedScale:SetPoint("TOPLEFT", nameplateAuraScale, "BOTTOMLEFT", -170, -101)
    local enlargedAuraIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    enlargedAuraIcon:SetTexture(BBP.EnlargedIcon)
    enlargedAuraIcon:SetSize(18, 18)
    enlargedAuraIcon:SetPoint("RIGHT", nameplateAuraEnlargedScale, "LEFT", -3, 0)





    local npColorAuraBorder = CreateCheckbox("npColorAuraBorder", L["Color_Border_By_Type"], enableNameplateAuraCustomisation)
    npColorAuraBorder:SetPoint("RIGHT", enlargedAuraIcon, "LEFT", -10, 295)
    CreateTooltipTwo(npColorAuraBorder, L["Color_Border_By_Type"], L["Color_Border_By_Type"])

    local npAuraBuffsRGB = CreateColorBox(npColorAuraBorder, "npAuraBuffsRGB", L["Buffs"])
    npAuraBuffsRGB:SetPoint("TOPLEFT", npColorAuraBorder, "BOTTOMLEFT", 15, 0)

    local npAuraPoisonRGB = CreateColorBox(npColorAuraBorder, "npAuraPoisonRGB", L["Poison"])
    npAuraPoisonRGB:SetPoint("TOPLEFT", npAuraBuffsRGB, "BOTTOMLEFT", 0, 0)

    local npAuraCurseRGB = CreateColorBox(npColorAuraBorder, "npAuraCurseRGB", L["Curse"])
    npAuraCurseRGB:SetPoint("TOPLEFT", npAuraPoisonRGB, "BOTTOMLEFT", 0, 0)

    local npAuraDiseaseRGB = CreateColorBox(npColorAuraBorder, "npAuraDiseaseRGB", L["Disease"])
    npAuraDiseaseRGB:SetPoint("TOPLEFT", npAuraCurseRGB, "BOTTOMLEFT", 0, 0)

    local npAuraMagicRGB = CreateColorBox(npColorAuraBorder, "npAuraMagicRGB", L["Magic"])
    npAuraMagicRGB:SetPoint("TOPLEFT", npAuraDiseaseRGB, "BOTTOMLEFT", 0, 0)

    local npAuraOtherRGB = CreateColorBox(npColorAuraBorder, "npAuraOtherRGB", L["Other"])
    npAuraOtherRGB:SetPoint("TOPLEFT", npAuraMagicRGB, "BOTTOMLEFT", 0, 0)

    npColorAuraBorder:HookScript("OnClick", function(self)
        local alpha = self:GetChecked() and 1 or 0.5
        npAuraBuffsRGB:SetAlpha(alpha)
        npAuraPoisonRGB:SetAlpha(alpha)
        npAuraCurseRGB:SetAlpha(alpha)
        npAuraDiseaseRGB:SetAlpha(alpha)
        npAuraMagicRGB:SetAlpha(alpha)
        npAuraOtherRGB:SetAlpha(alpha)
    end)






    local nameplateAuraEnlargedSquare = CreateCheckbox("nameplateAuraEnlargedSquare", L["Square_Aura"], enableNameplateAuraCustomisation)
    nameplateAuraEnlargedSquare:SetPoint("RIGHT", enlargedAuraIcon, "LEFT", -60, 1)
    CreateTooltipTwo(nameplateAuraEnlargedSquare, L["Square_Enlarged_Aura"], L["Tooltip_Square_Enlarged_Aura_Desc"], nil)

    local sortCompactedAurasFirst = CreateCheckbox("sortCompactedAurasFirst", L["Sort_Compacted_Auras_First"], enableNameplateAuraCustomisation)
    sortCompactedAurasFirst:SetPoint("BOTTOMLEFT", nameplateAuraEnlargedSquare, "TOPLEFT", 0, 5)
    CreateTooltipTwo(sortCompactedAurasFirst, L["Sort_Compacted_Auras_First"], L["Tooltip_Sort_Compacted_Auras_First_Desc"])

    local sortEnlargedAurasFirst = CreateCheckbox("sortEnlargedAurasFirst", L["Sort_Enlarged_Auras_First"], enableNameplateAuraCustomisation)
    sortEnlargedAurasFirst:SetPoint("BOTTOMLEFT", sortCompactedAurasFirst, "TOPLEFT", 0, -4)
    CreateTooltipTwo(sortEnlargedAurasFirst, L["Sort_Enlarged_Auras_First"], L["Tooltip_Sort_Enlarged_Auras_First_Desc"])

    local sortDurationAuras = CreateCheckbox("sortDurationAuras", L["Sort_Auras_By_Duration"], enableNameplateAuraCustomisation)
    sortDurationAuras:SetPoint("BOTTOMLEFT", sortEnlargedAurasFirst, "TOPLEFT", 0, -4)
    CreateTooltipTwo(sortDurationAuras, L["Sort_Auras_By_Duration"], L["Tooltip_Sort_Auras_By_Duration_Desc"])
    sortDurationAuras:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzPlatesDB.sortDurationAurasReverse then
                BetterBlizzPlatesDB.sortDurationAurasReverse = nil
            else
                BetterBlizzPlatesDB.sortDurationAurasReverse = true
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local enlargeAllImportantBuffs = CreateCheckbox("enlargeAllImportantBuffs", L["Enlarge_All_Important_Buffs"], enableNameplateAuraCustomisation)
    enlargeAllImportantBuffs:SetPoint("BOTTOMLEFT", sortDurationAuras, "TOPLEFT", 0, -4)
    CreateTooltipTwo(enlargeAllImportantBuffs, L["Enlarge_All_Important_Buffs"], L["Tooltip_Enlarge_All_Important_Buffs_2_Desc"])
    BBP.enlargeAllImportantBuffs = enlargeAllImportantBuffs

    local enlargeAllCC = CreateCheckbox("enlargeAllCC", L["Enlarge_All_CC"], enableNameplateAuraCustomisation)
    enlargeAllCC:SetPoint("BOTTOMLEFT", enlargeAllImportantBuffs, "TOPLEFT", 0, -4)
    CreateTooltipTwo(enlargeAllCC, L["Enlarge_All_PvP_CC"], L["Tooltip_Enlarge_All_PvP_CC_Desc"])

    sortEnlargedAurasFirst:HookScript("OnClick", function (self)
        if self:GetChecked() then
            sortCompactedAurasFirst:SetChecked(false)
            BetterBlizzPlatesDB.sortCompactedAurasFirst = false
        end
    end)

    sortCompactedAurasFirst:HookScript("OnClick", function (self)
        if self:GetChecked() then
            sortEnlargedAurasFirst:SetChecked(false)
            BetterBlizzPlatesDB.sortEnlargedAurasFirst = false
        end
    end)

    local nameplateAuraCompactedScale = CreateSlider(enableNameplateAuraCustomisation, L["Compacted_Aura_Size"], 0.4, 1, 0.01, "nameplateAuraCompactedScale")
    nameplateAuraCompactedScale:SetPoint("TOPLEFT", nameplateAuraEnlargedScale, "BOTTOMLEFT", 0, -17)
    local compactedAuraIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    compactedAuraIcon:SetTexture(BBP.CompactIcon)
    compactedAuraIcon:SetSize(18, 18)
    compactedAuraIcon:SetPoint("RIGHT", nameplateAuraCompactedScale, "LEFT", -3, 0)

    local nameplateAuraCompactedSquare = CreateCheckbox("nameplateAuraCompactedSquare", L["Halve_Aura"], enableNameplateAuraCustomisation)
    nameplateAuraCompactedSquare:SetPoint("RIGHT", compactedAuraIcon, "LEFT", -60, 1)
    CreateTooltipTwo(nameplateAuraCompactedSquare, L["Halve_Compacted_Aura"], L["Tooltip_Halve_Compacted_Aura_Desc"], L["Tooltip_Halve_Compacted_Aura_SubText"])

    local nameplateAuraKeyAuraPositionEnabled = CreateCheckbox("nameplateAuraKeyAuraPositionEnabled", L["Enable_Key_Auras"], enableNameplateAuraCustomisation)
    nameplateAuraKeyAuraPositionEnabled:SetPoint("TOPLEFT", nameplateAuraCompactedSquare, "BOTTOMLEFT", 5, -12)
    CreateTooltipTwo(nameplateAuraKeyAuraPositionEnabled, L["Enable_Key_Auras"], L["Tooltip_Enable_Key_Auras_Desc"], L["Tooltip_Enable_Key_Auras_SubText"])
    nameplateAuraKeyAuraPositionEnabled:SetScale(1.4)

    local pvpCC = CreateFrame("CheckButton", nil, nameplateAuraKeyAuraPositionEnabled, "InterfaceOptionsCheckButtonTemplate")
    pvpCC:SetPoint("TOPLEFT", nameplateAuraKeyAuraPositionEnabled, "BOTTOMRIGHT", -20, 9)
    pvpCC.Text:SetText(L["Glow_And_Filter"])
    pvpCC:SetChecked(BetterBlizzPlatesDB.otherNpdeBuffFilterCC)
    pvpCC:SetIgnoreParentScale(true)
    pvpCC:SetScale(0.7)
    CreateTooltipTwo(pvpCC, L["Glow_And_Filter"], L["Tooltip_Glow_And_Filter_Desc"],L["Tooltip_Glow_And_Filter_SubText"])

    otherNpdeBuffFilterCC:HookScript("OnClick", function(self)
        pvpCC:SetChecked(self:GetChecked())
    end)

    if not nameplateAuraKeyAuraPositionEnabled:GetChecked() then
        pvpCC:Disable()
        pvpCC:SetAlpha(0.5)
    end

    pvpCC:HookScript("OnClick", function(self)
        BetterBlizzPlatesDB.otherNpdeBuffFilterCC = self:GetChecked()
        BBP.UpdateImportantBuffsAndCCTables()
        otherNpdeBuffFilterCC:Click()
        otherNpdeBuffFilterCC:SetChecked(BetterBlizzPlatesDB.otherNpdeBuffFilterCC)
    end)

    pvpCC:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenCCSettingsWindow(pvpCC)
        end
    end)

    local nameplateAuraKeyAuraPositionFriendly = CreateCheckbox("nameplateAuraKeyAuraPositionFriendly", L["Friendly"], nameplateAuraKeyAuraPositionEnabled)
    nameplateAuraKeyAuraPositionFriendly:SetPoint("LEFT", pvpCC.text, "RIGHT", 0, 0)
    CreateTooltipTwo(nameplateAuraKeyAuraPositionFriendly, L["Enable_Key_Auras_On_Friendly"], L["Tooltip_Enable_Key_Auras_On_Friendly_Desc"])
    nameplateAuraKeyAuraPositionFriendly:SetIgnoreParentScale(true)
    nameplateAuraKeyAuraPositionFriendly:SetScale(0.7)

    nameplateAuraKeyAuraPositionEnabled:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BetterBlizzPlatesDB["keyAurasImportantBuffsEnabled"] = not BetterBlizzPlatesDB["keyAurasImportantBuffsEnabled"]
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.UpdateImportantBuffsAndCCTables()
            for k, namePlate in pairs(C_NamePlate.GetNamePlates(false)) do
                BBP.On_NpRefreshOnce(namePlate.UnitFrame)
            end
        end
    end)

    nameplateAuraKeyAuraPositionEnabled:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    local nameplateKeyAuraScale = CreateSlider(nameplateAuraKeyAuraPositionEnabled, L["Key_Aura_Size"], 0.6, 2.2, 0.01, "nameplateKeyAuraScale")
    nameplateKeyAuraScale:SetPoint("TOPLEFT", nameplateAuraKeyAuraPositionEnabled, "BOTTOMLEFT", 20, -27)
    CreateTooltipTwo(nameplateKeyAuraScale, L["Key_Aura_Size"], L["Tooltip_Key_Aura_Size_Desc"])
    nameplateKeyAuraScale:SetScale(0.7)

    local nameplateKeyAurasXPos = CreateSlider(nameplateAuraKeyAuraPositionEnabled, L["Key_Aura_X_Offset"], -80, 80, 1, "nameplateKeyAurasXPos", "X")
    nameplateKeyAurasXPos:SetPoint("TOPLEFT", nameplateKeyAuraScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateKeyAurasXPos, L["Key_Aura_X_Offset"], L["Tooltip_Key_Aura_X_Offset_Desc"])
    nameplateKeyAurasXPos:SetScale(0.7)

    local nameplateKeyAurasYPos = CreateSlider(nameplateAuraKeyAuraPositionEnabled, L["Key_Aura_Y_Offset"], -80, 80, 1, "nameplateKeyAurasYPos", "Y")
    nameplateKeyAurasYPos:SetPoint("TOPLEFT", nameplateKeyAurasXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateKeyAurasYPos, L["Key_Aura_Y_Offset"], L["Tooltip_Key_Aura_Y_Offset_Desc"])
    nameplateKeyAurasYPos:SetScale(0.7)

    local nameplateKeyAurasHorizontalGap = CreateSlider(nameplateAuraKeyAuraPositionEnabled, L["Key_Aura_Aura_Gap"], 0, 10, 1, "nameplateKeyAurasHorizontalGap", "Y")
    nameplateKeyAurasHorizontalGap:SetPoint("TOPLEFT", nameplateKeyAurasYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateKeyAurasHorizontalGap, L["Key_Aura_Gap"], L["Tooltip_Key_Aura_Gap_Desc"])
    nameplateKeyAurasHorizontalGap:SetScale(0.7)

    local nameplateKeyAurasAnchor = CreateAnchorDropdown(
        "nameplateKeyAurasAnchorDropdown",
        enableNameplateAuraCustomisation,
        L["Select_Key_Aura_Anchor"],
        "nameplateKeyAurasAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = nameplateKeyAurasHorizontalGap, x = -16, y = -40, label = L["Key_Auras_Position"] },nil,nil,{"RIGHT", "LEFT", "CENTER"}
    )

    local nameplateKeyAurasFriendlyAnchor = CreateAnchorDropdown(
        "nameplateKeyAurasFriendlyAnchorDropdown",
        enableNameplateAuraCustomisation,
        L["Select_Friendly_Key_Aura_Anchor"],
        "nameplateKeyAurasFriendlyAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = nameplateKeyAurasHorizontalGap, x = -16, y = -85, label = L["Friendly_Key_Auras_Position"] },nil,nil,{"RIGHT", "LEFT", "CENTER"}
    )


    nameplateAuraKeyAuraPositionEnabled:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
        CheckAndToggleCheckboxes(nameplateAuraKeyAuraPositionEnabled)
    end)

    -- local prdText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- prdText:SetPoint("BOTTOMLEFT", nameplateAuraCountScale, "BOTTOMLEFT", 0, -30)
    -- prdText:SetText("Personal Resource Display Specific:")
    -- CreateTooltipTwo(prdText, "PRD Specific Settings", "The settings listed here are specific for the Personal Resource Display. If settings are not listed here they will take the values from the settings above.")


    -- local nameplateAuraSelfScale = CreateSlider(enableNameplateAuraCustomisation, "PRD: Global Aura Size", 0.7, 2, 0.01, "nameplateAuraSelfScale")
    -- nameplateAuraSelfScale:SetPoint("TOPLEFT", prdText, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(nameplateAuraSelfScale, "Global Aura Size\nfor Personal Resource Display", "The general size of ALL auras. Will be added on top of every aura type: buff, debuff.")

    -- local nameplateAuraBuffSelfScale = CreateSlider(enableNameplateAuraCustomisation, "PRD: Buff Size", 0.7, 2, 0.01, "nameplateAuraBuffSelfScale")
    -- nameplateAuraBuffSelfScale:SetPoint("TOPLEFT", nameplateAuraSelfScale, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(nameplateAuraBuffSelfScale, "Buff Size\nfor Personal Resource Display", "Size of Buffs on the Personal Resource Display.", "Will not be applied to auras marked Enlarged or Compacted")

    -- local nameplateAuraDebuffSelfScale = CreateSlider(enableNameplateAuraCustomisation, "PRD: Debuff Size", 0.7, 2, 0.01, "nameplateAuraDebuffSelfScale")
    -- nameplateAuraDebuffSelfScale:SetPoint("TOPLEFT", nameplateAuraBuffSelfScale, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(nameplateAuraDebuffSelfScale, "Debuff Size\nfor Personal Resource Display", "Size of Debuffs on the Personal Resource Display.", "Will not be applied to auras marked Enlarged or Compacted")

    -- local nameplateAurasPersonalXPos = CreateSlider(enableNameplateAuraCustomisation, "PRD: X Offset", -50, 50, 1, "nameplateAurasPersonalXPos", "X")
    -- nameplateAurasPersonalXPos:SetPoint("TOPLEFT", nameplateAuraDebuffSelfScale, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(nameplateAurasPersonalXPos, "X Offset\nfor Personal Resource Display", "X Offset for Auras on the Personal Resource Display.")

    -- local nameplateAurasPersonalCenteredAnchor = CreateCheckbox("nameplateAurasPersonalCenteredAnchor", "PRD: Center Auras", enableNameplateAuraCustomisation)
    -- nameplateAurasPersonalCenteredAnchor:SetPoint("LEFT", nameplateAurasPersonalXPos, "RIGHT", 5, 0)
    -- CreateTooltipTwo(nameplateAurasPersonalCenteredAnchor, "Center Auras\nfor Personal Resource Display")

    -- local nameplateAurasPersonalYPos = CreateSlider(enableNameplateAuraCustomisation, "PRD: Y Offset", -50, 50, 1, "nameplateAurasPersonalYPos", "Y")
    -- nameplateAurasPersonalYPos:SetPoint("TOPLEFT", nameplateAurasPersonalXPos, "BOTTOMLEFT", 0, -17)
    -- CreateTooltipTwo(nameplateAurasPersonalYPos, "Y Offset\nfor Personal Resource Display", "Y Offset for Auras on the Personal Resource Display.")

    -- local disableEnlargedAurasOnSelf = CreateCheckbox("disableEnlargedAurasOnSelf", "Disable Enlarged Aura on PRD", enableNameplateAuraCustomisation)
    -- disableEnlargedAurasOnSelf:SetPoint("TOPLEFT", nameplateAurasPersonalYPos, "BOTTOMLEFT", 0, 1)
    -- CreateTooltipTwo(disableEnlargedAurasOnSelf, "Disable Enlarged Aura on PRD", "Disable Enlarged Auras on Personal Resource Display.")

    -- local disableCompactedAurasOnSelf = CreateCheckbox("disableCompactedAurasOnSelf", "Disable Compacted Aura on PRD", enableNameplateAuraCustomisation)
    -- disableCompactedAurasOnSelf:SetPoint("TOPLEFT", disableEnlargedAurasOnSelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(disableCompactedAurasOnSelf, "Disable Compacted Aura on PRD", "Disable Compacted Auras on Personal Resource Display.")

    -- local disableImportantAurasOnSelf = CreateCheckbox("disableImportantAurasOnSelf", "Disable Important Aura Glow on PRD", enableNameplateAuraCustomisation)
    -- disableImportantAurasOnSelf:SetPoint("TOPLEFT", disableCompactedAurasOnSelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(disableImportantAurasOnSelf, "Disable Important Aura Glow on PRD", "Disable Important Aura Glow on Personal Resource Display.")

--[[
    local nameplateAuraDropdown = CreateAnchorDropdown(
        "nameplateAuraDropdown",
        enableNameplateAuraCustomisation,
        "Select Anchor Point",
        "nameplateAuraAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = nameplateAuraScale, x = -16, y = -35, label = "Aura Anchor Point" }
    )

    local nameplateAuraRelativeDropdown = CreateAnchorDropdown(
        "nameplateAuraRelativeDropdown",
        enableNameplateAuraCustomisation,
        "Select Anchor Point",
        "nameplateAuraRelativeAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = nameplateAuraScale, x = -16, y = -95, label = "Nameplate Relative Point" }
    )


]]

    local nameplateAurasEnemyCenteredAnchor = CreateCheckbox("nameplateAurasEnemyCenteredAnchor", L["Center_Auras_On_Enemy"], enableNameplateAuraCustomisation)
    nameplateAurasEnemyCenteredAnchor:SetPoint("BOTTOM", nameplateAurasXPos, "TOP", -80, 80)
    CreateTooltipTwo(nameplateAurasEnemyCenteredAnchor, L["Center_Auras_On_Enemy"], L["Tooltip_Center_Auras_On_Enemy_Desc"])
    nameplateAurasEnemyCenteredAnchor:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzPlatesDB.nameplateCenterOnlyBuffs == nil then
                BetterBlizzPlatesDB.nameplateCenterOnlyBuffs = true
            else
                BetterBlizzPlatesDB.nameplateCenterOnlyBuffs = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local nameplateAuraRightToLeft = CreateCheckbox("nameplateAuraRightToLeft", L["Reverse_Auras"], enableNameplateAuraCustomisation)
    nameplateAuraRightToLeft:SetPoint("BOTTOMLEFT", nameplateAurasEnemyCenteredAnchor, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateAuraRightToLeft, L["Reverse_Auras"], L["Tooltip_Reverse_Auras_Desc"])

    local nameplateAurasFriendlyCenteredAnchor = CreateCheckbox("nameplateAurasFriendlyCenteredAnchor", L["Center_Auras_On_Friendly"], enableNameplateAuraCustomisation)
    nameplateAurasFriendlyCenteredAnchor:SetPoint("TOPLEFT", nameplateAurasEnemyCenteredAnchor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAurasFriendlyCenteredAnchor, L["Tooltip_Keep_Auras_Centered_On_Friendly_Nameplates"])

    local nameplateCenterAllRows = CreateCheckbox("nameplateCenterAllRows", L["Center_Every_Row"], enableNameplateAuraCustomisation)
    nameplateCenterAllRows:SetPoint("TOP", nameplateAurasFriendlyCenteredAnchor, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateCenterAllRows, L["Tooltip_Centers_Every_New_Row_On_Top"])

    if BetterBlizzPlatesDB.enableNameplateAuraCustomisation and (BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor or BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor) then
        EnableElement(nameplateCenterAllRows)
    else
        DisableElement(nameplateCenterAllRows)
    end

    nameplateAurasEnemyCenteredAnchor:HookScript("OnClick", function(self)
        if BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor or BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor then
            EnableElement(nameplateCenterAllRows)
        else
            DisableElement(nameplateCenterAllRows)
        end
    end)

    nameplateAurasFriendlyCenteredAnchor:HookScript("OnClick", function(self)
        if BetterBlizzPlatesDB.nameplateAurasEnemyCenteredAnchor or BetterBlizzPlatesDB.nameplateAurasFriendlyCenteredAnchor then
            EnableElement(nameplateCenterAllRows)
        else
            DisableElement(nameplateCenterAllRows)
        end
    end)

    local nameplateAuraPlayersOnly = CreateCheckbox("nameplateAuraPlayersOnly", L["Hide_Auras_On_NPCs"], enableNameplateAuraCustomisation)
    nameplateAuraPlayersOnly:SetPoint("TOP", nameplateCenterAllRows, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAuraPlayersOnly, L["Tooltip_Hide_Auras_On_NPCs_And_Only"])

    local nameplateAuraPlayersOnlyShowTarget = CreateCheckbox("nameplateAuraPlayersOnlyShowTarget", L["Show_On_Target"], nameplateAuraPlayersOnly)
    nameplateAuraPlayersOnlyShowTarget:SetPoint("TOP", nameplateCenterAllRows, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAuraPlayersOnlyShowTarget, L["Tooltip_Show_Auras_On_Current_Target_Regardless"])

    local linkTexture = nameplateAuraPlayersOnly:CreateTexture(nil, "BACKGROUND")
    linkTexture:SetAtlas("Garr_XPBar_Nub")
    linkTexture:SetSize(9, 16)
    linkTexture:SetPoint("RIGHT", nameplateAuraPlayersOnlyShowTarget, "LEFT", -2, 0)
    linkTexture:SetRotation(math.pi / 2)

    if not BetterBlizzPlatesDB.nameplateAuraPlayersOnly then
        linkTexture:SetDesaturated(true)
    end

    nameplateAuraPlayersOnly:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(nameplateAuraPlayersOnly)
        if self:GetChecked() then
            linkTexture:SetDesaturated(false)
        else
            linkTexture:SetDesaturated(true)
        end
    end)

--[[
    nameplateAurasEnemyCenteredAnchor:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.nameplateAuraAnchor = "BOTTOM"
            BetterBlizzPlatesDB.nameplateAuraRelativeAnchor = "TOP"
            UIDropDownMenu_SetText(nameplateAuraDropdown, "BOTTOM")
            UIDropDownMenu_SetText(nameplateAuraRelativeDropdown, "TOP")
            BBP.RefreshBuffFrame()
        else
            BetterBlizzPlatesDB.nameplateAuraAnchor = "BOTTOMLEFT"
            BetterBlizzPlatesDB.nameplateAuraRelativeAnchor = "TOPLEFT"
            UIDropDownMenu_SetText(nameplateAuraDropdown, "BOTTOMLEFT")
            UIDropDownMenu_SetText(nameplateAuraRelativeDropdown, "TOPLEFT")
            BBP.RefreshBuffFrame()
        end
    end)

]]


    local nameplateAuraSquare = CreateCheckbox("nameplateAuraSquare", L["Square_Auras"], enableNameplateAuraCustomisation)
    nameplateAuraSquare:SetPoint("LEFT", nameplateAurasEnemyCenteredAnchor.text, "RIGHT", 5, 0)
    CreateTooltip(nameplateAuraSquare, L["Tooltip_Square_Aura_Icons"])

    local nameplateAuraTestMode = CreateCheckbox("nameplateAuraTestMode", L["Aura_Test_Mode"], enableNameplateAuraCustomisation)
    nameplateAuraTestMode:SetPoint("BOTTOMLEFT", nameplateAuraSquare, "TOPLEFT", 0, 0)
    CreateTooltipTwo(nameplateAuraTestMode, L["Aura_Test_Mode"], L["Tooltip_Aura_Test_Mode_Desc"], L["Tooltip_Aura_Test_Mode_SubText"], "ANCHOR_TOP")
    nameplateAuraTestMode:SetScale(1.4)

    local showDefaultCooldownNumbersOnNpAuras = CreateCheckbox("showDefaultCooldownNumbersOnNpAuras", L["Default_CD"], enableNameplateAuraCustomisation)
    showDefaultCooldownNumbersOnNpAuras:SetPoint("TOPLEFT", nameplateAuraSquare, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showDefaultCooldownNumbersOnNpAuras, L["Show_Blizzard_Cooldown"], L["Tooltip_Show_Blizzard_Cooldown_Desc"], L["Tooltip_Show_Blizzard_Cooldown_SubText"])

    local hideNpAuraSwipe = CreateCheckbox("hideNpAuraSwipe", L["Hide_CD_Swipe"], enableNameplateAuraCustomisation)
    hideNpAuraSwipe:SetPoint("TOPLEFT", showDefaultCooldownNumbersOnNpAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideNpAuraSwipe, L["Tooltip_Hide_The_Cooldown_Swipe_Animation"])
    nameplateAuraPlayersOnlyShowTarget:SetPoint("TOP", hideNpAuraSwipe, "BOTTOM", 0, pixelsBetweenBoxes)

    local nameplateAuraTaller = CreateCheckbox("nameplateAuraTaller", L["Taller_Auras"], enableNameplateAuraCustomisation)
    nameplateAuraTaller:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 9, 0)
    CreateTooltipTwo(nameplateAuraTaller, L["Taller_Auras"], L["Tooltip_Taller_Auras_Desc"])
    nameplateAuraTaller:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.nameplateAuraSquare = false
            nameplateAuraSquare:SetChecked(false)
            BBP.RefreshAllNameplates()
        end
    end)
    nameplateAuraSquare:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.nameplateAuraTaller = false
            nameplateAuraTaller:SetChecked(false)
            BBP.RefreshAllNameplates()
        end
    end)

    local showInterruptsOnNameplateAuras = CreateCheckbox("showInterruptsOnNameplateAuras", L["Interrupts"], enableNameplateAuraCustomisation)
    showInterruptsOnNameplateAuras:SetPoint("TOPLEFT", nameplateAuraTaller, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showInterruptsOnNameplateAuras, L["Show_Interrupts"], L["Tooltip_Show_Interrupts_Desc"])
    showInterruptsOnNameplateAuras:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BBP.SetUpAuraInterrupts()
        else
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local onlyPandemicAuraMine = CreateCheckbox("onlyPandemicAuraMine", L["Only_Pandemic_Mine"], enableNameplateAuraCustomisation)
    onlyPandemicAuraMine:SetPoint("TOPLEFT", showInterruptsOnNameplateAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(onlyPandemicAuraMine, L["Tooltip_Ignore_Self"], "ANCHOR_LEFT")

    local nameplateResourceDoNotRaiseAuras = CreateCheckbox("nameplateResourceDoNotRaiseAuras", L["Dont_Raise_For_Resource"], enableNameplateAuraCustomisation)
    nameplateResourceDoNotRaiseAuras:SetPoint("TOPLEFT", onlyPandemicAuraMine, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateResourceDoNotRaiseAuras, L["Tooltip_Dont_Raise_Auras_When_Nameplate_Resource"], "ANCHOR_LEFT")

--[=[
    local AuraGrowLeft = CreateCheckbox("nameplateAurasGrowLeft", "Grow left", contentFrame)
    AuraGrowLeft:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 5, 0)
]=]

    local maxAurasOnNameplate = CreateSlider(enableNameplateAuraCustomisation, L["Max_Auras_On_Nameplate"], 1, 24, 1, "maxAurasOnNameplate")
    maxAurasOnNameplate:SetPoint("LEFT", nameplateAurasXPos, "RIGHT", 30, 0)

    local nameplateAuraRowAmount = CreateSlider(enableNameplateAuraCustomisation, L["Enemy_Max_Auras_Per_Row"], 2, 24, 1, "nameplateAuraRowAmount")
    nameplateAuraRowAmount:SetPoint("TOP", maxAurasOnNameplate,  "BOTTOM", 0, -17)

    local nameplateAuraRowFriendlyAmount = CreateSlider(enableNameplateAuraCustomisation, L["Friendly_Max_Auras_Per_Row"], 2, 24, 1, "nameplateAuraRowFriendlyAmount")
    nameplateAuraRowFriendlyAmount:SetPoint("TOP", nameplateAuraRowAmount,  "BOTTOM", 0, -17)

    local nameplateAuraWidthGap = CreateSlider(enableNameplateAuraCustomisation, L["Horizontal_Gap_Between_Auras"], 0, 18, 0.5, "nameplateAuraWidthGap")
    nameplateAuraWidthGap:SetPoint("TOP", nameplateAuraRowFriendlyAmount,  "BOTTOM", 0, -17)

    local nameplateAuraHeightGap = CreateSlider(enableNameplateAuraCustomisation, L["Vertical_Gap_Between_Auras"], 0, 18, 0.5, "nameplateAuraHeightGap")
    nameplateAuraHeightGap:SetPoint("TOP", nameplateAuraWidthGap,  "BOTTOM", 0, -17)

    local defaultNpAuraCdSize = CreateSlider(showDefaultCooldownNumbersOnNpAuras, L["Default_CD_Text_Size"], 0.1, 2, 0.01, "defaultNpAuraCdSize")
    defaultNpAuraCdSize:SetPoint("TOP", nameplateAuraHeightGap,  "BOTTOM", 0, -17)
    CreateTooltipTwo(defaultNpAuraCdSize, L["Default_CD_Text_Size"], L["Tooltip_Default_CD_Text_Size_Desc"])
    showDefaultCooldownNumbersOnNpAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            defaultNpAuraCdSize:Enable()
            defaultNpAuraCdSize:SetAlpha(1)
        else
            defaultNpAuraCdSize:Disable()
            defaultNpAuraCdSize:SetAlpha(0.5)
        end
    end)

    local targetNameplateAuraScaleEnabled = CreateCheckbox("targetNameplateAuraScaleEnabled", "", enableNameplateAuraCustomisation)

    local targetNameplateAuraScale = CreateSlider(targetNameplateAuraScaleEnabled, L["Target_Aura_Size"], 0.5, 1.8, 0.01, "targetNameplateAuraScale")
    targetNameplateAuraScale:SetPoint("TOP", defaultNpAuraCdSize,  "BOTTOM", 0, -17)
    CreateTooltipTwo(targetNameplateAuraScale, L["Target_Aura_Size"], L["Tooltip_Target_Aura_Size_Desc"], nil, "ANCHOR_LEFT")
    targetNameplateAuraScaleEnabled:SetPoint("LEFT", targetNameplateAuraScale, "RIGHT", 5, 0)
    CreateTooltipTwo(targetNameplateAuraScaleEnabled, L["Enable_Target_Aura_Size"], L["Tooltip_Enable_Target_Aura_Size_Desc"], L["Tooltip_Enable_Target_Aura_Size_SubText"], "ANCHOR_LEFT")
    targetNameplateAuraScaleEnabled:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(targetNameplateAuraScale)
        else
            DisableElement(targetNameplateAuraScale)
        end
    end)


    local separateAuraBuffRow = CreateCheckbox("separateAuraBuffRow", L["Separate_Buff_Row"], enableNameplateAuraCustomisation)
    separateAuraBuffRow:SetPoint("TOPLEFT", nameplateAuraCountScale, "BOTTOMLEFT", 0, -10)
    CreateTooltip(separateAuraBuffRow, L["Tooltip_Show_Buffs_On_A_Separate_Row"], "ANCHOR_LEFT")

    local nameplateAuraTooltip = CreateCheckbox("nameplateAuraTooltip", L["Tooltip"], enableNameplateAuraCustomisation)
    nameplateAuraTooltip:SetPoint("TOPLEFT", separateAuraBuffRow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateAuraTooltip, L["Show_Tooltip"], L["Tooltip_Show_Tooltip_Desc"])
    nameplateAuraTooltip:HookScript("OnClick", function() BBP.ShowPopup("BBP_CONFIRM_RELOAD")end)

    local hideNpAurasOnUnattackableEnemies = CreateCheckbox("hideNpAurasOnUnattackableEnemies", L["Hide_Auras_On_Unattackable_Enemies"], enableNameplateAuraCustomisation)
    hideNpAurasOnUnattackableEnemies:SetPoint("TOPLEFT", nameplateAuraTooltip, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNpAurasOnUnattackableEnemies, L["Hide_Auras_On_Unattackable_Enemies"], L["Tooltip_Hide_Auras_On_Unattackable_Enemies_Desc"])

    local nameplateAuraTypeGap = CreateSlider(enableNameplateAuraCustomisation, L["Gap_Between_Buffs_And_Debuffs"], -100, 100, 0.5, "nameplateAuraTypeGap")
    nameplateAuraTypeGap:SetPoint("LEFT", separateAuraBuffRow.text,  "RIGHT", 0, 0)
    CreateTooltipTwo(nameplateAuraTypeGap, L["Gap_Between_Buffs_And_Debuffs"], L["Tooltip_Gap_Between_Buffs_And_Debuffs_Desc"], nil, "ANCHOR_LEFT")

    local imintoodeep1 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    imintoodeep1:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -95, -80)
    imintoodeep1:SetText(L["Scroll_Down_For_More_Settings"])

    enableNameplateAuraCustomisation:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BBP.ShowPopup("BBP_NP_AURA_ENABLE")
        else
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
        CheckAndToggleCheckboxes(enableNameplateAuraCustomisation)
        --TogglePanel()
    end)
    --TogglePanel()

    local betaHighlightIcon = enableNameplateAuraCustomisation:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", enableNameplateAuraCustomisation, "LEFT", 8, 0)


    local nameplateAuraTestMode2 = CreateCheckbox("nameplateAuraTestMode", L["Aura_Test_Mode"], enableNameplateAuraCustomisation)
    nameplateAuraTestMode2:SetPoint("LEFT", nameplateKeyAurasAnchor, "RIGHT", 60, -25)
    CreateTooltipTwo(nameplateAuraTestMode2, L["Aura_Test_Mode"], L["Tooltip_Aura_Test_Mode_Desc"], L["Tooltip_Aura_Test_Mode_SubText_2"], "ANCHOR_TOP")
    nameplateAuraTestMode2:SetScale(1.5)

    nameplateAuraTestMode:HookScript("OnClick", function(self)
        nameplateAuraTestMode2:SetChecked(self:GetChecked())
    end)

    nameplateAuraTestMode2:HookScript("OnClick", function(self)
        nameplateAuraTestMode:SetChecked(self:GetChecked())
    end)
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

    local tempResourceWA = CreateFrame("Button", nil, guiCVarControl, "UIPanelButtonTemplate")
    tempResourceWA:SetText(L["Import_WeakAura"])
    tempResourceWA:SetSize(170, 37)
    tempResourceWA:SetPoint("TOPLEFT", comboPointsText, "BOTTOMLEFT", 0, -6)
    tempResourceWA:SetScript("OnClick", function()
        if WeakAuras then
            WeakAuras.Import(BBP.tempComboPointWA)
        else
            print(L["Print_WeakAuras_Not_Enabled"])
        end
    end)
    CreateTooltipTwo(tempResourceWA, L["Import_Resource_WeakAura"], L["Tooltip_Import_Resource_WeakAura_Desc"])


    local nameplateResourceOnTarget = CreateCheckbox("nameplateResourceOnTarget", L["Show_Resource_On_Nameplate"], guiCVarControl, true, BBP.TargetResourceUpdater)
    nameplateResourceOnTarget:SetPoint("TOPLEFT", comboPointsText, "BOTTOMLEFT", -4, pixelsOnFirstBox-45)
    CreateTooltipTwo(nameplateResourceOnTarget, L["Nameplate_Resource"], L["Tooltip_Nameplate_Resource_Desc_2"], nil, nil, "nameplateResourceOnTarget")
    notWorking(nameplateResourceOnTarget)

    local nameplateResourceUnderCastbar = CreateCheckbox("nameplateResourceUnderCastbar", L["Anchor_Resource_Underneath_Healthbar_Castbar"], guiCVarControl, nil, BBP.RegisterTargetCastingEvents)
    nameplateResourceUnderCastbar:SetPoint("TOP", nameplateResourceOnTarget, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateResourceUnderCastbar, L["Anchor_Resource_Under"], L["Tooltip_Anchor_Resource_Under_Desc_2"])
    nameplateResourceOnTarget:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(nameplateResourceOnTarget)
    end)

    local hideResourceOnFriend = CreateCheckbox("hideResourceOnFriend", L["Hide_Resource_On_Friendly_Nameplates"], guiCVarControl)
    hideResourceOnFriend:SetPoint("TOP", nameplateResourceUnderCastbar, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideResourceOnFriend, L["Hide_Resource_On_Friendly"], L["Tooltip_Hide_Resource_On_Friendly_Desc"])
    notWorking(hideResourceOnFriend, true)

    local nameplateResourceScale = CreateSlider(guiCVarControl, L["Resource_Scale"], 0.2, 1.7, 0.01, "nameplateResourceScale")
    nameplateResourceScale:SetPoint("TOPLEFT", hideResourceOnFriend, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(nameplateResourceScale, L["Resource_Scale"], L["Tooltip_Resource_Scale_Desc"])
    CreateResetButton(nameplateResourceScale, "nameplateResourceScale", guiCVarControl)
    notWorking(nameplateResourceScale, true)

    local nameplateResourceXPos = CreateSlider(guiCVarControl, L["X_Offset"], -100, 100, 1, "nameplateResourceXPos", "X")
    nameplateResourceXPos:SetPoint("TOPLEFT", nameplateResourceScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceXPos, L["Nameplate_Resource_X_Position"], L["Tooltip_Nameplate_Resource_X_Position_Desc"])
    CreateResetButton(nameplateResourceXPos, "nameplateResourceXPos", guiCVarControl)
    notWorking(nameplateResourceXPos, true)

    local nameplateResourceYPos = CreateSlider(guiCVarControl, L["Y_Offset"], -100, 100, 1, "nameplateResourceYPos", "Y")
    nameplateResourceYPos:SetPoint("TOPLEFT", nameplateResourceXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceYPos, L["Nameplate_Resource_Y_Position"], L["Tooltip_Nameplate_Resource_Y_Position_Desc"])
    CreateResetButton(nameplateResourceYPos, "nameplateResourceYPos", guiCVarControl)
    notWorking(nameplateResourceYPos, true)

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", L["Dark_Mode"], guiCVarControl, nil, BBP.DarkModeNameplateResources)
    darkModeNameplateResource:SetPoint("TOPLEFT", nameplateResourceYPos, "BOTTOMLEFT", -12, -4)
    CreateTooltipTwo(darkModeNameplateResource, L["Resource_Dark_Mode"], L["Tooltip_Resource_Dark_Mode_Desc"])
    notWorking(darkModeNameplateResource, true)

    local darkModeNameplateColor = CreateSlider(darkModeNameplateResource, L["Darkness_Amount"], 0, 1, 0.01, "darkModeNameplateColor")
    darkModeNameplateColor:SetPoint("TOPLEFT", darkModeNameplateResource, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(darkModeNameplateColor, L["How_Dark_You_Want_Nameplate_Resource"])
    notWorking(darkModeNameplateColor, true)

    darkModeNameplateResource:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeNameplateResource)
    end)

    if C_CVar.GetCVar("nameplateSimplifiedScale") then
        local nameplateSimplifiedScale = CreateSlider(guiCVarControl, L["Simplified_Scale"], 0.3, 1, 0.01, "nameplateSimplifiedScale")
        nameplateSimplifiedScale:SetPoint("TOPLEFT", darkModeNameplateColor, "BOTTOMLEFT", 0, -20)
        CreateTooltipTwo(nameplateSimplifiedScale, L["Simplified_Scale"], L["Tooltip_Simplified_Scale_Desc"], L["Tooltip_Simplified_Scale_SubText"], nil, "nameplateSimplifiedScale")
        CreateResetButton(nameplateSimplifiedScale, "nameplateSimplifiedScale", guiCVarControl)
    end

    local disableCVarForceOnLogin = CreateCheckbox("disableCVarForceOnLogin", L["Disable_All_CVar_Forcing"], guiCVarControl)
    disableCVarForceOnLogin:SetPoint("BOTTOM", guiCVarControl, "BOTTOM", -disableCVarForceOnLogin.Text:GetStringWidth() / 2 - 30, -5)
    CreateTooltipTwo(disableCVarForceOnLogin, L["Disable_All_CVar_Forcing"], L["Tooltip_Disable_All_CVar_Forcing_2_Desc"], L["Tooltip_Disable_All_CVar_Forcing_2_SubText_2"])

    local avoidCVarPickup = CreateCheckbox("avoidCVarPickup", L["Avoid_CVar_Pickup"], guiCVarControl)
    avoidCVarPickup:SetPoint("BOTTOMLEFT", disableCVarForceOnLogin, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(avoidCVarPickup, L["Avoid_CVar_Pickup"], L["Tooltip_Avoid_CVar_Pickup_Desc"])

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

    local nameplateSelectedAlpha = CreateSlider(guiCVarControl, L["Target_Alpha"], 0, 1, 0.01, "nameplateSelectedAlpha")
    nameplateSelectedAlpha:SetPoint("TOPLEFT", nameplateOccludedAlphaMult, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateSelectedAlpha, L["Target_Alpha"], L["Tooltip_Target_Alpha_Desc"], nil, nil, "nameplateSelectedAlpha")
    CreateResetButton(nameplateSelectedAlpha, "nameplateSelectedAlpha", guiCVarControl)

    local nameplateNotSelectedAlpha = CreateSlider(guiCVarControl, L["Non_Target_Alpha"], 0, 1, 0.01, "nameplateNotSelectedAlpha")
    nameplateNotSelectedAlpha:SetPoint("TOPLEFT", nameplateSelectedAlpha, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateNotSelectedAlpha, L["Non_Target_Alpha"], L["Tooltip_Non_Target_Alpha_Desc"], nil, nil, "nameplateNotSelectedAlpha")
    CreateResetButton(nameplateNotSelectedAlpha, "nameplateNotSelectedAlpha", guiCVarControl)

    local nameplateCVarText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateCVarText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 400, -310)
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
            if entry and not entry.root and not entry.stack and not entry.short and not entry.simplify and BBP.NameplateToggleEntryAvailable(entry) and set[entry.key] then
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
                    local isNeutralEntry = entry.neutral
                    checkbox:AddInitializer(function(button)
                        if isNeutralEntry then
                            button.fontString:SetTextColor(1, 1, 1)
                        elseif isEnemyEntry then
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
    cbCVars["nameplateResourceOnTarget"] = nameplateResourceOnTarget
    cbCVars["nameplateMotion"] = nameplateMotion
    cbCVars["nameplateShowAll"] = nameplateShowAll

    local sliderCVars = {}
    sliderCVars["nameplateMotionSpeed"] = nameplateMotionSpeed
    sliderCVars["nameplateMinAlpha"] = nameplateMinAlpha
    sliderCVars["nameplateMinAlphaDistance"] = nameplateMinAlphaDistance
    sliderCVars["nameplateMaxAlpha"] = nameplateMaxAlpha
    sliderCVars["nameplateMaxAlphaDistance"] = nameplateMaxAlphaDistance
    sliderCVars["nameplateOccludedAlphaMult"] = nameplateOccludedAlphaMult
    sliderCVars["nameplateSelectedAlpha"] = nameplateSelectedAlpha
    sliderCVars["nameplateNotSelectedAlpha"] = nameplateNotSelectedAlpha

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
                -- elseif cvarName == "nameplateStackingTypes" then
                --     -- Sync bitfield checkbox UI
                --     local enemyVal = C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy)
                --     local friendlyVal = C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly)
                --     nameplateStackingEnemy:SetChecked(enemyVal and true or false)
                --     nameplateStackingFriendly:SetChecked(friendlyVal and true or false)
                --     CheckAndToggleCheckboxes(nameplateStackingEnemy)
                end
            end
        end)
    end)


    --local moreBlizzSettingsText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    --moreBlizzSettingsText:SetPoint("BOTTOM", guiCVarControl, "BOTTOM", 0, 10)
    --moreBlizzSettingsText:SetText("Work in progress, more stuff inc soon™\n \nSome settings don't make much sense anymore because\nthe addon grew a bit more than I thought it would.\nWill clean up eventually\n \nIf you have any suggestions feel free to\nleave a comment on CurseForge")
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

    local stackingSliders = {stackingHorizontalOffset, stackingVerticalOffset, stackingHorizontalOffsetReset, stackingVerticalOffsetReset,stackingVerticalAdjustmentOffset,stackingVerticalAdjustmentOffsetReset, nameplateOverlapH, nameplateOverlapHReset, nameplateOverlapV, nameplateOverlapVReset}
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
    clickingText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -295)
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
    castbarText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -430)
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
        CreateTooltipTwo(fitCastIconLeftOfCast, L["Fit_Cast_Icon_On_The_Left"], L["Tooltip_Fit_Cast_Icon_On_The_Left_Desc"])
    end

    -- local fitCastIconLeftOfCastAndHp = CreateCheckbox("fitCastIconLeftOfCastAndHp", "Fit Cast Icon Left of Bars", guiClickNStack)
    -- fitCastIconLeftOfCastAndHp:SetPoint("TOPLEFT", fitCastIconLeftOfCast, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(fitCastIconLeftOfCastAndHp, "Fit Cast Icon Left of Bars", "Position the castbar icon on the left side of the health bar and cast bar, stretching from the bottom of the cast bar to the top of the health bar.")

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
        CreateTooltipTwo(guiTotemList.totemIndicator, L["Totem_Indicator"] .. " |T"..BBP.TotemIndicatorIcon..":22:22:0:0|t", L["Tooltip_Totem_Indicator_2_Desc_2"])
    else
        CreateTotemListElements()
    end
end

local function CreateGuiFontSection(parent, anchor)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 12, -24)
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
            guildNameOptionsFrame = CreateFrame("Frame", "BBPGuildNameOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            guildNameOptionsFrame.name = guiMisc.name
            guildNameOptionsFrame:SetSize(250, 296)
            guildNameOptionsFrame:SetPoint("CENTER")
            guildNameOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            guildNameOptionsFrame:SetFrameLevel(550)
            guildNameOptionsFrame:SetMovable(true)
            guildNameOptionsFrame:EnableMouse(true)
            guildNameOptionsFrame:RegisterForDrag("LeftButton")
            guildNameOptionsFrame:SetScript("OnDragStart", guildNameOptionsFrame.StartMoving)
            guildNameOptionsFrame:SetScript("OnDragStop", guildNameOptionsFrame.StopMovingOrSizing)
            guildNameOptionsFrame.title = guildNameOptionsFrame:CreateFontString(nil, "OVERLAY")
            guildNameOptionsFrame.title:SetFontObject("GameFontHighlight")
            guildNameOptionsFrame.title:SetPoint("LEFT", guildNameOptionsFrame.TitleBg, "LEFT", 5, 0)
            guildNameOptionsFrame.title:SetText(L["Guild_Name_Options"])

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

    local npcTitleScale = CreateSlider(guiMisc, L["NPC_Title_Size"], 0.2, 2, 0.01, "npcTitleScale")
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

    local friendIndicator = CreateCheckbox("friendIndicator", L["Friend_Guildie_Indicator"], guiMisc)
    friendIndicator:SetPoint("TOPLEFT", npcTitleColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendIndicator, L["Tooltip_Places_A_Little_Icon_To_The"])

    local anonMode = CreateCheckbox("anonMode", L["Anon_Mode"], guiMisc)
    anonMode:SetPoint("TOPLEFT", friendIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anonMode, L["Tooltip_Changes_The_Names_Of_Players_To"])

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

    local forceClassColors = CreateCheckbox("forceClassColors", L["Force_Class_Colors"], guiMisc, nil, BBP.RefreshAllNameplates)
    forceClassColors:SetPoint("TOPLEFT", showLastNameNpc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(forceClassColors, L["Force_Class_Colors"], L["Tooltip_Force_Class_Colors_Desc"])

    local scaleNpNameWithParent = CreateCheckbox("scaleNpNameWithParent", L["Scale_Names_With_The_Nameplate"], guiMisc)
    scaleNpNameWithParent:SetPoint("TOPLEFT", forceClassColors, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(scaleNpNameWithParent, L["Scale_Names_With_The_Nameplate"], L["Tooltip_Scale_Names_With_The_Nameplate_Desc"])

    if BBP.isEra then
        guiMisc.colorShamansBlue = CreateCheckbox("colorShamansBlue", L["Color_Shamans_Blue"], guiMisc)
        guiMisc.colorShamansBlue:SetPoint("TOPLEFT", scaleNpNameWithParent, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        CreateTooltipTwo(guiMisc.colorShamansBlue, L["Color_Shamans_Blue"], L["Tooltip_Color_Shamans_Blue_Desc"])
    end

    -- local nameplateResourceText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- nameplateResourceText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 45, -250)
    -- nameplateResourceText:SetText("Nameplate Resource")

    -- local nameplateSelfWidth = CreateSlider(guiMisc, "Personal Nameplate Width", 50, 200, 1, "nameplateSelfWidth")
    -- nameplateSelfWidth:SetPoint("TOPLEFT", doNotHideFriendlyHealthbarInPve, "BOTTOMLEFT", 10, -20)





    local changeHealthbarHeight = CreateCheckbox("changeHealthbarHeight", L["Separate_Friendly_Enemy_Nameplate_Height"], guiMisc)
    changeHealthbarHeight:SetPoint("TOPLEFT", guiMisc.colorShamansBlue or scaleNpNameWithParent, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(changeHealthbarHeight, L["Separate_Nameplate_Heights"], L["Tooltip_Separate_Nameplate_Heights_Desc_2"], L["Tooltip_Separate_Nameplate_Heights_SubText"])


    local hpHeightEnemy = CreateSlider(changeHealthbarHeight, L["Enemy_Height"], 1, 35, 0.1, "hpHeightEnemy")
    hpHeightEnemy:SetPoint("TOPLEFT", changeHealthbarHeight, "BOTTOMLEFT", 10, -10)
    CreateTooltipTwo(hpHeightEnemy, L["Enemy_Height"], L["Tooltip_Enemy_Height_Desc"])
    local hpHeightEnemyReset = CreateResetButton(hpHeightEnemy, "hpHeightEnemy", guiMisc)
    CreateTooltipTwo(hpHeightEnemyReset, L["Reset_To_Default"], L["Tooltip_Reset_To_Default_Desc"])

    local hpHeightFriendly = CreateSlider(changeHealthbarHeight, L["Friendly_Height"], 1, 35, 0.1, "hpHeightFriendly")
    hpHeightFriendly:SetPoint("TOPLEFT", hpHeightEnemy, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(hpHeightFriendly, L["Friendly_Height"], L["Tooltip_Friendly_Height_Desc_2"])
    local hpHeightFriendlyReset = CreateResetButton(hpHeightFriendly, "hpHeightFriendly", guiMisc)
    CreateTooltipTwo(hpHeightFriendlyReset, L["Reset_To_Default"], L["Tooltip_Reset_To_Default_Desc"])

    CreateGuiFontSection(guiMisc, hpHeightFriendly)

    changeHealthbarHeight:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.HookHealthbarHeight()
            EnableElement(hpHeightEnemy)
            EnableElement(hpHeightFriendly)
        else
            DisableElement(hpHeightEnemy)
            DisableElement(hpHeightFriendly)
            --BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local customFontSizeEnabled = CreateCheckbox("customFontSizeEnabled", L["Enable_Custom_Nameplate_Font_Size"], guiMisc)
    customFontSizeEnabled:SetPoint("TOPLEFT", changeHealthbarHeight, "BOTTOMLEFT", 0, -120)
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

    local changeNameplateBorderSize = CreateCheckbox("changeNameplateBorderSize", L["Change_Nameplate_Border_Size"], guiMisc)
    changeNameplateBorderSize:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 340, -50)
    local nameplateBorderSize = CreateSlider(changeNameplateBorderSize, L["Nameplate_Border_Size"], 1, 10, 0.5, "nameplateBorderSize")
    nameplateBorderSize:SetPoint("TOPLEFT", changeNameplateBorderSize, "BOTTOMLEFT", 10, -10)
    local nameplateTargetBorderSize = CreateSlider(changeNameplateBorderSize, L["Target_Border_Size"], 1, 10, 0.5, "nameplateTargetBorderSize")
    nameplateTargetBorderSize:SetPoint("LEFT", nameplateBorderSize, "RIGHT", 10, 0)
    CreateTooltipTwo(nameplateBorderSize, L["Nameplate_Border_Size"], L["Tooltip_Nameplate_Border_Size_Desc"])
    changeNameplateBorderSize:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(nameplateBorderSize)
            EnableElement(nameplateTargetBorderSize)
        else
            DisableElement(nameplateBorderSize)
            DisableElement(nameplateTargetBorderSize)
            --BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)


    local changeNameplateBorderColor = CreateCheckbox("changeNameplateBorderColor", L["Change_Nameplate_Border_Color"], guiMisc)
    changeNameplateBorderColor:SetPoint("TOPLEFT", nameplateBorderSize, "BOTTOMLEFT", -10, -4)

    local npBorderDesaturate = CreateCheckbox("npBorderDesaturate", L["Desaturate"], guiMisc)
    npBorderDesaturate:SetPoint("LEFT", changeNameplateBorderColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(npBorderDesaturate, L["Desaturate_Border"], L["Tooltip_Desaturate_Border_Desc"])
    npBorderDesaturate:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            BBP.ShowPopup("BBP_CONFIRM_RELOAD")
        end
    end)

    local colorCastbarBorder = CreateCheckbox("colorCastbarBorder", L["Color_Castbar_Border"], changeNameplateBorderColor)
    colorCastbarBorder:SetPoint("TOPLEFT", changeNameplateBorderColor, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltipTwo(colorCastbarBorder, L["Color_Castbar_Border"], L["Tooltip_Color_Castbar_Border_Desc"])

    local npBorderTargetColor = CreateCheckbox("npBorderTargetColor", L["Target_Border"], changeNameplateBorderColor)
    npBorderTargetColor:SetPoint("TOPLEFT", colorCastbarBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(npBorderTargetColor, L["Tooltip_Enable_To_Change_The_Color_Of"])

    local npBorderTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderTargetColorRGB", L["Target_Border"])
    npBorderTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColor, "BOTTOMLEFT", 15, 0)

    local npBorderNonTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderNonTargetColorRGB", L["Non_Target_Border"])
    npBorderNonTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColorRGB, "BOTTOMLEFT", 0, -2)

    npBorderTargetColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBorderTargetColorRGB:SetAlpha(1)
            npBorderNonTargetColorRGB:SetAlpha(1)
        else
            npBorderTargetColorRGB:SetAlpha(0.5)
            npBorderNonTargetColorRGB:SetAlpha(0.5)
        end
    end)

    local npBorderFriendFoeColor = CreateCheckbox("npBorderFriendFoeColor", L["Reaction_Color_Border"], changeNameplateBorderColor)
    npBorderFriendFoeColor:SetPoint("TOPLEFT", npBorderNonTargetColorRGB, "BOTTOMLEFT", -15, 0)
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
        CheckAndToggleCheckboxes(npBorderTargetColor)
        CheckAndToggleCheckboxes(npBorderFriendFoeColor)
        CheckAndToggleCheckboxes(npBorderClassColor)
    end)

    local changeNpHpBgColor = CreateCheckbox("changeNpHpBgColor", L["Change_Nameplate_Background_Color"], guiMisc)
    changeNpHpBgColor:SetPoint("TOPLEFT", npBorderNpcColorRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltipTwo(changeNpHpBgColor, L["Nameplate_Background_Color"], L["Tooltip_Nameplate_Background_Color_Desc"])

    local npBgColorRGB = CreateColorBox(changeNpHpBgColor, "npBgColorRGB", L["Background_Color"])
    npBgColorRGB:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 15, 0)

    local changeNpHpBgColorSolid = CreateCheckbox("changeNpHpBgColorSolid", L["Solid"], guiMisc)
    changeNpHpBgColorSolid:SetPoint("LEFT", npBgColorRGB.text, "RIGHT", 2, 0)
    CreateTooltipTwo(changeNpHpBgColorSolid, L["Solid_Background_Color"], L["Tooltip_Solid_Background_Color_Desc"])

    changeNpHpBgColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBgColorRGB:SetAlpha(1)
        else
            npBgColorRGB:SetAlpha(0.5)
        end
    end)

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

    local totemIndicatorList = CreateImportExportUI(auraWhitelist, L["Totem_Indicator_List"], BetterBlizzPlatesDB.totemIndicatorNpcList, 0, -100, "totemIndicatorNpcList")

    local fadeOutNPCsList = CreateImportExportUI(totemIndicatorList, L["Fade_NPC_List"], BetterBlizzPlatesDB.fadeOutNPCsList, 0, -100, "fadeOutNPCsList")
    local hideNpcList = CreateImportExportUI(fadeOutNPCsList, L["Hide_NPC_Blacklist"], BetterBlizzPlatesDB.hideNPCsList, 210, 0, "hideNPCsList")
    local hideNPCsWhitelist = CreateImportExportUI(hideNpcList, L["Hide_NPC_Whitelist"], BetterBlizzPlatesDB.hideNPCsWhitelist, 210, 0, "hideNPCsWhitelist")

    local castEmphasisList = CreateImportExportUI(fadeOutNPCsList, L["Cast_Emphasis_List"], BetterBlizzPlatesDB.castEmphasisList, 0, -100, "castEmphasisList")
    local hideCastbarList = CreateImportExportUI(castEmphasisList, L["Hide_Castbar_Blacklist"], BetterBlizzPlatesDB.hideCastbarList, 210, 0, "hideCastbarList")
    local hideCastbarWhitelist = CreateImportExportUI(hideCastbarList, L["Hide_Castbar_Whitelist"], BetterBlizzPlatesDB.hideCastbarWhitelist, 210, 0, "hideCastbarWhitelist")

    local colorNpcList = CreateImportExportUI(castEmphasisList, L["Color_NPC_List"], BetterBlizzPlatesDB.colorNpcList, 0, -100, "colorNpcList")
    local auraColorList = CreateImportExportUI(colorNpcList, L["Color_By_Aura_List"], BetterBlizzPlatesDB.auraColorList, 210, 0, "auraColorList")

    local text2 = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text2:SetText(L["Color_NPC_And_Cast_Emphasis_Now_Supports_Plater"])
    text2:SetPoint("LEFT", totemIndicatorList, "RIGHT", 60, 0)
end
------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
local function CombatOnGUICreation()
    if InCombatLockdown() then
        BBP.Print(L["Print_Leave_Combat_To_Open_Settings_For"])
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
    guiPositionAndScale()
    guiClickingAndStacking()
    guiCastbar()
    guiHideCastbar()
    guiFadeNPC()
    guiHideNPC()
    guiColorNPC()
    guiAuraColor()
    guiNameplateAuras()
    guiCVarControl()
    guiMisc()
    guiImportAndExport()
    guiTotemList()
    guiSupport()
    BetterBlizzPlates.guiLoaded = true

    if SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end
    Settings.OpenToCategory(BBP.category:GetID())
    Settings.OpenToCategory(BBP.category:GetID())
end

function BBP.CVarTracker()
    if BBP.cvarTrackerRegistered then return end
    BBP.cvarTrackerRegistered = true

    local cvarsToTrack = {
        checkboxes = {
            nameplateResourceOnTarget = true,
            nameplateShowAll = true,
        },
        sliders = {
            nameplateOverlapH = true,
            nameplateOverlapV = true,
            --nameplateMotionSpeed = true,
            nameplateMinAlpha = true,
            nameplateMinAlphaDistance = true,
            nameplateMaxAlpha = true,
            nameplateMaxAlphaDistance = true,
            nameplateOccludedAlphaMult = true,
            -- Midnight
            nameplateDebuffPadding = true,
            nameplateAuraScale = true,
            nameplateSimplifiedScale = true,
        },
        other = {
            nameplateStyle = true,
            nameplateSize = true,
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
        nameplateSimplifiedTypes = true,
        nameplateAuraScale = true,
    }
    pickupProtected.nameplateUseClassColorForFriendlyPlayerUnitNames = true
    for cvarName in pairs(BBP.nameplateToggleCVarLookup) do
        pickupProtected[cvarName] = true
    end

    if BetterBlizzPlatesDB.disableCVarForceOnLogin and not BetterBlizzPlatesDB.avoidCVarPickup then
        BetterBlizzPlatesDB.friendlyClassColorName = C_CVar.GetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames") == "1"
    end

    local cvarListener = CreateFrame("Frame")
    cvarListener:RegisterEvent("CVAR_UPDATE")
    cvarListener:SetScript("OnEvent", function(self, event, cvarName, cvarValue)
        if BBP.CVarTrackingDisabled then return end
        if BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater") then return end
        if BetterBlizzPlatesDB.avoidCVarPickup and pickupProtected[cvarName] then return end

        if BBP.SaveNameplateToggleCVar(cvarName, cvarValue) then
            -- handled: stored against the active PvP/PvE set
        elseif cvarName == "nameplateUseClassColorForFriendlyPlayerUnitNames" then
            BetterBlizzPlatesDB.friendlyClassColorName = cvarValue == "1"
            if BBP.friendlyClassColorNameCheckbox then
                BBP.friendlyClassColorNameCheckbox:SetChecked(cvarValue == "1")
            end
            BBP.RefreshAllNameplates()
        elseif cvarsToTrack.checkboxes[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
        elseif cvarsToTrack.sliders[cvarName] then
            BetterBlizzPlatesDB[cvarName] = tonumber(cvarValue)
        elseif cvarsToTrack.other[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
        elseif bitCVarNames[cvarName] then
            local bitfields = BetterBlizzPlatesDB.bitfields
            if bitfields and bitfields[cvarName] then
                for _, index in ipairs(BBP.bitCVarList[cvarName]) do
                    bitfields[cvarName][tostring(index)] = C_CVar.GetCVarBitfield(cvarName, index)
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
    BBP.IntroMessageWindow:SetTitle("Better|cff00c0ffBlizz|rPlates v"..BBP.VersionNumber)
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
        local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, string.format(L["Profile_Name_Title"], profileName == "Starter" and L["Starter"] or profileName))
        local confirmationText = titleText .. string.format(L["Popup_Intro_Profile_Confirm"], profileText, noteText)
        BBP.GetPopup("BBP_CONFIRM_PROFILE").text = confirmationText
        BBP.ShowPopup("BBP_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
    end

    -- Create button for your profile
    local starterButton = CreateClassButton(BBP.IntroMessageWindow, "STARTER", "Starter", nil, function()
        ShowProfileConfirmation("Starter", "STARTER", BBP.StarterProfile)
    end)
    starterButton:SetPoint("TOP", description1, "BOTTOM", 0, -20)

    local blitzButton = CreateClassButton(BBP.IntroMessageWindow, "BLITZ", "Blitz", nil, function()
        ShowProfileConfirmation("Blitz", "BLITZ", BBP.BlitzProfile)
    end)
    blitzButton:SetPoint("TOP", starterButton, "BOTTOM", 0, btnGap)

    local minimalButton = CreateClassButton(BBP.IntroMessageWindow, "MINIMAL", "Minimal", nil, function()
        ShowProfileConfirmation("Minimal", "MINIMAL", BBP.MinimalProfile)
    end)
    minimalButton:SetPoint("TOP", blitzButton, "BOTTOM", 0, btnGap)

    -- local mythicButton = CreateClassButton(BBP.IntroMessageWindow, "MYTHIC", "Mythic", nil, function()
    --     ShowProfileConfirmation("Mythic", "MYTHIC", BBP.MythicProfile)
    -- end)
    -- mythicButton:SetPoint("TOP", blitzButton, "BOTTOM", 0, btnGap)

    local orText = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText:SetPoint("CENTER", minimalButton, "BOTTOM", 0, -20)
    orText:SetText("OR")
    orText:SetJustifyH("CENTER")

    -- local aeghisButton = CreateClassButton(BBP.IntroMessageWindow, "MAGE", "Aeghis", "aeghis", function()
    --     ShowProfileConfirmation("Aeghis", "MAGE", BBP.AeghisProfile)
    -- end)
    -- aeghisButton:SetPoint("TOP", mythicButton, "BOTTOM", 0, -40)

    -- local kalvishButton = CreateClassButton(BBP.IntroMessageWindow, "ROGUE", "Kalvish", "kalvish", function()
    --     ShowProfileConfirmation("Kalvish", "ROGUE", BBP.KalvishProfile)
    -- end)
    -- kalvishButton:SetPoint("TOP", aeghisButton, "BOTTOM", 0, btnGap)

    -- local magnuszButton = CreateClassButton(BBP.IntroMessageWindow, "WARRIOR", "Magnusz", "magnusz", function()
    --     ShowProfileConfirmation("Magnusz", "WARRIOR", BBP.MagnuszProfile)
    -- end)
    -- magnuszButton:SetPoint("TOP", kalvishButton, "BOTTOM", 0, btnGap)

    -- local mmarkersButton = CreateClassButton(BBP.IntroMessageWindow, "DRUID", "Mmarkers", "mmarkers", function()
    --     ShowProfileConfirmation("Mmarkers", "DRUID", BBP.MmarkersProfile)
    -- end)
    -- mmarkersButton:SetPoint("TOP", magnuszButton, "BOTTOM", 0, btnGap)

    local aeghisButton = CreateClassButton(BBP.IntroMessageWindow, "MAGE", "Aeghis", "aeghis", function()
        ShowProfileConfirmation("Aeghis", "MAGE", BBP.AeghisProfile)
    end)
    aeghisButton:SetPoint("TOP", minimalButton, "BOTTOM", 0, -40)

    local mmarkersButton = CreateClassButton(BBP.IntroMessageWindow, "DRUID", "Mmarkers", "mmarkers", function()
        ShowProfileConfirmation("Mmarkers", "DRUID", BBP.MmarkersProfile)
    end)
    mmarkersButton:SetPoint("TOP", aeghisButton, "BOTTOM", 0, btnGap)

    local nahjButton = CreateClassButton(BBP.IntroMessageWindow, "ROGUE", "Nahj", "nahj", function()
        ShowProfileConfirmation("Nahj", "ROGUE", BBP.NahjProfile)
    end)
    nahjButton:SetPoint("TOP", mmarkersButton, "BOTTOM", 0, btnGap)

    local saulButton = CreateClassButton(BBP.IntroMessageWindow, "SHAMAN", "Saul", "saul", function()
        ShowProfileConfirmation("Saul", "SHAMAN", BBP.SaulProfile)
    end)
    saulButton:SetPoint("TOP", nahjButton, "BOTTOM", 0, btnGap)

    local snupyButton = CreateClassButton(BBP.IntroMessageWindow, "DRUID", "Snupy", "snupy", function()
        ShowProfileConfirmation("Snupy", "DRUID", BBP.SnupyProfile)
    end)
    snupyButton:SetPoint("TOP", saulButton, "BOTTOM", 0, btnGap)

    local orText2 = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText2:SetPoint("CENTER", snupyButton, "BOTTOM", 0, -20)
    orText2:SetText("OR")
    orText2:SetJustifyH("CENTER")

    local buttonLast = CreateFrame("Button", nil, BBP.IntroMessageWindow, "GameMenuButtonTemplate")
    buttonLast:SetSize(btnWidth, btnHeight)
    buttonLast:SetText(L["Exit_No_Profile"])
    buttonLast:SetPoint("TOP", snupyButton, "BOTTOM", 0, -40)
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
        local baseHeight = 334
        local perButtonHeight = 29
        local buttonCount = -1
        for _, child in ipairs({BBP.IntroMessageWindow:GetChildren()}) do
            if child and child:IsObjectType("Button") then
                buttonCount = buttonCount + 1
            end
        end
        local newHeight = baseHeight + (buttonCount * perButtonHeight)
        BBP.IntroMessageWindow:SetSize(470, newHeight)
    end
    AdjustWindowHeight()
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
