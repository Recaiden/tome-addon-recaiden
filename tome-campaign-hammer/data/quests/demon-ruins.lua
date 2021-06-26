name = "What Lies Beneath"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Strange energies of unusual strength have been detected beneath the western sands."
	desc[#desc+1] = "Perhaps they could prove useful in our struggle for revenge."
	desc[#desc+1] = "Investigate."
	if self:isStatus(self.COMPLETED) then
		desc[#desc+1] = "#LIGHT_GREEN#* You have pacified the ruins and claimed their power for demonkind.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)

		require("engine.ui.Dialog"):simpleLongPopup("Onwards!", [[With this, your preparations are ready.  It is time for a final confrontation with the Allied Kingdoms. Head east, towards their capital of Last Hope.]], 500)
	end
end
