newTalent{
	name = "Forfend", short_name = "REK_HEKA_HELPING_FORFEND",
	type = {"technique/helping-hands", 1}, require = str_req_slow, points = 5,
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
	name = "Demon's Playground", short_name = "REK_HEKA_HELPING_IDLE",
	type = {"technique/helping-hands", 2},	require = str_req2, points = 5,
	mode = "passive",
	range = 3,
	getChance = function(self, t) return self:combatTalentLimit(t, 66, 20, 40) end,
	callbackOnTalentPost = function(self, t, ab)
		local chance = t.getChance(self, t)
		if ab.hands and not ab.invest_hands then
			self:project(
				{type="ball", range=0, radius=3, no_restrict=true},
				self.x, self.y,
				function(px, py)
					local a = game.level.map(px, py, engine.Map.ACTOR)
					if a and a:reactionToward(self) < 0 then
						local alt = {}
						local found  = false
						for tid, cd in pairs(a.talents_cd) do
							if rng.percent(chance) then alt[tid] = true found = true end
						end
						for tid, cd in pairs(alt) do
							a:alterTalentCoolingdown(tid, 1)
						end
						if found then
							game.level.map:particleEmitter(a.x, a.y, 1, "image_rise", {img="heka_devil_claws"})
						end
					end
				end)
		end
	end,
	info = function(self, t)
		return ([[Your idle hands flock around you, poking and grasping.  Whenever you spend hands (not sustain or invest them), enemies within range %d are distracted, giving a %d%% chance to increase the remaining cooldowns of each of their talents by 1.]]):tformat(self:getTalentRange(t), t.getChance(self, t))
	end,
}

newTalent{
	name = "Magpie Hook", short_name = "REK_HEKA_HELPING_MAGPIE",
	type = {"technique/helping-hands", 3}, require = str_req3, points = 5,
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
		if target:canBe("disarm") and self:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5) then
			-- get weapon's combat table
			if target:getInven(self.INVEN_MAINHAND) then
				for i, o in ipairs(target:getInven(self.INVEN_MAINHAND)) do
					local combat = target:getObjectCombat(o, "mainhand")
					self:setEffect(self.EFF_REK_HEKA_MAGPIE_WEAPONS, t.getDuration(self, t), {weapon=combat, mult=t.getDamage(self, t), src=self})
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
		if self:hasEffect(self.EFF_REK_HEKA_MAGPIE_WEAPONS) then
			self:removeEffect(self.EFF_REK_HEKA_MAGPIE_WEAPONS)
		end
		return true
	end,
	info = function(self, t)
		return ([[When an enemy hits you in melee, your hands swoop in to steal their weapon, disarming (#SLATE#Physical vs Physical#LAST#) them for %d turns.  Your next armed attack in that time will also attack using the stolen weapon for %d%% damage.  A given enemy can only have their weapon stolen every %d turns, and you can only hold one stolen weapon at a time.]]):tformat(t.getDuration(self, t), t.getDamage(self, t)*100, t.getCD(self, t))
	end,
}

newTalent{
	name = "Lay on Hands", short_name = "REK_HEKA_HELPING_HEALING",
	type = {"technique/helping-hands", 4}, require = str_req4, points = 5,
	mode = "passive",
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 10, 14) end,
	doHeal = function(self, t, hands)
		-- called by individual effects and talents
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)*hands), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.0, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.0, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
	end,
	info = function(self, t)
		return ([[When your hands reunite with you after ending a talent that drains hands, invests hands, or has a sustained hand cost, you are healed by %0.1f per hand.
Spellpower: increases healing]]):tformat(t.getHeal(self, t))
	end,
}

