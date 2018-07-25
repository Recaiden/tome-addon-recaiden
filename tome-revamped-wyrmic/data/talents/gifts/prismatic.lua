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
   name = "Primary Aspect", short_name = "REK_WYRMIC_COLOR_PRIMARY",
   type = {"wild-gift/other", 1},
   points = 1,
   no_energy = true,
   action = function(self, t)
      --local possibles = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR, "getOptions")
      local possibles = table.shallow_copy(self.rek_wyrmic_dragon_type) or {}
      local aspect = self:talentDialog(Dialog:listPopup("Primary Aspect", "Choose an aspect to bring forth:", possibles, 400, 400, function(item) self:talentDialogReturn(item) end))
      if aspect then
	 self.rek_wyrmic_dragon_damage = aspect
	 -- if self.rek_wyrmic_dragon_status == aspect then
	 --    self.rek_wyrmic_dragon_status = nil
	 -- end
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
      return ([[Activate this talent to select your Primary Aspect from among Active Aspects.  Your Primary aspect will be used by Wyrmic talents to determine damage type and status effects.
Currently: %s]]):
	 format(name)
   end,
}
-- newTalent{
--    name = "Secondary Aspect", short_name = "REK_WYRMIC_COLOR_SECONDARY",
--    type = {"wild-gift/other", 1},
--    points = 1,
--    no_energy = true,
--    action = function(self, t)
--       local possibles = table.shallow_copy(self.rek_wyrmic_dragon_type) or {}
--       if self.rek_wyrmic_dragon_damage then
-- 	 table.removeFromList(possibles, self.rek_wyrmic_dragon_damage)
--       end
--       local aspect = self:talentDialog(Dialog:listPopup("Secondary Aspect", "Choose an aspect to bring forth:", possibles, 400, 400, function(item) self:talentDialogReturn(item) end))
--       if aspect then
-- 	 self.rek_wyrmic_dragon_status = aspect
--       end
--       return true
--    end,
--    info = function(self, t)
--       local name = self.rek_wyrmic_dragon_status
--       if name then
-- 	 name = name.name
--       else
-- 	 name = "None"
--       end
--       return ([[Activate this talent to select your Secondary Aspect from among Active Aspects.  Your Secondary aspect will be used by Wyrmic talents to determine additional status effects.  It cannot be the same as your Primary Aspect.
-- Currently: %s]]):
-- 	 format(name)
--    end,
-- }

