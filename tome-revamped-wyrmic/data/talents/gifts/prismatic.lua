local Dialog = require "engine.ui.Dialog"

function table.shallow_copy(t)
   local t2 = {}
   if t then
      for k,v in pairs(t) do
	 t2[k] = v
      end
   end
  return t2
end

--Configuration Tools
newTalent{
   name = "Change Aspect", short_name = "REK_WYRMIC_COLOR_PRIMARY",
   type = {"wild-gift/other", 1},
   points = 1,
   cooldown = 15,
   no_energy = true,
   no_npc_use = true,
   action = function(self, t)
      local possibles = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_BLOOD, "getOptions")
      local aspect = self:talentDialog(Dialog:listPopup("Primary Aspect", "Choose an aspect to bring forth:", possibles, 400, 400, function(item) self:talentDialogReturn(item) end))
      if aspect then
         if self:knowTalent(self.T_REK_WYRMIC_MULTICOLOR_BLOOD) and aspect ~= self.rek_wyrmic_dragon_damage then
            local speed = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_BLOOD, "getPassiveSpeed")
            self:setEffect(self.EFF_REK_WYRMIC_PRISMATIC_SPEED, 5, {power=speed})
            game:playSoundNear(self, "talents/devouringflame")
         end
	 self.rek_wyrmic_dragon_damage = aspect
	 self:updateTalentPassives(self.T_REK_WYRMIC_MULTICOLOR_BLOOD)
      end
      
      return true
   end,
   info = function(self, t)
      local name = self.rek_wyrmic_dragon_damage
      if name then
	 name = name.name
      else
	 name = "None"
      end
      return ([[You can activate this talent to change which drake aspect to bring forth, altering the damage type and status effect your abilities inflict.
Current Aspect: %s]]):format(name)
   end,
}

-- Real talents
newTalent{
   name = "Prismatic Blood", short_name = "REK_WYRMIC_MULTICOLOR_BLOOD",
   type = {"wild-gift/prismatic-dragon", 1},
   require = color_req_1,
   points = 5,
   mode = "passive",
   -- 1 aspect per rank, plus one per weird dragon type unlocked
   getNumAspects = function(self, t)
      local num = self:getTalentLevelRaw(t)
      if self:knowTalent(self.T_RAZE) then
	 num = num +1
      end
      if self:knowTalent(self.T_TENTACLED_WINGS) then
	 num = num +1
      end
      return num
   end,
   getOptions = function(self, t)
      local possibles = {}
      -- Add 6 basic dragon types if you've learned their Aspect talent
      if self:knowTalent(self.T_REK_WYRMIC_FIRE) then
	 possibles[#possibles+1] = {
	    name="Fire",
	    nameStatus="Flameshocked",
	    nameDrake=(DamageType:get(DamageType.FIRE).text_color or "").."Fire Drake#LAST#",
	    damtype=DamageType.FIRE,
	    status=DamageType.REK_WYRMIC_FIRE,
	    talent=self.T_REK_WYRMIC_FIRE
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_COLD) then
	 possibles[#possibles+1] = {
	    name="Cold",
	    nameStatus="Frozen",
	    nameDrake=(DamageType:get(DamageType.COLD).text_color or "").."Cold Drake#LAST#",
	    damtype=DamageType.COLD,
	    status=DamageType.REK_WYRMIC_COLD,
	    talent=self.T_REK_WYRMIC_COLD
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_ELEC) then
	 possibles[#possibles+1] = {
	    name="Lightning",
	    nameStatus="Dazed",
	    nameDrake=(DamageType:get(DamageType.LIGHTNING).text_color or "").."Storm Drake#LAST#",
	    damtype=DamageType.LIGHTNING,
	    status=DamageType.REK_WYRMIC_ELEC,	    
	    talent=self.T_REK_WYRMIC_ELEC
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_SAND) then
	 possibles[#possibles+1] = {
	    name="Physical",
	    nameStatus="Blinded",
	    nameDrake=(DamageType:get(DamageType.PHYSICAL) or "").text_color.."Sand Drake#LAST#",
	    damtype=DamageType.PHYSICAL,
	    status=DamageType.REK_WYRMIC_SAND,
	    talent=self.T_REK_WYRMIC_SAND
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_ACID) then
	 possibles[#possibles+1] = {
	    name="Acid",
	    nameStatus="Disarmed",
	    nameDrake=(DamageType:get(DamageType.ACID).text_color or "").."Acid Drake#LAST#",
	    damtype=DamageType.ACID,
	    status=DamageType.REK_WYRMIC_ACID,
	    talent=self.T_REK_WYRMIC_ACID
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_VENM) then
	 possibles[#possibles+1] = {
	    name="Nature",
	    nameDrake=(DamageType:get(DamageType.NATURE).text_color or "").."Venom Drake#LAST#",
	    nameStatus="Poisoned",
	    damtype=DamageType.NATURE,
	    status=DamageType.REK_WYRMIC_VENM,
	    talent=self.T_REK_WYRMIC_VENM
	 }
      end
      -- Add unusual drake types if you know the first talent in the tree
      if self:knowTalent(self.T_RAZE) then
	 possibles[#possibles+1] = {
	    name="Darkness",
	    nameDrake=DamageType:get(DamageType.DARKNESS).text_color.."Undead Drake#LAST#",
	    nameStatus="Doomed",
	    damtype=DamageType.DARKNESS,
	    status=DamageType.REK_WYRMIC_DARK,
	    talent=self.T_RAZE
	 }
      end
      if self:knowTalent(self.T_TENTACLED_WINGS) then
	 possibles[#possibles+1] = {
	    name="Blight",
	    nameDrake=DamageType:get(DamageType.BLIGHT).text_color.."Scourge Drake#LAST#",
	    nameStatus="Diseased",
	    damtype=DamageType.BLIGHT,
	    status=DamageType.REK_CORRUPTED_BLOOD,
	    talent=self.T_REK_TENTACLED_WINGS
	 }
      end
      return possibles
   end,

   getPassiveSpeed = function(self, t) return (self:combatTalentScale(t, 2, 10, 0.5)/100) end,
   -- Chromatic Fury hook
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "combat_physspeed", t.getPassiveSpeed(self, t))
      self:talentTemporaryValue(p, "combat_mindspeed", t.getPassiveSpeed(self, t))
      self:talentTemporaryValue(p, "combat_spellspeed", t.getPassiveSpeed(self, t))
      
      if self:knowTalent(self.T_REK_WYRMIC_MULTICOLOR_FURY) then
	 local dam_inc = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_FURY, "getDamageIncrease")
	 local resists_pen = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_FURY, "getResistPen")
	 local aspect = self.rek_wyrmic_dragon_damage
	 self:talentTemporaryValue(p, "inc_damage", {[aspect.damtype] = dam_inc})
	 self:talentTemporaryValue(p, "resists_pen", {[aspect.damtype] = resists_pen})
      end
   end,

   info = function(self, t)
      local speed = t.getPassiveSpeed(self, t)
      return ([[Taking lessons from every color of wyrm, you move with serpentine swiftness. Your Physical, Mental, and Spell attack speeds are increased by %d%%.  This bonus is doubled for 5 turns when you change your elemental aspect.]]):format(speed*100)
   end,
}


