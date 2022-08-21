package dev_toolbox.toolbox_tabs;

class TemplateTab extends ToolboxTab {
    public function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "name", home);
    }
    public override function onTabExit() {}
    public override function tabUpdate(elapsed:Float) {

    }
    public override function onTabEnter() {}
}