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
	name = "Close-Quarters Combat Mode", short_name = "REK_OCLT_TOOL_FRENZY",
	type = {"technique/dwarven-legacy", 2}, require = str_req2, points = 5,
	cooldown = 18,
	getDur = function(self, t) return 6 end,
	getAcc = function(self, t) return return self:combatTalentScale(t, 10, 50, 1.0) end,
	getSpeed = function(self, t) return 0.18 end,
	getStr = function(self, t) return self:combatTalentScale(t, 10, 30, 1.0) end,
	dofrenzy = function(self, t)
		self:setEffect(self.EFF_REK_OCLT_TOOL_FRENZY, t:_getDur(self), {src=self, acc=t:_getDur(self), speed=t:_getSpeed(self), power=t:_getStr(self)})
	end,
	action = function(self, t)
		t.doFrenzy(self, t)
		return true
	end,
	callbackOnTalentPost = function(self, t, ab)
		if not ab.battery then return end
		if self:getBattery() < 1 then
			t.doFrenzy(self, t)
			self:startTalentCooldown(t)
		end
	end,
	info = function(self, t)
		return ([[Ready yourself for hand-to-hand combat, granting you +%d accuracy, +%d%% global speed, and +%d strength for %d turns.

This talent activates automatically when your carbine battery becomes empty.]]):format(t_:getAcc(self), t:_getSpeed(self), t:_getStr(self), t:_getDur(self))
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
				target:setEffect(target.EFF_DISARMED, t.getDur(self, t), {src=self, apply_power=self:combatAttackStr()})
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
	name = "Demolition Protocol", short_name = "REK_OCLT_TOOL_DEMOLITION",
	type = {"technique/dwarven-legacy", 4}, points = 5, require = str_req4,
	cooldown = 18,
	range = 2,
	radius = 3
	tactical = { BUFF = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.8, 3.2) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		
		local tgts = {}
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				-- If we've already moved this target don't move it again
				for _, v in pairs(tgts) do
					if v == target then
						return
					end
				end

				-- pull
				if target:canBe("knockback") then
					target:pull(x, y, tg.radius)
					tgts[#tgts+1] = target
					game.logSeen(target, "%s is drawn into the sinkhole!", target:getName():capitalize())
				end
			end
		end)

		local shield, shield_combat = self:hasShield()							 
		local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
		-- Make attacks last
		self:project(
			tg, x, y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					if not shield then
						self:attackTarget(target, nil, t.getDamage(self, t), true)
					else
						self:attackTargetWith(target, weapon, nil, t.getDamage(self, t))
						self:attackTargetWith(target, shield_combat, nil, t.getDamage(self, t))
					end
				end
			end
		)
		return true
	end,

	info = function(self, t)
		return ([[Strike the earth and collapse the ground around you, dealing %d%% weapon damage in radius %d and creating a huge sinkhole that pulls in all creatures.]]):format(t.getDamage(self, t)*100, self:getTalentRadius(t))
	end,
}
