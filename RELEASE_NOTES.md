# BetterBlizzPlates 1.9.4c
## Prepatch/Midnight
### New
- New DailyShuffle profile (www.twitch.tv/dailyshuffle). Thanks for sharing!
### Bugfix
- Fix lua errors from now new restrictions from Blizzard related to castbar types (uninterruptible status).
    This means currently not possible to color/texture an uninterruptible cast without some sort of wonky workaround maybe.
    Disabled for now and will just color depending on cast/channel, this may be confusing on uninterruptible casts. Consider Modern Castbars setting which uses default colored textures.

# BetterBlizzPlates 1.9.4b
## Prepatch/Midnight
### Bugfix
- Fix castbar icon position and size settings (again, but for real this time)
- Fix castbar icon pixel border setting
- Fix guild name secret error
- Attempt to make arena ID more consistent and not be tagged wrong, still a garbage system due to Blizzard restrictions and my low effort.

# BetterBlizzPlates 1.9.4
## Prepatch/Midnight
### New
- Add "Hide Cooldown Text on Debuffs" setting (New settings section).
- Add Mysticall profile on Prepatch/Midnight (www.twitch.tv/mysticallx)
- Add Wolf profile on Prepatch/Midnight (www.twitch.tv/wolfzx)
- Add Mmarkers profile to TBC (www.twitch.tv/mmarkers)
### Tweak
- Tweak nameplate click area to be a little smaller at the top, should be very similar to how they were before Midnight.
- Stupid silly and scuffed workaround for new arena nameplate restrictions.
- Nerf "Show target underneath castbar"'s Target Text size a little on casting units. This will likely see a rework in the future due to Blizzards new settings.
- Castbar Icon bugfixes and tweaks.
- Added a quick temporary variable if you want to disable all combo points movement from BBP. To do this type: /run BetterBlizzPlatesDB.disablePrdMovement = true
### Bugfix
- Fix Personal Resource Display's Combo Points moving and settings, especially when attached to the PRD and not target nameplate.
- Fix border color setting for new Midnight nameplate borders
- Fix castbar icon position/size settings.
- Fix target indicator not applying texture on out of range nameplates when targeted.
- Fix Nameplate Shadow/Highlight setting (Misc).
- Potential fix for nameplate width going small with "Small Pets" setting enabled.
- Fix a lot of minor bugs due to Midnight changes/restrictions across the addon causing lua errors.
- Fix Classic Nameplates setting showing the new Midnight Border on target.
- Attempted fix for Class Indicator & Blitz Indicators battleground flag carrier logic. Havent got to actually test this unfortunately due to time and long queues. Thats where you, the person reading this, comes in! :D
- Many minor misc things I've probably forgot to mention. Please continue to report bugs and thank you so much!
## Note
- Spec name stuff might be dead, probably, we'll see.
- The game is still undergoing tons of changes and in an extremly buggy state despite being in Prepatch and releasing in a few weeks. Many things are getting restricted and unrestricted and its a pain to develop for as we have no idea what is happening most of the time. 