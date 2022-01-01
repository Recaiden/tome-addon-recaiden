local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "subclass",
	name = "Argosine",
	locked = function() return profile.mod.allow_build.mage end,
	locked_desc = _t"Adrift upon the sea of mist, he saw a thousand eyes.",
	desc = {
		_t"You've finally realized: you are not just you.  You are bigger than your body, and you can see forever.",
		_t"An argosine is summoner who directs disembodied wandering eyes and supports them with weird otherworldly magic.",
		_t"Their most important stat is Magic.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Dexterity, +5 Magic, +1 Willpower",
		_t"#GOLD#Life Rating:#LIGHT_BLUE# -2",
	},
	power_source = { arcane=true },
	stats = { dex=3, mag=5, wil=1 },
	not_on_random_boss = true,
	talents_types = {
		-- base talents
		["spell/sybarite"]={true, 0.3},
		["spell/watcher"]={true, 0.3},
		["spell/veiled-shepherd"]={true, 0.3},
		["spell/headless-horror"]={true, 0.3},
		["spell/hale-hands"]={true, 0.3},
		["spell/oubliette"]={false, 0.3},

		--advanced talents
		["spell/eyebite"]={false, 0.3},
		["spell/eyesight"]={false, 0.3},
		
		--generics
		["technique/combat-training"]={true, 0.0},
		["spell/divination"]={true, 0.3},
		["cunning/survival"]={true, 0.0},
		["spell/otherness"]={true, 0.0},
	},
	birth_example_particles = {
		function(actor)
			--actor:addShaderAura("rek_heka_metafolded", "awesomeaura", {time_factor=16000, alpha=0.9}, "particles_images/metafolded.png")
			actor:addParticles(Particles.new("circle", 1, {base_rot=1, oversize=0.5, a=150, appear=8, y=-0.68, speed=0, img="sudden_insight_eye", radius=0}))
		end,
	},
	talents = {
		[ActorTalents.T_REK_HEKA_HEADLESS_EYES] = 1,
		[ActorTalents.T_REK_HEKA_SYBARITE_ROYAL_ROAD] = 1,
		[ActorTalents.T_REK_HEKA_VEILED_LASHING] = 1,
		
		[ActorTalents.T_LIGHT_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_REK_HEKA_OTHERNESS_HIDDEN_PATHS] = 1,
	},
	
	copy = {
		class_start_check = start_zone,
		max_life = 100,
		mana_regen = 0.5,
		mana_rating = 5,
		mage_equip_filters,
		resolvers.equipbirth{
			id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = -2,
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

getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Argosine"] = "allow"
