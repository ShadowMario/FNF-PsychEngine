package mod_support_stuff;

class CustomShader_Helper {
    public var shader:CustomShader;
    public function new(frag:String, vert:String, ?values:Map<String, Any>) {
        if (values == null) values = [];
        shader = new CustomShader(frag, vert, values);
    }
    public function setValue(name:String, val:Any) {
        Reflect.setField(Reflect.field(shader, name), "value", [val]);
    }
    public function getValue(name:String) {
        Reflect.field(Reflect.field(shader, name), "value");
    }
}