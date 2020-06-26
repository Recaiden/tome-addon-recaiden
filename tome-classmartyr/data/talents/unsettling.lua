newTalent{
   name = "Unnerve", short_name = "REK_MTYR_UNSETTLING_UNNERVE",
   type = {"demented/unsettling", 1},
   require = martyr_req1,
   points = 5,
   insanity = 10,   
   cooldown = 3,
   range = function(self, t)
      local weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeapon()
      if not (weapon and weapon.combat) and not (pf_weapon and pf_weapon.combat) then 
         if self:hasArcheryWeaponQS() then
            weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeaponQS()
         else
            return 3
         end
      end
      local br = (self.archery_bonus_range or 0)
      return math.max(weapon and br + weapon.combat.range or 6,
         offweapon and offweapon.combat and br + offweapon.combat.range or 0,
         pf_weapon and pf_weapon.combat and br + pf_weapon.combat.range or 0,
         self:attr("archery_range_override") or 0)
   end,
   requires_target = true,
   tactical = { DISABLE = { confusion = 2 } },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   getPower = function(self, t) return self:combatTalentScale(t, 20, 50, 0.75) end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.1) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, x, y = self:canProject(tg, x, y)
      local target = game.level.map(x, y, Map.ACTOR)
      if not target then return end

      local power = t.getPower(self, t)
      local dam = 0
      local powerlessness = 0
      --DoT
      if self:knowTalent(self.T_REK_MTYR_UNSETTLING_UNHINGE) then
         local t2 = self:getTalentFromId(self.T_REK_MTYR_UNSETTLING_UNHINGE)
         dam = self:mindCrit(t2.getDamage(self, t2))
         if amSane(self) then
            powerlessness = t2.getPowerDrain(self, t2)
         end
      end
      
      if target:canBe("confusion") then   
         -- Main effct
         target:setEffect(target.EFF_REK_MTYR_UNNERVE, t.getDuration(self,t), {power=t.getPower(self, t) or 30, damage=dam, powerlessness=powerlessness, src=self})
      elseif self:knowTalent(self.T_REK_MTYR_UNSETTLING_UNINHIBITED) then
         local t4 = self:getTalentFromId(self.T_REK_MTYR_UNSETTLING_UNINHIBITED)
         local diminishment = t4.getReduction(self, t4)
         power = power * (100 - diminishment) / 100
         dam = dam * (100 - diminishment) / 100
         powerlessness = powerlessness * (100 - diminishment) / 100
         target:setEffect(target.EFF_REK_MTYR_UNNERVE, t.getDuration(self,t), {power=power, damage=dam, powerlessness=powerlessness, src=self})
      else
         game.logSeen(target, "%s resists the revelation!", target.name:capitalize())
      end

      -- sanityBonus
      if amSane(self) then
         if target and target:hasEffect(target.EFF_REK_MTYR_UNNERVE) then
            self:attackTarget(target, nil, t.getDamage(self, t), true, true)
         end
      end
      
      return true
   end,
   
   info = function(self, t)
      return ([[Inform an enemy about the true bleak vistas of reality, confusing them for %d turns (%d power).  The range of this talent will increase with the firing range of a ranged weapon in your main set or offset (but is always at least 3).

#ORANGE#Sanity Bonus:#LAST# Take advantage of their moment of realization to throw a sucker punch or other sneak attack, dealing %d%% unarmed damage.
]]):format(t.getDuration(self, t), t.getPower(self, t), 100*t.getDamage(self, t))
   end,
}

newTalent{
   name = "Unhinge", short_name = "REK_MTYR_UNSETTLING_UNHINGE",
   type = {"demented/unsettling", 2},
   require = martyr_req2,
   points = 5,
   mode = "passive",
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 135) end,
   getPowerDrain = function(self, t) return self:combatTalentMindDamage(t, 5, 36) end,
   info = function(self, t)
      return ([[Your Unnerve effect tears at the victim's mind, dealing %d mind damage per turn.
Mindpower: improves damage

#ORANGE#Sanity Bonus:#LAST# Unnerve also reduces the victim's physical, spell, and mind power by %d.
Mindpower: improves stat reduction]]):format(t.getDamage(self, t), t.getPowerDrain(self, t))
   end,
}

newTalent{
   name = "Unveil", short_name = "REK_MTYR_UNSETTLING_UNVEIL",
   type = {"demented/unsettling", 3},
   require = martyr_req3,
   points = 5,
   cooldown = 8,
   insanity = 10,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 3.2) end,
   getExtension = function(self, t) return self:combatTalentScale(t, 3, 5) end,
   range = 0,
   radius = 10,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local damage = t.getDamage(self, t)
      
      self:project(tg, self.x, self.y,
                   function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self and target:hasEffect(target.EFF_REK_MTYR_UNNERVE) then
			 self:attackTarget(target, DamageType.MIND, damage, true, true)
		      end
                   end
                  )
      self:project(tg, self.x, self.y,
                   function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self and target:hasEffect(target.EFF_REK_MTYR_UNNERVE) then
                         local e2 = target.tmp[target.EFF_REK_MTYR_UNNERVE]
                         e2.dur = e2.dur + t.getExtension(self, t)
		      end
                   end
                  )
      return true
   end,
   info = function(self, t)
      return ([[Reveal a terrible secret and crush the psyches of your listeners, attacking all Unnerved targets within range 10 for %d%% unarmed damage (as mind damage).

#ORANGE#Sanity Bonus:#LAST# And then increase the duration of their Unnerve effect by %d turns.
]]):format(100*t.getDamage(self, t), t.getExtension(self, t))
   end,
}

newTalent{
   name = "Uninhibited", short_name = "REK_MTYR_UNSETTLING_UNINHIBITED",
   type = {"demented/unsettling", 4},
   require = martyr_req4,
   points = 5,
   mode = "passive",
   getReduction = function(self, t) return math.max(10, self:combatTalentScale(t, 70, 25)) end,
   info = function(self, t)
      return ([[Your Unnerve ability can penetrate confusion immunity, with %d%% reduced effectiveness. 
]]):format(t.getReduction(self, t))
   end,
}