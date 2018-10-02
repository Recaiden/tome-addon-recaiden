long_name = "Playable Mummy Race"
short_name = "mummyrace"
for_module = "tome"
version = {1,4,8}
addon_version = {1, 3, 0}
weight = 100
author = { 'Recaiden' }
description = [[Adds Mummies as a new type of undead that cripple their enemies and overcome any obstacle.

Embalming increases Strength and Willpower
Entangle wraps up an enemy with animate bandages, slowing them over time
Inevitability wears away at the resistances of your enemies while increasing your own

Uniquely, they have a small secondary racial tree that removes detrimental effects

Mummies begin in a unique starting zone of their own.

Mummies are unlocked in exactly the way you would expect.]]
tags = {'undead', "mummy", 'race'} -- tags MUST immediately follow description

hooks = true
overload = true
superload = false
data = true


-- TODO
-- Give mummy wraps on start

--1.3.0 - Added unlock condition
--1.2.2 - Fixed typos, nerfed the golem guardian, made non-mummies have to start at the top level
--1.2.1 - Moved the starting zone to not overlap with More Tales
--1.2.0
--Proper starter Zone

--1.1.0
--Basic playable starter zone

--1.0.3
-- Canopic - Breath no longer generates vim and requires level 12
-- final racial talent renamed (too similar to brawler stat synergy generic)
-- fire resistance works on raw talent level (caps out at neutral 50%)
-- refactoring - fire resistance is a racial feature not a talent

--1.0.2 - more specific talent descriptions
