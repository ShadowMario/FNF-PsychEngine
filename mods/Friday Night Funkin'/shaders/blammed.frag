#pragma header

uniform float r = 1;
uniform float g = 1;
uniform float b = 1;
uniform bool enabled = true;

void main() {
    if (enabled) {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        float alpha = color.a;
        if (alpha == 0) {
            gl_FragColor = vec4(0, 0, 0, alpha);
        } else {
            float average = ((color.r + color.g + color.b) / 3) * 255;
            float finalColor = (50 - average) / 50;
            if (finalColor < 0) finalColor = 0;
            if (finalColor > 1) finalColor = 1;

            gl_FragColor = vec4(finalColor * r * alpha, finalColor * g * alpha, finalColor * b * alpha, alpha);
        }

    } else {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    }
}