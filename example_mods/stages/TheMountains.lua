
--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them

function onCreate()
	-- background shit
	makeLuaSprite('TheMountainsBack', 'TheMountainsBack', -600, -300);
	setScrollFactor('TheMountainsBack', 0.9, 0.9);
	
	makeLuaSprite('TheMountainsBottom', 'TheMountainsBottom', -650, 600);
	setScrollFactor('TheMountainsBottom', 0.9, 0.9);
	scaleObject('TheMountainsBottom', 1.1, 1.1);

	addLuaSprite('TheMountainsBack', false);
	addLuaSprite('TheMountainsBottom', false);
end