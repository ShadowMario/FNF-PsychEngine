#pragma header

uniform float uTime = 0;

void main() {
    vec2 pos = vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y);
    pos.x += sin((uTime / 2) + openfl_TextureCoordv.y) * 0.1;
    pos.y += -uTime / 3;
    pos.x = mod(pos.x, 1);
    pos.y = mod(pos.y, 1);

    vec4 color = flixel_texture2D(bitmap, pos);
    gl_FragColor = vec4(color.r, color.g, color.b, color.a);
}