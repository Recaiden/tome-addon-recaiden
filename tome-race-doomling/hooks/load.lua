local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local Map = require "engine.Map"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-race-doomling/talents.lua')
   ActorTemporaryEffects:loadDefinition('/data-race-doomling/effects.lua')
   Birther:loadDefinition("/data-race-doomling/birth.lua")
end
class:bindHook('ToME:load', load)

class:bindHook(
	"DamageProjector:final",
	function(self, hd)
		local src = hd.src
		local type = hd.type
		local dam = hd.dam
		local target = game.level.map(hd.x, hd.y, Map.ACTOR)
		
		if src.knowTalent and src:knowTalent(src.T_REK_DOOMLING_PREDATORY_MINDSET) and src:canSee(target) then
			local countEnemiesSeen = 0
			for i, act in ipairs(src.fov.actors_dist) do
				if src:canSee(act) and src ~= act then
					local r = act:reactionToward(src)
					if r < 0 then countEnemiesSeen = countEnemiesSeen + 1 end
				end
			end
			if countEnemiesSeen == 1 then 
				dam = dam * (1 + src:callTalent(src.T_REK_DOOMLING_PREDATORY_MINDSET, "getDamageBoost")/100)
				hd.dam = dam
			end
		end
		return hd
	end)
