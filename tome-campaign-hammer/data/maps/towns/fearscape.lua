defineTile('<', "PORTAL_EYAL")
defineTile('_', "OUTERSPACE")
defineTile(';', "FLOATING_ROCKS")
defineTile(".", "MALROK_FLOOR")
defineTile("M", "MALROK_FLOOR", nil, "SMITH")
defineTile("m", "MALROK_FLOOR", nil, "JEWELSMITH")
defineTile('#', "MALROK_WALL")
defineTile("+", "MALROK_DOOR")
defineTile("^", "LAVA_FLOOR")

defineTile(",", "DEMON_VAULT_FLOOR")
defineTile("o", "DEMON_ITEMS_VAULT")
defineTile("O", "TRAINING_ORB")
defineTile("0", "MONITOR_ORB1")

defineTile('2', "MALROK_WALL", nil, nil, "ARMOR_STORE")
defineTile('3', "MALROK_WALL", nil, nil, "WEAPON_STORE")
defineTile('4', "MALROK_WALL", nil, nil, "INSCRIPTION_STORE")
defineTile('5', "MALROK_WALL", nil, nil, "TOOL_STORE")
defineTile('6', "MALROK_WALL", nil, nil, "JEWELRY_STORE")
defineTile('7', "MALROK_WALL", nil, nil, "ARTIFACT_STORE")

startx = 23
starty = 3
endx = startx
endy = starty

-- addSpot section
addSpot({23, 3}, "spawn", "player")

addSpot({23, 25}, "pop", "bonus-shop")
addSpot({15, 22}, "pop", "bonus-shop")
addSpot({21, 28}, "pop", "bonus-shop")
addSpot({22, 29}, "pop", "bonus-shop")

addSpot({31, 36}, "training", "training")
addSpot({32, 36}, "training", "training")
addSpot({33, 36}, "training", "training")
addSpot({34, 36}, "training", "training")
addSpot({35, 36}, "training", "training")
addSpot({36, 36}, "training", "training")
addSpot({37, 36}, "training", "training")
addSpot({31, 37}, "training", "training")
addSpot({32, 37}, "training", "training")
addSpot({33, 37}, "training", "training")
addSpot({35, 37}, "training", "training")
addSpot({36, 37}, "training", "training")
addSpot({37, 37}, "training", "training")
addSpot({31, 38}, "training", "training")
addSpot({32, 38}, "training", "training")
addSpot({33, 38}, "training", "training")
addSpot({34, 38}, "training", "training")
addSpot({35, 38}, "training", "training")
addSpot({36, 38}, "training", "training")
addSpot({37, 38}, "training", "training")
addSpot({31, 39}, "training", "training")
addSpot({32, 39}, "training", "training")
addSpot({33, 39}, "training", "training")
addSpot({34, 39}, "training", "training")
addSpot({35, 39}, "training", "training")
addSpot({36, 39}, "training", "training")
addSpot({37, 39}, "training", "training")
addSpot({31, 40}, "training", "training")
addSpot({32, 40}, "training", "training")
addSpot({33, 40}, "training", "training")
addSpot({34, 40}, "camera", "trainingroom")
addSpot({35, 40}, "training", "training")
addSpot({36, 40}, "training", "training")
addSpot({37, 40}, "training", "training")

-- addZone section

-- ASCII map section
return [[
__________________________________________________
_____;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;__________
____;;................;<;;;............;;_________
___;;...................................;;________
_;;;;.....####...........................;;;______
_;;;;.....####...........................;;;______
__;;;;....####..................M........;;_______
___;;;....#__#...........................;________
___;;;....#__#.......#####....#####.....;;________
____;;....####.......#####....#####.....;_________
____;;....####.......#####....#####.....;_________
____;;....#4##.......##5##....#2#3#....;;;________
____;;.................................;;;;_______
___;;;................................;;;;;;______
___;;;...........;;;;;........#####...;;;;;;______
___;;...........;;___;;.......#####.;;;;;;;_______
___;######......;_____;.......#####.;;;;;;;;______
___;######......;_____;.......##6##;;;____;;;_____
___;######......;;___;;..........m;;_______;;_____
___;##7###.......;;;;;...........;;_______________
___;;;...........................;;_______________
___;;.............................;;;;____________
___;;.............................;;;;;;;;________
___;;;........................###########;________
___;;;........................#,,,,#,,,,#;________
___;;;;.......................#,,,,#,,o,#;________
___;;;;.......................#,,,,#,,,,#;;_______
___;;;;.....;;;...............###+###+###;;_______
___;;;;.....;_;...............#,,,,#,,,,#;________
____;;;.;;;;;_;...;;;;;.......#,,,,+,,,,#_________
_____;;.;_____;...;^^^;.......+,,,,#,,,,#_________
_____;;.;_____;...;^^^;.......###########;________
_____;;.;;;;;;;...;^^^;.................;;________
____;;;.;;;.......;;;;;.................;;________
____;;;;;_;.............................;;________
___;;;;;__;......;;;;;;;;;....####+####..;;_______
___;;.;__;;......;__;;___;....#.......#..;;_______
____;;;;;;.......;;;;;;;;;;...#...O...#...;_______
_____;;;;...........;;;.;;;...#.......+...;;______
________;;..........;_;.;_;...#.......#....;;_____
_________;.;;;;....;;_;.;;;...#...0...#.....;_____
_________;;;__;;..;;__;;;.....#########.....;;____
_______________;;.;_____;;;......;;__;;;;....;____
________________;.;_______;;;;_;;;;_____;;;;;;;___
________________;;;____________;;___________;;;___
________________;;;_______________________________
________________;;;_______________________________
_______________;;;;;______________________________
_______________;;;;;______________________________
__________________________________________________]]
