newTalent{
   name = "Slipping Psyche", short_name = "REK_MTYR_WHISPERS_SLIPPING_PSYCHE",
   type = {"demented/whispers", 1},
   require = martyr_req1,
   points = 5,
   mode = "passive",
   getPower = function(self, t)
      return self:combatTalentScale(t, 3, 20)
         * (self:getInsanity() / 100)
         * self:combatScale(self.level, 1, 1, 2, 50)
   end,
   getMaxPower = function(self, t)
      return self:combatTalentScale(t, 3, 20)
         * self:combatScale(self.level, 1, 1, 2, 50)
   end,
   getReduction = function(self, t)
      return self:combatTalentScale(t, 2, 20)
         * ((self:getMaxInsanity() - self:getInsanity()) / 100)
         * self:combatScale(self.level, 1, 1, 2, 50)
   end,
   getMaxReduction = function(self, t)
      return self:combatTalentScale(t, 2, 20)
         * self:combatScale(self.level, 1, 1, 2, 50)
   end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "flat_damage_armor", {all=t.getReduction(self, t)})
      --self:talentTemporaryValue(p, "combat_dam", t.getPower(self, t))
   end,
   callbackOnAct = function (self, t)
      self:updateTalentPassives(t.id)
   end,
   callbackOnTalentPost = function(self, t, ab, ret, silent)
      self:updateTalentPassives(t.id)
   end,
   -- odd terrain
   callbackOnChangeLevel = function(self, t, action, zone, level)
      if action ~= "enter" then return end
      if not game.level or not game.level.data then return end
      if game.level and game.level.data and game.level.data.rek_mtyr_tentacles_placed then
         return nil
      end
      game.level.data.rek_mtyr_tentacles_placed = true
      local chance = (game.calendar.rek_mtyr_infestation_progress or 0) + 1
      game.calendar.rek_mtyr_infestation_progress = (game.calendar.rek_mtyr_infestation_progress or 0) + 2 
   end,
   doRevealTentacles = function(self, t)
      local chance = game.calendar.rek_mtyr_infestation_progress or 20
      local tg = {type="ball", range=0, selffire=false, radius=20, talent=t, no_restrict=true}
      self:project(
         tg, self.x, self.y,
         function(px, py, tg, self)
            if not rng.percent(chance) then return end
            local oe = game.level.map(px, py, Map.TERRAIN)
            if oe and not oe:attr("temporary") and not oe.special
               and game.level.map:checkAllEntities(px, py, "block_move")
            then
               if oe.rek_swap_mos then
                  local temp = oe.add_mos
                  oe.add_mos = oe.rek_swap_mos
                  oe.rek_swap_mos = temp
               else
                  oe.rek_swap_mod = oe.add_mos
                  oe.add_mos = {{image="terrain/stair_down.png"}}
               end
               game.nicer_tiles:updateAround(game.level, self.x, self.y)
               --game.level.map(px, py, Map.TERRAIN, e)
            end
         end)
      game.level.map:scheduleRedisplay()
   end,
   info = function(self, t)
      return ([[Gain melee damage as you gain insanity, up to %d (currently %d).
Reduce incoming damage by a flat amount as you approach sanity, up to %d per hit (currently %d).
Both values will improve with your level.

You benefit from #ORANGE#Sanity Bonus#LAST# while you have up to 40 Insanity.
You benefit from #GREEN#Our Gift#LAST# while you have at least 60 Insanity.

#{italic}#As long as I don't start thinking like #GREEN#us#LAST#, I'll be safe.#{normal}#
]]):format(t.getMaxPower(self, t), t.getPower(self, t), t.getMaxReduction(self, t), t.getReduction(self, t))
   end,
         }

--local hd = {"Combat:attackTargetWith:attackerBonuses", target=target, weapon=weapon, damtype=damtype, mult=mult, dam=dam, apr=apr, atk=atk, def=def, armor=armor}
	
class:bindHook(
   "Combat:attackTargetWith:attackerBonuses",
   function(self, hd)
      if not self:knowTalent(self.T_REK_MTYR_WHISPERS_SLIPPING_PSYCHE) then return hd end
      hd.dam = hd.dam + self:callTalent(self.T_REK_MTYR_WHISPERS_SLIPPING_PSYCHE, "getPower")
      return hd
end)


