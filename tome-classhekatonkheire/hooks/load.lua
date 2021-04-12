local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorResource = require "engine.interface.ActorResource"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local ActorAI = require "mod.class.interface.ActorAI"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

ActorResource:defineResource ("Hands", "hands", "T_HANDS_POOL", "hands_regen", "Hands represents your ability to reach into the world from the other place.  It recovers at a fixed fast rate.", 0, 100, {
	color = "#c68642#", 
	wait_on_rest = true,
	--status_text = function(act)
	--	return ("%d/%d %s %d"):format(act:getHands(), act:getMaxHands(), (act.hands_regen >= 0) and "+" or "-", (act.hands_regen >= 0) and act.hands_regen or -act.hands_regen)
	--end,
	
	Minimalist = { --parameters for the Minimalist uiset
		images = {front = "resources/front_hands.png", front_dark = "resources/front_hands_dark.png"},
		highlight = function(player, vc, vn, vm, vr)
			if player then
				local cur_t = player.hands
				if cur_t > 20 then return true end
			end
		end,
		shader_params = {display_resource_bar = function(player, shader, x, y, color, a)
				if player ~= table.get(game, "player") or not shader or not a then return end
				local cur_t = player.hands
				local max_t = player.max_hands
				local s = max_t - cur_t
				if s > max_t then s = max_t end
				s = s / max_t
				if shader.shad then
					shader:setUniform("pivot", math.sqrt(s))
					shader:setUniform("a", a)
					shader:setUniform("speed", 10000 - s * 7000)
					shader.shad:use(true)
				end

				local p = cur_t / max_t
				shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], color[1], color[2], color[3], a)
				if shader.shad then shader.shad:use(false) end
			end
		}
	}
})

class:bindHook("ToME:load", function(self, data)
                  Talents:loadDefinition('/data-classhekatonkheire/talents/talents.lua')
                  ActorTemporaryEffects:loadDefinition('/data-classhekatonkheire/effects.lua')
                  Birther:loadDefinition("/data-classhekatonkheire/birth/classes/warrior.lua")
                  DamageType:loadDefinition("/data-classhekatonkheire/damage_types.lua")
									ActorAI:loadDefinition("/data-classhekatonkheire/ai")
                            end)

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classshining/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)
