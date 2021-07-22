load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 3 do
	newEntity{ base = "BASE_LORE",
						 define_as = "NOTE"..i,
						 name = "journal page", lore="landing-site-note-"..i,
						 desc = _t[[scraps of paper from a traveler's journal]],
						 rarity = false,
						 encumberance = 0,
	}
end
