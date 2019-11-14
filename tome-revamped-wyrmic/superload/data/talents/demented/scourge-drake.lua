local _M = loadPrevious(...)

local k, mod = debug.getlocal(6, 2) 	
if k == "mod" and mod.addons and mod.addons.cults then
   Talents.talents_def.T_TENTACLED_WINGS.on_learn = function(self, t)
      self:learnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
   end

   Talents.talents_def.T_TENTACLED_WINGS.on_unlearn = function(self, t)
      self:unlearnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
   end
   
   Talents.talents_def.T_TENTACLED_WINGS.getResists = function(self, t) return self:combatTalentScale(t, 2, 25) end

   Talents.talents_def.T_TENTACLED_WINGS.getDiseaseStrength = function(self, t)
      self:combatSpellDamage(t, 5, 35)
   end
   
   Talents.talents_def.T_TENTACLED_WINGS.getDiseaseDamage = function(self, t)
      return self:combatSpellDamage(t, 6, 45)
   end
   
   Talents.talents_def.T_TENTACLED_WINGS.info = function(self, t)
		return ([[You can take on the power of the otherworldly Scourge using Prismatic Blood.  You will gain %d%% blight resistance and can inflict Scourge damage using your draconic talents.

Activate this talent to project tentacles in a cone of radius %d in front of you.
Any foes caught inside are grappled by the tentacles, suffering %d%% weapon damage as blight and being pulled towards you (#SLATE#no save#LAST#).

Scourge is blight that can inflict a virulent disease (#SLATE#Spellpower vs. Spell#LAST#), reducing one of strength, dexterity, or constitution by %d.  The strength of the disease depends on your Spellpower.]]):
		format(t.getResists(self, t), self:getTalentRange(t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t) * 100), t.getDiseaseStrength(self, t))
	end,
end

return _M
