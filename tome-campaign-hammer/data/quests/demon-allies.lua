name = "The Old Ones"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Three demons have been trapped on Eyal since the disaster.  They could be useful to our cause.  Seek them out."

	if self:isCompleted("death-k") and self:isCompleted("death-s") then
		desc[#desc+1] = _t"#LIGHT_RED#Kryl-Feijan's resurrection failed, and without Shassy'Kaish, he has died his final death.#WHITE#"
	elseif self:isCompleted("death-k") then
		desc[#desc+1] = _t"#LIGHT_RED#Kryl-Feijan's resurrection failed.  There is still hope of reviving his seed, but he will not help you.#WHITE#"
	elseif self:isCompleted("help-k") then
		desc[#desc+1] = _t"#LIGHT_GREEN#Kryl-Feijan is reborn, and has pledged to aid you in taking revenge.#WHITE#"
	else
		desc[#desc+1] = _t"#RED#[UNIMPLEMENTED]#LIGHT_GREY#Seek out the wounded ancient Kryl-Feijan in his isolated crypt.#WHITE#"
	end

	if self:isCompleted("death-s") then
		desc[#desc+1] = _t"#LIGHT_RED#Shassy'Kaish has been killed and her cultists scattered.  Perhaps she will return one day, but she cannot help you.#WHITE#"
	elseif self:isCompleted("angry-s") then
		desc[#desc+1] = _t"#LIGHT_RED#The mad Shassy'Kaish has refused to help you.#WHITE#"
	elseif self:isCompleted("help-s") then
		desc[#desc+1] = _t"#LIGHT_GREEN#Shassy'Kaish will help you.  Probably.#WHITE#"
	else
		desc[#desc+1] = _t"#RED#[UNIMPLEMENTED]#LIGHT_GREY#Seek out the ancient explorer Shassy'Kaish among her cultists in the Daikara mountains.#WHITE#"
	end

	if self:isCompleted("death-w") then
		desc[#desc+1] = _t"#LIGHT_RED#Walrog is dead.  What a waste.  You really messed this up.#WHITE#"
	elseif self:isCompleted("help-w") then
		desc[#desc+1] = _t"#LIGHT_GREEN#Walrog has agreed to aid you in destroying the Allied Kingdoms.#WHITE#"
	else
		desc[#desc+1] = _t"#RED#[UNIMPLEMENTED]#LIGHT_GREY#Seek out the ancient necromancer Walrog along the ocean shore.#WHITE#"
	end

	if self:isCompleted("death-m") then
		desc[#desc+1] = _t"#LIGHT_RED#After all these years, the Messenger is dead.#WHITE#"
	elseif self:isCompleted("help-m") then
		desc[#desc+1] = _t"#LIGHT_GREEN#The Messenger has agreed to help you.#WHITE#"
	elseif (self:isCompleted("help-k") or self:isCompleted("help-s") or self:isCompleted("help-w"))
		desc[#desc+1] = _t"#LIGHT_GREY#You have heard of a fourth old one, the Onyx who carried news of Mal'rok's destruction and saved the others by shutting down the portal.  Find this Messenger.#WHITE#"
	end

	if self:isEnded() then
		desc[#desc+1] = "#LIGHT_GREEN#* You have found each of the old ones.#WHITE#"
	end
	
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if (self:isCompleted("death-k")
		and (self:isCompleted("death-s") or self:isCompleted("angry-s"))
		and self:isCompleted("death-w")
		and self:isCompleted("death-o")
	) then
		who:setQuestStatus(self.id, engine.Quest.FAILED)
	elseif ((self:isCompleted("death-k") or self:isCompleted("help-k"))
		and (self:isCompleted("death-s") or self:isCompleted("help-s") or self:isCompleted("angry-s"))
		and (self:isCompleted("death-w") or self:isCompleted("help-w"))
		and (self:isCompleted("death-m") or self:isCompleted("help-m"))
	) then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
