local ActorTalents = require "engine.interface.ActorTalents"

damDesc = Talents.damDesc

techs_req1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_req2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_req3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_req4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_req5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end

gifts_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
gifts_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
gifts_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
gifts_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
gifts_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
gifts_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
gifts_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
gifts_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
gifts_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
gifts_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

color_req_1 = {
   stat = { wil=function(level) return 10 + (level-1) * 10 end },
   level = function(level) return 0 + (level-1) * 6 end,
}

numAspects = function(self)
   local num = -1
   local aspects = {
      self.T_REK_WYRMIC_FIRE,
      self.T_REK_WYRMIC_COLD,
      self.T_REK_WYRMIC_ELEC,
      self.T_REK_WYRMIC_SAND,
      self.T_REK_WYRMIC_ACID,
      self.T_REK_WYRMIC_VENM
   }
   for k, talent in pairs(aspects) do
      if self:knowTalent(talent) then
	 num = num + 1
      end
   end
   return num
end

aspect_req_1 = {
   stat = { wil=function(level) return 10 + (level-1) * 4 end },
   level = function(level) return 0 + (level-1) * 3 end,
}

elem_req_1 = {
   stat = { wil=function(level) return 12 + (level-1) * 2 end },
   level = function(level) return 0 + (level-1) end,
}
elem_req_2 = {
   stat = { wil=function(level) return 20 + (level-1) * 2 end },
   level = function(level) return 4 + (level-1) end,
}
elem_req_3 = {
   stat = { wil=function(level) return 28 + (level-1) * 2 end },
   level = function(level) return 8 + (level-1) end,
}
elem_req_4 = {
   stat = { wil=function(level) return 36 + (level-1) * 2 end },
   level = function(level) return 12 + (level-1) end,
}


function aspectIsActive(self, name)
   local possibles = self.rek_wyrmic_dragon_type or {}

   for k, element in pairs(possibles) do
      if element.name == name then
	 return true
      end
   end
   return false
end

function aspectByName(self, name)
   local possibles = self.rek_wyrmic_dragon_type or {}

   for k, element in pairs(possibles) do
      if element.name == name then
	 return element
      end
   end
   return {}
end

function swapAspectByName(self, name)
   if aspectIsActive(self, name) then
      local aspect_new = aspectByName(self, name)

      -- Do the breath cooldown
      if ( self:knowTalent(self.T_REK_WYRMIC_MULTICOLOR_GUILE)
	      and aspect_new ~= self.rek_wyrmic_dragon_damage
	      and not self:hasEffect(self.EFF_REK_WYRMIC_BREATH_RECOVERY)
      )
      then
	 local cd = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_GUILE, "CDreduce")
	 if not self:attr("no_talents_cooldown") then
	    for tid, _ in pairs(self.talents_cd) do
	       if tid == self.T_REK_WYRMIC_ELEMENT_BREATH then
		  local t = self:getTalentFromId(tid)
		  if t and not t.fixed_cooldown then
		     self.talents_cd[tid] = math.max(0, self.talents_cd[tid] - cd)
		     self:setEffect(self.EFF_REK_WYRMIC_BREATH_RECOVERY, 13, {})
		  end
	       end
	    end
	 end
      end
      -- Finally swap
      self.rek_wyrmic_dragon_damage = aspect_new
   end
end

function hasHigherAbility(self)
   local level = self:getTalentLevelRaw(self.T_REK_WYRMIC_FIRE_HEAL)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_COLD_WALL)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_ELEC_SHOCK)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_SAND_BURROW)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_ACID_AURA)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_VENM_PIN)
   if level > 1 then return true else return false end
end

function onLearnHigherAbility(self)
   local level = self:getTalentLevelRaw(self.T_REK_WYRMIC_FIRE_HEAL)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_COLD_WALL)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_ELEC_SHOCK)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_SAND_BURROW)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_ACID_AURA)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_VENM_PIN)
   if level == 1 then
      self.unused_talents_types = self.unused_talents_types - 1
   end
end

function onUnLearnHigherAbility(self)
   local level = self:getTalentLevelRaw(self.T_REK_WYRMIC_FIRE_HEAL)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_COLD_WALL)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_ELEC_SHOCK)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_SAND_BURROW)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_ACID_AURA)
      + self:getTalentLevelRaw(self.T_REK_WYRMIC_VENM_PIN)
   if level == 0 then
      self.unused_talents_types = self.unused_talents_types + 1
   end
