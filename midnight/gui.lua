local LSM = LibStub("LibSharedMedia-3.0")
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

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
local sliderList = {}

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
}

StaticPopupDialogs["BBP_CONFIRM_WIPE_NPCCOLOR"] = {
    text = titleText.."This will delete the entire npc color list and reload.\n\nAre you sure?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterBlizzPlatesDB.colorNpcList = {}
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
}

StaticPopupDialogs["BBP_CONFIRM_IMPORT_NPCCOLOR"] = {
    text = titleText.."This will add Mythic+ Season 3 NPCs to your color list and reload.\n\nAre you sure?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBP.MythicSeason3NPCColors()
    end,
    timeout = 0,
    whileDead = true,
}


StaticPopupDialogs["BBP_CONFIRM_WIPE_CASTEMPHASIS"] = {
    text = titleText.."This will delete the entire cast list and reload.\n\nAre you sure?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterBlizzPlatesDB.castEmphasisList = {}
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

StaticPopupDialogs["BBP_RESET_NP_AURAS"] = {
    text = titleText.."Are you sure you want to reset all nameplate aura settings?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBP.ResetNameplateAuraSettings()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBP_TOTEMLIST_RESET"] = {
    text = titleText.."This will delete the entire totem list and reset it back to its default state.\nA reload will be neccesary.\n\nAre you sure you want to continue?",
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
    resetButton:SetText("Default")
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
    dropdown:SetDefaultText(BetterBlizzPlatesDB[settingKey] or "Select texture")
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
    dropdown.label = dropdownText

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
                        elseif element == "fakeNameXPos" or element == "fakeNameYPos" or element == "fakeNameFriendlyXPos" or element == "fakeNameFriendlyYPos" or element == "fakeNameMaxWidth" then
                            BBP.RepositionName(frame)
                        -- Target Indicator Pos and Scale
                        elseif element == "targetIndicatorXPos" or element == "targetIndicatorYPos" or element == "targetIndicatorScale" then
                            BBP.TargetIndicator(frame)
                        -- Focus Target Indicator Pos and Scale
                        elseif element == "focusTargetIndicatorXPos" or element == "focusTargetIndicatorYPos" or element == "focusTargetIndicatorScale" then
                            BBP.FocusTargetIndicator(frame)
                        elseif element == "healthNumbersScale" or element == "healthNumbersXPos" or element == "healthNumbersYPos" then
                            BBP.HealthNumbers(frame)
                        -- Cast Timer Pos and Scale
                        elseif element == "castTimer" then
                            --not rdy
                        -- Cast bar icon pos and scale
                        elseif element == "castBarIconXPos" or element == "castBarIconYPos" or element == "castBarIconScale" then
                            if axis then
                                frame.castBarIconFrame:ClearAllPoints()
                                frame.castBarIconFrame:SetPoint("CENTER", frame.castBar, "LEFT", -2 + BetterBlizzPlatesDB.castBarIconXPos, BetterBlizzPlatesDB.castBarIconYPos)
                                frame.castBar.BorderShield:ClearAllPoints()
                                frame.castBar.BorderShield:SetPoint("CENTER", frame.castBarIconFrame, "CENTER", 0, 0)
                                if frame.castBar.bbpClassicIcon then
                                    frame.castBar.bbpClassicIcon:ClearAllPoints()
                                    frame.castBar.bbpClassicIcon:SetPoint("RIGHT", frame.CastBarsContainer.castBar, "LEFT", xPos-2, yPos)
                                end
                            else
                                BetterBlizzPlatesDB.castBarIconScale = value
                                frame.castBarIconFrame:SetScale(value)
                                --frame.castBar.BorderShield:SetScale(value)
                                if frame.castBar.bbpClassicIcon then
                                    frame.castBar.bbpClassicIcon:SetScale(value)
                                end
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
            local tooltipText = "|cff32f795Right-click to keep them enabled on your Target.|r"

            -- Add or remove the checkmark based on the value of showOnTarget
            if showOnTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            tooltipText = tooltipText .. "\n\n|cffc084f7Shift + Right-click to keep Tank and Healer healthbars visible in PvE.|r"

            if BetterBlizzPlatesDB.friendlyHideHealthBarShowTanksAndHeals then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            if BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerHideAll then
                tooltipText = tooltipText .. "\n\n|cff00c0ffParty Pointer|r: Hide All setting is enabled which affects this setting.\nInfo in |cff32f795Advanced Settings|r."
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Hide NPC Healthbar" then
            local hideFriendlyHpNpcPve = BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve
            local tooltipText = "\n|cff32f795Right-click to keep NPC healthbars shown in PvE.|r"

            if hideFriendlyHpNpcPve then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            tooltipText = tooltipText .. "\n\n|cffc084f7Shift + Right-click to keep healthbar shown on your Pet.|r"
            if BetterBlizzPlatesDB.friendlyHideHealthBarShowPet then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Hide Enemy Castbar" then
            local showOnTarget = BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget
            local tooltipText = "|cff32f795Right-click to keep them enabled on your Target.|r"

            -- Add or remove the checkmark based on the value of showOnTarget
            if showOnTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            if BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerHideAll then
                tooltipText = tooltipText .. "\n\n|cff00c0ffParty Pointer|r: Hide All setting is enabled which affects this setting.\nInfo in |cff32f795Advanced Settings|r."
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Hide Castbar Text" then
            local alsoHideInt = BetterBlizzPlatesDB.hideCastbarTextInt
            local tooltipText = "\n|cff32f795Right-click to also hide the \"Interrupted\" text|r"

            if alsoHideInt then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Hide Friendly Castbar" then
            local showOnTarget = BetterBlizzPlatesDB.alwaysHideFriendlyCastbarShowTarget
            local tooltipText = "|cff32f795Right-click to keep them enabled on your Target.|r"

            -- Add or remove the checkmark based on the value of showOnTarget
            if showOnTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            if BetterBlizzPlatesDB.partyPointer and BetterBlizzPlatesDB.partyPointerHideAll then
                tooltipText = tooltipText .. "\n\n|cff00c0ffParty Pointer|r: Hide All setting is enabled which affects this setting.\nInfo in |cff32f795Advanced Settings|r."
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Hide Level" and BetterBlizzPlatesDB.classicNameplates then
            local showInPvP = BetterBlizzPlatesDB.hideLevelFrameForceOnInPvP
            local tooltipText = "\n|cff32f795Right-click to show Level in PvP |r"

            if showInPvP then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Color Focus Nameplate Healthbar" then
            local tooltipText = "\n|cff32f795Right-click to disable while in PvP.|r"
            if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateNotPvP then
                tooltipText = tooltipText .. "\nDisabled in PvP |A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Stacking Enemy Nameplates" then
            local tooltipText = "\n|cff32f795Right-click to keep Overlapping Nameplates in PvP.|r"
            if BetterBlizzPlatesDB.keepOverlappingNameplatesInPvP then
                tooltipText = tooltipText .. "\nOverlapping in PvP enabled|A:ParagonReputation_Checkmark:15:15|a"
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
        elseif title == "Hide Enemy Name" then
            local forceShowTotems = BetterBlizzPlatesDB.forceShowTotemNames
            local tooltipText = "\n|cff32f795Right-click to keep totem names shown.\nNote: Expects only Enemy Totems and Enemy Pets enabled in CVar Control. Otherwise it will keep the name shown for the other categories as well.|r"

            if forceShowTotems then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Sort Auras by Duration" then
            local tooltipText = "\n|cff32f795Right-click to reverse duration sort.|r"
            if BetterBlizzPlatesDB.sortDurationAurasReverse then
                tooltipText = tooltipText .. "\nReverse sorting|A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Castbar Background Color" then
            local redBg = BetterBlizzPlatesDB.redBgCastColor
            local tooltipText = "\n|cff32f795Right-click to color the background red during un-interruptiple cast.|r"

            if redBg then
                tooltipText = tooltipText .. "\n|cff32f795Enabled |A:ParagonReputation_Checkmark:15:15|a"
            else
                tooltipText = tooltipText .. "\n|cFFFFD100Disabled |A:lootroll-toast-icon-pass-up:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Center Auras on Enemy" then
            local centerBuffsOnly = BetterBlizzPlatesDB.nameplateCenterOnlyBuffs
            local tooltipText = "\n|cff32f795Right-click to only center Buffs.|r"

            if centerBuffsOnly then
                tooltipText = tooltipText .. "\n|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Nameplate Resource" then
            local showOnPlayerWithoutTarget = BetterBlizzPlatesDB.nameplateResourceOnTargetAndNoTargetOnSelf
            local tooltipText = "\n|cff32f795Right-click to show resource on Personal Resource Display when you have no target|r"

            if showOnPlayerWithoutTarget then
                tooltipText = tooltipText .. "|A:ParagonReputation_Checkmark:15:15|a"
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Friend/Guildie Indicator" then
            local currentAnchor = BetterBlizzPlatesDB.friendIndicatorAnchor or "LEFT"
            local tooltipText = "\n|cff32f795Right-click to change anchor: " .. currentAnchor .. "|r"
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        elseif title == "Show Crowd Control" then
            local tooltipText = "\n|cff32f795Right-click to hide the cooldown duration text on the CC.|r"

            if BetterBlizzPlatesDB.classIndicatorCCHideCdText then
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
            GameTooltip:AddDoubleLine("Changes CVar:", cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
            if cvarName2 then
                GameTooltip:AddDoubleLine(" ", cvarName2, 0.2, 1, 0.6, 0.2, 1, 0.6)
            end
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
    DEATHKNIGHT = "|cffc41f3b",
    MONK = "|cff00ff96",
    DEMONHUNTER = "|cffa330c9",
    EVOKER = "|cff33937f",
    STARTER = "|cff32cd32",
    BLITZ = "|cffff8000",
    MYTHIC = "|cff7dd1c2",
    PREMIDNIGHT = "|cffbbc3ff",
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

local function CreateClassButton(parent, class, name, twitchName, onClickFunc, youtubeName)
    local bbpParent = parent == BetterBlizzPlates
    local coreProfile = class == "STARTER" or class == "BLITZ" or class == "MYTHIC" or class == "PREMIDNIGHT" or name == "Bodify"
    local btnWidth, btnHeight = bbpParent and 110 or (coreProfile and 150 or 114), bbpParent and 22 or 30
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetSize(btnWidth, btnHeight)
    button:SetScale(bbpParent and 0.9 or 0.95)

    local dontIncludeProfileText = (bbpParent or not coreProfile) and "" or " Profile"
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"

    if name == "Bodify" then
        icon = "gmchat-icon-blizz"
    end

    if name == "Pre-Midnight" then
        button:SetText(string.format("|A:%s:16:16|a%s%s|r", icon, color, name..dontIncludeProfileText))
    else
        button:SetText(string.format("|A:%s:16:16|a %s%s|r", icon, color, name..dontIncludeProfileText))
    end
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    local a,b,c = button.Text:GetFont()
    button.Text:SetFont(a,b,"OUTLINE")
    local a,b,c,d,e = button.Text:GetPoint()
    if not bbpParent then
        button.Text:SetPoint("LEFT",b,"LEFT",10,e-0.6)
    end

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
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A tweaked version of the Midnight nameplates with NPC colors enabled.", nil, "ANCHOR_TOP")
    elseif name == "Bodify" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "My personal profile from a while ago. Meant for Arenas only. Possible I'd make some tweaks if I was actively playing still.", nil, "ANCHOR_TOP")
    elseif name == "Pre-Midnight" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A very basic profile that aims to be similar to how the nameplates looked like before Midnight. A few adjustments that can be tuned later on.", nil, "ANCHOR_TOP")
    else
        local socialText = ""
        if twitchName then
            socialText = string.format("www.twitch.tv/%s", twitchName)
        end
        if youtubeName then
            if socialText ~= "" then socialText = socialText .. "\n" end
            socialText = socialText .. string.format("www.youtube.com/@%s", youtubeName)
        end
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), string.format("Enable all of %s's profile settings.", name), socialText ~= "" and socialText or nil, "ANCHOR_TOP")
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

    if title == "Cast Emphasis List" then
        CreateTooltipTwo(titleText, "Supports Plater cast color import as well.")
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
        if InCombatLockdown() then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Leave combat to Import")
            return
        end
        local importString = importBox:GetText()
        local profileData, errorMessage, bypass = BBP.OldImportProfile(importString, tableName)
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Error importing " .. title .. ":", errorMessage)
        else
            if bypass then
                -- bypass
            else
                if tableName == "auraWhitelist" or tableName == "auraBlacklist" then
                    local keyed = BBP.NormalizeAuraList(profileData)
                    if next(keyed) == nil and next(profileData) ~= nil then
                        print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Error importing " .. title ..
                            ": that string holds no auras with a spell ID. Nothing was changed.")
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
                end
            end
            BetterBlizzPlatesDB.scStart = true
            BetterBlizzPlatesDB.skipUpdateMsg = true
            if BetterBlizzPlatesDB.friendlyNameplatesEnabledOnExport then
                C_CVar.SetCVar("nameplateShowFriendlyPlayers", "1")
                BetterBlizzPlatesDB.friendlyNameplatesEnabledOnExport = nil
            end
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

