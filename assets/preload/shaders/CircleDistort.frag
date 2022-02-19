    //From https://www.shadertoy.com/view/lddXWS
    
    uniform vec2 iResolution;
    uniform float iTime;

    const float RADIUS	= 200.0;
    const float BLUR	= 500.0;
    const float SPEED   = 2.0;

    void main()
    {
        vec2 fragCoord = openfl_TextureCoordv * iResolution;

        vec2 uv = fragCoord.xy / iResolution.xy;
        vec4 pic = texture2D(bitmap, vec2(uv.x, uv.y));
        
        vec2 center = iResolution.xy / 2.0;
        float d = distance(fragCoord.xy, center);
        float intensity = max((d - RADIUS) / (2.0 + BLUR * (1.0 + sin(iTime*SPEED))), 0.0);

        gl_FragColor = vec4(intensity + pic.r, intensity + pic.g, intensity + pic.b, 0.2);
    }