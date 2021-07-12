defineTile('<', "UP")
defineTile(',', "FLOOR")
defineTile('.', "FLOOR", nil, nil, nil, {lite=true})
defineTile('#', "WALL", nil, nil, nil, {lite=true})
defineTile('*', "HARDWALL", nil, nil, nil, {lite=true})

-- Portals
--defineTile('&', "FAR_EAST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
--defineTile('U', "ORB_UNDEATH", nil, nil, nil, {lite=true})

-- Bosses
defineTile('T', "FLOOR", nil, "TOLAK", nil, {lite=true})
defineTile('M', "FLOOR", nil, "MERENAS", nil, {lite=true})
defineTile("g", "FLOOR", nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='humanoid', faction="allied-kingdoms"}})
defineTile("G", "FLOOR", nil, {random_filter={type='humanoid', faction="allied-kingdoms" random_boss={nb_classes=1, loot_quality="store", loot_quantity=3, ai_move="move_complex", rank=3.5,}}})

addSpot({12, 11}, "portal", "west")
addSpot({34, 11}, "portal", "east")

startx = 23
starty = 21
endx = 23
endy = 21

return [[
*************************************************
*************.....................***************
************.......................**************
***********..........#####..........*************
**********.....##...M.........##.....************
**********.....##......T......##.....************
***********.........................*************
***********.........................*************
************...##....G....G...##...**************
************...##..g..g..g..g.##...**************
************........gg....gg.......**************
************.......................**************
************.......................**************
************...##.............##...**************
************...##.............##...**************
***********#.......................#*************
***********#.......................#*************
**********##...##.............##...##************
*********###...##.............##...###***********
*********###.......................###***********
**********##.......................##************
********************.......**********************
*************************************************]]
