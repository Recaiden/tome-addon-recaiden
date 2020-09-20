local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorResource = require "engine.interface.ActorResource"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

ActorResource:defineResource ("Hull", "hull", "T_HULL_POOL", "hull_regen", "Hull represents how intact your vehicle is. If functions like Life while in a vehicle, absorbing damage and recovering through healing. If it is reduced to zero your vehicle is destroyed.", 0, nil, {
	color = "#a35633#", 
	wait_on_rest = true,
	
	Minimalist = { --parameters for the Minimalist uiset
		images = {front = "resources/front_hull.png", front_dark = "resources/front_hull_dark.png"},
		highlight = function(player, vc, vn, vm, vr) -- dim the resource display if <= 30%
			if player then
				local cur_t = player.hull
				local max_t = player.max_hull
				if cur_t > max_t * .3 then return true end
			end
		end,
		shader_params = {display_resource_bar = function(player, shader, x, y, color, a)
				if player ~= table.get(game, "player") or not shader or not a then return end
				local cur_t = player.hull
				local max_t = player.max_hull
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
                  Talents:loadDefinition('/data-classdemolisher/talents/steam.lua')
                  ActorTemporaryEffects:loadDefinition('/data-classdemolisher/effects.lua')
                  Birther:loadDefinition("/data-classdemolisher/birth/classes/tinker.lua")
                  DamageType:loadDefinition("/data-classdemolisher/damage_types.lua")
                            end)

class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local type = hd.type
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)
	if type ~= DamageType.FIRE and src.knowTalent and src:isTalentActive(src.T_REK_DEML_PYRO_DEMON) then
		local tDemon = src:getTalentFromId(src.T_REK_DEML_PYRO_DEMON)
		tDemon.doConsumeBurn(src, tDemon, target)
	end
	return hd
end)

class:bindHook("Object:descWielder", function(self, hd)
								 hd.compare_fields(hd.w, hd.compare_with, hd.field, "max_hull", "%+.2f", "Maximum hull: ")
	return hd
end) 

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classdemolisher/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)


function hookupdateModdableTileBack(self, data)
	local base = data.base
	local add = data.add
	if self:hasEffect(self.EFF_REK_DEML_RIDE) then
		add[#add+1] = {image = "demolisher_ride_back.png", auto_tall=1}
	end
end

function hookupdateModdableTileFront(self, data)
	local base = data.base
	local add = data.add
	if self:hasEffect(self.EFF_REK_DEML_RIDE) then
		add[#add+1] = {image = "demolisher_ride_front.png", auto_tall=1}
	end
end

class:bindHook("Actor:updateModdableTile:back", hookupdateModdableTileBack)
class:bindHook("Actor:updateModdableTile:front", hookupdateModdableTileFront)
