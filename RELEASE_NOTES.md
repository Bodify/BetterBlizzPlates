# BetterBlizzPlates 2.1.2b
## Midnight
### Bugfix
- Fix oopsie on friend check for Big CC/Buff Icon showing them when turned off.

# BetterBlizzPlates 2.1.2
## Midnight
### New
- "Enlarged Aura" is back as an option in the whitelist. Can be combined with Important Glow for a separate (or same) color to Important one. Squares the aura by default and lets you scale it differently. Sorts first before others.
- "Enlarge All CC" and "Enlarge All Important" settings are back, making every crowd control debuff / important buff square and bigger (Not Big CC/Buffs). Both default to on, like they did pre-Midnight, so this will change how your rows look if you use those filters.
- Reworked, cleaned up and fixed a lot about how filters and Big CC/Buff Icon works. Now if CC/Important/Defensive filters alone are enabled they show above the nameplate as normal auras how they used to before Midnight. And enabling Big Buffs/CC Icon setting moves them to a side of the healthbar instead (or top of thats ur anchor).
- Big CC and Big Buffs settings are now split into Enemy and Friendly checkboxes.
- Disarms count as crowd control now. Blizzard's crowd control filter doesnt include them but we can add it now (on enemies at least).
- Friendly Debuffs have a "Dispellable" filter now.
- New setting "Dispel Color" next to the Crowd Control glow colors the CC glow after the debuff's dispel type instead of one CC color.
- Max Debuffs setting is enabled again kind of but it is very wonky due to API limitations. This will be properly fixed in 12.1.5 when new API becomes available.
- Cooldown Text Size is now split between "normal auras" and Big CC/Buff Icon.
- "Glow on Purgeable" is back under Aura Glows, putting the bright blue glow on buffs.
- "Blue Border for Buffs" is back, adding a blue border for buffs on the normal buff row above the nameplate (not Big Buffs).
- Stack Text now has its own settings, with a Show Stack Text toggle, its own font, X and Y offsets, alignment and color.
- Name Reposition's "Name Anchor Point" and "Healthbar Anchor Point" are now split into Enemy and Friendly dropdowns.
- Auras "Center On Enemies" and "Center On Friendlies" are now split into Center Buffs and Center Debuffs.
- Class Icon's "Show CC" checkbox in Advanced Settings now has a right click toggle to avoid showing the timer text and only shows the cooldown spiral.
- New setting "Combine Big CC and Buffs" puts both big icon groups on one shared anchor instead of two separate ones.
- New setting "Move Normal Buffs" moves the normal buff row off the top of the nameplate and onto a side of the healthbar.
- New setting "Grow Auras Top to Bottom". New aura rows move downwards instead of upwards.
- New setting to change the Purgeable Glow Color.
### Tweak
- Clean up filter section a lot and removed filter checkboxes where they didnt make sense (for example whitelist/blacklist on enemy nameplate buffs since that cant be filtered via spell ids)
- Update Venruki profile (www.twitch.tv/venruki)
- Update Disc / JustDisclipline's profile (www.youtube.com/@JustDisclipline)
- Update Pre-Midnight Nameplate profile a bit with new aura settings in mind.
### Bugfix
- Fix handling of the default nameplate aura CVars (for when Nameplate Aura settings are turned off). Some CVars were being forced unintentionally with the new nameplate auras.
- Fix issues with nameplate aura filters and how they were supposed to work. Checking filters didnt reduce the auras to just those filters as intended, especially for buffs.
- Fix the Big Buff Icon and Big CC Icon being too low on on actual auras compared to test mode. This fix will likely require you to re-adjust your auras.
- Fix the aura position sliders refusing 0 (forced 0.1)
- Fix secret error in Party Pointer due to getting class color with old API.
- Fix totem indicator not using the correct texture for grounding totem.
- Fix "Color Border By Type" having a pixel border on nameplate auras while Pixel Border was off. It now has a rounded colored border that fits the normal aura look instead.
- Fix Enemy "Hide Name"'s right click option to force show totem names not working properly.