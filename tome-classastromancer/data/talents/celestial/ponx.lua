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


newTalent{
	name = "Bright Lightning", short_name = "WANDER_LIGHTNING_GWEL",
	type = {"spell/other", 1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 3,
	tactical = { ATTACK = {LIGHTNING = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	allow_for_arcane_combat = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 100) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.GOOD_LIGHTNING, {dam=rng.avg(dam / 3, dam, 3)})
		local _ _, x, y = self:canProject(tg, x, y)
		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning_beam", {tx=x-self.x, ty=y-self.y}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning_beam", {tx=x-self.x, ty=y-self.y})
		end
		--game:playSoundNear(self, "talents/wander_thunder")
		game:playSoundNear(self, {"talents/wander_thunder", vol=0.3})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures up mana into a powerful beam of lightning, doing %0.2f to %0.2f damage
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

--	Summon Gwelgoroth
newTalent{
   name = "Summon: Gwelgoroth", short_name = "WANDER_SUMMON_LIGHTNING",
   type = {"celestial/ponx", 1},
   require = spells_req1,
   points = 5,
   random_ego = "attack",
   message = "@Source@ conjures a Gwelgoroth!",
   cooldown = 10,
   negative = -10.2,
   tactical = { ATTACK = { LIGHTNING = 2 } },
   range = 5,

   on_pre_use = function(self, t, silent)
      if not self:canBe("summon") and not silent then game.logPlayer(self, "You cannot summon; you are suppressed!") return end
      return not checkMaxSummonStar(self, silent)
   end,

   on_arrival = function(self, t, m)
      local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
      local duration = self:callTalent(self.T_WANDER_ELEMENTAL_ARRIVAL, "effectDuration")
      self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_FIRE_RESIST, dur=duration, p={power=self:combatTalentMindDamage(t, 15, 70)}})
      game.level.map:particleEmitter(m.x, m.y, tg.radius, "ball_fire", {radius=tg.radius})
   end,

   incStats = function(self, t, fake)
      local mp = self:combatSpellpower()
      return{ 
	 mag=15 + (fake and mp or self:spellCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
	 cun=15 + (fake and mp or self:spellCrit(mp)) * 1.7 * self:combatTalentScale(t, 0.2, 1, 0.75),
	 con=10 
      }
   end,

   speed = astromancerSummonSpeed,

   display_speed = function(self, t)
      return ("Swift Spell (#LIGHT_GREEN#%d%%#LAST# of a turn)"):
	 format(t.speed(self, t)*100)
   end,
   
   summonTime = function(self, t)
      return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_WANDER_GRAND_ARRIVAL), 5, 0, 10, 5))
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
	 return
      end
      
      local NPC = require "mod.class.NPC"
      local m = NPC.new{
	 type = "elemental", subtype = "air",
	 display = "E", color=colors.AQUAMARINE, image = "npc/elemental_air_gwelgoroth.png",
	 name = "Gwelgoroth", faction = self.faction,
	 desc = [[A mighty air elemental, torn away from its home world by powerful magic.]],
	 autolevel = "none",
	 ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1 }, --, ally_compassion=10},
	 ai_tactic = resolvers.tactic"ranged",
	 stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
	 inc_stats = t.incStats(self, t),
	 level_range = {self.level, self.level}, exp_worth = 0,
	 
	 max_life = resolvers.rngavg(5,10),
	 life_rating = 8,
	 infravision = 10,
	 size_category =3,
	 levitation = 1,
	 
	 combat_armor = 0, combat_def = 20,
	 combat = { dam=1, atk=1, },
	 on_melee_hit = { [DamageType.LIGHTNING] = resolvers.mbonus(20, 10), },
	 
	 resolvers.talents{
	    [self.T_WANDER_LIGHTNING_GWEL]=self:getTalentLevelRaw(t),
	 },
	 resists = { [DamageType.LIGHTNING] = self:getTalentLevel(t)*20 },
	 
	 summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
	 summon_time = t.summonTime(self, t),
	 ai_target = {actor=target},
	 resolvers.sustains_at_birth(),
      }
      local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
      if augment then
	 if augment.ultimate then
	    m[#m+1] = resolvers.talents{
	       [self.T_HURRICANE]=self:getTalentLevelRaw(t),
	       [self.T_SHOCK]=self:getTalentLevelRaw(t)
	    }
	    m.name = "Ultimate "..m.name
	    m.image = "npc/elemental_air_ultimate_gwelgoroth_short.png"
	 else
	    m[#m+1] = resolvers.talents{ [self.T_SHOCK]=self:getTalentLevelRaw(t) }
	    m.name = "Greater "..m.name
	    m.image = "npc/elemental_air_greater_gwelgoroth_short.png"
	 end	 
      end
      
      setupSummonStar(self, m, x, y)
      game:playSoundNear(self, "talents/lightning")
      return true
   end,
   info = function(self, t)
      local incStats = t.incStats(self, t, true)
      return ([[Summon a Gwelgoroth for %d turns to electrocute your foes. These Air Elementals are powerful ranged attackers who use bright lightning bolts.
Its attacks improve with your level and talent level
		It will get %d Magic, %d Cunning and %d Constitution.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Their Magic and Cunning will increase with your Spellpower.

#GREEN#Blighted Summoning: Flame of Urh'rok#{normal}#
]])
	 :format(t.summonTime(self, t), incStats.mag, incStats.cun, incStats.con)
   end,
}

