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


# BetterBlizzPlates 1.9.3e
## Prepatch/Midnight
### Tweak
- Fix some more CVar renames.
### Bugfix
- Fix ComboPoints moving without "Attach to nameplate" enabled.
- Fix midnight secret error.

# BetterBlizzPlates 1.9.3d
## Prepatch/Midnight
### Tweak
- Update mes profile

# BetterBlizzPlates 1.9.3c
## Prepatch/Midnight
### Tweak
- Fix rogue combo points offset on nameplate due to them not being centered by Blizzard.
### Bugfix
- Fix Pre-Midnight Nameplate Border getting stuck white target color sometimes.
- Fix Pre-Midnight Nameplate Border resizing sometimes when it shouldnt.
- Misc fixes.

# BetterBlizzPlates 1.9.3b
## Prepatch/Midnight
### Tweak
- Add back support for Combo Points on Target Nameplate (Requires PRD enabled, which you can hide bars of in Edit Mode)
- Fixup Border Size Settings for Pre-midnight look
- Hide absorb indicator when absorb is 0
### Bugfix
- Fix Nameplate Style CVar changing on logout.
- Fix everything related to showing friendly nameplates due to Blizzard CVar name change.
- Fix everything related to nameplate class colors due to Blizzard CVar name change.

# BetterBlizzPlates 1.9.3
## Prepatch/Midnight
### Tweak
- Tweak Class Indicator position for some settings
- Update profiles for Midnight: Aeghis, Starter, Blitz, Bodify (Likely more tweaks later on)
### Bugfix
- Fix nameplate debuff padding resetting.
- Fix no-interrupt castbar coloring.

# BetterBlizzPlates 1.9.2g
## All versions
### Tweak
- Extremely minor cleanup to some settings and a toc update.

# BetterBlizzPlates 1.9.2f
## Midnight
### Tweak
- Fix default "pre-midnight nameplates" border color now turning white on target.
- Fix Misc "Nameplate Border Color" setting to work with both midnight and pre-midnight nameplates.
- Fix an issue with castbar text being too high on one nameplate style

# BetterBlizzPlates 1.9.2e
## Midnight
### Tweak
- Minor tweaks and bugfixes.

# BetterBlizzPlates 1.9.2d
## TBC
### Tweak
- Fix nameplate position/width settings being off due to TBC changes to nameplates.
- Remove UA (non silence) auras accidentally being in Key Auras filter.

# BetterBlizzPlates 1.9.2c
## TBC
### Tweak
- Remove vampiric embrace listed as a defensive buff on TBC.

# BetterBlizzPlates 1.9.2b
## Classic Era
### Tweak
- Fix missing initialization of the new extra buff detection oops.

# BetterBlizzPlates 1.9.2
## The Burning Crusade
### Tweak
- You can now whitelist warrior stance auras. Note that these will only pop up after the warrior switches stance once.
### Bugfix
- Fix popup message containing old popup button structure causing lua error.
## Classic Era
### New
- Attempt to add better nameplate aura buff detection for npcs for Era. Had a hard time getting to test this properly so yolo..

# BetterBlizzPlates 1.9.1d
## The Burning Crusade
### Tweak
- Remove Wyvern Sting dot debuff (not CC) from PvP CC/Key Auras filter.

# BetterBlizzPlates 1.9.1c
## The Burning Crusade
### Tweak
- Remove Thorns from PvP Buffs filter.

# BetterBlizzPlates 1.9.1b
## The Burning Crusade
### Tweak
- Fix nameplate height when level frame was hidden.

# BetterBlizzPlates 1.9.1
## The Burning Crusade
### Tweak
- Tweak nameplate height and name position in TBC. Tweak needed for Era/Cata is no longer needed for TBC and caused nameplates to be much shorter than intended. You will have to re-adjust your nameplate height (General) and nameplate name position settings (Advanced Settings).
- Fixup aura spell ids for Key Auras, PvP Buffs & CC Filters.

# BetterBlizzPlates 1.9.0b
## MoP
### Bugfix
- Fix changes meant for tbc unintentionally being pushed on MoP version causing lua errors.

# BetterBlizzPlates 1.9.0
## The Burning Crusade
- Very early and scuffed TBC support. Not very well tested and no default spells/npcs updated for TBC. Best I can do for now. Please report bugs. Any support in terms of spell ids and npc ids etc is welcome.
## Midnight
### Tweak
- Some tweaks to nameplate height and width so they can be adjusted separately between friendly enemy again after Blizzard removed the default API for it. This will see more tweaks in the future so don't expect your settings to be 100% until a full release sometime before Midnight release.
## All versions
### Bugfix
- Fix all gui subcategories not showing instantly when loading GUI.

# BetterBlizzPlates 1.8.9k
## GitHub
- With this patch and forward my addons will also have GitHub releases. Huge thanks to zerbiniandrea for the pull request with everything set up quickly for me for this.
## All versions
### Bugfix
- Fix Arena Spec Names to have text aligned LEFT when spec text is LEFT anchored and vice versa. But actually this time (forgot an anchor).
- Fix issues with tooltip setting for auras on both MoP and Era. Added "Show tooltip" setting back in the MoP version since that was accidentally removed from the GUI during the Cata->MoP update.
## Classic Era
### Tweak
- Classic Era/SoD version now has different defaults for new users for Nameplate Aura filter settings. Due to no existing "Blizzard Default Filter" and too much work required to make my own preset (need debuffs of all classes and then also spell ids for every single rank since they are unique) this "Blizzard Default Filter" is now disabled (it doesnt do much anyway on Era) and instead "Only show mine" is enabled by default to show all your own debuffs. Whitelist etc can ofc still be tweaked however you like. Honestly thought I made this change forever ago but appearently not.

# BetterBlizzPlates 1.8.9i
## Retail & Midnight
### Tweak
- Fix Arena Spec Names to have text aligned LEFT when spec text is LEFT anchored and vice versa. Will do this fix for MoP soonTM but needs a few other tweaks as well.

# BetterBlizzPlates 1.8.9h
## All versions
### Bugfix
- Fix settings panel not opening on Midnight (and tweak it for all the rest too)

# BetterBlizzPlates 1.8.9g
## All versions
### Bugfix
- Nameplate Auras: Fix Purge Glow texture not being scaled with the buff scale setting.
## Midnight
### Tweak
- Fix up some spec id stuff for Midnight to have working spec detection for most things. Will still need some more tweaks but good enough for now.
### Bugfix
- Fix castbar color issues with castbar customization enabled but recolor castbar disabled.

# BetterBlizzPlates 1.8.9f
## Midnight & Retail
### New
- Add Venruki Profile (www.twitch.tv/venruki)

# BetterBlizzPlates 1.8.9e
## Midnight
### Bugfix
- Fix nameplates breaking if you had level frame shown due to new Blizzard changes on latest Beta.
### Tweak
- Some other minor tweaks I forget. BBP will see some more love this weekend with fixes and new stuff for Midnight Beta.
## Retail & Midnight
- Mes profile update

# BetterBlizzPlates 1.8.9d
## Retail
### Bugfix
- Fix border size setting for personal nameplate & manabar.
## Mists of Pandaria
- Fix error on nameplate aura tooltip settings.

# BetterBlizzPlates 1.8.9c
## Midnight
- Few more fixes for Midnight

# BetterBlizzPlates 1.8.9b
## Midnight
- Many fixes for Midnight. Damn you Blizzurd.

# BetterBlizzPlates 1.8.9
## MIDNIGHT
- Midnight support is live. Very early version so bugs are expected, especially week 1-2. Things are not finished, I still have months of work left so please be patient.

# BetterBlizzPlates 1.8.8
## Retail
### New
- Added Pmake profile (www.twitch.tv/pmakewow)
- Added my own personal profile (i havent played since march or so)

# BetterBlizzPlates 1.8.7b
## All versions
### New
- Nameplate Auras: Reverse Aura Direction setting, stacks right to left instead (also works together with Centered auras to change Enlarged sorting etc).
### Tweak
- Tweak couple of Pandemic Aura windows and logic.
## Classic versions
### Tweak
- Tweak Nameplate Auras' Container position to fix new Reverse Aura Direction setting working properly. I don't think this will cause any issues but if anything changes let me know.


# BetterBlizzPlates 1.8.7
## All versions
### New
- Nameplate Auras: Add new Ctrl+Alt+Rightclick option for important color that colors ALL whitelist auras at once. This is irreversible so only do this if you are planning and wanting to easily change the color on every single aura at once.
- Temporary Midnight section explaining plans.
## Retail
### Tweak
- Class Indicator/Party Pointer Pet Detection tweaked again: Previous workaround had issues BM hunter pets. This new workaround should solve that and the other issue so hopefully good now.
- Change Health Number billions to only show two decimals instead of three
## Mists of Pandaria
### Tweak
- Add Hunter Silence Shot for Castbar Interrupt Color. Thanks to Snackqt @ CurseForge.


