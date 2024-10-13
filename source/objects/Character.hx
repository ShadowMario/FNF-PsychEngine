	function adjustOffsets(Axis:Int, Flipped:Bool)
	{
		var currentAnimation:String = getAnimationName();
		var wasReversed:Bool = isAnimateAtlas ? atlas.anim.reversed : animation.curAnim.reversed;
		var currentFrame:Int = isAnimateAtlas ? atlas.anim.curFrame : animation.curAnim.curFrame;

		for (animName in animOffsets.keys())
		{
			playAnim(animName, true);
			var curOffset:Dynamic = animOffsets.get(animName)[Axis];
			curOffset *= -1;
			curOffset += (Axis == 0 ? frameWidth - height : frameHeight - height) * jsonScale;
		}
		playAnim(currentAnimation, true, wasReversed, currentFrame);

		var difference:Float = (Axis == 0 ? frameWidth - height : frameHeight - height) * jsonScale;
		if (!Flipped) difference *= -1;
		cameraPosition[Axis] -= difference;
		if (Axis == 0) x += difference; else y += difference;
	}

	public function swapAnimations(Animation1:String, Animation2:String)
	{
		if (Animation1 == Animation2) return; //dude

		var trackedKeys:Array<String> = [];
		@:privateAccess
		for (animName in animation._animations.keys())
		{
			if (trackedKeys.contains(animName))
				continue;

			var newAnimName:String;
			if (animName.contains(Animation1))
				newAnimName = animName.replace(Animation1, Animation2);
			else if (animName.contains(Animation2))
				newAnimName = animName.replace(Animation2, Animation1);
			else
				continue;

			var swapped:Bool = false;
			var animObj:flixel.animation.FlxAnimation = animation._animations.get(animName);
			var offset:Array<Dynamic> = animOffsets.get(animName);

			if (animation._animations.exists(newAnimName))
			{
				animation._animations.set(animName, animation._animations.get(newAnimName));
				animOffsets.set(animName, animOffsets.get(newAnimName));
				swapped = true;
				trackedKeys.push(animName);
			}

			animation._animations.set(newAnimName, animObj);
			animOffsets.set(newAnimName, offset);
			trackedKeys.push(newAnimName);
			if (!swapped)
			{
				animation._animations.remove(animName);
				animOffsets.remove(animName);
			}
		}
	}
