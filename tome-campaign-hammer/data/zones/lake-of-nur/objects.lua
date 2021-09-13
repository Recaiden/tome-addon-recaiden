load("/data/general/objects/objects-maj-eyal.lua")
loadIfNot("/data/general/objects/world-artifacts-far-east.lua")
loadIfNot("/data/general/objects/boss-artifacts-far-east.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "crystalline tablets", lore="demon-nur-note-"..i, image = "terrain/malrok_wall/crystalline_tablets.png",
	desc = _t[[A pile of crystalline tablets, holding the water imps' observations]],
	rarity = false,
	encumberance = 0,
}
end
