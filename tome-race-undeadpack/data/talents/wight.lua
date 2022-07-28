newTalent{
	name = "Alter Fury Element", short_name="REK_WIGHT_CYCLE_ELEMENT",
	type = {"undead/other", 1}, require = undeads_req1, points = 1,
	no_energy = true,
	cooldown = 0,
	action = function(self, t)
		if self.rek_wight_damage == DamageType.FIRE then
			self.rek_wight_damage = DamageType.LIGHTNING
		elseif self.rek_wight_damage == DamageType.LIGHTNING  then
			self.rek_wight_damage = DamageType.COLD
		else
			self.rek_wight_damage = DamageType.FIRE
		end
		return true
	end,
	info = function(self, t)
		local damtype = DamageType.FIRE
		if self.rek_wight_damage then
			damtype = self.rek_wight_damage
      end
		
		local str = DamageType:get(damtype).name
		return ([[Rotate the type of damage you do with Fury of the Wilds between Fire, Lightning, and Cold.  Currently: %s]]):tformat(str)
	end,
}

newTalent{
	name = "Fury of the Wild", short_name="REK_WIGHT_FURY",
	type = {"undead/wight", 1}, require = undeads_req1, points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end,
	tactical = { ATTACK = 2 },
	on_learn = function(self, t)
		self:learnTalent(self.T_REK_WIGHT_CYCLE_ELEMENT, 1)
		if self.rek_wight_damage == nil then
			self.rek_wight_damage = DamageType.FIRE
		end
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_REK_WIGHT_CYCLE_ELEMENT, 1)
	end,
	getDamage = function(self, t)
		return math.min(200, self:combatStatScale(math.max(self:getMag(), self:getWil()), 10, 100, 2.0))
	end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_WIGHT_FURY, 5, {power=t.getDamage(self,  t)})
		return true
	end,
	info = function(self, t)
		return ([[For the next 5 turns, whenever you damage an enemy, you will unleash a radius 1 burst of %d elemental damage (once per enemy per turn).
The damage improves with the stronger of your magic or willpower.

#{italic}#Death and destruction, we must admit, are part of nature...#{normal}#]]):tformat(t.getDamage(self, t))
	end,
}

newTalent{
	name = "Draining Presence", short_name = "REK_WIGHT_DRAIN",
	type = {"undead/wight", 2}, require = undeads_req2, points = 5,
	mode = "passive",
	on_learn = function(self, t)
		if not game:isCampaign("Maj'Eyal") then return end
		local level = self:getTalentLevelRaw(self.T_REK_WIGHT_DRAIN)
		if level == 1 then
			self.old_faction_cloak = self.faction
			self.faction = "allied-kingdoms"
			if self.descriptor and self.descriptor.race and self:attr("undead") then self.descriptor.fake_race = "Human" end
			if self.descriptor and self.descriptor.subrace and self:attr("undead") then self.descriptor.fake_subrace = "Cornac" end
			if self.player then engine.Map:setViewerFaction(self.faction) end
		end
	end,
	on_unlearn = function(self, t)
		if not game:isCampaign("Maj'Eyal") then return end
		local level = self:getTalentLevelRaw(self.T_REK_WIGHT_DRAIN)
		if level == 0 then
			if self.permanent_undead_cloak then return end
			self.faction = self.old_faction_cloak
			if self.descriptor and self.descriptor.race and self:attr("undead") then self.descriptor.fake_race = nil end
			if self.descriptor and self.descriptor.subrace and self:attr("undead") then self.descriptor.fake_subrace = nil end
			if self.player then engine.Map:setViewerFaction(self.faction) end
		end
	end,
	getFearPower = function(self, t)
		return -self:combatStatScale(math.max(self:getMag(), self:getWil()), 15, 40)
	end,
	getSpeed = function(self, t) return  end,
	getFearlessDuration = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 20, 10)) end,
	callbackOnActBase = function (self, t)
		self:project(
			{type="ball", radius=5}, self.x, self.y,
			function(px, py)
				local actor = game.level.map(px, py, Map.ACTOR)
				local apply_power = math.max(self:combatPhysicalpower(), self:combatSpellpower(), self:combatMindpower())
				if actor and self:reactionToward(actor) < 0 then
					if actor:hasEffect(actor.EFF_REK_WIGHT_FEARLESS) then return end
					if self:checkHit(apply_power, actor:combatMentalResist(), 0, 95, 5) then
						actor:setEffect(actor.EFF_REK_WIGHT_DESPAIR, 4, {statChange = t.getFearPower(self, t), apply_power=apply_power, no_ct_effect=true})
					else
						actor:setEffect(actor.EFF_REK_WIGHT_FEARLESS, t.getFearlessDuration(self, t), {})
					end
				end
			end)
	end,
	info = function(self, t)
		local disguise_str = game:isCampaign("Maj'Eyal") and ([[
																																				 
Learning this talent gives you enough control over your ghostly form to pass as a human.
]]):tformat() or ""
		return ([[Each round, enemies within range 5 may (#SLATE#Highest power vs. Mental#LAST#) despair of surviving, reducing their saves, defense, and armor by %d.  If they successfully resist, they are immune to your draining presence for %d turns.

The depth of their despair improves with the stronger of your magic or willpower.
%s
#{italic}#Merely being close to these figments of death causes one's life force to sputter and fade...#{normal}# 
]]):tformat(t.getFearPower(self, t), t.getFearlessDuration(self, t), disguise_str)
   end,
}

newTalent{
	name = "Ephemeral", short_name = "REK_WIGHT_DODGE",
	type = {"undead/wight", 3}, require = undeads_req3, points = 5,
	mode = "passive",
	no_unlearn_last = true,
	getEvasion = function(self, t)
		return math.min(self:combatTalentScale(t, 4, 18, 0.75), 30)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "cancel_damage_chance", t.getEvasion(self, t))
	end,
	info = function(self, t)
		return ([[You have a %d%% chance to reduce any incoming damage to 0.

Learning this talent regrows a fragment of your connection to nature, allowing you to use a single Infusion.

#{italic}#Blows that should have been telling seem to slip right through them...#{normal}#]]):tformat(t.getEvasion(self, t))
   end,
}

newTalent{
   short_name = "REK_WIGHT_GHOST_VISION",
   name = "Haunting",
   type = {"undead/wight", 4},
   require = undeads_req4,
   points = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 30, 17)) end,
   no_energy = true,
   tactical = { ESCAPE = 1 },
   getRange = function(self, t) return self:combatTalentScale(t, 11, 20) end,
   getDuration = function(self, t) return 3 end,
   action = function(self, t)
      local rad = self:getTalentRadius(t)
      self:setEffect(self.EFF_REK_WIGHT_GHOSTLY, t.getDuration(self, t), {power=t.getRange(self, t)})
      return true
   end,
   info = function(self, t)
      return ([[Shift fully into the spirit world for 3 turns, allowing you to walk through walls and to sense all enemies within range %d. 

If you are inside a wall when the effect ends, you will move to the nearest open space.

#{italic}#...faded and incorporeal at their edges, while strange lights dance where their eyes should remain....#{normal}#]]):tformat(t.getRange(self, t))
   end,
}
