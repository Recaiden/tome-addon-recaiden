name = "Invaders Invaded"
desc = function(self, who)
   local desc = {}
   desc[#desc+1] = "The fearscape was in position.  The armies were ready.  The research was done.  Then a vast horde of void creatures descended.\n"
   desc[#desc+1] = "Fight them off, and take back the portal!\n"
   if self:isCompleted("secured") then
      desc[#desc+1] = "The portal is secure once again.  The invasion begins!"
   end
   return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
      who:setQuestStatus(self.id, engine.Quest.DONE)
      who:grantQuest("demon-landing")
   end
end
