function onEvent(name, value1, value2) 
	drainValue = tonumber(value1);
	curHealth = getProperty('health');
		if drainValue == null then
		drainValue = 0.02;
		
		else 
		damageValue = 0.02 + drainValue;
		end
		if name == 'Gain' then
			if curHealth < 2 then
			setProperty('health', curHealth + damageValue);
			
			end
			if curHealth > 2 then
			setProperty('health', 2);
		end
	end
end