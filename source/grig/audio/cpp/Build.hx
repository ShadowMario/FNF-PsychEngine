package grig.audio.cpp;
  
import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Compiler;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Build
{
    private static function addCoreFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_COREAUDIO');

        var coreServices = Xml.createElement('vflag');
        coreServices.set('name', '-framework');
        coreServices.set('value', 'CoreServices');

        var coreAudio = Xml.createElement('vflag');
        coreAudio.set('name', '-framework');
        coreAudio.set('value', 'CoreAudio');

        var audioUnit = Xml.createElement('vflag');
        audioUnit.set('name', '-framework');
        audioUnit.set('value', 'AudioUnit');

        var audioToolbox = Xml.createElement('vflag');
        audioToolbox.set('name', '-framework');
        audioToolbox.set('value', 'AudioToolbox');

        var coreFoundation = Xml.createElement('vflag');
        coreFoundation.set('name', '-framework');
        coreFoundation.set('value', 'CoreFoundation');

        var wlFlags = Xml.createElement('flag');
        wlFlags.set('value', '-Wl,-F/Library/Frameworks');

        for (flag in [defineXml]) {
            flag.set('if', 'macos || ios');
            files.addChild(flag);
        }

        for (flag in [coreServices, coreAudio, audioUnit, audioToolbox, coreFoundation, wlFlags]) {
            flag.set('if', 'macos || ios');
            target.addChild(flag);
        }

        var fileNames = ['pa_mac_core_blocking.c', 'pa_mac_core_utilities.c', 'pa_mac_core.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/coreaudio/' + file);
            fileXml.set('if', 'macos || ios');
            files.addChild(fileXml);
        }
    }

    private static function addALSAFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_ALSA');

        var libALSA = Xml.createElement('lib');
        libALSA.set('name', '-lasound');

        for (flag in [defineXml]) {
            flag.set('if', 'linux'); // What do I do about FreeBSD?
            flag.set('unless', 'disable_alsa');
            files.addChild(flag);
        }

        for (flag in [libALSA]) {
            flag.set('if', 'linux');
            flag.set('unless', 'disable_alsa');
            target.addChild(flag);
        }

        var fileNames = ['pa_linux_alsa.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/alsa/' + file);
            fileXml.set('if', 'linux');
            fileXml.set('unless', 'disable_alsa');
            files.addChild(fileXml);
        }
    }

    private static function addOSSFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_OSS');

        var libOSS = Xml.createElement('lib');
        libOSS.set('name', '-lossaudio');

        for (flag in [defineXml]) {
            flag.set('if', 'enable_oss'); // What do I do about FreeBSD?
            files.addChild(flag);
        }

        for (flag in [libOSS]) {
            flag.set('if', 'enable_oss');
            target.addChild(flag);
        }

        var fileNames = ['pa_unix_oss.c', 'recplay.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/oss/' + file);
            fileXml.set('if', 'enable_oss');
            files.addChild(fileXml);
        }
    }

    // Dynamically linking and not statically building a la portaudio itself because lGPL
    private static function addJACKFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_JACK');

        var libJACK = Xml.createElement('lib');
        libJACK.set('name', '-ljack');

        for (flag in [defineXml]) {
            flag.set('if', 'enable_jack');
            files.addChild(flag);
        }

        for (flag in [libJACK]) {
            flag.set('if', 'enable_jack');
            target.addChild(flag);
        }

        var fileNames = ['pa_jack.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/jack/' + file);
            fileXml.set('if', 'enable_jack');
            files.addChild(fileXml);
        }
    }

    private static function addWinMMFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_WMME');

        var libMM = Xml.createElement('lib');
        libMM.set('name', 'winmm.lib');

        for (flag in [defineXml]) {
            flag.set('if', 'windows');
            files.addChild(flag);
        }

        for (flag in [libMM]) {
            flag.set('if', 'windows');
            target.addChild(flag);
        }

        var fileNames = ['pa_win_wmme.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/wmme/' + file);
            fileXml.set('if', 'windows');
            files.addChild(fileXml);
        }
    }

    private static function addWinDSFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_DS');

        var libDS = Xml.createElement('lib');
        libDS.set('name', 'dsound.lib');

        for (flag in [defineXml]) {
            flag.set('if', 'windows');
            files.addChild(flag);
        }

        for (flag in [libDS]) {
            flag.set('if', 'windows');
            target.addChild(flag);
        }

        var fileNames = ['pa_win_ds.c', 'pa_win_ds_dynlink.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/dsound/' + file);
            fileXml.set('if', 'windows');
            files.addChild(fileXml);
        }
    }

    private static function addWASAPIFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_WASAPI');

        var ole32 = Xml.createElement('lib');
        ole32.set('name', 'ole32.lib');

        var uuid = Xml.createElement('lib');
        uuid.set('name', 'uuid.lib');

        for (flag in [defineXml]) {
            flag.set('if', 'windows');
            files.addChild(flag);
        }

        for (flag in [ole32, uuid]) {
            flag.set('if', 'windows');
            target.addChild(flag);
        }

        var fileNames = ['pa_win_wasapi.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/wasapi/' + file);
            fileXml.set('if', 'windows');
            files.addChild(fileXml);
        }
    }

    private static function addWDKMSFlags(files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_WDMKS');

        var ole32 = Xml.createElement('lib');
        ole32.set('name', 'ole32.lib');

        var uuid = Xml.createElement('lib');
        uuid.set('name', 'uuid.lib');

        var setupapi = Xml.createElement('lib');
        setupapi.set('name', 'setupapi.lib');

        var advapi32 = Xml.createElement('lib');
        advapi32.set('name', 'advapi32.lib');

        for (flag in [defineXml]) {
            flag.set('if', 'windows');
            files.addChild(flag);
        }

        for (flag in [ole32, uuid, setupapi, advapi32]) {
            flag.set('if', 'windows');
            target.addChild(flag);
        }

        var fileNames = ['pa_win_wdmks.c'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/wdmks/' + file);
            fileXml.set('if', 'windows');
            files.addChild(fileXml);
        }
    }

    private static function addASIOFlags(sourcePath:String, files:Xml, target:Xml)
    {
        var defineXml = Xml.createElement('compilerflag');
        defineXml.set('value', '-DPA_USE_ASIO');

        var ole32 = Xml.createElement('lib');
        ole32.set('name', 'ole32.lib');

        var uuid = Xml.createElement('lib');
        uuid.set('name', 'uuid.lib');

        for (flag in [defineXml]) {
            flag.set('if', 'enable_asio');
            files.addChild(flag);
        }

        for (flag in [ole32, uuid]) {
            flag.set('if', 'enable_asio');
            target.addChild(flag);
        }

        var fileNames = ['pa_asio.cpp', 'iasiothiscallresolver.cpp'];
        for (file in fileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/hostapi/asio/' + file);
            fileXml.set('if', 'enable_asio');
            files.addChild(fileXml);
        }

        var asioFileNames = ['common/asio.cpp', 'host/pc/asiolist.cpp', 'host/asiodrivers.cpp'];
        for (file in asioFileNames) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', '$${asio_path}/$file');
            fileXml.set('if', 'enable_asio');
            files.addChild(fileXml);
        }

        var includePaths = ['common', 'host', 'host/pc'];
        for (includePath in includePaths) {
            var includePathXml = Xml.createElement('compilerflag');
            includePathXml.set('value', '-I$${asio_path}/$includePath');
            includePathXml.set('if', 'enable_asio');
            files.addChild(includePathXml);
        }
    }

    private static function addOSSpecific(libPath:String, files:Xml):Void
    {
        var unixFiles = ['pa_unix_hostapis.c', 'pa_unix_util.c'];
        for (file in unixFiles) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/os/unix/' + file);
            fileXml.set('if', 'linux || macos || ios');
            files.addChild(fileXml);
        }

        var winFiles = [
            'pa_win_coinitialize.c', 'pa_win_hostapis.c', 'pa_win_util.c', 'pa_win_waveformat.c',
            'pa_win_wdmks_utils.c', 'pa_x86_plain_converters.c'
        ];
        for (file in winFiles) {
            var fileXml = Xml.createElement('file');
            fileXml.set('name', 'src/os/win/' + file);
            fileXml.set('if', 'windows');
            files.addChild(fileXml);
        }

        var includePath = Xml.createElement('compilerflag');
        includePath.set('value', '-I$libPath/src/os/unix/');
        includePath.set('if', 'linux || macos || ios');
        files.addChild(includePath);

        var includePath = Xml.createElement('compilerflag');
        includePath.set('value', '-I$libPath/src/os/win/');
        includePath.set('if', 'windows');
        files.addChild(includePath);
    }

    macro public static function xml():Array<Field>
    {
        var _pos =  Context.currentPos();
        var _pos_info = _pos.getInfos();
        var _class = Context.getLocalClass();

        var _source_path = Path.directory(_pos_info.file);
        if( !Path.isAbsolute(_source_path) ) {
            _source_path = Path.join([Sys.getCwd(), _source_path]);
        }

        _source_path = Path.normalize(_source_path);

        var _lib_path = Path.normalize(Path.join([_source_path, 'portaudio/portaudio']));

        var _xml = Xml.createDocument();
        var _topElement = Xml.createElement('xml');
        _xml.addChild(_topElement);

        var rtmidiFilenames = [
            'pa_allocation.c', 'pa_converters.c', 'pa_cpuload.c', 'pa_debugprint.c', 'pa_dither.c', 'pa_front.c', 'pa_process.c',
            'pa_ringbuffer.c', 'pa_stream.c', 'pa_trace.c'
        ];

        var portaudioFiles = 'portaudio-files';
        var _files = Xml.createElement('files');
        _files.set('id', portaudioFiles);
        _files.set('dir', _lib_path);
        for (fileName in rtmidiFilenames) {
            var _file = Xml.createElement('file');
            _file.set('name', 'src/common/' + fileName);
            _files.addChild(_file);
        }
        
        for (includeDir in ['include', 'src/common']) {
            var _includePath = Xml.createElement('compilerflag');
            _includePath.set('value', '-I$_lib_path/$includeDir');
            _files.addChild(_includePath);
        }
        
        _topElement.addChild(_files);

        var _haxeTarget = Xml.createElement('target');
        _haxeTarget.set('id', 'haxe');
        _haxeTarget.set('tool', 'linker');
        _haxeTarget.set('toolid', '$${haxelink}');
        _haxeTarget.set('output', '$${HAXE_OUTPUT_FILE}');
        var _libXml = Xml.createElement('lib');
        _libXml.set('name', Path.normalize(Path.join(['build', 'libportaudio$${LIBEXT}'])));
        var _targetDependency = Xml.createElement('target');
        _targetDependency.set('id', 'portaudio_link');
        _haxeTarget.addChild(_libXml);
        _haxeTarget.addChild(_targetDependency);
        _topElement.addChild(_haxeTarget);

        var _defaultTarget = Xml.createElement('target');
        _defaultTarget.set('id', 'portaudio_link');
        _defaultTarget.set('tool', 'linker');
        _defaultTarget.set('toolid', 'static_link');
        _defaultTarget.set('output', 'libportaudio');
        var _filesRef = Xml.createElement('files');
        _filesRef.set('id', portaudioFiles);
        var _outdir = Xml.createElement('outdir');
        _outdir.set('name', 'build');
        _defaultTarget.addChild(_filesRef);
        _defaultTarget.addChild(_outdir);
        _topElement.addChild(_defaultTarget);

        addOSSpecific(_lib_path, _files);
        addCoreFlags(_files, _haxeTarget);
        addALSAFlags(_files, _haxeTarget);
        addJACKFlags(_files, _haxeTarget);
        addOSSFlags(_files, _haxeTarget);
        addWinMMFlags(_files, _haxeTarget);
        addWinDSFlags(_files, _haxeTarget);
        addWASAPIFlags(_files, _haxeTarget);
        addWDKMSFlags(_files, _haxeTarget);
        addASIOFlags(_source_path, _files, _haxeTarget);

        var filesString = _files.toString();
        var haxeTargetString = _haxeTarget.toString();
        var defaultTargetString = _defaultTarget.toString();

        _class.get().meta.add(":buildXml", [{ expr:EConst( CString( '$filesString\n$haxeTargetString\n$defaultTargetString' ) ), pos:_pos }], _pos );

        return Context.getBuildFields();
    }

}