local eraShamanColor
if BBP.isEra then
    eraShamanColor = CreateColor(0, 0.44, 0.87)
    eraShamanColor.colorStr = eraShamanColor:GenerateHexColor()
end

function BBP.GetClassColor(class)
    if eraShamanColor and class == "SHAMAN" and BetterBlizzPlatesDB.colorShamansBlue then
        return eraShamanColor
    end
    return RAID_CLASS_COLORS[class]
end
