BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

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

-- GUI Functions
local function FetchCVarWhenLoaded(cvarName, callback)
    local function FetchCVarValue()
        if BBP.variablesLoaded then
            local value = GetCVar(cvarName)
            callback(value)
        else
            C_Timer.After(1, FetchCVarValue)
        end
    end

    FetchCVarValue()
end

local function FetchWidthWhenLoaded(callback)
    local function FetchWidthValue()
        if BBP.variablesLoaded then
            local value
            if BBP.isLargeNameplatesEnabled() then
                value = 154
            else
                value = 110
            end
            callback(value)
        else
            C_Timer.After(1, FetchWidthValue)
        end
    end

    FetchWidthValue()
end

local function DisableCheckboxes(frame)
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        if child and child:GetObjectType() == "CheckButton" or child:GetObjectType() == "Slider" then
            child:Disable()
            child:SetAlpha(0.5)
        end
    end
end

local function EnableCheckboxes(frame)
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        if child and child:GetObjectType() == "CheckButton" or child:GetObjectType() == "Slider" then
            child:Enable()
            child:SetAlpha(1)
        end
    end
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

local function CreateSlider(name, parent, label, minValue, maxValue, stepValue, element, axis)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Low = _G[slider:GetName() .. "Low"]
    slider.High = _G[slider:GetName() .. "High"]
    slider.Text = _G[slider:GetName() .. "Text"]
    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)

    slider.Low:SetText(" ")
    slider.High:SetText(" ")

    local initialValue

    if axis == "X" then
        initialValue = BetterBlizzPlatesDB[element .. "XPos"] or minValue
    elseif axis == "Y" then
        initialValue = BetterBlizzPlatesDB[element .. "YPos"] or minValue
    elseif axis == "Alpha" then
        initialValue = BetterBlizzPlatesDB[element .. "Alpha"] or minValue
    elseif axis == "Height" then
        initialValue = BetterBlizzPlatesDB[element .. "Height"] or minValue
    else
        initialValue = BetterBlizzPlatesDB[element .. "Scale"] or minValue
    end
    slider:SetValue(initialValue)

    local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
    slider.Text:SetText(label .. ": " .. textValue)

    slider:SetScript("OnValueChanged", function(self, value)
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
                    if element == "absorbIndicator" then
                        BBP.AbsorbIndicator(frame)
                    -- Combat Indicator Pos and Scale
                    elseif element == "combatIndicator" then
                        BBP.CombatIndicator(frame)
                    -- Healer Indicator Pos and Scale
                    elseif element == "healerIndicator" then
                        BBP.HealerIndicator(frame)
                    -- Pet Indicator Pos and Scale
                    elseif element == "petIndicator" then
                        BBP.PetIndicator(frame)
                    -- Quest Indicator Pos and Scale
                    elseif element == "questIndicator" then
                        BBP.QuestIndicator(frame)
                    -- Execute Indicator Pos and Scale
                    elseif element == "executeIndicator" then
                        BBP.ExecuteIndicator(frame)
                    -- Target Indicator Pos and Scale
                    elseif element == "targetIndicator" then
                        BBP.TargetIndicator(frame)
                    -- Focus Target Indicator Pos and Scale
                    elseif element == "focusTargetIndicator" then
                        BBP.FocusTargetIndicator(frame)
                    -- Totem Indicator Pos and Scale
                    elseif element == "totemIndicator" then
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
                    elseif element == "castBarIcon" then
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
                    elseif element == "castBarText" then
                        frame.castBar.Text:SetScale(value)
                    -- Cast bar emphasis icon pos and scale
                    elseif element == "castBarEmphasisIcon" then
                        if axis then
                            frame.castBar.Icon:SetPoint("CENTER", frame.castBar, "LEFT", xPos, yPos)
                        end


                    -- Target Text for Cast Timer Pos and Scale
                    elseif element == "targetText" then
                        --not rdy
                    -- Max auras on nameplate
                    elseif element == "maxAurasOnNameplate" then
                        BBP.RefBuffFrameDisplay()
                    elseif element == "nameplateAuras" then
                        if axis then
                            BBP.RefBuffFrameDisplay()
                        end
                    -- Raidmarker Pos and Scale
                    elseif element == "raidmarkIndicator" then
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
                    elseif element == "friendlyText" then
                        if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                            BBP.ClassColorAndScaleNames(frame)
                        end
                    -- Enemy name scale
                    elseif element == "enemyText" then
                        if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                            BBP.ClassColorAndScaleNames(frame)
                        end
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
                            BBP.FadeOutNPCs(frame)
                        end
                    end
                end
            end





            --If no nameplates are present still adjust values
            if element == "NamePlateVerticalScale" then
                if not BBP.checkCombatAndWarn() then
                    SetCVar("NamePlateVerticalScale", value)
                    BetterBlizzPlatesDB.NamePlateVerticalScale = value
                end
            elseif element == "executeIndicatorThreshold" then
                BetterBlizzPlatesDB.executeIndicatorThreshold = value
            elseif element == "castBarHeight" then
                BetterBlizzPlatesDB.castBarHeight = value
            elseif element == "castBarText" then
                BetterBlizzPlatesDB.castBarTextScale = value
            elseif element == "castBarEmphasisSpark" then
                BetterBlizzPlatesDB.castBarEmphasisSparkHeight = value
            elseif element == "castBarEmphasisIcon" then
                BetterBlizzPlatesDB.castBarEmphasisIconScale = value
            -- Cast bar emphasis height
            elseif element == "castBarEmphasisHeightValue" then
                BetterBlizzPlatesDB.castBarEmphasisHeightValue = value
            -- Cast bar emphasis text scale
            elseif element == "castBarEmphasisText" then
                BetterBlizzPlatesDB.castBarEmphasisTextScale = value
            -- Enemy Nameplate height
            elseif element == "enemyNameplateHealthbarHeight" then
                BetterBlizzPlatesDB.enemyNameplateHealthbarHeight = value
                --BBP.DefaultCompactNamePlateFrameAnchorInternal(frame, setupOptions)
            elseif element == "maxAurasOnNameplate" then
                BetterBlizzPlatesDB.maxAurasOnNameplate = value
                -- Nameplate scales
            elseif element == "nameplate" then
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
            elseif element == "nameplateSelected" then
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
            elseif element == "friendlyText" then
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
            elseif element == "enemyText" then
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
            elseif element == "arenaID" then
                BetterBlizzPlatesDB.arenaIDScale = value
                BBP.RefreshAllNameplatesLightVer()
            -- Arena spec scale
            elseif element == "arenaSpec" then
                BetterBlizzPlatesDB.arenaSpecScale = value
                BBP.RefreshAllNameplatesLightVer()
            -- Party ID scale
            elseif element == "partyID" then
                BetterBlizzPlatesDB.partyIDScale = value
                BBP.RefreshAllNameplatesLightVer()
            -- Party spec scale
            elseif element == "partySpec" then
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
            elseif element == "nameplateAuras" then
                if axis then
                    BetterBlizzPlatesDB.nameplateAurasYPos = yPos
                    BetterBlizzPlatesDB.nameplateAurasXPos = xPos
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

                    -- Refresh all nameplates only if a different anchor is picked
                    BBP.RefreshAllNameplates()
                end

                for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                    if namePlate.UnitFrame then
                        BBP.ExecuteIndicator(namePlate.UnitFrame)
                        if namePlate.UnitFrame.absorbIndicator then
                            local anchorPoint = BetterBlizzPlatesDB["absorbIndicatorAnchor"] or "LEFT"
                            local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
                            namePlate.UnitFrame.absorbIndicator:ClearAllPoints()
                            namePlate.UnitFrame.absorbIndicator:SetPoint(oppositeAnchor, namePlate.UnitFrame.healthBar, anchorPoint, BetterBlizzPlatesDB.absorbIndicatorXPos, BetterBlizzPlatesDB.absorbIndicatorYPos)
                        end
                    end
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

        if extraFunc and not BetterBlizzPlatesDB.wasOnLoadingScreen then
            extraFunc(option, value)
        end

        BBP.RefreshAllNameplates()
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
            local bg = button.bgTexture
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
        button.bgTexture = bg  -- Store the background texture for later color updates

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




local function guiGeneralTab()
    ------------------------------------------------------------------------------------------------
    -- Main panel:
    ------------------------------------------------------------------------------------------------
    -- Main GUI Anchor
    local mainGuiAnchor = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")

    -- Create the background texture
    local bgTexture = BetterBlizzPlates:CreateTexture(nil, "BACKGROUND")
    --bgTexture:SetAtlas("professions-specializations-background-inscription")
    bgTexture:SetAtlas("professions-recipe-background")
    bgTexture:SetPoint("CENTER", BetterBlizzPlates, "CENTER", -8, 4)
    bgTexture:SetSize(680, 610)
    bgTexture:SetAlpha(0.4)
    bgTexture:SetVertexColor(0,0,0)

    -- "Addon name" text
    local addonNameText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 15)
    addonNameText:SetText("BetterBlizzPlates")
    local addonNameIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    addonNameIcon:SetAtlas("gmchat-icon-blizz")
    addonNameIcon:SetSize(22, 22)
    addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)






    ------------------------------------------------------------------------------------------------
    -- General:
    ------------------------------------------------------------------------------------------------
    -- "General:" text
    local settingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -5)
    settingsText:SetText("General settings")
    local generalSettingsIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    -- Remove realm names from names
    local checkBox_removeRealmNames = CreateCheckbox("removeRealmNames", "Hide realm names", BetterBlizzPlates)
    checkBox_removeRealmNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    -- Hide nameplate auras
    local checkBox_hideNameplateAuras = CreateCheckbox("hideNameplateAuras", "Hide nameplate auras", BetterBlizzPlates)
    checkBox_hideNameplateAuras:SetPoint("TOPLEFT", checkBox_removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Hide target highlight glow on nameplates
    local checkBox_hideTargetHighlight = CreateCheckbox("hideTargetHighlight", "Hide target highlight glow", BetterBlizzPlates)
    checkBox_hideTargetHighlight:SetPoint("TOPLEFT", checkBox_hideNameplateAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Change raidmarker position
    local checkBox_raidmarkIndicator = CreateCheckbox("raidmarkIndicator", "Change raidmarker position", BetterBlizzPlates, nil, BBP.ChangeRaidmarker)
    checkBox_raidmarkIndicator:SetPoint("TOPLEFT", checkBox_hideTargetHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- nameplate scale slider
    local nameplateScaleSlider = CreateSlider("NameplateScaleSlider", BetterBlizzPlates, "Nameplate Size", 0.5, 2, 0.1, "nameplate")
    nameplateScaleSlider:SetPoint("TOPLEFT", checkBox_raidmarkIndicator, "BOTTOMLEFT", 12, -10)
    FetchCVarWhenLoaded("nameplateMaxScale", function(value)
        nameplateScaleSlider:SetValue(BetterBlizzPlatesDB.nameplateMaxScale or value)
    end)

    -- Reset button for nameplateScale slider
    local btn_reset_nameplateScale = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reset_nameplateScale:SetText("Default")
    btn_reset_nameplateScale:SetWidth(60)
    btn_reset_nameplateScale:SetPoint("LEFT", nameplateScaleSlider, "RIGHT", 10, 0)
    btn_reset_nameplateScale:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateScaleSlider, "nameplateScale")
    end)

    -- target nameplate scale
    local nameplateSelectedScaleSlider = CreateSlider("NameplateSelectedScaleSlider", BetterBlizzPlates, "Target Nameplate Size", 0.5, 3, 0.1, "nameplateSelected")
    nameplateSelectedScaleSlider:SetPoint("TOPLEFT", nameplateScaleSlider, "BOTTOMLEFT", 0, -17)
    FetchCVarWhenLoaded("nameplateSelectedScale", function(value)
        nameplateSelectedScaleSlider:SetValue(BetterBlizzPlatesDB.nameplateSelectedScale or value)
    end)

    -- Reset button for nameplateSelectedScale slider
    local btn_reset_nameplateSelected = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reset_nameplateSelected:SetText("Default")
    btn_reset_nameplateSelected:SetWidth(60)
    btn_reset_nameplateSelected:SetPoint("LEFT", nameplateSelectedScaleSlider, "RIGHT", 10, 0)
    btn_reset_nameplateSelected:SetScript("OnClick", function()
        BBP.ResetToDefaultScales(nameplateSelectedScaleSlider, "nameplateSelected")
    end)


    -- Nameplate Height
    local NamePlateVerticalScaleSlider = CreateSlider("NamePlateVerticalScaleSlider", BetterBlizzPlates, "Nameplate Height", 0.5, 5, 0.1, "NamePlateVerticalScale")
    NamePlateVerticalScaleSlider:SetPoint("TOPLEFT", nameplateSelectedScaleSlider, "BOTTOMLEFT", 0, -17)
    FetchCVarWhenLoaded("NamePlateVerticalScale", function(value)
        NamePlateVerticalScaleSlider:SetValue(BetterBlizzPlatesDB.NamePlateVerticalScale or value)
    end)
    CreateTooltip(NamePlateVerticalScaleSlider, "Changes the height of ALL nameplates.\n(Will also change the height of friendly castbars\nin PvE content due to Blizzard restrictions)")

    local btn_reset_nameplateHeight = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reset_nameplateHeight:SetText("Default")
    btn_reset_nameplateHeight:SetWidth(60)
    btn_reset_nameplateHeight:SetPoint("LEFT", NamePlateVerticalScaleSlider, "RIGHT", 10, 0)
    btn_reset_nameplateHeight:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight2(NamePlateVerticalScaleSlider)
    end)



    ------------------------------------------------------------------------------------------------
    -- Enemy nameplates:
    ------------------------------------------------------------------------------------------------
    -- "Enemy nameplates:" text
    local enemyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -230)
    enemyNameplatesText:SetText("Enemy nameplates")
    local enemyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon:SetSize(28, 28)
    enemyNameplateIcon:SetPoint("RIGHT", enemyNameplatesText, "LEFT", -3, 0)
    enemyNameplateIcon:SetDesaturated(1)
    enemyNameplateIcon:SetVertexColor(1, 0, 0)

    -- Class colored enemy names
    local checkBox_enemyClassColorName = CreateCheckbox("enemyClassColorName", "Class colored names", BetterBlizzPlates)
    checkBox_enemyClassColorName:SetPoint("TOPLEFT", enemyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    --Spellcast timer
    local checkBox_showNameplateCastbarTimer = CreateCheckbox("showNameplateCastbarTimer", "Cast timer next to castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    checkBox_showNameplateCastbarTimer:SetPoint("TOPLEFT", checkBox_enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    --Target name on spellcasts
    local checkBox_showNameplateTargetText = CreateCheckbox("showNameplateTargetText", "Show target underneath castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
    checkBox_showNameplateTargetText:SetPoint("TOPLEFT", checkBox_showNameplateCastbarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Enemy name size slider
    local enemyNameScaleSlider = CreateSlider("enemyNameScaleSlider", BetterBlizzPlates, "Name Size", 0.5, 1.5, 0.01, "enemyText")
    enemyNameScaleSlider:SetPoint("TOPLEFT", checkBox_showNameplateTargetText, "BOTTOMLEFT", 12, -10)
    enemyNameScaleSlider:SetValue(BetterBlizzPlatesDB.enemyNameScale or 1)

--[[
    -- Nameplate height slider
    local enemyNameplateHealthbarHeightSlider = CreateSlider("enemyNameplateHealthbarHeightScaleSlider", BetterBlizzPlates, "Nameplate Height (*)", 2, 20, 0.1, "enemyNameplateHealthbarHeight")
    enemyNameplateHealthbarHeightSlider:SetPoint("TOPLEFT", enemyNameScaleSlider, "BOTTOMLEFT", 0, -17)
    enemyNameplateHealthbarHeightSlider:SetValue(BetterBlizzPlatesDB.enemyNameplateHealthbarHeight or 10.8)
    enemyNameplateHealthbarHeightSlider:Disable()
    enemyNameplateHealthbarHeightSlider:SetAlpha(0.5)
    CreateTooltip(enemyNameplateHealthbarHeightSlider, "*Testing\nDisabled until I figure out stuff")

    -- Button for resetting Enemy Nameplate Height
    local btn_reset_enemyHeight = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reset_enemyHeight:SetText("Default")
    btn_reset_enemyHeight:SetWidth(60)
    btn_reset_enemyHeight:SetPoint("LEFT", enemyNameplateHealthbarHeightSlider, "RIGHT", 10, 0)
    btn_reset_enemyHeight:Disable()
    btn_reset_enemyHeight:SetAlpha(0.5)
    btn_reset_enemyHeight:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight2(enemyNameplateHealthbarHeightSlider)
    end)

]]


    -- Enemy nameplate width
    local nameplateEnemyWidthSlider = CreateSlider("BetterBlizzPlates_nameplateEnemyWidthSlider", BetterBlizzPlates, "Nameplate Width", 50, 200, 1, "nameplateEnemyWidth")
    nameplateEnemyWidthSlider:SetPoint("TOPLEFT", enemyNameScaleSlider, "BOTTOMLEFT", 0, -17)
    FetchWidthWhenLoaded(function(value)
        nameplateEnemyWidthSlider:SetValue(BetterBlizzPlatesDB.nameplateEnemyWidth or value)
    end)


    -- Button for resetting Enemy Nameplate width
    local btn_reset_enemy = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reset_enemy:SetText("Default")
    btn_reset_enemy:SetWidth(60)
    btn_reset_enemy:SetPoint("LEFT", nameplateEnemyWidthSlider, "RIGHT", 10, 0)
    btn_reset_enemy:SetScript("OnClick", function()
        BBP.ResetToDefaultWidth(nameplateEnemyWidthSlider, false)
    end)









    ------------------------------------------------------------------------------------------------
    -- Friendly nameplates:
    ------------------------------------------------------------------------------------------------
    -- "Friendly nameplates:" text
    local friendlyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -400)
    friendlyNameplatesText:SetText("Friendly nameplates")
    local friendlyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    friendlyNameplateIcon:SetAtlas("groupfinder-icon-friend")
    friendlyNameplateIcon:SetSize(28, 28)
    friendlyNameplateIcon:SetPoint("RIGHT", friendlyNameplatesText, "LEFT", -3, 0)

    -- Clickthrough plates
    local checkBox_friendlyNameplateClickthrough = CreateCheckbox("friendlyNameplateClickthrough", "Clickthrough", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
    checkBox_friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltip(checkBox_friendlyNameplateClickthrough, "Make friendly nameplates clickthrough and make them overlap despite stacking nameplates setting.")

    -- Class colored friendly names
    local checkBox_friendlyClassColorName = CreateCheckbox("friendlyClassColorName", "Class colored names", BetterBlizzPlates)
    checkBox_friendlyClassColorName:SetPoint("TOPLEFT", checkBox_friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Toggle friendly nameplates on for arena and off outside
    local checkBox_toggleFriendlyNameplatesInArena = CreateCheckbox("friendlyNameplatesOnlyInArena", "Toggle on/off for Arena auto", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesInArena)
    checkBox_toggleFriendlyNameplatesInArena:SetPoint("TOPLEFT", checkBox_friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_toggleFriendlyNameplatesInArena, "Turn on friendly nameplates when you enter arena and off again when you leave.")

    -- Friendly nameplates text slider
    local friendlyNameScaleSlider = CreateSlider("friendlyNameScaleSlider", BetterBlizzPlates, "Name Size", 0.5, 3, 0.1, "friendlyText")
    friendlyNameScaleSlider:SetPoint("TOPLEFT", checkBox_toggleFriendlyNameplatesInArena, "BOTTOMLEFT", 12, -10)
    friendlyNameScaleSlider:SetValue(BetterBlizzPlatesDB.friendlyNameScale or 1)

    -- Friendly nameplate width slider
    local nameplateFriendlyWidthSlider = CreateSlider("nameplateFriendlyWidthSlider", BetterBlizzPlates, "Nameplate Width", 50, 200, 1, "nameplateFriendlyWidth")
    nameplateFriendlyWidthSlider:SetPoint("TOPLEFT", friendlyNameScaleSlider, "BOTTOMLEFT", 0, -20)
    FetchWidthWhenLoaded(function(value)
        nameplateFriendlyWidthSlider:SetValue(BetterBlizzPlatesDB.nameplateFriendlyWidth or value)
    end)

    -- Button for resetting Friendly Nameplate width
    local btn_reset_friendly = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reset_friendly:SetText("Default")
    btn_reset_friendly:SetWidth(60)
    btn_reset_friendly:SetPoint("LEFT", nameplateFriendlyWidthSlider, "RIGHT", 5, 0)
    btn_reset_friendly:SetScript("OnClick", function()
        BBP.ResetToDefaultWidth(nameplateFriendlyWidthSlider, true)
    end)











    ------------------------------------------------------------------------------------------------
    -- Extra features on nameplates:
    ------------------------------------------------------------------------------------------------
    -- "Extra Features:" text
    local extraFeaturesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -250)
    extraFeaturesText:SetText("Extra Features")
    local extraFeaturesIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)

    -- Toggle to test arena ID for names
    local checkBox_testAllEnabledFeatures = CreateCheckbox("testAllEnabledFeatures", "Test", BetterBlizzPlates, nil, BBP.TestAllEnabledFeatures)           
    checkBox_testAllEnabledFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
    CreateTooltip(checkBox_testAllEnabledFeatures, "Test all enabled features. Check advanced settings for more")

    -- Absorb indicator
    local checkBox_absorbIndicator = CreateCheckbox("absorbIndicator", "Absorb indicator", BetterBlizzPlates, nil, BBP.ToggleAbsorbIndicator)
    checkBox_absorbIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)


    CreateTooltip(checkBox_absorbIndicator, "Show absorb amount on nameplates")
    local absorbsIcon = checkBox_absorbIndicator:CreateTexture(nil, "ARTWORK")
    absorbsIcon:SetAtlas("ParagonReputation_Glow")
    absorbsIcon:SetSize(22, 22)
    absorbsIcon:SetPoint("RIGHT", checkBox_absorbIndicator, "LEFT", 0, 0)

    -- Combat indicator
    local checkBox_combatIndicator = CreateCheckbox("combatIndicator", "Combat indicator", BetterBlizzPlates, nil, BBP.ToggleCombatIndicator)
    checkBox_combatIndicator:SetPoint("TOPLEFT", checkBox_absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    CreateTooltip(checkBox_combatIndicator, "Show a food icon on nameplates that are out of combat")
    local combatIcon = checkBox_combatIndicator:CreateTexture(nil, "ARTWORK")
    combatIcon:SetAtlas("food")
    combatIcon:SetSize(19, 19)
    combatIcon:SetPoint("RIGHT", checkBox_combatIndicator, "LEFT", -1, 0)

    -- Execute indicator
    local checkBox_executeIndicator = CreateCheckbox("executeIndicator", "Execute indicator", BetterBlizzPlates, nil, BBP.ToggleExecuteIndicator)
    checkBox_executeIndicator:SetPoint("TOPLEFT", checkBox_combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)


    CreateTooltip(checkBox_executeIndicator, "Starts tracking health percentage once target\ndips below a certain percentage.\n40% by default, can be changed in Advanced Settings.")
    local executeIndicatorIcon = checkBox_executeIndicator:CreateTexture(nil, "ARTWORK")
    executeIndicatorIcon:SetAtlas("islands-azeriteboss")
    executeIndicatorIcon:SetSize(28, 30)
    executeIndicatorIcon:SetPoint("RIGHT", checkBox_executeIndicator, "LEFT", 4, 1)

    -- Healer indicator
    local checkBox_healerIndicator = CreateCheckbox("healerIndicator", "Healer indicator", BetterBlizzPlates)
    checkBox_healerIndicator:SetPoint("TOPLEFT", checkBox_executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_healerIndicator, "Show a cross on healers. Requires Details to work.")
    local healerCrossIcon = checkBox_healerIndicator:CreateTexture(nil, "ARTWORK")
    healerCrossIcon:SetAtlas("greencross")
    healerCrossIcon:SetSize(21, 21)
    healerCrossIcon:SetPoint("RIGHT", checkBox_healerIndicator, "LEFT", 0, 0)

    -- Pet indicator
    local checkBox_petIndicator = CreateCheckbox("petIndicator", "Pet indicator", BetterBlizzPlates)
    checkBox_petIndicator:SetPoint("TOPLEFT", checkBox_healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_petIndicator, "Show a murloc on the main hunter pet")
    local petIndicator = checkBox_petIndicator:CreateTexture(nil, "ARTWORK")
    petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicator:SetSize(18, 18)
    petIndicator:SetPoint("RIGHT", checkBox_petIndicator, "LEFT", -1, 0)

    -- Target indicator
    local checkBox_targetIndicator = CreateCheckbox("targetIndicator", "Target indicator", BetterBlizzPlates, nil, BBP.ToggleTargetIndicator)
    checkBox_targetIndicator:SetPoint("TOPLEFT", checkBox_petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_targetIndicator, "Show a pointer on your current target")
    local targetIndicatorIcon = checkBox_healerIndicator:CreateTexture(nil, "ARTWORK")
    targetIndicatorIcon:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicatorIcon:SetRotation(math.rad(180))
    targetIndicatorIcon:SetSize(19, 14)
    targetIndicatorIcon:SetPoint("RIGHT", checkBox_targetIndicator, "LEFT", -1, 0)

    -- Focus Target indicator
    local checkBox_focusTargetIndicator = CreateCheckbox("focusTargetIndicator", "Focus target indicator", BetterBlizzPlates, nil, BBP.ToggleFocusTargetIndicator)
    checkBox_focusTargetIndicator:SetPoint("TOPLEFT", checkBox_targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_focusTargetIndicator, "Show a marker on the focus nameplate")
    local focusTargetIndicatorIcon = checkBox_healerIndicator:CreateTexture(nil, "ARTWORK")
    focusTargetIndicatorIcon:SetAtlas("Waypoint-MapPin-Untracked")
    focusTargetIndicatorIcon:SetSize(19, 19)
    focusTargetIndicatorIcon:SetPoint("RIGHT", checkBox_focusTargetIndicator, "LEFT", 0, 0)

    -- Totem indicator
    local checkBox_totemIndicator = CreateCheckbox("totemIndicator", "Totem indicator", BetterBlizzPlates)
    checkBox_totemIndicator:SetPoint("TOPLEFT", checkBox_focusTargetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_totemIndicator, "Color and put icons on key npc and totem nameplates.\nImportant npcs and totems will be slightly larger and\nhave a glow around the icon")
    local totemsIcon = checkBox_totemIndicator:CreateTexture(nil, "ARTWORK")
    totemsIcon:SetAtlas("teleportationnetwork-ardenweald-32x32")
    totemsIcon:SetSize(17, 17)
    totemsIcon:SetPoint("RIGHT", checkBox_totemIndicator, "LEFT", -1, 0)

    -- Quest indicator
    local checkBox_questIndicator = CreateCheckbox("questIndicator", "Quest indicator", BetterBlizzPlates)
    checkBox_questIndicator:SetPoint("TOPLEFT", checkBox_totemIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_questIndicator, "Quest symbol on quest npcs")
    local questsIcon = checkBox_questIndicator:CreateTexture(nil, "ARTWORK")
    questsIcon:SetAtlas("smallquestbang")
    questsIcon:SetSize(20, 20)
    questsIcon:SetPoint("RIGHT", checkBox_questIndicator, "LEFT", 1, 0)






    ------------------------------------------------------------------------------------------------
    -- Font and texture
    ------------------------------------------------------------------------------------------------
    -- Font and texture
    local customFontandTextureText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -480)
    customFontandTextureText:SetText("Font and texture")
    local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
    customFontandTextureIcon:SetAtlas("barbershop-32x32")
    customFontandTextureIcon:SetSize(24, 24)
    customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

    -- Use a sexy font for nameplates
    local checkBox_useCustomFont = CreateCheckbox("useCustomFont", "Use a sexy font for nameplates", BetterBlizzPlates)
    checkBox_useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    -- Use a sexy texture for nameplates
    local checkBox_useCustomTexture = CreateCheckbox("useCustomTextureForBars", "Use a sexy texture for nameplates", BetterBlizzPlates)
    checkBox_useCustomTexture:SetPoint("TOPLEFT", checkBox_useCustomFont, "BOTTOMLEFT", 0, pixelsBetweenBoxes)









    ------------------------------------------------------------------------------------------------
    -- Arena
    ------------------------------------------------------------------------------------------------
    -- "Arena:" text
    local arenaSettingsText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaSettingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -5)
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
            --print("Selected mode:", arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSettingsText, x = -20, y = -30, label = "Mode" },
        modes,
        tooltips,
        "Enemy",
        {1, 0, 0, 1}
    )

    -- Toggle to test arena ID for names
    local checkBox_arenaIndicatorTestMode = CreateCheckbox("arenaIndicatorTestMode", "Test", BetterBlizzPlates, BBP.RefreshAllNameplates)           
    checkBox_arenaIndicatorTestMode:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)

    -- Arena nameplates slider
    local arenaIDScaleSlider = CreateSlider("arenaIDScaleSlider", BetterBlizzPlates, "Arena ID Size", 1, 4, 0.1, "arenaID")
    arenaIDScaleSlider:SetPoint("TOPLEFT", arenaModeDropdown, "BOTTOMLEFT", 20, -9)
    arenaIDScaleSlider:SetValue(BetterBlizzPlatesDB.arenaIDScale or 1)
    CreateTooltip(arenaIDScaleSlider, "Size of the arena ID text on top of nameplate during arena.")

    -- Arena spec nameplates slider
    local arenaSpecScaleSlider = CreateSlider("arenaSpecScale", BetterBlizzPlates, "Spec Size", 0.5, 3, 0.1, "arenaSpec")
    arenaSpecScaleSlider:SetPoint("TOPLEFT", arenaIDScaleSlider, "BOTTOMLEFT", 0, -11)
    arenaSpecScaleSlider:SetValue(BetterBlizzPlatesDB.arenaSpecScale or 1)
    CreateTooltip(arenaSpecScaleSlider, "Size of the spec name text on top of nameplate during arena.")

    local partyModeDropdown = CreateModeDropdown(
        "partyModeDropdown",
        BetterBlizzPlates,
        "Select a mode to use",
        "partyModeSettingKey",
        function(arg1)
            --print("Selected mode:", arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = arenaSpecScaleSlider, x = -20, y = -30, label = "Mode" },
        modesParty,
        tooltipsParty,
        "Friendly", -- textLabel
        {0.04, 0.76, 1, 1} -- textColor (blue)
    )

    -- Party nameplates scale slider
    local partyIDScaleSlider = CreateSlider("partyIDScaleSlider", BetterBlizzPlates, "Party ID Size", 1, 4, 0.1, "partyID")
    partyIDScaleSlider:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
    partyIDScaleSlider:SetValue(BetterBlizzPlatesDB.partyIDScale or 1)

    -- Party spec name scale slider
    local partySpecScaleSlider = CreateSlider("partySpecScale", BetterBlizzPlates, "Spec Size", 0.5, 3, 0.1, "partySpec")
    partySpecScaleSlider:SetPoint("TOPLEFT", partyIDScaleSlider, "BOTTOMLEFT", 0, -11)
    partySpecScaleSlider:SetValue(BetterBlizzPlatesDB.partySpecScale or 1)


    ------------------------------------------------------------------------------------------------
    -- Reload etc
    ------------------------------------------------------------------------------------------------

    local btn_reload_ui = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    btn_reload_ui:SetText("Reload UI")
    btn_reload_ui:SetWidth(85)
    btn_reload_ui:SetPoint("TOP", BetterBlizzPlates, "BOTTOMRIGHT", -140, -9)
    btn_reload_ui:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    local body_ui_profile = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
    body_ui_profile:SetText("Body Profile")
    body_ui_profile:SetWidth(100)
    body_ui_profile:SetPoint("RIGHT", btn_reload_ui, "LEFT", -10, 0)
    body_ui_profile:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_BODY_PROFILE")
    end)

    -- Create a static popup for the confirmation dialog
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

    InterfaceOptions_AddCategory(BetterBlizzPlates)
