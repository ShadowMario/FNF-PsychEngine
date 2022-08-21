import("Date");

function create() {
    var t = Date.now();
    if (t.getDay() == 5) {
        Medals.unlock("Just like the game");
    }
}