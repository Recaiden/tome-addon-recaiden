local merge_order = {'.', '_', 'r', '+', '#', 'O', ';', '=', 'T'}

-- trees layer
local wfcmain = WaveFunctionCollapse.new{
	mode="overlapping", async=true,
	sample=self:getFile("!forest-bits.tmx", "samples"),
	size={self.mapsize.w, self.mapsize.h},
	n=3, symmetry=8, periodic_out=false, periodic_in=false, has_foundation=false
}
-- Wait for all generators to finish
if not WaveFunctionCollapse:waitAll(wfcmain, wfcwater) then print("[inner_outer] a WFC failed") return self:redo() end

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

-- Build up a road inside a new Tilemap
local roadpath = tm:tunnelAStar(start, stop, '=', nil, nil, {virtual=true, erraticness=5, weights_fct=function(x, y, c)
	return 9 / (tm:countNeighbours(tm:point(x, y), ';')+0.001)
end})
if not roadpath then return self:redo() end

local road = Tilemap.new(self.mapsize)
local road_group = road:group{}
for _, p in ipairs(roadpath) do
	for _, np in ipairs(select(2, tm:countNeighbours(p, {';', 'T'}, '='))) do
		road:put(np, '=') road_group:add(np)
	end
	road:put(p, '=') road_group:add(p)
end

-- Find random points along the road
for i = 1, rng.range(4, 7) do
	local p = road_group:pickSpot("any")
	if p then
		road_group:remove(p)
		self:addSpot(p.x, p.y, "road", "caravan")
	end
end

-- place caravan decorations not directly near the spawn points
for _, groups in ipairs(tm:findGroupsOf{';'}) do --groups of grass
	for _, spot in ripairs(groups.list) do
		if rng.percent(3) and tm:countNeighbours(spot, '=') >= 3 then -- adjacent to the road
			tm:put(spot, '@')
		end
	end
end

tm:merge(1, 1, road, merge_order)

tm:put(start, '<')
tm:put(stop, '>')

-- Elimitate the rest
-- if tm:eliminateByFloodfill{'T', '#'} < 400 then return self:redo() end

tm:printResult()

return tm
