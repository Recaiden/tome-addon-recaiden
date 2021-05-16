name = "Invasion Invaded"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Creatures from the void are swarming onto the fearscape!"
	desc[#desc+1] = "They must be driven away from the portals before the invasion can commence."
	if self:isStatus(self.DONE) then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed the void creatures.#WHITE#"
	else
		desc[#desc+1] = "#LIGHT_GREY#* You must reach the portal to Eyal and ensure it is safe fromt he monsters.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("campaign-hammer+landing")

		require("engine.ui.Dialog"):simpleLongPopup("To the surface!", [[The portal is secured.  Now, pass through it to the surface of Eyal, and let the invasion begin!]], 500)
	end
end
