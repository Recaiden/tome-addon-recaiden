newTalent{
   short_name = "FLN_SHADOW_FADE",
   name = "Fade",
   type = {"spell/other",1},
   points = 5,
   cooldown = function(self, t)
      return math.max(3, 8 - self:getTalentLevelRaw(t))
   end,
   action = function(self, t)
      self:setEffect(self.EFF_FLN_SHADOW_FADE_SHIELD, 1, {})
      return true
   end,
   info = function(self, t)
      return ([[You form a radiant shield, making you invulnerable until the beginning of your next turn.]])
end,
         }

newTalent{
   name = "Healing Light", short_name = "FLN_SHADOW_HEAL",
   type = {"celestial/other", 1},
   require = spells_req1,
   points = 5,
   cooldown = 10,
   tactical = { HEAL = 2},
   getHeal = function(self, t) return 40+self:combatTalentSpellDamage(t, 10, 520) end,
   is_heal = true,
   action = function(self, t)
      self:attr("allow_on_heal", 1)
      self:heal(self:spellCrit(t.getHeal(self, t)), self)
      self:attr("allow_on_heal", -1)
      if core.shader.active(4) then
         self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true, size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
         self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
      end
      game:playSoundNear(self, "talents/heal")
      return true
   end,
   info = function(self, t)
      local heal = t.getHeal(self, t)
      return ([[An invigorating ray of Sunlight shines upon you, healing your body for %d life.
		The amount healed will increase with your Spellpower.]]):
      format(heal)
   end,
}

newTalent{
   name = "Absorption", short_name = "FLN_SHADOW_ABSORPTION_STRIKE",
   type = {"celestial/other", 1},
   points = 5,
   cooldown = 8,
   tactical = { ATTACK = 2, DISABLE = 1 },
   range = 1,
   requires_target = true,
   getWeakness = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 2.3) end,
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t)}
      local x, y, target = self:getTarget(tg)
      if not x or not y or not target then return nil end
      if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
      local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
      if hit then
         self:project({type="ball", radius=1, friendlyfire=false, selffire=false}, self.x, self.y,
                      function(px, py)
                         local a = game.level.map(px, py, Map.ACTOR)
                         if a then
                            a:setEffect(a.EFF_FLN_ABSORPTION_STRIKE, 5, {power=t.getWeakness(self, t)})
                         end
                      end)
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You strike your foe, dealing %d%% weapon damage.
		If the attack hits, all foes in radius 1 will have their light resistance reduced by %d%% and grant 1 hate when hit for 5 turns.]]):
      format(100 * damage, t.getWeakness(self, t))
   end,
         }

newTalent{
   short_name = "FLN_SHADOW_PHASE_DOOR",
   name = "Phase Door",
   type = {"spell/other",1},
   points = 5,
   range = 10,
   tactical = { ESCAPE = 2 },
   is_teleport = true,
   action = function(self, t)
      local x, y, range
      if self.ai_state.shadow_wall then
         x, y, range = self.ai_state.shadow_wall_target.x, self.ai_state.shadow_wall_target.y, 1
      elseif self.ai_target.x and self.ai_target.y then
         x, y, range = self.ai_target.x, self.ai_target.y, 1
      else
         x, y, range = self.summoner.x, self.summoner.y, self.ai_state.location_range
      end
      
      game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
      self:teleportRandom(x, y, range)
      game.level.map:particleEmitter(x, y, 1, "teleport_in")
      return true
   end,
   info = function(self, t)
      return ([[Teleports you within range 10.]])
   end,
         }

