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
   type = "other",
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
      local tid = marker.T_FLN_BLOODSTAINED_RUSH
      if marker.talents_cd[tid] then
         marker.talents_cd[tid] = marker.talents_cd[tid] - reduc
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
   name = "FLN_JUDGEMENT_BLEED", image = "talents/fln_selfhate_judgement.png",
   desc = "Self-Judgement",
   long_desc = function(self, eff) return ("Your body is bleeding, losing %0.2f life each turn."):format(eff.power) end,
   type = "other",
   subtype = { bleed=true },
   status = "detrimental",
   parameters = { power=10 },
   on_gain = function(self, err) return "#CRIMSON##Target# is torn open by the powerful blow!", "+Self-Judgement" end,
   on_lose = function(self, err) return "#CRIMSON##Target#'s wound has closed.", "-Self-Judgement" end,
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
   name = "FLN_DIRGE_LINGER_FAMINE", image = "talents/fln_dirge_famine.png",
   desc = "Dirge of Famine",
   long_desc = function(self, eff) return ("The target is regenerating health"):format() end,
   type = "magical",
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
   name = "FLN_DIRGE_LINGER_CONQUEST", image = "talents/fln_dirge_conquest.png",
   desc = "Dirge of Conquest",
   long_desc = function(self, eff) return ("The target will gain a surge of energy on kill or crit"):format() end,
   type = "magical",
   subtype = { haste=true },
   status = "beneficial",
   parameters = { heal=1 },

   callbackOnCrit = function(self, eff)
      if self.turn_procs.fallen_conquest_on_crit then return end
      self.turn_procs.fallen_conquest_on_crit = true

      self.energy.value = self.energy.value + 100
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   callbackOnKill = function(self, t)
      if self.turn_procs.fallen_conquest_on_kill then return end
      self.turn_procs.fallen_conquest_on_kill = true
      
      self.energy.value = self.energy.value + 500
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
   name = "FLN_DIRGE_LINGER_PESTILENCE", image = "talents/fln_dirge_pestilence.png",
   desc = "Dirge of Pestilence",
   long_desc = function(self, eff) return ("The target will gain a shield upon suffering a detrimental effect"):format() end,
   type = "magical",
   subtype = { shield=true },
   status = "beneficial",
   parameters = { shield=50, cd=5 },
   callbackOnTemporaryEffectAdd = function(self, eff, eff_id, e_def, eff_incoming)
      if not self:hasProc("rek_fln_dirge_shield") then
         if e_def.status == "detrimental" and e_def.type ~= "other" and eff_incoming.src ~= self then
            self:setProc("rek_fln_dirge_shield", true, eff.cd)
            self:setEffect(self.EFF_DAMAGE_SHIELD, eff_incoming.dur, {color={0xff/255, 0x3b/255, 0x3f/255}, power=self:spellCrit(eff.shield)})
         end
      end
   end,
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
   name = "FLN_NO_LIGHT", image = "talents/fln_darkside_sunset.png",
   desc = "Lights Out",
   long_desc = function(self, eff) return "The target is cut off from the sun" end,
   type = "other",
   subtype = { magic=true },
   status = "detrimental",
   parameters = { },
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
   subtype = { light=true, blind=true },
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

newEffect{
   name = "FLN_GRAVITY_BUFF", image = "talents/fln_blacksun_devour.png",
   desc = "Devourer Stance",
   long_desc = function(self, eff)
      local desc = ("The target is redirecting energy, adding %d gravity damage to their attacks."):format(eff.gravity)
      if eff.counter and eff.counter < 3 then
         return desc..("The target is storing up healing energy, currently %d"):format(eff.heal)
      end
      return desc
   end,
   type = "magical",
   subtype = { gravity=true },
   status = "beneficial",
   parameters = { gravity=10, heal=0 },
   callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
      if eff.counter < 3 then
         local dam_absorb = dam * 0.5
         eff.heal = eff.heal + dam_absorb
      end
      return {dam=dam}
   end,
   activate = function(self, eff)
      eff.counter = 0
      local damtype = DamageType.REK_FLN_GRAVITY_PULL
      eff.onhit = self:addTemporaryValue("melee_project", {[damtype] = eff.gravity})
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("melee_project", eff.onhit)
   end,
   on_timeout = function(self, eff)
      if not eff.counter then eff.counter = 0 end
      eff.counter = eff.counter + 1
      if eff.counter == 3 then
         self:attr("allow_on_heal", 1)
         self:heal(eff.heal, eff.src)
         self:attr("allow_on_heal", -1)
         eff.heal = 0
      end
   end,
         }


