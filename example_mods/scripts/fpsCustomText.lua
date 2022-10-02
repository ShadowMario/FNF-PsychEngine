local fpsCurText = ""
local fpsLastText = ""
function onUpdatePost(elapsed)
    fpsCurText = getPropertyFromClass("Main", "fpsVar.text")

    onFpsUpdate(elapsed)
end

function onFpsUpdate(elapsed)
    local curMem = "Memory: "..math.abs(fakeRoundDecimal(getPropertyFromClass("openfl.system.System", "totalMemory") / 1000000, 1)).." MB"
    local curFps = "FPS: "..getPropertyFromClass("Main", "fpsVar.currentFPS")
    local curSection = getProperty("curSection")
    local songPosition = getSongPosition()

    addHaxeLibrary("Main")
    runHaxeCode([[
        if (Main.fpsVar.visible) {
            Main.fpsVar.text = ']]..curFps..[[\n]]..curMem..[[';
            Main.fpsVar.text += "
            \nElapsed: ]]..elapsed..[[
            \ncurBeat: " + ]]..curBeat..[[ + "\ncurStep: " + ]]..curStep..[[ + "\ncurSection: " + ]]..curSection..[[ + "\nsongPosition: " + ]]..songPosition..[[ + "\n";
        }
    ]])
end


function fakeRoundDecimal(v, f)
    local mult = 1;
    for i = 1,f do
        mult = mult * 10;
    end
    return math.floor(v * mult) / mult;
end