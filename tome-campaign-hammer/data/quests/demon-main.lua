name = "The Fall of Maj'Eyal"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The peoples of Maj'Eyal are divided into many different kingdoms and organizations.  Their power must be broken so that they may be exterminated properly."
	if self:isCompleted("dwarves") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* It turns out that dwarves aren't Eyalites at all.  The decision has been made to consider them fellow victims of the Sher'tul.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must locate and destroy the dwarven kingdom of the Iron Throne.#WHITE#"
	end
	if self:isCompleted("derth") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* One way or another, Derth lies in ruins.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must destroy the town of Derth, a major focus of allied Agriculture.#WHITE#"
	end
	if self:isCompleted("shalore") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Rhaloren have plunged Elvala into chaos.  It will be easy to round up the survivors.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* In the southern forests is a hidden city of elves.  Find a way to destroy them.#WHITE#"
	end
	if self:isCompleted("thalore") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Thaloren counterattack has been defeated, and the incineration of their forests is proceeding according to schedule.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* When the time comes, destroy the Thaloren elves.#WHITE#"
	end
	if self:isCompleted("zigur") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* There was once an organization of anti-mages working in these lands, but their headquarters is now a blighted ruin.  How convenient.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* On the shores of the Sea of Sash is a town of antimagic adherents.  Destroy them.#WHITE#"
	end
	if self:isCompleted("north") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The northern regions have been reduced to a lifeless waste.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* There are scattered groups all throughout the northern reaches of Maj'Eyal. The Ambassador will deal with them.#WHITE#"
	end
	if self:isCompleted("last-hope") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Allied Kingdoms have lost their armies, and their leadership is destroyed.  Victory is certain.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must gather your strength and crush the Allied Kingdoms!#WHITE#"
	end
	if self:isCompleted("angolwen") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* Linaniil is dead, and Angolwen has fallen.  There is no one and nothing left now to fight you.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* The largest resistance is expected to come from the wizards of Angolwen.  Khulmanar will deal with them personally.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted("last-hope") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		--game:setAllowedBuild("race_demon", true)
	end
end
