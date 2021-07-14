local class = require"engine.class"
local DamageType = require "engine.DamageType"
local Shader = require "engine.Shader"
local UIBase = require "engine.ui.Base"

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

