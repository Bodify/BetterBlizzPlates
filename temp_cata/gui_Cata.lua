BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
local LSM = LibStub("LibSharedMedia-3.0")
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

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
local sliderList = {}

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

local tooltips = {
    ["5: Replace name with spec + ID on same row"] = "Shows as for example \"Frost 2\"",
    ["Off"] = "Turn the functionaly off and just use normal names",
}

local modes = {
    ["1: Replace name with Arena ID"] = "arenaIndicatorModeOne",
    ["2: Arena ID on top of name"] = "arenaIndicatorModeTwo",
    ["3: Replace name with spec"] = "arenaIndicatorModeThree",
    ["4: Replace name with spec + ID on top"] = "arenaIndicatorModeFour",
    ["5: Replace name with spec + ID on same row"] = "arenaIndicatorModeFive",
    ["Off"] = "arenaIndicatorModeOff",
}

local tooltipsParty = {
    ["5: Replace name with spec + ID on same row"] = "Shows as for example \"Frost 2\"",
    ["Off"] = "Turn the functionaly off and just use normal names",
}

local modesParty = {
    ["1: Replace name with Arena ID"] = "partyIndicatorModeOne",
    ["2: Arena ID on top of name"] = "partyIndicatorModeTwo",
    ["3: Replace name with spec"] = "partyIndicatorModeThree",
    ["4: Replace name with spec + ID on top"] = "partyIndicatorModeFour",
    ["5: Replace name with spec + ID on same row"] = "partyIndicatorModeFive",
    ["Off"] = "partyIndicatorModeOff",
}
StaticPopupDialogs["BBP_CONFIRM_RELOAD"] = {
    text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: \n\nThis requires a reload. Reload now?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBP_CONFIRM_PROFILE"] = {
    text = "",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self)
        if self.data and self.data.func then
            self.data.func()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBP_TOTEMLIST_RESET"] = {
    text = "This will delete the entire totem list and reset it back to its default state.\nA reload will be neccesary.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBP.ResetTotemList()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBP_UPDATE_NOTIF"] = {
    text = "|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates Cata Beta v0.1.1b:\n\nFixed Retail-look Nameplate Height Slider. You might have to re-adjust/reset it back to 1.",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBP_RETAILORCLASSIC"] = {
    text = "Welcome to Better|cff00c0ffBlizz|rPlates\n\nWould you like to keep the retail nameplate look or reload and switch to classic nameplates?",
    button1 = "Keep Retail",
    button2 = "Switch to Classic",
    OnCancel = function()
        BetterBlizzPlatesDB.classicNameplates = true
        BetterBlizzPlatesDB.nameplateEnemyWidth = 128
        BetterBlizzPlatesDB.nameplateFriendlyWidth = 128
        BetterBlizzPlatesDB.castBarHeight = 10
        BetterBlizzPlatesDB.hideLevelFrame = false
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
}

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
    resetButton:SetText("Default")
    resetButton:SetWidth(60)
    resetButton:SetPoint("LEFT", relativeTo, "RIGHT", 10, 0)
    resetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(relativeTo, settingKey)
        BBP.needsUpdate = true
    end)
    return resetButton
end

local function CreateModeDropdown(name, parent, defaultText, settingKey, toggleFunc, point, modes, tooltips, textLabel, textColor)
    -- Create the dropdown frame using the library's creation function
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, 135)
    LibDD:UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    -- Initialize the dropdown using the library's initialize function
    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        local orderedKeys = {}

        for displayText, _ in pairs(modes) do
            table.insert(orderedKeys, displayText)
        end

        local dropdownTextFontString = _G[dropdown:GetName() .. "Text"]
        if dropdownTextFontString then
            dropdownTextFontString:SetTextColor(1, 1, 0)
        end

        table.sort(orderedKeys)

        for _, displayText in ipairs(orderedKeys) do
            local dbKey = modes[displayText]
            info.text = displayText
            info.arg1 = dbKey
            info.func = function(self, arg1, arg2, checked)
                -- Set the selected mode to true and all others to false
                for _, dbKeyIter in pairs(modes) do
                    BetterBlizzPlatesDB[dbKeyIter] = (dbKeyIter == arg1)
                end
                -- Store the selected mode's display text
                BetterBlizzPlatesDB[settingKey] = displayText

                LibDD:UIDropDownMenu_SetText(dropdown, displayText)
                BBP.needsUpdate = true
                toggleFunc(displayText)
            end
            info.checked = (BetterBlizzPlatesDB[settingKey] == displayText)

            -- Color dropdown text
            info.colorCode = "|cFFFFFF00"

            -- Setting tooltip for specific menu items
            if tooltips[displayText] then
                info.tooltipTitle = displayText
                info.tooltipText = tooltips[displayText]
                info.tooltipOnButton = true
            else
                info.tooltipTitle = nil
                info.tooltipText = nil
                info.tooltipOnButton = nil
            end

            LibDD:UIDropDownMenu_AddButton(info)
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
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, 135)
    LibDD:UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    dropdown.initialize = function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        local fonts = LSM:HashTable(LSM.MediaType.FONT)
        local sortedFonts = {}

        -- Extract and sort font names
        for fontName in pairs(fonts) do
            table.insert(sortedFonts, fontName)
        end
        table.sort(sortedFonts)

        -- If level 1, create categories
        if level == 1 then
            local categorySize = 12  -- Number of items per category
            local numFonts = #sortedFonts

            for i = 1, math.ceil(numFonts / categorySize) do
                info.hasArrow = true
                info.notCheckable = true
                info.checked = nil
                info.text = "Fonts " .. i
                info.icon = nil
                info.menuList = i
                info.func = nil
                info.arg1 = nil
                LibDD:UIDropDownMenu_AddButton(info)
            end
        -- If level 2, add items to the selected category
        elseif level == 2 then
            local categorySize = 12
            local startIndex = (menuList - 1) * categorySize + 1
            local endIndex = startIndex + categorySize - 1

            for i = startIndex, math.min(endIndex, #sortedFonts) do
                local fontName = sortedFonts[i]
                local fontPath = fonts[fontName]
                info.hasArrow = nil
                info.notCheckable = nil
                info.checked = (BetterBlizzPlatesDB[settingKey] == fontName)
                info.text = fontName
                info.arg1 = fontName
                info.func = function(_, arg1)
                    BetterBlizzPlatesDB[settingKey] = arg1
                    LibDD:UIDropDownMenu_SetText(dropdown, arg1)
                    BBP.needsUpdate = true
                    toggleFunc(fontPath)
                    dropdown.Text:SetFont(fontPath, 12)
                    LibDD:CloseDropDownMenus()
                end
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end

    local fontName = BetterBlizzPlatesDB.customFont
    local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
    dropdown.Text:SetFont(fontPath, 12)
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    if parent:GetObjectType() == "CheckButton" and not parent:GetChecked() then
        LibDD:UIDropDownMenu_DisableDropDown(dropdown)
    else
        LibDD:UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateTextureDropdown(name, parent, defaultText, settingKey, toggleFunc, point, dropdownWidth)
    -- Create the dropdown frame
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, dropdownWidth or 135)
    LibDD:UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    -- Define the initialize function
    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        local textures = LSM:HashTable(LSM.MediaType.STATUSBAR)
        local sortedTextures = {}

        -- Extract and sort texture names
        for textureName in pairs(textures) do
            table.insert(sortedTextures, textureName)
        end
        table.sort(sortedTextures)

        -- If level 1, create categories
        if level == 1 then
            local categorySize = 12  -- Number of items per category
            local numTextures = #sortedTextures

            for i = 1, math.ceil(numTextures / categorySize) do
                info.hasArrow = true
                info.notCheckable = true
                info.checked = nil
                info.text = "Textures " .. i
                info.icon = nil
                info.menuList = i
                info.func = nil
                info.arg1 = nil
                LibDD:UIDropDownMenu_AddButton(info)
            end
        -- If level 2, add items to the selected category
        elseif level == 2 then
            local categorySize = 12
            local startIndex = (menuList - 1) * categorySize + 1
            local endIndex = startIndex + categorySize - 1

            for i = startIndex, math.min(endIndex, #sortedTextures) do
                local textureName = sortedTextures[i]
                local texturePath = textures[textureName]
                info.hasArrow = nil
                info.notCheckable = nil
                info.checked = (BetterBlizzPlatesDB[settingKey] == textureName)
                info.text = textureName
                info.icon = texturePath
                info.menuList = nil
                info.func = function(_, arg1)
                    BetterBlizzPlatesDB[settingKey] = arg1
                    LibDD:UIDropDownMenu_SetText(dropdown, arg1)
                    BBP.needsUpdate = true
                    toggleFunc(texturePath)
                    LibDD:CloseDropDownMenus()
                end
                info.arg1 = textureName
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Position the dropdown
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    -- Enable or disable based on parent's check state
    if parent:GetObjectType() == "CheckButton" and not parent:GetChecked() then
        LibDD:UIDropDownMenu_DisableDropDown(dropdown)
    else
        LibDD:UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point, width, textColor, anchorTypes)
    -- Create the dropdown frame using the library's creation function
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, width or 125)
    LibDD:UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    local anchorPointsToUse = anchorTypes or anchorPoints
    if name == "targetIndicatorDropdown" then
        anchorPointsToUse = targetIndicatorAnchorPoints
    end

    -- Initialize the dropdown using the library's initialize function
    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        for _, anchor in ipairs(anchorPointsToUse) do
            info.text = anchor
            info.arg1 = anchor
            info.func = function(self, arg1)
                if BetterBlizzPlatesDB[settingKey] ~= arg1 then
                    BetterBlizzPlatesDB[settingKey] = arg1
                    LibDD:UIDropDownMenu_SetText(dropdown, arg1)
                    BBP.needsUpdate = true
                    toggleFunc(arg1)
                    BBP.RefreshAllNameplates()
                end
            end
            info.checked = (BetterBlizzPlatesDB[settingKey] == anchor)
            LibDD:UIDropDownMenu_AddButton(info)
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

    -- Enable or disable the dropdown based on the parent's check state
    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        LibDD:UIDropDownMenu_DisableDropDown(dropdown)
    else
        LibDD:UIDropDownMenu_EnableDropDown(dropdown)
    end

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
        category = "General"
    end

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
    editBox:SetFrameStrata("DIALOG")
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
                            if axis then
                                local yOffset = BetterBlizzPlatesDB.castBarDragonflightShield and -2 or 0
                                frame.CastBar.Icon:ClearAllPoints()
                                frame.CastBar.Icon:SetPoint("CENTER", frame.CastBar, "LEFT", xPos, yPos)
                                frame.CastBar.BorderShield:ClearAllPoints()
                                frame.CastBar.BorderShield:SetPoint("CENTER", frame.CastBar.Icon, "CENTER", 0, 0)
                            else
                                BetterBlizzPlatesDB.castBarIconScale = value
                                frame.CastBar.Icon:SetScale(value)
                                frame.CastBar.BorderShield:SetScale(value)
                            end
                        -- Cast bar height
                        elseif element == "castBarHeight" then
                            frame.CastBar:SetHeight(value)
                            if BetterBlizzPlatesDB.classicNameplates then
                                frame.CastBar.UpdateBorders()
                            end
                        elseif element == "castBarTextScale" then
                            frame.CastBar.castText:SetScale(value)
                        -- Cast bar emphasis icon pos and scale
                        elseif element == "castBarEmphasisIconXPos" or element == "castBarEmphasisIconYPos" then
                            if axis then
                                frame.CastBar.Icon:SetPoint("CENTER", frame.CastBar, "LEFT", xPos, yPos)
                            end
                        elseif element == "nameplateGeneralHeight" then
                            if not frame.greenScreened then
                                BBP.greenScreen(namePlate)
                                frame.greenScreened = true
                            end
                            if not BBP.checkCombatAndWarn() then
                                BBP.ApplyNameplateWidth()
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
                if element == "NamePlateVerticalScale" then
                    BetterBlizzPlatesDB.NamePlateVerticalScale = value
                    if not BBP.checkCombatAndWarn() then
                        BBP.ApplyNameplateWidth()
                    end
                elseif element == "nameplateExtraClickHeight" then
                    BetterBlizzPlatesDB.nameplateExtraClickHeight = value
                    BBP.AdjustClickableNameplateHeight()
                elseif element == "nameplateVerticalPosition" then
                    BetterBlizzPlatesDB.nameplateVerticalPosition = value
                    BBP.AdjustNameplateVerticalPosition()
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
                elseif element == "nameplateGeneralHeight" then
                    BetterBlizzPlatesDB.nameplateGeneralHeight = value
                    BBP.RefreshAllNameplates()
                    if not BBP.checkCombatAndWarn() then
                        BBP.ApplyNameplateWidth()
                    end
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
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateFriendlyWidth = value
                        -- local heightValue
                        -- if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
                        --     heightValue = 1
                        -- else
                        --     heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        -- end
                        local retailExtra = (not BetterBlizzPlatesDB.classicNameplates and 24) or 0
                        C_NamePlate.SetNamePlateFriendlySize(value + retailExtra, 32)
                        BBP.RefreshAllNameplates()
                    end
                elseif element == "nameplateEnemyWidth" then
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateEnemyWidth = value
                        -- local heightValue
                        -- heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        local retailExtra = (not BetterBlizzPlatesDB.classicNameplates and 24) or 0
                        C_NamePlate.SetNamePlateEnemySize(value + retailExtra, 32)
                        BBP.RefreshAllNameplates()
                    end
                elseif element == "nameplateSelfWidth" then
                    if not BBP.checkCombatAndWarn() then
                        BetterBlizzPlatesDB.nameplateSelfWidth = value
                        local heightValue
                        heightValue = 45 --BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        C_NamePlate.SetNamePlateSelfSize(value, heightValue)
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
                elseif element == "nameplateAuraTypeGap" then
                    BetterBlizzPlatesDB.nameplateAuraTypeGap = value
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
                        if frame.CastBar then
                            if not BetterBlizzPlatesDB.enableCastbarCustomization then
                                if BBP.isLargeNameplatesEnabled() then
                                    frame.CastBar:SetHeight(18.8)
                                else
                                    frame.CastBar:SetHeight(8)
                                end
                            else
                                frame.CastBar:SetHeight(BetterBlizzPlatesDB.castBarHeight)
                            end
                        end
                    end
                -- Nameplate Horizontal Overlap
                elseif element == "nameplateOverlapH" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateOverlapH", value)
                        BetterBlizzPlatesDB.nameplateOverlapH = value
                    end
                -- Nameplate Vertical Overlap
                elseif element == "nameplateOverlapV" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateOverlapV", value)
                        BetterBlizzPlatesDB.nameplateOverlapV = value
                    end
                -- Nameplate Motion Speed
                elseif element == "nameplateMotionSpeed" then
                    if not BBP.checkCombatAndWarn() then
                        C_CVar.SetCVar("nameplateMotionSpeed", value)
                        BetterBlizzPlatesDB.nameplateMotionSpeed = value
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
                            print("ArenaID test mode active, disable to adjust this slider")
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
                            print("ArenaID test mode active, disable to adjust this slider")
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
                elseif element == "guildNameScale" then
                    BetterBlizzPlatesDB.guildNameScale = value
                    BBP.RefreshAllNameplates()
                elseif element == "npcTitleScale" then
                    BetterBlizzPlatesDB.npcTitleScale = value
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
            finalTooltipText = finalTooltipText .. "\n\nThis controls the CVar: " .. cvarName
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
            GameTooltip:AddDoubleLine("Changes CVar:", cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
            if cvarName2 then
                GameTooltip:AddDoubleLine(" ", cvarName2, 0.2, 1, 0.6, 0.2, 1, 0.6)
            end
        end
        -- Add the current border type
        if title == "Shield" then
            local currentBorder = BetterBlizzPlatesDB["totemIndicatorShieldType"]
            local borderTypes = {
                "1:|A:nameplates-InterruptShield:24:20|a",
                "2:|A:transmog-frame-selected:24:24|a",
                "3:|A:ShipMission_ShipFollower-EquipmentFrame:22:22|a",
                "4:|A:GarrMission_EncounterAbilityBorder-Lg:29:29|a",
                "5:|A:Garr_Specialization_IconBorder:24:24|a"
            }
            local tooltipText = "|cff32f795Right-click to change border type.|r\n\nBorder types:\n"
            for i, border in ipairs(borderTypes) do
                if i == currentBorder then
                    tooltipText = tooltipText .. border .. " |A:ParagonReputation_Checkmark:15:15|a\n"
                else
                    tooltipText = tooltipText .. border .. "\n"
                end
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Hide Castbar Text" then
            local alsoHideInt = BetterBlizzPlatesDB.hideCastbarTextInt
            local tooltipText = "\n|cff32f795Right-click to also hide the \"Interrupted\" text|r"

            if alsoHideInt then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Center Auras on Enemy" then
            local centerBuffsOnly = BetterBlizzPlatesDB.nameplateCenterOnlyBuffs
            local tooltipText = "\n|cff32f795Right-click to only center Buffs.|r"

            if centerBuffsOnly then
                tooltipText = tooltipText .. "\n|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Sort Auras by Duration" then
            local tooltipText = "\n|cff32f795Right-click to reverse duration sort.|r"
            if BetterBlizzPlatesDB.sortDurationAurasReverse then
                tooltipText = tooltipText .. "\nReverse sorting|A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Purgeable" then
            local tooltipText = "\n|cff32f795Right-click to only show Purgeable in PvE.|r"
            if BetterBlizzPlatesDB.otherNpBuffFilterPurgeablePvEOnly then
                tooltipText = tooltipText .. "\nOnly in PvE enabled|A:ParagonReputation_Checkmark:15:15|a"
            end

            local onlyShowIfPurge = BetterBlizzPlatesDB.otherNpBuffFilterPurgeableHasPurge
            tooltipText = tooltipText.."\n\n|cff32f795Shift-Right-click to only show purgeable auras if you have a purge|r"

            if onlyShowIfPurge then
                tooltipText = tooltipText .. "\nOnly in show if have a purge|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if category then
            GameTooltip:AddLine("")
            GameTooltip:AddLine("|A:shop-games-magnifyingglass:17:17|a Setting located in "..category.." section.", 0.4, 0.8, 1, true)
        end
        GameTooltip:Show()
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
    CreateTooltipTwo(element, "Not Working", "Currently not working and disabled for "..(BBP.isMoP and "MoP" or BBP.isTBC and "TBC" or "Cata")..". May or may not be removed TBD.", "A lot of other features might also not work 100% in this Beta version. Keep an eye out for errors.")

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
        GameTooltip:AddDoubleLine("Changes CVar:", cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
        if cvarName2 then
            GameTooltip:AddDoubleLine(" ", cvarName2, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end
    end
    GameTooltip:Show()
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
}

-- Function to show the confirmation popup with dynamic profile information
local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
    local noteText = additionalNote or ""
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
    local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, profileName.." Profile")
    local confirmationText = titleText .. "This action will delete all settings and apply\nthe " .. profileText .. " and reload the UI.\n\n" .. noteText .. "Are you sure you want to continue?"

    StaticPopupDialogs["BBP_CONFIRM_PROFILE"].text = confirmationText
    StaticPopup_Show("BBP_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
end

local function CreateClassButton(parent, class, name, twitchName, onClickFunc)
    local bbpParent = parent == BetterBlizzPlates
    local btnWidth, btnHeight = bbpParent and 96 or 150, bbpParent and 22 or  30
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetSize(btnWidth, btnHeight)

    local dontIncludeProfileText = bbpParent and "" or " Profile"
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"

    button:SetText(string.format("|A:%s:16:16|a %s%s|r", icon, color, name..dontIncludeProfileText))
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    local a,b,c = button.Text:GetFont()
    button.Text:SetFont(a,b,"OUTLINE")
    local a,b,c,d,e = button.Text:GetPoint()
    button.Text:SetPoint(a,b,c,d,e-0.6)

    button:SetScript("OnClick", function()
        if onClickFunc then
            onClickFunc()
        end
    end)

    if class == "STARTER" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A basic starter profile that only enables the few things you need.\n\nIntended to work as a very minimal quick start that can be built upon.", nil, "ANCHOR_TOP")
    elseif class == "BLITZ" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A more advanced profile enabling a few more settings and customizing things a bit more.\n\nGreat for Battlegrounds (and Arenas) with Class Icons showing Healers, Tanks and Battleground Objectives.", nil, "ANCHOR_TOP")
    elseif class == "MYTHIC" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A great, well-rounded profile made by |cffc79c6eJovelo|r that enhances the default Blizzard nameplates.\n\nGreat for all types of content with Mythic+ Season 2 NPC nameplate colors included.", nil, "ANCHOR_TOP")
    else
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), string.format("Enable all of %s's profile settings.", name), string.format("www.twitch.tv/%s", twitchName), "ANCHOR_TOP")
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

    if title == "Cast Emphasis List" then
        CreateTooltipTwo(titleText, "Supports Plater cast color import as well.")
    elseif title == "Color NPC List" then
        CreateTooltipTwo(titleText, "Supports Plater NPC Color import as well.")
    end

    -- Export EditBox
    local exportBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    exportBox:SetSize(100, 20)
    exportBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -10)
    exportBox:SetAutoFocus(false)
    CreateTooltipTwo(exportBox, "Ctrl+C to copy and share")

    -- Import EditBox
    local importBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importBox:SetSize(100, 20)
    importBox:SetPoint("TOP", exportBox, "BOTTOM", 0, -5)
    importBox:SetAutoFocus(false)

    -- Export Button
    local exportBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    exportBtn:SetPoint("RIGHT", exportBox, "LEFT", -10, 0)
    exportBtn:SetSize(73, 20)
    exportBtn:SetText("Export")
    exportBtn:SetNormalFontObject("GameFontNormal")
    exportBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(exportBtn, "Export Data", "Create an export string to share your data.")

    -- Import Button
    local importBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    importBtn:SetPoint("RIGHT", importBox, "LEFT", -10, 0)
    --importBtn:SetSize(title ~= "Full Profile" and 52 or 73, 20)
    importBtn:SetSize(73, 20)
    importBtn:SetText("Import")
    importBtn:SetNormalFontObject("GameFontNormal")
    importBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(importBtn, "Import Data", "Import an export string.\nWill remove any current data (optional setting coming in non-beta)")

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
            if title == "Full Profile" then
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
    CreateTooltipTwo(wipeButton, "Delete "..title, "Delete all the data in "..title.."\n\nHold Shift+Alt and Right-Click to delete and reload.")

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
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Error importing " .. title .. ":", errorMessage)
        else
            if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                -- Perform a deep merge if "Keep Old" is checked
                BBP.DeepMergeTables(dataTable, profileData)
            else
                -- Replace existing data with imported data
                --for k in pairs(dataTable) do dataTable[k] = nil end -- Clear current table
                for k, v in pairs(profileData) do
                    dataTable[k] = v -- Populate with new data
                end
            end
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: " .. title .. " imported successfully. While still BETA this requires a reload to load in new lists.")
            C_CVar.SetCVar("NamePlateVerticalScale", BetterBlizzPlatesDB.NamePlateVerticalScale)
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
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
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: You cannot change CVar's in combat. Waiting for combat to end...")
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
    table.insert(checkBoxList, {checkbox = checkBox, label = label})
    checkBox.text = checkBox.Text
    -- checkBox:SetHitRectInsets(0, 0, 0, 0)
    checkBox.Text:SetFont("Fonts\\FRIZQT__.TTF", 11)
    -- local a,b,c,d,e = checkBox.Text:GetPoint()
    -- checkBox.Text:SetPoint(a,b,c,d-4,e-1)
    checkBox.option = option
    if cvar then
        checkBox.cvar = true
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
        category = "General"
    end

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
                    GameTooltip:AddLine("Spell ID: " .. npc.id, 1, 1, 1)
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
            colorPickerButton:SetText("Color")

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
            CreateTooltipTwo(checkBoxMurloc, "Murloc Icon |A:newplayerchat-chaticon-newcomer:22:22|a", "Instead of hiding the nameplate completely show a small Murloc icon.", nil, "ANCHOR_TOPRIGHT")

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
            CreateTooltipTwo(checkBoxP, "Pandemic Glow |T"..BBP.PandemicIcon..":22:22:0:0|t", "Check for a red glow when the aura has less than 5 sec remaining.", nil, "ANCHOR_TOPRIGHT")

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
            CreateTooltipTwo(checkBoxI, "Important Glow |T"..BBP.ImportantIcon..":22:22:0:0|t", "Check for a glow on the aura to highlight it.\n|cff32f795Right-click to change Color.|r", "Ctrl+Alt+Right-click to change the color of ALL auras in the whitelist.", "ANCHOR_TOPRIGHT")

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
                        okBtn:SetText("Color ALL Auras")
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
            CreateTooltipTwo(checkBoxC, "Compacted Aura |T"..BBP.CompactIcon..":22:22:0:0|t", "Check to make the aura half-sized and smaller.", "You can turn off half-size and adjust size in settings below.", "ANCHOR_TOPRIGHT")

            -- Initialize state from npc flags
            if npc.flags.compacted then
                checkBoxC:SetChecked(true)
            end

            -- Create Checkbox E (Enlarged)
            local checkBoxE = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxE:SetSize(24, 24)
            checkBoxE:SetPoint("RIGHT", checkBoxC, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxE, "Enlarged Aura |T"..BBP.EnlargedIcon..":22:22:0:0|t", "Check to make the aura square and bigger.", "You can turn off square and adjust size in settings below.", "ANCHOR_TOPRIGHT")

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
            CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |T"..BBP.OwnAuraIcon..":22:22:0:0|t", "Only show my aura.", nil, "ANCHOR_TOPRIGHT")

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
            CreateTooltipTwo(prioritySlider, "Priority value", "Whichever aura has the highest priority will determine the color.")

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
            CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |T"..BBP.OwnAuraIcon..":22:22:0:0|t", "Only color my aura.", nil, "ANCHOR_TOPRIGHT")

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
            for _, entry in ipairs(listData) do
                local name = entry.name and entry.name:lower() or ""
                local id = entry.id and tostring(entry.id):lower() or ""
                local comment = entry.comment and entry.comment:lower() or ""
                if name:match(currentSearchFilter) or id:match(currentSearchFilter) or comment:match(currentSearchFilter) then
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
        text = "This name or npcID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
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
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
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
        CreateTooltipTwo(editBox, "Add new aura or Search", "Add new aura to the list with name or spell id. Typing also searches in the list.", nil, "ANCHOR_TOP")
    elseif listName == "hideCastbarList" then
        CreateTooltipTwo(editBox, "Add new spell or NPC", "Filter auras/npcs by spell/npc id and/or spell/npc name. Typing also searches in the list.", nil, "ANCHOR_TOP")
    elseif listName == "castEmphasisList" then
        CreateTooltipTwo(editBox, "Add new spell or NPC", "Add spells by spell id and/or name. Typing also searches in the list.", nil, "ANCHOR_TOP")
    else
        CreateTooltipTwo(editBox, "Add new NPC", "Filter npcs by npc id and/or npc name. Typing also searches in the list.", nil, "ANCHOR_TOP")
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

        -- Remove unwanted characters from name and comment individually
        name = gsub(name, "[%/%(%)%[%]]", "")
        comment = gsub(comment, "[%/%(%)%[%]]", "")

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
    addButton:SetText("Add")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)
    return scrollFrame
end

local function CreateNpcList(subPanel, npcList, refreshFunc, width, height)
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetPoint("TOPLEFT", -4, -10)

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
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
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
            npcEditFrame = CreateFrame("Frame", "NPC_EditFrame", UIParent, "BasicFrameTemplateWithInset")
            npcEditFrame:SetSize(350, 250)
            npcEditFrame:SetPoint("CENTER")
            npcEditFrame:SetFrameStrata("HIGH")

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
            title:SetText("Edit NPC Details")
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
            local nameLabel, nameEditBox = CreatePropertyField(npcEditFrame, "Name:", npcEditFrame.iconTexture, -35, 125, 220, 25)
            npcEditFrame.nameEditBox = nameEditBox

            local durationLabel, durationEditBox = CreatePropertyField(npcEditFrame, "Duration:", npcEditFrame.iconTexture, 95, 91, 50, 20)
            npcEditFrame.durationEditBox = durationEditBox
            CreateTooltipTwo(durationEditBox, "Duration", "Enter new duration (0 for no duration)")

            local sizeLabel, sizeEditBox = CreatePropertyField(npcEditFrame, "Size:", durationLabel, 0, -10, 50, 20)
            npcEditFrame.sizeEditBox = sizeEditBox
            CreateTooltipTwo(sizeEditBox, "Size", "Enter new size")

            local iconLabel, iconEditBox = CreatePropertyField(npcEditFrame, "Icon:", sizeLabel, 0, -10, 50, 20)
            npcEditFrame.iconEditBox = iconEditBox
            CreateTooltipTwo(iconEditBox, "Icon", "Enter new icon ID", "Use Wowhead to find a new icon. Search for a spell then click on its icon and an icon ID will show.")


            local GlowText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            GlowText:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 0, -10)
            GlowText:SetText("Glow")

            local importantCheckBox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            importantCheckBox:SetSize(28, 28)
            importantCheckBox:SetPoint("LEFT", GlowText, "RIGHT", 5, 0)
            CreateTooltipTwo(importantCheckBox, "Important Glow")
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
            colorPickerButton:SetText("Color")
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
            HideText:SetText("Hide Icon")

            -- Creation of the hideIconCheckbox
            local hideIconCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideIconCheckbox:SetSize(28, 28)
            hideIconCheckbox:SetPoint("LEFT", HideText, "RIGHT", 5, 0)

            local HideHpText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            HideHpText:SetPoint("TOPLEFT", HideText, "BOTTOMLEFT", 0, -10)
            HideHpText:SetText("Hide HP")

            -- Creation of the hideIconCheckbox
            local hideHpCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideHpCheckbox:SetSize(28, 28)
            hideHpCheckbox:SetPoint("LEFT", HideHpText, "RIGHT", 5, 0)

            CreateTooltipTwo(hideIconCheckbox, "Hide Icon")

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
            updateButton:SetText("Close")
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
        editButton:SetText("Edit")
        editButton:SetScript("OnClick", function()
            ShowEditFrame(npcId)
        end)
        button.editButton = editButton
        CreateTooltipTwo(editButton, "Edit NPC details", "Change size, duration, icon and glow.")

        -- Size button
        local sizeButton = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sizeButton:SetPoint("LEFT", button, "RIGHT", -355, 0)
        local sizeText = npcData.size and "Size: " .. npcData.size or "Set Size"
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
        CreateTooltipTwo(hideIconCheckboxButton, "Hide Icon")

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
        CreateTooltip(importantCheckBox, "Important Glow")

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
        CreateTooltipTwo(hideHealthBarCheckBox, "Hide Healthbar")

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
        CreateTooltipTwo(iconOnlyCheckBox, "Icon Only Mode")

        if npcData.iconOnly then
            iconOnlyCheckBox:SetChecked(true)
        end

        button.iconOnlyCheckBox = iconOnlyCheckBox


        --if prioSlider then
                -- Create Input Box on Right Click

            
                local editBox = CreateFrame("EditBox", nil, barWidthSlider, "InputBoxTemplate")
                editBox:SetAutoFocus(false)
                editBox:SetWidth(50)
                editBox:SetHeight(20)
                editBox:SetMultiLine(false)
                editBox:SetFrameStrata("DIALOG")
                editBox:Hide()
                
                editBox:SetFontObject(GameFontHighlightSmall)
                
                local barWidthSlider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
                barWidthSlider:SetSize(100, 16)
                barWidthSlider:SetPoint("LEFT", button, "RIGHT", -203, 0)
                barWidthSlider:SetOrientation("HORIZONTAL")
                if BetterBlizzPlatesDB.classicNameplates then
                    barWidthSlider:SetMinMaxValues(-48, 48)
                else
                    barWidthSlider:SetMinMaxValues(-53, 53)
                end
                barWidthSlider:SetValueStep(1)
                barWidthSlider:SetValue(npcData.hpWidth or 0) -- Set the default priority to 1 if not specified
                barWidthSlider:SetObeyStepOnDrag(true)
                barWidthSlider.Low:SetText("")
                barWidthSlider.High:SetText("")
                CreateTooltipTwo(barWidthSlider, "Healthbar Width", "Decrease or Increase the healthbar width of this NPC.\nEnable Change HP Bar width to use.\n\nRight-click to input specific value.")

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
                    BBP.auraListNeedsUpdate = true
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
        CreateTooltipTwo(hpWidthCheckBox, "Change HP Bar Width")

        if npcData.widthOn then
            hpWidthCheckBox:SetChecked(true)
        else
            DisableElement(barWidthSlider)
        end

        button.hpWidthCheckBox = hpWidthCheckBox

        return button
    end

    StaticPopupDialogs["BBP_SET_SIZE"] = {
        text = "Enter new size (minimum 10):",
        button1 = "Set",
        button2 = "Cancel",
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
        text = "Enter new duration (0 for no duration):",
        button1 = "Set",
        button2 = "Cancel",
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
        text = "This name or npcID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
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
    CreateTooltipTwo(editBox, "Add new NPC", "Enter NPC ID first, name second and Spell ID (for icon) third. Separate with commas. Name and Spell ID are optional.", "Example: 192123, Hermit Crab, 52127", "ANCHOR_TOP")

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
            print("Invalid NPC ID.")
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
            icon = spellId and GetSpellTexture(spellId) or 533422,  -- Get icon if spellId is provided
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
    addButton:SetText("Add")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)

    return scrollFrame
end

local function CreateTitle(parent)
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
    wipText:SetText("Search is not complete and is WIP.")

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
    settingsText:SetText("Search results:")

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
    CreateTooltipTwo(searchBox, "Search |A:shop-games-magnifyingglass:17:17|a", "You can now search for settings in BetterBlizzPlates. (WIP)", nil, "TOP")

    -- Create the list to display search results, positioned under the title and icon
    local resultsList = CreateFrame("Frame", nil, searchFrame)
    resultsList:SetSize(640, 500)
    resultsList:SetPoint("TOP", settingsText, "BOTTOM", 0, -10)

    -- Search function that clears results or searches for query
    local checkboxPool = {}
    local sliderPool = {}

    local function SearchElements(query)
        -- Clear existing results
        for _, child in ipairs({resultsList:GetChildren()}) do
            child:Hide()
        end

        if query == "" then
            return
        end

        -- Convert the query into lowercase and split it into individual words
        query = string.lower(query)
        local queryWords = { strsplit(" ", query) }

        local checkboxCount = 0
        local sliderCount = 0
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
            local originalScript = originalCheckbox:GetScript("OnMouseDown")
            if originalScript then
                searchCheckbox:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        originalScript(originalCheckbox, button)
                    end
                end)
            end
        end

        -- Search through checkboxes
        for _, data in ipairs(checkBoxList) do
            if checkboxCount >= 20 then break end

            -- Prepare the label and tooltip text
            local label = string.lower(data.label or "")
            local tooltipTitle = string.lower(data.checkbox.tooltipTitle or "")
            local tooltipMainText = string.lower(data.checkbox.tooltipMainText or "")
            local tooltipSubText = string.lower(data.checkbox.tooltipSubText or "")
            local tooltipCVarName = string.lower(data.checkbox.tooltipCVarName and data.checkbox.tooltipCVarName.." CVar" or "")

            -- Check if all query words are found in any of the searchable fields
            if matchesQuery(label) or matchesQuery(tooltipTitle) or matchesQuery(tooltipMainText) or matchesQuery(tooltipSubText) or matchesQuery(tooltipCVarName) then
                checkboxCount = checkboxCount + 1

                -- Re-use or create a new checkbox from the pool
                local resultCheckBox = checkboxPool[checkboxCount]
                if not resultCheckBox then
                    resultCheckBox = CreateFrame("CheckButton", nil, resultsList, "InterfaceOptionsCheckButtonTemplate")
                    resultCheckBox:SetSize(24, 24)
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

                -- Link the result checkbox to the main checkbox
                resultCheckBox:SetScript("OnClick", function()
                    data.checkbox:Click()
                end)

                applyRightClickScript(resultCheckBox, data.checkbox)

                -- Reapply tooltip
                if data.checkbox.tooltipMainText then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, data.checkbox.tooltipMainText, data.checkbox.tooltipSubText, nil, data.checkbox.tooltipCVarName, nil, data.checkbox.searchCategory)
                elseif data.checkbox.tooltipTitle then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, nil, nil, nil, nil, nil, data.checkbox.searchCategory)
                else
                    CreateTooltipTwo(resultCheckBox, "No data yet WIP", nil, nil, nil, nil, nil, data.checkbox.searchCategory)
                end

                resultCheckBox:Show()

                -- Move down for the next checkbox
                yOffsetCheckbox = yOffsetCheckbox - 24
            end
        end

        -- Search through sliders
        for _, data in ipairs(sliderList) do
            if sliderCount >= 13 then break end

            -- Prepare the label and tooltip text
            local label = string.lower(data.label or "")
            local tooltipTitle = string.lower(data.slider.tooltipTitle or "")
            local tooltipMainText = string.lower(data.slider.tooltipMainText or "")
            local tooltipSubText = string.lower(data.slider.tooltipSubText or "")
            local tooltipCVarName = string.lower(data.slider.tooltipCVarName and data.slider.tooltipCVarName.." CVar" or "")

            -- Check if all query words are found in any of the searchable fields
            if matchesQuery(label) or matchesQuery(tooltipTitle) or matchesQuery(tooltipMainText) or matchesQuery(tooltipSubText) or matchesQuery(tooltipCVarName) then
                sliderCount = sliderCount + 1

                -- Re-use or create a new slider from the slider pool
                local resultSlider = sliderPool[sliderCount]
                if not resultSlider then
                    resultSlider = CreateFrame("Slider", nil, resultsList, "OptionsSliderTemplate")
                    resultSlider:SetOrientation('HORIZONTAL')
                    resultSlider:SetValueStep(data.slider:GetValueStep())
                    resultSlider:SetObeyStepOnDrag(true)
                    resultSlider.Text = resultSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    resultSlider.Text:SetTextColor(1, 0.81, 0, 1)
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
                    CreateTooltipTwo(resultSlider, "No data yet WIP", nil, nil, nil, nil, nil, data.slider.searchCategory)
                end

                -- Show the slider and prepare for the next slider
                resultSlider:Show()
                yOffsetSlider = yOffsetSlider - 42
            end
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
            SettingsPanel.SearchBox.Instructions:SetText("Search in BetterBlizzPlates")
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
            if SettingsPanel.SearchBox.Instructions:GetText() == "Search in BetterBlizzPlates" then
                SettingsPanel.SearchBox.Instructions:SetText("Search")
            end
            searchBox:Hide()
            searchFrame:Hide()
        end
    end)
