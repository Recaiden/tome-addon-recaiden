newTalentType{ type="race/doomling", name = "Doomling", is_spell=true, generic = true, description = "The various racial bonuses a doomling character can have."}

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
	getNumbing = function(self, t) return 20 * (1.5 + (self.combat_critical_power or 0) / 100) end,
	tactical = { DISABLE = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false} end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(
			tg, x, y,
			function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_REK_DOOMLING_LUCK, 5, {curse=t.getSaveDown(self,  t), numb=t.getNumbing(self, t), src=self})
				game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx", radius=0})
			end)
		
		return true
	end,
	info = function(self, t)
		return ([[Call upon the luck and cunning of the Little Folk to find an enemy's vulnerabilities.  This lower all their saves and defense by %d #SLATE#(no save)#LAST# and reduces the damage they do by %d%% for 5 turns.
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
	end,
	-- called by _M:onTakeHit function in mod.class.Actor.lua for trigger 
	info = function(self, t)
		return ([[Whenever you would lose at least %d%% of your maximum life, you break free from %d stun, daze, or pin effects. If you weren't restrained, you instead become immune to those effects for %d turns.

#{italic}#It didn't save them from the demons, but a Doomling's incredible luck can still get them out of some tight spots.#{normal}#]]):tformat(t.getThreshold(self, t) * 100, t.getRemoveCount(self), t.getDuration(self, t))
	end,
}

newTalent{
	short_name = "REK_DOOMLING_PREDATORY_MINDSET",
	name = "Predatory Mindset",
	type = {"race/doomling", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getDamageBoost = function(self, t) return self:combatTalentScale(t, 10, 20) end,
	info = function(self, t)
		return ([[Whenever you can only see one enemy, you do %d%% more damage to that enemy.

#{italic}#Halflings have always considered themselves superior.  It only took a little push to change their goals from dominion to destruction.#{normal}#]]):format(t.getDamageBoost(self, t))
	end,
}

newTalent{
	short_name = "REK_DOOMLING_DOOM_HUNT",
	name = "Doom Hunt",
	type = {"race/doomling", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
	tactical = { DISABLE = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false} end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(
			tg, x, y,
			function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_REK_DOOMLING_VICTIM, 5, {src=self})
				self:setEffect(self.EFF_REK_DOOMLING_HUNTER, 5, {target=target.uid, name=target.name})
			end)
		return true
	end,
	info = function(self, t)
		return ([[Focus all your attention on one enemy's weaknesses, reducing all their effect immunities (except instant-death) by 1/2 for 5 turns.  Your intense focus lets you see through their stealth or invisibility, but is so narrow that you lose sight of all other creatures.

#{italic}#Rip through an enemy's defenses and make them suffer!#{normal}#]]):format()
	end,
}