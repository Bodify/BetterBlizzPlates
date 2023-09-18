BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

BetterBlizzPlates = nil
local anchorPoints = {"CENTER", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local targetIndicatorAnchorPoints = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

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

function BBP.CreateModeDropdown(name, parent, defaultText, settingKey, toggleFunc, point, modes, tooltips, textLabel, textColor)
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

function BBP.CreateSlider(name, parent, label, minValue, maxValue, stepValue, element, axis)
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
    else
        initialValue = BetterBlizzPlatesDB[element .. "Scale"] or minValue
    end
    slider:SetValue(initialValue)

    local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
    slider.Text:SetText(label .. ": " .. textValue)

    slider:SetScript("OnValueChanged", function(self, value)
        local textValue = value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
        self.Text:SetText(label .. ": " .. textValue)
        if not BBP.checkCombatAndWarn() then
            -- Update the X or Y position based on the axis
            if axis == "X" then
                BetterBlizzPlatesDB[element .. "XPos"] = value
            elseif axis == "Y" then
                BetterBlizzPlatesDB[element .. "YPos"] = value
            elseif axis == "Alpha" then
                BetterBlizzPlatesDB[element .. "Alpha"] = value
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
                        if not frame.absorbIndicator then
                            BBP.AbsorbIndicator(frame)
                        end
                        if axis then
                            local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
                            frame.absorbIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos -2, yPos)
                        else
                            frame.absorbIndicator:SetScale(value)
                        end
                    -- Combat Indicator Pos and Scale
                    elseif element == "combatIndicator" then
                        if not frame.combatIndicator then
                            BBP.CombatIndicator(frame)
                        end
                        if axis then
                            frame.combatIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                            frame.combatIndicatorSap:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.combatIndicator:SetScale(value)
                            frame.combatIndicatorSap:SetScale(value)
                        end
                    -- Healer Indicator Pos and Scale
                    elseif element == "healerIndicator" then
                        if not frame.healerIndicator then
                            BBP.HealerIndicator(frame)
                        end
                        if axis then
                            frame.healerIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.healerIndicator:SetScale(value)
                        end
                    -- Pet Indicator Pos and Scale
                    elseif element == "petIndicator" then
                        if not frame.petIndicator then
                            BBP.PetIndicator(frame)
                        end
                        if axis then
                            frame.petIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.petIndicator:SetScale(value)
                        end
                    -- Execute Indicator Pos and Scale
                    elseif element == "executeIndicator" then
                        if not frame.executeIndicator then
                            BBP.ExecuteIndicator(frame)
                        end
                        if axis then
                            frame.executeIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.executeIndicator:SetScale(value)
                        end
                    -- Target Indicator Pos and Scale
                    elseif element == "targetIndicator" then
                        if not frame.targetIndicator then
                            BBP.TargetIndicator(frame)
                        end
                        if axis then
                            frame.targetIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.targetIndicator:SetScale(value)
                        end
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
                        if not frame.CastTimer then
                            BBP.UpdateCastTimer(nameplate, unitID)
                        end
                        if axis then
                            frame.CastTimer:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.CastTimer:SetScale(value)
                        end
                    -- Target Text for Cast Timer Pos and Scale
                    elseif element == "targetText" then
                        if not frame.TargetText then
                            BBP.UpdateNameplateTargetText(nameplate, unitID)
                        end
                        if axis then
                            local oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
                            frame.TargetText:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos, yPos)
                        else
                            frame.TargetText:SetScale(value)
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
                    -- Nameplate scales
                    elseif element == "nameplate" then
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
                    -- Nameplate selected scale
                    elseif element == "nameplateSelected" then
                        SetCVar("nameplateSelectedScale", value)
                        BetterBlizzPlatesDB.nameplateSelectedScale = value
                    -- Nameplate Horizontal Overlap
                    elseif element == "nameplateOverlapH" then
                        SetCVar("nameplateOverlapH", value)
                        BetterBlizzPlatesDB.nameplateOverlapH = value
                    -- Nameplate Vertical Overlap
                    elseif element == "nameplateOverlapV" then
                        SetCVar("nameplateOverlapV", value)
                        BetterBlizzPlatesDB.nameplateOverlapV = value
                    -- Nameplate Motion Speed
                    elseif element == "nameplateMotionSpeed" then
                        SetCVar("nameplateMotionSpeed", value)
                        BetterBlizzPlatesDB.nameplateMotionSpeed = value
                    -- Friendly name scale
                    elseif element == "friendlyText" then
                        if not BetterBlizzPlatesDB.arenaIndicatorTestMode then
                            BBP.hasPrintedTestModeWarning = false
                            BetterBlizzPlatesDB.friendlyNameScale = value
                            BBP.ClassColorAndScaleNames(frame)
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
                            BBP.ClassColorAndScaleNames(frame)
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
                        BetterBlizzPlatesDB.nameplateFriendlyWidth = value
                        local heightValue
                        if BetterBlizzPlatesDB.friendlyNameplateClickthrough then
                            heightValue = 1
                        else
                            heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        end
                        C_NamePlate.SetNamePlateFriendlySize(value, heightValue)
                    elseif element == "nameplateEnemyWidth" then
                        BetterBlizzPlatesDB.nameplateEnemyWidth = value
                        local heightValue
                        heightValue = BBP.isLargeNameplatesEnabled() and 64.125 or 40
                        C_NamePlate.SetNamePlateEnemySize(value, heightValue)
                    elseif element == "fadeOutNPCsAlpha" then
                        if axis then
                            BetterBlizzPlatesDB.fadeOutNPCsAlpha = value
                            BBP.FadeOutNPCs(frame)
                        end
                    end
                end
            end
        end
    end)
    
    return slider
end

function BBP.CreateTooltip(widget, tooltipText, textureInfo)
    local tooltipTexture = GameTooltip:CreateTexture(nil, "ARTWORK")
    
    widget:SetScript("OnEnter", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText)

        if type(textureInfo) == "string" then
            tooltipTexture:SetTexture(textureInfo)
            tooltipTexture:SetSize(256, 32)  -- Default size
        elseif type(textureInfo) == "table" then
            tooltipTexture:SetTexture(textureInfo.path)
            tooltipTexture:SetSize(textureInfo.width, textureInfo.height)
            -- Add other properties here
        end

        if textureInfo then
            tooltipTexture:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, 0)
            tooltipTexture:Show()
        end

        GameTooltip:Show()
    end)
    
    widget:SetScript("OnLeave", function(self)
        tooltipTexture:Hide()
        GameTooltip:Hide()
    end)
end

function BBP.CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point)
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

