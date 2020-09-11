local Dialog = require "engine.ui.Dialog"
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

You can no longer use infusions, you shrink by one size category, and your maximum life will be greatly reduced.  You lose access to Force of Will and Punishments, and all points you spent there will be refunded.

In exchange, you can use shadow magic for elemental attacks, healing, and teleportation. You can be anywhere your shadows are, and will only die if all your shadows are killed. You cannot trigger pressure traps, and are immune to petrification, fear, hostile teleports, blindness, and suffocation.
]]):format()
	end,
}

newTalent{
	name = "Purge Talent", short_name = "REK_EVOLUTION_WRITHING_HUNGRY_PURGE",
	type = {"demented/other", 1},
	cant_steal = true,
	cooldown = 12,
	no_npc_use = true,
	is_spell = true,
	action = function(self, t)
		self.gourmand_talents = self.gourmand_talents or {}
		local count = 0
		for _ in pairs(self.gourmand_talents) do count = count + 1 end
		if count < 1 then return end

		-- Pick talent
		local possibles = {}
		for tid, has in pairs(self.gourmand_talents) do
			local t = self:getTalentFromId(tid)
			possibles[#possibles+1] = {tid=tid, name=t.name}
		end
		local talent = self:talentDialog(Dialog:listPopup("Purge Talent", "Choose a talent to forget:", possibles, 400, 400, function(item) self:talentDialogReturn(item) end))
		-- Remove talent
		if talent and talent.tid then
			self:unlearnTalentFull(talent.tid)
			self.talent_no_resources[talent.tid] = nil
			self.gourmand_talents[talent.tid] = nil
		else
			return nil
		end
		
		-- Reset Gourmand
		self:alterTalentCoolingdown(self.T_REK_EVOLUTION_WRITHING_HUNGRY, -1000)
		return true
	end,
	info = function(self, t)
		return ([[Reorganize your interior and forget a talent you've learned using Gourmand.
Activating this will reset the cooldown of your Gourmand talent.]]):format()
	end,
}

newTalent{
	name = "Gourmand", short_name = "REK_EVOLUTION_WRITHING_HUNGRY",
	type = {"uber/magic", 1},
	uber = true,
	require = {
		stat = {mag = 50},
		level = 25,
		birth_descriptors={{"subclass", "Writhing One"}},
		special={
			desc="3 points in the Painful Agony talent",
			fct=function(self)
				return self:getTalentLevelRaw(self.T_PAINFUL_AGONY) >= 3
			end
		}
	},
	is_class_evolution = "Writhing One",
	cant_steal = true,
	cooldown = 12,
	no_npc_use = true,
	is_spell = true,
	action = function(self, t)
		local digest = self:hasEffect(self.EFF_DIGEST)
		if not digest then return end
		if not digest.tid then return end
		self.gourmand_talents = self.gourmand_talents or {}
		local count = 0
		for _ in pairs(self.gourmand_talents) do count = count + 1 end
		if count >= 3 then return end
		local tid = digest.tid
		local level = digest.lev

		-- special checks
		local t = self:getTalentFromId(tid)
		if t.uber then 
			game.logPlayer(self, "This creature's talent is too powerful to preserve.")
			return nil
		end

		-- clear digestion
		self:removeEffect(self.EFF_DIGEST, true, true)
		self:alterTalentCoolingdown(self.T_DIGEST, -1000)
		game:playSoundNear(self, "talents/heal")

		-- relearn talent
		if tid then
			self:learnTalent(tid, true, level, {no_unlearn=true})
			self.talent_no_resources = self.talent_no_resources or {}
			self.talent_no_resources[tid] = 1
			self.gourmand_talents[tid] = true
		end
		return true
	end,
	on_learn = function(self, t)
		self:learnTalent(self.T_REK_EVOLUTION_WRITHING_HUNGRY_PURGE, true, 1, {no_unlearn=true})
	end,
	info = function(self, t)
		return ([[Preserve a currently digesting victim within you, granting you their stolen talent indefinitely. This will not work on Prodigies.
You can have 3 talents preserved this way at a time.  
Activating this will reset the cooldown of your Digest talent.

#{italic}#As the saying goes, "You are what you eat".#{normal}#]]):format()
	end,
}
