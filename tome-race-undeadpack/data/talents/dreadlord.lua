

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
      if not src or src == self or src.necrotic_minion then return mod.class.NPC.heal(self, amt, src) end
      if src.getCurrentTalent and src:getCurrentTalent() and src:getTalentFromId(src:getCurrentTalent()) and not src:getTalentFromId(src:getCurrentTalent()).is_nature then return mod.class.NPC.heal(self, amt, src) end
      game.logSeen(self, "#GREY#%s can not be healed this way!", self:getName():capitalize())
   end

   -- Leave this for necromancers
   if self:isTalentActive(self.T_NECROTIC_AURA) then
      local t = self:getTalentFromId(self.T_NECROTIC_AURA)
      local perc = t:_getInherit(self) / 100
      
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
                              title=_t"Necrotic Minion",
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
            T_PHASE_DOOR={base=1, every=6},
                          },
         max_life = resolvers.rngavg(90,100),
      },
   },
   getLevel = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t), -6, 0.9, 2, 5)) end,
   on_pre_use = function(self, t, silent)
      local count = 0
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.is_dreadlord_minion then
               count = count + 1
	    end
	 end
      end
      if count < 3 then return true end
      if not silent then game.logPlayer(self, "You have too many dreads already.") end
      return false
   end,
   action = function(self, t)
      local lev = t.getLevel(self, t)

      local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
      if not x then return end
      local dread = dreadSetupSummon(self, t.minions_list.dread, x, y, lev)
      if self:knowTalent(self.T_DREADMASTER) then
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
      end
      game:playSoundNear(self, "creatures/ghost/random1")
      return true
   end,
   info = function(self, t)
      return ([[Summon a Dread of level %d that will annoyingly blink around, attacking your foes.
Dreads last until destroyed, and you can maintain up to %d dreads at a time.]]):format(math.max(1, self.level + t:_getLevel(self)), t.getMaxSummons(self, t))
   end,
         }

newTalent{
   name = "Threefold Hex", short_name = "REK_DREAD_HEXES",
   type = {"undead/dreadmaster", 2},
   require = dreads_req2,
   points = 5,
   mode = "passive",
   getSP = function(self, t) return self:combatTalentSpellDamage(t, 6, 50, 1.0) end,
   info = function(self, t)
      return ([[Weave magic into your dreads, teaching them terrible hexes and curses (at talent level %d) and increasing their spellpower by %d.
Level 1: Burning Hex
Level 3: Empathic Hex
Level 5: Pacification Hex
Level 7: Curse of Impotence]]):format(self:getTalentLevel(t), t:_getSP(self))
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
   getFoes = function(self, t) return math.floor(self:combatTalentScale(t, 2, 8)) end,
   doCallback = function(self, t)
      if game.party and game.party:hasMember(self) then
	 for dread, def in pairs(game.party.members) do
	    if dread.summoner and dread.summoner == self and dread.is_dreadlord_minion then
               dread:heal(t:_getHeal(self), dread)
               for tid, _ in pairs(dread.talents) do dread:alterTalentCoolingdown(tid, -t:_getCD(self)) end
            end
         end
      end
   end,
   thRare = function(self, t) return .4 end,
   thBoss = function(self, t) return 0.25 end,
   thEBoss = function(self, t) return 0.1 end,
   callbackOnSummonKill = function(self, t, src, self, death_note) t.doCallback(self, t) end,
   callbackOnKill = function(self, t, src, self, death_note) t.doCallback(self, t) end,
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
Each time they feed, each dreads heals for %d and reduces the remaining cooldown of their spells by %d.]]):format(t:_getHeal(self), t:_getCD(self))
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
         dread:setEffect(dread.EFF_NEVERENDING_PERIL, t.getTurns(self, t), {src=self})
      end
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.is_dreadlord_minion then
	       apply(act)
	    end
	 end
      end
      return true
   end,
   info = function(self, t)
      return ([[Focus a shell of darkness and scorn around your dreads, rendering them fully invincible for %d turns.]]):format(t.getTurns(self, t))
   end,
}