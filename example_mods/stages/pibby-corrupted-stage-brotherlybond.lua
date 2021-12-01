function onCreate()

	makeLuaSprite('pibby-corrupted-stage', 'pibby-corrupted-stage', -600, -300);
	
	addLuaSprite('pibby-corrupted-stage', false);
	
makeAnimatedLuaSprite('pibby-corrupted-glitchattack','pibby-corrupted-glitchattack',700,30)
addAnimationByPrefix('pibby-corrupted-glitchattack','blank','nonglitch',24,false)
addAnimationByPrefix('pibby-corrupted-glitchattack','gattack','glitchattack',24,false)
addLuaSprite('pibby-corrupted-glitchattack',true)

end

function onBeatHit()

objectPlayAnimation('pibby-corrupted-glitchattack','blank',true)

end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'Sword' then
	   	characterPlayAnim('gf', 'attack', true);
		objectPlayAnimation('pibby-corrupted-glitchattack','gattack',true)
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if noteType == 'Sword' then
	   	characterPlayAnim('gf', 'attack', true);
		objectPlayAnimation('pibby-corrupted-glitchattack','gattack',true)
	end
end