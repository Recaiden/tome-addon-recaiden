local default_eyal_descriptors = Birther.default_eyal_descriptors

local default_hammer_descriptors = function(add)
	local base = {
    race = getBirthDescriptor("world", "Arena").descriptor_choices.race,	
    class = getBirthDescriptor("world", "Arena").descriptor_choices.class,
	}

	-- TODO move Whitehoof into undead
-- 	local base = {

-- 	race =
-- 	{
-- 		__ALL__ = "disallow",
-- 	},

-- 	class =
-- 	{
-- 		__ALL__ = "disallow"
-- 	},
-- }

-- 	for name, what in pairs(default_eyal_descriptors{}.race) do base.race[name] = what end
-- 	for name, what in pairs(default_eyal_descriptors{}.class) do base.class[name] = what end

	if add then table.merge(base, add) end
	return base
end

-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Demons",
	display_name = _t"Demons: The Hammer of Urh'Rok",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.campaign == "Hammer",
	desc =
		{
			"Centuries ago, the Spellblaze plunged the world into an age of darkness.",
			"The people of Eyal were the lucky ones; Mal'rok was blasted apart, the broken peices of the world transformed to ever-burning hellscapes.",
			"Amidst the flames, the survivors remade themselves into demons, bent on revenge.",
			"They spent centuries traversing the void, preparing themselves for war.",
			"Now, Goedalath has arrived in high orbit.  A linked Orb of Many Ways allows passage through the planetary shield.  Khulmanar's armies are ready.  It is time.",
			"Unleash the fury of hell!",
		},
	descriptor_choices = default_hammer_descriptors{},
	copy = {
		calendar = "demon", calendar_start_year = 123, calendar_start_day = 70,
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "campaign-hammer+orbital-invasion-platform"
			self.starting_quest = "campaign-hammer+start-demon"
			self.starting_intro = "doombringer"
			self.faction = 'fearscape'
			self.default_wilderness = {"playerpop", "hammer-demon"}

			engine.Faction:setInitialReaction("fearscape", "enemies", -50, true)
			engine.Faction:setInitialReaction("orc-pride", "fearscape", -50, true)
		end,
	},
	game_state = {
		exp_multiplier = 5,
		campaign_name = "hammer",
		ignore_prodigies_special_reqs = true,
		__allow_rod_recall = true,
		__allow_transmo_chest = true,
		grab_online_event_zone = function() return "wilderness-1" end,
		grab_online_event_spot = function(zone, level)
			local find = {type="world-encounter", subtype="maj-eyal"}
			local where = game.level:pickSpotRemove(find)
			while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove(find) end
			local x, y = mod.class.Encounter:findSpot(where)
			return x, y
		end,
	},
	game_state_execute = function()
		-- Khulmanar is not killed by the Scourge in this timeline, but shouldn't randomly appear.
		game.uniques["mod.class.NPC/Khulmanar, General of Urh'Rok"] = 1
	end,
}
