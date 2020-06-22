newTalent{
   name = "Panic", short_name = "FLN_SHADOW_PANIC",
   type = {"cursed/misc", 1},
   require = { },
   points = 5,
   cooldown = 20,
   range = 4,
   tactical = { DISABLE = 4 },
   getDuration = function(self, t)
      return 3 + math.floor(math.pow(self:getTalentLevel(t), 0.5) * 2.2)
   end,
   getChance = function(self, t)
      return math.min(50, math.floor(self:combatTalentScale(t, 25, 40)))
   end,
   action = function(self, t)
      local range = self:getTalentRange(t)
      local duration = t.getDuration(self, t)
      local chance = t.getChance(self, t)
      self:project(
         {type="ball", radius=range}, self.x, self.y,
         function(px, py)
            local actor = game.level.map(px, py, engine.Map.ACTOR)
            if actor and self:reactionToward(actor) < 0 and actor ~= self then
               if not actor:canBe("fear") then
                  game.logSeen(actor, "#F53CBE#%s ignores the panic!", actor.name:capitalize())
               elseif actor:checkHit(self:combatMindpower(), actor:combatMentalResist(), 0, 95) then
                  actor:setEffect(actor.EFF_PANICKED, duration, {src=self, range=10, chance=chance, tyrantPower=tyrantPower, maxStacks=maxStacks, tyrantDur=tyrantDur})
               else
                  game.logSeen(actor, "#F53CBE#%s resists the panic!", actor.name:capitalize())
               end
            end
         end,
         nil, nil)
      return true
   end,
   info = function(self, t)
      local range = self:getTalentRange(t)
      local duration = t.getDuration(self, t)
      local chance = t.getChance(self, t)
      return ([[Panic your enemies within a range of %d for %d turns. Anyone who fails to make a mental save against your Mindpower has a %d%% chance each turn of trying to run away from you.]]):format(range, duration, chance)
   end,
}


