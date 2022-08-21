#pragma header
uniform vec2 uBlocksize = vec2(3, 3);
uniform float size = 0;

void main()
{
	// was taken from the mosaic effect but was edited to prevent blur
    if (size > 0) { // bigger than 640x360
        vec2 blocks = openfl_TextureSize / uBlocksize;
        gl_FragColor = texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);

        if (size > 1) {// checking for dumbas, must be > 1280x720 
            vec2 offset = vec2(0, 0);
            if (gl_FragColor == texture2D(bitmap, (floor(openfl_TextureCoordv * blocks) + offset - vec2(0.25, 0)) / blocks)) {
                offset += vec2(0.25, 0);
            }
            // if (gl_FragColor == texture2D(bitmap, (floor(openfl_TextureCoordv * blocks) + offset - vec2(0, 0.25)) / blocks)) {
            //     offset += vec2(0, 0.25);
            // }
            gl_FragColor = texture2D(bitmap, (floor(openfl_TextureCoordv * blocks) + offset) / blocks);
        }
    } else
        gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);       
}