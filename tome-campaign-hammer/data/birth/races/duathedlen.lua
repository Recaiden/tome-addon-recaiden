newBirthDescriptor{
	type = "race",
	name = "Duathedlen",
	desc = {
		"Orcs have a long and sad history. They are seen, and are, as an aggressive race that more than one time managed to imperil all of Maj'Eyal.",
		"But one year ago the Scourge from the West came and wiped four of the five Prides. And a hundred years ago King Toknor wiped all traces of orcs from Maj'Eyal.",
		"The orc race is dangerously on the brink of destruction. One wrong move is all that is needed.",
		"But they are strong and will face whatever is needed to ensure a future of their own!",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Orc = "allow",
		},
	},
	copy = {
		auto_id = 100,
		faction = "demon",
		type = "demon", subtype="major",
		default_wilderness = {"playerpop", "orc"},
		starting_zone = "orcs+town-kruk",
		starting_quest = "orcs+kruk-invasion",
		starting_intro = "orc",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
	},
--	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	moddable_attachement_spots = "race_orc", moddable_attachement_spots_sexless=true,

	cosmetic_unlock = {
		cosmetic_race_orc = {
			{priority=2, name="Goggles", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_ornament={female="goggles_01", male="goggles_01"} end end},
			{priority=2, name="Monocle Left", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_ornament={female="monocle_left_01", male="monocle_left_01"} end end},
			{priority=2, name="Monocle Right", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_ornament={female="monocle_right_01", male="monocle_right_01"} end end},
		},
		cosmetic_bikini =  {
			{name="Bikini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Bikini if not o then print("No bikini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_BIKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
			{name="Mankini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Mankini if not o then print("No mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_MANKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Male" end},
		},
	},
}

---------------------------------------------------------
--                        Orcs                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Orc",
	desc = {
		"Orcs have a long and sad history. They are seen, and are, as an aggressive race that more than one time managed to imperil all of Maj'Eyal.",
		"But one year ago the Scourge from the West came and wiped four of the five Prides. And a hundred years ago King Toknor wiped all traces of orcs from Maj'Eyal.",
		"The orc race is dangerously on the brink of destruction. One wrong move is all that is needed.",
		"But they are strong and will face whatever is needed to ensure a future of their own!",
		"They possess the #GOLD#Orcish Fury#WHITE# which allows them to increase all their damage for a few turns.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +1 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * -1 Magic, +1 Willpower, +1 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 12",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 25%",
	},
	inc_stats = { str=2, con=1, dex=1, wil=1, cun=1, mag=-1 },
	talents_types = { ["race/orc"]={true, 0} },
	talents = {
		[ActorTalents.T_ORC_FURY]=1,
	},
	copy = {
		moddable_tile = "orc_#sex#",
		life_rating=12,
	},
	experience = 1.25,
}
