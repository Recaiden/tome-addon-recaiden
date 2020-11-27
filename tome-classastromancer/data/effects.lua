local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "WANDER_ICE_DAMAGE_SHIELD", image = "talents/wander_ice_shield.png",
	desc = "Icy Block",
	long_desc = function(self, eff) return ("The target is surrounded by an elemental shield and cannot be stunned"):format() end,
	type = "other",
	subtype = { arcane=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stun_immune", 1.0)
		
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, nil, {type="shield", shieldIntensity=0.1, color=eff.color or {0.2, 0.4, 0.8}}))
		end
		
	end,
	
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	
	--after each instance of damage, if you have no shield, the stun-proofing is set to expire
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state)
		if not self:hasEffect(self.EFF_DAMAGE_SHIELD) then
			eff.dur = 0
		end
		
	end,
	
	callbackOnActBase = function(self, eff)
		if not self:hasEffect(self.EFF_DAMAGE_SHIELD) then
			eff.dur = 0
		end
	end,
}


newEffect{
   name = "WANDER_KOLAL", image = "talents/wander_summon_fire.png",
   desc = "Planetary Charge: Kolal",
   long_desc = function(self, eff) return ("%d stacks, +%d%% to action speed."):format(eff.stacks, eff.stacks*2.2) end,
   type = "magical",
   subtype = { fire=true, haste=true },
   status = "beneficial",
   parameters = { stacks = 1, max_stacks = 1 },
   charges = function(self, eff) return eff.stacks end,
   on_gain = function(self, err) return nil, true end,
   on_lose = function(self, err) return nil, true end,
   updateEffect = function(self, old_eff, new_eff, e)
      -- Put this in __tmpvals so stuff like copyEffect doesn't break
      old_eff.__tmpvals = old_eff.__tmpvals or {}
      new_eff.__tmpvals = new_eff.__tmpvals or {}
      if old_eff.__tmpvals.kolspeedid then
	  self:removeTemporaryValue("combat_physspeed", old_eff.__tmpvals.kolspeedid)
	  self:removeTemporaryValue("combat_spellspeed", old_eff.__tmpvals.kolspellid)
      end
      new_eff.__tmpvals.kolspeedid = self:addTemporaryValue("combat_physspeed", new_eff.stacks*0.022)
      new_eff.__tmpvals.kolspellid = self:addTemporaryValue("combat_spellspeed", new_eff.stacks*0.022)
   end,
   on_merge = function(self, old_eff, new_eff, e)
      new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
      e.updateEffect(self, old_eff, new_eff, e)
      return new_eff
   end,
   activate = function(self, eff, e)
      e.updateEffect(self, eff, eff, e)
   end,
   callbackOnChangeLevel = function(self, eff, what, zone, level)
      if what == "leave" then self:removeEffect(eff) end
   end,
   deactivate = function(self, eff, e)
      self:removeTemporaryValue("combat_physspeed", eff.__tmpvals.kolspeedid)
      self:removeTemporaryValue("combat_spellspeed", eff.__tmpvals.kolspellid)
   end,
}


newEffect{
   name = "WANDER_LUXAM", image = "talents/wander_summon_ice.png",
   desc = "Planetary Charge: Luxam",
   long_desc = function(self, eff) return ("%d stacks, +%d%% resist all."):format(eff.stacks, eff.stacks*3) end,
   type = "magical",
   subtype = { cold=true, resist=true },
   status = "beneficial",
   parameters = { stacks = 1, max_stacks = 1 },
   charges = function(self, eff) return eff.stacks end,
   on_gain = function(self, err) return nil, true end,
   on_lose = function(self, err) return nil, true end,
   updateEffect = function(self, old_eff, new_eff, e)
      -- Put this in __tmpvals so stuff like copyEffect doesn't break
      old_eff.__tmpvals = old_eff.__tmpvals or {}
      new_eff.__tmpvals = new_eff.__tmpvals or {}
      if old_eff.__tmpvals.luxresid then
	 self:removeTemporaryValue("resists",old_eff.__tmpvals.luxresid)
      end
      new_eff.__tmpvals.luxresid = self:addTemporaryValue("resists",{all=new_eff.stacks*3})
   end,
   on_merge = function(self, old_eff, new_eff, e)
      new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
      e.updateEffect(self, old_eff, new_eff, e)
      return new_eff
   end,
   activate = function(self, eff, e)
      e.updateEffect(self, eff, eff, e)
   end,
   callbackOnChangeLevel = function(self, eff, what, zone, level)
      if what == "leave" then self:removeEffect(eff) end
   end,
   deactivate = function(self, eff, e)
      self:removeTemporaryValue("resists",eff.__tmpvals.luxresid)
   end,
}

