local Object = require "mod.class.Object"

function getAspectResists(self, t)
   return self:combatTalentScale(t, 2, 25)
end

newTalent{
   name = "Venomous Strikes", short_name = "REK_WYRMIC_VENM",
   type = {"wild-gift/wyrm-venom", 1},
   require = {
      stat = { wil=function(level) return 10 + (level-1) * 4 end },
      level = function(level) return 0 + (level-1) * 3 end,
      special =
	 {
	    desc="One level in Prismatic Blood per additional aspect",
	    fct=function(self) 
	       return self:getTalentLevelRaw(self.T_REK_WYRMIC_MULTICOLOR_BLOOD) > numAspects(self) or self:knowTalent(self.T_REK_WYRMIC_VENM)
	    end
	 },
   },
   points = 5,
   on_learn = function(self, t)
      if self.rek_wyrmic_dragon_damage == nil then
	 self.rek_wyrmic_dragon_damage = {
	    name="Nature",
	    nameDrake=(DamageType:get(DamageType.NATURE).text_color or "").."Venom Drake#LAST#",
	    nameStatus="Poisoned",
	    damtype=DamageType.NATURE,
	    status=DamageType.REK_WYRMIC_VENM,
	    talent=self.T_REK_WYRMIC_VENM
	 }
      end
   end,
   on_unlearn = function(self, t) onUnLearnAspect(self) end,
   mode = "sustained",
   cooldown = 10,
   tactical = { BUFF = 2 },
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists,
   getDamageStinger = function(self, t) return 8 + self:combatTalentStatDamage(t, "cun", 10, 60) * 0.6 end,
   getIntensify = function(self, t) return self:combatTalentMindDamage(t, 0.3, 1.2) end,
   getRange = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 4.5)) end,
   getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5)) end,
   passives = function(self, t, p)
      local resist = t.getResists(self, t)
      self:talentTemporaryValue(p, "resists", {[DamageType.NATURE] = resist})
   end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7)) end,
   getChance = function(self,t) return math.min(100, self:combatTalentScale(t, 20, 100)) end,
   ApplyPoisons = function(self, t, target, weapon) -- apply poison(s) to a target
      if self:knowTalent(self.T_REK_WYRMIC_VENM_BYPASS) then -- apply vulnerability first
	 target:setEffect(target.EFF_REK_WYRMIC_VULNERABILITY_POISON, t.getDuration(self, t), {src=self, power=self:callTalent(self.T_REK_WYRMIC_VENM_BYPASS, "getReduction") , apply_power=self:combatAttack(), no_ct_effect=true})
      end
      if target:canBe("poison") then
	 local dam = t.getDamageStinger(self,t)
	 target:setEffect(target.EFF_DEADLY_POISON, t.getDuration(self, t),
			  {
			     src=self, power=dam, max_power=dam*4,
			     insidious=0,
			     crippling=0,
			     numbing=0,
			     leeching=0,
			     volatile=0,
			     apply_power=self:combatAttack(), no_ct_effect=true})
	 if self.vile_poisons then
	    for tid, val in pairs(self.vile_poisons) do -- apply any special procs
	       local tal = self:getTalentFromId(tid)
	       if tal and tal.proc then
		  tal.proc(self, tal, target, weapon)
	       end
	    end
	 end
      end
   end,
   
   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
      local chance = t.getChance(self,t)
      if self:hasDualWeapon() then
	 chance = chance * 0.5
      end
      if target and hitted and rng.percent(chance) then
	 t.ApplyPoisons(self, t, target, weapon)
      end
   end,
   callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam)
      local chance = t.getChance(self,t)
      if target and hitted and rng.percent(chance) then
	 t.ApplyPoisons(self, t, target, weapon)
      end
   end,
   
   activate = function(self, t)
      local ret = {}
      local h1x, h1y = self:attachementSpot("hand1", true) if h1x then self:talentParticles(ret, {type="apply_poison", args={x=h1x, y=h1y}}) end
      local h2x, h2y = self:attachementSpot("hand2", true) if h2x then self:talentParticles(ret, {type="apply_poison", args={x=h2x, y=h2y}}) end
      self:talentParticles(ret, {type="apply_poison", args={}})
      return ret
   end,
   deactivate = function(self, t, p)
      return true
   end,
   
   info = function(self, t)
      local resist = t.getResists(self, t)
      local dam = t.getDamageStinger(self, t)
      return ([[You can take on the power of Venom Wyrms using Prismatic Blood.  You will gain %d%% nature resistance. 

While sustained, you coat your weapons and ammo in venom, giving them a %d%% chance to expose enemies to deadly poison (%d damage over %d turns (#SLATE#Accuracy vs. Physical#LAST#), stacking up to 4 times).  The chance is reduced by 75%% if you have a shield, 50%% if you are wielding 2 weapons.

Venom is Nature damage that can inflict Crippling Poison (#SLATE#Mindpower vs. Physical#LAST#).  It deals 50%% of the listed damage up-front, and 75%% as a poison over the next three turns.

Cunning: Improves on-hit poison damage
]]):format(resist, t.getChance(self,t), t.getDuration(self, t), dam)
   end,
}

newTalent{
   name = "Excruciate", short_name = "REK_WYRMIC_VENM_PIN",
   type = {"wild-gift/wyrm-venom", 2},
   require = {
      stat = { wil=function(level) return 22 + (level-1) * 2 end },
      level = function(level) return 10 + (level-1) end,
      special =
	 {
	    desc="Higher Aspect Abilities unlocked",
	    fct=function(self) 
	       return self:knowTalent(self.T_REK_WYRMIC_FIRE_HEAL)
		  or self:knowTalent(self.T_REK_WYRMIC_COLD_WALL)
		  or self:knowTalent(self.T_REK_WYRMIC_ELEC_SHOCK)
		  or self:knowTalent(self.T_REK_WYRMIC_SAND_BURROW)
		  or self:knowTalent(self.T_REK_WYRMIC_ACID_AURA)
		  or self:knowTalent(self.T_REK_WYRMIC_VENM_PIN)
		  or self.unused_talents_types >= 1
	    end
	 },
   },
   points = 5,
   equilibrium = 15,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 0,
   requires_target = true,
   tactical = { DISABLE = 2 },
   getIntensify = function(self, t) return self:combatTalentMindDamage(t, 0.5, 1.8) end,
   getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5)) end,
   on_learn = function(self, t) onLearnHigherAbility(self) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self) end,
   action = function(self, t)
      local tg = {type="ball", nolock=true, range=0, radius = 5, friendlyfire=false}     
      self:project(tg, self.x, self.y,
		   function(px, py)
		      local target = game.level.map(px, py, engine.Map.ACTOR)
		      if not target then
			 return
		      end
		      for eff_id, p in pairs(target.tmp) do
			 local e = target.tempeffect_def[eff_id]
			 if e.subtype.poison and p.power and e.status == "detrimental" then
			    p.power = p.power * (1+t.getIntensify(self, t))
			    if target:canBe("pin") then
			       target:setEffect(target.EFF_PINNED, t.getDur(self, t),
						{apply_power=999})
			    else
			       game.logSeen(target, "%s resists the pin!",
					    target.name:capitalize())
			    end
			 end
		      end
		   end
      )
      return true
   end,
   info = function(self, t)
      local desc = ([[Trigger a slow-acting paralytic within your venom.  Poisoned foes within range 5 are pinned for %d turns (no save) and have the remaining damage of their poisons increased by %d%%.

Mindpower: Improves poison intensification
]]):format(t.getDur(self, t), t.getIntensify(self, t)*100)
      if not hasHigherAbility(self) then
	 return desc..[[

#YELLOW#Learning this talent will unlock the higher aspect abilities in all 6 elements at the cost of a category point.  You still require Prismatic Blood to learn more aspects. #LAST#]]
      else
	 return desc
      end 
   end,
}

newTalent{
   name = "Toxic Shock", short_name = "REK_WYRMIC_VENM_SHOCK",
   type = {"wild-gift/wyrm-venom", 3},
   require = gifts_req_high2,
   points = 5,
   mode = "passive",
   getPercent = function(self, t)
      return 200 - math.min(150, self:combatTalentScale(t, 50, 125))
   end,
   getDuration = function(self, t)
      return self:combatTalentScale(t, 2, 6)
   end,

   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      if target:hasEffect(self.EFF_DEADLY_POISON) then
	 target:setEffect(target.EFF_REK_WYRMIC_TOXIC_WATCH, 10, {src=self, power=t.getDuration(self, t), threshold=t.getPercent(self, t) * 0.01})
      end
   end,
   
   info = function(self, t)
      local threshold = t.getPercent(self, t)
      local dur = t.getDuration(self, t)
      return ([[As your venom accumulates, your enemies' bodies undergo catastrophic failure.
When the remaining damage of their poison is at least %d %% of their remaining health, they suffer toxic shock.
All enemies have their resistance to damage reduced by 20%%.
Unique enemies and weaker are also stunned for %d turns.
Normal and weaker enemies may also be instantly slain.]]):format(threshold, dur)
   end,
}

newTalent{
   name = "Penetrating Venom", short_name = "REK_WYRMIC_VENM_BYPASS",
   type = {"wild-gift/wyrm-venom", 4},
   require = gifts_req_high3,
   points = 5,
   mode = "passive",
   getReduction = function(self, t)
      return self:combatTalentScale(t, 25, 50)
   end,
   info = function(self, t)
      return ([[Whenever you would apply your Venom, you add a destabilizing agent that makes the target vulnerable to poison. This reduces nature damage resistance by 10%% and poison immunity by %d%%.]]):
	 format(t.getReduction(self, t))
   end,
}
