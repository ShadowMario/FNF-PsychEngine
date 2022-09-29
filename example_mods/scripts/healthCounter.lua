function onCreate()
	makeLuaText('counter',math.floor(getProperty('health') * 500 / 10) .. '%',0,950,634)
	setTextSize('counter', 25)
	addLuaText('counter')
end

function onUpdate()
	setTextString('counter',math.floor(getProperty('health') * 500 / 10) .. '%')
end