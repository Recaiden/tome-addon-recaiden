local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_DEML_SAVE_BOOST", image = "talents/rek_deml_drone_medic.png",
	desc = _t"Perfect Health",
	long_desc = function(self, eff) return ("The target's saves are boosted by %d."):tformat(eff.power) end,
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
	desc = _t"Revved Up",
	long_desc = function(self, eff) return ("The target's steam speed is increased by %d%%."):tformat(eff.power*100) end,
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
	desc = _t"Steel Rider",
	long_desc = function(self, eff) return ("The target is riding in a mechanical contraption."):tformat(eff.power) end,
	type = "other",
	subtype = { steam=true, vehicle=true },
	status = "beneficial",
	decrease = 0,
	parameters = { hull=10, pin=10, armor=0, speed=0, def=0, knock=0 },
	charges = function(self, eff) return math.ceil(self:getHull()) end,
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

			-- Remove effect, start coolingdown
			self:startTalentCooldown(self.T_REK_DEML_PILOT_AUTOMOTOR, 10)
			self:removeEffect(self.EFF_REK_DEML_RIDE)
			
			if self:knowTalent(self.T_REK_EVOLUTION_DEML_SPARE) and not self:isTalentCoolingDown(self.T_REK_EVOLUTION_DEML_SPARE) then
				self:callTalent(self.T_REK_EVOLUTION_DEML_SPARE, "trigger", true)
				if cb.value > self:getHull() then
					cb.value = cb.value - self:getHull()
				else
					cb.value = 0
					self.hull = self.hull - cb.value
				end
			end
			
		else
			self.hull = self.hull - cb.value
			cb.value = 0
		end
		game:delayedLogDamage(src, self, 0, ("#SLATE#(%d to hull)#LAST#"):tformat(hullLost), false)
		return cb.value
	end,
	-- on_merge = function(self, old_eff, new_eff)
	-- 	return old_eff
	-- end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "hull_regen", 0.25)
		if eff.pin then self:effectTemporaryValue(eff, "pin_immune", eff.pin) end
		if eff.knock then
			self:effectTemporaryValue(eff, "knockback_immune", eff.knock)
			if eff.knock > 0 then
				self:effectTemporaryValue(eff, "size_category", 1)
			end
		end
		if eff.speed then self:effectTemporaryValue(eff, "movement_speed", eff.speed) end
		if eff.armor then self:effectTemporaryValue(eff, "combat_armor", eff.armor) end
		if eff.def then self:effectTemporaryValue(eff, "combat_def", eff.def) end
		--self.hull = self:getMaxHull(

		local selfbase = self.replace_display or self
		if not selfbase.moddable_tile then
			local img = self.deml_ride_style or "classic"
			eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=1, y=-0.01, oversize=0.8, a=225, appear=1, speed=0, img="demolisher_ride_"..img, radius=0}))
		end		
		self:updateModdableTile()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if eff.particle then
			self:removeParticles(eff.particle)
		end
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
	desc = _t"Reinforced Hull",
	long_desc = function(self, eff)
		return ("Blocking up to %d total damage."):tformat(eff.block or 0)
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
		game:delayedLogDamage(src, self, 0, ("#STEEL_BLUE#(%d to reinforced hull)#LAST#"):tformat(math.min(dam, eff.block)), false)
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
	desc = _t"Drifting",
	long_desc = function(self, eff) return ("The target is coasting forward."):tformat() end,
	type = "other",
	subtype = { steam=true },
	status = "beneficial",
	parameters = { dir=1 },
	cancel_on_level_change = true,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=-1*util.dirToAngle(eff.dir)+90, y=0, oversize=0.6, a=100, appear=1, toback=true, speed=0, img="deml_drift_indicator", radius=1}))
	end,
	deactivate = function(self, eff)
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
	-- Method 2
	on_timeout = function(self, eff)
		if self.running then return end -- not in autoexplore or run
		if self:attr("never_move") then return end -- not while pinned
		if game.zone.wilderness then return end -- not on the world map
		local dx, dy = util.dirToCoord(eff.dir)
		
		if not game.level.map:checkAllEntities(self.x+dx, self.y+dy, "block_move", self) then
			if self:isTalentActive(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
				self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "applyFlames", self.x, self.y)
			end
			self:move(self.x+dx, self.y+dy, true)
		end
	end,
}


newEffect{
	name = "REK_DEML_HULL_PENALTY", image = "talents/rek_evolution_deml_spare.png",
	desc = _t"Getaway Drive",
	long_desc = function(self, eff) return ("The target has %d less hull until they can rebuild their main vehicle."):tformat(eff.power) end,
	type = "other",
	subtype = { steam=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "max_hull", -1 * eff.power)
	end,
	deactivate = function(self, eff)
	end,
}
