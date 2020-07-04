function martyrSetupSummon(self, def, x, y, level, turns, no_control)
   local m = require("mod.class.NPC").new(def)
   m.creation_turn = game.turn
   m.faction = self.faction
   m.summoner = self
   m.summoner_gain_exp = true
   if turns then
      m.summon_time_max = turns
      m.summon_time = turns
   end
   m.exp_worth = 0
   m.life_regen = 0

   -- don't level up
   m.unused_stats = 0
   m.unused_talents = 0
   m.unused_generics = 0
   m.unused_talents_types = 0
   m.silent_levelup = true
   m.no_points_on_levelup = true

   m.ai_state = m.ai_state or {}
   m.ai_state.tactic_leash = 100
   m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
   
   m.inc_damage = table.clone(self.inc_damage, true)
   m.no_drops = true
   
   if game.party:hasMember(self) then
      local can_control = not no_control
      
      m.remove_from_party_on_death = true
      game.party:addMember(m, {
                              control=can_control and "full" or "no",
                              temporary_level = true,
                              type="minion",
                              title="Flag",
                              orders = {target=true},
                              })
   end
   m:resolve() m:resolve(nil, true)
   m.max_level = self.level + (level or 0)
   m:forceLevelup(math.max(1, self.level + (level or 0)))
   
   game.zone:addEntity(game.level, m, "actor", x, y)
   game.level.map:particleEmitter(x, y, 1, "summon")
   
   -- Summons never flee
   m.ai_tactic = m.ai_tactic or {}
   m.ai_tactic.escape = 0
   return m
end

