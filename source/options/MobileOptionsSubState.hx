package options;

class MobileOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; //for Discord Rich Presence, fuck it

		var option:Option = new Option('Extra Hitbox button', //Name
			'If checked, adds a secondery hitbox button at the bottom of the screen.', //Description
			'hitbox1', //Save data variable name
			'bool'); //Variable type
		addOption(option);

        var option:Option = new Option('Hitbox Position', //Name
			'If checked, the hitbox will be put at the bottom of the screen, otherwise will stay at the top.', //Description
			'hitbox2', //Save data variable name
			'bool'); //Variable type
		addOption(option);
		super();
	}
}
