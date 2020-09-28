local ActorTalents = require "engine.interface.ActorTalents"

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
