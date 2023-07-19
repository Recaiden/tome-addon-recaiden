local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_ONYX_IMPULSE", image = "talents/rek_onyx_impulse.png",
	desc = "Impulse",
	long_desc = function(self, eff) return ("The target is moving instantly for %d steps."):format(eff.steps) end,
	type = "physical",
	charges = function(self, eff) return eff.steps end,
	subtype = { haste=true },
	status = "beneficial",
	parameters = { steps=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "free_movement", 1)
		eff.ox = self.x
		eff.oy = self.y
	end,
	deactivate = function(self, eff)
	end,
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		
		if self.reload then
			local reloaded = self:reload()
			if not reloaded and self.reloadQS then
				self:reloadQS()
			end
		end
		
		eff.steps = eff.steps - 1
		if eff.steps <= 0 then
			self:removeEffect(self.EFF_REK_ONYX_IMPULSE)
		end
	end,
}

newEffect{
	name = "REK_ONYX_UNBREAKABLE", image = "talents/rek_onyx_unbreakable.png",
	desc = "Unbreakable",
	long_desc = function(self, eff) return ("The target is covered with hardened spines, gaining %d%% absolute resistance and triggering bursts of physical damage every round."):format(eff.power) end,
	type = "physical",
	subtype = { armor=true },
	status = "beneficial",
	parameters = { power=5, damage=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {absolute = eff.power})
		self.rek_onyx_spines_autoproc = eff.damage
	end,
	deactivate = function(self, eff)
		self.rek_onyx_spines_autoproc = nil
	end,
}


-------------------------------------------------------------------------------
--                             Blackhoof racials                             --
-------------------------------------------------------------------------------

newEffect{
	name = "REK_BLACKHOOF_MOVEMENT", image = "talents/rek_blackhoof_movement.png",
	desc = "Blackhooves",
	long_desc = function(self, eff) return ("The target is moving at +900%% speed for %d steps."):format(eff.steps) end,
	type = "physical",
	charges = function(self, eff) return eff.steps end,
	subtype = { haste=true },
	status = "beneficial",
	parameters = { steps=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", 9)
	end,
	deactivate = function(self, eff) end,
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		
		eff.steps = eff.steps - 1
		if eff.steps <= 0 then
			self:removeEffect(self.EFF_REK_BLACKHOOF_MOVEMENT)
		end
	end,
}

newEffect{
	name = "REK_BLACKHOOF_WRECK", image = "talents/rek_blackhoof_wreck.png",
	desc = "Wreck",
	long_desc = function(self, eff) return ("The target's armour and saves are broken, reducing them by %d."):tformat(eff.power*eff.stacks) end,
	type = "other",
	charges = function(self, eff) return eff.stacks end,
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { power=5, stacks=1, max_stacks=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.stacks = math.min(old_eff.stacks + new_eff.stacks, new_eff.max_stacks)
		self:removeTemporaryValue("combat_armor", old_eff.arm)
		self:removeTemporaryValue("combat_physresist", old_eff.physical)
		self:removeTemporaryValue("combat_spellresist", old_eff.spell)
		self:removeTemporaryValue("combat_mentalresist", old_eff.mental)	
		old_eff.acc = self:addTemporaryValue("combat_armor", -old_eff.power*old_eff.stacks)
		old_eff.mental = self:addTemporaryValue("combat_physresist", -old_eff.power*old_eff.stacks)
		old_eff.spell = self:addTemporaryValue("combat_spellresist", -old_eff.power*old_eff.stacks)
		old_eff.physical = self:addTemporaryValue("combat_mentalresist", -old_eff.power*old_eff.stacks)	
		return old_eff	
	end,
	activate = function(self, eff)		
		eff.arm = self:addTemporaryValue("combat_armor", -eff.power*eff.stacks )
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power*eff.stacks)
		eff.spell = self:addTemporaryValue("combat_spellpower", -eff.power*eff.stacks)
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power*eff.stacks)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.arm)
		self:removeTemporaryValue("combat_physresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_mentalresist", eff.physical)
	end,
}

newEffect{
	name = "REK_BLACKHOOF_MOVEMENT", image = "talents/rek_blackhoof_powerup.png",
	desc = "Blackhooves",
	long_desc = function(self, eff) return ("The target has +%d%% damage."):format(eff.power) end,
	type = "magical",
	charges = function(self, eff) return eff.steps end,
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff) end,
}
