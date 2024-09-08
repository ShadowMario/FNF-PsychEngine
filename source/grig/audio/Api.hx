package grig.audio;

// Ordered to match RtAudio to allow easy conversion
enum Api {
    Unspecified;
    Alsa;
    Jack;
    Oss;
    MacOSCore;
    WindowsWASAPI;
    WindowsASIO;
    WindowsDS;
    WindowsWDMKS;
    WindowsMME; // Will this fucking ever come up?!!
    Dummy;
    Browser;
}