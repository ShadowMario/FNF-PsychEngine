package states.stages.objects;

import objects.Note;
import objects.Character;

// Pico Note functions
class PicoBlazinHandler
{
	public function new() {}

	var cantUppercut = false;
	public function noteHit(note:Note)
	{
		if (wasNoteHitPoorly(note.rating) && isPlayerLowHealth() && isDarnellPreppingUppercut())
		{
			playPunchHighAnim();
			return;
		}

		if (cantUppercut)
		{
			playBlockAnim();
			cantUppercut = false;
			return;
		}

		switch(note.noteType)
		{
			case "weekend-1-punchlow":
				playPunchLowAnim();
			case "weekend-1-punchlowblocked":
				playPunchLowAnim();
			case "weekend-1-punchlowdodged":
				playPunchLowAnim();
			case "weekend-1-punchlowspin":
				playPunchLowAnim();

			case "weekend-1-punchhigh":
				playPunchHighAnim();
			case "weekend-1-punchhighblocked":
				playPunchHighAnim();
			case "weekend-1-punchhighdodged":
				playPunchHighAnim();
			case "weekend-1-punchhighspin":
				playPunchHighAnim();

			case "weekend-1-blockhigh":
				playBlockAnim();
			case "weekend-1-blocklow":
				playBlockAnim();
			case "weekend-1-blockspin":
				playBlockAnim();

			case "weekend-1-dodgehigh":
				playDodgeAnim();
			case "weekend-1-dodgelow":
				playDodgeAnim();
			case "weekend-1-dodgespin":
				playDodgeAnim();

			// Pico ALWAYS gets punched.
			case "weekend-1-hithigh":
				playHitHighAnim();
			case "weekend-1-hitlow":
				playHitLowAnim();
			case "weekend-1-hitspin":
				playHitSpinAnim();

			case "weekend-1-picouppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-picouppercut":
				playUppercutAnim(true);

			case "weekend-1-darnelluppercutprep":
				playIdleAnim();
			case "weekend-1-darnelluppercut":
				playUppercutHitAnim();

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playFakeoutAnim();
			case "weekend-1-taunt":
				playTauntConditionalAnim();
			case "weekend-1-tauntforce":
				playTauntAnim();
			case "weekend-1-reversefakeout":
				playIdleAnim(); // TODO: Which anim?
		}
	}

	public function noteMiss(note:Note)
	{
		//trace('missed note!');
		if (isDarnellInUppercut())
		{
			playUppercutHitAnim();
			return;
		}

		if (willMissBeLethal())
		{
			playHitLowAnim();
			return;
		}

		if (cantUppercut)
		{
			playHitHighAnim();
			return;
		}

		switch (note.noteType)
		{
			// Pico fails to punch, and instead gets hit!
			case "weekend-1-punchlow":
				playHitLowAnim();
			case "weekend-1-punchlowblocked":
				playHitLowAnim();
			case "weekend-1-punchlowdodged":
				playHitLowAnim();
			case "weekend-1-punchlowspin":
				playHitSpinAnim();

			// Pico fails to punch, and instead gets hit!
			case "weekend-1-punchhigh":
				playHitHighAnim();
			case "weekend-1-punchhighblocked":
				playHitHighAnim();
			case "weekend-1-punchhighdodged":
				playHitHighAnim();
			case "weekend-1-punchhighspin":
				playHitSpinAnim();

			// Pico fails to block, and instead gets hit!
			case "weekend-1-blockhigh":
				playHitHighAnim();
			case "weekend-1-blocklow":
				playHitLowAnim();
			case "weekend-1-blockspin":
				playHitSpinAnim();

			// Pico fails to dodge, and instead gets hit!
			case "weekend-1-dodgehigh":
				playHitHighAnim();
			case "weekend-1-dodgelow":
				playHitLowAnim();
			case "weekend-1-dodgespin":
				playHitSpinAnim();

			// Pico ALWAYS gets punched.
			case "weekend-1-hithigh":
				playHitHighAnim();
			case "weekend-1-hitlow":
				playHitLowAnim();
			case "weekend-1-hitspin":
				playHitSpinAnim();

			// Fail to dodge the uppercut.
			case "weekend-1-picouppercutprep":
				playPunchHighAnim();
				cantUppercut = true;
			case "weekend-1-picouppercut":
				playUppercutAnim(false);

			// Darnell's attempt to uppercut, Pico dodges or gets hit.
			case "weekend-1-darnelluppercutprep":
				playIdleAnim();
			case "weekend-1-darnelluppercut":
				playUppercutHitAnim();

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playHitHighAnim();
			case "weekend-1-taunt":
				playTauntConditionalAnim();
			case "weekend-1-tauntforce":
				playTauntAnim();
			case "weekend-1-reversefakeout":
				playIdleAnim();
		}
	}
	
