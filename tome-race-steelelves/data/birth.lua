newBirthDescriptor {
  type = 'subrace',
  name = 'Macilore',
  desc = {
     "Steel elves are not a proper race, but are other elves of the Sunwall who follow a specific martial tradition to the detriment of their natural talents.",
     "They can dual-weild with great skill and move freely across the battlefield.",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * +3 Strength, +3 Dexterity, +0 Constitution',
     '#LIGHT_BLUE# * +0 Magic, +2 Willpower, +1 Cunning',
     '#GOLD#Life Rating:#LIGHT_BLUE# 11',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +10%'},
  moddable_attachement_spots = "race_elf",
  descriptor_choices =
		{
			sex =
				{
					__ALL__ = "disallow",
					Male = "allow",
				},
		},
  inc_stats = { str = 3, dex = 3, con = 0, mag = 0, wil = 2, cun = 1 },
  experience = 1.10,
  talents_types = {
     ["race/macilore"]={true, 0},
  },
  talents = {
     [ActorTalents.T_REK_STEEL_WIELDING]=1,
  },
	cosmetic_options = {},
	default_cosmetics = { {"hairs", "Blond Hair 3"} },
  copy = {
     type = "humanoid", subtype="elf",
		 default_wilderness = {"zone-pop", "ruined-gates-of-morning"},
		 starting_zone = "town-gates-of-morning",
		 starting_quest = "start-sunwall",
		 starting_intro = "sunwall",
		 faction = "sunwall",
     life_rating=11,
		 resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=100}, 1),
		 resolvers.inscription("INFUSION:_WILD", {cooldown=14, what={physical=true}, dur=4, power=14}, 2),
		 resolvers.inscription("INFUSION:_HEALING", {cooldown=12, heal=50}, 3),
     moddable_tile = "elf_#sex#",
     moddable_tile_base = "base_01.png",
		 resolvers.inventorybirth{ id=true,
															 {type="weapon", subtype="mace", name="iron mace", autoreq=true, ego_chance=-1000},
		 },
	}
}

getBirthDescriptor("race", "Elf").descriptor_choices.subrace['Macilore'] = "allow"

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

-- todo use to add new hairs
-- alterRace(
-- 	nil, "Maciloren",
-- 	function(item, add, i)
-- 		add("skin", {name="Demonic Skin 1", file="doomling_01", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
-- 		add("skin", {name="Demonic Skin 2", file="doomling_02", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
-- 		add("skin", {name="Demonic Skin 3", file="doomling_03", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
-- 		add("skin", {name="Demonic Skin 4", file="doomling_04", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
-- 		add("skin", {name="Demonic Skin 5", file="doomling_05", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
-- 		add("skin", {name="Demonic Skin 6", file="doomling_06", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"})
-- 	end, true)