local function createBonusShadow(self, level, tCallShadows, tShadowWarriors, tShadowMages, tReave, duration, target)
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
      stats = {
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
         [self.T_FLN_SHADOW_PANIC]=tReave.getTalentLevel(self, tReave),
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
         if self:knowTalent(self.T_FLN_SHADOW_PANIC) and not self:isTalentCoolingDown(self.T_FLN_SHADOW_PANIC) then
            return self:useTalent(self.T_FLN_SHADOW_PANIC)
         end
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


-- Provides distractions, weak targets to lifesteal from/jump to, and a renewable source of on-kills
newTalent{
   name = "Shadowed Memories", short_name = "FLN_SHADOW_TWISTING_SHADOWS",
   type = {"cursed/suffering-shadows", 1},
   require = cursed_wil_req_high1,
   points = 5,
   cooldown = 30,
   range = 10,
   tactical = { DEFEND = 3 },
   getCount = function(self, t) return math.ceil(self:getTalentLevel(t)+2) end,
   action = function(self, t)
      -- Boost your existing shadows, which is just a consolation
      local apply = function(a)
	 a.energy.value = a.energy.value + 1000
      end
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.subtype == "shadow" then
	       apply(act)
	    end
	 end
      else
	 for uid, act in pairs(game.level.entities) do
	    if act.summoner and act.summoner == self and act.subtype == "shadow" then
	       apply(act)
	    end
	 end
      end

      -- Summon the shades
      local nb = t.getCount(self, t)
      for i = 1, nb do
         local x, y = util.findFreeGrid(rng.range(-5, 5)+self.x, rng.range(-5, 5)+self.y, 5, true, {[Map.ACTOR]=true})
         if x and y then
            local NPC = require "mod.class.NPC"
            local level = self.level
            local m = NPC.new {
               type = "undead", subtype="shadow", display = "b",
               color=colors.WHITE,
               
               combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },
               
               body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
               lite = 3,
               
               life_rating = 5,
               rank = 2,
               size_category = 3,
               
               autolevel = "none",
               stats = {
                  str=math.floor(self:combatScale(level, 5, 0, 55, 50, 0.75)),
                  dex=math.floor(self:combatScale(level, 10, 0, 85, 50, 0.75)),
                  mag=math.floor(self:combatScale(level, 10, 0, 85, 50, 0.75)),
                  wil=math.floor(self:combatScale(level, 5, 0, 55, 50, 0.75)),
                  cun=math.floor(self:combatScale(level, 5, 0, 40, 50, 0.75)),
                  con=math.floor(self:combatScale(level, 5, 0, 40, 50, 0.75)),
               },
               ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
               level_range = {level, level},
               
               max_life = resolvers.rngavg(3,12),
               combat_armor = 0, combat_def = 3,

               summoner = nil,
               summoner_gain_exp = false,
               exp_worth = 0,
               summon_time = 8,
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
               hated_by_everybody = 1,
               hated_by_summoner = 1,
               hates_everybody = 1
            }
            
            m.level = level
            
            local race = rng.range(1, 3)
            if race == 1 then
               m.name = "distant shade"
               m.image = "npc/shadow_sun_paladin.png"
               m.desc = [[You remember...failure]]
            elseif race == 2 then
               m.name = "cowering shade"
               m.image = "npc/shadow_sun_mage.png"
               m.desc = [[You remember...betrayal]]
            elseif race == 3 then
               m.name = "fearsome shade"
               m.image = "npc/shadow_star_crusader.png"
               m.desc = [[You remember...terror]]
            end
            m.no_necrotic_soul = true
            
            m:resolve() m:resolve(nil, true)
            m:forceLevelup(self.level)
            game.zone:addEntity(game.level, m, "actor", x, y)
            game.level.map:particleEmitter(x, y, 1, "summon")
         end
      end
      game:playSoundNear(self, "talents/spell_generic")
      return true
   end,
   info = function(self, t)
      return ([[Reach into your memories and let out the darkness into nearby shadows.  Each of your shadows gains 1 turn, but you also summon %d shades of the past in random spaces nearby.  The shades do not know friend from foe, but are mostly harmless.]]):format(t.getCount(self, t))
   end,
}

newTalent{
   name = "Shadow Guardians", short_name = "FLN_SHADOW_GUARDING_SHADOWS",
   type = {"cursed/suffering-shadows", 2},
   require = cursed_wil_req_high2,
   points = 5,
   points = 5,
   cooldown = 10,
   mode = 'sustained',
   no_npc_use = true,
   --count shadows in party
   getShadows = function(self, t)
      local shadowsCount = 0
      for _, actor in pairs(game.level.entities) do
	 if actor.summoner and actor.summoner == self and actor.subtype == "shadow" then shadowsCount = shadowsCount + 1 end
      end
      return shadowsCount
   end,
   --values for resists and affinity
   getLightResist = function(self, t) return -15 end,
   getDarkResist = function(self, t) return self:combatTalentScale(t, 10, 25) end,
   getAffinity = function(self, t) return self:combatTalentScale(t, 10, 25) end,
   getAllResScale = function(self, t) return self:combatTalentScale(t, 2, 4) end,
   getAllResist = function(self, t) return t.getAllResScale(self, t) * t.getShadows(self, t) end, 
   --activate effects
   activate = function(self, t)
      local ret = {
	 shadowres = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)}),
	 res = self:addTemporaryValue("resists", {[DamageType.LIGHT]=t.getLightResist(self, t), [DamageType.DARKNESS]=t.getDarkResist(self, t)}),
	 aff = self:addTemporaryValue("damage_affinity", {[DamageType.DARKNESS]=t.getAffinity(self, t)}),
      }
      return ret
   end,
   --callbacks
   callbackOnPartyAdd = function(self, t)
      local p = self:isTalentActive(t.id)
      if p.shadowres then self:removeTemporaryValue("resists", p.shadowres) end
      p.shadowres = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)})
   end,
   callbackOnPartyRemove = function(self, t)
      local p = self:isTalentActive(t.id)
      game:onTickEnd(function()
	    if p.shadowres then self:removeTemporaryValue("resists", p.shadowres) end
	    p.shadowres = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)})
      end)
   end,
   --deactivate effects
   deactivate = function(self, t, p)
      self:removeTemporaryValue("resists", p.shadowres)
      self:removeTemporaryValue("resists", p.res)
      self:removeTemporaryValue("damage_affinity", p.aff)
      return true
   end,
   info = function(self, t)
      return ([[You draw distant from the sun, and sink into the shadows of your past.  The line between you and your shadows begins to blur.
		You lose %d%% light resistance, but gain %d%% darkness resistance and affinity. You also gain %0.2f%% all resistance for each shadow in your party.]]):
	 format(t.getLightResist(self, t), t.getDarkResist(self, t), t.getAllResScale(self, t))
   end,   
}

