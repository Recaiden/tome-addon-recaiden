local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_GLR_DAZE", image = "talents/rek_glr_idol_fascinating.png",
	desc = "Fascinated",
	long_desc = function(self, eff) return ("The target is dazed with fascination."):format() end,
	type = "mental",
	subtype = { psionic=true, stun=true },
	status = "detrimental",
	parameters = { power=1, immunity=15 },
	-- break on damage is in Actor.lua
	-- callbackOnTakeDamage = function (self, eff, src, x, y, type, dam, tmp, no_martyr)
	-- 	self:removeEffect(self.EFF_REK_GLR_DAZE)
	-- end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "dazed", 1)
		self:effectTemporaryValue(eff, "never_move", 1)
	end,
	deactivate = function(self, eff)
		self:setEffect(self.EFF_REK_GLR_NO_FASCINATE, eff.immunity, {src = eff.src})
	end,
}

newEffect{
	name = "REK_GLR_NO_FASCINATE", image = "talents/rek_glr_idol_fascinating.png",
	desc = "Bored",
	long_desc = function(self, eff) return ("The target is immune to further fascination."):format() end,
	type = "mental",
	subtype = { psionic=true, emotion=true },
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_QUENCHED_SPEED", image = "talents/rek_glr_idol_thought_drinker.png",
	desc = "Mind-Quenched",
	long_desc = function(self, eff) return ("Movement speed increased by %d%%."):format(eff.speed) end,
	type = "mental",
	subtype = { haste = true },
	status = "beneficial",
	parameters = { speed = 1, steps = 1 },
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		eff.steps = eff.steps - 1
		if eff.steps <= 0 then
			self:removeEffect(self.EFF_REK_GLR_QUENCHED_SPEED)	
		end
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", eff.speed)
	end,
}