function countFlags(self)
   local flags = {}
   if game.party and game.party:hasMember(self) then
      for act, def in pairs(game.party.members) do
         if act.is_tentacle_flag then
            flags[#flags+1] = act
         end
      end
   else
      for uid, act in pairs(game.level.entities) do
         if act.summoner and act.summoner == self and act.is_tentacle_flag then
            flags[#flags+1] = act
         end
      end
   end

   -- Find oldest existing flag to replace if needed
   local victim = flags[1] or nil
   for i, flag in pairs(flags) do
      if not victim or flag.creation_turn < victim.creation_turn then
         victim = flag
      end
   end
   return #flags, victim
end

newTalent{
   name = "Triumphant Flag", short_name = "REK_MTYR_STANDARD_IRRUPTION",
   type = {"demented/standard-bearer", 1},
   require = martyr_req1,
   points = 5,
   mode = "passive",
   cooldown = 6,
   flag = {
      type = "horror", subtype = "eldritch",
      display = "h", color=colors.WHITE,
      blood_color = colors.BLUE,
      name = "glorious flag",
      display = "G", color=colors.ORANGE,
      image="terrain/sprouting_tentacles_nest_base.png",
      embed_particles = {
         {name="tentacle_tree2", rad=1, args={tentacle_id=id, force_tf=0}},
      },

      sound={"creatures/ghost/attack%d", 1, 2},
      sound_moam = {"creatures/ghost/on_hit%d", 1, 2},
      sound_die = {"creatures/ghost/death%d", 1, 1},
      sound_random = {"creatures/ghost/random%d", 1, 1},

      level_range = {1, nil}, exp_worth = 0,
      temporary_level = true, -- don't follow you to new levels
      is_tentacle_tree = 1,
      is_tentacle_flag = 1,
      combat_armor = resolvers.levelup(30, 1, 1.5), combat_def = 0,
      combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 2.2), atk=500, apr=10 },
      never_move = 1,
      -- cant_be_moved = 1,
      body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },
      force_tentacle_hand = 1,
      autolevel = "warriormage",
      ai = "dumb_talented_simple", ai_state = { ai_target="target_closest", ai_move="move_complex", talent_in=2, },
      dont_pass_target = true,
      stats = { str=14, dex=18, mag=20, con=12 },
      rank = 2,
      size_category = 3,
      infravision = 10,
      insanity_regen = 10,
      
      resists = {all = 10, [DamageType.FIRE] = -10, [DamageType.LIGHT] = -25, [DamageType.BLIGHT] = 50},
      
      confusion_immune = 1,
      fear_immune = 1,
      teleport_immune = 0.5,
      knockback_immune = 1,
      stun_immune = 1,
      blind_immune = 1,
      see_invisible = 20,
      resolvers.sustains_at_birth(),
      
      resolvers.talents{T_MUTATED_HAND={base=1, every=5}},
      max_life = resolvers.rngavg(90,100),
   },
   
   getLevel = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t), -6, 0.9, 2, 5)) end, -- -6 @ 1, +2 @ 5, +5 @ 8
   callbackOnRest = function(self, t) self.rek_mtyr_flag_progress = nil end,
   callbackOnRun = function(self, t) self.rek_mtyr_flag_progress = nil end,
   callbackOnKill = function(self, t, src, death_note)
      if self:isTalentCoolingDown(t) then return end
      local didSummon = t.doSummon(self, t, src.x, src.y)
      if didSummon then self:startTalentCooldown(t) end
   end,
   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      if dead then return end
      
      local threshold = 0
      if target.rank < 3.2 then return
      elseif target.rank >= 5 then
         threshold = target.max_life * t.thEBoss(self, t)
      elseif target.rank >= 4 then
         threshold = target.max_life * t.thBoss(self, t)
      else
         threshold = target.max_life * t.thRare(self, t)
      end
      local amt = 0

      self.rek_mtyr_flag_progress = self.rek_mtyr_flag_progress or {}
      
      local stored = self.rek_mtyr_flag_progress[target.uid] or 0
      if stored + val >= threshold then
         if self:isTalentCoolingDown(t) then return end
         local didSummon = t.doSummon(self, t, target.x, target.y)
         if didSummon then self:startTalentCooldown(t) end
         self.rek_mtyr_flag_progress[target.uid] = 0
      else
         self.rek_mtyr_flag_progress[target.uid] = stored + val
      end
   end,
   getTimeLimit = function(self, t) return 10 end,
   thRare = function(self, t) return .4 end,
   thBoss = function(self, t) return 0.25 end,
   thEBoss = function(self, t) return 0.1 end,
   
   doSummon = function(self, t, x, y)
      game:onTickEnd(function()
			if self:attr("dead") then return end
                        local lev = t.getLevel(self, t)
                        
                        local x, y = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
                        if not x then return false end
                        
                        local count, weakest = countFlags(self)
                        if count >= 3 then
                           weakest:die()
                        end
                        
                        local flag = martyrSetupSummon(self, t.flag, x, y, lev, nil, true)
                        if self:knowTalent(self.T_REK_MTYR_STANDARD_CONTROL) then
                           local lvl = math.floor(self:getTalentLevel(self.T_REK_MTYR_STANDARD_CONTROL))
                           flag:learnTalent(flag.T_TENTACLE_CONSTRICT, true, lvl)
      end
                        if self:knowTalent(self.T_REK_MTYR_STANDARD_TUNNELING) then
                           local lvl = math.floor(self:getTalentLevel(self.T_REK_MTYR_STANDARD_TUNNELING))
                           flag:learnTalent(flag.T_OOZE_ROOTS, true, lvl)
                        end
                        if self:knowTalent(self.T_REK_MTYR_STANDARD_SYMBIOSIS) then
                           local lvl = math.floor(self:getTalentLevel(self.T_REK_MTYR_STANDARD_SYMBIOSIS))
                           flag:learnTalent(flag.T_TENDRILS_ERUPTION, true, lvl)
                        end
                     end)
      return true
   end,
   info = function(self, t)
      return ([[When you kill an enemy, summon a Flag of level %d where they died that magically strikes nearby enemies.

You also summon a flag when you have done enough damage to a powerful enemy: %d%% of the life of a rare enemy, %d%% of the life of a boss, or %d%% of the life of an elite boss or stronger.  In this case, the flag appears adjacent to them.

Summoning a flag has a cooldown.

Flags last until destroyed or until you leave the level, but you can only have 3 placed at a time.]]):format(math.max(1, self.level + t.getLevel(self, t)), t.getTimeLimit(self, t), t.thRare(self, t)*100, t.thBoss(self, t)*100, t.thEBoss(self, t)*100)
   end,
}

