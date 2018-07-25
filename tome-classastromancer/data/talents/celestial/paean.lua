-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Object = require "mod.class.Object"
require "math"

-- Close Combat paean, wants you to be in meteor range
newTalent{
   name = "Paean of Volcanic Fire", short_name="WANDER_PAEAN_KOLAL",
   type = {"celestial/other", 1},
   mode = "sustained",
   hide = true,
   require = divi_req1,
   points = 5,
   cooldown = 12,
   sustain_negative = 20,
   no_energy = true,
   dont_provide_pool = true,
   tactical = { BUFF = 2 },
   range = 0,
   getDamageChange = function(self, t)
      return -self:combatTalentLimit(t, 50, 14, 30) -- Limit < 50% damage reduction
   end,

   callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp, no_martyr)
      if src and src.x and src.y then
	 -- assume instantaneous projection and check range to source
	 if core.fov.distance(self.x, self.y, src.x, src.y) < 5 then
	    dam = dam * (100 + t.getDamageChange(self, t)) / 100
	    print("[PROJECTOR] Paean of Fire (source) dam", dam)
	 end
      end
      return {dam=dam}
   end,
   sustain_slots = 'celestial_paean',
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      ret.particle = self:addParticles(Particles.new("wander_shield_kolal", 1))

      --Fire shield
      if self:knowTalent(self.T_WANDER_PAEAN_FIRESHIELD) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_FIRESHIELD)
	 self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.FIRE]=t2.getDamageOnMeleeHit(self, t2)})
	 self:talentTemporaryValue(ret, "combat_spellpower", t2.getSpellpowerIncrease(self, t2))
      end

      --Adept Upgrade
      if self:knowTalent(self.T_WANDER_PAEAN_PLANET2) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PLANET2)
	 self:talentTemporaryValue(ret, "combat_atk", t2.getAcc(self, t2))
	 self:talentTemporaryValue(ret, "damage_affinity", {[DamageType.FIRE] = t2.getAffinity(self, t2)})
      end

      --resPen upgrade
      if self:knowTalent(self.T_WANDER_PAEAN_PENETRATION) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PENETRATION)
	 self:talentTemporaryValue(ret, "resists_pen", {[DamageType.FIRE] = t2.getResistPenalty(self, t2)})
      end
      
      return ret
   end,
   deactivate = function(self, t, p)
      self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[You sing a paean to Kolal, protecting you from the clash of combat, reducing damage from enemies within 4 spaces by %d%%.
		You may only have one Paean active at once.
		The effects will increase with your Spellpower.]]):
	 format(-t.getDamageChange(self, t))
   end,
}

-- Pure defensive paean
newTalent{
   name = "Paean of Glacial Ice", short_name="WANDER_PAEAN_LUXAM",
   type = {"celestial/other", 1},
   mode = "sustained",
   hide = true,
   require = divi_req1,
   points = 5,
   cooldown = 12,
   sustain_positive = 20,
   no_energy = true,
   dont_provide_pool = true,
   tactical = { BUFF = 2 },
   range = 0,
   getResists = function(self, t) return self:combatTalentScale(t, 10, 32, 0.75) end,
   sustain_slots = 'celestial_paean',
   activate = function(self, t)
      local power = t.getResists(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      local ret = {}
      self:talentTemporaryValue(ret, "ignore_direct_crits", t.getResists(self, t))
      ret.particle = self:addParticles(Particles.new("wander_shield_luxam", 1))
      
      --Fire shield
      if self:knowTalent(self.T_WANDER_PAEAN_FIRESHIELD) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_FIRESHIELD)
	 self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.COLD]=t2.getDamageOnMeleeHit(self, t2)})
	 self:talentTemporaryValue(ret, "combat_spellpower", t2.getSpellpowerIncrease(self, t2))
      end

      --Adept Upgrade
      if self:knowTalent(self.T_WANDER_PAEAN_PLANET2) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PLANET2)
	 self:talentTemporaryValue(ret, "damage_affinity", {[DamageType.COLD] = t2.getAffinity(self, t2)})
      end

      --resPen upgrade
      if self:knowTalent(self.T_WANDER_PAEAN_PENETRATION) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PENETRATION)
	 self:talentTemporaryValue(ret, "resists_pen", {[DamageType.COLD] = t2.getResistPenalty(self, t2)})
      end
      
      return ret
   end,

   -- other part of adept upgrade
   callbackOnActBase = function(self, t)
      if self:knowTalent(self.T_WANDER_PAEAN_PLANET2) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PLANET2)

	 if self:hasEffect(self.EFF_DAMAGE_SHIELD) then
	    -- Shields can't usually merge, so change the parameters manually
	    local shield = self:hasEffect(self.EFF_DAMAGE_SHIELD)
	    local shield_power = t2.getShield(self, t2)
	    
	    shield.power = shield.power + shield_power
	    self.damage_shield_absorb = self.damage_shield_absorb + shield_power
	    self.damage_shield_absorb_max = self.damage_shield_absorb_max + shield_power 
	 end
      end
   end,
   
   deactivate = function(self, t, p)
      self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[You sing a paean to Luxam, granting you %d%% chance to ignore incoming critical hits.
		You may only have one Paean active at once.
		The effects will increase with your Spellpower.]]):
      format(t.getResists(self, t))
   end,
}

