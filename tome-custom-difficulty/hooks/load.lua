local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorInventory = require "engine.interface.ActorInventory"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

dofile("data-custom-difficulty/settings.lua")

class:bindHook("ToME:load", function(self, data)
  Birther:loadDefinition("/data-custom-difficulty/birth/descriptors.lua")
end)

-- class:bindHook(
-- 	"GameOptions:generateList",
-- 	function(self, data)
-- 		config.settings.tome.loading_zomnibus = 'zomnibus'
-- 		config.settings.tome.rek_dif = config.settings.tome.rek_dif or {}
-- 		local list = data.list
-- 		local function createOption(option, tabTitle, desc, defaultFunct, defaultStatus)
-- 			defaultFunct = defaultFunct or function(item)
-- 				config.settings.tome.rek_dif[option] = not config.settings.tome.rek_dif[option]
-- 				--
-- 				game:saveSettings("tome.rek_dif."..option, ("tome.rek_dif."..option.." = %s\n"):format(tostring(config.settings.tome.rek_dif[option])))
-- 				self.c_list:drawItem(item)
-- 			end
-- 			defaultStatus = defaultStatus or function(item)
-- 				return tostring(config.settings.tome.rek_dif[option])
-- 			end
			
-- 			list[#list+1] = { zone=Textzone.new{width=self.c_desc.w, height=self.c_desc.h,
-- 			text=string.toTString("#GOLD#"..addonTitle.."\n\n#WHITE#"..desc.."#WHITE#")}, name=string.toTString(("#GOLD##{bold}#[%s] %s#WHITE##{normal}#"):format(addonShort, tabTitle)), status=defaultStatus, fct=defaultFunct,}
-- 		end
		
-- 		createOption("zone_mul", "Zone Level Multiplier", "")
-- 		createOption("zone_add", "Zone Level Bonus", "")
-- 		createOption("talent", "Enemy Talent Bonus Percent", "")
-- 		createOption("randrare", "Random Rare Chance", "")
-- 		createOption("randboss", "Random Boss Chance", "")
-- 		createOption("talent_boss", "Boss Talent Multiplier", "")
-- 		createOption("stairwait", "Stair Kill Delay", "")
-- 		createOption("health", "Enemy Life Multiplier", "")
		
-- 		createOption("hunted", "Hunted", "")
-- 		createOption("ezstatus", "Debuff Resistance", "")
		
-- 		createOption("start_level", "Player Starting Level", "")
-- 		createOption("start_life", "Player Bonus Life", "")
-- 		createOption("start_gold", "Player Starting Gold", "")
-- 	end
-- )
