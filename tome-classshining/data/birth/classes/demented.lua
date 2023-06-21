local start_zone = function(self)
	if self.descriptor.world == "Maj'Eyal" and (
		self.descriptor.race == "Human" or
		self.descriptor.race == "Elf" or
		self.descriptor.race == "Dwarf" or
		self.descriptor.race == "Yeek" or
		self.descriptor.race == "Halfling" or 
		(self.descriptor.race == "Giant" and self.descriptor.subrace == "Ogre")
	) and not self._forbid_start_override then
		self.cults_race_start_quest = self.starting_quest
		-- Some overrides
		if self.descriptor.race == "Dwarf" then self.cults_race_start_quest = "start-allied" end
		if self.descriptor.race == "Yeek" then self.cults_race_start_quest = "start-allied" end
		--self.default_wilderness = {"zone-pop", "angolwen-portal"}  This erases Angolwen
		self.default_wilderness = {20, 17}
		self.starting_zone = "cults+town-kroshkkur"
		self.starting_quest = "cults+start-cults"
		self.starting_intro = "cults"
	end
	self:triggerHook{"BirthStartZone:cults"}
end


newBirthDescriptor{
	type = "subclass",
	name = "Shining One",
	locked = function() return profile.mod.allow_build.divine_anorithil end,
	locked_desc = _t"The balance of the heavens' powers is a daunting task. Blessed are those that venture east, into the house of the sun.",
	desc = {
		"Many in the east look to the sun for guidance and inspiration. You have looked more closely than most. You have seen the true nature of Shandral, and now you know that you must cleanse the world with holy fire.",
		"It will be #FIREBRICK#beautiful.#LAST#",
		"Their most important stats are Magic and Cunning.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life Rating:#LIGHT_BLUE# -5",
	},
	power_source = {arcance=true},
	stats = { con=2, mag=5, cun=3 },
	not_on_random_boss = true,
	talents_types = {
		-- base talents
		["celestial/sunlight"]={true, 0.3},
		["demented/sunlight"]={true, 0.3},
		["demented/prism"]={true, 0.3},
		["demented/inner-power"]={true, 0.3},
		
		--advanced talents
		["celestial/seals"]={false, 0.3},
		["demented/core-gate"]={false, 0.3},
		["celestial/incinerator"]={false, 0.3},
		
		--generics
		["cunning/survival"]={false, 0.0},
		["technique/combat-training"]={true, 0.0},
		["celestial/chants"]={true, 0.3},
		["celestial/shining-mantras"]={true, 0.3},
		["celestial/light"]={true, 0.3},
		--["demented/beyond-sanity"]={true, 0.0},
	},
	birth_example_particles = {
		"mantra_shield",
		-- function(actor)
		-- 	if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, infinite=1}))
		-- 	else actor:addParticles(Particles.new("wildfire", 1))
		-- 	end
		-- end,
	},
	talents = {
		[ActorTalents.T_REK_SHINE_SUNLIGHT_SOLAR_FLARE] = 1,
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_REK_SHINE_PRISM_REFLECTIONS] = 1,
		[ActorTalents.T_HEALING_LIGHT] = 1,
		[ActorTalents.T_REK_SHINE_MANTRA_INITIATE] = 1,

		[ActorTalents.T_REK_SHINE_PRISM_REMOVER] = 1,
	},
	
	copy = {
		class_start_check = start_zone,
		max_life = 70,
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
		life_rating = -5,
	},
}

-- Add to metaclass
getBirthDescriptor("class", "Demented").descriptor_choices.subclass["Shining One"] = "allow"
