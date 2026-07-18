# BetterBlizzPlates 2.0.8
## All versions (except Era, comes next week)
### New
- Complete haulover on how nameplates' clicking, stacking and positioning works. Nameplates should now stop "vibrating" and stop bouncing up and down. New section "Look & Behaviour" with these new things in it, some settings from Misc & CVar Control moved in here. You will have to re-do your settings for these things in here. Due to these new changes other addons (MiniCC++) that anchor things specifically to the nameplate (as opposed to its healthbar) will likely need you to tweak their x/y offsets to be positioned correctly.
- Castbar can now be adjusted the position of too in the new "Look & Behaviour" section.
- Castbar can also be adjusted the width of in the new "Look & Behaviour" section.
- Castbar now has a new "Fit Cast Icon on the left" setting. It moves the castbar to the right to make space for the icon and locks the icon perfectly. In the new "Look & Behaviour" section.
- Minimalist texture and PT Sans Narrow Bold font is now included.
- Castbar Customization section has a new "Anchor Icon Right" setting if you want the cast icon on the right side instead.
- Added a hidden variable if you want to change the castbar cast timer text font size. In order to tweak it you need to set a font size, 12 default, with this command and reload after /run BetterBlizzPlatesDB.npCastTimerSize = 12
- The WeakAura for ComboPoints, Shards, etc has been fixed for Era, TBC and MoP. Re-import it from the CVar Control section or ask me on Discord or check the pinned comment in BetterBlizzPlates channel if you have customized yours a lot for a simple update fix.
## TBC & MoP
### New
- New "Minimal" profile. Made by skinnay on Discord. Neat profile that is clean and using classic nameplates with clutter removed and auras neatly organized.
### Bugfix
- Fix a bunch of CVar names that were wrong after Blizzard changed them on the latest patches. This caused settings to not stick among other things.
- Fix castbar flashing wrong & white texture at the end of a cast sometimes.
- Fix missing kick spell id for aura interrupts.
- Fix Small Pets setting being wrong and ending up with way wider nameplates than intended.
- Fix potential lua error in castbar code when it sometimes doesnt have a texture.
- Add back missing TBC "Break-CC DoT" filter. PR by Romainjava ty!
## Midnight
### Tweak
- Class Icon "Pet": Added Whiptails icon. Ty Stroold for helping.
- Fix a check for BetterBlizzFrames' Personal Resource Display settings causing BBP to send chat msg about skipping the settings unintentionally.
- Tweak castbar background for when people who selected castbar pixel border without changing the background texture to fit the corners. Original texture has cut corners which left some gaps.
- Fix BBP cancelling out BBF's PRD settings with certain settings.