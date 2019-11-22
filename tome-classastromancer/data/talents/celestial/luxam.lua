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

-- For creating Glacial Path entities on map squares
local Object = require "engine.Object"
local Map = require "engine.Map"


newTalent{
	name = "Glacial Vapor", short_name = "WANDER_ICE_VAPOR",
	type = {"spell/other",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 12,
	cooldown = 8,
	tactical = { ATTACKAREA = { COLD = 2 } },
	range = 8,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false }
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.LUXAM_VAPOUR, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="ice_vapour"},
			nil, true)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Glacial fumes rise from the ground, doing %0.2f cold damage to enemies in a radius of 3 each turn for %d turns.
		Creatures that are wet will take 30%% more damage and have 15%% chance to get frozen.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.COLD, damage), duration)
	end,
}

newTalent{
   name = "Summon: Shivgoroth", short_name = "WANDER_SUMMON_ICE",
   type = {"celestial/luxam", 1},
   require = spells_req1,
   points = 5,
   random_ego = "attack",
   message = "@Source@ conjures a Shivgoroth!",
   negative = -5,
   cooldown = 10,
   range = 5,
   requires_target = true,
   is_summon = true,
   tactical = { ATTACK = { COLD = 2 } },
   
   on_pre_use = function(self, t, silent)
      if not self:canBe("summon") and not silent then game.logPlayer(self, "You cannot summon; you are suppressed!") return end
      return not checkMaxSummonStar(self, silent)
   end,

   incStats = function(self, t, fake)
      local mp = self:combatSpellpower()
      return{
         str=10,
         dex=10,
         con=15 + (fake and mp or self:spellCrit(mp)) * 1.7 * self:combatTalentScale(t, 0.2, 1, 0.75),
	 mag=15 + (fake and mp or self:spellCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
         wil=10,
	 cun=15 + (fake and mp or self:spellCrit(mp)) * 1.7 * self:combatTalentScale(t, 0.2, 1, 0.75)
      }
   end,
   
   summonTime = function(self, t)
      local duration = math.floor(self:combatScale(self:getTalentLevel(t), 5, 0, 10, 5))
      local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
      if augment then
         duration = duration + augment.extend
      end
      return duration
   end,

   speed = astromancerSummonSpeed,

   display_speed = function(self, t)
      return ("Swift Spell (#LIGHT_GREEN#%d%%#LAST# of a turn)"):
	 format(t.speed(self, t)*100)
   end,
   
   action = function(self, t)
      local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
      local tx, ty, target = self:getTarget(tg)
      if not tx or not ty then return nil end
      local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
      target = game.level.map(tx, ty, Map.ACTOR)
      if target == self then target = nil end
      
      -- Find space
      local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
      if not x then
	 game.logPlayer(self, "Not enough space to summon!")
	 return
      end
      
      local NPC = require "mod.class.NPC"
      local m = NPC.new{
	 type = "elemental", subtype = "cold",

	 display = "I", color=colors.LIGHT_RED, image = "npc/elemental_ice_shivgoroth_short.png",
	 name = "Shivgoroth", faction = self.faction,
	 desc = [[]],
	 autolevel = "none",
	 ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=0},
	 ai_tactic = resolvers.tactic"ranged",
	 stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
	 inc_stats = t.incStats(self, t),
	 level_range = {self.level, self.level}, exp_worth = 0,
	 
	 max_life = resolvers.rngavg(5,10),
	 life_rating = 8,
	 infravision = 10,
	 
	 combat_armor = 0, combat_def = 20,
	 combat = { dam=1, atk=1, },
	 on_melee_hit = { [DamageType.COLD] = resolvers.mbonus(20, 10), },
	 
	 resolvers.talents{
	    [self.T_WANDER_ICE_VAPOR]=self:getTalentLevelRaw(t),
	 },
	 resists = { [DamageType.COLD] = self:getTalentLevel(t)*20 },
	 
	 summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
	 summon_time = t.summonTime(self, t),
	 ai_target = {actor=target}
      }
      local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
      if augment then
	 if augment.ultimate then
	    m[#m+1] = resolvers.talents{
	       [self.T_ICE_STORM]=self:getTalentLevelRaw(t),
	       [self.T_COLD_FLAMES]=self:getTalentLevelRaw(t)
	    }
	    m.name = "Ultimate "..m.name
	    m.image = "npc/elemental_ice_ultimate_shivgoroth_short.png"
	 else
	    m[#m+1] = resolvers.talents{ [self.T_COLD_FLAMES]=self:getTalentLevelRaw(t) }
	    m.name = "Greater "..m.name
	    m.image = "npc/elemental_ice_greater_shivgoroth_short.png"
	 end	 
      end
      
      setupSummonStar(self, m, x, y)
      game:playSoundNear(self, "talents/lightning")
      return true
   end,
   info = function(self, t)
      local incStats = t.incStats(self, t, true)
      return ([[Summon a Shivgoroth for %d turns to freeze your foes. These Ice Elementals lock down enemies in an area with freezing vapour.
Its attacks improve with talent level.
		It will get %d Magic, %d Cunning and %d Constitution.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Their Magic and Cunning will increase with your Spellpower.

#GREEN#Blighted Summoning: Corrosive Vapour (Warning: shivgoroth is willing to melt allies who are in the line of fire)#{normal}#
]])
	 :format(t.summonTime(self, t), incStats.mag, incStats.cun, incStats.con)
   end,
}

--Glacial Path - Deal light Cold damage in a cone and leave a zone in which you move very quickly.
newTalent{
   name = "Glacial Path", short_name = "WANDER_ICE_CONE",
   type = {"celestial/luxam", 2},
   require = spells_req2,
   points = 5,
   random_ego = "attack",
   negative = -10,
   cooldown = 14,
   tactical = { ATTACKAREA = { COLD = 1, stun = 1 } },
   range = 0,
   direct_hit = true,
   reflectable = true,
   requires_target = true,
   createPath = function(summoner, x, y, duration)
      local e = Object.new{
	 name = summoner.name:capitalize() .. "'s glacial path",
	 block_sight=false,
	 canAct = false,
	 x = x, y = y,
	 originalDuration = duration,
	 duration = duration,
	 summoner = summoner,
	 summoner_gain_exp = true,
	 act = function(self)
	    local Map = require "engine.Map"
	    
	    self:useEnergy()
	    
	    if self.duration <= 0 then
	       -- remove
	       if self.particles then game.level.map:removeParticleEmitter(self.particles) end
	       game.level.map:remove(self.x, self.y, Map.TERRAIN+3)
	       game.level:removeEntity(self, true)
	       self.glacialPath = nil
	       game.level.map:scheduleRedisplay()
	    else
	       self.duration = self.duration - 1
	    end
	 end,
      }
      e.glacialPath = e -- used for checkAllEntities to return the Object itself
      game.level:addEntity(e)
      game.level.map(x, y, Map.TERRAIN+3, e)
      
      -- add particles
      --e.particles = Particles.new("creeping_dark", 1, {is_ascii = config.settings.tome.gfx.tiles == "ascii" or config.settings.tome.gfx.tiles == "ascii_full"})
      --e.particles.x = x
      --e.particles.y = y
      --game.level.map:addParticleEmitter(e.particles)
   end,
   
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, 0.5, 0, 0, true)) end,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false, talent=t}
   end,

   getMovementSpeedChange = function(self, t)
      --be just fast enough to cross the entire glacial path in 1 turn (with no other movespeed effects)
      return t.radius(self, t) - 1
      --return self:combatTalentScale(t, 1, 5, 0.75)
   end,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 125) end,
   getStunDuration = function(self, t) return self:combatTalentScale(t, 3, 7, 0.5, 0, 0, true) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.COLDNEVERMOVE, {dur=t.getStunDuration(self, t), dam=self:spellCrit(t.getDamage(self, t))})
      -- Create ice cone on empty spaces or targets enemies
      self:project(tg, x, y, function(px, py)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if not target then
			 local oe = game.level.map(px, py, Map.TERRAIN)
			 if not oe or oe.special then return end
			 if not oe or oe:attr("temporary")
			    or game.level.map:checkAllEntities(px, py, "block_move")
			 then return end

			 t.createPath(self, px, py, t.getStunDuration(self, t))
		      else
			 t.createPath(self, px, py, t.getStunDuration(self, t))
		      end
      end)

      game.level.map:addEffect(self,
			       self.x, self.y, --start location
			       t.getStunDuration(self, t) + 1, --duration
			       DamageType.COSMETIC, 0, --damage type and amount
			       tg.radius,
			       {delta_x=x-self.x, delta_y=y-self.y}, 55, --direction, angle
			       MapEffect.new{color_br=187, color_bg=187, color_bb=255, alpha=100, effect_shader="shader_images/ice_effect.png"}, nil, true)
      
      game:playSoundNear(self, "talents/ice")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local stunduration = t.getStunDuration(self, t)
      local radius = self:getTalentRadius(t)
      local movespeed = t.getMovementSpeedChange(self, t) * 100
      return ([[Freezes the ground in a cone of radius %d. Any enemies caught in the area will immediately suffer %0.2f cold damage and be pinned while the ice lasts (for %d turns).  When moving over the ice, you skate at %d%% increased movement speed.
The damage will increase with your Spellpower.]]):
	 format(radius, damDesc(self, DamageType.COLD, damage), stunduration, movespeed)
   end,
}

