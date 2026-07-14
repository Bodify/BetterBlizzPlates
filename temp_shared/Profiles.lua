-- Profiles.lua
--
-- User-managed profiles for BetterBlizzPlates (see .claude/specs/profiles.md).
-- Loaded by every flavor TOC immediately after init.lua, so this file's
-- ADDON_LOADED handler is registered BEFORE the main file's and therefore runs
-- first: it migrates the saved variable to the profile structure and rebinds the
-- global BetterBlizzPlatesDB to the active profile table before any settings are
-- read. On PLAYER_LOGOUT the global is swapped back to the full root so WoW
-- serializes the whole structure to disk ("logout swap").
--
-- Data model (root = the on-disk saved variable BetterBlizzPlatesDB):
--   root.profiles    = { ["Default"] = { ...flat settings... }, ... }
--   root.profileKeys = { ["Name - Realm"] = "Default", ... }
--   root.global      = { ...account-level housekeeping (unused for now)... }
--   root.dbVersion   = 2

local ADDON = "BetterBlizzPlates"

-- Root-level keys that are NOT part of a profile's flat settings.
local RESERVED = {
    profiles = true,
    profileKeys = true,
    global = true,
    dbVersion = true,
}

--#########################################
-- Helpers

-- Deep copy that handles nested tables (aura lists, npc lists, etc.).
local function DeepCopy(src)
    if type(src) ~= "table" then
        return src
    end
    local dst = {}
    for k, v in pairs(src) do
        dst[k] = DeepCopy(v)
    end
    return dst
end
BBP.DeepCopyTable = DeepCopy

