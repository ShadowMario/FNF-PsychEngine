# FNF-PsychEngine
Engine originally used on [Mind Games Mod](https://gamebanana.com/mods/301107)

**Credits:**
* Shadow Mario - Coding
* RiverOaken - Arts and Animations

WARNING: This engine is still very early in development! You can request new features though
_____________________________________

**Features:**

Atleast one change to every week:
* Week 1:
  * New Dad Left sing sprite 
  * Unused stage lights are now used
* Week 2:
  * Both BF and Skid & Pump does "Hey!" animations
  * Thunders does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
* Week 3:
  * BF does "Hey!" during Philly Nice
  * Blammed has a cool new colors flash during that sick part of the song
* Week 4:
  * Better hair physics for Mom/Boyfriend (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
* Week 5:
  * Bottom Boppers and GF does "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
* Week 6:
  * On Thorns, the HUD is hidden during the cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the Instrumental

Cool new Chart Editor changes and multiple bug fixes
![](https://i.imgur.com/tNY2A03.png)
* You can now chart "Event" notes, which are bookmarks that trigger specific actions that usually were hardcoded on the vanilla version of the game.
* Your song's BPM can now have decimal values
* You can manually adjust a Note's strum time if you're really going for milisecond precision
* You can change a note's type on the Editor, it comes with two example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.

Story mode menu rework:
![](https://i.imgur.com/UB2EKpV.png)
* Added a different BG to every song (less Tutorial)
* All menu characters are now in individual spritesheets, makes modding it easier.

A Credits menu
![](https://i.imgur.com/NdIQt3d.png)
* You can add a head icon, name, description and a Redirect link for when the player presses Enter while the item is currently selected.

Awards/Achievements
* The engine comes with 16 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx)

Options menu:
* You can change Note colors, Controls and Preferences there, not much to say about it. Go check it yourself k?

Other gameplay features:
* When the enemy hits a note, it plays the note hit animation on their strum, just like when the player hits a note.
* Lag doesn't impact the camera movement and player icon scaling anymore.
* Some stuff based on Week 7's changes has been put in (Background colors on Freeplay, Note splashes)
* You can reset your Score on Freeplay/Story Mode by pressing Reset button.
* You can listen to a song on Freeplay by pressing Space once.

Dialogue file (This is still slightly experimental, so i might make it easier to work with later, i don't know):
* Example:
```
psychic:bf
:0:talk:0.05:0:What brings you here so late at night?
:1:talk:0.05:0:Beep.
:0:angry:0.05:1:Drop the act already.
:0:unamused:0.05:0:I could feel your malicious intent the\nmoment you stepped foot in here.
:1:talk:0.05:0:Bep bee aa skoo dep?
:0:talk:0.05:0:I wouldn't try the door if I were you.
:0:unamused:0.05:0:Now...
:0:talk:0.05:0:I have a couple of questions to ask you...
:0:angry:0.1:0:And you WILL answer them.
```

* The first line has only two values as you can see, "Psychic" and "BF", in this case, Psychic will be the character on the left, while "BF" is the character on the right.
  * You can change characters at any time during the dialogue, by doing the same thing as on the first line.

* Dialogue lines must start with a `:` and every value is separated by another `:`, the values are in the respective order:
  * Character speaking (0 = Character on the left, 1 = Character on the right)
  * Animation to use during this line
  * Text speed, default is 0.05 (20 characters per second)
  * Speech bubble type (0 = Normal, 1 = Screaming/Angry bubble)
  * Text. Warning! Don't use this: `’`, use this instead: `'`
