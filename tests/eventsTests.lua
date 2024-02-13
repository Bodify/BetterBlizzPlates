--#region Setup
local addonName = ... ---@type string

---@class BetterBlizzPlates: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Events: AceModule
local events = addon:GetModule("Events")

---@class EventsTests: AceModule
local eventsTests = addon:NewModule("EventsTests")

eventsTests:SetDefaultModuleState(false)
--#endregion


--#region Local variables and helper functions
local event = "NAME_PLATE_UNIT_ADDED"

---@param arg number
local function registerEvent(arg)
    events:RegisterEvent(event, print(arg))
end

local function testCallback()
    print("Test callback")
end
--#endregion


--#region Test functions
local function testRegisterEvent()
    events._events = {}
    registerEvent(1)
    assert(#events._events[event].cbs == 1, "TestRegisterEvent1")
    registerEvent(2)
    assert(#events._events[event].cbs == 2, "TestRegisterEvent2")
    registerEvent(3)
    assert(#events._events[event].cbs == 3, "TestRegisterEvent2")
end

local function testUnregisterEvent()
    events._events = {}
    registerEvent(1)
    registerEvent(2)
    events:RegisterEvent(event, testCallback)
    assert(#events._events[event].cbs == 3)
    assert(events._events[event].cbs[3].cb == testCallback)

    events:UnregisterEvent(event, testCallback)
    assert(#events._events[event].cbs == 2)
    table.foreach(events._events[event].cbs, function (_, value)
        assert(value ~= testCallback)
    end)
end
--#endregion

function eventsTests:OnInitialize()
    testRegisterEvent()
    testUnregisterEvent()
end