-- Healing-synergy paean, gives you more time to use your healing
newTalent{
   name = "Paean of Cleansing Wind",  short_name="WANDER_PAEAN_PONX",
   type = {"celestial/other",1},
   mode = "sustained",
   hide = true,
   require = divi_req1,
   points = 5,
   cooldown = 12,
   sustain_positive = 20,
   dont_provide_pool = true,
   tactical = { BUFF = 2 },
   no_energy = true,
   range = 0,
   getDieat =  function(self, t) return math.floor(self:combatTalentScale(t, 30, 200)) end,
   sustain_slots = 'celestial_paean',
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      local ret = {}
      self:talentTemporaryValue(ret, "die_at", -t.getDieat(self,t))
      ret.particle = self:addParticles(Particles.new("wander_shield_ponx", 1))
      
      --Fire shield
      if self:knowTalent(self.T_WANDER_PAEAN_FIRESHIELD) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_FIRESHIELD)
	 self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.LIGHTNING]=t2.getDamageOnMeleeHit(self, t2)})
	 self:talentTemporaryValue(ret, "combat_spellpower", t2.getSpellpowerIncrease(self, t2))
      end
      
      --Adept Upgrade
      if self:knowTalent(self.T_WANDER_PAEAN_PLANET2) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PLANET2)
	 self:talentTemporaryValue(ret, "combat_physresist", t2.getSaves(self, t2))
	 self:talentTemporaryValue(ret, "combat_mentalresist", t2.getSaves(self, t2))
	 self:talentTemporaryValue(ret, "combat_spellresist", t2.getSaves(self, t2))
	 self:talentTemporaryValue(ret, "damage_affinity", {[DamageType.LIGHTNING] = t2.getAffinity(self, t2)})
      end
      
      --resPen upgrade
      if self:knowTalent(self.T_WANDER_PAEAN_PENETRATION) then
	 local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_PENETRATION)
	 self:talentTemporaryValue(ret, "resists_pen", {[DamageType.LIGHTNING] = t2.getResistPenalty(self, t2)})
      end
      
      return ret
   end,
   
   deactivate = function(self, t, p)
      self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[You chant the glory of the Sun, increasing your negative life threshold by %d.
	You may only have one Paean active at once.
	The effects will increase with your Spellpower.]]):
	 format(t.getDieat(self, t))
   end,
}

