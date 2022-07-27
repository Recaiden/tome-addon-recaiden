load("/data-campaign-hammer/general/objects/objects.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "demonic documents", lore="orbital-platform-note-"..i,
	desc = _t[[Writings prepared by demons for temporary use, or before encoding them into memory crystals.]],
	rarity = false,
	encumberance = 0,
}
end
