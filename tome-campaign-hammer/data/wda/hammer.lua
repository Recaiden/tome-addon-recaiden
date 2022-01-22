-- worldmap directory AI

-- Select the zone
local Map = require "engine.Map"
local zone = game.zone.display_name and game.zone.display_name() or game.zone.name
if not wda.zones[zone] then wda.zones[zone] = {} end
wda = wda.zones[zone]

game.level.level = game.player.level

local encounter_chance = function(who)
	local harmless_chance = 1 + who:getLck(7)
	local hostile_chance = 2
	if rng.percent(hostile_chance) then return "hostile"
	elseif rng.percent(harmless_chance) then return "harmless"
	end
end

wda.cur_caravan = wda.cur_caravan or 0
wda.cur_patrols = wda.cur_patrols or 0
wda.cur_sw_patrols = wda.cur_sw_patrols or 0
wda.cur_hostiles = wda.cur_hostiles or 0

-- Spawn some patrols
if wda.cur_patrols < 3 then
	local e = game.zone:makeEntity(game.level, "maj_eyal_encounters_npcs", {type="patrol", subtype="allied kingdoms"}, nil, true)
	if e then
		local spot = game.level:pickSpot{type="patrol", subtype="allied-kingdoms"}
		if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
			print("Spawned allied kingdom patrol", spot.x, spot.y, e.name)
			game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
			wda.cur_patrols = wda.cur_patrols + 1
			e.world_zone = zone
			e.on_die = function(self)
				if game and game.level and game.level.data and game.level.data.wda then
					game.level.data.wda.zones[self.world_zone].cur_patrols = game.level.data.wda.zones[self.world_zone].cur_patrols - 1
				end
			end
		end
	end
end

--spawn the caravan initially
if wda.cur_caravan < 1 then
	local e = game.zone:makeEntity(game.level, "caravan_encounter", {type="patrol", subtype="caravan"}, nil, true)
	if e then
		local spot = game.level:pickSpot{type="patrol", subtype="campaign-hammer+caravan"}
		if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
			print("Spawned carvan patrol entity", spot.x, spot.y, e.name)
			game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
			wda.cur_caravan = wda.cur_caravan + 1
			e.world_zone = zone
			e.on_die = function(self)
				-- Don't respawn --TODO unless player doesn't clear enough?
				--game.level.data.wda.zones[self.world_zone].cur_caravan = game.level.data.wda.zones[self.world_zone].cur_caravan - 1
			end
		end
	end
end

game.level.level = 1
