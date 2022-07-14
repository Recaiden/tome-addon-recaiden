newTalent{
	name = "Titan's Mettle", short_name = "REK_EVOLUTION_HEKA_HEKA_HIT",
	type = {"uber/strength", 1},
	uber = true,
	require = {
		stat = {dex = 25},
		level = 25,
		birth_descriptors={{"subclass", "Hekatonkheire"}},
		special={
			desc="Know Talent: Skewer",
			fct=function(self)
				return self:getTalentLevelRaw(self.T_REK_HEKA_TITANIC_SKEWER) >= 1
			end
		}
	},
	is_class_evolution = "Hekatonkheire",
	cant_steal = true,
	mode = "passive",
	no_npc_use = true,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam) 
		if hitted and not self.heka_in_mettle then
			local chance = mult * 5
			local count = mult
			self.heka_in_mettle = true
			while count > 1 do -- not 0 because the original hit has its own on-hits.
				self:attackTargetHitProcs(target, weapon, dam, 0, 0, damtype, 1, atk, def, hitted, crit, false, false, target.life + dam)
				count = count - 1
			end
			self.heka_in_mettle = nil
			if rng.percent(chance) then
				self:forceUseTalent(self.T_REK_HEKA_TITANIC_SKEWER, {ignore_cd=true, ignore_energy=true, force_target=target, ignore_ressources=true})
			end
		end
	end,
	info = function(self, t)
		return ([[#{italic}#Hit them as hard as possible.#{normal}#

You apply on-hit effects once for every 100%% damage of an attack (round up).
You have a %d%% chance to use Skewer on-melee-hit for every 100%% damage of an attack.]]):format(self:getTalentLevel(t)*10)
	end,
}
