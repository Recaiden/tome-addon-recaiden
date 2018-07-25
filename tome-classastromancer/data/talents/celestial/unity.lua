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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Object = require "mod.class.Object"
require "math"

--  1  Harmonic Feedback - Passive, Gain a temporary buff when casting elemental spells
newTalent{
   name = "Harmonic Feedback", short_name = "WANDER_FEEDBACK",
   type = {"celestial/terrestrial_unity", 1},
   require = spells_req1,
   points = 5,
   mode = "passive",

   getSpeed = function(self, t)
      return 2.2
   end,
   getResist = function(self, t)
      return 3 --math.max(1, self:getTalentLevel(t) * 0.67)
   end,
   getHealMod = function(self, t)
      return 15 --self:combatTalentSpellDamage(t, 3, 10)

   end,

   callbackOnTalentPost = function(self, t, ab)
      if not ab.type[1]:find("^celestial/") then return end
      if ab.type[1]:find("/kolal") then
	 self:setEffect(self.EFF_WANDER_KOLAL, 10, {stacks = 1, max_stacks = self:getTalentLevelRaw(t)})
      elseif ab.type[1]:find("/luxam") then
	 self:setEffect(self.EFF_WANDER_LUXAM, 10, {stacks = 1, max_stacks = self:getTalentLevelRaw(t)})
      elseif ab.type[1]:find("/ponx") then
      	 self:setEffect(self.EFF_WANDER_PONX, 10, {stacks = 1, max_stacks = self:getTalentLevelRaw(t)})
      end
   end,
   
   info = function(self, t)
      local speed_flame = t.getSpeed(self, t)
      local res_cold = t.getResist(self, t)
      local hmod_wind = t.getHealMod(self, t)
      local stacks = self:getTalentLevelRaw(t)
      
      return ([[Casting planetary spells gives you charges of planetary energy for 10 turns, stacking up to %d times each
Kolal charges increase your casting and combat speeds by %d%%
Luxam charges increase your resist all by %d%%
Ponx charges increase your healing mod by %d%%]]):format(stacks, speed_flame, res_cold, hmod_wind)
   end,
}


--  4  Elemental Transposition - swap places with one of your elementals
newTalent{
   name = "Elemental Transposition", short_name = "WANDER_SWAP",
   type = {"celestial/terrestrial_unity", 2},
   require = spells_req2,
   points = 5,
   random_ego = "attack",
   negative = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 25, 6)) end, -- Limit > 5
   range = 10,
   requires_target = true,
   np_npc_use = true,
   no_energy = true;

   on_pre_use = function(self, t, silent)
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.type == "elemental" then
	       return true
	    end
	 end
      end
      if not silent then game.logPlayer(self, "You require an ally to swap places with") end
      return false
   end,
   
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local tx, ty, target = self:getTarget(tg)
      if not tx or not ty or not target or not target.summoner or target.summoner ~= self or not target.type == elemental then return nil end
      
      -- Displace
      game.level.map:remove(self.x, self.y, Map.ACTOR)
      game.level.map:remove(target.x, target.y, Map.ACTOR)
      game.level.map(self.x, self.y, Map.ACTOR, target)
      game.level.map(target.x, target.y, Map.ACTOR, self)
      self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
      
      game:playSoundNear(self, "talents/teleport")
      return true
   end,
   info = function(self, t)
      return ([[Instantly switches places with one of your summons.]])
   end,
}

--  8  Planetary Convergence
newTalent{
   name = "Planetary Convergence", short_name = "WANDER_CYCLE_BOOST",
   type = {"celestial/terrestrial_unity", 3},
   require = spells_req3,
   points = 5,
   no_energy = true,
   cooldown = 10,

   on_pre_use = function(self, t, silent)
      if not self:hasEffect(self.EFF_WANDER_KOLAL)
	 or not self:hasEffect(self.EFF_WANDER_LUXAM)
	 or not self:hasEffect(self.EFF_WANDER_PONX)
      then
	 if not silent then game.logPlayer(self, "You require at least one of each planetary charge.") end
	 return false
      end
      return true
   end,

   getDuration = function(self, t)
      return self:combatTalentScale(t, 5, 10, 1)
      --return 10
   end,

   action = function(self, t)
      local chargeFlame = self:hasEffect(self.EFF_WANDER_KOLAL).stacks
      local chargeCold = self:hasEffect(self.EFF_WANDER_LUXAM).stacks
      local chargeWind = self:hasEffect(self.EFF_WANDER_PONX).stacks

      self:setEffect(self.EFF_WANDER_UNITY_OVERCHARGE, t.getDuration(self, t),
		     {stacks_kolal = chargeFlame,
		      stacks_luxam = chargeCold,
		      stacks_ponx = chargeWind})
      self:removeEffect(self.EFF_WANDER_KOLAL)
      self:removeEffect(self.EFF_WANDER_LUXAM)
      self:removeEffect(self.EFF_WANDER_PONX)	    
   end,

    info = function(self, t)
       return ([[Consume all stacks of planetary charge for a sudden burst of power lasting %d turns.  Kolal gives movement speed, Luxam regeneration, and Ponx on-hit damage.]]):format(t.getDuration(self, t))
   end,
}

newTalent{
   name = "Swift Arrival", short_name = "WANDER_GRAND_ARRIVAL",
   type = {"celestial/terrestrial_unity", 4},
   require = spells_req4,
   points = 5,
   mode = "passive",
   
   info = function(self, t)
      return ([[Perfect your summoning techniques, increasing the duration of your summons.
Each rank greatly improves the casting speed of your summongs, allowing you to summon mlutiple elementals in one turn.
The bonuses are reflected in the description of each summon spell.]])
   end,
}



-- newTalent{
-- 	name = "Quick Recovery",
-- 	type = {"technique/combat-techniques-passive", 1},
-- 	require = techs_strdex_req1,
-- 	mode = "passive",
-- 	points = 5,
-- 	getStamRecover = function(self, t) return self:combatTalentScale(t, 0.6, 2.5, 0.75) end,
-- 	passives = function(self, t, p)
-- 		self:talentTemporaryValue(p, "stamina_regen", t.getStamRecover(self, t))
-- 	end,
-- 	info = function(self, t)
-- 		return ([[Your combat focus allows you to regenerate stamina faster (+%0.1f stamina/turn).]]):format(t.getStamRecover(self, t))
-- 	end,
-- }
