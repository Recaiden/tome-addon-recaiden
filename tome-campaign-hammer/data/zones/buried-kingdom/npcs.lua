rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=45, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=1, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/ghost.lua", rarityWithLoot(1))
load("/data/general/npcs/horror.lua", rarityWithLoot(2))
load("/data/general/npcs/horror_temporal.lua", rarityWithLoot(2))
load("/data/general/npcs/horror-undead.lua", rarityWithLoot(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_HORROR", define_as = "BURIED_FORGOTTEN",
  type = "undead",
	subtype = "ghost",
	allow_infinite_dungeon = true,
	unique = true,
	name = "The Forgotten King",
	display = "q", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_ghost_forgotten_king.png", display_h=2, display_y=-1}}},
	desc = _t[[Once upon a time there was a storyteller, and he said-]],
	killer_message = _t"and was made to endlessly relive the kingdom's final moments.",
	level_range = {40, nil}, exp_worth = 2,
	max_life = 200, life_rating = 20, fixed_rating = true,
	stats = { str=5, dex=15, cun=20, mag=50, wil=70, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	immune_possession = 1,
	vim_regen = 8,
	disease_immune = 1,
	stun_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={wil=1.2} },

	inc_damage = {all=-10},
	resists = { [DamageType.TEMPORAL] = 50, [DamageType.DARKNESS] = 30 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=5, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=15, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SPACETIME_STABILITY]=15,

		[Talents.T_CALL_OF_THE_CRYPT]={base=4, every=5, max=7},
		[Talents.T_LORD_OF_SKULLS]={base=4, every=5, max=7},
		[Talents.T_ASSEMBLE]={base=4, every=5, max=7},

		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=6, max=8},
		[Talents.T_CURSE_OF_DEATH]={base=5, every=6, max=8},
		
		[Talents.T_ENERGY_ABSORPTION]={base=3, every=7},
		[Talents.T_ENERGY_DECOMPOSITION]={base=3, every=7},
		[Talents.T_ENTROPY]={base=3, every=7},
		[Talents.T_ECHOES_FROM_THE_VOID]={base=3, every=7},
		[Talents.T_VOID_SHARDS]={base=2, every=7, max=5},
		
		[Talents.T_TEMPORAL_BOLT]={base=3, every=10, max=6},
		[Talents.T_ECHOES_FROM_THE_PAST]={base=3, every=10, max=6},
	},

	self_resurrect = 2,

	emote_random = {chance=3, _t"Help me!", _t"He can't!", _t"You can't let him in!", _t"Put an end to this!"},

	on_acquire_target = function(self, who)
		if not self.rewind then
			self.rewind = game.turn
			self:doEmote(_t"Children, is that you?", 100)
		end
	end,
	
	on_resurrect = function(self)
		game.bignews:saySimple(120, "#GOLD#Time strains and snaps.  You are thrown back to the beginning of the fight!  But things aren't quite the same...")

		if not self.rewind then self.rewind = game.turn end
		if game.player then
			game.player:teleportRandom(self.x, self.y, 7, 3)
			game.player:resetToFull()
			local effs = {}
			for eff_id, p in pairs(game.player.tmp) do
				local e = game.player.tempeffect_def[eff_id]
				if e.status == "detrimental" then effs[#effs+1] = {"effect", eff_id} end
			end
			while #effs > 0 do
				local eff = rng.tableRemove(effs)
				game.player:removeEffect(eff[2])
			end
			game.player:resetToFull()
		end
		
		local tlevel = self:getTalentLevelRaw(self.T_ECHOES_FROM_THE_VOID)
		if self.died >= 2  then --second death
			self:learnTalent(self.T_DISINTEGRATION, true, tlevel)
			self:learnTalent(self.T_DUST_TO_DUST, true, tlevel)
			self:learnTalent(self.T_HASTE, true, tlevel)
			self:learnTalent(self.T_CHRONO_TIME_SHIELD, true, tlevel)
			self:learnTalent(self.T_DRACONIC_WILL, true, 1)
			self:forceUseTalent(self.T_DISINTEGRATION, {ignore_energy=true})
			self:unlearnTalentFull(self.T_FEED, true, tlevel)
			self:unlearnTalentFull(self.T_DEVOUR_LIFE, true, tlevel)
			self:unlearnTalentFull(self.T_FEED_POWER, true, tlevel)
			self:unlearnTalentFull(self.T_FEED_STRENGTHS, true, tlevel)
			self.inc_damage.all = self.inc_damage.all + 24
			self.rank = 10
			self.female = true

			self.replace_display = mod.class.Actor.new{image="npc/undead_ghost_freed_god.png", display_h=2, display_y=-1}
      self:removeAllMOs()
			--resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_ghost_forgotten_king.png", display_h=2, display_y=-1}}},

      game.level.map:updateMap(self.x, self.y)
			
			self:doEmote(_t"Brother, can you not see that your changes are ruining the project!?", 100)
			self.emote_random = {chance=3, _t"Finally, the king is silent.", _t"All of this will be undone!", _t"At last, I live again!"}
			if game and game.player then
				game.player.hammer_timemark = true
			end
			local Chat = require "engine.Chat"
			local chat = Chat.new("campaign-hammer+horror-power", {name=_t"Power Behind the Throne"}, game.player)
			chat:invoke()
		end
		if self.died == 1 then --first death
			self:learnTalent(self.T_FEED, true, tlevel)
			self:learnTalent(self.T_DEVOUR_LIFE, true, tlevel)
			self:learnTalent(self.T_FEED_POWER, true, tlevel)
			self:learnTalent(self.T_FEED_STRENGTHS, true, tlevel)
			self:unlearnTalentFull(self.T_CURSE_OF_VULNERABILITY)
			self:unlearnTalentFull(self.T_CURSE_OF_DEATH)
			self.inc_damage.all = self.inc_damage.all + 30
			self.rank = 5
			self:doEmote(_t"But where is your sister? She-", 100)
			self.emote_random = {chance=3, _t"They were here even then.", _t"I made them well.", _t"Please, stranger-"}
		end
		self.vim = self.max_vim
		self.souls = self.max_souls
		self.paradox = 300
		game.turn = self.rewind	
	end,
	
	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	auto_classes={{class="Paradox Mage", start_level=18, level_rate=50}},

	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		self:doEmote(_t"This is not the end!", 500)
		if game and game.player then
			game.player.hammer_timemark = nil
		end
		if not game.player:resolveSource():hasQuest("campaign-hammer+demon-ruins") then
			game.player:resolveSource():grantQuest("campaign-hammer+demon-ruins")
		end 
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-ruins", engine.Quest.COMPLETED)
	end,
}

