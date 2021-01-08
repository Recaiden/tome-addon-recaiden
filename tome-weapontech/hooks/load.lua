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
	["longsword"] = {["T_REK_WTEK_SWORD_LUNGE"]=1,
									 ["T_REK_WTEK_SWORD_POMMEL_STRIKE"]=1,
									 ["T_REK_WTEK_SWORD_BREEZEBLADE"]=1,
									 ["T_REK_WTEK_SWORD_OVERWHELM"]=1},
	["waraxe"] = {["T_REK_WTEK_AXE_ARTERIAL_CUT"]=1,
								["T_REK_WTEK_AXE_SHIELDSHATTER"]=1,
								["T_REK_WTEK_AXE_BREEZEBLADE"]=1,
								["T_REK_WTEK_AXE_RENDING"]=1},
	["mace"] = {["T_REK_WTEK_MACE_DAZING_BLOW"]=1,
							["T_REK_WTEK_MACE_EARTHSHAKER"]=1,
							["T_REK_WTEK_MACE_BREEZEHAMMER"]=1,
							["T_REK_WTEK_MACE_BONEGRINDER"]=1},
	["greatsword"] = {["T_REK_WTEK_GREATSWORD_THRUST"]=1,
										["T_REK_WTEK_GREATSWORD_MORDHAU"]=1,
										["T_REK_WTEK_GREATSWORD_GUSTBLADE"]=1,
										["T_REK_WTEK_GREATSWORD_LANCE"]=1},
	["battleaxe"] = {["T_REK_WTEK_BATTLEAXE_HEWING_BLADES"]=1,
										["T_REK_WTEK_BATTLEAXE_WILD_SWING"]=1,
										["T_REK_WTEK_BATTLEAXE_GUSTBLADE"]=1,
										["T_REK_WTEK_BATTLEAXE_WHIRLWIND"]=1},
	--maul
	--shield
	--whip
	--trident
	--psiblade?
	--staff???
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