newTalent{
   name = "Shadow Madness", short_name = "FLN_SHADOW_MADNESS",
   type = {"cursed/suffering-shadows", 3},
   require = cursed_wil_req_high3,
   points = 5,
   range = 3,
   cooldown = 14,
   hate = 6,
   getDuration = function(self, t) return self:combatTalentScale(t, 2, 6) end,
   on_pre_use = function(self, t, silent)
      local tgts = {}
      local seen = {}

      -- Collect all enemies within range of any shadow
      if game.level then
         for _, actor in pairs(game.level.entities) do
            if actor.summoner and actor.summoner == self and actor.subtype == "shadow" then
               self:project({type="ball", radius=self:getTalentRange(t)}, actor.x, actor.y, function(px, py)
                               local tgt = game.level.map(px, py, Map.ACTOR)
                               if tgt and self:reactionToward(tgt) < 0 and not seen[tgt.uid] then
                                  tgts[#tgts+1] = tgt
                                  seen[tgt.uid] = true
                               end
                                                                                            end)   
            end
         end
      end

      if #tgts > 0 then
         return true
      end
      if not silent then game.logPlayer(self, "No enemies in range of madness!") end
      return false
   end,
   action = function(self, t)
      local tgts = {}
      local seen = {}

      -- Collect all enemies within range of any shadow
      for _, actor in pairs(game.level.entities) do
	 if actor.summoner and actor.summoner == self and actor.subtype == "shadow" then
	    self:project({type="ball", radius=self:getTalentRange(t)}, actor.x, actor.y, function(px, py)
		  local tgt = game.level.map(px, py, Map.ACTOR)
		  if tgt and self:reactionToward(tgt) < 0 and not seen[tgt.uid] then
		     tgts[#tgts+1] = tgt
		     seen[tgt.uid] = true
		  end
	    end)   
	 end
      end

      if #tgts <= 0 then
         return false
      end
      -- Gloom them
      for _, target in pairs(tgts) do
	 if  target:checkHit(self:combatMindpower(), target:combatMentalResist(), 5, 95, 15) then
	    local effect = rng.range(1, 3)
	    if effect == 1 then
	       -- confusion
	       if target:canBe("confusion") and not target:hasEffect(target.EFF_GLOOM_CONFUSED) then
		  target:setEffect(target.EFF_GLOOM_CONFUSED, t.getDuration(self, t), {power=70})
	       end
	    elseif effect == 2 then
	       -- stun
	       if target:canBe("stun") and not target:hasEffect(target.EFF_GLOOM_STUNNED) then
		  target:setEffect(target.EFF_GLOOM_STUNNED, t.getDuration(self, t), {})
	       end
	    elseif effect == 3 then
	       -- slow
	       if target:canBe("slow") and not target:hasEffect(target.EFF_GLOOM_SLOW) then
		  target:setEffect(target.EFF_GLOOM_SLOW, t.getDuration(self, t), {power=0.3})
	       end
	    end
	 end
      end
      
      game:playSoundNear(self, "talents/fallen_scream")
      for _, actor in pairs(game.level.entities) do
         if actor.summoner and actor.summoner == self and actor.subtype == "shadow" then
            game.level.map:particleEmitter(actor.x, actor.y, 3, "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=3, nb_circles=6, rm=0.1, rM=0.2, gm=0, gM=0, bm=0.8, bM=0.9, am=0.4, aM=0.6})
         end
      end
      

      return true
   end,
   info = function(self, t)
      local dur = t.getDuration(self, t)
      return ([[Channel your raw anguish through your shadows, causing enemies near them to be overcome by gloom (#SLATE#Mindpower vs. Mental#LAST#) for %d turns, inflicting stun, slow, or confusion at random.]]):format(dur)
   end,
}

newTalent{
   name = "Shadow Reave", short_name = "FLN_SHADOW_SHADOW_REAVE",
   type = {"cursed/suffering-shadows", 4},
   require = cursed_wil_req_high4,
   points = 5,
   cooldown = 20,
   hate = 18,
   range = 6,
   requires_target = true,
   tactical = { ATTACK = 2 },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   getDuration = function(self, t) return 10 end,
   getResist = function(self, t) return math.ceil(self:combatTalentScale(t, 8, 35)) end,
   getTalentLevel = function(self, t)
      return self:getTalentLevelRaw(t)
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      if target == self then
         game.logPlayer(self, "You can't steal your own shadow!")
         return false
      end
      if self:reactionToward(target) >= 0 then
         game.logPlayer(self, "You can only steal an enemy's shadow!")
         return false
      end
      if target.subtype == "shadow" then
         game.logPlayer(self, "A shadow has no shadow to steal!")
         return false
      end
      if target:hasEffect(self.EFF_FLN_SHADOW_REFT) then
         game.logPlayer(self, "They have already lost their shadow!")
         return false
      end
      
      target:setEffect(target.EFF_FLN_SHADOW_REFT, 10, {resists=t.getResist(self, t)})
      if not target:hasEffect(self.EFF_FLN_SHADOW_REFT) then
         return true
      end --only summon if they successfully lose shadow
      
      -- Find space
      local x, y = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
      if not x then
	 return
      end

      local level = self.level
      local tCallShadows = self:knowTalent(self.T_FLN_CALL_SHADOWS) and self:getTalentFromId(self.T_FLN_CALL_SHADOWS) or nil
      local tShadowWarriors = self:knowTalent(self.T_FLN_SHADOW_WARRIORS) and self:getTalentFromId(self.T_FLN_SHADOW_WARRIORS) or nil
      local tShadowMages = self:knowTalent(self.T_FLN_SHADOW_MAGES) and self:getTalentFromId(self.T_FLN_SHADOW_MAGES) or nil
      local shadow = createBonusShadow(self, level, tCallShadows, tShadowWarriors, tShadowMages, t, t.getDuration(self, t)*2, nil)
      
      shadow:resolve()
      shadow:resolve(nil, true)
      shadow:forceLevelup(level)
      game.zone:addEntity(game.level, shadow, "actor", x, y)
      shadow:feed()
      game:playSoundNear(self, "talents/fallen_tearing")
      game.level.map:particleEmitter(x, y, 1, "teleport_in")
      return true
   end,
   
   info = function(self, t)
      local dur = t.getDuration(self, t)
      local strip = t.getResist(self, t)
      return ([[Attempt (#SLATE#Mindpower vs. Mental#LAST#) to rip away a target's shadow and pour in your pain to animate it, summoning a Shadow of Despair for %d turns and reducing their resistance to light and darkness damage by %d%%

The Shadow of Despair has all of your shadows' normal powers and can panic foes into fleeing.]]):format(dur, strip)
   end,
}