# BetterBlizzPlates 1.8.6b
## Retail
### Tweak
- Add another tweak to Pet detection on Class Indicator etc to avoid others pets triggering this new check.

# BetterBlizzPlates 1.8.6
## All versions
### New
Nameplate Auras: Center Auras on Enemy now has a right-click option to only center buffs and not debuffs. Allows you to keep the debuffs where youre used to and have buffs centered above/under.
Nameplate Auras: "Gap between Buffs and Debuffs" slider setting.
### Tweak
- Fixed an issue with separate buff row setting and buff scale setting causing the scale to also adjust the gap size (introduced new gap setting if ur setup changed)
## Retail
### Tweak
- Fixed an issue with Class Indicator & Party Pointers pet detection while in Arena. When summoning a Pet the nameplate update would not register it as a pet unit. Use a different detection method that gets the pet update immediately cuz Blizz API poopoo.



# BetterBlizzPlates 1.8.5d
## All versions
### Bugfix
- Fix target highlight showing unintentionally on friendly npcs thats had their healthbar hidden.
## Classics
### Bugfix
- Another tweak for absorb code on Classics due to error reports that I can't reproduce. Hopefully this works.

# BetterBlizzPlates 1.8.5c
## Classics
### Bugfix
- Add forbidden check for absorb stuff so it wont error in dungeons due to friendly nameplates.

# BetterBlizzPlates 1.8.5b
## Retail
### Tweak
- Add missing classes & genders to the GetSpecID workaround for Spanish clients.Thank you Dardo @ Discord for notifying and helping me collect the missing data. Blizzards API does not have a proper GetSpecID API and even the workaround fails in some cases (like classes/specs in Spanish) due to Blizzards own data not properly supporting it..
- Changing castbar background texture now updates immediately (instead of only when a real cast happens)
### Bugfix
- Fix capital letter typo in pixel border + border size change causing lua errors.
- Remove debug print accidentally left in Class Indicator pet logic.


# BetterBlizzPlates 1.8.5
## Retail
### New
- Added Mes's Profile (www.twitch.tv/notmes). Thank you <3
### Tweak
- Add unique pet icons for Class Indicator for Hunter pet families. Huge thanks to Stroold @ Discord for putting this list together <3
- Blitz preset profile adjusted to show pvp buffs by default too.
- Health Numbers now show three decimals on billions and two decimals on millions if decimals are selected to show.
- Tweaked Class Indicator's Pin Mode a little bit. (Cropped the pin texture so it doesnt stick out on square icon. Repositioned and resized ever so slightly)
## All versions
### New
- New setting for nameplate background color which makes it solid and allows you to properly put any color as background which was limited before.
### Tweak
- Change nameplate border size now also resizes border on castbar and castbar icon if enabled and not just healthbar.



# BetterBlizzPlates 1.8.4i
## Retail
### Tweak
- Kalvish profile update
## Classic Era/SoD
- Fix healthbars getting stuck hidden with some settings

# BetterBlizzPlates 1.8.4h
## Mists of Pandaria
### Bugfix
- Health number fixes for mop

# BetterBlizzPlates 1.8.4g
## Classic versions
### Bugfix
- Fix multiple naming mistakes on era and mop causing lua errors due to multiselect and not double checking.


# BetterBlizzPlates 1.8.4f
## All versions
### Tweak
- Color Threat: Don't color threat on tapped units.
## All classic versions
### Tweak
- Health Numbers' Advanced Settings updated to same stuff as on Retail (new anchor settings and some others)
- Misc: Change nameplate border color now also colors castbar border when using Classic Nameplates.
## Retail
### Tweak
- Aeghis profile update
## Mists of Pandaria
### Bugfix
- Fix missing GUI elements in Totem Indicator List section to toggle Totem Indicator Width settings on/off causing Totem Indicator Width settings to appear broken.
## Classic Era
### Tweak
- Cleaned up name position stuff and updated it to same as on Retail/MoP. Shouldnt notice any difference unless I've messed smth up. Please report bugs as always.
### Bugfix
- Fixed some issues with name text updates and some features not working properly because of it, for example "Show last name only on npcs" bugging on mouseover.



# BetterBlizzPlates 1.8.4e
## Retail
### New
- New right-click setting on "Show resource on target" (CVar Control) that lets you keep resource on PRD while you have no target and swap to target if you have one.
- Full Text Width setting for Castbars. Also tweaked the default to be a tiny bit wider.
### Bugfix
- Cleanup at some hide nameplate stuff. Hopefully the end of it.
## Mists of Pandaria
### New
- Full Text Width setting for Castbars. Also tweaked the default to be a tiny bit wider.
### Bugfix
- Attempted fix at some people getting errors on creating absorb textures. Correct according to API and working for most, wrong according to errors, very poggers.



# BetterBlizzPlates 1.8.4d
## Mists of Pandaria
### New
- Aeghis MoP profile
### Tweak
- Realised I forgot to force the missed healing tide totem into ppl lists late. This has now been put into into your Totem Indicator List if it was missing.
### Bugfix
- Fixed Quest Indicator not showing. Please report if it is still causing issues.
- Fixed a missing variable in Fade NPCs causing lua errors if you hadn't already adjusted the slider.
- Fix missing Capacitor Totem icon from Totem Indicator
## All versions
### Bugfix
- Fixed "Disable all CVar forcing on login" setting being borked due to the introduction of the CVar backup system causing CVars to revert on logout despite setting enabled.
- Removed some debug prints.



# BetterBlizzPlates 1.8.4c
## Mists of Pandaria
### Tweak
- Saul profile update
- Living Bomb now shows Pandemic Glow when its below 3 seconds left instead of the default 5 (explode refresh window)
## Classic Era
### Bugfix
- Fix debug printing of variables when opening GUI
- Fix Totem Indicator issue with icon getting stuck on friendly players
## Note
- If you are experiencing missing healthbars/nameplates of any kind please give me as much info as possible on Discord so I can sort it.

# BetterBlizzPlates 1.8.4b
## Mists of Pandaria/Cata/Wrath
### Bugfix
- Fix nameplate aura fix from 1.8.4... :)

# BetterBlizzPlates 1.8.4
## Retail
### Tweak
- Updated Jovelo (Mythic) profile.
- Updated Color NPC M+ Season 3 Import. From Gramhehe @ Wago (Plater). Might change in the future.
- Nameplate Auras: Max nameplate auras setting now works more like expected and properly checks all auras instead of immediately ending upon reaching the max value which could cause it to not show some enlarged/important auras.
## Mists of Pandaria/Cata/Wrath
### Tweak
- Nameplate Auras: Max nameplate auras setting now works more like expected and properly checks all auras instead of immediately ending upon reaching the max value which could cause it to not show some enlarged/important auras.
- Update Class Icons' old spec icon code, with it new Monk spec icons.
### Bugfix
- Nameplate Auras: Fix issues with nameplate aura positioning. Inconsistencies especially between enemy and neutral mobs and "Extra Clickable Height" setting also affecting. Due to this fix you might have had your nameplate auras moved slightly and will need to reposition them to your liking if so.
- Fix Class Indicator's Alpha slider not working.
## All versions
### Bugfix
- Fix Castbar Emphasis activating on spellcasts added by ID that had the same name. If added by ID now only activates on that specific ID and not other spells with the same name as originally intended.


# BetterBlizzPlates 1.8.3d
## All versions
### Bugfix
- Fix nameplate unit nil lua error.

# BetterBlizzPlates 1.8.3c
## Retail
### Tweak
- Add missing AOE Blind spell id to CC & Key Auras.
## Mists of Pandaria
### Tweak
- Add missing Capacitor Totem & Stone Bulwark Totem to Totem List. These have been auto added to your list if you did not have them.
### Bugfix
- Fixed an issue where interrupt and aura tracking for Nameplate Auras remained active even when Nameplate Auras were disabled causing some lua errors.
## All versions
### Tweak
- Tweaked castbar target text slightly, hopefully not showing up when it shouldnt now.
### Bugfix
- Fix Totem Indicator's "Use Nicknames" setting not always applying nickname.
- Fix issues with castbar setting "Hide name while casting" erroring and not hiding/showing names properly.
- Fix Color NPC color resetting after targeting for tanks when not in combat and Color Threat enabled as well.
- Fix castbar setting "Interrupt CD Color" only recoloring interrupted castbar immediately and not all active castbars.

# BetterBlizzPlates 1.8.3b
## Retail
### Bugfix
- Fix friendly nameplates being hidden in PvE when "Hide Friendly NPC Healthbar" was enabled (After decoupling player & npc healthbar settings). Also turned off the hide npc healthbar setting if hide player healthbar was not enabled since this should not be enabled by default anymore.
## Mists of Pandaria
### Bugfix
- Fix enemy nameplates getting a bit more narrow in PvE.

