local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorResource = require "engine.interface.ActorResource"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

ActorResource:defineResource (_t"Hull", "hull", "T_HULL_POOL", "hull_regen", _t"Hull represents how intact your vehicle is. If functions like Life while in a vehicle, absorbing damage and recovering through healing. If it is reduced to zero your vehicle is destroyed.", 0, nil, {
	color = "#a35633#", 
	wait_on_rest = true,
	
	status_text = function(act)
		if act.hasEffect and act:hasEffect(act.EFF_REK_DEML_RIDE) then
			local regen_t = act.life_regen * (act.healing_factor or 1)
			return ("%d/%d  +%0.2f"):tformat(act:getHull(), act:getMaxHull(), regen_t)
		else
			return ("%d"):tformat(act:getMaxHull())
		end
	end,
	
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
								 hd.compare_fields(hd.w, hd.compare_with, hd.field, "max_hull", "%+.2f", _t"Maximum hull: ")
	return hd
end) 

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classdemolisher/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)


function hook_updateModdableTileBack(self, data)
	local base = data.base or {}
	local add = data.add or {}
	if self:hasEffect(self.EFF_REK_DEML_RIDE) then
		local img = self.deml_ride_style or "classic"
		add[#add+1] = {image = "demolisher_ride_"..img.."_back.png", auto_tall=1}
	end
	data.add = add
end

function hook_updateModdableTileSkin(self, data)	
	local base = data.base or {}
	local add = data.add or {}
	if self:hasEffect(self.EFF_REK_DEML_RIDE) then
	
		local masked = add[#add]

		-- check for ogres
		local is_tall = self.deml_tall_tiles or nil
		if is_tall == nil then
			local Map = require "engine.Map"
			if Map.tiles then
				local _, _, _, w, h = Map.tiles:get('', 0, 0, 0, 0, 0, 0, masked.image)
				is_tall = h > w
				self.deml_tall_tiles = is_tall
			else
				is_tall = false
			end
		end

		masked.image_alter="sdm"
		masked.sdm_double=is_tall and "dynamic" or false
		masked.shader="alpha_shader"
		masked.shader_args={}
		masked.textures={
			{"image", masked.image},
			{"image", is_tall and "particles_images/masks/mask_pants_giant.png" or "particles_images/masks/mask_pants.png"}
		}
		masked.auto_tall=1
		masked.display_h=(is_tall and 2 or nil)
		masked.display_y=(is_tall and -1 or nil)
		
		add[#add] = masked
	end
	data.add = add
end

function hook_updateModdableTileFront(self, data)
	local base = data.base or {}
	local add = data.add or {}
	if self:hasEffect(self.EFF_REK_DEML_RIDE) then
		local is_tall = self.deml_tall_tiles or false
		
		-- go through and apply a masked shader to legs and lower body, if they exist
		local base = "player/"..self.moddable_tile:gsub("#sex#", self.female and "female" or "male").."/"
		local i = self:getObjectModdableTile(self.INVEN_FEET)
		local j = self:getObjectModdableTile(self.INVEN_BODY)
		local jfile =  base..(j and j.moddable_tile2 or "nosuchlayer")..".png"
		for idx, mos in ipairs(add) do
			if mos.bodyplace and mos.bodyplace == "feet" then
				local masked = add[idx]
				masked.image_alter="sdm"
				masked.sdm_double=is_tall and "dynamic" or false
				masked.shader="alpha_shader"
				masked.shader_args={}
				if masked.textures then
					masked.textures[#masked.textures+1] = {"image", "particles_images/masks/mask_boots.png"}
				else
					masked.textures={{"image", base..(i.moddable_tile)..".png"},
						{"image", "particles_images/masks/mask_boots.png"}}
				end
				masked.auto_tall=1
				add[idx] = masked
			end
			if mos.bodyplace and mos.bodyplace == "body" then
				if mos.image == jfile then
					local  masked = add[idx]
					masked.image_alter="sdm"
					masked.sdm_double=is_tall and "dynamic" or false
					masked.shader="alpha_shader"
					masked.shader_args={}
					if masked.textures then
						masked.textures[#masked.textures+1] = {"image", "particles_images/masks/mask_pants.png"}
					else
						masked.textures={{"image", base..(j.moddable_tile2)..".png"}, {"image", "particles_images/masks/mask_pants.png"}}
					end
					masked.auto_tall=1
					add[idx] = masked
				elseif string.find(mos.image, "lower_body") then
					local masked = add[idx]
					masked.image_alter="sdm"
					masked.sdm_double=false
					masked.shader="alpha_shader"
					masked.shader_args={}
					if masked.textures then
						masked.textures[#masked.textures+1] = {"image", "particles_images/masks/mask_pants.png"}
					else
						masked.textures={{"image", mos.image}, {"image", "particles_images/masks/mask_pants.png"}}
					end
					masked.auto_tall=1
					add[idx] = masked
				elseif string.find(mos.image, "upper_body") then
					local masked = add[idx]

					-- keep ogres' bras on their chests
					local is_tall_clothes = false
					local Map = require "engine.Map"
					if Map.tiles then
						local _, _, _, w, h = Map.tiles:get('', 0, 0, 0, 0, 0, 0, masked.image)
						is_tall_clothes = h > w
					end
					
					masked.image_alter="sdm"
					masked.sdm_double=is_tall_clothes and "dynamic" or false
					masked.shader="alpha_shader"
					masked.shader_args={}
					if masked.textures then
						masked.textures[#masked.textures+1] = {"image", is_tall and "particles_images/masks/mask_pants_giant.png" or "particles_images/masks/mask_pants.png"}
					else
						masked.textures={{"image", mos.image}, {"image", is_tall and "particles_images/masks/mask_pants_giant.png" or "particles_images/masks/mask_pants.png"}}
					end
					masked.auto_tall=1
					masked.display_h=(is_tall and 2 or nil)
					masked.display_y=(is_tall and -1 or nil)
					add[idx] = masked
				end
			end
		end
		
		local img = self.deml_ride_style or "classic"
		add[#add+1] = {image = "demolisher_ride_"..img.."_front.png", auto_tall=1}
	end
	data.add = add
end

class:bindHook("Actor:updateModdableTile:back", hook_updateModdableTileBack)
class:bindHook("Actor:updateModdableTile:skin", hook_updateModdableTileSkin)
class:bindHook("Actor:updateModdableTile:front", hook_updateModdableTileFront)