newTalent{
   name = "Symbolic Defiance", short_name = "REK_MTYR_STANDARD_CONTROL",
   type = {"demented/standard-bearer", 2},
   require = martyr_req2,
   points = 5,
   insanity = -20,
   cooldown = 16,
   on_pre_use = function(self, t, silent) return true end,
   getCDReduce = function(self, t) return math.min(4, math.floor(self:combatTalentScale(t, 1, 3))) end,
   range = function(self, t)
      if self:knowTalent(self.T_REK_MTYR_STANDARD_TUNNELING) then
         local t3 = self:getTalentFromId(self.T_REK_MTYR_STANDARD_TUNNELING)
         return self:getTalentRange(t3)
      end
      return 1
   end,
   target = function(self, t) return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
   action = function(self, t)
      if not self:knowTalent(self.T_REK_MTYR_STANDARD_IRRUPTION) then
         return false
      end
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTargetLimitedWallStop(tg)
      if not x or not y then return nil end
      local t1 = self:getTalentFromId(self.T_REK_MTYR_STANDARD_IRRUPTION)
      t1.doSummon(self, t1, x, y)
      return true
   end,
   info = function(self, t)
      return ([[With incredible boldness, you plant a flag nearby without needing to defeat an enemy!

Levels in this talent grant your flags the ability to pull enemies closer to them and reduce the cooldown between automatic flag placements by %d turns.]]):
      format(t.getCDReduce(self, t))
   end,
}

newTalent{
   name = "Flag Toss", short_name = "REK_MTYR_STANDARD_TUNNELING",
   type = {"demented/standard-bearer", 3},
   require = martyr_req3,
   points = 5,
   mode = "passive",
   range = function(self, t) return self:combatTalentScale(t, 2, 5) end,
   info = function(self, t)
      return ([[When you place a flag yourself, it can go anywhere within range %d.

Levels in this talent grant your flags the ability to move around of their own volition.
]]):format(self:getTalentRange(t))
   end,
}

newTalent{
   name = "Aura of Confidence", short_name = "REK_MTYR_STANDARD_SYMBIOSIS",
   type = {"demented/standard-bearer", 4},
   require = martyr_req4,
   points = 5,
   mode = "passive",
   getRange = function(self, t) return 3 end,
   getResist = function(self, t) return math.floor(self:combatTalentScale(t, 15, 25)) end,
   callbackOnActBase = function(self, t)
      local list = {}
      --Near the player
      self:project(
         {type="ball", radius=t.getRange(self, t)}, self.x, self.y,
         function(px, py)
            local actor = game.level.map(px, py, Map.ACTOR)
            if actor and self:reactionToward(actor) >= 0 then list[#list+1] = actor end  
         end)
      while #list > 0 do
	 local flag = rng.tableRemove(list)
         if flag.is_tentacle_flag and not flag.dead and flag.x then
            if core.fov.distance(self.x, self.y, flag.x, flag.y) <= 3 then
               self:setEffect(self.EFF_REK_FLAG_SYMBIOSIS, 5, {resist=t.getResist(self, t)})
               flag:setEffect(flag.EFF_REK_FLAG_SYMBIOSIS, 5, {resist=t.getResist(self, t)})
            end
         end
      end
   end,
   info = function(self, t)
      return ([[Whenever you start a turn within range 3 of one of your flags, each of you gains %d%% all resistance for 5 turns.

Levels in this talent grant your flags a magical numbing attack.]]):format(t.getResist(self, t))
   end,
}
