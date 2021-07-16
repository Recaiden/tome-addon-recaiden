local merge_order = {'.', '#', '+'}

local tm = Tilemap.new(self.mapsize, '.')

-- 3 large buildings
local exclusionPoints = {}
for i=1,3 do
	local lx, ly
	local collision = false
	repeat
		collision = false
		lx = rng.range(8, 36)
		ly = rng.range(8, 36)
		for _, point in pairs(exclusionPoints) do
			if math.abs(point.x-lx) <= 12 and math.abs(point.y-ly) <= 12 then collision = true end
		end
	until collision == false
	exclusionPoints[i] = {x=lx, y=ly}
	local large = Static.new(self:getFile("!base.tmx", "samples"))
	if rng.percent(50) then local flip = rng.table{"x", "y"} large = large:flip(flip) end
	tm:merge(lx, ly, large, merge_order)
end

-- 3 to 5 small rooms
local exclusionPointsRoom = {}
for i=rng.range(1,3),5 do
	local lx, ly
	local collision = false
	repeat
		collision = false
		lx = rng.range(2, 40)
		ly = rng.range(2, 40)
		for _, point in pairs(exclusionPoints) do
			if math.abs(point.x-lx) <= 12 and math.abs(point.y-ly) <= 12 then collision = true end
		end
		for _, point in pairs(exclusionPointsRoom) do
			if math.abs(point.x-lx) <= 8 and math.abs(point.y-ly) <= 8 then collision = true end
		end
	until collision == false
	exclusionPointsRoom[i] = {x=lx, y=ly}
	local room = Static.new(self:getFile("!room.tmx", "samples"))
	if rng.percent(50) then local flip = rng.table{"x", "y"} room = room:flip(flip) end
	tm:merge(lx, ly, room, merge_order)
end

-- punch holes in the platform, but not too close
local exclusionPointsHole = {}
for i=rng.range(1,15),30 do
	local lx, ly
	local collision = false
	local count = 0
	repeat
		collision = false
		lx = rng.range(3, 48)
		ly = rng.range(3, 48)
		for _, point in pairs(exclusionPoints) do
			if lx-point.x <= 12 and lx-point.x >= 0 and ly-point.y <= 12 and ly-point.y >= 0 then collision = true end
		end
		for _, point in pairs(exclusionPointsRoom) do
			if lx-point.x <= 8 and lx-point.x >= 0 and ly-point.y <= 8 and ly-point.y >= 0 then collision = true end
		end
		for _, point in pairs(exclusionPointsHole) do
			if math.abs(point.x-lx) <= 1 and math.abs(point.y-ly) <= 1 then collision = true end
		end
		count = count + 1
	until collision == false or count >= 100
	exclusionPointsHole[i] = {x=lx, y=ly}
	tm:put({x=lx,y=ly}, ';')
end

--randomly grow gaps
for _, groups in ipairs(tm:findGroupsOf{'.'}) do
	for _, spot in ripairs(groups.list) do
		if tm:countNeighbours(spot, ';') >=2 then
			tm:put(spot, ';')
		end
	end
end

-- leaving this out creates cascades of void breaking up the level.
-- -- Clear space around void
-- for _, groups in ipairs(tm:findGroupsOf{';'}) do
-- 	for _, spot in ripairs(groups.list) do
-- 		tm:countNeighbours(spot, ';', '.')
-- 	end
-- end

-- randomly destroy some doors
for _, groups in ipairs(tm:findGroupsOf{'+'}) do
	for _, spot in ripairs(groups.list) do
		if rng.percent(20) then tm:put(spot, '#') end
	end
end

local start = tm:locateTile('.', nil, 2, 2, 2, tm.data_h-2)
local stop = tm:locateTile('.', nil, tm.data_w-1, 2, tm.data_w-1, tm.data_h-2)
if not start or not stop then return self:redo() end

tm:put(start, '<')
tm:put(stop, '>')

tm:printResult()

return tm
