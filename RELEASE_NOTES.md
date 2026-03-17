# BetterBlizzPlates 1.9.9
## Midnight
### New
- New Faction Indicator setting. (Default setting only enabled in World Free-For-All content, tweak in Advanced Settings)
- Nameplate Aura Tweaks (in the temp section) now has Cooldown Text Size slider back. Note that the old value (from before Midnight) was smaller than the current one but uses the same variable so your cooldown text size might need a tweak now. The value from before in Midnight was 0.65 if you want to change it back to that.
### Tweak
- More nameplate font tweaks. Going insane. Misc: Custom Font Size should now work again. I hope and pray. I suspect this change may fix a few things but also break a few other things. Please report issues on Discord/GitHub.
- FrameSort numbering support fixed and back.
- Tweaks related to Arena ID and stuff depending on it like spec icons etc. Should hopefully be better again now but may see more tweaks or even removal if Blizzard keeps Blizzarding.
### Bugfix
- Fix the "Hide nameplate aura tooltip" setting for Midnight.
- Fix a castbar nil error.

# BetterBlizzPlates 1.9.8
## Midnight
### New
- Added Xaryu profile. Thank you for sharing.
- Friend Indicator (Misc): Add a scale setting and a right-click anchor setting. Also seen some tweaks to work better outside of instances (restricted inside).
### Tweak
- Improve the mask needed for changing textures on the new Midnight nameplates so when changing the texture it should fit more snug to the borders. Best I can do with the mess that is the new nameplates for now I think without changing everything.
- Fixup "Normal Evoker Castbars" setting, but untested yolo need bed /pray.
- Update Snupy & Pinkteddyp profiles.
### Bugfix
- Fixup some issues with PRD settings. (Still more fixes required but thats for another day, please report any issues)
## TBC
### Tweak
- All profiles included in addon that had "Default Blizzard Filter" enabled will get it fixed to instead do "Only mine" and whitelist + blacklist due to the fact that the "Default Blizzard Filter" doesnt exist on TBC and I havent made a substitude due to all auras having unique spell ids per rank and no time. Only mine is nearly the same thing anyway, may have to blacklist a trash aura or two.