BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}
local LSM = LibStub("LibSharedMedia-3.0")

BetterBlizzPlates = nil
local anchorPoints = {"CENTER", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local targetIndicatorAnchorPoints = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local pixelsBetweenBoxes = 5
local pixelsOnFirstBox = -1

local tooltips = {
    ["5: Replace name with ID + spec"] = "Shows as for example \"2 Frost\"",
    ["Off"] = "Turn the functionaly off and just use normal names",
}

local modes = {
    ["1: Replace name with Arena ID"] = "arenaIndicatorModeOne",
    ["2: Arena ID on top of name"] = "arenaIndicatorModeTwo",
    ["3: Replace name with spec"] = "arenaIndicatorModeThree",
    ["4: Replace name with spec + ID on top"] = "arenaIndicatorModeFour",
    ["5: Replace name with ID + spec"] = "arenaIndicatorModeFive",
    ["Off"] = "arenaIndicatorModeOff",
}

local tooltipsParty = {
    ["5: Replace name with ID + spec"] = "Shows as for example \"2 Frost\"",
    ["Off"] = "Turn the functionaly off and just use normal names",
}

local modesParty = {
    ["1: Replace name with Arena ID"] = "partyIndicatorModeOne",
    ["2: Arena ID on top of name"] = "partyIndicatorModeTwo",
    ["3: Replace name with spec"] = "partyIndicatorModeThree",
    ["4: Replace name with spec + ID on top"] = "partyIndicatorModeFour",
    ["5: Replace name with ID + spec"] = "partyIndicatorModeFive",
    ["Off"] = "partyIndicatorModeOff",
}
StaticPopupDialogs["CONFIRM_RELOAD"] = {
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

local function CreateModeDropdown(name, parent, defaultText, settingKey, toggleFunc, point, modes, tooltips, textLabel, textColor)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 135)
    UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    -- Get the FontString object representing the text and set its color
    local dropdownTextFontString = _G[dropdown:GetName() .. "Text"]
    if dropdownTextFontString then
        dropdownTextFontString:SetTextColor(1, 1, 0) -- Set text color to yellow
    end

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local orderedKeys = {}

        for displayText, _ in pairs(modes) do
            table.insert(orderedKeys, displayText)
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

                UIDropDownMenu_SetText(dropdown, displayText)
                toggleFunc(displayText)
            end
            info.checked = (BetterBlizzPlatesDB[settingKey] == displayText)

            -- Color dropdown text
            info.colorCode = "|cFFFFFF00"

            -- Setting tooltip for specific menu items
            if tooltips[displayText] then
                info.tooltipTitle = displayText
                info.tooltipText = tooltips[displayText]
                info.tooltipOnButton = 1
            else
                info.tooltipTitle = nil
                info.tooltipText = nil
                info.tooltipOnButton = nil
            end

            UIDropDownMenu_AddButton(info)
        end
    end)

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
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 135) 
    UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local fonts = LSM:HashTable(LSM.MediaType.FONT)
        for fontName, fontPath in pairs(fonts) do
            info.text = fontName
            info.arg1 = fontName
            info.func = function(self, arg1)
                if BetterBlizzPlatesDB[settingKey] ~= arg1 then
                    BetterBlizzPlatesDB[settingKey] = arg1
                    UIDropDownMenu_SetText(dropdown, arg1)
                    toggleFunc(fontPath)
                    dropdown.Text:SetFont(fontPath, 12)
                end
            end
            info.checked = (BetterBlizzPlatesDB[settingKey] == fontName)

            UIDropDownMenu_AddButton(info)
        end
    end)

    local fontName = BetterBlizzPlatesDB.customFont
    local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
    dropdown.Text:SetFont(fontPath, 12)
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        UIDropDownMenu_DisableDropDown(dropdown)
    else
        UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateTextureDropdown(name, parent, defaultText, settingKey, toggleFunc, point, dropdownWidth)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, dropdownWidth or 135)
    UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local textures = LSM:HashTable(LSM.MediaType.STATUSBAR)
        for textureName, texturePath in pairs(textures) do
            info.text = textureName
            info.arg1 = textureName
            info.func = function(self, arg1)
                if BetterBlizzPlatesDB[settingKey] ~= arg1 then
                    BetterBlizzPlatesDB[settingKey] = arg1
                    UIDropDownMenu_SetText(dropdown, arg1)
                    toggleFunc(texturePath)
                end
            end
            info.checked = (BetterBlizzPlatesDB[settingKey] == textureName)

            -- Set the texture preview
            info.icon = texturePath
            info.iconInfo = { tCoordLeft = 0, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 1, tSizeX = 50, tSizeY = 50 }

            UIDropDownMenu_AddButton(info)
        end
    end)

    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        UIDropDownMenu_DisableDropDown(dropdown)
    else
        UIDropDownMenu_EnableDropDown(dropdown)
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

    local function SetSliderValue()
        if BBP.variablesLoaded and BBP.CVarsAreSaved() then
            local initialValue = BetterBlizzPlatesDB[element]
            slider:SetValue(BetterBlizzPlatesDB[element])

            local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
            slider.Text:SetText(label .. ": " .. textValue)
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
                                BBP.CreateTotemComponents(frame)
                            end
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
                        -- Cast Timer Pos and Scale
                        elseif element == "castTimer" then
                            --not rdy
                        -- Cast bar icon pos and scale
                        elseif element == "castBarIconXPos" or element == "castBarIconYPos" or element == "castBarIconScale" then
                            if axis then
                                local yOffset = BetterBlizzPlatesDB.castBarDragonflightShield and -2 or 0
                                frame.castBar.Icon:ClearAllPoints()
                                frame.castBar.Icon:SetPoint("CENTER", frame.castBar, anchorPoint, xPos, yPos)
                                frame.castBar.BorderShield:ClearAllPoints()
                                frame.castBar.BorderShield:SetPoint("CENTER", frame.castBar, BetterBlizzPlatesDB.castBarIconAnchor, xPos, yPos + yOffset)
                            else
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
                elseif element == "executeIndicatorThreshold" then
                    BetterBlizzPlatesDB.executeIndicatorThreshold = value
                elseif element == "castBarHeight" then
                    BetterBlizzPlatesDB.castBarHeight = value
                elseif element == "castBarTextScale" then
                    BetterBlizzPlatesDB.castBarTextScale = value
                elseif element == "castBarEmphasisSparkHeight" then
                    BetterBlizzPlatesDB.castBarEmphasisSparkHeight = value
                elseif element == "castBarEmphasisIconScale" then
                    BetterBlizzPlatesDB.castBarEmphasisIconScale = value
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

