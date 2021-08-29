load("/data/general/objects/objects-maj-eyal.lua")
loadIfNot("/data/general/objects/world-artifacts-far-east.lua")
loadIfNot("/data/general/objects/boss-artifacts-far-east.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "wooden sign", lore="demon-derth-note-"..i, image = "terrain/signpost.png",
	desc = _t[[Sturdy signs carved by the local farmers]],
	rarity = false,
	encumberance = 0,
}
end
