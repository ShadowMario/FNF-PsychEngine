package android.backend;

//https://github.com/beihu235/AndroidDialogs

import extension.androiddialogs.AndroidDialogs;

class AndroidDialogsExtend {

    public static function OpenToast(showtext:String, time:Int)
    {
        if (time != 1 && time != 2) time = 1;
			
        AndroidDialogs.ShowToast(showtext, time);
    }

    public static function OpenAlert(Title:String, Message:String, ConfirmName:String, CancelName:String)
    {
        AndroidDialogs.ShowAlertDialog(Title, Message, ConfirmName, CancelName);
    }
    
    public static function OpenAlertSelect(Title:String, choose1:String, choose2:String, choose3:String, choose4:String, choose5:String)
    {
        var names_players:Array<String> = new Array<String>();
        names_players.push(choose1);
        if (choose2 != null) names_players.push(choose2);
        if (choose3 != null) names_players.push(choose3);
        if (choose4 != null) names_players.push(choose4);
        if (choose5 != null) names_players.push(choose5);
        AndroidDialogs.ShowAlertSelectOption(Title, names_players);
    }
}