local function CreateTooltip(widget, tooltipText)
    widget:SetScript("OnEnter", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText)

        GameTooltip:Show()
    end)

    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 125)
    UIDropDownMenu_SetText(dropdown, BetterBlizzPlatesDB[settingKey] or defaultText)
    local anchorPointsToUse = anchorPoints
    if name == "targetIndicatorDropdown" then
        anchorPointsToUse = targetIndicatorAnchorPoints
    end
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, anchor in ipairs(anchorPointsToUse) do
            info.text = anchor
            info.arg1 = anchor
            info.func = function(self, arg1)
                if BetterBlizzPlatesDB[settingKey] ~= arg1 then
                    BetterBlizzPlatesDB[settingKey] = arg1
                    UIDropDownMenu_SetText(dropdown, arg1)
                    toggleFunc(arg1)
                    BBP.RefreshAllNameplates()
                end
            end
            info.checked = (BetterBlizzPlatesDB[settingKey] == anchor)
            UIDropDownMenu_AddButton(info)
        end
    end)

    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    local dropdownText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownText:SetPoint("BOTTOM", dropdown, "TOP", 0, 3)
    dropdownText:SetText(point.label)

    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        UIDropDownMenu_DisableDropDown(dropdown)
    else
        UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateCheckbox(option, label, parent, cvarName, extraFunc)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)

    local function UpdateOption(value)
        if option == 'friendlyNameplateClickthrough' and BBP.checkCombatAndWarn() then
            return
        end

        BetterBlizzPlatesDB[option] = value
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

    UpdateOption(BetterBlizzPlatesDB[option])

    checkBox:HookScript("OnClick", function(_, _, _)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
end

local function CreateList(subPanel, listName, listData, refreshFunc, enableColorPicker)
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(322, 390)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)

    -- Create the content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(322, 390)
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
                    StaticPopup_Show("DELETE_NPC_CONFIRM_" .. listName)
                end
            end)
        end

        selectedLineIndex = nil
        updateBackgroundColors()
        refreshFunc()
    end

    local function createTextLineButton(npc, index, enableColorPicker)
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize(310, 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg  -- Store the background texture for later color updates

        local displayText = npc.id and npc.id or ""
        if npc.name and npc.name ~= "" then
            displayText = displayText .. (displayText ~= "" and " - " or "") .. npc.name
        end
        if npc.comment and npc.comment ~= "" then
            displayText = displayText .. (displayText ~= "" and " - " or "") .. npc.comment
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", 5, 0)
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
                StaticPopup_Show("DELETE_NPC_CONFIRM_" .. listName)
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

                ColorPickerFrame:Show()
            end

            colorPickerButton:SetScript("OnClick", OpenColorPicker)
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
    StaticPopupDialogs["DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = "This name or npcID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopupDialogs["DELETE_NPC_CONFIRM_" .. listName] = {
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize(260, 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)

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
                StaticPopup_Show("DUPLICATE_NPC_CONFIRM_" .. listName)
            else
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
    addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 15)
    addonNameText:SetText("BetterBlizzPlates")
    local addonNameIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    addonNameIcon:SetAtlas("gmchat-icon-blizz")
    addonNameIcon:SetSize(22, 22)
    addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)

    ----------------------
    -- General:
    ----------------------
    -- "General:" text
    local settingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 5)
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

    local raidmarkIndicator = CreateCheckbox("raidmarkIndicator", "Change raidmarker position", BetterBlizzPlates, nil, BBP.ChangeRaidmarker)
    raidmarkIndicator:SetPoint("TOPLEFT", hideTargetHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local nameplateMaxScale = CreateSlider(BetterBlizzPlates, "Nameplate Size", 0.5, 2, 0.1, "nameplateMaxScale")
    nameplateMaxScale:SetPoint("TOPLEFT", raidmarkIndicator, "BOTTOMLEFT", 12, -10)

    local nameplateMaxScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateMaxScaleResetButton:SetText("Default")
    nameplateMaxScaleResetButton:SetWidth(60)
    nameplateMaxScaleResetButton:SetPoint("LEFT", nameplateMaxScale, "RIGHT", 10, 0)
    nameplateMaxScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateMaxScale, "nameplateScale")
    end)

    local nameplateSelectedScale = CreateSlider(BetterBlizzPlates, "Target Nameplate Size", 0.5, 3, 0.1, "nameplateSelectedScale")
    nameplateSelectedScale:SetPoint("TOPLEFT", nameplateMaxScale, "BOTTOMLEFT", 0, -17)

    local nameplateSelectedScaleResetButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    nameplateSelectedScaleResetButton:SetText("Default")
    nameplateSelectedScaleResetButton:SetWidth(60)
    nameplateSelectedScaleResetButton:SetPoint("LEFT", nameplateSelectedScale, "RIGHT", 10, 0)
    nameplateSelectedScaleResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateSelectedScale, "nameplateSelected")
    end)

    local NamePlateVerticalScale = CreateSlider(BetterBlizzPlates, "Nameplate Height", 0.5, 5, 0.1, "NamePlateVerticalScale")
    NamePlateVerticalScale:SetPoint("TOPLEFT", nameplateSelectedScale, "BOTTOMLEFT", 0, -17)
    CreateTooltip(NamePlateVerticalScale, "Changes the height of ALL nameplates.\nIn PvE content, due to Blizzard restrictions,\nit will also change the height of friendly castbars")

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
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -215)
    enemyNameplatesText:SetText("Enemy nameplates")
    local enemyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon:SetSize(28, 28)
    enemyNameplateIcon:SetPoint("RIGHT", enemyNameplatesText, "LEFT", -3, 0)
    enemyNameplateIcon:SetDesaturated(1)
    enemyNameplateIcon:SetVertexColor(1, 0, 0)

    local enemyClassColorName = CreateCheckbox("enemyClassColorName", "Class colored names", BetterBlizzPlates)
    enemyClassColorName:SetPoint("TOPLEFT", enemyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    local showNameplateCastbarTimer = CreateCheckbox("showNameplateCastbarTimer", "Cast timer next to castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateCastbarTimer:SetPoint("TOPLEFT", enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local showNameplateTargetText = CreateCheckbox("showNameplateTargetText", "Show target underneath castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    showNameplateTargetText:SetPoint("TOPLEFT", showNameplateCastbarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local enemyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 1.5, 0.01, "enemyNameScale")
    enemyNameScale:SetPoint("TOPLEFT", showNameplateTargetText, "BOTTOMLEFT", 12, -10)

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
    friendlyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -385)
    friendlyNameplatesText:SetText("Friendly nameplates")
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    local friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", "Clickthrough", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltip(friendlyNameplateClickthrough, "Make friendly nameplates clickthrough and make them overlap despite stacking nameplates setting.")

    local friendlyClassColorName = CreateCheckbox("friendlyClassColorName", "Class colored names", BetterBlizzPlates)
    friendlyClassColorName:SetPoint("TOPLEFT", friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local toggleFriendlyNameplatesInArena = CreateCheckbox("friendlyNameplatesOnlyInArena", "Toggle on/off for Arena auto", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesInArena)
    toggleFriendlyNameplatesInArena:SetPoint("TOPLEFT", friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(toggleFriendlyNameplatesInArena, "Turn on friendly nameplates when you enter arena and off again when you leave.")

    local friendlyNameScale = CreateSlider(BetterBlizzPlates, "Name Size", 0.5, 3, 0.1, "friendlyNameScale")
    friendlyNameScale:SetPoint("TOPLEFT", toggleFriendlyNameplatesInArena, "BOTTOMLEFT", 12, -10)

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
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 390, -230)
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
    absorbsIcon:SetPoint("RIGHT", absorbIndicator, "LEFT", 0, 0)

    local combatIndicator = CreateCheckbox("combatIndicator", "Combat indicator", BetterBlizzPlates, nil, BBP.ToggleCombatIndicator)
    combatIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
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
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -455)
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


    useCustomFont:HookScript("OnClick", function(self)
        if self:GetChecked() then
            UIDropDownMenu_EnableDropDown(fontDropdown)
        else
            UIDropDownMenu_DisableDropDown(fontDropdown)
        end
    end)

    useCustomTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            UIDropDownMenu_EnableDropDown(textureDropdown)
        else
            UIDropDownMenu_DisableDropDown(textureDropdown)
        end
    end)


    ----------------------
    -- Arena
    ----------------------
    local arenaSettingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaSettingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, 5)
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

    local arenaIndicatorTestMode = CreateCheckbox("arenaIndicatorTestMode", "Test", BetterBlizzPlates, BBP.RefreshAllNameplates)           
    arenaIndicatorTestMode:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)

    local arenaIDScale = CreateSlider(BetterBlizzPlates, "Arena ID Size", 1, 4, 0.1, "arenaIDScale")
    arenaIDScale:SetPoint("TOPLEFT", arenaModeDropdown, "BOTTOMLEFT", 20, -9)
    CreateTooltip(arenaIDScale, "Size of the arena ID text on top of nameplate during arena.")

    local arenaSpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.1, "arenaSpecScale")
    arenaSpecScale:SetPoint("TOPLEFT", arenaIDScale, "BOTTOMLEFT", 0, -11)
    CreateTooltip(arenaSpecScale, "Size of the spec name text on top of nameplate during arena.")

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

    local partyIDScale = CreateSlider(BetterBlizzPlates, "Party ID Size", 1, 4, 0.1, "partyIDScale")
    partyIDScale:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)

    local partySpecScale = CreateSlider(BetterBlizzPlates, "Spec Size", 0.5, 3, 0.1, "partySpecScale")
    partySpecScale:SetPoint("TOPLEFT", partyIDScale, "BOTTOMLEFT", 0, -11)

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

    local bodyProfileButton = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    bodyProfileButton:SetText("Body Profile")
    bodyProfileButton:SetWidth(100)
    bodyProfileButton:SetPoint("RIGHT", reloadUiButton, "LEFT", -10, 0)
    bodyProfileButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_BODY_PROFILE")
    end)

    StaticPopupDialogs["CONFIRM_BODY_PROFILE"] = {
        text = "This will change every setting to Body's Profile and reload UI. Are you sure you want to continue?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local db = BetterBlizzPlatesDB
            db.reopenOptions = true
            db.removeRealmNames = true
            db.hideNameplateAuras = true
            db.hideTargetHighlight = true
            db.fadeOutNPC = true
            db.raidmarkIndicator = true
            db.raidmarkIndicatorScale = 1.3
            db.enemyClassColorName = true
            db.showNameplateCastbarTimer = true
            db.showNameplateTargetText = true
            db.enemyNameScale = 0.9
            db.nameplateEnemyWidth = 144
            db.nameplateEnemyHeight = 64.125
            db.friendlyNameplateClickthrough = true
            db.friendlyClassColorName = true
            db.friendlyNameScale = 1.2
            db.arenaIDScale = 1.9
            db.arenaSpecScale = 1.1
            db.arenaIndicatorModeFour = true
            db.absorbIndicator = true
            db.combatIndicator = true
            db.combatIndicatorEnemyOnly = true
            db.combatIndicatorArenaOnly = true
            db.executeIndicator = true
            db.healerIndicator = true
            db.petIndicator = true
            db.targetIndicator = true
            db.totemIndicator = true
            db.useCustomFont = true
            db.useCustomTextureForBars = true
            db.nameplateFriendlyWidth = 60
            db.nameplateFriendlyHeight = 1
            db.arenaIndicatorModeFour = true
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
    anchorSubHeal:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY)
    anchorSubHeal:SetText("Healer Indicator")

    CreateBorderBox(anchorSubHeal)

    local healerCrossIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    healerCrossIcon2:SetAtlas("greencross")
    healerCrossIcon2:SetSize(32, 32)
    healerCrossIcon2:SetPoint("BOTTOM", anchorSubHeal, "TOP", 0, 0)
    healerCrossIcon2:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local healerIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.1, "healerIndicatorScale")
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

    ----------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorSubOutOfCombat:SetText("Combat Indicator")

    CreateBorderBox(anchorSubOutOfCombat)

    local combatIconSub = contentFrame:CreateTexture(nil, "ARTWORK")
    if BetterBlizzPlatesDB.combatIndicatorSap then
        combatIconSub:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
        combatIconSub:SetSize(38, 38)
        combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 0)
    else
        combatIconSub:SetAtlas("food")
        combatIconSub:SetSize(42, 42)
        combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", -1, 0)
    end

    local combatIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "combatIndicatorScale")
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
    anchorSubPet:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubPet:SetText("Pet Indicator")

    CreateBorderBox(anchorSubPet)

    local petIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    petIndicator2:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicator2:SetSize(38, 38)
    petIndicator2:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

    local petIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "petIndicatorScale")
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
    anchorSubAbsorb:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubAbsorb:SetText("Absorb Indicator")

    CreateBorderBox(anchorSubAbsorb)

    local absorbIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator2:SetAtlas("ParagonReputation_Glow")
    absorbIndicator2:SetSize(56, 56)
    absorbIndicator2:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

    local absorbIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "absorbIndicatorScale")
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
    anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY)
    anchorSubTotem:SetText("Totem Indicator")

    CreateBorderBox(anchorSubTotem)

    local totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    totemIcon2:SetAtlas("teleportationnetwork-ardenweald-32x32")
    totemIcon2:SetSize(34, 34)
    totemIcon2:SetPoint("BOTTOM", anchorSubTotem, "TOP", 0, 0)

    local totemIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 3, 0.1, "totemIndicatorScale")
    totemIndicatorScale:SetPoint("TOP", anchorSubTotem, "BOTTOM", 0, -15)

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

    local totemIndicatorHideNameAndShiftIconDown = CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", "Hide name", contentFrame)
    totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local totemIndicatorGlowOff = CreateCheckbox("totemIndicatorGlowOff", "No glow", contentFrame)
    totemIndicatorGlowOff:SetPoint("TOPLEFT", totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorGlowOff, "Turn off the glow around the icons on important nameplates.")

    local totemIndicatorScaleUpImportant = CreateCheckbox("totemIndicatorScaleUpImportant", "Scale up important", contentFrame)
    totemIndicatorScaleUpImportant:SetPoint("TOPLEFT", totemIndicatorGlowOff, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(totemIndicatorScaleUpImportant, "Scale up important nameplates slightly.")

    ----------------------
    -- Target indicator
    ----------------------
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, secondLineY)
    anchorSubTarget:SetText("Target Indicator")

    CreateBorderBox(anchorSubTarget)

    local targetIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    targetIndicator2:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicator2:SetRotation(math.rad(180))
    targetIndicator2:SetSize(48, 32)
    targetIndicator2:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

    local targetIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "targetIndicatorScale")
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
    anchorSubRaidmark:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, secondLineY)
    anchorSubRaidmark:SetText("Raidmarker")

    CreateBorderBox(anchorSubRaidmark)

    local raidmarkIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    raidmarkIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_3")
    raidmarkIcon:SetSize(38, 38)
    raidmarkIcon:SetPoint("BOTTOM", anchorSubRaidmark, "TOP", 0, 0)

    local raidmarkIndicatorScale = CreateSlider(contentFrame, "Size", 0.6, 2.5, 0.1, "raidmarkIndicatorScale")
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
    anchorSubquest:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, secondLineY)
    anchorSubquest:SetText("Quest Indicator")

    CreateBorderBox(anchorSubquest)

    local questIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    questIcon2:SetAtlas("smallquestbang")
    questIcon2:SetSize(44, 44)
    questIcon2:SetPoint("BOTTOM", anchorSubquest, "TOP", 0, 0)

    local questIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "questIndicatorScale")
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
    anchorSubFocus:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, thirdLineY)
    anchorSubFocus:SetText("Focus Target Indicator")

    CreateBorderBox(anchorSubFocus)

    local focusIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusIcon:SetAtlas("Waypoint-MapPin-Untracked")
    focusIcon:SetSize(44, 44)
    focusIcon:SetPoint("BOTTOM", anchorSubFocus, "TOP", 0, 0)

    local focusTargetIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 3, 0.1, "focusTargetIndicatorScale")
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
    anchorSubExecute:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubExecute:SetText("Execute Indicator")

    CreateBorderBox(anchorSubExecute)

    local executeIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    executeIcon:SetAtlas("islands-azeriteboss")
    executeIcon:SetSize(56, 60)
    executeIcon:SetPoint("BOTTOM", anchorSubExecute, "TOP", 0, -10)

    local executeIndicatorScale = CreateSlider(contentFrame, "Size", 0.5, 2.5, 0.05, "executeIndicatorScale")
    executeIndicatorScale:SetPoint("TOP", anchorSubExecute, "BOTTOM", 0, -15)

    local executeIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "executeIndicatorScale", "X")
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

    local executeIndicatorShowDecimal = CreateCheckbox("executeIndicatorShowDecimal", "Decimal", contentFrame)
    executeIndicatorShowDecimal:SetPoint("BOTTOMLEFT", executeIndicatorNotOnFullHp, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltip(executeIndicatorShowDecimal, "Show decimal")

    local executeIndicatorThreshold = CreateSlider(contentFrame, "Threshold", 5, 100, 1, "executeIndicatorThreshold", "Y")
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
    castbarSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -240, -20)
    castbarSettingsText:SetText("Castbar settings")
    local castbarSettingsIcon = guiCastbar:CreateTexture(nil, "ARTWORK")
    castbarSettingsIcon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarSettingsIcon:SetSize(24, 24)
    castbarSettingsIcon:SetPoint("RIGHT", castbarSettingsText, "LEFT", -3, 0)

    local enableCastbarCustomization = CreateCheckbox("enableCastbarCustomization", "Enable castbar customization", guiCastbar, nil, BBP.ToggleSpellCastEventRegistration)
    enableCastbarCustomization:SetPoint("TOPLEFT", castbarSettingsText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    local castBarDragonflightShield = CreateCheckbox("castBarDragonflightShield", "Dragonflight Shield on Non-Interruptable", enableCastbarCustomization)
    castBarDragonflightShield:SetPoint("TOPLEFT", enableCastbarCustomization, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarDragonflightShield, "Replace the old pixelated non-interruptible\ncastbar shield with the new Dragonflight one")

    local castBarIconScale = CreateSlider(enableCastbarCustomization, "Castbar Icon Size", 0.1, 2.5, 0.1, "castBarIconScale")
    castBarIconScale:SetPoint("TOPLEFT", castBarDragonflightShield, "BOTTOMLEFT", 12, -10)

    local castBarIconXPos = CreateSlider(enableCastbarCustomization, "Icon x offset", -50, 50, 1, "castBarIconScale", "X")
    castBarIconXPos:SetPoint("TOPLEFT", castBarIconScale, "BOTTOMLEFT", 0, -15)

    local castBarIconYPos = CreateSlider(enableCastbarCustomization, "Icon y offset", -50, 50, 1, "castBarIconYPos", "Y")
    castBarIconYPos:SetPoint("TOPLEFT", castBarIconXPos, "BOTTOMLEFT", 0, -15)

    local castBarHeight = CreateSlider(enableCastbarCustomization, "Castbar height", 4, 36, 0.1, "castBarHeight", "Height")
    castBarHeight:SetPoint("TOPLEFT", castBarIconYPos, "BOTTOMLEFT", 0, -15)

    local castbarHeightResetButton = CreateFrame("Button", nil, enableCastbarCustomization, "UIPanelButtonTemplate")
    castbarHeightResetButton:SetText("Default")
    castbarHeightResetButton:SetWidth(60)
    castbarHeightResetButton:SetPoint("LEFT", castBarHeight, "RIGHT", 10, 0)
    castbarHeightResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight(castBarHeight)
    end)

    local castBarTextScale = CreateSlider(enableCastbarCustomization, "Castbar text size", 0.5, 2.5, 0.1, "castBarTextScale")
    castBarTextScale:SetPoint("TOPLEFT", castBarHeight, "BOTTOMLEFT", 0, -15)

    local castbarEmphasisSettingsText = guiCastbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castbarEmphasisSettingsText:SetPoint("LEFT", guiCastbar, "TOPRIGHT", -240, -260)
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

    local castBarEmphasisOnlyInterruptable = CreateCheckbox("castBarEmphasisOnlyInterruptable", "Only emphasize interruptable casts", enableCastbarEmphasis)
    castBarEmphasisOnlyInterruptable:SetPoint("TOPLEFT", enableCastbarEmphasis, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local castBarEmphasisColor = CreateCheckbox("castBarEmphasisColor", "Cast Emphasis: Color castbar", enableCastbarEmphasis)
    castBarEmphasisColor:SetPoint("TOPLEFT", castBarEmphasisOnlyInterruptable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisHeight = CreateCheckbox("castBarEmphasisHeight", "Cast Emphasis: Height", enableCastbarEmphasis)
    castBarEmphasisHeight:SetPoint("TOPLEFT", castBarEmphasisColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisIcon = CreateCheckbox("castBarEmphasisIcon", "Cast Emphasis: Icon Size", enableCastbarEmphasis)
    castBarEmphasisIcon:SetPoint("TOPLEFT", castBarEmphasisHeight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisText = CreateCheckbox("castBarEmphasisText", "Cast Emphasis: Text Size", enableCastbarEmphasis)
    castBarEmphasisText:SetPoint("TOPLEFT", castBarEmphasisIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisSpark = CreateCheckbox("castBarEmphasisSpark", "Cast Emphasis: Spark", enableCastbarEmphasis)
    castBarEmphasisSpark:SetPoint("TOPLEFT", castBarEmphasisText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisHealthbarColor = CreateCheckbox("castBarEmphasisHealthbarColor", "Cast Emphasis: Color healthbar", enableCastbarEmphasis)
    castBarEmphasisHealthbarColor:SetPoint("TOPLEFT", castBarEmphasisSpark, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local castBarEmphasisHeightValue = CreateSlider(enableCastbarEmphasis, "Emphasis height", 4, 40, 0.1, "castBarEmphasisHeightValue", "Height")
    castBarEmphasisHeightValue:SetPoint("TOPLEFT", castBarEmphasisHealthbarColor, "BOTTOMLEFT", 10, -10)

    local castBarEmphasisIconScale = CreateSlider(enableCastbarEmphasis, "Emphasis Icon Size", 1, 3, 0.1, "castBarEmphasisIconScale")
    castBarEmphasisIconScale:SetPoint("TOPLEFT", castBarEmphasisHeightValue, "BOTTOMLEFT", 0, -15)

    local castBarEmphasisTextScale = CreateSlider(enableCastbarEmphasis, "Emphasis text size", 0.5, 2.5, 0.1, "castBarEmphasisTextScale")
    castBarEmphasisTextScale:SetPoint("TOPLEFT", castBarEmphasisIconScale, "BOTTOMLEFT", 0, -15)

    local castBarEmphasisSparkHeight = CreateSlider(enableCastbarEmphasis, "Emphasis Spark Size", 25, 60, 1, "castBarEmphasisTextScale", "Height")
    castBarEmphasisSparkHeight:SetPoint("TOPLEFT", castBarEmphasisTextScale, "BOTTOMLEFT", 0, -15)

    enableCastbarCustomization:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enableCastbarCustomization)
        if self:GetChecked() then
            if BetterBlizzPlatesDB.enableCastbarEmphasis then
                listFrame:SetAlpha(1)
            end
        else
            listFrame:SetAlpha(0.5)
        end
    end)

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.enableCastbarEmphasis then
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

    local hideNPCWhitelistOn = CreateCheckbox("hideNPCsWhitelistOn", "Whitelist mode", hideNPC, nil, BBP.hideNPC)
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

    local hideNPCArenaOnly = CreateCheckbox("hideNPCArenaOnly", "Only hide NPCs in arena", hideNPC, nil, BBP.hideNPC)
    hideNPCArenaOnly:SetPoint("TOPLEFT", hideNPCWhitelistOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local function TogglePanel()
        if BBP.variablesLoaded then
            if BetterBlizzPlatesDB.hideNPC then
                listFrame:SetAlpha(1)
                if BetterBlizzPlatesDB.hideNPCsWhitelistOn then
                    hideNPCListFrame:Hide()
                    hideNPCWhitelistFrame:Show()
                else
                    hideNPCListFrame:Show()
                    hideNPCWhitelistFrame:Hide()
                end
            else
                listFrame:SetAlpha(0.5)
                if BetterBlizzPlatesDB.hideNPCsWhitelistOn then
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

    CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzPlatesDB.auraWhitelist, BBP.RefreshAllNameplates)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", 10, 0)
    whitelistText:SetText("Whitelist")

    local enableNameplateAuraCustomisation = CreateCheckbox("enableNameplateAuraCustomisation", "Enable Aura Settings (BETA)", contentFrame)
    enableNameplateAuraCustomisation:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 75)

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

    local otherNpdeBuffPandemicGlow = CreateCheckbox("otherNpdeBuffPandemicGlow", "Pandemic Glow", otherNpdeBuffEnable)
    otherNpdeBuffPandemicGlow:SetPoint("TOPLEFT", otherNpdeBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(otherNpdeBuffPandemicGlow, "Red glow on whitelisted debuffs with less than 5 seconds left.")

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

    -- Friendly Debuffs
    local friendlyNpdeBuffEnable = CreateCheckbox("friendlyNpdeBuffEnable", "Show DEBUFFS", enableNameplateAuraCustomisation)
    friendlyNpdeBuffEnable:SetPoint("TOPLEFT", friendlyNpBuffFilterLessMinite, "BOTTOMLEFT", -15, -2)
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
    nameplateAurasXPos:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -240, -300)
    CreateTooltip(nameplateAurasXPos, "Aura x offset")

    local nameplateAurasYPos = CreateSlider(enableNameplateAuraCustomisation, "y offset", -50, 50, 1, "nameplateAurasYPos", "Y")
    nameplateAurasYPos:SetPoint("TOPLEFT", nameplateAurasXPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasYPos, "Aura y offset when name is showing")

    local nameplateAurasNoNameYPos = CreateSlider(enableNameplateAuraCustomisation, "no name y offset", -50, 50, 1, "nameplateAurasNoNameYPos")
    nameplateAurasNoNameYPos:SetPoint("TOPLEFT", nameplateAurasYPos, "BOTTOMLEFT", 0, -17)
    CreateTooltip(nameplateAurasNoNameYPos, "Aura y offset when name is hidden\n(Unimportant non-targeted npcs etc)")

    local nameplateAuraScale = CreateSlider(enableNameplateAuraCustomisation, "Aura size", 0.7, 2, 0.01, "nameplateAuraScale")
    nameplateAuraScale:SetPoint("TOPLEFT", nameplateAurasNoNameYPos, "BOTTOMLEFT", 0, -17)

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

    local nameplateAurasCenteredAnchor = CreateCheckbox("nameplateAurasCenteredAnchor", "Center Auras", enableNameplateAuraCustomisation)
    nameplateAurasCenteredAnchor:SetPoint("BOTTOM", nameplateAurasXPos, "TOP", -30, 30)
    CreateTooltip(nameplateAurasCenteredAnchor, "Center auras on their anchor.\nSets aura icons centered on top of nameplate by default.")

    local nameplateCenterAllRows = CreateCheckbox("nameplateCenterAllRows", "Center every row", enableNameplateAuraCustomisation)
    nameplateCenterAllRows:SetPoint("TOP", nameplateAurasCenteredAnchor, "BOTTOM", 0, pixelsBetweenBoxes)
    CreateTooltip(nameplateCenterAllRows, "Centers every new row on top of the previous row.\n \nBy default the first icon of a new row starts\non top of the first icon of the last row.")

    nameplateAurasCenteredAnchor:HookScript("OnClick", function (self)
        if self:GetChecked() then
            EnableElement(nameplateCenterAllRows)
            BetterBlizzPlatesDB.nameplateAuraAnchor = "BOTTOM"
            BetterBlizzPlatesDB.nameplateAuraRelativeAnchor = "TOP"
            UIDropDownMenu_SetText(nameplateAuraDropdown, "BOTTOM")
            UIDropDownMenu_SetText(nameplateAuraRelativeDropdown, "TOP")
            BBP.RefreshBuffFrame()
        else
            DisableElement(nameplateCenterAllRows)
            BetterBlizzPlatesDB.nameplateAuraAnchor = "BOTTOMLEFT"
            BetterBlizzPlatesDB.nameplateAuraRelativeAnchor = "TOPLEFT"
            UIDropDownMenu_SetText(nameplateAuraDropdown, "BOTTOMLEFT")
            UIDropDownMenu_SetText(nameplateAuraRelativeDropdown, "TOPLEFT")
            BBP.RefreshBuffFrame()
        end
    end)

    local nameplateAuraSquare = CreateCheckbox("nameplateAuraSquare", "Square Auras", enableNameplateAuraCustomisation)
    nameplateAuraSquare:SetPoint("LEFT", nameplateAurasCenteredAnchor.text, "RIGHT", 5, 0)
    nameplateAuraSquare:HookScript("OnClick", function (self)
        if not self:GetChecked() then
            StaticPopup_Show("CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(nameplateAuraSquare, "Square aura icons.\n \nRequires reload to turn back off")

--[=[
    local AuraGrowLeft = CreateCheckbox("nameplateAurasGrowLeft", "Grow left", contentFrame)
    AuraGrowLeft:SetPoint("LEFT", nameplateAuraSquare.text, "RIGHT", 5, 0)
]=]

    local maxAurasOnNameplate = CreateSlider(enableNameplateAuraCustomisation, "Max auras on nameplate", 1, 24, 1, "maxAurasOnNameplate")
    maxAurasOnNameplate:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -10, -280)

    local nameplateAuraRowAmount = CreateSlider(enableNameplateAuraCustomisation, "Max auras per row", 2, 24, 1, "nameplateAuraRowAmount")
    nameplateAuraRowAmount:SetPoint("TOP", maxAurasOnNameplate,  "BOTTOM", 0, -15)

    local nameplateAuraWidthGap = CreateSlider(enableNameplateAuraCustomisation, "Horizontal gap between auras", 0, 18, 1, "nameplateAuraWidthGap")
    nameplateAuraWidthGap:SetPoint("TOP", nameplateAuraRowAmount,  "BOTTOM", 0, -15)

    local nameplateAuraHeightGap = CreateSlider(enableNameplateAuraCustomisation, "Vertical gap between auras", 0, 18, 1, "nameplateAuraHeightGap")
    nameplateAuraHeightGap:SetPoint("TOP", nameplateAuraWidthGap,  "BOTTOM", 0, -15)

    local imintoodeep = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    imintoodeep:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -50, -220)
    imintoodeep:SetText("will add more settings, very beta\nwould love feedback if u notice anything weird")

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
                TogglePanel()
            end)
        end
    end

    enableNameplateAuraCustomisation:HookScript("OnClick", function (self)
        StaticPopup_Show("CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(enableNameplateAuraCustomisation)
        TogglePanel()
    end)
    TogglePanel()

    local betaHighlightIcon = enableNameplateAuraCustomisation:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", enableNameplateAuraCustomisation, "LEFT", 8, 0)
end

local function guiMoreBlizzSettings()
    --------------------------
    -- More Blizz Settings
    --------------------------
    local guiMoreBlizzSettings = CreateFrame("Frame")
    guiMoreBlizzSettings.name = "More Blizz Settings"
    guiMoreBlizzSettings.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(guiMoreBlizzSettings)

    local bgImg = guiMoreBlizzSettings:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiMoreBlizzSettings, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local moreBlizzSettings = guiMoreBlizzSettings:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettings:SetPoint("TOPLEFT", guiMoreBlizzSettings, "TOPLEFT", 0, 0)
    moreBlizzSettings:SetText("Settings not available in Blizzard's standard UI")

    local stackingNameplatesText = guiMoreBlizzSettings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackingNameplatesText:SetPoint("TOPLEFT", guiMoreBlizzSettings, "TOPLEFT", 13, -20)
    stackingNameplatesText:SetText("Stacking nameplate overlap amount")

    local nameplateOverlapH = CreateSlider(guiMoreBlizzSettings, "Horizontal overlap", 0.05, 1, 0.05, "nameplateOverlapH")
    nameplateOverlapH:SetPoint("TOP", stackingNameplatesText, "BOTTOM", -15, -20)
    CreateTooltip(nameplateOverlapH, "Space between nameplates horizontally")

    local nameplateOverlapHResetButton = CreateFrame("Button", nil, guiMoreBlizzSettings, "UIPanelButtonTemplate")
    nameplateOverlapHResetButton:SetText("Default")
    nameplateOverlapHResetButton:SetWidth(60)
    nameplateOverlapHResetButton:SetPoint("LEFT", nameplateOverlapH, "RIGHT", 10, 0)
    nameplateOverlapHResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(nameplateOverlapH, "nameplateOverlapH")
    end)

    local nameplateOverlapV = CreateSlider(guiMoreBlizzSettings, "Vertical overlap", 0.05, 1.1, 0.05, "nameplateOverlapV")
    nameplateOverlapV:SetPoint("TOPLEFT", nameplateOverlapH, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateOverlapV, "Space between nameplates vertically")

    local nameplateOverlapVResetButton = CreateFrame("Button", nil, guiMoreBlizzSettings, "UIPanelButtonTemplate")
    nameplateOverlapVResetButton:SetText("Default")
    nameplateOverlapVResetButton:SetWidth(60)
    nameplateOverlapVResetButton:SetPoint("LEFT", nameplateOverlapV, "RIGHT", 10, 0)
    nameplateOverlapVResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(nameplateOverlapV, "nameplateOverlapV")
    end)

    local nameplateMotionSpeed = CreateSlider(guiMoreBlizzSettings, "Nameplate motion speed", 0.01, 1, 0.01, "nameplateMotionSpeed")
    nameplateMotionSpeed:SetPoint("TOPLEFT", nameplateOverlapV, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateMotionSpeed, "The speed at which nameplates move into their new position")

    local nameplateMotionSpeedResetButton = CreateFrame("Button", nil, guiMoreBlizzSettings, "UIPanelButtonTemplate")
    nameplateMotionSpeedResetButton:SetText("Default")
    nameplateMotionSpeedResetButton:SetWidth(60)
    nameplateMotionSpeedResetButton:SetPoint("LEFT", nameplateMotionSpeed, "RIGHT", 10, 0)
    nameplateMotionSpeedResetButton:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(nameplateMotionSpeed, "nameplateMotionSpeed")
    end)

    local moreBlizzSettingsText = guiMoreBlizzSettings:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettingsText:SetPoint("BOTTOM", guiMoreBlizzSettings, "BOTTOM", 0, 10)
    moreBlizzSettingsText:SetText("Work in progress, more stuff inc soon™\n \nSome settings don't make much sense anymore because\nthe addon grew a bit more than I thought it would.\nWill clean up eventually\n \nIf you have any suggestions feel free to\nleave a comment on CurseForge")
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
        guiNameplateAuras()
        guiMoreBlizzSettings()
    end
end