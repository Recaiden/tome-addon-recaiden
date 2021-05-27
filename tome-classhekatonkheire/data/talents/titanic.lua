newTalent{
	name = "Scattering Wave", short_name = "REK_HEKA_TITANIC_SCATTER",
	type = {"technique/titanic-blows", 1}, require = str_req1, points = 5,
	tactical = { ATTACK = { weapon = 2 }, ATTACKAREA = { weapon = 1 } },
	hands = 20,
	cooldown = 8,
	radius = 2,
	range = 1,
	is_melee = true,
	target = function(self, t) return {type="ball", talent=t, range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false} end,
	getDuration = function (self, t) return 3 end,
	getKnockback = function (self, t) return 2 end,
	getDamageHit = function (self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.8) end,
	getDamageSplash = function (self, t) return self:combatTalentWeaponDamage(t, 0.1, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, targetMain = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:canProject(tg, x, y) then return nil end
		local wrath = self:hasEffect(self.EFF_REK_HEKA_TOWERING_WRATH)

		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "spiky_shockwave", {tx=x-self.x, ty=y-self.y}, nil, 5)
		
		if targetMain then
			local hit = self:attackTarget(targetMain, nil, t.getDamageHit(self,t), true)
			if hit and targetMain:canBe("pin") then
				targetMain:setEffect(targetMain.EFF_PINNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), src=self})
			end
		end
		
		local actors = {}
		-- collect everyone affected
		self:project(
			tg, x, y,
			function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if target and target ~= targetMain then
					self:attackTarget(target, nil, t.getDamageSplash(self,t), true)
					local dist_sq = (target.x - self.x)^2 + (target.y - self.y) ^ 2
					actors[#actors+1] = {actor=target, dist_sq=dist_sq}
				end
			end)
		--sort actors
		table.sort(actors, function(a, b) return a.dist_sq > b.dist_sq end)
		
		--apply knockback
		for i = 1, #actors do
			local act = actors[i].actor
			if core.fov.distance(self.x, self.y, act.x, act.y) > 1 then
				if not act.dead and act:canBe("knockback") then
					act:knockback(self.x, self.y,  t.getKnockback(self, t))
					if wrath then
						act:setEffect(act.EFF_PINNED, 1, {src=self})
					end
				end
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Smash your weapon into the earth, sending foes flying. Anyone at the center of the impact is hit for %d%% damage and pinned (#SLATE#Physical vs Physical#LAST#) for %d turns.  Other enemies within radius %d are hit for %d%% and knocked back %d spaces.  
If you had Towering Wrath active, enemies knocked back are also pinned for 1 turn.]]):tformat(t.getDamageHit(self, t)*100, t.getDuration(self, t), self:getTalentRadius(t), t.getDamageSplash(self, t)*100, t.getKnockback(self, t))
	end,
}

newTalent{
	name = "Sundering Blast", short_name = "REK_HEKA_TITANIC_SUNDER",
	type = {"technique/titanic-blows", 2}, require = str_req2, points = 5,
	speed = "weapon",
	hands = 20,
	tactical = { ATTACK = { weapon = 2}, DISABLE = 1 },
	cooldown = 6,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentScale(t, 1.0, 1.8) end,
	getResistPenalty = function(self, t) return 30 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		-- set flag if towering wrath
		local eff = self:hasEffect(self.EFF_REK_HEKA_TOWERING_WRATH)
		if eff then
			local effs = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.status == "beneficial" and e.subtype and e.subtype.shield then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
			
			for i = 1, #effs do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)
				
				if eff[1] == "effect" then
					game.logSeen(self, "#CRIMSON#%s shatters %s shield!", self:getName():capitalize(), target:getName())
					target:removeEffect(eff[2])
				end
			end
		end
		
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit then
			target:setEffect(target.EFF_REK_HEKA_SUNDERED_RESISTANCES, 5, {power=t.getResistPenalty(self, t), src=self})
		end

		return true
	end,
	info = function(self, t)
		return ([[If you have Towering Wrath active, you shatter any temporary damage shield protecting the target.
Then, smash your weapon down, dealing %d%% damage and wounding them, lowering their resistances by %d%% for 5 turns (#SLATE#No save#LAST#).]]):tformat(t.getDamage(self, t)*100, t.getResistPenalty(self, t))
	end,
}

newTalent{
	name = "Skewer", short_name = "REK_HEKA_TITANIC_SKEWER",
	type = {"technique/titanic-blows", 3}, require = str_req3, points = 5,
	cooldown = 5,
	hands = 15,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7.5)) end,
	tactical = { ATTACK = 1 },
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true, talent = t} end,
	getDamage = function(self, t) return 1.5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local aprid = self:addTemporaryValue("combat_apr", 1000)
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit then
			game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=target.blood_color})
			game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=target.blood_color})
			game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=target.blood_color})
		end
		self:removeTemporaryValue("combat_apr", aprid)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Coat your weapon in #{italic}#displacement#{normal}# and attack an enemy from the inside, dealing %d%% damage that ignores up to 1000 points of armor.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Immersion", short_name = "REK_HEKA_TITANIC_IMMERSION",
	type = {"technique/titanic-blows", 4},	require = str_req4, points = 5,
	cooldown = function(self, t) return 15 end,
	hands = 30,
	range = 1,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 3 },
	--no_npc_use = true,
	is_melee = true,
	on_learn = function(self, t) self:attr("show_gloves_combat", 1) end,
	on_unlearn = function(self, t) self:attr("show_gloves_combat", -1) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 1.2) end,
	getDamageImmersion = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.6) end,
	getRes = function(self, t) return 80 - math.floor(self:combatTalentLimit(t, 40, 5, 20)) end,
	getNumb = function(self, t) return 40 + math.floor(self:combatTalentLimit(t, 40, 5, 20)) end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead then
			target:setEffect(target.EFF_REK_HEKA_IMMERSED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), dam=t.getDamageImmersion(self, t), resist=t.getRes(self, t), numb=t.getNumb(self, t), src=self})
			game:onTickEnd(function() 
											 self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
																			{investitures={{power=util.getval(t.hands, self, t)}}, src=self})
										 end)
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Hit an enemy for %d%% damage and knock them partway into the Other Place (#SLATE#Physical vs Spell#LAST#) for %d turns. Each turn while there, they suffer an unarmed attack for %d%% damage, all other damage they take is reduced by %d%%, and all damage they deal is reduced by %d%%.

This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(t.getDamage(self, t)*100, t.getDuration(self, t), t.getDamageImmersion(self, t)*100, t.getRes(self, t), t.getNumb(self, t))
	end,
}
