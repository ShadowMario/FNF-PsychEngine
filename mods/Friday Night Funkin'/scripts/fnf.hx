// function create()
//     set("PlayState.autoCamZooming", false);
// end

// function onDadHit(note)
//     print(get("parameter1.strumTime"))
//     set("PlayState.autoCamZooming", true);
// end

function create() {
    PlayState.autoCamZooming = false;
}

function onDadHit(note) {
    PlayState.autoCamZooming = true;
}