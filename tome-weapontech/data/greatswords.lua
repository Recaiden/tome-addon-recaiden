greatswordPreUse = function(self, t, silent)
	if not self:hasTwoHandedWeapon() or not self:hasWeaponType("sword") then
		if not silent then
			game.logPlayer(self, "You require a two handed sword to use this talent.")
		end
		return false
	end
			return true
end

newTalent{
	name = "Thrust", short_name = "REK_WTEK_GREATSWORD_THRUST",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 2 },
	is_melee = true,
	range = 2,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = greatswordMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.00, 1.00) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		self.turn_procs.auto_melee_hit = true
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		self.turn_procs.auto_melee_hit = nil

		return true
	end,
	info = function(self, t)
		return ([[Grip your sword higher-up the blade and stab into an enemy for %d%% damage.  This attack always hits.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Murderstroke", short_name = "REK_WTEK_GREATSWORD_MORDHAU",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = greatswordMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 0.9) end,
	getAPR = function(self, t) return 10+math.floor(self.level / 5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local id_pen = self:addTemporaryValue("combat_apr", t.getAPR(self, t))
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead and target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
		self:removeTemporaryValue("combat_apr", id_pen)
		
		return true
	end,
	info = function(self, t)
		return ([[Flip your sword around and wield it as an armor-crushing maul, dealing %d%% damage with %d extra armor penetration and stunning the target for 1 turn.]]):format(t.getDamage(self, t)*100, t.getAPR(self, t))
	end,
}

newTalent{
	name = "Gustblade", short_name = "REK_WTEK_GREATSWORD_GUSTBLADE",
	type = {"technique/weapon-techniques", 3}, require = str_req3, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	is_melee = true,
	range = 0,
	radius = 1,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = greatswordOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.05, 1.05) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
				if hit and not target.dead then target:setEffect(target.EFF_OFFGUARD, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {radius=1, img="spinningwinds_blue"}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around to slash all adjacent targets, dealing %d%% damage and trying to knock them off-guard, increasing critical-hit chance against them.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Lancing Blade", short_name = "REK_WTEK_GREATSWORD_LANCE",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1,
	speed = "weapon",
	cooldown = 3,
	on_pre_use = greatswordOHPreUse,
	tactical = { ATTACKARE = { weapon = 1 } },
	is_melee = true,
	range = 2,
	target = function(self, t)
		return {type="line", range=self:getTalentRange(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = {}
		self:project(
			tg, self.x, self.y,
			function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= self then
					targets[#targets+1] = target
				end
			end)
		for i, target in ipairs(targets) do
			self:attackTarget(target, nil, t.getDamage(self, t)*(1+#targets*0.1), true)
		end

		return true
	end,
	info = function(self, t)
		return ([[Strike out against all targets in a short line, dealing %d%% damage, increased by %d%% per target.]]):format(t.getDamage(self, t)*100, 10)
	end,
}
