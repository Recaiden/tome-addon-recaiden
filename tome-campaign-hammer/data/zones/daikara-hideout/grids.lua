load("/data/general/grids/basic.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/void.lua")
load("/data/general/grids/lava.lua", function(e) e.on_stand = nil end)

newEntity{
	define_as = "MONOLITH",
	type = "wall", subtype = "cave",
	name = "monolith", image = "terrain/cave/cave_floor_1_01.png",
	display = '&', color={r=0,g=255,b=255}, back_color=colors.OLIVE_DRAB,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	can_pass = {pass_wall=1},
	add_displays = {mod.class.Grid.new{image="terrain/darkgreen_moonstone_0"..rng.range(1,8)..".png", display_y=-1, display_h=2, z=18}},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	grow = nil,
	dig = nil,
	special = true,
	autoexplore_ignore = true,
	is_monolith = true,
}

newEntity{
	define_as = "SPACETIME_RIFT_BELOW",
	type = "wall", subtype = "rift",
	name = "crack in spacetime",
	display = '#', color=colors.YELLOW, image="terrain/rift/rift_inner_05_01.png",
	always_remember = true,
	does_block_move = true,
	_noalpha = false,
}

newEntity{
	define_as = "ROCKY_STEEP_UP2",
	type = "floor", subtype = "rock",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -2,
}

newEntity{
	define_as = "CAVE_LADDER_ON",
	type = "floor", subtype = "cave",
	name = "way up into the mountains", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_stairs_up_1_02.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_level_check = function(self, actor)
		local p = game.party:findMember{main=true}
		if not p:hasQuest("campaign-hammer+demon-allies") then
			return true -- block entry until you have quest progress
		end
		if p:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "angry-s") or p:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "death-s") then
			-- if you made shassy angry, no entry
			game.log("Heading towards the stairs, you find the path up blocked by a toppled cult obelisk.  They've spitefully decided to keep you out.")
			return true
		elseif p:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "help-s") and p:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "daikara-gate-open") then
			-- if you finished the miniquest, you can't go back.
			game.log("Heading towards the stairs, you see yourself coming the other direction. You decide to turn around, and at the top of the stairs, the other you does the same.")
			return true
		elseif p:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "daikara-gate-open") then
			-- if you accepted the mini-quest but not finished, head into the rift version
			return false
		elseif p:isQuestStatus("campaign-hammer+demon-allies", engine.Quest.COMPLETED, "help-s") then
			--if you skipped the miniquest by luck, go into the bonus level
			self.change_level = 2
		else
			-- fallback, go into the rift
			return false
		end
	end,
}
