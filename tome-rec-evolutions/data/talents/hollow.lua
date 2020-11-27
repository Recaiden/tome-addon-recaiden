knowRessource = Talents.main_env.knowRessource

newTalent{
	name = "Hollow", short_name = "REK_EVOLUTION_DOOMED_HOLLOW",
	type = {"uber/cunning", 1},
	uber = true,
	require = {
		stat = {cun = 50},
		level = 25,
		birth_descriptors={{"subclass", "Doomed"}},
		special={
			desc="10 points in Cursed/Shadows talents",
			fct=function(self)
				return self:getTalentLevelRaw(self.T_CALL_SHADOWS) + self:getTalentLevelRaw(self.T_SHADOW_WARRIORS) + self:getTalentLevelRaw(self.T_SHADOW_MAGES) + self:getTalentLevelRaw(self.T_FOCUS_SHADOWS) >= 10
			end
		}
	},
	is_class_evolution = "Doomed",
	cant_steal = true,
	mode = "passive",
	is_spell = true,
	no_npc_use = true,
	unlearnTalents = function(self, t, cats)
		local tids = {}
		local types = {}
		for id, lvl in pairs(self.talents) do
			local t = self.talents_def[id]
			if t.type[1] and cats[t.type[1]] ~= nil then
				types[t.type[1]] = true
				tids[id] = lvl
			end
		end
		local unlearnt = 0
		for id, lvl in pairs(tids) do self:unlearnTalent(id, lvl, nil, {no_unlearn=true}) unlearnt = unlearnt + lvl end
		self.unused_talents = self.unused_talents + unlearnt
		
		for cat, v in pairs(cats) do
			if self.__increased_talent_types[cat] then
				self.unused_talents_types = self.unused_talents_types + 1
			end
			self.talents_types[cat] = nil
		end
	end,
	learnAndMaster = function(self, cat, unlocked, mastery)
		self:learnTalentType(cat, unlocked)
		self:setTalentTypeMastery(cat, mastery)
	end,
	
	becomeHollow = function(self, t)
		self.descriptor.race = "Undead"
		self.descriptor.subrace = "Shadow"
		self.blood_color = colors.GREY
		
		--hate_regen = 1,
		avoid_traps = 1,
		self:attr("size_category", -1)
		self:attr("undead", 1)
		self:attr("true_undead", 1)
		
		self:attr("stone_immune", 1)
		self:attr("fear_immune", 1)
		self:attr("teleport_immune", 1)    
		self:attr("blind_immune", 1)
		
		--      self:attr("confusion_immune", 1)
		--      self:attr("disease_immune", 1)
		--      self:attr("poison_immune", 1)
		--      self:attr("stun_immune", 1)
		
		self:attr("no_breath", 1)
		
		self.inscription_forbids = self.inscription_forbids or {}
		self.inscription_forbids["inscriptions/infusions"] = true
		if self:attr("blood_life") then
			self.blood_life = nil
			game.log("#GREY#As you turn into a powerful shade you feel yourself violently rejecting the Blood of Life.")
		end
		
		--life drop
		local cost = math.min(5, self.life_rating - 1)
		self.life_rating = math.max(1, self.life_rating - cost)
		self.max_life = self.max_life - cost * (1.1 * (self.level-1) + ((self.level-1) * (self.level - 2) / 80))
		if self.life > self.max_life then self.life = self.max_life end

		-- Unlearn old talents, learn new
		local removes = {
			["cursed/punishments"] = true,
			["cursed/force-of-will"] = true,
		}
		t.unlearnTalents(self, t, removes)
		t.learnAndMaster(self, "undead/shadow-destruction", true, 1.3)
		t.learnAndMaster(self, "undead/shadow-magic", true, 1.3)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
		if not self.shader then
			self.shader = "rek_seething_darkness"
			self.shader_args = { a_min = 0, a_max = 0.8, base = 0.1 }
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
	end,
	callbackOnRest = function(self, t, status)
		if not self.shader then
			self.shader = "rek_seething_darkness"
			self.shader_args = { a_min = 0, a_max = 0.8, base = 0.1 }
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
	end,
	on_learn = function(self, t)
		t.becomeHollow(self, t)
	end,
	info = function(self, t)
		return ([[You exist in eternal pursuit of something you can never regain. There's nothing left of you but another shadow, a hateful entity of pure, living darkness.

#CRIMSON#This evolution fundamentally alters your class and character in a huge way. Do not take it lightly.#LAST#
You can no longer use infusions, you shrink by one size category, and your maximum life will be reduced by 5 life rating (this is retroactive).  You lose access to Force of Will and Punishments, and all points you spent there will be refunded.

In exchange, you can use shadow magic for elemental attacks, healing, and teleportation. You can be anywhere your shadows are, and will only die if all your shadows are killed. You cannot trigger pressure traps, and are immune to petrification, fear, hostile teleports, blindness, and suffocation.
]]):format()
	end,
}