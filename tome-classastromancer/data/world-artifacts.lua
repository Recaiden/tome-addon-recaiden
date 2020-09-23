local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local Map = require "engine.Map"
local DamageType = require "engine.DamageType"
local Object = require "engine.Object"

--------------------------------------------------------------------------------
-- Staves
--------------------------------------------------------------------------------
newEntity{
	base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Meteor Staff",
	flavor_name = "magestaff",
	flavors = {magestaff=true},
	unided_name = "stone-tipped staff", image = "object/artifact/wander_staff_of_meteors.png",
	level_range = {20, 35},
	color=colors.VIOLET,
	rarity = 170,
	desc = [[Small meteoric stones swirl around the tip of this ashen-wood staff]],
	cost = 200,
	material_level = 4,
	
	require = { stat = { mag=24 }, },
	combat = {
		dam = 20,
		apr = 4,
		dammod = {mag=1.3},
		element = DamageType.PHYSICAL,
		convert_damage = { [DamageType.FIRE] = 50,},
	},
	wielder = {
		combat_spellpower = 35,
		inc_damage={
			[DamageType.FIRE] = 25,
			[DamageType.PHYSICAL] = 25,
		},
		talents_types_mastery = {
			["celestial/meteor"] = 0.2,
		},
		talent_cd_reduction={[Talents.T_WANDER_METEOR_STARSTRIKE]=2},
		learn_talent = {
			[Talents.T_WANDER_METEOR_STORM_BONUS] = 1,
			[Talents.T_WANDER_METEOR_STORM] = 1},
	}
}

--------------------------------------------------------------------------------
-- Boots
--------------------------------------------------------------------------------
newEntity{
   base = "BASE_LEATHER_BOOT",
   power_source = {arcane=true},
   unique = true,
   name = "Gliding Boots", image = "object/artifact/wander_boots_skates.png",
   unided_name = "pair of bladed boots",
   desc = [[Sheets of ice form beneath these bladed white boots, letting the wearer skate speedily across any terrain]],
   color = colors.YELLOW,
   level_range = {1, 20},
   rarity = 300,
   cost = 100,
   material_level = 3,
   wielder = {
      combat_armor = 2,
      combat_def = 4,
      fatigue = 1,
      talents_types_mastery = { ["celestial/luxam"] = 0.2 },
      inc_stats = { [Stats.STAT_DEX] = 4, },
      learn_talent = {[Talents.T_WANDER_ICE_SPEED] = 1},
   },
}

--------------------------------------------------------------------------------
-- Shield
--------------------------------------------------------------------------------
newEntity{
   base = "BASE_SHIELD",
   power_source = {arcane=true},
   unided_name = "worn voratun plate",
   name = "Windswept Shield", unique=true, image = "object/artifact/wander_shield_windworn.png",
   desc = [[A pentagonal voratun shield, the crest it once bore long since worn away]],
   require = { stat = { wil=24 }, },
   level_range = {30, 50},
   rarity = 200,
   cost = 500,
   material_level = 5,
   moddable_tile_big = true,
   metallic = true,
   special_combat = {
      dam = 18,
      block = 260,
      physcrit = 5,
      dammod = {str=0.9, mag=0.5},
      damrange = 1.4,
      melee_project = { [DamageType.COLD] = 10, },
   },
   wielder = {
      combat_armor = 10,
      combat_def = 20,
      fatigue = 10,
      resists = {[DamageType.LIGHTNING] = 35},
      learn_talent = { [Talents.T_BLOCK] = 5, },
      talents_types_mastery = {
	 ["celestial/ponx"] = 0.2,
      },
   },
   max_power = 10, power_regen = 1,
   use_talent = { id = Talents.T_WANDER_WIND_DODGE, level = 1, power = 10 },
   on_block = {desc = "30% chance to electrocute the target.", fct = function(self, who, target, type, dam, eff)
		  if rng.percent(30) then
		     if not target or target:attr("dead") or not target.x or not target.y then return end
		     who:forceUseTalent(who.T_WANDER_LIGHTNING_GWEL, {ignore_energy=true, no_talent_fail=true, ignore_cd=true, force_target=target, force_level=2, ignore_ressources=true})
		  end
   end,},
}

