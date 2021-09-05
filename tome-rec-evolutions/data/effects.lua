local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "HOLLOW_BLINDSIDE_BONUS", image = "talents/rek_hollow_shadow_blindside.png",
	desc = _t"Shadow of Speed",
	long_desc = function(self, eff) return ("The target has appeared out of nowhere! It takes %d less damage from each hit."):tformat(eff.power) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "flat_damage_armor", {all=eff.power})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "HOLLOW_DOMINATED", image = "talents/rek_hollow_shadow_dominate.png",
	desc = _t"Dominated",
	long_desc = function(self, eff) return ("The target has been dominated.  It is unable to move and has lost %d armor, %d defense, %d mental save, and 10%% resistance."):tformat(-eff.armorChange, -eff.defenseChange,  -eff.defenseChange) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	on_gain = function(self, err) return "#F53CBE##Target# has been dominated!", "+Dominated" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer dominated.", "-Dominated" end,
	parameters = { armorChange = -3, defenseChange = -3 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "combat_armor", eff.armorChange)
		self:effectTemporaryValue(eff, "combat_def", eff.armorChange)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.armorChange)
		self:effectTemporaryValue(eff, "resists", {all=-10})

		eff.particle = self:addParticles(Particles.new("dominated", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}


newEffect{
	name = "REK_ZEPHYR_ELECTRIC_STAMINA", image = "talents/rek_zephyr_electric_stamina.png",
	desc = _t"Electric Stamina",
	long_desc = function(self, eff) return ("Has %d%% increased lightning penetration."):tformat(eff.power*eff.stacks) end,
	charges = function(self, eff) return eff.stacks end,
	type = "magical",
	subtype = { lightning=true },
	status = "beneficial",
	parameters = { power=5, stacks=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.stacks = math.min(5, old_eff.stacks + 1)
		self:removeTemporaryValue("resists_pen", old_eff.pid)
		old_eff.pid = self:addTemporaryValue("resists_pen", {[DamageType.LIGHTNING]=old_eff.power*old_eff.stacks})

		return old_eff
	end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists_pen", {[DamageType.LIGHTNING]=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists_pen", eff.pid)
	end,
}

newEffect{
	name = "REK_ZEPHYR_STORM_BOLTS", image = "talents/rek_zephyr_storm_bolts.png",
	desc = _t"Storm Bolts",
	long_desc = function(self, eff) return ("The target's arrows become piercing lightning bolts."):tformat(eff.power) end,
	type = "magical",
	subtype = { lightning=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "ranged_project", {[DamageType.LIGHTNING_DAZE] = eff.power})
		
		if not self:getInven("QUIVER") then return end
		local ammoWeapon = self:getInven("QUIVER")[1]
		if not ammoWeapon or not ammoWeapon.combat then return end
		eff.old_tg_type = ammoWeapon.combat.tg_type
		eff.old_takeoff = ammoWeapon.on_cantakeoff
		ammoWeapon.combat.tg_type = "beam"
		ammoWeapon.on_cantakeoff = function(self, who) return true end
	end,
	deactivate = function(self, eff)
		if not self:getInven("QUIVER") then return end
		local ammoWeapon = self:getInven("QUIVER")[1]
		if not ammoWeapon or not ammoWeapon.combat then return end
		ammoWeapon.combat.tg_type = eff.old_tg_type
		ammoWeapon.on_cantakeoff = eff.old_takeoff
	end,
}
