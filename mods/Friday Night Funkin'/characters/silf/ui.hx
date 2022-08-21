
for (r in ratings) {
    r.color = "#E1BF22";
}

function createPost() {
    for (t in PlayState.members) {
        if (Std.is(t, FlxText)) {
            t.setFormat("C:\\Windows\\Fonts\\comic.ttf", t.size, 0xFFE1BF22, t.alignment, t.borderStyle, t.borderColor);
        }
    }
    if (PlayState.timerBar != null) PlayState.timerBar.createFilledBar(0xFF5A4D0C, 0xFFE1BF22);
}