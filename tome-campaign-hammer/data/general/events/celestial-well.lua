-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local which = rng.table{"sunwell", "moonwell"}

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = which
g.display='~' g.color_r=255 g.color_g=255 g.color_b=0 g.notice = true
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/"..which..".png", z=5}
end
g:altered()
game.zone:addEntity(game.level, g, "terrain", x, y)

local on_stand = which == "sunwell" and function(self, x, y, who) who:setEffect(who.EFF_SUNWELL, 1, {}) end or function(self, x, y, who) who:setEffect(who.EFF_MOONWELL, 1, {}) end

if which == "sunwell" then
	if core.shader.active(4) and false then level.map:particleEmitter(x, y, 2, "shader_ring_rotating", {rotation=0, radius=4}, {type="flames", aam=0.5, zoom=3, npow=4, time_factor=4000, color1={0.9,0.7,0,1}, color2={0.3,0.2,0,1}, hide_center=0})
	else level.map:particleEmitter(x, y, 2, "ultrashield", {rm=220, rM=250, gm=180, gM=220, bm=10, bM=80, am=220, aM=250, radius=2, density=1, life=14, instop=17})	end
else
	if core.shader.active(4) and false then level.map:particleEmitter(x, y, 2, "shader_ring_rotating", {rotation=0, radius=4}, {type="flames", aam=0.5, zoom=3, npow=4, time_factor=4000, color1={0.1,0.2,0.3,1}, color2={0,0,0.2,1}, hide_center=0})
	else level.map:particleEmitter(x, y, 2, "ultrashield", {rm=0, rM=30, gm=20, gM=40, bm=30, bM=80, am=220, aM=250, radius=2, density=1, life=14, instop=17})	end
end

local grids = core.fov.circle_grids(x, y, 3, "do not block")
for x, yy in pairs(grids) do for y, _ in pairs(yy) do
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.on_stand = g.on_stand or on_stand
	game.zone:addEntity(game.level, g, "terrain", x, y)
end end

return true