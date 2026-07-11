# BetterBlizzPlates 2.0.7
## All versions
### New
- Quest Indicator: Now has a "Color" option in Advanced Settings that also colors the healthbar of the nameplate.
### Tweak
- Quest Indicator: If friendly npc healthbars are hidden quest indicator on friendly npcs now still shows and attaches to name instead.
- Fix stacking nameplates checkboxes not properly displaying their state as enabled when they were on Midnight, TBC and MoP.
## Midnight
### Tweak
- Update Disc (JustDiscipline) profile (www.youtube.com/@JustDiscipline)
- Tweak nameplate vertical position update call to hopefully avoid lua error.
### Bugfix
- Fix execute indicator color warping the nameplate texture.
## TBC/MoP
### New
- New setting that hides nameplate auras for unattackable enemies (Nameplate Auras). On by default to reduce clutter.
### Tweak
- Adjust friend/foe detecting in the new nameplate width stuff. Should solve issues in cities.
- The "Small Pets" width has been increase a little bit and the slider now also lets you go up to 70. Reminder that ALL sliders can be right clicked to input a custom value, even one outside of the default range. Tell your friends.
- Sort some font issues. Should hopefully be more consistent now.

# BetterBlizzPlates 2.0.6f
## Midnight
### Bugfix
- Fix nameplate vertical position setting not sticking.
## MoP/TBC
### New
- Add new "Scale names with the nameplate" option in Misc. This will keep the name proportionally scaled with the nameplate and grow/shrink with it.
### Tweak
- Sort out some scaling issues on nameplate names. Size might have changed slightly.
- Hide level on friendly nameplates in PvE if healthbar is hidden when using Blizzard's Classic nameplate style in their nameplate setting (recommended one atm due to issues).
### Bugfix
- Fix lua error in gui.
- Fix friendly nameplate width in PvE for Blizzards "Classic" style.
- Fix some castbar settings like icon size, icon position, etc.
- Fix various nameplate color issues.
- 2.0.6g: Add temporary fix for giant castbar icon when using classic nameplates option in BBP.
## Note
- Thank you for all the reports and please continue reporting bugs! Changes like these mess with BBP hard as I have to rework around all the new Blizzard changes (BBP is just tweaks to the default nameplates)

# BetterBlizzPlates 2.0.6e
## MoP + TBC
### Bugfix
- Fix lua error in a hook.

# BetterBlizzPlates 2.0.6d
## The Burning Crusade
- Updated for WoW 2.5.6. Midnight nameplates have arrived in TBC too now. This means A LOT has changed and there is too much stuff to go over. You may have to tweak your settings to get sizes/positions back how you had it. If you run into bugs or issues or other things please let me know on Discord! Link in support section.

# BetterBlizzPlates 2.0.6c
## Midnight & MoP
### Bugfix
- Fix Target/Focus Indicator's Texture Change settings resetting on target/focus.

# BetterBlizzPlates 2.0.6b
## All versions
### New
- Add a "Force Class Colors" setting to Misc. This setting is intended to fix Blizzards bug of failing to class color nameplates properly after Mind Control or other similar effects. This will probably be enabled by default later on but I have not tested it enough to rule out any potential unintentional changes. Please test it, especially if you are running into that MC bug (which is usually because you dont have class color friendly nameplates enabled and Blizzard fails to properly evaluate if the nameplate is friendly or not but still considers that CVar).
## Midnight
### Bugfix
- Fix an issue causing friendly nameplates that was targeted then un-targeted to get a brighter color than supposed to with class color setting off.
- Fix a typo in the "Hide name (but ignore totems)" setting causing it to error.

# BetterBlizzPlates 2.0.6
## Important changes:
- Midnight and MoP: Update click area logic. The click area preview should now be more accurate. You may want to tweak your click area settings (Misc) again after this update.
- Midnight: Update font size logic for Blizzards nameplate healthbar value text. It now gets treated the same way as the name and should stay consistent with the name. The name size slider in BBP will also affect the healthbar value text now.
## All versions
### New
- Healer Indicator: Color Enemy/Friendly Healthbar Color setting. (Advanced Settings for Healer Indicator)
## Midnight
### New
- Update "Small Pets" settings logic and introduce a few more right-click settings: "Reduce widith of ALL npc nameplates in PvP" and "Ignore Totems" (ignoring totems requires only pets and totems enabled).
- Totem Indicator: No Glow setting in advanced settings.
- Target Text: "Inside Bar" setting that places the target text inside the castbar on casts similar to BBF and sArena Reloaded.
- Enemy "Hide Name": Add a right-click option on "Hide Name" that keeps totem nameplate names shown.
- New castbar setting that lets you set castbar text position left/right/center (Castbar section)
### Tweak
- Totem Indicator: Add wonky workaround for Psyfiend showing as well (will be a tiny gap on Psyfiend summon but correct itself later).
- Totem Indicator: All totems are now sized 30x30 by default (instead of 30x30 for important and 24x24 for others) due to new restrictions. Should also fix healing stream showing grounding color.
- Totem Indicator: Fix it showing on your own pet. (Secondary pets seem more difficult though, for now I would recommend disabling totem indicator for friendly targets or disabling friendly pet nameplates if you dont use them)
- Fix NPC Titles showing on players own pet and potentially other minion pets from other players too.
- Update Nahj profile (www.twitch.tv/nahj)
- Update Dissonance profile (www.twitch.tv/dissonancewow)
## Mists of Pandaria
### Bugfix
- Fix lua error in pet indicator logic from Blizzard changes.
- Fix castbar background change not working since 5.5.4. (Note that if you change the color here on MoP the alpha slider is upside down because Blizzard, so maybe also check that).
- Fix an issue with vertical nameplate position setting.
## Classics
### Bugfix
- Fix an issue with hiding friendly npc healthbars on targeting despite that setting not being on.