# BetterBlizzPlates 1.8.3
## Retail
### New
- "Change Nameplate Border Size" setting in Misc now also has a slider for Personal Resource Display.
- Nameplate Auras: "Sort Auras by Duration" right-click subsetting that reverses order.
### Tweak
- Friendly "Hide healthbar" and "Hide healthbar NPC" are no longer tied together so you can hide one or the other.
- Custom name color for enemy/neutral npcs now changes the neutral color to enemy when they get in combat.
### Bugfix
- Fix the 2 extra rogue combo points from talents sometimes not getting darkened from the darkmode setting.
## Mists of Pandaria
## New
- Nameplate Auras: "Sort Auras by Duration" right-click subsetting that reverses order.
### Tweak
- Added missing Earthgrab Totem in Totem Indicator List after accidental removal from cata -> mop update. This has been auto added to your list.
- Updated the "temporary" nameplate resource weakaura for MoP to support Monk etc. Still in CVar Control with a "Import WeakAura" button.
### Bugfix
- Fix "Color by Aura" missing "Only Mine" check on MoP version and still coloring auras that was not yours.
- Fix some issues with castbar text due to it not being linked to the proper element after copypaste from retail (clasic version originally doesnt have castbar text)
- Fix the default width of friendly nameplates in PvE being off after the big changes to BBP in MoP. This width is forced to default width due to friendly nameplates not being allowed to be altered and the border is a single texture and cant follow the nameplate width when BBP is not allowed to customize it.
## All versions
### New
- Totem Indicator: Use Nicknames. This setting will show the nameplates with the name you put in the totem indicator list instead of their default name. Setting found in the Totem Indicator List section.
- Nameplate Auras: "Purgeable" filter now has a Shift-Rightclick setting to only display purgeable auras if your class has a purge. This is checking Blizzards default logic whether or not you have a purge.
### Tweak
- Little tweak to how the default nameplate font is handled. This was poorly handled from way back when and this should fix some issues. However there have been weird issues spawning from attempting to change this behaviour before. If you are seeing any issues with the nameplate font with this new change please type "/bbp oldfonts"
- Health Numbers now copies outline and shadow from nameplate name on creation (untested).
### Bugfix
- Fix "Show last name only" setting conflicting with Totem Indicator's "Hide Name" setting causing names to to despite being set to hidden.
## Classic Era
### Bugfix
- Fix issues with sliders caused by broken CVar fetcher for new users. Been broken for awhile... oops.
## Note
- If you have reported bugs or requested features that I promised but did not deliver please remind me. Been hectic and I lost a lot of data due to some oopsies during Linux testing.




# BetterBlizzPlates 1.8.2h
## Retail
### Tweak
- Class Indicator's "Always show Healer/Tank" settings now properly shows for Healer/Tanks in both Arenas and BGs if "Only Arena/BG" were selected. Lets you enable for all nameplates in Arena but only for Healer/Tanks in BGs for example. Tooltip updated.

# BetterBlizzPlates 1.8.2g
## Retail
### Bugfix
- Fix changing anchors for Blitz Indicator not working properly until a reload.
## Classic versions
### Bugfix
- Fix hiding nameplates causing lua errors and unintentionally hiding nameplates, due to Blizzard changes in the 11.1.7 patch. These changes are active in Classic versions of wow. As a result hidden nameplates are now clickable again as mentioned in previous patch notes as well. :/
- Fix nil error related to BuffFrame
- Fix Edge Highlighter causing lua errors due to copypaste mistake from retail -> cata/mop.
- Fix a nil function being called causing a lua error.

# BetterBlizzPlates 1.8.2f
## Mists of Pandaria & Cataclysm
### Bugfix
- Fix issues with hiding castbar not always hiding it

# BetterBlizzPlates 1.8.2e
## Retail
### New
- RaidMark setting to always keep the mark Full Alpha (Advanced Settings).
- "Casting Full Alpha" setting for "Non-Target Alpha" setting in the CVar Control section.
### Tweak
- The "Targeting" color from Threat Color feature should now override Color NPC.
### Bugfix
- Fix typo in nameplate aura stuff, ty vkottler for noticing this.

# BetterBlizzPlates 1.8.2d
## All versions
### New
- Hide Castbar Text subsetting: Right-click to also hide the "Interrupted" text.
## Retail
### Bugfix
- More fixes regarding nameplate visibility for 11.1.7. Please be vocal and report if there are still issues here.
## Mists of Pandaria / Cataclysm
### New
- Saul profile (www.twitch.tv/saul)
### Bugfix
- Fix cooldown numbers on auras showing regardless if you had "Default CD" enabled or not.
- Fix red castbars with castbar recoloring/retexturing enabled
- Fix castbar text size setting not working.

# BetterBlizzPlates 1.8.2c
## Mists of Pandaria & Cataclysm
### Bugfix
- Fixed retail nameplate width being off after adjustsments. If you changed it you will have to change it back. Apologies for the trouble.
- Fixed Starter Profile not being able to be selected. Also cleaned up a few things in the profile system for the new patch.
- Fix Cata's ArenaID stuff accidentally being updated to new MoP API. This needs to remain old version, fixed.
## The War Within
### Bugfix
- Fix issue with Separate Buff Row + Key Auras causing the buff row to get shifted up when it doesnt have to due to the debuff being a key aura.
- Fix one more issue causing the ADDON_ACTION_BLOCKED error (in Castbar Emphasis) due to new Blizzard changes in 11.1.7.

# BetterBlizzPlates 1.8.2b
## The War Within
### Bugfix
- Fix some more issues with hiding nameplates due to the new changes in 11.1.7

# BetterBlizzPlates 1.8.2
## Mists of Pandaria Classic & Cata
### New:
- A lot of features from Retail BBP has been ported over and theres been a lot of changes. Due to so many changes its possible I have missed something.
- Key Auras (BigDebuffs'ish feature) and PvP CC and PvP Buffs filters have all been updated for Mists of Pandaria (and also added to Cata but might miss some auras there, its not prio rn).
- Nameplate Auras section have been updated to include all the retail features.
- Party Pointer & Class Indicator CC shown on them (Requires nameplate auras enabled, Can turn off in Advanced Settings)
- Nameplate vertical position and click box size adjusters in Misc
### Note:
- Things to look out for on this new patch:
1) Name position. This was not perfect after doing a retail import. People may have moved it down as a fix and will probably have to move it back up now in Advanced Settings.
2) Bugs. So much has changed and there is probably things I have missed.
### Bugfix:
- Fix pets getting class colored accidentally

## The War Within
### Tweak:
- Aeghis profile update
- Mythic S2 NPC list updated (Ty Sporadic)
- Nameplate Auras: Whitelist's "Compacted Aura" will now have priority over the setting "Enlarge all Important Buffs" as intended.
### Bugfix:
- Fix "ADDON_ACTION_BLOCKED" error due to logic related to Hide NPC. Unfortunately this change required to fix it will make it so hidden nameplates now are hidden but still clickable.
- Fix issues with castbar coloring with emphasis castbar.
- Fix Target Nameplate Border size not updating when Nameplate Size CVars were set to 1

## All versions
### Bugfix:
- Fix chatbubbles getting covered by nameplates and not showing above them.
- Classics: Fixed the Nameplate Height CVar essentially getting stuck and not being able to be changed after introducing the CVar Backup system.



# BetterBlizzPlates 1.8.1c
## Retail
### New:
- Nameplate Auras: Enemy "Purgeable" filter now has a rightclick setting "Only show Purgeable Auras in PvE".
### Tweak:
- "Small Pets" setting now also reduces the width of your own Pet while in World, but actually this time.
## Classic versions
### Tweak:
- Small Pets and Totem Indicator Width settings have been updated to be similar to their more up-to-date Retail version. Due to this the width of affected nameplates may have changed a little bit and you might have to re-adjust them slightly.
### Bugfix:
- MoP Beta: Fix player role check for Threat Color causing lua errors due to API changes on MoP Beta.
- Fix a logic issue causing nameplates to always be class colored regardless of settings.
- Fix issue with individual nameplate width (Small Pets & Totem Indicator Width settings) not resetting properly on other nameplates.
- Fix the text from the Guild Name setting not hiding immediately as the nameplate disappears.



# BetterBlizzPlates 1.8.1b
## All versions
- Import/Export: Added a warning for when exporting a Retail profile to a Classic version and vice versa. Due to CVars being very different between them some of them needs to be reset to not bug out. You will have to readjust a few things like nameplate size etc. Also a reminder than you can delete individual lists in the Import/Export section top right on each field when mouseover.
## Retail
### Tweak:
- "Small Pets" setting now also reduces the width of your own Pet while in World.
- Pet Indicator now always works on own Pet as well.
- Rogue's Evasion was missing as a Key Aura and has been added as one.
### Bugfix:
- Non-Target Nameplate Alpha now properly updates when Focus changes (if you have Focus also enabled).
## Classic versions
### Bugfix:
- Fixed an issue from a recent change to friendly class color setting causing friendly nameplates to bug out upon entering an instance.
- Fixed Execute Indicator's test mode having some Retail code in it causing lua errors on Classic.



