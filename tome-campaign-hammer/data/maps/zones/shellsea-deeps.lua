startx = 0
starty = 5
endx = 18
endy = 7

-- defineTile section
defineTile('<', "WATER_UP")
defineTile('>', "WATER_DOWN")
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

defineTile('W', "DEEP_WATER", nil, "WALROG_HAMMER")


-- addSpot section

-- addZone section
 
-- ASCII map section
return [[
CGCCCcCcccCCCGCCCCCC
CCC:::::CcG:::::GGCC
cC::::::::::::::::GC
CC:::::::::G::CCCGGC
C::::C:::::::::::GCC
<::::::::W::::::::cC
C::::::c:::::::::::C
c::::::::::::::::::>
CGCc:::::CcG::Gcc:CC
CCCCGCCcGGGcCCCGCCGC]]

