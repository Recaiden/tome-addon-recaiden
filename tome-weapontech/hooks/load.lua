local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local PartyLore = require "mod.class.interface.PartyLore"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-weapontech/talents.lua')
end
class:bindHook('ToME:load', load)

local function insertWeaponSkills(obj, talents)
   if not obj.wielder then
      obj.wielder = {}
   end
	 if not obj.wielder.learn_talent then
		 obj.wielder.learn_talent = {}
	 end
	 for talent, levels in pairs(talents) do
		 obj.wielder.learn_talent[talent] = levels
	 end
end

local typeList = {
	["dagger"] = {["T_REK_WTEK_DAGGER_THOUSAND_CUTS"]=1,
								["T_REK_WTEK_DAGGER_ROLLING_STAB"]=1,
								["T_REK_WTEK_DAGGER_THROAT_SLITTER"]=1,
								["T_REK_WTEK_DAGGER_BLADE_RUSH"]=1},
}

class:bindHook(
	"Entity:loadList",
	function(self, data)
		-- Attach skills to weapons
		for _,obj in pairs(data.res) do
			if type(obj) == "table" then
				if typeList[obj.subtype] then
					insertWeaponSkills(obj, typeList[obj.subtype])
				end
			end
		end		
	end
)
