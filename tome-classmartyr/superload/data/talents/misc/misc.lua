local _M = loadPrevious(...)

local Map = require "engine.Map"

hasMeleeWeapon = function(self, quickset)
   if self:attr("disarmed") then
      return nil, "disarmed"
   end
   local weapon = table.get(self:getInven(quickset and "QS_MAINHAND" or "MAINHAND"), 1)
   if weapon and weapon.combat and not weapon.archery_kind then
      return true
   end
   return nil
end

canMartyrRanged = function(self)
   return self:hasArcheryWeapon("sling") or self:hasArcheryWeaponQS("sling")
end

canMartyrMelee = function(self)
   return hasMeleeWeapon(self) or hasMeleeWeapon(self, true)
end

-- Swaps weapons if needed
doMartyrWeaponSwap = function(self, type, silent)
	if not self:attr("martyr_swap") then return false end	
	local swap = false
	local mainhand, offhand, ammo, pf_weapon
	
	if type == "melee" then
		if not hasMeleeWeapon(self) and hasMeleeWeapon(self, true) then
			swap = true
		end
	end
	if type == "sling" then
		mainhand, offhand, ammo, pf_weapon = self:hasArcheryWeapon("sling")
		if not mainhand and not pf_weapon then
			mainhand, offhand, ammo, pf_weapon = self:hasArcheryWeapon("sling", true)
			if mainhand or pf_weapon then swap = true end
		end
	end
	
	if swap == true then
		local old_inv_access = self.no_inventory_access
		self.no_inventory_access = nil
		self:attr("no_sound", 1)
		self:quickSwitchWeapons(true, "martyr", silent)
		self:attr("no_sound", -1)
		self.no_inventory_access = old_inv_access
	end
	return swap
end

base_action = Talents.talents_def.T_ATTACK.action
Talents.talents_def.T_ATTACK.action = function(self, t)
   doMartyrWeaponSwap(self, "melee", true)
   return base_action(self, t)
end

return _M
