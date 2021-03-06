local Object = require "mod.class.Object"

function getAspectResists(self, t)
   return self:combatTalentScale(t, 2, 25)
end

newTalent{
   name = "Flickering Embers", short_name = "REK_WYRMIC_FIRE",
   type = {"wild-gift/wyrm-fire", 1},
   require = {
      stat = { wil=function(level) return 10 + (level-1) * 4 end },
      level = function(level) return 0 + (level-1) * 3 end,
      special =
	 {
         desc="You can learn a new aspect every 6 levels",
         fct=function(self)
            return self:knowTalent(self.T_REK_WYRMIC_FIRE) or self.level >= numAspectsKnown(self)*6
	    end
	 },
   },
   points = 5,
   on_learn = function(self, t)
      if self.rek_wyrmic_dragon_damage == nil then
	 self.rek_wyrmic_dragon_damage = {
	    name="Fire",
	    nameStatus="Flameshocked",
	    nameDrake=(DamageType:get(DamageType.FIRE).text_color or "").."Fire Drake#LAST#",
	    damtype=DamageType.FIRE,
	    status=DamageType.REK_WYRMIC_FIRE,
	    talent=self.T_REK_WYRMIC_FIRE
	 }
      end
      onLearnAspect(self, t)
   end,
   on_unlearn = function(self, t) onUnLearnAspect(self) end,
   
   cooldown = function(self, t)
      return math.floor(self:combatTalentLimit(t, 3, 18, 6))
   end,
   mode = "passive",
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists,
   getDrain = function(self, t) return 5 + self:combatTalentScale(t, 0, 8) end,
   getDamage = function(self, t) return math.ceil(self:combatTalentScale(t, 60, 110, 0.75))/100 end,
   
   passives = function(self, t, p)
      local resist = t.getResists(self, t)
      self:talentTemporaryValue(p, "resists", {[DamageType.FIRE] = resist})
   end,

   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
      if not hitted then return end
      if self:isTalentCoolingDown(t) then return end

      local victims = {}
      for _, c in pairs(util.adjacentCoords(self.x, self.y)) do
	 local targ = game.level.map(c[1], c[2], engine.Map.ACTOR)
	 if targ and self:reactionToward(targ) < 0 then victims[#victims+1] = targ end
      end
      if #victims > 0 then
	 self:startTalentCooldown(t)
         local shield, shield_combat = self:hasShield()
         local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
         if not shield then
            self:attackTarget(rng.table(victims), DamageType.REK_WYRMIC_FIRE, t.getDamage(self, t), true)
         else
            self:attackTargetWith(rng.table(victims), weapon, DamageType.REK_WYRMIC_FIRE, t.getDamage(self, t))
            self:attackTargetWith(rng.table(victims), shield_combat, DamageType.REK_WYRMIC_FIRE, t.getDamage(self, t))
         end
      end
   end,

   info = function(self, t)
      local resist = t.getResists(self, t)
      local damage = t.getDamage(self, t)*100
      local cooldown = t.cooldown(self,t)
      return ([[You can take on the power of Fire Wyrms, giving you %d%% fire resistance.
When you hit an enemy with a melee attack, you immediately follow up, making another attack against a random adjacent enemy doing %d%% damage as Flame.  This will also attack with your shield, if you have one equipped. This can only happen once every %d turns.

Flame damage can inflict stun (#SLATE#Mindpower vs. Physical#LAST#).  
Flame does 10%% bonus damage. 
25%% of Flame damage is applied as a burn over the next few turns.
]]):format(resist, damage, cooldown)
   end,
}

newTalent{
   name = "Devouring Flame", short_name = "REK_WYRMIC_FIRE_HEAL",
   type = {"wild-gift/wyrm-fire", 2},
   require = {
      stat = { wil=function(level) return 22 + (level-1) * 2 end },
      level = function(level) return 10 + (level-1) end,
      special =
	 {
	    desc="Advanced aspect talents learnable",
	    fct=function(self) 
	       return self:knowTalent(self.T_REK_WYRMIC_FIRE_HEAL)
		  or self.unused_talents_types >= 1
	    end
	 },
   },
   points = 5,
   mode = "passive",
   getLeech = function(self, t) return self:combatTalentScale(t, 1, 3) end,
   getMaxHeal = function(self, t) return self:combatTalentMindDamage(t, 20, 120) end,
   on_learn = function(self, t) onLearnHigherAbility(self, t) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self, t) end,
   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      local burning = false
      for eff_id, p in pairs(target.tmp) do
	 local e = target.tempeffect_def[eff_id]
	 if e.subtype.fire and p.power and e.status == "detrimental" then
	    burning = true
	    break
	 end
      end
      if not burning then return end
      
      local cap = t.getMaxHeal(self, t)
      local used = self.turn_procs.rek_wyrmic_fire_heal or 0
      if used > 0 then cap = cap - used end
      if used < cap then
         local amt = t.getLeech(self, t) * val / 100
         self:attr("allow_on_heal", 1)
         self:heal(amt, self)
         self:attr("allow_on_heal", -1)
         self.turn_procs.rek_wyrmic_fire_heal = used + amt
      end
   end,
   
   info = function(self, t)
      local notice = (self:getTalentLevelRaw(t) == 1000 or (self:getTalentLevelRaw(t) < 2)) and [[


#YELLOW#Learning the advanced flame talents costs a category point.#LAST#]] or ""
return ([[The fire wyrm is sutained by destruction.  All damage you do to burning targets heals you for %d%% of the damage done, up to a maximum of %d healed each turn.%s]]):format(t.getLeech(self, t), t.getMaxHeal(self, t), notice)
   end,
}

newTalent{
   name = "Renewing Inferno", short_name = "REK_WYRMIC_FIRE_KNOCKBACK",
   type = {"wild-gift/wyrm-fire", 3},
   require = gifts_req_high2,
   points = 5,
   cooldown = 18,
   tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 2 } },
   direct_hit = true,
   requires_target = true,
   range = 0,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 28, 180) end,
   getEqGain = function(self, t) return math.floor(self:combatTalentScale(t, 10, 28, 0.75)) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local grids = self:project(tg, self.x, self.y, DamageType.REK_WYRMIC_FIRE_KNOCKBACK, {dist=3, dam=self:mindCrit(t.getDamage(self, t))})
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
      game:playSoundNear(self, "talents/fire")

      local ember_cd = self.talents_cd["T_REK_WYRMIC_FIRE"]
      if ember_cd then self.talents_cd["T_REK_WYRMIC_FIRE"] = 0 end

      local tg = {type="ball", nolock=true, range=0, radius = 10, friendlyfire=true}
      local burncount = 0
      self:project(tg, self.x, self.y, function(px, py)
		      local target = game.level.map(px, py, engine.Map.ACTOR)
		      if not target then return end
		      local burns = {}
		      for eff_id, p in pairs(target.tmp) do
			 local e = target.tempeffect_def[eff_id]
			 if e.subtype.fire and p.power and e.status == "detrimental" then
			    burns[#burns+1] = {id=eff_id, params=p}
			    burncount = burncount + 1
			 end
		      end
		      for i, d in ipairs(burns) do
			 target:removeEffect(d.id)
		      end
      end)

      self:incEquilibrium(-1 * t.getEqGain(self, t)*(2-0.5^burncount))
      
      return true
   end,
   
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local radius = self:getTalentRadius(t)
      local eq = t.getEqGain(self, t)
      return ([[Erupt with a wave of flames with a radius of %d, knocking back and stunning (#SLATE#Mindpower vs. Physical#LAST#) any targets caught inside and burning them for %0.1f flame damage.

Then, recover between %d and %d equilibrium, increased for each burning creature within 10 spaces.

Using this talent resets the cooldown of Flickering Embers.]]):format(radius, damDesc(self, DamageType.FIRE, damage), eq, eq*2)
   end,
}

newTalent{
	name = "Scorched Speed", short_name = "REK_WYRMIC_FIRE_INFERNO",
	type = {"wild-gift/wyrm-fire", 4},
	require = gifts_req_high3,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 12,
	cooldown = 20,
	tactical = { BUFF = 1},
	getLifePercent = function(self, t) return self:combatTalentLimit(t, .1, .25, .125) end,
	getTurn = function(self, t) return util.bound(50 + self:combatTalentMindDamage(t, 5, 500) / 10, 50, 160) end,
	callbackOnAct = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if not p.last_life then p.last_life = self.life end
		local min = self.max_life * t.getLifePercent(self, t)
		if self.life <= p.last_life - min then
			if core.shader.active(4) then
				local bx, by = self:attachementSpot("back", true)
				self:addParticles(Particles.new("shader_wings", 1, {x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
			game.logSeen(self, "#ORANGE#%s is energized by all the damage taken!", self.name:capitalize())
			self.energy.value = self.energy.value + (t.getTurn(self, t) * game.energy_to_act / 100)
			
			local ember_cd = self.talents_cd["T_REK_WYRMIC_FIRE"]
			if ember_cd then self.talents_cd["T_REK_WYRMIC_FIRE"] = 0 end
			
		end
		p.last_life = self.life
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local ret = {name = self.name:capitalize().."'s "..t.name}
		ret.last_life = self.life
		
		if core.shader.active(4) then
			ret.particle1 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="fireice_nova"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=22000, noup=2.0, verticalIntensityAdjust=-3.0}))
			ret.particle1.toback = true
			ret.particle2 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="fireice_nova"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=22000, noup=1.0, verticalIntensityAdjust=-3.0}))
		end
		
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end
		return true
	end,
	info = function(self, t)
		local threshold = t.getLifePercent(self, t) * 100
		local turn = t.getTurn(self, t)
		return ([[The Fire Wyrm is driven into a frenzy by violence and danger.
		At the start of each turn in which you have lost at least %d%% of your maximum life since your last turn, you will gain %d%% of a turn and Flickering Embers will recharge immediately.]]):
			format(threshold, turn)
	end,
}
