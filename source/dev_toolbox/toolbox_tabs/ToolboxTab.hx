package dev_toolbox.toolbox_tabs;

import flixel.addons.ui.FlxUI;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class ToolboxTab extends FlxSpriteGroup {
    var state:ToolboxHome;
    public function new(x:Float, y:Float, tabName:String, home:ToolboxHome) {
        super(x, y);
        
        state = home;

        var t = new FlxUI(null, state.UI_Tabs);
        t.name = tabName;
        state.UI_Tabs.addGroup(t);

        state.tabs[tabName] = this;
    }

    public function onTabExit() {

    }

    public function tabUpdate(elapsed:Float) {

    }

    public function onTabEnter() {

    }
}