newTalent{
   name = "Prismatic Burst", short_name = "REK_WYRMIC_PRISMATIC_BURST",
   type = {"wild-gift/prismatic-dragon", 2},
   require = gifts_req_high2,
   points = 5,
   no_energy = true,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 13, 8)) end,
   equilibrium = function(self, t) return math.floor(t.cooldown(self, t)/3) end,
   tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1, POISON = 1 } },
   getBurstDamage = function(self, t) return self:combatTalentMindDamage(t, 50, 230) end,
   getCost = function(self, t) return math.floor(t.cooldown(self, t)/3) end,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
   action = function(self, t)
      if self:hasEffect(self.EFF_REK_WYRMIC_PRISMATIC_BURST) then return false end
      self:setEffect(self.EFF_REK_WYRMIC_PRISMATIC_BURST, 3, {power=t.getBurstDamage(self, t), radius = self:getTalentRadius(t)})
      return true
   end,
   info = function(self, t)
      local burstdamage = t.getBurstDamage(self, t)
      local radius = self:getTalentRadius(t)
      local cost = t.getCost(self, t)
      return ([[You charge your body with raw, chaotic elemental damage. The next time you damage an enemy (within 2 turns), you will unleash a burst of one of your elements at random, dealing %0.2f damage in radius %d.

Mindpower: Improves damage.]]):format(burstdamage, radius)
   end,
}


newTalent{
   name = "Wyrmic Guile", short_name = "REK_WYRMIC_MULTICOLOR_GUILE",
   image = "talents/wyrmic_guile.png",
   type = {"wild-gift/prismatic-dragon", 3},
   require = gifts_req_high3,
   points = 5,
   mode = "passive",
   resistKnockback = function(self, t) return self:combatTalentLimit(t, 1, .17, .5) end,
   resistBlindStun = function(self, t) return self:combatTalentLimit(t, 1, .07, .25) end,
   getStat = function(self, t) return self:combatTalentScale(t, 1, 12) end,	
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "knockback_immune", t.resistKnockback(self, t))
      self:talentTemporaryValue(p, "stun_immune", t.resistBlindStun(self, t))
      self:talentTemporaryValue(p, "blind_immune", t.resistBlindStun(self, t))
      self:talentTemporaryValue(p, "inc_stats", {[self.STAT_STR] = t.getStat(self, t)})
      self:talentTemporaryValue(p, "inc_stats", {[self.STAT_WIL] = t.getStat(self, t)})
   end,
   info = function(self, t)
      return ([[You have the might and mettle of a Wyrm.
		Your Strength and Willpower are increased by %d, you gain %d%% knockback resistance, and your blindness and stun resistances are increased by %d%%.]]):format(2*self:getTalentLevelRaw(t), 100*t.resistKnockback(self, t), 100*t.resistBlindStun(self, t))
   end,
}

-- Chromatic Fury
newTalent{
   name = "Chromatic Fury", short_name = "REK_WYRMIC_MULTICOLOR_FURY",
   type = {"wild-gift/prismatic-dragon", 4},
   require = gifts_req_high4,
   points = 5,
   mode = "passive",

   CDreduce = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 1, 3)) end,
   getDamageIncrease = function(self, t) return self:combatTalentScale(t, 2.5, 10) end,
   getResistPen = function(self, t) return self:combatTalentLimit(t, 100, 5, 20) end,
   info = function(self, t)
      return ([[You have gained the full power of the multihued dragon and become attuned to the draconic elements.  Your primary aspect will also grant you %0.1f%% increased damage and %0.1f%% resistance penetration with its element.
Whenever you change aspect, the cooldowns of Dragon's Breath and Overwhelm will be reduced by %d.]])
	 :format(t.getDamageIncrease(self, t), t.getResistPen(self, t), t.CDreduce(self, t))
  end,
}
