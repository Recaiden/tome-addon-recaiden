local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

amSane = function(self)
   return self:getInsanity() <= 40
end

amInsane = function(self)
   return self:getInsanity() >= 60
end

local oldNewTalent = Talents.newTalent
Talents.newTalent = function(self, t)	
	if t.extra_image_sane then
		if fs.exists(Tiles.baseImageFile(t.extra_image_sane)) then
			t.display_entity_sane = Entity.new{image=t.extra_image_sane, is_talent=true}
		else
			t.display_entity_sane = Entity.new{image="talents/default.png", is_talent=true}
		end
		if fs.exists(Tiles.baseImageFile(t.extra_image_semisane)) then
			t.display_entity_semisane = Entity.new{image=t.extra_image_semisane, is_talent=true}
		else
			t.display_entity_semisane = Entity.new{image="talents/default.png", is_talent=true}
		end
		if fs.exists(Tiles.baseImageFile(t.extra_image_insane)) then
			t.display_entity_insane = Entity.new{image=t.extra_image_insane, is_talent=true}
		else
			t.display_entity_insane = Entity.new{image="talents/default.png", is_talent=true}
		end
	end
	return oldNewTalent(self, t)
end


sling_req1 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
      stat = { [stat]=function(level) return 10 + (level-1) * 6 end },
      level = function(level) return 0 + (level-1)  end,
      special = {
         desc=_t"Uses the higher of your Strength or Dexterity",
         fct=function(self) return true end
      },
   } end

sling_req2 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return { 
      stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
      level = function(level) return 4 + (level-1)  end,
      special = {
         desc=_t"Uses the higher of your Strength or Dexterity",
         fct=function(self) return true end
      },
}end
sling_req3 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return { 
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
        special = {
           desc=_t"Uses the higher of your Strength or Dexterity",
           fct=function(self) return true end
        },
}end
sling_req4 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
      stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
      level = function(level) return 12 + (level-1)  end,
      special = {
         desc=_t"Uses the higher of your Strength or Dexterity",
         fct=function(self) return true end
      },
} end
sling_reqMaster = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {      
      stat = { [stat]=function(level) return 10 + (level-1) * 6 end },
      level = function(level) return 0 + (level-1)  end,
      special = {
         desc=_t"Uses the higher of your Strength or Dexterity",
         fct=function(self) return true end
      },
}end

