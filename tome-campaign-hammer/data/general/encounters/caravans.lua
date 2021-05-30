class = require("mod.class.WorldNPC")

newEntity{
	name = "Human Trade Caravan",
	type = "patrol", subtype = "caravan",
	display = 'c', color = colors.GRAY,
	faction = "allied-kingdoms",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 999, --unusually competent caravan guards, should fend off any adventurers
	movement_speed = 0.5,
	cant_be_moved = false,
	ai = "world_patrol", ai_state = {route_kind="campaign-hammer+caravan", no_follow_beyond=1},
	on_encounter = function()
		game:changeLevel(1, "campaign-hammer+caravan-route")
	end,
}