--------------------------------------------------------------------------------
-- Weapons
--------------------------------------------------------------------------------
newEntity{
	base = "BASE_GREATMAUL", define_as="WANDER_VOLCANO_HAMMER",
	power_source = {unknown=true, arcane=true},
	unique = true,
	name = "Molten Hammer", color = colors.LIGHT_RED, image = "object/artifact/wander_molten_hammer.png",
	unided_name = "unfinished hammer",
	desc = [[The end of the hammer is still glowing.  It's said the volcanoes of the Daikara first erupted when this hammer was thrown down into the mountain range by the gods. It doesn't fit right in your hands, but it's very easy to lift.]],
	level_range = {31, 45},
	rarity = 250,
	require = { stat = { str=10, mag=30 }, },
	cost = 650,
	material_level = 4,
	combat = {
		dam = 75,
		apr = 4,
		physcrit = 10,
		dammod = {str=1.2, con=0.1, mag=0.1},
		special_on_hit = {desc="splashes up to 5 nearby enemies with lava",
											fct=function(combat, who, target)
												local o, item, inven_id = who:findInAllInventoriesBy("define_as", "WANDER_VOLCANO_HAMMER")
												
												local tgts = {}
												local grids = core.fov.circle_grids(target.x, target.y, 5, true)
												for x, yy in pairs(grids) do
													for y, _ in pairs(grids[x]) do
														local a = game.level.map(x, y, engine.Map.ACTOR)
														if a and who:reactionToward(a) < 0 then
															tgts[#tgts+1] = a
														end
													end
												end
												local tg = {type="bolt", range=5, x=target.x, y=target.y, display={image="object/lava_boulder.png"}}
												for i = 1, 5 do
													if #tgts <= 0 then break end
													local a, id = rng.table(tgts)
													who:projectile(tg, a.x, a.y, engine.DamageType.MOLTENROCK, who:getMag()*0.5, {type="flame"})
													table.remove(tgts, id) 
												end
											end
		},
		talent_on_crit = { [Talents.T_WANDER_FIRE_VOLCANO] = {level=4, chance=10} },
		melee_project={[DamageType.FIRE] = 20, [DamageType.PHYSICAL] = 20},
	},
	
	wielder = {
		combat_spellpower = 35,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.FIRE] = 30,
			[DamageType.PHYSICAL] = 30,
		},
		talents_types_mastery = {
			["celestial/kolal"] = 0.2,
		},
	},
}


--------------------------------------------------------------------------------
-- Planet gems
--------------------------------------------------------------------------------

-- newEntity{
--    base = "BASE_GEM", 
--    power_source = {arcane=true},
--    unique = true,
--    unided_name = "glowing green gem",
--    define_as = "WANDER_KOLAL_GEM",
--    name = "Molten Peridot", subtype = "green",
--    color = colors.GREEN, image = "object/artifact/corrupted_crystal.png",
--    level_range = {20, 30},
--    desc = [[An indistinct green gem, still glowing with otherworldly heat.]],
--    rarity = 300,
--    cost = 200,
--    identified = false,
--    material_level = 3,
--    color_attributes = {
--       damage_type = 'FIRE',
--       alt_damage_type = 'FLAMESHOCK',
--       --particle = 'crystalist_fire_ball',
--    },
--    wielder = {
--       resists = {[DamageType.FIRE] = 10},
--       inc_damage = {[DamageType.FIRE] = 10},
--       resists_pen = {[DamageType.FIRE] = 10},
--       talents_types_mastery = { ["celestial/kolal"] = 0.1 },
--    },
--    imbue_powers = {
--       resists = {[DamageType.FIRE] = 10},
--       inc_damage = {[DamageType.FIRE] = 10},
--       resists_pen = {[DamageType.FIRE] = 10},
--       talents_types_mastery = { ["celestial/kolal"] = 0.1 },
--    },
-- }

-- newEntity{
--    base = "BASE_GEM", 
--    power_source = {arcane=true},
--    unique = true,
--    unided_name = "hardened sand",
--    define_as = "WANDER_PONX_GEM",
--    name = "Fulgurite", subtype = "blue",
--    color = colors.BLUE, image = "object/artifact/elemental_prism.png",
--    level_range = {20, 30},
--    desc = [[This patch of sand still remembers the lightning that fused it together]],
--    rarity = 300,
--    cost = 300,
--    identified = false,
--    material_level = 3,
--    color_attributes = {
--       damage_type = 'GOOD_LIGHTNING',
--       alt_damage_type = 'LIGHTNING_DAZE',
--       particle = 'lightning_explosion',
--    },
--    wielder = {
--       talents_types_mastery = { ["celestial/ponx"] = 0.1 },
--       resists = {[DamageType.COLD]=10,[DamageType.FIRE]=10,[DamageType.LIGHTNING]=10,[DamageType.ARCANE]=10},
--       combat_spellpower = 10,
--       combat_spellcrit = 5,
--    },
--    imbue_powers = {
--       talents_types_mastery = { ["celestial/ponx"] = 0.1 },
--       resists = {[DamageType.COLD]=10,[DamageType.FIRE]=10,[DamageType.LIGHTNING]=10,[DamageType.ARCANE]=10},
--       combat_spellpower = 10,
--       combat_spellcrit = 5,
--       talent_on_spell = { {chance=10, talent=Talents.T_ELEMENTAL_BOLT, level=3} },
--       talent_on_mind = { {chance=10, talent=Talents.T_ELEMENTAL_BOLT, level=3} },
--    },
-- }
