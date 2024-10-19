package backend.util.sys.mac;

#if mac
@:cppFileCode("#include <sys/sysctl.h>")
class Mac {
	@:functionCode('
	int mib [] = { CTL_HW, HW_MEMSIZE };
	int64_t value = 0;
	size_t length = sizeof(value);

	if(-1 == sysctl(mib, 2, &value, &length, NULL, 0))
		return -1; // An error occurred

	return value / 1024 / 1024;
	')
	public static function getTotalRam():Float
	{
		return 0;
	}
}
#end