newEffect{
   name = "WANDER_PONX", image = "talents/wander_summon_lightning.png",
   desc = "Planetary Charge: Ponx",
   long_desc = function(self, eff) return ("%d stacks, +%d%% healing mod."):format(eff.stacks, eff.stacks*15) end,
   type = "magical1",
   subtype = { lightning=true, heal=true },
   status = "beneficial",
   parameters = { stacks = 1, max_stacks = 1 },
   charges = function(self, eff) return eff.stacks end,
   on_gain = function(self, err) return nil, true end,
   on_lose = function(self, err) return nil, true end,
   updateEffect = function(self, old_eff, new_eff, e)
      -- Put this in __tmpvals so stuff like copyEffect doesn't break
      old_eff.__tmpvals = old_eff.__tmpvals or {}
      new_eff.__tmpvals = new_eff.__tmpvals or {}
      if old_eff.__tmpvals.ponxmodid then
	 self:removeTemporaryValue("healing_factor", old_eff.__tmpvals.ponxmodid)
      end
      new_eff.__tmpvals.ponxmodid = self:addTemporaryValue("healing_factor", new_eff.stacks*.15)
   end,
   on_merge = function(self, old_eff, new_eff, e)
      new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
      e.updateEffect(self, old_eff, new_eff, e)
      return new_eff
   end,
   activate = function(self, eff, e)
      e.updateEffect(self, eff, eff, e)
   end,
   callbackOnChangeLevel = function(self, eff, what, zone, level)
      if what == "leave" then self:removeEffect(eff) end
   end,
   deactivate = function(self, eff, e)
      self:removeTemporaryValue("healing_factor", eff.__tmpvals.ponxmodid)
   end,
}


newEffect{
   name = "WANDER_UNITY_OVERCHARGE", image = "talents/wander_feedback.png",
   desc = "Planetary Convergence",
   long_desc = function(self, eff) return ("%d%% movement, +%d on-hit, +%d regen"):format(eff.stacks_kolal*40, eff.stacks_ponx*20, eff.stacks_luxam*10) end,
   type = "magical",
   subtype = { fire=true, cold=true, lightning = true, haste=true, heal=true },
   status = "beneficial",
   parameters = { stacks_kolal = 1, stacks_luxam = 1, stacks_ponx = 1 },
   charges = function(self, eff) return eff.stacks end,
   activate = function(self, eff, e)
      eff.__tmpvals = {}
      eff.__tmpvals.speed = self:addTemporaryValue("movement_speed", eff.stacks_kolal * 0.40)
      eff.__tmpvals.regen = self:addTemporaryValue("life_regen", eff.stacks_luxam * 10)
      eff.__tmpvals.zap = self:addTemporaryValue("melee_project", {[DamageType.LIGHTNING] = eff.stacks_ponx * 20 })

      if core.shader.active(4) then
	 local slow = rng.percent(50)
	 local h1x, h1y = self:attachementSpot("hand1", true)
	 if h1x then eff.ps = self:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
	 local h2x, h2y = self:attachementSpot("hand2", true)
	 if h2x then eff.ps2 = self:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
      end
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("movement_speed", eff.__tmpvals.speed)
      self:removeTemporaryValue("life_regen", eff.__tmpvals.regen)
      self:removeTemporaryValue("melee_project", eff.__tmpvals.zap)
				--{[DamageType.LIGHTNING] = eff.stacks_ponx * 20 })
      if eff.ps then
	 self:removeParticles(eff.ps)
	 self:removeParticles(eff.ps2)
      end
   end,
}


