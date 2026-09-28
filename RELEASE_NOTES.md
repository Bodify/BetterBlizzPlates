# BetterBlizzPlates 2.1.7
## WoW Forever
### New
- Misc: "Center Nameplate Healthbar". This setting will center the healthbar properly on the default nameplates and move the level more to the right.
- General: Level Options: "Hide Level On Friendly" setting, on by default.
- General: Level Options: "Move & Size Level Text" setting. (Only available with some settings for now)
### Tweak
- Improve nameplate coloring in low level dungeons a bit, mostly boss color not going on random npcs.
### Bugfix
- Fix some positon issues with healthbar on Pre-Midnight nameplates.
## Midnight & Forever
### New
- General: "Hide Target Border". Hides the default target border around nameplates.
- Color NPC: "Color neutral healthbars only in combat"
- Color NPC: "Color neutral names only in combat"
### Bugfix
- Fix the healthbar background showing on targeted friendly nameplates while their healthbar was hidden.
- Fix issues with old nameplate info not clearing properly on new nameplates causing all sorts of issues (old colors on new nameplates being one example).
## All versions
### New
- CVar Control: Nameplate Visibility CVars reworked. Choose a "Nameplate Toggle Mode":
  - Simple: one setup for PvP and one for PvE, like before.
  - Advanced: separate setups for Arenas, BGs, Epic BGs, Dungeons, Raids, World and Cities.
- The dropdowns now also control Show Enemy/Friendly Nameplates, Stacking Enemy/Friendly Nameplates and "Only show Friendly name".
- Faction Indicator setting: "Only on PvP Tagged Players".
### Tweak
- The "Show Only Friendly NP Names" checkbox is replaced by the new per-content setting.
- The friendly nameplate "Toggles" in General now mirror the "Show Friendly Nameplates" option in the CVar Control dropdowns, in both modes. Added a "City" toggle.
- Right-click "keep overlapping nameplates in PvP" on Stacking Enemy Nameplates is replaced by per-content stacking.
- Hide friendly healthbar "NPC's" and "Show NPC Titles on Friendly NPCs" now also apply to neutral NPCs you can't attack.
- Update Ceit profile (www.twitch.tv/ceitxd)
### Classics
### New
- Add new Level Options dropdown topleft in /bbp with: Hide Level, Hide Level On Friendly, Hide Level background, Move Level.
- Faction Indicator brought over to Classics as well.

# BetterBlizzPlates 2.1.6
## WoW Forever
### New
- "Rogue & Druid: Retail Combo Points" in Combo Points/Resource. Rogues and Druids get the modern retail-style combo point bar on the Personal Resource Display and the target nameplate.
### Tweak
- Remove warnings about Blizzard bug making addons not remember saved settings, this is finally fixed by Blizzard.
- Tweak default nameplate width for Forever to be similar to Blizzards default.
- Change nameplate outline to be on by default to follow WoW Forever's new defaults. "Disable Blizzard Outline" and custom font outlines still override it.
- Tweak nameplate aura positions a bit to fix some issues, might have to tweak settings.
- Nameplate auras now show above the Blizzard level indicator.
- Big Buff/CC icons anchored to the right side now sit next to the level indicator instead of on top of it. You may need to tweak your settings cuz of this.
### Bugfix
- Fix normal rare mobs not showing the rare elite icon.
- Fix an issue with Target Indicator's position when Double Markers was enabled with level shown on nameplates not anchoring correctly on the right side with the level.
## All versions
### Bugfix
- Fix "Color Threat" or "Color NPC" overriding the tapped gray color for tagged mobs.
## Midnight & Forever
### Bugfix
- Fix execute indicator coloring showing a mix of execute color and nameplate color sometimes instead of one or the other.
## Midnight
### Tweak
- Warlock Soul Shards been bumped 2 pixels to the left so its properly centered. If you already accounted for this in your settings you will have to tweak that back.
## Classic Era, TBC, Wrath & Mists
### Tweak
- BBP now creates its own elite icon on nameplates same as other clients. If its popped up for you reminder that there is a hide setting in /bbp