end

------------------------------------------------------------
-- GUI Panels
------------------------------------------------------------
local function guiGeneralTab()
    ----------------------
    -- Main panel:
    ----------------------
    local mainGuiAnchor = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")
    CreateTitle(BetterBlizzPlates)

    local bgImg = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local newSearch = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    newSearch:SetAtlas("NewCharacter-Horde", true)
    newSearch:SetPoint("BOTTOM", BetterBlizzPlates, "TOP", -70, 2)
    CreateTooltipTwo(newSearch, "Search |A:shop-games-magnifyingglass:17:17|a", "You can now search for settings in BetterBlizzPlates. (WIP)")

    local newSearchPoint = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    newSearchPoint:SetAtlas("auctionhouse-icon-buyallarrow", true)
    newSearchPoint:SetPoint("LEFT", newSearch, "RIGHT", -25, 0)
    newSearchPoint:SetRotation(math.pi / 2)

    local alpha = BetterBlizzPlates:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    alpha:SetPoint("CENTER", 0, 0)
    alpha:SetText("BETA")
    alpha:SetFont("Fonts\\FRIZQT__.TTF", 156)
    alpha:SetScale(1.4)
    alpha:SetAlpha(0.1)

    local alpha2 = BetterBlizzPlates:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    alpha2:SetPoint("BOTTOM", SettingsPanel, "TOP", 0, 0)
    alpha2:SetText("BetterBlizzPlates "..(BBP.isMoP and "MoP" or BBP.isTBC and "TBC" or "Cata").." is still in Beta. Please report bugs.")
    alpha2:SetFont("Fonts\\FRIZQT__.TTF", 20, "THINOUTLINE")
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
    settingsText:SetText("General settings")
    local generalSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local removeRealmNames = CreateCheckbox("removeRealmNames", "Hide realm", BetterBlizzPlates)
    removeRealmNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local healthNumbers = CreateCheckbox("healthNumbers", "Health numbers", BetterBlizzPlates, nil, BBP.ToggleHealthNumbers)
    healthNumbers:SetPoint("LEFT", removeRealmNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(healthNumbers, "Show Health Numbers", "Show health numbers on nameplates. More settings available in \"Advanced Settings\".")

    local classicNameplates = CreateCheckbox("classicNameplates", "Use Classic Nameplates", BetterBlizzPlates)
    classicNameplates:SetPoint("TOPLEFT", removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicNameplates, "Classic Nameplates", "Use the default classic nameplate look instead of retail look on nameplates.")

    local hideLevelFrame = CreateCheckbox("hideLevelFrame", "Hide Level", BetterBlizzPlates)
    hideLevelFrame:SetPoint("LEFT", classicNameplates.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideLevelFrame, "Hide Level", "Hides the Level on nameplates.")

    classicNameplates:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.nameplateEnemyWidth = 128
            BetterBlizzPlatesDB.nameplateFriendlyWidth = 128
            BetterBlizzPlatesDB.castBarHeight = 10
            hideLevelFrame:SetChecked(false)
            BetterBlizzPlatesDB.hideLevelFrame = false
        else
            BetterBlizzPlatesDB.nameplateEnemyWidth = 110
            BetterBlizzPlatesDB.nameplateFriendlyWidth = 110
            BetterBlizzPlatesDB.castBarHeight = 16
            hideLevelFrame:SetChecked(true)
            BetterBlizzPlatesDB.hideLevelFrame = true
        end
        if not InCombatLockdown() then
            C_NamePlate.SetNamePlateFriendlySize(BetterBlizzPlatesDB.nameplateFriendlyWidth, 32)--friendlyHeight)
            C_NamePlate.SetNamePlateEnemySize(BetterBlizzPlatesDB.nameplateEnemyWidth, 32)
        end
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)
    -- hideLevelFrame:HookScript("OnClick", function(self)
    --     if not self:GetChecked() then
    --         StaticPopup_Show("BBP_CONFIRM_RELOAD")
    --     end
    -- end)

    -- local hideNameplateAuraTooltip = CreateCheckbox("hideNameplateAuraTooltip", "Hide aura tooltip", BetterBlizzPlates)
    -- hideNameplateAuraTooltip:SetPoint("LEFT", classicNameplates.text, "RIGHT", 0, 0)
    -- hideNameplateAuraTooltip:HookScript("OnClick", function()
    --     BBP.HideNameplateAuraTooltip()
    --     StaticPopup_Show("BBP_CONFIRM_RELOAD")
    -- end)
    -- CreateTooltipTwo(hideNameplateAuraTooltip, "Hide Aura Tooltip", "Hide Nameplate Aura Tooltips.")

    local hideTargetHighlight = CreateCheckbox("hideTargetHighlight", "Hide target highlight glow", BetterBlizzPlates)
    hideTargetHighlight:SetPoint("TOPLEFT", classicNameplates, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTargetHighlight, "Hide Target Highlight", "Hide the bright glow on your current target nameplate")

    local smallPetsInPvP = CreateCheckbox("smallPetsInPvP", "Small Pets", BetterBlizzPlates)
    smallPetsInPvP:SetPoint("LEFT", healthNumbers.text, "RIGHT", 0, 0)
    CreateTooltipTwo(smallPetsInPvP, "Small Pets", "Reduce the width of all pet nameplates, and the width of all npc nameplates in PvP.\n\n|cff32f795Right-click to adjust width.|r", "Totem Indicator NPCs will stay full width unless specified otherwise in the Totem Indicator List section.")

    -- Create slider frame when right-clicked
    smallPetsInPvP:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            if not self.slider then
                -- Create slider frame
                local slider = CreateFrame("Slider", "SmallPetsWidthSlider", self:GetParent(), "OptionsSliderTemplate")
                slider:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
                slider:SetWidth(120)
                slider:SetMinMaxValues(2, 40)
                slider:SetValue(BetterBlizzPlatesDB.smallPetsWidth or 20)
                slider:SetValueStep(1)
                slider:SetObeyStepOnDrag(true)

                -- Customize the slider text
                slider.Text:SetFontObject(GameFontHighlightSmall)
                slider.Text:SetTextColor(1, 0.81, 0, 1)
                slider.Low:SetText("")
                slider.High:SetText("")

                -- Set initial label
                local initialValue = BetterBlizzPlatesDB.smallPetsWidth or 50
                slider.Text:SetText("Small Pets Width: " .. initialValue)

                -- Slider update logic
                slider:SetScript("OnValueChanged", function(_, value)
                    local roundedValue = math.floor(value + 0.5)
                    BetterBlizzPlatesDB.smallPetsWidth = roundedValue
                    slider.Text:SetText("Small Pets Width: " .. roundedValue)
                    slider.adjusting = true
                    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
                        local frame = nameplate.UnitFrame
                        if frame then
                            BBP.SmallPetsInPvP(frame)
                            if BetterBlizzPlatesDB.classicNameplates then
                                BBP.AdjustClassicBorderWidth(frame)
                                BBP.CreateBetterClassicCastbarBorders(frame)
                            end
                            --BBP.NameplateShadowAndMouseoverHighlight(frame)
                        end
                    end
                end)

                slider:SetScript("OnMouseUp", function(self)
                    slider.adjusting = nil
                    C_Timer.After(2, function()
                        if not self.adjusting then
                            self:Hide()
                        end
                    end)
                end)
                self.slider = slider
            else
                self.slider:SetShown(not self.slider:IsShown())
            end
        end
    end)

    -- Ensure slider hides if checkbox is unchecked
    smallPetsInPvP:HookScript("OnClick", function(self)
        if not self:GetChecked() and self.slider then
            self.slider:Hide()
        end
    end)

    local nameplateMinScale = CreateSlider(BetterBlizzPlates, "Nameplate Size", 0.5, 2, 0.01, "nameplateMinScale")
    nameplateMinScale:SetPoint("TOPLEFT", hideTargetHighlight, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(nameplateMinScale, "Nameplate Size", "General size of all nameplates (except Target nameplate)", nil, nil, "nameplateMinScale", "nameplateMaxScale")

    local nameplateMinScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateMinScaleResetButton:SetText("Default")
    nameplateMinScaleResetButton:SetWidth(60)
    nameplateMinScaleResetButton:SetPoint("LEFT", nameplateMinScale, "RIGHT", 10, 0)
    nameplateMinScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateMinScale, "nameplateScale")
    end)

    local nameplateSelectedScale = CreateSlider(BetterBlizzPlates, "Target Nameplate Size", 0.5, 3, 0.01, "nameplateSelectedScale")
    nameplateSelectedScale:SetPoint("TOPLEFT", nameplateMinScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateSelectedScale, "Target Nameplate Size", "Size of your current target's nameplate", nil, nil, "nameplateSelectedScale")

    local nameplateSelectedScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateSelectedScaleResetButton:SetText("Default")
    nameplateSelectedScaleResetButton:SetWidth(60)
    nameplateSelectedScaleResetButton:SetPoint("LEFT", nameplateSelectedScale, "RIGHT", 10, 0)
    nameplateSelectedScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateSelectedScale, "nameplateSelected")
    end)

    local NamePlateVerticalScale = CreateSlider(BetterBlizzPlates, "Nameplate Height", 0.5, 5, 0.01, "NamePlateVerticalScale")
    NamePlateVerticalScale:SetPoint("TOPLEFT", nameplateSelectedScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(NamePlateVerticalScale, "Nameplate Height", "Changes the height of ALL nameplates.", "Needs reload after adjustment.", nil, "NamePlateVerticalScale")

    local NamePlateVerticalScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    NamePlateVerticalScaleResetButton:SetText("Default")
    NamePlateVerticalScaleResetButton:SetWidth(60)
    NamePlateVerticalScaleResetButton:SetPoint("LEFT", NamePlateVerticalScale, "RIGHT", 10, 0)
    NamePlateVerticalScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight2(NamePlateVerticalScale)
    end)

    ----------------------
    -- Enemy nameplates:
    ----------------------
    local enemyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -151)
    enemyNameplatesText:SetText("Enemy nameplates")
    local enemyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon:SetSize(28, 28)
    enemyNameplateIcon:SetPoint("RIGHT", enemyNameplatesText, "LEFT", -3, 0)
    enemyNameplateIcon:SetDesaturated(1)
    enemyNameplateIcon:SetVertexColor(1, 0, 0)

    local enemyClassColorName = CreateCheckbox("enemyClassColorName", "Class color name", BetterBlizzPlates)
    enemyClassColorName:SetPoint("TOPLEFT", enemyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(enemyClassColorName, "Class Color Name", "Class color the enemy name text on nameplate")

    local enemyColorName = CreateCheckbox("enemyColorName", "Color name", BetterBlizzPlates)
    enemyColorName:SetPoint("LEFT", enemyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyColorName, "Color Name", "Pick one color for all enemy names", "If class color name is also enabled this setting will only color the name of npcs")

    local enemyColorThreat = CreateCheckbox("enemyColorThreat", "Color Threat", BetterBlizzPlates)
    enemyColorThreat:SetPoint("TOPLEFT", enemyColorName.text, "BOTTOMLEFT", 0, 0)
    CreateTooltipTwo(enemyColorThreat, "Color by threat in instanced PvE", "Color options and more settings in Advanced Settings section. Default Red & Green.")

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
    enemyColorNameButton:SetText("Hostile")
    enemyColorNameButton:SetPoint("LEFT", enemyColorName.Text, "RIGHT", -1, 0)
    enemyColorNameButton:SetSize(55, 20)
    enemyColorNameButton:SetScript("OnClick", function()
        OpenColorPicker("enemyColorNameRGB", enemyColorNameButtonIcon)
    end)
    CreateTooltipTwo(enemyColorNameButton, "Hostile Color")
    enemyColorNameButtonIcon:SetPoint("LEFT", enemyColorNameButton, "RIGHT", 0, -0.5)

    local enemyNeutralColorNameButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNeutralColorNameButtonIcon:SetAtlas("CircleMaskScalable")
    enemyNeutralColorNameButtonIcon:SetSize(18, 17)
    UpdateColorSquare(enemyNeutralColorNameButtonIcon, unpack(BetterBlizzPlatesDB.enemyNeutralColorNameRGB or {1, 1, 1}))
    local enemyNeutralColorNameButton = CreateFrame("Button", nil, enemyColorName, "UIPanelButtonTemplate")
    enemyNeutralColorNameButton:SetText("Neutral")
    enemyNeutralColorNameButton:SetPoint("LEFT", enemyColorNameButtonIcon, "RIGHT", 0, 0.5)
    enemyNeutralColorNameButton:SetSize(55, 20)
    enemyNeutralColorNameButton:SetScript("OnClick", function()
        OpenColorPicker("enemyNeutralColorNameRGB", enemyNeutralColorNameButtonIcon)
    end)
    CreateTooltipTwo(enemyNeutralColorNameButton, "Neutral Color")
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

    local ShowClassColorInNameplate = CreateCheckbox("ShowClassColorInNameplate", "Class color healthbar", BetterBlizzPlates, true, BBP.ApplyNameplateWidth)
    ShowClassColorInNameplate:SetPoint("TOPLEFT", enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(ShowClassColorInNameplate, "Class Color Healthbar", "Class color enemy healthbars.", nil, nil, "ShowClassColorInNameplate")
    if GetCVar("ShowClassColorInNameplate") == "1" and BetterBlizzPlatesDB.ShowClassColorInNameplate == nil then
        BetterBlizzPlatesDB.ShowClassColorInNameplate = true
        ShowClassColorInNameplate:SetChecked(true)
    end
    ShowClassColorInNameplate:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local enemyHealthBarColor = CreateCheckbox("enemyHealthBarColor", "Custom healthbar color", BetterBlizzPlates)
    enemyHealthBarColor:SetPoint("TOPLEFT", ShowClassColorInNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enemyHealthBarColor, "Custom Nameplate Color", "Color ALL enemy nameplates a color of your choice.", "Has sub-setting to color NPC's only")

    local alwaysHideEnemyCastbar = CreateCheckbox("alwaysHideEnemyCastbar", "Hide castbar", BetterBlizzPlates)
    alwaysHideEnemyCastbar:SetPoint("TOPLEFT", enemyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideEnemyCastbar, "Hide Castbar", "Always hide Enemy castbar.")

    local enemyHealthBarColorNpcOnly = CreateCheckbox("enemyHealthBarColorNpcOnly", "Npc only", BetterBlizzPlates)
    enemyHealthBarColorNpcOnly:SetPoint("LEFT", enemyHealthBarColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyHealthBarColorNpcOnly, "Only color NPC's.")

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
    enemyHealthBarColorButton:SetText("Hostile")
    enemyHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorNpcOnly.Text, "RIGHT", -1, 0)
    enemyHealthBarColorButton:SetSize(55, 20)
    enemyHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyHealthBarColorRGB", enemyHealthBarColorButtonIcon)
    end)
    CreateTooltipTwo(enemyHealthBarColorButton, "Hostile Color")
    enemyHealthBarColorButtonIcon:SetPoint("LEFT", enemyHealthBarColorButton, "RIGHT", 0, -0.5)

    local enemyNeutralHealthBarColorButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNeutralHealthBarColorButtonIcon:SetAtlas("CircleMaskScalable")
    enemyNeutralHealthBarColorButtonIcon:SetSize(18, 17)
    UpdateColorSquare(enemyNeutralHealthBarColorButtonIcon, unpack(BetterBlizzPlatesDB.enemyNeutralHealthBarColorRGB or {1, 1, 1}))
    local enemyNeutralHealthBarColorButton = CreateFrame("Button", nil, enemyHealthBarColor, "UIPanelButtonTemplate")
    enemyNeutralHealthBarColorButton:SetText("Neutral")
    enemyNeutralHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorButtonIcon, "RIGHT", 0, 0.5)
    enemyNeutralHealthBarColorButton:SetSize(55, 20)
    enemyNeutralHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyNeutralHealthBarColorRGB", enemyNeutralHealthBarColorButtonIcon)
    end)
    CreateTooltipTwo(enemyNeutralHealthBarColorButton, "Neutral Color")
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

    local showNameplateCastbarTimer = CreateCheckbox("showNameplateCastbarTimer", "Cast timer next to castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateCastbarTimer:SetPoint("LEFT", alwaysHideEnemyCastbar.text, "RIGHT", 0, 0)

    local showNameplateTargetText = CreateCheckbox("showNameplateTargetText", "Show target underneath castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateTargetText:SetPoint("TOPLEFT", alwaysHideEnemyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateTargetText, "Nameplate Target Text", "Show the nameplate's current target underneath the castbar while casting")

    local hideEliteDragon = CreateCheckbox("hideEliteDragon", "Hide elite icon", BetterBlizzPlates)
    hideEliteDragon:SetPoint("LEFT", showNameplateTargetText.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideEliteDragon, "Hide Elite Icon", "Hide the elite dragon icon on nameplates")

    local enemyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 1.5, 0.01, "enemyNameScale")
    enemyNameScale:SetPoint("TOPLEFT", showNameplateTargetText, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(enemyNameScale, "Name Size", "Change Name size on Enemy nameplates", "While adjusting this setting names can get 20% larger/smaller due to Blizzard scaling issues. Reload between adjustments to make sure the size is what you want.")

    local hideEnemyNameText = CreateCheckbox("hideEnemyNameText", "Hide name", BetterBlizzPlates)
    hideEnemyNameText:SetPoint("LEFT", enemyNameScale, "RIGHT", 2, 0)
    CreateTooltip(hideEnemyNameText, "Hide Name", "Hide Name on Enemy nameplates")

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

    local nameplateEnemyWidth = CreateSlider(BetterBlizzPlates, "Nameplate Width", 26, 200, 1, "nameplateEnemyWidth")
    nameplateEnemyWidth:SetPoint("TOPLEFT", enemyNameScale, "BOTTOMLEFT", 0, -17)

    local nameplateEnemyWidthResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateEnemyWidthResetButton:SetText("Default")
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
    friendlyNameplatesText:SetText("Friendly nameplates")
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", "Clickthrough", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(friendlyNameplateClickthrough, "Clickthrough Nameplate", "Make friendly nameplates clickthrough and make them overlap.",  "Overlaps even with stacking nameplates setting. For other addons relying on healthbar height (usually stuff anchored on top) this setting will push the anchor point lower so you'll have to adjust for that on friendly plates.")

    local friendlyClassColorName = CreateCheckbox("friendlyClassColorName", "Class color name", BetterBlizzPlates)
    friendlyClassColorName:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyClassColorName, "Class Color Name", "Class color the Friendly name text on nameplates")

    local friendlyColorName = CreateCheckbox("friendlyColorName", "Color name", BetterBlizzPlates)
    friendlyColorName:SetPoint("LEFT", friendlyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyColorName, "Color Name", "Pick one color for all friendly names.", "If class color name is also enabled this setting will only color the name of npcs")

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
    friendlyColorNameButton:SetText("Color")
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

    local ShowClassColorInFriendlyNameplate = CreateCheckbox("ShowClassColorInFriendlyNameplate", "Class color healthbar", BetterBlizzPlates, true, BBP.ApplyNameplateWidth)
    ShowClassColorInFriendlyNameplate:SetPoint("TOPLEFT", friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(ShowClassColorInFriendlyNameplate, "Class color healthbar", "Class color friendly healthbars.", nil, nil, "ShowClassColorInFriendlyNameplate")
    if GetCVar("ShowClassColorInFriendlyNameplate") == "1" and BetterBlizzPlatesDB.ShowClassColorInFriendlyNameplate == nil then
        BetterBlizzPlatesDB.ShowClassColorInFriendlyNameplate = true
        ShowClassColorInFriendlyNameplate:SetChecked(true)
    end
    ShowClassColorInFriendlyNameplate:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local friendlyHealthBarColor = CreateCheckbox("friendlyHealthBarColor", "Custom healthbar color", BetterBlizzPlates)
    friendlyHealthBarColor:SetPoint("TOPLEFT", ShowClassColorInFriendlyNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyHealthBarColor, "Custom Healthbar Color", "Color Friendly healthbars a color of your choice.")

    local friendlyHealthBarColorPlayer = CreateCheckbox("friendlyHealthBarColorPlayer", "Player", BetterBlizzPlates)
    friendlyHealthBarColorPlayer:SetPoint("LEFT", friendlyHealthBarColor.text, "RIGHT", -3, 0)
    CreateTooltipTwo(friendlyHealthBarColorPlayer, "Color Players", "Color friendly player healthbars.")

    local friendlyHealthBarColorNpc = CreateCheckbox("friendlyHealthBarColorNpc", "Npc", BetterBlizzPlates)
    friendlyHealthBarColorNpc:SetPoint("LEFT", friendlyHealthBarColorPlayer.text, "RIGHT", -3, 0)
    CreateTooltipTwo(friendlyHealthBarColorNpc, "Color Npcs", "Color friendly npc healthbars.")

    local alwaysHideFriendlyCastbar = CreateCheckbox("alwaysHideFriendlyCastbar", "Hide castbar", BetterBlizzPlates)
    alwaysHideFriendlyCastbar:SetPoint("TOPLEFT", friendlyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideFriendlyCastbar, "Hide Castbar", "Always hide Friendly castbars.")

    local classColorPersonalNameplate = CreateCheckbox("classColorPersonalNameplate", "Class color personal nameplate", BetterBlizzPlates)
    classColorPersonalNameplate:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    classColorPersonalNameplate:HookScript("OnClick", function(self)
        local nameplate, frame = BBP.GetSafeNameplate("player")
        if frame then
            if self:GetChecked() then
                local localizedClass, englishClass = UnitClass(frame.unit);
                local playerClassColor = RAID_CLASS_COLORS[englishClass];
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
    friendlyHealthBarColorButton:SetText("Color")
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

    BBP.friendlyHideHealthBar = CreateCheckbox("friendlyHideHealthBar", "Hide healthbar", BetterBlizzPlates, nil, nil, true)
    BBP.friendlyHideHealthBar:SetPoint("LEFT", alwaysHideFriendlyCastbar.text, "RIGHT", 0, 0)
    BBP.friendlyHideHealthBar:HookScript("OnClick", function()
        BBP.HideHealthbarInPvEMagicCaller()
    end)
    CreateTooltipTwo(BBP.friendlyHideHealthBar, "Hide Healthbar", "Hide healthbars on Friendly nameplates.", "Castbar and name will still show.\nThis also hides healthbars in PvE, if you don't want that behaviour then check the setting in Misc.")

    BBP.friendlyHideHealthBarNpc = CreateCheckbox("friendlyHideHealthBarNpc", "NPC's", BetterBlizzPlates, nil, nil, true)
    BBP.friendlyHideHealthBarNpc:SetPoint("LEFT", BBP.friendlyHideHealthBar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(BBP.friendlyHideHealthBarNpc, "Hide NPC Healthbar", "Hide healthbars on Friendly NPC's", "Castbar and name will still show.")

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
    friendlyNpToggles:SetText("Toggles:")
    friendlyNpToggles:SetPoint("TOPLEFT", classColorPersonalNameplate, "BOTTOMLEFT", -20, -70)
    CreateTooltipTwo(friendlyNpToggles, "Toggle Friendly Nameplates", "Turn on friendly nameplates when you enter these types of content and off again when it changes.\n\nSelect where you want friendly nameplates enabled:")

    local toggleFriendlyNameplatesInArena = CreateCheckbox("friendlyNameplatesOnlyInArena", "Arena", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesAuto)
    toggleFriendlyNameplatesInArena:SetPoint("LEFT", friendlyNpToggles, "RIGHT", 0, 0)
    CreateTooltipTwo(toggleFriendlyNameplatesInArena, "Arena Toggle", "Turn on friendly nameplates when you enter arena and off again when you leave.")
    toggleFriendlyNameplatesInArena:SetSize(22,22)

    local friendlyNameplatesOnlyInBgs = CreateCheckbox("friendlyNameplatesOnlyInBgs", "BGs", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesAuto)
    friendlyNameplatesOnlyInBgs:SetPoint("LEFT", toggleFriendlyNameplatesInArena.text, "RIGHT", -2, 0)
    CreateTooltipTwo(friendlyNameplatesOnlyInBgs, "Battleground Toggle", "Turn on friendly nameplates when you enter battlegrounds and off again when you leave.")
    friendlyNameplatesOnlyInBgs:SetSize(22,22)

    local friendlyNameplatesOnlyInEpicBgs = CreateCheckbox("friendlyNameplatesOnlyInEpicBgs", "E-BGs", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesAuto)
    friendlyNameplatesOnlyInEpicBgs:SetPoint("LEFT", friendlyNameplatesOnlyInBgs.text, "RIGHT", -2, 0)
    CreateTooltipTwo(friendlyNameplatesOnlyInEpicBgs, "Epic Battleground Toggle", "Turn on friendly nameplates when you enter epic battlegrounds and off again when you leave.")
    friendlyNameplatesOnlyInEpicBgs:SetSize(22,22)

    local friendlyNameplatesOnlyInDungeons = CreateCheckbox("friendlyNameplatesOnlyInDungeons", "Dungeons", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesAuto)
    friendlyNameplatesOnlyInDungeons:SetPoint("LEFT", friendlyNameplatesOnlyInEpicBgs.text, "RIGHT", -2, 0)
    CreateTooltipTwo(friendlyNameplatesOnlyInDungeons, "Dungeon Toggle", "Turn on friendly nameplates when you enter dungeons and off again when you leave.")
    friendlyNameplatesOnlyInDungeons:SetSize(22,22)

    local friendlyNameplatesOnlyInRaids = CreateCheckbox("friendlyNameplatesOnlyInRaids", "Raids", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesAuto)
    friendlyNameplatesOnlyInRaids:SetPoint("LEFT", friendlyNameplatesOnlyInDungeons.text, "RIGHT", -2, 0)
    CreateTooltipTwo(friendlyNameplatesOnlyInRaids, "Raid Toggle", "Turn on friendly nameplates when you enter raids and off again when you leave.")
    friendlyNameplatesOnlyInRaids:SetSize(22,22)

    local friendlyNameplatesOnlyInWorld = CreateCheckbox("friendlyNameplatesOnlyInWorld", "World", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesAuto)
    friendlyNameplatesOnlyInWorld:SetPoint("LEFT", friendlyNameplatesOnlyInRaids.text, "RIGHT", -2, 0)
    CreateTooltipTwo(friendlyNameplatesOnlyInWorld, "World Toggle", "Turn on friendly nameplates when you enter non-instanced World content and off again when enter other types.")
    friendlyNameplatesOnlyInWorld:SetSize(22,22)

    local friendlyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 3, 0.01, "friendlyNameScale")
    friendlyNameScale:SetPoint("TOPLEFT", classColorPersonalNameplate, "BOTTOMLEFT", 0, -6)
    CreateTooltipTwo(friendlyNameScale, "Name Size", "Change Name size on Friendly nameplates.", "While adjusting this setting names can get 20% larger/smaller due to Blizzard scaling issues. Reload between adjustments to make sure the size is what you want.")

    local hideFriendlyNameText = CreateCheckbox("hideFriendlyNameText", "Hide name", BetterBlizzPlates)
    hideFriendlyNameText:SetPoint("LEFT", friendlyNameScale, "RIGHT", 2, 0)
    CreateTooltipTwo(hideFriendlyNameText, "Hide Name", "Hide Name on Friendly nameplates")

    local nameplateFriendlyWidth = CreateSlider(BetterBlizzPlates, "Nameplate Width", 26, 200, 1, "nameplateFriendlyWidth")
    nameplateFriendlyWidth:SetPoint("TOPLEFT", friendlyNameScale, "BOTTOMLEFT", 0, -20)

    local nameplateFriendlyWidthResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateFriendlyWidthResetButton:SetText("Default")
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
    extraFeaturesText:SetText("Extra Features")
    local extraFeaturesIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)

    local testAllEnabledFeatures = CreateCheckbox("testAllEnabledFeatures", "Test", BetterBlizzPlates, nil, BBP.TestAllEnabledFeatures)
    testAllEnabledFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
    CreateTooltipTwo(testAllEnabledFeatures, "Test all features", "Test all enabled features.", "Check advanced settings for more settings for each individual feature.")

    local absorbIndicator = CreateCheckbox("absorbIndicator", "Absorb indicator", BetterBlizzPlates, nil, BBP.ToggleAbsorbIndicator)
    absorbIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(absorbIndicator, "Absorb Indicator |A:ParagonReputation_Glow:18:18|a", "Show absorb amount on nameplates")
    local absorbsIcon = absorbIndicator:CreateTexture(nil, "ARTWORK")
    absorbsIcon:SetAtlas("ParagonReputation_Glow")
    absorbsIcon:SetSize(22, 22)
    absorbsIcon:SetPoint("RIGHT", absorbIndicator, "LEFT", 2, 0)

    local overShields = CreateCheckbox("overShields", "Overshields", BetterBlizzPlates, nil, BBP.HookOverShields)
    overShields:SetPoint("LEFT", absorbIndicator.text, "RIGHT", 0, 0)
    CreateTooltipTwo(overShields, "Show Overshields |A:ParagonReputation_Glow:18:18|a", "Shows absorb texture even on full hp targets. The texture will go backwards onto the hp bar for however much over-absorb there is.", "No test-mode available yet, soonTM.")
    overShields:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local classIndicator = CreateCheckbox("classIndicator", "Class indicator", BetterBlizzPlates)
    classIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classIndicator, "Class Indicator |A:groupfinder-icon-class-mage:16:16|a", "Show class icon on nameplates\nHides default raidmarker.")
    local classIndicatorIcon = classIndicator:CreateTexture(nil, "ARTWORK")
    classIndicatorIcon:SetAtlas("groupfinder-icon-class-mage")
    classIndicatorIcon:SetSize(18, 18)
    classIndicatorIcon:SetPoint("RIGHT", classIndicator, "LEFT", 0, 0)
    classIndicator:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        if self:GetChecked() then
            if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
                print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Enable Nameplate Aura customization in order to show CC icons in Class Indicator.")
            else
                print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Enabled Friendly Debuffs & PvP CC filter in Nameplate Auras section in order to show CC inside of Class Indicator.")
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

    local combatIndicator = CreateCheckbox("combatIndicator", "Combat indicator", BetterBlizzPlates, nil, BBP.ToggleCombatIndicator)
    combatIndicator:SetPoint("TOPLEFT", classIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(combatIndicator, "Combat Indicator |A:food:16:16|a", "Show a food (or sap) icon on nameplates that are out of combat.")
    local combatIcon = combatIndicator:CreateTexture(nil, "ARTWORK")
    combatIcon:SetAtlas("food")
    combatIcon:SetSize(19, 19)
    combatIcon:SetPoint("RIGHT", combatIndicator, "LEFT", -1, 0)

    local executeIndicator = CreateCheckbox("executeIndicator", "Execute indicator", BetterBlizzPlates, nil, BBP.ToggleExecuteIndicator)
    executeIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(executeIndicator, "Execute Indicator |T"..BBP.executeIndicatorIconReplacement..":22:22:0:0|t", "Starts tracking health percentage once target dips below a certain percentage (40% by default).")
    local executeIndicatorIcon = executeIndicator:CreateTexture(nil, "ARTWORK")
    executeIndicatorIcon:SetTexture(BBP.executeIndicatorIconReplacement)
    executeIndicatorIcon:SetSize(28, 30)
    executeIndicatorIcon:SetPoint("RIGHT", executeIndicator, "LEFT", 4, 1)

    local healerIndicator = CreateCheckbox("healerIndicator", "Healer indicator", BetterBlizzPlates)
    healerIndicator:SetPoint("TOPLEFT", executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healerIndicator, "Healer Indicator |A:greencross:21:21|a", "Show a cross on healers. Requires Details to work.", "Note: Party Pointer and Class Indicator both have their own Healer Icon settings. This is a separate icon entirely.")
    local healerCrossIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    healerCrossIcon:SetAtlas("greencross")
    healerCrossIcon:SetSize(21, 21)
    healerCrossIcon:SetPoint("RIGHT", healerIndicator, "LEFT", 0, 0)

    local partyPointer = CreateCheckbox("partyPointer", "Party pointer", BetterBlizzPlates)
    partyPointer:SetPoint("TOPLEFT", healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyPointer, "Party Pointer |T"..BBP.partyPointerIconReplacement..":22:22:0:0|t", "Show a class colored pointer above friendly player nameplates.", "Hides default raidmarkers. Only shows in Arena by default or during testing. Can show extra + sign on healers in settings.")
    local partyPointerIcon = partyPointer:CreateTexture(nil, "ARTWORK")
    partyPointerIcon:SetTexture(BBP.partyPointerIconReplacement)
    partyPointerIcon:SetSize(17, 18)
    partyPointerIcon:SetPoint("RIGHT", partyPointer, "LEFT", -2.5, 1.5)
    partyPointerIcon:SetDesaturated(true)
    partyPointerIcon:SetVertexColor(0.04, 0.76, 1)
    partyPointer:HookScript("OnClick", function(self)
        if self:GetChecked() then
            if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
                print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Enable Nameplate Aura customization in order to show CC icons on top of Party Pointer.")
            else
                print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Enabled Friendly Debuffs & PvP CC filter in Nameplate Auras section in order to show CC on top of Party Pointer.")
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

    local petIndicator = CreateCheckbox("petIndicator", "Pet indicator", BetterBlizzPlates)
    petIndicator:SetPoint("TOPLEFT", partyPointer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(petIndicator, "Show a murloc on the main hunter pet")
    CreateTooltipTwo(petIndicator, "Pet Indicator |A:newplayerchat-chaticon-newcomer:18:18|a", "Show a murloc on the main hunter and demo warlock pet.")
    local petIndicatorIcon = petIndicator:CreateTexture(nil, "ARTWORK")
    petIndicatorIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicatorIcon:SetSize(18, 18)
    petIndicatorIcon:SetPoint("RIGHT", petIndicator, "LEFT", -1, 0)

    local targetIndicator = CreateCheckbox("targetIndicator", "Target indicator", BetterBlizzPlates)
    targetIndicator:SetPoint("TOPLEFT", petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetIndicator, "Target Indicator |T"..BBP.targetIndicatorIconReplacement..":22:22:0:0|t", "Show a pointer on your current target.\n\nCan also change Target Color/Texture in Advanced Settings.")
    local targetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    targetIndicatorIcon:SetTexture(BBP.targetIndicatorIconReplacement)
    targetIndicatorIcon:SetRotation(math.rad(180))
    targetIndicatorIcon:SetSize(24, 20)
    targetIndicatorIcon:SetPoint("RIGHT", targetIndicator, "LEFT", 2, 0)

    local focusTargetIndicator = CreateCheckbox("focusTargetIndicator", "Focus target indicator", BetterBlizzPlates)
    focusTargetIndicator:SetPoint("TOPLEFT", targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicator, "Show a marker on the focus nameplate")
    CreateTooltipTwo(focusTargetIndicator, "Focus Target Indicator |T"..BBP.focusIndicatorIconReplacement..":22:22:0:0|t", "Show a marker on your focus nameplate.")
    local focusTargetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    focusTargetIndicatorIcon:SetTexture(BBP.focusIndicatorIconReplacement)
    focusTargetIndicatorIcon:SetSize(19, 20)
    focusTargetIndicatorIcon:SetPoint("RIGHT", focusTargetIndicator, "LEFT", 0, 0)

    local totemIndicator = CreateCheckbox("totemIndicator", "Totem indicator", BetterBlizzPlates)
    totemIndicator:SetPoint("TOPLEFT", focusTargetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    totemIndicator:HookScript("OnClick", function(self)
        local function setTotemCVar()
            if InCombatLockdown() then
                C_Timer.After(1.5, setTotemCVar)
            else
                if self:GetChecked() and GetCVar("nameplateShowEnemyTotems") ~= "1" then
                    BetterBlizzPlatesDB.nameplateShowEnemyTotems = 1
                    C_CVar.SetCVar("nameplateShowEnemyTotems", BetterBlizzPlatesDB.nameplateShowEnemyTotems)
                    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: CVar \"nameplateShowEnemyTotems\" set to 1. Make sure your CVar settings are correct in the \"CVar Control\" section of the addon.")
                end
            end
        end
        setTotemCVar()
    end)

    CreateTooltipTwo(totemIndicator, "Totem Indicator |T"..BBP.TotemIndicatorIcon..":22:22:0:0|t", "Show icon on and color important NPC nameplates.", "Full list available in \"Totem Indicator List\" section, designed for PvP.")
    local totemsIcon = totemIndicator:CreateTexture(nil, "ARTWORK")
    totemsIcon:SetTexture(BBP.TotemIndicatorIcon)
    totemsIcon:SetSize(17, 17)
    totemsIcon:SetPoint("RIGHT", totemIndicator, "LEFT", -1, 0)

    local questIndicator = CreateCheckbox("questIndicator", "Quest indicator", BetterBlizzPlates)
    questIndicator:SetPoint("TOPLEFT", totemIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(questIndicator, "Quest Indicator|A:smallquestbang:20:20|a", "Quest symbol on quest NPC's.")
    local questsIcon = questIndicator:CreateTexture(nil, "ARTWORK")
    questsIcon:SetAtlas("smallquestbang")
    questsIcon:SetSize(20, 20)
    questsIcon:SetPoint("RIGHT", questIndicator, "LEFT", 1, 0)

    ----------------------
    -- Font and texture
    ----------------------
    local customFontandTextureText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -365)
    customFontandTextureText:SetText("Font and texture")
    local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    customFontandTextureIcon:SetTexture(BBP.BarberIcon)
    customFontandTextureIcon:SetSize(24, 24)
    customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

    local useCustomFont = CreateCheckbox("useCustomFont", "Change the nameplate font", BetterBlizzPlates)
    useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(useCustomFont, "Custom Font", "Change the nameplate font.", "If you want to completely skip nameplate font adjustment there is a setting in the Misc section for that")

    local useCustomTexture = CreateCheckbox("useCustomTextureForBars", "Change the nameplate texture", BetterBlizzPlates)
    useCustomTexture:SetPoint("TOPLEFT", useCustomFont, "BOTTOMLEFT", 0, -26)
    CreateTooltipTwo(useCustomTexture, "Custom Texture", "Change the nameplate texture.")

    local fontDropdown = CreateFontDropdown(
        "fontDropdown",
        useCustomFont,
        "Select Font",
        "customFont",
        function(arg1)
            BBP.RefreshAllNameplates() 
        end,
        { anchorFrame = useCustomFont, x = 5, y = -21, label = "Font" }
    )

    local enableCustomFontOutline = CreateCheckbox("enableCustomFontOutline", "Outline", useCustomFont)
    enableCustomFontOutline:SetPoint("LEFT", fontDropdown, "RIGHT", -15, 1)
    CreateTooltipTwo(enableCustomFontOutline, "Font Outline", "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.")
    enableCustomFontOutline:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            local currentOutline = BetterBlizzPlatesDB["customFontOutline"]
            if currentOutline == "THINOUTLINE" then
                BetterBlizzPlatesDB["customFontOutline"] = "THICKOUTLINE"
                RefreshTooltip(enableCustomFontOutline, "Font Outline", "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.\nCurrent: Thick Outline")
            else
                BetterBlizzPlatesDB["customFontOutline"] = "THINOUTLINE"
                RefreshTooltip(enableCustomFontOutline, "Font Outline", "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.\nCurrent: Thin Outline")
            end
            BBP.RefreshAllNameplates()
        end
    end)

    local textureDropdown = CreateTextureDropdown(
        "textureDropdown",
        useCustomTexture,
        "Select Texture",
        "customTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomTexture, x = 5, y = -21, label = "Texture" }
    )

    local textureDropdownFriendly = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        "Select Texture",
        "customTextureFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomTexture, x = 5, y = -51, label = "Friendly" }
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

    local useCustomTextureForEnemy = CreateCheckbox("useCustomTextureForEnemy", "Enemy", useCustomTexture)
    useCustomTextureForEnemy:SetPoint("LEFT", textureDropdown, "RIGHT", -15, 1)
    --useCustomTextureForEnemy.text:SetTextColor(1,0,0) bodifycata
    useCustomTextureForEnemy:HookScript("OnClick", function(self)
        if self:GetChecked() then
            LibDD:UIDropDownMenu_EnableDropDown(textureDropdown)
        else
            LibDD:UIDropDownMenu_DisableDropDown(textureDropdown)
        end
    end)
    CreateTooltipTwo(useCustomTextureForEnemy, "Enemy Texture", "Change Enemy healthbar texture.", nil, "ANCHOR_LEFT")
    if not useCustomTextureForEnemy:GetChecked() then
        LibDD:UIDropDownMenu_DisableDropDown(textureDropdown)
    end

    -- local useCustomTextureForExtraBars = CreateCheckbox("useCustomTextureForExtraBars", "Overbars", BetterBlizzPlates)
    -- useCustomTextureForExtraBars:SetPoint("BOTTOMLEFT", useCustomTextureForEnemy, "TOPLEFT", 0, -3)
    -- CreateTooltipTwo(useCustomTextureForExtraBars, "Change Overbars Texture", "Also change the texture for nameplate absorbs & overhealing etc.")
    -- notWorking(useCustomTextureForExtraBars, true)

    local useCustomTextureForFriendly = CreateCheckbox("useCustomTextureForFriendly", "Friendly", useCustomTexture)
    useCustomTextureForFriendly:SetPoint("LEFT", textureDropdownFriendly, "RIGHT", -15, 1)
    --useCustomTextureForFriendly.text:SetTextColor(0.04, 0.76, 1) bodifycata
    useCustomTextureForFriendly:HookScript("OnClick", function(self)
        if self:GetChecked() then
            LibDD:UIDropDownMenu_EnableDropDown(textureDropdownFriendly)
        else
            LibDD:UIDropDownMenu_DisableDropDown(textureDropdownFriendly)
        end
    end)
    CreateTooltipTwo(useCustomTextureForFriendly, "Friendly Texture", "Change Friendly healthbar texture.", nil, "ANCHOR_LEFT")
    if not useCustomTextureForFriendly:GetChecked() then
        LibDD:UIDropDownMenu_DisableDropDown(textureDropdownFriendly)
    end

    -- local useCustomTextureForSelf = CreateCheckbox("useCustomTextureForSelf", "Self", useCustomTexture)
    -- useCustomTextureForSelf:SetPoint("LEFT", textureDropdownSelf, "RIGHT", -15, 1)
    -- useCustomTextureForSelf:HookScript("OnClick", function(self)
    --     if self:GetChecked() then
    --         LibDD:UIDropDownMenu_EnableDropDown(textureDropdownSelf)
    --     else
    --         LibDD:UIDropDownMenu_DisableDropDown(textureDropdownSelf)
    --     end
    -- end)
    -- CreateTooltipTwo(useCustomTextureForSelf, "Personal Texture", "Change Personal resource healthbar texture.", nil, "ANCHOR_LEFT")
    -- if not useCustomTextureForSelf:GetChecked() then
    --     LibDD:UIDropDownMenu_DisableDropDown(textureDropdownSelf)
    -- end

    -- local useCustomTextureForSelfMana = CreateCheckbox("useCustomTextureForSelfMana", "Self Mana", useCustomTexture)
    -- useCustomTextureForSelfMana:SetPoint("LEFT", textureDropdownSelfMana, "RIGHT", -15, 1)
    -- useCustomTextureForSelfMana:HookScript("OnClick", function(self)
    --     if self:GetChecked() then
    --         LibDD:UIDropDownMenu_EnableDropDown(textureDropdownSelfMana)
    --     else
    --         LibDD:UIDropDownMenu_DisableDropDown(textureDropdownSelfMana)
    --     end
    -- end)
    -- CreateTooltipTwo(useCustomTextureForSelfMana, "Personal Mana/Resource Texture", "Change Personal Resource mana/resource-bar texture", nil, "ANCHOR_LEFT")
    -- if not useCustomTextureForSelfMana:GetChecked() then
    --     LibDD:UIDropDownMenu_DisableDropDown(textureDropdownSelfMana)
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
            LibDD:UIDropDownMenu_EnableDropDown(fontDropdown)
        else
            LibDD:UIDropDownMenu_DisableDropDown(fontDropdown)
            DisableElement(enableCustomFontOutline)
        end
    end)

    useCustomTexture:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(useCustomTexture)
        if self:GetChecked() then
            if useCustomTextureForEnemy:GetChecked() then
                LibDD:UIDropDownMenu_EnableDropDown(textureDropdown)
            end
            if useCustomTextureForFriendly:GetChecked() then
                LibDD:UIDropDownMenu_EnableDropDown(textureDropdownFriendly)
            end
            -- if useCustomTextureForSelf:GetChecked() then
            --     LibDD:UIDropDownMenu_EnableDropDown(textureDropdownSelf)
            -- end
            -- if useCustomTextureForSelfMana:GetChecked() then
            --     LibDD:UIDropDownMenu_EnableDropDown(textureDropdownSelfMana)
            -- end
        else
            LibDD:UIDropDownMenu_DisableDropDown(textureDropdown)
            LibDD:UIDropDownMenu_DisableDropDown(textureDropdownFriendly)
            -- LibDD:UIDropDownMenu_DisableDropDown(textureDropdownSelf)
            -- LibDD:UIDropDownMenu_DisableDropDown(textureDropdownSelfMana)
        end
    end)


    ----------------------
    -- Arena
    ----------------------
    local arenaSettingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaSettingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, 30)
    arenaSettingsText:SetText("Arena nameplates")
    local arenaSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    arenaSettingsIcon:SetAtlas("questbonusobjective")
    arenaSettingsIcon:SetSize(24, 24)
    arenaSettingsIcon:SetPoint("RIGHT", arenaSettingsText, "LEFT", -3, 0)
    CreateTooltipTwo(arenaSettingsText, "Arena ID/Spec Name", "Replace names in arena to their arena ID or their specialization", nil, "ANCHOR_LEFT")

    local arenaModeDropdown = CreateModeDropdown(
        "arenaModeDropdown",
        BetterBlizzPlates,
        "Select a mode to use",
        "arenaModeSettingKey",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSettingsText, x = -90, y = -33, label = "Mode" },
        modes,
        tooltips,
        "Enemy",
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(arenaModeDropdown, "Arena ID/Spec Name", "Replace names in arena to their arena ID or their specialization", nil, "ANCHOR_LEFT")

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", "Short", BetterBlizzPlates)
    shortArenaSpecName:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)
    CreateTooltipTwo(shortArenaSpecName, "Short Spec Names", "Enable to use abbreviated specialization names. For instance, \"Assassination\" will be displayed as \"Assa\".", nil, "ANCHOR_LEFT")

    local arenaIndicatorBg = CreateCheckbox("arenaIndicatorBg", "BG", BetterBlizzPlates)
    arenaIndicatorBg:SetPoint("LEFT", shortArenaSpecName.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(arenaIndicatorBg, "Battleground Spec Names", "Show spec names on enemy nameplates in Battlegrounds", "Requires Details addon", "ANCHOR_LEFT")

    local arenaIndicatorTestMode = CreateCheckbox("arenaIndicatorTestMode", "Test", BetterBlizzPlates)
    arenaIndicatorTestMode:SetPoint("LEFT", arenaIndicatorBg.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(arenaIndicatorTestMode, "Test Arena ID/Spec", "Test the selected Arena Nameplates mode.", nil, "ANCHOR_LEFT")

    local arenaIDScale = CreateSlider(BetterBlizzPlates, "Arena ID Size", 0.5, 4, 0.01, "arenaIDScale")
    arenaIDScale:SetPoint("TOPLEFT", arenaModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltipTwo(arenaIDScale, "Arena ID Size", "Size of the enemy arena ID text on top of nameplate during arena.")

    local arenaSpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.01, "arenaSpecScale")
    arenaSpecScale:SetPoint("TOPLEFT", arenaIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltipTwo(arenaSpecScale, "Arena Spec Size", "Size of the enemy spec name text on top of nameplate during arena.")

    local partyModeDropdown = CreateModeDropdown(
        "partyModeDropdown",
        BetterBlizzPlates,
        "Select a mode to use",
        "partyModeSettingKey",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSettingsText, x = 70, y = -33, label = "Mode" },
        modesParty,
        tooltipsParty,
        "Friendly",
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(partyModeDropdown, "Arena ID/Spec Name", "Replace names in arena to their arena ID or their specialization", nil, "ANCHOR_LEFT")

    local partyIDScale = CreateSlider(BetterBlizzPlates, "Party ID Size", 0.5, 4, 0.01, "partyIDScale")
    partyIDScale:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltipTwo(partyIDScale, "Arena ID Size", "Size of the friendly party ID text on top of nameplate during arena.")

    local partySpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.01, "partySpecScale")
    partySpecScale:SetPoint("TOPLEFT", partyIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltipTwo(partySpecScale, "Arena Spec Size", "Size of the friendly spec name text on top of nameplate during arena.")






    local btnGap = 3
    local starterButton = CreateClassButton(BetterBlizzPlates, "STARTER", "Starter", nil, function()
        ShowProfileConfirmation("Starter", "STARTER", BBP.StarterProfile, "|cff808080(If you want to completely reset BBP there\nis a button in Advanced Settings)|r\n\n")
    end)
    starterButton:SetPoint("TOPLEFT", SettingsPanel, "BOTTOMLEFT", 16, 38)

    local blitzButton = CreateClassButton(BetterBlizzPlates, "BLITZ", "Blitz", nil, function()
        ShowProfileConfirmation("Blitz", "BLITZ", BBP.BlitzProfile)
    end)
    blitzButton:SetPoint("LEFT", starterButton, "RIGHT", btnGap, 0)

    -- local mythicButton = CreateClassButton(BetterBlizzPlates, "MYTHIC", "Mythic", nil, function()
    --     ShowProfileConfirmation("Mythic", "MYTHIC", BBP.MythicProfile)
    -- end)
    -- mythicButton:SetPoint("LEFT", blitzButton, "RIGHT", btnGap, 0)

    -- local aeghisButton = CreateClassButton(BetterBlizzPlates, "MAGE", "Aeghis", "aeghis", function()
    --     ShowProfileConfirmation("Aeghis", "MAGE", BBP.AeghisProfile)
    -- end)
    -- aeghisButton:SetPoint("LEFT", mythicButton, "RIGHT", btnGap, 0)

    -- local kalvishButton = CreateClassButton(BetterBlizzPlates, "ROGUE", "Kalvish", "kalvish", function()
    --     ShowProfileConfirmation("Kalvish", "ROGUE", BBP.KalvishProfile)
    -- end)
    -- kalvishButton:SetPoint("LEFT", aeghisButton, "RIGHT", btnGap, 0)

    -- local magnuszButton = CreateClassButton(BetterBlizzPlates, "WARRIOR", "Magnusz", "magnusz", function()
    --     ShowProfileConfirmation("Magnusz", "WARRIOR", BBP.MagnuszProfile)
    -- end)
    -- magnuszButton:SetPoint("LEFT", kalvishButton, "RIGHT", btnGap, 0)

    -- local mmarkersButton = CreateClassButton(BetterBlizzPlates, "DRUID", "Mmarkers", "mmarkers", function()
    --     ShowProfileConfirmation("Mmarkers", "DRUID", BBP.MmarkersProfile)
    -- end)
    -- mmarkersButton:SetPoint("LEFT", magnuszButton, "RIGHT", btnGap, 0)
    local aeghisButton = CreateClassButton(BetterBlizzPlates, "MAGE", "Aeghis", "aeghis", function()
        ShowProfileConfirmation("Aeghis", "MAGE", BBP.AeghisProfile)
    end)
    aeghisButton:SetPoint("LEFT", blitzButton, "RIGHT", btnGap, 0)

    local mmarkersButton = CreateClassButton(BetterBlizzPlates, "DRUID", "Mmarkers", "mmarkers", function()
        ShowProfileConfirmation("Mmarkers", "DRUID", BBP.MmarkersProfile)
    end)
    mmarkersButton:SetPoint("LEFT", aeghisButton, "RIGHT", btnGap, 0)

    local nahjButton = CreateClassButton(BetterBlizzPlates, "ROGUE", "Nahj", "nahj", function()
        ShowProfileConfirmation("Nahj", "ROGUE", BBP.NahjProfile)
    end)
    nahjButton:SetPoint("LEFT", mmarkersButton, "RIGHT", btnGap, 0)

    local saulButton = CreateClassButton(BetterBlizzPlates, "SHAMAN", "Saul", "saul", function()
        ShowProfileConfirmation("Saul", "SHAMAN", BBP.SaulProfile)
    end)
    saulButton:SetPoint("LEFT", nahjButton, "RIGHT", btnGap, 0)

    local snupyButton = CreateClassButton(BetterBlizzPlates, "DRUID", "Snupy", "snupy", function()
        ShowProfileConfirmation("Snupy", "DRUID", BBP.SnupyProfile)
    end)
    snupyButton:SetPoint("LEFT", saulButton, "RIGHT", btnGap, 0)




    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", BetterBlizzPlates, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)
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

    local BetterBlizzPlatesSubPanel = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel.name = "Advanced Settings"
    BetterBlizzPlatesSubPanel.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel)
    local guiPositionAndScaleCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, BetterBlizzPlatesSubPanel, BetterBlizzPlatesSubPanel.name, BetterBlizzPlatesSubPanel.name)
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
    anchorSubHeal:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, secondLineY)
    anchorSubHeal:SetText("Healer Indicator")

    CreateBorderBox(anchorSubHeal)

    local healerCrossIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    healerCrossIcon2:SetAtlas("greencross")
    healerCrossIcon2:SetSize(29, 29)
    healerCrossIcon2:SetPoint("BOTTOM", anchorSubHeal, "TOP", 0, 3)
    healerCrossIcon2:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local healerIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "healerIndicatorScale", false, 72)
    healerIndicatorScale:SetPoint("TOP", anchorSubHeal, "BOTTOM", 36, -15)
    healerIndicatorScale.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltipTwo(healerIndicatorScale, "Friendly Scale")

    local healerIndicatorEnemyScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "healerIndicatorEnemyScale", false, 72)
    healerIndicatorEnemyScale:SetPoint("TOP", anchorSubHeal, "BOTTOM", -36, -15)
    healerIndicatorEnemyScale.Text:SetTextColor(1,0,0)
    CreateTooltipTwo(healerIndicatorEnemyScale, "Enemy Scale")

    local healerIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "healerIndicatorXPos", "X", 72)
    healerIndicatorXPos:SetPoint("TOP", healerIndicatorScale, "BOTTOM", 0, -15)
    healerIndicatorXPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltipTwo(healerIndicatorXPos, "Friendly X Offset")

    local healerIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "healerIndicatorYPos", "Y", 72)
    healerIndicatorYPos:SetPoint("TOP", healerIndicatorXPos, "BOTTOM", 0, -15)
    healerIndicatorYPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltipTwo(healerIndicatorYPos, "Friendly Y Offset")

    local healerIndicatorEnemyXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "healerIndicatorEnemyXPos", "X", 72)
    healerIndicatorEnemyXPos:SetPoint("TOP", healerIndicatorEnemyScale, "BOTTOM", 0, -15)
    healerIndicatorEnemyXPos.Text:SetTextColor(1,0,0)
    CreateTooltipTwo(healerIndicatorEnemyXPos, "Enemy X Offset")

    local healerIndicatorEnemyYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "healerIndicatorEnemyYPos", "Y", 72)
    healerIndicatorEnemyYPos:SetPoint("TOP", healerIndicatorEnemyXPos, "BOTTOM", 0, -15)
    healerIndicatorEnemyYPos.Text:SetTextColor(1,0,0)
    CreateTooltipTwo(healerIndicatorEnemyYPos, "Enemy Y Offset")

    local healerIndicatorDropdown = CreateAnchorDropdown(
        "healerIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "healerIndicatorEnemyAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = healerIndicatorYPos, x = -90, y = -35, label = "Enemy" },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltip(healerIndicatorDropdown, "Enemy Anchor")

    local healerIndicatorDropdown2 = CreateAnchorDropdown(
        "healerIndicatorDropdown2",
        contentFrame,
        "Select Anchor Point",
        "healerIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = healerIndicatorYPos, x = -16, y = -35, label = "Friendly" },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltip(healerIndicatorDropdown2, "Friendly Anchor")

    local healerIndicatorTestMode2 = CreateCheckbox("healerIndicatorTestMode", "Test", contentFrame)
    healerIndicatorTestMode2:SetPoint("TOPLEFT", healerIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local healerIndicatorEnemyOnly2 = CreateCheckbox("healerIndicatorEnemyOnly", "Enemies only", contentFrame)
    healerIndicatorEnemyOnly2:SetPoint("TOPLEFT", healerIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorArenaOnly = CreateCheckbox("healerIndicatorArenaOnly", "Arena only", contentFrame)
    healerIndicatorArenaOnly:SetPoint("TOPLEFT", healerIndicatorEnemyOnly2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorBgOnly = CreateCheckbox("healerIndicatorBgOnly", "Battleground only", contentFrame)
    healerIndicatorBgOnly:SetPoint("TOPLEFT", healerIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorRedCrossEnemy = CreateCheckbox("healerIndicatorRedCrossEnemy", "Red Cross for Enemy", contentFrame)
    healerIndicatorRedCrossEnemy:SetPoint("TOPLEFT", healerIndicatorBgOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    ----------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubOutOfCombat:SetText("Combat Indicator")

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

    local combatIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "combatIndicatorScale")
    combatIndicatorScale:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)

    local combatIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "combatIndicatorXPos", "X")
    combatIndicatorXPos:SetPoint("TOP", combatIndicatorScale, "BOTTOM", 0, -15)

    local combatIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "combatIndicatorYPos", "Y")
    combatIndicatorYPos:SetPoint("TOP", combatIndicatorXPos, "BOTTOM", 0, -15)

    local combatIndicatorDropdown = CreateAnchorDropdown(
        "combatIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "combatIndicatorAnchor",
        function(arg1) 
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = combatIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local combatIndicatorEnemyOnly = CreateCheckbox("combatIndicatorEnemyOnly", "Enemies only", contentFrame)
    combatIndicatorEnemyOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local combatIndicatorArenaOnly = CreateCheckbox("combatIndicatorArenaOnly", "In arena only", contentFrame)
    combatIndicatorArenaOnly:SetPoint("TOPLEFT", combatIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local combatIndicatorSap = CreateCheckbox("combatIndicatorSap", "Use sap icon instead", contentFrame)
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

    local combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", "On players only", contentFrame)
    combatIndicatorPlayersOnly:SetPoint("TOPLEFT", combatIndicatorSap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local combatIndicatorAssumePalaCombat = CreateCheckbox("combatIndicatorAssumePalaCombat", "Assume Pala Combat", contentFrame)
    combatIndicatorAssumePalaCombat:SetPoint("TOPLEFT", combatIndicatorPlayersOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(combatIndicatorAssumePalaCombat, "Assume Paladin Combat", "This setting makes it so if paladins have the \"Guardian of Ancient Kings\" pet up it assumes they are in combat.", "The API for combat status doesnt work and returns false even though they are in combat with this pet up. This is a very crude workaround that might not always be accurate.")

    ----------------------
    -- Hunter pet icon
    ----------------------
    local anchorSubPet = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPet:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, secondLineY)
    anchorSubPet:SetText("Pet Indicator")

    CreateBorderBox(anchorSubPet)

    anchorSubPet.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubPet.t:SetAtlas("newplayerchat-chaticon-newcomer")
    anchorSubPet.t:SetSize(36, 36)
    anchorSubPet.t:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

    local petIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "petIndicatorScale")
    petIndicatorScale:SetPoint("TOP", anchorSubPet, "BOTTOM", 0, -15)

    local petIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "petIndicatorXPos", "X")
    petIndicatorXPos:SetPoint("TOP", petIndicatorScale, "BOTTOM", 0, -15)

    local petIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "petIndicatorYPos", "Y")
    petIndicatorYPos:SetPoint("TOP", petIndicatorXPos, "BOTTOM", 0, -15)

    local petIndicatorDropdown = CreateAnchorDropdown(
        "petIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "petIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = petIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    anchorSubPet.petIndicatorTestMode2 = CreateCheckbox("petIndicatorTestMode", "Test", contentFrame)
    anchorSubPet.petIndicatorTestMode2:SetPoint("TOPLEFT", petIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    anchorSubPet.petIndicatorHideSecondaryPets = CreateCheckbox("petIndicatorHideSecondaryPets", "Hide Secondary Pets", contentFrame)
    anchorSubPet.petIndicatorHideSecondaryPets:SetPoint("TOPLEFT", anchorSubPet.petIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPet.petIndicatorHideSecondaryPets, "Hide Secondary Pets", "While in arena hide the nameplates of the non-main pets from pet classes.\n\nThis will hide DK, Lock & Hunter Zoo's.")

    anchorSubPet.petIndicatorShowMurloc = CreateCheckbox("petIndicatorShowMurloc", "Murloc Secondary Pets", anchorSubPet.petIndicatorHideSecondaryPets)
    anchorSubPet.petIndicatorShowMurloc:SetPoint("TOPLEFT", anchorSubPet.petIndicatorHideSecondaryPets, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPet.petIndicatorShowMurloc, "Murloc Secondary Pets", "Instead of completely hiding the nameplate show a little Murloc icon while hiding the rest of the nameplate. This helps with awareness but nameplates will still be clickable.")
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


    anchorSubPet.petIndicatorColorHealthbar = CreateCheckbox("petIndicatorColorHealthbar", "Color Main Pet HP", contentFrame)
    anchorSubPet.petIndicatorColorHealthbar:SetPoint("TOPLEFT", anchorSubPet.petIndicatorShowMurloc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPet.petIndicatorColorHealthbar, "Color Main Pet Healthbar", "Color the healthbar of the main pet.\n\n|cff32f795Right-click to change color.|r")
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
    anchorSubAbsorb:SetText("Absorb Indicator")

    CreateBorderBox(anchorSubAbsorb)

    anchorSubAbsorb.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubAbsorb.t:SetAtlas("ParagonReputation_Glow")
    anchorSubAbsorb.t:SetSize(51, 51)
    anchorSubAbsorb.t:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

    local absorbIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "absorbIndicatorScale")
    absorbIndicatorScale:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)

    local absorbIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "absorbIndicatorXPos", "X")
    absorbIndicatorXPos:SetPoint("TOP", absorbIndicatorScale, "BOTTOM", 0, -15)

    local absorbIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "absorbIndicatorYPos", "Y")
    absorbIndicatorYPos:SetPoint("TOP", absorbIndicatorXPos, "BOTTOM", 0, -15)

    local absorbIndicatorDropdown = CreateAnchorDropdown(
        "absorbIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "absorbIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = absorbIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local absorbIndicatorTestMode2 = CreateCheckbox("absorbIndicatorTestMode", "Test", contentFrame)
    absorbIndicatorTestMode2:SetPoint("TOPLEFT", absorbIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local absorbIndicatorEnemyOnly = CreateCheckbox("absorbIndicatorEnemyOnly", "Enemies only", contentFrame)
    absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", absorbIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local absorbIndicatorOnPlayersOnly = CreateCheckbox("absorbIndicatorOnPlayersOnly", "Players only", contentFrame)
    absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    ----------------------
    -- Totem Indicator
    ----------------------
    local anchorSubTotem = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, thirdLineY)
    anchorSubTotem:SetText("Totem Indicator")

    CreateBorderBox(anchorSubTotem)

    local totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    totemIcon2:SetTexture(BBP.TotemIndicatorIcon)
    totemIcon2:SetSize(34, 34)
    totemIcon2:SetPoint("BOTTOM", anchorSubTotem, "TOP", 0, 0)

    BBP.totemIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 3, 0.01, "totemIndicatorScale")
    BBP.totemIndicatorScale:SetPoint("TOP", anchorSubTotem, "BOTTOM", 0, -15)
    CreateTooltip( BBP.totemIndicatorScale, "This changes the scale of ALL icons.\n\nYou can adjust individual sizes in the \"Totem Indicator List\" tab.", "ANCHOR_LEFT")

    local totemIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "totemIndicatorXPos", "X")
    totemIndicatorXPos:SetPoint("TOP",  BBP.totemIndicatorScale, "BOTTOM", 0, -15)

    local totemIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "totemIndicatorYPos", "Y")
    totemIndicatorYPos:SetPoint("TOP", totemIndicatorXPos, "BOTTOM", 0, -15)

    local totemIndicatorDropdown = CreateAnchorDropdown(
        "totemIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "totemIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = totemIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local totemTestIcons2 = CreateCheckbox("totemIndicatorTestMode", "Test", contentFrame)
    totemTestIcons2:SetPoint("TOPLEFT", totemIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local totemIndicatorEnemyOnly = CreateCheckbox("totemIndicatorEnemyOnly", "Enemies only", contentFrame)
    totemIndicatorEnemyOnly:SetPoint("LEFT", totemTestIcons2.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorEnemyOnly, "Show on enemy totems only")

    local totemIndicatorHideNameAndShiftIconDown = CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", "Hide name", contentFrame)
    totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local totemIndicatorHideHealthBar = CreateCheckbox("totemIndicatorHideHealthBar", "Hide hp", contentFrame)
    totemIndicatorHideHealthBar:SetPoint("LEFT", totemIndicatorHideNameAndShiftIconDown.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorHideHealthBar, "Hide the healthbar on totems.\nWill still show if targeted.")

--[=[
    local totemIndicatorDisplayCdText = CreateCheckbox("totemIndicatorDisplayCdText", "CD Text", contentFrame)
    totemIndicatorDisplayCdText:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorDisplayCdText, "Display default Blizz CD Text\n\nWill not work with OmniCC.")
]=]-- cant force use blizzards own countdown it seems, must make own soonTM

    local showTotemIndicatorCooldownSwipe = CreateCheckbox("showTotemIndicatorCooldownSwipe", "CD Swipe", contentFrame)
    showTotemIndicatorCooldownSwipe:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showTotemIndicatorCooldownSwipe, "Show Cooldown Swipe Animation")

    local totemIndicatorColorName = CreateCheckbox("totemIndicatorColorName", "Color Name", contentFrame)
    totemIndicatorColorName:SetPoint("TOPLEFT", showTotemIndicatorCooldownSwipe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorColorName, "Color name text")

    local totemIndicatorHideAuras = CreateCheckbox("totemIndicatorHideAuras", "Hide auras", contentFrame)
    totemIndicatorHideAuras:SetPoint("LEFT", totemIndicatorColorName.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorHideAuras, "Hide Auras on totem nameplates")

    local totemIndicatorColorHealthBar = CreateCheckbox("totemIndicatorColorHealthBar", "Color HP", contentFrame)
    totemIndicatorColorHealthBar:SetPoint("LEFT", showTotemIndicatorCooldownSwipe.text, "RIGHT", 0, 0)
    CreateTooltip(totemIndicatorColorHealthBar, "Color healthbar")

    local totemIndicatorDefaultCooldownTextSize = CreateSlider(contentFrame, "Default CD Size", 0.3, 2, 0.01, "totemIndicatorDefaultCooldownTextSize", nil, 95)
    totemIndicatorDefaultCooldownTextSize:SetPoint("TOP", totemIndicatorHideNameAndShiftIconDown, "BOTTOM", 40, -48)
    CreateTooltip(totemIndicatorDefaultCooldownTextSize, "Size of the default Blizz CD text.\n\nWill not work with OmniCC.")

    local totemIndicatorNoAnimation = CreateCheckbox("totemIndicatorNoAnimation", "Anim", contentFrame)
    totemIndicatorNoAnimation:SetPoint("LEFT", totemIndicatorDefaultCooldownTextSize, "RIGHT", 0, 3)
    CreateTooltipTwo(totemIndicatorNoAnimation, "No Animation", "Stops the pulsing animation on important npcs")

    ----------------------
    -- Target indicator
    ----------------------
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubTarget:SetText("Target Indicator")

    CreateBorderBox(anchorSubTarget)

    anchorSubTarget.icon = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubTarget.icon:SetTexture(BBP.targetIndicatorIconReplacement)
    anchorSubTarget.icon:SetRotation(math.rad(180))
    anchorSubTarget.icon:SetSize(48, 32)
    anchorSubTarget.icon:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

    local targetIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "targetIndicatorScale")
    targetIndicatorScale:SetPoint("TOP", anchorSubTarget, "BOTTOM", 0, -15)

    local targetIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "targetIndicatorXPos", "X")
    targetIndicatorXPos:SetPoint("TOP", targetIndicatorScale, "BOTTOM", 0, -15)

    local targetIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "targetIndicatorYPos", "Y")
    targetIndicatorYPos:SetPoint("TOP", targetIndicatorXPos, "BOTTOM", 0, -15)

    local targetIndicatorDropdown = CreateAnchorDropdown(
        "targetIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "targetIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = targetIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local targetIndicatorHideIcon = CreateCheckbox("targetIndicatorHideIcon", "Hide Target Marker", contentFrame)
    targetIndicatorHideIcon:SetPoint("TOPLEFT", targetIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local targetIndicatorColorNameplate = CreateCheckbox("targetIndicatorColorNameplate", "Color healthbar", contentFrame)
    targetIndicatorColorNameplate:SetPoint("TOPLEFT", targetIndicatorHideIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetIndicatorColorName = CreateCheckbox("targetIndicatorColorName", "Color name", contentFrame)
    targetIndicatorColorName:SetPoint("TOPLEFT", targetIndicatorColorNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    if BetterBlizzPlatesDB.targetIndicatorColorNameplate then
        targetIndicatorColorNameplate.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
    end

    if BetterBlizzPlatesDB.targetIndicatorColorName then
        targetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.targetIndicatorColorNameplateRGB))
    end

    local function OpenColorPicker()
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

    local targetColorButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    targetColorButton:SetText("Color")
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

    local targetIndicatorChangeTexture = CreateCheckbox("targetIndicatorChangeTexture", "Re-texture healthbar", contentFrame)
    targetIndicatorChangeTexture:SetPoint("TOPLEFT", targetIndicatorColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetIndicatorChangeTexture, "Re-texture the healthbar of your current target.")

    local targetIndicatorTexture = CreateTextureDropdown(
        "targetIndicatorTexture",
        targetIndicatorChangeTexture,
        "Select Texture",
        "targetIndicatorTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = targetIndicatorChangeTexture, x = -16, y = -20, label = "Texture" },
        125
    )

    targetIndicatorChangeTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            LibDD:UIDropDownMenu_EnableDropDown(targetIndicatorTexture)
        else
            LibDD:UIDropDownMenu_DisableDropDown(targetIndicatorTexture)
        end
    end)


    ----------------------
    -- Raid Indicator
    ----------------------
    local anchorSubRaidmark = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubRaidmark:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, thirdLineY)
    anchorSubRaidmark:SetText("Raidmarker")

    CreateBorderBox(anchorSubRaidmark)

    anchorSubRaidmark.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubRaidmark.t:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_3")
    anchorSubRaidmark.t:SetSize(32, 32)
    anchorSubRaidmark.t:SetPoint("BOTTOM", anchorSubRaidmark, "TOP", 0, 3)

    BBP.raidmarkIndicator2 = CreateCheckbox("raidmarkIndicator", "Move raidmarker", contentFrame, nil, BBP.ChangeRaidmarker)
    CreateTooltip(BBP.raidmarkIndicator2, "Enable this to move raidmarker on nameplates")

    local hideRaidmarkIndicator = CreateCheckbox("hideRaidmarkIndicator", "Hide raidmarker", contentFrame)
    hideRaidmarkIndicator:SetPoint("TOPLEFT", BBP.raidmarkIndicator2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    anchorSubRaidmark.box3 = CreateCheckbox("raidmarkerPvPOnly", "Only move in PvP", contentFrame)
    anchorSubRaidmark.box3:SetPoint("TOPLEFT", hideRaidmarkIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubRaidmark.box3, "Only move in PvP", "Will only move the raidmarker in PvP and stay in default location elsewhere.")
    --CreateTooltip(hideRaidmarkIndicator, "Hide all raidmarkers on nameplates\n\n(Class Indicator and Party Pointer has their own setting\nto only hide on those specific nameplates where those icons show)")
    CreateTooltipTwo(hideRaidmarkIndicator, "Hide Raidmarker", "Hide all raidmarkers on nameplates", "Class Indicator and Party Pointer has their own setting to only hide on those specific nameplates where those icons show", anchor, cvarName)
    --(widget, title, mainText, subText, anchor, cvarName)
    local raidmarkIndicatorScale = CreateSlider(BBP.raidmarkIndicator2, "Size", 0.6, 2.5, 0.01, "raidmarkIndicatorScale")
    raidmarkIndicatorScale:SetPoint("TOP", anchorSubRaidmark, "BOTTOM", 0, -15)

    local raidmarkIndicatorXPos = CreateSlider(BBP.raidmarkIndicator2, "x offset", -50, 50, 1, "raidmarkIndicatorXPos", "X")
    raidmarkIndicatorXPos:SetPoint("TOP", raidmarkIndicatorScale, "BOTTOM", 0, -15)

    local raidmarkIndicatorYPos = CreateSlider(BBP.raidmarkIndicator2, "y offset", -50, 50, 1, "raidmarkIndicatorYPos", "Y")
    raidmarkIndicatorYPos:SetPoint("TOP", raidmarkIndicatorXPos, "BOTTOM", 0, -15)

    local raidmarkIndicatorDropdown = CreateAnchorDropdown(
        "raidmarkIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "raidmarkIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = raidmarkIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    --BBP.raidmarkIndicator2 = CreateCheckbox("raidmarkIndicator", "Change raidmarker pos", contentFrame, nil, BBP.ChangeRaidmarker)
    BBP.raidmarkIndicator2:SetPoint("TOPLEFT", raidmarkIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    function BBP.TempScuffedRadio()
        if BetterBlizzPlatesDB.raidmarkIndicator then
            CheckAndToggleCheckboxes(BBP.raidmarkIndicator2)
            LibDD:UIDropDownMenu_EnableDropDown(raidmarkIndicatorDropdown)
        else
            CheckAndToggleCheckboxes(BBP.raidmarkIndicator2)
            LibDD:UIDropDownMenu_DisableDropDown(raidmarkIndicatorDropdown)
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
    anchorSubquest:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, thirdLineY)
    anchorSubquest:SetText("Quest Indicator")

    CreateBorderBox(anchorSubquest)

    local questIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    questIcon2:SetAtlas("smallquestbang")
    questIcon2:SetSize(44, 44)
    questIcon2:SetPoint("BOTTOM", anchorSubquest, "TOP", 0, -3)

    local questIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "questIndicatorScale")
    questIndicatorScale:SetPoint("TOP", anchorSubquest, "BOTTOM", 0, -15)

    local questIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "questIndicatorXPos", "X")
    questIndicatorXPos:SetPoint("TOP", questIndicatorScale, "BOTTOM", 0, -15)

    local questIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "questIndicatorYPos", "Y")
    questIndicatorYPos:SetPoint("TOP", questIndicatorXPos, "BOTTOM", 0, -15)

    local questIndicatorDropdown = CreateAnchorDropdown(
        "questIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "questIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = questIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local questTestIcons2 = CreateCheckbox("questIndicatorTestMode", "Test", contentFrame)
    questTestIcons2:SetPoint("TOPLEFT", questIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    ----------------------
    -- Focus Target Indicator
    ----------------------
    local anchorSubFocus = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFocus:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, secondLineY)
    anchorSubFocus:SetText("Focus Target Indicator")

    CreateBorderBox(anchorSubFocus)

    local focusIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusIcon:SetTexture(BBP.focusIndicatorIconReplacement)
    focusIcon:SetSize(40, 40)
    focusIcon:SetPoint("BOTTOM", anchorSubFocus, "TOP", 0, -2)

    local focusTargetIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 3, 0.01, "focusTargetIndicatorScale")
    focusTargetIndicatorScale:SetPoint("TOP", anchorSubFocus, "BOTTOM", 0, -15)

    local focusTargetIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "focusTargetIndicatorXPos", "X")
    focusTargetIndicatorXPos:SetPoint("TOP", focusTargetIndicatorScale, "BOTTOM", 0, -15)

    local focustargetIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "focusTargetIndicatorYPos", "Y")
    focustargetIndicatorYPos:SetPoint("TOP", focusTargetIndicatorXPos, "BOTTOM", 0, -15)

    local focusTargetIndicatorDropdown = CreateAnchorDropdown(
        "focusTargetIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "focusTargetIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = focustargetIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local focusTargetTestIcons2 = CreateCheckbox("focusTargetIndicatorTestMode", "Test", contentFrame)
    focusTargetTestIcons2:SetPoint("TOPLEFT", focusTargetIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local focusTargetIndicatorColorName = CreateCheckbox("focusTargetIndicatorColorName", "Color name", contentFrame)
    focusTargetIndicatorColorName:SetPoint("LEFT", focusTargetTestIcons2.Text, "RIGHT", 0, 0)

    if BetterBlizzPlatesDB.focusTargetIndicatorColorName then
        focusTargetIndicatorColorName.Text:SetTextColor(unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB))
    end

    local focusTargetIndicatorColorNameplate = CreateCheckbox("focusTargetIndicatorColorNameplate", "Color healthbar", contentFrame)
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
    focusColorButton:SetText("Color")
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

    local focusTargetIndicatorChangeTexture = CreateCheckbox("focusTargetIndicatorChangeTexture", "Re-texture healthbar", contentFrame)
    focusTargetIndicatorChangeTexture:SetPoint("TOPLEFT", focusTargetIndicatorColorNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicatorChangeTexture, "Re-texture the healthbar of the focus target")

    local focusTargetIndicatorTexture = CreateTextureDropdown(
        "focusTargetIndicatorTexture",
        focusTargetIndicatorChangeTexture,
        "Select Texture",
        "focusTargetIndicatorTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = focusTargetIndicatorChangeTexture, x = -16, y = -20, label = "Texture" },
        125
    )

    focusTargetIndicatorChangeTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            LibDD:UIDropDownMenu_EnableDropDown(focusTargetIndicatorTexture)
        else
            LibDD:UIDropDownMenu_DisableDropDown(focusTargetIndicatorTexture)
        end
    end)

    ----------------------
    -- Execute Indicator
    ----------------------
    local anchorSubExecute = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubExecute:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY)
    anchorSubExecute:SetText("Execute Indicator")

    CreateBorderBox(anchorSubExecute)

    anchorSubExecute.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubExecute.t:SetTexture(BBP.executeIndicatorIconReplacement)
    anchorSubExecute.t:SetSize(50, 54)
    anchorSubExecute.t:SetPoint("BOTTOM", anchorSubExecute, "TOP", 0, -10)

    local executeIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 2.5, 0.01, "executeIndicatorScale")
    executeIndicatorScale:SetPoint("TOP", anchorSubExecute, "BOTTOM", 0, -15)

    local executeIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "executeIndicatorXPos", "X")
    executeIndicatorXPos:SetPoint("TOP", executeIndicatorScale, "BOTTOM", 0, -15)

    local executeIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "executeIndicatorYPos", "Y")
    executeIndicatorYPos:SetPoint("TOP", executeIndicatorXPos, "BOTTOM", 0, -15)

    local executeIndicatorDropdown = CreateAnchorDropdown(
        "executeIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "executeIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = executeIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local executeTestIcons2 = CreateCheckbox("executeIndicatorTestMode", "Test", contentFrame)
    executeTestIcons2:SetPoint("TOPLEFT", executeIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local executeIndicatorAlwaysOn = CreateCheckbox("executeIndicatorAlwaysOn", "Always on", contentFrame)
    executeIndicatorAlwaysOn:SetPoint("TOPLEFT", executeTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorAlwaysOn, "Always display health percentage")

    local executeIndicatorFriendly = CreateCheckbox("executeIndicatorFriendly", "Friendly", contentFrame)
    executeIndicatorFriendly:SetPoint("TOPLEFT", executeIndicatorAlwaysOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorFriendly, "Show on friendly nameplates")

    anchorSubExecute.executeIndicatorUseTexture = CreateCheckbox("executeIndicatorUseTexture", "Use Texture", contentFrame)
    anchorSubExecute.executeIndicatorUseTexture:SetPoint("TOPLEFT", executeIndicatorFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorUseTexture, "Use Texture", "Show a line on execute range instead of text.")
    anchorSubExecute.executeIndicatorUseTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            DisableElement(executeIndicatorScale)
            DisableElement(executeIndicatorXPos)
            DisableElement(executeIndicatorYPos)
            LibDD:UIDropDownMenu_DisableDropDown(executeIndicatorDropdown)
        else
            EnableElement(executeIndicatorScale)
            EnableElement(executeIndicatorXPos)
            EnableElement(executeIndicatorYPos)
            LibDD:UIDropDownMenu_EnableDropDown(executeIndicatorDropdown)
        end
    end)
    if BetterBlizzPlatesDB.executeIndicatorUseTexture then
        DisableElement(executeIndicatorScale)
        DisableElement(executeIndicatorXPos)
        DisableElement(executeIndicatorYPos)
        LibDD:UIDropDownMenu_DisableDropDown(executeIndicatorDropdown)
    end

    local executeIndicatorNotOnFullHp = CreateCheckbox("executeIndicatorNotOnFullHp", "< 100%", contentFrame)
    executeIndicatorNotOnFullHp:SetPoint("LEFT", executeIndicatorAlwaysOn.text, "RIGHT", 2, 0)
    CreateTooltip(executeIndicatorNotOnFullHp, "Hide on 100%")

    local executeIndicatorPercentSymbol = CreateCheckbox("executeIndicatorPercentSymbol", "% Symbol", contentFrame)
    executeIndicatorPercentSymbol:SetPoint("TOPLEFT", executeIndicatorNotOnFullHp, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorPercentSymbol, "Show % Symbol")

    anchorSubExecute.executeIndicatorTargetOnly = CreateCheckbox("executeIndicatorTargetOnly", "Target", contentFrame)
    anchorSubExecute.executeIndicatorTargetOnly:SetPoint("TOPLEFT", executeIndicatorPercentSymbol, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorTargetOnly, "Target Only", "Only show execute indicator on your current Target.")

    local executeIndicatorShowDecimal = CreateCheckbox("executeIndicatorShowDecimal", "Decimal", contentFrame)
    executeIndicatorShowDecimal:SetPoint("BOTTOMLEFT", executeIndicatorNotOnFullHp, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorShowDecimal, "Show decimal")

    local executeIndicatorThreshold = CreateSlider(contentFrame, "Threshold", 5, 100, 1, "executeIndicatorThreshold")
    executeIndicatorThreshold:SetPoint("TOP", executeIndicatorAlwaysOn, "BOTTOM", 58, -48)
    CreateTooltip(executeIndicatorThreshold, "Percentage of when the execute indicator should show.")

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

    ----------------------
    -- Arena Indicator
    ----------------------
    local anchorSubArena = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubArena:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorSubArena:SetText("Arena Indicator")

    CreateBorderBox(anchorSubArena)

    anchorSubArena.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubArena.t:SetAtlas("questbonusobjective")
    anchorSubArena.t:SetSize(32, 32)
    anchorSubArena.t:SetPoint("BOTTOM", anchorSubArena, "TOP", 0, 3)

    local arenaIndicatorXPos = CreateSlider(contentFrame, "ID x offset", -50, 50, 1, "arenaIdXPos", "X")
    arenaIndicatorXPos:SetPoint("TOP", anchorSubArena, "BOTTOM", 0, -15)

    local arenaIndicatorYPos = CreateSlider(contentFrame, "ID y offset", -50, 50, 1, "arenaIdYPos", "Y")
    arenaIndicatorYPos:SetPoint("TOP", arenaIndicatorXPos, "BOTTOM", 0, -15)

    local arenaSpecXPos = CreateSlider(contentFrame, "Spec x offset", -50, 50, 1, "arenaSpecXPos", "X")
    arenaSpecXPos:SetPoint("TOP", arenaIndicatorYPos, "BOTTOM", 0, -15)

    local arenaSpecYPos = CreateSlider(contentFrame, "Spec y offset", -50, 50, 1, "arenaSpecYPos", "Y")
    arenaSpecYPos:SetPoint("TOP", arenaSpecXPos, "BOTTOM", 0, -15)

    local arenaIdAnchorDropdown = CreateAnchorDropdown(
        "arenaIdAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "arenaIdAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = arenaSpecYPos, x = -16, y = -31, label = "ID Anchor" }
    )

    local arenaSpecAnchorDropdown = CreateAnchorDropdown(
        "arenaSpecAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "arenaSpecAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = arenaIdAnchorDropdown, x = 0, y = -41, label = "Spec Anchor" }
    )
    BBP.arenaSpecAnchorDropdown = arenaSpecAnchorDropdown

    local arenaIndicatorTestMode2 = CreateCheckbox("arenaIndicatorTestMode", "Test", contentFrame)
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

    local showCircleOnArenaID = CreateCheckbox("showCircleOnArenaID", "Show Circle on ID", contentFrame)
    showCircleOnArenaID:SetPoint("TOPLEFT", arenaIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCircleOnArenaID, "Show a colored circle on each ID, red green and blue\n\n(Needs some finetuning still)")

    ----------------------
    -- Class Icon
    ----------------------
    local anchorSubClassIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubClassIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubClassIcon:SetText("Class Indicator")

    CreateBorderBox(anchorSubClassIcon)

    anchorSubClassIcon.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubClassIcon.t:SetAtlas("groupfinder-icon-class-mage")
    anchorSubClassIcon.t:SetSize(33, 33)
    anchorSubClassIcon.t:SetPoint("BOTTOM", anchorSubClassIcon, "TOP", 0, 1.5)
    --anchorSubClassIcon.t:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local classIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "classIndicatorFriendlyScale", false, 72)
    classIndicatorScale:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", 36, -15)
    classIndicatorScale.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorScale, "Friendly Scale")

    anchorSubHeal.classIndicatorAlpha = CreateSlider(contentFrame, "Alpha", 0.1, 1, 0.01, "classIndicatorAlpha", false, 52)
    anchorSubHeal.classIndicatorAlpha:SetPoint("LEFT", anchorSubClassIcon.t, "RIGHT", 0, -3)
    CreateTooltipTwo(anchorSubHeal.classIndicatorAlpha, "Class Indicator Alpha")

    local classIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "classIndicatorFriendlyXPos", "X", 72)
    classIndicatorXPos:SetPoint("TOP", classIndicatorScale, "BOTTOM", 0, -15)
    classIndicatorXPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorXPos, "Friendly X Offset")

    local classIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "classIndicatorFriendlyYPos", "Y", 72)
    classIndicatorYPos:SetPoint("TOP", classIndicatorXPos, "BOTTOM", 0, -15)
    classIndicatorYPos.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorYPos, "Friendly Y Offset")

    local classIndicatorScale2 = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "classIndicatorScale", false, 72)
    classIndicatorScale2:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", -36, -15)
    classIndicatorScale2.Text:SetTextColor(1,0,0)
    CreateTooltip(classIndicatorScale2, "Enemy Scale")

    local classIndicatorXPos2 = CreateSlider(contentFrame, "x offset", -50, 50, 1, "classIndicatorXPos", "X", 72)
    classIndicatorXPos2:SetPoint("TOP", classIndicatorScale2, "BOTTOM", 0, -15)
    classIndicatorXPos2.Text:SetTextColor(1,0,0)
    CreateTooltip(classIndicatorXPos2, "Enemy X Offset")

    local classIndicatorYPos2 = CreateSlider(contentFrame, "y offset", -50, 50, 1, "classIndicatorYPos", "Y", 72)
    classIndicatorYPos2:SetPoint("TOP", classIndicatorXPos2, "BOTTOM", 0, -15)
    classIndicatorYPos2.Text:SetTextColor(1,0,0)
    CreateTooltip(classIndicatorYPos2, "Enemy Y Offset")

    local classIconDropdown = CreateAnchorDropdown(
        "classIconDropdown",
        contentFrame,
        "Select Anchor Point",
        "classIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = classIndicatorYPos, x = -90, y = -35, label = "Enemy" },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltip(classIconDropdown, "Enemy Anchor")

    local classIconDropdown2 = CreateAnchorDropdown(
        "classIconDropdown2",
        contentFrame,
        "Select Anchor Point",
        "classIndicatorFriendlyAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = classIndicatorYPos, x = -16, y = -35, label = "Friendly" },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltip(classIconDropdown2, "Friendly Anchor")

    local classIndicatorEnemy = CreateCheckbox("classIndicatorEnemy", "Enemies", contentFrame)
    classIndicatorEnemy:SetPoint("TOPLEFT", classIconDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorEnemy, "Show class indicator on enemy nameplates")

    local classIndicatorFriendly = CreateCheckbox("classIndicatorFriendly", "Friendly", contentFrame)
    classIndicatorFriendly:SetPoint("LEFT", classIndicatorEnemy.text, "RIGHT", -2, 0)
    CreateTooltip(classIndicatorFriendly, "Show class indicator on friendly nameplates")

    local classIconSquareBorder = CreateCheckbox("classIconSquareBorder", "Square", contentFrame)
    classIconSquareBorder:SetPoint("TOPLEFT", classIndicatorEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIconSquareBorder, "Square instead of circle icon for enemy.")

    local classIconSquareBorderFriendly = CreateCheckbox("classIconSquareBorderFriendly", "Square Friend", contentFrame)
    classIconSquareBorderFriendly:SetPoint("LEFT", classIconSquareBorder.text, "RIGHT", 0, 0)
    CreateTooltip(classIconSquareBorderFriendly, "Square instead of circle icon for friendly.")

    local classIconArenaOnly = CreateCheckbox("classIconArenaOnly", "Arena only", contentFrame)
    classIconArenaOnly:SetPoint("TOPLEFT", classIconSquareBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIconArenaOnly, "Show in arena only")

    local classIconBgOnly = CreateCheckbox("classIconBgOnly", "BG only", contentFrame)
    classIconBgOnly:SetPoint("LEFT", classIconArenaOnly.text, "RIGHT", 0, 0)
    CreateTooltip(classIconBgOnly, "Show in battlegrounds only")

    local classIndicatorSpecIcon = CreateCheckbox("classIndicatorSpecIcon", "Spec", contentFrame)
    classIndicatorSpecIcon:SetPoint("TOPLEFT", classIconArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorSpecIcon, "Show spec instead of class icon. (Requires Details)\n\nNote: The spec information might not always\nbe available and it will default to class icon.")

    local classIndicatorHealer = CreateCheckbox("classIndicatorHealer", "Heal", contentFrame)
    classIndicatorHealer:SetPoint("LEFT", classIndicatorSpecIcon.text, "RIGHT", -2, 0)
    CreateTooltip(classIndicatorHealer, "Show cross instead of class/spec icon on healers")

    local classIconColorBorder = CreateCheckbox("classIconColorBorder", "Color", contentFrame)
    classIconColorBorder:SetPoint("LEFT", classIndicatorHealer.text, "RIGHT", -2, 0)
    CreateTooltip(classIconColorBorder, "Class color border")

    local classIndicatorHighlight = CreateCheckbox("classIndicatorHighlight", "HL", contentFrame)
    classIndicatorHighlight:SetPoint("TOPLEFT", classIndicatorSpecIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorHighlight, "Show highlight on current target icon")

    anchorSubClassIcon.classIndicatorCCAuras = CreateCheckbox("classIndicatorCCAuras", "Show CC", contentFrame)
    anchorSubClassIcon.classIndicatorCCAuras:SetPoint("TOPLEFT", classIndicatorHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorCCAuras, "Show Crowd Control", "Replace Class/Spec Icon with Icon of Crowd Control on Friendly Players.", "This setting requires nameplate aura settings + PvP CC filter enabled.")
    anchorSubClassIcon.classIndicatorCCAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Enabled Friendly Debuffs & PvP CC filter in Nameplate Auras section.")
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

    local classIndicatorHighlightColor = CreateCheckbox("classIndicatorHighlightColor", "Color HL", contentFrame)
    classIndicatorHighlightColor:SetPoint("LEFT", classIndicatorHighlight.text, "RIGHT", -2, 0)
    CreateTooltip(classIndicatorHighlightColor, "Class color target highlight")

    local classIndicatorHideRaidMarker = CreateCheckbox("classIndicatorHideRaidMarker", "Hide", contentFrame)
    classIndicatorHideRaidMarker:SetPoint("LEFT", classIndicatorHighlightColor.text, "RIGHT", -2, 0)
    CreateTooltip(classIndicatorHideRaidMarker, "Hide RaidMarker on nameplates with class icons")

    ----------------------
    -- Party Pointer
    ----------------------
    local anchorSubPointerIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPointerIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, fourthLineY)
    anchorSubPointerIndicator:SetText("Party Pointer")

    CreateBorderBox(anchorSubPointerIndicator)

    anchorSubPointerIndicator.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubPointerIndicator.t:SetTexture(BBP.partyPointerIconReplacement)
    anchorSubPointerIndicator.t:SetSize(28, 29)
    anchorSubPointerIndicator.t:SetPoint("BOTTOM", anchorSubPointerIndicator, "TOP", -1, 5)
    anchorSubPointerIndicator.t:SetDesaturated(true)
    anchorSubPointerIndicator.t:SetVertexColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubPointerIndicator.t, "Show a class colored pointer above\nfriendly player nameplates.")

    local partyPointerScale = CreateSlider(contentFrame, "Size", 0.5, 2.2, 0.01, "partyPointerScale", false, 72)
    partyPointerScale:SetPoint("TOP", anchorSubPointerIndicator, "BOTTOM", -36, -15)

    local partyPointerWidth = CreateSlider(contentFrame, "Width", 20, 55, 1, "partyPointerWidth", false, 72)
    partyPointerWidth:SetPoint("TOP", anchorSubPointerIndicator, "BOTTOM", 36, -15)

    local partyPointerHealerScale = CreateSlider(contentFrame, "Healer Icon Size", 0.5, 2.2, 0.01, "partyPointerHealerScale")
    partyPointerHealerScale:SetPoint("TOP", partyPointerScale, "BOTTOM", 36, -15)

    local partyPointerXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "partyPointerXPos", "X")
    partyPointerXPos:SetPoint("TOP", partyPointerHealerScale, "BOTTOM", 0, -15)

    local partyPointerYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "partyPointerYPos", "Y")
    partyPointerYPos:SetPoint("TOP", partyPointerXPos, "BOTTOM", 0, -15)

    local partyPointerDropdown = CreateAnchorDropdown(
        "partyPointerDropdown",
        contentFrame,
        "Select Anchor Point",
        "partyPointerAnchor",
        function(arg1) 
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = partyPointerYPos, x = -16, y = -35, label = "Anchor" }
    )

    local partyPointerTestMode = CreateCheckbox("partyPointerTestMode", "Test", contentFrame)
    partyPointerTestMode:SetPoint("TOPLEFT", partyPointerDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local partyPointerHideRaidmarker = CreateCheckbox("partyPointerHideRaidmarker", "No raidmarker", contentFrame)
    partyPointerHideRaidmarker:SetPoint("LEFT", partyPointerTestMode.text, "RIGHT", 0, 0)
    CreateTooltip(partyPointerHideRaidmarker, "Hide raidmarker on nameplates with party pointer.")

    local partyPointerArenaOnly = CreateCheckbox("partyPointerArenaOnly", "Arena only", contentFrame)
    partyPointerArenaOnly:SetPoint("TOPLEFT", partyPointerTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(partyPointerArenaOnly, "Show in Arena only")

    local partyPointerBgOnly = CreateCheckbox("partyPointerBgOnly", "BG only", contentFrame)
    partyPointerBgOnly:SetPoint("LEFT", partyPointerArenaOnly.text, "RIGHT", 0, 0)
    CreateTooltip(partyPointerBgOnly, "Show in Battlegrounds only")

    local partyPointerClassColor = CreateCheckbox("partyPointerClassColor", "Class color", contentFrame)
    partyPointerClassColor:SetPoint("TOPLEFT", partyPointerArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(partyPointerClassColor, "Class color pointer")

    local partyPointerTargetIndicator = CreateCheckbox("partyPointerTargetIndicator", "Target", contentFrame)
    partyPointerTargetIndicator:SetPoint("TOPLEFT", partyPointerClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyPointerTargetIndicator, "Target Indicator", "Replace the texture for your current target with one that has an exclamation mark on it.")

    local partyPointerHealer = CreateCheckbox("partyPointerHealer", "Healer", contentFrame)
    partyPointerHealer:SetPoint("LEFT", partyPointerClassColor.text, "RIGHT", 0, 0)
    CreateTooltip(partyPointerHealer, "Show a cross on top of the pointer on healers\n(Requires addon Details and might not always show in world but fine in bgs and arena).")

    anchorSubPointerIndicator.partyPointerHighlight = CreateCheckbox("partyPointerHighlight", "Highlight", contentFrame)
    anchorSubPointerIndicator.partyPointerHighlight:SetPoint("TOPLEFT", partyPointerHealer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlight, "Highlight", "Show a highlight around the Icon.\n\n|cff32f795Right-click to change Highlight Color.|r", "Currently only fit for original texture, will look weird on the others.")
    anchorSubPointerIndicator.partyPointerHighlight:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.partyPointerHighlightRGB, BBP.RefreshAllNameplates)
        end
    end)

    local partyPointerHealerReplace = CreateCheckbox("partyPointerHealerReplace", "Replace", contentFrame)
    partyPointerHealerReplace:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyPointerHealerReplace, "Replace Party Pointer with Healer Icon", "Replace the party pointer with healer icon instead of showing on the top.")

    local partyPointerHideAll = CreateCheckbox("partyPointerHideAll", "Hide all", contentFrame)
    partyPointerHideAll:SetPoint("TOPLEFT", partyPointerTargetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyPointerHideAll, "Hide All", "Hide everything except the Party Pointer for friendly nameplates that have the Party Pointer on them. Hides healthbar, castbar & name.")

    anchorSubPointerIndicator.partyPointerCCAuras = CreateCheckbox("partyPointerCCAuras", "Show CC", contentFrame)
    anchorSubPointerIndicator.partyPointerCCAuras:SetPoint("TOPLEFT", partyPointerHideAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerCCAuras, "Show CC", "Show CC Overlay on Party Pointer", "This setting requires nameplate aura settings + PvP CC filter enabled.")

    anchorSubPointerIndicator.partyPointerHighlightScale = CreateSlider(contentFrame, "PP: Highlight Size", 0.8, 1.7, 0.01, "partyPointerHighlightScale", "X")
    anchorSubPointerIndicator.partyPointerHighlightScale:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerCCAuras, "BOTTOMLEFT", 2, -18)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlightScale, "Change the size of the Highlight. Requires Highlight enabled.")

   ----------------------
    -- Fake Name Reposition
    ----------------------
    local anchorSubFakeName = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFakeName:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, fourthLineY)
    anchorSubFakeName:SetText("Name Reposition")

    CreateBorderBox(anchorSubFakeName)

    anchorSubFakeName.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFakeName.t:SetAtlas("MiniMap-PositionArrows")
    anchorSubFakeName.t:SetSize(32, 44)
    anchorSubFakeName.t:SetPoint("BOTTOM", anchorSubFakeName, "TOP", 0, -3)
    anchorSubFakeName.t:SetRotation(math.pi / 2)
    anchorSubFakeName.t:SetDesaturated(true)
    anchorSubFakeName.t:SetVertexColor(1,1,0.1)

    anchorSubFakeName.useFakeName = CreateCheckbox("useFakeName", "Enable Name Reposition", contentFrame)
    anchorSubFakeName.useFakeName:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    anchorSubFakeName.fakeNameXPos = CreateSlider(anchorSubFakeName.useFakeName, "|cffFF0000Enemy x offset|r", -50, 50, 1, "fakeNameXPos", "X")
    anchorSubFakeName.fakeNameXPos:SetPoint("TOP", anchorSubFakeName, "BOTTOM", 0, -15)

    anchorSubFakeName.fakeNameYPos = CreateSlider(anchorSubFakeName.useFakeName, "|cffFF0000Enemy y offset|r", -50, 50, 1, "fakeNameYPos", "Y")
    anchorSubFakeName.fakeNameYPos:SetPoint("TOP", anchorSubFakeName.fakeNameXPos, "BOTTOM", 0, -15)

    anchorSubFakeName.fakeNameFriendlyXPos = CreateSlider(anchorSubFakeName.useFakeName, "|cff0CC2FFFriendly x offset|r", -50, 50, 1, "fakeNameFriendlyXPos", "X")
    anchorSubFakeName.fakeNameFriendlyXPos:SetPoint("TOP", anchorSubFakeName.fakeNameYPos, "BOTTOM", 0, -15)

    anchorSubFakeName.fakeNameFriendlyYPos = CreateSlider(anchorSubFakeName.useFakeName, "|cff0CC2FFFriendly y offset|r", -50, 50, 1, "fakeNameFriendlyYPos", "Y")
    anchorSubFakeName.fakeNameFriendlyYPos:SetPoint("TOP", anchorSubFakeName.fakeNameFriendlyXPos, "BOTTOM", 0, -15)

    local fakeNameAnchorDropdown = CreateAnchorDropdown(
        "partyPointerDropdown",
        contentFrame,
        "Select Anchor Point",
        "fakeNameAnchor",
        function(arg1) 
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubFakeName.fakeNameFriendlyYPos, x = -16, y = -33, label = "Name Anchor Point" }
    )
    CreateTooltipTwo(fakeNameAnchorDropdown, "Name Anchor Point", "Which side of the name should be the anchor point.")

    local fakeNameAnchorRelativeDropdown = CreateAnchorDropdown(
        "arenaSpecAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "fakeNameAnchorRelative",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameAnchorDropdown, x = 0, y = -41, label = "Healthbar Anchor Point" }
    )
    CreateTooltipTwo(fakeNameAnchorRelativeDropdown, "Healthbar Anchor Point", "Which side of the healthbar the name should get anchored to.")

    anchorSubFakeName.useFakeName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            LibDD:UIDropDownMenu_EnableDropDown(fakeNameAnchorDropdown)
            LibDD:UIDropDownMenu_EnableDropDown(fakeNameAnchorRelativeDropdown)
            if BetterBlizzPlates.arenaSpecAnchor == "TOP" then
                BetterBlizzPlates.arenaSpecAnchor = "CENTER"
            end
        else
            LibDD:UIDropDownMenu_DisableDropDown(fakeNameAnchorDropdown)
            LibDD:UIDropDownMenu_DisableDropDown(fakeNameAnchorRelativeDropdown)
            if BetterBlizzPlates.arenaSpecAnchor == "CENTER" then
                BetterBlizzPlates.arenaSpecAnchor = "TOP"
            end
        end
        LibDD:UIDropDownMenu_SetText(BBP.arenaSpecAnchorDropdown, BetterBlizzPlatesDB["arenaSpecAnchor"])
    end)

    if not BetterBlizzPlatesDB.useFakeName then
        LibDD:UIDropDownMenu_DisableDropDown(fakeNameAnchorDropdown)
        LibDD:UIDropDownMenu_DisableDropDown(fakeNameAnchorRelativeDropdown)
    end

    --local useFakeName = CreateCheckbox("useFakeName", "Enable Name Reposition", contentFrame) --moved up
    anchorSubFakeName.useFakeName:SetPoint("TOPLEFT", fakeNameAnchorRelativeDropdown, "BOTTOMLEFT", 16, 8)
    anchorSubFakeName.useFakeName:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(anchorSubFakeName.useFakeName)
    end)
    CreateTooltip(anchorSubFakeName.useFakeName, "Enables name repositioning by using a \"fake name\" and hiding the real one.")
    CreateTooltip(anchorSubFakeName.t, "Enables name repositioning by using a \"fake name\" and hiding the real one.")

    anchorSubFakeName.useFakeNameAnchorBottom = CreateCheckbox("useFakeNameAnchorBottom", "Anchor friend", anchorSubFakeName.useFakeName)
    anchorSubFakeName.useFakeNameAnchorBottom:SetPoint("TOPLEFT", anchorSubFakeName.useFakeName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubFakeName.useFakeNameAnchorBottom, "Anchor Friendly Name to Bottom", "Anchor the name on friendly nameplates to the bottom of the healthbar instead of on top so the name no longer shifts up when targeted.\nThis will override the other anchor settings.")

    local fakeNameScaleWithParent = CreateCheckbox("fakeNameScaleWithParent", "Scale", anchorSubFakeName.useFakeName)
    fakeNameScaleWithParent:SetPoint("LEFT", anchorSubFakeName.useFakeNameAnchorBottom.text, "RIGHT", 0, 0)
    CreateTooltipTwo(fakeNameScaleWithParent, "Scale with Nameplate", "Scale the Name with the nameplate.\nBy default this is off.")

    anchorSubFakeName.fakeNameRaiseStrata = CreateCheckbox("fakeNameRaiseStrata", "Raise Strata", anchorSubFakeName.useFakeName)
    anchorSubFakeName.fakeNameRaiseStrata:SetPoint("TOPLEFT", anchorSubFakeName.useFakeNameAnchorBottom, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubFakeName.fakeNameRaiseStrata, "Raise Strata", "Raise the frame strata of name so it overlaps healthbar.")
    anchorSubFakeName.fakeNameRaiseStrata:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    ----------------------
    -- Health Numbers
    ----------------------
    local anchorSubHealthNumbers = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHealthNumbers:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, fourthLineY)
    anchorSubHealthNumbers:SetText("Health Numbers")

    anchorSubHealthNumbers.border = CreateBorderBox(anchorSubHealthNumbers)

    anchorSubHealthNumbers.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubHealthNumbers.t:SetTexture(BBP.healthNumbersIconReplacement)
    anchorSubHealthNumbers.t:SetSize(44, 44)
    anchorSubHealthNumbers.t:SetPoint("BOTTOM", anchorSubHealthNumbers, "TOP", 0, -5)

    local healthNumbersScale = CreateSlider(contentFrame, "Size", 0.5, 2.5, 0.01, "healthNumbersScale")
    healthNumbersScale:SetPoint("TOP", anchorSubHealthNumbers, "BOTTOM", 0, -15)

    local healthNumbersXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "healthNumbersXPos", "X")
    healthNumbersXPos:SetPoint("TOP", healthNumbersScale, "BOTTOM", 0, -15)

    local healthNumbersYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "healthNumbersYPos", "Y")
    healthNumbersYPos:SetPoint("TOP", healthNumbersXPos, "BOTTOM", 0, -15)

    local healthNumbersDropdown = CreateAnchorDropdown(
        "healthNumbersDropdown",
        contentFrame,
        "Select Anchor Point",
        "healthNumbersAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = healthNumbersYPos, x = -16, y = -35, label = "Anchor" }
    )

    local healthNumbersTestMode = CreateCheckbox("healthNumbersTestMode", "Test", contentFrame)
    healthNumbersTestMode:SetPoint("TOPLEFT", healthNumbersDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local healthNumbersFriendly = CreateCheckbox("healthNumbersFriendly", "Friendly", contentFrame)
    healthNumbersFriendly:SetPoint("LEFT", healthNumbersTestMode.text, "RIGHT", 20, 0)
    CreateTooltip(healthNumbersFriendly, "Show on friendly nameplates")

    local healthNumbersPercentage = CreateCheckbox("healthNumbersPercentage", "Percent", contentFrame)
    healthNumbersPercentage:SetPoint("TOPLEFT", healthNumbersTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersPercentage, "Show Percent", "Show health values in percentages")

    local healthNumbersPercentSymbol = CreateCheckbox("healthNumbersPercentSymbol", "% Symbol", contentFrame)
    healthNumbersPercentSymbol:SetPoint("TOPLEFT", healthNumbersFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersPercentSymbol, "Show Percent Symbol", "Show the percent symbol (%).")

    local healthNumbersShowDecimal = CreateCheckbox("healthNumbersShowDecimal", "Decimal", contentFrame)
    healthNumbersShowDecimal:SetPoint("TOPLEFT", healthNumbersPercentage, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(healthNumbersShowDecimal, "Show decimal")

    local healthNumbersNotOnFullHp = CreateCheckbox("healthNumbersNotOnFullHp", "< 100%", contentFrame)
    healthNumbersNotOnFullHp:SetPoint("TOPLEFT", healthNumbersPercentSymbol, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersNotOnFullHp, "Hide on full HP", "Hide the health text on nameplates with full health.")

    -- Extended Settings Button
    anchorSubHealthNumbers.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    anchorSubHealthNumbers.extendedSettingsButton:SetSize(120, 25)
    anchorSubHealthNumbers.extendedSettingsButton:SetPoint("TOP", anchorSubHealthNumbers, "BOTTOM", 0, -212)
    anchorSubHealthNumbers.extendedSettingsButton:SetText("More options")
    CreateTooltip(anchorSubHealthNumbers.extendedSettingsButton, "Open more settings for Health Numbers")

    -- Extended Settings Frame
    anchorSubHealthNumbers.extendedSettings = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel, "DefaultPanelFlatTemplate")
    -- anchorSubHealthNumbers.extendedSettings:SetAllPoints(anchorSubHealthNumbers.border)
    anchorSubHealthNumbers.extendedSettings:SetSize(anchorSubHealthNumbers.border:GetHeight()+40, 335)
    anchorSubHealthNumbers.extendedSettings:SetPoint("BOTTOMRIGHT", anchorSubHealthNumbers.border, "BOTTOMLEFT", 87, -125)
    anchorSubHealthNumbers.extendedSettings:SetFrameStrata("DIALOG")
    anchorSubHealthNumbers.extendedSettings:SetIgnoreParentAlpha(true)
    anchorSubHealthNumbers.extendedSettings:EnableMouse(true)
    anchorSubHealthNumbers.extendedSettings:Hide()
    anchorSubHealthNumbers.extendedSettings.name = "Advanced Settings"
    anchorSubHealthNumbers.extendedSettings:SetTitle("Health Numbers")

    anchorSubHealthNumbers.closeButton = CreateFrame("Button", nil, anchorSubHealthNumbers.extendedSettings, "UIPanelCloseButton")
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

    local healthNumbersUseMillions = CreateCheckbox("healthNumbersUseMillions", "Format Million", anchorSubHealthNumbers.extendedSettings)
    healthNumbersUseMillions:SetPoint("TOPLEFT", anchorSubHealthNumbers.extendedSettings, "TOPLEFT", 10, -23)
    CreateTooltipTwo(healthNumbersUseMillions, "Format Million", "Display health values above 1million as 1m instead of 1000k")

    local healthNumbersCurrentFull = CreateCheckbox("healthNumbersCurrentFull", "Current / Max", anchorSubHealthNumbers.extendedSettings)
    healthNumbersCurrentFull:SetPoint("TOPLEFT", healthNumbersUseMillions, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersCurrentFull, "Current / Max", "Show current health and max health.\nFor example 69k/420k")

    local healthNumbersCombined = CreateCheckbox("healthNumbersCombined", "Health - Percent", anchorSubHealthNumbers.extendedSettings)
    healthNumbersCombined:SetPoint("TOPLEFT", healthNumbersCurrentFull, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersCombined, "Health - Percent", "Shows health & percent. For example 20m / 100%")

    local healthNumbersOnlyInCombat = CreateCheckbox("healthNumbersOnlyInCombat", "Only in Combat", anchorSubHealthNumbers.extendedSettings)
    healthNumbersOnlyInCombat:SetPoint("TOPLEFT", healthNumbersCombined, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersOnlyInCombat, "Only in Combat", "Only show health values on nameplates in combat")

    local healthNumbersSwapped = CreateCheckbox("healthNumbersSwapped", "Swap Numbers", anchorSubHealthNumbers.extendedSettings)
    healthNumbersSwapped:SetPoint("TOPLEFT", healthNumbersOnlyInCombat, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersSwapped, "Swap Numbers", "Swap the numbers to be percent first. 100% - 200k")

    local healthNumbersTargetOnly = CreateCheckbox("healthNumbersTargetOnly", "Show on Target only", anchorSubHealthNumbers.extendedSettings)
    healthNumbersTargetOnly:SetPoint("TOPLEFT", healthNumbersSwapped, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healthNumbersTargetOnly, "Show on Target only", "Only show the health values on current target")

    anchorSubHealthNumbers.healthNumbersPlayers = CreateCheckbox("healthNumbersPlayers", "Enable on Players", anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersPlayers:SetPoint("TOPLEFT", healthNumbersTargetOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersPlayers, "Players", "Enable health numbers on players")

    anchorSubHealthNumbers.healthNumbersHideSelf = CreateCheckbox("healthNumbersHideSelf", "Hide on Personal", anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersHideSelf:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersPlayers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersHideSelf, "Hide on Personal Resource Display", "Hide the health numbers on personal resource bar")

    anchorSubHealthNumbers.healthNumbersNpcs = CreateCheckbox("healthNumbersNpcs", "Enable on NPCs", anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersNpcs:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersHideSelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersNpcs, "Enable on NPCs", "Enable health numbers on NPCs")

    anchorSubHealthNumbers.healthNumbersClassColor = CreateCheckbox("healthNumbersClassColor", "Class Color Text", anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersClassColor:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersNpcs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersClassColor, "Class Color Text", "Class color the text for players.")

    anchorSubHealthNumbers.healthNumbersTextJustify = CreateAnchorDropdown(
        "healthNumbersTextJustifyDropdown",
        anchorSubHealthNumbers.extendedSettings,
        "Select Text Alignment",
        "healthNumbersJustify",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = anchorSubHealthNumbers.healthNumbersClassColor, x = 0, y = -45, label = "Text Alignment" },nil,nil,{"CENTER", "LEFT", "RIGHT"}
    )


    anchorSubHealthNumbers.healthNumbersFontOutline = CreateAnchorDropdown(
        "healthNumbersFontOutlineDropdown",
        anchorSubHealthNumbers.extendedSettings,
        "Select Font Outline",
        "healthNumbersFontOutline",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = anchorSubHealthNumbers.healthNumbersTextJustify, x = 0, y = -45, label = "Font Outline" },nil,nil,{"THICKOUTLINE", "OUTLINE"}
    )


    ----------------------
    -- Threat Colors
    ----------------------
    local anchorThreatColor = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorThreatColor:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, fourthLineY)
    anchorThreatColor:SetText("Threat Colors")

    CreateBorderBox(anchorThreatColor)

    anchorThreatColor.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorThreatColor.t:SetAtlas("Raid")
    anchorThreatColor.t:SetSize(30, 30)
    anchorThreatColor.t:SetPoint("BOTTOM", anchorThreatColor, "TOP", 0, 2)

    local tankFullAggroColorRGB = CreateColorBox(contentFrame, "tankFullAggroColorRGB", "Tank: Full Aggro")
    tankFullAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor, "BOTTOMLEFT", -28, -5)

    anchorThreatColor.tankLosingAggroColorRGB = CreateColorBox(contentFrame, "tankLosingAggroColorRGB", "Tank: Losing Aggro")
    anchorThreatColor.tankLosingAggroColorRGB:SetPoint("TOPLEFT", tankFullAggroColorRGB, "BOTTOMLEFT", 0, -2)

    anchorThreatColor.tankOffTankAggroColorRGB = CreateColorBox(contentFrame, "tankOffTankAggroColorRGB", "Tank: Off-Tank Aggro")
    anchorThreatColor.tankOffTankAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor.tankLosingAggroColorRGB, "BOTTOMLEFT", 0, -2)

    local tankNoAggroColorRGB = CreateColorBox(contentFrame, "tankNoAggroColorRGB", "Tank: No Aggro")
    tankNoAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor.tankOffTankAggroColorRGB, "BOTTOMLEFT", 0, -2)

    local dpsOrHealFullAggroColorRGB = CreateColorBox(contentFrame, "dpsOrHealFullAggroColorRGB", "DPS/Heal: Full Aggro")
    dpsOrHealFullAggroColorRGB:SetPoint("TOPLEFT", tankNoAggroColorRGB, "BOTTOMLEFT", 0, -8)

    anchorThreatColor.dpsOrHealTargetAggroColorRGB = CreateColorBox(contentFrame, "dpsOrHealTargetAggroColorRGB", "DPS/Heal: Targeted")
    anchorThreatColor.dpsOrHealTargetAggroColorRGB:SetPoint("TOPLEFT", dpsOrHealFullAggroColorRGB, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(anchorThreatColor.dpsOrHealTargetAggroColorRGB, "Color when being Targeted but without aggro.")

    local dpsOrHealNoAggroColorRGB = CreateColorBox(contentFrame, "dpsOrHealNoAggroColorRGB", "DPS/Heal: No Aggro")
    dpsOrHealNoAggroColorRGB:SetPoint("TOPLEFT", anchorThreatColor.dpsOrHealTargetAggroColorRGB, "BOTTOMLEFT", 0, -2)

    anchorThreatColor.threatColorAlwaysOn = CreateCheckbox("threatColorAlwaysOn", "Always on", contentFrame)
    anchorThreatColor.threatColorAlwaysOn:SetPoint("TOPLEFT", dpsOrHealNoAggroColorRGB, "BOTTOMLEFT", 0, 0)
    CreateTooltipTwo(anchorThreatColor.threatColorAlwaysOn, "Always on", "Always color threat, even outside of PvE content.")

    anchorThreatColor.enemyColorThreatCombatOnly = CreateCheckbox("enemyColorThreatCombatOnly", "Combat only", contentFrame)
    anchorThreatColor.enemyColorThreatCombatOnly:SetPoint("TOPLEFT", anchorThreatColor.threatColorAlwaysOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatCombatOnly, "Combat only", "Only apply coloring when nameplate unit is in combat")

    anchorThreatColor.enemyColorThreatCombatOnlyPlayer = CreateCheckbox("enemyColorThreatCombatOnlyPlayer", "Player Combat only", contentFrame)
    anchorThreatColor.enemyColorThreatCombatOnlyPlayer:SetPoint("TOPLEFT", anchorThreatColor.enemyColorThreatCombatOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatCombatOnlyPlayer, "Player Combat Only", "Only apply coloring when I am in combat")

    anchorThreatColor.enemyColorThreatHideSolo = CreateCheckbox("enemyColorThreatHideSolo", "Turn off while Solo", contentFrame)
    anchorThreatColor.enemyColorThreatHideSolo:SetPoint("TOPLEFT", anchorThreatColor.enemyColorThreatCombatOnlyPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorThreatColor.enemyColorThreatHideSolo, "Turn off while Solo", "Don't show threat colors when I am not in a group.")


    ----

    BetterBlizzPlatesSubPanel.reloadButton = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
    BetterBlizzPlatesSubPanel.reloadButton:SetText("Reload UI")
    BetterBlizzPlatesSubPanel.reloadButton:SetWidth(85)
    BetterBlizzPlatesSubPanel.reloadButton:SetPoint("TOP", BetterBlizzPlatesSubPanel, "BOTTOMRIGHT", -140, -9)
    BetterBlizzPlatesSubPanel.reloadButton:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    BetterBlizzPlatesSubPanel.resetBBPButton = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
    BetterBlizzPlatesSubPanel.resetBBPButton:SetText("Reset BetterBlizzPlates")
    BetterBlizzPlatesSubPanel.resetBBPButton:SetWidth(165)
    BetterBlizzPlatesSubPanel.resetBBPButton:SetPoint("RIGHT", BetterBlizzPlatesSubPanel.reloadButton, "LEFT", -528, 0)
    BetterBlizzPlatesSubPanel.resetBBPButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    end)
    CreateTooltipTwo(BetterBlizzPlatesSubPanel.resetBBPButton, "Reset", "Reset ALL BetterBlizzPlates settings.")

    BetterBlizzPlatesSubPanel.rightClickTip = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    BetterBlizzPlatesSubPanel.rightClickTip:SetPoint("RIGHT", BetterBlizzPlatesSubPanel.reloadButton, "LEFT", -80, -2)
    BetterBlizzPlatesSubPanel.rightClickTip:SetText("|A:smallquestbang:20:20|aTip:  Right-click sliders to enter a specific value")
