local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "HAMMER_DEMONIC_WATERBREATHING", image = "effects/hammer_demonic_waterbreathing.png",
	desc = _t"Shell of Living Air",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return (_t"You have a large but limited supply of air for breathing underwater.  Once it runs out, you will start drowning as normal.") end,
	cancel_on_level_change = false,
	type = "other",
	subtype = { aura=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		eff.dur = 665
		self:effectTemporaryValue(eff, "can_breath", {water = 1})
	end,
	deactivate = function(self, eff) end,
}

newEffect{
	name = "HAMMER_CULTIST_REVIVE", image = "effects/hammer_demonic_revive.png",
	desc = _t"Cult of the Demon Seed",
	long_desc = function(self, eff) return ("If life is brought below 0, cancels the attack and heals you fully."):tformat() end,
	type = "other",
	subtype = { aura=true },
	status = "beneficial",
	parameters = { life=100 },
	decrease = 0, cancel_on_level_change = true,
	activate = function(self, eff)	end,
	deactivate = function(self, eff) end,
	callbackOnHit = function(self, eff, cb, src)
		if cb.value > self.life and not eff.trigger then	
			cb.value = 0
			self:heal(self.max_life, eff)
			game.logSeen(self, "%s's is reborn through Shasshhiy'Kaish's magic!", self:getName():capitalize())
			eff.trigger = true
			if core.shader.active(4) then
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "shader_ring", {radius=eff.rad*2, life=8}, {type="sparks"})
			else
				local x, y = self.x, self.y
				-- Lightning ball gets a special treatment to make it look neat
				local sradius = (eff.rad + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
				local nb_forks = 16
				local angle_diff = 360 / nb_forks
				for i = 0, nb_forks - 1 do
					local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
					local tx = x + math.floor(math.cos(a) * eff.rad)
					local ty = y + math.floor(math.sin(a) * eff.rad)
					game.level.map:particleEmitter(x, y, eff.rad, "lightning", {radius=eff.rad, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
				end
			end
			game:onTickEnd(function() self:removeEffect(self.EFF_HAMMER_CULTIST_REVIVE) end)
			game:playSoundNear(self, "talents/lightning")		
		end
		return cb.value
	end,
}


local activate = TemporaryEffects.tempeffect_def.EFF_RECALL.activate
TemporaryEffects.tempeffect_def.EFF_RECALL.activate = function(self, eff)
	activate(self, eff)

	if not self.hammer_timecrash then return end
	eff.where = "campaign-hammer+edge-of-eternity"
end


newEffect{
	name = "HAMMER_ZONE_AURA_VERGE", image = "effects/zero_gravity.png",
	desc = _t"Spatial Abstraction",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return (_t"There is no gravity or friction here; you travel -indeed exist- only with an act of will. Movement is five times as fast and pinning is impossible. Maximum encumbrance is greatly increased.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { spacetime=true, aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	activate = function(self, eff)
		eff.encumb = self:addTemporaryValue("max_encumber", self:getMaxEncumbrance() * 20)
		self:effectTemporaryValue(eff, "pin_immune", 8.0)
		self:effectTemporaryValue(eff, "movement_speed", 4)
		self:checkEncumbrance()
		game.logPlayer(self, "#LIGHT_BLUE#You enter zone where space behaves differently, beware!")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_encumber", eff.encumb)
		self:checkEncumbrance()
	end,
}
