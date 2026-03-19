# BetterBlizzPlates 1.9.9c
## Midnight
### Tweak
- Update Mes profile (www.twitch.tv/notmes). Thank you for sharing.
### Bugfix
- Fix an issue with Target Indicator's "Change Healthbar Texture" setting not properly applying a Mask on the texture and bleeding over the border/background if you were using default healthbar textures normally.
- Fix "Hide Personal Manabar" setting showing borders around the bar on login/reload.

# BetterBlizzPlates 1.9.9b
## Midnight
### New
- Add a "Hostile only" setting for Faction Indicator; showing only on nameplates you can attack.
### Bugfix
- Fix nil error on login.
- Fix issues with Faction Indicator and improve reliabiliy when crossing zones etc.

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