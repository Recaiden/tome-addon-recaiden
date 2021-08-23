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
M#####____PPPPPPPPP___________#P::::::::
M##_PPPPPPP_________####PPP___PP::::::::
M##____P__________________PP####:::::::>
M###___P_______________________#m:::::::
M###___P______________________##m:::::::
M#PPPPPP______PPPP____________Pmm::::::c
M###___P______P_______________PP::::::cC
M###___P______P_________P_____P:::::::GC
M###___P______P_________P_____PP:::::::G
M#PPPPPPPPPPPPPPPPPPPPPPP__PPPP:::::::::
M#________________________##mmmmM:::::::
M############_#############mmm::::::::::
Mmmmmmmmm###___###mmmmmmmmMMMM::::::::::
Mmmmmmmmm##___####mmmmmM:MMMM:::::GGc:::
Mmmmmmm###___##mmmm:mMM:::MMM::::::CC:::
Mmmmmm###___###mmmm::mm:::MMM:::::::c:::
Mmmmmm##___P:::::::::::::::MMM::::::::::
Mmmmm##___P:::::::::::::::::::::::::::::
MmPPP##___P:::::::::::::::::::::::::GGCc
PPPP####_#PP#PPPmmmmmmm:::::::G::::::cCG
P______________Pmmmmmmm:::::::CcG:::::cc
PP______________PmmmmmmmP:::::Gc::::::::
PPP_____________PmmmmmmmP::::::GC:::::::
<PP___________PPPPmmmmmP::::::::cC::::::
PPPP__________PPPPPPPPPPP::::::::::::::G
PPPPPPPPPPPPPPPPPPPPPPPPP::::::::::::ccC
MMMMMMMMMMMMMMMMMMMMMMMMP:~~~~~~~~~~GGCG]]

