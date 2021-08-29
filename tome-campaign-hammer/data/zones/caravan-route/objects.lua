load("/data/general/objects/objects-maj-eyal.lua")
loadIfNot("/data/general/objects/world-artifacts-far-east.lua")
loadIfNot("/data/general/objects/boss-artifacts-far-east.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "journal-entry", lore="caravan-note-"..i.."-sc",
	desc = _t[[Scattered entries from a mercenary guard's journal.]],
	rarity = false,
	encumberance = 0,
}
end
