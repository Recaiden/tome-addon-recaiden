local Object = require "mod.class.Object"

function useFinalMoment(self)
   local combat = {
      talented = "sword",
      sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},

      wil_attack = true,
      damrange = 1.5,
      physspeed = 1,
      dam = 16,
      apr = 0,
      atk = 0,
      physcrit = 0,
      dammod = {str=1.0, cun=0.3},
      melee_project = {},
   }
   if self:knowTalent(self.T_REK_MTYR_MOMENT_CUT) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_CUT)
      combat.dam = 16 + t.getBaseDamage(self, t)
      combat.apr = 0 + t.getBaseApr(self, t)
      combat.physcrit = 0 + t.getBaseCrit(self, t)
      combat.atk = 0 + t.getBaseAtk(self, t)
   end
   if self:knowTalent(self.T_REK_MTYR_MOMENT_DASH) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_DASH)
      combat.atk = t.getAttackTotal(self, t)
   end
   if self:knowTalent(self.T_REK_MTYR_MOMENT_STOP) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_STOP)
      combat.melee_project = { [engine.DamageType.ITEM_TEMPORAL_ENERGIZE] = t.getChance(self, t) }
   end
   if self:knowTalent(self.T_REK_MTYR_MOMENT_BLOCK) then
      combat.talent_on_hit = { T_REK_MTYR_MOMENT_CUT = {level=self:getTalentLevel(self.T_REK_MTYR_MOMENT_BLOCK), chance=20} }
   end
   return combat
end

-- tactical value (between 1 and 3) for a Moment attack, accounting for various talent enhancements
function moment_tactical(self, t)
   return "PHYSICAL", 1 + util.bound(self:getTalentLevelRaw(self.T_REK_MTYR_MOMENT_CUT) + self:getTalentLevelRaw(self.T_REK_MTYR_MOMENT_DASH)/2 + self:getTalentLevelRaw(self.T_REK_MTYR_MOMENT_BLOCK)/2, 0, 10)/5
end

newTalent{
   name = "Cut Time", short_name = "REK_MTYR_MOMENT_CUT",
   type = {"demented/moment", 1},
   points = 5,
   require = str_req_high1,
   cooldown = 6,
   insanity = -10,
   range = 0,
   no_energy = true,
   requires_target = true,
   radius = function(self, t) return 1 end,
   tactical = { ATTACK = { [moment_tactical] = 1 } },
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.8) end,
   getBaseDamage = function(self, t) return self:combatTalentMindDamage(t, 0, 60) end,
   getBaseAtk = function(self, t) return self:combatTalentMindDamage(t, 0, 20) end,
   getBaseApr = function(self, t) return self:combatTalentMindDamage(t, 0, 20) end,
   getBaseCrit = function(self, t) return self:combatTalentMindDamage(t, 0, 20) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)

      game.level.map:particleEmitter(self.x, self.y, 2, "circle", {oversize=0, appear=8, limit_life=24, base_rot=0, img="mtyr_clock_face", speed=0, radius=2})
      game.level.map:particleEmitter(self.x, self.y, 2, "circle", {oversize=0, appear=8, limit_life=24, img="mtyr_hour_hand", speed=1.0, radius=2})
      game.level.map:particleEmitter(self.x, self.y, 2, "circle", {oversize=0, appear=8, limit_life=24, img="mtyr_minute_hand", speed=12.0, radius=2})

      self:project(tg, self.x, self.y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
                         --self:attackTarget(target, nil, t.getDamage(self, t), true)

			 self:attackTargetWith(target, useFinalMoment(self), nil, t.getDamage(self, t))
		      end
                                       end)
      game:playSoundNear(self, "talents/rek_triple_tick")

      
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local weapon_stats = Object:descCombat(self, {combat=useFinalMoment(self)}, {}, "combat")
      local descI = ([[
You think of the sword.  

					The world stands still. 

You are holding a sword.

					The sword slices through everyone around you (%d%%). 

You are not holding the sword.

					The world is in motion.
#YELLOW#Regain your sanity to better understand this talent.#LAST#

The sword springs from your mind.  Behold!
		%s
]]):format(damage * 100, tostring(weapon_stats))
			local descS = ([[Summon an impossible sword, the Final Moment, and use it to strike everyone adjacent to you for %d%% weapon damage.
Mindpower: improves damage, accuracy, armor penetration, critical chance.

		Current Final Moment Stats:
		%s]]):format(damage * 100, tostring(weapon_stats))
			return amSane(self) and descS or descI
   end,
         }

