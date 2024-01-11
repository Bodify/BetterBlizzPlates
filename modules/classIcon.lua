-- Setting up the database
BetterBlizzPlatesDB = BetterBlizzPlatesDB or {}
BBP = BBP or {}

-- Healer spec id's
local HealerSpecs = {
    [105]  = true,  --> druid resto
    [270]  = true,  --> monk mw
    [65]   = true,  --> paladin holy
    [256]  = true,  --> priest disc
    [257]  = true,  --> priest holy
    [264]  = true,  --> shaman resto
    [1468] = true,  --> preservation evoker  
}

-- Class Indicator
function BBP.ClassIndicator(frame, fetchedSpecID)
    local anchorPoint
    local oppositeAnchor
    local xPos
    local yPos
    local scale
    local inInstance, instanceType = IsInInstance()
    local arenaOnly = BetterBlizzPlatesDB.classIconArenaOnly
    local bgOnly = BetterBlizzPlatesDB.classIconBgOnly
    local friendlyOnly = BetterBlizzPlatesDB.classIndicatorFriendly
    local enemyOnly = BetterBlizzPlatesDB.classIndicatorEnemy
    local useSpecIcon = BetterBlizzPlatesDB.classIndicatorSpecIcon
    local showHealerIcon = BetterBlizzPlatesDB.classIndicatorHealer
    local squareIcon = BetterBlizzPlatesDB.classIconSquareBorder

    -- Initialize Class Icon Frame
    if not frame.classIndicator then
        frame.classIndicator = CreateFrame("Frame", nil, frame)
        frame.classIndicator:SetSize(24, 24)
        --frame.classIndicator:SetScale(scale)
        frame.classIndicator.icon = frame.classIndicator:CreateTexture(nil, "BORDER")
        frame.classIndicator.icon:SetPoint("CENTER", frame.classIndicator)
        frame.classIndicator.mask = frame.classIndicator:CreateMaskTexture()
        frame.classIndicator.border = frame.classIndicator:CreateTexture(nil, "OVERLAY")
        frame.classIndicator:SetFrameStrata("HIGH")
    end

    local isFriendly = UnitIsFriend("player", frame.unit)
    local isEnemy = not isFriendly
    local isPlayer = UnitIsPlayer(frame.unit)
    local isUser = UnitIsUnit(frame.unit, "player")

    if isUser then
        frame.classIndicator:Hide()
        return
    end

    if not isPlayer then
        frame.classIndicator:Hide()
        return
    end

    if (isFriendly and not friendlyOnly) or (isEnemy and not enemyOnly) then
        frame.classIndicator:Hide()
        return
    end

    -- Configure for square or circle border and apply mask
    if squareIcon then
        scale = scale + 0.2
        frame.classIndicator.icon:SetSize(20, 20)
        frame.classIndicator.mask:SetAtlas("UI-Frame-IconMask")
        frame.classIndicator.mask:SetSize(20, 20)
        frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
        frame.classIndicator.border:SetAtlas("UI-HUD-ActionBar-IconFrame-AddRow")
        frame.classIndicator.border:SetSize(23, 23)
        frame.classIndicator.border:ClearAllPoints()
        frame.classIndicator.border:SetPoint("CENTER", frame.classIndicator.icon, 1.5, -1.5)
    else
        frame.classIndicator.icon:SetSize(24, 24)
        frame.classIndicator.mask:SetTexture("Interface/Masks/CircleMaskScalable")
        frame.classIndicator.mask:SetSize(24, 24)
        frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)
        frame.classIndicator.border:SetAtlas("ui-frame-genericplayerchoice-portrait-border")
        frame.classIndicator.border:SetAllPoints(frame.classIndicator)
    end

    frame.classIndicator.icon:AddMaskTexture(frame.classIndicator.mask)

    frame.classIndicator.icon:SetPoint("CENTER", frame.classIndicator)
    frame.classIndicator.mask:SetPoint("CENTER", frame.classIndicator.icon)

    -- Set position and scale dynamically
    if isFriendly then
        anchorPoint = BetterBlizzPlatesDB.classIndicatorFriendlyAnchor
        oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
        xPos = BetterBlizzPlatesDB.classIndicatorFriendlyXPos
        yPos = BetterBlizzPlatesDB.classIndicatorFriendlyYPos + (anchorPoint == "TOP" and 2 or 0)
        scale = BetterBlizzPlatesDB.classIndicatorFriendlyScale + 0.3
    elseif isEnemy then
        anchorPoint = BetterBlizzPlatesDB.classIndicatorAnchor
        oppositeAnchor = BBP.GetOppositeAnchor(anchorPoint)
        xPos = BetterBlizzPlatesDB.classIndicatorXPos
        yPos = BetterBlizzPlatesDB.classIndicatorYPos + (anchorPoint == "TOP" and 2 or 0)
        scale = BetterBlizzPlatesDB.classIndicatorScale + 0.3
    end

    frame.classIndicator:ClearAllPoints()
    if anchorPoint == "TOP" then
        frame.classIndicator:SetPoint(oppositeAnchor, frame.name, anchorPoint, xPos, yPos)
    else
        frame.classIndicator:SetPoint(oppositeAnchor, frame.healthBar, anchorPoint, xPos, yPos)
    end
    frame.classIndicator:SetScale(scale)

    -- Visibility checks
    if (arenaOnly and not (inInstance and instanceType == "arena")) or (bgOnly and not (inInstance and instanceType == "pvp")) then
        frame.classIndicator:Hide()
        return
    end

    -- Get class from the unit frame
    local unit = frame.unit or frame.displayedUnit
    local _, class = UnitClass(unit)
    if not class then
        frame.classIndicator:Hide()
        return
    end

    -- Get class icon texture and coordinates
    local classIcon = "Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES"
    local classColor = RAID_CLASS_COLORS[class]
    local coords = CLASS_ICON_TCOORDS[class]
    if not coords then
        frame.classIndicator:Hide()
        return
    end

    local specIcon
    local specID = fetchedSpecID
    local Details = Details
    if useSpecIcon or showHealerIcon then
        if not specID then
            if isFriendly and Details then
                local unitGUID = UnitGUID(frame.displayedUnit)
                if Details then
                    specID = Details:GetSpecByGUID(unitGUID)
                end
                if specID then
                    specIcon = select(4, GetSpecializationInfoByID(specID))
                end
            elseif isEnemy and IsActiveBattlefieldArena() then
                for i = 1, 3 do
                    local arenaUnit = "arena" .. i
                    if UnitIsUnit(frame.displayedUnit, arenaUnit) then
                        specID = GetArenaOpponentSpec(i)
                        if specID then
                            specIcon = select(4, GetSpecializationInfoByID(specID))
                            break
                        end
                    end
                end
            elseif isEnemy then
                local unitGUID = UnitGUID(frame.displayedUnit)
                if Details then
                    specID = Details:GetSpecByGUID(unitGUID)
                end
                if specID then
                    specIcon = select(4, GetSpecializationInfoByID(specID))
                end
            end
        else
            specIcon = select(4, GetSpecializationInfoByID(specID))
        end
    end

    -- Set class icon texture and coordinates
    if specIcon and useSpecIcon then
        if showHealerIcon then
            if HealerSpecs[specID] then
                if not squareIcon then
                    frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                    frame.classIndicator.icon:SetTexCoord(0.005, 0.116, 0.76, 0.87)
                else
                    frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                    frame.classIndicator.icon:SetTexCoord(0.0185, 0.103, 0.772, 0.856)
                end
            else
                frame.classIndicator.icon:SetTexture(specIcon)
                frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
            end
        else
            frame.classIndicator.icon:SetTexture(specIcon)
            frame.classIndicator.icon:SetTexCoord(0, 1, 0, 1)
        end
    elseif showHealerIcon then
        if HealerSpecs[specID] then
            if not squareIcon then
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.005, 0.116, 0.76, 0.87)
            else
                frame.classIndicator.icon:SetTexture("interface/lfgframe/uilfgprompts")
                frame.classIndicator.icon:SetTexCoord(0.0185, 0.103, 0.772, 0.856)
            end
        else
            frame.classIndicator.icon:SetTexture(classIcon)
            frame.classIndicator.icon:SetTexCoord(unpack(coords))
        end
    else
        frame.classIndicator.icon:SetTexture(classIcon)
        frame.classIndicator.icon:SetTexCoord(unpack(coords))
    end

    -- Optional class coloring for the border
    if BetterBlizzPlatesDB.classIconColorBorder then
        frame.classIndicator.border:SetDesaturated(true)
        frame.classIndicator.border:SetVertexColor(classColor.r, classColor.g, classColor.b)
    else
        frame.classIndicator.border:SetDesaturated(false)
        frame.classIndicator.border:SetVertexColor(1, 1, 1)
    end

    -- Show the class icon frame
    frame.classIndicator:Show()
end
