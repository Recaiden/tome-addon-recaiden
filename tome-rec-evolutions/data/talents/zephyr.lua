knowRessource = Talents.main_env.knowRessource

newTalent{
	name = "Zephyr", short_name = "REK_EVOLUTION_ARCHER_ZEPHYR",
	image = "talents/rek_zephyr_storm_archer.png",
	type = {"uber/magic", 1},
	uber = true,
	require = {
		stat = {mag = 50},
		level = 25,
		birth_descriptors={{"subclass", "Archer"}},
		special={
			desc="Know a Spell",
			fct=function(self)
				return self:attr("has_arcane_knowledge")
			end,
		}
	},
	is_class_evolution = "Archer",
	cant_steal = true,
	mode = "passive",
	is_spell = true,
	no_npc_use = true,
	learnAndMaster = function(self, cat, unlocked, mastery)
		self:learnTalentType(cat, unlocked)
		self:setTalentTypeMastery(cat, mastery)
	end,
	getPassiveSpeed = function(self, t) return 0.2 end,
	getManaRegen = function(self, t) return 0.5 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "movement_speed", t:_getPassiveSpeed(self))
		self:talentTemporaryValue(p, "mana_regen", 0.5)
	end,
	on_learn = function(self, t)
		t.learnAndMaster(self, "spell/air", true, 1.3)
		t.learnAndMaster(self, "spell/lightning-archery", true, 1.3)
	end,
	info = function(self, t)
		return ([[Bind the wild magic of wind and lightning together with your archery. 
You gain %d%% movement speed and %0.1f natural mana regeneration.
You learn the Air spell category.
In addition you get access to the unique Lightning Archery generic category:
	- Trigger bolts of lightning with your archery marks and arrows.
	- Regain mana and make your foes vulnerable with each shot.
	- Transform your arrows into piercing lines of lightning.
	- Teleport through enemies and mark them with dazing bolts.
]]):tformat(t:_getPassiveSpeed(self)*100, t:_getManaRegen(self))
	end,
}