end

local function guiCastbar()
    --------------------------------
    -- Castbar Customization
    --------------------------------
    local guiCastbar = CreateFrame("Frame")
    guiCastbar.name = "Castbar"
    guiCastbar.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiCastbar)
    local guiCastbarCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiCastbar, guiCastbar.name, guiCastbar.name)
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
    castEmphasisText:SetText("Cast Emphasis List")

    local onMeOnlyTexture = listFrame:CreateTexture(nil, "OVERLAY")
    onMeOnlyTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    onMeOnlyTexture:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", -99, -1)
    onMeOnlyTexture:SetSize(18,20)
    CreateTooltipTwo(onMeOnlyTexture, "Only On Me Checkboxes", "Check to only emphasis casts if theyre on me.", "This is only for NPCs, due to API limitations.")

    local how2usecastemphasis = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usecastemphasis:SetPoint("TOP", guiCastbar, "BOTTOMLEFT", 180, 165)
    how2usecastemphasis:SetText("Add name or spell ID. Case-insensitive.\nType a name or spell ID already in list to delete it")

    local castbarSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -280, -5)
    castbarSettingsText:SetText("Castbar settings")
    local castbarSettingsIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsIcon:SetSize(24, 24)
    castbarSettingsIcon:SetPoint("RIGHT", castbarSettingsText, "LEFT", -3, 0)

    local nameplateCastbarTestMode = CreateCheckbox("nameplateCastbarTestMode", "Test Castbars", guiCastbar)
    nameplateCastbarTestMode:SetPoint("LEFT", castbarSettingsText, "RIGHT", 0, 0)
    nameplateCastbarTestMode:SetScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.nameplateCastBarTestMode()
        else
            BBP.cancelTimers()
        end
    end)
    CreateTooltipTwo(nameplateCastbarTestMode, "Test Nameplate Castbars", "NOTE: This is a simple test mode meant to give you a rough idea.\nIt only works for the basic settings. It does not work for interrupt color, emphasis etc. It may not be 100% accurate so please double check with a real castbar.")

    local enableCastbarCustomization = CreateCheckbox("enableCastbarCustomization", "Enable castbar customization", guiCastbar, nil, BBP.ToggleSpellCastEventRegistration)
    enableCastbarCustomization:SetPoint("TOPLEFT", castbarSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)

    local castbarAlwaysOnTop = CreateCheckbox("castbarAlwaysOnTop", "Always on Top", enableCastbarCustomization)
    castbarAlwaysOnTop:SetPoint("LEFT", enableCastbarCustomization.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castbarAlwaysOnTop, "Always on Top", "Ensures castbar will always be displayed on top of other elements and not covered behind other nameplates.\n\n(This setting may see tweaks)")

    local castbarQuickHide = CreateCheckbox("castbarQuickHide", "Castbar Quick Hide", enableCastbarCustomization)
    castbarQuickHide:SetPoint("TOPLEFT", enableCastbarCustomization, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castbarQuickHide, "Hide the castbar instantly when a cast is finished/interrupted\n\nIf \"Show who interrupted\" is turned on the castbar will\nnot be immediately hidden under those circumstances.")

    local hideCastbarBorderShield = CreateCheckbox("hideCastbarBorderShield", "Hide Shield", enableCastbarCustomization)
    hideCastbarBorderShield:SetPoint("LEFT", castbarQuickHide.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideCastbarBorderShield, "Hide Castbar Shield", "Hide the castbar shield on uninterruptible casts")

    local hideCastbarIcon = CreateCheckbox("hideCastbarIcon", "Hide Icon", enableCastbarCustomization)
    hideCastbarIcon:SetPoint("LEFT", hideCastbarBorderShield.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideCastbarIcon, "Hide Castbar Icon", "Hide the castbar spell Icon")

    local showCastBarIconWhenNoninterruptible = CreateCheckbox("showCastBarIconWhenNoninterruptible", "Show Cast Icon on Non-Interruptable", enableCastbarCustomization)
    showCastBarIconWhenNoninterruptible:SetPoint("TOPLEFT", castbarQuickHide, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCastBarIconWhenNoninterruptible, "Show the cast icon on non-interruptable casts (on top of shield),\njust like every other castbar in the game.\n\nBest used together with Dragonflight Shield setting on.")

    local hideNameDuringCast = CreateCheckbox("hideNameDuringCast", "Hide Name", enableCastbarCustomization)
    hideNameDuringCast:SetPoint("LEFT", showCastBarIconWhenNoninterruptible.text, "RIGHT", -1, 0)
    CreateTooltipTwo(hideNameDuringCast, "Hide Unit Name", "Hide the name of the unit casting during a cast.")

    local castBarDragonflightShield = CreateCheckbox("castBarDragonflightShield", "New Shield on Non-Interruptable", enableCastbarCustomization)
    castBarDragonflightShield:SetPoint("TOPLEFT", showCastBarIconWhenNoninterruptible, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarDragonflightShield, "Replace the old pixelated non-interruptible\ncastbar shield with the new Dragonflight one")

    local castBarFullTextWidth = CreateCheckbox("castBarFullTextWidth", "Full Text Width", enableCastbarCustomization)
    castBarFullTextWidth:SetPoint("LEFT", castBarDragonflightShield.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarFullTextWidth, "Full Text Width", "Never shorten spell cast text.")

    local castBarIconScale = CreateSlider(enableCastbarCustomization, "Castbar Icon Size", 0.1, 2.5, 0.01, "castBarIconScale")
    castBarIconScale:SetPoint("TOPLEFT", castBarDragonflightShield, "BOTTOMLEFT", 12, -10)

    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconXPos", "X", 100)
    castBarIconXPos:SetPoint("LEFT", castBarIconScale, "RIGHT", 12, 0)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y", 100)
    castBarIconYPos:SetPoint("TOP", castBarIconXPos, "BOTTOM", 0, -15)

