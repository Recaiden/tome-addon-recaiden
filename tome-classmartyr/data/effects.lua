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
   charges = function(self, eff) return eff.stacks end,
   subtype = { demented=true },
   status = "detrimental",
   parameters = { power=10 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "numbed", eff.power)
      -- cooldown increase is in Actor.Lua
   end,
   deactivate = function(self, eff)
   end,
}