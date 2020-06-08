local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "REK_MTYR_UNNERVE", image = "talents/rek_mtyr_unnerve.png",
   desc = "Unnerved",
   long_desc = function(self, eff) return ("Unable to handle the truth, giving them a %d chance to act randomly, suffering %d damage, and losing %d power."):format(eff.power, eff.damage, eff.powerlessness) end,
   type = "mental",
   subtype = { confusion=true, },
   status = "detrimental",
   parameters = { power = 20, damage=0, powerlessness=0 },
   
   activate = function(self, eff)
      eff.power = math.floor(util.bound(eff.power, 0, 50))
      eff.tmpid = self:addTemporaryValue("confused", eff.power)

      if eff.powerlessness > 0 then
         eff.mental = self:addTemporaryValue("combat_mindpower", -eff.powerlessness)
         eff.spell = self:addTemporaryValue("combat_spellpower", -eff.powerlessness)
         eff.physical = self:addTemporaryValue("combat_dam", -eff.powerlessness)
      end
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("confused", eff.tmpid)
      if eff.mental then
         self:removeTemporaryValue("combat_mindpower", eff.mental)
         self:removeTemporaryValue("combat_spellpower", eff.spell)
         self:removeTemporaryValue("combat_dam", eff.physical)
      end
      if self == game.player and self.updateMainShader then self:updateMainShader() end
   end,
   on_timeout = function(self, eff)
      if eff.damage > 0 then
         DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, eff.damage)
      end
   end,
}

newEffect{
   name = "REK_MTYR_JOLT_SHIELD", image = "talents/rek_mtyr_whispers_shield.png",
   desc = "Recently Awakened",
   long_desc = function(self, eff) return ("Just woke up and is immune to all damage."):format() end,
   type = "other",
   subtype = { temporal=true },
   status = "beneficial",
   parameters = { power=100 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "cancel_damage_chance", 100)
   end,
   deactivate = function(self, eff)
   end,
   callbackOnAct = function(self, t)
      self:removeEffect(self.EFF_REK_MTYR_JOLT_SHIELD)
   end,
}


newEffect{
   name = "REK_MTYR_SCORN", image = "talents/rek_mtyr_scourge_infest.png",
   desc = "Scorned",
   long_desc = function(self, eff)
      local str = ("The target's self-image has been crushed, and they take %d damage each turn as a Disease effect"):format(eff.damage)
      if eff.lifesteal > 0 then
         str = str..(" and heal the source for %d%% as much."):format(eff.lifesteal*100)
      else
         str = str.."."
      end
      if eff.ramp > 1 then
         str = str..("\nThe damage's intensity will increase by %d%% per turn."):format((eff.ramp-1)*100)
      end
      if eff.fail > 0 then
         str = str..("\nThe pain causes them to have a %d%% chance to fail to use talents."):format(eff.pain)
      end
      return str
   end,
   type = "mental",
   subtype = { confusion=true, },
   status = "detrimental",
   parameters = { damage=10, ramp=1, lifesteal=0, fail=0 },
   activate = function(self, eff)
      if eff.fail then
         self:effectTemporaryValue(eff, "talent_fail_chance", eff.fail)
      end
   end,
   deactivate = function(self, eff)
   end,
   on_timeout = function(self, eff)
      if eff.damage > 0 then
         local realdam = DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, eff.damage)
         if eff.src and realdam > 0 and not eff.src:attr("dead") then
            eff.src:heal(realdam * eff.lifesteal, self)
         end
      end
      eff.damage = eff.damage*eff.ramp
   end,
         }

newEffect{
   name = "REK_MTYR_INSPIRED", image = "talents/rek_mtyr_polarity_rebound.png",
   desc = "Inspired",
   long_desc = function(self, eff) return ("You are empowered by your madness, increasing  mindpower by %d."):format(eff.power * eff.stacks) end,
   type = "other",
   charges = function(self, eff) return eff.stacks end,
   subtype = { demented=true },
   status = "beneficial",
   parameters = { power=2, stacks=1, max_stacks=5 },
   on_merge = function(self, old_eff, new_eff)
      old_eff.dur = new_eff.dur
      old_eff.stacks = math.min(old_eff.stacks + new_eff.stacks, new_eff.max_stacks)
      old_eff.power = math.max(old_eff.power, new_eff.power)
      
      self:removeTemporaryValue("combat_mindpower", old_eff.mentalP)
      
      old_eff.mentalP = self:addTemporaryValue("combat_mindpower", old_eff.power*old_eff.stacks)
      
      return old_eff
   end,   
   activate = function(self, eff)
      eff.mentalP = self:addTemporaryValue("combat_mindpower", eff.power*eff.stacks)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("combat_mindpower", eff.mentalP)
   end,
}

