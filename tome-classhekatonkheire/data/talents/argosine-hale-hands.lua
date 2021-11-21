newTalent{
	name = "Forestall", short_name = "REK_HEKA_HALE_FORFEND",
	type = {"spell/hale-hands", 1}, require = mag_req_slow, points = 5,
	tactical = { DEFEND = 2 },
	speed= "weapon",
	cooldown = 8,
	hands = 20,
	getDuration = function (self, t) return 1 end,
	getBlock = function(self, t) return self:combatTalentScale(t, 30, 200) * (1 + self.level/50) end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_HEKA_FORFEND, t.getDuration(self, t), {block=t.getBlock(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Throw out handfuls of hands, palms open, to block incoming threats, reducing all non-Mind damage by %d for 1 turn. If you block all of an attack's damage, the attacker will be vulnerable to a deadly counterstrike (the next attack will deal double damage) for one turn.
The blocking value will increase with your level.]]):tformat(t.getBlock(self, t))
	end,
}

newTalent{
	name = "Demon's Mire", short_name = "REK_HEKA_HALE_IDLE",
	type = {"spell/hale-hands", 2},	require = mag_req2, points = 5,
	mode = "passive",
	range = 3,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 60) end,
	callbackOnTalentPost = function(self, t, ab)
		local chance = t.getChance(self, t)
		if ab.hands and not ab.invest_hands then
			self:project(
				{type="ball", range=0, radius=3, no_restrict=true},
				self.x, self.y,
				function(px, py)
					local a = game.level.map(px, py, engine.Map.ACTOR)
					if a and a:reactionToward(self) < 0 and rng.percent(t.getChance(self, t)) and a:checkHit(self:combatSpellpower(), a:combatPhysicalResist(), 0, 95, 15) then
						a:crossTierEffect(
							a.EFF_OFFBALANCE,
							self:combatSpellpower())
						game.level.map:particleEmitter(a.x, a.y, 1, "image_rise", {img="heka_devil_claws"})
					end
			end)
		end
	end,
	info = function(self, t)
		return ([[Your idle hands flock around you, poking and grasping.  Whenever you spend hands (not sustain or invest them), enemies within range %d are distracted, giving a %d%% chance to knock them off-balance (#SLATE#using your spellpower#LAST#).]]):tformat(self:getTalentRange(t), t.getChance(self, t))
	end,
}

newTalent{
	name = "Magpie Mirror", short_name = "REK_HEKA_HALE_MAGPIE",
	type = {"spell/hale-hands", 3}, require = mag_req3, points = 5,
	speed = "weapon",
	mode = "sustained",
	sustain_hands = 10,
	tactical = { ATTACK = { weapon = 2}, DISABLE = 1 },
	cooldown = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentScale(t, 0.80, 1.5) end,
	getDuration = function(self, t) return 2 end,
	getCD = function(self, t) return 10 end,
	callbackOnMeleeHit = function(self, t, target, dam)
		if target:hasProc("heka_magpie") then return end
		if target:isUnarmed() then return end
		if target:canBe("disarm") and self:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 5) then
			-- get weapon's combat table
			if target:getInven(self.INVEN_MAINHAND) then
				for i, o in ipairs(target:getInven(self.INVEN_MAINHAND)) do
					local combat = target:getObjectCombat(o, "mainhand")
					target:attackTargetWith(target, combat, nil, t.getDamage(self, t))
					break
				end
			end
			target:setEffect(self.EFF_DISARMED, 3, {src=self})
			target:setProc("heka_magpie", true, t.getCD(self, t))
		end
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[When an enemy hits you in melee, your hands swoop in to strike back, disarming (#SLATE#Spellpower vs Physical#LAST#) them for %d turns and having them attack themselves for %d%% damage.  A given enemy can only have their weapon turned against them every %d turns.]]):tformat(t.getDuration(self, t), t.getDamage(self, t)*100, t.getCD(self, t))
	end,
}

newTalent{
	name = "Show of Hands", short_name = "REK_HEKA_HALE_HEALING",
	type = {"spell/hale-hands", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getSaves = function(self, t) return self:getTalentLevel(t) * 2.0 end,
	callbackOnAct = function(self, t) self:updateTalentPassives(t) end,
	callbackOnPartyAdd = function(self, t, actor) self:updateTalentPassives(t) end,
	callbackOnSummonDeath = function(self, t, summon) self:updateTalentPassives(t) end,
	passives = function(self, t, p)
		local nb_friends = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) > 0 and self:canSee(act) then nb_friends = nb_friends + 1 end
		end
		if nb_friends > 1 then
			nb_friends = math.min(nb_friends, 7)
		end
		local power = t.getSaves(self, t)

		self:talentTemporaryValue(p, "combat_physresist", power * nb_friends)
		self:talentTemporaryValue(p, "combat_spellresist", power * nb_friends)
		self:talentTemporaryValue(p, "combat_mentalresist", power * nb_friends)
		return p
	end,
	info = function(self, t)
		return ([[All your saves are increased by %0.1f per ally in sight (up to 7 allies).

#{italic}#Remember, this is only an anchor, and your real self is beyond concern.#{normal}#]]):tformat(t.getSaves(self, t))
	end,
}