--[=[
    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconXPos", "X")
    castBarIconXPos:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y")
    castBarIconYPos:SetPoint("TOPLEFT", castBarIconXPos, "BOTTOMLEFT", 0, -15)

]=]

    local castBarTextScale = CreateSlider(enableCastbarCustomization, "Castbar text size", 0.5, 2.5, 0.01, "castBarTextScale")
    castBarTextScale:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarHeight = CreateSlider(enableCastbarCustomization, "Castbar height", 4, 36, 0.1, "castBarHeight", "Height")
    castBarHeight:SetPoint("TOPLEFT", castBarTextScale, "BOTTOMLEFT", 0, -15)

    local castbarHeightResetButton = CreateFrame("Button", nil, enableCastbarCustomization, "UIPanelButtonTemplate")
    castbarHeightResetButton:SetText("Default")
    castbarHeightResetButton:SetWidth(60)
    castbarHeightResetButton:SetPoint("LEFT", castBarHeight, "RIGHT", 10, 0)
    castbarHeightResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight(castBarHeight)
    end)

    local castBarRecolor = CreateCheckbox("castBarRecolor", "Re-color castbar", enableCastbarCustomization)
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
    castBarCastColor:SetText("Cast")
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
    castBarChanneledColor:SetText("Channel")
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
    castBarNoninterruptibleColor:SetText("Non-Int")
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
    CreateTooltip(castBarNoninterruptibleColor, "Color for non-interruptible casts")

    local useCustomCastbarTexture = CreateCheckbox("useCustomCastbarTexture", "Re-texture Castbar", enableCastbarCustomization, nil, BBP.ToggleSpellCastEventRegistration)
    useCustomCastbarTexture:SetPoint("TOPLEFT", castBarRecolor, "BOTTOMLEFT", 0, -16)

    local castBarPixelBorder = CreateCheckbox("castBarPixelBorder", "Pixel Border", enableCastbarCustomization)
    castBarPixelBorder:SetPoint("LEFT", useCustomCastbarTexture.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarPixelBorder, "Castbar Pixel Border", "Put a pixel border on castbars.")

    local castBarIconPixelBorder = CreateCheckbox("castBarIconPixelBorder", "Icon Pixel", enableCastbarCustomization)
    castBarIconPixelBorder:SetPoint("LEFT", castBarPixelBorder.text, "RIGHT", -1, 0)
    CreateTooltipTwo(castBarIconPixelBorder, "Icon Pixel Border", "Put a pixel border on cast icon.")

    local customCastbarTextureDropdown = CreateTextureDropdown(
        "customCastbarTextureDropdown",
        useCustomCastbarTexture,
        "Select Texture",
        "customCastbarTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomCastbarTexture, x = -8, y = -23, label = "CustomCastbar" }
    )
    CreateTooltip(customCastbarTextureDropdown, "Castbar Texture")

    local interruptibleLabel = useCustomCastbarTexture:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    interruptibleLabel:SetPoint("LEFT", customCastbarTextureDropdown, "RIGHT", 6, 0)
    interruptibleLabel:SetText("<- Interruptible")

    local customCastbarNonInterruptibleTextureDropdown = CreateTextureDropdown(
        "customCastbarNonInterruptibleTextureDropdown",
        useCustomCastbarTexture,
        "Select Texture",
        "customCastbarNonInterruptibleTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomCastbarTexture, x = -8, y = -54, label = "CustomBGCastbar" }
    )
    CreateTooltip(customCastbarNonInterruptibleTextureDropdown, "Non-Interruptible Texture")

    local nonInterruptibleLabel = useCustomCastbarTexture:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nonInterruptibleLabel:SetPoint("LEFT", customCastbarNonInterruptibleTextureDropdown, "RIGHT", 6, 0)
    nonInterruptibleLabel:SetText("<- Non-Interruptible")

    local customCastbarBGTextureDropdown = CreateTextureDropdown(
        "customCastbarBGTextureDropdown",
        useCustomCastbarTexture,
        "Select Texture",
        "customCastbarBGTexture",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomCastbarTexture, x = -8, y = -85, label = "CustomBGCastbar" }
    )
    CreateTooltip(customCastbarBGTextureDropdown, "Background Texture")

    if not useCustomCastbarTexture:GetChecked() then
        LibDD:UIDropDownMenu_DisableDropDown(customCastbarTextureDropdown)
        LibDD:UIDropDownMenu_DisableDropDown(customCastbarNonInterruptibleTextureDropdown)
        LibDD:UIDropDownMenu_DisableDropDown(customCastbarBGTextureDropdown)
    end

    local useCustomCastbarBGTexture = CreateCheckbox("useCustomCastbarBGTexture", "BG", useCustomCastbarTexture)
    useCustomCastbarBGTexture:SetPoint("LEFT", customCastbarBGTextureDropdown, "RIGHT", 2, -2)
    CreateTooltipTwo(useCustomCastbarBGTexture, "Change Background Texture")
    useCustomCastbarBGTexture:SetFrameStrata("HIGH")

    local castBarBackgroundColor = CreateFrame("Button", nil, useCustomCastbarBGTexture, "UIPanelButtonTemplate")
    castBarBackgroundColor:SetText("Color")
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
    CreateTooltipTwo(castBarBackgroundColor, "Castbar Background Color", "Change the castbar background color.")
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
            LibDD:UIDropDownMenu_EnableDropDown(customCastbarTextureDropdown)
            LibDD:UIDropDownMenu_EnableDropDown(customCastbarNonInterruptibleTextureDropdown)
            useCustomCastbarBGTexture:Enable()
            useCustomCastbarBGTexture:SetAlpha(1)
            if BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                castBarBackgroundColor:Enable()
                castBarBackgroundColor:SetAlpha(1)
                castBarBackgroundColorIcon:SetAlpha(1)
                LibDD:UIDropDownMenu_EnableDropDown(customCastbarBGTextureDropdown)
            end
        else
            LibDD:UIDropDownMenu_DisableDropDown(customCastbarTextureDropdown)
            LibDD:UIDropDownMenu_DisableDropDown(customCastbarNonInterruptibleTextureDropdown)
            LibDD:UIDropDownMenu_DisableDropDown(customCastbarBGTextureDropdown)
            useCustomCastbarBGTexture:Disable()
            useCustomCastbarBGTexture:SetAlpha(0.5)
            if not BetterBlizzPlatesDB.useCustomCastbarBGTexture then
                castBarBackgroundColor:Disable()
                castBarBackgroundColor:SetAlpha(0)
                castBarBackgroundColorIcon:SetAlpha(0)
            end
        end
    end)

    local interruptedByIndicator = CreateCheckbox("interruptedByIndicator", "Show who interrupted", enableCastbarCustomization, nil, BBP.ToggleSpellCastEventRegistration)
    interruptedByIndicator:SetPoint("TOPLEFT", useCustomCastbarTexture, "BOTTOMLEFT", 0, -84)
    CreateTooltip(interruptedByIndicator, "Show the name of who interrupted the cast\ninstead of just the standard \"Interrupted\" text.")

    local normalCastbarForEmpoweredCasts = CreateCheckbox("normalCastbarForEmpoweredCasts", "Normal empowered cast", enableCastbarCustomization)
    normalCastbarForEmpoweredCasts:SetPoint("LEFT", interruptedByIndicator.text, "RIGHT", -1, 0)
    CreateTooltip(normalCastbarForEmpoweredCasts, "Instead of the jank tiered castbar that always kinda looks uninterruptible,\nchange the empowered castbars to just look like normal ones.", "ANCHOR_LEFT")
    normalCastbarForEmpoweredCasts:HookScript("OnClick", function(self)
        if BetterBlizzFramesDB then
            if self:GetChecked() then
                BetterBlizzFramesDB.normalCastbarForEmpoweredCasts = true
            else
                BetterBlizzFramesDB.normalCastbarForEmpoweredCasts = false
            end
        end
    end)

    local hideCastbarText = CreateCheckbox("hideCastbarText", "Hide Castbar Text", enableCastbarCustomization)
    hideCastbarText:SetPoint("TOPLEFT", normalCastbarForEmpoweredCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarText, "Hide Castbar Text", "Hides castbar text except for the \"Interrupted\" text\nor if \"Show who interrupted\" is on.", nil, "ANCHOR_LEFT")
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

    local castBarRecolorInterrupt = CreateCheckbox("castBarRecolorInterrupt", "Interrupt CD color", enableCastbarCustomization)
    castBarRecolorInterrupt:SetPoint("TOPLEFT", interruptedByIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarRecolorInterrupt, "Checks if you have interrupt ready\nand color castbar thereafter.")

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText("Kick on cd")
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", -15, 3)
    castBarNoInterruptColor:SetSize(95, 20)
    CreateTooltip(castBarNoInterruptColor, "Castbar color when interrupt is on CD")
    local castBarNoInterruptColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarNoInterruptColorIcon:SetAtlas("CircleMaskScalable")
    castBarNoInterruptColorIcon:SetSize(18, 17)
    castBarNoInterruptColorIcon:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarNoInterruptColorIcon, unpack(BetterBlizzPlatesDB["castBarNoInterruptColor"] or {1, 1, 1}))
    castBarNoInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarNoInterruptColor", castBarNoInterruptColorIcon)
    end)

    local castBarDelayedInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarDelayedInterruptColor:SetText("Kick soon")
    castBarDelayedInterruptColor:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 30, 0)
    castBarDelayedInterruptColor:SetSize(95, 20)
    CreateTooltip(castBarDelayedInterruptColor, "Castbar color when interrupt is on CD but\nwill be ready before the cast ends")
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
    castbarEmphasisSettingsText:SetText("Castbar emphasis settings")
    local castbarSettingsEmphasisIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsEmphasisIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsEmphasisIcon:SetSize(36, 36)
    castbarSettingsEmphasisIcon:SetVertexColor(1,0,0)
    castbarSettingsEmphasisIcon:SetPoint("RIGHT", castbarEmphasisSettingsText, "LEFT", 5, 0)

    local enableCastbarEmphasis = CreateCheckbox("enableCastbarEmphasis", "Cast Emphasis", enableCastbarCustomization)
    enableCastbarEmphasis:SetPoint("TOPLEFT", castbarEmphasisSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)
    enableCastbarEmphasis:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarEmphasis)
        if self:GetChecked() then
            listFrame:SetAlpha(1)
        else
            listFrame:SetAlpha(0.5)
        end
    end)
    CreateTooltipTwo(enableCastbarEmphasis, "Castbar Emphasis", "Enable to adjust how the castbar looks for specific spells from the list. Will also ensure the castbar is not being covered by other nameplates during cast.")

    local castBarEmphasisOnlyInterruptable = CreateCheckbox("castBarEmphasisOnlyInterruptable", "Interruptable cast only", enableCastbarEmphasis)
    castBarEmphasisOnlyInterruptable:SetPoint("LEFT", enableCastbarEmphasis.text, "RIGHT", 0, 0)
    CreateTooltip(castBarEmphasisOnlyInterruptable, "Only apply emphasis settings if the cast is interruptable")

    local castBarEmphasisHealthbarColor = CreateCheckbox("castBarEmphasisHealthbarColor", "Color healthbar", enableCastbarEmphasis)
    castBarEmphasisHealthbarColor:SetPoint("TOPLEFT", enableCastbarEmphasis, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(castBarEmphasisHealthbarColor, "Color the healthbar the color you've set\nin the list if that spell is being cast.")

    local castBarEmphasisColor = CreateCheckbox("castBarEmphasisColor", "Color castbar", enableCastbarEmphasis)
    castBarEmphasisColor:SetPoint("LEFT", castBarEmphasisHealthbarColor.text, "RIGHT", 0, 0)
    CreateTooltip(castBarEmphasisColor, "Color the castbar the color you've set\nin the list if that spell is being cast.")

    local castBarEmphasisSelfColor = CreateCheckbox("castBarEmphasisSelfColor", "Self Color", enableCastbarEmphasis)
    castBarEmphasisSelfColor:SetPoint("LEFT", castBarEmphasisColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(castBarEmphasisSelfColor, "Self Color", "Color a specific color if the cast is on me.\n\n|cff32f795Right-click to change Self Color.|r", "This is only for NPCs, due to API limitations.")
    castBarEmphasisSelfColor:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.castBarEmphasisSelfColorRGB, BBP.RefreshAllNameplates)
        end
    end)

    local castBarEmphasisHeight = CreateCheckbox("castBarEmphasisHeight", "Height", enableCastbarEmphasis)
    castBarEmphasisHeight:SetPoint("TOPLEFT", castBarEmphasisHealthbarColor, "BOTTOMLEFT", 0, -2)

    local castBarEmphasisIcon = CreateCheckbox("castBarEmphasisIcon", "Icon size", enableCastbarEmphasis)
    castBarEmphasisIcon:SetPoint("TOPLEFT", castBarEmphasisHeight, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)

    local castBarEmphasisText = CreateCheckbox("castBarEmphasisText", "Text size", enableCastbarEmphasis)
    castBarEmphasisText:SetPoint("TOPLEFT", castBarEmphasisIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)

    local castBarEmphasisSpark = CreateCheckbox("castBarEmphasisSpark", "Spark", enableCastbarEmphasis)
    castBarEmphasisSpark:SetPoint("TOPLEFT", castBarEmphasisText, "BOTTOMLEFT", 0, pixelsBetweenBoxedWSlider)
    CreateTooltip(castBarEmphasisSpark, "Spark is the little texture at the end of the current cast progress")

    local castBarEmphasisHeightValue = CreateSlider(enableCastbarEmphasis, "Emphasis height", 4, 40, 0.1, "castBarEmphasisHeightValue", "Height")
    castBarEmphasisHeightValue:SetPoint("LEFT", castBarEmphasisHeight, "RIGHT", 50, -1)

    local castBarEmphasisIconScale = CreateSlider(enableCastbarEmphasis, "Emphasis Icon Size", 1, 3, 0.1, "castBarEmphasisIconScale")
    castBarEmphasisIconScale:SetPoint("LEFT", castBarEmphasisIcon, "RIGHT", 50, -1)

    local castBarEmphasisTextScale = CreateSlider(enableCastbarEmphasis, "Emphasis text size", 0.5, 2.5, 0.1, "castBarEmphasisTextScale")
    castBarEmphasisTextScale:SetPoint("LEFT", castBarEmphasisText, "RIGHT", 50, -1)

    local castBarEmphasisSparkHeight = CreateSlider(enableCastbarEmphasis, "Emphasis Spark Size", 25, 60, 1, "castBarEmphasisSparkHeight", "Height")
    castBarEmphasisSparkHeight:SetPoint("LEFT", castBarEmphasisSpark, "RIGHT", 50, -1)

    local castBarInterruptHighlighterText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castBarInterruptHighlighterText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -610, -485)
    castBarInterruptHighlighterText:SetText("Castbar Edge Highlight settings")

    local castBarInterruptHighlighter = CreateCheckbox("castBarInterruptHighlighter", "Castbar Edge Highlight", enableCastbarCustomization)
    castBarInterruptHighlighter:SetPoint("TOPLEFT", castBarInterruptHighlighterText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(castBarInterruptHighlighter, "Castbar Highlight", "Color the start and end of the castbar differently.\nSet the time in seconds when to color the castbar below.")
    castBarInterruptHighlighter:HookScript("OnClick", function(self)
        BBP.ToggleSpellCastEventRegistration()
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local castBarInterruptHighlighterColorDontInterrupt = CreateCheckbox("castBarInterruptHighlighterColorDontInterrupt", "Re-color between portion", castBarInterruptHighlighter)
    castBarInterruptHighlighterColorDontInterrupt:SetPoint("TOPLEFT", castBarInterruptHighlighter, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptHighlighterColorDontInterrupt, "Color Inbetween", "Color the middle section between start and finish as well. Pick a color.")

    local castBarInterruptHighlighterDontInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighterColorDontInterrupt, "UIPanelButtonTemplate")
    castBarInterruptHighlighterDontInterruptRGB:SetText("Color")
    castBarInterruptHighlighterDontInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterColorDontInterrupt.text, "RIGHT", 0, 0)
    castBarInterruptHighlighterDontInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterDontInterruptRGB, "Castbar color inbetween the start and finish")
    local castBarInterruptHighlighterDontInterruptRGBIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetAtlas("CircleMaskScalable")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterDontInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterDontInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterDontInterruptRGBIcon, unpack(BetterBlizzPlatesDB["castBarInterruptHighlighterDontInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterDontInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterDontInterruptRGB", castBarInterruptHighlighterDontInterruptRGBIcon)
    end)

    local castBarInterruptHighlighterStartTime = CreateSlider(castBarInterruptHighlighter, "Start Seconds", 0, 2, 0.01, "castBarInterruptHighlighterStartTime", "Height")
    castBarInterruptHighlighterStartTime:SetPoint("TOPLEFT", castBarInterruptHighlighterColorDontInterrupt, "BOTTOMLEFT", 10, -6)
    CreateTooltip(castBarInterruptHighlighterStartTime, "How many seconds of the start of the cast you want to color the castbar.")

    local castBarInterruptHighlighterEndTime = CreateSlider(castBarInterruptHighlighter, "End Seconds", 0, 2, 0.01, "castBarInterruptHighlighterEndTime", "Height")
    castBarInterruptHighlighterEndTime:SetPoint("TOPLEFT", castBarInterruptHighlighterStartTime, "BOTTOMLEFT", 0, -10)
    CreateTooltip(castBarInterruptHighlighterEndTime, "How many seconds of the end of the cast you want to color the castbar.")

    local castBarInterruptHighlighterInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighter, "UIPanelButtonTemplate")
    castBarInterruptHighlighterInterruptRGB:SetText("Color")
    castBarInterruptHighlighterInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterEndTime, "RIGHT", 0, 15)
    castBarInterruptHighlighterInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterInterruptRGB, "Castbar edge color")
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
            LibDD:UIDropDownMenu_EnableDropDown(customCastbarBGTextureDropdown)
            castBarBackgroundColor:Enable()
            castBarBackgroundColor:SetAlpha(1)
            castBarBackgroundColorIcon:SetAlpha(1)
        else
            LibDD:UIDropDownMenu_DisableDropDown(customCastbarBGTextureDropdown)
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
                    LibDD:UIDropDownMenu_EnableDropDown(customCastbarBGTextureDropdown)
                    castBarBackgroundColor:Enable()
                    castBarBackgroundColor:SetAlpha(1)
                    castBarBackgroundColorIcon:SetAlpha(1)
                else
                    LibDD:UIDropDownMenu_DisableDropDown(customCastbarBGTextureDropdown)
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
    guiHideCastbar.name = "Hide Castbar"
    guiHideCastbar.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiHideCastbar)
    local guiHideCastbarCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiHideCastbar, guiHideCastbar.name, guiHideCastbar.name)
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
    hideCastbarListExplanationText:SetText("Add spell name, spell ID, npc name or npc ID\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or spell ID already in list to delete it")

    local hideCastbarExplanationText = guiHideCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideCastbarExplanationText:SetPoint("TOP", guiHideCastbar, "TOP", 172, -127)
    hideCastbarExplanationText:SetText("Hide the castbar for chosen spells,\nor only show whitelisted ones.\n \nYou will still be able to click them\neven though you can't see them")

    local hideCastbar = CreateCheckbox("hideCastbar", "Enable Hide Castbar", guiHideCastbar)
    hideCastbar:SetPoint("TOPLEFT", hideCastbarExplanationText, "BOTTOMLEFT", 25, -15)
    hideCastbar:HookScript("OnClick", function(_, btn, down)
        BBP.ToggleSpellCastEventRegistration()
    end)
    CreateTooltip(hideCastbar, "Hide the castbar for chosen spells,\nor only show whitelisted ones.")

    local hideCastbarFrame = CreateFrame("Frame", nil, listFrame)
    hideCastbarFrame:SetSize(322, 390)
    hideCastbarFrame:SetPoint("TOPLEFT", 0, 0)

    local hideCastbarWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    hideCastbarWhitelistFrame:SetSize(322, 390)
    hideCastbarWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = hideCastbarWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", hideCastbarWhitelistFrame, "TOP", 0, -5)
    whitelistOnText:SetText("Whitelist ON")

    CreateList(hideCastbarFrame, "hideCastbarList", BetterBlizzPlatesDB.hideCastbarList, BBP.RefreshAllNameplates, false)
    CreateList(hideCastbarWhitelistFrame, "hideCastbarWhitelist", BetterBlizzPlatesDB.hideCastbarWhitelist, BBP.RefreshAllNameplates, false)

    local hideCastbarWhitelist = CreateCheckbox("hideCastbarWhitelistOn", "Whitelist mode", hideCastbar)
    hideCastbarWhitelist:SetPoint("TOPLEFT", hideCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCastbarWhitelist, "Hide castbar for ALL spells except the ones in the whitelist")

    local showCastbarIfTarget = CreateCheckbox("showCastbarIfTarget", "Always show castbar on target", hideCastbar)
    showCastbarIfTarget:SetPoint("TOPLEFT", hideCastbarWhitelist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local onlyShowInterruptableCasts = CreateCheckbox("onlyShowInterruptableCasts", "Only show interruptable casts", hideCastbar)
    onlyShowInterruptableCasts:SetPoint("TOPLEFT", showCastbarIfTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideNpcCastbar = CreateCheckbox("hideNpcCastbar", "Hide all NPC castbars", hideCastbar)
    hideNpcCastbar:SetPoint("TOPLEFT", onlyShowInterruptableCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNpcCastbar, "Hide NPC Castbars", "Hide all NPC castbars (except whitelisted ones).")

    local hidePetCastbars = CreateCheckbox("hidePetCastbars", "Hide all Pet castbars", hideCastbar)
    hidePetCastbars:SetPoint("TOPLEFT", hideNpcCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePetCastbars, "Hide Pet Castbars", "Hide all Pet castbars.")

    local hideCastbarFriendly = CreateCheckbox("hideCastbarFriendly", "Hide friendly castbars", hideCastbar)
    hideCastbarFriendly:SetPoint("TOPLEFT", hidePetCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarFriendly, "Hide Friendly Castbars", "Hide all friendly castbars (except whitelisted ones).")

    local hideCastbarEnemy = CreateCheckbox("hideCastbarEnemy", "Hide enemy castbars", hideCastbar)
    hideCastbarEnemy:SetPoint("TOPLEFT", hideCastbarFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarEnemy, "Hide Enemy Castbars", "Hide all enemy castbars (except whitelisted ones).")

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
    guiFadeNpc.name = "Fade NPC"
    guiFadeNpc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiFadeNpc)
    local guiFadeNpcCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiFadeNpc, guiFadeNpc.name, guiFadeNpc.name)
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
    whitelistOnText:SetText("Whitelist ON")

    CreateList(fadeOutNPCListFrame, "fadeOutNPCsList", BetterBlizzPlatesDB.fadeOutNPCsList, BBP.RefreshAllNameplates, false)
    CreateList(fadeOutNPCWhitelistFrame, "fadeOutNPCsWhitelist", BetterBlizzPlatesDB.fadeOutNPCsWhitelist, BBP.RefreshAllNameplates, false)

    local how2usefade = guiFadeNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usefade:SetPoint("TOP", guiFadeNpc, "BOTTOMLEFT", 180, 155)
    how2usefade:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    local fadeOutNPCsAlpha = CreateSlider(guiFadeNpc, "Alpha value", 0, 1, 0.01, "fadeOutNPCsAlpha", "Alpha")
    fadeOutNPCsAlpha:SetPoint("TOPRIGHT", guiFadeNpc, "TOPRIGHT", -90, -90)

    local noteFade = guiFadeNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteFade:SetPoint("TOP", fadeOutNPCsAlpha, "BOTTOM", 0, -20)
    noteFade:SetText("This makes nameplates transparent.\n \nYou will still be able to click them\neven though you can't see them.")

    local fadeOutNPC = CreateCheckbox("fadeOutNPC", "Enable Fade NPC", guiFadeNpc)
    fadeOutNPC:SetPoint("TOPLEFT", noteFade, "BOTTOMLEFT", 20, -15)

    local fadeAllButTarget = CreateCheckbox("fadeAllButTarget", "Fade All Except Target", fadeOutNPC)
    fadeAllButTarget:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(fadeAllButTarget, "Fade out all other nameplates when you have a target.\nDisregards the fade list")

    local fadeNPCPvPOnly = CreateCheckbox("fadeNPCPvPOnly", "Only fade NPCs in PvP", fadeOutNPC)
    fadeNPCPvPOnly:SetPoint("TOPLEFT", fadeAllButTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fadeNPCPvPOnly, "Only fade nameplates in Arena and BGs")

    local fadeOutNPCWhitelistOn = CreateCheckbox("fadeOutNPCWhitelistOn", "Whitelist Mode", fadeOutNPC)
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
    CreateTooltipTwo(fadeOutNPCWhitelistOn, "Whitelist Mode", "Swaps out the blacklist with a whitelist and fades out ALL nameplates except the ones in the whitelist.")

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
    guiHideNpc.name = "Hide NPC"
    guiHideNpc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiHideNpc)
    local guiHideNpcCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiHideNpc, guiHideNpc.name, guiHideNpc.name)
    CreateTitle(guiHideNpc)

    local bgImg = guiHideNpc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiHideNpc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local hideNpcListExplanationText = guiHideNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideNpcListExplanationText:SetPoint("TOP", guiHideNpc, "BOTTOMLEFT", 180, 155)
    hideNpcListExplanationText:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    local hideNpcExplanationText = guiHideNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideNpcExplanationText:SetPoint("TOP", guiHideNpc, "TOP", 172, -127)
    hideNpcExplanationText:SetText("This hides nameplates.\n \nThe nameplates also become\nunclickable.")

    local hideNPC = CreateCheckbox("hideNPC", "Enable Hide NPC", guiHideNpc, nil, BBP.hideNPC)
    hideNPC:SetPoint("TOPLEFT", hideNpcExplanationText, "BOTTOMLEFT", 25, -15)
    CreateTooltip(hideNPC, "Hide NPC's from the blacklist\nOr only show the ones in whitelist with whitelist mode.")
    hideNPC:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
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
    whitelistOnText:SetText("Whitelist ON")

    CreateList(hideNPCListFrame, "hideNPCsList", BetterBlizzPlatesDB.hideNPCsList, BBP.RefreshAllNameplates, false)
    CreateList(hideNPCWhitelistFrame, "hideNPCsWhitelist", BetterBlizzPlatesDB.hideNPCsWhitelist, BBP.RefreshAllNameplates, false)

    local murlocTexture = guiHideNpc:CreateTexture(nil, "OVERLAY")
    murlocTexture:SetAtlas("newplayerchat-chaticon-newcomer")
    murlocTexture:SetPoint("BOTTOM", hideNPCListFrame, "TOPRIGHT", -30, -9)
    murlocTexture:SetSize(17,17)
    CreateTooltip(murlocTexture, "Murloc Icon Checkboxes")

    local hideNpcMurlocScale = CreateSlider(hideNPC, "Murloc Size", 0.7, 2.2, 0.01, "hideNpcMurlocScale")
    hideNpcMurlocScale:SetPoint("TOPRIGHT", guiHideNpc, "TOPRIGHT", -90, -365)

    local hideNpcMurlocYPos = CreateSlider(hideNPC, "Murloc Y Position", -50, 50, 1, "hideNpcMurlocYPos", "Y")
    hideNpcMurlocYPos:SetPoint("TOPRIGHT", guiHideNpc, "TOPRIGHT", -90, -410)

    local hideNPCWhitelistOn = CreateCheckbox("hideNPCWhitelistOn", "Whitelist mode", hideNPC)
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
    CreateTooltip(hideNPCWhitelistOn, "Hides ALL NPC's except the ones in the whitelist")

    local hideNPCArenaOnly = CreateCheckbox("hideNPCArenaOnly", "Only hide NPCs in PvP", hideNPC)
    hideNPCArenaOnly:SetPoint("TOPLEFT", hideNPCWhitelistOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- local hideNPCPetsOnly = CreateCheckbox("hideNPCPetsOnly", "Hide Player Pets", hideNPC)
    -- hideNPCPetsOnly:SetPoint("TOPLEFT", hideNPCArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(hideNPCPetsOnly, "Hide all player pets.")

    local hideNPCAllNeutral = CreateCheckbox("hideNPCAllNeutral", "Hide Neutral NPCs", hideNPC)
    hideNPCAllNeutral:SetPoint("TOPLEFT", hideNPCArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCAllNeutral, "Hide Neutral NPCs", "Hide all neutral NPCs, except current target, that are not in combat.")

    local hideNPCHideOthersPets = CreateCheckbox("hideNPCHideOthersPets", "Hide Others Pets", hideNPC)
    hideNPCHideOthersPets:SetPoint("TOPLEFT", hideNPCAllNeutral, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCHideOthersPets, "Hide Others Pets", "Hide other friendly pets that are not yours.\n\nPerfect in combination with Class Indicator's Pet setting to keep track of your own Pet.", "Reminder: To see Friendly Pet Nameplates at all requires \"Show Friendly Pets\" CVar enabled in CVar Control section.")

    local hideNPCHideSecondaryPets = CreateCheckbox("hideNPCHideSecondaryPets", "Hide Secondary Pets", hideNPC)
    hideNPCHideSecondaryPets:SetPoint("TOPLEFT", hideNPCHideOthersPets, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCHideSecondaryPets, "Hide Secondary Pets", "Hide all secondary pets like hunters zoo etc. Will not hide important things.", "For some hunter pets and lock pets this will only work in Arena.")

    local hideNPCSecondaryShowMurloc = CreateCheckbox("hideNPCSecondaryShowMurloc", "Murloc Secondary Pets", hideNPCHideSecondaryPets)
    hideNPCSecondaryShowMurloc:SetPoint("TOPLEFT", hideNPCHideSecondaryPets, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNPCSecondaryShowMurloc, "Murloc Secondary Pets", "Instead of completely hiding the nameplate show a little Murloc icon while hiding the rest of the nameplate. This helps with awareness but nameplates will still be clickable.")
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
    guiColorNpc.name = "Color NPC"
    guiColorNpc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiColorNpc)
    local guiColorNpcCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiColorNpc, guiColorNpc.name, guiColorNpc.name)
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
    listExplanationText:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    local colorNpcExplanationText = guiColorNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorNpcExplanationText:SetPoint("TOP", guiColorNpc, "TOP", 172, -127)
    colorNpcExplanationText:SetText("This colors specific nameplates.\n \nAdd a name/npc ID and select a color")

    local colorNPC = CreateCheckbox("colorNPC", "Enable NPC Color", guiColorNpc, nil, BBP.colorNPC)
    colorNPC:SetPoint("TOPLEFT", colorNpcExplanationText, "BOTTOMLEFT", 25, -15)
    CreateTooltip(colorNPC, "Color NPC's from the list a color of your choice.\nClick color button after adding the NPC to the list to chose color.")

    local colorNPCName = CreateCheckbox("colorNPCName", "Also color name text", colorNPC, nil, BBP.colorNPC)
    colorNPCName:SetPoint("TOPLEFT", colorNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local reloadUiButton = CreateFrame("Button", nil, guiColorNpc, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
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
    guiAuraColor.name = "Color by Aura"
    guiAuraColor.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiAuraColor)
    local guiAuraColorCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiAuraColor, guiAuraColor.name, guiAuraColor.name)
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
    listExplanationText:SetText("Add name or spell ID. Case-insensitive.\n\nType a name or spell ID already in list to delete it")

    local auraColorExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    auraColorExplanationText:SetPoint("TOP", guiAuraColor, "TOP", 210, -127)
    auraColorExplanationText:SetText("Color nameplates\ndepending on their auras.\n \nAdd a name/spellID\nand select a color")

    local auraColor = CreateCheckbox("auraColor", "Enable Color by Aura", guiAuraColor, nil, BBP.CreateUnitAuraEventFrame)
    auraColor:SetPoint("TOPLEFT", auraColorExplanationText, "BOTTOMLEFT", 30, -15)
    CreateTooltip(auraColor, "Chose nameplate color depending on the aura on them")

    local auraColorPvEOnly = CreateCheckbox("auraColorPvEOnly", "Enable in PvE only", auraColor)
    auraColorPvEOnly:SetPoint("TOPLEFT", auraColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local reloadUiButton = CreateFrame("Button", nil, guiAuraColor, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
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
    guiNameplateAuras.name = "Nameplate Auras"
    guiNameplateAuras.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiNameplateAuras)
    local guiNameplateAurasCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiNameplateAuras, guiNameplateAuras.name, guiNameplateAuras.name)
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
    blacklistText:SetText("Blacklist")

    local whitelist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzPlatesDB.auraWhitelist, BBP.RefreshAllNameplates, nil, true, nil, 379, 270, true, true)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -60, -5)
    whitelistText:SetText("Whitelist")

    local onlyMeTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    onlyMeTexture:SetTexture(BBP.OwnAuraIcon)
    onlyMeTexture:SetPoint("RIGHT", whitelist, "TOPRIGHT", -101, 9)
    onlyMeTexture:SetSize(18,20)
    CreateTooltip(onlyMeTexture, "Only My Aura Checkboxes")

    local enlargeAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    enlargeAuraTexture:SetTexture(BBP.EnlargedIcon)
    enlargeAuraTexture:SetPoint("LEFT", onlyMeTexture, "RIGHT", 4, 0)
    enlargeAuraTexture:SetSize(18,18)
    CreateTooltip(enlargeAuraTexture, "Enlarged Aura Checkboxes")

    local compactAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    compactAuraTexture:SetTexture(BBP.CompactIcon)
    compactAuraTexture:SetPoint("LEFT", enlargeAuraTexture, "RIGHT", 3, 0)
    compactAuraTexture:SetSize(18,18)
    CreateTooltip(compactAuraTexture, "Compact Aura Checkboxes")

    local importantAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    importantAuraTexture:SetTexture(BBP.ImportantIcon)
    importantAuraTexture:SetPoint("LEFT", compactAuraTexture, "RIGHT", 2, 0)
    importantAuraTexture:SetSize(17,16)
    importantAuraTexture:SetDesaturated(true)
    importantAuraTexture:SetVertexColor(0,1,0)
    CreateTooltip(importantAuraTexture, "Important Aura Checkboxes")

    local pandemicAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    pandemicAuraTexture:SetTexture(BBP.PandemicIcon)
    pandemicAuraTexture:SetPoint("LEFT", importantAuraTexture, "RIGHT", 0, 1)
    pandemicAuraTexture:SetSize(26,26)
    pandemicAuraTexture:SetDesaturated(true)
    pandemicAuraTexture:SetVertexColor(1,0,0)
    CreateTooltip(pandemicAuraTexture, "Pandemic Aura Checkboxes")

    local enableNameplateAuraCustomisation = CreateCheckbox("enableNameplateAuraCustomisation", "Enable Aura Settings", contentFrame)
    enableNameplateAuraCustomisation:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 195)
    enableNameplateAuraCustomisation:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.hideNameplateAuras = false
        end
    end)
    CreateTooltip(enableNameplateAuraCustomisation, "Enable all aura settings like filters and customization.")

    --------------------------
    -- Enemy Nameplates
    --------------------------
    -- Enemy Buffs
    local otherNpBuffEnable = CreateCheckbox("otherNpBuffEnable", "Show BUFFS", enableNameplateAuraCustomisation)
    otherNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 145)
    otherNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(otherNpBuffEnable)
    end)
    CreateTooltip(otherNpBuffEnable, "Enable all Buffs. Select filters under.")

    local bigEnemyBorderText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText:SetPoint("LEFT", otherNpBuffEnable, "CENTER", 0, 25)
    bigEnemyBorderText:SetText("Enemy Nameplates")
    local friendlyNameplatesIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    friendlyNameplatesIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplatesIcon:SetSize(28, 28)
    friendlyNameplatesIcon:SetPoint("RIGHT", bigEnemyBorderText, "LEFT", -3, 0)
    friendlyNameplatesIcon:SetDesaturated(1)
    friendlyNameplatesIcon:SetVertexColor(1, 0, 0)

    local otherNpBuffFilterBlacklist = CreateCheckbox("otherNpBuffFilterBlacklist", "Blacklist", otherNpBuffEnable)
    otherNpBuffFilterBlacklist:SetPoint("TOPLEFT", otherNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffFilterBlacklist, "Hide blacklisted buffs.")

    local otherNpBuffFilterWatchList = CreateCheckbox("otherNpBuffFilterWatchList", "Whitelist", otherNpBuffEnable)
    otherNpBuffFilterWatchList:SetPoint("TOPLEFT", otherNpBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(otherNpBuffFilterWatchList, "Whitelist", "Only show whitelisted buffs.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")

    local otherNpBuffFilterImportantBuffs = CreateCheckbox("otherNpBuffFilterImportantBuffs", "PvP Buffs", otherNpBuffEnable)
    otherNpBuffFilterImportantBuffs:SetPoint("LEFT", otherNpBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(otherNpBuffFilterImportantBuffs, "Show Important Buffs", "Only show important PvP Buffs. (Plus other filters)\n\n|cff32f795Right-click for categories.|r\n\nBy default these auras are Enlarged.\nThis can be turned off below in settings on the left side.")
    otherNpBuffFilterImportantBuffs:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local otherNpBuffFilterLessMinite = CreateCheckbox("otherNpBuffFilterLessMinite", "Under one min", otherNpBuffEnable)
    otherNpBuffFilterLessMinite:SetPoint("TOPLEFT", otherNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffFilterLessMinite, "Only show buffs under one minute long. (Plus other filters)")

    local otherNpBuffFilterPurgeable = CreateCheckbox("otherNpBuffFilterPurgeable", "Purgeable", otherNpBuffEnable)
    otherNpBuffFilterPurgeable:SetPoint("TOPLEFT", otherNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(otherNpBuffFilterPurgeable, "Purgeable", "Only show purgeable/stealable buffs. (Plus other filters)")
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

    local otherNpBuffPurgeGlow = CreateCheckbox("otherNpBuffPurgeGlow", "Glow on Purgeable", otherNpBuffEnable)
    otherNpBuffPurgeGlow:SetPoint("TOPLEFT", otherNpBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffPurgeGlow, "Bright blue glow on purgeable/stealable buffs.")

    local alwaysShowPurgeTexture = CreateCheckbox("alwaysShowPurgeTexture", "Always", otherNpBuffPurgeGlow)
    alwaysShowPurgeTexture:SetPoint("LEFT", otherNpBuffPurgeGlow.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(alwaysShowPurgeTexture, "Always Show", "Always show the purge texture regardless if you have a purge ability or not.")

    otherNpBuffPurgeGlow:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    -- local otherNpBuffBlueBorder = CreateCheckbox("otherNpBuffBlueBorder", "Blue border on buffs", otherNpBuffEnable)
    -- otherNpBuffBlueBorder:SetPoint("TOPLEFT", otherNpBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(otherNpBuffBlueBorder, "Replace the black border around buffs with a blue one (for buffs only)")

    -- Enemy Debuffs
    local otherNpdeBuffEnable = CreateCheckbox("otherNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    otherNpdeBuffEnable:SetPoint("TOPLEFT", otherNpBuffPurgeGlow, "BOTTOMLEFT", -15, -2)
    otherNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(otherNpdeBuffEnable)
    end)
    CreateTooltip(otherNpdeBuffEnable, "Enable all Debuffs. Select filters under.")

    local otherNpdeBuffFilterBlacklist = CreateCheckbox("otherNpdeBuffFilterBlacklist", "Blacklist", otherNpdeBuffEnable)
    otherNpdeBuffFilterBlacklist:SetPoint("TOPLEFT", otherNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterBlacklist, "Hide blacklisted debuffs.")

    local otherNpdeBuffFilterWatchList = CreateCheckbox("otherNpdeBuffFilterWatchList", "Whitelist", otherNpdeBuffEnable)
    otherNpdeBuffFilterWatchList:SetPoint("TOPLEFT", otherNpdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(otherNpdeBuffFilterWatchList, "Whitelist", "Only show whitelisted buffs.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")

    local otherNpdeBuffFilterCC = CreateCheckbox("otherNpdeBuffFilterCC", "PvP CC", otherNpdeBuffEnable)
    otherNpdeBuffFilterCC:SetPoint("LEFT", otherNpdeBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(otherNpdeBuffFilterCC, "Show Crowd Control", "Only show crowd control debuffs. (Plus other filters)\n\n|cff32f795Right-click for categories.|r\n\nBy default these auras are Enlarged.\nThis can be turned off below in settings on the left side.")
    otherNpdeBuffFilterCC:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local otherNpdeBuffFilterBlizzard = CreateCheckbox("otherNpdeBuffFilterBlizzard", "Blizzard Default Filter", otherNpdeBuffEnable)
    otherNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", otherNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterBlizzard, "Only show debuffs that are in the Blizzard Default nameplate filter\n(most of own auras + some cc etc) (Plus other filters).")

    local blizzardDefaultFilterOnlyMine = CreateCheckbox("blizzardDefaultFilterOnlyMine", "BDF: Mine", otherNpdeBuffFilterBlizzard)
    blizzardDefaultFilterOnlyMine:SetPoint("LEFT", otherNpdeBuffFilterBlizzard.text, "RIGHT", 0, 0)
    CreateTooltipTwo(blizzardDefaultFilterOnlyMine, "Blizzard Default Filter: Mine only", "Only show auras that are mine from the Blizzard Default Filter.")

    otherNpdeBuffFilterBlizzard:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    local otherNpdeBuffFilterLessMinite = CreateCheckbox("otherNpdeBuffFilterLessMinite", "Under one min", otherNpdeBuffEnable)
    otherNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", otherNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterLessMinite, "Only show debuffs under one minute long.\n\nThis filter gets overriden by \"Only mine\" if both\nconditions are met, otherwise filters are additive.")

    local otherNpdeBuffFilterOnlyMe = CreateCheckbox("otherNpdeBuffFilterOnlyMe", "Only mine", otherNpdeBuffEnable)
    otherNpdeBuffFilterOnlyMe:SetPoint("TOPLEFT", otherNpdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffFilterOnlyMe, "Only show my debuffs. (Can select individual in whitelist too)\n\nThis filter allows auras from the Blizzard Default filter if it is enabled.")

--[=[
    local otherNpdeBuffPandemicGlow = CreateCheckbox("otherNpdeBuffPandemicGlow", "Pandemic Glow", otherNpdeBuffEnable)
    otherNpdeBuffPandemicGlow:SetPoint("TOPLEFT", otherNpdeBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffPandemicGlow, "Red glow on whitelisted debuffs with less than 5 seconds left.")

]=]


    --------------------------
    -- Friendly Nameplates
    --------------------------
    -- Friendly Buffs
    local friendlyNpBuffEnable = CreateCheckbox("friendlyNpBuffEnable", "Show BUFFS", enableNameplateAuraCustomisation)
    friendlyNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 300, 170)
    friendlyNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(friendlyNpBuffEnable)
    end)
    CreateTooltip(friendlyNpBuffEnable, "Enable all Buffs. Select filters under.")

    local friendlyNameplatesText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyNameplatesText:SetPoint("LEFT", friendlyNpBuffEnable, "CENTER", 0, 25)
    friendlyNameplatesText:SetText("Friendly Nameplates")
    local friendlyNameplatesIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    friendlyNameplatesIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplatesIcon:SetSize(28, 28)
    friendlyNameplatesIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNpBuffFilterBlacklist = CreateCheckbox("friendlyNpBuffFilterBlacklist", "Blacklist", friendlyNpBuffEnable)
    friendlyNpBuffFilterBlacklist:SetPoint("TOPLEFT", friendlyNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpBuffFilterBlacklist, "Hide blacklisted buffs.")

    local friendlyNpBuffFilterWatchList = CreateCheckbox("friendlyNpBuffFilterWatchList", "Whitelist", friendlyNpBuffEnable)
    CreateTooltipTwo(friendlyNpBuffFilterWatchList, "Whitelist", "Only show whitelisted buffs.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    friendlyNpBuffFilterWatchList:SetPoint("TOPLEFT", friendlyNpBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyNpBuffFilterImportantBuffs = CreateCheckbox("friendlyNpBuffFilterImportantBuffs", "PvP Buffs", friendlyNpBuffEnable)
    friendlyNpBuffFilterImportantBuffs:SetPoint("LEFT", friendlyNpBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyNpBuffFilterImportantBuffs, "Show Important Buffs", "Only show important PvP Buffs. (Plus other filters)\n\n|cff32f795Right-click for categories.|r\n\nBy default these auras are Enlarged.\nThis can be turned off below in settings on the left side.")
    friendlyNpBuffFilterImportantBuffs:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local friendlyNpBuffFilterLessMinite = CreateCheckbox("friendlyNpBuffFilterLessMinite", "Under one min", friendlyNpBuffEnable)
    friendlyNpBuffFilterLessMinite:SetPoint("TOPLEFT", friendlyNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpBuffFilterLessMinite, "Only show buffs under one minute long. (Plus other filters)")

    local friendlyNpBuffFilterOnlyMe = CreateCheckbox("friendlyNpBuffFilterOnlyMe", "Only mine", friendlyNpBuffEnable)
    friendlyNpBuffFilterOnlyMe:SetPoint("TOPLEFT", friendlyNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpBuffFilterOnlyMe, "Only show my buffs. (Plus other filters)")

    -- Friendly Debuffs
    local friendlyNpdeBuffEnable = CreateCheckbox("friendlyNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    friendlyNpdeBuffEnable:SetPoint("TOPLEFT", friendlyNpBuffFilterOnlyMe, "BOTTOMLEFT", -15, -2)
    friendlyNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(friendlyNpdeBuffEnable)
    end)
    CreateTooltip(friendlyNpdeBuffEnable, "Enable all Debuffs. Select filters under.")
    BBP.friendlyNpdeBuffEnable = friendlyNpdeBuffEnable

    local friendlyNpdeBuffFilterBlacklist = CreateCheckbox("friendlyNpdeBuffFilterBlacklist", "Blacklist", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterBlacklist:SetPoint("TOPLEFT", friendlyNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpdeBuffFilterBlacklist, "Hide blacklisted debuffs.")

    local friendlyNpdeBuffFilterWatchList = CreateCheckbox("friendlyNpdeBuffFilterWatchList", "Whitelist", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterWatchList:SetPoint("TOPLEFT", friendlyNpdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyNpdeBuffFilterWatchList, "Whitelist", "Only show whitelisted debuffs.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")

    local friendlyNpdeBuffFilterCC = CreateCheckbox("friendlyNpdeBuffFilterCC", "PvP CC", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterCC:SetPoint("LEFT", friendlyNpdeBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyNpdeBuffFilterCC, "Show Crowd Control", "Only show crowd control debuffs. (Plus other filters)\n\n|cff32f795Right-click for categories.|r\n\nBy default these auras are Enlarged.\nThis can be turned off below in settings on the left side.")
    friendlyNpdeBuffFilterCC:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)
    BBP.friendlyNpdeBuffFilterCC = friendlyNpdeBuffFilterCC

    local friendlyNpdeBuffFilterBlizzard = CreateCheckbox("friendlyNpdeBuffFilterBlizzard", "Blizzard Default Filter", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", friendlyNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpdeBuffFilterBlizzard, "Only show debuffs that are in the Blizzard Default nameplate filter\n(most of own auras + some cc etc) (Plus other filters).")

    local friendlyNpdeBuffFilterLessMinite = CreateCheckbox("friendlyNpdeBuffFilterLessMinite", "Under one min", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", friendlyNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyNpdeBuffFilterLessMinite, "Only show debuffs under one minute long. (Plus other filters)")

    --------------------------
    -- Personal Bar
    --------------------------
    -- Personal Bar Buffs
    local personalNpBuffEnable = CreateCheckbox("personalNpBuffEnable", "Show BUFFS", enableNameplateAuraCustomisation)
    personalNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 525, 170)
    personalNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(personalNpBuffEnable)
    end)
    CreateTooltip(personalNpBuffEnable, "Enable all Buffs. Select filters under.", "ANCHOR_LEFT")

    local personalBarText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalBarText:SetPoint("LEFT", personalNpBuffEnable, "CENTER", 0, 25)
    personalBarText:SetText("Personal Bar")
    local personalBarIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    personalBarIcon:SetAtlas("groupfinder-icon-friend")
    personalBarIcon:SetSize(28, 28)
    personalBarIcon:SetPoint("RIGHT", personalBarText, "LEFT", -3, 0)
    personalBarIcon:SetDesaturated(1)
    local _, playerClass = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[playerClass]
    if classColor then
        personalBarIcon:SetVertexColor(classColor.r, classColor.g, classColor.b)
    else
        personalBarIcon:SetVertexColor(1, 0.5, 0)
    end
    personalBarIcon:SetBlendMode("ADD")


    local hideDefaultPersonalNameplateAuras = CreateCheckbox("hideDefaultPersonalNameplateAuras", "Hide default", personalNpBuffEnable)
    hideDefaultPersonalNameplateAuras:SetPoint("LEFT", personalBarText, "RIGHT", 0, 0)
    CreateTooltip(hideDefaultPersonalNameplateAuras, "Hide default personal BuffFrame.\nI don't use Personal Bar and didn't even\nrealize it had it's own BuffFrame\nWill maybe update rest of aura handling for it if demand.", "ANCHOR_LEFT")

    local personalNpBuffFilterBlacklist = CreateCheckbox("personalNpBuffFilterBlacklist", "Blacklist", personalNpBuffEnable)
    personalNpBuffFilterBlacklist:SetPoint("TOPLEFT", personalNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterBlacklist, "Hide blacklisted buffs.", "ANCHOR_LEFT")

    local personalNpBuffFilterWatchList = CreateCheckbox("personalNpBuffFilterWatchList", "Whitelist", personalNpBuffEnable)
    personalNpBuffFilterWatchList:SetPoint("TOPLEFT", personalNpBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(personalNpBuffFilterWatchList, "Whitelist", "Only show whitelisted buffs.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)", "ANCHOR_LEFT")

    local personalNpBuffFilterImportantBuffs = CreateCheckbox("personalNpBuffFilterImportantBuffs", "PvP Buffs", personalNpBuffEnable)
    personalNpBuffFilterImportantBuffs:SetPoint("LEFT", personalNpBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(personalNpBuffFilterImportantBuffs, "Show Important Buffs", "Only show important PvP Buffs. (Plus other filters)\n\n|cff32f795Right-click for categories.|r\n\nBy default these auras are Enlarged.\nThis can be turned off below in settings on the left side.")
    personalNpBuffFilterImportantBuffs:HookScript("OnClick", function()
        BBP.UpdateImportantBuffsAndCCTables()
    end)

    local personalNpBuffFilterBlizzard = CreateCheckbox("personalNpBuffFilterBlizzard", "Blizzard Default Filter", personalNpBuffEnable)
    personalNpBuffFilterBlizzard:SetPoint("TOPLEFT", personalNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterBlizzard, "Only show buffs that are in the Blizzard Default nameplate filter. (Plus other filters)", "ANCHOR_LEFT")

    local personalNpBuffFilterLessMinite = CreateCheckbox("personalNpBuffFilterLessMinite", "Under one min", personalNpBuffEnable)
    personalNpBuffFilterLessMinite:SetPoint("TOPLEFT", personalNpBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterLessMinite, "Only show buffs under one minute long. (Plus other filters)", "ANCHOR_LEFT")

    local personalNpBuffFilterOnlyMe = CreateCheckbox("personalNpBuffFilterOnlyMe", "Only mine", personalNpBuffEnable)
    personalNpBuffFilterOnlyMe:SetPoint("TOPLEFT", personalNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpBuffFilterOnlyMe, "Only show my buffs. (Can select individual in whitelist too)\n\nThis filter allows auras from the Blizzard Default filter if it is enabled.", "ANCHOR_LEFT")

    -- Personal Bar Debuffs
    local personalNpdeBuffEnable = CreateCheckbox("personalNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    personalNpdeBuffEnable:SetPoint("TOPLEFT", personalNpBuffFilterOnlyMe, "BOTTOMLEFT", -15, -2)
    personalNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(personalNpdeBuffEnable)
    end)
    CreateTooltip(personalNpdeBuffEnable, "Enable all Debuffs. Select filters under.", "ANCHOR_LEFT")

    local personalNpdeBuffFilterBlacklist = CreateCheckbox("personalNpdeBuffFilterBlacklist", "Blacklist", personalNpdeBuffEnable)
    personalNpdeBuffFilterBlacklist:SetPoint("TOPLEFT", personalNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(personalNpdeBuffFilterBlacklist, "Hide blacklisted debuffs.", "ANCHOR_LEFT")

    local personalNpdeBuffFilterWatchList = CreateCheckbox("personalNpdeBuffFilterWatchList", "Whitelist", personalNpdeBuffEnable)
    personalNpdeBuffFilterWatchList:SetPoint("TOPLEFT", personalNpdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(personalNpdeBuffFilterWatchList, "Whitelist", "Only show whitelisted debuffs.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)",  "ANCHOR_LEFT")

    local personalNpdeBuffFilterCC = CreateCheckbox("personalNpdeBuffFilterCC", "PvP CC", personalNpdeBuffEnable)
    personalNpdeBuffFilterCC:SetPoint("LEFT", personalNpdeBuffFilterWatchList.text, "RIGHT", 0, 0)
    CreateTooltipTwo(personalNpdeBuffFilterCC, "Show Crowd Control", "Only show crowd control debuffs. (Plus other filters)\n\n|cff32f795Right-click for categories.|r\n\nBy default these auras are Enlarged.\nThis can be turned off below in settings on the left side.")
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
            ccOptionsFrame:SetFrameStrata("HIGH")
            ccOptionsFrame:SetMovable(true)
            ccOptionsFrame:EnableMouse(true)
            ccOptionsFrame:RegisterForDrag("LeftButton")
            ccOptionsFrame:SetScript("OnDragStart", ccOptionsFrame.StartMoving)
            ccOptionsFrame:SetScript("OnDragStop", ccOptionsFrame.StopMovingOrSizing)

            -- Title
            ccOptionsFrame.title = ccOptionsFrame:CreateFontString(nil, "OVERLAY")
            ccOptionsFrame.title:SetFontObject("GameFontHighlight")
            ccOptionsFrame.title:SetPoint("LEFT", ccOptionsFrame.TitleBg, "LEFT", 5, 0)
            ccOptionsFrame.title:SetText("PvP CC (All units)")


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
                { label = "Glow Full", var = "importantCCFullGlow", tt = "Full CC Auras", colorTbl = "importantCCFullGlowRGB", linkedVar = "importantCCFull" },
                { label = "Glow Disarm", var = "importantCCDisarmGlow", tt = "Disarm CC Auras", colorTbl = "importantCCDisarmGlowRGB", linkedVar = "importantCCDisarm" },
                { label = "Glow Root", var = "importantCCRootGlow", tt = "Root CC Auras", colorTbl = "importantCCRootGlowRGB", linkedVar = "importantCCRoot" },
                { label = "Glow Silence", var = "importantCCSilenceGlow", tt = "Silence CC Auras", colorTbl = "importantCCSilenceGlowRGB", linkedVar = "importantCCSilence" },
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
                CreateTooltipTwo(glowCheckbox, "Important Glow |T"..BBP.ImportantIcon..":22:22:0:0|t", "Check for a glow on all "..ccFilter.tt.."\n\n|cff32f795Right-click to change Color.|r", "Auras that are in the whitelist with glow enabled will override this behavior", "ANCHOR_TOPRIGHT")

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
                { label = "CC Full", var = "importantCCFull", tt = "Show Full CC Auras" },
                { label = "CC Disarm", var = "importantCCDisarm", tt = "Show Disarm CC Auras" },
                { label = "CC Root", var = "importantCCRoot", tt = "Show Root CC Auras" },
                { label = "CC Silence", var = "importantCCSilence", tt = "Show Silence CC Auras" },
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
            buffOptionsFrame:SetFrameStrata("HIGH")
            buffOptionsFrame:SetMovable(true)
            buffOptionsFrame:EnableMouse(true)
            buffOptionsFrame:RegisterForDrag("LeftButton")
            buffOptionsFrame:SetScript("OnDragStart", buffOptionsFrame.StartMoving)
            buffOptionsFrame:SetScript("OnDragStop", buffOptionsFrame.StopMovingOrSizing)

            -- Title
            buffOptionsFrame.title = buffOptionsFrame:CreateFontString(nil, "OVERLAY")
            buffOptionsFrame.title:SetFontObject("GameFontHighlight")
            buffOptionsFrame.title:SetPoint("LEFT", buffOptionsFrame.TitleBg, "LEFT", 5, 0)
            buffOptionsFrame.title:SetText("PvP Buffs (All units)")

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
                { label = "Glow Offensives", var = "importantBuffsOffensivesGlow", tt = "Important Offensive Auras", colorTbl = "importantBuffsOffensivesGlowRGB", linkedVar = "importantBuffsOffensives" },
                { label = "Glow Defensives", var = "importantBuffsDefensivesGlow", tt = "Important Defensive Auras", colorTbl = "importantBuffsDefensivesGlowRGB", linkedVar = "importantBuffsDefensives" },
                { label = "Glow Mobility", var = "importantBuffsMobilityGlow", tt = "Important Mobility/Freedom Auras", colorTbl = "importantBuffsMobilityGlowRGB", linkedVar = "importantBuffsMobility" },
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
                CreateTooltipTwo(glowCheckbox, "Important Glow |T"..BBP.ImportantIcon..":22:22:0:0|t", "Check for a glow on all "..buffFilter.tt.."\n\n|cff32f795Right-click to change Color.|r", "Auras that are in the whitelist with glow enabled will override this behavior", "ANCHOR_TOPRIGHT")

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
                { label = "Important Offensives", var = "importantBuffsOffensives", tt = "Show Important Offensives" },
                { label = "Important Defensives", var = "importantBuffsDefensives", tt = "Show Important Defensives" },
                { label = "Important Mobility", var = "importantBuffsMobility", tt = "Show Important Mobility/Freedoms" },
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


    local personalNpdeBuffFilterLessMinite = CreateCheckbox("personalNpdeBuffFilterLessMinite", "Under one min", personalNpdeBuffEnable)
    personalNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", personalNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(personalNpdeBuffFilterLessMinite, "Only show debuffs under one minute long. (Plus other filters)", "ANCHOR_LEFT")

    --------------------------
    -- Nameplate settings
    --------------------------
    local nameplateAurasXPos = CreateSlider(enableNameplateAuraCustomisation, "x offset", -50, 50, 1, "nameplateAurasXPos", "X")
    nameplateAurasXPos:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -230, -240)
    CreateTooltip(nameplateAurasXPos, "Aura x offset")

    local nameplateAurasYPos = CreateSlider(enableNameplateAuraCustomisation, "y offset", -50, 50, 1, "nameplateAurasYPos", "Y")
    nameplateAurasYPos:SetPoint("TOPLEFT", nameplateAurasXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasYPos, "Aura y offset when name is showing")

    local nameplateAurasNoNameYPos = CreateSlider(enableNameplateAuraCustomisation, "no name y offset", -50, 50, 1, "nameplateAurasNoNameYPos", "Y")
    nameplateAurasNoNameYPos:SetPoint("TOPLEFT", nameplateAurasYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasNoNameYPos, "Aura y offset when name is hidden\n(Unimportant non-targeted npcs etc)")

    local nameplateAuraScale = CreateSlider(enableNameplateAuraCustomisation, "Global Aura Size", 0.7, 2, 0.01, "nameplateAuraScale")
    nameplateAuraScale:SetPoint("TOPLEFT", nameplateAurasNoNameYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraScale, "Global Aura Size", "The general size of ALL auras. Will be added on top of every aura type: buff, debuff, enlarged, compacted.")

    local nameplateAuraBuffScale = CreateSlider(enableNameplateAuraCustomisation, "Buff Size", 0.7, 2, 0.01, "nameplateAuraBuffScale")
    nameplateAuraBuffScale:SetPoint("TOPLEFT", nameplateAuraScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraBuffScale, "Buff Size", "Size of nameplate Buffs.", "Will not be applied to auras marked Enlarged or Compacted")

    local nameplateAuraDebuffScale = CreateSlider(enableNameplateAuraCustomisation, "Debuff Size", 0.7, 2, 0.01, "nameplateAuraDebuffScale")
    nameplateAuraDebuffScale:SetPoint("TOPLEFT", nameplateAuraBuffScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraDebuffScale, "Debuff Size", "Size of nameplate Debuffs.", "Will not be applied to auras marked Enlarged or Compacted")

    local nameplateAuraCountScale = CreateSlider(enableNameplateAuraCustomisation, "Aura Stack Size", 0.7, 2, 0.01, "nameplateAuraCountScale")
    nameplateAuraCountScale:SetPoint("TOPLEFT", nameplateAuraDebuffScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateAuraCountScale, "Aura Stack Size", "Size of the stack/count/charges number on auras.")

    local nameplateAuraEnlargedScale = CreateSlider(enableNameplateAuraCustomisation, "Enlarged Aura Size", 1, 2, 0.01, "nameplateAuraEnlargedScale")
    nameplateAuraEnlargedScale:SetPoint("TOPLEFT", nameplateAuraScale, "BOTTOMLEFT", -170, -101)
    local enlargedAuraIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    enlargedAuraIcon:SetTexture(BBP.EnlargedIcon)
    enlargedAuraIcon:SetSize(18, 18)
    enlargedAuraIcon:SetPoint("RIGHT", nameplateAuraEnlargedScale, "LEFT", -3, 0)





    local npColorAuraBorder = CreateCheckbox("npColorAuraBorder", "Color Border by Type", enableNameplateAuraCustomisation)
    npColorAuraBorder:SetPoint("RIGHT", enlargedAuraIcon, "LEFT", -10, 295)
    CreateTooltipTwo(npColorAuraBorder, "Color Border by Type", "Color Border by Type")

    local npAuraBuffsRGB = CreateColorBox(npColorAuraBorder, "npAuraBuffsRGB", "Buffs")
    npAuraBuffsRGB:SetPoint("TOPLEFT", npColorAuraBorder, "BOTTOMLEFT", 15, 0)

    local npAuraPoisonRGB = CreateColorBox(npColorAuraBorder, "npAuraPoisonRGB", "Poison")
    npAuraPoisonRGB:SetPoint("TOPLEFT", npAuraBuffsRGB, "BOTTOMLEFT", 0, 0)

    local npAuraCurseRGB = CreateColorBox(npColorAuraBorder, "npAuraCurseRGB", "Curse")
    npAuraCurseRGB:SetPoint("TOPLEFT", npAuraPoisonRGB, "BOTTOMLEFT", 0, 0)

    local npAuraDiseaseRGB = CreateColorBox(npColorAuraBorder, "npAuraDiseaseRGB", "Disease")
    npAuraDiseaseRGB:SetPoint("TOPLEFT", npAuraCurseRGB, "BOTTOMLEFT", 0, 0)

    local npAuraMagicRGB = CreateColorBox(npColorAuraBorder, "npAuraMagicRGB", "Magic")
    npAuraMagicRGB:SetPoint("TOPLEFT", npAuraDiseaseRGB, "BOTTOMLEFT", 0, 0)

    local npAuraOtherRGB = CreateColorBox(npColorAuraBorder, "npAuraOtherRGB", "Other")
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






    local nameplateAuraEnlargedSquare = CreateCheckbox("nameplateAuraEnlargedSquare", "Square Aura", enableNameplateAuraCustomisation)
    nameplateAuraEnlargedSquare:SetPoint("RIGHT", enlargedAuraIcon, "LEFT", -60, 1)
    CreateTooltipTwo(nameplateAuraEnlargedSquare, "Square Enlarged Aura", "Square the Enlarged Aura.", nil)

    local sortCompactedAurasFirst = CreateCheckbox("sortCompactedAurasFirst", "Sort Compacted Auras First", enableNameplateAuraCustomisation)
    sortCompactedAurasFirst:SetPoint("BOTTOMLEFT", nameplateAuraEnlargedSquare, "TOPLEFT", 0, 5)
    CreateTooltipTwo(sortCompactedAurasFirst, "Sort Compacted Auras First", "Sorts the nameplate auras to put Compacted auras first and Enlarged auras last.")

    local sortEnlargedAurasFirst = CreateCheckbox("sortEnlargedAurasFirst", "Sort Enlarged Auras First", enableNameplateAuraCustomisation)
    sortEnlargedAurasFirst:SetPoint("BOTTOMLEFT", sortCompactedAurasFirst, "TOPLEFT", 0, -4)
    CreateTooltipTwo(sortEnlargedAurasFirst, "Sort Enlarged Auras First", "Sorts the nameplate auras to put Enlarged auras first and Compacted auras last.")

    local sortDurationAuras = CreateCheckbox("sortDurationAuras", "Sort Auras by Duration", enableNameplateAuraCustomisation)
    sortDurationAuras:SetPoint("BOTTOMLEFT", sortEnlargedAurasFirst, "TOPLEFT", 0, -4)
    CreateTooltipTwo(sortDurationAuras, "Sort Auras by Duration", "Sorts the nameplate auras with the shortest duration first. Enlarged Auras will still appear first but also sorted by duration (I want feedback here if you have).")
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

    local enlargeAllImportantBuffs = CreateCheckbox("enlargeAllImportantBuffs", "Enlarge all Important Buffs", enableNameplateAuraCustomisation)
    enlargeAllImportantBuffs:SetPoint("BOTTOMLEFT", sortDurationAuras, "TOPLEFT", 0, -4)
    CreateTooltipTwo(enlargeAllImportantBuffs, "Enlarge all Important Buffs", "Enlarges all Important PvP Buffs.\n\nThis setting requires any of the\n\"PvP Buffs\" filters to be active.")
    BBP.enlargeAllImportantBuffs = enlargeAllImportantBuffs

    local enlargeAllCC = CreateCheckbox("enlargeAllCC", "Enlarge all CC", enableNameplateAuraCustomisation)
    enlargeAllCC:SetPoint("BOTTOMLEFT", enlargeAllImportantBuffs, "TOPLEFT", 0, -4)
    CreateTooltipTwo(enlargeAllCC, "Enlarge all PvP CC", "Enlarges all PvP CC.\n\nThis setting requires any of the\n\"PvP CC\" filters to be active.")

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

    local nameplateAuraCompactedScale = CreateSlider(enableNameplateAuraCustomisation, "Compacted Aura Size", 0.4, 1, 0.01, "nameplateAuraCompactedScale")
    nameplateAuraCompactedScale:SetPoint("TOPLEFT", nameplateAuraEnlargedScale, "BOTTOMLEFT", 0, -17)
    local compactedAuraIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    compactedAuraIcon:SetTexture(BBP.CompactIcon)
    compactedAuraIcon:SetSize(18, 18)
    compactedAuraIcon:SetPoint("RIGHT", nameplateAuraCompactedScale, "LEFT", -3, 0)

    local nameplateAuraCompactedSquare = CreateCheckbox("nameplateAuraCompactedSquare", "Halve Aura", enableNameplateAuraCustomisation)
    nameplateAuraCompactedSquare:SetPoint("RIGHT", compactedAuraIcon, "LEFT", -60, 1)
    CreateTooltipTwo(nameplateAuraCompactedSquare, "Halve Compacted Aura", "Halve the Compacted Aura.", "Half-sized auras will count as half towards \"max buffs per row\" and if two are next to eachother they will combine taking up the space of 1 normal aura slot.")

    local nameplateAuraKeyAuraPositionEnabled = CreateCheckbox("nameplateAuraKeyAuraPositionEnabled", "Enable Key Auras", enableNameplateAuraCustomisation)
    nameplateAuraKeyAuraPositionEnabled:SetPoint("TOPLEFT", nameplateAuraCompactedSquare, "BOTTOMLEFT", 5, -12)
    CreateTooltipTwo(nameplateAuraKeyAuraPositionEnabled, "Enable Key Auras", "Show and move CC and Important Buffs to the right of healthbar similar to BigDebuffs.", "All CC will be moved, but unlike BigDebuffs, this location is intended only for a select number of very important buffs, such as immunities.\n\nSmaller, less urgent buffs will either be displayed in their normal position (if enabled) or hidden completely (if disabled).\n\nExpect to a see a lot of tweaks to this. WIP.")
    nameplateAuraKeyAuraPositionEnabled:SetScale(1.4)

    local pvpCC = CreateFrame("CheckButton", nil, nameplateAuraKeyAuraPositionEnabled, "InterfaceOptionsCheckButtonTemplate")
    pvpCC:SetPoint("TOPLEFT", nameplateAuraKeyAuraPositionEnabled, "BOTTOMRIGHT", -20, 9)
    pvpCC.Text:SetText("Glow & Filter")
    pvpCC:SetChecked(BetterBlizzPlatesDB.otherNpdeBuffFilterCC)
    pvpCC:SetIgnoreParentScale(true)
    pvpCC:SetScale(0.7)
    CreateTooltipTwo(pvpCC, "Glow & Filter", "Enable to adjust which CC categories show and which you want a Glow on.\n\n|cff32f795Right-click to open settings.|r","This checkbox is the same as the \"PvP CC\" filter above in the enemy filter settings. Just placed here as well for it to be a bit easier to understand.")

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

    local nameplateAuraKeyAuraPositionFriendly = CreateCheckbox("nameplateAuraKeyAuraPositionFriendly", "Friendly", nameplateAuraKeyAuraPositionEnabled)
    nameplateAuraKeyAuraPositionFriendly:SetPoint("LEFT", pvpCC.text, "RIGHT", 0, 0)
    CreateTooltipTwo(nameplateAuraKeyAuraPositionFriendly, "Enable Key Auras on Friendly", "Enable Key Auras on Friendly units as well.")
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

    local nameplateKeyAuraScale = CreateSlider(nameplateAuraKeyAuraPositionEnabled, "Key Aura Size", 0.6, 2.2, 0.01, "nameplateKeyAuraScale")
    nameplateKeyAuraScale:SetPoint("TOPLEFT", nameplateAuraKeyAuraPositionEnabled, "BOTTOMLEFT", 20, -27)
    CreateTooltipTwo(nameplateKeyAuraScale, "Key Aura Size", "The size of Key Auras like CC and very Important Buffs.")
    nameplateKeyAuraScale:SetScale(0.7)

    local nameplateKeyAurasXPos = CreateSlider(nameplateAuraKeyAuraPositionEnabled, "Key Aura X Offset", -80, 80, 1, "nameplateKeyAurasXPos", "X")
    nameplateKeyAurasXPos:SetPoint("TOPLEFT", nameplateKeyAuraScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateKeyAurasXPos, "Key Aura X Offset", "X Offset for Key Auras.\nRight click to input own values.")
    nameplateKeyAurasXPos:SetScale(0.7)

    local nameplateKeyAurasYPos = CreateSlider(nameplateAuraKeyAuraPositionEnabled, "Key Aura Y Offset", -80, 80, 1, "nameplateKeyAurasYPos", "Y")
    nameplateKeyAurasYPos:SetPoint("TOPLEFT", nameplateKeyAurasXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateKeyAurasYPos, "Key Aura Y Offset", "Y Offset for Key Auras.\nRight click to input own values.")
    nameplateKeyAurasYPos:SetScale(0.7)

    local nameplateKeyAurasHorizontalGap = CreateSlider(nameplateAuraKeyAuraPositionEnabled, "Key Aura Aura Gap", 0, 10, 1, "nameplateKeyAurasHorizontalGap", "Y")
    nameplateKeyAurasHorizontalGap:SetPoint("TOPLEFT", nameplateKeyAurasYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateKeyAurasHorizontalGap, "Key Aura Gap", "Horizontal Gap between the Key Auras.\nRight click to input own values.")
    nameplateKeyAurasHorizontalGap:SetScale(0.7)

    local nameplateKeyAurasAnchor = CreateAnchorDropdown(
        "nameplateKeyAurasAnchorDropdown",
        enableNameplateAuraCustomisation,
        "Select Key Aura Anchor",
        "nameplateKeyAurasAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = nameplateKeyAurasHorizontalGap, x = -16, y = -40, label = "Key Auras Position" },nil,nil,{"RIGHT", "LEFT", "CENTER"}
    )

    local nameplateKeyAurasFriendlyAnchor = CreateAnchorDropdown(
        "nameplateKeyAurasFriendlyAnchorDropdown",
        enableNameplateAuraCustomisation,
        "Select Friendly Key Aura Anchor",
        "nameplateKeyAurasFriendlyAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = nameplateKeyAurasHorizontalGap, x = -16, y = -85, label = "Friendly Key Auras Position" },nil,nil,{"RIGHT", "LEFT", "CENTER"}
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

    local nameplateAurasEnemyCenteredAnchor = CreateCheckbox("nameplateAurasEnemyCenteredAnchor", "Center Auras on Enemy", enableNameplateAuraCustomisation)
    nameplateAurasEnemyCenteredAnchor:SetPoint("BOTTOM", nameplateAurasXPos, "TOP", -80, 80)
    CreateTooltipTwo(nameplateAurasEnemyCenteredAnchor, "Center Auras on Enemy", "Keep auras centered on enemy nameplates.")
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

    local nameplateAuraRightToLeft = CreateCheckbox("nameplateAuraRightToLeft", "Reverse Auras", enableNameplateAuraCustomisation)
    nameplateAuraRightToLeft:SetPoint("BOTTOMLEFT", nameplateAurasEnemyCenteredAnchor, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateAuraRightToLeft, "Reverse Auras", "Stack auras right to left instead of the default left to right.")

    local nameplateAurasFriendlyCenteredAnchor = CreateCheckbox("nameplateAurasFriendlyCenteredAnchor", "Center Auras on Friendly", enableNameplateAuraCustomisation)
    nameplateAurasFriendlyCenteredAnchor:SetPoint("TOPLEFT", nameplateAurasEnemyCenteredAnchor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAurasFriendlyCenteredAnchor, "Keep auras centered on friendly nameplates.")

    local nameplateCenterAllRows = CreateCheckbox("nameplateCenterAllRows", "Center every row", enableNameplateAuraCustomisation)
    nameplateCenterAllRows:SetPoint("TOP", nameplateAurasFriendlyCenteredAnchor, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateCenterAllRows, "Centers every new row on top of the previous row.\n \nBy default the first icon of a new row starts\non top of the first icon of the last row.")

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

    local nameplateAuraPlayersOnly = CreateCheckbox("nameplateAuraPlayersOnly", "Hide auras on NPC's", enableNameplateAuraCustomisation)
    nameplateAuraPlayersOnly:SetPoint("TOP", nameplateCenterAllRows, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAuraPlayersOnly, "Hide auras on NPC's and only show on Players.\n\n(Check \"Show on Target\" to always show on Target)")

    local nameplateAuraPlayersOnlyShowTarget = CreateCheckbox("nameplateAuraPlayersOnlyShowTarget", "Show on Target", nameplateAuraPlayersOnly)
    nameplateAuraPlayersOnlyShowTarget:SetPoint("TOP", nameplateCenterAllRows, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAuraPlayersOnlyShowTarget, "Show Auras on current Target regardless of it is a Player or a NPC.")

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


    local nameplateAuraSquare = CreateCheckbox("nameplateAuraSquare", "Square Auras", enableNameplateAuraCustomisation)
    nameplateAuraSquare:SetPoint("LEFT", nameplateAurasEnemyCenteredAnchor.text, "RIGHT", 5, 0)
    CreateTooltip(nameplateAuraSquare, "Square aura icons.")

    local nameplateAuraTestMode = CreateCheckbox("nameplateAuraTestMode", "Test Mode", enableNameplateAuraCustomisation)
    nameplateAuraTestMode:SetPoint("BOTTOMLEFT", nameplateAuraSquare, "TOPLEFT", 0, 0)
    CreateTooltipTwo(nameplateAuraTestMode, "Test Mode", "Add some auras to nameplates for testing.", "Testing only respects the Show BUFF/DEBUFF filters and none of the sub-filters.", "ANCHOR_TOP")
    nameplateAuraTestMode:SetScale(1.4)

    local showDefaultCooldownNumbersOnNpAuras = CreateCheckbox("showDefaultCooldownNumbersOnNpAuras", "Default CD", enableNameplateAuraCustomisation)
    showDefaultCooldownNumbersOnNpAuras:SetPoint("TOPLEFT", nameplateAuraSquare, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showDefaultCooldownNumbersOnNpAuras, "Show Blizzard Cooldown", "Show default cooldown counter.\n\n|cff32f795If you use OmniCC this setting is irrelevant and will not work.\n\nNote: If using OmniCC you may have to reduce the minimun cooldown size allowed in your OmniCC settings for the timer to show on auras.", "This setting requires the Blizzard setting \"Show Numbers for Cooldowns\" turned on. It is in Options->Gameplay->Action Bars")

    local hideNpAuraSwipe = CreateCheckbox("hideNpAuraSwipe", "Hide CD Swipe", enableNameplateAuraCustomisation)
    hideNpAuraSwipe:SetPoint("TOPLEFT", showDefaultCooldownNumbersOnNpAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideNpAuraSwipe, "Hide the cooldown swipe animation.")
    nameplateAuraPlayersOnlyShowTarget:SetPoint("TOP", hideNpAuraSwipe, "BOTTOM", 0, pixelsBetweenBoxes)

    local nameplateAuraTaller = CreateCheckbox("nameplateAuraTaller", "Taller Auras", enableNameplateAuraCustomisation)
    nameplateAuraTaller:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 9, 0)
    CreateTooltipTwo(nameplateAuraTaller, "Taller Auras", "Make auras a little bit taller and show more of the icon texture.")
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

    local showInterruptsOnNameplateAuras = CreateCheckbox("showInterruptsOnNameplateAuras", "Interrupts", enableNameplateAuraCustomisation)
    showInterruptsOnNameplateAuras:SetPoint("TOPLEFT", nameplateAuraTaller, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showInterruptsOnNameplateAuras, "Show Interrupts", "Show interrupt duration as a nameplate aura when a unit gets interrupted.")
    showInterruptsOnNameplateAuras:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BBP.SetUpAuraInterrupts()
        else
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local onlyPandemicAuraMine = CreateCheckbox("onlyPandemicAuraMine", "Only Pandemic Mine", enableNameplateAuraCustomisation)
    onlyPandemicAuraMine:SetPoint("TOPLEFT", showInterruptsOnNameplateAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(onlyPandemicAuraMine, "Only show the red pandemic aura glow on my own auras", "ANCHOR_LEFT")

    local nameplateResourceDoNotRaiseAuras = CreateCheckbox("nameplateResourceDoNotRaiseAuras", "Don't raise for resource", enableNameplateAuraCustomisation)
    nameplateResourceDoNotRaiseAuras:SetPoint("TOPLEFT", onlyPandemicAuraMine, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateResourceDoNotRaiseAuras, "Don't raise auras when nameplate resource is on.\n(By default they get raised an extra 18 pixels)", "ANCHOR_LEFT")

--[=[
    local AuraGrowLeft = CreateCheckbox("nameplateAurasGrowLeft", "Grow left", contentFrame)
    AuraGrowLeft:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 5, 0)
]=]

    local maxAurasOnNameplate = CreateSlider(enableNameplateAuraCustomisation, "Max auras on nameplate", 1, 24, 1, "maxAurasOnNameplate")
    maxAurasOnNameplate:SetPoint("LEFT", nameplateAurasXPos, "RIGHT", 30, 0)

    local nameplateAuraRowAmount = CreateSlider(enableNameplateAuraCustomisation, "Enemy Max auras per row", 2, 24, 1, "nameplateAuraRowAmount")
    nameplateAuraRowAmount:SetPoint("TOP", maxAurasOnNameplate,  "BOTTOM", 0, -17)

    local nameplateAuraRowFriendlyAmount = CreateSlider(enableNameplateAuraCustomisation, "Friendly Max auras per row", 2, 24, 1, "nameplateAuraRowFriendlyAmount")
    nameplateAuraRowFriendlyAmount:SetPoint("TOP", nameplateAuraRowAmount,  "BOTTOM", 0, -17)

    local nameplateAuraWidthGap = CreateSlider(enableNameplateAuraCustomisation, "Horizontal gap between auras", 0, 18, 0.5, "nameplateAuraWidthGap")
    nameplateAuraWidthGap:SetPoint("TOP", nameplateAuraRowFriendlyAmount,  "BOTTOM", 0, -17)

    local nameplateAuraHeightGap = CreateSlider(enableNameplateAuraCustomisation, "Vertical gap between auras", 0, 18, 0.5, "nameplateAuraHeightGap")
    nameplateAuraHeightGap:SetPoint("TOP", nameplateAuraWidthGap,  "BOTTOM", 0, -17)

    local defaultNpAuraCdSize = CreateSlider(showDefaultCooldownNumbersOnNpAuras, "Default CD Text Size", 0.1, 2, 0.01, "defaultNpAuraCdSize")
    defaultNpAuraCdSize:SetPoint("TOP", nameplateAuraHeightGap,  "BOTTOM", 0, -17)
    CreateTooltipTwo(defaultNpAuraCdSize, "Default CD Text Size", "The text size of the default Blizzard Timer Text.\nEnable \"Default CD\" to use.\n\nIf you use OmniCC this setting will not work.")
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

    local targetNameplateAuraScale = CreateSlider(targetNameplateAuraScaleEnabled, "Target Aura Size", 0.5, 1.8, 0.01, "targetNameplateAuraScale")
    targetNameplateAuraScale:SetPoint("TOP", defaultNpAuraCdSize,  "BOTTOM", 0, -17)
    CreateTooltipTwo(targetNameplateAuraScale, "Target Aura Size", "The aura size on your current target.\nYou might have to adjust the y offset as well.", nil, "ANCHOR_LEFT")
    targetNameplateAuraScaleEnabled:SetPoint("LEFT", targetNameplateAuraScale, "RIGHT", 5, 0)
    CreateTooltipTwo(targetNameplateAuraScaleEnabled, "Enable Target Aura Size", "Change the size of your current targets auras. You might have to adjust the y offset as well with this setting.", "If you want auras to be the same size as non-targets use the same size as \"Nameplate Size\" in the general tab. By default it is 0.8", "ANCHOR_LEFT")
    targetNameplateAuraScaleEnabled:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(targetNameplateAuraScale)
        else
            DisableElement(targetNameplateAuraScale)
        end
    end)

    local separateAuraBuffRow = CreateCheckbox("separateAuraBuffRow", "Separate Buff Row", enableNameplateAuraCustomisation)
    separateAuraBuffRow:SetPoint("TOPLEFT", nameplateAuraCountScale, "BOTTOMLEFT", 0, -10)
    CreateTooltip(separateAuraBuffRow, "Show Buffs on a separate row on top of debuffs.", "ANCHOR_LEFT")

    local nameplateAuraTypeGap = CreateSlider(enableNameplateAuraCustomisation, "Gap between Buffs and Debuffs", -100, 100, 0.5, "nameplateAuraTypeGap")
    nameplateAuraTypeGap:SetPoint("LEFT", separateAuraBuffRow.text,  "RIGHT", 0, 0)
    CreateTooltipTwo(nameplateAuraTypeGap, "Gap between Buffs and Debuffs", "The vertical gap between Buffs and Debuffs (0 is default).\n\nOnly works if \"Separate Buff Row\" is enabled.", nil, "ANCHOR_LEFT")

    local imintoodeep1 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    imintoodeep1:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -95, -80)
    imintoodeep1:SetText("Scroll down for more settings")

    enableNameplateAuraCustomisation:HookScript("OnClick", function (self)
        if self:GetChecked() then
            StaticPopup_Show("BBP_NP_AURA_ENABLE")
        else
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
        CheckAndToggleCheckboxes(enableNameplateAuraCustomisation)
        --TogglePanel()
    end)
    --TogglePanel()

    local betaHighlightIcon = enableNameplateAuraCustomisation:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", enableNameplateAuraCustomisation, "LEFT", 8, 0)


    local nameplateAuraTestMode2 = CreateCheckbox("nameplateAuraTestMode", "Test Mode", enableNameplateAuraCustomisation)
    nameplateAuraTestMode2:SetPoint("LEFT", nameplateKeyAurasAnchor, "RIGHT", 60, -25)
    CreateTooltipTwo(nameplateAuraTestMode2, "Test Mode", "Add some auras to nameplates for testing.", "Testing is limited and not 100% accurate and only respects the Show BUFF/DEBUFF filters and none of the sub-filters.", "ANCHOR_TOP")
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
    guiCVarControl.name = "CVar Control"
    guiCVarControl.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiCVarControl)
    local guiCVarControlCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiCVarControl, guiCVarControl.name, guiCVarControl.name)
    CreateTitle(guiCVarControl)

    local bgImg = guiCVarControl:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiCVarControl, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local moreBlizzSettings = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettings:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 0, 0)
    moreBlizzSettings:SetText("Blizzard CVar settings not available in base UI")

    local stackingNameplatesText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackingNameplatesText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 20, -35)
    stackingNameplatesText:SetText("Stacking nameplate overlap amount")

    local nameplateMotion = CreateCheckbox("nameplateMotion", "Stacking nameplates", guiCVarControl, true)
    nameplateMotion:SetPoint("TOPLEFT", stackingNameplatesText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    --CreateTooltip(nameplateMotion, "Turn on stacking nameplates.\n\nI recommend using around 0.30 Vertical Overlap", nil, "nameplateMotion")
    CreateTooltipTwo(nameplateMotion, "Stacking Nameplates", "Turn on stacking nameplates.", nil, nil, "nameplateMotion")

    local nameplateOverlapH = CreateSlider(nameplateMotion, "Horizontal Overlap", 0.05, 1, 0.01, "nameplateOverlapH")
    nameplateOverlapH:SetPoint("TOPLEFT", nameplateMotion, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(nameplateOverlapH, "Horizontal Overlap", "Space between nameplates horizontally", nil, nil, "nameplateOverlapH")
    local nameplateOverlapHReset = CreateResetButton(nameplateOverlapH, "nameplateOverlapH", nameplateMotion)

    local nameplateOverlapV = CreateSlider(nameplateMotion, "Vertical Overlap", 0.05, 1.1, 0.01, "nameplateOverlapV")
    nameplateOverlapV:SetPoint("TOPLEFT", nameplateOverlapH, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOverlapV, "Vertical Overlap", "Space between nameplates vertically", nil, nil, "nameplateOverlapV")
    local nameplateOverlapVReset = CreateResetButton(nameplateOverlapV, "nameplateOverlapV", nameplateMotion)

    local nameplateMotionSpeed = CreateSlider(nameplateMotion, "Nameplate Motion Speed", 0.01, 1, 0.01, "nameplateMotionSpeed")
    nameplateMotionSpeed:SetPoint("TOPLEFT", nameplateOverlapV, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateMotionSpeed, "Nameplate Motion Speed", "The speed at which nameplates move into their new position", nil, nil, "nameplateMotionSpeed")
    local nameplateMotionSpeedReset = CreateResetButton(nameplateMotionSpeed, "nameplateMotionSpeed", nameplateMotion)

    if not BetterBlizzPlatesDB.nameplateMotion then
        CheckAndToggleCheckboxes(nameplateMotion)
    end

    nameplateMotion:HookScript("OnClick", function() CheckAndToggleCheckboxes(nameplateMotion) end)




    local comboPointsText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    comboPointsText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 20, -210)
    comboPointsText:SetText("Resource Settings (Combo points etc)")
    local comboPointIcon = guiCVarControl:CreateTexture(nil, "ARTWORK")
    comboPointIcon:SetAtlas("ClassOverlay-ComboPoint")
    comboPointIcon:SetSize(16, 16)
    comboPointIcon:SetPoint("RIGHT", comboPointsText, "LEFT", -3, 0)

    local tempResourceWA = CreateFrame("Button", nil, guiCVarControl, "UIPanelButtonTemplate")
    tempResourceWA:SetText("Import WeakAura")
    tempResourceWA:SetSize(170, 37)
    tempResourceWA:SetPoint("TOPLEFT", comboPointsText, "BOTTOMLEFT", 0, -6)
    tempResourceWA:SetScript("OnClick", function()
        if WeakAuras then
            WeakAuras.Import(BBP.tempComboPointWA)
        else
            print("WeakAuras not enabled.")
        end
    end)
    CreateTooltipTwo(tempResourceWA, "Import Resource WeakAura", "Import temporary weakaura for resource on nameplate (all classes)")


    local nameplateResourceOnTarget = CreateCheckbox("nameplateResourceOnTarget", "Show resource on nameplate", guiCVarControl, true, BBP.TargetResourceUpdater)
    nameplateResourceOnTarget:SetPoint("TOPLEFT", comboPointsText, "BOTTOMLEFT", -4, pixelsOnFirstBox-45)
    CreateTooltipTwo(nameplateResourceOnTarget, "Nameplate Resource", "Show combo points, warlock shards, arcane charges etc on nameplates.", nil, nil, "nameplateResourceOnTarget")
    notWorking(nameplateResourceOnTarget)

    local nameplateResourceUnderCastbar = CreateCheckbox("nameplateResourceUnderCastbar", "Anchor resource underneath healthbar/castbar", guiCVarControl, nil, BBP.RegisterTargetCastingEvents)
    nameplateResourceUnderCastbar:SetPoint("TOP", nameplateResourceOnTarget, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateResourceUnderCastbar, "Anchor Resource Under", "Anchor nameplate combo points etc underneath the healthbar and underneath the castbar during casts.\n\nWEAKAURA: This setting will work with the Imported WeakAura.")
    nameplateResourceOnTarget:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(nameplateResourceOnTarget)
    end)
    if not BBP.isMoP then
        notWorking(nameplateResourceUnderCastbar)
    end

    local hideResourceOnFriend = CreateCheckbox("hideResourceOnFriend", "Hide resource on friendly nameplates", guiCVarControl)
    hideResourceOnFriend:SetPoint("TOP", nameplateResourceUnderCastbar, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideResourceOnFriend, "Hide Resource on Friendly", "Hide combo points, warlock shards, arcane charges etc on friendly nameplates when targeting them.")
    notWorking(hideResourceOnFriend, true)

    local nameplateResourceScale = CreateSlider(guiCVarControl, "Resource Scale", 0.2, 1.7, 0.01, "nameplateResourceScale")
    nameplateResourceScale:SetPoint("TOPLEFT", hideResourceOnFriend, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(nameplateResourceScale, "Resource Scale", "The scale of nameplate Resource (Combo points etc)")
    CreateResetButton(nameplateResourceScale, "nameplateResourceScale", guiCVarControl)
    notWorking(nameplateResourceScale, true)

    local nameplateResourceXPos = CreateSlider(guiCVarControl, "x offset", -100, 100, 1, "nameplateResourceXPos", "X")
    nameplateResourceXPos:SetPoint("TOPLEFT", nameplateResourceScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceXPos, "Nameplate Resource X Position", "X offset for Nameplate Resource")
    CreateResetButton(nameplateResourceXPos, "nameplateResourceXPos", guiCVarControl)
    notWorking(nameplateResourceXPos, true)

    local nameplateResourceYPos = CreateSlider(guiCVarControl, "y offset", -100, 100, 1, "nameplateResourceYPos", "Y")
    nameplateResourceYPos:SetPoint("TOPLEFT", nameplateResourceXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceYPos, "Nameplate Resource Y Position", "Y offset for Nameplate Resource")
    CreateResetButton(nameplateResourceYPos, "nameplateResourceYPos", guiCVarControl)
    notWorking(nameplateResourceYPos, true)

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", "Dark Mode", guiCVarControl, nil, BBP.DarkModeNameplateResources)
    darkModeNameplateResource:SetPoint("TOPLEFT", nameplateResourceYPos, "BOTTOMLEFT", -12, -4)
    CreateTooltipTwo(darkModeNameplateResource, "Resource Dark Mode", "Dark Mode for Nameplate Resource")
    notWorking(darkModeNameplateResource, true)

    local darkModeNameplateColor = CreateSlider(darkModeNameplateResource, "Darkness Amount", 0, 1, 0.01, "darkModeNameplateColor")
    darkModeNameplateColor:SetPoint("TOPLEFT", darkModeNameplateResource, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(darkModeNameplateColor, "How dark you want nameplate resource")
    notWorking(darkModeNameplateColor, true)

    darkModeNameplateResource:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeNameplateResource)
    end)

    local disableCVarForceOnLogin = CreateCheckbox("disableCVarForceOnLogin", "Disable all CVar forcing", guiCVarControl)
    disableCVarForceOnLogin:SetPoint("BOTTOM", guiCVarControl, "BOTTOM", -80, 60)
    CreateTooltipTwo(disableCVarForceOnLogin, "Disable all CVar Forcing", "Disables all forcing of CVar's on login (Not recommended)", "(Sliders adjusting CVar values will still change CVars.)")

    local nameplateAlphaText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateAlphaText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 400, -35)
    nameplateAlphaText:SetText("Nameplate alpha settings")

    local nameplateMinAlpha = CreateSlider(guiCVarControl, "Min Alpha", 0, 1, 0.01, "nameplateMinAlpha")
    nameplateMinAlpha:SetPoint("TOP", nameplateAlphaText, "BOTTOM", 0, -17)
    CreateTooltipTwo(nameplateMinAlpha, "Min Alpha", "The minimum alpha value of nameplates", "If you never want nameplates to be faded set this to 1.\nFor LOS alpha adjust \"Occluded Alpha\".", nil, "nameplateMinAlpha")
    CreateResetButton(nameplateMinAlpha, "nameplateMinAlpha", guiCVarControl)

    local nameplateMinAlphaDistance = CreateSlider(guiCVarControl, "Min Alpha Distance", 0, 60, 1, "nameplateMinAlphaDistance")
    nameplateMinAlphaDistance:SetPoint("TOPLEFT", nameplateMinAlpha, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateMinAlphaDistance, "Min Alpha Distance", "The distance from the max distance that nameplates will reach their minimum alpha.", nil, nil, "nameplateMinAlphaDistance")
    CreateResetButton(nameplateMinAlphaDistance, "nameplateMinAlphaDistance", guiCVarControl)

    local nameplateMaxAlpha = CreateSlider(guiCVarControl, "Max Alpha", 0, 1, 0.01, "nameplateMaxAlpha")
    nameplateMaxAlpha:SetPoint("TOP", nameplateMinAlphaDistance, "BOTTOM", 0, -17)
    CreateTooltipTwo(nameplateMaxAlpha, "Max Alpha", "The maximum alpha value of nameplates", nil, nil, "nameplateMaxAlpha")
    CreateResetButton(nameplateMaxAlpha, "nameplateMaxAlpha", guiCVarControl)

    local nameplateMaxAlphaDistance = CreateSlider(guiCVarControl, "Max Alpha Distance", 0, 60, 1, "nameplateMaxAlphaDistance")
    nameplateMaxAlphaDistance:SetPoint("TOPLEFT", nameplateMaxAlpha, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateMaxAlphaDistance, "Max Alpha Distance", "The distance from the camera that nameplates will reach their maximum alpha.", "Note: It is from the camera POV, and not player. Almost useless, I did not make this, blame Blizzard.", nil, "nameplateMaxAlphaDistance")
    CreateResetButton(nameplateMaxAlphaDistance, "nameplateMaxAlphaDistance", guiCVarControl)

    local nameplateOccludedAlphaMult = CreateSlider(guiCVarControl, "Occluded Alpha", 0, 1, 0.01, "nameplateOccludedAlphaMult")
    nameplateOccludedAlphaMult:SetPoint("TOPLEFT", nameplateMaxAlphaDistance, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOccludedAlphaMult, "Occluded Alpha", "The alpha value of nameplates that are not in line of sight.", nil, nil, "nameplateOccludedAlphaMult")
    CreateResetButton(nameplateOccludedAlphaMult, "nameplateOccludedAlphaMult", guiCVarControl)

    local nameplateSelectedAlpha = CreateSlider(guiCVarControl, "Target Alpha", 0, 1, 0.01, "nameplateSelectedAlpha")
    nameplateSelectedAlpha:SetPoint("TOPLEFT", nameplateOccludedAlphaMult, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateSelectedAlpha, "Target Alpha", "The alpha value of the nameplate you are targeting.", nil, nil, "nameplateSelectedAlpha")
    CreateResetButton(nameplateSelectedAlpha, "nameplateSelectedAlpha", guiCVarControl)

    local nameplateNotSelectedAlpha = CreateSlider(guiCVarControl, "Non-Target Alpha", 0, 1, 0.01, "nameplateNotSelectedAlpha")
    nameplateNotSelectedAlpha:SetPoint("TOPLEFT", nameplateSelectedAlpha, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateNotSelectedAlpha, "Non-Target Alpha", "The alpha value of nameplates that is not your target.", nil, nil, "nameplateNotSelectedAlpha")
    CreateResetButton(nameplateNotSelectedAlpha, "nameplateNotSelectedAlpha", guiCVarControl)

    local nameplateCVarText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateCVarText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 400, -310)
    nameplateCVarText:SetText("Nameplate Visibility CVars")

    local setCVarAcrossAllCharacters = CreateCheckbox("setCVarAcrossAllCharacters", "Force these CVars across all characters", guiCVarControl)
    setCVarAcrossAllCharacters:SetPoint("TOP", nameplateCVarText, "BOTTOM", -100, 0)
    CreateTooltipTwo(setCVarAcrossAllCharacters, "Force CVars", "By default you have to set them on each character separately.")

    local nameplateShowAll = CreateCheckbox("nameplateShowAll", "Always show nameplates (if not targeted)", guiCVarControl, true)
    nameplateShowAll:SetPoint("TOP", setCVarAcrossAllCharacters, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowAll, "Always show nameplates", "Always show nameplates (if not targeted)", nil, nil, "nameplateShowAll")

    local nameplateShowEnemyMinions = CreateCheckbox("nameplateShowEnemyMinions", "Show Enemy Minions", guiCVarControl, true)
    nameplateShowEnemyMinions:SetPoint("TOP", nameplateCVarText, "BOTTOM", -127, -40)
    CreateTooltipTwo(nameplateShowEnemyMinions, "Show Enemy Minion Nameplates", "Minions are stuff like extra BM hunter pets but Observer is also a minion", nil, nil, "nameplateShowEnemyMinions")

    local nameplateShowEnemyGuardians = CreateCheckbox("nameplateShowEnemyGuardians", "Show Enemy Guardians", guiCVarControl, true)
    nameplateShowEnemyGuardians:SetPoint("TOP", nameplateShowEnemyMinions, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowEnemyGuardians, "Show Enemy Guardian Nameplates", "Guardians are usually \"semi controllable\" larger summoned pets, like Earth Elemental/Infernal.", nil, nil, "nameplateShowEnemyGuardians")

    local nameplateShowEnemyMinus = CreateCheckbox("nameplateShowEnemyMinus", "Show Enemy Minus", guiCVarControl, true)
    nameplateShowEnemyMinus:SetPoint("TOP", nameplateShowEnemyGuardians, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowEnemyMinus, "Show Enemy Minus Nameplates", "Minus are usually uncontrollable very small summoned pets with little hp, like Warlock Imps.", nil, nil, "nameplateShowEnemyMinus")

    local nameplateShowEnemyPets = CreateCheckbox("nameplateShowEnemyPets", "Show Enemy Pets", guiCVarControl, true)
    nameplateShowEnemyPets:SetPoint("TOP", nameplateShowEnemyMinus, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowEnemyPets, "Show Enemy Pets Nameplates", "Pets are the main controllable pets like Hunter Pet, Warlock Pet etc.", nil, nil, "nameplateShowEnemyPets")

    local nameplateShowEnemyTotems = CreateCheckbox("nameplateShowEnemyTotems", "Show Enemy Totems", guiCVarControl, true)
    nameplateShowEnemyTotems:SetPoint("TOP", nameplateShowEnemyPets, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowEnemyTotems, "Show Enemy Totem Nameplates", "Totems are totems.. and Psyfiend", nil, nil, "nameplateShowEnemyTotems")

    local nameplateShowFriendlyMinions = CreateCheckbox("nameplateShowFriendlyMinions", "Show Friendly Minions", guiCVarControl, true)
    nameplateShowFriendlyMinions:SetPoint("TOP", nameplateCVarText, "BOTTOM", 25, -40)
    CreateTooltipTwo(nameplateShowFriendlyMinions, "Show Friendly Minion Nameplates", "Minions are stuff like extra BM hunter pets but Observer is also a minion", nil, nil, "nameplateShowFriendlyMinions")

    local nameplateShowFriendlyGuardians = CreateCheckbox("nameplateShowFriendlyGuardians", "Show Friendly Guardians", guiCVarControl, true)
    nameplateShowFriendlyGuardians:SetPoint("TOP", nameplateShowFriendlyMinions, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyGuardians, "Show Friendly Guardian Nameplates", "Guardians are usually \"semi controllable\" larger summoned pets, like Earth Elemental/Infernal.", nil, nil, "nameplateShowFriendlyGuardians")

    local nameplateShowFriendlyNPCs = CreateCheckbox("nameplateShowFriendlyNPCs", "Show Friendly NPCs", guiCVarControl, true)
    nameplateShowFriendlyNPCs:SetPoint("TOP", nameplateShowFriendlyGuardians, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyNPCs, "Show Friendly NPC Nameplates", "Always show friendly NPC nameplates", nil, nil, "nameplateShowFriendlyNPCs")

    local nameplateShowFriendlyPets = CreateCheckbox("nameplateShowFriendlyPets", "Show Friendly Pets", guiCVarControl, true)
    nameplateShowFriendlyPets:SetPoint("TOP", nameplateShowFriendlyNPCs, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyPets, "Show Friendly Pets Nameplates", "Pets are the main controllable pets like Hunter Pet, Warlock Pet etc.", nil, nil, "nameplateShowFriendlyPets")

    local nameplateShowFriendlyTotems = CreateCheckbox("nameplateShowFriendlyTotems", "Show Friendly Totems", guiCVarControl, true)
    nameplateShowFriendlyTotems:SetPoint("TOP", nameplateShowFriendlyPets, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyTotems, "Show Friendly Totem Nameplates", "Totems are totem... and Psyfiend", nil, nil, "nameplateShowFriendlyTotems")

    local function ChangeCVarCheckboxBehaviour(checkbox, cvarName, changeDB)
        checkbox:SetScript("OnClick", function(self)
            local value = self:GetChecked() and "1" or "0"
            if changeDB then
                BetterBlizzPlatesDB[cvarName] = value
            end
            BBP.RunAfterCombat(function()
                C_CVar.SetCVar(cvarName, value)
                if cvarName == "nameplateShowEnemyMinions" then
                    if changeDB then
                        C_CVar.SetCVar("nameplateShowEnemyGuardians", BetterBlizzPlatesDB.nameplateShowEnemyGuardians)
                        C_CVar.SetCVar("nameplateShowEnemyTotems", BetterBlizzPlatesDB.nameplateShowEnemyTotems)
                        C_CVar.SetCVar("nameplateShowEnemyMinus", BetterBlizzPlatesDB.nameplateShowEnemyMinus)
                        C_CVar.SetCVar("nameplateShowEnemyPets", BetterBlizzPlatesDB.nameplateShowEnemyPets)
                    end
                elseif cvarName == "nameplateShowFriendlyMinions" then
                    if changeDB then
                        C_CVar.SetCVar("nameplateShowFriendlyGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyGuardians)
                        C_CVar.SetCVar("nameplateShowFriendlyTotems", BetterBlizzPlatesDB.nameplateShowFriendlyTotems)
                        C_CVar.SetCVar("nameplateShowFriendlyPets", BetterBlizzPlatesDB.nameplateShowFriendlyPets)
                    end
                end
            end)
        end)
    end

    local function ChangeMinionCheckboxes(changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowEnemyMinions, "nameplateShowEnemyMinions", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowEnemyGuardians, "nameplateShowEnemyGuardians", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowEnemyMinus, "nameplateShowEnemyMinus", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowEnemyPets, "nameplateShowEnemyPets", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowEnemyTotems, "nameplateShowEnemyTotems", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyMinions, "nameplateShowFriendlyMinions", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyGuardians, "nameplateShowFriendlyGuardians", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyPets, "nameplateShowFriendlyPets", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyTotems, "nameplateShowFriendlyTotems", changeDB)

        if changeDB then
            nameplateShowEnemyMinions:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyMinions"]=="1")
            nameplateShowEnemyGuardians:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyGuardians"]=="1")
            nameplateShowEnemyMinus:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyMinus"]=="1")
            nameplateShowEnemyPets:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyPets"]=="1")
            nameplateShowEnemyTotems:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyTotems"]=="1")
            nameplateShowFriendlyMinions:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyMinions"]=="1")
            nameplateShowFriendlyGuardians:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyGuardians"]=="1")
            nameplateShowFriendlyPets:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyPets"]=="1")
            nameplateShowFriendlyTotems:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyTotems"]=="1")
        else
            nameplateShowEnemyMinions:SetChecked(GetCVar("nameplateShowEnemyMinions")=="1")
            nameplateShowEnemyGuardians:SetChecked(GetCVar("nameplateShowEnemyGuardians")=="1")
            nameplateShowEnemyMinus:SetChecked(GetCVar("nameplateShowEnemyMinus")=="1")
            nameplateShowEnemyPets:SetChecked(GetCVar("nameplateShowEnemyPets")=="1")
            nameplateShowEnemyTotems:SetChecked(GetCVar("nameplateShowEnemyTotems")=="1")
            nameplateShowFriendlyMinions:SetChecked(GetCVar("nameplateShowFriendlyMinions")=="1")
            nameplateShowFriendlyGuardians:SetChecked(GetCVar("nameplateShowFriendlyGuardians")=="1")
            nameplateShowFriendlyPets:SetChecked(GetCVar("nameplateShowFriendlyPets")=="1")
            nameplateShowFriendlyTotems:SetChecked(GetCVar("nameplateShowFriendlyTotems")=="1")
        end
    end


    setCVarAcrossAllCharacters:HookScript("OnClick", function(self)
        if self:GetChecked() then
            ChangeMinionCheckboxes(true)
        else
            ChangeMinionCheckboxes(false)
        end
    end)

    local cbCVars = {}
    cbCVars["nameplateShowEnemyMinions"] = nameplateShowEnemyMinions
    cbCVars["nameplateShowEnemyGuardians"] = nameplateShowEnemyGuardians
    cbCVars["nameplateShowEnemyMinus"] = nameplateShowEnemyMinus
    cbCVars["nameplateShowEnemyPets"] = nameplateShowEnemyPets
    cbCVars["nameplateShowEnemyTotems"] = nameplateShowEnemyTotems
    cbCVars["nameplateShowFriendlyMinions"] = nameplateShowFriendlyMinions
    cbCVars["nameplateShowFriendlyGuardians"] = nameplateShowFriendlyGuardians
    cbCVars["nameplateShowFriendlyPets"] = nameplateShowFriendlyPets
    cbCVars["nameplateShowFriendlyTotems"] = nameplateShowFriendlyTotems
    cbCVars["nameplateResourceOnTarget"] = nameplateResourceOnTarget
    cbCVars["nameplateMotion"] = nameplateMotion

    local sliderCVars = {}
    sliderCVars["nameplateOverlapH"] = nameplateOverlapH
    sliderCVars["nameplateOverlapV"] = nameplateOverlapV
    sliderCVars["nameplateMotionSpeed"] = nameplateMotionSpeed
    sliderCVars["nameplateMinAlpha"] = nameplateMinAlpha
    sliderCVars["nameplateMinAlphaDistance"] = nameplateMinAlphaDistance
    sliderCVars["nameplateMaxAlpha"] = nameplateMaxAlpha
    sliderCVars["nameplateMaxAlphaDistance"] = nameplateMaxAlphaDistance
    sliderCVars["nameplateOccludedAlphaMult"] = nameplateOccludedAlphaMult
    sliderCVars["nameplateSelectedAlpha"] = nameplateSelectedAlpha
    sliderCVars["nameplateNotSelectedAlpha"] = nameplateNotSelectedAlpha

    -- Re-check checkboxes late cuz its all a mess and needs to be done and at this point more bandaid is all the effort i will put in until TWW maybe
    if not BetterBlizzPlatesDB.hasSaved then
        C_Timer.After(3, function()
            if BetterBlizzPlatesDB.setCVarAcrossAllCharacters then
                ChangeMinionCheckboxes(true)
            else
                ChangeMinionCheckboxes(false)
            end
            -- local children = {guiCVarControl:GetChildren()}
            -- for _, child in ipairs(children) do
            --     if child:IsObjectType("CheckButton") and child.option then
            --         LateUpdateCheckboxState(child, child.option)
            --     end
            -- end
        end)
    end

    C_Timer.After(0.5, function()
        local cvarListener = CreateFrame("Frame")
        cvarListener:RegisterEvent("CVAR_UPDATE")
        cvarListener:SetScript("OnEvent", function(self, event, cvarName, cvarValue)
            if BBP.CVarTrackingDisabled then return end
            if (BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater")) then return end
            local checkedState = cvarValue == "1" or false
            if cvarValue then
                if cbCVars[cvarName] then
                    --BetterBlizzPlatesDB[cvarName] = cvarValue
                    cbCVars[cvarName]:SetChecked(checkedState)
                elseif sliderCVars[cvarName] then
                    --BetterBlizzPlatesDB[cvarName] = tonumber(cvarValue)
                    sliderCVars[cvarName]:SetValue(tonumber(cvarValue))
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
    guiTotemList.name = "Totem Indicator List"
    guiTotemList.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiTotemList)
    local guiTotemListCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiTotemList, guiTotemList.name, guiTotemList.name)
    CreateTitle(guiTotemList)

    local bgImg = guiTotemList:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiTotemList, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiTotemList)
    listFrame:SetAllPoints(guiTotemList)

    local totemListFrame = CreateFrame("Frame", nil, listFrame)
    totemListFrame:SetSize(322, 390)
    totemListFrame:SetPoint("TOPLEFT", -5, 3)

    -- local totemListTip = guiTotemList:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- totemListTip:SetPoint("TOP", guiTotemList, "TOP", 0, 8)
    -- totemListTip:SetText("(Adjust general size of ALL icons in the Advanced Settings tab)")

    local totemList = CreateNpcList(totemListFrame, BetterBlizzPlatesDB.totemIndicatorNpcList, BBP.RefreshAllNameplates, 660, 490)

    local totemIndicatorScale = CreateSlider(guiTotemList, "General scale of all totem icons", 0.5, 3, 0.01, "totemIndicatorScale")
    totemIndicatorScale:SetPoint("TOP", totemList, "BOTTOM", 0, -45)
    totemIndicatorScale:HookScript("OnValueChanged", function(self)
        local val = self:GetValue()
        BBP.totemIndicatorScale:SetValue(val)
    end)
    totemIndicatorScale:SetScale(1.2)

    local totemIndicatorUseNicknames = CreateCheckbox("totemIndicatorUseNicknames", "Use Nicknames", listFrame)
    totemIndicatorUseNicknames:SetPoint("LEFT", totemIndicatorScale, "RIGHT", 25, 2)
    CreateTooltipTwo(totemIndicatorUseNicknames,"Use Nicknames", "The nameplates will show the name you enter in the list instead of their original name.")
    totemIndicatorUseNicknames:SetScale(1.1)

    local resetTotemListButton = CreateFrame("Button", nil, guiTotemList, "UIPanelButtonTemplate")
    resetTotemListButton:SetText("Reset Totem List")
    resetTotemListButton:SetWidth(120)
    resetTotemListButton:SetPoint("BOTTOMLEFT", guiTotemList, "BOTTOMLEFT", 10, 20)
    resetTotemListButton:SetScript("OnClick", function()
        StaticPopup_Show("BBP_TOTEMLIST_RESET")
    end)
    CreateTooltipTwo(resetTotemListButton, "Reset Totem List", "Reset totem list back to its default state", nil, "ANCHOR_TOP")
end

local function guiMisc()
    local guiMisc = CreateFrame("Frame")
    guiMisc.name = "Misc"--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiMisc.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiMisc)
    local guiMiscCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiMisc, guiMisc.name, guiMisc.name)
    CreateTitle(guiMisc)

    local bgImg = guiMisc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiMisc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local settingsText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 20, -10)
    settingsText:SetText("Misc settings")
    local miscSettingsIcon = guiMisc:CreateTexture(nil, "ARTWORK")
    miscSettingsIcon:SetAtlas("optionsicon-brown")
    miscSettingsIcon:SetSize(22, 22)
    miscSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local showGuildNames = CreateCheckbox("showGuildNames", "Show Guild Names on Friendly Nameplates", guiMisc)
    showGuildNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    --CreateTooltip(showGuildNames, "*Only works when \"Hide healthbar\" setting on friendly nameplates is on.\n\n(Will add some extra settings for this soon,\ndisable in arena/bg etc,\nplease shoot me a message if you have other suggestions too)")

    local guildNameScale = CreateSlider(guiMisc, "Guild Name Size", 0.2, 2, 0.01, "guildNameScale")
    guildNameScale:SetPoint("LEFT", showGuildNames.Text, "RIGHT", 5, 0)

    local guildNameColor = CreateCheckbox("guildNameColor", "Custom Guild Name Color", guiMisc)
    guildNameColor:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(guildNameColor, "Change guild name color to a custom one instead of class colors.")

    local function OpenColorPicker()
        local r, g, b = unpack(BetterBlizzPlatesDB.guildNameColorRGB or {1, 1, 1})

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.guildNameColorRGB = { r, g, b }
                BBP.RefreshAllNameplates()
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.guildNameColorRGB = { r, g, b }
                BBP.RefreshAllNameplates()
            end,
        })
    end

    local guildNameColorButton = CreateFrame("Button", nil, guiMisc, "UIPanelButtonTemplate")
    guildNameColorButton:SetText("Color")
    guildNameColorButton:SetPoint("LEFT", guildNameColor.text, "RIGHT", -1, 0)
    guildNameColorButton:SetSize(45, 20)
    guildNameColorButton:SetScript("OnClick", OpenColorPicker)

    local showNpcTitle = CreateCheckbox("showNpcTitle", "Show NPC Titles on Friendly NPCs", guiMisc)
    showNpcTitle:SetPoint("TOPLEFT", guildNameColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showNpcTitle, "Show NPC Titles under name/healthbar. (\"Innkeeper\" etc.)")

    local npcTitleScale = CreateSlider(guiMisc, "NPC Title Size", 0.2, 2, 0.01, "npcTitleScale")
    npcTitleScale:SetPoint("LEFT", showNpcTitle.Text, "RIGHT", 25, 0)

    local npcTitleColor = CreateCheckbox("npcTitleColor", "Custom NPC Title Color", guiMisc)
    npcTitleColor:SetPoint("TOPLEFT", showNpcTitle, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(npcTitleColor, "Change the NPC Title Color.")

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
    npcTitleColorButton:SetText("Color")
    npcTitleColorButton:SetPoint("LEFT", npcTitleColor.text, "RIGHT", -1, 0)
    npcTitleColorButton:SetSize(45, 20)
    npcTitleColorButton:SetScript("OnClick", OpenColorPicker)

    local friendIndicator = CreateCheckbox("friendIndicator", "Friend/Guildie Indicator", guiMisc)
    friendIndicator:SetPoint("TOPLEFT", npcTitleColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendIndicator, "Places a little icon to the left of a friend/guildies name")

    local anonMode = CreateCheckbox("anonMode", "Anon Mode", guiMisc)
    anonMode:SetPoint("TOPLEFT", friendIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anonMode, "Changes the names of players to their class instead.\nWill be overwritten by Arena Names module during arenas.")

    local skipAdjustingFixedFonts = CreateCheckbox("skipAdjustingFixedFonts", "Skip adjusting nameplate fonts", guiMisc)
    skipAdjustingFixedFonts:SetPoint("TOPLEFT", anonMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(skipAdjustingFixedFonts, "Skip adjusting nameplate fonts", "1080p can cause name scaling issues and this setting will fix it.\nIt will however also make you unable to change fonts with this addon\n(you can do it manually in game files still).", "NOTE: Still don't fully understand Blizzards code and how this nameplate font thing works\nso check this at own risk and report to me if it's not working as expected.")
    skipAdjustingFixedFonts:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local toggleNamesOffDuringPVE = CreateCheckbox("toggleNamesOffDuringPVE", "Toggle Friendly Player Name", guiMisc)
    toggleNamesOffDuringPVE:SetPoint("TOPLEFT", skipAdjustingFixedFonts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(toggleNamesOffDuringPVE, "Toggle friendly player names (on nameplate) off\nduring PvE content and back on again outside.")

    local doNotHideFriendlyHealthbarInPve = CreateCheckbox("doNotHideFriendlyHealthbarInPve", "Don't hide friendly healthbars in PvE", guiMisc)
    doNotHideFriendlyHealthbarInPve:SetPoint("TOPLEFT", toggleNamesOffDuringPVE, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(doNotHideFriendlyHealthbarInPve, "Don't Hide Friendly Healthbar", "Prevents hiding friendly healthbars in PvE if \"Hide healthbar\" is checked in General settings.")

    local showLastNameNpc = CreateCheckbox("showLastNameNpc", "Only show last name of NPCs", guiMisc)
    showLastNameNpc:SetPoint("TOPLEFT", doNotHideFriendlyHealthbarInPve, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showLastNameNpc, "Only show last name of NPCs", "Hides the first names/words of npc names and only shows the last part.")

    -- local nameplateResourceText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- nameplateResourceText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 45, -250)
    -- nameplateResourceText:SetText("Nameplate Resource")

    -- local nameplateSelfWidth = CreateSlider(guiMisc, "Personal Nameplate Width", 50, 200, 1, "nameplateSelfWidth")
    -- nameplateSelfWidth:SetPoint("TOPLEFT", doNotHideFriendlyHealthbarInPve, "BOTTOMLEFT", 10, -20)





    local changeHealthbarHeight = CreateCheckbox("changeHealthbarHeight", "Separate Friendly/Enemy Nameplate Height", guiMisc)
    changeHealthbarHeight:SetPoint("TOPLEFT", doNotHideFriendlyHealthbarInPve, "BOTTOMLEFT", 0, -50)
    CreateTooltipTwo(changeHealthbarHeight, "Separate Nameplate Heights", "Change the height of nameplates individually depending if enemy or friendly.", "This setting runs a lot and I am unsure just how much of a performance impact it has. Use at own risk.")


    local hpHeightEnemy = CreateSlider(changeHealthbarHeight, "Enemy Height", 1, 35, 0.1, "hpHeightEnemy")
    hpHeightEnemy:SetPoint("TOPLEFT", changeHealthbarHeight, "BOTTOMLEFT", 10, -10)
    CreateTooltipTwo(hpHeightEnemy, "Enemy Height", "Change the height for enemy nameplates.")
    local hpHeightEnemyReset = CreateResetButton(hpHeightEnemy, "hpHeightEnemy", guiMisc)
    CreateTooltipTwo(hpHeightEnemyReset, "Reset to default", "Default is 4 * NamePlateVerticalScale")

    local hpHeightFriendly = CreateSlider(changeHealthbarHeight, "Friendly Height", 1, 35, 0.1, "hpHeightFriendly")
    hpHeightFriendly:SetPoint("TOPLEFT", hpHeightEnemy, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(hpHeightFriendly, "Friendly Height", "The height for friendly nameplates.")
    local hpHeightFriendlyReset = CreateResetButton(hpHeightFriendly, "hpHeightFriendly", guiMisc)
    CreateTooltipTwo(hpHeightFriendlyReset, "Reset to default", "Default is 4 * NamePlateVerticalScale")

    changeHealthbarHeight:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.HookHealthbarHeight()
            EnableElement(hpHeightEnemy)
            EnableElement(hpHeightFriendly)
        else
            DisableElement(hpHeightEnemy)
            DisableElement(hpHeightFriendly)
            --StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local nameplateGeneralHeight = CreateSlider(guiMisc, "Clickable Height", 1, 70, 1, "nameplateGeneralHeight")
    nameplateGeneralHeight:SetPoint("TOPLEFT", hpHeightFriendly, "BOTTOMLEFT", 0, -37)
    CreateTooltipTwo(nameplateGeneralHeight, "Clickable Height", "Adjust the clickable area of nameplates.")


    local customFontSizeEnabled = CreateCheckbox("customFontSizeEnabled", "Enable Custom Nameplate Font Size", guiMisc)
    customFontSizeEnabled:SetPoint("TOPLEFT", changeHealthbarHeight, "BOTTOMLEFT", 0, -120)
    CreateTooltipTwo(customFontSizeEnabled, "Custom Nameplate Font Size", "Change the font size on nameplates", "This setting will work in PvE for friendly name size while the font size settings on the general page adjust the scale (not allowed in PvE).\nUse this setting as a baseline for friendly name size and finetune with scale on general page for non-pve content.")

    local customFontSize = CreateSlider(customFontSizeEnabled, "Font Size", 2, 32, 1, "customFontSize")
    customFontSize:SetPoint("TOPLEFT", customFontSizeEnabled, "BOTTOMLEFT", 10, -10)

    customFontSizeEnabled:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(customFontSize)
        else
            DisableElement(customFontSize)
        end
    end)

    local nameplateGeneralHeightReset = CreateResetButton(nameplateGeneralHeight, "nameplateGeneralHeight", guiMisc)
    CreateTooltipTwo(nameplateGeneralHeightReset, "Reset to default", "Default is 32")

    local changeNameplateBorderSize = CreateCheckbox("changeNameplateBorderSize", "Change Nameplate Border Size", guiMisc)
    changeNameplateBorderSize:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 340, -50)
    local nameplateBorderSize = CreateSlider(changeNameplateBorderSize, "Nameplate Border Size", 1, 10, 0.5, "nameplateBorderSize")
    nameplateBorderSize:SetPoint("TOPLEFT", changeNameplateBorderSize, "BOTTOMLEFT", 10, -10)
    local nameplateTargetBorderSize = CreateSlider(changeNameplateBorderSize, "Target Border Size", 1, 10, 0.5, "nameplateTargetBorderSize")
    nameplateTargetBorderSize:SetPoint("LEFT", nameplateBorderSize, "RIGHT", 10, 0)
    CreateTooltipTwo(nameplateBorderSize, "Nameplate Border Size", "The size of nameplate borders.")
    changeNameplateBorderSize:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(nameplateBorderSize)
            EnableElement(nameplateTargetBorderSize)
        else
            DisableElement(nameplateBorderSize)
            DisableElement(nameplateTargetBorderSize)
            --StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)


    local changeNameplateBorderColor = CreateCheckbox("changeNameplateBorderColor", "Change Nameplate Border Color", guiMisc)
    changeNameplateBorderColor:SetPoint("TOPLEFT", nameplateBorderSize, "BOTTOMLEFT", -10, -4)

    local npBorderDesaturate = CreateCheckbox("npBorderDesaturate", "Desaturate", guiMisc)
    npBorderDesaturate:SetPoint("LEFT", changeNameplateBorderColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(npBorderDesaturate, "Desaturate Border", "Desaturate/Grayscale the Classic Border.")
    npBorderDesaturate:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local npBorderTargetColor = CreateCheckbox("npBorderTargetColor", "Target Border", changeNameplateBorderColor)
    npBorderTargetColor:SetPoint("TOPLEFT", changeNameplateBorderColor, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(npBorderTargetColor, "Enable to change the color of the target nameplate border")

    local npBorderTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderTargetColorRGB", "Target Border")
    npBorderTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColor, "BOTTOMLEFT", 15, 0)

    local npBorderNonTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderNonTargetColorRGB", "Non-Target Border")
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

    local npBorderFriendFoeColor = CreateCheckbox("npBorderFriendFoeColor", "Reaction Color Border", changeNameplateBorderColor)
    npBorderFriendFoeColor:SetPoint("TOPLEFT", npBorderNonTargetColorRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltip(npBorderFriendFoeColor, "Enable to change the color of nameplate borders depending on their reaction")

    local npBorderEnemyColorRGB = CreateColorBox(npBorderFriendFoeColor, "npBorderEnemyColorRGB", "Enemy Border")
    npBorderEnemyColorRGB:SetPoint("TOPLEFT", npBorderFriendFoeColor, "BOTTOMLEFT", 15, 0)

    local npBorderFriendlyColorRGB = CreateColorBox(npBorderFriendFoeColor, "npBorderFriendlyColorRGB", "Friendly Border")
    npBorderFriendlyColorRGB:SetPoint("TOPLEFT", npBorderEnemyColorRGB, "BOTTOMLEFT", 0, -2)

    local npBorderNeutralColorRGB = CreateColorBox(npBorderFriendFoeColor, "npBorderNeutralColorRGB", "Neutral Border")
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

    local npBorderClassColor = CreateCheckbox("npBorderClassColor", "Class Color Border", changeNameplateBorderColor)
    npBorderClassColor:SetPoint("TOPLEFT", npBorderNeutralColorRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltip(npBorderClassColor, "Enable to change the color of nameplate borders depending on their class")

    local npBorderNpcColorRGB = CreateColorBox(npBorderClassColor, "npBorderNpcColorRGB", "NPC Border")
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

    local changeNpHpBgColor = CreateCheckbox("changeNpHpBgColor", "Change Nameplate Background Color", guiMisc)
    changeNpHpBgColor:SetPoint("TOPLEFT", npBorderNpcColorRGB, "BOTTOMLEFT", -15, 0)
    CreateTooltipTwo(changeNpHpBgColor, "Nameplate Background Color", "Change the nameplate background color.")

    local npBgColorRGB = CreateColorBox(changeNpHpBgColor, "npBgColorRGB", "Background Color")
    npBgColorRGB:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 15, 0)

    local changeNpHpBgColorSolid = CreateCheckbox("changeNpHpBgColorSolid", "Solid", guiMisc)
    changeNpHpBgColorSolid:SetPoint("LEFT", npBgColorRGB.text, "RIGHT", 2, 0)
    CreateTooltipTwo(changeNpHpBgColorSolid, "Solid Background Color", "Make the nameplate background color solid and non-transparent.")

    changeNpHpBgColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBgColorRGB:SetAlpha(1)
        else
            npBgColorRGB:SetAlpha(0.5)
        end
    end)


    local enableNpVerticalPos = CreateCheckbox("enableNpVerticalPos", "Change Nameplate Vertical Position", guiMisc)
    enableNpVerticalPos:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 0, -30)
    CreateTooltipTwo(enableNpVerticalPos, "Change Nameplate Vertical Position", "Change the vertical position of nameplates.\n\nThis will only move the visual elements and not the clickable area due to restrictions.")

    local nameplateVerticalPosition = CreateSlider(enableNpVerticalPos, "Nameplate Vertical Position", -60, 60, 1, "nameplateVerticalPosition", "Y")
    nameplateVerticalPosition:SetPoint("TOPLEFT", enableNpVerticalPos, "BOTTOMLEFT", 10, -10)

    enableNpVerticalPos:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(nameplateVerticalPosition)
        else
            DisableElement(nameplateVerticalPosition)
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local nameplateExtraClickHeight = CreateSlider(guiMisc, "Nameplate Extra Clickable Height", -40, 60, 1, "nameplateExtraClickHeight", "Y")
    nameplateExtraClickHeight:SetPoint("TOPLEFT", nameplateVerticalPosition, "BOTTOMLEFT", 0, -16)


    -- local nameplateSelfWidthResetButton = CreateFrame("Button", nil, guiMisc, "UIPanelButtonTemplate")
    -- nameplateSelfWidthResetButton:SetText("Default")
    -- nameplateSelfWidthResetButton:SetWidth(60)
    -- nameplateSelfWidthResetButton:SetPoint("LEFT", nameplateSelfWidth, "RIGHT", 10, 0)
    -- nameplateSelfWidthResetButton:SetScript("OnClick", function()
    --     BBP.ResetToDefaultWidth(nameplateSelfWidth, false)
    -- end)
end

local function guiSupport()
    local guiSupport = CreateFrame("Frame")
    guiSupport.name = "|A:GarrisonTroops-Health:10:10|a Support"
    guiSupport.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiSupport)
    local guiSupportCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiSupport, guiSupport.name, guiSupport.name)
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
    discordText:SetText("Join the Discord for info\nand help with BBP/BBF")

    local joinDiscord = guiSupport:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local supportText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportText:SetPoint("TOP", guiSupport, "TOP", 0, -230)
    supportText:SetText("If you wish to support me and my projects\nit would be greatly appreciated |A:GarrisonTroops-Health:10:10|a")

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

