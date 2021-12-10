function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s";
    end
    local t={};
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str);
    end
    return t;
end

function onEvent(name, value1, value2)
	if name == "ScreenPos" then
        local tableeee=mysplit(value1,", "); -- Splits value1 into a table
		doTweenX('X', 'camGame', tableeee[1], value2, 'circOut')
		doTweenY('Y', 'camGame', -tableeee[2], value2, 'circOut')
		doTweenX('X2', 'camHUD', tableeee[1], value2, 'circOut')
		doTweenY('Y2', 'camHUD', -tableeee[2], value2, 'circOut')
	end
end