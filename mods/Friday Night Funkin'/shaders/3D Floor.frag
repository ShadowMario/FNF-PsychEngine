#pragma header

uniform float curveX = 0.05;
uniform float curveY = 0.05;

void main() {
    vec2 pos = openfl_TextureCoordv;
    vec2 newPos = vec2((openfl_TextureCoordv.x * (1.0 - openfl_TextureCoordv.y)) + ((openfl_TextureCoordv.x + curveX) * openfl_TextureCoordv.y), openfl_TextureCoordv.y * (1 + curveY));
    gl_FragColor = flixel_texture2D(bitmap, newPos);
}