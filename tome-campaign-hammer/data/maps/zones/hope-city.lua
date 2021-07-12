quickEntity('@', {show_tooltip=true, name=_t"Statue of King Tolak the Fair", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_tolak.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-tolak-statue") end return true end})
quickEntity('Z', {show_tooltip=true, name=_t"Statue of King Toknor the Brave", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_toknor.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-toknor-statue") end return true end})
quickEntity('Y', {show_tooltip=true, name=_t"Statue of Queen Mirvenia the Inspirer", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_mirvenia.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-mirvenia-statue") end return true end})
quickEntity('X', {show_tooltip=true, name=_t"Declaration of the Unification of the Allied Kingdoms", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/monument_allied_kingdoms.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-allied-kingdoms-foundation") end return true end})

-- defineTile section
defineTile("<", "GRASS_UP8")
defineTile(">", "GRASS_DOWN8")

defineTile("#", "HARDWALL")
defineTile("&", "HARDMOUNTAIN_WALL")
defineTile("~", "DEEP_WATER")
defineTile("_", "FLOOR_ROAD_STONE")
defineTile("-", "GRASS_ROAD_STONE")
defineTile(".", "GRASS")
defineTile("t", "TREE")
defineTile(" ", "FLOOR")

defineTile("g", "FLOOR", nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='humanoid', faction="allied-kingdoms"}})
defineTile("G", "FLOOR", nil, {random_filter={type='humanoid', faction="allied-kingdoms", random_boss={nb_classes=1, loot_quality="store", loot_quantity=3, ai_move="move_complex", rank=3.5,}}})

startx = 25
starty = 0
endx = 25
endy = 27

-- ASCII map section
return [[
ttttttttttttttttttttttttt<tttttttttttttttttttttttt
ttttttttttttttttttttt~~~X-X~~~tttttttttttttttttttt
ttttttttttttttttt~~~~~~~.-.~~~~~~~tttttttttttttttt
ttttttttttttttt~~~~~~~~~.-.~~~~~~~~~tttttttttttttt
ttttttttttttt~~~~~~~~####.####~~~~~~~~tttttttttttt
tttttttttttt~~~~~~####gg___gg####~~~~~~ttttttttttt
tttttttttt~~~~~~###   _ gGg _   ###~~~~~~ttttttttt
ttttttttt~~~~~###     _ ### _     ###~~~~~tttttttt
tttttttt~~~~~##       _ ### _       ##~~~~~ttttttt
ttttttt~~~~###      ___ ### ___      ###~~~~tttttt
tttttt~~~~##       __   ###   __       ##~~~~ttttt
tttttt~~~##    #  __  #######  __       ##~~~ttttt
ttttt~~~~#    ### _  #### ####  _  #     #~~~~tttt
tttt~~~~##   #### _ ###     ### _ ###    ##~~~~ttt
tttt~~~##   ###   _ #         # _ ####    ##~~~ttt
ttt~~~~#     ##   _  _________  _   ###    #~~~~tt
ttt~~~##          ____~~~_~~~____   ##     ##~~~tt
tt~~~~#  ###      __~~~##.##~~~__           #~~~~t
tt~~~##  ###     __~~###@.t###~~__          ##~~~t
tt~~~#   ###    __~~##ttY-Ztt##~~__          #~~~t
tt~~~#       ## _~~##tt-----tt##~~_ ##       #~~~t
t~~~##      ## __~##t---&-&---t##~__ ##      ##~~~
t~~~#      ### _~~#tt-&&&-&&&-tt#~~_ ###      #~~~
t~~~#      ##  _~##t--&&---&&--t##~_  ##      #~~~
t~~~#  ######  _~#tt-&&-###-&&-tt#~_  ######  #~~~
t~~~#  #####   _~#tt-&&-###-&&-tt#~_   #####  #~~~
t~~~#  ######  _~#tt-&&-->--&&-tt#~_  ######  #~~~
t~~~#      ##  _~##t--&&---&&--t##~_  ##      #~~~
t~~~#      ### _~~#tt-&&&&&&&-tt#~~_ ###      #~~~
t~~~##      ## __~##t---&&&---t##~__ ##      ##~~~
tt~~~#       ## _~~##tt-----tt##~~_ ##       #~~~t
tt~~~#          __~~##ttttttt##~~__          #~~~t
tt~~~##          __~~###ttt###~~__          ##~~~t
tt~~~~#           __~~~#####~~~__           #~~~~t
ttt~~~##           ___~~~~~~~___     ##    ##~~~tt
ttt~~~~#     ##      _________       ###   #~~~~tt
tttt~~~##   ###     #         #    ####   ##~~~ttt
tttt~~~~##   ####   ###     ###    ###   ##~~~~ttt
ttttt~~~~#    ###    #### ####      #    #~~~~tttt
tttttt~~~##    #      #######           ##~~~ttttt
tttttt~~~~##            ###            ##~~~~ttttt
ttttttt~~~~###          ###          ###~~~~tttttt
tttttttt~~~~~##         ###         ##~~~~~ttttttt
ttttttttt~~~~~###       ###       ###~~~~~tttttttt
tttttttttt~~~~~~###             ###~~~~~~ttttttttt
tttttttttttt~~~~~~####       ####~~~~~~ttttttttttt
ttttttttttttt~~~~~~~~#########~~~~~~~~tttttttttttt
ttttttttttttttt~~~~~~~~~~~~~~~~~~~~~tttttttttttttt
ttttttttttttttttt~~~~~~~~~~~~~~~~~tttttttttttttttt
ttttttttttttttttttttt~~~~~~~~~tttttttttttttttttttt]]
