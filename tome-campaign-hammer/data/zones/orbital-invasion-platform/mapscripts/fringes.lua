local tm = Tilemap.new(self.mapsize, '#')

-- Place as much rooms as possible then space them out a bit
local bp = tm:binpack(tm.data_w, tm.data_h)

local retries = 1; while retries > 0 do
	local roomsize = math.min(rng.range(5, 15), rng.range(5, 15))
	local size = tm:point(roomsize+rng.range(-1, 1), roomsize+rng.range(-1, 1))
	
	local proom = Heightmap.new(1.6, {up_left=0, down_left=0, up_right=0, down_right=0, middle=1}):make(size.x, size.y, size > tm:point(10,10) and {'#', '.', '.', ';', ';'} or {'#', '.', '.'}):trim('#')

	-- in large spaces create a central hole
	local groups = proom:findGroupsOf{';'}
	local main = table.remove(groups, 1)
	proom:eliminateGroups('.', groups)
	if main then
		local i = 1; while i <= #main.list do local p = main.list[i]
			local nb = 0
			if main:hasPoint(p:dir(4)) then nb = nb + 1 end
			if main:hasPoint(p:dir(6)) then nb = nb + 1 end
			if main:hasPoint(p:dir(8)) then nb = nb + 1 end
			if main:hasPoint(p:dir(2)) then nb = nb + 1 end
			if nb < 2 then i = 1 main:remove(p) proom:put(p, '.')
			else i = i +1 end
		end
		local border = proom:getBorderGroup(main)
		border:fill(proom, '&')

		-- Make sure we are encircled by passable terrain
		local total = border + main
		if not proom:getBorderGroup(total):allMatch(proom, '.') then proom:eliminateGroups('.', total) end
	end


	if not bp:add(proom, 1, 1):resolve() then retries = retries - 1 end
end
bp:compute("random"):spaceOut():merge()
if not bp:hasMerged() then return self:redo() end

-- Strip out land
for _, groups in ipairs(tm:findGroupsOf{'#'}) do
	for _, spot in ripairs(groups.list) do
		tm:countNeighbours(spot, '.', '#')
		tm:countNeighbours(spot, '+', '#')
		tm:countNeighbours(spot, '&', '#')
	end
end

-- bridges
local full_connection, graph = lib.connect_rooms_multi{map=tm, rooms=bp:getMerged(), tunnel_avoid={'_','|'}, tunnel_through={'#'}, smart_door_check={'#','|'}, closest_exits=3, door_chance=0, erraticness=7, edges_surplus=100}
if not full_connection then return self:redo() end

-- Thicken bridges
for _, groups in ipairs(tm:findGroupsOf{'.', '+', '&'}) do
	for _, spot in ripairs(groups.list) do
		tm:countNeighbours(spot, '#', '.')
		tm:countNeighbours(spot, ';', '.')
	end
end

if tm:eliminateByFloodfill{'#'} < 215 then return self:redo() end

-- Find start & exit
local start = tm:locateTile('.')
local stop = tm:locateTile('.')
if not start or not stop then return self:redo() end
tm:put(start, '<')
tm:put(stop, '>')

tm:printResult()

return tm