martyr_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
martyr_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
martyr_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
martyr_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
martyr_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
martyr_req_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
martyr_req_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
martyr_req_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
martyr_req_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
martyr_req_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}
str_req_high1 = {
	stat = { str=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
str_req_high2 = {
	stat = { str=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
str_req_high3 = {
	stat = { str=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
str_req_high4 = {
	stat = { str=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

wil_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
wil_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
wil_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
wil_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

canLearnMirror = function(self)
   local countVagabond = self:getTalentLevelRaw(self.T_REK_MTYR_VAGABOND_SLING_PRACTICE)
      + self:getTalentLevelRaw(self.T_REK_MTYR_VAGABOND_STAGGER_SHOT)
      + self:getTalentLevelRaw(self.T_REK_MTYR_VAGABOND_TAINTED_BULLETS)
      + self:getTalentLevelRaw(self.T_REK_MTYR_VAGABOND_HOLLOW_SHELL)
   
   local countChivalry = self:getTalentLevelRaw(self.T_REK_MTYR_CHIVALRY_CHAMPIONS_FOCUS)
      + self:getTalentLevelRaw(self.T_REK_MTYR_CHIVALRY_LANCERS_CHARGE)
      + self:getTalentLevelRaw(self.T_REK_MTYR_CHIVALRY_EXECUTIONERS_ONSLAUGHT)
      + self:getTalentLevelRaw(self.T_REK_MTYR_CHIVALRY_HEROS_RESOLVE)
   return countChivalry < countVagabond
end

martyr_mirror_req1 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {      
   stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
   level = function(level) return 0 + (level-1) end,
   special = {
      desc=_t"Uses the higher of your Strength or Dexterity",
      fct=function(self) return canLearnMirror(self) end
   },
   special2 = {
      desc=_t"Points in Vagabond talents allow you to learn Chivalry talents",
      fct=function(self) return canLearnMirror(self) end
   },
} end

martyr_mirror_req2 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {      
   stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
   level = function(level) return 4 + (level-1) end,
   special = {
      desc=_t"Uses the higher of your Strength or Dexterity",
      fct=function(self) return canLearnMirror(self) end
   },
   special2 = {
      desc=_t"Points in Vagabond talents allow you to learn Chivalry talents",
      fct=function(self) return canLearnMirror(self) end
   },
}end

martyr_mirror_req3 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {      
   stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
   level = function(level) return 8 + (level-1) end,
   special = {
      desc=_t"Uses the higher of your Strength or Dexterity",
      fct=function(self) return canLearnMirror(self) end
   },
   special2 = {
      desc=_t"Points in Vagabond talents allow you to learn Chivalry talents",
      fct=function(self) return canLearnMirror(self) end
   },
}end

martyr_mirror_req4 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {      
   stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
   level = function(level) return 12 + (level-1) end,
   special = {
      desc=_t"Uses the higher of your Strength or Dexterity",
      fct=function(self) return canLearnMirror(self) end
   },
   special2 = {
      desc=_t"Points in Vagabond talents allow you to learn Chivalry talents",
      fct=function(self) return canLearnMirror(self) end
   },
}end

archerPreUse = Talents.main_env.archerPreUse
archeryWeaponCheck = function(self, weapon, ammo, silent, weapon_type)
   if not weapon then
      if not silent then
         -- ammo contains error message
         game.logPlayer(self, ({
                                  ["disarmed"] = _t"You are currently disarmed and cannot use this talent.",
                                  ["no shooter"] = ("You require a %s to use this talent."):tformat(weapon_type or "missile launcher"),
                                  ["no ammo"] = _t"You require ammo to use this talent.",
                                  ["bad ammo"] = _t"Your ammo cannot be used.",
                                  ["incompatible ammo"] = _t"Your ammo is incompatible with your missile launcher.",
                                  ["incompatible missile launcher"] = ("You require a %s to use this talent."):tformat(weapon_type or "bow"),
                               })[ammo] or _t"You require a missile launcher and ammo for this talent.")
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
      weapon, ammo = doMartyrPreUse(self, "sling")
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

if not Talents.talents_types_def["demented/chivalry"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/chivalry", name = _t("Chivalry", "talent type"), description = _t"Onward, to greater challenges, for glory!" }
   load("/data-classmartyr/talents/chivalry.lua")
end

if not Talents.talents_types_def["demented/vagabond"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/vagabond", name = _t("Vagabond", "talent type"), description = _t"I'm not the only one seeing this, right?" }
   load("/data-classmartyr/talents/vagabond.lua")
end

if not Talents.talents_types_def["demented/whispers"] then
   newTalentType{ allow_random=true, type="demented/whispers", name = _t("Beinagrind Whispers", "talent type"), description = _t"Exist on the edge of madness", is_mind=true }
   load("/data-classmartyr/talents/whispers.lua")
end

if not Talents.talents_types_def["demented/unsettling"] then
   newTalentType{ allow_random=true, type="demented/unsettling", name = _t("Unsettling Words", "talent type"), description = _t"Distort your enemies' perceptions and fray their sanity.", is_mind=true }
   load("/data-classmartyr/talents/unsettling.lua")
end

if not Talents.talents_types_def["demented/polarity"] then
   newTalentType{ allow_random=true, is_mind=true, generic=true, type="demented/polarity", name = _t("Polarity", "talent type"), description = _t"Dive into the madness; power comes at the price of sanity" }
   load("/data-classmartyr/talents/polarity.lua")
end

if not Talents.talents_types_def["demented/scourge"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/scourge", name = _t("Scourge", "talent type"), description = _t"We will fight; you are but a vessel." }
   load("/data-classmartyr/talents/scourge.lua")
end

if not Talents.talents_types_def["demented/standard-bearer"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/standard-bearer", name = _t("Standard-Bearer", "talent type"), description = _t"To he who is victorious, ever more victories will flow!" }
   load("/data-classmartyr/talents/standard-bearer.lua")
end

if not Talents.talents_types_def["demented/moment"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/moment", name = _t("Final Moment", "talent type"), min_lev = 10, description = _t"Wield the blade of the ancient kings, and you will never be late nor lost." }
   load("/data-classmartyr/talents/moment.lua")
end

if not Talents.talents_types_def["psionic/crucible"] then
   newTalentType{ allow_random=true, is_mind=true, type="psionic/crucible", name = _t("Crucible", "talent type"), min_lev = 10, description = _t"Pain brings clarity.  To see clearly is painful." }
   load("/data-classmartyr/talents/crucible.lua")
end

if not Talents.talents_types_def["demented/revelation"] then
   newTalentType{ allow_random=true, is_mind=true, type="demented/revelation", name = _t("Revelation", "talent type"), min_lev = 10, description = _t"You see the world as it truly is, Eyal in the Age of Scourge.  The world is horrid, but the truth has power." }
   load("/data-classmartyr/talents/revelation.lua")
end
