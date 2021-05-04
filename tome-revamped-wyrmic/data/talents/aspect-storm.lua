local Object = require "mod.class.Object"

function getAspectResists(self, t)
   return self:combatTalentScale(t, 2, 25)
end

newTalent{
   name = "Static Shock", short_name = "REK_WYRMIC_ELEC",
   type = {"wild-gift/wyrm-storm", 1},
   require = {
      stat = { wil=function(level) return 10 + (level-1) * 4 end },
      level = function(level) return 0 + (level-1) * 3 end,
      special =
	 {
         desc="You can learn a new aspect every 6 levels",
         fct=function(self)
            return self:knowTalent(self.T_REK_WYRMIC_ELEC) or self.level >= numAspectsKnown(self)*6
	    end
	 },
   },
   points = 5,
   on_learn = function(self, t)
      if self.rek_wyrmic_dragon_damage == nil then
	 self.rek_wyrmic_dragon_damage = {
	    name="Lightning",
	    nameStatus="Dazed",
	    nameDrake=(DamageType:get(DamageType.LIGHTNING).text_color or "").."Storm Drake#LAST#",
	    damtype=DamageType.LIGHTNING,
	    status=DamageType.REK_WYRMIC_ELEC,	    
	    talent=self.T_REK_WYRMIC_ELEC
	 }
      end
      onLearnAspect(self, t)
   end,
   on_unlearn = function(self, t) onUnLearnAspect(self) end,
      
   mode = "passive",
   
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists,
   
   getPercent = function(self, t)
      return self:combatLimit(self:combatTalentMindDamage(t, 10, 45), 90, 0, 0, 31, 31) -- Limit to <90%
   end,
   passives = function(self, t, p)
      local resist = t.getResists(self, t)
      self:talentTemporaryValue(p, "resists", {[DamageType.LIGHTNING] = resist})
   end,
   info = function(self, t)
      local resist = t.getResists(self, t)
      local rad = self:getTalentRadius(t)
      return ([[You can take on the power of Storm Wyrms, giving you %d%% lightning resistance.

Dealing damage with your primary element will Electrocute enemies (#SLATE#Mindpower vs. Physical#LAST#) for %d%% of their current life (2/3 as much vs. Elites and Rares, 2/4 as much vs. Uniques or Bosses, and 2/5 as much vs. Elite Bosses and above).  Enemies can only be electrocuted once every 20 turns.

Storm damage can inflict Daze (#SLATE#Mindpower vs. Physical#LAST#).
If the target is already dazed, the chance to reapply daze is greatly increased.
Storm damage will fluctuate between 60%% and 140%% of the listed damage.
]]):format(resist, t.getPercent(self, t))
   end,
}

newTalent{
   name = "Electroshock", short_name = "REK_WYRMIC_ELEC_SHOCK",
   type = {"wild-gift/wyrm-storm", 2},
   require = {
      stat = { wil=function(level) return 22 + (level-1) * 2 end },
      level = function(level) return 10 + (level-1) end,
      special =
	 {
	    desc="Advanced aspect talents learnable",
	    fct=function(self) 
	       return self:knowTalent(self.T_REK_WYRMIC_ELEC_SHOCK)
		  or self.unused_talents_types >= 1
	    end
	 },
   },
   points = 5,
   equilibrium = 10,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 20, 8)) end,
   range = 0,
   requires_target = true,
   direct_hit = true,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
   tactical = { DISABLE = { stun = 1 } },
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   on_learn = function(self, t) onLearnHigherAbility(self, t) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self, t) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.REK_WYRMIC_SHOCK,
		   {
		      dam=0
		   }
      )
      game:playSoundNear(self, "talents/lightning")
      return true
   end,
   
   info = function(self, t)
      local rad = self:getTalentRadius(t)
      local notice = (self:getTalentLevelRaw(t) == 1000 or (self:getTalentLevelRaw(t) < 2)) and [[


#YELLOW#Learning the advanced storm talents costs a category point.#LAST#]] or ""
      return ([[Produce a disorienting electrical pulse, shocking(halved daze/stun/pin resist) your foes (#SLATE#Mindpower vs. Spell#LAST#) within a radius %d cone for 3 turns.%s]]):format(rad, notice)
   end,
}

newTalent{
   name = "Storm Surge", short_name = "REK_WYRMIC_ELEC_CHAIN",
   type = {"wild-gift/wyrm-storm", 3},
   require = gifts_req_high2,
   points = 5,
   mode = "passive",
   getPercent = function(self, t)
      return math.min(50, 10 + self:combatTalentScale(t, 5, 15))
   end,
   getNumChain = function(self, t)
      return math.floor(self:combatTalentLimit(t, 5, 2, 4))
   end,

   --Talent is a passive implemented entirely in damage_types

   info = function(self, t)
      local diminish = t.getPercent(self, t)
      local targets = t.getNumChain(self, t)
      return ([[Your wyrmic lightning attacks leap between enemies with range 5. It can leap to up to %d enemies and never strikes the same enemy twice.  The second target takes %d%% of the original damage.  Subsequent targets take 75%% as much damage as the previous target.   Secondary targets will not be dazed.
]]):format(targets, diminish)
   end,
}

newTalent{
	name = "Tornado", short_name = "REK_WYRMIC_ELEC_TORNADO",
	type = {"wild-gift/wyrm-storm", 4},
	require = gifts_req_high3,
	points = 5,
	equilibrium = 14,
	cooldown = 15,
	proj_speed = 1, -- This is purely indicative
	tactical = { ATTACK = { LIGHTNING = 2 }, DISABLE = { stun = 2 } },
	range = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 6, 9))) end,
	requires_target = true,
	getRadius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, 0.5, 0, 0, true)) end,
	getMoveDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	getStunDuration = function(self, t) return self:combatTalentScale(t, 3, 6, 0.5, 0, 0, true) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), selffire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		
		local movedam = self:mindCrit(t.getMoveDamage(self, t))
		local dam = self:mindCrit(t.getDamage(self, t))
		local rad = t.getRadius(self, t)
		local dur = t.getStunDuration(self, t)
		
		local proj = require("mod.class.Projectile"):makeHoming(
			self,
			{particle="bolt_lightning", trail="lightningtrail"},
			{speed=1, name="Tornado", dam=dam, movedam=movedam, rad=rad, dur=dur},
			target,
			self:getTalentRange(t),
			function(self, src)
				local DT = require("engine.DamageType")
				local Map = require("engine.Map")
				local kb_func = function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					
					if not target or target == self then return end
					if target:canBe("knockback") then
						target:knockback(src.x, src.y, 2)
						game.logSeen(target, "%s is knocked back!", target.name:capitalize())
					else
						game.logSeen(target, "%s resists the tornado!", target.name:capitalize())
					end
				end
				src:project({type="ball", radius=2, selffire=false, x=self.x, y=self.y, friendlyfire=false}, self.x, self.y, DT.REK_WYRMIC_ELEC, self.def.movedam)
				src:project({type="ball", radius=2, selffire=false, x=self.x, y=self.y, friendlyfire=false}, self.x, self.y, kb_func)
			end,
			function(self, src, target)
				local DT = require("engine.DamageType")
				src:project({type="ball", radius=self.def.rad, selffire=false, x=self.x, y=self.y}, self.x, self.y, DT.REK_WYRMIC_ELEC, self.def.dam)
				src:project({type="ball", radius=self.def.rad, selffire=false, x=self.x, y=self.y}, self.x, self.y, DT.MINDKNOCKBACK, self.def.dam)
				
				-- Lightning ball gets a special treatment to make it look neat
				local sradius = (1 + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
				local nb_forks = 16
				local angle_diff = 360 / nb_forks
				for i = 0, nb_forks - 1 do
					local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
					local tx = self.x + math.floor(math.cos(a) * 1)
					local ty = self.y + math.floor(math.sin(a) * 1)
					game.level.map:particleEmitter(self.x, self.y, 1, "lightning", {radius=1, tx=tx-self.x, ty=ty-self.y, nb_particles=25, life=8})
				end
				game:playSoundNear(self, "talents/lightning")
			end
																													 )
		proj.energy.value = 1500 -- Give it a boost so it moves before our next turn
		proj.homing.count = 20  -- 20 turns max
		game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local rad = t.getRadius(self, t)
		return ([[Summons a tornado that moves slowly toward its target, following it if it changes position.
Each time it moves every foe within radius 2 takes %0.1f storm damage and is knocked back 2 spaces.
When it reaches its target, it explodes in a radius of %d for %0.1f storm damage. All affected creatures will be knocked back. The blast will ignore the talent user.
The tornado will last for %d turns, or until it reaches its target.
Mindpower: improves damage
]]):format(
	damDesc(self, DamageType.LIGHTNING, t.getMoveDamage(self, t)),
	rad,
	damDesc(self, DamageType.LIGHTNING, t.getDamage(self, t)),
	self:getTalentRange(t))
end,
}
