# BetterBlizzPlates 1.5.8b
## The War Within & Cata
### New stuff:
- Custom Nameplate Font Size setting in Misc (This works in PvE for name size)
### Bugfix:
- Fix issues with healthbar color when "Custom healthbar color" was checked.

## The War Within
### Tweak:
- Improvements to nameplate updates after solo shuffle rounds to fix friendly/enemy difference issues.

## Cata
### Bugfix:
- Fix issue with nameplate auras not showing when the unit has maaany auras.

# BetterBlizzPlates 1.5.8
## The War Within & Cata
### New stuff:
- Change nameplate healthbar background color (Misc)
### Bugfix:
- Fix Guild/Friend indicator appearing on personal nameplate.

## The War Within
### Tweak:
- Fixed Blizzards fuckup with target highlight on nameplate healthbar. Now only displays on current health like it used to instead of also on the missing health (made background color look weird).


# BetterBlizzPlates 1.5.7c
## The War Within't (Prepatch)
### Tweaks:
- Updated "Show Guild Name" (Misc) to work without "Hide healthbar" setting on. Shows underneath healthbar.
### Bugfixes:
- Fix typo in nameplate aura glow settings causing lua errors.
- Fix an old function name that opened settings (InterfaceOptionsFrame_OpenToCategory) to its new name in TWW.
- Fix the healthbar height adjuster in Misc.
- Update OpenRaid lib and enabled it again (used to more accurately fetch and update party specs for class icon)

# BetterBlizzPlates 1.5.7b
## The War Within't (Prepatch)
- Fix issues with nameplate healthbars and their borders from a TWW change I missed.

# BetterBlizzPlates 1.5.7
## The War Within
- Update to support TWW.

# BetterBlizzPlates 1.5.6b:
## Cata
### Bugfix:
- Fix nameplate auras after a copypaste naming mistake from retail.

# BetterBlizzPlates 1.5.6:
## Retail & Cata
### New stuff:
- Raidmarker: "Move only in PvP" setting. (Advanced Settings)
- Threat Color: Can now change colors in "Advanced Settings"
### Tweaks:
- Adjusted the Threat Colors slightly with a few more updates
### Bugfix:
- Fix issue with nameplate aura filter "Purgeable" causing it to always show all buffs and not just purgeable like intended.

## Cata
### Bugfix:
- Fixed "Threat Color in PvE" setting. Not tested much, need feedback as I don't PvE.
- Fix "Always hide castbar" setting sometimes showing castbar in certain scenarious (?)

## Retail
### Tweak:
- Minor tweak to aura glow positioning

# BetterBlizzPlates 1.5.5e:
## Retail
### Bugfix:
- The "Change Healthbar Height" setting in Misc will now properly update height on all nameplates and not affect personal resource.

## Cata
### Tweak:
- Totem Indicator: Hide BigDebuffs Icon on nameplate if hide healthbar/icon only mode is selected for the npc

# BetterBlizzPlates 1.5.5d:
## Cata
### New Stuff:
- Combat Indicator: `Assume Pala Combat` setting. (Combat status while Guardian is out is bugged, crude workaround)

# BetterBlizzPlates 1.5.5c:
## Cata
### Bugfix:
- Totem Indicator: Fix Shield Border displaying on totems with "Hide Icon" enabled.

# BetterBlizzPlates 1.5.5b:
## Cata
### Bugfix:
- Fix nil error on totem indicator shield border

# BetterBlizzPlates 1.5.5:
## Retail & Cata
### New stuff:
- Health Numbers: `Target Only` setting.
- Totem Indicator: `No animation` setting.
- Castbar customization: `Hide Castbar Shield` setting.
### Bugfixes:
- Fix aura purge border sometimes not being visible/positioned correctly.

## Cata
### New stuff:
- Totem Indicator: Different visual presets for `Shield` setting.
- Nameplate Auras: `Show Tooltip` setting.
### Bugfixes:
- Fixed Nameplate Auras: `Center auras`. 
- Fixed issue with nameplate aura size not resetting after Enlarged/Compacted being set.

## Retail
### Bugfixes:
- Fix typo in castbar settings copypasted a few places causing lua errors.


# BetterBlizzPlates 1.5.4c:
## Cata
### New stuff:
- Added setting for totem indicator to show a shield icon on totems shielded by stoneclaw totem.

### Tweaks:
- Add missing Sunfire and Corruption (seed of corruption version) spellid to default aura list.
- Changed the default name anchor from TOP to CENTER. Forgot to change this after a recent tweak.