newEffect{
   name = "FLN_VAMPIRE_MARK", image = "talents/fln_templar_mark_of_the_vampire.png",
   desc = "Mark of the Vampire",
   long_desc = function(self, eff) return ("The target is doomed to die a bloody death.  Each time it uses an ability it takes %0.2f physical damage, and incoming bleeds are strengthened by %d%%."):
      format(eff.dam, eff.power*100)
   end,
   charges = function(self, eff) return (tostring(math.floor((eff.power-1)*100)).."%") end,
   type = "mental",
   subtype = { psionic=true },
   status = "detrimental",
   parameters = {dam=10, power = 0.1},

   callbackOnTalentPost = function(self, eff, ab)
      DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.dam)
   end,

   callbackOnTemporaryEffectAdd = function(self, eff, eff_id, e_def, new_eff)
      if e_def.subtype.bleed and e_def.type ~= "other" then
         new_eff.power = new_eff.power * (1+eff.power)
      end
   end,
   
   on_gain = function(self, err) return "#Target# is doomed!", "+Vampire Mark" end,
   on_lose = function(self, err) return "#Target# is free from their doom.", "-Vampire Mark" end,
}

newEffect{
   name = "FLN_SHADOW_FADE_SHIELD", image = "talents/flash_of_the_blade.png",
   desc = "Protected by the Sun",
   long_desc = function(self, eff) return "The Sun has granted brief invulnerability." end,
   type = "other",
   subtype = {},
   status = "beneficial",
   on_gain = function(self, err) return "#Target# is surrounded by a radiant shield!", "+Divine Shield" end,
   parameters = {},
   activate = function(self, eff)
      eff.iid = self:addTemporaryValue("invulnerable", 1)
      eff.imid = self:addTemporaryValue("status_effect_immune", 1)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("invulnerable", eff.iid)
      self:removeTemporaryValue("status_effect_immune", eff.imid)
   end,
   on_timeout = function(self, eff)
      -- always remove
      return true
   end,
}

newEffect{
   name = "FLN_SHADOW_REFT", image = "effects/fln_shadow_shadow_reave.png",
   desc = "Shadowless",
   long_desc = function(self, eff) return ("Target has lost their shadow, lowering light/dark resistance by %d%%."):format(-eff.resists) end,
   type = "mental",
   subtype = { shadow=true, psionic=true },
   status = "detrimental",
   parameters = { resists = 5 },
   on_gain = function(self, err) return "#F53CBE##Target#'s shadow is torn away!", "+Reft" end,
   on_lose = function(self, err) return "#Target#'s shadow returns to them.", "-Reft" end,
   activate = function(self, eff)
      eff.resistChangeId = self:addTemporaryValue("resists", { [DamageType.LIGHT]=-1*eff.resists, [DamageType.DARKNESS]=-1*eff.resists })
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("resists", eff.resistChangeId)
   end,
}


-- type other because the original was, this is a resource mechanic.
newEffect{
   name = "FLN_ABSORPTION_STRIKE", image = "talents/absorption_strike.png",
   desc = "Shadow Absorption",
   long_desc = function(self, eff) return ("The target's light has been drained, reducing light resistance by %d%%."):format(eff.power) end,
   type = "other",
   subtype = { sun=true, },
   status = "detrimental",
   parameters = { power = 10 },
   on_gain = function(self, err) return "#Target# is drained from light!", "+Shadow Absorption" end,
   on_lose = function(self, err) return "#Target#'s light is back.", "-Shadow Absorption" end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=-eff.power})
   end,
   callbackOnMeleeHit = function(self, eff, attacker, dam)
      attacker:incHate(1)
   end,
         }

-- type other because it's just a delayed talent.  Defend by not getting melee hit.
newEffect{
   name = "FLN_LIGHT_VICTIM", image = "talents/fln_shadow_mages.png",
   desc = "Searing Mark",
   long_desc = function(self, eff) return ("The target is marked by a shadow anorithil, and will take %d light damage if hit by the shadow's summoner."):format(eff.power) end,
   type = "other",
   subtype = { sun=true, },
   status = "detrimental",
   parameters = { power = 10 },
   on_gain = function(self, err) return "#Target# is marked by the light!", "+Searing Mark" end,
   on_lose = function(self, err) return "#Target#'s is free from the mark.", "-Searing Mark" end,
   activate = function(self, eff)
      eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=1, oversize=1.0, a=200, appear=8, speed=0, img="fln_marked", radius=0}))
   end,
   deactivate = function(self, eff)
      self:removeParticles(eff.particle)
   end,
   callbackOnMeleeHit = function(self, eff, attacker, dam)
      if attacker == eff.fallen then
         --trigger the spell
         local x = self.x
         local y = self.y
         local target = self
         if not x or not y then return nil end

         local projector = eff.shadow or eff.fallen
         if target then
            projector:project({type="hit", talent=t}, x, y, DamageType.LIGHT, eff.power, {type="light"})
            self:removeEffect(self.EFF_FLN_LIGHT_VICTIM)
         end
         
         -- Add a lasting map effect
         game.level.map:addEffect(projector,
                                  x, y, 4,
                                  DamageType.LIGHT, eff.power / 2,
                                  1,
                                  5, nil,
                                  {type="light_zone"},
                                  nil, false, false
                                 )
         
         game:playSoundNear(self, "talents/flame")
      end
   end,
}