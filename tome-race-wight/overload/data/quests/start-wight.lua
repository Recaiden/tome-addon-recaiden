name = "Unquiet Sleep"
desc = function(self, who)
   local desc = {}
   desc[#desc+1] = "You died in battle, long ago.\n"
   desc[#desc+1] = "However, that wasn't the end.  You haunted the place even as it was overgrown by wilderness and forgotten.  Now, after countless years, your grave has been disturbed.  Rise, and slay the interloper!\n"
   if self:isCompleted("start-wight") then
      desc[#desc+1] = "The graverobber is dead.  The bones sink back into their sleep.  But you remain, unable to move on.  You can sense that there is something deeply wrong with the world.  Twisting your ghostly form into a semblance of life, you set off to find out what."
   end
   return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
      who:setQuestStatus(self.id, engine.Quest.DONE)
      who:grantQuest("start-wight")
   end
end