--Chill - Slow enemies in a small area
local what = {physical=true, mental=true, magical=true}
newTalent{
   name = "Chill", short_name = "WANDER_ICE_SLOW",
   type = {"celestial/luxam", 3},
   require = spells_req3,
   points = 5,
   negative = 15,
   cooldown = 20,
   tactical = { ATTACKAREA = 3 },
   range = 7,
   radius = 1,
   direct_hit = true,
   requires_target = true,
   target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t, display={particle="bolt_ice", trail="icetrail"}} end,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 18, 180) end,
   getDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.6, 6.3)) end,
   getSpeed = function(self, t) return math.min(self:getTalentLevel(t) * 0.095, 0.6) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:projectile(tg, x, y, DamageType.LUXAM_COLD,
		      {dam=self:spellCrit(t.getDamage(self, t)),
		       speed=t.getSpeed(self, t),
		       dur=t.getDur(self, t)},
		      function(self, tg, x, y, grids)
			 game.level.map:particleEmitter(x, y, tg.radius, "iceflash",
							{radius=tg.radius, tx=x, ty=y})
      end)
      game:playSoundNear(self, "talents/ice")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local speed = t.getSpeed(self, t) * 100
      local dur = t.getDur(self, t)
      return ([[Invoke a sphere of frost that deals %0.2f cold damage in a radius of %d. Every enemy hit will be chilled to the bone, reducing their global speed by %d%% for %d turns and making them wet.
		The damage done will increase with your Spellpower.]]):
	 format(damDesc(self, DamageType.COLD, damage), self:getTalentRadius(t), speed, dur)
   end,
}

