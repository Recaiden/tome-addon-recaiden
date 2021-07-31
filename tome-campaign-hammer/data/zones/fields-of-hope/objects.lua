load("/data/general/objects/objects-maj-eyal.lua")
load("/data/general/objects/objects-far-east.lua")

newEntity{
	base = "BASE_HELM", define_as="CROWN_TOLAK",
	power_source = {technique=true},
	unique = true,
	name = "Twofold Crown",
	unided_name = _t"fine golden crown",
	desc = _t[[The crown of Nargol was lost long ago, so at the beginning of the Age of Ascendancy, a new crown was forged to represent the Allied Kingdoms.]],
	color = colors.BLUE, image = "object/artifact/twofold_crown.png",
	moddable_tile = "special/crown_of_command",
	level_range = {50, 50},
	rarity = nil,
	cost = 1000,
	material_level = 5,
	wielder = {
		stun_immune = 0.5,
		combat_def = 3,
		combat_armor = 6,

		combat_atk = 33,
		combat_dam = 33,
		combat_spellpower = 33,
		combat_mindpower = 33,
		generic_range_increase = 5,
		infravision = 5,
		sight = 5,
		resists = {
			[DamageType.ARCANE] = 25,
			[DamageType.PHYSICAL] = 25,
		},
		talents_mastery_bonus = {
			["race"] = 0.3,
		},
	},
	special_desc = function(self) return _t"Greatly extends the reach of your talents." end,
}
