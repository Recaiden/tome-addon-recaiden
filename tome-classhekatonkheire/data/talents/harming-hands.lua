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
	invest_hands = true,
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
		target:setEffect(target.EFF_REK_HEKA_GRASPED, t:_getDuration(self), {power=t:_getDamage(self), health=t:_getHealth(self), silence=choke and 1 or 0, savepower=self:combatPhysicalpower(), src=self})
		if choke then
			game:onTickEnd(function() 
											 self:removeEffect(self.EFF_REK_HEKA_CHOKE_READY)
										 end)
		end
		game:onTickEnd(function() 
										 self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
																		{investitures={{power=util.getval(t.hands, self, t)}}, src=self})
									 end)
		return true
	end,
	info = function(self, t)
		return ([[Send out your other hands to grab a creature, dealing %d physical damage per turn and pinning them in place for %d turns.  While grasped the creature deals %d%% less damage to others, and each turn can make a physical save to reduce the grasp's duration.

This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), t.getDuration(self, t), 10, t:_getHealth(self))
	end,
}

newTalent{
	name = "Inexorable Pull", short_name = "REK_HEKA_HARMING_INEXORABLE_PULL",
	type = {"technique/harming-hands", 2}, require = str_req2, points = 5,
	speed = "weapon",
	hands = 10,
	invest_hands = true,
	tactical = { CLOSEIN = 1 },
	cooldown = 5,
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 2, 6)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		if not target:attr("never_move") then
			game.logPlayer(target, "Target isn't pinned.")
			return nil
		end
		-- Manually test knockback immunity because we're ignoring the pin
		if rng.percent(100 - (target:attr("knockback_immune") or 0)) then
			target:pull(self.x, self.y, 2)
			target:setEffect(target.EFF_REK_HEKA_PULLED, t:_getDuration(self), {src=self})
		else
			game.logSeen(target, "#ORCHID#%s resists the hands' pull!", target:getName():capitalize())
		end
		
		game:onTickEnd(function() 
										 self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
																		{investitures={{power=util.getval(t.hands, self, t)}}, src=self})
									 end)
		return true
	end,

	info = function(self, t)
		return ([[Draw your hands in to reunite with your body.
Target a pinned creature and pull it 2 spaces towards you immediately, and 1 space per turn for %d turns (#SLATE#checks knockback resistance#LAST#).  The effect will end if they become un-pinned.]]):tformat(t.getDuration(self, t))
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
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 20, 200) end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 0.66, 0.30, 0.50) end,
	getSlowDuration = function(self, t) return 5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, 2, "circle", {appear_size=0, base_rot=0, a=250, appear=6, limit_life=4, speed=0, img="hurricane_throw", radius=-0.3})
		self:project(tg, x, y, DamageType.GRAVITY, {dam=self:physicalCrit(t:_getDamage(self)), slow=t:_getSlow(self), dur=t:_getSlowDuration(self)}, {type="bones"})
		return true
	end,
	info = function(self, t)
		return ([[Twist through impossible rotations to slam the ground at high speed, sending out a shockwave that does %0.1f physical damage in radius %d and slows enemies by %d%% for %d turns.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), self:getTalentRadius(t), t:_getSlow(self)*100, t:_getSlowDuration(self))
	end,
}

newTalent{
	name = "Hundred Hand Hurricane", short_name = "REK_HEKA_HARMING_FRENZY",
	type = {"technique/harming-hands", 4}, require = str_req4, points = 5,
	cooldown = function(self, t) return 15 end,
	range = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	mode = "sustained",
	drain_hands = 20,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 1.2) end,
	target = function(self, t) return {type="ball", range=0, friendlyfire=false, radius=self:getTalentRange(t), talent=t} end,
	doPunch = function(self, t)
		if self:getHands() < t.drain_hands then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end
		
		local tg = self:getTalentTarget(t)
		
		self:project(tg, self.x, self.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					self:attackTarget(target, nil, t.getDamage(self, t), true, true)
				end
			end)
	end,
	callbackOnActEnd = function(self, t)
		t.doPunch(self, t)
	end,
	activate = function(self, t)
		--t.doPunch(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		if self:knowTalent(self.T_REK_HEKA_HELPING_HEALING) then
			self:callTalent(self.T_REK_HEKA_HELPING_HEALING, "doHeal", 20)
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Reach into the world with all your hands, and pummel enemies within %d spaces for %d%% unarmed damage every turn.
This talent will deactivate if you run out of hands.]]):tformat(self:getTalentRange(t), t.getDamage(self, t)*100)
	end,
}