package;


class Signal<T> {
    var callbacks:Array<T -> Void> = [];
    public function new() {}
    public function connect(func:T->Void):Void {
        callbacks.push(func);
    }
    public function disconnect(func:T->Void):Void {
        callbacks.remove(func);
    }
    public function reset():Void {
        callbacks = [];
    }

    public function trigger(value:T) {
        for (callback in callbacks) {
            callback(value);
        }
    }
}
class Signal2<A, B> {
    var callbacks:Array<(A, B) -> Void> = [];

    public function trigger(value:A, value2:B) {
        for (callback in callbacks) {
            callback(value, value2);
        }
    }

    public function connect(func:(A, B) -> Void):Void {
        callbacks.push(func);
    }
    public function disconnect(func:(A,B) -> Void):Void {
        callbacks.remove(func);
    }
    public function reset():Void {
        callbacks = [];
    }
}
enum Noise {
    Noise;
}