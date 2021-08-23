name = "The Fall of Maj'Eyal"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The peoples of Maj'Eyal are divided into many different kingdoms and organizations.  Their power must be broken so that they may be punished properly."
	desc[#desc+1] = _t"The largest resistance is expected to come from the wizards of Angolwen.  Khulmanar has taken the bulk of our forces to confront them."
	--if self:isCompleted("north") then
	--desc[#desc+1] = _t"#LIGHT_GREEN#* The northern regions have been reduced to a lifeless waste.#WHITE#"
	desc[#desc+1] = _t"The Ambassador has been assigned to deal with scattered groups all throughout the northern reaches of Maj'Eyal."
	desc[#desc+1] = _t"Your job will be to sabotage, assassinate, and destroy various targets to weaken the Eyalites."

	if self:isCompleted("waterimp") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The sher'tul-made horrors beneath the lake overwhelmed the imps, but you managed to recover their records.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* Our water imp agents in the lake of Nur have stopped reporting.  Investigate.#WHITE#"
	end
	if self:isCompleted("dwarves") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* It turns out that dwarves aren't Eyalites at all.  The decision has been made to consider them fellow victims of the Sher'tul, and specialists dispatched to handle them appropriately.  They seem quite responsive to offers of material goods...#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must bring down the dwarven kingdom of the Iron Throne.#WHITE#"
	end
	if self:isCompleted("derth") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* One way or another, Derth lies in ruins.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must destroy the town of Derth, a focal point of Allied agriculture and trade.#WHITE#"
	end
	if self:isCompleted("crystals-2") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The unbound crystal beings have laid waste to Elvala.  It will be easy to round up the survivors.#WHITE#"
	elseif self:isCompleted("crystals") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Rhaloren are defeated, giving you full access to the scintillating caves.#WHITE#"
	elseif self:isCompleted("rhalore") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* Your Rhaloren allies have plunged Elvala into chaos.  It will be easy to round up the survivors.#WHITE#" 
	else
		desc[#desc+1] = _t"#SLATE#* In the southern forests is a hidden city of elves.  Find a way to defeat them.#WHITE#"
	end
	if self:isCompleted("thalore") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Thaloren counterattack has been defeated, and the incineration of their forests is proceeding according to schedule.#WHITE#"
	--else
		--desc[#desc+1] = _t"#SLATE#* When the time comes, destroy the Thaloren elves.#WHITE#"
	end
	-- if self:isCompleted("zigur") then
	-- 	desc[#desc+1] = _t"#LIGHT_GREEN#* There was once an organization of anti-mages working in these lands, but their headquarters is now a blighted ruin.  How convenient.#WHITE#"
	-- else
	-- 	desc[#desc+1] = _t"#SLATE#* On the shores of the Sea of Sash is a town of antimagic adherents.  Destroy them.#WHITE#"
	-- end

	local statusRuins = who:hasQuest("campaign-hammer+demon-ruins") and who:hasQuest("campaign-hammer+demon-ruins"):isCompleted()
	if self:isCompleted("last-hope") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Allied Kingdom leadership is destroyed.  Victory is certain.#WHITE#"
		desc[#desc+1] = _t"You have won the game!"
	elseif not statusRuins then
		desc[#desc+1] = _t"#SLATE#* You must gather your strength before dealing with Last Hope.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must join the attack on Last Hope and kill King Tolak!#WHITE#"
	end
	if self:isCompleted("angolwen") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* Linaniil is dead, and Angolwen has fallen.  There is no one and nothing left now to fight you.#WHITE#"
		desc[#desc+1] = _t"You have won the game - and then some!"
	end
	return table.concat(desc, "\n")
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = _t"#GOLD#Well done! You have won the Tales of Maj'Eyal: The Hammer of Urh'Rok#WHITE#"
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"The King is dead, and the Allied Kingdoms lie in ruins, thanks to your efforts."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"Maj'Eyal will fall into the demons' hands. Eventually, all trace of the sher'tul will be wiped out."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"You have done your duty."

	desc[#desc+1] = _t""
	desc[#desc+1] = _t"You may continue playing and enjoy the rest of the world."
	
	return 0, desc
end


function win(self, how)
	game:playAndStopMusic("Lords of the Sky.ogg")
	
	local p = game:getPlayer(true)
	p:inventoryApplyAll(function(inven, item, o) o:check("on_win") end)
	self:triggerHook{"Winner", how=how, kind="tolak"}

	-- grant achievements
	world:gainAchievement("HAMMER_WIN", p)
	local kryl = game.level:findEntity{define_as="KRYL_FEIJAN_REBORN"}
	if kryl and not kryl.dead then world:gainAchievement("HAMMER_WIN_KRYL", p) end
	local mel = game.level:findEntity{define_as="DOOMBRINGER_MELINDA"}
	if mel and not mel.dead then world:gainAchievement("HAMMER_WIN_MELINDA", p) end
	local broughtKryl = who:hasQuest("campaign-hammer+demon-allies") and who:hasQuest("campaign-hammer+demon-allies"):isCompleted("help-k")
	local broughtMel = who:hasQuest("campaign-hammer+demon-allies") and who:hasQuest("campaign-hammer+demon-allies"):isCompleted("saved-melinda")
	if not broguhtKryl and not broughtMel then world:gainAchievement("HAMMER_WIN_ALONE", p) end
	
	-- unlocks
	game:setAllowedBuild("adventurer", true)
	if game.difficulty == game.DIFFICULTY_NIGHTMARE then game:setAllowedBuild("difficulty_insane", true) end
	if game.difficulty == game.DIFFICULTY_INSANE then game:setAllowedBuild("difficulty_madness", true) end
	
	p.winner = "tolak"
	game:registerDialog(require("engine.dialogs.ShowText").new(_t"Winner", "win", {playername=p.name, how=how}, game.w * 0.6))
	
	if not config.settings.cheat then game:saveGame() end
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("last-hope") and not who:isQuestStatus("demon-main", engine.Quest.DONE) then
			self.use_ui = "quest-win"
			who:setQuestStatus(self.id, engine.Quest.DONE)

			-- Remove all remaining hostiles
			-- for i = #game.level.e_array, 1, -1 do
			-- 	local e = game.level.e_array[i]
			-- 	if game.player:reactionToward(e) < 0 then game.level:removeEntity(e) end
			-- end
			game:setAllowedBuild("hammer_race_demon", true)
			
			local Chat = require"engine.Chat"
			local chat = Chat.new("campaign-hammer+doombringer-end", {name=_t"Endgame", image="portrait/win.png"}, game:getPlayer(true))
			chat:invoke()

		end
	end
end
