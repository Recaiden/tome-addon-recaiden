newBirthDescriptor{
	name = "Brute", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
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
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = { life_rating = 2 },
}
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass["Brute"] = "disallow"

newBirthDescriptor{
	name = "Spellblade", type = "subclass", desc = "",
	enemy_ego_point_cost = 2,
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
