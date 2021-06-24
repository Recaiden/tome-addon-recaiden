name = "First Steps"
desc = function(self, who)
   local desc = {}
   desc[#desc+1] = "You've landed on Eyal.\n"
   desc[#desc+1] = "First, terminate any eyalite that might be an immediate threat.\n"
	 desc[#desc+1] = "Then, head southeast and rendevous with the water-imp agents in the Lake of Nur.\n"
	 if self:isStatus(self.COMPLETED, "landing") then desc[#desc+1] = "#LIGHT_GREEN#* The landing zone has been purged of eyalites.#WHITE#" end
	if self:isStatus(self.COMPLETED, "imps") then desc[#desc+1] = "#LIGHT_GREEN#* The water imps' data has been recovered.#WHITE#" end

   return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
      who:setQuestStatus(self.id, engine.Quest.DONE)
      who:grantQuest("demon-dwarves")
			who:grantQuest("demon-derth")
   end
end