# BetterBlizzPlates 1.8.1
## Mists of Pandaria Beta
### No beta access :/
- I don't have beta access so cant work on support. I made it so MoP loads Cata files for now but it's unlikely this will work without changes, and NPC lists need updates etc. If you bugreport I might be able to fix it up, contact me.
## All versions
### New:
- Party Pointer now has a 2nd "Highlight" setting in Advanced Settings. Currently only intended for default texture, might expand on that in the future.
## Retail
### New:
- Focus Indicator's "Color Healthbar" setting now has a right-click option to disable it while in PvP.
- Class Indicators Pet setting now has a "Always show" setting to keep it enabled with for example "Arena only" enabled.
- "Non-Target Alpha" setting in CVar Control now has a setting to also keep Focus nameplate full Alpha.
- "Stacking Nameplates" setting in CVar Control now has a right-click option to keep them Overlapping (Non-Stacking) in PvP.
- Nameplate Auras: Personal Resource Display now has separate YX Offset and "Centered Auras" settings.
### Tweak:
- Added a missing Solar Beam Spell ID to the "Interrupt CD Color" castbar setting and also added Priests Silence back to it.
### Bugfix:
- Fix the clickable preview field for "Extra Clickable Height" setting in Misc becoming inaccurate when using a lower click area value.
- Fix old API call in Totem Indicator NPC List when trying to add a spell id for icon causing a lua error.
- Fix an issue in Nameplate Aura Filter settings causing Purgeable Auras to not show when it combined with "PvP Buffs" were enabled.
## Classic versions
### Bugfix:
- Added some forbidden nameplate checks on some castbar code to prevent errors in PvE. Please use BugSack & BugGrabber and report bugs so I can fix.




# BetterBlizzPlates 1.8.0f
## All versions:
### Tweak:
- Updated Import function to support Blizzards new native functionality that Plater uses so that Plater imports for npc color and casts works again.
- "Only show last name" setting fixed so words like "Bee-let" dont get shortened to "let". Also Classic versions so that they instead use first name on Totems, like how it is on Retail. 
## Retail
### Bugfix:
- Fix Castbar Interrupt Colors "Soon" Highlight Spark Position on Evoker Empowered Casts.
- Fix "Hide Elite Dragon" not hiding the silver version and some others.
- Fix new "Friends Only" setting for Class Indicator not being shown in the GUI in Advanced Settings.
- Fix BG Objectives not updating when flag drops due to aura update not coming through.
## Classic & Cata
### New:
- "Raise Name Strata" setting added (same as on retail) that shows name above healthbars instead of behind them. In Advanced Settings under "Reposition Name".
### Bugfix:
- Fix Friendly Nameplate "Arena" toggle not working. Deleted this setting from Era and accidentally deleted it on Cata too.



# BetterBlizzPlates 1.8.0e
## Retail
### Bugfix:
- Fix a typo causing lua errors after renaming a function related to "Friends only" settings.



# BetterBlizzPlates 1.8.0d
## All versions
### Tweak:
- Threat Color: Tweak to when offtank color shows for Tanks. Added a npc check to color pets getting aggro and showing offtank color for those cases.
## Retail
### Tweak:
- Tweaks to Interrupt spell list for Castbar Interrupt Color.
### Bugfix:
- Fix inconsistencies for Castbar Interrupt Color.
- Fix "Blitz Indicator" showing up on Personal Resource Display
## Era/Sod, Cata & Wrath:
- Added more friendly nameplate auto toggle settings, as already implemented for Retail.




# BetterBlizzPlates 1.8.0c
## Retail
### New:
- Party Pointer: New setting to enable/disable showing CC on top of Party Pointer (Advanced Settings). This is on by default.
- Hide Healthbar (Friendly): New subsetting that lets you keep healthbars on tanks and healers in PvE. Shift+Rightclick the checkbox to toggle.
### Tweak:
- Class Icon and Party Pointer CC overlay will now not be shown if Key Auras on Friendly Nameplates are enabled.
- Updated the PvE healthbar hiding function a little bit.
### Bugfix:
- Fix bug from patch 1.8.0 causing some nameplate auras to become hidden/glitchy with Party Pointer enabled due to a flaw in some of the new logic.


# BetterBlizzPlates 1.8.0b
## Retail
### Bugfix:
- Fix a lua error in nameplate auras.



# BetterBlizzPlates 1.8.0
## Retail:
### New:
- Nameplate Auras: New subsetting for "Blizzard Default Filter". Lets you keep the Default Blizzard Filter but hide others auras. Similar to the "Only Mine" filter but doesn't add trash auras that are yours that you need to blacklist.
- Party Pointer: 13 more textures to pick from in the Advanced Settings Section. The last option lets you enter a custom atlas texture too.
- Hide Friendly Healthbar setting now has a "Show Pet" subsetting by shift+rightclicking to allow pet to still be shown.
### Tweak:
- Made CC show on top of Party Pointer as well.
- Hide Friendly Healthbar NPCs setting now also works in PvE Dungeons and there is a new right-click setting on the same checkbox that you can enable if you want npc healthbars to be kept shown in PvE only.
- Castbar Customizations' "Change background texture" setting made it so the background was red on un-interruptible casts, despite the color setting. This was only intended temporarily until settings got made but was forgotten about. This is now off by default but can still be enabled again by right-clicking the color button in /bbp -> Castbar -> Color button next to "Change background texture".
### Bugfix:
- Fix Class Indicators Pet setting being dependant on pin mode by accident.
- Fix "Purgeable" aura filter causing non-purgeable buffs from the "PvP Buffs" filter to not show, this was unintended.
- Fix issue with Fade NPCs + Hide Friendly NPC Healthbar causing frame to get completely hidden instead of its set value.
## Retail, Cata, Classic
### New:
- Threat Color: DPS/Heal: "Targeted" color. This color kicks in when you are targeted but dont have aggro. Default same color as Full Aggro but now you have the option to change it.
### Tweak:
- Cata/Era: Due to Nameplate Class Color CVar being crazy wonky (Blizzard handles this, not BBP) I have added a tweak that should force Blizzard to Class Color them if the setting is enabled. However this will not be able to fix it for friendly nameplates in PvE instances due to restrictions. If you are having issues with this you may have to clear your WTF folder or even do a fresh install. I could not figure out the cause of this rare bug other than it being from Blizzard.
### Bugfix:
- Totem Indicator was not able to detect NPC ID on players own Pet and possibly some other cases too, that is now fixed.



# BetterBlizzPlates 1.7.9d
## Retail:
### Bugfix:
- Fix issue in Instant Combo Points sometimes causing a lua error.
- Fix non-english text on "Target Name" for castbar.


# BetterBlizzPlates 1.7.9c
## Retail:
### New:
- Color settings for Nameplate Shadow and its Highlight (Misc) - Rightclick to change its color from black/white to any color.
### Tweak:
- Health Numbers formatting now show billions as well.
- Revert last updates pandemic logic changes. Accepting this update before bed and thorough testing was too hasty of me and it is less optimal than the old code. Will see if maybe I can look into it later.
- Fix it so the "Hide castbar" feature does not instantly hide castbar if "Show who interrupted" is enabled and someone got kicked.
- Added Stealth (Rogue, druid, hunter camo, invis) to key auras. Mostly to easier see teammates status on Class Indicator.
### Bugfix:
- Fixed "Hide name while casting" setting sometimes still not showing name again after cast is finished.



# BetterBlizzPlates 1.7.9b
## Retail:
### New:
- Added option to keep LevelFrame shown for Classic Nameplates in PvP (Right-click Hide Level setting)
### Tweak:
- Fix some pandemic logic and added special logic for Rip. Thank you to NicolasYD for fixing this <3
### Bugfix:
- Fix Personal Bar Alpha slider not actually being hooked up properly to adjust the CVar.
- Fix level showing on lvl 0 interactable nameplates (untested so hopefully)
## All versions:
### Tweak:
- Updated Threat Color to work in Alterac Valley if "Always on" is enabled (usually disabled in PvP automatically)
- Another tweak to Threat Color based on feedback.

# BetterBlizzPlates 1.7.9
## Retail
### New:
- Druid: Always Show Combo Points (CVar Control)
- Added "nameplateSelfAlpha" to CVar Control section. This is 0.75 by default on Blizzards side, but most people would maybe want to set it to 1.
- Personal Bar Tweaks (Misc), shows name + guild name (if enabled) on Personal Bar Nameplate.
- Support for TRP3 Personal Resource Bar RP Color (Misc)
### Tweak:
- Classic Nameplates will now have LevelFrame hidden automatically when in PvP.
- Nameplate Border Size setting now allows minimum 0.5 pixels.
- Added Prototype and Yanone font to non-english clients as well, did not realize this was not the case by default.
### Bugfix:
- Fix level text still showing with with Classic Nameplates with Hide Level enabled.
- Fix typo in pandemic+compacted auras logic causing lua error. 
- Fix castbar text showing squares with castbar customization on for non-english clients.
- Fix issue with castbar setting "Hide name during casts" causing names to stay hidden.
## Retail, Classic & Cata
- Added new Color Threat settings from Retail version to Classic versions.
- Color Threat tweak for DPS, should now color when you are being targeted as well due to threat API being a bit clunky? Testing this pls give feedback.

