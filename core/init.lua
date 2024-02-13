---@diagnostic disable: duplicate-set-field,duplicate-doc-field
local addonName = ... ---@type string

---@class BetterBlizzPlates: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)
---@cast addon +AceHook-3.0

---@class Events: AceModule
local events = addon:GetModule("Events")


function addon:OnInitialize()
    print("BBP Initialized.")
end

function addon:OnEnable()
    local enableTests = false
    if enableTests then
        addon:GetModule("Tests"):Enable()
    else
        -- enable other modules
    end
end