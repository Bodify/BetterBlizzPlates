# BetterBlizzPlates 2.0.0c
## Midnight
### Tweak
- Fix the health numbers "dont show on full hp" setting for Midnight.
## Titan Reforged
- Change Titan Reforged to load TBC files instead as a temporary solution because of new API changes. Very difficult for me to do any testing here so please report any errors with BugSack and BugGrabber.

# BetterBlizzPlates 2.0.0b
## Midnight
### Tweak
- Nameplate Auras: Fix player CC icon being a little bit larger than other aura icons. You may have to tweak your settings a little bit for it now.
### Bugfix
- Fix Quickhide Castbar always being active and also accidentally quick-hiding interrupted castbars due to a mistake.

# BetterBlizzPlates 2.0.0
## Midnight
### New
- The movers and position settings for nameplate buffs & cc are now functional. Settings have been reset to default here to avoid crazy stuff happening. I still recommend MiniCC instead of the default nameplate auras for this (which BBP uses) due to how bad the defaults are (showing Arcane Intellect over Combustion for example). GG Blizz.
- New "Scale names with the nameplates" setting. This setting just makes the name on the nameplate scale up/down with the nameplate size. This is how it by default works now in Midnight but wasnt before. I had some hardcoded stuff turning it off and now at this point I don't think I want to change it back either to avoid messing with ppls ui's. Here is a setting to chose for yourself at least.
- Nameplate Simplified Scale setting in CVar Control. Controls the scale of Blizzards new "Simplified Nameplates".
- Nameplate Clickable Area is now adjustable again (was hardcoded and sliders did nothing). Bottom right in Misc.
- New "Use PvP Title Names" setting in Misc. Thanks to DanteCrestfallen @ GitHub.
- New "Also hide Buffs & CC aura timers" right-click option for "Hide cooldown text for debuffs" in the new settings temp section.
- New Execute Indicator: Hide Text setting that disables the text and lets you just color the healthbar when below threshold without the text.
### Tweak
- Fix Castbar Quick Hide interrupt detection so it now again in Midnight no longer immediately hides a castbar thats been kicked but fades it out slowly showing who interrupted it on it.
- Default nameplate clickable area has been adjusted a little bit, less clickable room underneath the healthbar. This can be adjusted in Misc again now. The hardcoded clickable area before this patch was identical to pre-Midnight values but due to new shitty Midnight nameplates people are having click issues. Nothing I can do about that but at least being able to tweak the clickable box again now should help you a bit.
- Arena ID/Spec names have been improved and should be more consistent and hopefully also faster in some cases.
- Fix some issues with pixel border auras in PvP and in general other issues with auras in pvp.
- Fix Nameplate/PRD instant combo points setting.
### Bugfix
- Fix Name Repositon's "Scale name with nameplate" setting. Related to the other new setting mentioned above too but fixed up.
- Fix strange CVar value collected for "Min Alpha Distance" sometimes, correct it to default value.
- Add some temporary secret checks for nameplate alpha checks that could error. Idk why they are secret sometimes atm.