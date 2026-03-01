# BetterBlizzPlates 1.9.7d
## Mindight
### Tweak
- Yet another nameplate font size tweak. Still not 100% there, need more time to figure out which exact moment to tweak it.
- Update Aeghis, Aswog, Bualock, Kalvish, Pinkteddyp, Pmake, Snupy, Venruki & Wolf
### Bugfix
- Fix enemy nameplate width being wrong and when friendly width had a higher value.

# BetterBlizzPlates 1.9.7c
## Midnight
### Tweak
- Update Venruki profile (www.twitch.tv/venruki). Ty for sharing.
### Bugfix
- Fix more issues with text rendering and name size. The name size slider should also now finally be sorted properly.
- Fix typo in nameplate simplified CVar name not storing proper names.
- Fix some castbar icon issues.

# BetterBlizzPlates 1.9.7b
## Midnight
### Bugfix/Tweak
- Fix issue with nameplate name size. Should be better and more consistent now. HOWEVER; Please read the tooltip of Name Size slider in /bbp as when adjusting this the size still does get a little weird and this is mentioned how to work around in the tooltip. Still not sure what causes this but after a reload there shouldnt be any problems now (hopefully). The name size things have been improved from Blizzards side with more API and I will likely rework the name size settings in the future but for now it stays with this system.
- Fix PRD frame sometimes having bottom border hidden with certain settings.

# BetterBlizzPlates 1.9.7
## Retail/Midnight
### New
- Color NPC section back with NPC colors
- New "Disable Outline" setting next to Font settings. More on this under Tweaks notes.
### Tweak
- Nameplate font rendering issue fixed and introduced new Disable Outline setting (for when custom Font is not enabled). The outline setting for custom font is now also fixed properly.
- Cleaned up some temporary Midnight stuff so Castbars now properly don't get messed with by BBP if "Enable Castbar Customization" is disabled. Due to this your Castbar might have changed and follow Blizzards "Nameplate Style" in Blizzards Nameplates section.
- BBP now stores a lot of the new Midnight nameplate related CVars in its profile so other people will get the same settings when sharing profiles.
- The stacking nameplates checkbox in CVar Control is now functional again and instead split up into Enemy/Friendly stacking due to new CVars from Blizzard.
### Bugfix
- Fix castbar icon not showing if "Enable Castbar Customization" was not enabled.
- Fix cast icon showing on un-interruptible casts despite the setting "Show icon on un-interruptible casts" being disabled
- Fix nameplate shadow setting showing up on some special hidden nameplates (like the Delver's Guide book in Dornogal)
- Fix pre-midnight nameplate setting's border & background showing up on some special hidden nameplates (like the Delver's Guide book in Dornogal)
- Misc minor issues.
### Note
- Lots of stuff to keep track off. Still more bugfixes and feature bring-backs to do but we are getting somewhere. If you have reported something and not seen it fixed please do not hesitate to remind me.