using Map;

class Calendar
{
    public static var month_short_name_map:Map<Int, String> = [
        0 => 'Jan', 1 => 'Feb', 2 => 'Mar', 3 => 'Apr', 4 => 'May',
        5 => 'Jun', 6 => 'Jul', 7 => 'Aug', 8 => 'Sep', 9 => 'Oct',
        10 => 'Nov', 11 => 'Dec'
    ];

    public static var month_name_map:Map<Int, String> = [
        0 => 'January', 1 => 'February', 2 => 'March', 3 => 'April', 4 => 'May',
        5 => 'June', 6 => 'July', 7 => 'August', 8 => 'September', 9 => 'October',
        10 => 'November', 11 => 'December'
    ];

    public static var days_short_name_map:Map<Int, String> = [
        0 => 'Sun', 1 => 'Mon', 2 => 'Tue', 3 => 'Wed', 4 => 'Thu',
        5 => 'Fri', 6 => 'Sat'
    ];

    public static var days_name_map:Map<Int, String> = [
        0 => 'Sunday', 1 => 'Monday', 2 => 'Tuesday', 3 => 'Wednesday', 4 => 'Thursday',
        5 => 'Friday', 6 => 'Saturday'
    ];

    /*public static var MONTH_SHORT_NAME = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May',
        'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
        'Nov', 'Dec'
    ];
    public static var MONTH_NAME = [
        'January', 'February', 'March', 'April', 'May',
        'June', 'July', 'August', 'September', 'October',
        'November', 'December'
    ];
    public static var DAYS_SHORT_NAME = [
        'Sun', 'Mon', 'Tue', 'Wed', 'Thu',
        'Fri', 'Sat'
    ];
    public static var DAYS_NAME = [
        'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday'
    ];*/
}