local function guiMidnight()
    local guiMidnight = CreateFrame("Frame")
    guiMidnight.name = "|T136221:12:12|t |cffcc66ffWoW: Midnight|r"
    guiMidnight.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiMidnight)
    local guiMidnightCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiMidnight, guiMidnight.name, guiMidnight.name)
    BBP.guiMidnight = guiMidnight.name
    BBP.category.guiMidnightCategory = guiMidnightCategory.ID
    CreateTitle(guiMidnight)

    local titleText = guiMidnight:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    titleText:SetPoint("TOPLEFT", guiMidnight, "TOPLEFT", 20, -10)
    titleText:SetText("|cffcc66ffWorld of Warcraft: Midnight Plans|r")
    local titleIcon = guiMidnight:CreateTexture(nil, "ARTWORK")
    titleIcon:SetTexture(136221)
    titleIcon:SetSize(23, 23)
    titleIcon:SetPoint("RIGHT", titleText, "LEFT", -3, 0.5)

    local nf = CreateFrame("Frame", nil, guiMidnight)
    nf:SetFrameStrata("HIGH")

    local midnightInfo = nf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    midnightInfo:SetPoint("TOPLEFT", titleIcon, "BOTTOMLEFT", 2, -5)
    midnightInfo:SetText("|cff00ff00UPDATE: All now available on Midnight.|r |cffffffffEarly versions and work in progress.\n\nI'm planning to continue developing all my addons for Midnight as well.\n\nSome features will need to be adjusted or removed but the addons should stick around.\nMidnight is still in early Alpha and I haven't started preparing yet (14th Oct), but I will soon.\n\nPlans might change, but I'm confident |A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates and my other addons\n|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames & |cffffffffsArena |cffff8000Reloaded|r |T135884:13:13|t will stick around for Midnight (with changes/removals).\n\nI have a lot of work ahead of me and any support is greatly appreciated |A:GarrisonTroops-Health:10:10|a (|cff00c0ff@bodify|r)\nI'll update this section with more detailed information as I know more in some weeks/months.")
    midnightInfo:SetTextColor(1,1,1,1)
    midnightInfo:SetJustifyH("LEFT")

    local bgImg = guiMidnight:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiMidnight, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local f = CreateFrame("PlayerModel", nil, guiMidnight)
    f:SetIgnoreParentScale(true)
    f:SetScale(1)
    f:SetAllPoints(bgImg)
    f:SetPortraitZoom(0)
    f:SetDisplayInfo(18955)
    f:SetFrameStrata("MEDIUM")
    f.anim = 69
    f:SetAnimation(69)
    f:HookScript("OnAnimFinished", function(self)
        if self.anim == 3 or self.anim == 15 then return end
        self:SetAnimation(self.anim)
    end)

    local DEFAULT_CAM     = 1.55
    local DEFAULT_VTX     = -15
    local DEFAULT_VTY     = -60

    local validAnimations = {}
    for i = 1, 84 do
        if i ~= 7 and i ~= 11 and i ~= 12 and i ~= 40 and i ~= 56 then
            table.insert(validAnimations, i)
        end
    end
    local extras = { 102, 103, 105, 106, 107, 108, 109, 110, 111, 112, 113, 144, 164, 185, 186, 195, 196, 225 }
    for _, v in ipairs(extras) do
        table.insert(validAnimations, v)
    end

    local pool = {}
    local function RefillPool()
        wipe(pool)
        for i = 1, #validAnimations do
            pool[i] = validAnimations[i]
        end
        for i = #pool, 2, -1 do
            local j = math.random(i)
            pool[i], pool[j] = pool[j], pool[i]
        end
    end
    RefillPool()

    local function PlayRandomAnimation()
        if #pool == 0 then
            RefillPool()
        end
        local anim = table.remove(pool)
        f.anim = anim
        f:SetAnimation(anim)
    end

    local poke = CreateFrame("Button", nil, guiMidnight, "UIPanelButtonTemplate")
    poke:SetText("Poke")
    poke:SetWidth(50)
    poke:SetPoint("LEFT", f, "LEFT", 65, -55)
    poke:SetScale(1.5)
    poke:SetFrameStrata("HIGH")
    poke:SetScript("OnClick", PlayRandomAnimation)
    poke.Text:SetVertexColor(1, 1, 1)


    local r, g, b = 0.945, 0.769, 1.0
    for _, region in ipairs({ poke:GetRegions() }) do
        if region:IsObjectType("Texture") then
            region:SetDesaturated(true)
            region:SetVertexColor(r, g, b)
        end
    end

    local ROT_SENS   = 0.010 * 0.8
    local PITCH_SENS = 0.010 * 0.8
    local DOLLY_SENS = 0.015 * 0.35
    local WHEEL_PAN  = 0.34

    f:EnableMouse(true)
    f:EnableMouseWheel(true)
    f:UseModelCenterToTransform(true)

    local camScale = DEFAULT_CAM
    f:SetCamDistanceScale(camScale)

    local startX, startY, startYaw, startPitch, startPX, startPY, startPZ
    local dragMode

    local function Cur()
        local x, y = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        return x / s, y / s
    end

    f:SetScript("OnMouseDown", function(self, button)
        startX, startY            = Cur()
        startYaw                  = self:GetFacing() or 0
        startPitch                = self:GetPitch() or 0
        startPX, startPY, startPZ = self:GetPosition()
        if button == "LeftButton" then
            dragMode = "lmb"
        elseif button == "RightButton" then
            dragMode = "rmb"
        elseif button == "MiddleButton" then
            camScale = DEFAULT_CAM
            self:SetCamDistanceScale(camScale)
            self:SetFacing(0)
            self:SetPitch(0)
            self:SetPosition(0, 0, 0)
            self:SetViewTranslation(DEFAULT_VTX, DEFAULT_VTY)
            return
        end
        self:EnableMouseMotion(true)
    end)

    f:SetScript("OnMouseUp", function(self)
        self:EnableMouseMotion(false)
        dragMode = nil
    end)

    f:SetScript("OnHide", function(self)
        self:EnableMouseMotion(false)
        dragMode = nil
    end)

    f:SetScript("OnMouseWheel", function(self, delta)
        local px, py, pz = self:GetPosition()
        self:SetPosition(px + delta * WHEEL_PAN, py, pz)
    end)

    f:SetScript("OnUpdate", function(self)
        if not dragMode then return end
        local x, y = Cur()
        local dx, dy = x - startX, y - startY
        if dragMode == "lmb" then
            self:SetFacing(startYaw + dx * ROT_SENS)
            self:SetPitch(startPitch - dy * PITCH_SENS)
        elseif dragMode == "rmb" then
            self:SetPosition(startPX, startPY + dx * DOLLY_SENS, startPZ + dy * DOLLY_SENS)
        end
    end)

    local function ResetView()
        camScale = DEFAULT_CAM
        f:RefreshCamera()
        f:ZeroCachedCenterXY()
        f:UseModelCenterToTransform(true)
        f:SetPortraitZoom(0)
        f:SetFacing(0)
        f:SetPitch(0)
        f:SetRoll(0)
        f:SetPosition(0, 0, 0)
        f:SetCamDistanceScale(camScale)
        f:SetViewTranslation(DEFAULT_VTX, DEFAULT_VTY)
    end
    ResetView()

    guiMidnight:HookScript("OnShow", function()
        ResetView()
    end)
