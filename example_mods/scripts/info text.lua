curentVersion = 0;

local Quotes = {
    "It's AumSum Time!",
    "What if HScript Disappared?",
    "No AumSum?",
    "Thanks to Heli Pro Gamer for the fix!",
    "No OpenFL?",
    "MOM GET THE CAMERA",
    "YouTube is gonna copyright strike you if you die!",
    "oh noes arnold got his finger cut",
    "what a loser, getting his mod cancelled",
    "This is YOUR Daily Does of Internet",
    "I've over dosed on ketamine and I'm going to die",
    "Oh, AumSum.",
    "hell nah aumsum have merch (its in www.aumsum.com)"
}

function onCreate()
   bit = string.gsub(version,"%.","")

   curentVersion = tonumber(bit)
end


function onCreatePost()
    makeLuaText('songText', songName .. ' - ' .. getProperty('storyDifficultyText') .. ' | YouTube Engine (PE 0.6.3) | ' .. Quotes[getRandomInt(1, 11)], 0, 2, 701);
    setTextAlignment('songText', 'left');
    setTextSize('songText', 15);
    setTextBorder('songText', 1, '000000');
    setObjectCamera('songText', 'camHUD');
    addLuaText('songText');
end