-- uniques
newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	subtype = "temporal",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_temporal_temporal_stalker.png", display_h=2, display_y=-1}}},
	name = "Shredder of Days", color=colors.STEEL_BLUE, unique=true,
	desc = _t"A slender metallic monstrosity with long claws in place of its fourteen fingers, and many needle-sharp teeth.",
	level_range = {45, nil}, exp_worth = 2,
	rarity = 25,
	rank = 3.5,
	size_category = 3,
	max_life = resolvers.rngavg(100,180),
	life_rating = 18,
	global_speed_base = 1.6,
	autolevel = "rogue",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	combat_armor = 10, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,100), 1, 1.2), atk=resolvers.rngavg(25,100), apr=25, dammod={dex=1.1} },
	combat_critical_power = 30,
	resists = {all = 20, [DamageType.TEMPORAL] = 50},

	resolvers.talents{
		[Talents.T_FATEWEAVER]={base=5, every=7, max=8},
		[Talents.T_SPIN_FATE]={base=5, every=7, max=8},
		[Talents.T_WEAPON_FOLDING]={base=5, every=7, max=8},
		[Talents.T_WEAPON_MANIFOLD]={base=5, every=7, max=8},

		[Talents.T_UNARMED_MASTERY]={base=5, every=7},
		[Talents.T_STEALTH]={base=3, every=7, max=5},
		[Talents.T_SHADOWSTRIKE]={base=3, every=7, max=5},
		[Talents.T_LETHALITY]={base=1, every=6, max=5},
		[Talents.T_WEAPON_COMBAT]={base=0, every=6, max=6},
		[Talents.T_SHADOWSTEP]={base=2, every=6, max=6},
		
		[Talents.T_SHADOW_VEIL]={last=20, base=0, every=6, max=6},
	},

	resolvers.inscriptions(1, {"stormshield rune"}),
	resolvers.inscriptions(1, "infusion"),

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	subtype = "temporal",
	name = "Record of Reunion", color=colors.GREY, unique=true,
	desc = _t"It looks like a hole into the night sky, through which you see things moving, but you get the impression it's somehow more than that.",
	level_range = {45, nil}, exp_worth = 2,
	rarity = 25,
	rank = 3.5,
	size_category = 2,
	max_life = resolvers.rngavg(80, 120),
	life_rating = 15,
	autolevel = "summoner",
	ai = "dumb_talented_simple",
	ai_state = { ai_target="target_player_radius", ai_move="move_snake", sense_radius=6, talent_in=1, },
	combat_armor = 1, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={wil=0.8}, damtype=DamageType.VOID },
	on_melee_hit = { [DamageType.VOID] = resolvers.mbonus(20, 10), },

	stun_immune = 1,
	confusion_immune = 1,
	silence_immune = 1,
	negative_status_effect_immune = 1,

	resists = {all = 35, [DamageType.TEMPORAL] = 50, [DamageType.DARKNESS] = 50},

	combat_spellpower = resolvers.levelup(30, 1, 2),
	combat_mindpower = resolvers.levelup(30, 1, 2),

	resolvers.talents{
		[Talents.T_ENERGY_ABSORPTION]={base=3, every=7, max=5},
		[Talents.T_ENERGY_DECOMPOSITION]={base=3, every=7, max=5},
		[Talents.T_ENTROPY]={base=3, every=7, max=5},
		[Talents.T_ECHOES_FROM_THE_VOID]={base=3, every=7, max=5},
		[Talents.T_VOID_SHARDS]={base=2, every=7, max=5},

		[Talents.T_NIGHTMARE]={base=5, every=8, max=10},
		[Talents.T_WAKING_NIGHTMARE]={base=3, every=8, max=10},
		[Talents.T_INNER_DEMONS]={base=3, every=8, max=10},

		[Talents.T_ABYSSAL_SHROUD]={base=3, every=8, max=8},
	},

	can_pass = {pass_wall=20},

	resolvers.inscriptions(1, {"shielding rune"}),
	
	-- Random Anomaly on Death
	on_die = function(self, who)
		local ts = {}
		for id, t in pairs(self.talents_def) do
			if t.type[1] == "chronomancy/anomalies" then ts[#ts+1] = id end
		end
		self:forceUseTalent(rng.table(ts), {ignore_energy=true})
		game.logSeen(self, "%s has collapsed in upon itself.", self:getName():capitalize())
	end,

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "Thy Brother's Keeper", color=colors.GOLD, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_eldritch_brothers_keeper.png", display_h=2, display_y=-1}}},
	desc =_t"A lanky tentacled shape composed of bright golden light.  It's so bright it's hard to look at, and you can feel heat alternately radiating outward from it and pouring in towards it.",
	level_range = {45, nil}, exp_worth = 2,
	rarity = 25,
	rank = 3.5,
	autolevel = "caster",
	max_life = resolvers.rngavg(220,250),
	life_rating = 19,
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=30, apr=40, dammod={mag=1}, damtype=DamageType.LIGHT},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	lite = 5,

	resists = {all = 40, [DamageType.DARKNESS] = 100, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100, [DamageType.COLD] = 100},
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, [DamageType.DARKNESS] = 50,  [DamageType.COLD] = 50,},

	all_damage_convert = DamageType.DARKNESS,
	all_damage_convert_percent = 100,

	blind_immune = 1,
	see_invisible = 20,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]={base=10, every=15},
		[Talents.T_CIRCLE_OF_BLAZING_LIGHT]={base=10, every=15},
		[Talents.T_SEARING_LIGHT]={base=10, every=15},
		[Talents.T_FIREBEAM]={base=10, every=15},
		[Talents.T_SUNBURST]={base=10, every=15},
		[Talents.T_SUN_FLARE]={base=10, every=15},
		[Talents.T_PROVIDENCE]={base=10, every=15},
		[Talents.T_HEALING_LIGHT]={base=10, every=15},
		[Talents.T_BARRIER]={base=10, every=15},

		[Talents.T_INVOKE_DARKNESS]={base=10, every=15},
		[Talents.T_SHADOW_BLAST]={base=10, every=15},
		[Talents.T_STARFALL]={base=10, every=15},
	},

	resolvers.sustains_at_birth(),
	power_source = {arcane=true},

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=2, no_subescort=true},
	},
}