end

local function guiImportAndExport()
    local guiImportAndExport = CreateFrame("Frame")
    guiImportAndExport.name = "Import & Export"--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiImportAndExport.parent = BetterBlizzPlates.name
    --InterfaceOptions_AddCategory(guiImportAndExport)
    local guiImportAndExportCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiImportAndExport, guiImportAndExport.name, guiImportAndExport.name)
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
    profilesBtn:SetText("PROFILES SELECTION")
    profilesBtn:SetPoint("TOP", text, "BOTTOM", 0, -25)
    profilesBtn:SetScale(1.3)
    profilesBtn:SetNormalFontObject("GameFontNormal")
    profilesBtn:SetHighlightFontObject("GameFontHighlight")
    profilesBtn:SetScript("OnClick", function()
        BBP.CreateIntroMessageWindow()
    end)
    CreateTooltipTwo(profilesBtn, "Profiles", "Check out the included profiles. Selecting one will delete all your current settings and apply the profile.", nil, "ANCHOR_TOP")

    local fullProfile = CreateImportExportUI(guiImportAndExport, "Full Profile", BetterBlizzPlatesDB, 20, -20, "fullProfile")

    local auraWhitelist = CreateImportExportUI(fullProfile, "Aura Whitelist", BetterBlizzPlatesDB.auraWhitelist, 0, -100, "auraWhitelist")
    local auraBlacklist = CreateImportExportUI(auraWhitelist, "Aura Blacklist", BetterBlizzPlatesDB.auraBlacklist, 210, 0, "auraBlacklist")

    local totemIndicatorList = CreateImportExportUI(auraWhitelist, "Totem Indicator List", BetterBlizzPlatesDB.totemIndicatorNpcList, 0, -100, "totemIndicatorNpcList")

    local fadeOutNPCsList = CreateImportExportUI(totemIndicatorList, "Fade NPC List", BetterBlizzPlatesDB.fadeOutNPCsList, 0, -100, "fadeOutNPCsList")
    local hideNpcList = CreateImportExportUI(fadeOutNPCsList, "Hide NPC Blacklist", BetterBlizzPlatesDB.hideNPCsList, 210, 0, "hideNPCsList")
    local hideNPCsWhitelist = CreateImportExportUI(hideNpcList, "Hide NPC Whitelist", BetterBlizzPlatesDB.hideNPCsWhitelist, 210, 0, "hideNPCsWhitelist")

    local castEmphasisList = CreateImportExportUI(fadeOutNPCsList, "Cast Emphasis List", BetterBlizzPlatesDB.castEmphasisList, 0, -100, "castEmphasisList")
    local hideCastbarList = CreateImportExportUI(castEmphasisList, "Hide Castbar Blacklist", BetterBlizzPlatesDB.hideCastbarList, 210, 0, "hideCastbarList")
    local hideCastbarWhitelist = CreateImportExportUI(hideCastbarList, "Hide Castbar Whitelist", BetterBlizzPlatesDB.hideCastbarWhitelist, 210, 0, "hideCastbarWhitelist")

    local colorNpcList = CreateImportExportUI(castEmphasisList, "Color NPC List", BetterBlizzPlatesDB.colorNpcList, 0, -100, "colorNpcList")
    local auraColorList = CreateImportExportUI(colorNpcList, "Color by Aura List", BetterBlizzPlatesDB.auraColorList, 210, 0, "auraColorList")

    local text2 = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text2:SetText("Color NPC & Cast Emphasis now supports\nPlater NPC Color & Plater Cast Color import.")
    text2:SetPoint("LEFT", totemIndicatorList, "RIGHT", 60, 0)
