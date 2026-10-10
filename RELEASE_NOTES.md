# BetterBlizzPlates 2.2.0
## All versions
### New
- Add localization support. Force English setting is in Misc if that is preferred along with some new font size settings for the GUI.
- Guild Names: Can now also show guild names on enemy players. Right-click "Show Guild Names on Nameplates" for separate Friendly and Enemy settings (scale and color) plus a font outline setting.
- Threat Colors: New "Specific Role Only" setting in Advanced Settings. Right-click it to pick Tank, DPS and/or Heal.
- CVar Control: "Avoid CVar Pickup" setting. CVar changes made outside BBP are no longer saved into BBP settings.
- Execute Indicator: "Show Execute Skull" setting in its More Options. Shows a skull in execute range, attached to the end of current health by default.
### Tweak
- Minor cleanup in the Advanced Settings section and a indicator top left whether the feature is on or off and click to toggle it.
### Bugfix
- Fix some nameplate font issues, for example Korean, Chinese and Cyrillic names showing as boxes on nameplates, with or without a custom font.
- Focus Indicator: Fix the focus texture getting reset after the nameplate was targeted and then untargeted.
- Target Indicator: Fix the target texture not showing when targeting a unit before its nameplate is visible.
## Forever
### Tweak
- The "Hide Level Background" setting now also stretches the healthbar to full width and puts the level on the side. If you had moved the nameplate names to accomodate how it was before youll have to reset them back to 0 x offset. And possible reduce the width of the healthbar too if you find them too wide now.
- Rogue & Druid: The Personal Resource Display now uses Blizzard's new combo point bar. "Show resource on target nameplate" shows a separate bar on the target nameplate. The "Retail Combo Points" setting is removed since this is now default from Blizzard.
- Minor tweaks to Forever profile (bit smaller nameplate combo points and only show them when 1+ combos)
### Bugfix
- Fix nameplates showing only the first name for a moment immediately after a reload.
- Fix nameplate combo points in general due to the tweak mentioned above with Blizzard adding combo points themselves and making changes.
## Retail & Forever
### New
- Resource Settings: "Hide Combo Points/Resource When Empty" setting. Hides the nameplate resource (PRD or target nameplate) until you have at least one point.
- Resource Settings: "Only Show Filled Combo Points/Resource" setting. Hides empty points and their background. Only one of the two can be on at a time.
- Nameplate Auras: "Color Timer Text" right-click options now have a High Color and a Normal Threshold (30 sec).
- Castbar: "Move Castbar Text" setting. Right-click it to move the spell name and cast timer and change the timer size.
- Friendly Nameplates: "Hide Other Pets" setting. Hides other players' pets unless targeted.
- Nameplate Auras: Personal Bar buffs now have filters: Blacklist, Whitelist, Defensives, Important, Under one min and Only mine. Whitelist, Defensives and Important are on by default. New "PRD Aura Align" setting (Left, Center, Right). This has also been added to BBF and If BetterBlizzFrames has it enabled as well you get asked which addon should handle them.
### Tweak
- Classic Castbar: No longer requires Classic Nameplates.
- Castbar: "Anchor Icon Right" now works with Classic Castbar and "Fit Cast Icon on the left".
### Bugfix
- Fix nameplate auras not sorting exactly like Blizzard's by default.
- Class Indicator & Blitz Indicator: Fix Battleground Objective icons sometimes not updating when a flag or orb gets picked up or dropped.
- Class Indicator & Party Pointer: Added more delay on pet summons to fix pet icon sometimes showing default fallback icon instead of current pet icon.
## Retail
### New
- Nameplate Motion Speed slider is back once 12.1.5 is live.
- New "Level Options" dropdown that has "Hide Lvl" and Misc "Friendly Lvl" moved into it. It has Hide Level, Hide Level On Friendly and Hide Level Background. Hide Level Background works with Classic Nameplates.