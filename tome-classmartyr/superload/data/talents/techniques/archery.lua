local _M = loadPrevious(...)

local Map = require "engine.Map"

archerPreUse = Talents.main_env.archerPreUse
archeryWeaponCheck = function(self, weapon, ammo, silent, weapon_type)
   if not weapon then
      if not silent then
         -- ammo contains error message
         game.logPlayer(self, ({
                                  ["disarmed"] = "You are currently disarmed and cannot use this talent.",
                                  ["no shooter"] = ("You require a %s to use this talent."):format(weapon_type or "missile launcher"),
                                  ["no ammo"] = "You require ammo to use this talent.",
                                  ["bad ammo"] = "Your ammo cannot be used.",
                                  ["incompatible ammo"] = "Your ammo is incompatible with your missile launcher.",
                                  ["incompatible missile launcher"] = ("You require a %s to use this talent."):format(weapon_type or "bow"),
                               })[ammo] or "You require a missile launcher and ammo for this talent.")
      end
      return false
   else
      local infinite = ammo and ammo.infinite or self:attr("infinite_ammo")
      if not ammo or (ammo.combat.shots_left <= 0 and not infinite) then
         if not silent then game.logPlayer(self, "You do not have enough ammo left!") end
         return false
      end
   end
   return true
end

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

martyrPreUse = function(self, t, silent, weapon_type)
   local weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeapon(weapon_type)
   weapon = weapon or pf_weapon
   if self:attr("martyr_swap") and not weapon and weapon_type == nil or weapon_type == "sling" then
      weapon, ammo = doMartyrPreUse(self, "sling", silent)
   end
   return archeryWeaponCheck(self, weapon, ammo, silent, weapon_type)
end

doMartyrPreUse = function(self, weapon, silent)
   if weapon == "sling" then
      local bow, ammo, oh, pf_bow= self:hasArcheryWeapon("sling")
      if not bow and not pf_bow then
         bow, ammo, oh, pf_bow= self:hasArcheryWeaponQS("sling")
      end
      return bow or pf_bow, ammo
   end
   if weapon == "melee" then
      local mh, oh = self:hasDualWeapon()
      if not mh then
         mh, oh = self:hasDualWeaponQS()
      end
      return mh, oh
   end
end

base_preuse = Talents.talents_def.T_SHOOT.on_pre_use
Talents.talents_def.T_SHOOT.on_pre_use = function(self, t, silent)
   if self:attr("martyr_swap") then
      return martyrPreUse(self, t, silent, "sling")
   end
   return base_preuse(self, t, silent)
end

base_action = Talents.talents_def.T_SHOOT.action
Talents.talents_def.T_SHOOT.action = function(self, t)
   doMartyrWeaponSwap(self, "sling", true)
   return base_action(self, t)
end

return _M
