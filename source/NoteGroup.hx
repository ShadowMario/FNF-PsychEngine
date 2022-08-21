import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteGroup extends FlxTypedGroup<Note> {
    public override function draw() {
        var drawOnTop:Array<Note> = [];

        var i:Int = 0;
		var note:Note = null;

        @:privateAccess(FlxCamera)
		var oldDefaultCameras = FlxCamera._defaultCameras;

		if (cameras != null)
		{
            @:privateAccess(FlxCamera)
			FlxCamera._defaultCameras = cameras;
		}

		while (i < length)
		{
			note = members[i++];

			if (note != null && note.exists && note.visible)
			{
                // draw sustains first
                if (!note.isSustainNote) {
                    drawOnTop.push(note);
                } else {
                    note.draw();
                }
			}
		}

        // then draw normal notes above them
        for(note in drawOnTop) {
            note.draw();
        }

        @:privateAccess(FlxCamera)
		FlxCamera._defaultCameras = oldDefaultCameras;
    }
}