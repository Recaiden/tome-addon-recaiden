load("/data/general/grids/basic.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/lava.lua", function(e) e.on_stand = nil end)
