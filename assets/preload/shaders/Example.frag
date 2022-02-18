    /*
        1- First of all, you need to know that shadertoy automatically uses the inputs below:

        uniform vec3      iResolution;           // viewport resolution (in pixels)
        uniform float     iTime;                 // shader playback time (in seconds)
        uniform float     iTimeDelta;            // render time (in seconds)
        uniform int       iFrame;                // shader playback frame
        uniform float     iChannelTime[4];       // channel playback time (in seconds)
        uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
        uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
        uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
        uniform vec4      iDate;                 // (year, month, day, time in seconds)
        uniform float     iSampleRate;           // sound sample rate (i.e., 44100)

        Currently, my implementation only supports the following inputs: (iResolution, iTime, iChannel0).
        Support for iMouse input is planned for the future.

        2- Porting:

        For this instance we will be porting https://www.shadertoy.com/view/lddXWS

        The shader code is the following:

        ```
        const float RADIUS	= 100.0;
        const float BLUR	= 200.0;
        const float SPEED   = 2.0;

        void mainImage( out vec4 fragColor, in vec2 fragCoord )
        {
            vec2 uv = fragCoord.xy / iResolution.xy;
            vec4 pic = texture(iChannel0, vec2(uv.x, uv.y));
            
            vec2 center = iResolution.xy / 2.0;
            float d = distance(fragCoord.xy, center);
            float intensity = max((d - RADIUS) / (2.0 + BLUR * (1.0 + sin(iTime*SPEED))), 0.0);
            
            fragColor = vec4(intensity + pic.r, intensity + pic.g, intensity + pic.b, 1.0);
        }
        ```

        We need to modify some stuff, 

        - main function header `void mainImage( out vec4 fragColor, in vec2 fragCoord )`
           should be changed to `void main()` 
           and add a new line at the start of function: `vec2 fragCoord = openfl_TextureCoordv * iResolution;`

        - The shader outputs to `fragColor`, this should be changed to `gl_FragColor`

        - at the very start of the shader add those two uniforms:
            `uniform vec2 iResolution;`
            `uniform float iTime;`

        - if your shader makes use of `iChannel0` sampler, change that to `bitmap`

        - if your shader outputs alpha pixels and they're black (Black instead of transparent),
            Make sure to use\change texture function to `texture2D` instead of `texture`

        The result should be the **uncommented** code below.

        3- Usage:

        ```
        new DynamicShaderHandler("Example");
		FlxG.camera.setFilters([new ShaderFilter(animatedShaders["Example"].shader)]);
        ```

        or

        ```
        var spr:FlxSprite = new ShaderSprite("Example");
        ```
    */
    
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