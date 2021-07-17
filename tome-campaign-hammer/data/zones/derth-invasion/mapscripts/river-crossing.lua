local merge_order = {'.', '_', 'r', '+', '#', 'O', ';', '~', 'T'}

-- trees layer
local wfcmain = WaveFunctionCollapse.new{
	mode="overlapping", async=true,
	sample=self:getFile("!trees.tmx", "samples"),
	size={self.mapsize.w, self.mapsize.h},
	n=3, symmetry=8, periodic_out=false, periodic_in=false, has_foundation=false
}
-- Wait for all generators to finish
if not WaveFunctionCollapse:waitAll(wfcmain) then print("[inner_outer] a WFC failed") return self:redo() end

if wfcmain:eliminateByFloodfill{'T', '#'} < 400 then return self:redo() end

-- Merge them all
local tm = Tilemap.new(self.mapsize)
tm:merge(1, 1, wfcmain, merge_order)

-- Find start & exit
local start = tm:locateTile(';', nil, 1, 1, 1, math.floor(tm.data_h / 3))
local stop = tm:locateTile(';', nil, tm.data_w, math.floor(tm.data_h * 2 / 3), tm.data_w, tm.data_h-1)
if tm.data_h > tm.data_w then
	start = tm:locateTile(';', nil, 1, 1, math.floor(tm.data_w / 3), 1)
	stop = tm:locateTile(';', nil, math.floor(tm.data_w * 2 / 3), tm.data_h, tm.data_w-1, tm.data_h)
end
if not start or not stop then return self:redo() end

-- Road
local roadpath = tm:tunnelAStar(start, stop, '~', nil, nil, {virtual=true, erraticness=5, weights_fct=function(x, y, c)
	return 9 / (tm:countNeighbours(tm:point(x, y), ';')+0.001)
end})
if not roadpath then return self:redo() end

local road = Tilemap.new(self.mapsize)
local road_group = road:group{}
for _, p in ipairs(roadpath) do
	road:put(p, '~') road_group:add(p)
end
tm:merge(1, 1, road, merge_order)

-- River
local rstart = tm:locateTile(';', nil, math.floor(tm.data_w*0.6), 1, math.floor(tm.data_w*0.9), 1)
local rstop = tm:locateTile(';', nil, math.floor(tm.data_w*0.6), tm.data_h-1, math.floor(tm.data_w*0.9), tm.data_h-1)
if not rstart or not rstop then return self:redo() end
local riverpath = tm:tunnelAStar(rstart, rstop, 'w', nil, nil, {virtual=true, erraticness=10, weights_fct=function(x, y, c)
	return 9 / (tm:countNeighbours(tm:point(x, y), ';')+0.001)
end})
if not riverpath then return self:redo() end

local river = Tilemap.new(self.mapsize)
local river_group = river:group{}
for _, p in ipairs(riverpath) do
	for _, np in ipairs(select(2, tm:countNeighbours(p, {';', 'T'}, 'w'))) do
		river:put(np, 'w') river_group:add(np)
	end
	river:put(p, 'w') river_group:add(p)
end
tm:merge(1, 1, river, merge_order)

tm:put(start, '<')
tm:put(stop, '>')

-- Elimitate the rest
-- if tm:eliminateByFloodfill{'T', '#'} < 400 then return self:redo() end

tm:printResult()

return tm
