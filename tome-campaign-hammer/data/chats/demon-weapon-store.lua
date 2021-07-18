newChat{ id="welcome",
	text = _t[[Welcome @playername@ to my shop.]],
	answers = {
		{_t"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{_t"I am looking for staff training.", jump="training-staff", cond=function(npc, player)
			 if player:knowTalentType("spell/staff-combat") and player:getTalentTypeMastery("spell/staff-combat") < 1.2 then return true end
		end},
		{_t"I am looking for mindstar training.", jump="training-mindstar", cond=function(npc, player)
			 if player:knowTalentType("wild-gift/mindtstar-mastery") and player:getTalentTypeMastery("wild-gift/mindtstar-mastery") < 1.2 then return true end
		end},
		{_t"I am looking for archery training", action=function(npc, player)
			game.logPlayer(player, "The weaponmaster spends some time with you, teaching you the basics of bows and slings.")
			player:incMoney(-8)
			player:learnTalent(player.T_SHOOT, true, nil, {no_unlearn=true})
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 8 then return end
			if player:knowTalent(player.T_SHOOT) then return end
			return true
		end},
		{_t"Sorry, I have to go!"},
	}
}

newChat{ id="training-staff",
	text = _t[[I can teach you staff combat (talent category Spell/Staff combat).  Learning the basics costs 500 gold.  Once you're proficient, I can teach you more refined techniques for an additional 750 gold.]],
	answers = {
		{("Teach me what I need to know (unlocks talent category) - %d gold."):tformat(500),
		action=function(npc, player) --Normal intensive training
			game.logPlayer(player, "The weaponmaster spends a substantial amount of time teaching you all of the techniques of staff combat.")
			player:incMoney(-500)
			player:learnTalentType("spell/staff-combat", true)
			if player:getTalentTypeMastery("spell/staff-combat") < 1 then -- Special case for previously locked category (escort)
				player:setTalentTypeMastery("spell/staff-combat", math.max(1.0, player:getTalentTypeMastery("spell/staff-combat", true) + 0.3))
			end
			if player:getTalentTypeMastery("spell/staff-combat") > 1 then
				game.logPlayer(player, "He is impressed with your mastery and shows you a few extra techniques.")
			end
			player.changed = true
		end,
		cond=function(npc, player)
			if player.money < 500 then return end
			if player:knowTalentType("spell/staff-combat") then return end
			return true
		end},
		{_t"I want to be an expert (improves talent mastery by 0.2) - 750 gold.", action=function(npc, player) --Enhanced intensive training
			player:incMoney(-750)
			player:learnTalentType("spell/staff-combat", true)
			player:setTalentTypeMastery("spell/staff-combat", player:getTalentTypeMastery("spell/staff-combat", true) + 0.2)
			game.logPlayer(player, ("The weaponmaster spends a great deal of time going over the finer details of staff combat with you%s."):tformat(player:getTalentTypeMastery("spell/staff-combat")>1 and _t", including some esoteric techniques" or ""))
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("spell/staff-combat") and player:getTalentTypeMastery("spell/staff-combat") < 1.2 then return true end
		end},
		{_t"No thanks."},
	}
}

newChat{ id="training-mindstar",
	text = _t[[I can teach you mindstar mastery (talent category Wild-gift/Mindstar mastery).  Learning the basics costs 500 gold.  Once you're proficient, I can teach you some additional skills for 750 gold.]],
	answers = {
		{_t"Teach me what I need to know (unlocks talent category) - 500 gold.", action=function(npc, player)
			game.logPlayer(player, "The shopkeeper spends a great deal of time going over the finer details of channeling energy through mindstars with you.")
			player:incMoney(-500)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1 then -- Special case for previously locked category (escort)
				player:setTalentTypeMastery("wild-gift/mindstar-mastery", math.max(1.0, player:getTalentTypeMastery("wild-gift/mindstar-mastery", true) + 0.3))
			end
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") > 1 then
				game.logPlayer(player, "He is impressed with your mastery and shows you a few tricks to handle stronger energy flows.")
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 500 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			return true
		end},
		{_t"I want to be an expert (improves talent mastery by 0.2) - 750 gold.", action=function(npc, player) --Enhanced intensive training
			player:incMoney(-750)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			player:setTalentTypeMastery("wild-gift/mindstar-mastery", player:getTalentTypeMastery("wild-gift/mindstar-mastery", true) + 0.2)
			game.logPlayer(player, ("The shopkeeper spends a great deal of time going over the finer details of channeling energy through mindstars with you%s."):tformat(player:getTalentTypeMastery("wild-gift/mindstar-mastery")>1 and _t", and teaches you enhanced mental discipline needed to maintain powerful energy fields" or ""))
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") and player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1.2 then return true end
		end},
		{_t"No thanks."},
	}
}

return "welcome"
