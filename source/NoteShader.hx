import flixel.system.FlxAssets.FlxShader;

class ColoredNoteShader extends FlxFixedShader {
    @:glFragmentSource('#pragma header

    uniform float r;
    uniform float g;
    uniform float b;
    uniform bool enabled;
    
    uniform bool blurEnabled;
    uniform float x;
    uniform float y;
    uniform int passes;
    
    uniform vec4 clipRect;
    uniform vec2 frameOffset;
    
    void main() {
        vec2 coordinates = openfl_TextureCoordv;
        vec4 finalColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        vec4 clipR = vec4(clipRect.x + frameOffset.x, clipRect.y + frameOffset.y, clipRect.z, clipRect.w);
        clipR.x /= openfl_TextureSize.x;
        clipR.y /= openfl_TextureSize.y;
        clipR.z /= openfl_TextureSize.x;
        clipR.w /= openfl_TextureSize.y;
    
        if (!(coordinates.x > clipR.x && coordinates.x < clipR.x + clipR.z
            && coordinates.y > clipR.y && coordinates.y < clipR.y + clipR.w)) {
            gl_FragColor = vec4(0, 0, 0, 0);
            return;
        }
    
        if (enabled) {
            float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2.0);
            gl_FragColor = vec4(((finalColor.g + finalColor.b) / 2.0) + (r * diff), finalColor.g + (g * diff), finalColor.b + (b * diff), finalColor.a);
            
        } else
            gl_FragColor = finalColor;
    }
    ')
    public function new(r:Int = 0, g:Int = 0, b:Int = 0, motion_blur:Null<Bool> = false, passes:Int = 10) {
        super();
        setColors(r, g, b);
        this.enabled.value = [true];
        this.y.value = [0.0075];
        this.passes.value = [passes];
        this.frameOffset.value = [0, 0];
        this.clipRect.value = [0, 0, 99999, 99999];
    }

    public function setColors(r:Int, g:Int, b:Int) {
        this.r.value = [r / 255];
        this.g.value = [g / 255];
        this.b.value = [b / 255];
    }
}