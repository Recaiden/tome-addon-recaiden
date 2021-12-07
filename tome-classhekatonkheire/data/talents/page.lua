newTalent{
	name = "Carnigenesis", short_name = "REK_HEKA_PAGE_REGEN",
	type = {"spell/other-page", 1}, require = mag_req1, points = 5,
	points = 5,
	cooldown = 6,
	tactical = { RESOURCE = 1 },
	getSpellpower = function(self, t) return self:combatTalentScale(t, 10, 50, 1.0) end,
	getHands = function(self, t) return 5 end,
	getDuration = function(self, t) return 3 end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_HEKA_HAND_REGEN, t:_getDuration(self), {regen=5, power=t:_getSpellpower(self)})
		return true
	end,
	info = function(self, t)
		local h = t:_getHands(self)
		return ([[Rapidly grow new forms in the other place, restoring %d/%d/%d hands each turn for the next %d turns.  During that time, your spellpower will be increased by %d.]]):tformat(h, h*2, h*3, t:_getDuration(self), t:_getSpellpower(self))
	end,
}

newTalent{
	name = "Close at Hand", short_name = "REK_HEKA_PAGE_ITEM",
	type = {"spell/other-page", 2},	require = mag_req2, points = 5,
	mode = "passive",
	getCharmCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	getCharmPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	doCharm = function(self, t)
		local charms = {"cd", "buff", "heal", "evade", "pen", "dam"}
		local charm = rng.table(charms)
		if charm == "cd" then
			game.logPlayer(self, "%s is refreshed!", self:getName():capitalize())
			self:talentCooldownFilter(nil, t:_getCharmCount(self), 2, true)
		elseif charm == "buff" then
			game.logPlayer(self, "%s's powers are extended!", self:getName():capitalize())
			local eff_ids = self:effectsFilter(function(eff)
				if eff.status == "beneficial" and eff.type ~= "other" then return true end
			end, t:_getCharmCount(self))
			for _, eff_id in pairs(eff_ids) do 
				local eff = self:hasEffect(eff_id)
				if eff and eff.dur then
					eff.dur = eff.dur + math.ceil(t:_getCharmPower(self)*0.02)
				end
			end
		elseif charm == "heal" then
			game.logPlayer(self, "%s is healed!", self:getName():capitalize())
			self:attr("allow_on_heal", 1)
			self:heal(self:spellCrit(20+t:_getCharmPower(self)*2.6), self)
			self:attr("allow_on_heal", -1)		
		elseif charm == "evade" then
			game.logPlayer(self, "%s begins evading!", self:getName():capitalize())
			self:setEffect(self.EFF_ITEM_CHARM_EVASIVE, 2, {chance = t:_getCharmPower(self)*0.3})
		elseif charm == "pen" then
			game.logPlayer(self, "%s becomes more piercing!", self:getName():capitalize())
			self:setEffect(self.EFF_ITEM_CHARM_PIERCING, 2, {penetration = t:_getCharmPower(self)*0.2})
		elseif charm == "dam" then
			game.logPlayer(self, "%s becomes more powerful!", self:getName():capitalize())
			self:setEffect(self.EFF_ITEM_CHARM_POWERFUL, 2, {damage = t:_getCharmPower(self)*0.2})
		end
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "quick_weapon_swap", 1)
	end,
	info = function(self, t)
		return ([[You dedicate spare tentacles and pincers to holding each and every item, allowing you to swap equipment sets instantly.
What's more, whenever you use an item, you activate a random charm effect (scales with Spellpower):
 * reduce %d talent cooldowns by %d turns
 * extend %d beneficial effects by %d turns
 * heal %d life
 * gain %d%% evasion for 2 turns
 * increase resistance penetration by %d%% for 2 turns
 * increase all damage by %d%% for 2 turns.

#{italic}#You can't lose it if you never put it down.#{normal}#]]):tformat(t:_getCharmCount(self), 2, t:_getCharmCount(self), math.ceil(t:_getCharmPower(self)*0.02), 20+t:_getCharmPower(self)*2.6, t:_getCharmPower(self)*0.3, t:_getCharmPower(self)*0.2, t:_getCharmPower(self)*0.2)
	end,
}

newTalent{
	name = "Total Phase Shift", short_name = "REK_HEKA_PAGE_FLIP",
	type = {"spell/other-page", 3}, require = mag_req3, points = 5,
	cooldown = 5,
	hands = 30,
	tactical = { DISABLE = 1 },
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6))end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		target:setEffect(target.EFF_REK_HEKA_PHASE_OUT, t.getDuration(self, t), {src=self, apply_power=self:combatSpellpower()})

		game:playSoundNear(self, "talents/arcane")
		investHands(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Seal a creture entirely into the Other Place (#SLATE#Spell save#LAST#) for %d turns. While there time does not pass for them - they are unable to act and immune to harm - except that their talents cool down, and at double speed.

This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Sea of Flesh", short_name = "REK_HEKA_PAGE_SEA",
	type = {"spell/other-page", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getHands = function(self, t) return 5 * math.floor(self:combatTalentScale(t, 2, 10)) end,
	getHandRegen = function(self, t) return 5 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "max_hands", t:_getHands(self))
		if self:getHands() >= 100 then
			self:talentTemporaryValue(p, "hands_regen", t:_getHandRegen(self))
		end
	end,
	callbackOnActBase = function(self, t) self:updateTalentPassives(t) end,
	callbackOnTalentPost = function(self, t, ab) self:updateTalentPassives(t) end,
	-- bonus regen in mod/class/interface/ActorResource/lua
	info = function(self, t)
		return ([[Your form stretches endlessly through the other place, increasing your maximum Hands by %d. While you have more than 100 hands, you regenerate an extra %d hands per round.]]):tformat(t:_getHands(self), t:_getHandRegen(self))
	end,
}
