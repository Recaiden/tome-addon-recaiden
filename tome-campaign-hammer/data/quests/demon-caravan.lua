name = "Supply Lines"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Observation of the eyalites has identified a caravan carrying critical supplies into the Allied Kingdoms."
	desc[#desc+1] = "It will be travelling between the eastern mountains and Last Hope."
	desc[#desc+1] = "Make sure it never arrives."
	if self:isStatus(self.COMPLETED) then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed the supply caravan.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
