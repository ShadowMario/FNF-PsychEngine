#pragma header


uniform float horizontalDistort = 0;
uniform float verticalScroll = 0;

float coolmod(float v, float v2) {
    while(v < 0) v += v2;
    return mod(v, v2);
}

float bound(float v1, float v2, float v3) {
    if (v1 < v2) return v2;
    if (v1 > v3) return v3;
    return v2;
}
void main() {
    vec4 color = flixel_texture2D(bitmap, vec2(coolmod(openfl_TextureCoordv.x + (coolmod(sin(horizontalDistort) + openfl_TextureCoordv.y, 1) * 0.05), 1), coolmod(openfl_TextureCoordv.y + verticalScroll, 1)));

    gl_FragColor = vec4(0, 0, 0, color.a * openfl_TextureCoordv.y);
}