newEffect{
   name = "REK_MTYR_DEMENTED", image = "talents/rek_mtyr_polarity_dement.png",
   desc = "Demented",
   long_desc = function(self, eff) return ("The target cannot think clearly, reducing their damage and increasing their cooldowns by %d%%."):format(eff.power) end,
   type = "mental",
   subtype = { demented=true },
   status = "detrimental",
   parameters = { power=0.1 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "numbed", eff.power*100)
      -- cooldown increase is in Actor.Lua
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
   name = "REK_MTYR_MANIC_SPEED", image = "talents/rek_mtyr_polarity_dement.png",
   desc = "Demented",
   long_desc = function(self, eff) return ("The target is moving at infinite speed for %d to %d steps."):format(eff.min_steps, eff.max_steps) end,
   type = "mental",
   charges = function(self, eff) return math.max(0, eff.min_steps - eff.steps) end,
   subtype = { haste=true },
   status = "beneficial",
   parameters = { min_steps=1, max_steps=8 },

   on_gain = function(self, err) return "#Target# accelerates out of sight!", "+Infinite Speed" end,
   on_lose = function(self, err) return "#Target# has lost their manic speed.", "-Infinite Speed" end,
   activate = function(self, eff)
      -- absurd hack, please replace 
      --self:effectTemporaryValue(eff, "move_stamina_instead_of_energy", -0.00001)
      self.did_energy = true
      eff.steps = 0
   end,
   deactivate = function(self, eff)
   end,
   callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
      if not moved then return end
      if ox == x and oy == y then return end

      self.did_energy = true
      if self.reload then
         local reloaded = self:reload()
         if not reloaded and self.reloadQS then
            self:reloadQS()
         end
      end
      --self.energy.value = self.energy.value + game.energy_to_act * self:combatMovementSpeed(x, y)
      
      eff.steps = eff.steps + 1
      local remaining = eff.max_steps - eff.steps +1
      if eff.steps >= eff.max_steps or (eff.steps > eff.min_steps and rng.percent(100/remaining)) then
         self:removeEffect(self.EFF_REK_MTYR_MANIC_SPEED)
      end
   end,
         }

newEffect{
   name = "REK_MTYR_OVERSEER", image = "talents/rek_mtyr_vagabond_tainted_bullets.png",
   desc = "Psychic Tunneling",
   long_desc = function(self, eff) return ("Detects creatures of type %s/%s in radius 15."):format(eff.type, eff.subtype) end,
   type = "mental",
   subtype = { whisper=true },
   status = "beneficial",
   parameters = { type="humanoid", subtype="human" },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "esp", {[eff.type.."/"..eff.subtype]=1})
      self:effectTemporaryValue(eff, "esp_range", 5)
   end,
   deactivate = function(self, eff)
   end,
         }

newEffect{
   name = "REK_FLAG_SYMBIOSIS", image = "talents/rek_mtyr_standard_symbiosis.png",
   desc = "Aura of Confidence",
   long_desc = function(self, eff) return ("Linked to their flag gaining %d%% all damage resistance."):format(eff.resist) end,
   type = "other",
   subtype = { miscellaneous=true },
   status = "beneficial",
   parameters = { resist=10, save=0 },
   on_gain = function(self, err) return "#Target# links closer to his ally!", true end,
   on_lose = function(self, err) return "#Target# no longer seems to be in sync with his ally.", true end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "resists", {all = eff.resist})
   end,
}


newEffect{
   name = "REK_MTYR_GUIDANCE_HEAL", image = "talents/rek_mtyr_whispers_guiding_light.png",
   desc = "Guided to Healing",
   long_desc = function(self, eff)
      local str = ("A light of life shines upon the target, regenerating %0.2f life per turn."):format(eff.power)
      if eff.aura > 0 then
         str = str..(" and damaging nearby enemies for %d mind damage."):format(eff.aura)
      end
      return str
   end,
   type = "physical",
   subtype = { healing=true, regeneration=true },
   status = "beneficial",
   parameters = { power=10, aura=0 },
   on_gain = function(self, err) return "#Target# is healing in the light.", "+Regen" end,
   on_lose = function(self, err) return "#Target# stops healing.", "-Regen" end,
   activate = function(self, eff)
      eff.tmpid = self:addTemporaryValue("life_regen", eff.power)   
      if core.shader.active(4) then
         eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, circleColor={0,0,0,0}, beamsCount=9}))
         eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, circleColor={0,0,0,0}, beamsCount=9}))
      end
   end,
   on_timeout = function(self, eff)
      if self:knowTalent(self.T_ANCESTRAL_LIFE) then
         local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
         self:incEquilibrium(-t.getEq(self, t))
      end
   end,
   deactivate = function(self, eff)
      self:removeParticles(eff.particle1)
      self:removeParticles(eff.particle2)
      self:removeTemporaryValue("life_regen", eff.tmpid)
   end,
         }

newEffect{
   name = "REK_MTYR_GUIDANCE_FLASH", image = "talents/rek_mtyr_whispers_guiding_light.png",
   desc = _t"Guided to Vision",
   long_desc = function(self, eff) return ("The target's ability to see stealthed and invisibled targets is improved by %d."):tformat(eff.power) end,
   type = "mental",
   subtype = { focus=true },
   status = "beneficial",
   parameters = { power=10 },
   on_gain = function(self, err) return _t"#Target# sees precisely." end,
   on_lose = function(self, err) return _t"#Target# sees less precisely." end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "see_invisible", eff.power)
      self:effectTemporaryValue(eff, "see_stealth", eff.power)
      self:effectTemporaryValue(eff, "see_traps", eff.power)
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
   name = "REK_MTYR_GUIDANCE_AVAILABLE", image = "talents/rek_mtyr_whispers_guiding_light.png",
   desc = "Seeking the Light",
   long_desc = function(self, eff) return ("Somewhere nearby is a beam of light this creature is looking for"):format() end,
   type = "other",
   subtype = { whisper=true },
   status = "beneficial",
   parameters = { ground_effect='' },
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
}