load("/data/general/npcs/horror.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "QUEKORJA",
	type = "god", subtype = "eyal",
	name = "Quekorja, Goddess of Time",
	display = "@", color=colors.GRAY,
	faction = "enemies",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_ghost_freed_god.png", display_h=2, display_y=-1}}},
	desc = _t[[How sad it must have been, to be the deity of time in an era before timetravel.
Luckily that time is over.

In her six set of claws she holds the history of the world, and all possible futures are reflected in her single all-seeing eye.]],
	level_range = {100, nil}, exp_worth = 20,
	max_life = 1000, life_rating = 100, fixed_rating = true,
	rank = 10,
	size_category = 6,
	
	stats = { str=80, dex=80, con=100, cun=100, mag=100, wil=100 },
	inc_stats = { str=80, dex=80, con=80, mag=100, wil=80, cun=100 },
	combat_spellpower = resolvers.levelup(1, 1, 2.5),
	combat_mindpower = resolvers.levelup(1, 1, 2.5),

	no_auto_saves = true,
	no_auto_resists = true,

	resists = { all = 80, },
	resists_pen = {all = 50},

	
	combat_physresist = 160,
	combat_mentalresist = 130, -- for mind damage users, sigh.
	combat_spellresist = 160,
	combat_def = 120,

	combat_armor_hardiness = 100,
	combat_armor = 50,

	infravision = 10,
	see_invisible = 100,
	instakill_immune = 1,
	
	confusion_immune = 0.66,
	stun_immune = 0.66,
	silence_immune = 1.0,
	blind_immune = 1,

	body = { INVEN = 10 },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	
	resolvers.talents{
		[Talents.T_ANOMALY_TEMPORAL_BUBBLE]=1,
		[Talents.T_ANOMALY_TEMPORAL_SHIELD]=1,
		[Talents.T_ANOMALY_FLAWED_DESIGN]=1,
		[Talents.T_ANOMALY_EVIL_TWIN]=1,
		[Talents.T_ANOMALY_TEMPORAL_STORM]=1,

		[Talents.T_PRECOGNITION]=15,
		[Talents.T_FORESIGHT]=15,
		[Talents.T_SPACETIME_STABILITY]=15,
		[Talents.T_DIMENSIONAL_STEP]=5,

		[Talents.T_HIDDEN_RESOURCES]=5,
		[Talents.T_UNBREAKABLE_WILL]=5,
		
		[Talents.T_WEAPON_COMBAT]={base=5, every=10},
		[Talents.T_ARMOUR_TRAINING]={base=5, every=5},
		[Talents.T_WEAPONS_MASTERY]={base=5, every=5},
		
		[Talents.T_ENERGY_DECOMPOSITION]={base=5, every=6},

		[Talents.T_REPULSION_BLAST]={base=4, every=6},
		[Talents.T_GRAVITY_SPIKE]={base=4, every=6},
		[Talents.T_GRAVITY_LOCUS]={base=4, every=6},
		[Talents.T_GRAVITY_WELL]={base=4, every=6},

		[Talents.T_TEMPORAL_WAKE]={base=4, every=6},
		[Talents.T_CELERITY]={base=4, every=6, max=20},
		[Talents.T_TIME_DILATION]={base=4, every=6, max=20},
		[Talents.T_HASTE]={base=3, every=6, max=20},
		[Talents.T_TIME_SHIELD]={base=5, every=6},
		
		[Talents.T_ECHOES_FROM_THE_PAST]={base=5, every=6},
	},
	resolvers.sustains_at_birth(),
	can_pass = {pass_void=1},

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)

		for uid, e in pairs(game.level.entities) do
			if e.define_as == "TIME_PILLAR" then
				e:die()
			end
		end
		
		world:gainAchievement("HAMMER_GODSLAYER", who)
		game.level.data.no_worldport = nil
		game.zone.no_worldport = nil
		game.player.hammer_timecrash = nil
		game.player.hammer_timecrashed = true
	end,
}

local takeHitFloatingPillar = function(self, value, src)
	value = mod.class.Actor.onTakeHit(self, value, src)
	local Map = require "engine.Map"
	local original_terrain = game.level.map(self.x, self.y, Map.TERRAIN)
	if original_terrain.define_as == "TIMESHELL" then
		distance = math.ceil(value / 1000)
		if src then
			self:knockback(src.x, src.y, distance)
		end

		local oe = game.level.map(self.x, self.y, Map.TERRAIN)
		if oe.define_as == "TIMESHELL" then
			self.energy.value = self.energy.value - 10000
			game.bignews:saySimple(50, "#PINK#The %s crashes against the edge of the time bubble and grows still for now.", self:getName())
			game.log("#PINK#The %s crashes against the edge of the time bubble and grows still for now.", self:getName())
		end
	end
	
	return value
end

newEntity{
	define_as = "TIME_PILLAR",
	type = "immovable", subtype = "crystal",
	name = "Obelisk of Crystallized Time",
	display = "I", color=colors.GRAY,
	faction = "enemies",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_crystal_golden_crystal.png", display_h=2, display_y=-1}}},
	desc = _t[[A vast piece of raw time-stuff, turned into a weapon.  It is nigh-indestructible, but looks weightless, easy to push around.]],
	level_range = {100, nil}, exp_worth = 1,
	max_life = 1000000, life_rating = 10000, fixed_rating = true,
	life_regen = 10000,
	rank = 5,
	size_category = 4,
	
	stats = { str=10, dex=10, con=10, cun=100, mag=100, wil=100 },
	inc_stats = { mag=100, wil=80, cun=100 },
	combat_spellpower = resolvers.levelup(1, 1, 2.5),

	no_auto_saves = true,
	no_auto_resists = true,

	resists = { all = 0, },
	resists_pen = {all = 33},
	
	combat_physresist = 160,
	combat_mentalresist = 130,
	combat_spellresist = 160,
	combat_def = 0,

	combat_armor_hardiness = 100,
	combat_armor = 100,

	infravision = 10,
	see_invisible = 100,
	instakill_immune = 1,
	never_move = 1,
	
	confusion_immune = 0.5,
	stun_immune = 1.0,
	blind_immune = 1,

	body = { INVEN = 10 },
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },
	
	can_pass = {pass_void=1},

	resolvers.talents{
		[Talents.T_DUST_TO_DUST]=10,
		[Talents.T_MATTER_WEAVING]=5,
		[Talents.T_SPACETIME_STABILITY]=15,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	onTakeHit = takeHitFloatingPillar,
	on_act = function(self)
		local Map = require "engine.Map"
		local oe = game.level.map(self.x, self.y, Map.TERRAIN)
		if oe.define_as == "TIMESHELL" then
			game.bignews:saySimple(50, "#PINK#The %s rejoins your time thread.", self:getName())
			game.log("#PINK#The %s rejoins your time thread.", self:getName())
			self:teleportRandom(game.player.x, game.player.y, 8)
		end
	end,
}
