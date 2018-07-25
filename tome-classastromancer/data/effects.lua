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
   type = "magical",
   subtype = { arcane=true, shield=true },
   status = "beneficial",
   parameters = { power=100 },
   
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "stun_immune", 1.0)

      if core.shader.active(4) then
	 eff.particle = self:addParticles(Particles.new("shader_shield", 1, nil, {type="shield", shieldIntensity=0.2, color=eff.color or {0.2, 0.4, 0.8}}))
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
   long_desc = function(self, eff) return ("%d stacks, +%d%% to action speed."):format(eff.stacks, eff.stacks*0.022) end,
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
      -- No cheesing orb stacks
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
   useOrb = function(self, eff, amt)
      local amt = amt or eff.stacks
      local def = self.tempeffect_def[eff.effect_id]
      
      eff.stacks = eff.stacks - amt
      if eff.stacks <= 0 then
	 self:removeEffect(self.EFF_WANDER_LUXAM)
	 return
      end
      
      def.updateEffect(self, eff, eff, def)
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
   useOrb = function(self, eff, amt)
      local amt = amt or eff.stacks
      local def = self.tempeffect_def[eff.effect_id]
      
      eff.stacks = eff.stacks - amt
      if eff.stacks <= 0 then
	 self:removeEffect(self.EFF_WANDER_PONX)
	 return
      end
      
      def.updateEffect(self, eff, eff, def)
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
