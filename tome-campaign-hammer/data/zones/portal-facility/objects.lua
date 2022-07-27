load("/data-campaign-hammer/general/objects/objects.lua")

for i = 1, 5 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "stone slate", lore="buried-kingdom-note-"..i,
	desc = _t[[Records carved by the long-dead human inhabitants of the kingdom.]],
	rarity = false,
	encumberance = 0,
}
end