newEffect{
   name = "WANDER_BOMBARDMENT", image = "talents/wander_meteor_bombardment.png",
   desc = "Meteor Bombardment",
   long_desc = function(self, eff) return ("%d stacks, +%d%% to meteor damage."):format(eff.stacks, eff.stacks*eff.power) end,
   type = "magical",
   subtype = { fire=true, haste=true },
   status = "beneficial",
   parameters = { stacks = 1, power = 1 },
   charges = function(self, eff) return eff.stacks end,
   on_gain = function(self, err) return nil, true end,
   on_lose = function(self, err) return nil, true end,
   updateEffect = function(self, old_eff, new_eff, e)
      -- Put this in __tmpvals so stuff like copyEffect doesn't break
      old_eff.__tmpvals = old_eff.__tmpvals or {}
      new_eff.__tmpvals = new_eff.__tmpvals or {}
      if old_eff.__tmpvals.bomb_damage_id then
	  self:removeTemporaryValue("inc_damage", old_eff.__tmpvals.bomb_damage_id)
      end
      new_eff.__tmpvals.bomb_damage_id = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL] = math.min(50, new_eff.stacks*new_eff.power), [DamageType.FIRE] = math.min(50, new_eff.stacks*new_eff.power)})
      
      if new_eff.ps and new_eff.ps._shader and new_eff.ps._shader.shad then
	 if not new_eff.ps.shader then
	    self:removeParticles(new_eff.ps)
	    new_eff.ps = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=0, radius=1.5, img="meteor_orbs"},
							 {type="boneshield",
							  scrollingSpeed=-0.003,
							  ellipsoidalFactor={1, 1.2}}))
	 end
	 
	 new_eff.ps._shader.shad:resetClean()
	 new_eff.ps._shader:setResetUniform("chargesCount", util.bound(new_eff.__tmpvals.bomb_damage_id/5, 0, 5))
	 new_eff.ps.shader.chargesCount = util.bound(new_eff.__tmpvals.bomb_damage_id/5, 0, 5)
      end
   end,
   on_merge = function(self, old_eff, new_eff, e)
      new_eff.stacks = old_eff.stacks + 1
      new_eff.ps = old_eff.ps
      e.updateEffect(self, old_eff, new_eff, e)
      return new_eff
   end,
   activate = function(self, eff, e)
      if core.shader.allow("adv") then
	 eff.ps = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotatwion=0, radius=1.5, img="meteor_orbs"},
						  {type="boneshield",
						   scrollingSpeed=-0.003,
						   ellipsoidalFactor={1, 1.2}}))
	 eff.ps._shader.shad:resetClean()
	 eff.ps._shader:setResetUniform("chargesCount", 1)
	 eff.ps.shader.chargesCount = 1
      end
      e.updateEffect(self, eff, eff, e)
   end,
   callbackOnChangeLevel = function(self, eff, what, zone, level)
      if what == "leave" then self:removeEffect(eff) end
   end,
   deactivate = function(self, eff, e)
      if eff.ps then self:removeParticles(eff.ps) end
      self:removeTemporaryValue("inc_damage", eff.__tmpvals.bomb_damage_id)
   end,
}


newEffect{
   name = "WANDER_ICE_SPEED", image = "talents/wander_ice_speed.png",
   desc = "Skating",
   long_desc = function(self, eff) return ("The target is sliding on ice, moving extra fast"):format() end,
   type = "physical",
   subtype = { speed=true },
   status = "beneficial",
   parameters = { },
   on_merge = function(self, old_eff, new_eff)
      return old_eff
   end,
   on_gain = function(self, err)
      return nil, true
   end,
   on_lose = function(self, err)
      return nil, true
   end,
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
      if eff.particle then
	 self:removeParticles(eff.particle)
      end
   end,
}

