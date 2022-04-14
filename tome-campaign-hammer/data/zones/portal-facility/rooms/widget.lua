local def = { numbers = '.',
[[v]],
}

return function(gen, id)
	local room = gen:roomParse(def)
	return { name="valve"..room.w.."x"..room.h, w=room.w, h=room.h, generator = function(self, x, y, is_lit)
		gen:roomFrom(id, x, y, is_lit, room)

		util.squareApply(x, y, room.w, room.h-2, function(i, j) gen.map.room_map[i][j].special = true end)
		
		local spot = room.spots[1][1]
		gen.spots[#gen.spots+1] = {x=x+spot.x, y=y+spot.y, check_connectivity="entrance"}
		end
	end}
end
