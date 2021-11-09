newTalent{
   name = "Walking Blasphemy", short_name="REK_DREAD_STEALTH",
   type = {"undead/dreadlord", 1},
   mode = "sustained",
   require = high_undeads_req1,
   points = 5,
   cooldown = 10,
   radius = 10,
   tactical = { BUFF = 2 },
   getDefense = function(self, t) return math.max(self:getMag(), self:getCun()) * 0.7 end,
   getStealth = function(self, t) return self:combatTalentScale(t, 15, 64) end,
   getDamage = function(self, t) return self:combatTalentScale(t, 20, 40) end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/heal")    
      self:talentTemporaryValue(t, "stealthed_prevents_targetting", 1)

      local p = {}
      p.def = self:addTemporaryValue("combat_def", t.getDefense(self, t))
      p.stealth = self:addTemporaryValue("stealth", t.getStealth(self, t))

      if not self.shader then
         p.set_shader = true
         self.shader = "frog_shadow"
         self.shader_args = { a_min = 0, a_max = 0.8, base = 0.1 }
         self:removeAllMOs()
         game.level.map:updateMap(self.x, self.y)
      end
      
      return p
   end,
   deactivate = function(self, t, p)
      self:removeTemporaryValue("combat_def", p.def)
      self:removeTemporaryValue("stealth", p.stealth)
      self:resetCanSeeCacheOf()
      if p.set_shader then
         self.shader = nil
         self:removeAllMOs()
         game.level.map:updateMap(self.x, self.y)
      end
      return true
   end,

   callbackOnActBase = function(self, t)
      local tg = {type="ball", friendlyfire=false, range=0, radius=self:getTalentRadius(t), talent=t}
      local has_targets = false
      self:project(
         tg, self.x, self.y,
         function(tx, ty)
            local target = game.level.map(tx, ty, Map.ACTOR)
            if target then
               has_targets = true
            end
         end)

      if has_targets then
         local damage = self:mindCrit(t.getDamage(self, t))
      
         self:project(
            tg, self.x, self.y,
            function(tx, ty)
               local target = game.level.map(tx, ty, Map.ACTOR)
               if target and not target:canSee(self) then
                  DamageType:get(DamageType.MIND).projector(self, target.x, target.y, DamageType.MIND, damage)
               end
            end)
      end
   end,
   info = function(self, t)
      return ([[You are shrouded in unholy darkness, granting a %d bonus to Defense and placing you in stealth with %d power.  Actions that normally break stealth do #{bold}#not#{normal}# disrupt this effect.

The stealth will increase with talent level.
The defense will increase with your Magic or Cunning (whichever is higher).

Anyone who manages to glimpse your terrible form suffers %d mind damage (uses mental critical rate).

#{italic}#Your appearance flickers, black and twisted. The very universe tries to banish you...but it lacks the strength.#{normal}#]]):tformat(t.getDefense(self, t), t.getStealth(self, t), damDesc(self, DamageType.MIND, t.getDamage(self, t)))
   end,
}

newTalent{
   name = "Corrupting Touch", short_name="REK_DREAD_DISPERSE",
   type = {"undead/dreadlord", 2},
   require = high_undeads_req2,
   points = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
   tactical = {
      DISABLE = function(self, t, aitarget)
         local nb = 0
         for eff_id, p in pairs(aitarget.tmp) do
            local e = self.tempeffect_def[eff_id]
            if e.status == "beneficial" then nb = nb + 1 end
         end
         for tid, act in pairs(aitarget.sustain_talents) do
            nb = nb + 1
         end
         return nb^0.5
      end},
   requires_target = true,
   range = 1,
   getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t)}
      local tx, ty = self:getTarget(tg)
      if not tx or not ty or not game.level.map(tx, ty, Map.ACTOR) then return nil end
      local _ _, tx, ty = self:canProject(tg, tx, ty)
      if not tx then return nil end
      local target = game.level.map(tx, ty, Map.ACTOR)
      if not target then return nil end
      
      local effs = {}

      -- effects
      for eff_id, p in pairs(target.tmp) do
         local e = target.tempeffect_def[eff_id]
         if e.status == "beneficial" then
            effs[#effs+1] = {"effect", eff_id}
         end
      end
      -- sustains
      for tid, act in pairs(target.sustain_talents) do
         if act then
            local talent = target:getTalentFromId(tid)
            effs[#effs+1] = {"talent", tid}
         end
      end
      
      for i = 1, t.getRemoveCount(self, t) do
         if #effs == 0 then break end
         local eff = rng.tableRemove(effs)
         
         if eff[1] == "effect" then
            target:removeEffect(eff[2])
         else
            target:forceUseTalent(eff[2], {ignore_energy=true})
         end
      end
      if self:knowTalent(self.T_REK_DREAD_STEP) then
         self:setEffect(self.EFF_REK_DREAD_GHOSTLY, self:callTalent(self.T_REK_DREAD_STEP, "getDuration"), {src=self}) 
      end
      game:playSoundNear(self, "talents/spell_generic")
      return true
   end,
   info = function(self, t)
      return ([[Reach out to an adjacent enemy, removing up to %d positive effects or sustains.

#{italic}#At your touch, rock crumbles, flesh withers, and magic fails.#{normal}#]]):tformat(t.getRemoveCount(self, t))
   end,
}

newTalent{
   name = "Black Gate", short_name="REK_DREAD_TELEPORT",
   type = {"undead/dreadlord", 3},
   require = high_undeads_req3,
   points = 5,
   cooldown = function(self, t) return 12 end,
   tactical = teleport_tactical,
   range = function(self, t) return self:combatTalentScale(t, 5, 15) end,
   is_teleport = true,
   radius = function(self, t) return math.max(0, 7 - math.floor(self:getTalentLevel(t))) end,
   target = function(self, t)
      local tg = {type="beam", nolock=true, pass_terrain=false, nowarning=true, range=self:getTalentRange(t)}
      if not self.player then
         tg.grid_params = {want_range=self.ai_state.tactic == "escape" and self:getTalentCooldown(t) + 11 or self.ai_tactic.safe_range or 0, max_delta=-1}
      end
      return tg
   end,
   direct_hit = true,
   is_teleport = true,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not x or not y then return nil end

      -- Check LOS
      if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
         game.logPlayer(self, "The gate fizzles and works randomly!")
         x, y = self.x, self.y
         range = self:getTalentRange(t)
      end
      if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
         game.logPlayer(self, "You may only gate to an open space.")
         return nil
      end
      local __, x, y = self:canProject(tg, x, y)
      local teleport = self:getTalentRadius(t)
      target = game.level.map(x, y, Map.ACTOR)
      if target then
         teleport = 0
      end

      game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
      
      if not self:teleportRandom(x, y, teleport) then
         game.logSeen(self, "Your gate fails!")
      elseif self:isTalentActive(self.T_REK_DREAD_STEALTH) then
         local tg = {type="ball", range=self:getTalentRange(t), radius=10, friendlyfire=false, talent=t}
         self:project(
            tg, self.x, self.y,
            function(tx, ty)
               local a = game.level.map(tx, ty, Map.ACTOR)
               if a and a:reactionToward(self) < 0 then
                  a:setTarget(nil)
               end
            end)
      end

      if self:knowTalent(self.T_REK_DREAD_STEP) then
         self:setEffect(self.EFF_REK_DREAD_GHOSTLY, self:callTalent(self.T_REK_DREAD_STEP, "getDuration"), {src=self}) 
      end
      
      game.level.map:particleEmitter(self.x, self.y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
      game:playSoundNear(self, "talents/teleport")
      
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local range = self:getTalentRange(t)
      return ([[Teleports you randomly within a range of up to %d.  You arrive right next to a targeted creature, or within %d grids of a targeted space.
If the target area is not in line of sight, there is a chance you will instead teleport randomly.
If Walking Blasphemy is sustained, all enemies will lose track of you.]]):tformat(range, radius)
   end,
         }

newTalent{
   name = "Phantasmal Step", short_name="REK_DREAD_STEP",
   type = {"undead/dreadlord", 4},
   points = 5,
   require = high_undeads_req4,
   cooldown = 18,
   no_energy = true,
   tactical = { ESCAPE = 1, CLOSEIN = 1 },
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_DREAD_GHOSTLY, t.getDuration(self, t), {src=self}) 
      game:playSoundNear(self, "talents/warp")
      return true
   end,
   info = function(self, t)
      return ([[Physical barriers are no obstacle to a spirit.  After using this or any other talent in this tree, you'll be able to walk through walls for the next %d turns.  If you are inside a wall when the effect ends, you will move to the nearest open space.]])
:tformat(t.getDuration(self, t))
   end,
}

-- Class talents for summoning lesser dreads
function dreadSetupSummon(self, def, x, y, level)
   local m = require("mod.class.NPC").new(def)
   m.necrotic_minion = true
   m.creation_turn = game.turn
   m.faction = self.faction
   m.summoner = self
   m.summoner_gain_exp = true
   m.exp_worth = 0
   m.life_regen = 0
   m.unused_stats = 0
   m.unused_talents = 0
   m.unused_generics = 0
   m.unused_talents_types = 0
   m.silent_levelup = true
   m.no_points_on_levelup = true
   m.ai_state = m.ai_state or {}
   m.ai_state.tactic_leash = 100
   -- Try to use stored AI talents to preserve tweaking over multiple summons
   m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
   m.inc_damage = table.clone(self.inc_damage, true)
   m.no_inventory_access = 1
   m.no_drops = true
   m.minion_be_nice = 1
   m.heal = function(self, amt, src)
      if not src or src == self or src.necrotic_minion or src == self.summoner then return mod.class.NPC.heal(self, amt, src) end
      if src.getCurrentTalent and src:getCurrentTalent() and src:getTalentFromId(src:getCurrentTalent()) and not src:getTalentFromId(src:getCurrentTalent()).is_nature then return mod.class.NPC.heal(self, amt, src) end
      if self.getName then
         game.logSeen(self, "#GREY#%s can not be healed this way!", self:getName():capitalize())
      end
   end

   -- Leave this for necromancers
   if self:isTalentActive(self.T_NECROTIC_AURA) then
      local t = self:getTalentFromId(self.T_NECROTIC_AURA)
      local perc = t.getInherit(self, t) / 100
      
      -- Damage
      m.combat_generic_crit = (m.combat_generic_crit or 0) + math.floor(self:combatSpellCrit() * perc)
      m.combat_generic_power = (m.combat_generic_crit or 0) + math.floor(self:combatSpellpowerRaw() * perc)
      local max_inc = self.inc_damage.all or 0
      for k, e in pairs(self.inc_damage) do
         max_inc = math.max(max_inc, self:combatGetDamageIncrease(k))
      end
      m.inc_damage.all = (m.inc_damage.all or 0) + math.floor(max_inc * perc)
      
      -- Resists
      for k, e in pairs(self.resists) do
         m.resists[k] = (m.resists[k] or 0) + math.floor(e * perc)
      end
      for k, e in pairs(self.resists_cap) do
         m.resists_cap[k] = e
      end
      
      -- Saves
      m.combat_physresist = m.combat_physresist + math.floor(self:combatPhysicalResistRaw() * perc)
      m.combat_spellresist = m.combat_spellresist + math.floor(self:combatSpellResistRaw() * perc)
      m.combat_mentalresist = m.combat_mentalresist + math.floor(self:combatMentalResistRaw() * perc)
      
      m.poison_immune = (m.poison_immune or 0) + (self:attr("poison_immune") or 0) * perc
      m.disease_immune = (m.disease_immune or 0) + (self:attr("disease_immune") or 0) * perc
      m.cut_immune = (m.cut_immune or 0) + (self:attr("cut_immune") or 0) * perc
      m.confusion_immune = (m.confusion_immune or 0) + (self:attr("confusion_immune") or 0) * perc
      m.blind_immune = (m.blind_immune or 0) + (self:attr("blind_immune") or 0) * perc
      m.silence_immune = (m.silence_immune or 0) + (self:attr("silence_immune") or 0) * perc
      m.disarm_immune = (m.disarm_immune or 0) + (self:attr("disarm_immune") or 0) * perc
      m.pin_immune = (m.pin_immune or 0) + (self:attr("pin_immune") or 0) * perc
      m.stun_immune = (m.stun_immune or 0) + (self:attr("stun_immune") or 0) * perc
      m.fear_immune = (m.fear_immune or 0) + (self:attr("fear_immune") or 0) * perc
      m.knockback_immune = (m.knockback_immune or 0) + (self:attr("knockback_immune") or 0) * perc
      m.stone_immune = (m.stone_immune or 0) + (self:attr("stone_immune") or 0) * perc
      m.teleport_immune = (m.teleport_immune or 0) + (self:attr("teleport_immune") or 0) * perc
   end
   if self:knowTalent(self.T_SOUL_LEECH) then
      m:learnTalent(m.T_SOUL_LEECH, true, self:getTalentLevelRaw(self.T_SOUL_LEECH))
   end
   
   -- Speeds
   m.movement_speed = self.movement_speed
   m.global_speed_add = self.global_speed_add
   
   if game.party:hasMember(self) then
      local can_control = false
      
      m.remove_from_party_on_death = true
      game.party:addMember(m, {
                              control=can_control and "full" or "order",
                              type="minion",
                              title="Necrotic Minion",
                              orders = {target=true, dismiss=true},
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

newTalent{
   name = "Spirit of Dread", short_name = "REK_DREAD_SUMMON_DREAD",
   type = {"undead/dreadmaster", 1},
   require = dreads_req1,
   points = 5,
   cooldown = 40,
   tactical = { ATTACK = {DARKNESS=1}, DISABLE = 5 },
   requires_target = true,
   range = 10,
   minions_list = {
      dread = {
         type = "undead", subtype = "ghost", is_dreadlord_minion = true,
         name = "dread", blood_color = colors.GREY,
         display = "G", color=colors.ORANGE, image="npc/dread.png",
         combat = {dam=resolvers.mbonus(45, 45), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5}, sound={"creatures/ghost/attack%d", 1, 2}},
         sound_moam = {"creatures/ghost/on_hit%d", 1, 2},
         sound_die = {"creatures/ghost/death%d", 1, 1},
         sound_random = {"creatures/ghost/random%d", 1, 1},
         level_range = {1, nil}, exp_worth = 0,
         body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
         autolevel = "warriormage",
         ai = "dumb_talented_simple", ai_state = { ai_target="target_closest", ai_move="move_complex", talent_in=2, },
         dont_pass_target = true,
         stats = { str=14, dex=18, mag=20, con=12 },
         rank = 2,
         size_category = 3,
         infravision = 10,
         mana_regen = 5,
         vim_regen = 5,
         stealth = resolvers.mbonus(40, 10),

         can_pass = {pass_wall=70},
         resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},

         no_breath = 1,
         stone_immune = 1,
         confusion_immune = 1,
         fear_immune = 1,
         teleport_immune = 0.5,
         disease_immune = 1,
         poison_immune = 1,
         stun_immune = 1,
         blind_immune = 1,
         cut_immune = 1,
         see_invisible = 80,
         undead = 1,
         avoid_pressure_traps = 1,
         resolvers.sustains_at_birth(),
         no_boneyard_resurrect = true,

         resolvers.talents{
            T_BLUR_SIGHT={base=3, every=5},
            T_PHASE_DOOR={base=1, max=3, every=6},
                          },
         max_life = resolvers.rngavg(90,100),
      },
   },
   getLevel = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t), -6, 0.9, 2, 5)) end,
   getMaxSummons = function(self, t) return math.min(5, math.floor(self:combatTalentScale(t, 1, 3))) end,
   on_pre_use = function(self, t, silent)
      local count = 0
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.is_dreadlord_minion then
               count = count + 1
	    end
	 end
      end
      if count < t.getMaxSummons(self, t) then return true end
      if not silent then game.logPlayer(self, "You have too many dreads already.") end
      return false
   end,
   relearnHexes = function(self, t, dread)
      if dread:knowTalent(dread.T_BURNING_HEX) then
         dread.combat_spellpower = 0
         dread:unlearnTalent(dread.T_BURNING_HEX, dread:getTalentLevelRaw(dread.T_BURNING_HEX), nil, {no_unlearn=true})
      end
      if dread:knowTalent(dread.T_EMPATHIC_HEX) then
         dread:unlearnTalent(dread.T_EMPATHIC_HEX, dread:getTalentLevelRaw(dread.T_EMPATHIC_HEX), nil, {no_unlearn=true})
      end
      if dread:knowTalent(dread.T_PACIFICATION_HEX) then
         dread:unlearnTalent(dread.T_PACIFICATION_HEX, dread:getTalentLevelRaw(dread.T_PACIFICATION_HEX), nil, {no_unlearn=true})
      end
      if dread:knowTalent(dread.T_CURSE_OF_IMPOTENCE) then
         dread:unlearnTalent(dread.T_CURSE_OF_IMPOTENCE, dread:getTalentLevelRaw(dread.T_CURSE_OF_IMPOTENCE), nil, {no_unlearn=true})
      end

      t.learnHexes(self, t, dread)
   end,
   learnHexes = function(self, t, dread)
      local lvl = math.floor(self:getTalentLevel(self.T_REK_DREAD_HEXES))
      if lvl >= 1 then
         dread:learnTalent(dread.T_BURNING_HEX, true, lvl)
         dread.combat_spellpower = self:callTalent(self.T_REK_DREAD_HEXES, "getSP")
      end
      if lvl >= 3 then
         dread:learnTalent(dread.T_EMPATHIC_HEX, true, lvl)
      end
      if lvl >= 5 then
         dread:learnTalent(dread.T_PACIFICATION_HEX, true, lvl)
      end
      if lvl >= 7 then
         dread:learnTalent(dread.T_CURSE_OF_IMPOTENCE, true, lvl)
      end
   end,
   action = function(self, t)
      local lev = t.getLevel(self, t)

      local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
      if not x then return end
      local dread = dreadSetupSummon(self, t.minions_list.dread, x, y, lev)
      if self:knowTalent(self.T_REK_DREAD_HEXES) then
         t.learnHexes(self, t, dread)
      end
      game:playSoundNear(self, "creatures/ghost/random1")
      return true
   end,
   info = function(self, t)
      return ([[Summon a Dread of level %d that will annoyingly blink around, attacking your foes.
Dreads last until destroyed, and you can maintain up to %d dreads at a time.
You always know where your dreads are.]]):tformat(math.max(1, self.level + t.getLevel(self, t)), t.getMaxSummons(self, t))
   end,
         }

newTalent{
   name = "Threefold Hex", short_name = "REK_DREAD_HEXES",
   type = {"undead/dreadmaster", 2},
   require = dreads_req2,
   points = 5,
   mode = "passive",
   getSP = function(self, t) return 5+self:combatSpellpower()*0.5 end,
   on_levelup_close = function(self, t, lvl, old_lvl, lvl_raw, old_lvl_raw)
      if lvl_raw ~= old_lvl_raw then
         if self:knowTalent(self.T_REK_DREAD_SUMMON_DREAD) then
            local t1 = self:getTalentFromId(self.T_REK_DREAD_SUMMON_DREAD)
            if game.party and game.party:hasMember(self) then
               for act, def in pairs(game.party.members) do
                  if act.summoner and act.summoner == self and act.is_dreadlord_minion then
                     t1.relearnHexes(self, t1, act)
                  end
               end
            end
      end
      end
   end,
   info = function(self, t)
      return ([[Weave magic into your dreads, teaching them terrible hexes and curses (at talent level %d) and increasing their spellpower by %d (based on your spellpower).
Level 1: Burning Hex
Level 3: Empathic Hex
Level 5: Pacification Hex
Level 7: Curse of Impotence]]):tformat(self:getTalentLevel(t), t.getSP(self, t))
   end,
}

newTalent{
   name = "Soul Feast", short_name = "REK_DREAD_SOUL_FEAST",
   type = {"undead/dreadmaster",3},
   require = dreads_req3,
   points = 5,
   mode = "passive",
   getHeal = function(self, t) return 10 + self:combatTalentSpellDamage(t, 30, 200) end,
   getCD = function(self, t) return math.floor(self:combatTalentScale(t, 1, 4)) end,
   doCallback = function(self, t)
      if game.party and game.party:hasMember(self) then
	 for dread, def in pairs(game.party.members) do
	    if dread.summoner and dread.summoner == self and dread.is_dreadlord_minion then
               dread:heal(t.getHeal(self, t), dread)
               for tid, _ in pairs(dread.talents) do dread:alterTalentCoolingdown(tid, -t.getCD(self, t)) end
            end
         end
      end
      self:heal(t.getHeal(self, t), dread)
      self:alterTalentCoolingdown(self.T_REK_DREAD_DISPERSE, -t.getCD(self, t))
      self:alterTalentCoolingdown(self.T_REK_DREAD_TELEPORT, -t.getCD(self, t))
      self:alterTalentCoolingdown(self.T_REK_DREAD_STEP, -t.getCD(self, t))
      self:alterTalentCoolingdown(self.T_REK_DREAD_SUMMON_DREAD, -t.getCD(self, t))
   end,
   thRare = function(self, t) return .4 end,
   thBoss = function(self, t) return 0.25 end,
   thEBoss = function(self, t) return 0.1 end,
   callbackOnSummonKill = function(self, t, src, death_note) t.doCallback(self, t) end,
   callbackOnKill = function(self, t, src, death_note) t.doCallback(self, t) end,
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

      self.rek_dread_soul_progress = self.rek_dread_soul_progress or {}
      
      local stored = self.rek_dread_soul_progress[target.uid] or 0
      if stored + val >= threshold then
         if self:isTalentCoolingDown(t) then return end
         t.doCallback(self, t)
         self.rek_dread_soul_progress[target.uid] = 0
      else
         self.rek_dread_soul_progress[target.uid] = stored + val
      end
   end,
   info = function(self, t)
      return ([[You and your minions feed on death and destruction.  Any time you or your minions kill something (or you do a large chunk of damage to a rare or stronger enemy), your dreads absorb a fragment of its soul to feed on.
Each time they feed, each dread heals for %d and reduces the remaining cooldown of their spells by %d.  This also applies to you and your dread abilities.]]):tformat(t.getHeal(self, t), t.getCD(self, t))
   end,
}

newTalent{
   name = "Peril Unending", short_name = "REK_DREAD_NEVERENDING_PERIL",
   type = {"undead/dreadmaster", 4},
   require = dreads_req4,
   points = 5,
   cooldown = 20,
   tactical = { BUFF=1 },
   getTurns = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9)) end,
   on_pre_use = function(self, t, silent)
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.is_dreadlord_minion then
	       return true
	    end
	 end
      end
      if not silent then game.logPlayer(self, "You have no dread to protect!") end
      return false
   end,
   action = function(self, t)
      local apply = function(dread)
         dread:setEffect(dread.EFF_REK_DREAD_NEVERENDING_PERIL, t.getTurns(self, t), {src=self})
      end
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and (act.is_dreadlord_minion or act.dread_minion) then
	       apply(act)
	    end
	 end
      end
      return true
   end,
   info = function(self, t)
      return ([[Focus a shell of darkness and scorn around your dreads, rendering them fully invincible for %d turns.]]):tformat(t.getTurns(self, t))
   end,
}
