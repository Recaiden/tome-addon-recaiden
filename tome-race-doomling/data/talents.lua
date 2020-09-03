newTalentType{ type="undead/wight", name = "wight", is_spell=true, generic = true, description = "The various racial bonuses an undead character can have."}

local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

newTalent{
	short_name="REK_DOOMLING_LUCK",
	name = "Curse of the Little Folk",
	type = {"race/doomling", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
	getSaveDown = function(self, t) return self:combatStatScale("cun", 15, 60, 0.75) end,
	getNumbing = function(self, t) return 20 * (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100) end,
	-- TODO real tactical table for debuff
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_REK_DOOMLING_FURY, 5, {power=t.getDamage(self,  t)})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the luck and cunning of the Little Folk to find an enemy's weaknesses.  This lower all their saves by %d (no save) and reduces the damage they do by %d%% for 5 turns.
		The save reduction will increase with your Cunning.
    The damage reduction will increase with your critical power.]]):format(t.getSaveDown(self, t), t.getNumbing(self, t))
	end,
}

newTalent{
	short_name = "REK_DOOMLING_UNFLINCHING",
	name = "Unflinching",
	type = {"race/doomling", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.max(10, (15 - self:getTalentLevelRaw(t))) / 100 end,
	getRemoveCount = function(self, t) return 1 end,
	getDuration = function(self, t) return 2 end,
	callbackOnHit = function(self, t, cb, src, death_note)
		if cb.value >= self.max_life * t.getThreshold(self, t) then
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.subtype.stun or e.subtype.pin then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
			if #effs > 0 then
				for i = 1, t.getRemoveCount(self, t) do
					local eff = rng.tableRemove(effs)
					if eff[1] == "effect" then
						self:removeEffect(eff[2])
					end
				end
			else
				self:setEffect(self.EFF_FREE_ACTION, t.getDuration(self, t), {src=self})
			end
		end
		return cb
	end
	-- called by _M:onTakeHit function in mod.class.Actor.lua for trigger 
	info = function(self, t)
		local threshold = t.getThreshold(self, t)
		local evasion = t.getEvasionChance(self, t)
		local duration = t.getDuration(self, t)
		return ([[Whenever you would lose at least %d%% of your maximum life, you break free from %d stun, daze, or pin effects. If you weren't restrained, you instead become immune to those effects for %d turns.
#{italic}#It didn't save them from the demons, but a Doomling's incredible luck can still get them out of some tight spots.#{normal}#]]):tformat(threshold * 100, t.getRemoveCount(self), t.getDuration(self, t))
	end,
	end,
}

newTalent{
   short_name = "REK_DOOMLING_PREDATORY_MINDSET",
   name = "Predatory Mindset",
   type = {"race/doomling", 3},
   require = racial_req3,
   points = 5,
   cooldown = 10,
   mode = "passive",
   --TODO make it a sustain
   getEvasion = function(self, t)
      return math.min(self:combatTalentScale(t, 4, 18, 0.75), 30)
   end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "cancel_damage_chance", t.getEvasion(self, t))
   end,
   info = function(self, t)
      return ([[You have a %d%% chance to reduce any incoming damage to 0.

Learning this talent regrows a fragment of your connection to nature, allowing you to use a single Infusion.

#{italic}#Blows that should have been telling seem to slip right through them...#{normal}#]]):format(t.getEvasion(self, t))
   end,
}

newTalent{
   short_name = "REK_DOOMLING_FURY_OF_THE_BROKEN",
   name = "Fury of the Broken",
   type = {"race/doomling", 4},
   require = racial_req4,
   points = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 30, 17)) end,
   no_energy = true,
   tactical = { ESCAPE = 1 },
   getRange = function(self, t) return self:combatTalentScale(t, 11, 20) end,
   getDuration = function(self, t) return 3 end,
   action = function(self, t)
      local rad = self:getTalentRadius(t)
      self:setEffect(self.EFF_REK_DOOMLING_GHOSTLY, t.getDuration(self, t), {power=t.getRange(self, t)})
      return true
   end,
   info = function(self, t)
      return ([[Shift fully into the spirit world for 3 turns, allowing you to walk through walls and to sense all enemies within range %d. 

If you are inside a wall when the effect ends, you will move to the nearest open space.

#{italic}#...faded and incorporeal at their edges, while strange lights dance where their eyes should remain....#{normal}#]]):format(t.getRange(self, t))
   end,
}