newTalent{
   name = "Voltaic Chain", short_name = "WANDER_CHAIN_LIGHTNING",
   type = {"celestial/ponx", 2},
   require = spells_req2,
   points = 5,
   random_ego = "attack",
   negative = -8.2,
   cooldown = 8,
   tactical = { ATTACKAREA = {LIGHTNING = 2} }, --note: only considers the primary target
   range = 10,
   direct_hit = true,
   reflectable = true,
   requires_target = true,
   target = function(self, t) return {type="bolt", range=self:getTalentRange(t), nowarning=true, talent=t} end,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
   getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, "log")) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local fx, fy = self:getTarget(tg)
      if not fx or not fy then return nil end
      
      local nb = t.getTargetCount(self, t)
      local affected = {}
      local first = nil
      
      self:project(tg, fx, fy, function(dx, dy)
		      local actor = game.level.map(dx, dy, Map.ACTOR)
		      if actor and not affected[actor] then
			 affected[actor] = true
			 first = actor
			 
			 self:project({type="ball", selffire=true, x=dx, y=dy, radius=10, range=0}, dx, dy, function(bx, by)
			       local actor = game.level.map(bx, by, Map.ACTOR)
			       if actor and not affected[actor] then
				  affected[actor] = true
			       end
			 end)
			 return true
		      end
      end)
      
      if not first then return end
      local targets = { first }
      affected[first] = nil
      local possible_targets = table.listify(affected)
      for i = 2, nb do
	 if #possible_targets == 0 then break end
	 local act = rng.tableRemove(possible_targets)
	 targets[#targets+1] = act[1]
      end
      
      local sx, sy = self.x, self.y
      for i, actor in ipairs(targets) do
	 local tgr = {type="beam", range=self:getTalentRange(t), selffire=true, talent=t, x=sx, y=sy}
	 local dam = self:spellCrit(t.getDamage(self, t))
	 self:project(tgr, actor.x, actor.y, DamageType.GOOD_LIGHTNING, {dam=rng.avg(rng.avg(dam / 3, dam, 3), dam, 5)})
	 
	 if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy}, {type="lightning"})
	 else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy})
	 end
	 
	 sx, sy = actor.x, actor.y
      end
      
      game:playSoundNear(self, "talents/wander_thunder")
      
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local targets = t.getTargetCount(self, t)
      return ([[Invokes a forking beam of lightning doing %0.2f to %0.2f damage and forking to another target.  Allies are instead healed for this amount.
		It can hit up to %d targets up to 10 grids apart, and will never hit the same one twice.
		The damage will increase with your Spellpower.]]):
	 format(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage),
		targets)
   end,
}


