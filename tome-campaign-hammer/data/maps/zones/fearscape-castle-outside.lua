defineTile("<", "PORTAL_PREV")
defineTile(">", "MALROK_DOWN2")

defineTile('o', "LAVA")
defineTile('#', "GOTHIC_WALL", nil, nil, nil, {lite=true})
defineTile('*', "MALROK_HARDWALL", nil, nil, nil, {lite=true})
defineTile(" ", "MALROK_FLOOR")

defineTile("g", "MALROK_FLOOR", nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='demon', faction="fearscape"}})
defineTile("G", "MALROK_FLOOR", nil, {random_filter={type='demon', faction="fearscape", random_boss={nb_classes=1, loot_quality="store", loot_quantity=3, ai_move="move_complex", rank=3.5,}}})

startx = 25
starty = 0
endx = 25
endy = 46

-- ASCII map section
return [[
oooooooooooooooooooooooo < ooooooooooooooooooooooo
oooooooooooooooooooooooo   ooooooooooooooooooooooo
oooooooooooooooooooooooo   ooooooooooooooooooooooo
oooooooooooooooooooooooo   ooooooooooooooooooooooo
ooooooooooooooooooooooooo oooooooooooooooooooooooo
oooooooooooooooooooooogg   ggooooooooooooooooooooo
oooooooooooooooooo      gGg      ooooooooooooooooo
oooooooooooooooo                   ooooooooooooooo
oooooooooooooo                       ooooooooooooo
ooooooooooooo           ooo           oooooooooooo
ooooooooooo             o#o             oooooooooo
oooooooooo              ooo              ooooooooo
oooooooooo         ooo       ooo         ooooooooo
oooooooooo  ooo    o#o       o#o    ooo  ooooooooo
ooooooooo   o#o    ooo       ooo    o#o   oooooooo
oooooooo    ooo                     ooo    ooooooo
oooooooo                                   ooooooo
ooooooo             ooooo ooooo             oooooo
ooooooo  ooo                           ooo  oooooo
oooooo   o#o                           o#o   ooooo
ooooo    ooo ##  oo##oo  G  oo##oo  ## ooo   ooooo
ooo##                                        ##ooo
ooo##      ###        g    g         ###     ##ooo
ooo##           oo#ooooooooooooo#oo          ##ooo
ooo##     ##    o##ooooooooooooo##o    ##    ##ooo
ooo##     ##    o#ooooooooooooooo#o    ##    ##ooo
ooo##     ##    o#ooooooo#ooooooo#o    ##    ##ooo
ooo##           o##ooooooooooooo##o          ##ooo
ooo##      ###  oo#ooooooooooooo#oo  ###     ##ooo
ooo###      ##   o##ooooooooooo##o   ##     ###ooo
oooo##           oo##ooooooooo##oo          ##oooo
oooo##            oo##ooooooo##oo           ##oooo
oooo##             oo#ooooooo#oo            ##oooo
oooo##              ooooooooooo             ##oooo
oooo##      ###       ooooooo       ###     ##oooo
oooo##      ###                     ###     ##oooo
oooo###     ###                     ###    ###oooo
ooooo###            ###     ###           ###ooooo
oooooo##     G       #########       G    ##oooooo
oooooo##              #######             ##oooooo
oooooo##                gGg               ##oooooo
oooooo##                ###               ##oooooo
oooooo##     o                       o    ##oooooo
oooooo##    ooo                     ooo   ##oooooo
oooooo##     o                       o    ##oooooo
oooooo##                                  ##oooooo
oooooo###               #>#              ##ooooooo
ooooooo####################################ooooooo
oooooooo##################################oooooooo
ooooooooooooo########################ooooooooooooo]]
