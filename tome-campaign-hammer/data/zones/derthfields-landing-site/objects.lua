load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 2 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "tattered paper scrap", lore="trollmire-note-"..i,
	desc = _t[[A paper scrap, left by an adventurer.]],
	rarity = false,
	encumberance = 0,
}
end
