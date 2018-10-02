-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newTalentType{ type="undead/mummy", name = "mummy", is_spell=true, generic = true, description = "The various racial bonuses an undead character can have."}
newTalentType{ type="undead/mummified", name = "mummified", is_spell=true, generic = true, description = "The special bonuses owed to preserved body parts."}
newTalentType{ type="undead/flammable", name = "flammable", is_spell=true, generic = true, description = "The drawbacks to being extremely dry and composed of cloth and oil."}

local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
undeads_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

-- Global jar cooldown
local function activate_jar(self, btid)
   for tid, lev in pairs(self.talents) do
      if tid ~= btid and self.talents_def[tid].type[1] == "undead/mummified" and (not self.talents_cd[tid] or self.talents_cd[tid] < 3) then
	 self.talents_cd[tid] = 3
      end
   end
end

--Was part of the initial release before I found out that races could have COPY-coded resistances
newTalent{
   short_name="MUMMY_FIRE_WEAKNESS",
   name = "Flammable",
   type = {"undead/flammable", 1},
   mode = "passive",
   require = undeads_req1,
   points = 1,
   no_energy = true,
   getFPenalty = function(self, t) return 50 end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "resists",{[DamageType.FIRE]= -1*t.getFPenalty(self, t)})
   end,
   info = function(self, t)
      return ([[The dried-out bodies of mummies are highly flammable, decreasing fire resistance by %0.1f%%]]):format(t.getFPenalty(self, t))
   end,
}

newTalent{
   short_name="MUMMY_EMBALM",
   name = "Embalming",
   type = {"undead/mummy", 1},
   mode = "passive",
   require = undeads_req1,
   points = 5,
   no_energy = true,
   statBonus = function(self, t)
      return math.ceil(self:combatTalentScale(t, 2, 10, 0.75))
   end,
   getFResist = function(self, t) return 10 * self:getTalentLevelRaw(t) end,
   getMaxDamage = function(self, t)
      return math.max(50, 100 - self:getTalentLevelRaw(t) * 10)
   end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "inc_stats", {[self.STAT_STR]=t.statBonus(self, t)})
      self:talentTemporaryValue(p, "inc_stats", {[self.STAT_WIL]=t.statBonus(self, t)})
      self:talentTemporaryValue(p, "resists",{[DamageType.FIRE]=t.getFResist(self, t)})
   end,
   info = function(self, t)
      return ([[Improves your mummified body and undying will, increasing Strength and Willpower by %d.  Modern embalming techniques mitigate your fire vulnerability, increasing fire resistance by %d%%]]):format(t.statBonus(self, t), t.getFResist(self, t))
   end,
}

newTalent{
   short_name = "MUMMY_ENTANGLE",
   name = "Entangle",
   type = {"undead/mummy", 2},
   require = undeads_req2,
   points = 5,
   cooldown = 3,
   no_energy = true,
   range = 1,
   is_melee = true,
   tactical = { DISABLE = 2 },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   speedPenalty = function(self, t) return self:combatTalentLimit(t, 1, 0.18, 0.33) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      target:setEffect(target.EFF_ENTANGLE, 5,
		       {src=self,
			speed = t.speedPenalty(self, t),
			dam=self:mindCrit(self:combatTalentMindDamage(t, 15, 250))})
      return true
   end,
   info = function(self, t)
      return ([[You animate part of your bindings and wrap them around a foe.
		The mummy wraps will constrict the target, slowing it by %d%% for 5 turns.]]):format(100*t.speedPenalty(self,t))
   end,
}

