-- local function GetRangeTextColor(unit)
--     local minrange, maxrange = WeakAuras.GetRange(unit)

--     if minrange and maxrange then
--         if maxrange < 8 then
--             return "", 0, 0, 0 -- Hide the text for ranges below 8 yards
--         elseif maxrange <= 8 then
--             return "8", 0, 1, 0 -- Green color for 0-8 yards
--         elseif maxrange <= 10 then
--             return "10", 0.5, 1, 0 -- Lime green color for 8-10 yards
--         elseif maxrange <= 15 then
--             return "15", 1, 1, 0 -- Yellow color for 10-15 yards
--         elseif maxrange <= 20 then
--             return "20", 1, 0.75, 0 -- Light orange color for 15-20 yards
--         elseif maxrange <= 25 then
--             return "25", 1, 0.5, 0 -- Orange color for 20-25 yards
--         elseif maxrange <= 30 then
--             return "30", 1, 0.25, 0 -- Dark orange color for 25-30 yards
--         elseif maxrange <= 35 then
--             return "35", 1, 0, 0 -- Red color for 30-35 yards
--         elseif maxrange <= 40 then
--             return "40", 0.5, 0, 0 -- Dark red color for 35-40 yards
--         end
--     end

--     return "", 1, 0, 0 -- Red color for unknown range
-- end

-- -- Function to update range indicator
-- local function UpdateRangeIndicator(frame)
--     local rangeText, r, g, b = GetRangeTextColor(frame.unit)
--     frame.rangeIndicator:SetText(rangeText)
--     frame.rangeIndicator:SetTextColor(r, g, b)
-- end

-- Range Indicator
function BBP.RangeIndicator(frame)
    -- local config = frame.BetterBlizzPlates.config

    -- if not config.rangeIndicatorInitialized or BBP.needsUpdate then
    --     config.rangeIndicatorAnchor = BetterBlizzPlatesDB.rangeIndicatorAnchor or "CENTER"
    --     config.rangeIndicatorXPos = BetterBlizzPlatesDB.rangeIndicatorXPos or 0
    --     config.rangeIndicatorYPos = BetterBlizzPlatesDB.rangeIndicatorYPos or 0
    --     config.rangeIndicatorTestMode = BetterBlizzPlatesDB.rangeIndicatorTestMode
    --     config.rangeIndicatorScale = BetterBlizzPlatesDB.rangeIndicatorScale or 1

    --     config.rangeIndicatorInitialized = true
    -- end

    -- if not frame.rangeIndicator then
    --     frame.rangeIndicator = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    --     frame.rangeIndicator:SetPoint("CENTER", frame.healthBar, config.rangeIndicatorAnchor, config.rangeIndicatorXPos, config.rangeIndicatorYPos)
    --     frame.rangeIndicator:SetScale(config.rangeIndicatorScale)
    -- end

    -- -- Test mode
    -- if config.rangeIndicatorTestMode then
    --     frame.rangeIndicator:SetText("30")
    --     frame.rangeIndicator:SetTextColor(0, 1, 0) -- Green color for test
    --     frame.rangeIndicator:Show()
    --     return
    -- end

    -- UpdateRangeIndicator(frame)
    -- frame.rangeIndicator:Show()
end

-- -- Function to update all nameplates
-- local function UpdateAllNameplates()
--     for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
--         local frame = nameplate.UnitFrame
--         if frame and frame.unit then
--             UpdateRangeIndicator(frame)
--         end
--     end
-- end

-- -- Initialize and set up the repeating timer
-- local function InitializeRangeIndicator()
--     C_Timer.NewTicker(0.1, UpdateAllNameplates)
-- end

-- InitializeRangeIndicator()