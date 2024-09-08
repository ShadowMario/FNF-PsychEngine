package grig.audio;

import grig.audio.NumericTypes;

typedef AudioCallback = (input:AudioBuffer<Float32>, output:AudioBuffer<Float32>, sampleRate:Float, audioStreamInfo:AudioStreamInfo)->Void;
