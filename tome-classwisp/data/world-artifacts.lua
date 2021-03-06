local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local Map = require "engine.Map"
local DamageType = require "engine.DamageType"
local Object = require "engine.Object"

--------------------------------------------------------------------------------
-- Bows
--------------------------------------------------------------------------------
newEntity{
	base = "BASE_LONGBOW",
	power_source = {unknown=true},
	unique = true,
	name = "The Crimson Storm",
	unided_name = "red swirl", image = "object/artifact/glr_crimson_storm.png",
	moddable_tile = "%s_bow_glr_storm",
	moddable_tile_big = true,
	level_range = {35, 50},
	color=colors.CRIMSON,
	rarity = 170,
	desc = [[A tiny hurricane of bloody raindrops and basalt hail, whirling eternally in the air.  It seems ... friendly.]],
	cost = 200,
	material_level = 5,
	sentient = true,
	require = { stat = { dex=50 }, },
	encumber = 0,
	combat = {
		range = 3,
		travel_speed = 4,
		physspeed = 0.95,
		attack_recurse = 2,
		dam_mult=0.35,
		ranged_project = {[DamageType.PHYSICAL] = 5},
		combat_physcrit=20,
		apr = 11,
	},
	wielder = {
		combat_def = 50,
		movement_speed = 0.35,
		talents_types_mastery = {
			["technique/arrowstorm"] = 0.2,
		},
		talent_cd_reduction={[Talents.T_REK_GLR_ARROWSTORM_VITARIS]=4},
	},
}

