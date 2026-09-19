# BetterBlizzPlates 2.1.5
## WoW Forever
### New
- New "Level Options" dropdown under General in /bbp.
- Level Options: "Hide Level Background" setting. Hides the level background texture and just shows the level text.
- Level Options: "Show Elite Icon Around Level" setting. Shows a rare dragon texture around the level on elite mobs. If "Hide Level" is also enabled it is shown on the side of the healthbar instead.
- "Hide Level" moved into the new Level Options dropdown.
- Elite mobs now always show the elite dragon icon on the left side of the healthbar. Hidden with "Hide elite icon" or when "Show Elite Icon Around Level" is enabled.
- Enabling "Classic Nameplates" setting will now ask you if you want to change a few other settings as well to hit that classic look on first try and not just the borders.
### Tweak
- The Pre-Midnight nameplate look no longer shows the level background, only the level text.
- "Hide Realm Names" removed in favour of "Hide 2nd Name" setting instead. This was causing names to only show first name. The setting is now reset and off by default.
- Tweak level font size on classic nameplates.
## All versions
### Tweak
- Fix classic nameplates border showing above name.

# BetterBlizzPlates 2.1.4
## WoW Forever
- BetterBlizzPlates early patch for WoW Forever. Should be good enough for Beta usage but many tweaks inc so don't expect things to stay 100% the same when updating.
- New "Forever" profile to select that has a classic feel to it.
## PSA
- There is a Blizzard Bug on WoW Forever Beta with addons atm making them fail to save/load settings. Nothing I can do. Deleting your saved variable files while logged out seems to fix it, at least for a while. Blizz pls.

# BetterBlizzPlates 2.1.3
## Highlights
- New Target Indicator options and icons for all versions.
- Retail Combo Points for Enhancement Shamans Mealstrom and Hunters Tip of the Spear buffs.
![bbpTargetIndicatorOptions](https://github.com/user-attachments/assets/7fec8e58-eb1c-4cd2-80c7-6146edcaee1a)
## All versions
### New
- Target Indicator: Now has options to change the icon, color the icon, and also to have the icon appear on both sides. In Advanced Settings.
- CVar Control: Shaman: Maelstrom Weapon Combo Points. Enhancement now gets a Rogue-style combo point bar for Maelstrom Weapon stacks on PRD/Target Nameplate.
- CVar Control: Hunter: Tip of the Spear Combo Points. Survival now gets a Rogue-style combo point bar for tracking Tip of the spear stacks on PRD/Target Nameplate.
- CVar Control: The nameplate visibility CVars now has PvP and PvE dropdowns to select which nameplate types you want to see in which content.
- Nameplate Auras: New setting to center auras on themselves (so enlarged square aura and a rectangle smaller one stays centered instead of aligned at top or bottom)
- Castbar Quick Hide: New right click option to always hide the castbar instantly, also when the cast was successfully interrupted (normally the castbar is kept up in that case to show the interrupt).
### Bugfix
- Fix classic nameplates border overlaying some things like healer indicator icon and more.
- Fix CC auras showing up twice with some filter settings when not using the Big CC Icon setting.
## Midnight
### New
- Nameplate Auras: "Center Align Auras" setting. Instead of aligning auras at top/bottom of the icon it now aligns center, so that a large and small aura next to eachother stay centered on the center.
- Totem Indicator: New options to change colors for the different types of detectable totems again.
- Totem Indicator: New setting to hide castbars on totems.
- Totem Indicator: Setting to hide the duration number.
### Tweak
- Totem Indicator: Last big patch caused some headache with CVars resetting due to the Totem Indicator (as intended to function properly). It still does this but now only during PvP and with the new CVar Control PvP/PvE visibility settings it should be much smoother to control this.
- Totem Indicator: Show healing stream separate again.
- Update JFarm profile (www.twitch.tv/jfarm_)
### Bugfix
- Fix an issue with the "Non-Target Alpha" setting causing nameplates to sometimes become full alpha when not target due to changes from Blizzard.
## Classic Era
### New
- Fix pink shamans and introduce a new "Color Shamans Blue" setting (Misc). Colors Shamans their blue color. On Era and only Era they are the same pink as paladin, this setting avoids that. Enabled by default, uncheck it to keep the pink Blizzard color.