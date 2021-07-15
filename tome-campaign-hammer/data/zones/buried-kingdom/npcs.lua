rarityWithLoot = function(add, mult)
	add = add or 0; mult = mult or 1;
	return function(e)
		e.bonus_loot = resolvers.drops{chance=85, nb=1, {}}
		e.bonus_arts = resolvers.drops{chance=2, nb=1, {tome_drops="boss"}}
		if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end
	end
end

load("/data/general/npcs/ghost.lua", rarityWithLoot(1))
load("/data/general/npcs/horror.lua", rarityWithLoot(2))
load("/data/general/npcs/horror_temporal.lua", rarityWithLoot(2))
load("/data/general/npcs/horror-undead.lua", rarityWithLoot(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_HORROR", define_as = "BURIED_FORGOTTEN",
	subtype = "temporal",
	allow_infinite_dungeon = true,
	unique = true,
	name = "The Forgotten King",
	display = "q", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_eldritch_dreaming_horror.png", display_h=2, display_y=-1}}},
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
			game.player:teleportRandom(self.x, self.y, 3, 7)
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
			self:doEmote(_t"Brother, can you not see that your changes are ruining the project!?", 100)
			self.emote_random = {chance=3, _t"Finally, the king is silent.", _t"All of this will be undone!", _t"At last, I live again!"}
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
		if not game.player:resolveSource():hasQuest("campaign-hammer+demon-ruins") then
			game.player:resolveSource():grantQuest("campaign-hammer+demon-ruins")
		end 
		game.player:resolveSource():setQuestStatus("campaign-hammer+demon-ruins", engine.Quest.COMPLETED)
		local Chat = require "engine.Chat"
		local chat = Chat.new("campaign-hammer+horror-power", {name=_t"Power Behind the Throne"}, game.player)
		chat:invoke()
	end,
}
