import SongConf.SongConfJson;
import stage.StageJSON;

class Templates {
    public static var stageScriptTemplate = '// Stage element
var stage:Stage = null;
function create() {
    // Loads the stage. Can be called in any scripts
    stage = loadStage("tank");
}

function beatHit(curBeat) {
    // Does the OnBeat event to animate stage sprites.
    stage.onBeat();
};';

    public static var stageTemplate:StageJSON = {
        defaultCamZoom: 1,
        sprites: [
            {
                type: "GF",
                name: "Girlfriend",
                scrollFactor: [0.95, 0.95]
            },
            {
                type: "Dad",
                name: "Dad",
                scrollFactor: [1, 1]
            },
            {
                type: "BF",
                name: "Boyfriend",
                scrollFactor: [1, 1]
            }
        ],
        bfOffset: [0, 0],
        gfOffset: [0, 0],
        dadOffset: [0, 0],
        followLerp: 0.04
    };

    public static var songConfTemplate:SongConfJson = {
        songs: [
            {
                name: "Your song",
                scripts: ["modcharts/script1"],
                cutscene: "cutscenes/your-cutscene",
                end_cutscene: "cutscenes/your-end-cutscene",
                difficulties: null
            }
        ]
    }

    public static var entireFuckingCustomVertexHeader =
  " attribute float openfl_Alpha;
    attribute vec4 openfl_ColorMultiplier;
    attribute vec4 openfl_ColorOffset;
    attribute vec4 openfl_Position;
    attribute vec2 openfl_TextureCoord;

    varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;

    uniform mat4 openfl_Matrix;
    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    ";

    public static var entireFuckingCustomVertexBody = 
   "openfl_Alphav = openfl_Alpha;
    openfl_TextureCoordv = openfl_TextureCoord;

    if (openfl_HasColorTransform) {

        openfl_ColorMultiplierv = openfl_ColorMultiplier;
        openfl_ColorOffsetv = openfl_ColorOffset / 255.0;

    }

    gl_Position = openfl_Matrix * openfl_Position;
    ";

    public static var entireFuckingCustomFragmentHeader = "
    
    varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;

    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    uniform sampler2D bitmap;

    uniform bool hasTransform;
    uniform bool hasColorTransform;

    vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
    {
        vec4 color = texture2D(bitmap, coord);
        if (!hasTransform)
        {
            return color;
        }

        if (color.a == 0.0)
        {
            return vec4(0.0, 0.0, 0.0, 0.0);
        }

        if (!hasColorTransform)
        {
            return color * openfl_Alphav;
        }

        color = vec4(color.rgb / color.a, color.a);

        mat4 colorMultiplier = mat4(0);
        colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

        color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

        if (color.a > 0.0)
        {
            return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
        }
        return vec4(0.0, 0.0, 0.0, 0.0);
    }

    uniform vec4 _camSize;

    vec2 getCamPos(vec2 pos) {
        return (pos * openfl_TextureSize / vec2(_camSize.z, _camSize.w)) + vec2(_camSize.x / _camSize.z, _camSize.y / _camSize.z);
    }
    vec2 camToOg(vec2 pos) {
        return ((pos - vec2(_camSize.x / _camSize.z, _camSize.y / _camSize.z)) * vec2(_camSize.z, _camSize.w) / openfl_TextureSize);
    }
    vec4 textureCam(sampler2D bitmap, vec2 pos) {
        return texture2D(bitmap, camToOg(pos));
    }
    ";

    public static var entireFuckingCustomFragmentBody = "vec4 color = texture2D (bitmap, openfl_TextureCoordv);

    if (color.a == 0.0) {

        gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

    } else if (openfl_HasColorTransform) {

        color = vec4 (color.rgb / color.a, color.a);

        mat4 colorMultiplier = mat4 (0);
        colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        colorMultiplier[3][3] = 1.0;

        color = clamp (openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

        if (color.a > 0.0) {

            gl_FragColor = vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);

        } else {

            gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

        }

    } else {

        gl_FragColor = color * openfl_Alphav;

    }
    ";
}