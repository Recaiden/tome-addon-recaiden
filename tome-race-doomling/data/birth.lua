newBirthDescriptor {
  type = 'subrace',
  name = 'Doomling',
  locked = function() return profile.mod.allow_build.race_doomelf end,
  locked_desc = [[The demons of Mal'Rok would never bless you!
Three could tell them of the horrors you wrought.
One rages and torments in deep oceans blue,
one fights for the third with the cultists she taught.
Silence these beings, maintain your deception,
and then witness a new halfling's conception...]],
  desc = {
     "Doomlings are not a real race, they are Halflings that have been taken by demons and transformed into harbingers of doom",
     "They enjoy stalking lone foes and afflicting them with torments",
     "They possess the #GOLD#Curse of the Little Folk#WHITE# talent which allows them to reduce an enemy's saving throws and damage.",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * -3 Strength, +3 Dexterity, +1 Constitution',
     '#LIGHT_BLUE# * +2 Magic, +0 Willpower, +1 Cunning',
     '#GOLD#Life Rating:#LIGHT_BLUE# 12',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
  moddable_attachement_spots = "race_halfling",
  descriptor_choices =
     {
	sex =
	   {
	      __ALL__ = "disallow",
	      Male = "allow",
	   },
     },
  inc_stats = { str = -1, dex = 3, con = 1, mag = 2, wil = 0, cun = 1 },
  experience = 1.10,
  talents_types = {
     ["race/doomling"]={true, 0},
  },
  talents = {
     [ActorTalents.T_REK_DOOMLING_LUCK]=1,
  },
	cosmetic_options = {},
	default_cosmetics = { {"hairs", "Blond Hair 3"}, {"horns", "Demonic Horns 2"} },
  copy = {
     type = "halfling", subtype="doomling",
     _forbid_start_override = true,
     default_wilderness = {"zone-pop", "angolwen-portal"},
     starting_zone = "ashes-urhrok+searing-halls",
     starting_quest = "ashes-urhrok+start-ashes",
     ashes_urhrok_race_start_quest = "start-allied",
     faction = "allied-kingdoms",
     starting_intro = "ashes-urhrok",
     life_rating=12,
     moddable_tile = "halfling_#sex#",
     moddable_tile_base = "doomling_01.png",
    } 
}

getBirthDescriptor("race", "Halfling").descriptor_choices.subrace['Doomling'] = "allow"

local function alterRace(race, subrace, fct, no_defaults)
	skinsuffix = skinsuffix or ""
	local item
	if subrace then item = getBirthDescriptor("subrace", subrace)
	elseif race then item = getBirthDescriptor("race", race) end
	if not item then return end
	
	item.cosmetic_options = item.cosmetic_options or {}

	local i = 1

	local function add(kind, entry)
		entry.name = entry.name:gsub("#", i)
		entry.file = entry.file:gsub("#", i)
		item.cosmetic_options[kind] = item.cosmetic_options[kind] or {}
		table.insert(item.cosmetic_options[kind], entry)
	end

	while i <= 1 do
		fct(item, add, i)
		i = i + 1
	end
end

alterRace(
	nil, "Doomling",
	function(item, add, i)
		add("skin", {name="Demonic Skin 1", file="doomling_01", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
		add("skin", {name="Demonic Skin 2", file="doomling_02", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
		add("skin", {name="Demonic Skin 3", file="doomling_03", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
		add("skin", {name="Demonic Skin 4", file="doomling_04", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
		add("skin", {name="Demonic Skin 5", file="doomling_05", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
		add("skin", {name="Demonic Skin 6", file="doomling_06", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
		end, true)