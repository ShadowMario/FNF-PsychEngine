package shaders;

import openfl.display.Shader;

class BlurShader extends Shader {
    public function new() {
        super();
        this.glFragmentSource =
        "
        precision mediump float;

        uniform sampler2D openfl_Texture;
        uniform vec2 openfl_TextureSize;
        
        void main(void) {
            vec2 texCoord = gl_FragCoord.xy / openfl_TextureSize;
            vec4 color = vec4(0.0);
            float blurSize = 1.0 / openfl_TextureSize.x * 8.0; // Adjust blur strength
            
            for(float x = -4.0; x <= 4.0; x++) {
                for(float y = -4.0; y <= 4.0; y++) {
                    vec2 offset = vec2(x, y) * blurSize;
                    color += texture2D(openfl_Texture, texCoord + offset);
                }
            }
            color /= 81.0; // 9x9 blur area
            gl_FragColor = color;
        }
        ";
    }
}
