startx = 0
starty = 26
endx = 39
endy = 5

-- defineTile section
defineTile('<', "WATER_UP_WILDERNESS")
defineTile('>', "ABYSSAL_CAVES")
defineTile('_', "WATER_FLOOR")
defineTile('.', "WATER_FLOOR")
defineTile('+', "WATER_DOOR")
defineTile('#', "WATER_WALL")
defineTile('m', "UNDERSEA_CLIFFS")
defineTile('M', "HARDUNDERSEA_CLIFFS")
defineTile('p', "SAND")
defineTile('P', "NOTSAND")
defineTile('c', "CORAL1") 
defineTile('C', "CORAL2")
defineTile('G', "CORAL3")

defineTile("~", "WATER_DEEP_DEEP")
defineTile(":", "DEEP_WATER")


-- addSpot section

-- addZone section

-- ASCII map section
return [[
MMMMMMMMMMMMMMMMM~~~~~~~~~~~~~~~~~~~~cGC
M###############MMMMMMMMMMMMMMM:::::::cC
M#####__#########################m::::::
M#####____ppppppppp___________#p::::::::
M##_ppppppp_________####ppp___pp::::::::
M##____p__________________pp####:::::::>
M###___p_______________________#m:::::::
M###___p______________________##m:::::::
M#pppppp______pppp____________pmm::::::c
M###___p______p_______________pp::::::cC
M###___p______p_________p_____p:::::::GC
M###___p______p_________p_____pp:::::::G
M#ppppppppppppppppppppppp__pppp:::::::::
M#________________________##mmmmM:::::::
M############_#############mmm::::::::::
Mmmmmmmmm###___###mmmmmmmmMMMM::::::::::
Mmmmmmmmm##___####mmmmmM:MMMM:::::GGc:::
Mmmmmmm###___##mmmm:mMM:::MMM::::::CC:::
Mmmmmm###___###mmmm::mm:::MMM:::::::c:::
Mmmmmm##___p:::::::::::::::MMM::::::::::
Mmmmm##___p:::::::::::::::::::::::::::::
Mmppp##___p:::::::::::::::::::::::::GGCc
pppp####_#pp#pppmmmmmmm:::::::G::::::cCG
p______________pmmmmmmm:::::::CcG:::::cc
pp______________pmmmmmmmp:::::Gc::::::::
ppp_____________pmmmmmmmp::::::GC:::::::
<pp___________ppppmmmmmp::::::::cC::::::
pppp__________ppppppppppp::::::::::::::G
ppppppppppppppppppppppppp::::::::::::ccC
MMMMMMMMMMMMMMMMMMMMMMMMp:~~~~~~~~~~GGCG]]

