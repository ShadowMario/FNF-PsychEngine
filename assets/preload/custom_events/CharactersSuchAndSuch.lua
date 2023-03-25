function onEvent(name, value1)

    if name == 'THEEVENTNAME' and value1 == 'true' then
    
    doTweenX('MoveChar', 'THEIMAGETAG', POSITION, TIME, 'CircInOut')
    
    end
    
    end