newTalent{
   short_name = "FLN_SHADOW_BLINDSIDE",
   name = "Blindside",
   type = {"spell/other", 1},
   points = 5,
   random_ego = "attack",
   range = 10,
   requires_target = true,
   tactical = { CLOSEIN = 2 },
   is_melee = true,
   target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      local start = rng.range(0, 8)
      for i = start, start + 8 do
         local x = target.x + (i % 3) - 1
         local y = target.y + math.floor((i % 9) / 3) - 1
         if game.level.map:isBound(x, y)
            and self:canMove(x, y)
            and not game.level.map.attrs(x, y, "no_teleport") then
         game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
         self:move(x, y, true)
         game.level.map:particleEmitter(x, y, 1, "teleport_in")
         local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
         self:attackTarget(target, nil, multiplier, true)
         return true
         end
      end
      
      return false
   end,info = function(self, t)
      local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
      return ([[With blinding speed you suddenly appear next to a target up to %d spaces away and attack for %d%% damage.]]):format(self:getTalentRange(t), multiplier * 100)
   end,
         }

newTalent{
   short_name = "FLN_SHADOW_LIGHTNING",
   name = "Shadow of Moonlight",
   type = {"celestial/other", 1},
   require = { },
   points = 5,
   tactical = { ATTACK = {DARKNESS = 2} },
   range = 1,
   direct_hit = true,
   requires_target = true,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 130) end,
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
      local _ _, x, y = self:canProject(tg, x, y)
      game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/flame")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Focuses the power of the Moon into a blast of shadows, doing %0.2f damage.
		The damage dealt will increase with your Spellpower.]]):
      format(damDesc(self, DamageType.DARKNESS, damage))
   end,
}

newTalent{
   short_name = "FLN_SHADOW_FLAMES",
   name = "Shadow of Sunlight",
   type = {"celestial/other", 1},
   require = { },
   points = 5,
   range = 6,
   direct_hit = true,
   requires_target = true,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 85) end,   
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local x, y, target = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, x, y = self:canProject(tg, x, y)
      
      local dam = self:spellCrit(t.getDamage(self, t))
      if target then
         target:setEffect(target.EFF_FLN_LIGHT_VICTIM, 3, {power=dam, shadow=self, fallen=self.summoner})
      end
            return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Calls the power of the Sun into a searing lance, doing %d damage to the target and leaving a radius 1 area of searing light on the ground for 4 turns that does %d light damage to all foes within it.
		The damage dealt will increase with your Spellpower.]]):
      format(damDesc(self, DamageType.LIGHT, damage), damDesc(self, DamageType.LIGHT, damage/2))
   end,
}

newTalent{
   short_name = "FLN_SHADOW_REFORM",
   name = "Reform",
   type = {"spell/other", 1},
   require = { },
   points = 5,
   getChance = function(self, t) return 50 end,
   info = function(self, t)
      local chance = t.getChance(self, t)
      return ([[When a shadow is hit and killed, there is a %d%% chance it will reform unhurt.]]):format(chance)
   end,
}

