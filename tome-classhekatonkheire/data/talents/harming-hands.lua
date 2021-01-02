newTalent{
	name = "Titan's Grasp", short_name = "REK_HEKA_HARMING_TITANS_GRASP",
	type = {"technique/harming-hands", 1}, require = str_req1, points = 5,
	tactical = { DISABLE = 2 },
	speed= "weapon",
	cooldown = 8,
	hands = function(self, t)
		if self:hasEffect(self.EFF_REK_HEKA_CHOKE_READY) then return 30 end
		return 20
	end,
	range = 10,
	requires_target = true,
	getDuration = function (self, t) return 6 end,
	getDamage = function (self, t) return self:combatTalentPhysicalDamage(t, 20, 100) end,
	getHealth = function (self, t) return self:combatTalentPhysicalDamage(t, 20, 300) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true, talent = t} end,
	getBlock = function(self, t) return self:combatTalentScale(t, 30, 200) * (1 + self.level/50) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local choke = self:hasEffect(self.EFF_REK_HEKA_CHOKE_READY)
		target:setEffect(target.EFF_REK_HEKA_GRASPED, t:_getDuration(self), {power=t:_getDamage(self), health=t:_getHealth(self), silence=choke and 1 or 0, src=self})
		if choke then
			game:onTickEnd(function() 
											 self:removeEffect(self.EFF_REK_HEKA_CHOKE_READY)
										 end)
		end
		game:onTickEnd(function() 
										 self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self), {cost=util.getval(t.hands, self, t), src=self})
									 end)
		return true
	end,
	info = function(self, t)
		return ([[Send out your other hands to grab a creature, dealing %d physical damage per turn and pinning them in place for %d turns.  %d%% of the damage the grasped creature would deal is instead redirected to the hands, and after taking %d damage the hands let go.

This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), t.getDuration(self, t), 10, t:_getHealth(self))
	end,
}

newTalent{
	name = "Inexorable Pull", short_name = "REK_HEKA_HARMING_INEXORABLE_PULL",
	type = {"technique/harming-hands", 2}, require = str_req2, points = 5,
	speed = "weapon",
	hands = 10,
	tactical = { CLOSEIN = 1 },
	cooldown = 5,
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 2, 6)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		if not target:attr("never_move") then return nil end
		if target:canBe("knockback") then
			src:pull(self.x, self.y, 2)			
		else
			game.logSeen(src, "#ORCHID#%s resists the hands' pull!", target:getName():capitalize())
		end
		target:setEffect(target.EFF_REK_HEKA_PULLED, t:_getDuration(self), {src=self})		
		game:onTickEnd(function() 
										 self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self), {cost=util.getval(t.hands, self, t), src=self})
									 end)
		return true
	end,

	info = function(self, t)
		return ([[Draw your hands in to reunite with your body.
Target a pinned creature and pull it 2 spaces towards you immediately, and 1 space per turn for %d turns (#SLATE#checks knockback resistance#LAST#).]]):tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Vortex Slam", short_name = "REK_HEKA_HARMING_VORTEX_SLAM",
	type = {"technique/harming-hands", 3}, require = str_req3, points = 5,
	hands = 25,
	tactical = { ATTACKAREA = { PHYSICAL = 1 } },
	cooldown = 12,
	range = 6,
	radius = 2,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return 1 end,
	getSlow = function(self, t) return 1 end,
	getSlowDuration = function(self, t) return 1 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, 2, "circle", {appear_size=0, base_rot=0, a=250, appear=6, limit_life=4, speed=0, img="hurricane_throw", radius=-0.3})
		self:project(tg, self.x, self.y, DamageType.GRAVITY, {dam=self:physicalCrit(t:_getDamage(self)), slow=t:_getSlow(self), dur=t:_getSlowDuration(self)}, {type="bones"})
		return true
	end,
	info = function(self, t)
		return ([[Grab an enemy and twist them through impossible rotations to slam into the ground at high speed, sending out a shockwave that does %0.1f physical damage in radius %d and slows enemies by %d%% for %d turns.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), self:getTalentRadius(t), t:_getSlow(self)*100, t:_getSlowDuration(self))
	end,
}

newTalent{
	name = "Hundred Fist Frenzy", short_name = "REK_HEKA_HARMING_FRENZY",
	type = {"technique/harming-hands", 4}, require = str_req4, points = 5,
	cooldown = function(self, t) return 15 end,
	range = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	mode = "sustained",
	drain_hands = 20,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 1.2) end,
	target = function(self, t) return {type="ball", range=0, friendlyfire=false, radius=self:getTalentRange(t), talent=t} end,
	doPunch = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		self:project(tg, x, y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					self:attackTarget(target, nil, t.getDamage(self, t), true)
				end
			end)
	end,
	activate = function(self, t)
		t.doPunch(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead then
			target:setEffect(target.EFF_REK_HEKA_IMMERSED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), dam=t.getDamageImmersion(self, t), resist=t.getRes(self, t), numb=t.getNumb(self, t), src=self})
		end
		return true
	end,
	deactivate = function(self, t, p)
		if self:knowTalent(self.T_REK_HEKA_HELPING_HEALING) then
			self:callTalent(self.T_REK_HEKA_HELPING_HEALING, "doHeal", 20)
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Reach into the world with all your hands, and pummel enemies within %d spaces for %d%% unarmed damage every turn.]]):tformat(self:getTalentRange(t), t.getDamage(self, t)*100)
	end,
}