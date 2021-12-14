function onCreate()

   makeLuaSprite('vignette', 'vignette-black', -500, -300);
   addLuaSprite('vignette', true);
   scaleObject('vignette', 1.0, 1.0);

   makeLuaSprite('stage', 'bob-run-stage', -500, -300);
   addLuaSprite('stage', false);
end