package grig.audio.lime;

#if lime
class AudioBufferTools
{
    public static inline function toInterleaved(audioBuffer:lime.media.AudioBuffer):Array<Float> {
        return UInt8ArrayTools.toInterleaved(audioBuffer.data, audioBuffer.bitsPerSample);
    }
}
#end
