local equip_sets = {
	"twohander",
	"sword+shield",
	"sword+mindstar",
	"sword+dagger",
	"sword+hand",
	"sword+sword",
	"unarmed",
	"bow",
	"sling",
	"guns",
	"gun+shield",
	"staff",
	"mindstars",
	"daggers",
}


local equipFilter_Mindstars = resolvers.auto_equip_filters{
	MAINHAND = {type="weapon", subtype="mindstar"},
	OFFHAND = {type="weapon", subtype="mindstar"},
}

load("/data-enemy-egos/birth/warriors.lua")
load("/data-enemy-egos/birth/unarmed.lua")
load("/data-enemy-egos/birth/mages.lua")
load("/data-enemy-egos/birth/wilders.lua")
--load("/data-enemy-egos/birth/psionics.lua")