--Ice Shield - Encase yourself or an ally in a protective casing of ice, absorbing incoming damage.  Freeze immune while it lasts.
newTalent{
   name = "Icy Block", short_name = "WANDER_ICE_SHIELD",
   type = {"celestial/luxam", 4},
   require = spells_req4,
   points = 5,
   cooldown = 2,
   negative = 10,
   tactical = { DEFEND = 2},
   range = 10,
   getAbsorb = function(self, t)
      return self:combatTalentSpellDamage(t, 40, 400)
   end,
   
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend", default_target=self, friendlyblock=false, nowarning=true}
      local tx, ty, target = self:getTarget(tg)
      if not tx or not ty or not target then return nil end
      target:setEffect(target.EFF_DAMAGE_SHIELD, 10, {power=self:spellCrit(t.getAbsorb(self, t))})
      target:setEffect(target.EFF_WANDER_ICE_DAMAGE_SHIELD, 10, {power=100})
      game:playSoundNear(self, "talents/spell_generic")
      return true
   end,
   info = function(self, t)
      return ([[Encases an ally in a protective layer of ice, shielding them from %d damage in the next 10 turns and protecting them from being stunned for as long as the shield holds.
The total damage the ice can absorb will increase with your spellpower.]]):format(t.getAbsorb(self, t))
   end,
}


newTalent{
   name = "Ice Speed", short_name = "WANDER_ICE_SPEED",
   type = {"spell/objects",1},
   mode = "passive",
   points = 1,

   callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
      if not ox or not oy then return end
      if not x or not y then return end
      local dx, dy = (self.x - ox), (self.y - oy)
      if dx ~= 0 then dx = dx / math.abs(dx) end
      if dy ~= 0 then dy = dy / math.abs(dy) end
      local dir = util.coordToDir(dx, dy, 0)
      
      local eff = self:hasEffect(self.EFF_WANDER_ICE_SPEED)
      if eff then
	 eff.dur = 2
      else
	 self:setEffect(self.EFF_WANDER_ICE_SPEED, 2, {})
      end
      eff = self:hasEffect(self.EFF_WANDER_ICE_SPEED)
      
      if eff and not eff.dir then
	 eff.dir = dir
	 eff.nb = 0
      end
      
      if eff and eff.dir ~= dir then
	 self:removeEffect(self.EFF_WANDER_ICE_SPEED)
	 self:setEffect(self.EFF_WANDER_ICE_SPEED, 2, {})
	 eff = self:hasEffect(self.EFF_WANDER_ICE_SPEED)
	 eff.dir = dir
	 eff.nb = 0
      end
      
      eff.nb = eff.nb + 1
      
      if eff.nb >= 2 and not eff.blink then
	 self:effectTemporaryValue(eff, "movement_speed", 1)
	 eff.blink = true
      end
   end,
   info = function(self, t)
      return ([[When moving for at least 2 steps in the same direction, you create a corridor of ice, increasing your movement speed by 100%%.
		Changing direction will break the effect.]])
	 :format()
   end,
}
