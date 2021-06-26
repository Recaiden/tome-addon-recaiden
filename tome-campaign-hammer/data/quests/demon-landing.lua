name = "The Beachhead"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You've landed on Eyal.\n"
	desc[#desc+1] = "First, terminate any eyalite that might be an immediate threat.\n"
	--desc[#desc+1] = "Then, head southeast and rendevous with the water-imp agents in the Lake of Nur.\n"
	if self:isStatus(self.COMPLETED, "landing") then desc[#desc+1] = "#LIGHT_GREEN#* The landing zone has been purged of eyalites.#WHITE#" end
	--if self:isStatus(self.COMPLETED, "imps") then desc[#desc+1] = "#LIGHT_GREEN#* The water imps' data has been recovered.#WHITE#" end
	
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted("landing") and not who:isQuestStatus("campaign-hammer+demon-landing", engine.Quest.DONE) then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("campaign-hammer+demon-main")

		require("engine.ui.Dialog"):simpleLongPopup("Beachhead!", [[Other demons are assigned to fortify the landing site, improve the portal, and bring through the fearscape's armies.  Your job is to head southeast and rendevous with the water-imp agents in the Lake of Nur.]], 500)
	end
end
