function create() {
	character.frames = Paths.getCharacter(character.curCharacter);
	character.loadJSON(true); // Setting to true will override getColors() and dance().
	dance = function() {
		if (character.animation.curAnim.name == "singDOWN-alt" && !character.animation.curAnim.finished) return;
		character.playAnim("idle");
	};

	if (!character.isPlayer) GameOverSubstate.scriptName = mod + ":scripts/week7-gameover";
}