newEffect{
	name = "WANDER_METEOR_STORM", image = "talents/wander_meteor_storm.png",
	desc = "Meteor Rain",
	long_desc = function(self, eff) return ("The target is summoning meteors"):format() end,
	type = "magical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = {power=100, range=4, radius=1},
	callbackOnActBase = function(self, eff, multiplier)
		multiplier = multiplier or 1.0
		local rad = 1
		if multiplier < 1 then rad = 0.5 + 0.5 * multiplier end
		local meteor = function(src, x, y, dam)
			game.level.map:particleEmitter(x, y, 5*rad, "meteor", {x=x, y=y}).on_remove = function(self)
				local x, y = self.args.x, self.args.y
				if core.shader.active() then
					game.level.map:particleEmitter(x, y, rad, "starfall", {radius=rad, tx=tx, ty=ty})
				else
					game.level.map:particleEmitter(x, y, rad, "shadow_flash", {radius=rad, grids=grids, tx=tx, ty=ty})
					game.level.map:particleEmitter(x, y, rad, "circle", {oversize=0.7, a=60, limit_life=16, appear=8, speed=-0.5, img="darkness_celestial_circle", radius=rad})
				end
				game:getPlayer(true):attr("meteoric_crash", 1)
																																										end
		end
		
		--Collect possible targets
		local list = {}
		--Near the player
		self:project({type="ball", radius=eff.range}, self.x, self.y, function(px, py)
									 local actor = game.level.map(px, py, Map.ACTOR)
									 if actor and self:reactionToward(actor) < 0 then list[#list+1] = actor end  
																																	end)
		
		--Near summons
		local apply = function(a)
			a:project({type="ball", radius=eff.range}, a.x, a.y,
								function(px, py)
									local actor = game.level.map(px, py, Map.ACTOR)
									if actor and self:reactionToward(actor) < 0 then
										list[#list+1] = actor
									end
								end)
		end
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					apply(act)
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					apply(act)
				end
			end
		end
		
		-- determine damage for this turn
		local dam = 0
		if #list > 0 then
			dam = self:spellCrit(eff.power)
			if multiplier then dam = dam * multiplier end
		end
		
		-- Hit a random enemy
		local nb = 0
		while #list > 0 and nb < 1 do
			local a = rng.tableRemove(list)
			
			-- Hit within 1 space of the target so they're always included.
			local tx = util.bound(a.x + rng.range(-1,1), 0, game.level.map.w-1)
			local ty = util.bound(a.y + rng.range(-1,1), 0, game.level.map.h-1)
			
			-- Don't use the BIZARRE REALTIME METEOR for damage, just for visuals
			meteor(self, tx, ty, 0)
			self:project({type="ball", x=tx, y=ty, radius=1, friendlyfire=false}, tx, ty, DamageType.FIRE, dam)
			
			-- Void summons hook
			if self:knowTalent(self.T_WANDER_METEOR_VOID_SUMMONS) then
				local tal_vs = self:getTalentFromId(self.T_WANDER_METEOR_VOID_SUMMONS)
				if rng.percent(tal_vs.getChance(self, tal_vs)) then
					if rng.percent(50) then
						tal_vs.callLosgoroth(self, tal_vs, a.x, a.y, a)
					else
						tal_vs.callManaworm(self, tal_vs, a.x, a.y, a)
					end
				end
			end
			
			nb = nb + 1
		end
	end,
	on_gain = function(self, err)
		return nil, true
	end,
	on_lose = function(self, err)
		return nil, true
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}


newEffect{
	name = "WANDER_UNITY_CONVERGENCE", image = "talents/wander_cycle_boost.png",
	desc = "Planetary Convergence",
	long_desc = function(self, eff) return ("The target is preparing to summon a mighty elemental"):format() end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { count=1, extend=0, ultimate=false },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}


newEffect{
	name = "WANDER_CORROSIVE_WORM", image = "talents/corrosive_worm.png",
	desc = "Corrosive Worm",
	long_desc = function(self, eff) return ("The target is infected with a lesser manaworm, reducing damage resistance by %d%%. When the effect ends, the worm will explode, dealing %d arcane damage in a 2 radius ball. This damage will increase by %d%% of all damage taken while under this effect"):format(eff.power, eff.finaldam, eff.rate*100) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = { power=20, rate=10, finaldam=50, },
	on_gain = function(self, err) return "#Target# is infected by a corrosive worm.", "+Corrosive Manaworm" end,
	on_lose = function(self, err) return "#Target# is free from the corrosive worm.", "-Corrosive Manaworm" end,
	activate = function(self, eff)
		eff.projector = eff.src.summoner or eff.src
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=0, oversize=0.7, a=255, appear=8, speed=0, img="blight_worms", radius=0}))
		self:effectTemporaryValue(eff, "resists", {all=-eff.power})
	end,
	deactivate = function(self, eff)
		local tg = {type="ball", radius=2, selffire=false, friendlyfire=false, x=self.x, y=self.y}
		eff.src:project(tg, self.x, self.y, DamageType.MANABURN, eff.finaldam, {type="acid"})
		self:removeParticles(eff.particle)
	end,
	callbackOnHit = function(self, eff, cb)
		eff.finaldam = eff.finaldam + (cb.value * eff.rate)
		return true
	end,
	on_die = function(self, eff)
		local tg = {type="ball", radius=2, selffire=false, x=self.x, y=self.y}
		eff.projector:project(tg, self.x, self.y, DamageType.MANABURN, eff.finaldam, {type="acid"})
	end,
}

