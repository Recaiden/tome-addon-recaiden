local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = Talents.main_env.damDesc

str_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}

dex_req1 = {
	stat = { dex=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
dex_req2 = {
	stat = { dex=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
dex_req3 = {
	stat = { dex=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
dex_req4 = {
	stat = { dex=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}

if not Talents.talents_types_def["technique/weapon-techniques"] then
   newTalentType{ allow_random=false, type="technique/weapon-techniques", name = "Weapon Techniques", description = "Basic attacks for each type of weapon." }
   load("/data-weapontech/daggers.lua")

	 load("/data-weapontech/swords.lua")
	 load("/data-weapontech/axes.lua")
	 load("/data-weapontech/maces.lua")

	 load("/data-weapontech/greatswords.lua")
	 load("/data-weapontech/battleaxes.lua")
	 load("/data-weapontech/greatmauls.lua")

	 load("/data-weapontech/shields.lua")

	 load("/data-weapontech/tridents.lua")
	 load("/data-weapontech/whips.lua")
end