newTalent{
   name = "Paean Acolyte", short_name = "WANDER_PAEAN_PLANET",

   type = {"celestial/paeans", 1},
   require = divi_req1,
   points = 5,
   mode = "passive",
   on_learn = function(self, t)
      self:learnTalent(self.T_WANDER_PAEAN_KOLAL, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_WANDER_PAEAN_LUXAM, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_WANDER_PAEAN_PONX, true, nil, {no_unlearn=true})
   end,
   on_unlearn = function(self, t)
      self:unlearnTalent(self.T_WANDER_PAEAN_KOLAL)
      self:unlearnTalent(self.T_WANDER_PAEAN_LUXAM)
      self:unlearnTalent(self.T_WANDER_PAEAN_PONX)
   end,
   info = function(self, t)
      local ret = ""
      local old1 = self.talents[self.T_WANDER_PAEAN_KOLAL]
      local old2 = self.talents[self.T_WANDER_PAEAN_LUXAM]
      local old3 = self.talents[self.T_WANDER_PAEAN_PONX]
      self.talents[self.T_WANDER_PAEAN_KOLAL] = (self.talents[t.id] or 0)
      self.talents[self.T_WANDER_PAEAN_LUXAM] = (self.talents[t.id] or 0)
      self.talents[self.T_WANDER_PAEAN_PONX] = (self.talents[t.id] or 0)
      pcall(function() -- Be very paranoid, even if some addon or whatever manage to make that crash, we still restore values
	    local t1 = self:getTalentFromId(self.T_WANDER_PAEAN_KOLAL)
	    local t2 = self:getTalentFromId(self.T_WANDER_PAEAN_LUXAM)
	    local t3 = self:getTalentFromId(self.T_WANDER_PAEAN_PONX)
	    ret = ([[You have learned to sing the praises of the Spheres, in the form of three defensive Paeans.
			Paean of Volcanic Fire: Reduces all damage that comes from nearby enemies (4 or fewer spaces) by %d%%
			Paean of Glacial Ice: Reduces the bonus damage critical hits do to you by %d percentage points.
			Paean of Cleansing Wind: Increases your negative health threshold by %d.
			You may only have one Paean active at a time.]]):
	       format(t1.getDamageChange(self, t1), t2.getResists(self, t2), t3.getDieat(self, t3))
      end)
      self.talents[self.T_WANDER_PAEAN_KOLAL] = old1
      self.talents[self.T_WANDER_PAEAN_LUXAM] = old2
      self.talents[self.T_WANDER_PAEAN_PONX] = old3
      return ret
   end,
}

newTalent{
   name = "Paean Orator", short_name = "WANDER_PAEAN_FIRESHIELD",
   type = {"celestial/paeans", 2},
   require = divi_req2,
   points = 5,
   mode = "passive",
   getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
   getSpellpowerIncrease = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
   info = function(self, t)
      return ([[Your Paeans now cover you in a shield of elemental energy, which increases your spellpower by %d and does %0.2f damage of the associated element to anyone who hits you in melee.
		The elemental shield scales with your Spellpower.]]):format(t.getSpellpowerIncrease(self, t), t.getDamageOnMeleeHit(self, t))
   end,
}

newTalent{
   name = "Paean Adept", short_name = "WANDER_PAEAN_PLANET2",
   type = {"celestial/paeans", 3},
   require = divi_req3,
   points = 5,
   mode = "passive",
   getAffinity = function(self, t) return self:combatTalentLimit(t, 100, 10, 50) end, -- Limit < 100%
   getAcc = function(self, t) return self:combatTalentScale(t, 20, 50, 0.75) end,
   getShield = function(self, t) return 7 + self:combatSpellpower(0.056) * self:combatTalentScale(t, 1, 4)  end,
   getSaves = function(self, t) return self:getTalentLevel(t)*3.5 end,
   info = function(self, t)
      return ([[Your skill at singing paeans now extends the elemental cloak, increasing your affinity for the associated element by %d.
		Also, each Paean has an additional effect while it's active.
		Paean of Volcanic Fire increase your Accuracy by %d.
		Paean of Glacial Ice reinforces existing damage shields by %d each turn.
		Paean of Cleansing Wind increases all your saves by %d ]]):format(t.getAffinity(self, t), t.getAcc(self, t), t.getShield(self, t), t.getSaves(self, t))
   end,
}

newTalent{
   name = "Paean Maelstrom", short_name = "WANDER_PAEAN_PENETRATION",
   type = {"celestial/paeans", 4},
   require = divi_req4,
   points = 5,
   mode = "passive",
   getBonusRegen = function(self, t) return self:combatTalentScale(t, 1.0, 3.0) end,
   getResistPenalty = function(self, t) return self:combatTalentLimit(t, 100, 17, 50) end,

   callbackOnTalentPost = function(self, t, ab)
      if not ab.type[1]:find("^celestial/") then return end
      if not self:isTalentActive(self.T_WANDER_PAEAN_KOLAL) and not self:isTalentActive(self.T_WANDER_PAEAN_LUXAM) and not self:isTalentActive(self.T_WANDER_PAEAN_PONX) then return end
      self:incNegative(t.getBonusRegen(self, t))
   end,
   
   info = function(self, t)
      return ([[Your passion for singing the praises of the spheres reaches its zenith.
		Your Paeans now increases your damage penetration with their assicated elemnt by %d%% and cause you to gain %d additional negative energy when you cast a celetial spell.
		These values scale with your Spellpower.]]):format(t.getResistPenalty(self, t), t.getBonusRegen(self, t))
   end,
}
