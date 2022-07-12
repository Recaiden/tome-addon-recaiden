return {
	name = "Edge of Eternity",
	level_range = {100, 100},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 26,
	all_lited = true,
	day_night = false,
	no_worldport = true,
	persistent = "zone",
	ambient_music = "Through the Dark Portal.ogg",
	min_material_level = 5,
	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "!final",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
	},
	post_process = function(level)
		local Map = require "engine.Map"
		level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
	end,
	
	on_enter = function()
		--game.party:learnLore("campaign-hammer-goddess-arrives")
		for uid, e in pairs(game.level.entities) do
			if e.define_as == "QUEKORJA" then
				local Chat = require "engine.Chat"
				local chat = Chat.new("campaign-hammer+time-talk", e, game:getPlayer(true))
				chat:invoke()
			end
		end
	end,
	
	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		if level.starfield_shader and level.starfield_shader.shad then
			level.starfield_shader.shad:use(true)
			core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
			level.starfield_shader.shad:use(false)
		elseif level.background_particle then
			level.background_particle.ps:toScreen(x, y, true, 1)
		end
	end,
}
