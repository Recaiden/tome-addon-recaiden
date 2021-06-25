defineTile('<', "GRASS_UP")
defineTile('t', "TREE")
defineTile('~', "DEEP_WATER")
defineTile('.', "GRASS")
defineTile('-', "FIELDS")
defineTile('_', "GRASS_ROAD_STONE")
defineTile(',', "SAND")
defineTile('!', "ROCK")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('=', "LAVA")
defineTile("?", "OLD_FLOOR")
defineTile(":", "FLOOR")
defineTile("&", "POST")
defineTile("'", "DOOR")

defineTile('2', "DOOR")
defineTile('5', "DOOR")
defineTile('6', "DOOR")
defineTile('3', "DOOR")
defineTile('1', "DOOR")
defineTile('4', "DOOR")
defineTile('9', "DOOR")
defineTile('a', "DOOR")
defineTile('b', "DOOR")

startx = 0
starty = 20

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttt~~~~~~~~~~~~tttttttttttttttttttt
tttttttttttttttt~~~~~~~~~~~~~~~~~ttttttttttttttttt
ttttttttttttttt~~~~~~~~~~~~~~~~~~~~ttttttttttttttt
tttttttttttttt~~~~~~ttttttt~~~~~~~~~~ttttttttttttt
ttttttttttttt~~~~~ttt.....tttttt~~~~~~~ttttttttttt
tttttttttttt~~~~~tt............ttt~~~~~~ttttttttt~
ttttttttttt~~~~~tt...............ttt~~~~ttttttt~~~
ttttttttttt~~~~tt..................tt~~~~ttttt~~~~
tttttttttt~~~~~t............######..tt~~~~tt~~~~~~
tttttttttt~~~~tt..######....#????#...tt~~~~~~~~~~~
ttttttttt~~~~~t...#????#....#????#....tt~~~~~~~~~~
ttttttttt~~~~tt...#????#....##b###.....tt~~~~~~~~~
ttttttttt~~~~t....###4##.....___........tt~~~~~~~t
ttttttttt~~~tt......___......._..........t~~~~~ttt
tttttttt~...t........_........_..........t~~~~tttt
tttttttt~...t........_........_..........t~~~~tttt
tttttttt~...t........_........_..........t~~~~tttt
<______________......_.......__..####....t~~~~tttt
<__________________.___.....__...#??#....tt~~~tttt
<______________...___._______....#9##.....t~~~tttt
ttttttt~~~~t.....__....._t_......___......t~~~tttt
tttttt~~~~~t....__......___......._.......t~~~tttt
tttttt~~~~~t....__......___......._.......t~~~tttt
tttttt~~~~~t..___........_.......__.......t~~~tttt
tttttt~~~~tt.__.........._......__........t~~~~ttt
tttttt~~~~t.._.#5#2#....._......_..####...t~~~~ttt
tttttt~~~~t.._.#???#....._.####._..#??#...t~~~~ttt
tttttt~~~~t.._.#???#....._.#??#._..#??#...t~~~~ttt
tttttt~~~~t.._.#####....___##a#._..#??#...t~~~~ttt
tttttt~~~~t.._______..___._.._.._..#??#...t~~~~ttt
tttttt~~~~t......._..__..._______..#6##..tt~~~~ttt
tttttt~~~~tt......_.._.........._.._.....t~~~~tttt
ttttttt~~~~tt.....____.####.....____.....t~~~~tttt
tttttttt~~~~tt......_..1??#....._.......tt~~~~tttt
tttttttt~~~~~tt.....__.#??#....._......tt~~~~~tttt
ttttttttt~~~~~ttt....__##3#....._.....tt~~~~tttttt
ttttttttttt~~~~~tt....___________...tt~~~~~ttttttt
tttttttttttt~~~~~ttttt............ttt~~~~~tttttttt
ttttttttttttt~~~~~~~~ttttttt...tttt~~~~~~~tttttttt
ttttttttttttttt~~~~~~~~~~~~ttttt~~~~~~~~~ttttttttt
tttttttttttttttttt~~~~~~~~~~~~~~~~~~~~~~tttttttttt
tttttttttttttttttttt~~~~~~~~~~~~~~~~~ttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt]]

--return [[
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- ttttttttttttttttttt~~~~~~~~~~ttttttttttttttttttttt
-- ttttttttttttttttt~~~~~~~~~~~~~~~tttttttttttttttttt
-- tttttttttttttttt~~~~~~~~~~~~~~~~~~tttttttttttttttt
-- ttttttttttttttt~~~~~ttttttt~~~~~~~~~tttttttttttttt
-- tttttttttttttt~~~~ttt.....tttttt~~~~~~tttttttttttt
-- ttttttttttttt~~~~tt............tt~~~~~~tttttttttt~
-- tttttttttttt~~~~tt..............ttt~~~~tttttttt~~~
-- tttttttttttt~~~tt.................ttt~~~tttttt~~~~
-- ttttttttttt~~~~t....................t~~~~ttt~~~~~~
-- ttttttttttt~~~tt..######....######...t~~~t~~~~~~~t
-- tttttttttt~~~~t...######....######...tt~~~~~~~~~~t
-- tttttttttt~~~tt...######....##b###....t~~~~~~~~ttt
-- tttttttttt~~~t....###4##.....___......tt~~~~~~tttt
-- tttttttttt~~tt......___......._........t~~~~tttttt
-- ttttttttt...t........_........_........t~~~ttttttt
-- <______________......_.......__........t~~~ttttttt
-- tttttttt...t.._____.___.....__..###....tt~~ttttttt
-- tttttttt~~~t......___._______...#9#.....t~~ttttttt
-- tttttttt~~~t.....__....._t_.....___.....t~~ttttttt
-- ttttttt~~~~t....__......___......_......t~~ttttttt
-- ttttttt~~~~t..___........_......__......t~~ttttttt
-- ttttttt~~~tt.__.........._......_.......t~~~tttttt
-- ttttttt~~~t.._.#####....._......_.###...t~~~tttttt
-- ttttttt~~~t.._.#####....._.####._.###...t~~~tttttt
-- ttttttt~~~t.._.#####....._.####._.###...t~~~tttttt
-- ttttttt~~~t.._.#5#2#....___##a#._.###...t~~~tttttt
-- ttttttt~~~t.._______..___._.._.._.###...t~~~tttttt
-- ttttttt~~~t......._..__..._______.#6#..tt~~~tttttt
-- ttttttt~~~tt......_.._.........._.._...t~~~ttttttt
-- tttttttt~~~tt.....____.####.....____...t~~~ttttttt
-- ttttttttt~~~tt......_..####....._......t~~~ttttttt
-- ttttttttt~~~~tt.....__.####....._.....tt~~~ttttttt
-- tttttttttt~~~~ttt....__1#3#....._.....t~~~tttttttt
-- tttttttttttt~~~~tt....___________...tt~~~~tttttttt
-- ttttttttttttt~~~~ttttt............ttt~~~~ttttttttt
-- tttttttttttttt~~~~~~~ttttttt...tttt~~~~~~ttttttttt
-- tttttttttttttttt~~~~~~~~~~~ttttt~~~~~~~~tttttttttt
-- ttttttttttttttttttt~~~~~~~~~~~~~~~~~~~~ttttttttttt
-- ttttttttttttttttttttt~~~~~~~~~~~~~~~tttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt
-- tttttttttttttttttttttttttttttttttttttttttttttttttt]]