# BetterBlizzPlates 1.7.8
## Retail
### New:
- Nameplate Vertical Position (Misc)
- Nameplate Clickable Height Adjuster (Misc)
- Key Auras: Anchor setting. Right (Default), Left & Center. Left will stack leftwards, opposite of the default Right option and Center will stay centered on the nameplate.
- Execute Indicator: Healthbar recolor when in execute range setting.
- Hide Personal Resource Manabar FX (Misc)
### Bugfix:
- Fix Key Auras' Gap setting being affected by aura scale unintentionally.
- Fix issue with Classic Nameplates Level not displaying properly.
- Fix Nameplate Border Size setting not working with Nameplate Size set to 1 due to Blizzard function not running then.


# BetterBlizzPlates 1.7.7b
## Retail
### New:
- Threat Color: Turn off while Solo setting.
### Tweak:
- Kalvish profile update
### Bugfix:
- Fix Hide NPCs' reset function causing some nameplates that should be hidden to pop back up.

# BetterBlizzPlates 1.7.7
## Retail
### New:
- Key Auras: Horizontal Aura Gap setting specific to Key Auras.
- Health Numbers: Font Outline dropdown in Advanced Settings
- Health Numbers: Text Alignment dropdown in Advanced Settings
- Friendly Nameplate Toggles: Added Epic BGs and World to the auto toggle settings and split Dungeons and Raids into two different settings.
### Tweak:
- Having both Color Threat and Color NPC should now work a bit better for Tanks. It will keep NPC Color if you have aggro and only color for threat if you dont have aggro or are losing it.
- Blessing of Sanctuary now has green important glow by default for PvP Buffs/KeyAuras settings
- Guild Name if enabled is now not shown if name is hidden.
### Bugfix:
- Fix level text on Classic Nameplates sometimes showing behind the texture.
- Fix issue with "Non-Target Alpha" not applying the reduced alpha on nontargets for new nameplates popping up.
- Fix alpha issue in Fade NPC feature.
- Fix "Show resource on nameplate" toggle causing nameplate height to reset to default (due to Blizzard code).


# BetterBlizzPlates 1.7.6b
## Retail
### Tweak:
- Kalvish profile update

# BetterBlizzPlates 1.7.6
## Retail
### New:
- Class Indicator: Only for Party setting. - Only shows Class Indicator on people in your Party.
- Class Indicator: Hide Friendly Healthbar setting. - Hides healthbar only on friendly nameplates with Class Indicator on them.
- Party Pointer: Only for Party setting. - Only shows Party Pointer on people in your Party.
- Party Pointer: Show on Pet setting.
- Hide NPC: Hide Others Pets -> Hide other friendly pets and only show your own. Will only show main pet. This is now on by default.
### Tweak:
- Class Indicator Pet Icons updated.
- Class Indicator: Show Background Color is now on by default for new users.
- Tweaks to Class Indicator's Pin Mode setting. Toggling the setting now toggles different and new settings: Hide Friendly Healthbar and Hide Name (for Class Indicator nameplates specifically and not all like previously).



# BetterBlizzPlates 1.7.5c
## Retail
### Tweak:
- Nameplate Auras: PvP Buffs Filter: Monk's Dance of the Wind aura (432180) now only shows when it has 5 stacks or more. If you want it to always show add it to whitelist.
- Small tweaks to Class Indicator pet settings.



# BetterBlizzPlates 1.7.5b
## Retail
### Tweak:
- Nameplate Auras: PvP Buffs Filter: Monk's Dance of the Wind aura (432180) now only shows when it has 5 stacks or more. If you want it to always show add it to whitelist.
### Bugfix:
- Fix CC auras having glow on them on enemy nameplates unintentionally due to "PvP CC" filter being enabled for friendly nameplates for Class Indicator users.
- Fix Class Indicator showing on all friendly npc nameplates after oopsie in Pet icon logic



# BetterBlizzPlates 1.7.5
## Retail:
### New stuff:
- Class Indicator: CC Icons. Show CC Instead of Class/Spec during CC.
- Class Indicator: Show Pet. Show class indicator on pet too. On by default but this requires "Show Friendly Pets" enabled in the CVar Control section which is not on by default.
- Theat Color: Now has "Tank: Losing Aggro" and "Tank: Off-Tank Color" settings. I rely on feedback for these functioning properly so please be vocal (i dont pve)
- Nameplate Shadow: Target Only setting.
### Tweaks:
- Key Auras now have more auras in the list. I've been a bit more lenient on what to show and allowed more to be shown here. What is a key aura? Currently a key aura is: CC, Immunity, and a few other big, but short duration auras requiring a shift in gameplay.
- Added duration to show on Sanctified Ground and Absolute Serenity auras with aura settings enabled.
- Nameplate Aura settings are now enabled by default for new users.
### Bugfix:
- Fix Nameplate Shadow: "Highlight shadow on Mouseover" always being active regardless of that setting being on or not.
- Fixed Rebuke showing on Paladin's nameplates when using it with interrupts enabled. Rebuke is also an aura Paladins get when they use it for some reason... This was not accounted for.

## Classic & Cata:
### New:
- Elite/Rare Indicator is now on by default for both retail and classic nameplates. New setting to hide it is under "Enemy nameplates" on general page /bbp
### Bugfix:
- Fix nameplate aura tooltip repeating spell id multiple times






# BetterBlizzPlates 1.7.4
## New stuff:
- Class Indicator: Pin Mode: Display the Icon as a Pin and hide healthbar, castbar and name.
- Class Indicator: Background Color (Shadow behind Icon, Class Color & Custom, black default)
- Nameplate Interrupt Duration Auras are now optional, but on by default when Nameplate Aura Filtering is enabled. Checkbox in Nameplate Auras section called "Interrupts".
## Tweaks:
- Class Indicator: Now gets faded out when people chat so you can read chat message from chat bubble.
- Class Indicator: Small touchups on the Square Border Texture.
- "Only show last name" setting for NPCs now show first name if its a totem. Grounding/Tremor etc instead of bunch of "Totem"s.
- Class Indicator and Party Pointer now ignores Nameplate alpha and always show at full alpha.



# BetterBlizzPlates 1.7.3
## Tweaks:
- Instant Combo Points: Holy Power for Paladins also supported.
- Aura Filtering now also shows duration on auras Power Word: Barrier, Earthen Wall and Grounding Totem in addition to Smoke Bomb. (This also works on BigDebuffs & OmniAuras. Sidenote: Try out Key Auras setting which is similar to those two)
## Bugfix:
- Fix Key Auras always being shown instead of abiding by the Show Buffs/Debuffs and Blacklist filters like intended.


# BetterBlizzPlates 1.7.2d
## Tweak:
- Tweak to always get updated spec id's in World content to ensure people who respec dont show up as wrong spec.
- Tweak to Fade NPC to never fade out player pet and work more reliably together with fading non target nameplate setting.
- Tweaks to interrupt list for interrupt color, only counting pure kicks again.
- Mirror Images adds 3 frostbolt debuffs. I've made it so only one appears to clean up clutter. You can of course still blacklist the id (59638) entirely.
## Bugfix:
- Fixed issue for new users where their Nameplate Height value would reset on logout/login.
- Fixed Custom HealthBar Color affecting personal plate.

# BetterBlizzPlates 1.7.2c
## Bugfix
- Fix CC filter causing all CC on enemy nameplates be considered a "Key Aura" by mistake.

# BetterBlizzPlates 1.7.2b
## Bugfix:
- Fix Key Auras enabling CC auras to show on friendly nameplates even without Show Debuffs filter enabled.
- Fix Castbar Icon Pixel Border setting showing border when icon is hidden but castbar shield icon is showing.
- Fix "Color NPC Healthbar" name color bleeding onto Player nameplates and not getting updated due to function skipping player nameplates.



# BetterBlizzPlates 1.7.2
## All versions
### Tweak:
- BBP now stores the value of all CVars that can be adjusted with BBP for new users to ensure there is a backup to go back to should they chose to uninstall.
- Fix CVars that have options in BBP not updating in BBP if changed elsewhere.
- Added some Execute Indicator settings from retail to classic versions (Line & Target Only).
## The War Within
### New:
- Castbar Pixel Border & Castbar Icon Pixel Border settings.
- Nameplate Auras now show Interrupt durations if nameplate auras section is enabled.
- Key Auras: Setting to only show/move CC and not Important Buffs.
- Key Auras: Friendly setting (was on by default before, now needs to be checked)
### Tweak:
- Small Starter & Blitz profile tweaks.
- Health Numbers "Format Millions" setting now on by default due to increased health pools.
### Bugfix:
- Fix class color nameplate border sometimes having reduced alpha.
- Fix execute indicator line showing on friendlies without it enabled on them.
- Fix execute indicator showing on personal plate.
- Fix "Color NPC Healthbar" setting causing text color to bleed over to other unintended nameplates.
- Fix nameplate border color settings having reduced Alpha due to default Blizzard functionality.




