load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "LINANIIL_LECTURE",
	subtype = "lecture on humility", unique=true, no_unique_lore=true, not_in_stores=false,
	name = "Lecture on Humility by Archmage Linaniil", lore="angolwen-linaniil-lecture",
	desc = _t[[Lecture on Humility by Archmage Linaniil. A tale of the first ages and the Spellblaze.]],
	rarity = false,
	cost = 2,
}

newEntity{ base = "BASE_LORE",
	define_as = "TARELION_LECTURE_MAGIC",
	subtype = "magic teaching", unique=true, no_unique_lore=true, not_in_stores=false,
	name = "'What is Magic' by Archmage Tarelion", lore="angolwen-tarelion-magic",
	desc = _t[[Lecture on the nature of magic by Archmage Tarelion.]],
	rarity = false,
	cost = 2,
}
