setStatusAll{control_teleport_fizzle=30}

defineTile('<', "UP")
defineTile(',', "FLOOR")
defineTile('.', "FLOOR", nil, nil, nil, {lite=true})
defineTile('#', "WALL", nil, nil, nil, {lite=true})
defineTile('*', "HARDWALL", nil, nil, nil, {lite=true})

-- Portals
--defineTile('&', "FAR_EAST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
--defineTile('!', "CFAR_EAST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
--defineTile('"', "WEST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
--defineTile("'", "CWEST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
--defineTile('V', "VOID_PORTAL", nil, nil, nil, {lite=true})
--defineTile('v', "CVOID_PORTAL", nil, nil, nil, {lite=true})
--defineTile('d', "ORB_DESTRUCTION", nil, nil, nil, {lite=true})
--defineTile('D', "ORB_DRAGON", nil, nil, nil, {lite=true})
--defineTile('E', "ORB_ELEMENTS", nil, nil, nil, {lite=true})
--defineTile('U', "ORB_UNDEATH", nil, nil, nil, {lite=true})

-- Bosses
defineTile('T', "FLOOR", nil, "TOLAK", nil, {lite=true})
defineTile('M', "FLOOR", nil, "MERENAS", nil, {lite=true})

--addSpot({16, 4}, "portal", "demon")
--addSpot({33, 4}, "portal", "dragon")
--addSpot({33, 18}, "portal", "undead")
--addSpot({16, 18}, "portal", "elemental")

startx = 25
starty = 8
endx = 25
endy = 8

return [[
**************************************************
******************..............******************
************..........................************
***********..............#.............***********
***********.....d.......###......D.....***********
************............###...........************
*************............#...........*************
*************............#...........*************
**************......................**************
**************......................**************
**************......................**************
**************..#####..T...M..####..**************
**************......................**************
**************......................**************
**************......................**************
*************............#...........*************
*************............#...........*************
************............###...........************
***********.....E.......###......U.....***********
***********..............#.............***********
************..........................************
******************..............******************
**************************************************]]
