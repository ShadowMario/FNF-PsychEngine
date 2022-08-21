class TextBorderShader extends FlxFixedShader {
    @:glFragmentSource("
        #pragma header

        void main() {
            vec4 color = texture2D(bitmap, openfl_TextureCoordv);
            vec4 left = texture2D(bitmap, openfl_TextureCoordv - vec2(-1 / openfl_TextureSize.x, 0));
            vec4 right = texture2D(bitmap, openfl_TextureCoordv - vec2(1 / openfl_TextureSize.x, 0));
            vec4 up = texture2D(bitmap, openfl_TextureCoordv - vec2(0, -1 / openfl_TextureSize.y));
            vec4 down = texture2D(bitmap, openfl_TextureCoordv - vec2(0, 1 / openfl_TextureSize.y));

            float alpha = color.a;
            if (left.a < alpha) alpha = left.a;
            if (right.a < alpha) alpha = right.a;
            if (up.a < alpha) alpha = up.a;
            if (down.a < alpha) alpha = down.a;
            gl_FragColor = vec4(
                color.r * color.a,
                color.g * color.a,
                color.b * color.a,
                alpha
                );
        }
    ")
}