-- Empty a table WITHOUT changing its identity, so references held elsewhere
-- (the rebound global, root.profiles[key]) keep pointing at the same table.
local function WipeInPlace(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

local function Trim(s)
    if type(s) ~= "string" then return "" end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- charKey: "Name - Realm" (AceDB-compatible). Built no earlier than our own
-- ADDON_LOADED. Returns nil if EITHER the player name OR the realm is not yet
-- available/known (should not happen on current clients; guarded so we never
-- concat a nil and, critically, never persist a placeholder like "Name - Unknown"
-- as a sticky profileKeys assignment). A nil return triggers the deferred
-- activation path (provisional binding now, retry at PLAYER_LOGIN).
local function BuildCharKey()
    local name = UnitName("player")
    if not name or name == "" or name == UNKNOWN or name == UNKNOWNOBJECT then
        return nil
    end
    local realm = GetRealmName()
    if not realm or realm == "" or realm == UNKNOWN or realm == UNKNOWNOBJECT then
        return nil
    end
    return name .. " - " .. realm
end

--#########################################
-- Migration (run once, idempotent, before anything reads settings)

local function Migrate(root)
    -- Sentinel: presence of .profiles means we already migrated.
    if root.profiles then
        return
    end

    local default = {}
    local moved = {}
    -- Copy every existing flat key into Default...
    for k, v in pairs(root) do
        if not RESERVED[k] then
            default[k] = v
            moved[#moved + 1] = k
        end
    end
    -- ...then remove them from the root (move, not copy). Setting existing
    -- fields to nil during traversal is allowed in Lua 5.1, but we collected
    -- keys first to keep this unambiguous.
    for _, k in ipairs(moved) do
        root[k] = nil
    end

    root.profiles = { Default = default }
    root.profileKeys = {}
    root.global = {}
    root.dbVersion = 2
end

--#########################################
-- Activation + the rebind

local function EnsureStructure(root)
    root.profiles = root.profiles or {}
    if not root.profiles.Default then
        root.profiles.Default = {}
    end
    root.profileKeys = root.profileKeys or {}
    root.global = root.global or {}
end

-- Resolve which profile a (possibly nil) charKey maps to. Never persists.
local function ResolveActiveKey(root, charKey)
    if charKey then
        local assigned = root.profileKeys[charKey]
        if assigned and root.profiles[assigned] then
            return assigned
        end
    end
    -- No identity, no assignment, or the assigned profile was deleted.
    return "Default"
end

-- Second-chance activation at PLAYER_LOGIN, used ONLY when identity was not
-- available at our ADDON_LOADED (Classic Era timing risk). At PLAYER_LOGIN
-- UnitName("player")/GetRealmName() are guaranteed populated. Nothing between
-- ADDON_LOADED and PLAYER_LOGIN captures the profile table long-term (every
-- `local db = BetterBlizzPlatesDB` alias is function-local and re-read per call),
-- so swapping the global here is seen by all subsequent reads, including the
-- PLAYER_ENTERING_WORLD handlers (which fire AFTER PLAYER_LOGIN) that apply
-- nameplate settings. Note: the main file's own file-scope PLAYER_LOGIN handler
-- was registered before ours and thus runs first against the SCRATCH binding;
-- because the equality branch below ADOPTS the scratch AS the persisted profile
-- table (rather than copying out of it), every write made against the scratch —
-- by that earlier handler AND by any delayed closures captured during boot — is
-- kept, because the scratch itself is what ends up serialized. This path only
-- triggers in the rare unresolved case.
local function ReactivateAtLogin(root)
    local charKey = BuildCharKey()
    if not charKey then
        -- Still unresolvable (defensive; should be impossible at PLAYER_LOGIN).
        -- Stay on the SCRATCH binding for the rest of the session and persist
        -- NOTHING: BBP.charKey remains nil so SetProfile prints a clear error, and
        -- since the scratch is never stored in root.profiles nor serialized, the
        -- session is effectively SANDBOXED — all changes are discarded at logout.
        -- This matches the existing SetProfile "identity unavailable" behavior.
        return
    end

    local activeKey = ResolveActiveKey(root, charKey)
    BBP.charKey = charKey
    root.profileKeys[charKey] = activeKey

    -- Branch on KEYS, not table identity: the current global is the SCRATCH (a deep
    -- copy, so it never equals a persisted profile table). hintKey is the profile
    -- the scratch was copied FROM (recorded as BBP.activeProfileKey in Activate).
    local hintKey = BBP.activeProfileKey
    local scratch = BBP.profileScratch

    if activeKey == hintKey then
        -- CONVERGENT COMMON CASE: the scratch was copied from the CORRECT profile
        -- for this character, so every write the session made to it (the additive
        -- default-merge, one-shot migration flags, list updates, reopenOptions
        -- clearing, font/CVar captures) is EXACTLY what a normal boot would have
        -- written to this profile. Promote by ADOPTION: make the scratch itself the
        -- persisted profile table (root.profiles[activeKey] = scratch) and leave the
        -- global pointed at the scratch (Activate already bound it there). The old
        -- persisted table for activeKey is discarded.
        --
        -- WHY adoption instead of the previous wipe-in-place + copy-contents-out:
        -- the copy approach kept the persisted table's identity but orphaned the
        -- SCRATCH object, and closures created during ADDON_LOADED (delayed popup
        -- callbacks, retry tickers — e.g. midnight's popup handlers and era's ticker
        -- that captured `local db = BetterBlizzPlatesDB`) still alias the scratch.
        -- After a copy-based promotion those captured aliases point at the orphaned
        -- scratch, so their later writes never reach the serialized profile and are
        -- silently lost. Adoption makes the scratch the real table, so EVERY alias
        -- captured during boot converges on the one table that is now persisted.
        -- The discarded original is safe to drop: root.profiles was its only holder
        -- (profileKeys/lastActiveProfile store strings), and the scratch is a deep
        -- copy of it plus the legitimate boot writes, so no data is lost. NO reload:
        -- the adopted profile equals the normal-boot image, nothing to re-apply.
        if scratch then
            root.profiles[activeKey] = scratch
        end
        -- Defensive re-merge against the (now adopted) persisted table. A no-op after
        -- adoption (every default key is already present), but guarantees full
        -- seeding even if the scratch was somehow absent (root.profiles[activeKey]
        -- is left untouched and the global still points at it via Activate).
        if type(BBP.InitializeSavedVariables) == "function" then
            BBP.InitializeSavedVariables()
        end
        BBP.profileScratch = nil
        root.lastActiveProfile = activeKey
        BBP.activeProfileKey = activeKey
        BBP.profileUnresolved = nil
        return
    end

    -- MISMATCH: the hinted profile was WRONG for this character. Because the whole
    -- session ran against the SCRATCH, the persisted profiles were NEVER touched —
    -- no foreign profile got dirtied (this is the fix). A live rebind + additive
    -- merge cannot reconstruct the correct profile's one-shot init this session, so
    -- persist the correct assignment + converging hint and do one clean reboot.
    --
    -- CONVERGENCE INVARIANT (invisible constraint — do not remove): we set
    -- root.lastActiveProfile = activeKey BEFORE reloading. On the reboot, if
    -- identity is AGAIN unresolvable at ADDON_LOADED, Activate's provisional path
    -- copies its scratch FROM root.profiles[lastActiveProfile] == root.profiles[activeKey].
    -- Then here hintKey == activeKey, so we take the equality (no-reload) branch
    -- above. The reload therefore happens AT MOST once per identity change; the
    -- steady state never reloads. The scratch is discarded by the reload itself.
    root.lastActiveProfile = activeKey
    BBP.activeProfileKey = activeKey
    BBP.profileUnresolved = nil
    ReloadUI()
end

local function Activate(root)
    EnsureStructure(root)
    BBP.dbRoot = root

    local charKey = BuildCharKey()
    if charKey then
        -- Identity available now (the normal path on every current client).
        local activeKey = ResolveActiveKey(root, charKey)
        root.profileKeys[charKey] = activeKey
        root.lastActiveProfile = activeKey
        BBP.charKey = charKey
        BBP.activeProfileKey = activeKey
        BBP.profileUnresolved = nil

        -- THE REBIND. The global now points at the active profile table for the
        -- whole session. Every one of the ~10k BetterBlizzPlatesDB.* reads/writes
        -- transparently targets the active profile. PLAYER_LOGOUT swaps it back.
        BetterBlizzPlatesDB = root.profiles[activeKey]
    else
        -- Identity NOT available yet (Classic Era timing edge). Bind PROVISIONALLY
        -- but persist NOTHING (no profileKeys entry, no BBP.charKey) so we never
        -- write a sticky assignment under an UNKNOWN/empty identity. Retry at
        -- PLAYER_LOGIN, when name/realm are guaranteed available.
        --
        -- Converging hint: derive from root.lastActiveProfile (the last profile
        -- any character successfully activated) when it still exists, else Default.
        -- This makes the provisional binding correct in virtually all real cases
        -- (same character re-logging, single-profile accounts), so
        -- ReactivateAtLogin usually takes the no-reload equality branch.
        local hintKey = root.lastActiveProfile
        if not (hintKey and root.profiles[hintKey]) then
            hintKey = "Default"
        end
        -- CRITICAL: bind to a SCRATCH deep copy of the hinted profile, NOT to the
        -- persisted profile table itself. All pre-PLAYER_LOGIN init runs now — the
        -- main file's ADDON_LOADED handler AND its earlier-registered PLAYER_LOGIN
        -- handler (both fire before ReactivateAtLogin) — and every write it makes
        -- (one-shot migration flags, the additive default-merge, list updates,
        -- reopenOptions clearing, font/CVar captures) lands on this throwaway table.
        -- If the hint turns out WRONG for this character (mismatch branch below),
        -- no persisted profile was ever dirtied — that is the whole point: init
        -- must never contaminate a profile that may belong to a different character.
        -- The scratch lives only in BBP.profileScratch; it is never stored in
        -- root.profiles and never serialized (PLAYER_LOGOUT rebinds the global to
        -- the root, not to the scratch).
        local scratch = DeepCopy(root.profiles[hintKey])
        BBP.profileScratch = scratch
        BBP.charKey = nil
        BBP.activeProfileKey = hintKey
        BBP.profileUnresolved = true
        BetterBlizzPlatesDB = scratch

        local loginFrame = CreateFrame("Frame")
        loginFrame:RegisterEvent("PLAYER_LOGIN")
        loginFrame:SetScript("OnEvent", function(self)
            self:UnregisterEvent("PLAYER_LOGIN")
            ReactivateAtLogin(root)
        end)
    end
end

-- Build a fully-seeded fresh profile table for CreateProfile/ResetProfile.
-- Result contract: pure addon defaults (deep-copied from the flavor's exported
-- defaultSettings, so no reference aliasing between profiles) PLUS, via the
-- per-flavor hook BBP.FinalizeNewProfile, every one-shot bootstrap/migration
-- flag pre-marked done and the client-descriptive captures (Blizzard font
-- defaults, nameplateStyle) carried from `source`. This means the reload that
-- follows creation/reset performs NO CVar snapshot, NO onboarding replay, and
-- NO destructive migration against the new profile — instead of the old
-- behavior where an empty {} inherited the previous profile's CVar state via
-- the legacy first-run path.
local function BuildFreshProfile(source)
    local fresh = DeepCopy(BBP.defaultSettings or {})
    if type(BBP.FinalizeNewProfile) == "function" then
        BBP.FinalizeNewProfile(fresh, source or {})
    else
        -- Defensive fallback if a flavor failed to export the hook: at minimum
        -- suppress the first-run bootstrap so we never snapshot CVars/onboard.
        fresh.firstSaveComplete = true
        fresh.hasSaved = true
    end
    return fresh
end
BBP.BuildFreshProfile = BuildFreshProfile

--#########################################
-- Public API

function BBP.GetGlobalDB()
    local root = BBP.dbRoot
    if root then
        root.global = root.global or {}
        return root.global
    end
    -- Should not happen (only valid after ADDON_LOADED); return a throwaway so
    -- callers never index nil.
    return {}
end

function BBP.GetProfiles()
    local list = {}
    local root = BBP.dbRoot
    if root and root.profiles then
        for name in pairs(root.profiles) do
            list[#list + 1] = name
        end
        table.sort(list)
    end
    return list
end

function BBP.GetCurrentProfileName()
    return BBP.activeProfileKey or "Default"
end

-- SetProfile is THE single switch path: assign this character's profile and
-- reload. Confirmation happens in the popup so a cancel changes nothing.
function BBP.SetProfile(name)
    local root = BBP.dbRoot
    if not root or type(name) ~= "string" then return end
    if not root.profiles[name] then
        BBP.Print("Profile \"" .. tostring(name) .. "\" does not exist.")
        return
    end
    if name == BBP.GetCurrentProfileName() then
        BBP.Print("Profile \"" .. name .. "\" is already active.")
        return
    end
    if not BBP.charKey then
        BBP.Print("Cannot switch profiles: character name/realm unavailable.")
        return
    end
    BBP.pendingProfile = name
    StaticPopup_Show("BBP_CONFIRM_PROFILE_SWITCH", name)
end

function BBP.CreateProfile(name)
    name = Trim(name)
    if name == "" then
        BBP.Print("Profile name cannot be empty.")
        return
    end
    local root = BBP.dbRoot
    if not root then return end
    if root.profiles[name] then
        BBP.Print("A profile named \"" .. name .. "\" already exists.")
        return
    end
    -- Fresh profile: deterministically seeded with pure defaults + one-shot
    -- flags marked done + client-descriptive captures (see BuildFreshProfile).
    -- No CVar snapshot, no onboarding replay on the post-switch reload.
    root.profiles[name] = BuildFreshProfile(root.profiles[BBP.activeProfileKey])
    -- Then switch to it (popup -> reload).
    BBP.SetProfile(name)
end

-- Deep-copy the source profile INTO the active profile (AceDB semantics).
function BBP.CopyProfile(sourceName)
    local root = BBP.dbRoot
    if not root or type(sourceName) ~= "string" then return end
    if not root.profiles[sourceName] then
        BBP.Print("Profile \"" .. tostring(sourceName) .. "\" does not exist.")
        return
    end
    if sourceName == BBP.GetCurrentProfileName() then
        BBP.Print("Cannot copy a profile onto itself.")
        return
    end
    BBP.pendingCopy = sourceName
    StaticPopup_Show("BBP_CONFIRM_PROFILE_COPY", sourceName, BBP.GetCurrentProfileName())
end

function BBP.DeleteProfile(name)
    local root = BBP.dbRoot
    if not root or type(name) ~= "string" then return end
    if not root.profiles[name] then
        BBP.Print("Profile \"" .. tostring(name) .. "\" does not exist.")
        return
    end
    if name == "Default" then
        -- Hard-block: Default holds the migrated settings and is the fallback that
        -- every unassigned character resolves to. It must always exist.
        BBP.Print("You cannot delete the Default profile.")
        return
    end
    if name == BBP.GetCurrentProfileName() then
        BBP.Print("You cannot delete the profile you are currently using.")
        return
    end
    root.profiles[name] = nil
    -- Characters assigned to it fall back to Default on their next login.
    for k, v in pairs(root.profileKeys) do
        if v == name then
            root.profileKeys[k] = nil
        end
    end
    -- Keep the converging hint valid: if it pointed at the deleted profile, fall
    -- back to Default (a nil/stale hint is also tolerated by Activate's provisional
    -- path, but resetting it here keeps the persisted state clean).
    if root.lastActiveProfile == name then
        root.lastActiveProfile = "Default"
    end
    BBP.Print("Deleted profile \"" .. name .. "\".")
end

-- Wipe the active profile in place -> reload (defaults re-merge on load).
function BBP.ResetProfile()
    if not BBP.dbRoot then return end
    StaticPopup_Show("BBP_CONFIRM_PROFILE_RESET", BBP.GetCurrentProfileName())
end

--#########################################
-- Confirmation popups

StaticPopupDialogs["BBP_CONFIRM_PROFILE_SWITCH"] = {
    text = "Switch BetterBlizzPlates profile to \"%s\"?\n\nThis will reload your UI.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        local name = BBP.pendingProfile
        local root = BBP.dbRoot
        if name and root and root.profiles[name] and BBP.charKey then
            root.profileKeys[BBP.charKey] = name
            root.lastActiveProfile = name
            ReloadUI()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BBP_CONFIRM_PROFILE_COPY"] = {
    text = "Copy the settings from \"%s\" into your current profile \"%s\"?\n\nThis overwrites the current profile and reloads your UI.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        local src = BBP.pendingCopy
        local root = BBP.dbRoot
        if not (src and root and root.profiles[src]) then return end
        local active = root.profiles[BBP.activeProfileKey]
        if not active then return end
        WipeInPlace(active)
        for k, v in pairs(root.profiles[src]) do
            active[k] = DeepCopy(v)
        end
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BBP_CONFIRM_PROFILE_RESET"] = {
    text = "Reset the current profile \"%s\" to defaults?\n\nThis will reload your UI.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        local root = BBP.dbRoot
        local active = root and root.profiles[BBP.activeProfileKey]
        if not active then return end
        -- Seed defaults + flags + client-descriptive captures FROM the current
        -- (still-intact) active profile BEFORE wiping, then copy the seeded
        -- result back into the SAME table so references held elsewhere (the
        -- rebound global) stay valid. Same deterministic contract as create:
        -- no CVar snapshot / onboarding replay on the reset reload.
        local fresh = BuildFreshProfile(active)
        WipeInPlace(active)
        for k, v in pairs(fresh) do
            active[k] = v
        end
        active.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

--#########################################
-- Slash: /bbp profile [<name>]

local function HandleProfileSlash(rest)
    rest = Trim(rest)
    if rest == "" then
        BBP.Print("Current profile: " .. BBP.GetCurrentProfileName())
        local list = BBP.GetProfiles()
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Profiles: " .. table.concat(list, ", "))
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Use /bbp profile <name> to switch.")
    else
        local root = BBP.dbRoot
        if root and root.profiles[rest] then
            BBP.SetProfile(rest)
        else
            BBP.Print("No profile named \"" .. rest .. "\". Use /bbp profile to list them.")
        end
    end
end

-- Wrap the existing SlashCmdList["BBP"] (defined at the main file's file scope,
-- which runs before any ADDON_LOADED, so it exists by the time we hook).
local function HookSlash()
    if BBP.profilesSlashHooked then return end
    local original = SlashCmdList and SlashCmdList["BBP"]
    if type(original) ~= "function" then return end
    SlashCmdList["BBP"] = function(msg)
        msg = msg or ""
        -- Keep the name's original case; only the subcommand is matched.
        local cmd, rest = msg:match("^(%S*)%s*(.-)$")
        if cmd and cmd:lower() == "profile" then
            HandleProfileSlash(rest)
            return
        end
        return original(msg)
    end
    BBP.profilesSlashHooked = true
end

--#########################################
-- Bootstrap

local function Initialize()
    if BBP.profilesInitialized then return end

    local root = BetterBlizzPlatesDB
    if type(root) ~= "table" then
        root = {}
        BetterBlizzPlatesDB = root
    end

    Migrate(root)
    Activate(root)
    HookSlash()

    -- Register the logout swap HERE (inside our ADDON_LOADED), not at file
    -- scope. The main file registers its PLAYER_LOGOUT handler at file scope
    -- (which runs before any ADDON_LOADED), so registering ours now guarantees
    -- ours fires AFTER it. That matters: the main file's logout handler reads
    -- profile settings (e.g. disableCVarForceOnLogin), so the global must still
    -- point at the active profile while it runs; we swap to the root only after.
    local logoutFrame = CreateFrame("Frame")
    logoutFrame:RegisterEvent("PLAYER_LOGOUT")
    logoutFrame:SetScript("OnEvent", function()
        if BBP.dbRoot then
            BetterBlizzPlatesDB = BBP.dbRoot
        end
    end)

    BBP.profilesInitialized = true
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON then
        Initialize()
    end
end)
