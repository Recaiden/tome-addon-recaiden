newTalent{
   name = "Apocalypse Eyes", short_name = "REK_MTYR_REVELATION_EYES",
   type = {"demented/revelation", 1},
   require = martyr_req_high1,
   points = 5,
   mode = "passive",
   getPower = function(self, t) return self:combatTalentScale(t, 5, 30) end,
   getVision = function(self, t) return self:combatTalentStatDamage(t, "wil", 10, 80) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "see_invisible", t.getVision(self, t))
      self:talentTemporaryValue(p, "see_stealth", t.getVision(self, t))
      self:talentTemporaryValue(p, "resists_actor_type", {horror=t.getPower(self, t)})
      self:talentTemporaryValue(p, "inc_damage_actor_type", {horror=t.getPower(self, t)})
   end,
   callbackOnDealDamage = function(self, t, dam, target)
      if target.rank >= 3 then return end
      if target.on_die then return end
      if target.type == "horror" then return end
      if self and self.reactionToward and self:reactionToward(target) > 0 then return end
      if not rng.percent(4) then return end
      if target.__light_revelation then return end
      target.__light_revelation = true
      
      game:onTickEnd(function()
			if self:attr("dead") then return end
			local horror = game.zone:makeEntity(game.level, "actor", {type="horror", subtype="eldritch", base_list="mod.class.NPC:/data/general/npcs/horror.lua"})
			if horror then
                           local oldname = target.name
                           local x, y = target.x, target.y
                           local life_pct = target.life / target.max_life
                           target:disappear(who)
                           target:replaceWith(horror)
                           game.zone:addEntity(game.level, target, "actor", x, y)
                           target.life = target.max_life * life_pct
                           game.bignews:say(120, "#YELLOW#You look upon %s and realize its true nature as %s!", oldname, target.name)
			end
                     end)
   end,
   info = function(self, t)
      return ([[You have trained yourself to look at the ruined world that others pretend not to notice. 
Your attention to detail increases stealth detection and invisibility detection by %d. The things you have learned give you %d%% resistance to and %d%% increased damage against the Horrors you see.

#ROYAL_BLUE#Sometimes reveals hidden truths that you'd rather not see.#LAST#
]]):format(t.getVision(self, t), t.getPower(self, t), t.getPower(self, t))
   end,
}

newTalent{
   name = "Abyssal Shot", short_name = "REK_MTYR_REVELATION_ABYSSAL_SHOT",
   type = {"demented/revelation", 2},
   require = martyr_req_high2,
   points = 5,
   cooldown = 20,
   insanity = 15,
   getDamage = function(self,t) return self:combatTalentWeaponDamage(t, 1.2, 1.6) end,
   getDuration = function(self,t) return self:combatTalentScale(t, 2, 4) end,
   range = archery_range,
   tactical = { ATTACK = { weapon = 1 } },
   requires_target = true,
   on_pre_use = function(self, t, silent) return martyrPreUse(self, t, silent, "sling") end,
   archery_onhit = function(self, t, target, x, y)
      options = {target.EFF_MTYR_ABYSSAL_LUMINOUS, target.EFF_MTYR_ABYSSAL_UMBRAL, target.EFF_MTYR_ABYSSAL_BLOATED, target.EFF_MTYR_ABYSSAL_WORMS}
      target:setEffect(options[rng.range(1, #options)], t.getDuration(self, t), {src=self})
   end,
   action = function(self, t)
      doMartyrWeaponSwap(self, "sling", true)
      local targets = self:archeryAcquireTargets(nil, {one_shot=true, add_speed=self.combat_physspeed})
      if not targets then return end
      self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})
      return true
   end,
   info = function(self, t)
      return ([[While in combat, zones of guiding light will appear nearby, lasting %d turns.
Entering a green light will cause you to regenerate for %d health per turn for 5 turns.
Entering a blue light will refresh you, reducing the duration of outstanding cooldowns by %d turns.
Entering a orange light will grant you vision sevenfold, allowing you to see stealthed and invisible targets with power %d. and fight while blinded.]]):format(3, t.getPower(self,t), math.ceil(t.getPower(self,t)/20), t.getPower(self,t)/2)
   end,
}


newTalent{
   name = "Writhing Speed", short_name = "REK_MTYR_REVELATION_SPEED",
   type = {"demented/revelation", 3},
   require = martyr_req_high3,
   points = 5,
   insanity = -5,
   cooldown = 20,
   getDuration = function(self) return 5 end,
   getAmmo = function(self) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   getSpeed = function(self) return self:combatTalentScale(t, 0.42, 0.84, 0.75) end,
   getAccuracy = function(self) return self:combatTalentScale(t, 40, 100, 0.75) end,

   activate = function(self, t)
      local c = 0
      while c < t.getAmmot(self, t) do
         local reloaded = self:reload()
         if not reloaded and self.reloadQS then
            self:reloadQS()
         end
         c = c + 1
      end
      self:setEffect(self.EFF_REK_MTYR_SEVENFOLD_SPEED, t.getDuration(self, t), {src=self, power=t.getSpeed(self, t), acc=t.getAccuracy(self, t)})

      game:playSoundNear(self, "talents/dispel")
      local ret = {}
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[Immediately reload %d times.  For the next %d turns, your ranged attack speed increases by %d%% and your accuracy by %d.

#{italic}#Harmonize with the world of horror all around you, letting the eyestalks guide your shots and the tentacles be your hands.#{normal}#
]]):format(t.getDuration(self, t), t.getSpeed(self, t)*100, t.getAccuracy(self, t))
   end,
}

newTalent{
   name = "Suborn", short_name = "REK_MTYR_REVELATION_SUBORN",
   type = {"demented/revelation", 4},
   require = martyr_req_high4,
   points = 5,
   no_energy = true,
   insanity = -35,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 47, 35)) end,
   getDuration = function(self) return math.floor(self:combatTalentScale(t, 5, 14)) end,
   range = 4,
   no_npc_use = true,
   requires_target = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTargetLimited(tg)
      if not x or not y then return nil end
      if not target or target.dead or target == self then return end
      if not target:attr("confused") then return end
      if game.party:hasMember(target) then return end
      if target.instakill_immune and target.instakill_immune >= 1 then
         game.logSeen(target, "%s is immune to instakill and mind control effects!", target.name:capitalize())
         return
      end
      if target.rank > 3 and ((target.life / target.max_life) >= 0.8) then
         game.logSeen(target, "%s must be below 80%% of their max life to be controlled!", target.name:capitalize())
         return
      end
      self:project(tg, x, y, function(px, py)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target:canBe("instakill") then
                         target:takeHit(1, self)
                         target:takeHit(1, self)
                         target:takeHit(1, self)
                         if target.rank > 3 then
                            target:setEffect(target.EFF_DOMINANT_WILL_BOSS, 3, {src=self})
                         else
                            target:setEffect(target.EFF_DOMINANT_WILL, t.getDuration(self), {src=self})
                         end
                      else
                         game.logSeen(target, "%s resists the mental assault!", target.name:capitalize())
                      end
                      
                             end)
      return true
   end,
   info = function(self, t)
      return ([[#{italic}#Don't you remember?  #GREEN#We#LAST#'ve already absorbed that one.#{normal}# 
Remind a Confused target that it is under your full control. 
Rare and stronger targets must be below 80%% of their maximum life to be controlled, will be invulnerable for the duration, and will break free of the effect without dying after 3 turns.
Other creatures can be controlled for %d turns and will die from the strain afterward.
This effect checks instakill immunity.]]):format(t.getDuration(self))
   end,
}