newTalent{
   name = "Guiding Light", short_name = "REK_MTYR_WHISPERS_GUIDING_LIGHT",
   type = {"demented/whispers", 2},
   require = martyr_req2,
   points = 5,
   mode = "passive",
   getPower = function(self,t) return self:combatTalentScale(t, 20, 120) end,
   getChance = function(self, t) return 20 end,
   getDuration = function(self, t) return 4 end,
   callbackOnActBase = function (self, t)
      if not self.in_combat then return end
      if not rng.percent(t.getChance(self, t)) then return end
      local _, _, gs = util.findFreeGrid(self.x, self.y, rng.range(1, 10), true, {})
      if gs and #gs > 0 then
         local dur = t.getDuration(self, t)
         
         local DamageType = require "engine.DamageType"
         local MapEffect = require "engine.MapEffect"
         local x, y = gs[#gs][1], gs[#gs][2]
         local options = {
            {
               dam=DamageType.REK_MTYR_GUIDE_HEAL,
               r=60, g=255, b=60
            },
            {
               dam=DamageType.REK_MTYR_GUIDE_BUFF,
               r=20, g=100, b=255
            },
            {
               dam=DamageType.REK_MTYR_GUIDE_FLASH,
               r=255, g=210, b=60
            }
         }
         local type = options[rng.range(1, #options)]
         local ground_effect = game.level.map:
         addEffect(game.player, x, y, dur, type.dam, t.getPower(self, t), rng.range(1, 2), 5, nil, MapEffect.new{color_br=type.r, color_bg=type.g, color_bb=type.b, alpha=100, effect_shader="shader_images/sun_effect.png"}, nil, true)
         game.logSeen(self, "#YELLOW#A guiding light appears!#LAST#", self.name:capitalize())
      end
   end,
   info = function(self, t)
      return ([[While in combat, zones of guiding light will appear nearby, lasting %d turns.
Entering a green light will cause you to regenerate for %d health per turn for 5 turns.
Entering a blue light will refresh you, reducing the duration of outstanding cooldowns by %d turns.
Entering a orange light will grant you terrible strength, giving you +%d%% to all damage for 3 turns.]]):format(t.getDuration(self, t), t.getPower(self,t), math.max(1, math.floor(t.getPower(self,t)/25)), t.getPower(self,t)/4)
   end,
}

newTalent{
   name = "Warning Lights", short_name = "REK_MTYR_WHISPERS_WARNING",
   type = {"demented/whispers", 3},
   require = martyr_req3,
   points = 5,
   mode = "passive",
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 15, 60) end,
   getDuration = function(self, t) return 5 end,
   radius = 2,
   info = function(self, t)
      return ([[Entering any light will imbue you with a destructive aura, dealing %d - %d mind damage to enemies within range 2 each turn for %d turns.  The damage will increase with your current insanity.
Mindpower: increases damage.

#{italic}#The light whispers secrets to bring about the destruction of your enemies.#{normal}#]]):format(damDesc(self, DamageType.MIND, t.getDamage(self, t)), 2*damDesc(self, DamageType.MIND, t.getDamage(self, t)), t.getDuration(self, t))
   end,
}

newTalent{
   name = "Jolt Awake", short_name = "REK_MTYR_WHISPERS_JOLT",
   type = {"demented/whispers", 4},
   require = martyr_req4,
   points = 5,
   mode = "sustained",
   cooldown = function(self, t) return math.max(25, self:combatTalentScale(t, 60, 35)) end,
   callbackOnHit = function(self, eff, cb, src)
      if cb.value >= (self.life - self.die_at) then
         cb.value = 0

         self:forceUseTalent(self.T_REK_MTYR_WHISPERS_JOLT, {ignore_energy=true})
         game:playSoundNear(self, "talents/rek_false_death")
         game.logSeen(self, "#YELLOW#%s awakens from a terrible dream!#LAST#", self.name:capitalize())
         if self == game.player then game.bignews:say(80, "#GREEN#"..string.format("You die in the dream!")) end

         self:incInsanity(-1 * self:getInsanity())
         self:setEffect(self.EFF_REK_MTYR_JOLT_SHIELD, 1, {src=self})
      end
      return cb.value
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/dispel")
      local ret = {}
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[If you suffer damage that would kill you, you instead awake from a dream of dying, setting your insanity to zero and becoming immune to damage for the rest of the turn.
]]):format()
   end,
}