newEffect{
	name = "WANDER_FISSURE_AMP", image = "talents/wander_fire_fissure.png",
	desc = "Tectonic Crush",
	long_desc = function(self, eff) return ("The target is seared by otherworldly flame, causing them to take %d%% more damage from elementals."):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = { power=20 },
	callbackOnTakeDamageBeforeResists = function(self, eff, src, x, y, type, dam, state)
		if src and src.type == "elemental" then
			dam = dam * (1 + eff.power/100)
		end
		return {dam=dam}
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "WANDER_INVIGORATING_CHILL", image = "talents/wander_ice_slow.png",
	desc = "Invigorating Chill",
	long_desc = function(self, eff) return ("Increases global speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	subtype = { telekinesis=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Quick" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Quick" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "WANDER_WATER_DANCE", image = "talents/wander_water_dance.png",
	desc = "Dancing Waves",
	long_desc = function(self, eff)
		local str = ("The target has been injured, but can recover up to %d life with the power of water."):format(eff.damage)
		return str
	end,
	type = "magical",
	subtype = { water=true },
	status = "beneficial",
	parameters = { damage=0, hits={{life = 2, power=10}}},
	charges = function(self, eff)
		return math.round(eff.damage)

	end,
	activate = function(self, eff)
		local damageTotal = 0
		for i, instance in pairs(eff.hits) do
			damageTotal = damageTotal + instance.power
		end
		eff.damage = damageTotal
	end,
	deactivate = function(self, eff)
	end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the best part of each effect
		old_eff.dur = new_eff.dur
		-- add new damage instance
		old_eff.hits[#old_eff.hits+1] = new_eff.hits[1]

		local damageTotal = 0
		for i, instance in pairs(old_eff.hits) do
			damageTotal = damageTotal + instance.power
		end
		old_eff.damage = damageTotal
		
		return old_eff
	end,
	on_timeout = function(self, eff)
		for i, instance in pairs(eff.hits) do
			-- applications that have lived out their allotted time are cleared.
			instance.life = instance.life - 1
			if instance.life <= 0 then
				eff.hits[i] = nil
			end
		end
		
		local damageTotal = 0
		for i, instance in pairs(eff.hits) do
			damageTotal = damageTotal + instance.power
		end
		eff.damage = damageTotal
	end,
}