# BetterBlizzPlates 1.7.1d
## The War Within
### Tweak:
- Snupy profile update
### Bugfix:
- Fixed Key Auras affecting normal auras positioning.
- Fixed Barkskin being tagged as a Key Aura from testing.
- Fixed Key Auras not stacking when theres two different aura types (buff/debuff).

# BetterBlizzPlates 1.7.1c
## The War Within
### Bugfix:
- Remove a debug print.

# BetterBlizzPlates 1.7.1b
## The War Within
### Bugfix:
- Fix broken logic for deciding whether Class Indicator should show or not after introducing healer only setting.

# BetterBlizzPlates 1.7.1
## The War Within
### New:
- Nameplate Auras setting "Enable Key Auras". Works similar to BigDebuffs/OmniAuras. Will be seeing a lot of tweaks.
- Kalvish profile (www.twitch.tv/kalvish)
- Class Indicator "Only Show Healers" setting to make it possible showing on friendly OR enemy healers only.
### Tweaks:
- "Reset BBP" button moved to show in Advanced Settings section.
- Few more auras in PvP Buffs filter. Again thanks to Zwacky.
### Bugfix:
- Fix Compacted auras being Enlarged instead on Personal Resource Bar due to copypaste mistake.
- Fix Totem Indicator's positioning being wonky during adjustments.



# BetterBlizzPlates 1.7.0
## The War Within
### New:
- Instant Combo Points setting (in CVar Control). Remove combo points animations for instant feedback on Rogue, Druid, Monk and Arcane Mage.
### Tweak:
- Add more auras to to PvP CC & Buffs Filters. Thanks to Zwacky for gathering the ids and helping.
### Bugfix:
- Added some extra safe checks when importing Plater strings to avoid lua errors if importing a wrong type of string.
- Fix position of interrupt highlight spark on castbar 

## Classic & Cata
### Tweak:
- Added highlight spark on castbar for when interrupt will be ready during cast if that setting is on.


# BetterBlizzPlates 1.6.9i
## The War Within
### Bugfix:
- Fix Twin Peaks missing from BG Objectives.

## All versions
### Bugfix:
- Fix Hide Healthbar Toggle keybind not updating settings properly.
- Potential fix for nameplate frame level issue.



# BetterBlizzPlates 1.6.9h
## The War Within, Classic Era/SoD & Catalcysm
### New:
- Nameplate Auras: Sort Auras by Duration setting.
### Tweak:
- Added missing Nameplate Class Color CVar forcing on login.
### Bugfix
- Fix Hide Healthbar Toggle Keybind (BBP) not working.

## The War Within
### New:
- PvP CC & Buffs can now have Important Glow on them as categories you can color them by category. Right-Click the PvP CC/PvP Buffs filter checkbox to open settings to customize.
- Class Indicator: Hide Name setting. (Only hides name on units with a class indicator.)
### Tweak:
- Magnusz profile update



# BetterBlizzPlates 1.6.9g
## The War Within
### Tweak:
- Added Intro screens with profile selections for new users for Classic Versions as well.
- Removed "Skip GUI" as an option, now always active.

### Bugfix:
- Fix Class Indicator only showing Deephaul Ravine crystal for a split sec and removing it again.
- Fix "Reset BetterBlizzPlates" button showing up randomly on screen unintentionally for people without skip GUI enabled due SettingsPanel not being loaded in.
- Fix some LevelFrame hide/show issues on Classic versions.
- Fix Target Highlight not being hidden with some specific settings when its supposed to be.



# BetterBlizzPlates 1.6.9f
## The War Within
### New: 
- New Nameplate Aura filters to enable all important pvp buffs and all pvp cc and enlarges them by default.
- Adding Mage Barriers to Whitelist now only Glows/Enlarges if they are specced into Overpowered Barriers. (This can be turned off with /run BetterBlizzPlatesDB.opBarriersOn = false)
### Tweak:
- Nameplate Auras: "Separate Buff Row" is now enabled by default. Your settings may have changed due to this.
### Bugfix:
- Castbar Shield now also gets faded when castbar/nameplate is faded.

## The War Within, Classic Era & Cataclysm
### Bugfix:
- Fixed issue with Nameplate Aura's "Separate Buff Row" setting causing the buffs to go too high with multiple rows of debuffs if the buffs were enlarged/square. Not a perfect fix but better than it was. Wish I was smart.
- Fixed Friend/Guild Indicator to be anchored to spec name during Arenas if spec names are enabled.



# BetterBlizzPlates 1.6.9e
## The War Within
### Bugfix:
- Fix typo in Castbar Edge Highlight causing errors.

# BetterBlizzPlates 1.6.9d
## The War Within, Classic Era, Cataclysm
### Bugfix:
- Fix missing mid-section castbar color in the Castbar Edge Highlight feature when using castbar recolor/retexture.

# BetterBlizzPlates 1.6.9c
## The War Within
### Tweak:
- Class Icon:
  - Add Ashran's Ancient Artifact and Brawl: Deepwind Dunk Dunkballs to BG Objectives.
  - Changed to higher res icons on Retail
- Revert nameplate change causing some unintended issues for some people.
### Bugfix:
- Fix the Classic Nameplate Border showing above name.
- Fix Toggle Friendly Healthbar Keybind function causing lua error when GUI was not loaded.

# BetterBlizzPlates 1.6.9b
## The War Within
### New:
- Class Indicator now has a lot more settings:
  - Now shows Battleground Objectives (Flags, Orbs)
  - Show Tank Icons
  - Always show on Healers (despite only enemy/friendly setting)
  - Always show on Tanks (despite only enemy/friendly setting)
  - Always show on BG Objectives (despite only enemy/friendly setting)
  - Change Enemy Healer Icon (with 3 modes)
  - Show Health Percent instead of Name
  - Reaction Color Border
- New "Blitz Profile" that is a step up from the "Starter Profile". This is an early basic version meant for new users. It is not complete but I decided to include it for now to make things easier for new users. It will be tuned more in the future.
- New misc setting to color border of focus target.

### Tweak:
- Changed order of a few things in Hide NPC feature making sure fully hidden NPCs trumps secondary murloc mode.
- Hide level frame on friendly nameplates on retail and adjust position slightly and make sure its not shown in pvp with retail nameplates
- Healer Indicator higher draw layer level

### Bugfix:
- Fix Nameplate Auras' "Important Glow" sometimes "blinking".
- Fix an issue with Pet Indicator causing nameplate castbars/names to be stuck hidden

## The War Within, Classic Era & Cataclysm
### Bugfix:
- Fix issues with Hide Castbar feature
- Fix accidental removal of Player check for Threat Color causing some Enemy Player Nameplates to potentially get colored.
- Fixed Totem Indicators Icon Only mode not hiding name on name updates on retail and did some small tweaks on classic versions.

# BetterBlizzPlates 1.6.9
## The War Within, Cata & Era
### New:
- Class Indicator Alpha setting.
- Export/Import section now has a delete button top right on each section when mousing over them that deletes all data in that section.
### Tweaks:
- Skip GUI setting now also available on Classic versions and is on by default.
- Search is now available on Classic versions
- Color Threat will now only override Color NPC if you have aggro.
- Fade NPC feature now also fades the castbar
- Castbar Icon now also gets faded when a nameplate is faded, when castbar customization is on.
- NPC Title setting will now show under healthbar if healthbar is visible

## The War Within
### New:
- Pet Indicator & Hide NPC now both have settings to hide secondary pets during arena. These will be enabled by default.
- You can now adjust Personal Resource Display Aura size separately and chose to disable enlarge/compact/glow on it
- Hide Castbar Icon setting.
### Tweak:
- Class Indicator: New circle border. Also lowered the Strata so it does not appear above auras and added a setting to raise strata
- New and more reliable healer detection that works without Details. Thanks to RBGDEV for the code.
- Added a few more common arena npcs to Fade Out & Totem Lists.
- Level Indicator can now also be shown on the right side of nameplates with default non-classic nameplates. Positonal settings etc might come later.
- Small Pets in PvP setting slightly changed and width can now be changed.
- Small Pets setting will no longer reduce healthbar width for comp stomp npcs.
- Small tweaks to the nameplate shadow/highlight setting.
### Bugfix:
- Fix Blitz Indicator. Was not working properly at all due to a couple of mistakes.
- Fix friendly auras being too high with "Non-Stackable" friendly nameplate setting on due to a change from an earlier patch that had not been accounted for.
- Fix BG Spec Names option accidentally being run on npcs causing other name settings to not display as intended.

