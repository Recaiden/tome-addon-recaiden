defineTile('<', "UP")
defineTile(',', "MALROK_FLOOR")
defineTile('o', "LAVA")
defineTile('.', "FLOOR", nil, nil, nil, {lite=true})
defineTile('#', "GOTHIC_WALL", nil, nil, nil, {lite=true})
defineTile('*', "MALROK_HARDWALL", nil, nil, nil, {lite=true})

-- Portals

-- Bosses
defineTile('K', "FLOOR", nil, "KHULMANAR_HAMMER", nil, {lite=true})
defineTile("g", "FLOOR", nil, {entity_mod=function(e) e.make_escort = nil e.faction="fearscape" return e end, random_filter={type='demon', faction="fearscape"}})
defineTile("G", "FLOOR", nil, {entity_mod=function(e) e.faction="fearscape" return e end, random_filter={type='demon', faction="fearscape", random_boss={nb_classes=1, loot_quality="store", loot_quantity=3, ai_move="move_complex", rank=3.5,}}})

--addSpot({12, 11}, "portal", "west")
--addSpot({34, 11}, "portal", "east")

startx = 23
starty = 1
endx = 23
endy = 1

return [[
*************************************************
*************.....................***************
************.......................**************
***********.........................*************
**********.....##.............##.....************
**********.....##.............##.....************
***********.........................*************
***********......G...........G......*************
************...##....g...g....##...**************
************...##g...........g##...**************
************.......................**************
************.......................**************
************...........o...........**************
************...##.....ooo.....##...**************
************...##....ooooo....##...**************
***********#..........ooo..........#*************
***********#...........o...........#*************
**********##...ooo...........ooo...##************
*********###...o#o.....K.....o#o...###***********
*********###...ooo...........ooo...###***********
**********##.......................##************
*******************#.......#*********************
********************#######**********************]]