end
------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
local function CombatOnGUICreation()
    if InCombatLockdown() then
        print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Leave combat to open settings for the first time.")
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
        BBP.category = Settings.RegisterCanvasLayoutCategory(BetterBlizzPlates, BetterBlizzPlates.name, BetterBlizzPlates.name)
        Settings.RegisterAddOnCategory(BBP.category)

        local titleText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFont_Gigantic")
        titleText:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -15, 33)
        titleText:SetText("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates")
        BetterBlizzPlates.titleText = titleText

        local loadGUI = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
        loadGUI:SetText("Load Settings")
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
    guiMidnight()
    BetterBlizzPlates.guiLoaded = true

    if SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end
    Settings.OpenToCategory(BBP.category:GetID())
    Settings.OpenToCategory(BBP.category:GetID(), BBP.guiCustomCode)
    Settings.OpenToCategory(BBP.category:GetID())
end

function BBP.CVarTracker()
    local cvarsToTrack = {
        checkboxes = {
            nameplateShowEnemyMinions = true,
            nameplateShowEnemyGuardians = true,
            nameplateShowEnemyMinus = true,
            nameplateShowEnemyPets = true,
            nameplateShowEnemyTotems = true,
            nameplateShowFriendlyMinions = true,
            nameplateShowFriendlyGuardians = true,
            nameplateShowFriendlyPets = true,
            nameplateShowFriendlyTotems = true,
            nameplateResourceOnTarget = true,
            nameplateMotion = true,
            nameplateShowAll = true
        },
        sliders = {
            nameplateOverlapH = true,
            nameplateOverlapV = true,
            nameplateMotionSpeed = true,
            nameplateMinAlpha = true,
            nameplateMinAlphaDistance = true,
            nameplateMaxAlpha = true,
            nameplateMaxAlphaDistance = true,
            nameplateOccludedAlphaMult = true
        }
    }

    local cvarListener = CreateFrame("Frame")
    cvarListener:RegisterEvent("CVAR_UPDATE")
    cvarListener:SetScript("OnEvent", function(self, event, cvarName, cvarValue)
        if BBP.CVarTrackingDisabled then return end
        if BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater") then return end

        if cvarsToTrack.checkboxes[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
        elseif cvarsToTrack.sliders[cvarName] then
            BetterBlizzPlatesDB[cvarName] = tonumber(cvarValue)
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
    welcomeText:SetText("Welcome to Better|cff00c0ffBlizz|rPlates!")
    welcomeText:SetJustifyH("CENTER")

    local description1 = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description1:SetPoint("TOP", welcomeText, "BOTTOM", 0, -10)
    description1:SetText("Thank you for trying out my addon!\n\nBelow you can pick a profile to start with or you can exit and customize everything by yourself.\n\nI highly recommend the minimal |A:newplayerchat-chaticon-newcomer:16:16|a|cff32cd32Starter Profile|r if you just\nwant a quick start with only the essentials!")
    description1:SetJustifyH("CENTER")
    description1:SetWidth(410)

    local btnWidth, btnHeight, btnGap = 150, 30, -3

    local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
        local noteText = additionalNote or ""
        local color = CLASS_COLORS[class] or "|cffffffff"
        local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
        local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, profileName.." Profile")
        local confirmationText = titleText .. "Are you sure you want to go\nwith the " .. profileText .. "?\n\n" .. noteText .. "Click yes to apply and Reload UI."
        StaticPopupDialogs["BBP_CONFIRM_PROFILE"].text = confirmationText
        StaticPopup_Show("BBP_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
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

    -- local mythicButton = CreateClassButton(BBP.IntroMessageWindow, "MYTHIC", "Mythic", nil, function()
    --     ShowProfileConfirmation("Mythic", "MYTHIC", BBP.MythicProfile)
    -- end)
    -- mythicButton:SetPoint("TOP", blitzButton, "BOTTOM", 0, btnGap)

    local orText = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText:SetPoint("CENTER", blitzButton, "BOTTOM", 0, -20)
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
    aeghisButton:SetPoint("TOP", blitzButton, "BOTTOM", 0, -40)

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
    buttonLast:SetText("Exit, No Profile.")
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
    CreateTooltipTwo(buttonLast, "Exit, No Profile", "Exit and customize everything yourself.\n\nYou can always change your mind later!", nil, "ANCHOR_TOP")
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