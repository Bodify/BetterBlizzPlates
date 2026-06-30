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