--Evasive Gust - passively slow projectiles, activate to redirect one to a new target.
newTalent{
   name = "Evasive Gust", short_name = "WANDER_WIND_DODGE",
   type = {"celestial/ponx", 3},
   require = spells_req3,
   points = 5,
   no_energy = true,
   cooldown = 0,
   negative = 10,
   range = 10,
   target = function(self, t)
      return {type="beam", range=self:getTalentRange(t), talent=t}
   end,
   
   onAIGetTarget = function(self, t)
      local tgts = {}
      self:project({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, function(px, py)
	    local tgt = game.level.map(px, py, Map.PROJECTILE)
	    if tgt and (not tgt.src or self:reactionToward(tgt.src) < 0) then tgts[#tgts+1] = {x=px, y=py, tgt=tgt, dist=core.fov.distance(self.x, self.y, px, py)} end
      end)
      table.sort(tgts, function(a, b) return a.dist < b.dist end)
      if #tgts > 0 then return tgts[1].x, tgts[1].y, tgts[1].tgt end
   end,
   
   on_pre_use_ai = function(self, t, silent) return t.onAIGetTarget(self, t) and true or false end,
   requires_target = true,
   target = function(self, t)
      return {type="bolt", range=self:getTalentRange(t), scan_on=engine.Map.PROJECTILE, no_first_target_filter=true}
   end,
   getSlow = function(self,t) return math.min(90, self:combatTalentScale(t, 15, 50)) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "slow_projectiles", t.getSlow(self, t))
   end,
   tactical = {SPECIAL=10},
   
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      local Map = require("engine.Map")
      local proj = game.level.map(x, y, engine.Map.PROJECTILE)
      if not proj then
	 return false
      end
      local energy = proj.energy.value
      
      
      if proj.project then
	 --local range = core.fov.distance(proj.x, proj.y, proj.project.def.x, proj.project.def.y)
	 local range = 10
	 
	 local tg2 = (proj.project.def and proj.project.def.tg) or {type = "hit"}
	 tg2.range = range
	 tg2.start_x = x 
	 tg2.start_y = y
	 
	 local x2, y2 = self:getTarget(tg2)
	 if not x2 or not y2 then return nil end
	 local _ _, _, _, x2, y2 = self:canProject(tg2, x2, y2)
	 if proj.name == "Lunar Orb" then
	    x2 = 1000 * (x2 - x) + x
	    y2 = 1000 * (y2 - y) + y
	 end
	 
	 --this is all copy-pasted from distortion pulse
	 local proj2 = require("engine.Projectile").new(proj:clone{})

	 local block_corner = proj.project.def.typ.line_function.block_corner
	 local block = proj.project.def.typ.line_function.block
	 proj2.project.def.typ.line_function = core.fov.line(proj.x, proj.y, x2, y2, block)
	 proj2.project.def.typ.line_function:set_corner_block(block_corner)
	 proj2.project.def.start_x = proj.x
	 proj2.project.def.start_y = proj.y
	 proj2.project.def.x = x2
	 proj2.project.def.y = y2
	 proj2.start_x = proj2.project.def.start_x
	 proj2.start_y = proj2.project.def.start_y
	 proj2.src = self
	 game.zone:addEntity(game.level, proj2, "projectile", x, y)
	 if self.mirror_self and not self.mirror_self.dead then
	    local proj3 = require("engine.Projectile").new(proj:clone{})
	    local block_corner = proj.project.def.typ.line_function.block_corner
	    local block = proj.project.def.typ.line_function.block
	    proj3.project.def.typ.line_function = core.fov.line(proj.x, proj.y, x2, y2, block)
	    proj3.project.def.typ.line_function:set_corner_block(block_corner)
	    proj3.project.def.start_x = proj.x
	    proj3.project.def.start_y = proj.y
	    proj3.project.def.x = x2
	    proj3.project.def.y = y2
	    proj3.start_x = proj3.project.def.start_x
	    proj3.start_y = proj3.project.def.start_y
	    proj3.src = self
	    game.zone:addEntity(game.level, proj3, "projectile", x, y)
	 end
      elseif proj.homing then
	 local tg2 = {type = "hit", start_x = x, start_y = y}
	 local x2, y2 = self:getTarget(tg2)
	 if not x2 or not y2 then return nil end
	 local _ _, _, _, x2, y2 = self:canProject(tg2, x2, y2)
	 local target = game.level.map(x2, y2, Map.ACTOR)
	 if not target then return nil end
	 local proj2 = require("engine.Projectile").new(proj:clone{})
	 proj2.homing.target = target
	 proj2.src = self
	 game.zone:addEntity(game.level, proj2, "projectile", x, y)
	 if self.mirror_self and not self.mirror_self.dead then
	    local proj3 = require("engine.Projectile").new(proj:clone{})
	    proj3.homing.target = target
	    proj3.src = self
	    game.zone:addEntity(game.level, proj3, "projectile", x, y)
	 end
      end
      
      proj.energy.value = energy

      -- delete the original
      proj:terminate(x, y)
      game.level:removeEntity(proj, true)
      proj.dead = true	 
      
      game:playSoundNear(self, "talents/wander_wind")
      return true
   end,
   
   info = function(self, t)
      return ([[Surround yourself with the whirling winds of Ponx, slowing incoming projectiles by %d%%.

In addition, you can send the winds out to instantly redirect a projectile to a new target.]]):
	 format(t.getSlow(self,t))
   end,
}


--Voltaic Storm - Sustain, generate random bolts that harm enemies and heal allies
newTalent{
   name = "Voltaic Storm", short_name = "WANDER_LIGHTNING_STORM",
   type = {"celestial/ponx", 4},
   require = spells_req4,
   points = 5,
   mode = "sustained",
   sustain_negative = 20,
   cooldown = 15,
   tactical = { ATTACKAREA = {LIGHTNING = 2} },
   range = 6,
   direct_hit = true,
   
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
   getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
   getManaDrain = function(self, t) return -1 end, --self:getTalentLevelRaw(t) end,

   callbackOnActBase = function(self, t)
      local mana = t.getManaDrain(self, t)
      if self:getNegative() <= mana + 1 then return end
      
      local tgts = {}
      local grids = core.fov.circle_grids(self.x, self.y, 6, true)
      for x, yy in pairs(grids) do
	 for y, _ in pairs(grids[x]) do
	    local a = game.level.map(x, y, Map.ACTOR)
	    if a then
	       if a.x ~= self.x or a.y ~= self.y then
		  if self:reactionToward(a) < 0 or a.life < a.max_life then
		     tgts[#tgts+1] = a
		  end
	       end
	    end
	 end
      end
      
      -- Randomly take targets
      local tg = {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=true}
      --local tg = {type="ball", radius=1, range=self:getTalentRange(t), talent=t, friendlyfire=true}
      if #tgts > 0 then
	 game:playSoundNear(self, "talents/lightning")
      end
      for i = 1, t.getTargetCount(self, t) do
	 if #tgts <= 0 then break end
	 local a, id = rng.table(tgts)
	 table.remove(tgts, id)
	 
	 self:project(tg, a.x, a.y, DamageType.GOOD_LIGHTNING, {dam=rng.avg(1, self:spellCrit(t.getDamage(self, t)), 3)})

	 game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "lightning", {tx=a.x-self.x, ty=a.y-self.y})

	 -- if core.shader.active() then
	 --    game.level.map:particleEmitter(a.x, a.y, 1, "ball_lightning_beam", {radius=1, tx=x, ty=y}, {type="lightning"})
	 -- else
	 --    game.level.map:particleEmitter(a.x, a.y, 1, "ball_lightning_beam", {radius=1, tx=x, ty=y})
	 -- end
	 
	 self:incNegative(mana)
      end
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/thunderstorm")
      game.logSeen(self, "#0080FF#A furious bright storm forms around %s!", self.name)
      return {
      }
   end,
   deactivate = function(self, t, p)
      game.logSeen(self, "#0080FF#The furious bright storm around %s calms down and disappears.", self.name)
      return true
   end,

   info = function(self, t)
      local targetcount = t.getTargetCount(self, t)
      local damage = t.getDamage(self, t)
      local manadrain = t.getManaDrain(self, t)
      return ([[You immerse yourself in a fragment of the Great Storm, creating a maelstrom with a radius of 6 that follows you as long as this spell is active.

Each turn, a random bright-lightning bolt will hit up to %d targets, healing alies and damaging foes for %0.2f damage.
This powerful spell will drain %0.2f negative energy with each hit.]])
	 :format(targetcount, damDesc(self, DamageType.GOOD_LIGHTNING, damage), -manadrain)
   end,
}
