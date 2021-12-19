function opponentNoteHit()
            health = getProperty('health')
       if getProperty('health') > 1.5 then
           setProperty('health', health- 0.02);
   end
end