defineTile('<', "GRASS_UP_WILDERNESS")
defineTile('t', "OUTERSPACE")
defineTile("^", "MOUNTAIN_WALL")
defineTile(';', "FLOATING_ROCKS")
defineTile("_", "FLOOR_ROAD_STONE")
defineTile(".", "MALROK_FLOOR")
defineTile("M", "MALROK_FLOOR", nil, "METASH")
defineTile('#', "HARDWALL")
defineTile("'", "GRASS_WOODEN_BARRICADE")
defineTile("&", "FLOOR_WOODEN_BARRICADE")
defineTile("~", "MECH_WALL")
defineTile("+", "BAMBOO_HUT_DOOR")
defineTile(">", "CAVE_IN")

--defineTile('1', "HARDWALL", nil, nil, "TRAINER")
defineTile('2', "MALROK_WALL", nil, nil, "ARMOR_STORE")
defineTile('3', "MALROK_WALL", nil, nil, "WEAPON_STORE")
defineTile('4', "MALROK_WALL", nil, nil, "INSCRIPTION_STORE")
defineTile('5', "MALROK_WALL", nil, nil, "TOOL_STORE")
defineTile('7', "MALROK_WALL", nil, nil, "ARTIFACT_STORE")

startx = 23
starty = 0
endx = startx
endy = starty

-- addSpot section
addSpot({19, 37}, "spawn", "player")
addSpot({16, 43}, "spawn", "giants-respawn")
addSpot({17, 43}, "spawn", "giants-respawn")
addSpot({12, 35}, "spawn", "defender")
addSpot({15, 42}, "spawn", "giants")
addSpot({16, 42}, "spawn", "giants")
addSpot({17, 42}, "spawn", "giants")
addSpot({18, 42}, "spawn", "giants")
addSpot({14, 41}, "spawn", "defender")
addSpot({20, 39}, "spawn", "defender")
addSpot({17, 39}, "spawn", "defender")
addSpot({17, 44}, "feature", "down")

-- addZone section

-- ASCII map section
return [[
tttttt'''''''''''''''''<'''''''''''ttttttttttttttt
ttttt;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ttttttttttttttt
ttttt;;....####.......;;;;;.......;ttttttttttttttt
ttttt;;....####....................;;;;;;;tttttttt
ttttt;;;...####.....................;;;;;;;;tttttt
tttt;;;;...####......................;;;;;;ttttttt
tttt;;;;...####................M......;;;;;ttttttt
tttt;;;....####........................;;;tttttttt
tttt;;;....####.......###.......~~~~~...;;tttttttt
tttt;;.....#4##......#####......~~~~~...;ttttttttt
tttt;;...............#####......~~~~~...;ttttttttt
tttt;;................#5#.......~2~3~..;;;tttttttt
tttt;;.................................;;;;ttttttt
ttt;;;................................;;;;;;tttttt
ttt;;;........................#####;..;;;;;;tttttt
ttt;;.........................#####;;;;;;;;ttttttt
ttt;######.....~~~............#####;;;;;;;;ttttttt
ttt;######.....~~~............#####;;;tttt;;tttttt
ttt;#####......~~~..............;;;;ttttttt;;ttttt
ttt;#9#8#......~7~...............;;ttttttttttttttt
ttt;;;...................~~~~....;;ttttttttttttttt
ttt;;....................~~~~.....;;;;tttttttttttt
ttt;;.....................~~......;;;;;ttttttttttt
ttt;;;....................~~......;;;;;;tttttttttt
ttt;;;...................~~~~.....;######ttttttttt
ttt;;;;...................~~.....;;######;tttttttt
ttt;;;;...................~~.....;;######;;;tttttt
ttt;;;;...................~~.....;;######;;;tttttt
ttt;;;;......&...................;;######;tttttttt
tttt;;;......&...................;;######ttttttttt
ttttt;;..&...&.....&.............;;######ttttttttt
ttttt;;..&.&&......&..............;;;;tttttttttttt
ttttt;;............&&&.&&..........;;;tttttttttttt
tttt;;;............................;;;tttttttttttt
tt^^;;;..&.........................;;;tttttttttttt
t^^;;;..&&...&&&....................;;;;;;;^tttttt
t^^....&&.........&&.&&&&...........;;;;;;;^^ttttt
^^^^....................&&.................^^^tttt
^^^^^^...................&..................^^^^^t
^^^^^^^^......&&&....^...&...................^^^^^
^^^^^^^^^............^.......................^^^^^
^^^^^^^^^...^^......^^........................^^^^
^^^^^^^^^^^^^^^....^^^^^...........^^.........^^^^
^^^^^^^^^^^^^^^^...^^^^^^^....^....^^^^^.......^^^
^^^^^^^^^^^^^^^^...^^^^^^^^^^^^..^^^^^^^^^^^...^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^]]