## Classic Era
### Bugfix:
- Fixed an issue with the "Castbar: Interrupted by" setting causing shaman interrupts to cause a lua error.

### Note
- I might have missed some other minor bugfixes in the patch notes, and I might have introduced some new ones. Please keep reporting bugs, however minor.





# BetterBlizzPlates 1.6.8d
## Classic Era/SoD
- Early Alpha version of BBP for Classic Era/SoD. Please report bugs, very limited testing has been done. Classic Era and Cataclysm will support eachothers import codes 100%. This version will just have the cata totem list, so not very accurate.

# BetterBlizzPlates 1.6.8c
## The War Within
### New stuff:
- Aeghis profile (www.twitch.tv/aeghis)
### Bugfix:
- Fix Pandemic Glow Texture Size accidentally scaling with enlarged scale value instead of default scale value when not enlarged.
### Note:
- Yet another small update. Rip time.

# BetterBlizzPlates 1.6.8b
## The War Within
### Bugfix:
- Hide NPC: "Murloc Mode" should now properly always hide castbar as well.
- Added a variable that skips messing with cvars if Plater is also loaded. (BetterBlizzPlatesDB.skipCVarsPlater = true)
### Note:
- Been very busy. Hopefully I get some more time now in December to work on stuff.

# BetterBlizzPlates 1.6.8
## The War Within
### New stuff:
- Snupy profile (www.twitch.tv/snupy)
- Added a "Always Show" setting for purgeable auras that will show the purge texture regardless if you have a purge ability or not. This is on by default, and have been, but can now be turned off.
### Tweak:
- New dropdowns for Texture & Fonts. Will change all dropdowns over time to use the new system.
### Bugfix:
- Fixed "Hide nameplate aura tooltip" causing lua error in PvE.
- Fixed multiple issues with the new Nameplate Shadow/Highlight setting. Blocking mouseover macros, showing on some hidden nameplates, now showing when mouseover character model as well as nameplate.
- Fix nameplate aura test mode causing lua errors.
- Fix Execute Indicator causing lua errors on some object nameplates (hopefully, untested).
### Note:
- I wanted to push a few more new features but it will have to wait until I have had more time developing and testing them.

# BetterBlizzPlates 1.6.7
## The War Within
### New Stuff:
- Misc: Nameplate Shadow & Mouseover Highlight settings. The mouseover detection is not perfect, especially with overlapping nameplates, but until I can figure out a better method it will stay like this.
### Tweak:
- Healer Indicator: Added default Blizzard spec info API call for enemy units while in arena. This API is only available for enemy units in arena specifically but is prefered over Details due to it identifying healer immediately.
- Fixed up Party Pointer test mode.
### Bugfix:
- Fix Castbar Emphasis color settings not working properly.
- Fix Execute Indicator mistake from an earlier patch causing a lua error with certain anchors.
## Cataclysm
### Tweak:
- Update to 4.4.1 Settings API Support

# BetterBlizzPlates 1.6.6d
## The War Within
### Tweak:
- Search: Searching "cvar" now shows all checkboxes/sliders affecting CVar values. Search is still WIP and will receive many more changes over time.
- Normal Evoker Castbar: Now also changes the spark to be identical to default.
### Bugfix:
- Fix Classic Nameplates setting having a little gap between border and health on the right side when level is not hidden.
- Fix Totem Indicator width setting accidentally applying the "Small Pets in PvP" setting for non-totems even when that was off.
## Cataclysm
### Bugfix:
- Fix profile Import functionality being broken since renaming of the function ages ago >_<