-- Real talents
newTalent{
   name = "Prismatic Blood", short_name = "REK_WYRMIC_MULTICOLOR",
   type = {"wild-gift/prismatic-dragon", 1},
   require = color_req_1,
   points = 6,
   cooldown = 10,
   no_energy = true,
   no_unlearn_last = true,
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
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,

   passives = function(self, t, p)
      local aspects = self.rek_wyrmic_dragon_type or {}
      local resist = t.getResists(self, t)
      local damtype = DamageType.FIRE
      local dam_inc = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_FURY, "getDamageIncrease")
      local resists_pen = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_FURY, "getResistPen")

      for k, element in pairs(aspects) do
	 damtype = element.damtype
	 resist = self:callTalent(element.talent, "getResists")
	 --resist = element.talent.getResists(self, element.talent)
	 if damtype == DamageType.PHYSICAL then 
	    resist = resist / 2
	 end
	 self:talentTemporaryValue(p, "resists", {[damtype] = resist})
	 if self:knowTalent(self.T_REK_WYRMIC_MULTICOLOR_FURY) then
	    self:talentTemporaryValue(p, "inc_damage", {[damtype] = dam_inc})
	    self:talentTemporaryValue(p, "resists_pen", {[damtype] = resists_pen})
	 end
      end
   end,
   getOptions = function(self, t)
      local possibles = {}
      -- Add 6 basic dragon types if you've learned their Aspect talent
      if self:knowTalent(self.T_REK_WYRMIC_FIRE) then
	 possibles[#possibles+1] = {
	    name="Fire",
	    nameStatus="Flameshocked",
	    nameDrake=DamageType:get(DamageType.FIRE).text_color.."Fire Drake#LAST#",
	    damtype=DamageType.FIRE,
	    status=DamageType.FIRE_STUN,
	    talent=self.T_REK_WYRMIC_FIRE
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_COLD) then
	 possibles[#possibles+1] = {
	    name="Cold",
	    nameStatus="Frozen",
	    nameDrake=DamageType:get(DamageType.COLD).text_color.."Cold Drake#LAST#",
	    damtype=DamageType.COLD,
	    status=DamageType.ICE,
	    talent=self.T_REK_WYRMIC_COLD
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_ELEC) then
	 possibles[#possibles+1] = {
	    name="Lightning",
	    nameStatus="Dazed",
	    nameDrake=DamageType:get(DamageType.LIGHTNING).text_color.."Storm Drake#LAST#",
	    damtype=DamageType.LIGHTNING,
	    status=DamageType.LIGHTNING_DAZE,	    
	    talent=self.T_REK_WYRMIC_ELEC
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_SAND) then
	 possibles[#possibles+1] = {
	    name="Physical",
	    nameStatus="Blinded",
	    nameDrake=DamageType:get(DamageType.PHYSICAL).text_color.."Sand Drake#LAST#",
	    damtype=DamageType.PHYSICAL,
	    status=DamageType.REK_WYRMIC_SAND,
	    talent=self.T_REK_WYRMIC_SAND
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_ACID) then
	 possibles[#possibles+1] = {
	    name="Acid",
	    nameStatus="Disarmed",
	    nameDrake=DamageType:get(DamageType.ACID).text_color.."Acid Drake#LAST#",
	    damtype=DamageType.ACID,
	    status=DamageType.ACID_DISARM,
	    talent=self.T_REK_WYRMIC_ACID
	 }
      end
      if self:knowTalent(self.T_REK_WYRMIC_VENM) then
	 possibles[#possibles+1] = {
	    name="Nature",
	    nameDrake=DamageType:get(DamageType.NATURE).text_color.."Venom Drake#LAST#",
	    nameStatus="Poisoned",
	    damtype=DamageType.NATURE,
	    status=DamageType.CRIPPLING_POISON,
	    talent=self.T_REK_WYRMIC_VENM
	 }
      end
      -- Add unusual drake types if you know the first talent in the tree
      if self:knowTalent(self.T_RAZE) then
	 possibles[#possibles+1] = {
	    name="Darkness",
	    nameDrake=DamageType:get(DamageType.DARKNESS).text_color.."Undead Drake#LAST#",
	    nameStatus="Frozen",
	    damtype=DamageType.DARKNESS,
	    status=DamageType.SAND
	 }
      end
      if self:knowTalent(self.T_TENTACLED_WINGS) then
	 possibles[#possibles+1] = {
	    name="Blight",
	    nameDrake=DamageType:get(DamageType.BLIGHT).text_color.."Scourge Drake#LAST#",
	    nameStatus="Frozen",
	    damtype=DamageType.BLIGHT,
	    status=DamageType.SAND
	 }
      end
      return possibles
   end,
   on_learn = function(self, t)
      self:learnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY, true, nil, {no_unlearn=true})
      -- if self:getTalentLevelRaw(t) > 1 then
      -- 	 self:learnTalent(self.T_REK_WYRMIC_COLOR_SECONDARY, true, nil, {no_unlearn=true})
      -- end
   end,
   action = function(self, t)
      -- Enumerate drake types
      local possibles = t.getOptions(self, t)

      self:talentDialog(require("mod.dialogs.SelectDragonAspects").new(self, possibles))
      local aspects = self.rek_wyrmic_dragon_type or {}
      
      if aspects then
	 --self.rek_wyrmic_dragon_type = aspects.aspects
	 self:updateTalentPassives(t.id)
      end
      return true
   end,
   info = function(self, t)
      --local damtype = self.rek_wyrmic_dragon_type or DamageType.FIRE
      local numAspects = t.getNumAspects(self, t)
      local damname = ""
      local str_info = ([[Through intense concentration you attune yourself to the power of dragons, passively increasing your resistances and adding special effects to your abilities.
		You can activate this talent to change which drake aspect(s) to bring forth.
		You can maintain %d aspects simultaneously.
You gain resistances, damage bonuses, damage penetration, and special bonuses from all active aspects.
Your talents inflict damage based on your Primary Aspect.
Your talents inflict status effects based on your Primary and Secondary Aspects.
		Current Aspects:
		]]):format(numAspects)

      local aspects = self.rek_wyrmic_dragon_type or {}
      for k, element in pairs(aspects) do
	 damname = DamageType:get(element.damtype).text_color..DamageType:get(element.damtype).name.."#LAST#"
	 str_info = str_info..([[  %s
]]):format(damname)
      end
      return str_info
   end,
}


