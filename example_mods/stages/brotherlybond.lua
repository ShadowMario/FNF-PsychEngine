function onCreate()

	makeLuaSprite('place', 'place', -600, -300);
	
	addLuaSprite('place', false);
	
makeAnimatedLuaSprite('glitchattack','glitchattack',700,30)
addAnimationByPrefix('glitchattack','blank','nonglitch',24,false)
addAnimationByPrefix('glitchattack','gattack','glitchattack',24,false)
addLuaSprite('glitchattack',true)

end

function onBeatHit()

objectPlayAnimation('glitchattack','blank',true)

end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'Sword' then
	   	characterPlayAnim('gf', 'attack', true);
		objectPlayAnimation('glitchattack','gattack',true)
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if noteType == 'Sword' then
	   	characterPlayAnim('gf', 'attack', true);
		objectPlayAnimation('glitchattack','gattack',true)
	end
end