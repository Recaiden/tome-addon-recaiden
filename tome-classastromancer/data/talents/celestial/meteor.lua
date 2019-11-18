local Object = require "mod.class.Object"

--Celestial/Meteor LOCKED, Level 10
newTalent{
   name = "Meteor Storm", short_name = "WANDER_METEOR_STORM",
   type = {"celestial/meteor", 1},
   require = spells_req_high1,
   points = 5,
   cooldown = 20,
   tactical = { ATTACKAREA = 3 },
   range = function(self, t) return 4 end,
   radius = function(self, t) return 1 end,
   getDuration = function(self, t) return 8 + self:combatTalentScale(t, 2, 9, 0.75) end,
   getDam = function(self, t) return self:combatTalentSpellDamage(t, 15, 60) end,
   action = function(self, t)
      game:playSoundNear(self, "talents/fire")
      self:setEffect(self.EFF_WANDER_METEOR_STORM, t.getDuration(self, t),
		     {
			power=t.getDam(self, t),
			range=t.range(self, t),
			radius=t.radius(self, t),
		     }
      )
      return true
   end,
   
   info = function(self, t)
      return ([[Shatter an orbiting meteor and rain down burnnig fragments on your enemies.
		Each turn for the next %d turns, a meteor will fall on an enemy near you or your summons, dealing %0.2f meteor damage to enemies in radius 1.  Enemies are more likely to be struck if there are multiple party members near them.
		The effects increase with spellpower.

#ORANGE#Meteor damage is half physical and half fire.#{normal}#
]])
	 :format(t.getDuration(self, t), damDesc(self, DamageType.METEOR, t.getDam(self, t)))
   end,
}

