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
    text = "This requires a reload. Reload now?",
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

local function CreateBorderBox(anchor)
    local contentFrame = anchor:GetParent()
    local texture = contentFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAtlas("UI-Frame-Neutral-PortraitWiderDisable")
    texture:SetDesaturated(true)
    texture:SetRotation(math.rad(90))
    texture:SetSize(295, 163)
    texture:SetPoint("CENTER", anchor, "CENTER", 0, -95)
    return texture
end

local function CreateResetButton(relativeTo, settingKey, parent)
    local resetButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    resetButton:SetText("Default")
    resetButton:SetWidth(60)
    resetButton:SetPoint("LEFT", relativeTo, "RIGHT", 10, 0)
    resetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(relativeTo, settingKey)
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
            -- Set text color (example: yellow)
            dropdownTextFontString:SetTextColor(1, 1, 0) -- RGB for yellow
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
                    toggleFunc(fontPath)
                    dropdown.Text:SetFont(fontPath, 12)
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
    dropdown.initialize = function(self, level, menuList)
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
                    toggleFunc(texturePath)
                end
                info.arg1 = textureName
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end

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

local function CreateSlider(parent, label, minValue, maxValue, stepValue, element, axis)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)

    slider.Low:SetText(" ")
    slider.High:SetText(" ")

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
            slider:SetMinMaxValues(newMinValue, newMaxValue)
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

    -- Create Input Box on Right Click
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetWidth(50) -- Set the width of the EditBox
    editBox:SetHeight(20) -- Set the height of the EditBox
    editBox:SetMultiLine(false)
    editBox:SetPoint("CENTER", slider, "CENTER", 0, 0) -- Position it to the right of the slider
    editBox:SetFrameStrata("DIALOG") -- Ensure it appears above other UI elements
    editBox:Hide()

    editBox:SetFontObject(GameFontHighlightSmall)

    -- Function to handle the entered value and update the slider
    local function HandleEditBoxInput()
        local inputValue = tonumber(editBox:GetText())
        if inputValue then
            -- Check if it's a non-axis slider and inputValue is <= 0
            if (axis ~= "X" and axis ~= "Y") and inputValue <= 0 then
                inputValue = 0.1  -- Set to minimum allowed value for non-axis sliders
            end

            local currentMin, currentMax = slider:GetMinMaxValues()
            if inputValue < currentMin or inputValue > currentMax then
                UpdateSliderRange(inputValue, currentMin, currentMax)
            end

            slider:SetValue(inputValue)
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

    slider:SetScript("OnValueChanged", function(self, value)
        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            local textValue = value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
            self.Text:SetText(label .. ": " .. textValue)
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
                    BetterBlizzPlatesDB[element .. "Scale"] = value
                end

                local xPos = BetterBlizzPlatesDB[element .. "XPos"] or 0
                local yPos = BetterBlizzPlatesDB[element .. "YPos"] or 0
                local anchorPoint = BetterBlizzPlatesDB[element .. "Anchor"] or "CENTER"

                for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                    if namePlate.UnitFrame then
                        local frame = namePlate.UnitFrame
                        -- Absorb Indicator Pos and Scale
                        if element == "absorbIndicatorXPos" or element == "absorbIndicatorYPos" or element == "absorbIndicatorScale" then
                            BBP.AbsorbIndicator(frame)
                        -- Combat Indicator Pos and Scale
                        elseif element == "combatIndicatorXPos" or element == "combatIndicatorYPos" or element == "combatIndicatorScale" then
                            BBP.CombatIndicator(frame)
                        -- Healer Indicator Pos and Scale
                        elseif element == "healerIndicatorXPos" or element == "healerIndicatorYPos" or element == "healerIndicatorScale" then
                            BBP.HealerIndicator(frame)
                        -- Healer Indicator Pos and Scale
                        elseif element == "classIndicatorXPos" or element == "classIndicatorYPos" or element == "classIndicatorScale" then
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
                        -- Target Indicator Pos and Scale
                        elseif element == "targetIndicatorXPos" or element == "targetIndicatorYPos" or element == "targetIndicatorScale" then
                            BBP.TargetIndicator(frame)
                        -- Focus Target Indicator Pos and Scale
                        elseif element == "focusTargetIndicatorXPos" or element == "focusTargetIndicatorYPos" or element == "focusTargetIndicatorScale" then
                            BBP.FocusTargetIndicator(frame)
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
                                frame.castBar.Icon:ClearAllPoints()
                                frame.castBar.Icon:SetPoint("CENTER", frame.castBar, anchorPoint, xPos, yPos)
                                frame.castBar.BorderShield:ClearAllPoints()
                                frame.castBar.BorderShield:SetPoint("CENTER", frame.castBar, BetterBlizzPlatesDB.castBarIconAnchor, xPos, yPos + yOffset)
                            else
                                BetterBlizzPlatesDB.castBarIconScale = value
                                frame.castBar.Icon:SetScale(value)
                                frame.castBar.BorderShield:SetScale(value)
                            end
                        -- Cast bar height
                        elseif element == "castBarHeight" then
                            frame.castBar:SetHeight(value)
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
                            if frame.RaidTargetFrame.RaidTargetIcon then
                                if axis then
                                    if anchorPoint == "TOP" then
                                        frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                                        frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.name, anchorPoint, xPos, yPos)
                                    else
                                        frame.RaidTargetFrame.RaidTargetIcon:ClearAllPoints()
                                        frame.RaidTargetFrame.RaidTargetIcon:SetPoint("BOTTOM", frame.healthBar, anchorPoint, xPos, yPos)
                                    end
                                else
                                    frame.RaidTargetFrame.RaidTargetIcon:SetScale(value)
                                end
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
                elseif element == "nameplateResourceScale" then
                    BetterBlizzPlatesDB.nameplateResourceScale = value
                    BBP.ApplySettingsToAllNameplates()
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
                elseif element == "defaultNpAuraCdSize" then
                    BetterBlizzPlatesDB.defaultNpAuraCdSize = value
                    BBP.RefreshBuffFrame()
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
                elseif element == "nameplateMaxScale" then
                    if not BBP.checkCombatAndWarn() then
                    local defaultMinScale = 0.8
                    local defaultMaxScale = 1.0
                    local ratio = defaultMinScale / defaultMaxScale
                    -- Keep ratio between default values
                    local newMaxScale = value
                    local newMinScale = newMaxScale * ratio
                    SetCVar("nameplateMinScale", newMinScale)
                    SetCVar("nameplateMaxScale", newMaxScale)
                    BetterBlizzPlatesDB.nameplateMinScale = newMinScale
                    BetterBlizzPlatesDB.nameplateMaxScale = newMaxScale
                    end
                -- Nameplate selected scale
                elseif element == "nameplateSelectedScale" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateSelectedScale", value)
                        BetterBlizzPlatesDB.nameplateSelectedScale = value
                    end
                -- Nameplate Height cvar
                elseif element == "NamePlateVerticalScale" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("NamePlateVerticalScale", value)
                        BetterBlizzPlatesDB.NamePlateVerticalScale = value
                        local verticalScale = tonumber(BetterBlizzPlatesDB.NamePlateVerticalScale)
                        if verticalScale and verticalScale >= 2 then
                            SetCVar("NamePlateHorizontalScale", 1.4)
                        else
                            SetCVar("NamePlateHorizontalScale", 1)
                        end
                        if frame.castBar then
                            if not BetterBlizzPlatesDB.enableCastbarCustomization then
                                if BBP.isLargeNameplatesEnabled() then
                                    frame.castBar:SetHeight(18.8)
                                else
                                    frame.castBar:SetHeight(8)
                                end
                            else
                                frame.castBar:SetHeight(BetterBlizzPlatesDB.castBarHeight)
                            end
                        end
                    end
                -- Nameplate Horizontal Overlap
                elseif element == "nameplateOverlapH" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateOverlapH", value)
                        BetterBlizzPlatesDB.nameplateOverlapH = value
                    end
                -- Nameplate Vertical Overlap
                elseif element == "nameplateOverlapV" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateOverlapV", value)
                        BetterBlizzPlatesDB.nameplateOverlapV = value
                    end
                -- Nameplate Motion Speed
                elseif element == "nameplateMotionSpeed" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateMotionSpeed", value)
                        BetterBlizzPlatesDB.nameplateMotionSpeed = value
                    end
                elseif element == "nameplateMinAlpha" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateMinAlpha", value)
                        BetterBlizzPlatesDB.nameplateMinAlpha = value
                    end
                elseif element == "nameplateMinAlphaDistance" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateMinAlphaDistance", value)
                        BetterBlizzPlatesDB.nameplateMinAlphaDistance = value
                    end
                elseif element == "nameplateMaxAlpha" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateMaxAlpha", value)
                        BetterBlizzPlatesDB.nameplateMaxAlpha = value
                    end
                elseif element == "nameplateMaxAlphaDistance" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateMaxAlphaDistance", value)
                        BetterBlizzPlatesDB.nameplateMaxAlphaDistance = value
                    end
                elseif element == "nameplateOccludedAlphaMult" then
                    if not BBP.checkCombatAndWarn() then
                        SetCVar("nameplateOccludedAlphaMult", value)
                        BetterBlizzPlatesDB.nameplateOccludedAlphaMult = value
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
    end)

    return slider
end