newEntity{
	base = "BASE_LONGBOW",
	power_source = {unknown=true},
	unique = true,
	name = "Voyager",
	unided_name = "pointy machine", image = "object/artifact/glr_ritiel.png",
	moddable_tile = "%s_bow_glr_ritiel",
	moddable_tile_big = true,
	level_range = {20, 35},
	rarity = 170,
	desc = [[This complex assembly of branches, pulleys and strings seems to serve as a longbow.]],
	cost = 200,
	material_level = 3,
	sentient = true,
	require = { stat = { dex=24 }, },
	encumber = 6,
	combat = {
		range = 10,
		ranged_project = { 
			[DamageType.NATURE] = 15,
		},
		burst_on_crit = {
			[DamageType.NATURE] = 10,
		}
	},
	wielder = {
		combat_atk = 10,
		talents_types_mastery = {
			["race/higher"] = 0.2,
		},
		lite = 3,
		blind_immune = 0.4,
		learn_talent = {
			[Talents.T_OVERSEER_OF_NATIONS] = 5,
			[Talents.T_REK_GLR_SHOT_VOYAGE] = 2,
		},
	},
	
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.zone.wilderness then return end
		if game.level and not game.level:hasEntity(self.worn_by) then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		if not self.worn_by.in_combat then return end
		local who = self.worn_by
		local Map = require "engine.Map"
		local tgts = {}
		local DamageType = require "engine.DamageType"
		local grids = core.fov.circle_grids(who.x, who.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and who:reactionToward(a) < 0 and not game.level.map:hasEffectType(x, y, DamageType.GRASPING_MOSS) then
				tgts[#tgts+1] = a
			end
		end end

		local tg = {type="hit", range=5, friendlyfire=false}

		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)

		game.level.map:addEffect(self.worn_by,
			a.x, a.y, 8,
			DamageType.GRASPING_MOSS, {dam=30, pin=33, slow=45},
			0,
			5, nil,
			{type="moss"},
			nil, false, false
		)
	end,
	special_desc = function(self, who)		
		return _t"Automatically sprouts grasping moss underneath nearby enemies, dealing nature damage and slowing their movement."
	end,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	callbackOnKill = function(self, who, target)
		if not rng.percent(4) then return end
		local msg = rng.table{
			_t"Yhudran!",
			_t"Vycdan!",
			_t"Kad ic lmucan!",
			_t"Oui nasaspan dra udranc, nekrd?",
			_t"Ryryry!",
			_t"Fa'ja paah rana duu muhk.  Mayja!",
			_t"Feamtan, yna oui mecdahehk?",
			_t"Suja, suja!",
			_t"Ajanouha rana ec dra cysa.  Mad'c ku cusabmyla haf.",
			_t"Oui teth'd haat sa vun dryd uha.",
		}
		who:setEmote(require("engine.Emote").new(self:getName()..': "'..msg..'"', 120, colors.CRIMSON))
	end,
	finish = function(self, zone, level) -- add and 15 points of physical random powers
		-- the stats of Voyager ego are builit-in, except that the active is learned rather than a charm power, to allow the moss to work
		game.state:addRandartProperties(self, {lev = 0, nb_points_add=15, egos = 1,
			force_themes = {'physical'}})
	end,
}

--------------------------------------------------------------------------------
-- Arrows
--------------------------------------------------------------------------------

newEntity{ base = "BASE_ARROW",
	power_source = {psionic=true},
	unique = true,
	name = "Nnnu's Stinger",
	unided_name = _t"dreamy quiver",
	desc = _t[[You believe that you are drawing an arrow.  You feel its nock against the bowstring.  You see yourself take aim.]],
	color = colors.BLUE, image = "object/artifact/glr_imaginarrow.png",
	proj_image = "object/artifact/arrow_s_glr_imaginarrow.png",
	moddable_tile = "quiver_glr_nnnu",
	moddable_tile_big = true,
	level_range = {35, 50},
	rarity = 300,
	cost = resolvers.rngrange(700,1100),
	material_level = 3,
	infinite=true,
	require = { stat = { wil=32 }, },
	special_desc = function(self) return ("Your arrows hit instantly."):tformat() end,
	combat = {
		capacity = 0,
		dam = 30,
		apr = 50,
		dammod = {dex=0.5, wil=0.5, cun=0.5,},
		damtype = DamageType.MIND,
		ranged_project={
			[DamageType.MIND] = 25,
		},
		special_on_hit = {
			desc=_t"#LIGHT_GREEN#33%#LAST# chance to stun, blind, pin, or silence the target for 3 turns (#SLATE#Mindpower or Accuracy vs Mental#LAST#)",
			fct=function(combat, who, target, dam, special)
				if not rng.percent(33) then return end
				local eff = rng.table{"stun", "blind", "pin", "confusion", "silence",}
				if not target:canBe(eff) then return end
				local check = math.max(who:combatMindpower(), who:combatAttack())
				if not who:checkHit(check, target:combatMentalResist()) then return end
				if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
				elseif eff == "blind" then target:setEffect(target.EFF_BLINDED, 3, {})
				elseif eff == "pin" then target:setEffect(target.EFF_PINNED, 3, {})
				elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
				end
			end
		}
	},
	wielder = {
		instant_shot = 1,
		learn_talent = {[Talents.T_REK_GLR_MARKSMAN_SOUNDSHOCK] = 1},
	},
}


newEntity{ base = "BASE_ARROW",
	power_source = {technique=true},
	unique = true,
	name = "Pale Bolts",
	unided_name = _t"steel quiver",
	desc = _t[[These stubby arrows are composed entirely of metal, but once you adjust to the odd balance, they work just fine.]],
	color = colors.BLUE, image = "object/artifact/glr_steel_arrow.png",
	proj_image = "object/artifact/arrow_s_glr_steel_arrow.png",
	moddable_tile = "quiver_glr_pale",
	moddable_tile_big = true,
	level_range = {15, 35},
	rarity = 300,
	cost = resolvers.rngrange(700,1100),
	material_level = 3,
	combat = {
		capacity = 20, -- average
		dam = 38, -- slightly higher than normal max
		apr = 30, -- triple normal
		dammod = {dex=0.7, str=0.7}, -- higher str value
		ranged_project={[DamageType.PHYSICAL] = 12},
		special_on_hit = {
			on_kill = 0,
			desc=function(self, who, special)
				return ("Shred the target, reducing their phyiscal damage resistance by 5%% (stacks 6 times)"):tformat()
		end,
			fct=function(combat, who, target, dam, special)
				if target then
					target:setEffect(target.EFF_WEAKENED_DEFENSES, 3, {inc = -5, max = -30})
				end
			end
		}
	},
	-- no wielder effects on ammo, you fool!
	-- wielder = {
	-- 	inc_damage={[DamageType.PHYSICAL] = 20},
	-- 	resists_pen={[DamageType.PHYSICAL] = 15},
	-- },
}

-- Aim is to make this the ideal Psychic Marksman weapon
newEntity{ base = "BASE_ARROW",
	power_source = {psionic=true},
	unique = true,
	name = "Jaguar's Teeth",
	unided_name = _t"primitive arrows",
	desc = _t[[Each of these arrowheads are carved from the fang of a Tar'Eyalian great cat, and the fletchings are all of silk.  Holding an arrow, you feel a desperate hunger.]],
	color = colors.BLUE, image = "object/artifact/glr_jaguar_arrow.png",
	proj_image = "object/artifact/arrow_s_glr_jaguar_arrow.png",
	moddable_tile = "quiver_glr_jaguar",
	moddable_tile_big = true,
	level_range = {35, 50},
	rarity = 300,
	require = { stat = { dex=50 }, },
	cost = resolvers.rngrange(700,1100),
	material_level = 5,
	combat = {
		capacity = 30, -- That's the right number of teeth
		dam = 40, apr = 10, -- can be low for T5, the hit isn't the point.
		dammod = {dex=0.7, str=0.5},
		ranged_project={[DamageType.PHYSICAL] = 75},
		physspeed = 0.90,
		special_on_crit = {
			desc=function(self, who, special)
				local dam, hf = special.wound(self.combat, who)
				return ("Wound the target, dealing #RED#%d#LAST# physical damage across 3 turns and reducing healing by %d%%.  This gives you 3 psi and 3 hate."):tformat(dam, hf)
			end,
			wound=function(combat, who)
				local dam = math.max(15, math.floor(who:combatStatScale(who:combatPhysicalpower(), 1, 350)))
				local hf = 50
				return dam, hf
			end,
			fct=function(combat, who, target, dam, special)
				if target:canBe("cut") then
					local dam, hf = special.wound(combat, who)
					local check = math.max(who:combatMindpower(), who:combatAttack())
					target:setEffect(target.EFF_DEEP_WOUND, 3, {src=who, heal_factor=hf, power=who:physicalCrit(dam) / 3, apply_power=check}) 
					if who:knowTalent(who.T_PSI_POOL) then who:incPsi(3) end
					if who:knowTalent(who.T_HATE_POOL) then who:incHate(3) end
				end
			end
		},
		special_on_hit = {
			on_kill = 0,
			desc=function(self, who, special)
				local dam = special.poison(who)
				return ("#LIGHT_GREEN#15%%#LAST# chance to apply spydric poison, pinning the enemy and dealing #RED#%d#LAST# nature damage over 3 turns"):tformat(dam)
			end,
			poison=function(who)
				local dam = math.max(15, math.floor(who:combatStatScale(who:combatPhysicalpower(), 1, 300)))
				return dam
			end,
			fct=function(combat, who, target, dam, special)
				if not rng.percent(15) then return end
				local dam = who:physicalCrit(special.poison(who))
				if target and target:canBe("poison") then
					target:setEffect(target.EFF_SPYDRIC_POISON, 3, {src=who, power=dam/3, no_ct_effect=true})
				end
			end
		},
		special_on_kill = {desc=_t"Fully reload", fct=function(combat, who, target)
												 local ammo = who:hasAmmo()
												 if not ammo then return end
												 ammo.combat.shots_left = ammo.combat.capacity
		end},
	},
	wielder = { -- making an exception here because this is archery stuff
		talents_types_mastery = {["technique/psychic-marksman"] = 0.2},
	},
}

--------------------------------------------------------------------------------
-- Hat
--------------------------------------------------------------------------------

-- Thoughtplague 
--     Head item, stacks up talent failure nearby or on hit



--------------------------------------------------------------------------------
-- Jewelry
--------------------------------------------------------------------------------

-- Kailovela's Regret
-- Amulet
-- Carved in shape of a baby bird
-- Improves Idol talents
--     5th idol aura
-- Adds mindpower
-- ?anti-stealth on you?



--------------------------------------------------------------------------------
-- Cloaks
--------------------------------------------------------------------------------

-- Shadow of the Swarm
--     Cloak
--     Cannot be removed while you have beast talents
--     Eats talent points to give you the beast tree
--         Swing line
--         Summon bugs
--     Can't learn unleash

-- Taki's Wings
--     Cloak    
--     Persistent pair of glass wings
--     Activates for glass wings
--     ?Lets you go across the ocean