--	Void Summons - Sustained, instant, your meteors have a chance to spawn weak friendly Losgoroths and/or Manaworms
newTalent{
   name = "Void Summons", short_name = "WANDER_METEOR_VOID_SUMMONS",
   type = {"celestial/meteor", 2},
   require = spells_req_high2,
   points = 5,
   mode = "passive",

   getDuration = function(self,t) return 3 end,
   getChance = function(self,t) return 10* self:getTalentLevelRaw(t) end,

   incStats = function(self, t, fake)
      local mp = self:combatSpellpower()
      return{ 
	 mag=15 + (fake and mp or self:spellCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
	 cun=15 + (fake and mp or self:spellCrit(mp)) * 1.7 * self:combatTalentScale(t, 0.2, 1, 0.75),
	 con=10
      }
   end,

   callLosgoroth = function(self, t, tx, ty, target)
      if not tx or not ty then return nil end
      
      -- Find space
      local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
      if not x then
	 return
      end
      
      local NPC = require "mod.class.NPC"
      local m = NPC.new{
	 type = "elemental", subtype = "arcane",
	 display = "E", color=colors.DARK_GREY, image = "npc/elemental_void_losgoroth.png",
	 name = "Losgoroth", faction = self.faction,
	 desc = [[Aether elementals, native to the void between the stars.  This one has hitched a ride on a meteor.]],
	 autolevel = "none",
	 ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
	 ai_tactic = resolvers.tactic"ranged",
	 stats = {str=10, dex=8, con=16, cun=0, wil=0, mag=6},
	 inc_stats = t.incStats(self, t),
	 level_range = {self.level, self.level}, exp_worth = 0,
	 
	 max_life = resolvers.rngavg(5,10),
	 life_rating = 8,
	 infravision = 10,
	 levitation = 1,
	 can_pass = {pass_void=70},
	 
	 combat_armor = 0, combat_def = 20,
	 combat = { dam=51, atk=15, },
	 on_melee_hit = { [DamageType.ARCANE] = resolvers.mbonus(20, 10), },
	 
	 resolvers.talents{
	    [self.T_VOID_BLAST]=self:getTalentLevelRaw(t),
	 },
	 resists = { [DamageType.ARCANE] = self:getTalentLevel(t)*20 },
	 
	 summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
	 summon_time = t.getDuration(self, t),
	 ai_target = {actor=target}
      }
      setupSummonStar(self, m, x, y, false)
   end,

   callManaworm = function(self, t, tx, ty, target)
      if not tx or not ty then return nil end
      
      -- Find space
      local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
      if not x then
	 return
      end
      
      local NPC = require "mod.class.NPC"
      local m = NPC.new{
	 type = "elemental", subtype = "arcane",
	 display = "E", color=colors.BLUE, image = "npc/elemental_void_manaworm.png",
	 name = "Manaworm", faction = self.faction,
	 desc = [[Losgoroths which feed on magical energy. If they ever come in contact with a spellcaster, they latch on and start draining mana away.  This one has hitched a ride on a meteor]],
	 autolevel = "none",
	 ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
	 ai_tactic = resolvers.tactic"ranged",
	 stats = {str=10, dex=80, con=16, cun=0, wil=0, mag=6},
	 inc_stats = t.incStats(self, t),
	 level_range = {self.level, self.level}, exp_worth = 0,
	 
	 max_life = resolvers.rngavg(5,10),
	 life_rating = 8,
	 infravision = 10,
	 levitation = 1,
	 can_pass = {pass_void=70},

	 movement_speed = 0.7,
	 combat_armor = 0, combat_def = 20,
	 combat = { atk=10000, apr=10000, damtype=DamageType.MANAWORM }, -- They can not miss
	 on_melee_hit = { [DamageType.ARCANE] = resolvers.mbonus(20, 10), },
	 
	 resolvers.talents{
	 },
	 resists = { [DamageType.ARCANE] = self:getTalentLevel(t)*20 },
	 
	 summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
	 summon_time = t.getDuration(self, t),
	 ai_target = {actor=target}
      }
      setupSummonStar(self, m, x, y, false)
   end,
   
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local chance = t.getChance(self, t)
      return ([[Sometimes, the meteors you call down are host to small aether elementals.  Each meteor has a %d%% chance to spawn a friendly losgoroth or manaworm for %d turns.  Their stats will increase with your spellpower.

#GREEN#Blighted Summoning: Corrupted Negation (Losgoroth)
Blighted Summoning: Worm Rot (manaworm)#{normal}#
]]):format(chance, duration)
   end,
}


--	Starstrike - Converge several meteor shards on one location, stunning and dealing meteor damage.
newTalent{
   name = "Starstrike", short_name = "WANDER_METEOR_STARSTRIKE",
   type = {"celestial/meteor", 3},
   require = spells_req_high3,
   points = 5,
   random_ego = "attack",
   cooldown = 6,
   tactical = { ATTACKAREA = {FIRE = 1, PHYSICAL = 1}, DISABLE = 2 },
   range = 6,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
   end,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 170) end,
   on_pre_use = function(self, t, silent)
      if not self:hasEffect(self.EFF_WANDER_METEOR_STORM) then
	 if not silent then game.logPlayer(self, "You require an active meteor storm.") end
	 return false
      end
      local e = self:hasEffect(self.EFF_WANDER_METEOR_STORM)
      if e.dur and e.dur < 2 then
	 if not silent then game.logPlayer(self, "Your meteor storm is too close to ending.") end
	 return false
      end
      return true
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local grids = self:project(tg, x, y, DamageType.METEOR_BLAST, self:spellCrit(t.getDamage(self, t)))

      -- Void summons hook
      if self:knowTalent(self.T_WANDER_METEOR_VOID_SUMMONS) then
	 local tal_vs = self:getTalentFromId(self.T_WANDER_METEOR_VOID_SUMMONS)
	 if rng.percent(tal_vs.getChance(self, tal_vs)*2) then
	    if rng.percent(50) then
	       tal_vs.callLosgoroth(self, tal_vs, x, y, tg)
	    else
	       tal_vs.callManaworm(self, tal_vs, x, y, tg)
	    end
	 end
      end
      
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      if core.shader.active() then
	 game.level.map:particleEmitter(x, y, tg.radius, "starfall", {radius=tg.radius, tx=x, ty=y})
      else
	 game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})
	 game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, a=60, limit_life=16, appear=8, speed=-0.5, img="darkness_celestial_circle", radius=self:getTalentRadius(t)})
      end
      game:playSoundNear(self, "talents/fireflash")

      -- Use up meteor charges
      local e = self:hasEffect(self.EFF_WANDER_METEOR_STORM)
      e.dur = e.dur - 2
      if e.dur <= 0 then
	 self:removeEffect(self.EFF_WANDER_METEOR_STORM)
      end
	 
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local damage = t.getDamage(self, t)
      return ([[Call down several of your meteor fragments simultaneously, blasting a radius %d area for %0.2f meteor damage and stunning those within the area for 4 turns. 
This can trigger Void Summons, with double chance.
This talent requires an active Meteor Storm, and reduces its duration by 2.
		The damage dealt will increase with your Spellpower.]]):
	 format(radius, damDesc(self, DamageType.METEOR, damage))
   end,
}

