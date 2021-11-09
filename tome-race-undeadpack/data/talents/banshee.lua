newTalent{
   short_name="REK_BANSHEE_WAIL",
   name = "Deathly Wail",
   type = {"undead/banshee", 1},
   require = undeads_req1,
   points = 5,
   no_energy = true,
   tactical = { DISABLE = { confusion = 3, silence = 3 } },
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
   
   statBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 10, 0.75)) end,
   getConfuse = function(self, t) return math.min(50, self:combatStatScale("wil", 30, 60)) end,
   
   range = 10,
   direct_hit = true,
   requires_target = true,
   tactical = { DISABLE = { confusion = 3 } },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false} end,

   passives = function(self, t, p)
      self:talentTemporaryValue(p, "inc_stats", {[self.STAT_DEX]=t.statBonus(self, t)})
      self:talentTemporaryValue(p, "inc_stats", {[self.STAT_WIL]=t.statBonus(self, t)})
   end,
   
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.REK_BANSHEE_WAIL, {dur=5, dam=t.getConfuse(self, t)}, {type="manathrust"})
      game:playSoundNear(self, "talents/rek_banshee_scream")
      return true
   end,
   info = function(self, t)
      return ([[Let out a maddening shriek, which attempts (#SLATE#Highest Power vs. Mental#LAST#) to confuse (%d%% confuse power) the target creature for 5 turns.
The confusion improves with your willpower.

Passively improves your undead body and vengeful spirit, increasing Dexterity and Willpower by %d.]]):tformat(t.getConfuse(self, t), t.statBonus(self, t))
   end,
}

newTalent{
   short_name = "REK_BANSHEE_RESIST",
   name = "Graveborn",
   type = {"undead/banshee", 2},
   require = undeads_req2,
   points = 5,
   mode = "passive",
   getResist = function(self, t) return 10 + self:combatTalentScale(t, 3, 20) end,
   getCap = function(self, t) return self:combatTalentScale(t, 5, 14) end,

   passives = function(self, t, p)
      self:talentTemporaryValue(p, "resists",{
				   [DamageType.COLD] = t.getResist(self, t),
				   [DamageType.DARKNESS] = t.getResist(self, t),
				   [DamageType.BLIGHT] = t.getResist(self, t)
      })
      self:talentTemporaryValue(p, "resists_cap", {
				   [DamageType.COLD] = t.getCap(self, t),
				   [DamageType.DARKNESS] = t.getCap(self, t),
				   [DamageType.BLIGHT] = t.getCap(self, t)
      })
   end,
   info = function(self, t)
      return ([[The journey into death and back has hardened you against many mortal frailties, providing %d%% resistance to cold, darkness, and blight damage, and increasing your maximum resistance to those elements by %d%%.  
]]):tformat(t.getResist(self, t), t.getCap(self, t))
   end,
}

newTalent{
   short_name = "REK_BANSHEE_CURSE",
   name = "Doomsayer",
   type = {"undead/banshee", 3},
   require = undeads_req3,
   points = 5,
   mode = "passive",
   cut = function(self, t) return 10 end,
   maxStacks = function(self, t) return 5 + self:getTalentLevelRaw(t) end,
   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      if dead then return end
      	if self.turn_procs.rek_banshee_curse then
	   for i = 1, #self.turn_procs.rek_banshee_curse do
	      if self.turn_procs.rek_banshee_curse[i] == target.uid then return end
	   end
	end
	self.turn_procs.rek_banshee_curse = self.turn_procs.rek_banshee_curse or {}
	self.turn_procs.rek_banshee_curse[#self.turn_procs.rek_banshee_curse+1] = target.uid
	target:setEffect(target.EFF_REK_BANSHEE_CURSE, 5, {max_stacks = t.maxStacks(self,t)}, true)
   end,

   info = function(self, t)
      return ([[Your presence cuts into the spirit of your enemies, sapping their life force.
Each time you damage an opponent (once per turn per target) or affect them with your Deathly Wail, you curse them for 5 turns, reducing their healing factor by %d%%.
This stacks up to %d times.]]):tformat(t.cut(self, t), t.maxStacks(self, t))
   end,
}

newTalent{
   short_name = "REK_BANSHEE_GHOST",
   name = "Ghostly",
   type = {"undead/banshee", 4},
   require = undeads_req4,
   points = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 30, 17)) end,
   no_energy = true,
   tactical = { ESCAPE = 1, CLOSEIN = 1 },
   speedBoost = function(self, t) return self:combatStatScale("dex", 100, 200) end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_BANSHEE_GHOSTLY, 3, {power=t.speedBoost(self, t)})
      game:playSoundNear(self, "talents/rek_banshee_ghostly")
      return true
   end,
   info = function(self, t)
      return ([[Disperse yourself into a ghostly, insubstantial form for 3 turns.  While in this ghostly form, you can walk through walls and do not need to breathe. 
During your first three steps, you will move %d%% faster.  The speed boost will improve with your Dexterity.
If you are inside a wall when the effect ends, you will move to the nearest open space.]]):tformat(t.speedBoost(self, t))
   end,
}
