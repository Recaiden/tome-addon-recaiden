load("/data/general/npcs/aquatic_critter.lua", function(e) if e.rarity then e.water_rarity, e.rarity = e.rarity, nil end end)
load("/data/general/npcs/aquatic_demon.lua", function(e) if e.rarity then e.water_rarity, e.rarity = e.rarity, nil end end)
load("/data/general/npcs/horror_aquatic.lua", function(e) if e.rarity then e.horror_water_rarity, e.rarity = e.rarity, nil end end)
load("/data/general/npcs/horror.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/plant.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")
