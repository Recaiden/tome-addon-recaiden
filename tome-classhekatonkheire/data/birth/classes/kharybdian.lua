local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "subclass",
	name = "Kharybdian",
	locked = function() return profile.mod.allow_build.mage end,
	locked_desc = _t"Between a rock, and a hard place.",
	desc = {
		_t"You've finally realized: you are not just you.  You are all who came before you, countless aeons within the sea.",
		_t"A kharybdian is a mage attuned to the primordial ocean.",
		_t"Their most important stat is Magic.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Constitution, +5 Magic, +1 Cunning",
		_t"#GOLD#Life Rating:#LIGHT_BLUE# +0",
	},
	power_source = { arcane=true },
	stats = { con=3, mag=5, cun=1 },
	not_on_random_boss = true,
	talents_types = {
		-- base talents
		["spell/bloodtide"]={true, 0.3},
		["spell/intrusion"]={true, 0.3},
		["spell/oceansong"]={true, 0.3},
		["spell/chronorium"]={true, 0.3},
		["spell/polyp"]={true, 0.3},
		["spell/moon-wurm"]={false, 0.3},

		--advanced talents
		["spell/null-vizier"]={false, 0.3},
		["spell/marching-sea"]={false, 0.3},
		
		--generics
		["technique/combat-training"]={true, 0.0},
		["cunning/survival"]={true, 0.3},
		["spell/other-page"]={true, 0.3},
		["spell/otherness"]={true, 0.0},
	},
	birth_example_particles = {
		function(actor)
			actor:addShaderAura("rek_heka_metafolded", "awesomeaura", {time_factor=16000, alpha=0.9}, "particles_images/metafolded.png")
		end,
	},
	talents = {
		[ActorTalents.T_REK_HEKA_INTRUSION_EYE] = 1,
		[ActorTalents.T_REK_HEKA_BLOODTIDE_SHIELD] = 1,
		[ActorTalents.T_REK_HEKA_POLYP_POLYP] = 1,
		
		[ActorTalents.T_REK_HEKA_OTHERNESS_HIDDEN_PATHS] = 1,
	},
	
	copy = {
		class_start_check = start_zone,
		max_life = 100,
		mage_equip_filters,
		resolvers.equipbirth{
			id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
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

getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Kharybdian"] = "allow"
