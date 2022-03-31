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

-- local function insertWeaponSkills(obj, talents)
--    if not obj.wielder then
--       obj.wielder = {}
--    end
-- 	 if not obj.wielder.learn_talent then
-- 		 obj.wielder.learn_talent = {}
-- 	 end
-- 	 for talent, levels in pairs(talents) do
-- 		 obj.wielder.learn_talent[talent] = levels
-- 	 end
-- end

local typeList = {
	["dagger"] = {"T_REK_WTEK_DAGGER_THOUSAND_CUTS",
								"T_REK_WTEK_DAGGER_ROLLING_STAB",
								"T_REK_WTEK_DAGGER_THROAT_SLITTER",
								"T_REK_WTEK_DAGGER_BLADE_RUSH"},
	["longsword"] = {"T_REK_WTEK_SWORD_LUNGE",
									 "T_REK_WTEK_SWORD_POMMEL_STRIKE",
									 "T_REK_WTEK_SWORD_BREEZEBLADE",
									 "T_REK_WTEK_SWORD_OVERWHELM"},
	["waraxe"] = {"T_REK_WTEK_AXE_ARTERIAL_CUT",
								"T_REK_WTEK_AXE_SHIELDSHATTER",
								"T_REK_WTEK_AXE_BREEZEBLADE",
								"T_REK_WTEK_AXE_RENDING"},
	["mace"] = {"T_REK_WTEK_MACE_DAZING_BLOW",
							"T_REK_WTEK_MACE_EARTHSHAKER",
							"T_REK_WTEK_MACE_BREEZEHAMMER",
							"T_REK_WTEK_MACE_BONEGRINDER"},
	["greatsword"] = {"T_REK_WTEK_GREATSWORD_THRUST",
										"T_REK_WTEK_GREATSWORD_MORDHAU",
										"T_REK_WTEK_GREATSWORD_GUSTBLADE",
										"T_REK_WTEK_GREATSWORD_LANCE"},
	["battleaxe"] = {"T_REK_WTEK_BATTLEAXE_HEWING_BLADES",
										"T_REK_WTEK_BATTLEAXE_WILD_SWING",
										"T_REK_WTEK_BATTLEAXE_GUSTBLADE",
										"T_REK_WTEK_BATTLEAXE_WHIRLWIND"},
	["greatmaul"] = {"T_REK_WTEK_GREATMAUL_CRUSH",
										"T_REK_WTEK_GREATMAUL_EARTHSHAKER",
										"T_REK_WTEK_GREATMAUL_GUSTBLADE",
										"T_REK_WTEK_GREATMAUL_GUARD"},
	["shield"] = {"T_REK_WTEK_SHIELD_BASH",
								"T_REK_WTEK_SHIELD_TOSS",
								"T_REK_WTEK_SHIELD_BASH",
								"T_REK_WTEK_SHIELD_TOSS"},
	["trident"] = {"T_REK_WTEK_TRIDENT_PIERCE",
								 "T_REK_WTEK_TRIDENT_IMPALER",
								 "T_REK_WTEK_TRIDENT_GUSTBLADE",
								 "T_REK_WTEK_TRIDENT_VAULT"},
	["whip"] = {"T_REK_WTEK_WHIP_WHIPCRACK",
							"T_REK_WTEK_WHIP_WREST",
							"T_REK_WTEK_WHIP_ENCOIL",
							"T_REK_WTEK_WHIP_LASH"},
	--psiblade?
	--staff???
}

class:bindHook(
	"Actor:onWear",
	function(self, data)
		local obj = data.o
		local inven_id = data.inven_id
		game.logPlayer(self, "Inven is %s - %s", obj, inven_id)
		talentSublist = typeList[obj.subtype]
		if talentSublist then
			if inven_id == "MAINHAND" then
				obj.wielder = obj.wielder or {}
				obj.wielder.learn_talent = obj.wielder.learn_talent or {}
				obj.wielder.learn_talent[talentSublist[1]] = 1
				obj.wielder.learn_talent[talentSublist[2]] = 1
				if obj.twohanded then
					obj.wielder.learn_talent[talentSublist[3]] = 1
					obj.wielder.learn_talent[talentSublist[4]] = 1
				end
			elseif inven_id == "OFFHAND" then
				obj.wielder = obj.wielder or {}
				obj.wielder.learn_talent = obj.wielder.learn_talent or {}
				obj.wielder.learn_talent[talentSublist[3]] = 1
				obj.wielder.learn_talent[talentSublist[4]] = 1
				if obj.twohanded then -- addons letting you offhand a two-hander
					obj.wielder.learn_talent[talentSublist[1]] = 1
					obj.wielder.learn_talent[talentSublist[2]] = 1
				end
			end
		end
	end
)

-- class:bindHook(
-- 	"Entity:loadList",
-- 	function(self, data)
-- 		-- Attach skills to weapons
-- 		for _,obj in pairs(data.res) do
-- 			if type(obj) == "table" then
-- 				if typeList[obj.subtype] then
-- 					insertWeaponSkills(obj, typeList[obj.subtype])
-- 				end
-- 			end
-- 		end		
-- 	end
-- )