newTalent{
   name = "Micrometeorite Strike", short_name = "WANDER_METEOR_MICROMETEOR",
   type = {"spell/other", 1},
   require = spells_req_high4,
   points = 5,
   range = 10,
   direct_hit = true,
   requires_target = true,
   tactical = { ATTACK = { FIRE = 1, PHYSICAL = 1 } },
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
   target = function(self, t)
      return {type="hit", range=self:getTalentRange(t), talent=t}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, x, y = self:canProject(tg, x, y)
      if not x or not y then return nil end
      local target = game.level.map(x, y, Map.ACTOR)
      if not target then return nil end
      
      local dam = self:spellCrit(t.getDamage(self, t))
      self:project(tg, x, y, DamageType.METEOR, {dam=dam})

      -- Graphic
      if core.shader.active() then
	 game.level.map:particleEmitter(x, y, 1, "starfall", {radius=0.5, tx=x, ty=y})
      else
	 game.level.map:particleEmitter(x, y, 1, "circle", {oversize=0.7, a=60, limit_life=16, appear=8, speed=-0.5, img="darkness_celestial_circle", radius=1})
      end
      
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Strike an enemy from above with a tiny meteorite, doing %0.2f meteor damage
		Spellpower: Increases damage]]):
      format(damDesc(self, DamageType.METEOR, damage))
   end,
}

newTalent{
   name = "Meteor Bombardment", short_name = "WANDER_METEOR_BOMBARDMENT",
   type = {"celestial/meteor", 4},
   require = spells_req_high4,
   points = 5,
   mode = "passive",

   getChance = function(self, t) return self:combatTalentLimit(t, 20, 5, 10) end,

   learnOnHit = function(self, t)
      self.talent_on_spell["WANDER_METEOR_BOMBARDMENT"] = {
	 chance=t.getChance(self,t),
	 talent=Talents.T_WANDER_METEOR_MICROMETEOR,
	 level=self:getTalentLevel(t)
      }
   end,

   on_learn = function(self, t)
      self.talent_on_spell = self.talent_on_spell or {}
      self.talent_on_spell["WANDER_METEOR_BOMBARDMENT"] = nil
      t.learnOnHit(self, t)
   end,
   on_unlearn = function(self, t)
      self.talent_on_spell = self.talent_on_spell or {}
      self.talent_on_spell["WANDER_METEOR_BOMBARDMENT"] = nil
      if self:getTalentLevel(t) > 0 then
	 t.learnOnHit(self, t)
      end
   end,
   
   info = function(self, t)
      local tv = self:getTalentFromId(self.T_WANDER_METEOR_MICROMETEOR)
      return ([[The surging of your magic is synchronized with drifitng meteors.  Whenever you hit with a spell, you have a %d%% chance to summon a meteor to strike them automatically. 
%s]]):format(t.getChance(self, t), self:getTalentFullDescription(tv, self:getTalentLevelRaw(t)):toString())
   end,
}

newTalent{
   name = "Meteor Shower", short_name = "WANDER_METEOR_STORM_BONUS",
   type = {"spell/objects",1},
   mode = "passive",
   points = 1,
   range = 4,
   getDam = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,

   callbackOnActBase = function(self, t)
      if not self:hasEffect(self.EFF_WANDER_METEOR_STORM) then return end
      local rad = 1
      
      local meteor = function(src, tg, x, y, dam)
	 --local x, y = self.args.x, self.args.y
	 game.level.map:particleEmitter(x, y, 10, "meteor", {x=x, y=y}).on_remove =
	    function(self)
	       game.level.map:particleEmitter(x, y, 10, "starfall", {radius=1})
	       src:project(tg, x, y, DamageType.METEOR, dam)
	    end
      end
      
      --Collect possible targets
      local list = {}
      --Near the player
      self:project({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, function(px, py)
	    local actor = game.level.map(px, py, Map.ACTOR)
	    if actor and self:reactionToward(actor) < 0 then list[#list+1] = actor end  
      end)

      --Near summons
      local apply = function(a)
	 a:project({type="ball", radius=self:getTalentRange(t)}, a.x, a.y,
	    function(px, py)
	       local actor = game.level.map(px, py, Map.ACTOR)
	       if actor and self:reactionToward(actor) < 0 then
		  list[#list+1] = actor
	       end
	 end)
      end
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.type == "elemental" then
	       apply(act)
	    end
	 end
      else
	 for uid, act in pairs(game.level.entities) do
	    if act.summoner and act.summoner == self and act.type == "elemental" then
	       apply(act)
	    end
	 end
      end

      -- determine damage for this turn
      local dam = 0
      if #list > 0 then
	 dam = self:spellCrit(t.getDam(self, t))
      end

      -- Hit a random enemy
      local nb = 0
      while #list > 0 and nb < 2 do
	 local a = rng.tableRemove(list)			
	 meteor(self, a, a.x, a.y, dam)	 
	 nb = nb + 1
      end   
   end,

  
   info = function(self, t)
      return ([[Channeled through the staff, your meteor storms are wilder and more destructive.
		While Meteor Storm is active, two additional smaller meteors will fall each turn on an enemy near you or your summons, dealing %0.2f meteor damage. Enemies are more likely to be struck if there are multiple party members near them.
		The effects increase with spellpower.]])
	 :format(damDesc(self, DamageType.METEOR, t.getDam(self, t)))

   end,
}
