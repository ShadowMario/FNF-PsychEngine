#pragma header

float bound(float v1, float v2, float v3) {
    if (v1 < v2) return v2;
    if (v1 > v3) return v3;
    return v1;
}

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    color.r += 0.2;
    color.g += 0.2;
    color.b += 0.2;

    gl_FragColor = color;
}