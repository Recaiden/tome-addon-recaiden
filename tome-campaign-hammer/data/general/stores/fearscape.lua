newEntity{
	define_as = "DEMON_ARMOR",
	name = "armory",
	display = '2', color=colors.UMBER,
	store = {
		nb_fill = 45,
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="armor", subtype="heavy", id=true, tome_drops="store"},
			{type="armor", subtype="massive", id=true, tome_drops="store"},
			{type="armor", subtype="shield", id=true, tome_drops="store"},
			{type="armor", subtype="head", id=true, tome_drops="store"},
			{type="armor", subtype="light", id=true, tome_drops="store"},
			{type="armor", subtype="hands", id=true, tome_drops="store"},
			{type="armor", subtype="feet", id=true, tome_drops="store"},
			{type="armor", subtype="belt", id=true, tome_drops="store"},
			{type="armor", subtype="cloth", id=true, tome_drops="store"},
			{type="armor", subtype="cloak", id=true, tome_drops="store"},
			{type="armor", subtype="belt", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "DEMON_WEAPON",
	name = "forge",
	display = '3', color=colors.UMBER,
	store = {
		nb_fill = 45,
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="greatsword", id=true, tome_drops="store"},
			{type="weapon", subtype="longsword", id=true, tome_drops="store"},
			{type="weapon", subtype="waraxe", id=true, tome_drops="store"},
			{type="weapon", subtype="battleaxe", id=true, tome_drops="store"},
			{type="weapon", subtype="greatmaul", id=true, tome_drops="store"},
			{type="weapon", subtype="mace", id=true, tome_drops="store"},
			{type="weapon", subtype="mindstar", id=true, tome_drops="store"},
			{type="weapon", subtype="staff", id=true, tome_drops="store"},
			{type="weapon", subtype="dagger", id=true, tome_drops="store"},
			{type="weapon", subtype="longbow", id=true, tome_drops="boss"},
			{type="weapon", subtype="sling", id=true, tome_drops="boss"},
			{type="ammo", id=true, tome_drops="boss"},
			{type="ammo", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "DEMON_POTION",
	name = "inscriptor",
	display = '4', color=colors.LIGHT_BLUE,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="scroll", subtype="infusion", id=true, ego_chance = 1000},
			{type="scroll", subtype="rune", id=true, ego_chance = 1000},
		},
	},
}

newEntity{
	define_as = "DEMON_TOOL",
	name = "quartermaster",
	display = '5', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="lite", id=true, tome_drops="store"},
			{type="tool", subtype="digger", id=true, tome_drops="store"},
			{type="charm", subtype="torque", id=true, tome_drops="boss"},
			{type="charm", subtype="totem", id=true, tome_drops="boss"},
			{type="charm", subtype="wand", id=true, tome_drops="boss"},
		},
	},
}

newEntity{
	define_as = "DEMON_JEWELRY",
	name = "gemcarver",
	display = '6', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="jewelry", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "DEMON_TREASURE",
	name = "salvaged treasures",
	display = '7', color=colors.BLUE,
	store = {
		nb_fill = 20,
		purse = 35,
		empty_before_restock = false,
		sell_percent = 190,
		filters = function()
			return {id=true, ignore={type="money"}, add_levels=12, force_tome_drops=true, tome_drops="boss", tome_mod={money=0, basic=0}, special=function(o) return o.type ~= "scroll" end}
		end,
	},
}
