# BetterBlizzPlates 2.0.3
## Mists of Pandaria
### Note
- Quick rushed update for 5.5.4: The new MoP patch from Blizzard is quite big with a lot of changes and I was not prepared. BBP will need a lot more work than just this version. This version is more of a "hopefully things work OK until I can fix things" version but it is not expected to be stable. Please report bugs and be patient for fixes.

# BetterBlizzPlates 2.0.2c
## Midnight
### Tweak
- Update DailyShuffle profile (www.twitch.tv/dailyshuffle / www.youtube.com/@Dailydoseofsoloshuffle)
### Bugfix
- Fix Class Indicator CC icons getting stuck (and because of that also appearing on enemy nameplates unintentionally)
- Fix Pre-Midnight Nameplates Pixel border color getting set to white on focus from a mistake.

# BetterBlizzPlates 2.0.2b
## Midnight
### Bugfix
- Add missing forbidden check causing lua errors in PvE

# BetterBlizzPlates 2.0.2
## Midnight
### New
- Arena Names setting to only show healer spec names and leave others blank.
### Tweak
- Fix Class Indicator's "Show CC" setting for Midnight.
- Fix Class Indicator's "Show Health instead of Name" setting for Midnight.
- Castbar quick hide tweak for channeled bars now hiding properly (and not hiding when actually interrupted).
### Bugfix
- Fix a Blizzard nameplate bug causing nameplate debuffs sometimes hiding after a Mind Control. (They will never ever fix Mind Control bugs will they?)
- Fix coloring issue with threat color + custom healthbar color settings.
- Fix potential lua errors on moving nameplate vertical position.
- Fix potential execute indicator secret lua errors.
- Fix nameplate debuff icons showing on friendly pet nameplate when healthbar was hidden (also recommend turning off the CVar nameplateShowDebuffsOnFriendly which controls that)
- Fix some coloring issues with the nameplate selected border by default and also with the border color change setting.