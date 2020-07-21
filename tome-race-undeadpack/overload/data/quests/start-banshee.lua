name = "Waking Up"
desc = function(self, who)
   local desc = {}
   desc[#desc+1] = "You were kidnapped, held captive, and finally murdered.\n"
   desc[#desc+1] = "However, that wasn't the end.  You awoke in a shallow grave, your spirit tied to Eyal by the injustice of your death. Take your revenge, and then...who knows?\n"
   if self:isCompleted("black-cloak") then
      desc[#desc+1] = "You have retrieved a peculair cloak that should help you walk among the living without trouble."
   end
   return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
      who:setQuestStatus(self.id, engine.Quest.DONE)
      who:grantQuest("start-banshee")
   end
end
