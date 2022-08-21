#pragma header

uniform float r = 1;
uniform float g = 1;
uniform float b = 1;
uniform bool enabled = true;
uniform bool isUI = false;

uniform float diff = 0;

float max(float v1, float v2) {
    return v1 > v2 ? v1 : v2;
}
float min(float v1, float v2) {
    return v1 < v2 ? v1 : v2;
}
void main() {
    if (enabled) {
        float r = r;
        float g = g;
        float b = b;

        if (isUI) {
            r = r + 0.5 / 1.5;
            g = g + 0.5 / 1.5;
            b = b + 0.5 / 1.5;
        }

        vec4 c = flixel_texture2D(bitmap, openfl_TextureCoordv);

        vec4 leftColor = flixel_texture2D(bitmap, openfl_TextureCoordv + vec2(-diff, 0));
        vec4 rightColor = flixel_texture2D(bitmap, openfl_TextureCoordv + vec2(diff, 0));

        vec4 color = vec4(c.r + leftColor.r + rightColor.r, c.g + leftColor.g + rightColor.g, c.b + leftColor.b + rightColor.b, c.a + leftColor.a + rightColor.a);
        color.r /= 3;
        color.g /= 3;
        color.b /= 3;
        color.a /= 3;

        float alpha = color.a;
        if (alpha == 0) {
            gl_FragColor = vec4(0, 0, 0, alpha);
        } else {
            float average = ((color.r + color.g + color.b) / 3) * 255;
            float finalColor = (50 - average) / 75;
            if (finalColor < 0) finalColor = 0;
            if (finalColor > 1) finalColor = 1;

            float average2 = ((c.r + c.g + c.b) / 3) * 255;
            float finalColor2 = (75 - average2) / 75;
            if (finalColor2 < 0) finalColor2 = 0;
            if (finalColor2 > 1) finalColor2 = 1;

            gl_FragColor = vec4(max(finalColor2, finalColor) * r * alpha, max(finalColor2, finalColor) * g * alpha, max(finalColor2, finalColor) * b * alpha, alpha);
        }

    } else {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    }
}