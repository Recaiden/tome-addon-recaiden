-- defineTile section
defineTile('~', "SEA_EYAL")
defineTile('-', "RIVER")
defineTile('*', "LAKE_NUR")
defineTile(')', "SEA_SASH")
defineTile('(', "LAKE")
defineTile('W', "LAKE_WESTREACH")
defineTile('L', "LAKE_IRONDEEP")
defineTile('S', "LAKE_SPELLMURK")

defineTile('q', "VOLCANIC_MOUNTAIN")
defineTile('^', "MOUNTAIN")
defineTile('m', "DAIKARA_MOUNTAIN")
defineTile('#', "IRONTHRONE_MOUNTAIN")
defineTile('w', "GOLDEN_MOUNTAIN")

defineTile('p', "OASIS")
defineTile('t', "COLD_FOREST")
defineTile('_', "BURNT_FOREST")
defineTile('T', "FOREST")
defineTile('P', "PINE_FOREST")
defineTile('v', "OLD_FOREST")
defineTile('e', "ELVENWOOD_SNOW")
defineTile('E', "ELVENWOOD_GREEN")

defineTile('.', "PLAINS")
defineTile('|', "DESERT")

defineTile('"', "POLAR_CAP")
defineTile('=', "FROZEN_SEA")

defineTile('{', "CHARRED_SCAR")

defineTile('!', "LOW_HILLS")
defineTile('h', "LOW_HILLS")

defineTile('&', "CULTIVATION")

defineTile('j', "JUNGLE_FOREST")
defineTile('k', "JUNGLE_PLAINS")

defineTile("buried-kingdom", "BURIED_KINGDOM")
defineTile("daikara-hideout", "DAIKARA_HIDEOUT")
defineTile("derth-battle", "DERTH_INVASION")
defineTile("landing-site", "DERTHFIELDS_LANDING_SITE")
defineTile("fields-of-hope", "FIELDS_OF_HOPE")
defineTile("lake-of-nur", "LAKE_OF_NUR")
defineTile("scintillating-caverns", "SCINTILLATING_CAVERNS")
defineTile("fearscape-town", "TOWN_FEARSCAPE")

-- Load encounters for this map
--prepareEntitiesList("maj_eyal_encounters", "mod.class.Encounter", "/data/general/encounters/maj-eyal.lua")
prepareEntitiesList("maj_eyal_encounters_npcs", "mod.class.WorldNPC", "/data/general/encounters/maj-eyal-npcs.lua")
addData{
	wda = { script="campaign-hammer+hammer", zones={} },
}

-- addSpot section
addSpot({28, 13}, "playerpop", "hammer-demon")

addSpot({33, 40}, "patrol", "allied-kingdoms")
addSpot({24, 17}, "patrol", "allied-kingdoms")
addSpot({17, 39}, "patrol", "allied-kingdoms")
addSpot({41, 18}, "patrol", "allied-kingdoms")
addSpot({65, 11}, "patrol", "allied-kingdoms")
addSpot({60, 38}, "patrol", "allied-kingdoms")
addSpot({25, 26}, "hostile", "maj-eyal")
addSpot({26, 26}, "hostile", "maj-eyal")
addSpot({25, 27}, "hostile", "maj-eyal")
addSpot({26, 27}, "hostile", "maj-eyal")
addSpot({56, 13}, "hostile", "maj-eyal")
addSpot({57, 13}, "hostile", "maj-eyal")
addSpot({56, 14}, "hostile", "maj-eyal")
addSpot({57, 14}, "hostile", "maj-eyal")
addSpot({45, 43}, "hostile", "maj-eyal")
addSpot({46, 43}, "hostile", "maj-eyal")
addSpot({45, 44}, "hostile", "maj-eyal")
addSpot({46, 44}, "hostile", "maj-eyal")
addSpot({7, 25}, "hostile", "maj-eyal")
addSpot({8, 25}, "hostile", "maj-eyal")
addSpot({7, 26}, "hostile", "maj-eyal")
addSpot({8, 26}, "hostile", "maj-eyal")

