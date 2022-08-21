enableRating = true;
// enableMiss(true);

function create() {
    note.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels-colored'), true, 17, 17);
    note.colored = true;
    
    switch(note.noteData % 4) {
        case 0:
            note.animation.add('scroll', [4]);
        case 1:
            note.animation.add('scroll', [5]);
        case 2:
            note.animation.add('scroll', [6]);
        case 3:
            note.animation.add('scroll', [7]);
    }

    note.splash = Paths.splashes('weeb/splash');
    
    if (note.isSustainNote)
    {
        note.noteOffset.x += 30;
        note.loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored'), true, 7, 6);

        switch(note.noteData % 4) {
            case 0:
                note.animation.add('holdpiece', [0]);
                note.animation.add('holdend', [4]);
            case 1:
                note.animation.add('holdpiece', [1]);
                note.animation.add('holdend', [5]);
            case 2:
                note.animation.add('holdpiece', [2]);
                note.animation.add('holdend', [6]);
            case 3:
                note.animation.add('holdpiece', [3]);
                note.animation.add('holdend', [7]);
        }

        note.animation.add('purpleholdend', [4]);
        note.animation.add('greenholdend', [6]);
        note.animation.add('redholdend', [7]);
        note.animation.add('blueholdend', [5]);

        note.animation.add('purplehold', [0]);
        note.animation.add('greenhold', [2]);
        note.animation.add('redhold', [3]);
        note.animation.add('bluehold', [1]);
    }

    note.setGraphicSize(Std.int(note.width * PlayState_.daPixelZoom));
    note.updateHitbox();
}


function generateStaticArrow(babyArrow:FlxSprite, i:Int) {
    babyArrow.loadGraphic(Paths.image(EngineSettings.customArrowColors ? 'weeb/pixelUI/arrows-pixels-colored' : 'weeb/pixelUI/arrows-pixels'), true, 17, 17);
    babyArrow.animation.add('green', [6]);
    babyArrow.animation.add('red', [7]);
    babyArrow.animation.add('blue', [5]);
    babyArrow.animation.add('purplel', [4]);

    babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState_.daPixelZoom));
    babyArrow.updateHitbox();
    babyArrow.antialiasing = false;
    
    babyArrow.colored = EngineSettings.customArrowColors;
    
    var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.song.keyNumber];
    if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
    switch (noteNumberScheme[i % noteNumberScheme.length])
    {
        case 0:
            babyArrow.animation.add('static', [0]);
            babyArrow.animation.add('pressed', [4, 8], 12, false);
            babyArrow.animation.add('confirm', [12, 16], 24, false);
        case 1:
            babyArrow.animation.add('static', [1]);
            babyArrow.animation.add('pressed', [5, 9], 12, false);
            babyArrow.animation.add('confirm', [13, 17], 24, false);
        case 2:
            babyArrow.animation.add('static', [2]);
            babyArrow.animation.add('pressed', [6, 10], 12, false);
            babyArrow.animation.add('confirm', [14, 18], 12, false);
        case 3:
            babyArrow.animation.add('static', [3]);
            babyArrow.animation.add('pressed', [7, 11], 12, false);
            babyArrow.animation.add('confirm', [15, 19], 24, false);
    }
}