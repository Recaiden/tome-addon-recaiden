-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a strange triangular device, some kind of automated facility.*#WHITE#
It seems to be able to teach you the tinker crafting techniques, but requires input to do so (500 gold and a talent category point).]],
	answers = {
		{"[pay 500 gold and a talent category points]", jump="APE", action=function(npc, player)
			player:learnTalentType("steamtech/physics", true)
			player:learnTalentType("steamtech/chemistry", true)
			player:learnTalent(player.T_SMITH, true)
			player:learnTalent(player.T_THERAPEUTICS, true)
			player:incMoney(-500)
			player.unused_talents_types = player.unused_talents_types - 1

			-- From now on, drop tinker stuff
			game.state.birth.merge_tinkers_data = true

			game.log("#PURPLE#The %s teaches you: #GOLD#Steamtech/Physics#LAST#, #GOLD#Steamtech/Chemistry#LAST# and two starter crafting talents.", npc.name)
		end, cond=function(npc, player) return player.money >= 500 and player.unused_talents_types >= 1 and not player:knowTalent(player.T_CREATE_TINKER) end},
		{"[access store]", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player, npc.name)
		end, cond=function(npc, player) return player:knowTalent(player.T_CREATE_TINKER) end},
		{"[leave]"},
	}
}

newChat{ id="APE",
	text = [[The machine gives you a small metallic box labelled as #{italic}#"Automated Portable Extractor"#{normal}#.
It seems to be used to break down metallic items into lumps of metal and infusions into herbs which are used to craft tinkers.

#{bold}#You will have to choose to use it or the Transmogrification Chest when you destroy items. You can choose the default one by using it with no items to destroy.#{normal}#
]],
	answers = {
		{"[take it]", jump="welcome", action=function(npc, player)
			local base_list = require("mod.class.Object"):loadList("/data-orcs/general/objects/quest-artifacts.lua")
			base_list.__real_type = "object"
			local o = game.zone:makeEntityByName(game.level, base_list, "APE")
			if o then
				o.auto_hotkey = 1
				player:addObject(player.INVEN_INVEN, o)
				player:sortInven()
			end
		end},
	}
}

return "welcome"