-- ASCII map section
return {
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],[[~]],[[=]],[[=]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[["]],[["]],[["]],[["]],[[=]],[[m]],[[m]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[=]],[[=]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[["]],[[t]],[[t]],[[t]],[[=]],[[=]],[[=]],[[=]],[["]],[[t]],[["]],[["]],[["]],[["]],[["]],[[t]],[[m]],[[m]],[[m]],[[t]],[[t]],[["]],[["]],[["]],[["]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[=]],[[=]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[t]],[["]],[["]],[[=]],[[=]],[[=]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[[t]],[[t]],[[t]],[[t]],[["]],[[t]],[[m]],[[m]],[[m]],[[m]],[[m]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[["]],[["]],[["]],[[t]],[["]],[["]],[["]],[["]],[["]],[["]],[["]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[["]],[[t]],[[t]],[["]],[["]],[["]],[["]],[["]],[["]],[["]],[[t]],[[t]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[["]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[t]],[[t]],[["]],[["]],[["]],[["]],[["]],[[t]],[[t]],[["]],[["]],[["]],[["]],[["]],[["]],[["]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[~]],},
	{[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[=]],[[t]],[[t]],[[t]],[["]],[["]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[[t]],[[t]],[[t]],[["]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[["]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[["]],[[m]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[=]],[[=]],[[=]],[[~]],},
	{[[~]],[[=]],[[=]],[[=]],[[~]],[[~]],[[~]],[[=]],[[=]],[[=]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[[t]],[[t]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[["]],[["]],[["]],[["]],[["]],[[m]],[[m]],[[m]],[[m]],[[m]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[=]],[[=]],[[=]],},
	{[[~]],[[~]],[[=]],[[=]],[[=]],[[~]],[[~]],[[=]],[[=]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[e]],[[e]],[["]],[["]],[[e]],[[e]],[["]],[["]],[[m]],[[m]],[["]],[["]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[["]],[["]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[#]],[[#]],[[#]],[[=]],[[=]],[[~]],},
	{[[~]],[[=]],[[=]],[[=]],[[~]],[[~]],[[~]],[[=]],[[=]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[["]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[["]],[["]],[["]],[[m]],[[t]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[["]],[["]],[["]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[#]],[[#]],[["]],[[=]],[[=]],[[~]],},
	{[[~]],[[=]],[[~]],[[~]],[[=]],[[=]],[[~]],[[~]],[[=]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[P]],[[P]],[[!]],[[.]],[["]],[["]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[t]],[[m]],[[m]],[[m]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[m]],[[m]],[[m]],[[m]],[[m]],[[m]],[[!]],[[!]],[[P]],[[P]],[[!]],[[m]],[[m]],[[m]],[[m]],[["]],[["]],[["]],[["]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[["]],[["]],[["]],[[~]],[[~]],[[~]],},
	{[[~]],[[=]],[[~]],[[=]],[[=]],[[=]],[[~]],[[~]],[[=]],[[t]],[[t]],[[t]],[[t]],[[t]],[[P]],[[^]],[[^]],[[^]],[[!]],[[.]],[["]],[["]],[["]],[["]],[["]],[[.]],[[.]],[[.]],[[t]],[[t]],[[t]],[[t]],[[t]],[[m]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[e]],[[m]],[[m]],[[m]],[[m]],[[!]],[[P]],[[.]],[[.]],[[P]],[[!]],[[!]],[[daikara-hideout]],[[m]],[["]],[["]],[["]],[["]],[["]],[["]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[=]],[[=]],[[=]],[[=]],[[=]],[[t]],[[t]],[[P]],[[P]],[[^]],[[^]],[[^]],[[^]],[[!]],[[.]],[[.]],[["]],[["]],[["]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[t]],[[t]],[[t]],[[e]],[[e]],[[e]],[[e]],[[e]],[[E]],[[E]],[[E]],[[E]],[[E]],[[e]],[[e]],[[e]],[[e]],[[e]],[[m]],[[m]],[[!]],[[P]],[[P]],[[.]],[[.]],[[P]],[[!]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[["]],[["]],[["]],[[#]],[[#]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[#]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[=]],[[=]],[[=]],[[~]],[[=]],[[=]],[[=]],[[.]],[[P]],[[P]],[[P]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[landing-site]],[[T]],[[T]],[[t]],[[t]],[[E]],[[E]],[[e]],[[T]],[[.]],[[.]],[[!]],[[!]],[[!]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[-]],[[P]],[[P]],[[P]],[[P]],[[P]],[[P]],[[!]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[["]],[[T]],[[T]],[[#]],[[#]],[[#]],[[#]],[[#]],[["]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[=]],[[=]],[[~]],[[~]],[[~]],[[P]],[[P]],[[P]],[[P]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[E]],[[E]],[[E]],[[.]],[[.]],[[E]],[[!]],[[!]],[[!]],[[.]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[-]],[[P]],[[P]],[[P]],[[P]],[[P]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[[T]],[[T]],[[!]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[P]],[[P]],[[!]],[[!]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[!]],[[&]],[[&]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[.]],[[.]],[[T]],[[T]],[[T]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[!]],[[E]],[[E]],[[.]],[[E]],[[E]],[[E]],[[E]],[[-]],[[-]],[[P]],[[P]],[[P]],[[P]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[[T]],[[T]],[[T]],[[!]],[[!]],[[#]],[[#]],[[#]],[[#]],[["]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[.]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[&]],[[&]],[[&]],[[&]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[.]],[[E]],[[.]],[[.]],[[E]],[[E]],[[E]],[[-]],[[P]],[[P]],[[P]],[[P]],[[.]],[[.]],[[T]],[[!]],[[!]],[[!]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[!]],[[!]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[.]],[[T]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[&]],[[&]],[[&]],[[&]],[[.]],[[.]],[[derth-battle]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[E]],[[E]],[[E]],[[E]],[[.]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[E]],[[-]],[[!]],[[!]],[[P]],[[P]],[[P]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[!]],[[#]],[[#]],[[#]],[[#]],[["]],[["]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[|]],[[.]],[[T]],[[T]],[[T]],[[!]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[&]],[[&]],[[&]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[-]],[[-]],[[!]],[[!]],[[P]],[[P]],[[P]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[!]],[[-]],[[#]],[[#]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[|]],[[.]],[[T]],[[T]],[[T]],[[!]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[&]],[[&]],[[&]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[.]],[[!]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[[-]],[[!]],[[!]],[[!]],[[P]],[[P]],[[.]],[[.]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[T]],[[T]],[[T]],[[-]],[[#]],[[#]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[|]],[[.]],[[T]],[[T]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[v]],[[T]],[[.]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[.]],[[!]],[[^]],[[^]],[[!]],[[.]],[[.]],[[-]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[-]],[[#]],[[#]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[buried-kingdom]],[[|]],[[|]],[[T]],[[T]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[v]],[[v]],[[v]],[[v]],[[.]],[[.]],[[!]],[[!]],[[!]],[[^]],[[^]],[[!]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[-]],[[-]],[[!]],[[!]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[-]],[[-]],[[#]],[[#]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[T]],[[T]],[[!]],[[!]],[[^]],[[^]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[.]],[[v]],[[v]],[[v]],[[.]],[[v]],[[v]],[[v]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[.]],[[.]],[[-]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[-]],[[.]],[[#]],[[#]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[T]],[[T]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[v]],[[v]],[[v]],[[v]],[[v]],[[lake-of-nur]],[[v]],[[v]],[[v]],[[v]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[)]],[[)]],[[)]],[[)]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[.]],[[.]],[[T]],[[T]],[[T]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[-]],[[.]],[[!]],[[#]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[T]],[[T]],[[^]],[[^]],[[^]],[[^]],[[.]],[[!]],[[.]],[[.]],[[.]],[[.]],[[W]],[[W]],[[W]],[[.]],[[.]],[[.]],[[.]],[[v]],[[v]],[[*]],[[*]],[[-]],[[-]],[[v]],[[v]],[[v]],[[!]],[[!]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[.]],[[.]],[[T]],[[T]],[[.]],[[.]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[T]],[[T]],[[.]],[[.]],[[-]],[[.]],[[!]],[[!]],[[#]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[.]],[[T]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[W]],[[W]],[[W]],[[W]],[[W]],[[.]],[[.]],[[v]],[[v]],[[v]],[[*]],[[*]],[[v]],[[-]],[[-]],[[v]],[[v]],[[!]],[[!]],[[^]],[[^]],[[^]],[[!]],[[.]],[[.]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[T]],[[T]],[[.]],[[.]],[[-]],[[.]],[[.]],[[!]],[[#]],[[#]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[.]],[[T]],[[T]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[W]],[[W]],[[W]],[[W]],[[W]],[[.]],[[.]],[[.]],[[v]],[[v]],[[*]],[[*]],[[v]],[[v]],[[-]],[[-]],[[v]],[[v]],[[v]],[[^]],[[^]],[[^]],[[!]],[[.]],[[.]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[)]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[.]],[[L]],[[L]],[[.]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[T]],[[T]],[[T]],[[^]],[[^]],[[^]],[[-]],[[!]],[[!]],[[.]],[[.]],[[W]],[[W]],[[T]],[[T]],[[W]],[[W]],[[.]],[[.]],[[.]],[[-]],[[-]],[[-]],[[v]],[[v]],[[v]],[[v]],[[-]],[[-]],[[-]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[)]],[[)]],[[)]],[[)]],[[T]],[[)]],[[)]],[[)]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[L]],[[L]],[[L]],[[L]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[T]],[[T]],[[T]],[[^]],[[^]],[[!]],[[-]],[[-]],[[.]],[[.]],[[.]],[[W]],[[W]],[[T]],[[.]],[[.]],[[W]],[[.]],[[.]],[[-]],[[-]],[[v]],[[v]],[[v]],[[v]],[[v]],[[v]],[[v]],[[!]],[[-]],[[-]],[[-]],[[^]],[[^]],[[^]],[[.]],[[.]],[[-]],[[.]],[[)]],[[T]],[[T]],[[T]],[[)]],[[)]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[L]],[[L]],[[L]],[[L]],[[L]],[[L]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[.]],[[T]],[[^]],[[^]],[[^]],[[!]],[[!]],[[-]],[[-]],[[.]],[[.]],[[W]],[[W]],[[W]],[[W]],[[.]],[[W]],[[-]],[[-]],[[-]],[[v]],[[v]],[[v]],[[v]],[[v]],[[v]],[[!]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[-]],[[-]],[[-]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[-]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[L]],[[L]],[[L]],[[L]],[[L]],[[L]],[[-]],[[-]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[|]],[[|]],[[|]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[T]],[[-]],[[-]],[[T]],[[T]],[[T]],[[W]],[[W]],[[W]],[[-]],[[-]],[[.]],[[.]],[[v]],[[v]],[[v]],[[v]],[[v]],[[v]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[-]],[[-]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[.]],[[.]],[[.]],[[L]],[[L]],[[L]],[[.]],[[.]],[[.]],[[-]],[[-]],[[-]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[|]],[[!]],[[!]],[[^]],[[^]],[[!]],[[!]],[[!]],[[T]],[[T]],[[T]],[[-]],[[T]],[[T]],[[T]],[[T]],[[W]],[[W]],[[W]],[[W]],[[.]],[[.]],[[v]],[[v]],[[v]],[[v]],[[v]],[[!]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[-]],[[-]],[[-]],[[^]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[.]],[[.]],[[.]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[.]],[[.]],[[.]],[[-]],[[.]],[[&]],[[&]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[[T]],[[T]],[[T]],[[-]],[[T]],[[T]],[[T]],[[T]],[[-]],[[W]],[[W]],[[W]],[[.]],[[.]],[[v]],[[v]],[[v]],[[v]],[[v]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[-]],[[^]],[[^]],[[^]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[.]],[[-]],[[-]],[[.]],[[&]],[[&]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[-]],[[-]],[[-]],[[T]],[[T]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[v]],[[v]],[[v]],[[!]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[^]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[-]],[[-]],[[.]],[[.]],[[&]],[[&]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[~]],[[.]],[[.]],[[.]],[[T]],[[T]],[[-]],[[T]],[[-]],[[-]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[.]],[[.]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[&]],[[-]],[[-]],[[.]],[[.]],[[.]],[[&]],[[&]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[-]],[[-]],[[T]],[[T]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[.]],[[!]],[[!]],[[!]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[T]],[[T]],[[^]],[[^]],[[!]],[[.]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[&]],[[&]],[[-]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[-]],[[-]],[[T]],[[T]],[[T]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[!]],[[^]],[[!]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[!]],[[!]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[-]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[&]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[&]],[[&]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[~]],[[~]],[[.]],[[.]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[-]],[[-]],[[^]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[-]],[[T]],[[T]],[[T]],[[.]],[[.]],[[-]],[[-]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[!]],[[^]],[[!]],[[!]],[[.]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[T]],[[-]],[[.]],[[!]],[[^]],[[^]],[[!]],[[.]],[[.]],[[.]],[[~]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[T]],[[T]],[[T]],[[T]],[[T]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[.]],[[.]],[[.]],[[T]],[[_]],[[_]],[[_]],[[_]],[[T]],[[S]],[[S]],[[S]],[[!]],[[!]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[fields-of-hope]],[[-]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[T]],[[T]],[[T]],[[T]],[[.]],[[T]],[[T]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[.]],[[~]],[[.]],[[T]],[[_]],[[{]],[[{]],[[_]],[[_]],[[S]],[[S]],[[S]],[[S]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[.]],[[.]],[[-]],[[-]],[[-]],[[-]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[&]],[[&]],[[T]],[[T]],[[T]],[[.]],[[T]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[T]],[[_]],[[{]],[[{]],[[{]],[[_]],[[S]],[[S]],[[S]],[[S]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[&]],[[&]],[[-]],[[.]],[[scintillating-caverns]],[[T]],[[T]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[_]],[[_]],[[{]],[[{]],[[{]],[[S]],[[S]],[[.]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[-]],[[.]],[[.]],[[.]],[[.]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[P]],[[~]],[[~]],[[.]],[[.]],[[&]],[[&]],[[-]],[[-]],[[!]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[_]],[[_]],[[_]],[[{]],[[{]],[[.]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[-]],[[-]],[[-]],[[.]],[[.]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[P]],[[P]],[[P]],[[P]],[[.]],[[&]],[[&]],[[-]],[[!]],[[!]],[[!]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[T]],[[_]],[[{]],[[{]],[[{]],[[{]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[-]],[[.]],[[-]],[[.]],[[.]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[P]],[[P]],[[P]],[[P]],[[.]],[[&]],[[&]],[[-]],[[!]],[[!]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[j]],[[j]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[{]],[[{]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[-]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[P]],[[P]],[[P]],[[.]],[[.]],[[.]],[[-]],[[-]],[[-]],[[-]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[j]],[[j]],[[j]],[[j]],[[j]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[P]],[[P]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[-]],[[-]],[[-]],[[-]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[j]],[[j]],[[j]],[[k]],[[k]],[[k]],[[k]],[[|]],[[|]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[-]],[[.]],[[.]],[[.]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[j]],[[j]],[[j]],[[j]],[[^]],[[^]],[[k]],[[k]],[[|]],[[|]],[[|]],[[k]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[{]],[[{]],[[{]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[-]],[[-]],[[.]],[[!]],[[!]],[[!]],[[!]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[^]],[[k]],[[k]],[[^]],[[^]],[[^]],[[k]],[[k]],[[|]],[[|]],[[|]],[[|]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[{]],[[{]],[[{]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[k]],[[k]],[[k]],[[^]],[[^]],[[^]],[[k]],[[k]],[[k]],[[|]],[[|]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[{]],[[{]],[[{]],[[{]],[[~]],[[~]],[[~]],[[{]],[[{]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],},
	{[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[.]],[[.]],[[.]],[[.]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[k]],[[k]],[[k]],[[^]],[[k]],[[k]],[[k]],[[k]],[[k]],[[k]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[{]],[[{]],[[{]],[[{]],[[{]],[[{]],[[{]],[[{]],[[{]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],[[~]],}
}
