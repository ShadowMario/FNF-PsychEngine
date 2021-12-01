function onCreate()

   makeLuaSprite('tabi-stage-destroyed-vignette','tabi-stage-destroyed-vignette',-500,-300);
   addLuaSprite('tabi-stage-destroyed-vignette',true);
   scaleObject('tabi-stage-destroyed-vignette',1.0,1.0);

   makeLuaSprite('tabi-stage-destroyed','tabi-stage-destroyed',-500,-300);
   addLuaSprite('tabi-stage-destroyed',false);

   makeAnimatedLuaSprite('fire','tabi-stage-destroyed-fire',800,-200);
   addAnimationByPrefix('fire','first','Fire',30,true);
   objectPlayAnimation('fire','first');
   addLuaSprite('fire',false);
   scaleObject('fire',0.5,2);

   makeAnimatedLuaSprite('fire1','tabi-stage-destroyed-fire',350,-230);
   addAnimationByPrefix('fire1','first','Fire',30,true);
   objectPlayAnimation('fire1','first');
   addLuaSprite('fire1',false);
   scaleObject('fire1',0.5,2);

   makeLuaSprite('tabi-stage-destroyed-boards','tabi-stage-destroyed-boards',-500,-310);
   addLuaSprite('tabi-stage-destroyed-boards',false);

   makeAnimatedLuaSprite('fire2','tabi-stage-destroyed-fire',1100,-300);
   addAnimationByPrefix('fire2','first','Fire',30,true);
   objectPlayAnimation('fire2','first');
   addLuaSprite('fire2',false);
   scaleObject('fire2',2,2);

   makeAnimatedLuaSprite('fire3','tabi-stage-destroyed-fire',-600,-300);
   addAnimationByPrefix('fire3','first','Fire',30,true);
   objectPlayAnimation('fire3','first');
   addLuaSprite('fire3',false);
   scaleObject('fire3',2,2);

   makeAnimatedLuaSprite('fire4','tabi-stage-destroyed-fire',600,200);
   addAnimationByPrefix('fire4','first','Fire',30,true);
   objectPlayAnimation('fire4','first');
   addLuaSprite('fire4',false);
   scaleObject('fire4',1,1);

   makeLuaSprite('tabi-stage-destroyed-furniture','tabi-stage-destroyed-furniture',-500,-310);
   addLuaSprite('tabi-stage-destroyed-furniture',false);

   makeLuaSprite('tabi-stage-destroyed-boombox','tabi-stage-destroyed-boombox',250,385);
   scaleObject('tabi-stage-destroyed-boombox',1.2,1.2);
   addLuaSprite('tabi-stage-destroyed-boombox',false);
end