newEffect{
	name = "REK_GLR_INTIMIDATED", image = "talents/rek_glr_idol_terrific.png",
	desc = "Awed",
	long_desc = function(self, eff) return ("The target is in awe, losing %d mental save."):format(eff.power) end,
	type = "mental",
	subtype = { psionic=true, emotion=true },
	status = "detrimental",
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_BRAINSEALED", image = "talents/rek_glr_noumena_lockdown.png",
	desc = "Thoughtsealed",
	long_desc = function(self, eff) return ("The target is unable to think, preventing weapon attacks and spells, and slowing talent cooldown."):format() end,
	type = "mental",
	subtype = { psionic=true, },
	status = "detrimental",
	parameters = { count=1 },
	activate = function(self, eff)
		if self:canBe("silence") then self:effectTemporaryValue(eff, "silence", 1) end
		if self:canBe("disarm") then self:effectTemporaryValue(eff, "disarmed", 1) end
		self:effectTemporaryValue(eff,"half_talents_cooldown", 1)
		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and not t.no_energy then tids[#tids+1] = t end
		end
		for i = 1, eff.count do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1
		end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_TRACED",
	desc = "Illuminating Trace", image = "talents/illumination.png",
	long_desc = function(self, eff) return ("The target is psychically mapped, reducing its stealth and invisibility power by %d and removing all evasion bonus from being unseen."):format(eff.power, eff.def) end,
	type = "physical",
	subtype = { vision=true },
	status = "detrimental",
	parameters = { power=20 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_stealth", -eff.power)
		if self:attr("invisible") then self:effectTemporaryValue(eff, "invisible", -eff.power) end
		self:effectTemporaryValue(eff, "blind_fighted", 1)
	end,
}

newEffect{
	name = "REK_GLR_TRACE", image = "talents/perfect_strike.png",
	desc = "Trace Accuracy",
	long_desc = function(self, eff) return ("The target's accuracy is improved by %d."):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# aims carefully." end,
	on_lose = function(self, err) return "#Target# aims less carefully." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", eff.power)
		self:effectParticles(eff, {type="perfect_strike", args={radius=1}})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
	end,
}


newEffect{
	name = "REK_GLR_SUNDER_ARMOUR", image = "talents/sunder_armour.png",
	desc = "Sunder Armour",
	long_desc = function(self, eff) return ("The target's armour is broken, reducing it by %d."):format(eff.power) end,
	type = "physical",
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s armour is damaged!", "+Sunder Armor" end,
	on_lose = function(self, err) return "#Target#'s armour is more intact.", "-Sunder Armor" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_armor", -eff.power)
	end,
}

newEffect{
	name = "REK_GLR_COCOONED", image = "talents/rek_glr_material_cocoon.png",
	desc = "Cocoon Snare",
	long_desc = function(self, eff) return ("The target is pinned in place and loses %d resistances."):format(eff.power) end,
	type = "mental",
	subtype = { psionic=true, pin=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is snared.", "+Cocoon" end,
	on_lose = function(self, err) return "#Target# is free of the snare.", "-Cocoon" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_SHARDS_READY", image = "talents/rek_glr_abomination_shard_shot.png",
	desc = "Swift Shooting",
	long_desc = function(self, eff) return ("The target has transmuted arrows ready to fire and can attack %d%% faster."):format(eff.power) end,
	type = "physical",
	subtype = { psionic=true, haste=true },
	status = "beneficial",
	parameters = { power=0.1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_MIND_NET", image = "talents/rek_glr_mindprison_chorus.png",
	desc = "Dream Chorus Net",
	long_desc = function(self, eff) return ("The target's psyche is caught in a mental net, dealing %0.2f mind damage per turn."):format(eff.power) end,
	type = "mental",
	subtype = { psionic=true, possess=true, mind=true },
	status = "detrimental",
	parameters = { power=1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, eff.power)
	end,
	callbackOnDeath = function(self, eff, value, src, death_note)
		if eff.death_triggered then return end
		eff.death_triggered = true
		if eff.src and eff.src ~= self then
			if eff.src:callTalent(eff.src.T_REK_GLR_MINDPRISON_CHORUS, "captureMind", self, true) then
				eff.src:logCombat(self, "#PURPLE##Source# draws out #Target#'s mind and absorbs it.")
			else
				eff.src:logCombat(self, "#PURPLE##Source# rips out #Target#'s mind, utterly destroying it.")
			end
		end
	end,
}

newEffect{
	name = "REK_GLR_OVERFLOW", image = "talents/rek_glr_mindprison_overflow.png",
	desc = "Overflowed Thoughts",
	long_desc = function(self, eff) return ("The target is conflicated and about to lose energy."):format() end,
	type = "other",
	subtype = { psionic=true, emotion=true },
	status = "detrimental",
	parameters = { power=1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		self.energy.value = self.energy.value - game.energy_to_act
	end,
}

newEffect{
	name = "REK_GLR_GRINDING", image = "talents/rek_glr_abomination_shard_shot.png",
	desc = "Ground Down",
	long_desc = function(self, eff) return ("The target in pinend down by a hail of arrows and debris, losing %d defense, %d accuracy, and %d powers."):format(eff.def, eff.atk, eff.pow) end,
	type = "physical",
	subtype = { psionic=true },
	status = "detrimental",
	parameters = { def=2, atk=1, pow=0, stacks=1, max_stacks=5 },
	charges = function(self, eff) return eff.stacks end,
	updateEffect = function(self, old_eff, new_eff, e)
		old_eff.__tmpvals = old_eff.__tmpvals or {}
		new_eff.__tmpvals = new_eff.__tmpvals or {}
		if old_eff.__tmpvals.id_def then
			self:removeTemporaryValue("defense", old_eff.__tmpvals.id_def)
			self:removeTemporaryValue("combat_atk", old_eff.__tmpvals.id_acc)
			self:removeTemporaryValue("combat_mindpower", old_eff.__tmpvals.id_pm)
			self:removeTemporaryValue("combat_spellpower", old_eff.__tmpvals.id_ps)
			self:removeTemporaryValue("combat_dam", old_eff.__tmpvals.id_pp)
		end
		new_eff.__tmpvals.id_def = self:addTemporaryValue("defense", -new_eff.def*new_eff.stacks)
		new_eff.__tmpvals.id_acc = self:addTemporaryValue("combat_atk", -new_eff.atk*new_eff.stacks)
		new_eff.__tmpvals.id_pm = self:addTemporaryValue("combat_mindpower", -new_eff.pow*new_eff.stacks)
		new_eff.__tmpvals.id_ps = self:addTemporaryValue("combat_spellpower", -new_eff.pow*new_eff.stacks)
		new_eff.__tmpvals.id_pp = self:addTemporaryValue("combat_dam", -new_eff.pow*new_eff.stacks)
	end,
	on_merge = function(self, old_eff, new_eff, e)
		new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		e.updateEffect(self, old_eff, new_eff, e)
		return new_eff
	end,
	activate = function(self, eff, e)
		e.updateEffect(self, eff, eff, e)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("defense", eff.__tmpvals.id_def)
		self:removeTemporaryValue("combat_atk", eff.__tmpvals.id_acc)
		self:removeTemporaryValue("combat_mindpower", eff.__tmpvals.id_pm)
		self:removeTemporaryValue("combat_spellpower", eff.__tmpvals.id_ps)
		self:removeTemporaryValue("combat_dam", eff.__tmpvals.id_pp)
	end,
}

newEffect{
	name = "REK_GLR_COSMIC_AWARENESS", image = "talents/rek_glr_nightmare_awareness.png",
	desc = "Cosmic Awareness",
	long_desc = function(self, eff) return ("The target has awakened to the dream, giving it %d%% incoming mind conversion and %d mind resistance."):format(eff.power*100, eff.resist) end,
	type = "physical",
	subtype = { psionic=true, sleep=true },
	status = "beneficial",
	parameters = { power=0.1, resist=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "lucid_dreamer", 1)
		self:effectTemporaryValue(eff, "resists", {[DamageType.MIND] = eff.resist})
		self:effectTemporaryValue(eff, "resists_cap", {[DamageType.MIND] = eff.resist})
		
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_DREAM_SHIFT", image = "talents/rek_glr_nightmare_shift.png",
	desc = "Dream Shift",
	long_desc = function(self, eff) return ("The target is a harmless animal, with %d less stats."):format(eff.power) end,
	type = "other",
	subtype = { psionic=true, dream=true },
	status = "detrimental",
	decrease = 0,
	parameters = { power=10, lockin=1, save=20 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_stats", {[Stats.STAT_STR] = -eff.power,
																						[Stats.STAT_DEX] = -eff.power,
																						[Stats.STAT_CON] = -eff.power,
																						[Stats.STAT_MAG] = -eff.power,
																						[Stats.STAT_WIL] = -eff.power,
																						[Stats.STAT_CUN] = -eff.power,
																						[Stats.STAT_LCK] = -eff.power})
		self.replace_display = mod.class.Actor.new{image="npc/vermin_rodent_cute_little_bunny.png",}
		self:removeAllMOs()
		self.life = min(self.life, self.max_life)
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	on_timeout = function(self, eff)
		if eff.lockin > 0 then
			eff.lockin = eff.lockin - 1
			return
		end
		if not self:checkHit(eff.save, self:combatMentalResist(), 0, 95, 10) then eff.dur = 0 end
	end,
}

newEffect{
	name = "REK_GLR_HALLUCINATING", image = "talents/rek_glr_nightmare_overlay.png",
	desc = "Hallucination",
	long_desc = function(self, eff) return ("Does %d%% less damage to non-hallucinatory targets."):format(eff.power*100) end,
	type = "other",
	subtype = { psionic=true, nightmare=true, hallucination=true },
	status = "detrimental",
	parameters = { power=0.1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}