newTalent{
	name = "Cut Space", short_name = "REK_MTYR_MOMENT_DASH",
	type = {"demented/moment", 2},
	points = 5,
	require = str_req_high2,
	cooldown = 18,
	insanity = 11,
	tactical = { ATTACKAREA = { [moment_tactical] = 1 } },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	requires_target = true,
	proj_speed = 10,
	speed = "weapon",
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t, nolock=true} end,
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getAttack = function(self, t) return self:getTalentLevel(t) * 10 end,
	getAttackTotal = function(self, t)
		local base_atk = 0
		if self:knowTalent(self.T_REK_MTYR_MOMENT_CUT) then
			local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_CUT)
			base_atk = 0 + t.getBaseAtk(self, t)
		end
		return base_atk + t.getAttack(self, t)
	end,
	getDurSword = function(self, t) return 4 end,
	getFinalMoment = function(self, t) return useFinalMoment(self) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTargetLimited(tg)
		if not tx or not ty then return nil end
		if not self:canProject(tg, tx, ty) then return nil end
		if game.level.map(tx, ty, engine.Map.ACTOR) then return nil end
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") then return nil end
		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if self:attr("defense_on_teleport") or self:attr("resist_all_on_teleport") or self:attr("effect_reduction_on_teleport") then
			self:setEffect(self.EFF_OUT_OF_PHASE, 5, {})
		end
		self:fireTalentCheck("callbackOnTeleport", true, ox, oy, self.x, self.y)
		if ox == self.x and oy == self.y then return end
		
		self:project(
			{type="beam", range=100}, ox, oy,
			function(px, py)
				local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
				local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_DASH)
				if tmp_target and tmp_target ~= self then
					self:attackTargetWith(tmp_target, t.getFinalMoment(self, t), nil, t.getDamage(self, t))
				end
			end)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(ox-self.x), math.abs(oy-self.y)), "rek_time_beam", {tx=ox-self.x, ty=oy-self.y})
		
		--create sword at ox, oy
		local map_eff = game.level.map:addEffect(
			self, ox, oy, t.getDurSword(self, t), DamageType.COSMETIC, 
			{dam = t.getDamage(self, t), radius = 0, self = self, talent = t}, 
			0, 5, nil, 
			{type="warning_ring", args ={radius = 1, r=45, g=15, b=110, nb=10, size=8}},
			
			function(e, update_shape_only)
				if not update_shape_only and e.duration == 1 then
					local DamageType = require("engine.DamageType")
					if e.src then
						e.src.__project_source = e
						local grids = e.src:project(
							{type="beam", range=100}, e.x, e.y,
							function(px, py)
								local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
								local t = e.src:getTalentFromId(e.src.T_REK_MTYR_MOMENT_DASH)
								if t and tmp_target and tmp_target ~= e.src then
									e.src:attackTargetWith(tmp_target, t.getFinalMoment(e.src, t), nil, t.getDamage(e.src, t))
								end
							end)
						game.level.map:particleEmitter(e.x, e.y, math.max(math.abs(e.src.x-e.x), math.abs(e.src.y-e.y)), "rek_time_beam", {tx=e.src.x-e.x, ty=e.src.y-e.y})
						
					end
					e.src.__project_source = nil
					e.duration = 0
					for _, ps in ipairs(e.particles) do game.level.map:removeParticleEmitter(ps) end
					e.particles = nil
					game:playSoundNear(self, "talents/frog_slowdown")
				end
			end)
		map_eff.name = t.name
		
		game:playSoundNear(self, "talents/frog_speedup")
		return true
	end,
	info = function(self, t)
		local descI = ([[
The sword goes out before you, %d paces.

					The sword cuts all in its path (%d%%).
					You come to the blade.

The sword is behind you.

					It waits.
					It waits.

The sword comes to you.

					The sword cuts all in its path once more.
					You are together.

You are not holding a sword.                                        

Strikes with the sword grow more accurate (%d).
#YELLOW#Regain your sanity to better understand this talent.#LAST#]]):format(self:getTalentRange(t), t.getDamage(self, t) * 100, t.getAttack(self, t))
		local descS = ([[Throw the Final Moment up to %d spaces, attacking all targets in a line for %d%% weapon damage and teleporting yourself to the end of the line.  2 turns later, repeat the attack against all targets between your original position and your current position.                              

Learning this talent increases the Accuracy of your Final Moment by %d]]):format(self:getTalentRange(t), t.getDamage(self, t) * 100, t.getAttack(self, t))
		return amSane(self) and descS or descI
	end,
}

newTalent{
	name = "Cut Fate", short_name = "REK_MTYR_MOMENT_STOP",
	type = {"demented/moment", 3},
	points = 5,
	require = str_req_high3,
	cooldown = 18,
	fixed_cooldown = true,
	mode = "passive",
	getFinalMoment = function(self, t) return useFinalMoment(self) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end,
	getGain = function(self, t) return math.min(5, 1+self:combatTalentMindDamage(t, 0.1, 2.2)) end,
	doStop = function(self, t)
		if self:isTalentCoolingDown(t) then return end
		game:playSoundNear(self, "talents/roat_luna_dial")
		self.energy.value = self.energy.value + game.energy_to_act * t.getGain(self, t)
		self:startTalentCooldown(t)
		self:setEffect(self.EFF_REK_MTYR_MOMENT_WIELD, 1, {src=self})
	end,
	callbackPriorities = {callbackOnHit = -20},
	callbackOnHit = function(self, t, cb, src)
		if cb.value >= (self.life) then
			t.doStop(self, t)
		end
		return cb.value
	end,
	info = function(self, t)
		local descI = ([[
You lose your life or your sanity.

					The world stands still.

You are holding a sword.

					The world remains still.

You have %0.2f breaths.

Strikes with the sword may grant you a tenth of a breath (%d%%).
#YELLOW#Regain your sanity to better understand this talent.#LAST#]]):format(t.getGain(self, t), t.getChance(self, t))
		local descS = ([[If you would gain insanity beyond your maximum, or would take damage exceeding your current health, time stops, granting you %0.2f turns.  While time is stopped, you use the Final Moment for all your attacks.
Mindpower: improves turn gain

This effect has a cooldown.

All attacks with the Final Moment have %d%% to grant you 10%% of a turn (up to 3 times per turn).
]]):format(t.getGain(self, t), t.getChance(self, t))
		return amSane(self) and descS or descI
	end,
}

newTalent{
	name = "Cut Danger", short_name = "REK_MTYR_MOMENT_BLOCK",
	type = {"demented/moment", 4},
	points = 5,
	require = str_req_high4,
	cooldown = 8,
	insanity = -15,
	speed = "weapon",
	tactical = { ATTACK = {[moment_tactical] = 1}, ATTACKAREA = { TEMPORAL = 1} },
	getFinalMoment = function(self, t) return useFinalMoment(self) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getBlock = function(self, t) return self:combatTalentMindDamage(t, 20, 120) end,
	getProject = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_MTYR_MOMENT_COUNTER, 1, {src=self, power=self:mindCrit(t.getBlock(self, t)), dam=t.getDamage(self, t)})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local descI = ([[
Danger approaches.

					Your thoughts protect you, your sword is your shield.

The danger strikes you, weakened by %d.

					Your sword strikes back (%d%%).

Strikes with the sword may strike again.
#YELLOW#Regain your sanity to better understand this talent.#LAST#]]):format(t.getBlock(self, t), damage * 100)
		local descS = ([[Summon the Final Moment to block incoming attacks.  For 1 turn, all incoming damage is reduced by %d and you will counterattack using the Final Moment for %d%% damage, even at range.  The counterattack can only happen once per attacker.
Mindpower: increases damage blocked
Mental Critical: increases damage blocked

Learning this talent gives attacks with the Final Moment a 20%% chance to trigger Cut Time (talent level %0.1f)]]):format(t.getBlock(self, t), damage * 100, self:getTalentLevel(t))
		return amSane(self) and descS or descI	
	end,
}