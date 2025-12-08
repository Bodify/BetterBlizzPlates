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