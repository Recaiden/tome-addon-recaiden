local function main_gun_cd(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].type[1] == "steamtech/battlewagon-guns" and (not self.talents_cd[tid] or self.talents_cd[tid] < 5) then
			self.talents_cd[tid] = 5
		end
	end
end

newTalent{
	name = "Harpoon Launcher", short_name = "REK_DEML_MG_HARPOON",
	type = {"steamtech/battlewagon-guns", 1},
	points = 5,
	cooldown = 5,
	steam = 20,
	tactical = { ATTACK = {PHYSICAL = 1}, CLOSEIN = 2 },
	requires_target = true,
	range = function(self, t) return math.min(10, self:combatTalentScale(t, 10, 5, 9)) end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t)} end,
	getDamage = function(self, t)
		return self:callTalent(self.T_REK_DEML_BATTLEWAGON_MAIN_GUNS, "getHarpoonDamage")
	end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "The target is out of range")
			return
		end
		local dam = self:steamCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.PHYSICALBLEED, dam)
		if target and target:canBe("knockback") then
			target:pull(self.x, self.y, tg.range)
		end
		
		game:playSoundNear(self, "talents/chain_hit")
		main_gun_cd(self, t.id)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Launch a harpoon at an enemy, doing %d damage and pulling them close to you.
Steampower: increases damage.]]):format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Gauss Cannon", short_name = "REK_DEML_MG_GAUSS",
	type = {"steamtech/battlewagon-guns", 1},
	points = 5,
	cooldown = 5,
	steam = 20,
	range = 10,
	tactical = { ATTACK = {LIGHTNING = 2} },
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t)
		return self:callTalent(self.T_REK_DEML_BATTLEWAGON_MAIN_GUNS, "getGaussDamage")
	end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:steamCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.REK_DEML_COILSHOCK, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning_beam", {tx=x-self.x, ty=y-self.y}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning_beam", {tx=x-self.x, ty=y-self.y})
		end
		game:playSoundNear(self, "talents/lightning")
		main_gun_cd(self, t.id)
		return true
	end,
	info = function(self, t)
		return ([[Launch a magnetic projectile at incredible speeds, doing %0.2f lightning damage (that ignores resistances) in a line.
Steampower: increases damage.]]):format(damDesc(self, DamageType.LIGHTNING, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Havoc Missiles", short_name = "REK_DEML_MG_MISSILE",
	type = {"steamtech/battlewagon-guns", 1},
	points = 5,
	cooldown = 5,
	steam = 20,
	range = function(self, t) return 10-self:getTalentRadius(t) end,
	radius = function(self, t)
		return self:callTalent(self.T_REK_DEML_BATTLEWAGON_MAIN_GUNS, "getMissileRadius")
	end,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = {STUN = 2} },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false}
	end,
	getDamage = function(self, t)
		return self:callTalent(self.T_REK_DEML_BATTLEWAGON_MAIN_GUNS, "getMissileDamage")
	end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		local dam = self:steamCrit(t.getDamage(self, t))
		if not tg or not tx or not ty then return nil end
		self:project(tg, tx, ty, DamageType.REK_DEML_FIRE_DAZE, dam)
		game.level.map:particleEmitter(
			tx, ty, self:getTalentRadius(t),
			"generic_ball", {img="particles_images/smoke_whispery_bright", size={8,20}, life=16, density=10, radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/fireflash")
		main_gun_cd(self, t.id)
		return true
	end,
	info = function(self, t)
		return ([[Fires a barrage of explosive missiles from your battlewagon at a radius %d area, dealing %0.2f fire damage and dazing those within for 2 turns (#SLATE#Steampower vs Physical#LAST#).
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}
