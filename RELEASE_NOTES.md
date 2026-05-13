# BetterBlizzPlates 2.0.1e
## Midnight
### New
- New Vanguards profile (www.twitch.tv/VanguardsTV). Thank you for sharing!

# BetterBlizzPlates 2.0.1d
## Midnight
### Tweak
- Update to fix specID stuff for mexican clients and missing female pres evoker on russian client.

# BetterBlizzPlates 2.0.1c
## Midnight
### Tweak
- Fixup class indicator pet icons for water elemental, dk ghoul and warlock pets after Blizzard nuked old npc ID method.
## All versions
### Tweak
- Interrupt logic: Replace IsSpellKnown API call with IsPlayerSpell because IsSpellKnown returns false on known spells on some clients causing interrupt logic to not detect an interrupt.
- Small Pets right-click slider can now be right-clicked as well for value input (and allow values greater than the default).

# BetterBlizzPlates 2.0.1b
## Midnight
### Bugfix
- Fix overshield not updating immediately on the PRD when it was set to shown in combat only.
- Fix an issue with a mix of settings "Change nameplate texture" + "Overbars" + No actual texture change selected for enemy/friend/self causing the nameplate absorb texture (white) to disappear.
- Fix some old aura code being called from gui causing a lua error.

# BetterBlizzPlates 2.0.1
## Midnight
### New
- Overshields is fixed and back. If you have used an alternative then either turn off this setting or the alternative so you dont run it twice. (And again huge thanks to Verz (MiniCC, FrameSort, etc) for being the goat and helping me a bit here)
### Tweak
- Sort out texture replacement issues with PRD and Overbars. Should hopefully be more consistent and cover more textures now.
- Tweak the look and size of default absorb texture. This was bleeding out from the healthbar and looked a super weird on the new nameplates (Thanks to Blizzards keen eye to details).
### Bugfix
- Fix issues with execute indicator color & texture with certain setting combinations.
- Fix the scale slider for Simplified Nameplate Scale not being hooked up properly and not actually changing values or setting them on login. Due to this if you have made changes elsewhere this fix might change your scale setting on the update.
## The Burning Crusade
### Bugfix
- Add another detection method for spell interrupt ids so Earth Shock (and maybe others) should hopefully be picked up more consistently now.