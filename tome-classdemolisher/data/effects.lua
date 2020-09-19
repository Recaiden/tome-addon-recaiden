local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_DEML_SAVE_BOOST", image = "talents/rek_deml_drone_medic.png",
	desc = "Perfect Health",
	long_desc = function(self, eff) return ("The target's saves are boosted by %d."):format(eff.power) end,
	type = "physical",
	subtype = { steam=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physresist", eff.power)
		self:effectTemporaryValue(eff, "combat_spellresist", eff.power)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.power)
	end,
}

newEffect{
	name = "REK_DEML_REVVED_UP", image = "talents/rek_deml_pilot_rev_up.png",
	desc = "Revved Up",
	long_desc = function(self, eff) return ("The target's steam speed is increased by %d%%."):format(eff.power*100) end,
	type = "physical",
	subtype = { steam=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_steamspeed", eff.power)
	end,
}

newEffect{
	name = "REK_DEML_RIDE", image = "talents/rek_deml_pilot_automotor.png",
	desc = "Piloting",
	long_desc = function(self, eff) return ("The target is riding in a mechanical contraption."):format(eff.power) end,
	type = "other",
	subtype = { steam=true, vehicle=true },
	status = "beneficial",
	decrease = 0,
	parameters = { hull=10, pin=10, armor=0, speed=0, def=0, knock=0 },
	-- Healing goes to your hull first
	callbackPriorities={callbackOnHeal = 5},
	callbackOnHeal = function(self, eff, value, src, raw_value)
		if value > 0 then
			local hullMissing = self:getMaxHull() - self:getHull()
			local hullRestored = math.min(hullMissing, value)
			self.hull = self.hull + hullRestored
			value = value - hullRestored
			return {value = value}
		end
	end,
	callbackOnHit = function(self, eff, cb, src, dt)
		local hullLost = math.min(cb.value, self:getHull())
		if cb.value > self:getHull() then
			cb.value = cb.value - self:getHull()
			self.hull = 0
			self:removeEffect(self.EFF_REK_DEML_RIDE)
			self:startTalentCooldown(self.T_REK_DEML_PILOT_AUTOMOTOR)
			game:playSoundNear(self, "talents/breaking")
		else
			self.hull = self.hull - cb.value
			cb.value = 0
		end
		game:delayedLogDamage(src, self, 0, ("#SLATE#(%d to hull)#LAST#"):format(hullLost), false)
		cb.value = 0
		return true
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "hull_regen", 0.25)
		if eff.pin then self:effectTemporaryValue(eff, "pin_immune", eff.pin) end
		if eff.knock then
			self:effectTemporaryValue(eff, "knockback_immune", eff.knock)
			self:effectTemporaryValue(eff, "size_category", 1)
		end
		if eff.speed then self:effectTemporaryValue(eff, "movement_speed", eff.speed) end
		if eff.armor then self:effectTemporaryValue(eff, "combat_armor", eff.armor) end
		if eff.def then self:effectTemporaryValue(eff, "combat_def", eff.def) end
		self.hull = self:getMaxHull()
		self:updateModdableTile()
	end,
	deactivate = function(self, eff)
		self.hull = 0
		self:updateModdableTile()
		if not self:isTalentCoolingDown(self.T_REK_DEML_PILOT_AUTOMOTOR) then
			self:startTalentCooldown(self.T_REK_DEML_PILOT_AUTOMOTOR)
		end
		if self:isTalentActive(self.T_REK_DEML_ENGINE_FULL_THROTTLE) then
			self:forceUseTalent(self.T_REK_DEML_ENGINE_FULL_THROTTLE, {ignore_energy=true})
		end
		if self:isTalentActive(self.T_REK_DEML_ENGINE_DRIFT_NOZZLES) then
			self:forceUseTalent(self.T_REK_DEML_ENGINE_DRIFT_NOZZLES, {ignore_energy=true})
		end
	end,
}

newEffect{
	name = "REK_DEML_DRIFTING", image = "talents/rek_deml_engine_drift_nozzles.png",
	desc = "Drifting",
	long_desc = function(self, eff) return ("The target is coasting forward."):format() end,
	type = "other",
	subtype = { steam=true },
	status = "beneficial",
	parameters = { dir=1 },
	activate = function(self, eff)
	end,
	-- Method 1
	-- callbackOnActBase = function(self, eff)
	-- 	if self.running and self.running.explore then return end
	-- 	if self:attr("never_move") then return end
	-- 	local dx, dy = util.dirToCoord(eff.dir)
		
	-- 	if not game.level.map:checkAllEntities(self.x+dx, self.y+dy, "block_move", self) then
	-- 		self:move(self.x+dx, self.y+dy, true)
	-- 	end
	-- end,
	
	-- Method 2
	on_timeout = function(self, eff)
		if self.running and self.running.explore then return end
		if self:attr("never_move") then return end
		local dx, dy = util.dirToCoord(eff.dir)
		
		if not game.level.map:checkAllEntities(self.x+dx, self.y+dy, "block_move", self) then
			self:move(self.x+dx, self.y+dy, true)
			if self:isTalentActive(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
				local damageFlame = self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "getDamage")
				game.level.map:addEffect(self, self.x, self.y, 4, engine.DamageType.FIRE, damageFlame, 0, 5, nil, {type="inferno"}, nil, true)
			end
		end
	end,
}