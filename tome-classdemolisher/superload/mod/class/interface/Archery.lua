local _M = loadPrevious(...)

local Talents = require "engine.interface.ActorTalents"

local base_hasArcheryWeapon = _M.hasArcheryWeapon
function _M:hasArcheryWeapon(type, quickset)
	if self:knowTalent(self.T_REK_EVOLUTION_DEML_DRONE) then
		-- find ammo and shooters
		local ammo = table.get(self:getInven(quickset and "QS_QUIVER" or "QUIVER"), 1)
		if not ammo then return nil, "no ammo" end
		if not ammo.archery_ammo or not ammo.combat then return nil, "bad ammo" end

		local weapon = nil
		local offweapon = nil
		
		local t1 = self:getTalentFromId(self.T_REK_DEML_DRONE_GUNNER)
		local t2 = self:getTalentFromId(self.T_REK_EVOLUTION_DEML_DRONE)
		if self:isTalentActive(t1.id) then
			weapon = {
				name = "dronegun",
				power_source = {steam=true},
				type = "weapon", subtype="steamgun",
				display = "}", color=colors.UMBER,
				encumber = 0,
				metallic = true,
				combat = { talented = "dronegun", travel_speed=6, physspeed = 1, accuracy_effect="mace", sound = "actions/dual-steamgun", sound_miss = "actions/dual-steamgun", use_resources={steam = 2} },
				archery_kind = "steamgun",
				archery = "sling", -- Same ammunition as slings
				require = { talent = { Talents.T_STEAM_POOL}, },
				proj_image = resolvers.image_material("shot_s", "metal"),
				desc = _t[[Steamguns use bursts of steam directly injected in the barrel to propel metal shots with great force.]],
				material_level = 3,
				combat = {
					range = t1.range(self, t1),
					apr = 10,
				},
			}			
		end
		if self:isTalentActive(t2.id) then offweapon = weapon end
		return weapon, ammo, offweapon
	end
	return base_hasArcheryWeapon(self, type, quickset)
end

return _M
