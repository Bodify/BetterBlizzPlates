local addonName = ... ---@type string

---@class BetterBlizzPlates: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Callback
---@field cb fun(...)
---@field a any
local callbackProto = {}

---@class Events: AceModule
---@field _eventHandler AceEvent-3.0
---@field _events table<string, {fn: fun(...), cbs: Callback[]}>
local events = addon:NewModule('Events')

function events:OnInitialize()
  self._eventHandler = {}
  self._events = {}
  LibStub:GetLibrary('AceEvent-3.0'):Embed(self._eventHandler)
end

function events:RegisterEvent(event, callback, arg)
  if self._events[event] == nil then
    self._events[event] = {
      fn = function(...)
        for _, cb in pairs(self._events[event].cbs) do
          if cb.a ~= nil then
            cb.cb(cb.a, ...)
          else
            cb.cb(...)
          end
        end
      end,
      cbs = {},
    }
    self._eventHandler:RegisterEvent(event, self._events[event].fn)
  end
  table.insert(self._events[event].cbs, {cb = callback, a = arg})
end

function events:UnregisterEvent(event)
    self._events[event] = nil
    self._eventHandler.UnregisterEvent(self, event)
    print("UnregisterEvent: " .. event)
end

events:Enable()