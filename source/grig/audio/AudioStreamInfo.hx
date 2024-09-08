package grig.audio;

/**
 * Stream info passed in from the sound card.
 */
class AudioStreamInfo
{
    /**
     * Indicates that input data will be silence since it isn't available yet.
     * This value is always false in environments that don't provide this information.
     */
    public var inputUnderflow:Bool = false;
    /**
     * Indicates that input data was lost due to previous callback using too much time.
     * This value is always false in environments that don't provide this information.
     */
    public var inputOverflow:Bool = false;
    /**
     * Indicates that there was a gap in the output data due to previous callback taking too much time.
     * This value is always false in environments that don't provide this information.
     */
    public var outputUnderflow:Bool = false;
    /**
     * Indicates that previously given output data was discarded due to insufficient space available.
     * This value is always false in environments that don't provide this information.
     */
    public var outputOverflow:Bool = false;
    /**
     * Indicates that the given output data will be used to prime stream, so can be empty.
     * This value is always false in environments that don't provide this information.
     */
    public var primingOutput:Bool = false;
    /**
     * The time at which the beginning of the input data was recorded.
     * On platforms that don't support this, this value shall be approximated by calculating time between callbacks.
     */
    public var inputTime:AudioTime;
    /**
     * The time at which the beginning of the output data will be played.
     * On platforms that don't support this, this value shall be approximated by calculating time between callbacks.
     */
    public var outputTime:AudioTime;
    /**
     * The time at which this callback was called.
     * On platforms that don't support this, this value shall be approximated by keeping its own time from time of stream being opened.
     */
    public var callbackTime:AudioTime;

    public function new() {}
}