package grig.audio;

import tink.core.Error;

class PortAudioHelper
{
    private static var nameApiMapping = [
        'ALSA'                      => grig.audio.Api.Alsa,
        'ASIO'                      => grig.audio.Api.WindowsASIO,
        'Core Audio'                => grig.audio.Api.MacOSCore,
        'Windows DirectSound'       => grig.audio.Api.WindowsDS,
        'JACK Audio Connection Kit' => grig.audio.Api.Jack,
        'OSS'                       => grig.audio.Api.Oss,
        'Windows WASAPI'            => grig.audio.Api.WindowsWASAPI,
        'Windows WDM-KS'            => grig.audio.Api.WindowsWDMKS,
        'MME'                       => grig.audio.Api.WindowsMME,
        'Unspecified'               => grig.audio.Api.Unspecified,
    ];

    public static function apiFromName(name:String):Api
    {
        if (nameApiMapping.exists(name)) return nameApiMapping[name];
        throw new Error(InternalError, 'Unknown api: $name');
    }

    public static function nameFromApi(api:Api):String
    {
        for (name in nameApiMapping.keys()) {
            if (nameApiMapping[name] == api) return name;
        }
        throw new Error(InternalError, 'Unknown api: $api');
    }
}