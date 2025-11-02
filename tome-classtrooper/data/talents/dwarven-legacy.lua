local Object = require "engine.Object"
local Entity = require "engine.Entity"

newTalent{
	name = "Ancestral Tool Reserve", short_name = "REK_OCLT_TOOL_RESERVE",
	type = {"technique/dwarven-legacy", 1}, require = str_req1, points = 5,
	cooldown = 4,
	no_unlearn_last = true,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.0) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.7) end,
	getSlow = function(self, t) return 50 end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(2,5)) end,
	modifyPick = function(self, t, pick)
		if pick.ancestral_tool then return end
		local ego = Entity.new{
			name = _t"sharpened",
			display_string = " (Weapon)",
			ancestral_tool = true,
			combat = {
				talented = "pick", accuracy_effect="knife", damrange = 1.3, physspeed = 1,
				-- todo new sound
				sound = {"actions/melee", pitch=1.2, vol=1.2}, sound_miss = {"actions/melee", pitch=1.2, vol=1.2}, 
				dam = resolvers.mbonus_material(10, 20),
				apr = 5,
				physcrit = 5,
				dammod = {str=1},
			}, 
			fake_ego = true, unvault_ego = true,
		}
		game.zone:applyEgo(pick, ego, "object")
		pick:resolve()
	end,

	requires_target = true,
	tactical = { ATTACK = 1, DISABLE = { wound = 3 } },
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a shield to use this talent.") end return false end return true end,
	getStunDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, nil, t:_getDamage(self), true)
		if hit then
			target:setEffect(target.EFF_CRIPPLE, t:_getDur(self), {src=self, speed=t:_getSlow(self)*0.01, apply_power=self:combatPhysicalpower()})
		end

		return true
	end,
	info = function(self, t)
		return ([[You can equip a pickaxe as a mainhand weapon.  When you make a pickaxe attack, you also attack with any offhand shield for %d%% damage.

Activate this talent to strike a crippling blow with your pickaxe for %d%% damage, slowing them by %d%% for %d turns.]]):tformat(t:_getShieldDamage(self)*100, t:_getDamage(self), t:_getSlow(self), t:_getDur(self))
	end,
}

newTalent{
	name = "Earthquake Stance", short_name = "REK_OCLT_TOOL_FRENZY",
	type = {"technique/dwarven-legacy", 2}, require = str_req2, points = 5,
	cooldown = 12,
	
	info = function(self, t)
		return ([[Fight with wild strikes that land less heavily, but are more likely to strike a weak point.  While sustained you lose %d physical power but gain +%d%% physical critical rate.  The benefit will increase with your Dexterity.]]):format(t_:getPenalty(self), t:_getCritBoost(self))
	end,
}

newTalent{
	name = "Cutting Edge Sharpening System", short_name = "REK_OCLT_TOOL_SHARPEN",
	type = {"technique/dwarven-legacy", 3}, points = 5, require = str_req3,
	getApr = function(self, t) return self:combatTalentScale(t, 10, 25) end,
	getConThreshold = function(self, t) return math.max(15, 35 - 5*self:getTalentLevel(t)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_apr", t:_getApr(self))
	end,

	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t, silent)
		if not self:hasShield() then
			if not silent then
				game.logPlayer(self, "You require a shield to use this talent.")
			end
			return false
		end
		return true
	end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.8, 2.6, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	action = function(self, t)
		local shield, shield_combat = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use this without a shield!")
			return nil
		end
		
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		
		local speed, hit = self:attackTargetWith(target, shield_combat, nil, t:_getDamage(self))
		-- todo whirring noise
		if hit then
			if target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, t.getDur(self, t), {apply_power=self:combatAttackStr()})
			else
				game.logSeen(target, "%s resists the disarm!", target:getName():capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Passively grants %d additional armor penetration.
You may activate this talent to mangle an enemy's weapon with the sharpener, doing %d%% shield damage and disarming them for %d turns.]]):format(t:_getApr(self), t:_getDamage(self)*100, t:_getDur(self))
	end,
}

newTalent{
	name = "Crushing Might", short_name = "REK_OCLT_TOOL_DEMOLITION",
	type = {"technique/dwarven-legacy", 4}, points = 5, require = str_req4,
	cooldown = 30,
	getDamageAmp = function(self, t)
		local weapon = nil
		if self:getInven("MAINHAND") then
			weapon = self:getInven("MAINHAND")[1]
		end

		local val = 30
		if weapon then
			val = val + self:combatDamage(weapon) * self:combatTalentScale(t, 0.3, 0.9)
		end
		return val
	end,
	getDuration = function(self, t) return 6 end,
	tactical = { BUFF = 2 },
	on_pre_use_ai = function(self, t) -- don't use out of combat
		local target = self.ai_target.actor
		if target and core.fov.distance(self.x, self.y, target.x, target.y) <= 10 and self:hasLOS(target.x, target.y, "block_move") then return true end
		return false
	end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_OCLT_MIGHT, t:_getDuration(self), {power=t.getDamageAmp(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Summon up reserves of strength to fight harder; for %d turns, your physical power is increased by %d.  This will increase with the damage of your mainhand weapon.]]):format(t.getDuration(self, t), t.getDamageAmp(self, t))
	end,
}
