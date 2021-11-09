name = _t"Waking Up"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"You have been resurrected as an undead by your own dark powers.\n"
	desc[#desc+1] = _t"However, the ritual failed in some way.  Time has flown by and your memories are shattered. You need to find the way out of your laboratory-tomb and see if you can carve a place for yourself in this world.\n"
	if self:isCompleted("black-cloak") then
	   desc[#desc+1] = _t"You have retrieved a very special cloak that was made to help you walk among the living without trouble."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
   if self:isCompleted() then
      who:setQuestStatus(self.id, engine.Quest.DONE)
      who:grantQuest("start-mummy")
   end
end