newTalent{
   short_name = "JAR_STOMACH",
   name = "Canopic-Stomach",
   type = {"undead/mummified", 1},
   require = undeads_req3,
   points = 1,
   no_energy = true,
   cooldown = 21,
   tactical = { BUFF = 1, CURE = function(self, t, target)
		   local nb = 0
		   for eff_id, p in pairs(self.tmp) do
		      local e = self.tempeffect_def[eff_id]
		      if e.status == "detrimental" and e.type == "mental" then
			 nb = nb + 1
		      end
		   end
		   return nb
   end,},
   getNumber = function(self, t) return self:combatTalentScale(t, 3, 10) end,
   action = function(self, t)
      local effs = {}
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.type == "mental" and e.status == "detrimental" then
	    effs[#effs+1] = {"effect", eff_id}
	 end
      end
      
      if #effs ~= 0 then
	 local eff = rng.tableRemove(effs)
      
	 if eff[1] == "effect" then
	    self:removeEffect(eff[2])
	 end
      end
      
      game:playSoundNear(self, "talents/heal")
      activate_jar(self, t.id)
      return true
   end,
   info = function(self, t)
      local number = t.getNumber(self, t)
      return ([[Draw upon your stomach, preserved in a canopic jar, and remember what it is to hunger.  The memories fill your mind, removing 1 detrimental mental effect.
Activating a jar is instant but places other jar talents on cooldown for 3 turns.]])
   end,
}

newTalent{
   short_name = "JAR_INTESTINE",
   name = "Canopic-Gut",
   type = {"undead/mummified", 1},
   require = undeads_req3,
   points = 1,
   no_energy = true,
   cooldown = 21,
   tactical = { BUFF = 1, CURE = function(self, t, target)
		   local nb = 0
		   for eff_id, p in pairs(self.tmp) do
		      local e = self.tempeffect_def[eff_id]
		      if e.status == "detrimental" and e.type == "magical" then
			 nb = nb + 1
		      end
		   end
		   return nb
   end,},
   getNumber = function(self, t) return self:combatTalentScale(t, 3, 10) end,

   action = function(self, t)
      local effs = {}
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.type == "magical" and e.status == "detrimental" then
	    effs[#effs+1] = {"effect", eff_id}
	 end
      end
      
      if #effs ~= 0 then
	 local eff = rng.tableRemove(effs)
      
	 if eff[1] == "effect" then
	    self:removeEffect(eff[2])
	 end
      end
      
      game:playSoundNear(self, "talents/heal")     
      activate_jar(self, t.id)
      return true
   end,
   info = function(self, t)
      local number = t.getNumber(self, t)
      return ([[Draw upon your intestines, preserved in a canopic jar, to remember living weighted by flesh and blood. This grounds you in the physical and real, removing 1 detrimental magical effect.
Activating a jar is instant but places other jar talents on cooldown for 3 turns.]])
   end,
}

newTalent{
   short_name = "JAR_LIVER",
   name = "Canopic-Blood",
   type = {"undead/mummified", 1},
   require = undeads_req3,
   points = 1,
   no_energy = true,
   cooldown = 21,
   tactical = { BUFF = 1, CURE = function(self, t, target)
		   local nb = 0
		   for eff_id, p in pairs(self.tmp) do
		      local e = self.tempeffect_def[eff_id]
		      if e.status == "physical" and e.type == "magical" then
			 nb = nb + 1
		      end
		   end
		   return nb
   end,},
   getNumber = function(self, t) return self:combatTalentScale(t, 3, 10) end,
   action = function(self, t)
            local effs = {}
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.type == "physical" and e.status == "detrimental" then
	    effs[#effs+1] = {"effect", eff_id}
	 end
      end
      
      if #effs ~= 0 then
	 local eff = rng.tableRemove(effs)
      
	 if eff[1] == "effect" then
	    self:removeEffect(eff[2])
	 end
      end
      
      game:playSoundNear(self, "talents/heal")
      activate_jar(self, t.id)
      return true
   end,
   info = function(self, t)
      local number = t.getNumber(self, t)
      return ([[Draw upon your liver, sealed in a canopic jar, and remember being whole and hale.  The memories purify your body, removing 1 detrimental physical effect.
Activating a jar is instant but places other jar talents on cooldown for 3 turns.]])
   end,
}

newTalent{
   short_name = "JAR_LUNG", 
   name = "Canopic-Breath",
   type = {"undead/mummified", 1},
   require = undeads_req4,
   points = 1,
   cooldown = 21,
   no_energy = true,
   is_heal = true,
   tactical = { HEAL = 2, MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PSI = 2, HATE = 2 },
   getConversion = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
   getData = function(self, t)
      local base = t.getConversion(self, t)
      return {
	 heal = base * 10,
	 stamina = base,
	 mana = base * 1.8,
	 positive = base / 2,
	 negative = base / 2,
	 psi = base * 0.7,
	 hate = base / 4,
      }
   end,
   action = function(self, t)
      local data = t.getData(self, t)
      for name, v in pairs(data) do
	 local inc = "inc"..name:capitalize()
	 if name == "heal" then
	    self:attr("allow_on_heal", 1)
	    self:heal(self:mindCrit(v), t)
	    self:attr("allow_on_heal", -1)
	 elseif
	 self[inc] then self[inc](self, v) 
	 end
      end
      game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
      game:playSoundNear(self, "talents/heal")
      activate_jar(self, t.id)
      return true
   end,
   info = function(self, t)
      local data = t.getData(self, t)
      return ([[Call upon your lungs, preserved in a canopic jar, and remember what it is like to breathe. The memories fill you with energy, healing you for %d life, and restoring %d stamina, %d mana,  %d positive and negative energies, %d psi energy, and %d hate.
		The heal and resource gain will improve with your Mindpower.
Activating a jar is instant but places other jar talents on cooldown for 3 turns]]):format(data.heal, data.stamina, data.mana, data.positive, data.psi, data.hate)
end,
}

newTalent{
   short_name = "MUMMY_CURSE",
   name = "Inevitability",
   type = {"undead/mummy", 3},
   require = undeads_req3,
   points = 5,
   tactical = { BUFF = 2 },
   mode = "passive",
   no_energy = true,
   getReductionMax = function(self, t) return math.floor(5 * self:combatTalentLimit(t, 19, 1.2, 4.1)) end, -- Limit to 95%
   getResistanceMax = function(self, t) return math.floor(5 * self:combatTalentLimit(t, 19, 1.2, 4.1)) end, -- Limit to 95%
   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
      if hitted then
	 target:setEffect(self.EFF_MUMMY_WEAKNESS, 3, {inc = - 3, max = - t.getReductionMax(self, t)})
      end
   end,
   callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
      if hitted then
	 target:setEffect(self.EFF_MUMMY_WEAKNESS, 3, {inc = - 3, max = - t.getReductionMax(self, t)})
      end
   end,

   callbackOnTakeDamage = function(self, t, src, x, y, damtype, dam, tmp)
      if not self:hasEffect(self.EFF_MUMMY_STRENGTH) then
	 self:setEffect(self.EFF_MUMMY_STRENGTH, 3, {inc = 3, max = t.getResistanceMax(self, t)})
      end
      local target = self
      for eff_id, p in pairs(target.tmp) do
	 local e = target.tempeffect_def[eff_id]
	 if e.name == "MUMMY_STRENGTH" then
	    if p.dur < 3 then
	       self:setEffect(self.EFF_MUMMY_STRENGTH, 3, {inc = 3, max = t.getResistanceMax(self, t)})
	    end
	 end
      end
      return {dam=dam}
   end,

   info = function(self, t)
      local reduction = t.getReductionMax(self, t)
      local resistance = t.getResistanceMax(self, t)
      return ([[Your triumph is inevitable; you overcame death and all lesser foes will eventually crumble before you.  
Each time you hit an opponent with an attack, you curse them, reducing their resistance to all damage by 3%%, up to a maximum of %d%%.
Each time you take damage, you resolve yourself to outlast this harm, increasing your resistance to damage by 3%% for 3 turns, stacking up to %d%%]]):format(reduction, resistance)
   end,
}

newTalent{
   short_name = "MUMMY_JAR",
   name = "Preserved Wholeness",
   type = {"undead/mummy", 4},
   require = undeads_req4,
   points = 1,
   mode = "passive",
   CDreduce = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 3, 5)) end,
   passives = function(self, t, p)
      local cdr = t.CDreduce(self, t)
      self:talentTemporaryValue(p, "talent_cd_reduction",
				{[Talents.T_JAR_STOMACH]=cdr, [Talents.T_JAR_INTESTINE]=cdr, [Talents.T_JAR_LUNG]=cdr,[Talents.T_JAR_LIVER]=cdr})
   end,
   info = function(self, t)
      --local number = t.getNumber(self, t)
      return ([[Though separated, your preserved body acts as one.  This talent reduces the cooldown of your canopic jar talents by %d turns.]]):format(t.CDreduce(self,t))
   end,
}
