config.settings.rek_dif = config.settings.rek_dif or {}

if config.settings.rek_dif.enabled then
	return
else
	config.settings.rek_dif.enabled = true
	
	-- Init settings
	config.settings.tome.rek_dif = config.settings.tome.rek_dif or {}
	
	function setIfNil(tag, default)
		if type(config.settings.tome.rek_dif[tag]) == "nil" then
			config.settings.tome.rek_dif[tag] = default
		end
	end
	
	-- setIfNil("zone_mul", "1.0")
	-- setIfNil("zone_add", "0")
	-- setIfNil("talent", "0")
	-- setIfNil("randrare", 4)
	-- setIfNil("randboss", 0)
	-- setIfNil("talent_boss", "0")
	-- setIfNil("stairwait", "2")
	-- setIfNil("health", "1.0")
	-- setIfNil("hunted", false)
	-- setIfNil("ezstatus", false)
	-- setIfNil("start_level", "1")
	-- setIfNil("start_life", "0")
	-- setIfNil("start_gold", "0")
end
