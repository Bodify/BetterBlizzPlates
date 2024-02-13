-- boot.lua handles the initialisation of the addon and the creation of the root module.

local addonName = ... ---@type string

---@class BetterBlizzPlates: AceModule
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, 'AceHook-3.0')
