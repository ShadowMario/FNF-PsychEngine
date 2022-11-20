curentVersion = 0;

local Quotes = {
    "It's AumSum Time!",
    "What if HScript Disappared?",
    "No AumSum?",
    "Thanks to Heli Pro Gamer for the fix!",
    "hi my name is carmen winstead im 17 years old",
    "No OpenFL?",
    "MOM GET THE CAMERA",
    "YouTube is gonna copyright strike you if you die!",
    "DONT PUT AUMSUM IN DALL E WORST MISTAKE OF MY LIFE",
    "oh noes arnold got his finger cut",
    "what a loser, getting his mod cancelled",
    "This is YOUR Daily Does of Internet",
    "I've over dosed on ketamine and I'm going to die",
    "Oh, AumSum.",
    "hell nah aumsum have merch (its in www.aumsum.com)",
    "Don't swear on your YouTube Video or else Susan Wojkcicki will come to your house",
    "Copyright Striked",
    "This video is not available on YouTube",
    "Demonitized",
    "No play button?"
    
}

function onCreate()
   bit = string.gsub(version,"%.","")

   curentVersion = tonumber(bit)
end


function onCreatePost()
    makeLuaText('songText', songName .. ' - ' .. getProperty('storyDifficultyText') .. ' | YouTube Engine (PE 0.6.3) | ' .. Quotes[getRandomInt(1, 20)], 0, 2, 701);
    setTextAlignment('songText', 'left');
    setTextSize('songText', 15);
    setTextBorder('songText', 1, '000000');
    setObjectCamera('songText', 'camHUD');
    addLuaText('songText');
end
