newChat{ id="welcome",
	text = _t[[Welcome @playername@ to my shop.]],
	answers = {
		{_t"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{_t"Please train me in generic weapons and armour usage (costs 50 gold).", action=function(npc, player)
			game.logPlayer(player, "The armorer spends some time with you, teaching you the basics of armour and weapon usage.")
			player:incMoney(-50)
			player:learnTalentType("technique/combat-training", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 50 then return end
			if player:knowTalentType("technique/combat-training") then return end
			return true
		end},
		{_t"Sorry, I have to go!"},
	}
}

return "welcome"