end

local function guiPositionAndScale()
    ------------------------------------------------------------------------------------------------
    -- Advanced settings
    ------------------------------------------------------------------------------------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -360
    local thirdLineX = 391
    local thirdLineY = -655
    local fourthLineX = 560

    -- ADVANCED SETTINGS PANEL
    local BetterBlizzPlatesSubPanel = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel.name = "Advanced Settings"
    BetterBlizzPlatesSubPanel.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel)

    -- Create the background texture
    local bgTexture2 = BetterBlizzPlatesSubPanel:CreateTexture(nil, "BACKGROUND")
    bgTexture2:SetAtlas("professions-recipe-background")
    bgTexture2:SetPoint("CENTER", BetterBlizzPlatesSubPanel, "CENTER", -8, 4)
    bgTexture2:SetSize(680, 610)
    bgTexture2:SetAlpha(0.4)
    bgTexture2:SetVertexColor(0,0,0)



    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzPlatesSubPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzPlatesSubPanel, "CENTER", -20, 3)

    -- Create the content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    -- Main GUI Anchor
    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

    ------------------------------------------------------------------------------------------------
    -- Healer indicator
    ------------------------------------------------------------------------------------------------
    --Healer Indicator
    local anchorSubHeal = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHeal:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY)
    anchorSubHeal:SetText("Healer Indicator")

    CreateBorderBox(anchorSubHeal)

    local healerCrossIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    healerCrossIcon2:SetAtlas("greencross")
    healerCrossIcon2:SetSize(32, 32)
    healerCrossIcon2:SetPoint("BOTTOM", anchorSubHeal, "TOP", 0, 0)
    healerCrossIcon2:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    -- Healer icon scale slider2
    local healerIndicatorScaleSlider2 = CreateSlider("BetterBlizzPlates_healerIndicatorScaleSlider2", contentFrame, "Size", 0.6, 2.5, 0.1, "healerIndicator")
    healerIndicatorScaleSlider2:SetPoint("TOP", anchorSubHeal, "BOTTOM", 0, -15)
    healerIndicatorScaleSlider2:SetValue(BetterBlizzPlatesDB.healerIndicatorScale)

    -- Healer x pos slider
    local healerIndicatorXPosSlider2 = CreateSlider("BetterBlizzPlates_healerIndicatorXPosSlider2", contentFrame, "x offset", -50, 50, 1, "healerIndicator", "X")
    healerIndicatorXPosSlider2:SetPoint("TOP", healerIndicatorScaleSlider2, "BOTTOM", 0, -15)
    healerIndicatorXPosSlider2:SetValue(BetterBlizzPlatesDB.healerIndicatorXPos or 0)

    -- Healer y pos slider
    local healerIndicatorYPosSlider2 = CreateSlider("BetterBlizzPlates_healerIndicatorYPosSlider2", contentFrame, "y offset", -50, 50, 1, "healerIndicator", "Y")
    healerIndicatorYPosSlider2:SetPoint("TOP", healerIndicatorXPosSlider2, "BOTTOM", 0, -15)
    healerIndicatorYPosSlider2:SetValue(BetterBlizzPlatesDB.healerIndicatorYPos or 0)

    -- Healer icon anchor dropdown
    local healerIndicatorDropdown = CreateAnchorDropdown(
        "healerIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "healerIndicatorAnchor",
        function(arg1)
            --print("Selected anchor:", arg1)
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = healerIndicatorYPosSlider2, x = -15, y = -35, label = "Anchor" }
    )

    -- Healer icon tester
    local checkBox_healerIndicatorTestMode2 = CreateCheckbox("healerIndicatorTestMode", "Test", contentFrame)
    checkBox_healerIndicatorTestMode2:SetPoint("TOPLEFT", healerIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    -- Only on enemy nameplate
    local checkBox_healerIndicatorEnemyOnly2 = CreateCheckbox("healerIndicatorEnemyOnly", "Enemies only", contentFrame)
    checkBox_healerIndicatorEnemyOnly2:SetPoint("TOPLEFT", checkBox_healerIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)


    ------------------------------------------------------------------------------------------------
    -- Combat indicator
    ------------------------------------------------------------------------------------------------
    --Combat Indicator
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

    -- ooc scale Slider
    local outOfCombatScaleSlider = CreateSlider("BetterBlizzPlates_outOfCombatScaleSlider", contentFrame, "Size", 0.1, 1.9, 0.1, "combatIndicator")
    outOfCombatScaleSlider:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)
    outOfCombatScaleSlider:SetValue(BetterBlizzPlatesDB.combatIndicatorScale or 1)

    local outOfCombatXPosSlider = CreateSlider("BetterBlizzPlates_outOfCombatXPosSlider", contentFrame, "x offset", -50, 50, 1, "combatIndicator", "X")
    outOfCombatXPosSlider:SetPoint("TOP", outOfCombatScaleSlider, "BOTTOM", 0, -15)
    outOfCombatXPosSlider:SetValue(BetterBlizzPlatesDB.combatIndicatorXPos or 0)

    local outOfCombatYPosSlider = CreateSlider("BetterBlizzPlates_outOfCombatYPosSlider", contentFrame, "y offset", -50, 50, 1, "combatIndicator", "Y")
    outOfCombatYPosSlider:SetPoint("TOP", outOfCombatXPosSlider, "BOTTOM", 0, -15)
    outOfCombatYPosSlider:SetValue(BetterBlizzPlatesDB.combatIndicatorYPos or 0)

    -- For the Out of Combat Icon:
    local combatIndicatorDropdown = CreateAnchorDropdown(
        "combatIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "combatIndicatorAnchor",
        function(arg1) 
            --("Selected anchor for Out of Combat Indicator:", arg1);
            BBP.RefreshAllNameplates()
        end,
        { anchorFrame = outOfCombatYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Only on enemy nameplate
    local checkBox_combatIndicatorEnemyOnly = CreateCheckbox("combatIndicatorEnemyOnly", "Enemies only", contentFrame)
    checkBox_combatIndicatorEnemyOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    -- Only in arena
    local checkBox_combatIndicatorArenaOnly = CreateCheckbox("combatIndicatorArenaOnly", "In arena only", contentFrame)
    checkBox_combatIndicatorArenaOnly:SetPoint("TOPLEFT", checkBox_combatIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- use sap texture instead
    local checkBox_combatIndicatorSap = CreateCheckbox("combatIndicatorSap", "Use sap icon instead", contentFrame) --combatIndicatorSap
    checkBox_combatIndicatorSap:SetPoint("TOPLEFT", checkBox_combatIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    checkBox_combatIndicatorSap:SetScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzPlatesDB.combatIndicatorSap = true -- (setting SetScript on click here overrides the checkbox creation function so have to toggle value here)
            combatIconSub:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
            combatIconSub:SetSize(38, 38)
            combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 0)
            BBP.RefreshAllNameplates()
        else
            BetterBlizzPlatesDB.combatIndicatorSap = false
            combatIconSub:SetAtlas("food")
            combatIconSub:SetSize(42, 42)
            combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", -1, 0)
            BBP.RefreshAllNameplates()
        end
    end)

    -- Only on players
    local checkBox_combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", "On players only", contentFrame)
    checkBox_combatIndicatorPlayersOnly:SetPoint("TOPLEFT", checkBox_combatIndicatorSap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)



    ------------------------------------------------------------------------------------------------
    -- Hunter pet icon
    ------------------------------------------------------------------------------------------------
    --Hunter pet icon
    local anchorSubPet = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPet:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubPet:SetText("Pet Indicator")

    CreateBorderBox(anchorSubPet)

    local petIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    petIndicator2:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicator2:SetSize(38, 38)
    petIndicator2:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

    -- Pet icon scale slider2
    local petIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_petIndicatorScaleSlider", contentFrame, "Size", 0.1, 1.9, 0.1, "petIndicator")
    petIndicatorScaleSlider:SetPoint("TOP", anchorSubPet, "BOTTOM", 0, -15)
    petIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.petIndicatorScale)

    -- Pet x pos slider
    local petIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_petIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "petIndicator", "X")
    petIndicatorXPosSlider:SetPoint("TOP", petIndicatorScaleSlider, "BOTTOM", 0, -15)
    petIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.petIndicatorXPos or 0)

    -- Pet y pos slider
    local petIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_petIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "petIndicator", "Y")
    petIndicatorYPosSlider:SetPoint("TOP", petIndicatorXPosSlider, "BOTTOM", 0, -15)
    petIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.petIndicatorYPos or 0)

    -- Pet icon anchor dropdown
    local petIndicatorDropdown = CreateAnchorDropdown(
        "petIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "petIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = petIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Pet icon tester
    local checkBox_petIndicatorTestMode2 = CreateCheckbox("petIndicatorTestMode", "Test", contentFrame)
    checkBox_petIndicatorTestMode2:SetPoint("TOPLEFT", petIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)



    ------------------------------------------------------------------------------------------------
    -- absorb indicator
    ------------------------------------------------------------------------------------------------
    --absorb Indicator
    local anchorSubAbsorb = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubAbsorb:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubAbsorb:SetText("Absorb Indicator")

    CreateBorderBox(anchorSubAbsorb)

    local absorbIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator2:SetAtlas("ParagonReputation_Glow")
    absorbIndicator2:SetSize(56, 56)
    absorbIndicator2:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

    -- absorb icon scale slider2
    local absorbIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_absorbIndicatorScaleSlider", contentFrame, "Size", 0.1, 1.9, 0.1, "absorbIndicator")
    absorbIndicatorScaleSlider:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)
    absorbIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.absorbIndicatorScale or 1)

    -- absorb x pos slider
    local absorbIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_absorbIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "absorbIndicator", "X")
    absorbIndicatorXPosSlider:SetPoint("TOP", absorbIndicatorScaleSlider, "BOTTOM", 0, -15)
    absorbIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.absorbIndicatorXPos or 0)

    -- absorb y pos slider
    local absorbIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_absorbIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "absorbIndicator", "Y")
    absorbIndicatorYPosSlider:SetPoint("TOP", absorbIndicatorXPosSlider, "BOTTOM", 0, -15)
    absorbIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.absorbIndicatorYPos or 0)

    -- absorb icon anchor dropdown
    local absorbIndicatorDropdown = CreateAnchorDropdown(
        "absorbIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "absorbIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = absorbIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Absorb icon tester
    local checkBox_absorbIndicatorTestMode2 = CreateCheckbox("absorbIndicatorTestMode", "Test", contentFrame)
    checkBox_absorbIndicatorTestMode2:SetPoint("TOPLEFT", absorbIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    -- Only on enemy nameplate
    local checkBox_absorbIndicatorEnemyOnly = CreateCheckbox("absorbIndicatorEnemyOnly", "Enemies only", contentFrame)
    checkBox_absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", checkBox_absorbIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Only on player nameplates
    local checkBox_absorbIndicatorOnPlayersOnly = CreateCheckbox("absorbIndicatorOnPlayersOnly", "Players only", contentFrame)
    checkBox_absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", checkBox_absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)



    ------------------------------------------------------------------------------------------------
    -- totem
    ------------------------------------------------------------------------------------------------
    --totem Indicator
    local anchorSubTotem = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTotem:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY)
    anchorSubTotem:SetText("Totem Indicator")

    CreateBorderBox(anchorSubTotem)

    local totemIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    totemIcon2:SetAtlas("teleportationnetwork-ardenweald-32x32")
    totemIcon2:SetSize(34, 34)
    totemIcon2:SetPoint("BOTTOM", anchorSubTotem, "TOP", 0, 0)

    -- Totem Important Icon Size Slider
    local totemIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_totemIndicatorScaleSlider", contentFrame, "Size", 0.5, 3, 0.1, "totemIndicator")
    totemIndicatorScaleSlider:SetPoint("TOP", anchorSubTotem, "BOTTOM", 0, -15)
    totemIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.totemIndicatorScale or 1)

    -- totem x pos slider
    local totemIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_totemIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "totemIndicator", "X")
    totemIndicatorXPosSlider:SetPoint("TOP", totemIndicatorScaleSlider, "BOTTOM", 0, -15)
    totemIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.totemIndicatorXPos or 0)

    -- totem y pos slider
    local totemIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_totemIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "totemIndicator", "Y")
    totemIndicatorYPosSlider:SetPoint("TOP", totemIndicatorXPosSlider, "BOTTOM", 0, -15)
    totemIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.totemIndicatorYPos or 0)

    -- totem icon anchor dropdown
    local totemIndicatorDropdown = CreateAnchorDropdown(
        "totemIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "totemIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = totemIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Toggle to test totem icons
    local checkBox_totemTestIcons2 = CreateCheckbox("totemIndicatorTestMode", "Test", contentFrame)
    checkBox_totemTestIcons2:SetPoint("TOPLEFT", totemIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    -- Shift icon down and remove name
    local checkBox_totemIndicatorHideNameAndShiftIconDown = CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", "Hide name", contentFrame)
    checkBox_totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", checkBox_totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- Glow off
    local checkBox_totemIndicatorGlowOff = CreateCheckbox("totemIndicatorGlowOff", "No glow", contentFrame)
    checkBox_totemIndicatorGlowOff:SetPoint("TOPLEFT", checkBox_totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_totemIndicatorGlowOff, "Turn off the glow around the icons on important nameplates.")

    -- Scale up important npcs
    local checkBox_totemIndicatorScaleUpImportant = CreateCheckbox("totemIndicatorScaleUpImportant", "Scale up important", contentFrame)
    checkBox_totemIndicatorScaleUpImportant:SetPoint("TOPLEFT", checkBox_totemIndicatorGlowOff, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_totemIndicatorScaleUpImportant, "Scale up important nameplates slightly.")







    ------------------------------------------------------------------------------------------------
    -- Target indicator
    ------------------------------------------------------------------------------------------------
    --Target indicator
    local anchorSubTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, secondLineY)
    anchorSubTarget:SetText("Target Indicator")

    CreateBorderBox(anchorSubTarget)

    local targetIndicator2 = contentFrame:CreateTexture(nil, "ARTWORK")
    targetIndicator2:SetAtlas("Navigation-Tracked-Arrow")
    targetIndicator2:SetRotation(math.rad(180))
    targetIndicator2:SetSize(48, 32)
    targetIndicator2:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

    -- Target indicator scale slider2
    local targetIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_targetIndicatorScaleSlider", contentFrame, "Size", 0.1, 1.9, 0.1, "targetIndicator")
    targetIndicatorScaleSlider:SetPoint("TOP", anchorSubTarget, "BOTTOM", 0, -15)
    targetIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.targetIndicatorScale)

    -- Target indicator x pos slider
    local targetIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_targetIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "targetIndicator", "X")
    targetIndicatorXPosSlider:SetPoint("TOP", targetIndicatorScaleSlider, "BOTTOM", 0, -15)
    targetIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.targetIndicatorXPos or 0)

    -- Target indicator y pos slider
    local targetIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_targetIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "targetIndicator", "Y")
    targetIndicatorYPosSlider:SetPoint("TOP", targetIndicatorXPosSlider, "BOTTOM", 0, -15)
    targetIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.targetIndicatorYPos)

    -- Target indicator icon anchor dropdown
    local targetIndicatorDropdown = CreateAnchorDropdown(
        "targetIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "targetIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = targetIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )




    ------------------------------------------------------------------------------------------------
    -- Raid Indicator
    ------------------------------------------------------------------------------------------------
    -- Raid Indicator
    local anchorSubRaidmark = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubRaidmark:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, secondLineY)
    anchorSubRaidmark:SetText("Raidmarker")

    CreateBorderBox(anchorSubRaidmark)

    local raidmarkIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    raidmarkIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_3")
    raidmarkIcon:SetSize(38, 38)
    raidmarkIcon:SetPoint("BOTTOM", anchorSubRaidmark, "TOP", 0, 0)

    -- Raid Indicator scale slider2
    local raidmarkIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_raidmarkIndicatorScaleSlider", contentFrame, "Size", 0.6, 2.5, 0.1, "raidmarkIndicator")
    raidmarkIndicatorScaleSlider:SetPoint("TOP", anchorSubRaidmark, "BOTTOM", 0, -15)
    raidmarkIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorScale)

    -- Raid x pos slider
    local raidmarkIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_raidmarkIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "raidmarkIndicator", "X")
    raidmarkIndicatorXPosSlider:SetPoint("TOP", raidmarkIndicatorScaleSlider, "BOTTOM", 0, -15)
    raidmarkIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorXPos or 0)

    -- Raid y pos slider
    local raidmarkIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_raidmarkIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "raidmarkIndicator", "Y")
    raidmarkIndicatorYPosSlider:SetPoint("TOP", raidmarkIndicatorXPosSlider, "BOTTOM", 0, -15)
    raidmarkIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorYPos or 0)

    -- Raid Indicator anchor dropdown
    local raidmarkIndicatorDropdown = CreateAnchorDropdown(
        "raidmarkIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "raidmarkIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = raidmarkIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Change raidmarker position
    local checkBox_raidmarkIndicator2 = CreateCheckbox("raidmarkIndicator", "Change raidmarker pos", contentFrame, nil, BBP.ChangeRaidmarker)
    checkBox_raidmarkIndicator2:SetPoint("TOPLEFT", raidmarkIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    ------------------------------------------------------------------------------------------------
    -- Quest Indicator
    ------------------------------------------------------------------------------------------------
    local anchorSubquest = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubquest:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, secondLineY)
    anchorSubquest:SetText("Quest Indicator")

    CreateBorderBox(anchorSubquest)

    local questIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    questIcon2:SetAtlas("smallquestbang")
    questIcon2:SetSize(44, 44)
    questIcon2:SetPoint("BOTTOM", anchorSubquest, "TOP", 0, 0)

    -- quest Important Icon Size Slider
    local questIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_questIndicatorScaleSlider", contentFrame, "Size", 0.1, 1.9, 0.1, "questIndicator")
    questIndicatorScaleSlider:SetPoint("TOP", anchorSubquest, "BOTTOM", 0, -15)
    questIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.questIndicatorScale or 1)

    -- quest x pos slider
    local questIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_questIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "questIndicator", "X")
    questIndicatorXPosSlider:SetPoint("TOP", questIndicatorScaleSlider, "BOTTOM", 0, -15)
    questIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.questIndicatorXPos or 0)

    -- quest y pos slider
    local questIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_questIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "questIndicator", "Y")
    questIndicatorYPosSlider:SetPoint("TOP", questIndicatorXPosSlider, "BOTTOM", 0, -15)
    questIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.questIndicatorYPos or 0)

    -- quest icon anchor dropdown
    local questIndicatorDropdown = CreateAnchorDropdown(
        "questIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "questIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = questIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Toggle to test quest icons
    local checkBox_questTestIcons2 = CreateCheckbox("questIndicatorTestMode", "Test", contentFrame)
    checkBox_questTestIcons2:SetPoint("TOPLEFT", questIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)





    ------------------------------------------------------------------------------------------------
    -- Focus Target Indicator
    ------------------------------------------------------------------------------------------------
    local anchorSubFocus = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFocus:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, thirdLineY)
    anchorSubFocus:SetText("Focus Target Indicator")

    CreateBorderBox(anchorSubFocus)

    local focusIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusIcon:SetAtlas("Waypoint-MapPin-Untracked")
    focusIcon:SetSize(44, 44)
    focusIcon:SetPoint("BOTTOM", anchorSubFocus, "TOP", 0, 0)

    -- focusTarget Important Icon Size Slider
    local focusTargetIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_focusTargetIndicatorScaleSlider", contentFrame, "Size", 0.5, 3, 0.1, "focusTargetIndicator")
    focusTargetIndicatorScaleSlider:SetPoint("TOP", anchorSubFocus, "BOTTOM", 0, -15)
    focusTargetIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.focusTargetIndicatorScale or 1)

    -- focusTarget x pos slider
    local focusTargetIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_focusTargetIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "focusTargetIndicator", "X")
    focusTargetIndicatorXPosSlider:SetPoint("TOP", focusTargetIndicatorScaleSlider, "BOTTOM", 0, -15)
    focusTargetIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.focusTargetIndicatorXPos or 0)

    -- focusTarget y pos slider
    local focusTargetIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_focusTargetIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "focusTargetIndicator", "Y")
    focusTargetIndicatorYPosSlider:SetPoint("TOP", focusTargetIndicatorXPosSlider, "BOTTOM", 0, -15)
    focusTargetIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.focusTargetIndicatorYPos or 0)

    -- focusTarget icon anchor dropdown
    local focusTargetIndicatorDropdown = CreateAnchorDropdown(
        "focusTargetIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "focusTargetIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = focusTargetIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Toggle to test focusTarget icons
    local checkBox_focusTargetTestIcons2 = CreateCheckbox("focusTargetIndicatorTestMode", "Test", contentFrame)
    checkBox_focusTargetTestIcons2:SetPoint("TOPLEFT", focusTargetIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

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




    -- Color nameplate
    local checkBox_focusTargetIndicatorColorNameplate = CreateCheckbox("focusTargetIndicatorColorNameplate", "Color healthbar", contentFrame)
    checkBox_focusTargetIndicatorColorNameplate:SetPoint("TOPLEFT", checkBox_focusTargetTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local focusColorButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    focusColorButton:SetText("Color")
    focusColorButton:SetPoint("LEFT", checkBox_focusTargetIndicatorColorNameplate.text, "RIGHT", -1, 0)
    focusColorButton:SetSize(43, 18)
    focusColorButton:SetScript("OnClick", OpenColorPicker)

    checkBox_focusTargetIndicatorColorNameplate:SetScript("OnClick", function(self)
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

    -- Change texture
    local checkBox_focusTargetIndicatorChangeTexture = CreateCheckbox("focusTargetIndicatorChangeTexture", "Re-texture healthbar", contentFrame)
    checkBox_focusTargetIndicatorChangeTexture:SetPoint("TOPLEFT", checkBox_focusTargetIndicatorColorNameplate, "BOTTOMLEFT", 0, pixelsBetweenBoxes)





    ------------------------------------------------------------------------------------------------
    -- execute Indicator
    ------------------------------------------------------------------------------------------------
    local anchorSubExecute = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubExecute:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, thirdLineY)
    anchorSubExecute:SetText("Execute Indicator")

    CreateBorderBox(anchorSubExecute)

    local executeIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    executeIcon:SetAtlas("islands-azeriteboss")
    executeIcon:SetSize(56, 60)
    executeIcon:SetPoint("BOTTOM", anchorSubExecute, "TOP", 0, -10)

    -- execute Important Icon Size Slider
    local executeIndicatorScaleSlider = CreateSlider("BetterBlizzPlates_executeIndicatorScaleSlider", contentFrame, "Size", 0.5, 2.5, 0.05, "executeIndicator")
    executeIndicatorScaleSlider:SetPoint("TOP", anchorSubExecute, "BOTTOM", 0, -15)
    executeIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.executeIndicatorScale or 1)

    -- execute x pos slider
    local executeIndicatorXPosSlider = CreateSlider("BetterBlizzPlates_executeIndicatorXPosSlider", contentFrame, "x offset", -50, 50, 1, "executeIndicator", "X")
    executeIndicatorXPosSlider:SetPoint("TOP", executeIndicatorScaleSlider, "BOTTOM", 0, -15)
    executeIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.executeIndicatorXPos or 0)

    -- execute y pos slider
    local executeIndicatorYPosSlider = CreateSlider("BetterBlizzPlates_executeIndicatorYPosSlider", contentFrame, "y offset", -50, 50, 1, "executeIndicator", "Y")
    executeIndicatorYPosSlider:SetPoint("TOP", executeIndicatorXPosSlider, "BOTTOM", 0, -15)
    executeIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.executeIndicatorYPos or 0)

    -- execute icon anchor dropdown
    local executeIndicatorDropdown = CreateAnchorDropdown(
        "executeIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "executeIndicatorAnchor",
        function(arg1) --print("Selected anchor:", arg1);
        BBP.RefreshAllNameplates()
    end,
        { anchorFrame = executeIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
    )

    -- Toggle to test execute icons
    local checkBox_executeTestIcons2 = CreateCheckbox("executeIndicatorTestMode", "Test", contentFrame)
    checkBox_executeTestIcons2:SetPoint("TOPLEFT", executeIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

    local checkBox_executeIndicatorAlwaysOn = CreateCheckbox("executeIndicatorAlwaysOn", "Always on", contentFrame)
    checkBox_executeIndicatorAlwaysOn:SetPoint("TOPLEFT", checkBox_executeTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_executeIndicatorAlwaysOn, "Always display health percentage")

    local checkBox_executeIndicatorFriendly = CreateCheckbox("executeIndicatorFriendly", "Friendly", contentFrame)
    checkBox_executeIndicatorFriendly:SetPoint("TOPLEFT", checkBox_executeIndicatorAlwaysOn, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_executeIndicatorFriendly, "Show on friendly nameplates")

    local checkBox_executeIndicatorNotOnFullHp = CreateCheckbox("executeIndicatorNotOnFullHp", "< 100%", contentFrame)
    checkBox_executeIndicatorNotOnFullHp:SetPoint("LEFT", checkBox_executeIndicatorAlwaysOn.text, "RIGHT", 2, 0)
    CreateTooltip(checkBox_executeIndicatorNotOnFullHp, "Hide on 100%")

    local checkBox_executeIndicatorShowDecimal = CreateCheckbox("executeIndicatorShowDecimal", "Decimal", contentFrame)
    checkBox_executeIndicatorShowDecimal:SetPoint("BOTTOMLEFT", checkBox_executeIndicatorNotOnFullHp, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltip(checkBox_executeIndicatorShowDecimal, "Show decimal")

    local executeIndicatorThresholdSlider = CreateSlider("BetterBlizzPlates_executeIndicatorThresholdSlider", contentFrame, "Threshold", 5, 100, 1, "executeIndicatorThreshold", "Y")
    executeIndicatorThresholdSlider:SetPoint("TOP", checkBox_executeIndicatorAlwaysOn, "BOTTOM", 58, -29)
    executeIndicatorThresholdSlider:SetValue(BetterBlizzPlatesDB.executeIndicatorThreshold or 40)
    CreateTooltip(executeIndicatorThresholdSlider, "Percentage of when the execute indicator should show.")

    local function executeIndicatorToggle()
        if BetterBlizzPlatesDB.executeIndicatorAlwaysOn then
            checkBox_executeIndicatorNotOnFullHp:SetAlpha(1)
            checkBox_executeIndicatorNotOnFullHp:Enable()
            executeIndicatorThresholdSlider:SetAlpha(0.5)
            executeIndicatorThresholdSlider:Disable()
        else
            checkBox_executeIndicatorNotOnFullHp:SetAlpha(0.5)
            checkBox_executeIndicatorNotOnFullHp:Disable()
            executeIndicatorThresholdSlider:SetAlpha(1)
            executeIndicatorThresholdSlider:Enable()
        end
    end
    executeIndicatorToggle()

    checkBox_executeIndicatorAlwaysOn:HookScript("OnClick", function(_, btn, down)
        executeIndicatorToggle()
    end)























    local btn_reload_ui2 = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
    btn_reload_ui2:SetText("Reload UI")
    btn_reload_ui2:SetWidth(85)
    btn_reload_ui2:SetPoint("TOP", BetterBlizzPlatesSubPanel, "BOTTOMRIGHT", -140, -9)
    btn_reload_ui2:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)
end

local function guiCastbar()
    ------------------------------------------------------------------------------------------------
    -- Castbar Customization
    ------------------------------------------------------------------------------------------------
    -- Castbar Customization
    local BetterBlizzPlatesSubPanel7 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel7.name = "Castbar"
    BetterBlizzPlatesSubPanel7.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel7)

    -- Create the background texture
    local bgTexture8 = BetterBlizzPlatesSubPanel7:CreateTexture(nil, "BACKGROUND")
    bgTexture8:SetAtlas("professions-recipe-background")
    bgTexture8:SetPoint("CENTER", BetterBlizzPlatesSubPanel7, "CENTER", -8, 4)
    bgTexture8:SetSize(680, 610)
    bgTexture8:SetAlpha(0.4)
    bgTexture8:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor8 = BetterBlizzPlatesSubPanel7:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor8:SetPoint("TOPLEFT", 15, 20)
    mainGuiAnchor8:SetText(" ")


    local listFrame = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel7)
    listFrame:SetAllPoints(BetterBlizzPlatesSubPanel7)
    CreateList(listFrame, "castEmphasisList", BetterBlizzPlatesDB.castEmphasisList, BBP.RefreshAllNameplates, true)

    local how2usecastemphasis = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usecastemphasis:SetPoint("TOP", mainGuiAnchor8, "BOTTOM", 140, -450)
    how2usecastemphasis:SetText("Add name or spell ID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or polymorph/kick this\n \nType a name or spell ID already in list to delete it")


    local noteCast2 = BetterBlizzPlatesSubPanel7:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteCast2:SetPoint("LEFT", BetterBlizzPlatesSubPanel7, "TOPRIGHT", -240, -20)
    noteCast2:SetText("Castbar settings")
    local castbarsettingsicon = BetterBlizzPlatesSubPanel7:CreateTexture(nil, "ARTWORK")
    castbarsettingsicon:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarsettingsicon:SetSize(24, 24)
    castbarsettingsicon:SetPoint("RIGHT", noteCast2, "LEFT", -3, 0)

    local checkBox_enableCastbarCustomization = CreateCheckbox("enableCastbarCustomization", "Enable castbar customization", BetterBlizzPlatesSubPanel7, nil, BBP.ToggleSpellCastEventRegistration)
    checkBox_enableCastbarCustomization:SetPoint("TOPLEFT", noteCast2, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    local checkBox_castBarDragonflightShield = CreateCheckbox("castBarDragonflightShield", "Dragonflight Shield on Non-Interruptable", BetterBlizzPlatesSubPanel7)
    checkBox_castBarDragonflightShield:SetPoint("TOPLEFT", checkBox_enableCastbarCustomization, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- cast bar icon size
    local castBarIconScaleSlider = CreateSlider("BetterBlizzPlates_castBarIconScaleSlider", BetterBlizzPlatesSubPanel7, "Castbar Icon Size", 0.1, 2.5, 0.1, "castBarIcon")
    castBarIconScaleSlider:SetPoint("TOPLEFT", checkBox_castBarDragonflightShield, "BOTTOMLEFT", 12, -10)
    castBarIconScaleSlider:SetValue(BetterBlizzPlatesDB.castBarIconScale or 1)

    local castBarIconXPosSlider = CreateSlider("BetterBlizzPlates_castBarIconXPosSlider", BetterBlizzPlatesSubPanel7, "x offset", -50, 50, 1, "castBarIcon", "X")
    castBarIconXPosSlider:SetPoint("TOPLEFT", castBarIconScaleSlider, "BOTTOMLEFT", 0, -15)
    castBarIconXPosSlider:SetValue(BetterBlizzPlatesDB.castBarIconXPos or 0)

    local castBarIconYPosSlider = CreateSlider("BetterBlizzPlates_castBarIconYPosSlider", BetterBlizzPlatesSubPanel7, "y offset", -50, 50, 1, "castBarIcon", "Y")
    castBarIconYPosSlider:SetPoint("TOPLEFT", castBarIconXPosSlider, "BOTTOMLEFT", 0, -15)
    castBarIconYPosSlider:SetValue(BetterBlizzPlatesDB.castBarIconYPos or 0)


    -- cast bar height
    local castBarHeightSlider = CreateSlider("BetterBlizzPlates_castBarHeightSlider", BetterBlizzPlatesSubPanel7, "Castbar height", 4, 36, 0.1, "castBarHeight", "Height")
    castBarHeightSlider:SetPoint("TOPLEFT", castBarIconYPosSlider, "BOTTOMLEFT", 0, -15)
    if BBP.isLargeNameplatesEnabled() then
        castBarHeightSlider:SetValue(BetterBlizzPlatesDB.castBarHeight or 18.8)
    else
        castBarHeightSlider:SetValue(BetterBlizzPlatesDB.castBarHeight or 8)
    end    
    -- Reset button for nameplateSelectedScale slider
    local btn_reset_castBarHeight = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel7, "UIPanelButtonTemplate")
    btn_reset_castBarHeight:SetText("Default")
    btn_reset_castBarHeight:SetWidth(60)
    btn_reset_castBarHeight:SetPoint("LEFT", castBarHeightSlider, "RIGHT", 10, 0)
    btn_reset_castBarHeight:SetScript("OnClick", function()
        BBP.ResetToDefaultHeight(castBarHeightSlider)
    end)


    -- cast bar text size
    local castBarTextScaleSlider = CreateSlider("BetterBlizzPlates_castBarTextScaleSlider", BetterBlizzPlatesSubPanel7, "Castbar text size", 0.5, 2.5, 0.1, "castBarText")
    castBarTextScaleSlider:SetPoint("TOPLEFT", castBarHeightSlider, "BOTTOMLEFT", 0, -15)
    castBarTextScaleSlider:SetValue(BetterBlizzPlatesDB.castBarTextScale or 1)


    local noteCast3 = BetterBlizzPlatesSubPanel7:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteCast3:SetPoint("LEFT", BetterBlizzPlatesSubPanel7, "TOPRIGHT", -240, -260)
    noteCast3:SetText("Castbar emphasis settings")
    local castbarsettingsicon2 = BetterBlizzPlatesSubPanel7:CreateTexture(nil, "ARTWORK")
    castbarsettingsicon2:SetAtlas("powerswirlanimation-starburst-soulbinds")
    castbarsettingsicon2:SetSize(36, 36)
    castbarsettingsicon2:SetVertexColor(1,0,0)
    castbarsettingsicon2:SetPoint("RIGHT", noteCast3, "LEFT", 5, 0)


    local checkBox_enableCastbarEmphasis = CreateCheckbox("enableCastbarEmphasis", "Cast Emphasis", BetterBlizzPlatesSubPanel7)
    CreateTooltip(checkBox_enableCastbarEmphasis, "Customize castbar for spells in the list")
    checkBox_enableCastbarEmphasis:SetPoint("TOPLEFT", noteCast3, "BOTTOMLEFT", 0, pixelsOnFirstBox)

    local checkBox_castBarEmphasisOnlyInterruptable = CreateCheckbox("castBarEmphasisOnlyInterruptable", "Only emphasize interruptable casts", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisOnlyInterruptable:SetPoint("TOPLEFT", checkBox_enableCastbarEmphasis, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_castBarEmphasisColor = CreateCheckbox("castBarEmphasisColor", "Cast Emphasis: Color castbar", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisColor:SetPoint("TOPLEFT", checkBox_castBarEmphasisOnlyInterruptable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_castBarEmphasisHeight = CreateCheckbox("castBarEmphasisHeight", "Cast Emphasis: Height", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisHeight:SetPoint("TOPLEFT", checkBox_castBarEmphasisColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_castBarEmphasisIcon = CreateCheckbox("castBarEmphasisIcon", "Cast Emphasis: Icon Size", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisIcon:SetPoint("TOPLEFT", checkBox_castBarEmphasisHeight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_castBarEmphasisText = CreateCheckbox("castBarEmphasisText", "Cast Emphasis: Text Size", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisText:SetPoint("TOPLEFT", checkBox_castBarEmphasisIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_castBarEmphasisSpark = CreateCheckbox("castBarEmphasisSpark", "Cast Emphasis: Spark", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisSpark:SetPoint("TOPLEFT", checkBox_castBarEmphasisText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_castBarEmphasisHealthbarColor = CreateCheckbox("castBarEmphasisHealthbarColor", "Cast Emphasis: Color healthbar", checkBox_enableCastbarEmphasis)
    checkBox_castBarEmphasisHealthbarColor:SetPoint("TOPLEFT", checkBox_castBarEmphasisSpark, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    -- cast bar height
    local castBarEmphasisHeightValueSlider = CreateSlider("BetterBlizzPlates_castBarEmphasisHeightValueSlider", checkBox_enableCastbarEmphasis, "Emphasis height", 4, 40, 0.1, "castBarEmphasisHeightValue", "Height")
    castBarEmphasisHeightValueSlider:SetPoint("TOPLEFT", checkBox_castBarEmphasisHealthbarColor, "BOTTOMLEFT", 10, -10)
    if BBP.isLargeNameplatesEnabled() then
        castBarEmphasisHeightValueSlider:SetValue(BetterBlizzPlatesDB.castBarEmphasisHeightValue or 24)
    else
        castBarEmphasisHeightValueSlider:SetValue(BetterBlizzPlatesDB.castBarEmphasisHeightValue or 18)
    end

    -- cast bar icon size
    local castBarEmphasisIconScaleScaleSlider = CreateSlider("BetterBlizzPlates_castBarEmphasisIconScaleScaleSlider", checkBox_enableCastbarEmphasis, "Emphasis Icon Size", 1, 3, 0.1, "castBarEmphasisIcon")
    castBarEmphasisIconScaleScaleSlider:SetPoint("TOPLEFT", castBarEmphasisHeightValueSlider, "BOTTOMLEFT", 0, -15)
    castBarEmphasisIconScaleScaleSlider:SetValue(BetterBlizzPlatesDB.castBarEmphasisIconScale or 2)



    -- cast bar text size
    local castBarEmphasisTextScaleSlider = CreateSlider("BetterBlizzPlates_castBarEmphasisTextScaleSlider", checkBox_enableCastbarEmphasis, "Emphasis text size", 0.5, 2.5, 0.1, "castBarEmphasisText")
    castBarEmphasisTextScaleSlider:SetPoint("TOPLEFT", castBarEmphasisIconScaleScaleSlider, "BOTTOMLEFT", 0, -15)
    castBarEmphasisTextScaleSlider:SetValue(BetterBlizzPlatesDB.castBarEmphasisTextScale or 1)

    -- cast bar spark
    local castBarEmphasisSparkHeightSlider = CreateSlider("BetterBlizzPlates_castBarEmphasisSparkHeightSlider", checkBox_enableCastbarEmphasis, "Emphasis Spark Size", 25, 60, 1, "castBarEmphasisSpark", "Height")
    castBarEmphasisSparkHeightSlider:SetPoint("TOPLEFT", castBarEmphasisTextScaleSlider, "BOTTOMLEFT", 0, -15)
    castBarEmphasisSparkHeightSlider:SetValue(4 + BetterBlizzPlatesDB.castBarEmphasisSparkHeight)





    local function handleVisibility()
        if BetterBlizzPlatesDB.enableCastbarCustomization then
            listFrame:SetAlpha(1)
            noteCast3:SetAlpha(1)
            btn_reset_castBarHeight:Enable()
            btn_reset_castBarHeight:SetAlpha(1.0)
            castBarIconScaleSlider:Enable()
            castBarIconScaleSlider:SetAlpha(1.0)
            castBarHeightSlider:Enable()
            castBarHeightSlider:SetAlpha(1.0)
            castBarTextScaleSlider:Enable()
            castBarTextScaleSlider:SetAlpha(1.0)
            checkBox_enableCastbarEmphasis:Enable()
            checkBox_enableCastbarEmphasis:SetAlpha(1.0)
            checkBox_castBarDragonflightShield:Enable()
            checkBox_castBarDragonflightShield:SetAlpha(1.0)
            castBarIconXPosSlider:Enable()
            castBarIconXPosSlider:SetAlpha(1.0)
            castBarIconYPosSlider:Enable()
            castBarIconYPosSlider:SetAlpha(1.0)
            checkBox_castBarEmphasisOnlyInterruptable:Enable()
            checkBox_castBarEmphasisOnlyInterruptable:SetAlpha(1.0)
            checkBox_castBarEmphasisColor:Enable()
            checkBox_castBarEmphasisColor:SetAlpha(1.0)
            checkBox_castBarEmphasisIcon:Enable()
            checkBox_castBarEmphasisIcon:SetAlpha(1.0)
            checkBox_castBarEmphasisText:Enable()
            checkBox_castBarEmphasisText:SetAlpha(1.0)
            checkBox_castBarEmphasisHeight:Enable()
            checkBox_castBarEmphasisHeight:SetAlpha(1.0)
            checkBox_castBarEmphasisSpark:Enable()
            checkBox_castBarEmphasisSpark:SetAlpha(1.0)
            checkBox_castBarEmphasisHealthbarColor:Enable()
            checkBox_castBarEmphasisHealthbarColor:SetAlpha(1.0)
            castBarEmphasisIconScaleScaleSlider:Enable()
            castBarEmphasisIconScaleScaleSlider:SetAlpha(1.0)
            castBarEmphasisHeightValueSlider:Enable()
            castBarEmphasisHeightValueSlider:SetAlpha(1.0)
            castBarEmphasisTextScaleSlider:Enable()
            castBarEmphasisTextScaleSlider:SetAlpha(1.0)
            castBarEmphasisSparkHeightSlider:Enable()
            castBarEmphasisSparkHeightSlider:SetAlpha(1.0)
        else
            listFrame:SetAlpha(0.5)
            noteCast3:SetAlpha(0.5)
            btn_reset_castBarHeight:Disable()
            btn_reset_castBarHeight:SetAlpha(0.5)
            castBarIconScaleSlider:Disable()
            castBarIconScaleSlider:SetAlpha(0.5)
            castBarHeightSlider:Disable()
            castBarHeightSlider:SetAlpha(0.5)
            castBarTextScaleSlider:Disable()
            castBarTextScaleSlider:SetAlpha(0.5)
            checkBox_enableCastbarEmphasis:Disable()
            checkBox_enableCastbarEmphasis:SetAlpha(0.5)
            checkBox_castBarDragonflightShield:Disable()
            checkBox_castBarDragonflightShield:SetAlpha(0.5)
            castBarIconXPosSlider:Disable()
            castBarIconXPosSlider:SetAlpha(0.5)
            castBarIconYPosSlider:Disable()
            castBarIconYPosSlider:SetAlpha(0.5)
            checkBox_castBarEmphasisOnlyInterruptable:Disable()
            checkBox_castBarEmphasisOnlyInterruptable:SetAlpha(0.5)
            checkBox_castBarEmphasisColor:Disable()
            checkBox_castBarEmphasisColor:SetAlpha(0.5)
            checkBox_castBarEmphasisIcon:Disable()
            checkBox_castBarEmphasisIcon:SetAlpha(0.5)
            checkBox_castBarEmphasisText:Disable()
            checkBox_castBarEmphasisText:SetAlpha(0.5)
            checkBox_castBarEmphasisHeight:Disable()
            checkBox_castBarEmphasisHeight:SetAlpha(0.5)
            checkBox_castBarEmphasisSpark:Disable()
            checkBox_castBarEmphasisSpark:SetAlpha(0.5)
            checkBox_castBarEmphasisHealthbarColor:Disable()
            checkBox_castBarEmphasisHealthbarColor:SetAlpha(0.5)
            castBarEmphasisIconScaleScaleSlider:Disable()
            castBarEmphasisIconScaleScaleSlider:SetAlpha(0.5)
            castBarEmphasisHeightValueSlider:Disable()
            castBarEmphasisHeightValueSlider:SetAlpha(0.5)
            castBarEmphasisTextScaleSlider:Disable()
            castBarEmphasisTextScaleSlider:SetAlpha(0.5)
            castBarEmphasisSparkHeightSlider:Disable()
            castBarEmphasisSparkHeightSlider:SetAlpha(0.5)
        end
    end

    checkBox_enableCastbarCustomization:HookScript("OnClick", function(_, btn, down)
        handleVisibility()
    end)









    checkBox_enableCastbarEmphasis:HookScript("OnClick", function(_, btn, down)
        if BetterBlizzPlatesDB.enableCastbarEmphasis then
            EnableCheckboxes(checkBox_enableCastbarEmphasis)
        else
            DisableCheckboxes(checkBox_enableCastbarEmphasis)
        end
    end)
    if BetterBlizzPlatesDB.enableCastbarEmphasis then
        EnableCheckboxes(checkBox_enableCastbarEmphasis)
    else
        DisableCheckboxes(checkBox_enableCastbarEmphasis)
    end









    handleVisibility()
end

local function guiHideCastbar()
        ------------------------------------------------------------------------------------------------
    -- Hide Cast
    ------------------------------------------------------------------------------------------------
    -- Hide Cast
    local BetterBlizzPlatesSubPanel9 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel9.name = "Hide Castbar"
    BetterBlizzPlatesSubPanel9.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel9)

    -- Create the background texture
    local bgTexture4 = BetterBlizzPlatesSubPanel9:CreateTexture(nil, "BACKGROUND")
    bgTexture4:SetAtlas("professions-recipe-background")
    bgTexture4:SetPoint("CENTER", BetterBlizzPlatesSubPanel9, "CENTER", -8, 4)
    bgTexture4:SetSize(680, 610)
    bgTexture4:SetAlpha(0.4)
    bgTexture4:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor4 = BetterBlizzPlatesSubPanel9:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor4:SetPoint("TOPLEFT", 15, 20)
    mainGuiAnchor4:SetText(" ")

    local listFrame = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel9)
    listFrame:SetAllPoints(BetterBlizzPlatesSubPanel9)

    local how2useHide = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2useHide:SetPoint("TOP", mainGuiAnchor4, "BOTTOM", 140, -450)
    how2useHide:SetText("Add spell name, spell ID, npc name or npc ID\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or spell ID already in list to delete it")

    local noteHide = BetterBlizzPlatesSubPanel9:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteHide:SetPoint("TOP", BetterBlizzPlatesSubPanel9, "TOP", 172, -127)
    noteHide:SetText("Hide the castbar for chosen spells,\nor only show whitelisted ones.")

    -- Hide Cast list
    local checkBox_hideCastbar = CreateCheckbox("hideCastbar", "Enable Hide Castbar", BetterBlizzPlatesSubPanel9, nil, BBP.HideCastbar)
    checkBox_hideCastbar:SetPoint("TOPLEFT", noteHide, "BOTTOMLEFT", 25, -15)
    checkBox_hideCastbar:HookScript("OnClick", function(_, btn, down)
        BBP.ToggleSpellCastEventRegistration()
    end)
    CreateTooltip(checkBox_hideCastbar, "Hide the castbar for chosen spells,\nor only show whitelisted ones.")


    local hideCastbarFrame = CreateFrame("Frame", nil, listFrame)
    hideCastbarFrame:SetSize(322, 390)
    hideCastbarFrame:SetPoint("TOPLEFT", 0, 0)

    local hideCastbarWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    hideCastbarWhitelistFrame:SetSize(322, 390)
    hideCastbarWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = hideCastbarWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", hideCastbarWhitelistFrame, "TOP", 0, -5)
    whitelistOnText:SetText("Whitelist ON")

    -- Create the lists using the CreateList function
    CreateList(hideCastbarFrame, "hideCastbarList", BetterBlizzPlatesDB.hideCastbarList, BBP.RefreshAllNameplates, false)
    CreateList(hideCastbarWhitelistFrame, "hideCastbarWhitelist", BetterBlizzPlatesDB.hideCastbarWhitelist, BBP.RefreshAllNameplates, false)

    -- Whitelist Hide Cast list
    local checkBox_hideCastbarWhitelist = CreateCheckbox("hideCastbarWhitelistOn", "Whitelist mode", BetterBlizzPlatesSubPanel9, nil, BBP.HideCastbar)
    checkBox_hideCastbarWhitelist:SetPoint("TOPLEFT", checkBox_hideCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_hideCastbarWhitelist, "Hide castbar for ALL spells except the ones in the whitelist")

    local checkBox_showCastbarIfTarget = CreateCheckbox("showCastbarIfTarget", "Always show castbar on target", BetterBlizzPlatesSubPanel9, nil, BBP.HideCastbar)
    checkBox_showCastbarIfTarget:SetPoint("TOPLEFT", checkBox_hideCastbarWhitelist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_onlyShowInterruptableCasts = CreateCheckbox("onlyShowInterruptableCasts", "Only show interruptable casts", BetterBlizzPlatesSubPanel9, nil, BBP.HideCastbar)
    checkBox_onlyShowInterruptableCasts:SetPoint("TOPLEFT", checkBox_showCastbarIfTarget, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_hideNpcCastbar = CreateCheckbox("hideNpcCastbar", "Hide all NPC castbars", BetterBlizzPlatesSubPanel9, nil, BBP.HideCastbar)
    checkBox_hideNpcCastbar:SetPoint("TOPLEFT", checkBox_onlyShowInterruptableCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_hideNpcCastbar, "Hide all NPC castbars (except whitelisted ones).")

    local function handleVisibility()
        if BetterBlizzPlatesDB.hideCastbarWhitelistOn then
            hideCastbarFrame:Hide()
            hideCastbarWhitelistFrame:Show()
        else
            hideCastbarFrame:Show()
            hideCastbarWhitelistFrame:Hide()
        end
    end
    checkBox_hideCastbarWhitelist:HookScript("OnClick", function(_, btn, down)
        handleVisibility()
    end)
    handleVisibility()

    local function handleVisibility2()
        if BetterBlizzPlatesDB.hideCastbar then
            listFrame:SetAlpha(1)
            how2useHide:SetAlpha(1)
            checkBox_hideCastbarWhitelist:SetAlpha(1)
            checkBox_hideCastbarWhitelist:Enable()
            checkBox_showCastbarIfTarget:SetAlpha(1)
            checkBox_showCastbarIfTarget:Enable()
            checkBox_onlyShowInterruptableCasts:SetAlpha(1)
            checkBox_onlyShowInterruptableCasts:Enable()
            checkBox_hideNpcCastbar:SetAlpha(1)
            checkBox_hideNpcCastbar:Enable()
        else
            listFrame:SetAlpha(0.5)
            how2useHide:SetAlpha(0.5)
            checkBox_hideCastbarWhitelist:SetAlpha(0.5)
            checkBox_hideCastbarWhitelist:Disable()
            checkBox_showCastbarIfTarget:SetAlpha(0.5)
            checkBox_showCastbarIfTarget:Disable()
            checkBox_onlyShowInterruptableCasts:SetAlpha(0.5)
            checkBox_onlyShowInterruptableCasts:Disable()
            checkBox_hideNpcCastbar:SetAlpha(0.5)
            checkBox_hideNpcCastbar:Disable()
        end
    end
    checkBox_hideCastbar:HookScript("OnClick", function(_, btn, down)
        handleVisibility2()
    end)
    handleVisibility2()
end

local function guiFadeNPC()
    ------------------------------------------------------------------------------------------------
    -- Fade out NPC
    ------------------------------------------------------------------------------------------------
    -- Fade out NPC
    local BetterBlizzPlatesSubPanel2 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel2.name = "Fade NPC"
    BetterBlizzPlatesSubPanel2.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel2)

    -- Create the background texture
    local bgTexture3 = BetterBlizzPlatesSubPanel2:CreateTexture(nil, "BACKGROUND")
    bgTexture3:SetAtlas("professions-recipe-background")
    bgTexture3:SetPoint("CENTER", BetterBlizzPlatesSubPanel2, "CENTER", -8, 4)
    bgTexture3:SetSize(680, 610)
    bgTexture3:SetAlpha(0.4)
    bgTexture3:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor3 = BetterBlizzPlatesSubPanel2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor3:SetPoint("TOPLEFT", 15, 20)
    mainGuiAnchor3:SetText(" ")

    local listFrame = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel2)
    listFrame:SetAllPoints(BetterBlizzPlatesSubPanel2)
    CreateList(listFrame, "fadeOutNPCsList", BetterBlizzPlatesDB.fadeOutNPCsList, BBP.RefreshAllNameplates, false)

    local how2usefade = BetterBlizzPlatesSubPanel2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2usefade:SetPoint("TOP", mainGuiAnchor3, "BOTTOM", 140, -450)
    how2usefade:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    -- fade out nameplate alpha slider
    local fadeOutNPCsAlphaSlider = CreateSlider("BetterBlizzPlates_fadeOutNPCsAlphaSlider", BetterBlizzPlatesSubPanel2, "Alpha value", 0, 1, 0.05, "fadeOutNPCsAlpha", "Alpha")
    fadeOutNPCsAlphaSlider:SetPoint("TOPRIGHT", BetterBlizzPlatesSubPanel2, "TOPRIGHT", -90, -90)
    fadeOutNPCsAlphaSlider:SetValue(BetterBlizzPlatesDB.fadeOutNPCsAlpha or 0.2)



    -- made an oopsie here after changing some stuff fix later

    -- Restore default entries
    --local restoreDefaultsButton = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel2, "UIPanelButtonTemplate")
    --restoreDefaultsButton:SetSize(150, 30)
    --restoreDefaultsButton:SetPoint("BOTTOM", fadeOutNPCsAlphaSlider, "TOP", 0, 30)
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





    local noteFade = BetterBlizzPlatesSubPanel2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteFade:SetPoint("TOP", fadeOutNPCsAlphaSlider, "BOTTOM", 0, -20)
    noteFade:SetText("This makes nameplates transparent.\n \nYou will still be able to click them\neven though you can't see them.\n \nIf you wish to completely get rid of a\nnameplate use Hide NPC list instead")

    -- Fade out unimportant npcs in arena
    local checkBox_fadeOutNPCs2 = CreateCheckbox("fadeOutNPC", "Enable Fade NPC", BetterBlizzPlatesSubPanel2, nil, BBP.FadeOutNPCs)
    checkBox_fadeOutNPCs2:SetPoint("TOPLEFT", noteFade, "BOTTOMLEFT", 20, -15)

    local function handleVisibility()
        if BetterBlizzPlatesDB.fadeOutNPC then
            listFrame:SetAlpha(1)
            how2usefade:SetAlpha(1)
            fadeOutNPCsAlphaSlider:SetAlpha(1)
            fadeOutNPCsAlphaSlider:Enable()
        else
            listFrame:SetAlpha(0.5)
            how2usefade:SetAlpha(0.5)
            fadeOutNPCsAlphaSlider:SetAlpha(0.5)
            fadeOutNPCsAlphaSlider:Disable()
        end
    end
    checkBox_fadeOutNPCs2:HookScript("OnClick", function(_, btn, down)
        handleVisibility()
    end)
    handleVisibility()
end

local function guiHideNPC()
        ------------------------------------------------------------------------------------------------
    -- Hide NPC
    ------------------------------------------------------------------------------------------------
    -- Hide NPC
    local BetterBlizzPlatesSubPanel3 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel3.name = "Hide NPC"
    BetterBlizzPlatesSubPanel3.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel3)

    -- Create the background texture
    local bgTexture4 = BetterBlizzPlatesSubPanel3:CreateTexture(nil, "BACKGROUND")
    bgTexture4:SetAtlas("professions-recipe-background")
    bgTexture4:SetPoint("CENTER", BetterBlizzPlatesSubPanel3, "CENTER", -8, 4)
    bgTexture4:SetSize(680, 610)
    bgTexture4:SetAlpha(0.4)
    bgTexture4:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor4 = BetterBlizzPlatesSubPanel3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor4:SetPoint("TOPLEFT", 15, 20)
    mainGuiAnchor4:SetText(" ")







    local how2useHide = BetterBlizzPlatesSubPanel3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2useHide:SetPoint("TOP", mainGuiAnchor4, "BOTTOM", 140, -450)
    how2useHide:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    local noteHide = BetterBlizzPlatesSubPanel3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteHide:SetPoint("TOP", BetterBlizzPlatesSubPanel3, "TOP", 172, -127)
    noteHide:SetText("This completely hides nameplates.\n \nYou will not be able to click them\n \nIf you wish to fade out and still be able\nto click them use Fade NPC instead")


    -- Hide NPC list
    local checkBox_hideNPCs = CreateCheckbox("hideNPC", "Enable Hide NPC", BetterBlizzPlatesSubPanel3, nil, BBP.HideNPCs)
    checkBox_hideNPCs:SetPoint("TOPLEFT", noteHide, "BOTTOMLEFT", 25, -15)
    CreateTooltip(checkBox_hideNPCs, "Hide NPC's from the blacklist\nOr only show the ones in whitelist with whitelist mode.")

    local listFrame = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel3)
    listFrame:SetAllPoints(BetterBlizzPlatesSubPanel3)

    local hideNPCsListFrame = CreateFrame("Frame", nil, listFrame)
    hideNPCsListFrame:SetSize(322, 390)
    hideNPCsListFrame:SetPoint("TOPLEFT", 0, 0)

    local hideNPCsWhitelistFrame = CreateFrame("Frame", nil, listFrame)
    hideNPCsWhitelistFrame:SetSize(322, 390)
    hideNPCsWhitelistFrame:SetPoint("TOPLEFT", 0, 0)

    local whitelistOnText = hideNPCsWhitelistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistOnText:SetPoint("BOTTOM", hideNPCsWhitelistFrame, "TOP", 0, 0)
    whitelistOnText:SetText("Whitelist ON")

    -- Create the lists using the CreateList function
    CreateList(hideNPCsListFrame, "hideNPCsList", BetterBlizzPlatesDB.hideNPCsList, BBP.RefreshAllNameplates, false)
    CreateList(hideNPCsWhitelistFrame, "hideNPCsWhitelist", BetterBlizzPlatesDB.hideNPCsWhitelist, BBP.RefreshAllNameplates, false)

    -- Whitelist Hide NPC list
    local checkBox_hideNPCsWhitelist = CreateCheckbox("hideNPCWhitelistOn", "Whitelist mode", checkBox_hideNPCs, nil, BBP.HideNPCs)
    checkBox_hideNPCsWhitelist:SetPoint("TOPLEFT", checkBox_hideNPCs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_hideNPCsWhitelist, "Hides ALL NPC's except the ones in the whitelist")

    local function handleVisibility()
        if BetterBlizzPlatesDB.hideNPCWhitelistOn then
            hideNPCsListFrame:Hide()
            hideNPCsWhitelistFrame:Show()
        else
            hideNPCsListFrame:Show()
            hideNPCsWhitelistFrame:Hide()
        end
    end
    checkBox_hideNPCsWhitelist:HookScript("OnClick", function(_, btn, down)
        handleVisibility()
    end)
    handleVisibility()

    -- Only hide npcs in arena
    local checkBox_hideNPCsArena = CreateCheckbox("hideNPCArenaOnly", "Only hide NPCs in arena", checkBox_hideNPCs, nil, BBP.HideNPCs)
    checkBox_hideNPCsArena:SetPoint("TOPLEFT", checkBox_hideNPCsWhitelist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local function handleVisibility2()
        if BetterBlizzPlatesDB.hideNPC then
            listFrame:SetAlpha(1)
            how2useHide:SetAlpha(1)
            checkBox_hideNPCsWhitelist:SetAlpha(1)
            checkBox_hideNPCsWhitelist:Enable()
            checkBox_hideNPCsArena:SetAlpha(1)
            checkBox_hideNPCsArena:Enable()
        else
            listFrame:SetAlpha(0.5)
            how2useHide:SetAlpha(0.5)
            checkBox_hideNPCsWhitelist:SetAlpha(0.5)
            checkBox_hideNPCsWhitelist:Disable()
            checkBox_hideNPCsArena:SetAlpha(0.5)
            checkBox_hideNPCsArena:Disable()
        end
    end
    checkBox_hideNPCs:HookScript("OnClick", function(_, btn, down)
        handleVisibility2()
    end)
    handleVisibility2()
end

local function guiColorNPC()
        ------------------------------------------------------------------------------------------------
    -- Color NPC
    ------------------------------------------------------------------------------------------------
    -- Color NPC
    local BetterBlizzPlatesSubPanel4 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel4.name = "Color NPC"
    BetterBlizzPlatesSubPanel4.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel4)

    -- Create the background texture
    local bgTexture5 = BetterBlizzPlatesSubPanel4:CreateTexture(nil, "BACKGROUND")
    bgTexture5:SetAtlas("professions-recipe-background")
    bgTexture5:SetPoint("CENTER", BetterBlizzPlatesSubPanel4, "CENTER", -8, 4)
    bgTexture5:SetSize(680, 610)
    bgTexture5:SetAlpha(0.4)
    bgTexture5:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor5 = BetterBlizzPlatesSubPanel4:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor5:SetPoint("TOPLEFT", 15, 20)
    mainGuiAnchor5:SetText(" ")

    local listFrame = CreateFrame("Frame", nil, BetterBlizzPlatesSubPanel4)
    listFrame:SetAllPoints(BetterBlizzPlatesSubPanel4)


    CreateList(listFrame, "colorNpcList", BetterBlizzPlatesDB.colorNpcList, BBP.RefreshAllNameplates, true)


    local how2UseColor = BetterBlizzPlatesSubPanel4:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    how2UseColor:SetPoint("TOP", mainGuiAnchor5, "BOTTOM", 140, -450)
    how2UseColor:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

    local noteColor = BetterBlizzPlatesSubPanel4:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noteColor:SetPoint("TOP", BetterBlizzPlatesSubPanel4, "TOP", 172, -127)
    noteColor:SetText("This colors specific nameplates.\n \nAdd a name/npc ID and select a color")


    -- Color NPC list
    local checkBox_colorNPCs = CreateCheckbox("colorNPC", "Enable NPC Color", BetterBlizzPlatesSubPanel4, nil, BBP.colorNPC)
    checkBox_colorNPCs:SetPoint("TOPLEFT", noteColor, "BOTTOMLEFT", 25, -15)
    CreateTooltip(checkBox_colorNPCs, "Color NPC's from the list a color of your choice.\nClick color button after adding the NPC to the list to chose color.")

    -- Color NPC name
    local checkBox_colorNPCName = CreateCheckbox("colorNPCName", "Also color name text", checkBox_colorNPCs, nil, BBP.colorNPC)
    checkBox_colorNPCName:SetPoint("TOPLEFT", checkBox_colorNPCs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)


    local btn_reload_ui3 = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel4, "UIPanelButtonTemplate")
    btn_reload_ui3:SetText("Reload UI")
    btn_reload_ui3:SetWidth(85)
    btn_reload_ui3:SetPoint("TOP", BetterBlizzPlatesSubPanel4, "BOTTOMRIGHT", -140, -9)
    btn_reload_ui3:SetScript("OnClick", function()
        BetterBlizzPlatesDB.reopenOptions = true
        ReloadUI()
    end)

    local function handleVisibility()
        if BetterBlizzPlatesDB.colorNPC then
            listFrame:SetAlpha(1)
            how2UseColor:SetAlpha(1)
            checkBox_colorNPCName:SetAlpha(1)
            checkBox_colorNPCName:Enable()
        else
            listFrame:SetAlpha(0.5)
            how2UseColor:SetAlpha(0.5)
            checkBox_colorNPCName:SetAlpha(0.5)
            checkBox_colorNPCName:Disable()
        end
    end
    checkBox_colorNPCs:HookScript("OnClick", function(_, btn, down)
        handleVisibility()
    end)
    handleVisibility()
end

local function guiMoreBlizzSettings()
        ------------------------------------------------------------------------------------------------
    -- More Blizz Settings
    ------------------------------------------------------------------------------------------------
    -- More Blizz Settings
    local BetterBlizzPlatesSubPanel5 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel5.name = "More Blizz Settings"
    BetterBlizzPlatesSubPanel5.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel5)

    -- Create the background texture
    local bgTexture6 = BetterBlizzPlatesSubPanel5:CreateTexture(nil, "BACKGROUND")
    bgTexture6:SetAtlas("professions-recipe-background")
    bgTexture6:SetPoint("CENTER", BetterBlizzPlatesSubPanel5, "CENTER", -8, 4)
    bgTexture6:SetSize(680, 610)
    bgTexture6:SetAlpha(0.4)
    bgTexture6:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor6 = BetterBlizzPlatesSubPanel5:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor6:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor6:SetText(" ")

    local moreBlizzSettings = BetterBlizzPlatesSubPanel5:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettings:SetPoint("TOPLEFT", mainGuiAnchor6, "TOPLEFT", -10, 10)
    moreBlizzSettings:SetText("Settings not available in Blizzard's standard UI")

    local stackingNameplatesText = BetterBlizzPlatesSubPanel5:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackingNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor6, "BOTTOMLEFT", 0, -5)
    stackingNameplatesText:SetText("Stacking nameplate overlap amount")

    -- Nameplate Horizontal Overlap
    local stackingNameplateOverlapHorizontal = CreateSlider("BetterBlizzPlates_nameplateOverlapH", BetterBlizzPlatesSubPanel5, "Horizontal overlap", 0.05, 1, 0.05, "nameplateOverlapH")
    stackingNameplateOverlapHorizontal:SetPoint("TOP", stackingNameplatesText, "BOTTOM", 0, -20)
    CreateTooltip(stackingNameplateOverlapHorizontal, "Space between nameplates horizontally")
    FetchCVarWhenLoaded("nameplateOverlapH", function(value)
        stackingNameplateOverlapHorizontal:SetValue(BetterBlizzPlatesDB.nameplateOverlapH or value)
    end)

    local btn_reset_nameplateOverlapH = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel5, "UIPanelButtonTemplate")
    btn_reset_nameplateOverlapH:SetText("Default")
    btn_reset_nameplateOverlapH:SetWidth(60)
    btn_reset_nameplateOverlapH:SetPoint("LEFT", stackingNameplateOverlapHorizontal, "RIGHT", 10, 0)
    btn_reset_nameplateOverlapH:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(stackingNameplateOverlapHorizontal, "nameplateOverlapH")
    end)

    -- Nameplate Vertical Overlap
    local stackingNameplateOverlapVertical = CreateSlider("BetterBlizzPlates_nameplateOverlapV", BetterBlizzPlatesSubPanel5, "Vertical overlap", 0.05, 1.1, 0.05, "nameplateOverlapV")
    stackingNameplateOverlapVertical:SetPoint("TOPLEFT", stackingNameplateOverlapHorizontal, "BOTTOMLEFT", 0, -20)
    CreateTooltip(stackingNameplateOverlapVertical, "Space between nameplates vertically")
    FetchCVarWhenLoaded("nameplateOverlapV", function(value)
        stackingNameplateOverlapVertical:SetValue(BetterBlizzPlatesDB.nameplateOverlapV or value)
    end)

    local btn_reset_nameplateOverlapV = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel5, "UIPanelButtonTemplate")
    btn_reset_nameplateOverlapV:SetText("Default")
    btn_reset_nameplateOverlapV:SetWidth(60)
    btn_reset_nameplateOverlapV:SetPoint("LEFT", stackingNameplateOverlapVertical, "RIGHT", 10, 0)
    btn_reset_nameplateOverlapV:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(stackingNameplateOverlapVertical, "nameplateOverlapV")
    end)

    -- Nameplate Motion Speed
    local nameplateMotionSpeed = CreateSlider("BetterBlizzPlates_nameplateMotionSpeed", BetterBlizzPlatesSubPanel5, "Nameplate motion speed", 0.01, 1, 0.01, "nameplateMotionSpeed")
    nameplateMotionSpeed:SetPoint("TOPLEFT", stackingNameplateOverlapVertical, "BOTTOMLEFT", 0, -20)
    CreateTooltip(nameplateMotionSpeed, "The speed at which nameplates move into their new position")
    FetchCVarWhenLoaded("nameplateMotionSpeed", function(value)
        nameplateMotionSpeed:SetValue(BetterBlizzPlatesDB.nameplateMotionSpeed or value)
    end)

    local btn_reset_nameplateMotionSpeed = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel5, "UIPanelButtonTemplate")
    btn_reset_nameplateMotionSpeed:SetText("Default")
    btn_reset_nameplateMotionSpeed:SetWidth(60)
    btn_reset_nameplateMotionSpeed:SetPoint("LEFT", nameplateMotionSpeed, "RIGHT", 10, 0)
    btn_reset_nameplateMotionSpeed:SetScript("OnClick", function()
        BBP.ResetToDefaultValue(nameplateMotionSpeed, "nameplateMotionSpeed")
    end)

    -- WIP text
    local moreBlizzSettings = BetterBlizzPlatesSubPanel5:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moreBlizzSettings:SetPoint("BOTTOM", BetterBlizzPlatesSubPanel5, "BOTTOM", 0, 10)
    moreBlizzSettings:SetText("Work in progress, more stuff inc soon™\n \nSome settings don't make much sense anymore because\nthe addon grew a bit more than I thought it would.\nWill clean up eventually\n \nIf you have any suggestions feel free to\nleave a comment on CurseForge")
end

local function guiNameplateAuras()
    ------------------------------------------------------------------------------------------------
    -- Nameplate Auras
    ------------------------------------------------------------------------------------------------
    -- Nameplate Auras
    local BetterBlizzPlatesSubPanel6 = CreateFrame("Frame")
    BetterBlizzPlatesSubPanel6.name = "Nameplate Auras"
    BetterBlizzPlatesSubPanel6.parent = BetterBlizzPlates.name
    InterfaceOptions_AddCategory(BetterBlizzPlatesSubPanel6)

    -- Create the background texture
    local bgTexture7 = BetterBlizzPlatesSubPanel6:CreateTexture(nil, "BACKGROUND")
    bgTexture7:SetAtlas("professions-recipe-background")
    bgTexture7:SetPoint("CENTER", BetterBlizzPlatesSubPanel6, "CENTER", -8, 4)
    bgTexture7:SetSize(680, 610)
    bgTexture7:SetAlpha(0.4)
    bgTexture7:SetVertexColor(0,0,0)

    -- Main GUI Anchor
    local mainGuiAnchor7 = BetterBlizzPlatesSubPanel6:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor7:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor7:SetText(" ")

    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzPlatesSubPanel6, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzPlatesSubPanel6, "CENTER", -20, 3)

    -- Create the content frame
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



    local checkBox_enableNameplateAuraCustomisation = CreateCheckbox("enableNameplateAuraCustomisation", "Enable Aura Settings (BETA)", contentFrame)
    checkBox_enableNameplateAuraCustomisation:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 75)


    local checkBox_otherNpBuffEnable = CreateCheckbox("otherNpBuffEnable", "Show BUFFS", contentFrame)
    checkBox_otherNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 25)

    local bigEnemyBorderText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText:SetPoint("LEFT", checkBox_otherNpBuffEnable, "CENTER", 0, 25)
    bigEnemyBorderText:SetText("Enemy Nameplates")
    local enemyNameplateIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon2:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon2:SetSize(28, 28)
    enemyNameplateIcon2:SetPoint("RIGHT", bigEnemyBorderText, "LEFT", -3, 0)
    enemyNameplateIcon2:SetDesaturated(1)
    enemyNameplateIcon2:SetVertexColor(1, 0, 0)

    local checkBox_otherNpBuffFilterAll = CreateCheckbox("otherNpBuffFilterAll", "All", contentFrame)
    checkBox_otherNpBuffFilterAll:SetPoint("TOPLEFT", checkBox_otherNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_otherNpBuffFilterWatchList = CreateCheckbox("otherNpBuffFilterWatchList", "Whitelist", contentFrame)
    CreateTooltip(checkBox_otherNpBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    checkBox_otherNpBuffFilterWatchList:SetPoint("TOPLEFT", checkBox_otherNpBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpBuffFilterLessMinite = CreateCheckbox("otherNpBuffFilterLessMinite", "Under one min", contentFrame)
    checkBox_otherNpBuffFilterLessMinite:SetPoint("TOPLEFT", checkBox_otherNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpBuffFilterPurgeable = CreateCheckbox("otherNpBuffFilterPurgeable", "Purgeable", contentFrame)
    checkBox_otherNpBuffFilterPurgeable:SetPoint("TOPLEFT", checkBox_otherNpBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpBuffPurgeGlow = CreateCheckbox("otherNpBuffPurgeGlow", "Glow on purgeable buffs", contentFrame)
    checkBox_otherNpBuffPurgeGlow:SetPoint("TOPLEFT", checkBox_otherNpBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpBuffBlueBorder = CreateCheckbox("otherNpBuffBlueBorder", "Blue border on buffs", contentFrame)
    checkBox_otherNpBuffBlueBorder:SetPoint("TOPLEFT", checkBox_otherNpBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpBuffEmphasisedBorder = CreateCheckbox("otherNpBuffEmphasisedBorder", "Red glow on whitelisted buffs", contentFrame)
    checkBox_otherNpBuffEmphasisedBorder:SetPoint("TOPLEFT", checkBox_otherNpBuffBlueBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local function ToggleOtherNpBuffCheckboxes()
        if BetterBlizzPlatesDB.otherNpBuffEnable then
            checkBox_otherNpBuffFilterAll:Enable()
            checkBox_otherNpBuffFilterAll:SetAlpha(1.0)
            checkBox_otherNpBuffFilterWatchList:Enable()
            checkBox_otherNpBuffFilterWatchList:SetAlpha(1.0)
            checkBox_otherNpBuffFilterLessMinite:Enable()
            checkBox_otherNpBuffFilterLessMinite:SetAlpha(1.0)
            checkBox_otherNpBuffFilterPurgeable:Enable()
            checkBox_otherNpBuffFilterPurgeable:SetAlpha(1.0)
            checkBox_otherNpBuffPurgeGlow:Enable()
            checkBox_otherNpBuffPurgeGlow:SetAlpha(1.0)
            checkBox_otherNpBuffBlueBorder:Enable()
            checkBox_otherNpBuffBlueBorder:SetAlpha(1.0)
            checkBox_otherNpBuffEmphasisedBorder:Enable()
            checkBox_otherNpBuffEmphasisedBorder:SetAlpha(1.0)
        else
            checkBox_otherNpBuffFilterAll:Disable()
            checkBox_otherNpBuffFilterAll:SetAlpha(0.5)
            checkBox_otherNpBuffFilterWatchList:Disable()
            checkBox_otherNpBuffFilterWatchList:SetAlpha(0.5)
            checkBox_otherNpBuffFilterLessMinite:Disable()
            checkBox_otherNpBuffFilterLessMinite:SetAlpha(0.5)
            checkBox_otherNpBuffFilterPurgeable:Disable()
            checkBox_otherNpBuffFilterPurgeable:SetAlpha(0.5)
            checkBox_otherNpBuffPurgeGlow:Disable()
            checkBox_otherNpBuffPurgeGlow:SetAlpha(0.5)
            checkBox_otherNpBuffBlueBorder:Disable()
            checkBox_otherNpBuffBlueBorder:SetAlpha(0.5)
            checkBox_otherNpBuffEmphasisedBorder:Disable()
            checkBox_otherNpBuffEmphasisedBorder:SetAlpha(0.5)
        end
    end

    checkBox_otherNpBuffEnable:HookScript("OnClick", function(_, btn, down)
        ToggleOtherNpBuffCheckboxes()
    end)
    ToggleOtherNpBuffCheckboxes()




    local checkBox_otherNpdeBuffEnable = CreateCheckbox("otherNpdeBuffEnable", "Show DEBUFFS", contentFrame)
    checkBox_otherNpdeBuffEnable:SetPoint("TOPLEFT", checkBox_otherNpBuffEmphasisedBorder, "BOTTOMLEFT", -15, -2)

    local checkBox_otherNpdeBuffFilterAll = CreateCheckbox("otherNpdeBuffFilterAll", "All", contentFrame)
    checkBox_otherNpdeBuffFilterAll:SetPoint("TOPLEFT", checkBox_otherNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_otherNpdeBuffFilterBlizzard = CreateCheckbox("otherNpdeBuffFilterBlizzard", "Blizzard Default Filter", contentFrame)
    checkBox_otherNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", checkBox_otherNpdeBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpdeBuffFilterWatchList = CreateCheckbox("otherNpdeBuffFilterWatchList", "Whitelist", contentFrame)
    CreateTooltip(checkBox_otherNpdeBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    checkBox_otherNpdeBuffFilterWatchList:SetPoint("TOPLEFT", checkBox_otherNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpdeBuffFilterLessMinite = CreateCheckbox("otherNpdeBuffFilterLessMinite", "Under one min", contentFrame)
    checkBox_otherNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", checkBox_otherNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpdeBuffFilterOnlyMe = CreateCheckbox("otherNpdeBuffFilterOnlyMe", "Only mine", contentFrame)
    checkBox_otherNpdeBuffFilterOnlyMe:SetPoint("TOPLEFT", checkBox_otherNpdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_otherNpdeBuffPandemicGlow = CreateCheckbox("otherNpdeBuffPandemicGlow", "Pandemic Glow", contentFrame)
    checkBox_otherNpdeBuffPandemicGlow:SetPoint("TOPLEFT", checkBox_otherNpdeBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(checkBox_otherNpdeBuffPandemicGlow, "Red glow on whitelisted debuffs with less than 5 seconds left.")

    local function ToggleOtherNpDebuffCheckboxes()
        if BetterBlizzPlatesDB.otherNpdeBuffEnable then
            checkBox_otherNpdeBuffFilterAll:Enable()
            checkBox_otherNpdeBuffFilterAll:SetAlpha(1.0)
            checkBox_otherNpdeBuffFilterBlizzard:Enable()
            checkBox_otherNpdeBuffFilterBlizzard:SetAlpha(1.0)
            checkBox_otherNpdeBuffFilterWatchList:Enable()
            checkBox_otherNpdeBuffFilterWatchList:SetAlpha(1.0)
            checkBox_otherNpdeBuffFilterLessMinite:Enable()
            checkBox_otherNpdeBuffFilterLessMinite:SetAlpha(1.0)
            checkBox_otherNpdeBuffFilterOnlyMe:Enable()
            checkBox_otherNpdeBuffFilterOnlyMe:SetAlpha(1.0)
            checkBox_otherNpdeBuffPandemicGlow:Enable()
            checkBox_otherNpdeBuffPandemicGlow:SetAlpha(1.0)
        else
            checkBox_otherNpdeBuffFilterAll:Disable()
            checkBox_otherNpdeBuffFilterAll:SetAlpha(0.5)
            checkBox_otherNpdeBuffFilterBlizzard:Disable()
            checkBox_otherNpdeBuffFilterBlizzard:SetAlpha(0.5)
            checkBox_otherNpdeBuffFilterWatchList:Disable()
            checkBox_otherNpdeBuffFilterWatchList:SetAlpha(0.5)
            checkBox_otherNpdeBuffFilterLessMinite:Disable()
            checkBox_otherNpdeBuffFilterLessMinite:SetAlpha(0.5)
            checkBox_otherNpdeBuffFilterOnlyMe:Disable()
            checkBox_otherNpdeBuffFilterOnlyMe:SetAlpha(0.5)
            checkBox_otherNpdeBuffPandemicGlow:Disable()
            checkBox_otherNpdeBuffPandemicGlow:SetAlpha(0.5)
        end
    end

    checkBox_otherNpdeBuffEnable:HookScript("OnClick", function(_, btn, down)
        ToggleOtherNpDebuffCheckboxes()
    end)
    ToggleOtherNpDebuffCheckboxes()

    --
    local checkBox_friendlyNpBuffEnable = CreateCheckbox("friendlyNpBuffEnable", "Show BUFFS", contentFrame)
    checkBox_friendlyNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 300, 45)

    local bigEnemyBorderText2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText2:SetPoint("LEFT", checkBox_friendlyNpBuffEnable, "CENTER", 0, 25)
    bigEnemyBorderText2:SetText("Friendly Nameplates")
    local enemyNameplateIcon2 = contentFrame:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon2:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon2:SetSize(28, 28)
    enemyNameplateIcon2:SetPoint("RIGHT", bigEnemyBorderText2, "LEFT", -3, 0)

    local checkBox_friendlyNpBuffFilterAll = CreateCheckbox("friendlyNpBuffFilterAll", "All", contentFrame)
    checkBox_friendlyNpBuffFilterAll:SetPoint("TOPLEFT", checkBox_friendlyNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_friendlyNpBuffFilterWatchList = CreateCheckbox("friendlyNpBuffFilterWatchList", "Whitelist", contentFrame)
    CreateTooltip(checkBox_friendlyNpBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    checkBox_friendlyNpBuffFilterWatchList:SetPoint("TOPLEFT", checkBox_friendlyNpBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_friendlyNpBuffFilterLessMinite = CreateCheckbox("friendlyNpBuffFilterLessMinite", "Under one min", contentFrame)
    checkBox_friendlyNpBuffFilterLessMinite:SetPoint("TOPLEFT", checkBox_friendlyNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local function ToggleFriendlyNpBuff()
        if BetterBlizzPlatesDB.friendlyNpBuffEnable then
            checkBox_friendlyNpBuffFilterAll:Enable()
            checkBox_friendlyNpBuffFilterAll:SetAlpha(1.0)
            checkBox_friendlyNpBuffFilterWatchList:Enable()
            checkBox_friendlyNpBuffFilterWatchList:SetAlpha(1.0)
            checkBox_friendlyNpBuffFilterLessMinite:Enable()
            checkBox_friendlyNpBuffFilterLessMinite:SetAlpha(1.0)
        else
            checkBox_friendlyNpBuffFilterAll:Disable()
            checkBox_friendlyNpBuffFilterAll:SetAlpha(0.5)
            checkBox_friendlyNpBuffFilterWatchList:Disable()
            checkBox_friendlyNpBuffFilterWatchList:SetAlpha(0.5)
            checkBox_friendlyNpBuffFilterLessMinite:Disable()
            checkBox_friendlyNpBuffFilterLessMinite:SetAlpha(0.5)
        end
    end

    checkBox_friendlyNpBuffEnable:HookScript("OnClick", function(_, btn, down)
        ToggleFriendlyNpBuff()
    end)
    ToggleFriendlyNpBuff()

    local checkBox_friendlyNpdeBuffEnable = CreateCheckbox("friendlyNpdeBuffEnable", "Show DEBUFFS", contentFrame)
    checkBox_friendlyNpdeBuffEnable:SetPoint("TOPLEFT", checkBox_friendlyNpBuffFilterLessMinite, "BOTTOMLEFT", -15, -2)

    local checkBox_friendlyNpdeBuffFilterAll = CreateCheckbox("friendlyNpdeBuffFilterAll", "All", contentFrame)
    checkBox_friendlyNpdeBuffFilterAll:SetPoint("TOPLEFT", checkBox_friendlyNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_friendlyNpdeBuffFilterBlizzard = CreateCheckbox("friendlyNpdeBuffFilterBlizzard", "Blizzard Default Filter", contentFrame)
    checkBox_friendlyNpdeBuffFilterBlizzard:SetPoint("TOPLEFT", checkBox_friendlyNpdeBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_friendlyNpdeBuffFilterWatchList = CreateCheckbox("friendlyNpdeBuffFilterWatchList", "Whitelist", contentFrame)
    CreateTooltip(checkBox_friendlyNpdeBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    checkBox_friendlyNpdeBuffFilterWatchList:SetPoint("TOPLEFT", checkBox_friendlyNpdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_friendlyNpdeBuffFilterLessMinite = CreateCheckbox("friendlyNpdeBuffFilterLessMinite", "Under one min", contentFrame)
    checkBox_friendlyNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", checkBox_friendlyNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    --local checkBox_friendlyNpdeBuffFilterOnlyMe = CreateCheckbox("friendlyNpdeBuffFilterOnlyMe", "Only mine", contentFrame)
    --checkBox_friendlyNpdeBuffFilterOnlyMe:SetPoint("TOPLEFT", checkBox_friendlyNpdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)



    checkBox_friendlyNpdeBuffEnable:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.friendlyNpdeBuffEnable = self:GetChecked()

        BBP.RefreshAllNameplates()

        if BetterBlizzPlatesDB.friendlyNpdeBuffEnable then
            checkBox_friendlyNpdeBuffFilterAll:Enable()
            checkBox_friendlyNpdeBuffFilterAll:SetAlpha(1.0)
            checkBox_friendlyNpdeBuffFilterBlizzard:Enable()
            checkBox_friendlyNpdeBuffFilterBlizzard:SetAlpha(1.0)
            checkBox_friendlyNpdeBuffFilterWatchList:Enable()
            checkBox_friendlyNpdeBuffFilterWatchList:SetAlpha(1.0)
            checkBox_friendlyNpdeBuffFilterLessMinite:Enable()
            checkBox_friendlyNpdeBuffFilterLessMinite:SetAlpha(1.0)
            --checkBox_friendlyNpdeBuffFilterOnlyMe:Enable()
            --checkBox_friendlyNpdeBuffFilterOnlyMe:SetAlpha(1.0)
        else
            checkBox_friendlyNpdeBuffFilterAll:Disable()
            checkBox_friendlyNpdeBuffFilterAll:SetAlpha(0.5)
            checkBox_friendlyNpdeBuffFilterBlizzard:Disable()
            checkBox_friendlyNpdeBuffFilterBlizzard:SetAlpha(0.5)
            checkBox_friendlyNpdeBuffFilterWatchList:Disable()
            checkBox_friendlyNpdeBuffFilterWatchList:SetAlpha(0.5)
            checkBox_friendlyNpdeBuffFilterLessMinite:Disable()
            checkBox_friendlyNpdeBuffFilterLessMinite:SetAlpha(0.5)
            --checkBox_friendlyNpdeBuffFilterOnlyMe:Disable()
            --checkBox_friendlyNpdeBuffFilterOnlyMe:SetAlpha(0.5)
        end
    end)
    if BetterBlizzPlatesDB.friendlyNpdeBuffEnable then
        checkBox_friendlyNpdeBuffFilterAll:Enable()
        checkBox_friendlyNpdeBuffFilterAll:SetAlpha(1.0)
        checkBox_friendlyNpdeBuffFilterBlizzard:Enable()
        checkBox_friendlyNpdeBuffFilterBlizzard:SetAlpha(1.0)
        checkBox_friendlyNpdeBuffFilterWatchList:Enable()
        checkBox_friendlyNpdeBuffFilterWatchList:SetAlpha(1.0)
        checkBox_friendlyNpdeBuffFilterLessMinite:Enable()
        checkBox_friendlyNpdeBuffFilterLessMinite:SetAlpha(1.0)
        --checkBox_friendlyNpdeBuffFilterOnlyMe:Enable()
        --checkBox_friendlyNpdeBuffFilterOnlyMe:SetAlpha(1.0)
    else
        checkBox_friendlyNpdeBuffFilterAll:Disable()
        checkBox_friendlyNpdeBuffFilterAll:SetAlpha(0.5)
        checkBox_friendlyNpdeBuffFilterBlizzard:Disable()
        checkBox_friendlyNpdeBuffFilterBlizzard:SetAlpha(0.5)
        checkBox_friendlyNpdeBuffFilterWatchList:Disable()
        checkBox_friendlyNpdeBuffFilterWatchList:SetAlpha(0.5)
        checkBox_friendlyNpdeBuffFilterLessMinite:Disable()
        checkBox_friendlyNpdeBuffFilterLessMinite:SetAlpha(0.5)
        --checkBox_friendlyNpdeBuffFilterOnlyMe:Disable()
        --checkBox_friendlyNpdeBuffFilterOnlyMe:SetAlpha(0.5)
    end






    local checkBox_personalNpBuffEnable = CreateCheckbox("personalNpBuffEnable", "Show BUFFS", contentFrame)
    checkBox_personalNpBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 530, 45)

    local bigEnemyBorderText3 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText3:SetPoint("LEFT", checkBox_personalNpBuffEnable, "CENTER", 0, 25)
    bigEnemyBorderText3:SetText("Personal Bar")
    local enemyNameplateIcon3 = contentFrame:CreateTexture(nil, "ARTWORK")
    enemyNameplateIcon3:SetAtlas("groupfinder-icon-friend")
    enemyNameplateIcon3:SetSize(28, 28)
    enemyNameplateIcon3:SetPoint("RIGHT", bigEnemyBorderText3, "LEFT", -3, 0)
    enemyNameplateIcon3:SetDesaturated(1)
    local _, playerClass = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[playerClass]
    if classColor then
        enemyNameplateIcon3:SetVertexColor(classColor.r, classColor.g, classColor.b)
    else
        enemyNameplateIcon3:SetVertexColor(1, 0.5, 0)
    end
    enemyNameplateIcon3:SetBlendMode("ADD")

    local checkBox_personalNpBuffFilterAll = CreateCheckbox("personalNpBuffFilterAll", "All", contentFrame)
    checkBox_personalNpBuffFilterAll:SetPoint("TOPLEFT", checkBox_personalNpBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_personalNpBuffFilterBlizzard = CreateCheckbox("personalNpBuffFilterBlizzard", "Blizzard Default Filter", contentFrame)
    checkBox_personalNpBuffFilterBlizzard:SetPoint("TOPLEFT", checkBox_personalNpBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_personalNpBuffFilterWatchList = CreateCheckbox("personalNpBuffFilterWatchList", "Whitelist", contentFrame)
    CreateTooltip(checkBox_personalNpBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    checkBox_personalNpBuffFilterWatchList:SetPoint("TOPLEFT", checkBox_personalNpBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_personalNpBuffFilterLessMinite = CreateCheckbox("personalNpBuffFilterLessMinite", "Under one min", contentFrame)
    checkBox_personalNpBuffFilterLessMinite:SetPoint("TOPLEFT", checkBox_personalNpBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local function TogglePersonalNpBuff()
        if BetterBlizzPlatesDB.personalNpBuffEnable then
            checkBox_personalNpBuffFilterAll:Enable()
            checkBox_personalNpBuffFilterAll:SetAlpha(1.0)
            checkBox_personalNpBuffFilterBlizzard:Enable()
            checkBox_personalNpBuffFilterBlizzard:SetAlpha(1.0)
            checkBox_personalNpBuffFilterWatchList:Enable()
            checkBox_personalNpBuffFilterWatchList:SetAlpha(1.0)
            checkBox_personalNpBuffFilterLessMinite:Enable()
            checkBox_personalNpBuffFilterLessMinite:SetAlpha(1.0)
        else
            checkBox_personalNpBuffFilterAll:Disable()
            checkBox_personalNpBuffFilterAll:SetAlpha(0.5)
            checkBox_personalNpBuffFilterBlizzard:Disable()
            checkBox_personalNpBuffFilterBlizzard:SetAlpha(0.5)
            checkBox_personalNpBuffFilterWatchList:Disable()
            checkBox_personalNpBuffFilterWatchList:SetAlpha(0.5)
            checkBox_personalNpBuffFilterLessMinite:Disable()
            checkBox_personalNpBuffFilterLessMinite:SetAlpha(0.5)
        end
    end

    checkBox_personalNpBuffEnable:HookScript("OnClick", function(_, btn, down)
        TogglePersonalNpBuff()
    end)
    TogglePersonalNpBuff()




    local checkBox_personalNpdeBuffEnable = CreateCheckbox("personalNpdeBuffEnable", "Show DEBUFFS", contentFrame)
    checkBox_personalNpdeBuffEnable:SetPoint("TOPLEFT", checkBox_personalNpBuffFilterLessMinite, "BOTTOMLEFT", -15, -2)

    local checkBox_personalNpdeBuffFilterAll = CreateCheckbox("personalNpdeBuffFilterAll", "All", contentFrame)
    checkBox_personalNpdeBuffFilterAll:SetPoint("TOPLEFT", checkBox_personalNpdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local checkBox_personalNpdeBuffFilterWatchList = CreateCheckbox("personalNpdeBuffFilterWatchList", "Whitelist", contentFrame)
    CreateTooltip(checkBox_personalNpdeBuffFilterWatchList, "Whitelist works in addition to the other filters selected.")
    checkBox_personalNpdeBuffFilterWatchList:SetPoint("TOPLEFT", checkBox_personalNpdeBuffFilterAll, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local checkBox_personalNpdeBuffFilterLessMinite = CreateCheckbox("personalNpdeBuffFilterLessMinite", "Under one min", contentFrame)
    checkBox_personalNpdeBuffFilterLessMinite:SetPoint("TOPLEFT", checkBox_personalNpdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)


    local function PersonalNpDebuffToggle()
        if BetterBlizzPlatesDB.personalNpdeBuffEnable then
            checkBox_personalNpdeBuffFilterAll:Enable()
            checkBox_personalNpdeBuffFilterAll:SetAlpha(1.0)
            checkBox_personalNpdeBuffFilterWatchList:Enable()
            checkBox_personalNpdeBuffFilterWatchList:SetAlpha(1.0)
            checkBox_personalNpdeBuffFilterLessMinite:Enable()
            checkBox_personalNpdeBuffFilterLessMinite:SetAlpha(1.0)
        else
            checkBox_personalNpdeBuffFilterAll:Disable()
            checkBox_personalNpdeBuffFilterAll:SetAlpha(0.5)
            checkBox_personalNpdeBuffFilterWatchList:Enable()
            checkBox_personalNpdeBuffFilterWatchList:SetAlpha(0.5)
            checkBox_personalNpdeBuffFilterLessMinite:Enable()
            checkBox_personalNpdeBuffFilterLessMinite:SetAlpha(0.5)
        end
    end

    checkBox_personalNpdeBuffEnable:HookScript("OnClick", function(_, btn, down)
        PersonalNpDebuffToggle()
    end)
    PersonalNpDebuffToggle()



    --[[
    -- Nameplateaura slider
    local checkBox_nameplateAurasXPosSlider = CreateSlider("BetterBlizzPlates_nameplateAurasXPosSlider", contentFrame, "x offset", -50, 50, 1, "nameplateAuras", "X")
    checkBox_nameplateAurasXPosSlider:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -240, -370)
    checkBox_nameplateAurasXPosSlider:SetValue(BetterBlizzPlatesDB.nameplateAurasXPos or 0)

    ]]


    local nameplateAurasYPosSlider = CreateSlider("BetterBlizzPlates_nameplateAurasYPosSlider", contentFrame, "y offset", -50, 50, 1, "nameplateAuras", "Y")
    nameplateAurasYPosSlider:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -240, -280)
    nameplateAurasYPosSlider:SetValue(BetterBlizzPlatesDB.nameplateAurasYPos or 0)

    local cB_centerAuras = CreateCheckbox("nameplateAurasCenteredAnchor", "Center auras on top of nameplate", contentFrame)
    cB_centerAuras:SetPoint("BOTTOM", nameplateAurasYPosSlider, "TOP", -30, 10)
    CreateTooltip(cB_centerAuras, "Requires reload to turn back off")

    local maxAurasOnNameplateSlider = CreateSlider("BetterBlizzPlates_maxAurasOnNameplate", contentFrame, "Max auras on nameplate", 1, 24, 1, "maxAurasOnNameplate")
    maxAurasOnNameplateSlider:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -10, -280)
    maxAurasOnNameplateSlider:SetValue(BetterBlizzPlatesDB.maxAurasOnNameplate or 12)


    local imintoodeep = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    imintoodeep:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -50, -220)
    imintoodeep:SetText("will add more settings, very beta\nwould love feedback if u notice anything weird")














    checkBox_enableNameplateAuraCustomisation:SetScript("OnClick", function(self)
        BetterBlizzPlatesDB.enableNameplateAuraCustomisation = self:GetChecked()
        StaticPopup_Show("CONFIRM_RELOAD")

        if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
            --contentFrame:SetAlpha(1)
            EnableCheckboxes(contentFrame)
            checkBox_enableNameplateAuraCustomisation:SetParent(scrollFrame)
        else
            --contentFrame:SetAlpha(0.5)
            DisableCheckboxes(contentFrame)
            checkBox_enableNameplateAuraCustomisation:Enable()
            checkBox_enableNameplateAuraCustomisation:SetAlpha(1)
            checkBox_enableNameplateAuraCustomisation:SetParent(scrollFrame)
        end
    end)


    if BetterBlizzPlatesDB.enableNameplateAuraCustomisation then
        --contentFrame:SetAlpha(1)
        EnableCheckboxes(contentFrame)
        checkBox_enableNameplateAuraCustomisation:SetParent(scrollFrame)
    else
        --contentFrame:SetAlpha(0.5)
        DisableCheckboxes(contentFrame)
        checkBox_enableNameplateAuraCustomisation:Enable()
        checkBox_enableNameplateAuraCustomisation:SetAlpha(1)
        checkBox_enableNameplateAuraCustomisation:SetParent(scrollFrame)
    end

    local betaHighlight = checkBox_enableNameplateAuraCustomisation:CreateTexture(nil, "BACKGROUND")
    betaHighlight:SetAtlas("CharacterCreate-NewLabel")
    betaHighlight:SetSize(42, 34)
    betaHighlight:SetPoint("RIGHT", checkBox_enableNameplateAuraCustomisation, "LEFT", 8, 0)




end



-- GUI Setup
function BBP.InitializeOptions()
    if not BetterBlizzPlates then
        BetterBlizzPlates = CreateFrame("Frame")
        BetterBlizzPlates.name = "BetterBlizzPlates"

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