function BBP.CreateCheckbox(option, label, parent, cvarName, extraFunc)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)

    local function UpdateOption(value)
        -- If the option being updated is 'friendlyNameplateClickthrough' and the player is in combat, warn and return.
        if option == 'friendlyNameplateClickthrough' and BBP.checkCombatAndWarn() then
            return
        end
        
        local modifiedValue = value

        BetterBlizzPlatesDB[option] = modifiedValue
        -- Update the checkbox state
        checkBox:SetChecked(value)
    
        -- Update the cvar value if provided
        if cvarName then
            if BBP.checkCombatAndWarn() then
                return  -- Don't try to adjust CVar if in combat, just warn the player
            end
            local cvarValue = modifiedValue and 1 or 0
            SetCVar(cvarName, cvarValue)
        end
    
        -- Run additional update function if provided
        if extraFunc then
            extraFunc(option, value)
        end

        BBP.RefreshAllNameplates()
    end    

    -- Initialize checkbox
    local initialCVarValue
    if cvarName then
        if cvarName == "nameplateShowEnemyMinus" then
            initialCVarValue = GetCVar(cvarName) == "0"
        else
            initialCVarValue = GetCVar(cvarName) == "1"
        end
    else
        initialCVarValue = BetterBlizzPlatesDB[option]
    end
    UpdateOption(initialCVarValue)

    -- Hook the OnClick script to update things when clicked
    checkBox:HookScript("OnClick", function(_, btn, down)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
end

local function createScrollFrame(subPanel, listName, listData, refreshFunc)
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

    local function createTextLineButton(npc, index)
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
    
        button.deleteButton = deleteButton
        table.insert(textLines, button)
        updateBackgroundColors()  -- Update background colors after adding a new entry
    end

    -- Create and initialize textLine buttons
    for i, npc in ipairs(listData) do
        createTextLineButton(npc, i)
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
                createTextLineButton({ name = name, id = id, comment = comment }, #textLines + 1)
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

-- GUI Setup
function BBP.InitializeOptions()
    if not BetterBlizzPlates then
        BetterBlizzPlates = CreateFrame("Frame")
        BetterBlizzPlates.name = "BetterBlizzPlates"
        local pixelsBetweenBoxes = 5
        local pixelsOnFirstBox = -1

        
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
        local checkBox_removeRealmNames = BBP.CreateCheckbox("removeRealmNames", "Hide realm names", BetterBlizzPlates)
        checkBox_removeRealmNames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

        -- Hide nameplate auras
        local checkBox_hideNameplateAuras = BBP.CreateCheckbox("hideNameplateAuras", "Hide nameplate auras", BetterBlizzPlates)
        checkBox_hideNameplateAuras:SetPoint("TOPLEFT", checkBox_removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Hide target highlight glow on nameplates
        local checkBox_hideTargetHighlight = BBP.CreateCheckbox("hideTargetHighlight", "Hide target highlight glow", BetterBlizzPlates)
        checkBox_hideTargetHighlight:SetPoint("TOPLEFT", checkBox_hideNameplateAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Put raidmarker on top of nameplates
        local checkBox_raidmarkIndicator = BBP.CreateCheckbox("raidmarkIndicator", "Raidmarker on top of nameplate", BetterBlizzPlates, nil, BBP.ChangeRaidmarker)
        checkBox_raidmarkIndicator:SetPoint("TOPLEFT", checkBox_hideTargetHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Raidmarker slider
        local raidmarkIndicatorScaleSlider = BBP.CreateSlider("raidmarkIndicatorScaleSlider", BetterBlizzPlates, "Raidmark Size", 1, 3, 0.1, "raidmarkIndicator")
        raidmarkIndicatorScaleSlider:SetPoint("TOPLEFT", checkBox_raidmarkIndicator, "BOTTOMLEFT", 12, -10)
        raidmarkIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorScale or 0.1)

        -- nameplate scale slider
        local nameplateScaleSlider = BBP.CreateSlider("NameplateScaleSlider", BetterBlizzPlates, "Nameplate Size", 0.5, 2, 0.1, "nameplate")
        nameplateScaleSlider:SetPoint("TOPLEFT", raidmarkIndicatorScaleSlider, "BOTTOMLEFT", 0, -15)
        nameplateScaleSlider:SetValue(BetterBlizzPlatesDB.nameplateMaxScale or 1)

        -- Reset button for nameplateScale slider
        local btn_reset_nameplateScale = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
        btn_reset_nameplateScale:SetText("Default")
        btn_reset_nameplateScale:SetWidth(60)
        btn_reset_nameplateScale:SetPoint("LEFT", nameplateScaleSlider, "RIGHT", 10, 0)
        btn_reset_nameplateScale:SetScript("OnClick", function()
            BBP.ResetToDefaultScales(nameplateScaleSlider, "nameplateScale")
        end)

        -- target nameplate scale
        local nameplateSelectedScaleSlider = BBP.CreateSlider("NameplateSelectedScaleSlider", BetterBlizzPlates, "Target Nameplate Size", 0.5, 3, 0.1, "nameplateSelected")
        nameplateSelectedScaleSlider:SetPoint("TOPLEFT", nameplateScaleSlider, "BOTTOMLEFT", 0, -17)
        nameplateSelectedScaleSlider:SetValue(BetterBlizzPlatesDB.nameplateSelectedScale or 1.2)

        -- Reset button for nameplateSelectedScale slider
        local btn_reset_nameplateSelected = CreateFrame("Button", nil, BetterBlizzPlates, "UIPanelButtonTemplate")
        btn_reset_nameplateSelected:SetText("Default")
        btn_reset_nameplateSelected:SetWidth(60)
        btn_reset_nameplateSelected:SetPoint("LEFT", nameplateSelectedScaleSlider, "RIGHT", 10, 0)
        btn_reset_nameplateSelected:SetScript("OnClick", function()
            BBP.ResetToDefaultScales(nameplateSelectedScaleSlider, "nameplateSelected")
        end)







        ------------------------------------------------------------------------------------------------
        -- Enemy nameplates:
        ------------------------------------------------------------------------------------------------
        -- "Enemy nameplates:" text
        local enemyNameplatesText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enemyNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -250)
        enemyNameplatesText:SetText("Enemy nameplates")
        local enemyNameplateIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
        enemyNameplateIcon:SetAtlas("groupfinder-icon-friend")
        enemyNameplateIcon:SetSize(28, 28)
        enemyNameplateIcon:SetPoint("RIGHT", enemyNameplatesText, "LEFT", -3, 0)
        enemyNameplateIcon:SetDesaturated(1)
        enemyNameplateIcon:SetVertexColor(1, 0, 0)

        -- Class colored enemy names
        local checkBox_enemyClassColorName = BBP.CreateCheckbox("enemyClassColorName", "Class colored names", BetterBlizzPlates)
        checkBox_enemyClassColorName:SetPoint("TOPLEFT", enemyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

        --Spellcast timer
        local checkBox_showNameplateCastbarTimer = BBP.CreateCheckbox("showNameplateCastbarTimer", "Cast timer next to castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
        checkBox_showNameplateCastbarTimer:SetPoint("TOPLEFT", checkBox_enemyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        --Target name on spellcasts
        local checkBox_showNameplateTargetText = BBP.CreateCheckbox("showNameplateTargetText", "Show target underneath castbar", BetterBlizzPlates, nil, BBP.ToggleSpellCastEventRegistration)
        checkBox_showNameplateTargetText:SetPoint("TOPLEFT", checkBox_showNameplateCastbarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Enemy name size slider
        local enemyNameScaleSlider = BBP.CreateSlider("enemyNameScaleSlider", BetterBlizzPlates, "Name Size", 0.5, 1.5, 0.01, "enemyText")
        enemyNameScaleSlider:SetPoint("TOPLEFT", checkBox_showNameplateTargetText, "BOTTOMLEFT", 12, -10)
        enemyNameScaleSlider:SetValue(BetterBlizzPlatesDB.enemyNameScale or 1)

        -- Enemy nameplate width
        local nameplateEnemyWidthSlider = BBP.CreateSlider("BetterBlizzPlates_nameplateEnemyWidthSlider", BetterBlizzPlates, "Nameplate Width", 50, 200, 1, "nameplateEnemyWidth")
        nameplateEnemyWidthSlider:SetPoint("TOPLEFT", enemyNameScaleSlider, "BOTTOMLEFT", 0, -17)
        nameplateEnemyWidthSlider:SetValue(BetterBlizzPlatesDB.nameplateEnemyWidth or 154)

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
        local checkBox_friendlyNameplateClickthrough = BBP.CreateCheckbox("friendlyNameplateClickthrough", "Clickthrough", BetterBlizzPlates, nil, BBP.ApplyNameplateWidth)
        checkBox_friendlyNameplateClickthrough:SetPoint("TOPLEFT", friendlyNameplatesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

        -- Class colored friendly names
        local checkBox_friendlyClassColorName = BBP.CreateCheckbox("friendlyClassColorName", "Class colored names", BetterBlizzPlates)
        checkBox_friendlyClassColorName:SetPoint("TOPLEFT", checkBox_friendlyNameplateClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Toggle friendly nameplates on for arena and off outside
        local checkBox_toggleFriendlyNameplatesInArena = BBP.CreateCheckbox("friendlyNameplatesOnlyInArena", "Toggle nameplates on in arena auto", BetterBlizzPlates, nil, BBP.ToggleFriendlyNameplatesInArena)
        checkBox_toggleFriendlyNameplatesInArena:SetPoint("TOPLEFT", checkBox_friendlyClassColorName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Friendly nameplates text slider
        local friendlyNameScaleSlider = BBP.CreateSlider("friendlyNameScaleSlider", BetterBlizzPlates, "Name size", 0.5, 3, 0.1, "friendlyText")
        friendlyNameScaleSlider:SetPoint("TOPLEFT", checkBox_toggleFriendlyNameplatesInArena, "BOTTOMLEFT", 12, -10)
        friendlyNameScaleSlider:SetValue(BetterBlizzPlatesDB.friendlyNameScale or 1)

        -- Friendly nameplate width slider
        local nameplateFriendlyWidthSlider = BBP.CreateSlider("nameplateFriendlyWidthSlider", BetterBlizzPlates, "Nameplate Width", 50, 200, 1, "nameplateFriendlyWidth")
        nameplateFriendlyWidthSlider:SetPoint("TOPLEFT", friendlyNameScaleSlider, "BOTTOMLEFT", 0, -20)
        nameplateFriendlyWidthSlider:SetValue(BetterBlizzPlatesDB.nameplateFriendlyWidth or 154)

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
        local checkBox_testAllEnabledExtraFeatures = BBP.CreateCheckbox("testAllEnabledExtraFeatures", "Test", BetterBlizzPlates, nil, BBP.EnableAllActiveFeatureTestModes)           
        checkBox_testAllEnabledExtraFeatures:SetPoint("LEFT", extraFeaturesText, "RIGHT", 5, 0)
        BBP.CreateTooltip(checkBox_testAllEnabledExtraFeatures, "Test all enabled features. Check advanced settings for more")

        -- Absorb indicator
        local checkBox_absorbIndicator = BBP.CreateCheckbox("absorbIndicator", "Absorb indicator", BetterBlizzPlates, nil, BBP.ToggleAbsorbIndicator)
        checkBox_absorbIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
        local absorbTooltip = {
            path = "Interface\\AddOns\\BetterBlizzPlates\\media\\absorbIndicator",
            width = 256,
            height = 32
        }
        BBP.CreateTooltip(checkBox_absorbIndicator, "Show absorb amount on nameplates", absorbTooltip)
        local absorbsIcon = checkBox_absorbIndicator:CreateTexture(nil, "ARTWORK")
        absorbsIcon:SetAtlas("ParagonReputation_Glow")
        absorbsIcon:SetSize(22, 22)
        absorbsIcon:SetPoint("RIGHT", checkBox_absorbIndicator, "LEFT", 0, 0)

        -- Combat indicator
        local checkBox_combatIndicator = BBP.CreateCheckbox("combatIndicator", "Combat indicator", BetterBlizzPlates, nil, BBP.ToggleCombatIndicator)
        checkBox_combatIndicator:SetPoint("TOPLEFT", checkBox_absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        local combatTooltip = {
            path = "Interface\\AddOns\\BetterBlizzPlates\\media\\combatIndicator",
            width = 256,
            height = 32
        }
        BBP.CreateTooltip(checkBox_combatIndicator, "Show a food icon on nameplates that are out of combat", combatTooltip)
        local combatIcon = checkBox_combatIndicator:CreateTexture(nil, "ARTWORK")
        combatIcon:SetAtlas("food")
        combatIcon:SetSize(19, 19)
        combatIcon:SetPoint("RIGHT", checkBox_combatIndicator, "LEFT", -1, 0)

        -- Execute indicator
        local checkBox_executeIndicator = BBP.CreateCheckbox("executeIndicator", "Execute indicator", BetterBlizzPlates, nil, BBP.ToggleExecuteIndicator)
        checkBox_executeIndicator:SetPoint("TOPLEFT", checkBox_combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        local executeTooltip = {
            path = "Interface\\AddOns\\BetterBlizzPlates\\media\\executeIndicator",
            width = 256,
            height = 32
        }
        BBP.CreateTooltip(checkBox_executeIndicator, "Starts tracking health percentage once target dips below 40%", executeTooltip)
        local executeIndicatorIcon = checkBox_executeIndicator:CreateTexture(nil, "ARTWORK")
        executeIndicatorIcon:SetAtlas("islands-azeriteboss")
        executeIndicatorIcon:SetSize(28, 30)
        executeIndicatorIcon:SetPoint("RIGHT", checkBox_executeIndicator, "LEFT", 4, 1)

        -- Healer indicator
        local checkBox_healerIndicator = BBP.CreateCheckbox("healerIndicator", "Healer indicator", BetterBlizzPlates)
        checkBox_healerIndicator:SetPoint("TOPLEFT", checkBox_executeIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        local healerTooltip = {
            path = "Interface\\AddOns\\BetterBlizzPlates\\media\\healerIndicator",
            width = 256,
            height = 32
        }
        BBP.CreateTooltip(checkBox_healerIndicator, "Show a cross on healers. Requires Details to work", healerTooltip)
        local healerCrossIcon = checkBox_healerIndicator:CreateTexture(nil, "ARTWORK")
        healerCrossIcon:SetAtlas("greencross")
        healerCrossIcon:SetSize(21, 21)
        healerCrossIcon:SetPoint("RIGHT", checkBox_healerIndicator, "LEFT", 0, 0)

        -- Pet indicator
        local checkBox_petIndicator = BBP.CreateCheckbox("petIndicator", "Pet indicator", BetterBlizzPlates)
        checkBox_petIndicator:SetPoint("TOPLEFT", checkBox_healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        local petTooltip = {
            path = "Interface\\AddOns\\BetterBlizzPlates\\media\\petIndicator",
            width = 256,
            height = 32
        }
        BBP.CreateTooltip(checkBox_petIndicator, "Show a murloc on the main hunter pet", petTooltip)
        local petIndicator = checkBox_petIndicator:CreateTexture(nil, "ARTWORK")
        petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
        petIndicator:SetSize(18, 18)
        petIndicator:SetPoint("RIGHT", checkBox_petIndicator, "LEFT", -1, 0)

        -- Target indicator
        local checkBox_targetIndicator = BBP.CreateCheckbox("targetIndicator", "Target indicator", BetterBlizzPlates, nil, BBP.ToggleTargetIndicator)
        checkBox_targetIndicator:SetPoint("TOPLEFT", checkBox_petIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        local targetTooltip = {
            path = "Interface\\AddOns\\BetterBlizzPlates\\media\\targetIndicator",
            width = 256,
            height = 32
        }
        BBP.CreateTooltip(checkBox_targetIndicator, "Show an arrow on your current target", targetTooltip)
        local targetIndicatorIcon = checkBox_healerIndicator:CreateTexture(nil, "ARTWORK")
        targetIndicatorIcon:SetAtlas("Navigation-Tracked-Arrow")
        targetIndicatorIcon:SetRotation(math.rad(180))
        targetIndicatorIcon:SetSize(19, 14)
        targetIndicatorIcon:SetPoint("RIGHT", checkBox_targetIndicator, "LEFT", -1, 0)

        -- Totem indicator
        local checkBox_totemIndicator = BBP.CreateCheckbox("totemIndicator", "Totem indicator", BetterBlizzPlates)
        checkBox_totemIndicator:SetPoint("TOPLEFT", checkBox_targetIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
        BBP.CreateTooltip(checkBox_totemIndicator, "Color and put icons on key npc and totem nameplates.\nImportant npcs and totems will be slightly larger and\nhave a glow around the icon")
        local totemsIcon = checkBox_totemIndicator:CreateTexture(nil, "ARTWORK")
        totemsIcon:SetAtlas("teleportationnetwork-ardenweald-32x32")
        totemsIcon:SetSize(17, 17)
        totemsIcon:SetPoint("RIGHT", checkBox_totemIndicator, "LEFT", -1, 0)








        ------------------------------------------------------------------------------------------------
        -- Font and texture
        ------------------------------------------------------------------------------------------------
        -- Font and texture
        local customFontandTextureText = BetterBlizzPlates:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        customFontandTextureText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 370, -430)
        customFontandTextureText:SetText("Font and texture")
        local customFontandTextureIcon = BetterBlizzPlates:CreateTexture(nil, "ARTWORK")
        customFontandTextureIcon:SetAtlas("barbershop-32x32")
        customFontandTextureIcon:SetSize(24, 24)
        customFontandTextureIcon:SetPoint("RIGHT", customFontandTextureText, "LEFT", -3, 0)

        -- Use a sexy font for nameplates
        local checkBox_useCustomFont = BBP.CreateCheckbox("useCustomFont", "Use a sexy font for nameplates", BetterBlizzPlates)
        checkBox_useCustomFont:SetPoint("TOPLEFT", customFontandTextureText, "BOTTOMLEFT", 0, pixelsOnFirstBox)

        -- Use a sexy texture for nameplates
        local checkBox_useCustomTexture = BBP.CreateCheckbox("useCustomTextureForBars", "Use a sexy texture for nameplates", BetterBlizzPlates)
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

        local arenaModeDropdown = BBP.CreateModeDropdown(
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
        local checkBox_arenaIndicatorTestMode = BBP.CreateCheckbox("arenaIndicatorTestMode", "Test", BetterBlizzPlates, RefreshAllNameplates)           
        checkBox_arenaIndicatorTestMode:SetPoint("LEFT", arenaSettingsText, "RIGHT", 5, 0)

        -- Arena nameplates slider
        local arenaIDScaleSlider = BBP.CreateSlider("arenaIDScaleSlider", BetterBlizzPlates, "Arena ID Size", 1, 4, 0.1, "arenaID")
        arenaIDScaleSlider:SetPoint("TOPLEFT", arenaModeDropdown, "BOTTOMLEFT", 20, -9)
        arenaIDScaleSlider:SetValue(BetterBlizzPlatesDB.arenaIDScale or 1)

        -- Arena spec nameplates slider
        local arenaSpecScaleSlider = BBP.CreateSlider("arenaSpecScale", BetterBlizzPlates, "Spec Size", 0.5, 3, 0.1, "arenaSpec")
        arenaSpecScaleSlider:SetPoint("TOPLEFT", arenaIDScaleSlider, "BOTTOMLEFT", 0, -11)
        arenaSpecScaleSlider:SetValue(BetterBlizzPlatesDB.arenaSpecScale or 1)

        local partyModeDropdown = BBP.CreateModeDropdown(
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
        local partyIDScaleSlider = BBP.CreateSlider("partyIDScaleSlider", BetterBlizzPlates, "Party ID Size", 1, 4, 0.1, "partyID")
        partyIDScaleSlider:SetPoint("TOPLEFT", partyModeDropdown, "BOTTOMLEFT", 20, -9)
        partyIDScaleSlider:SetValue(BetterBlizzPlatesDB.partyIDScale or 1)

        -- Party spec name scale slider
        local partySpecScaleSlider = BBP.CreateSlider("partySpecScale", BetterBlizzPlates, "Spec Size", 0.5, 3, 0.1, "partySpec")
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

















        ------------------------------------------------------------------------------------------------
        -- Advanced settings
        ------------------------------------------------------------------------------------------------
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
        
        -- Main GUI Anchor
        local mainGuiAnchor2 = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mainGuiAnchor2:SetPoint("TOPLEFT", 15, 20)
        mainGuiAnchor2:SetText(" ")




        ------------------------------------------------------------------------------------------------
        -- Healer indicator
        ------------------------------------------------------------------------------------------------
        --Healer Indicator
        local anchorSubHeal = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubHeal:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 10, -60)
        anchorSubHeal:SetText("Healer Indicator")

        local healerCrossIcon2 = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
        healerCrossIcon2:SetAtlas("greencross")
        healerCrossIcon2:SetSize(32, 32)
        healerCrossIcon2:SetPoint("BOTTOM", anchorSubHeal, "TOP", 0, 0)
        healerCrossIcon2:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

        -- Healer icon scale slider2
        local healerIndicatorScaleSlider2 = BBP.CreateSlider("BetterBlizzPlates_healerIndicatorScaleSlider2", BetterBlizzPlatesSubPanel, "Size", 0.6, 2.5, 0.1, "healerIndicator")
        healerIndicatorScaleSlider2:SetPoint("TOP", anchorSubHeal, "BOTTOM", 0, -15)
        healerIndicatorScaleSlider2:SetValue(BetterBlizzPlatesDB.healerIndicatorScale)

        -- Healer x pos slider
        local healerIndicatorXPosSlider2 = BBP.CreateSlider("BetterBlizzPlates_healerIndicatorXPosSlider2", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "healerIndicator", "X")
        healerIndicatorXPosSlider2:SetPoint("TOP", healerIndicatorScaleSlider2, "BOTTOM", 0, -15)
        healerIndicatorXPosSlider2:SetValue(BetterBlizzPlatesDB.healerIndicatorXPos or 0)

        -- Healer y pos slider
        local healerIndicatorYPosSlider2 = BBP.CreateSlider("BetterBlizzPlates_healerIndicatorYPosSlider2", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "healerIndicator", "Y")
        healerIndicatorYPosSlider2:SetPoint("TOP", healerIndicatorXPosSlider2, "BOTTOM", 0, -15)
        healerIndicatorYPosSlider2:SetValue(BetterBlizzPlatesDB.healerIndicatorYPos or 0)

        -- Healer icon anchor dropdown
        local healerIndicatorDropdown = BBP.CreateAnchorDropdown(
            "healerIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
            "Select Anchor Point",
            "healerIndicatorAnchor",
            function(arg1)
                --print("Selected anchor:", arg1)
                BBP.RefreshAllNameplates()
            end,
            { anchorFrame = healerIndicatorYPosSlider2, x = -15, y = -35, label = "Anchor" }
        )
        
        -- Healer icon tester
        local checkBox_healerIndicatorTestMode2 = BBP.CreateCheckbox("healerIndicatorTestMode", "Test", BetterBlizzPlatesSubPanel)
        checkBox_healerIndicatorTestMode2:SetPoint("TOPLEFT", healerIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

        -- Only on enemy nameplate
        local checkBox_healerIndicatorEnemyOnly2 = BBP.CreateCheckbox("healerIndicatorEnemyOnly", "Enemies only", BetterBlizzPlatesSubPanel)
        checkBox_healerIndicatorEnemyOnly2:SetPoint("TOPLEFT", checkBox_healerIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)





        
        ------------------------------------------------------------------------------------------------
        -- Combat indicator
        ------------------------------------------------------------------------------------------------
        --Combat Indicator
        local anchorSubOutOfCombat = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubOutOfCombat:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 170, -60)
        anchorSubOutOfCombat:SetText("Combat Indicator")

        local combatIconSub = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
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
        local outOfCombatScaleSlider = BBP.CreateSlider("BetterBlizzPlates_outOfCombatScaleSlider", BetterBlizzPlatesSubPanel, "Size", 0.1, 1.9, 0.1, "combatIndicator")
        outOfCombatScaleSlider:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)
        outOfCombatScaleSlider:SetValue(BetterBlizzPlatesDB.combatIndicatorScale or 1)
    
        local outOfCombatXPosSlider = BBP.CreateSlider("BetterBlizzPlates_outOfCombatXPosSlider", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "combatIndicator", "X")
        outOfCombatXPosSlider:SetPoint("TOP", outOfCombatScaleSlider, "BOTTOM", 0, -15)
        outOfCombatXPosSlider:SetValue(BetterBlizzPlatesDB.combatIndicatorXPos or 0)
        
        local outOfCombatYPosSlider = BBP.CreateSlider("BetterBlizzPlates_outOfCombatYPosSlider", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "combatIndicator", "Y")
        outOfCombatYPosSlider:SetPoint("TOP", outOfCombatXPosSlider, "BOTTOM", 0, -15)
        outOfCombatYPosSlider:SetValue(BetterBlizzPlatesDB.combatIndicatorYPos or 0)
                
        -- For the Out of Combat Icon:
        local combatIndicatorDropdown = BBP.CreateAnchorDropdown(
            "combatIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
            "Select Anchor Point",
            "combatIndicatorAnchor",
            function(arg1) 
                --("Selected anchor for Out of Combat Indicator:", arg1);
                BBP.RefreshAllNameplates()
            end,
            { anchorFrame = outOfCombatYPosSlider, x = -15, y = -35, label = "Anchor" }
        )

        -- Only on enemy nameplate
        local checkBox_combatIndicatorEnemyOnly = BBP.CreateCheckbox("combatIndicatorEnemyOnly", "Enemies only", BetterBlizzPlatesSubPanel)
        checkBox_combatIndicatorEnemyOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

        -- Only in arena
        local checkBox_combatIndicatorArenaOnly = BBP.CreateCheckbox("combatIndicatorArenaOnly", "In arena only", BetterBlizzPlatesSubPanel)
        checkBox_combatIndicatorArenaOnly:SetPoint("TOPLEFT", checkBox_combatIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- use sap texture instead
        local checkBox_combatIndicatorSap = BBP.CreateCheckbox("combatIndicatorSap", "Use sap icon instead", BetterBlizzPlatesSubPanel) --combatIndicatorSap
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
        local checkBox_combatIndicatorPlayersOnly = BBP.CreateCheckbox("combatIndicatorPlayersOnly", "On players only", BetterBlizzPlatesSubPanel)
        checkBox_combatIndicatorPlayersOnly:SetPoint("TOPLEFT", checkBox_combatIndicatorSap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)








        ------------------------------------------------------------------------------------------------
        -- Hunter pet icon
        ------------------------------------------------------------------------------------------------
        --Hunter pet icon
        local anchorSubPet = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubPet:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 350, -60)
        anchorSubPet:SetText("Pet Indicator")

        local petIndicator2 = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
        petIndicator2:SetAtlas("newplayerchat-chaticon-newcomer")
        petIndicator2:SetSize(38, 38)
        petIndicator2:SetPoint("BOTTOM", anchorSubPet, "TOP", 0, 0)

        -- Pet icon scale slider2
        local petIndicatorScaleSlider = BBP.CreateSlider("BetterBlizzPlates_petIndicatorScaleSlider", BetterBlizzPlatesSubPanel, "Size", 0.1, 1.9, 0.1, "petIndicator")
        petIndicatorScaleSlider:SetPoint("TOP", anchorSubPet, "BOTTOM", 0, -15)
        petIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.petIndicatorScale)

        -- Pet x pos slider
        local petIndicatorXPosSlider = BBP.CreateSlider("BetterBlizzPlates_petIndicatorXPosSlider", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "petIndicator", "X")
        petIndicatorXPosSlider:SetPoint("TOP", petIndicatorScaleSlider, "BOTTOM", 0, -15)
        petIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.petIndicatorXPos or 0)

        -- Pet y pos slider
        local petIndicatorYPosSlider = BBP.CreateSlider("BetterBlizzPlates_petIndicatorYPosSlider", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "petIndicator", "Y")
        petIndicatorYPosSlider:SetPoint("TOP", petIndicatorXPosSlider, "BOTTOM", 0, -15)
        petIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.petIndicatorYPos or 0)

        -- Pet icon anchor dropdown
        local petIndicatorDropdown = BBP.CreateAnchorDropdown(
            "petIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
            "Select Anchor Point",
            "petIndicatorAnchor",
            function(arg1) --print("Selected anchor:", arg1);
            BBP.RefreshAllNameplates()
        end,
            { anchorFrame = petIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
        )

        -- Pet icon tester
        local checkBox_petIndicatorTestMode2 = BBP.CreateCheckbox("petIndicatorTestMode", "Test", BetterBlizzPlatesSubPanel)
        checkBox_petIndicatorTestMode2:SetPoint("TOPLEFT", petIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)








        ------------------------------------------------------------------------------------------------
        -- absorb indicator
        ------------------------------------------------------------------------------------------------
        --absorb Indicator
        local anchorSubAbsorb = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubAbsorb:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 510, -60)
        anchorSubAbsorb:SetText("Absorb Indicator")

        local absorbIndicator2 = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
        absorbIndicator2:SetAtlas("ParagonReputation_Glow")
        absorbIndicator2:SetSize(56, 56)
        absorbIndicator2:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)

        -- absorb icon scale slider2
        local absorbIndicatorScaleSlider = BBP.CreateSlider("BetterBlizzPlates_absorbIndicatorScaleSlider", BetterBlizzPlatesSubPanel, "Size", 0.1, 1.9, 0.1, "absorbIndicator")
        absorbIndicatorScaleSlider:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)
        absorbIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.absorbIndicatorScale or 1)

        -- absorb x pos slider
        local absorbIndicatorXPosSlider = BBP.CreateSlider("BetterBlizzPlates_absorbIndicatorXPosSlider", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "absorbIndicator", "X")
        absorbIndicatorXPosSlider:SetPoint("TOP", absorbIndicatorScaleSlider, "BOTTOM", 0, -15)
        absorbIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.absorbIndicatorXPos or 0)

        -- absorb y pos slider
        local absorbIndicatorYPosSlider = BBP.CreateSlider("BetterBlizzPlates_absorbIndicatorYPosSlider", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "absorbIndicator", "Y")
        absorbIndicatorYPosSlider:SetPoint("TOP", absorbIndicatorXPosSlider, "BOTTOM", 0, -15)
        absorbIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.absorbIndicatorYPos or 0)

        -- absorb icon anchor dropdown
        local absorbIndicatorDropdown = BBP.CreateAnchorDropdown(
            "absorbIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
            "Select Anchor Point",
            "absorbIndicatorAnchor",
            function(arg1) --print("Selected anchor:", arg1);
            BBP.RefreshAllNameplates()
        end,
            { anchorFrame = absorbIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
        )

        -- Absorb icon tester
        local checkBox_absorbIndicatorTestMode2 = BBP.CreateCheckbox("absorbIndicatorTestMode", "Test", BetterBlizzPlatesSubPanel)
        checkBox_absorbIndicatorTestMode2:SetPoint("TOPLEFT", absorbIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

        -- Only on enemy nameplate
        local checkBox_absorbIndicatorEnemyOnly = BBP.CreateCheckbox("absorbIndicatorEnemyOnly", "Enemies only", BetterBlizzPlatesSubPanel)
        checkBox_absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", checkBox_absorbIndicatorTestMode2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Only on player nameplates
        local checkBox_absorbIndicatorOnPlayersOnly = BBP.CreateCheckbox("absorbIndicatorOnPlayersOnly", "Players only", BetterBlizzPlatesSubPanel)
        checkBox_absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", checkBox_absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)








        ------------------------------------------------------------------------------------------------
        -- totem
        ------------------------------------------------------------------------------------------------
        --totem Indicator
        local anchorSubTotem = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubTotem:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 10, -360)
        anchorSubTotem:SetText("Totem Indicator")

        local totemIcon2 = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
        totemIcon2:SetAtlas("teleportationnetwork-ardenweald-32x32")
        totemIcon2:SetSize(44, 44)
        totemIcon2:SetPoint("BOTTOM", anchorSubTotem, "TOP", 0, 0)

        -- Totem Important Icon Size Slider
        local totemIndicatorScaleSlider = BBP.CreateSlider("BetterBlizzPlates_totemIndicatorScaleSlider", BetterBlizzPlatesSubPanel, "Size", 0.5, 3, 0.1, "totemIndicator")
        totemIndicatorScaleSlider:SetPoint("TOP", anchorSubTotem, "BOTTOM", 0, -15)
        totemIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.totemIndicatorScale or 1)

        -- totem x pos slider
        local totemIndicatorXPosSlider = BBP.CreateSlider("BetterBlizzPlates_totemIndicatorXPosSlider", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "totemIndicator", "X")
        totemIndicatorXPosSlider:SetPoint("TOP", totemIndicatorScaleSlider, "BOTTOM", 0, -15)
        totemIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.totemIndicatorXPos or 0)

        -- totem y pos slider
        local totemIndicatorYPosSlider = BBP.CreateSlider("BetterBlizzPlates_totemIndicatorYPosSlider", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "totemIndicator", "Y")
        totemIndicatorYPosSlider:SetPoint("TOP", totemIndicatorXPosSlider, "BOTTOM", 0, -15)
        totemIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.totemIndicatorYPos or 0)

        -- totem icon anchor dropdown
        local totemIndicatorDropdown = BBP.CreateAnchorDropdown(
            "totemIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
            "Select Anchor Point",
            "totemIndicatorAnchor",
            function(arg1) --print("Selected anchor:", arg1);
            BBP.RefreshAllNameplates()
        end,
            { anchorFrame = totemIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
        )

        -- Toggle to test totem icons
        local checkBox_totemTestIcons2 = BBP.CreateCheckbox("totemIndicatorTestMode", "Test", BetterBlizzPlatesSubPanel)
        checkBox_totemTestIcons2:SetPoint("TOPLEFT", totemIndicatorDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)

        -- Shift icon down and remove name
        local checkBox_totemIndicatorHideNameAndShiftIconDown = BBP.CreateCheckbox("totemIndicatorHideNameAndShiftIconDown", "Hide name", BetterBlizzPlatesSubPanel)
        checkBox_totemIndicatorHideNameAndShiftIconDown:SetPoint("TOPLEFT", checkBox_totemTestIcons2, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Glow off
        local checkBox_totemIndicatorGlowOff = BBP.CreateCheckbox("totemIndicatorGlowOff", "No glow", BetterBlizzPlatesSubPanel)
        checkBox_totemIndicatorGlowOff:SetPoint("TOPLEFT", checkBox_totemIndicatorHideNameAndShiftIconDown, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

        -- Scale up important npcs
        local checkBox_totemIndicatorScaleUpImportant = BBP.CreateCheckbox("totemIndicatorScaleUpImportant", "Scale up important", BetterBlizzPlatesSubPanel)
        checkBox_totemIndicatorScaleUpImportant:SetPoint("TOPLEFT", checkBox_totemIndicatorGlowOff, "BOTTOMLEFT", 0, pixelsBetweenBoxes)







        ------------------------------------------------------------------------------------------------
        -- Target indicator
        ------------------------------------------------------------------------------------------------
        --Target indicator
        local anchorSubTarget = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubTarget:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 170, -360)
        anchorSubTarget:SetText("Target Indicator")

        local targetIndicator2 = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
        targetIndicator2:SetAtlas("Navigation-Tracked-Arrow")
        targetIndicator2:SetRotation(math.rad(180))
        targetIndicator2:SetSize(48, 32)
        targetIndicator2:SetPoint("BOTTOM", anchorSubTarget, "TOP", -1, 2)

        -- Target indicator scale slider2
        local targetIndicatorScaleSlider = BBP.CreateSlider("BetterBlizzPlates_targetIndicatorScaleSlider", BetterBlizzPlatesSubPanel, "Size", 0.1, 1.9, 0.1, "targetIndicator")
        targetIndicatorScaleSlider:SetPoint("TOP", anchorSubTarget, "BOTTOM", 0, -15)
        targetIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.targetIndicatorScale)

        -- Target indicator x pos slider
        local targetIndicatorXPosSlider = BBP.CreateSlider("BetterBlizzPlates_targetIndicatorXPosSlider", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "targetIndicator", "X")
        targetIndicatorXPosSlider:SetPoint("TOP", targetIndicatorScaleSlider, "BOTTOM", 0, -15)
        targetIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.targetIndicatorXPos or 0)

        -- Target indicator y pos slider
        local targetIndicatorYPosSlider = BBP.CreateSlider("BetterBlizzPlates_targetIndicatorYPosSlider", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "targetIndicator", "Y")
        targetIndicatorYPosSlider:SetPoint("TOP", targetIndicatorXPosSlider, "BOTTOM", 0, -15)
        targetIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.targetIndicatorYPos)

        -- Target indicator icon anchor dropdown
        local targetIndicatorDropdown = BBP.CreateAnchorDropdown(
            "targetIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
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
        local anchorSubRaidmark = BetterBlizzPlatesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        anchorSubRaidmark:SetPoint("TOPLEFT", mainGuiAnchor2, "CENTER", 350, -360)
        anchorSubRaidmark:SetText("Raidmarker")

        local raidmarkIcon = BetterBlizzPlatesSubPanel:CreateTexture(nil, "ARTWORK")
        raidmarkIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_3")
        raidmarkIcon:SetSize(38, 38)
        raidmarkIcon:SetPoint("BOTTOM", anchorSubRaidmark, "TOP", 0, 0)

        -- Raid Indicator scale slider2
        local raidmarkIndicatorScaleSlider = BBP.CreateSlider("BetterBlizzPlates_raidmarkIndicatorScaleSlider", BetterBlizzPlatesSubPanel, "Size", 0.6, 2.5, 0.1, "raidmarkIndicator")
        raidmarkIndicatorScaleSlider:SetPoint("TOP", anchorSubRaidmark, "BOTTOM", 0, -15)
        raidmarkIndicatorScaleSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorScale)

        -- Raid x pos slider
        local raidmarkIndicatorXPosSlider = BBP.CreateSlider("BetterBlizzPlates_raidmarkIndicatorXPosSlider", BetterBlizzPlatesSubPanel, "x offset", -50, 50, 1, "raidmarkIndicator", "X")
        raidmarkIndicatorXPosSlider:SetPoint("TOP", raidmarkIndicatorScaleSlider, "BOTTOM", 0, -15)
        raidmarkIndicatorXPosSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorXPos or 0)

        -- Raid y pos slider
        local raidmarkIndicatorYPosSlider = BBP.CreateSlider("BetterBlizzPlates_raidmarkIndicatorYPosSlider", BetterBlizzPlatesSubPanel, "y offset", -50, 50, 1, "raidmarkIndicator", "Y")
        raidmarkIndicatorYPosSlider:SetPoint("TOP", raidmarkIndicatorXPosSlider, "BOTTOM", 0, -15)
        raidmarkIndicatorYPosSlider:SetValue(BetterBlizzPlatesDB.raidmarkIndicatorYPos or 0)

        -- Raid Indicator anchor dropdown
        local raidmarkIndicatorDropdown = BBP.CreateAnchorDropdown(
            "raidmarkIndicatorDropdown",
            BetterBlizzPlatesSubPanel,
            "Select Anchor Point",
            "raidmarkIndicatorAnchor",
            function(arg1) --print("Selected anchor:", arg1);
            BBP.RefreshAllNameplates()
        end,
            { anchorFrame = raidmarkIndicatorYPosSlider, x = -15, y = -35, label = "Anchor" }
        )

        local btn_reload_ui2 = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel, "UIPanelButtonTemplate")
        btn_reload_ui2:SetText("Reload UI")
        btn_reload_ui2:SetWidth(85)
        btn_reload_ui2:SetPoint("TOP", BetterBlizzPlatesSubPanel, "BOTTOMRIGHT", -140, -9)
        btn_reload_ui2:SetScript("OnClick", function()
            BetterBlizzPlatesDB.reopenOptions = true
            ReloadUI()
        end)


        ------------------------------------------------------------------------------------------------
        -- Fade out NPC
        ------------------------------------------------------------------------------------------------
        -- Fade out NPC
        local BetterBlizzPlatesSubPanel2 = CreateFrame("Frame")
        BetterBlizzPlatesSubPanel2.name = "Fade out NPC"
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


        createScrollFrame(BetterBlizzPlatesSubPanel2, "fadeOutNPCsList", BetterBlizzPlatesDB.fadeOutNPCsList, BBP.RefreshAllNameplates)

        local how2usefade = BetterBlizzPlatesSubPanel2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        how2usefade:SetPoint("TOP", mainGuiAnchor3, "BOTTOM", 140, -450)
        how2usefade:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

        -- fade out nameplate alpha slider
        local fadeOutNPCsAlphaSlider = BBP.CreateSlider("BetterBlizzPlates_fadeOutNPCsAlphaSlider", BetterBlizzPlatesSubPanel2, "Alpha value", 0, 1, 0.05, "fadeOutNPCsAlpha", "Alpha")
        fadeOutNPCsAlphaSlider:SetPoint("TOPRIGHT", BetterBlizzPlatesSubPanel2, "TOPRIGHT", -90, -90)
        fadeOutNPCsAlphaSlider:SetValue(BetterBlizzPlatesDB.fadeOutNPCsAlpha or 0.2)

        
        -- Restore default entries
        local restoreDefaultsButton = CreateFrame("Button", nil, BetterBlizzPlatesSubPanel2, "UIPanelButtonTemplate")
        restoreDefaultsButton:SetSize(150, 30)
        restoreDefaultsButton:SetPoint("BOTTOM", fadeOutNPCsAlphaSlider, "TOP", 0, 30)
        restoreDefaultsButton:SetText("Restore Default Entries")
        restoreDefaultsButton:SetScript("OnClick", function()
            local defaultFadeOutNPCsList = BBP.GetDefaultFadeOutNPCsList()
            for _, defaultNPC in ipairs(defaultFadeOutNPCsList) do
                local isFound = false
                for _, userNPC in ipairs(BetterBlizzPlatesDB.fadeOutNPCsList) do
                    if defaultNPC.id == userNPC.id then
                        isFound = true
                        break
                    end
                end
                if not isFound then
                    addOrUpdateEntry(defaultNPC.id, defaultNPC.name, defaultNPC.comment)
                end
            end
        end)

        local noteFade = BetterBlizzPlatesSubPanel2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noteFade:SetPoint("TOP", fadeOutNPCsAlphaSlider, "BOTTOM", 0, -20)
        noteFade:SetText("This only makes nameplates transparent.\n \nYou will still be able to click them\neven though you can't see them.\n \nIf you wish to completely get rid of a\nnameplate use Hide NPC list instead")

        -- Fade out unimportant npcs in arena
        checkBox_fadeOutNPCs2 = BBP.CreateCheckbox("fadeOutNPC", "Fade out NPC nameplates from list", BetterBlizzPlatesSubPanel2, nil, BBP.FadeOutNPCs)
        checkBox_fadeOutNPCs2:SetPoint("TOPLEFT", noteFade, "BOTTOMLEFT", 20, -15)



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





        createScrollFrame(BetterBlizzPlatesSubPanel3, "hideNPCsList", BetterBlizzPlatesDB.hideNPCsList, BBP.RefreshAllNameplates)


        local how2useHide = BetterBlizzPlatesSubPanel3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        how2useHide:SetPoint("TOP", mainGuiAnchor4, "BOTTOM", 140, -450)
        how2useHide:SetText("Add name or npcID. Case-insensitive.\n \n \nAdd a comment to the entry with slash\nfor example 1337/comment or xuen/monk tiger\n \nType a name or npcID already in list to delete it")

        local noteHide = BetterBlizzPlatesSubPanel3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noteHide:SetPoint("TOP", BetterBlizzPlatesSubPanel3, "TOP", 172, -127)
        noteHide:SetText("This completely hides nameplates.\n \nYou will not be able to click them\n \nIf you wish to fade out and still be able\nto click them use Fade out NPC instead")


        -- Hide NPC list
        checkBox_hideNPCs = BBP.CreateCheckbox("hideNPC", "Hide NPC nameplates from list", BetterBlizzPlatesSubPanel3, nil, BBP.HideNPCs)
        checkBox_hideNPCs:SetPoint("TOPLEFT", noteHide, "BOTTOMLEFT", 25, -15)


















        ------------------------------------------------------------------------------------------------
        -- More Blizz Settings
        ------------------------------------------------------------------------------------------------
        -- More Blizz Settings
        local BetterBlizzPlatesSubPanel4 = CreateFrame("Frame")
        BetterBlizzPlatesSubPanel4.name = "More Blizz Settings"
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
        mainGuiAnchor5:SetPoint("TOPLEFT", 15, -15)
        mainGuiAnchor5:SetText(" ")

        local moreBlizzSettings = BetterBlizzPlatesSubPanel4:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        moreBlizzSettings:SetPoint("TOPLEFT", mainGuiAnchor5, "TOPLEFT", -10, 10)
        moreBlizzSettings:SetText("Settings not available in Blizzard's standard UI")

        local stackingNameplatesText = BetterBlizzPlatesSubPanel4:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        stackingNameplatesText:SetPoint("TOPLEFT", mainGuiAnchor5, "BOTTOMLEFT", 0, -5)
        stackingNameplatesText:SetText("Stacking nameplate overlap amount")

        -- Nameplate Horizontal Overlap
        local stackingNameplateOverlapHorizontal = BBP.CreateSlider("BetterBlizzPlates_nameplateOverlapH", BetterBlizzPlatesSubPanel4, "Space between nameplates horizontally", 0.05, 1, 0.05, "nameplateOverlapH")
        stackingNameplateOverlapHorizontal:SetPoint("TOP", stackingNameplatesText, "BOTTOM", 0, -20)
        stackingNameplateOverlapHorizontal:SetValue(BetterBlizzPlatesDB.nameplateOverlapH)

        -- Nameplate Vertical Overlap
        local stackingNameplateOverlapVertical = BBP.CreateSlider("BetterBlizzPlates_nameplateOverlapV", BetterBlizzPlatesSubPanel4, "Space between nameplates vertically", 0.05, 1.1, 0.05, "nameplateOverlapV")
        stackingNameplateOverlapVertical:SetPoint("TOPLEFT", stackingNameplateOverlapHorizontal, "BOTTOMLEFT", 0, -20)
        stackingNameplateOverlapVertical:SetValue(BetterBlizzPlatesDB.nameplateOverlapV)

        -- Nameplate Motion Speed
        local nameplateMotionSpeed = BBP.CreateSlider("BetterBlizzPlates_nameplateMotionSpeed", BetterBlizzPlatesSubPanel4, "Nameplate motion speed", 0.01, 1, 0.01, "nameplateMotionSpeed")
        nameplateMotionSpeed:SetPoint("TOPLEFT", stackingNameplateOverlapVertical, "BOTTOMLEFT", 0, -20)
        nameplateMotionSpeed:SetValue(BetterBlizzPlatesDB.nameplateMotionSpeed)

        -- WIP text
        local moreBlizzSettings = BetterBlizzPlatesSubPanel4:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        moreBlizzSettings:SetPoint("BOTTOM", BetterBlizzPlatesSubPanel4, "BOTTOM", 0, 10)
        moreBlizzSettings:SetText("Work in progress, more stuff inc soon™\nIf you have any suggestions feel free to\nleave a comment on CurseForge")
    end
end