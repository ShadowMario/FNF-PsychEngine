*On this Example, i will be adding a week with Two songs: "Test", and "Smash". It will be Week 69420, will be named "Test Testicle" and will use an assets folder called "testicle" inside assets/*

:moyai: **PART 1 - Adding it to the list** :moyai:

**1.** Open WeekData.hx inside `source/` folder

**2.** Most of the stuff you will need to fill is explained in WeekData file, but i will try to summarize it here.

**3.** To add your songs to your Week, You have to edit the songsNames array, this is how it should look like once you're done:

![](https://i.imgur.com/RAWANw7.png)

**4.** I want my week to be numbered as Week 69420 instead of "Week 7", change weekNumber array.

![](https://i.imgur.com/LCAWebQ.png)

**5.** I want my week to load a specific folder for it, in this case it will load the "testicle" folder, check out the end of this tutorial for understanding how to make the new folder get compiled properly, if you don't know how to do it.

![](https://i.imgur.com/H9PhI0s.png)

It's done! Your new week should be in... but not fully configured, of course. 😔


____________________________________________________
😳 **PART 2 - Week BG/Characters/Name** 😳

**1.** Open StoryMenuState.hx

**2.** Add a new value to weekUnlocked array, wether you want your new week in your mod to come in already unlocked is up to you, just set it to `true` or `false` based on your preferences.

**3.** For changing the characters displayed, change the weekCharacters array. the order of characters is the following:
First - Left character (Usually the Opponent)
Second - Middle character (Usually Boyfriend)
Third - Right character (Usually Girlfriend)

![](https://i.imgur.com/KykubIJ.png)

The character images are stored on assets/preload/menucharacters/
If you want to make a new Menu Character(s), add them to MenuCharacter.hx

**4.** Now for the background to your Week, add your prefered file to the weekBackgrounds array. I will be using 'stage', which will be loading the file called "menu_stage.png".

![](https://i.imgur.com/qTuGBWQ.png)

The background images are stored on assets/preload/menubackgrounds/, the file name must start with "menu_"

**5.** And lastly for the Story Mode menu, you just need to name your Week for the top-right corner display name. I will be naming my week "Test Testicle" because i can.

![](https://i.imgur.com/kykW4vL.png)


If you're copying my steps, this is how it should be looking like:
![](https://cdn.discordapp.com/attachments/840678333602857040/870168312703746088/Screenshot_5.png)


____________________________________________________
🙃 **PART 3 - Freeplay Heads/BG Color** 🙃

By default, your songs will be using BF's head icon and Week 1/Tutorial BG color.

![](https://i.imgur.com/hRCL4Wl.png)

Here's how to change it:

**1.** Open FreeplayState.hx

**2.** Near the start of the file you will see an array called songsHeads, this is how you change the head icons.
And this is how the array works:
* If you want all the songs to use Tankman's head icon, just do `['tankman']`
* If you want your songs to use different head icons, you have to define every icon individually, i will be using BF-Pixel's head icon for Test and Dad's icon for Smash, so i must do this: `['bf-pixel', 'dad']`

![](https://i.imgur.com/ISwORpR.png)

**3.** And finally, changing the background color. I will be using Color hex #E0E000 (Yellow)
Open the text file `assets/preload/data/freeplayColors.txt`, then add a new line. Add you hex color there, **BUT**, add a `0xFF` before it, it should now be looking like `0xFFE0E000`

If you've set up everything correctly, this is how it should look like:

![](https://i.imgur.com/UhBMZvA.png)


____________________________________________________

🤨 **EXTRA - Making a new folder being compiled** 🤨

This can be skipped if you already know about it.

**1.** Open Project.xml

**2.** The easiest and fastest way to add your folder there, is to copy all mentions of `week6` and `week6_high` and name it to whatever your folder will be named (In my case, `testicle`).

![](https://i.imgur.com/3nxa1FW.png)
