local addonName = ... ---@type string

---@class BetterBlizzPlates: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Tests: AceModule
local tests = addon:NewModule("Tests")

---@class EventsTests: AceModule
local eventsTests = addon:GetModule("EventsTests")

tests:SetDefaultModuleState(false)

function tests:OnInitialize()
    eventsTests:Enable()
end

