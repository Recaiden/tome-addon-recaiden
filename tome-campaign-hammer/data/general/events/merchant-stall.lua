-- ToME - Tales of Maj'Eyal
-- Copyright (C) 4009 - 2016 Nicolas Casalini
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
local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while tries < 400 do
	local ok = false
	if game.state:canEventGrid(level, x, y) then
		-- We want to be close a mountain on one side
		for _, dir in ipairs{4,6,8,2} do
			local mx, my = util.coordAddDir(x, y, dir)
			local odir = util.opposedDir(dir)
			local omx, omy = util.coordAddDir(x, y, odir)
			local olx, oly = util.coordAddDir(x, y, util.dirSides(odir).left)
			local orx, ory = util.coordAddDir(x, y, util.dirSides(odir).right)
			if not game.player:canMove(mx, my) and game.player:canMove(omx, omy) and game.player:canMove(olx, oly) and game.player:canMove(orx, ory) then
				ok = true
				break
			end
		end
	end
	if ok then break end

	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries >= 400 then return false end

local stallid = rng.range(1, 3)
local g = mod.class.Grid.new{
	type = "stall", subtype = "rock",
	display = "7", color=colors.UMBER, image="terrain/rocky_ground.png", add_displays={mod.class.Grid.new{image = "terrain/market_stall_0"..stallid.."_1.png", z=6}, mod.class.Grid.new{image = "terrain/market_stall_0"..stallid.."_0.png", display_y=-1, z=18}},
	name = "market stall",
	desc = [[A market stall, it looks abandoned..]],
	does_block_move = true,
	block_sight = true,
	looted = false,
	special = true,
	block_move = function(self, x, y, e, act, couldpass)
		if not self.looted and e and e.player and act then
			self.looted = true
			self.special = nil
			self.autoexplore_ignore = true
			local money = rng.range(10, 30)
			local list = { ("- #GOLD#%0.2f gold#LAST# worth of money"):format(money) }

			e:incMoney(money)
			for _, o in ipairs(self.loots) do
				o.__transmo = true
				o:identify(true)
				e:addObject(e.INVEN_INVEN, o)
				list[#list+1] = "- "..o:getName{do_color=true}
			end
			e:sortInven()

			require("engine.ui.Dialog"):simpleLongPopup("Market Stall", "You loot the stall and gain:\n"..table.concat(list, "\n"), 500)
		end
		return mod.class.Grid.block_move(self, x, y, e, act, couldpass)
	end,
}
g:resolve()
g:resolve(nil, true)

game.zone:addEntity(game.level, g, "terrain", x, y)

g.loots = {}

-- Grab items under it
for i = game.level.map:getObjectTotal(x, y), 1, -1 do
	local o = game.level.map:getObject(x, y, i)
	game.level.map:removeObject(x, y, i)

	o:identify(true)
	g.loots[#g.loots+1] = o
end

-- Sometimes make a few items
if rng.percent(25) then
	for i = 1, rng.range(1, 3) do
		local o = game.zone:makeEntity(game.level, "object", {not_properties={"lore", "auto_pickup"}}, nil, true)
		if o then
			game.zone:addEntity(game.level, o, "object")
			g.loots[#g.loots+1] = o
		end
	end
end

return true