	public function noteMissPress(direction:Int)
	{
		if (willMissBeLethal())
			playHitLowAnim(); // Darnell throws a punch so that Pico dies.
		else 
			playPunchHighAnim(); // Pico wildly throws punches but Darnell dodges.
	}

	function movePicoToBack()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos < dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	function movePicoToFront()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos > dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	var alternate:Bool = false;
	function doAlternate():String
	{
		alternate = !alternate;
		return alternate ? '1' : '2';
	}

	function playBlockAnim()
	{
		boyfriend.playAnim('block', true);
		FlxG.camera.shake(0.002, 0.1);
		moveToBack();
	}

	function playCringeAnim()
	{
		boyfriend.playAnim('cringe', true);
		moveToBack();
	}

	function playDodgeAnim()
	{
		boyfriend.playAnim('dodge', true);
		moveToBack();
	}

	function playIdleAnim()
	{
		boyfriend.playAnim('idle', false);
		moveToBack();
	}

	function playFakeoutAnim()
	{
		boyfriend.playAnim('fakeout', true);
		moveToBack();
	}

	function playUppercutPrepAnim()
	{
		boyfriend.playAnim('uppercutPrep', true);
		moveToFront();
	}

	function playUppercutAnim(hit:Bool)
	{
		boyfriend.playAnim('uppercut', true);
		if (hit) FlxG.camera.shake(0.005, 0.25);
		moveToFront();
	}

	function playUppercutHitAnim()
	{
		boyfriend.playAnim('uppercutHit', true);
		FlxG.camera.shake(0.005, 0.25);
		moveToBack();
	}

	function playHitHighAnim()
	{
		boyfriend.playAnim('hitHigh', true);
		FlxG.camera.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitLowAnim()
	{
		boyfriend.playAnim('hitLow', true);
		FlxG.camera.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitSpinAnim()
	{
		boyfriend.playAnim('hitSpin', true);
		FlxG.camera.shake(0.0025, 0.15);
		moveToBack();
	}

	function playPunchHighAnim()
	{
		boyfriend.playAnim('punchHigh' + doAlternate(), true);
		moveToFront();
	}

	function playPunchLowAnim()
	{
		boyfriend.playAnim('punchLow' + doAlternate(), true);
		moveToFront();
	}

	function playTauntConditionalAnim()
	{
		if (boyfriend.getAnimationName() == "fakeout")
			playTauntAnim();
		else
			playIdleAnim();
	}

	function playTauntAnim()
	{
		boyfriend.playAnim('taunt', true);
		moveToBack();
	}

	function willMissBeLethal()
	{
		return PlayState.instance.health <= 0.0 && !PlayState.instance.practiceMode;
	}
	
	function isDarnellPreppingUppercut()
	{
		return dad.getAnimationName() == 'uppercutPrep';
	}

	function isDarnellInUppercut()
	{
		return dad.getAnimationName() == 'uppercut' || dad.getAnimationName() == 'uppercut-hold';
	}

	function wasNoteHitPoorly(rating:String)
	{
		return (rating == "bad" || rating == "shit");
	}

	function isPlayerLowHealth()
	{
		return PlayState.instance.health <= 0.3 * 2;
	}
	
	function moveToBack()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos < dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	function moveToFront()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos > dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	var boyfriend(get, never):Character;
	var dad(get, never):Character;
	var boyfriendGroup(get, never):FlxSpriteGroup;
	var dadGroup(get, never):FlxSpriteGroup;
	function get_boyfriend() return PlayState.instance.boyfriend;
	function get_dad() return PlayState.instance.dad;
	function get_boyfriendGroup() return PlayState.instance.boyfriendGroup;
	function get_dadGroup() return PlayState.instance.dadGroup;
}