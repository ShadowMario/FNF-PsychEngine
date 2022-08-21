import flixel.FlxGame;

class FnfGame extends FlxGame {
    public override function switchState() {
        var log = true;
        if (Settings.engineSettings != null) log = Settings.engineSettings.data.logStateChanges;
        if (log) LogsOverlay.trace('[FLIXEL ENGINE] == Switching State to ${Type.getClassName(Type.getClass(_requestedState))} ==');
        super.switchState();
    }
}