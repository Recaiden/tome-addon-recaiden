long_name = "Cleaner Item Descriptions"
short_name = "cleaner-descriptions" -- Determines the name of your addon's file.
for_module = "tome"
version = {1,7,0}
addon_version = {1,0,2}
weight = 49 -- needs to load before ZOmnibus for compatability
author = {"Recaiden"}
homepage = ''
description = [[This is a fork of Better Item Descriptions that simply makes the tooltip larger and uses long phrases instead of abbreviations.
Works with zOmnibus's inscription-compare feature
- sorts all stats by category
- item's passive power always the same blue color
- item's usable power - always yellow
- all rarity categories are displayed
- encumbrance value moved to the right under item name
- "on hit" powers always green
- "Stats" have an orange highlight and placed before others]]
tags = {'interface','item','description','better','tooltip'} -- tags MUST immediately follow description

superload = true
hooks = true