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
	callbackOnTakeDamage = function (self, eff, src, x, y, type, dam, tmp, no_martyr)
		self:removeEffect(self.EFF_REK_GLR_DAZE)
	end,
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
	subtype = { psionic=true, stun=true },
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