end
   
if not Talents.talents_types_def["demented/wyrmic"] then
   newTalentType{ allow_random=false, is_spell=true, no_silence=true,
		  type="demented/wyrmic",
		  name = "Tentacle Dragon",
		  description = "Wyrmic techniques used when infested with otherworldly tentacles" }
end

if not Talents.talents_types_def["wild-gift/draconic-energy"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-energy",
		  name = "Draconic Energy",
		  description = "Fire breath, freezing claws - strike with the elemental power of a dragon." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-energy.lua")
end

if not Talents.talents_types_def["wild-gift/draconic-combat"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-combat",
		  name = "Draconic Combat",
		  description = "Fight like a dragon, with fang and claw." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-combat.lua")
end

if not Talents.talents_types_def["wild-gift/draconic-body"] then
   newTalentType{ allow_random=true, is_mind=true, is_nature=true,
		  type="wild-gift/draconic-body",
		  name = "Draconic Body",
		  description = "Scales and heart, the strength of the dragons." }
   load("/data-revamped-wyrmic/talents/gifts/draconic-body.lua")
end

-- if not Talents.talents_types_def["wild-gift/draconic-aspects"] then
--    newTalentType{ allow_random=true, is_mind=true, is_nature=true,
-- 		  type="wild-gift/draconic-aspects",
-- 		  name = "Draconic Aspects",
-- 		  description = "Fire, Ice, Storm, Acid, Venom, and Sand." }
--    load("/data-revamped-wyrmic/talents/gifts/draconic-aspects.lua")
-- end

-- if not Talents.talents_types_def["wild-gift/draconic-utility"] then
--    newTalentType{ allow_random=true, is_mind=true, is_nature=true,
-- 		  type="wild-gift/draconic-utility",
-- 		  name = "Draconic Skill",
-- 		  description = "Create and destroy walls, melt, burn, shock foes." }
--    load("/data-revamped-wyrmic/talents/gifts/draconic-utility.lua")
-- end

if not Talents.talents_types_def["wild-gift/prismatic-dragon"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/prismatic-dragon", name = "Prismatic Aspect", min_lev = 10, description = "Take on the power of the mighty multi-hued wyrms." }
   load("/data-revamped-wyrmic/talents/gifts/prismatic.lua")
end

if not Talents.talents_types_def["wild-gift/apex-predator"] then
   newTalentType{ allow_random=false, generic=true, is_mind=true, is_nature=true, type="wild-gift/apex-predator", name = "Apex Predator", description = "The strongest creature in nature is ... you." }
   load("/data-revamped-wyrmic/talents/gifts/apex-predator.lua")
end

-- Talent categories for the six elements
if not Talents.talents_types_def["wild-gift/wyrm-fire"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/wyrm-fire", name = "Fire Wyrm", description = "The power of the dragons: burning, ash, and desperation" }
   load("/data-revamped-wyrmic/talents/gifts/aspect-fire.lua")
end
if not Talents.talents_types_def["wild-gift/wyrm-ice"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/wyrm-ice", name = "Ice Wyrm", description = "The power of the dragons: armor and ice" }
   load("/data-revamped-wyrmic/talents/gifts/aspect-ice.lua")
end
if not Talents.talents_types_def["wild-gift/wyrm-storm"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/wyrm-storm", name = "Storm Wyrm", description = "The power of the dragons: shock and awe" }
   load("/data-revamped-wyrmic/talents/gifts/aspect-storm.lua")
end
if not Talents.talents_types_def["wild-gift/wyrm-sand"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/wyrm-sand", name = "Sand Wyrm", description = "The power of the dragons: crushing weight, eyeless sight" }
   load("/data-revamped-wyrmic/talents/gifts/aspect-sand.lua")
end
if not Talents.talents_types_def["wild-gift/wyrm-acid"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/wyrm-acid", name = "Acid Wyrm", description = "The power of the dragons: scour and dissolve" }
   load("/data-revamped-wyrmic/talents/gifts/aspect-acid.lua")
end
if not Talents.talents_types_def["wild-gift/wyrm-venom"] then
   newTalentType{ allow_random=false, is_mind=true, is_nature=true, type="wild-gift/wyrm-venom", name = "Venom Wyrm", description = "The power of the dragons: poison and pain" }
   load("/data-revamped-wyrmic/talents/gifts/aspect-venom.lua")
end