local function CreateTooltip(widget, tooltipText, anchor)
    widget:SetScript("OnEnter", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:SetText(tooltipText)

        GameTooltip:Show()
    end)

    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point)
    -- Create the dropdown frame using the library's creation function
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, 125)
    LibDD:UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    local anchorPointsToUse = anchorPoints
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

    -- Enable or disable the dropdown based on the parent's check state
    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        LibDD:UIDropDownMenu_DisableDropDown(dropdown)
    else
        LibDD:UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateCheckbox(option, label, parent, cvar, extraFunc)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)

    local function UpdateOption(value)
        if option == 'friendlyNameplateClickthrough' and BBP.checkCombatAndWarn() then
            return
        end

        BetterBlizzPlatesDB[option] = value

        if cvar then
            if value == "0" then
                value = false
            elseif value == "1" then
                value = true
            end
            if BetterBlizzPlatesDB[option] ~= nil and not BetterBlizzPlatesDB.wasOnLoadingScreen then
                SetCVar(option, BetterBlizzPlatesDB[option])
            end
        end
        checkBox:SetChecked(value)

        local grandparent = parent:GetParent()

        if parent:GetObjectType() == "CheckButton" and (parent:GetChecked() == false or (grandparent:GetObjectType() == "CheckButton" and grandparent:GetChecked() == false)) then
            checkBox:Disable()
            checkBox:SetAlpha(0.5)
        else
            checkBox:Enable()
            checkBox:SetAlpha(1)
        end

        if extraFunc and not BetterBlizzPlatesDB.wasOnLoadingScreen then
            extraFunc(option, value)
        end

        if not BetterBlizzPlatesDB.wasOnLoadingScreen then
            BBP.RefreshAllNameplates()
        end
        --print("Checkbox option '" .. option .. "' changed to:", value)
    end

    local function PeriodicCheck()
        if BetterBlizzPlatesDB[option] ~= nil then
            UpdateOption(BetterBlizzPlatesDB[option])
        else
            -- Handle the nil case if necessary, or set a default value
            C_Timer.After(1, PeriodicCheck) -- Recursively call this function every second
        end
    end
    
    UpdateOption(BetterBlizzPlatesDB[option])
    
    if cvar then
        PeriodicCheck()
    end

    checkBox:HookScript("OnClick", function(_, _, _)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
end

local function CreateList(subPanel, listName, listData, refreshFunc, enableColorPicker, extraBoxes, prioSlider, width, height)
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)

    -- Create the content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, height or 390)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}
    local selectedLineIndex = nil

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

    local function updatePriority(index, priority)
        if not index then return end

        -- Update the priority in the listData
        listData[index].priority = priority

        -- Update the auraColorList table with the new priority
        local auraColorList = BetterBlizzPlatesDB.auraColorList
        local auraName = listData[index].name
        local spellId = listData[index].id

        for _, npc in ipairs(auraColorList) do
            if (npc.id == tonumber(spellId) or (npc.name and strlower(npc.name) == strlower(auraName))) then
                npc.priority = priority
                break
            end
        end

        refreshFunc()
    end

    local function deleteEntry(index)
        if not index then return end

        -- Remove the selected entry from the list and saved variables
        table.remove(listData, index)

        -- Remove the button from the frame and the textLines table
        textLines[index]:Hide()
        table.remove(textLines, index)

        -- Re-anchor all buttons below the removed one and update their OnClick scripts
        for i = index, #textLines do
            textLines[i]:SetPoint("TOPLEFT", 10, -(i - 1) * 20)
            textLines[i].deleteButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    deleteEntry(i)
                else
                    selectedLineIndex = i
                    StaticPopup_Show("BBP_DELETE_NPC_CONFIRM_" .. listName)
                end
            end)
        end

        selectedLineIndex = nil
        updateBackgroundColors()
        refreshFunc()
    end

    local function createTextLineButton(npc, index, enableColorPicker)
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or 310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

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
                local spellName, _, _ = GetSpellInfo(npc.id)
                if spellName then
                    displayText = displayText .. " - " .. spellName
                end
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
            displayText = displayText .. (displayText ~= "" and " - " or "") .. npc.name
        end
        if npc.comment and npc.comment ~= "" then
            displayText = displayText .. (displayText ~= "" and " - " or "") .. npc.comment
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", addIcon and 25 or 5, 0)
        text:SetText(displayText)

        -- Initialize the text color and background color for this entry from npc table or with default values
        local entryColors = npc.entryColors or {}
        npc.entryColors = entryColors  -- Save the colors back to the npc data

        if not entryColors.text then
            entryColors.text = { r = 1, g = 1, b = 0 } -- Default to yellow color
        end

        -- Function to set the text color
        local function SetTextColor(r, g, b)
            text:SetTextColor(r, g, b)
        end

        -- Set initial text and background colors from entryColors
        SetTextColor(entryColors.text.r, entryColors.text.g, entryColors.text.b)

        local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
        deleteButton:SetText("X")

        deleteButton:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                deleteEntry(index)
            else
                selectedLineIndex = index
                StaticPopup_Show("BBP_DELETE_NPC_CONFIRM_" .. listName)
            end
        end)

        if enableColorPicker then
            local colorPickerButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
            colorPickerButton:SetSize(50, 20)
            colorPickerButton:SetPoint("RIGHT", deleteButton, "LEFT", -5, 0)
            colorPickerButton:SetText("Color")

            -- Function to open the color picker
            local function OpenColorPicker()
                local r, g, b = entryColors.text.r, entryColors.text.g, entryColors.text.b

                --ColorPickerFrame:SetColorRGB(r, g, b)
                ColorPickerFrame.previousValues = { r, g, b }

                ColorPickerFrame.func = function()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    entryColors.text.r, entryColors.text.g, entryColors.text.b = r, g, b
                    SetTextColor(r, g, b)  -- Update text color when the color picker changes

                    -- Update the npc entry in listData with the new color
                    npc.entryColors.text.r, npc.entryColors.text.g, npc.entryColors.text.b = r, g, b
                    listData[index] = npc  -- Update the entry in the listData
                    BBP.RefreshAllNameplates()
                end

                ColorPickerFrame.cancelFunc = function()
                    r, g, b = unpack(ColorPickerFrame.previousValues)
                    entryColors.text.r, entryColors.text.g, entryColors.text.b = r, g, b
                    SetTextColor(r, g, b)  -- Update text color if canceled
                end
                ColorPickerFrame:ClearAllPoints()
                ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                ColorPickerFrame:Show()
            end

            colorPickerButton:SetScript("OnClick", OpenColorPicker)
        end

        if extraBoxes then
            -- Ensure the npc.flags table exists
            if not npc.flags then
                npc.flags = { important = false, pandemic = false }
            end

            -- Create Checkbox I (Important)
            local checkBoxI = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxI:SetSize(24, 24)
            checkBoxI:SetPoint("RIGHT", deleteButton, "LEFT", -38, 0)

            -- Create a texture for the checkbox
            checkBoxI.texture = checkBoxI:CreateTexture(nil, "ARTWORK",nil,1)
            checkBoxI.texture:SetAtlas("newplayertutorial-drag-slotgreen")
            checkBoxI.texture:SetSize(27, 27)

            checkBoxI.texture:SetPoint("CENTER", checkBoxI, "CENTER", -0.5,0.5)
            CreateTooltip(checkBoxI, "Important Glow\n\nCheck for a green glow on the aura to highlight it.", "ANCHOR_TOPRIGHT")

            -- Handler for the I checkbox
            checkBoxI:SetScript("OnClick", function(self)
                npc.flags.important = self:GetChecked() -- Save the state in the npc flags
            end)
            checkBoxI:HookScript("OnClick", BBP.RefreshAllNameplates)


            -- Initialize state from npc flags
            if npc.flags.important then
                checkBoxI:SetChecked(true)
            end

            -- Create Checkbox P (Pandemic)
            local checkBoxP = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxP:SetSize(24, 24)
            checkBoxP:SetPoint("LEFT", checkBoxI, "RIGHT", 6, 0)

            -- Create a texture for the checkbox
            checkBoxP.texture = checkBoxP:CreateTexture(nil, "ARTWORK",nil,1)
            checkBoxP.texture:SetAtlas("newplayertutorial-drag-slotgreen")
            checkBoxP.texture:SetDesaturated(true)
            checkBoxP.texture:SetVertexColor(1, 0, 0)
            checkBoxP.texture:SetSize(27, 27)

            -- Center the texture within the checkbox
            checkBoxP.texture:SetPoint("CENTER", checkBoxP, "CENTER", -0.5,0.5)
            CreateTooltip(checkBoxP, "Pandemic Glow\n\nCheck for a red glow when the aura has less than 5 sec remaining.", "ANCHOR_TOPRIGHT")

            -- Handler for the P checkbox
            checkBoxP:SetScript("OnClick", function(self)
                npc.flags.pandemic = self:GetChecked() -- Save the state in the npc flags
            end)
            checkBoxP:HookScript("OnClick", BBP.RefreshAllNameplates)

            -- Initialize state from npc flags
            if npc.flags.pandemic then
                checkBoxP:SetChecked(true)
            end
        end

        if prioSlider then
            local prioritySlider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
            prioritySlider:SetSize(100, 16)
            prioritySlider:SetPoint("RIGHT", colorPickerButton or deleteButton, "LEFT", -65, 0)
            prioritySlider:SetOrientation("HORIZONTAL")
            prioritySlider:SetMinMaxValues(1, 10)
            prioritySlider:SetValueStep(1)
            prioritySlider:SetValue(npc.priority or 1) -- Set the default priority to 1 if not specified
            prioritySlider:SetObeyStepOnDrag(true)
            prioritySlider.Low:SetText("")
            prioritySlider.High:SetText("")
            CreateTooltip(prioritySlider, "Priority value.\nWhichever aura has the highest priority will determine the color.")

            local priorityText = prioritySlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            priorityText:SetPoint("RIGHT", prioritySlider, "LEFT", -5, 0)
            priorityText:SetText(prioritySlider:GetValue())
            priorityText:SetTextColor(1, 0.8196, 0, 1)

            prioritySlider:SetScript("OnValueChanged", function(self, value)
                local newValue = floor(value + 0.5) -- Round to the nearest integer
                self:SetValue(newValue)
                priorityText:SetText(newValue)
                updatePriority(index, newValue) -- Update the priority when the slider value changes
            end)

            button.prioritySlider = prioritySlider
        end

        button.deleteButton = deleteButton
        table.insert(textLines, button)
        updateBackgroundColors()  -- Update background colors after adding a new entry
    end


    -- Create and initialize textLine buttons with or without color pickers
    for i, npc in ipairs(listData) do
        createTextLineButton(npc, i, enableColorPicker)
    end

    -- Create static popup dialogs for duplicate and delete confirmations
    StaticPopupDialogs["BBP_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = "This name or npcID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)
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

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize(260, 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    if listName == "auraBlacklist" or
    listName == "auraWhitelist" or
    listName == "auraColorList" or
    listName == "auraColorList" or
    listName == "hideCastbarWhitelist" then
        CreateTooltip(editBox, "Filter auras by spell id and/or spell name", "ANCHOR_TOP")
    elseif listName == "hideCastbarList" then
        CreateTooltip(editBox, "Filter auras/npcs by spell/npc id and/or spell/npc name", "ANCHOR_TOP")
    else
        CreateTooltip(editBox, "Filter npcs by npc id and/or npc name", "ANCHOR_TOP")
    end

    local function addOrUpdateEntry(inputText)
        selectedLineIndex = nil
        local name, comment = strsplit("/", inputText, 2)
        name = strtrim(name or "")
        comment = strtrim(comment or "")
        local id = tonumber(name)

        -- Check if there's a numeric ID within the name and clear the name if found
        if id then
            name = ""
        end

        -- Remove unwanted characters from name and comment individually
        name = gsub(name, "[%/%(%)%[%]]", "")
        comment = gsub(comment, "[%/%(%)%[%]]", "")

        if (name ~= "" or id) then
            local isDuplicate = false

            for i, npc in ipairs(listData) do
                if (id and npc.id == id) or (not id and strlower(npc.name) == strlower(name)) then
                    isDuplicate = true
                    selectedLineIndex = i
                    break
                end
            end

            if isDuplicate then
                StaticPopup_Show("BBP_DUPLICATE_NPC_CONFIRM_" .. listName)
            else
                local newEntry = { name = name, id = id, comment = comment, flags = { important = false, pandemic = false } }
                table.insert(listData, { name = name, id = id, comment = comment })
                createTextLineButton({ name = name, id = id, comment = comment }, #textLines + 1, enableColorPicker)
                refreshFunc()
            end
        end

        editBox:SetText("") -- Clear the EditBox
    end

    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
    end)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText("Add")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)
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

            local durationLabel, durationEditBox = CreatePropertyField(npcEditFrame, "Duration:", npcEditFrame.iconTexture, 95, 90, 50, 20)
            npcEditFrame.durationEditBox = durationEditBox
            CreateTooltip(durationEditBox, "Enter new duration (0 for no duration)")

            local sizeLabel, sizeEditBox = CreatePropertyField(npcEditFrame, "Size:", durationLabel, 0, -15, 50, 20)
            npcEditFrame.sizeEditBox = sizeEditBox
            CreateTooltip(sizeEditBox, "Enter new size")

            local iconLabel, iconEditBox = CreatePropertyField(npcEditFrame, "Icon:", sizeLabel, 0, -15, 50, 20)
            npcEditFrame.iconEditBox = iconEditBox
            CreateTooltip(iconEditBox, "Enter new icon ID\n\nUse Wowhead to find a new icon.\nSearch for a spell then click on its icon and an icon ID will show.")


            local GlowText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            GlowText:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 0, -15)
            GlowText:SetText("Glow")

            local importantCheckBox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            importantCheckBox:SetSize(28, 28)
            importantCheckBox:SetPoint("LEFT", GlowText, "RIGHT", 5, 0)
            CreateTooltip(importantCheckBox, "Important Glow")
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
                ColorPickerFrame.func = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    text:SetTextColor(r, g, b)
                    npcEditFrame.iconGlowTexture:SetVertexColor(r, g, b)
                    npcEditFrame.nameEditBox:SetTextColor(r, g, b)
                    updateEntryColor(npcId, {r, g, b})
                end
                ColorPickerFrame:SetColorRGB(unpack(currentColor))
                ColorPickerFrame:ClearAllPoints()
                ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                ColorPickerFrame:Show()
            end)

            local HideText = npcEditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            HideText:SetPoint("TOPLEFT", GlowText, "BOTTOMLEFT", 0, -15)
            HideText:SetText("Hide Icon")

            -- Creation of the hideIconCheckbox
            local hideIconCheckbox = CreateFrame("CheckButton", nil, npcEditFrame, "UICheckButtonTemplate")
            hideIconCheckbox:SetSize(28, 28)
            hideIconCheckbox:SetPoint("LEFT", HideText, "RIGHT", 5, 0)

            CreateTooltip(hideIconCheckbox, "Hide Icon")

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
            updateButton:SetText("Update")
            npcEditFrame.updateButton = updateButton
        end

        local function PopulateEditFrame(npcId)
            local npcData = npcList[npcId]
            if not npcData then return end
            if not npcEditFrame then return end

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
                npcEditFrame.iconGlowTexture:SetVertexColor(unpack(color))
                npcEditFrame.currentColor = npcData.color
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
                updateNpcData()
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
        editButton:SetPoint("RIGHT", button, "RIGHT", -80, 0)
        editButton:SetText("Edit")
        editButton:SetScript("OnClick", function()
            ShowEditFrame(npcId)
        end)
        button.editButton = editButton

        -- Size button
        local sizeButton = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sizeButton:SetPoint("RIGHT", button, "RIGHT", -140, 0)
        local sizeText = npcData.size and "Size: " .. npcData.size or "Set Size"
        sizeButton:SetText(sizeText)

        -- Creation of the hideIconCheckbox
        local hideIconCheckboxButton = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        hideIconCheckboxButton:SetSize(24, 24)
        hideIconCheckboxButton:SetPoint("RIGHT", button, "RIGHT", -20, 0)
        hideIconCheckboxButton:SetScript("OnClick", function(self)
            updateHideIconFlag(npcId, self:GetChecked())
            if self:GetChecked() then
                iconTexture:Hide()
            else
                iconTexture:Show()
            end
        end)
        CreateTooltip(hideIconCheckboxButton, "Hide Icon")

        if npcData.hideIcon then
            hideIconCheckboxButton:SetChecked(true)
        end

        button.hideIconCheckboxButton = hideIconCheckboxButton

        local importantCheckBox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
        importantCheckBox:SetSize(24, 24)
        importantCheckBox:SetPoint("RIGHT", button, "RIGHT", -45, 0)
        importantCheckBox:SetScript("OnClick", function(self)
            updateImportantFlag(npcId, self:GetChecked())
        end)
        CreateTooltip(importantCheckBox, "Important Glow")

        if npcData.important then
            importantCheckBox:SetChecked(true)
        end

        button.importantCheckBox = importantCheckBox
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
    CreateTooltip(editBox, "Enter NPC ID first, name second and Spell ID (for icon) third.\n\nSeparate with commas. Name and Spell ID are optional.\n\nExample: 192123, Hermit Crab, 52127", "ANCHOR_TOP")

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
            id = npcId,
            name = name,  -- Name from input, or default if not provided
            icon = spellId and GetSpellTexture(spellId) or nil,  -- Get icon if spellId is provided
            hideIcon = false,
            size = 30,  -- Default size
            duration = nil,
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

    local bgImg = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local addonNameText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 17)
    addonNameText:SetText("BetterBlizzPlates")
    local addonNameIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    addonNameIcon:SetAtlas("gmchat-icon-blizz")
    addonNameIcon:SetSize(22, 22)
    addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    local verNumber = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    verNumber:SetText("v" .. BBP.VersionNumber)--SetText("v" .. BetterBlizzPlatesDB.updates)

    ----------------------
    -- General:
    ----------------------
    -- "General:" text
    local settingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 8)
    settingsText:SetText("General settings")
    local generalSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local removeRealmNames = CreateCheckbox("removeRealmNames", "Hide realm names", BetterBlizzPlates)
    removeRealmNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local hideNameplateAuras = CreateCheckbox("hideNameplateAuras", "Hide nameplate auras", BetterBlizzPlates)
    hideNameplateAuras:SetPoint("TOPLEFT", removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideTargetHighlight = CreateCheckbox("hideTargetHighlight", "Hide target highlight glow", BetterBlizzPlates)
    hideTargetHighlight:SetPoint("TOPLEFT", hideNameplateAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetHighlight, "Hide the bright glow on your current targets nameplate.")

    local raidmarkIndicator = CreateCheckbox("raidmarkIndicator", "Change raidmarker position", BetterBlizzPlates, nil, BBP.ChangeRaidmarker)
    raidmarkIndicator:SetPoint("TOPLEFT", hideTargetHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local nameplateMaxScale = CreateSlider(BetterBlizzPlates, "Nameplate Size", 0.5, 2, 0.01, "nameplateMaxScale")
    nameplateMaxScale:SetPoint("TOPLEFT", raidmarkIndicator, "BOTTOMLEFT", 12, -10)
    CreateTooltip(nameplateMaxScale, "General size of all nameplates (except Target nameplate)")

    local nameplateMaxScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateMaxScaleResetButton:SetText("Default")
    nameplateMaxScaleResetButton:SetWidth(60)
    nameplateMaxScaleResetButton:SetPoint("LEFT", nameplateMaxScale, "RIGHT", 10, 0)
    nameplateMaxScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateMaxScale, "nameplateScale")
    end)

    local nameplateSelectedScale = CreateSlider(BetterBlizzPlates, "Target Nameplate Size", 0.5, 3, 0.01, "nameplateSelectedScale")
    nameplateSelectedScale:SetPoint("TOPLEFT", nameplateMaxScale, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateSelectedScale, "Size of your current target's nameplate")

    local nameplateSelectedScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateSelectedScaleResetButton:SetText("Default")
    nameplateSelectedScaleResetButton:SetWidth(60)
    nameplateSelectedScaleResetButton:SetPoint("LEFT", nameplateSelectedScale, "RIGHT", 10, 0)
    nameplateSelectedScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateSelectedScale, "nameplateSelected")
    end)

    local NamePlateVerticalScale = CreateSlider(BetterBlizzPlates, "Nameplate Height", 0.5, 5, 0.01, "NamePlateVerticalScale")
    NamePlateVerticalScale:SetPoint("TOPLEFT", nameplateSelectedScale, "BOTTOMLEFT", 0, -17)
    CreateTooltip(NamePlateVerticalScale, "Changes the height of ALL nameplates.\n\nWill also increase castbar height by default,\ncan be re-adjusted with castbar customization.")

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
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -196)
    enemyNameplatesText:SetText("Enemy nameplates")
    local enemyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon:SetSize(28, 28)
    enemyNameplateIcon:SetPoint("RIGHT", enemyNameplatesText, "LEFT", -3, 0)
    enemyNameplateIcon:SetDesaturated(1)
    enemyNameplateIcon:SetVertexColor(1, 0, 0)

    local enemyClassColorName = CreateCheckbox("enemyClassColorName", "Class color name", BetterBlizzPlates)
    enemyClassColorName:SetPoint("TOPLEFT", enemyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltip(enemyClassColorName, "Class color the enemy name text on nameplate")

    local enemyColorName = CreateCheckbox("enemyColorName", "Color name", BetterBlizzPlates)
    enemyColorName:SetPoint("LEFT", enemyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltip(enemyColorName, "Pick one color for all enemy names\nIf class color name is also enabled this setting will only color the name of npcs")

    local function OpenColorPicker()
        local r, g, b = unpack(BetterBlizzPlatesDB.enemyColorNameRGB or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }
        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB.enemyColorNameRGB = { r, g, b }
            BBP.RefreshAllNameplates()
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB.enemyColorNameRGB = { r, g, b }
        end
        ColorPickerFrame:Show()
    end

    local enemyColorNameButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    enemyColorNameButton:SetText("Color")
    enemyColorNameButton:SetPoint("LEFT", enemyColorName.text, "RIGHT", -1, 0)
    enemyColorNameButton:SetSize(45, 20)
    enemyColorNameButton:SetScript("OnClick", OpenColorPicker)

    local enemyHealthBarColor = CreateCheckbox("enemyHealthBarColor", "Custom nameplate color", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    enemyHealthBarColor:SetPoint("TOPLEFT", enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(enemyHealthBarColor, "Color ALL enemy nameplates a color of your choice.")

    local enemyHealthBarColorNpcOnly = CreateCheckbox("enemyHealthBarColorNpcOnly", "Npc only", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    enemyHealthBarColorNpcOnly:SetPoint("LEFT", enemyHealthBarColor.Text, "RIGHT", 0, 0)
    CreateTooltip(enemyHealthBarColorNpcOnly, "Only color NPC's.")

    local function OpenColorPicker(colorType, icon)
        local r, g, b = unpack(BetterBlizzPlatesDB[colorType] or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }

        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB[colorType] = { r, g, b }
            BBP.RefreshAllNameplates()
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB[colorType] = { r, g, b }
        end

        ColorPickerFrame:Show()
    end

    local enemyHealthBarColorButton = CreateFrame("Button", nil, enemyHealthBarColor, "UIPanelButtonTemplate")
    enemyHealthBarColorButton:SetText("Hostile")
    enemyHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorNpcOnly.Text, "RIGHT", -1, 0)
    enemyHealthBarColorButton:SetSize(55, 20)
    enemyHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyHealthBarColorRGB", enemyHealthBarColorButtonIcon)
    end)
    CreateTooltip(enemyHealthBarColorButton, "Hostile color")

    local enemyNeutralHealthBarColorButton = CreateFrame("Button", nil, enemyHealthBarColor, "UIPanelButtonTemplate")
    enemyNeutralHealthBarColorButton:SetText("Neutral")
    enemyNeutralHealthBarColorButton:SetPoint("LEFT", enemyHealthBarColorButton, "RIGHT", 0, 0)
    enemyNeutralHealthBarColorButton:SetSize(55, 20)
    enemyNeutralHealthBarColorButton:SetScript("OnClick", function()
        OpenColorPicker("enemyNeutralHealthBarColorRGB", enemyNeutralHealthBarColorButton)
    end)
    CreateTooltip(enemyNeutralHealthBarColorButton, "Neutral color")

    enemyHealthBarColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            enemyHealthBarColorNpcOnly:Enable()
            enemyHealthBarColorNpcOnly:SetAlpha(1)
            enemyNeutralHealthBarColorButton:Enable()
            enemyNeutralHealthBarColorButton:SetAlpha(1)
            enemyHealthBarColorButton:Enable()
            enemyHealthBarColorButton:SetAlpha(1)
        else
            enemyHealthBarColorNpcOnly:SetAlpha(0)
            enemyHealthBarColorNpcOnly:Disable()
            enemyNeutralHealthBarColorButton:Disable()
            enemyNeutralHealthBarColorButton:SetAlpha(0)
            enemyHealthBarColorButton:Disable()
            enemyHealthBarColorButton:SetAlpha(0)
        end
    end)
    if not BetterBlizzPlatesDB.enemyHealthBarColor then
        enemyHealthBarColorNpcOnly:SetAlpha(0)
        enemyHealthBarColorNpcOnly:Disable()
        enemyNeutralHealthBarColorButton:Disable()
        enemyNeutralHealthBarColorButton:SetAlpha(0)
        enemyHealthBarColorButton:SetAlpha(0)
        enemyHealthBarColorButton:Disable()
    end

    local showNameplateCastbarTimer = CreateCheckbox("showNameplateCastbarTimer", "Cast timer next to castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateCastbarTimer:SetPoint("TOPLEFT", enemyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local showNameplateTargetText = CreateCheckbox("showNameplateTargetText", "Show target underneath castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateTargetText:SetPoint("TOPLEFT", showNameplateCastbarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showNameplateTargetText, "Show the targets name under their castbar")

    local enemyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 1.5, 0.01, "enemyNameScale")
    enemyNameScale:SetPoint("TOPLEFT", showNameplateTargetText, "BOTTOMLEFT", 12, -10)
    CreateTooltip(enemyNameScale, "Size of enemy name text above nameplate")

    local hideEnemyNameText = CreateCheckbox("hideEnemyNameText", "Hide name", BetterBlizzPlates)
    hideEnemyNameText:SetPoint("LEFT", enemyNameScale, "RIGHT", 2, 0)
    CreateTooltip(hideEnemyNameText, "Hide enemy nameplate name text")

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

    local nameplateEnemyWidth = CreateSlider(BetterBlizzPlates, "Nameplate Width", 50, 200, 1, "nameplateEnemyWidth")
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
    friendlyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -363)
    friendlyNameplatesText:SetText("Friendly nameplates")
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", "Clickthrough", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltip(friendlyNameplateClickthrough, "Make friendly nameplates clickthrough and make them overlap despite stacking nameplates setting.")

    local friendlyClassColorName = CreateCheckbox("friendlyClassColorName", "Class color name", BetterBlizzPlates)
    friendlyClassColorName:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyClassColorName, "Class color the friendly name text on nameplate")

    local friendlyColorName = CreateCheckbox("friendlyColorName", "Color name", BetterBlizzPlates)
    friendlyColorName:SetPoint("LEFT", friendlyClassColorName.text, "RIGHT", 0, 0)
    CreateTooltip(friendlyColorName, "Pick one color for all enemy names\nIf class color name is also enabled this setting will only color the name of npcs")

    local function OpenColorPicker2()
        local r, g, b = unpack(BetterBlizzPlatesDB.friendlyColorNameRGB or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }
        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB.friendlyColorNameRGB = { r, g, b }
            BBP.RefreshAllNameplates()
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB.friendlyColorNameRGB = { r, g, b }
        end
        ColorPickerFrame:Show()
    end

    local friendlyColorNameButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    friendlyColorNameButton:SetText("Color")
    friendlyColorNameButton:SetPoint("LEFT", friendlyColorName.text, "RIGHT", -1, 0)
    friendlyColorNameButton:SetSize(45, 20)
    friendlyColorNameButton:SetScript("OnClick", OpenColorPicker2)

    local classColorPersonalNameplate = CreateCheckbox("classColorPersonalNameplate", "Class colored personal nameplate", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    classColorPersonalNameplate:SetPoint("TOPLEFT", friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyHealthBarColor = CreateCheckbox("friendlyHealthBarColor", "Custom nameplate color", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    friendlyHealthBarColor:SetPoint("TOPLEFT", classColorPersonalNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(friendlyHealthBarColor, "Color ALL friendly nameplates a color of your choice.")

    local friendlyNameColor = CreateCheckbox("friendlyNameColor", "Name", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    friendlyNameColor:SetPoint("LEFT", friendlyHealthBarColor.Text, "RIGHT", 0, 0)
    friendlyNameColor:HookScript("OnClick", function(self)
        if self:GetChecked(true) then
            BetterBlizzPlatesDB.friendlyClassColorName = false
            friendlyClassColorName:SetChecked(false)
        end
    end)
    CreateTooltip(friendlyNameColor, "Color friendly name text as well.")

    friendlyClassColorName:HookScript("OnClick", function(self)
        if self:GetChecked(true) then
            BetterBlizzPlatesDB.friendlyNameColor = false
            friendlyNameColor:SetChecked(false)
        end
    end)

    local function UpdateColorSquare(icon, r, g, b)
        if r and g and b then
            icon:SetVertexColor(r, g, b)
        end
    end

    local function OpenColorPicker(colorType, icon)
        local r, g, b = unpack(BetterBlizzPlatesDB[colorType] or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }
        UpdateColorSquare(icon, r, g, b)

        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB[colorType] = { r, g, b }
            BBP.RefreshAllNameplates()
            UpdateColorSquare(icon, r, g, b)
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB[colorType] = { r, g, b }
            UpdateColorSquare(icon, r, g, b)
        end

        ColorPickerFrame:Show()
    end

    local friendlyHealthBarColorButton = CreateFrame("Button", nil, friendlyHealthBarColor, "UIPanelButtonTemplate")
    friendlyHealthBarColorButton:SetText("Color")
    friendlyHealthBarColorButton:SetPoint("LEFT", friendlyNameColor.Text, "RIGHT", -1, 0)
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
            friendlyNameColor:Enable()
            friendlyNameColor:SetAlpha(1)
            friendlyHealthBarColorButton:Enable()
            friendlyHealthBarColorButton:SetAlpha(1)
            friendlyHealthBarColorButtonIcon:SetAlpha(1)
        else
            friendlyNameColor:SetAlpha(0)
            friendlyNameColor:Disable()
            friendlyHealthBarColorButton:Disable()
            friendlyHealthBarColorButton:SetAlpha(0)
            friendlyHealthBarColorButtonIcon:SetAlpha(0)
        end
    end)
    if not BetterBlizzPlatesDB.friendlyHealthBarColor then
        friendlyNameColor:SetAlpha(0)
        friendlyHealthBarColorButtonIcon:SetAlpha(0)
        friendlyHealthBarColorButton:SetAlpha(0) --default slider creation only does 0.5 alpha
    end

    local friendlyHideHealthBar = CreateCheckbox("friendlyHideHealthBar", "Hide healthbar", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    friendlyHideHealthBar:SetPoint("TOPLEFT", friendlyHealthBarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    friendlyHideHealthBar:HookScript("OnClick", function()
        BBP.HideHealthbarInPvEMagicCaller()
    end)
    CreateTooltip(friendlyHideHealthBar, "Hide friendly nameplate healthbars. Castbar and name will still show.")

    local friendlyHideHealthBarNpc = CreateCheckbox("friendlyHideHealthBarNpc", "NPC's", BetterBlizzPlates, nil, BBP.RefreshAllNameplates)
    friendlyHideHealthBarNpc:SetPoint("LEFT", friendlyHideHealthBar.text, "RIGHT", 0, 0)
    CreateTooltip(friendlyHideHealthBarNpc, "Hide friendly NPC nameplate healthbars. Castbar and name will still show.")

    friendlyHideHealthBar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            friendlyHideHealthBarNpc:Enable()
            friendlyHideHealthBarNpc:SetAlpha(1)
        else
            friendlyHideHealthBarNpc:Disable()
            friendlyHideHealthBarNpc:SetAlpha(0)
        end
    end)
    if not BetterBlizzPlatesDB.friendlyHideHealthBar then
        friendlyHideHealthBarNpc:SetAlpha(0)
        friendlyHideHealthBarNpc:Disable()
    end

    local toggleFriendlyNameplatesInArena = CreateCheckbox("friendlyNameplatesOnlyInArena", "Toggle on/off for Arena auto", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesInArena)
    toggleFriendlyNameplatesInArena:SetPoint("TOPLEFT", friendlyHideHealthBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(toggleFriendlyNameplatesInArena, "Turn on friendly nameplates when you enter arena and off again when you leave.")

    local friendlyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 3, 0.01, "friendlyNameScale")
    friendlyNameScale:SetPoint("TOPLEFT", toggleFriendlyNameplatesInArena, "BOTTOMLEFT", 12, -10)
    CreateTooltip(friendlyNameScale, "Size of the friendly name text above nameplates")

    local hideFriendlyNameText = CreateCheckbox("hideFriendlyNameText", "Hide name", BetterBlizzPlates)
    hideFriendlyNameText:SetPoint("LEFT", friendlyNameScale, "RIGHT", 2, 0)
    CreateTooltip(hideFriendlyNameText, "Hide friendly nameplate name text")

    local nameplateFriendlyWidth = CreateSlider(BetterBlizzPlates, "Nameplate Width", 50, 200, 1, "nameplateFriendlyWidth")
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
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 390, -205)
    extraFeaturesText:SetText("Extra Features")
    local extraFeaturesIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)

    local testAllEnabledFeatures = CreateCheckbox("testAllEnabledFeatures", "Test", BetterBlizzPlates, nil, BBP.TestAllEnabledFeatures)           
    testAllEnabledFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
    CreateTooltip(testAllEnabledFeatures, "Test all enabled features. Check advanced settings for more")

    local absorbIndicator = CreateCheckbox("absorbIndicator", "Absorb indicator", BetterBlizzPlates, nil, BBP.ToggleAbsorbIndicator)
    absorbIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    CreateTooltip(absorbIndicator, "Show absorb amount on nameplates")
    local absorbsIcon = absorbIndicator:CreateTexture(nil, "ARTWORK")
    absorbsIcon:SetAtlas("ParagonReputation_Glow")
    absorbsIcon:SetSize(22, 22)
    absorbsIcon:SetPoint("RIGHT", absorbIndicator, "LEFT", 2, 0)

    local classIndicator = CreateCheckbox("classIndicator", "Class indicator", BetterBlizzPlates)
    classIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    CreateTooltip(classIndicator, "Show class icon on nameplates")
    local classIndicatorIcon = classIndicator:CreateTexture(nil, "ARTWORK")
    classIndicatorIcon:SetAtlas("groupfinder-icon-class-mage")
    classIndicatorIcon:SetSize(18, 18)
    classIndicatorIcon:SetPoint("RIGHT", classIndicator, "LEFT", 0, 0)

    local combatIndicator = CreateCheckbox("combatIndicator", "Combat indicator", BetterBlizzPlates, nil, BBP.ToggleCombatIndicator)
    combatIndicator:SetPoint("TOPLEFT", classIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(combatIndicator, "Show a food icon on nameplates that are out of combat")
    local combatIcon = combatIndicator:CreateTexture(nil, "ARTWORK")
    combatIcon:SetAtlas("food")
    combatIcon:SetSize(19, 19)
    combatIcon:SetPoint("RIGHT", combatIndicator, "LEFT", -1, 0)

    local executeIndicator = CreateCheckbox("executeIndicator", "Execute indicator", BetterBlizzPlates, nil, BBP.ToggleExecuteIndicator)
    executeIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicator, "Starts tracking health percentage once target\ndips below a certain percentage.\n40% by default, can be changed in Advanced Settings.")
    local executeIndicatorIcon = executeIndicator:CreateTexture(nil, "ARTWORK")
    executeIndicatorIcon:SetAtlas("islands-azeriteboss")
    executeIndicatorIcon:SetSize(28, 30)
    executeIndicatorIcon:SetPoint("RIGHT", executeIndicator, "LEFT", 4, 1)

    local healerIndicator = CreateCheckbox("healerIndicator", "Healer indicator", BetterBlizzPlates)
    healerIndicator:SetPoint("TOPLEFT", executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(healerIndicator, "Show a cross on healers. Requires Details to work.")
    local healerCrossIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    healerCrossIcon:SetAtlas("greencross")
    healerCrossIcon:SetSize(21, 21)
    healerCrossIcon:SetPoint("RIGHT", healerIndicator, "LEFT", 0, 0)

    local petIndicator = CreateCheckbox("petIndicator", "Pet indicator", BetterBlizzPlates)
    petIndicator:SetPoint("TOPLEFT", healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(petIndicator, "Show a murloc on the main hunter pet")
    local petIndicatorIcon = petIndicator:CreateTexture(nil, "ARTWORK")
    petIndicatorIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicatorIcon:SetSize(18, 18)
    petIndicatorIcon:SetPoint("RIGHT", petIndicator, "LEFT", -1, 0)

    local targetIndicator = CreateCheckbox("targetIndicator", "Target indicator", BetterBlizzPlates, nil, BBP.ToggleTargetIndicator)
    targetIndicator:SetPoint("TOPLEFT", petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetIndicator, "Show a pointer on your current target")
    local targetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    targetIndicatorIcon:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicatorIcon:SetRotation(math.rad(180))
    targetIndicatorIcon:SetSize(19, 14)
    targetIndicatorIcon:SetPoint("RIGHT", targetIndicator, "LEFT", -1, 0)

    local focusTargetIndicator = CreateCheckbox("focusTargetIndicator", "Focus target indicator", BetterBlizzPlates, nil, BBP.ToggleFocusTargetIndicator)
    focusTargetIndicator:SetPoint("TOPLEFT", targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusTargetIndicator, "Show a marker on the focus nameplate")
    local focusTargetIndicatorIcon = healerIndicator:CreateTexture(nil, "ARTWORK")
    focusTargetIndicatorIcon:SetAtlas("Waypoint-MapPin-Untracked")
    focusTargetIndicatorIcon:SetSize(19, 19)
    focusTargetIndicatorIcon:SetPoint("RIGHT", focusTargetIndicator, "LEFT", 0, 0)

    local totemIndicator = CreateCheckbox("totemIndicator", "Totem indicator", BetterBlizzPlates)
    totemIndicator:SetPoint("TOPLEFT", focusTargetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicator, "Color and put icons on key npc and totem nameplates.\nImportant npcs and totems will be slightly larger and\nhave a glow around the icon")
    local totemsIcon = totemIndicator:CreateTexture(nil, "ARTWORK")
    totemsIcon:SetAtlas("teleportationnetwork-ardenweald-32x32")
    totemsIcon:SetSize(17, 17)
    totemsIcon:SetPoint("RIGHT", totemIndicator, "LEFT", -1, 0)

    local questIndicator = CreateCheckbox("questIndicator", "Quest indicator", BetterBlizzPlates)
    questIndicator:SetPoint("TOPLEFT", totemIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(questIndicator, "Quest symbol on quest npcs")
    local questsIcon = questIndicator:CreateTexture(nil, "ARTWORK")
    questsIcon:SetAtlas("smallquestbang")
    questsIcon:SetSize(20, 20)
    questsIcon:SetPoint("RIGHT", questIndicator, "LEFT", 1, 0)

    ----------------------
    -- Font and texture
    ----------------------
    local customFontandTextureText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -435)
    customFontandTextureText:SetText("Font and texture")
    local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    customFontandTextureIcon:SetAtlas("barbershop-32x32")
    customFontandTextureIcon:SetSize(24, 24)
    customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

    local useCustomFont = CreateCheckbox("useCustomFont", "Use a sexy font for nameplates", BetterBlizzPlates)
    useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    local useCustomTexture = CreateCheckbox("useCustomTextureForBars", "Use a sexy texture for nameplates", BetterBlizzPlates)
    useCustomTexture:SetPoint("TOPLEFT", useCustomFont, "BOTTOMLEFT", 0, -20)

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

    local useCustomTextureForEnemy = CreateCheckbox("useCustomTextureForEnemy", "Enemy", useCustomTexture)
    useCustomTextureForEnemy:SetPoint("LEFT", textureDropdown, "RIGHT", -15, 1)
    useCustomTextureForEnemy.text:SetTextColor(1,0,0)

    local useCustomTextureForFriendly = CreateCheckbox("useCustomTextureForFriendly", "Friendly", useCustomTexture)
    useCustomTextureForFriendly:SetPoint("LEFT", textureDropdownFriendly, "RIGHT", -15, 1)
    useCustomTextureForFriendly.text:SetTextColor(0.04, 0.76, 1)

    useCustomFont:HookScript("OnClick", function(self)
        if self:GetChecked() then
            UIDropDownMenu_EnableDropDown(fontDropdown)
        else
            UIDropDownMenu_DisableDropDown(fontDropdown)
        end
    end)

    useCustomTexture:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(useCustomTexture)
        if self:GetChecked() then
            UIDropDownMenu_EnableDropDown(textureDropdown)
            UIDropDownMenu_EnableDropDown(textureDropdownFriendly)
            --useCustomTextureForEnemy:Enable()
            --useCustomTextureForEnemy:SetAlpha(1)
            --useCustomTextureForFriendly:Enable()
            --useCustomTextureForFriendly:SetAlpha(1)
        else
            UIDropDownMenu_DisableDropDown(textureDropdown)
            UIDropDownMenu_DisableDropDown(textureDropdownFriendly)
            --useCustomTextureForEnemy:Disable()
            --useCustomTextureForEnemy:SetAlpha(0)
            --useCustomTextureForFriendly:Disable()
            --useCustomTextureForFriendly:SetAlpha(0)
        end
    end)


    ----------------------
    -- Arena
    ----------------------
    local arenaSettingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaSettingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, 20)
    arenaSettingsText:SetText("Arena nameplates")
    local arenaSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    arenaSettingsIcon:SetAtlas("questbonusobjective")
    arenaSettingsIcon:SetSize(24, 24)
    arenaSettingsIcon:SetPoint("RIGHT", arenaSettingsText, "LEFT", -3, 0)

    local arenaModeDropdown = CreateModeDropdown(
        "arenaModeDropdown",
        BetterBlizzPlates,
        "Select a mode to use",
        "arenaModeSettingKey",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSettingsText, x = -20, y = -30, label = "Mode" },
        modes,
        tooltips,
        "Enemy",
        {1, 0, 0, 1}
    )

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", "Short", BetterBlizzPlates, BBP.RefreshAllNameplates)
    shortArenaSpecName:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)
    CreateTooltip(shortArenaSpecName, "Enable to use abbreviated specialization names.\nFor instance, \"Assassination\" will be displayed as \"Assa\".", "ANCHOR_LEFT")

    local arenaIndicatorTestMode = CreateCheckbox("arenaIndicatorTestMode", "Test", BetterBlizzPlates, BBP.RefreshAllNameplates)
    arenaIndicatorTestMode:SetPoint("LEFT", shortArenaSpecName.Text, "RIGHT", 5, 0)
    CreateTooltip(arenaIndicatorTestMode, "Test the selected Arena Nameplates mode.", "ANCHOR_LEFT")

    local arenaIDScale = CreateSlider(BetterBlizzPlates, "Arena ID Size", 0.5, 4, 0.01, "arenaIDScale")
    arenaIDScale:SetPoint("TOPLEFT", arenaModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltip(arenaIDScale, "Size of the enemy arena ID text on top of nameplate during arena.")

    local arenaSpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.01, "arenaSpecScale")
    arenaSpecScale:SetPoint("TOPLEFT", arenaIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltip(arenaSpecScale, "Size of the enemy spec name text on top of nameplate during arena.")

    local partyModeDropdown = CreateModeDropdown(
        "partyModeDropdown",
        BetterBlizzPlates,
        "Select a mode to use",
        "partyModeSettingKey",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSpecScale, x = -20, y = -30, label = "Mode" },
        modesParty,
        tooltipsParty,
        "Friendly",
        {0.04, 0.76, 1, 1}
    )

    local partyIDScale = CreateSlider(BetterBlizzPlates, "Party ID Size", 0.5, 4, 0.01, "partyIDScale")
    partyIDScale:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltip(partyIDScale, "Size of the friendly party ID text on top of nameplate during arena.")

    local partySpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.01, "partySpecScale")
    partySpecScale:SetPoint("TOPLEFT", partyIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltip(partySpecScale, "Size of the friendly spec name text on top of nameplate during arena.")

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

    local nahjProfileButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nahjProfileButton:SetText("Nahj Profile")
    nahjProfileButton:SetWidth(100)
    nahjProfileButton:SetPoint("RIGHT", reloadUiButton, "LEFT", -10, 0)
    nahjProfileButton:SetScript("OnClick", function()
        StaticPopup_Show("BBP_CONFIRM_NAHJ_PROFILE")
    end)
    CreateTooltip(nahjProfileButton, "Enable all of Nahj's profile settings.")

    StaticPopupDialogs["BBP_CONFIRM_NAHJ_PROFILE"] = {
        text = "This action will modify all settings to Nahj's profile and reload the UI.\n\nYour existing blacklists and whitelists will be retained, with Nahj's additional entries.\n\nAre you sure you want to continue?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            BBP.NahjProfile()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
end

local function guiPositionAndScale()
    ----------------------
    -- Advanced settings
    ----------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -360
    local thirdLineX = 391
    local thirdLineY = -655
    local fourthLineX = 560

    local BetterBlizzPlatesSubPanel = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel.name = "Advanced Settings"
    BetterBlizzPlatesSubPanel.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel)

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

    local healerIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "healerIndicatorScale")
    healerIndicatorScale:SetPoint("TOP", anchorSubHeal, "BOTTOM", 0, -15)

    local healerIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "healerIndicatorXPos", "X")
    healerIndicatorXPos:SetPoint("TOP", healerIndicatorScale, "BOTTOM", 0, -15)

    local healerIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "healerIndicatorYPos", "Y")
    healerIndicatorYPos:SetPoint("TOP", healerIndicatorXPos, "BOTTOM", 0, -15)

    local healerIndicatorDropdown = CreateAnchorDropdown(
        "healerIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "healerIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = healerIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local healerIndicatorTestMode2 = CreateCheckbox("healerIndicatorTestMode", "Test", contentFrame)
    healerIndicatorTestMode2:SetPoint("TOPLEFT", healerIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local healerIndicatorEnemyOnly2 = CreateCheckbox("healerIndicatorEnemyOnly", "Enemies only", contentFrame)
    healerIndicatorEnemyOnly2:SetPoint("TOPLEFT", healerIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorArenaOnly = CreateCheckbox("healerIndicatorArenaOnly", "Arena only", contentFrame)
    healerIndicatorArenaOnly:SetPoint("TOPLEFT", healerIndicatorEnemyOnly2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local healerIndicatorBgOnly = CreateCheckbox("healerIndicatorBgOnly", "Battleground only", contentFrame)
    healerIndicatorBgOnly:SetPoint("TOPLEFT", healerIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

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

    local petIndicatorTestMode2 = CreateCheckbox("petIndicatorTestMode", "Test", contentFrame)
    petIndicatorTestMode2:SetPoint("TOPLEFT", petIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

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
    -- Totem Indicator
    ----------------------
    local anchorSubTotem = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, thirdLineY)
    anchorSubTotem:SetText("Totem Indicator")

    CreateBorderBox(anchorSubTotem)

    local totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    totemIcon2:SetAtlas("teleportationnetwork-ardenweald-32x32")
    totemIcon2:SetSize(34, 34)
    totemIcon2:SetPoint("BOTTOM", anchorSubTotem, "TOP", 0, 0)

    local totemIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 3, 0.01, "totemIndicatorScale")
    totemIndicatorScale:SetPoint("TOP", anchorSubTotem, "BOTTOM", 0, -15)
    CreateTooltip(totemIndicatorScale, "This changes the scale of ALL icons.\n\nYou can adjust individual sizes in the \"Totem Indicator List\" tab.", "ANCHOR_LEFT")

    local totemIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "totemIndicatorXPos", "X")
    totemIndicatorXPos:SetPoint("TOP", totemIndicatorScale, "BOTTOM", 0, -15)

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

    local totemIndicatorDefaultCooldownTextSize = CreateSlider(contentFrame, "Default CD Size", 0.3, 2, 0.01, "totemIndicatorDefaultCooldownTextSize")
    totemIndicatorDefaultCooldownTextSize:SetPoint("TOP", totemIndicatorHideNameAndShiftIconDown, "BOTTOM", 58, -29)
    CreateTooltip(totemIndicatorDefaultCooldownTextSize, "Size of the default Blizz CD text.\n\nWill not work with OmniCC.")

    ----------------------
    -- Target indicator
    ----------------------
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubTarget:SetText("Target Indicator")

    CreateBorderBox(anchorSubTarget)

    local targetIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    targetIndicator2:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicator2:SetRotation(math.rad(180))
    targetIndicator2:SetSize(48, 32)
    targetIndicator2:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

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

    ----------------------
    -- Raid Indicator
    ----------------------
    local anchorSubRaidmark = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubRaidmark:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, thirdLineY)
    anchorSubRaidmark:SetText("Raidmarker")

    CreateBorderBox(anchorSubRaidmark)

    local raidmarkIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    raidmarkIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_3")
    raidmarkIcon:SetSize(32, 32)
    raidmarkIcon:SetPoint("BOTTOM", anchorSubRaidmark, "TOP", 0, 3)

    local raidmarkIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "raidmarkIndicatorScale")
    raidmarkIndicatorScale:SetPoint("TOP", anchorSubRaidmark, "BOTTOM", 0, -15)

    local raidmarkIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "raidmarkIndicatorXPos", "X")
    raidmarkIndicatorXPos:SetPoint("TOP", raidmarkIndicatorScale, "BOTTOM", 0, -15)

    local raidmarkIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "raidmarkIndicatorYPos", "Y")
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

    local raidmarkIndicator2 = CreateCheckbox("raidmarkIndicator", "Change raidmarker pos", contentFrame, nil, BBP.ChangeRaidmarker)
    raidmarkIndicator2:SetPoint("TOPLEFT", raidmarkIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

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
    focusIcon:SetAtlas("Waypoint-MapPin-Untracked")
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

    local function OpenColorPicker()
        local r, g, b = unpack(BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }
        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB = { r, g, b }
            BBP.RefreshAllNameplates()
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB.focusTargetIndicatorColorNameplateRGB = { r, g, b }
        end
        ColorPickerFrame:Show()
    end

    local focusTargetIndicatorColorNameplate = CreateCheckbox("focusTargetIndicatorColorNameplate", "Color healthbar", contentFrame)
    focusTargetIndicatorColorNameplate:SetPoint("TOPLEFT", focusTargetTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local focusColorButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    focusColorButton:SetText("Color")
    focusColorButton:SetPoint("LEFT", focusTargetIndicatorColorNameplate.text, "RIGHT", -1, 0)
    focusColorButton:SetSize(43, 18)
    focusColorButton:SetScript("OnClick", OpenColorPicker)

    focusTargetIndicatorColorNameplate:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate = self:GetChecked()
        local nameplateForFocusTarget = C_NamePlate.GetNamePlateForUnit("focus")
        if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
            focusColorButton:Enable()
            focusColorButton:SetAlpha(1)
        else
            focusColorButton:Disable()
            focusColorButton:SetAlpha(0.5)
        end
        BBP.FocusTargetIndicator(nameplateForFocusTarget)
        BBP.RefreshAllNameplates()
    end)

    if BetterBlizzPlatesDB.focusTargetIndicatorColorNameplate then
        focusColorButton:Enable()
        focusColorButton:SetAlpha(1)
    else
        focusColorButton:Disable()
        focusColorButton:SetAlpha(0.5)
    end

    local focusTargetIndicatorChangeTexture = CreateCheckbox("focusTargetIndicatorChangeTexture", "Re-texture healthbar", contentFrame)
    focusTargetIndicatorChangeTexture:SetPoint("TOPLEFT", focusTargetIndicatorColorNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

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
            UIDropDownMenu_EnableDropDown(focusTargetIndicatorTexture)
        else
            UIDropDownMenu_DisableDropDown(focusTargetIndicatorTexture)
        end
    end)

    ----------------------
    -- Execute Indicator
    ----------------------
    local anchorSubExecute = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubExecute:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY)
    anchorSubExecute:SetText("Execute Indicator")

    CreateBorderBox(anchorSubExecute)

    local executeIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    executeIcon:SetAtlas("islands-azeriteboss")
    executeIcon:SetSize(56, 60)
    executeIcon:SetPoint("BOTTOM", anchorSubExecute, "TOP", 0, -10)

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

    local executeIndicatorNotOnFullHp = CreateCheckbox("executeIndicatorNotOnFullHp", "< 100%", contentFrame)
    executeIndicatorNotOnFullHp:SetPoint("LEFT", executeIndicatorAlwaysOn.text, "RIGHT", 2, 0)
    CreateTooltip(executeIndicatorNotOnFullHp, "Hide on 100%")

    local executeIndicatorPercentSymbol = CreateCheckbox("executeIndicatorPercentSymbol", "% Symbol", contentFrame)
    executeIndicatorPercentSymbol:SetPoint("TOPLEFT", executeIndicatorNotOnFullHp, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorPercentSymbol, "Show % Symbol")

    local executeIndicatorShowDecimal = CreateCheckbox("executeIndicatorShowDecimal", "Decimal", contentFrame)
    executeIndicatorShowDecimal:SetPoint("BOTTOMLEFT", executeIndicatorNotOnFullHp, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorShowDecimal, "Show decimal")

    local executeIndicatorThreshold = CreateSlider(contentFrame, "Threshold", 5, 100, 1, "executeIndicatorThreshold")
    executeIndicatorThreshold:SetPoint("TOP", executeIndicatorAlwaysOn, "BOTTOM", 58, -29)
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

    local arenaIndicator = contentFrame:CreateTexture(nil, "ARTWORK")
    arenaIndicator:SetAtlas("questbonusobjective")
    arenaIndicator:SetSize(32, 32)
    arenaIndicator:SetPoint("BOTTOM", anchorSubArena, "TOP", 0, 3)

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

    local arenaIndicatorTestMode2 = CreateCheckbox("arenaIndicatorTestMode", "Test", contentFrame)
    arenaIndicatorTestMode2:SetPoint("TOPLEFT", arenaSpecAnchorDropdown, "BOTTOMLEFT", 16, 8)


    ----------------------
    -- Class Icon
    ----------------------
    local anchorSubClassIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubClassIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubClassIcon:SetText("Class Icon")

    CreateBorderBox(anchorSubClassIcon)

    local classIconIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    classIconIcon:SetAtlas("groupfinder-icon-class-mage")
    classIconIcon:SetSize(33, 33)
    classIconIcon:SetPoint("BOTTOM", anchorSubClassIcon, "TOP", 0, 1.5)
    --classIconIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local classIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.01, "classIndicatorScale")
    classIndicatorScale:SetPoint("TOP", anchorSubClassIcon, "BOTTOM", 0, -15)

    local classIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "classIndicatorXPos", "X")
    classIndicatorXPos:SetPoint("TOP", classIndicatorScale, "BOTTOM", 0, -15)

    local classIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "classIndicatorYPos", "Y")
    classIndicatorYPos:SetPoint("TOP", classIndicatorXPos, "BOTTOM", 0, -15)

    local classIconDropdown = CreateAnchorDropdown(
        "classIconDropdown",
        contentFrame,
        "Select Anchor Point",
        "classIndicatorAnchor",
        function(arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = classIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local classIconSquareBorder = CreateCheckbox("classIconSquareBorder", "Square", contentFrame)
    classIconSquareBorder:SetPoint("TOPLEFT", classIconDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
    CreateTooltip(classIconSquareBorder, "Square border instead of circle")

    local classIconColorBorder = CreateCheckbox("classIconColorBorder", "Color", contentFrame)
    classIconColorBorder:SetPoint("LEFT", classIconSquareBorder.text, "RIGHT", 0, 0)
    CreateTooltip(classIconColorBorder, "Class color border")

    local classIndicatorEnemy = CreateCheckbox("classIndicatorEnemy", "Enemies", contentFrame)
    classIndicatorEnemy:SetPoint("TOPLEFT", classIconSquareBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorEnemy, "Show class indicator on enemy nameplates")

    local classIndicatorFriendly = CreateCheckbox("classIndicatorFriendly", "Friendly", contentFrame)
    classIndicatorFriendly:SetPoint("LEFT", classIndicatorEnemy.text, "RIGHT", 0, 0)
    CreateTooltip(classIndicatorFriendly, "Show class indicator on friendly nameplates")

    local classIconArenaOnly = CreateCheckbox("classIconArenaOnly", "Arena only", contentFrame)
    classIconArenaOnly:SetPoint("TOPLEFT", classIndicatorEnemy, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIconArenaOnly, "Show in arena only")

    local classIconBgOnly = CreateCheckbox("classIconBgOnly", "BG only", contentFrame)
    classIconBgOnly:SetPoint("LEFT", classIconArenaOnly.text, "RIGHT", 0, 0)
    CreateTooltip(classIconBgOnly, "Show in battlegrounds only")

    local classIndicatorSpecIcon = CreateCheckbox("classIndicatorSpecIcon", "Spec", contentFrame)
    classIndicatorSpecIcon:SetPoint("TOPLEFT", classIconArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classIndicatorSpecIcon, "Show spec instead of class icon. (Requires Details)\n\nNote: The spec information might not always\nbe available and it will default to class icon.")

    local classIndicatorHealer = CreateCheckbox("classIndicatorHealer", "Healer Icon", contentFrame)
    classIndicatorHealer:SetPoint("LEFT", classIndicatorSpecIcon.text, "RIGHT", 0, 0)
    CreateTooltip(classIndicatorHealer, "Show cross instead of class/spec icon on healers")

    ----

    local reloadUiButton2 = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
    reloadUiButton2:SetText("Reload UI")
    reloadUiButton2:SetWidth(85)
    reloadUiButton2:SetPoint("TOP", BetterBlizzPlatesSubPanel, "BOTTOMRIGHT", -140, -9)
    reloadUiButton2:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)
end

local function guiCastbar()
    --------------------------------
    -- Castbar Customization
    --------------------------------
    local guiCastbar = CreateFrame("Frame")
    guiCastbar.name = "Castbar"
    guiCastbar.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(guiCastbar)

    local bgImg = guiCastbar:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiCastbar, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiCastbar)
    listFrame:SetAllPoints(guiCastbar)
    CreateList(listFrame, "castEmphasisList", BetterBlizzPlatesDB.castEmphasisList, BBP.RefreshAllNameplates, true)

    local how2usecastemphasis = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usecastemphasis:SetPoint("TOP", guiCastbar, "BOTTOMLEFT", 180, 155)
    how2usecastemphasis:SetText("Add name or spell ID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or polymorph/kick this\n \nType a name or spell ID already in list to delete it")

    local castbarSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -250, -13)
    castbarSettingsText:SetText("Castbar settings")
    local castbarSettingsIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsIcon:SetSize(24, 24)
    castbarSettingsIcon:SetPoint("RIGHT", castbarSettingsText, "LEFT", -3, 0)

    local enableCastbarCustomization = CreateCheckbox("enableCastbarCustomization", "Enable castbar customization", guiCastbar, nil, BBP.ToggleSpellCastEventRegistration)
    enableCastbarCustomization:SetPoint("TOPLEFT", castbarSettingsText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    local showCastBarIconWhenNoninterruptible = CreateCheckbox("showCastBarIconWhenNoninterruptible", "Show Cast Icon on Non-Interruptable", enableCastbarCustomization)
    showCastBarIconWhenNoninterruptible:SetPoint("TOPLEFT", enableCastbarCustomization, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showCastBarIconWhenNoninterruptible, "Show the cast icon on non-interruptable casts (on top of shield),\njust like every other castbar in the game.\n\nBest used together with Dragonflight Shield setting on.")

    local castBarDragonflightShield = CreateCheckbox("castBarDragonflightShield", "Dragonflight Shield on Non-Interruptable", enableCastbarCustomization)
    castBarDragonflightShield:SetPoint("TOPLEFT", showCastBarIconWhenNoninterruptible, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarDragonflightShield, "Replace the old pixelated non-interruptible\ncastbar shield with the new Dragonflight one")

    local castBarIconScale = CreateSlider(enableCastbarCustomization, "Castbar Icon Size", 0.1, 2.5, 0.1, "castBarIconScale")
    castBarIconScale:SetPoint("TOPLEFT", castBarDragonflightShield, "BOTTOMLEFT", 12, -10)

--[=[
    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconXPos", "X")
    castBarIconXPos:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y")
    castBarIconYPos:SetPoint("TOPLEFT", castBarIconXPos, "BOTTOMLEFT", 0, -15)

]=]


    local castBarHeight = CreateSlider(enableCastbarCustomization, "Castbar height", 4, 36, 0.1, "castBarHeight", "Height")
    castBarHeight:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castbarHeightResetButton = CreateFrame("Button", nil, enableCastbarCustomization, "UIPanelButtonTemplate")
    castbarHeightResetButton:SetText("Default")
    castbarHeightResetButton:SetWidth(60)
    castbarHeightResetButton:SetPoint("LEFT", castBarHeight, "RIGHT", 10, 0)
    castbarHeightResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight(castBarHeight)
    end)

    local castBarTextScale = CreateSlider(enableCastbarCustomization, "Castbar text size", 0.5, 2.5, 0.1, "castBarTextScale")
    castBarTextScale:SetPoint("TOPLEFT", castBarHeight, "BOTTOMLEFT", 0, -15)

    local castBarRecolor = CreateCheckbox("castBarRecolor", "Re-color castbar", enableCastbarCustomization)
    castBarRecolor:SetPoint("TOPLEFT", castBarTextScale, "BOTTOMLEFT", -12, -3)

    local function UpdateColorSquare(icon, r, g, b)
        if r and g and b then
            icon:SetVertexColor(r, g, b)
        end
    end

    local function OpenColorPicker(colorType, icon)
        local r, g, b = unpack(BetterBlizzPlatesDB[colorType] or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }
        UpdateColorSquare(icon, r, g, b)

        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB[colorType] = { r, g, b }
            BBP.RefreshAllNameplates()
            UpdateColorSquare(icon, r, g, b)
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB[colorType] = { r, g, b }
            UpdateColorSquare(icon, r, g, b)
        end

        ColorPickerFrame:Show()
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

    local interruptedByIndicator = CreateCheckbox("interruptedByIndicator", "Show who interrupted", enableCastbarCustomization)
    interruptedByIndicator:SetPoint("TOPLEFT", castBarRecolor, "BOTTOMLEFT", 0, -23)
    CreateTooltip(interruptedByIndicator, "Show the name of who interrupted the cast\ninstead of just the standard \"Interrupted\" text.")

    local castBarRecolorInterrupt = CreateCheckbox("castBarRecolorInterrupt", "Interrupt CD color", enableCastbarCustomization)
    castBarRecolorInterrupt:SetPoint("TOPLEFT", interruptedByIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarRecolorInterrupt, "Checks if you have interrupt ready\nand color castbar thereafter.")

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText("Interrupt on CD")
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", 0, 3)
    castBarNoInterruptColor:SetSize(139, 20)
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
    castBarDelayedInterruptColor:SetText("Interrupt CD soon")
    castBarDelayedInterruptColor:SetPoint("TOPLEFT", castBarNoInterruptColor, "BOTTOMLEFT", 0, -5)
    castBarDelayedInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarDelayedInterruptColor, "Castbar color when interrupt is on CD but\nwill be ready before the cast ends")
    local castBarDelayedInterruptColorIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castBarDelayedInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarDelayedInterruptColorIcon:SetSize(18, 17)
    castBarDelayedInterruptColorIcon:SetPoint("LEFT", castBarDelayedInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarDelayedInterruptColorIcon, unpack(BetterBlizzPlatesDB["castBarDelayedInterruptColor"] or {1, 1, 1}))
    castBarDelayedInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarDelayedInterruptColor", castBarDelayedInterruptColorIcon)
    end)

    local castbarEmphasisSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarEmphasisSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -250, -340)
    castbarEmphasisSettingsText:SetText("Castbar emphasis settings")
    local castbarSettingsEmphasisIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsEmphasisIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsEmphasisIcon:SetSize(36, 36)
    castbarSettingsEmphasisIcon:SetVertexColor(1,0,0)
    castbarSettingsEmphasisIcon:SetPoint("RIGHT", castbarEmphasisSettingsText, "LEFT", 5, 0)

    local enableCastbarEmphasis = CreateCheckbox("enableCastbarEmphasis", "Cast Emphasis", enableCastbarCustomization)
    enableCastbarEmphasis:SetPoint("TOPLEFT", castbarEmphasisSettingsText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    enableCastbarEmphasis:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarEmphasis)
        if self:GetChecked() then
            listFrame:SetAlpha(1)
        else
            listFrame:SetAlpha(0.5)
        end
    end)
    CreateTooltip(enableCastbarEmphasis, "Customize castbar for spells in the list")

    local castBarEmphasisOnlyInterruptable = CreateCheckbox("castBarEmphasisOnlyInterruptable", "Interruptable cast only", enableCastbarEmphasis)
    castBarEmphasisOnlyInterruptable:SetPoint("TOPLEFT", enableCastbarEmphasis, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(castBarEmphasisOnlyInterruptable, "Only apply emphasis settings if the cast is interruptable")

    local castBarEmphasisColor = CreateCheckbox("castBarEmphasisColor", "Color castbar", enableCastbarEmphasis)
    castBarEmphasisColor:SetPoint("TOPLEFT", castBarEmphasisOnlyInterruptable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisHealthbarColor = CreateCheckbox("castBarEmphasisHealthbarColor", "Color healthbar", enableCastbarEmphasis)
    castBarEmphasisHealthbarColor:SetPoint("TOPLEFT", castBarEmphasisColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

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

    local castBarEmphasisSparkHeight = CreateSlider(enableCastbarEmphasis, "Emphasis Spark Size", 25, 60, 1, "castBarEmphasisTextScale", "Height")
    castBarEmphasisSparkHeight:SetPoint("LEFT", castBarEmphasisSpark, "RIGHT", 50, -1)

    enableCastbarCustomization:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarCustomization)
        if self:GetChecked() then
            if BetterBlizzPlatesDB.enableCastbarEmphasis then
                listFrame:SetAlpha(1)
            end
            if BetterBlizzPlatesDB.castBarRecolor then
                castBarCastColorIcon:SetAlpha(1)
                castBarChanneledColorIcon:SetAlpha(1)
            else
                castBarCastColorIcon:SetAlpha(0)
                castBarChanneledColorIcon:SetAlpha(0)
            end
            if BetterBlizzPlatesDB.castBarRecolorInterrupt then
                castBarNoInterruptColorIcon:SetAlpha(1)
                castBarDelayedInterruptColorIcon:SetAlpha(1)
            else
                castBarNoInterruptColorIcon:SetAlpha(0)
                castBarDelayedInterruptColorIcon:SetAlpha(0)
            end
        else
            listFrame:SetAlpha(0.5)
            castBarCastColorIcon:SetAlpha(0)
            castBarChanneledColorIcon:SetAlpha(0)
            castBarNoInterruptColorIcon:SetAlpha(0)
            castBarDelayedInterruptColorIcon:SetAlpha(0)
        end
    end)

    castBarRecolor:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(castBarRecolor)
        if self:GetChecked() then
            castBarCastColorIcon:SetAlpha(1)
            castBarChanneledColorIcon:SetAlpha(1)
        else
            castBarCastColorIcon:SetAlpha(0)
            castBarChanneledColorIcon:SetAlpha(0)
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
            else
                castBarCastColor:Disable()
                castBarChanneledColor:Disable()
                castBarCastColorIcon:SetAlpha(0)
                castBarChanneledColorIcon:SetAlpha(0)
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
    InterfaceOptions_AddCategory(guiHideCastbar)

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

    local hideCastbar = CreateCheckbox("hideCastbar", "Enable Hide Castbar", guiHideCastbar, nil, BBP.HideCastbar)
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

    local hideCastbarWhitelist = CreateCheckbox("hideCastbarWhitelistOn", "Whitelist mode", guiHideCastbar, nil, BBP.HideCastbar)
    hideCastbarWhitelist:SetPoint("TOPLEFT", hideCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCastbarWhitelist, "Hide castbar for ALL spells except the ones in the whitelist")

    local showCastbarIfTarget = CreateCheckbox("showCastbarIfTarget", "Always show castbar on target", guiHideCastbar, nil, BBP.HideCastbar)
    showCastbarIfTarget:SetPoint("TOPLEFT", hideCastbarWhitelist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local onlyShowInterruptableCasts = CreateCheckbox("onlyShowInterruptableCasts", "Only show interruptable casts", guiHideCastbar, nil, BBP.HideCastbar)
    onlyShowInterruptableCasts:SetPoint("TOPLEFT", showCastbarIfTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideNpcCastbar = CreateCheckbox("hideNpcCastbar", "Hide all NPC castbars", guiHideCastbar, nil, BBP.HideCastbar)
    hideNpcCastbar:SetPoint("TOPLEFT", onlyShowInterruptableCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideNpcCastbar, "Hide all NPC castbars (except whitelisted ones).")

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

    local function handleVisibility2()
        if BetterBlizzPlatesDB.hideCastbar then
            listFrame:SetAlpha(1)
            hideCastbarWhitelist:SetAlpha(1)
            hideCastbarWhitelist:Enable()
            showCastbarIfTarget:SetAlpha(1)
            showCastbarIfTarget:Enable()
            onlyShowInterruptableCasts:SetAlpha(1)
            onlyShowInterruptableCasts:Enable()
            hideNpcCastbar:SetAlpha(1)
            hideNpcCastbar:Enable()
        else
            listFrame:SetAlpha(0.5)
            hideCastbarWhitelist:SetAlpha(0.5)
            hideCastbarWhitelist:Disable()
            showCastbarIfTarget:SetAlpha(0.5)
            showCastbarIfTarget:Disable()
            onlyShowInterruptableCasts:SetAlpha(0.5)
            onlyShowInterruptableCasts:Disable()
            hideNpcCastbar:SetAlpha(0.5)
            hideNpcCastbar:Disable()
        end
    end
    hideCastbar:HookScript("OnClick", function(_, btn, down)
        handleVisibility2()
    end)
    handleVisibility2()
end

local function guiFadeNPC()
    ---------------------
    -- Fade out NPC
    ---------------------
    local guiFadeNpc = CreateFrame("Frame")
    guiFadeNpc.name = "Fade NPC"
    guiFadeNpc.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(guiFadeNpc)

    local bgImg = guiFadeNpc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiFadeNpc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiFadeNpc)
    listFrame:SetAllPoints(guiFadeNpc)
    CreateList(listFrame, "fadeOutNPCsList", BetterBlizzPlatesDB.fadeOutNPCsList, BBP.RefreshAllNameplates, false)

    local how2usefade = guiFadeNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usefade:SetPoint("TOP", guiFadeNpc, "BOTTOMLEFT", 180, 155)
    how2usefade:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    local fadeOutNPCsAlpha = CreateSlider(guiFadeNpc, "Alpha value", 0, 1, 0.05, "fadeOutNPCsAlpha", "Alpha")
    fadeOutNPCsAlpha:SetPoint("TOPRIGHT", guiFadeNpc, "TOPRIGHT", -90, -90)

    -- made an oopsie here after changing some stuff TODO: fix later

    -- Restore default entries
    --local restoreDefaultsButton = CreateFrame("Button", nil, guiFadeNpc, "UIPanelButtonTemplate")
    --restoreDefaultsButton:SetSize(150, 30)
    --restoreDefaultsButton:SetPoint("BOTTOM", fadeOutNPCsAlpha, "TOP", 0, 30)
    --restoreDefaultsButton:SetText("Restore Default Entries")
    --restoreDefaultsButton:SetScript("OnClick", function()
    --    local defaultFadeOutNPCsList = BBP.GetDefaultFadeOutNPCsList()
    --    for _, defaultNPC in ipairs(defaultFadeOutNPCsList) do
    --        local isFound = false
    --        for _, userNPC in ipairs(BetterBlizzPlatesDB.fadeOutNPCsList) do
    --            if defaultNPC.id == userNPC.id then
    --                isFound = true
    --                break
    --            end
    --        end
    --        if not isFound then
    --            addOrUpdateEntry(defaultNPC.id, defaultNPC.name, defaultNPC.comment)
    --        end
    --    end
    --end)

    local noteFade = guiFadeNpc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteFade:SetPoint("TOP", fadeOutNPCsAlpha, "BOTTOM", 0, -20)
    noteFade:SetText("This makes nameplates transparent.\n \nYou will still be able to click them\neven though you can't see them.")

    local fadeOutNPC = CreateCheckbox("fadeOutNPC", "Enable Fade NPC", guiFadeNpc, nil, BBP.FadeOutNPCs)
    fadeOutNPC:SetPoint("TOPLEFT", noteFade, "BOTTOMLEFT", 20, -15)

    local fadeAllButTarget = CreateCheckbox("fadeAllButTarget", "Fade All Except Target", fadeOutNPC, nil, BBP.FadeOutNPCs)
    fadeAllButTarget:SetPoint("TOPLEFT", fadeOutNPC, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(fadeAllButTarget, "Fade out all other nameplates when you have a target.\nDisregards the fade list")

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.fadeOutNPC then
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
    InterfaceOptions_AddCategory(guiHideNpc)

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
    hideNpcExplanationText:SetText("This hides nameplates.\n \nYou will still be able to click them\neven though you can't see them.")

    local hideNPC = CreateCheckbox("hideNPC", "Enable Hide NPC", guiHideNpc, nil, BBP.hideNPC)
    hideNPC:SetPoint("TOPLEFT", hideNpcExplanationText, "BOTTOMLEFT", 25, -15)
    CreateTooltip(hideNPC, "Hide NPC's from the blacklist\nOr only show the ones in whitelist with whitelist mode.")

    local listFrame = CreateFrame("Frame", nil, guiHideNpc)
    listFrame:SetAllPoints(guiHideNpc)

    local hideNPCListFrame = CreateFrame("Frame", nil, listFrame)
    hideNPCListFrame:SetSize(322, 390)
    hideNPCListFrame:SetPoint("TOPLEFT", 0, 0)

    local hideNPCWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    hideNPCWhitelistFrame:SetSize(322, 390)
    hideNPCWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = hideNPCWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", hideNPCWhitelistFrame, "TOP", 0, 0)
    whitelistOnText:SetText("Whitelist ON")

    CreateList(hideNPCListFrame, "hideNPCsList", BetterBlizzPlatesDB.hideNPCsList, BBP.RefreshAllNameplates, false)
    CreateList(hideNPCWhitelistFrame, "hideNPCsWhitelist", BetterBlizzPlatesDB.hideNPCsWhitelist, BBP.RefreshAllNameplates, false)

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

    local hideNPCArenaOnly = CreateCheckbox("hideNPCArenaOnly", "Only hide NPCs in arena", hideNPC)
    hideNPCArenaOnly:SetPoint("TOPLEFT", hideNPCWhitelistOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideNPCPetsOnly = CreateCheckbox("hideNPCPetsOnly", "Hide Player Pets", hideNPC)
    hideNPCPetsOnly:SetPoint("TOPLEFT", hideNPCArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideNPCPetsOnly, "Hide all player pets.")

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
    InterfaceOptions_AddCategory(guiColorNpc)

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
    InterfaceOptions_AddCategory(guiAuraColor)

    local bgImg = guiAuraColor:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiAuraColor, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local listFrame = CreateFrame("Frame", nil, guiAuraColor)
    listFrame:SetAllPoints(guiAuraColor)

    CreateList(listFrame, "auraColorList", BetterBlizzPlatesDB.auraColorList, BBP.RefreshAllNameplates, true, false, true, 390)

    local listExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listExplanationText:SetPoint("TOP", guiAuraColor, "BOTTOMLEFT", 180, 155)
    listExplanationText:SetText("Add name or spell ID. Case-insensitive.\n\nType a name or spell ID already in list to delete it")

    local auraColorExplanationText = guiAuraColor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    auraColorExplanationText:SetPoint("TOP", guiAuraColor, "TOP", 190, -127)
    auraColorExplanationText:SetText("Color nameplates\ndepending on their auras.\n \nAdd a name/spellID\nand select a color")

    local auraColor = CreateCheckbox("auraColor", "Enable Color by Aura", guiAuraColor, nil, BBP.CreateUnitAuraEventFrame)
    auraColor:SetPoint("TOPLEFT", auraColorExplanationText, "BOTTOMLEFT", 10, -15)
    CreateTooltip(auraColor, "Chose nameplate color depending on the aura on them")

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
    InterfaceOptions_AddCategory(guiNameplateAuras)

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
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, 390)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, -15)

    local auraBlacklistFrame = CreateFrame("Frame", nil, contentFrame)
    auraBlacklistFrame:SetSize(322, 390)
    auraBlacklistFrame:SetPoint("TOPLEFT", 6, -15)

    CreateList(auraBlacklistFrame, "auraBlacklist", BetterBlizzPlatesDB.auraBlacklist, BBP.RefreshAllNameplates)

    local blacklistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistText:SetPoint("BOTTOM", auraBlacklistFrame, "TOP", 10, 0)
    blacklistText:SetText("Blacklist")

    CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzPlatesDB.auraWhitelist, BBP.RefreshAllNameplates, nil, true)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", 10, 0)
    whitelistText:SetText("Whitelist")

    local enableNameplateAuraCustomisation = CreateCheckbox("enableNameplateAuraCustomisation", "Enable Aura Settings (BETA)", contentFrame)
    enableNameplateAuraCustomisation:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 75)
    enableNameplateAuraCustomisation:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.hideNameplateAuras = false
        end
    end)

    --------------------------
    -- Enemy Nameplates
    --------------------------
    -- Enemy Buffs
    local otherNpBuffEnable = CreateCheckbox("otherNpBuffEnable", "Show BUFFS", enableNameplateAuraCustomisation)
    otherNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 25)
    otherNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(otherNpBuffEnable)
    end)

    local bigEnemyBorderText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText:SetPoint("LEFT", otherNpBuffEnable, "CENTER", 0, 25)
    bigEnemyBorderText:SetText("Enemy Nameplates")
    local friendlyNameplatesIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    friendlyNameplatesIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplatesIcon:SetSize(28, 28)
    friendlyNameplatesIcon:SetPoint("RIGHT", bigEnemyBorderText, "LEFT", -3, 0)
    friendlyNameplatesIcon:SetDesaturated(1)
    friendlyNameplatesIcon:SetVertexColor(1, 0, 0)

    local otherNpBuffFilterAll = CreateCheckbox("otherNpBuffFilterAll", "All", otherNpBuffEnable)
    otherNpBuffFilterAll:SetPoint("TOPLEFT", otherNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local otherNpBuffFilterWatchList = CreateCheckbox("otherNpBuffFilterWatchList", "Whitelist", otherNpBuffEnable)
    CreateTooltip(otherNpBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    otherNpBuffFilterWatchList:SetPoint("TOPLEFT", otherNpBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffFilterLessMinite = CreateCheckbox("otherNpBuffFilterLessMinite", "Under one min", otherNpBuffEnable)
    otherNpBuffFilterLessMinite:SetPoint("TOPLEFT", otherNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffFilterPurgeable = CreateCheckbox("otherNpBuffFilterPurgeable", "Purgeable", otherNpBuffEnable)
    otherNpBuffFilterPurgeable:SetPoint("TOPLEFT", otherNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffPurgeGlow = CreateCheckbox("otherNpBuffPurgeGlow", "Glow on purgeable buffs", otherNpBuffEnable)
    otherNpBuffPurgeGlow:SetPoint("TOPLEFT", otherNpBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffBlueBorder = CreateCheckbox("otherNpBuffBlueBorder", "Blue border on buffs", otherNpBuffEnable)
    otherNpBuffBlueBorder:SetPoint("TOPLEFT", otherNpBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffEmphasisedBorder = CreateCheckbox("otherNpBuffEmphasisedBorder", "Red glow on whitelisted buffs", otherNpBuffEnable)
    otherNpBuffEmphasisedBorder:SetPoint("TOPLEFT", otherNpBuffBlueBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpBuffEmphasisedBorder, "Note: This is specifically for all whitelisted buffs,\nnot to be confused with pandemic glow\neven though they look the same.\nWill probably remove this setting soonTM idk")

    -- Enemy Debuffs
    local otherNpdeBuffEnable = CreateCheckbox("otherNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    otherNpdeBuffEnable:SetPoint("TOPLEFT", otherNpBuffEmphasisedBorder, "BOTTOMLEFT", -15, -2)
    otherNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(otherNpdeBuffEnable)
    end)

    local otherNpdeBuffFilterAll = CreateCheckbox("otherNpdeBuffFilterAll", "All", otherNpdeBuffEnable)
    otherNpdeBuffFilterAll:SetPoint("TOPLEFT", otherNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local otherNpdeBuffFilterBlizzard = CreateCheckbox("otherNpdeBuffFilterBlizzard", "Blizzard Default Filter", otherNpdeBuffEnable)
    otherNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", otherNpdeBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpdeBuffFilterWatchList = CreateCheckbox("otherNpdeBuffFilterWatchList", "Whitelist", otherNpdeBuffEnable)
    CreateTooltip(otherNpdeBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    otherNpdeBuffFilterWatchList:SetPoint("TOPLEFT", otherNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpdeBuffFilterLessMinite = CreateCheckbox("otherNpdeBuffFilterLessMinite", "Under one min", otherNpdeBuffEnable)
    otherNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", otherNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpdeBuffFilterOnlyMe = CreateCheckbox("otherNpdeBuffFilterOnlyMe", "Only mine", otherNpdeBuffEnable)
    otherNpdeBuffFilterOnlyMe:SetPoint("TOPLEFT", otherNpdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

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
    friendlyNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 300, 45)
    friendlyNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(friendlyNpBuffEnable)
    end)

    local friendlyNameplatesText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyNameplatesText:SetPoint("LEFT", friendlyNpBuffEnable, "CENTER", 0, 25)
    friendlyNameplatesText:SetText("Friendly Nameplates")
    local friendlyNameplatesIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    friendlyNameplatesIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplatesIcon:SetSize(28, 28)
    friendlyNameplatesIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNpBuffFilterAll = CreateCheckbox("friendlyNpBuffFilterAll", "All", friendlyNpBuffEnable)
    friendlyNpBuffFilterAll:SetPoint("TOPLEFT", friendlyNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local friendlyNpBuffFilterWatchList = CreateCheckbox("friendlyNpBuffFilterWatchList", "Whitelist", friendlyNpBuffEnable)
    CreateTooltip(friendlyNpBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    friendlyNpBuffFilterWatchList:SetPoint("TOPLEFT", friendlyNpBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyNpBuffFilterLessMinite = CreateCheckbox("friendlyNpBuffFilterLessMinite", "Under one min", friendlyNpBuffEnable)
    friendlyNpBuffFilterLessMinite:SetPoint("TOPLEFT", friendlyNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyNpBuffFilterOnlyMe = CreateCheckbox("friendlyNpBuffFilterOnlyMe", "Only mine", friendlyNpBuffEnable)
    friendlyNpBuffFilterOnlyMe:SetPoint("TOPLEFT", friendlyNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Friendly Debuffs
    local friendlyNpdeBuffEnable = CreateCheckbox("friendlyNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    friendlyNpdeBuffEnable:SetPoint("TOPLEFT", friendlyNpBuffFilterOnlyMe, "BOTTOMLEFT", -15, -2)
    friendlyNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(friendlyNpdeBuffEnable)
    end)

    local friendlyNpdeBuffFilterAll = CreateCheckbox("friendlyNpdeBuffFilterAll", "All", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterAll:SetPoint("TOPLEFT", friendlyNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local friendlyNpdeBuffFilterBlizzard = CreateCheckbox("friendlyNpdeBuffFilterBlizzard", "Blizzard Default Filter", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", friendlyNpdeBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyNpdeBuffFilterWatchList = CreateCheckbox("friendlyNpdeBuffFilterWatchList", "Whitelist", friendlyNpdeBuffEnable)
    CreateTooltip(friendlyNpdeBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    friendlyNpdeBuffFilterWatchList:SetPoint("TOPLEFT", friendlyNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local friendlyNpdeBuffFilterLessMinite = CreateCheckbox("friendlyNpdeBuffFilterLessMinite", "Under one min", friendlyNpdeBuffEnable)
    friendlyNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", friendlyNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    --------------------------
    -- Personal Bar
    --------------------------
    -- Personal Bar Buffs
    local personalNpBuffEnable = CreateCheckbox("personalNpBuffEnable", "Show BUFFS", enableNameplateAuraCustomisation)
    personalNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 525, 45)
    personalNpBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(personalNpBuffEnable)
    end)

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
    CreateTooltip(hideDefaultPersonalNameplateAuras, "Hide default personal BuffFrame.\nI don't use Personal Bar and didn't even\nrealize it had it's own BuffFrame\nWill maybe update rest of aura handling for it if demand.")


    local personalNpBuffFilterAll = CreateCheckbox("personalNpBuffFilterAll", "All", personalNpBuffEnable)
    personalNpBuffFilterAll:SetPoint("TOPLEFT", personalNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local personalNpBuffFilterBlizzard = CreateCheckbox("personalNpBuffFilterBlizzard", "Blizzard Default Filter", personalNpBuffEnable)
    personalNpBuffFilterBlizzard:SetPoint("TOPLEFT", personalNpBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local personalNpBuffFilterWatchList = CreateCheckbox("personalNpBuffFilterWatchList", "Whitelist", personalNpBuffEnable)
    CreateTooltip(personalNpBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    personalNpBuffFilterWatchList:SetPoint("TOPLEFT", personalNpBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local personalNpBuffFilterLessMinite = CreateCheckbox("personalNpBuffFilterLessMinite", "Under one min", personalNpBuffEnable)
    personalNpBuffFilterLessMinite:SetPoint("TOPLEFT", personalNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Personal Bar Debuffs
    local personalNpdeBuffEnable = CreateCheckbox("personalNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    personalNpdeBuffEnable:SetPoint("TOPLEFT", personalNpBuffFilterLessMinite, "BOTTOMLEFT", -15, -2)
    personalNpdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(personalNpdeBuffEnable)
    end)

    local personalNpdeBuffFilterAll = CreateCheckbox("personalNpdeBuffFilterAll", "All", personalNpdeBuffEnable)
    personalNpdeBuffFilterAll:SetPoint("TOPLEFT", personalNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local personalNpdeBuffFilterWatchList = CreateCheckbox("personalNpdeBuffFilterWatchList", "Whitelist", personalNpdeBuffEnable)
    CreateTooltip(personalNpdeBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    personalNpdeBuffFilterWatchList:SetPoint("TOPLEFT", personalNpdeBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local personalNpdeBuffFilterLessMinite = CreateCheckbox("personalNpdeBuffFilterLessMinite", "Under one min", personalNpdeBuffEnable)
    personalNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", personalNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    --------------------------
    -- Nameplate settings
    --------------------------
    local nameplateAurasXPos = CreateSlider(enableNameplateAuraCustomisation, "x offset", -50, 50, 1, "nameplateAurasXPos", "X")
    nameplateAurasXPos:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -240, -320)
    CreateTooltip(nameplateAurasXPos, "Aura x offset")

    local nameplateAurasYPos = CreateSlider(enableNameplateAuraCustomisation, "y offset", -50, 50, 1, "nameplateAurasYPos", "Y")
    nameplateAurasYPos:SetPoint("TOPLEFT", nameplateAurasXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasYPos, "Aura y offset when name is showing")

    local nameplateAurasNoNameYPos = CreateSlider(enableNameplateAuraCustomisation, "no name y offset", -50, 50, 1, "nameplateAurasNoNameYPos", "Y")
    nameplateAurasNoNameYPos:SetPoint("TOPLEFT", nameplateAurasYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasNoNameYPos, "Aura y offset when name is hidden\n(Unimportant non-targeted npcs etc)")

    local nameplateAuraScale = CreateSlider(enableNameplateAuraCustomisation, "Aura size", 0.7, 2, 0.01, "nameplateAuraScale")
    nameplateAuraScale:SetPoint("TOPLEFT", nameplateAurasNoNameYPos, "BOTTOMLEFT", 0, -17)

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
    nameplateAurasEnemyCenteredAnchor:SetPoint("BOTTOM", nameplateAurasXPos, "TOP", -30, 50)
    CreateTooltip(nameplateAurasEnemyCenteredAnchor, "Keep auras centered on enemy nameplates.")

    local nameplateAurasFriendlyCenteredAnchor = CreateCheckbox("nameplateAurasFriendlyCenteredAnchor", "Center Auras on Friendly", enableNameplateAuraCustomisation)
    nameplateAurasFriendlyCenteredAnchor:SetPoint("TOPLEFT", nameplateAurasEnemyCenteredAnchor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateAurasFriendlyCenteredAnchor, "Keep auras centered on friendly nameplates.")

    local nameplateCenterAllRows = CreateCheckbox("nameplateCenterAllRows", "Center every row", enableNameplateAuraCustomisation)
    nameplateCenterAllRows:SetPoint("TOP", nameplateAurasFriendlyCenteredAnchor, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateCenterAllRows, "Centers every new row on top of the previous row.\n \nBy default the first icon of a new row starts\non top of the first icon of the last row.")

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

    local showDefaultCooldownNumbersOnNpAuras = CreateCheckbox("showDefaultCooldownNumbersOnNpAuras", "Default CD", enableNameplateAuraCustomisation)
    showDefaultCooldownNumbersOnNpAuras:SetPoint("TOPLEFT", nameplateAuraSquare, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showDefaultCooldownNumbersOnNpAuras, "Show Blizz default cooldown counter.\n\nIf you use OmniCC this setting will not work.")

    local nameplateAuraTaller = CreateCheckbox("nameplateAuraTaller", "Taller Auras", enableNameplateAuraCustomisation)
    nameplateAuraTaller:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 5, 0)
    CreateTooltip(nameplateAuraTaller, "Bit taller aura icons and more of the texture visible.")
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

    local separateAuraBuffRow = CreateCheckbox("separateAuraBuffRow", "Separate Buff Row", enableNameplateAuraCustomisation)
    separateAuraBuffRow:SetPoint("TOPLEFT", nameplateAuraTaller, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(separateAuraBuffRow, "Show Buffs on a separate row on top of debuffs.", "ANCHOR_LEFT")

--[=[
    local AuraGrowLeft = CreateCheckbox("nameplateAurasGrowLeft", "Grow left", contentFrame)
    AuraGrowLeft:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 5, 0)
]=]

    local maxAurasOnNameplate = CreateSlider(enableNameplateAuraCustomisation, "Max auras on nameplate", 1, 24, 1, "maxAurasOnNameplate")
    maxAurasOnNameplate:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -10, -310)

    local nameplateAuraRowAmount = CreateSlider(enableNameplateAuraCustomisation, "Max auras per row", 2, 24, 1, "nameplateAuraRowAmount")
    nameplateAuraRowAmount:SetPoint("TOP", maxAurasOnNameplate,  "BOTTOM", 0, -15)

    local nameplateAuraWidthGap = CreateSlider(enableNameplateAuraCustomisation, "Horizontal gap between auras", 0, 18, 0.5, "nameplateAuraWidthGap")
    nameplateAuraWidthGap:SetPoint("TOP", nameplateAuraRowAmount,  "BOTTOM", 0, -15)

    local nameplateAuraHeightGap = CreateSlider(enableNameplateAuraCustomisation, "Vertical gap between auras", 0, 18, 0.5, "nameplateAuraHeightGap")
    nameplateAuraHeightGap:SetPoint("TOP", nameplateAuraWidthGap,  "BOTTOM", 0, -15)

    local defaultNpAuraCdSize = CreateSlider(showDefaultCooldownNumbersOnNpAuras, "Default CD Text Size", 0.1, 2, 0.01, "defaultNpAuraCdSize")
    defaultNpAuraCdSize:SetPoint("TOP", nameplateAuraHeightGap,  "BOTTOM", 0, -15)
    CreateTooltip(defaultNpAuraCdSize, "The text size of the default Blizz CD counter.\n\nIf you use OmniCC this setting will not work.")
    showDefaultCooldownNumbersOnNpAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            defaultNpAuraCdSize:Enable()
            defaultNpAuraCdSize:SetAlpha(1)
        else
            defaultNpAuraCdSize:Disable()
            defaultNpAuraCdSize:SetAlpha(0.5)
        end
    end)

    local imintoodeep = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    imintoodeep:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -50, -220)
    imintoodeep:SetText("will add more settings, very beta\nI'll clean this up soon Clueless.png")

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
                UIDropDownMenu_EnableDropDown(nameplateAuraDropdown)
                UIDropDownMenu_EnableDropDown(nameplateAuraRelativeDropdown)
            else
                UIDropDownMenu_DisableDropDown(nameplateAuraDropdown)
                UIDropDownMenu_DisableDropDown(nameplateAuraRelativeDropdown)
            end
        else
            C_Timer.After(1, function()
                --TogglePanel()
            end)
        end
    end

    enableNameplateAuraCustomisation:HookScript("OnClick", function (self)
        StaticPopup_Show("BBP_CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(enableNameplateAuraCustomisation)
        --TogglePanel()
    end)
    --TogglePanel()

    local betaHighlightIcon = enableNameplateAuraCustomisation:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", enableNameplateAuraCustomisation, "LEFT", 8, 0)
end

local function guiBlizzCVars()
    --------------------------
    -- More Blizz Settings
    --------------------------
    local guiBlizzCVars = CreateFrame("Frame")
    guiBlizzCVars.name = "Blizzard CVar's"
    guiBlizzCVars.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(guiBlizzCVars)

    local bgImg = guiBlizzCVars:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiBlizzCVars, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local moreBlizzSettings = guiBlizzCVars:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettings:SetPoint("TOPLEFT", guiBlizzCVars, "TOPLEFT", 0, 0)
    moreBlizzSettings:SetText("Blizzard CVar settings not available in base UI")

    local stackingNameplatesText = guiBlizzCVars:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackingNameplatesText:SetPoint("TOPLEFT", guiBlizzCVars, "TOPLEFT", 13, -35)
    stackingNameplatesText:SetText("Stacking nameplate overlap amount")

    local nameplateMotion = CreateCheckbox("nameplateMotion", "Stacking nameplates", guiBlizzCVars, true)
    nameplateMotion:SetPoint("TOP", stackingNameplatesText, "BOTTOM", -65, -5)
    CreateTooltip(nameplateMotion, "Turn on stacking nameplates.\n\nI recommend using around 0.30 Vertical Overlap")

    local nameplateOverlapH = CreateSlider(guiBlizzCVars, "Horizontal Overlap", 0.05, 1, 0.01, "nameplateOverlapH")
    nameplateOverlapH:SetPoint("TOP", stackingNameplatesText, "BOTTOM", -15, -45)
    CreateTooltip(nameplateOverlapH, "Space between nameplates horizontally")
    CreateResetButton(nameplateOverlapH, "nameplateOverlapH", guiBlizzCVars)

    local nameplateOverlapV = CreateSlider(guiBlizzCVars, "Vertical Overlap", 0.05, 1.1, 0.01, "nameplateOverlapV")
    nameplateOverlapV:SetPoint("TOPLEFT", nameplateOverlapH, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateOverlapV, "Space between nameplates vertically")
    CreateResetButton(nameplateOverlapV, "nameplateOverlapV", guiBlizzCVars)

    local nameplateMotionSpeed = CreateSlider(guiBlizzCVars, "Nameplate Motion Speed", 0.01, 1, 0.01, "nameplateMotionSpeed")
    nameplateMotionSpeed:SetPoint("TOPLEFT", nameplateOverlapV, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateMotionSpeed, "The speed at which nameplates move into their new position")
    CreateResetButton(nameplateMotionSpeed, "nameplateMotionSpeed", guiBlizzCVars)

    local nameplateAlphaText = guiBlizzCVars:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateAlphaText:SetPoint("TOPLEFT", guiBlizzCVars, "TOPLEFT", 300, -35)
    nameplateAlphaText:SetText("Nameplate alpha settings")

    local nameplateMinAlpha = CreateSlider(guiBlizzCVars, "Min Alpha", 0, 1, 0.01, "nameplateMinAlpha")
    nameplateMinAlpha:SetPoint("TOP", nameplateAlphaText, "BOTTOM", 0, -20)
    CreateTooltip(nameplateMinAlpha, "The minimum alpha value of nameplates")
    CreateResetButton(nameplateMinAlpha, "nameplateMinAlpha", guiBlizzCVars)

    local nameplateMinAlphaDistance = CreateSlider(guiBlizzCVars, "Min Alpha Distance", 0, 60, 1, "nameplateMinAlphaDistance")
    nameplateMinAlphaDistance:SetPoint("TOPLEFT", nameplateMinAlpha, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateMinAlphaDistance, "The distance from the max distance\nthat nameplates will reach their minimum alpha.")
    CreateResetButton(nameplateMinAlphaDistance, "nameplateMinAlphaDistance", guiBlizzCVars)

    local nameplateMaxAlpha = CreateSlider(guiBlizzCVars, "Max Alpha", 0, 1, 0.01, "nameplateMaxAlpha")
    nameplateMaxAlpha:SetPoint("TOP", nameplateMinAlphaDistance, "BOTTOM", 0, -20)
    CreateTooltip(nameplateMaxAlpha, "The maximum alpha value of nameplates")
    CreateResetButton(nameplateMaxAlpha, "nameplateMaxAlpha", guiBlizzCVars)

    local nameplateMaxAlphaDistance = CreateSlider(guiBlizzCVars, "Max Alpha Distance", 0, 60, 1, "nameplateMaxAlphaDistance")
    nameplateMaxAlphaDistance:SetPoint("TOPLEFT", nameplateMaxAlpha, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateMaxAlphaDistance, "The distance from the camera that\nnameplates will reach their maximum alpha.\n\nNote: Yes, it is from the camera POV, and not player unfortunately.")
    CreateResetButton(nameplateMaxAlphaDistance, "nameplateMaxAlphaDistance", guiBlizzCVars)

    local nameplateOccludedAlphaMult = CreateSlider(guiBlizzCVars, "Occluded Alpha", 0, 1, 0.01, "nameplateOccludedAlphaMult")
    nameplateOccludedAlphaMult:SetPoint("TOPLEFT", nameplateMaxAlphaDistance, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateOccludedAlphaMult, "The alpha value on nameplates that\nare behind cover like pillars etc.")
    CreateResetButton(nameplateOccludedAlphaMult, "nameplateOccludedAlphaMult", guiBlizzCVars)

    local nameplateCVarText = guiBlizzCVars:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateCVarText:SetPoint("TOPLEFT", guiBlizzCVars, "TOPLEFT", 350, -270)
    nameplateCVarText:SetText("Nameplate Visibility CVars")

    local setCVarAcrossAllCharacters = CreateCheckbox("setCVarAcrossAllCharacters", "Force these CVars across all characters", guiBlizzCVars)
    setCVarAcrossAllCharacters:SetPoint("TOP", nameplateCVarText, "BOTTOM", -100, 0)
    CreateTooltip(setCVarAcrossAllCharacters, "(By default you have to set them on each character separately.)")

    local nameplateShowEnemyGuardians = CreateCheckbox("nameplateShowEnemyGuardians", "Show Enemy Guardians", guiBlizzCVars, true)
    nameplateShowEnemyGuardians:SetPoint("TOP", nameplateCVarText, "BOTTOM", -135, -20)
    CreateTooltip(nameplateShowEnemyGuardians, "Show Enemy Guardian Nameplates.\n\n\"Guardians\" are usually \"semi controllable\"\nlarger summoned pets, like Earth Elemental/Infernal.")

    local nameplateShowEnemyMinions = CreateCheckbox("nameplateShowEnemyMinions", "Show Enemy Minions", guiBlizzCVars, true)
    nameplateShowEnemyMinions:SetPoint("TOP", nameplateShowEnemyGuardians, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowEnemyMinions, "Show Enemy Minion Nameplates.\n\n\"Minions\" are usually uncontrollable\nsmaller summoned pets, like Psyfiend/Mindflayer.")

    local nameplateShowEnemyMinus = CreateCheckbox("nameplateShowEnemyMinus", "Show Enemy Minus", guiBlizzCVars, true)
    nameplateShowEnemyMinus:SetPoint("TOP", nameplateShowEnemyMinions, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowEnemyMinus, "Show Enemy Minus Nameplates.\n\n\"Minus\" are usually uncontrollable very small\nsummoned pets with little hp, like Warlock Imps.")

    local nameplateShowEnemyPets = CreateCheckbox("nameplateShowEnemyPets", "Show Enemy Pets", guiBlizzCVars, true)
    nameplateShowEnemyPets:SetPoint("TOP", nameplateShowEnemyMinus, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowEnemyPets, "Show Enemy Pets Nameplates.\n\n\"Pets\" are the main controllable pets,\nlike Hunter Pet, Warlock Pet etc.")

    local nameplateShowEnemyTotems = CreateCheckbox("nameplateShowEnemyTotems", "Show Enemy Totems", guiBlizzCVars, true)
    nameplateShowEnemyTotems:SetPoint("TOP", nameplateShowEnemyPets, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowEnemyTotems, "Show Enemy Totem Nameplates.\n\n\"Totems\" are totems, like totems :)")

    local nameplateShowFriendlyGuardians = CreateCheckbox("nameplateShowFriendlyGuardians", "Show Friendly Guardians", guiBlizzCVars, true)
    nameplateShowFriendlyGuardians:SetPoint("TOP", nameplateCVarText, "BOTTOM", 35, -20)
    CreateTooltip(nameplateShowFriendlyGuardians, "Show Friendly Guardian Nameplates.\n\n\"Guardians\" are usually \"semi controllable\"\nlarger summoned pets, like Earth Elemental/Infernal.")

    local nameplateShowFriendlyMinions = CreateCheckbox("nameplateShowFriendlyMinions", "Show Friendly Minions", guiBlizzCVars, true)
    nameplateShowFriendlyMinions:SetPoint("TOP", nameplateShowFriendlyGuardians, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowFriendlyMinions, "Show Friendly Minion Nameplates.\n\n\"Minions\" are usually uncontrollable\nsmaller summoned pets, like Psyfiend/Mindflayer.")

    local nameplateShowFriendlyPets = CreateCheckbox("nameplateShowFriendlyPets", "Show Friendly Pets", guiBlizzCVars, true)
    nameplateShowFriendlyPets:SetPoint("TOP", nameplateShowFriendlyMinions, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowFriendlyPets, "Show Friendly Pets Nameplates.\n\n\"Pets\" are the main controllable pets,\nlike Hunter Pet, Warlock Pet etc.")

    local nameplateShowFriendlyTotems = CreateCheckbox("nameplateShowFriendlyTotems", "Show Friendly Totems", guiBlizzCVars, true)
    nameplateShowFriendlyTotems:SetPoint("TOP", nameplateShowFriendlyPets, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateShowFriendlyTotems, "Show Friendly Totem Nameplates.\n\n\"Totems\" are totems, like totems :)")

    local moreBlizzSettingsText = guiBlizzCVars:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettingsText:SetPoint("BOTTOM", guiBlizzCVars, "BOTTOM", 0, 10)
    moreBlizzSettingsText:SetText("Work in progress, more stuff inc soon™\n \nSome settings don't make much sense anymore because\nthe addon grew a bit more than I thought it would.\nWill clean up eventually\n \nIf you have any suggestions feel free to\nleave a comment on CurseForge")
end

local function guiTotemList()
    -----------------------
    -- Hide NPC
    -----------------------
    local guiTotemList = CreateFrame("Frame")
    guiTotemList.name = "Totem Indicator List"
    guiTotemList.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(guiTotemList)

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

    CreateNpcList(totemListFrame, BetterBlizzPlatesDB.totemIndicatorNpcList, BBP.RefreshAllNameplates, 630, 560)
end

local function guiMisc()
    local guiMisc = CreateFrame("Frame")
    guiMisc.name = "Misc"
    guiMisc.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(guiMisc)

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

    local showGuildNames = CreateCheckbox("showGuildNames", "Show Guild Names on Friendly Nameplates*", guiMisc)
    showGuildNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(showGuildNames, "*Only works when \"Hide healthbar\" setting on friendly nameplates is on.\n\n(Will add some extra settings for this soon,\ndisable in arena/bg etc,\nplease shoot me a message if you have other suggestions too)")

    local guildNameScale = CreateSlider(guiMisc, "Guild Name Size", 0.2, 2, 0.01, "guildNameScale")
    guildNameScale:SetPoint("LEFT", showGuildNames.Text, "RIGHT", 5, 0)

    local guildNameColor = CreateCheckbox("guildNameColor", "Custom Guild Name Color", guiMisc)
    guildNameColor:SetPoint("TOPLEFT", showGuildNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(guildNameColor, "Change guild name color to a custom one instead of class colors.")

    local function OpenColorPicker()
        local r, g, b = unpack(BetterBlizzPlatesDB.guildNameColorRGB or {1, 1, 1})
        ColorPickerFrame.previousValues = { r, g, b }
        ColorPickerFrame.func = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzPlatesDB.guildNameColorRGB = { r, g, b }
            BBP.RefreshAllNameplates()
        end

        ColorPickerFrame.cancelFunc = function()
            r, g, b = unpack(ColorPickerFrame.previousValues)
            BetterBlizzPlatesDB.guildNameColorRGB = { r, g, b }
        end
        ColorPickerFrame:Show()
    end

    local guildNameColorButton = CreateFrame("Button", nil, guiMisc, "UIPanelButtonTemplate")
    guildNameColorButton:SetText("Color")
    guildNameColorButton:SetPoint("LEFT", guildNameColor.text, "RIGHT", -1, 0)
    guildNameColorButton:SetSize(45, 20)
    guildNameColorButton:SetScript("OnClick", OpenColorPicker)


    --
    local nameplateResourceText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplateResourceText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 45, -250)
    nameplateResourceText:SetText("Nameplate Resource")

    local nameplateResourceScale = CreateSlider(guiMisc, "Resource Scale", 0.2, 1.7, 0.01, "nameplateResourceScale")
    nameplateResourceScale:SetPoint("TOP", nameplateResourceText, "BOTTOM", 0, -20)
    CreateTooltip(nameplateResourceScale, "Resource Scale (Combo points, warlock shards etc.)")
    CreateResetButton(nameplateResourceScale, "nameplateResourceScale", guiMisc)


    local nameplateSelfWidth = CreateSlider(guiMisc, "Personal Nameplate Width", 50, 200, 1, "nameplateSelfWidth")
    nameplateSelfWidth:SetPoint("TOP", nameplateResourceText, "BOTTOM", 0, -60)

    local nameplateSelfWidthResetButton = CreateFrame("Button", nil, guiMisc, "UIPanelButtonTemplate")
    nameplateSelfWidthResetButton:SetText("Default")
    nameplateSelfWidthResetButton:SetWidth(60)
    nameplateSelfWidthResetButton:SetPoint("LEFT", nameplateSelfWidth, "RIGHT", 10, 0)
    nameplateSelfWidthResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultWidth(nameplateSelfWidth, false)
    end)
end
------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
function BBP.InitializeOptions()
    if not BetterBlizzPlates then
        BetterBlizzPlates = CreateFrame("Frame")
        BetterBlizzPlates.name = "BetterBlizzPlates"
        InterfaceOptions_AddCategory(BetterBlizzPlates)

        guiGeneralTab()
        guiPositionAndScale()
        guiCastbar()
        guiHideCastbar()
        guiFadeNPC()
        guiHideNPC()
        guiColorNPC()
        guiAuraColor()
        guiNameplateAuras()
        guiBlizzCVars()
        guiMisc()
        guiTotemList()
    end
end