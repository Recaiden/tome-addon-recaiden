local class = require"engine.class"
local DamageType = require "engine.DamageType"
local Shader = require "engine.Shader"
local UIBase = require "engine.ui.Base"
local Textzone = require "engine.ui.Textzone"

class:bindHook(
	"ToME:load",
	function(self, data)
		local Birther = require "engine.Birther"
		local DamageType = require "engine.DamageType"
		local WorldAchievements = require "mod.class.interface.WorldAchievements"
		local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
		local ActorTalents = require "engine.interface.ActorTalents"
		local ActorResource = require "engine.interface.ActorResource"
		local ActorAI = require "engine.interface.ActorAI"
		local PartyIngredients = require "mod.class.interface.PartyIngredients"
		local Store = require "mod.class.Store"
		local PartyLore = require "mod.class.interface.PartyLore"
		
		dofile("/data-campaign-hammer/factions.lua")
		DamageType:loadDefinition("/data-campaign-hammer/damage_types.lua")
		WorldAchievements:loadDefinition("/data-campaign-hammer/achievements/")
		PartyLore:loadDefinition("/data-campaign-hammer/lore/lore.lua")
		Store:loadStores("/data-campaign-hammer/general/stores/fearscape.lua")
		ActorAI:loadDefinition("/data-campaign-hammer/ai/")
		
		--ActorTalents:loadDefinition("/data-campaign-hammer/talents.lua")
		
		ActorTemporaryEffects:loadDefinition("/data-campaign-hammer/effects.lua")
		
		Birther:loadDefinition("/data-campaign-hammer/birth/worlds.lua")
		--Birther:loadDefinition("/data-campaign-hammer/birth/races/duathedlen.lua")
		--Birther:loadDefinition("/data-campaign-hammer/birth/classes/impling.lua")
	end)

class:bindHook(
	"MapGeneratorStatic:subgenRegister",
	function(self, data)
		if data.mapfile ~= "wilderness/eyal" or game.state.birth.campaign_name ~= "hammer" then return end
		data.list[#data.list+1] = {
			x = 0, y = 0, w = 79, h = 52, overlay = true,
			generator = "engine.generator.map.Static",
			data = {
				map = "campaign-hammer+zones/worldmap",
			},
		}
		self.level:setEntitiesList("maj_eyal_encounters", {}, true)
	end
)

class:bindHook(
	"Entity:loadList",
	function(self, data)
		if type(game) ~= "table" then return end
		if game.state.birth.campaign_name == "hammer" then
			if data.file == "/data/zones/wilderness/grids.lua" then
				self:loadList("/data-campaign-hammer/zones/wilderness-add/grids.lua", data.no_default, data.res, data.mod, data.loaded)
			end
		end
		
		-- TODO load extra enemies
		-- if data.file == "/data/general/npcs/horror.lua" then
		-- 	self:loadList("/data-campaign-hammer/general/npcs/horror.lua", data.no_default, data.res, data.mod, data.loaded)
		-- end
	end
)

class:bindHook(
	"ToME:runDone",
	function(self, data)
		if game.state.birth.campaign_name == "hammer" then
			engine.Faction:setInitialReaction("fearscape", "enemies", -50, true)
			engine.Faction:setInitialReaction("orc-pride", "fearscape", -50, true)
		end
	end
)

-- Add zone events
local statue_zones = {
	["campaign-hammer+orbital-invasion-platfomr"] = {percent = 50},
	["campaign-hammer+scintillating-caverns"] = {percent = 80, forbid={1,2,3,4}},
	["campaign-hammer+fields-of-hope"] = {percent = 50, forbid={5,6}},
}
local tentacle_zones = {
	["campaign-hammer+derth-invasion"] = {percent = 25, forbid={3}},
	["campaign-hammer+beachhead-siege"] = {percent = 50, forbid={1}},
	["campaign-hammer+fields-of-hope"] = {percent = 30, forbid={5,6}},
}
class:bindHook(
	"Zone:loadEvents",
	function(self, data)
		if game:isAddonActive("cults") then
			if tentacle_zones[data.zone] then
				local d = tentacle_zones[data.zone]
				if type(d) ~= "table" then d = {percent=d} end
				data.events[#data.events+1] = {name="cults+tentacle-tree", minor=true, percent=d.percent, forbid=d.forbid}
			end
		end
		if game:isAddonActive("ashes-urhrok") then --redundant, but you can never have too many sanity checks
			if statue_zones[data.zone] then
				local d = statue_zones[data.zone]
				if type(d) ~= "table" then d = {percent=d} end
				data.events[#data.events+1] = {name="ashes-urhrok+demon-statue", minor=true, percent=d.percent, forbid=d.forbid}
			end
		end
	end
)


-- class:bindHook(
-- 	"GameOptions:generateList",
-- 	function(self, data)
-- 		if data.kind == "ui" then
-- 			local optShort = "Hammer"
			
-- 			local optTitle = "Hide Stick-figure Backgrounds"
-- 			local optText = [[Allows you to hide the original Hammer loading screen with its stick-figure demons and bright white background.]]
-- 			data.list[#data.list+1] = { 
-- 				zone=Textzone.new{
-- 					width=self.c_desc.w, 
-- 					height=self.c_desc.h,
-- 					text=string.toTString("#GOLD#"..optTitle.."\n\n#WHITE#"..optText.."#WHITE#")
-- 				},
				
-- 				name=string.toTString(("#GOLD##{bold}#[%s] %s#WHITE##{normal}#"):format(optShort, optTitle)),
				
-- 				status=function(item) 
-- 					return config.settings.censor_stick_figures and _t"enabled" or _t"disabled"
-- 				end, 
				
-- 				fct=function(item)
-- 					config.settings.censor_stick_figures = not config.settings.censor_stick_figures
-- 					game:saveSettings("censor_stick_figures", ("censor_stick_figures = %s\n"):format(tostring(config.settings.censor_stick_figures)))					
-- 					self.c_list:drawItem(item)
-- 				end,
-- 			}
--     end
-- end)
