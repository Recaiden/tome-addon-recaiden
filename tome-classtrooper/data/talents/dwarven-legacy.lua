local Object = require "engine.Object"
local Entity = require "engine.Entity"

newTalent{
	name = "Ancestral Tool Reserve", short_name = "REK_OCLT_TOOL_RESERVE",
	type = {"technique/dwarven-legacy", 1}, require = str_req1, points = 5,
	cooldown = 4,
	range = 1,
	requires_target = true,
	no_unlearn_last = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
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
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, self.x, self.y, function(px, py)
									 local target = game.level.map(px, py, Map.ACTOR)
									 if not target then return end
									 local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
									 if tx and ty and target:canBe("teleport") then
										 target:move(tx, ty, true)
										 game.logSeen(target, "%s is called to battle!", target:getName():capitalize())
									 end
		end)
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
	mode = "sustained",
	cooldown = 20,
	tactical = { BUFF = 1 },
	getPenalty = function(self, t) return 30 end,
	getCritBoost = function(self, t)
		local dex = self:combatStatScale("dex", 10/25, 100/25, 0.75)
		return (self:combatTalentScale(t, dex, dex*5, 0.5, 4))
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "combat_dam", -1 * t:_getPenalty(self))
		self:talentTemporaryValue(ret, "combat_physcrit", t:_getCritBoost(self))
		return ret
	end,
	deactivate = function(self, t, r)
		return true
	end,
	info = function(self, t)
		return ([[Fight with wild strikes that land less heavily, but are more likely to strike a weak point.  While sustained you lose %d physical power but gain +%d%% physical critical rate.  The benefit will increase with your Dexterity.]]):format(t_:getPenalty(self), t:_getCritBoost(self))
	end,
}

newTalent{
	name = "Rockslide Targeting", short_name = "REK_OCLT_TOOL_SHARPEN",
	type = {"technique/dwarven-legacy", 3}, points = 5, require = str_req3,
	mode = "passive",
	getMult = function(self, t) return self:combatTalentLimit(t, 1.75, 0.5, 1.4) end,
	getConThreshold = function(self, t) return math.max(15, 35 - 5*self:getTalentLevel(t)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_atk", t:getStat("con") * t:_getMult(self))
		if t:getStat("con") > t:_getConThreshold(self) then
			self:talentTemporaryValue(p, "blind_fight", 1)
		end
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_CON then self:updateTalentPassives(t) end
	end,
	info = function(self, t)
		return ([[Once you've chosen a target, nothing can deter you from striking it.
You gain raw Accuracy equal to %d%% of your Constitution.
With at least %d Constitution, you can fight while blinded or against invisible targets without penalty.]]):format(t.getMult(self, t)*100, t.getConThreshold(self, t))
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