# BetterBlizzPlates 1.6.6c
## The War Within
### Tweak:
- Health Numbers "Class Color" setting will just color the text after the healthbar color instead for all nameplates.
- Added a more "HD" version of the Dragonflight texture.
- Changed old "Shattered" texture to a more HD version.
### Bugfix:
- Fix elite dragon being hidden if Small Pets in PvP was enabled (Forgot to rename the copypaste d'oh)
- Fix Execute Indicator text version not showing after 1.6.6 update. Oops.

# BetterBlizzPlates 1.6.6b
## The War Within
### Tweak:
- "Remove realm names" setting is no longer affecting raidframes (Old code that never got changed)
### Bugfix:
- Fix Misc setting "Separate Friendly/Enemy Nameplate Height" being backwards due to a change from last update. Oops.

# BetterBlizzPlates 1.6.6
## The War Within
### New stuff:
- Search feature! Top right SearchBox that normally searches Blizzard settings has now been hijacked and will search BetterBlizzPlates settings instead if you have the BBP settings open. (WIP)
- Health Numbers: Class Color setting.
- Execute Indicator: Target only setting.
- Execute Indicator: Use Texture setting that displays a line instead of text.
### Tweak:
- Aura Color: "Only in PvE" setting now also does not color Player nameplates and has a better tooltip description.
- Nameplate Auras are now anchored to the healthbar (was NamePlate.UnitFrame) with Nameplate Auras settings enabled. This makes it so when increasing castbar height with Castbar Emphasis the auras follow properly.
- Tweak Pandemic Timers to never go below base duration (Rot and Decay refresh caused wrong timings)
### Bugfix:
- Fix Hide elite icon setting overlapping other setting in the GUI
- Fix elite icon popping back up even with the hide setting on.
- Fixed nameplate color going back and forth between target/aura color with both features enabled. Always prioritizes target/focus color over aura color now as intended.
- Fix issues with classic nameplates border not aligning properly around the healthbar.
- Fix GUI slider for Castbar Emphasis Spark Height accidentally adjusting Emphasis Text Size instead.
## Cataclysm
### Bugfix:
- Fix Misc setting "Do not hide friendly healthbars in PvE" not working.
- Fix GUI slider for Castbar Emphasis Spark Height accidentally adjusting Emphasis Text Size instead.

# BetterBlizzPlates 1.6.5
## The War Within
### New stuff:
- General: Hide elite dragon icon (Under Enemy Nameplates)
- Misc: Adjust Personal Resource Bar Vertical Position
- Misc: Hide Personal Resource Bar Manabar
- Misc: Hide Personal Resource Bar Extrabar (Stagger/Ebon)
- Castbars: "Always on Top" setting that forces all nameplate castbars to be ontop of other nameplates so they are never covered.
### Tweak:
- Castbar Emphasis now makes the castbar appear on top of everything else so you dont miss a cast thats been emphasized.
### Bugfix:
- Fix Personal Resource Bar sometimes not picking up special auras like Frenzy that are not shown elsewhere with Nameplate Aura settings on.
- Fix Druid Blue Combos sometimes not being in order

# BetterBlizzPlates 1.6.4
## The War Within
### New stuff:
- Mmarkers profile
- Party Pointer "Healer only" setting
### Tweak:
- Pandemic Glow for auras that have a pandemic effect is now properly glowing when 30% of their duration is left instead of a flat 5 sec like it was before. For non-pandemic auras the default timer is still 5sec. For UA and Agony if their refresh talents are picked the Pandemic Glow will first be orange when it enters that range and then turn red when it also enters the 30% window.
### Bugfix:
- Fix the Interrupt CD Color spark positioning on channeled casts.
- Fix "Castbar Edge Highlight" causing lua errors in PvE.
- Fix druid blue berserk combos sometimes not activating.
- Potential fix for combopoints jumping to wrong nameplate due to a mix of settings. Requires more testing, pls report if this is still an issue.

# BetterBlizzPlates 1.6.3c
## The War Within
### Tweak:
- The "Interrupt CD Color" for castbars will now also display a spark on the castbar exactly where your interrupt becomes ready instead of just displaying a different color for casts where your interrupt will be ready.
- "Full Profile" export strings can now be imported in the other import windows and will then only import that specific portion of the full profile.
- Changed the color of Priests Re-Fear Shadow NPC to a more pinkish less threathening color (Was too similar to Psyfiend).
- Updated Nahj profile.
- Added missing `nameplateShowAll` CVar to CVar listener (If changed elsewhere will also change in BBP settings).
### Bugfix:
- Fixed Reposition Name not positioning name properly in a duel with a friend.
- Fixed "Color by Aura" accidentally checking both name and id when id was added.
- Fixed Druid Blue ComboPoints not getting activated if Druid was not in catform during login/reload.
- Fixed "Hide nameplate auras" on general page not working immediately
### Known issue:
- Nameplate resource can attach to wrong nameplates (with attach under nameplate setting?)

# BetterBlizzPlates 1.6.3b
## The War Within
### Tweak:
- Reposition Name now has a "Raise Strata" setting that is on by default.
- Make it so "Small Pets in PvP" only reduces the width of npcs that are not in the Totem Indicator if that feature is enabled. This was the intended behaviour but was only active if "Totem Width" setting was on.
### Bugfix:
- Fix Reposition Name no longer overlapping healthbar like intended by introducing new setting.
- Fix refresh of nameplates putting cast timer text back to default value instead of `BetterBlizzPlatesDB.npTargetTextSize`, this will get gui settings in a future patch.
- Updated castbar test mode to respect the new customizeable target text + cast timer text size.
- Fix issue with aura cooldown frame showing above aura glows.
- Fix issue with castbar customization enabled causing castbars to be white if ClassicFrames was enabled.

# BetterBlizzPlates 1.6.3
## The War Within
### New stuff:
- Small Pets in PvP setting. (Totem Indicator plates will stay full size, unless specified otherwise)
- Classic Nameplates look (Only healthbar for now, might do castbar later. You can use customize castbar and select on texture if youd like.)
- Nameplate Auras: Color aura border by type setting.
- Arena Nameplates (spec name / id) now also has a setting to show spec names in Battlegrounds.
- New misc setting: Skip GUI, minmax setting that doesnt load GUI into the game until needed.
### Tweak:
- Added Monk Images (Storm, Earth & Fire) to Hide NPC & Fade NPC whitelists.
- Removed "Fade all but target" setting from Fade NPC. It doesnt make sense anymore after adding whitelist mode.
- Made Totem Indicator hide BigDebuffs icon on Totems on Retail as well when healthbar is hidden.
- Changed default color on Evoker "Past Self" NPC in Totem Indicator, original color was too close to evoker themself causing some confusion. This change will only be active for new users.
### Bugfix:
- Fix issue with Hide NPC causing Target nameplate to sometimes appear behind other nameplates.
- Fix issue with reposition name sometimes not repositioning.
- Fix issues with Fade NPC in combination with Fade Non-Target Nameplates
- Fix issue with "Hide healthbar" & "Show on Target" setting not hiding previous target nameplate again.
- Fix "Skip hiding friendly nameplates in PvE" setting not working.
- Fix issue with Smoke Bomb debuff on nameplates multiplying its cooldown frame across other auras.
- Fix Healer Indicator Anchor selections in Advanced Settings being backwards for enemy & friendly.

# BetterBlizzPlates 1.6.2
## The War Within
### Important Change:
- Changed default values for cvars: nameplateMinScale and nameplateMaxScale. They are originally 0.8 and 1, I've put them both to 0.85.
You can change of course this value but they will now be linked and have the same value.
This makes nameplates always keep the same size instead of scaling up and down tiny amounts depending on range.
The reason I've done this is because it opens up a lot of possibilities to do things I couldnt normally do due to cpu usage concerns, and probably even makes wow run a little lighter alltogether.
You might notice your non-target nameplates have changed (very minimal) in size and to re-adjust just go to /bbp -> Nameplate Size
### New stuff:
- Totem Indicator can now change the width of nameplate healthbars, made possible by the important change above.
- Name Reposition has been changed to no longer create a fake name but instead move the original one, should make it less prone to bugs, made possible by the important change above.
- Added cooldown timer on Smoke Bomb debuff. This also supports nameplate icons for BigDebuffs and OmniAuras.
- Subsettings for "Hide castbar" on Enemy & Friendly nameplates: "Show on Target". Right-Click the "Hide castbar" setting to toggle on/off.
- Subsettings for "Hide healthbar" on Enemy & Friendly nameplates: "Show on Target". Right-Click the "Hide healthbar" setting to toggle on/off.
- Show Druid Berserk Overcharge as blue on nameplate combo points.
### Tweak:
- Nahj profile update
- Pandemic timer for Agony and Unstable Affliction is now 10s and 8s instead of the regular 5s if the talents are learned.
- "Hide auras on totems" from Totem Indicator is now off by default instead. Could be confusing for dot classes.
- I've added a variable that controls size for nameplate target text and cast timer. Atm no GUI yet, default value is 11, you can change this size by writing /run BetterBlizzPlatesDB.npTargetTextSize = 11
- I've also added a variable that controls font outline for health numbers, also without GUI, to change it do /run BetterBlizzPlatesDB.healthNumbersFontOutline = "OUTLINE"    (or "THICKOUTLINE", or nil)
- Absorb Indicator now says millions instead of thousands. 7300k -> 7.3m
- Added Voidwraith (priest npc), Shadowfiend and Surge Totem to Totem Indicator and Hide/Fade Whitelists.
- General performance tweaks.
### Bugfix:
- Fix an issue with the "Hide castbar" setting for friendly nameplates potentially getting stuck.
- Fix missing buff check for personal nameplate auras causing whitelisted debuffs to go through filter even with debuffs turned off.
- Reworked how Name Reposition works and fixed issues with it in combination with Arena Names + Party Pointer.
- Fix threat color coloring friendly units (since no check was needed before the always on setting)
- Fix "Castbar Edge Highlight" erroring in PvE content.

# BetterBlizzPlates 1.6.1b
## The War Within & Cata
### Bugfix:
- Fix gui lists causing lua error if entry in lists didnt have an id

# BetterBlizzPlates 1.6.1
## The War Within & Cata
### New stuff:
- Plater NPC Color & Cast Color now importable in the Import/Export section.
- Health Numbers: Added "Players" & "NPCs" settings.
- Threat Color: "Only color during combat" (now on by default) and "Always on" settings.
- Fade NPC: "Whitelist mode" and "Only in PvP" settings.

## The War Within
### Tweak:
- Totem Indicator: Added priest hero talent "Shadow" npc that re-fears after 4 sec.
- "Set CVars across all characters" now on by default on fresh installs.
- Added Monk Stagger Personal Resource Bar to re-texturing if self mana is checked, might add separate setting for this in the future.
- Hide NPC with whitelist mode on should now be inactive during Brawl: Comp Stomp.
- Cast emphasis should now layer the casting nameplate on top of the others so it is more visible.
- Added Shadow, Past Self and Stone Bulwark Totem to HideNPC Whitelist.
### Bugfix:
- Fix Color NPC not having priority over "Custom healthbar color" on new nameplates.

# BetterBlizzPlates 1.6.0
## The War Within
### New stuff:
- Blitz Indicator: Show flag/orb on top of nameplates in battlegrounds.
- Hide Temp HP Loss setting (General)
- Recolor Temp HP setting (Misc)
### Bugfix:
- Fix deprecated API call for castbar interrupt recolor

## The War Within & Cata
### New stuff:
- Hide NPC: "Hide Neutral NPCs" setting, hides all non-target neutral npcs that are out of combat.

# BetterBlizzPlates 1.5.9f
## Cata
### Bugfix:
- Fixed aura Pandemic Glow setting. Completely forgot to add it to the cata version oops.

# BetterBlizzPlates 1.5.9e
## The War Within
### Bugfix:
- Fix Party Pointer setting "Hide All" unintentionally hiding name on new nameplates popping up when party pointer was not supposed to show (and not hide name).
- Fix overshield glow fix.. Hopefully maybe potentially the glow wont show in unintended cases now.

# BetterBlizzPlates 1.5.9d
## The War Within
### New:
- Made the the TWW Target Highlight fix optional, setting in Misc.
### Bugfix:
- Fixed friendly auras being positioned too high with clickthrough friendly nameplate setting on. This was due to splitting the clickthrough setting into two different ones and this logic should rely on the new separated setting instead and not clickthrough.

# BetterBlizzPlates 1.5.9c
## The War Within
### New stuff:
- Non-Target Nameplate Alpha setting in CVar Control. (This is a CVar on cata but not on retail)
### Tweak:
- Split friendly nameplate "Clickthrough" setting into two settings: One for clickthrough itself and other one for nonstackable. This change is because the nonstackable setting can cause issues and better left optional.
### Bugfix:
- Fix a lua error from nameplate auras occouring in some rare cases.
- Fix an issue for people who had deleted Skyfury Totem from their totem list causing the attempted update to its totem name to fail and make settings fail to load.

## The War Within & Cata
### Bugfix:
- Fix healer indicator always being hidden when both "Arena Only" and "BG Only" was set. Now shows correctly in both.

# BetterBlizzPlates 1.5.9b
## The War Within
### Bugfix:
- Fix overshields glow texture appearing on hidden healthbars due to new change in TWW.
- Fix things coloring things based on reaction sometimes causing enemies to show as neutral.

## Cata
### Bugfix:
- Fix lua errors from totem indicator after adding the "Hide Auras on Totems". These auras only exist optionally on cata and was causing errors if turned off.

# BetterBlizzPlates 1.5.9
## The War Within & Cata
### New stuff:
- Totem Indicator: Hide auras on totems setting (on by default, can turn off in advanced settings)
### Bugfix:
- Castbar Emphasis was jank. Fixed now.

## The War Within
### Tweak:
- Totem Indicator: Added Stone Bulwark Totem. Removed Fel Obelisk & Windfury Totem. If you have input on new pvp pets/npcs in TWW let me know @bodify
### Bugfix:
- Fix Threat Color coloring personal nameplate

# BetterBlizzPlates 1.5.8c
## The War Within
### Bugfix:
- Comment out a function call meant to update name positioning on nameplate but was causing ripple effect issues in some cases.

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