local function CreateCheckbox(option, label, parent, cvar, extraFunc, bitCVar)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)
    checkBox:SetSize(24,24)
    checkBox.option = option
    table.insert(checkBoxList, {checkbox = checkBox, label = label})
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
        category = "General"
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
            local resolved = BBP.TWWGetSpellInfo(npc.id) or C_Spell.GetSpellName(npc.id)
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
                return string.format("%s (%d)", GetEntryName(npc) or "Name Missing", npc.id)
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
            CreateTooltipTwo(button.checkBoxPandemic, "Pandemic Glow |A:elementalstorm-boss-air:22:22|a",
                "Check for a red glow when the aura has less than 30% of its duration remaining.\nOr last 5sec if the aura has no pandemic effect.",
                globalPandemic
                    and "Inactive: \"Pandemic\" under Aura Glows is on, which already glows every aura you cast. Turn that off to pick spells individually here."
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
                    GameTooltip:AddLine("Spell ID: " .. id, 1, 1, 1)
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
                colorPickerButton:SetText("Color")

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
                CreateTooltipTwo(checkBoxMurloc, "Murloc Icon |A:newplayerchat-chaticon-newcomer:22:22|a", "Instead of hiding the nameplate completely show a small Murloc icon.", nil, "ANCHOR_TOPRIGHT")

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
                CreateTooltipTwo(checkBoxOnMe, "Only On Me |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", "Only emphasize this spell if it is being cast on me.", "This is only for NPCs, due to API limitations.", "ANCHOR_TOPRIGHT")

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
                CreateTooltipTwo(checkBoxImportant, "Important Glow |A:importantavailablequesticon:22:22|a",
                    "Check for a glow on the aura to highlight it.\n|cff32f795Right-click to change Color.|r",
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
                CreateTooltipTwo(checkBoxEnlarged, "Enlarged Aura |A:ui-hud-minimap-zoom-in:22:22|a",
                    "Check to make the aura square and bigger.",
                    "You can turn off square and adjust size in settings below.\n\nCombine with Important Glow to also glow it, in its own shared Enlarged color.\n|cff32f795Right-click to change that color.|r",
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
                CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a",
                    "Only show my aura.", nil, "ANCHOR_TOPRIGHT")

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
                CreateTooltipTwo(prioritySlider, "Priority value", "Whichever aura has the highest priority will determine the color.")

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
                CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", "Only color my aura.", nil, "ANCHOR_TOPRIGHT")

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
        text = "This name or npcID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
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
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(entryToDelete)
            entryToDelete = nil
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    if listName == "auraWhitelist" then
        CreateTooltipTwo(editBox, "Add whitelist aura",
            "Enter Spell ID of Aura to add to whitelist. You can also type to search in list.\nYou can enable Spell ID on tooltips below in settings.\n\nNOTE: Auras can have MULTIPLE correct Spell IDs and they might change depending on talents and if in PvP or not etc.\n\nReminder that filtering only works for enemy debuffs and friendly buffs.",
            nil, "ANCHOR_TOP")
    elseif listName == "auraBlacklist" then
        CreateTooltipTwo(editBox, "Add blacklist aura",
            "Enter Spell ID of Aura to add to blacklist. You can enable Spell ID on tooltips below in settings.\n\nReminder that filtering only works for enemy debuffs and friendly buffs.",
            nil, "ANCHOR_TOP")
    elseif isKeyed then
        CreateTooltipTwo(editBox, "Add new aura or Search", "Add new aura to the list with its spell id. Typing also searches in the list.", nil, "ANCHOR_TOP")
    elseif listName == "auraColorList" or
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
        duplicateEntry = nil

        local name, comment = strsplit("/", inputText, 2)
        name = strtrim(name or "")
        comment = strtrim(comment or "")
        local id = tonumber(name)

        if isKeyed and not id then
            if name ~= "" then
                BBP.Print("Spell ID only. Auras can no longer be filtered by name in Midnight.")
            end
            setSearchFilter("")
            editBox:SetText("")
            refreshList()
            return
        end

        local icon
        if id then
            local spellName, _, spellIcon = BBP.TWWGetSpellInfo(id)
            if isKeyed and not spellName then
                BBP.Print("No spell found with ID " .. id .. ".")
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
                BBP.Print(iconString .. name .. " (" .. id .. ") added to the "
                    .. (listName == "auraBlacklist" and "blacklist." or "whitelist."))
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
    addButton:SetText("Add")
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
        editButton:SetPoint("RIGHT", button, "RIGHT", -105, 0)
        editButton:SetText("Edit")
        editButton:SetScript("OnClick", function()
            ShowEditFrame(npcId)
        end)
        button.editButton = editButton
        CreateTooltipTwo(editButton, "Edit NPC details", "Change size, duration, icon and glow.")

        -- Size button
        local sizeButton = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sizeButton:SetPoint("RIGHT", button, "RIGHT", -165, 0)
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
        CreateTooltipTwo(hideHealthBarCheckBox, "Hide HealthBar")

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
    addButton:SetText("Add")
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
        CreateTooltipTwo(hideHealthBarCheckBox, "Hide HealthBar")

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


                local barWidthSlider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
                local editBox = CreateFrame("EditBox", nil, barWidthSlider, "InputBoxTemplate")
                editBox:SetAutoFocus(false)
                editBox:SetWidth(50)
                editBox:SetHeight(20)
                editBox:SetMultiLine(false)
                editBox:SetFrameStrata("DIALOG")
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
local function guiProfiles()
    local parent = SettingsPanel
    local frame = CreateFrame("Frame", nil, BetterBlizzPlates, "SettingsFrameTemplate")
    frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.titleText:SetPoint("TOP", frame, "TOP", 1, -4)
    frame.titleText:SetText("|A:gmchat-icon-blizz:16:16|a BBP")

    frame.descriptionText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.descriptionText:SetPoint("TOP", frame, "TOP", 2, -25)
    frame.descriptionText:SetText("Profiles for BetterBlizzPlates:")
    frame.descriptionText:SetWidth(100)

    frame.coreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.coreText:SetPoint("TOP", frame.descriptionText, "BOTTOM", 0, -3)
    frame.coreText:SetText("Core")

    frame.streamerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.streamerText:SetPoint("TOP", frame.coreText, "BOTTOM", 0, -110)
    frame.streamerText:SetText("Streamers")

    frame.infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.infoText:SetPoint("BOTTOM", frame, "BOTTOM", 2, 39)
    frame.infoText:SetText("") --If you are missing and want to be here let me know :)
    frame.infoText:SetWidth(100)

    frame:SetSize(130, parent:GetHeight())
    frame:SetPoint("TOPRIGHT", parent, "TOPLEFT", 7, 0)
    frame:SetFrameStrata("BACKGROUND")
    frame.ClosePanelButton:Hide()

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
    midnightBeta:SetText("|T136221:12:12|t |cffcc66ffBetterBlizzPlates EARLY BETA (Beware of bugs! WIP).")
    midnightBeta:SetFont("Fonts\\FRIZQT__.TTF", 24, "THINOUTLINE")
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
    CreateTooltipTwo(newSearch, "Search |A:shop-games-magnifyingglass:17:17|a", "You can now search for settings in BetterBlizzPlates. (WIP)")

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
    settingsText:SetText("General settings")
    local generalSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local removeRealmNames = CreateCheckbox("removeRealmNames", "Hide realm", BetterBlizzPlates)
    removeRealmNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(removeRealmNames, "Hide Realm Name", "Hide the realm name from Player names on nameplates.")

    local healthNumbers = CreateCheckbox("healthNumbers", "Health numbers", BetterBlizzPlates, nil, BBP.ToggleHealthNumbers)
    healthNumbers:SetPoint("LEFT", removeRealmNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(healthNumbers, "Show Health Numbers", "Show health numbers on nameplates. More settings available in |cff32f795Advanced Settings|r.")

    local smallPetsInPvP = CreateCheckbox("smallPetsInPvP", "Small Pets", BetterBlizzPlates)
    smallPetsInPvP:SetPoint("LEFT", healthNumbers.text, "RIGHT", 0, 0)
    CreateTooltipTwo(smallPetsInPvP, "Small Pets in PvP", "Reduce the width (and optionally height) of pet nameplates, and small NPC nameplates in PvP.\n\n|cff32f795Right-click for options.|r")

    local smallPetsOptionsFrame
    local function OpenSmallPetsOptionsWindow()
        if not smallPetsOptionsFrame then
            smallPetsOptionsFrame = CreateFrame("Frame", "BBPSmallPetsOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            smallPetsOptionsFrame:SetSize(180, 240)
            smallPetsOptionsFrame:SetPoint("CENTER")
            smallPetsOptionsFrame:SetFrameStrata("HIGH")
            smallPetsOptionsFrame:SetMovable(true)
            smallPetsOptionsFrame:EnableMouse(true)
            smallPetsOptionsFrame:RegisterForDrag("LeftButton")
            smallPetsOptionsFrame:SetScript("OnDragStart", smallPetsOptionsFrame.StartMoving)
            smallPetsOptionsFrame:SetScript("OnDragStop", smallPetsOptionsFrame.StopMovingOrSizing)
            smallPetsOptionsFrame.title = smallPetsOptionsFrame:CreateFontString(nil, "OVERLAY")
            smallPetsOptionsFrame.title:SetFontObject("GameFontHighlight")
            smallPetsOptionsFrame.title:SetPoint("LEFT", smallPetsOptionsFrame.TitleBg, "LEFT", 5, 0)
            smallPetsOptionsFrame.title:SetText("Small Pets Options")

            local smallPetsAllNPCs = CreateCheckbox("smallPetsInPvPAllNPCs", "Shrink All NPCs in PvP", smallPetsOptionsFrame)
            smallPetsAllNPCs:SetPoint("TOPLEFT", smallPetsOptionsFrame, "TOPLEFT", 10, -26)
            CreateTooltipTwo(smallPetsAllNPCs, "Shrink All NPCs in PvP", "Also shrink all NPC nameplates while in PvP, not just pets/minions.")

            local smallPetsIgnoreTotems = CreateCheckbox("smallPetsInPvPIgnoreTotems", "Ignore Totems", smallPetsOptionsFrame)
            smallPetsIgnoreTotems:SetPoint("TOPLEFT", smallPetsAllNPCs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
            CreateTooltipTwo(smallPetsIgnoreTotems, "Ignore Totems", "Keep totems at full width/height instead of shrinking them.", "|cFFFFD100Note: Only works if you only have Totems and Pets enabled. Guardians etc would also be ignored if enabled.|r")

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

            local smallPetsWidthSlider = CreateSlider(smallPetsOptionsFrame, "Pets Width", 2, 40, 1, "smallPetsWidth", nil, 150)
            smallPetsWidthSlider:SetPoint("TOPLEFT", smallPetsIgnoreTotems, "BOTTOMLEFT", 2, -10)
            CreateTooltipTwo(smallPetsWidthSlider, "Pets Width", "Adjust the width used for pet nameplates.", "Right-click the slider to type a value outside the default range.")

            local smallPetsSmallerWidthSlider = CreateSlider(smallPetsOptionsFrame, "Smaller Pets Width", 2, 40, 1, "smallPetsSmallerWidth", nil, 150)
            smallPetsSmallerWidthSlider:SetPoint("TOPLEFT", smallPetsWidthSlider, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(smallPetsSmallerWidthSlider, "Smaller Pets Width", "Adjust the width used for smaller pet nameplates like guardians and totems etc.", "Right-click the slider to type a value outside the default range.")

            local smallPetsInPvPHeight = CreateCheckbox("smallPetsInPvPHeight", "Also Adjust Height", smallPetsOptionsFrame)
            smallPetsInPvPHeight:SetPoint("TOPLEFT", smallPetsSmallerWidthSlider, "BOTTOMLEFT", -2, -10)
            CreateTooltipTwo(smallPetsInPvPHeight, "Also Adjust Height", "Also shrink the height of pet/small nameplates, not just the width.")

            local smallPetsHeightSlider = CreateSlider(smallPetsOptionsFrame, "Pets Height", 1, 35, 0.1, "smallPetsHeight", nil, 150)
            smallPetsHeightSlider:SetPoint("TOPLEFT", smallPetsInPvPHeight, "BOTTOMLEFT", 2, -10)
            CreateTooltipTwo(smallPetsHeightSlider, "Pets Height", "Adjust the height used for pet nameplates.", "Right-click the slider to type a value outside the default range.")

            local smallPetsSmallerHeightSlider = CreateSlider(smallPetsOptionsFrame, "Smaller Pets Height", 1, 35, 0.1, "smallPetsSmallerHeight", nil, 150)
            smallPetsSmallerHeightSlider:SetPoint("TOPLEFT", smallPetsHeightSlider, "BOTTOMLEFT", 0, -17)
            CreateTooltipTwo(smallPetsSmallerHeightSlider, "Smaller Pets Height", "Adjust the height used for smaller pet nameplates like guardians and totems etc.", "Right-click the slider to type a value outside the default range.")

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

    local hideNameplateAuras = CreateCheckbox("hideNameplateAuras", "Hide nameplate auras", BetterBlizzPlates)
    hideNameplateAuras:SetPoint("TOPLEFT", removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideNameplateAuras, "Hide Nameplate Auras", "Hide all Nameplate Auras.")
    hideNameplateAuras:HookScript("OnClick", function (self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local hideNameplateAuraTooltip = CreateCheckbox("hideNameplateAuraTooltip", "Hide aura tooltip", BetterBlizzPlates)
    hideNameplateAuraTooltip:SetPoint("LEFT", hideNameplateAuras.text, "RIGHT", 0, 0)
    hideNameplateAuraTooltip:HookScript("OnClick", function()
        BBP.HideNameplateAuraTooltip()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)
    CreateTooltipTwo(hideNameplateAuraTooltip, "Hide Aura Tooltip", "Hide Nameplate Aura Tooltips.")

    local hideTargetHighlight = CreateCheckbox("hideTargetHighlight", "Hide target glow", BetterBlizzPlates)
    hideTargetHighlight:SetPoint("TOPLEFT", hideNameplateAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTargetHighlight, "Hide Target Highlight", "Hide the bright glow on your current target nameplate")

    local classicNameplates = CreateCheckbox("classicNameplates", "Classic Nameplates", BetterBlizzPlates)
    classicNameplates:SetPoint("TOPLEFT", hideTargetHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicNameplates, "Classic Nameplates", "Enable to use a classic nameplate look for your nameplates.", "Only healthbar for now, might add classic castbar in a later patch.\nYou can enable castbar customization and change the texture to the old texture which will basically be the old classic castbars.")
    classicNameplates:HookScript("OnClick", function(self)
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local hideLevelFrame = CreateCheckbox("hideLevelFrame", "Hide Lvl", BetterBlizzPlates)
    hideLevelFrame:SetPoint("LEFT", classicNameplates.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideLevelFrame, "Hide Level", "Hide the level display.")
    hideLevelFrame:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzPlatesDB.classicNameplates then return end
            if BetterBlizzPlatesDB.hideLevelFrameForceOnInPvP == nil then
                BetterBlizzPlatesDB.hideLevelFrameForceOnInPvP = true
            else
                BetterBlizzPlatesDB.hideLevelFrameForceOnInPvP = not BetterBlizzPlatesDB.hideLevelFrameForceOnInPvP
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    classicNameplates:HookScript("OnClick", function(self)
        if self:GetChecked() then
            hideLevelFrame:SetChecked(false)
            BetterBlizzPlatesDB.hideLevelFrame = false
            BetterBlizzPlatesDB.classicRetailNameplates = nil
        else
            hideLevelFrame:SetChecked(true)
            BetterBlizzPlatesDB.hideLevelFrame = true
        end
        BBP.RefreshAllNameplates()
    end)

    local classicRetailNameplates = CreateCheckbox("classicRetailNameplates", "Use the Pre-Midnight Nameplate look", BetterBlizzPlates)
    classicRetailNameplates:SetPoint("TOPLEFT", classicNameplates, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicRetailNameplates, "Pre-Midnight Nameplates", "Enable to use the old retail nameplate look instead of the new Midnight style nameplates.\n\nIn Blizzards \"Nameplates\" section you likely want to select \"Blocky Bars\" or similar for nameplate style. The new styles does not matter too much due to BBP customizing things. BBP still needs more work to cover the settings gap.")
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
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local nameplateMinScale = CreateSlider(BetterBlizzPlates, "Nameplate Size", 0.5, 2, 0.01, "nameplateMinScale")
    nameplateMinScale:SetPoint("TOPLEFT", classicRetailNameplates, "BOTTOMLEFT", 12, -15)
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

    local nameplateGeneralHpHeight = CreateSlider(BetterBlizzPlates, "Nameplate Height", 4, 50, 0.5, "nameplateGeneralHpHeight")
    nameplateGeneralHpHeight:SetPoint("TOPLEFT", nameplateSelectedScale, "BOTTOMLEFT", 0, -17)
    if BetterBlizzPlatesDB.changeHealthbarHeight then
        CreateTooltipTwo(nameplateGeneralHpHeight, "Nameplate Height", "Disabled due to Misc setting:\nSeparate Enemy/Friendly Healthbar Height\n\nUse that instead.")
        nameplateGeneralHpHeight:Disable()
        nameplateGeneralHpHeight:SetAlpha(0.5)
    else
        CreateTooltipTwo(nameplateGeneralHpHeight, "Nameplate Height", "Changes the height of ALL nameplates.")
    end

    local nameplateGeneralHpHeightResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateGeneralHpHeightResetButton:SetText("Default")
    nameplateGeneralHpHeightResetButton:SetWidth(60)
    nameplateGeneralHpHeightResetButton:SetPoint("LEFT", nameplateGeneralHpHeight, "RIGHT", 10, 0)
    nameplateGeneralHpHeightResetButton:SetScript("OnClick", function()
        local value = (BetterBlizzPlatesDB.classicNameplates or BetterBlizzPlatesDB.classicRetailNameplates) and 12 or 16
        nameplateGeneralHpHeight:SetValue(value)
        BetterBlizzPlatesDB.nameplateGeneralHpHeight = value
    end)
    CreateTooltipTwo(nameplateGeneralHpHeightResetButton, "Reset Nameplate Height", "Midnight default is 16. Pre-midnight is ~12.", nil, "ANCHOR_TOP")
    ----------------------
    -- Enemy nameplates:
    ----------------------
    local enemyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -191)
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
    enemyColorNameButton:SetText("Hostile")
    enemyColorNameButton:SetPoint("LEFT", enemyColorName.Text, "RIGHT", -1, 0)
    enemyColorNameButton:SetSize(55, 20)
    enemyColorNameButton:SetScript("OnClick", function()
        OpenColorPicker("enemyColorNameRGB", enemyColorNameButtonIcon)
    end)
    CreateTooltipTwo(enemyColorNameButton, "Hostile Color")
    enemyColorNameButtonIcon:SetPoint("LEFT", enemyColorNameButton, "RIGHT", 0, -0.5)

    local enemyNeutralColorNameButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNeutralColorNameButtonIcon:SetAtlas("newplayertutorial-icon-key")
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

    local nameplateShowClassColor = CreateCheckbox("nameplateShowClassColor", "Class color healthbar", BetterBlizzPlates, true, BBP.ApplyNameplateWidth)
    nameplateShowClassColor:SetPoint("TOPLEFT", enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowClassColor, "Class Color Healthbar", "Class color enemy healthbars.", nil, nil, "nameplateShowClassColor")
    if GetCVar("nameplateShowClassColor") == "1" and BetterBlizzPlatesDB.nameplateShowClassColor == nil then
        BetterBlizzPlatesDB.nameplateShowClassColor = true
        nameplateShowClassColor:SetChecked(true)
    end

    local enemyColorThreat = CreateCheckbox("enemyColorThreat", "Color Threat", BetterBlizzPlates)
    enemyColorThreat:SetPoint("LEFT", nameplateShowClassColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyColorThreat, "Color by threat in instanced PvE", "Color options and more settings in |cff32f795Advanced Settings|r section. Default Red & Green.")

    local enemyHealthBarColor = CreateCheckbox("enemyHealthBarColor", "Custom healthbar color", BetterBlizzPlates)
    enemyHealthBarColor:SetPoint("TOPLEFT", nameplateShowClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enemyHealthBarColor, "Custom Nameplate Color", "Color ALL enemy nameplates a color of your choice.", "Has sub-setting to color NPC's only")

    local alwaysHideEnemyCastbar = CreateCheckbox("alwaysHideEnemyCastbar", "Hide castbar", BetterBlizzPlates)
    alwaysHideEnemyCastbar:SetPoint("TOPLEFT", enemyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideEnemyCastbar, "Hide Enemy Castbar", "Always hide Enemy castbar.")
    alwaysHideEnemyCastbar:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget = not BetterBlizzPlatesDB.alwaysHideEnemyCastbarShowTarget
            --self:SetChecked(BetterBlizzPlatesDB.friendlyHideHealthBarShowTarget)
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    local enemyHealthBarColorNpcOnly = CreateCheckbox("enemyHealthBarColorNpcOnly", "Npc only", BetterBlizzPlates)
    enemyHealthBarColorNpcOnly:SetPoint("LEFT", enemyHealthBarColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(enemyHealthBarColorNpcOnly, "Only color NPC's.")

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
    enemyHealthBarColorButton:SetText("Hostile")
    enemyHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorNpcOnly.Text, "RIGHT", -1, 0)
    enemyHealthBarColorButton:SetSize(55, 20)
    enemyHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyHealthBarColorRGB", enemyHealthBarColorButtonIcon)
    end)
    CreateTooltipTwo(enemyHealthBarColorButton, "Hostile Color")
    enemyHealthBarColorButtonIcon:SetPoint("LEFT", enemyHealthBarColorButton, "RIGHT", 0, -0.5)

    local enemyNeutralHealthBarColorButtonIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNeutralHealthBarColorButtonIcon:SetAtlas("newplayertutorial-icon-key")
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

    local showNameplateCastbarTimer = CreateCheckbox("showNameplateCastbarTimer", "Cast timer next to castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateCastbarTimer:SetPoint("LEFT", alwaysHideEnemyCastbar.text, "RIGHT", 0, 0)

    local showNameplateTargetText = CreateCheckbox("showNameplateTargetText", "Show Target Text", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateTargetText:SetPoint("TOPLEFT", alwaysHideEnemyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateTargetText, "Nameplate Target Text", "Show the nameplates current target underneath the castbar while casting.", "More settings in the Advanced Settings section like position, size and \"Always show\" etc.")

    local hideEliteDragon = CreateCheckbox("hideEliteDragon", "Hide elite icon", BetterBlizzPlates)
    hideEliteDragon:SetPoint("LEFT", showNameplateTargetText.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideEliteDragon, "Hide Elite Icon", "Hide the elite dragon icon on nameplates")

    local enemyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 1.5, 0.01, "enemyNameScale")
    enemyNameScale:SetPoint("TOPLEFT", showNameplateTargetText, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(enemyNameScale, "Name Size", "Change Name size on Enemy nameplates")

    local hideEnemyNameText = CreateCheckbox("hideEnemyNameText", "Hide name", BetterBlizzPlates)
    hideEnemyNameText:SetPoint("LEFT", enemyNameScale, "RIGHT", 2, 0)
    CreateTooltipTwo(hideEnemyNameText, "Hide Enemy Name", "Hide Name on Enemy nameplates")
    hideEnemyNameText:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BetterBlizzPlatesDB.forceShowTotemNames = not BetterBlizzPlatesDB.forceShowTotemNames
            if BetterBlizzPlatesDB.forceShowTotemNames then
                if not C_CVar.GetCVarBool("UnitNameEnemyTotemName") then
                    BBP.RunAfterCombat(function()
                        C_CVar.SetCVar("UnitNameEnemyTotemName", "1")
                        BBP.Print("CVar \"UnitNameEnemyTotemName\" set to 1 so totem names can be shown.")
                    end)
                end
                if BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown then
                    BetterBlizzPlatesDB.totemIndicatorHideNameAndShiftIconDown = false
                    if BBP.totemIndicatorHideName then
                        BBP.totemIndicatorHideName:SetChecked(false)
                    end
                end
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

    local nameplateEnemyWidth = CreateSlider(BetterBlizzPlates, "Nameplate Width", 24, 300, 1, "nameplateEnemyWidth")
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
    friendlyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -375)
    friendlyNameplatesText:SetText("Friendly nameplates")
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", "Clickthrough", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(friendlyNameplateClickthrough, "Clickthrough Nameplate", "Make friendly nameplates clickthrough")

    -- local friendlyNameplateNonstackable = CreateCheckbox("friendlyNameplateNonstackable", "Non-Stackable", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    -- friendlyNameplateNonstackable:SetPoint("LEFT", friendlyNameplateClickthrough.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(friendlyNameplateNonstackable, "Non-Stackable", "Makes the friendly nameplates non-stackable even with \"Stacking Nameplates\" on.")

    local friendlyClassColorName = CreateCheckbox("friendlyClassColorName", "Class color name", BetterBlizzPlates)
    friendlyClassColorName:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyClassColorName, "Class Color Name", "Class color the Friendly name text on nameplates")

    local friendlyColorName = CreateCheckbox("friendlyColorName", "Color name", BetterBlizzPlates)
    friendlyColorName:SetPoint("LEFT", friendlyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(friendlyColorName, "Color Name", "Pick one color for all friendly names.", "If class color name is also enabled this setting will only color the name of npcs")

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

    local nameplateShowFriendlyClassColor = CreateCheckbox("nameplateShowFriendlyClassColor", "Class color healthbar", BetterBlizzPlates, true)
    nameplateShowFriendlyClassColor:SetPoint("TOPLEFT", friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyClassColor, "Class color healthbar", "Class color friendly healthbars.", nil, nil, "nameplateShowFriendlyClassColor")
    if GetCVar("nameplateShowFriendlyClassColor") == "1" and BetterBlizzPlatesDB.nameplateShowFriendlyClassColor == nil then
        BetterBlizzPlatesDB.nameplateShowFriendlyClassColor = true
        nameplateShowFriendlyClassColor:SetChecked(true)
    end

    local friendlyHealthBarColor = CreateCheckbox("friendlyHealthBarColor", "Custom healthbar color", BetterBlizzPlates)
    friendlyHealthBarColor:SetPoint("TOPLEFT", nameplateShowFriendlyClassColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendlyHealthBarColor, "Custom Healthbar Color", "Color Friendly healthbars a color of your choice.")

    local friendlyHealthBarColorPlayer = CreateCheckbox("friendlyHealthBarColorPlayer", "Player", BetterBlizzPlates)
    friendlyHealthBarColorPlayer:SetPoint("LEFT", friendlyHealthBarColor.text, "RIGHT", -3, 0)
    CreateTooltipTwo(friendlyHealthBarColorPlayer, "Color Players", "Color friendly player healthbars.")

    local friendlyHealthBarColorNpc = CreateCheckbox("friendlyHealthBarColorNpc", "Npc", BetterBlizzPlates)
    friendlyHealthBarColorNpc:SetPoint("LEFT", friendlyHealthBarColorPlayer.text, "RIGHT", -3, 0)
    CreateTooltipTwo(friendlyHealthBarColorNpc, "Color Npcs", "Color friendly npc healthbars.")

    local alwaysHideFriendlyCastbar = CreateCheckbox("alwaysHideFriendlyCastbar", "Hide castbar", BetterBlizzPlates)
    alwaysHideFriendlyCastbar:SetPoint("TOPLEFT", friendlyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(alwaysHideFriendlyCastbar, "Hide Friendly Castbar", "Always hide Friendly castbars.")
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
    friendlyHealthBarColorButton:SetText("Color")
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

    BBP.friendlyHideHealthBar = CreateCheckbox("friendlyHideHealthBar", "Hide healthbar", BetterBlizzPlates)
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

    CreateTooltipTwo(BBP.friendlyHideHealthBar, "Hide Healthbar", "Hide healthbars on Friendly nameplates.", "Castbar and name will still show.\nThis also hides healthbars in PvE, if you don't want that behaviour then check the setting in Misc.")

    BBP.friendlyHideHealthBarNpc = CreateCheckbox("friendlyHideHealthBarNpc", "NPC's", BetterBlizzPlates)
    BBP.friendlyHideHealthBarNpc:SetPoint("LEFT", BBP.friendlyHideHealthBar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(BBP.friendlyHideHealthBarNpc, "Hide NPC Healthbar", "Hide healthbars on Friendly NPC's", "Castbar and name will still show.")

    BBP.friendlyHideHealthBarNpc:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not IsShiftKeyDown() then
                if not BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve then
                    BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve = true
                else
                    BetterBlizzPlatesDB.friendlyHideHealthBarNpcShowInPve = nil
                end
                StaticPopup_Show("BBP_CONFIRM_RELOAD")
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
    friendlyNpToggles:SetText("Toggles:")
    friendlyNpToggles:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", -20, -70)
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
    friendlyNameScale:SetPoint("TOPLEFT", alwaysHideFriendlyCastbar, "BOTTOMLEFT", 0, -6)
    CreateTooltipTwo(friendlyNameScale, "Name Size", "Change Name size on Friendly nameplates.", "Note: This changes the scale of the name, not the font size itself and means this scale wont be active in PvE.\n\nHowever there is a setting in Misc to tweak the default font size setting and you can use that as a baseline for PvE name size and keep this slider at 1 and tweak the Enemy Size slider from there since thats allowed in PvE.\n\nIt was made this way to support different size names on Friendly vs Enemy but will eventually be reworked with new API available now.")

    local hideNameTooltip = "Hide Name on Friendly nameplates."
    if BetterBlizzPlatesDB.partyPointerHideAll then
        hideNameTooltip = "Hide Name on Friendly nameplates.\n\n|cff00c0ffParty Pointer|r: Hide All setting is enabled which affects this setting.\nInfo in |cff32f795Advanced Settings|r."
    end
    local hideFriendlyNameText = CreateCheckbox("hideFriendlyNameText", "Hide name", BetterBlizzPlates)
    hideFriendlyNameText:SetPoint("LEFT", friendlyNameScale, "RIGHT", 2, 0)
    CreateTooltipTwo(hideFriendlyNameText, "Hide Name", hideNameTooltip)
    BBP.hideFriendlyNameText = hideFriendlyNameText

    local nameplateFriendlyWidth = CreateSlider(BetterBlizzPlates, "Nameplate Width", 24, 300, 1, "nameplateFriendlyWidth")
    nameplateFriendlyWidth:SetPoint("TOPLEFT", friendlyNameScale, "BOTTOMLEFT", 0, -20)
    CreateTooltipTwo(nameplateFriendlyWidth, "Friendly Nameplate Width", "Adjust the width of Friendly Nameplates.\n\nNote:\nBlizzard decided to remove the API to control different widths for Friendly/Enemy Nameplates in Midnight.\n\nBecause of this, since Friendly nameplates are restricted in PvE and cannot be changed much by addons, the nameplate width in PvE will be forced to be the same as Enemy Nameplates. |cff00c0ff#Blizzard")

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
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 390, -102)
    extraFeaturesText:SetText("Extra Features")
    local extraFeaturesIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)
    CreateTooltipTwo(extraFeaturesText, "Extra Features |A:Campaign-QuestLog-LoreBook:18:18|a", "Various extra features to add to nameplates.\nCustomize each in the |cff32f795Advanced Settings|r section.")
    CreateTooltipTwo(extraFeaturesIcon, "Extra Features |A:Campaign-QuestLog-LoreBook:18:18|a", "Various extra features to add to nameplates.\nCustomize each in the |cff32f795Advanced Settings|r section.")

    local testAllEnabledFeatures = CreateCheckbox("testAllEnabledFeatures", "Test", BetterBlizzPlates, nil, BBP.TestAllEnabledFeatures)
    testAllEnabledFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
    CreateTooltipTwo(testAllEnabledFeatures, "Test all features", "Test all enabled features.", "Check |cff32f795Advanced Settings|r for more settings for each individual feature.")

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

    local bgIndicator = CreateCheckbox("bgIndicator", "Blitz indicator", BetterBlizzPlates)
    bgIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(bgIndicator, "Blitz Indicator |A:Ping_Chat_Assist:18:18|a", "Show a big flag/orb on top of carriers in Battlegrounds.")
    local bgIcon = bgIndicator:CreateTexture(nil, "ARTWORK")
    bgIcon:SetAtlas("Ping_Chat_Assist")
    bgIcon:SetSize(17, 17)
    bgIcon:SetPoint("RIGHT", bgIndicator, "LEFT", 1, 0)

    local classIndicator = CreateCheckbox("classIndicator", "Class indicator", BetterBlizzPlates)
    classIndicator:SetPoint("TOPLEFT", bgIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classIndicator, "Class Indicator |A:groupfinder-icon-class-mage:16:16|a", "Show class/spec/role icon on nameplates and hides the default raidmarker. Also shows Battleground objectives like flag/orbs.\n\nGreat combined with \"Hide healthbar\" for Friendly Nameplates.", "With default settings BG Objectives will still show on nameplates regardless of your friendly/enemy preference. This can all be tuned in Advanced Settings.\nYou could even disable Class Indicator on both and have it show only BG Objectives.")
    local classIndicatorIcon = classIndicator:CreateTexture(nil, "ARTWORK")
    classIndicatorIcon:SetAtlas("groupfinder-icon-class-mage")
    classIndicatorIcon:SetSize(18, 18)
    classIndicatorIcon:SetPoint("RIGHT", classIndicator, "LEFT", 0, 0)

    local classIndicatorPinMode = CreateCheckbox("classIndicatorPinMode", "Pin Mode", classIndicator)
    classIndicatorPinMode:SetPoint("LEFT", classIndicator.text, "RIGHT", 0, 0)
    classIndicatorPinMode:HookScript("OnClick", function(self)
        BBP.ToggleClassIndicatorPinMode(self:GetChecked())
    end)
    CreateTooltipTwo(classIndicatorPinMode, "Class Indicator: Pin Mode |A:groupfinder-icon-class-mage:16:16|a", "Pin Mode displays the icon as a Pin and hides name, healthbar and castbar in the same go.", "These settings can all be toggled individually later in rest of the GUI.")

    classIndicator:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        BBP.RefreshAllNameplateAuras()
        if InCombatLockdown() then return end
        if self:GetChecked() then
            C_CVar.SetCVar("nameplateShowFriendlyPlayers", "1")
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
    CreateTooltipTwo(executeIndicator, "Execute Indicator |A:islands-azeriteboss:24:24|a", "Starts tracking health percentage once target dips below a certain percentage (40% by default).")
    local executeIndicatorIcon = executeIndicator:CreateTexture(nil, "ARTWORK")
    executeIndicatorIcon:SetAtlas("islands-azeriteboss")
    executeIndicatorIcon:SetSize(28, 30)
    executeIndicatorIcon:SetPoint("RIGHT", executeIndicator, "LEFT", 4, 1)

    local factionIndicator = CreateCheckbox("factionIndicator", "Faction indicator", BetterBlizzPlates, nil, BBP.ToggleFactionIndicator)
    factionIndicator:SetPoint("TOPLEFT", executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(factionIndicator, "Faction Indicator |A:questlog-questtypeicon-alliance:21:21|a", "Show a faction icon on nameplates.", "Enabled only in World PvP Zones by default but more settings in the Advanced Settings section.")
    local factionIndicatorIcon = factionIndicator:CreateTexture(nil, "ARTWORK")
    factionIndicatorIcon:SetAtlas("questlog-questtypeicon-alliance")
    factionIndicatorIcon:SetSize(21, 21)
    factionIndicatorIcon:SetPoint("RIGHT", factionIndicator, "LEFT", 0, 0)

    local healerIndicator = CreateCheckbox("healerIndicator", "Healer indicator", BetterBlizzPlates)
    healerIndicator:SetPoint("TOPLEFT", factionIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(healerIndicator, "Healer Indicator |A:greencross:21:21|a", "Show a cross on healers.", "Note: Party Pointer and Class Indicator both have their own Healer Icon settings. This is a separate icon entirely.")
    local healerCrossIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    healerCrossIcon:SetAtlas("greencross")
    healerCrossIcon:SetSize(21, 21)
    healerCrossIcon:SetPoint("RIGHT", healerIndicator, "LEFT", 0, 0)

    local partyPointer = CreateCheckbox("partyPointer", "Party pointer", BetterBlizzPlates)
    partyPointer:SetPoint("TOPLEFT", healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    partyPointer:HookScript("OnClick", function(self)
        BBP.RefreshAllNameplateAuras()
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
            C_CVar.SetCVar("nameplateShowFriendlyPlayers", "1")
        end
    end)
    CreateTooltipTwo(partyPointer, "Party Pointer |A:UI-QuestPoiImportant-QuestNumber-SuperTracked:21:16|a", "Show a class colored pointer above friendly player nameplates.", "Hides default raidmarkers. Only shows in Arena by default or during testing. Can show extra + sign on healers in settings.")
    local partyPointerIcon = partyPointer:CreateTexture(nil, "ARTWORK")
    partyPointerIcon:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
    partyPointerIcon:SetSize(16, 20)
    partyPointerIcon:SetPoint("RIGHT", partyPointer, "LEFT", -2.5, 1.5)
    partyPointerIcon:SetDesaturated(true)
    partyPointerIcon:SetVertexColor(0.04, 0.76, 1)

    local petIndicator = CreateCheckbox("petIndicator", "Pet indicator", BetterBlizzPlates)
    petIndicator:SetPoint("TOPLEFT", partyPointer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(petIndicator, "Show a murloc on the main hunter pet")
    CreateTooltipTwo(petIndicator, "Pet Indicator |A:newplayerchat-chaticon-newcomer:18:18|a", "Show a murloc on the main hunter and demo warlock pet. Also hides secondary pets.")
    local petIndicatorIcon = petIndicator:CreateTexture(nil, "ARTWORK")
    petIndicatorIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicatorIcon:SetSize(18, 18)
    petIndicatorIcon:SetPoint("RIGHT", petIndicator, "LEFT", -1, 0)

    local targetIndicator = CreateCheckbox("targetIndicator", "Target indicator", BetterBlizzPlates)
    targetIndicator:SetPoint("TOPLEFT", petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetIndicator, "Target Indicator |A:Navigation-Tracked-Arrow:14:19|a", "Show a pointer on your current target.\n\nCan also change Target Color/Texture in Advanced Settings.")
    local targetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    targetIndicatorIcon:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicatorIcon:SetRotation(math.rad(180))
    targetIndicatorIcon:SetSize(19, 14)
    targetIndicatorIcon:SetPoint("RIGHT", targetIndicator, "LEFT", -1, 0)

    local focusTargetIndicator = CreateCheckbox("focusTargetIndicator", "Focus target indicator", BetterBlizzPlates)
    focusTargetIndicator:SetPoint("TOPLEFT", targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicator, "Show a marker on the focus nameplate")
    CreateTooltipTwo(focusTargetIndicator, "Focus Target Indicator |A:Waypoint-MapPin-Untracked:19:19|a", "Show a marker on your focus nameplate.\n\nCan also change Focus Color/Texture in Advanced Settings.")
    local focusTargetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    focusTargetIndicatorIcon:SetAtlas("Waypoint-MapPin-Untracked")
    focusTargetIndicatorIcon:SetSize(19, 19)
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

    CreateTooltipTwo(totemIndicator, "Totem Indicator |A:teleportationnetwork-ardenweald-32x32:17:17|a", "Show icon on and color Totem nameplates.\n\nIn Midnight only Grounding and Capacitor are shown as important (due to restrictions), other totems will just show as a default \"totem icon & color\" if enabled in Advanced Settings.\n\nIt also expects you to only have Pet and Totem Nameplates enabled in CVar Control section.")
    local totemsIcon = totemIndicator:CreateTexture(nil, "ARTWORK")
    totemsIcon:SetAtlas("teleportationnetwork-ardenweald-32x32")
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
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -373)
    customFontandTextureText:SetText("Font and texture")
    local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    customFontandTextureIcon:SetAtlas("barbershop-32x32")
    customFontandTextureIcon:SetSize(24, 24)
    customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

    local useCustomFont = CreateCheckbox("useCustomFont", "Change the nameplate font", BetterBlizzPlates)
    useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltipTwo(useCustomFont, "Custom Font", "Change the nameplate font.", "If you want to completely skip nameplate font adjustment there is a setting in the Misc section for that")

    local useDefaultBlizzardOutline = CreateCheckbox("disableDefaultBlizzardOutline", "Disable Outline", BetterBlizzPlates)
    useDefaultBlizzardOutline:SetPoint("LEFT", useCustomFont.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(useDefaultBlizzardOutline, "Disable Default Blizzard Outline", "Disable the new default font outline on nameplate text in Midnight.\n\nThis setting is irrelevant if you have Custom Font enabled, use the Outline setting below for that.")

    local useCustomTexture = CreateCheckbox("useCustomTextureForBars", "Change the nameplate texture", BetterBlizzPlates)
    useCustomTexture:SetPoint("TOPLEFT", useCustomFont, "BOTTOMLEFT", 0, -23)
    CreateTooltipTwo(useCustomTexture, "Custom Texture", "Change the nameplate texture.")

    local fontDropdown = CreateFontDropdown(
        "fontDropdown",
        useCustomFont,
        "Select Font",
        "customFont",
        function(arg1)
            BBP.RefreshAllNameplates()
            BBP.TexturePRD()
        end,
        { anchorFrame = useCustomFont, x = 20, y = 1, label = "Font" }
    )

    if not useCustomFont:GetChecked() then
        fontDropdown:Disable()
    else
        DisableElement(useDefaultBlizzardOutline)
    end

    local enableCustomFontOutline = CreateCheckbox("enableCustomFontOutline", "Outline", useCustomFont)
    enableCustomFontOutline:SetPoint("LEFT", fontDropdown, "RIGHT", 0, 0)
    CreateTooltipTwo(enableCustomFontOutline, "Font Outline", "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.\n|cff87ceebShift+Right-click to toggle font shadow.")

    enableCustomFontOutline:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then
                -- Toggle Font Shadow
                BetterBlizzPlatesDB["customFontShadowOff"] = not BetterBlizzPlatesDB["customFontShadowOff"]
                local shadowState = BetterBlizzPlatesDB["customFontShadowOff"] and "Disabled" or "Enabled"
                RefreshTooltip(enableCustomFontOutline, "Font Outline",
                    "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.\nCurrent: " ..
                    (BetterBlizzPlatesDB["customFontOutline"] == "THICKOUTLINE" and "Thick Outline" or "Thin Outline") ..
                    "\n|cff87ceebShift+Right-click to toggle font shadow.\nCurrent: " .. shadowState)
            else
                -- Swap Between Thick and Thin Outline
                local currentOutline = BetterBlizzPlatesDB["customFontOutline"]
                if currentOutline == "THINOUTLINE" then
                    BetterBlizzPlatesDB["customFontOutline"] = "THICKOUTLINE"
                    RefreshTooltip(enableCustomFontOutline, "Font Outline",
                        "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.\nCurrent: Thick Outline" ..
                        "\n|cff87ceebShift+Right-click to toggle font shadow.\nCurrent: " ..
                        (BetterBlizzPlatesDB["customFontShadowOff"] and "Disabled" or "Enabled"))
                else
                    BetterBlizzPlatesDB["customFontOutline"] = "THINOUTLINE"
                    RefreshTooltip(enableCustomFontOutline, "Font Outline",
                        "Enable font outline.\n|cff32f795Right-click to swap between thick and thin outline.\nCurrent: Thin Outline" ..
                        "\n|cff87ceebShift+Right-click to toggle font shadow.\nCurrent: " ..
                        (BetterBlizzPlatesDB["customFontShadowOff"] and "Disabled" or "Enabled"))
                end
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
        { anchorFrame = useCustomTexture, x = 20, y = 1, label = "Texture" }
    )

    local textureDropdownFriendly = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        "Select Texture",
        "customTextureFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = -27, label = "Friendly" }
    )

    local textureDropdownSelf = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        "Select Texture",
        "customTextureSelf",
        function(arg1)
            BBP.TexturePRD()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = -55, label = "Personal" }
    )

    local textureDropdownSelfMana = CreateTextureDropdown(
        "textureDropdownFriendly",
        useCustomTexture,
        "Select Texture",
        "customTextureSelfMana",
        function(arg1)
            BBP.TexturePRD()
        end,
        { anchorFrame = useCustomTexture, x = 20, y = -83, label = "Personal Mana" }
    )

    local useCustomTextureForEnemy = CreateCheckbox("useCustomTextureForEnemy", "Enemy", useCustomTexture)
    useCustomTextureForEnemy:SetPoint("LEFT", textureDropdown, "RIGHT", 0, 0)
    useCustomTextureForEnemy.text:SetTextColor(1,0,0)
    useCustomTextureForEnemy:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdown:Enable()
        else
            textureDropdown:Disable()
        end
    end)
    CreateTooltipTwo(useCustomTextureForEnemy, "Enemy Texture", "Change Enemy healthbar texture.", nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForEnemy:GetChecked() then
        textureDropdown:Disable()
    end

    local useCustomTextureForExtraBars = CreateCheckbox("useCustomTextureForExtraBars", "Overbars", useCustomTexture)
    useCustomTextureForExtraBars:SetPoint("BOTTOMLEFT", useCustomTextureForEnemy, "TOPLEFT", 0, -3)
    CreateTooltipTwo(useCustomTextureForExtraBars, "Change Overbars Texture", "Also change the texture for nameplate absorbs & overhealing etc.")

    local useCustomTextureForFriendly = CreateCheckbox("useCustomTextureForFriendly", "Friendly", useCustomTexture)
    useCustomTextureForFriendly:SetPoint("LEFT", textureDropdownFriendly, "RIGHT", 0, 0)
    useCustomTextureForFriendly.text:SetTextColor(0.04, 0.76, 1)
    useCustomTextureForFriendly:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownFriendly:Enable()
        else
            textureDropdownFriendly:Disable()
        end
    end)
    CreateTooltipTwo(useCustomTextureForFriendly, "Friendly Texture", "Change Friendly healthbar texture.", nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForFriendly:GetChecked() then
        textureDropdownFriendly:Disable()
    end

    local useCustomTextureForSelf = CreateCheckbox("useCustomTextureForSelf", "Self", useCustomTexture)
    useCustomTextureForSelf:SetPoint("LEFT", textureDropdownSelf, "RIGHT", 0, 0)
    useCustomTextureForSelf:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownSelf:Enable()
        else
            textureDropdownSelf:Disable()
        end
        BBP.TexturePRD()
    end)
    CreateTooltipTwo(useCustomTextureForSelf, "Personal Texture", "Change Personal resource healthbar texture.", nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForSelf:GetChecked() then
        textureDropdownSelf:Disable()
    end

    local useCustomTextureForSelfMana = CreateCheckbox("useCustomTextureForSelfMana", "Self Mana", useCustomTexture)
    useCustomTextureForSelfMana:SetPoint("LEFT", textureDropdownSelfMana, "RIGHT", 0, 0)
    useCustomTextureForSelfMana:HookScript("OnClick", function(self)
        if self:GetChecked() then
            textureDropdownSelfMana:Enable()
        else
            textureDropdownSelfMana:Disable()
        end
        BBP.TexturePRD()
    end)
    CreateTooltipTwo(useCustomTextureForSelfMana, "Personal Mana/Resource Texture", "Change Personal Resource mana/resource-bar texture", nil, "ANCHOR_LEFT")
    if not useCustomTexture:GetChecked() or not useCustomTextureForSelfMana:GetChecked() then
        textureDropdownSelfMana:Disable()
    end

    local function SetClassAndPowerColor()
        -- Retrieve the player's class information
        local _, class = UnitClass("player")
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
    arenaSettingsText:SetText("Arena Names")
    local arenaSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    arenaSettingsIcon:SetAtlas("pvptalents-warmode-swords")
    arenaSettingsIcon:SetSize(20, 20)
    arenaSettingsIcon:SetPoint("RIGHT", arenaSettingsText, "LEFT", -3, 0)
    CreateTooltipTwo(arenaSettingsText, "Arena ID/Spec Name", "Replace names in arena to their arena ID or their specialization", "More settings in \"Advanced Settings\" section.", "ANCHOR_LEFT")

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
    CreateTooltipTwo(arenaModeDropdown, "Arena ID/Spec Name", "Replace names in arena to their arena ID or their specialization", "More settings in \"Advanced Settings\" section.", "ANCHOR_LEFT")

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", "Short", BetterBlizzPlates)
    shortArenaSpecName:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)
    CreateTooltipTwo(shortArenaSpecName, "Short Spec Names", "Enable to use abbreviated specialization names. For instance, \"Assassination\" will be displayed as \"Assa\".", nil, "ANCHOR_LEFT")

    local healerSpecNameOnly = CreateCheckbox("healerSpecNameOnly", "Heal", BetterBlizzPlates)
    healerSpecNameOnly:SetPoint("LEFT", shortArenaSpecName.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(healerSpecNameOnly, "Healer Spec Only", "Only show the spec name for healers. Other names will be blank.", nil, "ANCHOR_LEFT")

    local arenaIndicatorBg = CreateCheckbox("arenaIndicatorBg", "BG", BetterBlizzPlates)
    arenaIndicatorBg:SetPoint("LEFT", healerSpecNameOnly.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(arenaIndicatorBg, "Battleground Spec Names", "Show spec names on enemy nameplates in Battlegrounds", nil, "ANCHOR_LEFT")

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
    CreateTooltipTwo(partyModeDropdown, "Arena ID/Spec Name", "Replace names in arena to their arena ID or their specialization", "More settings in \"Advanced Settings\" section.", "ANCHOR_LEFT")

    local partyIDScale = CreateSlider(BetterBlizzPlates, "Party ID Size", 0.5, 4, 0.01, "partyIDScale")
    partyIDScale:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltipTwo(partyIDScale, "Arena ID Size", "Size of the friendly party ID text on top of nameplate during arena.")

    local partySpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.01, "partySpecScale")
    partySpecScale:SetPoint("TOPLEFT", partyIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltipTwo(partySpecScale, "Arena Spec Size", "Size of the friendly spec name text on top of nameplate during arena.")

    local btnGap = -1
    local lastCoreButton = profilesFrame.coreText
    local lastStreamerButton = profilesFrame.streamerText

    for _, profile in ipairs(BBP.ProfileData) do
        local additionalNote = profile.name == "Starter" and "|cff808080(If you want to completely reset BBP there\nis a button in Advanced Settings)|r\n\n" or nil
        local button = CreateClassButton(BetterBlizzPlates, profile.class, profile.name, profile.twitchName, function()
            ShowProfileConfirmation(profile.name, profile.class, function() BBP.ApplyProfile(profile.name) end, additionalNote)
        end, profile.youtubeName)
        if profile.core then
            button:SetPoint("TOP", lastCoreButton, "BOTTOM", 0, lastCoreButton == profilesFrame.coreText and -3 or btnGap)
            lastCoreButton = button
        else
            button:SetPoint("TOP", lastStreamerButton, "BOTTOM", 0, lastStreamerButton == profilesFrame.streamerText and -3 or btnGap)
            lastStreamerButton = button
        end
    end

    local resetBBPButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    resetBBPButton:SetText("Full Reset")
    resetBBPButton:SetWidth(104)
    resetBBPButton:SetPoint("BOTTOM", profilesFrame, "BOTTOM", 2, 10)
    resetBBPButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZPLATESDB")
    end)
    CreateTooltip(resetBBPButton, "Reset ALL BetterBlizzPlates settings.", "ANCHOR_TOP")




    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
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
    local sixthLineY = -1640

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
    healerIndicatorEnemyOnly2:SetPoint("LEFT", healerIndicatorTestMode2.text, "RIGHT", 0, 0)

    local healerIndicatorArenaOnly = CreateCheckbox("healerIndicatorArenaOnly", "Arena only", contentFrame)
    healerIndicatorArenaOnly:SetPoint("TOPLEFT", healerIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorBgOnly = CreateCheckbox("healerIndicatorBgOnly", "Battleground only", contentFrame)
    healerIndicatorBgOnly:SetPoint("TOPLEFT", healerIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorRedCrossEnemy = CreateCheckbox("healerIndicatorRedCrossEnemy", "Red Cross for Enemy", contentFrame)
    healerIndicatorRedCrossEnemy:SetPoint("TOPLEFT", healerIndicatorBgOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    anchorSubHeal.healerIndicatorColorEnemyHealthbar = CreateCheckbox("healerIndicatorColorEnemyHealthbar", "Color Enemy Healer HP", contentFrame)
    anchorSubHeal.healerIndicatorColorEnemyHealthbar:SetPoint("TOPLEFT", healerIndicatorRedCrossEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHeal.healerIndicatorColorEnemyHealthbar, "Color Enemy Healer Healthbar", "Color the healthbar of enemy healers.\n\n|cff32f795Right-click to change color.|r")

    anchorSubHeal.healerIndicatorColorFriendlyHealthbar = CreateCheckbox("healerIndicatorColorFriendlyHealthbar", "Color Friendly Healer HP", contentFrame)
    anchorSubHeal.healerIndicatorColorFriendlyHealthbar:SetPoint("TOPLEFT", anchorSubHeal.healerIndicatorColorEnemyHealthbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHeal.healerIndicatorColorFriendlyHealthbar, "Color Friendly Healer Healthbar", "Color the healthbar of friendly healers.\n\n|cff32f795Right-click to change color.|r")

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

    ----------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubOutOfCombat:SetText("Combat Indicator")

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

    ----------------------
    -- Hunter pet icon
    ----------------------
    local anchorSubPet = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPet:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, secondLineY)
    anchorSubPet:SetText("Pet Indicator")

    CreateBorderBox(anchorSubPet)

    local petIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    petIndicator2:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicator2:SetSize(36, 36)
    petIndicator2:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

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

    local absorbIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator2:SetAtlas("ParagonReputation_Glow")
    absorbIndicator2:SetSize(51, 51)
    absorbIndicator2:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

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
    -- Faction Indicator
    ----------------------
    local anchorSubFaction = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFaction:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, thirdLineY)
    anchorSubFaction:SetText("Faction Indicator")

    CreateBorderBox(anchorSubFaction)

    anchorSubFaction.factionIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFaction.factionIcon2:SetAtlas("questlog-questtypeicon-alliance")
    anchorSubFaction.factionIcon2:SetSize(34, 34)
    anchorSubFaction.factionIcon2:SetPoint("BOTTOM", anchorSubFaction, "TOP", 0, 0)

    anchorSubFaction.factionIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 3, 0.01, "factionIndicatorScale")
    anchorSubFaction.factionIndicatorScale:SetPoint("TOP", anchorSubFaction, "BOTTOM", 0, -15)

    anchorSubFaction.factionIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "factionIndicatorXPos", "X")
    anchorSubFaction.factionIndicatorXPos:SetPoint("TOP", anchorSubFaction.factionIndicatorScale, "BOTTOM", 0, -15)

    anchorSubFaction.factionIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "factionIndicatorYPos", "Y")
    anchorSubFaction.factionIndicatorYPos:SetPoint("TOP", anchorSubFaction.factionIndicatorXPos, "BOTTOM", 0, -15)

    anchorSubFaction.factionIndicatorDropdown = CreateAnchorDropdown(
        "factionIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "factionIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubFaction.factionIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    -- Icon Set dropdown
    anchorSubFaction.factionIconSetNames = {
        [1]  = "Quest Log Icons",
        [2]  = "UnitFrame Icons",
        [3]  = "PVP Banners",
        [4]  = "BFA Landing Buttons",
        [5]  = "Talent Tree Logos",
        [6]  = "CTF Flags",
        [7]  = "Quest Portrait Icons",
        [8]  = "Quest Portrait (Small)",
        [9]  = "Character Create Icons",
        [10] = "Character Create (Small)",
        [11] = "Warfront Armory Icons",
        [12] = "Wax Seals",
    }

    anchorSubFaction.factionIconSetDropdown = LibDD:Create_UIDropDownMenu("factionIconSetDropdown", contentFrame)
    LibDD:UIDropDownMenu_SetWidth(anchorSubFaction.factionIconSetDropdown, 125)
    local currentSet = BetterBlizzPlatesDB.factionIndicatorIconSet or 1
    LibDD:UIDropDownMenu_SetText(anchorSubFaction.factionIconSetDropdown, anchorSubFaction.factionIconSetNames[currentSet] or "Quest Log Icons")

    LibDD:UIDropDownMenu_Initialize(anchorSubFaction.factionIconSetDropdown, function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        for i = 1, 12 do
            info.text = anchorSubFaction.factionIconSetNames[i]
            info.arg1 = i
            info.func = function(self, arg1)
                BetterBlizzPlatesDB.factionIndicatorIconSet = arg1
                LibDD:UIDropDownMenu_SetText(anchorSubFaction.factionIconSetDropdown, anchorSubFaction.factionIconSetNames[arg1])
                BBP.needsUpdate = true
                BBP.RefreshAllNameplates()
            end
            info.checked = (BetterBlizzPlatesDB.factionIndicatorIconSet == i)
            LibDD:UIDropDownMenu_AddButton(info)
        end
    end)

    anchorSubFaction.factionIconSetDropdown:SetPoint("TOPLEFT", anchorSubFaction.factionIndicatorDropdown, "TOPLEFT", 0, -43)

    anchorSubFaction.factionIconSetLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFaction.factionIconSetLabel:SetPoint("BOTTOM", anchorSubFaction.factionIconSetDropdown, "TOP", 0, 3)
    anchorSubFaction.factionIconSetLabel:SetText("Icon Set")

    anchorSubFaction.factionIndicatorTestMode2 = CreateCheckbox("factionIndicatorTestMode", "Test", contentFrame)
    anchorSubFaction.factionIndicatorTestMode2:SetPoint("TOPLEFT", anchorSubFaction.factionIconSetDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    anchorSubFaction.factionIndicatorEnemy = CreateCheckbox("factionIndicatorEnemy", "Enemy", contentFrame)
    anchorSubFaction.factionIndicatorEnemy:SetPoint("TOPLEFT", anchorSubFaction.factionIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorEnemy, "Show on Enemies", "Show the faction icon on players of the opposing faction.")

    anchorSubFaction.factionIndicatorFriendly = CreateCheckbox("factionIndicatorFriendly", "Friendly", contentFrame)
    anchorSubFaction.factionIndicatorFriendly:SetPoint("LEFT", anchorSubFaction.factionIndicatorEnemy.text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorFriendly, "Show on Friendly", "Show the faction icon on players of your own faction.")

    anchorSubFaction.factionIndicatorOnlyWorld = CreateCheckbox("factionIndicatorOnlyWorld", "World only", contentFrame)
    anchorSubFaction.factionIndicatorOnlyWorld:SetPoint("TOPLEFT", anchorSubFaction.factionIndicatorEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorOnlyWorld, "World Only", "Only show the faction icon in the open world.")
    anchorSubFaction.factionIndicatorOnlyWorld:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.factionIndicatorOnlyPvPZone = false
            anchorSubFaction.factionIndicatorOnlyPvPZone:SetChecked(false)
        end
    end)

    anchorSubFaction.factionIndicatorHostileOnly = CreateCheckbox("factionIndicatorHostileOnly", "Hostile only", contentFrame)
    anchorSubFaction.factionIndicatorHostileOnly:SetPoint("LEFT", anchorSubFaction.factionIndicatorOnlyWorld.text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorHostileOnly, "Hostile Only", "Only enable on hostile nameplates. Nameplates you can attack, regardless of faction.")

    anchorSubFaction.factionIndicatorOnlyPvPZone = CreateCheckbox("factionIndicatorOnlyPvPZone", "PvP (FFA) only", contentFrame)
    anchorSubFaction.factionIndicatorOnlyPvPZone:SetPoint("LEFT", anchorSubFaction.factionIndicatorTestMode2.text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubFaction.factionIndicatorOnlyPvPZone, "PvP Zone Only", "Only show the faction icon in PvP zones. (Free-For-All in the open world)")
    anchorSubFaction.factionIndicatorOnlyPvPZone:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.factionIndicatorOnlyWorld = false
            anchorSubFaction.factionIndicatorOnlyWorld:SetChecked(false)
        end
    end)

    ----------------------
    -- Target indicator
    ----------------------
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubTarget:SetText("Target Indicator")

    CreateBorderBox(anchorSubTarget)

    anchorSubTarget.icon = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubTarget.icon:SetAtlas("Navigation-Tracked-Arrow")
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
        { anchorFrame = targetIndicatorChangeTexture, x = 3, y = 3, label = "Texture" },
        138
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

    anchorSubRaidmark.box4 = CreateCheckbox("raidmarkIndicatorRaiseStrata", "Raise Strata", contentFrame)
    anchorSubRaidmark.box4:SetPoint("TOPLEFT", anchorSubRaidmark.box3, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubRaidmark.box4, "Raise Strata", "Raise strata of Raidmark to it appears above healthbar.")

    anchorSubRaidmark.box5 = CreateCheckbox("raidmarkIndicatorFullAlpha", "Always Full Alpha", contentFrame)
    anchorSubRaidmark.box5:SetPoint("TOPLEFT", anchorSubRaidmark.box4, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubRaidmark.box5, "Always Full Alpha", "Always display the Raid Marker at full opacity, regardless of the nameplate's alpha.")


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

    anchorSubquest.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubquest.t:SetAtlas("smallquestbang")
    anchorSubquest.t:SetSize(44, 44)
    anchorSubquest.t:SetPoint("BOTTOM", anchorSubquest, "TOP", 0, -3)

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

    anchorSubquest.questIndicatorColorNpc = CreateCheckbox("questIndicatorColorNpc", "Color NPC", contentFrame)
    anchorSubquest.questIndicatorColorNpc:SetPoint("TOPLEFT", questTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubquest.questIndicatorColorNpc, "Color Quest NPC", "Color the healthbar of quest NPCs.\n\n|cff32f795Right-click to change color.|r")

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
    anchorSubFocus:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, secondLineY)
    anchorSubFocus:SetText("Focus Target Indicator")

    CreateBorderBox(anchorSubFocus)

    anchorSubFocus.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubFocus.t:SetAtlas("Waypoint-MapPin-Untracked")
    anchorSubFocus.t:SetSize(40, 40)
    anchorSubFocus.t:SetPoint("BOTTOM", anchorSubFocus, "TOP", 0, -2)

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
    CreateTooltipTwo(focusTargetIndicatorColorNameplate, "Color Focus Nameplate Healthbar", "Color the Focus Nameplate Healthbar.")
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
        { anchorFrame = focusTargetIndicatorChangeTexture, x = 3, y = 3, label = "Texture" },
        138
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
    anchorSubExecute.t:SetAtlas("islands-azeriteboss")
    anchorSubExecute.t:SetSize(56, 60)
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

    anchorSubExecute.executeIndicatorInRangeColor = CreateCheckbox("executeIndicatorInRangeColor", "C", contentFrame)
    anchorSubExecute.executeIndicatorInRangeColor:SetPoint("LEFT", executeTestIcons2.text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorInRangeColor, "Color healthbar", "Color healthbar when in execute range.\n\nRight-click to change color.")

    anchorSubExecute.executeIndicatorInRangeColor:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.executeIndicatorInRangeColorRGB, BBP.RefreshAllNameplates)
        end
    end)

    local executeIndicatorAlwaysOn = CreateCheckbox("executeIndicatorAlwaysOn", "Always on", contentFrame)
    executeIndicatorAlwaysOn:SetPoint("TOPLEFT", executeTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorAlwaysOn, "Always display health percentage")

    local executeIndicatorFriendly = CreateCheckbox("executeIndicatorFriendly", "Friendly", contentFrame)
    executeIndicatorFriendly:SetPoint("TOPLEFT", executeIndicatorAlwaysOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorFriendly, "Show on friendly nameplates")

    anchorSubExecute.executeIndicatorUseTexture = CreateCheckbox("executeIndicatorUseTexture", "Use Texture", contentFrame)
    anchorSubExecute.executeIndicatorUseTexture:SetPoint("TOPLEFT", executeIndicatorFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubExecute.executeIndicatorUseTexture, "Use Texture", "Show a line on execute range instead of text.")

    local executeIndicatorHideText = CreateCheckbox("executeIndicatorHideText", "Hide text", contentFrame)
    executeIndicatorHideText:SetPoint("TOPLEFT", anchorSubExecute.executeIndicatorUseTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(executeIndicatorHideText, "Hide Text", "Hide percentage text (If you only want to color)")
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
    anchorSubArena:SetText("Arena Names")

    CreateBorderBox(anchorSubArena)

    anchorSubArena.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubArena.t:SetAtlas("pvptalents-warmode-swords")
    anchorSubArena.t:SetSize(30, 30)
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

    anchorSubArena.arenaIdAnchorRaiseStrata = CreateCheckbox("arenaIdAnchorRaiseStrata", "Raise Strata", contentFrame)
    anchorSubArena.arenaIdAnchorRaiseStrata:SetPoint("LEFT", arenaIndicatorTestMode2.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubArena.arenaIdAnchorRaiseStrata, "Raise Strata for Arena ID", "Raises the strata of the Arena ID/Spec so it shows on top of (z-axis) healthbars etc.")
    anchorSubArena.arenaIdAnchorRaiseStrata:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)


    local showCircleOnArenaID = CreateCheckbox("showCircleOnArenaID", "Show Circle on ID", contentFrame)
    showCircleOnArenaID:SetPoint("TOPLEFT", arenaIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCircleOnArenaID, "Show a colored circle on each ID, red green and blue\n\n(Needs some finetuning still)")

    ----------------------
    -- Class Icon
    ----------------------
    local anchorSubClassIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubClassIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubClassIcon:SetText("Class Indicator")

    anchorSubClassIcon.border = CreateBorderBox(anchorSubClassIcon)

    anchorSubClassIcon.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubClassIcon.t:SetAtlas("groupfinder-icon-class-mage")
    anchorSubClassIcon.t:SetSize(33, 33)
    anchorSubClassIcon.t:SetPoint("BOTTOM", anchorSubClassIcon, "TOP", 0, 1.5)

    local classIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "classIndicatorFriendlyScale", false, 72)
    classIndicatorScale:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", 36, -15)
    classIndicatorScale.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(classIndicatorScale, "Friendly Scale")

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
    CreateTooltipTwo(classIndicatorEnemy, "Show on Enemy Nameplates", "Show Class Indicator on Enemy Nameplates", "More settings available to for example only show on Enemy Healers.")

    local classIndicatorFriendly = CreateCheckbox("classIndicatorFriendly", "Friendly", contentFrame)
    classIndicatorFriendly:SetPoint("LEFT", classIndicatorEnemy.text, "RIGHT", -2, 0)
    CreateTooltipTwo(classIndicatorFriendly, "Show on Friendly Nameplates", "Show Class Indicator on Friendly Nameplates.", "More settings available to for example only show on Friendly Healers.")

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

    anchorSubClassIcon.classIndicatorCCAuras = CreateCheckbox("classIndicatorCCAuras", "Show CC", contentFrame)
    anchorSubClassIcon.classIndicatorCCAuras:SetPoint("TOPLEFT", classIconArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorCCAuras, "Show Crowd Control", "Replace Class/Spec Icon with Icon of Crowd Control on Friendly Players.", "While this is on the nameplate's own crowd control (both the Big CC Icon and the debuff row) is left off every friendly plate that is actually showing the class icon, so the same icon is not shown twice.")
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

    anchorSubClassIcon.classIndicatorShowPet = CreateCheckbox("classIndicatorShowPet", "Pet", contentFrame)
    anchorSubClassIcon.classIndicatorShowPet:SetPoint("TOPLEFT", classIconBgOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorShowPet, "Show Pet", "Show icon on your pet as well.", "This setting requires \"Show Friendly Pets\" enabled in the CVar Control section.")
    anchorSubClassIcon.classIndicatorShowPet:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.RunAfterCombat(function()
                C_CVar.SetCVar("nameplateShowFriendlyPlayerPets", "1")
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Show Friendly Pets CVar toggled on for Pet Class Indicator to work. If you want to turn this back off go to /bbp -> CVar Control and uncheck it.")
            end)
        end
    end)

    anchorSubClassIcon.classIndicatorAlwaysShowPet = CreateCheckbox("classIndicatorAlwaysShowPet", "A", contentFrame)
    anchorSubClassIcon.classIndicatorAlwaysShowPet:SetPoint("LEFT", anchorSubClassIcon.classIndicatorShowPet.text, "RIGHT", 0, 5)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorAlwaysShowPet, "Show Pet: Always", "Always show the Class Indicator on your pet, disregarding \"Arena Only\" settings etc.", "This setting requires \"Show Friendly Pets\" enabled in the CVar Control section.")
    anchorSubClassIcon.classIndicatorAlwaysShowPet:SetSize(16,16)

    anchorSubClassIcon.partyPointerShowOthersPets = CreateCheckbox("partyPointerShowOthersPets", "O", contentFrame)
    anchorSubClassIcon.partyPointerShowOthersPets:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorAlwaysShowPet, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.partyPointerShowOthersPets, "Show on Pet: Others", "Show Class Indicator on other friendlys Pets in Arena.", "This setting requires \"Show Friendly Pets\" enabled in the CVar Control section.")
    anchorSubClassIcon.partyPointerShowOthersPets:SetSize(16,16)

    -- Extended Settings Button
    anchorSubClassIcon.extendedSettingsButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    anchorSubClassIcon.extendedSettingsButton:SetSize(120, 25)
    anchorSubClassIcon.extendedSettingsButton:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", 0, -224)
    anchorSubClassIcon.extendedSettingsButton:SetText("More options")
    CreateTooltip(anchorSubClassIcon.extendedSettingsButton, "Open more settings for Class Indicator")

    -- Extended Settings Frame
    anchorSubClassIcon.extendedSettings = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel, "DefaultPanelFlatTemplate")
    -- anchorSubClassIcon.extendedSettings:SetAllPoints(anchorSubClassIcon.border)
    anchorSubClassIcon.extendedSettings:SetSize(anchorSubClassIcon.border:GetHeight()+105, 500)
    anchorSubClassIcon.extendedSettings:SetPoint("BOTTOMRIGHT", anchorSubClassIcon.border, "BOTTOMLEFT", 87, -185)
    anchorSubClassIcon.extendedSettings:SetFrameStrata("DIALOG")
    anchorSubClassIcon.extendedSettings:SetIgnoreParentAlpha(true)
    anchorSubClassIcon.extendedSettings:Hide()
    anchorSubClassIcon.extendedSettings.name = "Advanced Settings"
    anchorSubClassIcon.extendedSettings:SetTitle("Class Indicator")
    anchorSubClassIcon.extendedSettings:EnableMouse(true)

    anchorSubClassIcon.closeButton = CreateFrame("Button", nil, anchorSubClassIcon.extendedSettings, "UIPanelCloseButton")
    anchorSubClassIcon.closeButton:SetPoint("TOPRIGHT", anchorSubClassIcon.extendedSettings, "TOPRIGHT", 0, 0)
    anchorSubClassIcon.closeButton:SetScript("OnClick", function()
        anchorSubClassIcon.extendedSettings:Hide()
        contentFrame:SetAlpha(1)
    end)

    anchorSubClassIcon.bg = anchorSubClassIcon.extendedSettings:CreateTexture(nil, "BACKGROUND")
    anchorSubClassIcon.bg:SetPoint("TOPLEFT", anchorSubClassIcon.extendedSettings, "TOPLEFT", 7, -3)
    anchorSubClassIcon.bg:SetPoint("BOTTOMRIGHT", anchorSubClassIcon.extendedSettings, "BOTTOMRIGHT", -3, 3)
    anchorSubClassIcon.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    anchorSubClassIcon.extendedSettingsButton:HookScript("OnClick", function(self)
        anchorSubClassIcon.extendedSettings:SetShown(not anchorSubClassIcon.extendedSettings:IsShown())
        contentFrame:SetAlpha(anchorSubClassIcon.extendedSettings:IsShown() and 0.5 or 1)
    end)

    local classIndicatorSpecIcon = CreateCheckbox("classIndicatorSpecIcon", "Show Spec Icon", anchorSubClassIcon.extendedSettings)
    classIndicatorSpecIcon:SetPoint("TOPLEFT", anchorSubClassIcon.extendedSettings, "TOPLEFT", 10, -23)
    CreateTooltip(classIndicatorSpecIcon, "Show spec instead of class icon.")

    anchorSubClassIcon.classIndicatorHideFriendlyHealthbar = CreateCheckbox("classIndicatorHideFriendlyHealthbar", "Hide Friendly Healthbar", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorHideFriendlyHealthbar:SetPoint("TOPLEFT", classIndicatorSpecIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorHideFriendlyHealthbar, "Hide Friendly Healthbar","Hide healthbar on friendly nameplates with Class Indicator showing on them.")

    anchorSubClassIcon.classIndicatorOnlyParty = CreateCheckbox("classIndicatorOnlyParty", "Only show on Party", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorOnlyParty:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorHideFriendlyHealthbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorOnlyParty, "Only show on Party", "Only show Class Indicator on people in your Party.")

    anchorSubClassIcon.classIndicatorOnlyFriends = CreateCheckbox("classIndicatorOnlyFriends", "Only show on Friends (Friendlist)", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorOnlyFriends:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorOnlyParty, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorOnlyFriends, "Only show on Friends (Friendlist)", "Only show Class Indicator on friends you have in your Friendlist and Guild mates.")

    anchorSubClassIcon.classIndicatorOnlyHealer = CreateCheckbox("classIndicatorOnlyHealer", "Only Show Healer", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorOnlyHealer:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorOnlyFriends, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anchorSubClassIcon.classIndicatorOnlyHealer, "Only show on Healers")

    local classIndicatorHealer = CreateCheckbox("classIndicatorHealer", "Show cross on Healer", anchorSubClassIcon.extendedSettings)
    classIndicatorHealer:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorOnlyHealer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorHealer, "Show cross instead of class/spec icon on Healers")

    anchorSubClassIcon.classIndicatorTank = CreateCheckbox("classIndicatorTank", "Show shield on Tank", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorTank:SetPoint("TOPLEFT", classIndicatorHealer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anchorSubClassIcon.classIndicatorTank, "Show shield instead of class/spec icon on Tanks")

    local classIconColorBorder = CreateCheckbox("classIconColorBorder", "Class color Border", anchorSubClassIcon.extendedSettings)
    classIconColorBorder:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorTank, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIconColorBorder, "Class color border.")

    anchorSubClassIcon.classIconReactionBorder = CreateCheckbox("classIconReactionBorder", "Reaction color Border", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIconReactionBorder:SetPoint("TOPLEFT", classIconColorBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anchorSubClassIcon.classIconReactionBorder, "Reaction color border. Red for Enemy and Green for Friendly.")

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

    anchorSubClassIcon.classIconAlwaysShowHealer = CreateCheckbox("classIconAlwaysShowHealer", "Always Show Healers", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIconAlwaysShowHealer:SetPoint("TOPLEFT", anchorSubClassIcon.classIconReactionBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIconAlwaysShowHealer, "Always Show Healers", "Always show Class Indicator on all Healer nameplates and disregard Enemy/Friendly setting.\n\nIf Arena/BG Only is enabled it will force enable on all Healer Nameplates in PvP but hide it in World.")

    anchorSubClassIcon.classIconAlwaysShowTank = CreateCheckbox("classIconAlwaysShowTank", "Always Show Tanks", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIconAlwaysShowTank:SetPoint("TOPLEFT", anchorSubClassIcon.classIconAlwaysShowHealer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIconAlwaysShowTank, "Always Show Tanks", "Always show Class Indicator on all Tank nameplates and disregard Enemy/Friendly setting.\n\nIf Arena/BG Only is enabled it will force enable on all Tank Nameplates in PvP but hide it in World.")

    anchorSubClassIcon.classIconAlwaysShowBgObj = CreateCheckbox("classIconAlwaysShowBgObj", "Always Show BG Objective", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIconAlwaysShowBgObj:SetPoint("TOPLEFT", anchorSubClassIcon.classIconAlwaysShowTank, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIconAlwaysShowBgObj, "Always Show BG Objective", "Always show Class Indicator on nameplates that are doing Battleground objectives and disregard your other settings.")

    anchorSubClassIcon.classIconHealthNumbers = CreateCheckbox("classIconHealthNumbers", "Show Health instead of Name", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIconHealthNumbers:SetPoint("TOPLEFT", anchorSubClassIcon.classIconAlwaysShowBgObj, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIconHealthNumbers, "Show Health instead of Name", "Show health percentage instead of name on people with Class Indicator showing.\n\nHealth Percentage will only be shown while in PvP.")
    anchorSubClassIcon.classIconHealthNumbers:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBP.SetupClassIndicatorHealthText()
        end
    end)

    anchorSubClassIcon.classIconEnemyHealIcon = CreateCheckbox("classIconEnemyHealIcon", "Change Enemy Healer Icon", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIconEnemyHealIcon:SetPoint("TOPLEFT", anchorSubClassIcon.classIconHealthNumbers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIconEnemyHealIcon, "Change Enemy Healer Icon", "Change enemy healer icon.\n\n|cff32f795Right-click to change between icon types for |cffff0000Enemy|r Healer.|r")

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

    local classIndicatorHighlight = CreateCheckbox("classIndicatorHighlight", "Highlight Target", anchorSubClassIcon.extendedSettings)
    classIndicatorHighlight:SetPoint("TOPLEFT", anchorSubClassIcon.classIconEnemyHealIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorHighlight, "Show highlight on current target icon")

    local classIndicatorHighlightColor = CreateCheckbox("classIndicatorHighlightColor", "Class color highlight", anchorSubClassIcon.extendedSettings)
    classIndicatorHighlightColor:SetPoint("TOPLEFT", classIndicatorHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorHighlightColor, "Class color target highlight")

    local classIndicatorHideRaidMarker = CreateCheckbox("classIndicatorHideRaidMarker", "Hide Raidmarker", anchorSubClassIcon.extendedSettings)
    classIndicatorHideRaidMarker:SetPoint("TOPLEFT", classIndicatorHighlightColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorHideRaidMarker, "Hide Raidmarker on nameplates with class icons")

    anchorSubClassIcon.classIndicatorFrameStrataHigh = CreateCheckbox("classIndicatorFrameStrataHigh", "Raise Strata", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorFrameStrataHigh:SetPoint("TOPLEFT", classIndicatorHideRaidMarker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorFrameStrataHigh, "Class Indicator Frame Strata", "Raise the Frame Strata of Class Indicator so it appears on top of other elements.")

    anchorSubClassIcon.classIndicatorHideName = CreateCheckbox("classIndicatorHideName", "Hide Name", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorHideName:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorFrameStrataHigh, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorHideName, "Hide Name (Friend)", "Hides the name on friendly nameplates with Class Indicator on them.")

    anchorSubClassIcon.classIndicatorIgnoreScale = CreateCheckbox("classIndicatorIgnoreScale", "Ignore Nameplate Scale", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorIgnoreScale:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorHideName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorIgnoreScale, "Ignore Nameplate Scale", "Ignore the scale of the Nameplate and keep the Class Indicator the same size always (especially when Targeting)")

    anchorSubClassIcon.classIndicatorBackground = CreateCheckbox("classIndicatorBackground", "Show Background Color", anchorSubClassIcon.extendedSettings)
    anchorSubClassIcon.classIndicatorBackground:SetPoint("TOPLEFT", anchorSubClassIcon.classIndicatorIgnoreScale, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorBackground, "Show Background Color","Show a background color on Class Indicator. Adjustable color and size.\n\n|cff32f795Right-click to change Color.|r\n\n|cff32f795Control + Right-click to turn on/off Class Colors.|r")

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

    anchorSubClassIcon.classIndicatorBackgroundSize = CreateSlider(anchorSubClassIcon.extendedSettings, "Background Size", 0.8, 1.4, 0.01, "classIndicatorBackgroundSize", false, 90)
    anchorSubClassIcon.classIndicatorBackgroundSize:SetPoint("LEFT", anchorSubClassIcon.classIndicatorBackground.Text, "RIGHT", 3, -3)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorBackgroundSize, "Class Indicator Background Size")

    anchorSubClassIcon.classIndicatorAlpha = CreateSlider(anchorSubClassIcon.extendedSettings, "Alpha", 0.1, 1, 0.01, "classIndicatorAlpha", false, 110)
    anchorSubClassIcon.classIndicatorAlpha:SetPoint("BOTTOM", anchorSubClassIcon.extendedSettings, "BOTTOM", 3, 5)
    CreateTooltipTwo(anchorSubClassIcon.classIndicatorAlpha, "Class Indicator Alpha")

    ----------------------
    -- Party Pointer
    ----------------------
    local anchorSubPointerIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPointerIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, fourthLineY)
    anchorSubPointerIndicator:SetText("Party Pointer")

    CreateBorderBox(anchorSubPointerIndicator)

    anchorSubPointerIndicator.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubPointerIndicator.t:SetAtlas("UI-QuestPoiImportant-QuestNumber-SuperTracked")
    anchorSubPointerIndicator.t:SetSize(25, 30)
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
    CreateTooltip(partyPointerHealer, "Show a cross on top of the pointer on healers.")

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
    CreateTooltipTwo(partyPointerHealerReplace, "Replace Party Pointer with Healer Icon", "Instead of showing the Healer Icon on top of the Party Pointer replace it entirely with the Healer icon.")

    anchorSubPointerIndicator.partyPointerHealerOnly = CreateCheckbox("partyPointerHealerOnly", "Heal Only", contentFrame)
    anchorSubPointerIndicator.partyPointerHealerOnly:SetPoint("TOPLEFT", partyPointerHealerReplace, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHealerOnly, "Healer Only", "Only show Party Pointer for healers.")

    local partyPointerHideAll = CreateCheckbox("partyPointerHideAll", "Hide all", contentFrame)
    partyPointerHideAll:SetPoint("TOPLEFT", partyPointerTargetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyPointerHideAll, "Hide All", "Hide everything except the Party Pointer for friendly nameplates that have the Party Pointer on them. Hides healthbar, castbar & name.")

    anchorSubPointerIndicator.partyPointerShowPet = CreateCheckbox("partyPointerShowPet", "Pet", contentFrame)
    anchorSubPointerIndicator.partyPointerShowPet:SetPoint("TOPLEFT", partyPointerHideAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerShowPet, "Show on Pet", "Show Party Pointer on your Pet.", "This setting requires \"Show Friendly Pets\" enabled in the CVar Control section.")

    anchorSubPointerIndicator.partyPointerAlwaysShowPet = CreateCheckbox("partyPointerAlwaysShowPet", "A", contentFrame)
    anchorSubPointerIndicator.partyPointerAlwaysShowPet:SetPoint("LEFT", anchorSubPointerIndicator.partyPointerShowPet.text, "RIGHT", 0, 5)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerAlwaysShowPet, "Show on Pet: Always", "Always show Party Pointer on your Pet, disregarding \"Arena Only\" settings etc.", "This setting requires \"Show Friendly Pets\" enabled in the CVar Control section.")
    anchorSubPointerIndicator.partyPointerAlwaysShowPet:SetSize(16,16)

    anchorSubPointerIndicator.partyPointerShowOthersPets = CreateCheckbox("partyPointerShowOthersPets", "O", contentFrame)
    anchorSubPointerIndicator.partyPointerShowOthersPets:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerAlwaysShowPet, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerShowOthersPets, "Show on Pet: Others", "Show Party Pointer on other friendlys Pets in Arena.", "This setting requires \"Show Friendly Pets\" enabled in the CVar Control section.")
    anchorSubPointerIndicator.partyPointerShowOthersPets:SetSize(16,16)

    anchorSubPointerIndicator.partyPointerCCAuras = CreateCheckbox("partyPointerCCAuras", "Show CC", contentFrame)
    anchorSubPointerIndicator.partyPointerCCAuras:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerShowPet, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerCCAuras, "Show CC", "Show CC Overlay on Party Pointer", "This setting requires nameplate aura settings + PvP CC filter enabled.\n\nWhile this is on the nameplate's own Big CC Icon is left off friendly plates outside of PvE, so the same icon is not shown twice.")
    anchorSubPointerIndicator.partyPointerCCAuras:HookScript("OnClick", function(self)
        BBP.RefreshAllNameplateAuras()
    end)

    anchorSubPointerIndicator.partyPointerOnlyParty = CreateCheckbox("partyPointerOnlyParty", "Party Only", contentFrame)
    anchorSubPointerIndicator.partyPointerOnlyParty:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerHealerOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerOnlyParty, "Party Only", "Only show Party Pointer for Party Members.")

    anchorSubPointerIndicator.partyPointerHighlightScale = CreateSlider(contentFrame, "PP: Highlight Size", 0.8, 1.7, 0.01, "partyPointerHighlightScale")
    anchorSubPointerIndicator.partyPointerHighlightScale:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerCCAuras, "BOTTOMLEFT", 2, -18)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerHighlightScale, "Change the size of the Highlight. Requires Highlight enabled.")

    anchorSubPointerIndicator.partyPointerTexture = CreateSlider(contentFrame, "Party Pointer Texture", 1, 14, 1, "partyPointerTexture")
    anchorSubPointerIndicator.partyPointerTexture:SetPoint("TOPLEFT", anchorSubPointerIndicator.partyPointerCCAuras, "BOTTOMLEFT", 2, -50)
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerTexture, "Change Party Pointer Texture")
    anchorSubPointerIndicator.partyPointerCustomTextureBox = CreateFrame("EditBox", nil, contentFrame, "InputBoxTemplate")
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
    CreateTooltipTwo(anchorSubPointerIndicator.partyPointerCustomTextureBox, "Enter Custom Atlas Name", "Enter atlas name to use a custom texture\n\nExample:\nIcon-WoW", nil, "ANCHOR_TOP")

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

    local useFakeName = CreateCheckbox("useFakeName", "Enable Name Reposition", contentFrame)

    local fakeNameXPos = CreateSlider(useFakeName, "|cffFF0000Enemy x offset|r", -50, 50, 1, "fakeNameXPos", "X")
    fakeNameXPos:SetPoint("TOP", anchorSubFakeName, "BOTTOM", 0, -15)

    local fakeNameYPos = CreateSlider(useFakeName, "|cffFF0000Enemy y offset|r", -50, 50, 1, "fakeNameYPos", "Y")
    fakeNameYPos:SetPoint("TOP", fakeNameXPos, "BOTTOM", 0, -15)

    local fakeNameFriendlyXPos = CreateSlider(useFakeName, "|cff0CC2FFFriendly x offset|r", -50, 50, 1, "fakeNameFriendlyXPos", "X")
    fakeNameFriendlyXPos:SetPoint("TOP", fakeNameYPos, "BOTTOM", 0, -15)

    local fakeNameFriendlyYPos = CreateSlider(useFakeName, "|cff0CC2FFFriendly y offset|r", -50, 50, 1, "fakeNameFriendlyYPos", "Y")
    fakeNameFriendlyYPos:SetPoint("TOP", fakeNameFriendlyXPos, "BOTTOM", 0, -15)

    local fakeNameAnchorDropdown = CreateAnchorDropdown(
        "partyPointerDropdown",
        contentFrame,
        "Select Anchor Point",
        "fakeNameAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameFriendlyYPos, x = -16, y = -33, label = "Enemy Name" },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(fakeNameAnchorDropdown, "Enemy Name Anchor Point", "Which side of the name should be the anchor point on Enemy nameplates.")

    local fakeNameAnchorFriendlyDropdown = CreateAnchorDropdown(
        "fakeNameAnchorFriendlyDropdown",
        contentFrame,
        "Select Anchor Point",
        "fakeNameAnchorFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameFriendlyYPos, x = 58, y = -33, label = "Friend Name" },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(fakeNameAnchorFriendlyDropdown, "Friendly Name Anchor Point", "Which side of the name should be the anchor point on Friendly nameplates.")

    local fakeNameAnchorRelativeDropdown = CreateAnchorDropdown(
        "arenaSpecAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "fakeNameAnchorRelative",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameAnchorDropdown, x = 0, y = -41, label = "Enemy HP" },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(fakeNameAnchorRelativeDropdown, "Enemy Healthbar Anchor Point", "Which side of the healthbar the name should get anchored to on Enemy nameplates.")

    local fakeNameAnchorRelativeFriendlyDropdown = CreateAnchorDropdown(
        "fakeNameAnchorRelativeFriendlyDropdown",
        contentFrame,
        "Select Anchor Point",
        "fakeNameAnchorRelativeFriendly",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = fakeNameAnchorFriendlyDropdown, x = 0, y = -41, label = "Friend HP" },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(fakeNameAnchorRelativeFriendlyDropdown, "Friendly Healthbar Anchor Point", "Which side of the healthbar the name should get anchored to on Friendly nameplates.")

    local fakeNameDropdowns = {
        fakeNameAnchorDropdown,
        fakeNameAnchorFriendlyDropdown,
        fakeNameAnchorRelativeDropdown,
        fakeNameAnchorRelativeFriendlyDropdown,
    }

    useFakeName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            for _, dropdown in ipairs(fakeNameDropdowns) do
                LibDD:UIDropDownMenu_EnableDropDown(dropdown)
            end
            if BetterBlizzPlates.arenaSpecAnchor == "TOP" then
                BetterBlizzPlates.arenaSpecAnchor = "CENTER"
            end
        else
            for _, dropdown in ipairs(fakeNameDropdowns) do
                LibDD:UIDropDownMenu_DisableDropDown(dropdown)
            end
            if BetterBlizzPlates.arenaSpecAnchor == "CENTER" then
                BetterBlizzPlates.arenaSpecAnchor = "TOP"
            end
        end
        LibDD:UIDropDownMenu_SetText(BBP.arenaSpecAnchorDropdown, BetterBlizzPlatesDB["arenaSpecAnchor"])
    end)

    if not BetterBlizzPlatesDB.useFakeName then
        for _, dropdown in ipairs(fakeNameDropdowns) do
            LibDD:UIDropDownMenu_DisableDropDown(dropdown)
        end
    end

    --local useFakeName = CreateCheckbox("useFakeName", "Enable Name Reposition", contentFrame) --moved up
    useFakeName:SetPoint("TOPLEFT", fakeNameAnchorRelativeDropdown, "BOTTOMLEFT", 16, 8)
    useFakeName:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(useFakeName)
    end)
    CreateTooltip(useFakeName, "Enables name repositioning by using a \"fake name\" and hiding the real one.")
    CreateTooltip(anchorSubFakeName.t, "Enables name repositioning by using a \"fake name\" and hiding the real one.")

    local useFakeNameAnchorBottom = CreateCheckbox("useFakeNameAnchorBottom", "Anchor friend", useFakeName)
    useFakeNameAnchorBottom:SetPoint("TOPLEFT", useFakeName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(useFakeNameAnchorBottom, "Anchor Friendly Name to Bottom", "Anchor the name on friendly nameplates to the bottom of the healthbar instead of on top so the name no longer shifts up when targeted.\nThis will override the other anchor settings.")

    local fakeNameScaleWithParent = CreateCheckbox("fakeNameScaleWithParent", "Scale", useFakeName)
    fakeNameScaleWithParent:SetPoint("LEFT", useFakeNameAnchorBottom.text, "RIGHT", 0, 0)
    CreateTooltipTwo(fakeNameScaleWithParent, "Scale with Nameplate", "Scale the Name with the nameplate.\nBy default this is off.")

    local fakeNameRaiseStrata = CreateCheckbox("fakeNameRaiseStrata", "Raise Strata", useFakeName)
    fakeNameRaiseStrata:SetPoint("TOPLEFT", useFakeNameAnchorBottom, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fakeNameRaiseStrata, "Raise Strata", "Raise the frame strata of name so it overlaps healthbar.")
    fakeNameRaiseStrata:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    anchorSubFakeName.fakeNameMaxWidthOn = CreateCheckbox("fakeNameMaxWidthOn", "Max Width", useFakeName)
    anchorSubFakeName.fakeNameMaxWidthOn:SetPoint("TOPLEFT", fakeNameRaiseStrata, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubFakeName.fakeNameMaxWidthOn, "Max Width", "Set a maximum width for the name text on nameplates.")
    anchorSubFakeName.fakeNameMaxWidthOn:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        BBP.RefreshAllNameplates()
    end)

    anchorSubFakeName.fakeNameMaxWidthSlider = CreateSlider(anchorSubFakeName.fakeNameMaxWidthOn, "Max Width", 25, 400, 1, "fakeNameMaxWidth", false, 120)
    anchorSubFakeName.fakeNameMaxWidthSlider:SetPoint("TOPLEFT", anchorSubFakeName.fakeNameMaxWidthOn, "BOTTOMLEFT", 18, -10)

    ----------------------
    -- Health Numbers
    ----------------------
    local anchorSubHealthNumbers = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHealthNumbers:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, fourthLineY)
    anchorSubHealthNumbers:SetText("Health Numbers")

    anchorSubHealthNumbers.border = CreateBorderBox(anchorSubHealthNumbers)

    anchorSubHealthNumbers.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubHealthNumbers.t:SetAtlas("ui_adv_health")
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
    anchorSubHealthNumbers.extendedSettings:SetSize(anchorSubHealthNumbers.border:GetHeight()+40, 360)
    anchorSubHealthNumbers.extendedSettings:SetPoint("BOTTOMRIGHT", anchorSubHealthNumbers.border, "BOTTOMLEFT", 87, -125)
    anchorSubHealthNumbers.extendedSettings:SetFrameStrata("DIALOG")
    anchorSubHealthNumbers.extendedSettings:SetIgnoreParentAlpha(true)
    anchorSubHealthNumbers.extendedSettings:EnableMouse(true)
    anchorSubHealthNumbers.extendedSettings:Hide()
    anchorSubHealthNumbers.extendedSettings.name = "Advanced Settings"
    anchorSubHealthNumbers.extendedSettings:SetTitle("Health Numbers")

    anchorSubHealthNumbers.closeButton = CreateFrame("Button", nil, anchorSubHealthNumbers.extendedSettings, "UIPanelCloseButton")
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

    anchorSubHealthNumbers.healthNumbersRawNumbers = CreateCheckbox("healthNumbersRawNumbers", "Raw Numbers", anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersRawNumbers:SetPoint("TOPLEFT", anchorSubHealthNumbers.extendedSettings, "TOPLEFT", 10, -23)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersRawNumbers, "Raw Numbers", "Show the full unformatted health number with no abbreviation.")

    anchorSubHealthNumbers.healthNumbersUseMillions = CreateCheckbox("healthNumbersUseMillions", "Format Million", anchorSubHealthNumbers.extendedSettings)
    anchorSubHealthNumbers.healthNumbersUseMillions:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersRawNumbers, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubHealthNumbers.healthNumbersUseMillions, "Format Million", "Display health values above 1million as 1m instead of 1000k")

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

    local healthNumbersCurrentFull = CreateCheckbox("healthNumbersCurrentFull", "Current / Max", anchorSubHealthNumbers.extendedSettings)
    healthNumbersCurrentFull:SetPoint("TOPLEFT", anchorSubHealthNumbers.healthNumbersUseMillions, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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


    ----------------------
    -- Target Text
    ----------------------
    local anchorSubTargetText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTargetText:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, fifthLineY)
    anchorSubTargetText:SetText("Target Text")

    anchorSubTargetText.border = CreateBorderBox(anchorSubTargetText)

    anchorSubTargetText.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubTargetText.t:SetAtlas("TargetCrosshairs")
    anchorSubTargetText.t:SetSize(60, 60)
    anchorSubTargetText.t:SetPoint("BOTTOM", anchorSubTargetText, "TOP", 11, -23)

    anchorSubTargetText.s1 = CreateSlider(contentFrame, "Font Size", 4, 20, 1, "npTargetTextSize", false, 72)
    anchorSubTargetText.s1:SetPoint("TOP", anchorSubTargetText, "BOTTOM", -36, -15)
    anchorSubTargetText.s1.Text:SetTextColor(1,0,0)
    CreateTooltip(anchorSubTargetText.s1, "Enemy Font Size")

    anchorSubTargetText.s2 = CreateSlider(contentFrame, "x offset", -50, 50, 1, "npTargetTextXPos", "X", 72)
    anchorSubTargetText.s2:SetPoint("TOP", anchorSubTargetText.s1, "BOTTOM", 0, -15)
    anchorSubTargetText.s2.Text:SetTextColor(1,0,0)
    CreateTooltip(anchorSubTargetText.s2, "Enemy X Offset")

    anchorSubTargetText.s3 = CreateSlider(contentFrame, "y offset", -50, 50, 1, "npTargetTextYPos", "Y", 72)
    anchorSubTargetText.s3:SetPoint("TOP", anchorSubTargetText.s2, "BOTTOM", 0, -15)
    anchorSubTargetText.s3.Text:SetTextColor(1,0,0)
    CreateTooltip(anchorSubTargetText.s3, "Enemy Y Offset")

    anchorSubTargetText.fs1 = CreateSlider(contentFrame, "Font Size", 4, 20, 1, "npTargetTextFriendlySize", false, 72)
    anchorSubTargetText.fs1:SetPoint("TOP", anchorSubTargetText, "BOTTOM", 36, -15)
    anchorSubTargetText.fs1.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubTargetText.fs1, "Friendly Font Size")

    anchorSubTargetText.fs2 = CreateSlider(contentFrame, "x offset", -50, 50, 1, "npTargetTextFriendlyXPos", "X", 72)
    anchorSubTargetText.fs2:SetPoint("TOP", anchorSubTargetText.fs1, "BOTTOM", 0, -15)
    anchorSubTargetText.fs2.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubTargetText.fs2, "Friendly X Offset")

    anchorSubTargetText.fs3 = CreateSlider(contentFrame, "y offset", -50, 50, 1, "npTargetTextFriendlyYPos", "Y", 72)
    anchorSubTargetText.fs3:SetPoint("TOP", anchorSubTargetText.fs2, "BOTTOM", 0, -15)
    anchorSubTargetText.fs3.Text:SetTextColor(0.04, 0.76, 1)
    CreateTooltip(anchorSubTargetText.fs3, "Friendly Y Offset")

    anchorSubTargetText.dropdown = CreateAnchorDropdown(
        "targetTextAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "targetTextAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.fs3, x = -90, y = -35, label = "Enemy" },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdown, "Enemy Anchor Point", "The anchor point of the Target Text itself.")
    CreateTooltipTwo(anchorSubTargetText.dropdown.label, "Enemy Anchor Point", "The anchor point of the Target Text itself.")

    anchorSubTargetText.dropdownFriendly = CreateAnchorDropdown(
        "targetTextFriendlyAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "targetTextFriendlyAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.fs3, x = -16, y = -35, label = "Friendly" },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendly, "Friendly Anchor Point", "The anchor point of the Target Text itself.")
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendly.label, "Friendly Anchor Point", "The anchor point of the Target Text itself.")

    anchorSubTargetText.dropdownRelative = CreateAnchorDropdown(
        "targetTextRelativeAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "targetTextRelativeAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.dropdown, x = 0, y = -45, label = "Relative" },
        55,
        {1, 0, 0, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdownRelative, "Enemy Relative Point", "The point where the Target Text attaches to the nameplate. If any of the bottom ones are selected it will anchor underneath castbar instead of healthbar when castbar is shown unless \"Static\" is selected.")
    CreateTooltipTwo(anchorSubTargetText.dropdownRelative.label, "Enemy Relative Point", "The point where the Target Text attaches to the nameplate. If any of the bottom ones are selected it will anchor underneath castbar instead of healthbar when castbar is shown unless \"Static\" is selected.")

    anchorSubTargetText.dropdownFriendlyRelative = CreateAnchorDropdown(
        "targetTextFriendlyRelativeAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "targetTextFriendlyRelativeAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = anchorSubTargetText.dropdownFriendly, x = 0, y = -45, label = "Relative" },
        55,
        {0.04, 0.76, 1, 1}
    )
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendlyRelative, "Friendly Relative Point", "The point where the Target Text attaches to the nameplate. If any of the bottom ones are selected it will anchor underneath castbar instead of healthbar when castbar is shown unless \"Static\" is selected.")
    CreateTooltipTwo(anchorSubTargetText.dropdownFriendlyRelative.label, "Friendly Relative Point", "The point where the Target Text attaches to the nameplate. If any of the bottom ones are selected it will anchor underneath castbar instead of healthbar when castbar is shown unless \"Static\" is selected.")

    anchorSubTargetText.c1 = CreateCheckbox("targetTextAlwaysShow", "Always on", contentFrame, nil, function()
        BBP.ToggleTargetTextAlwaysShow()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c1:SetPoint("TOPLEFT", anchorSubTargetText.dropdownRelative, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubTargetText.c1, "Always show Target Text", "When not casting, shows who the unit is targeting.\nWhen casting, cast target always has priority.")

    anchorSubTargetText.static = CreateCheckbox("targetTextStatic", "Static", contentFrame)
    anchorSubTargetText.static:SetPoint("LEFT", anchorSubTargetText.c1.text, "RIGHT", 0, 0)
    CreateTooltipTwo(anchorSubTargetText.static, "Static Position", "Enable this to keep the text in one place and not move it up/down depending on castbar shown or not")

    anchorSubTargetText.c1pvp = CreateCheckbox("targetTextAlwaysShowPvP", "PvP", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c1pvp:SetPoint("TOPLEFT", anchorSubTargetText.c1, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anchorSubTargetText.c1pvp, "Always on mode active in PvP")

    anchorSubTargetText.c1pve = CreateCheckbox("targetTextAlwaysShowPvE", "PvE", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c1pve:SetPoint("LEFT", anchorSubTargetText.c1pvp.text, "RIGHT", 0, 0)
    CreateTooltip(anchorSubTargetText.c1pve, "Always on mode active in PvE instances (Dungeons, Raids)")

    anchorSubTargetText.c1world = CreateCheckbox("targetTextAlwaysShowWorld", "World", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c1world:SetPoint("LEFT", anchorSubTargetText.c1pve.text, "RIGHT", 0, 0)
    CreateTooltip(anchorSubTargetText.c1world, "Always on mode active in the open world")

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

    anchorSubTargetText.c3 = CreateCheckbox("targetTextEnemy", "Enemy", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c3:SetPoint("TOPLEFT", anchorSubTargetText.c1pvp, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anchorSubTargetText.c3, "Show target text on enemy nameplates")

    anchorSubTargetText.c4 = CreateCheckbox("targetTextFriendly", "Friendly", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.c4:SetPoint("LEFT", anchorSubTargetText.c3.text, "RIGHT", 0, 0)
    CreateTooltip(anchorSubTargetText.c4, "Show target text on friendly nameplates")

    anchorSubTargetText.testMode = CreateCheckbox("targetTextTestMode", "Test", contentFrame)
    anchorSubTargetText.testMode:SetPoint("TOPLEFT", anchorSubTargetText.c3, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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
    CreateTooltipTwo(anchorSubTargetText.testMode, "Test Target Text", "Shows your name as the target on all nameplates.\n\n|cff32f795Right-click to toggle Castbar Test Mode.|r")

    anchorSubTargetText.insideBar = CreateCheckbox("castbarTargetTextInsideBar", "Inside Bar", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.insideBar:SetPoint("LEFT", anchorSubTargetText.testMode.text, "RIGHT", 0, 0)

    anchorSubTargetText.hideOnNpcs = CreateCheckbox("npTargetTextHideOnNpcs", "Hide on npcs", contentFrame, nil, function()
        BBP.RefreshAllNameplates()
    end)
    anchorSubTargetText.hideOnNpcs:SetPoint("TOPLEFT", anchorSubTargetText.testMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubTargetText.hideOnNpcs, "Hide on NPCs", "Only show the target text on player nameplates.")
    do
        local playerName = UnitName("player") or "Player"
        local _, playerClass = UnitClass("player")
        local classColor = playerClass and C_ClassColor.GetClassColor(playerClass)
        local coloredName = classColor and classColor:WrapTextInColorCode(playerName) or playerName
        CreateTooltipTwo(anchorSubTargetText.insideBar, "Target text inside castbar", "Put the target text inside the castbar on casts so it appears like \"Polymorph: " .. coloredName .. "\"")
    end


    ----------------------
    -- Bg Blitz
    ----------------------
    local anchorSubBlitzIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubBlitzIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, fifthLineY)
    anchorSubBlitzIndicator:SetText("Blitz Indicator")

    CreateBorderBox(anchorSubBlitzIndicator)

    anchorSubBlitzIndicator.t = contentFrame:CreateTexture(nil, "ARTWORK")
    anchorSubBlitzIndicator.t:SetAtlas("Ping_Chat_Assist")
    anchorSubBlitzIndicator.t:SetSize(29, 29)
    anchorSubBlitzIndicator.t:SetPoint("BOTTOM", anchorSubBlitzIndicator, "TOP", 0, 3)

    anchorSubBlitzIndicator.s1 = CreateSlider(contentFrame, "Size", 0.5, 2, 0.01, "bgIndicatorScale")
    anchorSubBlitzIndicator.s1:SetPoint("TOP", anchorSubBlitzIndicator, "BOTTOM", 0, -15)

    anchorSubBlitzIndicator.s2 = CreateSlider(contentFrame, "x offset", -50, 50, 1, "bgIndicatorXPos", "X")
    anchorSubBlitzIndicator.s2:SetPoint("TOP", anchorSubBlitzIndicator.s1, "BOTTOM", 0, -15)

    anchorSubBlitzIndicator.s3 = CreateSlider(contentFrame, "y offset", -50, 50, 1, "bgIndicatorYPos", "Y")
    anchorSubBlitzIndicator.s3:SetPoint("TOP", anchorSubBlitzIndicator.s2, "BOTTOM", 0, -15)

    anchorSubBlitzIndicator.dropdown = CreateAnchorDropdown(
        "anchorSubBlitzIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "bgIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = anchorSubBlitzIndicator.s3, x = -16, y = -35, label = "Anchor" }
    )

    anchorSubBlitzIndicator.c1 = CreateCheckbox("bgIndicatorEnemyOnly", "Enemies Only", contentFrame)
    anchorSubBlitzIndicator.c1:SetPoint("TOPLEFT", anchorSubBlitzIndicator.dropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubBlitzIndicator.c1, "Enemies only", "Show on enemies only.")

    anchorSubBlitzIndicator.c2 = CreateCheckbox("bgIndicatorShowFlags", "Show Flags", contentFrame)
    anchorSubBlitzIndicator.c2:SetPoint("TOPLEFT", anchorSubBlitzIndicator.c1, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubBlitzIndicator.c2, "Show Flags", "Show flag on flag carriers.")

    anchorSubBlitzIndicator.c3 = CreateCheckbox("bgIndicatorShowOrbs", "Show Orbs", contentFrame)
    anchorSubBlitzIndicator.c3:SetPoint("TOPLEFT", anchorSubBlitzIndicator.c2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubBlitzIndicator.c3, "Show Orbs", "Show orb on orb carriers.")

    -- anchorSubBlitzIndicator.c4 = CreateCheckbox("bgIndicatorShowFlags", "", contentFrame)
    -- anchorSubBlitzIndicator.c4:SetPoint("TOPLEFT", anchorSubBlitzIndicator.c2, "BOTTOMLEFT", 0, -50)
    -- anchorSubBlitzIndicator.c4:SetAlpha(0)
    -- anchorSubBlitzIndicator.c4:SetScript("OnClick", nil)



    ----------------------
    -- Totem Indicator
    ----------------------
    contentFrame.anchorSubTotem = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentFrame.anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, sixthLineY)
    contentFrame.anchorSubTotem:SetText("Totem Indicator")

    CreateBorderBox(contentFrame.anchorSubTotem)

    contentFrame.totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    contentFrame.totemIcon2:SetAtlas("teleportationnetwork-ardenweald-32x32")
    contentFrame.totemIcon2:SetSize(34, 34)
    contentFrame.totemIcon2:SetPoint("BOTTOM", contentFrame.anchorSubTotem, "TOP", 0, 0)

    BBP.totemIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 3, 0.01, "totemIndicatorScale")
    BBP.totemIndicatorScale:SetPoint("TOP", contentFrame.anchorSubTotem, "BOTTOM", 0, -15)
    CreateTooltip( BBP.totemIndicatorScale, "This changes the scale of ALL icons.\n\nYou can adjust individual sizes in the \"Totem Indicator List\" tab.", "ANCHOR_LEFT")

    contentFrame.totemIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "totemIndicatorXPos", "X")
    contentFrame.totemIndicatorXPos:SetPoint("TOP",  BBP.totemIndicatorScale, "BOTTOM", 0, -15)

    contentFrame.totemIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "totemIndicatorYPos", "Y")
    contentFrame.totemIndicatorYPos:SetPoint("TOP", contentFrame.totemIndicatorXPos, "BOTTOM", 0, -15)

    contentFrame.totemIndicatorDropdown = CreateAnchorDropdown(
        "totemIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "totemIndicatorAnchor",
        function(arg1)
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = contentFrame.totemIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    contentFrame.totemTestIcons2 = CreateCheckbox("totemIndicatorTestMode", "Test", contentFrame)
    contentFrame.totemTestIcons2:SetPoint("TOPLEFT", contentFrame.totemIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    contentFrame.totemIndicatorEnemyOnly = CreateCheckbox("totemIndicatorEnemyOnly", "Enemies only", contentFrame)
    contentFrame.totemIndicatorEnemyOnly:SetPoint("LEFT", contentFrame.totemTestIcons2.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorEnemyOnly, "Show on enemy totems only")

    contentFrame.totemIndicatorHideNameAndShiftIconDown = CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", "Hide name", contentFrame)
    BBP.totemIndicatorHideName = contentFrame.totemIndicatorHideNameAndShiftIconDown
    contentFrame.totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", contentFrame.totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    contentFrame.totemIndicatorHideHealthBar = CreateCheckbox("totemIndicatorHideHealthBar", "Hide hp", contentFrame)
    contentFrame.totemIndicatorHideHealthBar:SetPoint("LEFT", contentFrame.totemIndicatorHideNameAndShiftIconDown.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorHideHealthBar, "Hide the healthbar on totems.\nWill still show if targeted.")

--[=[
    local totemIndicatorDisplayCdText = CreateCheckbox("totemIndicatorDisplayCdText", "CD Text", contentFrame)
    totemIndicatorDisplayCdText:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorDisplayCdText, "Display default Blizz CD Text\n\nWill not work with OmniCC.")
]=]-- cant force use blizzards own countdown it seems, must make own soonTM

    contentFrame.showTotemIndicatorCooldownSwipe = CreateCheckbox("showTotemIndicatorCooldownSwipe", "CD Swipe", contentFrame)
    contentFrame.showTotemIndicatorCooldownSwipe:SetPoint("TOPLEFT", contentFrame.totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(contentFrame.showTotemIndicatorCooldownSwipe, "Show Cooldown Swipe Animation")

    contentFrame.totemIndicatorColorName = CreateCheckbox("totemIndicatorColorName", "Color Name", contentFrame)
    contentFrame.totemIndicatorColorName:SetPoint("TOPLEFT", contentFrame.showTotemIndicatorCooldownSwipe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(contentFrame.totemIndicatorColorName, "Color name text")

    contentFrame.totemIndicatorHideAuras = CreateCheckbox("totemIndicatorHideAuras", "Hide auras", contentFrame)
    contentFrame.totemIndicatorHideAuras:SetPoint("LEFT", contentFrame.totemIndicatorColorName.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorHideAuras, "Hide Auras on totem nameplates")

    contentFrame.totemIndicatorColorHealthBar = CreateCheckbox("totemIndicatorColorHealthBar", "Color HP", contentFrame)
    contentFrame.totemIndicatorColorHealthBar:SetPoint("LEFT", contentFrame.showTotemIndicatorCooldownSwipe.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorColorHealthBar, "Color healthbar")

    contentFrame.totemIndicatorShowOtherIcons = CreateCheckbox("totemIndicatorShowOtherIcons", "Other icons", contentFrame)
    contentFrame.totemIndicatorShowOtherIcons:SetPoint("TOPLEFT", contentFrame.totemIndicatorColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(contentFrame.totemIndicatorShowOtherIcons, "Show icon on non-important totems", "Show an icon on standard totems that cannot be detected specifically. Only detectable important totems atm are Grounding Totem and Capacitor Totem")

    contentFrame.totemIndicatorColorOtherHealthBars = CreateCheckbox("totemIndicatorColorOtherHealthBars", "Color other HP", contentFrame)
    contentFrame.totemIndicatorColorOtherHealthBars:SetPoint("LEFT", contentFrame.totemIndicatorShowOtherIcons.text, "RIGHT", 0, 0)
    CreateTooltipTwo(contentFrame.totemIndicatorColorOtherHealthBars, "Color healthbar of non-important totems", "This will be the standard totem color for totems that cannot be detected specifically. Only detectable important totems atm are Grounding Totem and Capacitor Totem\n\n|cff32f795Right-click to set a general \"Totem Nameplate Color\".|r")
    local function OpenTotemNormalColorPicker()
        BBP.needsUpdate = true
        local r, g, b = unpack(BetterBlizzPlatesDB.totemIndicatorTotemColor or { 0.4, 0.34, 0.21 })
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                BetterBlizzPlatesDB.totemIndicatorTotemColor = { r, g, b }
                BBP.RefreshAllNameplates()
                contentFrame.totemIndicatorColorOtherHealthBars.Text:SetTextColor(r, g, b)
            end,
            cancelFunc = function(previousValues)
                local r, g, b = previousValues.r, previousValues.g, previousValues.b
                BetterBlizzPlatesDB.totemIndicatorTotemColor = { r, g, b }
                BBP.RefreshAllNameplates()
                contentFrame.totemIndicatorColorOtherHealthBars.Text:SetTextColor(r, g, b)
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

    contentFrame.totemIndicatorColorNameOthers = CreateCheckbox("totemIndicatorColorNameOthers", "Color name (others)", contentFrame)
    contentFrame.totemIndicatorColorNameOthers:SetPoint("LEFT", contentFrame.totemIndicatorColorOtherHealthBars.text, "RIGHT", 0, 0)
    CreateTooltip(contentFrame.totemIndicatorColorNameOthers, "Color name text of non-important totems")

    contentFrame.totemIndicatorDefaultCooldownTextSize = CreateSlider(contentFrame, "Default CD Size", 0.3, 2, 0.01, "totemIndicatorDefaultCooldownTextSize", nil, 95)
    contentFrame.totemIndicatorDefaultCooldownTextSize:SetPoint("TOP", contentFrame.totemIndicatorHideNameAndShiftIconDown, "BOTTOM", 40, -68)
    CreateTooltip(contentFrame.totemIndicatorDefaultCooldownTextSize, "Size of the default Blizz CD text.\n\nWill not work with OmniCC.")

    contentFrame.totemIndicatorNoAnimation = CreateCheckbox("totemIndicatorNoAnimation", "Anim", contentFrame)
    contentFrame.totemIndicatorNoAnimation:SetPoint("LEFT", contentFrame.totemIndicatorDefaultCooldownTextSize, "RIGHT", 0, 3)
    CreateTooltipTwo(contentFrame.totemIndicatorNoAnimation, "No Animation", "Stops the pulsing animation on important npcs")

    contentFrame.totemIndicatorNoGlow = CreateCheckbox("totemIndicatorNoGlow", "No Glow", contentFrame)
    contentFrame.totemIndicatorNoGlow:SetPoint("TOPLEFT", contentFrame.totemIndicatorNoAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(contentFrame.totemIndicatorNoGlow, "No Glow", "Hide the glow border on important npcs")




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

    local castBarTextJustifyDropdown = CreateAnchorDropdown(
        "castBarTextJustifyDropdown",
        enableCastbarCustomization,
        "CENTER",
        "castBarTextJustify",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = castBarFullTextWidth, x = 110, y = 8, label = "Castbar Text Position" },
        110,
        nil,
        { "LEFT", "CENTER", "RIGHT" }
    )
    CreateTooltipTwo(castBarTextJustifyDropdown, "Castbar Text Position", "Align the castbar spell name text to the left, center, or right of the castbar.")

    local castBarIconScale = CreateSlider(enableCastbarCustomization, "Castbar Icon Size", 0.1, 2.5, 0.01, "castBarIconScale")
    castBarIconScale:SetPoint("TOPLEFT", castBarDragonflightShield, "BOTTOMLEFT", 12, -10)

    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconXPos", "X", 100)
    castBarIconXPos:SetPoint("LEFT", castBarIconScale, "RIGHT", 12, 0)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y", 100)
    castBarIconYPos:SetPoint("TOP", castBarIconXPos, "BOTTOM", 0, -15)

    local anchorCastIconOnRight = CreateCheckbox("anchorCastIconOnRight", "Anchor Icon Right", enableCastbarCustomization)
    anchorCastIconOnRight:SetPoint("LEFT", castBarIconYPos, "RIGHT", 5, 16)
    CreateTooltipTwo(anchorCastIconOnRight, "Anchor Cast Icon on Right", "Anchor the cast icon to the right side of the castbar instead of left. Do this if you want it on the right side.")

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
    castBarCastColor:SetText("Cast")
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
    castBarChanneledColor:SetText("Channel")
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
    castBarNoninterruptibleColor:SetText("Non-Int")
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
        { anchorFrame = useCustomCastbarTexture, x = 5, y = 0, label = "CustomCastbar" }
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
        { anchorFrame = useCustomCastbarTexture, x = 5, y = -31, label = "CustomBGCastbar" }
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
        { anchorFrame = useCustomCastbarTexture, x = 5, y = -62, label = "CustomBGCastbar" }
    )
    CreateTooltip(customCastbarBGTextureDropdown, "Background Texture")

    if not useCustomCastbarTexture:GetChecked() then
        customCastbarTextureDropdown:Disable()
        customCastbarNonInterruptibleTextureDropdown:Disable()
        customCastbarBGTextureDropdown:Disable()
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
    castBarBackgroundColorIcon:SetAtlas("newplayertutorial-icon-key")
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
    castBarNoInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
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
    --         StaticPopup_Show("BBP_CONFIRM_RELOAD")
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
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
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
    guiClickNStack.name = "|A:plunderstorm-pickup-mouseclick-left:16:16|aLook & Behaviour"
    guiClickNStack.parent = BetterBlizzPlates.name
    local guiClickNStackCategory = Settings.RegisterCanvasLayoutSubcategory(BBP.category, guiClickNStack, guiClickNStack.name, guiClickNStack.name)
    CreateTitle(guiClickNStack)

    local bgImg = guiClickNStack:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiClickNStack, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local settingsText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, 0)
    settingsText:SetText("General")
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("optionsicon-brown")
    icon:SetSize(22, 22)
    icon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local info = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 300, 0)
    info:SetWidth(270)
    info:SetText("|cff6699ffBlue: Nameplate Box Height|r\nThe invisible nameplate size. This will be the max area allowed to click, the size that stacking nameplates care about (+- overlap values), and what some addons anchor their stuff to (some anchor directly to the healthbar instead).\n\n\n|cffff6666Red: Stacking Zone|r\nWhen the stacking zone of two nameplates touch they will begin to stack.\n\n\n|cff66cc66Green: Valid Click Area|r\nYour click area has to be inside of the |cff6699ffblue|r nameplate box. If you do not see |cff66cc66green|r you've moved the healthbar outside of the allowed click area and nothing will be clickable.")

    local nameplateBoxHeight = CreateSlider(guiClickNStack, "Nameplate Box Height", 12, 70, 1, "nameplateBoxHeight")
    nameplateBoxHeight:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 8, -12)
    CreateTooltipTwo(nameplateBoxHeight, "Nameplate Box Height", "Adjusts the invisible nameplate box height.\n\nThis height matters for two things:\n1) The height Blizzard considers a nameplate to be and affects CVar settings like how close to the edge a nameplate can get. This will also impact some addons anchoring things to the nameplate as they anchor to this box. Some addons anchor to the nameplate directly other addons anchor to the nameplate's healthbar.\n2) The maximum clickable height for a nameplate.")
    local nameplateBoxHeightReset = CreateResetButton(nameplateBoxHeight, "nameplateBoxHeight", nameplateBoxHeight)

    local nameplateVerticalPosition = CreateSlider(guiClickNStack, "Nameplate Vertical Position", -190, 70, 1, "nameplateVerticalPosition", "Y")
    nameplateVerticalPosition:SetPoint("TOPLEFT", nameplateBoxHeight, "BOTTOMLEFT", 0, -17)
    CreateResetButton(nameplateVerticalPosition, "nameplateVerticalPosition", guiClickNStack)

    local stackingText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackingText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -80)
    stackingText:SetText("Stacking")
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("MiniMap-PositionArrows")
    icon:SetSize(17, 25)
    icon:SetPoint("RIGHT", stackingText, "LEFT", -3, -1)

    local nameplateStackingEnemy = CreateCheckbox("nameplateStackingTypes_Enemy", "Stacking enemy nameplates", guiClickNStack, nil, nil, {cvarName = "nameplateStackingTypes", index = Enum.NamePlateStackType.Enemy})
    nameplateStackingEnemy:SetPoint("TOPLEFT", stackingText, "BOTTOMLEFT", -4, -pixelsOnFirstBox)
    CreateTooltipTwo(nameplateStackingEnemy, "Stacking Enemy Nameplates", "Turn on stacking for enemy nameplates.", nil, nil, "nameplateStackingTypes")
    nameplateStackingEnemy:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzPlatesDB.keepOverlappingNameplatesInPvP == nil then
                BetterBlizzPlatesDB.keepOverlappingNameplatesInPvP = true
                if not nameplateStackingEnemy:GetChecked() then
                    nameplateStackingEnemy:Click()
                    nameplateStackingEnemy:SetChecked(true)
                end
            else
                BetterBlizzPlatesDB.keepOverlappingNameplatesInPvP = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBP.SetNameplateBehavior()
        end
    end)

    local nameplateStackingFriendly = CreateCheckbox("nameplateStackingTypes_Friendly", "Stacking friendly nameplates", guiClickNStack, nil, nil, {cvarName = "nameplateStackingTypes", index = Enum.NamePlateStackType.Friendly})
    nameplateStackingFriendly:SetPoint("TOPLEFT", nameplateStackingEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateStackingFriendly, "Stacking Friendly Nameplates", "Turn on stacking for friendly nameplates.", nil, nil, "nameplateStackingTypes")

    local stackingHorizontalOffset = CreateSlider(guiClickNStack, "Stacking Zone Width", -60, 60, 1, "stackingHorizontalOffset", "X")
    stackingHorizontalOffset:SetPoint("TOPLEFT", nameplateStackingFriendly, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(stackingHorizontalOffset, "Stacking Zone Width", "Adjusts the zone width for stackable nameplates.\n\nWhen the zones of two nameplates hit each other the nameplates will start stacking.")
    local stackingHorizontalOffsetReset = CreateResetButton(stackingHorizontalOffset, "stackingHorizontalOffset", stackingHorizontalOffset)

    local stackingVerticalOffset = CreateSlider(guiClickNStack, "Stacking Zone Height", -60, 60, 1, "stackingVerticalOffset", "Y")
    stackingVerticalOffset:SetPoint("TOPLEFT", stackingHorizontalOffset, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(stackingVerticalOffset, "Stacking Zone Height", "Adjusts the zone height for stackable nameplates.\n\nWhen the zones of two nameplates hit each other the nameplates will start stacking.")
    local stackingVerticalOffsetReset = CreateResetButton(stackingVerticalOffset, "stackingVerticalOffset", stackingVerticalOffset)

    local stackingVerticalAdjustmentOffset = CreateSlider(guiClickNStack, "Stacking Zone Y Offset", -60, 60, 1, "stackingVerticalAdjustmentOffset", "Y")
    stackingVerticalAdjustmentOffset:SetPoint("TOPLEFT", stackingVerticalOffset, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(stackingVerticalAdjustmentOffset, "Stacking Zone Y Offset", "Adjust where the stacking zone sits vertically.\n\nWhen the zones of two nameplates hit each other the nameplates will start stacking.")
    local stackingVerticalAdjustmentOffsetReset = CreateResetButton(stackingVerticalAdjustmentOffset, "stackingVerticalAdjustmentOffset", stackingVerticalAdjustmentOffset)

    local nameplateOverlapH = CreateSlider(guiClickNStack, "Horizontal Stacking Overlap", 0.3, 1.2, 0.01, "nameplateOverlapH")
    nameplateOverlapH:SetPoint("TOPLEFT", stackingVerticalAdjustmentOffset, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOverlapH, "Horizontal Stacking Overlap", "|cff00ff00TLDR:|r Lower values makes nameplates stack closer to eachother but too low increases risk of vibrating nameplates.\n\nOverlap values are based on your nameplate size (blue box). 1 = 100% of the nameplate's width/height. Higher values increase spacing, lower values allow more overlap. The actual distance between nameplates changes depending on your nameplate size and this overlap setting.\n\nToo low values can cause the nameplates to start \"vibrating\". Recommended range 0.85 to 1 but your milage may vary depending on nameplate size.\n\nThe nameplates will only start stacking once the red stacking box comes into contact with another one.")
    local nameplateOverlapHReset = CreateResetButton(nameplateOverlapH, "nameplateOverlapH", nameplateOverlapH)

    local nameplateOverlapV = CreateSlider(guiClickNStack, "Vertical Stacking Overlap", 0.3, 1.2, 0.01, "nameplateOverlapV")
    nameplateOverlapV:SetPoint("TOPLEFT", nameplateOverlapH, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateOverlapV, "Vertical Stacking Overlap", "|cff00ff00TLDR:|r Lower values makes nameplates stack closer to eachother but too low increases risk of vibrating nameplates.\n\nOverlap values are based on your nameplate size (blue box). 1 = 100% of the nameplate's width/height. Higher values increase spacing, lower values allow more overlap. The actual distance between nameplates changes depending on your nameplate size and this overlap setting.\n\nToo low values can cause the nameplates to start \"vibrating\". Recommended range 0.85 to 1 but your milage may vary depending on nameplate size.\n\nThe nameplates will only start stacking once the red stacking box comes into contact with another one.")
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

    nameplateStackingEnemy:HookScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        BBP.RunAfterCombat(function()
            if not BetterBlizzPlatesDB.bitfields then BetterBlizzPlatesDB.bitfields = {} end
            if not BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"] then BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"] = {} end
            BetterBlizzPlatesDB.bitfields["nameplateStackingTypes"][tostring(Enum.NamePlateStackType.Enemy)] = isChecked
            C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, isChecked)
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
        end)
        ToggleStackingSliders()
    end)

    local clickingText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clickingText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -295)
    clickingText:SetText("Clicking")
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("plunderstorm-pickup-mouseclick-left")
    icon:SetSize(24, 26)
    icon:SetPoint("RIGHT", clickingText, "LEFT", -3, -1)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", "Friendly Clickthrough", guiClickNStack, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", clickingText, "BOTTOMLEFT", -4, -pixelsOnFirstBox)
    CreateTooltipTwo(friendlyNameplateClickthrough, "Clickthrough Friendly Nameplate", "Make friendly nameplates clickthrough")

    local nameplateExtraClickWidth = CreateSlider(guiClickNStack, "Nameplate Extra Click Width", -60, 6, 1, "nameplateExtraClickWidth", "X")
    nameplateExtraClickWidth:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 12, -10)
    CreateResetButton(nameplateExtraClickWidth, "nameplateExtraClickWidth", guiClickNStack)

    local nameplateExtraClickHeight = CreateSlider(guiClickNStack, "Nameplate Extra Click Height", -38, 30, 1, "nameplateExtraClickHeight", "Y")
    nameplateExtraClickHeight:SetPoint("TOPLEFT", nameplateExtraClickWidth, "BOTTOMLEFT", 0, -16)
    CreateResetButton(nameplateExtraClickHeight, "nameplateExtraClickHeight", guiClickNStack)

    local nameplateClickVerticalAdjustment = CreateSlider(guiClickNStack, "Nameplate Click Area Y Offset", -20, 20, 1, "nameplateClickVerticalAdjustment", "Y")
    nameplateClickVerticalAdjustment:SetPoint("TOPLEFT", nameplateExtraClickHeight, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(nameplateClickVerticalAdjustment, "Clickable Vertical Position", "Tweak the vertical position of the clickable area.")
    CreateResetButton(nameplateClickVerticalAdjustment, "nameplateClickVerticalAdjustment", guiClickNStack)

    local castbarText = guiClickNStack:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarText:SetPoint("TOPLEFT", guiClickNStack, "TOPLEFT", 20, -430)
    castbarText:SetText("Castbar Adjustments")
    local icon = guiClickNStack:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("UI-CastingBar-Pip")
    icon:SetSize(22, 22)
    icon:SetPoint("RIGHT", castbarText, "LEFT", -3, -1)


    local fitCastIconLeftOfCast
    local classic = BetterBlizzPlatesDB.classicNameplates
    if not classic then
        fitCastIconLeftOfCast = CreateCheckbox("fitCastIconLeftOfCast", "Fit Cast Icon on the left", guiClickNStack)
        fitCastIconLeftOfCast:SetPoint("TOPLEFT", castbarText, "BOTTOMLEFT", -4, -pixelsOnFirstBox)
        CreateTooltipTwo(fitCastIconLeftOfCast, "Fit Cast Icon on the left", "Position the castbar icon on the left side of the castbar and push the castbar to the right so everything fits under the healthbar.")
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

    local enemyCastbarExtraWidth = CreateSlider(guiClickNStack, "Castbar Width (Enemy)", -60, 60, 1, "enemyCastbarExtraWidth", "X")
    enemyCastbarExtraWidth:SetPoint("TOPLEFT", fitCastIconLeftOfCast or castbarText, "BOTTOMLEFT", xPos, yPos)
    CreateTooltipTwo(enemyCastbarExtraWidth, "Enemy Castbar Extra Width", "Adjust the extra width of the enemy castbar.")
    CreateResetButton(enemyCastbarExtraWidth, "enemyCastbarExtraWidth", guiClickNStack)

    local friendlyCastbarExtraWidth = CreateSlider(guiClickNStack, "Castbar Width (Friendly)", -60, 60, 1, "friendlyCastbarExtraWidth", "X")
    friendlyCastbarExtraWidth:SetPoint("TOPLEFT", enemyCastbarExtraWidth, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(friendlyCastbarExtraWidth, "Friendly Castbar Extra Width", "Adjust the extra width of the friendly castbar.")
    CreateResetButton(friendlyCastbarExtraWidth, "friendlyCastbarExtraWidth", guiClickNStack)

    local castBarXPos = CreateSlider(guiClickNStack, "Castbar Horizontal Position", -50, 50, 1, "castBarXPos", "X")
    castBarXPos:SetPoint("TOPLEFT", friendlyCastbarExtraWidth, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(castBarXPos, "Castbar Horizontal Position", "Adjust the horizontal position of the castbar.")
    CreateResetButton(castBarXPos, "castBarXPos", guiClickNStack)

    local spacingBetweenCastAndHealthbar = CreateSlider(guiClickNStack, "Castbar Vertical Position", -50, 50, 1, "spacingBetweenCastAndHealthbar", "Y")
    spacingBetweenCastAndHealthbar:SetPoint("TOPLEFT", castBarXPos, "BOTTOMLEFT", 0, -16)
    CreateTooltipTwo(spacingBetweenCastAndHealthbar, "Castbar Vertical Position", "Adjust the vertical position of the castbar.")
    CreateResetButton(spacingBetweenCastAndHealthbar, "spacingBetweenCastAndHealthbar", guiClickNStack)

    local clickAndStackTestButton = CreateFrame("Button", nil, guiClickNStack, "GameMenuButtonTemplate")
    clickAndStackTestButton:SetSize(110, 25)
    clickAndStackTestButton:SetText("Test")
    clickAndStackTestButton:SetNormalFontObject("GameFontNormal")
    clickAndStackTestButton:SetHighlightFontObject("GameFontHighlight")
    clickAndStackTestButton:SetPoint("TOP", info, "BOTTOM", 0, -10)
    CreateTooltipTwo(clickAndStackTestButton, "Test Click & Stacking", "Preview the stacking zone (red), nameplate box (blue) and clickable area (green) overlays on all nameplates.\n\nAlso runs the castbar test mode.", nil, "ANCHOR_LEFT")

    local testModeActive = false
    clickAndStackTestButton:SetScript("OnClick", function(self)
        testModeActive = not testModeActive
        if testModeActive then
            self:SetText("Stop Testing")
            BBP.ClickAndStackTestMode(true)
        else
            self:SetText("Test")
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
    hideCastbarExplanationText:SetText("Hide castbar for chosen spells/NPCs,\nor only show whitelisted ones.\n \nSupports spell name/id and npc id/name")

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

    local hideCastbarFriendly = CreateCheckbox("hideCastbarFriendly", "Hide friendly castbars", hideCastbar)
    hideCastbarFriendly:SetPoint("TOPLEFT", hideNpcCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideCastbarFriendly, "Hide Friendly Castbars", "Hide all friendly castbars, except for whitelisted ones. This setting will NOT be able to whitelist certain spells during PvE and instead just hide all casts.")

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
    fadeOutNPC:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    -- local fadeAllButTarget = CreateCheckbox("fadeAllButTarget", "Fade All Except Target", fadeOutNPC)
    -- fadeAllButTarget:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(fadeAllButTarget, "Fade out all other nameplates when you have a target.\nDisregards the fade list")

    local fadeNPCPvPOnly = CreateCheckbox("fadeNPCPvPOnly", "Only fade NPCs in PvP", fadeOutNPC)
    fadeNPCPvPOnly:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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

    local fadeOutNPCOnlyFadeSecondaryPets = CreateCheckbox("fadeOutNPCOnlyFadeSecondaryPets", "Don't Fade Main Pet", fadeOutNPC)
    fadeOutNPCOnlyFadeSecondaryPets:SetPoint("TOPLEFT", fadeOutNPCWhitelistOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fadeOutNPCOnlyFadeSecondaryPets, "Don't Fade Main Pets", "Some Pets like Hunter Zoo all share the same NPC ID as the main Pet. This setting makes it so only the non-main Pets gets faded and the real one stays fully visible.", "This setting will only be available in Arena due to API limits.")

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

    local npcColorSettingsText = guiColorNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    npcColorSettingsText:SetPoint("LEFT", guiColorNpc, "TOPLEFT", 5, -5)
    npcColorSettingsText:SetText("NPC Color settings")
    local npcColorSettingsIcon = guiColorNpc:CreateTexture(nil, "ARTWORK")
    npcColorSettingsIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    npcColorSettingsIcon:SetSize(24, 24)
    npcColorSettingsIcon:SetPoint("RIGHT", npcColorSettingsText, "LEFT", -3, 0)

    local colorNPC = CreateCheckbox("colorNPC", "Enable Color NPC", guiColorNpc, nil, BBP.colorNPC)
    colorNPC:SetPoint("TOPLEFT", npcColorSettingsText, "BOTTOMLEFT", -10, pixelsOnFirstBox)
    CreateTooltip(colorNPC, "Color NPCs a color of your choice.")

    local colorNPCEverywhere = CreateCheckbox("colorNPCEverywhere", "Color NPC's Everywhere", colorNPC, nil, BBP.colorNPC)
    colorNPCEverywhere:SetPoint("TOPLEFT", colorNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(colorNPCEverywhere, "Color NPC's Everywhere", "Enable to color NPC's everywhere instead of just in PvE instances.")

    local colorNPCName = CreateCheckbox("colorNPCName", "Also Color Name Text", colorNPC, nil, BBP.colorNPC)
    colorNPCName:SetPoint("TOPLEFT", colorNPCEverywhere, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local npcColorBoss = CreateColorBox(colorNPC, "npcColorBoss", "Boss")
    npcColorBoss:SetPoint("TOPLEFT", colorNPCName, "BOTTOMLEFT", 0, -8)

    local npcColorMiniboss = CreateColorBox(colorNPC, "npcColorMiniboss", "Miniboss")
    npcColorMiniboss:SetPoint("TOPLEFT", npcColorBoss, "BOTTOMLEFT", 0, -2)

    local npcColorMinionCaster = CreateColorBox(colorNPC, "npcColorCaster", "Casters")
    npcColorMinionCaster:SetPoint("TOPLEFT", npcColorMiniboss, "BOTTOMLEFT", 0, -2)

    local npcColorMelee = CreateColorBox(colorNPC, "npcColorMelee", "Melee")
    npcColorMelee:SetPoint("TOPLEFT", npcColorMinionCaster, "BOTTOMLEFT", 0, -2)

    local npcColorTrivial = CreateColorBox(colorNPC, "npcColorTrivial", "Trivial")
    npcColorTrivial:SetPoint("TOPLEFT", npcColorMelee, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(npcColorTrivial, "Trivial", "Low-level trivial mobs.")

    local npcColorRareElite = CreateColorBox(colorNPC, "npcColorRareElite", "Rare / Rare-Elite")
    npcColorRareElite:SetPoint("TOPLEFT", npcColorTrivial, "BOTTOMLEFT", 0, -2)

    local npcColorMinus = CreateColorBox(colorNPC, "npcColorMinus", "Minus")
    npcColorMinus:SetPoint("TOPLEFT", npcColorRareElite, "BOTTOMLEFT", 0, -2)
    CreateTooltipTwo(npcColorMinus, "Minus", "Small squishy mobs.")

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
    reloadUiButton:SetText("Reload UI")
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

    local auraColorList = CreateList(listFrame, "auraColorList", BetterBlizzPlatesDB.auraColorList, BBP.RefreshAllNameplates, true, false, true, 440)
    auraColorList:SetPoint("TOPLEFT", -5, -10)

    local listExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listExplanationText:SetPoint("TOP", guiAuraColor, "BOTTOMLEFT", 180, 155)
    listExplanationText:SetText("Add name or spell ID. Case-insensitive.\n\nType a name or spell ID already in list to delete it")

    local prioText = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prioText:SetPoint("BOTTOM", auraColorList, "TOP", 76, 3)
    prioText:SetText("Priority Value")

    local auraColorExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    auraColorExplanationText:SetPoint("TOP", guiAuraColor, "TOP", 220, -127)
    auraColorExplanationText:SetText("Color nameplates\ndepending on their auras.\n \nAdd a name/spellID\nand select a color.\n\nCheck the \"Only mine\"\ncheckbox to only\ncolor own auras.")

    local auraColor = CreateCheckbox("auraColor", "Enable Color by Aura", guiAuraColor, nil, BBP.CreateUnitAuraEventFrame)
    auraColor:SetPoint("TOPLEFT", auraColorExplanationText, "BOTTOMLEFT", 10, -15)
    CreateTooltip(auraColor, "Chose nameplate color depending on the aura on them")

    local auraColorPvEOnly = CreateCheckbox("auraColorPvEOnly", "Enable in PvE only", auraColor)
    auraColorPvEOnly:SetPoint("TOPLEFT", auraColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(auraColorPvEOnly, "Aura Color for PvE only", "Disables aura coloring during PvP and also for Player nameplates in general everywhere else.")

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
    scrollFrame:SetScrollChild(contentFrame)

    local function Refresh()
        BBP.RefreshAllNameplateAuras()
    end

    local enableAuras = CreateCheckbox("enableNameplateAuraCustomisation", "Enable Aura Settings", contentFrame)
    CreateTooltipTwo(enableAuras, "Enable Nameplate Aura Customization", "Enable BetterBlizzPlates' own nameplate auras that lets you customize them with filters etc.")

    local resetAuras = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetAuras:SetSize(70, 22)
    resetAuras:SetText("Default")
    resetAuras:SetPoint("LEFT", enableAuras.Text, "RIGHT", 10, 0)
    CreateTooltipTwo(resetAuras, "Default", "Reset all nameplate aura settings back to default",
        "Your Whitelist and Blacklist are kept.\n\nTo delete blacklist or whitelist entirely go to Import & Export section and mouseover top right corner of the list buttons for a delete button to pop up.")
    resetAuras:SetScript("OnClick", function()
        StaticPopup_Show("BBP_RESET_NP_AURAS")
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
                LibDD:UIDropDownMenu_EnableDropDown(dropdown)
            else
                LibDD:UIDropDownMenu_DisableDropDown(dropdown)
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
            BetterBlizzPlatesDB.hideNameplateAuras = false
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
            btn:SetText(on and "Stop Test" or "Test Auras")
        end
    end

    local function TestButton(col, dy)
        local btn = CreateFrame("Button", nil, enableAuras, "UIPanelButtonTemplate")
        btn:SetSize(110, 28)
        Place(col, btn, -4, 34, dy)
        CreateTooltipTwo(btn, "Test Auras",
            "Enable a some test auras to configure your settings.")
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
    blacklistText:SetText("Blacklist")

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, LIST_H + 20)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, LIST_TOP)
    local whitelist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzPlatesDB.auraWhitelist, Refresh, nil, true, nil, 379, LIST_H, nil, true)
    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -60, -4)
    whitelistText:SetText("Whitelist")


    local pandemicIcon = CreateFrame("Frame", nil, contentFrame)
    pandemicIcon:SetSize(26, 26)
    pandemicIcon:SetPoint("CENTER", whitelist, "TOPRIGHT", -30, 11)
    pandemicIcon:EnableMouse(true)
    pandemicIcon.texture = pandemicIcon:CreateTexture(nil, "OVERLAY")
    pandemicIcon.texture:SetAllPoints()
    pandemicIcon.texture:SetAtlas("elementalstorm-boss-air")
    pandemicIcon.texture:SetDesaturated(true)
    TintFromColor(pandemicIcon.texture, "nameplateAuraPandemicGlowRGB", 1, 0, 0)
    CreateTooltipTwo(pandemicIcon, "Pandemic Glow",
        "Glow this aura while it is inside its pandemic window, on your own copy only.",
        "Greyed out while \"Pandemic\" under Aura Glows is on, which already glows every aura you cast.")

    local importantIcon = CreateFrame("Frame", nil, contentFrame)
    importantIcon:SetSize(16, 16)
    importantIcon:SetPoint("CENTER", pandemicIcon, "CENTER", -25, -2)
    importantIcon:EnableMouse(true)
    importantIcon.texture = importantIcon:CreateTexture(nil, "OVERLAY")
    importantIcon.texture:SetAllPoints()
    importantIcon.texture:SetAtlas("importantavailablequesticon")
    importantIcon.texture:SetDesaturated(true)
    TintFromColor(importantIcon.texture, "nameplateAuraImportantGlowRGB", 0, 1, 0)
    CreateTooltipTwo(importantIcon, "Important Glow",
        "Glow this aura in the Important color.",
        "Every whitelisted aura glow shares this one color; it cannot be set per spell.")

    local enlargedIcon = CreateFrame("Frame", nil, contentFrame)
    enlargedIcon:SetSize(18, 18)
    enlargedIcon:SetPoint("CENTER", importantIcon, "CENTER", -23, -1)
    enlargedIcon:EnableMouse(true)
    enlargedIcon.texture = enlargedIcon:CreateTexture(nil, "OVERLAY")
    enlargedIcon.texture:SetAllPoints()
    enlargedIcon.texture:SetAtlas("ui-hud-minimap-zoom-in")
    CreateTooltipTwo(enlargedIcon, "Enlarged Aura",
        "Make this aura larger and at the front.",
        "Square by default; size and shape are set under Style. Combine with Important Glow to also glow it, in its shared Enlarged own color.")

    local onlyMeIcon = CreateFrame("Frame", nil, contentFrame)
    onlyMeIcon:SetSize(18, 20)
    onlyMeIcon:SetPoint("CENTER", enlargedIcon, "CENTER", -24, 1)
    onlyMeIcon:EnableMouse(true)
    onlyMeIcon.texture = onlyMeIcon:CreateTexture(nil, "OVERLAY")
    onlyMeIcon.texture:SetAllPoints()
    onlyMeIcon.texture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    CreateTooltipTwo(onlyMeIcon, "Only My Aura", "Only show the aura when you cast it.")

    local COL_ENEMY, COL_FRIENDLY, COL_PERSONAL = 50, 300, 525
    local listBottom = LIST_TOP - LIST_H - 38

    local filterCaveat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    filterCaveat:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", COL_ENEMY - 4, listBottom)
    filterCaveat:SetWidth(620)
    filterCaveat:SetJustifyH("LEFT")
    filterCaveat:SetText("|cffffd100Note:|r Only |cff7fff7fdebuffs on enemies|r and |cff7fff7fbuffs on friendly units|r can be filtered by spell. The whitelist and blacklist do nothing on |cffff7f7fbuffs on enemies|r and |cffff7f7fdebuffs on friendly units|r.")

    local masterY = listBottom - 34
    enableAuras:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", COL_ENEMY - 4, masterY)

    local FILTER_STEP = 19
    local enemy    = NewColumn(COL_ENEMY, masterY - 26, FILTER_STEP)
    local friendly = NewColumn(COL_FRIENDLY, masterY - 6, FILTER_STEP)
    local personal = NewColumn(COL_PERSONAL, masterY - 6, FILTER_STEP)

    GroupHeader(enemy, "Enemy Nameplates", 1, 0, 0)
    GroupHeader(friendly, "Friendly Nameplates")

    local FILTER_GROUPS = {
        { col = enemy,    prefix = "otherNpBuff",      title = "Enemy Buffs",      helpful = true,  byName = false },
        { col = enemy,    prefix = "otherNpdeBuff",    title = "Enemy Debuffs",    helpful = false, byName = true, mine = true },
        { col = friendly, prefix = "friendlyNpBuff",   title = "Friendly Buffs",   helpful = true,  byName = true, mine = true },
        { col = friendly, prefix = "friendlyNpdeBuff", title = "Friendly Debuffs", helpful = false, byName = false, dispel = true },
    }

    for _, spec in ipairs(FILTER_GROUPS) do
        local col = spec.col
        local kind = spec.helpful and "Buffs" or "Debuffs"

        local enable = Check(col, spec.prefix .. "Enable",
            spec.helpful and "Show BUFFS" or "Show DEBUFFS", nil, 0,
            spec.title, "Show all " .. kind:lower() .. ".",
            "Every filter under this one, except the blacklist, cuts the list down to just that "
            .. "filter. Several filters stack, so you get each of them and nothing else.\n\n"
            .. "All " .. kind:lower() .. " only ever show with no filter checked.")

        local function Sub(key, label, title, desc, sub)
            return Check(col, spec.prefix .. key, label, enable, 15, title, desc, sub)
        end

        local blackList = spec.byName and Sub("FilterBlacklist", "Blacklist", "Blacklist",
            "Hide blacklisted " .. kind:lower())
        local watchList = spec.byName and Sub("FilterWatchList", "Whitelist", "Whitelist",
            "Only show whitelisted " .. kind:lower() .. ".\n(Plus other filters)")

        if spec.helpful then
            Sub("FilterDefensives", "Defensives", "Defensives",
                "Only show big and external defensives.\n(Plus other filters)",
                "Big Buffs Icon setting below takes priority over this setting and instead shows all Big Buffs next to healthbar instead of a small icon above.")
            Sub("FilterImportantBuffs", "Important", "Important Buffs",
                "Only show important buffs.\n(Plus other filters)",
                "Big Buffs Icon setting below takes priority over this setting and instead shows all Big Buffs next to healthbar instead of a small icon above.")
            local purgeable = Sub("FilterPurgeable", "Purgeable", "Purgeable Buffs",
                "Only show purgeable/stealable buffs.\n(Plus other filters)")
            Beside(purgeable, spec.prefix .. "FilterPurgeableAny", "Always show", purgeable,
                "Always show",
                "Always show purgeable auras regardless if you have a dispel or not")
        else
            local ccTitle, ccDesc, ccSub = "Crowd Control",
                "Only show crowd control.\n(Plus other filters)",
                "Big CC Icon setting below takes priority over this setting and instead shows all CC next to healthbar instead of a small icon above."
            local ccAnchor = watchList or blackList
            if ccAnchor then
                Beside(ccAnchor, spec.prefix .. "FilterCC", "Crowd Control", enable,
                    ccTitle, ccDesc, ccSub)
            else
                Sub("FilterCC", "Crowd Control", ccTitle, ccDesc, ccSub)
            end
            if spec.dispel then
                local dispellable = Sub("FilterPurgeable", "Dispellable", "Dispellable Debuffs",
                    "Only show debuffs you can dispel.\n(Plus other filters)")
                Beside(dispellable, spec.prefix .. "FilterPurgeableAny", "Always show", dispellable,
                    "Always show",
                    "Always show dispellable auras regardless if you have a dispel or not")
            end
            Sub("FilterBlizzard", "Blizzard Default Filter", "Blizzard Default Filter",
                "Only show debuffs that are in the Blizzard Default nameplate filter\n(most of own auras + some cc etc) (Plus other filters).")
        end

        Sub("FilterLessMinite", "Under one min", "Under one min",
            "Only show " .. kind:lower() .. " under one minute long.\n(Plus other filters)")

        if spec.mine then
            Sub("FilterOnlyMe", "Only mine",
                spec.helpful and "Only my buffs" or "Only my debuffs",
                "Only show my " .. kind:lower())
        end

        col.y = col.y - 2
    end

    local _, playerClass = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[playerClass]
    GroupHeader(personal, "Personal Bar",
        classColor and classColor.r or 1, classColor and classColor.g or 0.5,
        classColor and classColor.b or 0, true)

    local prdAuras = Check(personal, "prdAurasEnabled", "Show BUFFS", nil, 0,
        "Auras On Personal Resource Display",
        "Show your important buffs and defensives above the Personal Resource Display.",
        nil, "ANCHOR_LEFT")
    prdAuras:HookScript("OnClick", function()
        BBP.SetupPRDAuras()
    end)

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

    Header(left, "Big CC Icon")
    Check(left, "nameplateAuraCCOnEnemyPlayers", "Show On Enemy Players", nil, 0,
        "Crowd Control On Enemy Players",
        "Show a large crowd control icon beside the healthbar on enemy player nameplates.",
        "While this is on, crowd control never appears in the normal debuff row for enemy players.")
    Check(left, "nameplateAuraCCOnFriendlyPlayers", "Show On Friendly Players", nil, 0,
        "Crowd Control On Friendly Players",
        "Show a large crowd control icon beside the healthbar on friendly player nameplates.",
        "While this is on, crowd control never appears in the normal debuff row for friendly players.")
    Check(left, "nameplateAuraCCOnNpcs", "Show On NPCs", nil, 0,
        "Crowd Control On NPCs",
        "Show a large crowd control icon beside the healthbar on NPC nameplates.",
        "While this is on, crowd control never appears in the normal debuff row for NPCs.")
    local ccBlizzardPvE = Check(left, "nameplateAuraCCBlizzardInPvE", "Blizzards In PvE (Friendly)", nil, 0,
        "Show Blizzard's In PvE (Friendly Only)",
        "Show Blizzards default Big CC Icon on friendly nameplates in PvE (since addons cant modify default nameplates)")
    ccBlizzardPvE:HookScript("OnClick", function()
        BBP.RefreshBlizzardAuraCVarOverrides()
    end)
    local ccIconScale = Slider(left, "CC Icon Scale", 0.4, 3, 0.01, "ccIconScale", -2, nil, nil, nil, -5)
    local ccIconXPos = Slider(left, "CC Icon X", -100, 100, 1, "ccIconXPos", -2, nil, nil, nil, -5)
    local ccIconYPos = Slider(left, "CC Icon Y", -100, 100, 1, "ccIconYPos", -2, nil, nil, nil, -5)
    local ccIconAnchor = CreateAnchorDropdown("ccIconAnchor", contentFrame, "RIGHT", "ccIconAnchor",
        Refresh, { label = "CC Icon Anchor", anchorFrame = ccIconYPos, x = -22, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(ccIconAnchor, "CC Icon Anchor", "Which side of the healthbar the crowd control icon sits on.")
    ccIconAnchor.bbpDisableWhen = "combineBigAuraIcons"
    table.insert(dropdowns, ccIconAnchor)
    left.y = left.y - 60

    local combineBigIcons = Check(left, "combineBigAuraIcons", "Combine Big CC and Buffs", nil, 0,
        "Combine Big CC and Big Buffs Icons",
        "Put both big icon groups on one shared anchor instead of two separate ones.",
        "Crowd control is anchored first and the big buffs queue up after it, following along as crowd control comes and goes. The CC and Buff Icon X/Y sliders still nudge each group.")
    combineBigIcons:HookScript("OnClick", function()
        UpdatePanelState()
    end)
    local combinedAnchor = CreateAnchorDropdown("combinedBigIconAnchor", contentFrame, "RIGHT",
        "combinedBigIconAnchor", Refresh,
        { label = "Combined Anchor", anchorFrame = combineBigIcons, x = -17, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(combinedAnchor, "Combined Anchor",
        "Which side of the healthbar the combined crowd control and buff run sits on.")
    combinedAnchor.bbpShowWhen = "combineBigAuraIcons"
    table.insert(dropdowns, combinedAnchor)
    left.y = left.y - 60

    Header(mid, "Big Buff Icon")
    Check(mid, "nameplateAuraBuffsOnEnemyPlayers", "Show On Enemy Players", nil, 0,
        "Buffs On Enemy Players",
        "Show large defensive and important buff icons beside the healthbar on enemy player nameplates.",
        "While this is on, defensives and important buffs never appear in the normal buff row for enemy players.")
    Check(mid, "nameplateAuraBuffsOnFriendlyPlayers", "Show On Friendly Players", nil, 0,
        "Buffs On Friendly Players",
        "Show large defensive and important buff icons beside the healthbar on friendly player nameplates.",
        "While this is on, defensives and important buffs never appear in the normal buff row for friendly players.")
    Check(mid, "nameplateAuraBuffsOnNpcs", "Show On NPCs", nil, 0,
        "Buffs On NPCs",
        "Show large defensive and important buff icons beside the healthbar on NPC nameplates.",
        "While this is on, defensives and important buffs never appear in the normal buff row above debuffs for NPCs.")
    local buffsBlizzardPvE = Check(mid, "nameplateAuraBuffsBlizzardInPvE", "Blizzards In PvE (Friendly)", nil, 0,
        "Show Blizzard's In PvE (Friendly Only)",
        "Show Blizzards default Big Buff Icon on friendly nameplates in PvE (since addons cant modify default nameplates)")
    buffsBlizzardPvE:HookScript("OnClick", function()
        BBP.RefreshBlizzardAuraCVarOverrides()
    end)
    local buffIconScale = Slider(mid, "Buff Icon Scale", 0.4, 3, 0.01, "buffIconScale", -2, nil, nil, nil, -5)
    local buffIconXPos = Slider(mid, "Buff Icon X", -100, 100, 1, "buffIconXPos", -2, nil, nil, nil, -5)
    local buffIconYPos = Slider(mid, "Buff Icon Y", -100, 100, 1, "buffIconYPos", -2, nil, nil, nil, -5)
    local buffIconAnchor = CreateAnchorDropdown("buffIconAnchor", contentFrame, "LEFT", "buffIconAnchor",
        Refresh, { label = "Buff Icon Anchor", anchorFrame = buffIconYPos, x = -22, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(buffIconAnchor, "Buff Icon Anchor", "Which side of the healthbar the buff icons sit on.")
    buffIconAnchor.bbpDisableWhen = "combineBigAuraIcons"
    table.insert(dropdowns, buffIconAnchor)
    mid.y = mid.y - 60

    local moveNormalBuffs = Check(mid, "moveNormalBuffs", "Move Normal Buffs", nil, 0,
        "Move Normal Buffs",
        "Move the normal buff row off the top of the nameplate and onto a side of the healthbar.",
        "If Big CC or Big Buff Icon already sits on the same side as normal buffs the normal buff row starts after it.")
    moveNormalBuffs:HookScript("OnClick", function()
        UpdatePanelState()
    end)
    local buffRowAnchor = CreateAnchorDropdown("moveNormalBuffsAnchor", contentFrame, "LEFT",
        "moveNormalBuffsAnchor", Refresh,
        { label = "Normal Buffs Anchor", anchorFrame = moveNormalBuffs, x = -17, y = -34 }, 140, nil,
        { "LEFT", "RIGHT", "TOP" })
    CreateTooltipTwo(buffRowAnchor, "Normal Buffs Anchor",
        "Which side of the healthbar the normal buff row sits on.")
    buffRowAnchor.bbpShowWhen = "moveNormalBuffs"
    table.insert(dropdowns, buffRowAnchor)
    mid.y = mid.y - 60

    Header(right, "Aura Glows")

    local TIERS = {
        { key = "nameplateAuraDefensiveGlow", label = "Defensives", color = "nameplateAuraDefensiveGlowRGB",
          title = "Defensives", desc = "Glow on defensive buffs." },
        { key = "nameplateAuraImportantGlow", label = "Important", color = "nameplateAuraImportantGlowRGB",
          title = "Important", desc = "Glow on important auras." },
        { key = "nameplateAuraCCGlow", label = "Crowd Control", color = "nameplateAuraCCGlowRGB",
          title = "Crowd Control", desc = "Glow on crowd control." },
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

    local ccDispelColor = Beside(ccGlow, "nameplateAuraCCGlowDispelColor", "Dispel Color", ccGlow,
        "Dispel Color", "Color CC after dispel type instead",
        "Crowd control without a dispel type keeps the color picked on the left (Usually red).")
    ccDispelColor:ClearAllPoints()
    ccDispelColor:SetPoint("LEFT", ccGlowSwatch, "RIGHT", -25, 0)

    local purgeGlow = Check(right, "otherNpBuffPurgeGlow", "Purgeable", nil, 0,
        "Glow on Purgeable",
        "Bright blue glow on purgeable buffs in the normal buff row above the nameplate if you have a dispel.")
    local purgeAlways = Beside(purgeGlow, "alwaysShowPurgeTexture", "Always", purgeGlow,
        "Always", "Glow on anything purgeable or soothable, whether or not you can remove it.")

    local purgeColorToggle = Beside(purgeAlways, "npAuraPurgeGlowColorEnabled", "", purgeGlow,
        "Change Purge Glow Color",
        "Use your own color for the purge glow instead of the default blue.")
    local purgeColorSwatch = Swatch("npAuraPurgeGlowRGB", Refresh)
    purgeColorSwatch:SetPoint("LEFT", purgeColorToggle, "RIGHT", -2, 0)
    purgeColorSwatch.bbpRequires = { "otherNpBuffPurgeGlow", "npAuraPurgeGlowColorEnabled" }
    purgeColorSwatch:EnableMouse(true)
    CreateTooltipTwo(purgeColorSwatch, "Change Purge Glow Color",
        "Use your own color for the purge glow instead of the default blue.")
    purgeColorToggle:HookScript("OnClick", function()
        UpdatePanelState()
    end)
    purgeGlow:HookScript("OnClick", function()
        UpdatePanelState()
    end)

    local pandemic = Check(right, "otherNpdeBuffPandemicGlow", "Pandemic", nil, 0,
        "Pandemic Glow",
        "Show pandemic glow on all your own auras.",
        "For individual aura glow add to whitelist and enable pandemic glow checkbox there.")
    local pandemicSwatch = Swatch("nameplateAuraPandemicGlowRGB", Refresh)
    pandemicSwatch:SetPoint("LEFT", pandemic.Text, "RIGHT", 4, 0)
    pandemic:HookScript("OnClick", function()
        if BBP.RefreshAuraWhitelistDisplay then BBP.RefreshAuraWhitelistDisplay() end
    end)

    StartRow(RowBottom() - SECTION_GAP)
    mid.x = mid.x + 10
    right.x = right.x + 12

    Header(left, "Size & Position")
    Slider(left, "Aura Scale", 0.3, 3, 0.01, "bbpAuraScale", 0, "Aura Scale",
        "The size of all auras.")
    Slider(left, "Debuff Scale", 0.3, 3, 0.01, "nameplateAuraDebuffScale", 0, "Debuff Scale",
        "The size of the normal debuffs on top of the nameplate.")
    Slider(left, "Buff Scale", 0.3, 3, 0.01, "nameplateAuraBuffScale", 0, "Buff Scale",
        "The size of the normal buffs on top of the nameplate.")
    Slider(left, "Enlarged Aura Scale", 1, 2, 0.01, "nameplateAuraEnlargedScale", 0, "Enlarged Aura Scale",
        "The size of Enlarged Auras.")
    local AURA_POS_NOTE = "This only affects the normal debuffs and buffs row, not Big CC or Big Buffs."
    local auraPosX = Slider(left, "Auras Horizontal Position", -300, 300, 0.5, "nameplateDebuffXPadding", 0)
    CreateTooltipTwo(auraPosX, "Auras Horizontal Position",
        "Move the aura rows left or right.", AURA_POS_NOTE)
    local bbpDebuffPadding = Slider(left, "Auras Vertical Position", -100, 100, 1, "bbpDebuffPadding", 0)
    CreateTooltipTwo(bbpDebuffPadding, "Auras Vertical Position",
        "Move the aura rows up or down.", AURA_POS_NOTE)
    Slider(left, "Horizontal Gap", 0, 20, 0.5, "nameplateAuraWidthGap")
    Slider(left, "Vertical Gap", 0, 20, 0.5, "nameplateAuraHeightGap")
    Slider(left, "Auras Per Row (Enemy)", 1, 16, 1, "nameplateAuraRowAmount")
    Slider(left, "Auras Per Row (Friendly)", 1, 16, 1, "nameplateAuraRowFriendlyAmount")
    local sortDuration, sortDurationReverse
    sortDuration = Check(left, "sortDurationAuras", "Sort By Duration", nil, 0,
        "Sort By Duration", "Shortest remaining first.")
    sortDurationReverse = Check(left, "sortDurationAurasReverse", "Reverse Duration Sort", nil, 0,
        "Reverse Duration Sort", "Longest remaining first.")

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
    Check(left, "sortEnlargedAurasFirst", "Sort Enlarged First", nil, 0,
        "Sort Enlarged First",
        "Put the enlarged auras at the front of the row instead of the back.")

    Header(mid, "Style")
    local squareAuras, tallerAuras
    squareAuras = Check(mid, "nameplateAuraSquare", "Square Auras")
    tallerAuras = Check(mid, "nameplateAuraTaller", "Taller Auras", nil, 0, "Taller Auras",
        "Make auras a little bit taller and show more of the icon texture.")
    squareAuras:HookScript("OnClick", function(self)
        ExclusiveSort(self, tallerAuras, "nameplateAuraTaller")
    end)
    tallerAuras:HookScript("OnClick", function(self)
        ExclusiveSort(self, squareAuras, "nameplateAuraSquare")
    end)
    Check(mid, "nameplateAuraPixelBorder", "Pixel Border", nil, 0, "Pixel Border Auras",
        "Adds a pixel border around the aura instead of Blizzards new rounded shadow.")
    Check(mid, "npColorAuraBorder", "Color Border By Type", nil, 0, "Color Border By Dispel Type",
        "Color the borders by their dispel type.")
    Check(mid, "nameplateAuraRightToLeft", "Grow Auras Right To Left", nil, 0, "Grow Auras Right To Left",
        "Grow the debuff row right to left instead.")
    Check(mid, "nameplateAuraGrowDownwards", "Grow Auras Top to Bottom", nil, 0,
        "Grow Auras Top to Bottom",
        "Fill extra rows downwards instead of upwards.")
    Check(mid, "otherNpBuffBlueBorder", "Blue Border for Buffs", nil, 0, "Blue Border for Buffs",
        "Adds a blue border for buffs on the normal buff row above the nameplate (not Big Buffs).")
    Check(mid, "nameplateAurasEnemyCenteredDebuffs", "Center Debuffs On Enemies", nil, 0,
        "Center Debuffs On Enemies",
        "Center the debuff row over the healthbar.")
    Check(mid, "nameplateAurasEnemyCenteredBuffs", "Center Buffs On Enemies", nil, 0,
        "Center Buffs On Enemies", "Center the normal buff row (not Big Buff Icon) over enemy healthbars.")
    Check(mid, "nameplateAurasFriendlyCenteredDebuffs", "Center Debuffs On Friendlies", nil, 0,
        "Center Debuffs On Friendlies", "Center the debuff row over friendly healthbars.")
    Check(mid, "nameplateAurasFriendlyCenteredBuffs", "Center Buffs On Friendlies", nil, 0,
        "Center Buffs On Friendlies", "Center the normal buff row (not Big Buff Icon) over friendly healthbars.")
    Check(mid, "nameplateAuraEnlargedSquare", "Square Enlarged", nil, 0, "Square Enlarged Auras",
        "Make auras marked Enlarged in the whitelist square.")
    Check(mid, "enlargeAllCC", "Enlarge All CC", nil, 0, "Enlarge All Crowd Control",
        "Make every CC have the Enlarged size.",
        "Only affects the debuff row. The Big CC Icon beside the healthbar has its own scale.")
    Check(mid, "enlargeAllImportantBuffs", "Enlarge All Important", nil, 0,
        "Enlarge All Important Buffs",
        "Make every important buff have the Enlarged size.",
        "Only affects the buff row. The Big Buff Icon beside the healthbar has its own scale.")

    mid.y = mid.y - SECTION_GAP

    Header(mid, "Visibility")
    local playersOnly = Check(mid, "nameplateAuraPlayersOnly", "Players Only", nil, 0,
        "Players Only", "Only show auras on player nameplates.")
    Beside(playersOnly, "nameplateAuraPlayersOnlyShowTarget", "Show Target", playersOnly,
        "Show Target", "Keep showing auras on your target even when it is not a player.")
    Check(mid, "hideNameplateAuraTooltip", "Hide Tooltips", nil, 0,
        "Hide Tooltips", "Stop nameplate auras showing a tooltip on mouseover.")
    local auraTooltipSpellID = Check(mid, "auraTooltipSpellID", "Spell ID in Tooltip", nil, 0,
        "Spell ID in Tooltip", "Show aura spell IDs in tooltips.")
    auraTooltipSpellID:HookScript("OnClick", function(self)
        BBP.ApplyAuraTooltipSpellID(not self:GetChecked())
    end)

    local limitsHeader = Header(right, "Limits")

    local limitsNote = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    limitsNote:SetPoint("BOTTOMLEFT", limitsHeader, "TOPLEFT", 0, 3)
    limitsNote:SetJustifyH("LEFT")
    limitsNote:SetText("Proper limits wont come\nuntil 12.1.5 due to API")

    local ROUGH_LIMIT_NOTE = "A rough cap, not an exact one. The row is built from several groups "
        .. "and each one carries this limit of its own, so with filters stacked you can end up "
        .. "seeing more than this."
    local maxDebuffs = Slider(right, "Max Debuffs", 1, 24, 1, "maxAurasOnNameplate", 0)
    CreateTooltipTwo(maxDebuffs, "Max Debuffs",
        "How many debuffs the row above the nameplate may show.", ROUGH_LIMIT_NOTE)
    local maxBuffs = Slider(right, "Max Buffs", 1, 24, 1, "maxBuffsOnNameplate", 0)
    CreateTooltipTwo(maxBuffs, "Max Buffs",
        "How many buffs the row above the nameplate may show.", ROUGH_LIMIT_NOTE)
    Slider(right, "Max Buffs on Side", 1, 12, 1, "nameplateAuraBuffLimit", 0,
        "Max Buffs on Side",
        "How many of the big buff icons next to the healthbar to show.")
    local maxCC = Slider(right, "Max Crowd Control", 1, 6, 1, "ccIconLimit")
    CreateTooltipTwo(maxCC, "Max Crowd Control",
        "How many of the big crowd control icons next to the healthbar to show.", ROUGH_LIMIT_NOTE)

    StartRow(RowBottom() - SECTION_GAP)
    mid.x = mid.x + 10

    Header(left, "Cooldown Text")
    local showCd = Check(left, "showDefaultCooldownNumbersOnNpAuras", "Show Cooldown Text", nil, 0,
        "Show Cooldown Text", "Show the remaining duration on each aura.")
    Check(left, "hideNpAuraSwipe", "Hide Swipe", showCd, 14, "Hide Swipe",
        "Remove the dark cooldown sweep from the icon.")
    Check(left, "nameplateAuraHideLongDurationText", "Hide Over A Minute", showCd, 14,
        "Hide Text Over A Minute",
        "Hide duration text on nameplate auras when they're longer than 1 min")
    Check(left, "nameplateAuraUseBlizzardCdText", "Use Blizzard Numbers", showCd, 14,
        "Use Blizzard Cooldown Numbers",
        "Show the default Blizzard CD numbers instead.")
    Check(left, "nameplateAuraMillisecondsBuffs", "Milliseconds On Buffs", showCd, 14,
        "Milliseconds On Buffs",
        "Show decimals on big buffs once they are below 6 seconds.")
    Check(left, "nameplateAuraMillisecondsCC", "Milliseconds On CC", showCd, 14,
        "Milliseconds On Crowd Control",
        "Show decimals on CC once they are below 6 seconds")
    Check(left, "npAuraCdTextBigOnly", "Only On Big Icons", showCd, 14,
        "Only On Big Icons",
        "Only show duration text on Big CC and Big Buff Icons.")
    local timerColor = Check(left, "nameplateAuraTimerColor", "Color Timer Text", showCd, 14, "Color Timer Text",
        "Color the duration text, switching to the low color under the threshold.\n\n|cff32f795Right-click for options.|r")
    timerColor:HookScript("OnClick", Refresh)

    local timerColorOptionsFrame
    local function OpenTimerColorOptionsWindow()
        if not timerColorOptionsFrame then
            timerColorOptionsFrame = CreateFrame("Frame", "BBPAuraTimerColorOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            timerColorOptionsFrame:SetSize(200, 155)
            timerColorOptionsFrame:SetPoint("CENTER")
            timerColorOptionsFrame:SetFrameStrata("HIGH")
            timerColorOptionsFrame:SetMovable(true)
            timerColorOptionsFrame:EnableMouse(true)
            timerColorOptionsFrame:RegisterForDrag("LeftButton")
            timerColorOptionsFrame:SetScript("OnDragStart", timerColorOptionsFrame.StartMoving)
            timerColorOptionsFrame:SetScript("OnDragStop", timerColorOptionsFrame.StopMovingOrSizing)
            timerColorOptionsFrame.title = timerColorOptionsFrame:CreateFontString(nil, "OVERLAY")
            timerColorOptionsFrame.title:SetFontObject("GameFontHighlight")
            timerColorOptionsFrame.title:SetPoint("LEFT", timerColorOptionsFrame.TitleBg, "LEFT", 5, 0)
            timerColorOptionsFrame.title:SetText("Timer Text Colors")

            local lowThreshold = CreateSlider(timerColorOptionsFrame, "Low Threshold (sec)", 1, 30, 1,
                "nameplateAuraTimerLowThreshold", nil, 150)
            lowThreshold:SetPoint("TOP", timerColorOptionsFrame, "TOP", 0, -45)
            lowThreshold.integerOnly = true
            CreateTooltipTwo(lowThreshold, "Low Threshold",
                "Seconds remaining at which the duration text switches to the low color.")

            local baseColorBox = CreateColorBox(timerColorOptionsFrame, "nameplateAuraTimerBaseColor",
                "Normal Color", Refresh)
            baseColorBox:SetPoint("TOPLEFT", timerColorOptionsFrame, "TOPLEFT", 18, -80)

            local lowColorBox = CreateColorBox(timerColorOptionsFrame, "nameplateAuraTimerLowColor",
                "Low Color", Refresh)
            lowColorBox:SetPoint("TOPLEFT", baseColorBox, "BOTTOMLEFT", 0, -10)

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

    Slider(left, "Aura CD Text Size", 0.1, 2, 0.01, "defaultNpAuraCdSize", 12, "Aura CD Text Size",
        "Size of the duration text on the debuff and buff rows above the nameplate.", showCd, -4)
    Slider(left, "Big Icon CD Text Size", 0.1, 2, 0.01, "bigNpAuraCdSize", 12, "Big Icon CD Text Size",
        "Size of the duration text on the Big CC Icon and Big Buff Icon beside the healthbar.", showCd, -4)

    local cdFontEnabled = Check(left, "npAuraCdFontEnabled", "Change Cooldown Font", showCd, 14,
        "Custom Timer Font", "Use your own font for the duration text on auras.",
        "Ignored while Use Blizzard Numbers is on, since the countdown is drawn by the game then.")
    local cdFontDropdown = CreateFontDropdown("npAuraCdFontDropdown", contentFrame, "Select Font",
        "npAuraCdFont", Refresh,
        { label = "Timer Font", anchorFrame = cdFontEnabled, x = 4, y = 4 }, 140)
    CreateTooltipTwo(cdFontDropdown, "Timer Font", "Font used for the duration text on auras.")
    cdFontDropdown.bbpRequires = "npAuraCdFontEnabled"
    table.insert(plainDropdowns, cdFontDropdown)
    cdFontEnabled:HookScript("OnClick", function()
        Refresh()
        UpdatePanelState()
    end)
    left.y = left.y - 36

    Header(mid, "Stack Text")
    local showStackText = Check(mid, "npAuraShowStackText", "Show Stack Text")
    Slider(mid, "Stack Text Scale", 0.3, 3, 0.01, "nameplateAuraCountScale", -4, nil, nil, showStackText, -6)
    mid.y = mid.y - 6
    Slider(mid, "Stack Text X", -30, 30, 1, "npAuraStackTextXPos", -4, nil, nil, showStackText)
    local stackTextY = Slider(mid, "Stack Text Y", -30, 30, 1, "npAuraStackTextYPos", -4, nil, nil,
        showStackText)
    local stackTextAlign = CreateAnchorDropdown("npAuraStackTextAlignDropdown", contentFrame, "RIGHT",
        "npAuraStackTextAlign", Refresh,
        { label = "Stack Text Align", anchorFrame = stackTextY, x = -22, y = -34 }, 140, nil,
        { "LEFT", "CENTER", "RIGHT" })
    table.insert(dropdowns, stackTextAlign)
    mid.y = mid.y - 50

    local stackFontEnabled = Check(mid, "npAuraStackFontEnabled", "Change Stack Font", showStackText, -4)
    local stackFontDropdown = CreateFontDropdown("npAuraStackFontDropdown", contentFrame, "Select Font",
        "npAuraStackFont", Refresh,
        { label = "Stack Font", anchorFrame = stackFontEnabled, x = 4, y = 4 }, 140)
    stackFontDropdown.bbpRequires = "npAuraStackFontEnabled"
    table.insert(plainDropdowns, stackFontDropdown)
    stackFontEnabled:HookScript("OnClick", function()
        Refresh()
        UpdatePanelState()
    end)
    mid.y = mid.y - 50

    local stackTextColor = Swatch("npAuraStackTextColor", Refresh)
    stackTextColor.text:SetText("Stack Text Color")
    Place(mid, stackTextColor, -8, CHECK_STEP, 10)

    StartRow(RowBottom() - SECTION_GAP)

    Header(left, "Personal Resource Display")
    Slider(left, "PRD Aura Scale", 0.3, 3, 0.01, "prdAuraScale", 0, "PRD Aura Scale",
        "Size of the buffs above the Personal Resource Display.", prdAuras)
    Slider(left, "PRD Aura X", -100, 100, 0.5, "prdAuraXPos", 0, nil, nil, prdAuras)
    Slider(left, "PRD Aura Y", -100, 100, 0.5, "prdAuraYPos", 0, nil, nil, prdAuras)

    mid.y = mid.y - HEADER_STEP
    Slider(mid, "PRD Auras Per Row", 1, 16, 1, "prdAuraRowAmount", 0, nil, nil, prdAuras)
    Slider(mid, "PRD Max Auras", 1, 12, 1, "prdAuraLimit", 0, "PRD Max Auras",
        "How many auras each tier may show. A limit per tier, as on nameplates.", prdAuras)

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


    local comboPointsText = guiCVarControl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    comboPointsText:SetPoint("TOPLEFT", guiCVarControl, "TOPLEFT", 20, -25)
    comboPointsText:SetText("Resource Settings (Combo points etc)")
    local comboPointIcon = guiCVarControl:CreateTexture(nil, "ARTWORK")
    comboPointIcon:SetAtlas("ClassOverlay-ComboPoint")
    comboPointIcon:SetSize(16, 16)
    comboPointIcon:SetPoint("RIGHT", comboPointsText, "LEFT", -3, 0)

    local nameplateResourceOnTarget = CreateCheckbox("nameplateResourceOnTarget", "Show resource on target nameplate", guiCVarControl, true, BBP.TargetResourceUpdater)
    nameplateResourceOnTarget:SetPoint("TOPLEFT", comboPointsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(nameplateResourceOnTarget, "Nameplate Resource", "MIDNIGHT: This needs Personal Resource Display enabled in Blizzard settings. You can then also hide the Health/Mana in Edit Mode for it if you want.\n\nShow combo points, warlock shards, arcane charges etc on nameplates.", nil, nil, "nameplateResourceOnTarget")
    nameplateResourceOnTarget:HookScript("OnClick", function()
        BBP.RegisterTargetCastingEvents()
        BBP.ApplyNameplateWidth()
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
            end
        end
    end)

    local instantComboPoints = CreateCheckbox("instantComboPoints", "Instant Combo Points", guiCVarControl, nil, BBP.InstantComboPoints)
    instantComboPoints:SetPoint("TOPLEFT", nameplateResourceOnTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(instantComboPoints, "Instant Combo Points", "Remove the combo point animations for instant feedback. Currently works for:\n|cFFFFF569Rogue|r\n|cFFFF7D0ADruid|r\n|cFF00FF96Monk|r\n|cFF3FC7EBMage|r\n|cFFF58CBAPaladin|r")
    instantComboPoints:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
            if BetterBlizzFramesDB then
                BetterBlizzFramesDB.instantComboPoints = false
            end
        end
    end)

    local hideResourceFrame = CreateCheckbox("hideResourceFrame", "Hide resource on Personal Bar", guiCVarControl, nil, BBP.HideResourceFrames)
    hideResourceFrame:SetPoint("TOPLEFT", instantComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hideResourceFrame:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            if prdClassFrame then
                prdClassFrame:SetAlpha(1)
            end
        end
    end)
    CreateTooltipTwo(hideResourceFrame, "Hide resource on Personal Bar", "Hide Resource/Power under Personal Resource Bar. Rogue combopoints, Warlock shards etc.\n\n|cff32f795Right-click for class specific options.|r")

    local classOptionsFrame
    local function OpenClassSpecificWindow()
        if not classOptionsFrame then
            -- Create a new frame if it doesn't exist
            classOptionsFrame = CreateFrame("Frame", "ClassOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            classOptionsFrame:SetSize(185, 210)
            classOptionsFrame:SetPoint("CENTER")
            classOptionsFrame:SetFrameStrata("HIGH")
            classOptionsFrame:SetMovable(true)
            classOptionsFrame:EnableMouse(true)
            classOptionsFrame:RegisterForDrag("LeftButton")
            classOptionsFrame:SetScript("OnDragStart", classOptionsFrame.StartMoving)
            classOptionsFrame:SetScript("OnDragStop", classOptionsFrame.StopMovingOrSizing)
            classOptionsFrame.title = classOptionsFrame:CreateFontString(nil, "OVERLAY")
            classOptionsFrame.title:SetFontObject("GameFontHighlight")
            classOptionsFrame.title:SetPoint("LEFT", classOptionsFrame.TitleBg, "LEFT", 5, 0)
            classOptionsFrame.title:SetText("Class Specific Options")

            -- Create checkboxes for each class
            local classes = {
                { class = "Druid", var = "hideResourceFrameNoDruid", color = RAID_CLASS_COLORS["DRUID"] },
                { class = "Rogue", var = "hideResourceFrameNoRogue", color = RAID_CLASS_COLORS["ROGUE"] },
                { class = "Warlock", var = "hideResourceFrameNoWarlock", color = RAID_CLASS_COLORS["WARLOCK"] },
                { class = "Paladin", var = "hideResourceFrameNoPaladin", color = RAID_CLASS_COLORS["PALADIN"] },
                { class = "Death Knight", var = "hideResourceFrameNoDeathKnight", color = RAID_CLASS_COLORS["DEATHKNIGHT"] },
                { class = "Evoker", var = "hideResourceFrameNoEvoker", color = RAID_CLASS_COLORS["EVOKER"] },
                { class = "Monk", var = "hideResourceFrameNoMonk", color = RAID_CLASS_COLORS["MONK"] },
                { class = "Mage", var = "hideResourceFrameNoMage", color = RAID_CLASS_COLORS["MAGE"] },
            }

            local previousCheckbox
            for i, classData in ipairs(classes) do
                local classCheckbox = CreateFrame("CheckButton", nil, classOptionsFrame, "UICheckButtonTemplate")
                classCheckbox:SetSize(24, 24)
                classCheckbox.Text:SetText("Ignore " .. classData.class)

                -- Set the color of the checkbox label to the class color
                local r, g, b = classData.color.r, classData.color.g, classData.color.b
                classCheckbox.Text:SetTextColor(r, g, b)

                -- Position the checkboxes
                if i == 1 then
                    classCheckbox:SetPoint("TOPLEFT", classOptionsFrame, "TOPLEFT", 10, -30)
                else
                    classCheckbox:SetPoint("TOPLEFT", previousCheckbox, "BOTTOMLEFT", 0, 3)
                end

                -- Set the state from the DB
                classCheckbox:SetChecked(BetterBlizzPlatesDB[classData.var])

                -- Save the state back to the DB when toggled
                classCheckbox:SetScript("OnClick", function(self)
                    BetterBlizzPlatesDB[classData.var] = self:GetChecked() or nil
                    BBP.HideResourceFrames()
                end)

                previousCheckbox = classCheckbox
            end
            classOptionsFrame:Show()
        else
            -- Toggle visibility of the frame when the function is called
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

    local druidOverstacks = CreateCheckbox("druidOverstacks", "Druid: Color Berserk Overstack Combo Points Blue", guiCVarControl)
    druidOverstacks:SetPoint("TOPLEFT", hideResourceFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(druidOverstacks, "Druid: Color Berserk Overstack Combo Points Blue", "Color the Druid Berserk Overstack Combo Points blue similar to Rogue's Echoing Reprimand.")

    local druidAlwaysShowCombos = CreateCheckbox("druidAlwaysShowCombos", "Druid: Always Show Combo Points", guiCVarControl)
    druidAlwaysShowCombos:SetPoint("TOPLEFT", druidOverstacks, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(druidAlwaysShowCombos, "Druid: Always Show Combo Points", "Alway show the combo points regardless of what form you are in if you have active combo points.")

    local changeResourceStrata = CreateCheckbox("changeResourceStrata", "Increase resource layer level", guiCVarControl, nil, BBP.ChangeStrataOfResourceFrame)
    changeResourceStrata:SetPoint("TOP", druidAlwaysShowCombos, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(changeResourceStrata, "Increase resource layer level", "Increases the frame strata of the resource frame making it show on top of nameplate instead of under (z-axis)")

    local nameplateResourceUnderCastbar = CreateCheckbox("nameplateResourceUnderCastbar", "Anchor resource underneath healthbar/castbar", nameplateResourceOnTarget, nil, BBP.RegisterTargetCastingEvents)
    nameplateResourceUnderCastbar:SetPoint("TOP", changeResourceStrata, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateResourceUnderCastbar, "Anchor Resource Under", "Anchor nameplate combo points etc underneath the healthbar and underneath the castbar during casts.")
    nameplateResourceOnTarget:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(nameplateResourceOnTarget)
    end)

    local hideResourceOnFriend = CreateCheckbox("hideResourceOnFriend", "Hide resource on friendly nameplates", guiCVarControl)
    hideResourceOnFriend:SetPoint("TOP", nameplateResourceUnderCastbar, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideResourceOnFriend, "Hide Resource on Friendly", "Hide combo points, warlock shards, arcane charges etc on friendly nameplates when targeting them.")

    local nameplateResourceScale = CreateSlider(guiCVarControl, "Resource Scale", 0.2, 1.7, 0.01, "nameplateResourceScale")
    nameplateResourceScale:SetPoint("TOPLEFT", hideResourceOnFriend, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(nameplateResourceScale, "Resource Scale", "The scale of nameplate Resource (Combo points etc)")
    CreateResetButton(nameplateResourceScale, "nameplateResourceScale", guiCVarControl)

    local nameplateResourceXPos = CreateSlider(guiCVarControl, "x offset", -100, 100, 1, "nameplateResourceXPos", "X")
    nameplateResourceXPos:SetPoint("TOPLEFT", nameplateResourceScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceXPos, "Nameplate Resource X Position", "X offset for Nameplate Resource")
    CreateResetButton(nameplateResourceXPos, "nameplateResourceXPos", guiCVarControl)

    local nameplateResourceYPos = CreateSlider(guiCVarControl, "y offset", -100, 100, 1, "nameplateResourceYPos", "Y")
    nameplateResourceYPos:SetPoint("TOPLEFT", nameplateResourceXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(nameplateResourceYPos, "Nameplate Resource Y Position", "Y offset for Nameplate Resource")
    CreateResetButton(nameplateResourceYPos, "nameplateResourceYPos", guiCVarControl)

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", "Dark Mode", guiCVarControl, nil, BBP.DarkModeNameplateResources)
    darkModeNameplateResource:SetPoint("TOPLEFT", nameplateResourceYPos, "BOTTOMLEFT", -12, -4)
    CreateTooltipTwo(darkModeNameplateResource, "Resource Dark Mode", "Dark Mode for Nameplate Resource")

    local darkModeNameplateColor = CreateSlider(darkModeNameplateResource, "Darkness Amount", 0, 1, 0.01, "darkModeNameplateColor")
    darkModeNameplateColor:SetPoint("TOPLEFT", darkModeNameplateResource, "BOTTOMLEFT", 12, -10)
    CreateTooltipTwo(darkModeNameplateColor, "How dark you want nameplate resource")

    darkModeNameplateResource:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeNameplateResource)
    end)

    local disableCVarForceOnLogin = CreateCheckbox("disableCVarForceOnLogin", "Disable all CVar forcing", guiCVarControl)
    disableCVarForceOnLogin:SetPoint("BOTTOM", guiCVarControl, "BOTTOM", 60, 10)
    CreateTooltipTwo(disableCVarForceOnLogin, "Disable all CVar Forcing", "Disables all forcing of CVar's on login (Not recommended)", "Checkboxes and sliders adjusting CVar values will still change CVars.")
    disableCVarForceOnLogin:SetScale(1.2)

    local nameplateSimplifiedScale = CreateSlider(guiCVarControl, "Simplified Scale", 0.3, 1, 0.01, "nameplateSimplifiedScale")
    nameplateSimplifiedScale:SetPoint("BOTTOMLEFT", disableCVarForceOnLogin, "TOPLEFT", 10, 30)
    CreateTooltipTwo(nameplateSimplifiedScale, "Simplified Scale", "The scale of simplified nameplates.", "Which nameplates are simplified can be adjusted in Blizzards Nameplate section.", nil, "nameplateSimplifiedScale")
    CreateResetButton(nameplateSimplifiedScale, "nameplateSimplifiedScale", guiCVarControl)

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

    local enableNpNonTargetAlpha = CreateCheckbox("enableNpNonTargetAlpha", "Enable", guiCVarControl)
    CreateTooltipTwo(enableNpNonTargetAlpha, "Enable Non-Target Alpha")

    local enableNpNonFocusAlpha = CreateCheckbox("enableNpNonFocusAlpha", "Focus", enableNpNonTargetAlpha)
    enableNpNonFocusAlpha:SetPoint("LEFT", enableNpNonTargetAlpha.text, "RIGHT", 0, 0)
    CreateTooltipTwo(enableNpNonFocusAlpha, "Also keep Focus nameplate full Alpha.")

    local enableNpNonTargetAlphaTargetOnly = CreateCheckbox("enableNpNonTargetAlphaTargetOnly", "Require Target", enableNpNonTargetAlpha)
    CreateTooltipTwo(enableNpNonTargetAlphaTargetOnly, "Only fade out other nameplates when you have a target")
    enableNpNonTargetAlphaTargetOnly:SetPoint("TOPLEFT", enableNpNonTargetAlpha, "BOTTOMLEFT", 0, 6)

    local enableNpNonTargetAlphaFullAlphaCasting = CreateCheckbox("enableNpNonTargetAlphaFullAlphaCasting", "Casting Full Alpha", enableNpNonTargetAlpha)
    CreateTooltipTwo(enableNpNonTargetAlphaFullAlphaCasting, "Keep casting nameplates at full Alpha")
    enableNpNonTargetAlphaFullAlphaCasting:SetPoint("TOPLEFT", enableNpNonTargetAlphaTargetOnly, "BOTTOMLEFT", 0, 6)

    local nameplateNonTargetAlpha = CreateSlider(enableNpNonTargetAlpha, "Non-Target Alpha", 0, 1, 0.01, "nameplateNonTargetAlpha")
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
    nameplateCVarText:SetText("Nameplate Visibility CVars")

    local setCVarAcrossAllCharacters = CreateCheckbox("setCVarAcrossAllCharacters", "Force these CVars across all characters", guiCVarControl)
    setCVarAcrossAllCharacters:SetPoint("TOP", nameplateCVarText, "BOTTOM", -100, 0)
    CreateTooltipTwo(setCVarAcrossAllCharacters, "Force CVars", "By default you have to set them on each character separately.")

    local nameplateShowAll = CreateCheckbox("nameplateShowAll", "Always show nameplates (if not targeted)", guiCVarControl, true)
    nameplateShowAll:SetPoint("TOP", setCVarAcrossAllCharacters, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowAll, "Always show nameplates", "Always show nameplates (if not targeted)", nil, nil, "nameplateShowAll")

    local nameplateShowOnlyNameForFriendlyPlayerUnits = CreateCheckbox("nameplateShowOnlyNameForFriendlyPlayerUnits", "Show Only Friendly NP Names", guiCVarControl, true, BBP.SetNameplateBehavior)
    nameplateShowOnlyNameForFriendlyPlayerUnits:SetPoint("TOP", nameplateShowAll, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowOnlyNameForFriendlyPlayerUnits, "Show Only Friendly NP Names", "Only show Name on Nameplates and hide healthbar & castbar. This enables Blizzards new CVar for this.", nil, nil, "nameplateShowOnlyNameForFriendlyPlayerUnits")

    local nameplateShowEnemyMinions = CreateCheckbox("nameplateShowEnemyMinions", "Show Enemy Minions", guiCVarControl, true)
    nameplateShowEnemyMinions:SetPoint("TOP", nameplateCVarText, "BOTTOM", -127, -56)
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

    local nameplateShowFriendlyPlayerMinions = CreateCheckbox("nameplateShowFriendlyPlayerMinions", "Show Friendly Minions", guiCVarControl, true)
    nameplateShowFriendlyPlayerMinions:SetPoint("TOP", nameplateCVarText, "BOTTOM", 25, -56)
    CreateTooltipTwo(nameplateShowFriendlyPlayerMinions, "Show Friendly Minion Nameplates", "Minions are stuff like extra BM hunter pets but Observer is also a minion", nil, nil, "nameplateShowFriendlyPlayerMinions")

    local nameplateShowFriendlyPlayerGuardians = CreateCheckbox("nameplateShowFriendlyPlayerGuardians", "Show Friendly Guardians", guiCVarControl, true)
    nameplateShowFriendlyPlayerGuardians:SetPoint("TOP", nameplateShowFriendlyPlayerMinions, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyPlayerGuardians, "Show Friendly Guardian Nameplates", "Guardians are usually \"semi controllable\" larger summoned pets, like Earth Elemental/Infernal.", nil, nil, "nameplateShowFriendlyPlayerGuardians")

    local nameplateShowFriendlyNPCs = CreateCheckbox("nameplateShowFriendlyNpcs", "Show Friendly NPCs", guiCVarControl, true)
    nameplateShowFriendlyNPCs:SetPoint("TOP", nameplateShowFriendlyPlayerGuardians, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyNPCs, "Show Friendly NPC Nameplates", "Always show friendly NPC nameplates", nil, nil, "nameplateShowFriendlyNpcs")

    local nameplateShowFriendlyPlayerPets = CreateCheckbox("nameplateShowFriendlyPlayerPets", "Show Friendly Pets", guiCVarControl, true)
    nameplateShowFriendlyPlayerPets:SetPoint("TOP", nameplateShowFriendlyNPCs, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyPlayerPets, "Show Friendly Pets Nameplates", "Pets are the main controllable pets like Hunter Pet, Warlock Pet etc.", nil, nil, "nameplateShowFriendlyPlayerPets")

    local nameplateShowFriendlyPlayerTotems = CreateCheckbox("nameplateShowFriendlyPlayerTotems", "Show Friendly Totems", guiCVarControl, true)
    nameplateShowFriendlyPlayerTotems:SetPoint("TOP", nameplateShowFriendlyPlayerPets, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(nameplateShowFriendlyPlayerTotems, "Show Friendly Totem Nameplates", "Totems are totem... and Psyfiend", nil, nil, "nameplateShowFriendlyPlayerTotems")

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
                elseif cvarName == "nameplateShowFriendlyPlayerMinions" then
                    if changeDB then
                        C_CVar.SetCVar("nameplateShowFriendlyPlayerGuardians", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerGuardians)
                        C_CVar.SetCVar("nameplateShowFriendlyPlayerTotems", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerTotems)
                        C_CVar.SetCVar("nameplateShowFriendlyPlayerPets", BetterBlizzPlatesDB.nameplateShowFriendlyPlayerPets)
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
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyPlayerMinions, "nameplateShowFriendlyPlayerMinions", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyPlayerGuardians, "nameplateShowFriendlyPlayerGuardians", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyPlayerPets, "nameplateShowFriendlyPlayerPets", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyNPCs, "nameplateShowFriendlyNpcs", changeDB)
        ChangeCVarCheckboxBehaviour(nameplateShowFriendlyPlayerTotems, "nameplateShowFriendlyPlayerTotems", changeDB)

        if changeDB then
            nameplateShowEnemyMinions:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyMinions"]=="1")
            nameplateShowEnemyGuardians:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyGuardians"]=="1")
            nameplateShowEnemyMinus:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyMinus"]=="1")
            nameplateShowEnemyPets:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyPets"]=="1")
            nameplateShowEnemyTotems:SetChecked(BetterBlizzPlatesDB["nameplateShowEnemyTotems"]=="1")
            nameplateShowFriendlyPlayerMinions:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyPlayerMinions"]=="1")
            nameplateShowFriendlyPlayerGuardians:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyPlayerGuardians"]=="1")
            nameplateShowFriendlyPlayerPets:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyPlayerPets"]=="1")
            nameplateShowFriendlyPlayerTotems:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyPlayerTotems"]=="1")
            nameplateShowFriendlyNPCs:SetChecked(BetterBlizzPlatesDB["nameplateShowFriendlyNpcs"]=="1")
        else
            nameplateShowEnemyMinions:SetChecked(GetCVar("nameplateShowEnemyMinions")=="1")
            nameplateShowEnemyGuardians:SetChecked(GetCVar("nameplateShowEnemyGuardians")=="1")
            nameplateShowEnemyMinus:SetChecked(GetCVar("nameplateShowEnemyMinus")=="1")
            nameplateShowEnemyPets:SetChecked(GetCVar("nameplateShowEnemyPets")=="1")
            nameplateShowEnemyTotems:SetChecked(GetCVar("nameplateShowEnemyTotems")=="1")
            nameplateShowFriendlyPlayerMinions:SetChecked(GetCVar("nameplateShowFriendlyPlayerMinions")=="1")
            nameplateShowFriendlyPlayerGuardians:SetChecked(GetCVar("nameplateShowFriendlyPlayerGuardians")=="1")
            nameplateShowFriendlyPlayerPets:SetChecked(GetCVar("nameplateShowFriendlyPlayerPets")=="1")
            nameplateShowFriendlyPlayerTotems:SetChecked(GetCVar("nameplateShowFriendlyPlayerTotems")=="1")
            nameplateShowFriendlyNPCs:SetChecked(GetCVar("nameplateShowFriendlyNpcs")=="1")
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
    cbCVars["nameplateShowFriendlyPlayerMinions"] = nameplateShowFriendlyPlayerMinions
    cbCVars["nameplateShowFriendlyPlayerGuardians"] = nameplateShowFriendlyPlayerGuardians
    cbCVars["nameplateShowFriendlyPlayerPets"] = nameplateShowFriendlyPlayerPets
    cbCVars["nameplateShowFriendlyNpcs"] = nameplateShowFriendlyNPCs
    cbCVars["nameplateShowFriendlyPlayerTotems"] = nameplateShowFriendlyPlayerTotems
    --cbCVars["nameplateResourceOnTarget"] = nameplateResourceOnTarget
    cbCVars["nameplateShowAll"] = nameplateShowAll
    cbCVars["nameplateShowOnlyNameForFriendlyPlayerUnits"] = nameplateShowOnlyNameForFriendlyPlayerUnits

    local sliderCVars = {}
    sliderCVars["nameplateOverlapH"] = nameplateOverlapH
    sliderCVars["nameplateOverlapV"] = nameplateOverlapV
    --sliderCVars["nameplateMotionSpeed"] = nameplateMotionSpeed
    sliderCVars["nameplateMinAlpha"] = nameplateMinAlpha
    sliderCVars["nameplateMinAlphaDistance"] = nameplateMinAlphaDistance
    sliderCVars["nameplateMaxAlpha"] = nameplateMaxAlpha
    sliderCVars["nameplateMaxAlphaDistance"] = nameplateMaxAlphaDistance
    sliderCVars["nameplateOccludedAlphaMult"] = nameplateOccludedAlphaMult

    -- Re-check checkboxes late cuz its all a mess and needs to be done and at this point more bandaid is all the effort i will put in until TWW maybe
    --if not BetterBlizzPlatesDB.hasSaved then
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
    --end

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
    ggText:SetText("GGs")
    ggText:SetTextColor(1, 0.2, 0.2, 1)
    ggText:SetTextScale(4.5)
    ggText:SetJustifyH("CENTER")

    local warningText = overlayFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    warningText:SetPoint("TOP", ggText, "BOTTOM", 0, -3)
    warningText:SetText("All of these settings are currently disabled.\n\nUnsure if this will come back in any shape at all.")
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
        local totemIndicatorScale = CreateSlider(listFrame, "General scale of all totem icons", 0.5, 3, 0.01, "totemIndicatorScale")
        totemIndicatorScale:SetPoint("TOP", totemList, "BOTTOM", -25, -45)
        totemIndicatorScale:HookScript("OnValueChanged", function(self)
            local val = self:GetValue()
            BBP.totemIndicatorScale:SetValue(val)
        end)
        totemIndicatorScale:SetScale(1.2)

        local totemIndicatorWidthEnabled = CreateCheckbox("totemIndicatorWidthEnabled", "Enable healthbar width settings", listFrame)
        totemIndicatorWidthEnabled:SetPoint("LEFT", totemIndicatorScale, "RIGHT", 25, 2)
        totemIndicatorWidthEnabled:HookScript("OnClick", function()
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end)
        CreateTooltipTwo(totemIndicatorWidthEnabled,"Enable healthbar width settings", "Enable individual healthbar width settings for npcs in totem list.\n\nRequires a reload.")
        totemIndicatorWidthEnabled:SetScale(1.1)

        local totemIndicatorUseNicknames = CreateCheckbox("totemIndicatorUseNicknames", "Use Nicknames", listFrame)
        totemIndicatorUseNicknames:SetPoint("TOPLEFT", totemIndicatorWidthEnabled, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        CreateTooltipTwo(totemIndicatorUseNicknames,"Use Nicknames", "The nameplates will show the name you enter in the list instead of their original name.")
        totemIndicatorUseNicknames:SetScale(1.1)

        local resetTotemListButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        resetTotemListButton:SetText("Reset Totem List")
        resetTotemListButton:SetWidth(120)
        resetTotemListButton:SetPoint("BOTTOMLEFT", listFrame, "BOTTOMLEFT", 10, 20)
        resetTotemListButton:SetScript("OnClick", function()
            StaticPopup_Show("BBP_TOTEMLIST_RESET")
        end)
        CreateTooltipTwo(resetTotemListButton, "Reset Totem List", "Reset totem list back to its default state", nil, "ANCHOR_TOP")
    end

    if not BetterBlizzPlatesDB.totemIndicator then
        listFrame:SetAlpha(0.5)
        guiTotemList.totemIndicator = CreateCheckbox("totemIndicator", "Enable Totem Indicator", guiTotemList)
        guiTotemList.totemIndicator:SetPoint("TOP", totemList, "BOTTOM", -45, -45)
        guiTotemList.totemIndicator:HookScript("OnClick", function(self)
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
            guiTotemList.totemIndicator:Hide()
            listFrame:SetAlpha(1)
            CreateTotemListElements()
        end)
        CreateTooltipTwo(guiTotemList.totemIndicator, "Totem Indicator |A:teleportationnetwork-ardenweald-32x32:17:17|a", "Show icon on and color important NPC nameplates.")
    else
        CreateTotemListElements()
    end
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

    local guildNameScale = CreateSlider(guiMisc, "Guild Name Size", 0.2, 2, 0.01, "guildNameScale", nil, 90)
    guildNameScale:SetPoint("LEFT", showGuildNames.Text, "RIGHT", 5, 0)

    local guildNameColor = CreateCheckbox("guildNameColor", "Custom Guild Name Color", guiMisc)
    guildNameColor:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(guildNameColor, "Change guild name color to a custom one instead of class colors.")

    local function OpenColorPicker()
        BBP.needsUpdate = true
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

    local npcTitleScale = CreateSlider(guiMisc, "NPC Title Size", 0.2, 2, 0.01, "npcTitleScale", nil, 90)
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

    local hideDeselectNonTargetOverlay = CreateCheckbox("hideDeselectNonTargetOverlay", "Hide Deselect Overlay", guiMisc)
    hideDeselectNonTargetOverlay:SetPoint("TOPLEFT", npcTitleColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDeselectNonTargetOverlay, "Hide Deselect Overlay", "New in Midnight is that non-target nameplates get a dark transparent overlay to make it more clear which one is your current target. This setting just hides that and makes it how it used to be.")
    hideDeselectNonTargetOverlay:HookScript("OnClick", function(self)
        if not self:GetChecked() then
             StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local friendIndicator = CreateCheckbox("friendIndicator", "Friend/Guildie Indicator", guiMisc)
    friendIndicator:SetPoint("TOPLEFT", hideDeselectNonTargetOverlay, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(friendIndicator, "Friend/Guildie Indicator", "Places a little icon next to a friend/guildies name")
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

    local friendIndicatorScale = CreateSlider(guiMisc, "Friend Indicator Size", 0.2, 2.5, 0.01, "friendIndicatorScale", nil, 90)
    friendIndicatorScale:SetPoint("LEFT", friendIndicator.Text, "RIGHT", 25, 0)

    local targetHighlightFix = CreateCheckbox("targetHighlightFix", "TWW Target Highlight Fix", guiMisc)
    targetHighlightFix:SetPoint("TOPLEFT", friendIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetHighlightFix, "TWW Target Highlight Fix", "Changes the faint Target Highlight Glow on nameplates to behave like it used to before TWW.\n\nBefore it was only active on current health portion but now in TWW it is active on the entire healthbar, also background.")

    local forceClassColors = CreateCheckbox("forceClassColors", "Force Class Colors", guiMisc)
    forceClassColors:SetPoint("TOPLEFT", targetHighlightFix, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(forceClassColors, "Force Class Colors", "Force BBP to class color player nameplates.\n\nNormally Blizzard class colors nameplates but due to too many bugs of it failing to color properly (like on Mind Control) this setting exists so BBP does the class coloring instead (without bugs).")

    local recolorTempHpLoss = CreateCheckbox("recolorTempHpLoss", "Recolor Temp HP Loss", guiMisc)
    recolorTempHpLoss:SetPoint("TOPLEFT", forceClassColors, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(recolorTempHpLoss, "Recolor Temp HP Loss", "Recolor the temp hp loss on nameplates to a slightly transparent red color")

    local hideTempHpLoss = CreateCheckbox("hideTempHpLoss", "Hide temp hp loss", guiMisc)
    hideTempHpLoss:SetPoint("TOPLEFT", recolorTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTempHpLoss, "Hide Temp HP Loss", "Hide the temp hp loss texture on nameplates")

    local showNameplateShadow = CreateCheckbox("showNameplateShadow", "Nameplate Shadow", guiMisc)
    showNameplateShadow:SetPoint("TOPLEFT", hideTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showNameplateShadow, "Nameplate Shadow", "Show a shadow behind nameplates.\n\n|cff32f795Right-click to change Color.|r")
    showNameplateShadow:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)
    showNameplateShadow:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.nameplateShadowRGB, BBP.RefreshAllNameplates)
        end
    end)

    local highlightNpShadowOnMouseover = CreateCheckbox("highlightNpShadowOnMouseover", "Highlight Mouseover", guiMisc)
    highlightNpShadowOnMouseover:SetPoint("LEFT", showNameplateShadow.text, "RIGHT", 0, 6)
    CreateTooltipTwo(highlightNpShadowOnMouseover, "Highlight Shadow on Mouseover", "Highlight the Shadow white on Mouseover.\n\n|cff32f795Right-click to change Color.|r")
    highlightNpShadowOnMouseover:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)
    highlightNpShadowOnMouseover:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzPlatesDB.nameplateShadowHighlightRGB, BBP.RefreshAllNameplates)
        end
    end)

    local showNameplateShadowClassColor = CreateCheckbox("showNameplateShadowClassColor", "Class Color", guiMisc)
    showNameplateShadowClassColor:SetPoint("LEFT", highlightNpShadowOnMouseover.text, "RIGHT", 0, 0)
    CreateTooltipTwo(showNameplateShadowClassColor, "Class Color", "Class color the shadow on players.")

    local showNameplateShadowOnlyTarget = CreateCheckbox("showNameplateShadowOnlyTarget", "Target", guiMisc)
    showNameplateShadowOnlyTarget:SetPoint("LEFT", showNameplateShadowClassColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(showNameplateShadowOnlyTarget, "Target Only", "Only show Nameplate Shadow on current Target.")

    local onlyShowHighlightedNpShadow = CreateCheckbox("onlyShowHighlightedNpShadow", "Highlighted Only", guiMisc)
    onlyShowHighlightedNpShadow:SetPoint("TOPLEFT", highlightNpShadowOnMouseover, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(onlyShowHighlightedNpShadow, "Highlighted Only", "Only show the highlighted shadow on current Mouseover.")
    onlyShowHighlightedNpShadow:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local keepNpShadowTargetHighlighted = CreateCheckbox("keepNpShadowTargetHighlighted", "Keep Target Highlighted", guiMisc)
    keepNpShadowTargetHighlighted:SetPoint("LEFT", onlyShowHighlightedNpShadow.text, "RIGHT", 0, 0)
    CreateTooltipTwo(keepNpShadowTargetHighlighted, "Keep Target Highlighted", "Keep your current target highlighted without mouseover.")
    keepNpShadowTargetHighlighted:HookScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local showLevelFrameOnFriendly = CreateCheckbox("showLevelFrameOnFriendly", "Friendly Lvl", guiMisc)
    showLevelFrameOnFriendly:SetPoint("TOPLEFT", showNameplateShadow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showLevelFrameOnFriendly, "Also shows level on friendly name plates if enabled.")

    local anonMode = CreateCheckbox("anonMode", "Anon Mode", guiMisc)
    anonMode:SetPoint("TOPLEFT", showLevelFrameOnFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(anonMode, "Changes the names of players to their class instead.\nWill be overwritten by Arena Names module during arenas.")

    local pvpTitleMode = CreateCheckbox("pvpTitleMode", "PVP Title", guiMisc)
    pvpTitleMode:SetPoint("LEFT", anonMode.text, "RIGHT", 5, 0)
    CreateTooltipTwo(pvpTitleMode, "Changes the names of players to include their chosen Title.\nWill be overwritten by Anon Mode and Arena Names module during arenas.")

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

    local scaleNpNameWithParent = CreateCheckbox("scaleNpNameWithParent", "Scale names with the nameplate", guiMisc)
    scaleNpNameWithParent:SetPoint("TOPLEFT", showLastNameNpc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(scaleNpNameWithParent, "Scale names with the nameplate", "This setting makes it so nameplate names scale up/down with the nameplate size. The \"Name Size\" slider in general will still adjust the general size.\n\nIf not enabled the name will always stay one consistent size.\n\nSince Midnight this has been on by default from Blizzard but not in BBP. If you want to keep that default behaviour enable this.")

    local prdLegacyLook = CreateCheckbox("prdLegacyLook", "PRD: Legacy Look", guiMisc)
    prdLegacyLook:SetPoint("TOPLEFT", scaleNpNameWithParent, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(prdLegacyLook, "Personal Resource Display: Legacy Look", "Change the look of the Personal Resource Display to be how it was before Midnight.")

    local prdSplitLines = CreateCheckbox("prdSplitLines", "PRD: Split Lines", prdLegacyLook, nil, BBP.LegacyPRDLook)
    prdSplitLines:SetPoint("LEFT", prdLegacyLook.text, "RIGHT", 0, 0)
    CreateTooltipTwo(prdSplitLines, "Personal Resource Display: Split Lines", "Show horizontal border lines splitting each bar on the PRD.")

    prdLegacyLook:HookScript("OnClick", function(self)
        BBP.LegacyPRDLook()
        BBP.TexturePRD()
        if self:GetChecked() then
            EnableElement(prdSplitLines)
        else
            DisableElement(prdSplitLines)
        end
    end)

    local fancyPrdAltTexture = CreateCheckbox("fancyPrdAltTexture", "PRD: Fancy Alt Power Texture", guiMisc)
    fancyPrdAltTexture:SetPoint("TOPLEFT", prdLegacyLook, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fancyPrdAltTexture, "PRD: Fancy Alt Power Texture", "Change the look of the Personal Resource Display to use Blizzards \"fancy\" alt textures for Astral Power, Insanity, etc.")


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

    local changeHealthbarHeight = CreateCheckbox("changeHealthbarHeight", "Separate Friendly/Enemy Nameplate Height", guiMisc)
    changeHealthbarHeight:SetPoint("TOPLEFT", scaleNpNameWithParent, "BOTTOMLEFT", 0, -60)
    CreateTooltipTwo(changeHealthbarHeight, "Separate Nameplate Heights", "Change the height of nameplates individually depending if enemy, friendly or personal.")

    local hpHeightEnemy = CreateSlider(changeHealthbarHeight, "Enemy Height", 1, 35, 0.1, "hpHeightEnemy")
    hpHeightEnemy:SetPoint("TOPLEFT", changeHealthbarHeight, "BOTTOMLEFT", 10, -10)
    CreateTooltipTwo(hpHeightEnemy, "Enemy Height", "Change the height for enemy nameplates.")
    local hpHeightEnemyReset = CreateResetButton(hpHeightEnemy, "hpHeightEnemy", guiMisc)
    CreateTooltipTwo(hpHeightEnemyReset, "Reset to default", "Default is 4 * NamePlateVerticalScale")

    local hpHeightFriendly = CreateSlider(changeHealthbarHeight, "Friendly Height", 1, 35, 0.1, "hpHeightFriendly")
    hpHeightFriendly:SetPoint("TOPLEFT", hpHeightEnemy, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(hpHeightFriendly, "Friendly Height", "The height for friendly nameplates.\n\nPvE: In PvE Friendly Nameplates will be forced to the \"Nameplate Height\" setting on the General page due to Blizzard restrictions. Due to this I would go into a dungeon and use that as a baseline for Friendlies and adjust the other ones accordingly.")
    local hpHeightFriendlyReset = CreateResetButton(hpHeightFriendly, "hpHeightFriendly", guiMisc)
    CreateTooltipTwo(hpHeightFriendlyReset, "Reset to default", "Default is 4 * NamePlateVerticalScale")

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
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
    end)

    local changeNameplateBorderSize = CreateCheckbox("changeNameplateBorderSize", "Change Nameplate Border Size", guiMisc)
    changeNameplateBorderSize:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 400, 39)
    local nameplateBorderSize = CreateSlider(changeNameplateBorderSize, "Nameplate Border Size", 0.5, 10, 0.5, "nameplateBorderSize")
    nameplateBorderSize:SetPoint("TOPLEFT", changeNameplateBorderSize, "BOTTOMLEFT", 10, -10)
    local nameplateTargetBorderSize = CreateSlider(changeNameplateBorderSize, "Target Border Size", 0.5, 10, 0.5, "nameplateTargetBorderSize")
    nameplateTargetBorderSize:SetPoint("TOPLEFT", nameplateBorderSize, "BOTTOMLEFT", 0, -17)
    local nameplatePersonalBorderSize = CreateSlider(changeNameplateBorderSize, "Personal Border Size", 0.5, 10, 0.5, "nameplatePersonalBorderSize")
    nameplatePersonalBorderSize:SetPoint("TOPLEFT", nameplateTargetBorderSize, "BOTTOMLEFT", 0, -17)



    CreateTooltipTwo(nameplateBorderSize, "Nameplate Border Size", "The size of nameplate borders.")
    changeNameplateBorderSize:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(nameplateBorderSize)
            EnableElement(nameplateTargetBorderSize)
            EnableElement(nameplatePersonalBorderSize)
        else
            DisableElement(nameplateBorderSize)
            DisableElement(nameplateTargetBorderSize)
            DisableElement(nameplatePersonalBorderSize)
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)


    local hidePersonalManaFX = CreateCheckbox("hidePersonalManaFX", "Hide Personal Resource Manabar FX", guiMisc, nil, BBP.HidePersonalManabarFX)
    hidePersonalManaFX:SetPoint("BOTTOMLEFT", changeNameplateBorderSize, "BOTTOMLEFT", 0, 20)
    CreateTooltipTwo(hidePersonalManaFX, "Hide Personal Manabar FX", "Hide the manabar animations on the Personal Resource Display for instant feedback.")
    hidePersonalManaFX:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBP_CONFIRM_RELOAD")
        end
    end)

    local changeNameplateBorderColor = CreateCheckbox("changeNameplateBorderColor", "Change Nameplate Border Color", guiMisc)
    changeNameplateBorderColor:SetPoint("TOPLEFT", nameplatePersonalBorderSize, "BOTTOMLEFT", -10, -2)

    local npBorderTargetColor = CreateCheckbox("npBorderTargetColor", "Target Border", changeNameplateBorderColor)
    npBorderTargetColor:SetPoint("TOPLEFT", changeNameplateBorderColor, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(npBorderTargetColor, "Enable to change the color of the target nameplate border")

    local npBorderTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderTargetColorRGB", "Target Border")
    npBorderTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColor, "BOTTOMLEFT", 15, 0)

    local npBorderNonTargetColorRGB = CreateColorBox(npBorderTargetColor, "npBorderNonTargetColorRGB", "Non-Target Border")
    npBorderNonTargetColorRGB:SetPoint("TOPLEFT", npBorderTargetColorRGB, "BOTTOMLEFT", 0, -2)

    local npBorderFocusColorRGB = CreateColorBox(npBorderTargetColor, "npBorderFocusColorRGB", "Focus Border")
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

    local npBorderFriendFoeColor = CreateCheckbox("npBorderFriendFoeColor", "Reaction Color Border", changeNameplateBorderColor)
    npBorderFriendFoeColor:SetPoint("TOPLEFT", npBorderFocusColorRGB, "BOTTOMLEFT", -15, 0)
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
    changeNpHpBgColor:SetPoint("TOPLEFT", npBorderNpcColorRGB, "BOTTOMLEFT", -30, 0)
    CreateTooltipTwo(changeNpHpBgColor, "Nameplate Background Color", "Change the nameplate background color.")

    local npBgColorRGB = CreateColorBox(changeNpHpBgColor, "npBgColorRGB", "Background Color")
    npBgColorRGB:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 15, 0)

    changeNpHpBgColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            npBgColorRGB:SetAlpha(1)
        else
            npBgColorRGB:SetAlpha(0.5)
        end
    end)

    local customFontSizeEnabled = CreateCheckbox("customFontSizeEnabled", "Enable Custom Nameplate Font Size", guiMisc)
    customFontSizeEnabled:SetPoint("TOPLEFT", changeNpHpBgColor, "BOTTOMLEFT", 0, -22)
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


    local personalNpTRP3Color = CreateCheckbox("personalNpTRP3Color", "TRP3: Personal Bar Color", guiMisc)
    personalNpTRP3Color:SetPoint("TOPLEFT", customFontSizeEnabled, "BOTTOMLEFT", -160, -90)
    CreateTooltipTwo(personalNpTRP3Color, "TRP3: Personal Bar Color", "Color the Personal Resource Display healthbar your TRP3 Color.")

    local personalBarTweaks = CreateCheckbox("personalBarTweaks", "Personal Bar Tweaks", guiMisc)
    personalBarTweaks:SetPoint("TOPLEFT", personalNpTRP3Color, "BOTTOMLEFT", 0, 6)
    CreateTooltipTwo(personalBarTweaks, "Personal Bar Tweaks", "Enable to show more features on the Personal Resource Bar\n\nThis will show (if enabled):\nName\nGuild Name\nClassic Border")




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

------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
local function CombatOnGUICreation()
    if InCombatLockdown() then
        print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates: Waiting for combat to drop before opening settings for the first time.")
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
    Settings.OpenToCategory(BBP.category:GetID(), BBP.guiCustomCode)
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
    local cvarsToTrack = {
        checkboxes = {
            nameplateShowEnemyMinions = true,
            nameplateShowEnemyGuardians = true,
            nameplateShowEnemyMinus = true,
            nameplateShowEnemyPets = true,
            nameplateShowEnemyTotems = true,
            nameplateShowFriendlyPlayerMinions = true,
            nameplateShowFriendlyPlayerGuardians = true,
            nameplateShowFriendlyPlayerPets = true,
            nameplateShowFriendlyNpcs = true,
            nameplateShowFriendlyPlayerTotems = true,
            nameplateResourceOnTarget = true,
            nameplateShowAll = true,
            nameplateShowOnlyNameForFriendlyPlayerUnits = true
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

    local cvarListener = CreateFrame("Frame")
    cvarListener:RegisterEvent("CVAR_UPDATE")
    cvarListener:SetScript("OnEvent", function(self, event, cvarName, cvarValue)
        if BBP.CVarTrackingDisabled then return end
        if BetterBlizzPlatesDB.skipCVarsPlater and C_AddOns.IsAddOnLoaded("Plater") then return end

        if cvarsToTrack.checkboxes[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
        elseif cvarsToTrack.sliders[cvarName] then
            BetterBlizzPlatesDB[cvarName] = tonumber(cvarValue)
        elseif cvarsToTrack.other[cvarName] then
            BetterBlizzPlatesDB[cvarName] = cvarValue
        elseif bitCVarNames[cvarName] then
            for _, index in ipairs(BBP.bitCVarList[cvarName]) do
                BetterBlizzPlatesDB.bitfields[cvarName][tostring(index)] = BBP.GetPlayerNameplateBit(cvarName, index)
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
    preMidnightButton:SetPoint("TOP", bodifyButton, "BOTTOM", -75, btnGap)

    local orText = BBP.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText:SetPoint("CENTER", preMidnightButton, "BOTTOM", 0, -20)
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
    buttonLast:SetText("Exit, No Profile.")
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
