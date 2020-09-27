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
	desc = "Steel Rider",
	long_desc = function(self, eff) return ("The target is riding in a mechanical contraption."):format(eff.power) end,
	type = "other",
	subtype = { steam=true, vehicle=true },
	status = "beneficial",
	decrease = 0,
	parameters = { hull=10, pin=10, armor=0, speed=0, def=0, knock=0 },
	-- Healing goes to your hull first
	callbackPriorities={callbackOnHeal = 5},
	callbackOnWear = function(self, t, o, fBypass)
		if self:getInven("BODY") then 
			local am = self:getInven("BODY")[1] or {}
			if am.subtype == "massive" then
				game.logPlayer(self, "You can't keep operating your ride in massive armor.")
				self:removeEffect(self.EFF_REK_DEML_RIDE)
			end
		end
	end,
	callbackOnHeal = function(self, eff, value, src, raw_value)
		if value > 0 then
			local hullMissing = self:getMaxHull() - self:getHull()
			local healthMissing = self.max_life - self.life
			local hullRestored = math.min(hullMissing, value)
			self.hull = self.hull + hullRestored
			value = value - hullRestored
			local overheal = value - healthMissing
			if self.in_combat and overheal > 0 and self:knowTalent(self.T_REK_DEML_PILOT_PATCH) then self:setEffect(self.EFF_REK_DEML_TEMP_HULL, 3, {src=self, block=overheal}) end
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
	-- on_merge = function(self, old_eff, new_eff)
	-- 	return old_eff
	-- end,
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
		--self.hull = self:getMaxHull()
		self:updateModdableTile()
	end,
	deactivate = function(self, eff)
		--self.hull = 0
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
	name = "REK_DEML_TEMP_HULL", image = "talents/rek_deml_pilot_patch.png",
	desc = "Reinforced Hull",
	long_desc = function(self, eff)
		return ("Blocking up to %d total damage."):format(eff.block or 0)
	end,
	charges = function(self, eff) return math.floor(eff.block) end,
	type = "physical",
	subtype = {steamtech=true},
	status = "beneficial",
	parameters = {block = 0},
	activate = function(self, eff)
		eff.block = math.min(self:getMaxHull()/2, eff.block)
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={toback=false, size_factor=2, img="open_palm_block_tentacles2"}, shader={type="tentacles", backgroundLayersCount=-4, appearTime=0.3, time_factor=500, noup=0.0}})
		end
	end,
	deactivate = function(self, eff) end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.block = old_eff.block + new_eff.block
		old_eff.block = math.min(self:getMaxHull()/2, old_eff.block)
		return old_eff
	end,
	callbackPriorities={callbackOnTakeDamage = -5},
	callbackOnTakeDamage = function(self, eff, src, x, y, type, value, tmp)
		if value <= 0 then return end

		local dam = value
		game:delayedLogDamage(src, self, 0, ("#STEEL_BLUE#(%d to reinforced hull)#LAST#"):format(math.min(dam, eff.block)), false)
		if dam < eff.block then
			eff.block = eff.block - dam
			dam = 0
		else
			dam = dam - eff.block
			eff.block = 0
		end

		-- If we are at the end of the capacity
		if eff.block <= 0 then
			game.logPlayer(self, "#ORCHID#Your hull reinforcement is broken!#LAST#")
			self:removeEffect(self.EFF_REK_DEML_TEMP_HULL)
		end
		return {dam = dam}
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
	cancel_on_level_change = true,
	activate = function(self, eff)
	end,
	
	-- Method 2
	on_timeout = function(self, eff)
		if self.running then return end -- not in autoexplore or run
		if self:attr("never_move") then return end -- not while pinned
		if game.zone.wilderness then return end -- not on the world map
		local dx, dy = util.dirToCoord(eff.dir)
		
		if not game.level.map:checkAllEntities(self.x+dx, self.y+dy, "block_move", self) then
			if self:isTalentActive(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
				local damageFlame = self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "getDamage")
				game.level.map:addEffect(self, self.x, self.y, 4, engine.DamageType.FIRE, damageFlame, 0, 5, nil, {type="inferno"}, nil, true)
			end
			self:move(self.x+dx, self.y+dy, true)
		end
	end,
}