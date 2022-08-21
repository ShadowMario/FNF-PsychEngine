function onPlayerHit(direction:Int) {
    switch(direction) {
        case 0:
            gf.playAnim("singLEFT", true);
        case 1:
            gf.playAnim("singDOWN", true);
        case 2:
            gf.playAnim("singUP", true);
        case 3:
            gf.playAnim("singRIGHT", true);
    }
}

function onDadHit(direction:Int) {
    onPlayerHit(direction);
}

function onMiss(direction:Int) {
    if (gf == null) return;
    switch(direction) {
        case 0:
            gf.playAnim("singLEFTmiss", true);
        case 1:
            gf.playAnim("singDOWNmiss", true);
        case 2:
            gf.playAnim("singUPmiss", true);
        case 03:
            gf.playAnim("singRIGHTmiss", true);
    }
}