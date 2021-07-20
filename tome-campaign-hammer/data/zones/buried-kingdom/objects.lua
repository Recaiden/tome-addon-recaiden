load("/data/general/objects/objects-maj-eyal.lua")
load("/data/general/objects/objects-far-east.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "stone slate", lore="buried-kingdom-note-"..i,
	desc = _t[[Records carved by the long-dead human inhabitants of the kingdom.]],
	rarity = false,
	encumberance = 0,
}
end
