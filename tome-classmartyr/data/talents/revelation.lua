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
   insanity = -22,
   getDamage = function(self,t) return self:combatTalentWeaponDamage(t, 1.2, 1.6) end,
   getDuration = function(self,t) return self:combatTalentScale(t, 3, 5) end,
   range = archery_range,
   tactical = { ATTACK = { weapon = 1 } },
   requires_target = true,
   speed = "archery",
   on_pre_use = function(self, t, silent) return martyrPreUse(self, t, silent, "sling") end,
   archery_onhit = function(self, t, target, x, y)
      if target.type == "horror" then return end
      local options = {target.EFF_REK_MTYR_ABYSSAL_LUMINOUS, target.EFF_REK_MTYR_ABYSSAL_UMBRAL, target.EFF_REK_MTYR_ABYSSAL_BLOATED, target.EFF_REK_MTYR_ABYSSAL_PARASITIC}
      if target:attr("hates_arcane") then
         options = {target.EFF_MTYR_ABYSSAL_UMBRAL, target.EFF_MTYR_ABYSSAL_PARASITIC}
      end
      local choice = rng.range(1, #options)
      local horror_type = target.mtyr_horror_type or options[choice]

      target.mtyr_horror_type = horror_type
      target:setEffect(horror_type, t.getDuration(self, t), {src=self})
   end,
   action = function(self, t)
      doMartyrWeaponSwap(self, "sling", true)
      local targets = self:archeryAcquireTargets(nil, {one_shot=true})
      if not targets then return end
      self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})

      return true
   end,
   info = function(self, t)
      return ([[Fire a shot into the mindscape to shatter the worldly guise of the target, dealing %d%% damage and revealing its true nature as a horror!
The horror will resume its disguise after %d turns.]]):format(t.getDamage(self,t) * 100, t.getDuration(self, t))
   end,
}

newTalent{
   name = "Writhing Speed", short_name = "REK_MTYR_REVELATION_SPEED",
   type = {"demented/revelation", 3},
   require = martyr_req_high3,
   points = 5,
   insanity = -20,
   cooldown = 20,
   getDuration = function(self, t) return 5 end,
   getAmmo = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   getSpeed = function(self, t) return self:combatTalentScale(t, 0.42, 0.84, 0.75) end,
   getAccuracy = function(self, t) return self:combatTalentScale(t, 40, 100, 0.75) end,
   action = function(self, t)
      local c = 0
      while c < t.getAmmo(self, t) do
         local reloaded = self:reload()
         if not reloaded and self.reloadQS then
            self:reloadQS()
         end
         c = c + 1
      end
      self:setEffect(self.EFF_REK_MTYR_SEVENFOLD_SPEED, t.getDuration(self, t), {src=self, power=t.getSpeed(self, t), acc=t.getAccuracy(self, t)})

      game:playSoundNear(self, "talents/dispel")
      return true
   end,
   info = function(self, t)
      return ([[Immediately reload %d times.  For the next %d turns, your ranged attack speed increases by %d%% and your accuracy by %d.

#{italic}#Harmonize with the world of horror all around you, letting the eyestalks guide your shots and the tentacles be your hands.#{normal}#
]]):format(t.getAmmo(self, t), t.getDuration(self, t), t.getSpeed(self, t)*100, t.getAccuracy(self, t))
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
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 14)) end,
   range = 4,
   no_npc_use = true,
   requires_target = true,
   speed = "archery",
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTargetLimited(tg)
      if not x or not y then return nil end
      if not target or target.dead or target == self then return end
      if not target:attr("confused") then
         game.logSeen(target, "%s must be confused to be controlled!", target.name:capitalize())
         return
      end
      if game.party:hasMember(target) then
         game.logSeen(target, "%s is already part of your party!", target.name:capitalize())
         return
      end
      if target.instakill_immune and target.instakill_immune >= 1 then
         game.logSeen(target, "%s is immune to mind control!", target.name:capitalize())
         return
      end
      self:project(tg, x, y, function(px, py)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target:canBe("instakill") then
                         if target.rank > 3 then
                            target:setEffect(target.EFF_DOMINANT_WILL_BOSS, 2+self:getTalentLevelRaw(t), {src=self})
                         else
                            target:setEffect(target.EFF_DOMINANT_WILL, t.getDuration(self, t), {src=self})
                         end
                      else
                         game.logSeen(target, "%s resists the mental assault!", target.name:capitalize())
                      end
                      
                             end)
      return true
   end,
   info = function(self, t)
      return ([[Take control of a Confused target, bringing it onto your side.
Rare and stronger targets will be invulnerable for the duration, and will break free of the effect after %d turns.
Weaker targets can be controlled for %d turns and will die from the strain afterward.

This effect checks instakill immunity.

#{italic}#Don't you remember?  #GREEN#We#LAST#'ve already absorbed that one.#{normal}# ]]):format(2+self:getTalentLevelRaw(t), t.getDuration(self, t))
   end,
}