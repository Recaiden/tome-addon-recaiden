
newBirthDescriptor{
	type = "subclass",
	name = "Hekatonkheire",
	locked = function() return profile.mod.allow_build.divine_anorithil end,
	locked_desc = _t"A thousand eyes open wide, a hundred hands embrace-",
	desc = {
		"You've finally realized: you are not just you.  You are bigger than your body, a vast entity with many hands and many eyes reaching into Eyal.",
		"A hekatonkhiere is a melee combatant who mixes weapons, martial arts, and weird otherworldly magic.",
		"Their most important stat is Strength, then Dexterity and Magic.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +5 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +3 Magic, -1 Willpower, +0 Cunning",
		"#GOLD#Life Rating:#LIGHT_BLUE# +2",
	},
	power_source = {arcance=true, technique=true},
	stats = { str=2, dex=5, mag=3, wil=-1 },
	not_on_random_boss = true,
	talents_types = {
		-- base talents
		["spell/shambler"]={true, 0.3},
		["spell/headless-horror"]={true, 0.3},
		["technique/titanic-blows"]={true, 0.3},
		["technique/helping-hands"]={true, 0.3},
		["technique/harming-hands"]={true, 0.3},
		
		
		--advanced talents
		["technique/splintered-lord"]={false, 0.3},
		--["spell/eyesight"]={false, 0.3},
		
		--generics
		["technique/combat-training"]={true, 0.0},
		["technique/conditioning"]={true, 0.3},
		["cunning/survival"]={true, 0.0},
		["spell/otherness"]={true, 0.0},
	},
	birth_example_particles = {
		"golden_shield",
		-- function(actor)
		-- 	if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, infinite=1}))
		-- 	else actor:addParticles(Particles.new("wildfire", 1))
		-- 	end
		-- end,
	},
	talents = {
		[ActorTalents.T_REK_HEKA_SHAMBLER_STEADY_GAIT] = 1,
		[ActorTalents.T_REK_HEKA_TITANIC_SCATTER] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	
	copy = {
		class_start_check = start_zone,
		max_life = 110,
		resolvers.auto_equip_filters{
			MAINHAND = {type="weapon", properties={"twohanded"}},
			OFFHAND = {special=function(e, filter) -- only allow if there is already a weapon in MAINHAND
					local who = filter._equipping_entity
					if who then
						local mh = who:getInven(who.INVEN_MAINHAND) mh = mh and mh[1]
						if mh and (not mh.slot_forbid or not who:slotForbidCheck(e, who.INVEN_MAINHAND)) then return true end
					end
					return false
												 end},
																},
		resolvers.equipbirth{
			id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
												},
	},
	copy_add = {
		life_rating = 2,
	},
}

-- Add to metaclass
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Hekatonkheire"] = "allow"
