startx = 0
starty = 6
endx = 22
endy = 8

-- defineTile section
defineTile('<', "CAVE_LADDER_UP_WILDERNESS")
defineTile('>', "CAVE_LADDER_ON")
defineTile('#', "CAVEWALL")
defineTile(' ', "CAVEFLOOR")
defineTile('S', "CAVEFLOOR", nil, "SHASSY")
defineTile('c', "CAVEFLOOR", nil, "CULTIST")
defineTile('^', "MONOLITH")


-- addSpot section

-- addZone section
 
-- ASCII map section
return [[
########################
#                      #
# ^        c         ^ #
#          ^           #
#   ^              ^   #
#                cc    #
<        S             #
#                      #
#   ^              ^   >
#          ^           #
# ^        c         ^ #
#                 c    #
########################]]

