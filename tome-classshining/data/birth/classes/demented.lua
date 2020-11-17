newBirthDescriptor{
	type = "subclass",
	name = "Shining One",
	locked = function() return profile.mod.allow_build.divine_anorithil end,
	locked_desc = _t"The balance of the heavens' powers is a daunting task. Blessed are those that venture east, into the house of the sun.",
	desc = {
		"Many in the east look to the sun for guidance and inspiration.  You have looked more closely than most.",
		"You have seen the true nature of Shandral, and now you know that you must cleanse the world with holy fire.",
		"It will be #FIREBRICK#beautiful.#LAST#",
		"Their most important stats are Magic and Cunning.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life Rating:#LIGHT_BLUE# -1",
	},
	power_source = {arcance=true},
	stats = { con=2, mag=5, cun=3 },
	not_on_random_boss = true,
	talents_types = {
		-- base talents
		["celestial/sunlight"]={true, 0.3},
		--["demented/prism"]={true, 0.3},
		--["demented/nuclear"]={true, 0.3},
		["demented/sunlight"]={true, 0.3},
		
		--advanced talents
		["celestial/circles"]={false, 0.3},
		--["demented/core-gate"]={false, 0.3},
		--["demented/incinerator"]={false, 0.3},
		
		--generics
		["cunning/survival"]={false, 0.0},
		["technique/combat-training"]={true, 1.0},
		["celestial/chants"]={true, 0.3},
		["celestial/light"]={true, 0.3},
	},
	birth_example_particles = "darkness_shield",
	talents = {
		[ActorTalents.T_REK_SHINE_SUNLIGHT_SOLAR_FLARE] = 1,
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_HEALING_LIGHT] = 1,
		-- [ActorTalents.T_REK_MTYR_UNSETTLING_UNNERVE] = 1,
		-- [ActorTalents.T_REK_MTYR_POLARITY_DEEPER_SHADOWS] = 1,
	},
	
	copy = {
		max_life = 90,
		resolvers.auto_equip_filters{
			MAINHAND = {type="weapon", subtype="staff"},
			OFFHAND = {special=function(e, filter)
					local who = filter._equipping_entity
					if who then
						local mh = who:getInven(who.INVEN_MAINHAND) mh = mh and mh[1]
						if mh and (not mh.slot_forbid or not who:slotForbidCheck(e, who.INVEN_MAINHAND)) then return true end
					end
					return false
												 end}
																},
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
													{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
												},
	},
	copy_add = {
		life_rating = -1,
	},
}

-- Add to metaclass
getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Shining One"] = "allow"