local function createShadow(self, level, tCallShadows, tShadowWarriors, tShadowMages, duration, target)
   local npc = require("mod.class.NPC").new{
      type = "undead", subtype = "shadow",
      name = "shadow",
      desc = [[]],
      display = 'b', color=colors.BLACK,
      
      never_anger = true,
      summoner = self,
      summoner_gain_exp=true,
      summon_time = duration,
      faction = self.faction,
      size_category = 2,
      rank = 2,
      autolevel = "none",
      level_range = {level, level},
      exp_worth=0,
      hate_regen = 1,
      avoid_traps = 1,
      is_doomed_shadow = true,
      
      max_life = resolvers.rngavg(3,12), life_rating = 5,
      stats = { -- affected by stat limits
         str=math.floor(self:combatScale(level, 5, 0, 55, 50, 0.75)),
         dex=math.floor(self:combatScale(level, 10, 0, 85, 50, 0.75)),
         mag=math.floor(self:combatScale(level, 10, 0, 85, 50, 0.75)),
         wil=math.floor(self:combatScale(level, 5, 0, 55, 50, 0.75)),
         cun=math.floor(self:combatScale(level, 5, 0, 40, 50, 0.75)),
         con=math.floor(self:combatScale(level, 5, 0, 40, 50, 0.75)),
      },
      combat_armor = 0, combat_def = 3,
      combat = {
         dam=math.floor(self:combatScale(level, 1.5, 1, 75, 50, 0.75)),
         atk=10 + level,
         apr=8,
         dammod={str=0.5, dex=0.5}
      },
      mana = 100,
      combat_spellpower = tShadowMages and tShadowMages.getSpellpowerChange(self, tShadowMages) or 0,
      summoner_hate_per_kill = self.hate_per_kill,
      resolvers.talents{
         [self.T_FLN_SHADOW_PHASE_DOOR]=tCallShadows.getPhaseDoorLevel(self, tCallShadows),
         [self.T_FLN_SHADOW_BLINDSIDE]=tCallShadows.getBlindsideLevel(self, tCallShadows),
         [self.T_FLN_SHADOW_HEAL]=tCallShadows.getHealLevel(self, tCallShadows),
         [self.T_FLN_SHADOW_ABSORPTION_STRIKE]=tShadowWarriors and tShadowWarriors.getAbsorbLevel(self, tShadowWarriors) or 0,
         [self.T_FLN_SHADOW_FADE]=tShadowWarriors and tShadowWarriors.getFadeLevel(self, tShadowWarriors) or 0,
         [self.T_FLN_SHADOW_LIGHTNING]=tShadowMages and tShadowMages.getLightningLevel(self, tShadowMages) or 0,
         [self.T_FLN_SHADOW_FLAMES]=tShadowMages and tShadowMages.getFlamesLevel(self, tShadowMages) or 0,
         [self.T_FLN_SHADOW_REFORM]=tShadowMages and tShadowMages.getReformLevel(self, tShadowMages) or 0,
                       },

      undead = 1,
      no_breath = 1,
      stone_immune = 1,
      confusion_immune = 1,
      fear_immune = 1,
      teleport_immune = 1,
      disease_immune = 1,
      poison_immune = 1,
      stun_immune = 1,
      blind_immune = 1,
      see_invisible = 80,
      resists = { [DamageType.LIGHT] = -100, [DamageType.DARKNESS] = 100 },
      resists_pen = { all=25 },

      avoid_master_damage = (100 - tCallShadows.getAvoidMasterDamage(self, tCallShadows)) / 100,

      ai = "shadow",
      ai_state = {
         summoner_range = 10,
         actor_range = 8,
         location_range = 4,
         target_time = 0,
         target_timeout = 10,
         focus_on_target = false,
         shadow_wall = false,
         shadow_wall_time = 0,

         blindside_chance = 15,
         phasedoor_chance = 5,
         close_attack_spell_chance = 0,
         far_attack_spell_chance = 0,
         can_reform = false,
         dominate_chance = 0,

         feed_level = 0
      },
      ai_target = {
         actor=target,
         x = nil,
         y = nil
      },

      healSelf = function(self)
         self:useTalent(self.T_FLN_SHADOW_HEAL)
      end,
      closeAttackSpell = function(self)
         return self:useTalent(self.T_FLN_SHADOW_LIGHTNING)
      end,
      farAttackSpell = function(self)
         if self:knowTalent(self.T_EMPATHIC_HEX) and not self:isTalentCoolingDown(self.T_EMPATHIC_HEX) and rng.percent(50) then
            return self:useTalent(self.T_EMPATHIC_HEX)
         else
            return self:useTalent(self.T_FLN_SHADOW_FLAMES)
         end
      end,
      dominate = function(self)
         return self:useTalent(self.T_FLN_SHADOW_ABSORPTION_STRIKE)
      end,
      feed = function(self)
         if self.summoner:knowTalent(self.summoner.T_FLN_SHADOW_MAGES) then
            local tShadowMages = self.summoner:getTalentFromId(self.summoner.T_FLN_SHADOW_MAGES)
            self.ai_state.close_attack_spell_chance = tShadowMages.getCloseAttackSpellChance(self.summoner, tShadowMages)
            self.ai_state.far_attack_spell_chance = tShadowMages.getFarAttackSpellChance(self.summoner, tShadowMages)
            self.ai_state.can_reform = self.summoner:getTalentLevel(tShadowMages) >= 5
         else
            self.ai_state.close_attack_spell_chance = 0
            self.ai_state.far_attack_spell_chance = 0
            self.ai_state.can_reform = false
         end

         if self.ai_state.feed_temp1 then self:removeTemporaryValue("combat_atk", self.ai_state.feed_temp1) end
         self.ai_state.feed_temp1 = nil
         if self.ai_state.feed_temp2 then self:removeTemporaryValue("inc_damage", self.ai_state.feed_temp2) end
         self.ai_state.feed_temp2 = nil
         if self.summoner:knowTalent(self.summoner.T_FLN_SHADOW_WARRIORS) then
            local tShadowWarriors = self.summoner:getTalentFromId(self.summoner.T_FLN_SHADOW_WARRIORS)
            self.ai_state.feed_temp1 = self:addTemporaryValue("combat_atk", tShadowWarriors.getCombatAtk(self.summoner, tShadowWarriors))
            self.ai_state.feed_temp2 = self:addTemporaryValue("inc_damage", {all=tShadowWarriors.getIncDamage(self.summoner, tShadowWarriors)})
            self.ai_state.dominate_chance = tShadowWarriors.getAbsorbChance(self.summoner, tShadowWarriors)
         else
            self.ai_state.dominate_chance = 0
         end
      end,
      onTakeHit = function(self, value, src)
         if src == self.summoner and self.avoid_master_damage then
            value = value * self.avoid_master_damage
         end

         if self:knowTalent(self.T_FLN_SHADOW_FADE) and not self:isTalentCoolingDown(self.T_FLN_SHADOW_FADE) and not (self.avoid_master_damage == 0) then
            self:forceUseTalent(self.T_FLN_SHADOW_FADE, {ignore_energy=true})
         end

         return mod.class.Actor.onTakeHit(self, value, src)
      end,
      on_act = function(self)
         -- clean up
         if self.summoner.dead then
            self:die(self)
         end
      end
                                           }
   self:attr("summoned_times", 1)
   return npc
