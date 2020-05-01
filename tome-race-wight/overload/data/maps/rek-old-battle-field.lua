defineTile('.', "CAVEFLOOR", nil, nil, nil, {lite=true})
defineTile('&', "CAVEFLOOR", nil, nil, nil, {lite=true}, {type="pop", subtype="undead"})
defineTile('G', "CAVEFLOOR", nil, nil, nil, {lite=true}, {type="pop", subtype="graverobber"})
defineTile('#', "CAVEWALL", nil, nil, nil, {lite=true})

endx = 16
endy = 11

return [[
##################
####..############
####&.#&.#&#######
##&..........#####
#............&####
#&...G........####
##..............##
###&............&#2
###.............##
#&..............##
##..............&#
#&...............#
##&...........&.##
####..........####
####&.......&#####
######&.##&.######
##################]]