newTalent{
   name = "Prismatic Burst", short_name = "REK_WYRMIC_PRISMATIC_BURST",
   image = "talents/prismatic_slash",
   type = {"wild-gift/prismatic-dragon", 2},
   require = gifts_req_high1,
   points = 5,
   random_ego = "attack",
   equilibrium = 10,
   mode = "sustained",
   no_energy = true,
   cooldown = 12,
   is_melee = true,
   tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1 } },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.6, 2.3) end,
   getBurstDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 230) end,
   getPassiveSpeed = function(self, t) return (self:combatTalentScale(t, 2, 10, 0.5)/100) end,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "combat_physspeed", t.getPassiveSpeed(self, t))
      self:talentTemporaryValue(p, "combat_mindspeed", t.getPassiveSpeed(self, t))
      self:talentTemporaryValue(p, "combat_spellspeed", t.getPassiveSpeed(self, t))
   end,

   activate = function(self, t)
      return {}
   end,
   deactivate = function(self, t, p)
      return true
   end,
   
   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
      
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      local elem = rng.table{"phys", "cold", "fire", "lightning", "acid",}
      
      if elem == "phys" then
	 local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
	 local grids = self:project(tg, x, y, DamageType.SAND, {dur=3, dam=self:mindCrit(t.getBurstDamage(self, t))})
	 game.level.map:particleEmitter(x, y, tg.radius, "ball_matter", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
	 game:playSoundNear(self, "talents/flame")
      elseif elem == "cold" then
	 local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
	 local grids = self:project(tg, x, y, DamageType.ICE_SLOW, self:mindCrit(t.getBurstDamage(self, t)))
	 game.level.map:particleEmitter(x, y, tg.radius, "ball_ice", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
	 game:playSoundNear(self, "talents/flame")
      elseif elem == "fire" then
	 local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
	 local grids = self:project(tg, x, y, DamageType.FIRE_STUN, self:mindCrit(t.getBurstDamage(self, t)))
	 game.level.map:particleEmitter(x, y, tg.radius, "ball_fire", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
	 game:playSoundNear(self, "talents/flame")
      elseif elem == "lightning" then
	 local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
	 local grids = self:project(tg, x, y, DamageType.LIGHTNING_DAZE, self:mindCrit(t.getBurstDamage(self, t)))
	 game.level.map:particleEmitter(x, y, tg.radius, "ball_lightning", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
	 game:playSoundNear(self, "talents/flame")
      elseif elem == "acid" then
	 local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
	 local grids = self:project(tg, x, y, DamageType.ACID_DISARM, self:mindCrit(t.getBurstDamage(self, t)))
	 game.level.map:particleEmitter(x, y, tg.radius, "ball_acid", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
	 game:playSoundNear(self, "talents/flame")
      end
      self:forceUseTalent(self.T_REK_WYRMIC_PRISMATIC_BURST, {ignore_energy=true})
   end,
   info = function(self, t)
      local burstdamage = t.getBurstDamage(self, t)
      local radius = self:getTalentRadius(t)
      local speed = t.getPassiveSpeed(self, t)
      return ([[Ypu charge your weapon with raw, chaotic elemental damage. Your next attack will cause a burst of one of blinding sand, disarming acid, freezing and slowing ice, dazing lightning or stunning flames, with equal odds, dealing %0.2f damage in radius %d.
		
Mindpower: Improves damage.
Talent Level: increase  Physical, Mental, and Spell attack speeds by %d%%.]]):format(burstdamage, radius, 100*speed)
   end,
}


newTalent{
   name = "Wyrmic Guile", short_name = "REK_WYRMIC_MULTICOLOR_GUILE",
   image = "talents/wyrmic_guile.png",
   type = {"wild-gift/prismatic-dragon", 3},
   require = gifts_req_high3,
   points = 5,
   mode = "passive",
   resistKnockback = function(self, t) return self:combatTalentLimit(t, 1, .17, .5) end, -- Limit < 100%
   resistBlindStun = function(self, t) return self:combatTalentLimit(t, 1, .07, .25) end, -- Limit < 100%
   CDreduce = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 1, 6)) end, -- Limit < 8
   on_learn = function(self, t)
      self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 2
   end,
   on_unlearn = function(self, t)
      self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 2
   end,
   passives = function(self, t, p)
      local cdr = t.CDreduce(self, t)
      self:talentTemporaryValue(p, "heightened_senses",  5 ) 
      self:talentTemporaryValue(p, "knockback_immune", t.resistKnockback(self, t))
      self:talentTemporaryValue(p, "stun_immune", t.resistBlindStun(self, t))
      self:talentTemporaryValue(p, "blind_immune", t.resistBlindStun(self, t))
      self:talentTemporaryValue(p, "talent_cd_reduction",
				{
				   [Talents.T_REK_WYRMIC_BREATH_FIRE]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_COLD]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_ELEC]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_ACID]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_VENM]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_SAND]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_DARK]=cdr,
				   [Talents.T_REK_WYRMIC_BREATH_WORM]=cdr
				}
      )
   end,
   info = function(self, t)
      return ([[You have the mental prowess of a Wyrm.
		Your Cunning is increased by %d, and your breath attack cooldowns are reduced by %d.
		You gain %d%% knockback resistance, and your blindness and stun resistances are increased by %d%%.]]):format(2*self:getTalentLevelRaw(t), t.CDreduce(self, t), 100*t.resistKnockback(self, t), 100*t.resistBlindStun(self, t))
   end,
}

-- Chromatic Fury
-- Does nothing, only used by Prismatic Blood to calculate numbers
newTalent{
   name = "Chromatic Fury", short_name = "REK_WYRMIC_MULTICOLOR_FURY",
   image = "talents/chromatic_fury.png",
   type = {"wild-gift/prismatic-dragon", 4},
   require = gifts_req_high4,
   points = 5,
   mode = "passive",

   getDamageIncrease = function(self, t) return self:combatTalentScale(t, 2.5, 10) end,
   getResistPen = function(self, t) return self:combatTalentLimit(t, 100, 5, 20) end, -- Limit < 100%

   info = function(self, t)
      return ([[You have gained the full power of the multihued dragon, and have become both attuned to the draconic elements.  Your active aspects will also grant you %0.1f%% and %0.1f%% resistance penetration with their element]])
	 :format(t.getDamageIncrease(self, t), t.getResistPen(self, t))
  end,
}
