name = "The Hollow Crystal"
desc = function(self, who)
   local desc = {}
   desc[#desc+1] = "You were given a memory crystal to improve your skills.\n"
   desc[#desc+1] = "But it didn't have any memories in it.\n"
	 if self:isStatus(self.COMPLETED) then desc[#desc+1] = "#LIGHT_GREEN#* Oh.  The memory crystal is empty *now*, but it was full when you got it.  You just couldn't remember#WHITE#" end

   return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
		 who:setQuestStatus(self.id, engine.Quest.DONE)
		 who.unused_talents_types = (who.unused_talents_types or 0) + 1
   end
end
