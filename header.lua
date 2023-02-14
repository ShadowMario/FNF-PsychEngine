---@diagnostic disable: lowercase-global, missing-return, unused-local
--[[
    A header class which adds basic documentation for all PsychLua functions and variables

    To add to your current working script, use `---@module "header"` into the top of the script, and have this file in the bin/ directory (where the assets or mods folder is found). This will add syntax highlighting, code completion, and much more

    Written and Maintained by saturn-volv (https://github.com/saturn-volv)
]]--

--- Common colors that may be used. Just a helper object.
---@enum common_colors
COMMON_COLORS = {
    BLACK = "000000",
    WHITE = "FFFFFF",
    RED = "FF0000",
    GREEN = "00FF00",
    BLUE = "0000FF",
    YELLOW = "FFFF00",
    CYAN = "00FFFF",
    MAGENTA = "FF00FF"
}
---@enum charType
local CHAR_TYPES = {
    BOYFRIEND = "boyfriend",
    BF = "boyfriend",
    DAD = "dad",
    GIRLFRIEND = "gf",
    GF = "gf"
}
---@enum keylist
local KEY_LIST = {
    A = "A",
    ALT = "ALT",
    B = "B",
    BACKSLASH = "BACKSLASH",
    BACKSPACE = "BACKSPACE",
    BREAK = "BREAK",
    C = "C",
    CAPSLOCK = "CAPSLOCK",
    COMMA = "COMMA",
    CONTROL = "CONTROL",
    D = "D",
    DELETE = "DELETE",
    DOWN = "DOWN",
    E = "E",
    EIGHT = "EIGHT",
    END = "END",
    ENTER = "ENTER",
    ESCAPE = "ESCAPE",
    F = "F",
    F1 = "F1",
    F10 = "F10",
    F11 = "F11",
    F12 = "F12",
    F2 = "F2",
    F3 = "F3",
    F4 = "F4",
    F5 = "F5",
    F6 = "F6",
    F7 = "F7",
    F8 = "F8",
    F9 = "F9",
    FIVE = "FIVE",
    FOUR = "FOUR",
    G = "G",
    GRAVEACCENT = "GRAVEACCENT",
    H = "H",
    HOME = "HOME",
    I = "I",
    INSERT = "INSERT",
    J = "J",
    K = "K",
    L = "L",
    LBRACKET = "LBRACKET",
    LEFT = "LEFT",
    M = "M",
    MENU = "MENU",
    MINUS = "MINUS",
    N = "N",
    NINE = "NINE",
    NUMLOCK = "NUMLOCK",
    NUMPADEIGHT = "NUMPADEIGHT",
    NUMPADFIVE = "NUMPADFIVE",
    NUMPADFOUR = "NUMPADFOUR",
    NUMPADMINUS = "NUMPADMINUS",
    NUMPADMULTIPLY = "NUMPADMULTIPLY",
    NUMPADNINE = "NUMPADNINE",
    NUMPADONE = "NUMPADONE",
    NUMPADPERIOD = "NUMPADPERIOD",
    NUMPADPLUS = "NUMPADPLUS",
    NUMPADSEVEN = "NUMPADSEVEN",
    NUMPADSIX = "NUMPADSIX",
    NUMPADSLASH = "NUMPADSLASH",
    NUMPADTHREE = "NUMPADTHREE",
    NUMPADTWO = "NUMPADTWO",
    NUMPADZERO = "NUMPADZERO",
    O = "O",
    ONE = "ONE",
    P = "P",
    PAGEDOWN = "PAGEDOWN",
    PAGEUP = "PAGEUP",
    PERIOD = "PERIOD",
    PLUS = "PLUS",
    PRINTSCREEN = "PRINTSCREEN",
    Q = "Q",
    QUOTE = "QUOTE",
    R = "R",
    RBRACKET = "RBRACKET",
    RIGHT = "RIGHT",
    S = "S",
    SCROLL_LOCK = "SCROLL_LOCK",
    SEMICOLON = "SEMICOLON",
    SEVEN = "SEVEN",
    SHIFT = "SHIFT",
    SIX = "SIX",
    SLASH = "SLASH",
    SPACE = "SPACE",
    T = "T",
    TAB = "TAB",
    THREE = "THREE",
    TWO = "TWO",
    U = "U",
    UP = "UP",
    V = "V",
    W = "W",
    WINDOWS = "WINDOWS",
    X = "X",
    Y = "Y",
    Z = "Z",
    ZERO = "ZERO"
}
---@enum lower_keylist
local LOWER_KEY_LIST = {
    A = "a",
    ALT = "alt",
    B = "b",
    BACKSLASH = "backslash",
    BACKSPACE = "backspace",
    BREAK = "break",
    C = "c",
    CAPSLOCK = "capslock",
    COMMA = "comma",
    CONTROL = "control",
    D = "d",
    DELETE = "delete",
    DOWN = "down",
    E = "e",
    EIGHT = "eight",
    END = "end",
    ENTER = "enter",
    ESCAPE = "escape",
    F = "f",
    F1 = "f1",
    F10 = "f10",
    F11 = "f11",
    F12 = "f12",
    F2 = "f2",
    F3 = "f3",
    F4 = "f4",
    F5 = "f5",
    F6 = "f6",
    F7 = "f7",
    F8 = "f8",
    F9 = "f9",
    FIVE = "five",
    FOUR = "four",
    G = "g",
    GRAVEACCENT = "graveaccent",
    H = "h",
    HOME = "home",
    I = "i",
    INSERT = "insert",
    J = "j",
    K = "k",
    L = "l",
    LBRACKET = "lbracket",
    LEFT = "left",
    M = "m",
    MENU = "menu",
    MINUS = "minus",
    N = "n",
    NINE = "nine",
    NUMLOCK = "numlock",
    NUMPADEIGHT = "numpadeight",
    NUMPADFIVE = "numpadfive",
    NUMPADFOUR = "numpadfour",
    NUMPADMINUS = "numpadminus",
    NUMPADMULTIPLY = "numpadmultiply",
    NUMPADNINE = "numpadnine",
    NUMPADONE = "numpadone",
    NUMPADPERIOD = "numpadperiod",
    NUMPADPLUS = "numpadplus",
    NUMPADSEVEN = "numpadseven",
    NUMPADSIX = "numpadsix",
    NUMPADSLASH = "numpadslash",
    NUMPADTHREE = "numpadthree",
    NUMPADTWO = "numpadtwo",
    NUMPADZERO = "numpadzero",
    O = "o",
    ONE = "one",
    P = "p",
    PAGEDOWN = "pagedown",
    PAGEUP = "pageup",
    PERIOD = "period",
    PLUS = "plus",
    PRINTSCREEN = "printscreen",
    Q = "q",
    QUOTE = "quote",
    R = "r",
    RBRACKET = "rbracket",
    RIGHT = "right",
    S = "s",
    SCROLL_LOCK = "scroll_lock",
    SEMICOLON = "semicolon",
    SEVEN = "seven",
    SHIFT = "shift",
    SIX = "six",
    SLASH = "slash",
    SPACE = "space",
    T = "t",
    TAB = "tab",
    THREE = "three",
    TWO = "two",
    U = "u",
    UP = "up",
    V = "v",
    W = "w",
    WINDOWS = "windows",
    X = "x",
    Y = "y",
    Z = "z",
    ZERO = "zero"
}
---@enum game_keyList
local GAME_KEY_LIST = {
    left = "left",
    down = "down",
    up = "up",
    right = "right",
    accept = "accept",
    back = "back",
    pause = "pause",
    reset = "reset",
    space = "space"
}
--[[ CALLBACKS ]]--
--[[
    onCreate
    onCreatePost
    onUpdate
    onUpdatePost
    onDestroy
    onBeatHit
    onStepHit
    onSectionHit
    onTweenCompleted
    onTimerCompleted
    onSoundFinished
    onStartCountdown
    onCountdownTick
    onPause
    onResume
    onGameOver
    onGameOverStart
    onGameOverConfirm
    onSpawnNote
    goodNoteHit
    opponentNoteHit
    noteMiss
    noteMissPress
    onGhostTap
    onKeyPressed
    onKeyReleased
    onNextDialogue
    onSkipDialogue
    onEvent
    eventEarlyTrigger
    onSongStart
    onEndSong
    onMoveCamera
    onRecalculateRating
    onUpdateScore
]]--
--[[ VARIABLES ]]--
---Stops the Lua script. Must be returned
---@type any
Function_StopLua = "##PSYCHLUA_FUNCTIONSTOPLUA"
---Stops the game. Must be returned
---@type any
Function_Stop = "##PSYCHLUA_FUNCTIONSTOP"
---Continues the game. Must be returned
---@type any
Function_Continue = "##PSYCHLUA_FUNCTIONCONTINUE"
--- If enabled PsychLua will leave a debug log on screen
---```lua
--- luaDebugMode = true -- Enables debug mode
---```
---@type boolean Defaults to false
luaDebugMode = false
--- If enabled and `luaDebugMode` is enabled, PsychLua will log all instances of deprecated functions being used
---```lua
--- luaDeprecatedWarnings = false -- Disables warnings
---```
---@type boolean Defaults to true
luaDeprecatedWarnings = true
--- If you are in the Chart Editor's playtest state
---@type boolean
inChartEditor = false
--- The current score. Alternative to `getScore()`
---@type number
score = 0
--- The current misses. Alternative to `getMisses()`
---@type number
misses = 0
--- The total notes hit. Alternative to `getHits()`
---@type number
hits = 0
--- The current rating percentage (from 0 to 1)
---@type number
rating = 0
--- The current rating name
---@type string
ratingName = ''
--- The current rating FC
---@type string
ratingFC = ''
--- The current song's scroll speed
---@type number
scrollSpeed = 0.0
--- The current song's duration in ms
---@type number
songLength = 0
--- The current song's directory
---@type string
songPath = ''
--- If the countdown has started
---@type boolean
startedCountdown = false
--- If you are in the `GameOverSubstate`
---@type boolean
inGameOver = false
--- The current song's difficulty
---@type number
difficulty = 0
--- The current song's difficulty name
---@type string
difficultyName = ''
--- The current song's difficulty directory
---@type string
difficultyPath = ''
--- The current week
---@type number
weekRaw = 0
--- The current week's name
---@type string
week = ''
--- If the game was played from `StoryModeState` or `FreeplayState`
---@type boolean
isStoryMode = false
--- The current bpm of the song
---@type number
curBpm = 0
--- The inital bpm of the song
---@type number
bpm = 0
--- Interval between beat hits in ms
---@type number
crochet = 0
--- Interval between step hits in ms
---@type number
stepCrochet = 0
--- The current beat
---@type number
curBeat = 0
--- The current step
---@type number
curStep = 0
--- The current beat with decimal
---@type number
curDecBeat = 0
--- The current step with decimal
---@type number
curDecStep = 0
--- The current section
---@type number
curSection = 0
--- If the camera points to BF
---@type boolean
mustHitSection = false
--- If characters play `-alt` animations
---@type boolean
altAnim = false
--- If `player3` sings instead of whoever the section points to
---@type boolean
gfSection = false
--- If the notes scroll downwards instead of upwards
---@type boolean
downscroll = false
--- If the player's notes are centered rather than on one side
---@type boolean
middlescroll = false
--- "Pretty self explanatory, isn't it?"
---@type number
framerate = 0
--- If you can press note keys without hitting a note and not miss
---@type boolean
ghostTapping = false
--- If the hud is hidden
---@type boolean
hideHud = false
--- @alias timeBarTypes "Time Left" | "Time Elapsed" | "Song Name" | "Disabled"
--- @type timeBarTypes The text displayed over the timebar
timeBarType = "Time Left"
--- If the score text zooms on each note hit
---@type boolean
scoreZoom = false
--- If the camera bops on each song beat
---@type boolean
cameraZoomOnBeat = false
--- If some items which may cause epilepsy, they will be disabled
---@type boolean
flashingLights = false
--- The offset from `songPosition` for notes to be pushed at in ms
---@type number
noteOffset = 0
--- The transparency of the healthBar and it's icons
---@type number
healthBarAlpha = 0
--- If the player can enter `GameOverSubstate` from a keystroke
---@type boolean
noResetButton = false
--- Hides certain items to increase performance
---@type boolean
lowQuality = false
--- If runtime shaders can be enabled.\
--- **MAY DECREASE PERFORMANCE**
---@type boolean
shadersEnabled = false
--- The current camera X position
---@type number
cameraX = 0
--- The current camera Y position
---@type number
cameraY = 0
--- The game width
---@type number
screenWidth = 0
--- The game height
---@type number
screenHeight = 0
--- Multiplier for how much health is gained on a note hit
---@type number
healthGainMult = 0
--- Multiplier for how much health is lossed on a missed note
---@type number
healthLossMult = 0
--- If the player must FC to win
---@type boolean
instakillOnMiss = false
--- If a CPU plays instead of the player
---@type boolean
botPlay = false
--- If the player can't die due to health loss
---@type boolean
practice = false
--- How fast the game plays
---@type number
playbackRate = 0
--- The inital boyfriend X position
---@type number
defaultBoyfriendX = 0
--- The inital boyfriend Y position
---@type number
defaultBoyfriendY = 0
--- The inital opponent X position
---@type number
defaultOpponentX = 0
--- The inital opponent Y position
---@type number
defaultOpponentY = 0
--- The inital girlfriend X position
---@type number
defaultGirlfriendX = 0
--- The initial girlfriend Y position
---@type number
defaultGirlfriendY = 0
--- The name of the `boyfriend` character\
--- Alias to `getProperty('boyfriend.curCharacter')`
---@type string
boyfriendName = ''
--- The name of the `dad` character\
--- Alias to `getProperty('dad.curCharacter')`
---@type string
dadName = ''
--- The name of the `gf` character\
--- Alias to `getProperty('gf.curCharacter')`
---@type string
gfName = ''
--- The inital X position for the Left Player Strum
---@type number
defaultPlayerStrumX0 = 0
--- The inital X position for the Down Player Strum
---@type number
defaultPlayerStrumX1 = 0
--- The inital X position for the Up Player Strum
---@type number
defaultPlayerStrumX2 = 0
--- The inital X position for the Right Player Strum
---@type number
defaultPlayerStrumX3 = 0
--- The inital X position for the Left Player Strum
---@type number
defaultPlayerStrumY0 = 0
--- The inital Y position for the Down Player Strum
---@type number
defaultPlayerStrumY1 = 0
--- The inital Y position for the Up Player Strum
---@type number
defaultPlayerStrumY2 = 0
--- The inital Y position for the Right Player Strum
---@type number
defaultPlayerStrumY3 = 0
--- The inital Y position for the Left Player Strum
---@type number
defaultOpponentStrumX0 = 0
--- The inital X position for the Down Opponent Strum
---@type number
defaultOpponentStrumX1 = 0
--- The inital X position for the Up Opponent Strum
---@type number
defaultOpponentStrumX2 = 0
--- The inital X position for the Right Opponent Strum
---@type number
defaultOpponentStrumX3 = 0
--- The inital Y position for the Left Opponent Strum
---@type number
defaultOpponentStrumY0 = 0
--- The inital Y position for the Down Opponent Strum
---@type number
defaultOpponentStrumY1 = 0
--- The inital Y position for the Up Opponent  Strum
---@type number
defaultOpponentStrumY2 = 0
--- The inital Y position for the Right Opponent Strum
---@type number
defaultOpponentStrumY3 = 0
--- The current version of Psych Engine being used
---@type number
version = 0
---@type "windows" | "linux" | "mac" | "browser" | "android" | "unknown" The current build target.
buildTarget = "windows"
--- The filename for the working script
---@type string
scriptName = ''
--- The foldername for the current working directory
---@type string
currentModDirectory = ''
--- The name of the current stage
---@type string
curStage = ''

--[[ FUNCTIONS ]]--
---Sets the colors for the health bar
---@param left string | common_colors Stick to "0xFFFFFFFF" or "FFFFFF" format
---@param right? string | common_colors Stick to "0xFFFFFFFF" or "FFFFFF" format
function setHealthBarColors(left, right) end
---Sets the colors for the health bar
---@param left string | common_colors Stick to "0xFFFFFFFF" or "FFFFFF" format
---@param right? string | common_colors Stick to "0xFFFFFFFF" or "FFFFFF" format
function setTimeBarColors(left, right) end
---Adds `value` to the player's current score
---@param value number
function addScore(value) end
---Adds `value` to the player's current miss count
---@param value number
function addMisses(value) end
---Adds `value` to the player's current hit count
---@param value number
function addHits(value) end
---@return number score The player's score
function getScore() end
---@return number misses The player's total misses
function getMisses() end
---@return number hits The player's total notes hit
function getHits() end
---Sets the player's score to `value`
---@param value number
function setScore(value) end
---Sets the player's miss count to `value`
---@param value number
function setMisses(value) end
---Sets the player's hit count to `value`
---@param value number
function setHits(value) end
---Sets the player's rating to `value`. Value must be between 0 and 1
---@param value number
function setRatingPercent(value) end
---Sets the player's rating name to `value`
---@param value string
function setRatingName(value) end
---Sets the player's rating FC name to `value`
---@param value string
function setRatingFC(value) end
---Adds `value` to the player's current health
---@param value number
function addHealth(value) end
---@return number health The player's current health
function getHealth() end
---Sets the player's health to `value`
---@param value number
function setHealth(value) end
---@param charType charType
---@return number characterX The current character's X position
function getCharacterX(charType) end
---@param charType charType
---@return number characterX The current character's Y position
function getCharacterY(charType) end
--- Sets the given character's X position
---@param charType charType
---@param x number
function setCharacterX(charType, x) end
--- Sets the given character's Y position
---@param charType charType
---@param y number
function setCharacterY(charType, y) end
--- Plays the given character's `idle` or `dance` animation
---@param charType charType
function characterDance(charType) end
---Alias for `Conductor.songPosition` 
---@return number songPos The current song time passed in ms
function getSongPosition() end
---If the countdown hasn't started already, will trigger the countdown event
function startCountdown() end
---Ends the song, saving the current score
function endSong() end
---Restarts the current song
---@param skipTrans? boolean skips the transition, defaults to false
function restartSong(skipTrans) end
---Exists the current song, without saving the current score
---@param skipTrans? boolean skips the transition, defaults to false
function exitSong(skipTrans) end
---Runs the given event without the need for charting it
---@param eventName string
---@param value1? string | number | boolean
---@param value2? string | number | boolean
function triggerEvent(eventName, value1, value2) end
---Returns a random integer between `min` and `max`. Will **not** return any numbers in the `exclude` array
---@param min number
---@param max number
---@param exclude? string Optional array of values to ignore. Numbers must be seperated by a comma: `"1, 2, 3, 4, 5, 6, 7"`
---@return number integer
function getRandomInt(min, max, exclude) end
---Returns a random integer float `min` and `max`. Will **not** return any numbers in the `exclude` array
---@param min number
---@param max number
---@param exclude? string Optional array of values to ignore. Numbers must be seperated by a comma: `"1, 2, 3, 4, 5, 6, 7"`
---@return number float
function getRandomFloat(min, max, exclude) end
---Returns `true` or `false` based on `chance`.
---@param chance number if `number >= 100`, it returns true always
---@return boolean
function getRandomBool(chance) end
---Starts a dialogue cutscene.
---@param dialogueFile string The cutscenes `JSON` file directory. Root starts in the song's `data/<song>/` folder
---@param music string Directory of the music file to use. Root starts from `music/`
function startDialogue(dialogueFile, music) end
---Starts a video cutscene
---@param videoFile string Directory of the video file to use. Root starts from `videos/`
function startVideo(videoFile) end
---Points the camera towards the given target
---@param target "dad" | "boyfriend"
function cameraSetTarget(target) end
---@alias cameras "game" | "hud" | "other" | "camGame" | "camHUD" | "camOther"
---Shakes the camera.
---@param camera cameras The `FlxCamera` to shake
---@param intensity number The intensity of the shake. Anything over 0.05 may be excessive
---@param duration number The duration of the shake
function cameraShake(camera, intensity, duration) end
---FLashes the camera with `color`
---@param camera cameras The `FlxCamera` to flash
---@param color string | common_colors The color to flash the camera with
---@param duration number The duration in seconds
---@param forced boolean Restarts the flash if the camera is already flashed
function cameraFlash(camera, color, duration, forced) end
---Fades the camera to `color`
---@param camera cameras The `FlxCamera` to fade
---@param color string | common_colors The color to fade the camera to
---@param duration number The duration in seconds
---@param forced boolean Restarts the fade if the camera is already fading
function cameraFade(camera, color, duration, forced) end
---Gets a global variable from another Lua file
---@param luaFile string The path to the lua file
---@param global string The variable to get
---@return any value
function getGlobalFromScript(luaFile, global) end
---Sets a global variable from another Lua file to `value`
---@param luaFile string The path to the lua file
---@param global string The variable to set
---@param value any What to set `global` to
function setGlobalFromScript(luaFile, global, value) end
---Gets a variable from source code using `Reflect`. Will cause a break at the current line if the variable can't be found
---@param property string Path to the variable. Local to `PlayState.instance`
---@return any value
function getProperty(property) end
---Sets a variable from source code using `Reflect`. Will cause a break at the current line if the variable can't be found
---@param property string Path to the variable. Local to `PlayState.instance`
---@param value any 
function setProperty(property, value) end
---Gets a variable from source code using `Reflect`. Will cause a break at the current line if the variable can't be found
---@param classPath string Path to the class
---@param property string Path to the variable. Local to `classPath`
---@return any value
function getPropertyFromClass(classPath, property) end
---Gets a variable from source code using `Reflect`. Will cause a break at the current line if the variable can't be found
---@param classPath string Path to the class
---@param property string Path to the variable. Local to `classPath`
---@param value any
function setPropertyFromClass(classPath, property, value) end
---Gets a variable from source code using `Reflect`. Will cause a break at the current line if the variable can't be found
---@param group string Group name. Local to `PlayState.instance`
---@param index number Index of `group` to get from
---@param property string Path to the variable. Local to `group[index]`
---@return any value 
function getPropertyFromGroup(group, index, property) end
---Gets a variable from source code using `Reflect`. Will cause a break at the current line if the variable can't be found
---@param group string Group name. Local to `PlayState.instance`
---@param index number Index of `group` to set from
---@param property string Path to the variable. Local to `group[index]`
---@param value any
function setPropertyFromGroup(group, index, property, value) end
---@param script string The Haxe code to run
---Runs the given Haxe code in `script` as long as all of it is valid. Any errors will cause the code to not run, `null` values and other runtime errors cause a break at the current line
---You can get variables/functions from other classes but natively limited to what is already imported. To add more libraries to your current `Expr` use `addHaxeLibrary`\
--- Already imported libraries:
---```haxe
--- flixel.FlxG;
--- flixel.FlxSprite;
--- flixel.camera.FlxCamera;
--- flixel.util.FlxTimer;
--- flixel.tweens.FlxTween;
--- PlayState; // as "PlayState" or "game"
--- Paths;
--- Conductor;
--- ClientPrefs;
--- Character;
--- Alphabet;
--- CustomSubstate;
--- flixel.addons.display.FlxRuntimeShader;
--- openfl.filters.ShaderFilter;
--- StringTools;
---```
---Types are non-strict and are not required for variable declaration
function runHaxeCode(script) end
---Adds support for calling a specific Library Package from any source implemented haxelibs or native Haxe libraries
---@param class string The class name, such as `FlxMath`
---@param package? string The path to the class name, such as `flixel.math`
function addHaxeLibrary(class, package) end
---Returns if the key `name` was just pressed on the current frame
---@param name keylist | lower_keylist
---@return boolean
function keyboardJustPressed(name) end
---Returns if the key `name` is pressed on the current frame
---@param name keylist | lower_keylist
---@return boolean
function keyboardPressed(name) end
---Returns if the key `name` was just released on the current frame
---@param name keylist | lower_keylist
---@return boolean
function keyboardReleased(name) end
---Returns if the key `name` was just pressed on the current frame
---@param name game_keyList
---@return boolean
function keyJustPressed(name) end
---Returns if the key `name` is pressed on the current frame
---@param name game_keyList
---@return boolean
function keyPressed(name) end
---Returns if the key `name` was just released on the current frame
---@param name game_keyList
---@return boolean
function keyReleased(name) end
---@alias mouse_button "left" | "middle" | "right"
---Returns if the mouse button `button` was just clicked on the current frame
---@param button mouse_button
---@return boolean
function mouseClicked(button) end
---Returns if the mouse button `button` is down on the current frame
---@param button mouse_button
---@return boolean
function mousePressed(button) end
---Returns if the mouse button `button` was just released on the current frame
---@param button mouse_button
---@return boolean
function mouseReleased(button) end
---Returns the current mouse X position relative to `camera`
---@param camera cameras
---@return number x
function getMouseX(camera) end
---Returns the current mouse Y position relative to `camera`
---@param camera cameras
---@return number y
function getMouseY(camera) end
---Precaches the given character for a `Change Character` event
---@param name string Name of the character
---@param type charType Which character to cache for
function addCharacterToList(name, type) end
---Precaches an image from `path`
---@param path string The path to the image to cache
function precacheImage(path) end
---Precaches a sound from `path`
---@param path string The path to the sound to cache
function precacheSound(path) end
---Precaches music from `path`
---@param path string The path to the music to cache
function precacheMusic(path) end
---Initializes the save data `name`, in the path `folder`. Directory root is the bin folder.
---@param name string The save data filename
---@param folder string directory to save to
function initSaveData(name, folder) end
---Returns a value from a save created with `initSaveData`
---@generic T
---@param name string Save data name
---@param field string The value to get from
---@param defaultValue `T` If it's `nil`, return this instead
---@return T
function getDataFromSave(name, field, defaultValue) end
---Sets a value to a save created with `initSaveData`
---@param name string Save data name
---@param field string The value to set
---@param value any What `field` is set to
function setDataFromSave(name, field, value) end
---Flushes the save `name`
---@param name string
function flushSaveData(name) end
---Creates a file at the path `path`. Directory root is the bin folder
---@param path string The path to save to
---@param content string The content to save
---@param absolute? boolean Start from root folder rather than `root/mods/`
function saveFile(path, content, absolute) end
---Deletes a file at path `path`. Directory root is the bin folder
---@param path string The path to save to
---@param absolute? boolean Start from root folder rather than `root/mods/`
function deleteFile(path, absolute) end
---Returns the contents of the file at `path`. Directory root is the bin folder
---@param path string The path to get from
---@param absolute? boolean Start from root folder rather than `root/mods/`
---@return string content
function getTextFromFile(path, absolute) end
---Returns if the file at `path` is found. Directory root is the bin folder
---@param path string The path to check
---@param absolute boolean Start from root folder rather than `root/mods/`
---@return boolean
function checkFileExists(path, absolute) end
---Returns the name and type of all the files in `path`. Directory root is the bin folder
---@param path string The path to check. Starts from `root/` **not** `root/mods/`
function directoryFileList(path) end
---Adds a lua script to the stack
---@param path string The lua file's directory
---@param showWarnings? boolean If the game should print warnings that the script is already running
function addLuaScript(path, showWarnings) end
---Removes a lua script from the stack
---@param path string The lua file's directory
---@param showWarnings? boolean If the game should print warnings that the script is already running
function removeLuaScript(path, showWarnings) end
---Returns a list of all the currently active scripts
---@return string[] scripts
function getRunningScripts() end
---Returns that the script `path` is in the stack
---@param path string The Lua file's directory
---@return boolean
function isRunning(path) end
---Prints the list of text given to `PlayState.camOther`
---@param ... string
function debugPrint(...) end
---Closes `this` script
function close() end
---Initializes the shader `name`
---@param name string The name of the shader frag file in `<currentModDir>/shaders/`
---@param glslVersion? number The GLSL version of the shader
function initLuaShader(name, glslVersion) end
---Applies a shader to a sprite
---@param tag string Sprite's object path
---@param shader string The shader to apply. **[Must be initialized with`initLuaShader`]**
function setSpriteShader(tag, shader) end
---Removes the shader from a sprite
---@param tag string Sprite's object path
function removeSpriteShader(tag) end
---Returns a `bool` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to return
---@return boolean
function getShaderBool(tag, property) end
---Returns a `bool[]` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to return
---@return boolean[]
function getShaderBoolArray(tag, property) end
---Returns a `int` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to return
---@return number
function getShaderInt(tag, property) end
---Returns a `int[]` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to return
---@return number[]
function getShaderIntArray(tag, property) end
---Returns a `float` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to return
---@return number
function getShaderFloat(tag, property) end
---Returns a `float[]` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to return
---@return number[]
function getShaderFloatArray(tag, property) end
---Set's a `bool` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param value boolean What to set `property` to.
function setShaderBool(tag, property, value) end
---Set's a `bool[]` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param value boolean[] What to set `property` to.
function setShaderBoolArray(tag, property, value) end
---Set's a `int` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param value number What to set `property` to.
function setShaderInt(tag, property, value) end
---Set's a `int[]` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param value number[] What to set `property` to.
function setShaderIntArray(tag, property, value) end
---Set's a `float` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param value number What to set `property` to.
function setShaderFloat(tag, property, value) end
---Set's a `float[]` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param value number[] What to set `property` to.
function setShaderFloatArray(tag, property, value) end
---Set's a `sampler2D` parameter of an object's shader
---@param tag string Sprite's object path
---@param property string The name of the parameter to change
---@param path string Path to the bitmapData used.
function setShaderSampler2D(tag, property, path) end
---Plays a sound file
---@param sound string "`<mods|assets>/sounds/<sound>`" Must be a .OGG file. Once the sound is completed, does a callback for `onSoundFinished()`
---@param volume? number Sound volume. From 0 to 1, where 1 is default
---@param tag? string Sound's string tag. Is optional but is required for all sound related functions
function playSound(sound, volume, tag) end
---Plays a music file
---@param music string "`<mods|assets>/music/<music>`" Must be a .OGG file. Once the sound is completed, does a callback for `onSoundFinished()`
---@param volume? number Sound volume. From 0 to 1, where 1 is default
---@param loop? boolean If the music should loop
function playMusic(music, volume, loop) end
---Pauses a sound
---@param tag string Sound tag name
function pauseSound(tag) end
---Resumes a sound
---@param tag string Sound tag name
function resumeSound(tag) end
---Stops a sound
---@param tag string Sound tag name
function stopSound(tag) end
---Fades a sound in
---@param tag string Sound tag name
---@param duration number Duration for the sound to fully fade in
---@param from? number Initial volume to fade from
---@param to? number Final volume to fade to
function soundFadeIn(tag, duration, from, to) end
---Fades a sound out
---@param tag string Sound tag name
---@param duration number Duration for the sound to fully fade out
---@param to? number Final volume to fade to
function soundFadeOut(tag, duration, to) end
---Cancels a current sound fade
---@param tag string Sound tag name
function soundFadeCancel(tag) end
---Returns the current volume of sound `tag`
---@param tag string Sound tag name
---@return number volume
function getSoundVolume(tag) end
---Returns the current timestamp of the sound `tag`
---@param tag string Sound tag name
---@return number timestamp_ms
function getSoundTime(tag) end
---Sets the volume of sound `tag` to `value`
---@param tag string Sound tag name
---@param value number Volume to set the sound to
function setSoundVolume(tag, value) end
---Sets the timestamp of sound `tag` to `value`
---@param tag string Sound tag name
---@param value number Timestamp to set the sound to in ms
function setSoundTime(tag, value) end
---Returns if the sound `tag` exists
---@param tag string Sound tag name
function luaSoundExists(tag) end
---Makes a static `ModchartSprite` with the tag `tag`, at x and y `x` and `y`
---@param tag string Sprite tag name. Used in other Lua Sprite functions, like `scaleObject`
---@param path string Path to the image to load with the sprite. Leave blank to use `makeGraphic` instead
---@param x number
---@param y number
function makeLuaSprite(tag, path, x, y) end
---@alias spriteType string | "tex" | "texture" | "textureatlas" | "texture_noaa" | "textureatlass_noaa" | "tex_noaa" | "packer" | "packeratlas" | "pac"
---Makes an animated `ModchartSprite` with the tag `tag`, at x and y `x` and `y`
---@param tag string Sprite tag name. Used in other Lua Sprite functions, like `scaleObject`
---@param path string Path to the `spriteType` animation handler
---@param x number
---@param y number
---@param spriteType? spriteType The animation atlas to generate the sprite with. Defaults to "sparrow"
function makeAnimatedLuaSprite(tag, path, x, y, spriteType) end
---Adds the `ModchartSprite` `tag` to `PlayState`
---@param tag string Sprite tag name
---@param inFront? boolean If the sprite should be placed infront of the characters
function addLuaSprite(tag, inFront) end
---Removes the `ModchartSprite` `tag` from `PlayState`
---@param tag string Sprite tag name
---@param destroy? boolean If false, the sprite does not need to be remade to be added again
function removeLuaSprite(tag, destroy) end
---Adds an animation to the Modchart Sprite or Object `tag` via XML prefixes.
---@param tag string Sprite object path
---@param name string Animation name
---@param prefix string XML animation name
---@param framerate? number Frames to play per second. Defaults to 24fps
---@param loop? boolean Restarts the animation on `finishCallback`. Defaults to `true`
function addAnimationByPrefix(tag, name, prefix, framerate, loop) end
---Adds an animation to the Modchart Sprite or Object `tag` via individual XML frames
---@param tag string Sprite object path
---@param name string Animation name
---@param prefix string XML animation name
---@param indicies string What frames to use, must be seperated by a comma: `"0, 1, 2, 3, 4, 5"`
---@param framerate? number Frames to play per second. Defaults to 24fps
function addAnimationByIndicies(tag, name, prefix, indicies, framerate) end
---Adds a looping animation to the Modchart Sprite or Object `tag` via individual XML frames
---@param tag string Sprite object path
---@param name string Animation name
---@param prefix string XML animation name
---@param indicies string What frames to use, must be seperated by a comma: `"0, 1, 2, 3, 4, 5"`
---@param framerate? number Frames to play per second. Defaults to 24fps
function addAnimationByIndiciesLoop(tag, name, prefix, indicies, framerate) end
---Adds an animation to Modchart Sprite or Object `tag`
---@param tag string Sprite object path
---@param name string Animation name
---@param frames number[] Frames to load
---@param framerate? number Frames to play per second. Defaults to 24fps
---@param loop? boolean Restarts the animation on `finishCallback`. Defaults to `true`
function addAnimation(tag, name, frames, framerate, loop) end
---Make a rectangle with the tag `tag`
---@param tag string Sprite tag name
---@param width number
---@param height number
---@param color string | common_colors Color the rectangle fills with
function makeGraphic(tag, width, height, color) end
---Sets the graphic `tag`'s size
---@param tag string Sprite tag name
---@param x number
---@param y number
---@param updateHitbox? boolean Automatically updates hitbox, elmininating the need to call `updateHitbox(tag)`. Defaults to `true`
function setGraphicSize(tag, x, y, updateHitbox) end
---Loads a graphic image to `tag`
---@param tag string Sprite tag name
---@param path string Path to image. Image must be in either `<currentModDirectory>/images` or `assets/images`
---@param width number
---@param height number
function loadGraphic(tag, path, width, height) end
---Moves a Sprite's drawn layer to `camera`
---@param tag string Sprite tag name
---@param camera cameras Camera name
function setObjectCamera(tag, camera) end
---@alias blend_modes "ADD" | "ALPHA" | "DARKEN" | "DIFFERENCE" | "ERASE" | "HARDLIGHT" | "INVERT" | "LAYER" | "LIGHTEN" | "MULTIPLY" | "NORMAL" | "OVERLAY" | "SCREEN" | "SHADER" | "SUBTRACT"
---Sets a Sprite's blend mode
---@param tag string Sprite tag name
---@param blend blend_modes The blend mode
function setBlendMode(tag, blend) end
---Sets the scrolling factor for Sprite `tag` as the camera moves
---@param tag string Sprite tag name
---@param x number Horizontal scroll multiplier
---@param y number Vertical scroll multiplier
function setScrollFactor(tag, x, y) end
---Sets the object `tag`'s scale
---@param tag string Sprite tag name
---@param x number
---@param y number
---@param updateHitbox? boolean Automatically updates hitbox, elmininating the need to call `updateHitbox(tag)`. Defaults to `true`
function scaleObject(tag, x, y, updateHitbox) end
---Updates an objects hitbox
---@param tag string Sprite tag name
function updateHitbox(tag) end
---Updates a sprite's hitbox from `group` at index `index`
---@param group string Group name, relative to `PlayState.instance`
---@param index number Index of `group` to get from
function updateHitboxFromGroup(group, index) end
---Plays an objects animation
---@param tag string Sprite object path
---@param name string Animation name
---@param forced? boolean If the animation is already playing, it will restart. Defaults to `false`
---@param reverse? boolean Play the animation in reverse. Defaults to `false`
---@param startIndex? number Starting frame index of the animation. Defaults to `0`
function playAnim(tag, name, forced, reverse, startIndex) end
---Adds an offset for sprites with the animation `name` is played with `playAnim`
---@param tag string Sprite object path
---@param name string Animation name
---@param x number Offset X. From BOTTOM_RIGHT
---@param y number Offset Y. From BOTTOM_RIGHT
function addOffset(tag, name, x, y) end
---Returns an object's position in `PlayState.instance`
---@param obj string Object path
---@return number index
function getObjectOrder(obj) end
---Sets an object's position in `PlayState.instance`
---@param obj string Object path
---@param index number New index for object `obj`
function setObjectOrder(obj, index) end
---Removes an object from it's current group
---@param obj string Group object path
---@param index number Index of `obj`
---@param dontDestroy? boolean Object remains in memory. Default is `false`
function removeFromGroup(obj, index, dontDestroy) end
---Loads frames from an image. Used for Texture Atlas support
---@param tag string Sprite tag name
---@param image string Path to the `spriteType` Atlas
---@param spriteType? spriteType Object's animation renderer. Default is `"sprarrow"`
function loadFrames(tag, image, spriteType) end
---Returns if `obj1` is overlapping `obj2`. Used for things in collision detection
---@param obj1 any
---@param obj2 any
---@return boolean
function objectsOverlap(obj1, obj2) end
---Centers an object to the axis `pos`
---@param tag string Sprite tag name
---@param pos? "X" | "Y" | "XY" Axis alignment for the sprite. Default value is `"XY"`
function screenCenter(tag, pos) end
---Returns if the `ModchartSprite` `tag` exists
---@param tag string Sprite tage name
---@return boolean
function luaSpriteExists(tag) end
---Creates a Substate with the tag `name`
---@param name string Substate name. Used in substate callbacks
---@param pauseGame? boolean Will pause the game if opened. Defaults to `false`
---All Custom Substate Callbacks:
---```lua
--- -- Called when a custom substate has been created.
---onCustomSubstateCreate(name)
--- -- Called when a custom substate has finished loading.
---onCustomSubstateCreatePost(name)
--- -- Called every frame a custom substate is open.
--- onCustomSubstateUpdate(name, elapsed)
--- -- Called after every frame a custom substate is open.
---onCustomSubstateUpdatePost(name, elapsed)
--- -- Called when a custom substate has been closed.
---onCustomSubstateDestroy(name)
---```
function openCustomSubstate(name, pauseGame) end
---Closes the currently opened substate
function closeSubstate() end
---Makes a new instance of `ModchartText`
---@param tag string Text object name
---@param text string The content of this text object
---@param width number The width of the text field. Enables `autoSize` if `<= 0`. (`height` is determined automatically)
---@param x number
---@param y number
function makeLuaText(tag, text, width, x, y) end
---Adds the `ModchartText` to this `PlayState` instance
---@param tag string Text object name
function addLuaText(tag) end
---Removes the `ModchartText` from `PlayState`
---@param tag string Text object name
---@param destroy? boolean If false, will not need to remade to be added again. Defaults to `true`
function removeLuaText(tag, destroy) end
---Returns the `text` field of the ModchartText `tag`
---@param tag string Text object name
---@return string text
function getTextString(tag) end
---Returns the `size` of the ModchartText `tag`
---@param tag string Text object name
---@return number size
function getTextSize(tag) end
---Returns the font name of the ModchartText `tag`
---@param tag string Text object name
---@return string fontName
function getTextFont(tag) end
---Returns the `width` of the ModchartText `tag`
---@param tag string Text object name
---@return number width
function getTextWidth(tag) end
---Sets the `text` field of the ModchartText `tag`
---@param tag string Text object name
---@param text string New text field content
function setTextString(tag, text) end
---Sets the `size` field of the ModchartText `tag`
---@param tag string Text object name
---@param size number New text field size
function setTextSize(tag, size) end
---Sets the `width` field of the ModchartText `tag`
---@param tag string Text object name
---@param width number New text field width
function setTextWidth(tag, width) end
---Sets the `color` field of the ModchartText `tag`
---@param tag string Text object name
---@param color string | common_colors New text field color
function setTextColor(tag, color) end
---Sets the border of the ModchartText `tag`
---@param tag string Text object name
---@param size number New border size
---@param color string | common_colors New border color
function setTextBorder(tag, size, color) end
---Sets the `italic` field of the ModchartText `tag`
---@param tag string Text object name
---@param italic boolean Italicise the text field
function setTextItalic(tag, italic) end
---Sets the alignment of the ModchartText `tag`
---@param tag string Text object name
---@param alignment number New text field alignment
function setTextAlignment(tag, alignment) end
---Returns if the ModchartText `tag` exists
---@param tag string Text object Name
---@return boolean
function luaTextExists(tag) end -- Just the tweens to go :D
---@alias ease 'backin' | 'backinout' | 'backout' | 'bouncein' | 'bounceinout' | 'bounceot' | 'circin' | 'circinout' | 'circout' | 'cubein' | 'cubeinout' | 'cubeout' | 'elasticin' | 'elasticinout' | 'elasticout' | 'expoin' | 'expoinout' | 'expoout' | 'quadin' | 'quadinout' | 'quadout' | 'quartin' | 'quartinout' | 'quartout' | 'quintin' | 'quintinout' | 'quintout' | 'sinein' | 'sineinout' | 'sineout' | 'smoothstepin' | 'smoothstepinout' | 'smoothstepout' | 'smootherstepin' | 'smootherstepinout' | 'smootherstepout' | 'linear'
---Runs a `FlxTween` on the `grpStrumlineNotes.members[note]` X position. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param note number index of `grpStrumlineNotes.members`
---@param value number The new X value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function noteTweenX(tag, note, value, duration, ease) end
---Runs a `FlxTween` on the `grpStrumlineNotes.members[note]` Y position. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param note number index of `grpStrumlineNotes.members`
---@param value number The new Y value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function noteTweenY(tag, note, value, duration, ease) end
---Runs a `FlxTween` on the `grpStrumlineNotes.members[note]` Angle. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param note number index of `grpStrumlineNotes.members`
---@param value number The new Angle value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function noteTweenAngle(tag, note, value, duration, ease) end
---Runs a `FlxTween` on the `grpStrumlineNotes.members[note]` Alpha. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param note number index of `grpStrumlineNotes.members`
---@param value number The new Alpha value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function noteTweenAlpha(tag, note, value, duration, ease) end
---Runs a `FlxTween` on the `grpStrumlineNotes.members[note]` Direction. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param note number index of `grpStrumlineNotes.members`
---@param value number The new Direction value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function noteTweenDirection(tag, note, value, duration, ease) end
---Runs a `FlxTween` on the `object`'s' X position. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param obj number The object to tween
---@param value number The new X value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function doTweenX(tag, obj, value, duration, ease) end
---Runs a `FlxTween` on the `object`'s' Y position. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param obj number The object to tween
---@param value number The new Y value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function doTweenY(tag, obj, value, duration, ease) end
---Runs a `FlxTween` on the `object`'s' Angle. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param obj number The object to tween
---@param value number The new Angle value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function doTweenAngle(tag, obj, value, duration, ease) end
---Runs a `FlxTween` on the `object`'s' Alpha. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param obj number The object to tween
---@param value number The new Alpha value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function doTweenAlpha(tag, obj, value, duration, ease) end
---Runs a `FlxTween` on the `camera`'s' Zoom. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param camera number The camera to tween
---@param value number The new Zoom value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function doTweenZoom(tag, camera, value, duration, ease) end
---Runs a `FlxTween` on the `object`'s' Color. Once finished, a `onTweenCompleted` callback will be pushed
---@param tag string Tween tag name, for `onTweenCompleted` callback
---@param obj number The object to tween
---@param value number The new Color value
---@param duration number The time it takes for the Tween to take place. In seconds
---@param ease? ease The tweening method used. Default is `'linear'`
function doTweenColor(tag, obj, value, duration, ease) end
---Cancels the `FlxTween` with the tag `tag`
---@param tag string Tween tag name
function cancelTween(tag) end
---Runs a timer with the tag `tag`. Once the timer is completed it will call `onTimerCompleted`
---@param tag string Timer tag name
---@param time? number Duration in seconds. Defaults to 1
---@param loops? number How many times to loop the timer. Defaults to 1
function runTimer(tag, time, loops) end
---Cancels the Timer with the tag `tag`
---@param tag string Timer tag name
function cancelTimer(tag) end
---Returns if `string` starts with `prefix`
---@param string string
---@param prefix string
---@return boolean
function stringStartsWith(string, prefix) end
---Returns if `string` ends with `suffix`
---@param string string
---@param suffix string
---@return boolean
function stringEndsWith(string, suffix) end
---Returns a table of `string` split at each occurance of `delimeter`
---@param string string
---@param delimeter string
---@return string[]
function stringSplit(string, delimeter) end
---Returns a string of `string` with leading and trailing space characters
---@param string string
function stringTrim(string) end

--[[ DEPRECATED STUFF ]]--
---@deprecated
---Plays an object's animation\
---*Deprecated: Use `playAnin`*
---@param obj string The object name or 'tag'
---@param name string The name of the animation to play
---@param forced boolean Restart the animation if it's currently playing
---@param startFrame? number The index of the animation to play from
function objectPlayAnimation(obj, name, forced, startFrame) end
---@deprecated
---Plays a character's animation\
---*Deprecated: Use `playAnim` *
---@param character string | '"dad"' | '"gf"' | '"girlfriend"' The character name, defaults to "boyfriend"
---@param anim any The name of the animation to play
---@param forced any Restart the animation if it's currently playing
function characterPlayAnim(character, anim, forced) end

---@deprecated
---Alias to [FlxSprite.loadGraphic](https://api.haxeflixel.com/flixel/FlxSprite.html#loadGraphic)\
---*Deprecated: Use `makeGraphic`*
---@param tag string Object to draw the graphic onto
---@param width number Width of the graphic
---@param height number Height of the graphic
---@param color string Hexadecimal color in `0xFFFFFFFF` or `FFFFFF` format
function luaSpriteMakeGraphic(tag, width, height, color) end

---@deprecated
---Alias to [FlxAnimationController.addByPrefix](https://api.haxeflixel.com/flixel/animation/FlxAnimationController.html#addByPrefix)\
---*Deprecated: Use `addAnimationByPrefix`*
---@param tag string Object to add the animation to
---@param name string Name of the animation
---@param prefix string Animation prefix from the XML
---@param framerate number The frames played per second
---@param loop boolean Whether the animation plays once or loops
function luaSpriteAddAnimationByPrefix(tag, name, prefix, framerate, loop) end

---@deprecated  
---Alias to [FlxAnimationController.addByPrefix](https://api.haxeflixel.com/flixel/animation/FlxAnimationController.html#addByPrefix)\
---*Deprecated: Use `addAnimationByIndicies`*
---@param tag string Object to add the animation to
---@param name string Name of the animation
---@param prefix string Animation prefix from the XML
---@param indicies string Whether the animation plays once or loops
---@param framerate number The frames played per second
function luaSpriteAddAnimationByIndicies(tag, name, prefix, indicies, framerate) end

---@deprecated
---Plays a sprite's animation\
---*Deprecated: Use `playAnim`*
---@param tag string The tag of the sprite
---@param name string The name of the animation to play
---@param forced boolean Restart the animation if it's currently playing
function luaSpritePlayAnimation(tag, name, forced) end

---@deprecated
---Changes a sprites drawn camera\
---*Deprecated: Use `setObjectCamera`*
---@param tag string The tag of the sprite
---@param camera string The name of the camera variable in `PlayState`
function setLuaSpriteCamera(tag, camera) end

---@deprecated
---Sets a sprite's `scrollFactor`\
---*Deprecated: Use `setScrollFactor`*
---@param tag string The tag of the sprite
---@param x number Horizintal scroll multiplier
---@param y number Vertical scroll multiplier
function setLuaSpriteScrollFactor(tag, x, y) end

---@deprecated
---Scales a sprite\
---*Deprecated: Use `scaleObject`*
---@param tag string The tage of the sprite
---@param x number
---@param y number
function scaleLuaSprite(tag, x, y) end

---@deprecated
---Gets the value `property` from a sprite\
---*Deprecated: Use `getProperty`*
---@param tag string The tag of the sprite
---@param property string The property to get
---@return any
function getPropertyLuaSprite(tag, property) end

---@deprecated
---Sets the value `property` from a sprite\
---*Deprecated: Use `setProperty`*
---@param tag string The tag of the sprite
---@param property string The property to set
---@param value any The value to set `property` to
function setPropertyLuaSprite(tag, property, value) end

---@deprecated
---Fades in `FlxG.sound.music`\
---*Deprecated: Use `soundFadeIn`*
---@param duration number Time in seconds
---@param from number Initial volume
---@param to number Final volume
function musicFadeIn(duration, from, to) end

---@deprecated
---Fades out `FlxG.sound.music`\
---*Deprecated: Use `soundFadeOut`*
---@param duration number Time in seconds
---@param to number Final volume
function musicFadeOut(duration, to) end