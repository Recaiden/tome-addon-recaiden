local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "FLN_RUSH_MARK", image = "talents/fln_blood_rush.png",
   desc = "Marked for Death",
   long_desc = function(self, eff) return ("Reduces Blood Rush cooldown if killed"):format() end,
   type = "mental",
   subtype = { status=true, },
   status = "detrimental",
   parameters = { },
   
   activate = function(self, eff)
   end,

   deactivate = function(self, eff)
   end,

   callbackOnDeath = function(self, eff, src, note)
      marker = eff.src
      reduc = eff.dur * 2
      for tid, _ in pairs(marker.talents_cd) do
	 if tid == marker.T_FLN_BLOODSTAINED_RUSH then
	    local t = marker:getTalentFromId(tid)
	    if t and not t.fixed_cooldown then
	       marker.talents_cd[tid] = marker.talents_cd[tid] - reduc
	    end
	    break
	 end
      end
   end,
}

newEffect{
   name = "FLN_BLEED_VULN", image = "effects/stunned.png",
   desc = "Brutalized",
   long_desc = function(self, eff) return ("The target is brutally stunned, reducing damage by 60%%, movement speed by 50%%, bleed resist by 50%%, and preventing talent cooldown."):format() end,
   type = "physical",
   subtype = { stun=true },
   status = "detrimental",
   parameters = { },
   on_gain = function(self, err) return "#Target# is stunned by the brutal strike!", "+Brutalized" end,
   on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Brutalized" end,
  activate = function(self, eff)
     eff.tmpid = self:addTemporaryValue("stunned", 1)
     eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
     eff.speedid = self:addTemporaryValue("movement_speed", -0.5)
     eff.bleedid = self:addTemporaryValue("cut_immune", -0.5)
     
     local tids = {}
     for tid, lev in pairs(self.talents) do
	local t = self:getTalentFromId(tid)
	if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
     end
     for i = 1, 4 do
	local t = rng.tableRemove(tids)
	if not t then break end
	self:startTalentCooldown(t.id, 1)
     end
  end,
  deactivate = function(self, eff)
     self:removeTemporaryValue("stunned", eff.tmpid)
     self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
     self:removeTemporaryValue("movement_speed", eff.speedid)
     self:removeTemporaryValue("cut_immune", eff.bleedid)
  end,
}

newEffect{
   name = "Self-Judgement", image = "talents/fln_selfhate_judgement.png",
   desc = "Self-Judgement",
   long_desc = function(self, eff) return ("Your body is bleeding, losing %0.2f life each turn."):format(eff.power) end,
   type = "other",
   subtype = { bleed=true },
   status = "detrimental",
   parameters = { power=10 },
   on_gain = function(self, err) return "#CRIMSON##Target# is torn open by the powerful blow!", "+Self-Judgement" end,
   on_lose = function(self, err) return "#CRIMSON#The flames around #target# vanish.", "-Self-Judgement" end,
   on_merge = function(self, old_eff, new_eff)
      local remaining = old_eff.dur*old_eff.power
      old_eff.dur = new_eff.dur
      old_eff.power = remaining/(new_eff.dur or 1) + new_eff.power
      return old_eff
   end,
   activate = function(self, eff) end,
   deactivate = function(self, eff) end,
   on_timeout = function(self, eff)
      if eff.invulnerable then
	 eff.dur = eff.dur + 1
	 return
      end
      local dead, val = self:takeHit(eff.power, self, {special_death_msg="died a well-deserved death by exsanguination"})
      
      local srcname = self.x and self.y and game.level.map.seens(self.x, self.y) and self.name:capitalize() or "Something"
      game:delayedLogDamage(eff, self, val, ("#CRIMSON#%d Bleed #LAST#"):format(math.ceil(val)), false)
   end,
}

newEffect{
   name = "FLN_DIRGE_LINGER_FAMINE", image = "effects/fln_dirge_famine.png",
   desc = "Dirge of Famine",
   long_desc = function(self, eff) return ("The target is regenerating health"):format() end,
   type = "mental",
   subtype = { regen=true },
   status = "beneficial",
   parameters = { heal=1 },
   activate = function(self, eff)
      eff.healid = self:addTemporaryValue("life_regen", eff.heal)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("life_regen", eff.healid)
   end,
}

newEffect{
   name = "FLN_DIRGE_LINGER_CONQUEST", image = "effects/fln_dirge_conquest.png",
   desc = "Dirge of Conquest",
   long_desc = function(self, eff) return ("The target is stealing health"):format() end,
   type = "mental",
   subtype = { regen=true },
   status = "beneficial",
   parameters = { heal=1 },

   callbackOnCrit = function(self, eff)
      if self.turn_procs.fallen_conquest_on_crit then return end
      self.turn_procs.fallen_conquest_on_crit = true
      
      self:heal(self:mindCrit(eff.heal), self)
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   callbackOnKill = function(self, t)
      if self.turn_procs.fallen_conquest_on_kill then return end
      self.turn_procs.fallen_conquest_on_kill = true
      
      self:heal(self:mindCrit(eff.heal), self)
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
   name = "FLN_DIRGE_LINGER_PESTILENCE", image = "effects/fln_dirge_pestilence.png",
   desc = "Dirge of Pestilence",
   long_desc = function(self, eff) return ("The target is regenerating health"):format() end,
   type = "mental",
   subtype = { regen=true },
   status = "beneficial",
   parameters = { heal=1 },
   activate = function(self, eff)
      eff.healid = self:addTemporaryValue("life_regen", eff.heal)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("life_regen", eff.healid)
   end,
}

newEffect{
   name = "FLN_NO_LIGHT", image = "talents/fln_darkside_sunset.png",
   desc = "Lights Out",
   long_desc = function(self, eff) return ("The target is cut off from the sun"):format() end,
   type = "other",
   subtype = { magic=true },
   status = "detrimental",
   parameters = { unresistable=true },
   callbackOnActBase = function(self, t)
      self:incPositive(-1 * self:getPositive())
   end,   
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
}


newEffect{
   name = "FLN_BLINDING_LIGHT", image = "talents/fln_templar_sigil.png",
   desc = "Blinding Light",
   long_desc = function(self, eff) return ("The target is unable to see anything and burns for %0.2f light damage per turn."):format(eff.dam) end,
   type = "magical",
   subtype = { bane=true, blind=true },
   status = "detrimental",
   parameters = { dam=10},
   on_gain = function(self, err) return "#Target# loses sight!", "+Blind" end,
   on_lose = function(self, err) return "#Target# recovers sight.", "-Blind" end,
   on_timeout = function(self, eff)
      DamageType:get(DamageType.LIGHT).projector(eff.src, self.x, self.y, DamageType.LIGHT, eff.dam)
   end,
   activate = function(self, eff)
      eff.tmpid = self:addTemporaryValue("blind", 1)
      if game.level then
	 self:resetCanSeeCache()
	 if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
      end
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("blind", eff.tmpid)
      if game.level then
	 self:resetCanSeeCache()
	 if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
      end
   end,
}
