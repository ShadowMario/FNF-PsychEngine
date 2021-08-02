First you need to be aware about how the Dialogue file works:
* Example:
```
psychic:left bf:right
:0:talk:0.05:normal:What brings you here so late at night?
:1:talk:0.05:normal:Beep.
:0:angry:0.05:angry:Drop the act already.
:0:unamused:0.05:normal:I could feel your malicious intent the\nmoment you stepped foot in here.
:1:talk:0.05:normal:Bep bee aa skoo dep?
:0:talk:0.05:normal:I wouldn't try the door if I were you.
:0:unamused:0.05:normal:Now...
:0:talk:0.05:normal:I have a couple of questions to ask you...
:0:angry:0.1:normal:And you WILL answer them.
```

* The first line will define the characters you will use on the dialogue
  * First value is the character
  * Second value is the character's position ("left", "center" or "right")
  * You separate the characters by adding a space between them
  * It's important that you keep in mind their creation order, as it will be used on the dialogue lines's first value

* Dialogue lines must start with a `:` and every value is separated by another `:`, the values are in the respective order:
  * Character speaking's ID (Based on character creation order)
  * Animation to use during this line
  * Text speed, default is 0.05 (20 characters per second)
  * Speech bubble type ("normal" or "angry")
  * Text. Warning! Don't use this kind of quote: `’`, use this instead: `'`

________________________________________
With that in mind, we can now go to the next step, making your song trigger the dialogue.

**1.** First off, you need to name your dialogue file as your song name + "Dialogue.txt". If my song is called `focus`, the dialogue file then should be named `focusDialogue.txt`.
Place the dialogue file in the same folder as your charts and it should be ready to be loaded.

**2.** Now, open PlayState.hx and go to line 971, you should be seeing this:

![](https://i.imgur.com/udchEJX.png)

Add your song to it and the dialogueIntro function, just like that:

![](https://i.imgur.com/b7NCVrf.png)

If you'd prefer a small delay (in this case, 0.8 seconds) before the dialogue starts, do this:

![](https://i.imgur.com/Hop6fCg.png)

You can also make the dialogue play a background music with it too!
Instead of using `dialogueIntro(dialogue);` you just have to use `dialogueIntro(dialogue, 'your-music-name-here');`, make sure you file is inside the `music` folder of your week's loaded folder!
