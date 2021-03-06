newTalentType{ type="undead/wight", name = "wight", is_spell=true, generic = true, description = "The various racial bonuses an undead character can have."}

local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

newTalent{
   short_name="REK_WIGHT_CYCLE_ELEMENT",
   name = "Alter Fury Element",
   type = {"undead/other", 1},
   require = undeads_req1,
   points = 1,
   no_energy = true,
   cooldown = 0,
   action = function(self, t)
      if self.rek_wight_damage == DamageType.FIRE then
         self.rek_wight_damage = DamageType.LIGHTNING
      elseif self.rek_wight_damage == DamageType.LIGHTNING  then
         self.rek_wight_damage = DamageType.COLD
      else
         self.rek_wight_damage = DamageType.FIRE
      end
      return true
   end,
   info = function(self, t)
      local damtype = DamageType.FIRE
      if self.rek_wight_damage then
         damtype = self.rek_wight_damage
      end
      
      local str = DamageType:get(damtype).name
      return ([[Rotate the type of damage you do with Fury of the Wilds between Fire, Lightning, and Cold.  Currently: %s
]]):format(str)
   end,
}

newTalent{
   short_name="REK_WIGHT_FURY",
   name = "Fury of the Wild",
   type = {"undead/wight", 1},
   require = undeads_req1,
   points = 5,
   no_energy = true,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end,
   tactical = { ATTACK = 2 },
   on_learn = function(self, t)
      self:learnTalent(self.T_REK_WIGHT_CYCLE_ELEMENT, 1)
   end,
   on_unlearn = function(self, t)
      self:unlearnTalent(self.T_REK_WIGHT_CYCLE_ELEMENT, 1)
   end,
   getDamage = function(self, t) return 10 + math.max(self:getMag(), self:getWil()) end,
   getStats = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 10, 0.75)) end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_WIGHT_FURY, 8, {power=t.getDamage(self,  t)})
      return true
   end,
   info = function(self, t)
      return ([[For the next 5 turns, whenever you damage an enemy, you will unleash a radius 1 burst of %d elemental damage (once per enemy per turn).
The damage improves with the stronger of your magic or willpower.

#{italic}#Death and destruction, we must admit, are part of nature...#{normal}#]]):format(t.getDamage(self, t), t.getStats(self, t))
   end,
}

newTalent{
   short_name = "REK_WIGHT_DRAIN",
   name = "Draining Presence",
   type = {"undead/wight", 2},
   require = undeads_req2,
   points = 5,
   mode = "passive",
   on_learn = function(self, t)
      local level = self:getTalentLevelRaw(self.T_REK_WIGHT_DRAIN)
      if level == 1 then
         self.old_faction_cloak = self.faction
         self.faction = "allied-kingdoms"
         if self.descriptor and self.descriptor.race and self:attr("undead") then self.descriptor.fake_race = "Human" end
         if self.descriptor and self.descriptor.subrace and self:attr("undead") then self.descriptor.fake_subrace = "Cornac" end
         if self.player then engine.Map:setViewerFaction(self.faction) end
      end
   end,
   on_unlearn = function(self, t)
      local level = self:getTalentLevelRaw(self.T_REK_WIGHT_DRAIN)
      if level == 0 then
         if self.permanent_undead_cloak then return end
         self.faction = self.old_faction_cloak
         if self.descriptor and self.descriptor.race and self:attr("undead") then self.descriptor.fake_race = nil end
         if self.descriptor and self.descriptor.subrace and self:attr("undead") then self.descriptor.fake_subrace = nil end
         if self.player then engine.Map:setViewerFaction(self.faction) end
      end
   end,
   getFearPower = function(self, t) return -self:combatTalentScale(t, 15, 40) end,
   getImmune = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 17, 9)) end,
   callbackOnActBase = function (self, t)
      self:project(
         {type="ball", radius=5}, self.x, self.y,
         function(px, py)
            local actor = game.level.map(px, py, Map.ACTOR)
            local apply_power = math.max(self:combatPhysicalpower(), self:combatSpellpower(), self:combatMindpower())
            if actor and self:reactionToward(actor) < 0 then
               if actor:hasEffect(actor.EFF_REK_WIGHT_FEARLESS) then return end
               if self:checkHit(apply_power, actor:combatMentalResist(), 0, 95, 5) then
                  actor:setEffect(actor.EFF_REK_WIGHT_DESPAIR, 4, {statChange = t.getFearPower(self, t), apply_power=apply_power})
               else
                  actor:setEffect(actor.EFF_REK_WIGHT_FEARLESS, t.getImmune(self, t), {})
               end
            end
         end)
   end,
   info = function(self, t)
      return ([[Each round, enemies within range 5 may (#SLATE#Highest power vs. Mental#LAST#) despair of surviving, reducing their saves, defense, and armor by %d.  If they successfully resist, they are immune to your draining presence for %d turns.

Learning this talent gives you enough control over your ghostly form to pass as a human.

#{italic}#Merely being close to these figments of death causes one's life force to sputter and fade...#{normal}# 
]]):format(t.getFearPower(self, t), t.getImmune(self, t))
   end,
}

newTalent{
   short_name = "REK_WIGHT_DODGE",
   name = "Ephemeral",
   type = {"undead/wight", 3},
   require = undeads_req3,
   points = 5,
   cooldown = 10,
   mode = "passive",
   --TODO make it a sustain
   getEvasion = function(self, t)
      return math.min(self:combatTalentScale(t, 5, 190) / 10 + 5, 30)
   end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "cancel_damage_chance", t.getEvasion(self, t))
   end,
   info = function(self, t)
      return ([[You have a %d%% chance to negate any source of incoming damage.

Learning this talent reestablishes a fragment of your connection to nature, allowing you to use a single Infusion.

#{italic}#Blows that should have been telling seem to slip right through them...#{normal}#]]):format(t.getEvasion(self, t))
   end,
}

newTalent{
   short_name = "REK_WIGHT_GHOST_VISION",
   name = "Haunt",
   type = {"undead/wight", 4},
   require = undeads_req4,
   points = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 30, 17)) end,
   no_energy = true, --don't make this a function, tie it to the OTHER buff
   tactical = { ESCAPE = 1, CLOSEIN = 1 },
   getDuration = function(self, t) return 1 end,
   getFearDuration = function(self, t) return 4 end,
   getFearPower = function(self, t) return -self:combatTalentScale(t, 15, 40) end,
   radius = function(self, t) return 10 end,
   action = function(self, t)
      local rad = self:getTalentRadius(t)
      self:setEffect(self.EFF_REK_WIGHT_VISION, t.getDuration(self, t), {
			range = rad,
			actor = 1,
			level = self:getTalentLevelRaw(t)
      })
      return true
   end,
   info = function(self, t)
      return ([[Peer into the spirit world to sense all enemies within range 10.  Then, you may activate this talent again to disperse your spectral body and reform next to a targeted enemy, draining their energy in the process.
Sensing enemies does not take a turn, but moving to them does.

#{italic}#...faded and incorporeal at their edges, while strange lights dance where their eyes should remain....#{normal}#]]):format(t.getFearDuration(self,t), -1*t.getFearPower(self, t))
   end,
}

newTalent{
   name = "Jaunt", short_name = "REK_WIGHT_GHOST_VISION_JUMP",
   type = {"undead/other", 1},
   points = 5,
   range = function(self, t) return 10 end,
   tactical = { CLOSEIN = 2 },
   requires_target = true,
   is_melee = true,
   is_teleport = true,
   target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
   getFearPower = function(self, t)
      return -self:combatTalentScale(t, 15, 40)
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      if not self:teleportRandom(x, y, 0) then game.logSeen(self, "You can't appear there!") return nil end       
      -- effect
      if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
         actor.energy.value = actor.energy.value - 250
         self.energy.value = self.energy.value + 250
      end

      if self:hasEffect(self.EFF_REK_WIGHT_VISION) then
	 self:removeEffect(self.EFF_REK_WIGHT_VISION)
      end
      
      return true
   end,
   
   info = function(self, t)
      return ([[Step through the spirit world to appear next to an enemy and steal 1/4 of a turn from them.]]):format()
   end,
}