defineTile('<', "GRASS_UP4")
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

defineTile('U', "GRASS_ROAD_STONE", nil, "URKIS_IN_TOWN")

startx = 0
starty = 20

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttt~~~~~~~~~~~~tttttttttttttttttttt
tttttttttttttttt~~~~~~~~~~~~~~~~~ttttttttttttttttt
ttttttttttttttt~~~~~~~~~~~~~~~~~~~~ttttttttttttttt
tttttttttttttt~~~~ttttttttttt~~~~~~~~ttttttttttttt
ttttttttttttt~~~ttt.........tttttt~~~~~ttttttttttt
tttttttttt~~~~~tt................ttt~~~~~tttttttt~
ttttttttt~~~~~tt...................ttt~~~tttttt~~~
tttttttt~~~tttt......................tt~~~~ttt~~~~
ttttttt~~~tttt...#######....######....tt~~~~~~~~~~
tttttt~~~ttttt...#?????#....#????#.....tt~~~~~~~~~
ttttt~~~~tttt....#?????#....#????#......ttt~~~~~~~
tttt~~~tttttt....#?????#....##b###.......tt~~~~~~~
ttt~~~tttttt.....####4##.....___..........tt~~~~~t
~~~~~ttttttt........___......._............t~~~ttt
~~~~ttttttt.........._........_............t~~~ttt
~~~tttttttt.........._........_............t~~~ttt
ttttttttttt.........._........_..#####.....t~~~ttt
<______________......_.......__..#???#.....t~~~ttt
<__________________.___.....__...#???#.....tt~~ttt
<______________...___._______....#9###......t~~ttt
tttttttttt.......__....._tU......___........t~~ttt
~ttttttttt......__......___......._.........t~~ttt
~~tttttttt......__......___......._.........t~~ttt
~~~ttttttt....___........_.......__.........t~~ttt
~~~ttttttt...__.........._......__..........t~~~tt
t~~~ttttt...._.#5#2#....._......_..####.....t~~~tt
t~~~~tttt...._.#???#....._.####._..#??#.....t~~~tt
tt~~~~ttt...._.#???#....._.#??#._..#??#.....t~~~tt
ttt~~~~tt...._.#####....___##a#._..#??#.....t~~~tt
tttt~~~tt...._______..___._.._.._..#??#.....t~~~tt
ttttt~~~t........._..__..._______..#6##....tt~~~tt
ttttt~~~tt........_.._.........._.._.......t~~~ttt
tttttt~~~tt.......____.####.....____.......t~~~ttt
ttttttt~~~tt........_..1??#....._.........tt~~~ttt
ttttttt~~~~tt.......__.#??#....._........tt~~~~ttt
tttttttt~~~~ttt......__##3#....._......ttt~~~ttttt
tttttttttt~~~~tt......___________.....tt~~~~~ttttt
ttttttttttt~~~~ttttt................ttt~~~~~tttttt
tttttttttttt~~~~~~~ttttttt.......tttt~~~~~~ttttttt
tttttttttttttt~~~~~~~~~ttttttttttt~~~~~~~~tttttttt
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
