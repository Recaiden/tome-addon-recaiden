name = "Invasion Invaded"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The beachhead is under concentrated attack by Thaloren elves and the plants and animals of their forest."
	desc[#desc+1] = "Return at once and help fight them off!"
	if self:isStatus(self.DONE) then
		desc[#desc+1] = "#LIGHT_GREEN#* The Thaloren are defeated and the beachhead is safe.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted("victory") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("campaign-hammer+demon-ruins")
	end
end
