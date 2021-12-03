newTalent{
	name = "Oculatus", short_name = "REK_HEKA_INTRUSION_EYE",
	type = {"spell/intrusion", 1}, require = mag_req1, points = 5,
	points = 5,
	cooldown = 3,
	hands = 15,
	tactical = { ATTACK = {PHYSICAL = 1}, BUFF = 1 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	getReduction = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getDuration = function(self, t) return 3 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		-- Project our damage
		self:project(tg, x, y, DamageType.PHYSICALBLEED, self:spellCrit(t.getDamage(self, t)))
		
		game.level.map:particleEmitter(x, y, 1, "otherside_teleport_gate_in", nil, nil, 15)
		game:playSoundNear(self, "talents/arcane")

		self:setEffect(self.EFF_REK_HEKA_OCULATUS, t:_getDuration(self), {power=t.getReduction(self, t)})

		-- invest cost
		game:onTickEnd(function() 
				self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
											 {investitures={{power=util.getval(t.hands, self, t)}}, src=self})
		end)
		
		return true
	end,
	info = function(self, t)
		local damage = damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t))
		return ([[Your eye swims through the world and takes a bite out of an enemy on the way, dealing %0.1f physical damage and bleeding them for %0.1f over %d turns.  The meal strengthens you, granting %d flat damage reduction for %d turns.
Spellpower: increases damage and damage reduction.
This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(damage, damage/2, 5, t:_getReduction(self), t:_getDuration(self))
	end,
}

newTalent{
	name = "Karkinos Grasp", short_name = "REK_HEKA_INTRUSION_CLAW",
	type = {"spell/intrusion", 2},	require = mag_req2, points = 5,
	cooldown = 7,
	hands = 25,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = 1 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		if target:canBe("pin") then
			target:setEffect(target.EFF_REK_HEKA_CRAB_GRAB, t.getDuration(self, t), {src=self, power=t.getDamage(self, t)})
		end

		return true
	end,
	info = function(self, t)
		return ([[Your pincers reach up from beneath an enemy and begin crushing it (#SLATE#checks pin resistance#LAST#), pinning it for %d turns and dealing %0.1f physical damage per turn.
Spellpower: increases damage.]]):tformat(t:_getDuration(self), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Arachnofusillade", short_name = "REK_HEKA_INTRUSION_SPIDER",
	type = {"spell/intrusion", 3}, require = mag_req3, points = 5,
	cooldown = 5,
	hands = 20,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	range = 7,
	radius = 2,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5))end,
	getNb = function(self, t) return t.getDuration(self, t)*2+1 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		local list = {}
		self:project(tg, x, y, function(px, py) list[#list+1] = {x=px, y=py} end)

		self:setEffect(self.EFF_REK_HEKA_FUSILLADE, t.getDuration(self, t), {src=self, x=x, y=y, radius=tg.radius, list=list, level=game.zone.short_name.."-"..game.level.level, dam=t.getDamage(self, t)})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Your chelicerae stab down onto the battlefield, affecting %d radius 1 areas within the targeted region over the next %d turns.  The first one is centered exactly where the ability is targeted, the others are random.  Each stab deals %0.1f physical damage, stuns (#SLATE#Spellpower vs Physical#LAST#) for %d turns, and can critically strike independently.
]]):tformat(t.getDuration(self, t)*2+1, t.getDuration(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), 2)
	end,
}

newTalent{
	name = "Cyclopean Spear", short_name = "REK_HEKA_INTRUSION_JELLYFISH",
	type = {"spell/intrusion", 4}, require = mag_req4, points = 5,
	cooldown = 9,
	hands = 30,
	requires_target = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	getDuration = function(self, t) return 4 end,
	getNumb = function(self, t) return self:combatTalentLimit(t, 0.5, 0.1, 0.25) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.REK_HEKA_PHYSICAL_NUMB, {dur=t.getDuration(self, t), numb=t.getNumb(self, t), dam=self:spellCrit(t.getDamage(self, t))})

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Your nematocysts launch outward in a cone of radius %d, dealing %0.1f physical damage and numbing those hit (#SLATE#Spell save#LAST#) by %d%% for %d turns.
Spellpower: increases damage.
]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t.getNumb(self, t)*100, t.getDuration(self, t))
	end,
}
