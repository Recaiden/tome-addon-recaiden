local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "subclass",
	name = "Khimeral",
	locked = function() return profile.mod.allow_build.adventurer and true or "hide"  end,
	locked_desc = _t"Save the world, create a monster.",
	desc = {
		_t"You've finally realized: you are not just you.  You are everything else, and something brand new.",
		_t"A khimeral can do a little bit of everything that other Hand users can do.",
		_t"It is a bonus class and by no means balanced.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +2 Strength, +2 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, +2 Cunning",
		_t"#GOLD#Life Rating:#LIGHT_BLUE# +0",
	},
	power_source = { arcane=true },
	stats = { str=2, con=2, mag=2, cun=2 },
	not_on_random_boss = true,
	talents_types = {
		-- titanic talents
		["spell/marching-sea"]={false, 0.3},
		["spell/oubliette"]={false, 0.3},
		["spell/mountainshaper"]={false, 0.3},

		-- base talents
		["spell/bloodtide"]={false, 0.3},
		["spell/intrusion"]={false, 0.3},
		["spell/oceansong"]={false, 0.3},
		["spell/chronorium"]={false, 0.3},
		["spell/polyp"]={false, 0.3},
		["spell/sybarite"]={false, 0.3},
		["spell/watcher"]={false, 0.3},
		["spell/veiled-shepherd"]={false, 0.3},
		["spell/headless-horror"]={false, 0.3},
		["spell/hale-hands"]={false, 0.3},
		["spell/shambler"]={false, 0.3},
		["technique/titanic-blows"]={false, 0.3},
		["technique/helping-hands"]={false, 0.3},
		["technique/harming-hands"]={false, 0.3},

		--advanced talents
		["spell/null-vizier"]={false, 0.3},
		["spell/eyebite"]={false, 0.3},
		["spell/eyesight"]={false, 0.3},
		["technique/splintered-lord"]={false, 0.3},
		["spell/moon-wurm"]={false, 0.3},

		--generics
		["technique/combat-training"]={true, 0.0},
		["cunning/survival"]={true, 0.0},
		["spell/otherness"]={true, 0.0},
		["spell/other-page"]={false, 0.3},
		["spell/divination"]={false, 0.3},
		["technique/conditioning"]={false, 0.3},
	},
	birth_example_particles = {
		function(actor)
			actor:addShaderAura("rek_heka_metafolded", "awesomeaura", {time_factor=16000, alpha=0.9}, "particles_images/metafolded.png")
		end,
	},
	talents = {
		-- [ActorTalents.T_REK_HEKA_MOUNTAIN_EARTHDRUM] = 1,
		-- [ActorTalents.T_REK_HEKA_MARCH_HEART] = 1,
		-- [ActorTalents.T_REK_HEKA_TENTACLE_WAVE] = 1,
		
		[ActorTalents.T_REK_HEKA_OTHERNESS_HIDDEN_PATHS] = 1,
		
		[ActorTalents.T_REK_HEKA_CHIMERA_UNLOCK] = 1,
	},
	
	copy = {
		class_start_check = start_zone,
		max_life = 100,
		heka_chimera_points = 6,
		unused_talents = 3,
		unused_generics = 1,
		mage_equip_filters,
		resolvers.inventorybirth{ id=true, transmo=true,
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="rough leather gloves", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="scroll", subtype="rune", name="manasurge rune", ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 0,
	},
}

-- Add to metaclass
if not getBirthDescriptor("class", "Demented") then
	for i, bdata in ipairs(Birther.birth_descriptor_def.world) do
		if bdata.descriptor_choices and bdata.descriptor_choices.class and bdata.descriptor_choices.class.Defiler == "allow" then
			bdata.descriptor_choices.class.Demented = "allow"
		end
	end
	
	newBirthDescriptor{
		type = "class",
		name = "Demented",
		desc = {
			_t"The thirst for knowledge is seen by most arcane users as as good thing.",
			_t"But some take it too far, some delve into lost knowledge. They may gain huge power from it, but at what cost?"
		},
		descriptor_choices =
			{
				subclass =
					{
						__ALL__ = "disallow",
					},
			},
		copy = {
			max_life = 110,
		},
	}
end

getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Khimeral"] = "allow"