end

newTalent{
   name = "Lomea Call", short_name="FLN_CALL_SHADOWS",
   type = {"cursed/solar-shadows", 1},
   mode = "sustained",
   no_energy = true,
   require = cursed_wil_req1,
   points = 5,
   cooldown = 10,
   hate = 0,
   unlearn_on_clone = true,
   tactical = { BUFF = 5 },
   getLevel = function(self, t) return self.level end,
   getMaxShadows = function(self, t)
      return math.min(4, math.max(1, math.floor(self:getTalentLevel(t) * 0.55)))
   end,
   getAvoidMasterDamage = function(self, t)
      return util.bound(self:combatTalentScale(t, 5, 85), 0, 100)
   end,
   getPhaseDoorLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   getBlindsideLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   getHealLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   activate = function(self, t)
      local ret = {}
      if core.shader.active() then
         self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1, img="call_shadows"}, shader={type="rotatingshield", noup=2.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
         self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1, img="call_shadows"}, shader={type="rotatingshield", noup=1.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
      end
      return ret
   end,
   deactivate = function(self, t, p)
      -- unsummon the shadows
      for _, e in pairs(game.level.entities) do
         if e.summoner and e.summoner == self and e.subtype == "shadow" then
            e.summon_time = 0
         end
      end

      return true
   end,
   nbShadowsUp = function(self, t)
      if not game.level then return 0 end
      local shadowCount = 0
      for _, e in pairs(game.level.entities) do
         if e.summoner and e.summoner == self and e.subtype == "shadow" then shadowCount = shadowCount + 1 end
      end
      return shadowCount
   end,
   summonShadow = function(self, t)
      local shadowCount = 0
      for _, e in pairs(game.level.entities) do
         if e.summoner and e.summoner == self and e.subtype == "shadow" then shadowCount = shadowCount + 1 end
      end

      if shadowCount >= t.getMaxShadows(self, t) then
         return false
      end
      
      -- Find space
      local x, y = util.findFreeGrid(self.x, self.y, 8, true, {[Map.ACTOR]=true})
      if not x then
         return false
      end

      -- use hate
      if self:getHate() < 5 then
         -- not enough hate..just wait for another try
         game.logPlayer(self, "Your hate is too low to call another shadow!", deflectDamage)
         return false
      end
      self:incHate(-5)

      local level = t.getLevel(self, t)
      local tShadowWarriors = self:knowTalent(self.T_FLN_SHADOW_WARRIORS) and self:getTalentFromId(self.T_FLN_SHADOW_WARRIORS) or nil
      local tShadowMages = self:knowTalent(self.T_FLN_SHADOW_MAGES) and self:getTalentFromId(self.T_FLN_SHADOW_MAGES) or nil

      local shadow = createShadow(self, level, t, tShadowWarriors, tShadowMages, 1000, nil)

      shadow:resolve()
      shadow:resolve(nil, true)
      shadow:forceLevelup(level)
      game.zone:addEntity(game.level, shadow, "actor", x, y)
      shadow:feed()
      game.level.map:particleEmitter(x, y, 1, "teleport_in")

      -- Reduce power of shadows for low level rares
      if self.inc_damage and self.inc_damage.all and self.inc_damage.all < 0 then
         shadow.inc_damage.all = (shadow.inc_damage.all or 0) + self.inc_damage.all
      end

      shadow.no_party_ai = true
      shadow.unused_stats = 0
      shadow.unused_talents = 0
      shadow.unused_generics = 0
      shadow.unused_talents_types = 0
      shadow.no_points_on_levelup = true
      if game.party:hasMember(self) then
         shadow.remove_from_party_on_death = true
         game.party:addMember(shadow, { control="no", type="summon", title="Summon"})
      end

      game:playSoundNear(self, "talents/spell_generic")
   end,
   callbackOnActBase = function(self, t)
      if not self.shadows then
         self.shadows = {
            remainingCooldown = 0
         }
      end

      if game.zone.wilderness then return false end

      self.shadows.remainingCooldown = self.shadows.remainingCooldown - 1
      if self.shadows.remainingCooldown > 0 then return false end
      self.shadows.remainingCooldown = 10

      t.summonShadow(self, t)
      return true
   end,
   info = function(self, t)
      local maxShadows = t.getMaxShadows(self, t)
      local healLevel = t.getHealLevel(self, t)
      local blindsideLevel = t.getBlindsideLevel(self, t)
      local avoid_master_damage = t.getAvoidMasterDamage(self, t)
      return ([[While this ability is active, you will continually call up to %d shadows to aid you in battle. Each shadow costs 5 hate to summon and has a level equal to your own. Shadows are weak combatants that can: Use Healing Light to heal themselves (level %d), Blindside their opponents (level %d), and Phase Door from place to place.
		Shadows ignore %d%% of the damage dealt to them by their master.

#{italic}#'Lomea', an elvish term for shadows, refers to something worse than the simple interruption of light.#{normal}#]]):format(maxShadows, healLevel, blindsideLevel, avoid_master_damage)
   end,
         }

newTalent{
   name = "Lomea Paladins", short_name="FLN_SHADOW_WARRIORS",
   type = {"cursed/solar-shadows", 2},
   mode = "passive",
   require = cursed_wil_req2,
   points = 5,
   getIncDamage = function(self, t)
      return math.floor((math.sqrt(self:getTalentLevel(t)) - 0.5) * 35)
   end,
   getCombatAtk = function(self, t)
      return math.floor((math.sqrt(self:getTalentLevel(t)) - 0.5) * 23)
   end,
   getAbsorbLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   getFadeLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   getAbsorbChance = function(self, t)
      if self:getTalentLevelRaw(t) > 0 then
         return self:combatLimit(self:getTalentLevel(t)^.5, 100, 7, 1, 15.65, 2.23) -- Limit < 100%
      else
         return 0
      end
   end,
   on_learn = function(self, t)
      if game and game.level and game.level.entities then
         for _, e in pairs(game.level.entities) do
            if e.summoner and e.summoner == self and e.subtype == "shadow" then
               e:feed(t)
            end
         end
      end

      return { }
   end,
   on_unlearn = function(self, t, p)
      if game and game.level and game.level.entities then
         for _, e in pairs(game.level.entities) do
            if e.summoner and e.summoner == self and e.subtype == "shadow" then
               e:feed(t)
            end
         end
      end

      return true
   end,
   info = function(self, t)
      local combatAtk = t.getCombatAtk(self, t)
      local incDamage = t.getIncDamage(self, t)
      local absorbChance = t.getAbsorbChance(self, t)
      local absorbLevel = t.getAbsorbLevel(self, t)
      local fadeCooldown = math.max(3, 8 - self:getTalentLevelRaw(t))
      return ([[Instill hate in your shadows, strengthening their attacks. They gain %d%% extra Accuracy and %d%% extra damage.
The fury of their attacks gives them the ability to try to Absorb the defenses of their foes, increasing light damage taken and giving you  a small amount of hate when you strike them (level %d, %d%% chance at range 1).
They also gain the ability to Fade when hit, avoiding all damage until their next turn (%d turn cooldown).

#{italic}#Remember how you used to fight side by side?#{normal}#]]):format(combatAtk, incDamage, absorbLevel, absorbChance, fadeCooldown)
end,
}

newTalent{
   name = "Lomea Anorithils", short_name="FLN_SHADOW_MAGES",
   type = {"cursed/solar-shadows", 3},
   mode = "passive",
   require = cursed_wil_req3,
   points = 5,
   getCloseAttackSpellChance = function(self, t)
      if math.floor(self:getTalentLevel(t)) > 0 then
         return self:combatLimit(self:getTalentLevel(t)^.5, 100, 7, 1, 15.65, 2.23) -- Limit < 100%
      else
         return 0
      end
   end,
   getFarAttackSpellChance = function(self, t)
      if math.floor(self:getTalentLevel(t)) >= 3 then
         return self:combatLimit(self:getTalentLevel(t)^.5, 100, 7, 1, 15.65, 2.23) -- Limit < 100%
      else
         return 0
      end
   end,
   getLightningLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   getFlamesLevel = function(self, t)
      if self:getTalentLevel(t) >= 3 then
         return self:getTalentLevelRaw(t)
      else
         return 0
      end
   end,
   getReformLevel = function(self, t)
      if self:getTalentLevel(t) >= 5 then
         return self:getTalentLevelRaw(t)
      else
         return 0
      end
   end,
   canReform = function(self, t)
      return t.getReformLevel(self, t) > 0
   end,
   getSpellpowerChange = function(self, t) return math.floor(self:combatTalentScale(t, 3, 15, 0.75)) end,
   on_learn = function(self, t)
      if game and game.level and game.level.entities then
         for _, e in pairs(game.level.entities) do
            if e.summoner and e.summoner == self and e.subtype == "shadow" then
               e:feed(t)
            end
         end
      end

      return { }
   end,
   on_unlearn = function(self, t, p)
      if game and game.level and game.level.entities then
         for _, e in pairs(game.level.entities) do
            if e.summoner and e.summoner == self and e.subtype == "shadow" then
               e:feed(t)
            end
         end
      end

      return true
   end,
   info = function(self, t)
      local closeAttackSpellChance = t.getCloseAttackSpellChance(self, t)
      local farAttackSpellChance = t.getFarAttackSpellChance(self, t)
      local spellpowerChange = t.getSpellpowerChange(self, t)
      local lightningLevel = t.getLightningLevel(self, t)
      local flamesLevel = t.getFlamesLevel(self, t)
      return ([[Infuse celestial energy into your shadows to give them fearsome spells. Your shadows receive a bonus of %d to their Spellpower.
Your shadows can strike adjacent foes with rays of Moonlight (%d%% chance).
At level 3 your shadows can mark their enemies (%d%% chance at range 2 to 6), triggering a Searing Light if you hit the same target.
At level 5 when your shadows are struck down they may (50%% chance) Reform, becoming whole again.

#{italic}#Remember how you used to look to them for guidance?#{normal}#]]):format(spellpowerChange, closeAttackSpellChance, farAttackSpellChance)
   end,
         }

newTalent{
   name = "Lomea Focus", short_name="FLN_FOCUS_SHADOWS",
   type = {"cursed/solar-shadows", 4},
   require = cursed_wil_req4,
   points = 5,
   random_ego = "attack",
   cooldown = 6,
   hate = 0,
   range = 6,
   requires_target = true,
   tactical = { ATTACK = 2 },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), nowarning=true} end,
   on_pre_use = function(self, t, silent)
      return self:isTalentActive(self.T_FLN_CALL_SHADOWS)
   end,
   getDefenseDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4.4, 10.1)) end,
   getBlindsideChance = function(self, t) return self:combatTalentLimit(t, 100, 40, 80) end, -- Limit < 100%
   action = function(self, t)
      local target = self:getTalentTarget(t)
      local x, y, target = self:getTargetLimited(target)
      if not target then return nil end

      -- Ensure we have max shadows
      for i = 1, self:callTalent(self.T_FLN_CALL_SHADOWS, "getMaxShadows") do
         self:callTalent(self.T_FLN_CALL_SHADOWS, "summonShadow")
      end

      if self:reactionToward(target) < 0 then
         -- attack the target
         local blindsideChance = t.getBlindsideChance(self, t)
         local shadowCount = 0
         for _, e in pairs(game.level.entities) do
            if e.summoner and e.summoner == self and e.subtype == "shadow" then
               -- reset target and set to focus
               e.ai_target.x = nil
               e.ai_target.y = nil
               e.ai_target.actor = target
               e.ai_target.focus_on_target = true
               e.ai_target.blindside_chance = blindsideChance

               shadowCount = shadowCount + 1
            end
         end

         if shadowCount > 0 then
            self:logCombat(target, "#PINK#The shadows converge on #Target#!")
            return true
         else
            game.logPlayer(self, "There are no shadows to heed the call!")
            return false
         end
      else
         -- defend the target
         local defenseDuration = t.getDefenseDuration(self, t)
         local shadowCount = 0
         for _, e in pairs(game.level.entities) do
            if e.summoner and e.summoner == self and e.subtype == "shadow" then
               e.ai_state.shadow_wall = true
               e.ai_state.shadow_wall_target = target
               e.ai_state.shadow_wall_time = defenseDuration

               shadowCount = shadowCount + 1
            end
         end

         if shadowCount > 0 then
            self:logCombat(target, "#PINK#The shadows form around #Target#!")
            return true
         else
            game.logPlayer(self, "Their are no shadows to heed the call!")
            return false
         end
      end
   end,
   info = function(self, t)
      local defenseDuration = t.getDefenseDuration(self, t)
      local blindsideChance = t.getBlindsideChance(self, t)
      return ([[Focus your shadows on a single target. Friendly targets will be defended for %d turns. Hostile targets will be attacked, with a %d%% chance the shadows will blindside the target.
		If you have less than maximum shadows available, they will automatically be summoned before focusing.
		This talent has no cost.]]):format(defenseDuration, blindsideChance)
   end,
         }