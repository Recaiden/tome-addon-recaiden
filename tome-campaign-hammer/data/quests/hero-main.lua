name = "The End of Vengeance"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The peoples of Maj'Eyal were victims of the Spellblaze just like you. Those responsible have already been annihilated by their own folly."
	desc[#desc+1] = _t"Allowing the invasion to continue would be an inexcusable disaster."

	if self:isCompleted("beachhead") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Eyalside beachhead has been overrun, and most of the demons evacuated back to the fearscape.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* Stage an attack on the beachhead to force Khulmanar to retreat from his offensive.#WHITE#"
	end
	if self:isCompleted("portals-1") and self:isCompleted("portals-2") and self:isCompleted("portals-3") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The primary portal facilty is in ruins - stopping any further assaults for now.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* Shut down the portal stabilizers to stop the demons resuming the invasion.#WHITE#"
	end
	if self:isCompleted("khulmanar-talk") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* Khulmanar has accepted your proof and ordered the armies of the fearscape to stand down.#WHITE#"
		desc[#desc+1] = _t"You have won the game!"
	elseif self:isCompleted("khulmanar-dead") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* Khulmanar lies dead at your feet.  You have proven yourself the most blessed of Urh'rok's children.#WHITE#"
		desc[#desc+1] = _t"You have won the game!"
	else
		desc[#desc+1] = _t"#SLATE#* Khulmanar must stop the campaign, one way or another.#WHITE#"
	end

	if self:isCompleted("angolwen") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* Linaniil is dead.  The last person on the planet remotely responsible for the Spellblaze has been brought to justice..#WHITE#"
		desc[#desc+1] = _t"You have won the game - and then some!"
	end
	return table.concat(desc, "\n")
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = _t"#GOLD#Well done! You have won the Tales of Maj'Eyal: The Hammer of Urh'Rok#WHITE#"
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"The General has fallen, and the long-awaited invasion is suddenly over."
	desc[#desc+1] = _t"Though countless Mal'rokka and Eyalites alike died thanks to your efforts, now, there is hope."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"Perhaps you have saved your people, or perhaps you have wasted their last chance.  Only time will tell."

	desc[#desc+1] = _t""
	desc[#desc+1] = _t"For now, you may continue playing and enjoy the rest of the world."
	
	return 0, desc
end


function win(self, how)
	game:playAndStopMusic("Lords of the Sky.ogg")
	
	local p = game:getPlayer(true)
	if p.hammer_timemark then p.hammer_timecrash = true end
	p:inventoryApplyAll(function(inven, item, o) o:check("on_win") end)
	self:triggerHook{"Winner", how=how, kind="khulmanar"}

	-- grant achievements
	world:gainAchievement("HAMMER_WIN", p)
	local kryl = game.level:findEntity{define_as="KRYL_FEIJAN_REBORN"}
	if kryl and not kryl.dead then world:gainAchievement("HAMMER_WIN_KRYL", p) end
	local mel = game.level:findEntity{define_as="DOOMBRINGER_MELINDA"}
	if mel and not mel.dead then world:gainAchievement("HAMMER_WIN_MELINDA", p) end
	local broughtKryl = p:hasQuest("campaign-hammer+demon-allies") and p:hasQuest("campaign-hammer+demon-allies"):isCompleted("help-k")
	local broughtMel = p:hasQuest("campaign-hammer+demon-allies") and p:hasQuest("campaign-hammer+demon-allies"):isCompleted("saved-melinda")
	if not broughtKryl and not broughtMel then world:gainAchievement("HAMMER_WIN_ALONE", p) end
	
	-- unlocks
	game:setAllowedBuild("adventurer", true)
	if game.difficulty == game.DIFFICULTY_NIGHTMARE then game:setAllowedBuild("difficulty_insane", true) end
	if game.difficulty == game.DIFFICULTY_INSANE then game:setAllowedBuild("difficulty_madness", true) end
	
	p.winner = "khulmanar"
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
			--game:setAllowedBuild("hammer_race_demon", true)
			
			local Chat = require"engine.Chat"
			local chat = Chat.new("campaign-hammer+demon-rebel-end", {name=_t"Endgame", image="portrait/win.png"}, game:getPlayer(true))
			chat:invoke()

		end
	end
end