# BetterBlizzPlates 1.5.4b:
## Cata & Retail
### Bugfix:
- Fix Hide NPC returning early before properly resetting nameplate
- Fix Hide NPC "murloc mode" showing names on Retail with "fake name" turned on.

# BetterBlizzPlates 1.5.4:
## Cata & Retail
### New stuff:
- Updated the Hide NPC module to now make hidden nameplates unclickable.
- Added a "Only show last name on NPCs" setting. (Misc)
### Bugfixes & Tweaks:
- Fix "Hide healthbar" setting getting stuck on always hiding nameplates if toggled off during instance and possibly other scenarios.
- Fix some "Hide castbar" bugs.

## Cata
### New stuff:
- Clickable Height setting slider in Misc section
### Bugfixes:
- Fixed the spec icon setting for class icons to now also rely on Details since blizzard functio is not in cata.
- Fixed an oversight making the Nameplate Height slider not affect Retail Nameplates
- Updated Pet Indicator to now mark all player controlled pets and own pet if friendly pet nameplates are on.
- Fixed some wrong castbar & border functions being called between classic vs retail nameplates causing errors with some specific settings.
- Hopefully fixed nameplate border not accurately displaying uninterruptible status if an aura mastery buff falls for example.

## Retail
### Bugfixes & Tweaks:
- Made the square class icon border brighter for a better visual on color.
- Castbars should not reset back to white after being re-colored if ClassicFrames is on to allow the classic castbars to look normal.
- Fixed names not showing consistently if partypointer+hideall+fakename was being used

# 1.5.3b
## Cataclysm
### Bugfix:
- Fix Totem Indicator Width not properly resetting after changing.

# 1.5.3b
## Cataclysm
### Bugfix:
- Fix BBF -> BBP typo

## Retail
### Bugfix:
- Fix missing evoker nameplate resource for adjusting position etc.

# 1.5.3
## Retail & Cata
### New stuff:
- Aura color in PvE only setting.
- NPC Title text on nameplate setting (Misc section)

### Change:
- I've made the `Nameplate Scale` slider have same value for both min and max scale. This will make the nameplate always have the same size compared to the default slight shrink/grow depending on distance.

## Cataclysm
### Bugfixes:
- Nameplate width in PvE now forced to be the default width so the border doesnt look all messed up (Not allowed to change anything else by Blizzard)
- Hide Castbar settings should now properly hide all castbars

## Retail
### Bugfixes:
- Fix some minor Resource Frame on nameplate positioning bugs (Reminder that once this frame attaches to a friendly nameplate in PvE it becomes forbidden and I am unable to move it because of restrictions until a reload)
- Fix missing evoker nameplate resource for adjusting position etc.

# 1.5.2
### Cataclysm
#### New Stuff
- **CVars:** Added `nameplateTargetAlpha` and `nameplateNonTargetAlpha` cvars to the CVar Control section.

#### Bugfixes & Tweaks
**Castbars:**
- Fixed castbar changes intended for one nameplate applying to multiple nameplates.
- Fixed emphasis colors.
**Nameplate Auras:**
- If "Default CD" is not checked, it will now not display CD numbers.

# 1.5.1c:
### Retail:
### Bugfixes:
- **Resource Frame:** Fix typo in the update function for positioning of resource underneath castbar.
### Cata:
### Bugfixes & Tweaks:
**Castbars:**
- Fix classic border positioning on custom height castbars.
- Changed classic default castbar height to 10.
- Fix castbars being white/desaturated with certain settings.

# 1.5.1b:
### Cata:
### Bugfixes:
- **Nameplate Auras:** Fix "Separate Buff Row" to properly move the buffs up/down if no debuffs are shown.
- **Castbar:** Fix castbar resetting to white on classic plates

# 1.5.1
## Retail & Cata
### New Stuff
- **Aura Color:** Only Mine flag for Auras.
### Bugfixes
- **Castbars:** Turning red after finished cast.

## Cataclysm
### New Stuff
- **Totem Indicator:** Width settings for individual npcs!
- **Hide Level Frame Setting:** Now completely hides the level frame on classic nameplates and extends the health bar.
- **Nameplate Auras:** Added stack number like on retail.
### Bugfixes
- **Castbar Settings:** "Show who interrupted" setting now working in Cata.
- **Classic Nameplates:** Lot of tweaks.
- **Friendly Castbars:** Now properly hidden during PvE if that setting is on.
- **Friendly LevelFrame:** Now hidden in PvE when "Hide Friendly Healthbar" is on.
- **Clickthrough:** Friendly nameplates fixed.

## Retail
### New Stuff
- **Nameplate Resource Frame:** Strata setting in CVar Control.
- **Totem Indicator:** "Icon Only" mode flag for NPCs.