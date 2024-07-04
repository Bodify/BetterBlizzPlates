# BetterBlizzPlates 1.5.4b:
## Cata & Retail
### Bugfix:
- Fix Hide NPC returning early before properly resetting nameplate

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