newBirthDescriptor{
	name = "Barbarian", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "twohander",
	power_source = {technique=true},
	stats = { str=5 },
	talents_types = {
		["technique/strength-of-the-berserker"]={true, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/bloodthirst"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_BERSERKER_RAGE] = 1,
		[ActorTalents.T_UNSTOPPABLE] = 1,
	},
	
	copy = {
			resolvers.auto_equip_filters{
				MAINHAND = {type="weapon", properties={"twohanded"}},
				OFFHAND = {type="none"}
		},
			resolvers.equipbirth{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = { life_rating = 2 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Barbarian"] = "disallow"

newBirthDescriptor{
	name = "Brute", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "twohander",
	power_source = {technique=true},
	stats = { str=5 },
	talents_types = {
		["technique/2hweapon-assault"]={true, 0.3},
		["technique/combat-techniques"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_STUNNING_BLOW_ASSAULT] = 1,
		[ActorTalents.T_DEATH_DANCE_ASSAULT] = 1,
	},
	
	copy = {
			resolvers.auto_equip_filters{
				MAINHAND = {type="weapon", properties={"twohanded"}},
				OFFHAND = {type="none"}
		},
			resolvers.equipbirth{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = { life_rating = 1 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Brute"] = "disallow"


local shield_special = function(e) -- allows any object with shield combat
	local combat = e.shield_normal_combat and e.combat or e.special_combat
	return combat and combat.block
end

newBirthDescriptor{
	name = "Swashbuckler", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "sword+shield",
	power_source = {technique=true},
	stats = { str=5 },
	talents_types = {
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/combat-techniques"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_RIPOSTE] = 1,
		[ActorTalents.T_ASSAULT] = 1,
	},
	
	copy = {
		resolvers.auto_equip_filters{
			MAINHAND = {type="weapon", special=function(e, filter) -- allow any weapon that doesn't forbid OFFHAND
										if e.slot_forbid == "OFFHAND" then
											local who = filter._equipping_entity
											return who and not who:slotForbidCheck(e, who.INVEN_MAINHAND)
										end
										return true
			end},
			OFFHAND = {special=shield_special},
			BODY = {type="armor", special=function(e, filter)
								if e.subtype=="heavy" or e.subtype=="massive" then return true end
								local who = filter._equipping_entity
								if who then
									local body = who:getInven(who.INVEN_BODY)
									return not (body and body[1])
								end
			end},
		},
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
													{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
													{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
	},
	copy_add = { life_rating = 3 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Swashbuckler"] = "disallow"

newBirthDescriptor{
	name = "Spellblade", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "twohander",
	power_source = {technique=true, arcane=true,},
	stats = { mag=5 },
	talents_types = {
		["spell/air"]={true, 0.3},
		["spell/enhancement"]={true, 0.3},
		["technique/magical-combat"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_ARCANE_COMBAT] = 1,
	},
	
	copy = {
			resolvers.auto_equip_filters{
				MAINHAND = {type="weapon", properties={"twohanded"}},
				OFFHAND = {
					special=function(e, filter)
						local who = filter._equipping_entity
						if who then
							local mh = who:getInven(who.INVEN_MAINHAND) mh = mh and mh[1]
							if mh and (not mh.slot_forbid or not who:slotForbidCheck(e, who.INVEN_MAINHAND)) then return true end
						end
						return false
					end},
		},
			resolvers.equipbirth{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Spellblade"] = "disallow"


newBirthDescriptor{
	name = "Guardian", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "sword+shield",
	power_source = {technique=true, arcane=true},
	stats = { str=3, mag=2 },
	talents_types = {
		["celestial/combat"]={true, 0.3},
		["celestial/guardian"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_OF_LIGHT] = 1,
		[ActorTalents.T_WAVE_OF_POWER] = 1,
		[ActorTalents.T_SHIELD_OF_LIGHT] = 1,
		[ActorTalents.T_CRUSADE] = 1,
	},
	
	copy = {
		resolvers.auto_equip_filters{
			MAINHAND = {type="weapon", special=function(e, filter) -- allow any weapon that doesn't forbid OFFHAND
										if e.slot_forbid == "OFFHAND" then
											local who = filter._equipping_entity
											return who and not who:slotForbidCheck(e, who.INVEN_MAINHAND)
										end
										return true
			end},
			OFFHAND = {special=shield_special},
			BODY = {type="armor", special=function(e, filter)
								if e.subtype=="heavy" or e.subtype=="massive" then return true end
								local who = filter._equipping_entity
								if who then
									local body = who:getInven(who.INVEN_BODY)
									return not (body and body[1])
								end
			end},
		},
		resolvers.equipbirth{ id=true,
													{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
													{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
													{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
	},
	copy_add = { life_rating = 3 },
}
getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Guardian"] = "disallow"


newBirthDescriptor{
	name = "Crusader", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
	enemy_ego_equip_set = "twohander",
	power_source = {technique=true, arcane=true},
	stats = { str=5 },
	talents_types = {
		["celestial/combat"]={true, 0.3},
		["celestial/crusader"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_OF_LIGHT] = 1,
		[ActorTalents.T_WAVE_OF_POWER] = 1,
		[ActorTalents.T_ABSORPTION_STRIKE] = 1,
		[ActorTalents.T_FLASH_OF_THE_BLADE] = 1,
	},
	
	copy = {
			resolvers.auto_equip_filters{
				MAINHAND = {type="weapon", properties={"twohanded"}},
				OFFHAND = {type="none"}
		},
			resolvers.equipbirth{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = { life_rating = 2 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Barbarian"] = "disallow"
